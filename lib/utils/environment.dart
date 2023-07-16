
class KasieEnvironment {
  static const currentStatus = 'dev';
  // static const currentStatus = 'prod';

  static const devUrl='http://192.168.86.242:8080/';
// static const devUrl='http://172.20.10.10:8080/';

  static const prodUrl='https://kasietransie-umrjnxdnuq-ew.a.run.app/';

  static getUrl() {
    if (currentStatus == 'dev') {
      return devUrl;
    } else {
      return prodUrl;
    }
  }

}