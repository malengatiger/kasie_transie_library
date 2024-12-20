import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/data/color_and_locale.dart';
import 'package:kasie_transie_library/data/data_schemas.dart' as lib;
import 'package:kasie_transie_library/l10n/translation_handler.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/prefs.dart';

class VehiclePhotoWidget extends StatefulWidget {
  const VehiclePhotoWidget({super.key, required this.vehiclePhoto});

  final lib.VehiclePhoto vehiclePhoto;

  @override
  VehiclePhotoWidgetState createState() => VehiclePhotoWidgetState();
}

class VehiclePhotoWidgetState extends State<VehiclePhotoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '💦💦💦💦 VehiclePhotoWidget 🔷';

  late ColorAndLocale colorAndLocale;
  late String date;
  bool ready = false;
  Prefs prefs = GetIt.instance<Prefs>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getLocale();
  }

  void _getLocale() async {
    pp('$mm ... _getLocale ...');
    colorAndLocale = prefs.getColorAndLocale();
    date = getFormattedDateLong(widget.vehiclePhoto.created!);

    setState(() {
      ready = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? vehiclePhotoText;
  Future _setTexts() async {
    final c = prefs.getColorAndLocale();
    vehiclePhotoText = await translator.translate('vehiclePhoto', c.locale);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title:  Text(vehiclePhotoText == null?
            'Vehicle Photo': vehiclePhotoText!),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: ready
                ? Column(
                    children: [
                      const SizedBox(height: 8,),
                      Text(
                        '${widget.vehiclePhoto.vehicleReg}',
                        style: myTextStyleMediumLargeWithColor(
                            context, Theme.of(context).primaryColor, 32),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(date, style: myTextStyleSmall(context),),
                      const SizedBox(
                        height: 12,
                      ),
                    ],
                  )
                : const SizedBox()),
      ),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: GestureDetector(
              onTap: (){
                Navigator.of(context).pop();
              },
              child: Card(
                child: Image.network(
                  widget.vehiclePhoto.url!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
