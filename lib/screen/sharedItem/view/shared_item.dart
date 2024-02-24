import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nextcloud_chat_app/models/chats.dart';
import 'package:nextcloud_chat_app/service/chat_service.dart';
import 'package:nextcloud_chat_app/service/request.dart';
import 'package:nextcloud_chat_app/utils.dart';

class SharedItem extends StatefulWidget {
  const SharedItem({
    Key? key,
    required this.token,
    required this.name,
  }) : super(key: key);
  final String token;
  final String name;

  @override
  State<SharedItem> createState() => _SharedItemState(token, name);
}

class _SharedItemState extends State<SharedItem> {
  PageController _pageController = PageController();
  int _currentIndex = 0;
  final String token;
  final String name;
  late Future<Map<dynamic, dynamic>> futureMedia;
  late Future<Map<dynamic, dynamic>> futureFile;
  late Map<String, String> requestHeaders;

  _SharedItemState(this.token, this.name);

  @override
  void initState() {
    // Call getFile in initState and don't forget to handle async operations here
    futureMedia = ChatService().getShared(token, "media");
    futureFile = ChatService().getShared(token, "file");
    setState(() {
      getFile();
    });
    super.initState();
  }

  Future<void> getFile() async {
    try {
      requestHeaders = await HTTPService().authImgHeader();
    } catch (error) {
      // Handle errors, log them, or display user-friendly messages
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottomOpacity: 0.0,
        elevation: 0.0,
        leading: Container(
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_outlined, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          name,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Container(
            child: Row(
              children: [
                _buildNavItem('Media', 0),
                _buildNavItem('File', 1),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                _buildMediaPage(),
                _buildFilePage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPage() {
    return FutureBuilder(
      future: futureMedia,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
 
          return GridView.count(
            crossAxisCount: 4,
            children: snapshot.data!.entries.map<Widget>((e) {
         
              return Container(
                margin: EdgeInsets.all(5),
                child: CachedNetworkImage(
                  imageUrl:
                      'http://${host}:8080/core/preview?x=480&y=480&fileId=${e.value['messageParameters']['file']['id']}',
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) {
                    return Icon(Icons.error);
                  },
                  httpHeaders: requestHeaders,
                ),
              );
            }).toList(),
          );
        } else if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildFilePage() {
    return FutureBuilder(
      future: futureFile,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView(
            children: snapshot.data!.entries.map<Widget>((e) {
        
              return ListTile(
                title: Text(
                  e.value['messageParameters']['file']['name'],
                  maxLines: 1,
                ),
                leading: Container(
                  width: 50,
                  child: Builder(
                    builder: (context) {
                      String filePath = e.value['messageParameters']['file']
                              ['name']
                          .toString();
                      List<String> parts = filePath.split('.');
                      if (parts.length > 1) {
                        switch (parts.last) {
                          case 'pdf':
                            return Image.asset('assets/pdf.png');
                            break;

                          case 'docx':
                            return Image.asset('assets/doc.png');
                            break;

                          case 'ppt':
                            return Image.asset('assets/ppt.png');
                            break;

                          case 'txt':
                            return Image.asset('assets/txt.png');
                            break;

                          case 'zip':
                            return Image.asset('assets/zip.png');

                            break;
                          default:
                            return Image.asset('assets/file.png');
                        }
                      } else {
                        return Image.asset('assets/file.png');
                        // Không có đuôi file
                      }
                    },
                  ),
                ),
                subtitle: Text(formatFileSize(
                        e.value['messageParameters']['file']['size']) +
                    " | " +
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            e.value['timestamp'] * 1000)) +
                    " | " +
                    e.value['actorId']),
              );
            }).toList(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildNavItem(String title, int index) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        // color: _currentIndex == index ? Colors.blue : Colors.transparent,
        child: Text(
          title,
          style: TextStyle(
            color: _currentIndex == index ? Colors.blue : Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        decoration: _currentIndex == index
            ? BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                color: Colors.blue,
                style: BorderStyle.solid,
                width: 3,
              )))
            : null,
      ),
    );
  }
}
