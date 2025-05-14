% Skrypt: osobne wykresy czasu i błędu dla każdego typu ak w zależności od
% liczby składników ak 
clear all;
close all;
clc;

%% Parametry testów
a = 0;                  % Dolna granica całkowania
b = pi;                 % Górna granica całkowania
n = 100;                % Liczba podprzedziałów (musi być parzysta)
max_skladnikow = 20;    % Maksymalna liczba składników do testowania
liczba_powtorzen = 5;   % Liczba powtórzeń pomiarów dla uśrednienia wyników

% Typy współczynników ak
typy = {'losowe', 'rosnace', 'malejace', 'rowne_1', 'oscylujace', ...
        'rosnace_kwadratowo', 'skokowe', 'rosnace_wykladniczo', 'losowe_fluktuacje'};
liczba_typow = length(typy);

% Kolory - zawsze takie same dla danego typu
colors = jet(liczba_typow);

% Inicjalizacja tablic na wyniki
czasy_obliczen = zeros(liczba_typow, max_skladnikow);
bledy_wzgledne = zeros(liczba_typow, max_skladnikow);
wartosci_analityczne = zeros(liczba_typow, max_skladnikow);

% Ustawienie generatora liczb losowych dla powtarzalności
rng(42);

%% Główna pętla testowa
for m = 1:max_skladnikow
    for typ = 1:liczba_typow
        % Generowanie współczynników ak zgodnie z typem
        switch typy{typ}
            case 'losowe'
                ak = rand(1, m);
            case 'rosnace'
                ak = linspace(0.1, 1, m);
            case 'malejace'
                ak = linspace(1, 0.1, m);
            case 'rowne_1'
                ak = ones(1, m);
            case 'oscylujace'
                ak = cos(linspace(0, 2*pi, m));
            case 'rosnace_kwadratowo'
                ak = ((1:m) / m) .^ 2;
            case 'skokowe'
                ak = zeros(1, m);
                ak(1:2:m) = 1;
            case 'rosnace_wykladniczo'
                ak = exp(linspace(0, 2, m)) / exp(2);
            case 'losowe_fluktuacje'
                ak = rand(1, m) .* (1 + 0.5*sin(linspace(0, 4*pi, m)));
        end
        
        % Obliczenie wartości analitycznej całki
        wartosci_analityczne(typ, m) = sum(ak .* (-cos((1:m)*b) + cos((1:m)*a)) ./ (1:m));
        
        % Pomiar czasu wykonania (uśredniony)
        czas_calkowity = 0;
        for i = 1:liczba_powtorzen
            tic;
            calka = metoda_simpsona(a, b, n, ak);
            czas_calkowity = czas_calkowity + toc;
        end
        czas_sredni = czas_calkowity / liczba_powtorzen;
        
        % Obliczenie błędu względnego
        blad = abs((calka - wartosci_analityczne(typ, m)) / wartosci_analityczne(typ, m)) * 100;
        
        % Zapisanie wyników
        czasy_obliczen(typ, m) = czas_sredni;
        bledy_wzgledne(typ, m) = blad;
    end
end

% Wykresy czasu obliczeń dla każdego typu współczynników osobno (loglog)
figure('Position', [100, 100, 1200, 1000]);
for typ = 1:liczba_typow
    subplot(3, 3, typ);
    loglog(1:max_skladnikow, czasy_obliczen(typ, :), '-o', ...
        'LineWidth', 1.5, 'Color', colors(typ,:), 'MarkerSize', 6);
    title(strrep(typy{typ}, '_', ' '), 'FontSize', 12); % zamiana _ na spację
    xlabel('Liczba składników ak');
    ylabel('Czas obliczeń [s]');
    grid on;
end
sgtitle('Czas obliczeń metody Simpsona dla poszczególnych typów współczynników', 'FontSize', 14);

% Wykresy błędu względnego dla każdego typu współczynników osobno (loglog)
figure('Position', [100, 100, 1200, 1000]);
for typ = 1:liczba_typow
    subplot(3, 3, typ);
    loglog(1:max_skladnikow, bledy_wzgledne(typ, :), '-o', ...
        'LineWidth', 1.5, 'Color', colors(typ,:), 'MarkerSize', 6);
    title(strrep(typy{typ}, '_', ' '), 'FontSize', 12); % zamiana _ na spację
    xlabel('Liczba składników ak');
    ylabel('Błąd względny [%]');
    grid on;
end
sgtitle('Błąd względny metody Simpsona dla poszczególnych typów współczynników', 'FontSize', 14);

%% Wyniki na konsoli w tabelach dla każdego typu ak
for typ = 1:liczba_typow
    Liczba_skladnikow = (1:max_skladnikow)';
    Czas_s = czasy_obliczen(typ, :)';
    Blad_wzgledny_procent = bledy_wzgledne(typ, :)';
    T = table(Liczba_skladnikow, Czas_s, Blad_wzgledny_procent, ...
        'VariableNames', {'Liczba_skladnikow', 'Czas_s', 'Blad_wzgledny'});
    fprintf('\nWyniki dla typu ak: %s\n', typy{typ});
    disp(T);
end
