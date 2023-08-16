using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;
using LakshayLab5.Data;
using LakshayLab5.Models;

// The Blank Page item template is documented at https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x409

namespace AthleteUI
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        private readonly Athlete athlete;

        public MainPage()
        {
            this.InitializeComponent();
            athlete = new Athlete(App.ConnectionString);
            FillDropDowns();
        }

        private async void FillDropDowns()
        {

            try 
            {
                List<Lookup> contingent = await athlete.GetPlayerByContingent();

                contingent.Insert(0, new Lookup { ID = 0, DisplayText = "- All Player" });

                comCon.ItemsSource = contingent;

                List<Lookup> gender = await athlete.GetPlayerByGender();

                gender.Insert(0, new Lookup { ID = 0, DisplayText = "- All Types" });

                comGen.ItemsSource = gender;

                txtFilter.Text = "";

                ShowAthlete(null,null,null,null,null);
            }
            catch(Exception ex) 
            {
                string errMsg = ex.GetBaseException().Message;
                if (errMsg.Contains("Failed to generate SSPI context"))
                {
                    App.ShowMessage("Error", "You need to enable Enterprise Authentication in Capabilities.");
                }
                else if (errMsg.Contains("server"))
                {
                    App.ShowMessage("Error", "Could not connect to the database server. Are you using the correct connetion string?");
                }

                else if (errMsg.Contains("database"))
                {
                    App.ShowMessage("Error", "Could not connect to the database server. Did you create the database?");
                }
                else
                {
                    App.ShowMessage("Error", "Could not complete operation");
                }
            }        
        }
        private async void ShowAthlete(int? ContingentID, int? GenderID, string NameFilter, DateTime? DobMin, DateTime? DobMax)
        {
            try 
            {
                List<Player> player;
                if (ContingentID.GetValueOrDefault() > 0 ||
                   GenderID.GetValueOrDefault() > 0 ||
                   !String.IsNullOrEmpty(NameFilter) ||
                   (DobMin.HasValue && DobMax.HasValue))
                {
                    player = await athlete.AthleteSelectByX(ContingentID.GetValueOrDefault(), GenderID.GetValueOrDefault(), NameFilter, DobMin, DobMax);
                }
                else
                {
                    player = await athlete.GetAthletes();
                }

                lvwAthlete.ItemsSource = player;
            }
            catch(Exception ex) 
            {
                string errMsg = ex.GetBaseException().Message;
                if (errMsg.Contains("Failed to generate SSPI context"))
                {
                    App.ShowMessage("Error", "You need to enable Enterprise Authentication in Capabilities.");
                }
                else if (errMsg.Contains("server"))
                {
                    App.ShowMessage("Error", "Could not connect to the database server. Are you using the correct connetion string?");
                }

                else if (errMsg.Contains("database"))
                {
                    App.ShowMessage("Error", "Could not connect to the database server. Did you create the database?");
                }
                else
                {
                    App.ShowMessage("Error", "Could not complete operation");
                }
            }
            
        }

        private void btnFilter_Click(object sender, RoutedEventArgs e)
        {
            Lookup selectedCon = (Lookup)comCon.SelectedItem;
            Lookup selectedGen = (Lookup)comGen.SelectedItem;
            DateTime? after = dateAfter.Date?.DateTime;
            DateTime? befor = dateBefor.Date?.DateTime;

            ShowAthlete(selectedCon?.ID, selectedGen?.ID,txtFilter.Text, after, befor);
        }

        private void Clear_Click(object sender, RoutedEventArgs e)
        {
            FillDropDowns();
        }

        private void Refresh_Click(object sender, RoutedEventArgs e)
        {
            comCon.SelectedIndex = -1;
            comGen.SelectedIndex = -1;
            txtFilter.Text = "";
            dateAfter.Date = null;
            dateBefor.Date = null;
            ShowAthlete(null,null,null,null,null);
        }

        private void AnotherPage_Click(object sender, RoutedEventArgs e)
        {
            Player newplayer = new Player();
            newplayer.DOB = DateTime.Now;

            Frame.Navigate(typeof(PlayerDetailPage), newplayer);
        }

        private void athleteGrifView_ItemClick(object sender, ItemClickEventArgs e)
        {
            Frame.Navigate(typeof(PlayerDetailPage), (Player)e.ClickedItem);
        }
    }
}
