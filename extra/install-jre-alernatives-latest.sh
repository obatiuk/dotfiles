#!/bin/bash
JDK_DIR=/usr/java/latest
PRIORITY=20000

sudo alternatives --install /usr/bin/java java $JDK_DIR/jre/bin/java $PRIORITY \
--slave /usr/bin/ControlPanel ControlPanel $JDK_DIR/jre/bin/ControlPanel \
--slave /usr/bin/javaws javaws $JDK_DIR/jre/bin/javaws \
--slave /usr/bin/jcontrol jcontrol $JDK_DIR/jre/bin/jcontrol \
--slave /usr/bin/jjs jjs $JDK_DIR/jre/bin/jjs \
--slave /usr/bin/keytool keytool $JDK_DIR/jre/bin/keytool \
--slave /usr/bin/orbd orbd $JDK_DIR/jre/bin/orbd \
--slave /usr/bin/pack200 pack200 $JDK_DIR/jre/bin/pack200 \
--slave /usr/bin/policytool policytool $JDK_DIR/jre/bin/policytool \
--slave /usr/bin/rmid rmid $JDK_DIR/jre/bin/rmid \
--slave /usr/bin/rmiregistry rmiregistry $JDK_DIR/jre/bin/rmiregistry \
--slave /usr/bin/servertool servertool $JDK_DIR/jre/bin/servertool \
--slave /usr/bin/tnameserv tnameserv $JDK_DIR/jre/bin/tnameserv \
--slave /usr/bin/unpack200 unpack200 $JDK_DIR/jre/bin/unpack200