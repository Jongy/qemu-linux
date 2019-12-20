# applies future patches on a linux tree to make older versions compile with
# newer GCC.

if [ $# != 1 ]; then
    echo "usage: $0 /path/to/kernel/source"
    exit 1
fi

pushd $1

major=$(grep VERSION Makefile | head -n 1 | cut -d"=" -f2 |  tr -d '[:space:]')
patchlevel=$(grep PATCHLEVEL Makefile | head -n 1 | cut -d"=" -f2 |  tr -d '[:space:]')

echo "Found kernel $major.$patchlevel"

echo "Patching..."

# 4.16
if [[ "$major" -le "3" || ("$major" -eq "4" && "$patchlevel" -le "15") ]]; then
    echo "Patching e3d03598e8ae7d195af5d3d049596dec336f569f"
    # fixes linker change from binutils > 2.31
    # doesn't hurt to apply even if using an older ld (older ld had this as default)
    git cherry-pick -n e3d03598e8ae7d195af5d3d049596dec336f569f
fi

# 4.11
if [[ "$major" -le 3 || ("$major" -eq 4 && "$patchlevel" -le 10) ]]; then
    echo "Patching 474c90156c8dcc2fa815e6716cc9394d7930cb9c"
    # warning about some log2 function
    git cherry-pick -n 474c90156c8dcc2fa815e6716cc9394d7930cb9c
fi

# 4.9
if [[ "$major" -le 3 || ("$major" -eq 4 && "$patchlevel" -le 8) ]]; then
    echo "Patching c6a385539175ebc603da53aafb7753d39089f32e"
    # new GCC defaults to use -fpie, but can't use it for kernel code.
    git cherry-pick -n c6a385539175ebc603da53aafb7753d39089f32e
fi

git reset

echo "Done patching"

popd
