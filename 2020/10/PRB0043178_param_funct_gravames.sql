 -- Cria parâmetros necessários para funcionamento da função.
  declare
    CURSOR cr_crapcop IS
      SELECT c.cdcooper
        FROM crapcop      c
       WHERE c.flgativo = 1;
    rw_crapcop cr_crapcop%ROWTYPE; 
  begin
    FOR rw_crapcop IN cr_crapcop LOOP   
      insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
      values ('CRED'
             ,rw_crapcop.cdcooper
             ,'SEQ_PROC_LOTE_NRO'
             ,'Lote de processamento do arquivo por cooperativa.'
             ,'0');
    END LOOP;
    COMMIT;
  end;
  
