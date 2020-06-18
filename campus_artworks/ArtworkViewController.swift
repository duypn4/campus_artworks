/**
 Author: Ngoc Duy Pham
 IDnumber: 201066354
 Email: n.pham@student.liverpool.ac.uk
 Date: 20/11/2017
 Second Assignment COMP327
 
 -------------*--ArtworkViewController.swift file--*------------------
 the file contains view controller class for the artwork view of Artworks On Campus app.
 */
import UIKit

class ArtworkViewController: UIViewController {
    //text field to display information of specific artwork.
    @IBOutlet weak var textView: UITextView!
    //image view to display artwork image.
    @IBOutlet weak var imageView: UIImageView!
    
    //----------------------------------FUCTIONS OF THE CLASS----------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let artwork = currentArtwork {
            //display information on the field
            textView.text = "ID: \(artwork.id)\nTitle: \(artwork.title)\nArtist: \(artwork.artist)\nYear of work: \(artwork.yearOfWork)\nLocation: \(artwork.locationNotes)\n\nInformation: \(artwork.Information)"
            
            //fetch image from User Default and put it on image view.
            if let imageData = UserDefaults.standard.value(forKey: artwork.fileName) as? Data {
                imageView.image = UIImage(data: imageData)
            }
        }
    }
    
    /*--Action of the back button--*/
    @IBAction func backButtonAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
