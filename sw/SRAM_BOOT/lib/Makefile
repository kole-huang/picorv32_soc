
include $(TOPDIR)/config.mk

LIB	= lib.a

AS_SRCS =
C_SRCS  = division.c string.c
C_SRCS += console.c
C_SRCS += printf_tiny.c
C_SRCS += heap_mm.c

AS_OBJS	= $(AS_SRCS:.S=.o)
C_OBJS	= $(C_SRCS:.c=.o)

SRCS	:= $(AS_SRCS) $(C_SRCS)
OBJS	:= $(AS_OBJS) $(C_OBJS)

all: $(LIB)

$(LIB):	.depend $(OBJS)
	$(AR) $(ARFLAGS) $@ $(OBJS)

#########################################################################

# defines .depend target
include $(TOPDIR)/rules.mk

sinclude .depend

#########################################################################
