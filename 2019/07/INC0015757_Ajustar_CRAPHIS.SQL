/* 
Solicita��o: INC0015757
Objetivo   : Ajustar a coluna CRAPHIS.DSEXTHST para os casos que cont�m o caracter inv�lido ASCII = 26 (setinha) nesta coluna. Este caracter est� sendo substitu�do por um h�fen (-).
Autor      : Edmar
*/


UPDATE CRAPHIS h
SET h.dsexthst = replace(h.dsexthst, chr(26), '-')
WHERE instr(h.dsexthst, chr(26)) > 0;

COMMIT;