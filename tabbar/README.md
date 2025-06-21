# TabBar for ArkUI

一个标签栏组件，适用于页面频道或选项切换等场景。

## ✨ 特性

* `TabBarItem`完全自定义布局
* `TabBarItem`多种排列分布策略（等间距、等宽、自适应）
* `ScrollIndicator`滚动指示条可配置

---

## ✅ 示例效果

![](snapshot.jpg)

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
  @Local private mTabBarItems: TabBarItem[] = [
    new TextTabBarItem('最新'),
    new TextTabBarItem('最热'),
  ];
  @Local private mCurrentIndex: number = 1; // 可以设置默认索引位置;

  build() {
    TabBar({
      items: this.mTabBarItems,
      itemBuilder: TabBarItemBuilder,   // 这里传入 item 自定义的 Builder;
      currentIndex: this.mCurrentIndex,
      onItemClick: (index) => {
        this.mCurrentIndex = index;     // item 点击回调
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
      .fontSize(state.currentIndex === index ? 20 : 15) // state.currentIndex 是当前选中的 item 的索引, 这里设置选中时字体大小为20, 未选中时字体大小为15;
      .fontWeight(FontWeight.Medium)
      .fontColor(state.currentIndex === index ? 0x121212 : 0x989898)
      .animation({ curve: 'linear', duration: 150 })
  }
}
```
