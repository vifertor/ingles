import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/escape_room_provider.dart';
import 'escape_room_story.dart';
import 'escape_room_room1.dart';
import 'escape_room_room2.dart';
import 'escape_room_room3.dart';
import 'escape_room_room4.dart';
import 'escape_room_finish.dart';

class EscapeRoomScreen extends StatefulWidget {
  const EscapeRoomScreen({super.key});
  @override
  State<EscapeRoomScreen> createState() => _EscapeRoomScreenState();
}

class _EscapeRoomScreenState extends State<EscapeRoomScreen> {
  int _currentView = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EscapeRoomProvider>();
      provider.resetAll();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _advance(int nextPhase) {
    setState(() => _currentView = nextPhase);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EscapeRoomProvider>(
      builder: (context, provider, child) {
        switch (_currentView) {
          case 0: 
            return EscapeRoomStory(onFinish: () {
              provider.markStoryViewed();
              _advance(1);
            });
          case 1: 
            return EscapeRoomRoom1(onComplete: () => _advance(2));
          case 2: 
            return EscapeRoomRoom2(onComplete: () => _advance(3));
          case 3: 
            return EscapeRoomRoom3(onComplete: () => _advance(4));
          case 4: 
            return EscapeRoomRoom4(onComplete: () {
              provider.markCompleted();
              _advance(5);
            });
          case 5: 
            return EscapeRoomFinish(onExit: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            });
          default: 
            return EscapeRoomFinish(onExit: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            });
        }
      },
    );
  }
}
