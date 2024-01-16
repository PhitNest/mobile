import 'package:amazon_cognito_identity_dart_2/cognito.dart';

import '../../config/aws.dart';
import 'secure_storage.dart';

export 'change_password/change_password.dart';
export 'confirm_email.dart';
export 'forgot_password/forgot_password.dart';
export 'login/login.dart';
export 'logout.dart';
export 'refresh_session/refresh_session.dart';
export 'register/register.dart';
export 's3.dart';
export 'secure_storage.dart';
export 'session.dart';

CognitoUserPool userPool = CognitoUserPool(
  kUserPoolId,
  kClientId,
  storage: SecureCognitoStorage(),
);
