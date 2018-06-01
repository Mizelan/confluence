# 실행 권한 풀기 : Set-ExecutionPolicy Unrestricted
# 현재 유저의 실행 권한 풀기 : Set-ExecutionPolicy -Scope CurrentUser Unrestricted

param([string]$Date)

$BackupPath = "Backups/$Date"
$WikiContainerId = (docker ps -aqf name=confluence)
$DBContainerId = (docker ps -aqf name=postgres)

if([string]::IsNullOrWhitespace($Date) -or
    !(Test-Path -Path $BackupPath )) {
    Write-Output "invalid backup path : $BackupPath"
    Return -1
}

# 정보 표시
Write-Output BackupPath=$BackupPath
Write-Output DBContainerId=$DBContainerId
Write-Output WikiContainerId=$WikiContainerId

# DB 복원
#Get-Content $BackupPath/db.sql | docker exec -i $DBContainerId psql -U postgres

# 컨플루언스 복원
Copy-Item -Force -Path $BackupPath\confluence.tgz -Destination ./temp/confluence.tgz
docker exec -t --privileged $WikiContainerId tar xzvf /tmp/backup/confluence.tgz -C /var/atlassian
Remove-Item ./temp/confluence.tgz