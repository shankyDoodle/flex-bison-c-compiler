calcout.exe : calc.tab.c
	gcc -o calc calc.tab.c lex.yy.c -ll

calc.tab.c : calc.l
	flex -l calc.l
	bison -dv calc.y
