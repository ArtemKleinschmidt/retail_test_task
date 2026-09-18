import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/core/tenant/tenant_scope.dart';
import 'package:retail_test_task/features/payment/debug/payment_debug_scenario.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:retail_test_task/features/payment/presentation/pages/payment_debug_page.dart';
import 'package:retail_test_task/features/payment/presentation/widgets/payment_state_view.dart';

typedef PaymentBlocFactory = PaymentBloc Function();
typedef PaymentScenarioBlocFactory = PaymentBloc Function(
  PaymentDebugScenario scenario,
);

class PaymentFlow extends StatelessWidget {
  const PaymentFlow({
    required this.createBloc,
    this.createDebugBloc,
    super.key,
  });

  final PaymentBlocFactory createBloc;
  final PaymentScenarioBlocFactory? createDebugBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createBloc()..add(const PaymentLoadRequested()),
      child: PaymentPage(createDebugBloc: createDebugBloc),
    );
  }
}

class PaymentPage extends StatelessWidget {
  const PaymentPage({this.createDebugBloc, super.key});

  final PaymentScenarioBlocFactory? createDebugBloc;

  @override
  Widget build(BuildContext context) {
    final tenant = TenantScope.of(context);
    final tokens = Theme.of(context).extension<TenantDesignTokens>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(tenant.appName),
        actions: [
          if (kDebugMode && createDebugBloc != null)
            IconButton(
              tooltip: 'Open payment scenarios',
              onPressed: () => _openDebugPage(context),
              icon: const Icon(Icons.bug_report_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: tokens.shortDuration,
              switchInCurve: tokens.motionCurve,
              switchOutCurve: tokens.motionCurve,
              child: KeyedSubtree(
                key: ValueKey<Type>(state.runtimeType),
                child: PaymentStateView(state: state),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openDebugPage(BuildContext context) {
    final debugBlocFactory = createDebugBloc;
    if (debugBlocFactory == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaymentDebugPage(createBloc: debugBlocFactory),
      ),
    );
  }
}
