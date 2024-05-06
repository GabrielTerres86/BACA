BEGIN
  INSERT INTO cecred.tbconsor_situacao
    (cdsituacao, nmsituacao, cdclassificacao)
  VALUES
    ('PCS', 'Inadimplente', 2);
  COMMIT;
END;
/
