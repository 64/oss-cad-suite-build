cd apicula
source ${PATCHES_DIR}/python3_package.sh
cp -R ${BUILD_DIR}/numpy${INSTALL_PREFIX}/lib/python3.8/site-packages/* ${BUILD_DIR}/python3${INSTALL_PREFIX}/lib/python3.8/site-packages/.
python3_package_setup
python3_package_pip_install "crcmod"
curl -L https://github.com/YosysHQ/apicula/releases/download/0.0.0.dev/linux-x64-gowin-data.tgz > linux-x64-gowin-data.tgz
tar xvfz linux-x64-gowin-data.tgz
python3_package_install
python3_package_pth "apicula"
rm -rf ${OUTPUT_DIR}${INSTALL_PREFIX}/lib/python3.8/site-packages/bin
rm -rf ${OUTPUT_DIR}${INSTALL_PREFIX}/bin/f2py*
