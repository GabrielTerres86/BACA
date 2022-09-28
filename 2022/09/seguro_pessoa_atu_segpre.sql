BEGIN
  UPDATE tbseg_prestamista p
     SET p.nrproposta = '770628743487'
   WHERE p.idseqtra = 641381;
   
 UPDATE crawseg w
    SET w.nrproposta = '770628743487'
  WHERE w.progress_recid = 3135326;

  UPDATE tbseg_prestamista p
     SET p.nrproposta = '770628743444'
   WHERE p.idseqtra = 641379;
   
  UPDATE crawseg w
     SET w.nrproposta = '770628743444'
   WHERE w.progress_recid = 3135322;
  COMMIT;
END;
/
