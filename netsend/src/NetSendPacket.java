public class NetSendPacket {
  public double tick;
  public String name;
  public double data;

  public NetSendPacket (double tick, String name, double data) {
    this.tick = tick;
    this.name = name;
    this.data = data;
  }

  public String toString() {
    String str = "";
    str += tick + "\t";
    str += name + "\t";
    str += data;

    return str;
  }
}
