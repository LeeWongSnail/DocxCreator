//
//  ViewController.swift
//  YXDocXCreator
//
//  Created by liwang8 on 08/31/2022.
//  Copyright (c) 2022 liwang8. All rights reserved.
//

import UIKit
import YXDocXCreator

class ViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textView)
        textView.frame = view.bounds
        
        // Do any additional setup after loading the view, typically from a nib.
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Lazy Load
    private lazy var textView: UITextView = {
        let textView = UITextView()
        
        return textView
    }()

}

