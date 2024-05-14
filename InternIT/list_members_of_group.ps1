# Replace 'YourGroupName' with the name of the Azure AD group you want to retrieve members from
$groupName = 'sales'

# Replace 'C:\Path\To\Output\File.csv' with the path where you want to save the CSV file
$outputPath = 'C:\Users\KnutBA\OneDrive - Netsecurity AS\Dokumenter\InternIT\ListerInternt\sales3.csv'

# Connect to Azure AD
Connect-AzureAD

# Get all members of the specified group
$groupMembers = Get-AzureADGroupMember -ObjectId (Get-AzureADGroup -Filter "DisplayName eq '$groupName'").ObjectId

# Convert the members to a custom PowerShell object with desired properties
$membersList = $groupMembers | ForEach-Object {
    [PSCustomObject]@{
        DisplayName = $_.DisplayName
        #UserPrincipalName = $_.UserPrincipalName
        #ObjectId = $_.ObjectId
        #UserType = $_.UserType
    }
}

# Export the list to CSV
$membersList | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8

Write-Host "Group members have been exported to $outputPath"
