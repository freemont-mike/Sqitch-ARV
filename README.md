# Sqitch-ARV
Automatic revert and verify script generator for Sqitch (https://sqitch.org/). Sqitch is a database change management application. It currently supports PostgreSQL 8.4+, SQLite 3.7.11+, MySQL 5.0+, Oracle 10g+, Firebird 2.0+, Vertica 6.0+, Exasol 6.0+ and Snowflake.

The Sqitch-ARV automatically generates revert and verify scripts based on the contents of your deploy script. It uses regular expressions to match the type of scripts used in your deploy statements and compares it to pre-defined statements in the included Dictionary. In addition, it connects to the DB defined in your sqitch.conf and fetches properties related to your deploy statements. This is done to avoid the tiresome task of writing revert and verify script for your every new deployment while using sqitch. 

## Current Support
- **Powershell Version**: 5.1
- **PostgreSQL Version**: 9.3+

## Using the ARV Generator
- Copy ARV.ps1 and PostgreSQLDictionary.csv to your sqitch directory on the same path of your sqitch.conf as seen in the sample structure on this repository.
- After you `sqitch add` and write the scripts on your deploy files, run this command in the CLI on the sqitch directory:
    `powershell ARV.ps1 sample/test/dev`
_ARV.ps1 folder/recent-deployment-file/environment_

If you are working on windows, you may need to enable running scripts on the system. There are two ways to do this:
1. Open powershell as administrator and run: `powershell Set-ExecutionPolicy RemoteSigned`
   (To return the policy back to default, if it's a one time use do: `powershell Set-ExecutionPolicy Restricted`)
2. `powershell-ExecutionPolicy Bypass -File ARV.ps1 sample/test/dev`
   (This helps by pass the current file in our script)


