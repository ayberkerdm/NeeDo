class OfferModel {
  final String id;
  final String requestId;
  final String providerId;
  final double price;
  final String? estimatedTime;
  final String status;
  final DateTime createdAt;
  final String? providerName;
  final double? providerRating;
  final String? requestService;
  final String? requestLocation;
  final String? requestStatus;
  final double? customerCounterPrice;

  OfferModel({
    required this.id,
    required this.requestId,
    required this.providerId,
    required this.price,
    this.customerCounterPrice,
    this.estimatedTime,
    required this.status,
    required this.createdAt,
    this.providerName,
    this.providerRating,
    this.requestService,
    this.requestLocation,
    this.requestStatus,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    String? pName;
    double? pRating;
    
    if (json['profiles'] != null && json['profiles'] is Map) {
      pName = json['profiles']['full_name'];
      pRating = (json['profiles']['rating'] as num?)?.toDouble();
    }

    String? reqService;
    String? reqLocation;
    String? reqStatus;
    if (json['requests'] != null && json['requests'] is Map) {
      reqLocation = json['requests']['location'];
      reqStatus = json['requests']['status'];
      if (json['requests']['services'] != null && json['requests']['services'] is Map) {
        reqService = json['requests']['services']['name'];
      }
    }

    return OfferModel(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      providerId: json['provider_id'] as String,
      price: (json['price'] as num).toDouble(),
      customerCounterPrice: json['customer_counter_price'] != null ? (json['customer_counter_price'] as num).toDouble() : null,
      estimatedTime: json['estimated_time'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      providerName: pName,
      providerRating: pRating,
      requestService: reqService,
      requestLocation: reqLocation,
      requestStatus: reqStatus,
    );
  }
}
