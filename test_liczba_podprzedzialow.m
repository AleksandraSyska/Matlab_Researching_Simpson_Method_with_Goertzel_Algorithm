% Skrypt testujący porównanie zbieżności metody Simpsona i czasu wykonania
% dla różnych typów współczynników ak w zależności od liczby podprzedziałów
clear all;
close all;
clc;

%% Parametry testów
a = 0;                  % Dolna granica całkowania
b = pi;                 % Górna granica całkowania
m = 10;                 % Liczba składników sumy w f(x)
podprzedzialy = [10, 20, 50, 100, 200, 500, 1000];  % Liczby podprzedziałów do testowania

% Typy współczynników ak
typy = {'losowe', 'rosnące', 'malejące', 'równe 1', 'oscylujące', ...
        'rosnące kwadratowo', 'skokowe', 'rosnące wykładniczo', 'losowe z fluktuacjami'};

% Inicjalizacja macierzy wyników
liczba_typow = length(typy);
liczba_podprzedzialow = length(podprzedzialy);
bledy_wzgledne = zeros(liczba_typow, liczba_podprzedzialow);
czasy_wykonania = zeros(liczba_typow, liczba_podprzedzialow);
wartosci_analityczne = zeros(liczba_typow, 1);

% Ustawienie generatora liczb losowych dla powtarzalności
rng(42);

%% Generowanie różnych typów współczynników ak
ak_wszystkie = cell(liczba_typow, 1);

% 1. Losowe
ak_wszystkie{1} = rand(1, m);

% 2. Rosnące
ak_wszystkie{2} = linspace(0.1, 1, m);

% 3. Malejące
ak_wszystkie{3} = linspace(1, 0.1, m);

% 4. Równe 1
ak_wszystkie{4} = ones(1, m);

% 5. Oscylujące
ak_wszystkie{5} = cos(linspace(0, 2*pi, m));

% 6. Rosnące kwadratowo
ak_wszystkie{6} = ((1:m) / m) .^ 2;

% 7. Skokowe
ak_wszystkie{7} = zeros(1, m);
ak_wszystkie{7}(1:2:m) = 1;

% 8. Rosnące wykładniczo
ak_wszystkie{8} = exp(linspace(0, 2, m)) / exp(2);

% 9. Losowe z fluktuacjami
ak_wszystkie{9} = rand(1, m) .* (1 + 0.5*sin(linspace(0, 4*pi, m)));

%% Przeprowadzenie testów dla każdego typu współczynników
fprintf('Rozpoczęcie testów zbieżności i czasu wykonania...\n');

% Przygotowanie do tabeli wyników
Typ = strings(liczba_typow * liczba_podprzedzialow, 1);
Podprzedzialy = zeros(liczba_typow * liczba_podprzedzialow, 1);
Blad_wzgledny = zeros(liczba_typow * liczba_podprzedzialow, 1);
Czas_s = zeros(liczba_typow * liczba_podprzedzialow, 1);
Wartosc_analityczna = zeros(liczba_typow * liczba_podprzedzialow, 1);

idx = 1;

for typ = 1:liczba_typow
    fprintf('Testowanie dla typu: %s\n', typy{typ});
    ak = ak_wszystkie{typ};
    wartosc_analityczna_typu = sum(ak .* (-cos((1:m)*b) + cos((1:m)*a)) ./ (1:m));
    wartosci_analityczne(typ) = wartosc_analityczna_typu;
    
    for i = 1:liczba_podprzedzialow
        n = podprzedzialy(i);
        tic;
        calka = metoda_simpsona(a, b, n, ak);
        czas = toc;
        blad = abs((calka - wartosc_analityczna_typu) / wartosc_analityczna_typu) * 100;
        bledy_wzgledne(typ, i) = blad;
        czasy_wykonania(typ, i) = czas;
        
        % Zapis do tabeli
        Typ(idx) = string(typy{typ});
        Podprzedzialy(idx) = n;
        Blad_wzgledny(idx) = blad;
        Czas_s(idx) = czas;
        Wartosc_analityczna(idx) = wartosc_analityczna_typu;
        idx = idx + 1;
    end
end

Typ = categorical(Typ); % Usuwa cudzysłowy w tabeli
wyniki_table = table(Typ, Podprzedzialy, Blad_wzgledny, Czas_s, ...
    'VariableNames', {'Typ_ak', 'Liczba_podprzedzialow', 'Blad_wzgledny', 'Czas_s'});

for i = 1:length(podprzedzialy)
    n = podprzedzialy(i);
    idx = wyniki_table.Liczba_podprzedzialow == n;
    tabela_n = wyniki_table(idx, :);
    tabela_n.Liczba_podprzedzialow = [];
    fprintf('\nTabela wyników dla liczby podprzedziałów n = %d:\n', n);
    disp(tabela_n);
    % (opcjonalnie zapis do pliku)
    % writetable(tabela_n, sprintf('wyniki_simpson_n_%d.csv', n));
end




%% Wizualizacja współczynników
figure('Position', [100, 100, 1000, 600]);
for typ = 1:liczba_typow
    subplot(3, 3, typ);
    stem(1:m, ak_wszystkie{typ}, 'LineWidth', 1.5);
    title(['Współczynniki: ' typy{typ}]);
    xlabel('k');
    ylabel('a_k');
    grid on;
    ylim([0 max(1.1, 1.1*max(ak_wszystkie{typ}))]);
end
sgtitle('Różne typy współczynników a_k', 'FontSize', 14);

%% Wykresy zbieżności dla każdego typu współczynników osobno
figure('Position', [100, 100, 1200, 1000]);
colors = jet(liczba_typow);
for typ = 1:liczba_typow
    subplot(3, 3, typ);
    loglog(podprzedzialy, bledy_wzgledne(typ, :), '-o', 'LineWidth', 1.5, 'Color', colors(typ,:), 'MarkerSize', 6);
    title(typy{typ}, 'FontSize', 12);
    xlabel('Liczba podprzedziałów');
    ylabel('Błąd względny [%]');
    grid on;
end
sgtitle('Zbieżność metody Simpsona dla poszczególnych typów współczynników', 'FontSize', 14);

%% Wykresy czasu wykonania dla każdego typu współczynników osobno
figure('Position', [100, 100, 1200, 1000]);
for typ = 1:liczba_typow
    subplot(3, 3, typ);
    semilogx(podprzedzialy, czasy_wykonania(typ, :), '-o', 'LineWidth', 1.5, 'Color', colors(typ,:), 'MarkerSize', 6);
    title(typy{typ}, 'FontSize', 12);
    xlabel('Liczba podprzedziałów');
    ylabel('Czas wykonania [s]');
    grid on;
end
sgtitle('Czas wykonania metody Simpsona dla poszczególnych typów współczynników', 'FontSize', 14);

%% Trójwymiarowy wykres zależności błędu od typu współczynników i liczby podprzedziałów
figure('Position', [100, 100, 1000, 800]);
[X, Y] = meshgrid(1:liczba_typow, podprzedzialy);
Z = bledy_wzgledne';
surf(X, Y, Z);
colormap(jet);
colorbar;
set(gca, 'XTick', 1:liczba_typow, 'XTickLabel', typy, 'XTickLabelRotation', 45);
set(gca, 'YScale', 'log');
set(gca, 'ZScale', 'log');
title('Zależność błędu względnego od typu współczynników i liczby podprzedziałów', 'FontSize', 14);
xlabel('Typ współczynników');
ylabel('Liczba podprzedziałów');
zlabel('Błąd względny [%]');
view(30, 30);
grid on;

%% Trójwymiarowy wykres zależności czasu wykonania od typu współczynników i liczby podprzedziałów
figure('Position', [100, 100, 1000, 800]);
Z = czasy_wykonania';
surf(X, Y, Z);
colormap(jet);
colorbar;
set(gca, 'XTick', 1:liczba_typow, 'XTickLabel', typy, 'XTickLabelRotation', 45);
set(gca, 'YScale', 'log');
title('Zależność czasu wykonania od typu współczynników i liczby podprzedziałów', 'FontSize', 14);
xlabel('Typ współczynników');
ylabel('Liczba podprzedziałów');
zlabel('Czas wykonania [s]');
view(30, 30);
grid on;

fprintf('\nWyniki zostały zapisane do pliku wyniki_simpson_typy.csv\n');
