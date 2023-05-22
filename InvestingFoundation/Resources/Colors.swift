import SwiftUI

public enum Colors {
    public enum Background {
      public static let action = Color(name: "BackgroundAction")
      public static let fadeEnd = Color(name: "BackgroundFadeEnd")
      public static let fadeStart = Color(name: "BackgroundFadeStart")
      public static let plain = Color(name: "BackgroundPlain")
      public static let primary = Color(name: "BackgroundPrimary")
      public static let secondary = Color(name: "BackgroundSecondary")
    }
    public enum Button {
      public static let disabled = Color(name: "ButtonDisabled")
      public static let paste = Color(name: "ButtonPaste")
      public static let positive = Color(name: "ButtonPositive")
      public static let positiveDisabled = Color(name: "ButtonPositiveDisabled")
      public static let primary = Color(name: "ButtonPrimary")
      public static let secondary = Color(name: "ButtonSecondary")
    }
    public enum Control {
      public static let checked = Color(name: "ControlChecked")
      public static let key = Color(name: "ControlKey")
      public static let unchecked = Color(name: "ControlUnchecked")
    }
    public enum Field {
      public static let focused = Color(name: "FieldFocused")
      public static let primary = Color(name: "FieldPrimary")
    }
    public enum Icon {
      public static let accent = Color(name: "IconAccent")
      public static let attention = Color(name: "IconAttention")
      public static let inactive = Color(name: "IconInactive")
      public static let informative = Color(name: "IconInformative")
      public static let primary1 = Color(name: "IconPrimary1")
      public static let primary2 = Color(name: "IconPrimary2")
      public static let secondary = Color(name: "IconSecondary")
      public static let warning = Color(name: "IconWarning")
    }
    public enum Old {
      public static let tangemBg = Color(name: "tangem_bg")
      public static let tangemBgGray = Color(name: "tangem_bg_gray")
      public static let tangemBgGray2 = Color(name: "tangem_bg_gray2")
      public static let tangemBgGray3 = Color(name: "tangem_bg_gray3")
      public static let tangemBlue = Color(name: "tangem_blue")
      public static let tangemBlue1 = Color(name: "tangem_blue1")
      public static let tangemBlue2 = Color(name: "tangem_blue2")
      public static let tangemBlue3 = Color(name: "tangem_blue3")
      public static let tangemBlueLight = Color(name: "tangem_blue_light")
      public static let tangemBlueLight2 = Color(name: "tangem_blue_light2")
      public static let tangemBtnHoverBg = Color(name: "tangem_btn_hover_bg")
      public static let tangemCritical = Color(name: "tangem_critical")
      public static let tangemGrayDark = Color(name: "tangem_gray_dark")
      public static let tangemGrayDark2 = Color(name: "tangem_gray_dark2")
      public static let tangemGrayDark3 = Color(name: "tangem_gray_dark3")
      public static let tangemGrayDark4 = Color(name: "tangem_gray_dark4")
      public static let tangemGrayDark5 = Color(name: "tangem_gray_dark5")
      public static let tangemGrayDark6 = Color(name: "tangem_gray_dark6")
      public static let tangemGrayDark1 = Color(name: "tangem_gray_dark_1")
      public static let tangemGrayLight4 = Color(name: "tangem_gray_light4")
      public static let tangemGrayLight5 = Color(name: "tangem_gray_light5")
      public static let tangemGrayLight6 = Color(name: "tangem_gray_light6")
      public static let tangemGrayLight7 = Color(name: "tangem_gray_light7")
      public static let tangemGreen = Color(name: "tangem_green")
      public static let tangemGreen1 = Color(name: "tangem_green1")
      public static let tangemGreen2 = Color(name: "tangem_green2")
      public static let tangemSkeletonGray = Color(name: "tangem_skeleton_gray")
      public static let tangemSkeletonGray2 = Color(name: "tangem_skeleton_gray2")
      public static let tangemStoryBackground = Color(name: "tangem_story_background")
      public static let tangemTextGray = Color(name: "tangem_text_gray")
      public static let tangemWarning = Color(name: "tangem_warning")
      public static let underlyingCardBackground1 = Color(name: "underlying-card-background1")
      public static let underlyingCardBackground2 = Color(name: "underlying-card-background2")
    }
    public enum Stroke {
      public static let primary = Color(name: "StrokePrimary")
      public static let secondary = Color(name: "StrokeSecondary")
      public static let transparency = Color(name: "StrokeTransparency")
    }
    public enum Text {
      public static let accent = Color(name: "TextAccent")
      public static let attention = Color(name: "TextAttention")
      public static let constantWhite = Color(name: "TextConstantWhite")
      public static let disabled = Color(name: "TextDisabled")
      public static let primary1 = Color(name: "TextPrimary1")
      public static let primary2 = Color(name: "TextPrimary2")
      public static let secondary = Color(name: "TextSecondary")
      public static let tertiary = Color(name: "TextTertiary")
      public static let warning = Color(name: "TextWarning")
    }
}

// MARK: - Implementation Details

public extension Color {
  /// Creates a named color.
  /// - Parameter name: the color resource to lookup.
  init(name: String) {
    let bundle = Bundle(for: BundleToken.self)
    self.init(name, bundle: bundle)
  }
}

private final class BundleToken {}
