import 'dart:typed_data';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Picker Example',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Media Picker Example App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: MediaGrid(),
    );
  }
}

class MediaGrid extends StatefulWidget {
  @override
  _MediaGridState createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid> {
  
  final _pagingController = PagingController<int, AssetEntity>(
    firstPageKey: 0,
  );

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPhotos(pageKey);
    });

    super.initState();
  }

  void _fetchPhotos(int page) async {
    final PermissionState _ps = await PhotoManager.requestPermissionExtend();
    if (_ps.isAuth) {
      final List<AssetPathEntity> path = await PhotoManager.getAssetPathList(
        onlyAll: true,
      );
      var temp = await path[0].getAssetListPaged(page: page, size: 60);
      _pagingController.appendPage(temp, ++page);
    } else {
      _pagingController.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedGridView(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<AssetEntity>(
            itemBuilder: (context, item, index) 
            {
              return FutureBuilder(
              future: item
                  .thumbnailDataWithSize(const ThumbnailSize(210, 210)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Image.memory(
                    snapshot.data as Uint8List,
                    fit: BoxFit.cover,
                  );
                }
                return Container();
              });
              
            }
        ),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3));
  }
}






 /*GridView.builder(
        controller: _controller,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: _mediaList.length,
        itemBuilder: (context, index) {
          return FutureBuilder(
              future: _mediaList[index]
                  .thumbnailDataWithSize(const ThumbnailSize(210, 210)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Image.memory(
                    snapshot.data as Uint8List,
                    fit: BoxFit.cover,
                  );
                }
                return Container();
              });
        });*/