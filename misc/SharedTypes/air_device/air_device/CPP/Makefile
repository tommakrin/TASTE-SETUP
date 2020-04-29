VISUAL?=kate

all: compile-linux

clean:
	rm -rf obj

edit:
	$(VISUAL) ../../dataview/C/dataview-uniq.h \
                  ../../dataview/C/Context-air-device.h \
                  ../../dataview/C/Context-air-device.c \
                  src/air_device.h \
                  src/air_device_state.h \
                  src/air_device.cc

compile-linux:
	mkdir -p obj && cd obj && g++ -c ../src/*.cc
