// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/sql;
import ballerina/jdbc;

public client class Client{
    private jdbc:Client jdbcClient;

    # Initialize PostgreSQL client.
    #
    # + url - The JDBC  URL of the database
    # + user - If the database is secured, the username of the database
    # + password - The password of provided username of the database
    # + options - The Database specific JDBC client properties
    # + connectionPool - The `sql:ConnectionPool` object to be used within the jdbc client.
    #                   If there is no connectionPool is provided, the global connection pool will be used and it will
    #                   be shared by other clients which has same properties.
    public function init(string url, string? user = (), string? password = (), jdbc:Options? options = (), 
        sql:ConnectionPool? connectionPool = ()) returns sql:Error?{
            self.jdbcClient = check new(url, user, password, options, connectionPool);
    }

    # Queries the database with the query provided by the user, and returns the result as stream.
    #
    # + sqlQuery - The query which needs to be executed as `string` or `ParameterizedQuery` when the SQL query has
    #              params to be passed in
    # + rowType - The `typedesc` of the record that should be returned as a result. If this is not provided the default
    #             column names of the query result set be used for the record attributes.
    # + return - Stream of records in the type of `rowType`
    remote function query(string | sql:ParameterizedQuery sqlQuery, typedesc<record {}>? rowType = ()) 
    returns @tainted stream<record {}, sql:Error>{
        return self.jdbcClient->query(sqlQuery, rowType);
    }

    # Executes the DDL or DML sql queries provided by the user, and returns summary of the execution.
    #
    # + sqlQuery - The DDL or DML query such as INSERT, DELETE, UPDATE, etc as `string` or `ParameterizedQuery`
    #              when the query has params to be passed in
    # + return - Summary of the sql update query as `ExecutionResult` or returns `Error`
    #           if any error occurred when executing the query
    remote function execute(string | sql:ParameterizedQuery sqlQuery) returns sql:ExecutionResult | sql:Error{
        return self.jdbcClient->execute(sqlQuery);
    }

    # Executes a batch of parameterized DDL or DML sql query provided by the user,
    # and returns the summary of the execution.
    #
    # + sqlQueries - The DDL or DML query such as INSERT, DELETE, UPDATE, etc as `ParameterizedQuery` with an array
    #                of values passed in
    # + return - Summary of the executed SQL queries as `ExecutionResult[]` which includes details such as
    #            `affectedRowCount` and `lastInsertId`. If one of the commands in the batch fails, this function
    #            will return `BatchExecuteError`, however the JDBC driver may or may not continue to process the
    #            remaining commands in the batch after a failure. The summary of the executed queries in case of error
    #            can be accessed as `(<sql:BatchExecuteError> result).detail()?.executionResults`.
    remote function batchExecute(sql:ParameterizedQuery[ ] sqlQueries) returns sql:ExecutionResult[ ] | sql:Error{
        return  self.jdbcClient->batchExecute(sqlQueries);
    }

    # Executes a SQL stored procedure and returns the result as stream and execution summary.
    #
    # + sqlQuery - The query to execute the SQL stored procedure
    # + rowTypes - The array of `typedesc` of the records that should be returned as a result. If this is not provided
    #               the default column names of the query result set be used for the record attributes.
    # + return - Summary of the execution is returned in `ProcedureCallResult` or `sql:Error`
    remote function call(string | sql:ParameterizedCallQuery sqlQuery, typedesc<record {}>[] rowTypes = []) 
    returns sql:ProcedureCallResult | sql:Error{
        return self.jdbcClient->call(sqlQuery, rowTypes);
    }

    # Close the PostgreSQL client.
    #
    # + return - Possible error during closing the client
    public function close() returns sql:Error?{
        return self.jdbcClient.close();
    }
}
