using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Windows.UI.Xaml.Data;

namespace AthleteUI.Converters
{
    public class CurrencyToStringConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, string language)
        {
            try
            {
                if (value == null) return string.Empty;

                return String.Format("{0:n2}", value);
            }
            catch (Exception)
            {
                return string.Empty;
            }
        }

        public object ConvertBack(object value, Type targetType, object parameter, string language)
        {
            try
            {
                string val = value.ToString();
                //strip out any characters that are not a digit, decimal place character or minus sign
                string cleanVal = new string(val.Where(c => (char.IsDigit(c)) || c == '.' || c == '-').ToArray());
                if (double.TryParse(cleanVal, out double result))
                {
                    return result;
                }
                else
                {
                    return 0.00;
                }
            }
            catch (Exception)
            {
                return 0.00;
            }
        }
    }
}

