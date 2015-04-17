
sum([], 0).
sum([X|L], R):- sum(L, S), R is X + S.


mult([], 1).
mult([X|L], R):- mult(L, S), R is X * S.


concat([], L, L).
concat([X|L], L1, [X|R]):- concat(L, L1, R).


pescalar([], [], 0).
pescalar([X1|L1], [X2|L2], R):- pescalar(L1, L2, X),  R is (X1 * X2) + X.


in(X, [X|_]):- !.
in(Y, [_|L]):- in(Y, L).

intersect([], _, []).
intersect([X|L], L1, R):- in(X, L1), !, intersect(L, L1, R1), R = [X|R1].
intersect([_|L], L1, R):- intersect(L, L1, R1), R = R1.

union([], L, L).
union([X|L], L1, R):- in(X, L1), !, union(L, L1, R1), R = R1.
union([X|L], L1, R):- union(L, L1, R1), R = [X|R1].


back(L, X):- concat(_, [X], L).


dice(0, 0, []):- !.
dice(P, N, L):-
	N > 0,
	member(X, [1,2,3,4,5,6]),
	P_ is P-X,
	N_ is N-1,
	dice(P_, N_, L_),
	L = [X|L_].


fib(1, 1):- !.
fib(2, 1):- !.
fib(N,F):-
	N_1 is N-1,
	N_2 is N-2,
	fib(N_1, F_1),
	fib(N_2, F_2),
	F is F_1 + F_2.


range(Min, Min, [Min]):- !.
range(Min, Max, []):- Min > Max, !.
range(Min, Max, R):-
	Min < Max,
	Min_ is Min+1,
	range(Min_, Max, R_),
	R = [Min|R_].


suma_demas(L):- sum(L, X_), member(X, L), X is X_-X, !.


suma_ants(_, []):- !, fail.
suma_ants(X, [Y|_]):- X is Y, !.
suma_ants(X, [Y|L]):- X_ is X + Y, suma_ants(X_, L).
suma_ants(L):- suma_ants(0, L).


card_insert_number(X, [], R):- R = [[X, 1]], !.
card_insert_number(X, [[X, C]|LL], R):- C_ is C+1, R = [[X, C_]|LL], !.
card_insert_number(X, [Y|LL], R):- card_insert_number(X, LL, R_), R = [Y|R_].

card_insert_card(X, [], R):- R = [X], !.
card_insert_card([I, C_1], [[I, C_2]|LL], R):- C_ is C_1 + C_2, R = [[I, C_]|LL], !.
card_insert_card(X, [Y|LL], R):- card_insert_card(X, LL, R_), R = [Y|R_].

card_merge_card([], L2, R):- R = L2, !.
card_merge_card([X|L1], L2, R):- card_insert_card(X, L2, R_), card_merge_card(L1, R_, R).

card([], []):- !.
card([X|LL], R):- card_insert_number(X, [], R_), card(LL, R__), card_merge_card(R_, R__, R).

card(L):- card(L, R), write(R).


esta_ordenada([_]):- !.
esta_ordenada([X,Y|L]):- X =< Y, esta_ordenada([Y|L]).


pert_con_resto(X, L, Resto):- concat(L1, [X|L2], L), concat(L1, L2, Resto).

permutacion([], []).
permutacion(L, [X|P]):- pert_con_resto(X, L, R), permutacion(R, P).


ordenacion(L1, L2):- permutacion(L1, L2), esta_ordenada(L2), !.