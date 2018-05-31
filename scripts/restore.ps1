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
Get-Content $BackupPath/db.sql | docker exec -i $DBContainerId psql -U postgres

# 컨플루언스 복원
Copy-Item -Path $BackupPath\confluence.tgz -Destination ./temp/confluence.tgz
docker exec -t $WikiContainerId tar xzvf /tmp/backup/confluence.tgz --strip=1 -C /var/atlassian/confluence
Remove-Item ./temp/confluence.tgz