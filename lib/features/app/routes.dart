abstract class Routes {
  static const main = '/';

  // SCREENS
  static const unknown = '/unknown';
  static const welcome = '/welcome';
  static const settings = '/settings';
  static const about = '/about';
  static const createPassword = '/create_password';
  static const mnemonic = '/mnemonic';
  static const confirmMnemonic = '/verify_mnemonic';
  static const import = '/import';
  static const export = '/export';
  static const item = '/item';
  static const reset = '/reset';
  static const unlock = '/unlock';
  static const upgrade = '/upgrade';
  static const otp = '/otp';
  static const vaults = '/vaults';
  static const sharedVaults = '/shared_vaults';
  static const disabledBeta = '/disabled_beta';
  static const debug = '/debug';

  // SYNC
  static const configuration = '/configuration';
  static const syncing = '/syncing';
  static const syncProvider = '/sync_provider';

  // S3
  static const s3Explorer = '/s3_explorer';
  static const attachments = '/attachments';

  // CRYPTO
  static const wallet = '/wallet';
  static const cipher = '/cipher';
}
