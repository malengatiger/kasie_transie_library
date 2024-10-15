import 'package:flutter/material.dart';

import '../../data/data_schemas.dart';
import '../../utils/functions.dart';


class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Name'),
                Text('${user.firstName} ${user.lastName}',
                    style: myTextStyle(weight: FontWeight.bold, fontSize: 24)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Email'),
                Text('${user.email}',
                    style: myTextStyle(weight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CellPhone'),
                Text('${user.cellphone}',
                    style: myTextStyle(weight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${user.associationName}',
                    style: myTextStyle(weight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
