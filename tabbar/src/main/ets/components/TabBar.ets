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

export interface TabBarScrollIndicatorOptions {
  /** 指示条宽度模式; 默认值: TabBarScrollIndicatorSizeMode.SpecifiedSize, 使用指定的大小; */
  readonly sizeMode?: TabBarScrollIndicatorSizeMode;
  /** 指示条宽度; 默认值: 12.0; */
  readonly width?: number;
  /** 指示条高度; 默认值: 3.0; */
  readonly height?: number;
  /** 指示条颜色; 默认值: 0x121212; */
  readonly color?: ResourceColor;
  /** 指示条垂直方向对齐方式; 默认值: VerticalAlign.Bottom; */
  readonly align?: VerticalAlign;
  /** 底部间隔; 默认值: 5.0; 仅在 align === VerticalAlign.Bottom 时生效; */
  readonly bottomMargin?: number;
  /** 额外增加的宽度; 默认值: 0.0; 在 width 的基础上增加的宽度; 滚动条最终布局的宽度等于: layoutWidth = width + extraWidth; */
  readonly extraWidth?: number;
  /** 额外增加的高度; 默认值: 0.0; 在 height 的基础上增加的高度; 滚动条最终布局的高度等于: layoutHeight = height + extraHeight; */
  readonly extraHeight?: number;
}

export enum TabBarScrollIndicatorStyle {
  /** 不显示指示条; */
  None,
  /** 圆角/胶囊样式; */
  Rounded,
}

export interface TabBarOptions {
  /** TabBar 的整体高度; 默认值: 44.0; */
  readonly barHeight?: Length;
  /** item 排列方式; 默认值: TabBarItemDistribution.EqualSpacing; */
  readonly itemDistribution?: TabBarItemDistribution;
  /** item 之间的间隔; 默认值: 12.0; */
  readonly itemSpacing?: number;
  /** 指示条样式; 默认值: TabBarScrollIndicatorStyle.Rounded, 默认圆角/胶囊样式; */
  readonly scrollIndicatorStyle?: TabBarScrollIndicatorStyle;
  /** 指示条配置项; */
  readonly scrollIndicatorOptions?: TabBarScrollIndicatorOptions;
  /** 内容起始边距; 默认值: 12.0; */
  readonly contentStartOffset?: number;
  /** 内容结束边距; 默认值: 12.0; */
  readonly contentEndOffset?: number;
}

export interface TabBarItem {

}

@ObservedV2
export class TabBarState {
  @Trace private mCurrentIndex: number = 0;
  private mPreviousIndex: number = 0;

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
}

@ComponentV2
export struct TabBar {
  @Param options?: TabBarOptions = undefined;
  @Require @Param items: TabBarItem[];
  @Require @Param state: TabBarState;
  @BuilderParam itemBuilder: (index: number, item: TabBarItem, state: TabBarState) => void;
  @Event onItemClick: (index: number, item: TabBarItem, state: TabBarState) => void;

  private mTabBarLayoutManager = new TabBarLayoutManager();
  private mScrollIndicatorViewModel: ScrollIndicatorViewModel = new ScrollIndicatorViewModel();
  private mScrollIndicatorStyle: TabBarScrollIndicatorStyle = TabBarScrollIndicatorStyle.Rounded;
  private mShouldMeasureItemContentSize = false;
  private mBarHeight: Length = 44.0;
  private mItemDistribution: TabBarItemDistribution = TabBarItemDistribution.EqualSpacing;
  private mItemSpacing: number = 12.0;
  private mContentStartOffset: number = 12.0;
  private mContentEndOffset: number = 12.0;
  private mLayoutWidth: number = 0.0;
  private mLayoutHeight: number = 0.0;
  private mContentWidth: number = 0.0;
  private mScroller = new Scroller();
  @Local private mEnabledScrollIndicatorAnimation: boolean = false;

  aboutToAppear(): void {
    this.mScrollIndicatorStyle = this.options?.scrollIndicatorStyle ?? this.mScrollIndicatorStyle;
    this.mScrollIndicatorViewModel.init(this.options?.scrollIndicatorOptions);
    this.mShouldMeasureItemContentSize = this.mScrollIndicatorStyle !== TabBarScrollIndicatorStyle.None && this.mScrollIndicatorViewModel.sizeMode === TabBarScrollIndicatorSizeMode.EqualItemContentSize;
    this.mBarHeight = this.options?.barHeight ?? this.mBarHeight;
    this.mItemDistribution = this.options?.itemDistribution ?? this.mItemDistribution;
    this.mItemSpacing = this.options?.itemSpacing ?? this.mItemSpacing;
    this.mContentStartOffset = this.options?.contentStartOffset ?? this.mContentStartOffset;
    this.mContentEndOffset = this.options?.contentEndOffset ?? this.mContentEndOffset;
  }

  build() {
    Scroll(this.mScroller) {
      Stack({ alignContent: Alignment.TopStart }) {
        if ( this.mScrollIndicatorStyle !== TabBarScrollIndicatorStyle.None ) {
          ScrollIndicator({
            viewModel: this.mScrollIndicatorViewModel,
            enabledAnimation: this.mEnabledScrollIndicatorAnimation,
          })
        }

        TabBarLayout({
          items: this.items,
          state: this.state,
          itemBuilder: this.itemBuilder,
          onItemClick: this.onItemClick,
          onItemAreaChange: (index: number) => {
            if ( this.mScrollIndicatorStyle !== TabBarScrollIndicatorStyle.None && index == this.state.currentIndex || index == this.state.previousIndex ) {
              const info = this.mTabBarLayoutManager.getInfo(this.state.currentIndex);
              if ( info ) {
                this.mScrollIndicatorViewModel.updatePositionTo(info, this.mLayoutHeight);
              }
            }

            this.scheduleUpdatePositions();
          },
          layoutManager: this.mTabBarLayoutManager,
          shouldMeasureItemContentSize: this.mShouldMeasureItemContentSize,
          itemDistribution: this.mItemDistribution,
          itemSpacing: this.mItemSpacing,
          contentStartOffset: this.mContentStartOffset,
          contentEndOffset: this.mContentEndOffset,
        })
        .onAreaChange((oldArea, newArea) => {
          if ( oldArea.width != newArea.width ) {
            this.mContentWidth = newArea.width as number;
            this.scheduleUpdatePositions();
          }
        })
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(this.mBarHeight)
    .onAreaChange((oldArea, newArea) => {
      if ( oldArea.width != newArea.width || oldArea.height != newArea.height ) {
        this.mLayoutWidth = newArea.width as number;
        this.mLayoutHeight = newArea.height as number;
        this.updatePositions();
        if ( !this.mEnabledScrollIndicatorAnimation ) {
          setTimeout(() => {
            this.mEnabledScrollIndicatorAnimation = true;
          });
        }
      }
    })
  }

  @Monitor('state.currentIndex')
  private onIndexChanged(_: IMonitor) {
    this.scheduleUpdatePositions();
  }

  private mScheduledID?: number = 0;
  private scheduleUpdatePositions() {
    this.cancelSchedule();
    this.mScheduledID = setTimeout(() => this.updatePositions(), 100);
  }

  private updatePositions(): void {
    if ( this.mLayoutWidth == 0.0 || this.mLayoutHeight == 0.0 || this.mContentWidth == 0.0 ) {
      return;
    }

    const info = this.mTabBarLayoutManager.getInfo(this.state.currentIndex);
    if ( info ) {
      if ( this.mScrollIndicatorStyle !== TabBarScrollIndicatorStyle.None ) {
        this.mScrollIndicatorViewModel.updatePositionTo(info, this.mLayoutHeight);
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
    }
    this.cancelSchedule();
  }

  private cancelSchedule() {
    if ( this.mScheduledID ) {
      clearTimeout(this.mScheduledID);
      this.mScheduledID = undefined;
    }
  }
}

@ComponentV2
struct TabBarLayout {
  @Require @Param items: TabBarItem[];
  @Require @Param state: TabBarState;
  @BuilderParam itemBuilder: (index: number, item: TabBarItem, state: TabBarState) => void;
  @Event onItemClick: (index: number, item: TabBarItem, state: TabBarState) => void;
  @Event onItemAreaChange: (index: number, item: TabBarItem, state: TabBarState) => void;

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
          this.itemBuilder(index, item, this.state)
        }
        .onAreaChange((oldArea, newArea) => {
          if (
            oldArea.position.x != newArea.position.x ||
            oldArea.position.y != newArea.position.y ||
            oldArea.width != newArea.width ||
            oldArea.height != newArea.height
          ) {
            this.onItemAreaChange(index, item, this.state);
          }
        })
      }
      .onClick(() => {
        this.onItemClick?.(index, item, this.state);
      })
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
  }
}

@ComponentV2
struct ScrollIndicator {
  @Require @Param viewModel: ScrollIndicatorViewModel;
  @Param enabledAnimation: boolean = false;

  build() {
    Stack()
      .width(this.viewModel.width)
      .height(this.viewModel.height)
      .borderRadius(this.viewModel.height * 0.5)
      .backgroundColor(this.viewModel.color)
      .offset({ left: this.viewModel.offsetX, top: this.viewModel.offsetY })
      .animation(this.enabledAnimation ? { curve: 'linear', duration: 150 } : undefined)
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
        width: selfWidth,
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
        const resultWidth = lastInfo.x + lastInfo.layoutSize.width + contentEndOffset;

        // 内容量不够滑动时, 使用自适应等间距分布撑满父布局;
        if ( itemDistribution === TabBarItemDistribution.AutoAdaptive && resultWidth < selfWidth ) {
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
        else {
          resultSelfWidth = Math.max(selfWidth, resultWidth);
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
  private mSizeMode: TabBarScrollIndicatorSizeMode = TabBarScrollIndicatorSizeMode.SpecifiedSize;
  private mColor: ResourceColor = 0x121212;
  private mAlign: VerticalAlign = VerticalAlign.Bottom;
  private mBottomMargin: number = 5.0;
  private mExtraWidth: number = 0.0;
  private mExtraHeight: number = 0.0;

  @Trace private mWidth: number = 12.0;
  @Trace private mHeight: number = 3.0;
  @Trace private mOffsetX: number = 0.0;
  @Trace private mOffsetY: number = 0.0;

  init(options?: TabBarScrollIndicatorOptions) {
    this.mSizeMode = options?.sizeMode ?? this.mSizeMode;
    this.mColor = options?.color ?? this.mColor;
    this.mAlign = options?.align ?? this.mAlign;
    this.mBottomMargin = options?.bottomMargin ?? this.mBottomMargin;
    this.mExtraWidth = options?.extraWidth ?? this.mExtraWidth;
    this.mExtraHeight = options?.extraHeight ?? this.mExtraHeight;

    this.mWidth = options?.width ?? this.mWidth;
    this.mHeight = options?.height ?? this.mHeight;
    this.mOffsetX = 0.0;
    this.mOffsetY = 0.0;
  }

  get sizeMode(): TabBarScrollIndicatorSizeMode {
    return this.mSizeMode;
  }

  get color(): ResourceColor {
    return this.mColor;
  }

  // @Trace
  get width(): number {
    return this.mWidth;
  }

  // @Trace
  get height(): number {
    return this.mHeight;
  }

  // @Trace
  get offsetX(): number {
    return this.mOffsetX;
  }

  // @Trace
  get offsetY(): number {
    return this.mOffsetY;
  }

  updatePositionTo(info: TabBarItemLayoutInfo, barHeight: number) {
    if ( this.mSizeMode == TabBarScrollIndicatorSizeMode.EqualItemContentSize ) {
      this.mWidth = info.contentSize.width + this.mExtraWidth;
      this.mHeight = info.contentSize.height + this.mExtraHeight;
    }

    this.mOffsetX = info.x + info.layoutSize.width * 0.5 - this.mWidth * 0.5;

    switch (this.mAlign) {
      case VerticalAlign.Top:
        this.mOffsetY = 0;
        break;
      case VerticalAlign.Center:
        this.mOffsetY = barHeight * 0.5 - this.mHeight * 0.5;
        break;
      case VerticalAlign.Bottom:
        // mBottomMargin 仅在 align === VerticalAlign.Bottom 时生效;
        this.mOffsetY = barHeight - this.mBottomMargin - this.mHeight;
        break;
    }
  }
}