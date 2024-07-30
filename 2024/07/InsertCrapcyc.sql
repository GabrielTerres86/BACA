BEGIN
  INSERT INTO cecred.crapcyc
    (CDCOOPER
    ,CDORIGEM
    ,NRDCONTA
    ,NRCTREMP
    ,FLGJUDIC
    ,FLEXTJUD
    ,FLGEHVIP
    ,CDOPERAD
    ,DTENVCBR
    ,DTINCLUS
    ,CDOPEINC
    ,DTALTERA
    ,CDASSESS
    ,CDMOTCIN
    ,FLVIPANT
    ,CDMOTANT
    ,CDPROLEG)
  VALUES
    (14
    ,1
    ,99662957
    ,336980
    ,1
    ,0
    ,0
    ,'1'
    ,to_date('09-06-2022', 'dd-mm-yyyy')
    ,to_date('23-05-2022', 'dd-mm-yyyy')
    ,'cyber'
    ,to_date('30-04-2024', 'dd-mm-yyyy')
    ,2
    ,0
    ,0
    ,0
    ,888333);
  COMMIT;
END;
