#!/bin/bash

# 🏛️ 自治体営業支援AIエージェントシステム 環境構築

set -e  # エラー時に停止

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

echo "🏛️ 自治体営業支援AIエージェントシステム 環境構築"
echo "=================================================="
echo ""

# STEP 1: 既存セッションクリーンアップ
log_info "🧹 既存セッションクリーンアップ開始..."

tmux kill-session -t multiagent 2>/dev/null && log_info "multiagentセッション削除完了" || log_info "multiagentセッションは存在しませんでした"
tmux kill-session -t president 2>/dev/null && log_info "presidentセッション削除完了" || log_info "presidentセッションは存在しませんでした"

# データディレクトリ準備
mkdir -p ./data/plans ./data/minutes ./data/budgets ./data/analysis
mkdir -p ./logs ./tmp
rm -f ./tmp/*_done.txt 2>/dev/null && log_info "既存の完了ファイルをクリア" || log_info "完了ファイルは存在しませんでした"

log_success "✅ クリーンアップ完了"
echo ""

# STEP 2: multiagentセッション作成（4ペイン：原課対応構成）
log_info "📺 multiagentセッション作成開始 (4ペイン)..."

# セッション作成
log_info "セッション作成中..."
tmux new-session -d -s multiagent -n "agents"

# セッション作成の確認
if ! tmux has-session -t multiagent 2>/dev/null; then
    echo "❌ エラー: multiagentセッションの作成に失敗しました"
    exit 1
fi

log_info "セッション作成成功"

# 2x2グリッド作成
log_info "グリッド作成中..."

# 水平分割
tmux split-window -h -t "multiagent:agents"

# 左上ペインを選択して垂直分割
tmux select-pane -t "multiagent:agents" -L
tmux split-window -v

# 右上ペインを選択して垂直分割
tmux select-pane -t "multiagent:agents" -R
tmux split-window -v

# ペインの配置確認
PANE_COUNT=$(tmux list-panes -t "multiagent:agents" | wc -l)
log_info "作成されたペイン数: $PANE_COUNT"

if [ "$PANE_COUNT" -ne 4 ]; then
    echo "❌ エラー: 期待されるペイン数(4)と異なります: $PANE_COUNT"
    exit 1
fi

# ペインID取得
PANE_IDS=($(tmux list-panes -t "multiagent:agents" -F "#{pane_id}" | sort))

# エージェント設定（原課対応構成）
log_info "原課対応エージェント設定中..."
AGENTS=("director" "dx_analyst" "admin_analyst" "doc_scanner")
AGENT_ROLES=(
    "全体統括・原課横断調整"
    "DX推進課・情報政策課担当"
    "総務課・企画政策課担当"
    "文書収集・構造化担当"
)
AGENT_COLORS=("1;31m" "1;36m" "1;33m" "1;35m")  # 赤、シアン、黄、マゼンタ

for i in {0..3}; do
    PANE_ID="${PANE_IDS[$i]}"
    AGENT="${AGENTS[$i]}"
    ROLE="${AGENT_ROLES[$i]}"
    COLOR="${AGENT_COLORS[$i]}"
    
    log_info "設定中: ${AGENT} - ${ROLE} (${PANE_ID})"
    
    # ペインタイトル設定
    tmux select-pane -t "$PANE_ID" -T "$AGENT"
    
    # 作業ディレクトリ設定
    tmux send-keys -t "$PANE_ID" "cd $(pwd)" C-m
    
    # カラープロンプト設定
    tmux send-keys -t "$PANE_ID" "export PS1='(\[\033[${COLOR}\]${AGENT}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
    
    # エージェント情報表示
    tmux send-keys -t "$PANE_ID" "echo '================================='" C-m
    tmux send-keys -t "$PANE_ID" "echo '🤖 ${AGENT} エージェント'" C-m
    tmux send-keys -t "$PANE_ID" "echo '📋 ${ROLE}'" C-m
    tmux send-keys -t "$PANE_ID" "echo '================================='" C-m
done

log_success "✅ multiagentセッション作成完了"
echo ""

# STEP 3: presidentセッション作成（営業戦略統括）
log_info "👑 presidentセッション作成開始..."

tmux new-session -d -s president
tmux send-keys -t president "cd $(pwd)" C-m
tmux send-keys -t president "export PS1='(\[\033[1;35m\]PRESIDENT\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
tmux send-keys -t president "echo '================================='" C-m
tmux send-keys -t president "echo '👑 PRESIDENT セッション'" C-m
tmux send-keys -t president "echo '📋 営業戦略統括・最終提案作成'" C-m
tmux send-keys -t president "echo '================================='" C-m

log_success "✅ presidentセッション作成完了"
echo ""

# STEP 4: 初期データディレクトリ情報表示
log_info "📁 データディレクトリ構造..."

echo ""
echo "📂 収集データ格納場所:"
echo "  ./data/plans/    - 総合計画・個別計画"
echo "  ./data/minutes/  - 議会議事録"
echo "  ./data/budgets/  - 予算・決算書"
echo "  ./data/analysis/ - 分析結果"
echo ""
echo "📝 ログファイル:"
echo "  ./logs/analysis_log.txt - 分析処理ログ"
echo "  ./logs/send_log.txt     - エージェント通信ログ"

echo ""
log_success "🎉 自治体営業支援システム環境セットアップ完了！"
echo ""
echo "📋 次のステップ:"
echo "  1. 🔗 セッションアタッチ:"
echo "     tmux attach-session -t multiagent   # 原課対応エージェント確認"
echo "     tmux attach-session -t president    # 営業統括確認"
echo ""
echo "  2. 🤖 Claude Code起動:"
echo "     # President認証後、multiagent一括起動"
echo "     tmux send-keys -t president 'claude' C-m"
echo "     for i in {0..3}; do tmux send-keys -t multiagent:0.\$i 'claude' C-m; done"
echo ""
echo "  3. 📜 指示書確認:"
echo "     営業統括: instructions/president.md"
echo "     全体調整: instructions/director.md"
echo "     原課分析: instructions/[原課名]_analyst.md"
echo ""
echo "  4. 🎯 分析開始: PRESIDENTに自治体名と分析テーマを指示"
echo ""