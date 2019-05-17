//
//  ViewController.swift
//  Path
//
//  Created by Leshya Bracaglia on 4/10/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//


//APP SHOULD BE LIMITED TO JUST THE STATE OF NEW YORK
import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate{
    
    //This is our map
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    private let dataProvider = GoogleDataProvider()
    private let searchRadius: Double = 1000
    var geocoder = CLGeocoder()
    var loc1: CLLocationCoordinate2D = (CLLocationCoordinate2DMake(0, 0));
    var loc2: CLLocationCoordinate2D = (CLLocationCoordinate2DMake(0, 0));
    
    
    //This is the cafe button/items
    @IBOutlet weak var cafe: UIView!
    @IBOutlet weak var cafeImage: UIImageView!
    @IBOutlet weak var cafeText: UILabel!
    
    //This is the culture button/items
    @IBOutlet weak var culture: UIView!
    @IBOutlet weak var beerImage: UIImageView!
    @IBOutlet weak var cultureText: UILabel!
    
    //This is the restaurant button/items
    @IBOutlet weak var restaurant: UIView!
    @IBOutlet weak var restaurantText: UILabel!
    @IBOutlet weak var forkImage: UIImageView!
    
    //The start and end text fields, go button
    @IBOutlet weak var endField: UITextField!
    @IBOutlet weak var startField: UITextField!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var viewResultsButton: UIButton!
    
    let group = DispatchGroup()
    
    //Our orange color
    var myorange = UIColor(red: 249.0/255.0, green: 156.0/255.0, blue: 8.0/255.0, alpha: 1.0)
    
    //our dark grey color
    var mygrey = UIColor(red: 58.0/255.0, green: 58.0/255.0, blue: 60.0/255.0, alpha: 1.0)
    
    var currentSearchType = "restaurant"
    
    var searchResults : [GooglePlace] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //This is all style***************************
        cafe.layer.borderColor = UIColor.black.cgColor;
        cafe.layer.borderWidth = 2;
        culture.layer.borderColor = UIColor.black.cgColor;
        culture.layer.borderWidth = 2;
        
        topView.layer.shadowColor = UIColor.black.cgColor
        topView.layer.shadowOpacity = 0.25
        topView.layer.shadowOffset = CGSize(width: 0, height: 5)
        topView.layer.shadowRadius = 4
        
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOpacity = 0.25
        bottomView.layer.shadowOffset = CGSize(width: 0, height: -5)
        bottomView.layer.shadowRadius = 4
        
        startField.placeholder = "Current Location"
        startField.layer.borderColor = mygrey.cgColor
        startField.layer.cornerRadius = 5.0
        startField.layer.borderWidth = 2
        endField.placeholder = "Where are you going?"
        endField.layer.borderColor = mygrey.cgColor
        endField.layer.cornerRadius = 5.0
        endField.layer.borderWidth = 2
        //**********************************************
        
        //For map
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()

        //Allows the user to dismis the keyboard when hitting return
        self.startField.delegate = self;
        self.endField.delegate = self;
        
        viewResultsButton.isHidden = true;
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //Perform the google place search when the user hits GO button
    @IBAction func onGo(_ sender: Any) {
        performSearch()
    }
    
    func performSearch() {
        mapView.clear()
        
        // Completion handler to build the location object once there is valid coordinate data
        let geocodeHandlerFactory : (_ completionHandler: @escaping (CLLocationCoordinate2D?, Error?) -> Void) -> CLGeocodeCompletionHandler = { completionHandler in
            let geocodeHandler : CLGeocodeCompletionHandler = { placemarks, geocodeError in
                guard let placemark = placemarks?.first else {
                    completionHandler(nil, geocodeError)
                    return
                }
                let lat = placemark.location!.coordinate.latitude
                let lon = placemark.location!.coordinate.longitude
                let newCoord = CLLocationCoordinate2DMake(lat, lon)
                completionHandler(newCoord, geocodeError)
            }
            return geocodeHandler
        }
        
        let startingAddress = startField.text!
        let endingAddress = endField.text!
        
       //dispatch so each geocording of addresses and then drawing of route are scheduled in order
        DispatchQueue.global().async {
            let dispatchGroup = DispatchGroup()
            var startLocationSearchError : Error?
            var endLocationSearchError : Error?
            let geocoder = CLGeocoder()
            
            //Geocode start address, then pass it through the completion handler to build the object, and return it
            dispatchGroup.enter()
            geocoder.geocodeAddressString(startingAddress, completionHandler: geocodeHandlerFactory() { coord, error in
                defer { dispatchGroup.leave() }
                if error != nil {
                    startLocationSearchError = error
                    print("ERROR: could not find starting location: \(error!)")
                    return
                }
                guard let coord = coord else {
                    print("ERROR: no coordinate data for starting location")
                    return
                    
                }
                
                self.loc1 = coord
            })
            dispatchGroup.wait()
            
            //Geocode the end address, pass to the handler, and pass back
            dispatchGroup.enter()
            geocoder.geocodeAddressString(endingAddress, completionHandler: geocodeHandlerFactory() { coord, error in
                defer { dispatchGroup.leave() }
                if error != nil {
                    endLocationSearchError = error
                    print("ERROR: could not find ending location: \(error!)")
                    return
                }
                guard let coord = coord else {
                    print("ERROR: no coordinate data for ending location")
                    return
                    
                }
                
                self.loc2 = coord
            })
            dispatchGroup.wait()
            
            //We now have both coordinates, and can print the route and show results
            dispatchGroup.notify(queue: .main) {
                if startLocationSearchError != nil || endLocationSearchError != nil {
                    print("ERROR: unable to find one or both of the locations")
                }
                else {
                    print("FOUND IT!")
                    //Move the camera to search location
                    let camera = GMSCameraPosition.camera(withLatitude: self.loc1.latitude, longitude: self.loc1.longitude, zoom: 14)
                    self.mapView?.camera = camera
                    self.mapView?.animate(to: camera)
                    //Draw the route and display places
                    self.fetchRoute(from: self.loc1, to: self.loc2)
                }
            }
        }
    }//End of performSearch function
    
    /*When you click button, changes color themes*/
    @IBAction func onCulture(_ sender: Any) {
        //change culture colors to be clicked
        cultureOn();
        //change cafe colors to be unclicked
        cafeOff();
        //change restaurant colors to be unclicked
        restaurantOff()
        
        performSearch()
    }
    
    @IBAction func onCafe(_ sender: Any) {
        //Change culture to be unclicked
        cultureOff();
        //Change cafe to be clicked
        cafeOn();
        //Change restaurant to be unclicked
        restaurantOff();
        
        performSearch()
    }
    
    
    @IBAction func onRestaurant(_ sender: Any) {
        //Change culture to be unclicked
        cultureOff();
        //Change cafe to be unclicked
        cafeOff();
        //Change restaurant to be clicked
        restaurantOn();
        
        performSearch()
    }
    
    func cultureOn(){
        currentSearchType = "bar"
        culture.layer.backgroundColor = myorange.cgColor;
        beerImage.image = UIImage(named: "beer");
        culture.layer.borderColor = myorange.cgColor;
        culture.layer.borderWidth = 0;
        cultureText.textColor = UIColor.black;
    }
    
    func cultureOff(){
        culture.layer.backgroundColor = mygrey.cgColor;
        beerImage.image = UIImage(named: "beer-orange");
        culture.layer.borderColor = UIColor.black.cgColor;
        culture.layer.borderWidth = 2;
        cultureText.textColor = myorange;
    }
    
    func restaurantOn(){
        currentSearchType = "restaurant"
        restaurant.layer.backgroundColor = myorange.cgColor;
        forkImage.image = UIImage(named: "fork");
        restaurant.layer.borderColor = myorange.cgColor;
        restaurant.layer.borderWidth = 0;
        restaurantText.textColor = UIColor.black;
    }
    
    func restaurantOff(){
        restaurant.layer.backgroundColor = mygrey.cgColor;
        forkImage.image = UIImage(named: "fork-orange");
        restaurant.layer.borderColor = UIColor.black.cgColor;
        restaurant.layer.borderWidth = 2;
        restaurantText.textColor = myorange;
    }
    
    func cafeOn(){
        currentSearchType = "cafe"
        cafe.layer.backgroundColor = myorange.cgColor;
        cafeImage.image = UIImage(named: "coffee-cup");
        cafe.layer.borderColor = myorange.cgColor;
        cafe.layer.borderWidth = 0;
        cafeText.textColor = UIColor.black;
    }
    
    func cafeOff(){
        cafe.layer.backgroundColor = mygrey.cgColor;
        cafeImage.image = UIImage(named: "coffee-cup-orange");
        cafe.layer.borderColor = UIColor.black.cgColor;
        cafe.layer.borderWidth = 2;
        cafeText.textColor = myorange;
    }
    
    //This functions resigns the keyboard when return is clicked
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
    
    //Address to CLLocationCoordinate2D object
    func getLocation(from address: String, completion: @escaping (_ location:
        CLLocationCoordinate2D?)-> Void) {
        NSLog("yellow")
        NSLog(address)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks,
                let location = placemarks.first?.location?.coordinate else {
                    return
            }
            completion(location)
        }
    }
    
    //Gets Route
    func fetchRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let session = URLSession.shared
        //WALKING
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(GoogleKey)"
        
        let url = URL(string: urlString)!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("ERROR: data was nil")
                return
            }
            
            guard let json = try? JSON(data: data) else {
                print("ERROR: could not parse JSON")
                return
            }
            
            guard let polyLineString = json["routes"][0]["overview_polyline"]["points"].string else {
                print("ERROR: missing polyline information")
                return
            }
            
            
            //After we have route data from google, dispatch
            DispatchQueue.main.async {
                if let path = GMSPath(fromEncodedPath: polyLineString) {
                    //Array that will be filled with points along route
                    var locations : [CLLocation] = []
                    for i in 0...path.count() - 1 {
                        let coordinate = path.coordinate(at: i)
                        
                        locations.append(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
                    }
                    //Call this method to find and display the nearby business and draw the path
                    self.findNearbyPlaces(for: locations)
                    self.drawPath(from: path)
                }

            }
            
        })
        task.resume()
    }
    
    //Draws path on map... Used in the fetchRoute method.
    func drawPath(from path: GMSPath) {
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 10.0
        polyline.strokeColor = myorange
        polyline.map = mapView // Google MapView
    }
    
    //Turns coordinates into a google place
    func findNearbyPlaces(for locations: [CLLocation]) {
        //We don't need ever coordinate, so we skip some
        if locations.count > 2 {
            var searchLocations : [CLLocation] = []
            var currentReferenceLocation = locations.first!
            searchLocations.append(currentReferenceLocation)
            for i in 1...locations.count - 1 {
                let candidate = locations[i]
                let distance = candidate.distance(from: currentReferenceLocation)
                //Filters which coordinates we want by our constant DistanceFilter.  This constant is a tradeoff, if we lower it we will be able to return more businesses, but greatly increase our API calls
                if distance > DistanceFilter || candidate == locations.last! {
                    print("Difference of ==> \(candidate.distance(from: currentReferenceLocation)) meters")
                    
                    //Filteres array of coordinates
                    searchLocations.append(candidate)
                    currentReferenceLocation = candidate
                }
            }
            
            print("locations = \(locations.count), searchLocations = \(searchLocations.count)")
            
            DispatchQueue.global().async {
                let dispatchGroup  = DispatchGroup()
                self.searchResults.removeAll()
                var uniquePlaces = Set<String>()
                for location in searchLocations {
                    dispatchGroup.enter()
                    //Use the GoogleDataProvider class to search a radius around each coordinate from the path
                    self.dataProvider.fetchPlacesNearCoordinate(location.coordinate, radius: DistanceFilter, type: self.currentSearchType) { places in
                        places.forEach {
                            // Ignore places that have already been added
                            if !uniquePlaces.contains($0.placeId) {
                                self.searchResults.append($0)
                                // Create and place marker for each unique place
                                uniquePlaces.insert($0.placeId)
                                let marker = PlaceMarker(place: $0)
                                marker.title = $0.name
                                marker.snippet = $0.address
                                marker.map = self.mapView
                            }
                        }
                        dispatchGroup.leave()
                    }
                    dispatchGroup.wait()
                }
                DispatchQueue.main.async {
                    //Show the view table view results button
                    self.viewResultsButton.isHidden = false
                }
            }
        }
    }//End of class
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchResultsSegue" {
            let resultController = segue.destination as! SearchResultsController
            resultController.searchResults = self.searchResults
        }
    }
    
}
//end of class


//Extends our main view controller as a CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    //If the location changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //Make sure we have permission for location
        guard status == .authorizedWhenInUse else {
            NSLog("Path needs permission to access your location")
            return
        }
        //If we have permission, start using location
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    //This function moves the camera view with the user as they move locations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
    }
}



