#!/bin/bash

# 🏛️ 自治体営業支援AIエージェントシステム v2.0 環境構築
# 証明機能と自動化強化版

set -e  # エラー時に停止

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

log_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

echo "🏛️ 自治体営業支援AIエージェントシステム v2.0 環境構築"
echo "======================================================"
echo "📊 証明機能強化 & 自動化率90%を目指す新バージョン"
echo ""

# STEP 1: 既存環境のクリーンアップ
log_info "🧹 既存環境クリーンアップ開始..."

# セッション削除
for session in multiagent president; do
    tmux kill-session -t $session 2>/dev/null && \
        log_info "${session}セッション削除完了" || \
        log_info "${session}セッションは存在しませんでした"
done

# ディレクトリ構造の準備（v2.0対応）
log_info "📁 ディレクトリ構造準備中..."
mkdir -p ./data/{plans,minutes,budgets,analysis,evidence,structured}
mkdir -p ./logs/{processing,quality,audit}
mkdir -p ./tmp ./reports ./quality ./config
mkdir -p ./tools/{scrapers,analyzers,validators}

# 既存ファイルクリア
rm -f ./tmp/*_done.txt 2>/dev/null
rm -f ./logs/*.log 2>/dev/null

log_success "✅ クリーンアップ完了"
echo ""

# STEP 2: 設定ファイル作成
log_info "⚙️ 設定ファイル作成中..."

# 品質基準設定
cat > ./config/quality_standards.yaml << EOF
quality_standards:
  evidence:
    min_confidence: 0.8
    required_fields: [document_name, page_number, quote, date]
  consistency:
    max_contradictions: 0
    numeric_tolerance: 0.01
  completeness:
    required_departments: [dx, admin, finance, education, welfare]
    min_coverage: 0.85
  automation:
    target_rate: 0.90
    max_human_intervention: 0.10
EOF

# 自動化設定
cat > ./config/automation_config.json << EOF
{
  "web_scraping": {
    "parallel_workers": 4,
    "timeout_seconds": 30,
    "retry_attempts": 3,
    "user_agent": "Mozilla/5.0 (Gov-Sales-Agent/2.0)"
  },
  "pdf_processing": {
    "ocr_enabled": true,
    "languages": ["jpn", "eng"],
    "dpi": 300,
    "enhancement": true
  },
  "analysis": {
    "batch_size": 10,
    "cache_enabled": true,
    "ml_models": {
      "entity_extraction": "models/ner_v2.pkl",
      "classification": "models/doc_classifier_v2.pkl"
    }
  }
}
EOF

log_success "✅ 設定ファイル作成完了"
echo ""

# STEP 3: multiagentセッション作成（8ペイン - v2.0拡張）
log_info "📺 multiagentセッション作成開始 (8ペイン - 拡張版)..."

# セッション作成
tmux new-session -d -s multiagent -n "agents"

# 8ペイン作成（4x2グリッド）
# まず4ペイン作成（既存と同じ）
tmux split-window -h -t "multiagent:agents"
tmux select-pane -t "multiagent:agents" -L
tmux split-window -v
tmux select-pane -t "multiagent:agents" -R
tmux split-window -v

# 下段に4ペイン追加
tmux select-pane -t "multiagent:agents.0"
tmux split-window -v -p 50
tmux split-window -h
tmux select-pane -t "multiagent:agents.2"
tmux split-window -v -p 50
tmux split-window -h

# ペイン数確認
PANE_COUNT=$(tmux list-panes -t "multiagent:agents" | wc -l)
if [ "$PANE_COUNT" -ne 8 ]; then
    log_warning "期待されるペイン数(8)と異なります: $PANE_COUNT"
    log_info "4ペイン構成で続行します"
    AGENTS=("director" "dx_analyst" "admin_analyst" "doc_scanner")
    AGENT_ROLES=(
        "全体統括・原課横断調整"
        "DX推進課・情報政策課担当"
        "総務課・企画政策課担当"
        "文書収集・構造化担当"
    )
else
    log_success "8ペイン作成成功"
    AGENTS=("director" "dx_analyst" "admin_analyst" "doc_scanner" 
            "evidence_tracker" "auto_processor" "quality_checker" "data_validator")
    AGENT_ROLES=(
        "全体統括・原課横断調整"
        "DX推進課・情報政策課担当"
        "総務課・企画政策課担当"
        "文書収集・構造化担当"
        "証明・引用管理担当"
        "自動化処理担当"
        "品質保証担当"
        "データ検証担当"
    )
fi

# エージェント設定
PANE_IDS=($(tmux list-panes -t "multiagent:agents" -F "#{pane_id}" | sort))
AGENT_COLORS=("1;31m" "1;36m" "1;33m" "1;35m" "1;32m" "1;34m" "1;37m" "1;30m")

for i in $(seq 0 $((${#AGENTS[@]} - 1))); do
    PANE_ID="${PANE_IDS[$i]}"
    AGENT="${AGENTS[$i]}"
    ROLE="${AGENT_ROLES[$i]}"
    COLOR="${AGENT_COLORS[$i]}"
    
    log_info "設定中: ${AGENT} - ${ROLE}"
    
    # ペイン設定
    tmux select-pane -t "$PANE_ID" -T "$AGENT"
    tmux send-keys -t "$PANE_ID" "cd $(pwd)" C-m
    tmux send-keys -t "$PANE_ID" "export PS1='(\[\033[${COLOR}\]${AGENT}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
    
    # エージェント情報表示
    tmux send-keys -t "$PANE_ID" "clear" C-m
    tmux send-keys -t "$PANE_ID" "echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'" C-m
    tmux send-keys -t "$PANE_ID" "echo '🤖 ${AGENT} エージェント v2.0'" C-m
    tmux send-keys -t "$PANE_ID" "echo '📋 ${ROLE}'" C-m
    tmux send-keys -t "$PANE_ID" "echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'" C-m
done

log_success "✅ multiagentセッション作成完了"
echo ""

# STEP 4: presidentセッション作成（変更なし）
log_info "👑 presidentセッション作成開始..."

tmux new-session -d -s president
tmux send-keys -t president "cd $(pwd)" C-m
tmux send-keys -t president "export PS1='(\[\033[1;35m\]PRESIDENT\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
tmux send-keys -t president "clear" C-m
tmux send-keys -t president "echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'" C-m
tmux send-keys -t president "echo '👑 PRESIDENT セッション v2.0'" C-m
tmux send-keys -t president "echo '📋 営業戦略統括・最終提案作成（証明機能強化）'" C-m
tmux send-keys -t president "echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'" C-m

log_success "✅ presidentセッション作成完了"
echo ""

# STEP 5: 証明データベース初期化
log_info "🗄️ 証明データベース初期化中..."

# SQLiteデータベース作成
sqlite3 ./data/evidence/evidence.db << EOF
CREATE TABLE IF NOT EXISTS evidence (
    id TEXT PRIMARY KEY,
    finding_id TEXT NOT NULL,
    document_name TEXT NOT NULL,
    document_url TEXT,
    page_number INTEGER,
    section TEXT,
    quote TEXT NOT NULL,
    extraction_method TEXT,
    extraction_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confidence_score REAL DEFAULT 0.0,
    verified BOOLEAN DEFAULT 0
);

CREATE TABLE IF NOT EXISTS quality_reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    municipality TEXT NOT NULL,
    report_date DATE,
    total_score REAL,
    evidence_score REAL,
    consistency_score REAL,
    completeness_score REAL,
    relevance_score REAL,
    presentation_score REAL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_finding_id ON evidence(finding_id);
CREATE INDEX idx_document_name ON evidence(document_name);
CREATE INDEX idx_municipality_date ON quality_reports(municipality, report_date);
EOF

log_success "✅ データベース初期化完了"
echo ""

# STEP 6: Pythonツール確認（仮想環境推奨）
log_info "🐍 Python環境確認中..."

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    log_success "Python3が見つかりました: $PYTHON_VERSION"
    
    # 必要なパッケージリスト作成
    cat > ./requirements.txt << EOF
selenium>=4.0.0
beautifulsoup4>=4.9.0
requests>=2.25.0
pdfplumber>=0.5.0
pytesseract>=0.3.0
pandas>=1.2.0
numpy>=1.20.0
scikit-learn>=0.24.0
pyyaml>=5.4.0
jinja2>=3.0.0
sqlite3
EOF
    
    log_info "必要なPythonパッケージは requirements.txt に記載されています"
    log_info "インストール: pip install -r requirements.txt"
else
    log_warning "Python3が見つかりません。自動化機能には Python3 が必要です"
fi

echo ""

# STEP 7: 完了メッセージ
log_success "🎉 自治体営業支援システム v2.0 環境セットアップ完了！"
echo ""
echo "📋 新機能の概要:"
echo "  ✨ 証明管理: 全ての分析結果に根拠を自動付与"
echo "  ⚡ 自動化強化: 処理の90%を自動化"
echo "  ✅ 品質保証: 営業提案の信頼性を保証"
echo "  📊 監査対応: 完全な処理履歴と証跡"
echo ""
echo "📋 次のステップ:"
echo "  1. 🔗 セッションアタッチ:"
echo "     tmux attach-session -t multiagent   # 拡張エージェント群"
echo "     tmux attach-session -t president    # 営業統括"
echo ""
echo "  2. 🤖 Claude Code起動:"
echo "     for i in {0..$((${#AGENTS[@]} - 1))}; do"
echo "         tmux send-keys -t multiagent:0.\$i 'claude' C-m"
echo "     done"
echo "     tmux send-keys -t president 'claude' C-m"
echo ""
echo "  3. 📜 新規エージェント指示書:"
echo "     証明管理: instructions/evidence_tracker.md"
echo "     自動処理: instructions/auto_processor.md"
echo "     品質保証: instructions/quality_checker.md"
echo ""
echo "  4. 🎯 v2.0での分析開始:"
echo "     『柏市の総合計画を証明付きで分析し、自動レポート生成』"
echo ""
echo "  5. 📊 品質確認:"
echo "     sqlite3 ./data/evidence/evidence.db"
echo "     cat ./quality/latest_report.html"
echo ""
echo "🚀 証明可能で信頼できる営業提案を自動生成します！"