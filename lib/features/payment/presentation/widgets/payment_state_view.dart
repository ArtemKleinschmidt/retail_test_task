import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:retail_test_task/core/tenant/tenant_design_tokens.dart';
import 'package:retail_test_task/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_page_section_mapper.dart';
import 'package:retail_test_task/features/payment/presentation/tenant/payment_tenant_components_scope.dart';

class PaymentStateView extends StatelessWidget {
  const PaymentStateView({
    required this.state,
    required this.sectionMapper,
    required this.contentScrollController,
    required this.onPaymentAction,
    super.key,
  });

  final PaymentState state;
  final PaymentPageSectionMapper sectionMapper;
  final ScrollController contentScrollController;
  final VoidCallback onPaymentAction;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      PaymentInitial() || PaymentLoading() => const _CenteredStatus(
        indicator: CircularProgressIndicator(),
        message: 'Loading payment details…',
      ),
      PaymentLoadFailed(:final failure) => _CenteredStatus(
        indicator: const Icon(Icons.receipt_long_outlined, size: 48),
        message: failure.message,
        actionLabel: 'Retry',
        onAction: () =>
            context.read<PaymentBloc>().add(const PaymentLoadRequested()),
      ),
      PaymentContentState contentState => _PaymentContentView(
        state: contentState,
        sectionMapper: sectionMapper,
        scrollController: contentScrollController,
        onPaymentAction: onPaymentAction,
      ),
    };
  }
}

class _PaymentContentView extends StatelessWidget {
  const _PaymentContentView({
    required this.state,
    required this.sectionMapper,
    required this.scrollController,
    required this.onPaymentAction,
  });

  final PaymentContentState state;
  final PaymentPageSectionMapper sectionMapper;
  final ScrollController scrollController;
  final VoidCallback onPaymentAction;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TenantDesignTokens>()!;
    final sectionKeys = PaymentTenantComponentsScope.of(context).sectionKeys;
    final sections = sectionMapper
        .mapAll(sectionKeys, onPaymentAction: onPaymentAction)
        .where((section) => section.isVisible(state))
        .toList(growable: false);

    return PaymentPageSectionScope(
      state: state,
      child: ListView.separated(
        key: const PageStorageKey<String>('payment-content'),
        controller: scrollController,
        padding: EdgeInsets.all(tokens.screenPadding),
        itemCount: sections.length,
        itemBuilder: (_, index) => sections[index],
        separatorBuilder: (_, _) => SizedBox(height: tokens.sectionSpacing),
      ),
    );
  }
}

class _CenteredStatus extends StatelessWidget {
  const _CenteredStatus({
    required this.indicator,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final Widget indicator;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<TenantDesignTokens>()!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            indicator,
            SizedBox(height: tokens.sectionSpacing),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              SizedBox(height: tokens.sectionSpacing),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
