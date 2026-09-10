import 'package:flutter/foundation.dart';

import 'browser_download_stub.dart'
    if (dart.library.js_interop) 'browser_download_web.dart' as impl;

/// Triggers a browser "Save As" download of [bytes] named [fileName]. No-op
/// outside web builds — desktop/mobile have no equivalent "download" concept
/// without also picking a destination folder, which isn't needed here yet.
void downloadBytesAsFile(List<int> bytes, String fileName) {
  if (!kIsWeb) return;
  impl.downloadBytesAsFile(bytes, fileName);
}
