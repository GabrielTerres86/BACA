BEGIN
  UPDATE CECRED.tbcapt_custodia_lanctos a
     SET a.idsituacao = 8
   WHERE a.idlancamento IN (44147661,51592463);
   
   COMMIT;
END;
