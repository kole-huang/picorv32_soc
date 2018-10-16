
include $(TOPDIR)/config.mk

LIB	= lib.a

AS_SRCS	=
C_SRCS	= hal.c irq.c uart.c

AS_OBJS	= $(AS_SRCS:.S=.o)
C_OBJS	= $(C_SRCS:.c=.o)

SRCS	:= $(AS_SRCS) $(C_SRCS)
OBJS	:= $(AS_OBJS) $(C_OBJS)

all: $(LIB) $(LDSCRIPT)

$(LIB): .depend $(C_OBJS)
	$(AR) $(ARFLAGS) $@ $(C_OBJS)

$(LDSCRIPT): $(LDSCRIPT_SRC)
	$(CC) $(LDSCRIPT_CPPFLAGS) -E -P -C -o $@ $<

#########################################################################

# defines .depend target
include $(TOPDIR)/rules.mk

sinclude .depend

#########################################################################
