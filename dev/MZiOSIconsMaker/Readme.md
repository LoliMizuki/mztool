MZiOSIconsMaker
====

簡易的 iOS Icon Maker

# Usagi

- 原始 Image 必須命名為 `Icon.png`
- 將原專案的 Contents.json 檔案 copy 出來, 作為生成的參考
- 將編譯出的 iOSIconsMaker 檔案與原始的 Icon image, Contents.json 放在一起
- iOSIconsMaker
- 生成 

```
 -- AppIcon.appiconset
  |- <各種 icon files>
  |- Contents.json

```
- 直接送到 Xcode 的 Assets.xcassets 之下就 ok 囉

# Tips

- 原生 Icon 要大於 proj 的最高需求

# TODO

- [ ] 未測試 tvOS, watchOS 的設置
