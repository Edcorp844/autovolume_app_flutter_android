import 'package:flutter/cupertino.dart';
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
            title: Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SliverToBoxAdapter(
              child: /* Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                      child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(),
                        Text('Name'),
                        Text(
                          'Agaba Derick',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text('Email'),
                        Text(
                          'agabaderrick981@gmail.com',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text('Gender'),
                        Text(
                          'Male',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
                ],
              ), */
                  CupertinoListSection.insetGrouped(
            backgroundColor: context.backgroundColor!,
            children: [
              CupertinoListTile.notched(
                title: Text(
                  'Name',
                  style: TextStyle(color: context.textColor),
                ),
                subtitle: const Text('Agaba Derick'),
              ),
              CupertinoListTile.notched(
                title: Text(
                  'Email',
                  style: TextStyle(color: context.textColor),
                ),
                subtitle: const Text('agabaderrick981@gmail.com'),
              ),
              CupertinoListTile.notched(
                title: Text(
                  'Gender',
                  style: TextStyle(color: context.textColor),
                ),
                subtitle: const Text('Male'),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
