BEGIN

  EXECUTE IMMEDIATE 'TRUNCATE TABLE gestaoderisco.htrisco_central_retorno';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE gestaoderisco.tbrisco_crapris';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE gestaoderisco.tbrisco_crapvri';
  COMMIT;

END;
