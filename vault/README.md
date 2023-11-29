# Vault

## Renewing the Nomad Token

Execute `vault login` to authenticate. Then run the provisioning script for the
Vault instance:

```shell
./provision-vault.py
```

If the Nomad cluster has been disconnected from Vault for an extended period,
the vault token will have expired. To renew it, ensure the token role is
present, then create a new token:

```shell
vault write /auth/token/roles/nomad-cluster @nomad-cluster-role.json
vault token create -policy nomad-server -period 72h -orphan
```

Use the generated token in the Ansible vault, then re-provision the Nomad
servers.

For more complete documentation, see the
[Nomad Vault integration documentation][nomad-vault-integration].

[nomad-vault-integration]: https://developer.hashicorp.com/nomad/docs/integrations/vault-integration
