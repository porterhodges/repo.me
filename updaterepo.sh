#!/usr/bin/env bash
script_full_path=$(dirname "$0")
cd $script_full_path || exit 1

needed=()
toInstall=(
    "wget"
    "xz"
    "zstd"
    "lz4"
)

if [[ "$(uname)" == "Darwin" ]]; then # macOS (Intel) usage of repo.me
    if [[ "$(uname -m)" == "x86_64" ]]; then
        echo "Checking for Homebrew, wget, xz, & zstd..."
        if test ! "$(which brew)"; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        fi

        echo "apt-ftparchive compiled by Diatrus" # credits to Hayden!
        wget -q -nc https://apt.procurs.us/apt-ftparchive # assuming Homebrew is already installed, download apt-ftparchive via wget
        chmod 0755 ./apt-ftparchive
        FTPARCHIVE='./apt-ftparchive'

        if [[ ! -z "${needed[@]}" ]]; then
            read -p "$(printf -- "Using Homebrew to install:\n%s\n  Press Enter to Continue. " "${needed[@]}")"
        fi

        for depend in ${needed[@]}; do
            brew install "${depend}"
        done
    fi
if [[ "$(uname)" == "Darwin" ]]; then # macOS (Arm) usage of repo.me
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo "Checking for Homebrew, wget, xz, & zstd..."
        if test ! "$(which brew)"; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        fi

        echo "apt-ftparchive compiled by Diatrus" # credits to Hayden!
        wget -q -nc https://apt.procurs.us/apt-ftparchive # assuming Homebrew is already installed, download apt-ftparchive via wget
        chmod 0755 ./apt-ftparchive
        FTPARCHIVE='./apt-ftparchive'

        if [[ ! -z "${needed[@]}" ]]; then
            read -p "$(printf -- "Using Homebrew to install:\n%s\n  Press Enter to Continue. " "${needed[@]}")"
        fi

        for depend in ${needed[@]}; do
            brew install "${depend}"
        done
    fi    
else
        if test ! "$(which apt-ftparchive)"; then
            echo "Please install apt-utils."
            exit 1
        fi

        FTPARCHIVE='apt-ftparchive'

        if [[ ! -z "${needed[@]}" ]]; then
            printf -- "Please install:\n%s\n" "${needed[@]}" && exit 1
        fi
fi    

rm {Packages{,.xz,.gz,.bz2,.zst,.lz4,.lzma},Release{,.gpg},InRelease} 2> /dev/null

$FTPARCHIVE packages ./debians > Packages
gzip -c9 Packages > Packages.gz
xz -c9 Packages > Packages.xz
xz -5fkev --format=lzma Packages > Packages.lzma
zstd -c19 Packages > Packages.zst
bzip2 -c9 Packages > Packages.bz2  
lz4 -c9 Packages > Packages.lz4

$FTPARCHIVE release -c ./assets/repo/repo.conf . > Release

echo "Repository Updated, thanks for using repo.me!"
