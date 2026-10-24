<?php header("X-Powered-By:"); ?>
<?php
// Detail karta objektu — data zatím inline, později z DB (viz data/ v rop2stl)
$objects_db = array(
  'a-180' => array(
    'title' => 'LO vz. 37 — typ A, varianta A-180',
    'subtitle' => '„řopík" · lehké opevnění nového typu · 1937–1938',
    'tags' => array('LO vz. 37', 'typ A', 'A-180', 'odolnost I', 'boční palba'),
    'status' => 'ready',
    'desc' => 'Nejrozšířenější československý pevnostní objekt — asi 85 % všech postavených řopíků patří k typu A. Dvě střelecké místnosti s bočními střílnami pro těžký kulomet vz. 37 (ZB-53); palba vede podél linie, ne čelně. Varianta A-180 má osy střílen rozevřené o 180°.',
    'posadka' => '7 mužů (velitel, 2 střelci, 2 nabíječi, 2 pozorovatelé/spojaři)',
    'vyzbroj' => '2× TK vz. 37 (ZB-53), LK vz. 26, pušky vz. 24',
    'variants' => array(
      // varianta => šířka týlní stěny (m), poznámka
      array('A-120', '7,70', '', false),
      array('A-140', '6,95', '', false),
      array('A-160', '7,40', '', false),
      array('A-180', '8,70', 'tento model', true),
      array('A-200', '8,40', '', false),
      array('A-220', '8,70', '', false),
    ),
    'dims' => array(
      array('Čelo (k nepříteli)', 'rovná stěna 7,40 m', 's ušima střílen na bocích — střílny míří PODÉL linie [Vilda 10:59 + REF STL]'),
      array('Uši střílen', '+0,80 m/bok, u čela (0,3–1,3 m)', 'střílnové stěny míří PODÉL linie — boční palba [Vilda 10:59 + REF STL]'),
      array('Šířka přes křídla', '8,70 m', '[DENK — Denkschrift 1941]'),
      array('Šířka těla', '7,15 m', 'konstantní mezi rameny a křídly [REF STL řez 50 %]'),
      array('Týl (s vchodem)', 'úzká stěna 4,0 m', 'zapuštěný portálek 0,50 m + pancéřové dveře 0,65 m [Vilda 10:59 + REF STL]'),
      array('Hloubka (apex→tyl)', '~5,7 m', 'topologie KST škálovaná na šířku A-180 [≈ — A-180 výkres v archivu dosud nenalezen]'),
      array('Tloušťka stěn (normální)', '0,80 m', 'zeslabené 0,60 / normální 0,80 / zesílené 1,00 m [DENK/typologie]'),
      array('Světlovnitřní výška', '1,70 m', '[≈ — k ověření z KST řezů (A140Z_rezy.pdf staženo)]'),
      array('Vchod', '0,65 m', 'pancéřové dveře, zapuštěný portálek [DENK + fotodok.]'),
    ),
    'provenance' => 'Tvar doložen čtyřmi zdroji: referenční STL model (Vilda/makerworld 769524 — řezová analýza, geometrie křídel 75–94 % hloubky), fotodokumentace reálného objektu typu A (Vilda, 8 snímků 24.10.2026 — wide-arrow čelo, rovný týl), Denkschrift OKH 1941 (šířky variant) a KST AIVO03 typové výkresy (A160Z). Konflikt pramenů u A-160: Denkschrift 7,40 m vs KST 6,93 m (uvádíme obě). Dřívější interpretace — chevronový hrot čela a zakulacený týl R4,32 — byly korigovány po srovnání s fotodokumentací; hodnoty [≈] zůstávají k ověření proti dalším KST výkresům.',
  ),
  // další objekty později
);
$id = isset($_GET['id']) ? $_GET['id'] : 'a-180';
$obj = isset($objects_db[$id]) ? $objects_db[$id] : null;
if (!$obj) { http_response_code(404); echo "<h1>404 — objekt nenalezen</h1>"; exit; }
?>
<!DOCTYPE html>
<html lang="cs">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><?php echo $obj['title']; ?> — ŘOP Katalog</title>
<meta name="description" content="<?php echo $obj['subtitle']; ?> — rozměry, půdorys a parametrický model pro 3D tisk.">
<link rel="stylesheet" href="style.css">
<link rel="icon" href="favicon.svg" type="image/svg+xml">
</head>
<body>
<header class="site-header">
  <div class="wrap">
    <a href="index.php" class="brand">ŘOP<span>Katalog</span></a>
    <nav class="main-nav">
      <a href="index.php">Katalog</a>
      <a href="index.php#o-katalogu">O katalogu</a>
      <a href="https://github.com/Vilda007/rop2stl" target="_blank" rel="noopener">GitHub ↗</a>
    </nav>
  </div>
</header>

<main>
<section class="obj-hero">
  <div class="wrap">
    <p class="crumb"><a href="index.php">Katalog</a> / LO vz. 37 / typ A / <strong>A-180</strong></p>
    <h1><?php echo $obj['title']; ?></h1>
    <p class="subtitle"><?php echo $obj['subtitle']; ?></p>
    <div class="obj-tags">
      <?php foreach ($obj['tags'] as $t):
        $accent = ($t === 'A-180') ? ' tag-accent' : ''; ?>
        <span class="tag<?php echo $accent; ?>"><?php echo $t; ?></span>
      <?php endforeach; ?>
    </div>
  </div>
</section>

<div class="wrap obj-layout">

  <!-- LEVÝ SLOUPEC -->
  <div>
    <div class="panel">
      <h2>Rozměry <span class="hint">— primární prameny</span></h2>
      <table class="dims">
        <tr><th>Parametr</th><th>Hodnota</th><th>Poznámka</th></tr>
        <?php foreach ($obj['dims'] as $d): ?>
        <tr>
          <td><?php echo $d[0]; ?></td>
          <td class="num"><?php echo $d[1]; ?></td>
          <td style="color:var(--text-dim);font-size:.82rem"><?php echo $d[2]; ?></td>
        </tr>
        <?php endforeach; ?>
      </table>
      <p class="dim-note">⚖ <?php echo $obj['provenance']; ?></p>
    </div>

    <div class="panel" style="margin-top:22px">
      <h2>Varianty typu A <span class="hint">— rozevření os střílen</span></h2>
      <table class="variants">
        <tr><th>Varianta</th><th>Šířka přes střílny</th><th></th></tr>
        <?php foreach ($obj['variants'] as $v): ?>
        <tr<?php if ($v[3]) echo ' class="hl"'; ?>>
          <td><?php echo $v[0]; ?></td>
          <td class="num"><?php echo $v[1]; ?> m</td>
          <td style="color:var(--text-dim);font-size:.82rem"><?php echo $v[2]; ?></td>
        </tr>
        <?php endforeach; ?>
      </table>
      <p class="dim-note">Číslo varianty = úhel mezi osami střílen. Šířky dle Denkschrift (max. přes střílnová křídla); model A-180 parametrizovatelný na ostatní varianty.</p>
    </div>

    <div class="panel" style="margin-top:22px">
      <h2>Popis objektu</h2>
      <p style="color:var(--text-dim);font-size:.95rem"><?php echo $obj['desc']; ?></p>
      <div class="spec-grid" style="margin-top:1rem">
        <div class="spec"><div class="k">Posádka</div><div class="v">7 mužů</div></div>
        <div class="spec"><div class="k">Vybudováno</div><div class="v num">9 632</div></div>
        <div class="spec"><div class="k">Výzbroj</div><div class="v" style="font-size:.85rem">2× TK ZB-53<br>LK vz. 26</div></div>
        <div class="spec"><div class="k">Betonáž</div><div class="v" style="font-size:.85rem">monolitická<br>24–30 h</div></div>
        <div class="spec"><div class="k">Cena (1938)</div><div class="v num">120–150 tis.</div></div>
      </div>
      <p class="dim-note"><?php echo $obj['posadka']; ?> · <?php echo $obj['vyzbroj']; ?></p>
    </div>
  </div>

  <!-- PRAVÝ SLOUPEC -->
  <div>
    <div class="panel plan-box">
      <h2>Půdorys <span class="hint">— schéma</span></h2>
      <svg viewBox="0 0 320 255" role="img" aria-label="Půdorys LO vz. 37 A-180 — v8.4 (čelo s ušima k nepříteli, týl s vchodem)">
        <path d="M38,40 L282,40 L282,50 L304,50 L304,83 L278,83 L278,94 L226,215 L94,215 L42,94 L42,83 L16,83 L16,50 L38,50 Z"
              fill="rgba(217,164,65,.08)" stroke="#d9a441" stroke-width="2.5" stroke-linejoin="round"/>
        <!-- střílnové otvory na střílnových stěnách uší (boční palba) -->
        <rect x="307" y="52" width="4" height="30" fill="#12151a" stroke="#6b8cae" stroke-width="1.2"/>
        <rect x="9" y="52" width="4" height="30" fill="#12151a" stroke="#6b8cae" stroke-width="1.2"/>
        <!-- vchod v týlu (dole) -->
        <rect x="149" y="211" width="22" height="9" fill="#12151a" stroke="#e8e6e3" stroke-width="1.2"/>
        <!-- šipka k nepříteli -->
        <text x="160" y="26" text-anchor="middle" fill="#c96a5a" font-size="11">▼ NEPŘÍTEL — čelo 7,40 m (rovno) + uši střílen</text>
        <text x="322" y="63" fill="#6b8cae" font-size="10" transform="rotate(90 322 63)">boční palba</text>
        <text x="7" y="63" fill="#6b8cae" font-size="10" transform="rotate(-90 7 63)">boční palba</text>
        <text x="160" y="239" text-anchor="middle" fill="#9aa3af" font-size="11">TÝL 4,0 m · VCHOD 0,65 m (zapuštěný portálek)</text>
        <text x="318" y="122" fill="#9aa3af" font-size="11" transform="rotate(90 318 122)">šířka přes uši 8,70 m [DENK]</text>
      </svg>
      <p class="plan-cap">Půdorys v8.4: rovné čelo 7,40 m s ušima střílen (boční palba) k nepříteli, šikmá ramena, úzký týl 4,0 m s vchodem — orientace dle Vilda (10:59), geometrie dle řezové analýzy referenčního STL.</p>
    </div>

    <div class="panel" style="margin-top:22px">
      <h2>Model pro 3D tisk <span class="hint">— OpenSCAD, parametrický</span></h2>
      <p style="color:var(--text-dim);font-size:.92rem">
        Korpus + <strong>oddělávací střecha</strong> (prohlídka interiéru). Měřítko a provedení
        se nastavuje parametry — STL vygenerujete jedním příkazem:
      </p>
      <div class="print-cmd"><span class="c"># korpus A-180 (1:87 H0) — varianta: 120|140|160|180|200|220</span>
openscad -o korpus-a180-1_87.stl \
  -D "scale_denom=87" -D "part=0" -D "variant=180" ropik-a.scad

<span class="c"># střecha A-180</span>
openscad -o strecha-a180-1_87.stl \
  -D "scale_denom=87" -D "part=1" -D "variant=180" ropik-a.scad</div>
      <p style="color:var(--text-dim);font-size:.85rem">
        Měřítka: <span class="tag">1:87 H0</span> <span class="tag">1:120</span>
        <span class="tag">1:144 N</span> <span class="tag">1:72</span> <span class="tag">1:48</span> <span class="tag">1:35</span>
        · Provedení: zeslabené / normální / zesílené
      </p>
      <ul class="dl-list">
        <a href="https://github.com/Vilda007/rop2stl/raw/main/scad/ropik-a.scad" download>⬇ ropik-a.scad (typ A, volitelná varianta)</a>
        <a href="https://github.com/Vilda007/rop2stl" target="_blank" rel="noopener">⟶ GitHub repozitář</a>
      </ul>
    </div>

    <div class="panel" style="margin-top:22px">
      <h2>Ovládání a výcvik</h2>
      <p style="color:var(--text-dim);font-size:.9rem">
        Cvičení posádek probíhalo zpravidla jednou měsíčně, ve zvýšené pohotovosti (od května 1938)
        byly posádky v kritických úsecích trvale ubytovány v objektech. Při palbě z TK vz. 37
        překračoval hluk uvnitř <strong>140 dB</strong>; bez komínku na odvod prachových plynů
        by obsluha rychle ochláslela.
      </p>
    </div>
  </div>
</div>
</main>

<footer class="site-footer">
  <div class="wrap">
    <p>ŘOP Katalog · <a href="https://klepeto.kuzelovi.cz">klepeto.kuzelovi.cz</a> · data z dobových pramenů · <a href="https://github.com/Vilda007/rop2stl">GitHub</a></p>
    <p class="fine">Historický a technický projekt — modely nejsou hračky. Používání dat s uvedením pramenů.</p>
  </div>
</footer>
</body>
</html>