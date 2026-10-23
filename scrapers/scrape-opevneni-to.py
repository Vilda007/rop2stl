#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Scraper opevneni.cz E-Databáze TO v2 — pěchotní sruby (PS) přes úseky.

Strategie: warm-up → per úsek iframe (podúseky) → search-us.asp?k=PS&u=N&p=AL
(všechny podúseky, ~100 ID/úsek) → karty itemPS.asp?id=N.

Výstup: data/opevneni-cz-to.json. Zdroj: E-Databáze (M. Hrdlička) — citovat.
Kódování windows-1250.
"""
import urllib.request, re, json, os, sys, time, html as H
import http.cookiejar

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "data", "opevneni-cz-to.json"))
BASE = "https://www.opevneni.cz"
PAGES = BASE + "/pages/"
DELAY = 0.3

USEKY = {1: "ŽSV II. Hlučín", 2: "ŽSV IV. Opava", 3: "ŽSV I. Staré Město p.S.",
         4: "ŽSV III. Králíky", 5: "ŽSV X. Rokytnice", 6: "ŽSV V. Náchod",
         7: "ŽSV VI. Trutnov", 8: "ŽSV VII. Liberec", 9: "Liběchov-Jitrava",
         10: "ŽSV XI. Hrušovany", 11: "ŽS 21 Bratislava", 12: "Cvičné objekty",
         15: "ŽSV VIII. Most", 16: "ŽSV IX. Domažlice", 17: "Vnější obrana Prahy"}

def log(msg):
    sys.stderr.write(time.strftime("[%H:%M:%S] ") + msg + "\n")
    sys.stderr.flush()

def strip_tags(s):
    t = H.unescape(re.sub(r"<(script|style)[^>]*>.*?</\1>", " ", s, flags=re.S))
    t = re.sub(r"<br\s*/?>", "\n", t)
    t = re.sub(r"<[^>]+>", " ", t)
    return re.sub(r"[ \t]+", " ", t).replace("\xa0", " ").strip()

def warmup(opener):
    for path in ["/", "/pages/main.asp", "/pages/header.asp", "/pages/outlookb.asp",
                 "/pages/left.asp", "/pages/novinky.asp", "/pages/right.asp"]:
        try:
            opener.open(BASE + path, timeout=30)
        except Exception as e:
            log(f"warmup {path}: {e}")
        time.sleep(0.2)
    log("warm-up hotov")

def parse_card(html_text):
    card = {}
    for m in re.finditer(r"<td[^>]*>\s*&?n?b?s?p?;?\s*([^<>]{2,40}?)\s*</td>\s*<td[^>]*>\s*:\s*</td>\s*<td[^>]*>(.*?)</td>", html_text, re.S):
        label = strip_tags(m.group(1)).rstrip(":").strip()
        val = strip_tags(m.group(2))
        if label and val and label not in card:
            card[label] = val
    m = re.search(r'class="V28B"\s*>([^<]+)<', html_text)
    if m:
        card["jmeno"] = m.group(1).strip()
    mh = re.search(r"Typ</td><td[^>]*>\s*&nbsp;?\s*Odolnost</td><td[^>]*>[^<]*&nbsp;?\s*Napojen na</td><td[^>]*>[^<]*&nbsp;?\s*Tvrz</td></tr>\s*<tr[^>]*>(.*?)</tr>", html_text, re.S)
    if mh:
        vals = re.findall(r"<td[^>]*>(.*?)</td>", mh.group(1), re.S)
        if len(vals) >= 4:
            card["typ"] = strip_tags(vals[0])
            card["odolnost"] = strip_tags(vals[1])
            card["napojen_na"] = strip_tags(vals[2])
            card["tvrz"] = strip_tags(vals[3])
    for m in re.finditer(r"ShowVykres\('(\d+)'\)[^>]*>\s*<br/>([^<]+)", html_text):
        card.setdefault("vykresy", []).append({"id": m.group(1), "nazev": m.group(2).strip()})
    m = re.search(r'Jméno : <font class="A11B">\s*([^<]+)</font', html_text)
    if m:
        card["gps_wpt"] = strip_tags(m.group(1))
    return card

def main():
    outdir = os.path.dirname(os.path.abspath(OUT))
    os.makedirs(outdir, exist_ok=True)
    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
    opener.addheaders = [("User-Agent", "Mozilla/5.0 (KlepetoRopKatalog/1.0)")]
    warmup(opener)

    def get(u):
        return opener.open(u, timeout=30).read().decode("cp1250", "replace")

    ids = {}  # id → (usek, podusek)
    for u, jmeno in USEKY.items():
        # iframe = podúseky pro daný úsek
        try:
            d = get(f"{PAGES}search-us-iframe.asp?k=PS&u={u}&p=")
        except Exception as e:
            log(f"iframe u={u} FAIL: {e}")
            continue
        pods = re.findall(r'<option value="([^"]*)"[^>]*>([^<]*)', re.search(r'name="p"[^>]*>(.*?)</select>', d, re.S).group(1)) if re.search(r'name="p"[^>]*>(.*?)</select>', d, re.S) else []
        time.sleep(DELAY)
        for pv, pn in pods:
            if not pv:
                continue
            try:
                d2 = get(f"{PAGES}search-us.asp?k=PS&u={u}&p={pv}")
            except Exception as e:
                log(f"  podúsek {pn} FAIL: {e}")
                continue
            got = re.findall(r"itemPS\.asp\?id=(\d+)", d2)
            for i in got:
                if i not in ids:
                    ids[i] = (jmeno, pn)
            log(f"{jmeno} / {pn}: {len(got)} ID (celkem {len(ids)})")
            time.sleep(DELAY)
            if (len(ids) // 200) > 0 and len(ids) % 200 < len(got):
                json.dump({k: v for k, v in ids.items()}, open(OUT + ".ids", "w", encoding="utf-8"))
    log(f"CELKEM PS objektů k scrape: {len(ids)}")

    data = {}
    if os.path.exists(OUT):
        data = json.load(open(OUT, encoding="utf-8"))
    for n, (oid, (usek, pod)) in enumerate(ids.items()):
        if str(oid) in data:
            continue
        try:
            d = get(f"{PAGES}itemPS.asp?id={oid}")
            card = parse_card(d)
            card["id"] = int(oid)
            card["usek_zsv"] = usek
            card["podusek"] = pod
            data[str(oid)] = card
        except Exception as e:
            log(f"FAIL {oid}: {e}")
        time.sleep(DELAY)
        if (n + 1) % 50 == 0:
            json.dump(data, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
            log(f"checkpoint: {n+1}/{len(ids)} karet")
    json.dump(data, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    log(f"HOTOVO: {len(data)} karet → {OUT}")

if __name__ == "__main__":
    main()