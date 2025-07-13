#!/bin/bash

# 🏛️ 自治体営業支援AIエージェントシステム
# 自動ダウンロード＆セットアップスクリプト

set -e

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ロゴ表示
clear
cat << "EOF"
    ____                 _____       __          
   / ___| _____   __    / ____|__ _ | | ___  ___ 
  | |  _ / _ \ \ / /____\___ \/ _` || |/ _ \/ __|
  | |_| | (_) \ V /_____|___) | (_| || |  __/\__ \
   \____|\___/ \_/      |____/ \__,_||_|\___||___/
                                                   
  自治体営業支援AIエージェントシステム 
  自動ダウンロード＆セットアップ
  
EOF

echo -e "${BLUE}=================================================${NC}"
echo -e "${GREEN}全ファイルを自動ダウンロードしてセットアップします${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# GitHubリポジトリ情報
GITHUB_USER="your-username"  # ここを実際のユーザー名に変更
GITHUB_REPO="gov-sales-ai-agents"
BRANCH="main"

# 一時ディレクトリ作成
TEMP_DIR=$(mktemp -d)
echo -e "${YELLOW}作業ディレクトリ: $TEMP_DIR${NC}"

# プロジェクトディレクトリ
PROJECT_DIR="gov-sales-ai-agents"

# ダウンロード方法の選択
echo ""
echo "ダウンロード方法を選択してください："
echo "1) GitHub リポジトリから直接ダウンロード（推奨）"
echo "2) 個別ファイルをダウンロード（GitHub未使用の場合）"
echo ""
read -p "選択 (1 or 2): " DOWNLOAD_METHOD

if [ "$DOWNLOAD_METHOD" == "1" ]; then
    # GitHubからダウンロード
    echo -e "${YELLOW}GitHubからダウンロード中...${NC}"
    
    # gitが利用可能か確認
    if command -v git &> /dev/null; then
        git clone "https://github.com/${GITHUB_USER}/${GITHUB_REPO}.git" "$PROJECT_DIR"
        cd "$PROJECT_DIR"
    else
        # gitがない場合はzipでダウンロード
        echo -e "${YELLOW}gitが見つかりません。zipファイルでダウンロードします...${NC}"
        curl -L "https://github.com/${GITHUB_USER}/${GITHUB_REPO}/archive/refs/heads/${BRANCH}.zip" -o "${TEMP_DIR}/repo.zip"
        unzip "${TEMP_DIR}/repo.zip" -d "${TEMP_DIR}"
        mv "${TEMP_DIR}/${GITHUB_REPO}-${BRANCH}" "$PROJECT_DIR"
        cd "$PROJECT_DIR"
    fi
    
else
    # 個別ファイルダウンロード
    echo -e "${YELLOW}個別ファイルをダウンロード中...${NC}"
    
    # プロジェクトディレクトリ作成
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"
    
    # ディレクトリ構造作成
    mkdir -p .claude instructions templates tools config
    mkdir -p data/{plans,minutes,budgets,analysis,evidence,structured}
    mkdir -p logs/{processing,quality,audit}
    mkdir -p reports quality tmp
    
    # ファイルリスト定義
    declare -A files=(
        # ルートディレクトリ
        ["README.md"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/README.md"
        ["README-en.md"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/README-en.md"
        ["CLAUDE.md"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/CLAUDE.md"
        ["CLAUDE-v2.md"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/CLAUDE-v2.md"
        ["LICENSE"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/LICENSE"
        ["setup.sh"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/setup.sh"
        ["setup-v2.sh"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/setup-v2.sh"
        ["agent-send.sh"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/agent-send.sh"
        ["install.sh"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/install.sh"
        ["requirements.txt"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/requirements.txt"
        [".gitignore"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/.gitignore"
        
        # .claude/
        [".claude/settings.local.json"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/.claude/settings.local.json"
        
        # instructions/
        ["instructions/president.md"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/instructions/president.md"
        ["instructions/director.md"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/instructions/director.md"
        ["instructions/dx_analyst.md"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/instructions/dx_analyst.md"
        ["instructions/admin_analyst.md"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/instructions/admin_analyst.md"
        ["instructions/doc_scanner.md"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/instructions/doc_scanner.md"
        ["instructions/evidence_tracker.md"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/instructions/evidence_tracker.md"
        ["instructions/auto_processor.md"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/instructions/auto_processor.md"
        ["instructions/quality_checker.md"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/instructions/quality_checker.md"
        
        # templates/
        ["templates/sales_report.md"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/templates/sales_report.md"
        
        # tools/
        ["tools/evidence_dashboard.py"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/tools/evidence_dashboard.py"
        
        # config/
        ["config/quality_standards.yaml"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/config/quality_standards.yaml"
        ["config/automation_config.json"]="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/config/automation_config.json"
    )
    
    # ファイルダウンロード
    TOTAL=${#files[@]}
    CURRENT=0
    
    for file in "${!files[@]}"; do
        CURRENT=$((CURRENT + 1))
        echo -e "${BLUE}[$CURRENT/$TOTAL]${NC} ダウンロード中: $file"
        
        # curlまたはwgetでダウンロード
        if command -v curl &> /dev/null; then
            curl -sL "${files[$file]}" -o "$file" || echo -e "${RED}失敗: $file${NC}"
        elif command -v wget &> /dev/null; then
            wget -q "${files[$file]}" -O "$file" || echo -e "${RED}失敗: $file${NC}"
        else
            echo -e "${RED}curlまたはwgetが必要です${NC}"
            exit 1
        fi
    done
fi

# 実行権限付与
echo -e "${YELLOW}実行権限を付与中...${NC}"
chmod +x setup.sh setup-v2.sh agent-send.sh install.sh 2>/dev/null

# ダウンロード完了確認
echo ""
echo -e "${GREEN}✅ ダウンロード完了！${NC}"
echo ""

# ファイル一覧表示
echo -e "${YELLOW}ダウンロードされたファイル:${NC}"
find . -type f -name "*.md" -o -name "*.sh" -o -name "*.json" -o -name "*.yaml" -o -name "*.py" | sort

# セットアップ実行確認
echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${GREEN}セットアップを開始しますか？${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""
echo "1) v1.0をセットアップ（基本版 - 4エージェント）"
echo "2) v2.0をセットアップ（証明機能強化版 - 8エージェント）※推奨"
echo "3) 後で手動でセットアップ"
echo ""
read -p "選択 (1, 2, or 3): " SETUP_CHOICE

case $SETUP_CHOICE in
    1)
        echo -e "${YELLOW}v1.0のセットアップを開始します...${NC}"
        ./setup.sh
        ;;
    2)
        echo -e "${YELLOW}v2.0のセットアップを開始します...${NC}"
        
        # Python環境チェック
        if command -v python3 &> /dev/null; then
            echo -e "${GREEN}Python3が見つかりました${NC}"
            echo "Python仮想環境を作成しますか？ [Y/n]: "
            read -p "" CREATE_VENV
            
            if [ "$CREATE_VENV" != "n" ] && [ "$CREATE_VENV" != "N" ]; then
                python3 -m venv venv
                echo -e "${GREEN}✅ 仮想環境を作成しました${NC}"
                echo ""
                echo -e "${YELLOW}仮想環境を有効化してパッケージをインストールしてください：${NC}"
                echo "source venv/bin/activate  # Linux/Mac"
                echo "venv\\Scripts\\activate   # Windows"
                echo "pip install -r requirements.txt"
                echo ""
            fi
        fi
        
        ./setup-v2.sh
        ;;
    3)
        echo -e "${YELLOW}手動セットアップを選択しました${NC}"
        ;;
    *)
        echo -e "${RED}無効な選択です${NC}"
        ;;
esac

# クリーンアップ
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}🎉 完了しました！${NC}"
echo -e "${GREEN}=================================================${NC}"
echo ""

if [ "$SETUP_CHOICE" != "3" ]; then
    echo -e "${YELLOW}次のステップ：${NC}"
    echo ""
    echo "1. tmuxセッションにアタッチ:"
    echo "   ${BLUE}tmux attach-session -t multiagent${NC}"
    echo "   ${BLUE}tmux attach-session -t president${NC}"
    echo ""
    echo "2. 各ペインでClaude Codeを起動"
    echo ""
    echo "3. 分析を開始！"
fi

echo ""
echo -e "${BLUE}プロジェクトディレクトリ: $(pwd)${NC}"
echo -e "${GREEN}📚 詳細: README.md を参照してください${NC}"
echo ""
echo -e "${BLUE}🏛️ 自治体営業を科学する準備が整いました！ 🤖✨${NC}"