DECLARE
    vr_dslinhaarq     VARCHAR2(2000);
    vr_nrproposta     tbseg_prestamista.nrproposta%TYPE;
    vr_nmrescop       VARCHAR2(20);
    vr_nmdirrec       VARCHAR2(2000);
    vr_nmarqmov       VARCHAR2(2000);
    vr_nmarq          VARCHAR2(2000);
    vr_dscritic       VARCHAR2(2000);
    vr_nrlinha        NUMBER(9);
    vr_index          NUMBER := 0;
    vr_cdcooper       tbseg_prestamista.cdcooper%TYPE;
    vr_exc_saida      EXCEPTION;
    vr_arqhandle      utl_file.file_type;
    vr_ind_arq        utl_file.file_type;
    vr_linha          VARCHAR2(32767);

    TYPE typ_reg_arq IS RECORD(nrproposta tbseg_prestamista.nrproposta%TYPE,
                               cdcooper   tbseg_prestamista.cdcooper%TYPE);

    --Definicao dos tipos de tabelas
    TYPE typ_tab_arquiv IS TABLE OF typ_reg_arq INDEX BY VARCHAR2(50);

    vr_typ_tab_arquiv typ_tab_arquiv;   

    CURSOR cr_seg_prestamista(pr_cdcooper   IN tbseg_prestamista.cdcooper%TYPE
                             ,pr_nrproposta IN tbseg_prestamista.nrproposta%TYPE) IS
     SELECT p.idseqtra,
            p.nrproposta,
            p.tpregist
       FROM tbseg_prestamista p
      WHERE p.cdcooper   = pr_cdcooper
        AND p.nrproposta = pr_nrproposta;
     rw_seg_prestamista cr_seg_prestamista%ROWTYPE;
     
   CURSOR cr_crapcop(pr_nmrescop IN crapcop.nmrescop%TYPE) IS
     SELECT c.cdcooper
       FROM crapcop c
      WHERE c.nmrescop = pr_nmrescop;
      
   CURSOR cr_crawseg(pr_cdcooper   IN crawseg.cdcooper%TYPE
                    ,pr_nrproposta IN crawseg.nrproposta%TYPE) IS
     SELECT w.progress_recid,
            w.nrproposta
       FROM crawseg w
      WHERE w.cdcooper   = pr_cdcooper
        AND w.nrproposta = pr_nrproposta;
     rw_crawseg cr_crawseg%ROWTYPE;

BEGIN
   BEGIN
     vr_nmdirrec := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0119662';
     vr_nmarqmov := 'INC0119662_centralizada.csv';
     vr_nmarq    := 'ROLLBACK_INC0119662.sql';
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

         vr_nrproposta := TRIM(gene0002.fn_busca_entrada(3,vr_dslinhaarq,';'));
         vr_nmrescop   := TRIM(gene0002.fn_busca_entrada(5,vr_dslinhaarq,';'));

         -- Localizando cdcooper
         OPEN cr_crapcop(pr_nmrescop => vr_nmrescop);
           FETCH cr_crapcop INTO vr_cdcooper;
           IF cr_crapcop%NOTFOUND THEN
             CLOSE cr_crapcop;
             CONTINUE;
           END IF;
         CLOSE cr_crapcop;

         -- Gravando na tabela temporário os registros da planilha
         vr_typ_tab_arquiv(vr_index).nrproposta := vr_nrproposta;
         vr_typ_tab_arquiv(vr_index).cdcooper   := vr_cdcooper;
         vr_index := vr_index + 1;
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
     vr_index := vr_typ_tab_arquiv.FIRST;
     WHILE (vr_index IS NOT NULL) LOOP
       -- Localizndo seguro prestamista
       OPEN cr_seg_prestamista(pr_cdcooper   => vr_typ_tab_arquiv(vr_index).cdcooper
                              ,pr_nrproposta => vr_typ_tab_arquiv(vr_index).nrproposta);
         FETCH cr_seg_prestamista INTO rw_seg_prestamista;
         
           -- Gerando um novo numero de proposta
           vr_nrproposta := segu0003.FN_NRPROPOSTA;
         
           IF cr_seg_prestamista%FOUND THEN
             OPEN cr_crawseg(pr_cdcooper   => vr_typ_tab_arquiv(vr_index).cdcooper
                            ,pr_nrproposta => vr_typ_tab_arquiv(vr_index).nrproposta);
               FETCH cr_crawseg INTO rw_crawseg;
                 IF cr_crawseg%FOUND THEN
                   -- Gerando Arquivo de Rollback crawseg
                   vr_linha :=
                       '  UPDATE crawseg ' ||
                       '     SET nrproposta = ' || rw_crawseg.nrproposta ||
                       '   WHERE progress_recid = '|| rw_crawseg.progress_recid ||';  ';
                   gene0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

                   -- Atualizando crawseg
                   UPDATE crawseg
                      SET nrproposta =  vr_nrproposta
                    WHERE progress_recid = rw_crawseg.progress_recid;

                   -- Gerando Arquivo de Rollback tbseg_prestamista
                   vr_linha :=
                      '  UPDATE tbseg_prestamista '||
                      '     SET nrproposta = ' || rw_seg_prestamista.nrproposta ||
                      '        ,tpregist   = ' || rw_seg_prestamista.tpregist ||
                      '   WHERE idseqtra   = '|| rw_seg_prestamista.idseqtra||' ;';
                   gene0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

                   -- Atualizando tbseg_prestamista
                   UPDATE tbseg_prestamista
                      SET nrproposta  = vr_nrproposta,
                          tpregist    = 1
                    WHERE idseqtra = rw_seg_prestamista.idseqtra;
                 ELSE
                   vr_dscritic := 'Crawseg não localizado! cdcooper = ' || vr_typ_tab_arquiv(vr_index).cdcooper
                                                    || ' nrproposta = ' || vr_typ_tab_arquiv(vr_index).nrproposta;
                   dbms_output.put_line(vr_dscritic);
                 END IF;
             CLOSE cr_crawseg;
           ELSE
             vr_dscritic := 'Seg_Prestamista não localizado! cdcooper = '   || vr_typ_tab_arquiv(vr_index).cdcooper
                                                        || ' nrproposta = ' || vr_typ_tab_arquiv(vr_index).nrproposta;
             dbms_output.put_line(vr_dscritic);
           END IF;
       CLOSE cr_seg_prestamista;
       vr_index := vr_typ_tab_arquiv.NEXT(vr_index);
     END LOOP;

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
