delete tbreportaval_fatca_crs where nrcpfcgc = '23969024000159';
delete tbreportaval_fatca_crs where nrcpfcgc = '97011959904';
INSERT INTO tbreportaval_fatca_crs
                   (nrcpfcgc
                   ,insituacao
                   ,inreportavel
                   ,cdtipo_declarado
                   ,cdtipo_proprietario
                   ,dsjustificativa
                   ,dtinicio
                   ,dtfinal
                   ,dtaltera
                   ,cdoperad)
            VALUES ('23969024000159'
                   ,'P'             -- insituacao  -- Pendente
                   ,NULL            -- inreportavel
                   ,NULL            -- cdtipo_declarado
                   ,NULL            -- cdtipo_proprietario
                   ,NULL            -- dsjustificativa
                   ,NULL            -- dtinicio
                   ,NULL            -- dtfinal
                   ,SYSDATE         -- dtaltera
                   ,'1'); -- Resolve o problema da primeira.
INSERT INTO tbreportaval_fatca_crs
                   (nrcpfcgc
                   ,insituacao
                   ,inreportavel
                   ,cdtipo_declarado
                   ,cdtipo_proprietario
                   ,dsjustificativa
                   ,dtinicio
                   ,dtfinal
                   ,dtaltera
                   ,cdoperad)
            VALUES ('97011959904'
                   ,'P'             -- insituacao  -- Pendente
                   ,NULL            -- inreportavel
                   ,NULL            -- cdtipo_declarado
                   ,NULL            -- cdtipo_proprietario
                   ,NULL            -- dsjustificativa
                   ,NULL            -- dtinicio
                   ,NULL            -- dtfinal
                   ,SYSDATE         -- dtaltera
                   ,'1'); -- Resolve o problema da segunda.  
commit;                   
                               
              
