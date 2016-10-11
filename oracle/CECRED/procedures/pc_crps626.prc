create or replace procedure cecred.pc_crps626 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

/* .............................................................................

   Programa: Fontes/crps626.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : André Santos/Supero
   Data    : Agosto/2012                   Ultima atualizacao: 05/08/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar arquivos TIC - Recebe arquivo TIC616

   Alteracoes: 25/10/2012 - Desconsiderar algumas criticas (Ze).

               10/10/2013 - Incluido tratamento craprej.cdcritic = 12,
                            ref. FDR 43/2013 (Diego).

               14/01/2014 - Alteracao referente a integracao Progress X
                            Dataserver Oracle
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)

              05/08/2014 - Alteraçao da Nomeclatura para PA (Vanessa).
............................................................................. */
-- Definição do tipo da PL Table para a tabela CRAPFER
    TYPE typ_reg_crapfer IS
      RECORD(registro PLS_INTEGER);
    TYPE typ_tab_crapfer IS TABLE OF typ_reg_crapfer INDEX BY VARCHAR2(11);

-- Type para armazenar nome dos arquivos para processamento
    TYPE typ_tab_nmarqtel IS
      TABLE OF VARCHAR2(100)
      INDEX BY BINARY_INTEGER;
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS626';

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;
    vr_exc_final     EXCEPTION;
    vr_exc_erro      EXCEPTION;
    vr_exc_fimprg    EXCEPTION;
    vr_cdcritic      PLS_INTEGER;
    vr_dscritic      VARCHAR2(4000);
    vr_input_file    UTL_FILE.file_type;
    vr_setlinha      varchar2(500);
    vr_cdempres      number;
    ie               number;
    vr_nrdocmto      number;
    vr_nrseqarq      number;
    vr_cdbanchq      number;
    vr_cdcmpchq      number;
    vr_cdagechq      number;
    vr_nrctachq      craplcm.nrctachq%type;
    vr_cdocorre      number;
    vr_flocotic      boolean;
    vr_cdocotic      number;
    vr_cdpesqbb      varchar2(500);
    tot_qtregrej     number;
    vr_cdrelato      number;
    vr_tot_qtregrej  number;
    vr_nmarqimp      varchar2(100);
    vr_rel_dspesqbb  VARCHAR2(100);
    ------------------------------- CURSORES ---------------------------------
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.cdagectl
            ,cop.cdbcoctl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;


    cursor CR_CRAPCST(pr_cdcooper CRAPCST.Cdcooper%type,
                      vr_cdcmpchq CRAPCST.Cdcmpchq%type,
                      vr_cdbanchq CRAPCST.Cdbanchq%type,
                      vr_cdagechq CRAPCST.Cdagechq%type,
                      vr_nrctachq CRAPCST.Nrctachq%type,
                      vr_nrdocmto CRAPCST.Nrdocmto%type)is
   select * from crapcst
     WHERE
      crapcst.cdcooper = pr_cdcooper  AND
      crapcst.cdcmpchq = vr_cdcmpchq  AND /* Nro compe */
      crapcst.cdbanchq = vr_cdbanchq  AND /* Nro do Bco*/
      crapcst.cdagechq = vr_cdagechq  AND /* Age dest  */
      crapcst.nrctachq = vr_nrctachq  AND /* Nr ctachq */
      crapcst.nrcheque = vr_nrdocmto;     /* Nro chq   */

   RW_CRAPCST CR_CRAPCST%ROWTYPE;

   cursor  CR_CRAPCDB(pr_cdcooper crapcdb.Cdcooper%type,
                      vr_cdcmpchq crapcdb.Cdcmpchq%type,
                      vr_cdbanchq crapcdb.Cdbanchq%type,
                      vr_cdagechq crapcdb.Cdagechq%type,
                      vr_nrctachq crapcdb.Nrctachq%type,
                      vr_nrdocmto crapcdb.Nrdocmto%type)is
   select * from crapcdb
     WHERE
      crapcdb.cdcooper = pr_cdcooper AND
      crapcdb.cdcmpchq = vr_cdcmpchq AND /* Nro compe  */
      crapcdb.cdbanchq = vr_cdbanchq AND /* Nro do Bco */
      crapcdb.cdagechq = vr_cdagechq AND /* Agen dest  */
      crapcdb.nrctachq = vr_nrctachq AND /* Nro ctachq */
      crapcdb.nrcheque = vr_nrdocmto;     /* Nro chq    */

    RW_crapcdb CR_crapcdb%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_nom_direto  VARCHAR2(100);
    --Arquivo a ser importado
    vr_nmarquiv VARCHAR2(500);

     --------------------------- VARIAVEIS DO CORPO DO PROGRAMA----------------
     aux_dtmvtolt       DATE;
     vr_dtauxili        VARCHAR(10);
     vr_refer           varchar(10);
     aux_mes            VARCHAR2(2);
     vr_flgrejei        BOOLEAN;
     vr_nmarqret        VARCHAR2(100);
     vr_qtcompln        NUMBER(8,2);
     vr_vlcompdb        NUMBER(8,2);
     vr_tab_nmarqtel    typ_tab_nmarqtel;
     vr_dtlimite        Date;

     vr_tab_crapfer typ_tab_crapfer;              --> PL Table de valores da tabela CRAPFER

     vr_contador number;
     vr_caminho_integra     VARCHAR2(1000);
     vr_comando             VARCHAR2(1000);
     vr_typ_saida           VARCHAR2(1000);

    --------------------------- SUBROTINAS INTERNAS --------------------------
   	    --Procedure que escreve linha no arquivo CLOB
	    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;


    FUNCTION fn_calc_prox_dia_util(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                  ,pr_data     IN DATE                  --> Data para cálculo do próximo dia útil
                                  ,pr_datautl  IN DATE) RETURN DATE IS  --> Data para comparação da situação atual
     BEGIN
      DECLARE
         tmp_dtrefere   DATE := pr_data + 1;       --> Ultimo dia util antes de ontem

       BEGIN
         LOOP
          -- Verifica se a data selecionada é segunda-feira ou domingo
          IF to_char(tmp_dtrefere, 'D') = 7 OR to_char(tmp_dtrefere, 'D') = 1 THEN
            tmp_dtrefere := tmp_dtrefere + 1;
            continue;
          END IF;

          -- Verifica se a data existe na tabela de feriados
          IF vr_tab_crapfer.exists(to_char(tmp_dtrefere, 'DDMMRRRR') || lpad(pr_cdcooper, 3, '0')) THEN
            tmp_dtrefere := tmp_dtrefere + 1;
            continue;
          END IF;

          -- Compara datas de atuação
          IF tmp_dtrefere = pr_datautl THEN
            tmp_dtrefere := tmp_dtrefere + 1;
          END IF;

          -- Condição de saída do LOOP
          EXIT;
        END LOOP;

        RETURN tmp_dtrefere;
      END;
    END fn_calc_prox_dia_util;



   begin
   ie := 0;
    --------------- VALIDACOES INICIAIS -----------------
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
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
    rw_crapdat.dtmvtopr := '04/20/2016';

    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF nvl(vr_cdcritic,0) <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;
--------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      --no programa original (PROGRESS) existia um parametro glb_nmtelant
      --que se fosse COMPEFORA pegava dtmvtoan mais na conversao passa a
      --pegar somente dtmvtolt
      vr_dtauxili := to_char(to_date(rw_crapdat.dtmvtolt,'dd/mm/rrrr'),'rrrrmmdd');
      vr_refer    := to_char(to_date(to_char(to_date(rw_crapdat.dtmvtolt,'dd/mm/rrrr'),'rrrrmmdd'),'rrrr/dd/mm'),'dd/mm/rrrr');
     --  to_char(to_date(rw_crapdat.dtmvtolt,'dd/mm/rrrr'),'dd/mm/rrrr');

      IF  EXTRACT(MONTH FROM rw_crapdat.dtmvtolt) > 9 THEN
      	 CASE
           EXTRACT(MONTH FROM rw_crapdat.dtmvtolt)
            WHEN 10 THEN aux_mes := 'O';
            WHEN 11 THEN aux_mes := 'N';
            WHEN 12 THEN aux_mes := 'D';
         END CASE;
      ELSE
         aux_mes := TO_CHAR(EXTRACT(MONTH FROM rw_crapdat.dtmvtolt));
      END IF;

      /* Nome do arq de origem*/
      vr_nmarquiv :=trim( '1' || lpad(rw_crapcop.cdagectl,4,'0') ||
                      aux_mes || lpad(EXTRACT (DAY FROM rw_crapdat.dtmvtolt),2,'0') || '.CND');
      vr_contador := 0;
      vr_nmarqret:= '39999%.RET'; /* Sua REMESSA e erros enviados */

       -- Buscar o diretorio padrao da cooperativa conectada
       vr_caminho_integra:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsubdir => 'integra');

       -- Comando para remover arquivos no diretorio integracao
       vr_comando:= 'rm '||vr_caminho_integra||'/'||vr_nmarquiv ||'.q 2> /dev/null';

       -- Remove os arquivos ".q" caso existam
       gene0001.pc_OScommand_Shell(pr_des_comando =>  vr_comando
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_dscritic);

         -- Se retornar uma indicação de erro
        IF NVL(vr_typ_saida,' ') = 'ERR' THEN
          -- Incluir erro no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2  -- Erro tratado
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || 'Erro pc_OScommand_Shell: '||vr_dscritic);
        END IF;
        /* Listar o nome do arquivo caso exista*/
        vr_comando:= 'ls '||vr_caminho_integra||'/'||vr_nmarquiv ||' 2> /dev/null';

        gene0001.pc_OScommand_Shell(pr_des_comando =>  vr_comando
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_dscritic);

        if  nvl(vr_typ_saida,' ') <> 'ERR' then

           vr_comando:= 'quoter '||vr_caminho_integra||'/'||vr_nmarquiv || ' > '||vr_caminho_integra||'/'||vr_nmarquiv ||'.q 2> /dev/null';
           gene0001.pc_OScommand_Shell(pr_des_comando =>  vr_comando
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_dscritic);
          /* Gravando a qtd de arquivos processados */
          vr_contador               := vr_contador + 1;
          vr_tab_nmarqtel(vr_contador) := vr_nmarquiv;

        end if;
         /* Se nao houver arquivos processados */
         IF vr_contador = 0 THEN
          -- Montar mensagem de critica
           vr_cdcritic:= 182;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '||vr_dscritic
                                                       || ' - Arquivo: integra/'||vr_nmarqret );
           --Levantar Excecao pois nao tem arquivo para processar
           RAISE vr_exc_final;
         END IF;
         /*  Fim da verificacao se deve executar  */
       begin
          delete craprej WHERE craprej.cdcooper = pr_cdcooper;
        exception
          when NO_DATA_FOUND then
            vr_dscritic := 'Limpeza da Tabela Craprej - Não funcionou ';
            -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '||vr_dscritic
                                                       || ' - Arquivo: integra/'||vr_nmarqret );
         WHEN OTHERS THEN
        vr_dscritic := 'Limpeza da Tabela Craprej  -'|| SQLERRM;
            -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '||vr_dscritic
                                                       || ' - Arquivo: integra/'||vr_nmarqret );



       end;
      /* Variavel de contador trouxe arquivos */
     FOR I IN 1..vr_contador LOOP

       vr_flgrejei := false;
       vr_qtcompln := 0;
       vr_vlcompdb := 0;
         --Abre o arquivo
       gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho_integra  --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_nmarquiv         --> Nome do arquivo
                              ,pr_tipabert => 'R'                 --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file       --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);       --> Erro
       IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
       END IF;
       --Verifica se o arquivo esta aberto

       IF  utl_file.IS_OPEN(vr_input_file) THEN
         -- Le os dados em pedacos insere na vr_setlinha
         gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                     ,pr_des_text => vr_setlinha); --> Texto lido
         --Incrementar contador
         vr_contador:= Nvl(vr_contador,0) + 1;

         --Separar o nome do arquivo do caminho
         GENE0001.pc_separa_arquivo_path(pr_caminho => vr_nmarquiv
                                        ,pr_direto  => vr_caminho_integra
                                        ,pr_arquivo => vr_nmarquiv);

       --Popular o vetor de arquivos
       IF SUBSTR(vr_setlinha,1,10) <> '0000000000'  THEN /* Const = 0 */
         vr_cdcritic := 468;
       ELSIF SUBSTR(vr_setlinha,48,6) <> 'TIC616' THEN  /* Const = 'TIC616' */
         vr_cdcritic := 173;
       ELSIF to_number(SUBSTR(vr_setlinha,61,3)) <> rw_crapcop.cdbcoctl THEN /* Nr cd bco */
         vr_cdcritic := 057;
       ELSIF SUBSTR(vr_setlinha,66,8) <> vr_dtauxili THEN
         vr_cdcritic := 013;

       IF (vr_cdcritic <> 0) THEN
          -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '||vr_dscritic
                                                       || ' - Arquivo: integra/'||vr_nmarqret );

       vr_cdcritic := 0;

        end if;
     end if;
     IF vr_dscritic is null then
      LOOP
        vr_setlinha := null;
         begin
           gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                       ,pr_des_text => vr_setlinha); --> Texto lido
         exception
            -- se apresentou erro de no_data_found é pq chegou no final do arquivo, fechar arquivo e sair do loop
               WHEN NO_DATA_FOUND THEN
                -- fechar arquivo
               gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
               EXIT;
        end;
           -- verificação de cabeçalho e rodapé
           if (SUBSTR(vr_setlinha,1,10) <> '9999999999'
           and SUBSTR(vr_setlinha,29,10) <> '9999900000') THEN
              vr_nrdocmto := to_number(SUBSTR(vr_setlinha,25,6));
              vr_nrseqarq := to_number(SUBSTR(vr_setlinha,151,10));
              vr_cdbanchq := to_number(SUBSTR(vr_setlinha,4,3));
              vr_cdcmpchq := to_number(SUBSTR(vr_setlinha,1,3));
              vr_cdagechq := to_number(SUBSTR(vr_setlinha,7,4));
              vr_nrctachq := to_number(SUBSTR(vr_setlinha,12,12));
              vr_cdocorre := to_number(SUBSTR(vr_setlinha,139,2));
              vr_cdpesqbb := vr_setlinha;
              /* Ocorrencia */
              IF  vr_cdocorre not in (01,02,03,04,05,08,09)  THEN

                 OPEN CR_CRAPCST(pr_cdcooper,
                                 vr_cdcmpchq,
                                 vr_cdbanchq,
                                 vr_cdagechq,
                                 vr_nrctachq,
                                 vr_nrdocmto);
                 FETCH CR_CRAPCST
                 INTO RW_CRAPCST;
                 -- Se não encontrar
                 IF CR_CRAPCST%NOTFOUND THEN
                 -- Fechar o cursor pois haverá raise
                    vr_qtcompln := vr_qtcompln + 1;
                    CLOSE CR_CRAPCST;
                 ELSE
                   IF vr_cdocorre <> 0 THEN
                      vr_flocotic := TRUE;
                      vr_cdocotic := vr_cdocorre;
                         INSERT INTO craprej (
                         cdcooper,
                         nrdconta,
                         dtdaviso,
                         dtmvtolt,
                         nrdctitg,
                         nrdocmto,
                         vllanmto,
                         nrseqdig,
                         cdpesqbb,
                         dshistor,
                         cdcritic)
                         VALUES
                         (pr_cdcooper,
                          rw_crapcst.nrdconta,
                          rw_crapcst.dtlibera,
                          rw_crapcst.dtmvtolt,
                          LPAD(vr_nrctachq,10,'0'),
                          vr_nrdocmto, /* Nro Docmto */
                          rw_crapcst.vlcheque,
                          vr_nrseqarq, /*  seq  arq  */
                          vr_cdpesqbb,
                          to_char(RW_CRAPCST.cdagenci,'fm000') || ' ' ||to_char(RW_CRAPCST.cdbccxlt,'fm000') || ' ' ||
                          to_char(RW_CRAPCST.nrdolote,'fm0000') ,
                          vr_cdocorre);
                   end if;
                 -- Apenas fechar o cursor
                  CLOSE CR_CRAPCST;
                 END IF;

                OPEN cr_crapcdb(pr_cdcooper,
                                 vr_cdcmpchq,
                                 vr_cdbanchq,
                                 vr_cdagechq,
                                 vr_nrctachq,
                                 vr_nrdocmto);
                 FETCH cr_crapcdb
                 INTO rw_crapcdb;
                 -- Se não encontrar
                 IF CR_crapcdb%NOTFOUND THEN
                 -- Fechar o cursor pois haverá raise
                    vr_qtcompln := vr_qtcompln + 1;
                    CLOSE CR_crapcdb;
                 ELSE
                   IF vr_cdocorre <> 0 THEN
                      vr_flocotic := TRUE;
                      vr_cdocotic := vr_cdocorre;
                         insert into craprej(
                               craprej.cdcooper,
                               craprej.nrdconta,
                               craprej.dtdaviso,
                               craprej.dtmvtolt,
                               craprej.nrdctitg,
                               craprej.nrdocmto,
                               craprej.vllanmto,
                               craprej.nrseqdig,
                               craprej.cdpesqbb,
                               craprej.dshistor,
                               craprej.cdcritic)
                               values
                               (pr_cdcooper,
                                rw_crapcdb.nrdconta,
                                rw_crapcdb.dtlibera,
                                rw_crapcdb.dtmvtolt,
                                LPAD(vr_nrctachq,10,'0'),
                                vr_nrdocmto /* Nro Docmto */,
                                rw_crapcdb.vlcheque,
                                vr_nrseqarq, /* seq arq */
                                vr_cdpesqbb,
                                to_char(RW_crapcdb.cdagenci,'fm000') || ' ' ||to_char(RW_crapcdb.cdbccxlt,'fm000') || ' ' ||
                                to_char(RW_crapcdb.nrdolote,'fm0000'),
                                vr_cdocorre);
                   end if;
                 -- Apenas fechar o cursor
                  CLOSE CR_crapcdb;
                 END IF;
              end if;
           end if;
        IE := iE + 1;
      END LOOP;
     end if;
     END IF;

    -- Comando para remover arquivos no diretorio integracao
       vr_comando:= 'mv '||vr_caminho_integra||'/'||vr_nmarquiv ||' salvar';
       gene0001.pc_OScommand_Shell(pr_des_comando =>  vr_comando
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_dscritic);
       IF NVL(vr_typ_saida,' ') = 'ERR' THEN
          -- Incluir erro no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2  -- Erro tratado
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || 'Erro pc_OScommand_Shell: '||vr_dscritic);
        END IF;



       vr_comando:= 'rm '||vr_caminho_integra||'/'||vr_nmarquiv ||'.q 2> /dev/null';
       gene0001.pc_OScommand_Shell(pr_des_comando =>  vr_comando
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_dscritic);

       IF NVL(vr_typ_saida,' ') = 'ERR' THEN
          -- Incluir erro no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2  -- Erro tratado
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || 'Erro pc_OScommand_Shell: '||vr_dscritic);
       END IF;

           tot_qtregrej := 0;
           vr_cdcritic := 0;
           vr_cdrelato := 626;

        /** Geração Relatorio crrl626 **/
        -- Inicializar o CLOB
        vr_des_xml := NULL;
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        -- Inicilizar as informações do XML
        vr_texto_completo := NULL;
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl626>');

        vr_nmarqimp := 'rl/crrl626' ||trim(to_char(i,'99')) ||  '.lst';
        vr_cdempres := 11;

        /* Considerar somente a data de liberacao superior a D+2, pelo motivo
        da compensacao da ABBC */
        vr_dtlimite :=  fn_calc_prox_dia_util(pr_cdcooper => pr_cdcooper
                                             ,pr_data     => rw_crapdat.dtmvtopr + 1
                                             ,pr_datautl  => sysdate);
        for rw_craprej in (select craprej.rowid,  craprej.* from craprej
                            where
                            craprej.cdcooper = pr_cdcooper AND
                            craprej.dtdaviso > vr_dtlimite) loop

             vr_flgrejei := TRUE;
             --Codigo da critica
             vr_cdcritic:= rw_craprej.cdcritic;
             --Incrementar qdade e valor rejeitado
             vr_tot_qtregrej:= nvl(vr_tot_qtregrej,0) + 1;
             --Montar Linha Pesquisa
             vr_rel_dspesqbb:= SUBSTR(rw_craprej.cdpesqbb,1,3) || ' ' ||
                               SUBSTR(rw_craprej.cdpesqbb,4,3)  || ' ' ||
                               SUBSTR(rw_craprej.cdpesqbb,7,4);

             CASE rw_craprej.Cdcritic
             WHEN 1 THEN vr_dscritic   := 'Conta Encerrada';
             WHEN 2 THEN vr_dscritic   := 'Cheque cancelado pelo cliente';
             WHEN 3 THEN  vr_dscritic  := 'Cheque cancelado pelo Banco sacado';
             WHEN 4 THEN  vr_dscritic  := 'Cheque furtado/roubado';
             WHEN 5 THEN  vr_dscritic  := 'Cheque malote roubado';
             WHEN 6 THEN  vr_dscritic  := 'Registro inconsistente';
             WHEN 7 THEN  vr_dscritic  := 'Cheque já custodiado por outra IF';
             WHEN 8 THEN  vr_dscritic  := 'Registro duplicado pelo mesma IF';
             WHEN 9 THEN  vr_dscritic  := 'Registro para exclusao inexistente';
             WHEN 10 THEN  vr_dscritic := 'Cheque liquidado anteriormente';
             WHEN 11 THEN  vr_dscritic := 'Cheque inexistente';
             WHEN 12 THEN  vr_dscritic := 'Registro efetuado por outra IF nesta data';
        END CASE;

          pc_escreve_xml('<rejeitados>
                          <reldspesqbb>'|| vr_rel_dspesqbb                            ||'</reldspesqbb>
                          <nrdctitg>'   ||TRIM(gene0002.fn_mask(to_number(substr(rw_craprej.nrdctitg,0,9)),'zzz.zzz.zzz'))||'</nrdctitg>
                          <nrdocmto>'   ||TRIM(gene0002.fn_mask(rw_craprej.nrdocmto,'zz.zzz.zzz'))||'</nrdocmto>
                          <vllanc>  '   || to_char(rw_craprej.vllanmto,'fm999G999G999G999G990d00')||'</vllanc>
                          <dtdaviso>'   || to_char(rw_craprej.dtdaviso,'DD/MM/RR')  ||'</dtdaviso>
                          <dtmvtolt>'   || to_char(rw_craprej.dtmvtolt,'DD/MM/RR')  ||'</dtmvtolt>
                          <nrdconta>'   ||GENE0002.FN_MASK_CONTA(rw_craprej.nrdconta) ||'</nrdconta>
                          <dshistor>'   || SUBSTR(rw_craprej.dshistor,0,7)            ||'</dshistor>
                          <nrdolote>'   || SUBSTR(rw_craprej.dshistor,9)              ||'</nrdolote>
                          <dscritic>'   || vr_dscritic                                ||'</dscritic>
                          <dtrefer> '   || vr_refer                                   ||'</dtrefer>
                          <nmarquiv>'   || 'integra/'||vr_nmarquiv                    ||'</nmarquiv>
                      </rejeitados>');



           END LOOP;
           pc_escreve_xml('<total>'||'<tot_qtregrej>'|| vr_tot_qtregrej  ||'</tot_qtregrej>'||'</total>');
           pc_escreve_xml('</crrl626>');

           ----------------- gerar relatório -----------------
           -- Busca do diretório base da cooperativa para PDF
           vr_caminho_integra := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                      ,pr_cdcooper => pr_cdcooper
                                	                    ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

         -- Efetuar solicitação de geração de relatório --

            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                 	                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                      ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                      ,pr_dsxmlnode => '/crrl626/rejeitados'    --> Nó base do XML para leitura dos dados
                                      ,pr_dsjasper  => 'crrl626.jasper'    --> Arquivo de layout do iReport
                                      ,pr_dsparams  => NULL                --> Sem parametros
                                      ,pr_dsarqsaid => vr_caminho_integra||'/crrl626.lst' --> Arquivo final com código da agência
                                      ,pr_qtcoluna  => 132                 --> 132 colunas
                                      ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                      ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                      ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                      ,pr_nrcopias  => 1                   --> Número de cópias
                                      ,pr_flg_gerar => 'S'                 --> gerar PDF
                                       ,pr_des_erro  => vr_dscritic);       --> Saída com erro


 -- Testar se houve erro
    IF vr_dscritic IS NOT NULL THEN
      -- Gerar exceção
      RAISE vr_exc_saida;
    END IF;
     -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

    -- limpar rejeitados
    BEGIN
      DELETE craprej
       WHERE craprej.cdcooper = pr_cdcooper;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possivel deletar craprej: '||SQLERRM;
        RAISE vr_exc_saida;
    END;

 end loop;

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informações atualizadas
    COMMIT;

  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;

end;
/
