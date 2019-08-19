PL/SQL Developer Test script 3.0
4491
/********************************************************************************************************
               Baca para Atualizar o Endereço,Telefone e Faturamento - BOA VISTA
               
 - O arquivo deve ser adicionado em: \\pkgprod\micros\cpd\bacas\boa_vista\cooperativa               
 - Separar arquivos em: boa_vista_pf_AAAAMMDD.csv(Chamado 745508) e boa_vista_pj_AAAAMMDD.csv(Chamado 745127)
               
 Lucas Ranghetti - Chamados 745127/745508
 
 Alterações: 25/09/2017 - Rodar bacas de PF e PJ para a cooperativa credifiesc (#757530 / 757634)
 
             24/10/2017 - Ajustar para rodar por cooperativa e adicioar contatos de telefone 4 e 5 para PJ 
                          (Lucas Ranghetti #779513 / 779688)
                          
             09/11/2017 - Alterações para rodar as planilhas ref. aos chamados 
                          (Lucas Ranghetti #783908,783913,785541,785543,785565)
                          
             30/11/2017 - Rodar baca para a credifiesc e padronizar nomenclatura do arquivo como 
                          ano,mes e dia (Lucas Ranghetti #805213)
                          
             25/03/2019 - sctask0052043 atualizar dados de telefones e emails de pf e pj
                          [‎25/‎03/‎2019 15:14] Marina Franco dos Santos: 
                          Oi, Sarah disse pra não registrarmos anda na altera. 
                          As informações de e-mail e telefone pq irá influenciar em outras coisas (Carlos)
********************************************************************************************************/
DECLARE
 
  vr_nmdireto    VARCHAR2(100);
  vr_nmarquiv    VARCHAR2(50); 
  vr_nmarqbkp    VARCHAR2(50) := 'ROLLBACK_BOA_VISTA';
  vr_input_file  UTL_FILE.FILE_TYPE;
 
  vr_setlinha    VARCHAR2(10000);

  vr_dscritic    crapcri.dscritic%TYPE;
  vr_sqlerrm     VARCHAR2(5000);  
  vr_exc_saida   EXCEPTION;
  
  vr_ind   INTEGER;
  vr_rowid ROWID;
  vr_des_xml         CLOB;
  vr_texto_completo  VARCHAR2(32600);
  vr_contlinha   INTEGER;  
  
  w_cdseqinc     crapenc.cdseqinc%TYPE;
  w_cdseqtfc     craptfc.cdseqtfc%TYPE;
  vr_cdcooper    INTEGER;
  vr_nrcpfcgc    crapass.nrcpfcgc%TYPE;  
  vr_cep         VARCHAR2(100);
  vr_rua         VARCHAR2(100);
  vr_numero      NUMBER;
  vr_complemento VARCHAR2(100);
  vr_bairro      VARCHAR2(100);
  vr_cidade      VARCHAR2(100);
  vr_estado      VARCHAR2(100);
  vr_ddd1        VARCHAR2(100);
  vr_telefone1   VARCHAR2(100);
  vr_ddd2        VARCHAR2(100);
  vr_telefone2   VARCHAR2(100);
  vr_ddd3        VARCHAR2(100);
  vr_telefone3   VARCHAR2(100);  
  vr_tptelefo    INTEGER:= 0;

  vr_ddd_contato1        VARCHAR2(100);
  vr_telefone_contato1   VARCHAR2(100);
  vr_ddd_contato2        VARCHAR2(100);
  vr_telefone_contato2   VARCHAR2(100);
  vr_ddd_contato3        VARCHAR2(100);
  vr_telefone_contato3   VARCHAR2(100);
  
  vr_ddd_celular1 VARCHAR2(100);
  vr_celular1     VARCHAR2(100);
  vr_ddd_celular2 VARCHAR2(100);
  vr_celular2     VARCHAR2(100);
  vr_ddd_celular3 VARCHAR2(100);
  vr_celular3     VARCHAR2(100);  
  vr_restritivo   VARCHAR2(100);
  
  vr_ddd_celular_contato1 VARCHAR2(100);
  vr_celular_contato1     VARCHAR2(100);
  vr_ddd_celular_contato2 VARCHAR2(100);
  vr_celular_contato2     VARCHAR2(100);
  vr_ddd_celular_contato3 VARCHAR2(100);
  vr_celular_contato3     VARCHAR2(100);
  vr_email                VARCHAR2(100);
    
  vr_renda       NUMBER;
  vr_fat_mensal  NUMBER;
  vr_fat_anual   NUMBER;
  vr_idorigem    INTEGER;
  vr_ano         INTEGER;
  
  vr_cep_ant         VARCHAR2(100);
  vr_rua_ant         VARCHAR2(100);
  vr_numero_ant      NUMBER;
  vr_complemento_ant VARCHAR2(100);
  vr_bairro_ant      VARCHAR2(100);
  vr_cidade_ant      VARCHAR2(100);
  vr_estado_ant      VARCHAR2(100);
  vr_ddd1_ant        VARCHAR2(100);
  vr_telefone1_ant   VARCHAR2(100);
  vr_ddd2_ant        VARCHAR2(100);
  vr_telefone2_ant   VARCHAR2(100);
  vr_ddd3_ant        VARCHAR2(100);
  vr_telefone3_ant   VARCHAR2(100);
  vr_ddd4_ant        VARCHAR2(100):= 0;
  vr_telefone4_ant   VARCHAR2(100):= 0;
  vr_ddd5_ant        VARCHAR2(100):= 0;
  vr_telefone5_ant   VARCHAR2(100):= 0;
  vr_dtaltenc_ant    DATE;
  vr_renda_ant       NUMBER;
  vr_fat_anual_ant   NUMBER;
  vr_renda_cje_ant   NUMBER;  
  vr_email_ant       VARCHAR2(100);
  
  vr_mesftbru        INTEGER;
  vr_anoftbru        INTEGER;
  vr_vlrftbru        NUMBER;
  vr_indice          VARCHAR2(2);
  
  vr_crapttl_insere  BOOLEAN;  
  vr_crapcje_insere  BOOLEAN;
  vr_crapjur_insere  BOOLEAN;
  vr_crapenc_insere  BOOLEAN;
  vr_craptfc1_insere  BOOLEAN;
  vr_craptfc2_insere  BOOLEAN;
  vr_craptfc3_insere  BOOLEAN;
  vr_craptfc4_insere  BOOLEAN;
  vr_craptfc5_insere  BOOLEAN;
  vr_craptfc6_insere  BOOLEAN;
  vr_crapjfn_insere  BOOLEAN;
  vr_craptfc7_insere  BOOLEAN;
  vr_craptfc8_insere  BOOLEAN;
  vr_craptfc9_insere  BOOLEAN;
  vr_craptfc10_insere  BOOLEAN;      
  vr_craptfc11_insere  BOOLEAN;
  vr_craptfc12_insere  BOOLEAN;  
    
  vr_crapttl_progress_recid  VARCHAR2(30);     
  vr_crapcje_progress_recid  VARCHAR2(30);
  vr_crapjur_progress_recid  VARCHAR2(30);
  vr_crapenc_progress_recid  VARCHAR2(30);
  vr_crapalt_progress_recid  VARCHAR2(30);
  vr_craptfc1_progress_recid  VARCHAR2(30);
  vr_craptfc2_progress_recid  VARCHAR2(30);
  vr_craptfc3_progress_recid  VARCHAR2(30);    
  vr_craptfc4_progress_recid  VARCHAR2(30);
  vr_craptfc5_progress_recid  VARCHAR2(30);
  vr_crapjfn_progress_recid  VARCHAR2(30); 
  vr_crapcem_progress_recid  VARCHAR2(30);
  
  -- Colocar as cooperativas que deseja buscar os arquivos
  CURSOR cr_crapcop IS
  SELECT cop.dsdircop
        ,cop.cdcooper 
    FROM crapcop cop 
   WHERE cop.flgativo = 1;
--    AND cop.cdcooper = 9; --9 transpocred
  
  -- Buscar as contas que possuem o CPF/CNPJ
  CURSOR cr_crapass (pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
    SELECT ass.cdcooper
          ,ass.nrdconta
          ,ass.inpessoa
          ,ass.nrdctitg
          ,ass.flgctitg
      FROM crapass ass
     WHERE ass.cdcooper = vr_cdcooper
       AND ass.nrcpfcgc = pr_nrcpfcgc;
  rw_crapass cr_crapass%ROWTYPE;

  -- Verificar se é conta ITG
  CURSOR cr_crapass2 (pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrcpfcgc%TYPE) IS
    SELECT ass.cdcooper
          ,ass.nrdconta
          ,ass.inpessoa
          ,ass.nrdctitg
          ,ass.flgctitg          
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta
       AND ass.nrdctitg IS NOT NULL
       AND ass.flgctitg = 2;
  rw_crapass2 cr_crapass2%ROWTYPE;

  -- Buscar as contas que possuem o CPF
  CURSOR cr_crapttl (pr_nrcfpcgc IN crapttl.nrcpfcgc%TYPE) IS
    SELECT ttl.cdcooper
          ,ttl.nrdconta
          ,ttl.idseqttl
          ,ttl.vlsalari
          ,ttl.nrcpfcgc
          ,ttl.progress_recid
      FROM crapttl ttl
     WHERE ttl.cdcooper = vr_cdcooper
       AND ttl.nrcpfcgc = pr_nrcfpcgc;
       
  CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%TYPE
                    ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
    SELECT jur.cdcooper
          ,jur.nrdconta
          ,jur.vlfatano
          ,jur.progress_recid
      FROM crapjur jur
     WHERE jur.cdcooper = pr_cdcooper
       AND jur.nrdconta = pr_nrdconta;
  rw_crapjur cr_crapjur%ROWTYPE;
  
  -- Endereço
  CURSOR cr_crapenc (pr_cdcooper IN crapenc.cdcooper%TYPE
                    ,pr_nrdconta IN crapenc.nrdconta%TYPE
                    ,pr_idseqttl IN crapenc.idseqttl%TYPE
                    ,pr_tpendass IN crapenc.tpendass%TYPE) IS
    SELECT enc.*
      FROM crapenc enc
     WHERE enc.cdcooper = pr_cdcooper
       AND enc.nrdconta = pr_nrdconta
       AND enc.idseqttl = pr_idseqttl
       AND enc.tpendass = pr_tpendass; -- 9 - Comercial / 10 - Residencial / 13 - Correspondencia
  rw_crapenc cr_crapenc%ROWTYPE;
  
  -- Altera
  CURSOR cr_crapalt (pr_cdcooper IN crapalt.cdcooper%TYPE
                    ,pr_nrdconta IN crapalt.nrdconta%TYPE
                    ,pr_dtaltera IN crapalt.dtaltera%TYPE) IS
    SELECT alt.dsaltera 
          ,alt.progress_recid
      FROM crapalt alt
     WHERE alt.cdcooper = pr_cdcooper
       AND alt.nrdconta = pr_nrdconta
       AND alt.dtaltera = pr_dtaltera;
    rw_crapalt cr_crapalt%ROWTYPE;
  
  -- Telefones
  CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%TYPE
                    ,pr_nrdconta IN craptfc.nrdddtfc%TYPE
                    ,pr_idseqttl IN craptfc.idseqttl%TYPE
                    ,pr_nrtelefo IN craptfc.nrtelefo%TYPE) IS
    SELECT tfc.*
      FROM craptfc tfc
     WHERE tfc.cdcooper = pr_cdcooper
       AND tfc.nrdconta = pr_nrdconta
       AND tfc.idseqttl = pr_idseqttl
       AND tfc.nrtelefo = pr_nrtelefo;
     rw_craptfc cr_craptfc%ROWTYPE;       

   -- Verificar conjuge
   CURSOR cr_crapcje (pr_cdcooper IN crapcje.cdcooper%TYPE
                     ,pr_nrdconta IN crapcje.nrdconta%TYPE
                     ,pr_nrcpfcjg IN crapcje.nrcpfcjg%TYPE) IS
     SELECT cje.vlsalari
           ,cje.progress_recid
       FROM crapcje cje
      WHERE cje.cdcooper = pr_cdcooper
        AND cje.nrdconta = pr_nrdconta
        AND cje.nrcpfcjg = pr_nrcpfcjg;
     rw_crapcje cr_crapcje%ROWTYPE;
     
   CURSOR cr_crapjfn (pr_cdcooper IN crapjfn.cdcooper%TYPE
                     ,pr_nrdconta IN crapjfn.nrdconta%TYPE) IS
     SELECT j.*
       FROM crapjfn j
      WHERE j.cdcooper = pr_cdcooper
        AND j.nrdconta = pr_nrdconta;
     rw_crapjfn cr_crapjfn%ROWTYPE;
  
  CURSOR cr_crapcem (pr_cdcooper IN crapcem.cdcooper%TYPE
                    ,pr_nrdconta IN crapcem.nrdconta%TYPE
                    ,pr_dsdemail IN crapcem.dsdemail%TYPE) IS
     SELECT j.*
       FROM crapcem j
      WHERE j.cdcooper = pr_cdcooper
        AND j.nrdconta = pr_nrdconta
        AND j.dsdemail = pr_dsdemail;
     rw_crapcem cr_crapcem%ROWTYPE;
  
  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                          ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_xml
                           ,vr_texto_completo
                           ,pr_des_dados
                           ,pr_fecha_xml);
  END; 

  -- Gerar o LOG 
  PROCEDURE pc_gera_log(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_idseqttl IN INTEGER
                       ,pr_dstransa IN VARCHAR2 
                       ,pr_nmdcampo IN VARCHAR2 
                       ,pr_dsdadant IN VARCHAR2 
                       ,pr_dsdadatu IN VARCHAR2
                       ,pr_dslogalt IN VARCHAR2 DEFAULT NULL) IS
    vr_nrdrowid ROWID;  
    vr_flgctitg INTEGER;
    vr_dsaltera VARCHAR2(5000);
  BEGIN
    NULL;
/* chw
[‎25/‎03/‎2019 15:14] Marina Franco dos Santos: 
Oi, Sarah disse pra não registrarmos anda na altera.
As informações de e-mail e telefone 
pq irá influenciar em outras coisas 

    gene0001.pc_gera_log( pr_cdcooper => pr_cdcooper
                         ,pr_cdoperad => '1'
                         ,pr_dscritic => ''         
                         ,pr_dsorigem => 'AYLLOS'
                         ,pr_dstransa => pr_dstransa
                         ,pr_dttransa => TRUNC(SYSDATE)
                         ,pr_flgtrans => 1
                         ,pr_hrtransa => gene0002.fn_busca_time
                         ,pr_idseqttl => pr_idseqttl
                         ,pr_nmdatela => 'CONTAS'
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrdrowid => vr_nrdrowid);

    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => pr_nmdcampo, 
                              pr_dsdadant => pr_dsdadant, 
                              pr_dsdadatu => pr_dsdadatu);

    -- Caso tenha a descrição da alteração vamos registrar na tela ALTERA                       
    IF pr_dslogalt IS NOT NULL THEN
    
      IF cr_crapalt%ISOPEN THEN
        CLOSE cr_crapalt;
      END IF;            
        
      OPEN cr_crapalt(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dtaltera => trunc(SYSDATE));
      FETCH cr_crapalt INTO rw_crapalt;
      -- Caso exista, vamos atualizar
      IF cr_crapalt%FOUND THEN
        CLOSE cr_crapalt;
      
        vr_dsaltera:= rw_crapalt.dsaltera;
        
        IF vr_dsaltera NOT LIKE '%[BOA VISTA]%' THEN        
          pc_escreve_xml('UPDATE crapalt alt '||
                            'SET alt.dsaltera = '''||vr_dsaltera||
                       ''' WHERE alt.progress_recid = '||rw_crapalt.progress_recid||';'||chr(10));        
        END IF;
        
        BEGIN
          UPDATE crapalt alt 
             SET alt.dsaltera = rw_crapalt.dsaltera || pr_dslogalt
           WHERE alt.progress_recid = rw_crapalt.progress_recid
           RETURNING progress_recid INTO vr_crapalt_progress_recid;
        EXCEPTION
          WHEN OTHERS THEN
            cecred.pc_internal_exception;
            dbms_output.put_line('Erro ao tentar atualizar crapalt - Linha: ' || to_char(vr_contlinha) || 
                                 ' Conta: ' || to_char(pr_nrdconta) || ' - ' || SQLERRM);
        END;
      ELSE
         vr_flgctitg:= 3;
         vr_dsaltera:= '';
         
         CLOSE cr_crapalt;
         
         -- Verificar se conta é itg
         OPEN cr_crapass2(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta);
         FETCH cr_crapass2 INTO rw_crapass2;
         
         IF cr_crapass2%FOUND THEN
           CLOSE cr_crapass2;
           vr_flgctitg:= 0;
         ELSE
           CLOSE cr_crapass2;
         END IF;
  
         BEGIN    
           INSERT INTO crapalt
             (nrdconta,
              dtaltera,
              cdoperad,
              dsaltera,
              tpaltera,
              flgctitg,
              cdcooper)
           VALUES
             (pr_nrdconta,
              trunc(SYSDATE),
              '1',
              pr_dslogalt,
              1,
              vr_flgctitg,
              pr_cdcooper)
           RETURNING progress_recid INTO vr_crapalt_progress_recid;
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('Erro ao tentar inserir crapalt - Linha: ' || to_char(vr_contlinha) || 
                                 ' Conta: ' || to_char(pr_nrdconta) || ' - ' || SQLERRM);
        END;
        
        pc_escreve_xml('DELETE crapalt WHERE progress_recid = '||vr_crapalt_progress_recid||';'||chr(10));
        
      END IF;
    END IF;
*/
    
  END pc_gera_log;
  
  PROCEDURE pc_zera_invalidos (pr_cdcooper IN crapjfn.cdcooper%TYPE
                              ,pr_nrdconta IN crapjfn.nrdconta%TYPE)IS
  BEGIN
    
    BEGIN 
      UPDATE crapjfn
          SET mesftbru##1 = 0,
              anoftbru##1 = 0,
              vlrftbru##1 = 0
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND (mesftbru##1,anoftbru##1) NOT IN
              (( 9,2016),
               (10,2016),
               (11,2016),
               (12,2016),
               ( 1,2017),
               ( 2,2017),
               ( 3,2017),
               ( 4,2017),
               ( 5,2017),
               ( 6,2017),
               ( 7,2017),
               ( 8,2017));
    EXCEPTION 
      WHEN OTHERS THEN
        vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal1 - ' || SQLERRM;
        RAISE;
    END;
    -- Indice 2
    BEGIN 
      UPDATE crapjfn
          SET mesftbru##2 = 0,
              anoftbru##2 = 0,
              vlrftbru##2 = 0
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND (mesftbru##2,anoftbru##2) NOT IN
              (( 9,2016),
               (10,2016),
               (11,2016),
               (12,2016),
               ( 1,2017),
               ( 2,2017),
               ( 3,2017),
               ( 4,2017),
               ( 5,2017),
               ( 6,2017),
               ( 7,2017),
               ( 8,2017));
    EXCEPTION 
      WHEN OTHERS THEN
        vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal2 - ' || SQLERRM;
        RAISE;
    END;
    -- Indice 3
    BEGIN 
      UPDATE crapjfn
          SET mesftbru##3 = 0,
              anoftbru##3 = 0,
              vlrftbru##3 = 0
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND (mesftbru##3,anoftbru##3) NOT IN
              (( 9,2016),
               (10,2016),
               (11,2016),
               (12,2016),
               ( 1,2017),
               ( 2,2017),
               ( 3,2017),
               ( 4,2017),
               ( 5,2017),
               ( 6,2017),
               ( 7,2017),
               ( 8,2017));
    EXCEPTION 
      WHEN OTHERS THEN
        vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal3 - ' || SQLERRM;
        RAISE;
    END;
    -- Indice 4
    BEGIN 
      UPDATE crapjfn
          SET mesftbru##4 = 0,
              anoftbru##4 = 0,
              vlrftbru##4 = 0
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND (mesftbru##4,anoftbru##4) NOT IN
              (( 9,2016),
               (10,2016),
               (11,2016),
               (12,2016),
               ( 1,2017),
               ( 2,2017),
               ( 3,2017),
               ( 4,2017),
               ( 5,2017),
               ( 6,2017),
               ( 7,2017),
               ( 8,2017));
    EXCEPTION 
      WHEN OTHERS THEN
        vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal4 - ' || SQLERRM;
        RAISE;
    END;
    -- Indice 5
    BEGIN 
      UPDATE crapjfn
          SET mesftbru##5 = 0,
              anoftbru##5 = 0,
              vlrftbru##5 = 0
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND (mesftbru##5,anoftbru##5) NOT IN
              (( 9,2016),
               (10,2016),
               (11,2016),
               (12,2016),
               ( 1,2017),
               ( 2,2017),
               ( 3,2017),
               ( 4,2017),
               ( 5,2017),
               ( 6,2017),
               ( 7,2017),
               ( 8,2017));
    EXCEPTION 
      WHEN OTHERS THEN
        vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal5 - ' || SQLERRM;
        RAISE;
    END;
    -- Indice 6
    BEGIN 
      UPDATE crapjfn
          SET mesftbru##6 = 0,
              anoftbru##6 = 0,
              vlrftbru##6 = 0
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND (mesftbru##6,anoftbru##6) NOT IN
              (( 9,2016),
               (10,2016),
               (11,2016),
               (12,2016),
               ( 1,2017),
               ( 2,2017),
               ( 3,2017),
               ( 4,2017),
               ( 5,2017),
               ( 6,2017),
               ( 7,2017),
               ( 8,2017));
    EXCEPTION 
      WHEN OTHERS THEN
        vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal6 - ' || SQLERRM;
        RAISE;
    END;
    -- Indice 7
    BEGIN 
      UPDATE crapjfn
          SET mesftbru##7 = 0,
              anoftbru##7 = 0,
              vlrftbru##7 = 0
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND (mesftbru##7,anoftbru##7) NOT IN
              (( 9,2016),
               (10,2016),
               (11,2016),
               (12,2016),
               ( 1,2017),
               ( 2,2017),
               ( 3,2017),
               ( 4,2017),
               ( 5,2017),
               ( 6,2017),
               ( 7,2017),
               ( 8,2017));
    EXCEPTION 
      WHEN OTHERS THEN
        vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal7 - ' || SQLERRM;
        RAISE;
    END;
    -- Indice 8
    BEGIN 
      UPDATE crapjfn
          SET mesftbru##8 = 0,
              anoftbru##8 = 0,
              vlrftbru##8 = 0
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND (mesftbru##8,anoftbru##8) NOT IN
              (( 9,2016),
               (10,2016),
               (11,2016),
               (12,2016),
               ( 1,2017),
               ( 2,2017),
               ( 3,2017),
               ( 4,2017),
               ( 5,2017),
               ( 6,2017),
               ( 7,2017),
               ( 8,2017));
    EXCEPTION 
      WHEN OTHERS THEN
        vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal8 - ' || SQLERRM;
        RAISE;
    END;
    -- Indice 9
    BEGIN 
      UPDATE crapjfn
          SET mesftbru##9 = 0,
              anoftbru##9 = 0,
              vlrftbru##9 = 0
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND (mesftbru##9,anoftbru##9) NOT IN
              (( 9,2016),
               (10,2016),
               (11,2016),
               (12,2016),
               ( 1,2017),
               ( 2,2017),
               ( 3,2017),
               ( 4,2017),
               ( 5,2017),
               ( 6,2017),
               ( 7,2017),
               ( 8,2017));
    EXCEPTION 
      WHEN OTHERS THEN
        vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal9 - ' || SQLERRM;
        RAISE;
    END;
    -- Indice 10
    BEGIN 
      UPDATE crapjfn
          SET mesftbru##10 = 0,
              anoftbru##10 = 0,
              vlrftbru##10 = 0
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND (mesftbru##10,anoftbru##10) NOT IN
              (( 9,2016),
               (10,2016),
               (11,2016),
               (12,2016),
               ( 1,2017),
               ( 2,2017),
               ( 3,2017),
               ( 4,2017),
               ( 5,2017),
               ( 6,2017),
               ( 7,2017),
               ( 8,2017));
    EXCEPTION 
      WHEN OTHERS THEN
        vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal10 - ' || SQLERRM;
        RAISE;
    END;
    -- Indice 11
    BEGIN 
      UPDATE crapjfn
          SET mesftbru##11 = 0,
              anoftbru##11 = 0,
              vlrftbru##11 = 0
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND (mesftbru##11,anoftbru##11) NOT IN
              (( 9,2016),
               (10,2016),
               (11,2016),
               (12,2016),
               ( 1,2017),
               ( 2,2017),
               ( 3,2017),
               ( 4,2017),
               ( 5,2017),
               ( 6,2017),
               ( 7,2017),
               ( 8,2017));
    EXCEPTION 
      WHEN OTHERS THEN
        vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal11 - ' || SQLERRM;
        RAISE;
    END;
    -- Indice 12
    BEGIN 
      UPDATE crapjfn
          SET mesftbru##12 = 0,
              anoftbru##12 = 0,
              vlrftbru##12 = 0
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND (mesftbru##12,anoftbru##12) NOT IN
              (( 9,2016),
               (10,2016),
               (11,2016),
               (12,2016),
               ( 1,2017),
               ( 2,2017),
               ( 3,2017),
               ( 4,2017),
               ( 5,2017),
               ( 6,2017),
               ( 7,2017),
               ( 8,2017));
    EXCEPTION 
      WHEN OTHERS THEN
        vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal122 - ' || SQLERRM;
        RAISE;
    END;
    
  END pc_zera_invalidos;
  
  PROCEDURE pc_verifica_faturamento(pr_cdcooper IN crapjfn.cdcooper%TYPE
                                   ,pr_nrdconta IN crapjfn.nrdconta%TYPE
                                   ,pr_mes      IN INTEGER
                                   ,pr_ano      IN INTEGER         
                                   ,pr_vlrftmes IN NUMBER                         
                                   ,pr_indice   OUT INTEGER
                                   ,pr_mesftbru OUT INTEGER
                                   ,pr_anoftbru OUT INTEGER
                                   ,pr_vlrftbru OUT NUMBER) IS    
     
     CURSOR cr_crapjfn_indice(pr_cdcooper IN crapjfn.cdcooper%TYPE
                             ,pr_nrdconta IN crapjfn.nrdconta%TYPE
                             ,pr_mes      IN INTEGER
                             ,pr_ano      IN INTEGER) IS
      SELECT a.*
        FROM (
              -- Tabela de memoria para carregar todos os valores de faturamento
              SELECT jfni.cdcooper,
                      jfni.nrdconta,
                      jfni.mesftbru##1 mesftbru,
                      jfni.anoftbru##1 anoftbru,
                      jfni.vlrftbru##1 vlrftbru,
                      '01' indice
                FROM crapjfn jfni
              UNION ALL
              SELECT jfni.cdcooper,
                      jfni.nrdconta,
                      jfni.mesftbru##2 mesftbru,
                      jfni.anoftbru##2 anoftbru,
                      jfni.vlrftbru##2 vlrftbru,
                      '02' indice
                FROM crapjfn jfni
              UNION ALL
              SELECT jfni.cdcooper,
                      jfni.nrdconta,
                      jfni.mesftbru##3 mesftbru,
                      jfni.anoftbru##3 anoftbru,
                      jfni.vlrftbru##3 vlrftbru,
                      '03' indice
                FROM crapjfn jfni
              UNION ALL
              SELECT jfni.cdcooper,
                      jfni.nrdconta,
                      jfni.mesftbru##4 mesftbru,
                      jfni.anoftbru##4 anoftbru,
                      jfni.vlrftbru##4 vlrftbru,
                      '04' indice
                FROM crapjfn jfni
              UNION ALL
              SELECT jfni.cdcooper,
                      jfni.nrdconta,
                      jfni.mesftbru##5 mesftbru,
                      jfni.anoftbru##5 anoftbru,
                      jfni.vlrftbru##5 vlrftbru,
                      '05' indice
                FROM crapjfn jfni
              UNION ALL
              SELECT jfni.cdcooper,
                      jfni.nrdconta,
                      jfni.mesftbru##6 mesftbru,
                      jfni.anoftbru##6 anoftbru,
                      jfni.vlrftbru##6 vlrftbru,
                      '06' indice
                FROM crapjfn jfni
              UNION ALL
              SELECT jfni.cdcooper,
                      jfni.nrdconta,
                      jfni.mesftbru##7 mesftbru,
                      jfni.anoftbru##7 anoftbru,
                      jfni.vlrftbru##7 vlrftbru,
                      '07' indice
                FROM crapjfn jfni
              UNION ALL
              SELECT jfni.cdcooper,
                      jfni.nrdconta,
                      jfni.mesftbru##8 mesftbru,
                      jfni.anoftbru##8 anoftbru,
                      jfni.vlrftbru##8 vlrftbru,
                      '08' indice
                FROM crapjfn jfni
              UNION ALL
              SELECT jfni.cdcooper,
                      jfni.nrdconta,
                      jfni.mesftbru##9 mesftbru,
                      jfni.anoftbru##9 anoftbru,
                      jfni.vlrftbru##9 vlrftbru,
                      '09' indice
                FROM crapjfn jfni
              UNION ALL
              SELECT jfni.cdcooper,
                      jfni.nrdconta,
                      jfni.mesftbru##10 mesftbru,
                      jfni.anoftbru##10 anoftbru,
                      jfni.vlrftbru##10 vlrftbru,
                      '10' indice
                FROM crapjfn jfni
              UNION ALL
              SELECT jfni.cdcooper,
                      jfni.nrdconta,
                      jfni.mesftbru##11 mesftbru,
                      jfni.anoftbru##11 anoftbru,
                      jfni.vlrftbru##11 vlrftbru,
                      '11' indice
                FROM crapjfn jfni
              UNION ALL
              SELECT jfni.cdcooper,
                      jfni.nrdconta,
                      jfni.mesftbru##12 mesftbru,
                      jfni.anoftbru##12 anoftbru,
                      jfni.vlrftbru##12 vlrftbru,
                      '12' indice
                FROM crapjfn jfni) a,
             crapjfn jfn
       WHERE a.cdcooper = jfn.cdcooper
         AND a.nrdconta = jfn.nrdconta
         AND jfn.cdcooper = pr_cdcooper
         AND jfn.nrdconta = pr_nrdconta
         AND ((a.mesftbru = pr_mes AND a.anoftbru = pr_ano ) OR
             (a.mesftbru = 0 AND a.anoftbru = 0))
       ORDER BY a.anoftbru DESC, 
                a.mesftbru DESC, 
                a.indice ASC;
      rw_crapjfn_indice cr_crapjfn_indice%ROWTYPE;
  
  BEGIN
    OPEN cr_crapjfn_indice(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta,
                           pr_mes => pr_mes,
                           pr_ano => pr_ano);
    FETCH cr_crapjfn_indice INTO rw_crapjfn_indice;
    -- Caso exista, vamos atualizar
    IF cr_crapjfn_indice%FOUND THEN          
      CLOSE cr_crapjfn_indice;
      
      pr_indice   := rw_crapjfn_indice.indice;
      pr_anoftbru := rw_crapjfn_indice.anoftbru;
      pr_mesftbru := rw_crapjfn_indice.mesftbru;
      pr_vlrftbru := rw_crapjfn_indice.vlrftbru;
    ELSE
      CLOSE cr_crapjfn_indice;            
    END IF;
  
    IF pr_anoftbru <> 0 AND pr_mesftbru <> 0 THEN
      RETURN;
    END IF;
  
    CASE 
      WHEN pr_indice = '01' THEN
        BEGIN
          UPDATE crapjfn jfn
             SET jfn.mesftbru##1 = pr_mes,
                 jfn.anoftbru##1 = pr_ano,
                 jfn.vlrftbru##1 = pr_vlrftmes,                       
                 jfn.dtaltjfn##1 = trunc(SYSDATE),
                 jfn.dtaltjfn##2 = trunc(SYSDATE),
                 jfn.dtaltjfn##3 = trunc(SYSDATE),
                 jfn.dtaltjfn##4 = trunc(SYSDATE),
                 jfn.cdopejfn##1 = '1',
                 jfn.cdopejfn##2 = '1',
                 jfn.cdopejfn##3 = '1',
                 jfn.cdopejfn##4 = '1'
           WHERE jfn.cdcooper = pr_cdcooper
             AND jfn.nrdconta = pr_nrdconta;              
        EXCEPTION
          WHEN OTHERS THEN
            vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal1 - ' || SQLERRM;
            RAISE;
        END;   
      WHEN pr_indice = '02' THEN
        BEGIN
          UPDATE crapjfn jfn
             SET jfn.mesftbru##2 = pr_mes,
                 jfn.anoftbru##2 = pr_ano,
                 jfn.vlrftbru##2 = pr_vlrftmes,                       
                 jfn.dtaltjfn##1 = trunc(SYSDATE),
                 jfn.dtaltjfn##2 = trunc(SYSDATE),
                 jfn.dtaltjfn##3 = trunc(SYSDATE),
                 jfn.dtaltjfn##4 = trunc(SYSDATE),
                 jfn.cdopejfn##1 = '1',
                 jfn.cdopejfn##2 = '1',
                 jfn.cdopejfn##3 = '1',
                 jfn.cdopejfn##4 = '1'
           WHERE jfn.cdcooper = pr_cdcooper
             AND jfn.nrdconta = pr_nrdconta;         
        EXCEPTION
          WHEN OTHERS THEN
            vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal2 - ' || SQLERRM;
            RAISE;
        END;   
      WHEN pr_indice = '03' THEN
        BEGIN
          UPDATE crapjfn jfn
             SET jfn.mesftbru##3 = pr_mes,
                 jfn.anoftbru##3 = pr_ano,
                 jfn.vlrftbru##3 = pr_vlrftmes,                       
                 jfn.dtaltjfn##1 = trunc(SYSDATE),
                 jfn.dtaltjfn##2 = trunc(SYSDATE),
                 jfn.dtaltjfn##3 = trunc(SYSDATE),
                 jfn.dtaltjfn##4 = trunc(SYSDATE),
                 jfn.cdopejfn##1 = '1',
                 jfn.cdopejfn##2 = '1',
                 jfn.cdopejfn##3 = '1',
                 jfn.cdopejfn##4 = '1'
           WHERE jfn.cdcooper = pr_cdcooper
             AND jfn.nrdconta = pr_nrdconta;              
        EXCEPTION
          WHEN OTHERS THEN
            vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal3 - ' || SQLERRM;
            RAISE;
        END;   
      WHEN pr_indice = '04' THEN
        BEGIN
          UPDATE crapjfn jfn
             SET jfn.mesftbru##4 = pr_mes,
                 jfn.anoftbru##4 = pr_ano,
                 jfn.vlrftbru##4 = pr_vlrftmes,                       
                 jfn.dtaltjfn##1 = trunc(SYSDATE),
                 jfn.dtaltjfn##2 = trunc(SYSDATE),
                 jfn.dtaltjfn##3 = trunc(SYSDATE),
                 jfn.dtaltjfn##4 = trunc(SYSDATE),
                 jfn.cdopejfn##1 = '1',
                 jfn.cdopejfn##2 = '1',
                 jfn.cdopejfn##3 = '1',
                 jfn.cdopejfn##4 = '1'
           WHERE jfn.cdcooper = pr_cdcooper
             AND jfn.nrdconta = pr_nrdconta;   
        EXCEPTION
          WHEN OTHERS THEN
            vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal4 - ' || SQLERRM;
            RAISE;
        END;   
     WHEN pr_indice = '05' THEN
        BEGIN
          UPDATE crapjfn jfn
             SET jfn.mesftbru##5 = pr_mes,
                 jfn.anoftbru##5 = pr_ano,
                 jfn.vlrftbru##5 = pr_vlrftmes,                       
                 jfn.dtaltjfn##1 = trunc(SYSDATE),
                 jfn.dtaltjfn##2 = trunc(SYSDATE),
                 jfn.dtaltjfn##3 = trunc(SYSDATE),
                 jfn.dtaltjfn##4 = trunc(SYSDATE),
                 jfn.cdopejfn##1 = '1',
                 jfn.cdopejfn##2 = '1',
                 jfn.cdopejfn##3 = '1',
                 jfn.cdopejfn##4 = '1'
           WHERE jfn.cdcooper = pr_cdcooper
             AND jfn.nrdconta = pr_nrdconta;            
        EXCEPTION
          WHEN OTHERS THEN
            vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal5 - ' || SQLERRM;
            RAISE;
        END;   
      WHEN pr_indice = '06' THEN
        BEGIN
          UPDATE crapjfn jfn
             SET jfn.mesftbru##6 = pr_mes,
                 jfn.anoftbru##6 = pr_ano,
                 jfn.vlrftbru##6 = pr_vlrftmes,                       
                 jfn.dtaltjfn##1 = trunc(SYSDATE),
                 jfn.dtaltjfn##2 = trunc(SYSDATE),
                 jfn.dtaltjfn##3 = trunc(SYSDATE),
                 jfn.dtaltjfn##4 = trunc(SYSDATE),
                 jfn.cdopejfn##1 = '1',
                 jfn.cdopejfn##2 = '1',
                 jfn.cdopejfn##3 = '1',
                 jfn.cdopejfn##4 = '1'
           WHERE jfn.cdcooper = pr_cdcooper
             AND jfn.nrdconta = pr_nrdconta;            
        EXCEPTION
          WHEN OTHERS THEN
            vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal6 - ' || SQLERRM;
            RAISE;
        END;     
      WHEN pr_indice = '07' THEN
        BEGIN
          UPDATE crapjfn jfn
             SET jfn.mesftbru##7 = pr_mes,
                 jfn.anoftbru##7 = pr_ano,
                 jfn.vlrftbru##7 = pr_vlrftmes,                       
                 jfn.dtaltjfn##1 = trunc(SYSDATE),
                 jfn.dtaltjfn##2 = trunc(SYSDATE),
                 jfn.dtaltjfn##3 = trunc(SYSDATE),
                 jfn.dtaltjfn##4 = trunc(SYSDATE),
                 jfn.cdopejfn##1 = '1',
                 jfn.cdopejfn##2 = '1',
                 jfn.cdopejfn##3 = '1',
                 jfn.cdopejfn##4 = '1'
           WHERE jfn.cdcooper = pr_cdcooper
             AND jfn.nrdconta = pr_nrdconta;            
        EXCEPTION
          WHEN OTHERS THEN
            vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal7 - ' || SQLERRM;
            RAISE;
        END;     
      WHEN pr_indice = '08' THEN
        BEGIN
          UPDATE crapjfn jfn
             SET jfn.mesftbru##8 = pr_mes,
                 jfn.anoftbru##8 = pr_ano,
                 jfn.vlrftbru##8 = pr_vlrftmes,                       
                 jfn.dtaltjfn##1 = trunc(SYSDATE),
                 jfn.dtaltjfn##2 = trunc(SYSDATE),
                 jfn.dtaltjfn##3 = trunc(SYSDATE),
                 jfn.dtaltjfn##4 = trunc(SYSDATE),
                 jfn.cdopejfn##1 = '1',
                 jfn.cdopejfn##2 = '1',
                 jfn.cdopejfn##3 = '1',
                 jfn.cdopejfn##4 = '1'
           WHERE jfn.cdcooper = pr_cdcooper
             AND jfn.nrdconta = pr_nrdconta;           
        EXCEPTION
          WHEN OTHERS THEN
            vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal8 - ' || SQLERRM;
            RAISE;
        END;   
      WHEN pr_indice = '09' THEN
        BEGIN
          UPDATE crapjfn jfn
             SET jfn.mesftbru##9 = pr_mes,
                 jfn.anoftbru##9 = pr_ano,
                 jfn.vlrftbru##9 = pr_vlrftmes,                       
                 jfn.dtaltjfn##1 = trunc(SYSDATE),
                 jfn.dtaltjfn##2 = trunc(SYSDATE),
                 jfn.dtaltjfn##3 = trunc(SYSDATE),
                 jfn.dtaltjfn##4 = trunc(SYSDATE),
                 jfn.cdopejfn##1 = '1',
                 jfn.cdopejfn##2 = '1',
                 jfn.cdopejfn##3 = '1',
                 jfn.cdopejfn##4 = '1'
           WHERE jfn.cdcooper = pr_cdcooper
             AND jfn.nrdconta = pr_nrdconta;           
        EXCEPTION
          WHEN OTHERS THEN
            vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal9 - ' || SQLERRM;
            RAISE;
        END;     
      WHEN pr_indice = '10' THEN
        BEGIN
          UPDATE crapjfn jfn
             SET jfn.mesftbru##10 = pr_mes,
                 jfn.anoftbru##10 = pr_ano,
                 jfn.vlrftbru##10 = pr_vlrftmes,                       
                 jfn.dtaltjfn##1 = trunc(SYSDATE),
                 jfn.dtaltjfn##2 = trunc(SYSDATE),
                 jfn.dtaltjfn##3 = trunc(SYSDATE),
                 jfn.dtaltjfn##4 = trunc(SYSDATE),
                 jfn.cdopejfn##1 = '1',
                 jfn.cdopejfn##2 = '1',
                 jfn.cdopejfn##3 = '1',
                 jfn.cdopejfn##4 = '1'
           WHERE jfn.cdcooper = pr_cdcooper
             AND jfn.nrdconta = pr_nrdconta;            
        EXCEPTION
          WHEN OTHERS THEN
            vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal10 - ' || SQLERRM;
            RAISE;
        END;  
      WHEN pr_indice = '11' THEN
        BEGIN
          UPDATE crapjfn jfn
             SET jfn.mesftbru##11 = pr_mes,
                 jfn.anoftbru##11 = pr_ano,
                 jfn.vlrftbru##11 = pr_vlrftmes,                       
                 jfn.dtaltjfn##1 = trunc(SYSDATE),
                 jfn.dtaltjfn##2 = trunc(SYSDATE),
                 jfn.dtaltjfn##3 = trunc(SYSDATE),
                 jfn.dtaltjfn##4 = trunc(SYSDATE),
                 jfn.cdopejfn##1 = '1',
                 jfn.cdopejfn##2 = '1',
                 jfn.cdopejfn##3 = '1',
                 jfn.cdopejfn##4 = '1'
           WHERE jfn.cdcooper = pr_cdcooper
             AND jfn.nrdconta = pr_nrdconta;             
        EXCEPTION
          WHEN OTHERS THEN
            vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal11 - ' || SQLERRM;
            RAISE;
        END;     
      WHEN pr_indice = '12' THEN
        BEGIN
          UPDATE crapjfn jfn
             SET jfn.mesftbru##12 = pr_mes,
                 jfn.anoftbru##12 = pr_ano,
                 jfn.vlrftbru##12 = pr_vlrftmes,                       
                 jfn.dtaltjfn##1 = trunc(SYSDATE),
                 jfn.dtaltjfn##2 = trunc(SYSDATE),
                 jfn.dtaltjfn##3 = trunc(SYSDATE),
                 jfn.dtaltjfn##4 = trunc(SYSDATE),
                 jfn.cdopejfn##1 = '1',
                 jfn.cdopejfn##2 = '1',
                 jfn.cdopejfn##3 = '1',
                 jfn.cdopejfn##4 = '1'
           WHERE jfn.cdcooper = pr_cdcooper
             AND jfn.nrdconta = pr_nrdconta;            
        EXCEPTION
          WHEN OTHERS THEN
            vr_sqlerrm := 'Erro ao tentar atualizar Faturamento mensal12 - ' || SQLERRM;
            RAISE;
        END;  
      ELSE
        vr_sqlerrm := 'Erro geral ao tentar atualizar Faturamento mensal - ' || SQLERRM;        
      END CASE;   
        
  END pc_verifica_faturamento;
BEGIN

  -- Nomenclatura do arquivo da coop AAAAMMDD
  vr_nmarquiv:= 'boa_vista_pf_'||to_char(SYSDATE,'RRRRMMDD')||'.csv';
    
  FOR rw_crapcop IN cr_crapcop LOOP

    vr_cdcooper:= rw_crapcop.cdcooper;
    
    -- Buscar caminho do micros
    vr_nmdireto := gene0001.fn_param_sistema('CRED',vr_cdcooper,'ROOT_MICROS');
    vr_nmdireto := vr_nmdireto||'cpd/bacas/boa_vista/'||rw_crapcop.dsdircop;
    
    -- Abrir o arquivo PESSOA FISICA
    gene0001.pc_abre_arquivo (pr_nmdireto => vr_nmdireto    --> Diretório do arquivo
                             ,pr_nmarquiv => vr_nmarquiv    --> Nome do arquivo
                             ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                             ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                             ,pr_des_erro => vr_dscritic);  --> Erro

    -- Se retornou erro
    IF vr_dscritic IS NOT NULL THEN
      continue; -- proxima coop
    END IF;

    BEGIN
    
      vr_contlinha:= 0;
      
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      vr_texto_completo := NULL;  
       
      -- Laco para leitura de linhas do arquivo
      LOOP
        -- Carrega handle do arquivo
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto lido
       
        vr_contlinha:= vr_contlinha + 1;
        
        -- ignorar primeira linha
        IF vr_contlinha = 1 THEN
          continue;
        END IF;
        
        -- Retirar quebra de linha
        vr_setlinha := REPLACE(REPLACE(vr_setlinha,CHR(10)),CHR(13));
        
        -- Antigo
        --cpf;CEP;Rua;Numero;Complemento;Bairro;Cidade;Estado;DDD1;Fone1;
        --DDD2;Fone2;DDD3;Fone3;Renda
        
        --Novo
        --CPF;CEP;Logradouro;Numero;Complemento;Bairro;Cidade;Estado;DDD1;Telefone1;
        --DDD2;Telefone2;DDD3;Telefone3;DDD_Celular1;Celular1;DDD_Celular2;Celular2;
        --DDD_Celular3;Celular3;Renda;Email
        vr_nrcpfcgc := replace(replace(gene0002.fn_busca_entrada(1,vr_setlinha,';'),'.',''),'-','');

/* chw nao atualizar endereco
        vr_cep := gene0002.fn_busca_entrada(2,vr_setlinha,';');
        vr_rua := substr(gene0002.fn_busca_entrada(3,vr_setlinha,';'),1,40);
        BEGIN
          vr_numero := nvl(gene0002.fn_busca_entrada(4,vr_setlinha,';'),0);
        EXCEPTION 
          WHEN OTHERS THEN
            vr_numero:= 0;
        END;
        vr_complemento := gene0002.fn_busca_entrada(5,vr_setlinha,';');
        vr_bairro := gene0002.fn_busca_entrada(6,vr_setlinha,';');
        vr_cidade := gene0002.fn_busca_entrada(7,vr_setlinha,';');      
        vr_estado := gene0002.fn_busca_entrada(8,vr_setlinha,';');
*/
        vr_ddd1 := nvl(gene0002.fn_busca_entrada(9,vr_setlinha,';'),'0');      
        vr_telefone1 := nvl(gene0002.fn_busca_entrada(10,vr_setlinha,';'),'0');      
        vr_ddd2 := nvl(gene0002.fn_busca_entrada(11,vr_setlinha,';'),'0');            
        vr_telefone2 := nvl(gene0002.fn_busca_entrada(12,vr_setlinha,';'),'0');            
        vr_ddd3 := nvl(gene0002.fn_busca_entrada(13,vr_setlinha,';'),'0');            
        vr_telefone3 := nvl(gene0002.fn_busca_entrada(14,vr_setlinha,';'),'0'); 
        --Novo
        vr_ddd_celular1 := nvl(gene0002.fn_busca_entrada(15,vr_setlinha,';'),'0'); 
        vr_celular1     := nvl(gene0002.fn_busca_entrada(16,vr_setlinha,';'),'0'); 
        vr_ddd_celular2 := nvl(gene0002.fn_busca_entrada(17,vr_setlinha,';'),'0'); 
        vr_celular2     := nvl(gene0002.fn_busca_entrada(18,vr_setlinha,';'),'0'); 
        vr_ddd_celular3 := nvl(gene0002.fn_busca_entrada(19,vr_setlinha,';'),'0'); 
        vr_celular3     := nvl(gene0002.fn_busca_entrada(20,vr_setlinha,';'),'0');         
        -- Fim novo
/* chw nao atualizar renda 
        vr_renda := to_number(gene0002.fn_busca_entrada(21,vr_setlinha,';'));
*/        
        vr_email := gene0002.fn_busca_entrada(22,vr_setlinha,';');
        
        vr_crapttl_insere  := FALSE;
        vr_crapcje_insere  := FALSE;
        vr_crapjur_insere  := FALSE;
        vr_crapenc_insere  := FALSE;
        vr_craptfc1_insere := FALSE;
        vr_craptfc2_insere := FALSE;
        vr_craptfc3_insere := FALSE;
        vr_craptfc4_insere := FALSE;
        vr_craptfc5_insere := FALSE;
        vr_craptfc6_insere := FALSE;        
        
        FOR rw_ttl IN cr_crapttl (pr_nrcfpcgc => vr_nrcpfcgc) LOOP
        
          vr_cep_ant         := ' ';
          vr_rua_ant         := ' ';
          vr_numero_ant      := 0;
          vr_complemento_ant := ' ';
          vr_bairro_ant      := ' ';
          vr_cidade_ant      := ' ';
          vr_estado_ant      := ' ';
          vr_ddd1_ant        := 0;
          vr_telefone1_ant   := 0;
          vr_ddd2_ant        := 0;
          vr_telefone2_ant   := 0;
          vr_ddd3_ant        := 0;
          vr_telefone3_ant   := 0;
          
          vr_renda_ant := rw_ttl.vlsalari;
          vr_renda_cje_ant := 0;
          
          vr_email_ant := ' ';
          
          ------------------------------------------------------------------------------------
          -------------------------------- Atualizar Endereço --------------------------------
          ------------------------------------------------------------------------------------
/* chw nao atualizar endereço

          OPEN cr_crapenc(pr_cdcooper => rw_ttl.cdcooper
                         ,pr_nrdconta => rw_ttl.nrdconta
                         ,pr_idseqttl => rw_ttl.idseqttl
                         ,pr_tpendass => 14);
          FETCH cr_crapenc INTO rw_crapenc;
          -- Caso exista, vamos atualizar
          IF cr_crapenc%FOUND THEN          
            -- Fecha CURSOR
            CLOSE cr_crapenc;
            vr_crapenc_insere:= TRUE;
            
            vr_cep_ant         := to_char(rw_crapenc.nrcepend);
            vr_rua_ant         := rw_crapenc.dsendere;
            vr_numero_ant      := rw_crapenc.nrendere;
            vr_complemento_ant := rw_crapenc.complend;
            vr_bairro_ant      := rw_crapenc.nmbairro;
            vr_cidade_ant      := rw_crapenc.nmcidade;
            vr_estado_ant      := rw_crapenc.cdufende;       
            vr_idorigem        := rw_crapenc.idorigem;
            vr_dtaltenc_ant    := rw_crapenc.dtaltenc;
            
            BEGIN
              UPDATE crapenc c
                 SET c.nrcepend = vr_cep,
                     c.dsendere = vr_rua,
                     c.nrendere = vr_numero,
                     c.complend = vr_complemento,
                     c.nmbairro = vr_bairro,
                     c.nmcidade = vr_cidade,
                     c.cdufende = vr_estado,
                     c.dtaltenc = trunc(SYSDATE),
                     c.idorigem = 3 -- 1-Cooperado,2-Cooperativa,3-Terceiros
               WHERE c.progress_recid = rw_crapenc.progress_recid
              RETURNING progress_recid INTO vr_crapenc_progress_recid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_sqlerrm := 'Erro ao tentar atualizar Endereço - ' || SQLERRM;
                RAISE;
            END;
            
            pc_escreve_xml('UPDATE crapenc c '||
                              'SET c.nrcepend = '||vr_cep_ant||',
                                   c.dsendere = '''||vr_rua_ant||''',
                                   c.nrendere = '||vr_numero_ant||',
                                   c.complend = '''||vr_complemento_ant||''',
                                   c.nmbairro = '''||vr_bairro_ant||''',
                                   c.nmcidade = '''||vr_cidade_ant||''',
                                   c.cdufende = '''||vr_estado_ant||''',
                                   c.dtaltenc = '''||vr_dtaltenc_ant||''',
                                   c.idorigem = '||vr_idorigem||
                           ' WHERE c.progress_recid = '||vr_crapenc_progress_recid||';'||chr(10));     
            
          ELSE
            -- Fecha CURSOR
            CLOSE cr_crapenc;
            
            vr_crapenc_insere:= FALSE;          
            
            BEGIN
              SELECT nvl(MAX(c.cdseqinc) + 1, 1)
                INTO w_cdseqinc
                FROM crapenc c
               WHERE c.cdcooper = vr_cdcooper
                 AND c.nrdconta = rw_ttl.nrdconta
                 AND c.idseqttl = rw_ttl.idseqttl;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqinc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;
            
            --Inclusão Endereço
            BEGIN
              INSERT INTO crapenc
                (cdcooper,
                 nrdconta,
                 idseqttl,
                 tpendass,
                 cdseqinc,
                 dsendere,
                 nrendere,
                 complend,
                 nmbairro,
                 nmcidade,
                 cdufende,
                 nrcepend,
                 dtaltenc,
                 idorigem)
              VALUES
                (vr_cdcooper,
                 rw_ttl.nrdconta,
                 rw_ttl.idseqttl,
                 14, -- 13-Correspondencia, 14-complementar
                 w_cdseqinc,
                 vr_rua,
                 vr_numero,
                 vr_complemento,
                 vr_bairro,
                 vr_cidade,
                 vr_estado,
                 vr_cep,
                 trunc(SYSDATE),
                 3)
              RETURNING progress_recid INTO vr_crapenc_progress_recid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_sqlerrm := 'Erro ao tentar inserir endereço - ' || SQLERRM;
                RAISE;
            END;
            
            pc_escreve_xml('DELETE crapenc WHERE progress_recid = '||vr_crapenc_progress_recid||';'||chr(10));

          END IF;
          ------------------------------------------------------------------------------------
          ----------------------------- FIM - Atualizar Endereço -----------------------------
          ------------------------------------------------------------------------------------
*/          
          ------------------------------------------------------------------------------------
          ----------------------------- INICIO - TELEFONE ------------------------------------
          ------------------------------------------------------------------------------------
          
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;
          
          vr_tptelefo:= 4;
          
          IF vr_ddd1 <> 0 AND 
             vr_telefone1 <> 0 THEN
             
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ttl.nrdconta
                 AND tfc.idseqttl = rw_ttl.idseqttl;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                cecred.pc_internal_exception;
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;           
             
            -- Telefone 1
            OPEN cr_craptfc(pr_cdcooper => rw_ttl.cdcooper
                           ,pr_nrdconta => rw_ttl.nrdconta
                           ,pr_idseqttl => rw_ttl.idseqttl
                           ,pr_nrtelefo => vr_telefone1 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
              
              vr_craptfc1_insere:= TRUE;
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_telefone1),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;

              --Inclusão telefone 1
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ttl.cdcooper,
                   rw_ttl.nrdconta,
                   rw_ttl.idseqttl,
                   w_cdseqtfc,
                   1,
                   vr_ddd1,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_telefone1,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc1_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone - ' || SQLERRM;
                  RAISE;
              END;
              
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc1_progress_recid||';'||chr(10));
            END IF;
          END IF;
          
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;
          
          IF vr_ddd2 <> 0 AND 
             vr_telefone2 <> 0 AND           
             vr_telefone2 <> vr_telefone1 THEN 
          
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ttl.nrdconta
                 AND tfc.idseqttl = rw_ttl.idseqttl;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;           
             
            -- Telefone 2
            OPEN cr_craptfc(pr_cdcooper => rw_ttl.cdcooper
                           ,pr_nrdconta => rw_ttl.nrdconta
                           ,pr_idseqttl => rw_ttl.idseqttl
                           ,pr_nrtelefo => vr_telefone2 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
              
              vr_craptfc2_insere:= TRUE;                    
                        
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_telefone2),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;
              
              --Inclusão telefone 2
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ttl.cdcooper,
                   rw_ttl.nrdconta,
                   rw_ttl.idseqttl,
                   w_cdseqtfc,
                   1,
                   vr_ddd2,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_telefone2,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc2_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone - ' || SQLERRM;
                  RAISE;
              END;
                          
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc2_progress_recid||';'||chr(10));
            END IF;
          END IF;
          
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;        
          
          IF vr_ddd3 <> 0 AND 
             vr_telefone3 <> 0 AND
             vr_telefone3 <> vr_telefone1 AND
             vr_telefone3 <> vr_telefone2 THEN
                
            -- Telefone 3
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ttl.nrdconta
                 AND tfc.idseqttl = rw_ttl.idseqttl;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;           
             
            -- Telefone 3
            OPEN cr_craptfc(pr_cdcooper => rw_ttl.cdcooper
                           ,pr_nrdconta => rw_ttl.nrdconta
                           ,pr_idseqttl => rw_ttl.idseqttl
                           ,pr_nrtelefo => vr_telefone3 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
              
              vr_craptfc3_insere:= TRUE;          
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_telefone3),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;
              
              --Inclusão telefone 3
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ttl.cdcooper,
                   rw_ttl.nrdconta,
                   rw_ttl.idseqttl,
                   w_cdseqtfc,
                   1,
                   vr_ddd3,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_telefone3,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc3_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone - ' || SQLERRM;
              END;
                          
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc3_progress_recid||';'||chr(10));
            END IF;
          END IF;

          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;
          
          IF vr_ddd_celular1 <> 0 AND 
             vr_celular1 <> 0     THEN
                
            -- celular 1
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ttl.nrdconta
                 AND tfc.idseqttl = rw_ttl.idseqttl;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;           
             
            -- celular 1
            OPEN cr_craptfc(pr_cdcooper => rw_ttl.cdcooper
                           ,pr_nrdconta => rw_ttl.nrdconta
                           ,pr_idseqttl => rw_ttl.idseqttl
                           ,pr_nrtelefo => vr_celular1 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
              
              vr_craptfc4_insere:= true;
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_celular1),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;
              
              --Inclusão telefone celular 1
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ttl.cdcooper,
                   rw_ttl.nrdconta,
                   rw_ttl.idseqttl,
                   w_cdseqtfc,
                   1,
                   vr_ddd_celular1,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_celular1,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc3_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone celular 1 - ' || SQLERRM;
              END;
                          
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc3_progress_recid||';'||chr(10));
            END IF;
          END IF;
          
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;
          
          IF vr_ddd_celular2 <> 0 AND 
             vr_celular2 <> 0     AND
             vr_celular2 <> vr_celular1 THEN
                
            -- celular 2
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ttl.nrdconta
                 AND tfc.idseqttl = rw_ttl.idseqttl;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;           
             
            -- celular 2
            OPEN cr_craptfc(pr_cdcooper => rw_ttl.cdcooper
                           ,pr_nrdconta => rw_ttl.nrdconta
                           ,pr_idseqttl => rw_ttl.idseqttl
                           ,pr_nrtelefo => vr_celular2 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
              
              vr_craptfc5_insere:= TRUE;
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_celular2),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;
              
              --Inclusão telefone celular 2
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ttl.cdcooper,
                   rw_ttl.nrdconta,
                   rw_ttl.idseqttl,
                   w_cdseqtfc,
                   1,
                   vr_ddd_celular2,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_celular2,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc3_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone celular 2 - ' || SQLERRM;
              END;
                          
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc3_progress_recid||';'||chr(10));
            END IF;
          END IF;
          
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;
           
          IF vr_ddd_celular3 <> 0 AND 
             vr_celular2 <> 0     AND
             vr_celular2 <> vr_celular1 AND
             vr_celular3 <> vr_celular2 THEN
             
            BEGIN
             SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
               INTO w_cdseqtfc
               FROM craptfc tfc
              WHERE tfc.cdcooper = vr_cdcooper
                AND tfc.nrdconta = rw_ttl.nrdconta
                AND tfc.idseqttl = rw_ttl.idseqttl;
             EXCEPTION
               WHEN no_data_found THEN
                 w_cdseqtfc := 1;
               WHEN OTHERS THEN
                 vr_sqlerrm := SQLERRM;
                 RAISE;
            END;     
             
            -- celular 3
            OPEN cr_craptfc(pr_cdcooper => rw_ttl.cdcooper
                           ,pr_nrdconta => rw_ttl.nrdconta
                           ,pr_idseqttl => rw_ttl.idseqttl
                           ,pr_nrtelefo => vr_celular3 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
              
              vr_craptfc6_insere:= true;              
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_celular3),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;
              
              --Inclusão telefone celular 3
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ttl.cdcooper,
                   rw_ttl.nrdconta,
                   rw_ttl.idseqttl,
                   w_cdseqtfc,
                   1,
                   vr_ddd_celular3,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_celular3,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc3_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone celular 3 - ' || SQLERRM;
              END;
                          
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc3_progress_recid||';'||chr(10));
            END IF;
          END IF;
          ------------------------------------------------------------------------------------
          -------------------------------- FIM - TELEFONE ------------------------------------
          ------------------------------------------------------------------------------------        

          ------------------------------------------------------------------------------------
          ----------------------------- INICIO - RENDIMENTOS ---------------------------------
          ------------------------------------------------------------------------------------
/* chw nao importar renda */
/*
          IF vr_renda_ant <> vr_renda THEN
            BEGIN
              UPDATE crapttl ttl
                 SET ttl.vlsalari = vr_renda
               WHERE ttl.progress_recid = rw_ttl.progress_recid
               RETURNING progress_recid INTO vr_crapttl_progress_recid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_sqlerrm := 'Erro ao tentar atualizar renda - ' || SQLERRM;
                RAISE;
            END;
          END IF;
          
          IF cr_crapcje%ISOPEN THEN
            CLOSE cr_crapcje;
          END IF;        
          
          -- Atualizar renda do conjuge
          OPEN cr_crapcje(pr_cdcooper => rw_ttl.cdcooper
                         ,pr_nrdconta => rw_ttl.nrdconta
                         ,pr_nrcpfcjg => rw_ttl.nrcpfcgc);                       
          FETCH cr_crapcje INTO rw_crapcje;

          IF cr_crapcje%FOUND THEN
            CLOSE cr_crapcje;
            
            vr_renda_cje_ant := rw_crapcje.vlsalari;
            vr_crapcje_insere:= TRUE;
            
            IF NVL(vr_renda_cje_ant,0) <> NVL(vr_renda,0) THEN
              BEGIN
                UPDATE crapcje cje
                   SET cje.vlsalari = vr_renda
                 WHERE cje.progress_recid = rw_crapcje.progress_recid
                 RETURNING progress_recid INTO vr_crapcje_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar atualizar renda conjuge - ' || SQLERRM;
                  RAISE;
              END;
            END IF;
          ELSE
            CLOSE cr_crapcje;
          END IF;
*/          
          ------------------------------------------------------------------------------------
          ---------------------------------- FIM RENDIMENTOS ---------------------------------
          ------------------------------------------------------------------------------------
          
          ------------------------------------------------------------------------------------
          ---------------------------------- EMAIL ---------------------------------
          ------------------------------------------------------------------------------------
          IF TRIM(vr_email) IS NOT NULL THEN
            IF cr_crapcem%ISOPEN THEN
              CLOSE cr_crapcem;
            END IF;    
            
            -- email
            OPEN cr_crapcem (pr_cdcooper => rw_ttl.cdcooper
                            ,pr_nrdconta => rw_ttl.nrdconta
                            ,pr_dsdemail => vr_email);
            FETCH cr_crapcem INTO rw_crapcem;
            
            IF cr_crapcem%FOUND THEN
              CLOSE cr_crapcem;
              
              vr_email_ant := rw_crapcem.dsdemail;
              
              IF TRIM(vr_email) <> TRIM(vr_email_ant) THEN
              
                pc_escreve_xml('UPDATE crapcem cem '||
                                  'SET cem.dsdemail = '|| rw_crapcem.dsdemail ||                               
                               ' WHERE cem.progress_recid = '||rw_crapcem.Progress_recid||';'||chr(10));                 

                -- Atualizar Faturamento Anual
                BEGIN
                  UPDATE crapcem cem
                     SET cem.dsdemail = vr_email
                   WHERE cem.progress_recid = rw_crapcem.progress_recid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_sqlerrm := 'Erro ao tentar atualizar E-mail - ' || SQLERRM;
                    RAISE;
                END;
                
                -- Logar alterações        
                pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                           ,pr_nrdconta => rw_ttl.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_dstransa => 'Atualizar e-mail - Boa Vista'
                           ,pr_nmdcampo => 'dsdemail'
                           ,pr_dsdadant => TRIM(vr_email_ant)
                           ,pr_dsdadatu => TRIM(vr_email)
                           ,pr_dslogalt => '[BOA VISTA] email 1.ttl,');
              END IF;  
            
            ELSE      
              CLOSE cr_crapcem;
              BEGIN
                INSERT INTO crapcem
                  (cdoperad,
                   nrdconta,
                   dsdemail,
                   cddemail,
                   dtmvtolt,
                   hrtransa,
                   cdcooper,
                   idseqttl,
                   prgqfalt,
                   nmpescto,
                   secpscto)
                VALUES
                  (1,
                   rw_ttl.nrdconta,
                   vr_email, 
                   (SELECT MAX(nvl(cddemail,0)) + 1
                      FROM crapcem
                     WHERE cdcooper = rw_ttl.cdcooper
                       AND nrdconta = rw_ttl.nrdconta),
                   trunc(SYSDATE),
                   gene0002.fn_busca_time,
                   rw_ttl.cdcooper,
                   1,
                   'A',
                   '',
                   '') RETURNING progress_recid INTO vr_crapcem_progress_recid; 

                -- Logar alterações        
                pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                           ,pr_nrdconta => rw_ttl.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_dstransa => 'Cadastrar e-mail - Boa Vista'
                           ,pr_nmdcampo => 'dsdemail'
                           ,pr_dsdadant => ''
                           ,pr_dsdadatu => TRIM(vr_email)
                           ,pr_dslogalt => '[BOA VISTA] email 1.ttl,');
                 
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir email - ' || SQLERRM;
              END;
                          
              pc_escreve_xml('DELETE crapcem c '||             
                              'WHERE c.progress_recid = '||vr_crapcem_progress_recid||';'||chr(10));
            END IF;
          END IF;
          ------------------------------------------------------------------------------------
          ---------------------------------- FIM EMAIL ---------------------------------
          ------------------------------------------------------------------------------------

/* chw não atualizar renda
          IF NVL(vr_renda_cje_ant,0) <> NVL(vr_renda,0) AND vr_crapcje_insere THEN
            -- Logar alterações        
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl                     
                       ,pr_dstransa => 'Atualizar Renda Conjuge - Boa Vista'
                       ,pr_nmdcampo => 'vlsalari'
                       ,pr_dsdadant => nvl(vr_renda_cje_ant,0)
                       ,pr_dsdadatu => nvl(vr_renda,0)
                       ,pr_dslogalt => '[BOA VISTA] sal. cje.'||to_char(rw_ttl.idseqttl)||'.ttl,');

             -- Registrar rollback caso ocorra algum erro
            pc_escreve_xml('UPDATE crapcje cje '||
                              'SET cje.vlsalari = ' || replace(vr_renda_ant,',','.')||
                           ' WHERE cje.progress_recid = '|| vr_crapcje_progress_recid||';'||chr(10)); 

          END IF;
          
          IF vr_renda_ant <> vr_renda THEN
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Renda - Boa Vista'
                       ,pr_nmdcampo => 'vlsalari'
                       ,pr_dsdadant => nvl(vr_renda_ant,0)
                       ,pr_dsdadatu => nvl(vr_renda,0)
                       ,pr_dslogalt => '[BOA VISTA] salario '||to_char(rw_ttl.idseqttl)||'.ttl,');
            
              -- Registrar rollback caso ocorra algum erro
              pc_escreve_xml(' UPDATE crapttl ttl '||
                                 'SET ttl.vlsalari = '|| replace(vr_renda_ant,',','.')||
                              ' WHERE ttl.progress_recid = '|| vr_crapttl_progress_recid||';'||chr(10));
                                   

          END IF;
  */        
          IF vr_craptfc4_insere THEN
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Celular - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_ddd_celular1,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD '||to_char(rw_ttl.idseqttl)||'.ttl,');
                       
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Celular - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_celular1,'')
                       ,pr_dslogalt => '[BOA VISTA] celular '||to_char(rw_ttl.idseqttl)||'.ttl,');
          END IF; 
          
          IF vr_craptfc5_insere THEN
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Celular - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_ddd_celular2,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD '||to_char(rw_ttl.idseqttl)||'.ttl,');
                       
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Celular - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_celular2,'')
                       ,pr_dslogalt => '[BOA VISTA] celular '||to_char(rw_ttl.idseqttl)||'.ttl,');
          END IF; 
          
          IF vr_craptfc6_insere THEN
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Celular - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_ddd_celular3,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD '||to_char(rw_ttl.idseqttl)||'.ttl,');
                       
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Celular - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_celular3,'')
                       ,pr_dslogalt => '[BOA VISTA] celular '||to_char(rw_ttl.idseqttl)||'.ttl,');
          END IF;          
          
          IF vr_craptfc3_insere THEN
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => nvl(vr_ddd3_ant,'')
                       ,pr_dsdadatu => nvl(vr_ddd3,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD '||to_char(rw_ttl.idseqttl)||'.ttl,');
                       
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => nvl(vr_telefone3_ant,'')
                       ,pr_dsdadatu => nvl(vr_telefone3,'')
                       ,pr_dslogalt => '[BOA VISTA] telefone '||to_char(rw_ttl.idseqttl)||'.ttl,');
          END IF;
          
          IF vr_craptfc2_insere THEN
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => nvl(vr_ddd2_ant,'')
                       ,pr_dsdadatu => nvl(vr_ddd2,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD '||to_char(rw_ttl.idseqttl)||'.ttl,');
          
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => nvl(vr_telefone2_ant,'')
                       ,pr_dsdadatu => nvl(vr_telefone2,'')
                       ,pr_dslogalt => '[BOA VISTA] telefone '||to_char(rw_ttl.idseqttl)||'.ttl,');
          END IF;
          
          IF vr_craptfc1_insere THEN
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => nvl(vr_ddd1_ant,'')
                       ,pr_dsdadatu => nvl(vr_ddd1,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD '||to_char(rw_ttl.idseqttl)||'.ttl,');
          
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => nvl(vr_telefone1_ant,'')
                       ,pr_dsdadatu => nvl(vr_telefone1,'')
                       ,pr_dslogalt => '[BOA VISTA] telefone '||to_char(rw_ttl.idseqttl)||'.ttl,');                 
          END IF;
          
          ------------------------------------------------------------------------------------
          -- Log de atualização do endereço --------------------------------------------------
          ------------------------------------------------------------------------------------
/* chw nao atualizar endereço */
/*
          IF nvl(vr_cep_ant,' ') <> nvl(vr_cep,' ') THEN
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'nrcepend'
                       ,pr_dsdadant => nvl(vr_cep_ant,'')
                       ,pr_dsdadatu => nvl(vr_cep,'')
                       ,pr_dslogalt => '[BOA VISTA] cep compl. '||to_char(rw_ttl.idseqttl)||'.ttl,');
          END IF;             
            
          IF nvl(vr_rua_ant,' ') <> nvl(vr_rua,' ') THEN
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'dsendere'
                       ,pr_dsdadant => nvl(vr_rua_ant,'')
                       ,pr_dsdadatu => nvl(vr_rua,'')
                       ,pr_dslogalt => '[BOA VISTA] endereco compl. '||to_char(rw_ttl.idseqttl)||'.ttl,');
          END IF;
          
          IF vr_numero_ant <> vr_numero THEN
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'nrendere'
                       ,pr_dsdadant => nvl(vr_numero_ant,0)
                       ,pr_dsdadatu => nvl(vr_numero,0)
                       ,pr_dslogalt => '[BOA VISTA] nro.end.compl. '||to_char(rw_ttl.idseqttl)||'.ttl,');
          END IF;
          
          IF nvl(vr_complemento_ant,' ') <> nvl(vr_complemento,' ') THEN             
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'complend'
                       ,pr_dsdadant => nvl(vr_complemento_ant,'')
                       ,pr_dsdadatu => nvl(vr_complemento,'')
                       ,pr_dslogalt => '[BOA VISTA] compl.end.compl. '||to_char(rw_ttl.idseqttl)||'.ttl,');
          END IF;
                 
          IF nvl(vr_bairro_ant,' ') <> nvl(vr_bairro,' ') THEN   
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'nmbairro'
                       ,pr_dsdadant => nvl(vr_bairro_ant,'')
                       ,pr_dsdadatu => nvl(vr_bairro,'')
                       ,pr_dslogalt => '[BOA VISTA] bairro compl. '||to_char(rw_ttl.idseqttl)||'.ttl,');
          END IF;
          
          IF nvl(vr_cidade_ant,' ') <> nvl(vr_cidade,' ') THEN
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'nmcidade'
                       ,pr_dsdadant => nvl(vr_cidade_ant,'')
                       ,pr_dsdadatu => nvl(vr_cidade,'')
                       ,pr_dslogalt => '[BOA VISTA] cidade compl. '||to_char(rw_ttl.idseqttl)||'.ttl,');
          END IF;
          
          IF nvl(vr_estado_ant,' ') <> nvl(vr_estado,' ') THEN     
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'cdufende'
                       ,pr_dsdadant => nvl(vr_estado_ant,'')
                       ,pr_dsdadatu => nvl(vr_estado,'')
                       ,pr_dslogalt => '[BOA VISTA] UF compl. '||to_char(rw_ttl.idseqttl)||'.ttl,');
          END IF;
                 
          IF vr_idorigem <> 3 THEN  
            pc_gera_log(pr_cdcooper => rw_ttl.cdcooper
                       ,pr_nrdconta => rw_ttl.nrdconta
                       ,pr_idseqttl => rw_ttl.idseqttl
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'idorigem'
                       ,pr_dsdadant => nvl(vr_idorigem,0)
                       ,pr_dsdadatu => 3);
          END IF;
fim atualizar endereço */

        END LOOP; -- Loop TTL
      
      END LOOP; -- Loop Arquivo


    EXCEPTION 
      WHEN no_data_found THEN
        -- Fechar o arquivo
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
        -- Fim do arquivo
        dbms_output.put_line('FIM do arquivo');

        pc_escreve_xml('COMMIT;');
        pc_escreve_xml(' ',TRUE);
        DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_nmdireto, to_char(sysdate,'ddmmyyyy_hh24miss')||'_'||vr_nmarqbkp||'_PF.txt', NLS_CHARSET_ID('UTF8'));
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
    END;
  END LOOP; -- Fim Coop  

/***************************************************************************************************************************/
/***************************************************************************************************************************/
/***************************************************************************************************************************/
/***************************************************************************************************************************/
/***************************************************************************************************************************/

  -- Nomenclatura do arquivo da coop AAAAMMDD
  vr_nmarquiv:= 'boa_vista_pj_'||to_char(SYSDATE,'RRRRMMDD')||'.csv';
  
  FOR rw_crapcop IN cr_crapcop LOOP
    -- Gravar cooperativa
    vr_cdcooper:= rw_crapcop.cdcooper;
  
    --Buscar caminho do micros
    vr_nmdireto := gene0001.fn_param_sistema('CRED',vr_cdcooper,'ROOT_MICROS');
    vr_nmdireto := vr_nmdireto||'cpd/bacas/boa_vista/'||rw_crapcop.dsdircop;

     -- Abrir o arquivo PESSOA JURIDICA
     gene0001.pc_abre_arquivo (pr_nmdireto => vr_nmdireto    --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nmarquiv    --> Nome do arquivo
                              ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);  --> Descricao do erro

     -- Se retornou erro
     IF vr_dscritic IS NOT NULL THEN
       CONTINUE;
     END IF;

      -- Inicializar o CLOB
     vr_des_xml := NULL;
     dbms_lob.createtemporary(vr_des_xml, TRUE);
     dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
     vr_texto_completo := NULL;  

    BEGIN
    
      vr_contlinha:= 0;
      
      -- Laco para leitura de linhas do arquivo
      LOOP
        -- Carrega handle do arquivo
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                    ,pr_des_text => vr_setlinha); --> Texto lido

        vr_contlinha:= vr_contlinha + 1;
        
        IF vr_contlinha = 1 THEN
          continue;
        END IF;

        -- Retirar quebra de linha
        vr_setlinha := REPLACE(REPLACE(vr_setlinha,CHR(10)),CHR(13));


        -- Original
        --cpf;CEP;Rua;Numero;Complemento;Bairro;Cidade;Estado;DDD1;Fone1;
        --DDD2;Fone2;DDD3;Fone3;Faturamento Anual;Faturamento Mensal
        
        --Novo
        --CNPJ;CEP;Logradouro;Numero;Complemento;Bairro;Cidade;Estado;DDD1;Telefone1;DDD2;Telefone2;DDD3;
        --Telefone3;DDD_Celular1;Celular1;DDD_Celular2;Celular2;DDD_Celular3;Celular3;DDDContato1;
        --TelefoneContato1;DDDContato2;TelefoneContato2;DDDContato3;TelefoneContato3;DDD_CelularContato1;
        --CelularContato1;DDD_CelularContato2;CelularContato2;DDD_CelularContato3;CelularContato3;
        --Faturamento ano;Email           
        vr_nrcpfcgc := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(1,vr_setlinha,';'));
/*chw nao atualizar endereco
        vr_cep := gene0002.fn_busca_entrada(2,vr_setlinha,';');
        vr_rua := substr(gene0002.fn_busca_entrada(3,vr_setlinha,';'),1,40);
        BEGIN
          vr_numero := nvl(gene0002.fn_busca_entrada(4,vr_setlinha,';'),0);
        EXCEPTION 
          WHEN OTHERS THEN
            vr_numero:= 0;
        END;
        vr_complemento := gene0002.fn_busca_entrada(5,vr_setlinha,';');
        vr_bairro := gene0002.fn_busca_entrada(6,vr_setlinha,';');
        vr_cidade := gene0002.fn_busca_entrada(7,vr_setlinha,';');      
        vr_estado := gene0002.fn_busca_entrada(8,vr_setlinha,';');
*/
        vr_ddd1 := nvl(gene0002.fn_busca_entrada(9,vr_setlinha,';'),'0');      
        vr_telefone1 := nvl(gene0002.fn_busca_entrada(10,vr_setlinha,';'),'0');      
        vr_ddd2 := nvl(gene0002.fn_busca_entrada(11,vr_setlinha,';'),'0');            
        vr_telefone2 := nvl(gene0002.fn_busca_entrada(12,vr_setlinha,';'),'0');            
        vr_ddd3 := nvl(gene0002.fn_busca_entrada(13,vr_setlinha,';'),'0');            
        vr_telefone3 := nvl(gene0002.fn_busca_entrada(14,vr_setlinha,';'),'0');
        --Novo
        vr_ddd_celular1 := nvl(gene0002.fn_busca_entrada(15,vr_setlinha,';'),'0'); 
        vr_celular1     := nvl(gene0002.fn_busca_entrada(16,vr_setlinha,';'),'0'); 
        vr_ddd_celular2 := nvl(gene0002.fn_busca_entrada(17,vr_setlinha,';'),'0'); 
        vr_celular2     := nvl(gene0002.fn_busca_entrada(18,vr_setlinha,';'),'0'); 
        vr_ddd_celular3 := nvl(gene0002.fn_busca_entrada(19,vr_setlinha,';'),'0'); 
        vr_celular3     := nvl(gene0002.fn_busca_entrada(20,vr_setlinha,';'),'0');             
        -- Fim Novo
        
        -- Contato Novo         
        vr_ddd_contato1 := nvl(gene0002.fn_busca_entrada(21,vr_setlinha,';'),'0');      
        vr_telefone_contato1 := nvl(gene0002.fn_busca_entrada(22,vr_setlinha,';'),'0');      
        vr_ddd_contato2 := nvl(gene0002.fn_busca_entrada(23,vr_setlinha,';'),'0');            
        vr_telefone_contato2 := nvl(gene0002.fn_busca_entrada(24,vr_setlinha,';'),'0');            
        vr_ddd_contato3 := nvl(gene0002.fn_busca_entrada(25,vr_setlinha,';'),'0');            
        vr_telefone_contato3 := nvl(gene0002.fn_busca_entrada(26,vr_setlinha,';'),'0');
        --Novo
        vr_ddd_celular_contato1 := nvl(gene0002.fn_busca_entrada(27,vr_setlinha,';'),'0'); 
        vr_celular_contato1     := nvl(gene0002.fn_busca_entrada(28,vr_setlinha,';'),'0'); 
        vr_ddd_celular_contato2 := nvl(gene0002.fn_busca_entrada(29,vr_setlinha,';'),'0'); 
        vr_celular_contato2     := nvl(gene0002.fn_busca_entrada(30,vr_setlinha,';'),'0'); 
        vr_ddd_celular_contato3 := nvl(gene0002.fn_busca_entrada(31,vr_setlinha,';'),'0'); 
        vr_celular_contato3     := nvl(gene0002.fn_busca_entrada(32,vr_setlinha,';'),'0');    
        -- Fim contato Novo

/* chw nao atualizar faturamento        
        BEGIN 
          vr_fat_anual := gene0002.fn_busca_entrada(33,vr_setlinha,';');       
        EXCEPTION
          WHEN OTHERS THEN
             vr_fat_anual := 0;       
        END;
*/        
        --EMAIL
        vr_email                := gene0002.fn_busca_entrada(34,vr_setlinha,';');
        
       -- BEGIN 
       --   vr_fat_mensal := gene0002.fn_busca_entrada(34,vr_setlinha,';');   
       -- EXCEPTION
       --   WHEN OTHERS THEN
       --     vr_fat_mensal:= 0;
       -- END;
        
        vr_crapenc_insere  := FALSE;      
        vr_craptfc1_insere := FALSE;
        vr_craptfc2_insere := FALSE;
        vr_craptfc3_insere := FALSE;
        vr_craptfc4_insere := FALSE;
        vr_craptfc5_insere := FALSE;
        vr_craptfc6_insere := FALSE;
        vr_craptfc7_insere := FALSE;
        vr_craptfc8_insere := FALSE;
        vr_craptfc9_insere := FALSE;
        vr_craptfc10_insere := FALSE;
        vr_craptfc11_insere := FALSE;
        vr_craptfc12_insere := FALSE;
        
        FOR rw_ass IN cr_crapass (pr_nrcpfcgc => vr_nrcpfcgc) LOOP
          
          IF rw_ass.inpessoa = 1 THEN
            CONTINUE;        
          END IF;
          
          vr_cep_ant         := ' ';
          vr_rua_ant         := ' ';
          vr_numero_ant      := 0;
          vr_complemento_ant := ' ';
          vr_bairro_ant      := ' ';
          vr_cidade_ant      := ' ';
          vr_estado_ant      := ' ';
          vr_ddd1_ant        := 0;
          vr_telefone1_ant   := 0;
          vr_ddd2_ant        := 0;
          vr_telefone2_ant   := 0;
          vr_ddd3_ant        := 0;          
          vr_telefone3_ant   := 0;
          vr_ddd4_ant        := 0;
          vr_telefone4_ant   := 0;
          vr_ddd5_ant        := 0;
          vr_telefone5_ant   := 0;
        
          ------------------------------------------------------------------------------------
          -------------------------------- Atualizar Endereço --------------------------------
          ------------------------------------------------------------------------------------

/* chw nao atualizar endereço */
/*
          IF cr_crapenc%ISOPEN THEN
            CLOSE cr_crapenc;
          END IF;
          
          OPEN cr_crapenc(pr_cdcooper => rw_ass.cdcooper
                         ,pr_nrdconta => rw_ass.nrdconta
                         ,pr_idseqttl => 1
                         ,pr_tpendass => 14);
          FETCH cr_crapenc INTO rw_crapenc;
          -- Caso exista, vamos atualizar
          IF cr_crapenc%FOUND THEN
            -- Fecha CURSOR
            CLOSE cr_crapenc;
            vr_crapenc_insere := TRUE;
            
              vr_cep_ant         := to_char(rw_crapenc.nrcepend);
              vr_rua_ant         := rw_crapenc.dsendere;
              vr_numero_ant      := rw_crapenc.nrendere;
              vr_complemento_ant := rw_crapenc.complend;
              vr_bairro_ant      := rw_crapenc.nmbairro;
              vr_cidade_ant      := rw_crapenc.nmcidade;
              vr_estado_ant      := rw_crapenc.cdufende;       
              vr_idorigem        := rw_crapenc.idorigem;     
            
            BEGIN
              UPDATE crapenc c
                 SET c.nrcepend = vr_cep
                    ,c.dsendere = vr_rua
                    ,c.nrendere = vr_numero
                    ,c.complend = vr_complemento
                    ,c.nmbairro = vr_bairro
                    ,c.nmcidade = vr_cidade
                    ,c.cdufende = vr_estado
                    ,c.dtaltenc = trunc(SYSDATE)
                    ,c.idorigem = 3 -- 1-Cooperado,2-Cooperativa,3-Terceiros
               WHERE c.progress_recid = rw_crapenc.progress_recid
               RETURNING progress_recid INTO vr_crapenc_progress_recid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_sqlerrm := 'Erro ao tentar atualizar Endereço PJ - ' || SQLERRM;
                RAISE;
            END;
            
            pc_escreve_xml('UPDATE crapenc c '||
                              'SET c.nrcepend = '||vr_cep_ant||',
                                   c.dsendere = '''||vr_rua_ant||''',
                                   c.nrendere = '||vr_numero_ant||',
                                   c.complend = '''||vr_complemento_ant||''',
                                   c.nmbairro = '''||vr_bairro_ant||''',
                                   c.nmcidade = '''||vr_cidade_ant||''',
                                   c.cdufende = '''||vr_estado_ant||''',
                                   c.dtaltenc = '''||vr_dtaltenc_ant||''',
                                   c.idorigem = '||vr_idorigem||
                            ' WHERE c.progress_recid = '||vr_crapenc_progress_recid||';'||chr(10));             
            
          ELSE
            -- Fecha CURSOR
            CLOSE cr_crapenc;
            vr_crapenc_insere := FALSE;
            
            BEGIN
              SELECT nvl(MAX(c.cdseqinc) + 1, 1)
                INTO w_cdseqinc
                FROM crapenc c
               WHERE c.cdcooper = rw_ass.cdcooper
                 AND c.nrdconta = rw_ass.nrdconta
                 AND c.idseqttl = 1;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqinc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;
            
            --Inclusão Endereço
            BEGIN
              INSERT INTO crapenc
                (cdcooper,
                 nrdconta,
                 idseqttl,
                 tpendass,
                 cdseqinc,
                 dsendere,
                 nrendere,
                 complend,
                 nmbairro,
                 nmcidade,
                 cdufende,
                 nrcepend,
                 dtaltenc,
                 idorigem)
              VALUES
                (rw_ass.cdcooper,
                 rw_ass.nrdconta,
                 1,
                 14, -- 13-Correspondencia, 14-complementar
                 w_cdseqinc,
                 vr_rua,
                 vr_numero,
                 vr_complemento,
                 vr_bairro,
                 vr_cidade,
                 vr_estado,
                 vr_cep,
                 trunc(SYSDATE),
                 3)
                 RETURNING progress_recid INTO vr_crapenc_progress_recid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_sqlerrm := 'Erro ao tentar inserir endereço PJ - ' || SQLERRM;
                RAISE;
            END;
           
            pc_escreve_xml('DELETE crapenc WHERE progress_recid = '||vr_crapenc_progress_recid||';'||chr(10));
          END IF;
          
chw fim nao atalizar endereco */
          ------------------------------------------------------------------------------------
          ----------------------------- FIM - Atualizar Endereço -----------------------------
          ------------------------------------------------------------------------------------
          
          ------------------------------------------------------------------------------------
          ----------------------------- INICIO - TELEFONE ------------------------------------
          ------------------------------------------------------------------------------------
          
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;        
          
          vr_tptelefo:= 4;
          
          IF vr_ddd1 <> 0 AND 
             vr_telefone1 <> 0 THEN
          
            -- Telefone 1
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ass.nrdconta
                 AND tfc.idseqttl = 1;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;           
             
            -- Telefone 1
            OPEN cr_craptfc(pr_cdcooper => rw_ass.cdcooper
                           ,pr_nrdconta => rw_ass.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_nrtelefo => vr_telefone1 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
             
              vr_craptfc1_insere := TRUE;   
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_telefone1),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;
            
              --Inclusão telefone 1
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ass.cdcooper,
                   rw_ass.nrdconta,
                   1,
                   w_cdseqtfc,
                   1,
                   vr_ddd1,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_telefone1,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc1_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone PJ - ' || SQLERRM;
                  RAISE;
              END;            
                          
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc1_progress_recid||';'||chr(10));
            END IF;
          END IF;
          
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;    
          
          IF vr_ddd2 <> 0 AND 
             vr_telefone2 <> 0 AND
             vr_telefone2 <> vr_telefone1 THEN 
             
            -- Telefone 2
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ass.nrdconta
                 AND tfc.idseqttl = 1;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;           
             
            -- Telefone 2
            OPEN cr_craptfc(pr_cdcooper => rw_ass.cdcooper
                           ,pr_nrdconta => rw_ass.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_nrtelefo => vr_telefone2 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
             
              vr_craptfc2_insere := TRUE;    
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_telefone2),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;      
                        
              --Inclusão telefone 2
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ass.cdcooper,
                   rw_ass.nrdconta,
                   1,
                   w_cdseqtfc,
                   1,
                   vr_ddd2,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_telefone2,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc2_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone PJ - ' || SQLERRM;
                  RAISE;
              END;
                          
              pc_escreve_xml('DELETE craptfc c'||              
                             ' WHERE c.progress_recid = '||vr_craptfc2_progress_recid||';'||chr(10));
            END IF;
          END IF;  
          
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;            
          
          IF vr_ddd3 <> 0 AND 
             vr_telefone3 <> 0 AND
             vr_telefone3 <> vr_telefone1 AND
             vr_telefone3 <> vr_telefone2 THEN
          
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ass.nrdconta
                 AND tfc.idseqttl = 1;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;           
             
            -- Telefone 3
            OPEN cr_craptfc(pr_cdcooper => rw_ass.cdcooper
                           ,pr_nrdconta => rw_ass.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_nrtelefo => vr_telefone3 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;            
             
              vr_craptfc3_insere := TRUE;          
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_telefone3),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;
              
              --Inclusão telefone 3
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ass.cdcooper,
                   rw_ass.nrdconta,
                   1,
                   w_cdseqtfc,
                   1,
                   vr_ddd3,
                   vr_tptelefo, 
                   ' ',
                   'A',
                   vr_telefone3,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc3_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone PJ - ' || SQLERRM;
              END;
                          
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc3_progress_recid||';'||chr(10));
            END IF;          
          END IF;
          
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;
          
          IF vr_ddd_celular1 <> 0 AND 
             vr_celular1 <> 0     THEN
                
            -- celular 1
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ass.nrdconta
                 AND tfc.idseqttl = 1;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;           
             
            -- celular 1
            OPEN cr_craptfc(pr_cdcooper => rw_ass.cdcooper
                           ,pr_nrdconta => rw_ass.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_nrtelefo => vr_celular1 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
              
              vr_craptfc4_insere:= true;
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_celular1),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;
              
              --Inclusão telefone celular 1
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ass.cdcooper,
                   rw_ass.nrdconta,
                   1,
                   w_cdseqtfc,
                   1,
                   vr_ddd_celular1,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_celular1,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc3_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone celular 1 - ' || SQLERRM;
              END;
                          
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc3_progress_recid||';'||chr(10));
            END IF;
          END IF;

          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;
          
          IF vr_ddd_celular2 <> 0 AND 
             vr_celular2 <> 0     AND
             vr_celular2 <> vr_celular1 THEN
                
            -- celular 2
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ass.nrdconta
                 AND tfc.idseqttl = 1;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;           
             
            -- celular 2
            OPEN cr_craptfc(pr_cdcooper => rw_ass.cdcooper
                           ,pr_nrdconta => rw_ass.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_nrtelefo => vr_celular2 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
              
              vr_craptfc5_insere:= TRUE;
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_celular2),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;
              
              --Inclusão telefone celular 2
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ass.cdcooper,
                   rw_ass.nrdconta,
                   1,
                   w_cdseqtfc,
                   1,
                   vr_ddd_celular2,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_celular2,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc3_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone celular 2 - ' || SQLERRM;
              END;
                          
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc3_progress_recid||';'||chr(10));
            END IF;
          END IF;
           
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;
          
          IF vr_ddd_celular3 <> 0 AND 
             vr_celular2 <> 0     AND
             vr_celular2 <> vr_celular1 AND
             vr_celular3 <> vr_celular2 THEN
             
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ass.nrdconta
                 AND tfc.idseqttl = 1;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;     
             
            -- celular 3
            OPEN cr_craptfc(pr_cdcooper => rw_ass.cdcooper
                           ,pr_nrdconta => rw_ass.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_nrtelefo => vr_celular3 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
              
              vr_craptfc6_insere:= true;              
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_celular3),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;
              
              --Inclusão telefone celular 3
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ass.cdcooper,
                   rw_ass.nrdconta,
                   1,
                   w_cdseqtfc,
                   1,
                   vr_ddd_celular3,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_celular3,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc3_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone celular 3 - ' || SQLERRM;
              END;
                          
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc3_progress_recid||';'||chr(10));
            END IF;
          END IF;
          
          
          -- NOVO
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;        
          
          vr_tptelefo:= 4;
          
          IF vr_ddd_contato1 <> 0 AND 
             vr_telefone_contato1 <> 0 THEN
          
            -- Telefone 1
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ass.nrdconta
                 AND tfc.idseqttl = 1;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;           
             
            -- Telefone 1
            OPEN cr_craptfc(pr_cdcooper => rw_ass.cdcooper
                           ,pr_nrdconta => rw_ass.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_nrtelefo => vr_telefone_contato1 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
             
              vr_craptfc7_insere := TRUE;   
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_telefone_contato1),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;
            
              --Inclusão telefone 1
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ass.cdcooper,
                   rw_ass.nrdconta,
                   1,
                   w_cdseqtfc,
                   1,
                   vr_ddd_contato1,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_telefone_contato1,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc1_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone PJ - ' || SQLERRM;
                  RAISE;
              END;            
                          
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc1_progress_recid||';'||chr(10));
            END IF;
          END IF;
          
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;    
          
          IF vr_ddd_contato2 <> 0 AND 
             vr_telefone_contato2 <> 0 AND
             vr_telefone_contato2 <> vr_telefone_contato1 THEN 
             
            -- Telefone 2
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ass.nrdconta
                 AND tfc.idseqttl = 1;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;           
             
            -- Telefone 2
            OPEN cr_craptfc(pr_cdcooper => rw_ass.cdcooper
                           ,pr_nrdconta => rw_ass.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_nrtelefo => vr_telefone_contato2 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
             
              vr_craptfc8_insere := TRUE;    
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_telefone_contato2),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;      
                        
              --Inclusão telefone 2
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ass.cdcooper,
                   rw_ass.nrdconta,
                   1,
                   w_cdseqtfc,
                   1,
                   vr_ddd_contato2,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_telefone_contato2,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc2_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone PJ - ' || SQLERRM;
                  RAISE;
              END;
                          
              pc_escreve_xml('DELETE craptfc c'||              
                             ' WHERE c.progress_recid = '||vr_craptfc2_progress_recid||';'||chr(10));
            END IF;
          END IF;  
          
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;            
          
          IF vr_ddd_contato3 <> 0 AND 
             vr_telefone_contato3 <> 0 AND
             vr_telefone_contato3 <> vr_telefone_contato1 AND
             vr_telefone_contato3 <> vr_telefone_contato2 THEN
          
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ass.nrdconta
                 AND tfc.idseqttl = 1;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;           
             
            -- Telefone 3
            OPEN cr_craptfc(pr_cdcooper => rw_ass.cdcooper
                           ,pr_nrdconta => rw_ass.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_nrtelefo => vr_telefone_contato3 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;            
             
              vr_craptfc9_insere := TRUE;          
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_telefone_contato3),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;
              
              --Inclusão telefone 3
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ass.cdcooper,
                   rw_ass.nrdconta,
                   1,
                   w_cdseqtfc,
                   1,
                   vr_ddd_contato3,
                   vr_tptelefo, 
                   ' ',
                   'A',
                   vr_telefone_contato3,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc3_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone PJ - ' || SQLERRM;
              END;
                          
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc3_progress_recid||';'||chr(10));
            END IF;          
          END IF;
          
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;
          
          IF vr_ddd_celular_contato1 <> 0 AND 
             vr_celular_contato1 <> 0     THEN
                
            -- celular 1
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ass.nrdconta
                 AND tfc.idseqttl = 1;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;           
             
            -- celular 1
            OPEN cr_craptfc(pr_cdcooper => rw_ass.cdcooper
                           ,pr_nrdconta => rw_ass.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_nrtelefo => vr_celular_contato1 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
              
              vr_craptfc10_insere:= true;
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_celular_contato1),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;
              
              --Inclusão telefone celular 1
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ass.cdcooper,
                   rw_ass.nrdconta,
                   1,
                   w_cdseqtfc,
                   1,
                   vr_ddd_celular_contato1,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_celular_contato1,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc3_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone celular 1 - ' || SQLERRM;
              END;
                          
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc3_progress_recid||';'||chr(10));
            END IF;
          END IF;
          
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;
          
          IF vr_ddd_celular_contato2 <> 0 AND 
             vr_celular_contato2 <> 0     AND
             vr_celular_contato2 <> vr_celular_contato1 THEN
                
            -- celular 2
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ass.nrdconta
                 AND tfc.idseqttl = 1;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;           
             
            -- celular 2
            OPEN cr_craptfc(pr_cdcooper => rw_ass.cdcooper
                           ,pr_nrdconta => rw_ass.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_nrtelefo => vr_celular_contato2 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
              
              vr_craptfc11_insere:= TRUE;
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_celular_contato2),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;
              
              --Inclusão telefone celular 2
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ass.cdcooper,
                   rw_ass.nrdconta,
                   1,
                   w_cdseqtfc,
                   1,
                   vr_ddd_celular_contato2,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_celular_contato2,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc3_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone celular 2 - ' || SQLERRM;
              END;
                          
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc3_progress_recid||';'||chr(10));
            END IF;
          END IF;
           
          IF cr_craptfc%ISOPEN THEN
            CLOSE cr_craptfc;
          END IF;
          
          IF vr_ddd_celular_contato3 <> 0 AND 
             vr_celular_contato2 <> 0     AND
             vr_celular_contato2 <> vr_celular_contato1 AND
             vr_celular_contato3 <> vr_celular_contato2 THEN
             
            BEGIN
              SELECT nvl(MAX(tfc.cdseqtfc) + 1, 1)
                INTO w_cdseqtfc
                FROM craptfc tfc
               WHERE tfc.cdcooper = vr_cdcooper
                 AND tfc.nrdconta = rw_ass.nrdconta
                 AND tfc.idseqttl = 1;
            EXCEPTION
              WHEN no_data_found THEN
                w_cdseqtfc := 1;
              WHEN OTHERS THEN
                vr_sqlerrm := SQLERRM;
                RAISE;
            END;     
             
            -- celular 3
            OPEN cr_craptfc(pr_cdcooper => rw_ass.cdcooper
                           ,pr_nrdconta => rw_ass.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_nrtelefo => vr_celular_contato3 );
            FETCH cr_craptfc INTO rw_craptfc;

            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
              
              vr_craptfc12_insere:= true;              
              
              -- Se iniciar com 9 considerar celular
              IF substr(trim(vr_celular_contato3),1,1) = '9' THEN
                vr_tptelefo:= 2; -- Celular
              ELSE
                vr_tptelefo:= 4; -- Contato
              END IF;
              
              --Inclusão telefone celular 3
              BEGIN
                INSERT INTO craptfc
                  (cdcooper,
                   nrdconta,
                   idseqttl,
                   cdseqtfc,
                   cdopetfn,
                   nrdddtfc,
                   tptelefo,
                   nmpescto,
                   prgqfalt,
                   nrtelefo,
                   nrdramal,
                   secpscto,
                   idsittfc,
                   idorigem)
                VALUES
                  (rw_ass.cdcooper,
                   rw_ass.nrdconta,
                   1,
                   w_cdseqtfc,
                   1,
                   vr_ddd_celular_contato3,
                   vr_tptelefo,
                   ' ',
                   'A',
                   vr_celular_contato3,
                   0,
                   ' ',
                   1,
                   3)
                   RETURNING progress_recid INTO vr_craptfc3_progress_recid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir telefone celular 3 - ' || SQLERRM;
              END;
                          
              pc_escreve_xml('DELETE craptfc c '||             
                              'WHERE c.progress_recid = '||vr_craptfc3_progress_recid||';'||chr(10));
            END IF;
          END IF;
          -- Fim Novo
          
          ------------------------------------------------------------------------------------
          -------------------------------- FIM - TELEFONE ------------------------------------
          ------------------------------------------------------------------------------------        

          ------------------------------------------------------------------------------------
          ----------------------------- INICIO - RENDIMENTOS ---------------------------------
          ------------------------------------------------------------------------------------
/* chw não atualizar rendimentos  */          
/*
          IF vr_fat_anual <> 0 THEN
          
            IF cr_crapjur%ISOPEN THEN
              CLOSE cr_crapjur;
            END IF;    
            
            -- Rendimento anual
            OPEN cr_crapjur (pr_cdcooper => rw_ass.cdcooper
                            ,pr_nrdconta => rw_ass.nrdconta);
            FETCH cr_crapjur INTO rw_crapjur;
            
            IF cr_crapjur%FOUND THEN
              CLOSE cr_crapjur;
              
              vr_fat_anual_ant:= rw_crapjur.vlfatano;
              
              IF NVL(vr_fat_anual,0) <> NVL(vr_fat_anual_ant,0) THEN
              
                pc_escreve_xml('UPDATE crapjur jur '||
                                  'SET jur.vlfatano = '||replace(rw_crapjur.vlfatano,',','.')||                               
                               ' WHERE jur.progress_recid = '||rw_crapjur.Progress_recid||';'||chr(10));                 

                -- Atualizar Faturamento Anual
                BEGIN
                  UPDATE crapjur jur
                     SET jur.vlfatano = vr_fat_anual
                   WHERE jur.progress_recid = rw_crapjur.progress_recid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_sqlerrm := 'Erro ao tentar atualizar Faturamento Anual - ' || SQLERRM;
                    RAISE;
                END;
                
                -- Logar alterações        
                pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                           ,pr_nrdconta => rw_ass.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_dstransa => 'Atualizar Faturamento Anual - Boa Vista'
                           ,pr_nmdcampo => 'vlfatano'
                           ,pr_dsdadant => nvl(vr_fat_anual_ant,0)
                           ,pr_dsdadatu => nvl(vr_fat_anual,0)
                           ,pr_dslogalt => '[BOA VISTA] faturamento ano 1.ttl,');
              END IF;  
            
            ELSE      
              CLOSE cr_crapjur;
            END IF;
          END IF;
          
          IF vr_fat_mensal <> 0 THEN
            IF cr_crapjfn%ISOPEN THEN
              CLOSE cr_crapjfn;
            END IF;            
            
            -- Rendimento mensal
            OPEN cr_crapjfn (pr_cdcooper => rw_ass.cdcooper
                            ,pr_nrdconta => rw_ass.nrdconta);                          
            FETCH cr_crapjfn INTO rw_crapjfn;
             
            IF cr_crapjfn%FOUND THEN
              CLOSE cr_crapjfn;
              
              pc_escreve_xml('UPDATE crapjfn jfn '||
                                'SET jfn.mesftbru##1 = '||rw_crapjfn.mesftbru##1||
                                   ',jfn.anoftbru##1 = '||rw_crapjfn.anoftbru##1||
                                   ',jfn.vlrftbru##1 = '||replace(rw_crapjfn.vlrftbru##1,',','.')||
                                   ',jfn.mesftbru##2 = '||rw_crapjfn.mesftbru##2||
                                   ',jfn.anoftbru##2 = '||rw_crapjfn.anoftbru##2||
                                   ',jfn.vlrftbru##2 = '||replace(rw_crapjfn.vlrftbru##2,',','.')||
                                   ',jfn.mesftbru##3 = '||rw_crapjfn.mesftbru##3||
                                   ',jfn.anoftbru##3 = '||rw_crapjfn.anoftbru##3||
                                   ',jfn.vlrftbru##3 = '||replace(rw_crapjfn.vlrftbru##3,',','.')||
                                   ',jfn.mesftbru##4 = '||rw_crapjfn.mesftbru##4||
                                   ',jfn.anoftbru##4 = '||rw_crapjfn.anoftbru##4||
                                   ',jfn.vlrftbru##4 = '||replace(rw_crapjfn.vlrftbru##4,',','.')||
                                   ',jfn.mesftbru##5 = '||rw_crapjfn.mesftbru##5||
                                   ',jfn.anoftbru##5 = '||rw_crapjfn.anoftbru##5||
                                   ',jfn.vlrftbru##5 = '||replace(rw_crapjfn.vlrftbru##5,',','.')||
                                   ',jfn.mesftbru##6 = '||rw_crapjfn.mesftbru##6||
                                   ',jfn.anoftbru##6 = '||rw_crapjfn.anoftbru##6||
                                   ',jfn.vlrftbru##6 = '||replace(rw_crapjfn.vlrftbru##6,',','.')||                               
                                   ',jfn.mesftbru##7 = '||rw_crapjfn.mesftbru##7||
                                   ',jfn.anoftbru##7 = '||rw_crapjfn.anoftbru##7||
                                   ',jfn.vlrftbru##7 = '||replace(rw_crapjfn.vlrftbru##7,',','.')||
                                   ',jfn.mesftbru##8 = '||rw_crapjfn.mesftbru##8||
                                   ',jfn.anoftbru##8 = '||rw_crapjfn.anoftbru##8||
                                   ',jfn.vlrftbru##8 = '||replace(rw_crapjfn.vlrftbru##8,',','.')||
                                   ',jfn.mesftbru##9 = '||rw_crapjfn.mesftbru##9||
                                   ',jfn.anoftbru##9 = '||rw_crapjfn.anoftbru##9||
                                   ',jfn.vlrftbru##9 = '||replace(rw_crapjfn.vlrftbru##9,',','.')||
                                   ',jfn.mesftbru##10 = '||rw_crapjfn.mesftbru##10||
                                   ',jfn.anoftbru##10 = '||rw_crapjfn.anoftbru##10||
                                   ',jfn.vlrftbru##10 = '||replace(rw_crapjfn.vlrftbru##10,',','.')||
                                   ',jfn.mesftbru##11 = '||rw_crapjfn.mesftbru##11||
                                   ',jfn.anoftbru##11 = '||rw_crapjfn.anoftbru##11||
                                   ',jfn.vlrftbru##11 = '||replace(rw_crapjfn.vlrftbru##11,',','.')||
                                   ',jfn.mesftbru##12 = '||rw_crapjfn.mesftbru##12||
                                   ',jfn.anoftbru##12 = '||rw_crapjfn.anoftbru##12||
                                   ',jfn.vlrftbru##12 = '||replace(rw_crapjfn.vlrftbru##12,',','.')||
                              ' WHERE jfn.progress_recid = '||rw_crapjfn.Progress_recid||';'||chr(10));   
              
                -- Zera invalidos
                pc_zera_invalidos(pr_cdcooper => rw_ass.cdcooper
                                 ,pr_nrdconta => rw_ass.nrdconta);
                
                pc_verifica_faturamento(pr_cdcooper => rw_ass.cdcooper
                                       ,pr_nrdconta => rw_ass.nrdconta
                                       ,pr_mes      => 1
                                       ,pr_ano      => '2017'
                                       ,pr_vlrftmes => vr_fat_mensal
                                       ,pr_indice   => vr_indice
                                       ,pr_mesftbru => vr_mesftbru
                                       ,pr_anoftbru => vr_anoftbru
                                       ,pr_vlrftbru => vr_vlrftbru);        
                     
               pc_verifica_faturamento( pr_cdcooper => rw_ass.cdcooper
                                       ,pr_nrdconta => rw_ass.nrdconta
                                       ,pr_mes      => 2
                                       ,pr_ano      => '2017'
                                       ,pr_vlrftmes => vr_fat_mensal                                       
                                       ,pr_indice   => vr_indice
                                       ,pr_mesftbru => vr_mesftbru
                                       ,pr_anoftbru => vr_anoftbru
                                       ,pr_vlrftbru => vr_vlrftbru);
                     
               pc_verifica_faturamento( pr_cdcooper => rw_ass.cdcooper
                                       ,pr_nrdconta => rw_ass.nrdconta
                                       ,pr_mes      => 3
                                       ,pr_ano      => '2017'
                                       ,pr_vlrftmes => vr_fat_mensal                                           
                                       ,pr_indice   => vr_indice
                                       ,pr_mesftbru => vr_mesftbru
                                       ,pr_anoftbru => vr_anoftbru
                                       ,pr_vlrftbru => vr_vlrftbru);
                     
               pc_verifica_faturamento( pr_cdcooper => rw_ass.cdcooper
                                       ,pr_nrdconta => rw_ass.nrdconta
                                       ,pr_mes      => 4
                                       ,pr_ano      => '2017'
                                       ,pr_vlrftmes => vr_fat_mensal                                           
                                       ,pr_indice   => vr_indice
                                       ,pr_mesftbru => vr_mesftbru
                                       ,pr_anoftbru => vr_anoftbru
                                       ,pr_vlrftbru => vr_vlrftbru);         
                     
               pc_verifica_faturamento( pr_cdcooper => rw_ass.cdcooper
                                       ,pr_nrdconta => rw_ass.nrdconta
                                       ,pr_mes      => 5
                                       ,pr_ano      => '2017'
                                       ,pr_vlrftmes => vr_fat_mensal                                           
                                       ,pr_indice   => vr_indice
                                       ,pr_mesftbru => vr_mesftbru
                                       ,pr_anoftbru => vr_anoftbru
                                       ,pr_vlrftbru => vr_vlrftbru);
                     
               pc_verifica_faturamento( pr_cdcooper => rw_ass.cdcooper
                                       ,pr_nrdconta => rw_ass.nrdconta
                                       ,pr_mes      => 6
                                       ,pr_ano      => '2017'
                                       ,pr_vlrftmes => vr_fat_mensal                                           
                                       ,pr_indice   => vr_indice
                                       ,pr_mesftbru => vr_mesftbru
                                       ,pr_anoftbru => vr_anoftbru
                                       ,pr_vlrftbru => vr_vlrftbru);
                                 
               pc_verifica_faturamento( pr_cdcooper => rw_ass.cdcooper
                                       ,pr_nrdconta => rw_ass.nrdconta
                                       ,pr_mes      => 7
                                       ,pr_ano      => '2017'
                                       ,pr_vlrftmes => vr_fat_mensal                                           
                                       ,pr_indice   => vr_indice
                                       ,pr_mesftbru => vr_mesftbru
                                       ,pr_anoftbru => vr_anoftbru
                                       ,pr_vlrftbru => vr_vlrftbru);
                
               pc_verifica_faturamento( pr_cdcooper => rw_ass.cdcooper
                                       ,pr_nrdconta => rw_ass.nrdconta
                                       ,pr_mes      => 8
                                       ,pr_ano      => '2017'
                                       ,pr_vlrftmes => vr_fat_mensal                                           
                                       ,pr_indice   => vr_indice
                                       ,pr_mesftbru => vr_mesftbru
                                       ,pr_anoftbru => vr_anoftbru
                                       ,pr_vlrftbru => vr_vlrftbru);
                 
               pc_verifica_faturamento( pr_cdcooper => rw_ass.cdcooper
                                       ,pr_nrdconta => rw_ass.nrdconta
                                       ,pr_mes      => 9
                                       ,pr_ano      => '2016'
                                       ,pr_vlrftmes => vr_fat_mensal                                           
                                       ,pr_indice   => vr_indice
                                       ,pr_mesftbru => vr_mesftbru
                                       ,pr_anoftbru => vr_anoftbru
                                       ,pr_vlrftbru => vr_vlrftbru);
                                           
               pc_verifica_faturamento( pr_cdcooper => rw_ass.cdcooper
                                       ,pr_nrdconta => rw_ass.nrdconta
                                       ,pr_mes      => 10
                                       ,pr_ano      => '2016'
                                       ,pr_vlrftmes => vr_fat_mensal                                           
                                       ,pr_indice   => vr_indice
                                       ,pr_mesftbru => vr_mesftbru
                                       ,pr_anoftbru => vr_anoftbru
                                       ,pr_vlrftbru => vr_vlrftbru);
                   
               pc_verifica_faturamento( pr_cdcooper => rw_ass.cdcooper
                                       ,pr_nrdconta => rw_ass.nrdconta
                                       ,pr_mes      => 11
                                       ,pr_ano      => '2016'
                                       ,pr_vlrftmes => vr_fat_mensal                                           
                                       ,pr_indice   => vr_indice
                                       ,pr_mesftbru => vr_mesftbru
                                       ,pr_anoftbru => vr_anoftbru
                                       ,pr_vlrftbru => vr_vlrftbru);
                                           
               pc_verifica_faturamento( pr_cdcooper => rw_ass.cdcooper
                                       ,pr_nrdconta => rw_ass.nrdconta
                                       ,pr_mes      => 12
                                       ,pr_ano      => '2016'
                                       ,pr_vlrftmes => vr_fat_mensal                                           
                                       ,pr_indice   => vr_indice
                                       ,pr_mesftbru => vr_mesftbru
                                       ,pr_anoftbru => vr_anoftbru
                                       ,pr_vlrftbru => vr_vlrftbru);

            ELSE
              CLOSE cr_crapjfn;
              
              BEGIN
                INSERT INTO crapjfn
                  (cdcooper,
                   nrdconta,
                   mesftbru##1,
                   mesftbru##2,
                   mesftbru##3,
                   mesftbru##4,
                   mesftbru##5,
                   mesftbru##6,
                   mesftbru##7,
                   mesftbru##8,
                   mesftbru##9,
                   mesftbru##10,
                   mesftbru##11,
                   mesftbru##12,
                   anoftbru##1,
                   anoftbru##2,
                   anoftbru##3,
                   anoftbru##4,
                   anoftbru##5,
                   anoftbru##6,
                   anoftbru##7,
                   anoftbru##8,
                   anoftbru##9,
                   anoftbru##10,
                   anoftbru##11,
                   anoftbru##12,
                   vlrftbru##1,
                   vlrftbru##2,
                   vlrftbru##3,
                   vlrftbru##4,
                   vlrftbru##5,
                   vlrftbru##6,
                   vlrftbru##7,
                   vlrftbru##8,
                   vlrftbru##9,
                   vlrftbru##10,
                   vlrftbru##11,
                   vlrftbru##12,
                   dtaltjfn##1,
                   dtaltjfn##2,
                   dtaltjfn##3,
                   dtaltjfn##4,
                   cdopejfn##1,
                   cdopejfn##2,
                   cdopejfn##3,
                   cdopejfn##4)
                VALUES
                  (vr_cdcooper,
                   rw_ass.nrdconta,
                   1,
                   2,
                   3,
                   4,
                   5,
                   6,
                   7,
                   8,
                   9,
                   10,
                   11,
                   12,
                   2017,
                   2017,
                   2017,
                   2017,
                   2017,
                   2017,
                   2017,
                   2017,
                   2016,
                   2016,
                   2016,
                   2016,
                   nvl(vr_fat_mensal, 0),
                   nvl(vr_fat_mensal, 0),
                   nvl(vr_fat_mensal, 0),
                   nvl(vr_fat_mensal, 0),
                   nvl(vr_fat_mensal, 0),
                   nvl(vr_fat_mensal, 0),
                   nvl(vr_fat_mensal, 0),
                   nvl(vr_fat_mensal, 0),
                   nvl(vr_fat_mensal, 0),
                   nvl(vr_fat_mensal, 0),
                   nvl(vr_fat_mensal, 0),
                   nvl(vr_fat_mensal, 0),
                   trunc(SYSDATE),
                   trunc(SYSDATE),
                   trunc(SYSDATE),
                   trunc(SYSDATE),
                   '1',
                   '1',
                   '1',
                   '1');
              EXCEPTION 
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar incluir Faturamento mensal - ' || SQLERRM;
                  RAISE;
              END;
            END IF; 
           
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Faturamento Mensal - Boa Vista'
                       ,pr_nmdcampo => 'vlrftbru'
                       ,pr_dsdadant => ' '
                       ,pr_dsdadatu => nvl(vr_fat_mensal,0)
                       ,pr_dslogalt => '[BOA VISTA] Faturamento medio bruto mensal 1.ttl,');

          END IF; -- Fim do faturamento mensal

chw fim não atualizar rendimentos */
          ------------------------------------------------------------------------------------
          ---------------------------------- FIM RENDIMENTOS ---------------------------------
          ------------------------------------------------------------------------------------
          
          
          ------------------------------------------------------------------------------------
          ---------------------------------- EMAIL ---------------------------------
          ------------------------------------------------------------------------------------
          IF TRIM(vr_email) IS NOT NULL THEN
            IF cr_crapcem%ISOPEN THEN
              CLOSE cr_crapcem;
            END IF;    
            
            OPEN cr_crapcem (pr_cdcooper => rw_ass.cdcooper
                            ,pr_nrdconta => rw_ass.nrdconta
                            ,pr_dsdemail => vr_email);
            FETCH cr_crapcem INTO rw_crapcem;
            
            IF cr_crapcem%FOUND THEN
              CLOSE cr_crapcem;
              
              vr_email_ant := rw_crapcem.dsdemail;
              
              IF TRIM(vr_email) <> TRIM(vr_email_ant) THEN
              
                pc_escreve_xml('UPDATE crapcem cem '||
                                  'SET cem.dsdemail = '|| rw_crapcem.dsdemail ||                               
                               ' WHERE cem.progress_recid = '||rw_crapcem.Progress_recid||';'||chr(10));                 

                BEGIN
                  UPDATE crapcem cem
                     SET cem.dsdemail = vr_email
                   WHERE cem.progress_recid = rw_crapcem.progress_recid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_sqlerrm := 'Erro ao tentar atualizar E-mail - ' || SQLERRM;
                    RAISE;
                END;
                
                -- Logar alterações        
                pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                           ,pr_nrdconta => rw_ass.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_dstransa => 'Atualizar e-mail - Boa Vista'
                           ,pr_nmdcampo => 'dsdemail'
                           ,pr_dsdadant => TRIM(vr_email_ant)
                           ,pr_dsdadatu => TRIM(vr_email)
                           ,pr_dslogalt => '[BOA VISTA] email 1.ttl,');
              END IF;  
            
            ELSE      
              CLOSE cr_crapcem;
              BEGIN
                INSERT INTO crapcem
                  (cdoperad,
                   nrdconta,
                   dsdemail,
                   cddemail,
                   dtmvtolt,
                   hrtransa,
                   cdcooper,
                   idseqttl,
                   prgqfalt,
                   nmpescto,
                   secpscto)
                VALUES
                  (1,
                   rw_ass.nrdconta,
                   vr_email, 
                   (SELECT MAX(nvl(cddemail,0)) + 1
                      FROM crapcem
                     WHERE cdcooper = rw_ass.cdcooper
                       AND nrdconta = rw_ass.nrdconta),
                   trunc(SYSDATE),
                   gene0002.fn_busca_time,
                   rw_ass.cdcooper,
                   1,
                   'A',
                   '',
                   '') RETURNING progress_recid INTO vr_crapcem_progress_recid; 
                 
                -- Logar alterações        
                pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                           ,pr_nrdconta => rw_ass.nrdconta
                           ,pr_idseqttl => 1
                           ,pr_dstransa => 'Cadastrar e-mail - Boa Vista'
                           ,pr_nmdcampo => 'dsdemail'
                           ,pr_dsdadant => ''
                           ,pr_dsdadatu => TRIM(vr_email)
                           ,pr_dslogalt => '[BOA VISTA] email 1.ttl,');
                
              EXCEPTION
                WHEN OTHERS THEN
                  vr_sqlerrm := 'Erro ao tentar inserir email - ' || SQLERRM;
              END;
                          
              pc_escreve_xml('DELETE crapcem c '||             
                              'WHERE c.progress_recid = '||vr_crapcem_progress_recid||';'||chr(10));
            END IF;
          END IF;
          ------------------------------------------------------------------------------------
          ---------------------------------- FIM EMAIL ---------------------------------
          ------------------------------------------------------------------------------------
          
          IF vr_craptfc4_insere THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_ddd_celular1,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD 1.ttl,');
                       
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_celular1,'')
                       ,pr_dslogalt => '[BOA VISTA] telefone 1.ttl,');
          END IF; 
          
          IF vr_craptfc5_insere THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_ddd_celular2,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD 1.ttl,');
                       
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_celular2,'')
                       ,pr_dslogalt => '[BOA VISTA] telefone 1.ttl,');
          END IF; 
          
          IF vr_craptfc6_insere THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_ddd_celular3,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD 1.ttl,');
                       
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_celular3,'')
                       ,pr_dslogalt => '[BOA VISTA] telefone 1.ttl,');
          END IF;  
          
          IF vr_craptfc3_insere THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => nvl(vr_ddd3_ant,'')
                       ,pr_dsdadatu => nvl(vr_ddd3,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD 1.ttl,');
          
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => nvl(vr_telefone3_ant,'')
                       ,pr_dsdadatu => nvl(vr_telefone3,'')
                       ,pr_dslogalt => '[BOA VISTA] telefone 1.ttl,');        
          END IF;
          
          IF vr_craptfc2_insere THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => nvl(vr_ddd2_ant,'')
                       ,pr_dsdadatu => nvl(vr_ddd2,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD 1.ttl,');
         
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => nvl(vr_telefone2_ant,'')
                       ,pr_dsdadatu => nvl(vr_telefone2,'')
                       ,pr_dslogalt => '[BOA VISTA] telefone 1.ttl,');
          END IF;
          
          IF vr_craptfc1_insere THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => nvl(vr_ddd1_ant,'')
                       ,pr_dsdadatu => nvl(vr_ddd1,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD 1.ttl,');
          
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => nvl(vr_telefone1_ant,'')
                       ,pr_dsdadatu => nvl(vr_telefone1,'')
                       ,pr_dslogalt => '[BOA VISTA] telefone 1.ttl,');
          END IF;
          
          -- Novo
          IF vr_craptfc10_insere THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_ddd_celular_contato1,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD 1.ttl,');
                       
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_celular_contato1,'')
                       ,pr_dslogalt => '[BOA VISTA] telefone 1.ttl,');
          END IF; 
          
          IF vr_craptfc11_insere THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_ddd_celular_contato2,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD 1.ttl,');
                       
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_celular_contato2,'')
                       ,pr_dslogalt => '[BOA VISTA] telefone 1.ttl,');
          END IF; 
          
          IF vr_craptfc12_insere THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_ddd_celular_contato3,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD 1.ttl,');
                       
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_celular_contato3,'')
                       ,pr_dslogalt => '[BOA VISTA] telefone 1.ttl,');
          END IF;  
          
          IF vr_craptfc9_insere THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_ddd_contato3,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD 1.ttl,');
          
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_telefone_contato3,'')
                       ,pr_dslogalt => '[BOA VISTA] telefone 1.ttl,');        
          END IF;
          
          IF vr_craptfc8_insere THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_ddd_contato2,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD 1.ttl,');
         
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_telefone_contato2,'')
                       ,pr_dslogalt => '[BOA VISTA] telefone 1.ttl,');
          END IF;
          
          IF vr_craptfc7_insere THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrdddtfc'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_ddd_contato1,'')
                       ,pr_dslogalt => '[BOA VISTA] DDD 1.ttl,');
          
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Telefone - Boa Vista'
                       ,pr_nmdcampo => 'nrtelefo'
                       ,pr_dsdadant => '0'
                       ,pr_dsdadatu => nvl(vr_telefone_contato1,'')
                       ,pr_dslogalt => '[BOA VISTA] telefone 1.ttl,');
          END IF;
          -- Fim Novo
     
          -----------------------------------------------------------
          -- Log de atualização do endereço -------------------------
          -----------------------------------------------------------
/* chw nao atualizar endereço     
          IF vr_cep_ant <> vr_cep THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'nrcepend'
                       ,pr_dsdadant => nvl(vr_cep_ant,'')
                       ,pr_dsdadatu => nvl(vr_cep,'')
                       ,pr_dslogalt => '[BOA VISTA] cep compl. 1.ttl,');
          END IF;             
            
          IF vr_rua_ant <> vr_rua THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'dsendere'
                       ,pr_dsdadant => nvl(vr_rua_ant,'')
                       ,pr_dsdadatu => nvl(vr_rua,'')
                       ,pr_dslogalt => '[BOA VISTA] endereco compl. 1.ttl,');
          END IF;
          
          IF vr_numero_ant <> vr_numero THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'nrendere'
                       ,pr_dsdadant => nvl(vr_numero_ant,0)
                       ,pr_dsdadatu => nvl(vr_numero,0)
                       ,pr_dslogalt => '[BOA VISTA] nro.end.compl. 1.ttl,');
          END IF;
          
          IF vr_complemento_ant <> vr_complemento THEN             
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'complend'
                       ,pr_dsdadant => nvl(vr_complemento_ant,'')
                       ,pr_dsdadatu => nvl(vr_complemento,'')
                       ,pr_dslogalt => '[BOA VISTA] compl.end.compl. 1.ttl,');
          END IF;
          
          IF vr_bairro_ant <> vr_bairro THEN   
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'nmbairro'
                       ,pr_dsdadant => nvl(vr_bairro_ant,'')
                       ,pr_dsdadatu => nvl(vr_bairro,'')
                       ,pr_dslogalt => '[BOA VISTA] bairro compl. 1.ttl,');
          END IF;
          
          IF vr_cidade_ant <> vr_cidade THEN
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'nmcidade'
                       ,pr_dsdadant => nvl(vr_cidade_ant,'')
                       ,pr_dsdadatu => nvl(vr_cidade,'')
                       ,pr_dslogalt => '[BOA VISTA] cidade compl. 1.ttl,');
          END IF;
          
          IF vr_estado_ant <> vr_estado THEN     
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'cdufende'
                       ,pr_dsdadant => nvl(vr_estado_ant,'')
                       ,pr_dsdadatu => nvl(vr_estado,'')
                       ,pr_dslogalt => '[BOA VISTA] UF compl. 1.ttl,');
          END IF;
                 
          IF vr_idorigem <> 3 THEN  
            pc_gera_log(pr_cdcooper => rw_ass.cdcooper
                       ,pr_nrdconta => rw_ass.nrdconta
                       ,pr_idseqttl => 1
                       ,pr_dstransa => 'Atualizar Endereco - Boa Vista'
                       ,pr_nmdcampo => 'idorigem'
                       ,pr_dsdadant => nvl(vr_idorigem,0)
                       ,pr_dsdadatu => 3);
          END IF;
chw fim nao atualizar endereco */

        END LOOP; -- Loop ASS
      END LOOP; -- Loop Arquivo
      
    EXCEPTION 
      WHEN no_data_found THEN
        -- Fechar o arquivo
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
        -- Fim do arquivo
        dbms_output.put_line('FIM do arquivo');
        
        pc_escreve_xml('COMMIT;');
        pc_escreve_xml(' ',TRUE);
        DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_nmdireto, to_char(sysdate,'ddmmyyyy_hh24miss')||'_'||vr_nmarqbkp||'_PJ.txt', NLS_CHARSET_ID('UTF8'));
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
    END;
  END LOOP;

  COMMIT;
EXCEPTION   
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    
    IF vr_sqlerrm IS NOT NULL THEN
      dbms_output.put_line('Erro: ' || ' Linha: ' ||to_char(vr_contlinha)||' Arquivo: '||vr_nmarquiv||' - '|| vr_sqlerrm);
    ELSE
      dbms_output.put_line('Erro: ' || vr_dscritic|| ' Linha: ' ||to_char(vr_contlinha)||' Arquivo: '||vr_nmarquiv||' - '||sqlerrm);
    END IF;
    ROLLBACK;
END;
0
1
vr_email
