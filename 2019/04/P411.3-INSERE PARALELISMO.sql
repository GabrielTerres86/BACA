-- P411.3 David Valente [Envolti]
-- INSERE O PROGRAMA PARA RODAR EM BATCH
DECLARE
   v_IDPARAMETRO NUMBER;      -- CÓDIGO DA TABELA
   V_CDPROGRAMA VARCHAR2(40); -- PROGRAMA
BEGIN
   
   V_CDPROGRAMA := 'CRPS753';
   
   -- PEGA O ÚLTIMO REGISTRO
   SELECT max(IDPARAMETRO) + 1 INTO v_IDPARAMETRO
   FROM tbgen_batch_param;
   
   -- INSERE O REGISTRO 
   INSERT INTO tbgen_batch_param (IDPARAMETRO, qtparalelo, qtreg_transacao, cdcooper, cdprograma )
   VALUES (v_IDPARAMETRO, 10, 0, 1, V_CDPROGRAMA);   
   COMMIT;
END;