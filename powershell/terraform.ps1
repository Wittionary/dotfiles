# Terraform alias
New-Alias -Name "tf" -Value "terraform.exe" -Description "Saves on 'terraform' keystrokes" -ErrorAction SilentlyContinue

# Terragrunt alias
New-Alias -Name "tg" -Value "terragrunt.exe" -Description "Saves on 'terragrunt' keystrokes" -ErrorAction SilentlyContinue
# May add shortcuts (like in git.ps1) later: e.g. tf pa (plan apply)