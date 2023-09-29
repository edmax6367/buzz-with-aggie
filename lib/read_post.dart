import 'package:flutter/material.dart';
import 'package:flutter_scrollbar/webscrollbar.dart';
import 'package:intl/intl.dart';
import 'post_content.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;

class Read extends StatefulWidget {
  final String? postId;
  /*final String? userId;
  final String? title;
  final String? banner;
  final String? intro;*/

  const Read({
    super.key,
    this.postId,
  });

  @override
  State<Read> createState() => Reader();
}

class Reader extends State<Read> {
  ScrollController controller = ScrollController();
  //Contents
  String authorKey = "";
  String authorName = "";
  String authorImage = "";
  String banner = "";
  String title = "";
  String description = "";
  String time = "";
  List<Content> contents = [];

  final postsRef = FirebaseDatabase.instance.ref().child("post");
  final usersRef = FirebaseDatabase.instance.ref().child("users");

  @override
  void initState() {
    super.initState();

    postsRef.child(widget.postId.toString()).onValue.listen((event) {
      authorKey = event.snapshot.child("author").value.toString();
      Author(authorKey);
      banner = event.snapshot.child("banner").value.toString();
      title = event.snapshot.child("title").value.toString();
      description = event.snapshot.child("description").value.toString();
      time = event.snapshot.child("time").value.toString();
      List<dynamic> contentList =
          event.snapshot.child("content").value as List<dynamic>;
      contents.clear();
      if (context.mounted) {
        setState(() {
          for (dynamic contentData in contentList) {
            String type = contentData["type"];
            String data = contentData["data"];
            Content content = Content(type: type, data: data);
            contents.add(content);
          }
        });
      }
    }, onError: (error) {});
  }

  void Author(String key) {
    if (key.isNotEmpty) {
      usersRef.child(authorKey).onValue.listen((event) {
        setState(() {
          authorName = event.snapshot.child("name").value.toString();
          authorImage = event.snapshot.child("image").value.toString();
          print("Author name: $authorName");
        });
      }, onError: (error) {});
    }
  }

  String timevalue(String t) {
    int milliseconds = int.parse(t);
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

    String date = DateFormat('MMM dd, yyyy').format(dateTime);
    String at = DateFormat('HH:mm').format(dateTime);
    return "Posted ${date} at ${at}";
  }

  //End Contents

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF9F0BAD),
          title: Text(
            title,
            style: google_fonts.GoogleFonts.poppins(
                fontSize: 17, color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, '/home/');
            },
          ),
        ),
        body: WebScrollBar(
            controller: controller,
            visibleHeight: MediaQuery.of(context).size.height * 0.9,
            scrollThumbColor: const Color.fromARGB(255, 117, 117, 117),
            child: SingleChildScrollView(
                controller: controller,
                child: Column(children: [
                  // Header start
                  const SizedBox(
                    height: 0,
                  ),
                  Stack(
                    children: [
                      Container(
                          color: Colors.transparent,
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          child: Image.network(
                            banner,
                            fit: BoxFit.cover,
                            scale: 0.7,
                          )),
                      Positioned(
                          bottom: 0,
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              color: Color.fromARGB(95, 0, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        authorName,
                                        style: google_fonts.GoogleFonts.poppins(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                      Text(
                                        timevalue(time),
                                        style: google_fonts.GoogleFonts.poppins(
                                            color: const Color.fromARGB(
                                                255, 181, 181, 181),
                                            fontSize: 12),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Container(
                                      width: 35,
                                      height: 35,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              360), // Adjust the radius as needed
                                          child: Image.network(
                                            authorImage,
                                            fit: BoxFit.cover,
                                            scale: 3,
                                          ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                ],
                              )))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(description,
                        style: google_fonts.GoogleFonts.ubuntu(
                          fontSize: 19,
                          fontWeight: FontWeight.normal,
                        )),
                  ),
                  //header end
                  //All content
                  const SizedBox(
                    height: 20,
                  ),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        contents.length, // Number of posts in the database
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          // Handle the tap event for a grid item
                          /*  Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Read(
                                        postId: content[index].key,
                                        userId: "Nada",
                                        title: post[index].title.toString(),
                                        banner: post[index].banner.toString(),
                                      )));*/
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              if (contents[index].type == "1")
                                //header text  data
                                Text(contents[index].data.toString(),
                                    style: google_fonts.GoogleFonts.ubuntu(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),

                              const SizedBox(
                                width: 10,
                              ),
                              //header text  data end
                              if (contents[index].type == "2")
                                //article text  data
                                Text(contents[index].data.toString(),
                                    style: google_fonts.GoogleFonts.ubuntu(
                                        fontSize: 19,
                                        fontWeight: FontWeight.normal)),
                              const SizedBox(
                                width: 10,
                              ),
                              //article text  data end
                              //image data
                              const SizedBox(
                                width: 10,
                              ),
                              if (contents[index].type == "3")
                                Image.network(
                                  contents[index].data.toString(),
                                  fit: BoxFit.cover,
                                  scale: 2,
                                ),

                              const SizedBox(
                                width: 10,
                              ),
                              //image data end
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  )

                  //All content end
                ]))));
  }
}
