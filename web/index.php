<?php header("X-Powered-By:"); ?>
<!DOCTYPE html>
<html lang="cs">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ŘOP Katalog — objekty lehkého opevnění 1935–1938 | Klepeto</title>
<meta name="description" content="Katalog objektů československého lehkého opevnění (ŘOP) s parametrickými modely pro 3D tisk v zadaném měřítku.">
<link rel="stylesheet" href="style.css">
<link rel="icon" href="favicon.svg" type="image/svg+xml">
</head>
<body>
<header class="site-header">
  <div class="wrap">
    <a href="index.php" class="brand">ŘOP<span>Katalog</span></a>
    <nav class="main-nav">
      <a href="index.php" class="active">Katalog</a>
      <a href="#o-katalogu">O katalogu</a>
      <a href="https://github.com/Vilda007/rop2stl" target="_blank" rel="noopener">GitHub ↗</a>
    </nav>
  </div>
</header>

<main>
<section class="hero">
  <div class="wrap">
    <h1>Objekty československého opevnění<br><em>1935–1938</em></h1>
    <p class="lead">Rozměry, půdorysy a parametrické modely pro 3D tisk v libovolném měřítku.
    Každý objekt s oddělávací střechou pro prohlídku interiéru. Data z dobových pramenů.</p>
    <div class="hero-badges">
      <span class="badge">LO vz. 36</span>
      <span class="badge">LO vz. 37 A–E</span>
      <span class="badge badge-dim">TO (v přípravě)</span>
    </div>
  </div>
</section>

<section class="wrap" id="katalog">
  <h2>Katalog objektů</h2>
  <div class="grid">

<?php
// --- data karet (později z DB) ---
$objects = array(
  array(
    'id' => 'a-180', 'badge' => 'PILOT',
    'title' => 'LO vz. 37 — typ A', 'subtitle' => 'A-120 · A-140 · A-160 · A-180 · A-200 · A-220',
    'desc' => 'Ikonický řopík. Dvě boční střílny pro těžké kulomety, boční palba podél linie. Nejrozšířenější typ — cca 85 % všech postavených objektů. Posádka 7 mužů.',
    'status' => 'ready',
    'meta' => array('Postaveno: 9 632 (všechny varianty A)', 'Provedení: zeslabené / normální / zesílené'),
  ),
  array(
    'id' => 'b', 'badge' => '',
    'title' => 'LO vz. 37 — typ B', 'subtitle' => 'B-80 · B-90 · B-100 (B1/B2)',
    'desc' => 'Jedna boční a jedna čelní střílna — pro místa, kde jedna strana nemohla být kryta sousedním objektem. Posádka 7 mužů.',
    'status' => 'data',
    'meta' => array('Data: rozměry k dispozici', 'Model: v přípravě'),
  ),
  array(
    'id' => 'c', 'badge' => '',
    'title' => 'LO vz. 37 — typ C', 'subtitle' => 'C1 · C2',
    'desc' => 'Nejmenší typ s jedinou čelní střílnou. Doplňkový objekt pro týlové polohy. Posádka 4 muži.',
    'status' => 'data',
    'meta' => array('2,30 × 3,10 m', 'Data: rozměry k dispozici'),
  ),
  array(
    'id' => 'd', 'badge' => '',
    'title' => 'LO vz. 37 — typ D', 'subtitle' => 'D',
    'desc' => 'Boční ochrana okolí těžkých objektů — vchody tvrzí a kritické sruby. Cca 4,6 % realizovaných řopíků.',
    'status' => 'data',
    'meta' => array('4,75 × 3,85 m', 'Data: rozměry k dispozici'),
  ),
  array(
    'id' => 'e', 'badge' => '',
    'title' => 'LO vz. 37 — typ E', 'subtitle' => 'E',
    'desc' => 'Nejvzácnější varianta pro malé dominantní kóty s krátkým zamaskováním. Posádka 2 muži, lehký kulomet. Cca 2,9 % objektů.',
    'status' => 'soon',
    'meta' => array('Rozměry: dohledáváme v pramenech'),
  ),
  array(
    'id' => 'lo-vz-36', 'badge' => '',
    'title' => 'LO vz. 36', 'subtitle' => 'Typ A · Typ B',
    'desc' => 'První sériový typ (1936–37) s čelní palbou — předchůdce řopíku, nahrazen pro nižší odolnost a zranitelnost čelních střílen. 864 postavených objektů.',
    'status' => 'soon',
    'meta' => array('Stěny 50/60 cm, strop 60/80 cm', 'Půdorysy: KST archiv'),
  ),
  array(
    'id' => 'to', 'badge' => 'PLÁN',
    'title' => 'Těžké objekty (TO)', 'subtitle' => 'Sruby · Tvrze · Kopule · Zvony',
    'desc' => 'Pěchotní sruby (6 odolnostních stupňů), dělostřelecké tvrze, pozorovací kopule, pancéřové zvony. Katalog v přípravě.',
    'status' => 'planned',
    'meta' => array('Prameny: opevneni.cz E-DB', '1 186 výkresů k dispozici'),
  ),
);

$status_labels = array(
  'ready' => 'Model k dispozici',
  'data' => 'Rozměrová data hotová',
  'soon' => 'V přípravě',
  'planned' => 'Plánováno',
);

foreach ($objects as $o):
  $cls = $o['status'];
  if ($o['status'] === 'ready'): ?>
    <a class="card card-<?php echo $cls; ?>" href="objekt.php?id=<?php echo $o['id']; ?>">
      <?php if ($o['badge']): ?><span class="card-badge"><?php echo $o['badge']; ?></span><?php endif; ?>
      <h3><?php echo $o['title']; ?></h3>
      <p class="card-sub"><?php echo $o['subtitle']; ?></p>
      <p class="card-desc"><?php echo $o['desc']; ?></p>
      <ul class="card-meta">
        <?php foreach ($o['meta'] as $m): echo '<li>' . $m . '</li>'; endforeach; ?>
      </ul>
      <span class="card-status"><?php echo $status_labels[$o['status']]; ?> →</span>
    </a>
  <?php else: ?>
    <div class="card card-<?php echo $cls; ?>">
      <?php if ($o['badge']): ?><span class="card-badge"><?php echo $o['badge']; ?></span><?php endif; ?>
      <h3><?php echo $o['title']; ?></h3>
      <p class="card-sub"><?php echo $o['subtitle']; ?></p>
      <p class="card-desc"><?php echo $o['desc']; ?></p>
      <ul class="card-meta">
        <?php foreach ($o['meta'] as $m): echo '<li>' . $m . '</li>'; endforeach; ?>
      </ul>
      <span class="card-status"><?php echo $status_labels[$o['status']]; ?></span>
    </div>
  <?php endif;
endforeach; ?>
  </div>
</section>

<section class="wrap" id="o-katalogu">
  <h2>O katalogu</h2>
  <div class="about">
    <div>
      <h3>Prameny rozměrů</h3>
      <p>Pouze primární zdroje: <strong>Denkschrift über die tschecho-slowakische Landesbefestigung</strong> (OKH 1941, public domain), originální stavební výkresy z KST archivu (ropiky.net), typologie a půdorysy (ropiky.cz) a E-databáze těžkého opevnění (opevneni.cz). Konflikty mezi prameny vždy uvádíme.</p>
    </div>
    <div>
      <h3>Modely pro 3D tisk</h3>
      <p>Každý typ má parametrický skript <a href="https://github.com/Vilda007/rop2stl" target="_blank" rel="noopener">OpenSCAD</a>: měřítko (1:87 H0, 1:144 N, 1:72, 1:48, 1:35…), provedení odolnosti a <strong>oddělávací střecha</strong> pro prohlídku interiéru. STL vygenerujete jedním příkazem.</p>
    </div>
    <div>
      <h3>Postupně doplňujeme</h3>
      <p>Všechny postavené typy včetně atypů, plánované nedostavěné varianty i těžké objekty. Základ: databáze všech 9 632 LO objektů vz. 37 + 864 objektů vz. 36.</p>
    </div>
  </div>
</section>
</main>

<footer class="site-footer">
  <div class="wrap">
    <p>ŘOP Katalog · <a href="https://klepeto.kuzelovi.cz">klepeto.kuzelovi.cz</a> · data z dobových pramenů · <a href="https://github.com/Vilda007/rop2stl">GitHub</a></p>
    <p class="fine">Historický a technický projekt — modely nejsou hračky. Používání dat s uvedením pramenů.</p>
  </div>
</footer>
</body>
</html>