BEGIN
  FOR rw_crapcop IN (SELECT p.cdcooper
                       FROM CECRED.crapcop p
                      WHERE p.cdcooper <> 3
                        AND p.flgativo = 1) LOOP
    INSERT INTO CECRED.crapprm(nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
      VALUES('CRED',rw_crapcop.cdcooper,'PROPOSTA_API_ICATU_QNTD','Quantidade de n�mero de proposta dispon�vel at� a pr�xima carga',15);
  END LOOP;
  COMMIT;
END;
/
