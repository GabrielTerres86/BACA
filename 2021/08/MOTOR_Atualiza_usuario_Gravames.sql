BEGIN
  UPDATE crapcop t
   SET t.cdloggrv = '0001TVDC'
     , t.cdfingrv = 4405
     , t.cdsubgrv = 001
 WHERE t.cdcooper <> 3
   AND t.flgativo = 1;

   COMMIT;

END;
