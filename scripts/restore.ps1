# 실행 권한 풀기 : Set-ExecutionPolicy Unrestricted
# 현재 유저의 실행 권한 풀기 : Set-ExecutionPolicy -Scope CurrentUser Unrestricted

param([string]$Date)

$BackupPath = "Backups/$Date.zip"
$WikiContainerId = (docker ps -aqf name=confluence)
$DBContainerId = (docker ps -aqf name=postgres)

if([string]::IsNullOrWhitespace($Date) -or
    !(Test-Path -Path $BackupPath )) {
    Write-Output "invalid backup file : $BackupPath"
    Return -1
}

# 도커 컴포즈 실행
Write-Output 'docker-compose up.'
docker-compose up -d
Start-Sleep -Seconds 5

# 전체 압축 해제
New-Item -ItemType Directory -Force -Path ./temp | Out-Null
Expand-Archive $BackupPath -DestinationPath ./temp

# 정보 표시
Write-Output BackupPath=$BackupPath
Write-Output DBContainerId=$DBContainerId
Write-Output WikiContainerId=$WikiContainerId

# DB 복원
Get-Content ./temp/$Date/db.sql | docker exec -i $DBContainerId psql -U postgres

# 도커 컴포즈 중지
Write-Output 'docker-compose stop.'
docker-compose stop

# 컨플루언스 복원
Remove-Item ./confluencedata -Recurse -Force
Expand-Archive ./temp/$Date/confluence.zip -DestinationPath ./
Remove-Item ./temp/ -Recurse -Force

# 도커 컴포즈 실행
Write-Output 'docker-compose up.'
docker-compose up -d