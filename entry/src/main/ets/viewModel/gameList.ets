import { Game } from '../model/game';

export class GameListModel {
  private static  gameList: Game[] = [
    {
      name: '原神',
      url: 'https://ys.mihoyo.com/cloud',
      icon: $r('app.media.genshin'),
      nickname: '旅行者',
      tips: [
        '你要休息了吗？ 尘歌壶里的菜记得收哦！',
        '你要休息了吗？ 每日任务交了吗？',
        '你要休息了吗？ 今天的树脂用完了吗？',
        '你要休息了吗？ 今天有和壶里的大家说说话吗？'
      ]
    },
    {
      name: '崩坏·星穹铁道',
      url: 'https://sr.mihoyo.com/cloud',
      icon: $r('app.media.star_rail'),
      nickname: '开拓者',
      tips: [
        '你要休息了帕？',
        '开拓者，今天的模拟宇宙打了没有？',
        '开拓者，今天的委托完成了吗？'
      ]
    }
  ];

  public static getGameList():Game[] {
    return GameListModel.gameList;
  }
}