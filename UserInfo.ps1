#Created by Keagan Whitelaw
#Created on  29Apr2021

function UserInfo 
{
    #making UserInfo a cmdlet for powershell
    [CmdletBinding()]
    #setting a parameter for the cmdlet UserInfo $uName 
    param
     (
         [Parameter()]
         [string[]]$uName 
     )
    #setting what the function will be doing with the paramter
    #this case putting $uName to get get user information
    net user $uName /domain
    #returns full name, comments, active/expire,password set/expire/changeable
    #whether or not user account is locked, and last login
    #also will return global groups
}


 #add assembly to run a WFP xaml file
 Add-Type -AssemblyName PresentationFramework
  #if you are going to store the xml file elsewhere update the $xmlFile to equal the location\filename
$xamlFile = "MainWindow.xaml"
 #get content of xaml file
 $inputXML = Get-Content $xamlFile -Raw
 $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*','<Window'
 [XML]$XAML = $inputXML
 #setup reader to read the xaml file
 $reader = (New-Object System.Xml.XmlNodeReader $xaml)
 try{
    $window = [Windows.Markup.XamlReader]::Load($reader)
    }catch {
    Write-Warning $_.Exception
    throw
    }
$xaml.SelectNodes("//*[@Name]") | ForEach-Object{
    try{
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    }catch{
        throw
    }
}
#gets all elements from the windows presentation from and displays it
Get-Variable var_*

#function that that will populate the result area
function SearchUser{
    
    #if else to see if anything was put into the text box for username. 
    if($var_txtUName.Text -eq ""){
        $var_txtResults.Text = "You must enter a username."
    }else {
     #try and catch for when the user does not exist or there is a typo
         try {
            ($results = UserInfo $var_txtUName.Text)
            #take results and split into array off new lines and ignore empty entries
            $uArray = $results.Split([System.Environment]::NewLine,[StringSplitOptions]::RemoveEmptyEntries)
            
            #feed array into the labels to be displayed
            $var_lblfName.Content = $uArray[2]        
            $var_lblaActive.Content = $uArray[6]
            $var_lblPassls.Content = $uArray[8]
            $var_lblPassex.Content = $uArray[9]
            $var_lblLastLog.Content = $uArray[17]


    }catch {
     $var_txtResults.Text = "Please confirm username is correct."
        }
    }

}
#function to clear the result area back to default
function ResetSearch{
            
            $var_lblfName.Content = "Full Name:"           
            $var_lblaActive.Content = "Account Active:"
            $var_lblPassls.Content = "Password Last Set:"
            $var_lblPassex.Content = "Password Expires:"
            $var_lblLastLog.Content = "Last Login:"

}
#called when the go button is clicked
$var_btnGo.Add_Click({
    ResetSearch
    SearchUser

})
#called when the enter key is pushed while in the textbox
$var_txtUName.Add_KeyDown({
    
    if($_.Key -eq "Enter"){
        ResetSearch
        SearchUser
    }


})
#called when the reset button is clicked
$var_btnReset.Add_Click({
      $var_txtUName.Text=""
      ResetSearch

})
#shows the windows presentation form to the user
$Null = $window.ShowDialog()
