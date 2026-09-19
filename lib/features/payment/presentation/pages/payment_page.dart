import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:retail_test_task/core/platform/secure_page_mixin.dart';
import 'package:retail_test_task/core/tenant/tenant_scope.dart';
import 'package:retail_test_task/features/payment/debug/payment_debug_scenario.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:retail_test_task/features/payment/presentation/pages/payment_debug_page.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section_mapper.dart';
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

class PaymentPage extends StatefulWidget {
  const PaymentPage({this.createDebugBloc, super.key});

  final PaymentScenarioBlocFactory? createDebugBloc;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with SecurePageMixin<PaymentPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tenant = TenantScope.of(context);
    final sectionMapper = GetIt.instance<PaymentPageSectionMapper>();

    return Scaffold(
      appBar: AppBar(
        title: Text(tenant.appName),
        actions: [
          if (kDebugMode && widget.createDebugBloc != null)
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
            return PaymentStateView(
              state: state,
              sectionMapper: sectionMapper,
              contentScrollController: _scrollController,
              onPaymentAction: () => context.read<PaymentBloc>().add(
                const PaymentPrimaryActionRequested(),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openDebugPage(BuildContext context) {
    final debugBlocFactory = widget.createDebugBloc;
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
