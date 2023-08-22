import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:intl_phone_field/countries.dart' as cc;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CountryList extends StatefulWidget {
  const CountryList({Key? key}) : super(key: key);

  @override
  State<CountryList> createState() => _CountryListState();
}

class _CountryListState extends State<CountryList> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  String? _countryCode;
  cc.Country? country;
  static const mm = '💦💦💦💦CountryList: ';
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _countryCode = await FlutterSimCountryCode.simCountryCode;
      pp('....................... _countryCode: $_countryCode');
      for (var value in cc.countries) {
        if (value.code == _countryCode) {
          setState(() {
            country = value;
          });
        }
      }
    } on PlatformException {
      _countryCode = 'Failed to get sim country code.';
    }
    if (!mounted) return;

    setState(() {});
  }

  TextEditingController searchController = TextEditingController();
  ItemScrollController scrollController = ItemScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController = ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener = ScrollOffsetListener.create();

  void _scrollTo(String text) {
    pp('... _scrollTo $text');
    int index = 0;
    for (var value in cc.countries) {
      if (value.name.toLowerCase().contains(text.toLowerCase())) {
        pp('$mm ... scroll to : $index');
        //scroll to index
        itemScrollController.scrollTo(
            index: index,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic);
      }
      index++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Country Selection'),
      ),
      body: Column(
        children: [
          Text(
            'Countries',
            style: myTextStyleMediumLargeWithColor(
                context, Theme.of(context).primaryColor, 20),
          ),
          gapH32,
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search),
              gapW16,
              SizedBox(width: 200,
                child: SearchBar(
                  controller: searchController,
                  onChanged: (text) {
                    _scrollTo(text);
                  },
                ),
              ),
            ],
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ScrollablePositionedList.builder(
                itemCount: cc.countries.length,
                itemScrollController: itemScrollController,
                scrollOffsetController: scrollOffsetController,
                itemPositionsListener: itemPositionsListener,
                scrollOffsetListener: scrollOffsetListener,
                itemBuilder: (ctx, index) {
                  final value = cc.countries.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(value);
                    },
                    child: Card(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Text(
                              value.flag,
                              style: const TextStyle(fontSize: 20),
                            ),
                            gapW8,
                            SizedBox(
                                width: 48,
                                child: Text(
                                  '+${value.dialCode}',
                                  style: myTextStyleSmall(context),
                                )),
                            gapW32,
                            Flexible(
                                child: Text(value.name,
                                    style: myTextStyleSmall(context))),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          )),
        ],
      ),
    ));
  }
}
