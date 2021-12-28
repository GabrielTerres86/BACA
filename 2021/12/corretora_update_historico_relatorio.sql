BEGIN
  UPDATE tbseg_historico_relatorio r
     SET r.dtinicio = TO_DATE('28/11/2021')
   WHERE r.idhistorico_relatorio = 3;
 COMMIT;
END;
/
