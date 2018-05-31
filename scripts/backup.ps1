# 실행 권한 풀기 : Set-ExecutionPolicy Unrestricted
# 현재 유저의 실행 권한 풀기 : Set-ExecutionPolicy -Scope CurrentUser Unrestricted
$BackupPath = "Backups/$(get-date -f yyyy-MM-dd-HHmmss)"
$WikiContainerId = (docker ps -aqf name=confluence)
$DBContainerId = (docker ps -aqf name=postgres)

# 정보 표시
Write-Output DBContainerId=$DBContainerId
Write-Output WikiContainerId=$WikiContainerId

# 백업 폴더 생성
New-Item -ItemType Directory -Force -Path $BackupPath | Out-Null

# 디비 백업
docker exec -t $DBContainerId pg_dumpall -c -U postgres > $BackupPath/db.sql

# 컨플루언스 백업
docker exec -t $WikiContainerId mkdir -p /tmp/backup 
docker exec -t $WikiContainerId tar czf /tmp/backup/confluence.tgz /var/atlassian/confluence
Move-Item -Path ./temp/confluence.tgz -Destination $BackupPath\confluence.tgz