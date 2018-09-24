//
//  ArticleView.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 9/1/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit
//@IBDesignable

class ArticleTile: UIView {
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var authorName: UILabel!
    
    var article: Article = ArticleLibrary.blank;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        print("frame")
//        initialize();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        print("coder")
//        initialize();
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
    
//    func initialize() {
//        tile = Bundle.main.loadNibNamed("ArticleTile", owner: self, options: nil)?.first as? ArticleTile;
//        tile = loadNib();
//        addSubview(tile);
//        tile.frame = self.bounds;
//        tile.autoresizingMask = [.flexibleHeight, .flexibleWidth];
//    }
    
//    func loadNib() -> ArticleTile {
//        let bundle = Bundle(for: type(of: self));
//        let nib = UINib(nibName: "ArticleTile", bundle: bundle);
//        return nib.instantiate(withOwner: self, options: nil)[0] as! ArticleTile;
//    }
}
