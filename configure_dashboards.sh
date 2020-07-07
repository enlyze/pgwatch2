#!/bin/bash
set -eu

DATASOURCE="$1"
DIR="$2"

for f in `find ${DIR} -name "dashboard.json"`
do
	tmp=`mktemp`
	jq '.annotations.list = []' "${f}" > "${tmp}"
	mv "${tmp}" "${f}"

	sed -E -i "s/^(\s*\"datasource\":) [A-Za-z0-9_\"\-]+/\1\ \"${DATASOURCE}\"/ig" "${f}"
	chmod 644 "${f}"
done
