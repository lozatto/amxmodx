#!/usr/bin/env bash
trap "exit" INT

ismac=0
iswin=0

archive_ext=tar.gz
decomp="tar zxvf"

if [ `uname` = "Darwin" ]; then
  ismac=1
elif [ `uname` != "Linux" ] && [ -n "${COMSPEC:+1}" ]; then
  iswin=1
  archive_ext=zip
  decomp=unzip
fi

if [ ! -d "amxmodx" ]; then
  git clone https://github.com/alliedmodders/amxmodx.git
fi

if [ $ismac -eq 1 ]; then
  mysqlver=mysql-5.5.28-osx10.5-x86
  mysqlurl=http://cdn.mysql.com/archives/mysql-5.5/$mysqlver.$archive_ext
elif [ $iswin -eq 1 ]; then
  mysqlver=mysql-noinstall-5.0.24a-win32
  mysqlurl=http://cdn.mysql.com/archives/mysql-5.0/$mysqlver.$archive_ext
  # The folder in the zip archive does not contain the substring "-noinstall", so strip it
  mysqlver=${mysqlver/-noinstall}
else
  mysqlver=mysql-5.6.15-linux-glibc2.5-i686
  mysqlurl=http://cdn.mysql.com/archives/mysql-5.6/$mysqlver.$archive_ext
fi

if [ ! -d "mysql-5.0" ]; then
  if [ `command -v wget` ]; then
    wget $mysqlurl -O mysql.$archive_ext
  elif [ `command -v curl` ]; then
    curl -o mysql.$archive_ext $mysqlurl
  else
    echo "Failed to locate wget or curl. Install one of these programs to download MySQL."
    exit 1
  fi
  $decomp mysql.$archive_ext
  mv $mysqlver mysql-5.0
  rm mysql.$archive_ext
fi

checkout ()
{
  if [ ! -d "$name" ]; then
    hg clone http://hg.alliedmods.net/$path
  else
    cd $name
    hg pull -u
    cd ..
  fi
}

name=metamod-am
path=metamod-am
checkout

name=hlsdk
path=hl2sdks/hlsdk
checkout

`python -c "import ambuild2"`
if [ $? -eq 1 ]; then
  name=ambuild
  path=ambuild
  checkout
  
  cd ambuild
  if [ $iswin -eq 1 ]; then
    python setup.py install
  else
    python setup.py build
    echo "About to install AMBuild - press Ctrl+C to abort, otherwise enter your password for sudo."
    sudo python setup.py install
  fi
fi