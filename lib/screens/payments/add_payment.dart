import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:societas/models/payment.dart';
import 'package:societas/providers/payment_provider.dart';

class PaymentForm extends StatefulWidget {
  final Payment? existingPayment;

  const PaymentForm({super.key, this.existingPayment});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();

  late double _amount;
  DateTime? _paymentDate;
  String? _paymentMethod;
  late int _memberId;
  int? _assessmentId;

  bool get isEdit => widget.existingPayment != null;

  @override
  void initState() {
    super.initState();

    final p = widget.existingPayment;
    if (p != null) {
      _amount = p.amount;
      _paymentDate = p.paymentdate;
      _paymentMethod = p.paymentmethod;
      _memberId = p.memberid;
      _assessmentId = p.assessmentid;
    } else {
      _amount = 0.0;
      _paymentDate = DateTime.now();
      _paymentMethod = 'Cash';
      _memberId = 1; // Replace with dynamic logic
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _paymentDate == null) return;
    _formKey.currentState!.save();

    final payment = Payment(
      id: widget.existingPayment?.id,
      memberid: _memberId,
      amount: _amount,
      paymentdate: _paymentDate!,
      paymentmethod: _paymentMethod,
      assessmentid: _assessmentId,
    );

    final provider = Provider.of<PaymentProvider>(context, listen: false);
    try {
      if (isEdit) {
        await provider.updatePayment(payment);
      } else {
        await provider.addPayment(payment);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Payment updated' : 'Payment added'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Payment' : 'Add Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _amount > 0 ? _amount.toString() : '',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount'),
                onSaved: (val) => _amount = double.parse(val!),
                validator: (val) =>
                    val == null ||
                        double.tryParse(val) == null ||
                        double.parse(val) <= 0
                    ? 'Enter valid amount'
                    : null,
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _paymentDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _paymentDate = picked);
                },
                child: Text(
                  _paymentDate == null
                      ? 'Select Payment Date'
                      : 'Date: ${_paymentDate!.toLocal().toString().split(' ')[0]}',
                ),
              ),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                items: ['Cash', 'Mobile Money', 'Bank Transfer', 'Cheque']
                    .map(
                      (method) =>
                          DropdownMenuItem(value: method, child: Text(method)),
                    )
                    .toList(),
                decoration: InputDecoration(labelText: 'Payment Method'),
                onChanged: (val) => setState(() => _paymentMethod = val),
              ),
              TextFormField(
                initialValue: _assessmentId?.toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Assessment ID (optional)',
                ),
                onSaved: (val) => _assessmentId = val == null || val.isEmpty
                    ? null
                    : int.tryParse(val),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isEdit ? 'Update Payment' : 'Add Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
