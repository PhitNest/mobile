import 'package:flutter/material.dart';

class ReportUserButton extends StatelessWidget {
  final String firstName;
  final String lastName;
  final void Function(String reason) onReportSubmitted;

  const ReportUserButton({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.onReportSubmitted,
  });

  Future<void> _showReportDialog(BuildContext context) async {
    String reason = '';
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Report $firstName $lastName',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Colors.white),
        ),
        content: TextField(
          onChanged: (value) => reason = value,
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
              onReportSubmitted(reason);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
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
