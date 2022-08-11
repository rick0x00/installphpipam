#!/usr/bin/env bash

# =============================================================
# Script created date: 10 ago 2022
# Created by: Henrique Silva (henriquesilvadotcontact@gmail.com
# Name: installphpipam
# Description: script to install phpIPAM on server
# License: GPL-3.0
# Remote repository 1: https://github.com/rick0x00/installphpipam
# Remote repository 2: https://gitlab.com/rick0x00/installphpipam

# Tested Servers:
# # Operational Sistem  - Date 
# # Debian-11.2.0-amd64 - xx ago 2022
# =============================================================

underline="________________________________________________________________";
equal="================================================================";
hash="################################################################";
plus="++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo "$hash"

apt update
apt upgrade -y
apt autoremove -y 