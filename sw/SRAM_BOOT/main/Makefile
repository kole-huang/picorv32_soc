
include $(TOPDIR)/config.mk

LIB	= lib.a

AS_SRCS	=
C_SRCS	= main.c

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
