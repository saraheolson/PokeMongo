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
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var ball: SKSpriteNode?
    
    // Defines where user touched
    var startTouchLocation: CGPoint = CGPoint.zero
    var endTouchLocation: CGPoint = CGPoint.zero

    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        label?.isHidden = true
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }

        if ball == nil {
            createBall()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        startTouchLocation = touches.first!.location(in: self)
        updateSpinner(atLocation: startTouchLocation)

//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let currentTouchLocation = touches.first!.location(in: self)
        updateSpinner(atLocation: currentTouchLocation)
        
        if let ball = ball {
            ball.position = currentTouchLocation
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        endTouchLocation = touches.first!.location(in: self)
        updateSpinner(atLocation: endTouchLocation)

        let factor: CGFloat = 50
        let vector = CGVector(dx: factor * (endTouchLocation.x - startTouchLocation.x), dy: factor * (endTouchLocation.y - startTouchLocation.y))
        ball?.physicsBody?.applyImpulse(vector)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let currentTouchLocation = touches.first!.location(in: self)
        updateSpinner(atLocation: currentTouchLocation)
    }
    
    func updateSpinner(atLocation location: CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = location
            n.strokeColor = SKColor.white
            self.addChild(n)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
        
        // Check if the node is not in the scene
        if let ball = ball {
            if (ball.position.x > self.size.width/2 + ball.size.width/2 ||
                ball.position.y > self.size.height + ball.size.height) {
                print("left the view")
                resetBall()
            }
        }
    }
    
    // MARK: - Create nodes
    
    func createBall() {
        ball = SKSpriteNode(imageNamed: "Ball")
        if let ball = ball {
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width/2)
            ball.physicsBody?.isDynamic = true
            ball.physicsBody?.affectedByGravity = false
            ball.physicsBody?.allowsRotation = false
            ball.physicsBody?.mass = 50
            
            ball.position = CGPoint(x: 0, y: 100)
            ball.scale(to: CGSize(width: 50, height: 50))
        
            addChild(ball)
        }
    }
    
    func resetBall() {
        
        // Reset ball and remove it
        ball?.removeAllActions()
        ball?.removeFromParent()
        ball = nil
        
        // Reset touched locations
        startTouchLocation = CGPoint.zero
        endTouchLocation = CGPoint.zero
        
        // Create a new ball to throw
        createBall()
    }
}
