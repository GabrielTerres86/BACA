BEGIN
  EXECUTE IMMEDIATE 'ALTER SEQUENCE cecred.tbconv_canalcoop_liberado_seq restart start with 20000';
END;