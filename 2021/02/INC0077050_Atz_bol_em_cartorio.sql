DECLARE

  rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
  vr_nrretcoo NUMBER := 0;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2 (4000);
  
BEGIN
  --
  FOR rw_bolpro in (SELECT DISTINCT    
                       crapcob.cdcooper
                      ,crapcob.nrcnvcob
                      ,crapcop.cdbcoctl
                      ,rpad(crapcop.cdagectl, 6, ' ') cdagectl 
                      ,crapcob.nrdconta nrctalog 
                      ,crapcob.nrdocmto 
                      ,crapcob.rowid
                      ,crapcob.dtmvtolt
                    FROM craprem
                    ,crapcob
                    ,crapdat
                    ,crapban
                    ,crapcop
                    ,crapass
                    ,crapenc
                    ,crapsab
                    ,crapmun
                    ,crapmun comarca
                    ,crapcco
                    ,crapcre
                    ,crapdne
                    WHERE crapcco.cdcooper > 0
                    AND crapcco.cddbanco = 85
                    AND crapcre.cdcooper = crapcco.cdcooper
                    AND crapcre.nrcnvcob = crapcco.nrconven
                    --
                    AND crapcre.dtmvtolt >= to_date('01-01-2021','DD-MM-RRRR')
                    AND crapcob.dtsitcrt <= to_date('10-02-2021','DD-MM-RRRR')
                    AND crapcob.dtsitcrt >= to_date('01-01-2021','DD-MM-RRRR')                    
                    --
                    AND crapcre.intipmvt = 1
                    AND craprem.cdcooper = crapcre.cdcooper
                    AND craprem.nrcnvcob = crapcre.nrcnvcob
                    AND craprem.nrremret = crapcre.nrremret
                    AND crapcob.cdcooper = craprem.cdcooper
                    AND crapcob.nrdconta = craprem.nrdconta
                    AND crapcob.nrcnvcob = craprem.nrcnvcob
                    AND crapcob.nrdocmto = craprem.nrdocmto
                    AND crapdat.cdcooper = crapcob.cdcooper
                    AND crapban.cdbccxlt = crapcob.cdbandoc
                    AND crapcop.cdcooper = crapcob.cdcooper
                    AND crapass.nrdconta = crapcob.nrdconta
                    AND crapass.cdcooper = crapcob.cdcooper
                    AND crapenc.cdcooper = crapass.cdcooper
                    AND crapenc.nrdconta = crapass.nrdconta
                    AND crapenc.tpendass = 9 -- Comercial
                    AND crapenc.idseqttl = 1
                    AND crapsab.cdcooper = crapcob.cdcooper
                    AND crapsab.nrdconta = crapcob.nrdconta
                    AND crapsab.nrinssac = crapcob.nrinssac
                    AND crapdne.nrceplog = crapsab.nrcepsac
                    AND crapdne.idoricad = 1 -- CEP dos correios
                    AND LPAD(crapmun.cdufibge, 2, '0') || LPAD(crapmun.cdcidbge, 5, '0') = crapdne.cdcidibge
                    AND LPAD(comarca.cdufibge, 2, '0') || LPAD(comarca.cdcidbge, 5, '0') = crapmun.cdcomarc
                    AND crapcob.cdbandoc = 85
                    AND crapcob.insrvprt = 1
                    AND crapcob.insitcrt = 2 -- Enviado pra cartorio
                    AND craprem.cdocorre = 9 -- Somente boletos c/ instrução de protesto
                    ORDER BY crapcob.cdcooper, crapcob.nrdconta, crapcob.nrdocmto)
    LOOP
      DBMS_OUTPUT.put_line(rw_bolpro.nrctalog ||' - '|| rw_bolpro.nrdocmto);      
      
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_bolpro.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;      
      --
      cobr0011.pc_proc_devolucao(pr_idtabcob      => rw_bolpro.rowid                      -- IN
                                ,pr_cdbanpag     => rw_bolpro.cdbcoctl                   -- IN
                                ,pr_cdagepag     => rw_bolpro.cdagectl                   -- IN
                                ,pr_dtocorre     => rw_bolpro.dtmvtolt                   -- IN
                                ,pr_cdocorre     => 89                                    -- IN
                                ,pr_dsmotivo     => '98'                                  -- IN
                                ,pr_crapdat      => rw_crapdat                            -- IN
                                ,pr_cdoperad     => '1'                                   -- IN
                                ,pr_vltarifa     => 0                                     -- IN
                                ,pr_ret_nrremret => vr_nrretcoo                           -- OUT
                                ,pr_cdcritic     => vr_cdcritic                           -- OUT
                                ,pr_dscritic     => vr_dscritic                           -- OUT
                                );
      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            vr_cdcritic := 0;
            vr_dscritic := NULL;
      END IF;      
      
  END LOOP;  
  --  
  COMMIT;  
    
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;    
    DBMS_OUTPUT.put_line('Erro atz rem cartorio: '||sqlerrm);      
END;
