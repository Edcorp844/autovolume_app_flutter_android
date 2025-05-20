import 'package:flutter/material.dart';
import 'package:myapp/src/extensions/build_context_extension.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            centerTitle: true,
            stretch: true,
            title: Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontFamily: 'Roboto',
                    color: context.textColor
                  ),
                  children: [
                    TextSpan(
                      text: 'Auto Volume\n',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Adjusts your media volume based on ambient noise levels for an optimal listening experience.\n\n',
                    ),
                    TextSpan(
                      text: 'How It Works:\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                    TextSpan(text: '• '),
                    TextSpan(
                      text: 'Enable Auto Volume',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' – Turn on the feature in settings.\n'),
                    TextSpan(text: '• '),
                    TextSpan(
                      text: 'Adjust Sensitivity',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: ' – Set the threshold for volume adjustments.\n',
                    ),
                    TextSpan(text: '• '),
                    TextSpan(
                      text: 'Play Music',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text:
                          ' – The app automatically adapts volume to your environment.\n\n',
                    ),
                    TextSpan(
                      text: 'Tips:\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                    TextSpan(text: '• '),
                    TextSpan(
                      text:
                          'Works best in dynamic sound environments (e.g., cafes, traffic).\n',
                    ),
                    TextSpan(text: '• '),
                    TextSpan(
                      text:
                          'Manual override available anytime via the volume slider.\n\n',
                    ),
                    TextSpan(
                      text:
                          'Enjoy seamless audio, no matter where you are!\n\n',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    TextSpan(
                      text: '— The Auto Volume Team',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
