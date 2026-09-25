#!/bin/sh
# Safe Chinese default for official IT-Tools without breaking module graph / caches.
set -eu
cd /usr/share/nginx/html

ENTRY_OLD="index-f8ba620c.js"
ENTRY_NEW="index-appzh1.js"

# Locate the real app entry (createI18n bundle), regardless of hash name
entry=""
for f in assets/index-*.js; do
  [ -f "$f" ] || continue
  if grep -q 'legacy:!1,locale:' "$f"; then
    entry=$f
    break
  fi
done
[ -n "$entry" ] || { echo "app entry not found"; exit 1; }

# Prefer zh in createI18n default
sed -i 's/legacy:!1,locale:"en"/legacy:!1,locale:"zh"/g' "$entry"

# Publish under a fresh filename never poisoned in browser/CDN caches
cp -f "$entry" "assets/$ENTRY_NEW"

# Rewrite every reference to the old entry name -> fresh name
old_base=$(basename "$entry")
find . -type f \( -name '*.html' -o -name '*.js' -o -name '*.webmanifest' \) \
  -exec grep -l "$old_base" {} + 2>/dev/null | while read -r ref; do
    sed -i "s/${old_base}/${ENTRY_NEW}/g" "$ref"
  done

# Keep old poisoned URLs serving valid JS too (compat for disk-cached HTML)
cp -f "assets/$ENTRY_NEW" "assets/$ENTRY_OLD"
cp -f "assets/$ENTRY_NEW" assets/index-bc49c609.js

# localStorage default zh + drop stale service workers / caches
if ! grep -q 'locale-zh-defaulted' index.html; then
  snippet='<script>(function(){try{var k="locale",m="locale-zh-defaulted",v=localStorage.getItem(k);if(!localStorage.getItem(m)){if(!v||v==="en")localStorage.setItem(k,"zh");localStorage.setItem(m,"1");}if(navigator.serviceWorker){navigator.serviceWorker.getRegistrations().then(function(rs){rs.forEach(function(r){r.unregister();});});}if(window.caches&&caches.keys){caches.keys().then(function(ks){ks.forEach(function(x){caches.delete(x);});});}}catch(e){}})();</script>'
  awk -v s="$snippet" 'BEGIN{done=0} /<head>/{print; if(!done){print s; done=1; next}} {print}' index.html > index.html.tmp
  mv index.html.tmp index.html
fi

# Ensure HTML entry points at fresh file
sed -i "s|/assets/${ENTRY_OLD}|/assets/${ENTRY_NEW}|g" index.html
sed -i "s|/assets/index-bc49c609.js|/assets/${ENTRY_NEW}|g" index.html

# SW: clear caches and unregister (do not precache)
cat > sw.js << 'SW'
self.addEventListener("install", (e) => { self.skipWaiting(); });
self.addEventListener("activate", (e) => {
  e.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.map((k) => caches.delete(k)));
    await self.registration.unregister();
  })());
});
SW

# Nginx: real 404 for missing assets; never cache HTML shell
cat > /etc/nginx/conf.d/default.conf << 'NGINX'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location /assets/ {
        try_files $uri =404;
        add_header Cache-Control "public, max-age=3600, must-revalidate";
    }

    location = /index.html {
        add_header Cache-Control "no-store, no-cache, must-revalidate";
        try_files $uri =404;
    }

    location = / {
        add_header Cache-Control "no-store, no-cache, must-revalidate";
        try_files /index.html =404;
    }

    location = /sw.js {
        add_header Cache-Control "no-store, no-cache, must-revalidate";
        try_files $uri =404;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
NGINX

echo "entry=$entry new=$ENTRY_NEW"
grep -oE "assets/index-[^\"]+\.js" index.html
grep -n 'legacy:!1,locale:"zh"' "assets/$ENTRY_NEW" | head -1
