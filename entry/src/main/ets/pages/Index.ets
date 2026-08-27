import router from '@ohos.router';
import window from '@ohos.window';
import deviceInfo from '@ohos.deviceInfo';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import { Game } from '../model/game'
import {GameListModel}from "../viewModel/gameList"
import { PermissionUtil } from '../utils/PermissionUtil';
import { Permissions } from '@ohos.privacyManager';
import { UIContext } from '@kit.ArkUI';
import { GlobalContext } from '../utils/GlobalContext';
import { CommonConstants } from '../common/CommonConstants';

@Entry
@Component
struct Index {
  @State isDarkMode: boolean = false
  @State refreshKey: number = 0
  private navPath:NavPathStack = new NavPathStack()
  uiContext:UIContext = this.getUIContext()
  context :Context | undefined = this.uiContext.getHostContext()

  private permissions:Permissions[] = ["ohos.permission.INTERNET"]

  getInternetPermission(){
    if(this.context == undefined){
      return
    }
    let hasInternet =  PermissionUtil.checkPermissions(this.permissions,this.context)
    if(!hasInternet){
      PermissionUtil.requestPermissions(this.permissions,this.context)
    }
  }

  // 游戏列表数据
  private gameList: Game[] = []

  onPageShow() {
    if (!canIUse('SystemCapability.Web.Webview.Core')) {
      console.error('WebView权限不可用')
    }
    window.getLastWindow(this.context, (err, current) => {
      current.setWindowSystemBarEnable(['status', 'navigation'])
      current.setWindowLayoutFullScreen(false)

      if (deviceInfo.deviceType === '2in1') {
        current.setWindowDecorVisible(true)
        current.recover().catch((e: BusinessError) => console.error('recover failed', e))
      } else if (deviceInfo.deviceType === 'phone' || deviceInfo.deviceType === 'tablet') {
        current.setPreferredOrientation(window.Orientation.PORTRAIT)
      }
    })
  }

  aboutToAppear(): void {
    this.gameList = GameListModel.getGameList()

    GlobalContext.getInstance().setContext(CommonConstants.UI_CONTEXT,this.uiContext)

    this.getInternetPermission()

  }

  // 游戏卡片点击事件
  private onGameClick(game: Game) {
    try {
      router.pushUrl({
        url: 'pages/Game',
        params: {
          type: SlideEffect.Top,
          data: game
        }
      }, router.RouterMode.Single)
    } catch (error) {
      console.error('页面跳转失败:', error)
    }
  }

  // 创建游戏卡片组件
  @Builder GameCard(game: Game) {
    Row({ space: 15 }) {
      // 游戏图标
      Image(game.icon)
        .width(80)
        .height(80)
        .borderRadius(12)
        .objectFit(ImageFit.Cover)
        .shadow({ radius: 2, color: '#20000000', offsetX: 0, offsetY: 1 })

      // 游戏名称
      Text(game.name)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
        .alignSelf(ItemAlign.Center)

      // 箭头指示器
      Text('>')
        .fontSize(20)
        .fontColor('#999999')
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 4, color: '#10000000', offsetX: 0, offsetY: 1 })
    .onClick(() => this.onGameClick(game))
  }

  build() {
      Navigation(this.navPath) {
        // 游戏列表
        Column({ space: 24 }) {
          ForEach(this.gameList, (item: Game, index: number) => {
            this.GameCard(item)
          })
        }
        .padding({top: 20})
        .width('90%')
        .height('100%')
      }
      .title('游戏列表')
      .titleMode(NavigationTitleMode.Free)
      .mode(NavigationMode.Stack)
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
  }
}