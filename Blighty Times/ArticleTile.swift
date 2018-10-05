//
//  ArticleView.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 9/1/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class ArticleTile: UIView {
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var authorName: UILabel!
    
    var article: Article = ArticleLibrary.blank;
    var isTouched: Bool = false;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        print("frame");
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        print("coder");
    }
    
    func set(article: inout Article) {
        self.article = article;
        articleTitle.text = article.getTitle();
        authorName.text = article.getAuthor().getName();
        self.backgroundColor = article.getTopic().getColor();
        self.isUserInteractionEnabled = true;
    }
    
    func setBlank() {
        self.article = ArticleLibrary.blank;
        articleTitle.text = "";
        authorName.text = "";
        self.backgroundColor = .clear;
        self.isUserInteractionEnabled = false;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouched = true;
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouched = false;
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouched = false;
    }
}
