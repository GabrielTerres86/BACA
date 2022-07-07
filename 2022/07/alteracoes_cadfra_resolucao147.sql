DECLARE

BEGIN

  BEGIN
    DELETE FROM cecred.crapprm
     WHERE cdacesso IN ('ANALISE_DICT_BLQ_CAUT'
                       ,'VLCORTE_DICT_BLQ_CAUT'
                       ,'HRDESAB_DICT_BLQ_CAUT')
       AND nmsistem = 'CRED'
       AND cdcooper = 0;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  BEGIN
    DELETE FROM cecred.crapaca
     WHERE nmdeacao = 'CADFRA_BUSCA_PARAM_BLQ_CAUTELAR'
       AND nmpackag = 'TELA_CADFRA'
       AND nmproced = 'pc_busca_parametros_bloqueio_cautelar';
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  BEGIN
    DELETE FROM cecred.crapaca
     WHERE nmdeacao = 'CADFRA_GRAVA_PARAM_BLQ_CAUTELAR'
       AND nmpackag = 'TELA_CADFRA'
       AND nmproced = 'pc_grava_parametros_bloqueio_cautelar';
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  BEGIN
    INSERT INTO cecred.crapprm
      (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES
      ('CRED'
      ,0
      ,'ANALISE_DICT_BLQ_CAUT'
      ,'Valor que permite a desativação da análise de PIX no recebimento.'
      ,'0');
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  BEGIN
    INSERT INTO cecred.crapprm
      (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES
      ('CRED'
      ,0
      ,'VLCORTE_DICT_BLQ_CAUT'
      ,'Valor de corte das transações para determinar a DICT deve ser consultada ou não no bloqueio cautelar.'
      ,'30,00');
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  BEGIN
    INSERT INTO cecred.crapprm
      (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES
      ('CRED'
      ,0
      ,'HRDESAB_DICT_BLQ_CAUT'
      ,'Quantidade de horas após a ultima atualização que determinará se o registro com informações da DICT estará desatualizado.'
      ,'2');
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  BEGIN
    INSERT INTO cecred.crapaca
      (nmdeacao, nmpackag, nmproced, nrseqrdr)
    VALUES
      ('CADFRA_BUSCA_PARAM_BLQ_CAUTELAR'
      ,'TELA_CADFRA'
      ,'pc_busca_parametros_bloqueio_cautelar'
      ,704);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  BEGIN
    INSERT INTO cecred.crapaca
      (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
      ('CADFRA_GRAVA_PARAM_BLQ_CAUTELAR'
      ,'TELA_CADFRA'
      ,'pc_grava_parametros_bloqueio_cautelar'
      ,'pr_vlcortedict,pr_hrdesabilitado,pr_analise'
      ,704);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  BEGIN
    UPDATE cecred.craptel
       SET cdopptel = 'C,A,E,B,G'
          ,lsopptel = 'CONSULTAR,ALTERAR,EXCLUIR,BLOQUEAR,CAUTELAR'
     WHERE nmdatela = 'CADFRA';
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  COMMIT;

END;
/
