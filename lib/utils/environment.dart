class KasieEnvironment {
  // static const _currentStatus = 'prod';
  static const _currentStatus = 'dev';
  //
  static const _devUrl='http://192.168.86.242:8080/';
  // static const _devUrl = 'http://172.20.10.10:8080/';

  static const _prodUrl = 'https://kasietransie-umrjnxdnuq-ew.a.run.app/';

  static getUrl() {
    if (_currentStatus == 'dev') {
      return _devUrl;
    } else {
      return _prodUrl;
    }
  }
}
