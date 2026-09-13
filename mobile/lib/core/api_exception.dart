class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromResponse(int statusCode, Map<String, dynamic> body) {
    final errors = body['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final firstValue = errors.values.first;
      if (firstValue is List && firstValue.isNotEmpty) {
        return ApiException(
          firstValue.first.toString(),
          statusCode: statusCode,
        );
      }
    }

    return ApiException(
      body['message']?.toString() ?? 'Something went wrong. Please try again.',
      statusCode: statusCode,
    );
  }

  @override
  String toString() => message;
}
