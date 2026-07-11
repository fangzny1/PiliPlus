import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/utils/rcmd_discover.dart';
import 'package:PiliPlus/utils/storage_pref.dart';

class RcmdController extends CommonListController {
  late bool enableSaveLastData = Pref.enableSaveLastData;
  final bool appRcmd = Pref.appRcmd;
  int? lastRefreshAt;
  late bool savedRcmdTip = Pref.savedRcmdTip;

  // Used only when discover mode is active.
  bool _discoverEnd = false;

  /// When discover mode is on, [isEnd] is controlled by [_discoverEnd]
  /// instead of the base class, so the infinite-scroll behaviour of the
  /// stock feed doesn't trigger load-more for the single-batch engine.
  @override
  bool get isEnd => Pref.useDiscoverRcmd ? _discoverEnd : false;

  @override
  void onInit() {
    super.onInit();
    page = 0;
    queryData();
  }

  @override
  Future<LoadingState> customGetData() async {
    if (Pref.useDiscoverRcmd) {
      if (page > 0) {
        _discoverEnd = true;
        return const Success([]);
      }
      _discoverEnd = false;
      return Success(await RcmdDiscoverEngine.fetch());
    }
    return appRcmd
        ? VideoHttp.rcmdVideoListApp(freshIdx: page)
        : VideoHttp.rcmdVideoList(freshIdx: page, ps: 20);
  }

  @override
  bool handleError(String? errMsg) => enableSaveLastData;

  @override
  void handleListResponse(List dataList) {
    if (Pref.useDiscoverRcmd) return;
    if (enableSaveLastData && page == 0) {
      if (loadingState.value case Success(:final response)) {
        if (response != null && response.isNotEmpty) {
          if (savedRcmdTip) {
            lastRefreshAt = dataList.length;
          }
          if (response.length > 200) {
            dataList.addAll(response.take(50));
          } else {
            dataList.addAll(response);
          }
        }
      }
    }
  }

  @override
  Future<void> onRefresh() {
    page = 0;
    _discoverEnd = false;
    return queryData();
  }
}
