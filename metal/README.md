# Metal Provisioning

These steps encompass the provisioning steps performed on the bare-metal Proxmox
machines to configure them for running app workloads.

# Proxmox Authentication

Proxmox provisioning is performed through Terraform. In order to authenticate
with Proxmox, a provisioning user must be created. This can be done through the
UI, or through the following shell commands (excerpted from [the Terraform
provider][terraform-proxmox]):

```shell
pveum user add terraform@pve
pveum role add Terraform -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify SDN.Use VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt User.Modify"
pveum aclmod / -user terraform@pve -role Terraform
pveum user token add terraform@pve provider --privsep=0
```

The last command spits out an API token which should be added to
`local.auto.tfvars` in the format:

```hcl
proxmox_api_token = "terraform@pve!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

[terraform-proxmox]: https://registry.terraform.io/providers/bpg/proxmox/latest/docs#api-token-authentication
