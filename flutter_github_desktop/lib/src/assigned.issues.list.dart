import 'package:flutter/material.dart';
import 'package:flutter_github_desktop/src/query.exception.dart';
import 'package:gql_link/gql_link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_github_desktop/src/github_gql/github_queries.data.gql.dart';
import 'package:flutter_github_desktop/src/github_gql/github_queries.req.gql.dart';

class AssignedIssuesList extends StatefulWidget {
  const AssignedIssuesList({@required this.link});
  final Link link;
  @override
  _AssignedIssuesListState createState() =>
      _AssignedIssuesListState(link: link);
}

class _AssignedIssuesListState extends State<AssignedIssuesList> {
  _AssignedIssuesListState({@required Link link}) {
    _assignedIssues = _retrieveAssignedIssues(link);
  }

  Future<List<$AssignedIssues$search$edges$node$asIssue>> _assignedIssues;

  Future<List<$AssignedIssues$search$edges$node$asIssue>>
  _retrieveAssignedIssues(Link link) async {
    var result = await link
        .request(ViewerDetail((b) => b))
        .first;
    if (result.errors != null && result.errors.isNotEmpty) {
      throw QueryException(result.errors);
    }
    var _viewer = $ViewerDetail(result.data).viewer;

    result = await link
        .request(AssignedIssues((b) =>
    b
      ..count = 100
      ..query = 'is:open assignee:${_viewer.login} archived:false'))
        .first;
    if (result.errors != null && result.errors.isNotEmpty) {
      throw QueryException(result.errors);
    }
    return $AssignedIssues(result.data)
        .search
        .edges
        .map((e) => e.node)
        .whereType<$AssignedIssues$search$edges$node$asIssue>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<$AssignedIssues$search$edges$node$asIssue>>(
      future: _assignedIssues,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var assignedIssues = snapshot.data;
        return ListView.builder(
          itemBuilder: (context, index) {
            var assignedIssue = assignedIssues[index];
            return ListTile(
              title: Text('${assignedIssue.title}'),
              subtitle: Text('${assignedIssue.repository.nameWithOwner} '
                  'Issue #${assignedIssue.number} '
                  'opened by ${assignedIssue.author.login}'),
              onTap: () => _launchUrl(context, assignedIssue.url.value),
            );
          },
          itemCount: assignedIssues.length,
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
        builder: (context) =>
            AlertDialog(
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
