BEGIN
 UPDATE crapcrd
    SET crapcrd.cdcooper = 1
    ,crapcrd.nrdconta = 191
    ,crapcrd.nrcpftit = 00407195963
    ,cdadmcrd = 15
    WHERE crapcrd.nrcrcard = 5161620000264183;

    UPDATE crawcrd
    SET crawcrd.cdcooper = 1
    ,crawcrd.nrdconta = 191
    ,crawcrd.nrcpftit = 00407195963
    ,cdadmcrd = 15
    WHERE crawcrd.nrcrcard = 5161620000264183;

    COMMIT;
END;