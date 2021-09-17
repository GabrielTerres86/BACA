BEGIN
  UPDATE tbgen_iof_taxa tit SET tit.vltaxa_iof = 0.00011180 WHERE tit.tpiof = 2;
  UPDATE tbgen_iof_taxa tit SET tit.vltaxa_iof = 0.00005590 WHERE tit.tpiof = 3;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
