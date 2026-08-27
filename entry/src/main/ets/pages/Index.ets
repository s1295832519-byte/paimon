import window from '@ohos.window';
import deviceInfo from '@ohos.deviceInfo';
import { BusinessError } from '@ohos.base';
import { Game } from '../model/game';
import { GameListModel } from '../viewModel/gameList';
import { PermissionUtil } from '../utils/PermissionUtil';
import { Permissions } from '@ohos.privacyManager';
import { UIContext } from '@kit.ArkUI';
import { GlobalContext } from '../utils/GlobalContext';
import { CommonConstants } from '../common/CommonConstants';

@Entry
@Component
struct Index {
  @State isDarkMode: boolean = false;
  @State refreshKey: number = 0;
  private navPath: NavPathStack = new NavPathStack();
  uiContext: UIContext = this.getUIContext();
  context: Context | undefined = this.uiContext.getHostContext();
  private permissions: Permissions[] = ['ohos.permission.INTERNET'];
  private gameList: Game[] = [];

  getInternetPermission(): void {
    if (this.context === undefined) {
      return;
    }
    if (!PermissionUtil.checkPermissions(this.permissions, this.context)) {
      PermissionUtil.requestPermissions(this.permissions, this.context);
    }
  }

  onPageShow(): void {
    if (!canIUse('SystemCapability.Web.Webview.Core')) {
      console.error('WebView权限不可用');
    }
    if (this.context === undefined) {
      return;
    }
    window.getLastWindow(this.context, (err, current) => {
      if (err.code) {
        console.error('获取主窗口失败:', err);
        return;
      }
      current.setWindowSystemBarEnable(['status', 'navigation']);
      current.setWindowLayoutFullScreen(false);
      if (deviceInfo.deviceType === '2in1') {
        current.setWindowDecorVisible(true);
        current.recover().catch((error: BusinessError) => console.error('恢复窗口失败:', error));
      } else if (deviceInfo.deviceType === 'phone' || deviceInfo.deviceType === 'tablet') {
        current.setPreferredOrientation(window.Orientation.PORTRAIT);
      }
    });
  }

  aboutToAppear(): void {
    this.gameList = GameListModel.getGameList();
    GlobalContext.getInstance().setContext(CommonConstants.UI_CONTEXT, this.uiContext);
    this.getInternetPermission();
  }

  private onGameClick(game: Game): void {
    try {
      this.navPath.pushPath({ name: CommonConstants.ROUTER_GAME, param: game });
    } catch (error) {
      console.error('页面跳转失败:', error);
    }
  }

  @Builder
  GameCard(game: Game): void {
    Row({ space: 15 }) {
      Image(game.icon)
        .width(80)
        .height(80)
        .borderRadius(12)
        .objectFit(ImageFit.Cover)
        .shadow({ radius: 2, color: '#20000000', offsetX: 0, offsetY: 1 });

      Text(game.name)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
        .alignSelf(ItemAlign.Center);

      Text('>')
        .fontSize(20)
        .fontColor('#999999')
        .fontWeight(FontWeight.Bold);
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 4, color: '#10000000', offsetX: 0, offsetY: 1 })
    .onClick(() => this.onGameClick(game));
  }

  build() {
    Navigation(this.navPath) {
      Column({ space: 24 }) {
        ForEach(this.gameList, (item: Game) => {
          this.GameCard(item);
        })
      }
      .width('90%')
      .height('100%');
    }
    .title('游戏列表')
    .titleMode(NavigationTitleMode.Free)
    .mode(NavigationMode.Stack)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}
