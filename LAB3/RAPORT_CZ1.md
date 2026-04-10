## TWM LAB3 
### Raport z części 1
* **Bartosz Zaborowski 319996**
* **Piotr Walczak 315220**



### Zadanie 1

Otrzymaliśmy następujące wyniki po uruchomieniu skryptu zadania 1:

```

Local minimum found.

Optimization completed because the size of the gradient is less than
the value of the optimality tolerance.

<stopping criteria details>
Accuracy train: 100.000000
Accuracy test: 85.555556
>> 

```

Model regresji logistycznej osiągnął skuteczność 100% na zbiorze uczącym oraz 85.56% na zbiorze testowym. Oznacza to, że model bardzo dobrze dopasował się do danych treningowych, jednak jego skuteczność na nowych danych jest niższa, co wskazuje na lekkie przeuczenie. Mimo tego model zachowuje dobrą zdolność generalizacji i poprawnie klasyfikuje większość obrazów.



### Zadanie 2

Po uruchomieniu skryptu do zadania 2 otrzymujemy medzy innymi nastepujace wytkresy:

![F. kosztu vs Liczba cech](CZ1_WYKRESY/ZAD2_1.png)

![Skuteczność vs Liczba cech](CZ1_WYKRESY/ZAD2_3.png)


Po przeanalizowaniu wykresów oraz po przeprowadzeniu eksperymentów, dochodzimy do wniosku, że wraz ze wzrostem liczby cech funkcja kosztu dla zbioru uczącego stale maleje, a skuteczność dąży do 100%. Skuteczność treningowa dociera do 100%, podczas gdy walidacyjna po osiągnięciu około 85% przy kilkunastu cechach zaczyna falować, a dystans między obiema liniami staje się ogromny. Dla zbioru walidacyjnego funkcja kosztu osiąga minimum dla 14 cech, po czym gwałtownie rośnie, co świadczy o silnym przeuczeniu modelu przy zbyt dużej liczbie wymiarów (spadek zdolności generalizacji). W związku z tym optymalnym wyborem dla tego scenariusza jest ograniczenie modelu do 14 cech.

Generowane były również wykresy odchylenia standardowego:

![Odch. stand. F. kosztu vs liczba cech](CZ1_WYKRESY/ZAD2_2.png)

![Odch. stand. skuteczności vs liczba cech](CZ1_WYKRESY/ZAD2_4.png)


Analiza wykresów odchylenia standardowego potwierdziła zjawisko przeuczenia. Podczas gdy dla zbioru uczącego odchylenie jest niemal zerowe (model jest stabilny), na zbiorze walidacyjnym po przekroczeniu 14 cech obserwujemy drastyczny wzrost niestabilności (ogromne skoki wariancji funkcji kosztu). Potwierdza to ogromnej wrażliwości przeuczonego modelu na to, jak dokładnie podzielono dane.


### Zadanie 3

Po wykonaniu skryptu do zadania 3 otrzymujemy następujące wykresy:

![](CZ1_WYKRESY/ZAD3_1.png)

![](CZ1_WYKRESY/ZAD3_3.png)

![](CZ1_WYKRESY/ZAD3_2.png)

![](CZ1_WYKRESY/ZAD3_4.png)

Widzimy, że wraz ze wzrostem ilości danych wykresy funkcji kosztu zbiegają się, błąd treningowy rośnie, a walidacyjny maleje. Wynika to z faktu, że na małym zbiorze model łatwo uczy się obrazków na pamięć, natomiast duża ilość danych zmusza go do szukania ogólnych, uniwersalnych reguł (co potwierdza też spadające odchylenie standardowe). Ostatecznie jednak niska skuteczność i wysoki koszt końcowy wskazują na zjawisko niedouczenia. Model bazujący 5 cechach jest zbyt prosty, by w pełni skorzystać z dużej liczby obrazków.


### Zadanie 4

Po uruchomieniu skryptu dla zadania 4 otrzymaliśmy nastepujace wykresy:

![Odch. stand. skuteczności vs liczba cech](CZ1_WYKRESY/ZAD4_1.png)

![Odch. stand. skuteczności vs liczba cech](CZ1_WYKRESY/ZAD4_2.png)

Z analizy wykresu funkcji kosztu jasno wynika, że optymalnym momentem na wczesne zatrzymanie jest około 28 iteracja. To w tym punkcie błąd walidacyjny osiąga minimum, po czym zaczyna rosnąć, co sugeruje zjawisko przeuczenia modelu. Przerwanie nauki w tej iteracji pozwala na zachowanie najlepszej zdolności do generalizacji, co przełożyło się na skuteczność rzędu 85.5% na zbiorze testowym.



### Zadanie 5 

Tutaj najlepiej analizowac wykrews funkcji kosztu