/*
6 linhas de lançamentos futuros
tempo: menor de 1 segundo
*/
BEGIN
  DELETE FROM craplcm l WHERE l.cdcooper = 9 AND l.nrdconta = 502367 AND l.progress_recid IN (1185283401,1185283402,1185283404,1185283405,1185283406,1185283408);
  COMMIT;
END;
