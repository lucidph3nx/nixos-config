{...}: {
  # Setting my abbreviations
  programs.neovim = {
    extraConfig =
      /*
      vim
      */
      ''
        " markdown
        ab ch - [ ]
        " fractions
        ab 1/2 ½
        ab 1/4 ¼
        ab 3/4 ¾
        ab 1/3 ⅓
        ab 2/3 ⅔
        ab 1/5 ⅕
        ab 2/5 ⅖
        ab 3/5 ⅗
        ab 4/5 ⅘
        ab 1/6 ⅙
        ab 5/6 ⅚
        ab 1/8 ⅛
        ab 3/8 ⅜
        ab 5/8 ⅝
        ab 7/8 ⅞
        " superscript
        ab 1u ¹
        ab 2u ²
        ab 3u ³
        ab 4u ⁴
        ab 5u ⁵
        ab 6u ⁶
        ab 7u ⁷
        ab 8u ⁸
        ab 9u ⁹
        ab 0u ⁰
        " subscript
        ab 1d ₁
        ab 2d ₂
        ab 3d ₃
        ab 4d ₄
        ab 5d ₅
        ab 6d ₆
        ab 7d ₇
        ab 8d ₈
        ab 9d ₉
        ab 0d ₀
        " math
        ab pi π
        ab inf ∞
      '';
  };
}
