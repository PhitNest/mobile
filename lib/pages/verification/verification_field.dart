part of 'verification.dart';

final class _VerificationField extends StatelessWidget {
  final _VerificationControllers controllers;
  final VoidCallback onCompleted;

  const _VerificationField({
    required this.controllers,
    required this.onCompleted,
  }) : super();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 280,
        child: PinCodeTextField(
          appContext: context,
          length: 6,
          validator: (code) => code!.length == 6 ? null : '',
          onChanged: (_) {},
          onCompleted: (_) => onCompleted(),
          textStyle: theme.textTheme.bodyLarge,
          controller: controllers.codeController,
          focusNode: controllers.focusNode,
          autoDisposeControllers: false,
          keyboardType: TextInputType.number,
          pinTheme: PinTheme(
            activeColor: Colors.grey.shade600,
            selectedColor: Colors.grey.shade600,
            inactiveColor: Colors.grey.shade400,
            fieldWidth: 40,
          ),
        ),
      );
}
