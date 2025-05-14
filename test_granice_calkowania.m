% Skrypt porównujący czas obliczeń i błąd metody Simpsona w zależności od granic całkowania

clear all;
close all;
clc;

%% Parametry testów
n = 100;                % Liczba podprzedziałów (musi być parzysta)
m = 5;                  % Liczba składników sumy w f(x)
ak = [1, 0.5, 0.25, 0.125, 0.0625];  % Współczynniki ak
liczba_powtorzen = 3;   % Liczba powtórzeń pomiarów dla uśrednienia wyników

% Definiowanie różnych granic całkowania
granice = [
    0, pi/4;
    0, pi/2;
    0, pi;
    0, 2*pi;
    -pi/2, pi/2;
    -pi, pi;
    pi/4, 3*pi/4;
    pi/2, 3*pi/2;
    -2*pi, 2*pi
];

nazwy_granic = {
    '[0, π/4]',
    '[0, π/2]',
    '[0, π]',
    '[0, 2π]',
    '[-π/2, π/2]',
    '[-π, π]',
    '[π/4, 3π/4]',
    '[π/2, 3π/2]',
    '[-2π, 2π]'
};
nazwy_granic_col = categorical(nazwy_granic);
liczba_granic = size(granice, 1);

% Inicjalizacja tablic na wyniki
czasy_obliczen = zeros(liczba_granic, 1);
bledy_wzgledne = zeros(liczba_granic, 1);
wartosci_calki = zeros(liczba_granic, 1);
wartosci_analityczne = zeros(liczba_granic, 1);
dlugosci_przedzialow = zeros(liczba_granic, 1);

%% Główna pętla testowa
for i = 1:liczba_granic
    a = granice(i, 1);
    b = granice(i, 2);
    dlugosci_przedzialow(i) = b - a;
    
    % Obliczenie wartości analitycznej całki
    wartosci_analityczne(i) = sum(ak .* (-cos((1:m)*b) + cos((1:m)*a)) ./ (1:m));
    
    % Pomiar czasu wykonania (powtórzony kilka razy dla lepszej dokładności)
    czas_calkowity = 0;
    for j = 1:liczba_powtorzen
        tic;
        calka = metoda_simpsona(a, b, n, ak);
        czas_calkowity = czas_calkowity + toc;
    end
    czas_sredni = czas_calkowity / liczba_powtorzen;
    
    
    % Obliczenie błędu względnego
    
    if wartosci_analityczne(i) == 0
        if calka == 0
            blad = 0;
        else
            blad = NaN; % lub blad = 0, jeśli wolisz
        end
    else
        blad = abs((calka - wartosci_analityczne(i)) / wartosci_analityczne(i)) * 100;
    end

    
    % Zapisanie wyników
    czasy_obliczen(i) = czas_sredni;
    bledy_wzgledne(i) = blad;
    wartosci_calki(i) = calka;
end
% Zamiana nazwy na kolumnę cell array znaków:
nazwy_granic_col = nazwy_granic_col(:); % wymusza kolumnę

% Wymuszenie orientacji kolumnowej na dane numeryczne:
czasy_obliczen_col = czasy_obliczen(:);
bledy_wzgledne_col = bledy_wzgledne(:);
wartosci_calki_col = wartosci_calki(:);
wartosci_analityczne_col = wartosci_analityczne(:);
dlugosci_przedzialow_col = dlugosci_przedzialow(:);

% Tworzenie tabeli:
wyniki_tabela = table( ...
    nazwy_granic_col, ...
    dlugosci_przedzialow_col, ...
    czasy_obliczen_col, ...
    bledy_wzgledne_col, ...
    wartosci_calki_col, ...
    wartosci_analityczne_col, ...
    'VariableNames', {'Przedzial', 'DlugoscPrzedzialu', 'Czas_s', 'Blad_wzgledny_procent', 'Wartosc_calki_Simpsona', 'Wartosc_calki_Analityczna'});

% Wyświetlenie tabeli w konsoli
disp(wyniki_tabela);



%% Porównanie bezwzględnych wartości całki
figure('Name', 'Wartości całki', 'Position', [100, 100, 1000, 600]);


bar([wartosci_calki, wartosci_analityczne]);
set(gca, 'XTick', 1:liczba_granic, 'XTickLabel', nazwy_granic, 'XTickLabelRotation', 45);
title('Porównanie obliczonych i analitycznych wartości całki', 'FontSize', 14);
ylabel('Wartość całki', 'FontSize', 12);
legend('Metoda Simpsona', 'Wartość analityczna');
grid on;

%% Badanie wpływu liczby podprzedziałów dla różnych granic całkowania
% Wybieramy 3 reprezentatywne granice całkowania
wybrane_granice = [3, 6, 9];  % [0, π], [-π, π], [-2π, 2π]
podprzedzialy = [10, 20, 50, 100, 200, 500];
liczba_podprzedzialow = length(podprzedzialy);

% Inicjalizacja tablic na wyniki
czasy_podprzedzialy = zeros(length(wybrane_granice), liczba_podprzedzialow);
bledy_podprzedzialy = zeros(length(wybrane_granice), liczba_podprzedzialow);

figure('Name', 'Wpływ liczby podprzedziałów', 'Position', [100, 100, 1200, 800]);

for i = 1:length(wybrane_granice)
    granica_idx = wybrane_granice(i);
    a = granice(granica_idx, 1);
    b = granice(granica_idx, 2);
    
    % Obliczenie wartości analitycznej
    wartosci_analityczne_wybrane = sum(ak .* (-cos((1:m)*b) + cos((1:m)*a)) ./ (1:m));
    
    for j = 1:liczba_podprzedzialow
        n_test = podprzedzialy(j);
        
        % Pomiar czasu
        tic;
        calka = metoda_simpsona(a, b, n_test, ak);
        czas = toc;
        
        % Obliczenie błędu
        if wartosci_analityczne_wybrane == 0
        if calka == 0
            blad = 0;
        else
            blad = NaN; % lub blad = 0
        end
        else
            blad = abs((calka - wartosci_analityczne_wybrane) / wartosci_analityczne_wybrane) * 100;
end


        % Zapisanie wyników
        czasy_podprzedzialy(i, j) = czas;
        bledy_podprzedzialy(i, j) = blad;
    end
end

% Wykres czasu dla różnych granic i liczby podprzedziałów
subplot(2, 1, 1);
for i = 1:length(wybrane_granice)
    granica_idx = wybrane_granice(i);
    semilogx(podprzedzialy, czasy_podprzedzialy(i, :), 'o-', 'LineWidth', 2, 'MarkerSize', 8);
    hold on;
end
hold off;
title('Czas obliczeń vs. liczba podprzedziałów dla różnych granic całkowania', 'FontSize', 14);
xlabel('Liczba podprzedziałów (skala logarytmiczna)', 'FontSize', 12);
ylabel('Czas [s]', 'FontSize', 12);
legend(nazwy_granic(wybrane_granice), 'Location', 'northwest');
grid on;

% Wykres błędu dla różnych granic i liczby podprzedziałów
subplot(2, 1, 2);
for i = 1:length(wybrane_granice)
    granica_idx = wybrane_granice(i);
    loglog(podprzedzialy, bledy_podprzedzialy(i, :), 'o-', 'LineWidth', 2, 'MarkerSize', 8);
    hold on;
end
hold off;
title('Błąd względny vs. liczba podprzedziałów dla różnych granic całkowania', 'FontSize', 14);
xlabel('Liczba podprzedziałów (skala logarytmiczna)', 'FontSize', 12);
ylabel('Błąd względny [%] (skala logarytmiczna)', 'FontSize', 12);
legend(nazwy_granic(wybrane_granice), 'Location', 'southwest');
grid on;


%% Podsumowanie
fprintf('PODSUMOWANIE WYNIKÓW:\n\n');

fprintf('1. Wpływ długości przedziału całkowania na czas obliczeń i błąd:\n');
[~, idx_max_czas] = max(czasy_obliczen);
[~, idx_min_czas] = min(czasy_obliczen);
[~, idx_max_blad] = max(bledy_wzgledne);
[~, idx_min_blad] = min(bledy_wzgledne);

fprintf('   - Najdłuższy czas obliczeń: %s (%.6f s)\n', nazwy_granic{idx_max_czas}, czasy_obliczen(idx_max_czas));
fprintf('   - Najkrótszy czas obliczeń: %s (%.6f s)\n', nazwy_granic{idx_min_czas}, czasy_obliczen(idx_min_czas));
fprintf('   - Największy błąd względny: %s (%.8f%%)\n', nazwy_granic{idx_max_blad}, bledy_wzgledne(idx_max_blad));
fprintf('   - Najmniejszy błąd względny: %s (%.8f%%)\n\n', nazwy_granic{idx_min_blad}, bledy_wzgledne(idx_min_blad));


% Zapisanie wyników do pliku
save('wyniki_granice_calkowania.mat', 'granice', 'nazwy_granic', 'czasy_obliczen', ...
     'bledy_wzgledne', 'wartosci_calki', 'wartosci_analityczne', 'dlugosci_przedzialow');
    