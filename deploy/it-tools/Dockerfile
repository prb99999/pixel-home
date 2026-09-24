FROM corentinth/it-tools:latest

# Official build hardcodes locale:"en" and syncs it to localStorage("locale").
# Flip default to zh, bust asset caches, and migrate stored "en" -> "zh" once.
COPY inject-zh-default.sh /tmp/inject-zh-default.sh
RUN chmod +x /tmp/inject-zh-default.sh && /tmp/inject-zh-default.sh && rm /tmp/inject-zh-default.sh
