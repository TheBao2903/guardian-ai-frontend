import 'package:flutter/material.dart';

import '../../../../shared/extensions/context_extensions.dart';
import '../../../home/presentation/widgets/danger_alert_sheet.dart';

/// Pending SOS is a real route, before any emergency notification is sent.
class SosConfirmationScreen extends StatelessWidget {
  const SosConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
            title: Text(context.l10n.sosConfirmationTitle),
            automaticallyImplyLeading: false),
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: const DangerAlertSheet(closeOnDismiss: false),
            ),
          ),
        ),
      ),
    );
  }
}
