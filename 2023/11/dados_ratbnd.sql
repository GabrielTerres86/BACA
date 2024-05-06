BEGIN
    UPDATE crapebn SET nrctremp = 4200939 WHERE cdcooper = 9 and nrdconta = 99819040 and nrctremp = 18089011;
    COMMIT;
EXCEPTION
WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20500, 'Erro não tratado: ' || SQLERRM);
END;