BEGIN
  DELETE FROM tbepr_segmento_canais_perm t WHERE t.tpemprst = 2;
  COMMIT;
END;
