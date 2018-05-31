# 실행 권한 풀기 : Set-ExecutionPolicy Unrestricted
# 현재 유저의 실행 권한 풀기 : Set-ExecutionPolicy -Scope CurrentUser Unrestricted

param([string]$BackupFile, [string]$Container)

$BackupPath = "../DBBackup"
Get-Content $BackupPath/$BackupFile | docker exec -i $Container psql -U postgres