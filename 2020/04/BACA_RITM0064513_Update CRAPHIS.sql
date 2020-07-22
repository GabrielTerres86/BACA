 --Melhorias, Incidentes | RITM0064513 - Tela RCONSI
 --Adicionar um histórico de Estorno para os histórios 3026 e 3027, referente a pgto por conciliação
 UPDATE craphis h 
	SET h.cdhisest = (SELECT craphis.cdhisest
						FROM craphis
					   WHERE craphis.cdhistor = 1044 --PAGTO EMPRESTIMO TX. PRE-FIXADA C/C
						 AND craphis.cdcooper = h.cdcooper) 
  WHERE h.cdhistor in(3026,--PAGTO EMPRESTIMO CONSIGNADO PRE-FIXADO VIA C/C
                      3027);--PAGTO EMPRESTIMO CONSIGNADO PRE-FIXADO VIA TED
                      
 COMMIT;

 UPDATE craphis h
   SET h.cdhisest =
       (SELECT craphis.cdhisest
          FROM craphis
         WHERE craphis.cdhistor = 108 --PAGTO PRESTACAO DE EMPRESTIMO
           AND craphis.cdcooper = h.cdcooper)
 WHERE h.cdhistor in (3089); --PAGTO PRESTACAO DE EMPRESTIMO CONSIGNADO (em atraso)


COMMIT;
