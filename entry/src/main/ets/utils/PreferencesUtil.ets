import { preferences } from '@kit.ArkData'
import { UIContext } from '@kit.ArkUI'
import { Logger } from './Logger'

const TAG = '[PreferencesUtil]'

export class PreferencesUtil {
  /**
   * 保存数据到首选项
   * @param preferencesName
   * @param key
   * @param value
   */
  static async savaData<T extends keyof number | number | string | boolean | Array<number> | Array<string> | Array<boolean>>(preferencesName: string,
    key: string, value: T,context: UIContext) {

    try {
      const pre = preferences.getPreferencesSync(context.getHostContext(), { name: preferencesName })
      await pre.put(key, value as preferences.ValueType).then(()=>{
        Logger.info(TAG, `savaData success: ${key} = ${value}`)
      }
      ).catch((e:Error)=>{
        Logger.error(TAG, `savaData put error: ${e.message}`)
      })
      await pre.flush().then(()=>{
        Logger.info(TAG, 'savaData flush success')
      }).catch((e:Error)=>{
        Logger.error(TAG, `savaData flush error: ${e.message}`)
      })
    }catch (e){
      Logger.error(TAG, `savaData error: ${e}`)
    }
  }

  /**
   * 获取数据
   * @param preferencesName
   * @param key
   * @param defaultValue
   * @returns
   */
  static getData<T extends keyof number | number | string | boolean | Array<number> | Array<string> | Array<boolean>>(preferencesName: string,
    key: string, defaultValue: T,context: UIContext) {
    try {
      const pre = preferences.getPreferencesSync(context.getHostContext(), { name: preferencesName })
      return pre.getSync(key, defaultValue as preferences.ValueType) as T
    }catch (e) {
      Logger.error(TAG, `getData error: ${e}`)
      return defaultValue
    }
  }

  /**
   * 删除数据
   * @param preferencesName
   * @param key
   */
  static async delAllData(preferencesName: string, key: string,context: UIContext) {
    try {
      const pre = preferences.getPreferencesSync(context.getHostContext(), { name: preferencesName })
      await pre.delete(key).then(()=>{
        Logger.info(TAG, `delAllData success: ${key}`)
      }).catch((e:Error)=>{
        Logger.error(TAG, `delAllData error: ${e.message}`)
      })
      await pre.flush()
    }catch (e) {
      Logger.error(TAG, `delAllData error: ${e}`)
    }
  }
}