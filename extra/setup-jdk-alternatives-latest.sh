#!/bin/bash
JDK_DIR=/usr/java/latest
PRIORITY=20000

sudo alternatives --install /usr/bin/java java $JDK_DIR/bin/java $PRIORITY \
	--slave /usr/bin/jaotc jaotc $JDK_DIR/bin/jaotc \
	--slave /usr/bin/jarsigner jarsigner $JDK_DIR/bin/jarsigner \
	--slave /usr/bin/javac javac $JDK_DIR/bin/javac \
	--slave /usr/bin/javap javap $JDK_DIR/bin/javap \
	--slave /usr/bin/jconsole jconsole $JDK_DIR/bin/jconsole \
	--slave /usr/bin/jshell jshell $JDK_DIR/bin/jshell \
	--slave /usr/bin/keytool keytool $JDK_DIR/bin/keytool \
	--slave /usr/bin/jar jar $JDK_DIR/bin/jar \
	--slave /usr/bin/javadoc javadoc $JDK_DIR/bin/javadoc \
	--slave /usr/bin/jcmd jcmd $JDK_DIR/bin/jcmd \
	--slave /usr/bin/jdeps jdeps $JDK_DIR/bin/jdeps \
	--slave /usr/bin/jinfo jinfo $JDK_DIR/bin/jinfo
