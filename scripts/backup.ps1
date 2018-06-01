# 실행 권한 풀기 : Set-ExecutionPolicy Unrestricted
# 현재 유저의 실행 권한 풀기 : Set-ExecutionPolicy -Scope CurrentUser Unrestricted

Write-Output 'Backup Begin.'

# 도커 컴포즈 실행
Write-Output 'docker-compose up.'
docker-compose up -d
Start-Sleep -Seconds 5

$BackupRootPath = "Backups"
$CurrentDate = $(get-date -f yyyy-MM-dd-HHmmss)
$BackupPath = "$BackupRootPath/$CurrentDate"
$WikiContainerId = (docker ps -aqf name=confluence)
$DBContainerId = (docker ps -aqf name=postgres)

# 정보 표시
Write-Output 'BackupPath=$BackupPath'
Write-Output 'DBContainerId=$DBContainerId'
Write-Output 'WikiContainerId=$WikiContainerId'

# 백업 폴더 생성
Write-Output 'backup db.'
New-Item -ItemType Directory -Force -Path $BackupPath | Out-Null

# 디비 백업
docker exec -t $DBContainerId pg_dumpall -c -U postgres > $BackupPath/db.sql

# 도커 컴포즈 중지
Write-Output 'docker-compose stop.'
docker-compose stop

# 컨플루언스 백업
Write-Output 'backup confluence.'
Compress-Archive -Path confluencedata -DestinationPath $BackupPath\confluence.zip

# 도커 컴포즈 실행
Write-Output 'docker-compose up.'
docker-compose up -d

# 백업파일들 전체 압축
Write-Output 'zip all backups.'
Compress-Archive -Path $BackupPath -DestinationPath $BackupRootPath\$CurrentDate.zip

# 임시 파일 제거
Write-Output 'remove temp files.'
Remove-Item $BackupPath -Force -Recurse

Write-Output 'Backup Finished.'
