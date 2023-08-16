using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LakshayLab5.Models;

namespace LakshayLab5.Data
{
    public interface IAthlete
    {
        Task<List<Player>> GetAthletes();

        Task<List<Lookup>> GetPlayerByContingent();

        Task<List<Lookup>> GetPlayerByGender();

        Task<List<Player>> AthleteSelectByX(int ContingentID, int GenderID, string NameFilter, DateTime? DobMin, DateTime? DobMax);

        Task<int> AddPlayer(Player playerToAdd);
        Task<int> UpdatePlayer(Player playerToAdd);

        Task<int> DeletePlayer(Player playerToAdd);


    }
}
