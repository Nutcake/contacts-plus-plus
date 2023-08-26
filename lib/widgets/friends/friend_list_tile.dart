import 'package:contacts_plus_plus/auxiliary.dart';
import 'package:contacts_plus_plus/clients/messaging_client.dart';
import 'package:contacts_plus_plus/models/users/friend.dart';
import 'package:contacts_plus_plus/models/message.dart';
import 'package:contacts_plus_plus/widgets/formatted_text.dart';
import 'package:contacts_plus_plus/widgets/friends/friend_online_status_indicator.dart';
import 'package:contacts_plus_plus/widgets/generic_avatar.dart';
import 'package:contacts_plus_plus/widgets/messages/messages_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:contacts_plus_plus/widgets/friends/friend_dialog.dart';

class FriendListTile extends StatelessWidget {
  const FriendListTile(
      {required this.friend, required this.unreads, this.onTap, super.key});

  final Friend friend;
  final int unreads;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    final imageUri = Aux.neosDbToHttp(friend.userProfile.iconUrl);
    final theme = Theme.of(context);
    return ListTile(
      leading: GenericAvatar(
        imageUri: imageUri,
      ),
      trailing: unreads != 0
          ? Text(
              "+$unreads",
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.primary),
            )
          : null,
      title: Row(
        children: [
          Text(friend.username),
          if (friend.isHeadless)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.dns,
                size: 12,
                color: theme.colorScheme.onSecondaryContainer.withAlpha(150),
              ),
            )
          else if (friend.userStatus.outputDevice == "Screen")
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.desktop_windows,
                size: 13,
                color: theme.colorScheme.onSecondaryContainer.withAlpha(150),
              ),
            )
          else if (friend.userStatus.outputDevice == "VR")
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                MdiIcons.googleCardboard,
                size: 14,
                color: theme.colorScheme.onSecondaryContainer.withAlpha(150),
              ),
            ),
          if (friend.id == "U-Neos")
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                MdiIcons.robot,
                size: 14,
                color: theme.colorScheme.onSecondaryContainer.withAlpha(150),
              ),
            )
        ],
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FriendOnlineStatusIndicator(userStatus: friend.userStatus),
          const SizedBox(
            width: 4,
          ),
          Text(toBeginningOfSentenceCase(friend.userStatus.onlineStatus.name) ??
              "Unknown"),
          if (!friend.userStatus.currentSession.isNone) ...[
            const Text(" in "),
            Expanded(
                child: FormattedText(
              friend.userStatus.currentSession.formattedName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ))
          ]
        ],
      ),
      onLongPress: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return FriendDialog(friend: friend,);
          },
        );
      },
      onTap: () async {
        onTap?.call();
        final mClient = Provider.of<MessagingClient>(context, listen: false);
        mClient.loadUserMessageCache(friend.id);
        final unreads = mClient.getUnreadsForFriend(friend);
        if (unreads.isNotEmpty) {
          final readBatch = MarkReadBatch(
            senderId: friend.id,
            ids: unreads.map((e) => e.id).toList(),
            readTime: DateTime.now(),
          );
          mClient.markMessagesRead(readBatch);
        }
        mClient.selectedFriend = friend;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider<MessagingClient>.value(
              value: mClient,
              child: const MessagesList(),
            ),
          ),
        );
        mClient.selectedFriend = null;
      },
    );
  }
}
