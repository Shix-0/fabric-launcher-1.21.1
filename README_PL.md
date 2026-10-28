# Fabric Launcher — prototyp

Prototyp menedżera modów przygotowany pod **Minecraft Java 1.21.1 + Fabric**.

## Uruchomienie

Kliknij dwukrotnie `Start.bat`. Launcher sprawdza publiczny folder `mods` w repozytorium GitHub i pobiera zmienione pliki `.jar` do `instance\mods`. Przycisk **Sprawdź aktualizacje** wykonuje to samo ręcznie. Dodatkowe lokalne pliki `.jar` są usuwane podczas udanej synchronizacji, aby przywrócić zatwierdzony zestaw.

## Dodawanie i aktualizowanie modów

W launcherze kliknij **Dodaj / aktualizuj mody**. Otworzy się strona dodawania plików do katalogu `mods` w repozytorium. Przeciągnij tam pliki `.jar` przeznaczone dla Minecraft 1.21.1 i Fabric, a następnie zatwierdź zmianę w GitHub. Tylko właściciel repozytorium może ją opublikować. Pozostali gracze pobiorą nowy zestaw przy kolejnym uruchomieniu albo po kliknięciu **Sprawdź aktualizacje**.

Repozytorium jest publiczne, więc pliki w `mods` mogą pobrać także osoby, którym nie wysłano launchera. Dodawaj tylko mody, których warunki pozwalają na dalsze udostępnianie.

## Zakres prototypu

Ta wersja synchronizuje mody i pozwala spakować kopię folderu do ZIP-a. Nie instaluje ani nie uruchamia jeszcze Minecrafta, nie instaluje Fabric i nie obsługuje logowania Microsoft. Każdy gracz musi używać własnego konta z licencją Minecraft Java Edition. Nie umieszczaj haseł ani tokenów kont w paczce.

## Repozytorium modów

`https://github.com/Shix-0/fabric-launcher-1.21.1`
