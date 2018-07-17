using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;
using Dapper;
using Newtonsoft.Json;

namespace ConsoleApp2
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length != 1)
                return;
            string connectionString = "Data Source=.;Initial Catalog=DbAdmin;Integrated Security=True;Pooling=False";
            string sqlQuery = @"exec SQLReportToZabbix_v2 @IncomingParam";

            string str = "";
            IEnumerable<dynamic> result;

            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();

                result = connection.Query<dynamic>(sqlQuery, new { IncomingParam = args[0] });
                str = String.Concat(result);
            }

            var outString = @"{""data"":{" + String.Join(",", result.Select(x => String.Format("\"{0}\":{1}", x.Item, x.Value))) + "}}";

            Console.WriteLine(outString);
        }
    }
}