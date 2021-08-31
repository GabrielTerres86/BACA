BEGIN
 UPDATE crapcrd
    SET crapcrd.cdcooper = 1
    ,crapcrd.nrdconta = 80107052
    ,crapcrd.nrcpftit = 00620541989
    ,cdadmcrd = 15
    WHERE crapcrd.nrcrcard = 5161620000264183;

    UPDATE crawcrd
    SET crawcrd.cdcooper = 1
    ,crawcrd.nrdconta = 80107052
    ,crawcrd.nrcpftit = 00620541989
    ,cdadmcrd = 15
    WHERE crawcrd.nrcrcard = 5161620000264183;

    COMMIT;
END;