# (C)2004-2008 SourceMod Development Team
# Makefile written by David "BAILOPAN" Anderson

SMSDK = ../..
SRCDS_BASE = ~/srcds
MMSOURCE17 = ../../../mmsource-central

#####################################
### EDIT BELOW FOR OTHER PROJECTS ###
#####################################

PROJECT = curl

#Uncomment for Metamod: Source enabled extension
USEMETA = false

OBJECTS = \
	sdk/smsdk_ext.cpp 	\
	extension.cpp 		\
	curlmanager.cpp		\
	curlthread.cpp 		\
	natives.cpp

##############################################
### CONFIGURE ANY OTHER FLAGS/OPTIONS HERE ###
##############################################

C_OPT_FLAGS = -DNDEBUG -O3 -pipe -fno-strict-aliasing -flto
C_DEBUG_FLAGS = -D_DEBUG -DDEBUG -g -ggdb3
C_GCC4_FLAGS = -fvisibility=hidden
CPP_GCC4_FLAGS = -fvisibility-inlines-hidden
CPP = gcc


METAMOD = $(MMSOURCE17)/core-legacy

INCLUDE += -I. -I.. -Isdk -I../ \
	-I$(METAMOD)/sourcehook -I$(SMSDK)/public -I$(SMSDK)/public/extensions \
	-I$(SMSDK)/public/sourcepawn \

CFLAGS += -DSE_EPISODEONE=1 -DSE_DARKMESSIAH=2 -DSE_ORANGEBOX=3 -DSE_ORANGEBOXVALVE=4 -DSE_LEFT4DEAD=5 -DSE_LEFT4DEAD2=6

LINK += -L/usr/lib -Wl,-Bstatic -m32 -static -lstdc++ -Wl,-Bdynamic -m32 -shared -lcurl

CFLAGS += -D_LINUX -Dstricmp=strcasecmp -D_stricmp=strcasecmp -D_strnicmp=strncasecmp -Dstrnicmp=strncasecmp \
	-D_snprintf=snprintf -D_vsnprintf=vsnprintf -D_alloca=alloca -Dstrcmpi=strcasecmp -Wall -Wno-switch \
	-Wno-unused -mfpmath=sse -msse -DSOURCEMOD_BUILD -DHAVE_STDINT_H -m32 -Wno-undef

CPPFLAGS += -Wno-non-virtual-dtor -fno-exceptions -fno-rtti -fno-threadsafe-statics

################################################
### DO NOT EDIT BELOW HERE FOR MOST PROJECTS ###
################################################

ifeq "$(DEBUG)" "true"
	BIN_DIR = Debug
	CFLAGS += $(C_DEBUG_FLAGS)
else
	BIN_DIR = Release
	CFLAGS += $(C_OPT_FLAGS)
endif

ifeq "$(USEMETA)" "true"
	BIN_DIR := $(BIN_DIR).$(ENGINE)
endif

OS := $(shell uname -s)
ifeq "$(OS)" "Darwin"
	LINK += -dynamiclib
	BINARY = $(PROJECT).ext.dylib
else
	BINARY = $(PROJECT).ext.so
endif

GCC_VERSION := $(shell $(CPP) -dumpversion >&1 | cut -b1)
ifeq "$(GCC_VERSION)" "4"
	CFLAGS += $(C_GCC4_FLAGS)
	CPPFLAGS += $(CPP_GCC4_FLAGS)
endif

OBJ_LINUX := $(OBJECTS:%.cpp=$(BIN_DIR)/%.o)

$(BIN_DIR)/%.o: %.cpp
	$(CPP) $(INCLUDE) $(CFLAGS) $(CPPFLAGS) -o $@ -c $<

all: check
	mkdir -p $(BIN_DIR)/sdk

	$(MAKE) -f Makefile extension

check:
	

extension: check $(OBJ_LINUX)
	$(CPP) $(INCLUDE) $(OBJ_LINUX) $(LINK) -o $(BIN_DIR)/$(BINARY)

debug:
	$(MAKE) -f Makefile all DEBUG=true

default: all

clean: check
	rm -rf $(BIN_DIR)/*.o
	rm -rf $(BIN_DIR)/sdk/*.o
	rm -rf $(BIN_DIR)/$(BINARY)
