-- Created on 26/08/2020 by T0032717 
declare 
  -- Local variables here
  CURSOR cr_crapcop IS
    SELECT cdcooper 
      FROM crapcop
     WHERE cdcooper <> 3
       AND flgativo = 1;
   rw_crapcop cr_crapcop%ROWTYPE;
BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', rw_crapcop.cdcooper, 'CTRL_CRPS652_A_EXEC', 'Controle de execução das atualizacoes diarias de agencia na CRPS652', '25/08/2020#0');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', rw_crapcop.cdcooper, 'QTD_EXEC_CRPS652_A', 'Quantidade de execuções da atualizacao diarias de agencia na CRPS652', '1');
  END LOOP;
  COMMIT;
end;
