BEGIN
    DELETE FROM cecred.CRAPEBN WHERE CDCOOPER = 9 AND NRDCONTA = 544825 AND NRCTREMP = 59949;
    DELETE FROM cecred.CRAPEBN WHERE CDCOOPER = 9 AND NRDCONTA = 405132 AND NRCTREMP = 405132;

    COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20500, SQLERRM);
END;