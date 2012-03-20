javac -classpath /Users/dylangarrett/Desktop/NetLogo\ 5.0/NetLogo.jar:./simple-4.1.21.jar -d classes src/NetSend.java src/NetSendExtension.java src/NetSendPacket.java
jar cvfm netsend.jar manifest.txt -C classes .
