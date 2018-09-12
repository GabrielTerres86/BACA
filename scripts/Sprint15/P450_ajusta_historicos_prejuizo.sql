-- Marca os históricos para lançamento aberto por PA no CRPS249
UPDATE craphis his
   SET his.tpctbcxa = 0
 WHERE his.cdhistor IN (2408, 2412, 2716, 2717, 2721, 2722)
;	  

-- Ajusta NMESTRUT (nome da tabela) dos históricos
UPDATE craphis his
   SET his.nmestrut = 'TBCC_PREJUIZO_DETALHE'
 WHERE his.cdhistor IN (2408, 2412, 2716, 2717, 2721, 2733, 2723, 2725, 2727, 2729, 2722, 2732, 2724, 2726, 2728, 2730)
;	 

-- Ajusta NMESTRUT (nome da tabela) dos históricos
UPDATE craphis his
   SET his.nmestrut = 'TBCC_PREJUIZO_LANCAMENTO'
 WHERE his.cdhistor IN (2738, 2739)
;

-- Ajusta as flags com efeito nas rotinas de débito/crédito para contas em prejuízo
UPDATE craphis his
   SET his.inestoura_conta = 1        -- Debita mesmo com a conta estourada
	   , his.indebprj = 1               -- Debita mesmo que a conta esteja em prejuízo
		 , his.intransf_cred_prejuizo = 0 -- Se deve transferir o crédito para a conta transitória
 WHERE his.cdhistor IN (2408,2412,2716,2717,2718,2719,2720,2738,2739,2721,2733,2723,2725,2727,2729,2722,2732,2724,2726,2728,2730,2323)		 
;

COMMIT;
		  
