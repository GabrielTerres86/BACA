Declare
  vr_contador number;  
  vr_excsaida EXCEPTION;
  vr_cdcritic number;
  vr_dscritic varchar2(2000);
  vr_linha varchar2(2000);
  vr_nrctrseg number;
  vr_rootmicros      VARCHAR2(4000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0079160';
  vr_nmarqimp        VARCHAR2(100)  := 'INC0079160_ROLLBACK.txt';
  vr_ind_arquiv utl_file.file_type;  
  cursor cr_seguros is
      Select a.cdcooper
           , a.nrdconta
           , a.nrctrseg
           , a.nrctremp  
           , a.nrctremp nrctrato 
           , a.vlsdeved vlproposta 
           , a.nrproposta   
           , a.cdapolic
           , to_date(a.dtinivig,'DD/MM/RRRR') dtinivig
           , SUM( a.vldevatu) OVER(PARTITION BY a.cdcooper, a.nrdconta )  Saldo_Devedor
           , to_number(substr(( SELECT dstextab
                                          from craptab b
                                         where b.cdcooper = a.cdcooper
                                           and b.cdempres = 11
                                           and b.nmsistem = 'CRED'
                                           AND b.tptabela = 'USUARI'
                                           and b.cdacesso = 'SEGPRESTAM'
                                           and b.tpregist = 0),
                                        94,
                                        12)) vlmaximo
        from tbseg_prestamista a
        where tpregist in (1,3) and not exists (select 1 from crapseg pseg, crawseg wseg 
                                               where wseg.tpseguro = 4
                                                 and pseg.cdcooper = wseg.cdcooper
                                                 AND pseg.nrdconta = wseg.nrdconta
                                                 AND pseg.nrctrseg = wseg.nrctrseg                                            
                                                 and a.cdcooper = wseg.cdcooper
                                                 AND a.nrdconta = wseg.nrdconta
                                                 and a.nrctremp =  wseg.nrctrato )                                              
  order by cdcooper, nrdconta desc, 1 desc;
   rw_seguros cr_seguros%rowtype;
  
  vr_existeDir number := 0;
  vr_gerdps varchar2(1);
     
  cursor cr_crawseq(pr_cdcooper1 crapseg.cdcooper%type,
                    pr_nrdconta1 crapseg.nrdconta%type,
                    pr_nrctrseg1 crapseg.nrctrseg%type ) is 
      select wseg.nrdconta
            ,wseg.nrctrseg 
            ,wseg.dtmvtolt 
            ,wseg.dtdebito 
            ,wseg.tpseguro 
            ,wseg.cdsegura 
            ,wseg.nrcpfcgc 
            ,wseg.nmdsegur 
            ,wseg.dtinivig 
            ,wseg.dtiniseg 
            ,wseg.dtfimvig 
            ,wseg.vlpremio 
            ,wseg.vlpreseg 
            ,wseg.cdcalcul 
            ,wseg.tpplaseg 
            ,wseg.vlseguro 
            ,wseg.dtprideb 
            ,wseg.flgunica 
            ,wseg.dsendres 
            ,wseg.nrendres 
            ,wseg.nmbairro 
            ,wseg.nmcidade 
            ,wseg.cdufresd 
            ,wseg.nrcepend 
            ,wseg.complend
            ,pseg.cdoperad
            ,pseg.cdagenci 
            from crapseg pseg, crawseg wseg 
           where wseg.tpseguro = 4
             and pseg.cdcooper = wseg.cdcooper
             AND pseg.nrdconta = wseg.nrdconta
             AND pseg.nrctrseg = wseg.nrctrseg                                            
             and pseg.cdcooper = pr_cdcooper1 
             and pseg.nrdconta = pr_nrdconta1
             and pseg.nrctrseg <> pr_nrctrseg1;
        rw_crawseq cr_crawseq%rowtype;     

   
   procedure pc_inserir_crawseg( pr_cdcooper IN crawseg.cdcooper%type
                                ,pr_nrdconta IN crawseg.nrdconta%type                                
                                ,pr_nrctrseg1 IN crawseg.nrctrseg%type
                                ,pr_nrctrato IN crawseg.nrctrato%type
                                ,pr_vlseguro IN crawseg.vlseguro%type
                                ,pr_nrctrseg OUT crawseg.nrctrseg%type
                                ,pr_dtmvtolt crawseg.dtmvtolt%type
                                ,pr_dtdebito crawseg.dtdebito%type
                                ,pr_tpseguro crawseg.tpseguro%type
                                ,pr_cdsegura crawseg.cdsegura%type
                                ,pr_nrcpfcgc crawseg.nrcpfcgc%type
                                ,pr_nmdsegur crawseg.nmdsegur%type
                                ,pr_dtinivig crawseg.dtinivig%type
                                ,pr_dtiniseg crawseg.dtiniseg%type
                                ,pr_dtfimvig crawseg.dtfimvig%type
                                ,pr_cdcalcul crawseg.cdcalcul%type
                                ,pr_tpplaseg crawseg.tpplaseg%type
                                ,pr_dtprideb crawseg.dtprideb%type
                                ,pr_flgunica crawseg.flgunica%type
                                ,pr_dsendres crawseg.dsendres%type
                                ,pr_nrendres crawseg.nrendres%type
                                ,pr_nmbairro crawseg.nmbairro%type
                                ,pr_nmcidade crawseg.nmcidade%type
                                ,pr_cdufresd crawseg.cdufresd%type
                                ,pr_nrcepend crawseg.nrcepend%type
                                ,pr_complend crawseg.complend%type                                                                 
                               ) is                               
                               
            
     begin            
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
            ( pr_dtmvtolt ,
              pr_dtdebito ,
              pr_nrdconta ,
              vr_nrctrseg,
              pr_tpseguro, 
              pr_cdsegura ,
              pr_nrcpfcgc ,
              pr_nmdsegur ,
              pr_dtinivig ,
              pr_dtiniseg ,
              pr_dtfimvig ,
              pr_vlseguro ,
              pr_vlseguro,
              pr_cdcalcul ,
              pr_tpplaseg ,
              pr_vlseguro ,
              pr_dtprideb ,
              pr_flgunica ,
              pr_dsendres ,
              pr_nrendres ,
              pr_nmbairro ,
              pr_nmcidade ,
              pr_cdufresd ,
              pr_nrcepend ,
              pr_cdcooper ,
              pr_nrctrato ,
              pr_complend 
              );
            pr_nrctrseg := vr_nrctrseg ;
      
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
            vr_dscritic:= 'Erro ao inserir registro na crawseg. '||sqlerrm;
            --Levantar Excecao
            dbms_output.put_line(vr_dscritic);
            raise_application_error(-20001,vr_dscritic)  ;
        END;
       
     end pc_inserir_crawseg;   
     
     PROCEDURE pc_efetiva_proposta_seguro_p(pr_cdcooper in crapcop.cdcooper%type,
                                           pr_nrdconta in crapass.nrdconta%type,
                                           pr_nrctrato in crawseg.nrctrato%type,
                                           pr_cdoperad in crapope.cdoperad%type,
                                           pr_cdagenci in crapseg.cdagenci%type,
                                           pr_vlslddev in crapseg.vlslddev%type,
                                           pr_idimpdps in varchar2,
                                           pr_dtinivig in crapseg.dtinivig%type,
                                           pr_nrctrseg OUT crapseg.nrctrseg%TYPE,
                                           pr_cdcritic out crapcri.cdcritic%type,    --> Codigo da critica
                                           pr_dscritic out crapcri.dscritic%type) IS --> Descricao da critica

                                                                                          
    cursor c_crawseg is
    select s.*
      from crawseg s
     where s.tpseguro = 4
       and s.cdcooper = pr_cdcooper
       and s.nrdconta = pr_nrdconta
       and s.nrctrato = pr_nrctrato
       and not exists (select 1 
                         from crapseg p
                        where s.cdcooper = p.cdcooper
                          and s.nrdconta = p.nrdconta
                          and s.tpseguro = p.tpseguro
                          and s.nrctrseg = p.nrctrseg);   
    r_crawseg c_crawseg%rowtype;

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;       
    
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);      
                                           
    BEGIN 
      
     open c_crawseg;
      fetch c_crawseg into r_crawseg;
     close c_crawseg;
     
     -- Leitura do calendário da cooperativa
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
    
     begin
       insert into crapseg(crapseg.cdcooper,
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
                                                    ,1 -- tpendcor -- Residencial
                                                    ,r_crawseg.flgconve
                                                    ,r_crawseg.tpdpagto
                                                    ,r_crawseg.vlpremio
                                                    ,pr_cdoperad
                                                    ,pr_cdagenci
                                                    ,sysdate
                                                    ,pr_vlslddev
                                                    ,decode(pr_idimpdps,'S',1,'N',0));
       pr_nrctrseg := r_crawseg.nrctrseg;
     exception
       when others then
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao inserir crapseg: '||sqlerrm;
        RAISE vr_exc_saida;
     end;
     
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
      -- Efetuar rollback
      -- ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      -- ROLLBACK;     
    END pc_efetiva_proposta_seguro_p;                                

BEGIN

begin
  vr_contador:=0;
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica---*
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_excsaida;
  END IF;

  FOR rw_seguros IN cr_seguros LOOP
    vr_contador:= vr_contador + 1;
      BEGIN
       ---'Incluir  crawseg' 
       open cr_crawseq(pr_cdcooper1 => rw_seguros.cdcooper,
                       pr_nrdconta1 => rw_seguros.nrdconta,
                       pr_nrctrseg1 => rw_seguros.nrctrseg);
       fetch cr_crawseq into rw_crawseq;
         
       if cr_crawseq%notfound then 
         close cr_crawseq;
       else                
         close cr_crawseq;
                                         
               pc_inserir_crawseg(pr_cdcooper => rw_seguros.cdcooper,
                                  pr_nrdconta => rw_seguros.nrdconta,
                                  pr_nrctrseg1 => rw_seguros.nrctrseg,
                                  pr_nrctrato => rw_seguros.nrctrato,
                                  pr_vlseguro => rw_seguros.vlproposta,
                                  pr_nrctrseg => vr_nrctrseg,                                  
                                  pr_dtmvtolt => rw_crawseq.dtmvtolt ,
                                  pr_dtdebito => rw_crawseq.dtdebito ,
                                  pr_tpseguro => rw_crawseq.tpseguro , 
                                  pr_cdsegura => 514,
                                  pr_nrcpfcgc => rw_crawseq.nrcpfcgc ,
                                  pr_nmdsegur => rw_crawseq.nmdsegur ,
                                  pr_dtinivig => rw_seguros.dtinivig ,
                                  pr_dtiniseg => rw_crawseq.dtiniseg ,
                                  pr_dtfimvig => rw_crawseq.dtfimvig ,
                                  pr_cdcalcul => rw_crawseq.cdcalcul ,
                                  pr_tpplaseg => rw_crawseq.tpplaseg ,
                                  pr_dtprideb => rw_crawseq.dtprideb ,
                                  pr_flgunica => rw_crawseq.flgunica ,
                                  pr_dsendres => rw_crawseq.dsendres ,
                                  pr_nrendres => rw_crawseq.nrendres ,
                                  pr_nmbairro => rw_crawseq.nmbairro ,
                                  pr_nmcidade => rw_crawseq.nmcidade ,
                                  pr_cdufresd => rw_crawseq.cdufresd ,
                                  pr_nrcepend => rw_crawseq.nrcepend ,
                                  pr_complend => rw_crawseq.complend ); 
                                  
               IF vr_dscritic IS NOT NULL THEN
                  RAISE vr_excsaida;
               END IF;
                 
              BEGIN 
                 UPDATE tbseg_prestamista 
                    set nrctrseg = vr_nrctrseg
                  where cdapolic = rw_seguros.cdapolic;        
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar numero contrato na tbseg_prestamista : '||
                                 rw_seguros.nrctrato;
                RAISE vr_excsaida;
              END;                
              vr_linha := ' UPDATE tbseg_prestamista set nrctrseg = '||rw_seguros.nrctrseg ||
                                        ' where cdapolic = ' ||rw_seguros.cdapolic ||';';        
              gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,  vr_linha);    
                       
              BEGIN                  
                 UPDATE crawseg 
                    set nrproposta = rw_seguros.nrproposta 
                  where cdcooper = rw_seguros.cdcooper 
                    and nrdconta = rw_seguros.nrdconta                                                
                    and NRCTRSEG = vr_nrctrseg;
              EXCEPTION
                 WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar numero de proposta crawseg: '||
                                       rw_seguros.nrctrato;
                      RAISE vr_excsaida;
              END;
                
              vr_linha := 'delete crawseg where cdcooper = '||rw_seguros.cdcooper  ||
                                          ' and nrdconta = '||rw_seguros.nrdconta   ||
                                          ' and nrctrato = '||rw_seguros.nrctrato   ||';';        
              gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,  vr_linha);                                                             
                 
              if rw_seguros.saldo_devedor > rw_seguros.vlmaximo then
                vr_gerdps := 'S';
              else
                vr_gerdps:= 'N';
              end if; 
                
             --Incluir na crapseg              
             pc_efetiva_proposta_seguro_p(pr_cdcooper => rw_seguros.cdcooper
                                        , pr_nrdconta => rw_seguros.nrdconta
                                        , pr_nrctrato => rw_seguros.nrctrato
                                        , pr_cdoperad => rw_crawseq.cdoperad
                                        , pr_cdagenci => rw_crawseq.cdagenci
                                        , pr_vlslddev => rw_seguros.vlproposta
                                        , pr_idimpdps => vr_gerdps
                                        , pr_dtinivig => rw_seguros.dtinivig
                                        , pr_nrctrseg => vr_nrctrseg 
                                        , pr_cdcritic => vr_cdcritic
                                        , pr_dscritic => vr_dscritic);
                                         
             --Se ocorreu erro                     
             IF vr_dscritic IS NOT NULL THEN      
               RAISE vr_excsaida;
             END IF;
              
            vr_linha := 'delete crapseg where cdcooper = '||rw_seguros.cdcooper  ||
                                        ' and nrdconta = '||rw_seguros.nrdconta   ||
                                        ' and nrctrseg = '||vr_nrctrseg   ||
                                        ' and tpseguro = '||rw_crawseq.tpseguro   ||';'; 
                                                 
            gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,  vr_linha);                 
              
            commit;            
       end if;         
     EXCEPTION
       WHEN OTHERS THEN
         vr_dscritic := 'Erro ao atualizar gerar proposta contrato: '||
                        rw_seguros.nrctrato;
         RAISE vr_excsaida;
     END;
  END LOOP;
   
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;
  vr_dscritic := 'SUCESSO -> Registros inseridos: '|| vr_contador;
EXCEPTION
  WHEN vr_excsaida then
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;
    vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
end;

end;
