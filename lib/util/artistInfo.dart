import 'dart:async';
import 'dart:convert';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/pages/artistcard.dart';

class GetArtistDetail extends StatefulWidget {
  final String artist;
  final Song artistSong;
  final int mode;

  //mode = 0 for artist image
  //mode = 1 similar artist details
  //mode = 2 bio
  GetArtistDetail({this.artist, this.artistSong, this.mode = 0});
  @override
  _GetArtistDetailState createState() => _GetArtistDetailState();
}

class _GetArtistDetailState extends State<GetArtistDetail> {
  var url;
  final String baseUrl = "http://ws.audioscrobbler.com/2.0/";
  final String apiKey = "0d2da67e6403429edfe068ec98acfe00";
  ArtistInfo artist;
  var albumArt;
  String summary;
  DatabaseClient db;
  List<Song> artists;
  @override
  void initState() {
    super.initState();
    url =
        "$baseUrl?method=artist.getinfo&artist=${widget.artist.toLowerCase().replaceAll(" ", "+")}&api_key=$apiKey&format=json";
    fetchData();
  }

  fetchData() async {
    albumArt = widget.artistSong.albumArt != null
        ? File.fromUri(Uri.parse(widget.artistSong.albumArt))
        : null;
    var res = await http.get(url);
    var decodedJson = jsonDecode(res.body);
    artist = ArtistInfo.fromJson(decodedJson);
//    artists = await db.fetchArtist();
    setState(() {});
  }
  showArtistPage(artistX){
    if(artists!= null)
      artists.forEach((artist) {
        if (artist.artist == artistX)
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return ArtistCard(db,artist);
          }));
        else
          return;
      });
  }

  Widget _similarArtist() {
    return artist.artist.image != null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(left: 15.0, top: 15.0, bottom: 10.0),
                child: Text(
                  "Similar artists".toUpperCase(),
                  style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Quicksand",
                      letterSpacing: 1.8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                color: Colors.white,
                height: 210.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: artist.artist.similar.artist.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 30.0),
                      child: InkWell(
                        onTap: showArtistPage(artist.artist.similar.artist
                            .toList()[i]
                            .name),
                        child: Card(
                          elevation: 15.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Image.network(
                                      artist.artist.similar.artist.toList()[i].image.toList()[3].text,
                                      height: 125.0,
                                      width: 180.0,
                                      fit: BoxFit.cover),
                              SizedBox(
                                width: 180.0,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10.0,left: 4.0,right: 4.0),
                                  child: Center(
                                    child: Text(
                                      artist.artist.similar.artist
                                          .toList()[i]
                                          .name
                                          .toUpperCase(),
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black.withOpacity(0.70)),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : Container(height: 0.0,width: 0.0,);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget forModeTwo(){
    summary = artist.artist.bio.summary;
    return ListView(
      children: <Widget>[
          Center(child: Text('Bio',style: TextStyle(color: Colors.black,fontSize: 27.0),)),
          Text(summary,style: TextStyle(color: Colors.black,fontSize: 20.0))
        ]
    );
  }

  Widget forModeZero() {
    return artist != null
        ? artist.artist.image != null
            ? Image.network(
                artist.artist.image.toList()[3].text,
                fit: BoxFit.cover,
              )
            : albumArt != null
                ? Image.file(
                    albumArt,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "images/artist.jpg",
                    fit: BoxFit.cover,
                  )
        : Image.file(
            albumArt,
            fit: BoxFit.cover,
          );
  }

  decide(){
    switch(widget.mode){
      case 0:
        return forModeZero();
        break;
      case 1:
        return artist!=null ? _similarArtist():Container();
        break;
      case 2:
        return artist!=null ? forModeTwo() : Container();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return decide();
  }
}

class ArtistInfo {
  Artist artist;

  ArtistInfo({this.artist});

  ArtistInfo.fromJson(Map<String, dynamic> json) {
    artist =
        json['artist'] != null ? new Artist.fromJson(json['artist']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.artist != null) {
      data['artist'] = this.artist.toJson();
    }
    return data;
  }
}

class Artist {
  String name;
  String mbid;
  String url;
  List<ImageX> image;
  String streamable;
  String ontour;
  Stats stats;
  Similar similar;
  Tags tags;
  Bio bio;

  Artist(
      {this.name,
      this.mbid,
      this.url,
      this.image,
      this.streamable,
      this.ontour,
      this.stats,
      this.similar,
      this.tags,
      this.bio});

  Artist.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    mbid = json['mbid'];
    url = json['url'];
    if (json['image'] != null) {
      image = new List<ImageX>();
      json['image'].forEach((v) {
        image.add(new ImageX.fromJson(v));
      });
    }
    streamable = json['streamable'];
    ontour = json['ontour'];
    stats = json['stats'] != null ? new Stats.fromJson(json['stats']) : null;
    similar =
        json['similar'] != null ? new Similar.fromJson(json['similar']) : null;
    tags = json['tags'] != null ? new Tags.fromJson(json['tags']) : null;
    bio = json['bio'] != null ? new Bio.fromJson(json['bio']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['mbid'] = this.mbid;
    data['url'] = this.url;
    if (this.image != null) {
      data['image'] = this.image.map((v) => v.toJson()).toList();
    }
    data['streamable'] = this.streamable;
    data['ontour'] = this.ontour;
    if (this.stats != null) {
      data['stats'] = this.stats.toJson();
    }
    if (this.similar != null) {
      data['similar'] = this.similar.toJson();
    }
    if (this.tags != null) {
      data['tags'] = this.tags.toJson();
    }
    if (this.bio != null) {
      data['bio'] = this.bio.toJson();
    }
    return data;
  }
}

class ImageX {
  String text;
  String size;

  ImageX({this.text, this.size});

  ImageX.fromJson(Map<String, dynamic> json) {
    text = json['#text'];
    size = json['size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['#text'] = this.text;
    data['size'] = this.size;
    return data;
  }
}

class Stats {
  String listeners;
  String playcount;

  Stats({this.listeners, this.playcount});

  Stats.fromJson(Map<String, dynamic> json) {
    listeners = json['listeners'];
    playcount = json['playcount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['listeners'] = this.listeners;
    data['playcount'] = this.playcount;
    return data;
  }
}

class Similar {
  List<Artist> artist;

  Similar({this.artist});

  Similar.fromJson(Map<String, dynamic> json) {
    if (json['artist'] != null) {
      artist = new List<Artist>();
      json['artist'].forEach((v) {
        artist.add(new Artist.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.artist != null) {
      data['artist'] = this.artist.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tags {
  List<Tag> tag;

  Tags({this.tag});

  Tags.fromJson(Map<String, dynamic> json) {
    if (json['tag'] != null) {
      tag = new List<Tag>();
      json['tag'].forEach((v) {
        tag.add(new Tag.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tag != null) {
      data['tag'] = this.tag.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tag {
  String name;
  String url;

  Tag({this.name, this.url});

  Tag.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['url'] = this.url;
    return data;
  }
}

class Bio {
  Links links;
  String published;
  String summary;
  String content;

  Bio({this.links, this.published, this.summary, this.content});

  Bio.fromJson(Map<String, dynamic> json) {
    links = json['links'] != null ? new Links.fromJson(json['links']) : null;
    published = json['published'];
    summary = json['summary'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.links != null) {
      data['links'] = this.links.toJson();
    }
    data['published'] = this.published;
    data['summary'] = this.summary;
    data['content'] = this.content;
    return data;
  }
}

class Links {
  Link link;

  Links({this.link});

  Links.fromJson(Map<String, dynamic> json) {
    link = json['link'] != null ? new Link.fromJson(json['link']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.link != null) {
      data['link'] = this.link.toJson();
    }
    return data;
  }
}

class Link {
  String text;
  String rel;
  String href;

  Link({this.text, this.rel, this.href});

  Link.fromJson(Map<String, dynamic> json) {
    text = json['#text'];
    rel = json['rel'];
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['#text'] = this.text;
    data['rel'] = this.rel;
    data['href'] = this.href;
    return data;
  }
}
