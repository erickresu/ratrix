import 'package:flutter/foundation.dart';

import 'web_chat_widget_stub.dart'
    if (dart.library.js_interop) 'web_chat_widget_web.dart' as impl;

/// Shows/hides the wyred.tech chat bubble injected via `<script>` in
/// `web/index.html` — it isn't part of the Flutter widget tree, so it has
/// to be toggled through JS interop. No-op outside web builds.
void setWebChatVisible(bool visible) {
  if (!kIsWeb) return;
  impl.setWebChatVisible(visible);
}
