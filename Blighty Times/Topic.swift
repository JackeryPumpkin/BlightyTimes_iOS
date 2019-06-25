//
//  Topic.swift
//  BlightyTimes
//
//  Created by Zachary Duncan on 8/19/18.
//  Copyright © 2018 Zachary Duncan. All rights reserved.
//

import UIKit

class Topic {
    let name: String
    let color: UIColor
    let articleColor: UIColor
    let image: UIImage
    
    init(name: String, color: UIColor, image: UIImage) {
        self.name = name
        self.color = color
        self.articleColor = color - 0.1
        self.image = image
    }
}

class TopicLibrary {
    static let list: [Topic] = [
        Topic(name: "Conservatism", color: #colorLiteral(red: 0.9294117647, green: 0.2823529412, blue: 0.3725490196, alpha: 1), image: #imageLiteral(resourceName: "Conservatism")),
        Topic(name: "Liberalism", color: #colorLiteral(red: 0.392133534, green: 0.3922289014, blue: 1, alpha: 1), image: #imageLiteral(resourceName: "Liberalism")),
        Topic(name: "Children", color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), image: #imageLiteral(resourceName: "Children")),
        Topic(name: "Violence", color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), image: #imageLiteral(resourceName: "Violence")),
        Topic(name: "Education", color: #colorLiteral(red: 0.3254901961, green: 0.8470588235, blue: 0.6901960784, alpha: 1), image: #imageLiteral(resourceName: "Education")),
        Topic(name: "Theatre", color: #colorLiteral(red: 0.768627451, green: 0.5490196078, blue: 0.4235294118, alpha: 1), image: #imageLiteral(resourceName: "Theatre")),
        Topic(name: "Literature", color: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), image: #imageLiteral(resourceName: "Literature")),
        Topic(name: "Travel", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), image: #imageLiteral(resourceName: "Travel")),
        Topic(name: "Sports", color: #colorLiteral(red: 0.862745098, green: 0.8470588235, blue: 0.3098039216, alpha: 1), image: #imageLiteral(resourceName: "Sports")),
        Topic(name: "Cinema", color: #colorLiteral(red: 0.501960814, green: 0.4519438447, blue: 0.470547367, alpha: 1), image: #imageLiteral(resourceName: "Film")),
        Topic(name: "Science", color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), image: #imageLiteral(resourceName: "Science")),
        Topic(name: "Religion", color: #colorLiteral(red: 0.7872382614, green: 0.2930592953, blue: 0.5784626659, alpha: 1), image: #imageLiteral(resourceName: "Religion")),
        Topic(name: "Video Games", color: #colorLiteral(red: 0.740938006, green: 0.1459471947, blue: 0.9279299378, alpha: 1), image: #imageLiteral(resourceName: "VideoGames")),
        Topic(name: "Technology", color: #colorLiteral(red: 0.3351085484, green: 0.05537386984, blue: 0.7984034419, alpha: 1), image: #imageLiteral(resourceName: "Technology")),
        Topic(name: "Music", color: #colorLiteral(red: 0.357692138, green: 0.7539047226, blue: 0.7730805838, alpha: 1), image: #imageLiteral(resourceName: "Music"))
    ]
    
    static let blank: Topic = Topic(name: "", color:  #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0), image: UIImage())
    
    static func getRandomTopics(count: Int, excludedTopics: [Topic]?) -> [Topic] {
        var newTopics: [Topic] = []
        var validTopics: [Topic] = []
        
        if let excludedTopics = excludedTopics {
            validTopics = TopicLibrary.list.filter { topic -> Bool in
                return !(excludedTopics.contains(where: { excludedTopic -> Bool in return excludedTopic.name == topic.name }))
            }
        } else {
            validTopics = TopicLibrary.list
        }
        
        validTopics.shuffle()
        
        for i in 0 ..< count {
            newTopics.append(validTopics[i])
        }
        
        return newTopics
    }
    
    static func getRandomTopics() -> [Topic] {
        return getRandomTopics(from: TopicLibrary.list);
    }
    
    static func getRandomTopics(from subset: [Topic], quantity MAX: Int = 3) -> [Topic] {
        let numTopics = RandomIndex(fromCount: subset.count > MAX ? MAX : subset.count);
        var topics: [Topic] = [];
        var usedTopics: [Int] = [];
        
        for _ in 0 ... numTopics {
            var topicIndex = RandomIndex(fromCount: subset.count);
            var valid: Bool = false;
            
            while (!valid) {
                valid = true;
                
                for i in 0 ..< usedTopics.count {
                    if (topicIndex == usedTopics[i]) {
                        topicIndex = RandomIndex(fromCount: subset.count);
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
