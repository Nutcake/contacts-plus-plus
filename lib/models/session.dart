import 'package:contacts_plus_plus/config.dart';
import 'package:contacts_plus_plus/string_formatter.dart';

class Session {
  final String id;
  final String name;
  final FormatNode formattedName;
  final List<SessionUser> sessionUsers;
  final String thumbnail;
  final int maxUsers;
  final bool hasEnded;
  final bool isValid;
  final String description;
  final FormatNode formattedDescription;
  final List<String> tags;
  final bool headlessHost;
  final String hostUserId;
  final String hostUsername;
  final SessionAccessLevel accessLevel;

  Session({
    required this.id,
    required this.name,
    required this.sessionUsers,
    required this.thumbnail,
    required this.maxUsers,
    required this.hasEnded,
    required this.isValid,
    required this.description,
    required this.tags,
    required this.headlessHost,
    required this.hostUserId,
    required this.hostUsername,
    required this.accessLevel,
  })  : formattedName = FormatNode.fromText(name),
        formattedDescription = FormatNode.fromText(description);

  factory Session.none() {
    return Session(
        id: "",
        name: "",
        sessionUsers: const [],
        thumbnail: "",
        maxUsers: 0,
        hasEnded: true,
        isValid: false,
        description: "",
        tags: const [],
        headlessHost: false,
        hostUserId: "",
        hostUsername: "",
        accessLevel: SessionAccessLevel.unknown);
  }

  bool get isNone => id.isEmpty && isValid == false;

  factory Session.fromMap(Map? map) {
    if (map == null) return Session.none();
    return Session(
      id: map["sessionId"],
      name: map["name"],
      sessionUsers: (map["sessionUsers"] as List? ?? []).map((entry) => SessionUser.fromMap(entry)).toList(),
      thumbnail: map["thumbnail"] ?? "",
      maxUsers: map["maxUsers"] ?? 0,
      hasEnded: map["hasEnded"] ?? false,
      isValid: map["isValid"] ?? true,
      description: map["description"] ?? "",
      tags: ((map["tags"] as List?) ?? []).map((e) => e.toString()).toList(),
      headlessHost: map["headlessHost"] ?? false,
      hostUserId: map["hostUserId"] ?? "",
      hostUsername: map["hostUsername"] ?? "",
      accessLevel: SessionAccessLevel.fromName(map["accessLevel"]),
    );
  }

  Map toMap({bool shallow = false}) {
    return {
      "sessionId": id,
      "name": name,
      "sessionUsers": shallow ? [] : sessionUsers.map((e) => e.toMap()).toList(),
      "thumbnail": thumbnail,
      "maxUsers": maxUsers,
      "hasEnded": hasEnded,
      "isValid": isValid,
      "description": description,
      "tags": shallow ? [] : tags,
      "headlessHost": headlessHost,
      "hostUserId": hostUserId,
      "hostUsername": hostUsername,
      "accessLevel": accessLevel.name, // This probably wont work, the API usually expects integers.
    };
  }

  bool get isLive => !hasEnded && isValid;
}

enum SessionAccessLevel {
  unknown,
  private,
  friends,
  friendsOfFriends,
  anyone;

  static const _readableNamesMap = {
    SessionAccessLevel.unknown: "Unknown",
    SessionAccessLevel.private: "Private",
    SessionAccessLevel.friends: "Contacts",
    SessionAccessLevel.friendsOfFriends: "Contacts+",
    SessionAccessLevel.anyone: "Anyone",
  };

  factory SessionAccessLevel.fromName(String? name) {
    return SessionAccessLevel.values.firstWhere(
      (element) => element.name.toLowerCase() == name?.toLowerCase(),
      orElse: () => SessionAccessLevel.unknown,
    );
  }

  String toReadableString() {
    return SessionAccessLevel._readableNamesMap[this] ?? "Unknown";
  }
}

class SessionUser {
  final String id;
  final String username;
  final bool isPresent;
  final int outputDevice;

  SessionUser({required this.id, required this.username, required this.isPresent, required this.outputDevice});

  factory SessionUser.fromMap(Map map) {
    return SessionUser(
      id: map["userID"] ?? "",
      username: map["username"] ?? "Unknown",
      isPresent: map["isPresent"] ?? false,
      outputDevice: map["outputDevice"] ?? 0,
    );
  }

  Map toMap() {
    return {
      "userID": id,
      "username": username,
      "isPresent": isPresent,
      "outputDevice": outputDevice,
    };
  }
}

class SessionFilterSettings {
  final String name;
  final bool includeEnded;
  final bool includeIncompatible;
  final String hostName;
  final int minActiveUsers;
  final bool includeEmptyHeadless;

  const SessionFilterSettings({
    required this.name,
    required this.includeEnded,
    required this.includeIncompatible,
    required this.hostName,
    required this.minActiveUsers,
    required this.includeEmptyHeadless,
  });

  factory SessionFilterSettings.empty() => const SessionFilterSettings(
        name: "",
        includeEnded: false,
        includeIncompatible: false,
        hostName: "",
        minActiveUsers: 0,
        includeEmptyHeadless: true,
      );

  String buildRequestString() => "?includeEmptyHeadless=$includeEmptyHeadless"
      "${"&includeEnded=$includeEnded"}"
      "${name.isNotEmpty ? "&name=$name" : ""}"
      "${!includeIncompatible ? "&compatibilityHash=${Uri.encodeComponent(Config.latestCompatHash)}" : ""}"
      "${hostName.isNotEmpty ? "&hostName=$hostName" : ""}"
      "${minActiveUsers > 0 ? "&minActiveUsers=$minActiveUsers" : ""}";

  SessionFilterSettings copyWith({
    String? name,
    bool? includeEnded,
    bool? includeIncompatible,
    String? hostName,
    int? minActiveUsers,
    bool? includeEmptyHeadless,
  }) {
    return SessionFilterSettings(
      name: name ?? this.name,
      includeEnded: includeEnded ?? this.includeEnded,
      includeIncompatible: includeIncompatible ?? this.includeIncompatible,
      hostName: hostName ?? this.hostName,
      minActiveUsers: minActiveUsers ?? this.minActiveUsers,
      includeEmptyHeadless: includeEmptyHeadless ?? this.includeEmptyHeadless,
    );
  }
}
