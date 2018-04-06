CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS540" (pr_cdcooper  IN craptab.cdcooper%TYPE
                                      ,pr_cdoperad  IN gncpdev.cdoperad%TYPE
                                      ,pr_nmtelant  IN VARCHAR2 DEFAULT NULL
                                      ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT VARCHAR2)  IS

/* .............................................................................

   Programa: PC_CRPS540           Antigo: Fontes/crps540.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/SUPERO
   Data    : Dezembro/2009.                      Ultima atualizacao: 04/01/2018

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar arquivos de DEVOLUCAO de CHEQUES da SR - Conciliacao.

   Alteracoes: 04/06/2010 - Acertos Gerais (Ze).

               16/06/2010 - Inclusao do campo gncptit.dtliquid (Ze).

               07/07/2010 - Incluso Validacao para COMPEFORA e Acertos na
                            Alinea (Jonatas/Supero e Ze)

               23/08/2010 - Acerto no registro de controle (Ze).

               02/09/2010 - Acerto no campo nrdconta (Vitor/Ze).

               13/09/2010 - Acerto p/ gerar relatorio no diretorio rlnsv
                            (Vitor)

               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop
                            na leitura e gravacao dos arquivos (Elton).

               15/08/2012 - Alterado posigues do gncpdev.cdtipdoc de 52,2
                            para 148,3 (Lucas R.).

               17/08/2012 - Tratamento para cheques VLB (Fabricio).

               17/01/2013 - FIND na gncpdev com cdcooper = craptco.cdcooper,
                            para cheques de contas migradas. (Fabricio)

               29/08/2013 - Conversão Progress >> Oracle PL/SQL (Renato - Supero).

               24/10/2013 - Copiar relatorio para o diretorio rlnsv quando a tela
                            for a COMPEFORA (Douglas Pagel).

               14/11/2013 - Alterar a chamada da lista_arquivos passando um filtro
                            para não trazer todos os arquivos da pasta Integra;
                          - Também alterado o formato do XML para que os registros
                            de rejeitados sejam gerados em um subrelatório e não
                            mais no principal, pois estávamos com problemas quando
                            não havia nenhum rejeitado. (Marcos-Supero)

               25/11/2013 - Limpar parametros de saida de critica no caso da
                            exceção vr_exc_fimprg (Marcos-Supero)

               05/12/2013 - Implementar nova metodologia de listagem de arquivos (Petter - Supero).

               17/09/2014 - Incluso tratamento para incorporação cooperativa (Daniel)
			   
			   13/10/2016 - Alterada leitura da tabela de parâmetros para utilização
							da rotina padrão. (Rodrigo)

               02/12/2016 - Incorporação Transulcred (Guilherme/SUPERO)

			   29/05/2017 - Incluso filtro para buscar apenas arquivos .DV% (Daniel)

         07/07/2017 - Incluido pc_internal_exception para verificacao de 
                      possiveis erros (Tiago/Rodrigo #681226)

               04/01/2018 - Ajustado para gravar o numero da conta do cooperado na craprej,
                            para gerar corretamente o relatório, além disso foi alterada a 
                            máscara do número do cheque (Chamado 821877)
............................................................................. */

  -- CURSORES
  -- Buscar informações da cooperativa
  CURSOR cr_crapcop IS
    SELECT crapcop.dsdircop
         , LPAD(crapcop.cdbcoctl,3,0) cdbcoctl
         , to_char(crapcop.cdagectl,'FM0000') cdagectl
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;

    -- Buscar informações da cooperativa
  CURSOR cr_crabcop(pr_cdcopant craptco.cdcopant%TYPE) IS
    SELECT crapcop.dsdircop
         , LPAD(crapcop.cdbcoctl,3,0) cdbcoctl
         , to_char(crapcop.cdagectl,'FM0000') cdagectl
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcopant;

  -- Buscar compensação de cheque devolvido
  CURSOR cr_gncpdev(pr_cdcooper    gncpdev.cdcooper%TYPE
                   ,pr_dtmvtolt    gncpdev.dtmvtolt%TYPE
                   ,pr_cdbanchq    gncpdev.cdbanchq%TYPE
                   ,pr_cdagechq    gncpdev.cdagechq%TYPE
                   ,pr_nrctachq    gncpdev.nrctachq%TYPE
                   ,pr_nrcheque    gncpdev.nrcheque%TYPE ) IS
    SELECT gncpdev.rowid    gncpdev_rowid
         , gncpdev.cdtipreg
      FROM gncpdev
     WHERE gncpdev.cdcooper = pr_cdcooper
       AND gncpdev.dtmvtolt = pr_dtmvtolt
       AND gncpdev.cdbanchq = pr_cdbanchq
       AND gncpdev.cdagechq = pr_cdagechq
       AND gncpdev.nrctachq = pr_nrctachq
       AND gncpdev.nrcheque = pr_nrcheque
     ORDER BY gncpdev.progress_recid DESC;

  -- Buscar por conta transferida entre cooperativas
  CURSOR cr_craptco(pr_nrctaant   craptco.nrctaant%TYPE) IS
    SELECT craptco.cdcooper
         , craptco.nrctaant
      FROM craptco
     WHERE craptco.cdcopant = pr_cdcooper
       AND craptco.nrctaant = pr_nrctaant
       AND craptco.flgativo = 1 -- TRUE
       AND craptco.tpctatrf = 1;

  -- Buscar por conta transferida entre cooperativas buffer
  CURSOR cr_crabtco(pr_nrctaant   craptco.nrctaant%TYPE) IS
    SELECT craptco.cdcooper
         , craptco.nrctaant
         , craptco.nrdconta
      FROM craptco
     WHERE craptco.cdcooper = pr_cdcooper
       AND craptco.nrctaant = pr_nrctaant
       AND craptco.flgativo = 1 -- TRUE
       AND craptco.tpctatrf = 1;

  -- REGISTROS
  rw_crapcop       cr_crapcop%ROWTYPE;
  rw_gncpdev       cr_gncpdev%ROWTYPE;
  rw_craptco       cr_craptco%ROWTYPE;
  rw_crabcop       cr_crabcop%ROWTYPE;
  rw_crabtco       cr_crabtco%ROWTYPE;

  -- TIPO
  TYPE typ_diretorio IS RECORD (idarquivo     NUMBER  -- 1 = DVD; 2 = DVT; 3 = DVS;
                               ,nmarquivo     VARCHAR2(200)
                               ,cdperdev      NUMBER);
  TYPE typ_tabarq  IS TABLE OF typ_diretorio INDEX BY BINARY_INTEGER;
  TYPE typ_arquivo IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

  -- VARIÁVEIS
  -- Código do programa
  vr_cdprogra      VARCHAR2(10);
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;
  vr_dtmvtoan      crapdat.dtmvtoan%TYPE;
  vr_dtmvtaux      crapdat.dtmvtolt%TYPE;
  -- Contadores
  vr_qttotreg      NUMBER := 0;
  -- Variável de erros
  vr_des_erro      VARCHAR2(4000);
  -- Diretórios
  vr_diretori      VARCHAR2(200);
  vr_nom_direto    VARCHAR2(200);
  vr_dircop_rlnsv  VARCHAR2(200);
  -- Registros de arquivos
  vr_arqdvd        typ_tabarq;
  vr_arqdvt        typ_tabarq;
  vr_arqdvs        typ_tabarq;
  vr_arquivos      typ_tabarq;
  vr_array_arquivo GENE0002.typ_split;
  vr_file          typ_arquivo;
  -- Arquivo lido
  vr_utlfileh      UTL_FILE.file_type;
  -- Índice para a linha do arquivo
  vr_nrlinha       NUMBER;
  -- Indica se encontrou o registro na GNCPDEV
  vr_idgncpdev     BOOLEAN;
  -- Variável auxiliar para guardar o código da cooperativa
  -- quando ocorre uma transferencia de conta
  vr_auxcooper     NUMBER;
  -- Sequencial para os relatórios
  vr_qtdrelat      NUMBER := 0;
  -- Validação de erros
  vr_typ_saida     VARCHAR2(100);
  vr_des_saida     VARCHAR2(2000);

  -- Tratamento de erros
  vr_exc_saida     EXCEPTION;
  vr_exc_fimprg    EXCEPTION;

  vr_listarq       VARCHAR2(32767);

  -- Variável auxiliar para guardar o código da cooperativa
  -- quando ocorre uma incorporação de cooperativa
  vr_cdcooper       NUMBER;
  vr_nrdconta       NUMBER;
  vr_dstextab       craptab.dstextab%TYPE;

BEGIN

  -- Código do programa
  vr_cdprogra := 'CRPS540';

  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CPRS540',
                             pr_action => vr_cdprogra);

  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => pr_cdcritic);

  -- Se retornou algum erro
  IF pr_cdcritic <> 0 THEN
    -- Buscar descricão do erro
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  -- Buscar os dados da cooperativa
  OPEN  cr_crapcop;
  FETCH cr_crapcop INTO rw_crapcop;

  -- Tratamento para buscar dados cooperativa incorporada
  IF pr_cdcooper IN (1,9,13) THEN

    CASE pr_cdcooper
      WHEN 1   THEN vr_cdcooper := 4;  --    VIACREDI --> CONCREDI
      WHEN 13  THEN vr_cdcooper := 15; --     SCRCRED --> CREDIMILSUL
      WHEN 9   THEN vr_cdcooper := 17; -- TRANSPOCRED --> TRANSULCRED
    END CASE;

    -- Buscar os dados da cooperativa
    OPEN  cr_crabcop(vr_cdcooper);
    FETCH cr_crabcop INTO rw_crabcop;
    CLOSE cr_crabcop;

  END IF;

  -- Se não encontrar registros
  IF cr_crapcop%NOTFOUND THEN
    pr_cdcritic := 651;
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

    CLOSE cr_crapcop;

    RAISE vr_exc_saida;
  END IF;

  CLOSE cr_crapcop;

  -- Verifica se a Cooperativa esta preparada para executa COMPE 85 - ABBC
  vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                           ,pr_nmsistem => 'CRED'
                                           ,pr_tptabela => 'GENERI'
                                           ,pr_cdempres => 0
                                           ,pr_cdacesso => 'EXECUTAABBC'
                                           ,pr_tpregist => 0);

  -- Se não encontrar registros ou o registro encontrado está com
  -- indicador igual a SIM, sai do programa
  IF NVL(vr_dstextab,'N') <> 'SIM' THEN
    RAISE vr_exc_fimprg;
  END IF;

  -- Buscar a data do movimento
  OPEN  btch0001.cr_crapdat(pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;

  -- Se não encontrar o registro de movimento
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- 001 - Sistema sem data de movimento.
    pr_cdcritic := 1;
    -- Buscar descricão do erro
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

    CLOSE btch0001.cr_crapdat;

    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  ELSE
    -- Atribuir os valores as variáveis
    vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
    vr_dtmvtoan := btch0001.rw_crapdat.dtmvtoan;
  END IF;

  CLOSE btch0001.cr_crapdat;

  -- Indica o parametro COMPEFORA do progress
  IF pr_nmtelant = 'COMPEFORA' THEN
    vr_dtmvtaux := vr_dtmvtoan;
  ELSE
    vr_dtmvtaux := vr_dtmvtolt;
  END IF;

  -- Excluir os registros da tabela
  BEGIN

    DELETE craprej
     WHERE craprej.cdcooper = pr_cdcooper
       AND craprej.dtmvtolt = vr_dtmvtolt
       AND craprej.cdagenci = 540;

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao excluir craprej: '||SQLERRM;
      RAISE vr_exc_saida;
  END;

  /* BUSCAR A LISTA DE ARQUIVOS DO DIRETÓRIO E ANALISAR OS ARQUIVOS, SEPARANDO OS MESMOS */
  -- Busca do diretório base da cooperativa para a geração de relatórios
  vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper);

  -- Define o diretório dos arquivos
  vr_diretori := vr_nom_direto || '/integra/';

  -- Retorna um array com todos os arquivos do diretório
  gene0001.pc_lista_arquivos(pr_path      => vr_diretori
                            ,pr_pesq      => '%.DV%'    
                            ,pr_listarq   => vr_listarq
                            ,pr_des_erro  => pr_dscritic);

  -- Verifica se ocorreram erros no processo de lsitagem de arquivos
  IF TRIM(pr_dscritic) IS NOT NULL THEN
    -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' || pr_dscritic );
  END IF;

  -- Se retornou arquivos
  IF TRIM(vr_listarq) IS NOT NULL THEN
    vr_array_arquivo := gene0002.fn_quebra_string(pr_string => vr_listarq, pr_delimit => ',');

    -- Percorre todos os arquivos retornados
    FOR ind IN vr_array_arquivo.FIRST..vr_array_arquivo.LAST LOOP

      -- Verifica através da extensão do arquivo a qual grupo o mesmo pertence
      IF    vr_array_arquivo(ind) LIKE ('1'||rw_crapcop.cdagectl||'%.DVD') THEN
        -- Grupo de arquivos .DVD
        vr_arqdvd(vr_arqdvd.COUNT()+1).idarquivo := 1;
        vr_arqdvd(vr_arqdvd.COUNT()  ).nmarquivo := vr_array_arquivo(ind);
        vr_arqdvd(vr_arqdvd.COUNT()  ).cdperdev  := 2; /* DVD = Diurna  = 2 */

      ELSIF vr_array_arquivo(ind) LIKE ('1'||rw_crapcop.cdagectl||'%.DVT') THEN
        -- Grupo de arquivos .DVT
        vr_arqdvt(vr_arqdvt.COUNT()+1).idarquivo := 2;
        vr_arqdvt(vr_arqdvt.COUNT()  ).nmarquivo := vr_array_arquivo(ind);
        vr_arqdvt(vr_arqdvt.COUNT()  ).cdperdev  := 1; /* DVT = Noturna  = 1 */

      ELSIF vr_array_arquivo(ind) LIKE ('5'||rw_crapcop.cdagectl||'%.DVS') THEN
        -- Grupo de arquivos .DVS
        vr_arqdvs(vr_arqdvs.COUNT()+1).idarquivo := 3;
        vr_arqdvs(vr_arqdvs.COUNT()  ).nmarquivo := vr_array_arquivo(ind);
        vr_arqdvs(vr_arqdvs.COUNT()  ).cdperdev  := 2; /* DVT = Diurna  = 2 */

      END IF;

      -- VIACON Tratamento para cooperativa incorporada
      IF pr_cdcooper IN (1,9,13) THEN

        -- Verifica através da extensão do arquivo a qual grupo o mesmo pertence
        IF    vr_array_arquivo(ind) LIKE ('1'||rw_crabcop.cdagectl||'%.DVD') THEN
          -- Grupo de arquivos .DVD
          vr_arqdvd(vr_arqdvd.COUNT()+1).idarquivo := 4;
          vr_arqdvd(vr_arqdvd.COUNT()  ).nmarquivo := vr_array_arquivo(ind);
          vr_arqdvd(vr_arqdvd.COUNT()  ).cdperdev  := 2; /* DVD = Diurna  = 2 */

        ELSIF vr_array_arquivo(ind) LIKE ('1'||rw_crabcop.cdagectl||'%.DVT') THEN
          -- Grupo de arquivos .DVT
          vr_arqdvt(vr_arqdvt.COUNT()+1).idarquivo := 5;
          vr_arqdvt(vr_arqdvt.COUNT()  ).nmarquivo := vr_array_arquivo(ind);
          vr_arqdvt(vr_arqdvt.COUNT()  ).cdperdev  := 1; /* DVT = Noturna  = 1 */

        ELSIF vr_array_arquivo(ind) LIKE ('5'||rw_crabcop.cdagectl||'%.DVS') THEN
          -- Grupo de arquivos .DVS
          vr_arqdvs(vr_arqdvs.COUNT()+1).idarquivo := 6;
          vr_arqdvs(vr_arqdvs.COUNT()  ).nmarquivo := vr_array_arquivo(ind);
          vr_arqdvs(vr_arqdvs.COUNT()  ).cdperdev  := 2; /* DVT = Diurna  = 2 */

        END IF;
      END IF;

    END LOOP; -- Arquivos do diretório

    -- * Juntar todos os arquivos num únicos registro
    -- Se o registro de arquivos .DVD possui registro
    IF vr_arqdvd.count() > 0 THEN
      -- Percorre todos os registros
      FOR ind IN vr_arqdvd.FIRST..vr_arqdvd.LAST LOOP
        vr_arquivos(vr_arquivos.COUNT()+1) := vr_arqdvd(ind);
      END LOOP;
    END IF;
    -- Se o registro de arquivos .DVT possui registro
    IF vr_arqdvt.count() > 0 THEN
      -- Percorre todos os registros
      FOR ind IN vr_arqdvt.FIRST..vr_arqdvt.LAST LOOP
        vr_arquivos(vr_arquivos.COUNT()+1) := vr_arqdvt(ind);
      END LOOP;
    END IF;
    -- Se o registro de arquivos .DVT possui registro
    IF vr_arqdvs.count() > 0 THEN
      -- Percorre todos os registros
      FOR ind IN vr_arqdvs.FIRST..vr_arqdvs.LAST LOOP
        vr_arquivos(vr_arquivos.COUNT()+1) := vr_arqdvs(ind);
      END LOOP;
    END IF;

  END IF; -- Se retornou arquivos do diretório

  -- Se possuir arquivos para processar
  IF vr_arquivos.COUNT() > 0 THEN
    -- Percorre todos os arquivos encontrados
    FOR ind IN vr_arquivos.first..vr_arquivos.last LOOP

      -- Inicializa Contador
	  vr_qttotreg := 0;

      -- Abrir o arquivo
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_diretori
                              ,pr_nmarquiv => vr_arquivos(ind).nmarquivo
                              ,pr_tipabert => 'R'
                              ,pr_utlfileh => vr_utlfileh
                              ,pr_des_erro => vr_des_erro);

      -- Verifica se houve erro ao abrir o arquivo
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Limpar o registro de memória, Caso possua registros
      IF vr_file.COUNT() > 0 THEN
        vr_file.DELETE;
      END IF;

      -- Se o arquivo estiver aberto, percorre o mesmo e guarda todas as linhas
      -- em um registro de memória
      IF  utl_file.IS_OPEN(vr_utlfileh) THEN

        -- Ler todas as linhas do arquivo
        LOOP

          BEGIN
            -- Guarda todas as linhas do arquivo no array
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh --> Handle do arquivo aberto
                                        ,pr_des_text => vr_file(vr_file.count()+1)); --> Texto lido
          EXCEPTION
            WHEN no_data_found THEN -- não encontrar mais linhas
              EXIT;
            WHEN OTHERS THEN
              vr_des_erro := 'Erro arquivo ['||vr_arquivos(ind).nmarquivo||']: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END LOOP;

        -- Fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh); --> Handle do arquivo aberto;
      END IF;
      --
      -- Remover as linhas em branco do arquivo
      -- Enquanto a ultima linha possuir menos de 100 posições
      WHILE (length(vr_file(vr_file.last())) < 100 AND vr_file.COUNT() > 0) LOOP
        -- Exclui a ultima linha lida no arquivo
        vr_file.delete(vr_file.last());
      END LOOP;

      -- Se encontrou linhas no arquivo
      IF vr_file.count() > 0 THEN

        -- Verifica se o arquivo está completo
        IF SUBSTR(vr_file(vr_file.last()),1,10) <> '9999999999' THEN
          -- Gerar a Crítica
          pr_cdcritic := 258;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

          -- Incluir erro no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro tratado
                                     pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || pr_dscritic);

          -- Processar o próximo arquivo
          CONTINUE;
          -- Limpa variaveis de criticas
          pr_cdcritic := 0;
          pr_dscritic := NULL;

        END IF; -- Se ultima linha diferente de '9999999999'

        -- Inicializa
        pr_cdcritic := 0;

        -- Valida o arquivo, conforme informações da primeira linha
        IF SUBSTR(vr_file(vr_file.first()),48,06) <> 'CEL605'    THEN
          pr_cdcritic := 181;
        ELSIF SUBSTR(vr_file(vr_file.first()),61,03) <> rw_crapcop.cdbcoctl THEN
          pr_cdcritic := 057;
        ELSIF SUBSTR(vr_file(vr_file.first()),66,08) <> to_char(vr_dtmvtaux,'YYYYMMDD') THEN
          pr_cdcritic := 013;
        END IF;

        -- Se houve alguma critica
        IF pr_cdcritic <> 0 THEN
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

          -- Gerar Log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 1, -- Processo normal
                                     pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || pr_dscritic);

          -- Reinicializa a variável de críticas
          pr_cdcritic := 0;
          pr_dscritic := NULL;
          -- Passa para o próximo arquivo
          CONTINUE;
        END IF;

        -- Aponta para a segunda linha
        vr_nrlinha := vr_file.next(vr_file.first());

        -- Percorrer as linhas do arquivo
        LOOP

          -- Se encontrar a linha de finalização do arquivo
          EXIT WHEN SUBSTR(vr_file(vr_nrlinha),1,10) = '9999999999';

          -- Indicador de busca do registro da gncpdev
          vr_idgncpdev := FALSE;

          -- Gravar a cooperativa utilizada para acesso a tabela
          vr_auxcooper := pr_cdcooper;

          -- Buscar dados de cheques devolvidos
          OPEN  cr_gncpdev(pr_cdcooper                                            -- Cooperativa
                          ,TO_DATE(  SUBSTR(vr_file(vr_nrlinha),82,8),'YYYYMMDD') -- Data
                          ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),4 ,3))            -- Banco
                          ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),7 ,4))            -- Agencia
                          ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),12,12))           -- Conta
                          ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),25,6)));          -- Numero do Cheque
          FETCH cr_gncpdev INTO rw_gncpdev;

          -- Se não encontrar registros
          IF cr_gncpdev%NOTFOUND THEN

            -- Busca por contas transferidas entre cooperativas
            OPEN  cr_craptco(TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),12,12))); -- Conta
            FETCH cr_craptco INTO rw_craptco;

            -- Se encontrar registros
            IF cr_craptco%FOUND THEN

              -- Limpar registro
              rw_gncpdev := NULL;

              -- Fechar o cursor antes de executa-lo novamente
              CLOSE cr_gncpdev;

              -- Gravar a cooperativa utilizada para acesso a tabela
              vr_auxcooper := rw_craptco.cdcooper;

              -- Buscar dados de cheques devolvidos, utilizando o código da cooperativa,
              -- encontrado no select da tabela CRAPTCO
              OPEN  cr_gncpdev(rw_craptco.cdcooper                                    -- Cooperativa
                              ,TO_DATE(  SUBSTR(vr_file(vr_nrlinha),82,8),'YYYYMMDD') -- Data
                              ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),4 ,3))            -- Banco
                              ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),7 ,4))            -- Agencia
                              ,rw_craptco.nrctaant                                    -- Conta
                              ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),25,6)));          -- Numero do Cheque
              -- Atribuir os dados ao registro
              FETCH cr_gncpdev INTO rw_gncpdev;

              -- Se encontrar o registro para a nova cooperativa
              IF cr_gncpdev%FOUND THEN
                -- Indica que o registro foi encontrado
                vr_idgncpdev := TRUE;
              END IF;

              CLOSE cr_gncpdev;

            END IF;

            CLOSE cr_craptco;

          ELSE
            -- Indica que o registro foi encontrado
            vr_idgncpdev := TRUE;
          END IF;

          -- Se o cursor ainda estiver aberto
          IF cr_gncpdev%ISOPEN THEN
            CLOSE cr_gncpdev;
          END IF;

          -- Se não foi encontrado registro de cheques devolvidos
          IF NOT vr_idgncpdev THEN

            /*  Criacao de registro generico na tabela - gncpdev  */
            BEGIN

              vr_nrdconta := TO_NUMBER(SUBSTR(vr_file(vr_nrlinha), 70, 9));

              /* VIACON - gravar nova conta */
                IF (pr_cdcooper IN (1,9,13) )
                AND vr_arquivos(ind).idarquivo > 3 THEN

                -- Busca por contas transferidas entre cooperativas
                OPEN  cr_crabtco(vr_nrdconta); -- Conta
                FETCH cr_crabtco INTO rw_crabtco;

                IF cr_crabtco%FOUND THEN
                   vr_nrdconta := rw_crabtco.nrdconta; -- Zimmermann
                END IF;
                -- Fecha cursor
                CLOSE cr_crabtco;
              END IF;

              -- Insere o registro
              INSERT INTO gncpdev
                             (dtliquid
                             ,cdcooper
                             ,cdagenci
                             ,dtmvtolt
                             ,cdagectl
                             ,cdbanchq
                             ,cdagechq
                             ,nrctachq
                             ,nrcheque
                             ,nrddigv2
                             ,cdcmpchq
                             ,cdtipdoc
                             ,cdtipchq
                             ,nrddigv3
                             ,nrddigv1
                             ,vlcheque
                             ,nrdconta
                             ,nmarquiv
                             ,cdoperad
                             ,hrtransa
                             ,cdtipreg
                             ,flgconci
                             ,nrseqarq
                             ,cdcritic
                             ,cdalinea
                             ,flgpcctl
                             ,cdperdev)
                       VALUES(vr_dtmvtolt                                             -- dtliquid
                             ,vr_auxcooper                                            -- cdcooper
                             ,0                                                       -- cdagenci /* Fixo, conforme Mirtes */
                             ,TO_DATE(  SUBSTR(vr_file(vr_nrlinha), 82, 8),'YYYYMMDD')-- dtmvtolt
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha), 59, 4))           -- cdagectl
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),  4, 3))           -- cdbanchq
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),  7, 4))           -- cdagechq
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha), 12,12))           -- nrctachq
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha), 25, 6))           -- nrcheque
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha), 11, 1))           -- nrddigv2
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),  1, 3))           -- cdcmpchq
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),148, 3))           -- cdtipdoc
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha), 51, 1))           -- cdtipchq
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha), 31, 1))           -- nrddigv3
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha), 24, 1))           -- nrddigv1
                             ,(TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),34,17))/100)      -- vlcheque
                             ,vr_nrdconta                                             -- nrdconta
                             ,vr_arquivos(ind).nmarquivo                              -- nmarquiv
                             ,pr_cdoperad                                             -- cdoperad
                             ,TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))                     -- hrtransa
                             ,2                                                       -- cdtipreg
                             ,1                                                       -- flgconci
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),151,10))           -- nrseqarq
                             ,927                                                     -- cdcritic
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha), 54, 2))           -- cdalinea
                             ,0                                                       -- flgpcctl
                             ,vr_arquivos(ind).cdperdev);                             -- cdperdev

            EXCEPTION
              WHEN OTHERS THEN
                -- Buscar descricão do erro
                pr_dscritic := 'Erro ao inserir gncpdev: '||SQLERRM;
                -- Envio centralizado de log de erro
                RAISE vr_exc_saida;
            END;

            -- Inclui um registro no cadastro de rejeitados na integracao
            BEGIN

              INSERT INTO craprej
                             (cdagenci
                             ,cdcritic
                             ,dtmvtolt
                             ,nrdconta
                             ,vllanmto
                             ,cdpesqbb
                             ,nrseqdig
                             ,nrdocmto
                             ,cdcooper)
                      VALUES (540                                                -- cdagenci
                             ,927                                                -- cdcritic
                             ,vr_dtmvtolt                                        -- dtmvtolt
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha), 12,12))      -- nrdconta
                             ,(TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),34,17))/100) -- vllanmto
                             ,vr_file(vr_nrlinha)                                -- cdpesqbb
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),151,10))      -- nrseqdig
                             ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha), 25, 6))      -- nrdocmto
                             ,vr_auxcooper);                                     -- cdcooper

            EXCEPTION
              WHEN OTHERS THEN
                -- Buscar descricão do erro
                pr_dscritic := 'Erro ao inserir craprej: '||SQLERRM;
                -- Envio centralizado de log de erro
                RAISE vr_exc_saida;
            END;
          ELSE -- Se encontrou cheque devolvido

            -- Verifica o tipo do registro
            IF rw_gncpdev.cdtipreg = 2 THEN
              -- Inclui um registro no cadastro de rejeitados na integracao
              BEGIN

                INSERT INTO craprej
                               (cdagenci
                               ,cdcritic
                               ,dtmvtolt
                               ,nrdconta
                               ,vllanmto
                               ,cdpesqbb
                               ,nrseqdig
                               ,nrdocmto
                               ,cdcooper)
                        VALUES (540                                                -- cdagenci
                               ,670                                                -- cdcritic
                               ,vr_dtmvtolt                                        -- dtmvtolt
                               ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha), 12,12))      -- nrdconta
                               ,(TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),34,17))/100) -- vllanmto
                               ,vr_file(vr_nrlinha)                                -- cdpesqbb
                               ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha),151,10))      -- nrseqdig
                               ,TO_NUMBER(SUBSTR(vr_file(vr_nrlinha), 25, 6))      -- nrdocmto
                               ,vr_auxcooper);                                     -- cdcooper


              EXCEPTION
                WHEN OTHERS THEN
                  -- Buscar descricão do erro
                  pr_dscritic := 'Erro ao inserir craprej: '||SQLERRM;
                  -- Envio centralizado de log de erro
                  RAISE vr_exc_saida;
              END;
            ELSE

              -- Se encontrou um registro do tipo 1 (NR) é pq conseguiu conciliar
              BEGIN

                UPDATE gncpdev
                   SET gncpdev.cdtipreg = 2
                     , gncpdev.flgconci = 1 -- TRUE
                     , gncpdev.dtliquid = vr_dtmvtolt
                     , gncpdev.cdalinea = TO_NUMBER(SUBSTR(vr_file(vr_nrlinha), 54, 2))
                 WHERE gncpdev.rowid    = rw_gncpdev.gncpdev_rowid;

              EXCEPTION
                WHEN OTHERS THEN
                  -- Buscar descricão do erro
                  pr_dscritic := 'Erro ao atualizar gncpdev: '||SQLERRM;
                  -- Envio centralizado de log de erro
                  RAISE vr_exc_saida;
              END;

            END IF;

          END IF; -- IF NOT vr_idgncpdev

          -- Quantidade total de registros processados
          vr_qttotreg := vr_qttotreg + 1;

          -- Se for a última linha a ser lida do arquivo
          EXIT WHEN vr_nrlinha = vr_file.last;
          vr_nrlinha := vr_file.next(vr_nrlinha); -- Próximo
        END LOOP; -- Fim LOOP linhas do arquivo

        -- Cria um log de execução
        pr_cdcritic := 190; -- "190 - ARQUIVO INTEGRADO COM SUCESSO"
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        -- Gerar Log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 1, -- Processo normal
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || pr_dscritic
                                                         || ' - Arquivo: integra/' || vr_arquivos(ind).nmarquivo);
        pr_cdcritic := 0;
        pr_dscritic := NULL;

        -- Contagem de relatórios gerados
        vr_qtdrelat := vr_qtdrelat + 1;

        -- Montar o XML para o relatório e solicitar o mesmo
        DECLARE

          -- Cursores locais
          CURSOR cr_xml_craprej IS
            SELECT craprej.cdcritic
                 , craprej.cdpesqbb
                 , craprej.nrseqdig
                 , craprej.nrdconta
                 , craprej.nrdocmto
                 , craprej.vllanmto
              FROM craprej
             WHERE craprej.cdcooper = vr_auxcooper
               AND craprej.dtmvtolt = vr_dtmvtolt
               AND craprej.cdagenci = 540
             ORDER BY craprej.nrseqdig
                    , craprej.nrdconta
                    , craprej.nrdocmto;

          -- Variáveis locais do bloco
          vr_xml_clobxml       CLOB;
          vr_xml_des_erro      VARCHAR2(4000);
          vr_xml_dscritic      VARCHAR2(200);
          vr_xml_dspesqbb      craprej.cdpesqbb%TYPE;
          vr_flg_temrejei      VARCHAR2(1) := 'N';

          -- Subrotina para escrever texto na variável CLOB do XML
          PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                                   ,pr_desdados IN VARCHAR2) IS
          BEGIN
            dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
          END;

        BEGIN

          -- Preparar o CLOB para armazenar as infos do arquivo
          dbms_lob.createtemporary(vr_xml_clobxml, TRUE, dbms_lob.CALL);
          dbms_lob.open(vr_xml_clobxml, dbms_lob.lob_readwrite);
          pc_escreve_clob(vr_xml_clobxml,'<?xml version="1.0" encoding="utf-8"?>'||chr(10)||'<crps540 >'||chr(10));

          -- Percorre todos os registros retornados pelo cursor
          FOR rv_xml_craprej IN cr_xml_craprej LOOP

            -- Indica que tem rejeitado
            vr_flg_temrejei := 'S';

            -- Busca a descrição da critica
            vr_xml_dscritic := gene0001.fn_busca_critica(pr_cdcritic => rv_xml_craprej.cdcritic);

            -- Codigo de pesquisa do lancamento no banco do Brasil.
            vr_xml_dspesqbb := substr(rv_xml_craprej.cdpesqbb,56,3)||' '||
                               substr(rv_xml_craprej.cdpesqbb,59,4)||' '||
                               substr(rv_xml_craprej.cdpesqbb,79,3);

              /** VIACON - Tratamento Incorporacao */
              IF  (pr_cdcooper IN (1,9,13))
              AND vr_arquivos(ind).idarquivo > 3 THEN
              vr_xml_dscritic := vr_xml_dscritic || ' - INCORPORADA';
            END IF;

            -- Adiciona a linha ao XML
            pc_escreve_clob(vr_xml_clobxml,'<rejeitado>'
                                 ||chr(10)||'  <nrseqdig>'||rv_xml_craprej.nrseqdig||'</nrseqdig>'
                                 ||chr(10)||'  <nrdconta>'||TRIM(gene0002.fn_mask(rv_xml_craprej.nrdconta,'zzz.zzz.zzz.zzz.zzz.z'))||'</nrdconta>'
                                 ||chr(10)||'  <nrdocmto>'||TRIM(gene0002.fn_mask(rv_xml_craprej.nrdocmto,'zzz.zzz.zzz'))||'</nrdocmto>'
                                 ||chr(10)||'  <dspesqbb>'||vr_xml_dspesqbb ||'</dspesqbb>'
                                 ||chr(10)||'  <vllanmto>'||to_char(rv_xml_craprej.vllanmto,'FM9G999G999G990D00')||'</vllanmto>'
                                 ||chr(10)||'  <dscritic>'||SUBSTR(vr_xml_dscritic,0,60) ||'</dscritic>'
                                 ||chr(10)||'</rejeitado>');

          END LOOP;

          -- Adiciona a linha ao XML
          pc_escreve_clob(vr_xml_clobxml, '<dsarquivo>'||vr_diretori||vr_arquivos(ind).nmarquivo||'</dsarquivo>'
                               ||chr(10)||'<dtprocess>'||to_char(vr_dtmvtolt,'dd/mm/yyyy')||'</dtprocess>'
                               ||chr(10)||'<fltemreje>'||vr_flg_temrejei||'</fltemreje>'
                               ||chr(10)||'<valor>'||vr_qttotreg||'</valor></crps540>');

          -- Submeter o relatório 536
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                     ,pr_dtmvtolt  => vr_dtmvtolt                          --> Data do movimento atual
                                     ,pr_dsxml     => vr_xml_clobxml                       --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crps540'                           --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl531.jasper'                     --> Arquivo de layout do iReport
                                     ,pr_dsparams  => null                                 --> Sem parâmetros
                                     ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl531_'||to_char(ind,'FM00')||'.lst'     --> Arquivo final com o path
                                     ,pr_qtcoluna  => 132                                  --> 132 colunas
                                     ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                     ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => '132col'                             --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 1                                    --> Número de cópias
                                     ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                     ,pr_des_erro  => pr_dscritic);                        --> Saída com erro

          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_xml_clobxml);
          dbms_lob.freetemporary(vr_xml_clobxml);

          -- Verifica se ocorreram erros na geração do XML
          IF vr_des_erro IS NOT NULL THEN

            pr_dscritic := vr_xml_des_erro;

            -- Gerar exceção
            RAISE vr_exc_saida;
          END IF;
          /*  Salvar copia relatorio para "/rlnsv"  */
          IF pr_nmtelant = 'COMPEFORA' THEN
            vr_dircop_rlnsv:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                             ,pr_cdcooper => pr_cdcooper
                                                             ,pr_nmsubdir => 'rlnsv');

            gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||vr_nom_direto||'/rl/crrl531_'||to_char(ind,'FM00')||'.lst'||' '||vr_dircop_rlnsv
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_des_saida);
          END IF;
        END;

        BEGIN

          -- Excluir registros
          DELETE craprej
           WHERE craprej.cdcooper = vr_auxcooper
             AND craprej.dtmvtolt = vr_dtmvtolt
             AND craprej.cdagenci = 540;

        EXCEPTION
          WHEN OTHERS THEN
            -- Buscar descricão do erro
            pr_dscritic := 'Erro ao inserir craprej: '||SQLERRM;
            -- Envio centralizado de log de erro
            RAISE vr_exc_saida;
        END;

      END IF; -- Se encontrou linhas no arquivo

      /* Move o arquivo lido para o diretório salvar */
      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_diretori||vr_arquivos(ind).nmarquivo||' '||vr_nom_direto||'/salvar 2> /dev/null'
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_saida);

    END LOOP; -- vr_arquivos

  END IF;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  COMMIT;

EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF nvl(pr_cdcritic,0) > 0 OR pr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || pr_dscritic );
    END IF;
    -- Limpar variaveis de saida de critica pois eh um erro tratado
    pr_cdcritic := 0;
    pr_dscritic := null;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS540;
/
