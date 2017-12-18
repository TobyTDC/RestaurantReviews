//
//  YelpSearchController.swift
//  RestaurantReviews
//
//  Created by Pasan Premaratne on 5/9/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import UIKit
import MapKit

class YelpSearchController: UIViewController {
    
    // MARK: - Properties
    
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    let dataSource = YelpSearchResultsDataSource()
    
    lazy var locationManager: LocationManager = {
        return LocationManager(delegate: self, permissionsDelegate: nil)
    }()
    
    lazy var client: YelpClient = {
        let yelpAccount = YelpAccount.loadFromKeyChain()
        let oauthToken = yelpAccount!.accessToken
        
        return YelpClient(oauthToken: oauthToken)
    }()
    
    var coordinate: Coordinate? {
        didSet {
            if let coordinate = coordinate {
                showNearByRestaurants(at: coordinate)
            }
        }
    }
    
    let queue = OperationQueue()
    
    var isAuthorized: Bool {
        let isAuthorizedWithYelpToken = YelpAccount.isAuthorized
        let isAuthorizedForLocation = LocationManager.isAuthorized
        
        return isAuthorizedForLocation && isAuthorizedWithYelpToken
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isAuthorized {
            locationManager.requestLocation()
        } else {
            checkPermissions()
        }
    }
    
    // MARK: - Table View
    func setupTableView() {
        self.tableView.dataSource = dataSource
        self.tableView.delegate = self
        
        addObserver(self, forKeyPath: #keyPath(YelpBusinessDetailOperation.isFinished), options: [.new, .old], context: nil)
    }
    
    func showNearByRestaurants(at coordinate: Coordinate) {
        client.search(withTerm: "", at: coordinate) {
            [weak self] result in
            switch result {
            case .success(let businesses): self?.dataSource.update(with: businesses)
                self?.tableView.reloadData()
                self?.mapView.addAnnotations(businesses)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    // MARK: - Search
    
    func setupSearchBar() {
        self.navigationItem.titleView = searchController.searchBar
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
    }
    
    // MARK: - Permissions
    
    /// Checks (1) if the user is authenticated against the Yelp API and has an OAuth
    /// token and (2) if the user has authorized location access for whenInUse tracking.
    func checkPermissions() {
        let isAuthorizedForLocation = LocationManager.isAuthorized
        let isAuthorizedWithToken = YelpAccount.isAuthorized
        
        let permissionsController = PermissionsController(isAuthorizedForLocation: isAuthorizedForLocation, isAuthorizedWithToken: isAuthorizedWithToken)
        present(permissionsController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension YelpSearchController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let business = dataSource.object(at: indexPath)
        let detailsOperation = YelpBusinessDetailOperation(business: business, client: self.client)
        let reviewsOperation = YelpBusinessReviewsOperation(business: business, client: client)
        reviewsOperation.addDependency(detailsOperation)
        
        reviewsOperation.completionBlock = {
            DispatchQueue.main.async {
                self.dataSource.update(business, at: indexPath)
                self.performSegue(withIdentifier: "showBusiness", sender: nil)
            }
        }
        
        queue.addOperation(detailsOperation)
        queue.addOperation(reviewsOperation)
    }
}

// MARK: - Search Results
extension YelpSearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchTerm = searchController.searchBar.text, let coordinate = coordinate else { return }
        
        if !searchTerm.isEmpty {
            client.search(withTerm: searchTerm, at: coordinate) {
                [weak self] result in
                switch result {
                case .success(let businesses): self?.dataSource.update(with: businesses)
                    self?.tableView.reloadData()
                    
                    self?.mapView.removeAnnotations(self!.mapView.annotations)
                    self?.mapView.addAnnotations(businesses)
                case .failure(let error):
                    print(error)
                }
            }
        }
        print("Search text: \(searchTerm)")
    }
}

// MARK: - Navigation
extension YelpSearchController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBusiness" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let business = dataSource.object(at: indexPath)
                let detailController = segue.destination as!
                YelpBusinessDetailController
                detailController.business = business
                detailController.dataSource.updateData(business.reviews)
            }
        }
    }
}

//Mark: --- LOcation Manager Delegate

extension YelpSearchController: LocationManagerDelegate {
    func obtainedCoordinates(_ coordinate: Coordinate) {
        self.coordinate = coordinate
        adjustMap(with: coordinate)
    }
    
    func failedWithError(_ error: LocationError) {
        print(error)
    }
}

extension YelpSearchController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
    }
}

//MARK: -- MapKit

extension YelpSearchController {
    func adjustMap(with coordinate: Coordinate) {
        let coordinate2D = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let span = MKCoordinateRegionMakeWithDistance(coordinate2D, 2500, 2500).span
        let region = MKCoordinateRegionMake(coordinate2D, span)
        mapView.setRegion(region, animated: true)
    }
}












