#!/bin/bash

# --- 設定エリア ---
# 日記を保存するフォルダ（なければ自動で作ります）
DIR="contents/diary"
# 今日の日付を取得 (例: 2025-12-18)
DATE=$(date +%Y-%m-%d)
# ファイル名
FILENAME="${DIR}/${DATE}.html"

# --- フォルダがなければ作る ---
mkdir -p $DIR

# --- ファイルが既にあるかチェック ---
if [ -f "$FILENAME" ]; then
    echo "⚠️  $FILENAME は既に存在します。VS Codeで開きます。"
    code "$FILENAME"
    exit 0
fi

# --- HTMLテンプレートを書き込む ---
cat << EOF > "$FILENAME"
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${DATE} の日記</title>
    
    <link rel="stylesheet" href="../../assets/css/style.css">
    
    <meta property="og:title" content="${DATE} の日記" />
    <meta property="og:type" content="article" />
</head>
<body>

    <div id="sidebar-placeholder"></div>

    <main class="main-content">
        <header class="content-header">
            <div class="page-title">
                <a href="../diary.html" class="silent-link">Diary Log</a>
            </div>
            <div class="page-number">${DATE}</div>
        </header>

        <article class="article">
            <h2>タイトル未定</h2>
            
            <p>
                ここに今日の日記を書く...
            </p>

            <div class="two-column">
                <div class="col-text">
                    <p>テキスト...</p>
                </div>
                <div class="col-media">
                    <figure>
                        <img src="../../assets/images/placeholder.jpg" alt="写真" class="hero-image">
                        <figcaption>キャプション</figcaption>
                    </figure>
                </div>
            </div>

        </article>
    </main>

    <script>
        // サイドバー読み込み (2階層上)
        fetch('../../components/sidebar.html')
            .then(response => response.text())
            .then(data => {
                const placeholder = document.getElementById('sidebar-placeholder');
                placeholder.innerHTML = data;
                
                // リンク自動修正など
                const sidebarLinks = placeholder.querySelectorAll('a');
                sidebarLinks.forEach(link => {
                    const href = link.getAttribute('href');
                    if (href && !href.startsWith('http') && !href.startsWith('#')) {
                        link.setAttribute('href', '../' + href);
                    }
                });
            });
    </script>
    </body>
</html>
EOF

# --- 完了メッセージと起動 ---
echo "✅ 新しい日記を作成しました: $FILENAME"
code "$FILENAME"

# --- log.html にリンクを自動追加する ---
LOG_FILE="contents/log.html"

if [ -f "$LOG_FILE" ]; then
    # タイル形式で挿入（複数行を一時ファイルに書き込む方式）
    # 挿入する内容を一時ファイルに保存
    TEMP_CARD=$(mktemp)
    cat > "$TEMP_CARD" << 'CARD_END'
                <li class="diary-card">
                    <a href="diary/DATE_PLACEHOLDER.html">
                        <div class="diary-date">DATE_PLACEHOLDER</div>
                        <div class="diary-title">の日記</div>
                    </a>
                </li>
CARD_END
    
    # DATE_PLACEHOLDERを実際の日付に置換
    sed -i.bak "s/DATE_PLACEHOLDER/${DATE}/g" "$TEMP_CARD"
    
    # log.htmlを一時ファイルにコピーして編集
    TEMP_LOG=$(mktemp)
    
    # <ul class="diary-grid"> の次の行に挿入
    awk '/<ul class="diary-grid">/ {print; system("cat '"$TEMP_CARD"'"); next} 1' "$LOG_FILE" > "$TEMP_LOG"
    
    # 元のファイルに上書き
    mv "$TEMP_LOG" "$LOG_FILE"
    
    # 一時ファイルを削除
    rm -f "$TEMP_CARD" "${TEMP_CARD}.bak"
    
    echo "🔗 log.html にリンクを追加しました。"
else
    echo "⚠️ log.html が見つかりませんでした。パスを確認してください: $LOG_FILE"
fi