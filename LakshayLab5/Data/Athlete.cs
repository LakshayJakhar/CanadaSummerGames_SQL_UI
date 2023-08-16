using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LakshayLab5.Models;
using Dapper;

namespace LakshayLab5.Data
{
    public class Athlete : IAthlete
    {
        private string _connectionString;

        public Athlete(string connstr)
        {
            _connectionString = connstr;
        }

        public async Task<List<Player>> GetAthletes()
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                List<Player> athlete = new List<Player>();
                try
                {
                    await connection.OpenAsync();
                    athlete = (List<Player>)await connection.QueryAsync<Player>("usp_AthleteSelectAll",
                        commandType: CommandType.StoredProcedure);
                }
                catch (Exception)
                {
                    throw;
                }
                return athlete;

            }
        }

        public async Task<List<Lookup>> GetPlayerByContingent()
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                List<Lookup> contingent = new List<Lookup>();
                try
                {
                    await connection.OpenAsync();
                    contingent = (List<Lookup>)await connection.QueryAsync<Lookup>("usp_ContingentList", commandType: CommandType.StoredProcedure);
                }
                catch (Exception)
                {
                    throw;
                }
                return contingent;
            }

        }

        public async Task<List<Lookup>> GetPlayerByGender()
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                List<Lookup> gender = new List<Lookup>();
                try
                {
                    await connection.OpenAsync();
                    gender = (List<Lookup>)await connection.QueryAsync<Lookup>("usp_GenderList", commandType: CommandType.StoredProcedure);
                }
                catch (Exception)
                {
                    throw;
                }
                return gender;
            }

        }

        public async Task<List<Player>> AthleteSelectByX(int ContingentID, int GenderID, string NameFilter, DateTime? DobMin, DateTime? DobMax)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                List<Player> filter = new List<Player>();
                try
                {
                    await connection.OpenAsync();
                    filter = (List<Player>)await connection.QueryAsync<Player>("usp_AthleteSelectByX",
                        new { ContingentID, GenderID, NameFilter, DobMin ,DobMax},
                        commandType: CommandType.StoredProcedure);
                }
                catch (Exception)
                {
                    throw;
                }

                return filter;
            }
        }

        public async Task<int> AddPlayer(Player playerToAdd)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                int affectedRows = 0;
                try
                {
                    await connection.OpenAsync();

                    DynamicParameters parameters = new DynamicParameters();
                    parameters.Add("@First", playerToAdd.FirstName);
                    parameters.Add("@Middle", playerToAdd.MiddleName);
                    parameters.Add("@Last", playerToAdd.LastName);
                    parameters.Add("@AthleteCode", playerToAdd.AthleteCode);
                    parameters.Add("@Dob", playerToAdd.DOB);
                    parameters.Add("@Height", playerToAdd.Height);
                    parameters.Add("@Weight", playerToAdd.Weight);
                    parameters.Add("@Media", playerToAdd.MediaInfo);
                    parameters.Add("@Email", playerToAdd.EMail);
                    parameters.Add("@ContingentID", playerToAdd.ContingentID);
                    parameters.Add("@GenderID", playerToAdd.GenderID);
                    parameters.Add("@ID", playerToAdd.ID, direction: ParameterDirection.Output);


                    affectedRows = await connection.ExecuteAsync(
                        "usp_AthleteInsert",
                        parameters,
                        commandType: CommandType.StoredProcedure);
                    playerToAdd.ID = parameters.Get<int>("@ID");//Get the new Primary Key Value

                }
                catch (Exception)
                {
                    throw;
                }
                return affectedRows;
            }
        }

        public async Task<int> UpdatePlayer(Player playerToUpdate)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                int affectedRows = 0;
                try
                {
                    await connection.OpenAsync();

                    DynamicParameters parameters = new DynamicParameters();
                    parameters.Add("@First", playerToUpdate.FirstName);
                    parameters.Add("@Middle", playerToUpdate.MiddleName);
                    parameters.Add("@Last", playerToUpdate.LastName);
                    parameters.Add("@AthleteCode", playerToUpdate.AthleteCode);
                    parameters.Add("@Dob", playerToUpdate.DOB);
                    parameters.Add("@Height", playerToUpdate.Height);
                    parameters.Add("@Weight", playerToUpdate.Weight);
                    parameters.Add("@Media", playerToUpdate.MediaInfo);
                    parameters.Add("@Email", playerToUpdate.EMail);
                    parameters.Add("@ContingentID", playerToUpdate.ContingentID);
                    parameters.Add("@GenderID", playerToUpdate.GenderID);
                    parameters.Add("@ID", playerToUpdate.ID);
                    parameters.Add("@RowVersion", playerToUpdate.RowVersion);


                    affectedRows = await connection.ExecuteAsync("usp_AthleteUpdate",
                        parameters,
                        commandType: CommandType.StoredProcedure);

                }
                catch (Exception)
                {
                    throw;
                }
                finally
                {
                    if (connection.State == ConnectionState.Open)
                        connection.Close();
                }
                return affectedRows;
            }
        }

        public async Task<int> DeletePlayer(Player playerToDelete)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                int affectedRows = 0;
                await connection.OpenAsync();
                try
                {
                    affectedRows = connection.Execute("usp_AthleteDelete",
                    new { playerToDelete.ID },
                    commandType: CommandType.StoredProcedure);
                }
                catch (Exception)
                {
                    throw;
                }
                return affectedRows;
            }
        }
    }
}
