# yum packaging nvidia modprobe

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Contributing](https://img.shields.io/badge/Contributing-Developer%20Certificate%20of%20Origin-violet)](https://developercertificate.org)

## Overview

Packaging templates for `yum` and `dnf` based Linux distros to build NVIDIA modprobe packages.

The `main` branch contains this README. The `.spec` and `.patch` files can be found in the appropriate [rhel7](../../tree/rhel7), [rhel8](../../tree/rhel8), and [fedora](../../tree/fedora) branches.

## Table of Contents

- [Overview](#Overview)
- [Deliverables](#Deliverables)
- [Prerequisites](#Prerequisites)
  * [Clone this git repository](#Clone-this-git-repository)
  * [Install build dependencies](#Install-build-dependencies)
- [Building with script](#Building-with-script)
- [Building Manually](#Building-Manually)
- [Related](#Related)
  * [DKMS nvidia](#DKMS-nvidia)
  * [NVIDIA driver](#NVIDIA-driver)
  * [NVIDIA kmod common](#NVIDIA-kmod-common)
  * [NVIDIA persistenced](#NVIDIA-persistenced)
  * [NVIDIA plugin](#NVIDIA-plugin)
  * [NVIDIA precompiled kmod](#NVIDIA-precompiled-kmod)
  * [NVIDIA settings](#NVIDIA-settings)
  * [NVIDIA xconfig](#NVIDIA-xconfig)
- [Contributing](#Contributing)


## Deliverables

This repo contains the `.spec` file used to build the following **RPM** packages:


> _note:_ `XXX` is the first `.` delimited field in the driver version, ex: `460` in `460.32.03`

* **RHEL8** or **Fedora** streams: `XXX`, `XXX-dkms`, `latest`, and `latest-dkms`
 ```shell
 nvidia-modprobe
 ```


For RHEL7 and derivatives, there are three sets of packages with different package dependencies.

The `latest` and `latest-dkms` flavors always update to the highest versioned driver, while the `branch-XXX` flavor locks driver updates to the specified driver branch.

* **RHEL7** flavor: `latest-dkms`
 ```shell
 nvidia-driver-latest-dkms-modprobe
 ```


> *note:* `XXX-dkms` is not supported for RHEL7


To use the precompiled flavors `latest` and `branch-XXX`, use [yum-packaging-precompiled-kmod](https://github.com/NVIDIA/yum-packaging-precompiled-kmod) to build `kmod-nvidia-latest` or `kmod-nvidia-branch-XXX` kernel modules for a specific kernel and driver combination.

* **RHEL7** flavor: `latest`
 ```shell
 nvidia-driver-latest-modprobe
 ```


* **RHEL7** flavor: `branch-XXX`
 ```shell
 nvidia-driver-branch-XXX-modprobe
 ```


## Prerequisites

### Clone this git repository:

Supported branches: `rhel7`, `rhel8` & `fedora`

```shell
git clone -b ${branch} https://github.com/NVIDIA/yum-packaging-nvidia-modprobe
> ex: git clone -b rhel8 https://github.com/NVIDIA/yum-packaging-nvidia-modprobe
```

### Download a NVIDIA modprobe tarball:

* **Source code** location: [https://github.com/NVIDIA/nvidia-modprobe/releases](https://github.com/NVIDIA/nvidia-modprobe/releases)

  *ex:* [https://github.com/NVIDIA/nvidia-modprobe/archive/460.32.03.tar.gz](https://github.com/NVIDIA/nvidia-modprobe/archive/460.32.03.tar.gz)

  *ex:* [https://github.com/NVIDIA/nvidia-modprobe/archive/460.56.tar.gz](https://github.com/NVIDIA/nvidia-modprobe/archive/460.56.tar.gz)

### Install build dependencies

```shell
# Compilation
yum install m4 gcc
# Packaging
yum install rpm-build
```


## Building with script

### Fetch script from `main` branch

```shell
cd yum-packaging-nvidia-modprobe
git checkout remotes/origin/main -- build.sh
```

### Usage

```shell
./build.sh [$version | path/to/*.tar.{gz,bz2} | path/to/*.run]
> ex: time ./build.sh 460.32.03
> ex: time ./build.sh ~/Downloads/nvidia-modprobe-450.102.04.tar.bz2
> ex: time ./build.sh ~/Downloads/nvidia-modprobe-460.32.03.tar.gz
> ex: time ./build.sh ~/Downloads/NVIDIA-Linux-x86_64-450.102.04.run
```
> _note:_ runfile is only used to determine version



## Building Manually

### Packaging (`dnf` distros)
> note: `fedora` & `rhel8`-based distros

```shell
mkdir BUILD BUILDROOT RPMS SRPMS SOURCES SPECS
cp *.patch SOURCES/
cp nvidia-modprobe-${version}.tar.gz SOURCES/
cp nvidia-modprobe.spec SPECS/

rpmbuild \
    --define "%_topdir $(pwd)" \
    --define "debug_package %{nil}" \
    --define "version $version" \
    --define "epoch 3" \
    --define "extension gz" \
    -v -bb SPECS/nvidia-modprobe.spec
```

### Packaging (`yum` distros)
> note: `rhel7`-based distros

```shell
mkdir BUILD BUILDROOT RPMS SRPMS SOURCES SPECS
cp *.patch SOURCES/
cp nvidia-modprobe-${version}.tar.gz SOURCES/
cp nvidia-modprobe.spec SPECS/

# latest-dkms
rpmbuild \
    --define "%_topdir $(pwd)" \
    --define "debug_package %{nil}" \
    --define "version $version" \
    --define "driver_branch latest-dkms" \
    --define "is_dkms 1" \
    --define "is_latest 1" \
    --define "epoch 3" \
    --define "extension gz" \
    -v -bb SPECS/nvidia-modprobe.spec

# latest
rpmbuild \
    --define "%_topdir $(pwd)" \
    --define "debug_package %{nil}" \
    --define "version $version" \
    --define "driver_branch latest" \
    --define "is_dkms 0" \
    --define "is_latest 1" \
    --define "epoch 3" \
    --define "extension gz" \
    -v -bb SPECS/nvidia-modprobe.spec

# branch-460
rpmbuild \
    --define "%_topdir $(pwd)" \
    --define "debug_package %{nil}" \
    --define "version $version" \
    --define "driver_branch branch-460" \
    --define "is_dkms 0" \
    --define "is_latest 0" \
    --define "epoch 3" \
    --define "extension gz" \
    -v -bb SPECS/nvidia-modprobe.spec
```


## Related

### DKMS nvidia

- dkms-nvidia
  * [https://github.com/NVIDIA/yum-packaging-dkms-nvidia](https://github.com/NVIDIA/yum-packaging-dkms-nvidia)


### NVIDIA driver

- nvidia-driver
  * [https://github.com/NVIDIA/yum-packaging-nvidia-driver](https://github.com/NVIDIA/yum-packaging-nvidia-driver)

### NVIDIA kmod common

- Common files
  * [https://github.com/NVIDIA/yum-packaging-nvidia-kmod-common](https://github.com/NVIDIA/yum-packaging-nvidia-kmod-common)

### NVIDIA persistenced

- nvidia-persistenced
  * [https://github.com/NVIDIA/yum-packaging-nvidia-persistenced](https://github.com/NVIDIA/yum-packaging-nvidia-persistenced)

### NVIDIA plugin

- _dnf-plugin-nvidia_ & _yum-plugin-nvidia_
  * [https://github.com/NVIDIA/yum-packaging-nvidia-plugin](https://github.com/NVIDIA/yum-packaging-nvidia-plugin)

### NVIDIA precompiled kmod

- Precompiled kernel modules
  * [https://github.com/NVIDIA/yum-packaging-precompiled-kmod](https://github.com/NVIDIA/yum-packaging-precompiled-kmod)

### NVIDIA settings

- nvidia-settings
  * [https://github.com/NVIDIA/yum-packaging-nvidia-settings](https://github.com/NVIDIA/yum-packaging-nvidia-settings)

### NVIDIA xconfig

- nvidia-xconfig
  * [https://github.com/NVIDIA/yum-packaging-nvidia-xconfig](https://github.com/NVIDIA/yum-packaging-nvidia-xconfig)


## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)
