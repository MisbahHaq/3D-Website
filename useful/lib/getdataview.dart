import 'package:api/api.dart';
import 'package:flutter/material.dart';

class GettingData extends StatefulWidget {
  int? id;
  GettingData({super.key, required this.id});

  @override
  State<GettingData> createState() => _GettingDataState();
}

class _GettingDataState extends State<GettingData> {
  ApiService apiService = ApiService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.id}'),
      ),
      body: FutureBuilder(
          future: apiService.getUsersId(widget.id),
          builder: (context, snapShot) {
            if (snapShot.hasData) {
              return ListTile(
                title: Text(snapShot.data['name']),
                subtitle: Text(snapShot.data['email']),
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
