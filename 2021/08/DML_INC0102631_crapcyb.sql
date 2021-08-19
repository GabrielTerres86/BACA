BEGIN
  INSERT INTO crapcyb(cdcooper
                   ,cdorigem
                   ,nrdconta
                   ,nrctremp
                   ,cdagenci
                   ,cdlcremp
                   ,cdfinemp
                   ,dtefetiv
                   ,vlemprst                                
                   ,qtpreemp
                   ,flgconsg
                   ,flgfolha
                   ,dtdpagto
                   ,dtmvtolt
                   ,vlsdeved 
                   ,qtprepag 
                   ,txmensal 
                   ,txdiaria 
                   ,dtprejuz 
                   ,vlpreemp 
                   ,flgpreju 
                   ,vlsdprej 
                   ,vlsdevan
                   ,vlprapga
                   ,qtmesdec
                   )
     SELECT cer.cdcooper
           ,3  
           ,cer.nrdconta
           ,cer.nrctremp
           ,ass.cdagenci
           ,cer.cdlcremp
           ,cer.cdfinemp
           ,cer.dtmvtolt
           ,cer.vlemprst
           ,cer.qtpreemp
           ,DECODE(tpdescto,2,1,0) flgconsg
           ,flgpagto
           ,NVL((SELECT ris.dtrefere - ris.qtdiaatr 
               FROM crapris ris
              WHERE ris.cdcooper = cer.cdcooper
                AND ris.nrdconta = cer.nrdconta
                AND ris.nrctremp = cer.nrctremp
                AND ris.dtrefere = dat.dtmvtoan),cer.dtdpagto) dtdpagto
           ,dat.dtmvtolt -- AJUSTAR
           ,cer.vlsdeved
           ,cer.qtprecal
           ,cer.txmensal
           ,cer.txjuremp
           ,cer.dtprejuz
           ,cer.vlpreemp
           ,cer.inprejuz
           ,cer.vlsdprej           
           ,cer.vlsdprej           
           ,cer.vlsdprej
           ,cer.qtmesdec
      FROM crapepr cer
          ,crapass ass
          ,crapdat dat
      WHERE ass.cdcooper = cer.cdcooper
        AND ass.nrdconta = cer.nrdconta
        AND ass.cdcooper = dat.cdcooper
        AND cer.inprejuz > 0
        AND cer.cdcooper = 9 
        AND ass.cdagenci = 28
        AND cer.dtprejuz < to_date('10/08/2021','DD/MM/RRRR')
        AND cer.vlsdprej > 0;
        
  COMMIT;        

END;  
