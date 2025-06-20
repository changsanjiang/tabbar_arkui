import { TabBar, TabBarItem, TabBarItemDistribution, TabBarScrollIndicatorSizeMode, TabBarState } from '@sj/tabbar';

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
  private mState: TabBarState = new TabBarState();

  private mTabBarItems: TabBarItem[] = [
    new TextTabBarItem('最新'),
    new TextTabBarItem('最热'),
    new TextTabBarItem('小桥流水'),
    new TextTabBarItem('古诗词')
  ];

  aboutToAppear(): void {
    this.mState.currentIndex = 2; // 默认选中索引 2 的 item;
  }

  build() {
    TabBar({
      items: this.mTabBarItems,
      itemBuilder: TabBarItemBuilder,
      state: this.mState,
      onItemClick: (index, item) => {
        this.mState.currentIndex = index;
      }
    })
  }
}

@ComponentV2
struct ImageAndTextTabBarDemo {
  private mState: TabBarState = new TabBarState();

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

  build() {
    Column() {
      Text(`ImageAndTextTabBarDemo`);

      TabBar({
        items: this.mTabBarItems,
        itemBuilder: TabBarItemBuilder,
        state: this.mState,
        onItemClick: (index, item) => {
          this.mState.currentIndex = index;
        }
      })
    }
  }
}

// 滚动条demo1
@ComponentV2
struct TabBarScrollIndicatorDemo {
  private mState: TabBarState = new TabBarState();

  private mTabBarItems = [
    new TextTabBarItem('最新'),
    new TextTabBarItem('最热'),
    new TextTabBarItem('小桥流水人家'),
    new TextTabBarItem('古诗词')
  ];

  build() {
    Column() {
      Text(`TabBarScrollIndicatorDemo`);

      TabBar({
        items: this.mTabBarItems,
        itemBuilder: TabBarItemBuilder,
        state: this.mState,
        onItemClick: (index, item) => {
          this.mState.currentIndex = index;
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
  }
}

@ComponentV2
struct TabBarItemDistributionDemo {
  private mState: TabBarState = new TabBarState();

  private mTabBarItems = [
    new TextTabBarItem('最新'),
    new TextTabBarItem('最热'),
    new TextTabBarItem('小桥'),
    new TextTabBarItem('古诗词')
  ];

  build() {
    Column() {
      Text(`TabBarItemDistributionDemo.FillEqually`)

      TabBar({
        items: this.mTabBarItems,
        itemBuilder: TabBarItemBuilder,
        state: this.mState,
        onItemClick: (index, item) => {
          this.mState.currentIndex = index;
        },
        // 配置项
        options: {
          itemDistribution: TabBarItemDistribution.FillEqually,
        }
      })
    }
  }
}


@Entry
@ComponentV2
struct Index {
  build() {
    Column({ space: 25 }) {
      TextTabBarDemo()

      ImageAndTextTabBarDemo()

      TabBarScrollIndicatorDemo()

      TabBarItemDistributionDemo()
    }
    .width('100%')
    .height('100%')
  }
}