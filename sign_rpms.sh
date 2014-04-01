#!/bin/bash

## Copyright (C) 2014 Red Hat, Inc., Kiril Nesenko <knesenko@redhat.com>
### This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

GPG_NAME="oVirt"

die() {
	local msg="${1?}"
	echo "FATAL: ${msg}"
	exit 1
}

usage() {
	cat << __EOF__
${0} [options]
    --repository=REPO
    --key=KEY
__EOF__
}

get_opts() {
	while [[ -n "${1}" ]]; do
		opt="${1}"
		val="${opt#*=}"
		shift
		case ${opt} in
			--repository=*)
				REPO="${val}"
				;;
			--key=*)
				KEY="${val}"
				;;
			--help|-h)
				usage
				exit 0
				;;
			*)
				usage
				die "Wrong option"
				;;
		esac
	done
	return 0
}

validate() {
	[[ -n "${REPO}" ]] || die "Please specify --repository="
	[[ -n "${KEY}" ]] || die "Please specify --key="
	[[ -d "${REPO}" ]] || die "${REPO} does not exist"
	if ! rpm -q rpm-sign >& /dev/null; then
		die "Please install rpm-sign pkg and try once again"
	fi
}

sign_pkgs() {
	local pkgs="$(find "${REPO}" -type f -name "*.rpm")"
	rpmsign --resign --key-id="${KEY}" -D "_signature gpg" -D "_gpg_name ${GPG_NAME}" ${pkgs}
}

main() {
	get_opts "${@}"
	validate
	sign_pkgs
}

main "${@}"
