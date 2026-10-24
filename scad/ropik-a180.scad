// ============================================================
// LO vz. 37 — typ A-180 (řopík) — parametrický model pro 3D tisk
// Katalog ŘOP — klepeto.kuzelovi.cz/rop | GitHub: Vilda007/rop2stl
// Data: Denkschrift OKH 1941 + fotodokumentace (Hnanice) — korigováno 24.10.2026
//
// GEOMETRIE v4 — finální, sladěno přes všechny prameny:
//   - ČELO = CHEVRON: dvě stěny se sbíhají k centrálnímu hrotu (apex) směrem
//     k nepříteli (odražení střel, fotka Hnanice to potvrzuje)
//   - STŘÍLNY = RIZALITY v přední části boků: boky vybíhají ven o ~1,1 m,
//     vnější stěny střílen jsou KOLMÉ na podélnou osu → střílny míří
//     PODÉL LINIE (boční palba — klíčová koncepce vz. 37)
//   - TÝL = rovná stěna se zapuštěným vstupním portálkem
//   - Šířka přes rizality ~9,2 m > týl ~7,0 m; délka ~5,8 m
//
// POUŽITÍ:
//   openscad -o korpus-1_87.stl -D "scale_denom=87" -D "part=0" ropik-a180.scad
//   openscad -o strecha-1_87.stl -D "scale_denom=87" -D "part=1" ropik-a180.scad
//   scale_denom: 87=H0, 120, 144=N, 72, 48, 35
// ============================================================

/* [Parametry] */
scale_denom = 87;     // jmenovatel měřítka
part = 0;             // 0=korpus, 1=střecha
provedeni = "normal"; // zeslabene/normal/zesilene
roof_tol_mm = 0.25;   // vůle střechy (mm v měřítku)
strilny = 1;          // 1=prostříznuté střílnové otvory (průhled dovnitř)

// ---------- Data (metry, A-180 dle Denkschrift/fotky) ----------
Y_tyl  = 3.50;        // ±3,50 → týlní stěna 7,00 m
Y_ris  = 4.60;        // ±4,60 → šířka PŘES rizality 9,20 m
X_ris  = 2.50;        // dosah rovného boku (od tylu k výskoku rizalitu)
X_str  = 3.80;        // x střílnové stěny (rizalit 1,30 m hluboký)
X_apex = 5.80;        // apex chevronu (od tylu)
h_int  = 1.70;        // světlá vnitřní výška
h_cor  = 1.40;        // výška vstupní chodby
w_door = 0.65;        // šířka vchodu
d_alc  = 0.50;        // hloubka zapuštěného portálku
w_strel = 0.30;       // šířka střílnového otvoru
h_strel = 0.28;       // výška střílnového otvoru
z_strel = 0.95;       // spodní hrana střílny nad podlahou

prov = provedeni == "zeslabene" ? [0.60,0.55] : provedeni == "zesilene" ? [1.00,1.20] : [0.80,0.80];
t_wall = prov[0];
t_roof = prov[1];

// ---------- Měřítko ----------
function mm(m) = m * 1000 / scale_denom;
S = 1000 / scale_denom;

// ---------- Půdorys (x=0 týl, čelo -x, y=0 podélná osa) ----------
// Boční palba: střílnové stěny (x=-X_str, y ±Y_ris) jsou KOLMÉ na osu X,
// střílny míří ±Y podél linie. Chevron: sběrné stěny od rizalitů k apexu.
module hull2d() {
  scale([S, S])
  polygon([
    [0,        -Y_tyl ],   // týl L
    [0,         Y_tyl ],   // týl P
    [-X_ris,    Y_tyl ],   // rovný bok P
    [-X_ris,    Y_ris ],   // výskok rizalitu P (ven o 1,10 m)
    [-X_str,    Y_ris ],   // STŘÍLNÁ STĚNA P (kolmá na X → palba +Y)
    [-X_apex,   0     ],   // APEX chevronu (čelo)
    [-X_str,   -Y_ris ],   // STŘÍLNÁ STĚNA L (palba -Y)
    [-X_ris,   -Y_ris ],   // rizalit L
    [-X_ris,   -Y_tyl ],   // rovný bok L
  ]);
}

// ---------- KORPUS ----------
module korpus() {
  difference() {
    linear_extrude(height = mm(h_int))
      hull2d();
    // vnitřní dutina (světlý prostor, otevřený shora — střecha zvlášť)
    translate([0, 0, mm(0.08)])
      linear_extrude(height = mm(h_int))
        offset(delta = -mm(t_wall))
          hull2d();
    // zapuštěný vstupní portálek + průchod v týlní stěně
    translate([-mm(d_alc), -mm(w_door)/2, mm(0.10)])
      cube([mm(d_alc + t_wall + 0.05), mm(w_door), mm(h_cor)]);
    // střílnové otvory — na střílnových stěnách (x=-X_str), míří ±Y
    if (strilny) {
      for (m = [1, -1]) {
        // blok ve směru Y prostříhne střílnovou stěnu rizalitu
        translate([-mm(X_str) - mm(0.5), m*(mm(Y_ris) - mm(0.6)), mm(z_strel)])
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
$fn = 80;
if (part == 0) {
  korpus();
} else {
  strecha();
}

echo(str("LO vz.37 A-180 v4 | 1:", scale_denom, " | part: ", part==0?"KORPUS":"STŘECHA"));
echo(str("Chevron apex ", X_apex, " m | rizality ±", Y_ris, " (šířka ", 2*Y_ris, " m) | týl ", 2*Y_tyl, " m | střílny PODÉL linie"));