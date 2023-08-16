using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LakshayLab5.Models
{
    public class Player
    {
        public int ID { get; set; }
        public string FirstName { get; set; }
        public string MiddleName { get; set; }
        public string LastName { get; set; }
        public string AthleteCode { get; set; }
        public DateTime DOB { get; set; }
        public double Height { get; set; }
        public double Weight { get; set; }
        public string MediaInfo { get; set; }
        public string EMail { get; set; }
        public Byte[] RowVersion { get; set; }
        public int ContingentID { get; set; }
        public int GenderID { get; set; }
        public string Summary { get; set; }
        public int Age { get; set; }
        public string Gender { get; set; }
        public string Contingent { get; set; }



    }
}
