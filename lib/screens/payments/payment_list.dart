import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:societas/models/payment.dart';
import 'package:societas/providers/payment_provider.dart';
import 'package:intl/intl.dart';

class FilteredPaymentList extends StatefulWidget {
  const FilteredPaymentList({super.key});

  @override
  State<FilteredPaymentList> createState() => _FilteredPaymentListState();
}

class _FilteredPaymentListState extends State<FilteredPaymentList> {
  String? selectedMemberId;
  DateTime? selectedMonth;

  @override
  void initState() {
    super.initState();
    Provider.of<PaymentProvider>(context, listen: false).fetchPayments();
  }

  @override
  Widget build(BuildContext context) {
    final payments = Provider.of<PaymentProvider>(context).payments;

    // Filter by member
    List<Payment> filtered = selectedMemberId == null
        ? payments
        : payments
              .where((p) => p.memberid.toString() == selectedMemberId)
              .toList();

    // Filter by date/month
    if (selectedMonth != null) {
      filtered = filtered
          .where(
            (p) =>
                p.paymentdate.month == selectedMonth!.month &&
                p.paymentdate.year == selectedMonth!.year,
          )
          .toList();
    }

    // Group by memberId
    final grouped = <String, List<Payment>>{};
    for (var payment in filtered) {
      final key =
          'Member ${payment.memberid}'; // Change to member name if available
      grouped.putIfAbsent(key, () => []).add(payment);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Payments'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: grouped.isEmpty
          ? Center(child: Text('No payments found.'))
          : ListView(
              children: grouped.entries.map((entry) {
                final payments = entry.value;
                return ExpansionTile(
                  title: Text('${entry.key} (${payments.length})'),
                  children: payments.map((p) {
                    return ListTile(
                      title: Text('Amount: GHS ${p.amount.toStringAsFixed(2)}'),
                      subtitle: Text(
                        'Date: ${DateFormat.yMMMd().format(p.paymentdate)} | Method: ${p.paymentmethod ?? 'N/A'}',
                      ),
                      trailing: p.assessmentid != null
                          ? Text('Assessment: ${p.assessmentid}')
                          : null,
                    );
                  }).toList(),
                );
              }).toList(),
            ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final memberIds = Provider.of<PaymentProvider>(
      context,
      listen: false,
    ).payments.map((p) => p.memberid.toString()).toSet().toList();

    showDialog(
      context: context,
      builder: (_) {
        String? localMemberId = selectedMemberId;
        DateTime? localDate = selectedMonth;

        return AlertDialog(
          title: Text('Filter Payments'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: localMemberId,
                hint: Text('Select Member'),
                items: memberIds
                    .map(
                      (id) => DropdownMenuItem(
                        value: id,
                        child: Text('Member $id'),
                      ),
                    )
                    .toList(),
                onChanged: (val) => localMemberId = val,
              ),
              SizedBox(height: 16),
              TextButton.icon(
                icon: Icon(Icons.calendar_month),
                label: Text(
                  localDate == null
                      ? 'Pick Month'
                      : DateFormat.yMMM().format(localDate),
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: localDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) localDate = picked;
                  setState(() {});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedMemberId = localMemberId;
                  selectedMonth = localDate;
                });
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedMemberId = null;
                  selectedMonth = null;
                });
                Navigator.pop(context);
              },
              child: Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
