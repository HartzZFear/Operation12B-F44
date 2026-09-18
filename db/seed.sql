USE fitfuerinfo;

-- ============================================================
-- Testdaten
-- Passwort für alle Testkonten: "test1"
-- (Hash von password_hash('test1', PASSWORD_DEFAULT))
-- ============================================================

INSERT INTO benutzer (name, passwort_hash, rolle, aktiv) VALUES
  ('admin',  '$2y$10$ITlV2jXJ5DzmJCCEK3F7iObgbMpW4E.BDZrcDEwJNsuo77XlbDZIW', 'admin', 1),
  ('lena',   '$2y$10$ITlV2jXJ5DzmJCCEK3F7iObgbMpW4E.BDZrcDEwJNsuo77XlbDZIW', 'mitarbeiter', 1),
  ('markus', '$2y$10$ITlV2jXJ5DzmJCCEK3F7iObgbMpW4E.BDZrcDEwJNsuo77XlbDZIW', 'mitarbeiter', 1),
  ('sabine', '$2y$10$ITlV2jXJ5DzmJCCEK3F7iObgbMpW4E.BDZrcDEwJNsuo77XlbDZIW', 'mitarbeiter', 0);

INSERT INTO software (name) VALUES
  ('VirtualBox'), ('Ubuntu'), ('Kali Linux'), ('Wireshark'), ('Office'), ('Visual Studio Code');

INSERT INTO raum (name, arbeitsplaetze) VALUES
  ('Raum A', 16), ('Raum B', 10), ('Raum C', 20);

INSERT INTO raum_software (raum_id, software_id) VALUES
  (1,1),(1,2),(1,5),(1,6),
  (2,1),(2,3),(2,4),
  (3,5),(3,6);

INSERT INTO kurs (titel, max_teilnehmer, ersteller_id) VALUES
  ('Linux-Grundlagen',     12, 2),
  ('IT-Sicherheit Praxis',  8, 3),
  ('Office für Einsteiger', 16, 2),
  ('Python für Admins',     10, 3);

INSERT INTO kurs_eigentuemer (kurs_id, benutzer_id) VALUES
  (1,2), (2,3), (3,2), (3,3), (4,3);

INSERT INTO kurs_software (kurs_id, software_id) VALUES
  (1,1),(1,2),
  (2,3),(2,4),
  (3,5),
  (4,6);

INSERT INTO raum_bearbeiter (raum_id, benutzer_id) VALUES
  (1,2), (2,3);

INSERT INTO buchung (raum_id, kurs_id, benutzer_id, start, ende) VALUES
  (1, 1, 2, '2026-09-07 08:00:00', '2026-09-07 12:00:00'),
  (1, 1, 2, '2026-09-08 08:00:00', '2026-09-08 12:00:00'),
  (2, 2, 3, '2026-09-08 13:00:00', '2026-09-08 17:00:00'),
  (2, 2, 3, '2026-09-09 13:00:00', '2026-09-09 17:00:00'),
  (3, 3, 2, '2026-09-07 08:00:00', '2026-09-07 12:00:00'),
  (3, 3, 2, '2026-09-09 08:00:00', '2026-09-09 12:00:00'),
  (1, 4, 3, '2026-09-11 08:00:00', '2026-09-11 12:00:00');

-- ============================================================
-- Nützliche Abfragen für die PHP-Umsetzung
-- ============================================================

-- Passende Räume für Kurs :kurs_id
-- (genug Plätze UND alle benötigten Softwarepakete vorhanden)
-- SELECT r.*
-- FROM raum r
-- JOIN kurs k ON k.id = :kurs_id
-- WHERE r.arbeitsplaetze >= k.max_teilnehmer
--   AND NOT EXISTS (
--     SELECT 1 FROM kurs_software ks
--     WHERE ks.kurs_id = k.id
--       AND ks.software_id NOT IN (
--         SELECT rs.software_id FROM raum_software rs WHERE rs.raum_id = r.id
--       )
--   );

-- Überschneidungsprüfung vor dem Speichern einer Buchung
-- SELECT COUNT(*) FROM buchung
-- WHERE raum_id = :raum_id
--   AND start < :neu_ende
--   AND ende  > :neu_start;
-- -> Ergebnis muss 0 sein, sonst Buchung ablehnen

-- Wochenbelegung
-- SELECT b.start, b.ende, r.name AS raum, k.titel AS kurs, u.name AS gebucht_von
-- FROM buchung b
-- JOIN raum r ON r.id = b.raum_id
-- JOIN kurs k ON k.id = b.kurs_id
-- JOIN benutzer u ON u.id = b.benutzer_id
-- WHERE b.start >= :wochenstart AND b.start < :wochenende
-- ORDER BY b.start, r.name;
