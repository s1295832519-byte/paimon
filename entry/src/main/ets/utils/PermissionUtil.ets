import { abilityAccessCtrl, Context, Permissions } from '@kit.AbilityKit';
import { Logger } from './Logger';



const TAG = 'PermissionUtil';

export class PermissionUtil {
  /**
   * 请求权限
   */
  static async requestPermissions(permissions: Permissions[],context:Context): Promise<boolean> {

    const atManager = abilityAccessCtrl.createAtManager();

    try {
      const result = await atManager.requestPermissionsFromUser(context, permissions);
      return result.authResults.every(item => item === 0);
    } catch (error) {
      Logger.error(TAG,'请求权限失败:', JSON.stringify(error as Error));
      return false;
    }
  }

  /**
   * 检查权限
   */
  static checkPermissions(permissions: Permissions[],context:Context): boolean {

    const atManager = abilityAccessCtrl.createAtManager();

    return permissions.every(permission => {
      try {
        const result = atManager.checkAccessTokenSync(
          context.applicationInfo.accessTokenId,
          permission
        );
        return result === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
      }catch (error) {
        Logger.error(TAG, `checkPermissions error: ${JSON.stringify(error)}`);
        return false;
      }
    });
  }
}