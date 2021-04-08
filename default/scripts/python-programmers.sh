source ${PATCHES_DIR}/python3_package.sh

cp -r tinyfpgab/programmer/* tinyfpgab/.
cp -r tinyprog/programmer/* tinyprog/.

python3_package_setup
for target in *; do
    if [ $target != 'python3' ]; then
        pushd $target
        if [ $target == 'tinyprog' ]; then
            export SETUPTOOLS_SCM_PRETEND_VERSION="1.0.23"
        fi
        python3_package_install
        popd
    fi
done
python3_package_pth "programmers"
rm -rf ${OUTPUT_DIR}${INSTALL_PREFIX}/bin/tqdm
rm -rf ${OUTPUT_DIR}${INSTALL_PREFIX}/bin/jsonschema