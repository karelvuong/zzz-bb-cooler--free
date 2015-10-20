QMAKE_TARGET  = cooler_free
LUPDATE       = $(QNX_HOST)/usr/bin/lupdate
LRELEASE      = $(QNX_HOST)/usr/bin/lrelease

update: $(QMAKE_TARGET).pro FORCE
	$(LUPDATE) $(QMAKE_TARGET).pro

release: $(QMAKE_TARGET).pro $(QMAKE_TARGET).ts
	$(LRELEASE) $(QMAKE_TARGET).pro

FORCE:

