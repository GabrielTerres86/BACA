CREATE OR REPLACE VIEW CECRED.VWSOA_SMS AS

SELECT TBGEN_SMS_CONTROLE.IDLOTE_SMS, TBGEN_SMS_CONTROLE.IDSMS, TBGEN_SMS_CONTROLE.NRDDD, TBGEN_SMS_CONTROLE.NRTELEFONE, TBGEN_SMS_CONTROLE.DSMENSAGEM,

            CASE WHEN tbcobran_config_boleto.tpnome_emissao = 0 THEN SUBSTR(tbcobran_config_boleto.nmemissao_sms,1,15)
                 WHEN tbcobran_config_boleto.tpnome_emissao = 1 THEN SUBSTR(crapass.nmprimtl,1,15)
                 WHEN tbcobran_config_boleto.tpnome_emissao = 2 THEN SUBSTR(crapjur.nmfansia,1,15)
            END AS remetente          



       FROM tbcobran_config_boleto
       JOIN tbcobran_sms_contrato

         ON tbcobran_sms_contrato.cdcooper = tbcobran_config_boleto.cdcooper 
        AND tbcobran_sms_contrato.nrdconta = tbcobran_config_boleto.nrdconta 
        AND tbcobran_sms_contrato.dhcancela is null


JOIN TBGEN_SMS_CONTROLE

         ON TBGEN_SMS_CONTROLE.cdcooper = tbcobran_config_boleto.cdcooper 
        AND TBGEN_SMS_CONTROLE.nrdconta = tbcobran_config_boleto.nrdconta  


JOIN TBGEN_SMS_LOTE

         ON TBGEN_SMS_LOTE.cdproduto = 19 
 	AND TBGEN_SMS_LOTE.IDSITUACAO = 'A'
	AND TBGEN_SMS_LOTE.IDTPREME = 'SMSCOBRAN'
        AND TBGEN_SMS_LOTE.IDLOTE_SMS = TBGEN_SMS_CONTROLE.IDLOTE_SMS


       JOIN crapass
         ON crapass.cdcooper = tbcobran_sms_contrato.cdcooper
        AND crapass.nrdconta = tbcobran_sms_contrato.nrdconta

  LEFT JOIN crapjur
         ON crapjur.cdcooper = crapass.cdcooper
        AND crapjur.nrdconta = crapass.nrdconta
