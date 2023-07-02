import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_library/data/schemas.dart' as lib;
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:badges/badges.dart' as bd;

class DispatchWidget extends StatelessWidget {
  const DispatchWidget({Key? key, required this.dispatchRecord})
      : super(key: key);

  final lib.DispatchRecord dispatchRecord;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MMM/yyyy HH:.mm');
    final date = fmt.format(DateTime.parse(dispatchRecord.created!));
    return ListTile(
      title: Text('${dispatchRecord.vehicleReg}'),
      subtitle: Text(
        date,
        style: myTextStyleTiny(context),
      ),
      leading: Icon(
        Icons.airport_shuttle,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

class DispatchWidgetList extends StatelessWidget {
  const DispatchWidgetList(
      {Key? key,
      required this.dispatchRecords,
      required this.onDispatchRecordSelected})
      : super(key: key);
  final List<lib.DispatchRecord> dispatchRecords;
  final Function(lib.DispatchRecord) onDispatchRecordSelected;

  @override
  Widget build(BuildContext context) {
    return bd.Badge(
      badgeContent: Text('${dispatchRecords.length}'),
      badgeStyle: bd.BadgeStyle(
          elevation: 12,
          padding: const EdgeInsets.all(12.0),
          badgeColor: Colors.blue[700]!),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: dispatchRecords.length,
          itemBuilder: (ctx, index) {
            final rl = dispatchRecords.elementAt(index);
            return GestureDetector(
                onTap: () {
                  onDispatchRecordSelected(rl);
                },
                child: SizedBox(
                    width: 100, height: 60,
                    child: DispatchWidget(dispatchRecord: rl)));
          }),
    );
  }
}
