// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/sql;
import ballerina/test;
import ballerina/config;

string connectionString = config:getAsString("CONNECTION_STRING");
@test:Config {}
function testCreateTable() {
    Client postgresqlClient = checkpanic new (connectionString);
    sql:ExecutionResult result = checkpanic postgresqlClient->execute("CREATE TABLE visitor_info (" 
        +"id serial PRIMARY KEY, firstname VARCHAR(255), lastname VARCHAR(255), country VARCHAR(255))");
    checkpanic postgresqlClient.close();
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id is not nil.");
}

@test:Config {
    dependsOn: ["testCreateTable"]
}
function testInsertTable() {
    Client postgresqlClient = checkpanic new (connectionString);
    sql:ExecutionResult result = checkpanic postgresqlClient->execute("Insert into visitor_info (firstname, lastname,"
    +" country) values ('John','Smith','England')");
    checkpanic postgresqlClient.close();
    
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    if (insertId is int) {
        test:assertTrue(insertId > 0, "Last Insert Id is nil.");
    } else {
        test:assertFail("Insert Id should be an integer.");
    }
}

@test:Config {
    dependsOn: ["testInsertTable"]
}
function testInsertAndSelectTable() {
    Client postgresqlClient = checkpanic new (connectionString);
    sql:ExecutionResult result = checkpanic postgresqlClient->execute("Insert into visitor_info (firstname, lastname,"
    +" country) values ('David','Miller','Australia')");

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    
    var insertedId = result.lastInsertId;
    if (insertedId is int) {
        string query = string `SELECT * from visitor_info where id = ${insertedId}`;
        stream<record{}, error> queryResult = postgresqlClient->query(query);

    error? e = queryResult.forEach(function(record {} result) {
            test:assertEquals(result["id"], insertedId, "Incorrect InsetId returned.");
        });

        if (e is error) {
            test:assertFail(e.message());
        }    
    } else {
        test:assertFail("Insert Id should be an integer.");
    }
    checkpanic postgresqlClient.close();
}

@test:AfterSuite {}
function afterSuiteFunc() {
    Client postgresqlClient = checkpanic new (connectionString);
    sql:ExecutionResult result = checkpanic postgresqlClient->execute("DROP TABLE visitor_info");
    checkpanic postgresqlClient.close();
}
