part of 'example.dart';

class ListUsersByRoleVariablesBuilder {
  String role;

  final FirebaseDataConnect _dataConnect;
  ListUsersByRoleVariablesBuilder(this._dataConnect, {required  this.role,});
  Deserializer<ListUsersByRoleData> dataDeserializer = (dynamic json)  => ListUsersByRoleData.fromJson(jsonDecode(json));
  Serializer<ListUsersByRoleVariables> varsSerializer = (ListUsersByRoleVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListUsersByRoleData, ListUsersByRoleVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListUsersByRoleData, ListUsersByRoleVariables> ref() {
    ListUsersByRoleVariables vars= ListUsersByRoleVariables(role: role,);
    return _dataConnect.query("ListUsersByRole", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListUsersByRoleUsers {
  final String id;
  final String displayName;
  final String? email;
  ListUsersByRoleUsers.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  displayName = nativeFromJson<String>(json['displayName']),
  email = json['email'] == null ? null : nativeFromJson<String>(json['email']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUsersByRoleUsers otherTyped = other as ListUsersByRoleUsers;
    return id == otherTyped.id && 
    displayName == otherTyped.displayName && 
    email == otherTyped.email;
    
  }
  @override
  int get hashCode => Object.hash(id.hashCode, displayName.hashCode, email.hashCode);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['displayName'] = nativeToJson<String>(displayName);
    if (email != null) {
      json['email'] = nativeToJson<String?>(email);
    }
    return json;
  }

  ListUsersByRoleUsers({
    required this.id,
    required this.displayName,
    this.email,
  });
}

@immutable
class ListUsersByRoleData {
  final List<ListUsersByRoleUsers> users;
  ListUsersByRoleData.fromJson(dynamic json):
  
  users = (json['users'] as List<dynamic>)
        .map((e) => ListUsersByRoleUsers.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUsersByRoleData otherTyped = other as ListUsersByRoleData;
    return users == otherTyped.users;
    
  }
  @override
  int get hashCode => users.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['users'] = users.map((e) => e.toJson()).toList();
    return json;
  }

  ListUsersByRoleData({
    required this.users,
  });
}

@immutable
class ListUsersByRoleVariables {
  final String role;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListUsersByRoleVariables.fromJson(Map<String, dynamic> json):
  
  role = nativeFromJson<String>(json['role']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListUsersByRoleVariables otherTyped = other as ListUsersByRoleVariables;
    return role == otherTyped.role;
    
  }
  @override
  int get hashCode => role.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['role'] = nativeToJson<String>(role);
    return json;
  }

  ListUsersByRoleVariables({
    required this.role,
  });
}

