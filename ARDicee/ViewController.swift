//
//  ViewController.swift
//  ARDicee
//
//  Created by Zülfücan Karakuş on 28.04.2023.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        //küp oluşturuyor
        //let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        
     //   let sphere = SCNSphere(radius: 0.2)
     //
     //   let material = SCNMaterial()
     //
     //   material.diffuse.contents = UIImage(named: "art.scnassets/8k_moon.jpg")
     //
     //   sphere.materials = [material]
     //
     //   let node = SCNNode()
     //
     //   node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
     //
     //   node.geometry = sphere
     //
     //   sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
        
    

     
     //   // Set the scene to the view
     //   sceneView.scene = diceScene!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        //nesne sabit kalır sen etrafında dönebilirsin
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)
            
            let result = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = result.first{
                
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
                
                if let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true){
                
                    diceNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius, z: hitResult.worldTransform.columns.3.z)
                    
                    diceArray.append(diceNode)
                
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    roll(dice: diceNode)
                    
                }
            }
            
        }
    }
    
    func rollAll(){
        
        if !diceArray.isEmpty {
            for dice in diceArray{
                roll(dice:dice)
            }
        }
    }
    
    func roll(dice:SCNNode){
        
        let randomx = Float(arc4random_uniform(4)+1)*(Float.pi/2)
        
        let randomz = Float(arc4random_uniform(4)+1)*(Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomx * 5), y: 0, z: CGFloat(randomz * 5), duration: 0.5))
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        
        rollAll()
        
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        rollAll()
        
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty{
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if anchor is ARPlaneAnchor {
            
            let planeanchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeanchor.extent.x), height: CGFloat(planeanchor.extent.z))
            
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(x: planeanchor.center.x, y: 0, z: planeanchor.center.z)
            
            planeNode.transform  = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
        }else{
            return
        }
    }

    
}
