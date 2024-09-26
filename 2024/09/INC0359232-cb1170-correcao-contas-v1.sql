DECLARE

  VR_NRCTRCRD CRAWCRD.NRCTRCRD%TYPE := NULL;
  VR_NRSEQCRD CRAWCRD.NRSEQCRD%TYPE := NULL;

BEGIN

  BEGIN
    DELETE TBCRD_CONTA_CARTAO
     WHERE NRCONTA_CARTAO = 7553239005094
       AND NRDCONTA = 7026455;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 0
     WHERE NRCCTITG = 7553239005094
       AND NRDCONTA = 7026455;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 0
     WHERE NRCCTITG = 7563239318698
       AND NRDCONTA = 12721514;
  END;

  BEGIN
    DELETE TBCRD_CONTA_CARTAO
     WHERE NRCONTA_CARTAO = 7563239780051
       AND NRDCONTA = 1024841;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 0
     WHERE NRCCTITG = 7563239780051
       AND NRDCONTA = 1024841;
  END;

  BEGIN
    DELETE TBCRD_CONTA_CARTAO
     WHERE NRCONTA_CARTAO = 7563265041192
       AND NRDCONTA = 542385;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 0
     WHERE NRCCTITG = 7563265041192
       AND NRDCONTA = 542385;
  END;

  BEGIN
    DELETE TBCRD_CONTA_CARTAO
     WHERE NRCONTA_CARTAO = 7563318027591
       AND NRDCONTA = 14399148;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 0
     WHERE NRCCTITG = 7563318027591
       AND NRDCONTA = 14399148;
  END;

  BEGIN
    DELETE TBCRD_LIMITE_ATUALIZA
     WHERE NRCONTA_CARTAO = 7564420023534
       AND NRDCONTA = 716650;
  END;

  BEGIN
    DELETE TBCRD_CONTA_CARTAO
     WHERE NRCONTA_CARTAO = 7564420023534
       AND NRDCONTA = 716650;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 0
     WHERE NRCCTITG = 7564420023534
       AND NRDCONTA = 716650;
  END;

  BEGIN
    DELETE TBCRD_CONTA_CARTAO
     WHERE NRCONTA_CARTAO = 7564420130737
       AND NRDCONTA = 17939380;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 0
     WHERE NRCCTITG = 7564420130737
       AND NRDCONTA = 17939380;
  END;

  BEGIN
    DELETE TBCRD_CONTA_CARTAO
     WHERE NRCONTA_CARTAO = 7564435005440
       AND NRDCONTA = 17984017;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 0
     WHERE NRCCTITG = 7564435005440
       AND NRDCONTA = 17984017;
  END;

  BEGIN
    DELETE TBCRD_LIMITE_ATUALIZA
     WHERE NRCONTA_CARTAO = 7564438002826
       AND NRDCONTA = 199605;
  END;

  BEGIN
    DELETE TBCRD_CONTA_CARTAO
     WHERE NRCONTA_CARTAO = 7564438002826
       AND NRDCONTA = 199605;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 0
     WHERE NRCCTITG = 7564438002826
       AND NRDCONTA = 199605;
  END;

  BEGIN
    DELETE TBCRD_CONTA_CARTAO
     WHERE NRCONTA_CARTAO = 7564438105037
       AND NRDCONTA = 997714;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 0
     WHERE NRCCTITG = 7564438105037
       AND NRDCONTA = 997714;
  END;

  BEGIN
    DELETE TBCRD_CONTA_CARTAO
     WHERE NRCONTA_CARTAO = 7563239238714
       AND NRDCONTA = 8798230;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 0
     WHERE NRCCTITG = 7563239238714
       AND NRDCONTA = 8798230;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 0
     WHERE NRCCTITG = 7563239498641
       AND NRDCONTA = 851477;
  END;

  BEGIN
    DELETE TBCRD_CONTA_CARTAO
     WHERE NRCONTA_CARTAO = 7563239825951
       AND NRDCONTA = 13520911;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 0
     WHERE NRCCTITG = 7563239825951
       AND NRDCONTA = 13520911;
  END;

  BEGIN
    UPDATE TBCRD_CONTA_CARTAO
       SET NRCONTA_CARTAO = 7563239275937
     WHERE NRCONTA_CARTAO = 7563239205547
       AND NRDCONTA = 2822610;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 7563239275937
     WHERE NRCCTITG = 7563239205547
       AND NRDCONTA = 2822610;
  END;

 BEGIN
    DELETE TBCRD_LIMITE_ATUALIZA
     WHERE NRCONTA_CARTAO = 7563239009402
       AND NRDCONTA = 2022648;
  END;


  BEGIN
    DELETE TBCRD_CONTA_CARTAO
     WHERE NRCONTA_CARTAO = 7563239009402
       AND NRDCONTA = 2022648;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 7563239091276
     WHERE NRCCTITG = 7563239009402
       AND NRDCONTA = 2022648;
  END;

  BEGIN
    UPDATE TBCRD_CONTA_CARTAO
       SET NRCONTA_CARTAO = 7563239408074
     WHERE NRCONTA_CARTAO = 7563239398174
       AND NRDCONTA = 7453337;
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 7563239408074
     WHERE CDCOOPER = 1
       AND NRDCONTA = 7453337;
  END;

  BEGIN
    INSERT INTO TBCRD_CONTA_CARTAO
      (CDCOOPER
      ,NRDCONTA
      ,NRCONTA_CARTAO
      ,VLLIMITE_GLOBAL
      ,CDADMCRD)
    VALUES
      (1
      ,9416544
      ,7563239336670
      ,0.000
      ,15);
  END;

  BEGIN
    UPDATE CRAWCRD
       SET NRCCTITG = 7563239336670
     WHERE CDCOOPER = 1
       AND NRDCONTA = 9416544
       AND CDADMCRD = 15;
  END;

  BEGIN
  
    vr_nrctrcrd := fn_sequence('CRAPMAT', 'NRCTRCRD', 2);
    vr_nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(2);
  
    INSERT INTO cecred.crawcrd
      (nrdconta
      ,nrcrcard
      ,nrcctitg
      ,nrcpftit
      ,vllimcrd
      ,flgctitg
      ,dtmvtolt
      ,nmextttl
      ,flgprcrd
      ,tpdpagto
      ,flgdebcc
      ,tpenvcrd
      ,vlsalari
      ,dddebito
      ,cdlimcrd
      ,tpcartao
      ,dtnasccr
      ,nrdoccrd
      ,nmtitcrd
      ,nrctrcrd
      ,cdadmcrd
      ,cdcooper
      ,nrseqcrd
      ,dtpropos
      ,dtsolici
      ,flgdebit
      ,cdgraupr
      ,insitcrd
      ,dtlibera
      ,insitdec)
    VALUES
      (8309230
      ,'5474080247596511'
      ,7563239639377
      ,06141106960
      ,500
      ,3
      ,trunc(SYSDATE)
      ,'FERNANDO GUTZ'
      ,0
      ,1
      ,1
      ,0
      ,0
      ,19
      ,0
      ,2
      ,to_date('18/04/1991', 'dd/mm/yyyy')
      ,'4924979'
      ,'RODRIGO L DE MIRANDA'
      ,vr_nrctrcrd
      ,15
      ,1
      ,vr_nrseqcrd
      ,to_date('21/02/2022', 'dd/mm/rrrr')
      ,to_date('21/02/2022', 'dd/mm/rrrr')
      ,1
      ,5
      ,4
      ,NULL
      ,2);
  
    INSERT INTO cecred.crapcrd
      (cdcooper
      ,nrdconta
      ,nrcrcard
      ,nrcpftit
      ,nmtitcrd
      ,dddebito
      ,cdlimcrd
      ,dtvalida
      ,nrctrcrd
      ,cdmotivo
      ,nrprotoc
      ,cdadmcrd
      ,tpcartao
      ,dtcancel
      ,flgdebit
      ,flgprovi)
    VALUES
      (1
      ,8309230
      ,'5474080247596511'
      ,06141106960
      ,'FERNANDO GUTZ'
      ,19
      ,0
      ,NULL
      ,vr_nrctrcrd
      ,0
      ,0
      ,15
      ,2
      ,NULL
      ,1
      ,0);
  END;

  vr_nrctrcrd := NULL;
  vr_nrseqcrd := NULL;

  BEGIN
  
    vr_nrctrcrd := fn_sequence('CRAPMAT', 'NRCTRCRD', 2);
    vr_nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(2);
  
    INSERT INTO cecred.crawcrd
      (nrdconta
      ,nrcrcard
      ,nrcctitg
      ,nrcpftit
      ,vllimcrd
      ,flgctitg
      ,dtmvtolt
      ,nmextttl
      ,flgprcrd
      ,tpdpagto
      ,flgdebcc
      ,tpenvcrd
      ,vlsalari
      ,dddebito
      ,cdlimcrd
      ,tpcartao
      ,dtnasccr
      ,nrdoccrd
      ,nmtitcrd
      ,nrctrcrd
      ,cdadmcrd
      ,cdcooper
      ,nrseqcrd
      ,dtpropos
      ,dtsolici
      ,flgdebit
      ,cdgraupr
      ,insitcrd
      ,dtlibera
      ,insitdec)
    VALUES
      (10158120
      ,'5474080196630899'
      ,7563239700948
      ,00816027900
      ,20000
      ,3
      ,trunc(SYSDATE)
      ,'ROBERTO ROSA DA SILVA'
      ,0
      ,1
      ,1
      ,0
      ,0
      ,3
      ,0
      ,2
      ,to_date('04/12/1950', 'dd/mm/yyyy')
      ,'3873323'
      ,'ROBERTO ROSA DA SILVA'
      ,vr_nrctrcrd
      ,15
      ,1
      ,vr_nrseqcrd
      ,to_date('31/07/2024', 'dd/mm/rrrr')
      ,to_date('31/07/2024', 'dd/mm/rrrr')
      ,0
      ,5
      ,3
      ,NULL
      ,2);
  
    INSERT INTO cecred.crapcrd
      (cdcooper
      ,nrdconta
      ,nrcrcard
      ,nrcpftit
      ,nmtitcrd
      ,dddebito
      ,cdlimcrd
      ,dtvalida
      ,nrctrcrd
      ,cdmotivo
      ,nrprotoc
      ,cdadmcrd
      ,tpcartao
      ,dtcancel
      ,flgdebit
      ,flgprovi)
    VALUES
      (1
      ,10158120
      ,'5474080196630899'
      ,00816027900
      ,'ROBERTO ROSA DA SILVA'
      ,3
      ,0
      ,NULL
      ,vr_nrctrcrd
      ,0
      ,0
      ,15
      ,2
      ,NULL
      ,0
      ,0);
  END;

  BEGIN
    INSERT INTO TBCRD_CONTA_CARTAO
      (CDCOOPER
      ,NRDCONTA
      ,NRCONTA_CARTAO
      ,VLLIMITE_GLOBAL
      ,CDADMCRD)
    VALUES
      (1
      ,10158120
      ,7563239700948
      ,0.000
      ,15);
  END;

  vr_nrctrcrd := NULL;
  vr_nrseqcrd := NULL;

  BEGIN
  
    vr_nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(2);
  
    INSERT INTO cecred.crawcrd
      (nrdconta
      ,nrcrcard
      ,nrcctitg
      ,nrcpftit
      ,vllimcrd
      ,flgctitg
      ,dtmvtolt
      ,nmextttl
      ,flgprcrd
      ,tpdpagto
      ,flgdebcc
      ,tpenvcrd
      ,vlsalari
      ,dddebito
      ,cdlimcrd
      ,tpcartao
      ,dtnasccr
      ,nrdoccrd
      ,nmtitcrd
      ,nrctrcrd
      ,cdadmcrd
      ,cdcooper
      ,nrseqcrd
      ,dtpropos
      ,dtsolici
      ,flgdebit
      ,cdgraupr
      ,insitcrd
      ,dtlibera
      ,insitdec)
    VALUES
      (3519287
      ,'5127070145603148'
      ,7563239128381
      ,41858328934
      ,0
      ,3
      ,TO_DATE('17/08/2018', 'DD/MM/YYYY')
      ,'ALTAIR MORA'
      ,1
      ,1
      ,0
      ,0
      ,0
      ,11
      ,0
      ,2
      ,to_date('01/07/1960', 'dd/mm/yyyy')
      ,'10433422'
      ,'ALTAIR MORA'
      ,1204246
      ,12
      ,1
      ,vr_nrseqcrd
      ,to_date('09/07/2018', 'dd/mm/rrrr')
      ,to_date('09/07/2018', 'dd/mm/rrrr')
      ,0
      ,5
      ,6
      ,NULL
      ,2);
  END;

  vr_nrctrcrd := NULL;
  vr_nrseqcrd := NULL;

  BEGIN
  
    vr_nrctrcrd := fn_sequence('CRAPMAT', 'NRCTRCRD', 2);
    vr_nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(2);
  
    INSERT INTO cecred.crawcrd
      (nrdconta
      ,nrcrcard
      ,nrcctitg
      ,nrcpftit
      ,vllimcrd
      ,flgctitg
      ,dtmvtolt
      ,nmextttl
      ,flgprcrd
      ,tpdpagto
      ,flgdebcc
      ,tpenvcrd
      ,vlsalari
      ,dddebito
      ,cdlimcrd
      ,tpcartao
      ,dtnasccr
      ,nrdoccrd
      ,nmtitcrd
      ,nrctrcrd
      ,cdadmcrd
      ,cdcooper
      ,nrseqcrd
      ,dtpropos
      ,dtsolici
      ,flgdebit
      ,cdgraupr
      ,insitcrd
      ,dtlibera
      ,insitdec)
    VALUES
      (9294015
      ,'6042034007504075'
      ,7563239316729
      ,50735640904
      ,0
      ,3
      ,TO_DATE('29/08/2017', 'DD/MM/YYYY')
      ,'MARCIA A PACHECO'
      ,0
      ,1
      ,1
      ,1
      ,0
      ,11
      ,1
      ,2
      ,to_date('16/03/1965', 'dd/mm/yyyy')
      ,'1462680'
      ,'MARCIA A PACHECO'
      ,vr_nrctrcrd
      ,12
      ,1
      ,vr_nrseqcrd
      ,TO_DATE('29/08/2017', 'DD/MM/YYYY')
      ,TO_DATE('29/08/2017', 'DD/MM/YYYY')
      ,1
      ,5
      ,6
      ,NULL
      ,2);
  END;

  vr_nrctrcrd := NULL;
  vr_nrseqcrd := NULL;

  BEGIN
  
    vr_nrctrcrd := fn_sequence('CRAPMAT', 'NRCTRCRD', 2);
    vr_nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(2);
  
    INSERT INTO cecred.crawcrd
      (nrdconta
      ,nrcrcard
      ,nrcctitg
      ,nrcpftit
      ,vllimcrd
      ,flgctitg
      ,dtmvtolt
      ,nmextttl
      ,flgprcrd
      ,tpdpagto
      ,flgdebcc
      ,tpenvcrd
      ,vlsalari
      ,dddebito
      ,cdlimcrd
      ,tpcartao
      ,dtnasccr
      ,nrdoccrd
      ,nmtitcrd
      ,nrctrcrd
      ,cdadmcrd
      ,cdcooper
      ,nrseqcrd
      ,dtpropos
      ,dtsolici
      ,flgdebit
      ,cdgraupr
      ,insitcrd
      ,dtlibera
      ,insitdec)
    VALUES
      (8519188
      ,'5474080312149394'
      ,7563239321949
      ,02512589986
      ,5000
      ,3
      ,to_date('09/06/2023', 'dd/mm/rrrr')
      ,'FERNANDO G SILVA ME'
      ,0
      ,1
      ,1
      ,0
      ,0
      ,11
      ,29
      ,2
      ,to_date('26/03/1978', 'dd/mm/yyyy')
      ,'33026203'
      ,'FERNANDO GERMANO DA SILVA'
      ,vr_nrctrcrd
      ,15
      ,1
      ,vr_nrseqcrd
      ,to_date('09/06/2023', 'dd/mm/rrrr')
      ,to_date('09/06/2023', 'dd/mm/rrrr')
      ,0
      ,5
      ,4
      ,NULL
      ,2);
  
    INSERT INTO cecred.crapcrd
      (cdcooper
      ,nrdconta
      ,nrcrcard
      ,nrcpftit
      ,nmtitcrd
      ,dddebito
      ,cdlimcrd
      ,dtvalida
      ,nrctrcrd
      ,cdmotivo
      ,nrprotoc
      ,cdadmcrd
      ,tpcartao
      ,dtcancel
      ,flgdebit
      ,flgprovi)
    VALUES
      (1
      ,8519188
      ,'5474080312149394'
      ,02512589986
      ,'FERNANDO G SILVA ME'
      ,11
      ,29
      ,NULL
      ,vr_nrctrcrd
      ,0
      ,0
      ,15
      ,2
      ,NULL
      ,0
      ,0);
  END;

  BEGIN
    INSERT INTO TBCRD_CONTA_CARTAO
      (CDCOOPER
      ,NRDCONTA
      ,NRCONTA_CARTAO
      ,VLLIMITE_GLOBAL
      ,CDADMCRD)
    VALUES
      (1
      ,8519188
      ,7563239321949
      ,0.000
      ,15);
  END;

  vr_nrctrcrd := NULL;
  vr_nrseqcrd := NULL;

  BEGIN
  
    vr_nrctrcrd := fn_sequence('CRAPMAT', 'NRCTRCRD', 2);
    vr_nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(2);
  
    INSERT INTO cecred.crawcrd
      (nrdconta
      ,nrcrcard
      ,nrcctitg
      ,nrcpftit
      ,vllimcrd
      ,flgctitg
      ,dtmvtolt
      ,nmextttl
      ,flgprcrd
      ,tpdpagto
      ,flgdebcc
      ,tpenvcrd
      ,vlsalari
      ,dddebito
      ,cdlimcrd
      ,tpcartao
      ,dtnasccr
      ,nrdoccrd
      ,nmtitcrd
      ,nrctrcrd
      ,cdadmcrd
      ,cdcooper
      ,nrseqcrd
      ,dtpropos
      ,dtsolici
      ,flgdebit
      ,cdgraupr
      ,insitcrd
      ,dtlibera
      ,insitdec)
    VALUES
      (456292
      ,'5474080350208664'
      ,7564444048412
      ,09606051935
      ,0
      ,3
      ,to_date('23/02/2024', 'dd/mm/rrrr')
      ,'ISRAEL MENDES'
      ,0
      ,1
      ,1
      ,0
      ,0
      ,11
      ,0
      ,2
      ,to_date('23/02/1993', 'dd/mm/yyyy')
      ,'05276434382'
      ,'ISRAEL DE O MENDES'
      ,vr_nrctrcrd
      ,15
      ,9
      ,vr_nrseqcrd
      ,to_date('23/02/2024', 'dd/mm/rrrr')
      ,to_date('23/02/2024', 'dd/mm/rrrr')
      ,0
      ,5
      ,6
      ,NULL
      ,2);
  
    INSERT INTO cecred.crapcrd
      (cdcooper
      ,nrdconta
      ,nrcrcard
      ,nrcpftit
      ,nmtitcrd
      ,dddebito
      ,cdlimcrd
      ,dtvalida
      ,nrctrcrd
      ,cdmotivo
      ,nrprotoc
      ,cdadmcrd
      ,tpcartao
      ,dtcancel
      ,flgdebit
      ,flgprovi)
    VALUES
      (9
      ,456292
      ,'5474080350208664'
      ,09606051935
      ,'ISRAEL MENDES'
      ,11
      ,0
      ,NULL
      ,vr_nrctrcrd
      ,0
      ,0
      ,15
      ,2
      ,NULL
      ,0
      ,0);
  END;

  BEGIN
    INSERT INTO TBCRD_CONTA_CARTAO
      (CDCOOPER
      ,NRDCONTA
      ,NRCONTA_CARTAO
      ,VLLIMITE_GLOBAL
      ,CDADMCRD)
    VALUES
      (9
      ,456292
      ,7564444048412
      ,0.000
      ,15);
  END;

  vr_nrctrcrd := NULL;
  vr_nrseqcrd := NULL;

  COMMIT;


END;
/
