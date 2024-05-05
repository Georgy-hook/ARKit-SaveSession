//
//  ARViewController.swift
//  ARKit + SaveSession
//
//  Created by Георгий Глухов on 02.05.2024.
//

import UIKit
import ARKit
import SceneKit

extension ARSCNView: ARSmartHitTest {}

final class ARViewController: UIViewController {
    //MARK: - UI Elements
    
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.addTarget(self, action: #selector(didShareButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var loadButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "arrow.down.doc"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didLoadButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didDeleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var reloadButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didReloadButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var sideStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [shareButton, loadButton, reloadButton, deleteButton])
        stackView.isHidden = true
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.backgroundColor = .lightGray
        stackView.layer.cornerRadius = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var containerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [settingsButton, sideStackView])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var settingsButton: UIButton = {
        let button = UIButton()
        let gearImage = UIImage(systemName: "gear")?.withRenderingMode(.alwaysTemplate)
        let chevronImage = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
        
        // Combine gear and chevron images vertically
        let combinedImage = combineImagesVertically(images: [gearImage!, chevronImage!])
        
        button.setImage(combinedImage, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleSideStackView), for: .touchUpInside)
        return button
    }()
    
    let sceneView = ARSCNView()
    var currentNode: SCNNode?
    let updateQueue = DispatchQueue(label: "update queue")
    let focusSquare = FocusSquare()
    
    private let worldMapDataKey = "worldMapData"
    let anchorDataKey = "anchorData"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addSubviews()
        applyConstraints()
        
        // Настройка ARSCNView
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        // Настройка сцены AR
        let scene = SCNScene()
        sceneView.scene = scene
        
        focusSquare.viewDelegate = sceneView
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal,.vertical]
        sceneView.automaticallyUpdatesLighting = true
        sceneView.session.run(configuration)
        sceneView.scene.rootNode.addChildNode(focusSquare)
        self.setupGestures()
    }
}

extension ARViewController {
    
    func setupUI() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addSubviews() {
        view.addSubview(sceneView)
        view.addSubview(containerStackView)
    }
    
    func applyConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            containerStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            containerStackView.widthAnchor.constraint(equalToConstant: 48),
            
            shareButton.heightAnchor.constraint(equalToConstant: 48),
            shareButton.widthAnchor.constraint(equalToConstant: 48),
            
            deleteButton.heightAnchor.constraint(equalToConstant: 48),
            deleteButton.widthAnchor.constraint(equalToConstant: 48),
            
            reloadButton.heightAnchor.constraint(equalToConstant: 48),
            reloadButton.widthAnchor.constraint(equalToConstant: 48),
            
            loadButton.heightAnchor.constraint(equalToConstant: 48),
            loadButton.widthAnchor.constraint(equalToConstant: 48),
            
            settingsButton.heightAnchor.constraint(equalToConstant: 48),
            settingsButton.widthAnchor.constraint(equalToConstant: 48),
            
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func combineImagesVertically(images: [UIImage]) -> UIImage {
        let totalHeight = images.reduce(0) { $0 + $1.size.height }
        let width = images.map { $0.size.width }.max() ?? 0
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: totalHeight))
        
        return renderer.image { context in
            var currentY: CGFloat = 0
            for image in images {
                image.draw(in: CGRect(x: 0, y: currentY, width: width, height: image.size.height))
                currentY += image.size.height
            }
        }.withRenderingMode(.alwaysTemplate)
    }
    
    func highlightButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.tintColor = .systemBlue
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                button.tintColor = .white 
            }
        })
    }
}

extension ARViewController {
    @objc func didShareButtonTapped() {
        highlightButton(shareButton)
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap else {
                print("Error getting world map: \(error!.localizedDescription)")
                return
            }
            
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true) else {
                fatalError("Can't encode map")
            }
            
            // Save the world map data to UserDefaults
            UserDefaults.standard.setValue(data, forKey: self.worldMapDataKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    @objc func didLoadButtonTapped() {
        highlightButton(loadButton)
        // Load the world map data from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: worldMapDataKey),
              let unarchived = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) else {
            print("Error loading world map data")
            return
        }
        
        guard let data = UserDefaults.standard.data(forKey: anchorDataKey),
              let anchorUnarchived = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) else {
            print("Error loading anchor data")
            return
        }
        
        let worldMap = unarchived
        
        // Run the session with the loaded world map
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.initialWorldMap = worldMap
        sceneView.session.add(anchor: anchorUnarchived)
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @objc func didDeleteButtonTapped(){
        highlightButton(deleteButton)
        UserDefaults.standard.removeObject(forKey: worldMapDataKey)
        UserDefaults.standard.removeObject(forKey: anchorDataKey)
        UserDefaults.standard.synchronize()
    }
    
    @objc func didReloadButtonTapped(){
        highlightButton(reloadButton)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @objc func toggleSideStackView() {
        settingsButton.isSelected.toggle()
        settingsButton.tintColor = settingsButton.isSelected ? .systemBlue:.white
        UIView.animate(withDuration: 0.3) {
            self.sideStackView.isHidden.toggle()
        }
        
    }
}
