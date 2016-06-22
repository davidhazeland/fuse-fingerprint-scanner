using Uno;
using Uno.Collections;
using Fuse.Scripting;
using Fuse.Reactive;
using Fuse;
using Uno.Compiler.ExportTargetInterop;
using Uno.Threading;

public class FingerprintScanner : NativeModule
{
  public FingerprintScanner()
  {
    AddMember(new NativePromise<sbyte, Fuse.Scripting.Object>("scan", Scan, ScanConverter));
  }

  static Future<sbyte> Scan(object[] args)
  {
    return FingerprintScannerImpl.Scan();
  }

  static Fuse.Scripting.Object ScanConverter(Context c, sbyte data)
  {
    return null;
  }
}


[extern(Android) ForeignInclude(Language.Java,
  "com.virditech.nurugo.NurugoBSP",
	"com.virditech.nurugo.NurugoBSP.InfoData",
	"android.hardware.Camera",
	"android.hardware.Camera.PreviewCallback",
  "android.graphics.SurfaceTexture"
	)]
public class FingerprintScannerImpl
{
  static extern(Android) Java.Object _camera;
  static extern(Android) Java.Object _sdk;

  static Promise<sbyte> FutureData {
		get; set;
	}

  public static Future<sbyte> Scan() {
    ScanImpl();
    FutureData = new Promise<sbyte>();
    return FutureData;
  }

  [Foreign(Language.Java)]
  public static extern(Android) void ScanImpl()
  @{
    NurugoBSP sdk = (NurugoBSP)@{GetSDKInstance():Call()};
    Camera camera = (Camera)@{GetCameraInstance():Call()};

    sdk.initCameraParam(camera);
  @}

  [Foreign(Language.Java)]
  public static extern(Android) Java.Object GetSDKInstance()
  @{
    if (@{_sdk:Get()} == null) {
      NurugoBSP _sdk = new NurugoBSP();
      InfoData infoData = _sdk.new InfoData();
  		int ret = _sdk.init(infoData);

      @{_sdk:Set(_sdk)};
      return _sdk;
    }
    return @{_sdk:Get()};
  @}

  [Foreign(Language.Java)]
  public static extern(Android) Java.Object GetCameraInstance()
  @{
    if (@{_camera:Get()} == null) {
      Camera _camera = Camera.open();
      @{_camera:Set(_camera)};
      return _camera;
    }
    return @{_camera:Get()};
  @}

  public static extern(!Android) void ScanImpl()
  {
    debug_log "Not support!";
  }
}
