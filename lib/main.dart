import 'package:buzzing_booth_blog/post_content.dart';
import 'package:buzzing_booth_blog/post_model.dart';
import 'package:buzzing_booth_blog/read_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;
import 'package:flutter_scrollbar/webscrollbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buzzing Booth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: const MyHomePage(title: 'Buzz'),
      initialRoute: '/home/',
      routes: {
        '/home/': (context) => const MyHomePage(title: 'Buzz'),
        '/post/:post_id': (context) => const Read(),
      },
      onGenerateRoute: (settings) {
        if (settings.name!.startsWith('/post/')) {
          final postId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => Read(postId: postId),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  bool prepareWeb = true;
  ScrollController controller = ScrollController();
  final String assetName = '';

  String latest = "";
  String title = "";
  String description = "";
  String time = "";
  List<Post> post = [];
  List<Comment> comment = [];
  List viewers = [];

  final postsRef = FirebaseDatabase.instance.ref().child("post");

  @override
  void initState() {
    super.initState();

    postsRef.onValue.listen((event) {
      post.clear();
      for (final child in event.snapshot.children) {
        String banner = child.child("banner").value.toString();
        String title = child.child("title").value.toString();
        String description = child.child("description").value.toString();
        String time = child.child("time").value.toString();
        String key = child.key.toString();

        List<Content> contents = [];
        // List<Content> comments = [];
        // Get the content data as a List<dynamic>
        List<dynamic> contentList =
            child.child("content").value as List<dynamic>;
        dynamic commentsList = child.child("comments").value;

        List<dynamic> viewsList = child.child("views").value as List<dynamic>;

        setState(() {
          commentsList = child.child("comments").children.toList();
          viewers = child.child("views").children.toList();
        });

        // Loop through the contentList to create Content objects
        for (dynamic contentData in contentList) {
          String type = contentData["type"];
          String data = contentData["data"];
          Content content = Content(type: type, data: data);
          contents.add(content);
        }

        for (dynamic contentData in commentsList) {
          String content = contentData["content"];
          int time = contentData["time"];
          Comment comment_ = Comment(content: content, time: time);
          comment.add(comment_);
        }

        prepareWeb = false;
        Post post_ = Post(
            title: title,
            banner: banner,
            description: description,
            time: time,
            content: contents,
            comments: comment,
            views: viewsList,
            key: key);

        setState(() {
          post.add(post_);
        });
        checkLatest();
      }
    }, onError: (error) {});
  }

  @override
  void dispose() {
    // Remove this widget as an observer when it's disposed

    super.dispose();
  }

  void myfun() {
    /*String key = postsRef.push().key.toString();
    postsRef.child(key).set(post_three
        .toJson()); // Convert the Post object to JSON using the toJson() method*/
    DateTime targetDateTime = DateTime(2023, 8, 16, 20, 00);
    int milliseconds = targetDateTime.microsecondsSinceEpoch ~/ 1000;

    print("Milliseconds $milliseconds");
  }

  void checkLatest() {
    setState(() {
      description = post[0].description.toString();
      latest = post[0].banner.toString();
      title = post[0].title.toString();
      time = post[0].time.toString();
    });
  }

  String timevalue(String t) {
    int milliseconds = int.parse(t);
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

    String date = DateFormat('MMM dd, yyyy').format(dateTime);
    String at = DateFormat('HH:mm').format(dateTime);
    return "Posted ${date} at ${at}";
  }

  @override
  Widget build(BuildContext context) {
    return prepareWeb
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            backgroundColor: const Color(0xFFEAC3EF),
            body: WebScrollBar(
                controller: controller,
                visibleHeight: 1000,
                scrollThumbColor: const Color.fromARGB(255, 117, 117, 117),
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    children: [
                      // Custom Appbar
                      Center(
                        child: Container(
                          color: const Color(0xFFEAC3EF),
                          child: RichText(
                            text: TextSpan(
                                style: const TextStyle(),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: widget.title,
                                      style: google_fonts.GoogleFonts
                                          .dancingScript(
                                              fontSize: 70,
                                              color: const Color(0xFF9F0BAD))),
                                  TextSpan(
                                    text: '\n         with Aggie',
                                    style: google_fonts.GoogleFonts.poppins(
                                        fontSize: 20,
                                        color: const Color(0xFF342635)),
                                  )
                                ]),
                          ),
                        ),
                      ),
                      // Custom Appbar end

                      // Latest post section
                      Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                                color: Colors.transparent,
                                width: MediaQuery.of(context).size.width,
                                child: Image.network(
                                  latest,
                                  scale: 0.7,
                                )),
                            Text(
                              timevalue(time),
                              style: google_fonts.GoogleFonts.ubuntu(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text(
                                title,
                                style: google_fonts.GoogleFonts.ubuntu(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Center(
                                child: Text(
                                  description,
                                  style: google_fonts.GoogleFonts.ubuntu(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FontStyle.italic),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 4,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Center(
                                child: GestureDetector(
                              onTap: () {
                                String id = post[0].key.toString();
                                Navigator.pushNamed(context, '/post/$id');
                              },
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2,
                                      color: Colors
                                          .black), // Customize border properties
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(
                                      10), // Add padding for spacing
                                  child: Text(
                                    "READ MORE",
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                              ),
                            )),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),

                      // Latest post section end
                      //Affiliate
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        color: Colors.red,
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        child: const Center(
                          child: Text("Affiliate"),
                        ),
                      ),
                      //end of affiliate
                      //All posts
                      const SizedBox(
                        height: 20,
                      ),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            post.length, // Number of posts in the database
                        itemBuilder: (BuildContext context, int index) {
                          Color backgroundColor = index % 2 == 0
                              ? Colors.white
                              : Colors.transparent; // Alternating colors
                          return GestureDetector(
                              onTap: () {
                                String id = post[index].key.toString();
                                Navigator.pushNamed(context, '/post/$id');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.27,
                                  alignment: Alignment.center,
                                  color: backgroundColor,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          color: Colors.transparent,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                10), // Adjust the radius as needed
                                            child: Image.network(
                                              post[index].banner.toString(),
                                              fit: BoxFit.cover,
                                              scale: 2,
                                            ),
                                          )),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Flexible(
                                          fit: FlexFit.loose,
                                          child: Container(
                                            color: Colors.transparent,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                    post[index]
                                                        .title
                                                        .toString(),
                                                    style:
                                                        google_fonts.GoogleFonts
                                                            .ubuntu(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                Text(
                                                    post[index]
                                                        .description
                                                        .toString(),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: google_fonts
                                                            .GoogleFonts
                                                        .poppins(fontSize: 17)),
                                                Text("Read more",
                                                    style: google_fonts
                                                            .GoogleFonts
                                                        .poppins(
                                                            fontSize: 15,
                                                            color:
                                                                Colors.blue)),
                                                Text(timevalue(post[index]
                                                    .time
                                                    .toString())),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(viewers.length
                                                        .toString()),
                                                    const SizedBox(
                                                      width: 3,
                                                    ),
                                                    SvgPicture.asset(
                                                      "assets/view.svg",
                                                      height: 19,
                                                    ),
                                                    const SizedBox(
                                                      width: 3,
                                                    ),
                                                    Text(post[index]
                                                        .comments
                                                        .length
                                                        .toString()),
                                                    const SizedBox(
                                                      width: 3,
                                                    ),
                                                    SvgPicture.asset(
                                                      "assets/comment.svg",
                                                      height: 19,
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                              ));
                        },
                      ),

                      const SizedBox(
                        height: 20,
                      )

                      //All posts end
                    ],
                  ),
                )),
          );
  }
}
