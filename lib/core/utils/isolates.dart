import 'dart:convert';
import 'dart:io';
import 'package:liso/core/utils/console.dart';
import 'package:web3dart/credentials.dart';

class Isolates {
  static final console = Console(name: 'Isolates');

  static Future<Wallet> loadWallet(Map<String, dynamic> params) async {
    final file = File(params['file_path']);
    final password = params['password'];

    return Wallet.fromJson(
      await file.readAsString(),
      password,
    );
  }

  // static Future<List<VaultSeed>> seedsToWallets(
  //     Map<String, dynamic> params) async {
  //   final _encryptionKey = params['encryptionKey'] as List<int>;
  //   final seedsJson = jsonDecode(params['seeds']);

  //   final seeds = List<HiveLisoItem>.from(
  //     seedsJson.map((x) => HiveLisoItem.fromJson(x)),
  //   );

  //   // Convert seeds to Wallet objects
  //   return seeds.map<VaultSeed>((e) {
  //     final seedHex = bip39.mnemonicToSeedHex(e.mnemonic);

  //     final wallet = Wallet.createNew(
  //       EthPrivateKey.fromHex(seedHex),
  //       utf8.decode(_encryptionKey), // 32 byte master seed hex as the password
  //       Random.secure(),
  //     );

  //     return VaultSeed(seed: e, wallet: wallet);
  //   }).toList();

  //   return [];
  // }

  // TODO: use either
  static Future<String> writeStringToFile(Map<String, String> params) async {
    final filePath = params['file_path'] as String;
    final contents = params['contents'] as String;

    try {
      await File(filePath).writeAsString(contents);
    } catch (e) {
      console.error('write to file failed 1: ${e.toString()}');
      return e.toString();
    }

    return '';
  }

  static String iJsonEncode(dynamic params) {
    return jsonEncode(params);
  }

  static dynamic iJsonDecode(String params) {
    return jsonDecode(params);
  }

  static List<dynamic> fromJsonToList(List<dynamic> seeds) {
    return List<dynamic>.from(
      seeds.map((x) => x.toJson()),
    );
  }
}
