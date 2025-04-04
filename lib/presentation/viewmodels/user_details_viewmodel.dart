import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDetailsViewModel {
  Future<void> launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch the URL: $urlString';
    }
  }

  void showErrorSnackbar(BuildContext context, String message) {
    log('URL launch error: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to open support website'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
