:-include(graphColoringInstance1).
:-dynamic(varNumber/3).

size(9).
subSize(3).

symbolicOutput(1). % set to 1 to see symbolic output only; 0 otherwise.

% writeClauses:- atleastOneNumberPerCell,
	atmostOneNumberPerCell,
	atleastOneNumberPerColumn,
	atmostOneNumberPerColumn,
	atleastOneNumberPerRow,
	atmostOneNumberPerRow.
writeClauses:- atmostOneNumberPerRow.

% writeClauses:- atleastOneColorPerNode, atmostOneColorPerNode, differentColors.
% 
% atleastOneColorPerNode:- numNodes(N), numColors(K), between(1,N,I),
% 	findall( x-I-J, between(1,K,J), C ), writeClause(C), fail.
% atleastOneColorPerNode.
% 
% atmostOneColorPerNode:- numNodes(N), numColors(K), 
% 	between(1,N,I), between(1,K,J1), between(1,K,J2), J1<J2,
% 	writeClause( [ \+x-I-J1, \+x-I-J2 ] ), fail.
% atmostOneColorPerNode.
% 
% differentColors:- edge(I1,I2), numColors(K), between(1,K,J),
% 	writeClause( [ \+x-I1-J, \+x-I2-J ] ), fail.
% differentColors.

atleastOneNumberPerCell:- size(N),
	between(1, N, I), between(1, N, J), findall(x-I-J-K, between(1, N, K), C), writeClause(C), fail.
atleastOneNumberPerCell.
atmostOneNumberPerCell:- size(N),
	between(1, N, I), between(1, N, J), N_ is N-1, between(1, N_, K), K1 is K+1,
	writeClause([\+x-I-J-K, \+x-I-J-K1]), fail.
atmostOneNumberPerCell.

atleastOneNumberPerColumn:- size(N),
	between(1, N, I), between(1, N, K), findall(x-I-J-K, between(1, N, J), C), writeClause(C), fail.
atleastOneNumberPerColumn.
atmostOneNumberPerColumn:- size(N),
	between(1, N, I), between(1, N, K), N_ is N-1, between(1, N_, J), J1 is J+1,
	writeClause([\+x-I-J-K, \+x-I-J1-K]), fail.
atmostOneNumberPerColumn.

atleastOneNumberPerRow:- size(N),
	between(1, N, J), between(1, N, K), findall(x-I-J-K, between(1, N, I), C), writeClause(C), fail.
atleastOneNumberPerRow.
atmostOneNumberPerRow:- size(N),
	between(1, N, J), between(1, N, K), N_ is N-1, between(1, N_, I), I1 is I+1,
	writeClause([\+x-I-J-K, \+x-I1-J-K]), fail.
atmostOneNumberPerRow.

% TODO: falta implementar esto!
atleastOneNumberPerSquare:- size(N), subSize(SubN),
	between(1, N, J), between(1, N, K), findall(x-I-J-K, between(1, N, I), C), writeClause(C), fail.
atleastOneNumberPerSquare.
% TODO: falta implementar esto!
atmostOneNumberPerSquare:- size(N), subSize(SubN),
	between(1, N, J), between(1, N, K), N_ is N-1, between(1, N_, I), I1 is I+1,
	writeClause([\+x-I-J-K, \+x-I1-J-K]), fail.
atmostOneNumberPerSquare.

displaySol([]).
displaySol([Nv|S]):- num2var(Nv,x-I-J), write(I), write(': color '), write(J), nl, displaySol(S).


% ========== No need to change the following: =====================================

main:- symbolicOutput(1), !, writeClauses, halt. % escribir bonito, no ejecutar
main:-  assert(numClauses(0)), assert(numVars(0)),
	tell(clauses), writeClauses, told,
	tell(header),  writeHeader,  told,
	unix('cat header clauses > infile.cnf'),
	unix('picosat -v -o model infile.cnf'),
	unix('cat model'),
	see(model), readModel(M), seen, displaySol(M),
	halt.

var2num(T,N):- hash_term(T,Key), varNumber(Key,T,N),!.
var2num(T,N):- retract(numVars(N0)), N is N0+1, assert(numVars(N)), hash_term(T,Key),
	assert(varNumber(Key,T,N)), assert( num2var(N,T) ), !.

writeHeader:- numVars(N),numClauses(C),write('p cnf '),write(N), write(' '),write(C),nl.

countClause:-  retract(numClauses(N)), N1 is N+1, assert(numClauses(N1)),!.
writeClause([]):- symbolicOutput(1),!, nl.
writeClause([]):- countClause, write(0), nl.
writeClause([Lit|C]):- w(Lit), writeClause(C),!.
w( Lit ):- symbolicOutput(1), write(Lit), write(' '),!.
w(\+Var):- var2num(Var,N), write(-), write(N), write(' '),!.
w(  Var):- var2num(Var,N),           write(N), write(' '),!.
unix(Comando):-shell(Comando),!.
unix(_).

readModel(L):- get_code(Char), readWord(Char,W), readModel(L1), addIfPositiveInt(W,L1,L),!.
readModel([]).

addIfPositiveInt(W,L,[N|L]):- W = [C|_], between(48,57,C), number_codes(N,W), N>0, !.
addIfPositiveInt(_,L,L).

readWord(99,W):- repeat, get_code(Ch), member(Ch,[-1,10]), !, get_code(Ch1), readWord(Ch1,W),!.
readWord(-1,_):-!, fail. %end of file
readWord(C,[]):- member(C,[10,32]), !. % newline or white space marks end of word
readWord(Char,[Char|W]):- get_code(Char1), readWord(Char1,W), !.
%========================================================================================
