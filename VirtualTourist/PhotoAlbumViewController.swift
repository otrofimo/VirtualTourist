//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Oleg Trofimov on 12/18/15.
//  Copyright © 2015 Oleg Trofimov. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    let reuseIdentifier = "PhotoCollectionCell"

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var okButton: UIBarButtonItem!

    var pin : Pin!
    var page = 0
    var annotation : MKPointAnnotation!

    // For FetchedResultsController to perform batch updates
    var insertedIndexPaths : [NSIndexPath]!
    var deletedIndexPaths : [NSIndexPath]!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self

        // Setup map
        annotation = pin.toMKPointAnnotation()
        mapView.addAnnotation(annotation)

        // Set region of map
        let region = MKCoordinateRegionMakeWithDistance(
            annotation.coordinate, 2000, 2000)
        mapView.setRegion(region, animated: true)

        do {
            try fetchedResultsController.performFetch()
        } catch {}

        fetchedResultsController.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        if pin.photos.isEmpty {
            statusLabel.hidden = false
            newCollectionButton.enabled = false
            self.activityIndicator.startAnimating()
            fetchAllPhotos()
        }
    }

    @IBAction func okButtonPressed(sender: UIBarButtonItem) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionCell

        // This is where the cell configuration happens -> make it its own method, inside make a call to get image (taskForImageWithSize)
        configureCell(cell, withPhoto: photo)

        return cell
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        print("total objects fetched: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }

    lazy var fetchedResultsController : NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "Photo")

        // Breaks when pin is empty ... :/
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format:"pin == %@", self.pin)

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        return fetchedResultsController
    }()

    // MARK: - Core Data Convenience

    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()

    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }

    func configureCell(cell: PhotoCollectionCell, withPhoto photo: Photo) {

        if let localImage = photo.image {
            cell.imageView.image = localImage
        } else if photo.imagePath == "" {
            cell.imageView.image = UIImage(named: "photoNoImage")
        }

        // Download image from Flickr
        else {
            cell.imageView.image = UIImage(named: "photoPlaceholder")

            Flickr.sharedInstance().taskforImageFromPhoto(photo) { (imageData, error) in
                if let data = imageData {
                    dispatch_async(dispatch_get_main_queue()) {
                        let image = UIImage(data: data)
                        photo.image = image
                        cell.imageView.image = image
                    }
                }
            }
        }
    }

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {

        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")

        collectionView.performBatchUpdates({() -> Void in

            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }

            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert :
            self.insertedIndexPaths.append(newIndexPath!)
        case .Delete :
            self.deletedIndexPaths.append(indexPath!)
        default :
            return
        }
    }

    // MARK: New Collection Button Pressed

    @IBAction func fetchNewCollection(sender: UIButton) {
        // Clear all photos
        deleteAllPhotos {
            dispatch_async(dispatch_get_main_queue()) {
                self.statusLabel.hidden = false
                self.newCollectionButton.enabled = false
                self.activityIndicator.startAnimating()
                self.fetchAllPhotos()
            }
        }
    }

    func deleteAllPhotos(completionHandler: ()-> Void) {
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            self.sharedContext.deleteObject(photo)
        }
        completionHandler()
    }

    func fetchAllPhotos() {
        Flickr.sharedInstance().getPhotos(page, latitude: pin.latitude, longitude: pin.longitude) { JSONResult, error in
            if error != nil {
                // Show error message over collection view
                dispatch_async(dispatch_get_main_queue()) {
                    self.statusLabel.text = "Did not find any images :?"
                    self.activityIndicator.stopAnimating()
                }
                print(error)
                return
            }

            print("Results fetched")

            if let photosResultDict = JSONResult.valueForKey(Flickr.Keys.Photos) as? [String : AnyObject] {

                print("ok cool we found the photos")

                self.page = photosResultDict["page"] as! Int

                // create parse array of photos
                if let photoDict = photosResultDict[Flickr.Keys.Photo] as? [[String : AnyObject]] {

                    dispatch_async(dispatch_get_main_queue()) {

                        let _ = photoDict.map { (dictionary : [String : AnyObject]) -> Photo in

                            // Looks like I need to do this on the main queue?
                            let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                            // set pin for photo
                            photo.pin = self.pin

                            return photo
                        }

                        // save context
                        print("Saving context")
                        self.saveContext()

                        print("reloading collection")
                        self.statusLabel.hidden = true
                        self.activityIndicator.stopAnimating()
                        self.newCollectionButton.enabled = true
                        self.collectionView.reloadData()
                    }

                } else {
                    let error = NSError(domain: "Photos for Pin. Cant find pin in \(JSONResult)", code: 0, userInfo: nil)
                    print(error)
                }
            }
        }
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photoToDelete = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        photoToDelete.pin = nil
    }

    // Layout the collection view

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Lay out the collection view so that cells take up 1/3 of the width,
        // with no space in between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let width = floor(self.collectionView.bounds.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }

}

