-- Created on 13/05/2021 by t0033292 
BEGIN
  DECLARE
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação de novos parâmetros da Renegociação Facilitada para Canais (tabela crapprm)';
    CURSOR cr_crapcop IS
    SELECT *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
  BEGIN
    -- Percorrer as cooperativas do cursor
    FOR rw_crapcop IN cr_crapcop LOOP
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_VLMXCOHI_RENCAN';
      --        
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'CD_VISUALIZAR_CNT_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_VISUALIZAR_CNT_RENCAN', 'Visualizar Contratos nos Canais - Renegociação.', '3');
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'CD_ATIVAR_CNT_HIB_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_ATIVAR_CNT_HIB_RENCAN', 'Ativar Contrato Híbrido - Renegociação.'        , '1');
      --
    END LOOP;

    UPDATE crapaca SET lstparam = lstparam || ',pr_flatchib,pr_cdviscnt'
    WHERE  nmdeacao             = 'TAB089_ALTERAR';
	
    COMMIT;
    dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
    ROLLBACK;
  END;
END;
