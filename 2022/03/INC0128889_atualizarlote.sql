BEGIN
    update craphpt hpt set dtmvtolt = to_date('13/02/2022', 'dd/mm/yyyy')   WHERE hpt.cdcooper = 1  AND hpt.nrdconta = 830968 and nrremret = 254;
    COMMIT;
END; 