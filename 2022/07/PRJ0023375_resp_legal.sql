DECLARE
  Cursor vc_contas is
  SELECT *
      FROM ( SELECT CRL.PROGRESS_RECID
                  , ASS.CDCOOPER
                  , ASS.NRDCONTA
                  , ass.nrcpfcgc
                  , TTL.DTNASTTL
                  , (trunc( ( months_between(DAT.DTMVTOLT, ass.dtnasctl ))/12) ) idade
                  , CRL.CDRLCRSP
                  , ( CASE WHEN CRL.CDRLCRSP = 1 then 'PAI'
                           WHEN CRL.CDRLCRSP = 2 then 'MAE'  
                           WHEN CRL.CDRLCRSP = 3 then 'TUTOR' 
                           WHEN CRL.CDRLCRSP = 4 then 'CURADOR'
                           WHEN CRL.CDRLCRSP = 0 then 'NAO INFORMADO' END ) as capacidade_civil      
               FROM CRAPCRL CRL
                  , CRAPASS ASS
                  , CRAPTTL TTL
                  , CRAPDAT DAT
              WHERE ASS.CDCOOPER = CRL.CDCOOPER
                AND ASS.NRDCONTA = CRL.NRCTAMEN
                AND DAT.CDCOOPER = ASS.CDCOOPER
                AND ASS.DTDEMISS IS NULL
                AND ASS.INPESSOA = 1
                AND TTL.CDCOOPER = ASS.CDCOOPER
                AND TTL.NRDCONTA = ASS.NRDCONTA
                AND TTL.IDSEQTTL = 1
                and ttl.idseqttl = crl.idseqmen
                AND TTL.INHABMEN NOT IN ( 1, 2 )
                AND TTL.DTHABMEN IS NULL ) CONTAS
        WHERE CONTAS.IDADE between 18 and 19
          AND CONTAS.CDRLCRSP NOT IN ( 0, 4 ) ;
       


BEGIN

      For vr_contas in vc_contas Loop
        Begin
          
           DELETE 
             FROM CRAPCRL
            WHERE PROGRESS_RECID = VR_CONTAS.PROGRESS_RECID;
            
            commit;
            
            registrarRevisaoCadastral(pr_cdcooper => vr_contas.cdcooper
                                     ,pr_nrdconta => vr_contas.nrdconta
                                     ,pr_cdoperad => 1
                                     ,pr_tpaltera => 1
                                     ,pr_dsaltera => ' ,Exclusao de responsavel legal'
                                     ,pr_dscritic => vr_dscritic);           
              
        Exception
        
        When Others Then 
           Null;
           
        End;   
       
     
     End Loop;
  
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
END;
