// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:lenovo_clock/clock_face.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'package:weather_icons/weather_icons.dart';

import 'container_hand.dart';
import 'drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class LenovoClock extends StatefulWidget {
  const LenovoClock(this.model);

  final ClockModel model;

  @override
  _LenovoClockState createState() => _LenovoClockState();
}

class _LenovoClockState extends State<LenovoClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _weatherConditionString = '';
  var _weatherCondition;
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(LenovoClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange =
          '${widget.model.lowString} - ${widget.model.highString}';
      _weatherConditionString = widget.model.weatherString;
      _location = widget.model.location;
      _weatherCondition = widget.model.weatherCondition;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

//  cloudy,
//  foggy,
//  rainy,
//  snowy,
//  sunny,
//  thunderstorm,
//  windy,
  IconData weatherIconData() {
    switch (_weatherCondition) {
      case WeatherCondition.cloudy:
        return WeatherIcons.cloudy;

      case WeatherCondition.foggy:
        return WeatherIcons.fog;
      case WeatherCondition.rainy:
        return WeatherIcons.rain;

      case WeatherCondition.thunderstorm:
        return WeatherIcons.thunderstorm;

      case WeatherCondition.sunny:
        return WeatherIcons.day_sunny;

      case WeatherCondition.windy:
        return WeatherIcons.windy;

      default:
        return WeatherIcons.na;
    }
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFF4285F4),
            // Minute hand.
            highlightColor: Color(0xFF8AB4F8),
            // Second hand.
            accentColor: Color(0xFF669DF6),
            backgroundColor: Color(0xFFD2E3FC).withOpacity(0.5),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFF4285F4),
            accentColor: Color(0xFF8AB4F8),
            backgroundColor: Color(0xFF3C4043),
          );

    final time = DateFormat.Hms().format(DateTime.now());
    final timeAMPM = DateFormat.jm().format(DateTime.now());
    final weekday = DateFormat.EEEE().format(DateTime.now());
    final dateFormed = DateFormat.yMMMd().format(DateTime.now());

    final weatherInfo = DefaultTextStyle(
      style: TextStyle(color: customTheme.primaryColor, fontSize: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(_location),
          SizedBox(
            height: 5,
          ),
          Text(
            _weatherConditionString.toUpperCase(),
          ),
          Icon(
            weatherIconData(),
            color: customTheme.primaryColor,
            size: 100,
          ),
          SizedBox(
            height: 40,
          ),
          Text(
            _temperature,
            style: TextStyle(fontSize: 80),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.arrow_drop_down,
                size: 30,
                color: Theme.of(context).accentColor,
              ),
              Text(_temperatureRange),
              Icon(
                Icons.arrow_drop_up,
                size: 30,
                color: Theme.of(context).accentColor,
              ),
            ],
          ),
        ],
      ),
    );

    final digiClockNWeekday = Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height / 7,
        bottom: MediaQuery.of(context).size.height / 7,
      ),
      child: DefaultTextStyle(
        style: TextStyle(
            color: customTheme.accentColor,
            fontSize: 80,
            fontFamily: "Roboto",
            fontWeight: FontWeight.bold),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  timeAMPM,
                  style: TextStyle(
                    fontSize: 80,
                  ),
                )
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
//              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  weekday.toUpperCase(),
                  style: TextStyle(
                    fontSize: 50,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );

    var day = DateTime.now().day;
    var month = DateFormat("MMMM y").format(DateTime.now());
    final dateInfo = Material(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(
              color: Theme.of(context).primaryColor.withOpacity(0.5))),
      elevation: 7,
      child: DefaultTextStyle(
        style: TextStyle(
          color: customTheme.primaryColor,
          fontSize: 40,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
            "$day",
            style: TextStyle(fontSize: 150),
          ),
          Divider(color: Theme.of(context).accentColor,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              month,
              textAlign: TextAlign.center,
            ),
          ),
        ]),
      ),
    );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: dateInfo,
                  ),
//                  Padding(
//                    padding: const EdgeInsets.all(8),
//                    child: temperature,
//                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: weatherInfo,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // clock face
                  ClockFace(),

                  ContainerHand(
                    color: Colors.transparent,
                    size: 0.6,
                    angleRadians: _now.hour * radiansPerHour +
                        (_now.minute / 60) * radiansPerHour,
                    child: Transform.translate(
                      offset: Offset(0.0, -100.0),
                      child: Container(
                        width: 25,
                        height: 250,
                        decoration: BoxDecoration(
                            color: customTheme.primaryColor,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),

                  DrawnHand(
                    color: customTheme.highlightColor,
                    thickness: 16,
                    size: 0.85,
                    angleRadians: _now.minute * radiansPerTick,
                  ),
                  DrawnHand(
                    color: customTheme.accentColor,
                    thickness: 4,
                    size: .9,
                    angleRadians: _now.second * radiansPerTick,
                  ),

                  //Center Point
                  new Center(
                    child: new Container(
                      width: 30.0,
                      height: 30.0,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),

                  // Digital clock
                  Center(
                    child: digiClockNWeekday,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
