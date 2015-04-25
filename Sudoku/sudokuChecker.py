rows = {}
columns = {}
squares = {}
ok = True
print('\n')
for i in range(0,9):
	r = raw_input();
	while r == '':
		r = raw_input();
	values = map(int, filter(lambda x: x != '', r.split(' ')))
	for j in range(0,9):
		k = values[j]
		n = str(i) + "-" + str(k)
		if n in rows.keys():
			ok = False
			print("row %i already has value %i at column %i" % (i, k, rows[n]))
		else:
			rows[n] = j
		n = str(j) + "-" + str(k)
		if n in columns.keys():
			ok = False
			print("column %i already has value %i at row %i" % (j, k, columns[n]))
		else:
			columns[n] = i
		n = str(i // 3) + "-" + str(j // 3) + "-" + str(k)
		if n in squares.keys():
			ok = False
			print("square %i-%i already has value %i at position %s" % (i // 3, j // 3, k, squares[n]))
		else:
			squares[n] = str(i) + "-" + str(j)

if ok:
	print("Sudoku checked")