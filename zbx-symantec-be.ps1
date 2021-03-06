function Convert-Encoding
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true)]
        $InputObject,

        [Parameter(Position = 0)]
        [String]
        $From,

        [Parameter(Position = 1)]
        [String]
        $To
    )

    begin
    {
        if ($From)
        {
            $EncodingFrom = [System.Text.Encoding]::GetEncoding($From)
        }
        else
        {
            $EncodingFrom = $OutputEncoding
        }

        if ($To)
        {
            $EncodingTo = [System.Text.Encoding]::GetEncoding($To)
        }
        else
        {
            $EncodingTo = $OutputEncoding
        }

        $Content = @()
    }

    process
    {
        $Content += $InputObject
    }

    end
    {
        $Content = $Content | Out-String
        $Bytes = $EncodingTo.GetBytes($Content)
        $Bytes = [System.Text.Encoding]::Convert($EncodingFrom, $EncodingTo, $Bytes)
        $Content = $EncodingTo.GetString($Bytes)

        return $Content
    }
}

Import-Module BEMCLI

$OPERATION = [string]$args[0]
$JOBNAME = [string]$args[1]

Switch($OPERATION) {
    "discovery" {   
     
        $jobsched = Get-BEJob -Jobtype Backup

        $i = 1
        write-host "{"
        write-host " `"data`":["
        write-host
        foreach($job in $jobsched){

            if($i -lt $jobsched.count){
                $line = "  { `"{#JOBNAME}`":`"" + $job.Name + "`"   }," | Convert-Encoding CP866 UTF-8
            }
            else {
                $line = "  { `"{#JOBNAME}`":`"" + $job.Name + "`"   }" | Convert-Encoding CP866 UTF-8
            }      
            $i++

            write-host $line 
        }
        write-host
        write-host " ]"
        write-host "}"
        write-host

    }
    "status" {
        $status = Get-BEJobHistory -Name "$JOBNAME" -JobType "Backup" | Select -last 1
        $state = $status.JobStatus
        $state = $state -replace 'Error','0' -replace 'Warning','1' -replace 'SucceededWithExceptions','2' -replace 'Succeeded','2' -replace 'None','2' -replace 'idle','3' -Replace 'Canceled','4' -Replace 'Missed','5' -Replace 'Active','6'
        write-host $state
    }
    "lastendtime" {
        $job = Get-BEJobHistory -Name "$JOBNAME" -JobType "Backup"| Select -last 1
        $job_Result = $job.EndTime
        $date = get-date -date "01/01/1970"
        # минус 3часа (10800 секунд) для корректирования временной зоны 
        $job_Result1 = (New-TimeSpan -Start $date -end $job_Result).TotalSeconds - 10800
        Write-host ($job_Result1)
    }
    "tasktype" {
        $job = Get-BEJob -Name "$JOBNAME"
        $job_type = $job.TaskType
        $job_type = $job_type -replace 'Full','0' -replace 'Differential','1' -replace 'Incremental','2' 
        Write-host ($job_type)
    }
    "libraryspace" {
        $device = Get-BEStorageDevice | where {$_.StorageType -eq "RoboticLibraryDevice"} | select Name
        $media = Get-BEMedia | Where {$_.LocationName -eq $device.Name} | measure AvailableCapacityBytes -Sum
        write-host $media.Sum
    }
}

