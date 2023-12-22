import 'dart:io';

import 'package:cake/helper/printer.dart';

import 'collector.dart';
import 'settings.dart';

class Runner {
  Runner._();
  static Runner runner = Runner._();
  factory Runner() => runner;

  Future<List<FileSystemEntity>> cakeFileList = _fetchFileList();

  static Future<List<FileSystemEntity>> _fetchFileList() {
    final Stream<FileSystemEntity> streamList =
        Directory.current.list(recursive: true);
    final Stream<FileSystemEntity> cakeStreamList = streamList.where((event) {
      final String filename = event.path.split('/').last;
      final bool cakeFile = filename.endsWith('.cake.dart');
      return cakeFile;
    });

    return cakeStreamList.toList();
  }

  Future<void> run(CakeSettings settings) async {
    bool runFlutter = true;
    final Collector collector = Collector();
    final List<FileSystemEntity> fileList = await cakeFileList;

    final Iterable<Future<void>> processes = fileList
        .where(
      (file) => settings.fileFilter != null
          ? file.path.contains(settings.fileFilter!)
          : true,
    )
        .map<Future<void>>((file) async {
      final List<String> processArgs = [];

      if (runFlutter) {
        processArgs.addAll([
          'test',
          file.path,
        ]);
      }

      // If we're filtering by a keyword, this needs to be passed via define
      processArgs.addAll(settings.testFilter.toProperties());

      if (!runFlutter) {
        processArgs.add(file.path);
      }

      // NEW CODE HERE ??
      Future<ProcessResult> process;
      if (runFlutter) {
        print(processArgs.join(' '));
        process = Process.run(
          'flutter',
          processArgs,
          workingDirectory: file.parent.path,
        );
      } else {
        process = Process.run('dart', processArgs);
      }

      return process.then((ProcessResult result) {
        if (result.stderr is String && result.stderr.isNotEmpty) {
          print(result.stderr);
        }
        final List<TestRunnerCollector> testRunnerCollectors =
            testRunnerOutputParser(result.stdout);
        for (TestRunnerCollector element in testRunnerCollectors) {
          collector.addCollector(element);
        }

        if (settings.verbose) {
          print('${collector.total} tests found...');
        }
      });
    });

    await Future.wait(processes);
    collector.printMessage(verbose: settings.verbose || settings.isVsCode);
    if (!settings.isVsCode) {
      Printer.neutral(''); // This makes sure to clear out any color changes
    }
    return;
  }
}
