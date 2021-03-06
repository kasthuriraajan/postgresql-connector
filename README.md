# postgresql-connector

This module provides the functionality required to access and manipulate data stored in a PostgreSQL database.

## Client
To access a database, you must first create a postgresql:Client object. To create a client the jdbc `connection string` for the database is mandatory. 

Following is a sample usecase to use this connector. 
```
import ballerina/io;
import ballerina/config;
import ballerina/sql;
import ballerinax/postgresql;

public function main() {
    string fname = "James";
    string lname = "Bond";
    string country = "US";
    
    postgresql:Client postgresqlClient = checkpanic new (config:getAsString("CONNECTION_STRING"));
    
    // Insert Users into db
    sql:ExecutionResult insertResult = insertUser(postgresqlClient, fname, lname, country);
    io:println(insertResult);
    //Get All users from db
    getAllUser(postgresqlClient);
    checkpanic postgresqlClient.close();
}

function insertUser(postgresql:Client postgresqlClient, string fname, string lname, string country) returns sql:ExecutionResult{
    sql:ParameterizedQuery insertQuery = `INSERT INTO userdetail(firstname, lastname, country) 
            VALUES ( ${fname}, ${lname}, ${country})`;
    sql:ExecutionResult result = checkpanic postgresqlClient->execute(insertQuery);
    return result;
}
function getAllUser(postgresql:Client postgresqlClient){
    stream<record{}, error> resultStream = postgresqlClient->query("Select * from userdetail");

    error? e = resultStream.forEach(function(record {} result) {
        io:println("Full User details: ", result);
        io:println("User first name: ", result["firstname"]);
        io:println("User last name: ", result["lastname"]);
        io:println("User country: ", result["country"]);
    });

    if (e is error) {
        io:println("ForEach operation on the stream failed!");
        io:println(e);
    }
}
```

Need to setup the `CONNECTION_STRING` for the db (with database name) in the `ballerina.config` file.
