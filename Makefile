PROG = zelda_roth/zelda_roth.elf
SRCS = $(wildcard src/*.cpp)
OBJS = $(SRCS:.cpp=.o)

CHAINPREFIX := /opt/mipsel-linux-uclibc
CROSS_COMPILE := $(CHAINPREFIX)/usr/bin/mipsel-linux-

CXX := $(CROSS_COMPILE)g++
STRIP := $(CROSS_COMPILE)strip
RC  := $(CROSS_COMPILE)windres

SYSROOT := $(shell $(CC) --print-sysroot)
SDL_CFLAGS := $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
SDL_LIBS := $(shell $(SYSROOT)/usr/bin/sdl-config --libs)

# CXXFLAGS = -Wall -Ofast -mno-abicalls -mplt $(SDL_CFLAGS) -DDINGUX
CXXFLAGS = -Wall -Ofast -mplt $(SDL_CFLAGS) -DDINGUX
LDFLAGS = $(SDL_LIBS) -lSDL_mixer -lSDL_image -lSDL_gfx -flto -s

$(PROG): $(OBJS)
	$(CXX) $(OBJS) $(LDFLAGS) -o $(PROG)

ipk: $(PROG)
	@rm -rf /tmp/.zelda_roth-ipk/ && mkdir -p /tmp/.zelda_roth-ipk/root/home/retrofw/games/zelda_roth /tmp/.zelda_roth-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@cp -r zelda_roth/zelda_roth.elf zelda_roth/zelda_roth.png zelda_roth/data /tmp/.zelda_roth-ipk/root/home/retrofw/games/zelda_roth
	@cp zelda_roth/zelda_roth.lnk /tmp/.zelda_roth-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" zelda_roth/control > /tmp/.zelda_roth-ipk/control
	@cp zelda_roth/conffiles /tmp/.zelda_roth-ipk/
	@tar --owner=0 --group=0 -czvf /tmp/.zelda_roth-ipk/control.tar.gz -C /tmp/.zelda_roth-ipk/ control conffiles
	@tar --owner=0 --group=0 -czvf /tmp/.zelda_roth-ipk/data.tar.gz -C /tmp/.zelda_roth-ipk/root/ .
	@echo 2.0 > /tmp/.zelda_roth-ipk/debian-binary
	@ar r zelda_roth/zelda_roth.ipk /tmp/.zelda_roth-ipk/control.tar.gz /tmp/.zelda_roth-ipk/data.tar.gz /tmp/.zelda_roth-ipk/debian-binary

clean:
	rm -f $(PROG) src/*.o

.PHONY: clean
