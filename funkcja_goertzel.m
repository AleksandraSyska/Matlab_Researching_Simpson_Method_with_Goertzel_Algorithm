function wartosc = funkcja_goertzel(t, ak)
% funkcja_goertzel
% Oblicza f(t) = sum(ak .* sin(k*t)) dla k=1:n za pomocą algorytmu Goertzela.
%
% Wejście:
%   t  - punkt, w którym liczymy wartość funkcji (skalar)
%   ak - wektor współczynników (długość n)
%   n  - liczba składników sumy (ilość sinusów)
% Wyjście:
%   wartosc - wartość funkcji f(t) w punkcie t



n = length(ak);
N = 100;            % Liczba próbek używana przez algorytm Goertzela
k = (1:n)';         % Numery składników (kolumna: 1, 2, ..., n)

% Wyznacz częstotliwości dla każdego składnika
w = 2*pi*k/N;       % Częstotliwości Goertzela dla każdego k

% Oblicz stałe potrzebne do algorytmu Goertzela
cw = cos(w);        % Kosinusy częstotliwości
c = 2*cw;           % Dwukrotność kosinusów (używana w rekursji)
sw = sin(w);        % Sinusy częstotliwości

% Inicjalizacja zmiennych pomocniczych dla rekursji Goertzela
z1 = zeros(n,1);    % Poprzednia wartość rekursji (z[-1])
z2 = zeros(n,1);    % Poprzednia poprzednia wartość rekursji (z[-2])

% Sztuczny sygnał wejściowy: impuls jednostkowy
x = zeros(N,1);
x(1) = 1;

% Główna pętla rekursji Goertzela
for i = 1:N
    z0 = x(i) + c.*z1 - z2; % Rekurencja Goertzela
    z2 = z1;
    z1 = z0;
end

% Oblicz części rzeczywistą (I) i urojoną (Q) dla każdego składnika
I = cw.*z1 - z2;
Q = sw.*z1;

% Wyznacz fazę dla każdego składnika (atan2 daje kąt w układzie biegunowym)
faza = atan2(Q, I);

% Odtwórz wartość sinusa dla każdego składnika w punkcie t
sinusy = sin(faza + mod(k*t, 2*pi));

% Policz sumę: każdy sinus razy odpowiedni współczynnik ak
wartosc = sum(ak(:) .* sinusy);

end

% Przykład wywołania (zakomentowany):
% t = pi/3;
% ak = [1, 0.5, 0.25];
% n = 3;
% wynik = funkcja_goertzel(t, ak, n)
