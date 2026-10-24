// ============================================================
// LO vz. 37 — typ A (řopík) — parametrický model pro 3D tisk
// Katalog ŘOP — klepeto.kuzelovi.cz/rop | GitHub: Vilda007/rop2stl
//
// HISTORICKÁ VĚRNOST v8.4 — ORIENTACE dle Vilda 10:59:
//   „Rovná strana s vybíhajícími ušima je NAPROTI vchodu (strana k nepříteli)"
//   => x=0 = ČELO k nepříteli: rovná široká stěna 7,40 m + UŠI-KŘÍDLA na bocích
//   => x=X_tyl = TÝL: úzká rovná stěna 4,0 m se zapuštěným VCHODEM
//
// Geometrie dle řezové analýzy referenčního STL (Vilda/makerworld 769524,
// normalizace 105 mm = 8,70 m [DENK]) — zrcadleno dle správné orientace.
//
// POUŽITÍ:
//   openscad -o korpus.stl -D "scale_denom=87" -D "part=0" -D "variant=180" ropik-a.scad
//   openscad -o strecha.stl -D "scale_denom=87" -D "part=1" -D "variant=180" ropik-a.scad
//   scale_denom: 87=H0, 120, 144=N, 72, 48, 35 | variant: 120|140|160|180|200|220
// ============================================================

/* [Parametry] */
scale_denom = 87;       // jmenovatel měřítka
part = 0;               // 0=korpus, 1=střecha
variant = 180;          // úhel os střílen (120–220)
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

W = width_variant(variant);   // max šířka přes UŠI [m]

// ---------- Topologie v8.4 (orientace dle Vilda + REF STL zrcadleno) ----------
X_cel  = 0;      // ČELO k nepříteli — rovná široká stěna
W_cel  = 7.40;   // šířka čelní stěny [REF: 90/105 mm × 8,70]
X_kr_f = 0.30;   // přední líc ucha (hned za čelem)
d_kr   = 1.00;   // hloubka ucha [REF ≈ 1,0 m]
X_kr_b = X_kr_f + d_kr;   // zadní líc ucha
W_body = 7.15;   // šířka těla mezi ušima a rameny [REF: 86–89 mm]
X_sh   = X_kr_b + 0.35;   // konec boků těla, začátek ramen
X_tyl  = 5.30;   // TÝL — rovná úzká stěna [REF: 64/105 mm × 8,70]
W_tyl  = 4.00;   // šířka týlní stěny [REF: 48/105 mm × 8,70]

h_int  = 1.70;   // světlá vnitřní výška [≈ — ověřit z KST A140Z_rezy]
h_cor  = 1.40;   // výška vstupní chodby [≈]
w_door = 0.65;   // šířka vchodu [DENK]
d_alc  = 0.50;   // hloubka zapuštěného portálku [≈ fotodok.]
w_strel = 0.30;  // šířka střílny [≈]
h_strel = 0.28;  // výška střílny [≈]
z_strel = 0.95;  // spodní hrana střílny nad podlahou [≈]

prov = provedeni == "zeslabene" ? [0.60,0.55] : provedeni == "zesilene" ? [1.00,1.20] : [0.80,0.80];
t_wall = prov[0];
t_roof = prov[1];

// ---------- Měřítko ----------
function mm(m) = m * 1000 / scale_denom;
S = 1000 / scale_denom;

// ---------- Půdorys (x=0 čelo k nepříteli, +x týl; y=0 osa) ----------
module hull2d() {
  scale([S, S])
  polygon([
    [X_cel,   W_cel/2],   // ČELO P (rovná stěna 7,40 m)
    [X_kr_f,  W_cel/2],   // bok čela P → ucho
    [X_kr_f,  W/2],       // vnější boku ucha P
    [X_kr_b,  W/2],       // STŘÍLNÁ STĚNA P — boční palba +Y
    [X_kr_b,  W_body/2],  // návrat ucha k tělu
    [X_sh,    W_body/2],  // bok těla P (konstantní šířka)
    [X_tyl,   W_tyl/2],   // šikmé rameno → TÝL
    [X_tyl,  -W_tyl/2],   // TÝL — rovná stěna 4,0 m (VCHOD)
    [X_sh,   -W_body/2],  // rameno L
    [X_kr_b, -W_body/2],
    [X_kr_b, -W/2],       // STŘÍLNÁ STĚNA L — boční palba -Y
    [X_kr_f, -W/2],       // vnější boku ucha L
    [X_kr_f, -W_cel/2],   // bok čela L
    [X_cel,  -W_cel/2],   // ČELO L
  ]);
}

// ---------- KORPUS ----------
module korpus() {
  difference() {
    linear_extrude(height = mm(h_int))
      hull2d();
    // vnitřní dutina (otevřená shora — oddělávací střecha)
    translate([0, 0, mm(0.08)])
      linear_extrude(height = mm(h_int))
        offset(delta = -mm(t_wall))
          hull2d();
    // zapuštěný portálek + průchod V TÝLNÍ STĚNĚ [Vilda 10:59: vchod v tylové straně]
    translate([mm(X_tyl - d_alc), -mm(w_door)/2, mm(0.10)])
      cube([mm(d_alc + t_wall + 0.05), mm(w_door), mm(h_cor)]);
    // střílnové otvory — vnější stěny uší (y=±W/2), palba PODÉL linie ±Y
    if (strilny) {
      for (m = [1, -1]) {
        translate([mm(X_kr_b) - mm(0.5), m > 0 ? mm(W/2 - 0.60) : mm(-W/2 - 0.60), mm(z_strel)])
          cube([mm(1.0), mm(1.2), mm(h_strel)]);
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

echo(str("LO vz.37 A-", variant, " v8.4 | 1:", scale_denom, " | part: ", part==0?"KORPUS":"STŘECHA"));
echo(str("ČELO 7,40 m + uši-křídla (boční palba ", variant, "°) k NEPŘÍTELI | TÝL 4,0 m s VCHODEM"));
echo(str("Šířka přes uši ", W, " m [DENK] | hloubka ", X_tyl, " m [REF] | výšky [≈ KST k ověření]"));