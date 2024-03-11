import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/colors/colors.dart';

class SideDrawer extends ConsumerStatefulWidget {
  const SideDrawer({super.key});

  @override
  ConsumerState<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends ConsumerState<SideDrawer> {
  String IPv4 = 'undefined';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String name = 'User';
    return SafeArea(
        child: Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
              accountName: Text(
                name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              accountEmail: SelectableText(
                IPv4,
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300),
              )),
          // ListTile(
          //   onTap: () {
          //     // Navigator.push(context, MaterialPageRoute(builder: (ctx)=> ChangePort(ports: options)));
          //     showDialog(
          //         context: context,
          //         builder: (ctx) => ChangePort(
          //               ports: options,
          //               currentPort: port,
          //             ));
          //   },
          //   leading: const Icon(Icons.lan),
          //   title: RichText(
          //     text: TextSpan(
          //         text: 'Current Port: ',
          //         style: TextStyle(
          //             color: MyColors().textColor2,
          //             fontSize: 18,
          //             fontWeight: FontWeight.w500),
          //         children: [
          //           TextSpan(
          //             text: '$port',
          //             style: TextStyle(
          //                 fontWeight: FontWeight.w500,
          //                 color: MyColors().textColor2,
          //                 fontSize: 18,
          //                 fontStyle: FontStyle.italic),
          //           ),
          //         ]),
          //   ),
          // ),
          ListTile(
            onTap: () {},
            leading: const Icon(Icons.schedule),
            title: RichText(
              text: TextSpan(
                text: 'Edit Schedule',
                style: TextStyle(
                    color: MyColors().textColor2,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          ListTile(
            onTap: () {},
            leading: const Icon(Icons.share),
            title: RichText(
              text: TextSpan(
                text: 'Share',
                style: TextStyle(
                    color: MyColors().textColor2,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              // showDialog(
              //     barrierDismissible: false,
              //     context: context,
              //     builder: (ctx) => const GiveFeedback());
            },
            leading: const Icon(Icons.feedback),
            title: RichText(
              text: TextSpan(
                text: 'Give Feedback',
                style: TextStyle(
                    color: MyColors().textColor2,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          // ListTile(
          //   onTap: () {},
          //   leading: const Icon(Icons.bug_report),
          //   title: RichText(
          //     text: TextSpan(
          //       text: 'Report a bug',
          //       style: TextStyle(
          //           color: MyColors().textColor2,
          //           fontSize: 18,
          //           fontWeight: FontWeight.w500),
          //     ),
          //   ),
          // ),
          ListTile(
            onTap: () {},
            leading: const Icon(Icons.help),
            title: RichText(
              text: TextSpan(
                text: 'About Us',
                style: TextStyle(
                    color: MyColors().textColor2,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
