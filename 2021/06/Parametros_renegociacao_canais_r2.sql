-- Created on 24/06/2021 by t0032717
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

      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_ATIVAR_MOBILE_RENCAN'  , 'Ativar Mobile - Renegocia��o.'      , '1');
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_ATIVAR_CNT_ONL_RENCAN', 'Ativar Conta Online - Renegocia��o.', '1');
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_VLMXRECA_RENCAN', 'Valor m�ximo de contratos de renegocia��o - H�brido.', '1');
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_VLMXREMO_RENCAN', 'Valor m�ximo de contratos de renegocia��o - Mobile.', '1');      
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_VLMXREON_RENCAN', 'Valor m�ximo de contratos de renegocia��o - On Line.', '1');
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_VLMXCOHI_RENCAN', 'Valor M�ximo para tornar contrata��o h�brida.', '1');
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_VALIDADE_PRO_RENCAN', 'Quantidade de dias para validade da proposta.', '1');    
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'VL_DESC_ASSAVAL_RENCAN', 'Valor m�ximo para desconsiderar assinatura aval e s�cios (PJ).', '10000');
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_ATRASO_MINIMO_RENCAN', 'Dias em atraso do contrato disponivel para renegociar(min).', '1');
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_ATRASO_MAXIMO_RENCAN', 'Dias em atraso do contrato disponivel para renegociar(max).', '30');
      
    END LOOP;
    
    UPDATE crapaca SET lstparam = 'pr_prtlmult,pr_prestorn,pr_prpropos,pr_vlempres,pr_pzmaxepr,pr_vlmaxest,pr_pcaltpar,pr_vltolemp,pr_qtdpaimo,pr_qtdpaaut,pr_qtdpaava,pr_qtdpaapl,pr_qtdpasem,pr_qtdpameq,pr_qtdibaut,pr_qtdibapl,pr_qtdibsem,pr_qtditava,pr_qtditapl,pr_qtditsem,pr_pctaxpre,pr_qtdictcc,pr_avtperda,pr_vlperavt,pr_vlmaxdst,pr_inpreapv,pr_vlmincnt,pr_nrmxrene,pr_nrmxcore,pr_pcalttax,pr_nrperccc,pr_qtdiamin,pr_qtdiamax,pr_cdfincan,pr_cdlcrcpp,pr_cdlcrpos,pr_idcarenc,pr_tptrrene,pr_flgfinta,pr_flglimcr,pr_flgcores,pr_nrmxreca,pr_nrmxcoca,pr_qtvalsim,pr_flatmobi,pr_flatconl,pr_vlmxremo,pr_vlmxreon,pr_vlmxreca,pr_qtvalpro,pr_preapvhib,pr_vlmaxhibfis,pr_vlmaxhibjur,pr_vlmxassi,pr_flatchib,pr_cdviscnt,pr_qtminatr,pr_qtmaxatr'
    WHERE  nmdeacao             = 'TAB089_ALTERAR';
	
    COMMIT;
    dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
    ROLLBACK;
  END;
END;
