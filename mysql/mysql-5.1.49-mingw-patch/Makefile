PLAT= none
CC= gcc
CPP= g++

#release : -O0 -g3 -Wall -fmessage-length=0
#debug : -O2 -g -Wall -fmessage-length=0

# Note1: uncomment this line "MYCFLAGS= -O2 -g" if you want to debug.
#        In CDT, right click project explorer and "Clean Project" to rebuild this project.
MYCFLAGS= -O0 -g3

CFLAGS= $(MYCFLAGS) -Wall -fmessage-length=0 \
 -DWIN32 -D_WINDOWS -D_DEBUG -DFORCE_INIT_OF_VARS \
 -DENABLED_DEBUG_SYNC -DSAFEMALLOC -DSAFE_MUTEX -DUSE_TLS \
 -D_CRT_SECURE_NO_DEPRECATE -DWITH_CSV_STORAGE_ENGINE \
 -DWITH_HEAP_STORAGE_ENGINE -DWITH_MYISAM_STORAGE_ENGINE \
 -DWITH_MYISAMMRG_STORAGE_ENGINE -DWITH_PARTITION_STORAGE_ENGINE \
 -D_LIB -DYASSL_PREFIX -DYASSL_THREAD_SAFE -DHAVE_YASSL \
 -DCMAKE_CONFIGD -DDEFAULT_MYSQL_HOME="\"c:/Program Files/MySQL/MySQL Server 5.1/\"" \
 -DDEFAULT_BASEDIR="\"c:/Program Files/MySQL/\"" \
 -DMYSQL_DATADIR="\"c:/Program Files/MySQL/MySQL Server 5.1/data\"" \
 -DDEFAULT_CHARSET_HOME="\"c:/Program Files/MySQL/MySQL Server 5.1/\"" \
 -DPACKAGE=mysql -DSHAREDIR="\"share\"" -D__NT__ \
 -D_WIN32_WINNT=0x0501 -DCMAKE_INTDIR=\"Debug\" \
 -Dlibmysql_EXPORTS -D_WINDLL -D_MBCS \
 -DNO_OLDNAMES -DHAVE_RINT \
 -I./include -I./libmysql -I./regex -I./sql \
 -I./strings -I./zlib -I./dbug \
 -I./extra/yassl/taocrypt/mySTL \
 -I./extra/yassl/taocrypt/include \
 -I./extra/yassl/include 

CPPFLAGS = $(CFLAGS)

LIBS=
TESTCFLAGS= $(MYCFLAGS) -Wall -fmessage-length=0 \
 -I./include
TESTLIBS = ./lib/libmysql.dll.a

AR= ar rcu
RANLIB= ranlib
RM= rm -f

OBJECTS= zlib/adler32.o \
zlib/compress.o \
zlib/crc32.o \
zlib/deflate.o \
zlib/gzio.o \
zlib/infback.o \
zlib/inffast.o \
zlib/inflate.o \
zlib/inftrees.o \
zlib/trees.o \
zlib/uncompr.o \
zlib/zutil.o \
sql-common/client.o \
sql-common/my_time.o \
sql-common/pack.o \
sql/net_serv.o \
sql/password.o \
strings/bchange.o \
strings/bmove.o \
strings/bmove_upp.o \
strings/ctype-big5.o \
strings/ctype-bin.o \
strings/ctype-cp932.o \
strings/ctype-czech.o \
strings/ctype-euc_kr.o \
strings/ctype-eucjpms.o \
strings/ctype-extra.o \
strings/ctype-gb2312.o \
strings/ctype-gbk.o \
strings/ctype-latin1.o \
strings/ctype-mb.o \
strings/ctype-simple.o \
strings/ctype-sjis.o \
strings/ctype-tis620.o \
strings/ctype-uca.o \
strings/ctype-ucs2.o \
strings/ctype-ujis.o \
strings/ctype-utf8.o \
strings/ctype-win1250ch.o \
strings/ctype.o \
strings/int2str.o \
strings/is_prefix.o \
strings/my_strtoll10.o \
strings/llstr.o \
strings/longlong2str.o \
strings/my_vsnprintf.o \
strings/str2int.o \
strings/str_alloc.o \
strings/strcend.o \
strings/strcont.o \
strings/strend.o \
strings/strfill.o \
strings/strinstr.o \
strings/strmake.o \
strings/strmov.o \
strings/strnlen.o \
strings/strnmov.o \
strings/strtod.o \
strings/strtoll.o \
strings/strtoull.o \
strings/strxmov.o \
strings/strxnmov.o \
strings/xml.o \
vio/vio.o \
vio/viosocket.o \
vio/viossl.o \
vio/viosslfactories.o \
dbug/dbug.o \
dbug/factorial.o \
dbug/sanity.o \
mysys/array.o \
mysys/charset-def.o \
mysys/charset.o \
mysys/default.o \
mysys/errors.o \
mysys/hash.o \
mysys/my_sleep.o \
mysys/default_modify.o \
mysys/list.o \
mysys/mf_arr_appstr.o \
mysys/mf_cache.o \
mysys/mf_dirname.o \
mysys/mf_fn_ext.o \
mysys/mf_format.o \
mysys/mf_iocache.o \
mysys/mf_iocache2.o \
mysys/mf_loadpath.o \
mysys/mf_pack.o \
mysys/mf_path.o \
mysys/mf_tempfile.o \
mysys/mf_unixpath.o \
mysys/mf_wcomp.o \
mysys/mulalloc.o \
mysys/my_access.o \
mysys/my_alloc.o \
mysys/my_chsize.o \
mysys/my_compress.o \
mysys/my_create.o \
mysys/my_delete.o \
mysys/my_div.o \
mysys/my_error.o \
mysys/my_file.o \
mysys/my_fopen.o \
mysys/my_fstream.o \
mysys/my_gethostbyname.o \
mysys/my_getopt.o \
mysys/my_getwd.o \
mysys/my_init.o \
mysys/my_lib.o \
mysys/my_malloc.o \
mysys/my_messnc.o \
mysys/my_net.o \
mysys/my_once.o \
mysys/my_open.o \
mysys/my_pread.o \
mysys/my_pthread.o \
mysys/my_read.o \
mysys/my_realloc.o \
mysys/my_rename.o \
mysys/my_seek.o \
mysys/my_static.o \
mysys/my_symlink.o \
mysys/my_symlink2.o \
mysys/my_thr_init.o \
mysys/my_wincond.o \
mysys/my_winthread.o \
mysys/my_write.o \
mysys/safemalloc.o \
mysys/sha1.o \
mysys/string.o \
mysys/thr_mutex.o \
mysys/typelib.o \
mysys/mf_qsort.o \
mysys/my_getsystime.o \
mysys/my_sync.o \
libmysql/errmsg.o \
libmysql/get_password.o \
libmysql/dll.o \
libmysql/libmysql.o \
libmysql/manager.o \
extra/yassl/taocrypt/src/aes.o \
extra/yassl/taocrypt/src/aestables.o \
extra/yassl/taocrypt/src/algebra.o \
extra/yassl/taocrypt/src/arc4.o \
extra/yassl/taocrypt/src/asn.o \
extra/yassl/taocrypt/src/coding.o \
extra/yassl/taocrypt/src/des.o \
extra/yassl/taocrypt/src/dh.o \
extra/yassl/taocrypt/src/dsa.o \
extra/yassl/taocrypt/src/file.o \
extra/yassl/taocrypt/src/hash.o \
extra/yassl/taocrypt/src/integer.o \
extra/yassl/taocrypt/src/md2.o \
extra/yassl/taocrypt/src/md4.o \
extra/yassl/taocrypt/src/md5.o \
extra/yassl/taocrypt/src/misc.o \
extra/yassl/taocrypt/src/random.o \
extra/yassl/taocrypt/src/ripemd.o \
extra/yassl/taocrypt/src/rsa.o \
extra/yassl/taocrypt/src/sha.o \
extra/yassl/src/buffer.o \
extra/yassl/src/cert_wrapper.o \
extra/yassl/src/crypto_wrapper.o \
extra/yassl/src/handshake.o \
extra/yassl/src/handshake.o \
extra/yassl/src/lock.o \
extra/yassl/src/log.o \
extra/yassl/src/socket_wrapper.o \
extra/yassl/src/ssl.o \
extra/yassl/src/timer.o \
extra/yassl/src/yassl_error.o \
extra/yassl/src/yassl_imp.o \
extra/yassl/src/yassl_int.o \




# Note2: if you want to comment this line "MYCFLAGS= -O2 -g", 
#        please use "cleanbin" & "clean" and rebuild the project("Clean Project")
#all : cleanbin bin/zlib.dll lib/libz.a bin/example.exe clean

all : libmysql.a test.exe

libmysql.dll : $(OBJECTS)
	$(CC) -shared -o $@ $(OBJECTS) $(LIBS)
	cp -p bin/zlib.dll lib/libmysql.dll.a
	
libmysql.a : $(OBJECTS)
	$(AR) $@ $(OBJECTS)
	#strip --strip-unneeded $@

# notice -l order
test.exe : 
	gcc $(CFLAGS) -o $@ main.c -L. -lmysql -lws2_32 -lstdc++

clean : 
	rm -f $(OBJECTS)
	rm -f *.a *.dll *.exe
	
cleanbin :
	rm -f bin/libmysql.dll lib/libmysql.a lib/libmysql.dll.a
	
run : all
	bin/example.exe

