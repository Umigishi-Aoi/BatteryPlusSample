import 'dart:async';

import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Battery Plus Demo',
      home: BatteryPage(title: 'Battery Plus Demo'),
    );
  }
}

class BatteryPage extends StatefulWidget {
  const BatteryPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _BatteryPageState createState() => _BatteryPageState();
}

class _BatteryPageState extends State<BatteryPage> {
  //バッテリーのインスタンスを取得
  final Battery _battery = Battery();

  //バッテリーの状態(充電中等)をStateとして保持
  BatteryState? _batteryState;
  //StreamSubscriptionで監視する（初期化はinitStateで行う）
  StreamSubscription<BatteryState>? _batteryStateSubscription;

  @override
  void initState() {
    super.initState();
    //Batteryの状態の変化を検知し、setStateするように設定
    _batteryStateSubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) {
          setState(() {
            _batteryState = state;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            //バッテリーの状態を表示
            Text('$_batteryState'),
            ElevatedButton(
              onPressed: () async {
                //充電残量の取得
                final batteryLevel = await _battery.batteryLevel;
                showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    content: Text('Battery: $batteryLevel%'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      )
                    ],
                  ),
                );
              },
              child: const Text('Get battery level'),
            ),
            ElevatedButton(
                onPressed: () async {
                  //パワーセーブモードか否かの取得
                  final isInPowerSaveMode = await _battery.isInBatterySaveMode;
                  showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      content: Text('Is on low power mode: $isInPowerSaveMode'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                },
                child: const Text('Is on low power mode'))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    //Subscriptionのストップ
    if (_batteryStateSubscription != null) {
      _batteryStateSubscription!.cancel();
    }
  }
}