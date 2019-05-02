Describe Get-DiskInfo {

    Mock Get-Date {
        return "201808121230"
    } -ParameterFilter {$format -eq "yyyyMMddhhmm"}

    Mock Get-Volume {

        $result = [pscustomobject]@{
            DriveLetter    = "C"
            Size           = 512GB
            SizeRemaining  = 99.12345GB
            HealthStatus   = "Healthy"
            PSComputername = "bttleuswsnp01"
        }
        return $result
    } -ParameterFilter {$CimSession -match "bttleuswsnp01"}

    Mock Get-Volume {

        $result = [pscustomobject]@{
            DriveLetter    = "C"
            Size           = 256GB
            SizeRemaining  = 128GB
            HealthStatus   = "Healthy"
            PSComputername = "bttleuswsnp02"
        }
        return $result
    } -ParameterFilter {$CimSession -match "bttleuswsnp02"}
    Mock Get-Volume {

        $result = [pscustomobject]@{
            DriveLetter    = "D"
            Size           = 512GB
            SizeRemaining  = 100GB
            HealthStatus   = "Healthy"
            PSComputername = "bttleuswsnp01"
        }
        return $result
    } -ParameterFilter {$CimSession -match "bttleuswsnp01" -AND $Drive -eq 'D'}
    Mock Get-Volume {
        #write-host "Offline mock" -ForegroundColor magenta
        write-Error "Failed to connect to Offline"
    } -parameterfilter {$cimsession -match "Offline"}

    Context "Input" {

        $cmd = Get-Command -Name Get-DiskInfo
        $attributes = $cmd.parameters["computername"].attributes | where-object {$_.typeid.name -eq 'parameterattribute'}
        It "Should have a mandatory parameter for the computername" {
            $attributes.Mandatory | Should Be $True
        }

        It "Should accept parameter input for the computername" {
            {Get-Diskinfo -Computername bttleuswsnp01} | Should beTrue
        }

        It "Should accept multiple computernames from the parameter" {
            $r = Get-Diskinfo -Computername bttleuswsnp01, bttleuswsnp02
            $r.count | Should be 2
        }
        It "Should accept positional parameter input for the computername" {
            $attributes.position | Should be 0
            {get-Diskinfo bttleuswsnp01} | Should beTrue
        }

        It "Should accept pipeline input by property name for the computername" {
            $attributes.ValueFromPipelinebyPropertyName | Should Be $True
            {[pscustomobject]@{Computername = "bttleuswsnp01"}  | Get-Diskinfo } | Should beTrue
            $r = [pscustomobject]@{Computername = "bttleuswsnp01"}, [pscustomobject]@{Computername = "bttleuswsnp01"}  | Get-Diskinfo
            $r.count  | Should be 2
        }

        It "Should accept pipeline input by value for the computername" {
            $attributes.ValueFromPipeline | Should Be $True
            {"bttleuswsnp01" | Get-DiskInfo} | Should BeTrue
        }

        It "Should only accept drives between C and G" {
            $driveparam = $cmd.parameters["drive"].attributes | where-object {$_.typeid.name -eq 'ValidatePatternAttribute'}
            $driveparam.RegexPattern | Should match "c-g"
            {Get-DiskInfo -computername bttleuswsnp01 -Drive D} | Should BeTrue
            {Get-DiskInfo -computername bttleuswsnp01 -Drive H} | Should Throw

        }

        It "Should fail with a bad computername" {
            $r = Get-Diskinfo -Computername "offline" -WarningAction "silentlyContinue"
            $r | Should BeFalse
        }

    }
    Context "Output" {

        $test = Get-DiskInfo -computername bttleuswsnp01

        It "Should call Get-Volume" {
            Assert-MockCalled 'Get-Volume'
        }
        It "Should write an object to the pipeline with the computername bttleuswsnp01" {
            $test.computername | Should Be "bttleuswsnp01"
        }

        It "Should write an object to the pipeline with a FreeGB value of a [double] for bttleuswsnp01" {
            $test.freeGB | Should BeOfType "double"
        }

        It "Should write an object to the pipeline with a SizeGB value of an [int] for bttleuswsnp01" {
            $test.SizeGB | Should BeofType "int"
            $test.SizeGB | Should Be 512
        }

        It "Should write an object to the pipeline with a PctFree value of an [int] for bttleuswsnp01" {
            $test.PctFree | Should BeOfType "int"
            $test.PctFree | Should Be 19
        }

        It "should write an object to the pipeline with a HealthStatus value of 'Healthy' for bttleuswsnp01" {
            $test.HealthStatus | Should Be "Healthy"
        }
        It "bttleuswsnp01 should respond to a connection test"{
            (test-netconnection -computername bttleuswsnp01 -port 80 | select -ExpandProperty TcpTestSucceeded) | Should Be $True
        }
        It "bttleuswsnp02 should respond to a connection test"{
            (test-netconnection -computername bttleuswsnp02 -port 80 | select -ExpandProperty TcpTestSucceeded) | Should Be $True
        }
        It "bttleuswsnp01 should have IIS installed"{
            Get-WindowsFeature -ComputerName "bttleuswsnp01" -name "Web-Server" | Should Be $True
        }
        It "bttleuswsnp02 should have IIS installed"{
            Get-WindowsFeature -ComputerName "bttleuswsnp02" -name "Web-Server" | Should Be $True
        }
    }
    Context "Error Handling" {

        It "Should fail with a bad folder for the log" {
            {Get-DiskInfo -Computername foo -LogPath TestDrive:\foo -ErrorAction stop } | Should Throw
        }
        It "Should create an error log with a name that iudes YearMonthDayHourMinute" {
            Get-DiskInfo -Computername Offline -LogPath TestDrive: -WarningVariable w -WarningAction SilentlyContinue
            $log = Get-Item TestDrive:\*.txt

            $w | Should Be $true
            $w | Should Match "201808121230_DiskInfo_Errors"
            $log.length | Should BeGreaterThan 0
            $log.name | Should Match "201808121230"
        }
    }

}
