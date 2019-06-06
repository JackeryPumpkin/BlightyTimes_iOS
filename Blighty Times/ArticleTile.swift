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
    @IBOutlet weak var quality: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    var article: Article = ArticleLibrary.blank;
    var touched: Bool = false
    var blinking: Bool = false
    var blank: Bool = true
    
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
        quality.text = "\(article.getQuality())"
        image.image = article.getTopic().image
        backgroundColor = article.getTopic().articleColor
        isUserInteractionEnabled = true
        blank = article === ArticleLibrary.blank
    }
    
    func setBlank() {
        self.article = ArticleLibrary.blank;
        articleTitle.text = "";
        authorName.text = "";
        image.image = UIImage()
        self.backgroundColor = .clear;
        self.isUserInteractionEnabled = false;
        
        blinking = false
        blank = true
        layer.removeAllAnimations()
    }
    
    func playLowLifeAnimation() {
        if touched {
            blinking = false
            layer.removeAllAnimations()
        } else {
            if !blinking && !blank {
                pulseBackground()
                blinking = true
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched = true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched = false;
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched = false;
    }
}
