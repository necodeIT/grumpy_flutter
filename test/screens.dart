import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:grumpy_flutter/grumpy_flutter.dart';

class NotFoundScreen extends Screen {
  @override
  Widget buildContent(BuildContext context, RouteContext route) {
    return const Center(child: Text('404 - Not Found'));
  }

  @override
  Widget buildPreview(BuildContext context, RouteContext route) =>
      buildContent(context, route);
}

class DummyScreen extends Screen {
  final String? title;

  DummyScreen(this.title);

  @override
  Widget buildContent(BuildContext context, RouteContext route) {
    return Center(child: Text('Content\ntitle: $title, route: $route'));
  }

  @override
  Widget buildPreview(BuildContext context, RouteContext route) {
    return Center(child: Text('Preview\ntitle: $title, route: $route'));
  }
}
