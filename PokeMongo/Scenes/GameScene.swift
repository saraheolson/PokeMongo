//
//  GameScene.swift
//  PokeMongo
//
//  Created by Floater on 8/21/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // Define nodes used in the game
    var ball: SKSpriteNode?
    var monster: SKSpriteNode?
    
    // Label for displaying contextual information to the user
    var titleLabel : SKLabelNode?

    // Holds last touch event locations
    var startTouchLocation: CGPoint = CGPoint.zero
    var endTouchLocation: CGPoint = CGPoint.zero

    override func sceneDidLoad() {
        
        // Get label node from scene and store it for use later
        self.titleLabel = self.childNode(withName: "//helloLabel") as? SKLabelNode
        titleLabel?.isHidden = true

        // Add a ball to the scene
        if ball == nil {
            createBall()
        }
        
        if monster == nil {
            createMonster()
        }
    }
    
    // MARK: - Touch gesture methods
    
    /**
     *  Called when a touch event is initiated.
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Record the beginning of the touch event
        startTouchLocation = touches.first!.location(in: self)
    }
    
    /**
     *  Called when a touch event moves.
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Move the ball along with the user's touch gesture
        let currentTouchLocation = touches.first!.location(in: self)
        if let ball = ball {
            ball.position = currentTouchLocation
        }
    }
    
    /**
     *  Called when a touch event is ended.
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Record the end of the touch event
        endTouchLocation = touches.first!.location(in: self)
        
        // Continue the ball's movement along the same path as the touch gesture
        let factor: CGFloat = 50
        let vector = CGVector(dx: factor * (endTouchLocation.x - startTouchLocation.x), dy: factor * (endTouchLocation.y - startTouchLocation.y))
        ball?.physicsBody?.applyImpulse(vector)
    }
    
    /**
     *  Called before each frame is rendered.
     */
    override func update(_ currentTime: TimeInterval) {
        
        // Check to see if the ball node has left the scene bounds
        if let ball = ball {
            if (ball.position.x > self.size.width/2 + ball.size.width/2 ||
                ball.position.x < -(self.size.width/2 + ball.size.width/2) ||
                ball.position.y > self.size.height + ball.size.height) {
                
                // The ball is outside the bounds of the visible view
                resetBall()
            }
        }
    }
    
    // MARK: - Ball node methods
    
    /**
     * Create a ball node and add it to the scene.
     */
    func createBall() {
        
        // Create the ball node
        ball = SKSpriteNode(imageNamed: "Ball")
        if let ball = ball {
            
            // Add physics
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width/2)
            ball.physicsBody?.isDynamic = true
            ball.physicsBody?.affectedByGravity = false
            ball.physicsBody?.allowsRotation = false
            ball.physicsBody?.mass = 50

            // Set position and scale
            ball.position = CGPoint(x: 0, y: 100)
            ball.scale(to: CGSize(width: 50, height: 50))
        
            // Add to the scene
            addChild(ball)
            
            // Display a spark particle when the ball is placed in the scene
            let spark:SKEmitterNode = SKEmitterNode(fileNamed: "MagicParticle")!
            spark.position = ball.position
            self.addChild(spark)
        }
    }
    
    /**
     * Reset the ball to the default position.
     */
    func resetBall() {
        
        // Remove the current ball from the scene
        ball?.removeAllActions()
        ball?.removeFromParent()
        ball = nil
        
        // Reset touch locations
        startTouchLocation = CGPoint.zero
        endTouchLocation = CGPoint.zero
        
        // Create a new ball and add to the scene
        createBall()
    }
    
    // MARK: - Monster functions
    
    func createMonster() {
        
        monster = SKSpriteNode(imageNamed: "PurpleMonster1")
        
        if let monster = self.monster {
            
            monster.position = CGPoint(x: 0, y: frame.height/2)
            monster.zPosition = 2
            
            addChild(monster)
        }
    }
}
