using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Threading;

namespace GetDatabaseNames
{
    class Program
    {
        public static void Main(string[] args)
        {
            var result = String.Empty;

            try
            {
                using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["connString"].ConnectionString))
                {
                    var cmd = conn.CreateCommand();
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = @"DECLARE @db_names TABLE (DB_Status NVARCHAR(256), DB_Mode NVARCHAR(256), name NVARCHAR(256))
INSERT INTO @db_names (DB_Status, DB_Mode, name)
select
	convert(varchar(20),databasepropertyex(a.name, 'Status')) as DB_Status,
	convert(varchar(20),databasepropertyex(a.name, 'Updateability')) as DB_Mode,
	a.name
from master.dbo.sysdatabases a
--order by a.name
select name from @db_names where DB_Status='ONLINE' and DB_Mode='READ_WRITE'";
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            result += result == "" ? "" : ", ";
                            result += "{\"{#DBNAME}\":\"";
                            result += reader.GetString(0);
                            result += "\"}";
                        }
                    }
                }
            }
            catch (Exception excp)
            {
                Console.WriteLine(excp.Message);
            }

            result = "{\"data\":[" + result + "]}";

            Console.WriteLine(result);
        }
    }
}
