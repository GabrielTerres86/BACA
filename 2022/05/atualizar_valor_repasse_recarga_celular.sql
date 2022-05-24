BEGIN
  UPDATE tbrecarga_operacao a
     SET a.vlrepasse = vlrecarga - 1.5
   WHERE a.cdcooper = 16
     AND TRUNC(a.dtrecarga) BETWEEN to_date('09/05/2022', 'DD/MM/YYYY') AND to_date('15/05/2022', 'DD/MM/YYYY')
     AND a.insit_operacao = 2;
     
   COMMIT;
END;
