CC=gcc
CFLAGS=-framework ApplicationServices -framework Carbon
SOURCES=heliumd.c
EXECUTABLE=heliumd
PLIST=heliumd.plist
INSTALLDIR=/usr/local/bin
PLISTDIR=/Library/LaunchDaemons
PLISTFULL=$(PLISTDIR)/$(PLIST)

dev: all
	./heliumd	

all: $(SOURCES)
	$(CC) $(SOURCES) $(CFLAGS) -o $(EXECUTABLE)

install: all
	mkdir -p $(INSTALLDIR)
	cp $(EXECUTABLE) $(INSTALLDIR)

uninstall:
	launchctl unload $(PLISTFULL)
	rm $(INSTALLDIR)/$(EXECUTABLE)
	rm -f $(PLISTFULL)

startup: install
	cp $(PLIST) $(PLISTFULL)
	launchctl load -w $(PLISTFULL)

load:
	launchctl load $(PLISTFULL)

unload:
	launchctl unload $(PLISTFULL)

clean:
	rm $(EXECUTABLE)
