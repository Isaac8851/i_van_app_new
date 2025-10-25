library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_school.dart';

part 'list_bus_stops_by_school.dart';

part 'assign_student_to_bus_stop.dart';

part 'list_users_by_role.dart';







class ExampleConnector {
  
  
  CreateSchoolVariablesBuilder createSchool ({required String name, required String address, }) {
    return CreateSchoolVariablesBuilder(dataConnect, name: name,address: address,);
  }
  
  
  ListBusStopsBySchoolVariablesBuilder listBusStopsBySchool ({required String schoolId, }) {
    return ListBusStopsBySchoolVariablesBuilder(dataConnect, schoolId: schoolId,);
  }
  
  
  AssignStudentToBusStopVariablesBuilder assignStudentToBusStop ({required String studentId, }) {
    return AssignStudentToBusStopVariablesBuilder(dataConnect, studentId: studentId,);
  }
  
  
  ListUsersByRoleVariablesBuilder listUsersByRole ({required String role, }) {
    return ListUsersByRoleVariablesBuilder(dataConnect, role: role,);
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'example',
    'ivanappnew',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}

