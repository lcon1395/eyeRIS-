//
//  ViewController.swift
//  SmartCamera
//
//  Created by Luis Contreras on 9/25/17.
//  Copyright © 2017 Luis Contreras. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var outputLabel: UILabel!
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //camera start up
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
 
        //VNImageRequestHandler(cgImage: CGImage, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
        
    
        
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //print("Camera was able to capture a frame", Date())
        
        guard let pixelBuffer: CVPixelBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        
        let request = VNCoreMLRequest(model: model)
       { (finishedReq, err) in
        
        //check errors
        
        //print(finishedReq.results)
        guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
        
        guard let firstObservation = results.first else { return }
        print(firstObservation.identifier, firstObservation.confidence)
        
        DispatchQueue.main.async {
        
        self.outputLabel.text = " \(firstObservation.identifier)"
        }
        
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
       
    
    }
    @IBAction func textToSpeech(_ sender: Any) {
        
        myUtterance = AVSpeechUtterance(string: outputLabel.text!)
            myUtterance.rate = 0.5
            synth.speak(myUtterance)
        
    }
    

}

