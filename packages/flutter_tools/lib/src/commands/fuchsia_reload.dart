// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import '../base/common.dart';
import '../base/file_system.dart';
import '../base/io.dart';
import '../base/platform.dart';
import '../base/utils.dart';
import '../cache.dart';
import '../device.dart';
import '../flx.dart' as flx;
import '../fuchsia/fuchsia_device.dart';
import '../globals.dart';
import '../run_hot.dart';
import '../runner/flutter_command.dart';
import '../vmservice.dart';

// Usage:
// With e.g. flutter_gallery already running, a HotRunner can be attached to it
// with:
// $ flutter fuchsia_reload -f ~/fuchsia -a 192.168.1.39 \
//       -g //lib/flutter/examples/flutter_gallery:flutter_gallery

class FuchsiaReloadCommand extends FlutterCommand {
  FuchsiaReloadCommand() {
    addBuildModeFlags(defaultToRelease: false);
    argParser.addOption('address',
      abbr: 'a',
      help: 'Fuchsia device network name or address.');
    argParser.addOption('build-type',
      abbr: 'b',
      defaultsTo: 'release-x86-64',
      help: 'Fuchsia build type, e.g. release-x86-64.');
    argParser.addOption('fuchsia-root',
      abbr: 'f',
      defaultsTo: platform.environment['FUCHSIA_ROOT'],
      help: 'Path to Fuchsia source tree.');
    argParser.addOption('gn-target',
      abbr: 'g',
      help: 'GN target of the application, e.g //path/to/app:app.');
    argParser.addFlag('list',
      abbr: 'l',
      defaultsTo: false,
      help: 'Lists the running modules. '
            'Requires the flags --address(-a) and --fuchsia-root(-f).');
    argParser.addOption('name-override',
      abbr: 'n',
      help: 'On-device name of the application binary.');
    argParser.addOption('isolate-number',
      abbr: 'i',
      help: 'To reload only one instance, speficy the isolate number, e.g. '
            'the number in foo\$main-###### given by --list.');
    argParser.addOption('target',
      abbr: 't',
      defaultsTo: flx.defaultMainPath,
      help: 'Target app path / main entry-point file. '
            'Relative to --gn-target path, e.g. lib/main.dart.');
  }

  @override
  final String name = 'fuchsia_reload';

  @override
  final String description = 'Hot reload on Fuchsia.';

  String _fuchsiaRoot;
  String _projectRoot;
  String _projectName;
  String _binaryName;
  String _isolateNumber;
  String _fuchsiaProjectPath;
  String _target;
  String _address;
  String _dotPackagesPath;

  bool _list;

  @override
  Future<Null> runCommand() async {
    Cache.releaseLockEarly();

    _validateArguments();

    // Find the network ports used on the device by VM service instances.
    final List<int> servicePorts = await _getServicePorts();
    if (servicePorts.isEmpty)
      throwToolExit('Couldn\'t find any running Observatory instances.');
    for (int port in servicePorts)
      printTrace('Fuchsia service port: $port');

    if (_list) {
      await _listViews(servicePorts);
      return;
    }

    // Check that there are running VM services on the returned
    // ports, and find the Isolates that are running the target app.
    final String isolateName = '$_binaryName\$main$_isolateNumber';
    final List<int> targetPorts = await _filterPorts(servicePorts, isolateName);
    if (targetPorts.isEmpty)
      throwToolExit('No VMs found running $_binaryName.');
    for (int port in targetPorts)
      printTrace('Found $_binaryName at $port');

    // Set up a device and hot runner and attach the hot runner to the first
    // vm service we found.
    final List<String> fullAddresses = targetPorts.map(
      (int p) => '$_address:$p'
    ).toList();
    final FuchsiaDevice device = new FuchsiaDevice(fullAddresses[0]);
    final HotRunner hotRunner = new HotRunner(
      device,
      debuggingOptions: new DebuggingOptions.enabled(getBuildMode()),
      target: _target,
      projectRootPath: _fuchsiaProjectPath,
      packagesFilePath: _dotPackagesPath
    );
    final List<Uri> observatoryUris =
      fullAddresses.map((String a) => Uri.parse('http://$a')).toList();
    printStatus('Connecting to $_binaryName');
    await hotRunner.attach(observatoryUris, isolateFilter: isolateName);
  }

  Future<List<FlutterView>> _getViews(List<int> ports) async {
    final List<FlutterView> views = <FlutterView>[];
    for (int port in ports) {
      final String addr = 'http://$_address:$port';
      final Uri uri = Uri.parse(addr);
      final VMService vmService = VMService.connect(uri);
      await vmService.getVM();
      await vmService.waitForViews();
      views.addAll(vmService.vm.views);
    }
    return views;
  }

  // Find ports where there is a view isolate with the given name
  Future<List<int>> _filterPorts(List<int> ports, String isolateFilter) async {
    final List<int> result = <int>[];
    for (FlutterView v in await _getViews(ports)) {
      final Uri addr = v.owner.vmService.httpAddress;
      printTrace('At $addr, found view: ${v.uiIsolate.name}');
      if (v.uiIsolate.name.indexOf(isolateFilter) == 0)
        result.add(addr.port);
    }
    return result;
  }

  Future<Null> _listViews(List<int> ports) async {
    const String bold = '\u001B[0;1m';
    const String reset = '\u001B[0m';
    for (FlutterView v in await _getViews(ports)) {
      final Uri addr = v.owner.vmService.httpAddress;
      final Isolate i = v.uiIsolate;
      final String name = i.name;
      final String shortName = name.substring(0, name.indexOf('\$'));
      final String main = '\$main-';
      final String number = name.substring(name.indexOf(main) + main.length);
      final String newUsed = getSizeAsMB(i.newSpace.used);
      final String newCap = getSizeAsMB(i.newSpace.capacity);
      final String newFreq = '${i.newSpace.avgCollectionTime.inMilliseconds}ms';
      final String newPer = '${i.newSpace.avgCollectionPeriod.inSeconds}s';
      final String oldUsed = getSizeAsMB(i.oldSpace.used);
      final String oldCap = getSizeAsMB(i.oldSpace.capacity);
      final String oldFreq = '${i.oldSpace.avgCollectionTime.inMilliseconds}ms';
      final String oldPer = '${i.oldSpace.avgCollectionPeriod.inSeconds}s';
      printStatus(
        '$bold$shortName$reset\n'
        '\tIsolate number: $number\n'
        '\tObservatory: $addr\n'
        '\tNew gen: $newUsed used of $newCap, GC: $newFreq every $newPer\n'
        '\tOld gen: $oldUsed used of $oldCap, GC: $oldFreq every $oldPer\n'
      );
    }
  }

  void _validateArguments() {
    _fuchsiaRoot = argResults['fuchsia-root'];
    if (_fuchsiaRoot == null)
      throwToolExit('Please give the location of the Fuchsia tree with --fuchsia-root.');
    if (!_directoryExists(_fuchsiaRoot))
      throwToolExit('Specified --fuchsia-root "$_fuchsiaRoot" does not exist.');

    _address = argResults['address'];
    if (_address == null)
      throwToolExit('Give the address of the device running Fuchsia with --address.');

    _list = argResults['list'];
    if (_list) {
      // For --list, we only need the device address and the Fuchsia tree root.
      return;
    }

    final String gnTarget = argResults['gn-target'];
    if (gnTarget == null)
      throwToolExit('Give the GN target with --gn-target(-g).');
    final List<String> targetInfo = _extractPathAndName(gnTarget);
    _projectRoot = targetInfo[0];
    _projectName = targetInfo[1];
    _fuchsiaProjectPath = '$_fuchsiaRoot/$_projectRoot';
    if (!_directoryExists(_fuchsiaProjectPath))
      throwToolExit('Target does not exist in the Fuchsia tree: $_fuchsiaProjectPath.');

    final String relativeTarget = argResults['target'];
    if (relativeTarget == null)
      throwToolExit('Give the application entry point with --target.');
    _target = '$_fuchsiaProjectPath/$relativeTarget';
    if (!_fileExists(_target))
      throwToolExit('Couldn\'t find application entry point at $_target.');

    final String buildType = argResults['build-type'];
    if (buildType == null)
      throwToolExit('Give the build type with --build-type.');
    final String packagesFileName = '${_projectName}_dart_package.packages';
    _dotPackagesPath = '$_fuchsiaRoot/out/$buildType/gen/$_projectRoot/$packagesFileName';
    if (!_fileExists(_dotPackagesPath))
      throwToolExit('Couldn\'t find .packages file at $_dotPackagesPath.');

    final String nameOverride = argResults['name-override'];
    if (nameOverride == null) {
      _binaryName = _projectName;
    } else {
      _binaryName = nameOverride;
    }

    final String isolateNumber = argResults['isolate-number'];
    if (isolateNumber == null) {
      _isolateNumber = '';
    } else {
      _isolateNumber = '-$isolateNumber';
    }
  }

  List<String> _extractPathAndName(String gnTarget) {
    final String errorMessage =
      'fuchsia_reload --target "$gnTarget" should have the form: '
      '"//path/to/app:name"';
    // Separate strings like //path/to/target:app into [path/to/target, app]
    final int lastColon = gnTarget.lastIndexOf(':');
    if (lastColon < 0)
      throwToolExit(errorMessage);
    final String name = gnTarget.substring(lastColon + 1);
    // Skip '//' and chop off after :
    if ((gnTarget.length < 3) || (gnTarget[0] != '/') || (gnTarget[1] != '/'))
      throwToolExit(errorMessage);
    final String path = gnTarget.substring(2, lastColon);
    return <String>[path, name];
  }

  Future<List<int>> _getServicePorts() async {
    final FuchsiaDeviceCommandRunner runner = new FuchsiaDeviceCommandRunner(_fuchsiaRoot);
    final List<String> lsOutput = await runner.run('ls /tmp/dart.services');
    final List<int> ports = <int>[];
    for (String s in lsOutput) {
      final String trimmed = s.trim();
      final int lastSpace = trimmed.lastIndexOf(' ');
      final String lastWord = trimmed.substring(lastSpace + 1);
      if ((lastWord != '.') && (lastWord != '..')) {
        final int value = int.parse(lastWord, onError: (_) => null);
        if (value != null)
          ports.add(value);
      }
    }
    return ports;
  }

  bool _directoryExists(String path) {
    final Directory d = fs.directory(path);
    return d.existsSync();
  }

  bool _fileExists(String path) {
    final File f = fs.file(path);
    return f.existsSync();
  }
}


// TODO(zra): When Fuchsia has ssh, this should be changed to use that instead.
class FuchsiaDeviceCommandRunner {
  final String _fuchsiaRoot;
  final Random _rng = new Random(new DateTime.now().millisecondsSinceEpoch);

  FuchsiaDeviceCommandRunner(this._fuchsiaRoot);

  Future<List<String>> run(String command) async {
    final int tag = _rng.nextInt(999999);
    const String kNetRunCommand = 'out/build-magenta/tools/netruncmd';
    final String netruncmd = fs.path.join(_fuchsiaRoot, kNetRunCommand);
    const String kNetCP = 'out/build-magenta/tools/netcp';
    final String netcp = fs.path.join(_fuchsiaRoot, kNetCP);
    final String remoteStdout = '/tmp/netruncmd.$tag';
    final String localStdout = '${fs.systemTempDirectory.path}/netruncmd.$tag';
    final String redirectedCommand = '$command > $remoteStdout';
    // Run the command with output directed to a tmp file.
    ProcessResult result =
        await Process.run(netruncmd, <String>[':', redirectedCommand]);
    if (result.exitCode != 0)
      return null;
    // Copy that file to the local filesystem.
    result = await Process.run(netcp, <String>[':$remoteStdout', localStdout]);
    // Try to delete the remote file. Don't care about the result;
    Process.run(netruncmd, <String>[':', 'rm $remoteStdout']);
    if (result.exitCode != 0)
      return null;
    // Read the local file.
    final File f = fs.file(localStdout);
    List<String> lines;
    try {
      lines = await f.readAsLines();
    } finally {
      f.delete();
    }
    return lines;
  }
}
