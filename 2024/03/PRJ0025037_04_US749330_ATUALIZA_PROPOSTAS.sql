DECLARE
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/PRJ0025037';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_PRJ0025037_US749330.sql';
  vr_exc_saida      EXCEPTION;

   CURSOR cr_principal IS
    select w.cdcooper, w.nrdconta, w.nrproposta, w.tpcustei, W.NRCTRATO, w.nrctrseg, w.dtinivig, w.dtfimvig,  r.vlsdeved
      from CECRED.crawseg w, CECRED.crapepr r
     where w.cdcooper = r.cdcooper
       and w.nrdconta = r.nrdconta
       and w.nrctrato = r.nrctremp
       and w.NRPROPOSTA is not null
       and r.inliquid = 0
       and r.vlsdeved > 0
       and w.TPCUSTEI = 1     
       and not exists (select 0
              from cecred.tbseg_prestamista p
             where p.cdcooper = w.cdcooper
               and p.nrdconta = w.nrdconta
               and p.nrctrseg = w.nrctrseg
               and p.nrctremp = w.nrctrato
               )
               ;
    vnumproposta cecred.tbseg_nrproposta.nrproposta%type;
    
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

      pc_valida_direto(pr_nmdireto => vr_nmdir, pr_dscritic => vr_dscritic);

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                                     ,pr_nmarquiv => vr_nmarq
                                     ,pr_tipabert => 'W'
                                     ,pr_utlfileh => vr_ind_arq
                                     ,pr_des_erro => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
         vr_dscritic := vr_dscritic ||'  N�o pode abrir arquivo '|| vr_nmdir || vr_nmarq;
         RAISE vr_exc_saida;
      END IF;

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');

   
        vr_linha := '';

        FOR rw_principal IN cr_principal LOOP
          
            vr_linha := 'UPDATE CECRED.CRAWSEG W SET W.NRPROPOSTA = '''|| rw_principal.Nrproposta   ||
                        ''' WHERE W.Cdcooper = ' || rw_principal.Cdcooper || 
                        ' AND W.NRDCONTA = ' || rw_principal.Nrdconta ||
                        ' AND W.Nrctrseg = ' || rw_principal.Nrctrseg ||
                        ' AND W.NRCTRATO = ' || rw_principal.NRCTRATO || ';';

            CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);

             SELECT p.nrproposta
               INTO vnumproposta 
               FROM cecred.tbseg_nrproposta p
              WHERE p.dhseguro IS NULL
                AND p.tpcustei = 1
                AND rownum = 1 FOR UPDATE;

            UPDATE CECRED.CRAWSEG W 
              SET W.NRPROPOSTA = vnumproposta  
            WHERE W.Cdcooper = rw_principal.Cdcooper 
              AND W.NRDCONTA = rw_principal.Nrdconta 
              AND W.Nrctrseg = rw_principal.Nrctrseg
              AND W.NRCTRATO = rw_principal.NRCTRATO;
              
             UPDATE cecred.tbseg_nrproposta
                SET dhseguro = SYSDATE
              WHERE nrproposta = vnumproposta;  
        END LOOP;        
     
      COMMIT;

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
      CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
    EXCEPTION
       WHEN vr_exc_saida THEN
            vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            dbms_output.put_line(vr_dscritic);
            ROLLBACK;
       WHEN OTHERS THEN
            vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            dbms_output.put_line(vr_dscritic);
            ROLLBACK;
    END;
