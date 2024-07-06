CC=clang++-18
CFLAGS=-Wall -g -std=c++11

.SUFFIXES: .o .cpp .h

SRC_DIRS = ./ ./benchmarks/ ./concurrency_control/ ./storage/ ./system/ ./transport/ ./utils/
INCLUDE = -I. -I./benchmarks -I./concurrency_control -I./storage -I./system -I./transport -I./utils -I../../../cxl_shmem/src/cxlalloc/include/

CFLAGS += $(INCLUDE) -D NOGRAPHITE=1 -O3 -g -ggdb -flto
LDFLAGS = -Wall -L./libs -pthread -lrt -std=c++0x -O3 -ljemalloc ./../../../cxl_shmem/build_clang_release/libcxlalloc_static.a ./../../../cxl_shmem/build_clang_release/bin/libcxl_driver_api_byte.a -lnuma

LDFLAGS += $(CFLAGS)

CPPS = $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)*.cpp))
OBJS = $(CPPS:.cpp=.o)
DEPS = $(CPPS:.cpp=.d)

all:rundb

rundb : $(OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

-include $(OBJS:%.o=%.d)

%.d: %.cpp
	$(CC) -MM -MT $*.o -MF $@ $(CFLAGS) $<

%.o: %.cpp %.d
	$(CC) -c $(CFLAGS) -o $@ $<

.PHONY: clean
clean:
	rm -f rundb *.o */*.o *.d */*.d
