MagicalMapper
=============

I started this library hoping that Swift would eventually support reflection wehich would lead to some really cool features, but that hasn't happened yet.

Until then you can use the objective c version I've written that supports both NSObjects and NSManagedObjects https://github.com/aryaxt/OCMapper

MagicalMapper is a mapping library that takes a dictionary of key/values and maps them to Core Data managed objects.


Let's take a look at an example. Below is how our core data models are defined

![alt tag](https://github.com/aryaxt/MagicalMapper/blob/master/modesl.png)

```swift
class User: NSManagedObject {

    @NSManaged var id: NSNumbe
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var age: NSNumber
    @NSManaged var address: Address
    @NSManaged var createdAt: NSDate
    @NSManaged var posts: NSSet
}

class Address: NSManagedObject {

    @NSManaged var id: NSNumbe
    @NSManaged var city: String
    @NSManaged var country: String
    @NSManaged var user: NSSet

}

class Post : NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var body: String
    
}
```
We make an http call that returns the following data
```json
{
  "id"          : 1,
  "firstName"   : "Aryan",
  "lastName"    : "Ghassemi",
  "age"         : 27,
  "createdAt"   : "2014-08-31",
  "address"     : {
                    "id"      : 1,
                    "city"    : "San Francisco",
                    "country" : "United States"
                  },
  "posts"       : [
                    {
                      "id"    : 2,
                      "title" : "Some title",
                      "body"  : "Some body"
                    },
                    {
                      "id"    : 3,
                      "title" : "Some title",
                      "body"  : "Some body"
                    }
                  ]
  
}
```
Usage
---------
Now let's use MagicalMapper to convert this result into our models
```swift
var user = mapper.mapDictionary(userDictionary, toType: User.self)
```

It's really that simple. MagicalMapper uses entity information to automatically generate managed objects and all associated relationships for you.

What if the server response includes an array of users? Still as simple as getting a single object
```swift
var arrayOfUsers = mapper.mapDictionaries(arrayOfUserDictionaries, toType: User.self)
```

Custom Mapping
---------
What if the key values comeing back from the server don't match our models? Well we can write custom mapping. let's say the server sends the key "location" instead of "address".
```Swift
mapper[User.self] = [
    "location"      : "address",
    "ANOTHER_KEY"   : "ANOTHER_PROPERTY"
    ]
```

The great thing is just because a single key in the dictionary is different from our model proprty name, it doesn't mean that we need to provide full mapping for the class. We only provide mapping where it's needed.

Date Conversion
---------
MagicalMapper uses a list of default date formatters to automatically map NSDate properties. Here is the list of date formats in the order they are used for conversion
```
yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ
yyyy-MM-dd'T'HH:mm:ss'Z'
MM/dd/yyyy HH:mm:ss aaa
yyyy-MM-dd HH:mm:ss
MM/dd/yyyy
yyyy-MM-dd
```

You could also add your own NSDateFormatter if you need. If your application uses a consistant date format it'll perform better to add the date formatter to the mapper. Any NSDateFormatter added goes to index 0 and mapper starts with that formatter for dateconversion which helps with performance.
```swift
var dateFormatter = NSDateFormatter()
dateFormatter.dateFormat = "MY_DATE_FORMAT"
mapper.addDateFormatter(dateFormatter)
```

Insert & Update
---------

What if we don't want to add a duplicate record everything mapping is performed? Well there is a solution for that too.
```Swift
mapper.addUniqueIdentifiersForEntity(User.self, identifiers: "id")
mapper.addUniqueIdentifiersForEntity(Address.self, identifiers: "id")
mapper.addUniqueIdentifiersForEntity(Post.self, identifiers: "id", "ANOTHER_KEY")
```
You can pass an array of property names to uniquely identify each record, and MagicalMapper uses these keys to decide whether it should insert a new record or update an existing record. Supperted property types to be used as unique identifiers are Stirng, Int, NSDate.


