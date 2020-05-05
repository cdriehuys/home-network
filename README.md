# Home Network

All about the home network.


## Networks

Name    | Purpose               | Subnet         | VLAN
--------|-----------------------|----------------|-----
Trusted | Any trusted devices   | 192.168.2.0/24 | 2
Guest   | Visitors              | 192.168.3.0/24 | 3
IoT     | Untrusted IoT devices | 192.168.4.0/24 | 4

### IoT Network

The IoT network requires additional setup to ensure that operations such as
casting to a Chromecast are still possible despite the segregation of the
network. The highlights are:

* The IoT network should have "IGMP Snooping" enabled.
* The WiFi network for IoT devices should have "Multicast Enhancement" enabled.

Additionally, the "MulticastDNS Service" must be enabled so that devices can
discover IoT devices even though they are on a different VLAN. This can be found
in __Settings > Services > MDNS__ within the UniFi controller.

For full instructions, see the [UniFi help article][unifi-chromecast].


## Firewall

### Groups

Name    | Address(es)
--------|------------------------------------------------
RFC1918 | `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`

### LAN IN

Name                                | Action | Source  | Destination   | Notes
------------------------------------|--------|---------|---------------|--------------------------------------------------
Allow established/related sessions  | Accept | All     | All           | Only packets in "Established" or "Related" states
Allow DNS to Pi-hole                | Accept | RFC1918 | 192.168.1.159 |
Allow trusted to access other VLANs | Accept | Trusted | RFC1918       |
Block inter-VLAN traffic            | Drop   | RFC1918 | RFC1918       |


## Problem Solving

The configuration described above didn't appear out of thin air. It was
developed in response to specific problems. This is an attempt to list
some of those problems.

### Inability to Cast to Chromecast

After setting up the [IoT network](#iot-network), devices on the trusted
network could discover the Chromecasts on the network but could not talk to
them despite the firewall rule allowing traffic from trusted devices to any
other VLAN.

The fix for this was to add the highest priority rule that allows established or
related sessions. In hindsight this is obvious, but as a beginner to networking,
it was not immediately clear to me why this was failing.

[unifi-chromecast]: https://help.ui.com/hc/en-us/articles/360001004034-UniFi-Best-Practices-for-Managing-Chromecast-Google-Home-on-UniFi-Network

