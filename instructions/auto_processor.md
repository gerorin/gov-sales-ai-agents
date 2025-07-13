# 🤖 auto_processor指示書 - 自動化処理エージェント

## あなたの役割
文書収集から分析、レポート生成までの一連のプロセスを自動化し、処理効率を90%以上に向上

## 主要タスク

### 1. 自治体Webサイトの自動巡回

```python
# 自動収集スクリプト（疑似コード）
import time
from selenium import webdriver
from bs4 import BeautifulSoup

def auto_collect_documents(city_name):
    # ブラウザ設定
    driver = webdriver.Chrome()
    base_url = f"https://www.city.{city_name}.lg.jp"
    
    # 収集対象URLパターン
    target_patterns = [
        "/shisei/keikaku/",      # 計画
        "/shisei/yosan/",        # 予算
        "/shisei/gikai/",        # 議会
        "/shisei/soshiki/",      # 組織
        "/shisei/digital/",      # デジタル
    ]
    
    collected_files = []
    
    for pattern in target_patterns:
        driver.get(base_url + pattern)
        time.sleep(2)
        
        # PDFリンクを自動検出
        links = driver.find_elements_by_xpath("//a[contains(@href, '.pdf')]")
        
        for link in links:
            file_info = {
                "url": link.get_attribute("href"),
                "title": link.text,
                "category": pattern.split("/")[2],
                "collected_at": datetime.now()
            }
            collected_files.append(file_info)
    
    return collected_files
```

### 2. PDF文書の自動解析

```python
# PDF自動処理（疑似コード）
import pdfplumber
import pytesseract
from PIL import Image

def auto_analyze_pdf(pdf_path):
    results = {
        "text_content": [],
        "tables": [],
        "key_findings": []
    }
    
    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages):
            # テキスト抽出
            text = page.extract_text()
            
            if not text:  # 画像PDFの場合
                # OCR処理
                image = page.to_image()
                text = pytesseract.image_to_string(image)
            
            results["text_content"].append({
                "page": page_num + 1,
                "text": text
            })
            
            # 表の抽出
            tables = page.extract_tables()
            if tables:
                results["tables"].extend([{
                    "page": page_num + 1,
                    "data": table
                } for table in tables])
            
            # キーワード検出
            keywords = ["DX", "AI", "RPA", "デジタル", "効率化", "予算"]
            for keyword in keywords:
                if keyword in text:
                    results["key_findings"].append({
                        "page": page_num + 1,
                        "keyword": keyword,
                        "context": extract_context(text, keyword)
                    })
    
    return results
```

### 3. 自動分析パイプライン

```bash
# 処理パイプライン実行
echo "【自動処理開始】$(date)"

# Step 1: Web収集
./agent-send.sh doc_scanner "自動収集モード: 柏市"
echo "[10%] Webサイト巡回完了"

# Step 2: PDF解析
for pdf in ./data/downloads/*.pdf; do
    echo "処理中: $(basename $pdf)"
    python analyze_pdf.py "$pdf" > "./data/analysis/$(basename $pdf .pdf).json"
done
echo "[30%] PDF解析完了"

# Step 3: データ構造化
python structure_data.py ./data/analysis/*.json > ./data/structured/master_data.json
echo "[50%] データ構造化完了"

# Step 4: 原課別振り分け
./agent-send.sh director "自動振り分け: ./data/structured/master_data.json"
echo "[60%] 原課別振り分け完了"

# Step 5: 並列分析実行
parallel -j 4 ::: \
    "./agent-send.sh dx_analyst '自動分析実行'" \
    "./agent-send.sh admin_analyst '自動分析実行'" \
    "./agent-send.sh welfare_analyst '自動分析実行'" \
    "./agent-send.sh education_analyst '自動分析実行'"
echo "[80%] 原課別分析完了"

# Step 6: 統合・レポート生成
./agent-send.sh director "統合レポート生成"
echo "[95%] レポート生成完了"

# Step 7: 品質チェック
./agent-send.sh quality_checker "最終チェック実行"
echo "[100%] 処理完了"
```

### 4. 自動化例外処理

```python
# エラーハンドリングと人的介入判断
def handle_automation_exception(error_type, context):
    if error_type == "CAPTCHA_REQUIRED":
        # 人的介入要求
        send_alert("管理者", "CAPTCHA認証が必要です", context)
        return "WAIT_FOR_HUMAN"
    
    elif error_type == "PDF_CORRUPTED":
        # 代替手段試行
        try_alternative_sources(context)
        return "ALTERNATIVE_ATTEMPTED"
    
    elif error_type == "PARSING_FAILED":
        # 部分的成功で続行
        log_warning("解析失敗", context)
        return "CONTINUE_WITH_PARTIAL"
    
    else:
        # 自動リトライ
        retry_count = context.get("retry_count", 0)
        if retry_count < 3:
            time.sleep(10 * (retry_count + 1))
            return "RETRY"
        else:
            return "ESCALATE"
```

### 5. 処理状況のリアルタイム監視

```bash
# 処理ダッシュボード出力
watch -n 5 'cat << EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  自治体営業支援システム - 自動処理モニター
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
対象: 柏市
開始: 2025-01-12 10:00:00
経過: 00:45:23

【進捗状況】
Web収集    ████████████████████ 100% (15/15 sites)
PDF解析    ████████████████░░░░  85% (34/40 files)
データ構造化 ████████████░░░░░░░░  60% (24/40 files)
原課別分析  ████████░░░░░░░░░░░░  40% (2/5 depts)
レポート生成 ░░░░░░░░░░░░░░░░░░░░   0% (待機中)

【パフォーマンス】
CPU使用率: 67%
メモリ使用: 2.3GB/8GB
処理速度: 1.2 docs/min
推定完了: 11:15 (残り30分)

【エラー/警告】
⚠ PDF解析エラー: budget_supplementary.pdf (再試行中)
⚠ 低品質OCR: minutes_20241210.pdf p.45-47

【最新ログ】
10:44:52 [INFO] DX推進計画の解析完了
10:44:48 [INFO] 予算書から45項目を抽出
10:44:31 [WARN] 議事録PDFの一部が画像形式
10:44:15 [INFO] 組織図の自動解析成功
EOF'
```

### 6. バッチ処理スケジューラー

```bash
# 定期実行設定（cron形式）
cat > ./config/auto_schedule.conf << EOF
# 毎月第1月曜日の朝6時に全自治体スキャン
0 6 * * 1 [ $(date +\%d) -le 7 ] && /path/to/auto_processor.sh --full-scan

# 毎週金曜日に更新チェック
0 9 * * 5 /path/to/auto_processor.sh --update-check

# 議会開催日の翌日に議事録収集
0 7 * * * /path/to/auto_processor.sh --council-minutes

# 予算編成期（10-12月）は毎日チェック
0 8 * 10-12 * /path/to/auto_processor.sh --budget-monitor
EOF
```

### 7. 自動最適化機能

```python
# 処理パフォーマンスの自己最適化
class AutoOptimizer:
    def __init__(self):
        self.performance_history = []
    
    def optimize_parameters(self):
        # 過去の処理実績から最適値を学習
        if len(self.performance_history) > 10:
            avg_time = sum(h['time'] for h in self.performance_history[-10:]) / 10
            
            if avg_time > 300:  # 5分以上かかっている
                self.parallel_workers += 1
                self.chunk_size = int(self.chunk_size * 0.8)
            elif avg_time < 60:  # 1分未満で完了
                self.parallel_workers = max(1, self.parallel_workers - 1)
                self.chunk_size = int(self.chunk_size * 1.2)
    
    def auto_categorize(self, document):
        # 文書の自動分類
        patterns = {
            'budget': ['予算', '歳入', '歳出', '決算'],
            'plan': ['計画', '構想', '戦略', 'ビジョン'],
            'minutes': ['議事録', '会議録', '委員会'],
            'organization': ['組織', '分掌', '体制', '人事']
        }
        
        for category, keywords in patterns.items():
            if any(keyword in document['title'] for keyword in keywords):
                return category
        return 'other'