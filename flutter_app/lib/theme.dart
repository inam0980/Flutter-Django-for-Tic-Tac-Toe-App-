import 'package:flutter/material.dart';

class NeonColors {
  static const bgDeep = Color(0xFF0E0E10);
  static const bgSurface = Color(0xFF161618);
  static const bgElevated = Color(0xFF1F1F23);
  static const bgCard = Color(0xFF202024);

  static const orange = Color(0xFFFF6B1A);
  static const orangeBright = Color(0xFFFF8534);
  static const orangeDim = Color(0xFFCC4F0E);

  // Backwards-compat aliases used by older screens.
  static const cyan = orange;
  static const pink = Color(0xFFF5F5F5);
  static const violet = orange;

  static const textPrimary = Color(0xFFF5F5F7);
  static const textMuted = Color(0xFF8A8A92);
  static const textDim = Color(0xFF5A5A60);

  static const success = Color(0xFF4ADE80);
  static const danger = Color(0xFFFF4D4D);

  static const xMark = orange;
  static const oMark = Color(0xFFF5F5F7);
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: NeonColors.bgDeep,
  colorScheme: const ColorScheme.dark(
    primary: NeonColors.orange,
    onPrimary: Colors.white,
    secondary: NeonColors.orangeBright,
    onSecondary: Colors.white,
    tertiary: NeonColors.orange,
    surface: NeonColors.bgSurface,
    onSurface: NeonColors.textPrimary,
    surfaceContainerHighest: NeonColors.bgElevated,
    error: NeonColors.danger,
  ),
  fontFamily: 'Roboto',
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: NeonColors.textPrimary, fontWeight: FontWeight.w900, letterSpacing: 2.0),
    displayMedium: TextStyle(color: NeonColors.textPrimary, fontWeight: FontWeight.w900, letterSpacing: 1.6),
    headlineLarge: TextStyle(color: NeonColors.textPrimary, fontWeight: FontWeight.w800),
    headlineMedium: TextStyle(color: NeonColors.textPrimary, fontWeight: FontWeight.w800, letterSpacing: 1.0),
    headlineSmall: TextStyle(color: NeonColors.textPrimary, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(color: NeonColors.textPrimary, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(color: NeonColors.textPrimary, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: NeonColors.textPrimary),
    bodyMedium: TextStyle(color: NeonColors.textPrimary),
    bodySmall: TextStyle(color: NeonColors.textMuted),
    labelLarge: TextStyle(color: NeonColors.textPrimary, fontWeight: FontWeight.w700, letterSpacing: 1.0),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: NeonColors.bgDeep,
    foregroundColor: NeonColors.textPrimary,
    titleTextStyle: TextStyle(
      color: NeonColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.2,
    ),
    iconTheme: IconThemeData(color: NeonColors.textPrimary),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: NeonColors.bgSurface,
    hintStyle: const TextStyle(color: NeonColors.textMuted),
    labelStyle: const TextStyle(color: NeonColors.textMuted),
    floatingLabelStyle: const TextStyle(color: NeonColors.orange),
    prefixIconColor: NeonColors.textMuted,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: NeonColors.bgElevated, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: NeonColors.orange, width: 1.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: NeonColors.danger, width: 1.4),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: NeonColors.danger, width: 1.8),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return NeonColors.bgElevated;
        return NeonColors.orange;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return NeonColors.textMuted;
        return Colors.white;
      }),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2),
      ),
      elevation: const WidgetStatePropertyAll(0),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: NeonColors.orange,
      side: const BorderSide(color: NeonColors.orange, width: 1.6),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1.0),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: NeonColors.orange,
      textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.8),
    ),
  ),
  cardTheme: CardThemeData(
    color: NeonColors.bgCard,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: NeonColors.bgElevated, width: 1),
    ),
  ),
  dividerTheme: const DividerThemeData(color: NeonColors.bgElevated, thickness: 1),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: NeonColors.bgElevated,
    contentTextStyle: const TextStyle(color: NeonColors.textPrimary),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: NeonColors.orange,
  ),
  iconTheme: const IconThemeData(color: NeonColors.textPrimary),
);

class NeonBackground extends StatelessWidget {
  final Widget child;
  const NeonBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.4,
          colors: [
            Color(0xFF1F1715),
            NeonColors.bgDeep,
          ],
          stops: [0.0, 0.75],
        ),
      ),
      child: child,
    );
  }
}

/// Title used on the game screen: "TIC TAC TOE" with the middle word in orange.
class GameTitle extends StatelessWidget {
  final double fontSize;
  const GameTitle({super.key, this.fontSize = 28});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 18, height: 1.4, color: NeonColors.orange),
            const SizedBox(width: 8),
            Text('X',
                style: TextStyle(
                  color: NeonColors.orange,
                  fontSize: fontSize * 0.55,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(width: 8),
            Text('O',
                style: TextStyle(
                  color: NeonColors.textPrimary,
                  fontSize: fontSize * 0.55,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(width: 8),
            Container(width: 18, height: 1.4, color: NeonColors.orange),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('TIC ',
                style: TextStyle(
                  color: NeonColors.textPrimary,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                )),
            Text('TAC',
                style: TextStyle(
                  color: NeonColors.orange,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                )),
            Text(' TOE',
                style: TextStyle(
                  color: NeonColors.textPrimary,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                )),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 70,
          height: 2,
          decoration: BoxDecoration(
            color: NeonColors.orange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

/// Legacy compatibility — used by login_screen.
class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final double letterSpacing;

  const NeonText(
    this.text, {
    super.key,
    this.fontSize = 32,
    this.color = NeonColors.orange,
    this.fontWeight = FontWeight.w900,
    this.letterSpacing = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      ),
    );
  }
}

class NeonCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final EdgeInsetsGeometry padding;
  final bool active;

  const NeonCard({
    super.key,
    required this.child,
    this.glowColor = NeonColors.orange,
    this.padding = const EdgeInsets.all(18),
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: NeonColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? glowColor : NeonColors.bgElevated,
          width: active ? 2 : 1,
        ),
      ),
      child: child,
    );
  }
}

/// Section banner with leading icon + title + subtitle (used on game screen).
class StatusBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;

  const StatusBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconBg = NeonColors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NeonColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NeonColors.bgElevated, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: const TextStyle(
                      color: NeonColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                      color: NeonColors.textMuted,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom action button used by game screen (RESTART / HINT / UNDO).
class GameActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final int? badge;

  const GameActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: NeonColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NeonColors.bgElevated, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(icon,
                        color: disabled
                            ? NeonColors.textDim
                            : NeonColors.orange,
                        size: 26),
                    if (badge != null && badge! > 0)
                      Positioned(
                        top: -6,
                        right: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: NeonColors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$badge',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              )),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(label,
                    style: TextStyle(
                      color: disabled
                          ? NeonColors.textDim
                          : NeonColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
