import 'dart:convert';
import 'package:impal_desktop/features/services/credentials/e_credit_credentials.dart';
import 'package:netbridge/netbridge.dart';

class EcreditRestletService {
  late NetsuiteClient client;

  EcreditRestletService() {
    init();
  }

  void init() async {
    Credentials credentials = Credentials(ecreditOAuthCredentials);
    RequestHandler handler = OAuthHandler(credentials: credentials);
    client = NetsuiteClient(handler: handler);
  }

  Future<dynamic> fetchReportData(
      String scriptId, Map<String, dynamic> requestBody) async {
    try {
      final encodedScriptId = Uri.encodeComponent(scriptId);
      final uri = Uri.parse(
          'https://8154332-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=$encodedScriptId&deploy=1');
          // 'https://8154332.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=$encodedScriptId&deploy=1');

      print('Requested Url : $uri');
      print('Script ID: $scriptId');
      print(json.encode(requestBody));

      final response = await client.post(uri,
          body: requestBody, headers: {'Content-Type': 'application/json'});

      print('Response Body for script ID from E-credit: $scriptId');
      print(response.body);

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          return json.decode(response.body);
        } else {
          print('API Connection Successful, but Empty response body received');
          return {};
        }
      } else {
        print('Failed to fetch report data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching Restlet data: $e');
      return null;
    }
  }

  Future<dynamic> postRequest(
    String scriptId,
    Map<String, dynamic> requestBody,
  ) async {
    try {
      final encodedScriptId = Uri.encodeComponent(scriptId);
      final uri = Uri.parse(
          // 'https://8154332.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=$encodedScriptId&deploy=1');
      'https://8154332-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=$encodedScriptId&deploy=1');

      print('Request URL for script ID from E-credit: $scriptId');
      print(uri);
      print('Request Body:');
      print(json.encode(requestBody));

      final response = await client.post(
        uri,
        body: requestBody,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Body for script ID: $scriptId');
      print(response.body);

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          if (response.body.trim().startsWith('{')) {
            final responseBody = json.decode(response.body);
            return responseBody;
          } else {
            print('Response: ${response.body}');
            return response.body;
          }
        } else {
          print('API Connection Successful, but Empty response body received');
          return {};
        }
      } else {
        print('Failed to post request: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error posting request: $e');
      return null;
    }
  }

  Future<dynamic> getRequest(
      String scriptId, Map<String, dynamic> queryParams) async {
    try {
      final encodedScriptId = Uri.encodeComponent(scriptId);

      final uri = Uri.parse(
          // 'https://8154332.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=$encodedScriptId&deploy=1');
      'https://8154332-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=$encodedScriptId&deploy=1');

      print('Request URL for script ID: $scriptId');
      print(uri);

      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Body for script ID: $scriptId');
      print(response.body);

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          print(response.body);
          return json.decode(response.body);
        } else {
          print('API Connection Successful, but Empty response body received');
          return {};
        }
      } else {
        print('Failed to fetch GET request: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error with GET request: $e');
      return null;
    }
  }

  void prettyprint(String str) {
    const JsonEncoder jEncoder = JsonEncoder.withIndent(" ");
    final jsonData = json.decode(str);
    print(jEncoder.convert(jsonData));
  }
}
