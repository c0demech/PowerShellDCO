<#
  .SYNOPSIS
    Computes cryptographic hash of files under the specified path(s)
    This script was developed to support powershell v2 and above
    which means it does not use Get-FileHash cmdlet which was introduced in
    powershell v4. It should be noted that we can only compute hashes
    for filesizes <= 2GB

  .DESCRIPTION

  .OUTPUTS

  .NOTES
    Date:     28 AUG 18
    Version:  1.0
    Authors:  Michael Edie @c0demech
 #>
# regular expression extension list
# Be deliberate about how many extensions you
# add to this variable. Scales O(log n)
## examples: exe,dll,vbs,msi,bat
$huntext   = "exe|dll"
$huntpaths = @(
 "C:\Windows\System32\",
 "C:\Windows\",
 "C:\Users\"
)
# change this to md5 or sha1
# some systems with FIPS restrictions will not allow md5
$hashtype = "sha1"

#$filesList = New-Object System.Collections.Generic.List[System.String]
# computes the specified hashtype and removes the dashes
# in between the hexadecimal characters
function DoComputeHash($hashtype, [string]$file){
  $fhash = [System.BitConverter]::ToString($hashtype.ComputeHash([System.IO.File]::ReadAllBytes($file)))
  $outp = $fhash -replace "-",""
  return $outp + " | " + $file
}

# currently supports MD5 and SHA1
function GetFileHash([string]$file, [string]$hashtype){
# case insensitive comparison
  if ($hashtype.Equals("sha1")){
    $sha1 = New-Object System.Security.Cryptography.SHA1CryptoServiceProvider
    return DoComputeHash $sha1 $file
  }
  elseif ($hashtype.Equals("md5")){
    $md5 = New-Object System.Security.Cryptography.MD5CryptoServiceProvider
    return DoComputeHash $md5 $file
  }
}
## Execution starts here.
# This block of code is O(log n). Be careful how many file extension
# you put in the $huntex variable. 
foreach ($path in $huntpaths){
  $huntfiles = Get-ChildItem -Path $path |
    Where-Object {! $_.PSIsContainer} |
    Where-Object -FilterScript {$_.Name -match $huntext} |
    Select-Object FullName
    # Remove for production. Consider using a conditional DEBUG = x
    Write-Host "DEBUG: Total Files Found: "  $huntfiles.count
    Pause
  foreach ($file in $huntfiles){
    # parameters are space separated in powershell
    # using parenthesis will cause a parse error in v2
    GetFileHash $file.FullName $hashtype
  }
}
