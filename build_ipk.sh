#!/bin/sh

mkdir ".tmp"
Version=$(grep Version nox-ovpn/control/control | sed 's|Version: *||1' | tr -d '\n')
cd ./nox-ovpn/control
tar --numeric-owner --group=0 --owner=0 -czf ../../.tmp/control.tar.gz ./*
cd ../data
tar --numeric-owner --group=0 --owner=0 -czf ../../.tmp/data.tar.gz ./*
cd ..
cp debian-binary ../.tmp/
cd ../.tmp/
tar --numeric-owner --group=0 --owner=0 -czf "../nox-ovpn_${Version}.ipk" ./*
cd ..
rm -r .tmp/
exit 0