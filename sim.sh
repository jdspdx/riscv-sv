#!/usr/bin/env bash
set -eo pipefail

# verilator --assert --trace --binary --build $1
OBJCACHE=ccache VM_PARALLEL_BUILDS=1 verilator -fno-inline -j 0 -CFLAGS -O0 --trace --binary --build $1
obj_dir/V$(basename -s .sv $1) +verilator+seed+$$
