BINARY_NAME=sketchybar_events
FRAMEWORKS= -framework Foundation -framework Cocoa -framework Network -framework CoreBluetooth
BRIDGING_HEADER= -import-objc-header sketchybar.h

bin/$(BINARY_NAME): events.swift | bin
	swiftc $(BRIDGING_HEADER) $< $(FRAMEWORKS) -o $@

bin:
	mkdir -p bin

clean:
	rm -rf bin

.PHONY: clean

