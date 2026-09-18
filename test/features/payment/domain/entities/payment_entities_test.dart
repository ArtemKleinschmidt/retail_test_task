import 'package:flutter_test/flutter_test.dart';
import 'package:retail_test_task/features/payment/domain/entities/bill_item.dart';
import 'package:retail_test_task/features/payment/domain/entities/confirmation_decision.dart';
import 'package:retail_test_task/features/payment/domain/entities/money.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_processing_update.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_reference.dart';
import 'package:retail_test_task/features/payment/domain/entities/security_status.dart';

void main() {
  group('Money', () {
    test('uses minor units and currency code for value equality', () {
      expect(
        Money(amountInMinorUnits: 1250, currencyCode: 'USD'),
        Money(amountInMinorUnits: 1250, currencyCode: 'USD'),
      );
    });

    test('rejects negative minor units', () {
      expect(
        () => Money(amountInMinorUnits: -1, currencyCode: 'USD'),
        throwsArgumentError,
      );
    });

    test('rejects a currency code that is not three uppercase letters', () {
      expect(
        () => Money(amountInMinorUnits: 100, currencyCode: 'usd'),
        throwsArgumentError,
      );
      expect(
        () => Money(amountInMinorUnits: 100, currencyCode: 'US'),
        throwsArgumentError,
      );
    });
  });

  group('PaymentReference', () {
    test('trims and compares the reference value', () {
      expect(PaymentReference('  INV-001  '), PaymentReference('INV-001'));
    });

    test('rejects a blank value', () {
      expect(() => PaymentReference('   '), throwsArgumentError);
    });
  });

  group('Payment', () {
    test('normalizes labels and protects its bill items from mutation', () {
      final item = BillItem(
        label: '  Usage  ',
        amount: Money(amountInMinorUnits: 2500, currencyCode: 'USD'),
      );
      final sourceItems = [item];
      final payment = Payment(
        reference: PaymentReference('INV-001'),
        payeeName: '  City Utilities  ',
        total: Money(amountInMinorUnits: 2500, currencyCode: 'USD'),
        billItems: sourceItems,
      );

      sourceItems.clear();

      expect(item.label, 'Usage');
      expect(payment.payeeName, 'City Utilities');
      expect(payment.billItems, [item]);
      expect(() => payment.billItems.clear(), throwsUnsupportedError);
    });

    test('rejects blank bill labels and payee names', () {
      final amount = Money(amountInMinorUnits: 100, currencyCode: 'USD');

      expect(() => BillItem(label: ' ', amount: amount), throwsArgumentError);
      expect(
        () => Payment(
          reference: PaymentReference('INV-001'),
          payeeName: ' ',
          total: amount,
        ),
        throwsArgumentError,
      );
    });

    test('supports value equality', () {
      Payment buildPayment() => Payment(
        reference: PaymentReference('INV-001'),
        payeeName: 'City Utilities',
        total: Money(amountInMinorUnits: 2500, currencyCode: 'USD'),
        billItems: [
          BillItem(
            label: 'Usage',
            amount: Money(amountInMinorUnits: 2500, currencyCode: 'USD'),
          ),
        ],
      );

      expect(buildPayment(), buildPayment());
    });
  });

  group('Processing models', () {
    test('validates progress percentage', () {
      final reference = PaymentReference('INV-001');

      expect(
        () => PaymentProgress(reference: reference, percentage: -1),
        throwsArgumentError,
      );
      expect(
        () => PaymentProgress(reference: reference, percentage: 101),
        throwsArgumentError,
      );
      expect(
        PaymentProgress(reference: reference, percentage: 50),
        PaymentProgress(reference: reference, percentage: 50),
      );
    });

    test('compares results by reference and outcome', () {
      expect(
        PaymentResult(
          reference: PaymentReference('INV-001'),
          outcome: PaymentOutcome.success,
        ),
        PaymentResult(
          reference: PaymentReference('INV-001'),
          outcome: PaymentOutcome.success,
        ),
      );
    });
  });

  group('ConfirmationDecision', () {
    test('protects blocking threats from mutation', () {
      final sourceThreats = [SecurityThreat.rootedDevice];
      final decision = ConfirmationDecision.blocked(sourceThreats);

      sourceThreats.clear();

      expect(decision.isAllowed, isFalse);
      expect(decision.blockingThreats, [SecurityThreat.rootedDevice]);
      expect(() => decision.blockingThreats.clear(), throwsUnsupportedError);
    });

    test('rejects a blocked decision without threats', () {
      expect(() => ConfirmationDecision.blocked(const []), throwsArgumentError);
    });
  });
}
