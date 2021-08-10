-- Created on 28/07/2021 by t0033292 
BEGIN
  DECLARE
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de novos parâmetros da Renegociação Facilitada para Canais (tabela crapprm)';
    CURSOR cr_crapcop IS
    SELECT *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    --
  BEGIN
    FOR rw_crapcop IN cr_crapcop LOOP
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'CD_PR_INC_CNT_PRO_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_PR_INC_CNT_PRO_RENCAN', 'Poderá incluir proposta ou poderá utilizar o app/Conta online para também contratar','1');     
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_MAX_ENV_ANALIS_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_MAX_ENV_ANALIS_RENCAN', 'Quantidade Máxima de envios para análise','10');     
      --      
    END LOOP;
    --
    UPDATE crapaca SET lstparam = lstparam||',pr_cdperpro,pr_qtmxenva'
    WHERE  nmdeacao             = 'TAB089_ALTERAR_RENEG';
  	--
    COMMIT;
    dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
    ROLLBACK;
  END;
END;
