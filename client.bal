import ballerina/sql;
import ballerina/jdbc;

public client class Client{
    private jdbc:Client jdbcClient;

    public function init(string url, string? user = (), string? password = (), jdbc:Options? options = (), 
        sql:ConnectionPool? connectionPool = ()) returns sql:Error?{
            self.jdbcClient = check new(url, user, password, options, connectionPool);
    }

    remote function query(string | sql:ParameterizedQuery sqlQuery, typedesc<record {}>? rowType = ()) 
    returns @tainted stream<record {}, sql:Error>{
        return self.jdbcClient->query(sqlQuery, rowType);
    }

    remote function execute(string | sql:ParameterizedQuery sqlQuery) returns sql:ExecutionResult | sql:Error{
        return self.jdbcClient->execute(sqlQuery);
    }

    remote function batchExecute(sql:ParameterizedQuery[ ] sqlQueries) returns sql:ExecutionResult[ ] | sql:Error{
        return  self.jdbcClient->batchExecute(sqlQueries);
    }

    remote function call(string | sql:ParameterizedCallQuery sqlQuery, typedesc<record {}>[] rowTypes = []) 
    returns sql:ProcedureCallResult | sql:Error{
        return self.jdbcClient->call(sqlQuery, rowTypes);
    }

    public function close() returns sql:Error?{
        return self.jdbcClient.close();
    }
}