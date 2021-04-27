DECLARE
 
  CURSOR cr_cdcooper is 
  select cdcooper 
  from   CRAPCOP
  where  flgativo = 1
  AND  cdcooper <> 3;
  
  rg_cdcooper cr_cdcooper%rowtype;
  
BEGIN

  OPEN cr_cdcooper;
  LOOP
    FETCH cr_cdcooper INTO rg_cdcooper;
    EXIT WHEN cr_cdcooper%NOTFOUND;

    insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values 
              							('CRED', rg_cdcooper.cdcooper, 'CRD_VISA_LIMITE_CONTING', 'Limite sugerido para o Cartão Visa em caso de contingência do Motor', '500');

  END LOOP;
  CLOSE cr_cdcooper;
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
END;