DECLARE
    vr_dslinhaarq     VARCHAR2(2000);
    vr_tprecusa       VARCHAR2(20);
    vr_cpf            VARCHAR2(200);
    vr_nrproposta     tbseg_prestamista.nrproposta%TYPE;
    vr_nrcontrato     VARCHAR2(200);
    vr_datastr        VARCHAR2(200);
    vr_dtinivig       DATE;
    vr_dtdvenda       DATE;
    vr_nmdirrec       VARCHAR2(2000);
    vr_nmarqmov       VARCHAR2(2000);
    vr_nmarq          VARCHAR2(2000);
    vr_dscritic       VARCHAR2(2000);
    vr_nrlinha        NUMBER(9);
    vr_index          NUMBER;
    vr_produto        VARCHAR2(200);
    vr_cdcooper       tbseg_prestamista.cdcooper%TYPE;
    vr_exc_saida      EXCEPTION;
    vr_arqhandle      utl_file.file_type;
    vr_ind_arq        utl_file.file_type;
    vr_linha          VARCHAR2(32767);
      
    TYPE typ_reg_arq IS RECORD(nrcontrato     VARCHAR2(200),
                               nrproposta     VARCHAR2(200),
                               dtinivig       DATE,
                               dtdvenda       DATE,
                               cdcooper       NUMBER);
                               
    --Definicao dos tipos de tabelas
    TYPE typ_tab_arquiv IS TABLE OF typ_reg_arq INDEX BY VARCHAR2(50);
    
    vr_faturamento_tab typ_tab_arquiv ;
    vr_recusado_tab    typ_tab_arquiv ;
    
    CURSOR cr_crawseg(pr_cdcooper   IN crawseg.cdcooper%TYPE
                     ,pr_nrdconta   IN crawseg.nrdconta%TYPE
                     ,pr_nrctrato   IN crawseg.nrctrato%TYPE
                     ,pr_nrproposta IN crawseg.nrproposta%TYPE) IS
      SELECT x.nrctrseg,
             x.nrdconta,
             x.dtinivig,
             x.nrproposta,
             x.progress_recid
        FROM (SELECT c.nrctrseg,
                     c.nrdconta,
                     c.dtinivig,
                     c.nrproposta,
                     c.progress_recid
                FROM crawseg c
               WHERE c.cdcooper   = pr_cdcooper
                 AND c.nrdconta   = pr_nrdconta
                 AND c.nrctrato   = pr_nrctrato
                 AND c.nrproposta = pr_nrproposta
                 AND c.tpseguro   = 4
            ORDER BY c.progress_recid DESC) x
       WHERE ROWNUM = 1;
    rw_crawseg cr_crawseg%ROWTYPE;
    
    CURSOR cr_seg_prestamista(pr_cdcooper   IN tbseg_prestamista.cdcooper%TYPE
                             ,pr_nrctremp   IN tbseg_prestamista.nrctremp%TYPE
                             ,pr_nrproposta IN tbseg_prestamista.nrproposta%TYPE) IS
     SELECT p.idseqtra,
            p.nrdconta,
            p.nrctrseg, 
            p.dtinivig,
            p.dtdevend,
            p.nrproposta
       FROM tbseg_prestamista p
      WHERE p.cdcooper   = pr_cdcooper
        AND p.nrctremp   = pr_nrctremp
        AND p.nrproposta = pr_nrproposta;
     rw_seg_prestamista cr_seg_prestamista%ROWTYPE;
    
BEGIN
   BEGIN
     vr_nmdirrec := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0108910';
     vr_nmarqmov := 'ailos_vigencia_futura_092021.csv';
     vr_nmarq    := 'ROLLBACK_INC0108910.sql';
     gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirrec
                             ,pr_nmarquiv => vr_nmarqmov
                             ,pr_tipabert => 'R'
                             ,pr_utlfileh => vr_arqhandle
                             ,pr_des_erro => vr_dscritic );

     IF vr_dscritic IS NOT NULL THEN
         vr_dscritic  := 'Erro na abertura do arquivo --> '|| vr_nmdirrec||'/' ||vr_nmarqmov ||' --> '||vr_dscritic ;
         RAISE vr_exc_saida;
     END IF;
     
     vr_nrlinha := 0;
     LOOP
         vr_nrlinha := vr_nrlinha + 1;
         BEGIN
           gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arqhandle
                                       ,pr_des_text => vr_dslinhaarq );
         EXCEPTION
           WHEN OTHERS THEN
           vr_dslinhaarq := '';
         END;

         IF nvl(TRIM(vr_dslinhaarq),' ') = ' ' THEN
           EXIT;
         END IF;
         
         vr_dslinhaarq := replace (vr_dslinhaarq,'"','');
         
         vr_cpf        := gene0002.fn_busca_entrada(1,vr_dslinhaarq,';');
         vr_nrcontrato := gene0002.fn_busca_entrada(2,vr_dslinhaarq,';');
         vr_tprecusa   := UPPER(gene0002.fn_busca_entrada(15,vr_dslinhaarq,';'));
         vr_nrproposta := gene0002.fn_busca_entrada(7,vr_dslinhaarq,';');
         vr_produto    := gene0002.fn_busca_entrada(10,vr_dslinhaarq,';');
         
         -- Localizando cdcooper
         SELECT lpad(decode(vr_produto , 1,5,  2,7,  3,10,  4,11,  5,14, 6 ,9, 7,16
                                                , 8,2  ,9,8 ,10, 6, 11,12, 12,13, 13,1      )   ,6,'0')
           INTO vr_cdcooper
           FROM dual ;
         
         -- Tratamento campo data venda
         vr_datastr    := gene0002.fn_busca_entrada(8,vr_dslinhaarq,';');
         vr_datastr    := TRIM(vr_datastr);
         vr_datastr    := REPLACE(vr_datastr,'/','');
         vr_datastr    := REPLACE(vr_datastr,'-','');
         vr_dtdvenda  := to_date(vr_datastr,'ddmmrrrr');
         
         -- Tratamento campo data inicio
         vr_datastr    := gene0002.fn_busca_entrada(9,vr_dslinhaarq,';');
         vr_datastr    := TRIM(vr_datastr);
         vr_datastr    := REPLACE(vr_datastr,'/','');
         vr_datastr    := REPLACE(vr_datastr,'-','');
         vr_dtinivig  := to_date(vr_datastr,'ddmmrrrr');
         
         -- Criando index da tabela
         vr_index      := vr_cpf || vr_nrcontrato;
         
         -- Gravando na tabela temporário os registros da planilha
         IF vr_tprecusa = 'RECUSADO' THEN
           vr_recusado_tab(vr_index).nrcontrato := vr_nrcontrato;
           vr_recusado_tab(vr_index).nrproposta := vr_nrproposta;
           vr_recusado_tab(vr_index).dtinivig   := vr_dtinivig;
           vr_recusado_tab(vr_index).dtdvenda   := vr_dtdvenda;           
           vr_recusado_tab(vr_index).cdcooper   := vr_cdcooper;
         ELSE
           vr_faturamento_tab(vr_index).nrcontrato := vr_nrcontrato;
           vr_faturamento_tab(vr_index).nrproposta := vr_nrproposta;
           vr_faturamento_tab(vr_index).dtinivig   := vr_dtinivig;
           vr_faturamento_tab(vr_index).dtdvenda   := vr_dtdvenda;
           vr_faturamento_tab(vr_index).cdcooper   := vr_cdcooper;
         END IF;
     END LOOP;
     
     GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirrec
                              ,pr_nmarquiv => vr_nmarq
                              ,pr_tipabert => 'W'
                              ,pr_utlfileh => vr_ind_arq
                              ,pr_des_erro => vr_dscritic);
                              
     IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '||vr_nmdirrec || vr_nmarq;
        RAISE vr_exc_saida;
     END IF;

     GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');
     
     -- Pecorrendo os recusados para atualizar
     vr_index := vr_recusado_tab.FIRST;
     WHILE (vr_index IS NOT NULL) LOOP
       -- Localizndo seguro prestamista
       OPEN cr_seg_prestamista(pr_cdcooper   => vr_recusado_tab(vr_index).cdcooper
                              ,pr_nrctremp   => vr_recusado_tab(vr_index).nrcontrato
                              ,pr_nrproposta => vr_recusado_tab(vr_index).nrproposta);
         FETCH cr_seg_prestamista INTO rw_seg_prestamista;
           IF cr_seg_prestamista%FOUND THEN             
             OPEN cr_crawseg(pr_cdcooper   => vr_recusado_tab(vr_index).cdcooper
                            ,pr_nrdconta   => rw_seg_prestamista.nrdconta
                            ,pr_nrctrato   => vr_recusado_tab(vr_index).nrcontrato
                            ,pr_nrproposta => vr_recusado_tab(vr_index).nrproposta);
               FETCH cr_crawseg INTO rw_crawseg;
                 IF cr_crawseg%FOUND THEN
                   -- Gerando Arquivo de Rollback crawseg
                   vr_linha :=
                       '  UPDATE crawseg ' ||
                       '     SET nrproposta = ' || rw_crawseg.nrproposta ||
                       '        ,dtinivig   = TO_DATE('''||rw_crawseg.dtinivig || ''',''DD/MM/RRRR'')' ||
                       '   WHERE PROGRESS_RECID = '|| rw_crawseg.progress_recid ||';  ';
                   gene0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
                   
                   -- Atualizando crawseg
                   UPDATE crawseg 
                      SET nrproposta =  vr_faturamento_tab(vr_index).nrproposta
                         ,dtinivig   =  vr_faturamento_tab(vr_index).dtinivig
                   WHERE progress_recid = rw_crawseg.progress_recid;
                   
                   -- Gerando Arquivo de Rollback tbseg_prestamista            
                   vr_linha :=
                      '  UPDATE tbseg_prestamista '||
                      '     SET nrproposta = ' || rw_seg_prestamista.nrproposta ||
                      '        ,nrctrseg   = ' || rw_seg_prestamista.nrctrseg   ||
                      '        ,dtdevend   = TO_DATE('''|| rw_seg_prestamista.dtdevend   ||''',''DD/MM/RRRR'')'||
                      '        ,dtinivig   = TO_DATE('''|| rw_seg_prestamista.dtinivig   ||''',''DD/MM/RRRR'')'||
                      ' WHERE idseqtra    = '|| rw_seg_prestamista.idseqtra||' ;';
                   gene0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha); 
                 
                   -- Atualizando tbseg_prestamista
                   UPDATE tbseg_prestamista
                      SET nrctrseg    = nvl(rw_crawseg.nrctrseg,nrctrseg)
                         ,nrproposta  = vr_faturamento_tab(vr_index).nrproposta
                         ,dtdevend    = vr_faturamento_tab(vr_index).dtdvenda
                         ,dtinivig    = vr_faturamento_tab(vr_index).dtinivig
                    WHERE idseqtra = rw_seg_prestamista.idseqtra;
                 ELSE
                   vr_dscritic := 'Crawseg não localizado! cdcooper = ' || vr_recusado_tab(vr_index).cdcooper 
                                                    || ' nrcontrato = ' || vr_recusado_tab(vr_index).nrcontrato
                                                    || ' nrproposta = ' || vr_recusado_tab(vr_index).nrproposta;
                   dbms_output.put_line(vr_dscritic);
                 END IF;
             CLOSE cr_crawseg;
           ELSE
             vr_dscritic := 'Seg_Prestamista não localizado! cdcooper = '   || vr_recusado_tab(vr_index).cdcooper 
                                                        || ' nrctremp = '   || vr_recusado_tab(vr_index).nrcontrato
                                                        || ' nrproposta = ' || vr_recusado_tab(vr_index).nrproposta;
             dbms_output.put_line(vr_dscritic);
           END IF;
       CLOSE cr_seg_prestamista;
       vr_index := vr_recusado_tab.NEXT(vr_index);
     END LOOP;
     
     BEGIN
       -- Arquivo de rollback
       gene0001.pc_escr_linha_arquivo(vr_ind_arq,' UPDATE tbseg_prestamista p '||
                                                 '    SET p.tpregist = 3      '||
                                                 '  WHERE p.cdcooper = 5      '||
                                                 '    AND p.nrdconta = 247642 '||
                                                 '    AND p.nrctrseg = 25369  '||
                                                 '    AND p.nrproposta = ''770357234964'';');
            
       -- Voltar o tpregist da nrproposta (770357234964) da tbseg_prestammista para "1";
       UPDATE tbseg_prestamista p
          SET p.tpregist = 1
        WHERE p.cdcooper = 5
          AND p.nrdconta = 247642
          AND p.nrctrseg = 25369
          AND p.nrproposta = '770357234964';
     EXCEPTION WHEN OTHERS THEN
       vr_dscritic := 'Erro na atualização tpregist da nrproposta (770357234964) da tbseg_prestammista para "1": ' || SQLERRM;
       RAISE vr_exc_saida;
       ROLLBACK;
     END;

     gene0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
     gene0001.pc_escr_linha_arquivo(vr_ind_arq,' EXCEPTION ');
     gene0001.pc_escr_linha_arquivo(vr_ind_arq,'  WHEN OTHERS THEN ');
     gene0001.pc_escr_linha_arquivo(vr_ind_arq,'   ROLLBACK;');
     gene0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
     gene0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );

     COMMIT;
   EXCEPTION
     WHEN vr_exc_saida THEN
       ROLLBACK;
     WHEN OTHERS THEN
       vr_dscritic := 'Erro Geral: ' || SQLERRM;
       ROLLBACK;
   END;
  
   IF vr_dscritic IS NOT NULL THEN
     dbms_output.put_line(vr_dscritic);
   END IF;
END;
/
