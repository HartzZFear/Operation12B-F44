# Projekt-Setup FitFuerInfo (Mission12B)

Anleitung für die Einrichtung des Arbeitsplatzes. Einmal komplett durchgehen,
danach reicht der Abschnitt "Täglicher Ablauf" am Ende.

Aufwand: ca. 30–45 Minuten.

---

## 1. XAMPP installieren

**Wichtig: Es muss Version 5.6.36 sein, nicht die neueste.**

Der Schulrechner hat XAMPP 5.6.36 mit PHP 5.6. Wenn wir zu Hause auf PHP 8
entwickeln, läuft bei der Abgabe auf dem Schulrechner nichts mehr. Deshalb
arbeiten alle drei mit derselben Version.

**Download:**
`sourceforge.net/projects/xampp/files/XAMPP Windows/5.6.36/`
→ Datei `xampp-win32-5.6.36-0-VC11-installer.exe`

Für 5.6 gibt es nur die 32-Bit-Variante. Die läuft auf 64-Bit-Windows
problemlos.

**Installation:**

1. Installer starten. Die UAC-Warnung mit OK bestätigen – die kommt immer.
2. Installationspfad: **`C:\xampp` beibehalten**, nicht nach
   `C:\Program Files (x86)` installieren. Dort fehlen Schreibrechte und
   Apache kann keine Dateien anlegen.
3. Den Vorschlag, UAC per msconfig abzuschalten, ignorieren. Unnötig.
4. Bei den Komponenten reichen Apache, MySQL und phpMyAdmin.

**Prüfen, ob es läuft:**

1. XAMPP Control Panel öffnen, bei **Apache** und **MySQL** auf Start klicken.
   Beide müssen grün hinterlegt sein.
2. Im Browser `http://localhost/dashboard` aufrufen → XAMPP-Seite erscheint.
3. Im Browser `http://localhost/phpmyadmin` aufrufen → phpMyAdmin erscheint.

**Wenn Apache nicht startet:** Meist belegt ein anderes Programm Port 80
(Skype, IIS, VMware). Im Control Panel steht die Ursache im Log. Fix: in
`C:\xampp\apache\conf\httpd.conf` `Listen 80` auf `Listen 8080` ändern, dann
läuft alles unter `http://localhost:8080/`.

**PHP-Version kontrollieren:** Im Control Panel neben Apache auf "Config" →
"PHP (php.ini)". Oben in der Titelzeile oder über `http://localhost/dashboard`
muss PHP 5.6.x stehen.

---

## 2. Git installieren und Repo klonen

**Git installieren:** `git-scm.com` → Download for Windows. Bei der
Installation alle Standardeinstellungen durchklicken.

**Repo klonen** – Eingabeaufforderung öffnen (Windows-Taste, "cmd" eingeben):

```
cd C:\xampp\htdocs
git clone https://github.com/HartzZFear/Mission12B.git fitfuerinfo
cd fitfuerinfo
git config user.name "DEIN-GITHUB-NAME"
git config user.email "deine@mail.de"
```

Das Projekt liegt jetzt unter `C:\xampp\htdocs\fitfuerinfo` und ist später
im Browser unter `http://localhost/fitfuerinfo` erreichbar.

**Nicht als ZIP herunterladen.** Beim ZIP fehlt der `.git`-Ordner. Ohne den
kann man nicht committen, nicht pushen und sieht keine Änderungen der
anderen. Nur der Klon funktioniert.

---

## 3. GitHub-Zugang einrichten (Personal Access Token)

Beim ersten Push fragt Git nach Anmeldedaten. **Das GitHub-Passwort
funktioniert dort nicht mehr**, es wird ein Token gebraucht. Jeder erstellt
sich einen eigenen.

1. GitHub öffnen → Profilbild oben rechts → **Settings**
   (Account-Settings, nicht die Repo-Settings)
2. Linke Seitenleiste ganz nach unten → **Developer settings**
3. **Personal access tokens** → **Tokens (classic)**
4. Rechts oben **Generate new token** → **Generate new token (classic)**
5. Ausfüllen:
   - Note: `Mission12B lokal`
   - Expiration: 90 days
   - Scopes: nur den obersten Haken bei **`repo`** setzen
6. Unten **Generate token**
7. **Der Token wird nur einmal angezeigt.** Sofort kopieren und sicher
   ablegen. Nicht ins Repo committen, nicht in WhatsApp schicken.

Beim ersten `git push`:
- Username: dein GitHub-Benutzername
- Password: der Token (beginnt mit `ghp_`)

Windows merkt sich das danach. Falls man sich vertippt und der Push
fehlschlägt, merkt sich Windows die falschen Daten: Systemsteuerung →
Anmeldeinformationsverwaltung → Windows-Anmeldeinformationen → Eintrag
`git:https://github.com` löschen, dann neu pushen.

**Alternative ohne Token:** GitHub Desktop installieren und einmal per
Browser einloggen. Clone, Commit und Push laufen dann per Klick. Für den
Einstieg völlig in Ordnung.

---

## 4. Datenbank einrichten

Jeder hat seine **eigene lokale Datenbank**. Es gibt keine zentrale DB auf
einem Rechner – das wäre bei der Abgabe auf dem Schulrechner nicht
erreichbar. Synchronisiert wird über die SQL-Dateien im Repo.

Die beiden Dateien liegen nach dem Klonen bereits unter
`C:\xampp\htdocs\fitfuerinfo\db\`.

**Import:**

1. `http://localhost/phpmyadmin` öffnen
2. Reiter **Importieren** → `db/schema.sql` auswählen → OK
   (legt die Datenbank `fitfuerinfo` mit allen Tabellen an)
3. Links in der Baumansicht **`fitfuerinfo` anklicken**
4. Wieder **Importieren** → `db/seed.sql` → OK (Testdaten)

**Diese Meldungen sind normal und kein Fehler:**
- `#1051 Unbekannte Tabelle` – kommt von `DROP TABLE IF EXISTS`. Bei einer
  frischen DB gibt es die Tabellen noch nicht.
- `#1046 Keine Datenbank ausgewählt` – löst sich durch das `USE fitfuerinfo`
  direkt danach auf.

**Kontrolle:** Links auf `fitfuerinfo` klicken. Es müssen **neun Tabellen**
da sein: `benutzer`, `buchung`, `kurs`, `kurs_eigentuemer`, `kurs_software`,
`raum`, `raum_bearbeiter`, `raum_software`, `software`.
`benutzer` hat 5 Zeilen, `buchung` hat 7.

**Testkonten** (Passwort für die ersten vier: `test1`):

| Benutzer  | Rolle       | aktiv | Passwort              |
|-----------|-------------|-------|------------------------|
| admin     | admin       | ja    | `test1`                |
| lena      | mitarbeiter | ja    | `test1`                |
| markus    | mitarbeiter | ja    | `test1`                |
| sabine    | mitarbeiter | nein  | `test1`                |
| neuling   | mitarbeiter | ja    | noch keins – siehe Abschnitt 6 |

---

## 5. Konfiguration anlegen und Selbsttest

Die Datei `src/config.php` enthält die lokalen Zugangsdaten zur Datenbank.
Sie liegt **nicht** im Repo, weil sie bei jedem anders aussehen kann. Im Repo
liegt nur die Vorlage `src/config.example.php`.

In der Eingabeaufforderung:

```
cd C:\xampp\htdocs\fitfuerinfo
copy src\config.example.php src\config.php
```

Bei einer frischen XAMPP-Installation passen die Standardwerte
(Benutzer `root`, kein Passwort). Nur wer sein MySQL abgesichert hat, trägt
in `src/config.php` seine eigenen Daten ein.

**Selbsttest aufrufen:** `http://localhost/fitfuerinfo/test.php`

Die Seite prüft der Reihe nach:

1. PHP-Version ist 5.6.x
2. PDO-MySQL-Treiber ist geladen
3. `src/config.php` ist vorhanden
4. Verbindung zur Datenbank steht
5. Alle neun Tabellen sind da
6. Testdaten sind importiert
7. `password_verify('test1', ...)` funktioniert gegen den Admin-Hash

**Wenn alle sieben Zeilen auf OK stehen, ist die Einrichtung fertig.** Steht
irgendwo FEHLER, sagt die Spalte "Ergebnis", was zu tun ist.

`test.php` ist nur ein Hilfsmittel für die Einrichtung und fliegt vor der
Abgabe wieder raus.

---

## 6. Zugang und Passwörter

Der Systemverwalter (Rolle `admin`) darf Zugang gewähren und entziehen, darf
aber zu keinem Zeitpunkt ein Passwort kennen – auch nicht das erste. Deshalb
läuft die Einrichtung eines Kontos in zwei Schritten:

1. **Admin legt das Konto an** (Benutzername, optional E-Mail, Rolle). Ein
   Passwort wird dabei nicht vergeben. Stattdessen erzeugt das System einen
   einmaligen **Freischaltcode** (8 Zeichen, siehe `erzeuge_freischaltcode()`
   in `src/auth.php`) und zeigt ihn dem Admin an.
2. **Mitarbeiter öffnet `src/pages/passwort_setzen.php`**, gibt seinen
   Benutzernamen und den Freischaltcode ein und vergibt sein Passwort selbst.
   Der Code wird dabei entwertet (nur einmal gültig) und funktioniert danach
   nicht mehr.
3. Ab da läuft die Anmeldung ganz normal über `src/pages/login.php` mit
   Benutzername und Passwort.

Passwortregel laut Aufgabenstellung: mindestens `PW_MIN_LAENGE` (Standard: 4)
Zeichen, darunter mindestens ein Kleinbuchstabe und mindestens eine Ziffer.
Geprüft wird das über `pruefe_passwortregeln()` in `src/auth.php`.

**Zum Ausprobieren** liegt in `db/seed.sql` ein fünfter Testbenutzer bereit,
der noch kein Passwort hat:

| Benutzer  | Freischaltcode | Gültig bis  |
|-----------|----------------|-------------|
| `neuling` | `START123`     | 2027-12-31  |

Damit lässt sich der komplette Ablauf lokal durchspielen:
`src/pages/passwort_setzen.php` öffnen, `neuling` und `START123` eingeben,
ein Passwort vergeben (z. B. `abc1`), danach mit `neuling` und diesem
Passwort auf `src/pages/login.php` anmelden. Ein zweiter Versuch mit
demselben Code schlägt danach erwartungsgemäß fehl.

---

## 7. Teamregeln

Diese sechs Punkte sind das, woran Gruppenprojekte sonst scheitern.

**1. Datenbankänderungen immer über `schema.sql`.**
Wer eine Tabelle oder Spalte ändert, ändert **die Datei** und pusht sie –
nicht nur lokal in phpMyAdmin klicken. Die anderen ziehen und importieren
neu. Ohne diese Regel hat nach drei Tagen jeder ein anderes Datenmodell.

Struktur aus der lokalen DB zurück in die Datei schreiben:

```
C:\xampp\mysql\bin\mysqldump -u root --no-data fitfuerinfo > db\schema.sql
C:\xampp\mysql\bin\mysqldump -u root --no-create-info fitfuerinfo > db\seed.sql
```

**2. SQL immer über `abfrage()`, Ausgaben immer über `h()`.**
Beide Funktionen stehen in `src/db.php`:

```php
require_once __DIR__ . '/../src/db.php';

$kurse = abfrage('SELECT * FROM kurs WHERE ersteller_id = ?', array($id))->fetchAll();
echo h($kurs['titel']);
```

Werte niemals per Stringverkettung ins SQL schreiben – immer als Parameter
übergeben. Damit sind SQL-Injection und XSS von Anfang an erledigt, und wir
können das in der Doku als bewusste Entscheidung beschreiben.

**3. Nur PHP-5.6-Syntax verwenden.**
Nicht erlaubt, weil erst ab PHP 7 verfügbar:
- `??` (Null-Coalescing) → stattdessen `isset($x) ? $x : ''`
- Typdeklarationen wie `function f(int $x): bool`
- Arrow Functions `fn() =>`, `match`, `str_contains()`, `<=>`
- Typed Properties

Erlaubt und erwünscht: `password_hash()` / `password_verify()`, PDO mit
Prepared Statements, Sessions, `[]`-Array-Syntax.

**4. Nie direkt auf `main-prd` arbeiten.**
`main-prd` bleibt immer lauffähig. Gearbeitet wird in Feature-Branches, die
nach `main-dev` gemerged werden:

```
git checkout main-dev
git pull
git checkout -b feature-login
```

**5. `config.php` wird nicht committet.**
Sie steht in der `.gitignore`, weil sie lokale Zugangsdaten enthält. Im Repo
liegt nur `config.example.php` als Vorlage (siehe Abschnitt 5). Wer eine neue
Einstellung braucht, trägt sie **auch in die Vorlage** ein, sonst fehlt sie
bei den anderen.

**6. Vor dem Arbeiten immer `git pull`.**
Kostet fünf Sekunden und erspart die meisten Merge-Konflikte.

---

## Täglicher Ablauf

```
cd C:\xampp\htdocs\fitfuerinfo
git checkout main-dev
git pull

git checkout -b feature-XYZ
... arbeiten ...

git status
git add .
git commit -m "Kurze Beschreibung, was gemacht wurde"
git push -u origin feature-XYZ
```

Danach auf GitHub den Pull Request von `feature-XYZ` nach `main-dev`
erstellen. Ein anderer aus dem Team schaut drüber und merged.

`git status` vor dem Commit zeigt, was wirklich reingeht – kurz prüfen, ob
da nichts Unerwartetes dabei ist.

---

## Wenn etwas nicht klappt

| Problem | Ursache / Lösung |
|---|---|
| Apache startet nicht | Port 80 belegt → auf 8080 umstellen (siehe Abschnitt 1) |
| MySQL startet nicht | Port 3306 belegt, meist von einer anderen MySQL-Installation |
| `fatal: pathspec ... did not match` | Datei liegt nicht da, wo Git sie erwartet – Pfad prüfen |
| Push wird abgelehnt | Token falsch oder abgelaufen → Anmeldeinformationsverwaltung leeren |
| Seite zeigt PHP-Code statt Ausgabe | Apache läuft nicht oder Datei liegt außerhalb von `htdocs` |
| `.gitignore` heißt `gitignore.txt` | Windows hängt `.txt` an → im Explorer Dateiendungen einblenden und umbenennen |
| `test.php` meldet "src/config.php fehlt" | Vorlage noch nicht kopiert → Abschnitt 5 |
| `test.php` meldet PHP 8.x | Falsche XAMPP-Version installiert → Abschnitt 1 |

---

## Checkliste

- [ ] XAMPP 5.6.36 installiert, Apache und MySQL starten grün
- [ ] `http://localhost/phpmyadmin` erreichbar
- [ ] Git installiert, Repo nach `C:\xampp\htdocs\fitfuerinfo` geklont
- [ ] `git config user.name` und `user.email` gesetzt
- [ ] Personal Access Token erstellt und sicher abgelegt
- [ ] `schema.sql` und `seed.sql` importiert, neun Tabellen sichtbar
- [ ] `src/config.php` aus der Vorlage erstellt
- [ ] `http://localhost/fitfuerinfo/test.php` zeigt siebenmal OK
- [ ] Kanban-Board auf Logineo geöffnet, eigene Karten zugewiesen
