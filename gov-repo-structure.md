# 🏛️ 自治体営業支援AIエージェントシステム リポジトリ

原課（自治体内の所管課）に対応した専門AIエージェントが連携し、証明可能な営業戦略を自動生成するシステム

## 📁 リポジトリ構造

```
gov-sales-ai-agents/
├── README.md                    # プロジェクト概要（日本語）
├── README-en.md                 # プロジェクト概要（英語）
├── CLAUDE.md                    # v1.0システム構成説明
├── CLAUDE-v2.md                 # v2.0システム構成説明（証明機能強化版）
├── LICENSE                      # MITライセンス
├── .gitignore                   # Git除外設定
├── requirements.txt             # Python依存パッケージ
│
├── setup.sh                     # v1.0環境構築スクリプト
├── setup-v2.sh                  # v2.0環境構築スクリプト（8エージェント対応）
├── agent-send.sh                # エージェント間通信スクリプト
│
├── .claude/
│   └── settings.local.json      # Claude Code権限設定
│
├── instructions/                # エージェント指示書
│   ├── president.md             # 営業戦略統括
│   ├── director.md              # 全体調整役
│   ├── dx_analyst.md            # DX推進課分析官
│   ├── admin_analyst.md         # 総務企画分析官
│   ├── doc_scanner.md           # 文書収集官
│   ├── evidence_tracker.md      # 証明管理官（v2.0新規）
│   ├── auto_processor.md        # 自動化処理官（v2.0新規）
│   └── quality_checker.md       # 品質保証官（v2.0新規）
│
├── templates/                   # 出力テンプレート
│   └── sales_report.md          # 営業提案書テンプレート
│
├── tools/                       # 自動化ツール（v2.0新規）
│   ├── evidence_dashboard.py    # 証明ダッシュボード
│   ├── web_scraper.py           # Web自動収集（実装予定）
│   ├── pdf_analyzer.py          # PDF自動解析（実装予定）
│   └── report_generator.py      # レポート自動生成（実装予定）
│
├── config/                      # 設定ファイル（v2.0新規）
│   ├── quality_standards.yaml   # 品質基準設定
│   └── automation_config.json   # 自動化設定
│
├── data/                        # 収集データ格納（.gitignore対象）
│   ├── plans/                   # 総合計画・個別計画
│   ├── minutes/                 # 議会議事録
│   ├── budgets/                 # 予算・決算書
│   ├── analysis/                # 分析結果
│   ├── evidence/                # 証明データ（v2.0新規）
│   │   └── evidence.db          # 証明データベース
│   └── structured/              # 構造化データ（v2.0新規）
│
├── logs/                        # ログファイル（.gitignore対象）
│   ├── send_log.txt             # エージェント通信ログ
│   ├── analysis_log.txt         # 分析処理ログ
│   ├── processing/              # 自動処理ログ（v2.0新規）
│   ├── quality/                 # 品質チェックログ（v2.0新規）
│   └── audit/                   # 監査ログ（v2.0新規）
│
├── reports/                     # 生成レポート（.gitignore対象）
│   └── evidence_dashboard.html  # 証明ダッシュボード
│
├── quality/                     # 品質管理（v2.0新規）
│   └── latest_report.html       # 最新品質レポート
│
└── tmp/                         # 一時ファイル（.gitignore対象）
    └── *_done.txt               # 処理完了フラグ
```

## 🚀 クイックスタート

### 1. リポジトリのクローン
```bash
git clone https://github.com/[your-username]/gov-sales-ai-agents.git
cd gov-sales-ai-agents
```

### 2. 環境構築を選択

#### v1.0（基本版）- 4エージェント
```bash
./setup.sh
```

#### v2.0（証明機能強化版）- 8エージェント
```bash
./setup-v2.sh
```

### 3. Python環境準備（v2.0で必須）
```bash
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 4. tmuxセッションにアタッチ
```bash
tmux attach-session -t multiagent  # 別ターミナルで
tmux attach-session -t president
```

### 5. Claude Code起動
```bash
# 各ペインでClaude Codeを起動
# v1.0の場合
for i in {0..3}; do tmux send-keys -t multiagent:0.$i 'claude' C-m; done

# v2.0の場合（8ペイン）
for i in {0..7}; do tmux send-keys -t multiagent:0.$i 'claude' C-m; done

# presidentセッション
tmux send-keys -t president 'claude' C-m
```

## 📊 バージョン比較

| 機能 | v1.0 | v2.0 |
|-----|------|------|
| エージェント数 | 4 | 8 |
| 証明機能 | ❌ | ✅ |
| 自動化率 | 60% | 90% |
| 品質保証 | 手動 | 自動 |
| 監査証跡 | 基本 | 完全 |
| Webスクレイピング | 手動 | 自動 |
| レポート生成 | 半自動 | 全自動 |

## 🤖 エージェント一覧

### 基本エージェント（v1.0/v2.0共通）
- **president**: 営業戦略統括・最終提案作成
- **director**: 全体統括・原課横断調整
- **dx_analyst**: DX推進課・情報政策課対応
- **admin_analyst**: 総務課・企画政策課対応
- **doc_scanner**: 計画書・HP情報自動読取

### 拡張エージェント（v2.0のみ）
- **evidence_tracker**: 証明・引用管理
- **auto_processor**: 自動化処理
- **quality_checker**: 品質保証
- **data_validator**: データ検証（予備）

## 📋 使用例

### v1.0での基本分析
```bash
# PRESIDENTセッションで
あなたはpresidentです。柏市の総合計画を分析して営業戦略を立案してください
```

### v2.0での証明付き自動分析
```bash
# PRESIDENTセッションで
柏市の総合計画を証明付きで分析し、品質保証済みの営業提案を自動生成してください
```

## 🔧 カスタマイズ

### 新規原課エージェントの追加
1. `instructions/[課名]_analyst.md` を作成
2. `setup.sh` または `setup-v2.sh` を編集
3. `agent-send.sh` にマッピング追加

### 品質基準の調整
```bash
vi config/quality_standards.yaml
```

### 自動化パラメータの変更
```bash
vi config/automation_config.json
```

## 📊 モニタリング

### 証明ダッシュボードの表示
```bash
python tools/evidence_dashboard.py
open reports/evidence_dashboard.html
```

### 品質レポートの確認
```bash
sqlite3 data/evidence/evidence.db "SELECT * FROM quality_reports ORDER BY created_at DESC LIMIT 10;"
```

### ログの監視
```bash
tail -f logs/analysis_log.txt
tail -f logs/processing/*.log
```

## 🤝 コントリビューション

1. Forkする
2. Feature branchを作成 (`git checkout -b feature/AmazingFeature`)
3. 変更をCommit (`git commit -m 'Add some AmazingFeature'`)
4. Branchにpush (`git push origin feature/AmazingFeature`)
5. Pull Requestを作成

## 📄 ライセンス

MIT License - 詳細は [LICENSE](LICENSE) を参照

## 🙏 謝辞

- 自治体DXの推進に取り組む全ての方々
- オープンガバメントデータの提供自治体
- AIエージェント技術の発展に貢献する研究者

---

🏛️ **自治体営業を科学する - 証明可能で自動化された営業支援** 🤖✨