BEGIN
  DECLARE
    -- nome da rotina
    wk_rotina varchar2(200) := 'Cria��o de novos par�metros da Renegocia��o Facilitada para Canais (tabela crapprm)';
    CURSOR cr_crapcop IS
    SELECT *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    --
    aux_vlmxremo varchar(100);
    aux_vlmxreon varchar(100);
    --
  BEGIN
    FOR rw_crapcop IN cr_crapcop LOOP
      --
      aux_vlmxremo := gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'QT_VLMXREMO_RENCAN');   
      aux_vlmxreon := gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'QT_VLMXREON_RENCAN');   
      --
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'VL_VLMXGARMOI_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'VL_VLMXGARMOI_RENCAN', 'Valor m�ximo de contratos de renegocia��o - Mobile - Im�vel.',aux_vlmxremo);      
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'VL_VLMXGARMOM_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'VL_VLMXGARMOM_RENCAN', 'Valor m�ximo de contratos de renegocia��o - Mobile - M�vel.',aux_vlmxremo);      
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'VL_VLMXGARMOA_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'VL_VLMXGARMOA_RENCAN', 'Valor m�ximo de contratos de renegocia��o - Mobile - Aval.',aux_vlmxremo);      
      --
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'VL_VLMXGARONI_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'VL_VLMXGARONI_RENCAN', 'Valor m�ximo de contratos de renegocia��o - Conta OnLine - Im�vel.',aux_vlmxreon);      
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'VL_VLMXGARONM_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'VL_VLMXGARONM_RENCAN', 'Valor m�ximo de contratos de renegocia��o - Conta OnLine - M�vel.',aux_vlmxreon);      
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'VL_VLMXGARONA_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'VL_VLMXGARONA_RENCAN', 'Valor m�ximo de contratos de renegocia��o - Conta OnLine - Aval.',aux_vlmxreon);      
      --
	    --
	    delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'CD_PR_INC_CNT_PRO_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_PR_INC_CNT_PRO_RENCAN', 'Poder� incluir proposta ou poder� utilizar o app/Conta online para tamb�m contratar','1');     
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_MAX_ENV_ANALIS_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_MAX_ENV_ANALIS_RENCAN', 'Quantidade M�xima de envios para an�lise','10');     
      --     
      --
	    delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_MAXMESENVAN_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED', rw_crapcop.cdcooper, 'QT_MAXMESENVAN_RENCAN', 'Meses decorridos para controle de maximo de envios para analise',6);
	  --
    END LOOP;
    --
    UPDATE crapaca SET lstparam = lstparam||',pr_vlmxgarmoi,pr_vlmxgarmom,pr_vlmxgarmoa,pr_vlmxgaroni,pr_vlmxgaronm,pr_vlmxgarona,pr_cdperpro,pr_qtmxenva,pr_qtmsenva'
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
