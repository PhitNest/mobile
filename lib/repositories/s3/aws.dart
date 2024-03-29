import 'dart:convert';

import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/aws.dart';
import '../../entities/session/session.dart';
import '../../util/logger.dart';

const _s3host = 's3.$kRegion.amazonaws.com';
const _s3Endpoint = 'https://$kUserBucketName.$_s3host';

({Uri uri, Map<String, String> headers}) _getProfilePictureUri(
    AwsSession session, String identityId) {
  final key = '$kUserBucketName/profilePictures/$identityId';
  final payload = SigV4.hashCanonicalRequest('');
  final datetime = SigV4.generateDatetime();
  final canonicalRequest = '''GET
${'/$key'.split('/').map((s) => Uri.encodeComponent(s)).join('/')}

host:$_s3host
x-amz-content-sha256:$payload
x-amz-date:$datetime
x-amz-security-token:${session.credentials.sessionToken}

host;x-amz-content-sha256;x-amz-date;x-amz-security-token
$payload''';
  final credentialScope = SigV4.buildCredentialScope(datetime, kRegion, 's3');
  final stringToSign = SigV4.buildStringToSign(
      datetime, credentialScope, SigV4.hashCanonicalRequest(canonicalRequest));
  final signingKey = SigV4.calculateSigningKey(
      session.credentials.secretAccessKey!, datetime, kRegion, 's3');
  final signature = SigV4.calculateSignature(signingKey, stringToSign);

  final authorization = [
    'AWS4-HMAC-SHA256 Credential=${session.credentials.accessKeyId}/$credentialScope',
    'SignedHeaders=host;x-amz-content-sha256;x-amz-date;x-amz-security-token',
    'Signature=$signature',
  ].join(',');

  final uri = Uri.https(_s3host, key);
  return (
    uri: uri,
    headers: {
      'Authorization': authorization,
      'x-amz-content-sha256': payload,
      'x-amz-date': datetime,
      'x-amz-security-token': session.credentials.sessionToken!,
    }
  );
}

Future<Image?> getProfilePicture(AwsSession session, String identityId) async {
  final uri = _getProfilePictureUri(session, identityId);
  try {
    final res = await http.get(uri.uri, headers: uri.headers);
    if (res.statusCode == 200) {
      return Image.memory(res.bodyBytes);
    } else {
      error('Failed to get profile picture', details: [
        'Status code: ${res.statusCode}',
        'Response body: ${res.body}',
      ]);
      return null;
    }
  } catch (e) {
    error('Failed to get profile picture', details: ['Error: ${e.toString()}']);
    return null;
  }
}

Future<String?> uploadProfilePicture({
  required http.ByteStream photo,
  required int length,
  required AwsSession session,
  required String identityId,
}) async {
  try {
    final bucketKey = 'profilePictures/$identityId';
    final uri = Uri.parse(_s3Endpoint);
    final req = http.MultipartRequest('POST', uri);
    final multipartFile = http.MultipartFile(
      'file',
      photo,
      length,
    );
    final accessKeyId = session.credentials.accessKeyId!;
    final datetime = SigV4.generateDatetime();
    final expiration = (DateTime.now())
        .add(const Duration(minutes: 15))
        .toUtc()
        .toString()
        .split(' ')
        .join('T');
    final cred =
        '$accessKeyId/${SigV4.buildCredentialScope(datetime, 'us-east-1', 's3')}';
    final key = SigV4.calculateSigningKey(
      session.credentials.secretAccessKey!,
      datetime,
      kRegion,
      's3',
    );

    final policy = base64.encode(utf8.encode('''{ 
  "expiration": "$expiration",
  "conditions": [
    {"bucket": "$kUserBucketName"},
    ["starts-with", "\$key", "$bucketKey"],
    ["content-length-range", 1, $length],
    {"x-amz-credential": "$cred"},
    {"x-amz-algorithm": "AWS4-HMAC-SHA256"},
    {"x-amz-date": "$datetime" },
    {"x-amz-security-token": "${session.credentials.sessionToken!}" }
  ]
}'''));

    final signature = SigV4.calculateSignature(key, policy);

    req.files.add(multipartFile);
    req.fields['key'] = bucketKey;
    req.fields['X-Amz-Credential'] = cred;
    req.fields['X-Amz-Algorithm'] = 'AWS4-HMAC-SHA256';
    req.fields['X-Amz-Date'] = datetime;
    req.fields['Policy'] = policy;
    req.fields['X-Amz-Signature'] = signature;
    req.fields['x-amz-security-token'] = session.credentials.sessionToken!;

    final res = await req.send();
    await for (String value in res.stream.transform(utf8.decoder)) {
      debug(value);
    }
    return null;
  } catch (e) {
    await logError('Error thrown while uploading picture',
        details: [
          'Identity ID: $identityId',
          'Error: ${e.toString()}',
        ],
        userId: session.user.username);
    return e.toString();
  }
}
