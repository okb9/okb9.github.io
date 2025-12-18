#!/bin/bash

# --- 設定エリア ---
DIR="contents/diary"
DATE=$(date +%Y-%m-%d)
FILENAME="${DIR}/${DATE}.html"
# ★あなたのサイトのURL（ここ重要！OGPには「https://〜」が必要です）
SITE_URL="https://okb9.github.io"

# --- フォルダ作成 ---
mkdir -p $DIR

# --- 重複チェック ---
if [ -f "$FILENAME" ]; then
    echo "⚠️  $FILENAME は既に存在します。VS Codeで開きます。"
    code "$FILENAME"
    exit 0
fi

# --- HTMLテンプレート書き込み ---
cat << EOF > "$FILENAME"
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${DATE} の日記</title>
    
    <link rel="stylesheet" href="../../assets/css/style.css">
    
    <meta property="og:site_name" content="水槽の中の、" />
    <meta property="og:title" content="${DATE} の日記 | 水槽の中の、" />
    <meta property="og:type" content="article" />
    <meta property="og:description" content="${DATE}の日記です。" />
    
    <meta property="og:url" content="${SITE_URL}/contents/diary/${DATE}.html" />
    <meta property="og:image" content="${SITE_URL}/assets/images/Sprite-0001-export.png" />

    <meta name="twitter:card" content="summary_large_image" />
</head>
<body>

    <div id="sidebar-placeholder"></div>

    <main class="main-content">
        <header class="content-header">
            <div class="page-title">
                <a href="../log.html" class="silent-link">Diary Log</a>
            </div>
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
        // サイドバー読み込み
        fetch('../../components/sidebar.html')
            .then(response => response.text())
            .then(data => {
                const placeholder = document.getElementById('sidebar-placeholder');
                placeholder.innerHTML = data;
                
                // リンク修正
                const sidebarLinks = placeholder.querySelectorAll('a');
                sidebarLinks.forEach(link => {
                    const href = link.getAttribute('href');
                    if (href && !href.startsWith('http') && !href.startsWith('#')) {
                        link.setAttribute('href', '../' + href);
                    }
                });

                // メニュー開閉
                const parents = placeholder.querySelectorAll('.has-submenu > .parent-link');
                parents.forEach(parent => {
                    parent.addEventListener('click', (e) => {
                        e.preventDefault();
                        const navItem = parent.parentElement;
                        const submenu = navItem.querySelector('.submenu');
                        navItem.classList.toggle('open');
                        
                        if (navItem.classList.contains('open')) {
                            submenu.style.maxHeight = submenu.scrollHeight + "px";
                        } else {
                            submenu.style.maxHeight = null;
                        }
                    });
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
    # タイル形式で挿入
    CARD_TAG="                <li class=\"diary-card\">
                    <a href=\"diary/${DATE}.html\">
                        <div class=\"diary-date\">${DATE}</div>
                        <div class=\"diary-title\">の日記</div>
                    </a>
                </li>"
    
    # <ul class="diary-grid"> の次の行に挿入
    sed "/<ul class=\"diary-grid\">/a\\
$CARD_TAG" "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
    
    echo "🔗 log.html にリンクを追加しました。"
else
    echo "⚠️ log.html が見つかりませんでした。パスを確認してください: $LOG_FILE"
fi