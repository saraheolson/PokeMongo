//
//  Ball.swift
//  PokeYourMongo
//
//  Created by Floater on 8/13/16.
//  Copyright © 2016 WomenWhoCode. All rights reserved.
//

import UIKit
import SpriteKit

class Ball {
    
    var node: SKSpriteNode?
    
    init() {
        
        // Create a new ball
        node = SKSpriteNode(imageNamed: "Ball")
        
        if let ball = node {
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width/2)
            ball.physicsBody?.isDynamic = true
            ball.physicsBody?.affectedByGravity = false
            ball.physicsBody?.allowsRotation = false
        }
    }
    
    func updatePosition(toPoint point: CGPoint) {
        if let ball = node {
            ball.position = point
        }
    }
}
