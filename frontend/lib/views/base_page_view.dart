import 'package:auto_size_text/auto_size_text.dart';
import 'package:dashi/app/theme_data.dart';
import 'package:dashi/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'base_page_viewmodel.dart';
import 'home_view.dart';

class BasePageView extends StatefulWidget {
  @override
  _BasePageViewState createState() => _BasePageViewState();
}

PageController pageCont = PageController(initialPage: 0);

_heading(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(
        text,
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

_subHeading(String text) {
  return FittedBox(
    fit: BoxFit.fitWidth,
    child: AutoSizeText(
      text,
      minFontSize: 9,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
    ),
  );
}

_toCheckList() {
  _rowItem(String text) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.brightness_1,
            size: 10,
          ),
          SizedBox(
            width: 5,
          ),
          _subHeading(text),
        ],
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rowItem("Your backend server is running correctly."),
        _rowItem("Your base url points to the backend server.")
      ],
    ),
  );
}

_errorPage() {
  return Stack(
    children: [
      Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 100,
              ),
              _heading("Well this doesn't seem right?"),
              _subHeading(
                  "Something went wrong getting data from the backend."),
              _subHeading("Please check the following:"),
              _toCheckList()
            ],
          ),
        ),
      ),
    ],
  );
}

class _BasePageViewState extends State<BasePageView>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BasePageViewModel>.reactive(
      disposeViewModel: false,
      onModelReady: (model) async {
        await model.getInfo();
      },
      viewModelBuilder: () => BasePageViewModel(),
      builder: (context, model, child) {
        _customFab(Size screen, context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: theme.colorScheme.primary,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: AnimatedIcon(
                    progress: _animationController,
                    icon: AnimatedIcons.menu_arrow,
                    color: Colors.white,
                    size: screen.height / 27,
                  ),
                ),
                onTap: () {
                  if (model.currentPage == 0) {
                    model.updateCurrentPage(1);
                    _animationController.animateTo(1);
                    pageCont.animateToPage(1,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeInCubic);
                  } else {
                    model.updateCurrentPage(0);
                    _animationController.animateTo(0);
                    pageCont.animateToPage(
                      0,
                      duration: Duration(milliseconds: 400),
                      curve: Curves.easeInCubic,
                    );
                  }
                },
              ),
            ),
          );
        }

        return Scaffold(
          floatingActionButton:
              _customFab(MediaQuery.of(context).size, context),
          body: model.ready
              ? Container(
                  decoration: model.background.backgroundImage == ""
                      ? BoxDecoration(
                          color: model.background.color != null
                              ? model.background.color
                              : Colors.transparent,
                        )
                      : BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(model.background.backgroundImage),
                          ),
                        ),
                  child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: pageCont,
                    children: <Widget>[
                      model.inError
                          ? _errorPage()
                          : HomeView(
                              apps: model.apps,
                              tags: model.tags,
                              viewType: model.viewType,
                            ),
                      SettingsView(
                        inError: model.inError,
                      ),
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        );
      },
    );
  }
}
