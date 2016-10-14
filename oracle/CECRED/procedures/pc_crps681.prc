CREATE OR REPLACE PROCEDURE CECRED.pc_crps681(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                      ,pr_nmtelant IN VARCHAR2                --> Nome da tela
                                      ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

  /* ..........................................................................

   Programa: PC_CRPS681
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Tiago
   Data    : Marco/2014.                  Ultima atualizacao: 10/11/2015
   Dados referentes ao programa: Projeto automatiza compe.

   Frequencia : Diario (Batch).
   Objetivo   : Conciliar arquivos de devolução enviados.
   
   Alterações : 24/09/2014 - Incluir tratamentos para incorporação Concredi pela Via
                            e Credimilsul pela SCRCred (Marcos-Supero)
                            
                08/01/2015 - Ajustes para enviar as criticas de não processamento do arquivo
                             via email, para não ser mais apresentada no log_bacth SD240262 (Odirlei/AMcom)            
                             
                10/11/2015 - Filtrado tabela gncpddc com dtliquid para pegar apenas
                             registros relevantes ao relatorio 675
                             (Tiago / Elton SD340990).             
                             
			   13/10/2016 - Alterada leitura da tabela de parâmetros para utilização
							da rotina padrão. (Rodrigo)                             
  ............................................................................ */


------------------------------- CURSORES ---------------------------------
  -- Buscar informações da cooperativa
  CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
         , crapcop.dsdircop
         , LPAD(crapcop.cdbcoctl,3,0) cdbcoctl
         , to_char(crapcop.cdagectl,'FM0000') cdagectl
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
  -- Busca das informações concialiadas
  CURSOR cr_gncpddc(pr_cdcooper gncpddc.cdcooper%TYPE
                   ,pr_vldocmto gncpddc.vldocmto%TYPE
                   ,pr_nrdocmto gncpddc.nrdocmto%TYPE
                   ,pr_dtmvtolt gncpddc.dtmvtolt%TYPE
                   ,pr_cdbandoc gncpddc.cdbandoc%TYPE
                   ,pr_cdagedoc gncpddc.cdagedoc%TYPE
                   ,pr_nrctadoc gncpddc.nrctadoc%TYPE
                   ,pr_cdmotdev gncpddc.cdmotdev%TYPE
                   ,pr_cdtipreg gncpddc.cdtipreg%TYPE) IS
    SELECT ddc.rowid,
           ddc.nrdocmto,
           ddc.dtmvtolt,
           ddc.vldocmto,
           ddc.cdcooper,
           ddc.cdagenci,
           ddc.nrdconta,
           ddc.nmfavore,
           ddc.nrcpffav,
           ddc.cdcritic,
           ddc.cdbandoc,
           ddc.cdagedoc,
           ddc.nrctadoc,
           ddc.nmemiten,
           ddc.nrcpfemi,
           ddc.cdmotdev,
           ddc.cdoperad,
           ddc.flgpcctl,
           ddc.dslayout,
           ddc.cdtipreg
      FROM gncpddc ddc
     WHERE ddc.cdcooper = pr_cdcooper
       AND ddc.vldocmto = pr_vldocmto
       AND ddc.nrdocmto = pr_nrdocmto
       AND ddc.dtmvtolt = pr_dtmvtolt
       AND ddc.cdbandoc = pr_cdbandoc
       AND ddc.cdagedoc = pr_cdagedoc
       AND ddc.nrctadoc = pr_nrctadoc
       AND ddc.cdmotdev = pr_cdmotdev
       AND ddc.cdtipreg = pr_cdtipreg;
  
  -- buscar nome do programa
  CURSOR cr_crapprg (pr_cdprogra crapprg.cdprogra%TYPE)IS
    SELECT crapprg.dsprogra##1 dsprogra
      FROM crapprg 
     WHERE crapprg.cdcooper = pr_cdcooper
       AND crapprg.cdprogra = pr_cdprogra;
  rw_crapprg cr_crapprg%ROWTYPE;      
  
  ------------------------------- TIPOS -------------------------------
  TYPE typ_arquivo IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
  
  ------------------------------- REGISTROS -------------------------------
  rw_crapcop        cr_crapcop%ROWTYPE;
  rw_crapcop_incorp cr_crapcop%ROWTYPE;
  rw_gncpddc        cr_gncpddc%ROWTYPE;


  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS681';
  -- Data de movimento, mês de referencia e demais datas de controle
  vr_dtmvtolt     DATE;

  -- Variáveis de dados gerais do programa
  vr_nrdconta     crapass.nrdconta%TYPE;

  -- Rolbacks para erros, ignorar o resto do processo e rollback
  -- Tratamento de erros
  vr_typ_saida    VARCHAR2(100);
  vr_des_saida    VARCHAR2(2000);
  vr_exc_fimprg   EXCEPTION;
  vr_exc_saida    EXCEPTION;
  vr_cdcritic     PLS_INTEGER;
  vr_dscritic     VARCHAR2(4000);

  vr_nom_direto     VARCHAR2(200);
  vr_diretori       VARCHAR2(200);
  vr_listarq        VARCHAR2(32767);
  vr_listarq_incorp VARCHAR2(32767);
  vr_vet_arquivos GENE0002.typ_split;

  -- Índice para a linha do arquivo
  vr_nrlinha      NUMBER;

  -- Arquivo lido
  vr_utlfileh      UTL_FILE.file_type;
  -- Variável de erros
  vr_des_erro      VARCHAR2(4000);
  vr_leit_arq      typ_arquivo;
  vr_qttotreg      NUMBER;
  -- variaveis para envio de email
  vr_conteudo      VARCHAR2(2000);
  vr_email_dest    VARCHAR2(2000);

  -- Variaveis do layout do arquivo
  vr_cdcooper      NUMBER;
  vr_nrctadoc      NUMBER;
  vr_nrdocmto      NUMBER;
  vr_vldocmto      NUMBER;
  vr_nmdestin      VARCHAR2(40);
  vr_cpfcgcds      NUMBER;
  vr_cdbandoc      NUMBER;
  vr_cdagedoc      NUMBER;
  vr_cdagenci      NUMBER;
  vr_nmremete      VARCHAR2(40);
  vr_cpfcgcre      NUMBER;
  vr_dttrcmov      DATE;
  vr_cdmotdev      NUMBER;
  vr_dslayout      VARCHAR2(255);
  vr_dstextab	   craptab.dstextab%TYPE;

BEGIN -- Principal

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra);

  -- Verifica se a cooperativa esta cadastrada
  OPEN  cr_crapcop(pr_cdcooper);
  FETCH cr_crapcop INTO rw_crapcop;
  -- Se não encontrar
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor pois haverá raise
    CLOSE cr_crapcop;
    -- Montar mensagem de critica
    vr_cdcritic := 651;
    RAISE vr_exc_saida;
  END IF;

  -- Apenas fechar o cursor
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

  -- Leitura do calendário da cooperativa
  OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
  -- Se não encontrar
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE btch0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE
    -- Guarda a data
    vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
  END IF;

  -- Fechar o cursor
  CLOSE btch0001.cr_crapdat;

  -- Validações iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);

  -- Se a variavel de erro é <> 0
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  /* BUSCAR A LISTA DE ARQUIVOS DO DIRETÓRIO E ANALISAR OS ARQUIVOS, SEPARANDO OS MESMOS */
  -- Busca do diretório base da cooperativa para a geração de relatórios
  vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper);

  -- Define o diretório dos arquivos
  vr_diretori := vr_nom_direto || '/integra';

  -- Retorna um array com todos os arquivos do diretório
  gene0001.pc_lista_arquivos(pr_path      => vr_diretori
                            ,pr_pesq      => '3'||rw_crapcop.cdagectl||'%.DVS' /*Filtrar*/
                            ,pr_listarq   => vr_listarq
                            ,pr_des_erro  => pr_dscritic);

  -- Verifica se ocorreram erros no processo de listagem de arquivos
  IF TRIM(pr_dscritic) IS NOT NULL THEN
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 2, -- Erro tratato
                               pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' || pr_dscritic );
  END IF;

  -- Para cooperativas com Incorporação
  IF pr_cdcooper in(1,13) THEN
    -- Buscar dados da cooperativa incorporada
    IF pr_cdcooper = 1 THEN
      -- Para Viacredi >> Concredi
      OPEN cr_crapcop(4);
    ELSE
      -- Para ScrCred >> Credimilsul
      OPEN cr_crapcop(15);
    END IF;
    -- Retornar as informações
    FETCH cr_crapcop
     INTO rw_crapcop_incorp;
    CLOSE cr_crapcop;
    -- Listar os arquivos da Incorporada
    gene0001.pc_lista_arquivos(pr_path      => vr_diretori
                              ,pr_pesq      => '3'||rw_crapcop_incorp.cdagectl||'%.DVS' /*Filtrar*/
                              ,pr_listarq   => vr_listarq_incorp
                              ,pr_des_erro  => pr_dscritic);
    -- Se encontrou arquivos incorporados
    IF trim(vr_listarq_incorp) IS NOT NULL THEN
      -- Adicionar a lista de arquivos total
      -- Obs: Tratar caso em que não existem arquivos na coop conectada
      IF TRIM(vr_listarq) IS NOT NULL THEN
        -- Precisamos fazer uma união das duas listas
        vr_listarq := vr_listarq || ',' || vr_listarq_incorp;
      ELSE
        -- Gerar a lista apenas com os arquivos incorporados
        vr_listarq := vr_listarq_incorp;
      END IF;
    END IF;
  END IF;
  
  --Buscar destinatario email
  vr_email_dest:= nvl(gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRPS681_EMAIL')
                      ,'compe@cecred.coop.br');
  -- buscar nome do programa
  OPEN cr_crapprg(pr_cdprogra => vr_cdprogra);
  FETCH cr_crapprg
   INTO rw_crapprg;
  CLOSE cr_crapprg;
  
  vr_conteudo := NULL;  
  -- Se retornou arquivos
  -- Separar a lista de arquivos em vetor
  vr_vet_arquivos := gene0002.fn_quebra_string(pr_string => vr_listarq, pr_delimit => ',');

  -- Se não encontrou arquivos para processar
  IF vr_vet_arquivos.COUNT() = 0 THEN
    -- Seta a crítica: 182 - Arquivo nao existe
    vr_cdcritic := 182;
    -- Finaliza o programa, sem erro
    RAISE vr_exc_fimprg;
  ELSE
    -- Percorre todos os arquivos encontrados
    FOR ind IN vr_vet_arquivos.first..vr_vet_arquivos.last LOOP

      -- Abrir o arquivo atual
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_diretori
                              ,pr_nmarquiv => vr_vet_arquivos(ind)
                              ,pr_tipabert => 'R'
                              ,pr_utlfileh => vr_utlfileh
                              ,pr_des_erro => vr_des_erro);


      -- Verifica se houve erro ao abrir o arquivo
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Limpar o registro de memória, Caso possua registros
      IF vr_leit_arq.COUNT() > 0 THEN
        vr_leit_arq.DELETE;
      END IF;

      -- Se o arquivo estiver aberto, percorre o mesmo e guarda todas as linhas
      -- em um registro de memória
      IF utl_file.IS_OPEN(vr_utlfileh) THEN
        -- Ler todas as linhas do arquivo
        LOOP
          BEGIN
            -- Guarda todas as linhas do arquivo no array
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh --> Handle do arquivo aberto
                                        ,pr_des_text => vr_leit_arq(vr_leit_arq.count()+1)); --> Texto lido

          EXCEPTION
            WHEN no_data_found THEN -- não encontrou mais linhas
              EXIT;
            WHEN OTHERS THEN
              vr_des_erro := 'Erro arquivo ['||vr_vet_arquivos(ind)||']: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END LOOP;
        -- Fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh); --> Handle do arquivo aberto;
      END IF;

      -- Remover as linhas em branco do arquivo
      -- Enquanto a ultima linha possuir menos de 100 posições
      WHILE (length(vr_leit_arq(vr_leit_arq.last())) < 100 AND vr_leit_arq.COUNT() > 0) LOOP
        -- Exclui a ultima linha lida no arquivo
        vr_leit_arq.delete(vr_leit_arq.last());
      END LOOP;
      
      -- Limpa variaveis de criticas
      pr_cdcritic := 0;
      pr_dscritic := NULL;
       
      -- Se encontrou linhas no arquivo
      IF vr_leit_arq.count() > 0 THEN
        -- Verifica se o arquivo está completo
        IF SUBSTR(vr_leit_arq(vr_leit_arq.last()),1,20) <> '99999999999999999999' THEN
          -- Gerar a Crítica
          pr_cdcritic := 258;
        END IF; -- Se ultima linha diferente de '99999999999999999999'

        IF pr_cdcritic = 0 THEN
          -- Valida o arquivo, conforme informações da primeira linha
          IF SUBSTR(vr_leit_arq(vr_leit_arq.first()),21,06) <> 'DCR605'    THEN
            pr_cdcritic := 181; -- 181 - Falta registro de controle no arquivo.
          ELSIF to_date( SUBSTR(vr_leit_arq(vr_leit_arq.first()),31,08), 'RRRRMMDD') <> vr_dtmvtolt THEN
            pr_cdcritic := 789; -- 789 - Data invalida no arquivo
          END IF;
        END IF;  

        -- Se houve alguma critica
        IF pr_cdcritic <> 0 THEN
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

          vr_conteudo := vr_conteudo || 
                         'Nao foi possível processar arquivo <b>'||vr_vet_arquivos(ind)||':'||
                         '</b><br>&nbsp&nbsp&nbsp&nbsp - '||to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||
                         ' --> '|| pr_dscritic ||'<br><br>';
          
          -- Reinicializa a variável de críticas
          pr_cdcritic := 0;
          pr_dscritic := NULL;
          -- Passa para o próximo arquivo
          CONTINUE;
        END IF;

        -- Aponta para a segunda linha
        vr_nrlinha := vr_leit_arq.next(vr_leit_arq.first());

        -- Tratamento exclusivo central Cecred
        IF pr_cdcooper = 3 THEN
          -- Código da Central
          vr_cdcooper := 3;
          vr_cdagenci := 100;
        -- Senão, Se for o arquivo da cooperativa conectada
        ELSIF vr_vet_arquivos(ind) LIKE '3'||rw_crapcop.cdagectl||'%.DVS' THEN
          vr_cdcooper := pr_cdcooper;
          vr_cdagenci := rw_crapcop.cdagectl;
        ELSE -- É da cooperativa incorporada
          vr_cdcooper := pr_cdcooper; --> Arquivos da cooperativa incorporada são gravados na incorporadora
          vr_cdagenci := rw_crapcop_incorp.cdagectl;
        END IF;

        -- Percorrer as linhas do arquivo
        LOOP

          -- Se encontrar a linha de finalização do arquivo
          EXIT WHEN SUBSTR(vr_leit_arq(vr_nrlinha),1,20) = '99999999999999999999';

          -- Pega linha do arquivo e joga pras variaveis com seu respectivo tipo
          BEGIN
            vr_nrdconta := TO_NUMBER(SUBSTR(vr_leit_arq(vr_nrlinha),017 , 008));   -- Nr Cta Participante
            vr_nrdocmto := TO_NUMBER(nvl(SUBSTR(vr_leit_arq(vr_nrlinha),025 , 006),0));   -- Nr Documento
            vr_vldocmto := TO_NUMBER(nvl(SUBSTR(vr_leit_arq(vr_nrlinha),031 , 018),0)); -- Valor
            vr_vldocmto := vr_vldocmto / 100;
            vr_nmdestin := SUBSTR(vr_leit_arq(vr_nrlinha),049 , 040);              -- Nome Destino (favorecido)
            vr_cpfcgcds := TO_NUMBER(SUBSTR(vr_leit_arq(vr_nrlinha),089 , 014));   -- CPF-CGC Destinatario (fav)
            vr_cdbandoc := TO_NUMBER(SUBSTR(vr_leit_arq(vr_nrlinha),121 , 003));   -- Nr Cod Participante Apresentante
            vr_cdagedoc := TO_NUMBER(SUBSTR(vr_leit_arq(vr_nrlinha),124 , 004));   -- Nr Agencia Apresentante
            vr_nrctadoc := TO_NUMBER(SUBSTR(vr_leit_arq(vr_nrlinha),129 , 013));   -- Nr Cta Participante Apresentante nrctadoc
            vr_nmremete := SUBSTR(vr_leit_arq(vr_nrlinha),142 , 040);              -- Nome Remetente emitente
            vr_cpfcgcre := TO_NUMBER(SUBSTR(vr_leit_arq(vr_nrlinha),182 , 014));   -- CPF-CGC Remetente emitente
            vr_dttrcmov := TO_DATE(SUBSTR(vr_leit_arq(vr_nrlinha),215,8),'RRRRMMDD'); -- Dta Troca Movimento AAAAMMDD
            vr_cdmotdev := TO_NUMBER(SUBSTR(vr_leit_arq(vr_nrlinha),239 , 002));   -- Motivo Devolucao conforme codificacao
            vr_dslayout := SUBSTR(vr_leit_arq(vr_nrlinha),1,255);
          EXCEPTION
             WHEN OTHERS THEN
               -- Tratamento de possíveis erros na leitura acima
               vr_dscritic := 'Erro no layout do arquivo: ' || vr_leit_arq(vr_nrlinha);
               RAISE vr_exc_saida;
          END;

          -- Buscar registro para conciliação com base nas informações
          -- de destino do doc devolvido
          OPEN cr_gncpddc(vr_cdcooper          -- Cooperativa do Arquivo
                         ,vr_vldocmto          -- Valor do Documento
                         ,vr_nrdocmto          -- Numero Documento
                         ,vr_dttrcmov          -- Data Movimento
                         ,vr_cdbandoc          -- Nr Cod Partcipante Apres(cdbandoc)
                         ,vr_cdagedoc          -- Nr Agencia Apresentante(cdagedoc)
                         ,vr_nrctadoc          -- Nr ContaPartic Apresent(nrctadoc)
                         ,vr_cdmotdev          -- Codigo Devolucao
                         ,3        );          -- cdtipreg
          FETCH cr_gncpddc INTO rw_gncpddc;
          -- Se não encontrar registros
          IF cr_gncpddc%NOTFOUND THEN
            -- Criacao registro gncpddc
            BEGIN
              INSERT INTO gncpddc(nrdocmto,
                                  dtmvtolt,
                                  vldocmto,
                                  cdtipreg,
                                  cdcooper,
                                  cdagenci,
                                  nrdconta,
                                  nmfavore,
                                  nrcpffav,
                                  cdcritic,
                                  cdbandoc,
                                  cdagedoc,
                                  nrctadoc,
                                  nmemiten,
                                  nrcpfemi,
                                  cdmotdev,
                                  cdoperad,
                                  dtliquid,
                                  nmarquiv,
                                  hrtransa,
                                  flgconci,
                                  flgpcctl,
                                  dslayout)
                          VALUES (vr_nrdocmto,
                                  vr_dttrcmov,
                                  vr_vldocmto,
                                  3,           --> cdtipreg
                                  vr_cdcooper,
                                  vr_cdagenci, --> cdagenci
                                  vr_nrdconta,
                                  vr_nmdestin,
                                  vr_cpfcgcds,
                                  11,          --> cdcritic
                                  vr_cdbandoc, --> cdbandoc
                                  vr_cdagedoc, --> cdagedoc
                                  vr_nrctadoc, --> nrctadoc
                                  vr_nmremete, --> nmemiten
                                  vr_cpfcgcre, --> nrcpfemi
                                  vr_cdmotdev,
                                  1,
                                  vr_dttrcmov, --> dtliquid
                                  vr_vet_arquivos(ind),     --> nmarquiv
                                  gene0002.fn_busca_time(),
                                  0,
                                  0,
                                  vr_dslayout);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir gncpddc: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          ELSE -- Se encontrou cheque devolvido
            -- Verifica o tipo do registro
            IF rw_gncpddc.cdtipreg = 3 THEN
              -- Se encontrou um registro do tipo 3 é pq conseguiu conciliar
              BEGIN
                UPDATE gncpddc
                   SET gncpddc.cdtipreg = 2
                     , gncpddc.flgconci = 1 -- TRUE
                     , gncpddc.dtliquid = vr_dtmvtolt
                     , gncpddc.hrtransa = gene0002.fn_busca_time()
                     , gncpddc.nmarquiv = vr_vet_arquivos(ind)
                 WHERE gncpddc.rowid    = rw_gncpddc.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Buscar descricão do erro
                  pr_dscritic := 'Erro ao atualizar gncpddc: '||SQLERRM;
                  -- Envio centralizado de log de erro
                  RAISE vr_exc_saida;
              END;
            END IF;
          END IF; -- IF NOT Found GNCDDC
          -- Fechar o cursor
          CLOSE cr_gncpddc;

          -- Quantidade total de registros processados
          vr_qttotreg  := vr_qttotreg + 1;
          -- Se for a última linha a ser lida do arquivo
          EXIT WHEN vr_nrlinha = vr_leit_arq.last;
          vr_nrlinha := vr_leit_arq.next(vr_nrlinha); -- Próximo
        END LOOP; -- Fim LOOP linhas do arquivo
        
          
        -- Montar o XML para o relatório e solicitar o mesmo
        DECLARE
          -- Cursores locais
          CURSOR cr_xml_gncpddc(pr_dtliquid IN gncpddc.dtliquid%TYPE) IS
            SELECT ddc.cdcooper
                  ,ddc.nrdconta
                  ,ddc.nmfavore
                  ,ddc.cdtipreg
                  ,ddc.nrdocmto
                  ,ddc.vldocmto
                  ,ddc.cdmotdev
                  ,ddc.cdagenci
                  ,ddc.cdoperad
                  ,ddc.nmarquiv
                  ,ddc.nmemiten
                  ,ddc.cdcritic
                  ,ddc.cdbandoc
                  ,ddc.cdagedoc
                  ,ddc.dtliquid
              FROM gncpddc ddc
             WHERE ddc.cdcooper = vr_cdcooper          --> Cooperativa do arquivo
               AND ddc.nmarquiv = vr_vet_arquivos(ind) --> Arquivo em questão
               AND ddc.cdtipreg = 2                    --> Conciliado
               AND ddc.flgconci = 1                    --> Conciliado
               AND ddc.dtliquid = pr_dtliquid
             ORDER BY ddc.nrdconta,
                      ddc.nmfavore,
                      ddc.cdtipreg,
                      ddc.nrdocmto;

          -- Variáveis locais do bloco
          vr_xml_clobxml  CLOB;
          vr_xml_dscritic VARCHAR2(200);
          vr_dircop_rlnsv VARCHAR2(200);

          -- Subrotina para escrever texto na variável CLOB do XML
          PROCEDURE pc_escreve_clob(pr_desdados IN VARCHAR2) IS
          BEGIN
            dbms_lob.writeappend(vr_xml_clobxml,length(pr_desdados),pr_desdados);
          END;

        BEGIN

          -- Preparar o CLOB para armazenar as infos do arquivo
          dbms_lob.createtemporary(vr_xml_clobxml, TRUE, dbms_lob.CALL);
          dbms_lob.open(vr_xml_clobxml, dbms_lob.lob_readwrite);
          -- Inicializar o XML
          pc_escreve_clob('<?xml version="1.0" encoding="utf-8"?>'||
                          '<crps681 nmarquiv="'||TRIM(gene0007.fn_caract_controle(vr_vet_arquivos(ind)))||'"'||
                          '         dtliquid="'||to_char(vr_dtmvtolt,'DD/MM/RRRR')||'">');
          -- Percorre todos os registros retornados pelo cursor
          FOR rv_xml_gncpddc IN cr_xml_gncpddc(pr_dtliquid => vr_dtmvtolt) LOOP
            -- Busca a descrição da critica
            vr_xml_dscritic := gene0001.fn_busca_critica(pr_cdcritic => rv_xml_gncpddc.cdcritic );
            -- Adiciona a linha ao XML
            pc_escreve_clob('<devolvidos>'
                           ||'  <nrdconta>'||TRIM(gene0002.fn_mask(rv_xml_gncpddc.nrdconta,'zzz.zzz.zzz.zzz.zzz.z'))||'</nrdconta>'
                           ||'  <nrdocmto>'||TRIM(gene0002.fn_mask(rv_xml_gncpddc.nrdocmto,'zzz.zzz.zzz.z'))||'</nrdocmto>'
                           ||'  <nmfavore>'||TRIM(gene0007.fn_caract_controle(rv_xml_gncpddc.nmfavore))||'</nmfavore>'
                           ||'  <vldocmto>'||to_char(rv_xml_gncpddc.vldocmto,'FM9999999990D00')||'</vldocmto>'
                           ||'  <cdbandoc>'||to_char(rv_xml_gncpddc.cdbandoc)||'</cdbandoc>'
                           ||'  <cdagedoc>'||to_char(rv_xml_gncpddc.cdagedoc)||'</cdagedoc>'
                           ||'  <cdmotdev>'||to_char(rv_xml_gncpddc.cdmotdev)||'</cdmotdev>'
                           ||'  <cdtipreg>'||to_char(rv_xml_gncpddc.cdtipreg)||'</cdtipreg>'
                           ||'</devolvidos>');
          END LOOP;
          -- Adiciona a linha ao XML
          pc_escreve_clob('</crps681>');
          --  Salvar copia relatorio para "/rlnsv"
          IF pr_nmtelant = 'COMPEFORA' THEN
            vr_dircop_rlnsv := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                    ,pr_cdcooper => pr_cdcooper
                                                    ,pr_nmsubdir => 'rlnsv');
          ELSE
            vr_dircop_rlnsv := NULL;
          END IF;

          -- Submeter o relatório 675
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                     ,pr_dtmvtolt  => vr_dtmvtolt                          --> Data do movimento atual
                                     ,pr_dsxml     => vr_xml_clobxml                       --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crps681/devolvidos'                --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl675.jasper'                     --> Arquivo de layout do iReport
                                     ,pr_dsparams  => null                                 --> Sem parâmetros
                                     ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl675_'||to_char(ind,'FM00')||'.lst' --> Arquivo final com o path
                                     ,pr_qtcoluna  => 132                                  --> 132 colunas
                                     ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                     ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => '132col'                             --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 1                                    --> Número de cópias
                                     ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                     ,pr_dspathcop => vr_dircop_rlnsv                      --> Copiar ao caminho passado
                                     ,pr_des_erro  => vr_des_saida);                       --> Saída com erro
          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_xml_clobxml);
          dbms_lob.freetemporary(vr_xml_clobxml);
        END;
      END IF; -- Se encontrou linhas no arquivo
      vr_typ_saida :=  NULL;
      -- Move o arquivo lido para o diretório salvar
      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_diretori||'/'||vr_vet_arquivos(ind)||' '||vr_nom_direto||'/salvar'
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_saida);

      IF vr_typ_saida = 'ERR' THEN
         vr_dscritic := 'Nao foi possivel mover arquivo integra/'||vr_vet_arquivos(ind)||' ao diretório Salvar: ' || vr_des_saida;
         RAISE vr_exc_saida;
      ELSE
        -- Cria um log de execução
        pr_cdcritic := 190; -- "190 - ARQUIVO INTEGRADO COM SUCESSO"
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        -- Gerar Log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 1, -- Processo normal
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || pr_dscritic
                                                         || ' - Arquivo: integra/' || vr_vet_arquivos(ind));
        pr_cdcritic := 0;
        pr_dscritic := NULL;
        -- Efetuar gravação a cada arquivo movido
        COMMIT;
      END IF;
    END LOOP; -- Fim varredura vr_vet_arquivos
    
    -- se existe informaçao para enviar por email
    IF vr_conteudo IS NOT NULL THEN
      --Enviar Email
      GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper    --> Cooperativa conectada
                                ,pr_cdprogra        => vr_cdprogra    --> Programa conectado
                                ,pr_des_destino     => vr_email_dest  --> Um ou mais detinatários separados por ';' ou ','
                                ,pr_des_assunto     => 'Ocorrencias '||upper(vr_cdprogra)||' - '|| rw_crapprg.dsprogra --> Assunto do e-mail
                                ,pr_des_corpo       => vr_conteudo    --> Corpo (conteudo) do e-mail
                                ,pr_des_anexo       => NULL           --> Um ou mais anexos separados por ';' ou ','
                                ,pr_flg_enviar      => 'N'            --> Enviar o e-mail na hora
                                ,pr_flg_log_batch   => 'N'            --> Incluir inf. no log
                                ,pr_des_erro        => vr_dscritic);  --> Descricao Erro
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        vr_cdcritic:= 0;
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
    END IF;
    
  END IF;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informacoes no banco de dados
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
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
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
END pc_crps681;
/
