#!/bin/bash
# 005-gcc-stage2.sh by Francisco Javier Trujillo Mata (fjtrujy@gmail.com)

## Exit with code 1 when any command executed returns a non-zero exit code.
onerr()
{
  exit 1;
}
trap onerr ERR

## Download the source code.
REPO_URL="https://github.com/ps2dev/gcc.git"
REPO_FOLDER="gcc"
BRANCH_NAME="ee-v11.2.0"
if test ! -d "$REPO_FOLDER"; then
  git clone --depth 1 -b "$BRANCH_NAME" "$REPO_URL"
  cd "$REPO_FOLDER"
else
  cd "$REPO_FOLDER"
  git fetch origin
  git reset --hard "origin/${BRANCH_NAME}"
  git checkout "$BRANCH_NAME"
fi

TARGET_ALIAS="ee"
TARGET="mips64r5900el-ps2-elf"
TARG_XTRA_OPTS=""
OSVER=$(uname)

if [ "${OSVER:0:10}" == MINGW64_NT ]; then
  export lt_cv_sys_max_cmd_len=8000
  export CC=x86_64-w64-mingw32-gcc
  TARG_XTRA_OPTS="--host=x86_64-w64-mingw32"
elif [ "${OSVER:0:10}" == MINGW32_NT ]; then
  export lt_cv_sys_max_cmd_len=8000
  export CC=i686-w64-mingw32-gcc
  TARG_XTRA_OPTS="--host=i686-w64-mingw32"
fi

## Determine the maximum number of processes that Make can work with.
PROC_NR=$(getconf _NPROCESSORS_ONLN)

## Create and enter the toolchain/build directory
rm -rf "build-$TARGET-stage2"
mkdir "build-$TARGET-stage2"
cd "build-$TARGET-stage2"

## Configure the build.
../configure \
  --quiet \
  --prefix="$PS2DEV/$TARGET_ALIAS" \
  --target="$TARGET" \
  --enable-languages="c,c++" \
  --with-float=hard \
  --with-headers="$PS2DEV/$TARGET_ALIAS/$TARGET/include" \
  --with-newlib \
  --disable-libssp \
  --disable-multilib \
  --enable-cxx-flags=-G0 \
  $TARG_XTRA_OPTS

## Compile and install.
make --quiet -j "$PROC_NR" all
make --quiet -j "$PROC_NR" install-strip
make --quiet -j "$PROC_NR" clean
