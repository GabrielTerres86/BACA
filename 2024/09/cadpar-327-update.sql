BEGIN

  update cecred.crappat set cdpartar = 327 where cdpartar = 347;

  update cecred.crappco set cdpartar = 327 where cdpartar = 347;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
