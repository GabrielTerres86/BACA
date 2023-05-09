BEGIN
  DELETE 
    FROM tbconv_canalcoop_liberado q
   where q.idsequencia > 15000;
  COMMIT;
END;