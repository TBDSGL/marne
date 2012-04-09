public class NetSendPacket {
  public double tick;
  public double turtleID;
  public String name;
  public double data;

  public NetSendPacket (double tick, double turtleID, String name, double data) {
    this.tick = tick;
    this.turtleID = turtleID;
    this.name = name;
    this.data = data;
  }

  public String toString() {
    String str = "";
    str += tick + "\t";
    str += turtleID + "\t";
    str += name + "\t";
    str += data;

    return str;
  }
}
