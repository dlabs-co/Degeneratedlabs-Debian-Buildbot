#!/bin/bash
# Copyright 2012 David Francos Cuartero
# This File is licensed under the GNU General Public License version 2 or superior (GPL2+)
# Degeneratedlabs initscript
# Each time you launch the virtual machine it will recreate the debian packages and dlive

dir=/root/
logfile=${dir}/`date +%m-%d`.log

install_tools(){ apt-get install devscripts dh-make debhelper live-build live-config live-tools; }
cleanup(){ (( $(ls -l|wc -l) > 3 )) && rm -rf /root/*; }
mkdirs(){ mkdir -p $dir/dlabs; cd $dir/dlabs; cleanup; }

get_aircrackng(){
  echo "Getting aircrack-ng from subversion"
  svn co http://trac.aircrack-ng.org/svn/trunk aircrack-ng-1.1 && {
      cd aircrack-ng-1.1 
      rm -rf `find . -name .svn` 
      echo "Creating orig file"
      tar czvf  ../aircrack-ng_1.1.orig.tar.gz *; 
      git clone http://github.com/XayOn/Aircrack-ngDebian debian 
  }
}

build_live(){
    echo "Getting dlive airo from git"
    git clone http://github.com/Degeneratedlabs/Dlive-Airo/ 
    cd Dlive-Airo
    echo "Building live"
    lb build  &> $logfile
    scp *iso $remoteuser@192.168.1.3:
}

build_package(){
    echo "Downloading aircrack-ng"
    get_aircrackng &> $logfile
    echo "Building package"
    debuild -us -uc $@ >& $logfile
    echo "Uploading package"
    upload_package &> $logfile
}

upload_package(){ 
    wget --no-check-certificate https://raw.github.com/degeneratedlabs/Degeneratedlabs-Debian-Buildbot/master/.dput.cf -O ~/.dput.cf
    cd .. 
    dput repo.degeneratedlabs.net *changes
}

mkdirs
install_tools &> $logfile
build_package
build_live 
