DECLARE 
  vr_datacorte DATE := TO_DATE('31/12/2099');
BEGIN
  FOR rw_coop IN  (SELECT cop.cdcooper
                     FROM crapcop cop
                    WHERE cop.flgativo = 1
                    ORDER BY cop.cdcooper) LOOP
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                  VALUES ('CRED',rw_coop.cdcooper, 'REGRA_PJ_MOTOR_0', 'Nome da politica PJ de Emprestimo no Motor de Credito NEUROTECH ','Polit_Neuro_Emprestimo_PJ');
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                  VALUES ('CRED',rw_coop.cdcooper, 'REGRA_PJ_MOTOR_1', 'Nome da politica PJ de Desc Titulo no Motor de Credito NEUROTECH ','Polit_Neuro_DescTit_PJ');
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                  VALUES ('CRED',rw_coop.cdcooper, 'REGRA_PJ_MOTOR_2', 'Nome da politica PJ de Simulação no Motor de Credito NEUROTECH ','Polit_Neuro_Simulacao_PJ');
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                  VALUES ('CRED',rw_coop.cdcooper, 'REGRA_PJ_MOTOR_3', 'Nome da politica PJ de Limite de Crédito no Motor de Credito NEUROTECH ','AILOS_LEGADO_PJ');
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                  VALUES ('CRED',rw_coop.cdcooper, 'REGRA_PJ_MOTOR_4', 'Nome da politica PJ de Cartão de Crédito no Motor de Credito NEUROTECH ','Polit_Neuro_Cartao_PJ');
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                  VALUES ('CRED',rw_coop.cdcooper, 'REGRA_PJ_MOTOR_5', 'Nome da politica PJ de Desc.Cheque Limite no Motor de Credito NEUROTECH ','Polit_Neuro_DescChqLim_PJ');
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                  VALUES ('CRED',rw_coop.cdcooper, 'REGRA_PJ_MOTOR_6', 'Nome da politica PJ de Desc.Cheque Borderô no Motor de Credito NEUROTECH ','Polit_Neuro_DescChqBord_PJ');

      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                  VALUES ('CRED',rw_coop.cdcooper, 'REGRA_PF_MOTOR_0', 'Nome da politica PF de Emprestimo no Motor de Credito NEUROTECH ','Polit_Neuro_Emprestimo_PF');
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                  VALUES ('CRED',rw_coop.cdcooper, 'REGRA_PF_MOTOR_1', 'Nome da politica PF de Desc Titulo no Motor de Credito NEUROTECH ','Polit_Neuro_DescTit_PF');
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                  VALUES ('CRED',rw_coop.cdcooper, 'REGRA_PF_MOTOR_2', 'Nome da politica PF de Simulação no Motor de Credito NEUROTECH ','Polit_Neuro_Simulacao_PF');
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                  VALUES ('CRED',rw_coop.cdcooper, 'REGRA_PF_MOTOR_3', 'Nome da politica PF de Limite de Crédito no Motor de Credito NEUROTECH ','AILOS_LEGADO_PF_V1');
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                  VALUES ('CRED',rw_coop.cdcooper, 'REGRA_PF_MOTOR_4', 'Nome da politica PF de Cartão de Crédito no Motor de Credito NEUROTECH ','Polit_Neuro_Cartao_PF');
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                  VALUES ('CRED',rw_coop.cdcooper, 'REGRA_PF_MOTOR_5', 'Nome da politica PF de Desc.Cheque Limite no Motor de Credito NEUROTECH ','Polit_Neuro_DescChqLim_PF');
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
                  VALUES ('CRED',rw_coop.cdcooper, 'REGRA_PF_MOTOR_6', 'Nome da politica PF de Desc.Cheque Borderô no Motor de Credito NEUROTECH ','Polit_Neuro_DescChqBord_PF');

      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',rw_coop.cdcooper, 'MOTOR_0', 'EMPR - DETERMINAR QUAL MOTOR VAI SER ACIONADO, NEUROTECH(0) OU IBRATAN(1) ',1);
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',rw_coop.cdcooper, 'MOTOR_1', 'DESCTIT - DETERMINAR QUAL MOTOR VAI SER ACIONADO, NEUROTECH(0) OU IBRATAN(1) ',1);
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',rw_coop.cdcooper, 'MOTOR_2', 'SIMUL - DETERMINAR QUAL MOTOR VAI SER ACIONADO, NEUROTECH(0) OU IBRATAN(1) ',1);
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',rw_coop.cdcooper, 'MOTOR_3', 'LIMCRED - DETERMINAR QUAL MOTOR VAI SER ACIONADO, NEUROTECH(0) OU IBRATAN(1) ',1);
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',rw_coop.cdcooper, 'MOTOR_4', 'CCRED - DETERMINAR QUAL MOTOR VAI SER ACIONADO, NEUROTECH(0) OU IBRATAN(1) ',1);
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',rw_coop.cdcooper, 'MOTOR_5', 'DSCCHQLIM - DETERMINAR QUAL MOTOR VAI SER ACIONADO, NEUROTECH(0) OU IBRATAN(1) ',1);
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',rw_coop.cdcooper, 'MOTOR_6', 'DSCCHQBORD - DETERMINAR QUAL MOTOR VAI SER ACIONADO, NEUROTECH(0) OU IBRATAN(1) ',1);

      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
      VALUES ('CRED',rw_coop.cdcooper, 'CALC_NVLRISCO_TAXA_NOVO', 'Calcular Nível de Risco (Taxa) 1-Sim 0-Nao ',0);

      IF rw_coop.cdcooper = 11 THEN
        vr_datacorte := TO_DATE('13/11/2022');
      END IF;
      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
      VALUES ('CRED',rw_coop.cdcooper, 'DT_CORTE_MOTOR_LIMITE_PF', 'Data de Corte, para poder diferenciar entre Produto Ibratan e Produto Neurotech. ',vr_datacorte);

      INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
      VALUES ('CRED',rw_coop.cdcooper, 'DT_CORTE_MOTOR_LIMITE_PJ', 'Data de Corte, para poder diferenciar entre Produto Ibratan e Produto Neurotech. ',vr_datacorte);
      vr_datacorte := TO_DATE('31/12/2099');

  END LOOP;

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',0, 'NOVOMOTOR_HOST_WEBSRV' , 'URLs de acesso ao Mulesoft AILOS - Saída Motor de Credito Neurotech','https://integra.ailos.coop.br');
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',0, 'NOVOMOTOR_URI_WEBSRV'  , 'URI de acesso aos Recursos Mulesoft AILOS - Saída Motor de Credito.','eapi-ailosmais-frontoffice/v1/aimaro/enviar');
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',0, 'NOVOMOTOR_URI_WSAYLLOS', 'URI de acesso aos Recursos Mulesoft AILOS - WSAYLLOS.','eapi-ailosmais-frontoffice/v1/aimaro/webservice');
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',0, 'NOVOMOTOR_ID_MULE'     , 'Client ID - Acesso Mulesoft AILOS','ab2aa7ad118e4042b82c27793456db8d');
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',0, 'NOVOMOTOR_SECRET_MULE' , 'Client Secret - Acesso Mulesoft AILOS','3030C3225cEf4FdcbbDCD9A1A2B5eC42');
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',0, 'NOVOMOTOR_DATARAW_MULE', 'Data Raw - Conteudo padrão Motor Mulesoft AILOS ','{"cooperado": {"identificador": #cooperado#},"contaCorrente": {"numero": "#conta#"},"contrato": {"numero": "#proposta#"},"cooperativa": {"codigo": #cdcooper#}}');

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',0, 'NOVOMOTOR_AUTORIZACAO', 'Usuario:Senha para acesso ao serviço Mulesoft AILOS ',1);
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',0, 'NOVOMOTOR_KEY_MULE'   , 'Chave de acesso ao serviço Mulesoft AILOS',1);

  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',0, 'URL_MULE_DWLD_PDF', 'URL para download PDF do Motor de Crédito','/eapi-ailosmais-frontoffice/motorcredito/v1/extrairDocumento');
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) VALUES ('CRED',0, 'SCRIPT_DWLD_PDF_NEURO', 'Script monta cURL Neurotech','curl --location --request GET [request] [header] -k --noproxy "*" --max-time 30 --output [local-name]');

  COMMIT;
END;
