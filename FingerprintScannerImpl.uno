using Uno;
using Uno.Collections;
using Fuse;
using Uno.Compiler.ExportTargetInterop;
using Uno.Threading;

public extern(!Android) class FingerprintScannerImpl
{
  public static void Initialize()
  {
    debug_log "Not support!";
  }

  public static void Start()
  {
    debug_log "Not support!";
  }

  public static bool IsStart()
  {
    return false;
  }

  public static Future<string> Scan()
  {
    var p = new Promise<string>();
		p.Reject(new Exception("Camera not available on current platform"));
		return p;
  }

  public static bool Match(object[] args) {
    return false;
  }

  public static void Stop() {
    debug_log "Not support!";
  }
}
