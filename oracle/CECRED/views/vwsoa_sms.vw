CREATE OR REPLACE VIEW CECRED.VWSOA_SMS AS
     SELECT TBGEN_SMS_CONTROLE.IDLOTE_SMS
           ,TBGEN_SMS_CONTROLE.IDSMS
           ,TBGEN_SMS_CONTROLE.NRDDD
           ,TBGEN_SMS_CONTROLE.NRTELEFONE
           ,TBGEN_SMS_CONTROLE.DSMENSAGEM
           ,CASE WHEN TBCOBRAN_SMS_CONTRATO.tpnome_emissao = 3 THEN SUBSTR(TBCOBRAN_SMS_CONTRATO.nmemissao_sms,1,15)
                 WHEN TBCOBRAN_SMS_CONTRATO.tpnome_emissao = 1 THEN SUBSTR(crapass.nmprimtl,1,15)
                 WHEN TBCOBRAN_SMS_CONTRATO.tpnome_emissao = 2 THEN SUBSTR(crapjur.nmfansia,1,15)
            END AS remetente
FROM TBCOBRAN_SMS_CONTRATO
JOIN TBGEN_SMS_CONTROLE
         ON TBGEN_SMS_CONTROLE.cdcooper = TBCOBRAN_SMS_CONTRATO.cdcooper
        AND TBGEN_SMS_CONTROLE.nrdconta = TBCOBRAN_SMS_CONTRATO.nrdconta
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
      WHERE tbcobran_sms_contrato.dhcancela IS NULL
UNION
     SELECT TBGEN_SMS_CONTROLE.IDLOTE_SMS
           ,TBGEN_SMS_CONTROLE.IDSMS
           ,TBGEN_SMS_CONTROLE.NRDDD
           ,TBGEN_SMS_CONTROLE.NRTELEFONE
           ,TBGEN_SMS_CONTROLE.DSMENSAGEM
           ,TBGEN_SMS_LOTE.DSAGRUPADOR AS REMETENTE
       FROM TBGEN_SMS_CONTROLE
       JOIN TBGEN_SMS_LOTE
         ON TBGEN_SMS_LOTE.IDLOTE_SMS = TBGEN_SMS_CONTROLE.IDLOTE_SMS
      WHERE TBGEN_SMS_LOTE.CDPRODUTO <> 19           /* Nao considerar sms cobranca */
        AND TBGEN_SMS_LOTE.IDTPREME  <> 'SMSCOBRAN'  /* Nao considerar sms cobranca */
        AND TBGEN_SMS_LOTE.IDSITUACAO = 'A'          /* Aberto */
