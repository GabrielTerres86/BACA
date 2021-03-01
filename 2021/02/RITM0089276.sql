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
    values (null, 1, 0, 'ERRO - TIPO DE SOLICITAÇÃO EM BRANCO', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 1, 'INCLUSÃO DE CARTÃO', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 2, 'MODIFICAÇÃO DE CONTA CARTÃO', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 3, 'CANCELAMENTO DE CARTÃO', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 4, 'INCLUSÃO DE CARTÃO ADICIONAL/REPOSIÇÃO DE CARTÃO', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 5, 'MODIFICAÇÃO DE CARTÃO', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 6, 'MODIFICAÇÃO DE DOCUMENTO', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 7, 'REATIVAÇÃO DE CARTÃO', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 8, 'REIMPRESSÃO DE PIN', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 9, 'BAIXA DE PARCELADOS', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 10, 'DESBLOQUEIO DE CARTÃO', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 11, 'ENTREGA DE CARTÃO', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 12, 'TROCA DE ESTADO DE CARTÃO', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 13, 'ALTERAÇÃO DE CONTA CARTÃO', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 14, 'CAD. DEB. AUTOMATICO', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 16, 'BAIXA DE PARCELAS', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 25, 'REATIVAR CARTÃO DO ADICIONAL', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 50, 'MODIFICAÇÃO DE PIN', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 99, 'EXCLUSÃO DE CARTÃO', 1);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 48, null, 1);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 1, 59, null, 1);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 1, 'INCLUSÃO DE CARTÃO', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 3, 'CANCELAMENTO DE CARTÃO', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 4, 'INCLUSÃO DE CARTÃO ADICIONAL/REPOSIÇÃO DE CARTÃO', null);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 5, 'MODIFICAÇÃO DE CARTÃO', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 7, 'REATIVAÇÃO DE CARTÃO', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 10, 'DESBLOQUEIO DE CARTÃO', null)
    returning IDOPERACAO_ADM into VR_IDOPERACAO_ADM;

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 12, 'TROCA DE ESTADO DE CARTÃO', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 13, 'ALTERAÇÃO DE CONTA CARTÃO', 3);

    insert into tbcrd_operacao_adm (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
    values (null, 2, 25, 'REATIVAR CARTÃO DO ADICIONAL', 3);
    
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
