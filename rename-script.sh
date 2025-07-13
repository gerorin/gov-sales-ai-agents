#!/bin/bash

# ファイル名修正スクリプト
# ダウンロードしたファイルを正しい構造に配置します

echo "📁 ファイル名修正とディレクトリ構造作成を開始します..."

# ディレクトリ作成
mkdir -p .claude
mkdir -p instructions
mkdir -p templates
mkdir -p tools
mkdir -p config

# ファイル名のマッピングと移動
declare -A file_mappings=(
    # ルートディレクトリのファイル
    ["gov-agent-readme.md"]="README.md"
    ["gov-agent-readme-en.md"]="README-en.md"
    ["gov-agent-claude-md.md"]="CLAUDE.md"
    ["gov-agent-v2-claude-md.md"]="CLAUDE-v2.md"
    ["gov-license"]="LICENSE"
    ["gov-license.txt"]="LICENSE"
    ["gov-agent-setup.sh"]="setup.sh"
    ["gov-v2-setup.sh"]="setup-v2.sh"
    ["gov-agent-send.sh"]="agent-send.sh"
    ["gov-repo-install-script.sh"]="install.sh"
    ["gov-repo-requirements.txt"]="requirements.txt"
    ["gov-gitignore"]="gitignore.tmp"  # 一時的に別名で保存
    
    # .claude/ディレクトリ
    ["gov-claude-settings.json"]=".claude/settings.local.json"
    
    # instructions/ディレクトリ
    ["gov-president-instruction.md"]="instructions/president.md"
    ["gov-director-instruction.md"]="instructions/director.md"
    ["gov-dx-analyst-instruction.md"]="instructions/dx_analyst.md"
    ["gov-admin-analyst-instruction.md"]="instructions/admin_analyst.md"
    ["gov-doc-scanner-instruction.md"]="instructions/doc_scanner.md"
    ["gov-evidence-tracker-instruction.md"]="instructions/evidence_tracker.md"
    ["gov-auto-processor-instruction.md"]="instructions/auto_processor.md"
    ["gov-quality-checker-instruction.md"]="instructions/quality_checker.md"
    
    # templates/ディレクトリ
    ["gov-sales-report-template.md"]="templates/sales_report.md"
    
    # tools/ディレクトリ
    ["gov-v2-evidence-dashboard.py"]="tools/evidence_dashboard.py"
    
    # config/ディレクトリ
    ["gov-quality-standards-yaml.yaml"]="config/quality_standards.yaml"
    ["gov-automation-config-json.json"]="config/automation_config.json"
)

# ファイルの移動とリネーム
for src in "${!file_mappings[@]}"; do
    dst="${file_mappings[$src]}"
    
    if [ -f "$src" ]; then
        echo "✅ $src → $dst"
        mv "$src" "$dst"
    else
        # 拡張子なしでも探す
        src_no_ext="${src%.*}"
        if [ -f "$src_no_ext" ]; then
            echo "✅ $src_no_ext → $dst"
            mv "$src_no_ext" "$dst"
        fi
    fi
done

# .gitignoreの処理（特殊ケース）
if [ -f "gitignore.tmp" ]; then
    mv "gitignore.tmp" ".gitignore"
    echo "✅ .gitignore を作成しました"
fi

# 実行権限の付与
chmod +x setup.sh setup-v2.sh agent-send.sh install.sh 2>/dev/null

echo ""
echo "🎉 ファイル名の修正が完了しました！"
echo ""
echo "📋 ディレクトリ構造:"
echo "gov-sales-ai-agents/"
echo "├── README.md"
echo "├── README-en.md"
echo "├── CLAUDE.md"
echo "├── CLAUDE-v2.md"
echo "├── LICENSE"
echo "├── .gitignore"
echo "├── requirements.txt"
echo "├── install.sh"
echo "├── setup.sh"
echo "├── setup-v2.sh"
echo "├── agent-send.sh"
echo "├── .claude/"
echo "│   └── settings.local.json"
echo "├── instructions/"
echo "│   ├── president.md"
echo "│   ├── director.md"
echo "│   ├── dx_analyst.md"
echo "│   ├── admin_analyst.md"
echo "│   ├── doc_scanner.md"
echo "│   ├── evidence_tracker.md"
echo "│   ├── auto_processor.md"
echo "│   └── quality_checker.md"
echo "├── templates/"
echo "│   └── sales_report.md"
echo "├── tools/"
echo "│   └── evidence_dashboard.py"
echo "└── config/"
echo "    ├── quality_standards.yaml"
echo "    └── automation_config.json"
echo ""
echo "次のステップ: ./install.sh を実行してセットアップを開始してください"