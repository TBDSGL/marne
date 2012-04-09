import org.nlogo.api.*;
import java.util.*;

// Simple (http server)
import org.simpleframework.http.core.Container;
import org.simpleframework.transport.connect.Connection;
import org.simpleframework.transport.connect.SocketConnection;
import org.simpleframework.http.Response;
import org.simpleframework.http.Request;
import org.simpleframework.http.Form;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.io.PrintStream;
import java.io.IOException;

public class NetSend extends DefaultCommand implements Container {
  public static List<NetSendPacket> packets = null;
  static Container container;
  static Connection connection;
  static SocketAddress address;

  public NetSend() {
    super();
    if (packets == null) {
      packets = new ArrayList<NetSendPacket>();
      container = this;
      try {
      connection = new SocketConnection(container);
      address = new InetSocketAddress(8080);

      connection.connect(address);
      } catch (IOException e) {}
    }
  }
  // take one number as input, report a list
  public Syntax getSyntax() {
    return Syntax.commandSyntax(
	new int[] {Syntax.StringType(), Syntax.NumberType()});
  }
  public void perform(Argument args[], Context context)
      throws ExtensionException, LogoException {
    if (args[0].getString().equalsIgnoreCase("reset")) {
      packets = new ArrayList<NetSendPacket>();
      return;
    }

    NetSendPacket n = new NetSendPacket(context.getAgent().world().ticks(),
		    Double.valueOf(context.getAgent().id()),
		    args[0].getString(),
		    args[1].getDoubleValue());
    packets.add(n);

    /*try {
      context.getAgent().setVariable(6, args[0].getString());
    } catch (Exception e) {}*/
  }

  // Should be modified to binary search or something
  private int findIndexOfTick(double tick) {
    /*int half = packets.size() / 2;
    int i = half;

    if (packets.size() == 0) return -1;

    while ((int)packets.get(i).tick != tick) {
      if (half / 2 == 0) return -1;
      if (packets.get(half).tick < tick) {
        half /= 2;
	i += half;
      } else if (packets.get(half).tick > tick) {
        half /= 2;
	i -= half;
      }
    }

    while (i > 0 && (int)packets.get(half - 1).tick == tick) {
      i--;
    }

    if ((int)packets.get(i).tick != tick) return -1;

    return i;*/
    int index = packets.size() - 1;
    while (index > 0 && tick < packets.get(index-1).tick) {
      index--;
    }

    if (packets.get(index).tick <= tick)
      return -1;

    return index;

  }

  public void handle(Request request, Response response) {
    PrintStream body = null;
    Form form = null;
    try {
      body = response.getPrintStream();
      form = request.getForm();
    } catch (IOException e) {}
    long time = System.currentTimeMillis();
    String value = form.get("tick");
    response.set("Content-Type", "text/plain");
    response.set("Server", "NetSend/1.0 (Simple 4.0)");
    response.setDate("Date", time);
    response.setDate("Last-Modified", time);

    body.println("tick: " + value);
    int lastTickIndex = 0;
    try {
      lastTickIndex = findIndexOfTick(Double.parseDouble(value));
    } catch (Exception e) {}
    for (int i = lastTickIndex; i >= 0 && i < packets.size(); i++) {
      body.println(packets.get(i).toString());
    }
    body.close();
  }  
}
