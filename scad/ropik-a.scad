// ============================================================
// LO vz. 37 — typ A (řopík) — parametrický model pro 3D tisk
// Katalog ŘOP — klepeto.kuzelovi.cz/rop | GitHub: Vilda007/rop2stl
//
// HISTORICKÁ VĚRNOST v5.1 — topologie dle ORIGINÁLNÍHO typového výkresu
// KST AIVO03/A160Z.pdf (stavební dokumentace ŘOP 1937, 1:25):
//   - čelo = CHEVRON (hrot k nepříteli, sběrné stěny)
//   - KŘÍDLA STŘÍLEN vybíhají z boků, střílnové stěny kolmé na osu
//     → střílny míří PODÉL linie (boční palba — koncepce vz. 37)
//   - TÝL = zakulacený oblouk (KST: R432 na A-160Z), vchod v něm
//
// PROVENIENCE KAŽDÉHO PARAMETRU (historická věrnost):
//   [KST]  = přímé čtení originálního výkresu A160Z (primární pramen)
//   [DENK] = Denkschrift OKH 1941 (zaměření po okupaci)
//   [≈]    = odvozeno škálováním / interpolací — V KATALOGU OZNAČIT, dál ověřovat
//
// KONFLIKT PRAMENŮ (v katalogu uvádět obě hodnoty):
//   A-160 šířka: Denkschrift 7,40 m vs KST A160Z 6,93 m
//   (KST = stavební dokumentace → pro topologii má přednost; rozdíl
//    může být způsobem měření "přes křídla" vs "tělo")
//
// A-180: vlastní typový výkres v archivu dosud nenalezen (A180N.pdf 404);
// šířka 8,70 m [DENK], topologie škálována z A-160Z [≈].
//
// POUŽITÍ:
//   openscad -o korpus-1_87.stl -D "scale_denom=87" -D "part=0" -D "variant=180" ropik-a.scad
//   openscad -o strecha-1_87.stl -D "scale_denom=87" -D "part=1" -D "variant=160" ropik-a.scad
// ============================================================

/* [Parametry] */
scale_denom = 87;       // jmenovatel měřítka (87=H0, 144=N, 72, 48, 35)
part = 0;               // 0=korpus, 1=střecha
variant = 180;          // rozevření os střílen: 120|140|160|180|200|220
provedeni = "normal";   // zeslabene/normal/zesilene
roof_tol_mm = 0.25;     // vůle střechy (mm v měřítku)
strilny = 1;            // 1=prostříznuté střílnové otvory

// ---------- Šířky variant [DENK; A-160 dle KST] ----------
function width_variant(v) =
  v==120 ? 7.70 :                      // [DENK]
  v==140 ? 6.95 :                      // [DENK]
  v==160 ? 6.93 :                      // [KST A160Z — Denkschrift uvádí 7,40, konflikt]
  v==180 ? 8.70 :                      // [DENK]
  v==200 ? 8.40 : 8.70;                // [DENK] (A-220)

W  = width_variant(variant);           // max šířka PŘES KŘÍDLA [m]
W_body = W - 1.60;                     // šířka TĚLA (křídla vybíhají ~0,80 m/bok) [KST A160Z: 80 cm výstupek]
sc = W / 6.93;                         // škálovací poměr k A-160Z [≈]

// ---------- Topologie z KST A160Z ----------
R_tyl  = 4.32;                         // zakulacený týl [KST R432 — na A-160Z]
X_apex = 0;                            // apex čela (referenční bod)
X_wing = 2.70 * sc;                    // dosah rovných boků ke křídlům [KST topologie ≈]
X_str  = X_wing + 0.55;                // střílnová stěna (křídlo ~0,55 m) [≈]
// TÝL oblouk: sahá přes celou šířku W; sagitta (hloubka vydutí) dle proporce
// KST A160Z (sagitta 1,74 m na šířku 6,93 → poměr 0,25 šířky) [≈ škálováno]
sag_tyl = W_body * 0.25;                // [≈ KST proporce A160Z: sagitta/šířka těla]
// poloměr oblouku pro danou půdlici (chord W) a sagittu:
R_arc  = ((W/2)*(W/2) + sag_tyl*sag_tyl) / (2*sag_tyl);
X_rear = X_str + sag_tyl;              // nejhlubší bod tylu [≈]

// zaoblení přechodů křídel [KST R245/246 — aproximováno rotate/ošetřeno $fn]
h_int  = 1.70;                         // světlá výška [≈ — ověřit z KST řezů A140Z_rezy]
h_cor  = 1.40;                         // výška chodby [≈]
w_door = 0.65;                         // vchod [DENK]
d_alc  = 0.50;                         // zapuštěný portálek [≈ fotodok.]
w_strel = 0.30;                        // šířka střílny [≈]
h_strel = 0.28;                        // výška střílny [≈]
z_strel = 0.95;                        // spodní hrana střílny [≈]

prov = provedeni == "zeslabene" ? [0.60,0.55] : provedeni == "zesilene" ? [1.00,1.20] : [0.80,0.80];
t_wall = prov[0];                      // [DENK/KST stupně]
t_roof = prov[1];

// ---------- Měřítko ----------
function mm(m) = m * 1000 / scale_denom;
S = 1000 / scale_denom;

// ---------- Půdorys (x=0 apex čela, +x tyl; y=0 osa) ----------
module hull2d() {
  scale([S, S])
  union() {
    // hlavní tělo: chevron (apex) → boky → křídla (střílnové stěny kolmé na osu)
    polygon([
      [0,       0          ], // APEX čela (chevron)
      [X_wing,  W_body/2   ], // rovný bok těla P končí zde
      [X_wing,  W/2        ], // VÝSKOK křídla P ven (0,80 m [KST]) — kolmice na osu X
      [X_str,   W/2        ], // STŘÍLNÁ STĚNA P (boční palba +Y), křídlo dlouhé 0,55 m
      [X_str,  -W/2        ], // STŘÍLNÁ STĚNA L (boční palba -Y)
      [X_wing, -W/2        ], // návrat křídla L k tělu
      [X_wing, -W_body/2   ], // rovný bok těla L
    ]);
    // ZAKULACENÝ TÝL: kruhová výseč R_arc přes celou šířku W,
    // střed na ose v (X_c, 0), nejhlubší bod X_rear [KST topologie, sagitta ≈]
    intersection() {
      translate([X_str - (R_arc - sag_tyl), 0]) circle(r = R_arc);
      translate([X_str - 0.01, -W_body/2]) square([sag_tyl + 0.02, W_body]);
    }
  }
}

// ---------- KORPUS ----------
module korpus() {
  difference() {
    linear_extrude(height = mm(h_int))
      hull2d();
    // dutina (světlý prostor, otevřený shora — oddělávací střecha)
    translate([0, 0, mm(0.08)])
      linear_extrude(height = mm(h_int))
        offset(delta = -mm(t_wall))
          hull2d();
    // vchod: zapuštěný portálek v zakulaceném týlu na ose
    translate([mm(X_rear - d_alc), -mm(w_door)/2, mm(0.10)])
      cube([mm(d_alc + t_wall + 0.05), mm(w_door), mm(h_cor)]);
    // střílnové otvory — střílnové stěny křídel (x=X_str), směr ±Y
    if (strilny) {
      for (m = [1, -1]) {
        translate([mm(X_str) - mm(0.5), m*(mm(W/2) - mm(0.65)), mm(z_strel)])
          cube([mm(1.0), mm(1.3), mm(h_strel)]);
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

echo(str("LO vz.37 A-", variant, " v5.1 (KST topologie) | 1:", scale_denom, " | part: ", part==0?"KORPUS":"STŘECHA"));
echo(str("Šířka přes křídla ", W, " m, tělo ", W_body, " m [", variant==160 ? "KST 6,93 / DENK 7,40 KONFLIKT" : "DENK", "] | tyl oblouk R", R_tyl, " | hloubka apex→tyl ", X_rear, " m"));
echo(str("PROVENIENCE: topologie [KST A160Z originál] | šířky [DENK] | výšky/střílny [≈ do ověření KST řezy]"));