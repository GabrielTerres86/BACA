BEGIN
  UPDATE tbseg_historico_relatorio r
     SET r.dtinicio = TO_DATE('08/01/2022','DD/MM/RRRR')
  WHERE r.idhistorico_relatorio = 3;
  COMMIT;
END;
/  
