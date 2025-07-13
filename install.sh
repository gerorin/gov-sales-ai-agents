#!/bin/bash

# 🏛️ 自治体営業支援AIエージェントシステム
# ワンクリックインストールスクリプト

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
                                                   
  自治体営業支援AIエージェントシステム インストーラー
  
EOF

echo -e "${BLUE}=================================================${NC}"
echo -e "${GREEN}原課対応型・証明機能付き営業支援システム${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# 必要なコマンドの確認
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 が見つかりません${NC}"
        echo "  インストール: $2"
        return 1
    else
        echo -e "${GREEN}✅ $1 が利用可能です${NC}"
        return 0
    fi
}

echo -e "${YELLOW}1. 依存関係チェック${NC}"
echo "------------------------"

MISSING_DEPS=0

check_command "tmux" "sudo apt-get install tmux" || MISSING_DEPS=1
check_command "git" "sudo apt-get install git" || MISSING_DEPS=1
check_command "python3" "sudo apt-get install python3" || MISSING_DEPS=1
check_command "pip3" "sudo apt-get install python3-pip" || MISSING_DEPS=1
check_command "sqlite3" "sudo apt-get install sqlite3" || MISSING_DEPS=1

if [ $MISSING_DEPS -eq 1 ]; then
    echo ""
    echo -e "${RED}必要なコマンドが不足しています。上記のインストールコマンドを実行してください。${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}2. バージョン選択${NC}"
echo "------------------------"
echo "1) v1.0 - 基本版（4エージェント）"
echo "2) v2.0 - 証明機能強化版（8エージェント）※推奨"
echo ""
read -p "バージョンを選択してください (1 or 2): " VERSION_CHOICE

if [ "$VERSION_CHOICE" == "2" ]; then
    VERSION="v2.0"
    SETUP_SCRIPT="setup-v2.sh"
    echo -e "${GREEN}v2.0（証明機能強化版）を選択しました${NC}"
else
    VERSION="v1.0"
    SETUP_SCRIPT="setup.sh"
    echo -e "${GREEN}v1.0（基本版）を選択しました${NC}"
fi

echo ""
echo -e "${YELLOW}3. ディレクトリ構造作成${NC}"
echo "------------------------"

# 必要なディレクトリを作成
mkdir -p .claude
mkdir -p instructions
mkdir -p templates
mkdir -p tools
mkdir -p config
mkdir -p data/{plans,minutes,budgets,analysis,evidence,structured}
mkdir -p logs/{processing,quality,audit}
mkdir -p reports
mkdir -p quality
mkdir -p tmp

echo -e "${GREEN}✅ ディレクトリ構造を作成しました${NC}"

echo ""
echo -e "${YELLOW}4. 実行権限の付与${NC}"
echo "------------------------"

# スクリプトに実行権限を付与
chmod +x setup.sh 2>/dev/null || true
chmod +x setup-v2.sh 2>/dev/null || true
chmod +x agent-send.sh 2>/dev/null || true
chmod +x install.sh 2>/dev/null || true

echo -e "${GREEN}✅ 実行権限を付与しました${NC}"

if [ "$VERSION" == "v2.0" ]; then
    echo ""
    echo -e "${YELLOW}5. Python環境セットアップ${NC}"
    echo "------------------------"
    
    if [ -f "requirements.txt" ]; then
        echo "Python仮想環境を作成しますか？"
        read -p "(既存環境を使用する場合はNを入力) [Y/n]: " CREATE_VENV
        
        if [ "$CREATE_VENV" != "n" ] && [ "$CREATE_VENV" != "N" ]; then
            echo "仮想環境を作成中..."
            python3 -m venv venv
            echo -e "${GREEN}✅ 仮想環境を作成しました${NC}"
            echo ""
            echo -e "${YELLOW}以下のコマンドで仮想環境を有効化してください：${NC}"
            echo "source venv/bin/activate  # Linux/Mac"
            echo "venv\\Scripts\\activate   # Windows"
            echo ""
            echo "その後、以下を実行："
            echo "pip install -r requirements.txt"
        fi
    else
        echo -e "${YELLOW}⚠️  requirements.txt が見つかりません${NC}"
    fi
fi

echo ""
echo -e "${YELLOW}6. セットアップ実行${NC}"
echo "------------------------"
echo "tmux環境を構築しますか？"
read -p "（既存のtmuxセッションがある場合は削除されます）[Y/n]: " RUN_SETUP

if [ "$RUN_SETUP" != "n" ] && [ "$RUN_SETUP" != "N" ]; then
    echo -e "${BLUE}セットアップを実行中...${NC}"
    ./$SETUP_SCRIPT
else
    echo "セットアップをスキップしました"
fi

echo ""
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}🎉 インストールが完了しました！${NC}"
echo -e "${GREEN}=================================================${NC}"
echo ""
echo -e "${YELLOW}次のステップ：${NC}"
echo ""
echo "1. tmuxセッションにアタッチ:"
echo "   ${BLUE}tmux attach-session -t multiagent${NC}  # 別ターミナルで"
echo "   ${BLUE}tmux attach-session -t president${NC}"
echo ""
echo "2. Claude Codeを起動:"
if [ "$VERSION" == "v2.0" ]; then
    echo "   ${BLUE}for i in {0..7}; do tmux send-keys -t multiagent:0.\$i 'claude' C-m; done${NC}"
else
    echo "   ${BLUE}for i in {0..3}; do tmux send-keys -t multiagent:0.\$i 'claude' C-m; done${NC}"
fi
echo "   ${BLUE}tmux send-keys -t president 'claude' C-m${NC}"
echo ""
echo "3. 分析を開始:"
echo "   PRESIDENTセッションで："
if [ "$VERSION" == "v2.0" ]; then
    echo "   ${BLUE}柏市の総合計画を証明付きで分析し、営業提案を自動生成してください${NC}"
else
    echo "   ${BLUE}あなたはpresidentです。柏市の総合計画を分析して営業戦略を立案してください${NC}"
fi
echo ""
echo -e "${GREEN}📚 詳細なドキュメント: README.md${NC}"
echo -e "${GREEN}🤝 サポート: https://github.com/[your-username]/gov-sales-ai-agents${NC}"
echo ""
echo -e "${BLUE}自治体営業を科学する準備が整いました！🏛️🤖✨${NC}"