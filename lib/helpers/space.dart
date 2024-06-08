import 'package:flutter/cupertino.dart';

class SpaceHelper {
  static Widget height(BuildContext context, double deger) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * deger,
    );
  }

  static Widget width(BuildContext context, double deger) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * deger,
    );
  }
}