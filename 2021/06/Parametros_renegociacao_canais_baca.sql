begin
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'CD_FINALI_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'CD_FINALI_RENCAN', 'Finalidade padrão para renegociações por canais', '62');
  --        
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'CD_LINHAPP_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'CD_LINHAPP_RENCAN', 'Linha de crédito padrão para pp', '259');
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'CD_LINHAPOS_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'CD_LINHAPOS_RENCAN', 'Linha de crédito padrão para pós', '260');
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_VLMXRECA_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_VLMXRECA_RENCAN', 'Valor máximo de contratos de renegociação - Híbrido.', '250000');
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_VLMXREMO_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_VLMXREMO_RENCAN', 'Valor máximo de contratos de renegociação - Mobile.', '250000');      
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_VLMXREON_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_VLMXREON_RENCAN', 'Valor máximo de contratos de renegociação - On Line.', '250000');
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_VLMXCOHI_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_VLMXCOHI_RENCAN', 'Valor Máximo para tornar contratação híbrida.', '250000');
  -- 
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_VALIDADE_PRO_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_VALIDADE_PRO_RENCAN', 'Quantidade de dias para validade da proposta.', '15');    
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_VALIDADE_SIM_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_VALIDADE_SIM_RENCAN', 'Validade da Simulacao', '15');
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_NRMXRECA_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_NRMXRECA_RENCAN', 'Máximo de renegociações por contrato', '10');
  --        
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_NRMXCOCA_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_NRMXCOCA_RENCAN', 'Máximo de contratos na proposta', '10');
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'VL_DESC_ASSAVAL_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'VL_DESC_ASSAVAL_RENCAN', 'Valor máximo para desconsiderar assinatura aval e sócios (PJ)', '10');
  --
  commit;
end;
