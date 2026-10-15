# Menu gier — Godot 4

Projekt uruchamia trzy gry z jednego menu. Menu pozwala regulować głośność i przełączać jasny/czarny motyw. Animowane tło nawiązuje do Radiostacji Gliwickiej. W każdej grze możesz wrócić do menu głównego przyciskiem **MENU GŁÓWNE** albo klawiszem **F10** lub **Home**. Dodana nawigacja nie zmienia mechaniki gier.

## Uruchamianie

1. Rozpakuj całe archiwum ZIP do jednego folderu. Nie przenoś osobno plików `.gd` ani folderu `games`.
2. Zainstaluj Godot 4.7 lub nowszy.
3. W Godot wybierz **Import** i wskaż plik `project.godot` z rozpakowanego folderu.
4. Otwórz projekt i naciśnij **F6**, aby uruchomić projekt (albo **F5**, jeśli Godot zapyta o scenę główną).
5. Wybierz grę w menu. Z menu gry wrócisz przyciskiem **MENU GŁÓWNE**, **F10** lub **Home**.

Ustawienia głośności i motywu są zapamiętywane. Gry zachowują swoje proporcje obrazu; przy innym kształcie okna mogą pojawić się wolne pasy.

## Gry i sterowanie

### Gliwice Sprint: Szlak Radiostacji (`games/subwaysurf`)

Trójwymiarowy biegacz bez końca po stylizowanych Gliwicach. Zmieniaj pasy i omijaj tramwaje, autobusy, pociągi, bariery oraz niskie belki. Zbieraj monety i czasowe moce. Rampy prowadzą na dach pociągu. Wynik i monety są zapisywane; monety można wydać w sklepie na postacie z bonusami.

- **A/D** lub **←/→** — zmiana pasa.
- **W**, **Spacja** lub **↑** — skok.
- **S** lub **↓** — kucanie (przytrzymaj).
- **Enter** — rozpoczęcie biegu; po zderzeniu **R** lub **Enter** — ponowny start.
- W sklepie: **←/→** przeglądanie, **Enter** zakup lub wybór, **Esc** powrót.

### Kierowca autobusu (`games/bus`)

Pikselowa gra z widokiem z góry. Wybierz linię i autobus, jedź po mieście i zabieraj pasażerów z żółtych przystanków, pilnując limitu czasu. Co trzy przystanki wybierasz ulepszenie. Kolizje uszkadzają autobus.

- **↑/W** — przyspieszanie; **↓/S** — hamowanie i cofanie.
- **←/A** i **→/D** — skręcanie.
- W menu gry: **↑/↓** wybór linii, **←/→** rozmiar autobusu, **C** kolor, **Enter** start.
- **Esc** — pauza lub wznowienie; w pauzie **M** wraca do menu tej gry.
- Po trzech przystankach wybierz ulepszenie klawiszem **1**, **2** lub **3**.

### Radiostacja Gliwice — Wspinaczka (`games/timberman`)

Gra zręcznościowa inspirowana Timbermanem. Wspinaj się po makietowej wieży, zmieniając stronę i unikając anten lub gałęzi. Pilnuj energii i zbieraj pierogi. Dostępne są tryby: Radiostacja (111 m), Ratusz, Politechnika i bez końca. Pierogi odblokowują postacie z bonusami.

- **A/←** i **D/→** albo kliknięcie lewej/prawej połowy ekranu — zmiana strony i cięcie.
- **Enter/Spacja** — start lub ponowienie rundy.
- **B** — sklep; **←/→** przeglądanie, **Enter/Spacja/B** zakup lub wybór, **Esc** powrót.
- W menu gry **A/D** lub strzałkami wybieraj tryb.

## Film

Demo: [Odtwórz film](https://youtu.be/hiP9DJX-vYk).

