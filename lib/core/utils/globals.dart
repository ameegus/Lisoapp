// COMPANY

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/credentials.dart';

const kAppName = 'Liso';
const kAppDescription =
    'Military-grade encrypted digital vault\nspecifically designed for securely storing sensitive informations';
const kAppWebsiteUrl = 'https://liso-vault.github.io'; // TODO: custom domain
// const kAppGithubUrl = 'https://github.com/Liso-Vault/app';
// const kAppGithubReleasesUrl = 'https://github.com/Liso-Vault/app/releases';
const kAppTwitterUrl = 'https://twitter.com/liso_vault';
// const kAppFacebookUrl = 'https://facebook.com/liso_vault';
// const kAppInstagramUrl = 'https://instagram.com/liso_vault';
const kAppEmail = 'liso.vault@gmail.com'; // TODO: custom domain email

const kDeveloperName = 'Stackwares';
const kDeveloperTwitterHandle = '@stackwares';
const kDeveloperTwitterUrl = 'https://twitter.com/stackwares';

const kGooglePlayUrl =
    'https://play.google.com/store/apps/details?id=com.liso.app';
const kAppStoreUrl = ''; // TODO: app store url

const kAppPrivacyUrl =
    'https://liso-vault.github.io/privacy'; // TODO: privacy url
const kAppTermsUrl = 'https://liso-vault.github.io/terms'; // TODO: terms url

const kHiveBoxItems = 'items';
const kHiveBoxArchived = 'archived';
const kHiveBoxTrash = 'trash';

const kLocalMasterWalletFileName = 'liso_wallet.json';
const kAad = 'liso';
const kRootDirectory = 'Liso';
const kBiometricPasswordKey = 'biometric_password';

const kMaxIconSize = 500000;

const kAppColor = Color(0xff02f297);

final inputFormatterRestrictSpaces =
    FilteringTextInputFormatter.deny(RegExp(r'\s'));

// VARS
List<int>? encryptionKey;
Wallet? masterWallet;
bool timeLockEnabled = true;

enum LisoItemSortOrder {
  titleAscending,
  titleDescending,
  categoryAscending,
  categoryDescending,
  dateModifiedAscending,
  dateModifiedDescending,
  dateCreatedAscending,
  dateCreatedDescending,
  favoriteAscending,
  favoriteDescending,
  protectedAscending,
  protectedDescending,
}

enum LisoItemCategory {
  cryptoWallet,
  login,
  password,
  identity,
  note,
  cashCard,
  bankAccount,
  medicalRecord,
  passport,
  server,
  softwareLicense,
  apiCredential,
  database,
  driversLicense,
  email,
  membership,
  outdoorLicense,
  rewardsProgram,
  socialSecurity,
  wirelessRouter,
  encryption,
}
