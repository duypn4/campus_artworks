/**
 Author: Ngoc Duy Pham
 IDnumber: 201066354
 Email: n.pham@student.liverpool.ac.uk
 Date: 20/11/2017
 Second Assignment COMP327
 
 -------------*--MapViewController.swift file--*------------------
 the file contains view controller class for the map view of Artworks On Campus app.
 */
import UIKit
import MapKit

//the chosen building
var currentBuilding: BuildingType?
//the chosen artwork
var currentArtwork: ArtworkType?

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    //the map view.
    @IBOutlet weak var map: MKMapView!
    //the location manager.
    var locationManager = CLLocationManager()
    //dictionary to link each annotation on the map to the building or artwork of building array.
    var annotationLog = [MKPointAnnotation: BuildingType]()
    
    //----------------------------------FUCTIONS OF THE CLASS----------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //add annotation on the map and map them to the buildings.
        for building in buildings {
            if building.artwork.count > 1 {   //if the building contains multiple artworks, respresent annotation as building.
                let coordinate = CLLocationCoordinate2D(latitude: Double(building.artwork[0].lat)!, longitude: Double(building.artwork[0].long)!)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = building.name
                annotationLog.updateValue(building, forKey: annotation)  //insert building based on the annotation key.
                self.map.addAnnotation(annotation)
            } else {   //if the building contains only one artwork, represent annotation as artwork.
                let coordinate = CLLocationCoordinate2D(latitude: Double(building.artwork[0].lat)!, longitude: Double(building.artwork[0].long)!)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = building.artwork[0].title
                annotationLog.updateValue(building, forKey: annotation)  //insert building based on the annotation key.
                self.map.addAnnotation(annotation)
            }
        }
    }
    
    /*--Fuction to update and show the user current location--*/
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        let region = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: true)
        self.map.showsUserLocation = true
    }
    
    /*--Fuction to respond when users tapping on annotations--*/
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKPointAnnotation {   //check the selected annotation is not user location pin.
            let annotation = view.annotation as! MKPointAnnotation
            let numberOfArtworks = (annotationLog[annotation]?.artwork.count)!
            
            if numberOfArtworks > 1 {   //if the annotation contains multi artworks, go to the list of artworks.
                //assign value of annotation to current building variable.
                currentBuilding = annotationLog[annotation]
                self.performSegue(withIdentifier: "to ArtGroup", sender: nil)
            } else {    //else go directly to the artwork details.
                //assign value of annotation to current artwork variable.
                currentArtwork = annotationLog[annotation]?.artwork[0]
                let artworkView = storyboard?.instantiateViewController(withIdentifier: "Artwork View") as! ArtworkViewController
                self.present(artworkView, animated: true, completion: nil)
            }
        }
    }
    
    /*--Fuction to create the view for header of each section in artwork table--*/
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.blue
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        headerLabel.textAlignment = NSTextAlignment.center
        headerLabel.textColor = UIColor.white
        headerLabel.text = buildings[section].name
        header.addSubview(headerLabel)
        return header
    }
    
    /*--Fuction to return the number of sections--*/
    func numberOfSections(in tableView: UITableView) -> Int {
        return buildings.count
    }
    
    /*--Fuction to return the number of rows in each section--*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildings[section].artwork.count
    }
    
    /*--Fuction to return the cell for each section--*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = buildings[indexPath.section].artwork[indexPath.row].title
        return cell
    }
    
    /*--Fuction to respond when users select the cell on table--*/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //assign the selected artwork to current artwork variable.
        currentArtwork = buildings[indexPath.section].artwork[indexPath.row]
        //go to the detail view of current artwork.
        let artworkView = storyboard?.instantiateViewController(withIdentifier: "Artwork View") as! ArtworkViewController
        self.present(artworkView, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
