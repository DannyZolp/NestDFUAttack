CC = gcc
INCLUDES =
LIBS = -lusb-1.0
LDFLAGS = $(LIBS)
APP_NAME = omap3_usbload

OBJS = omap3_usbload.o

all: $(APP_NAME)

$(APP_NAME): $(OBJS)
		$(CC) $^ -o $@ $(LDFLAGS) 

clean:
		rm -r $(APP_NAME) *.o

.PHONY: all clean
