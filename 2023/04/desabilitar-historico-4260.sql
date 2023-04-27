BEGIN
  DELETE from craphis where cdhistor in(4260);
  DELETE from crapthi where cdhistor=4260  ;
  COMMIT;
END;