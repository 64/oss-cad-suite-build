cd python3
#patch -p1 < ${PATCHES_DIR}/python38.diff
if [ ${ARCH_BASE} == 'darwin' ]; then
	patch -p1 < ${PATCHES_DIR}/python38-darwin.diff
	sed -e "s|MACOS = (HOST_PLATFORM == 'darwin')|MACOS = (HOST_PLATFORM.startswith('darwin'))|g" -i setup.py 
	autoreconf -vfi
    export CFLAGS="-I/opt/local/include"
    export LDFLAGS="-L/opt/local/lib"
    echo "ac_cv_file__dev_ptmx=no" > config.site
    echo "ac_cv_file__dev_ptc=no" >> config.site
    CONFIG_SITE=config.site ./configure --prefix=${INSTALL_PREFIX} --enable-optimizations --enable-shared --with-system-ffi --with-openssl=/opt/local --host=${CROSS_NAME} --build=`gcc -dumpmachine`  --disable-ipv6
elif [ ${ARCH} == 'windows-x64' ]; then
	patch -p1 < ${PATCHES_DIR}/python38-mingw.diff
	autoreconf -vfi
    export CFLAGS=" -fwrapv -D__USE_MINGW_ANSI_STDIO=1 -D_WIN32_WINNT=0x0601"
    export CXXFLAGS=" -fwrapv -D__USE_MINGW_ANSI_STDIO=1 -D_WIN32_WINNT=0x0601"
	./configure --prefix=${INSTALL_PREFIX} --host=${CROSS_NAME} --build=`gcc -dumpmachine`  \
		--enable-optimizations \
		--enable-shared \
		--with-nt-threads \
		--with-computed-gotos \
		--with-system-expat \
		--with-system-ffi \
		--without-c-locale-coercion \
		--enable-loadable-sqlite-extensions
    sed -e "s|windres|x86_64-w64-mingw32-windres|g" -i Makefile
	sed -e "s|#define HAVE_DECL_RTLD_LOCAL 1|#define HAVE_DECL_RTLD_LOCAL 0|g" -i pyconfig.h
	sed -e "s|#define HAVE_DECL_RTLD_GLOBAL 1|#define HAVE_DECL_RTLD_GLOBAL 0|g" -i pyconfig.h	
else
    echo "ac_cv_file__dev_ptmx=no" > config.site
    echo "ac_cv_file__dev_ptc=no" >> config.site
	CONFIG_SITE=config.site ./configure --prefix=${INSTALL_PREFIX} --host=${CROSS_NAME} --build=`gcc -dumpmachine` --disable-ipv6 --enable-shared --with-ensurepip=no --with-build-python=${BUILD_DIR}/python3-native${INSTALL_PREFIX}/bin/python3.11
fi

make DESTDIR=${OUTPUT_DIR} -j${NPROC} install

cp -R ${BUILD_DIR}/python3-native${INSTALL_PREFIX}/lib/python3.11/site-packages/*  ${OUTPUT_DIR}${INSTALL_PREFIX}/lib/python3.11/site-packages/.
cp -R ${BUILD_DIR}/python3-native${INSTALL_PREFIX}/bin/pip*  ${OUTPUT_DIR}${INSTALL_PREFIX}/bin/.

mv ${OUTPUT_DIR}${INSTALL_PREFIX}/bin ${OUTPUT_DIR}${INSTALL_PREFIX}/py3bin
if [ ${ARCH_BASE} == 'darwin' ]; then
    install_name_tool -id ${OUTPUT_DIR}${INSTALL_PREFIX}/lib/libpython3.11.dylib ${OUTPUT_DIR}${INSTALL_PREFIX}/lib/libpython3.11.dylib
    install_name_tool -change ${INSTALL_PREFIX}/lib/libpython3.11.dylib ${OUTPUT_DIR}${INSTALL_PREFIX}/lib/libpython3.11.dylib ${OUTPUT_DIR}${INSTALL_PREFIX}/py3bin/python3.11
elif [ ${ARCH} == 'windows-x64' ]; then
	cp ${OUTPUT_DIR}${INSTALL_PREFIX}/py3bin/libpython3.11.dll ${OUTPUT_DIR}${INSTALL_PREFIX}/lib/.
	cp ${OUTPUT_DIR}${INSTALL_PREFIX}/lib/python3.11/_sysconfigdata__win_.py ${OUTPUT_DIR}${INSTALL_PREFIX}/lib/python3.11/_sysconfigdata__win32_.py
fi
find ${OUTPUT_DIR}${INSTALL_PREFIX} -name "libpython*.a" | xargs rm -rf
