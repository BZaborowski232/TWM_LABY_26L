import tensorflow as tf 
from keras.models import Sequential
from keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Dropout, BatchNormalization, Activation

def generate_model():
    # Inicjalizacja modelu sekwencyjnego - warstwy będą układane jedna po drugiej (jak na taśmie produkcyjnej)
    model = Sequential()

    # =========================================================================
    # BLOK SPLOTOWY 1: Wykrywanie najprostszych cech (krawędzie, linie, kolory)
    # =========================================================================
    # Conv2D: Skanuje obraz za pomocą 32 filtrów o rozmiarze 3x3 piksele.
    # padding='same' gwarantuje, że wymiary obrazka nie zmniejszą się na brzegach.
    # input_shape=(32, 32, 3) to wymiary zdjęć w CIFAR-10 (32x32 piksele, 3 kanały RGB).
    model.add(Conv2D(32, (3, 3), padding='same', input_shape=(32, 32, 3)))
    
    # BatchNormalization: Stabilizuje i przyspiesza uczenie poprzez normalizację wyników z poprzedniej warstwy.
    model.add(BatchNormalization())
    
    # Activation('relu'): Wprowadza nieliniowość. Zamienia wszystkie wartości ujemne na 0, a dodatnie puszcza dalej.
    model.add(Activation('relu'))
    
    # Druga warstwa splotowa w pierwszym bloku - utrwala znalezione cechy
    model.add(Conv2D(32, (3, 3)))
    model.add(BatchNormalization())
    model.add(Activation('relu'))
    
    # MaxPooling2D: Kompresuje obraz (zmniejsza jego wymiary o połowę), wybierając najsilniejsze sygnały z obszaru 2x2.
    model.add(MaxPooling2D(pool_size=(2, 2)))
    
    # Dropout: Zapobiega przeuczeniu (overfittingowi) poprzez losowe "wyłączanie" 25% neuronów w każdej epoce treningu.
    model.add(Dropout(0.25))


    # =========================================================================
    # BLOK SPLOTOWY 2: Wykrywanie bardziej złożonych kształtów (kąty, koła)
    # =========================================================================
    # Zwiększamy liczbę filtrów do 64, ponieważ obraz jest już skompresowany 
    # i szukamy bardziej zaawansowanych wzorców.
    model.add(Conv2D(64, (3, 3), padding='same'))
    model.add(BatchNormalization())
    model.add(Activation('relu'))
    
    model.add(Conv2D(64, (3, 3)))
    model.add(BatchNormalization())
    model.add(Activation('relu'))
    
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.25))


    # =========================================================================
    # BLOK SPLOTOWY 3: Wykrywanie skomplikowanych obiektów (oczy, opony, pyszczki)
    # =========================================================================
    # Jeszcze więcej filtrów (128) dla najdrobniejszych i najbardziej skomplikowanych detali.
    model.add(Conv2D(128, (3, 3), padding='same'))
    model.add(BatchNormalization())
    model.add(Activation('relu'))
    
    model.add(Conv2D(128, (3, 3)))
    model.add(BatchNormalization())
    model.add(Activation('relu'))
    
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.25))


    # =========================================================================
    # KLASYFIKATOR: Podjęcie ostatecznej decyzji na podstawie znalezionych cech
    # =========================================================================
    # Flatten: "Spłaszcza" trójwymiarowe mapy cech z poprzednich warstw do jednowymiarowego wektora.
    model.add(Flatten())
    
    # Dense: W pełni połączona warstwa (512 neuronów), która analizuje zebrane cechy.
    model.add(Dense(512))
    model.add(BatchNormalization())
    model.add(Activation('relu'))
    
    # Silniejszy Dropout (50%) przed samą decyzją, aby uniknąć zapamiętywania danych treningowych na pamięć.
    model.add(Dropout(0.5))
    
    # Warstwa wyjściowa - dokładnie 10 neuronów (bo mamy 10 klas w CIFAR-10)
    model.add(Dense(10))
    
    # Softmax: Zamienia wyniki z 10 neuronów na prawdopodobieństwa (od 0 do 1), które sumują się do 100%.
    model.add(Activation('softmax'))

    # Wyświetla podsumowanie architektury w konsoli (wymiary i liczbę parametrów)
    model.summary()
    
    # =========================================================================
    # KOMPILACJA MODELU
    # =========================================================================
    # Adam to optymalizator ("trener"). Zmniejszony krok uczenia (0.0005 zamiast domyślnego) 
    # zapobiega "przestrzeliwaniu" idealnego rozwiązania pod koniec treningu.
    adam = tf.optimizers.Adam(learning_rate=0.0005)
    
    # loss='categorical_crossentropy' - optymalna funkcja błędu dla problemów wieloklasowych (więcej niż 2 klasy).
    model.compile(loss='categorical_crossentropy', optimizer=adam, metrics=['accuracy'])

    return model