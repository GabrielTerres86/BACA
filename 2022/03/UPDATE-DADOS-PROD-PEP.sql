BEGIN
    UPDATE crapass
    SET    nmprimtl = 'MARISTELA MATOSO',
           nrcpfcgc = 961685956
    WHERE  crapass.nrdconta = 591718
           AND crapass.cdcooper = 1;

    UPDATE crapttl
    SET    nmextttl = 'MARISTELA MATOSO',
           nrcpfcgc = 961685956
    WHERE  crapttl.nrdconta = 591718
           AND crapttl.cdcooper = 1;

    UPDATE tbcalris_pessoa
    SET    nmpessoa = 'MARISTELA MATOSO',
           nrcpfcgc = 961685956
    WHERE  idcalris_pessoa = 933137
           AND idpessoa = 1075467;

    UPDATE crapass
    SET    nmprimtl = 'IVONE STOLF DELUCA',
           nrcpfcgc = 71092730915
    WHERE  crapass.nrdconta = 624349
           AND crapass.cdcooper = 1;

    UPDATE crapttl
    SET    nmextttl = 'IVONE STOLF DELUCA',
           nrcpfcgc = 71092730915
    WHERE  crapttl.nrdconta = 624349
           AND crapttl.cdcooper = 1;

    UPDATE tbcalris_pessoa
    SET    nmpessoa = 'IVONE STOLF DELUCA',
           nrcpfcgc = 71092730915
    WHERE  idcalris_pessoa = 487803
           AND idpessoa = 95389;

    UPDATE crapass
    SET    nmprimtl = 'CARLOS TAVARES D AMARAL',
           nrcpfcgc = 1005022968
    WHERE  crapass.nrdconta = 165514
           AND crapass.cdcooper = 1;

    UPDATE crapttl
    SET    nmextttl = 'CARLOS TAVARES D AMARAL',
           nrcpfcgc = 1005022968
    WHERE  crapttl.nrdconta = 165514
           AND crapttl.cdcooper = 1;

    UPDATE tbcalris_pessoa
    SET    nmpessoa = 'CARLOS TAVARES D AMARAL',
           nrcpfcgc = 1005022968
    WHERE  idcalris_pessoa = 787118
           AND idpessoa = 1773;

    UPDATE crapass
    SET    nmprimtl = 'EDUARDO SARDAGNA',
           nrcpfcgc = 376518979
    WHERE  crapass.nrdconta = 21237
           AND crapass.cdcooper = 1;

    UPDATE crapttl
    SET    nmextttl = 'EDUARDO SARDAGNA',
           nrcpfcgc = 376518979
    WHERE  crapttl.nrdconta = 21237
           AND crapttl.cdcooper = 1;

    UPDATE tbcalris_pessoa
    SET    nmpessoa = 'EDUARDO SARDAGNA',
           nrcpfcgc = 376518979
    WHERE  idcalris_pessoa = 974971
           AND idpessoa = 189667;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
END; 