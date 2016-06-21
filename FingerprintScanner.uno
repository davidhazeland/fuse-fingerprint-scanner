using Uno;
using Uno.Collections;
using Fuse.Scripting;
using Fuse.Reactive;
using Fuse;
using Uno.Compiler.ExportTargetInterop;

public class FingerprintScanner : NativeModule
{
  public FingerprintScanner() {
    AddMember(new NavivePromise<sbyte, Fuse.Scripting.Object>("scan", Scan, ScanConverter));
    AddMember(new NavivePromise<bool, Fuse.Scripting.Object>("match", Match, MatchConverter));
  }

  static Future<sbyte> Scan(object[] args) {

  }

  static Fuse.Scripting.Object ScanConverter(Context c, sbyte data) {

  }

  static Future<bool> Match(object[] args) {

  }

  static Fuse.Scripting.Object MatchConverter(Context c, bool result) {

  }
}
