import 'package:flutter/material.dart';
import 'package:flutter_github_desktop/src/assigned.issues.list.dart';
import 'package:flutter_github_desktop/src/pull.request.list.dart';
import 'package:flutter_github_desktop/src/repository.list.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:http/http.dart' as http;

class GitHubSummary extends StatefulWidget {
  GitHubSummary({@required http.Client client})
      : _link = HttpLink(
    'https://api.github.com/graphql',
    httpClient: client,
  );
  final HttpLink _link;
  @override
  _GitHubSummaryState createState() => _GitHubSummaryState();
}

class _GitHubSummaryState extends State<GitHubSummary> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          labelType: NavigationRailLabelType.selected,
          destinations: [
            NavigationRailDestination(
              icon: Icon(Octicons.repo),
              label: Text('Repositories'),
            ),
            NavigationRailDestination(
              icon: Icon(Octicons.issue_opened),
              label: Text('Assigned Issues'),
            ),
            NavigationRailDestination(
              icon: Icon(Octicons.git_pull_request),
              label: Text('Pull Requests'),
            ),
          ],
        ),
        VerticalDivider(thickness: 1, width: 1),
        // This is the main content.
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              RepositoriesList(link: widget._link),
              AssignedIssuesList(link: widget._link),
              PullRequestsList(link: widget._link),
            ],
          ),
        ),
      ],
    );
  }
}