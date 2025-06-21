import { TabBar, TabBarItem, TabBarItemDistribution, TabBarScrollIndicatorSizeMode, TabBarState } from '@sj/tabbar';

@Entry
@ComponentV2
struct Index {
  build() {
    Scroll() {
      Column({ space: 20 }) {
        TextTabBarDemo()

        ImageAndTextTabBarDemo()

        TabBarScrollIndicatorDemo()

        TabBarItemDistributionDemo()

        ModifyingTabBarItems()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xEFEFEF)
  }
}

class TextTabBarItem implements TabBarItem {
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
        options: {
          itemDistribution: TabBarItemDistribution.EqualSpacing,
          itemSpacing: 24,
          scrollIndicatorOptions: {
            sizeMode: TabBarScrollIndicatorSizeMode.EqualItemContentSize,
            align: VerticalAlign.Center,
            color: 0xEFEFEF,
            extraWidth: 16,
            extraHeight: 8,
          }
        }
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
        options: {
          itemDistribution: TabBarItemDistribution.FillEqually,
        }
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
    }
    .backgroundColor(0xFFFFFF)
  }
}