import 'aws.dart';

Future<void> logout(Session session) => Future.wait(
    [session.user.signOut(), session.credentials.resetAwsCredentials()]);

Future<bool> deleteAccount(Session session) => session.user.deleteUser();
