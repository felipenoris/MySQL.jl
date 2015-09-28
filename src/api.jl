"""
Initializes the MYSQL object. Must be called before mysql_real_connect.
Memory allocated by mysql_init can be freed with mysql_close.
"""
function mysql_init(mysqlptr::MYSQL)
    return ccall((:mysql_init, mysql_lib),
                 Ptr{Void},
                 (Ptr{Cuchar}, ),
                 mysqlptr)
end

"""
Used to connect to database server. Returns a MYSQL handle on success and
C_NULL on failure.
"""
function mysql_real_connect(mysqlptr::MYSQL,
                            host::String,
                            user::String,
                            passwd::String,
                            db::String,
                            port::Cint,
                            unix_socket::Any,
                            client_flag::Uint64)

    reconnect_flag::Cuint = MySQL.MYSQL_OPTION.MYSQL_OPT_RECONNECT
    reconnect_option::Cuchar = 0
    retVal = MySQL.mysql_options(mysqlptr, reconnect_flag, reinterpret(Ptr{None},
                                   pointer_from_objref(reconnect_option)))
    if(retVal != 0)
        println("WARNING:::Options not set !!! The retVal is :: $retVal")
    end

    return ccall((:mysql_real_connect, mysql_lib),
                 Ptr{Cuchar},
                 (Ptr{Cuchar},
                  Ptr{Cuchar},
                  Ptr{Cuchar},
                  Ptr{Cuchar},
                  Ptr{Cuchar},
                  Cuint,
                  Ptr{Cuchar},
                  Uint64),
                 mysqlptr,
                 host,
                 user,
                 passwd,
                 db,
                 port,
                 unix_socket,
                 client_flag)
end

"""
Used to set options. Must be called after mysql_init and before
mysql_real_connect. Can be called multiple times to set options.
Returns non zero on error.
"""
function mysql_options(mysqlptr::MYSQL,
                       option_type::Cuint,
                       option::Ptr{None})
    return ccall((:mysql_options, mysql_lib),
                 Cint,
                 (Ptr{Cuchar},
                  Cint,
                  Ptr{Cuchar}),
                 mysqlptr,
                 option_type,
                 option)
end

"""
Close an opened MySQL connection.
"""
function mysql_close(mysqlptr::MYSQL)
    return ccall((:mysql_close, mysql_lib),
                 Void,
                 (Ptr{Cuchar}, ),
                 mysqlptr)
end

"""
Returns the error number of the last API call.
"""
function mysql_errno(mysqlptr::MYSQL)
    return ccall((:mysql_errno, mysql_lib),
                 Cuint,
                 (Ptr{Cuchar}, ),
                 mysqlptr)
end

"""
Returns a string of the last error message of the most recent function call.
If no error occured and empty string is returned.
"""
function mysql_error(mysqlptr::MYSQL)
    return ccall((:mysql_error, mysql_lib),
                 Ptr{Cuchar},
                 (Ptr{Cuchar}, ),
                 mysqlptr)
end

"""
Executes the prepared query associated with the statement handle.
"""
function mysql_stmt_execute(stmtptr::Ptr{MYSQL_STMT})
    return ccall((:mysql_stmt_execute, mysql_lib),
                 Cint,
                 (Ptr{Cuchar}, ),
                 stmtptr)
end

"""
Closes the prepared statement.
"""
function mysql_stmt_close(stmtptr::Ptr{MYSQL_STMT})
    return ccall((:mysql_stmt_close, mysql_lib),
                 Cchar,
                 (Ptr{Cuchar}, ),
                 stmtptr)
end

"""
Returns the value generated by auto increment column by the previous
insert / update statement.
"""
function mysql_insert_id(mysqlptr::MYSQL)
    return ccall((:mysql_insert_id, mysql_lib),
                 Culong,
                 (Ptr{Cuchar}, ),
                 mysqlptr)
end

"""
Creates the sql string where the special chars are escaped
"""
function mysql_real_escape_string(mysqlptr::MYSQL,
                                  to::Vector{Uint8},
                                  from::String,
                                  length::Culong)
    return ccall((:mysql_real_escape_string, mysql_lib),
                 Uint32,
                 (Ptr{Cuchar},
                  Ptr{Uint8},
                  Ptr{Uint8},
                  Culong),
                 mysqlptr,
                 to,
                 from,
                 length)
end

"""
Creates a mysql_stmt handle. Should be closed with mysql_close_stmt
"""
function mysql_stmt_init(dbptr::Ptr{Cuchar})
    return ccall((:mysql_stmt_init, mysql_lib),
                 Ptr{MYSQL_STMT},
                 (Ptr{Cuchar}, ),
                 dbptr)
end

function mysql_stmt_init(db::MySQLDatabaseHandle)
    return mysql_stmt_init(db.ptr)
end

"""
Creates the prepared statement. There should be only 1 statement
"""
function mysql_stmt_prepare(stmtptr::Ptr{MYSQL_STMT}, sql::String)
    s = utf8(sql)
    return ccall((:mysql_stmt_prepare, mysql_lib),
                 Cint, # TODO: Confirm proper type to use here
                 (Ptr{Cuchar}, Ptr{Cchar}, Culong),
                 stmtptr,      s,          length(s))
end

"""
Returns the error message for the recently invoked statement API
"""
function mysql_stmt_error(stmtptr::Ptr{MYSQL_STMT})
    return ccall((:mysql_stmt_error, mysql_lib),
                 Ptr{Cuchar},
                 (Ptr{Cuchar}, ),
                 stmtptr)
end

"""
Store the entire result returned by the prepared statement in the
bind datastructure provided by mysql_stmt_bind_result.
"""
function mysql_stmt_store_result(stmtptr::Ptr{MYSQL_STMT})
    return ccall((:mysql_stmt_store_result, mysql_lib),
                 Cint,
                 (Ptr{Cuchar}, ),
                 stmtptr)
end

"""
Return the metadata for the results that will be received from
the execution of the prepared statement.
"""
function mysql_stmt_result_metadata(stmtptr::Ptr{MYSQL_STMT})
    return ccall((:mysql_stmt_result_metadata, mysql_lib),
                 Ptr{Cuchar},
                 (Ptr{Cuchar}, ),
                 stmtptr)
end

"""
Equivalent of `mysql_num_rows` for prepared statements.
"""
function mysql_stmt_num_rows(stmtptr::Ptr{MYSQL_STMT})
    return ccall((:mysql_stmt_num_rows, mysql_lib),
                 Int64,
                 (Ptr{Cuchar}, ),
                 stmtptr)
end

"""
Equivalent of `mysql_fetch_row` for prepared statements.
"""
function mysql_stmt_fetch_row(stmtptr::Ptr{MYSQL_STMT})
    return ccall((:mysql_stmt_fetch, mysql_lib),
                 Cint,
                 (Ptr{Cuchar}, ),
                 stmtptr)
end

"""
Bind the returned data from execution of the prepared statement
to a preallocated datastructure `bind`.
"""
function mysql_stmt_bind_result(stmtptr::Ptr{MYSQL_STMT}, bind::Ptr{MYSQL_BIND})
    return ccall((:mysql_stmt_bind_result, mysql_lib),
                 Cchar,
                 (Ptr{Uint8}, Ptr{Cuchar}),
                 stmtptr,
                 bind)
end

"""
Executes the query and returns the status of the same.
"""
function mysql_query(mysqlptr::MYSQL, sql::String)
    return ccall((:mysql_query, mysql_lib),
                 Int8,
                 (Ptr{Cuchar}, Ptr{Cuchar}),
                 mysqlptr,
                 sql)
end

"""
Stores the result in to an object.
"""
function mysql_store_result(results::Ptr{Cuchar})
    return ccall((:mysql_store_result, mysql_lib),
                 Ptr{Cuchar},
                 (Ptr{Cuchar},),
                 results)
end

"""
Returns the field metadata.
"""
function mysql_fetch_fields(results::Ptr{Cuchar})
    return ccall((:mysql_fetch_fields, mysql_lib),
                 Ptr{MYSQL_FIELD},
                 (Ptr{Cuchar},),
                 results)
end


"""
Returns the row from the result set.
"""
function mysql_fetch_row(results::Ptr{Cuchar})
    return ccall((:mysql_fetch_row, mysql_lib),
                 MYSQL_ROW,
                 (Ptr{Cuchar},),
                 results)
end

"""
Frees the result set.
"""
function mysql_free_result(results::Ptr{Cuchar})
    return ccall((:mysql_free_result, mysql_lib),
                 Ptr{Cuchar},
                 (Ptr{Cuchar},),
                 results)
end

"""
Returns the number of fields in the result set.
"""
function mysql_num_fields(results::Ptr{Cuchar})
    return ccall((:mysql_num_fields, mysql_lib),
                 Int8,
                 (Ptr{Cuchar},),
                 results)
end

"""
Returns the number of records from the result set.
"""
function mysql_num_rows(results::Ptr{Cuchar})
    return ccall((:mysql_num_rows, mysql_lib),
                 Int64,
                 (Ptr{Cuchar},),
                 results)
end

"""
Returns the # of affected rows in case of insert / update / delete.
"""
function mysql_affected_rows(results::Ptr{Cuchar})
    return ccall((:mysql_affected_rows, mysql_lib),
                 Uint64,
                 (Ptr{Cuchar},),
                 results)
end

"""
Set the auto commit mode.
"""
function mysql_autocommit(mysqlptr::MYSQL, mode::Int8)
    return ccall((:mysql_autocommit, mysql_lib),
                 Cchar, (Ptr{Void}, Cchar),
                 mysqlptr, mode)
end

"""
Used to get the next result while executing multi query. Returns 0 on success
and more results are present. Returns -1 on success and no more results. Returns
positve on error.
"""
function mysql_next_result(mysqlptr::MYSQL)
    return ccall((:mysql_next_result, mysql_lib), Cint, (Ptr{Void},),
                 mysqlptr)
end
