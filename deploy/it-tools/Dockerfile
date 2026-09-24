FROM corentinth/it-tools:latest

# Official build hardcodes locale:"en"; switch default to Chinese.
# UI still has a language selector (中文 / English / …).
RUN sed -i 's/locale:"en"/locale:"zh"/g' /usr/share/nginx/html/assets/index-*.js
