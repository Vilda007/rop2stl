#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Postprocess ŘOP dat — spouštět PO KAŽDÉ aktualizaci scraperů (LO i TO).

1. Vyčištění LO (ropiky-net-objekty.json): odstraní _cells, normalizuje odolnost
   (Z→zesílený, N→normalní, "-"→nezjištěná), typ rozdělí na rodinu (A/B/C/D/E/36/atyp).
2. Vyčištění TO (opevneni-cz-to.json): klíče do snake_case bez mezer, GPS wpt.
3. Agregace → data/katalog-agregace.json: typy + varianty + odolnosti + úseky
   (vstup pro katalog web/DB).

Idempotentní: čte raw soubory, píše cleaned + agregaci. Raw soubory nemění.
"""
import json, os, re, sys
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.normpath(os.path.join(HERE, "..", "data"))

def load(name):
    p = os.path.join(DATA, name)
    return json.load(open(p, encoding="utf-8")) if os.path.exists(p) else None

def dump(name, obj):
    json.dump(obj, open(os.path.join(DATA, name), "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)

ODOLNOST_LO = {"Z": "zesílený", "N": "normalní", "-": "nezjištěná", "": "nezjištěná"}

def typ_rodina_lo(typ):
    t = (typ or "").strip()
    if not t: return "neznámý"
    if "atyp" in t.lower(): return "atyp"
    if "36" in t: return "vz. 36"
    m = re.match(r"([A-E])", t)
    if m: return m.group(1)
    return t

def clean_lo():
    raw = load("ropiky-net-objekty.json")
    if not raw:
        return None
    out = {}
    for k, v in raw.items():
        c = {key: v.get(key) for key in
             ("id", "sbor_nazev", "usek_nazev", "usek_prostor", "sled_cislo", "typ",
              "odolnost", "teren", "nm_vyska", "datum_betonaze", "krych_pevnost",
              "stav_1938", "stav_dnes", "poznamka")}
        odr = (c["odolnost"] or "").strip()
        c["odolnost_norm"] = ODOLNOST_LO.get(odr, "neurčeno" if odr else "nezjištěná")
        c["typ_rodina"] = typ_rodina_lo(c["typ"])
        out[k] = c
    dump("ropiky-net-objekty-clean.json", out)
    return out

def clean_to():
    raw = load("opevneni-cz-to.json")
    if not raw:
        return None
    out = {}
    for k, v in raw.items():
        c = {}
        for key, val in v.items():
            kk = re.sub(r"[^a-z0-9]+", "_", key.strip().lower()).strip("_") if isinstance(key, str) and key != key.lower() else key
            c[key if key in ("id", "jmeno", "typ", "odolnost", "napojen_na", "tvrz",
                             "vykresy", "gps_wpt", "usek_zsv", "podusek") else kk] = val
        # legacy labely z th/td párů: Úsek→usek, Podúsek→podusek_2, Stav→stav
        c["usek_label"] = v.get("Úsek")
        c["stav"] = v.get("Stav")
        out[k] = c
    dump("opevneni-cz-to-clean.json", out)
    return out

def aggregate(lo, to):
    agg = {"_meta": {"generováno": __import__("datetime").datetime.now().isoformat(timespec="seconds")}}
    if lo:
        tc = Counter(v["typ"] for v in lo.values())
        rod = Counter(v["typ_rodina"] for v in lo.values())
        odc = Counter(v["odolnost_norm"] for v in lo.values())
        sb = Counter(v["sbor_nazev"] for v in lo.values())
        st = Counter(v["stav_dnes"] for v in lo.values())
        agg["lo"] = {
            "celkem": len(lo),
            "typy": dict(tc.most_common()),
            "rodiny": dict(rod.most_common()),
            "odolnosti": dict(odc.most_common()),
            "sbory": dict(sb.most_common()),
            "stav_dnes": dict(st.most_common()),
            "varianty_typu": sorted(tc.keys()),
        }
    if to:
        tc = Counter((v.get("typ") or "?").strip() or "?" for v in to.values())
        oc = Counter((v.get("odolnost") or "?").strip() or "?" for v in to.values())
        uc = Counter(v.get("usek_zsv") or "?" for v in to.values())
        wk = sum(1 for v in to.values() if v.get("vykresy"))
        agg["to"] = {
            "celkem": len(to),
            "typy": dict(tc.most_common()),
            "odolnosti": dict(oc.most_common()),
            "useky_zsv": dict(uc.most_common()),
            "s_vykresy": wk,
            "s_gps": sum(1 for v in to.values() if v.get("gps_wpt")),
        }
    dump("katalog-agregace.json", agg)
    return agg

def main():
    lo = clean_lo()
    to = clean_to()
    agg = aggregate(lo, to)
    r = []
    if lo: r.append(f"LO: {len(lo)} objektů vyčištěno")
    if to: r.append(f"TO: {len(to)} karet vyčištěno")
    r.append(f"Agregace: LO typy={len(agg.get('lo',{}).get('typy',{}))}, "
             f"TO typy={len(agg.get('to',{}).get('typy',{}))} → katalog-agregace.json")
    print("\n".join(r))
    if not lo and not to:
        sys.exit("žádná raw data k zpracování")

if __name__ == "__main__":
    main()