# TrendVault macOS
TrendVault ist ein lokales Pinterest für Kreative, mit Fokus auf Marketer.

Die iOS App dient dem Sammeln von Inspiration.
Die macOS App ist das Studio für Organisation, Moodboards, Vergleich und Export.

## Ziel
- iPhone rein, Mac zeigt es automatisch
- Kein Ordner-Gefrickel, kein Export/Import
- Performance-first bei großen Bibliotheken

## Kernprinzip
- iOS: Capture & Tag (keine Boards)
- macOS: Organize & Create (Boards, Bulk, Compare, Export)
- Sync: iCloud via CloudKit (Apple Magic)
- Darstellung: Thumbnail-first, Full-res Assets werden lazy geladen und lokal gecached

## Funktionen macOS v1
- Inbox Grid mit Zoom Stufen
- Suche (Tags, später optional OCR Text)
- Detail View mit Metadaten Editing
- Boards (Moodboards)
- Drag & drop in Boards, Reordering
- Bulk Aktionen (Multi Select)
- Compare View (2–6 Items)
- Export v0 (Auswahl oder Board, Copy Image, Copy Tags)

## Datenmodell (High Level)
- TrendItem
  - id, createdAt, modifiedAt
  - tags, source, note
  - optional ocrText
  - thumbnailData
  - imageAssetRef (Full-res)
- Board
  - id, title, sortOrder, optional cover
- BoardItem (Join)
  - boardID, itemID, position

## Löschen
- Delete ist global
- Wenn ein Item gelöscht wird, verschwindet es überall inklusive Boards
- Beide Apps müssen löschen können
- iOS kann zusätzliche Sicherheitsabfrage nutzen, wenn ein Item in Boards verwendet wird

## Sync Hinweis
Das Produktziel ist automatische Synchronisierung über CloudKit.
Ein manuelles “Sync jetzt” wird nicht als Standard UX vorgesehen.
Optional kann es eine Debug oder Retry Funktion geben.

## Projektstatus
Siehe:
- `TrendVault_Roadmap.md`
- `TrendVault_Pflichtenheft.md`

## Development Workflow
- Entwicklung erfolgt chunk-basiert
- Jeder Chunk endet mit einem Git-Commit
- GPT Instanzen arbeiten streng nach dem Start Prompt
