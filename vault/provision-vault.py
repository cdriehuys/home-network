#!/usr/bin/env python

import argparse
import enum
import getpass
import logging
import pathlib
import sys
from typing import Any, List

import hvac


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

BASE_DIR = pathlib.Path(__file__).resolve().parent

KV_MOUNT_POINT = "secrets"


class KVMountVersion(enum.Enum):
    ONE = "1"
    TWO = "2"


class SecretAttr:
    def __init__(self, name, help="", allow_file: bool = False, data_type=str):
        self.name = name
        self.help = help
        self.allow_file = allow_file
        self.data_type = data_type

    def prompt_value(self) -> Any:
        print(f"\n{self.name}:")
        if self.help:
            print(f"  {self.help}")

        if self.allow_file and self._prompt_yes_no("Read from file"):
            while True:
                path = input("  Path to file: ")
                with open(path) as f:
                    return self.data_type(f.read())

        while True:
            raw = getpass.getpass(f"  Value ({self.data_type.__name__}): ")

            try:
                return self.data_type(raw)
            except ValueError:
                print(
                    f"  Please enter a valid value of type "
                    f"{self.data_type.__name__}."
                )

    def _prompt_yes_no(self, prompt: str, default: bool = False):
        affirmatives = ["y", "yes"]
        negatives = ["n", "no"]

        defaults = "[Y/n]" if default else "[y/N]"

        answer = input(f"  {prompt} {defaults}: ")

        if default:
            return answer.lower() not in negatives

        return answer.lower() in affirmatives


class VaultSecret:
    def __init__(
        self, mount_point: str, path: str, attrs: List[SecretAttr], ttl: str = None
    ):
        self.mount_point = mount_point
        self.path = path
        self.attrs = attrs
        self.ttl = ttl

    def ensure_present(self, client: hvac.Client):
        if self._needs_write(client):
            self.write(client)
        else:
            logger.info(
                "Mount point %s/ contains secret %s which does not need updating.",
                self.mount_point,
                self.path,
            )

    def _needs_write(self, client: hvac.Client):
        path_components = self.path.rsplit("/", 1)
        if len(path_components) == 2:
            parent_folder, secret_name = path_components
        else:
            parent_folder, secret_name = "", self.path

        logger.debug(
            "Searching mount point %s/ in the folder %s/ for secret %s",
            self.mount_point,
            parent_folder,
            secret_name,
        )

        try:
            list_result = client.secrets.kv.v1.list_secrets(
                mount_point=self.mount_point, path=parent_folder + "/"
            )
        except hvac.exceptions.InvalidPath:
            logger.info(
                "Mount point %s/ does not have the containing folder %s/ for the secret %s.",
                self.mount_point,
                parent_folder,
                self.path,
            )
            return True

        logging.debug(
            "Mount point %s/ has path %s/ containing the keys %s",
            self.mount_point,
            parent_folder,
            ", ".join(list_result["data"]["keys"]),
        )
        if secret_name not in list_result["data"]["keys"]:
            logging.info(
                "Mount point %s does not contain the secret %s.",
                self.mount_point,
                self.path,
            )
            return True

        read_result = client.secrets.kv.v1.read_secret(
            mount_point=self.mount_point, path=self.path
        )

        for attr in self.attrs:
            if attr.name not in read_result["data"]:
                logging.info(
                    "Mount point %s/ contains the secret %s, but it is missing the %s key.",
                    self.mount_point,
                    self.path,
                    attr.name,
                )
                return True

        return False

    def write(self, client: hvac.Client):
        secret_data = dict()

        # Allow for an advisory TTL for a V1 KV engine.
        # https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v1#ttls
        if self.ttl is not None:
            secret_data["ttl"] = self.ttl

        print(f"\nPlease enter the values for {self.mount_point}/{self.path}:")
        for attr in self.attrs:
            secret_data[attr.name] = attr.prompt_value()

        client.secrets.kv.v1.create_or_update_secret(
            mount_point=self.mount_point, path=self.path, secret=secret_data
        )

        logger.info(
            "Wrote a new value for mount point %s/ secret %s",
            self.mount_point,
            self.path,
        )


def create_parser():
    parser = argparse.ArgumentParser(
        prog="provision-vault",
        description=(
            "An interactive program for ensuring that our Vault instance is "
            "provisioned in the way we expect."
        ),
    )

    parser.add_argument(
        "--vault-token",
        help=(
            "The authentication token to use when interacting with Vault. It "
            "is probably easiest to use the root token for this due to all the "
            "permissions required, but a suitably elevated admin token would "
            "also work."
        ),
    )
    parser.add_argument(
        "--vault-url",
        help=(
            "The URL of the Vault service to interact with. This should "
            "include a scheme, host, and port."
        ),
    )

    return parser


def mount_kv_engine(client: hvac.Client, path: str, version: KVMountVersion):
    client.sys.enable_secrets_engine(
        backend_type="kv",
        path=path,
        options={"version": version.value},
    )
    logger.info("Mounted KV engine v%s at %s", version.value, path)


def ensure_kv_mount(client: hvac.Client, path: str, version: KVMountVersion):
    secrets_engines = client.sys.list_mounted_secrets_engines()["data"]

    if path not in secrets_engines:
        logger.info(
            "No KV secrets engine mounted at %s. Attempting to mount it.",
            path,
        )
        mount_kv_engine(client, path, version)
        return

    engine = secrets_engines[path]
    if engine["type"] != "kv":
        raise ValueError(
            f"Expected a KV engine at {path}, but found a {engine['type']} "
            f"engine instead.",
        )

    if engine["options"].get("version") != version.value:
        raise ValueError(
            f"Expected the KV engine mounted at {path} to be version "
            f"{version.value}, but it is a version "
            f"{engine['options']['version']} engine."
        )

    logger.info("Found a KV version %s engine at %s", version.value, path)


def upload_policies(client: hvac.Client, policy_dir: pathlib.Path):
    logger.info("Uploading policies from %s", policy_dir)
    for policy_path in policy_dir.glob("*.hcl"):
        logger.debug("Found policy at %s", policy_path)

        with policy_path.open() as f:
            client.sys.create_or_update_policy(name=policy_path.stem, policy=f.read())

        logger.info("Uploaded policy %s from %s", policy_path.stem, policy_path)


def main():
    parser = create_parser()
    args = parser.parse_args()

    if not args.vault_url:
        print(
            "\nNo Vault URL specified. Please provide the URL (with scheme, "
            "host, and port) of the Vault instance to interact with."
        )
        args.vault_url = input("Vault URL: ")

    if not args.vault_token:
        print(
            "\nNo Vault token specified. Please provide a token that has "
            "read/write permissions for engine mounts, secrets, and policies."
        )
        args.vault_token = getpass.getpass(prompt="Vault Token: ")

    client = hvac.Client(url=args.vault_url, token=args.vault_token)
    if not client.is_authenticated():
        logger.error("Could not authenticate. Please check the Vault URL and token.")
        sys.exit(1)

    ensure_kv_mount(client, f"{KV_MOUNT_POINT}/", KVMountVersion.ONE)

    secrets = [
        VaultSecret(
            KV_MOUNT_POINT,
            "cloudflare",
            [
                SecretAttr(
                    "dns_api_token", help="Token for interacting with Cloudflare DNS."
                )
            ],
        ),
        VaultSecret(
            KV_MOUNT_POINT,
            "cloudflare/tunnels/home-assistant",
            [SecretAttr("token", help="Token for the Home Assistant tunnel.")],
        ),
        VaultSecret(
            KV_MOUNT_POINT,
            "google/calendar/personal",
            [
                SecretAttr(
                    "ics_url",
                    help="URL of the ICS file for the calendar that doesn't require authentication.",
                )
            ],
        ),
        VaultSecret(
            KV_MOUNT_POINT,
            "google/home-assistant",
            [
                SecretAttr("project_id", help="Google Cloud project ID."),
                SecretAttr(
                    "service_account",
                    allow_file=True,
                    help="Service account credentials.",
                ),
            ],
        ),
        VaultSecret(
            KV_MOUNT_POINT,
            "home/location",
            [
                SecretAttr("elevation", help="Elevation in meters.", data_type=int),
                SecretAttr("latitude", data_type=float),
                SecretAttr("longitude", data_type=float),
            ],
        ),
        VaultSecret(
            KV_MOUNT_POINT,
            "personal",
            [
                SecretAttr("email", help="Personal email address."),
            ],
        ),
        VaultSecret(
            KV_MOUNT_POINT,
            "tailscale",
            [SecretAttr("auth_key", help="Token used to authenticate exit nodes.")],
            # Since Tailscale auth tokens have a maximum validity period, we
            # need clients to poll for changes to the token.
            ttl="30m",
        ),
    ]

    for secret in secrets:
        secret.ensure_present(client)

    upload_policies(client, BASE_DIR / "policies")

    token_roles = [
        {
            "role_name": "nomad-cluster",
            "disallowed_policies": "nomad-server",
            "token_explicit_max_ttl": 0,
            "orphan": True,
            # 3 days in seconds
            "token_period": 259200,
            "renewable": True,
        }
    ]

    for token_role in token_roles:
        client.adapter.post(
            f"/v1/auth/token/roles/{token_role['role_name']}", json=token_role
        )
        logger.info("Uploaded token role %s", token_role["role_name"])


if __name__ == "__main__":
    main()
