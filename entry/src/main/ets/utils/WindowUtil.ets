import { window } from "@kit.ArkUI";

const TAG: string = 'WindowUtil';

export class WindowUtil {

  static getDeviceSize(context: Context): void {
    window.getLastWindow(context).then((data: window.Window) => {
      let properties = data.getWindowProperties();
      AppStorage.setOrCreate<number>('deviceHeight',px2vp(properties.windowRect.height));
      AppStorage.setOrCreate<number>('deviceWidth',px2vp(properties.windowRect.width));
    });
  }
}