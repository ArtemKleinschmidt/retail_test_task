import 'package:retail_test_task/features/payment/domain/entities/bill_item.dart';
import 'package:retail_test_task/features/payment/domain/entities/money.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment.dart';
import 'package:retail_test_task/features/payment/domain/entities/payment_reference.dart';

Payment createPredefinedPayment() {
  return Payment(
    reference: PaymentReference('PAY-2026-0918'),
    payeeName: 'Northstar Services',
    total: Money(amountInMinorUnits: 12840, currencyCode: 'USD'),
    billItems: [
      BillItem(
        label: 'Service usage',
        amount: Money(amountInMinorUnits: 9650, currencyCode: 'USD'),
      ),
      BillItem(
        label: 'Network charge',
        amount: Money(amountInMinorUnits: 2100, currencyCode: 'USD'),
      ),
      BillItem(
        label: 'Taxes',
        amount: Money(amountInMinorUnits: 1090, currencyCode: 'USD'),
      ),
    ],
  );
}
