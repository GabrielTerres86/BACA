/* 
Solicita��o: INC0014425
Objetivo   : Alterar a situa��o da conta 9686983 (Viacredi) para 1 (liberda) conforme solicitado pela �rea de neg�cios e alinhado com Sarah (cadastros). H� uma restri��o que impede essa altera��o via sistema (conta com CDSITDCT = 8).
Autor      : Edmar
*/


UPDATE CRAPASS A
SET A.CDSITDCT = 1
WHERE A.NRDCONTA = 9686983
  AND A.CDCOOPER = 1;
COMMIT;