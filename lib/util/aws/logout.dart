import 'aws.dart';

Future<void> logout(Session session) => session.credentials
    .resetAwsCredentials()
    .then((_) => session.user.signOut());

Future<bool> deleteAccount(Session session) => session.credentials
    .resetAwsCredentials()
    .then((_) => session.user.deleteUser());
