#!/bin/sh
# Shell script to update Pi-Hole dnsmasq with uklans domains for lancache
#
# Written by Artur 'h0m3' Paiva <dr.hoome@gmail.com>
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

dnsmasq_dir="/etc/dnsmasq.d"

info() {
    echo ":: Update PiHole Lancache: $(date): $1"
}

backup_old() {
    info "Backing up old domain list"
    mkdir -pv "${dnsmasq_dir}/backup" || return 1
    mv -v "${dnsmasq_dir}/arenanet.conf" /etc/dnsmasq
    mv -v "${dnsmasq_dir}/blizzard.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/bsg.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/cityofheroes.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/daybreak.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/epicgames.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/frontier.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/neverwinter.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/nexusmods.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/nintendo.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/origin.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/pathofexile.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/renegadex.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/riot.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/rockstar.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/sony.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/square.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/steam.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/teso.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/uplay.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/warframe.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/wargaming.net.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/windowsupdates.conf" "${dnsmasq_dir}/backup"
    mv -v "${dnsmasq_dir}/xboxlive.conf" "${dnsmasq_dir}/backup"
    return 0
}

clone_cache() {
    info "Getting cache domain url"
    [[ -z ${CACHE_DOMAINS_URL} ]] && export CACHE_DOMAINS_URL="https://github.com/uklans/cache-domains"

    info "Cloning '${CACHE_DOMAINS_URL}'"
    cwd="$(pwd)"
    cd /tmp
    git clone "${CACHE_DOMAINS_URL}" cache_domains || return 1
    cd "${cwd}"
}

configure() {
    info "Copying configuration"
    cp -av /app/config.json /tmp/cache_domains/scripts/config.json || return 1

    info "Updating configuration"
    [[ -z $CACHE_IP ]] && export CACHE_IP="127.0.0.1"
    sed -i "s/127.0.0.1/${CACHE_IP}/g" /tmp/cache_domains/scripts/config.json || return 1
}

generate_domains() {
    info "Generating domain lists (create-dnsmasq.sh)"

    cwd="$(pwd)"
    cd /tmp/cache_domains/scripts/
    /bin/bash create-dnsmasq.sh || return 1

    info "Coyping new domains list"
    mkdir -pv /etc/dnsmasq.d || return 1
    cp -av output/dnsmasq/*.conf "${dnsmasq_dir}" || return 1

    cd "${cwd}"
}

restart_container() {
    if [[ ! -z "${CONTAINER_RESTART}" ]]; then
        info "Restarting docker container '${CONTAINER_RESTART}'"
        docker restart "${CONTAINER_RESTART}" || return 1
    fi
}

cleanup() {
    info "Cleaning up temporary files"
    rm -rfv /tmp/cache_domains || return 1
    rm -rfv "${dnsmasq_dir}/backup" || return 1
}

restore() {
    info "Restoring old domains"
    if ! mv -v "${dnsmasq_dir}/backup/*.conf" "${dnsmasq_dir}/"; then
        info "Failed to restore old domains"
    fi
}

loop() {
    info "Starting domain list update"

    if ! backup_old; then
        info "Failed to perform backup of old domains list"
        return
    fi

    if ! clone_cache; then
        info "Failed to clone cache"
        restore
        return
    fi

    if ! configure; then
        info "Failed to generate configuration"
        restore
        return
    fi

    if ! generate_domains; then
        info "Failed to generate a new domain list"
        restore
        return
    fi

    if ! restart_container; then
        info "Failed to restart container"
        return
    fi
}

info "Welcome to Update Pihole Lancache"
echo "Written by Artur 'h0m3' Paiva <dr.hoome@gmail.com>"
echo "Under Mozilla Public License, v. 2.0."

while true; do
    loop
    if ! cleanup; then
        info "Failed to cleanup temporary data"
    fi

    [[ -z $WAIT_DAYS ]] && export WAIT_DAYS=7
    info ":: Waiting ${WAIT_DAYS} days"
    sleep ${WAIT_DAYS}d
done
