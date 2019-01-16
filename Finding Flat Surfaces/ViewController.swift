import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ARSCNビューのデリゲート先になる
        sceneView.delegate = self
        
        // デバッグ情報を表示する
        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 水平面を検出するコンフィギュレーションを生成する
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]

        // セッションを実行する
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // セッションを停止する
        sceneView.session.pause()
    }
    
    // 板状ノードを生成する
    func createFloor(from anchor: ARPlaneAnchor) -> SCNNode{
        // アンカー情報から、板の寸法を取得する
        let anchorWidth  = CGFloat(anchor.extent.x)
        let anchorHeight = CGFloat(anchor.extent.z)
        
        // ノードの形状を板状にして、グリーンに設定する
        let planeGeometry = SCNPlane(width: anchorWidth, height: anchorHeight)
        planeGeometry.firstMaterial?.diffuse.contents = UIColor.green
        
        // 板状ノードを生成して、水平に寝かせて半透明にする
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.eulerAngles.x = -Float.pi/2
        planeNode.opacity = 0.25
        
        return planeNode
    }

    // MARK: - ARSCNViewDelegate

    // アンカーが追加されたら、板状ノードを置く
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // アンカーが水平面ならば...
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return  }

        // 板状ノードを生成して、シーンに追加する
        let floor = createFloor(from: planeAnchor)
        node.addChildNode(floor)
    }
    
    // アンカーが更新されたら
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // アンカーが水平面で、ノードが存在していて、ノード形状が板状ならば...
        guard let planeAnchor = anchor as? ARPlaneAnchor,
                   let planeNode = node.childNodes.first,
                   let planeNodeGeometry = planeNode.geometry as? SCNPlane
            else { return }

        // アンカー情報に基づいて、板状ノードの位置を修正
        let updatedPosition = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.position = updatedPosition

        // アンカー情報に基づいて、板状ノードの寸法を修正
        planeNodeGeometry.width  = CGFloat(planeAnchor.extent.x)
        planeNodeGeometry.height = CGFloat(planeAnchor.extent.z)
    }
    
}
