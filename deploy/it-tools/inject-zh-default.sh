#!/bin/sh
set -eu
cd /usr/share/nginx/html

for f in assets/index-*.js; do
  [ -f "$f" ] || continue
  if grep -q 'locale:"en"' "$f"; then
    sed -i 's/locale:"en"/locale:"zh"/g' "$f"
  fi
  if grep -q 'legacy:!1,locale:"zh"' "$f"; then
    old=$(basename "$f")
    new="index-$(md5sum "$f" | cut -c1-8).js"
    if [ "$old" != "$new" ]; then
      mv "$f" "assets/$new"
      find . -type f \( -name '*.html' -o -name '*.js' -o -name '*.webmanifest' \) \
        -exec grep -l "$old" {} + | while read -r ref; do
          sed -i "s/${old}/${new}/g" "$ref"
        done
    fi
  fi
done

if ! grep -q 'locale-zh-defaulted' index.html; then
  snippet='<script>(function(){try{var k="locale",m="locale-zh-defaulted",v=localStorage.getItem(k);if(!localStorage.getItem(m)){if(!v||v==="en")localStorage.setItem(k,"zh");localStorage.setItem(m,"1");}}catch(e){}})();</script>'
  # Insert snippet right after <head>
  awk -v s="$snippet" 'BEGIN{done=0} /<head>/{print; if(!done){print s; done=1; next}} {print}' index.html > index.html.tmp
  mv index.html.tmp index.html
fi

cat > sw.js << 'SW'
self.addEventListener("install", (e) => { self.skipWaiting(); });
self.addEventListener("activate", (e) => {
  e.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.map((k) => caches.delete(k)));
    await self.clients.claim();
  })());
});
SW

grep -n 'legacy:!1,locale:"zh"' assets/index-*.js
grep -o 'locale-zh-defaulted' index.html
grep -oE 'assets/index-[^"]+\.js' index.html
