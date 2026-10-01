// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Envia [mensagem] para a página que contém o app num iframe.
///
/// Só envia quando o app está de fato dentro de um iframe (a janela "pai" é
/// outra janela). O [targetOrigin] faz o navegador descartar a mensagem se a
/// página pai não for exatamente desse endereço.
void postMessageToParent(Map<String, dynamic> mensagem, String targetOrigin) {
  final parent = html.window.parent;
  if (parent == null || identical(parent, html.window)) return;
  parent.postMessage(mensagem, targetOrigin);
}
