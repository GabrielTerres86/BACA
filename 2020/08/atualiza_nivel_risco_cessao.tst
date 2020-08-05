PL/SQL Developer Test script 3.0
357
declare 
  PROCEDURE atualiza_nivel_risco IS

    -- Local variables here
    CURSOR cr_central_risco (pr_cdcooper IN crapdat.cdcooper%TYPE
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      select crapepr.cdcooper,
             crapepr.nrdconta,
             crapepr.nrctremp,
             crapris.innivris,
             crapris.inindris,
             crapris.rowid,
             tbcrd_cessao_credito.dtvencto
        from crapepr
        join crapris
          on crapris.cdcooper = crapepr.cdcooper
         and crapris.nrdconta = crapepr.nrdconta
         and crapris.nrctremp = crapepr.nrctremp
         and crapris.dtrefere = pr_dtmvtolt
         and crapris.cdorigem = 3
        join tbcrd_cessao_credito
          on tbcrd_cessao_credito.cdcooper = crapepr.cdcooper
         and tbcrd_cessao_credito.nrdconta = crapepr.nrdconta
         and tbcrd_cessao_credito.nrctremp = crapepr.nrctremp
       where crapris.cdcooper = pr_cdcooper
         and crapris.inddocto = 1
         and crapepr.cdfinemp = 69;
         
     CURSOR cr_cracop IS
       select crapcop.cdcooper
         from crapcop
        where crapcop.flgativo = 1
          and crapcop.cdcooper not in (3)
     order by crapcop.cdcooper;
     
     CURSOR cr_crapris (pr_cdcooper  IN crapris.cdcooper%TYPE
                       ,pr_dtrefere  IN crapris.dtrefere%TYPE) IS
        SELECT cdcooper
              ,nrdconta
              ,nrctremp
              ,cdmodali
              ,dtrefere
              ,innivori
              ,nrseqctr
              ,innivris
              ,dtdrisco
              ,cdorigem
              ,rowid
              ,ROW_NUMBER () OVER (PARTITION BY nrdconta
                                       ORDER BY nrdconta,innivris DESC) sequencia
          FROM crapris
         WHERE cdcooper = pr_cdcooper
           AND dtrefere = pr_dtrefere
           AND inddocto = 1
           AND innivris > 1 -- Risco AA não participa do Arrasto
      ORDER BY nrdconta
              ,innivris DESC;
                
     -- ENCONTRAR O MAIOR RISCO DO GRUPO
     CURSOR cr_risco_grupo (pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
        SELECT r.nrdgrupo
             , MAX(r.innivris) risco_grupo
          FROM crapris r
         WHERE r.cdcooper = pr_cdcooper
           AND r.dtrefere = pr_dtrefere
           and r.inddocto = 1
           AND r.nrdgrupo > 0
           AND r.innivris > 1  -- Risco AA não participa
         GROUP BY r.nrdgrupo;
     
     -- Cadastro de informacoes de central de riscos
     CURSOR cr_crapris_grupo(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_nrdgrupo IN crapris.nrdgrupo%TYPE
                            ,pr_dtrefere IN crapris.dtrefere%TYPE
                            ,pr_innivris IN crapris.innivris%TYPE) IS
       SELECT /*+ INDEX(crapris CRAPRIS##CRAPRIS1) */
                ris.cdcooper
               ,ris.dtrefere
               ,ris.nrdconta
               ,ris.innivris
               ,ris.cdmodali
               ,ris.cdorigem
               ,ris.nrctremp
               ,ris.nrseqctr
               ,ris.qtdiaatr
               ,ris.progress_recid
               ,ris.rowid
          FROM crapris ris
         WHERE ris.cdcooper = pr_cdcooper
           AND ris.dtrefere = pr_dtrefere
           AND ris.nrdgrupo = pr_nrdgrupo
           AND (    ris.innivris < pr_innivris -- Menor que o risco do grupo
                AND ris.innivris > 1)  -- Risco AA não participa
           --AND ris.inddocto = 1
           AND (ris.inddocto = 1 OR ris.cdmodali = 1901);
           
     -- Variaveis sistemas    
     vr_dtmvtolt        crapdat.dtmvtolt%TYPE;
     vr_qtdiaatr_cessao PLS_INTEGER;
     vr_inrisco_atraso  PLS_INTEGER;
     vr_innivris        crapris.innivris%TYPE;
     vr_texto_completo  CLOB;
     vr_des_log         CLOB;   
     vr_texto_arrasto   CLOB;
     vr_des_arrasto     CLOB;
     vr_maxrisco        INTEGER:=-10;
     
     vr_texto_arrasto_grupo   CLOB;
     vr_des_arrasto_grupo     CLOB;
     
     vr_dtdrisco_upd    DATE;
     vr_dsdireto        VARCHAR2(1000);
         
     -- Variavel tratamento de erro
     vr_dscritic        VARCHAR2(1000);
     vr_exc_erro        EXCEPTION;
  BEGIN      
     vr_dtmvtolt := TO_DATE('31/07/2020','DD/MM/RRRR');
          
     -- Inicializar o CLOB
     vr_texto_completo := NULL;
     vr_des_log := NULL;
     dbms_lob.createtemporary(vr_des_log, TRUE);
     dbms_lob.open(vr_des_log, dbms_lob.lob_readwrite);
     
     vr_texto_arrasto := NULL;
     vr_des_arrasto := NULL;
     dbms_lob.createtemporary(vr_des_arrasto, TRUE);
     dbms_lob.open(vr_des_arrasto, dbms_lob.lob_readwrite);  
     
     vr_texto_arrasto_grupo := NULL;
     vr_des_arrasto_grupo := NULL;
     dbms_lob.createtemporary(vr_des_arrasto_grupo, TRUE);
     dbms_lob.open(vr_des_arrasto_grupo, dbms_lob.lob_readwrite);  

     ------------------------------------------------------------------------------------
     -- Atualiza o risco das operações de cessão de cartão
     ------------------------------------------------------------------------------------   
     gene0002.pc_escreve_xml(vr_des_log, vr_texto_completo, 'Coop.;Conta;Contrato;Data Vencimento Fatura;Risco Antigo;Risco Novo;RowId' || chr(10));
     
     FOR rw_crapcop IN cr_cracop LOOP
       
       FOR rw_central_risco IN cr_central_risco(pr_cdcooper => rw_crapcop.cdcooper,
                                                pr_dtmvtolt => vr_dtmvtolt) LOOP
         -- Cessao de Cartao --
         vr_qtdiaatr_cessao := vr_dtmvtolt - rw_central_risco.dtvencto;
         vr_inrisco_atraso  := RISC0004.fn_calcula_niv_risco_atraso(vr_qtdiaatr_cessao);
              
         -- Qual é o pior risco, nivel de risco ou nivel da cessao de cartao????
         vr_innivris        := GREATEST(vr_inrisco_atraso,rw_central_risco.innivris);
         
         IF vr_innivris <> rw_central_risco.innivris THEN
           -- Escreve no arquivo completo
           gene0002.pc_escreve_xml(vr_des_log, vr_texto_completo, rw_central_risco.cdcooper || ';' || 
                                                                  rw_central_risco.nrdconta || ';' ||
                                                                  rw_central_risco.nrctremp || ';' ||
                                                                  rw_central_risco.dtvencto || ';' ||
                                                                  rw_central_risco.innivris || ';' ||
                                                                  vr_innivris || ';' ||
                                                                  rw_central_risco.rowid || chr(10));
            
           -- Atualizar o nível de risco
           BEGIN
             UPDATE crapris SET 
                    innivris = vr_innivris
                   ,inindris = vr_innivris
              WHERE rowid = rw_central_risco.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := SQLERRM;
               RAISE vr_exc_erro;
           END;     
         END IF;
       END LOOP;
     END LOOP;  
     
     ------------------------------------------------------------------------------------
     -- Efetua o arrasto das operacoes de credito
     ------------------------------------------------------------------------------------   
     gene0002.pc_escreve_xml(vr_des_arrasto, vr_texto_arrasto, 'Coop.;Conta;Contrato;Modalidade;Risco Antigo;Risco Novo;Data Risco Antiga;Data Risco Novo;Rowid' || chr(10));
     
     vr_innivris := null;
     FOR rw_crapcop IN cr_cracop LOOP
          
       FOR rw_crapris IN cr_crapris(pr_cdcooper  => rw_crapcop.cdcooper
                                   ,pr_dtrefere  => vr_dtmvtolt) LOOP
                                    
         -- Para o primeiro registro da conta
         IF rw_crapris.sequencia = 1 THEN
           -- Risco calculado do cartao de credito
           vr_innivris := rw_crapris.innivris;
         END IF; 
         
         -- Se o nível mais elevado for HH e o nível atual não for
         IF vr_innivris = 10 AND rw_crapris.innivris <> 10 THEN
           -- Nao jogar p/prejuizo, prov.100
           vr_innivris := 9;
         END IF;
         
         -- Escreve no arquivo completo
  --       IF rw_crapris.innivris <> vr_innivris THEN
           gene0002.pc_escreve_xml(vr_des_arrasto, vr_texto_arrasto, rw_crapris.cdcooper || ';' || 
                                                                     rw_crapris.nrdconta || ';' ||
                                                                     rw_crapris.nrctremp || ';' ||
                                                                     rw_crapris.cdmodali || ';' ||
                                                                     rw_crapris.innivris || ';' ||
                                                                     vr_innivris || ';' ||
                                                                     rw_crapris.dtdrisco || ';' ||
                                                                     vr_dtdrisco_upd || ';' ||
                                                                     rw_crapris.rowid || chr(10));

           -- Atualizar o risco
           BEGIN
             UPDATE crapris
                SET innivris = vr_innivris
                   ,inindris = vr_innivris
              WHERE rowid = rw_crapris.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao atualizar a tabela crapris. --> '
                              || 'Conta: '||rw_crapris.nrdconta||', Rowid: '||rw_crapris.rowid
                              || '. Detalhes:'||sqlerrm;
               RAISE vr_exc_erro;
           END;
          
           -- Atualizar o risco
           BEGIN
             UPDATE crapvri
                SET innivris = vr_innivris
              WHERE cdcooper = rw_crapris.cdcooper
                AND nrdconta = rw_crapris.nrdconta
                AND nrctremp = rw_crapris.nrctremp
                AND cdmodali = rw_crapris.cdmodali
                AND dtrefere = rw_crapris.dtrefere
                AND nrseqctr = rw_crapris.nrseqctr;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao atualizar a tabela crapvri. --> '
                              || 'Conta: '||rw_crapris.nrdconta||', Rowid: '||rw_crapris.rowid
                              || '. Detalhes:' || sqlerrm;
               RAISE vr_exc_erro;
           END;
                
       END LOOP; -- Fim riscos  
     END LOOP; -- Fim Cooperativa

     ------------------------------------------------------------------------------------
     -- Efetua o arrasto das operacoes de credito por grupo economico
     ------------------------------------------------------------------------------------
     gene0002.pc_escreve_xml(vr_des_arrasto_grupo, vr_texto_arrasto_grupo, 'Coop.;Conta;Contrato;Modalidade;Risco Antigo;Risco Novo;Rowid' || chr(10));
     
     FOR rw_crapcop IN cr_cracop LOOP
            
       FOR rw_risco_grupo IN cr_risco_grupo (pr_cdcooper => rw_crapcop.cdcooper
                                            ,pr_dtrefere => vr_dtmvtolt) LOOP

         -- MAIOR RISCO DO GRUPO
         vr_maxrisco := rw_risco_grupo.risco_grupo;
         -- NAO LEVA PARA O PREJUIZO
         IF vr_maxrisco = 10 THEN
           vr_maxrisco := 9;
         END IF;

           -- BUSCA NA CENTRAL CONTAS QUE TEM RISCO MENOR QUE O RISCO DO GRUPO
           FOR rw_crapris_grupo IN cr_crapris_grupo(pr_cdcooper => rw_crapcop.cdcooper
                                                   ,pr_nrdgrupo => rw_risco_grupo.nrdgrupo
                                                   ,pr_dtrefere => vr_dtmvtolt -- Data do Dia
                                                   ,pr_innivris => vr_maxrisco) LOOP

             --  IF rw_crapris_grupo.innivris <> vr_maxrisco THEN
                 -- Escreve no arquivo completo
                 gene0002.pc_escreve_xml(vr_des_arrasto_grupo, vr_texto_arrasto_grupo, rw_crapris_grupo.cdcooper || ';' || 
                                                                                       rw_crapris_grupo.nrdconta || ';' ||
                                                                                       rw_crapris_grupo.nrctremp || ';' ||
                                                                                       rw_crapris_grupo.cdmodali || ';' ||
                                                                                       rw_crapris_grupo.innivris || ';' ||
                                                                                       vr_maxrisco ||';'||
                                                                                       rw_crapris_grupo.rowid || chr(10));
                 
                 BEGIN
                   UPDATE crapris
                      SET crapris.innivris = vr_maxrisco,
                          crapris.inindris = vr_maxrisco
                    WHERE cdcooper         = rw_crapris_grupo.cdcooper
                      AND nrdconta         = rw_crapris_grupo.nrdconta
                      AND dtrefere         = rw_crapris_grupo.dtrefere
                      AND innivris         = rw_crapris_grupo.innivris
                      AND progress_recid   = rw_crapris_grupo.progress_recid;
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_dscritic := 'RISC0004.pc_central_risco_grupo: Erro ao atualizar Riscos G.E.(crapris). '||'Erro: '||SQLERRM;
                     RAISE vr_exc_erro;
                 END;
                 
                 -- Atualizar o risco
                 BEGIN
                   UPDATE crapvri
                      SET innivris = vr_maxrisco
                    WHERE cdcooper = rw_crapris_grupo.cdcooper
                      AND nrdconta = rw_crapris_grupo.nrdconta
                      AND nrctremp = rw_crapris_grupo.nrctremp
                      AND cdmodali = rw_crapris_grupo.cdmodali
                      AND dtrefere = rw_crapris_grupo.dtrefere
                      AND nrseqctr = rw_crapris_grupo.nrseqctr;
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_dscritic := 'Erro ao atualizar a tabela crapvri. --> '
                                    || 'Conta: '||rw_crapris_grupo.nrdconta||', Rowid: '||rw_crapris_grupo.rowid
                                    || '. Detalhes:' || sqlerrm;
                     RAISE vr_exc_erro;
                 END;
         --      END IF;
                            
           END LOOP; -- FIM FOR rw_crapris
           
      --  END LOOP; -- FIM FOR rw_contas_grupo

       END LOOP; -- FIM FOR rw_risco_grupo
       
     END LOOP;
     
     -- Fecha o arquivo
     gene0002.pc_escreve_xml(vr_des_log, vr_texto_completo, ' '    || chr(10),TRUE);
     gene0002.pc_escreve_xml(vr_des_arrasto, vr_texto_arrasto, ' ' || chr(10),TRUE);
     gene0002.pc_escreve_xml(vr_des_arrasto_grupo, vr_texto_arrasto_grupo, ' ' || chr(10),TRUE);
     
     vr_dsdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/james';
     DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_log, vr_dsdireto, 'contratos_cessao_cartao.csv', NLS_CHARSET_ID('UTF8'));
     DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_arrasto, vr_dsdireto, 'arrasto_conta.csv', NLS_CHARSET_ID('UTF8'));
     DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_arrasto_grupo, vr_dsdireto, 'arrasto_grupo_economico.csv', NLS_CHARSET_ID('UTF8'));
        
     dbms_lob.close(vr_des_log);
     dbms_lob.freetemporary(vr_des_log);
     
     dbms_lob.close(vr_des_arrasto);
     dbms_lob.freetemporary(vr_des_arrasto);
     
     dbms_lob.close(vr_des_arrasto_grupo);
     dbms_lob.freetemporary(vr_des_arrasto_grupo);

     commit;
     dbms_output.put_line('sucesso');
     
  EXCEPTION
    WHEN vr_exc_erro THEN
      dbms_output.put_line(vr_dscritic);
      ROLLBACK;    
    WHEN OTHERS THEN
      dbms_output.put_line(sqlerrm);
      ROLLBACK;   
  END atualiza_nivel_risco;

begin
  -- Test statements here
  atualiza_nivel_risco;
end;
0
0
