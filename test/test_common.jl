# A test  that performs  some basic SQL  queries. It creates  a database
# called  `mysqltest` a  user called  `test`  and a  table in  mysqltest
# called  `Employee`.  It then  inserts some  data, performs  an update,
# then retrieves the data using  a select query and converts the results
# to a datafram.

function run_query_helper(command, msg)
    error("API not implemented: `run_query_helper`")
end

function connect_as_root()
    global con = MySQL.mysql_init_and_connect(HOST, "root", ROOTPASS, "")
end

function create_test_database()
    command = """CREATE DATABASE mysqltest;"""
    @test run_query_helper(command, "Create database")
end

function create_test_user()
    command = "CREATE USER test@$HOST IDENTIFIED BY 'test';"
    @test run_query_helper(command, "Create user")
end

function grant_test_user_privilege()
    command = "GRANT ALL ON mysqltest.* TO test@$HOST;"
    @test run_query_helper(command, "Grant privilege")
end

function connect_as_test_user()
    global con = MySQL.mysql_init_and_connect(HOST, "test", "test", "mysqltest")
end

function create_table()
    command = """CREATE TABLE Employee
                 (
                     ID INT NOT NULL AUTO_INCREMENT,
                     Name VARCHAR(255),
                     Salary FLOAT(7,2),
                     JoinDate DATE,
                     LastLogin DATETIME,
                     LunchTime TIME,
                     OfficeNo TINYINT,
                     JobType ENUM('HR', 'Management', 'Accounts'),
                     Senior BIT(1),
                     empno SMALLINT,
                     PRIMARY KEY (ID)
                 );"""
    @test run_query_helper(command, "Create table")
end

function insert_values()
    command = """INSERT INTO Employee (Name, Salary, JoinDate, LastLogin, LunchTime, OfficeNo, JobType, Senior, empno)
                 VALUES
                 ('John', 10000.50, '2015-8-3', '2015-9-5 12:31:30', '12:00:00', 1, 'HR', b'1', 1301),
                 ('Tom', 20000.25, '2015-8-4', '2015-10-12 13:12:14', '13:00:00', 12, 'HR', b'1', 1422),
                 ('Jim', 30000.00, '2015-6-2', '2015-9-5 10:05:10', '12:30:00', 45, 'Management', b'0', 1567),
                 ('Tim', 15000.50, '2015-7-25', '2015-10-10 12:12:25', '12:30:00', 56, 'Accounts', b'1', 3200);
              """
    @test run_query_helper(command, "Insert")
end

function update_values()
    command = """UPDATE Employee SET Salary = 25000.00 WHERE ID > 2;"""
    @test run_query_helper(command, "Update")
end

function drop_table()
    command = """DROP TABLE Employee;"""
    @test run_query_helper(command, "Drop table")
end

function do_multi_statement()
    command = """INSERT INTO Employee (Name, Salary, JoinDate, LastLogin, LunchTime, OfficeNo, JobType, Senior, empno) VALUES
                 ('Donald', 30000.00, '2014-2-2', '2015-8-8 13:14:15', '14:01:02', 33, 'HR', b'0', 1112);
                 UPDATE Employee SET LunchTime = '15:00:00' WHERE LENGTH(Name) > 5;"""
    aff_rows = MySQL.execute_multi_query(con, command)
    println("Multi query affected rows: $aff_rows")
end

function show_as_dataframe()
    error("API not implemented: `run_query_helper`")
end

function drop_test_user()
    command = """DROP USER test@$HOST;"""
    @test run_query_helper(command, "Drop user")
end

function drop_test_database()
    command = """DROP DATABASE mysqltest;"""
    @test run_query_helper(command, "Drop database")
end

function run_test()
    # Connect as root and setup database, user and privilege
    # for the user.
    connect_as_root()
    create_test_database()
    create_test_user()
    grant_test_user_privilege()
    MySQL.mysql_disconnect(con)

    # Connect as test user and do insert, update etc.
    # and finally drop the table.
    connect_as_test_user()
    create_table()
    insert_values()
    update_values()
#   Subsequent queries fail after multi statement, need to debug.
    do_multi_statement()
    show_as_dataframe()
    drop_table()
    MySQL.mysql_disconnect(con)

    # Drop the test user and database.
    connect_as_root()
    drop_test_user()
    drop_test_database()
    MySQL.mysql_disconnect(con)
end
