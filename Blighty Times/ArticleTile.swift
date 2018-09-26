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
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        print("frame");
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        print("coder");
    }
    
    func set(article: Article) {
        self.article = article;
        articleTitle.text = article.getTitle();
        authorName.text = article.getAuthor().getName();
        self.backgroundColor = article.getTopic().getColor();
    }
    
    func setBlank() {
        self.article = ArticleLibrary.blank;
        articleTitle.text = "";
        authorName.text = "";
        self.backgroundColor = .clear;
    }
}
