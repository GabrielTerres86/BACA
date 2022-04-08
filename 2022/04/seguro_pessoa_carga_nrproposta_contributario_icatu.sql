DECLARE
  vr_listadir     VARCHAR2(2000);
  vr_dscritic     VARCHAR2(2000);
  vr_tab_nmarqtel GENE0002.typ_split;
  vr_contareg     NUMBER(9);
  vr_nrdlinha     NUMBER(9);
  vr_dslinhaarq   VARCHAR2(2000);
  vr_arqhandle    utl_file.file_type;
  vr_nmdirrec     VARCHAR2(2000);
  vr_nmarqmov     VARCHAR2(2000) := 'nrproposta_contributario_icatu.txt';
  vr_nrproposta   VARCHAR2(200);
  vr_nrlinha      NUMBER;
  vr_flexists     NUMBER;
  
  CURSOR cr_seg_nrproposta(pr_nrproposta IN VARCHAR) IS
    SELECT 1
      FROM tbseg_nrproposta p
     WHERE p.nrproposta = pr_nrproposta;
BEGIN
  vr_nmdirrec := gene0001.fn_diretorio(pr_tpdireto => 'C', --/usr/coop
                                        pr_cdcooper => 3);

  vr_nmdirrec := vr_nmdirrec || '/arq/prj0022983'; 
  
  gene0001.pc_lista_Arquivos(pr_path     => vr_nmdirrec 
                            ,pr_pesq     => vr_nmarqmov
                            ,pr_listarq  => vr_listadir
                            ,pr_des_erro => vr_dscritic);

  vr_tab_nmarqtel := GENE0002.fn_quebra_string(pr_string => vr_listadir);

  IF vr_tab_nmarqtel.count <= 0 THEN
    RETURN;
  END IF;

  FOR idx IN 1..vr_tab_nmarqtel.count
  LOOP
    vr_contareg := 0;
    vr_nrdlinha := 0;

    vr_nmarqmov := vr_tab_nmarqtel(idx);

    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirrec||'/'
                            ,pr_nmarquiv => vr_nmarqmov
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_arqhandle
                            ,pr_des_erro => vr_dscritic );                     
    vr_nrlinha := 0;
    LOOP
      BEGIN
        vr_nrlinha := vr_nrlinha + 1;  
        BEGIN
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arqhandle
                                      ,pr_des_text => vr_dslinhaarq );   
        EXCEPTION 
            WHEN OTHERS THEN
              vr_dslinhaarq := '';
              dbms_output.put_line(SQLERRM);
        END;      
                                               
        IF NVL(TRIM(vr_dslinhaarq),' ') = ' ' THEN
          EXIT;
        END IF;
            
        vr_dslinhaarq  := REPLACE(vr_dslinhaarq,'"','');
        vr_nrproposta  := REPLACE(substr(gene0002.fn_busca_entrada(1,vr_dslinhaarq,';'),1,15),',00','');
        
        OPEN cr_seg_nrproposta(pr_nrproposta => vr_nrproposta);
          FETCH cr_seg_nrproposta INTO vr_flexists;
          IF cr_seg_nrproposta%NOTFOUND THEN
            INSERT INTO tbseg_nrproposta(nrproposta,tpcustei) VALUES (vr_nrproposta,0);
          END IF;
        CLOSE cr_seg_nrproposta;
      END;
    END LOOP;
  END LOOP;
  COMMIT;
END;
/
