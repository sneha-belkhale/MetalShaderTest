//
//  GameViewController.swift
//  MetalCustomShaderTest
//
//  Created by sneha belkhale on 9/3/18.
//  Copyright © 2018 Codercat. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

//custom uniforms for our shader
struct BezierPoints {
    var p0 : float3;
    var p1 : float3;
    var p2 : float3;
    var p3 : float3;
};

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    var flexPlaneGeo: SCNPlane?
    var angle = 0.1;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // create a new scene
        let scene = SCNScene()

        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)

        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)

        //create plane geo
        self.flexPlaneGeo = SCNPlane(width: 1, height: 1)
        self.flexPlaneGeo?.widthSegmentCount = 4;
        self.flexPlaneGeo?.heightSegmentCount = 20;

        //create shader program, by default this looks for program.metal
        let program = SCNProgram()
        program.fragmentFunctionName = "flexFragment"
        program.vertexFunctionName = "flexVertex"
        //attach shader to plane geo
        self.flexPlaneGeo?.firstMaterial?.program = program
        
        //define our custom uniforms
        let point0 = float3(0,0,0);
        let point1 = float3(1,1,0);
        let point2 = float3(-5,2,0);
        let point3 = float3(3,3,0);
        var bezierPoints = BezierPoints(p0:point0, p1:point1, p2:point2, p3:point3)
        //store our uniforms in a buffer
        let data = NSData(bytes: &bezierPoints, length: MemoryLayout<BezierPoints>.size)
        //attach buffer for use in shader
        self.flexPlaneGeo?.firstMaterial?.setValue(data, forKey: "bezierPoints")

        //create node and add to scene
        let flexPlaneNode = SCNNode(geometry: self.flexPlaneGeo)
        flexPlaneNode.position = SCNVector3(x: 0, y: 0, z: 0)
        scene.rootNode.addChildNode(flexPlaneNode)
        
        // retrieve the SCNView
        let scnView = SCNView(frame: self.view.frame, options: ["preferredRenderingAPI": SCNRenderingAPI.openGLES2]);
        self.view.addSubview(scnView)
        //render continuously so we can see the shader updates
        scnView.rendersContinuously = true

        // set the scene to the view
        scnView.scene = scene

        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true

        // show statistics such as fps and timing information
        scnView.showsStatistics = true

        // configure the view
        scnView.backgroundColor = UIColor.gray
        scnView.delegate = self

    }
    
    //this function is a instance of SCNSceneRendererDelegate, it gets called before render allowing us to perform pre-render updates
    func renderer( _ renderer:SCNSceneRenderer, updateAtTime time:TimeInterval) {
        //update our uniforms
        let point0 = float3(0,0,0);
        let point1 = float3(1,1,0);
        let point2 = float3(Float(-5*sin(self.angle)),2,0);
        let point3 = float3(0,3,0);
        var bezierPoints = BezierPoints(p0:point0, p1:point1, p2:point2, p3:point3)
        //reattach to materia
        let data = NSData(bytes: &bezierPoints, length: MemoryLayout<BezierPoints>.size)
        self.flexPlaneGeo?.firstMaterial?.setValue(data, forKey: "bezierPoints")

        self.angle += 0.1;
    }

    
    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
