// ============================================================
// LO vz. 37 — typ A (řopík) — parametrický model pro 3D tisk
// Katalog ŘOP — klepeto.kuzelovi.cz/rop | GitHub: Vilda007/rop2stl
//
// HISTORICKÁ VĚRNOST v6 — tvar sladěn ze všech pramenů 24.10.2026:
//   [Vilda fotky] [DENK Denkschrift] [KST A160Z] [fotodok. Hnanice]
//
// PŮDORYS (shora, nepřítel vlevo):
//   - ČELO = chevron: dvě stěny od apexu k předním rohům křídel
//   - KŘÍDLA STŘÍLEN v PŘEDNÍCH rozích: výstupek ~0,80 m/bok mimo tělo,
//     střílnové stěny míří PODÉL linie (boční palba — koncepce vz. 37)
//   - TÝL = ROVNÁ stěna se zapuštěným vstupním portálkem
//     (v6 korekce: dřívější "zakulacený týl R4,32" bylo mylné čtení KST
//      výkresu vision modelem; Vildovy fotky + Denkschrift potvrzují rovnou
//      zadní stěnu s vchodem)
//
// Parametrický úhel křídel: variant = úhel mezi osami střílen (120–220°).
//   A-180 → osy protilehlé (střílnové stěny rovnoběžné s podélnou osou).
//   Jiné varianty → střílnové stěny se pootočí o (180−variant)/2° k čelu.
//
// POUŽITÍ:
//   openscad -o korpus.stl -D "scale_denom=87" -D "part=0" -D "variant=180" ropik-a.scad
//   openscad -o strecha.stl -D "scale_denom=87" -D "part=1" -D "variant=180" ropik-a.scad
// ============================================================

/* [Parametry] */
scale_denom = 87;       // jmenovatel měřítka (87=H0, 144=N, 72, 48, 35)
part = 0;               // 0=korpus, 1=střecha
variant = 180;          // úhel os střílen: 120|140|160|180|200|220
provedeni = "normal";   // zeslabene/normal/zesilene
roof_tol_mm = 0.25;     // vůle střechy (mm v měřítku)
strilny = 1;            // 1=prostříznuté střílnové otvory

// ---------- Šířky variant [DENK; A-160 s KST konfliktem] ----------
function width_variant(v) =
  v==120 ? 7.70 :
  v==140 ? 6.95 :
  v==160 ? 6.93 :   // [KST A160Z; Denkschrift 7,40 — konflikt, uvádíme obě]
  v==180 ? 8.70 :
  v==200 ? 8.40 : 8.70;

W       = width_variant(variant);  // max šířka přes KŘÍDLA [m]
W_body  = W - 1.60;                // šířka TĚLA (křídla +0,80 m/bok) [KST A160Z výstupek]
a_krid  = (180 - variant) / 2;     // pootočení střílnové stěny k čelu [°]
// ---------- Topologie (v7: wide-arrow dle fotodokumentace) ----------
X_nose  = 0;                       // PLOCHÉ čelo (ne hrot!) [fotka/DENK crop]
W_nose  = 3.60;                    // šířka plochého čela [≈ fotka: ~1/2 šířky]
X_kr_f  = 2.90;                    // přední roh křídla [≈]
d_kr    = 0.90;                    // hloubka křídla podél osy [≈ KST]
X_kr_b  = X_kr_f + d_kr;           // zadní hrana křídla
X_rear  = 5.40;                    // rovná týlní stěna [≈]
h_int   = 1.70;                    // světlá výška [≈ ověřit z A140Z_rezy]
h_cor   = 1.40;                    // výška vstupní chodby [≈]
w_door  = 0.65;                    // vchod [DENK]
d_alc   = 0.50;                    // zapuštěný portálek [≈ fotodok.]
w_strel = 0.30;                    // šířka střílny [≈]
h_strel = 0.28;                    // výška střílny [≈]
z_strel = 0.95;                    // spodní hrana střílny [≈]

prov = provedeni == "zeslabene" ? [0.60,0.55] : provedeni == "zesilene" ? [1.00,1.20] : [0.80,0.80];
t_wall = prov[0];
t_roof = prov[1];

// ---------- Měřítko ----------
function mm(m) = m * 1000 / scale_denom;
S = 1000 / scale_denom;

// ---------- Půdorys (x=0 apex u nepřítele, +x týl; y=0 osa) ----------
module hull2d() {
  scale([S, S])
  polygon([
    // ROVNÝ TÝL (vstupní stěna)
    [X_rear,  W_body/2],
    [X_kr_b,  W_body/2],   // bok těla P
    // KŘÍDLO P — výrazný obdélníkový blok [fotka/DENK]
    [X_kr_b,  W/2],        // vnější boku křídla P (výstupek 0,80 m)
    [X_kr_f,  W/2],        // STŘÍLNÁ STĚNA P — boční palba +Y
    // ŠIKMÉ RAMENO (shoulder) od křídla k čelu [fotka: wide-arrow]
    [X_nose,  W_nose/2],   // přední roh čela P
    // PLOCHÉ ČELO (wide nose)
    [X_nose, -W_nose/2],
    [X_kr_f, -W/2],        // rameno L → střílná stěna L
    [X_kr_b, -W/2],        // křídlo L — blok
    [X_kr_b, -W_body/2],   // bok těla L
  ]);
  // POZN.: pootočení střílnových střílen pro variant≠180 řeší úhel os střílen
  // v orientaci lafety (krytí střílny); půdorysný obrys křídel zůstává
  // krychlovitý — skutečné křídlo je mírně lichoběžníkové, doladíme po
  // analýze A160Z_ll (patra) a konkrétních variantách.
}

// ---------- KORPUS ----------
module korpus() {
  difference() {
    linear_extrude(height = mm(h_int))
      hull2d();
    // dutina (otevřená shora — oddělávací střecha)
    translate([0, 0, mm(0.08)])
      linear_extrude(height = mm(h_int))
        offset(delta = -mm(t_wall))
          hull2d();
    // zapuštěný portálek + průchod v ROVNÉ týlní stěně
    translate([mm(X_rear - d_alc), -mm(w_door)/2, mm(0.10)])
      cube([mm(d_alc + t_wall + 0.05), mm(w_door), mm(h_cor)]);
    // střílnové otvory — na střílnových stěnách křídel (vnější hrana y=±W/2),
    // míří ±Y podél linie; pro variant≠90+... osy se pootočí (lafeta v interiéru)
    if (strilny) {
      for (m = [1, -1]) {
        translate([mm((X_kr_f + X_kr_b)/2), m*(mm(W/2) - mm(0.60)), mm(z_strel)])
          cube([mm(d_kr + 0.3), mm(1.2), mm(h_strel)], center=[true, m==1?false:true, false]);
      }
    }
  }
}

// ---------- STŘECHA (oddělávací deska) ----------
module strecha() {
  linear_extrude(height = mm(t_roof))
    offset(delta = roof_tol_mm)
      hull2d();
}

// ---------- Export ----------
$fn = 96;
if (part == 0) { korpus(); } else { strecha(); }

echo(str("LO vz.37 A-", variant, " v6 | 1:", scale_denom, " | part: ", part==0?"KORPUS":"STŘECHA"));
echo(str("Čelo wide-arrow (ploché ", W_nose, " m + ramena) | křídla-bloky v předních rozích (+", (W-W_body)/2, " m/bok, střílny podél linie, osy ", variant, "°) | ROVNÝ týl ", W_body, " m s portálkem"));
echo(str("Šířka přes křídla ", W, " m [DENK] | hloubka ", X_rear, " m [≈] | výšky [≈ KST řezy k ověření]"));