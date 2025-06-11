
# Set the connection details
$serverName = "server.1dc.com"  # Your SQL Server instance name
$databaseName = "staging"
$queryTemplate = @"
SELECT p.name AS StoredProcedureName, m.definition
FROM sys.objects p
JOIN sys.sql_modules m ON p.object_id = m.object_id
WHERE p.type = 'P' AND p.name = '{0}'
"@

$inputFile = "C:\Users\FCXP1SB\OneDrive - Fiserv Corp\Documents\migration\sp_names.txt"
$outputDirectory = "C:\Users\FCXP1SB\OneDrive - Fiserv Corp\Documents\migration\final"
$spNames = Get-Content -Path $inputFile

# Loop through stored procedure names
foreach ($spName in $spNames) {
    $query = [string]::Format($queryTemplate, $spName)

    $outputFile = Join-Path -Path $outputDirectory -ChildPath "$spName.sql"
    $connectionString = "Server=$serverName;Database=$databaseName;Integrated Security=True;"
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $connection.Open()

    # Create a SQL data reader to fetch the result for this stored procedure
    $reader = $command.ExecuteReader()

    # Write the results to the file in .sql format
    while ($reader.Read()) {
        $outputLine = "-- Stored Procedure: $spName`r`n" + $reader["definition"]
        $outputLine | Out-File -FilePath $outputFile -Append
    }

    # Close the connection
    $connection.Close()
}
