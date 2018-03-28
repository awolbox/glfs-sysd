#!/bin/bash

# Copyright 2018 (C) awolbox
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# This program was writtn by awolbox <awolbox@gmail.com>

BLD=/mnt/moss
IN=/src
SRC=/usr/src
PKG=/usr/pkg
BQP=/var/backup/pkgs
dev=/dev/sdb
u=zimgir
export BLD IN SRC PKG BQP

d_prep(){

	shred -zvn 1 $dev

};d_part(){
	
	parted $dev mklabel gpt
	parted $dev mkpart primary fat32 1M 512MB		# 1 - /boot
	parted $dev set 1 bios_grub on
	parted $dev mkpart primary linux-swap 512MB 33GB	# 2 - [swap]
	parted $dev mkpart primary ext4 33GB 47GB		# 3 - /
	parted $dev mkpart primary ext4 47GB 63GB		# 4 - /usr
	parted $dev mkpart primary ext4 63GB 68GB		# 5 - /opt
	parted $dev mkpart primary ext4 68GB 70GB		# 6 - /etc
	parted $dev mkpart primary ext4 70GB 75GB		# 7 - /var
	parted $dev mkpart primary ext4 75GB 130GB		# 8 - /usr/src
	parted $dev mkpart primary ext4 130GB 100%		# 9 - /home
		
};d_mkfs(){
			
	mkfs.fat -F32 ${dev}1
	mkfs.ext4 ${dev}3
	mkfs.ext4 ${dev}4
	mkfs.ext4 ${dev}5
	mkfs.ext4 ${dev}6
	mkfs.ext4 ${dev}7
	mkfs.ext4 ${dev}8
	mkfs.ext4 ${dev}9
	mkswap ${dev}2
		
};d_mnts(){
			
	mkdir $BLD
	mount -v ${dev}3 $BLD
	mkdir -pv ${BLD}/{boot,usr,opt,etc,var,home} 
	mount -v ${dev}1 $BLD/boot
	mount -v ${dev}4 $BLD/usr
	mount -v ${dev}5 $BLD/opt
	mount -v ${dev}6 $BLD/etc
	mount -v ${dev}7 $BLD/var
	mkdir -pv $BLD/usr/src
	mount -v ${dev}8 $BLD/usr/src
	mount -v ${dev}9 $BLD/home
	/usr/bin/swapon ${dev}2
		
};pkgs0(){
		
	mkdir -v ${BLD}/src
	chmod -v a+wt ${BLD}/src
	wget --input-file=./pkgs --continue --directory-prefix=${BLD}/src &&
	cp ./md5sums ${BLD}/src
	pushd ${BLD}/src
	md5sum -c md5sums
	popd
	
};pkgs1(){
		
	mkdir -v ${BLD}/src
	chmod -v a+wt ${BLD}/src
	cp -v ../src/* ${BLD}/src
	
};t_usr(){
		
	mkdir ${BLD}/tbx
	ln -sv ${BLD}/tbx /
	groupadd $u
	useradd -s /bin/bash -g $u -m -k /dev/null $u
	chown -R $u:$u $BLD/src && \
	chown -R $u:$u $BLD/tbx

};t_usr_env(){
			
	p=/home/$u/.bash_profile
	rc=/home/$u/.bashrc
	touch $p $rc && 
		chown $u:$u $p $rc
	echo "
	;exec env -i HOME=\$HOME TERM=\$TERM /bin/bash
	" \
	       | cut -d ";" -f 2 > $p
	
	echo "
	;set +h
	;umask 022
	;BLD=$BLD
	;LC_ALL=C
	;BLD_TGT=$(uname -m)-moss-linux-gnu
	;PATH=/tbx/bin:/bin:/usr/bin
	;export BLD LC BLD_TGT PATH
	"\
	       | cut -d ";" -f 2 > $rc
	
	chown $u:$u /home/$u/bld.sh
	cp -v ./build.sh /home/$u/bld.sh
	z(){
		y=/home/$u/bld.sh
		sed -i 's/$x/#${x}/' $y
	}
	x='d_prep';z
	x='d_part';z
	x='d_mkfs';z	
	x='d_mnts';z
	x='pkgs0';z
	x='pkgs1';z
	x='t_usr';z
	x='t_usr_env';z
	x='b_tbx';z
	x='b_vkfs';z
	x='b_sys';z
	x='s_main';z
	x='s_passwd';z
	x='s_group';z
	x='s_log';z
	x='s_t';z
	x='s_linux_api';z
	x='s_man';z
	x='s_glibc';z
	x='a_tbx';z
	
};b_tbx(){ 

	su $u -c source /home/$u/.bash_profile && 
		source /home/$u/.bashrc && 
		/home/$u/bld.sh &&
	userdel -r "$u"

};b_vkfs(){
		
	mkdir -pv $BLD/{dev,proc,sys,run}
	mknod -m 600 $BLD/dev/console c 5 1
	mknod -m 666 $BLD/dev/null c 1 3
	mount -v --bind /dev $BLD/dev
	mount -vt devpts devpts $BLD/dev/pts -o gid=5,mode=620
	mount -vt proc proc $BLD/proc
	mount -vt sysfs sysfs $BLD/sys
	mount -vt tmpfs tmpfs $BLD/run
	if [ -h $BLD/dev/shm ]; then
 		mkdir -pv $BLD/$(readlink $BLD/dev/shm)
	fi
	
};b_sys(){

	cp -v ./build.sh $BLD/bld.sh
	z(){
		y=/home/$u/bld.sh
		sed -i 's/$x/#${x}/' $y
	}
	x='d_prep';z
	x='d_part';z
	x='d_mkfs';z	
	x='d_mnts';z
	x='pkgs0';z
	x='pkgs1';z
	x='t_usr';z
	x='t_usr_env';z
	x='b_tbx';z
	x='b_vkfs';z
	x='b_sys';z
	x='t_binutils_p1';z
	x='t_gcc_p1';z
	x='t_linux_api_h';z
	x='t_glibc';z
	x='t_tst1';z
	x='t_libstdc';z
	x='t_binutils_p2';z
	x='t_gcc_p2';z
	x='t_tst2';z
	x='t_tcl';z
	x='t_expect';z
	x='t_dejagnu';z
	x='t_m4';z
	x='t_ncurses';z
	x='t_bash';z
	x='t_bison';z
	x='t_bzip2';z
	x='t_coreutils';z
	x='t_diffutils';z
	x='t_file';z
	x='t_findutils';z
	x='t_gawk';z
	x='t_gettext';z
	x='t_grep';z
	x='t_gzip';z
	x='t_make';z
	x='t_patch';z
	x='t_perl';z
	x='t_sed';z
	x='t_tar';z
	x='t_texinfo';z
	x='t_util_linux';z
	x='t_xz';z
	x='t_ccc';z
	chroot "$BLD" /tbx/bin/env -i	\
		HOME=/root		\
    		TERM="$TERM"		\
		PS1='\$ '		\
    		PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tbx/bin \
		/tbx/bin/bash --login +h
		#/tbx/bin/bash +h /bld.sh
	exit 0

};t_binutils_p1(){
	
	pkg='binutils'
	ver='2.30'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	mkdir 0-bld
	cd 0-bld
	../configure --prefix=/tbx       \
		--with-sysroot=$BLD      \
		--with-lib-path=/tbx/lib \
		--target=$BLD_TGT        \
		--disable-nls            \
		--disable-werror
	make &&
		case $(uname -m) in
			x86_64) mkdir -v /tbx/lib && ln -sv /tbx/lib /tbx/lib64 ;;
		esac
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_gcc_p1(){
	
	pkg0='gcc'
	ver='7.3.0'
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	
	pkg='mpfr'
	ver='4.0.1'
	tar -xvf ../${pkg}-${ver}.tar.xz
	mv -v ${pkg}-${ver} ${pkg}
	
	pkg='gmp'
	ver='6.1.2'
	tar -xvf ../${pkg}-${ver}.tar.xz
	mv -v ${pkg}-${ver} ${pkg}
	
	pkg='mpc'
	ver='1.1.0'
	tar -xzvf ../${pkg}-${src}.tar.gz
	mv -v ${pkg}-${ver} ${pkg}
	
	for file in gcc/config/{linux,i386/linux{,64}}.h
	do
		cp -uv $file{,.orig}
		sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tbx&@g' \
			-e 's@/usr@/tbx@g' $file.orig > $file
		echo '
		;#undef STANDARD_STARTFILE_PREFIX_1
		;#undef STANDARD_STARTFILE_PREFIX_2
		;#define STANDARD_STARTFILE_PREFIX_1 "/tbx/lib/"
		;#define STANDARD_STARTFILE_PREFIX_2 ""' \
			| cut -d ";" -f 2 >> $file
		touch $file.orig
	done
	case $(uname -m) in
		x86_64)
			sed -e '/m64=/s/lib64/lib/' \
			-i.orig gcc/config/i386/t-linux64
	;;
	esac
	mkdir 0-bld
	cd 0-bld
	../configure --target=$BLD_TGT			          \
		     --prefix=/tbx				  \
		     --with-glibc-version=2.11                    \
		     --with-sysroot=$BLD                          \
		     --with-newlib                                \
		     --without-headers                            \
		     --with-local-prefix=/tbx			  \
		     --with-native-system-header-dir=/tbx/include \
		     --disable-nls                                \
		     --disable-shared                             \
		     --disable-multilib                           \
		     --disable-decimal-float                      \
		     --disable-threads                            \
		     --disable-libatomic                          \
		     --disable-libgomp                            \
		     --disable-libmpx                             \
		     --disable-libquadmath                        \
		     --disable-libssp                             \
		     --disable-libvtv                             \
		     --disable-libstdcxx                          \
		     --enable-languages=c,c++
	make &&
		make install
		cd $BLD/src && rm -rf ${pkg0}-${ver}

};t_linux_api_h(){
	
	pkg='linux'		# api
	ver='4.15.9'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	make mrproper
	make INSTALL_HDR_PATH=dest headers_install
	cp -rv dest/include/* /tbx/include
	cd $BLD/src && rm -rf ${pkg}-${ver}

};t_glibc(){
	
	pkg='glibc'
	ver='2.27'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	mkdir 0-bld
	cd 0-bld
	../configure                               \
		--prefix=/tbx			   \
		--host=$BLD_TGT                    \
		--build=$(../scripts/config.guess) \
		--enable-kernel=3.2                \
		--with-headers=/tbx/include	   \
		libc_cv_forced_unwind=yes          \
		libc_cv_c_cleanup=yes
	make && 
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_tst1(){
	
	tst() {
		echo 'int main(){}' > dummy.c
		$BLD_TGT-gcc dummy.c
		readelf -l a.out | grep ": /tbx"
	}; answr() {
		tst | \
			cut -d ":" -f 2 | \
			cut -d " " -f 2 | \
			cut -d "]" -f 1
	}; answr &&
		if [[ `answr` == "/tbx/lib64/ld-linux-x86-64.so.2" ]]; 
		then
			echo "PASS"
			rm -v a.out dummy.c
		else
			echo "TOOLCHAIN IS NOT SANE"
			rm -v a.out dummy.c
			exit 1
		fi

};t_libstdc(){
	
	pkg='gcc'
	ver='7.3.0'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	mkdir 0-bld
	cd 0-bld
	../libstdc++-v3/configure           	\
		--host=$BLD_TGT                 \
		--prefix=/tbx			\
		--disable-multilib              \
		--disable-nls                   \
		--disable-libstdcxx-threads     \
		--disable-libstdcxx-pch         \
		--with-gxx-include-dir=/tbx/$BLD_TGT/include/c++/7.3.0
	make &&
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_binutils_p2(){
	
	pkg='binutils'
	ver=-'2.30'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	mkdir 0-bld
	cd 0-bld
	CC=$BLD_TGT-gcc			 \
	AR=$BLD_TGT-ar			 \
	RANLIB=$BLD_TGT-ranlib		 \
	../configure			 \
		--prefix=/tbx            \
		--disable-nls            \
		--disable-werror         \
		--with-lib-path=/tbx/lib \
		--with-sysroot
	make &&
		make install
		make -C ld clean
		make -C ld LIB_PATH=/usr/lib:/lib
		cp -v ld/ld-new /tbx/bin
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_gcc_p2(){
	
	pkg0='gcc'
	ver='7.3.0'
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	
	pkg='mpfr'
	ver='4.0.1'
	tar -xvf ../${pkg}-${ver}.tar.xz
	mv -v ${pkg}-${ver} ${pkg}
	
	pkg='gmp'
	ver='6.1.2'
	tar -xvf ../${pkg}-${ver}.tar.xz
	mv -v ${pkg}-${ver} ${pkg}
	
	pkg='mpc'
	ver='1.1.0'
	tar -xzvf ../${pkg}-${src}.tar.gz
	mv -v ${pkg}-${ver} ${pkg}

	cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
		`dirname $($BLD_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h
	for file in gcc/config/{linux,i386/linux{,64}}.h
	do
		cp -uv $file{,.orig}
		sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tbx&@g' \
			-e 's@/usr@/tbx@g' $file.orig > $file
		echo '
		#undef STANDARD_STARTFILE_PREFIX_1
		#undef STANDARD_STARTFILE_PREFIX_2
		#define STANDARD_STARTFILE_PREFIX_1 "/tbx/lib/"
		#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
		touch $file.orig
	done
	case $(uname -m) in
		x86_64)
			sed -e '/m64=/s/lib64/lib/' \
				-i.orig gcc/config/i386/t-linux64
			;;
	esac
	mkdir 0-bld
	cd 0-bld
	CC=$BLD_TGT-gcc                                      \
	CXX=$BLD_TGT-g++                                     \
	AR=$BLD_TGT-ar                                       \
	RANLIB=$BLD_TGT-ranlib                               \
	../configure                                         \
		--prefix=/tbx				     \
		--with-local-prefix=/tbx		     \
		--with-native-system-header-dir=/tbx/include \
		--enable-languages=c,c++                     \
		--disable-libstdcxx-pch                      \
		--disable-multilib                           \
		--disable-bootstrap                          \
		--disable-libgomp
	make && 
		make install
		ln -sv /tbx/bin/gcc /tbx/bin/cc
		cd $BLD/src && rm -rf ${pkg0}-${ver}

};t_tst2(){
	
	tst() {
		echo 'int main(){}' > dummy.c
		cc dummy.c
		readelf -l a.out | grep ': /tbx'
	}; answr() {
		tst | \
			cut -d ":" -f 2 | \
			cut -d " " -f 2 | \
			cut -d "]" -f 1
	}; answr &&
		if [[ `answr` == "/tbx/lib64/ld-linux-x86-64.so.2" ]]; 
		then
			echo "PASS"
			rm -v a.out dummy.c
		else
			echo "TOOLCHAIN IS NOT SANE"
			exit 1
		fi

};t_tcl(){
	
	pkg='tcl'
	ver='8.6.8'
	
	cd $BLD/src
	tar -xzvf ${pkg}${ver}-src.tar.gz
	cd `echo ${ver} | cut -d '.' -f 1,2`/unix
	./configure --prefix=/tbx
	make && 
		#TZ=UTC make test &&
		make install &&
			chmod -v u+w /tbx/lib/libtcl8.6.so
		make install-private-headers &&
			ln -sv /tbx/bin/tclsh8.6 /tbx/bin/tclsh
			cd $BLD/src && rm -rf $pkg

};t_expect(){
	
	pkg='expect'
	ver='5.45.4'
	
	cd $BLD/src
	tar -xzvf ${pkg}${ver}.tar.gz
	cd ${pkg}${ver}
	cp -v configure{,.orig}
	sed 's:/usr/local/bin:/bin:' configure.orig > configure
	./configure --prefix=/tbx       \
		    --with-tcl=/tbx/lib \
		    --with-tclinclude=/tbx/include
	make &&
		#make test
		make SCRIPTS="" install
		cd $BLD/src && rm -rf ${pkg}${ver}

};t_dejagnu(){
	
	pkg='dejagnu'
	ver='1.6.1'
	
	cd $BLD/src
	tar -xzvf ${pkg}-${ver}.tar.gz
	cd ${pkg}-${ver}
	./configure --prefix=/tbx
	make &&
		make install
		#make check
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_m4(){
	
	pkg='m4'
	ver='1.4.18'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	./configure --prefix=/tbx
	make &&
		#make check
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_ncurses(){
	
	pkg='ncurses'
	ver='6.1'
	
	cd $BLD/src
	tar -xzvf ${pkg}-${ver}.tar.gz
	cd ${pkg}-${ver}
	sed -i s/mawk// configure
	./configure --prefix=/tbx   \
		    --with-shared   \
		    --without-debug \
		    --without-ada   \
		    --enable-widec  \
		    --enable-overwrite
	make &&
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_bash(){
	
	pkg='bash'
	ver='4.4.18'
	
	cd $BLD/src
	tar -xzvf ${pkg}-${ver}.tar.gz
	cd ${pkg}-${ver}
	./configure --prefix=/tbx --without-bash-malloc
	make &&
		make install &&
		ln -sfv /tbx/bin/bash /tbx/bin/sh
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_bison(){
	
	pkg='bison'
	ver='3.0.4'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.gz
	cd ${pkg}-${ver}
	./configure --prefix=/tbx
	make &&
		#make check
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_bzip2(){
	
	pkg='bzip2'
	ver='1.0.6'
	
	cd $BLD/src
	tar -xzvf ${pkg}-${ver}.tar.gz
	cd ${pkg}-${ver}
	make &&
		make PREFIX=/tbx install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_coreutils(){
	
	pkg='coreutils'
	ver='8.29'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	./configure --prefix=/tbx --enable-install-program=hostname
	make &&
		#make RUN_EXPENSIVE_TESTS=yes check
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_diffutils(){
	
	pkg='diffutils'
	ver='3.6'

	cd $BLD/src	
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${src}
	./configure --prefix=/tbx
	make &&
		#make check
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_file(){
	
	pkg='file'
	ver='5.32'
	
	cd $BLD/src
	tar -xzvf ${pkg}-${ver}.tar.gz
	cd ${pkg}-${ver}
	./configure --prefix=/tbx
	make &&
		#make check
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_findutils(){
	
	pkg='findutils'
	ver='4.6.0'
	
	cd $BLD/src
	tar -xzvf ${pkg}-${ver}.tar.gz
	cd ${pkg}-${ver}
	./configure --prefix=/tbx
	make &&
		#make check
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_gawk(){
	
	pkg='gawk'
	ver='4.2.1'
	
	cd $BLD/src
	tar -xzvf ${pkg}-${ver}.tar.gz
	cd ${pkg}-${ver}
	./configure --prefix=/tbx
	make &&
		#make check
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_gettext(){
	
	pkg='gettext'
	ver='0.19.8.1'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}/${pkg}-tools
	EMACS="no" ./configure --prefix=/tbx \
		               --disable-shared
	make -C gnulib-lib
	make -C intl pluralx.c
	make -C src msgfmt
	make -C src msgmerge
	make -C src xgettext
		cp -v $BLD/src/${pkg}-${ver}/src/{msgfmt,msgmerge,xgettext} /tbx/bin
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_grep(){
	
	pkg='grep'
	ver='3.1'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	./configure --prefix=/tbx
	make &&
		make check
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_gzip(){
	
	pkg='gzip'
	ver='1.9'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	./configure --prefix=/tbx
	make &&
		#make check
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_make(){
	
	pkg='make'
	ver='4.2.1'
	
	cd $BLD/src
	tar -xjvf ${pkg}-${ver}.tar.bz2
	cd ${pkg}-${ver}
	sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c &&
		./configure --prefix=/tbx --without-guile
	make &&
		#make check
       		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_patch(){
	
	pkg='patch'
	ver='2.7.6'

	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	./configure --prefix=/tbx
	make &&
		#make check
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_perl(){
	
	pkg='perl'
	ver='5.26.1'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	sh Configure -des -Dprefix=/tbx -Dlibs=-lm
	make &&
		cp -v perl cpan/podlators/scripts/pod2man /tbx/bin
		mkdir -pv /tbx/lib/perl5/${ver}
		cp -Rv lib/* /tbx/lib/perl5/${ver}
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_sed(){
	
	pkg='sed'
	ver='4.4'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	./configure --prefix=/tbx
	make &&
		#make check
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_tar(){
	
	pkg='tar'
	ver='1.30'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	./configure --prefix=/tbx
	make &&
		#make check
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_texinfo(){
	
	pkg='texinfo'
	ver='6.5'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	./configure --prefix=/tbx
	make &&
		#make check
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_util_linux(){
	
	pkg='util-linux'
	ver='2.31.1'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd $ac9
	./configure --prefix=/tbx                  \
		    --without-python               \
		    --disable-makeinstall-chown    \
		    --without-systemdsystemunitdir \
		    --without-ncurses              \
		    PKG_CONFIG=""
	make &&
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_xz(){
	
	pkg='xz'
	ver='5.2.3'
	
	cd $BLD/src
	tar -xvf ${pkg}-${ver}.tar.xz
	cd ${pkg}-${ver}
	./configure --prefix=/tbx
	make &&
		#make check
		make install
		cd $BLD/src && rm -rf ${pkg}-${ver}

};t_ccc(){
	
	strip --strip-debug /tbx/lib/*
	strip --strip-unneeded /tbx/{,s}bin/*
	#rm -rf /tbx/{,share}/{info,man,doc}
	#find /tbx/{lib,libexec} -name \*.la -delete

};s_main(){
	
	mkdir -pv /{etc/{opt,sysconfig},mnt,srv}
	install -dv -m 0750 /root
	install -dv -m 1777 /tmp /var/tmp
	mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src,man}
	mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale}
	mkdir -v  /usr/{,local/}share/{misc,terminfo,zoneinfo}
	mkdir -v  /usr/{libexec,lib/firmware}
	#mkdir -pv /usr/{,local/}share/man/man{1..8}
	case $(uname -m) in
 		x86_64) ln -sv /usr/lib /lib64 ;;
	esac
	mkdir -v /var/{log,mail,spool}
	ln -sv /run /var/run
	ln -sv /run/lock /var/lock
	mkdir -pv /var/{backup/pkgs,opt,cache,lib/{color,misc,locate},local}	

	ln -sv /usr/bin / 
	ln -sv /usr/bin /sbin
	ln -sv /usr/lib /lib
	ln -sv /tbx/bin/{bash,cat,dd,echo,ln,pwd,rm,stty} /bin
	ln -sv /tbx/bin/{env,install,perl} /usr/bin
	ln -sv /tbx/lib/libgcc_s.so{,.1} /usr/lib
	ln -sv /tbx/lib/libstdc++.{a,so{,.6}} /usr/lib
	for lib in blkid lzma mount uuid
	do
    		ln -sv /tbx/lib/lib$lib.so* /usr/lib
	done
	ln -svf /tbx/include/blkid    /usr/include
	ln -svf /tbx/include/libmount /usr/include
	ln -svf /tbx/include/uuid     /usr/include
	install -vdm755 /usr/lib/pkgconfig
	for pc in blkid mount uuid
	do
    		sed 's@tbx@usr@g' /tbx/lib/pkgconfig/${pc}.pc \
        		> /usr/lib/pkgconfig/${pc}.pc
	done
	ln -sv bash /bin/sh

};s_passwd(){

	echo "
	;root:x:0:0:root:/root:/bin/bash
	;bin:x:1:1:bin:/dev/null:/bin/false
	;daemon:x:6:6:Daemon User:/dev/null:/bin/false
	;messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
	;systemd-bus-proxy:x:72:72:systemd Bus Proxy:/:/bin/false
	;systemd-journal-gateway:x:73:73:systemd Journal Gateway:/:/bin/false
	;systemd-journal-remote:x:74:74:systemd Journal Remote:/:/bin/false
	;systemd-journal-upload:x:75:75:systemd Journal Upload:/:/bin/false
	;systemd-network:x:76:76:systemd Network Management:/:/bin/false
	;systemd-resolve:x:77:77:systemd Resolver:/:/bin/false
	;systemd-timesync:x:78:78:systemd Time Synchronization:/:/bin/false
	;systemd-coredump:x:79:79:systemd Core Dumper:/:/bin/false
	;nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
	" \
		| cut -d ";" -f 2 >> /etc/passwd

};s_group(){
	
	echo "
	;root:x:0:
	;bin:x:1:daemon
	;sys:x:2:
	;kmem:x:3:
	;tape:x:4:
	;tty:x:5:
	;daemon:x:6:
	;floppy:x:7:
	;disk:x:8:
	;lp:x:9:
	;dialout:x:10:
	;audio:x:11:
	;video:x:12:
	;utmp:x:13:
	;usb:x:14:
	;cdrom:x:15:
	;adm:x:16:
	;messagebus:x:18:
	;systemd-journal:x:23:
	;input:x:24:
	;mail:x:34:
	;kvm:x:61:
	;systemd-bus-proxy:x:72:
	;systemd-journal-gateway:x:73:
	;systemd-journal-remote:x:74:
	;systemd-journal-upload:x:75:
	;systemd-network:x:76:
	;systemd-resolve:x:77:
	;systemd-timesync:x:78:
	;systemd-coredump:x:79:
	;nogroup:x:99:
	;users:x:999:
	" \
		| cut -d ";" -f 2 >> /etc/group

};s_log(){
		
	touch /var/log/{btmp,lastlog,faillog,wtmp}
	chgrp -v utmp /var/log/lastlog
	chmod -v 664  /var/log/lastlog
	chmod -v 600  /var/log/btmp
	
};s_linux_api(){
		
	pkg='linux'
	ver='4.15.3'
	
	tar -xvf $IN/${pkg}-${ver}.tar.xz -C $SRC
	cd $SRC/${pkg}-${ver}
	make mrproper &&
		make INSTALL_HDR_PATH=dest headers_install
		find dest/include \( -name .install -o -name ..install.cmd \) -delete
		mkdir -pv $PKG/${pkg}-api-headers-${ver}
		cp -rv dest/include/* $PKG/${pkg}-api-headers-${ver}
		tar -czvf $BQP/${pkg}-api-headers-${ver}.tgz $PKG/${pkg}-api-headers-${ver}
		cp -rv $PKG/${pkg}-api-headers-${ver}/* /usr/include
	
};s_man(){

	pkg='man-pages'
	ver='4.15'
	
	tar -xvf $IN/${pkg}-${ver}.tar.xz -C $SRC
	cd $SRC/${pkg}-${ver}
	FAKEROOT=$PKG/$pkg/$ver
	mkdir $FAKEROOT
	make install prefix=$FAKEROOT
	tar -czvf $BQP/${pkg}-${ver}.tgz $FAKEROOT
	tar -xzf $BQP/${pkg}-${ver}.tgz -C /usr/local 
	ln -sv /usr/local/share/man/* /usr/share/man

};s_glibc(){
	
	pkg='glibc'
	ver='2.27'
	ptch='${pkg}-${ver}-fhs-1.patch'
	
	tar -xvf $IN/${pkg}-${ver}.tar.xz -C $SRC
	mv $IN/$ptch $SRC
	cd $SRC/${pkg}-${ver}
	patch -Np1 -i ../$ptch
	ln -svf /tbx/lib/gcc /usr/lib
	case $(uname -m) in
		i?86)   GCC_INCDIR=/usr/lib/gcc/$(uname -m)-pc-linux-gnu/7.3.0/include
			ln -sfv ld-linux.so.2 /lib/ld-lsb.so.3
		;;
  		x86_64) GCC_INCDIR=/usr/lib/gcc/x86_64-pc-linux-gnu/7.3.0/include
          		ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64
           		ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
    		;;
		esac
		
	mkdir 0-bld
	cd 0-bld
	CC="gcc -isystem $GCC_INCDIR -isystem /usr/include" \
	../configure --prefix=/usr                          \
            	     --disable-werror                       \
		     --enable-kernel=3.2                    \
		     --enable-stack-protector=strong        \
		     libc_cv_slibdir=/lib
		
	unset GCC_INCDIR
	make check
	touch /etc/ld.so.conf
	sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
	
	FAKEROOT=$PKG/$pkg/$ver
	mkdir -pv $FAKEROOT
	make install #prefix=$FAKEROOT
		
	cd $FAKEROOT/0-bld
	cp -v ../nscd/nscd.conf /etc/nscd.conf
	mkdir -pv /var/cache/nscd
	install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
	install -v -Dm644 ../nscd/nscd.service /lib/systemd/system/nscd.service
	mkdir -pv /usr/lib/locale
	localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
	localedef -i de_DE -f ISO-8859-1 de_DE
	localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
	localedef -i de_DE -f UTF-8 de_DE.UTF-8
	localedef -i en_GB -f UTF-8 en_GB.UTF-8
	localedef -i en_HK -f ISO-8859-1 en_HK
	localedef -i en_PH -f ISO-8859-1 en_PH
	localedef -i en_US -f ISO-8859-1 en_US
	localedef -i en_US -f UTF-8 en_US.UTF-8
	localedef -i es_MX -f ISO-8859-1 es_MX
	localedef -i fa_IR -f UTF-8 fa_IR
	localedef -i fr_FR -f ISO-8859-1 fr_FR
	localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
	localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
	localedef -i it_IT -f ISO-8859-1 it_IT
	localedef -i it_IT -f UTF-8 it_IT.UTF-8
	localedef -i ja_JP -f EUC-JP ja_JP
	localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
	localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
	localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
	localedef -i zh_CN -f GB18030 zh_CN.GB18030
		
	echo "
	;# Begin /etc/nsswitch.conf
	;
	;passwd: files
	;group: files
	;shadow: files
	;
	;hosts: files dns
	;networks: files
	;
	;protocols: files
	;services: files
	;ethers: files
	;rpc: files
	;
	;# End /etc/nsswitch.conf
	" \
		| cut -d ";" -f 2 >> /etc/nsswitch.conf
		
	tar -xf ../../tzdata2018c.tar.gz
	ZONEINFO=/usr/share/zoneinfo
	mkdir -pv $ZONEINFO/{posix,right}
	for tz in etcetera southamerica northamerica europe africa antarctica  \
         asia australasia backward pacificnew systemv; do
    	zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    	zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    	zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
	done
	cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
	zic -d $ZONEINFO -p America/New_York
	unset ZONEINFO
	ln -sfv /usr/share/zoneinfo/America/New_York /etc/localtime
	echo " Begin /etc/ld.so.conf\n/usr/local/lib\n/opt/lib"\
		>>/etc/ld.so.conf
	echo "# Add an include directory\ninclude /etc/ld.so.conf.d/*.conf"\
		>> /etc/ld.so.conf
	mkdir -pv /etc/ld.so.conf.d

};a_tbx(){ 
	
	mv -v /tbx/bin/{ld,ld-old}
	mv -v /tbx/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}
	mv -v /tbx/bin/{ld-new,ld}
	ln -sv /tbx/bin/ld /tbx/$(uname -m)-pc-linux-gnu/bin/ld
	gcc -dumpspecs | sed -e 's@/tbx@@g'                 	    \
		-e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
		-e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
		`dirname $(gcc --print-libgcc-file-name)`/specs

	tst0() {
		echo 'int main(){}' > dummy.c
		cc dummy.c -v -Wl,--verbose &> dummy.log
		readelf -l a.out | grep ': /lib'
	}; ansr () {
		tst0 | \
			cut -d ":" -f 2 | \
			cut -d " " -f 2 | \
			cut -d "]" -f 1
	};ansr &&
		if [[ `ansr` == "/lib64/ld-linux-x86-64.so.2" ]]
		then
			echo "PASS"
		else
			echo "TOOLCHAIN IS NOT SANE"
			exit 1
		fi
		
	grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
	grep -B1 '^ /usr/include' dummy.log

};build(){

	d_prep
	d_part
	d_mkfs
	d_mnts
#	pkgs0
	pkgs1
	t_usr
	t_usr_env
	b_tbx
	b_vkfs
	b_sys
	t_binutils_p1
	t_gcc_p1 
	t_linux_api_h
	t_glibc
	t_tst1
	t_libstdc
	t_binutils_p2
	t_gcc_p2
	t_tst2
	t_tcl
	t_expect
	t_dejagnu
	t_m4
	t_ncurses
	t_bash
	t_bison	
	t_bzip2
	t_coreutils
	t_diffutils
	t_file
	t_findutils
	t_gawk
	t_gettext
	t_grep
	t_gzip
	t_make
	t_patch
	t_perl
	t_sed
	t_tar
	t_texinfo
	t_util_linux
	t_xz
	t_ccc
	s_main
	s_passwd
	s_group
	s_log
	s_t
	s_linux_api
	s_man
#	s_glibc
#	a_tbx

}; if test $# -eq 0;
then
	build
fi
