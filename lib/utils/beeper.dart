import 'package:beep_player/beep_player.dart';

final Beeper beeper = Beeper();
class Beeper {

  static const BeepFile _beepFile = BeepFile(
    'assets/sounds/beep.wav',
    package: 'package1',
  );

 void init() {
   BeepPlayer.load(_beepFile);
 }
 Future playBeep() async{
   await BeepPlayer.play(_beepFile);
 }
 void close() {
   BeepPlayer.unload(_beepFile);

 }

  Beeper() {
   init();
  }
}
