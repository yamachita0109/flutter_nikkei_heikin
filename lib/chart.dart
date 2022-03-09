import 'dart:convert';

import 'package:charts_common/common.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chart extends StatefulWidget {
  const Chart({Key? key}) : super(key: key);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  late List<dynamic>? response = null;

  getData() async {
    final parameters = {
      'api_key': 'TL5ukBpapkqjs1Gxiuy-',
      'start_date': '2021-01-01',
      'end_date': '2021-03-31',
    };
    final url = Uri.https('www.quandl.com', '/api/v3/datasets/CHRIS/CME_NK2/data.json', parameters);
    final result = await http.get(url);
    setState(() {
      response = json.decode(result.body)['dataset_data']['data'];
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日経平均'),
        backgroundColor: Colors.orange
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("2021-01-01 ~ 2021-03-31 日足"),
            Expanded(flex: 1,
                child: Card(
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        child: response == null ? null : createChart(response!), // const CircularProgressIndicator()
                    )
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget createChart(List<dynamic> response) {
    List<TimeSeriesSales> data = [];
    for (var element in response) {
      List date = element[0].split('-');
      final settle = element[6];
      data.add(TimeSeriesSales(DateTime(int.parse(date[0]), int.parse(date[1]), int.parse(date[2])), settle));
    }

    List<Series<TimeSeriesSales, DateTime>> seriesList = [
      charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      )
    ];

    return charts.TimeSeriesChart(
      seriesList,
      animate: false,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }
}

class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}