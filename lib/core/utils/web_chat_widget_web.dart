import 'dart:js_interop';

@JS('RatrixChat.setVisible')
external void _setVisible(bool visible);

void setWebChatVisible(bool visible) => _setVisible(visible);
