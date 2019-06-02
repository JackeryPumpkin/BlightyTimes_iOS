//
//  Topic.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 8/19/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class Topic {
    private var _name: String;
    private var _approval: Bool;
    private let _color: UIColor;
    
    init(name: String, approval: Bool, color: UIColor) {
        _name = name;
        _approval = approval;
        _color = color;
    }
    
    func getName() -> String {
        return _name;
    }
    
    func getApproval() -> Bool {
        return _approval;
    }
    
    func getApprovalSymbol() -> String {
        return _approval ? "❤︎" : "✗";
    }
    
    func getColor() -> UIColor {
        return _color;
    }
}

class TopicLibrary {
    static let list: [Topic] = [
        Topic(name: "Conservatism", approval: true, color: #colorLiteral(red: 0.9279299378, green: 0.2826544046, blue: 0.3732864261, alpha: 1)),
        Topic(name: "Conservatism", approval: false, color: #colorLiteral(red: 0.9279299378, green: 0.2826544046, blue: 0.3732864261, alpha: 1)),
        Topic(name: "Liberalism", approval: true, color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)),
        Topic(name: "Liberalism", approval: false, color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)),
        Topic(name: "Children", approval: true, color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)),
        Topic(name: "Children", approval: false, color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)),
        Topic(name: "Violence", approval: true, color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)),
        Topic(name: "Violence", approval: false, color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)),
        Topic(name: "Education", approval: true, color: #colorLiteral(red: 0.3235808367, green: 0.8461168033, blue: 0.688386173, alpha: 1)),
        Topic(name: "Education", approval: false, color: #colorLiteral(red: 0.3235808367, green: 0.8461168033, blue: 0.688386173, alpha: 1)),
        Topic(name: "Theatre", approval: true, color: #colorLiteral(red: 0.7690228947, green: 0.5508928398, blue: 0.42204173, alpha: 1)),
        Topic(name: "Theatre", approval: false, color: #colorLiteral(red: 0.7690228947, green: 0.5508928398, blue: 0.42204173, alpha: 1)),
        Topic(name: "Travel", approval: true, color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)),
        Topic(name: "Travel", approval: false, color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)),
        Topic(name: "Sports", approval: true, color: #colorLiteral(red: 0.8620392335, green: 0.8467336318, blue: 0.3097212091, alpha: 1)),
        Topic(name: "Sports", approval: false, color: #colorLiteral(red: 0.8620392335, green: 0.8467336318, blue: 0.3097212091, alpha: 1)),
        Topic(name: "Film", approval: true, color: #colorLiteral(red: 0.501960814, green: 0.4519438447, blue: 0.470547367, alpha: 1)),
        Topic(name: "Film", approval: false, color: #colorLiteral(red: 0.501960814, green: 0.4519438447, blue: 0.470547367, alpha: 1)),
        Topic(name: "Science", approval: true, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)),
        Topic(name: "Science", approval: false, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)),
        Topic(name: "Religion", approval: true, color: #colorLiteral(red: 0.7872382614, green: 0.2930592953, blue: 0.5784626659, alpha: 1)),
        Topic(name: "Religion", approval: false, color: #colorLiteral(red: 0.7872382614, green: 0.2930592953, blue: 0.5784626659, alpha: 1)),
        Topic(name: "Video Games", approval: true, color: #colorLiteral(red: 0.740938006, green: 0.1459471947, blue: 0.9279299378, alpha: 1)),
        Topic(name: "Video Games", approval: false, color: #colorLiteral(red: 0.740938006, green: 0.1459471947, blue: 0.9279299378, alpha: 1)),
        Topic(name: "Technology", approval: true, color: #colorLiteral(red: 0.3351085484, green: 0.05537386984, blue: 0.7984034419, alpha: 1)),
        Topic(name: "Technology", approval: false, color: #colorLiteral(red: 0.3351085484, green: 0.05537386984, blue: 0.7984034419, alpha: 1)),
        Topic(name: "Music", approval: true, color: #colorLiteral(red: 0.357692138, green: 0.7539047226, blue: 0.7730805838, alpha: 1)),
        Topic(name: "Music", approval: false, color: #colorLiteral(red: 0.357692138, green: 0.7539047226, blue: 0.7730805838, alpha: 1))
    ];
    
    static let blank: Topic = Topic(name: "", approval: false, color:  #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0));
    
    static func getRandomTopics() -> [Topic] {
        return getRandomTopics(from: TopicLibrary.list);
    }
    
    static func getRandomTopics(from subset: [Topic], quantity MAX: Int = 3) -> [Topic] {
        let numTopics = Random(index: subset.count > MAX ? MAX : subset.count);
        var topics: [Topic] = [];
        var usedTopics: [Int] = [];
        
        for _ in 0 ... numTopics {
            var topicIndex = Random(index: subset.count);
            var valid: Bool = false;
            
            while (!valid) {
                valid = true;
                
                for i in 0 ..< usedTopics.count {
                    if (topicIndex == usedTopics[i]) {
                        topicIndex = Random(index: subset.count);
                        valid = false
                    }
                }
            }
            
            topics.append(subset[topicIndex]);
            usedTopics.append(topicIndex);
        }
        
        return topics;
    }
}
