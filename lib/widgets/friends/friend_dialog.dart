import 'package:contacts_plus_plus/models/session.dart';
import 'package:contacts_plus_plus/models/users/friend.dart';
import 'package:contacts_plus_plus/string_formatter.dart';
import 'package:contacts_plus_plus/widgets/formatted_text.dart';
import 'package:contacts_plus_plus/widgets/friends/friend_online_status_indicator.dart';
import 'package:contacts_plus_plus/widgets/sessions/session_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../auxiliary.dart';
import '../generic_avatar.dart';

class FriendDialog extends StatefulWidget {
  const FriendDialog({Key? key, required this.friend}) : super(key: key);

  final Friend friend;
  @override
  _FriendDialogState createState() => _FriendDialogState();
}

class _FriendDialogState extends State<FriendDialog> {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final user = widget.friend;
    DateFormat dateFormat = DateFormat.yMd();
    return Dialog(
      elevation: 3,
      child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.username, style: tt.headlineMedium),
                      Text(
                        user.id,
                        style: tt.labelMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(150)),
                      )
                    ],
                  ),
                  GenericAvatar(
                    imageUri: Aux.neosDbToHttp(user.userProfile.iconUrl),
                    radius: 24,
                  )
                ],
              ),

              Divider(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Online Status:"),
                  Row(children: [
                    FriendOnlineStatusIndicator(userStatus: user.userStatus),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Text(toBeginningOfSentenceCase(
                                user.userStatus.onlineStatus.name) ??
                            "Unknown"))
                  ])
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Output Device:"),
                  if (user.id == "U-Neos")
                    const Text("Neos Bot")
                  else
                    Text(toBeginningOfSentenceCase(
                            user.userStatus.outputDevice) ??
                        "Unknown")
                ],
              ),
              if (!user.userStatus.currentSession.isNone)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Current Session:"),
                    Expanded(
                      child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => SessionView(session: user.userStatus.currentSession)));
                          },
                          child: FormattedText(
                              user.userStatus.currentSession.formattedName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right)),
                    )
                  ],
                ),
              if (!user.userStatus.currentSession.isNone)
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Current Session Access Level: "),
                  Text(toBeginningOfSentenceCase(user.userStatus.currentSession.accessLevel.toReadableString())??"Unknown")
                ],),

              // Footere
              if (user.id != "U-Neos")
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("Neos Version: ",
                            style: tt.labelSmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(150))),
                        if (user.userStatus.neosVersion != "")
                          Text(user.userStatus.neosVersion,
                              style: tt.labelSmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(150)))
                      ],
                    )),
            ],
          )),
    );
  }
}
