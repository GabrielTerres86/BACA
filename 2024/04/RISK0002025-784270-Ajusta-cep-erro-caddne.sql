DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'RISK0002025_na.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'RISK0002025_corrige_crapdne_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'RISK0002025_corrige_crapdne_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  vr_base_log           VARCHAR2(3000);
  
  vr_uf_corrigir        CECRED.CRAPDNE.CDUFLOGR%TYPE;
  vr_cep_corrigir       CECRED.CRAPDNE.NRCEPLOG%TYPE;
  
  vr_comments           VARCHAR2(2000);
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  CURSOR cr_dados IS 
    WITH FAIXA_CEP_ESTADO AS (
      SELECT 01000000 INICIO, 19999999 FIM, 'SP' SIGLA, 01031000 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 20000000 INICIO, 28999999 FIM, 'RJ' SIGLA, 20230010 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 29000000 INICIO, 29999999 FIM, 'ES' SIGLA, 29010410 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 30000000 INICIO, 39999999 FIM, 'MG' SIGLA, 30180000 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 40000000 INICIO, 48999999 FIM, 'BA' SIGLA, 40020210 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 49000000 INICIO, 49999999 FIM, 'SE' SIGLA, 49010020 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 50000000 INICIO, 56999999 FIM, 'PE' SIGLA, 50090700 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 57000000 INICIO, 57999999 FIM, 'AL' SIGLA, 57020070 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 58000000 INICIO, 58999999 FIM, 'PB' SIGLA, 58013010 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 59000000 INICIO, 59999999 FIM, 'RN' SIGLA, 59114200 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 60000000 INICIO, 63999999 FIM, 'CE' SIGLA, 60035000 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 64000000 INICIO, 64999999 FIM, 'PI' SIGLA, 64000160 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 65000000 INICIO, 65999999 FIM, 'MA' SIGLA, 65010904 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 66000000 INICIO, 68899999 FIM, 'PA' SIGLA, 66823215 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 68900000 INICIO, 68999999 FIM, 'AP' SIGLA, 68900013 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 69000000 INICIO, 69299999 FIM, 'AM' SIGLA, 69020030 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 69300000 INICIO, 69399999 FIM, 'RR' SIGLA, 69301380 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 69400000 INICIO, 69899999 FIM, 'AM' SIGLA, 69020030 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 69900000 INICIO, 69999999 FIM, 'AC' SIGLA, 69908500 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 70000000 INICIO, 72799999 FIM, 'DF' SIGLA, 71690845 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 72800000 INICIO, 72999999 FIM, 'GO' SIGLA, 72856728 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 73000000 INICIO, 73699999 FIM, 'DF' SIGLA, 71690845 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 73700000 INICIO, 76799999 FIM, 'GO' SIGLA, 74055050 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 76800000 INICIO, 76999999 FIM, 'RO' SIGLA, 76801084 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 77000000 INICIO, 77999999 FIM, 'TO' SIGLA, 77064540 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 78000000 INICIO, 78899999 FIM, 'MT' SIGLA, 78104970 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 79000000 INICIO, 79999999 FIM, 'MS' SIGLA, 79002363 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 80000000 INICIO, 87999999 FIM, 'PR' SIGLA, 80020330 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 88000000 INICIO, 89999999 FIM, 'SC' SIGLA, 89010008 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 90000000 INICIO, 99999999 FIM, 'RS' SIGLA, 90010284 CEP_VALIDO_CAPITAL FROM DUAL 
    ), CRAPDNE_INVALIDOS AS (
      SELECT D.*
      FROM CRAPDNE D
      LEFT JOIN FAIXA_CEP_ESTADO CE ON NVL(D.CDUFLOGR, 'X') = CE.SIGLA
                                       AND D.NRCEPLOG BETWEEN CE.INICIO AND CE.FIM
      WHERE CE.INICIO IS NULL 
        AND D.Idoricad = 2 -- Cadastros manuais
    ) , CRAPMUN_UNICS AS (
      SELECT MB.DSCIDADE
        , MIN(ROWID)     ROWID_CRAPMUN
        ,COUNT(*) QTD
      FROM CRAPMUN MB
      GROUP BY MB.DSCIDADE
      HAVING COUNT(*) = 1
    ), CRAPMUN_CID_UF AS (
      SELECT MT.DSCIDADE
        , MT.CDESTADO
      FROM CRAPMUN_UNICS MU
      JOIN CRAPMUN       MT ON MU.ROWID_CRAPMUN = MT.ROWID
    ),cidades_duplicadas as (
      SELECT MB.DSCIDADE
        , COUNT(*) QTD
      FROM CRAPMUN MB
      GROUP BY MB.DSCIDADE
      HAVING COUNT(*) > 1
    ), CIDADES_DUPLICADAS_VS_ESTADO AS (
      SELECT MD.DSCIDADE
        , MD.CDESTADO
      FROM CRAPMUN MD 
      JOIN CIDADES_DUPLICADAs DP ON MD.DSCIDADE = DP.DSCIDADE
      ORDER BY MD.DSCIDADE
    ), CEP_ESTADO AS (
      SELECT d.progress_recid               progress_recid_corrigir
        , D.NRCEPLOG
        , D.CDUFLOGR
        , D.NMEXTCID
        , D.NMRESCID
        , SUBSTR(D.NRCEPLOG, 1, 2)          NRCEPLOG_2_DIGITOS
        
        , 'ERRO UF x FAIXA CEP ==> '        DIV_ERRO
        , FE.SIGLA                     UF_01
        , FE.INICIO                    INICIO_01
        , FE.FIM                       FIM_01
        , FE.CEP_VALIDO_CAPITAL
        , '(' || D.CDUFLOGR || ' - '
          || MUN.CDESTADO || ')'       UF_DNE_X_MUN_01
        
        , 'CORRETO POR FAIXA CEP ==> ' DIV_CORRETO
        , FEOK.SIGLA
        , FEOK.INICIO
        , FEOK.FIM
        , '(' || D.CDUFLOGR || ' - '
          || MUN.CDESTADO || ')'       UF_DNE_X_MUN
          
        
        , 'CRAPMUN POR CIDADE ==> '
        , MUN.CDESTADO                 UF_APLICAR_CORRECAO_01
        , MUN.DSCIDADE                 DSCIDADE_01
        
        , 'MUN2 - CIDADE EM MAIS DE 1 UF ==> '
        , MUN2.CDESTADO                 UF_APLICAR_CORRECAO_02
        , MUN2.DSCIDADE                 DSCIDADE_02
        
      FROM CRAPDNE_INVALIDOS D
                                         
      LEFT JOIN CRAPMUN_CID_UF   MUN  ON TRIM( UPPER(D.NMEXTCID) ) = TRIM( UPPER(MUN.DSCIDADE) )
                                         OR TRIM( UPPER(D.NMRESCID) ) = TRIM( UPPER(MUN.DSCIDADE) )
      
      LEFT JOIN CIDADES_DUPLICADAS_VS_ESTADO   MUN2  ON D.CDUFLOGR = MUN2.CDESTADO
                                                     AND ( TRIM( UPPER(D.NMEXTCID) ) = TRIM( UPPER(MUN2.DSCIDADE) )
                                                       OR TRIM( UPPER(D.NMRESCID) ) = TRIM( UPPER(MUN2.DSCIDADE) )
                                                     )
      
      LEFT JOIN FAIXA_CEP_ESTADO FE   ON D.CDUFLOGR = FE.SIGLA
                                         AND D.NRCEPLOG NOT BETWEEN FE.INICIO AND FE.FIM
      
      LEFT JOIN FAIXA_CEP_ESTADO FEOK ON ( NVL(D.CDUFLOGR, 'X') = FEOK.SIGLA OR NVL(MUN.CDESTADO, 'Z') = FEOK.SIGLA OR NVL(MUN2.CDESTADO, 'Z') = FEOK.SIGLA ) -- D.CDUFLOGR = FEOK.SIGLA
                                         AND D.NRCEPLOG BETWEEN FEOK.INICIO AND FEOK.FIM
      
      WHERE D.IDORICAD = 2
    )
    SELECT CE.*
      , 'DNE LIKE CEP => '
      , DNE.NRCEPLOG          NRCEPLOG_CRR_01
      , DNE.CDUFLOGR          CDUFLOGR_CRR_01
      , DNE.NMRESCID          NMRESCID_CRR_01
      , 'DNE CIDADE x UF => '
      , DNE_02.NRCEPLOG       NRCEPLOG_CRR_02
      , DNE_02.CDUFLOGR       CDUFLOGR_CRR_02
      , DNE_02.NMRESCID       NMRESCID_CRR_02
      
    FROM CEP_ESTADO    CE
    
    CROSS APPLY (
      SELECT MAX(D.NRCEPLOG) KEEP (DENSE_RANK FIRST ORDER BY D.IDORICAD ASC, D.IDTIPDNE ASC, D.NRCEPLOG DESC) NRCEPLOG
        , MAX(D.progress_recid) KEEP (DENSE_RANK FIRST ORDER BY D.IDORICAD ASC, D.IDTIPDNE ASC, D.NRCEPLOG DESC) PROGRES_RECID_DNE_APLICAR
        , 'Correção 01 - Busca CEP correto com like pelo CEP que está com erro X nm cidade X UF.' det
      FROM CRAPDNE D
      WHERE 
        (
             ( NRCEPLOG >  19999999 AND CDUFLOGR <> 'SP')
          OR ( NRCEPLOG <= 19999999 AND CDUFLOGR = 'SP')
        )
        AND NRCEPLOG LIKE '%' || CE.NRCEPLOG || '%'
        AND NRCEPLOG <> CE.NRCEPLOG
        AND  ( 
          NMRESCID = CE.NMRESCID
          OR NMEXTCID = CE.NMRESCID
          OR NMRESCID = CE.NMEXTCID
          OR NMEXTCID = CE.NMEXTCID
        )
        AND IDTIPDNE = 1
        AND NVL( NVL(CE.UF_APLICAR_CORRECAO_01, CE.UF_APLICAR_CORRECAO_02), NVL(CE.CDUFLOGR, 'X') ) = NVL(CDUFLOGR, 'Y')
    ) DNE_CORR
    LEFT JOIN CRAPDNE DNE ON DNE_CORR.PROGRES_RECID_DNE_APLICAR = DNE.PROGRESS_RECID
    
    CROSS APPLY (
      SELECT MAX(D.NRCEPLOG) KEEP (DENSE_RANK FIRST ORDER BY D.IDORICAD ASC, D.IDTIPDNE ASC, D.NRCEPLOG DESC) NRCEPLOG
        , MAX(D.progress_recid) KEEP (DENSE_RANK FIRST ORDER BY D.IDORICAD ASC, D.IDTIPDNE ASC, D.NRCEPLOG DESC) PROGRES_RECID_DNE_APLICAR
        , 'Busca um CEP válido com base na CIDADE x ( UF ou pelos dígitos iniciais do CEP ), quando não encontrar com o LIKE no CEP' det
      FROM CRAPDNE D
      WHERE 
        (
             ( D.NRCEPLOG >  19999999 AND CDUFLOGR <> 'SP')
          OR ( D.NRCEPLOG <= 19999999 AND CDUFLOGR  = 'SP')
        )
        AND D.NRCEPLOG <> CE.NRCEPLOG 
        AND ( 
          D.NMRESCID = CE.NMRESCID
          OR D.NMEXTCID = CE.NMRESCID
          OR D.NMRESCID = CE.NMEXTCID
          OR D.NMEXTCID = CE.NMEXTCID
        )
        AND (
          NVL( NVL(CE.UF_APLICAR_CORRECAO_01, CE.UF_APLICAR_CORRECAO_02), NVL(CE.CDUFLOGR, 'X') ) = NVL(D.CDUFLOGR, 'Y') 
          OR CE.NRCEPLOG_2_DIGITOS = SUBSTR(D.NRCEPLOG, 1, 2)
        )
        AND DNE.NRCEPLOG IS NULL
    ) DNE_CORR_02
    LEFT JOIN CRAPDNE DNE_02 ON DNE_CORR_02.PROGRES_RECID_DNE_APLICAR = DNE_02.PROGRESS_RECID

    WHERE UF_01 IS NOT NULL;
  
  TYPE TP_DADOS IS TABLE OF cr_dados%ROWTYPE INDEX BY PLS_INTEGER;
  vt_dados      TP_DADOS;
  
  CURSOR cr_valida_correcao ( pr_cep_corrigir IN NUMBER
                            , pr_uf_corrigir  IN VARCHAR2 ) IS
    WITH FAIXA_CEP_ESTADO AS (
      SELECT 01000000 INICIO, 19999999 FIM, 'SP' SIGLA, 01031000 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 20000000 INICIO, 28999999 FIM, 'RJ' SIGLA, 20230010 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 29000000 INICIO, 29999999 FIM, 'ES' SIGLA, 29010410 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 30000000 INICIO, 39999999 FIM, 'MG' SIGLA, 30180000 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 40000000 INICIO, 48999999 FIM, 'BA' SIGLA, 40020210 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 49000000 INICIO, 49999999 FIM, 'SE' SIGLA, 49010020 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 50000000 INICIO, 56999999 FIM, 'PE' SIGLA, 50090700 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 57000000 INICIO, 57999999 FIM, 'AL' SIGLA, 57020070 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 58000000 INICIO, 58999999 FIM, 'PB' SIGLA, 58013010 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 59000000 INICIO, 59999999 FIM, 'RN' SIGLA, 59114200 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 60000000 INICIO, 63999999 FIM, 'CE' SIGLA, 60035000 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 64000000 INICIO, 64999999 FIM, 'PI' SIGLA, 64000160 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 65000000 INICIO, 65999999 FIM, 'MA' SIGLA, 65010904 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 66000000 INICIO, 68899999 FIM, 'PA' SIGLA, 66823215 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 68900000 INICIO, 68999999 FIM, 'AP' SIGLA, 68900013 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 69000000 INICIO, 69299999 FIM, 'AM' SIGLA, 69020030 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 69300000 INICIO, 69399999 FIM, 'RR' SIGLA, 69301380 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 69400000 INICIO, 69899999 FIM, 'AM' SIGLA, 69020030 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 69900000 INICIO, 69999999 FIM, 'AC' SIGLA, 69908500 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 70000000 INICIO, 72799999 FIM, 'DF' SIGLA, 71690845 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 72800000 INICIO, 72999999 FIM, 'GO' SIGLA, 72856728 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 73000000 INICIO, 73699999 FIM, 'DF' SIGLA, 71690845 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 73700000 INICIO, 76799999 FIM, 'GO' SIGLA, 74055050 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 76800000 INICIO, 76999999 FIM, 'RO' SIGLA, 76801084 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 77000000 INICIO, 77999999 FIM, 'TO' SIGLA, 77064540 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 78000000 INICIO, 78899999 FIM, 'MT' SIGLA, 78104970 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 79000000 INICIO, 79999999 FIM, 'MS' SIGLA, 79002363 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 80000000 INICIO, 87999999 FIM, 'PR' SIGLA, 80020330 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 88000000 INICIO, 89999999 FIM, 'SC' SIGLA, 89010008 CEP_VALIDO_CAPITAL FROM DUAL UNION ALL 
      SELECT 90000000 INICIO, 99999999 FIM, 'RS' SIGLA, 90010284 CEP_VALIDO_CAPITAL FROM DUAL 
    )
    SELECT 1 
    FROM FAIXA_CEP_ESTADO V
    WHERE pr_cep_corrigir BETWEEN V.INICIO AND V.FIM
      AND pr_uf_corrigir = V.SIGLA;
      
  rg_valida_correcao cr_valida_correcao%ROWTYPE;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RISK0002025';
  
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
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'PROGRESS ID CORRIGIR;CEP CAD;UF CAD;CIDADE CAD - EXT e RES;UF CORRETA 01;UF CORRETA 02;CEP CORRETO 01; CEP CORRETO 02;STATUS;DETALHES;');
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Início: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  vr_count := 0;
  
  OPEN cr_dados;
  FETCH cr_dados BULK COLLECT INTO vt_dados;
  CLOSE cr_dados;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do BULK inicio do Loop: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  
  IF vt_dados.COUNT() > 0 THEN
    
    FOR i IN vt_dados.FIRST..vt_dados.LAST LOOP
      
      vr_base_log := vt_dados(i).PROGRESS_RECID_CORRIGIR                  || ';' ||
                     vt_dados(i).NRCEPLOG                                 || ';' ||
                     vt_dados(i).CDUFLOGR                                 || ';' ||
                     vt_dados(i).NMEXTCID || ' (' || vt_dados(i).NMRESCID || ');' ||
                     vt_dados(i).UF_APLICAR_CORRECAO_01                   || ';' ||
                     vt_dados(i).UF_APLICAR_CORRECAO_02                   || ';' ||
                     vt_dados(i).NRCEPLOG_CRR_01 || 
                       ' (' || vt_dados(i).CDUFLOGR_CRR_01 || ' - ' || 
                       vt_dados(i).NMRESCID_CRR_01                        || ');' ||
                     vt_dados(i).NRCEPLOG_CRR_02 || 
                       ' (' || vt_dados(i).CDUFLOGR_CRR_02 || ' - ' || 
                       vt_dados(i).NMRESCID_CRR_02                        || ');';
      
      vr_uf_corrigir  := TRIM(vt_dados(i).CDUFLOGR);
      
      vr_comments := 'Validações para correção da UF.';
      IF NVL( TRIM(vt_dados(i).UF_APLICAR_CORRECAO_01), vr_uf_corrigir ) <> vr_uf_corrigir THEN
        
        vr_comments := ' ## 01 - Caso encontre uma UF na crapmun baseado no nome da cidade, utiliza esta para correção. Aqui são as cidades que não tem nome repetido em UFs diferentes.';
        vr_uf_corrigir := vt_dados(i).UF_APLICAR_CORRECAO_01;
        
      ELSIF NVL( TRIM(vt_dados(i).UF_APLICAR_CORRECAO_02), vr_uf_corrigir) <> vr_uf_corrigir THEN
        
        vr_comments := ' ## 02 - Se não encontrar uma UF na primeira condição, tenta aplicar esta segunda UF. Aqui são cidades que tem o seu nome em mais de uma UF.';
        vr_uf_corrigir := vt_dados(i).UF_APLICAR_CORRECAO_02;
        
      ELSIF NVL( TRIM(vt_dados(i).CDUFLOGR_CRR_02), vr_uf_corrigir) <> vr_uf_corrigir THEN
        
        vr_comments := ' ## 03 - Se não encontrar uma UF das duas primeiras condições, pega da condição onde traz CEP pela cidade x (UF ou Dois dígitos do cep), onde será retornado um CEP para correção do registro';
        vr_uf_corrigir := vt_dados(i).CDUFLOGR_CRR_02;
        
      END IF;
      
      vr_comments := 'Validações para correção do CEP.';
      vr_comments := 'Solução 01: Busca sugestão de correção baseado em um Like com o CEP atual x Cidade x UF.';
      vr_cep_corrigir := vt_dados(i).NRCEPLOG_CRR_01;
      
      vr_comments := 'Solução 02: Busca sugestão de correção baseado no nome da Cidade x (UF ou dois primeiros dígitos do CEP).';
      IF vr_cep_corrigir IS NULL THEN
        vr_cep_corrigir := vt_dados(i).NRCEPLOG_CRR_02;
      END IF;
      
      IF vr_cep_corrigir IS NULL THEN
        
        vr_comments := 'Se não encontrar nenhum CEP de sugestão de correção, registra em log e parte para o próximo registro.';
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'ALERTA;Não foi encontrado um CEP para correção do registro.');
        CONTINUE;
        
      END IF;
      
      vr_comments := 'Validando se conseguimos encontrar uma sugestão de correção que seja coerente e mantenha a integridade entre UF e Faixa do CEP.';
      OPEN cr_valida_correcao(vr_cep_corrigir, vr_uf_corrigir);
      FETCH cr_valida_correcao INTO rg_valida_correcao;
      
      IF cr_valida_correcao%NOTFOUND THEN
        
        vr_comments := 'A sugestão de correcao nao deu certo, o cadastro precisara ser corrigido individualmente.';
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'ALERTA - Correcao Indiv.;' || vr_comments);
        CLOSE cr_valida_correcao;
        
        CONTINUE;
        
      END IF;
      
      CLOSE cr_valida_correcao;
      
      BEGIN
        
        UPDATE CECRED.CRAPDNE D
          SET D.NRCEPLOG = vr_cep_corrigir
            , D.CDUFLOGR = vr_uf_corrigir
        WHERE D.PROGRESS_RECID = vt_dados(i).PROGRESS_RECID_CORRIGIR;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  UPDATE CECRED.CRAPDNE ' 
                                                      || ' SET NRCEPLOG = ' || vt_dados(i).NRCEPLOG
                                                      || ' , CDUFLOGR = '''   || vt_dados(i).CDUFLOGR || ''' ' ||
                                                      '  WHERE PROGRESS_RECID = ' || vt_dados(i).PROGRESS_RECID_CORRIGIR || '; ');
        
        vr_count := vr_count + 1;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'SUCESSO;Registro corrigido com sucesso.');
        
      EXCEPTION
        WHEN OTHERS THEN
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'ERRO;Erro nao tratado ao corrigir CEP na caddne.: ' || SQLERRM);
          
      END;
      
      IF vr_count >= 1000 THEN
        
        COMMIT;
        
        vr_count := 0;
        
      END IF;
      
    END LOOP;
    
  END IF;
  vr_comments := 'Final do IF vt_dados.COUNT() > 0';
  
  vr_comments := 'Faz a busca novamente para identificar os casos que o script não resolveu e precisam ser ajustados individualmente.';
  vt_dados := NULL;
  OPEN cr_dados;
  FETCH cr_dados BULK COLLECT INTO vt_dados;
  CLOSE cr_dados;
  
  IF vt_dados.COUNT() > 0 THEN
    
    FOR i IN vt_dados.FIRST..vt_dados.LAST LOOP
      
      vr_base_log := vt_dados(i).PROGRESS_RECID_CORRIGIR                  || ';' ||
                     vt_dados(i).NRCEPLOG                                 || ';' ||
                     vt_dados(i).CDUFLOGR                                 || ';' ||
                     vt_dados(i).NMEXTCID || ' (' || vt_dados(i).NMRESCID || ');' ||
                     vt_dados(i).UF_APLICAR_CORRECAO_01                   || ';' ||
                     vt_dados(i).UF_APLICAR_CORRECAO_02                   || ';' ||
                     vt_dados(i).NRCEPLOG_CRR_01 || 
                       ' (' || vt_dados(i).CDUFLOGR_CRR_01 || ' - ' || 
                       vt_dados(i).NMRESCID_CRR_01                        || ');' ||
                     vt_dados(i).NRCEPLOG_CRR_02 || 
                       ' (' || vt_dados(i).CDUFLOGR_CRR_02 || ' - ' || 
                       vt_dados(i).NMRESCID_CRR_02                        || ');';
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'CORRECAO INDIVIDUAL;O Registro NAO foi corrigido pelo script, adicionar no CSV de correcao individual.');
      
    END LOOP;
    
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS'));
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exception THEN
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20003, 'Erro: ' || vr_dscritic);
    
  WHEN OTHERS THEN
    
    cecred.pc_internal_exception;
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20004, 'ERRO NÃO TRATADO: ' || SQLERRM);
    
END;
