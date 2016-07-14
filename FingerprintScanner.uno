using Uno;
using Uno.Collections;
using Fuse.Scripting;
using Fuse.Reactive;
using Fuse;
using Uno.Threading;

public class FingerprintScanner : NativeModule
{
  public FingerprintScanner()
  {
    AddMember(new NativeFunction("start", (NativeCallback)Start));
    AddMember(new NativeFunction("stop", (NativeCallback)Stop));
    AddMember(new NativePromise<string, Fuse.Scripting.Object>("scan", Scan, ScanConverter));
    AddMember(new NativeFunction("match", (NativeCallback)Match));
    AddMember(new NativeFunction("isStart", (NativeCallback)IsStart));
    AddMember(new NativeFunction("restart", (NativeCallback)Restart));

    FingerprintScannerImpl.Initialize();
  }

  static object Start(Context context, object[] args)
  {
    FingerprintScannerImpl.Start();
    return null;
  }

  static object Stop(Context context, object[] args)
  {
    FingerprintScannerImpl.Stop();
    return null;
  }

  static object Restart(Context context, object[] args)
  {
    FingerprintScannerImpl.Stop();
    FingerprintScannerImpl.Start();
    return null;
  }

  static Future<string> Scan(object[] args)
  {
    return FingerprintScannerImpl.Scan();
  }

  static Fuse.Scripting.Object ScanConverter(Context context, string data)
  {
    var wrapperObject = context.NewObject();
    wrapperObject["data"] = data;
    return wrapperObject;
  }

  static object Match(Context context, object[] args)
  {
    return FingerprintScannerImpl.Match(args);
  }

  static object IsStart(Context context, object[] args)
  {
    return FingerprintScannerImpl.IsStart();
  }
}
