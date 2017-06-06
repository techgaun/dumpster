#!/bin/bash

indir="${1}"
outfile="${2}"
metafile="${3}"

tar -cvzf "${outfile}" "${indir}" 2> /tmp/log.txt
touch "${metafile}"
