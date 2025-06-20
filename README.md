# TabBar for ArkUI

`TabBar` 是一个标签栏组件，适用于页面导航或选项切换功能。

## ✨ 特性

* `TabBarItem`自定义布局
* `TabBarItem`多种分布策略（等间距、等宽、自适应）
* 滚动指示条可配置

---

## ✅ 示例效果

![](tabbar/snapshot.jpg)

---

## 📦 安装
```shell
ohpm i @sj/tabbar
```

---

## 🧩 在项目中引用

请在需要依赖的模块找到 oh-package.json5 文件, 新增如下依赖, 执行同步后等待安装完成;
```json
{
  "dependencies": {
    "@sj/tabbar": "^1.0.0"
  }
}
```

---

## 🚀 使用方法

```ts
import { TabBar, TabBarItem, TabBarState } from '@sj/tabbar';

@ComponentV2
struct TextTabBarDemo {
  private mState: TabBarState = new TabBarState();

  private mTabBarItems = [
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

/// 自定义 item 数据类
class TextTabBarItem implements TabBarItem {
  text: string;

  constructor(text: string) {
    this.text = text;
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
      .fontSize(state.currentIndex === index ? 20 : 15) // state.currentIndex 为当前选中的item的索引, 就是说选中时字体大小为20, 未选中时字体大小为15;
      .fontWeight(FontWeight.Medium)
      .fontColor(state.currentIndex === index ? 0x121212 : 0x989898)
      .animation({ curve: 'linear', duration: 150 })
  }
}
```

---

## 📖 属性说明

### TabBarOptions

| 属性名                      | 类型                             | 默认值            | 描述           |
| ------------------------ | ------------------------------ | -------------- | ------------ |
| `barHeight`              | `Length`                       | `44.0`         | TabBar 的整体高度 |
| `itemDistribution`       | `TabBarItemDistribution`       | `EqualSpacing` | item 排列方式    |
| `itemSpacing`            | `number`                       | `12.0`         | item 之间的间隔   |
| `scrollIndicatorStyle`   | `TabBarScrollIndicatorStyle`   | `Rounded`      | 指示条样式        |
| `scrollIndicatorOptions` | `TabBarScrollIndicatorOptions` | 详见下表           | 指示条配置项       |
| `contentStartOffset`     | `number`                       | `12.0`         | 内容起始边距       |
| `contentEndOffset`       | `number`                       | `12.0`         | 内容结束边距       |

### TabBarScrollIndicatorOptions

| 属性名            | 类型                              | 默认值             | 描述                       |
| -------------- | ------------------------------- | --------------- |--------------------------|
| `sizeMode`     | `TabBarScrollIndicatorSizeMode` | `SpecifiedSize` | 尺寸模式（指定大小或与 item 内容宽度一致） |
| `width`        | `number`                        | `12.0`          | 指定宽度                     |
| `height`       | `number`                        | `3.0`           | 指定高度                     |
| `color`        | `ResourceColor`                 | `0x121212`      | 指示条颜色                    |
| `align`        | `VerticalAlign`                 | `Bottom`        | 垂直对齐方式                   |
| `bottomMargin` | `number`                        | `5.0`           | 距底部偏移量                   |
| `extraWidth`   | `number`                        | `0.0`           | 额外宽度                     |
| `extraHeight`  | `number`                        | `0.0`           | 额外高度                     |

---

## 🎛️ 枚举类型

### TabBarItemDistribution

| 枚举值            | 描述                     |
| -------------- | ---------------------- |
| `EqualSpacing` | 等间距排列，使用 `itemSpacing` |
| `FillEqually`  | 等宽排列，占满容器宽度            |
| `AutoAdaptive` | 内容少时自适应撑满，内容多时滚动排列     |

### TabBarScrollIndicatorStyle

| 枚举值       | 描述      |
| --------- | ------- |
| `None`    | 不显示指示条  |
| `Rounded` | 圆角样式指示条 |

### TabBarScrollIndicatorSizeMode

| 枚举值                    | 描述                |
| ---------------------- |-------------------|
| `SpecifiedSize`        | 使用指定的宽高           |
| `EqualItemContentSize` | 宽高与当前 item 内容大小一致 |

---

## 🧱 模块组成

| 模块名                   | 说明                       |
| --------------------- |--------------------------|
| `TabBar`              | 主组件，提供数据绑定与事件接口          |
| `TabBarLayout`        | 自定义布局，支持 item 的位置测量与响应更新 |
| `ScrollIndicator`     | 滚动条组件，可自定义样式与位置          |
| `TabBarLayoutManager` | 管理 item 位置与尺寸   |
| `TabBarState`         | 记录当前选中项与上一个选中项的状态        |

