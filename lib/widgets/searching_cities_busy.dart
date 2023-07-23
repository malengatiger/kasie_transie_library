import 'package:flutter/material.dart';
import 'package:kasie_transie_library/utils/functions.dart';

class SearchingCitiesBusy extends StatelessWidget {
  const SearchingCitiesBusy({
    super.key, required this.searchingCities,
  });
 final String searchingCities;
  @override
  Widget build(BuildContext context) {
    return  Center(
      child: SizedBox(
        height: 200, width: 400,
        child: Card(
          shape: getDefaultRoundedBorder(),
          elevation: 16,
          child:  Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 48,
                ),
                const SizedBox(height:18,width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    backgroundColor: Colors.pink,
                  ),
                ),
                const SizedBox(
                  height: 48,
                ),
                Text(searchingCities)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
