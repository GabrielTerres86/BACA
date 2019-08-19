/* 
Solicitação: INC0014425
Objetivo   : Alterar a situação da conta 9686983 (Viacredi) para 1 (liberda) conforme solicitado pela área de negócios e alinhado com Sarah (cadastros). Há uma restrição que impede essa alteração via sistema (conta com CDSITDCT = 8).
Autor      : Edmar
*/


UPDATE CRAPASS A
SET A.CDSITDCT = 1
WHERE A.NRDCONTA = 9686983
  AND A.CDCOOPER = 1;
COMMIT;