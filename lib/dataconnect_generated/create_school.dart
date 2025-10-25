part of 'example.dart';

class CreateSchoolVariablesBuilder {
  String name;
  String address;

  final FirebaseDataConnect _dataConnect;
  CreateSchoolVariablesBuilder(this._dataConnect, {required  this.name,required  this.address,});
  Deserializer<CreateSchoolData> dataDeserializer = (dynamic json)  => CreateSchoolData.fromJson(jsonDecode(json));
  Serializer<CreateSchoolVariables> varsSerializer = (CreateSchoolVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateSchoolData, CreateSchoolVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateSchoolData, CreateSchoolVariables> ref() {
    CreateSchoolVariables vars= CreateSchoolVariables(name: name,address: address,);
    return _dataConnect.mutation("CreateSchool", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateSchoolSchoolInsert {
  final String id;
  CreateSchoolSchoolInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateSchoolSchoolInsert otherTyped = other as CreateSchoolSchoolInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateSchoolSchoolInsert({
    required this.id,
  });
}

@immutable
class CreateSchoolData {
  final CreateSchoolSchoolInsert school_insert;
  CreateSchoolData.fromJson(dynamic json):
  
  school_insert = CreateSchoolSchoolInsert.fromJson(json['school_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateSchoolData otherTyped = other as CreateSchoolData;
    return school_insert == otherTyped.school_insert;
    
  }
  @override
  int get hashCode => school_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['school_insert'] = school_insert.toJson();
    return json;
  }

  CreateSchoolData({
    required this.school_insert,
  });
}

@immutable
class CreateSchoolVariables {
  final String name;
  final String address;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateSchoolVariables.fromJson(Map<String, dynamic> json):
  
  name = nativeFromJson<String>(json['name']),
  address = nativeFromJson<String>(json['address']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateSchoolVariables otherTyped = other as CreateSchoolVariables;
    return name == otherTyped.name && 
    address == otherTyped.address;
    
  }
  @override
  int get hashCode => Object.hash(name.hashCode, address.hashCode);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    json['address'] = nativeToJson<String>(address);
    return json;
  }

  CreateSchoolVariables({
    required this.name,
    required this.address,
  });
}

