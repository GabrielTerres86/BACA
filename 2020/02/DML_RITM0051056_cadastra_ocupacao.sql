--RITM0051056
--Ana Volles - 09/03/2020

--SELECT * FROM GNCDNTO;
--SELECT * FROM GNCDOCP A WHERE A.CDNATOCP = 11;
--SELECT nvl(MAX(cdocupa),0)+1 FROM GNCDOCP;

DECLARE
  vr_cdocupa     GNCDOCP.CDOCUPA%TYPE;
BEGIN
  SELECT nvl(MAX(cdocupa),0)+1 INTO vr_cdocupa FROM GNCDOCP;
  
  dbms_output.put_line ('vr_cdocupa :'||vr_cdocupa);

  INSERT INTO GNCDOCP (cdocupa
                      ,cdnatocp
                      ,dsdocupa
                      ,rsdocupa)
               VALUES(vr_cdocupa
                     ,11
                     ,upper('SEM REMUNERACAO')
                     ,upper('SEM REMUNERACAO'));


  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line ('Erro ao cadastrar:'||SQLCODE||'-'||SQLERRM);

      ROLLBACK;
END;



