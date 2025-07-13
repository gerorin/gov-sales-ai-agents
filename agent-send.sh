#!/bin/bash

# 🏛️ 自治体営業支援システム エージェント間通信

# tmuxのbase-indexとpane-base-indexを動的に取得
get_tmux_indices() {
    local session="$1"
    local window_index=$(tmux show-options -t "$session" -g base-index 2>/dev/null | awk '{print $2}')
    local pane_index=$(tmux show-options -t "$session" -g pane-base-index 2>/dev/null | awk '{print $2}')

    # デフォルト値
    window_index=${window_index:-0}
    pane_index=${pane_index:-0}

    echo "$window_index $pane_index"
}

# エージェント→tmuxターゲット マッピング（原課対応）
get_agent_target() {
    case "$1" in
        "president") echo "president" ;;
        "director"|"dx_analyst"|"admin_analyst"|"doc_scanner")
            # multiagentセッションのindexを動的に取得
            if tmux has-session -t multiagent 2>/dev/null; then
                local indices=($(get_tmux_indices multiagent))
                local window_index=${indices[0]}
                local pane_index=${indices[1]}

                # window名で取得（base-indexに依存しない）
                local window_name="agents"

                # pane番号を計算（原課対応配置）
                case "$1" in
                    "director") echo "multiagent:$window_name.$((pane_index))" ;;
                    "dx_analyst") echo "multiagent:$window_name.$((pane_index + 1))" ;;
                    "admin_analyst") echo "multiagent:$window_name.$((pane_index + 2))" ;;
                    "doc_scanner") echo "multiagent:$window_name.$((pane_index + 3))" ;;
                esac
            else
                echo ""
            fi
            ;;
        *) echo "" ;;
    esac
}

show_usage() {
    cat << EOF
🏛️ 自治体営業支援システム エージェント間通信

使用方法:
  $0 [エージェント名] [メッセージ]
  $0 --list

利用可能エージェント:
  president      - 営業戦略統括
  director       - 全体調整役（原課横断）
  dx_analyst     - DX推進課・情報政策課分析
  admin_analyst  - 総務課・企画政策課分析
  doc_scanner    - 文書収集・構造化

使用例:
  $0 president "分析完了報告"
  $0 director "○○市の総合計画分析開始"
  $0 dx_analyst "DX推進計画の重点施策を抽出"
  $0 doc_scanner "○○市HPから計画書収集"
EOF
}

# エージェント一覧表示（原課対応版）
show_agents() {
    echo "📋 利用可能なエージェント（原課対応）:"
    echo "========================================"

    # presidentセッション確認
    if tmux has-session -t president 2>/dev/null; then
        echo "  president      → president       (営業戦略統括)"
    else
        echo "  president      → [未起動]        (営業戦略統括)"
    fi

    echo ""
    echo "  【原課対応エージェント】"
    
    # multiagentセッション確認
    if tmux has-session -t multiagent 2>/dev/null; then
        local director_target=$(get_agent_target "director")
        local dx_target=$(get_agent_target "dx_analyst")
        local admin_target=$(get_agent_target "admin_analyst")
        local scanner_target=$(get_agent_target "doc_scanner")

        echo "  director       → ${director_target:-[エラー]}  (全体調整・原課横断)"
        echo "  dx_analyst     → ${dx_target:-[エラー]}  (DX推進課・情報政策課)"
        echo "  admin_analyst  → ${admin_target:-[エラー]}  (総務課・企画政策課)"
        echo "  doc_scanner    → ${scanner_target:-[エラー]}  (文書収集・構造化)"
    else
        echo "  director       → [未起動]        (全体調整・原課横断)"
        echo "  dx_analyst     → [未起動]        (DX推進課・情報政策課)"
        echo "  admin_analyst  → [未起動]        (総務課・企画政策課)"
        echo "  doc_scanner    → [未起動]        (文書収集・構造化)"
    fi

    echo ""
    echo "  【拡張予定エージェント（Phase2）】"
    echo "  welfare_analyst   - 福祉課・高齢者福祉課"
    echo "  education_analyst - 教育総務課・子ども家庭課"
}

# ログ記録（分析内容も含む）
log_send() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p logs
    echo "[$timestamp] $agent: $message" >> logs/send_log.txt
    
    # 分析関連メッセージは別途記録
    if [[ "$message" =~ "分析" ]] || [[ "$message" =~ "収集" ]] || [[ "$message" =~ "抽出" ]]; then
        echo "[$timestamp] [ANALYSIS] $agent: $message" >> logs/analysis_log.txt
    fi
}

# メッセージ送信
send_message() {
    local target="$1"
    local message="$2"
    
    echo "📤 送信中: $target ← '$message'"
    
    # Claude Codeのプロンプトを一度クリア
    tmux send-keys -t "$target" C-c
    sleep 0.3
    
    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.1
    
    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 0.5
}

# ターゲット存在確認
check_target() {
    local target="$1"
    local session_name="${target%%:*}"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ セッション '$session_name' が見つかりません"
        return 1
    fi
    
    return 0
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    # --listオプション
    if [[ "$1" == "--list" ]]; then
        show_agents
        exit 0
    fi
    
    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi
    
    local agent_name="$1"
    local message="$2"
    
    # エージェントターゲット取得
    local target
    target=$(get_agent_target "$agent_name")
    
    if [[ -z "$target" ]]; then
        echo "❌ エラー: 不明なエージェント '$agent_name'"
        echo "利用可能エージェント: $0 --list"
        exit 1
    fi
    
    # ターゲット確認
    if ! check_target "$target"; then
        exit 1
    fi
    
    # メッセージ送信
    send_message "$target" "$message"
    
    # ログ記録
    log_send "$agent_name" "$message"
    
    echo "✅ 送信完了: $agent_name に '$message'"
    
    return 0
}

main "$@"