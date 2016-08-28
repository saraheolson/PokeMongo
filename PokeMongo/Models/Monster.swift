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
    let minY: UInt32 = 100
    let minX: UInt32 = 0
    let maxY: CGFloat
    let maxX: CGFloat
    
    var monsterPositions: [CGPoint]

    init(name: String,
         hitColor: UIColor,
         maxX: CGFloat,
         maxY: CGFloat) {
        
        self.name = name
        self.hitColor = hitColor
        self.maxX = maxX
        self.maxY = maxY
        
        monsterPositions = [CGPoint(x: maxX, y: maxY-(maxY/3)),
                            CGPoint(x: -maxX, y: maxY/2),
                            CGPoint(x: maxX/2, y: maxY),
                            CGPoint(x: -maxX, y: maxY/4),
                            CGPoint(x: maxX/3, y: maxY-(maxY/4))]
    }
    
    func configureMonster() {
        
        // Get the images for the monster
        let textureAtlas = SKTextureAtlas(named:"\(name).atlas")
        
        // Programmatically add sprite animation
        spriteArray = [textureAtlas.textureNamed("\(name)1"),
                       textureAtlas.textureNamed("\(name)2")]
        
        // Create the node
        node = SKSpriteNode(texture:spriteArray[0]);
        
        if let node = node {
            
            // Set the node position
            node.position = randomPosition()
            node.zPosition = 2
            
            // Add physics
            node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.frame.size)
            node.physicsBody?.isDynamic = true
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.allowsRotation = false
            
            // Define which objects collide or contact
            node.physicsBody?.categoryBitMask = monsterMask
            node.physicsBody?.collisionBitMask = ballMask
            node.physicsBody?.contactTestBitMask = ballMask
            
            // Set the size of the node to a random value
            let scale = randomScale()
            node.xScale = scale;
            node.yScale = scale;
            
            // Start the animations
            startMovement()
        }
    }
    
    // MARK: - Actions
    
    func directHit() {
        
        // When the monster is hit, remove from view and stop all actions
        if let node = node {
            node.removeAllActions()
            node.removeFromParent()
        }
    }
    
    func startMovement() {
        
        if let node = node {
            
            // Create a series of random actions to move monster around screen
            let moveSequence = SKAction.sequence([
                randomMoveAction(),
                randomMoveAction(),
                randomMoveAction(),
                randomMoveAction(),
                randomMoveAction()])
            
            // Repeat these movements until the monster is destroyed
            let repeatMoves = SKAction.repeatForever(moveSequence)
            node.run(repeatMoves)
            
            // Animate the monster using the sprite atlas images
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
    
    func randomPosition() -> CGPoint {
        let randomIndex = Int(arc4random_uniform(UInt32(monsterPositions.count)))
        let point = monsterPositions[randomIndex]
        return point
    }
    
    func randomScale() -> CGFloat {
        
        // Number between 0.3 and 1.3
        let scale = (CGFloat(arc4random()) /  CGFloat(UInt32.max)) + 0.3
        print("scale: \(scale)")
        return scale
    }
    
    // MARK: - Static factory functions
    
    static func allMonsters(_ screenHeight: CGFloat, screenWidth: CGFloat) -> [Monster] {
        
        let blueMonster = Monster(name: "BlueMonster",
                                  hitColor: UIColor.blue,
                                  maxX: screenWidth/2,
                                  maxY: screenHeight)
        let purpleMonster = Monster(name: "PurpleMonster",
                                    hitColor: UIColor.purple,
                                    maxX: screenWidth/2,
                                    maxY: screenHeight)
        let blackMonster = Monster(name: "BlackMonster",
                                   hitColor: UIColor.black,
                                   maxX: screenWidth/2,
                                   maxY: screenHeight)
        let greenMonster = Monster(name: "GreenMonster",
                                   hitColor: UIColor.green,
                                   maxX: screenWidth/2,
                                   maxY: screenHeight)
        
        return [blueMonster, purpleMonster, blackMonster, greenMonster]
    }
}
