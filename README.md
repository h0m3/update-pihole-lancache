# Update Pihole Lancache

This is a container with a script to update pihole with the latest DNS entries for use with Lancache

## How to use

Using docker directly you can run by:

```bash
docker run --name=update-pihole-lancache --restart=unless-stopped -d -v ./pihole/dnsmasq:/etc/dnsmasq.d -v /var/run/docker.sock:/var/run/docker.sock -e CACHE_IP=192.168.1.200 -e CONTAINER_RESTART=pihole h0m3/update-pihole-lancache:latest
```

Replacing `192.168.1.200` with your lancache instance IP and `pihole` with the name of your pihole container

### Docker compose

```docker-compose
version: "3"
services:
    update-pihole-lancache:
        image: h0m3/update-pihole-lancache:latest
        restart: unless-stopped
        volumes:
            - ./pihole/dnsmasq:/etc/dnsmasq.d
            - /var/run/docker.socker:/var/run/docker.sock
        environment:
            CACHE_IP: 192.168.1.200
            CONTAINER_RESTART: pihole
```

Replacing `192.168.1.200` with your lancache instance IP and `pihole` with the name of your pihole container

## Environment variables

The follow environment variables can be used:

Environment Variable | Description | Default
-|-|-
`CACHE_DOMAINS_URL` | The URL where it gonna clone the list of domains, using the uklans format | `https://github.com/uklans/cache-domains`
`CACHE_IP` | IP address of your lancache instance | `127.0.0.1`
`WAIT_DAYS` | Number of days to wait between domain list updates | `7`
`CONTAINER_RESTART` | Name of the container to restart after updating, no container will restart if none is supplied

## Volumes

Volume | Descriptio
-|-
`/etc/dnsmasq.d` | dnsmasq folder to add the domain list, should be pointed to pihole's dnsmasq folder, which can be exposed at the same path `/etc/dnsmasq.d`. Check out [here](https://github.com/pi-hole/docker-pi-hole/) for more information.
`/var/run/docker.sock` | Path to docker socket, only used to restart the container at the end of the upgrade, this is not required if no container is to be restart
`/app/config.json` | Path to `config.json` used to configure the domain list, this shouldn't be mounted unless you have specific reasons. Check out more [here](https://github.com/uklans/cache-domains/tree/master/scripts).


## How it works

This script periodically requests a list of domains from [uklans cache domain list](https://github.com/uklans/cache-domains) and apply it on [dnsmasq](https://dnsmasq.org/) which is the DNS server for [Pi-Hole](https://pi-hole.net/).

[uklans cache domain list](https://github.com/uklans/cache-domains) is the official domain list used by [lancache](https://lancache.net/).

## Can I use other service than pihole

As long as its a [dnsmasq](https://dnsmasq.org/) service, sure, you just need to point /etc/dnsmasq.d to your dnsmasq folder to update the domains list.

## Can I use other list than uklans?

Sure, it needs to follow the same structure as uklans, specially the `scripts` folder and the `config.json` file since those are used by the script to generate the domain list. Just change the `CACHE_DOMAINS_URL` variable.

## Can I use another service than lancache?

Also yes, the script will point the domains to any IP set in `CACHE_IP`. The script was designed with lancache in mind but I dont see any problem pointing to any other service.

## What the docker container does?

Not much, its a bare [Alpine](https://hub.docker.com/_/alpine) container with the necessary tools installed and the script. Its just convenient since most of the time [Pi-Hole](https://pi-hole.net/) and [lancache](https://lancache.net/) also run under docker.

Providing that you have all dependencies theres no reason to run the script outside the containers, if you want you need the follow dependencies:

- [git](https://git-scm.com/)
- [jq](https://stedolan.github.io/jq/)
- [bash](https://www.gnu.org/software/bash/)
- [docker](https://www.docker.com/)

Also, you need to have the correct permissions to write to your dnsmasq folder and `/tmp`.

## Note

This script is not affiliated with [Pi-Hole](https://pi-hole.net/), [dnsmasq](https://dnsmasq.org/), [uklans](https://github.com/uklans/) or [lancache](https://lancache.net/). This is just a script i've made to automate my lancache + pihole setup.

## Licensing

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
