﻿using System;
using System.Diagnostics;
using System.Globalization;
using System.Windows;
using System.Windows.Data;
using System.Windows.Controls;
using iTRAACv2.Model;

namespace iTRAACv2.View
{
  public partial class SettingsPage
  {
    public SettingsPage()
    {
      InitializeComponent();

      LostFocus += SettingsPageLostFocus;

      iTRAACHelpers.WpfDataGridStandardBehavior(gridTaxOffices);
    }

    private void SettingsPageLostFocus(object sender, RoutedEventArgs e)
    {
      if (IsVisible) return; //nugget: focus is pretty complex in WPF, the LostFocus event will fire whenever any child control loses focus due to event "bubbling" ... by checking IsVisible of the UserControl, we only execute this save logic when the UserControl has truly been navigated away from

      TaxOfficeModel.Current.Save();
      SettingsModel.SaveLocalSettings(true);
    }

    private void GridTaxOfficesRowDetailsVisibilityChanged(object sender, DataGridRowDetailsEventArgs e)
    {
      var gridUsers = (DataGrid)e.DetailsElement;
      if (e.Row.Visibility != Visibility.Visible || gridUsers.ItemsSource != null) return;
      iTRAACHelpers.WpfDataGridStandardBehavior(gridUsers);
      //whack:gridUsers.MouseLeftButtonDown += new System.Windows.Input.MouseButtonEventHandler(gridUsers_MouseLeftButtonDown);
      gridUsers.ItemsSource = TaxOfficeModel.OfficeUsers(e.Row.DataContext);
    }

    private void BtnAddAgentClick(object sender, RoutedEventArgs e)
    {
      popAddAgent.IsOpen = true;
      lbxAddAgentExistingUsers.Focus();
    }

    private void BtnAddAgentCancelClick(object sender, RoutedEventArgs e)
    {
      popAddAgent.IsOpen = false;
    }

    private void PopAddAgentGotFocus(object sender, RoutedEventArgs e)
    {
      if (sender == lbxAddAgentExistingUsers) rdoAddExistingAgent.IsChecked = true;
      else rdoAddNewAgent.IsChecked = true;
    }

    private void BtnAddAgentOKClick(object sender, RoutedEventArgs e)
    {
      Debug.Assert(rdoAddExistingAgent.IsChecked != null, "rdoAddExistingAgent.IsChecked != null");
      if (rdoAddExistingAgent.IsChecked.Value)
        TaxOfficeModel.Current.ReActivateUser((Guid)lbxAddAgentExistingUsers.SelectedValue);
      else if (TaxOfficeModel.Current.AddNewUser(AddAgent_FirstName.Text, AddAgent_LastName.Text, AddAgent_Email.Text, AddAgent_DSN.Text))
      {
        AddAgent_FirstName.Text = "";
        AddAgent_LastName.Text = "";
        AddAgent_Email.Text = "";
        AddAgent_DSN.Text = "";
      }

      popAddAgent.IsOpen = false;
    }

    private void BtnTestPrintClick(object sender, RoutedEventArgs e)
    {
      var tag = ((Control)sender).Tag.ToString();
      if (tag.Left(1) == "!") TaxFormModel.ResetPrinterSettings(tag.Left(-1).ToEnum<TaxFormModel.PackageComponent>());
      else TaxFormModel.PrintTest(tag.ToEnum<TaxFormModel.PackageComponent>());
    }

  }

  public class UserGridIsReadOnlyMulti : WPFValueConverters.MarkupExtensionConverter, IMultiValueConverter
  {
// ReSharper disable EmptyConstructor
    public UserGridIsReadOnlyMulti() { } //to avoid an XAML annoying warning from XAML designer: "No constructor for type 'xyz' has 0 parameters."  Somehow the inherited one doesn't do the trick!?!  I guess it's a reflection buggy
// ReSharper restore EmptyConstructor

    public object Convert(object[] values, Type targetType, object parameter, CultureInfo culture)
    {
      bool result = ((int)values[0] != SettingsModel.TaxOfficeId && !(bool)values[1]);
      return (parameter != null) ? !result : result;
    }

    public object[] ConvertBack(object value, Type[] targetTypes, object parameter, CultureInfo culture)
    {
      throw new NotImplementedException();
    }
  }



}
