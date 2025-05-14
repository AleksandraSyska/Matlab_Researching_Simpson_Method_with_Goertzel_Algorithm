function [calka] = metoda_simpsona(a, b, n, ak)
% metoda_simpsona
% Oblicza przybliżoną wartość całki funkcji f(x) na przedziale [a, b]
% za pomocą złożonej metody Simpsona.
%
% Wejście:
%   a, b - granice całkowania (liczby)
%   n    - liczba podprzedziałów (musi być parzysta)
%   ak   - wektor współczynników ak (długości m)
%
% Wyjście:
%   calka - przybliżona wartość całki funkcji f(x) na [a, b]
%
% UWAGA: Funkcja f(x) jest wyznaczana przez funkcja_goertzel(x, ak)

m = length(ak); % liczba składników sumy

% Sprawdzenie, czy liczba podprzedziałów jest parzysta
if mod(n, 2) ~= 0
    error('Liczba podprzedziałów n musi być parzysta.');
end

% Oblicz krok całkowania
h = (b - a) / n;

% Wyznacz punkty węzłowe (x0, x1, ..., xn)
x = a:h:b;

% Oblicz wartości funkcji w punktach węzłowych
fx = zeros(1, n+1);
for i = 1:n+1
    fx(i) = funkcja_goertzel(x(i), ak); % f(x) w każdym punkcie
end

% Oblicz sumy do wzoru Simpsona:
% suma1: wartości na końcach przedziału (f(x0) + f(xn))
suma1 = fx(1) + fx(n+1);

% suma2: wartości w punktach o nieparzystych indeksach (f(x1), f(x3), ...)
suma2 = 0;
for i = 2:2:n
    suma2 = suma2 + fx(i);
end

% suma3: wartości w punktach o parzystych indeksach (f(x2), f(x4), ...)
suma3 = 0;
for i = 3:2:n-1
    suma3 = suma3 + fx(i);
end

% Zastosuj wzór Simpsona do obliczenia przybliżonej całki
calka = h/3 * (suma1 + 4*suma2 + 2*suma3);

end

% Przykład wywołania:
% a = 0;
% b = pi;
% n = 100; % liczba podprzedziałów (parzysta)
% ak = [1, 0.5, 0.25];
% wynik = metoda_simpsona(a, b, n, ak)
