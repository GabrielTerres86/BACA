BEGIN
  
  BEGIN
    UPDATE crawcrd
       SET nrcctitg = 7563239589473,
           nrcrcard = 5474080165087592, 
           insitcrd = 3,
           dtentreg = NULL,
           inanuida = 0,
           qtanuida = 0,
           dtlibera = trunc(SYSDATE),
           dtrejeit = NULL
     WHERE cdcooper = 1
       and nrdconta = 11366869
       and nrcpftit = 9669943965;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro na atualização da proposta do CPF 9669943965');
  END;
  
  BEGIN
    UPDATE crawcrd
       SET nrcctitg = 7563239589473,
           nrcrcard = 5474080165087725,
           insitcrd = 3,
           dtentreg = NULL,
           inanuida = 0,
           qtanuida = 0,
           dtlibera = trunc(SYSDATE),
           dtrejeit = NULL
     WHERE cdcooper = 1
       and nrdconta = 11366869
       and nrcpftit = 9650589996;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro na atualização da proposta do CPF 9650589996');
  END;
  
  BEGIN
    INSERT INTO crapcrd
      (cdcooper, -- 01
       nrdconta, -- 02
       nrcrcard, -- 03
       nrcpftit, -- 04
       nmtitcrd, -- 05
       dddebito, -- 06
       cdlimcrd, -- 07
       dtvalida, -- 08
       nrctrcrd, -- 09
       cdmotivo, -- 10
       nrprotoc, -- 11
       cdadmcrd, -- 12
       tpcartao, -- 13
       dtcancel, -- 14
       flgdebit, -- 15
       flgprovi) -- 16
    VALUES
      (1, -- 01
       11366869, -- 02
       5474080165087592, -- 03
       9669943965, -- 04
       'KALYAN BAKR', -- 05
       11, -- 06
       0, -- 07
       NULL, -- 08
       1752103, -- 09
       0, -- 10
       0, -- 11
       15, -- 12
       2, -- 13
       NULL, -- 14
       0, -- 15
       0); -- 16
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro na inserção da proposta 1752103');
  END;
  
  BEGIN
    INSERT INTO crapcrd
      (cdcooper, -- 01
       nrdconta, -- 02
       nrcrcard, -- 03
       nrcpftit, -- 04
       nmtitcrd, -- 05
       dddebito, -- 06
       cdlimcrd, -- 07
       dtvalida, -- 08
       nrctrcrd, -- 09
       cdmotivo, -- 10
       nrprotoc, -- 11
       cdadmcrd, -- 12
       tpcartao, -- 13
       dtcancel, -- 14
       flgdebit, -- 15
       flgprovi) -- 16
    VALUES
      (1, -- 01
       11366869, -- 02
       5474080165087725, -- 03
       9650589996, -- 04
       'JOEL LUCAS SIMSEN', -- 05
       11, -- 06
       0, -- 07
       NULL, -- 08
       1752106, -- 09
       0, -- 10
       0, -- 11
       15, -- 12
       2, -- 13
       NULL, -- 14
       0, -- 15
       0); -- 16
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro na inserção da proposta 1752106');
  END;
  
  BEGIN
    INSERT INTO tbcrd_conta_cartao
      (cdcooper, nrdconta, nrconta_cartao)
    VALUES
      (1, --> cdcooper
       11366869, --> nrdconta
       7563239589473); --> nrconta_cartao
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro na inserção na tabela tbcrd_conta_cartao');
  END;
  
  COMMIT;
  
END;
