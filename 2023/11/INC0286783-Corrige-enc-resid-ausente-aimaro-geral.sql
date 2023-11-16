DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0286783_dados.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'INC0286783_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'INC0286783_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  vr_log                VARCHAR2(8000);
  
  vr_dscritic           VARCHAR2(4000);
  vr_exception          EXCEPTION;
  
  vr_comments           VARCHAR2(2000);
  
  CURSOR cr_erros IS
    select t.nrcpfcgc
      , a.cdsitdct
      , a.dtadmiss
      , a.dtdemiss
      , a.cdcooper
      , a.nrdconta
      , t.idseqttl
      , e.ROWID     ROWID_ENDERECO
    from CECRED.crapttl t
    left join CECRED.crapenc e on t.cdcooper = e.cdcooper
                                and t.nrdconta = e.nrdconta
                                and t.idseqttl = e.idseqttl
                                and e.tpendass = 10
    join CECRED.crapass a on t.cdcooper = a.cdcooper
                             and t.nrdconta = a.nrdconta
    join CECRED.crapcop c on a.cdcooper = c.cdcooper
    where a.cdsitdct not in (3,4)
      and e.cdcooper is null
      and c.flgativo = 1
    order by t.nrcpfcgc;

  rg_erros   cr_erros%ROWTYPE;
  
  CURSOR cr_pessoa_end (pr_cpf IN CECRED.Tbcadast_Pessoa.NRCPFCGC%TYPE) IS
    SELECT p.nrcpfcgc
      , e.*
      , m.dscidade
      , m.cdestado
    FROM CECRED.tbcadast_pessoa          p
    JOIN CECRED.Tbcadast_Pessoa_endereco e on p.idpessoa = e.idpessoa
    LEFT JOIN CECRED.crapmun             m ON e.idcidade = m.idcidade
    WHERE p.nrcpfcgc = pr_cpf
      AND e.tpendereco = 10;

  rg_pessoa_end   cr_pessoa_end%ROWTYPE;
  
  CURSOR cr_crapenc (pr_cpf_ttl    IN CECRED.crapttl.NRCPFCGC%TYPE
                   , pr_cta_notin  IN CECRED.crapttl.NRDCONTA%TYPE
                   , pr_cop_notin  IN CECRED.crapttl.CDCOOPER%TYPE) IS
    SELECT E.*
    FROM CECRED.crapttl t
    JOIN CECRED.crapenc e on t.cdcooper = e.cdcooper
                             AND t.nrdconta = e.nrdconta
                             AND t.idseqttl = e.idseqttl
    JOIN CECRED.crapass a on t.cdcooper = a.cdcooper
                             and t.nrdconta = a.nrdconta
    JOIN CECRED.crapcop c on a.cdcooper = c.cdcooper
    WHERE t.nrcpfcgc = pr_cpf_ttl
      AND a.cdsitdct not in (3,4)
      AND c.flgativo = 1
      AND e.tpendass = 10
      AND (
          t.nrdconta <> pr_cta_notin
          AND t.cdcooper <> pr_cop_notin
      );

  rg_crapenc  cr_crapenc%ROWTYPE;
  
  CURSOR cr_next_cdseqinc (pr_cooper    IN CECRED.crapenc.CDCOOPER%TYPE
                         , pr_conta     IN CECRED.crapenc.NRDCONTA%TYPE
                         , pr_seqttl    IN CECRED.crapenc.IDSEQTTL%TYPE) IS 
    SELECT ( MAX( NVL(cdseqinc, 0) ) + 1 ) cdseqinc
    FROM CECRED.crapenc ec
    WHERE ec.cdcooper = pr_cooper
      AND ec.nrdconta = pr_conta
      AND ec.idseqttl = pr_seqttl;
  
  
  PROCEDURE insereEndereco( pr_coop_inc     IN CECRED.crapenc.CDCOOPER%TYPE
                          , pr_cta_inc      IN CECRED.crapenc.NRDCONTA%TYPE
                          , pr_seqttl_inc   IN CECRED.crapenc.IDSEQTTL%TYPE
                          , pr_rgcrapenc    IN CECRED.crapenc%ROWTYPE
                          , pr_dscritic     OUT VARCHAR2 ) IS
    
    vr_cdseqinc  CECRED.crapenc.CDSEQINC%TYPE;
    vr_rowid_enc ROWID;
    vr_dsmodule  VARCHAR2(100);
    
  BEGIN
    
    vr_comments := ' ## PROCEDURE QUE FARÁ O INSERT NA CRAPENC.';
    
    vr_cdseqinc  := NULL;
    vr_rowid_enc := NULL;
    
    OPEN cr_next_cdseqinc(rg_erros.cdcooper, rg_erros.nrdconta, rg_erros.idseqttl);
    FETCH cr_next_cdseqinc INTO vr_cdseqinc;
    CLOSE cr_next_cdseqinc;
    
    IF NVL(vr_cdseqinc, -1) = -1 THEN
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ';' || pr_coop_inc || ';' || pr_cta_inc || ';' || NVL(vr_cdseqinc, 1) || ';ALERTA **;Encontrado registro sem endereço e sem sequencial na CRAPENC: cop, ' || 
                                                    pr_coop_inc || ' - cta, ' || 
                                                    pr_cta_inc  || ' - seqttl, ' || 
                                                    pr_seqttl_inc || ' - seq enc, ' || 
                                                    NVL(vr_cdseqinc, 1) );
      
    END IF;
    
    vr_comments := 'Inicializa sessão do Centralizado para NÃO deixar as triggers do Aimaro rodarem em Loop.';
    CADA0016.pc_sessao_trigger( pr_tpmodule => 1,
                                pr_dsmodule => vr_dsmodule);
    
    BEGIN
          
      INSERT INTO CECRED.crapenc (
        cdcooper
        , nrdconta
        , idseqttl
        , tpendass
        , cdseqinc
        , dsendere
        , nrendere
        , complend
        , nmbairro
        , nmcidade
        , cdufende
        , nrcepend
        , incasprp
        , nranores
        , vlalugue
        , nrcxapst
        , dtaltenc
        , dtinires
        , nrdoapto
        , cddbloco
        , idorigem
      ) VALUES (
        pr_coop_inc
        , pr_cta_inc
        , pr_seqttl_inc
        , 10
        , NVL(vr_cdseqinc, 1)
        , NVL(pr_rgcrapenc.dsendere, ' ')
        , NVL(pr_rgcrapenc.nrendere, 0)
        , NVL(pr_rgcrapenc.complend, ' ')
        , NVL(pr_rgcrapenc.nmbairro, ' ')
        , NVL(pr_rgcrapenc.nmcidade, ' ')
        , NVL(pr_rgcrapenc.cdufende, ' ')
        , NVL(pr_rgcrapenc.nrcepend, 0)
        , NVL(pr_rgcrapenc.incasprp, 0)
        , NVL(pr_rgcrapenc.nranores, 0)
        , NVL(pr_rgcrapenc.vlalugue, 0)
        , NVL(pr_rgcrapenc.nrcxapst, 0)
        , pr_rgcrapenc.dtaltenc
        , pr_rgcrapenc.dtinires
        , NVL(pr_rgcrapenc.nrdoapto, 0)
        , NVL(pr_rgcrapenc.cddbloco, ' ')
        , NVL(pr_rgcrapenc.idorigem, 2)
      ) RETURNING ROWID INTO vr_rowid_enc;
      
      pr_dscritic := NULL;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  DELETE CECRED.crapenc WHERE ROWID = ''' || vr_rowid_enc || '''; ');
          
    EXCEPTION
      WHEN OTHERS THEN
            
        pr_dscritic := 'Erro ao incluir novo endereço: ' || SQLERRM;
            
    END;
    
    vr_comments := 'Finaliza sessao do cadastro centralizado.';
    CADA0016.pc_sessao_trigger( pr_tpmodule => 2,
                                pr_dsmodule => vr_dsmodule);
    
  END;

BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0286783';
  
  vr_count_file := 0;
  vr_seq_file   := 1;
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp || LPAD(vr_seq_file, 3, '0') || '.sql'
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqlog
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arqlog
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Início: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  
  OPEN cr_erros;
  LOOP
    FETCH cr_erros INTO rg_erros;
    EXIT WHEN cr_erros%NOTFOUND;
    
    rg_pessoa_end := NULL;
    OPEN cr_pessoa_end (rg_erros.nrcpfcgc);
    FETCH cr_pessoa_end INTO rg_pessoa_end;
    
    vr_dscritic := NULL;
    vr_log := rg_erros.nrcpfcgc || ';' ||
              rg_erros.cdcooper || ';' ||
              rg_erros.nrdconta || ';' ||
              rg_erros.idseqttl || ';';
    
    IF cr_pessoa_end%NOTFOUND THEN
      
      vr_log := vr_log || 'ALERTA 1;Endereço na TBCADAST_PESSOA_ENDERECO não encontrado.;';
      
      rg_crapenc := NULL;
      
      OPEN cr_crapenc(rg_erros.nrcpfcgc, rg_erros.nrdconta, rg_erros.cdcooper);
      FETCH cr_crapenc INTO rg_crapenc;
      
      IF cr_crapenc%NOTFOUND THEN
        
        vr_log := vr_log || 'ALERTA 2;Endereço na CRAPENC não encontrado.';
        
      ELSE
        
        vr_comments := 'Inclui endereço faltante do cooperado com base em algum encontrado em outra conta dele.';
        
        insereEndereco( pr_coop_inc     => rg_erros.cdcooper
                      , pr_cta_inc      => rg_erros.nrdconta
                      , pr_seqttl_inc   => rg_erros.idseqttl
                      , pr_rgcrapenc    => rg_crapenc
                      , pr_dscritic     => vr_dscritic);
        
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          
          vr_log := vr_log || 'ERRO 2;Erro ao inserir endereço com dados da CRAPENC: ' || vr_dscritic;
          
        ELSE
          
          vr_log := vr_log || 'Sucesso 2;Endereço encontrado CRAPENC';
          
        END IF;
        
        vr_log := vr_log || '. Dados de origem: Coop. | Cta: | SeqTtl. '
                  || rg_crapenc.cdcooper || ' | ' 
                  || rg_crapenc.nrdconta || ' | ' 
                  || rg_crapenc.idseqttl;
        
      END IF;
      
      CLOSE cr_crapenc;
      
    ELSE
      
      rg_crapenc := NULL;
      
      rg_crapenc.dsendere := NVL(rg_pessoa_end.nmlogradouro, ' ');
      rg_crapenc.nrendere := NVL(rg_pessoa_end.nrlogradouro, 0);
      rg_crapenc.complend := NVL(rg_pessoa_end.dscomplemento, ' ');
      rg_crapenc.nmbairro := NVL(rg_pessoa_end.nmbairro, ' ');
      rg_crapenc.nmcidade := NVL(rg_pessoa_end.dscidade, ' ');
      rg_crapenc.cdufende := NVL(rg_pessoa_end.cdestado, ' ');
      rg_crapenc.nrcepend := NVL(rg_pessoa_end.nrcep, 0);
      rg_crapenc.incasprp := NVL(rg_pessoa_end.tpimovel, 0);
      rg_crapenc.vlalugue := NVL(rg_pessoa_end.vldeclarado, 0);
      rg_crapenc.dtaltenc := rg_pessoa_end.dtalteracao;
      rg_crapenc.dtinires := rg_pessoa_end.dtinicio_residencia;
      rg_crapenc.idorigem := NVL(rg_pessoa_end.tporigem_cadastro, 2);
      
      vr_comments := 'Inclui endereço faltante do cooperado com base no cadastro centralizado.';
        
      insereEndereco( pr_coop_inc     => rg_erros.cdcooper
                    , pr_cta_inc      => rg_erros.nrdconta
                    , pr_seqttl_inc   => rg_erros.idseqttl
                    , pr_rgcrapenc    => rg_crapenc
                    , pr_dscritic     => vr_dscritic);
      
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        
        vr_log := vr_log || 'ERRO 1;Erro ao inserir endereço encontrado TBCADAST_PESSOA_ENDERECO. ' || vr_dscritic;
        
      ELSE
        
        vr_log := vr_log || 'Sucesso 1;Endereço encontrado TBCADAST_PESSOA_ENDERECO e aplicado na CRAPENC.';
        
      END IF;
      
    END IF;
    
    CLOSE cr_pessoa_end;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_log);
    
  END LOOP;
  
  CLOSE cr_erros;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS'));
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;

EXCEPTION
  WHEN vr_exception THEN
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' COMMIT;');
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO AO EXECUTAR O SCRIPT: ' 
                                                  || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') 
                                                  || ' - ' || vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20001, 'ERRO Tratado: ' || vr_dscritic);
    
  WHEN OTHERS THEN
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' COMMIT;');
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NÃO TRATADO EXECUTAR O SCRIPT: ' 
                                                  || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') 
                                                  || ' - ERRO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20001, 'ERRO GERAL: ' || SQLERRM);
    
END;
