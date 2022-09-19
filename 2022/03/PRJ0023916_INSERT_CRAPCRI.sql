DECLARE
  vr_code NUMBER;
  vr_errm VARCHAR2(4000);
  vr_cdcritic cecred.crapcri.cdcritic%type;
  vr_dscritic cecred.crapcri.dscritic%type;
BEGIN
  
  vr_cdcritic := 10604;
  vr_dscritic := vr_cdcritic || ' - Tipo da Solicitação de Bloqueio incorreto';
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (vr_cdcritic,
     vr_dscritic,
     1,
     0);
  
  vr_cdcritic := 10605;
  vr_dscritic := vr_cdcritic || ' - Relação do Tipo da Solicitação de Bloqueio e Tipo de Pessoa inválido';  
  INSERT INTO CECRED.CRAPCRI
    (CDCRITIC,
    DSCRITIC,
    TPCRITIC,
    FLGCHAMA)
  VALUES
    (vr_cdcritic,
     vr_dscritic,
     1,
     0);    
    
    
    COMMIT;    
    
EXCEPTION
 WHEN OTHERS THEN
    vr_code := sqlcode;
    vr_errm := sqlerrm;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro ao inserir codigo de critica '|| vr_cdcritic || ' - ' || vr_code || ' / ' || vr_errm);
END;    
