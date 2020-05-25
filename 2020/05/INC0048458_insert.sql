BEGIN

  BEGIN
    INSERT INTO crawcrd
      (nrdconta  -- 01
      ,nrcrcard  -- 02
      ,nrcctitg  -- 03
      ,nrcpftit  -- 04
      ,vllimcrd  -- 05
      ,flgctitg  -- 06
      ,dtmvtolt  -- 07
      ,nmextttl  -- 08
      ,flgprcrd  -- 09
      ,tpdpagto  -- 10
      ,flgdebcc  -- 11
      ,tpenvcrd  -- 12
      ,vlsalari  -- 13
      ,dddebito  -- 14
      ,cdlimcrd  -- 15
      ,tpcartao  -- 16
      ,dtnasccr  -- 17
      ,nrdoccrd  -- 18
      ,nmtitcrd  -- 19
      ,nrctrcrd  -- 20
      ,cdadmcrd  -- 21
      ,cdcooper  -- 22
      ,nrseqcrd  -- 23
      ,dtentr2v  -- 24
      ,dtpropos  -- 25
      ,flgdebit  -- 26
      ,nmempcrd) -- 27
    VALUES
      (14303                                                -- 01
      ,0005474080160299903                                  -- 02
      ,7564457007416                                        -- 03
      ,5401317921                                           -- 04
      ,49500                                                -- 05
      ,3                                                    -- 06
      ,TRUNC(SYSDATE)                                       -- 07
      ,NULL                                                 -- 08
      ,1                                                    -- 09
      ,1                                                    -- 10
      ,1                                                    -- 11
      ,1                                                    -- 12
      ,0                                                    -- 13
      ,11                                                   -- 14
      ,65                                                   -- 15
      ,2                                                    -- 16
      ,'19/07/1985'                                         -- 17
      ,NULL                                                 -- 18
      ,'WERNER WIND FILHO'                                  -- 19
      ,fn_sequence('CRAPMAT','NRCTRCRD', 13)                -- 20
      ,15                                                   -- 21
      ,13                                                   -- 22
      ,CCRD0003.fn_sequence_nrseqcrd(pr_cdcooper => 13)     -- 23
      ,trunc(sysdate)                                       -- 24
      ,trunc(sysdate)                                       -- 25
      ,1                                                    -- 26
      ,'WIND INDUSTRIAL');                                  -- 27
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro ao inserir crawcrd: ' || SQLERRM);
      ROLLBACK;
  END;
  
  IF SQL%FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Inserção efetuada com sucesso!');
    COMMIT;
  END IF;

END;
