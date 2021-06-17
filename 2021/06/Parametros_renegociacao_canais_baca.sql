begin
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'CD_FINALI_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'CD_FINALI_RENCAN', 'Finalidade padr�o para renegocia��es por canais', '62');
  --        
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'CD_LINHAPP_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'CD_LINHAPP_RENCAN', 'Linha de cr�dito padr�o para pp', '259');
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'CD_LINHAPOS_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'CD_LINHAPOS_RENCAN', 'Linha de cr�dito padr�o para p�s', '260');
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_VLMXRECA_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_VLMXRECA_RENCAN', 'Valor m�ximo de contratos de renegocia��o - H�brido.', '250000');
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_VLMXREMO_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_VLMXREMO_RENCAN', 'Valor m�ximo de contratos de renegocia��o - Mobile.', '250000');      
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_VLMXREON_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_VLMXREON_RENCAN', 'Valor m�ximo de contratos de renegocia��o - On Line.', '250000');
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_VLMXCOHI_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_VLMXCOHI_RENCAN', 'Valor M�ximo para tornar contrata��o h�brida.', '250000');
  -- 
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_VALIDADE_PRO_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_VALIDADE_PRO_RENCAN', 'Quantidade de dias para validade da proposta.', '15');    
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_VALIDADE_SIM_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_VALIDADE_SIM_RENCAN', 'Validade da Simulacao', '15');
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_NRMXRECA_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_NRMXRECA_RENCAN', 'M�ximo de renegocia��es por contrato', '10');
  --        
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'QT_NRMXCOCA_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'QT_NRMXCOCA_RENCAN', 'M�ximo de contratos na proposta', '10');
  --
  delete crapprm where nmsistem = 'CRED' and cdcooper = 13 and cdacesso = 'VL_DESC_ASSAVAL_RENCAN';
  INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', 13, 'VL_DESC_ASSAVAL_RENCAN', 'Valor m�ximo para desconsiderar assinatura aval e s�cios (PJ)', '10');
  --
  commit;
end;
