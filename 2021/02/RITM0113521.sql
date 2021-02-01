DECLARE
   v_IDPARAMETRO NUMBER;      -- CÓDIGO DA TABELA
   V_CDPROGRAMA VARCHAR2(40); -- PROGRAMA
BEGIN
   
   V_CDPROGRAMA := 'CRPS723';
   
   SELECT max(IDPARAMETRO) + 1 INTO v_IDPARAMETRO FROM tbgen_batch_param;   
   INSERT INTO tbgen_batch_param (IDPARAMETRO, qtparalelo, qtreg_transacao, cdcooper, cdprograma ) VALUES (v_IDPARAMETRO, 10, 0, 1, V_CDPROGRAMA);   
   
   SELECT max(IDPARAMETRO) + 1 INTO v_IDPARAMETRO FROM tbgen_batch_param;   
   INSERT INTO tbgen_batch_param (IDPARAMETRO, qtparalelo, qtreg_transacao, cdcooper, cdprograma ) VALUES (v_IDPARAMETRO, 10, 0, 2, V_CDPROGRAMA);   
   
   SELECT max(IDPARAMETRO) + 1 INTO v_IDPARAMETRO FROM tbgen_batch_param;   
   INSERT INTO tbgen_batch_param (IDPARAMETRO, qtparalelo, qtreg_transacao, cdcooper, cdprograma ) VALUES (v_IDPARAMETRO, 10, 0, 3, V_CDPROGRAMA);   
   
   SELECT max(IDPARAMETRO) + 1 INTO v_IDPARAMETRO FROM tbgen_batch_param;   
   INSERT INTO tbgen_batch_param (IDPARAMETRO, qtparalelo, qtreg_transacao, cdcooper, cdprograma ) VALUES (v_IDPARAMETRO, 10, 0, 5, V_CDPROGRAMA);   
   
   SELECT max(IDPARAMETRO) + 1 INTO v_IDPARAMETRO FROM tbgen_batch_param;   
   INSERT INTO tbgen_batch_param (IDPARAMETRO, qtparalelo, qtreg_transacao, cdcooper, cdprograma ) VALUES (v_IDPARAMETRO, 10, 0, 6, V_CDPROGRAMA);   
   
   SELECT max(IDPARAMETRO) + 1 INTO v_IDPARAMETRO FROM tbgen_batch_param;   
   INSERT INTO tbgen_batch_param (IDPARAMETRO, qtparalelo, qtreg_transacao, cdcooper, cdprograma ) VALUES (v_IDPARAMETRO, 10, 0, 7, V_CDPROGRAMA);   
   
   SELECT max(IDPARAMETRO) + 1 INTO v_IDPARAMETRO FROM tbgen_batch_param;   
   INSERT INTO tbgen_batch_param (IDPARAMETRO, qtparalelo, qtreg_transacao, cdcooper, cdprograma ) VALUES (v_IDPARAMETRO, 10, 0, 8, V_CDPROGRAMA);   
   
   SELECT max(IDPARAMETRO) + 1 INTO v_IDPARAMETRO FROM tbgen_batch_param;   
   INSERT INTO tbgen_batch_param (IDPARAMETRO, qtparalelo, qtreg_transacao, cdcooper, cdprograma ) VALUES (v_IDPARAMETRO, 10, 0, 9, V_CDPROGRAMA);
   
   SELECT max(IDPARAMETRO) + 1 INTO v_IDPARAMETRO FROM tbgen_batch_param;
   INSERT INTO tbgen_batch_param (IDPARAMETRO, qtparalelo, qtreg_transacao, cdcooper, cdprograma ) VALUES (v_IDPARAMETRO, 10, 0, 10, V_CDPROGRAMA);
   
   SELECT max(IDPARAMETRO) + 1 INTO v_IDPARAMETRO FROM tbgen_batch_param;
   INSERT INTO tbgen_batch_param (IDPARAMETRO, qtparalelo, qtreg_transacao, cdcooper, cdprograma ) VALUES (v_IDPARAMETRO, 10, 0, 11, V_CDPROGRAMA);   
   
   SELECT max(IDPARAMETRO) + 1 INTO v_IDPARAMETRO FROM tbgen_batch_param; 
   INSERT INTO tbgen_batch_param (IDPARAMETRO, qtparalelo, qtreg_transacao, cdcooper, cdprograma ) VALUES (v_IDPARAMETRO, 10, 0, 12, V_CDPROGRAMA);
   
   SELECT max(IDPARAMETRO) + 1 INTO v_IDPARAMETRO FROM tbgen_batch_param;
   INSERT INTO tbgen_batch_param (IDPARAMETRO, qtparalelo, qtreg_transacao, cdcooper, cdprograma ) VALUES (v_IDPARAMETRO, 10, 0, 13, V_CDPROGRAMA);
   
   SELECT max(IDPARAMETRO) + 1 INTO v_IDPARAMETRO FROM tbgen_batch_param;
   INSERT INTO tbgen_batch_param (IDPARAMETRO, qtparalelo, qtreg_transacao, cdcooper, cdprograma ) VALUES (v_IDPARAMETRO, 10, 0, 14, V_CDPROGRAMA);
   
   SELECT max(IDPARAMETRO) + 1 INTO v_IDPARAMETRO FROM tbgen_batch_param;
   INSERT INTO tbgen_batch_param (IDPARAMETRO, qtparalelo, qtreg_transacao, cdcooper, cdprograma ) VALUES (v_IDPARAMETRO, 10, 0, 16, V_CDPROGRAMA);
   
   COMMIT;
END;