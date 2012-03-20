import org.nlogo.api.*;

public class NetSendExtension extends DefaultClassManager {
  public void load(PrimitiveManager primitiveManager) {
    primitiveManager.addPrimitive(
      "send", new NetSend());
  }
}
