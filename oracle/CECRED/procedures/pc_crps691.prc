CREATE OR REPLACE PROCEDURE 
  CECRED.pc_crps691 (pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padr„o para utilizaÁ„o de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> SaÌda de termino da execuÁ„o
                    ,pr_infimsol OUT PLS_INTEGER            --> SaÌda de termino da solicitaÁ„o
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps691 (Fontes/crps691.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison
       Data    : Dezembro/2014                     Ultima atualizacao: 04/08/2016

       Dados referentes ao programa:

       Frequencia: Gerar no primeiro dia ˙til de cada mÍs.
       Objetivo  : Gerar Documento 5300 - InformaÁıes de Cooperados.

       Alteracoes: 20/07/2015 - Ajustes para quando o CPF/CNPJ possuir  relacionamento 
                                atual nao enviar os relacionamentos encerrados. (Jaison)
                                
                   27/01/2016 - Incluso tratamento para remover acentuaÁ„o no nome da
                                cidade (Daniel / Chamado 394040)            

                   22/02/2016 - Ajuste para nao carregar os CPF/CNPJ com problema
                                na Receita Federal. (Jaison/James)

                   04/04/2016 - Criacao do relatorio para conferencia pela area contabil. (James)

                   04/08/2016 - Alteracao para pegar as cidades da tabela crapmun.
                                (Jaison/Anderson)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- CÛdigo do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS691';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      
      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.nrdocnpj
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor genÈrico de calend·rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Cadastro de associados com seus saldos diarios e enderecos
      CURSOR cr_coop_dados(pr_cdcooper IN crapass.cdcooper%TYPE
                          ,pr_dtrefere IN crapsda.dtmvtolt%TYPE) IS
        SELECT crapass.cdcooper
              ,crapass.nrdconta
              ,crapass.inpessoa
              ,crapass.nrcpfcgc
              ,crapass.nmprimtl
              ,crapass.dtadmiss
              ,CASE 
                 WHEN crapass.dtdemiss > pr_dtrefere THEN NULL
                 ELSE crapass.dtdemiss
               END AS dtdemiss
              ,crapsda.vlsdcota
              ,crapsda.vlprepla
              ,crapsda.vlsdempr
              ,crapsda.vlsdfina
              ,crapsda.vllimcre
              ,crapsda.vllimtit
              ,crapsda.vllimdsc
              ,crapsda.vlsdrdca
              ,crapsda.vlsdrdpp
              ,crapsda.vlsrdc30
              ,crapsda.vlsrdc60
       	      ,crapenc.cdufende
              ,crapenc.nmcidade
              ,ROW_NUMBER() OVER (PARTITION BY crapass.nrcpfcgc ORDER BY crapass.nrcpfcgc, crapass.dtadmiss, crapass.dtdemiss ) AS nrseq
              ,COUNT(1)     OVER (PARTITION BY crapass.nrcpfcgc ) AS qtreg           
          FROM crapass, crapsda, crapenc
         WHERE crapass.cdcooper = crapsda.cdcooper
           AND crapass.nrdconta = crapsda.nrdconta
           AND crapass.cdcooper = crapenc.cdcooper
           AND crapass.nrdconta = crapenc.nrdconta
           AND crapass.cdcooper = pr_cdcooper
           AND ( ( crapass.dtadmiss <= pr_dtrefere ) OR ( crapass.dtadmiss IS NULL ) )
           AND crapsda.dtmvtolt = pr_dtrefere
           AND crapass.nrcpfcgc > 0
           AND (crapass.dtdemiss BETWEEN TRUNC(pr_dtrefere,'MM') AND pr_dtrefere
                OR crapass.dtdemiss IS NULL OR crapass.dtdemiss > pr_dtrefere )
           AND crapenc.idseqttl = 1
           AND ((crapass.inpessoa = 1 AND crapenc.tpendass = 10) OR
                (crapass.inpessoa > 1 AND crapenc.tpendass = 9))
      ORDER BY crapass.nrcpfcgc,crapass.dtadmiss,crapass.dtdemiss;

      -- Cadastro de representante legal do cooperado
      CURSOR cr_rep_legal(pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_dtrefere IN crapavt.dtvalida%TYPE) IS
        SELECT t.nrcpfcgc,
               t.dtinicio,
               t.dtvigenc,
               ROW_NUMBER() OVER (PARTITION BY t.nrcpfcgc ORDER BY t.nrcpfcgc,t.dtinicio,t.dtvigenc) AS nrseq,
               COUNT(1)      OVER (PARTITION BY t.nrcpfcgc) AS qtreg
        FROM (                 
          SELECT crapcrl.nrcpfcgc
               , NVL(crapcrl.dtmvtolt, crapass.dtadmiss) AS dtinicio
               , NULL AS dtvigenc
            FROM crapcrl, crapass
           WHERE crapcrl.cdcooper = crapass.cdcooper(+)
             AND crapcrl.nrctamen = crapass.nrdconta(+)
             AND crapcrl.cdcooper = pr_cdcooper
             AND crapcrl.nrcpfcgc > 0
             AND NOT EXISTS (SELECT 1
                               FROM crapass ass
                              WHERE ass.cdcooper = crapcrl.cdcooper
                                AND ass.nrcpfcgc = crapcrl.nrcpfcgc)

          UNION

          SELECT crapavt.nrcpfcgc
               , NVL(crapavt.dtmvtolt, crapass.dtadmiss) AS dtinicio
               , CASE 
                   WHEN crapavt.dtvalida > pr_dtrefere THEN NULL
                   ELSE crapavt.dtvalida -- Vigencia
                 END AS dtvigenc
            FROM crapavt, crapass
           WHERE crapavt.cdcooper = crapass.cdcooper(+)
             AND crapavt.nrdconta = crapass.nrdconta(+)
             AND crapavt.cdcooper = pr_cdcooper
             AND crapavt.nrcpfcgc > 0
             AND crapavt.tpctrato = 6 -- Procuradores
             AND NOT EXISTS (SELECT 1
                               FROM crapass ass
                              WHERE ass.cdcooper = crapavt.cdcooper
                                AND ass.nrcpfcgc = crapavt.nrcpfcgc)
             AND (crapavt.dtvalida BETWEEN TRUNC(pr_dtrefere,'MM') AND pr_dtrefere
                  OR crapavt.dtvalida IS NULL )

          ORDER BY nrcpfcgc, dtinicio, dtvigenc ) t;

      -- Listagem dos municipios
      CURSOR cr_crapmun IS
        SELECT crapmun.cdestado
              ,crapmun.cdcidbge
              ,crapmun.dscidesp
              ,crapmun.cdufibge
          FROM crapmun
         WHERE crapmun.cdcidbge IS NOT NULL
           AND crapmun.cdufibge IS NOT NULL;

      -- Selecionar informacoes de subscricao do capital dos associados
      CURSOR cr_crapsdc(pr_cdcooper IN crapsdc.cdcooper%TYPE
                       ,pr_nrdconta IN crapsdc.nrdconta%TYPE
                       ,pr_dtrefere IN crapsdc.dtrefere%TYPE) IS
        SELECT crapsdc.vllanmto
          FROM crapsdc
         WHERE crapsdc.cdcooper  = pr_cdcooper
           AND crapsdc.nrdconta  = pr_nrdconta
           AND crapsdc.dtrefere <= pr_dtrefere
           AND crapsdc.indebito  = 0
           AND crapsdc.dtdebito IS NULL
      ORDER BY crapsdc.progress_recid DESC;

      -- Selecionar a data de alteracao
      CURSOR cr_crapalt(pr_cdcooper IN crapsdc.cdcooper%TYPE
                       ,pr_nrdconta IN crapsdc.nrdconta%TYPE) IS
        SELECT crapalt.dtaltera
          FROM crapalt
         WHERE crapalt.cdcooper  = pr_cdcooper
           AND crapalt.nrdconta  = pr_nrdconta;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      -- Tabela temporaria para os municipios
      TYPE typ_tab_cid IS
        TABLE OF crapmun%ROWTYPE
          INDEX BY VARCHAR2(50);
      -- Vetor para armazenar os dados da central de risco
      vr_tab_cid typ_tab_cid;
      
      -- Registro para as informaÁıes das contas que irao ser enviadas como encerrada
      TYPE typ_tab_cpf_cnpj_encerrados IS
        TABLE OF PLS_INTEGER
          INDEX BY VARCHAR2(40);
      vr_tab_cpf_cnpj_encerrados typ_tab_cpf_cnpj_encerrados;

      ------------------------------- VARIAVEIS -------------------------------
      vr_dtrefere DATE;                       --> Ultimo dia util do mes anterior
      vr_nmarqxml VARCHAR2(50);               --> Nome do arquivo XML
      vr_nmdireto VARCHAR2(100);              --> Caminho do arquivo XML
      vr_nmdirmic VARCHAR2(100);              --> Caminho do arquivo XML na pasta Micros
      vr_dtadmiss crapass.dtadmiss%TYPE;      --> Data de admissao
      vr_dtiniadm crapass.dtadmiss%TYPE;      --> Data de admissao
      vr_inpessoa crapass.inpessoa%TYPE;      --> Tipo de pessoa
      vr_nrcpfcgc crapass.nrcpfcgc%TYPE := 0; --> CPF/CNPJ do associado
      vr_dscpfcgc VARCHAR2(14);               --> CPF/CNPJ do associado
      vr_dsrelatu VARCHAR2(32767) := NULL;    --> Relacionamento atual
      vr_dsrelenc VARCHAR2(32767) := NULL;    --> Relacionamentos encerrados
      vr_dsvlrprm VARCHAR2(1000);
      vr_flgdpraz VARCHAR2(1) := 'N';         --> Deposito a prazo
      vr_flgdavis VARCHAR2(1) := 'N';         --> Deposito sob aviso
      vr_flgopcre VARCHAR2(1) := 'N';         --> Operacoes de credito
      vr_flgoutro VARCHAR2(1) := 'N';         --> Outros
      vr_vlsdcota crapsda.vlsdcota%TYPE := 0; --> Saldo de cotas
      vr_vlsomado crapsdc.vllanmto%TYPE := 0; --> Subscricao do capital
      vr_vllanmto crapsdc.vllanmto%TYPE := 0; --> Subscricao do capital
      vr_cdmuibge crapmun.cdcidbge%TYPE;      --> Codigo do municipio
      vr_cdufibge crapmun.cdufibge%TYPE;      --> Codigo UF do municipio
      vr_flgativo BOOLEAN := FALSE;           --> Controla se possui relacionamento atual
      vr_dtdemiss DATE;
      
      vr_municipio VARCHAR(7) := NULL;

      -- Variaveis de XML do relatorio 5300
      vr_xml_5300          CLOB;
      vr_xml_5300_temp     VARCHAR2(32767);
      
      -- Variaveis de XML do relatorio crrl5300
      vr_xml_714      CLOB;
      vr_xml_714_temp VARCHAR2(32767);
      
      vr_dsmuibge VARCHAR2(50);
      
      vr_ufcidade VARCHAR2(50);

      --------------------------- SUBROTINAS INTERNAS --------------------------
      PROCEDURE pc_carrega_tab_encerrados(pr_string   IN VARCHAR2
                                         ,pr_delimit  IN CHAR DEFAULT ','
                                         ,pr_tab_cpf_cnpj_encerrados IN OUT typ_tab_cpf_cnpj_encerrados) IS
                                         
        vr_quebra   LONG DEFAULT pr_string || pr_delimit;
        vr_nrcpfcgc VARCHAR2(20);
        vr_idx      NUMBER;
      BEGIN
        LOOP
          -- Identifica ponto de quebra inicial
          vr_idx := instr(vr_quebra, pr_delimit);
          -- Clausula de saÌda para o loop
          exit WHEN nvl(vr_idx, 0) = 0;
          -- Monta o CPF/CNPJ
          vr_nrcpfcgc := to_number(trim(substr(vr_quebra, 1, vr_idx - 1)));
          -- Carrega na Temp-Table
          pr_tab_cpf_cnpj_encerrados(vr_nrcpfcgc) := 1;
          -- Atualiza a vari·vel com a string integral eliminando o bloco quebrado
          vr_quebra := substr(vr_quebra, vr_idx + LENGTH(pr_delimit));
        END LOOP;       
        
      END pc_carrega_tab_encerrados;

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do mÛdulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se n„o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver· raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calend·rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se n„o encontrar
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

      -- ValidaÁıes iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro È <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      IF (rw_crapdat.inproces = 1) -- Caso seja uma geracao manual e o processo esteja on-line
      OR (rw_crapdat.inproces <> 1 AND TO_CHAR(rw_crapdat.dtmvtolt,'MM') <> TO_CHAR(rw_crapdat.dtmvtoan,'MM')) -- Processo noturno rodando e tbm seja o primeiro dia util do mes
      THEN

        -- Carrega a listagem dos municipios
        FOR rw_crapmun IN cr_crapmun LOOP
          
          vr_dsmuibge := TRIM(UPPER(translate(rw_crapmun.dscidesp,
                         '¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸',
                         'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu')));
              				
          vr_dsmuibge := REPLACE(vr_dsmuibge,'''',' ');
        
          -- Adicionar a tabela
          vr_tab_cid(UPPER(rw_crapmun.cdestado || vr_dsmuibge)).cdcidbge := rw_crapmun.cdcidbge;
          vr_tab_cid(UPPER(rw_crapmun.cdestado || vr_dsmuibge)).cdufibge := rw_crapmun.cdufibge;
        END LOOP;

        -- Ultimo dia util do mes anterior
        vr_dtrefere := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => rw_crapdat.dtultdma
                                                  ,pr_tipo => 'A'); -- Anterior

        -- Busca o diretorio salvar da coop
        vr_nmdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'salvar');

        -- Busca o diretorio micros contab
        vr_nmdirmic := GENE0001.fn_diretorio(pr_tpdireto => 'M' --> /micros
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'contab');

        -- Busca as contas que serao enviadas como encerrada
        vr_tab_cpf_cnpj_encerrados.DELETE;
        FOR vr_indice IN 1 .. 10 LOOP
          vr_dsvlrprm := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => pr_cdcooper
                                                  ,pr_cdacesso => 'CRPS691_ENCERRADO_' || TO_CHAR(vr_indice));
          
          IF vr_dsvlrprm IS NULL THEN
            EXIT;
          END IF;
          
          -- Carrega os cooperado que serao enviado como encerrado
          pc_carrega_tab_encerrados(pr_string => vr_dsvlrprm,
                                    pr_tab_cpf_cnpj_encerrados => vr_tab_cpf_cnpj_encerrados);          
        END LOOP;
            
        -- Nome do arquivo XML
        vr_nmarqxml := '5300' || LPAD(pr_cdcooper, 2, '0') || TO_CHAR(vr_dtrefere,'MMYY')||'.xml';
        
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_xml_5300, TRUE);
        dbms_lob.open(vr_xml_5300, dbms_lob.lob_readwrite);

        -- Inicializar o CLOB do relatorio crrl5300
        dbms_lob.createtemporary(vr_xml_714, TRUE);
        dbms_lob.open(vr_xml_714, dbms_lob.lob_readwrite);
        -- Inicilizar as informaÁıes do XML
        gene0002.pc_escreve_xml(vr_xml_714,vr_xml_714_temp,'<?xml version="1.0" encoding="utf-8"?><crrl714>');

        -- Insere o cabecalho
        GENE0002.pc_escreve_xml(pr_xml            => vr_xml_5300
                               ,pr_texto_completo => vr_xml_5300_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>' || chr(10)
                                                  || '<Doc5300 codigo-documento="5300" cnpj="' || SUBSTR(LPAD(TO_CHAR(rw_crapcop.nrdocnpj), 14, 0), 1, 8) || '" tipo-remessa="I" data-base="' || TO_CHAR(vr_dtrefere,'YYYY-MM') || '">' || chr(10)
                                                  || '    <cooperados>' || chr(10));
        
        vr_dtdemiss := to_date('01/01/0001','DD/MM/YYYY');
        
        -- Listagem dos associados
        FOR rw_coop_dados IN cr_coop_dados(pr_cdcooper => pr_cdcooper
                                          ,pr_dtrefere => vr_dtrefere) LOOP

          -- Verifica se devemos enviar a conta como encerrada                         
          IF vr_tab_cpf_cnpj_encerrados.EXISTS(rw_coop_dados.nrcpfcgc) THEN
            CONTINUE;
          END IF;

          -- Caso seja a primeira ocorrencia do CPF/CNPJ
          IF rw_coop_dados.nrseq = 1 THEN
            
            vr_nrcpfcgc := rw_coop_dados.nrcpfcgc;
            
            IF rw_coop_dados.inpessoa = 1 THEN
              vr_inpessoa := 1;
              vr_dscpfcgc := LPAD(TO_CHAR(vr_nrcpfcgc), 11, 0);
            ELSE
              vr_inpessoa := 2;
              vr_dscpfcgc := LPAD(TO_CHAR(vr_nrcpfcgc), 14, 0);
            END IF;
            
            -- Guarda a data mais antiga
            vr_dtadmiss := rw_coop_dados.dtadmiss;
            
            vr_dtiniadm := vr_dtadmiss;
            
            OPEN cr_crapalt(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_coop_dados.nrdconta);
            FETCH cr_crapalt INTO vr_dtiniadm;
            CLOSE cr_crapalt;

            -- Insere a abertura do NO de cooperado
            GENE0002.pc_escreve_xml(pr_xml            => vr_xml_5300
                                   ,pr_texto_completo => vr_xml_5300_temp
                                   ,pr_texto_novo     => '        <cooperado pessoa="' || vr_inpessoa || '" identificacao="' || vr_dscpfcgc || '">' || chr(10));
            
          END IF;
          
          -- Vai guardando os dados do relacionamento atual
          IF rw_coop_dados.dtdemiss IS NULL THEN
            
            -- Possui relacionamento atual
            vr_flgativo := TRUE;

            -- Caso possua Emprestimo, Financiamento ou Limite de Credito
            IF (rw_coop_dados.vlsdempr + rw_coop_dados.vlsdfina + rw_coop_dados.vllimcre) > 0 THEN
              vr_flgopcre := 'S';
            END IF;

            -- Caso possua Aplicacao ou Poupanca Programada
            IF (rw_coop_dados.vlsdrdca + rw_coop_dados.vlsdrdpp) > 0 THEN
              vr_flgdpraz := 'S';
            END IF;

            -- Caso possua Saldo de RDCA 30 ou Saldo de RDCA 60
            IF (rw_coop_dados.vlsrdc30 + rw_coop_dados.vlsrdc60) > 0 THEN
              vr_flgdavis := 'S';
            END IF;

            -- Caso possua Limite Desconto de Titulos ou Limite Desconto de Cheques
            IF (rw_coop_dados.vllimtit + rw_coop_dados.vllimdsc) > 0 THEN
              vr_flgoutro := 'S';
            END IF;
            
            -- Zera valor da subscricao do capital
            vr_vlsomado := 0;

            -- Verifica a subscricao do capital
            OPEN cr_crapsdc(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_coop_dados.nrdconta
                           ,pr_dtrefere => vr_dtrefere);
            FETCH cr_crapsdc INTO vr_vlsomado;
            CLOSE cr_crapsdc;

            -- Soma o Saldo de Cotas e Subscricao do Capital
            vr_vlsdcota := vr_vlsdcota + rw_coop_dados.vlsdcota;
            vr_vllanmto := vr_vllanmto + NVL(/*rw_coop_dados.vlprepla */ vr_vlsomado,0);
            
            vr_ufcidade := UPPER(rw_coop_dados.cdufende) ||
                           TRIM(UPPER(translate(rw_coop_dados.nmcidade,
                           '¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸',
                           'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu')));

            -- Busca o codigo do municipio
            IF vr_tab_cid.EXISTS(vr_ufcidade) THEN
              vr_cdmuibge := vr_tab_cid(vr_ufcidade).cdcidbge;
              vr_cdufibge := vr_tab_cid(vr_ufcidade).cdufibge;
            ELSE
              vr_cdmuibge := 99999;
              vr_cdufibge := 99;
            END IF;
            
            vr_municipio := TRIM(TO_CHAR(vr_cdufibge,'00')) || TRIM(TO_CHAR(vr_cdmuibge,'00000'));
            
            vr_dsrelatu := '            <relacionamento-atual inicio="' || TO_CHAR(vr_dtadmiss,'YYYY-MM-DD') || '">' || chr(10) 
                        || '                <municipio>' || vr_municipio || '</municipio>' || chr(10)
                        || '                <operacoes-como-titular>' || chr(10)
                        || '                    <conta-corrente>S</conta-corrente>' || chr(10)
                        || '                    <deposito-a-prazo>' || vr_flgdpraz || '</deposito-a-prazo>' || chr(10)
                        || '                    <deposito-sob-aviso>' || vr_flgdavis || '</deposito-sob-aviso>' || chr(10)
                        || '                    <op-credito>' || vr_flgopcre || '</op-credito>' || chr(10)
                        || '                    <outros>' || vr_flgoutro || '</outros>' || chr(10)
                        || '                </operacoes-como-titular>' || chr(10)
                        || '                <capital-integralizado>' || TO_CHAR(vr_vlsdcota,'fm999999999990d00','NLS_NUMERIC_CHARACTERS=''.,''') || '</capital-integralizado>' || chr(10)
                        || '                <capital-a-integralizar>' || TO_CHAR(vr_vllanmto,'fm999999999990d00','NLS_NUMERIC_CHARACTERS=''.,''') || '</capital-a-integralizar>' || chr(10)
                        || '            </relacionamento-atual>' || chr(10);
          ELSE

            -- Vai guardando os relacionamentos encerrados
            vr_dsrelenc := vr_dsrelenc || '                <relacionamento inicio="' || TO_CHAR(vr_dtiniadm,'YYYY-MM-DD') || '" fim="' || TO_CHAR(rw_coop_dados.dtdemiss,'YYYY-MM-DD') || '" />' || chr(10);
          
            -- Armazena data demissao mais atual
            IF rw_coop_dados.dtdemiss > vr_dtdemiss THEN
               vr_dtdemiss := rw_coop_dados.dtdemiss;
            END IF;   
            
          END IF;

          -- Escreve quando ultimo registro do cpf/cnpg
          IF rw_coop_dados.nrseq = rw_coop_dados.qtreg THEN
 
              -- Caso tenha relacionamento atual
              IF vr_dsrelatu IS NOT NULL THEN
                -- Insere o relacionamento atual
                GENE0002.pc_escreve_xml(pr_xml            => vr_xml_5300
                                       ,pr_texto_completo => vr_xml_5300_temp
                                       ,pr_texto_novo     => vr_dsrelatu);
                                       
                --Montar tag da conta para arquivo XML
                gene0002.pc_escreve_xml(vr_xml_714,
                                        vr_xml_714_temp,
                                        '<conta>
                                            <nrdconta>'||LTrim(gene0002.fn_mask_conta(rw_coop_dados.nrdconta))||'</nrdconta>
                                            <nmprimtl>'||rw_coop_dados.nmprimtl||'</nmprimtl>
                                            <nrcpfcgc>'||LTRIM(gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_coop_dados.nrcpfcgc,pr_inpessoa => rw_coop_dados.inpessoa))||'</nrcpfcgc>
                                            <capital-integralizado>'||TO_CHAR(vr_vlsdcota) ||'</capital-integralizado>
                                            <capital-a-integralizar>'||TO_CHAR(vr_vllanmto)||'</capital-a-integralizar>
                                         </conta>');
              END IF;

              -- Caso tenha algum relacionamento encerrado
              IF vr_dsrelenc IS NOT NULL AND vr_flgativo = FALSE THEN
                
                IF vr_dtadmiss > vr_dtdemiss THEN
                  vr_dtadmiss := NVL(vr_dtiniadm,to_date('01/01/0001','DD/MM/YYYY'));
                END IF;  
                
                vr_dsrelenc := '                <relacionamento inicio="' || TO_CHAR(vr_dtadmiss,'YYYY-MM-DD') || '" fim="' || TO_CHAR(vr_dtdemiss,'YYYY-MM-DD') || '" />' || chr(10); 
              
                -- Insere o relacionamento encerrado
                GENE0002.pc_escreve_xml(pr_xml            => vr_xml_5300
                                       ,pr_texto_completo => vr_xml_5300_temp
                                       ,pr_texto_novo     => '            <relacionamentos-encerrados>' || chr(10)
                                                          || vr_dsrelenc
                                                          || '            </relacionamentos-encerrados>' || chr(10));
              END IF;

              -- Insere o fechamento do NO de cooperado
              GENE0002.pc_escreve_xml(pr_xml            => vr_xml_5300
                                     ,pr_texto_completo => vr_xml_5300_temp
                                     ,pr_texto_novo     => '        </cooperado>' || chr(10));
              -- Reinicia as variaveis
              vr_dsrelatu := NULL;
              vr_dsrelenc := NULL;
              vr_flgdpraz := 'N';
              vr_flgdavis := 'N';
              vr_flgopcre := 'N';
              vr_flgoutro := 'N';
              vr_vlsdcota := 0;
              vr_vllanmto := 0;
              vr_flgativo := FALSE;
              vr_dtdemiss := to_date('01/01/0001','DD/MM/YYYY');
            END IF;

        END LOOP;

        -- Reinicia as variaveis
        vr_dsrelatu := NULL;
        vr_dsrelenc := NULL;
        vr_flgativo := FALSE;
        
        vr_dtdemiss := to_date('01/01/0001','DD/MM/YYYY');

        -- Listagem dos representantes legais dos cooperados
        FOR rw_rep_legal IN cr_rep_legal(pr_cdcooper => pr_cdcooper
                                        ,pr_dtrefere => vr_dtrefere) LOOP
          
          -- Verifica se devemos enviar a conta como encerrada                         
          IF vr_tab_cpf_cnpj_encerrados.EXISTS(rw_rep_legal.nrcpfcgc) THEN
            CONTINUE;
          END IF;
          
          vr_nrcpfcgc := rw_rep_legal.nrcpfcgc;

          -- Caso seja um CPF invalido do Responsavel Legal grava log
          IF LENGTH(vr_nrcpfcgc) > 11 THEN

            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2, -- Erro tratato
                                       pr_des_log      => to_char(sysdate,'hh24:mi:ss')
                                                       || ' - ' || vr_cdprogra || ' --> ' 
                                                       || 'CPF invalido Resp. Legal: ' || vr_nrcpfcgc 
                                                       || ', crapcrl ou crapavt.');
            CONTINUE;                                           
          END IF;
          
          -- Caso seja a primeira ocorrencia do CPF/CNPJ
          IF rw_rep_legal.nrseq = 1 THEN
            
            vr_inpessoa := 1;
            vr_dscpfcgc := LPAD(TO_CHAR(vr_nrcpfcgc), 11, 0);
            
            -- Guarda a data mais antiga
            vr_dtadmiss := rw_rep_legal.dtinicio;

            -- Insere a abertura do NO de cooperado
            GENE0002.pc_escreve_xml(pr_xml            => vr_xml_5300
                                   ,pr_texto_completo => vr_xml_5300_temp
                                   ,pr_texto_novo     => '        <cooperado pessoa="' || vr_inpessoa || '" identificacao="' || vr_dscpfcgc || '">' || chr(10));
          END IF;    

          -- Caso a data de Vigencia seja nula
          IF rw_rep_legal.dtvigenc IS NULL THEN
            
            -- Possui relacionamento atual
            vr_flgativo := TRUE;
            
            -- Vai guardando os dados do relacionamento atual
            vr_dsrelatu := '            <relacionamento-atual inicio="' || TO_CHAR(vr_dtadmiss,'YYYY-MM-DD') || '" />' || chr(10);
          ELSE
            -- Vai guardando os relacionamentos encerrados
  	        vr_dsrelenc := vr_dsrelenc || '                <relacionamento inicio="' || TO_CHAR(rw_rep_legal.dtinicio,'YYYY-MM-DD') || '" fim="' || TO_CHAR(rw_rep_legal.dtvigenc,'YYYY-MM-DD') || '" />' || chr(10);
          
            -- Armazena data demissao mais atual
            IF rw_rep_legal.dtvigenc > vr_dtdemiss THEN
               vr_dtdemiss := rw_rep_legal.dtvigenc;
            END IF;
          
          END IF;
          
          -- Escreve quando ultimo registro do CPF/CNPJ
          IF rw_rep_legal.nrseq = rw_rep_legal.qtreg THEN
            
            -- Caso tenha relacionamento atual ou encerrado
            IF vr_dsrelatu IS NOT NULL OR (vr_dsrelenc IS NOT NULL AND vr_flgativo = FALSE) THEN

              -- Caso tenha relacionamento atual
              IF vr_dsrelatu IS NOT NULL THEN
                -- Insere o relacionamento atual
                GENE0002.pc_escreve_xml(pr_xml            => vr_xml_5300
                                       ,pr_texto_completo => vr_xml_5300_temp
                                       ,pr_texto_novo     => vr_dsrelatu);
              END IF;

              -- Caso tenha algum relacionamento encerrado
              IF vr_dsrelenc IS NOT NULL AND vr_flgativo = FALSE THEN
                  
                vr_dsrelenc := '                <relacionamento inicio="' || TO_CHAR(vr_dtadmiss,'YYYY-MM-DD') || '" fim="' || TO_CHAR(vr_dtdemiss,'YYYY-MM-DD') || '" />' || chr(10); 
                
                -- Insere o relacionamento encerrado
                GENE0002.pc_escreve_xml(pr_xml            => vr_xml_5300
                                       ,pr_texto_completo => vr_xml_5300_temp
                                       ,pr_texto_novo     => '            <relacionamentos-encerrados>' || chr(10)
                                                          || vr_dsrelenc
                                                          || '            </relacionamentos-encerrados>' || chr(10));
              END IF;

              -- Insere o fechamento do NO de cooperado
              GENE0002.pc_escreve_xml(pr_xml            => vr_xml_5300
                                     ,pr_texto_completo => vr_xml_5300_temp
                                     ,pr_texto_novo     => '        </cooperado>' || chr(10));
              
              -- Reinicia as variaveis
              vr_dsrelatu := NULL;
              vr_dsrelenc := NULL;
              vr_flgativo := FALSE;
              vr_dtdemiss := to_date('01/01/0001','DD/MM/YYYY');
            END IF;

          END IF;

        END LOOP;

        -- Encerra o documento 5300
        GENE0002.pc_escreve_xml(pr_xml            => vr_xml_5300
                               ,pr_texto_completo => vr_xml_5300_temp
                               ,pr_texto_novo     => '    </cooperados>' || chr(10)
                                                  || '</Doc5300>' || chr(10)
                               ,pr_fecha_xml      => true);

        -- Gera o arquivo XML
        GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper
                                           ,pr_cdprogra  => vr_cdprogra
                                           ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                           ,pr_dsxml     => vr_xml_5300
                                           ,pr_dsarqsaid => vr_nmdireto || '/' || vr_nmarqxml
                                           ,pr_cdrelato  => NULL
                                           ,pr_flg_gerar => 'N'              --> Apenas submeter
                                           ,pr_dspathcop => vr_nmdirmic      --> Copiar para a Micros
                                           ,pr_fldoscop  => 'S'              --> Efetuar cÛpia com Ux2Dos
                                           ,pr_dscmaxcop => '| tr -d "\032"'
                                           ,pr_des_erro  => vr_dscritic);

        -- Liberando a memoria alocada pro CLOB
        dbms_lob.close(vr_xml_5300);
        dbms_lob.freetemporary(vr_xml_5300);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Finaliza o relatorio crrl291
        gene0002.pc_escreve_xml(vr_xml_714,vr_xml_714_temp,'</crrl714>',true);
        -- Efetuar solicitaÁ„o de geraÁ„o de relatÛrio --
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_xml_714     --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl714/conta'   --> NÛ base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl714.jasper'   --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                --> Nao tem parametros                                   
                                   ,pr_dsarqsaid => vr_nmdirmic || '/crrl5300.pdf'
                                   ,pr_qtcoluna  => 132                 --> 132 colunas
                                   ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                   ,pr_flg_impri => 'N'                 --> Chamar a impress„o (Imprim.p)
                                   ,pr_nmformul  => '132dm'             --> Nome do formul·rio para impress„o
                                   ,pr_nrcopias  => 1                   --> N˙mero de cÛpias
                                   ,pr_flg_gerar => 'N'                 --> gerar PDF
                                   ,pr_des_erro  => vr_dscritic);       --> SaÌda com erro

        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Liberando a memÛria alocada pro CLOB
        dbms_lob.close(vr_xml_714);
        dbms_lob.freetemporary(vr_xml_714);
      END IF;

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informaÁıes atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas cÛdigo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descriÁ„o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos cÛdigo e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro n„o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps691;
/
