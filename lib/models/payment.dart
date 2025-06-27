class Payment {
  final int? id;
  final int memberid;
  final double amount;
  final DateTime paymentdate;
  final String? paymentmethod;
  final int? assessmentid;

  Payment({
    this.id,
    required this.memberid,
    required this.amount,
    required this.paymentdate,
    this.paymentmethod,
    this.assessmentid,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      memberid: json['member_id'],
      amount: double.parse(json['amount'].toString()),
      paymentdate: DateTime.parse(json['payment_date']),
      paymentmethod: json['payment_method'],
      assessmentid: json['assessment_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'member_id': memberid,
      'amount': amount,
      'payment_date': paymentdate.toIso8601String(),
      'payment_method': paymentmethod,
      'assessment_id': assessmentid,
    };
  }
}
