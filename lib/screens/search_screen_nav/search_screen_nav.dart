import 'package:Foodybite/screens/detail_screen/detail_screen.dart';
import 'package:Foodybite/screens/post_recipe_screen/models/database.dart';
import 'package:Foodybite/screens/search_screen/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class SearchScreenNav extends StatefulWidget {
  const SearchScreenNav({Key? key}) : super(key: key);

  @override
  _SearchScreenNavState createState() => _SearchScreenNavState();
}

class _SearchScreenNavState extends State<SearchScreenNav> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController searchController = TextEditingController();
  String? searchText = "";

  @override
  Widget build(BuildContext context) {
    // final authService = Provider.of<AuthService>(context);
    return WillPopScope(
      onWillPop: () async {
        bool willLeave = false;
        await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Do you really want to exit the app'),
              actions: [
                new ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(willLeave = true),
                  child: Text("Yes"),
                ),
                SizedBox(height: 16),
                new FlatButton(
                  onPressed: () =>
                      Navigator.of(context).pop(willLeave = false),
                  child: Text("No"),
                ),
              ],
            ));
        return willLeave;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.redAccent,
          title: Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
            ),
            child: Text("Search"),
          ),
          bottom: _buildBottomBar(),
        ),
        body: searchText == ""
            ? Center(
            child: Text(
              "No results found",
              style: TextStyle(
                fontSize: 20,
              ),
            )): _buildListView(context),
      ),
    );
  }

  PreferredSize _buildBottomBar() {
    return PreferredSize(
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Card(
          child: Container(
            child: TextField(
                controller: searchController,
                cursorColor: Colors.red,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search Recipe',
                  icon: IconButton(
                    onPressed: () {
                      setState(() {
                        searchText = searchController.text;
                      });
                    },
                    icon: Icon(Icons.search),
                    color: Colors.red,
                  ),
                )),
          ),
        ),
      ),
      preferredSize: Size.fromHeight(80.0),
    );
  }

  Widget _buildListView(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: 400,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color.fromRGBO(226, 55, 68, 0.60),
                  Color.fromRGBO(226, 55, 68, 0.60),
                  Color.fromRGBO(226, 55, 68, 0.60),
                  Color.fromRGBO(226, 55, 68, 0.60),
                ])),
          ),
        ),
        _buildShopItem()
      ],
    );
  }

  Widget _buildShopItem() {
    return SafeArea(
        child: StreamBuilder<QuerySnapshot>(
            stream: RecipeDatabase.readSearchRecipes(searchText),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.redAccent)),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ListView(
                    children: snapshot.data!.docs.map((document) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DetailScreen(document: document)));
                        },
                        child: Container(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          margin: EdgeInsets.only(bottom: 20.0),
                          height: 250,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(document["image"]),
                                            fit: BoxFit.cover),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(5.0, 5.0),
                                              blurRadius: 10.0)
                                        ]),
                                  )),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        document["title"],
                                        style: TextStyle(
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text(document["time_to_cook"],
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.grey,
                                              height: 1.5))
                                    ],
                                  ),
                                  margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0)),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(5.0, 5.0),
                                            blurRadius: 10.0)
                                      ]),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList()),
              );
            }));
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height);

    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    var firstControlPoint = Offset(size.width / 4, size.height - 53);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    var secondEndPoint = Offset(size.width, size.height - 90);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 14);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
