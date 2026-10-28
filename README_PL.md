# Fabric Launcher — prototyp

Prosty, przenośny menedżer modów przygotowany pod **Minecraft Java 1.21.1 + Fabric**.

## Uruchomienie

Kliknij dwukrotnie `Start.bat`. Wybierz pliki modów `.jar` przyciskiem **Dodaj mody**. Aplikacja kopiuje je do `instance\mods`. Folder `instance` jest częścią launchera i zostaje dołączony do archiwum tworzonego przyciskiem **Spakuj do ZIP**.

Odbiorca rozpakowuje ZIP i uruchamia własne `Start.bat`. Nie ma w nim hasła ani danych logowania.

## Ważne — zakres prototypu

Ta pierwsza wersja obsługuje dodawanie/usuwanie modów i pakowanie folderu. Nie uruchamia jeszcze Minecrafta, nie instaluje Fabric i nie obsługuje logowania Microsoft. Przed dodaniem modów trzeba sprawdzić, czy każdy z nich pasuje do Minecraft 1.21.1 oraz Fabric. Gra i pliki konta nie są kopiowane do ZIP; każda osoba musi mieć Minecraft Java Edition.

Kolejnym krokiem jest podłączenie instalacji Fabric i uruchamiania gry. Logowanie Microsoft wymaga konfiguracji aplikacji OAuth, a launcher nie powinien przechowywać haseł ani eksportować tokenów.
