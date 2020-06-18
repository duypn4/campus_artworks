/**
 Author: Ngoc Duy Pham
 IDnumber: 201066354
 Email: n.pham@student.liverpool.ac.uk
 Date: 20/11/2017
 Second Assignment COMP327
 
 -------------*--ArtworkGroupViewController.swift file--*------------------
 the file contains view controller class for the artwork group view of Artworks On Campus app.
 */
import UIKit

class ArtworkGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //field to display view title.
    @IBOutlet weak var viewTitle: UILabel!
    //number of rows in the table displaying all artworks of current building.
    var numberOfRow = 0
    
    //----------------------------------FUCTIONS OF THE CLASS----------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //display title of view as building name and assign value for numberOfRow.
        if let building = currentBuilding {
            viewTitle.text = building.name
            numberOfRow = building.artwork.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        cell.textLabel?.text = currentBuilding?.artwork[indexPath.row].title
        return cell
    }
    
    /*--Fuction to respond when users select the cell on table--*/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //assign the selected artwork to current artwork variable.
        currentArtwork = currentBuilding?.artwork[indexPath.row]
        //go to the detail view of current artwork.
        let artworkView = storyboard?.instantiateViewController(withIdentifier: "Artwork View") as! ArtworkViewController
        self.present(artworkView, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
