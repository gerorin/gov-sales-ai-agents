# 自治体営業支援AIエージェントシステム

## システム概要
自治体の原課（所管課）単位でニーズ・課題を分析し、効果的な営業戦略を立案するマルチエージェントシステム

## エージェント構成
- **PRESIDENT** (別セッション): 営業戦略統括・最終提案作成
- **director** (multiagent:agents): 全体統括・原課横断調整
- **dx_analyst** (multiagent:agents): DX推進課・情報政策課対応
- **admin_analyst** (multiagent:agents): 総務課・企画政策課対応
- **doc_scanner** (multiagent:agents): 計画書・HP情報自動読取

## あなたの役割
- **PRESIDENT**: @instructions/president.md
- **director**: @instructions/director.md
- **dx_analyst**: @instructions/dx_analyst.md
- **admin_analyst**: @instructions/admin_analyst.md
- **doc_scanner**: @instructions/doc_scanner.md

## メッセージ送信
```bash
./agent-send.sh [相手] "[メッセージ]"
```

## 基本フロー
1. PRESIDENT → director: 分析対象自治体・テーマ指示
2. director → doc_scanner: 文書収集指示
3. doc_scanner → 各analyst: 収集文書配布
4. 各analyst → director: 原課別分析結果
5. director → PRESIDENT: 統合営業戦略

## 原課対応マッピング

### 現在実装済み
| 原課カテゴリ | 所管課例 | 担当エージェント | 分析領域 |
|------------|---------|----------------|---------|
| デジタル推進 | DX推進課、情報政策課 | dx_analyst | デジタル施策、業務改善、AI・RPA |
| 総務・企画 | 総務課、企画政策課 | admin_analyst | 計画策定、自治体経営、組織改革 |

### 拡張予定（Phase2）
| 原課カテゴリ | 所管課例 | 担当エージェント | 分析領域 |
|------------|---------|----------------|---------|
| 福祉・高齢者 | 福祉課、高齢者福祉課 | welfare_analyst | 包括ケア、福祉DX |
| 教育・子育て | 教育総務課、子ども家庭課 | education_analyst | 教育ICT、子育て支援 |

## データ構造

### 収集対象文書
- 総合計画（基本構想・基本計画）
- 個別計画（DX推進計画、行革計画等）
- 予算書・決算書
- 議会議事録
- 首長施政方針
- 各課HP情報

### 分析出力項目
```json
{
  "自治体名": "○○市",
  "分析日": "2025-01-XX",
  "原課別分析": {
    "DX推進課": {
      "重点施策": [],
      "課題": [],
      "予算規模": "",
      "キーパーソン": [],
      "提案ポイント": []
    }
  },
  "営業戦略": {
    "優先アプローチ先": "",
    "提案タイミング": "",
    "連携可能部署": []
  }
}
```

## 拡張ガイドライン

### 新規原課エージェント追加手順
1. `instructions/[課名]_analyst.md` を作成
2. `setup.sh` でペイン追加
3. `agent-send.sh` にマッピング追加
4. 分析テンプレート更新

### 文書収集範囲の拡張
- Web scraping設定追加
- PDF解析ルール追加
- 構造化データ変換規則追加