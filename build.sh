#!/usr/bin/env bash

runfile="$1"
distro="$2"
topdir="$HOME/nvidia-modprobe"
epoch="3"

[[ -n $distro ]] ||
distro=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
[[ $distro == "main" ]] && distro="rhel8"

drvname=$(basename "$runfile")
arch=$(echo "$drvname" | awk -F "-" '{print $3}')
version=$(echo "$drvname" | sed -e "s|NVIDIA\-Linux\-${arch}\-||" -e 's|\.run$||' -e 's|\-grid$||' -e 's|\.tar\..*||' -e 's|nvidia\-modprobe\-||')
drvbranch=$(echo "$version" | awk -F "." '{print $1}')

tarball="nvidia-modprobe-${version}"

err() { echo; echo "ERROR: $*"; exit 1; }
kmd() { echo; echo ">>> $*" | fold -s; eval "$*" || err "at line \`$*\`"; }
dep() { type -p "$1" >/dev/null || err "missing dependency $1"; }

fetch_input() {
    inputfile="${tarball}.tar.bz2"

    # Download runfile
    if [[ ! -f "$inputfile" ]]; then
        dep wget
        kmd wget "https://download.nvidia.com/XFree86/nvidia-modprobe/${tarball}.tar.bz2" -O "$inputfile"
    fi
}

build_rpm()
{
    mkdir -p "$topdir"
    (cd "$topdir" && mkdir -p BUILD BUILDROOT RPMS SRPMS SOURCES SPECS)

    cp -v -- *.patch* "$topdir/SOURCES/"
    cp -v -- *modprobe*.tar* "$topdir/SOURCES/"
    cp -v -- *.spec "$topdir/SPECS/"
    cd "$topdir" || err "Unable to cd into $topdir"

    kmd rpmbuild \
        --define "'%_topdir $(pwd)'" \
        --define "'debug_package %{nil}'" \
        --define "'version $version'" \
        --define "'epoch $epoch'" \
        -v -bb SPECS/nvidia-modprobe.spec

    cd - || err "Unable to cd into $OLDPWD"
}

build_triple_rpm()
{
    mkdir -p "$topdir"
    (cd "$topdir" && mkdir -p BUILD BUILDROOT RPMS SRPMS SOURCES SPECS)

    cp -v -- *.patch* "$topdir/SOURCES/"
    cp -v -- *modprobe*.tar* "$topdir/SOURCES/"
    cp -v -- *.spec "$topdir/SPECS/"

    if [[ -f "nvidia-modprobe-${version}.tar.gz" ]]; then
        extension="gz"
    elif [[ -f "nvidia-modprobe-${version}.tar.bz2" ]]; then
        extension="bz2"
    fi

    for flavor in latest-dkms latest branch-${drvbranch}; do
        cd "$topdir" || err "Unable to cd into $topdir"
        is_latest=0
        is_dkms=0

        if [[ $flavor =~ latest ]]; then
            is_latest=1
        fi

        if [[ $flavor =~ dkms ]]; then
            is_dkms=1
        fi

        echo -e "\n:: flavor $flavor [$is_latest] [$is_dkms]"

        kmd rpmbuild \
            --define "'%_topdir $(pwd)'" \
            --define "'debug_package %{nil}'" \
            --define "'version $version'" \
            --define "'driver_branch $flavor'" \
            --define "'is_dkms $is_dkms'" \
            --define "'is_latest $is_latest'" \
            --define "'extension $extension'" \
            --define "'epoch $epoch'" \
            -v -bb SPECS/nvidia-modprobe.spec

        cd - || err "Unable to cd into $OLDPWD"
        echo "====================="
    done
}

build_wrapper()
{
    echo ":: Building $distro packages"
    if [[ $distro == "rhel7" ]]; then
        build_triple_rpm
    else
        build_rpm
    fi
}


# Download tarball
if [[ -f ${tarball}.tar.bz2 ]]; then
    echo "[SKIP] fetch_input($version)"
else
    echo "==> fetch_input($version)"
    fetch_input
fi

# Sanity check
[[ -n $version ]] || err "version could not be determined"

# Build RPMs
empty=$(find "$topdir/RPMS" -maxdepth 0 -type d -empty 2>/dev/null)
found=$(find "$topdir/RPMS" -mindepth 2 -maxdepth 2 -type f -name "*${version}*" 2>/dev/null)
if [[ ! -d "$topdir/RPMS" ]] || [[ $empty ]] || [[ ! $found ]]; then
    echo "==> build_rpm(${version})"
    dep m4
    dep rpmbuild
    build_wrapper
else
    echo "[SKIP] build_rpm(${version})"
fi

echo "---"
find "$topdir/RPMS" -mindepth 2 -maxdepth 2 -type f -name "*${version}*"
