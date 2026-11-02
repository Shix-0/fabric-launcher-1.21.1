# BDSMP Menu Cleanup — Fabric 1.21.11

Osobny, mały port usuwający ikonowe przyciski **Language** i **Accessibility** z ekranu tytułowego. Nie kopiuje kodu oryginalnego moda; odtwarza potrzebne zachowanie jako niezależny mod klienta.

## Budowanie

Wymagane: JDK 21 oraz połączenie z internetem, aby Gradle pobrał Fabric Loom i biblioteki Minecrafta.

W folderze projektu uruchom:

```powershell
gradle build
```

Gotowy plik powinien znaleźć się w `build\libs\bdsmp-bye-bye-buttons-1.0.0.jar`. Włóż go do folderu `mods` i usuń ewentualny duplikat starego moda, który również usuwa te przyciski.

## Zakres i ograniczenia

Mod usuwa ikonowe widgety z ekranu tytułowego po ich utworzeniu, żeby nie zależało to od położenia elementów w FancyMenu. Nie zmienia przycisków tekstowych ani innych ekranów. Przed użyciem w paczce należy zbudować i sprawdzić go na Minecraft 1.21.11.
