#!/bin/bash
# Copyright 2012 David Francos Cuartero
# This File is licensed under the GNU General Public License version 2 or superior (GPL2+)
# Degeneratedlabs initscript
# Each time you launch the virtual machine it will recreate the debian packages and dlive

cleanup(){ (( $(ls -l|wc -l) > 3 )) && rm -rf /root/*; }
mkdirs(){ mkdir -p /root/dlabs; cd /root/dlabs; cleanup; }

get_aircrackng(){
  svn co http://trac.aircrack-ng.org/svn/trunk aircrack-ng-1.1
  cd aircrack-ng-1.1 
  rm -rf `find . -name .svn` 
  tar czvf  ../aircrack-ng_1.1.orig.tar.gz *; 
}

get_debian(){
  # Remember to edit debian/changelog each time you build a new version. 
  # Directly doing this in github editor should be good enough!
  git clone http://github.com/XayOn/Aircrack-ngDebian debian 
}

build_package(){ 
  debuild -us -uc $@
}

build_live(){
  git clone http://github.com/XayOn/Dlive-Airo/ 
  cd Dlive-Airo
  lb build 
}

upload_package(){ 
  cd .. 
  dput repo.degeneratedlabs.net *changes
}

upload_live(){
  scp *iso 192.168.1.3:
}

cleanup
get_aircrackng
get_debian
build_package
upload_package
build_live
upload_live