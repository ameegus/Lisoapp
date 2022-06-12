import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:supercharged/supercharged.dart';

import '../../utils/utils.dart';
import 'field.hive.dart';
import 'metadata/metadata.hive.dart';

part 'item.hive.g.dart';

@HiveType(typeId: 0)
class HiveLisoItem extends HiveObject with EquatableMixin, ConsoleMixin {
  @HiveField(0)
  String identifier;
  @HiveField(1)
  String groupId;
  @HiveField(2)
  String category;
  @HiveField(3)
  String title;
  @HiveField(4)
  String iconUrl;
  @HiveField(5)
  List<HiveLisoField> fields;
  @HiveField(6)
  bool favorite;
  @HiveField(7)
  bool protected;
  @HiveField(8)
  bool trashed;
  @HiveField(9)
  bool deleted;
  @HiveField(10)
  bool reserved;
  @HiveField(11)
  bool hidden;
  @HiveField(12)
  List<String> tags;
  @HiveField(13)
  List<String> sharedVaultIds;
  @HiveField(14)
  List<String> attachments;
  @HiveField(15)
  HiveMetadata metadata;

  HiveLisoItem({
    required this.identifier,
    required this.groupId,
    required this.category,
    required this.title,
    this.iconUrl = '',
    required this.fields,
    this.favorite = false,
    this.protected = false,
    this.trashed = false,
    this.deleted = false,
    this.reserved = false,
    this.hidden = false,
    this.tags = const [],
    this.sharedVaultIds = const [],
    this.attachments = const [],
    required this.metadata,
  });

  factory HiveLisoItem.fromJson(Map<String, dynamic> json) => HiveLisoItem(
        identifier: json["identifier"],
        groupId: json["group_id"],
        category: json["category"],
        iconUrl: json["icon_url"],
        title: json["title"],
        fields: List<HiveLisoField>.from(
          json["fields"].map((x) => HiveLisoField.fromJson(x)),
        ),
        favorite: json["favorite"],
        protected: json["protected"],
        trashed: json["trashed"],
        deleted: json["deleted"],
        reserved: json["reserved"],
        hidden: json["hidden"],
        tags: List<String>.from(json["tags"].map((x) => x)),
        sharedVaultIds:
            List<String>.from(json["shared_vault_ids"].map((x) => x)),
        attachments: List<String>.from(json["attachments"].map((x) => x)),
        metadata: HiveMetadata.fromJson(json["metadata"]),
      );

  Map<String, dynamic> toJson() {
    return {
      "identifier": identifier,
      "group_id": groupId,
      "category": category,
      "icon_url": iconUrl,
      "title": title,
      "fields": List<dynamic>.from(fields.map((x) => x.toJson())),
      "favorite": favorite,
      "protected": protected,
      "trashed": trashed,
      "deleted": deleted,
      "reserved": reserved,
      "hidden": hidden,
      "tags": List<dynamic>.from(tags.map((x) => x)),
      "shared_vault_ids": List<dynamic>.from(sharedVaultIds.map((x) => x)),
      "attachments": List<dynamic>.from(attachments.map((x) => x)),
      "metadata": metadata.toJson(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  List<Object?> get props => [
        identifier,
        groupId,
        category,
        iconUrl,
        title,
        fields,
        favorite,
        protected,
        trashed,
        deleted,
        reserved,
        hidden,
        tags,
        sharedVaultIds,
        attachments,
        metadata,
      ];

  List<Widget> get widgets => fields.map((e) => e.widget).toList();

  String get updatedDateTimeFormatted =>
      DateFormat.yMMMMd().add_jm().format(metadata.updatedTime);

  String get createdDateTimeFormatted =>
      DateFormat.yMMMMd().add_jm().format(metadata.createdTime);

  String get updatedTimeAgo =>
      Utils.timeAgo(metadata.updatedTime, short: false);

  int get daysLeftToDelete =>
      metadata.updatedTime.duration().inDays -
      DateTime.now().duration().inDays +
      WalletService.to.limits.trashDays;

  String get subTitle {
    String identifier = significant.keys.first;
    final foundFields = fields.where((e) => e.identifier == identifier);
    final field = foundFields.isNotEmpty ? foundFields.first : null;

    if (field == null || field.data.value == null) {
      console.error('null field or value here');
    }

    String value = field?.data.value ?? '';

    // // decode rich text back to plain text
    // if (categoryObject == LisoItemCategory.note) {
    //   try {
    //     value = Document.fromJson(jsonDecode(value)).toPlainText();
    //   } catch (e) {
    //     console.error('error decoding rich text: $e');
    //     value = 'failed to decode';
    //   }
    // }

    // obscure characters
    if (category == LisoItemCategory.encryption.name ||
        category == LisoItemCategory.note.name) {
      final obscuredCharacters = <String>[];

      for (var i = 0; i < (value.length < 100 ? value.length : 100); i++) {
        obscuredCharacters.add('*');
      }

      return obscuredCharacters.join();
    }

    return value;
  }

  // TODO: bind corresponding significant data
  Map<String, String> get significant {
    String identifier = '';

    if (category == LisoItemCategory.cryptoWallet.name) {
      identifier = 'address';
    } else if (category == LisoItemCategory.login.name) {
      identifier = 'website';
    } else if (category == LisoItemCategory.password.name) {
      identifier = 'website';
    } else if (category == LisoItemCategory.identity.name) {
      identifier = 'first_name';
    } else if (category == LisoItemCategory.note.name) {
      identifier = 'note';
    } else if (category == LisoItemCategory.cashCard.name) {
      identifier = 'holder_name';
    } else if (category == LisoItemCategory.bankAccount.name) {
      identifier = 'account_name';
    } else if (category == LisoItemCategory.medicalRecord.name) {
      identifier = 'healthcare_professional';
    } else if (category == LisoItemCategory.passport.name) {
      identifier = 'full_name';
    } else if (category == LisoItemCategory.server.name) {
      identifier = 'url';
    } else if (category == LisoItemCategory.softwareLicense.name) {
      identifier = 'publisher';
    } else if (category == LisoItemCategory.apiCredential.name) {
      identifier = 'host_name';
    } else if (category == LisoItemCategory.database.name) {
      identifier = 'database';
    } else if (category == LisoItemCategory.driversLicense.name) {
      identifier = 'full_name';
    } else if (category == LisoItemCategory.email.name) {
      identifier = 'username';
    } else if (category == LisoItemCategory.membership.name) {
      identifier = 'website';
    } else if (category == LisoItemCategory.outdoorLicense.name) {
      identifier = 'approved_wildlife';
    } else if (category == LisoItemCategory.rewardsProgram.name) {
      identifier = 'company_name';
    } else if (category == LisoItemCategory.socialSecurity.name) {
      identifier = 'name';
    } else if (category == LisoItemCategory.wirelessRouter.name) {
      identifier = 'base_station_name';
    } else if (category == LisoItemCategory.encryption.name) {
      identifier = 'note';
    } else {
      identifier = 'note';
    }

    final foundFields = fields.where((e) => e.identifier == identifier);
    final field = foundFields.isNotEmpty ? foundFields.first : null;

    if (field == null || field.data.value == null) {
      console.error('null field or value here');
    }

    String value = field?.data.value ?? '';

    // decode rich text back to plain text
    if (category == LisoItemCategory.note.name) {
      try {
        value = Document.fromJson(jsonDecode(value)).toPlainText();
      } catch (e) {
        console.error('error decoding rich text: $e');
        value = 'failed to decode';
      }
    }

    return {
      identifier: value,
      'name': GetUtils.capitalize(identifier.replaceAll('_', ' '))!,
    };
  }
}
