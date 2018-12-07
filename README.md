# photo-viewer
The application should download and parse the JSON found at this URL: http:// jsonplaceholder.typicode.com/photos

Displays the images found at the thumbnail key for each node in the JSON, in either a UITableView or UICollectionView.

When tapped, display the image found at the url key in a detail view for each item in the UITableView or UICollectionView.

App Transport Security is disabled to load 'HTTP' URL
Project namespace is used as 'NTS'
Few reusable components are added like, 'NTSCachable', 'Two-way Binding', 'NTSReachability' classes
Images are cached if already downloaded
Unit test cases added for Photo list API
For visuals, a storyboard is used
Swift version used: 4.2.1
Minimum iOS version supported: iOS 11.0
