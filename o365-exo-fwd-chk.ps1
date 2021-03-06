<# CIAOPS
Script provided as is. Use at own risk. No guarantees or warranty provided.

Description
Script designed to check which email boxes have forwarding options set.
Will check mailbox forwarding, rules set by Outlook client and Sweep setting

Source - https://github.com/directorcia/Office365/blob/master/o365-exo-fwd-chk.ps1

Prerequisites = 1
1. Ensure connection to Exchange Online has already been completed

More scripts available by joining http://www.ciaopspatron.com

#>

## Variables
$systemmessagecolor = "cyan"
$processmessagecolor = "green"
$errormessagecolor = "red"
$warnmessagecolor = "yellow"

## If you have running scripts that don't have a certificate, run this command once to disable that level of security
## set-executionpolicy -executionpolicy bypass -scope currentuser -force

Clear-Host

write-host -foregroundcolor $systemmessagecolor "Script started`n"

## Get all mailboxes
write-host -foregroundcolor $processmessagecolor "Get all mailbox details - Start`n"
$mailboxes = Get-Mailbox -ResultSize Unlimited
write-host -foregroundcolor $processmessagecolor "Get all mailbox details - Finish`n"

## Results
## Green - no forwarding enabled and no forwarding address present
## Yellow - forwarding disabled but forwarding address present
## Red - forwarding enabled

write-host -foregroundcolor $processmessagecolor "Check Exchange Forwards - Start"

foreach ($mailbox in $mailboxes) {
    Write-Host -foregroundColor Gray "Checking rules for $($mailbox.displayname) - $($mailbox.primarysmtpaddress)"
    if ($mailbox.DeliverToMailboxAndForward) { ## if email forwarding is active
        Write-host
        Write-host -foregroundcolor $errormessagecolor "**********" 
        Write-Host -foregroundColor $errormessagecolor "Checking rules for $($mailbox.displayname) - $($mailbox.primarysmtpaddress) - Forwarding = $($mailbox.delivertomailboxandforward)" 
        Write-host -foregroundColor $errormessagecolor "Forwarding address = $($mailbox.forwardingsmtpaddress)" 
        Write-host -foregroundcolor $errormessagecolor "**********" 
        write-host
    }
    else {
        if ($mailbox.forwardingsmtpaddress){ ## if email forward email address has been set
            Write-host
            Write-host -foregroundcolor $warnmessagecolor "**********" 
            Write-Host -foregroundColor $warnmessagecolor "Checking rules for $($mailbox.displayname) - $($mailbox.primarysmtpaddress) - Forwarding = $($mailbox.delivertomailboxandforward)"
            Write-host -foregroundColor $warnmessagecolor "Forwarding address = $($mailbox.forwardingsmtpaddress)"
            Write-host -foregroundcolor $warnmessagecolor "**********"
            write-host
        }
    }
}
write-host -foregroundcolor $processmessagecolor "Check Exchange Forwards - Finish`n"
write-host -foregroundcolor $processmessagecolor "Check Outlook Rule Forwards - Start"

foreach ($mailbox in $mailboxes)
{
  Write-Host -foregroundcolor gray "Checking rules for $($mailbox.displayname) - $($mailbox.primarysmtpaddress)"
  $rules = get-inboxrule -mailbox $mailbox.identity
  foreach ($rule in $rules)
    {
       If ($rule.enabled) {
        if ($rule.forwardto -or $rule.RedirectTo -or $rule.CopyToFolder -or $rule.DeleteMessage -or $rule.ForwardAsAttachmentTo -or $rule.SendTextMessageNotificationTo) { write-host -ForegroundColor $warnmessagecolor "`nSuspect Enabled Rule name -",$rule.name }
        If ($rule.forwardto) { write-host -ForegroundColor $errormessagecolor "Forward to:",$rule.forwardto,"`n" }
        If ($rule.RedirectTo) { write-host -ForegroundColor $errormessagecolor "Redirect to:",$rule.redirectto,"`n" }
        If ($rule.CopyToFolder) { write-host -ForegroundColor $errormessagecolor "Copy to folder:",$rule.copytofolder,"`n" }
        if ($rule.DeleteMessage) { write-host -ForegroundColor $errormessagecolor "Delete message:", $rule.deletemessage,"`n" }
        if ($rule.ForwardAsAttachmentTo) { write-host -ForegroundColor $errormessagecolor "Forward as attachment to:",$rule.forwardasattachmentto, "`n"}
        if ($rule.SendTextMessageNotificationTo) { write-host -ForegroundColor $errormessagecolor "Sent TXT msg to:",$rule.sendtextmessagenotificationto, "`n" }
        }
        else {
        if ($rule.forwardto -or $rule.RedirectTo -or $rule.CopyToFolder -or $rule.DeleteMessage -or $rule.ForwardAsAttachmentTo -or $rule.SendTextMessageNotificationTo) { write-host -ForegroundColor $warnmessagecolor "`nSuspect Disabled Rule name -",$rule.name }
        If ($rule.forwardto) { write-host -ForegroundColor $warnmessagecolor "Forward to:",$rule.forwardto,"`n" }
        If ($rule.RedirectTo) { write-host -ForegroundColor $warnmessagecolor "Redirect to:",$rule.redirectto,"`n" }
        If ($rule.CopyToFolder) { write-host -ForegroundColor $warnmessagecolor "Copy to folder:",$rule.copytofolder,"`n" }
        if ($rule.DeleteMessage) { write-host -ForegroundColor $warnmessagecolor "Delete message:", $rule.deletemessage,"`n" }
        if ($rule.ForwardAsAttachmentTo) { write-host -ForegroundColor $warnmessagecolor "Forward as attachment to:",$rule.forwardasattachmentto,"`n"}
        if ($rule.SendTextMessageNotificationTo) { write-host -ForegroundColor $warnmessagecolor "Sent TXT msg to:",$rule.sendtextmessagenotificationto,"`n" }
        }
    }
}
write-host -foregroundcolor $processmessagecolor "Check Outlook Rule Forwards - Finish`n"
write-host -foregroundcolor $processmessagecolor "Check Sweep Rules - Start"

foreach ($mailbox in $mailboxes)
{
  Write-Host -foregroundcolor gray "Checking rules for $($mailbox.displayname) - $($mailbox.primarysmtpaddress)"
  $rules = get-sweeprule -mailbox $mailbox.identity
  foreach ($rule in $rules) {
    if ($rule.enabled) { ## if Sweep is active
        Write-host -foregroundcolor $errormessagecolor "`n**********" 
        Write-Host -foregroundcolor $errormessagecolor "Sweep rules enabled for $($mailbox.displayname) - $($mailbox.primarysmtpaddress)"
        Write-host -foregroundColor $errormessagecolor "Name = ",$rule.name
        Write-host -foregroundColor $errormessagecolor "Source Folder = ",$rule.sourcefolder 
        write-host -foregroundColor $errormessagecolor "Destination folder = ",$rule.destinationfolder
        Write-host -foregroundColor $errormessagecolor "Keep for days = ",$rule.keepfordays
        Write-host -foregroundcolor $errormessagecolor "**********"
        }
    }
}
write-host -foregroundcolor $processmessagecolor "Check Sweep Rules - Finish`n"
write-host -foregroundcolor $systemmessagecolor "Script complete`n"