#!/data/data/com.termux/files/usr/bin/bash

# ========== 基础配置（必改！） ==========
PROJECT_DIR=~/MemorySystem  # 本地GitHub仓库路径（如 ~/xxx）
REMOTE_BRANCH=main          # GitHub远程分支（如main/master）
COMMIT_MSG_PREFIX="Auto backup"  # Git提交前缀

# ========== 自动发现需备份的文件（Git追踪的文件） ==========
BACKUP_TARGETS=()  # 初始化空数组
# 遍历Git追踪的文件，加入备份列表
while IFS= read -r file; do
    BACKUP_TARGETS+=("$file")
done < <(git -C "$PROJECT_DIR" ls-files)  # -C 进入仓库目录执行git命令

# ========== 空值保护：仓库空的时候，备份整个目录 ==========
if [ ${#BACKUP_TARGETS[@]} -eq 0 ]; then
    BACKUP_TARGETS=(".")  # 备份当前目录（仓库根目录）
fi

# ========== 生成时间戳 & 打包 ==========
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BACKUP_DIR="$PROJECT_DIR/backups"
BACKUP_FILE="$BACKUP_DIR/backup_${TIMESTAMP}.tar.gz"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 打包（排除备份目录自身，避免循环）
tar -czvf "$BACKUP_FILE" \
    --exclude="$BACKUP_DIR" \
    "${BACKUP_TARGETS[@]}"  # 展开数组，备份所有Git追踪的文件

# 检查打包是否成功（非0则失败）
if [ $? -ne 0 ]; then
    echo "[$TIMESTAMP] 打包失败！请检查文件权限。"
    exit 1
fi

# ========== Git 流程（仅在打包成功后执行） ==========
cd "$PROJECT_DIR" || exit 1  # 进入仓库目录

# 1. 拉取远程更新
git pull origin "$REMOTE_BRANCH"

# 2. 添加备份文件到暂存区（虽然在.gitignore，但记录变更）
git add "$BACKUP_FILE"

# 3. 提交到本地仓库（仅当有变更时提交）
git commit -m "${COMMIT_MSG_PREFIX}: ${TIMESTAMP}"

# 4. 推送到远程仓库（重试机制）
git push origin "$REMOTE_BRANCH" || {
    echo "第一次推送失败，重试..."
    git push origin "$REMOTE_BRANCH"
}

# ========== 记录日志 ==========
echo "[$TIMESTAMP] 备份完成：$BACKUP_FILE" >> "$PROJECT_DIR/backup.log"
