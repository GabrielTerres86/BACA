CREATE OR REPLACE PACKAGE CECRED.INSS0003 AS

   /*---------------------------------------------------------------------------------------------------------------

   Programa : INSS0003
   Autor    : Douglas Quisinski
   Data     : 20/03/2017                        Ultima atualizacao: 22/06/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Importa��o da planilha de prova de vida

   Altera��es: 
   
   -- 22/06/2017 - inclus�o da variante de tipo se for erro tratado ou mensagem(alerta) - pr_ind_tipo_log_in
                 - Setado modulo pr_ind_tipo_log_in para variar se � erro ou alertar
                 - Chamado 660286 - (Belli - Envolti)
   
  --------------------------------------------------------------------------------------------------------------- */
  
  PROCEDURE pc_importar_prova_vida(pr_cdprogra   IN VARCHAR2     -- Programa que esta executando
                                  ,pr_dsdireto   IN VARCHAR2     -- Diretorio onde esta o arquivo
                                  ,pr_cdcritic  OUT PLS_INTEGER  -- C�digo da cr�tica
                                  ,pr_dscritic  OUT VARCHAR2);   -- Descri��o da cr�tica
  
END INSS0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.INSS0003 AS

  /*---------------------------------------------------------------------------------------------------------------
   Programa : INSS0003
   Autor    : Douglas Quisinski
   Data     : 20/03/2017                        Ultima atualizacao: 22/06/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Importa��o da planilha de prova de vida

   Alteracoes: 
   
   -- 22/06/2017 - inclus�o da variante de tipo se for erro tratado ou mensagem(alerta) - pr_ind_tipo_log_in
                 - Setado modulo pr_ind_tipo_log_in para variar se � erro ou alertar
                 - Chamado 660286 - (Belli - Envolti)
  
  ---------------------------------------------------------------------------------------------------------------*/

  PROCEDURE pc_gera_log_prova_vida(pr_cdcritic        IN crapcri.cdcritic%TYPE     -- Codigo do Erro
                                  ,pr_dscritic        IN crapcri.dscritic%TYPE     -- Descricao do Erro
                                  ,pr_ind_tipo_log_in IN NUMBER                    --> Tipo de mensagem do log
                                  ,pr_cdprograma_in   IN VARCHAR2                  --> programa ou job
                                  ,pr_dserro          OUT crapcri.dscritic%TYPE) IS -- Mensagem caso ocorra erro no log
  

    -- ..........................................................................
    --
    --  Programa : pc_gera_log_prova_vida
    --  Sistema  : Trata das informa�oes de INSS dos cooperados
    --  Sigla    : INSS
    --  Autor    :   - 
    --  Data     : .                   Ultima atualizacao: 22/06/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: 
    --   Objetivo  : Importa��o da planilha de prova de vida.
    --
    -- .............................................................................
    --   Alteracoes: 
    --   22/06/2017 - inclus�o da variante de tipo se for erro tratado ou mensagem(alerta) - pr_ind_tipo_log_in 
    --              - Setado modulo pr_ind_tipo_log_in para variar se � erro ou alertar
    --              - Chamado 660286 - (Belli - Envolti)
    -- .............................................................................
    --                                  
  
    vr_dscriti2 VARCHAR2(20000);
    
  BEGIN
	  -- Incluir nome do m�dulo logado - 22/06/2017 - Chamado 660286
		GENE0001.pc_set_modulo(pr_module => pr_cdprograma_in, pr_action => 'INSS0003.pc_gera_log_prova_vida');
      
    -- Se foi retornado apenas c�digo
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descri��o
      vr_dscriti2 := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;

    IF TRIM(pr_dscritic) IS NOT NULL THEN
      vr_dscriti2 := pr_dscritic;
    END IF;

    -- Envio centralizado de log de erro
    -- LOG sempre ser� gerado na CECRED
    
    -- inclus�o de informa��o do par�metro de entrada - 22/06/2017 - Chamado 660286
    
    btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                              ,pr_ind_tipo_log => pr_ind_tipo_log_in
                              ,pr_des_log      => vr_dscriti2
                              ,pr_nmarqlog     => 'log_crps700'
                              ,pr_cdprograma   => pr_cdprograma_in
                               );

  EXCEPTION
    WHEN OTHERS THEN
      pr_dserro := 'Erro na INSS0003.pc_gera_log_prova_vida --> ' || 
                   REPLACE(REPLACE(SQLERRM, '"', NULL), '''', NULL);
  END pc_gera_log_prova_vida;


  PROCEDURE pc_importar_prova_vida(pr_cdprogra   IN VARCHAR2     -- Programa que esta executando
                                  ,pr_dsdireto   IN VARCHAR2     -- Diretorio onde esta o arquivo
                                  ,pr_cdcritic  OUT PLS_INTEGER  -- C�digo da cr�tica
                                  ,pr_dscritic  OUT VARCHAR2) IS -- Descri��o da cr�tica

    -- ..........................................................................
    --
    --  Programa : pc_importar_prova_vida
    --  Sistema  : Trata das informa�oes de INSS dos cooperados
    --  Sigla    : INSS
    --  Autor    :   - 
    --  Data     : .                   Ultima atualizacao: 22/06/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: 
    --   Objetivo  : Trata das informa�oes de INSS dos cooperados.
    --
    --   Alteracoes: 
    --   22/06/2017 - inclus�o da variante de tipo se for erro tratado ou mensagem(alerta) - pr_ind_tipo_log_in 
    --              - Setado modulo pr_ind_tipo_log_in para variar se � erro ou alertar
    --              - Chamado 660286 - (Belli - Envolti)
    --   
    --   12/06/2018 - Projeto 413 - Mudanca de Marcas (Paulo Martins-Mout�s)
    -- .............................................................................
    --
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_valid  EXCEPTION;
    vr_exc_email  EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    
    -- Variaveis
    vr_tab_linhas gene0009.typ_tab_linhas;
    vr_indice2    PLS_INTEGER;
    vr_contareg   PLS_INTEGER;
    vr_nmarquiv   CONSTANT VARCHAR2(20) := 'PV_CECRED.csv';
    vr_dsarqimp   VARCHAR2(500);
    vr_dsdanexo   VARCHAR2(1000);
    vr_dserro     VARCHAR2(10000); 

--    lt_d_nrsequen   NUMBER:=0;
--    lt_d_dtinclus   DATE;
    lt_d_nrrecben   NUMBER:=0;
    lt_d_cdorgins   NUMBER:=0;
    lt_d_dtvencpv   DATE;
    vr_houveerro    BOOLEAN:=FALSE;
    vr_linhaserro   VARCHAR2(2000);
    
    -- Variaveis - Chamado 665812 - 01/06/2017
    vr_ind_tipo_log    number    (2)     := 2;        -- erro tratado
    ds_ind_tipo_log    varchar2 (10)     := 'ERRO: '; -- erro tratado
    
    ------------------------------- CURSORES ---------------------------------

    -- Cursor gen�rico de calend�rio
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Verificar se NB existe
    CURSOR cr_dcb(pr_nrrecben IN tbinss_dcb.nrrecben%TYPE)IS
      SELECT dcb.id_dcb
            ,dcb.dtvencpv
        FROM tbinss_dcb dcb
       WHERE dcb.nrrecben = pr_nrrecben;
    rw_dcb cr_dcb%ROWTYPE;

    -- Buscar o CPF do NB informado
    CURSOR cr_crapdbi(pr_nrrecben IN crapdbi.nrrecben%TYPE)IS
      SELECT dbi.rowid
            ,dbi.nrcpfcgc
        FROM crapdbi dbi
       WHERE dbi.nrrecben = pr_nrrecben
         AND rownum       = 1;
    rw_crapdbi cr_crapdbi%ROWTYPE;

    -- Buscar a Cooperativa do OP
    CURSOR cr_crapage(pr_cdorgins IN crapage.cdorgins%TYPE)IS
      SELECT age.cdagenci
            ,age.cdcooper
            ,cop.cdagesic
        FROM crapage age, crapcop cop
       WHERE cop.cdcooper = age.cdcooper
         AND age.cdorgins = pr_cdorgins;
    rw_crapage cr_crapage%ROWTYPE;

    -- Buscar as Contas do CPF
    CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
                     ,pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE)IS
      SELECT ttl.nrdconta
            ,ttl.nmextttl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrcpfcgc = pr_nrcpfcgc;
    rw_crapttl cr_crapttl%ROWTYPE;

    -- Verificar se a conta teve lancamento 1399 nos ultimos 3 meses
    CURSOR cr_craplcm_inss(pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                          ,pr_nrdconta IN tbinss_dcb.nrdconta%TYPE) IS
      SELECT 1
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.nrdconta = pr_nrdconta
         AND lcm.cdhistor = 1399
         AND lcm.dtmvtolt <= pr_dtmvtolt
         AND lcm.dtmvtolt >= (pr_dtmvtolt - 90);
    rw_craplcm_inss cr_craplcm_inss%ROWTYPE;
    
  BEGIN

	  -- Incluir nome do m�dulo logado - 22/06/2017 - Chamado 660286
		GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');

    vr_houveerro := FALSE;
    -- Arquivo para importar
    vr_dsarqimp  := pr_dsdireto || '/' || vr_nmarquiv;
    -- Arquivos enviados em anexo
    vr_dsdanexo  := vr_dsarqimp || ';' || 
                    gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                         ,pr_cdcooper => 3
                                         ,pr_nmsubdir => 'log')  ||
                    '/log_crps700.log';                 
    
    IF NOT gene0001.fn_exis_arquivo(pr_caminho => pr_dsdireto || '/' || vr_nmarquiv) THEN
      vr_dscritic := 'Nao existe arquivo ' || vr_nmarquiv || ' na pasta!';
      
      -- Gerar alerta - 22/06/2017 - Chamado 660286
      
      vr_ind_tipo_log              := 1;          -- mensagem tratada
      ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado
      
      RAISE vr_exc_saida;        
    END IF;

    -- Importar o arquivo utilizando o Layout, separado por Virgula
    gene0009.pc_importa_arq_layout(pr_nmlayout   => 'INSSVIDA'
                                  ,pr_dsdireto   => pr_dsdireto
                                  ,pr_nmarquiv   => vr_nmarquiv
                                  ,pr_dscritic   => vr_dscritic
                                  ,pr_tab_linhas => vr_tab_linhas);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      vr_dscritic := vr_dscritic || ' , Arquivo: ' || vr_nmarquiv;
      RAISE vr_exc_saida;
    END IF;
                          
    -- Se menos que 2 linha (linha 1 = Cabe�alho)
    IF vr_tab_linhas.count < 2 THEN
      vr_dscritic := 'Arquivo ' || vr_nmarquiv || ' nao possui conteudo!';
      
      -- Gerar alerta - 22/06/2017 - Chamado 660286      
      vr_ind_tipo_log              := 1;          -- mensagem tratada
      ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado
      
      RAISE vr_exc_saida;
    END IF;

    -- Leitura do calend�rio da cooperativa, apenas se o arquivo for valido 
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    -- Gerar hora inicio no log
    vr_ind_tipo_log              := 1;          -- mensagem tratada
    ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado
    pc_gera_log_prova_vida(pr_cdcritic => 0
                          ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                          ' - ' || pr_cdprogra  || ' --> ' ||
                                          ds_ind_tipo_log ||
                                           ' INICIO.'
                          ,pr_ind_tipo_log_in => vr_ind_tipo_log
                          ,pr_cdprograma_in   => pr_cdprogra
                          ,pr_dserro   => vr_dserro);

	  -- Incluir nome do m�dulo logado - 22/06/2017 - Chamado 660286
		GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');
          
    -- Assumir como padr�o erro - 22/06/2017 - Chamado 660286
    vr_ind_tipo_log              := 2;        -- erro tratado
    ds_ind_tipo_log              := 'ERRO: '; -- erro tratado
                          
    
    vr_contareg := 0; -- Contador de Linhas

    -- Navegar em cada linha do arquivo aberto para leitura
    FOR vr_indice2 IN vr_tab_linhas.FIRST..vr_tab_linhas.LAST LOOP --LINHAS ARQUIVO

      -- Assumir como padr�o erro - 22/06/2017 - Chamado 660286
      vr_ind_tipo_log              := 2;        -- erro tratado
      ds_ind_tipo_log              := 'ERRO: '; -- erro tratado

      vr_contareg := vr_contareg + 1; --Conta qtd de linhas do arquivo

      -- Se for a linha de cabe�alho do arquivo
      IF  vr_contareg = 1 THEN
        CONTINUE;
      END IF;

      IF vr_tab_linhas(vr_indice2).exists('$ERRO$') THEN --Problemas com importacao do layout
        IF vr_houveerro THEN -- TRUE (Primeira vez, estar� false)
          vr_linhaserro := vr_linhaserro || ', ' || vr_contareg;
        ELSE
          vr_linhaserro := vr_contareg;
        END IF;

        vr_houveerro  := TRUE;

        CONTINUE;
      END IF;

      -- Coloca o conteudo da linha/coluna em cada campo
      BEGIN
--        lt_d_nrsequen := to_number(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('NRSEQUEN').texto,'"','')));
--        lt_d_dtinclus := to_date(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('DTINCLUS').texto,'"','')),'DD/MM/RRRR');
        lt_d_nrrecben := to_number(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('NRRECBEN').texto,'"','')));
        lt_d_cdorgins := to_number(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('CDORGINS').texto,'"','')));
        lt_d_dtvencpv := to_date(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('DTVENCPV').texto,'"','')),'DD/MM/RRRR');
          
        IF (lt_d_nrrecben IS NULL OR lt_d_nrrecben = 0) OR
           (lt_d_cdorgins IS NULL OR lt_d_cdorgins = 0) OR
           (lt_d_dtvencpv IS NULL)                      THEN
          RAISE vr_exc_valid;
        END IF;
          
      EXCEPTION
        WHEN vr_exc_valid THEN -- Erro de Valida��o
          IF vr_houveerro THEN -- TRUE (Primeira vez, estar� false)
            vr_linhaserro := vr_linhaserro || ', ' || vr_contareg;
          ELSE
            vr_linhaserro := vr_contareg;
          END IF;

          vr_houveerro  := TRUE;

          CONTINUE;
        
        WHEN OTHERS THEN   -- Erro de Atribui��o / Tipo inv�lido
          IF vr_houveerro THEN -- TRUE (Primeira vez, estar� false)
            vr_linhaserro := vr_linhaserro || ', ' || vr_contareg;
          ELSE
            vr_linhaserro := vr_contareg;
          END IF;

          vr_houveerro  := TRUE;

          CONTINUE;
      END;

      -- Verificar se o NB do arquivo j� est� na base
      OPEN cr_dcb(pr_nrrecben => lt_d_nrrecben);
      FETCH cr_dcb INTO rw_dcb;

      IF cr_dcb%NOTFOUND THEN -- Se o NB ainda n�o est� na base, criar

        CLOSE cr_dcb;

        -- Buscar o CPF do NB do arquivo
        OPEN cr_crapdbi(pr_nrrecben => lt_d_nrrecben);
        FETCH cr_crapdbi INTO rw_crapdbi;
        IF cr_crapdbi%NOTFOUND THEN
          CLOSE cr_crapdbi;
      
          -- Gerar alerta - 22/06/2017 - Chamado 660286  
          vr_ind_tipo_log              := 1;          -- mensagem tratada
          ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado

          -- Gera LOG
          pc_gera_log_prova_vida(pr_cdcritic => 0
                                ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                                ' - ' || pr_cdprogra  || ' --> ' ||
                                                ds_ind_tipo_log ||
                                                ' CPF do NB do arquivo nao localizado! NB: ' 
                                                || lt_d_nrrecben
                                ,pr_ind_tipo_log_in => vr_ind_tipo_log
                                ,pr_cdprograma_in   => pr_cdprogra
                                ,pr_dserro    => vr_dserro);
                                
	        -- Incluir nome do m�dulo logado - 22/06/2017 - Chamado 660286
		      GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');
          
          -- Verificar se ocorreu erro na gera��o do LOG
          IF TRIM(vr_dserro) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          CONTINUE; -- Passa para pr�xima linha do arquivo
        END IF;
        CLOSE cr_crapdbi;

        -- Verificar a cooperativa do OP/NB
        OPEN cr_crapage(pr_cdorgins => lt_d_cdorgins);
        FETCH cr_crapage INTO rw_crapage;
        IF cr_crapage%NOTFOUND THEN
          CLOSE cr_crapage;
      
          -- Gerar alerta - 22/06/2017 - Chamado 660286      
          vr_ind_tipo_log              := 1;          -- mensagem tratada
          ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado
          
          -- Gera LOG
          pc_gera_log_prova_vida(pr_cdcritic => 0
                                ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                                 ' - ' || pr_cdprogra  || ' --> ' ||
                                                 ds_ind_tipo_log ||
                                                  ' OP do arquivo nao localizado! OP: '|| 
                                                 lt_d_cdorgins || ' - NB: ' || lt_d_nrrecben
                                ,pr_ind_tipo_log_in => vr_ind_tipo_log
                                ,pr_cdprograma_in   => pr_cdprogra
                                ,pr_dserro    => vr_dserro);
                                
	        -- Incluir nome do m�dulo logado - 22/06/2017 - Chamado 660286
		      GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');
          
          -- Verificar se ocorreu erro na gera��o do LOG
          IF TRIM(vr_dserro) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          
          CONTINUE; -- Passa para pr�xima linha do arquivo
        END IF;
        CLOSE cr_crapage;

        -- Buscar as Contas do CPF
        OPEN cr_crapttl(pr_cdcooper => rw_crapage.cdcooper
                       ,pr_nrcpfcgc => rw_crapdbi.nrcpfcgc);
        FETCH cr_crapttl INTO rw_crapttl;
        IF cr_crapttl%NOTFOUND THEN
          CLOSE cr_crapttl;
          
          -- Gerar alerta - 22/06/2017 - Chamado 660286
          vr_ind_tipo_log              := 1;          -- mensagem tratada
          ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado
          
          -- Gera LOG
          pc_gera_log_prova_vida(pr_cdcritic => 0
                                ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                                ' - ' || pr_cdprogra  || ' --> ' ||
                                                ds_ind_tipo_log ||
                                                ' Titular nao localizado com o CPF: ' || 
                                                rw_crapdbi.nrcpfcgc||
                                                ' - NB: '||lt_d_nrrecben
                                ,pr_ind_tipo_log_in => vr_ind_tipo_log                                
                                ,pr_cdprograma_in   => pr_cdprogra
                                ,pr_dserro    => vr_dserro);
                                
	        -- Incluir nome do m�dulo logado - 22/06/2017 - Chamado 660286
		      GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');
          
          -- Verificar se ocorreu erro na gera��o do LOG
          IF TRIM(vr_dserro) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          CONTINUE; -- Passa para pr�xima linha do arquivo
        ELSE -- SE Encontrou
      
          -- Para todas as contas que encontrar com esse CPF
          LOOP
            -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
            EXIT WHEN cr_crapttl%NOTFOUND;

            -- Verificar se a conta possui LCM 1399 nos ultimos 3 meses
            OPEN cr_craplcm_inss(pr_cdcooper => rw_crapage.cdcooper,
                                 pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                 pr_nrdconta => rw_crapttl.nrdconta);
            FETCH cr_craplcm_inss INTO rw_craplcm_inss;

            IF cr_craplcm_inss%NOTFOUND THEN
              FETCH cr_crapttl INTO rw_crapttl;
              CLOSE cr_craplcm_inss;

              CONTINUE; -- Passa para pr�xima Conta TTL
            END IF;

            CLOSE cr_craplcm_inss;
            -- Gravar tbinss_dcb apenas para as contas que receberam
            -- credito de beneficio(1399) nos ultimos 3 meses.
            -- Se nao recebeu, n�o grava.

            -- Criar o registro
            INSERT INTO tbinss_dcb(id_dcb
                                  ,cdcooper
                                  ,nrdconta
                                  ,dtvencpv
                                  ,dtcompet
                                  ,nmemissor
                                  ,nrcnpj_emissor
                                  ,nmbenefi
                                  ,nrrecben
                                  ,cdorgins
                                  ,nrcpf_benefi
                                  ,cdagencia_conv  )
                            VALUES(fn_sequence('TBINSS_DCB','ID_DCB','ID_DCB')
                                  ,rw_crapage.cdcooper
                                  ,rw_crapttl.nrdconta
                                  ,lt_d_dtvencpv
                                  ,to_date('01/01/2008','dd/mm/RRRR')
                                  ,'INSTITUTO NACIONAL DO SEGURO SOCIAL'
                                  ,29979036000140
                                  ,rw_crapttl.nmextttl
                                  ,lt_d_nrrecben
                                  ,lt_d_cdorgins
                                  ,rw_crapdbi.nrcpfcgc
                                  ,rw_crapage.cdagesic
                                   ) RETURNING id_dcb INTO rw_dcb.id_dcb;

            FETCH cr_crapttl INTO rw_crapttl;
          END LOOP; -- FIM LOOP TTL
          CLOSE cr_crapttl;
        END IF; -- IF FOUND/NOTFOUND - cr_crapttl

      ELSE -- Se encontrou, atualizar

        -- Para DCB desse NB
        LOOP
          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_dcb%NOTFOUND;

          -- Verificar se a data no Arquivo � Maior que a data da Base
          IF lt_d_dtvencpv > rw_dcb.dtvencpv OR
             rw_dcb.dtvencpv IS NULL         THEN

            -- Atualizar o registro
            UPDATE tbinss_dcb
               SET tbinss_dcb.dtvencpv = lt_d_dtvencpv
             WHERE tbinss_dcb.id_dcb   = rw_dcb.id_dcb;
             
          END IF;

          FETCH cr_dcb INTO rw_dcb;
        END LOOP;
        CLOSE cr_dcb;

      END IF;

      COMMIT; -- Ao termino de cada linha, COMMIT

    END LOOP;  -- LOOP de Linhas do Arquivo

    IF vr_houveerro THEN
      
      -- Gerar alerta - 22/06/2017 - Chamado 660286    
      vr_ind_tipo_log              := 1;          -- mensagem tratada
      ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado
      
      vr_dscritic := 'Planilha foi importada com erro(s). Erro linha(s): ' 
                     || vr_linhaserro;
      
      -- Gera LOG
      pc_gera_log_prova_vida(pr_cdcritic => 0
                            ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                                ' - ' || pr_cdprogra  || ' --> ' ||
                                                ds_ind_tipo_log ||
                                                vr_dscritic
                            ,pr_ind_tipo_log_in => vr_ind_tipo_log
                            ,pr_cdprograma_in   => pr_cdprogra
                            ,pr_dserro    => vr_dserro);
                                
	    -- Incluir nome do m�dulo logado - 22/06/2017 - Chamado 660286
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');
          
      -- Verificar se ocorreu erro na gera��o do LOG
      IF TRIM(vr_dserro) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
    END IF;

    -- Gerar hora Fim no log
    vr_ind_tipo_log              := 1;          -- mensagem tratada
    ds_ind_tipo_log              := 'ALERTA: '; -- mensagem tratado    
    pc_gera_log_prova_vida(pr_cdcritic => 0
                          ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                          ' - ' || pr_cdprogra ||  ' --> ' ||
                                           'ALERTA: FINALIZADO COM SUCESSO.'
                          ,pr_ind_tipo_log_in => vr_ind_tipo_log
                          ,pr_cdprograma_in   => pr_cdprogra
                          ,pr_dserro   => vr_dserro);
                                
	  -- Incluir nome do m�dulo logado - 22/06/2017 - Chamado 660286
	  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');
          
    vr_ind_tipo_log              := 2;        -- erro tratado
    ds_ind_tipo_log              := 'ERRO: '; -- erro tratado

    -- Mandar email para INSS com o resultado do processo
    gene0003.pc_solicita_email(pr_cdcooper        => 3 --pr_cdcooper
                              ,pr_cdprogra        => pr_cdprogra
                              ,pr_des_destino     => 'inss@ailos.coop.br'
                              ,pr_des_assunto     => 'SICREDI - PLANILHA PROVA DE VIDA - LOG'
                              ,pr_des_corpo       => 'Em anexo a PLANILHA e o LOG de processamento.'  ||
                                                     '</br></br>' ||
                                                     'Processado em: ' || to_char(SYSDATE,'dd/mm/RRRR hh24:mi:ss')
                              ,pr_des_anexo       => vr_dsdanexo
                              ,pr_flg_remove_anex => 'S' --> Remover os anexos passados
                              ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                              ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                              ,pr_des_erro        => vr_dscritic);
    -- Se houver erros
    IF vr_dscritic IS NOT NULL THEN
      -- Gera critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro no envio do Email!' || '. Erro: '||vr_dscritic;
      RAISE vr_exc_saida;
    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN -- SAIDA SEM ENVIO DE EMAIL
      -- Se foi retornado apenas c�digo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descri��o
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos c�digo e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      -- Gerar hora Fim no log - 22/06/2017 - Chamado 660286
      
      pc_gera_log_prova_vida(pr_cdcritic => 0
                            ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                            ' - ' || pr_cdprogra ||  ' --> ' ||
                                            ds_ind_tipo_log ||
                                            pr_dscritic
                            ,pr_ind_tipo_log_in => vr_ind_tipo_log
                            ,pr_cdprograma_in   => pr_cdprogra
                            ,pr_dserro   => vr_dserro);
                                
                                
	    -- Incluir nome do m�dulo logado - 22/06/2017 - Chamado 660286
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');

      -- Mandar email para INSS com o resultado do processo
      gene0003.pc_solicita_email(pr_cdcooper        => 3 --pr_cdcooper
                                ,pr_cdprogra        => pr_cdprogra
                                ,pr_des_destino     => 'inss@ailos.coop.br'
                                ,pr_des_assunto     => 'SICREDI - PLANILHA PROVA DE VIDA - ERRO'
                                ,pr_des_corpo       => 'Houve erro no processamento da planilha.</br>' ||
                                                       'Em anexo a PLANILHA e o LOG de processamento.'  ||
                                                       '</br></br>' ||
                                                       'Processado em: ' || to_char(SYSDATE,'dd/mm/RRRR hh24:mi:ss')
                                ,pr_des_anexo       => vr_dsdanexo
                                ,pr_flg_remove_anex => 'S' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
  
    WHEN OTHERS THEN
      --Monta mensagem de critica
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na INSS0003.pc_importar_prova_vida --> ' ||
                     SQLERRM || ' SEQ: ' || vr_contareg;

      -- Gerar hora Fim no log
      pc_gera_log_prova_vida(pr_cdcritic => 0
                            ,pr_dscritic => to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS') ||
                                            ' - ' || pr_cdprogra ||  ' --> ' ||
                                            'ERRO: FINALIZADO COM ERRO. ' ||
                                            pr_dscritic
                            ,pr_ind_tipo_log_in => vr_ind_tipo_log
                            ,pr_cdprograma_in   => pr_cdprogra
                            ,pr_dserro   => vr_dserro);

      --Inclus�o na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_cdcooper => 3
                                   ,pr_compleme => pr_dscritic );
                                                                
	    -- Incluir nome do m�dulo logado - 22/06/2017 - Chamado 660286
		  GENE0001.pc_set_modulo(pr_module => pr_cdprogra, pr_action => 'INSS0003.pc_importar_prova_vida');

      -- Mandar email para INSS com o resultado do processo
      gene0003.pc_solicita_email(pr_cdcooper        => 3 --pr_cdcooper
                                ,pr_cdprogra        => pr_cdprogra
                                ,pr_des_destino     => 'inss@ailos.coop.br'
                                ,pr_des_assunto     => 'SICREDI - PLANILHA PROVA DE VIDA - ERRO'
                                ,pr_des_corpo       => 'Houve erro no processamento da planilha.</br>' ||
                                                       'Em anexo a PLANILHA e o LOG de processamento.'  ||
                                                       '</br></br>' ||
                                                       'Processado em: ' || to_char(SYSDATE,'dd/mm/RRRR hh24:mi:ss')
                                ,pr_des_anexo       => vr_dsdanexo
                                ,pr_flg_remove_anex => 'S' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);

  END pc_importar_prova_vida;

END INSS0003;
/
