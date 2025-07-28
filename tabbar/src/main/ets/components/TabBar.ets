/** TabBar 中 item 的排列方式。*/
export enum TabBarItemDistribution {
  /** item 等间距排列，使用指定的 itemSpacing。 */
  EqualSpacing,

  /** item 等宽排列，平均分配容器宽度，忽略 itemSpacing。 */
  FillEqually,

  /** 自适应分布。
   * - 内容少不可滑动时自动拉伸间距撑满容器，这个间距必定 >= itemSpacing。
   * - 内容多可滑动时等间距排列，使用指定的 itemSpacing。
   */
  AutoAdaptive,
}

/** 指示条大小。 */
export enum TabBarScrollIndicatorSizeMode {
  /** 使用指定的大小; */
  SpecifiedSize,
  /** 使用 item 内容大小; */
  EqualItemContentSize,
}

/** 指示条样式; */
export enum TabBarScrollIndicatorStyle {
  /** 不显示指示条; */
  None,
  /** 圆角/胶囊样式; */
  Rounded,
}

/** 指示条滑动行为方式; */
export enum TabBarScrollIndicatorBehavior {
  /** 滑动过程中指示条渐渐拉长再渐渐恢复; */
  Stretch,
  /** 指示条同步滑动; */
  Follow,
}

/** 可以是任意对象, 对应 itemBuilder 构建参数中的 item; */
export type TabBarItem = Object;

/** 可以是任意对象，对应 itemBuilder 构建参数中的 options;  */
export type TabBarItemBuilderOptions = Object;

/** 记录着当前 TabBar 的状态; */
export interface TabBarState {
  /**
   * @Trace
   *
   * 当前选中的 item 的索引.
   *
   * 可用于判断是否选中了某个 item, 例如:
   *   isSelected = state.currentIndex == index;
   *
   */
  readonly currentIndex: number;

  /**
   * 指示当前 TabBar 是否处于滑动交互中。
   *
   * 当用户在 `Tabs` 上进行滑动(左右切换)时，此值将变为 `true`, 在滑动交互结束后变回 `false`.
   *
   */
  readonly isSwiping: boolean;

  /**
   * @Trace
   *
   * 获取指定位置的 item 的缩放因子, 取值范围为 [0.0, 1.0].
   *
   * TabBar 会在接收到 TabBarSwipeController 的滑动事件后, 实时更新各 item 的缩放因子.
   *
   * 通常用于实现缩放动画, 例如:
   *   item 当前尺寸 = 基础尺寸 + (最大尺寸 - 基础尺寸) * scaleFactor;
   *
   * 随着滑动的进行:
   *   - 当前选中的 item 的缩放因子会从 1.0 平滑过渡到 0.0;
   *   - 将要选中的 item 的缩放因子会从 0.0 逐渐增大到 1.0.
   *
   * */
  getItemScaleFactor(index: number): number;
}

/** 用于传递 tabs 的滑动事件; 实现指示条同步滑动及 item 的缩放控制; */
export class TabBarSwipeController {
  animationStart(index: number, targetIndex: number, event: TabsAnimationEvent, tabsWidth: number): void {
    this._onAnimationStart?.(index, targetIndex, event, tabsWidth);
  }

  animationEnd(index: number, event: TabsAnimationEvent, tabsWidth: number): void {
    this._onAnimationEnd?.(index, event, tabsWidth);
  }

  swipe(index: number, event: TabsAnimationEvent, tabsWidth: number): void {
    this._onSwipeEvent?.(index, event, tabsWidth);
  }

  /** 这三个 block 请勿设置, TabBar 内部将会使用它们来监听滑动事件; */
  _onAnimationStart?: (index: number, targetIndex: number, event: TabsAnimationEvent, tabsWidth: number) => void;
  _onAnimationEnd?: (index: number, event: TabsAnimationEvent, tabsWidth: number) => void;
  _onSwipeEvent?: (index: number, event: TabsAnimationEvent, tabsWidth: number) => void;
}

@ComponentV2
export struct TabBar {
  @Require @Param items: TabBarItem[];
  @Require @Param currentIndex: number;
  /** TabBarItem 的构建函数; */
  @BuilderParam itemBuilder: (index: number, item: TabBarItem, state: TabBarState, options?: TabBarItemBuilderOptions) => void;
  /** 为 itemBuilder 添加额外参数, 对应 itemBuilder 构建参数中的 options; */
  @Param itemBuilderOptions?: TabBarItemBuilderOptions = undefined;
  /** 点击 item 的回调; */
  @Event onItemClick: (index: number, item: TabBarItem, state: TabBarState) => void;
  /** 用于传递 tabs 的滑动事件; 实现指示条同步滑动及 item 的缩放控制; */
  @Param swipeController?: TabBarSwipeController = undefined;

  /** TabBar 的整体高度; 默认值: 44.0; */
  @Param barHeight: Length = 44.0;
  /** item 排列方式; 默认值: TabBarItemDistribution.EqualSpacing; */
  @Param itemDistribution: TabBarItemDistribution = TabBarItemDistribution.EqualSpacing;
  /** item 之间的间隔; 默认值: 12.0; */
  @Param itemSpacing: number = 12.0;
  /** 指示条样式; 默认值: TabBarScrollIndicatorStyle.Rounded, 默认圆角/胶囊样式; */
  @Param scrollIndicatorStyle: TabBarScrollIndicatorStyle = TabBarScrollIndicatorStyle.Rounded;
  /** 指示条宽度模式; 默认值: TabBarScrollIndicatorSizeMode.SpecifiedSize, 使用指定的大小; */
  @Param scrollIndicatorSizeMode: TabBarScrollIndicatorSizeMode = TabBarScrollIndicatorSizeMode.SpecifiedSize;
  /** 指示条滑动行为方式; 默认值: TabBarScrollIndicatorBehavior.Stretch; */
  @Param scrollIndicatorBehavior: TabBarScrollIndicatorBehavior = TabBarScrollIndicatorBehavior.Stretch;
  /** 指示条宽度; 默认值: 12.0; */
  @Param scrollIndicatorWidth: number = 12.0;
  /** 指示条高度; 默认值: 3.0; */
  @Param scrollIndicatorHeight: number = 3.0;
  /** 指示条颜色; 默认值: 0x121212; */
  @Param scrollIndicatorColor: ResourceColor = 0x121212;
  /** 指示条垂直方向对齐方式; 默认值: VerticalAlign.Bottom; */
  @Param scrollIndicatorAlign: VerticalAlign = VerticalAlign.Bottom;
  /** 底部间隔; 默认值: 5.0; 仅在 align === VerticalAlign.Bottom 时生效; */
  @Param scrollIndicatorBottomMargin: number = 5.0;
  /** 额外增加的宽度; 默认值: 0.0; 在 width 的基础上增加的宽度; 滚动条最终布局的宽度等于: layoutWidth = width + extraWidth; */
  @Param scrollIndicatorExtraWidth: number = 0.0;
  /** 额外增加的高度; 默认值: 0.0; 在 height 的基础上增加的高度; 滚动条最终布局的高度等于: layoutHeight = height + extraHeight; */
  @Param scrollIndicatorExtraHeight: number = 0.0;

  /** 内容起始边距; 默认值: 12.0; */
  @Param contentStartOffset: number = 12.0;
  /** 内容结束边距; 默认值: 12.0; */
  @Param contentEndOffset: number = 12.0;

  private mTabBarLayoutManager = new TabBarLayoutManager();
  private mScrollIndicatorViewModel: ScrollIndicatorViewModel = new ScrollIndicatorViewModel();
  private mLayoutWidth: number = 0.0;
  private mLayoutHeight: number = 0.0;
  private mContentWidth: number = 0.0;
  private mScroller = new Scroller();
  private mState = new TabBarStateImpl();

  @Local private mCurrentItemLayoutInfo?: TabBarItemLayoutInfo = undefined;
  @Local private mPreviousItemLayoutInfo?: TabBarItemLayoutInfo = undefined;
  private mSwiped = false;

  aboutToAppear(): void {
    if ( this.itemBuilder == undefined ) {
      this.itemBuilder = this.PlaceholderItemBuilder;
    }

    this.mState.currentIndex = this.currentIndex;
    if ( this.swipeController ) {
      this.swipeController._onSwipeEvent = (index: number, event: TabsAnimationEvent, tabsWidth: number) => this.onSwipeEvent(index, event, tabsWidth);
      this.swipeController._onAnimationStart = (index: number, targetIndex: number, event: TabsAnimationEvent, tabsWidth: number) => this.onAnimationStart(index, targetIndex, event, tabsWidth);
      this.swipeController._onAnimationEnd = (index: number, event: TabsAnimationEvent, tabsWidth: number) => this.onAnimationEnd(index, event, tabsWidth);
    }
  }

  build() {
    Scroll(this.mScroller) {
      if ( this.items.length > 0 ) {
        Stack({ alignContent: Alignment.TopStart }) {
          if ( this.scrollIndicatorStyle !== TabBarScrollIndicatorStyle.None ) {
            ScrollIndicator({
              scrollIndicatorColor: this.scrollIndicatorColor,
              viewModel: this.mScrollIndicatorViewModel,
            })
          }

          TabBarLayout({
            items: this.items,
            state: this.mState,
            itemBuilderOptions: this.itemBuilderOptions,
            itemBuilder: this.itemBuilder,
            onItemClick: this.onItemClick,
            layoutManager: this.mTabBarLayoutManager,
            shouldMeasureItemContentSize: this.shouldMeasureItemContentSize,
            itemDistribution: this.itemDistribution,
            itemSpacing: this.itemSpacing,
            contentStartOffset: this.contentStartOffset,
            contentEndOffset: this.contentEndOffset,
            onPlaceChildrenCallback: () => this.onTabBarLayoutPlaceChildren(),
            onDetachItemCallback: () => this.onTabBarLayoutDetachItem()
          })
          .constraintSize({ minWidth: '100%' })
          .onAreaChange((oldArea, newArea) => this.onTabBarLayoutAreaChange(oldArea, newArea))
        }
      }
    }
    .align(Alignment.Start)
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(this.barHeight)
    .onAreaChange((oldArea, newArea) => this.onBarAreaChange(oldArea, newArea))
  }

  private onAnimationStart(index: number, targetIndex: number, event: TabsAnimationEvent, tabsWidth: number): void {
    if ( this.items.length == 0 || Number.isNaN(tabsWidth) || !Number.isFinite(tabsWidth) || tabsWidth <= 0 ) {
      return;
    }
    this.mState.isSwiping = false;
    this.mState.isAnimating = true;

    if ( index == targetIndex ) {
      this.mState.fromIndex = index;
      this.mState.toIndex = index;
      this.mState.distance = 0;
      this.updateScrollIndicatorLayout();
      return;
    }

    this.onSwipeEvent(index, event, tabsWidth, false);
  }

  private onAnimationEnd(index: number, event: TabsAnimationEvent, tabsWidth: number): void {
    if ( this.items.length == 0 || Number.isNaN(tabsWidth) || !Number.isFinite(tabsWidth) || tabsWidth <= 0 ) {
      return;
    }
    this.mState.isSwiping = false;
    this.mState.isAnimating = false;

    this.mState.fromIndex = index;
    this.mState.toIndex = index;
    this.mState.distance = 0;
    this.updateScrollIndicatorLayout();
  }

  private onSwipeEvent(index: number, event: TabsAnimationEvent, tabsWidth: number, isSwiping: boolean = true): void {
    if ( this.items.length == 0 || Number.isNaN(tabsWidth) || !Number.isFinite(tabsWidth) || tabsWidth <= 0 ) {
      return;
    }

    const currentOffset = event.currentOffset;
    if ( currentOffset == 0 ) {
      return;
    }

    // 前一页 event.currentOffset > 0
    // 后一页 event.currentOffset < 0
    if ( index == 0 && currentOffset > 0 ) {
      return;
    }

    if ( index == this.items.length - 1 && currentOffset < 0 ) {
      return;
    }

    let fromIndex = 0;
    let toIndex = 0;
    let distance = 0.0;

    // 前一页
    if ( currentOffset > 0 ) {
      fromIndex = index - 1;
      toIndex = index;
      distance = 1.0 - currentOffset / tabsWidth;
    }
    // 后一页
    else {
     fromIndex = index;
     toIndex = index + 1;
     distance = Math.abs(currentOffset) / tabsWidth;
    }

    if ( !this.mSwiped ) {
      this.mSwiped = true;
    }

    this.mState.isSwiping = isSwiping;
    this.mState.fromIndex = fromIndex;
    this.mState.toIndex = toIndex;
    this.mState.distance = distance;
    this.updateScrollIndicatorLayout();
  }

  @Monitor('currentIndex')
  private onIndexChange() {
    this.mState.currentIndex = this.currentIndex;
    this.mState.fromIndex = this.currentIndex;
    this.mState.toIndex = this.currentIndex;
    this.mState.distance = 0.0;
    this.changeCurrentItemLayoutInfo(this.mTabBarLayoutManager.getInfo(this.currentIndex));
    this.scheduleScroll();
  }

  private onBarAreaChange(oldArea: Area, newArea: Area): void {
    if ( oldArea.width != newArea.width || oldArea.height != newArea.height ) {
      this.mLayoutWidth = newArea.width as number;
      this.mLayoutHeight = newArea.height as number;
      this.updateScrollIndicatorLayout();
      this.scheduleScroll();
    }
  }

  private onTabBarLayoutAreaChange(oldArea: Area, newArea: Area): void {
    if ( oldArea.width != newArea.width ) {
      this.mContentWidth = newArea.width as number;
      this.scheduleScroll();
    }
  }

  private onTabBarLayoutPlaceChildren(): void {
    this.changeCurrentItemLayoutInfo(this.mTabBarLayoutManager.getInfo(this.currentIndex));
  }

  private onTabBarLayoutDetachItem(): void {
    if ( this.items.length == 0.0 ) this.changeCurrentItemLayoutInfo(undefined);
  }

  @Monitor('scrollIndicatorSizeMode', 'scrollIndicatorWidth', 'scrollIndicatorHeight', 'scrollIndicatorAlign', 'scrollIndicatorBottomMargin', 'scrollIndicatorExtraWidth', 'scrollIndicatorExtraHeight')
  private onScrollIndicatorAttrsChange() {
    this.updateScrollIndicatorLayout();
  }

  @Computed
  private get shouldMeasureItemContentSize(): boolean {
    return this.scrollIndicatorStyle != TabBarScrollIndicatorStyle.None && this.scrollIndicatorSizeMode == TabBarScrollIndicatorSizeMode.EqualItemContentSize;
  }

  private mScheduledID?: number = 0;
  private scheduleScroll() {
    this.cancelScheduledScrollTask();
    this.mScheduledID = setTimeout(() => this.scroll(), 100);
  }

  private scroll(): void {
    if ( this.mLayoutWidth == 0.0 || this.mLayoutHeight == 0.0 || this.mContentWidth == 0.0 ) {
      return;
    }
    const info = this.mTabBarLayoutManager.getInfo(this.mState.currentIndex);
    if ( !info ) {
      return;
    }
    let offsetX = info.x + info.layoutSize.width * 0.5 - this.mLayoutWidth * 0.5;
    const minOffsetX = 0;
    const maxOffsetX = this.mContentWidth - this.mLayoutWidth;
    if ( offsetX > maxOffsetX ) {
      offsetX = maxOffsetX;
    }
    else if ( offsetX < minOffsetX ) {
      offsetX = minOffsetX;
    }
    this.mScroller.scrollTo({ xOffset: offsetX, yOffset: 0, animation: { curve: Curve.Linear, duration: 150 } });
    this.cancelScheduledScrollTask();
  }

  private cancelScheduledScrollTask() {
    if ( this.mScheduledID ) {
      clearTimeout(this.mScheduledID);
      this.mScheduledID = undefined;
    }
  }

  private changeCurrentItemLayoutInfo(info?: TabBarItemLayoutInfo): void {
    if (
        this.mCurrentItemLayoutInfo?.x != info?.x ||
        this.mCurrentItemLayoutInfo?.layoutSize.width != info?.layoutSize.width || this.mCurrentItemLayoutInfo?.layoutSize.height != info?.layoutSize.height ||
        this.mCurrentItemLayoutInfo?.contentSize.width != info?.contentSize.width || this.mCurrentItemLayoutInfo?.contentSize.height != info?.contentSize.height
    ) {
      this.mPreviousItemLayoutInfo = this.mCurrentItemLayoutInfo;
      this.mCurrentItemLayoutInfo = info;
      this.updateScrollIndicatorLayout();
    }
  }

  private updateScrollIndicatorLayout() {
    const animated = !this.mState.isSwiping && (this.mSwiped || (this.mCurrentItemLayoutInfo != undefined && this.mPreviousItemLayoutInfo != undefined));

    const info = this.mCurrentItemLayoutInfo;
    if ( info ) {
      if ( animated ) {
        setTimeout(() => {
          this.getUIContext().animateTo({ curve: 'linear', duration: 150 }, () => {
            this.mScrollIndicatorViewModel.updateLayout(
              info,
              this.mLayoutHeight,
              this.scrollIndicatorSizeMode,
              this.scrollIndicatorBehavior,
              this.scrollIndicatorAlign,
              this.scrollIndicatorWidth,
              this.scrollIndicatorHeight,
              this.scrollIndicatorExtraWidth,
              this.scrollIndicatorExtraHeight,
              this.scrollIndicatorBottomMargin,
              this.mTabBarLayoutManager.getInfo(this.mState.fromIndex)!,
              this.mTabBarLayoutManager.getInfo(this.mState.toIndex)!,
              this.mState.fromIndex,
              this.mState.toIndex,
              this.mState.distance,
            );
          });
        })
      }
      else {
        this.mScrollIndicatorViewModel.updateLayout(
          info,
          this.mLayoutHeight,
          this.scrollIndicatorSizeMode,
          this.scrollIndicatorBehavior,
          this.scrollIndicatorAlign,
          this.scrollIndicatorWidth,
          this.scrollIndicatorHeight,
          this.scrollIndicatorExtraWidth,
          this.scrollIndicatorExtraHeight,
          this.scrollIndicatorBottomMargin,
          this.mTabBarLayoutManager.getInfo(this.mState.fromIndex)!,
          this.mTabBarLayoutManager.getInfo(this.mState.toIndex)!,
          this.mState.fromIndex,
          this.mState.toIndex,
          this.mState.distance,
        );
      }
    }
  }

  @Builder
  private PlaceholderItemBuilder(index: number, item: TabBarItem, state: TabBarState, options?: TabBarItemBuilderOptions) {
    Text(`请指定 TabBar.itemBuilder 构建 item`)
      .backgroundColor(0x000000)
      .fontColor(0xFFFFFF)
      .fontSize(15)
  }
}

@ComponentV2
struct TabBarLayout {
  @Require @Param items: TabBarItem[];
  @Require @Param state: TabBarStateImpl;
  @Param itemBuilderOptions?: Object = undefined;
  @BuilderParam itemBuilder: (index: number, item: TabBarItem, state: TabBarState, options?: TabBarItemBuilderOptions) => void;
  @Event onItemClick: (index: number, item: TabBarItem, state: TabBarState) => void;
  @Event onPlaceChildrenCallback: () => void;
  @Event onDetachItemCallback: (index: number) => void;

  @Param layoutManager: TabBarLayoutManager = new TabBarLayoutManager();
  @Param shouldMeasureItemContentSize: boolean = false;

  @Param itemDistribution: TabBarItemDistribution = TabBarItemDistribution.EqualSpacing;
  @Param itemSpacing: number = 12.0;
  @Param contentStartOffset: number = 12.0;
  @Param contentEndOffset: number = 12.0;

  @Builder
  ItemsBuilder() {
    ForEach(this.items, (item: TabBarItem, index: number) => {
      Stack({ alignContent: Alignment.Center }) {
        Stack() {
          this.itemBuilder(index, item, this.state, this.itemBuilderOptions)
        }
      }
      .onClick(() => {
        if ( this.state.isSwiping || this.state.isAnimating ) {
          return;
        }
        this.onItemClick?.(index, item, this.state);
      })
      .onDetach(() => this.onDetachItemCallback(index))
    })
  }

  build() {
    this.ItemsBuilder()
  }

  onMeasureSize(selfLayoutInfo: GeometryInfo, children: Measurable[], constraint: ConstraintSizeOptions): SizeResult {
    return this.layoutManager.onMeasureSize(selfLayoutInfo, children, constraint, this.itemDistribution, this.itemSpacing, this.contentStartOffset, this.contentEndOffset, this.shouldMeasureItemContentSize);
  }

  onPlaceChildren(selfLayoutInfo: GeometryInfo, children: Layoutable[], constraint: ConstraintSizeOptions): void {
    this.layoutManager.onPlaceChildren(selfLayoutInfo, children, constraint);
    this.onPlaceChildrenCallback();
  }
}

@ComponentV2
struct ScrollIndicator {
  @Require @Param scrollIndicatorColor: ResourceColor;
  @Require @Param viewModel: ScrollIndicatorViewModel;

  build() {
    Stack()
      .width(this.viewModel.width)
      .height(this.viewModel.height)
      .borderRadius(this.viewModel.height * 0.5)
      .backgroundColor(this.scrollIndicatorColor)
      .offset({ left: this.viewModel.offsetX, top: this.viewModel.offsetY })
  }
}

@ObservedV2
class TabBarStateImpl implements TabBarState {
  @Trace private mCurrentIndex: number = 0;
  private mPreviousIndex: number = 0;

  @Trace isSwiping: boolean = false;
  @Trace isAnimating: boolean = false;

  @Trace fromIndex: number = 0;
  @Trace toIndex: number = 0;
  @Trace distance: number = 0;

  /**
   * @Trace
   *
   * 当前选中的 item 的索引;
   * */
  get currentIndex(): number {
    return this.mCurrentIndex;
  }

  set currentIndex(newIndex: number) {
    this.mPreviousIndex = this.mCurrentIndex;
    this.mCurrentIndex = newIndex;
  }

  get previousIndex(): number {
    return this.mPreviousIndex;
  }

  getItemScaleFactor(index: number): number {
    if ( this.fromIndex == this.toIndex ) {
      return index == this.mCurrentIndex ? 1.0 : 0.0;
    }

    if ( index == this.fromIndex ) {
      return 1 - this.distance;
    }

    if ( index == this.toIndex ) {
      return this.distance;
    }
    return 0.0;
  }
}

class TabBarItemLayoutInfo {
  x: number = 0;

  contentSize: SizeResult = { width: 0, height: 0 };
  layoutSize: SizeResult = { width: 0, height: 0 };
}

@ObservedV2
class TabBarLayoutManager {
  private mInfos: TabBarItemLayoutInfo[] = [];

  getInfo(index: number): TabBarItemLayoutInfo | undefined {
    if ( index >= 0 && index < this.mInfos.length ) {
      return this.mInfos[index];
    }
    return undefined;
  }

  // https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-custom-component-layout#onmeasuresize10
  // 不允许在onMeasureSize函数中改变状态变量
  onMeasureSize(
    selfLayoutInfo: GeometryInfo,
    children: Measurable[],
    _: ConstraintSizeOptions,
    itemDistribution: TabBarItemDistribution,
    itemSpacing: number,
    contentStartOffset: number,
    contentEndOffset: number,
    shouldMeasureItemContentSize: boolean,
  ): SizeResult {
    let resultSelfWidth = 0.0;

    const selfWidth = selfLayoutInfo.width;
    const selfHeight = selfLayoutInfo.height;

    if ( children.length == 0 ) {
      this.mInfos = [];
      return {
        width: 0,
        height: selfHeight,
      };
    }

    switch (itemDistribution) {
      case TabBarItemDistribution.EqualSpacing:
      case TabBarItemDistribution.AutoAdaptive: {
        const contentConstraint: ConstraintSizeOptions = {
          minHeight: 0,
          maxHeight: selfHeight,
          minWidth: 0,
        };

        const layoutConstraint: ConstraintSizeOptions = {
          minHeight: selfHeight,
          maxHeight: selfHeight,
          minWidth: 0,
        }

        // 等间距(itemSpacing)排列 items
        let prevX = contentStartOffset;
        const childLayoutInfos = children.map((child) => {
          const info = new TabBarItemLayoutInfo();
          let size: MeasureResult;
          if ( shouldMeasureItemContentSize ) {
            size = child.measure(contentConstraint); // measure content size
            info.contentSize = size;
          }

          size = child.measure(layoutConstraint); // measure layout size, layoutSize.width equal to contentSize.width;
          info.layoutSize = size;
          info.x = prevX;
          prevX += size.width + itemSpacing;
          return info;
        });

        const lastInfo = childLayoutInfos[children.length - 1];
        resultSelfWidth = lastInfo.x + lastInfo.layoutSize.width + contentEndOffset;

        // 内容量不够滑动时, 使用自适应等间距分布撑满父布局;
        if ( itemDistribution === TabBarItemDistribution.AutoAdaptive && resultSelfWidth < selfWidth ) {
          resultSelfWidth = selfWidth;
          const allChildrenSize = childLayoutInfos.reduce((prev, info) => prev + info.layoutSize.width, 0);

          // 左右起始间距和尾部间距也需要等间距(children.length + 1);
          // 这个间距必定 >= itemSpacing。
          const resultItemSpacing = (selfWidth - allChildrenSize) / (children.length + 1);
          const resultContentStartOffset = resultItemSpacing;

          // 等间距(resultItemSpacing)排列 items
          // update layout x for infos
          prevX = resultContentStartOffset;
          childLayoutInfos.forEach(info => {
            info.x = prevX;
            prevX += info.layoutSize.width + resultItemSpacing;
          });
        }
        this.mInfos = childLayoutInfos;
        break;
      }
      case TabBarItemDistribution.FillEqually: {
        // ignore itemSpacing and contentOffset(contentStartOffset & contentEndOffset);
        const avgChildWidth = (selfWidth / children.length);
        const contentConstraint: ConstraintSizeOptions = {
          minWidth: 0,
          minHeight: 0,
          maxHeight: selfHeight,
        };

        const layoutConstraint: ConstraintSizeOptions = {
          minWidth: avgChildWidth,
          maxWidth: avgChildWidth,
          minHeight: selfHeight,
          maxHeight: selfHeight,
        };

        // 等宽排列 items
        let prevX = 0.0;
        const childLayoutInfos = children.map((child, _) => {
          const info = new TabBarItemLayoutInfo();
          let size: MeasureResult;
          if ( shouldMeasureItemContentSize ) {
            size = child.measure(contentConstraint); // measure content size
            info.contentSize = size;
          }

          size = child.measure(layoutConstraint); // measure layout size;
          info.layoutSize = size;
          info.x = prevX;
          prevX += size.width;
          return info;
        });

        resultSelfWidth = selfWidth;
        this.mInfos = childLayoutInfos;
        break;
      }
    }

    return {
      width: resultSelfWidth,
      height: selfHeight
    }
  }

  // https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-custom-component-layout#onplacechildren10
  // 不允许在onPlaceChildren函数中改变状态变量
  onPlaceChildren(_: GeometryInfo, children: Layoutable[], __: ConstraintSizeOptions): void {
    children.forEach((child, index) => {
      const info = this.mInfos[index];
      child.layout({ x: info.x, y: 0.0 })
    })
  }
}

@ObservedV2
class ScrollIndicatorViewModel {
  @Trace private mOffsetX: number = 0.0;
  @Trace private mOffsetY: number = 0.0;
  @Trace private mLayoutWidth: number = 12.0;
  @Trace private mLayoutHeight: number = 3.0;

  // @Trace
  get offsetX(): number {
    return this.mOffsetX;
  }

  // @Trace
  get offsetY(): number {
    return this.mOffsetY;
  }

  // @Trace
  get width(): number {
    return this.mLayoutWidth;
  }

  // @Trace
  get height(): number {
    return this.mLayoutHeight;
  }

  updateLayout(
    info: TabBarItemLayoutInfo,
    barHeight: number,
    sizeMode: TabBarScrollIndicatorSizeMode,
    scrollBehavior: TabBarScrollIndicatorBehavior,
    align: VerticalAlign,
    specifedWidth: number,
    specifedHeight: number,
    extraWidth: number,
    extraHeight: number,
    bottomMargin: number,
    fromInfo: TabBarItemLayoutInfo,
    toInfo: TabBarItemLayoutInfo,
    fromIndex: number,
    toIndex: number,
    progress: number
  ) {
    let layoutSize: SizeResult;
    let offsetX: number;
    if ( fromIndex < toIndex ) {
      const fromViewCenterX = fromInfo.x + fromInfo.layoutSize.width * 0.5;
      const toViewCenterX = toInfo.x + toInfo.layoutSize.width * 0.5;
      const fromViewLeft = fromInfo.x;
      const toViewRight = toInfo.x + toInfo.layoutSize.width;

      const fromIndicatorSize = this.calculateIndicatorLayoutSizeBy(fromInfo, sizeMode, specifedWidth, specifedHeight, extraWidth, extraHeight);
      const toIndicatorSize = this.calculateIndicatorLayoutSizeBy(toInfo, sizeMode, specifedWidth, specifedHeight, extraWidth, extraHeight);

      switch (scrollBehavior) {
        case TabBarScrollIndicatorBehavior.Stretch: {
          const stretchFactor = 1 - Math.abs(toIndicatorSize.width - fromIndicatorSize.width) / Math.max(toIndicatorSize.width, fromIndicatorSize.width);
          const stretchDistance = (toViewRight - fromViewLeft) * stretchFactor;
          let interpolatedWidth: number;
          // 小于 0.5 开始变长
          if ( progress < 0.5 ) {
            interpolatedWidth = fromIndicatorSize.width * ( 1 - progress ) + toIndicatorSize.width * progress + stretchDistance * progress;
          }
          // 超过 0.5 开始缩小
          else {
            interpolatedWidth = fromIndicatorSize.width * ( 1 - progress ) + toIndicatorSize.width * progress + stretchDistance * ( 1 - progress);
          }

          let interpolatedHeight: number;
          if ( fromIndicatorSize.height == toIndicatorSize.height ) {
            interpolatedHeight = fromIndicatorSize.height;
          }
          else {
            interpolatedHeight = fromIndicatorSize.height + (toIndicatorSize.height - fromIndicatorSize.height) * progress;
          }

          const centerDeltaX = toViewCenterX - fromViewCenterX;
          const indicatorLeft = fromViewCenterX + centerDeltaX * progress - interpolatedWidth * 0.5;

          layoutSize = {
            width: interpolatedWidth,
            height: interpolatedHeight
          };
          offsetX = indicatorLeft;
        }
          break;
        case TabBarScrollIndicatorBehavior.Follow: {
          let interpolatedWidth: number;
          if ( fromIndicatorSize.width == toIndicatorSize.width ) {
            interpolatedWidth = fromIndicatorSize.width;
          }
          else {
            interpolatedWidth = fromIndicatorSize.width + (toIndicatorSize.width - fromIndicatorSize.width) * progress;
          }

          let interpolatedHeight: number;
          if ( fromIndicatorSize.height == toIndicatorSize.height ) {
            interpolatedHeight = fromIndicatorSize.height;
          }
          else {
            interpolatedHeight = fromIndicatorSize.height + (toIndicatorSize.height - fromIndicatorSize.height) * progress;
          }

          const centerDeltaX = toViewCenterX - fromViewCenterX;
          const indicatorLeft = fromViewCenterX + centerDeltaX * progress - interpolatedWidth * 0.5;

          layoutSize = {
            width: interpolatedWidth,
            height: interpolatedHeight
          };
          offsetX = indicatorLeft;
        }
          break;
      }
    }
    else {
      layoutSize = this.calculateIndicatorLayoutSizeBy(info, sizeMode, specifedWidth, specifedHeight, extraWidth, extraHeight);
      offsetX = info.x + info.layoutSize.width * 0.5 - layoutSize.width * 0.5;
    }

    let offsetY = 0.0;
    switch (align) {
      case VerticalAlign.Top:
        break;
      case VerticalAlign.Center:
        offsetY = barHeight * 0.5 - layoutSize.height * 0.5;
        break;
      case VerticalAlign.Bottom:
        // bottomMargin 仅在 align === VerticalAlign.Bottom 时生效;
        offsetY = barHeight - bottomMargin - layoutSize.height;
        break;
    }

    // (xy, wh)
    if ( offsetX != this.mOffsetX ) this.mOffsetX = offsetX;
    if ( offsetY != this.mOffsetY ) this.mOffsetY = offsetY;
    if ( layoutSize.width != this.mLayoutWidth )  this.mLayoutWidth = layoutSize.width;
    if ( layoutSize.height != this.mLayoutHeight ) this.mLayoutHeight = layoutSize.height;
  }

  private calculateIndicatorLayoutSizeBy(
    info: TabBarItemLayoutInfo,
    sizeMode: TabBarScrollIndicatorSizeMode,
    specifedWidth: number,
    specifedHeight: number,
    extraWidth: number,
    extraHeight: number
  ): SizeResult {
    let layoutWidth: number;
    let layoutHeight: number;
    if ( sizeMode == TabBarScrollIndicatorSizeMode.EqualItemContentSize ) {
      layoutWidth = info.contentSize.width + extraWidth;
      layoutHeight = info.contentSize.height + extraHeight;
    }
    else {
      layoutWidth = specifedWidth + extraWidth;
      layoutHeight = specifedHeight + extraHeight;
    }
    return {
      width: layoutWidth,
      height: layoutHeight,
    }
  }
}