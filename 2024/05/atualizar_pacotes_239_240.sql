BEGIN
  UPDATE CECRED.TBTARIF_PACOTES T SET T.DTMVTOLT = To_Date('10/05/2024 09:00:12','DD/MM/YYYY HH24:MI:SS') WHERE T.CDPACOTE IN (239,240);
  UPDATE CECRED.CRAPFCO T SET T.FLGVIGEN = 1 WHERE T.CDFAIXAV IN (740,741);
  COMMIT;
END;