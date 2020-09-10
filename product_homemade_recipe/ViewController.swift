//
//  ViewController.swift
//  product_homemade_recipe
//
//  Created by M'haimdat omar on 29-08-2020.
//

import UIKit
import Fritz
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let cellId = "cellId"
    
    let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.clear
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = true
        table.showsVerticalScrollIndicator = false
        table.allowsSelection = true
        return table
    }()
    
    // MARK: - My products
    lazy var products = [Product]()
    lazy var myProducts = [Product]()
    
    // MARK: - My model
    lazy var myModel = SeedImagesAccurate()
    lazy var visionModel = FritzVisionObjectPredictor(model: SeedImagesAccurate().fritz())

    // MARK: - Vision Properties
    var request: VNCoreMLRequest?
    var OcrRequest: VNRecognizeTextRequest?
    var isInferencing = false
    
    // MARK: - AV Property
    var videoCapture: VideoCapture!
    let semaphore = DispatchSemaphore(value: 1)
    
    // MARK: - Video Preview View
    let videoPreview: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Bounding Box View
    let BoundingBoxView: DrawingBoundingBoxView = {
       let boxView = DrawingBoundingBoxView()
        boxView.translatesAutoresizingMaskIntoConstraints = false
        return boxView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let data = self.readLocalFile(forName: "Products") else {return}
        if let parsedData = self.parse(jsonData: data) {
            self.products = parsedData
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .black
        setupTableView()
        setupCameraView()
        setUpCamera()
        setupBoundingBoxView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
        videoCapture.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }

    // MARK: - SetUp Camera preview
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 30
        videoCapture.setUp(sessionPreset: .high) { success in
            
            if success {
                // add preview view on the layer
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                // start video preview when setup is done
                self.videoCapture.start()
            }
        }
    }
    
    fileprivate func setupCameraView() {
        view.addSubview(videoPreview)
        videoPreview.bottomAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        videoPreview.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        videoPreview.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        videoPreview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
    fileprivate func setupBoundingBoxView() {
        view.addSubview(BoundingBoxView)
        BoundingBoxView.bottomAnchor.constraint(equalTo: videoPreview.bottomAnchor).isActive = true
        BoundingBoxView.leftAnchor.constraint(equalTo: videoPreview.leftAnchor).isActive = true
        BoundingBoxView.rightAnchor.constraint(equalTo: videoPreview.rightAnchor).isActive = true
        BoundingBoxView.topAnchor.constraint(equalTo: videoPreview.topAnchor).isActive = true
    }
    
    fileprivate func setupTableView() {
        view.addSubview(tableView)
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = .systemBackground
        } else {
            tableView.backgroundColor = .white
        }
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: view.frame.height/4).isActive = true
    }

}

extension ViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        
        // the captured image from camera is contained on pixelBuffer
        if !self.isInferencing, let pixelBuffer = pixelBuffer {
            self.isInferencing = true
            let image = FritzVisionImage(imageBuffer: pixelBuffer)
            let options = FritzVisionObjectModelOptions()
            options.threshold = 0.9
            
            guard let results = try? visionModel.predict(image, options: options) else { return }
            DispatchQueue.main.async {
                if results.count > 0 {
                    var result = [FritzVisionObject]()
                    result.append(results.first!)
                    self.BoundingBoxView.predictedObjects = result
                    if let product = self.products.first(where: {$0.id == result[0].label}) {
                        if self.myProducts.contains(where: {$0.id == product.id}) {
                            print("in the array")
                        } else {
                            self.myProducts.append(product)
                            print("reloaded")
                            self.tableView.reloadData()
                        }
                    }
                    
                }
                self.isInferencing = false
            }
            
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = self.myProducts[indexPath.row].name
        cell.textLabel?.textColor = .label
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = RecipeViewController()
        controller.recipe = self.myProducts[indexPath.item].list
        self.present(controller, animated: true, completion: nil)
    }
    
}

