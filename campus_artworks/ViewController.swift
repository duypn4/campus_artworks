/**
 Author: Ngoc Duy Pham
 IDnumber: 201066354
 Email: n.pham@student.liverpool.ac.uk
 Date: 20/11/2017
 Second Assignment COMP327
 
 -------------*--ViewController.swift file--*------------------
 the file contains view controller class for the initial view of Artworks On Campus app.
 */
import UIKit
import CoreData
import CoreLocation

//global struct ArtworksType.
struct ArtworksType: Codable {
    let artworks2: [ArtworkType]
}
//global struct ArtworkType.
struct ArtworkType: Codable {
    let id: String
    let title: String
    let artist: String
    let yearOfWork: String
    let Information: String
    let lat: String
    let long: String
    let location: String
    let locationNotes: String
    let fileName: String
    let lastModified: String
    let enabled: String
}

//global struct BuildingType.
struct BuildingType {
    let name: String
    let distanceFromUser: Double
    let artwork: [ArtworkType]
}

//array to store all buildings where artworks locate in.
var buildings = [BuildingType]()

class ViewController: UIViewController {
    
    @IBOutlet weak var alertLabel: UILabel!
    
    @IBOutlet weak var enterButton: UIButton!
    
    //array to store all artworks.
    var artworks = [ArtworkType]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var context: NSManagedObjectContext?
    
    //----------------------------------FUCTIONS OF THE CLASS----------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        alertLabel.isHidden = true
        enterButton.isEnabled = false
        
        context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Artwork")
        request.returnsObjectsAsFaults = false
        
        //fetch Core Data to check there are any caching data or not.
        do {
            let results = try context?.fetch(request) as! [NSManagedObject]
            
            if results.count == 0 {      //if there is not any caching data, retrieve data from the json file from the given URL.
                alertLabel.isHidden = false
                let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP327/artworksOnCampus/data.php?class=artworks2&lastUpdate=2017-11-01")!
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if error != nil {
                        print(error as Any)
                        DispatchQueue.main.async {
                            self.alertLabel.text = "Failed to download Data!!!"
                        }
                    } else {
                        if let urlContent = data {
                            do {
                                let jsonResult = try JSONDecoder().decode(ArtworksType.self, from: urlContent)
                                DispatchQueue.main.async {
                                    self.artworks += jsonResult.artworks2
                                    self.storeInCoreData()
                                    self.storeImageData()
                                    self.groupByBuilding()
                                    self.alertLabel.text = "Completed!"
                                    self.enterButton.isEnabled = true
                                }
                            } catch {
                                DispatchQueue.main.async {
                                    self.alertLabel.text = "Failed to download Data!!!"
                                }
                                print("!!!---JSON PROCESSING FAILED---!!!")
                            }
                        }
                    }
                }
                task.resume()
            } else {  //else, then fetch artwork information and group them into the building array.
                getFromCoreData(fetchResults: results)
                groupByBuilding()
                enterButton.isEnabled = true
            }
        } catch {
            print("CoreData Fetching Error!!!")
        }
    }
    
    /*--Fuction to store artwork information into Core Data--*/
    func storeInCoreData() {
        for artwork in artworks {
            let newArtwork = NSEntityDescription.insertNewObject(forEntityName: "Artwork", into: context!)
            newArtwork.setValue(artwork.id, forKey: "id")
            newArtwork.setValue(artwork.title, forKey: "title")
            newArtwork.setValue(artwork.artist, forKey: "artist")
            newArtwork.setValue(artwork.yearOfWork, forKey: "yearOfWork")
            newArtwork.setValue(artwork.Information, forKey: "information")
            newArtwork.setValue(artwork.lat, forKey: "latitude")
            newArtwork.setValue(artwork.long, forKey: "longitude")
            newArtwork.setValue(artwork.location, forKey: "location")
            newArtwork.setValue(artwork.locationNotes, forKey: "locationNote")
            newArtwork.setValue(artwork.fileName, forKey: "fileName")
            newArtwork.setValue(artwork.lastModified, forKey: "lastModified")
            newArtwork.setValue(artwork.enabled, forKey: "enabled")
        }
        do {
            try context?.save()
            print("Saved All Artworks!")
        } catch {
            print("CoreData Saving Error!!!")
        }
    }
    
    /*--Fuction to store images into User Default--*/
    func storeImageData() {
        //string variable contains the prefix of each image URL.
        let linkPrefix = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP327/artwork_images/"
        for artwork in artworks {
            //combine the prefix with the fileName to form the string of whole image URL.
            if let linkString = (linkPrefix + artwork.fileName).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                //get the data of artwork image from the URL.
                do {
                    let data = try Data(contentsOf: URL(string: linkString)!)
                    //store data into User Default.
                    UserDefaults.standard.set(data, forKey: artwork.fileName)
                } catch {
                    print("Fetching Image Data Errors!")
                }
            }
        }
        print("Saved Image Data!")
    }
    
    /*--Fuction to get information from Core Data--*/
    func getFromCoreData(fetchResults: [NSManagedObject]) {
        for result in fetchResults {
            if let id = result.value(forKey: "id") as? String, let title = result.value(forKey: "title") as? String, let artist = result.value(forKey: "artist") as? String, let yearOfWork = result.value(forKey: "yearOfWork") as? String, let information = result.value(forKey: "information") as? String, let latitude = result.value(forKey: "latitude") as? String, let longitude = result.value(forKey: "longitude") as? String, let location = result.value(forKey: "location") as? String, let locationNote = result.value(forKey: "locationNote") as? String, let fileName = result.value(forKey: "fileName") as? String, let lastModified = result.value(forKey: "lastModified") as? String, let enabled = result.value(forKey: "enabled") as? String {
                
                //insert information of each artwork into artworks array.
                artworks.append(ArtworkType(id: id, title: title, artist: artist, yearOfWork: yearOfWork, Information: information, lat: latitude, long: longitude, location: location, locationNotes: locationNote, fileName: fileName, lastModified: lastModified, enabled: enabled))
            }
        }
    }
    
    /*--Fuction to sort artworks into the building array--*/
    func groupByBuilding() {
        //array for obtaining artworks for each building.
        var arts = [ArtworkType]()
        //array to recognize which artwork has been added to a building.
        var chosenIndexs = [Int]()
        //the location of user (Ashton Building).
        let userLocation = CLLocation(latitude: 53.406566, longitude: -2.966531)
        
        //index of the prior artwork
        var index1 = 0
        while index1 < artworks.count {    //start sort the artworks array.
            if chosenIndexs.contains(index1) == false {   //if the artwork has been chosen, then append to arts array.
                arts.append(artworks[index1])
                
                //index of successor artwork.
                var index2 = index1 + 1
                while index2 < artworks.count {
                    if artworks[index1].location == artworks[index2].location {   //if succesor artwork has same buidling with the first one, add to the arts array
                        arts.append(artworks[index2])
                        chosenIndexs.append(index2)    //add index of successor artwork to chosenIndexs array.
                    }
                    index2 += 1
                }
                //the location of the building.
                let buildingLocation = CLLocation(latitude: Double(arts[0].lat)!, longitude: Double(arts[0].long)!)
                //the distance form the building to the user location.
                let distance = buildingLocation.distance(from: userLocation)
                //add the building into the buildings array.
                buildings.append(BuildingType(name: arts[0].location, distanceFromUser: distance, artwork: arts))
            }
            arts.removeAll()
            index1 += 1
        }
        //sort the buildings array based on the distance to user location.
        buildings.sort { (building1, building2) -> Bool in
            return building1.distanceFromUser < building2.distanceFromUser
        }
        artworks.removeAll()
        //print(buildings.count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

