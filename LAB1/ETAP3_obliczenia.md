# Raport z laboratorium 1: Techniki Widzenia Maszynowego (TWM)

**Zespół:**
 - Piotr Walczak 315220
 - Bartosz Zaborowski 319996

**Temat:** Kalibracja kamery, pomiar odległości oraz szacowanie maksymalnej prędkości obiektu.
**Aparat:** Apple iPhone 16 Pro


Celem zadania było wyznaczenie parametrów optycznych kamery w telefonie komórkowym, a następnie wykorzystanie modelu kamery otworkowej (pinhole camera) do wyliczenia odległości od obserwowanego obiektu oraz dopuszczalnej prędkości poruszającego się obiektu przy zadanym czasie naświetlania. 

Kluczowym założeniem podczas zbierania danych było zablokowanie ostrości i ekspozycji (AE/AF Lock), aby zagwarantować stałą ogniskową dla wszystkich zdjęć.

## Etap 1: Kalibracja Kamery
Proces kalibracji przeprowadzono w środowisku MATLAB, korzystając z aplikacji Camera Calibrator.

* **Wzorzec kalibracyjny:** Szachownica (`chess_16_9.pdf`) wyświetlona na płaskim monitorze.
* **Rozmiar pojedynczego pola:** 46 mm.
* **Zbiór danych:** 19 zdjęć wykonanych pod różnymi kątami i z różnych odległości.
* **Model zniekształceń:** Założono niskie zniekształcenia (opcja *Low / 2 Coefficients*), z uwagi na wbudowane mechanizmy prostujące obraz w smartfonie.

**Wyniki kalibracji (zmienna `cameraParams`):**
* Rozdzielczość obrazu: `5712 x 4284 px`
* Średni błąd reprojekcji (Overall Mean Error): `0.74 px` (bardzo wysoka dokładność)
* Ogniskowa ($f_x, f_y$): `[4025.3, 4024.8] px`
* Punkt główny ($c_x, c_y$): `[2845.8, 2148.2] px`


## Etap 2: Pomiar odległości
Celem drugiego etapu było wyliczenie odległości kamery od wzorca na podstawie znajomości jego rzeczywistych wymiarów oraz parametrów wyznaczonych w procesie kalibracji.

Wykorzystano uproszczony wzór z modelu rzutowania perspektywicznego:
$$Z = \frac{f_x \cdot W_{real}}{W_{px}}$$

Gdzie:
* $f_x$ = 4025.3 px (ogniskowa)
* $W_{real}$ = 24.2 cm (rzeczywista szerokość wzorca - od pierwszej do ostatniej czarnej krawędzi)
* $W_{px}$ = szerokość wzorca na zdjęciu odczytana w pikselach za pomocą narzędzia `imtool` w MATLABie.

**Obliczenia dla wykonanych zdjęć:**

1. **Zdjęcie 1 (założona odległość: ~0.5 m):**
   * Zmierzona szerokość ($W_{px}$): 2289.14 px
   * Obliczona odległość ($Z_1$): **42.55 cm**

2. **Zdjęcie 2 (założona odległość: ~1.0 m):**
   * Zmierzona szerokość ($W_{px}$): 1070.04 px
   * Obliczona odległość ($Z_2$): **91.04 cm**

3. **Zdjęcie 3 (założona odległość: ~1.5 m):**
   * Zmierzona szerokość ($W_{px}$): 630.05 px
   * Obliczona odległość ($Z_3$): **154.61 cm**


## Etap 3: Maksymalna szybkość poruszającego się obiektu
W ostatnim etapie wyznaczono maksymalną prędkość z jaką może poruszać się obiekt prostopadle do osi kamery, aby obraz nie uległ rozmyciu. 

**Założenia:**
* Czas naświetlania: $T = 10 \text{ ms} = 0.01 \text{ s}$
* Maksymalne dopuszczalne rozmycie obrazu na matrycy: $\Delta u = 1 \text{ px}$
* $\Delta X$ - przemieszczenie w świecie rzeczywistym
* $Z$ - odległość od kamery (1m, 2m, 3m)

Przekształcając podstawowy wzór optyczny, wyznaczono dopuszczalne przemieszczenie obiektu w świecie rzeczywistym ($\Delta X$), a następnie podzielono je przez czas naświetlania, otrzymując wzór na prędkość:
$$v = \frac{\Delta X}{T} = \frac{\Delta u \cdot Z}{f_x \cdot T}$$

**Wyniki obliczeń dla różnych dystansów:**

1. **Dla odległości Z = 1 m:**
   * $v_1 = \frac{1 \cdot 1}{4025.3 \cdot 0.01} =$ **0.0248 m/s** (~2.5 cm/s)

2. **Dla odległości Z = 2 m:**
   * $v_2 = \frac{1 \cdot 2}{4025.3 \cdot 0.01} =$ **0.0497 m/s** (~5.0 cm/s)

3. **Dla odległości Z = 3 m:**
   * $v_3 = \frac{1 \cdot 3}{4025.3 \cdot 0.01} =$ **0.0745 m/s** (~7.5 cm/s)

## Wnioski
Eksperyment potwierdził skuteczność kalibracji metodą szachownicy w wyznaczaniu użytecznych parametrów optycznych układu. Otrzymane odległości (Etap 2) pokrywają się z celowymi założeniami pomiarowymi, a obliczenia z Etapu 3 obrazują zależność między odległością fotografowanego obiektu, czasem naświetlania a zjawiskiem rozmycia ruchu (*motion blur*).

ss