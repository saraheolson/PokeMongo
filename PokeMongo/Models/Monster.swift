//
//  Monster.swift
//  PokeYourMongo
//
//  Created by Floater on 8/13/16.
//  Copyright © 2016 WomenWhoCode. All rights reserved.
//

import UIKit
import SpriteKit

class Monster {
    
    var name: String
    var spriteArray = Array<SKTexture>();
    var hitColor: UIColor
    var node: SKSpriteNode?
    let minY: UInt32
    let minX: UInt32
    let maxY: UInt32
    let maxX: UInt32
    
    init(name: String,
         hitColor: UIColor,
         minX: UInt32,
         minY: UInt32,
         maxX: UInt32,
         maxY: UInt32) {
        
        self.name = name
        self.hitColor = hitColor
        self.minX = minX
        self.minY = minY
        self.maxX = maxX
        self.maxY = maxY
    }
    
    func configureMonster() {
        
        let textureAtlas = SKTextureAtlas(named:"\(name).atlas")
        
        // Programmatically add sprite animation
        spriteArray = [textureAtlas.textureNamed("\(name)1"),
                       textureAtlas.textureNamed("\(name)2")]
        
        node = SKSpriteNode(texture:spriteArray[0]);
        
        if let node = node {
            node.position = randomPosition()
            node.zPosition = 2
            node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.frame.size)
            node.physicsBody?.isDynamic = true
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.allowsRotation = false
//            node.physicsBody?.categoryBitMask = monsterMask
//            node.physicsBody?.collisionBitMask = ballMask
//            node.physicsBody?.contactTestBitMask = ballMask
            
            let scale = randomScale()
            node.xScale = scale;
            node.yScale = scale;
            
            startMovement()
        }
    }
    
    // MARK: - Actions
    
    func directHit() {
        if let node = node {
            node.removeAllActions()
            node.removeFromParent()
        }
    }
    
    func startMovement() {
        
        if let node = node {
            let moveSequence = SKAction.sequence([randomMoveAction(), randomMoveAction(), randomMoveAction(), randomMoveAction(), randomMoveAction()])
            let repeatMoves = SKAction.repeatForever(moveSequence)
            node.run(repeatMoves)
            
            let animateAction = SKAction.animate(with: spriteArray, timePerFrame: 0.20);
            let repeatAnimation = SKAction.repeatForever(animateAction)
            node.run(repeatAnimation)
        }
    }

    func stopMovement() {
        node?.removeAllActions()
    }
    
    // MARK: - Random functions
    
    func randomMoveAction() -> SKAction {
        return SKAction.move(to: randomPosition(), duration: 1.0)
    }
    
    func randomScale() -> CGFloat {
        
        // Number between 0.2 and 1
        return (CGFloat(arc4random()) /  CGFloat(UInt32.max)) + 0.2
    }

    func randomPosition() -> CGPoint {
        
        let randomX = arc4random_uniform(UInt32(maxX)) + minX
        let randomY = arc4random_uniform(UInt32(maxY)) + minY
        
        print("randomPoint: \(randomX),\(randomY)")
        return CGPoint(x: CGFloat(randomX), y: CGFloat(randomY))
    }
    
    // MARK: - Static factory functions
    
    static func allMonsters(_ screenHeight: UInt32, screenWidth: UInt32) -> [Monster] {
        
        let blueMonster = Monster(name: "BlueMonster",
                                  hitColor: UIColor.blue,
                                  minX: 0,
                                  minY: 200,
                                  maxX: screenWidth,
                                  maxY: screenHeight)
        let purpleMonster = Monster(name: "PurpleMonster",
                                    hitColor: UIColor.purple,
                                    minX: 0,
                                    minY: 200,
                                    maxX: screenWidth,
                                    maxY: screenHeight)
        let blackMonster = Monster(name: "BlackMonster",
                                   hitColor: UIColor.black,
                                   minX: 0,
                                   minY: 200,
                                   maxX: screenWidth,
                                   maxY: screenHeight)
        let greenMonster = Monster(name: "GreenMonster",
                                   hitColor: UIColor.green,
                                   minX: 0,
                                   minY: 200,
                                   maxX: screenWidth,
                                   maxY: screenHeight)
        
        return [blueMonster, purpleMonster, blackMonster, greenMonster]
    }
}
