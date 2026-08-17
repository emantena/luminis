import 'package:flutter/widgets.dart';

/// Marca do Luminis, a partir do asset registrado em `pubspec.yaml`
/// (`assets/brand/luminis-logo.png`).
///
/// Widget de branding reutilizável; não decide layout de tela nem
/// hierarquia visual — isso é responsabilidade de cada tela ao consumi-lo.
class LuminisLogo extends StatelessWidget {
  const LuminisLogo({super.key, this.height = 48});

  /// Altura do logo. A largura é derivada mantendo a proporção original.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Luminis',
      image: true,
      child: Image.asset(
        'assets/brand/luminis-logo.png',
        height: height,
        excludeFromSemantics: true,
      ),
    );
  }
}
