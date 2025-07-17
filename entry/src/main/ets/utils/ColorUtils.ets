export namespace ColorUtils {
  /**
   * lerp: 线性插值、线性渐变, 是 linear interpolation 的缩写;
   *
   * 两个颜色插值（线性渐变）
   * @param from 起始颜色（0xAARRGGBB 或 0xRRGGBB）
   * @param to 目标颜色（0xAARRGGBB 或 0xRRGGBB）
   * @param t 插值因子，范围 [0.0, 1.0]
   *
   * 公式:
   *    lerp(a, b, t) = a * (1 - t) + b * t
   *
   * 例如:
   *    lerp(a, b, t) 表示在 a 和 b 之间插入一个值, 其中 t 是比例(范围在 [0.0, 1.0]):
   *
   *    当 t = 0.0 时, 返回 a;
   *    当 t = 1.0 时, 返回 b;
   *    当 t = 0.5 时, 返回 a 和 b 的中间值;
   *
   */
  export function lerpColor(fromColor: number | string, toColor: number | string, t: number): string {
    if ( typeof fromColor !== 'string' && typeof fromColor !== 'number' ) {
      throw new Error('fromColor must be a string or number');
    }

    if ( typeof toColor !== 'string' && typeof toColor !== 'number' ) {
      throw new Error('toColor must be a string or number');
    }

    const c1 = (typeof fromColor == 'string') ? Color.fromHex(fromColor) : Color.fromInt(fromColor);
    const c2 = (typeof toColor == 'string') ? Color.fromHex(toColor) : Color.fromInt(toColor);
    return Color.blend(c1, c2, t).toHex();
  }

  class Color {
    readonly red: number; // [0, 255]
    readonly green: number; // [0, 255]
    readonly blue: number; // [0, 255]
    readonly alpha: number; // [0, 255]

    constructor(r: number, g: number, b: number, a: number = 255) {
      this.red = r;
      this.green = g;
      this.blue = b;
      this.alpha = a;
    }

    /**
     * 将十六进制颜色字符串转换成 ArkUI 支持的 Color 对象
     * 支持格式：
     *  - #RRGGBB
     *  - #AARRGGBB
     * @param hexColor 颜色字符串
     */
    static fromHex(hexColor: string): Color {
      if (!hexColor) {
        throw new Error('Invalid color string');
      }
      let hex = hexColor.trim();
      if (hex[0] === '#') {
        hex = hex.slice(1);
      }

      // #RRGGBB 或 #AARRGGBB
      if ( hex.length === 6 ) {
        // 默认不透明
        const r = parseInt(hex.slice(0, 2), 16);
        const g = parseInt(hex.slice(2, 4), 16);
        const b = parseInt(hex.slice(4, 6), 16);
        return new Color(r, g, b, 255);
      }
      else if (hex.length === 8) {
        const a = parseInt(hex.slice(0, 2), 16);
        const r = parseInt(hex.slice(2, 4), 16);
        const g = parseInt(hex.slice(4, 6), 16);
        const b = parseInt(hex.slice(6, 8), 16);
        return new Color(r, g, b, a);
      }
      else {
        throw new Error('Unsupported hex color format');
      }
    }

    /**
     * 从 0xRRGGBB 或 0xAARRGGBB 整型值创建 Color 对象
     * @param value 整数颜色值，如 0xFF3366 或 0x80FF3366
     */
    static fromInt(value: number): Color {
      if ( value < 0 || value > 0xFFFFFFFF ) {
        throw new Error('Invalid color integer');
      }

      if ( value <= 0xFFFFFF ) {
        // 0xRRGGBB 格式，默认 alpha = 255
        const r = (value >> 16) & 0xFF;
        const g = (value >> 8) & 0xFF;
        const b = value & 0xFF;
        return new Color(r, g, b, 255);
      }
      else {
        // 0xAARRGGBB 格式
        const a = (value >> 24) & 0xFF;
        const r = (value >> 16) & 0xFF;
        const g = (value >> 8) & 0xFF;
        const b = value & 0xFF;
        return new Color(r, g, b, a);
      }
    }

    /**
     * 颜色混合：将两个颜色按比例混合
     * @param color1 颜色1
     * @param color2 颜色2
     * @param ratio 颜色2的比例 [0.0, 1.0]
     */
    static blend(color1: Color, color2: Color, ratio: number): Color {
      ratio = Math.min(Math.max(ratio, 0), 1);
      const r = Math.round(color1.red * (1 - ratio) + color2.red * ratio);
      const g = Math.round(color1.green * (1 - ratio) + color2.green * ratio);
      const b = Math.round(color1.blue * (1 - ratio) + color2.blue * ratio);
      const a = Math.round(color1.alpha * (1 - ratio) + color2.alpha * ratio);
      return new Color(r, g, b, a);
    }

    /**
     * 将 Color 对象转换成十六进制字符串，默认输出 #AARRGGBB
     */
    toHex(): string {
      const toHex = (v: number) => v.toString(16).padStart(2, '0').toUpperCase();
      return `#${toHex(this.alpha)}${toHex(this.red)}${toHex(this.green)}${toHex(this.blue)}`;
    }
  }
}
