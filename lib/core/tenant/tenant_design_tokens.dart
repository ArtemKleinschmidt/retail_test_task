import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

enum TenantContentDensity { comfortable, compact }

/// Semantic visual tokens shared by tenant-aware presentation code.
@immutable
final class TenantDesignTokens extends ThemeExtension<TenantDesignTokens> {
  const TenantDesignTokens({
    required this.accent,
    required this.accentContainer,
    required this.securityErrorBackground,
    required this.securityErrorForeground,
    required this.cardRadius,
    required this.controlRadius,
    required this.screenPadding,
    required this.sectionSpacing,
    required this.itemSpacing,
    required this.dataRowHeight,
    required this.contentDensity,
    required this.shortDuration,
    required this.pageTransitionDuration,
    required this.motionCurve,
  });

  final Color accent;
  final Color accentContainer;
  final Color securityErrorBackground;
  final Color securityErrorForeground;
  final double cardRadius;
  final double controlRadius;
  final double screenPadding;
  final double sectionSpacing;
  final double itemSpacing;
  final double dataRowHeight;
  final TenantContentDensity contentDensity;
  final Duration shortDuration;
  final Duration pageTransitionDuration;
  final Curve motionCurve;

  @override
  TenantDesignTokens copyWith({
    Color? accent,
    Color? accentContainer,
    Color? securityErrorBackground,
    Color? securityErrorForeground,
    double? cardRadius,
    double? controlRadius,
    double? screenPadding,
    double? sectionSpacing,
    double? itemSpacing,
    double? dataRowHeight,
    TenantContentDensity? contentDensity,
    Duration? shortDuration,
    Duration? pageTransitionDuration,
    Curve? motionCurve,
  }) {
    return TenantDesignTokens(
      accent: accent ?? this.accent,
      accentContainer: accentContainer ?? this.accentContainer,
      securityErrorBackground:
          securityErrorBackground ?? this.securityErrorBackground,
      securityErrorForeground:
          securityErrorForeground ?? this.securityErrorForeground,
      cardRadius: cardRadius ?? this.cardRadius,
      controlRadius: controlRadius ?? this.controlRadius,
      screenPadding: screenPadding ?? this.screenPadding,
      sectionSpacing: sectionSpacing ?? this.sectionSpacing,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      dataRowHeight: dataRowHeight ?? this.dataRowHeight,
      contentDensity: contentDensity ?? this.contentDensity,
      shortDuration: shortDuration ?? this.shortDuration,
      pageTransitionDuration:
          pageTransitionDuration ?? this.pageTransitionDuration,
      motionCurve: motionCurve ?? this.motionCurve,
    );
  }

  @override
  TenantDesignTokens lerp(
    covariant ThemeExtension<TenantDesignTokens>? other,
    double t,
  ) {
    if (other is! TenantDesignTokens) {
      return this;
    }

    return TenantDesignTokens(
      accent: Color.lerp(accent, other.accent, t)!,
      accentContainer: Color.lerp(accentContainer, other.accentContainer, t)!,
      securityErrorBackground: Color.lerp(
        securityErrorBackground,
        other.securityErrorBackground,
        t,
      )!,
      securityErrorForeground: Color.lerp(
        securityErrorForeground,
        other.securityErrorForeground,
        t,
      )!,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
      controlRadius: lerpDouble(controlRadius, other.controlRadius, t)!,
      screenPadding: lerpDouble(screenPadding, other.screenPadding, t)!,
      sectionSpacing: lerpDouble(sectionSpacing, other.sectionSpacing, t)!,
      itemSpacing: lerpDouble(itemSpacing, other.itemSpacing, t)!,
      dataRowHeight: lerpDouble(dataRowHeight, other.dataRowHeight, t)!,
      contentDensity: t < 0.5 ? contentDensity : other.contentDensity,
      shortDuration: _lerpDuration(shortDuration, other.shortDuration, t),
      pageTransitionDuration: _lerpDuration(
        pageTransitionDuration,
        other.pageTransitionDuration,
        t,
      ),
      motionCurve: t < 0.5 ? motionCurve : other.motionCurve,
    );
  }
}

Duration _lerpDuration(Duration start, Duration end, double t) {
  return Duration(
    microseconds: lerpDouble(
      start.inMicroseconds,
      end.inMicroseconds,
      t,
    )!.round(),
  );
}
