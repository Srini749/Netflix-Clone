import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';



class video extends StatefulWidget {
  final String title;
  final String videoid;
  video({this.title, this.videoid});
  @override
  _videoState createState() => _videoState();
}


class _videoState extends State<video> {
  YoutubePlayerController controller;

  @override
  void initState() {
    controller = YoutubePlayerController(
      initialVideoId: widget.videoid,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: true,
      ),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,

    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));
    super.initState();
  }


  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,

    ]);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            progressColors: ProgressBarColors(
              playedColor: Colors.red,
              bufferedColor: Colors.white,
              backgroundColor: Colors.grey,
            ),
            topActions: [
              IconButton(icon: Icon(Icons.arrow_back_outlined, color: Colors.white,),onPressed: (){
                Navigator.pop(context);
                
              },),
              Center(child: Text(widget.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),))
            ],

          ),
          builder: (context, player){
          return Stack(
           children: [

            player,
          ],
        );
      }),
    );
  }
}
