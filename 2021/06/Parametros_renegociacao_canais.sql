-- Created on 13/05/2021 by t0033292 
BEGIN
  DECLARE
    -- nome da rotina
    wk_rotina varchar2(200) := 'Cria��o de novos par�metros da Renegocia��o Facilitada para Canais (tabela crapprm)';
    CURSOR cr_crapcop IS
    SELECT *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
  BEGIN
    -- Percorrer as cooperativas do cursor
    FOR rw_crapcop IN cr_crapcop LOOP
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'CD_ATIVAR_MOBILE_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_ATIVAR_MOBILE_RENCAN'  , 'Ativar Mobile - Renegocia��o.'      , '1');
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'CD_ATIVAR_CNT_ONL_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_ATIVAR_CNT_ONL_RENCAN', 'Ativar Conta Online - Renegocia��o.', '1');
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_VLMXRECA_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_VLMXRECA_RENCAN', 'Valor m�ximo de contratos de renegocia��o - H�brido.', '1');
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_VLMXREMO_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_VLMXREMO_RENCAN', 'Valor m�ximo de contratos de renegocia��o - Mobile.', '1');      
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_VLMXREON_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_VLMXREON_RENCAN', 'Valor m�ximo de contratos de renegocia��o - On Line.', '1');
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_VALIDADE_PRO_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_VALIDADE_PRO_RENCAN', 'Quantidade de dias para validade da proposta.', '1');    
      --
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'VL_DESC_ASSAVAL_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'VL_DESC_ASSAVAL_RENCAN', 'Valor m�ximo para desconsiderar assinatura aval e s�cios (PJ)', '10');
      --  
      --  
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_VLMXCOHI_RENCAN';
      --        
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'CD_VISUALIZAR_CNT_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_VISUALIZAR_CNT_RENCAN', 'Visualizar Contratos nos Canais - Renegocia��o.', '3');
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'CD_ATIVAR_CNT_HIB_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_ATIVAR_CNT_HIB_RENCAN', 'Ativar Contrato H�brido - Renegocia��o.'        , '1');
      --
    END LOOP;
    
    UPDATE crapaca SET lstparam = 'pr_prtlmult,pr_prestorn,pr_prpropos,pr_vlempres,pr_pzmaxepr,pr_vlmaxest,pr_pcaltpar,pr_vltolemp,pr_qtdpaimo,pr_qtdpaaut,pr_qtdpaava,pr_qtdpaapl,pr_qtdpasem,pr_qtdpameq,pr_qtdibaut,pr_qtdibapl,pr_qtdibsem,pr_qtditava,pr_qtditapl,pr_qtditsem,pr_pctaxpre,pr_qtdictcc,pr_avtperda,pr_vlperavt,pr_vlmaxdst,pr_inpreapv,pr_vlmincnt,pr_nrmxrene,pr_nrmxcore,pr_pcalttax,pr_nrperccc,pr_qtdiamin,pr_qtdiamax,pr_cdfincan,pr_cdlcrcpp,pr_cdlcrpos,pr_idcarenc,pr_tptrrene,pr_flgfinta,pr_flglimcr,pr_flgcores,pr_nrmxreca,pr_nrmxcoca,pr_qtvalsim,pr_flatmobi,pr_flatconl,pr_vlmxremo,pr_vlmxreon,pr_vlmxreca,pr_qtvalpro,pr_preapvhib,pr_vlmaxhibfis,pr_vlmaxhibjur,pr_vlmxassi,pr_flatchib,pr_cdviscnt'
    WHERE  nmdeacao             = 'TAB089_ALTERAR';
	
    COMMIT;
    dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
    ROLLBACK;
  END;
END;
