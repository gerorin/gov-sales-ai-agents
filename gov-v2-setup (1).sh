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

# 自動化設