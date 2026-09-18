import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:retail_test_task/core/navigation/app_route_observer.dart';
import 'package:retail_test_task/core/platform/window_protection.dart';

Object? _activeSecurePage;

mixin SecurePageMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  final WindowProtection _windowProtection = GetIt.instance<WindowProtection>();
  final Object _securePageIdentity = Object();

  ModalRoute<dynamic>? _subscribedRoute;
  bool? _secureRequested;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (identical(route, _subscribedRoute)) {
      return;
    }

    appRouteObserver.unsubscribe(this);
    _subscribedRoute = route;
    if (route != null) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPush() {
    _activateProtection();
  }

  @override
  void didPopNext() {
    _activateProtection();
  }

  @override
  void didPushNext() {
    _deactivateProtection();
  }

  @override
  void didPop() {
    _deactivateProtection();
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _deactivateProtection();
    super.dispose();
  }

  void _activateProtection() {
    _activeSecurePage = _securePageIdentity;
    _requestSecure(true);
  }

  void _deactivateProtection() {
    if (!identical(_activeSecurePage, _securePageIdentity)) {
      return;
    }

    _activeSecurePage = null;
    _requestSecure(false);
  }

  void _requestSecure(bool enabled) {
    if (_secureRequested == enabled) {
      return;
    }

    _secureRequested = enabled;
    unawaited(_updateSecure(enabled));
  }

  Future<void> _updateSecure(bool enabled) async {
    try {
      await _windowProtection.setSecure(enabled);
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'secure page protection',
          context: ErrorDescription(
            'while ${enabled ? 'enabling' : 'disabling'} FLAG_SECURE',
          ),
        ),
      );

      if (!enabled || !mounted || _subscribedRoute?.isCurrent != true) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _subscribedRoute?.isCurrent != true) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Screen protection could not be enabled.'),
          ),
        );
      });
    }
  }
}
