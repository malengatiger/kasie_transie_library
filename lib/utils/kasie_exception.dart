

class KasieException implements Exception {

  late String _message;
  late String _translationKey;
  late String _errorType;
  late String _url;

  KasieException({required String message, required String translationKey,
    required String errorType, required String url}) {
    _message = message;
    _translationKey = translationKey;
    _errorType = errorType;
    _url = url;
  }

  @override
  String toString() {
    return _message;
  }

  String getErrorType() {
    return _errorType;
  }

  String getUrl() {
    return _url;
  }
  String geTranslationKey() {
    return _translationKey;
  }

  static const
  timeoutException = 'TimeoutException',
      socketException = 'SocketException',
      httpException = 'HttpException',
      formatException = 'FormatException';
}

