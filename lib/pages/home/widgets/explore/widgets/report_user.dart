import 'package:flutter/material.dart';

class ReportUserButton extends StatelessWidget {
  final String firstName;
  final String lastName;
  final VoidCallback onReportSubmitted;

  const ReportUserButton({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.onReportSubmitted,
  });

  Future<void> _showReportDialog(BuildContext context) async {
    final TextEditingController reportReasonController =
        TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Report $firstName $lastName',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Colors.white),
          ),
          content: TextField(
            controller: reportReasonController,
            decoration:
                const InputDecoration(hintText: 'Enter reason for reporting'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Report'),
              onPressed: () {
                // Placeholder for your report submission logic
                onReportSubmitted();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    reportReasonController.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => _showReportDialog(context),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.85),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.report_problem,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      );
}