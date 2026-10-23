# rop2stl — Katalog objektů lehkého opevnění (ŘOP) s parametrickými modely pro 3D tisk

Parametrické OpenSCAD modely československých objektů lehkého opevnění
(LO vz. 36, LO vz. 37 typy A–E včetně atypů a plánovaných variant)
s daty rozměrů z dobových pramenů, určené pro 3D tisk v zadaném měřítku.

Web katalogu: https://klepeto.kuzelovi.cz/rop

## Struktura

- `data/` — rozměrová data objektů (JSON) + prameny (denkschrift scany, SVG půdorysy, KST archiv)
- `scad/` — parametrické OpenSCAD skripty (jeden typ = jeden skript)
- `renders/` — vyexportované STL + PNG náhledy (generované CI/CLI)
- `web/` — zdrojáky web aplikace katalogu

## Použití

```bash
# korpus + střecha řopíku A-180 v měřítku 1:87 (H0)
openscad -o korpus-1_87.stl -D "scale_denom=87" -D "part=0" scad/ropik-a180.scad
openscad -o strecha-1_87.stl -D "scale_denom=87" -D "part=1" scad/ropik-a180.scad

# jiná měřítka: 144 (N), 120, 72, 48, 35; provedení: zeslabene|normal|zesilene
```

Model = korpus (dutý, vchod v týlní stěně) + oddělávací střecha pro prohlídku interiéru.

## Prameny rozměrů

- Denkschrift über die tschecho-slowakische Landesbefestigung (OKH 1941) — public domain
- KST archiv (ropiky.net) — originální dobové stavební výkresy ŘOP
- ropiky.cz — typologie + SVG půdorysy
- FORTprint: Československé opevnění 1935–1938 (Aron, Lakosil, Svoboda)

## Stav

- [x] Pilot: LO vz. 37 typ A-180 (lichoběžníkový půdorys, oddělávací střecha, 3 provedení)
- [ ] Střílnové šachty, periskopický komínek, vnitřní členění
- [ ] Web katalogu + DB
- [ ] Typy B, C, D, E; LO vz. 36; atypy; plánované varianty
- [ ] Těžké objekty (TO)
