BEGIN
 UPDATE CECRED.CRAPTAR T SET T.FLUTLPCT = 1  
  WHERE T.CDTARIFA = 422;
 COMMIT;
END;