import 'package:ardrive/blocs/blocs.dart';
import 'package:ardrive/misc/misc.dart';
import 'package:ardrive/services/shared_prefs/shared_prefs.dart';
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/link.dart';

import 'profile_auth_shell.dart';

class ProfileAuthPromptWalletScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ProfileAuthShell(
        illustration: Image.asset(
          R.images.profile.profileWelcome,
          fit: BoxFit.contain,
        ),
        contentWidthFactor: 0.5,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'WELCOME TO',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(height: 32),
            Text(
              'Your private and secure, decentralized, pay-as-you-go, censorship-resistant and permanent hard drive.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              child: Text('SELECT WALLET'),
              onPressed: () => _pickWallet(context),
            ),
            const SizedBox(height: 16),
            Link(
              uri: Uri.parse('https://tokens.arweave.org'),
              target: LinkTarget.blank,
              builder: (context, followLink) => TextButton(
                onPressed: followLink,
                child: Text(
                  'Don\'t have a wallet? Get one here!',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder:
                  (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (snapshot.data.buildNumber == 'staging')
                          SwitchListTile(
                            title: Text('Toggle TestNet'),
                            value: SharedPrefsService().testnetEnabled,
                            onChanged: (value) =>
                                SharedPrefsService().toggleTestNet(value),
                          ),
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      );

  void _pickWallet(BuildContext context) async {
    final walletFile = await file_selector.openFile(acceptedTypeGroups: [
      file_selector.XTypeGroup(label: 'wallet keys', extensions: ['json'])
    ]);

    if (walletFile == null) {
      return;
    }

    await context
        .read<ProfileAddCubit>()
        .pickWallet(await walletFile.readAsString());
  }
}
