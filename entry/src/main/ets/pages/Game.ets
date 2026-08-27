import webview from '@ohos.web.webview';
import window from '@ohos.window';
import deviceInfo from '@ohos.deviceInfo';
import { BusinessError } from '@ohos.base';
import { MobileUserAgent, PCUserAgent } from '../common';
import { Game } from '../model/game';

const LOAD_TIMEOUT: number = 10000;

@Component
struct GamePage {
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State errorMessage: string = '';
  @State game: Game = {} as Game;
  @State webViewReady: boolean = false;

  private navPathStack: NavPathStack = new NavPathStack();
  private loadTimer: number = 0;
  private context: Context | undefined = this.getUIContext().getHostContext();
  private userAgent: string = deviceInfo.deviceType === '2in1' ? PCUserAgent : MobileUserAgent;
  controller: webview.WebviewController = new webview.WebviewController();

  private initializeDestination(context: NavDestinationContext): void {
    this.navPathStack = context.pathStack;
    this.game = context.pathInfo.param as Game;
    if (!this.game || !this.game.url) {
      this.hasError = true;
      this.errorMessage = '游戏参数无效，无法加载页面';
      return;
    }
    this.enterGameWindow();
    this.startLoadTimeout();
    console.info('游戏页面初始化完成:', this.game.name, this.game.url);
  }

  private startLoadTimeout(): void {
    this.clearLoadTimeout();
    this.loadTimer = setTimeout(() => {
      if (this.isLoading) {
        console.info('WebView加载超时，自动显示内容');
        this.isLoading = false;
        this.webViewReady = true;
      }
    }, LOAD_TIMEOUT);
  }

  private clearLoadTimeout(): void {
    if (this.loadTimer !== 0) {
      clearTimeout(this.loadTimer);
      this.loadTimer = 0;
    }
  }

  private enterGameWindow(): void {
    if (this.context === undefined) {
      return;
    }
    window.getLastWindow(this.context, (err, current) => {
      if (err.code) {
        console.error('获取游戏窗口失败:', err);
        return;
      }
      current.setWindowSystemBarEnable([]);
      current.setWindowLayoutFullScreen(true);
      if (deviceInfo.deviceType === '2in1') {
        current.setWindowDecorVisible(false);
        current.maximize(window.MaximizePresentation.ENTER_IMMERSIVE_DISABLE_TITLE_AND_DOCK_HOVER)
          .catch((error: BusinessError) => console.error('进入沉浸模式失败:', error));
      } else if (deviceInfo.deviceType === 'phone' || deviceInfo.deviceType === 'tablet') {
        current.setPreferredOrientation(window.Orientation.LANDSCAPE);
      }
    });
  }

  private restoreWindow(): void {
    if (this.context === undefined) {
      return;
    }
    window.getLastWindow(this.context, (err, current) => {
      if (err.code) {
        console.error('恢复窗口失败:', err);
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

  private leaveGame(): boolean {
    this.navPathStack.pop();
    return true;
  }

  build() {
    NavDestination() {
      Stack() {
        if (this.hasError) {
          Column() {
            Text('加载失败').fontSize(20).fontWeight(FontWeight.Bold).margin({ bottom: 10 });
            Text(this.errorMessage).fontSize(14).textAlign(TextAlign.Center).margin({ bottom: 20 });
            Button('重试').onClick(() => {
              this.hasError = false;
              this.isLoading = true;
              this.controller.refresh();
            });
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor(0xF5F5F5)
          .padding(20);
        } else {
          Web({ src: this.game.url, controller: this.controller })
            .width('100%')
            .height('100%')
            .fileAccess(true)
            .javaScriptAccess(true)
            .domStorageAccess(true)
            .databaseAccess(true)
            .mixedMode(MixedMode.All)
            .onlineImageAccess(true)
            .zoomAccess(true)
            .pinchSmooth(true)
            .backgroundColor(0xFFFFFF)
            .userAgent(this.userAgent)
            .onPageBegin(() => {
              console.info('页面开始加载:', this.game.url);
              this.isLoading = false;
              this.hasError = false;
              this.webViewReady = true;
              this.clearLoadTimeout();
            })
            .onPageEnd(() => {
              console.info('页面加载完成:', this.game.url);
              this.isLoading = false;
              this.webViewReady = true;
            })
            .onHttpErrorReceive((event) => {
              console.error('HTTP错误:', event.response.getResponseCode(), event.response.getReasonMessage());
              if (!this.webViewReady) {
                this.hasError = true;
                this.errorMessage = '页面加载失败，请检查网络连接';
              }
            });
        }
      }
      .width('100%')
      .height('100%');
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => this.initializeDestination(context))
    .onBackPressed(() => this.leaveGame())
    .onDisAppear(() => {
      this.clearLoadTimeout();
      this.restoreWindow();
    });
  }
}


@Builder
export function GamePageBuilder(){
  GamePage()
}