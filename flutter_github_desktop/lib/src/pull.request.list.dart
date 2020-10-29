import 'package:flutter/material.dart';
import 'package:flutter_github_desktop/src/query.exception.dart';
import 'package:gql_link/gql_link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_github_desktop/src/github_gql/github_queries.data.gql.dart';
import 'package:flutter_github_desktop/src/github_gql/github_queries.req.gql.dart';

class PullRequestsList extends StatefulWidget {
  const PullRequestsList({@required this.link});
  final Link link;
  @override
  _PullRequestsListState createState() => _PullRequestsListState(link: link);
}

class _PullRequestsListState extends State<PullRequestsList> {
  _PullRequestsListState({@required Link link}) {
    _pullRequests = _retrievePullRequests(link);
  }
  Future<List<$PullRequests$viewer$pullRequests$edges$node>> _pullRequests;

  Future<List<$PullRequests$viewer$pullRequests$edges$node>>
  _retrievePullRequests(Link link) async {
    var result = await link.request(PullRequests((b) => b..count = 100)).first;
    if (result.errors != null && result.errors.isNotEmpty) {
      throw QueryException(result.errors);
    }
    return $PullRequests(result.data)
        .viewer
        .pullRequests
        .edges
        .map((e) => e.node)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<$PullRequests$viewer$pullRequests$edges$node>>(
      future: _pullRequests,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var pullRequests = snapshot.data;
        return ListView.builder(
          itemBuilder: (context, index) {
            var pullRequest = pullRequests[index];
            return ListTile(
              title: Text('${pullRequest.title}'),
              subtitle: Text('${pullRequest.repository.nameWithOwner} '
                  'PR #${pullRequest.number} '
                  'opened by ${pullRequest.author.login} '
                  '(${pullRequest.state.value.toLowerCase()})'),
              onTap: () => _launchUrl(context, pullRequest.url.value),
            );
          },
          itemCount: pullRequests.length,
        );
      },
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Navigation error'),
          content: Text('Could not launch $url'),
          actions: <Widget>[
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }
}