part of 'example.dart';

class ListBusStopsBySchoolVariablesBuilder {
  String schoolId;

  final FirebaseDataConnect _dataConnect;
  ListBusStopsBySchoolVariablesBuilder(this._dataConnect, {required  this.schoolId,});
  Deserializer<ListBusStopsBySchoolData> dataDeserializer = (dynamic json)  => ListBusStopsBySchoolData.fromJson(jsonDecode(json));
  Serializer<ListBusStopsBySchoolVariables> varsSerializer = (ListBusStopsBySchoolVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListBusStopsBySchoolData, ListBusStopsBySchoolVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListBusStopsBySchoolData, ListBusStopsBySchoolVariables> ref() {
    ListBusStopsBySchoolVariables vars= ListBusStopsBySchoolVariables(schoolId: schoolId,);
    return _dataConnect.query("ListBusStopsBySchool", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListBusStopsBySchoolBusStops {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  ListBusStopsBySchoolBusStops.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']),
  latitude = nativeFromJson<double>(json['latitude']),
  longitude = nativeFromJson<double>(json['longitude']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListBusStopsBySchoolBusStops otherTyped = other as ListBusStopsBySchoolBusStops;
    return id == otherTyped.id && 
    name == otherTyped.name && 
    latitude == otherTyped.latitude && 
    longitude == otherTyped.longitude;
    
  }
  @override
  int get hashCode => Object.hash(id.hashCode, name.hashCode, latitude.hashCode, longitude.hashCode);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    json['latitude'] = nativeToJson<double>(latitude);
    json['longitude'] = nativeToJson<double>(longitude);
    return json;
  }

  ListBusStopsBySchoolBusStops({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

@immutable
class ListBusStopsBySchoolData {
  final List<ListBusStopsBySchoolBusStops> busStops;
  ListBusStopsBySchoolData.fromJson(dynamic json):
  
  busStops = (json['busStops'] as List<dynamic>)
        .map((e) => ListBusStopsBySchoolBusStops.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListBusStopsBySchoolData otherTyped = other as ListBusStopsBySchoolData;
    return busStops == otherTyped.busStops;
    
  }
  @override
  int get hashCode => busStops.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['busStops'] = busStops.map((e) => e.toJson()).toList();
    return json;
  }

  ListBusStopsBySchoolData({
    required this.busStops,
  });
}

@immutable
class ListBusStopsBySchoolVariables {
  final String schoolId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListBusStopsBySchoolVariables.fromJson(Map<String, dynamic> json):
  
  schoolId = nativeFromJson<String>(json['schoolId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListBusStopsBySchoolVariables otherTyped = other as ListBusStopsBySchoolVariables;
    return schoolId == otherTyped.schoolId;
    
  }
  @override
  int get hashCode => schoolId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['schoolId'] = nativeToJson<String>(schoolId);
    return json;
  }

  ListBusStopsBySchoolVariables({
    required this.schoolId,
  });
}

