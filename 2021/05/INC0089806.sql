declare

  pr_retxml   xmltype;
  pr_retclob  clob;
  vr_nmdcampo VARCHAR2(1000);
  vr_des_erro VARCHAR2(2000);
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);

begin
  BEGIN
  
    UPDATE TBCRD_ARQUIVO
       SET DTINICIO_PROCESSO = NULL,
           DTFIM_PROCESSO    = NULL,
           INSTATUS          = 1,
           INEMAIL           = 0
     WHERE IDARQUIVO = 1;
  
    UPDATE TBCRD_LINHA_ARQUIVO
       SET DTPROCESSO = NULL, DSINFORMACAO = NULL, DSERRO = NULL
     WHERE IDARQUIVO = 1;
  
    UPDATE TBCRD_LINHA_ARQUIVO_ITEM
       SET DSFUNC_CONV = 'to_date(%VALOR%, ''DDMMRRRR'')'
     WHERE NMCAMPO LIKE 'DT%'
       AND DSFUNC_CONV IS NULL;
    
    UPDATE TBCRD_LAYOUT_ARQUIVO_ITEM
       SET DSFUNC_CONV = 'to_date(%VALOR%, ''DDMMRRRR'')'
     WHERE IDLAYOUT = 1
       AND NMCAMPO IN ('DTARQUIVO','DTDONASC','DTOPERACAO','DTOPERACAO','DTVENCIMENTO_CONTRATO');
  
    COMMIT;
  END;

  pr_retclob := '<?xml version="1.0" encoding="ISO-8859-1" ?><Root> <Dados> </Dados><params><nmprogra>CCR3</nmprogra>' ||
                '<nmeacao>CRPS672</nmeacao><cdcooper>3</cdcooper><cdagenci>0</cdagenci><nrdcaixa>0</nrdcaixa><idorigem>1</idorigem>' ||
                '<cdoperad>1</cdoperad></params></Root>';

  pr_retxml := XMLType.createXML(pr_retclob);

  cartao.CRD_CRPS672.processarRegistros(pr_xmllog   => '',
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic,
                                        pr_retxml   => pr_retxml,
                                        pr_nmdcampo => vr_nmdcampo,
                                        pr_des_erro => vr_des_erro);

  COMMIT;

end;
