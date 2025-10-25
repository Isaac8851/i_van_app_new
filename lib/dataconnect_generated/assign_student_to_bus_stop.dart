part of 'example.dart';

class AssignStudentToBusStopVariablesBuilder {
  String studentId;
  Optional<String> _busStopId = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  AssignStudentToBusStopVariablesBuilder busStopId(String? t) {
   _busStopId.value = t;
   return this;
  }

  AssignStudentToBusStopVariablesBuilder(this._dataConnect, {required  this.studentId,});
  Deserializer<AssignStudentToBusStopData> dataDeserializer = (dynamic json)  => AssignStudentToBusStopData.fromJson(jsonDecode(json));
  Serializer<AssignStudentToBusStopVariables> varsSerializer = (AssignStudentToBusStopVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AssignStudentToBusStopData, AssignStudentToBusStopVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AssignStudentToBusStopData, AssignStudentToBusStopVariables> ref() {
    AssignStudentToBusStopVariables vars= AssignStudentToBusStopVariables(studentId: studentId,busStopId: _busStopId,);
    return _dataConnect.mutation("AssignStudentToBusStop", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AssignStudentToBusStopStudentUpdate {
  final String id;
  AssignStudentToBusStopStudentUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AssignStudentToBusStopStudentUpdate otherTyped = other as AssignStudentToBusStopStudentUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AssignStudentToBusStopStudentUpdate({
    required this.id,
  });
}

@immutable
class AssignStudentToBusStopData {
  final AssignStudentToBusStopStudentUpdate? student_update;
  AssignStudentToBusStopData.fromJson(dynamic json):
  
  student_update = json['student_update'] == null ? null : AssignStudentToBusStopStudentUpdate.fromJson(json['student_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AssignStudentToBusStopData otherTyped = other as AssignStudentToBusStopData;
    return student_update == otherTyped.student_update;
    
  }
  @override
  int get hashCode => student_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (student_update != null) {
      json['student_update'] = student_update!.toJson();
    }
    return json;
  }

  AssignStudentToBusStopData({
    this.student_update,
  });
}

@immutable
class AssignStudentToBusStopVariables {
  final String studentId;
  late final Optional<String>busStopId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AssignStudentToBusStopVariables.fromJson(Map<String, dynamic> json):
  
  studentId = nativeFromJson<String>(json['studentId']) {
  
  
  
    busStopId = Optional.optional(nativeFromJson, nativeToJson);
    busStopId.value = json['busStopId'] == null ? null : nativeFromJson<String>(json['busStopId']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AssignStudentToBusStopVariables otherTyped = other as AssignStudentToBusStopVariables;
    return studentId == otherTyped.studentId && 
    busStopId == otherTyped.busStopId;
    
  }
  @override
  int get hashCode => Object.hash(studentId.hashCode, busStopId.hashCode);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['studentId'] = nativeToJson<String>(studentId);
    if(busStopId.state == OptionalState.set) {
      json['busStopId'] = busStopId.toJson();
    }
    return json;
  }

  AssignStudentToBusStopVariables({
    required this.studentId,
    required this.busStopId,
  });
}

