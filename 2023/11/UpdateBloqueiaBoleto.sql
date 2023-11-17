BEGIN

  UPDATE crapcob
     SET crapcob.dtbloque = trunc(SYSDATE)
        ,crapcob.dtsitcrt = trunc(SYSDATE)
   WHERE (nrdconta, nrdocmto) IN ((97693154, 50040), (97693154, 50035)) COMMIT;

END;
