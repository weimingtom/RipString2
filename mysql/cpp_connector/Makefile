MYSYS_VERSION := MinGW32_NT-6.1
GCC_VERSION := gcc version 3.4.5 (mingw-vista special r3)

TARGET := connect

CPP    := g++
RM     := rm -f

CPPFLAGS := -g3 -O0
LIBS     :=

CPPFLAGS += -I"/f/mysql-connector-c++-noinstall-1.0.5-win32/include"
LIBS     += "/f/mysql-connector-c++-noinstall-1.0.5-win32/lib/mysqlcppconn.dll"

all: ${TARGET}.exe

${TARGET}.exe: ${TARGET}.o	
	${CPP} ${CPPFLAGS} -o $@ $< ${LIBS} 
	
test: ${TARGET}.exe
	./${TARGET}.exe
	
clean:
	${RM} *.o *.exe
