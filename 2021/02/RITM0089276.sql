DECLARE

  VR_IDOPERACAO_ADM  tbcrd_operacao_adm.idoperacao_adm%TYPE;

BEGIN
  BEGIN
    UPDATE TBCRD_LAYOUT_ARQUIVO_ITEM
       SET DSFUNC_CONV = 'to_date(%VALOR%, ''DDMMRRRR'')'
     WHERE IDLAYOUT = 1
       AND NMCAMPO IN ('DTARQUIVO','DTDONASC','DTOPERACAO','DTOPERACAO','DTVENCIMENTO_CONTRATO');
  END;
  
  BEGIN
    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 0, 'ERRO - TIPO DE SOLICITA��O EM BRANCO', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 1, 'INCLUS�O DE CART�O', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 2, 'MODIFICA��O DE CONTA CART�O', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 3, 'CANCELAMENTO DE CART�O', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 4, 'INCLUS�O DE CART�O ADICIONAL/REPOSI��O DE CART�O', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 5, 'MODIFICA��O DE CART�O', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 6, 'MODIFICA��O DE DOCUMENTO', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 7, 'REATIVA��O DE CART�O', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 8, 'REIMPRESS�O DE PIN', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 9, 'BAIXA DE PARCELADOS', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 10, 'DESBLOQUEIO DE CART�O', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 11, 'ENTREGA DE CART�O', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 12, 'TROCA DE ESTADO DE CART�O', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 13, 'ALTERA��O DE CONTA CART�O', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 14, 'CAD. DEB. AUTOMATICO', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 16, 'BAIXA DE PARCELAS', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 25, 'REATIVAR CART�O DO ADICIONAL', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 50, 'MODIFICA��O DE PIN', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 99, 'EXCLUS�O DE CART�O', 1);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 48, null, 1);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 59, null, 1);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 1, 'INCLUS�O DE CART�O', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 3, 'CANCELAMENTO DE CART�O', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 4, 'INCLUS�O DE CART�O ADICIONAL/REPOSI��O DE CART�O', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 5, 'MODIFICA��O DE CART�O', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 7, 'REATIVA��O DE CART�O', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 10, 'DESBLOQUEIO DE CART�O', null)
    returning IDOPERACAO_ADM into VR_IDOPERACAO_ADM;

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 12, 'TROCA DE ESTADO DE CART�O', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 13, 'ALTERA��O DE CONTA CART�O', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 25, 'REATIVAR CART�O DO ADICIONAL', 3);
    
    insert into tbcrd_operacao_adm_situacao (IDOPERACAO_ADM, CDSITUACAO_ADM, CDSITUACAO_CARTAO, CDMOTIVO_CANCELAMENTO)
    values (VR_IDOPERACAO_ADM, 10, 6, 10);

    insert into tbcrd_operacao_adm_situacao (IDOPERACAO_ADM, CDSITUACAO_ADM, CDSITUACAO_CARTAO, CDMOTIVO_CANCELAMENTO)
    values (VR_IDOPERACAO_ADM, 16, 5, 16);

    insert into tbcrd_operacao_adm_situacao (IDOPERACAO_ADM, CDSITUACAO_ADM, CDSITUACAO_CARTAO, CDMOTIVO_CANCELAMENTO)
    values (VR_IDOPERACAO_ADM, 26, 6, 10);

    insert into tbcrd_operacao_adm_situacao (IDOPERACAO_ADM, CDSITUACAO_ADM, CDSITUACAO_CARTAO, CDMOTIVO_CANCELAMENTO)
    values (VR_IDOPERACAO_ADM, 1, 4, 0);
  END;
  
  COMMIT;
  
END;
