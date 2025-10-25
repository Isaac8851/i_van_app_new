# dataconnect_generated SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
ExampleConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### ListBusStopsBySchool
#### Required Arguments
```dart
String schoolId = ...;
ExampleConnector.instance.listBusStopsBySchool(
  schoolId: schoolId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListBusStopsBySchoolData, ListBusStopsBySchoolVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listBusStopsBySchool(
  schoolId: schoolId,
);
ListBusStopsBySchoolData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String schoolId = ...;

final ref = ExampleConnector.instance.listBusStopsBySchool(
  schoolId: schoolId,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListUsersByRole
#### Required Arguments
```dart
String role = ...;
ExampleConnector.instance.listUsersByRole(
  role: role,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListUsersByRoleData, ListUsersByRoleVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listUsersByRole(
  role: role,
);
ListUsersByRoleData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String role = ...;

final ref = ExampleConnector.instance.listUsersByRole(
  role: role,
).ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### CreateSchool
#### Required Arguments
```dart
String name = ...;
String address = ...;
ExampleConnector.instance.createSchool(
  name: name,
  address: address,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<CreateSchoolData, CreateSchoolVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createSchool(
  name: name,
  address: address,
);
CreateSchoolData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String name = ...;
String address = ...;

final ref = ExampleConnector.instance.createSchool(
  name: name,
  address: address,
).ref();
ref.execute();
```


### AssignStudentToBusStop
#### Required Arguments
```dart
String studentId = ...;
ExampleConnector.instance.assignStudentToBusStop(
  studentId: studentId,
).execute();
```

#### Optional Arguments
We return a builder for each query. For AssignStudentToBusStop, we created `AssignStudentToBusStopBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class AssignStudentToBusStopVariablesBuilder {
  ...
   AssignStudentToBusStopVariablesBuilder busStopId(String? t) {
   _busStopId.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.assignStudentToBusStop(
  studentId: studentId,
)
.busStopId(busStopId)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<AssignStudentToBusStopData, AssignStudentToBusStopVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.assignStudentToBusStop(
  studentId: studentId,
);
AssignStudentToBusStopData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String studentId = ...;

final ref = ExampleConnector.instance.assignStudentToBusStop(
  studentId: studentId,
).ref();
ref.execute();
```

