#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Scraper ropiky.net — kompletní databáze LO objektů (všechny sbory, ~10k objektů).

Primární data z tabulek úseků (dbase_usek): sled, číslo, typ, odolnost, terén,
n.m. výška, datum betonáže, krych. pevnost, stav 1938, stav dnes, poznámka.
Karta objektu (dbase_objekt) jen pro: plné označení, GPS.

Výstup: data/ropiky-net-objekty.json. Idempotentní resume (checkpoint každých 50 objektů).
Kódování windows-1250. Zdroj: ropiky.net — při použití dat citovat.
"""
import urllib.request, re, json, os, sys, time, html as H

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "data", "ropiky-net-objekty.json"))
BASE = "https://www.ropiky.net/"
DELAY = 0.25

SBORY = {"1": "I. sbor", "2": "II. sbor", "3": "III. sbor", "4": "IV. sbor",
         "6": "VI. sbor", "7": "VII. sbor", "B": "ZVV Brno", "P": "ZVV Praha", "S": "ZVV Bratislava"}

# sloupce tabulky dbase_usek (podle pozorování A-1: [?]=sled? … ověřené indexy:
# 1=číslo/sled, 3=typ, 4=odolnost, 5=terén, 6=nm výška, 7=datum betonáže,
# 8=pevnost, 9=stav1938, 10=stav dnes, 11=poznámka, 13=fotky?)

def log(msg):
    sys.stderr.write(time.strftime("[%H:%M:%S] ") + msg + "\n")
    sys.stderr.flush()

def get(url):
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (KlepetoRopKatalog/1.0)"})
    for attempt in range(3):
        try:
            return urllib.request.urlopen(req, timeout=30).read().decode("cp1250", "replace")
        except Exception as e:
            if attempt == 2:
                raise
            log(f"retry {url}: {e}")
            time.sleep(5)

def cells(tr):
    tds = re.findall(r"<td[^>]*>(.*?)</td>", tr, re.S | re.I)
    out = []
    for c in tds:
        t = H.unescape(re.sub(r"<[^>]+>", " ", c))
        out.append(re.sub(r"\s+", " ", t).replace("\xa0", " ").strip())
    return out

def scrape():
    data = {}
    if os.path.exists(OUT):
        data = json.load(open(OUT, encoding="utf-8"))
        log(f"resume: {len(data)} objektů již scraped")
    for sbor, jmeno in SBORY.items():
        d = get(BASE + f"dbase_sbor.php?sbor={sbor}")
        useky = []
        for m in re.finditer(r"<tr[^>]*onclick=\"window\.location\.href='dbase_usek\.php\?id=(\d+)'[^>]*>(.*?)</tr>", d, re.S):
            c = cells(m.group(2))
            useky.append({"id": m.group(1), "usek": c[0] if c else "", "prostor": c[1] if len(c) > 1 else ""})
        log(f"{jmeno}: {len(useky)} úseků")
        time.sleep(DELAY)
        for u in useky:
            if u["usek"] in [x.get("usek_nazev") for x in data.values()] and \
               any(x.get("usek_nazev") == u["usek"] and x.get("sbor_nazev") == jmeno for x in data.values()):
                continue  # úsek kompletně scraped v předchozím běhu
            ud = get(BASE + f"dbase_usek.php?id={u['id']}")
            rows = re.findall(r"<tr[^>]*onclick=\"window\.location\.href='dbase_objekt\.php\?id=(\d+)'[^>]*>(.*?)</tr>", ud, re.S)
            novych = 0
            for oid, tr in rows:
                if str(oid) in data:
                    continue
                c = cells(tr)
                o = {"id": int(oid), "sbor_nazev": jmeno, "usek_nazev": u["usek"], "usek_prostor": u["prostor"]}
                try:
                    o["sled_cislo"] = c[1]
                    o["typ"] = c[3]
                    o["odolnost"] = c[4]
                    o["teren"] = c[5]
                    o["nm_vyska"] = c[6]
                    o["datum_betonaze"] = c[7]
                    o["krych_pevnost"] = c[8]
                    o["stav_1938"] = c[9]
                    o["stav_dnes"] = c[10]
                    o["poznamka"] = c[11]
                    o["_cells"] = c  # celý řádek pro dočištění
                except IndexError:
                    o["_cells"] = c
                data[str(oid)] = o
                novych += 1
            log(f"  {u['usek']} ({u['prostor']}): {len(rows)} objektů, +{novych} nových (celkem {len(data)})")
            time.sleep(DELAY)
            if len(data) % 500 < len(rows):
                json.dump(data, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    json.dump(data, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    log(f"HOTOVO: {len(data)} objektů → {OUT}")

if __name__ == "__main__":
    scrape()