BEGIN
  UPDATE tbseg_historico_relatorio r
     SET r.dtinicio = TO_DATE('28/01/2022','DD/MM/RRRR')
   WHERE r.cdacesso = 'PROPOSTA_PREST_CONTRIB';
  COMMIT;
END;
/
