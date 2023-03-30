DECLARE
    
    vr_pemorte     CECRED.tbseg_prestamista.pemorte%TYPE;
    vr_peinvalidez CECRED.tbseg_prestamista.peinvalidez%TYPE;
    vr_peiftttaxa  CECRED.tbseg_prestamista.peiftttaxa%TYPE;
    vr_qtifttdias  CECRED.tbseg_prestamista.qtifttdias%TYPE;            
    vr_vlpielimit  CECRED.tbseg_prestamista.vlpielimit%TYPE;
    vr_vlifttlimi  CECRED.tbseg_prestamista.vlifttlimi%TYPE;
    vr_cdcritic    CECRED.crapcri.cdcritic%TYPE;
    vr_dscritic    CECRED.crapcri.dscritic%TYPE;
    
    vr_vlcapmor   NUMBER;
    vr_vlpremor   NUMBER;
    vr_vlpreinv   NUMBER;
    vr_vlpretot   NUMBER;
    vr_vlpreiof   NUMBER;
    vr_vlpreliq   NUMBER;
    vr_vlpreperda NUMBER;
    
    vr_apolice    CECRED.tbseg_parametros_prst.nrapolic%TYPE;
    vr_pgtosegu   CECRED.tbseg_parametros_prst.pagsegu%TYPE;
    vr_vlparcel   NUMBER;
    vr_idadecoop  NUMBER;
    
    vr_ind_arq    utl_file.file_type;
    vr_linha      VARCHAR2(32767);
    vr_nmdir      VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0258772';
    vr_nmarq      VARCHAR2(100)  := 'ROLLBACK_INC0258772.sql';
    vr_exc_saida  EXCEPTION;
    
    CURSOR cr_prestamista(pr_cdcooper   IN CECRED.tbseg_prestamista.cdcooper%TYPE
                         ,pr_nrproposta IN CECRED.tbseg_prestamista.nrproposta%TYPE) IS
      SELECT p.cdcooper,
             p.nrdconta,
             p.nrctremp,
             p.nrctrseg,
             p.dtnasctl,
             p.dtinivig,
             p.dtfimvig,
             p.vlprodut,
             p.pemorte,
             p.peinvalidez,
             p.peiftttaxa,
             p.qtifttdias,             
             p.vlpielimit,
             p.vlifttlimi,
             p.idseqtra
        FROM CECRED.tbseg_prestamista p
       WHERE p.cdcooper = pr_cdcooper
         AND p.nrproposta = pr_nrproposta;
    
    CURSOR cr_crawseg(pr_cdcooper IN CECRED.crawseg.cdcooper%TYPE
                     ,pr_nrdconta IN CECRED.crawseg.nrdconta%TYPE
                     ,pr_nrctrseg IN CECRED.crawseg.nrctrseg%TYPE
                     ,pr_nrctremp IN CECRED.crawseg.nrctrato%TYPE) IS
      SELECT w.flggarad
            ,w.flfinanciasegprestamista
            ,w.vlseguro
            ,w.vlpremio
            ,w.progress_recid
        FROM CECRED.crawseg w
       WHERE w.cdcooper = pr_cdcooper
         AND w.nrdconta = pr_nrdconta
         AND w.nrctrseg = pr_nrctrseg
         AND w.nrctrato = pr_nrctremp
         AND w.tpseguro = 4;
    rw_crawseg cr_crawseg%ROWTYPE;
    
    CURSOR cr_crapseg(pr_cdcooper IN CECRED.crapseg.cdcooper%TYPE
                     ,pr_nrdconta IN CECRED.crapseg.nrdconta%TYPE
                     ,pr_nrctrseg IN CECRED.crapseg.nrctrseg%TYPE) IS
      SELECT s.vlpremio
            ,s.vlslddev
            ,s.progress_recid
        FROM CECRED.crapseg s
       WHERE s.cdcooper = pr_cdcooper
         AND s.nrdconta = pr_nrdconta
         AND s.nrctrseg = pr_nrctrseg
         AND s.tpseguro = 4;
    rw_crapseg cr_crapseg%ROWTYPE;
    
    CURSOR cr_crawepr(pr_cdcooper IN CECRED.crawepr.cdcooper%TYPE
                     ,pr_nrdconta IN CECRED.crawepr.nrdconta%TYPE
                     ,pr_nrctremp IN CECRED.crawepr.nrctremp%TYPE) IS
      SELECT w.vlpreemp
            ,w.qtpreemp
        FROM CECRED.crawepr w
       WHERE w.cdcooper = pr_cdcooper
         AND w.nrdconta = pr_nrdconta
         AND w.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;

  PROCEDURE pc_valida_direto(pr_nmdireto IN  VARCHAR2,
                             pr_dscritic OUT CECRED.crapcri.dscritic%TYPE) IS
    vr_dscritic  CECRED.crapcri.dscritic%TYPE;
    vr_typ_saida VARCHAR2(3);
    vr_des_saida VARCHAR2(1000);
    vr_exc_erro  EXCEPTION;
    BEGIN
      IF NOT CECRED.gene0001.fn_exis_diretorio(pr_nmdireto) THEN

        CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' ||
                                                             pr_nmdireto ||
                                                             ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);

        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;

        CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                             pr_nmdireto ||
                                                             ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);

        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'PERMISSAO NO DIRETORIO -> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;
    
  BEGIN

    pc_valida_direto(pr_nmdireto => vr_nmdir,
                     pr_dscritic => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                                   ,pr_nmarquiv => vr_nmarq
                                   ,pr_tipabert => 'W'
                                   ,pr_utlfileh => vr_ind_arq
                                   ,pr_des_erro => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
       vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '|| vr_nmdir || vr_nmarq;
       RAISE vr_exc_saida;
    END IF;

    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');

    FOR rw_prestamista IN cr_prestamista(pr_cdcooper   => 9
                                        ,pr_nrproposta => '202302407679') LOOP
    
      vr_idadecoop := TRUNC(MONTHS_BETWEEN(rw_prestamista.dtinivig,rw_prestamista.dtnasctl) / 12, 0);
    
      BEGIN
        SELECT cob.gbsegmin, cob.gbsegmax
          INTO vr_pemorte, vr_peinvalidez
          FROM tbseg_param_prst_tax_cob cob,
               tbseg_parametros_prst    prst
         WHERE prst.cdcooper = rw_prestamista.cdcooper
           AND prst.tppessoa = 1
           AND prst.cdsegura = 514
           AND prst.tpcustei = 0
           AND prst.idseqpar = cob.idseqpar
           AND vr_idadecoop BETWEEN cob.gbidamin and cob.gbidamax;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := SQLERRM || ' - ' || dbms_utility.format_error_backtrace;
          RAISE vr_exc_saida;
      END;
                                        
      vr_peiftttaxa  := rw_prestamista.peiftttaxa;
      vr_qtifttdias  := rw_prestamista.qtifttdias;            
      vr_vlpielimit  := rw_prestamista.vlpielimit;
      vr_vlifttlimi  := rw_prestamista.vlifttlimi;
      
      OPEN cr_crawseg(pr_cdcooper => rw_prestamista.cdcooper
                     ,pr_nrdconta => rw_prestamista.nrdconta
                     ,pr_nrctrseg => rw_prestamista.nrctrseg
                     ,pr_nrctremp => rw_prestamista.nrctremp);
        FETCH cr_crawseg INTO rw_crawseg;
        IF cr_crawseg%NOTFOUND THEN
          vr_dscritic := 'Não foi possível localizar proposta de seguro contributario.';
          RAISE vr_exc_saida;
        END IF;
      CLOSE cr_crawseg;
      
      OPEN cr_crapseg(pr_cdcooper => rw_prestamista.cdcooper
                     ,pr_nrdconta => rw_prestamista.nrdconta
                     ,pr_nrctrseg => rw_prestamista.nrctrseg);
        FETCH cr_crapseg INTO rw_crapseg;
        IF cr_crapseg%NOTFOUND THEN
          vr_dscritic := 'Não foi possível localizar contrato do seguro contributario.';
          RAISE vr_exc_saida;
        END IF;
      CLOSE cr_crapseg;
      
      OPEN cr_crawepr(pr_cdcooper => rw_prestamista.cdcooper
                       ,pr_nrdconta => rw_prestamista.nrdconta
                       ,pr_nrctremp => rw_prestamista.nrctremp);
        FETCH cr_crawepr INTO rw_crawepr;
        IF cr_crawepr%NOTFOUND THEN
          vr_dscritic := 'Não foi possível localizar proposta de emprestimo.';
          RAISE vr_exc_saida;
        END IF;
      CLOSE cr_crawepr;
      
      IF rw_crawseg.flggarad = 1 AND rw_crawseg.flfinanciasegprestamista = 1 THEN
        
        CECRED.segu0003.pc_ret_parc_sem_seg(pr_cdcooper                 => rw_prestamista.cdcooper
                                           ,pr_nrdconta                 => rw_prestamista.nrdconta
                                           ,pr_nrctremp                 => rw_prestamista.nrctremp
                                           ,pr_flggarad                 => rw_crawseg.flggarad
                                           ,pr_flfinanciasegprestamista => rw_crawseg.flfinanciasegprestamista
                                           ,pr_vlseguro                 => rw_crawseg.vlseguro
                                           ,pr_nmdatela                 => 'SEGU0003'
                                           ,pr_vlparcel                 => vr_vlparcel);
      
      ELSE      
        vr_vlparcel := rw_crawepr.vlpreemp;
      END IF;   
      
      CECRED.segu0003.pc_retorna_valores_contributario(pr_cdcooper    => rw_prestamista.cdcooper       
                                                      ,pr_nrdconta    => rw_prestamista.nrdconta        
                                                      ,pr_nrctremp    => rw_prestamista.nrctremp        
                                                      ,pr_nrctrseg    => rw_prestamista.nrctrseg        
                                                      ,pr_dtnascsg    => rw_prestamista.dtnasctl        
                                                      ,pr_vlpreemp    => vr_vlparcel        
                                                      ,pr_qtpreemp    => rw_crawepr.qtpreemp        
                                                      ,pr_flggarad    => rw_crawseg.flggarad
                                                      ,pr_dtinivig    => rw_prestamista.dtinivig        
                                                      ,pr_dtfimvig    => rw_prestamista.dtfimvig        
                                                      ,pr_flefetivada => 'N'                
                                                      ,pr_pemorte     => vr_pemorte         
                                                      ,pr_peinvalidez => vr_peinvalidez     
                                                      ,pr_peiftttaxa  => vr_peiftttaxa      
                                                      ,pr_qtifttdias  => vr_qtifttdias      
                                                      ,pr_pielimit    => vr_vlpielimit      
                                                      ,pr_ifttlimi    => vr_vlifttlimi      
                                                      ,pr_apolice     => vr_apolice         
                                                      ,pr_pgtosegu    => vr_pgtosegu        
                                                      ,pr_vlsdeved    => vr_vlcapmor        
                                                      ,pr_vlpremor    => vr_vlpremor        
                                                      ,pr_vlpreinv    => vr_vlpreinv        
                                                      ,pr_preperda    => vr_vlpreperda      
                                                      ,pr_vlpreliq    => vr_vlpreliq        
                                                      ,pr_vlpreiof    => vr_vlpreiof        
                                                      ,pr_vlpretot    => vr_vlpretot        
                                                      ,pr_cdcritic    => vr_cdcritic        
                                                      ,pr_dscritic    => vr_dscritic);      
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      vr_linha :=    ' UPDATE CECRED.crawseg p   '
                  || '    SET p.vlpremio    = ' || REPLACE(rw_crawseg.vlpremio,',','.')
                  || '  WHERE p.progress_recid = ' || rw_crawseg.progress_recid || ';';

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
      
      BEGIN
        UPDATE CECRED.crawseg w
          SET w.vlpremio = vr_vlpretot
        WHERE w.progress_recid = rw_crawseg.progress_recid;
      EXCEPTION WHEN OTHERS THEN
        vr_dscritic := 'Não foi possível atualizar crawseg.';
        RETURN;
      END;
      
      vr_linha :=    ' UPDATE CECRED.crapseg p   '
                  || '    SET p.vlpremio    = ' || REPLACE(rw_crapseg.vlpremio,',','.')
                  || '  WHERE p.progress_recid = ' || rw_crapseg.progress_recid || ';';

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
      
      BEGIN
        UPDATE CECRED.crapseg p
          SET p.vlpremio   = vr_vlpretot
        WHERE p.progress_recid = rw_crapseg.progress_recid;
      EXCEPTION WHEN OTHERS THEN
        vr_dscritic := 'Não foi possível atualizar crapseg.';
        RETURN;
      END;
      
      vr_linha :=    ' UPDATE CECRED.tbseg_prestamista p   '
                  || '    SET p.vlprodut    = ' || REPLACE(rw_prestamista.vlprodut,',','.')
                  || '       ,p.pemorte     = ' || REPLACE(rw_prestamista.pemorte,',','.')
                  || '       ,p.peinvalidez = ' || REPLACE(rw_prestamista.peinvalidez,',','.')
                  || '  WHERE p.idseqtra = ' || rw_prestamista.idseqtra || ';';

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
      
      BEGIN
        UPDATE CECRED.tbseg_prestamista p
          SET p.vlprodut    = vr_vlpretot,
              p.pemorte     = vr_pemorte,
              p.peinvalidez = vr_peinvalidez
        WHERE p.idseqtra = rw_prestamista.idseqtra;
      EXCEPTION WHEN OTHERS THEN
        vr_dscritic := 'Não foi possível atualizar tbseg_prestamista.';
        RETURN;
      END;
    END LOOP;
    
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
    CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
    
    COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
         vr_dscritic := vr_dscritic || ' ' || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
         dbms_output.put_line(vr_dscritic);
         CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_dscritic);
         ROLLBACK;
    WHEN OTHERS THEN
         vr_dscritic := vr_dscritic || ' ' || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
         dbms_output.put_line(vr_dscritic);
         CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_dscritic);
         ROLLBACK;
  END;
/
