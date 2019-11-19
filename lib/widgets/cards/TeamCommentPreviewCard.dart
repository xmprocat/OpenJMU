///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-19 15:56
///
import 'dart:async';
import 'dart:ui' as ui;

import 'package:OpenJMU/pages/post/TeamPostDetailPage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:intl/intl.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/user/UserPage.dart';
import 'package:OpenJMU/widgets/image/ImageViewer.dart';

class TeamCommentPreviewCard extends StatelessWidget {
  final TeamPost post;
  final TeamPost topPost;

  const TeamCommentPreviewCard({
    Key key,
    @required this.post,
    @required this.topPost,
  }) : super(key: key);

  Widget _header(context) => Container(
        height: suSetHeight(80.0),
        padding: EdgeInsets.symmetric(
          vertical: suSetHeight(8.0),
        ),
        child: Row(
          children: <Widget>[
            UserAPI.getAvatar(uid: post.uid, size: 40.0),
            SizedBox(width: suSetWidth(16.0)),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      post.nickname ?? post.uid.toString(),
                      style: TextStyle(
                        fontSize: suSetSp(17.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (post.uid == topPost.uid)
                      Container(
                        margin: EdgeInsets.only(
                          left: suSetWidth(10.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: suSetWidth(6.0),
                          vertical: suSetHeight(0.5),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(suSetWidth(5.0)),
                          color: ThemeUtils.currentThemeColor,
                        ),
                        child: Text(
                          "楼主",
                          style: TextStyle(
                            fontSize: suSetSp(12.0),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (Constants.developerList.contains(post.uid))
                      Container(
                        margin: EdgeInsets.only(left: suSetWidth(14.0)),
                        child: Constants.developerTag(
                          padding: EdgeInsets.symmetric(
                            horizontal: suSetWidth(8.0),
                            vertical: suSetHeight(3.0),
                          ),
                          fontSize: 11.0,
                        ),
                      ),
                  ],
                ),
                _postTime(context),
              ],
            ),
            Spacer(),
            if (post.uid == UserAPI.currentUser.uid)
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).dividerColor,
                ),
                iconSize: suSetWidth(40.0),
                alignment: Alignment.centerRight,
                onPressed: () {},
              ),
          ],
        ),
      );

  Widget _postTime(context) {
    final now = DateTime.now();
    DateTime _postTime;
    String time = "";
    if (post.postInfo != null && post.postInfo.isNotEmpty) {
      _postTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(post.postInfo[0]['post_time']));
      time += "回复于";
    } else {
      _postTime = post.postTime;
    }
    if (_postTime.day == now.day &&
        _postTime.month == now.month &&
        _postTime.year == now.year) {
      time += DateFormat("HH:mm").format(_postTime);
    } else if (post.postTime.year == now.year) {
      time += DateFormat("MM-dd HH:mm").format(_postTime);
    } else {
      time += DateFormat("yyyy-MM-dd HH:mm").format(_postTime);
    }
    return Text(
      "第${post.floor}楼 · $time",
      style: Theme.of(context).textTheme.caption.copyWith(
            fontSize: suSetSp(15.0),
            fontWeight: FontWeight.normal,
          ),
    );
  }

  Widget get _content => Padding(
        padding: EdgeInsets.symmetric(
          vertical: suSetHeight(4.0),
        ),
        child: ExtendedText(
          post.content,
          style: TextStyle(
            fontSize: suSetSp(17.0),
          ),
          onSpecialTextTap: specialTextTapRecognizer,
          maxLines: 8,
          overFlowTextSpan: OverFlowTextSpan(
            children: <TextSpan>[
              TextSpan(text: " ... "),
              TextSpan(
                text: "全文",
                style: TextStyle(
                  color: ThemeUtils.currentThemeColor,
                  fontSize: suSetSp(17.0),
                ),
              ),
            ],
          ),
          specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
        ),
      );

  Widget _replyInfo(context) => Container(
        margin: EdgeInsets.symmetric(
          vertical: suSetHeight(12.0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: suSetWidth(16.0),
          vertical: suSetHeight(12.0),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(suSetWidth(10.0)),
          color: Theme.of(context).canvasColor.withOpacity(0.5),
        ),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: post.replyInfo.length +
              (post.replyInfo.length != post.repliesCount ? 1 : 0),
          itemBuilder: (_, index) {
            if (index == post.replyInfo.length)
              return Container(
                margin: EdgeInsets.only(
                  top: suSetHeight(12.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "查看更多回复",
                      style: Theme.of(context).textTheme.caption.copyWith(
                            fontSize: suSetSp(15.0),
                          ),
                    ),
                    Icon(
                      Icons.expand_more,
                      size: suSetWidth(20.0),
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ],
                ),
              );
            final _post = post.replyInfo[index];
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: suSetHeight(4.0),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ExtendedText(
                      _post['content'],
                      specialTextSpanBuilder:
                          StackSpecialTextSpanBuilder(prefixSpans: <InlineSpan>[
                        TextSpan(
                          text: "@${_post['user']['nickname']}",
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              UserPage.jump(int.parse(_post['user']['uid']));
                            },
                        ),
                        if (int.parse(_post['user']['uid']) == topPost.uid)
                          WidgetSpan(
                            alignment: ui.PlaceholderAlignment.middle,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: suSetWidth(6.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: suSetWidth(6.0),
                                vertical: suSetHeight(1.0),
                              ),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(suSetWidth(5.0)),
                                color: ThemeUtils.currentThemeColor,
                              ),
                              child: Text(
                                "楼主",
                                style: TextStyle(
                                  fontSize: suSetSp(15.0),
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        TextSpan(
                          text: "：",
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ]),
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontSize: suSetSp(17.0),
                          ),
                      onSpecialTextTap: specialTextTapRecognizer,
                    ),
                  ),
                  if (int.parse(_post['user']['uid']) ==
                      UserAPI.currentUser.uid)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).dividerColor,
                        size: suSetWidth(40.0),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );

  Widget _images(context) {
    List<Widget> imagesWidget = [];
    for (int index = 0; index < post.pics.length; index++) {
      final imageId = int.parse(post.pics[index]['fid']);
      final imageUrl = API.teamFile(fid: imageId);
      Widget _exImage = ExtendedImage.network(
        imageUrl,
        fit: BoxFit.cover,
        cache: true,
        color: ThemeUtils.isDark ? Colors.black.withAlpha(50) : null,
        colorBlendMode: ThemeUtils.isDark ? BlendMode.darken : BlendMode.srcIn,
        loadStateChanged: (ExtendedImageState state) {
          Widget loader;
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              loader = Center(child: Constants.progressIndicator());
              break;
            case LoadState.completed:
              final info = state.extendedImageInfo;
              if (info != null) {
                loader = scaledImage(
                  image: info.image,
                  length: post.pics.length,
                  num200: suSetSp(200),
                  num400: suSetSp(400),
                );
              }
              break;
            case LoadState.failed:
              break;
          }
          return loader;
        },
      );
      imagesWidget.add(
        GestureDetector(
          onTap: () {
            currentState.pushNamed(
              "openjmu://image-viewer",
              arguments: {
                "index": index,
                "pics": post.pics.map<ImageBean>((f) {
                  return ImageBean(
                    id: imageId,
                    imageUrl: imageUrl,
                    imageThumbUrl: imageUrl,
                    postId: post.tid,
                  );
                }).toList(),
              },
            );
          },
          child: _exImage,
        ),
      );
    }
    Widget _image;
    if (post.pics.length == 1) {
      _image = Align(
        alignment: Alignment.topLeft,
        child: imagesWidget[0],
      );
    } else if (post.pics.length > 1) {
      _image = GridView.count(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        primary: false,
        mainAxisSpacing: suSetSp(10.0),
        crossAxisCount: 3,
        crossAxisSpacing: suSetSp(10.0),
        children: imagesWidget,
      );
    }
    _image = Padding(
      padding: EdgeInsets.only(
        top: suSetHeight(6.0),
      ),
      child: _image,
    );
    return _image;
  }

  Future<bool> onLikeButtonTap(bool isLiked) {
    final completer = Completer<bool>();

    post.isLike = !post.isLike;
    !isLiked ? post.praisesCount++ : post.praisesCount--;
    completer.complete(!isLiked);

    TeamPraiseAPI.requestPraise(post.tid, !isLiked).catchError((e) {
      isLiked ? post.praisesCount++ : post.praisesCount--;
      completer.complete(isLiked);
      return completer.future;
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: post.replyInfo != null && post.replyInfo.isNotEmpty ? () {
            currentState.pushNamed(
              "openjmu://team-post-detail",
              arguments: {"post": post, "type": TeamPostType.comment},
            );
          } : null,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: suSetWidth(12.0),
              vertical: suSetHeight(6.0),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: suSetWidth(24.0),
              vertical: suSetHeight(8.0),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(suSetWidth(10.0)),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _header(context),
                _content,
                if (post.pics != null && post.pics.isNotEmpty) _images(context),
                if (post.replyInfo != null && post.replyInfo.isNotEmpty)
                  _replyInfo(context),
              ],
            ),
          ),
        ),
      ],
    );
  }
}