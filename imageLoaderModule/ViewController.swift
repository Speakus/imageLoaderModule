//
//  ViewController.swift
//  imageLoaderModule
//
//  Created by Maxim Nikolaevich on 14.08.2022.
//

import UIKit

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupField()
        setupImageView()
    }

    private func setupImageView() {
        let imgView = ImgLoaderView()
        var frame = view.bounds
        frame.origin.y = 40
        frame.size.height -= frame.origin.y
        imgView.frame = frame
        let imgUrl = URL(string: "https://w-dog.ru/wallpapers/6/3/317191821483406/zabavno-smeshno-milo-kot-koshka-kotenok.jpg")!
        imgView.setImg(from: imgUrl, completion: { error in
            if let error = error {
                print(error.localizedDescription)
            }
        })
        imgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imgView)
    }

    private func setupField() {
        let textField = UITextField()
        textField.textColor = UIColor.black
        var frame = view.bounds
        frame.size.height = 20
        frame.origin.y = 20
        textField.frame = frame
        view.addSubview(textField)
    }
}

