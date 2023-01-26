BEGIN

  declare

  vr_nrctrcrd crawcrd.nrctrcrd%TYPE;
  vr_nrseqcrd crawcrd.nrseqcrd%TYPE;

  begin

  DELETE FROM CECRED.CRAWCRD
  WHERE CDCOOPER = 1
  AND NRDCONTA = 15438511
  AND NRCTRCRD IN (2876836, 2906870);
  
  COMMIT;
  
  UPDATE CECRED.CRAWCRD SET
  nrcrcard = 5474080273143204,
  dtsolici = to_date('14/09/2022','dd/mm/rrrr'),  
  insitcrd = 4,
  dtpropos = to_date('13/09/2022','dd/mm/rrrr'),  
  dtmvtolt = to_date('22/09/2022','dd/mm/rrrr'), 
  dtlibera = to_date('23/09/2022','dd/mm/rrrr'),  
  dtrejeit = null  
  WHERE CDCOOPER = 1
  AND NRDCONTA = 15438511
  AND NRCTRCRD = 2863386;
  
   insert into cecred.crapcrd
    (cdcooper,
    nrdconta,
    nrcrcard,
    nrcpftit,
    nmtitcrd,
    dddebito,
    cdlimcrd,
    dtvalida,
    nrctrcrd,
    cdmotivo,
    nrprotoc,
    cdadmcrd,
    tpcartao,
    dtcancel,
    flgdebit,
    flgprovi)
  values  (1,     
    15438511,       
    '5474080273143204',  
    434835935,    
    'RODRIGO A PEREIRA ', 
    11,      
    0,     
    NULL,    
    2863386,   
    0,  
    0,       
    15,     
    2,     
    NULL,  
    1,   
    0      
    );

    commit;    

  vr_nrctrcrd := fn_sequence('CRAPMAT','NRCTRCRD', 2);
  vr_nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(2);

  insert into cecred.crawcrd
    (nrdconta,
    nrcrcard,
    nrcctitg,
    nrcpftit,
    vllimcrd,
    flgctitg,
    dtmvtolt,
    nmextttl,
    flgprcrd,
    tpdpagto,
    flgdebcc,
    tpenvcrd,
    vlsalari,
    dddebito,
    cdlimcrd,
    tpcartao,
    dtnasccr,
    nrdoccrd,
    nmtitcrd,
    nrctrcrd,
    cdadmcrd,
    cdcooper,
    nrseqcrd,
    dtpropos,
    dtsolici,
    flgdebit,
    cdgraupr,
    insitcrd,
    dtlibera,
    insitdec)
  values  (15438511,       
    '5474080280613025',   
    7563239976394,    
    434835935,     
    5000,      
    3,        
    trunc(sysdate),   
    'RODRIGO A PEREIRA ',  
    1,      
    1,    
    1,   
    0,   
    0,    
    11,    
    29,     
    2,    
    to_date('11/01/1979','dd/mm/yyyy'),
    '02258995960',     
    'RODRIGO A PEREIRA',   
    vr_nrctrcrd,   
    15,      
    1,      
    vr_nrseqcrd,     
    to_date('23/11/2022','dd/mm/rrrr'), 
    to_date('24/11/2022','dd/mm/rrrr'), 
    1,         
    5,       
    3,       
    null,   
    2     
    );

  insert into cecred.crapcrd
    (cdcooper,
    nrdconta,
    nrcrcard,
    nrcpftit,
    nmtitcrd,
    dddebito,
    cdlimcrd,
    dtvalida,
    nrctrcrd,
    cdmotivo,
    nrprotoc,
    cdadmcrd,
    tpcartao,
    dtcancel,
    flgdebit,
    flgprovi)
  values  (1,     
    15438511,       
    '5474080280613025',  
    434835935,    
    'RODRIGO A PEREIRA', 
    11,      
    0,     
    NULL,    
    vr_nrctrcrd,   
    0,  
    0,       
    15,     
    2,     
    NULL,  
    1,   
    0      
    );

    commit;    

  end;

END;
