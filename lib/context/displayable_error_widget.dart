part of '../cake_flutter.dart';

class DisplayableErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;
  final String? fontFamily;

  const DisplayableErrorWidget(this.details, {this.fontFamily, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.red,
          child: Center(
            child: Text(
              details.exceptionAsString(),
              style: TextStyle(
                fontFamily: fontFamily ?? 'Roboto',
                fontSize: 18,
                color: Colors.yellow[100],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
