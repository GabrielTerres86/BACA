PL/SQL Developer Test script 3.0
732
-- Created on 01/12/2016 by F0030344 
-- .........................................................................
--
--  Programa : BACA
--  Sistema  : Cred
--  Autor    : Tiago
--  Data     : Dezembro/2016.                   Ultima atualizacao: 05/07/2017
--
--  Dados referentes ao programa:
--
--   Frequencia: Sempre que for chamado
--   Objetivo  : 
--   Alteração : 05/07/2017 - Incluido a exclusao da crapsdc (Tiago)
-------------------------------------------------------------------------------
DECLARE  
  TYPE typ_rec_contas IS RECORD(cdcooper crapass.cdcooper%TYPE
                               ,nrdconta crapass.nrdconta%TYPE
                               ,inpessoa crapass.inpessoa%TYPE
                               ,assrowid ROWID);
                               
  TYPE typ_tab_contas IS TABLE OF typ_rec_contas INDEX BY PLS_INTEGER;
  
  
  --crapass,--crapttl,--crapjur,--crapadm,--crapsld,--crapcot,--crapsda,--crapneg,--crapenc,--crapdoc,--craplgm,--crapsdc,--tbchq_param_conta
  TYPE typ_tab_ass IS TABLE OF crapass%ROWTYPE INDEX BY PLS_INTEGER;
  TYPE typ_tab_ttl IS TABLE OF crapttl%ROWTYPE INDEX BY PLS_INTEGER;
  TYPE typ_tab_jur IS TABLE OF crapjur%ROWTYPE INDEX BY PLS_INTEGER;
  TYPE typ_tab_adm IS TABLE OF crapadm%ROWTYPE INDEX BY PLS_INTEGER;
  TYPE typ_tab_sld IS TABLE OF crapsld%ROWTYPE INDEX BY PLS_INTEGER;
  TYPE typ_tab_cot IS TABLE OF crapcot%ROWTYPE INDEX BY PLS_INTEGER;
  TYPE typ_tab_sda IS TABLE OF crapsda%ROWTYPE INDEX BY PLS_INTEGER;
  TYPE typ_tab_neg IS TABLE OF crapneg%ROWTYPE INDEX BY PLS_INTEGER;
  TYPE typ_tab_enc IS TABLE OF crapenc%ROWTYPE INDEX BY PLS_INTEGER;
  TYPE typ_tab_doc IS TABLE OF crapdoc%ROWTYPE INDEX BY PLS_INTEGER;
  TYPE typ_tab_lgm IS TABLE OF craplgm%ROWTYPE INDEX BY PLS_INTEGER;  
  TYPE typ_tab_sdc IS TABLE OF crapsdc%ROWTYPE INDEX BY PLS_INTEGER;  
  TYPE typ_tab_cta IS TABLE OF tbchq_param_conta%ROWTYPE INDEX BY PLS_INTEGER;

  vr_tab_contas typ_tab_contas;
  vr_tab_ass  typ_tab_ass;
  vr_tab_ttl  typ_tab_ttl;
  vr_tab_jur  typ_tab_jur;
  vr_tab_adm  typ_tab_adm;
  vr_tab_sld  typ_tab_sld;
  vr_tab_cot  typ_tab_cot;
  vr_tab_sda  typ_tab_sda;
  vr_tab_neg  typ_tab_neg;  
  vr_tab_enc  typ_tab_enc;
  vr_tab_doc  typ_tab_doc;
  vr_tab_lgm  typ_tab_lgm;
  vr_tab_sdc  typ_tab_sdc;
  vr_tab_cta  typ_tab_cta;

  vr_nome_baca  VARCHAR2(100);
  vr_nmarqlog   VARCHAR2(100);
  vr_nmarqimp   VARCHAR2(100);
  vr_nmarqbkp   VARCHAR2(100);
  vr_ind_arquiv utl_file.file_type;
  vr_ind_arqlog utl_file.file_type;
  vr_dslinha    VARCHAR2(4000);                
  vr_nmdireto   VARCHAR2(4000);   
  vr_dscritic   VARCHAR2(4000);   
  vr_exc_erro   EXCEPTION;

  vr_cont INTEGER;
  vr_qtcontas INTEGER;
  
  vr_des_xml         CLOB; /*tiago declarar para cada delete*/
  vr_texto_completo  VARCHAR2(32600); /*tiago declarar para cada delete*/

--crapass,crapttl,crapjur,crapadm,crapsld,crapcot,crapsda,crapneg,crapenc,crapdoc,craplgm,crapsdc,tbchq_param_conta
  vr_qcrapass INTEGER;
  vr_qcrapttl INTEGER;
  vr_qcrapjur INTEGER;
  vr_qcrapadm INTEGER;
  vr_qcrapsld INTEGER;
  vr_qcrapcot INTEGER;
  vr_qcrapsda INTEGER;
  vr_qcrapneg INTEGER;
  vr_qcrapenc INTEGER;
  vr_qcrapdoc INTEGER;
  vr_qcraplgm INTEGER;
  vr_qcrapsdc INTEGER;
  vr_qprconta INTEGER;

  CURSOR cr_crapcop IS
    SELECT crapcop.cdcooper
          ,crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.flgativo = 1;
 
     
  CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT ROWID, ass.cdcooper, ass.nrdconta, ass.inpessoa
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.cdagenci = 0
       AND ass.dtadmiss >= '21/11/2016';

  FUNCTION fn_formata_data(pr_data DATE) RETURN VARCHAR2 IS
  BEGIN    
    RETURN 'TO_DATE('''||TO_CHAR(pr_data,'DD/MM/RRRR')||''','||'''DD/MM/RRRR'')';
  END;

  FUNCTION fn_formata_valor(pr_numero DECIMAL) RETURN VARCHAR2 IS
  BEGIN    
    RETURN TO_CHAR(NVL(pr_numero,0),'FM99999999990D00','NLS_NUMERIC_CHARACTERS=''.,''');
  END;
  
  PROCEDURE pc_deleta_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
                             ,pr_nrdconta IN crapttl.nrdconta%TYPE
                             ,pr_tab_ttl  IN OUT typ_tab_ttl) IS

    CURSOR cr_crapttl(pr_cdcooper crapttl.cdcooper%TYPE
                     ,pr_nrdconta crapttl.nrdconta%TYPE) IS
      SELECT * 
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta;
    
  BEGIN
    
    FOR rw_crapttl IN cr_crapttl(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP
        BEGIN
          
          DELETE 
            FROM crapttl 
           WHERE crapttl.cdcooper = rw_crapttl.cdcooper
             AND crapttl.nrdconta = rw_crapttl.nrdconta
             AND crapttl.idseqttl = rw_crapttl.idseqttl;
           
          IF SQL%ROWCOUNT > 0 THEN
             pr_tab_ttl(pr_tab_ttl.count) := rw_crapttl;
          END IF;
                
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
        END;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  PROCEDURE pc_deleta_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE
                             ,pr_nrdconta IN crapjur.nrdconta%TYPE
                             ,pr_tab_jur  IN OUT typ_tab_jur) IS

    CURSOR cr_crapjur(pr_cdcooper crapjur.cdcooper%TYPE
                     ,pr_nrdconta crapjur.nrdconta%TYPE) IS
      SELECT jur.* 
        FROM crapjur jur
       WHERE jur.cdcooper = pr_cdcooper
         AND jur.nrdconta = pr_nrdconta;
    
  BEGIN
    FOR rw_crapjur IN cr_crapjur(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP
        BEGIN
          
          DELETE 
            FROM crapjur 
           WHERE crapjur.cdcooper = rw_crapjur.cdcooper
             AND crapjur.nrdconta = rw_crapjur.nrdconta;           
           
          IF SQL%ROWCOUNT > 0 THEN
             pr_tab_jur(pr_tab_jur.count) := rw_crapjur;
          END IF;
 
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
        END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  PROCEDURE pc_deleta_crapadm(pr_cdcooper IN crapadm.cdcooper%TYPE
                             ,pr_nrdconta IN crapadm.nrdconta%TYPE
                             ,pr_tab_adm  IN OUT typ_tab_adm) IS

    CURSOR cr_crapadm(pr_cdcooper crapadm.cdcooper%TYPE
                     ,pr_nrdconta crapadm.nrdconta%TYPE) IS
      SELECT adm.* 
        FROM crapadm adm
       WHERE adm.cdcooper = pr_cdcooper
         AND adm.nrdconta = pr_nrdconta;
    
  BEGIN
    FOR rw_crapadm IN cr_crapadm(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP
        BEGIN
        
          DELETE 
            FROM crapadm 
           WHERE crapadm.cdcooper = rw_crapadm.cdcooper
             AND crapadm.nrmatric = rw_crapadm.nrmatric;
          
          IF SQL%ROWCOUNT > 0 THEN
             pr_tab_adm(pr_tab_adm.count) := rw_crapadm;
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
        END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  PROCEDURE pc_deleta_crapsld(pr_cdcooper IN crapsld.cdcooper%TYPE
                             ,pr_nrdconta IN crapsld.nrdconta%TYPE
                             ,pr_tab_sld  IN OUT typ_tab_sld) IS

    CURSOR cr_crapsld(pr_cdcooper crapsld.cdcooper%TYPE
                     ,pr_nrdconta crapsld.nrdconta%TYPE) IS
      SELECT sld.* 
        FROM crapsld sld
       WHERE sld.cdcooper = pr_cdcooper
         AND sld.nrdconta = pr_nrdconta;
    
  BEGIN
    FOR rw_crapsld IN cr_crapsld(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP
        BEGIN          
        
          DELETE 
            FROM crapsld 
           WHERE crapsld.cdcooper = rw_crapsld.cdcooper
             AND crapsld.nrdconta = rw_crapsld.nrdconta;

          IF SQL%ROWCOUNT > 0 THEN
             pr_tab_sld(pr_tab_sld.count) := rw_crapsld;
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
        END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  PROCEDURE pc_deleta_crapcot(pr_cdcooper IN crapcot.cdcooper%TYPE
                             ,pr_nrdconta IN crapcot.nrdconta%TYPE
                             ,pr_tab_cot  IN OUT typ_tab_cot) IS

    CURSOR cr_crapcot(pr_cdcooper crapcot.cdcooper%TYPE
                     ,pr_nrdconta crapcot.nrdconta%TYPE) IS
      SELECT cot.* 
        FROM crapcot cot
       WHERE cot.cdcooper = pr_cdcooper
         AND cot.nrdconta = pr_nrdconta;
    
  BEGIN
    FOR rw_crapcot IN cr_crapcot(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP
        BEGIN          
        
          DELETE 
            FROM crapcot 
           WHERE crapcot.cdcooper = rw_crapcot.cdcooper
             AND crapcot.nrdconta = rw_crapcot.nrdconta;
               
          IF SQL%ROWCOUNT > 0 THEN
             pr_tab_cot(pr_tab_cot.count) := rw_crapcot;
          END IF;
                  
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
        END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  PROCEDURE pc_deleta_crapsda(pr_cdcooper IN crapsda.cdcooper%TYPE
                             ,pr_nrdconta IN crapsda.nrdconta%TYPE
                             ,pr_tab_sda  IN OUT typ_tab_sda) IS

    CURSOR cr_crapsda(pr_cdcooper crapsda.cdcooper%TYPE
                     ,pr_nrdconta crapsda.nrdconta%TYPE) IS
      SELECT sda.* 
        FROM crapsda sda
       WHERE sda.cdcooper = pr_cdcooper
         AND sda.nrdconta = pr_nrdconta;
    
  BEGIN
    FOR rw_crapsda IN cr_crapsda(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP
        BEGIN
        
          DELETE 
            FROM crapsda 
           WHERE crapsda.cdcooper = rw_crapsda.cdcooper
             AND crapsda.dtmvtolt = rw_crapsda.dtmvtolt
             AND crapsda.nrdconta = rw_crapsda.nrdconta;
             
          IF SQL%ROWCOUNT > 0 THEN
             pr_tab_sda(pr_tab_sda.count) := rw_crapsda;
          END IF;             
          
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
        END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  PROCEDURE pc_deleta_crapneg(pr_cdcooper IN crapneg.cdcooper%TYPE
                             ,pr_nrdconta IN crapneg.nrdconta%TYPE
                             ,pr_tab_neg  IN OUT typ_tab_neg) IS

    CURSOR cr_crapneg(pr_cdcooper crapneg.cdcooper%TYPE
                     ,pr_nrdconta crapneg.nrdconta%TYPE) IS
      SELECT neg.* 
        FROM crapneg neg
       WHERE neg.cdcooper = pr_cdcooper
         AND neg.nrdconta = pr_nrdconta;
    
  BEGIN
    FOR rw_crapneg IN cr_crapneg(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP
        BEGIN
        
          DELETE 
            FROM crapneg 
           WHERE crapneg.cdcooper = rw_crapneg.cdcooper
             AND crapneg.nrdconta = rw_crapneg.nrdconta
             AND crapneg.nrseqdig = rw_crapneg.nrseqdig;

          IF SQL%ROWCOUNT > 0 THEN
             pr_tab_neg(pr_tab_neg.count) := rw_crapneg;
          END IF;             
           
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
        END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  PROCEDURE pc_deleta_crapenc(pr_cdcooper IN crapenc.cdcooper%TYPE
                             ,pr_nrdconta IN crapenc.nrdconta%TYPE
                             ,pr_tab_enc  IN OUT typ_tab_enc) IS

    CURSOR cr_crapenc(pr_cdcooper crapenc.cdcooper%TYPE
                     ,pr_nrdconta crapenc.nrdconta%TYPE) IS
      SELECT enc.* 
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta;
    
  BEGIN
    FOR rw_crapenc IN cr_crapenc(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP
        BEGIN
          
          DELETE 
            FROM crapenc 
           WHERE crapenc.cdcooper = rw_crapenc.cdcooper
             AND crapenc.nrdconta = rw_crapenc.nrdconta
             AND crapenc.idseqttl = rw_crapenc.idseqttl
             AND crapenc.cdseqinc = rw_crapenc.cdseqinc;

          IF SQL%ROWCOUNT > 0 THEN
             pr_tab_enc(pr_tab_enc.count) := rw_crapenc;
          END IF;             

        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
        END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  PROCEDURE pc_deleta_crapdoc(pr_cdcooper IN crapdoc.cdcooper%TYPE
                             ,pr_nrdconta IN crapdoc.nrdconta%TYPE
                             ,pr_tab_doc  IN OUT typ_tab_doc) IS

    CURSOR cr_crapdoc(pr_cdcooper crapdoc.cdcooper%TYPE
                     ,pr_nrdconta crapdoc.nrdconta%TYPE) IS
      SELECT doc.* 
        FROM crapdoc doc
       WHERE doc.cdcooper = pr_cdcooper
         AND doc.nrdconta = pr_nrdconta;
    
  BEGIN
    FOR rw_crapdoc IN cr_crapdoc(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP
        BEGIN
        
          DELETE 
            FROM crapdoc 
           WHERE crapdoc.progress_recid = rw_crapdoc.progress_recid;           
        
          IF SQL%ROWCOUNT > 0 THEN
             pr_tab_doc(pr_tab_doc.count) := rw_crapdoc;
          END IF;             
           
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
        END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  PROCEDURE pc_deleta_craplgm(pr_cdcooper IN craplgm.cdcooper%TYPE
                             ,pr_nrdconta IN craplgm.nrdconta%TYPE
                             ,pr_tab_lgm  IN OUT typ_tab_lgm) IS

    CURSOR cr_craplgm(pr_cdcooper craplgm.cdcooper%TYPE
                     ,pr_nrdconta craplgm.nrdconta%TYPE) IS
      SELECT lgm.* 
        FROM craplgm lgm
       WHERE lgm.cdcooper = pr_cdcooper
         AND lgm.nrdconta = pr_nrdconta;
    
  BEGIN
    FOR rw_craplgm IN cr_craplgm(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP
        BEGIN
        
          DELETE 
            FROM craplgm 
           WHERE craplgm.cdcooper = rw_craplgm.cdcooper
             AND craplgm.nrdconta = rw_craplgm.nrdconta
             AND craplgm.idseqttl = rw_craplgm.idseqttl
             AND craplgm.dttransa = rw_craplgm.dttransa
             AND craplgm.hrtransa = rw_craplgm.hrtransa
             AND craplgm.nrsequen = rw_craplgm.nrsequen;
             
          IF SQL%ROWCOUNT > 0 THEN
             pr_tab_lgm(pr_tab_lgm.count) := rw_craplgm;
          END IF;             

        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
        END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  PROCEDURE pc_deleta_crapsdc(pr_cdcooper IN craplgm.cdcooper%TYPE
                             ,pr_nrdconta IN craplgm.nrdconta%TYPE
                             ,pr_tab_sdc  IN OUT typ_tab_sdc) IS

    CURSOR cr_crapsdc(pr_cdcooper craplgm.cdcooper%TYPE
                     ,pr_nrdconta craplgm.nrdconta%TYPE) IS
      SELECT sdc.* 
        FROM crapsdc sdc
       WHERE sdc.cdcooper = pr_cdcooper
         AND sdc.nrdconta = pr_nrdconta;
    
  BEGIN
    FOR rw_crapsdc IN cr_crapsdc(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP
        BEGIN
        
          DELETE 
            FROM crapsdc 
           WHERE crapsdc.cdcooper = rw_crapsdc.cdcooper
             AND crapsdc.nrdconta = rw_crapsdc.nrdconta
             AND crapsdc.dtrefere = rw_crapsdc.dtrefere
             AND crapsdc.tplanmto = rw_crapsdc.tplanmto;
             
          IF SQL%ROWCOUNT > 0 THEN
             pr_tab_sdc(pr_tab_sdc.count) := rw_crapsdc;
          END IF;             

        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
        END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  PROCEDURE pc_del_tbchq_param_conta(pr_cdcooper IN tbchq_param_conta.cdcooper%TYPE
                                    ,pr_nrdconta IN tbchq_param_conta.nrdconta%TYPE
                                    ,pr_tab_cta  IN OUT typ_tab_cta) IS

    CURSOR cr_pcta(pr_cdcooper tbchq_param_conta.cdcooper%TYPE
                  ,pr_nrdconta tbchq_param_conta.nrdconta%TYPE) IS
      SELECT pcta.* 
        FROM tbchq_param_conta pcta
       WHERE pcta.cdcooper = pr_cdcooper
         AND pcta.nrdconta = pr_nrdconta;
    
  BEGIN
    FOR rw_pcta IN cr_pcta(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta) LOOP
        BEGIN
          
          DELETE 
            FROM tbchq_param_conta 
           WHERE tbchq_param_conta.cdcooper = rw_pcta.cdcooper
             AND tbchq_param_conta.nrdconta = rw_pcta.nrdconta;

          IF SQL%ROWCOUNT > 0 THEN
             pr_tab_cta(pr_tab_cta.count) := rw_pcta;
          END IF;             
          
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
        END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  PROCEDURE pc_deleta_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE
                             ,pr_tab_ass  IN OUT typ_tab_ass) IS

    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.* 
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    
  BEGIN
    FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP
        BEGIN
        
          DELETE 
            FROM crapass 
           WHERE crapass.cdcooper = rw_crapass.cdcooper
             AND crapass.nrdconta = rw_crapass.nrdconta;

          IF SQL%ROWCOUNT > 0 THEN
             pr_tab_ass(pr_tab_ass.count) := rw_crapass;
          END IF;             

        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
        END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

BEGIN 

  vr_nome_baca := 'BACA_PAZERADO';
  vr_nmdireto  := '/micros/cpd/bacas/568801';
  vr_nmarqimp  := 'contaspazero.txt';
  vr_nmarqbkp  := 'ROLLBACK.txt';
  vr_nmarqlog := 'LOG_'||vr_nome_baca||'_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.txt';
  
  /* ############# LOG ########################### */
    --Criar arquivo de log
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                            ,pr_nmarquiv => vr_nmarqlog        --> Nome do arquivo
                            ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                            ,pr_utlfileh => vr_ind_arqlog      --> handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);      --> erro
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN        
       RAISE vr_exc_erro;
    END IF;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Inicio Processo');  
  /* ############# FIM LOG ########################### */


--tabelas envolvidas
--crapass,crapttl,crapjur,crapadm,crapsld,crapcot,crapsda,crapneg,crapenc,crapdoc,craplgm,tbchq_param_conta

--#################INICIO DO PROGRAMA######################################################################################
  
  
  -- processando por cooperativa
  FOR rw_crapcop IN cr_crapcop LOOP

    vr_qtcontas := 0;
    
    vr_tab_contas.DELETE;
    
    vr_tab_ass.DELETE;
    vr_tab_ttl.DELETE;
    vr_tab_jur.DELETE;
    vr_tab_adm.DELETE;
    vr_tab_sld.DELETE;
    vr_tab_cot.DELETE;
    vr_tab_sda.DELETE;
    vr_tab_neg.DELETE;
    vr_tab_enc.DELETE;
    vr_tab_doc.DELETE;
    vr_tab_lgm.DELETE;
    vr_tab_cta.DELETE;


    -- pego as ASS da coop que tem que ser deletadas e guardo em uma TempTable
    FOR rw_crapass IN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper) LOOP
        
      vr_tab_contas(vr_qtcontas).cdcooper := rw_crapass.cdcooper;
      vr_tab_contas(vr_qtcontas).nrdconta := rw_crapass.nrdconta;
      vr_tab_contas(vr_qtcontas).inpessoa := rw_crapass.inpessoa;
      vr_tab_contas(vr_qtcontas).assrowid := rw_crapass.rowid;
      
      vr_qtcontas := vr_qtcontas + 1;
      
      dbms_output.put_line(rw_crapass.cdcooper||' '||rw_crapass.nrdconta);
      
    END LOOP;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' '||rw_crapcop.nmrescop||' - Qtd Contas: '||TO_CHAR(vr_qtcontas) );  
    
    IF vr_tab_contas.count = 0 THEN
       CONTINUE;
    END IF;
                      
    --irei deletar por coop e por tabela, criando um arquivo de rollback para
    --cada tabela que houve remoção de registros
    FOR vr_cont IN vr_tab_contas.FIRST..vr_tab_contas.LAST LOOP
      
      IF vr_tab_contas(vr_cont).inpessoa = 1 THEN
         --deleta pessoa fisica
         pc_deleta_crapttl(pr_cdcooper => vr_tab_contas(vr_cont).cdcooper
                          ,pr_nrdconta => vr_tab_contas(vr_cont).nrdconta
                          ,pr_tab_ttl  => vr_tab_ttl);
      ELSE
        --deleta pessoa juridica
        pc_deleta_crapjur(pr_cdcooper => vr_tab_contas(vr_cont).cdcooper
                         ,pr_nrdconta => vr_tab_contas(vr_cont).nrdconta
                         ,pr_tab_jur  => vr_tab_jur);
      END IF;
      
      pc_deleta_crapadm(pr_cdcooper => vr_tab_contas(vr_cont).cdcooper
                       ,pr_nrdconta => vr_tab_contas(vr_cont).nrdconta
                       ,pr_tab_adm  => vr_tab_adm);
      
      pc_deleta_crapsld(pr_cdcooper => vr_tab_contas(vr_cont).cdcooper
                       ,pr_nrdconta => vr_tab_contas(vr_cont).nrdconta
                       ,pr_tab_sld  => vr_tab_sld);
                       
      pc_deleta_crapcot(pr_cdcooper => vr_tab_contas(vr_cont).cdcooper
                       ,pr_nrdconta => vr_tab_contas(vr_cont).nrdconta
                       ,pr_tab_cot  => vr_tab_cot);
                       
      pc_deleta_crapsda(pr_cdcooper => vr_tab_contas(vr_cont).cdcooper
                       ,pr_nrdconta => vr_tab_contas(vr_cont).nrdconta
                       ,pr_tab_sda  => vr_tab_sda);
                       
      pc_deleta_crapneg(pr_cdcooper => vr_tab_contas(vr_cont).cdcooper
                       ,pr_nrdconta => vr_tab_contas(vr_cont).nrdconta
                       ,pr_tab_neg  => vr_tab_neg);
                       
      pc_deleta_crapenc(pr_cdcooper => vr_tab_contas(vr_cont).cdcooper
                       ,pr_nrdconta => vr_tab_contas(vr_cont).nrdconta
                       ,pr_tab_enc  => vr_tab_enc);
                       
      pc_deleta_crapdoc(pr_cdcooper => vr_tab_contas(vr_cont).cdcooper
                       ,pr_nrdconta => vr_tab_contas(vr_cont).nrdconta
                       ,pr_tab_doc  => vr_tab_doc);
     
      pc_deleta_craplgm(pr_cdcooper => vr_tab_contas(vr_cont).cdcooper
                       ,pr_nrdconta => vr_tab_contas(vr_cont).nrdconta
                       ,pr_tab_lgm  => vr_tab_lgm);
      
      pc_del_tbchq_param_conta(pr_cdcooper => vr_tab_contas(vr_cont).cdcooper
                              ,pr_nrdconta => vr_tab_contas(vr_cont).nrdconta
                              ,pr_tab_cta  => vr_tab_cta);
    
      pc_deleta_crapsdc(pr_cdcooper => vr_tab_contas(vr_cont).cdcooper
                       ,pr_nrdconta => vr_tab_contas(vr_cont).nrdconta
                       ,pr_tab_sdc  => vr_tab_sdc);
      
      pc_deleta_crapass(pr_cdcooper => vr_tab_contas(vr_cont).cdcooper
                       ,pr_nrdconta => vr_tab_contas(vr_cont).nrdconta
                       ,pr_tab_ass  => vr_tab_ass);
    
    END LOOP;    

    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' '||rw_crapcop.nmrescop||' - Qtd CRAPTTL: '||TO_CHAR(vr_tab_ttl.count) );  
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' '||rw_crapcop.nmrescop||' - Qtd CRAPJUR: '||TO_CHAR(vr_tab_jur.count) );  
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' '||rw_crapcop.nmrescop||' - Qtd CRAPADM: '||TO_CHAR(vr_tab_adm.count) );  
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' '||rw_crapcop.nmrescop||' - Qtd CRAPSLD: '||TO_CHAR(vr_tab_sld.count) );  
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' '||rw_crapcop.nmrescop||' - Qtd CRAPCOT: '||TO_CHAR(vr_tab_cot.count) );  
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' '||rw_crapcop.nmrescop||' - Qtd CRAPSDA: '||TO_CHAR(vr_tab_sda.count) );  
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' '||rw_crapcop.nmrescop||' - Qtd CRAPNEG: '||TO_CHAR(vr_tab_neg.count) );  
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' '||rw_crapcop.nmrescop||' - Qtd CRAPENC: '||TO_CHAR(vr_tab_enc.count) );  
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' '||rw_crapcop.nmrescop||' - Qtd CRAPDOC: '||TO_CHAR(vr_tab_doc.count) );  
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' '||rw_crapcop.nmrescop||' - Qtd CRAPLGM: '||TO_CHAR(vr_tab_lgm.count) );  
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' '||rw_crapcop.nmrescop||' - Qtd TBPARAM: '||TO_CHAR(vr_tab_cta.count) );  
    
  END LOOP;

  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' - Fim do Processo.' );    
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog); --> Handle do arquivo aberto;  
   
  ROLLBACK;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;  
  
END ;
0
1
rw_crapcop.cdcooper
