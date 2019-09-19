CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS544 (pr_cdcooper  IN crapcop.cdcooper%TYPE
                     ,pr_nmdatela  IN craptel.nmdatela%TYPE
                     ,pr_nmtelant  IN craptel.nmdatela%TYPE
                     ,pr_flgresta  IN PLS_INTEGER
                     ,pr_stprogra OUT PLS_INTEGER
                     ,pr_infimsol OUT PLS_INTEGER
                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                     ,pr_dscritic OUT VARCHAR2) AS

/* .............................................................................

   Programa: PC_CRPS544                         Antigo: Fontes/crps544.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme / Supero
   Data    : Dezembro/2009.                      Ultima atualizacao: 09/08/2019

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar arquivos ROC - CECRED

   Alteracoes: 25/05/2010 - Acertos na integracao pelo processo e tela (Ze).

               27/05/2010 - Acertos na integracao do arquivo (Ze).

               16/06/2010 - Preparacao para o COMPEFORA (Ze).

               20/09/2013 - Conversão Progress => Oracle (Gabriel).

               10/10/2013 - Ajuste de criticas (Gabriel).
               
               16/02/2017 - Ajuste ref ao novo layout ROC640 (Rafael).

               16/07/2019 - PJ565 - Insert na TBCOMPE_SUAREMESSA.
                            Rafael Rocha (AmCom)
............................................................................. */

  -- Variaveis de uso no programa
  vr_cdprogra crapprg.cdprogra%TYPE := 'CRPS544';  -- Codigo do presente programa
  vr_nmarqlog         VARCHAR2(100);               -- Nome de arquivo de log
  vr_nmarquiv         VARCHAR2(100);               -- Arquivos do ROC
  vr_idperiod         VARCHAR2(1);                 -- Periodo do arquivo
  vr_dsdireto_integra VARCHAR2(100);               -- Diretorio /integra da cooperativa
  vr_dtleiarq gnfcomp.dtmvtolt%TYPE;               -- Data para a leitura da gnfcomp
  vr_dtauxili         VARCHAR2(50);                -- Data para validacao do arquivo
  vr_cdbanctl         VARCHAR2(10);                -- Codigo do banco
  vr_typ_saida        VARCHAR2(100);               -- Tipo de saida
  vr_des_saida        VARCHAR2(200);               -- Descricao da saida
  vr_gnfcomp          NUMBER(1);                   -- Verificador de registro da tabela gnfcomp
  vr_input_file       utl_file.file_type;          -- Handle para leitura de arquivo
  vr_vet_arquivos     gene0002.typ_split;          -- Array de arquivos
  vr_cdcritic         crapcri.cdcritic%TYPE;       -- Codigo da critica
  vr_dscritic         VARCHAR2(2000);              -- Descricao da critica
  vr_exc_saida        EXCEPTION;                   -- Tratamento de excecao sem parar a cadeia
  vr_exc_fimprg       EXCEPTION;                   -- Tratamento de excecao parando a cadeia
  --/
  vr_qtregrec PLS_INTEGER  :=0;
  vr_vlregrec tbcompe_suaremessa.vlintegr%TYPE;
  vr_qtregrej PLS_INTEGER  :=0;
  vr_vlregrej tbcompe_suaremessa.vlrejeit%TYPE;
  --
  -- Cursor da cooperativa logada
  CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT cop.dsdircop
          ,cop.cdbcoctl
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;

  -- Dados da cooperativa
  rw_crapcop cr_crapcop%ROWTYPE;

  --  Cursor que verifica se ja existe informacoes importadas
  CURSOR cr_gnfcomp (pr_dtleiarq gnfcomp.dtmvtolt%TYPE
                    ,pr_idperiod gnfcomp.cdperarq%TYPE) IS
    SELECT 1
      FROM gnfcomp
     WHERE gnfcomp.cdcooper = pr_cdcooper
       AND gnfcomp.dtmvtolt = pr_dtleiarq
       AND gnfcomp.cdtipfec = 2
       AND gnfcomp.cdperarq = pr_idperiod;

  -- Dados da data da cooperativa logada
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  PROCEDURE mostrar_no_log (pr_cdcooper  IN crapcop.cdcooper%TYPE
                           ,pr_nmarqlog  IN VARCHAR2
                           ,pr_dsinforma IN VARCHAR2
                           ,pr_cdcritic  IN OUT crapcri.cdcritic%TYPE
                           ,pr_dscritic  IN OUT  VARCHAR2) IS

    vr_dsinforma VARCHAR2(200); -- Informacao a ser exibida no log

    BEGIN
      -- Obtem a data
      vr_dsinforma := to_char(sysdate,'hh24:mi:ss') || ' - ';

      -- Se for chamado pela tela PRCCTL, incluir cdcooper
      IF  pr_nmdatela = 'PRCCTL'  THEN
        vr_dsinforma := vr_dsinforma || 'Coop:' || to_char(pr_cdcooper,'00') || ' - Processar: ROC - ';
      END IF;

      -- Incluir codigo do programa e critica
      vr_dsinforma := vr_dsinforma || vr_cdprogra || ' --> ' || pr_dscritic;

      -- Concatenar informacoes adicionais
      IF  pr_dsinforma IS NOT NULL  THEN
        vr_dsinforma := vr_dsinforma || pr_dsinforma;
      END IF;

      -- Gerar critica mas como processo normal
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => vr_dsinforma
                                ,pr_nmarqlog     => pr_nmarqlog);

      -- Limpar variaveis de critica para rodar fimprg.p no Progress
      pr_cdcritic := 0;
      pr_dscritic := '';

  END;

BEGIN

  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                            ,pr_action => NULL);

  -- Obter os dados da cooperativa logada
  OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);

  FETCH cr_crapcop INTO rw_crapcop;

  -- Se cooperativa nao encontrada, gera critica para o log
  IF  cr_crapcop%notfound   THEN

    vr_cdcritic := 651;

    CLOSE cr_crapcop;

    RAISE vr_exc_saida;

  END IF;

  CLOSE cr_crapcop;

  -- Obter dados da data da cooperativa
  OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);

  FETCH btch0001.cr_crapdat INTO rw_crapdat;

  -- Se nao exisitir a data da cooperativa, obter critica e jogar para o log
  IF  btch0001.cr_crapdat%notfound  THEN

    vr_cdcritic := 1;

    CLOSE btch0001.cr_crapdat;

    RAISE vr_exc_saida;

  END IF;

  CLOSE btch0001.cr_crapdat;

  -- Realizar as validacoes do iniprg
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);

  -- Se possui critica, buscar a descricao e jogar ao log
  IF  vr_cdcritic <> 0  THEN

    RAISE vr_exc_saida;

  END IF;

  -- Obter diretorio integra da cooperativa logada
  vr_dsdireto_integra := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => 'integra');

  IF  pr_nmdatela = 'PRCCTL'  THEN

    -- Nome do arquivo de log da PRCCTL
    vr_nmarqlog := 'prcctl_' ||
                   to_char(rw_crapdat.dtmvtolt,'yyyy') ||
                   to_char(rw_crapdat.dtmvtolt,'mm')   ||
                   to_char(rw_crapdat.dtmvtolt,'dd');

    -- Nome do arquivo no diretorio integra
    vr_nmarquiv := vr_dsdireto_integra || '/ROC640D9.'|| ltrim(to_char(rw_crapcop.cdbcoctl,'000'));

    -- Periocidade do arquivo
    vr_idperiod := 'D';

  ELSE

    -- Nome do arquivo null para obter o arquivo padrao na pc_gera_log_batch
    vr_nmarqlog := NULL;

    -- Nome do arquivo no diretorio integra
    vr_nmarquiv := vr_dsdireto_integra || '/ROC640N9.' || ltrim (to_char(rw_crapcop.cdbcoctl,'000'));

    -- Periocidade do arquivo
    vr_idperiod := 'N';

  END IF;

  -- Se a tela anterior foi COMPEFORA, utilizar a data do movimento anterior
  IF  pr_nmtelant = 'COMPEFORA'  THEN

    vr_dtleiarq := rw_crapdat.dtmvtoan;
    vr_dtauxili := to_char(rw_crapdat.dtmvtoan,'yyyy') ||
                   to_char(rw_crapdat.dtmvtoan,'mm')   ||
                   to_char(rw_crapdat.dtmvtoan,'dd');

  ELSE
    -- Senao utilizar a data atual
    vr_dtleiarq := rw_crapdat.dtmvtolt;
    vr_dtauxili := to_char(rw_crapdat.dtmvtolt,'yyyy') ||
                   to_char(rw_crapdat.dtmvtolt,'mm')   ||
                   to_char(rw_crapdat.dtmvtolt,'dd');

  END IF;

  -- Codigo do banco da cooperativa
  vr_cdbanctl := ltrim(to_char(rw_crapcop.cdbcoctl,'000'));

  -- Obter os arquivos do ROC
  gene0001.pc_OScommand_Shell(pr_des_comando =>  'ls ' || vr_nmarquiv || ' 2> /dev/null'
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_des_saida);

  -- Se der erro no comando shell, gerar critica e sair
  IF vr_typ_saida = 'ERR' THEN
    vr_dscritic := 'Erro na leitura dos arquivos ROC.';
    RAISE vr_exc_saida;
  END IF;

  --Separar os arquivos de retorno em um Array
  vr_vet_arquivos := gene0002.fn_quebra_string(pr_string  => vr_des_saida
                                              ,pr_delimit => vr_dsdireto_integra);

  -- Se o Array nao contem pelo menos 02 elementos, gerar critica 182
  IF  NOT vr_vet_arquivos.COUNT > 1  THEN

    vr_cdcritic := 182;

    RAISE vr_exc_fimprg;

  END IF;

  -- Cursor da gnfcomp
  OPEN cr_gnfcomp (pr_dtleiarq => vr_dtleiarq
                  ,pr_idperiod => vr_idperiod);

  FETCH cr_gnfcomp INTO vr_gnfcomp;

  --  Verifica se jah existe informacoes importadas
  IF  cr_gnfcomp%FOUND  THEN

    CLOSE cr_gnfcomp;

    -- Gerar critica de arquivo ja existente
    vr_cdcritic := 459;

    RAISE vr_exc_fimprg;

  END IF;

  CLOSE cr_gnfcomp;

  -- Percorrer os arquivos importados
  FOR vr_pos IN 1..vr_vet_arquivos.COUNT LOOP

    -- Desconsiderar elemento null
    IF  vr_vet_arquivos(vr_pos) IS NULL  THEN
      CONTINUE;
    END IF;

    -- Diretorio + o nome do arquivo
    vr_nmarquiv   := vr_dsdireto_integra || substr(vr_vet_arquivos(vr_pos),1,13);

    -- Verificar se o arquivo esta completo - inicio
    gene0001.pc_OScommand_Shell(pr_des_comando => 'tail -1 ' || vr_nmarquiv || ' 2> /dev/null'
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_des_saida);

    -- Se o comeco da linha nao for 9, criticar
    IF  substr(vr_des_saida,1,1) != '9' THEN

      -- Gerar critica de identificacao invalida
      vr_cdcritic := 887;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      -- Jogar para o log
      mostrar_no_log (pr_cdcooper  => pr_cdcooper
                     ,pr_nmarqlog  => vr_nmarqlog
                     ,pr_dsinforma => vr_nmarquiv
                     ,pr_cdcritic  => vr_cdcritic
                     ,pr_dscritic  => vr_dscritic);

      CONTINUE;

    END IF;

    -- Abrir o arquivo para leitura
    gene0001.pc_abre_arquivo (pr_nmcaminh => vr_nmarquiv    --> Diretório do arquivo
                             ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                             ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                             ,pr_des_erro => vr_dscritic);  --> Descricao do erro

    -- Se retornou erro
    IF  vr_dscritic IS NOT NULL  THEN
      RAISE vr_exc_saida;
    END IF;

    -- Verifica se o arquivo esta aberto
    IF  utl_file.IS_OPEN(vr_input_file) THEN

      DECLARE

        vr_setlinha         VARCHAR2(4000);   -- Texto do arquivo lido
        vr_conta_linha      NUMBER(10);       -- Contador de linhas
        vr_err_nmarquiv     VARCHAR2(100);    -- Arquivos que contem critica
        vr_idregist         NUMBER(10);       -- Identificador do registro
        vr_cdtipdoc         NUMBER(10);       -- Tipo de documento
        vr_salvar_dsdireto  VARCHAR2(100);    -- Diretorio do salvar
        vr_flgcontinua      BOOLEAN;          -- Boolean que identifica se o programa deve continuar

      BEGIN

        -- Zerar contador de linhas
        vr_conta_linha := 0;
        vr_flgcontinua := TRUE;

        -- Loop para leitura do arquivo linha a linha
        LOOP

          -- Le os dados do arquivo e coloca na variavel vr_setlinha
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_setlinha); --> Texto lido

          -- Aumentar o contador de linhas
          vr_conta_linha:= vr_conta_linha + 1;

          -- Se chegou na ultima linha, sair
          EXIT WHEN substr(vr_setlinha,1,1) = '9';

          -- Se estiver no HEADER, fazer as validacoes
          IF  vr_conta_linha = 1  THEN

            IF  substr(vr_setlinha,2,6) != 'ROC640'  THEN     -- Se arquivo nao for ROC640, critica
              vr_cdcritic := 173;
            ELSIF
              substr(vr_setlinha,8,8) != vr_dtauxili  THEN    -- Se nao for a data atual ou anterior dependendo da chamada do programa, criticar
              vr_cdcritic := 013;
            END IF;

            -- Se tem alguma critica
            IF  vr_cdcritic != 0  THEN

              -- Montar o nome do arquivo com erro
              vr_err_nmarquiv := vr_dsdireto_integra || '/err' || substr(vr_vet_arquivos(vr_pos),2,13);

              -- Mover para o integra
              gene0001.pc_OScommand_Shell(pr_des_comando => 'mv ' || vr_nmarquiv || ' ' ||  vr_err_nmarquiv || ' 2> /dev/null'
                                         ,pr_typ_saida   => vr_typ_saida
                                         ,pr_des_saida   => vr_des_saida);

              -- Buscar a descricao da critica
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

              -- Jogar para o log correspondente
              mostrar_no_log (pr_cdcooper  => pr_cdcooper
                             ,pr_nmarqlog  => vr_nmarqlog
                             ,pr_dsinforma => vr_err_nmarquiv
                             ,pr_cdcritic  => vr_cdcritic
                             ,pr_dscritic  => vr_dscritic);

              -- Flag para nao continuar com este arquivo, ir para o proximo
              vr_flgcontinua := FALSE;

              -- Sair do loop de linha a linha
              EXIT;

            END IF;
          ELSE -- Detalhes do arquivo

            -- Obter o identificador do registro
            vr_idregist := to_number (substr(vr_setlinha,1,1));

            -- Obter o tipo de documento
            IF  vr_idregist IN (1,2,3)  THEN

              IF  to_number(substr(vr_setlinha,78,3)) != 0  THEN
                vr_cdtipdoc := to_number(substr(vr_setlinha,78,3));
              END IF;

            ELSE
              vr_cdtipdoc := to_number(substr(vr_setlinha,78,3));
            END IF;

            BEGIN

              -- Criacao da tabela Generica - gnfcomp
              INSERT INTO gnfcomp
                    (cdcooper
                    ,dtmvtolt
                    ,dttrcarq
                    ,nmarquiv
                    ,vlrecdoc
                    ,vlremdoc
                    ,inddcrec
                    ,inddcrem
                    ,qtrecdoc
                    ,qtremdoc
                    ,cdcamorg
                    ,cdperarq
                    ,cdtipdoc
                    ,cdtipfec
                    ,nrseqarq
                    ,idregist)
              VALUES
                    (pr_cdcooper
                    ,vr_dtleiarq
                    ,to_date(substr(vr_setlinha,14,2) || '/'  || substr(vr_setlinha,12,2) || '/' || substr(vr_setlinha,8,4)
                           ,'dd/mm/yyyy')
                    ,vr_nmarquiv
                    ,to_number(substr(vr_setlinha,52,17)) / 100
                    ,to_number(substr(vr_setlinha,26,17)) / 100
                    ,substr(vr_setlinha,69,1)
                    ,substr(vr_setlinha,43,1)
                    ,to_number(substr(vr_setlinha,44,8))
                    ,to_number(substr(vr_setlinha,18,8))
                    ,to_number(nvl(trim(substr(vr_setlinha,5,3)),0))
                    ,vr_idperiod
                    ,vr_cdtipdoc
                    ,2
                    ,to_number(substr(vr_setlinha,95,6))
                    ,vr_idregist);

            -- Tratamento de erro para a insercao na gnfcomp
            EXCEPTION

              WHEN OTHERS THEN

                vr_dscritic := 'Erro na insercao na gnfcomp. ' || sqlerrm;

                RAISE vr_exc_saida;

            END;

          END IF; -- Fim do detalhe do arquivo

        END LOOP; -- Fim da leitura linha a linha do arquivo

        -- Fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;

        -- Nao continuar com este arquivo pois nao passou na validacao.
        IF  NOT vr_flgcontinua  THEN
          CONTINUE;
        END IF;

        -- Obter o diretorio do salvar
        vr_salvar_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                   ,pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsubdir => 'salvar');

        -- Mover para o diretorio salvar
        gene0001.pc_OScommand_Shell(pr_des_comando => 'mv ' || vr_nmarquiv || ' ' || vr_salvar_dsdireto || substr(vr_vet_arquivos(vr_pos),1,13) || '-' ||  vr_dtauxili );

        vr_cdcritic := 0;
        vr_dscritic := '';

        -- Mostrar no log que foi integrado com sucesso
        IF  pr_nmdatela = 'PRCCTL'   THEN
          mostrar_no_log (pr_cdcooper  => pr_cdcooper
                         ,pr_nmarqlog  => vr_nmarqlog
                         ,pr_dsinforma => '- Arquivo salvar' || substr(vr_vet_arquivos(vr_pos),1,13) || ' processado com sucesso !'
                         ,pr_cdcritic  => vr_cdcritic
                         ,pr_dscritic  => vr_dscritic);
        ELSE
          mostrar_no_log (pr_cdcooper  => pr_cdcooper
                         ,pr_nmarqlog  => vr_nmarqlog
                         ,pr_dsinforma => 'Arquivo ROC integrado com sucesso!'
                         ,pr_cdcritic  => vr_cdcritic
                         ,pr_dscritic  => vr_dscritic);
        END IF;

      -- Tratamento de erro para a importacao dos arquivos ROC
      EXCEPTION

        WHEN OTHERS THEN

          -- Erro na importacao, concatenar o sqlerrm
          vr_dscritic := 'Erro na importacao do arquivo. ' ||  substr(vr_vet_arquivos(vr_pos),1,13) || ' ' || sqlerrm;

          RAISE vr_exc_saida;

      END; -- Fim da leitura do arquivo do ROC

    END IF; -- Fim da verificação se o arquivo esta aberto

      -- pj565
      BEGIN
        --/
        SELECT SUM(vlrecdoc) ,
               SUM(a.qtrecdoc) 
          INTO vr_qtregrec,
               vr_vlregrec
          FROM gnfcomp a 
         WHERE a.cdcooper = pr_cdcooper 
           AND a.dtmvtolt = vr_dtleiarq
           AND cdtipdoc IN (40, 140);
            
          INSERT INTO tbcompe_suaremessa
              (cdcooper,
               tparquiv,
               dtarquiv,
               qtrecebd,
               vlrecebd,
               nmarqrec)
          VALUES
              (pr_cdcooper,
               4,
               trunc(sysdate),
               vr_qtregrec,
               vr_vlregrec,
               vr_vet_arquivos(vr_pos));
          --/
          EXCEPTION
             WHEN DUP_VAL_ON_INDEX THEN
                NULL;
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
        vr_dscritic := 'Erro ao inserir na tabela tbcompe_suaremessa, Rotina pc_crps533.pc_integra_todas_coop. '||sqlerrm;
        RAISE vr_exc_saida;
      END;
 
  END LOOP; -- Fim da leitura de todos os arquivos

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  COMMIT;

EXCEPTION

  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    END IF;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;

  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
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

END PC_CRPS544;
/
