class RequestModel {
  final String id;
  final String customerId;
  final String? serviceId;
  final String title;
  final String? description;
  final String? location;
  final String? budgetRange;
  final String status;
  final DateTime createdAt;
  final String? serviceName;
  final String? customerName;

  RequestModel({
    required this.id,
    required this.customerId,
    this.serviceId,
    required this.title,
    this.description,
    this.location,
    this.budgetRange,
    required this.status,
    required this.createdAt,
    this.serviceName,
    this.customerName,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    String? sName;
    if (json['services'] != null && json['services'] is Map) {
      sName = json['services']['name'];
    }

    String? cName;
    if (json['profiles'] != null && json['profiles'] is Map) {
      cName = json['profiles']['full_name'];
    }

    return RequestModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      serviceId: json['service_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      budgetRange: json['budget_range'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      serviceName: sName,
      customerName: cName,
    );
  }
}
