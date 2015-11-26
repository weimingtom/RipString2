MYSYS_VERSION := MinGW32_NT-6.1
GCC_VERSION := gcc version 3.4.5 (mingw-vista special r3)

TARGET := mysqltest

CPP    := g++
RM     := rm -f

CPPFLAGS := -g3 -O0
LIBS     :=

# libmysql.dll (libmysql.lib under MySQL install path, donnot use -l) 
# can't static link mysqlclient.lib
#CPPFLAGS += -I"/c/Program Files (x86)/MySQL/MySQL Server 5.1/include"
#LIBS     += "/c/Program Files (x86)/MySQL/MySQL Server 5.1/lib/opt/libmysql.lib"

# DEV-C++ libmysql.lib£¬need -l
CPPFLAGS += -I/local/include/mysql
LIBS     += -L/local/lib -lmysql

all: ${TARGET}.exe

${TARGET}.exe: ${TARGET}.o	
	${CPP} ${CPPFLAGS} -o $@ $< ${LIBS} 
	
test: ${TARGET}.exe
	./${TARGET}.exe
	
clean:
	${RM} *.o *.exe
