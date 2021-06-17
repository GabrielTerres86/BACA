-- Created on 15/06/2021 by t0033292 
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
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'CD_FINALI_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_FINALI_RENCAN', 'Finalidade padrão para renegociações por canais', '62');
      --        
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'CD_LINHAPP_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_LINHAPP_RENCAN', 'Linha de crédito padrão para pp', '259');
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'CD_LINHAPOS_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_LINHAPOS_RENCAN', 'Linha de crédito padrão para pós', '260');
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_VLMXRECA_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_VLMXRECA_RENCAN', 'Valor máximo de contratos de renegociação - Híbrido.', '250000');
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_VLMXREMO_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_VLMXREMO_RENCAN', 'Valor máximo de contratos de renegociação - Mobile.', '250000');      
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_VLMXREON_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_VLMXREON_RENCAN', 'Valor máximo de contratos de renegociação - On Line.', '250000');
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_VLMXCOHI_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_VLMXCOHI_RENCAN', 'Valor Máximo para tornar contratação híbrida.', '250000');
      -- 
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_VALIDADE_PRO_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_VALIDADE_PRO_RENCAN', 'Quantidade de dias para validade da proposta.', '15');    
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_VALIDADE_SIM_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_VALIDADE_SIM_RENCAN', 'Validade da Simulacao', '15');
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_NRMXRECA_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_NRMXRECA_RENCAN', 'Máximo de renegociações por contrato', '10');
      --        
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'QT_NRMXCOCA_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_NRMXCOCA_RENCAN', 'Máximo de contratos na proposta', '10');
      --
      delete crapprm where nmsistem = 'CRED' and cdcooper = rw_crapcop.cdcooper and cdacesso = 'VL_DESC_ASSAVAL_RENCAN';
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'VL_DESC_ASSAVAL_RENCAN', 'Valor máximo para desconsiderar assinatura aval e sócios (PJ)', '10');
    END LOOP;
    COMMIT;
    dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
    ROLLBACK;
  END;
END;
