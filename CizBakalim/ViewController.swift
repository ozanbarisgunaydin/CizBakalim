//
//  ViewController.swift
//  CizBakalim
//
//  Created by Ozan Barış Günaydın on 7.10.2021.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    var score = 0
    
    @IBOutlet weak var drawingQuestionLabel: UILabel!
    
    @IBOutlet weak var drawingResultLabel: UILabel!

    @IBOutlet weak var canvasView: CanvasView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    var numbersArray : [String] = []
    
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "Score: \(score)"
        
        numbersArray = ["0","1","2","3","4","5","6","7","8","9"]
        
        drawingQuestionLabel.text = numbersArray.randomElement()

        setupVision()
        
    }
    @objc func increaseScore() {
        score += 1
        scoreLabel.text = "Score: \(score)"
    }
    
    func setupVision() {
        
        guard let visionModel = try? VNCoreMLModel(for: MNISTClassifier().model) else {
            fatalError("Cannot load Vision ML model.")
        }
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleClassfication)
        
        self.requests = [classificationRequest]
    }
    
    func handleClassfication (request: VNRequest, error: Error?) {
        guard let observations = request.results else {print("No Results");return}
        let classfications = observations
            .compactMap({$0 as? VNClassificationObservation})
            .filter({$0.confidence > 0.8})
            .map({$0.identifier})
        
        DispatchQueue.main.async {
            self.drawingResultLabel.text = classfications.first
        }
    }
    
    @IBAction func clearButtonClicked(_ sender: Any) {
        canvasView.clearCanvas()
        
        let randomElement = numbersArray.randomElement()
        self.drawingQuestionLabel.text = randomElement
    }
    @IBAction func recognizeButtonClicked(_ sender: Any) {
        
        if drawingQuestionLabel.text == drawingResultLabel.text {
            increaseScore()
            canvasView.clearCanvas()
            let randomElement = numbersArray.randomElement()
            self.drawingQuestionLabel.text = randomElement
        } else {
        }
        
        
        let image = UIImage(view: canvasView)
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 200, height: 200))
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:])
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
        
    }
    
    func scaleImage(image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x:0, y:0, width:size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}

