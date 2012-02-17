#!/bin/bash
declare -a arch_qemu
version="squeeze"
archs=("i386", "amd64")
arch_qemu=( [i386]=i386 [amd64]=x86_64 )
script_url="https://raw.github.com/degeneratedlabs/Degeneratedlabs-Debian-Buildbot/master/initscript.sh"
cleanup(){ (( $(ls -l|wc -l) > 3 )) && rm -rf /root/*; }
chdir_(){ rm -rf /root/`date +%M-%D`/; mkdir -p /root/`date +%M-%D`/logs; cd /root/`date +%M-%D`/; }
launch_qemu(){ arch=$1; shift; qemu-${arch_qemu[$arch]} $@ images/debian_${version}_${arch}_standard.qcow2; }
build_package_and_iso(){ launch_qemu $1 "--no-graphic" ; }
prepare_image(){ 
    log="logs/debian-download-${1}_${version}-`date +%M-%D_%m-%d`"
    image_url="http://people.debian.org/~aurel32/qemu/$1/debian_${version}_${arch}_standard.qcow2"
    [[ ! -f images/debian_${version}_${1}_standard.qcow2 ]] && { 
	    wget $image_url -O images/debian_${version}_${1}_standard.qcow2 &> $log && {
            echo "Paste this on qemu's console. User root password root:"
            echo "wget --no-check-certificate \"$script_url\" -O /etc/init.d/dlabs_builder;"
            echo "chmod +x /etc/init.d/dlabs_builder; update-rc.d dlabs_builder default; halt;"
            read && launch_qemu $1 "--curses"; return
        }
    }
}

cleanup; chdir_
#This happens just the first time you have a new arch ;)
for arch in $archs; do prepare_image $arch; done # Get all qemu images and install the initscript on them. #

# Dangerous: make sure to not build it for more than two archs as a time if you don't have a huge computer
for arch in $archs; do build_package_and_iso $arch & done # Build packages and isos in parallel.
