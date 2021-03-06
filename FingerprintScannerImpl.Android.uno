using Uno;
using Uno.Collections;
using Fuse;
using Uno.Compiler.ExportTargetInterop;
using Uno.Threading;

[extern(Android) ForeignInclude(Language.Java,
  "java.io.IOException",
  "com.virditech.nurugo.NurugoBSP",
	"com.virditech.nurugo.NurugoBSP.InfoData",
  "com.virditech.nurugo.NurugoBSP.MatchingTemplateData",
  "com.virditech.nurugo.NurugoBSP.NURUGO_ERROR",
	"android.hardware.Camera",
	"android.hardware.Camera.PreviewCallback",
  "android.graphics.SurfaceTexture",
  "java.util.Arrays",
  "java.lang.Thread",
  "android.util.Base64",
  "android.util.Log"
	)]
public extern(Android) class FingerprintScannerImpl
{
  static extern(Android) Java.Object _camera;
  static extern(Android) Java.Object _sdk;
  static extern(Android) Java.Object _previewCallback;

  static Promise<string> FutureData {get; set;}

  static bool _IsStart = false;
  static bool IsCapture = false;

  public static void Initialize()
  {
    InitializeImpl();
  }

  [Foreign(Language.Java)]
  static extern(Android) void InitializeImpl()
  @{
    PreviewCallback callback = new PreviewCallback() {
        @Override
        public void onPreviewFrame(byte[] data, Camera cam) {
          if (!@{IsCapture}) {
            NurugoBSP sdk = (NurugoBSP)@{GetSDKInstance():Call()};

            byte[] outRaw = sdk.extractYuvToRaw(data);
            int ret = sdk.getErrorCode();

            @{IsCapture:Set(false)};
            @{Stop():Call()};

            if (ret == NURUGO_ERROR.NONE) {
              byte[] outTemplate = sdk.extractRawToTemplate(outRaw);
              ret = sdk.getErrorCode();

              if (ret == NURUGO_ERROR.NONE) {
                String base64 = Base64.encodeToString(outTemplate, Base64.DEFAULT);
                @{Done(string):Call(base64)};
              }
              else {
                Log.d("Extract Template Error", String.valueOf(ret));
                @{Error():Call()};
                @{Start():Call()};
              }
            } else {
              Log.d("Extract Raw Error", String.valueOf(ret));
              @{Error():Call()};
              @{Start():Call()};
            }
          }
        }
    };
    @{_previewCallback:Set(callback)};

    NurugoBSP sdk = (NurugoBSP)@{GetSDKInstance():Call()};
    sdk.setMatchScore(2000);
  @}

  /* start */

  public static void Start()
  {
    StartImpl();
  }

  [Foreign(Language.Java)]
  static extern(Android) void StartImpl()
  @{
    NurugoBSP sdk = (NurugoBSP)@{GetSDKInstance():Call()};
    Camera camera = (Camera)@{GetCameraInstance():Call()};

    sdk.initCameraParam(camera);

    SurfaceTexture surfaceTexture = new SurfaceTexture(10);
    try {
      camera.setPreviewTexture(surfaceTexture);
    } catch (IOException t) {

    }

    camera.startPreview();
    @{_IsStart:Set(true)};
  @}

  public static bool IsStart()
  {
    return IsStartImpl();
  }

  [Foreign(Language.Java)]
  static extern(Android) bool IsStartImpl()
  @{
    return @{_IsStart:Get()};
  @}

  /* scan */

  public static Future<string> Scan()
  {
    ScanImpl();
    FutureData = new Promise<string>();
    return FutureData;
  }

  [Foreign(Language.Java)]
  static extern(Android) void ScanImpl()
  @{
    try {
      Camera camera = (Camera)@{GetCameraInstance():Call()};
      PreviewCallback callback = (PreviewCallback) @{_previewCallback:Get()};

      camera.setPreviewCallback(callback);
    }
    catch (Exception e) {
		    @{Error():Call()};
		}
  @}

  /* match */

  public static bool Match(object[] args) {
    string src = args[0] as string;
    string dist = args[1] as string;
    return MatchImpl(src, dist);
  }

  [Foreign(Language.Java)]
  static extern(Android) bool MatchImpl(string src, string dst)
  @{
    NurugoBSP sdk = (NurugoBSP)@{GetSDKInstance():Call()};

    MatchingTemplateData matchingTemplateData = sdk.new MatchingTemplateData();
    byte[] templateSrc = Base64.decode(src, Base64.DEFAULT);
    byte[] templateDst = Base64.decode(dst, Base64.DEFAULT);

    matchingTemplateData.setInTemplateSrc(templateSrc);
    matchingTemplateData.setInTemplateDst(templateDst);

    int ret = sdk.matchTemplate(matchingTemplateData);
    return ret == NURUGO_ERROR.NONE;
  @}

  /* stop */

  public static void Stop() {
    StopImpl();
  }

  [Foreign(Language.Java)]
  static extern(Android) void StopImpl()
  @{
    @{ReleaseCamera():Call()};
    @{_IsStart:Set(false)};
  @}

  /* member */

  [Foreign(Language.Java)]
  static extern(Android) void ReleaseCamera()
  @{
    Camera camera = (Camera)@{GetCameraInstance():Call()};
    camera.stopPreview();
    camera.setPreviewCallback(null);
    camera.release();
    @{_camera:Set(null)};
	@}

  static void Error ()
  {
		FutureData.Reject(new Exception("Error!"));
	}

	static void Done (string data)
  {
		FutureData.Resolve(data);
	}

  /* get instance */

  [Foreign(Language.Java)]
  static extern(Android) Java.Object GetSDKInstance()
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
  static extern(Android) Java.Object GetCameraInstance()
  @{
    if (@{_camera:Get()} == null) {
      Camera _camera = Camera.open();
      @{_camera:Set(_camera)};
      return _camera;
    }
    return @{_camera:Get()};
  @}
}
