// ============================================================
// LO vz. 37 — typ A-180 (řopík) — parametrický model pro 3D tisk
// Katalog ŘOP — klepeto.kuzelovi.cz/rop
// Data: Denkschrift OKH 1941 (via ropiky.cz), viz data/typ-a-180.json
//
// Model: dva SAMOSTATNÉ objekty (korpus + střecha) vyexportované
// zvlášť — střecha pak fyzicky "oddělávací". Vše sedí na Z=0 (buildplate).
//
// POUŽITÍ:
//   openscad -o korpus-1_87.stl -D "scale_denom=87" -D "part=0" ropik-a180.scad
//   openscad -o strecha-1_87.stl -D "scale_denom=87" -D "part=1" ropik-a180.scad
//   scale_denom: 87=H0, 120, 144=N, 72, 48, 35
// ============================================================

/* [Parametry] */
scale_denom = 87;    // jmenovatel měřítka
part = 0;            // 0=korpus, 1=střecha (export zvlášť)
provedeni = "normal";// zeslabene/normal/zesilene
roof_tol_mm = 0.25;  // vůle střechy (mm v měřítku)

// ---------- Data (metry) ----------
W = 8.70;            // šířka týlní stěny (A-180, Denkschrift)
Wf = 6.96;           // šířka plochého čela (poměr 240/300 ze SVG plánu ropiky.cz)
D = 5.51;            // hloubka čelo→tyl (poměr 190/300 ze SVG; label '6,5 m' = max varianta)
h_int = 1.70;        // světlá vnitřní výška střelecké místnosti
h_cor = 1.40;        // vnitřní výška vstupní chodby
w_door = 0.65;       // šířka vchodu

prov = provedeni == "zeslabene" ? [0.60,0.55] : provedeni == "zesilene" ? [1.00,1.20] : [0.80,0.80];
t_wall = prov[0];
t_roof = prov[1];

// ---------- Měřítko ----------
function mm(m) = m * 1000 / scale_denom;

// ---------- Půdorys (rovina XY, čelo -X, týl +X=0 na svislé stěně) ----------
// Kosočtverec: hrot (-D,0), týlní rohy (0,±W/2) — ŠKÁLOVANÉ do mm modelu
S = 1000 / scale_denom;
module hull2d() {
  scale([S, S])
  polygon([           // LICHOBĚŽNÍK — ploché čelo (SVG ropiky.cz), ne hrot!
    [0, -W/2],        // týlní levý roh (týl = rovná stěna s vchodem)
    [0,  W/2],        // týlní pravý roh
    [-D,  Wf/2],      // čelní pravý roh (čelo ploché, užší)
    [-D, -Wf/2],      // čelní levý roh
  ]);
}

// ---------- KORPUS (bez střechy) ----------
module korpus() {
  difference() {
    // masiv zvenku
    linear_extrude(height = mm(h_int))
      hull2d();
    // vnitřní dutina — odsazení stěn (offset -t_wall), od Z=0 výš (podlaha zůstane plná)
    translate([0, 0, mm(0.10)])
      linear_extrude(height = mm(h_int))   // protne strop → otevřený shora
        offset(delta = -mm(t_wall))
          hull2d();
    // vstupní otvor v týlní stěně (průchod v rovině X=0)
    translate([-mm(t_wall) - 1, -mm(w_door)/2, mm(0.10)])
      cube([mm(t_wall) + 2, mm(w_door), mm(h_cor)]);
  }
}

// ---------- STŘECHA (samostatná deska) ----------
module strecha() {
  // deska leží samostatně na buildplate (Z=0) — při tisku zvlášť,
  // na model pak jen položí: spodní hrana = vršek korpusu.
  // Pozor: offset delta na ostrém hrotu nafoukne rohy (delta/sin(úhel/2))
  // → vůle jen roof_tol_mm, žádné velké přesahy (23.10.2026: mm(0.15) udělalo +4.4 mm na hrotu)
  linear_extrude(height = mm(t_roof))
    offset(delta = roof_tol_mm)
      hull2d();
}

// ---------- Export ----------
$fn = 80;
if (part == 0) {
  korpus();
} else {
  strecha();
}

echo(str("LO vz.37 A-180 | 1:", scale_denom, " | part: ", part==0?"KORPUS":"STŘECHA",
         " | Vnější: ", W, "×", D, " m → ", mm(W), "×", mm(D), " mm"));
echo(str("Provedeni: ", provedeni, " | stěna ", t_wall, " m, strop ", t_roof, " m | vůle střechy ", roof_tol_mm, " mm"));