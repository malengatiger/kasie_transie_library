import 'package:country_calling_code_picker/country.dart' as cd;
import 'package:country_calling_code_picker/country_code_picker.dart' as cc;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../bloc/list_api_dog.dart';
import '../../data/data_schemas.dart';
import '../../utils/functions.dart';

class CountryUi extends StatefulWidget {
  const CountryUi({super.key});

  @override
  State<CountryUi> createState() => _CountryUiState();
}

class _CountryUiState extends State<CountryUi> {

  static const mm = ' 🦠 🦠 🦠 CountryUi  🦠';
  cd.Country? country;
  List<Country> countries = [];
  ListApiDog dog = GetIt.instance<ListApiDog>();
@override
  void initState() {
  super.initState();
  _start();
}

  void _start() async {
    countries = await dog.getCountries();
    pp('$mm countries found: ${countries.length}');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Country'),
      ),
      body: Container(
        child: cc.CountryPickerWidget(
          onSelected: (c) {
            Country? found;
            for (var value in countries) {
              if (value.name == c.name) {
                found = value;
                Navigator.pop(context, found);
              }
            }
          },
        ),
      ),
    );
  }
}
