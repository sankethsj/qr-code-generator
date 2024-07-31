// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:animations/animations.dart";
import "package:flex_color_scheme/flex_color_scheme.dart";

// Project imports:

class AppTheme {
  static ColorScheme? lightColorScheme;
  static ColorScheme? darkColorScheme;
  static late bool hasDynamicColor;

  static ThemeData getTheme(
    Brightness brightness,
    ColorScheme? light,
    ColorScheme? dark,
  ) {
    lightColorScheme = light;
    darkColorScheme = dark;
    hasDynamicColor = light != null;

    final ColorScheme colorScheme =
        brightness == Brightness.light ? lightTheme() : darkTheme();

    ThemeData theme;
    String? fontFamily = "Raleway";
    if (fontFamily == "system") fontFamily = null;

    if (brightness == Brightness.light) {
      theme = FlexColorScheme.light(
        useMaterial3: true,
        colorScheme: colorScheme,
        fontFamily: fontFamily,
        subThemesData: const FlexSubThemesData(
          popupMenuRadius: 8,
          appBarCenterTitle: false,
        ),
      ).toTheme;
    } else {
      theme = FlexColorScheme.dark(
        useMaterial3: true,
        colorScheme: colorScheme,
        fontFamily: fontFamily,
        subThemesData: const FlexSubThemesData(
          popupMenuRadius: 8,
          appBarCenterTitle: false,
        ),
      ).toTheme;
    }

    final TextTheme textTheme = theme.textTheme.copyWith(
      titleLarge: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      headlineSmall: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      headlineMedium: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      headlineLarge: theme.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      displaySmall: theme.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 40,
      ),
      displayMedium: theme.textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 45,
      ),
      displayLarge: theme.textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 57,
      ),
    );

    return theme.copyWith(
      textTheme: textTheme,
      listTileTheme: theme.listTileTheme.copyWith(
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        iconColor: colorScheme.secondary,
      ),
      expansionTileTheme: theme.expansionTileTheme.copyWith(
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: colorScheme.primary,
        collapsedIconColor: colorScheme.onSurface.withOpacity(0.5),
      ),
      cardTheme: theme.cardTheme.copyWith(
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: theme.dividerTheme.copyWith(
        thickness: 0.5,
        space: 1,
        indent: 16,
        endIndent: 16,
        color: colorScheme.surfaceVariant,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SharedAxisTransitionBuilder(),
          TargetPlatform.windows: SharedAxisTransitionBuilder(),
          TargetPlatform.linux: SharedAxisTransitionBuilder(),
          TargetPlatform.fuchsia: SharedAxisTransitionBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      iconTheme: theme.iconTheme.copyWith(
        color: colorScheme.secondary,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: false,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: colorScheme.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: colorScheme.error),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      tabBarTheme: theme.tabBarTheme.copyWith(
        tabAlignment: TabAlignment.start,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ElevationOverlay.applySurfaceTint(
          colorScheme.inverseSurface,
          colorScheme.surfaceTint,
          3,
        ),
        contentTextStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.inversePrimary,
      ),
      appBarTheme: AppBarTheme(
        // ignore: avoid_redundant_argument_values
        systemOverlayStyle: null,
        actionsIconTheme: theme.appBarTheme.actionsIconTheme,
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: theme.appBarTheme.centerTitle,
        elevation: theme.appBarTheme.elevation,
        foregroundColor: theme.appBarTheme.foregroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
        shadowColor: theme.appBarTheme.shadowColor,
        titleSpacing: theme.appBarTheme.titleSpacing,
        scrolledUnderElevation: theme.appBarTheme.scrolledUnderElevation,
        shape: theme.appBarTheme.shape,
        surfaceTintColor: theme.appBarTheme.surfaceTintColor,
        toolbarHeight: theme.appBarTheme.toolbarHeight,
        toolbarTextStyle: theme.appBarTheme.toolbarTextStyle,
        titleTextStyle: theme.appBarTheme.titleTextStyle,
      ),
      switchTheme: theme.switchTheme.copyWith(
        thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return const Icon(Icons.check);
            }
            return null;
          },
        ),
      ),
      //platform: TargetPlatform.iOS,
    );
  }

  static ColorScheme lightTheme() {
    const seedColor = Color(0xFF2196f3);

    final ColorScheme scheme =
        lightColorScheme ?? ColorScheme.fromSeed(seedColor: seedColor);

    return scheme;
  }

  static ColorScheme darkTheme() {
    const seedColor = Color(0xFF2196f3);

    final ColorScheme scheme = darkColorScheme ??
        ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark);

    return scheme;
  }
}

class SharedAxisTransitionBuilder extends PageTransitionsBuilder {
  const SharedAxisTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.horizontal,
      child: child,
    );
  }
}
