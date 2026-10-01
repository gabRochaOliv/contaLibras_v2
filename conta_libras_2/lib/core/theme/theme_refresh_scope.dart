import 'package:flutter/widgets.dart';

import '../../data/managers/theme_manager.dart';

/// Reconstrói toda a árvore abaixo do Navigator quando o tema muda.
///
/// Muitos widgets leem cores de [AppColors] (que consulta o ThemeManager)
/// em vez de `Theme.of(context)`. Esses widgets não registram dependência
/// no Theme, então o Flutter não os reconstrói na troca de tema e eles
/// ficavam presos no modo anterior (ex.: sidebar, telas no IndexedStack,
/// widgets `const`). Marcar todos os elementos como sujos resolve isso sem
/// perder estado (rolagem, aba selecionada, rota atual).
class ThemeRefreshScope extends StatefulWidget {
  const ThemeRefreshScope({super.key, required this.child});

  final Widget child;

  @override
  State<ThemeRefreshScope> createState() => _ThemeRefreshScopeState();
}

class _ThemeRefreshScopeState extends State<ThemeRefreshScope> {
  @override
  void initState() {
    super.initState();
    ThemeManager().addListener(_rebuildTree);
  }

  @override
  void dispose() {
    ThemeManager().removeListener(_rebuildTree);
    super.dispose();
  }

  void _rebuildTree() {
    void markDirty(Element element) {
      element.markNeedsBuild();
      element.visitChildren(markDirty);
    }

    (context as Element).visitChildren(markDirty);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
