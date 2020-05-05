import 'package:graphql/client.dart';

class GraphRepo {
  final String token;

  final HttpLink httpLink = HttpLink(uri: 'https://api.github.com/graphql');

  AuthLink get authLink => AuthLink(getToken: () => 'Bearer $token');

  Link get _link => authLink.concat(httpLink);

  GraphQLClient get _client => GraphQLClient(
        cache: InMemoryCache(),
        link: _link,
      );

  GraphRepo(this.token);

  Future<int> sponsorsCount(String username) async {
    final query = '''
      {
        user(login: "$username") {
          sponsorshipsAsMaintainer {
            totalCount
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: query,
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw result.exception;
    }

    return result.data['user']['sponsorshipsAsMaintainer']['totalCount'];
  }
}
