import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

const int kSuccess = 0;
const int kWarnings = 1;
const int kErrors = 2;

const String helpFlag = 'help';
const String outputOption = 'output';

void main(List<String> arguments) {
  final ArgParser parser = ArgParser()
    ..addFlag(
      helpFlag,
      abbr: helpFlag[0],
      help: 'Display this message',
      negatable: false,
    )
    ..addOption(
      outputOption,
      abbr: outputOption[0],
      help: 'Output filename',
    );
  ArgResults argResults;

  try {
    argResults = parser.parse(arguments);
  } catch (exception) {
    stderr.write('error: ${exception.message}');
    exit(kErrors);
  }

  if (argResults[helpFlag] as bool) {
    stdout.write('Usage: [options] [input-file]\n\n');
    stdout.write('Converts input-file into manageable Dart source code\n\n');
    stdout.write('Options:\n');
    stdout.write(parser.usage);
    exit(kSuccess);
  }

  if (argResults.rest.isEmpty) {
    stderr.write('error: Please specifiy the location of the binary file to convert');
    exit(kErrors);
  }

  final String inputFilename = argResults.rest.single;

  String outputFilename;
  if (argResults[outputOption] != null) {
    outputFilename = argResults[outputOption] as String;
    if (path.extension(outputFilename) != '.dart') {
      stderr.write("error: Output file must have a '.dart' extension");
      exit(kErrors);
    }
  } else {
    outputFilename =
        path.setExtension(path.basename(inputFilename), '.dart').toLowerCase();
  }

  final File inputFile = File(inputFilename);
  IOSink sink;
  try {
    stdout.writeln("Reading file '$inputFilename'...");
    final Uint8List binData = inputFile.readAsBytesSync();

    final File outputFile = File(outputFilename);
    sink = outputFile.openWrite();
    sink.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    sink.writeln('final List<int> data = <int> [');
    for (int i = 0; i < binData.buffer.lengthInBytes; i++) {
      sink.writeln('0x${binData[i].toRadixString(16).toUpperCase().padLeft(2, '0')},');
    }
    sink.writeln('];');
  } catch (e) {
    stderr.write('error: ${e.message}');
    exit(kErrors);
  } finally {
    sink.close();
  }
}
