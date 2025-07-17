import { TabBar, TabBarItem, TabBarItemDistribution, TabBarScrollIndicatorSizeMode, TabBarState,
  TabBarSwipeController } from '@sj/tabbar';
import { ColorUtils } from '../utils/ColorUtils';

@Entry
@ComponentV2
struct Index {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        TextTabBarDemo()

        ImageAndTextTabBarDemo()

        TabBarScrollIndicatorDemo()

        TabBarItemDistributionDemo()

        ModifyingTabBarItems()

        TabsInteractionDemo()
          .width('100%')
          .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xEFEFEF)
  }
}

class TextTabBarItem {
  text: string;

  constructor(text: string) {
    this.text = text;
  }
}

class ImageTabBarItem implements TabBarItem {
  res: Resource;
  width: number;
  height: number;

  constructor(res: Resource, width: number, height: number) {
    this.res = res;
    this.width = width;
    this.height = height;
  }
}

/// 自定义 item 布局
@Builder
function TabBarItemBuilder(index: number, item: TabBarItem, state: TabBarState) {
  /// 在这里根据 item 的具体类型创建布局
  /// 参数 state 中含有当前选中的 item 的索引, 通过与 index 进行比较, 可以确定是否是`选中状态`;

  if ( item instanceof TextTabBarItem ) {
    /// 这里对字体大小和字体颜色做了动态改变, 并且添加了属性动画;
    Text(item.text)
      .height(25)
      .textAlign(TextAlign.Center)
      .fontSize(state.currentIndex === index ? 20 : 15) // state.currentIndex 为当前选中的item的索引
      .fontWeight(FontWeight.Medium)
      .fontColor(state.currentIndex === index ? 0x121212 : 0x989898)
      .animation({ curve: 'linear', duration: 150 })
  }
  else if ( item instanceof ImageTabBarItem ) {
    /// 这里对图片大小做了动态改变(比如等比例缩小), 并且添加了属性动画;
    Image(item.res)
      .width(state.currentIndex === index ? item.width : (item.width * 0.65))
      .height(state.currentIndex === index ? item.height : (item.height * 0.65))
      .animation({ curve: 'linear', duration: 150 })
  }
}

@ComponentV2
struct TextTabBarDemo {
  @Local private mTabBarItems: TabBarItem[] = [
    new TextTabBarItem('最新'),
    new TextTabBarItem('最热'),
    new TextTabBarItem('小桥流水'),
    new TextTabBarItem('古诗词')
  ];
  @Local private mCurrentIndex: number = 2; // 可以设置默认索引位置;

  build() {
    Column() {
      Text(`TextTabBarDemo`);

      TabBar({
        items: this.mTabBarItems,
        itemBuilder: TabBarItemBuilder,
        currentIndex: this.mCurrentIndex,
        onItemClick: (index) => {
          this.mCurrentIndex = index;
        }
      })
    }
    .backgroundColor(0xFFFFFF)
  }
}

@ComponentV2
struct ImageAndTextTabBarDemo {
  private mTabBarItems = [
    new TextTabBarItem('最新'),
    new TextTabBarItem('小桥流水'),
    new ImageTabBarItem($r('app.media.startIcon'), 25.0, 25.0),
    new TextTabBarItem('古诗词'),
    new ImageTabBarItem($r('app.media.tab_img_1'), 223.0 / 96.0 * 25.0, 25.0),
    new ImageTabBarItem($r('app.media.tab_img_2'), 194.0 / 95.0 * 25.0, 25.0),

    new TextTabBarItem('最新'),
    new TextTabBarItem('小桥流水人家古道西风瘦马'),
    new ImageTabBarItem($r('app.media.startIcon'), 25.0, 25.0),
    new TextTabBarItem('古诗词'),
    new ImageTabBarItem($r('app.media.tab_img_1'), 223.0 / 96.0 * 25.0, 25.0),
    new ImageTabBarItem($r('app.media.tab_img_2'), 194.0 / 95.0 * 25.0, 25.0),
  ];

  @Local private mCurrentIndex: number = 0;

  build() {
    Column() {
      Text(`ImageAndTextTabBarDemo`);

      TabBar({
        items: this.mTabBarItems,
        itemBuilder: TabBarItemBuilder,
        currentIndex: this.mCurrentIndex,
        onItemClick: (index) => {
          this.mCurrentIndex = index;
        }
      })
    }
    .backgroundColor(0xFFFFFF)
  }
}

// 滚动条demo1
@ComponentV2
struct TabBarScrollIndicatorDemo {
  private mTabBarItems = [
    new TextTabBarItem('最新'),
    new TextTabBarItem('最热'),
    new TextTabBarItem('小桥流水人家'),
    new TextTabBarItem('古诗词')
  ];

  @Local private mCurrentIndex: number = 0;

  build() {
    Column() {
      Text(`TabBarScrollIndicatorDemo`);

      TabBar({
        items: this.mTabBarItems,
        itemBuilder: TabBarItemBuilder,
        currentIndex: this.mCurrentIndex,
        onItemClick: (index, item) => {
          this.mCurrentIndex = index;
        },

        // 配置项
        itemDistribution: TabBarItemDistribution.EqualSpacing,
        itemSpacing: 24,
        scrollIndicatorSizeMode: TabBarScrollIndicatorSizeMode.EqualItemContentSize,
        scrollIndicatorAlign: VerticalAlign.Center,
        scrollIndicatorColor: 0xEFEFEF,
        scrollIndicatorExtraWidth: 16,
        scrollIndicatorExtraHeight: 8,
      })
    }
    .backgroundColor(0xFFFFFF)
  }
}

@ComponentV2
struct TabBarItemDistributionDemo {
  private mTabBarItems = [
    new TextTabBarItem('最新'),
    new TextTabBarItem('最热'),
    new TextTabBarItem('小桥'),
    new TextTabBarItem('古诗词')
  ];

  @Local private mCurrentIndex: number = 0;

  build() {
    Column() {
      Text(`TabBarItemDistributionDemo.FillEqually`)

      TabBar({
        items: this.mTabBarItems,
        itemBuilder: TabBarItemBuilder,
        currentIndex: this.mCurrentIndex,
        onItemClick: (index, item) => {
          this.mCurrentIndex = index;
        },
        // 配置项
        itemDistribution: TabBarItemDistribution.FillEqually,
      })
    }
    .backgroundColor(0xFFFFFF)
  }
}

/** 管理 items 和 当前索引;
 *
 * 删除项目或插入新项目时会维护当前索引;
 * */
@ObservedV2
class TabBarItemManager {
  @Trace private mItems: TabBarItem[];
  @Trace private mCurrentIndex: number;

  constructor(items: TabBarItem[], currentIndex: number = 0) {
    this.mItems = items;
    this.mCurrentIndex = currentIndex;
  }

  /** @Trace
   *
   * 当前选中的 item 的索引;
   * */
  get currentIndex(): number { return this.mCurrentIndex; }

  set currentIndex(newIndex: number) { this.mCurrentIndex = newIndex; }

  /** @Trace
   *
   * 当前的 items;
   * */
  get items(): TabBarItem[] { return this.mItems; }

  /** 获取当前的items的数量; */
  get length(): number { return this.mItems.length; }

  setItems(newItems: TabBarItem[], currentIndex: number = 0) {
    this.mItems = newItems;
    this.mCurrentIndex = currentIndex;
  }

  addItem(item: TabBarItem) {
    this.mItems.push(item);
  }

  addItems(items: TabBarItem[]) {
    this.mItems.push(...items);
  }

  /** 删除指定位置的 item; */
  deleteItem(index: number): boolean {
    if ( index >= this.mItems.length ) {
      return false;
    }

    this.mItems.splice(index, 1);

    // 需维护好 index
    // 如果数组为空, 则将 index 重置为 0;
    if ( this.mItems.length == 0 ) {
      this.mCurrentIndex = 0;
      return true;
    }

    // 如果删除的是前面的 item, currentIndex 需 - 1;
    if ( index < this.mCurrentIndex || (index == this.mCurrentIndex && index == this.mItems.length) ) {
      this.mCurrentIndex -= 1;
    }
    return true;
  }

  /** 在指定的位置插入 item; */
  insertItem(index: number, item: TabBarItem): boolean {
    if ( index > this.mItems.length ) {
      return false;
    }

    this.mItems.splice(index, 0, item);

    // 需维护好 index
    // 如果数组之前为空, 则将 index 置为 0;
    if ( this.mItems.length == 1 ) {
      this.mCurrentIndex = 0;
      return true;
    }

    // 如果在前面插入了新的 item, currentIndex 需 + 1;
    if ( index <= this.mCurrentIndex ) {
      this.mCurrentIndex += 1;
    }
    return true;
  }
}

/// 修改数组
@ComponentV2
struct ModifyingTabBarItems {
  private mItemManager: TabBarItemManager = new TabBarItemManager([
    new TextTabBarItem('最新'),
    new TextTabBarItem('最热'),
    new TextTabBarItem('小桥'),
    new TextTabBarItem('古诗词')
  ]);

  @Local private mShows: boolean = false;

  build() {
    Column() {
      Text(`ModifyingTabBarItems`)

      Row({ space: 20 }) {
        Text('添加')
          .textAlign(TextAlign.Center)
          .height('100%')
          .borderWidth(1)
          .borderColor(0x121212)
          .onClick(() => {
            this.mShows = true;
            this.mItemManager.addItem(new TextTabBarItem(`Tab_${this.mItemManager.length}`));
          })

        Text(`删除`)
          .textAlign(TextAlign.Center)
          .height('100%')
          .borderWidth(1)
          .borderColor(0x121212)
          .onClick(() => {
            const randomIndex = Math.floor((Math.random() * 100)) % this.mItemManager.length;
            this.mItemManager.deleteItem(randomIndex);
          })

        Text(`随机插入`)
          .textAlign(TextAlign.Center)
          .height('100%')
          .borderWidth(1)
          .borderColor(0x121212)
          .onClick(() => {
            const randomIndex = Math.floor((Math.random() * 100)) % (this.mItemManager.length + 1);
            this.mItemManager.insertItem(randomIndex, new TextTabBarItem(`R_${this.mItemManager.length}`))
          })
      }
      .height(44)

      TabBar({
        items: this.mItemManager.items,
        itemBuilder: TabBarItemBuilder,
        currentIndex: this.mItemManager.currentIndex,
        onItemClick: (index, item) => {
          this.mItemManager.currentIndex = index;
        },
      })

      if ( this.mShows ) {
        TabBar({
          items: this.mItemManager.items,
          itemBuilder: TabBarItemBuilder,
          currentIndex: this.mItemManager.currentIndex,
          onItemClick: (index, item) => {
            this.mItemManager.currentIndex = index;
          },
        })
      }
    }
    .backgroundColor(0xFFFFFF)
  }
}

/// 与 tabs 联动
@ComponentV2
struct TabsInteractionDemo {
  @Local private mTabs: TabViewModel[] = [
    new TabViewModel("最新", "#00FF00"),
    new TabViewModel("最热", "#00FFFF"),
    new TabViewModel("小桥流水", "#FFFF00"),
    new TabViewModel("古诗词", "#00FF0F"),
    new TabViewModel("这是一条震古烁今的文本", "#0FF000")
  ];

  private mInitialIndex = 2; // Tabs的初始索引; 可以设置默认索引位置, 这里修改为 2;
  @Local private mCurrentIndex: number = 2; // 可以设置默认索引位置, 这里修改为 2;

  private mTabsController: TabsController = new TabsController();
  private mTabsWidth: number = 0; // 记录 tabs 的宽度, TabBarSwipeController 需要;

  private mTabBarSwipeController = new TabBarSwipeController(); // 用于传递 tabs 的滑动事件; 实现指示条同步滑动及 item 的缩放控制;

  build() {
    Column() {
      Text(`TabsInteractionDemo(与 Tabs 联动)\n请左右滑动 Tab`)
        .textAlign(TextAlign.Center);

      TabBar({
        items: this.mTabs,
        currentIndex: this.mCurrentIndex,
        itemBuilder: TabBarItemBuilder2, // 传递 TabBarItemBuilder2, 用于构建自定义的 item 布局;
        swipeController: this.mTabBarSwipeController, // 传递 mTabBarSwipeController, 实现指示条同步滑动及 item 的缩放控制;
        onItemClick: (index) => {
          this.mCurrentIndex = index;
          this.mTabsController.changeIndex(index);
        }
      })

      Tabs({
        barPosition: BarPosition.Start,
        index: this.mInitialIndex,
        controller: this.mTabsController,
      }){
        ForEach(this.mTabs, (item: TabViewModel) => {
          TabContent()
          .backgroundColor(item.pageBackgroundColor)
          .width('100%')
          .height('100%')
        })
      }
      .vertical(false)
      .barHeight(0)
      .width('100%')
      .layoutWeight(1)
      .onAreaChange((_, newArea) => {
        this.mTabsWidth = newArea.width as number; // 记录 tabs 的布局宽度; TabBarSwipeController 需要;
      })
      .onAnimationStart((index, targetIndex, event) => {
        this.mCurrentIndex = targetIndex
        this.mTabBarSwipeController.animationStart(index, targetIndex, event, this.mTabsWidth); // 传递 tabs 滑动事件
      })
      .onAnimationEnd((index, event) => {
        this.mTabBarSwipeController.animationEnd(index, event, this.mTabsWidth); // 传递 tabs 滑动事件
      })
      .onGestureSwipe((index, event) => {
        this.mTabBarSwipeController.swipe(index, event, this.mTabsWidth); // 传递 tabs 滑动事件
      })
    }
    .backgroundColor(0xFFFFFF)
    .width('100%')
    .height('100%')
  }
}

class TabViewModel {
  readonly title: string;
  readonly pageBackgroundColor: string;

  constructor(title: string, pageBackgroundColor: string) {
    this.title = title;
    this.pageBackgroundColor = pageBackgroundColor;
  }
}

@Builder
function TabBarItemBuilder2(index: number, item: TabBarItem, state: TabBarState) {
  if ( item instanceof TabViewModel ) {
    Text(item.title)
      .height(25)
      .textAlign(TextAlign.Center)
      .fontSize(15 + (20 - 15) * state.getItemScaleFactor(index)) // 这里获取缩放因子: 当前尺寸 = 基础尺寸 + (最大尺寸 - 基础尺寸) * scaleFactor; 缩放因子是由 TabBarSwipeController 传递的滑动事件计算得出;
      .fontWeight(FontWeight.Medium)
      .fontColor(ColorUtils.lerpColor(0x989898, 0x121212, state.getItemScaleFactor(index))) // 设置字体颜色线性渐变, 未选中时字体颜色为 0x989898, 选中时为 0x121212;
      .animation(!state.isSwiping ? { duration: 150.0, curve: Curve.Linear } : undefined) // 这里有个细节就是当进行 tabs 的滑动交互(state.isSwiping)时不开启动画, 其他时候启用属性动画;
  }
}
