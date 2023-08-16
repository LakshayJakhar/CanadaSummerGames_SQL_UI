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
using Windows.UI.Popups;

// The Blank Page item template is documented at https://go.microsoft.com/fwlink/?LinkId=234238

namespace AthleteUI
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class PlayerDetailPage : Page
    {
        Player view;
        private readonly Athlete athlete;
        bool InsertMode;
        public PlayerDetailPage()
        {
            this.InitializeComponent();
            athlete = new Athlete(App.ConnectionString);
            fillDropDowns();
        }

        private async void fillDropDowns()
        {
            try
            {
                List<Lookup> contingent = await athlete.GetPlayerByContingent();
                List<Lookup> gender = await athlete.GetPlayerByGender();

                comCon.ItemsSource = contingent;
                comGen.ItemsSource = gender;
                this.DataContext = view;
            }
            catch(Exception ex)
            {
                string errMsg = ex.GetBaseException().Message;
                if (errMsg.Contains("Failed to generate SSPI context"))
                {
                    MessageDialog d = new MessageDialog("You need to enable Enterprise Authentication in Capabilities.", "Error");
                    await d.ShowAsync();
                }
                else if (errMsg.Contains("server"))
                {
                    MessageDialog d = new MessageDialog("Could not connect to the database server. Are you using the correct connetion string?", "Error");
                    await d.ShowAsync();
                }

                else if (errMsg.Contains("database"))
                {
                    MessageDialog d = new MessageDialog("Could not connect to the database server. Did you create the database?", "Error");
                    await d.ShowAsync();
                }
                else
                {
                    MessageDialog d = new MessageDialog("Could not complete operation.", "Error");
                    await d.ShowAsync();
                }
            }
        }
            
        

        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            view = (Player)e.Parameter;

            if (view.ID == 0)
            {
                btnDelete.IsEnabled = false;
                InsertMode = true;
            }
            else
            {
                InsertMode = false;
            }
        }

        private bool IsValid()
        {
            bool valid = true;
            string message = "Please fix the following errors:\n\n";

            if (string.IsNullOrEmpty(view.FirstName))
            {
                valid = false;
                message += "You must enter the First Name for the Player. \n";
            }
            if (string.IsNullOrEmpty(view.MiddleName))
            {
                valid = false;
                message += "You must enter the Middle Name for the Player. \n";
            }
            if (string.IsNullOrEmpty(view.LastName))
            {
                valid = false;
                message += "You must enter the Last Name for the Player. \n";
            }
            if (string.IsNullOrEmpty(view.AthleteCode))
            {
                valid = false;
                message += "You must enter the Athlete Code for the Player. \n";
            }
            if (view.Height <0)
            {
                valid = false;
                message += "You must enter the Height for the Player. \n";
            }
            if (view.Weight < 0)
            {
                valid = false;
                message += "You must enter the Weight for the Player. \n";
            }
            if (string.IsNullOrEmpty(view.EMail))
            {
                valid = false;
                message += "You must enter the Email for the Player. \n";
            }
            if (string.IsNullOrEmpty(view.MediaInfo))
            {
                valid = false;
                message += "You must enter the Media Info for the Player. \n";
            }
            if (view.ContingentID == 0)
            {
                valid = false;
                message += "You must enter the Contingent ID for the Player. \n";
            }
            if (view.GenderID == 0)
            {
                valid = false;
                message += "You must enter the Gender ID for the Player. \n";
            }
            if (!valid)
            {
                App.ShowMessage("Error", message);

            }

            return valid;

        }

        private async void btnDelete_Click(object sender, RoutedEventArgs e)
        {
            string strTitle = "Confirm Delete";
            string strMsg = "Are you certain that you want to delete " + view.FirstName + view.MiddleName + view.LastName + "?";
            ContentDialogResult choice = await App.ConfirmDialog(strTitle, strMsg);
            if(choice == ContentDialogResult.Secondary)
            {
                try
                {
                    int result = await athlete.DeletePlayer(view);
                    if (result == 0)
                    {
                        MessageDialog d = new MessageDialog("Could not delete " + view.FirstName + view.MiddleName + view.LastName, "Error");
                        await d.ShowAsync();
                    }
                    Frame.GoBack();
                }
                catch(Exception ex)
                {
                    string errMsg = ex.GetBaseException().Message;
                    if (errMsg.Contains("Failed to generate SSPI context"))
                    {
                        MessageDialog d = new MessageDialog("You need to enable Enterprise Authentication in Capabilities.", "Error");
                        await d.ShowAsync();
                    }
                    else if (errMsg.Contains("server"))
                    {
                        MessageDialog d = new MessageDialog("Could not connect to the database server. Are you using the correct connetion string?", "Error");
                        await d.ShowAsync();
                    }

                    else if (errMsg.Contains("database"))
                    {
                        MessageDialog d = new MessageDialog("Could not connect to the database server. Did you create the database?", "Error");
                        await d.ShowAsync();
                    }
                    else
                    {
                        MessageDialog d = new MessageDialog("Could not complete operation.", "Error");
                        await d.ShowAsync();
                    }
                }
            }
        }

        private async void btnSave_Click(object sender, RoutedEventArgs e)
        {
            try 
            {
                if (IsValid())
                {
                    if (InsertMode == true)
                    {
                        int recordsAffected = await athlete.AddPlayer(view);
                        if (recordsAffected == 0)
                        {
                            MessageDialog d = new MessageDialog("Could not add " + view.FirstName + view.MiddleName + view.LastName, "Error");
                            await d.ShowAsync();
                        }
                        else 
                        {
                            MessageDialog d = new MessageDialog($"{view.FirstName + view.MiddleName + view.LastName} Inserted");
                            await d.ShowAsync();
                        }
                    }
                    else
                    {
                        int recordsAffected = await athlete.UpdatePlayer(view);
                        if (recordsAffected == 0)
                        {
                            MessageDialog d = new MessageDialog("Could not add " + view.FirstName + view.MiddleName + view.LastName, "Error");
                            await d.ShowAsync();
                        }
                        Frame.GoBack();
                    }
                }
            }
            catch (Exception ex )
            {
                string errMsg = ex.GetBaseException().Message;
                if (errMsg.Contains("Failed to generate SSPI context"))
                {
                    MessageDialog d = new MessageDialog("You need to enable Enterprise Authentication in Capabilities.", "Error");
                    await d.ShowAsync();
                }
                else if (errMsg.Contains("server"))
                {
                    MessageDialog d = new MessageDialog("Could not connect to the database server. Are you using the correct connetion string?", "Error");
                    await d.ShowAsync();
                }

                else if (errMsg.Contains("database"))
                {
                    MessageDialog d = new MessageDialog("Could not connect to the database server. Did you create the database?", "Error");
                    await d.ShowAsync();
                }
                else
                {
                    //MessageDialog d = new MessageDialog("Could not complete operation.", "Error");
                    //await d.ShowAsync();

                    MessageDialog d = new MessageDialog(errMsg);
                    await d.ShowAsync();
                }
            }

            
        }

        private void btnCancel_Click(object sender, RoutedEventArgs e)
        {
            Frame.GoBack();
        }
    }
}
