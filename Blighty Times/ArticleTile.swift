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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touching")
        isTouched = article.getTitle() == ArticleLibrary.blank.getTitle() ? false : true;
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Ending touch")
        isTouched = false;
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Cancelling touch")
        isTouched = false;
    }
}
