DECLARE
  vr_contador       NUMBER;  
  vr_excsaida       EXCEPTION;
  vr_cdcritic       NUMBER;
  vr_dscritic       VARCHAR2(2000);
  vr_linha          VARCHAR2(2000);
  vr_cdcooper       NUMBER;
  vr_vlmaximo       NUMBER;
  vr_nrctrseg       NUMBER;
  vr_rootmicros     VARCHAR2(4000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto       VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0094957';
  vr_nmarqimp       VARCHAR2(100)  := 'INC0094957_rollback.txt';
  vr_nmarqcsv       VARCHAR2(100)  := 'INC0094957_inseridos.csv';
  vr_INd_arquiv     UTL_FILE.FILE_TYPE;  
  vr_INd_arquiv2    UTL_FILE.FILE_TYPE; 
  vr_flgprestamista VARCHAR2(1) := 'N';
  vr_flgdps         VARCHAR2(1) := 'N';
  vr_vlproposta     CRAWSEG.VLSEGURO%TYPE;
  vr_dsmotcan       VARCHAR2(60);
  vr_dsorigem       CRAPLGM.DSORIGEM%TYPE; 
  
  CURSOR cr_seguros IS
  SELECT a.cdcooper
       , a.nrdconta
       , a.nrctrseg
       , a.nrctremp  
       , a.nrctremp nrctrato 
       , a.vlsdeved vlproposta 
       , a.nrproposta   
       , a.cdapolic
       , TO_DATE(a.dtINivig,'DD/MM/RRRR') dtINivig
       , SUM(a.vldevatu) OVER(PARTITION BY a.cdcooper, a.nrdconta )  Saldo_Devedor
        ,TO_DATE(SYSDATE,'DD/MM/RRRR') dtmvtolt
        ,4 tpseguro 
        ,514 cdsegura 
        ,a.nrcpfcgc 
        ,a.nmprimtl
        ,TO_DATE(a.dtfimvig,'DD/MM/RRRR') dtfimvig
        ,a.vlprodut 
        ,a.vldevatu
        ,0 cdcalcul 
        ,NVL((SELECT MAX(g.tpplaseg) FROM crawseg g WHERE g.cdcooper = a.cdcooper AND g.nrdconta = a.nrdconta AND g.tpseguro = 4 ),0) tpplaseg 
        ,0 flgunica 
        ,a.dsendres
        ,0 nrendres 
        ,a.nmbairro 
        ,a.nmcidade 
        ,a.cdufresd 
        ,a.nrcepend 
        ,' ' complend
    FROM tbseg_prestamista a, 
         crapcop p
    WHERE p.flgativo = 1 
      AND a.cdcooper = p.cdcooper
      AND a.tpregist IN (1,3)
      AND NOT EXISTS (SELECT 1 
                        FROM crapseg pseg, 
                             crawseg wseg 
                       WHERE wseg.tpseguro = 4
                         AND wseg.cdcooper = a.cdcooper
                         AND wseg.nrdconta = a.nrdconta
                         AND wseg.nrctrato = a.nrctremp
                         AND pseg.cdcooper = wseg.cdcooper
                         AND pseg.nrdconta = wseg.nrdconta
                         AND pseg.nrctrseg = wseg.nrctrseg )
    ORDER BY a.cdcooper, a.nrdconta;
   rw_seguros cr_seguros%ROWTYPE;
  
  vr_existeDir NUMBER := 0;
  vr_gerdps VARCHAR2(1);
     
  CURSOR cr_crawseq(pr_cdcooper1 crapseg.cdcooper%TYPE,
                    pr_nrdconta1 crapseg.nrdconta%TYPE,
                    pr_nrctrato1 crawseg.nrctrato%TYPE) IS 
      SELECT 1
            FROM crapseg pseg, 
                 crawseg wseg
           WHERE pseg.cdcooper = wseg.cdcooper
             AND pseg.nrdconta = wseg.nrdconta
             AND pseg.nrctrseg = wseg.nrctrseg                                            
             AND wseg.cdcooper = pr_cdcooper1 
             AND wseg.nrdconta = pr_nrdconta1
             AND wseg.nrctrato = pr_nrctrato1
             AND wseg.tpseguro = 4;  
        rw_crawseq cr_crawseq%rowTYPE;     
        
   CURSOR c_crawseg_prop (pr_cdcooper crapseg.cdcooper%TYPE,
                          pr_nrdconta crapseg.nrdconta%TYPE,
                          pr_nrctrato crawseg.nrctrato%TYPE) IS 
    SELECT s.nrctrseg
      FROM crawseg s
     WHERE s.tpseguro = 4
       AND s.cdcooper = pr_cdcooper
       AND s.nrdconta = pr_nrdconta
       AND s.nrctrato = pr_nrctrato;   
    r_crawseg_prop c_crawseg_prop%ROWTYPE;
   
   PROCEDURE pc_inserir_crawseg( pr_cdcooper  IN crawseg.cdcooper%TYPE
                                ,pr_nrdconta  IN crawseg.nrdconta%TYPE                                
                                ,pr_nrctrseg1 IN crawseg.nrctrseg%TYPE
                                ,pr_nrctrato  IN crawseg.nrctrato%TYPE
                                ,pr_vlseguro  IN crawseg.vlseguro%TYPE
                                ,pr_nrctrseg  OUT crawseg.nrctrseg%TYPE
                                ,pr_dtmvtolt  crawseg.dtmvtolt%TYPE
                                ,pr_dtdebito  crawseg.dtdebito%TYPE
                                ,pr_tpseguro  crawseg.tpseguro%TYPE
                                ,pr_cdsegura  crawseg.cdsegura%TYPE
                                ,pr_nrcpfcgc  crawseg.nrcpfcgc%TYPE
                                ,pr_nmdsegur  crawseg.nmdsegur%TYPE
                                ,pr_dtINivig  crawseg.dtINivig%TYPE
                                ,pr_dtINiseg  crawseg.dtINiseg%TYPE
                                ,pr_dtfimvig  crawseg.dtfimvig%TYPE
                                ,pr_cdcalcul  crawseg.cdcalcul%TYPE
                                ,pr_tpplaseg  crawseg.tpplaseg%TYPE
                                ,pr_dtprideb  crawseg.dtprideb%TYPE
                                ,pr_flgunica  crawseg.flgunica%TYPE
                                ,pr_dsENDres  crawseg.dsENDres%TYPE
                                ,pr_nrENDres  crawseg.nrENDres%TYPE
                                ,pr_nmbairro  crawseg.nmbairro%TYPE
                                ,pr_nmcidade  crawseg.nmcidade%TYPE
                                ,pr_cdufresd  crawseg.cdufresd%TYPE
                                ,pr_nrcepEND  crawseg.nrcepEND%TYPE
                                ,pr_complEND  crawseg.complEND%TYPE) IS
     BEGIN            
        BEGIN
         vr_nrctrseg := 0;
                      
           -- Buscar a proxima sequencia crapmat.nrctrseg 
           pc_sequence_progress(pr_nmtabela => 'CRAPMAT'
                               ,pr_nmdcampo => 'NRCTRSEG'
                               ,pr_dsdchave => pr_cdcooper
                               ,pr_flgdecre => 'N'
                               ,pr_sequence => vr_nrctrseg);                              
           INSERT INTO crawseg
            (dtmvtolt
            ,dtdebito
            ,nrdconta
            ,nrctrseg
            ,tpseguro
            ,cdsegura
            ,nrcpfcgc
            ,nmdsegur
            ,dtinivig
            ,dtiniseg
            ,dtfimvig
            ,vlpremio
            ,vlpreseg
            ,cdcalcul
            ,tpplaseg
            ,vlseguro
            ,dtprideb
            ,flgunica
            ,dsendres
            ,nrendres
            ,nmbairro
            ,nmcidade
            ,cdufresd
            ,nrcepend
            ,cdcooper
            ,nrctrato
            ,complend)
          VALUES
            ( pr_dtmvtolt,
              pr_dtdebito,
              pr_nrdconta,
              vr_nrctrseg,
              pr_tpseguro, 
              pr_cdsegura,
              pr_nrcpfcgc,
              pr_nmdsegur,
              pr_dtINivig,
              pr_dtINiseg,
              pr_dtfimvig,
              pr_vlseguro,
              pr_vlseguro,
              pr_cdcalcul,
              pr_tpplaseg,
              pr_vlseguro,
              pr_dtprideb,
              pr_flgunica,
              pr_dsendres,
              pr_nrendres,
              pr_nmbairro,
              pr_nmcidade,
              pr_cdufresd,
              pr_nrcepend,
              pr_cdcooper,
              pr_nrctrato,
              pr_complend);
              
            pr_nrctrseg := vr_nrctrseg ;
      
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
            vr_dscritic:= 'Erro ao inserir registro na crawseg. '||SQLERRM;
            --Levantar Excecao
            DBMS_OUTPUT.PUT_LINE(vr_dscritic);
            RAISE_APPLICATION_ERROR(-20001,vr_dscritic)  ;
        END;
       
     END pc_inserir_crawseg;   
     
     PROCEDURE pc_efetiva_proposta_seguro_p(pr_cdcooper IN  crapcop.cdcooper%TYPE,
                                            pr_nrdconta IN  crapass.nrdconta%TYPE,
                                            pr_nrctrato IN  crawseg.nrctrato%TYPE,
                                            pr_cdoperad IN  crapope.cdoperad%TYPE,
                                            pr_cdagenci IN  crapseg.cdagenci%TYPE,
                                            pr_vlslddev IN  crapseg.vlslddev%TYPE,
                                            pr_idimpdps IN  VARCHAR2,
                                            pr_dtinivig IN  crapseg.dtINivig%TYPE,
                                            pr_nrctrseg OUT crapseg.nrctrseg%TYPE,
                                            pr_cdcritic OUT crapcri.cdcritic%TYPE,    --> Codigo da critica
                                            pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica

                                                                                          
    CURSOR c_crawseg is
    SELECT s.*
      FROM crawseg s
     WHERE s.tpseguro = 4
       AND s.cdcooper = pr_cdcooper
       AND s.nrdconta = pr_nrdconta
       AND s.nrctrato = pr_nrctrato       
       AND NOT EXISTS (SELECT 1 
                         FROM crapseg p
                        WHERE s.cdcooper = p.cdcooper
                          AND s.nrdconta = p.nrdconta
                          AND s.tpseguro = p.tpseguro
                          AND s.nrctrseg = p.nrctrseg);   
    r_crawseg c_crawseg%rowTYPE;

    -- Cursor genérico de calENDário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;       
    
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);      
                                           
    BEGIN 
      
     OPEN c_crawseg;
      FETCH c_crawseg INTO r_crawseg;
     CLOSE c_crawseg;
     
     -- Leitura do calENDário da cooperativa
     OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
    
     BEGIN
       INSERT INTO crapseg(crapseg.cdcooper,
                           crapseg.cdoperad,
                           crapseg.dtmvtolt,
                           crapseg.nrseqdig,
                           crapseg.nrctrseg,
                           crapseg.cdagenci,
                           crapseg.cdsitseg,
                           crapseg.dtdebito,
                           crapseg.dtinivig,
                           crapseg.dtfimvig,
                           crapseg.cdsegura,
                           crapseg.nrdconta,
                           crapseg.dtultpag,
                           crapseg.dtiniseg,
                           crapseg.qtparcel,
                           crapseg.dtprideb,
                           crapseg.vldifseg,
                           crapseg.flgunica,
                           crapseg.tpseguro,
                           crapseg.tpplaseg,
                           crapseg.vlpreseg,
                           crapseg.lsctrant,
                           crapseg.nrctratu,
                           crapseg.tpendcor,
                           crapseg.flgconve,
                           crapseg.tpdpagto,
                           crapseg.vlpremio,
                           crapseg.cdopeori,
                           crapseg.cdageori,
                           crapseg.dtinsori,
                           crapseg.vlslddev,
                           crapseg.idimpdps) values (pr_cdcooper
                                                    ,pr_cdoperad
                                                    ,rw_crapdat.dtmvtolt
                                                    ,r_crawseg.nrctrseg
                                                    ,r_crawseg.nrctrseg
                                                    ,pr_cdagenci
                                                    ,1 -- Ativo
                                                    ,r_crawseg.dtdebito
                                                    ,pr_dtinivig
                                                    ,r_crawseg.dtfimvig
                                                    ,514
                                                    ,r_crawseg.nrdconta
                                                    ,r_crawseg.dtmvtolt
                                                    ,r_crawseg.dtiniseg
                                                    ,r_crawseg.qtparcel
                                                    ,r_crawseg.dtprideb
                                                    ,r_crawseg.vldifseg
                                                    ,r_crawseg.flgunica
                                                    ,r_crawseg.tpseguro
                                                    ,r_crawseg.tpplaseg
                                                    ,r_crawseg.vlpreseg
                                                    ,r_crawseg.lsctrant
                                                    ,r_crawseg.nrctratu
                                                    ,1 -- tpENDcor -- Residencial
                                                    ,r_crawseg.flgconve
                                                    ,r_crawseg.tpdpagto
                                                    ,r_crawseg.vlpremio
                                                    ,pr_cdoperad
                                                    ,pr_cdagenci
                                                    ,SYSDATE
                                                    ,pr_vlslddev
                                                    ,DECODE(pr_idimpdps,'S',1,'N',0));
       pr_nrctrseg := r_crawseg.nrctrseg;
     EXCEPTION
       WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao INserir crapseg: '||SQLERRM;
        RAISE vr_exc_saida;
     END;
     
    EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar ROLLBACK
      -- ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- Efetuar ROLLBACK
      -- ROLLBACK;     
    END pc_efetiva_proposta_seguro_p;                                



BEGIN
  vr_contador:=0;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_INd_arquiv      --> hANDle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica---*
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqcsv        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_INd_arquiv2     --> hANDle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica---*
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_excsaida;
  END IF;

  vr_cdcooper:= 0;
  
  -- Cabecalho csv
  gene0001.pc_escr_linha_arquivo(vr_INd_arquiv2,  'Coop;Conta;Contrato_Emp;Contrato_Seg');  

  FOR rw_seguros IN cr_seguros LOOP
    
      -- Se mudou cooperativa vamos buscar o valor maximo 
      if vr_cdcooper <> rw_seguros.cdcooper THEN
        
        vr_cdcooper:= rw_seguros.cdcooper;
         
        -- Leitura dos valores de mínimo e máximo
        vr_vlmaximo := SUBSTR(tabe0001.fn_busca_dstextab(pr_cdcooper => rw_seguros.cdcooper,
                                                         pr_nmsistem => 'CRED',
                                                         pr_tptabela => 'USUARI',
                                                         pr_cdempres => 11,
                                                         pr_cdacesso => 'SEGPRESTAM',
                                                         pr_tpregist => 0),94,12);
      END if;
      
      --Validar necessidade de criação
      SEGU0003.pc_validar_prestamista(pr_cdcooper => rw_seguros.cdcooper
                                    , pr_nrdconta => rw_seguros.nrdconta
                                    , pr_nrctremp => rw_seguros.nrctrato
                                    , pr_cdagenci => 0
                                    , pr_nrdcaixa => 0
                                    , pr_cdoperad => 1
                                    , pr_nmdatela => 'Script'
                                    , pr_idorigem => 1
                                    , pr_valida_proposta => 'N' --Na efetivação da proposta o emprestimo já esta efetivado
                                    , pr_sld_devedor => vr_vlproposta
                                    , pr_flgprestamista => vr_flgprestamista
                                    , pr_flgdps => vr_flgdps
                                    , pr_dsmotcan =>  vr_dsmotcan
                                    , pr_cdcritic => vr_cdcritic
                                    , pr_dscritic => vr_dscritic);
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_excsaida;
      END IF;      
      
      IF vr_flgprestamista = 'S' THEN
        BEGIN
         ---'INcluir  crawseg' 
         OPEN cr_crawseq(pr_cdcooper1 => rw_seguros.cdcooper,
                         pr_nrdconta1 => rw_seguros.nrdconta,
                         pr_nrctrato1 => rw_seguros.nrctrato);
         FETCH cr_crawseq INTO rw_crawseq;
           
         IF cr_crawseq%FOUND THEN 
           CLOSE cr_crawseq;
         ELSE                
           CLOSE cr_crawseq; 
           vr_contador:= vr_contador + 1;
                  
           OPEN c_crawseg_prop(pr_cdcooper => rw_seguros.cdcooper,
                               pr_nrdconta => rw_seguros.nrdconta,
                               pr_nrctrato => rw_seguros.nrctrato);
           FETCH c_crawseg_prop INTO r_crawseg_prop;
           
           IF c_crawseg_prop%NOTFOUND THEN
             CLOSE c_crawseg_prop;
             pc_inserir_crawseg(pr_cdcooper   => rw_seguros.cdcooper,
                                pr_nrdconta   => rw_seguros.nrdconta,
                                pr_nrctrseg1  => rw_seguros.nrctrseg,
                                pr_nrctrato   => rw_seguros.nrctrato,
                                pr_vlseguro   => rw_seguros.vlproposta,
                                pr_nrctrseg   => vr_nrctrseg,                                  
                                pr_dtmvtolt   => rw_seguros.dtmvtolt ,
                                pr_dtdebito   => rw_seguros.dtmvtolt ,
                                pr_tpseguro   => rw_seguros.tpseguro , 
                                pr_cdsegura   => 514,
                                pr_nrcpfcgc   => rw_seguros.nrcpfcgc ,
                                pr_nmdsegur   => rw_seguros.nmprimtl ,
                                pr_dtinivig   => rw_seguros.dtinivig ,
                                pr_dtiniseg   => rw_seguros.dtinivig ,
                                pr_dtfimvig   => rw_seguros.dtfimvig ,
                                pr_cdcalcul   => rw_seguros.cdcalcul ,
                                pr_tpplaseg   => rw_seguros.tpplaseg + 1,
                                pr_dtprideb   => rw_seguros.dtmvtolt ,
                                pr_flgunica   => rw_seguros.flgunica ,
                                pr_dsENDres   => rw_seguros.dsendres ,
                                pr_nrENDres   => rw_seguros.nrendres ,
                                pr_nmbairro   => rw_seguros.nmbairro ,
                                pr_nmcidade   => rw_seguros.nmcidade ,
                                pr_cdufresd   => rw_seguros.cdufresd ,
                                pr_nrcepEND   => rw_seguros.nrcepend ,
                                pr_complEND   => rw_seguros.complend ); 
                                    
                 IF vr_dscritic IS NOT NULL THEN
                    RAISE vr_excsaida;
                 END IF;            
                 
                 BEGIN                  
                   UPDATE crawseg 
                      set nrproposta = rw_seguros.nrproposta 
                    WHERE cdcooper = rw_seguros.cdcooper 
                      AND nrdconta = rw_seguros.nrdconta                                                
                      AND NRCTRSEG = vr_nrctrseg;
                 EXCEPTION
                     WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao atualizar numero de proposta crawseg: '||
                                           rw_seguros.nrctrato;
                          RAISE vr_excsaida;
                 END;

                -- Gerar ROLLBACK                     
                vr_linha := 'DELETE crawseg WHERE cdcooper = '||rw_seguros.cdcooper ||
                                            ' AND nrdconta = '||rw_seguros.nrdconta ||
                                            ' AND nrctrseg = '||vr_nrctrseg   ||';';        
                gene0001.pc_escr_linha_arquivo(vr_INd_arquiv,  vr_lINha);        
           ELSE
             CLOSE c_crawseg_prop;
             vr_nrctrseg:= r_crawseg_prop.nrctrseg;
           END if;
             
              -- Gerar lINha arquivo csv                 
              gene0001.pc_escr_linha_arquivo(vr_INd_arquiv2, rw_seguros.cdcooper ||';'||
                                                             rw_seguros.nrdconta ||';'||
                                                             rw_seguros.nrctrato ||';'||
                                                             vr_nrctrseg );
              BEGIN 
                 UPDATE tbseg_prestamista 
                    SET nrctrseg = vr_nrctrseg
                  WHERE cdapolic = rw_seguros.cdapolic;        
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar numero contrato na tbseg_prestamista : '||
                                 rw_seguros.nrctrato;
                RAISE vr_excsaida;
              END;           

              -- Gerar ROLLBACK     
              vr_lINha := ' UPDATE tbseg_prestamista SET nrctrseg = '||rw_seguros.nrctrseg ||
                                        ' WHERE cdapolic = ' ||rw_seguros.cdapolic ||';';        
              gene0001.pc_escr_linha_arquivo(vr_INd_arquiv,  vr_lINha);    
                     
              -- Verificar se deve imprimir dps
              IF rw_seguros.saldo_devedor > vr_vlmaximo THEN
                vr_gerdps := 'S';
              ELSE
                vr_gerdps:= 'N';
              END IF; 
                    
             --incluir na crapseg              
             pc_efetiva_proposta_seguro_p(pr_cdcooper => rw_seguros.cdcooper
                                        , pr_nrdconta => rw_seguros.nrdconta
                                        , pr_nrctrato => rw_seguros.nrctrato
                                        , pr_cdoperad => '1'
                                        , pr_cdagenci => 1
                                        , pr_vlslddev => rw_seguros.vlproposta
                                        , pr_idimpdps => vr_gerdps
                                        , pr_dtINivig => rw_seguros.dtINivig
                                        , pr_nrctrseg => vr_nrctrseg 
                                        , pr_cdcritic => vr_cdcritic
                                        , pr_dscritic => vr_dscritic);
                                             
             --Se ocorreu erro                     
             IF vr_dscritic IS NOT NULL THEN      
               RAISE vr_excsaida;
             END IF;
                  
            -- Gerar ROLLBACK                  
            vr_lINha := 'DELETE crapseg WHERE cdcooper = '||rw_seguros.cdcooper  ||
                                        ' AND nrdconta = '||rw_seguros.nrdconta   ||
                                        ' AND nrctrseg = '||vr_nrctrseg   ||
                                        ' AND tpseguro = 4' ||';'; 
                                                     
            gene0001.pc_escr_linha_arquivo(vr_INd_arquiv,  vr_lINha);                 
                  
            commit;
         END if;         
       EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Erro ao atualizar gerar proposta contrato: '||
                          rw_seguros.nrctrato || ':' || SQLERRM;
           RAISE vr_excsaida;
       END;
     END IF;
  END LOOP;
  
  commit;
  -- Gerar commit no arquivo de ROLLBACK
  gene0001.pc_escr_linha_arquivo(vr_INd_arquiv,'commit;');
  -- Fechar hANDle dos arquivos abetos
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_INd_arquiv); --> HANDle do arquivo de ROLLBACK aberto
  gene0001.pc_escr_linha_arquivo(vr_INd_arquiv2,  vr_lINha); --> HANDle do arquivo csv aberto  

  vr_dscritic := 'SUCESSO -> Registros inseridos: '|| vr_contador;
EXCEPTION
  WHEN vr_excsaida THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_INd_arquiv); --> HANDle do arquivo aberto;
    gene0001.pc_escr_linha_arquivo(vr_INd_arquiv2,  vr_lINha); --> HANDle do arquivo csv aberto
    vr_dscritic := 'ERRO ' || vr_dscritic;
    ROLLBACK;
END;
/
