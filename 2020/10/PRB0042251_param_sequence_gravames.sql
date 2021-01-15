 -- Cria par�metros necess�rios para funcionamento da fun��o.
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
             ,'SEQ_PROC_B3_NRO'
             ,'Sequencial de processamento do arquivo na B3.'
             ,'0');
      --      
      insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
      values ('CRED'
             ,rw_crapcop.cdcooper
             ,'SEQ_PROC_B3_DATA'
             ,'Data do sequencial de processamento do arquivo na B3. Incrementa se processo � na mesma data ou reinicia e atualiza data se data � diferente.'
             ,to_char(sysdate,'dd/mm/rrrr'));
      --
    END LOOP;
    COMMIT;
  end;