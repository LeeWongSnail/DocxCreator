# YXDocXCreator

[![CI Status](https://img.shields.io/travis/liwang8/YXDocXCreator.svg?style=flat)](https://travis-ci.org/liwang8/YXDocXCreator)
[![Version](https://img.shields.io/cocoapods/v/YXDocXCreator.svg?style=flat)](https://cocoapods.org/pods/YXDocXCreator)
[![License](https://img.shields.io/cocoapods/l/YXDocXCreator.svg?style=flat)](https://cocoapods.org/pods/YXDocXCreator)
[![Platform](https://img.shields.io/cocoapods/p/YXDocXCreator.svg?style=flat)](https://cocoapods.org/pods/YXDocXCreator)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

YXDocXCreator is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'YXDocXCreator'
```

## Author

LeeWong wangli_0632@163.com

## License

YXDocXCreator is available under the MIT license. See the LICENSE file for more info.


## 背景
近期的需求中有一项任务是将用户输入的文字和图片写入Word文件并支持导出，对于苹果和微软的爱恨情仇很早就知道，iOS文本写入Word难度可想而知，所以在接到这个需求的第一时间，我就明确要求这个需求要先调研，然后再开始。所以这篇文章也算是对我调研结果的一个总结。

## 技术方案
之前知识做过将文字写到txt文件中，因为txt文件是纯文本且不包含文本格式，所以非常简单因此我最先想到的就是尝试直接将文本写到Word文件中，如果这个方案不行，那就只能通过其他方式转了，例如html。经过一番谷歌搜索，基本确定了下面几个方向

- 文本直接写入Word文件
- 将文本写入html模板中 在写入Word文件
- 其他库实现

下面我们根据上面的几个方向一次来看这几种方式的实现


## 方案验证

### 文本直接写入Excel
 
方法很简单，我们直接看代码


``` swift
    private func writeToWordFile() {
        // 首先尝试直接文档
        let text = "下面我们直接将这段文字写入到Word文档中，然后通过手机端和Mac端查看是否可以打开这个docx文件"
        let path = NSHomeDirectory().appending("/Documents")
        let filePath = path.appending("/1.docx")
        try? text.write(toFile: filePath, atomically: true, encoding: .utf8)
    }
```

通过沙盒路径我们找到了我们新写的这个文件

![沙盒文件](https://tva1.sinaimg.cn/large/e6c9d24egy1h61cxsh61xj20qs0jct9f.jpg)

当我们使用Mac的office组件打开时提示

![打开Word文件](https://tva1.sinaimg.cn/large/e6c9d24egy1h61czu49qaj20nu09kmxk.jpg)
因此这种方式应该是不行的。

*但是*，我这里是直接将文字写成docx文件，那如果我在项目里放一个模型，然后往模型文件里写呢？
我先找一个空的Word文件，将其放到项目中，然后将这个文件拷贝到沙盒中然后再写入内容到这个文件中
![模板文件](https://tva1.sinaimg.cn/large/e6c9d24egy1h61d33nz8qj20qg0i2gmm.jpg)

```swift 
    private func writeToWord() {
        // 现将示例文件拷贝到沙盒位置 有问题 无法打开对应文件
        let text = "下面我们直接将这段文字写入到Word文档中，然后通过手机端和Mac端查看是否可以打开这个docx文件"
        let examplePath = Bundle.main.path(forResource: "example.docx", ofType: nil)
        let destinationPath = NSHomeDirectory().appending("/Documents").appending("/2.docx")
        try? FileManager.default.copyItem(atPath: examplePath!, toPath: destinationPath)
        let data = text.data(using: .utf8)
        try? data?.write(to: URL(fileURLWithPath: destinationPath), options: .atomic)
    }
```
我们发现实际结果与前面的方式是相同的。我们都无法打开对应文件，而且这里`writetofile`应该是重新生成的文件，因为模板文件大小为`12KB`,但是写操作完成时文件变成了`173字节`。

没关系，我们还有另外一种方式就是通过数据流的形式写入到已存在的文件中，这里要用到的是`FileHandle`:

```swift 
    private func fileHandlerWrite() {
        let text = "若为购买过其它非intro offer（连续月、单年、单月）后降级的用户，\n则两次弹窗均给出连续包年intro offer（和现有收银台一致）的sku"
        let examplePath = Bundle.main.path(forResource: "example.docx", ofType: nil)
        let destinationPath = NSHomeDirectory().appending("/Documents").appending("/3.docx")
        try? FileManager.default.copyItem(atPath: examplePath!, toPath: destinationPath)
        let fileHandle = FileHandle(forWritingAtPath: destinationPath)!
        fileHandle.seekToEndOfFile()
        fileHandle.write(text.data(using: .utf8)!)
        try? fileHandle.close()
    }
```
但是结果一样，仍然无法打开文件，因此这了可以认为此方法行不通:broken_heart: 。如果大家有更好的方式也可以评论指出。

不过，当我尝试将文件后缀改为doc时，我发现打开文件时会提示
![doc文件打开提示](https://tva1.sinaimg.cn/large/e6c9d24egy1h61dep5l6lj20yk0u0di6.jpg)
当我选择其他编码，并选择有边框中的`UTF-8`时，我是可以打开文件的。但是目前绝大多数都是使用docx，因此这里也不深入的去讨论doc和docx的区别了。

### HTML

既然直接写入文件的方式不行，那么我们必须借助其他手段来实现我们的目的，首先想到的是html,同时我们在网上也搜到了部分方法

我们先来看下效果再去分析实现，

```swift 
   private func writeHtmlFile() {
        let text = "<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'> 既然直接写入文件的方式不行，那么我们必须借助其他手段来实现我们的目的，首先想到的是html</html>"
        let path = NSHomeDirectory().appending("/Documents")
        let filePath = path.appending("/1.doc")
        try? text.write(toFile: filePath, atomically: true, encoding: .utf8)
    }
```
上面代码中html格式为

```html
<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'>
    // 文件内容
</html>
```

我们通过将上面这段包含html标签和格式的文本写入到一个`doc文件`中,就可以生成一个Word文档，我们打开这个docx文档看下
![html简单doc文件](https://tva1.sinaimg.cn/large/e6c9d24egy1h61nqozpihj20wk0u0tag.jpg)

通过上面的方法，我们验证了可以通过html的方式去写Word文件的思路，既然文本都可以写那么图片呢, 我们知道在写html的时候我们嵌入图片一般都是通过图片路径的方式嵌入到html文件中，但是我们如果是通过改后缀的方式生成Word文件，这就要求我们必须只有一个文件，因此我这里尝试使用直接嵌入图片的base64数据实现


```html
<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'>
    <h1>Title level 1</h1>
    <div>
        <img src="data:image/jpeg;base64,xxxxx">
    </div>
</html>

```
[本地图片生成base64 传送门](https://tool.chinaz.com/tools/imgtobase)

我们在打开我们生成的`doc`文件，可以看到图片已经被展示到正确的位置了

![带图片的doc文件](https://tva1.sinaimg.cn/large/e6c9d24egy1h61o8zzy12j20wk0u0mz2.jpg)

`格局打开`,既然我们都用了html 那么是否html中的其他标签我们都可以使用呢？下面我来来搞一个复杂的例子试试

```html
<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'>
    <h1>Title level 1</h1>
    <h1>Title level 1</h1>
<h2>Title level 2</h2>
<h3>Title level 3</h3>
<p>Text in level 3</p>
<h2>2nd title level 2</h2>
<h3>Another level 3 title</h3>
 
List:
<ul>
<li>element 1</li>
<li>element 2</li>
<li>element 3</li>
  <ul>
  <li>element 4</li>
  <li>element 5</li>
  <li>element 6</li>
      <ul>
      <li>element 7</li>
      <li>element 8</li>
      </ul>
  </ul>
<li>element 9</li>
<li>element 10</li>
</ul>
 
<table width="100%",border="1">
<thead style="background-color:#A0A0FF;">
    <td nowrap>Column A</td><td nowrap>Column B</td><td nowrap>Column C</td>
</thead>
<tr><td>A1</td><td>B1</td><td>C1</td></tr>
<tr><td>A2</td><td>B2</td><td>C2</td></tr>
<tr><td>A3</td><td>B3</td><td>C3</td></tr>
</table>
    <div>
        <img src="data:image/jpeg;xxx">
    </div>
</html>

```
这时候我们在打开对应Word文件 可以发现,html的这些标签都可以支持
![支持html标签的Word](https://tva1.sinaimg.cn/large/e6c9d24egy1h61ojh7xibj20wk0u0q5e.jpg)


那么我们是找到了完美的方案了吗？ **不不不**，如果你仔细看上面的内容你会发现，上面html保存的时候我都保存成了doc文件，而对于最新的docx类型呢？

![无法打开](https://tva1.sinaimg.cn/large/e6c9d24egy1h61om1ke9tj20nu09kaah.jpg)
 
:sob: :sob: :sob: :sob: 

别放弃，我们继续看其他方法

### 真正的Word

#### Word文件结构

这里的实现主要是参考了 stackoverflow中的这个[问题](https://stackoverflow.com/questions/38751495/create-a-word-document-swift),回答问题的大佬给出了这段解释，Word文件包含了复杂的文件格式，具体可以通过将一个Word文档修改后缀为zip，然后解压查看

> Unfortunately, it is nearly impossible to create a .docx file in Swift, given how complicated they are (you can see for yourself by changing the file extension on any old .docx file to .zip, which will reveal their inner structure). The next best thing is to simply create a .txt file, which can also be opened into Pages (though sadly not Docs). If you're looking for a more polished format, complete with formatting and possibly even images, you could choose to create a .pdf file.

我们随便将一个docx，修改后缀后，解压可以看到下面的文件结构:
![Word文件结果](https://tva1.sinaimg.cn/large/e6c9d24ely1h61n0dafkcj20p209w3z4.jpg)

通过查找文件夹中文件的内容我们发现，我们实际写入的文本内容在`word/document.xml`文件中，如下图
![xml文件内容](https://tva1.sinaimg.cn/large/e6c9d24ely1h62evxaacuj21yc0u0kcz.jpg)

那我们只要能够将我们想写入的内容添加到这个文件中就可以完美实现了，废话不多说直接试一下

我们先新建一个docx文档(包含图片) 如下图
![docx文档](https://tva1.sinaimg.cn/large/e6c9d24egy1h62gp0839yj20wo0u00w9.jpg)
我们打开`word/document.xml`发现文字实际已经直接写在了文件中

```xml
    <w:p w:rsidR="00EB53D0" w:rsidRDefault="00D6373D">
      <w:r>
        <w:rPr>
          <w:rFonts w:hint="eastAsia"/>
        </w:rPr>
        <w:t>1</w:t>
      </w:r>
      <w:r>
        <w:t>234567</w:t>
      </w:r>
    </w:p>
    <w:p w:rsidR="00D6373D" w:rsidRDefault="00D6373D">
      <w:pPr>
        <w:rPr>
          <w:b/>
          <w:sz w:val="32"/>
          <w:szCs w:val="32"/>
        </w:rPr>
      </w:pPr>
      <w:r w:rsidRPr="00D6373D">
        <w:rPr>
          <w:rFonts w:hint="eastAsia"/>
          <w:b/>
          <w:sz w:val="32"/>
          <w:szCs w:val="32"/>
        </w:rPr>
        <w:t>啊啊啊啊没有了对吧</w:t>
      </w:r>
    </w:p>
```
那么如果我们要写入文字时就要按照这种格式写入，不过相对于使用Word软件直接生成的，咱们自己写可以相对简单写，比如对文字Font和等都没有要求。

接着我们在来看下图片是如何保存的呢？我们在来看下xml文件中对应内容

```xml
<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
                  <pic:nvPicPr>
                    <pic:cNvPr id="1" name="test.jpg"/>
                    <pic:cNvPicPr/>
                  </pic:nvPicPr>
                  <pic:blipFill>
                    <a:blip r:embed="rId4">
                      <a:extLst>
                        <a:ext uri="{28A0092B-C50C-407E-A947-70E740481C1C}">
                          <a14:useLocalDpi xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main" val="0"></a14:useLocalDpi>
                        </a:ext>
                      </a:extLst>
                    </a:blip>
                    <a:stretch>
                      <a:fillRect/>
                    </a:stretch>
                  </pic:blipFill>
                  <pic:spPr>
                    <a:xfrm>
                      <a:off x="0" y="0"/>
                      <a:ext cx="5080000" cy="3175000"/>
                    </a:xfrm>
                    <a:prstGeom prst="rect">
                      <a:avLst/>
                    </a:prstGeom>
                  </pic:spPr>
                </pic:pic>
```
我们发现xml文件中有踢掉一个标识符 `<a:blip r:embed="rId4">`, 然后我们需要知道`rId4 `表示的是哪一个资源，我们打开`document.xml.rels`文件

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
    <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/webSettings" Target="webSettings.xml"/>
    <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings" Target="settings.xml"/>
    <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
    <Relationship Id="rId6" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="theme/theme1.xml"/>
    <Relationship Id="rId5" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/fontTable" Target="fontTable.xml"/>
    <Relationship Id="rId4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image1.jpg"/>
</Relationships>
```

可以看到 `rId4`表示的是`"media/image1.jpg"`,然后我们到media文件夹下，果然发现了image1.jpg这张图片，对应的恰好使我们添加到Word文件中的那张图片，这样我们图片的添加方式也找到了。

如果你对于docx中的xml文件标签不熟悉，请参考[Word-docx文件图片信息格式分析](https://blog.csdn.net/renfufei/article/details/77481753)


### 如何编辑Word

根据第一步的讲解，我们导出一个docx文件，那么我们应该有下面几步:

![生成Word文件步骤](https://tva1.sinaimg.cn/large/e6c9d24egy1h62h9nz9gwj20dm0k6dgo.jpg)

#### 空Docx文件资源

这一步较为简单，实际上我们新建一个空的文件并进行解压就可以得到，注意这些文件要放到bundle中，生成文件时先拷贝到沙盒，在修改沙盒中的文件。

#### 编辑 word/document.xml 文件

这一步应该是最难的，在我们搜索时发现了已有的库[DocX](https://github.com/shinjukunian/DocX),唯一的缺点就是目前只支持Swift Package，鉴于我们项目中是直接使用的Cocoapods,因此，我这里直接将用到的三个库，封装为一个pod，大家可以直接使用。



#### 压缩文件为 zip

压缩文件，我们也不多说，这里直接用的三方[ZipFoundation](https://github.com/weichsel/ZIPFoundation)

#### 修改文件后缀

这一步也很简单这里不做赘述

我们来简单看下上面四个步骤的代码：


```swift 
 private func writeToDocx() {
        var attributeString = NSMutableAttributedString(string: "1.在QQ上或者微信上搜索关键词“班级群”，一些群无需验证或群管理不到位，骗子就能轻易混进群中。进群后，他们往往潜伏在群里，观察一段时间。 2.骗子趁学生玩手机游戏时，以“免费赠送游戏皮肤、验证身份”为由，要求对方发送班级微信群日常聊天截图和微信群聊二维码，借此混入班级微信群。3.学生、家长和老师的QQ、微信等社交账号被盗，个人信息泄露。进入班级微信群后，骗子还会拉入同伙，克隆班主任的头像和昵称，冒充老师在群里发送有关学校收取书本费、资料费、报名费等信息，同伙则在群里发送缴费截屏，家长见老师发布通知往往不会核实真假，向骗子提供的二维码转账汇款或者在群里发送缴费红包。收取的费用从几十到几百元不等，不易引起家长怀疑。\n")
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "1")!
        attachment.bounds = CGRect(origin: .zero, size: CGSize(width: 300, height: 300))
        let attributeImageText = NSAttributedString(attachment: attachment)
        attributeString.append(attributeImageText)
        self.textView.attributedText=attributeString
        self.textView.backgroundColor = .white
        
        let temp=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("docx")
        try? DocXWriter.write(pages: [attributeString, attributeString], to: temp)
  }

  public class func write(pages:[NSAttributedString], to url:URL, options:DocXOptions = DocXOptions()) throws{
        guard let first=pages.first else {return}
        let result=NSMutableAttributedString(attributedString: first)
        let pageSeperator=NSAttributedString(string: "\r", attributes: [.breakType:BreakType.page])
        
        for page in pages.dropFirst(){
            result.append(pageSeperator)
            result.append(page)
        }
        
        try result.writeDocX(to: url, options: options)
  }


func writeDocX_builtin(to url: URL, options:DocXOptions = DocXOptions()) throws{
        let tempURL=try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: url, create: true)
        
        defer{
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        let docURL=tempURL.appendingPathComponent(UUID().uuidString, isDirectory: true)
        guard let blankURL=Bundle.blankDocumentURL else{throw DocXSavingErrors.noBlankDocument}
        try FileManager.default.copyItem(at: blankURL, to: docURL)

        let docPath=docURL.appendingPathComponent("word").appendingPathComponent("document").appendingPathExtension("xml")
        
        let linkURL=docURL.appendingPathComponent("word").appendingPathComponent("_rels").appendingPathComponent("document.xml.rels")
        let mediaURL=docURL.appendingPathComponent("word").appendingPathComponent("media", isDirectory: true)
        let propsURL=docURL.appendingPathComponent("docProps").appendingPathComponent("core").appendingPathExtension("xml")
        
        
        let linkData=try Data(contentsOf: linkURL)
        var docOptions=AEXMLOptions()
        docOptions.parserSettings.shouldTrimWhitespace=false
        docOptions.documentHeader.standalone="yes"
        let linkDocument=try AEXMLDocument(xml: linkData, options: docOptions)
        let linkRelations=self.prepareLinks(linkXML: linkDocument, mediaURL: mediaURL)
        let updatedLinks=linkDocument.xmlCompact
        try updatedLinks.write(to: linkURL, atomically: true, encoding: .utf8)
        
        let xmlData = try self.docXDocument(linkRelations: linkRelations)
        
        try xmlData.write(to: docPath, atomically: true, encoding: .utf8)
        
        let metaData=options.xml.xmlCompact
        try metaData.write(to: propsURL, atomically: true, encoding: .utf8)

        let zipURL=tempURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("zip")
        try FileManager.default.zipItem(at: docURL, to: zipURL, shouldKeepParent: false, compressionMethod: .deflate, progress: nil)

        try FileManager.default.copyItem(at: zipURL, to: url)
    }

```


至此我们就完成了docx的写入!,如果想更详细的了解写入的过程，大家可以仔细看下`Word文件结构`的文章和`docx`这个库，相信你们可以做的更好。


# 总结

对于上面的几种方法我们做一个利弊总结:

| 方法  | 优点  | 缺点  | 建议  |
|:----------|:----------|:----------|:----------|
| 直接写入    | 简单，纯文本写入doc可行    | 不支持图片，不支持docx格式    | 不建议使用，因为生成的文件打不开    |
| html   | 简单快捷，支持html的格式，样式较多    | 不支持docx格式    | 可接受不支持docx的话 推荐使用     |
|  修改内部结构   | 完美支持docx格式，使用封装库可直接将富文本转换为word文档    | 如果要增加样式支持 门槛较高需要了解Word文件格式    | 没有硬伤，但是后续扩展成本较高    |

根据你的需求，选择一个合适你的方案吧！


# 参考文献

[Word document generation](https://sebsauvage.net/wiki/doku.php?id=word_document_generation)

[Create a word document, Swift](https://stackoverflow.com/questions/38751495/create-a-word-document-swift)

[Open-XML-SDK](https://github.com/OfficeDev/Open-XML-SDK)

[Word-docx文件图片信息格式分析](https://blog.csdn.net/renfufei/article/details/77481753)

[浅谈 Word 文档结构](https://kodango.com/talking-about-the-structure-of-word-document)

[docx文件基本结构](https://www.jianshu.com/p/96362c83e9d9)


