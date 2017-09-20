CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS541(
                                   pr_cdcooper  IN craptab.cdcooper%TYPE
                                  ,pr_nmtelant  IN VARCHAR2 DEFAULT NULL
                                  ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                  ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                  ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  ,pr_dscritic OUT VARCHAR2)  IS

/* .............................................................................

   Programa: PC_CRPS541                    Antigo: Fontes/crps541.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Novembro/2009.                      Ultima atualizacao: 01/09/2017

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Integrar arquivos de devolucao de DOC'S Nossa Remessa - ABBC.
               Emite relatorio crrl525.

   Alteracoes: 07/06/2010 - Alteracao na identificao do reg. de controle (Ze).

               16/06/2010 - Inclusao do campo gncptit.dtliquid (Ze).

               23/06/2010 - Acertos Gerais (Ze).

               06/07/2010 - Incluso Validacao para COMPEFORA (Jonatas/Supero)

               03/08/2010 - Acerto no campo w_relato.nrcpfcgc (Vitor).

               08/09/2010 - Ajuste no relatorio (Ze).

               13/09/2010 - Acerto p/ gerar relatorio no diretorio rlnsv
                            (Vitor)

               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop
                            na leitura e gravacao dos arquivos (Elton).

               29/07/2011 - Ajuste na data de pesquisa do gncpdoc (Ze).

               03/11/2011 - Tentativa para solucionar erro na integracao
                            na conta-corrente na CECRED (Ze).

               03/09/2013 - Conversão Progress >> Oracle PL/SQL (Renato - Supero).

               24/10/2013 - Copiar relatorio para o diretorio rlnsv quando a tela
                            for a COMPEFORA (Douglas Pagel).

               25/11/2013 - Limpar parametros de saida de critica no caso da
                            exceção vr_exc_fimprg (Marcos-Supero)

               05/12/2013 - Implementar nova metodologia de listagem de arquivos (Petter - Supero).

               19/06/2014 - Inserido a criação dos lancamentos para o lote
                            10131 banco 85 - Projeto automatiza compe
                            (Tiago/Aline).       
                            
               17/09/2014 - Incluir tratamentos para incorporação Concredi pela Via
                            e Credimilsul pela SCRCred (Marcos-Supero)                               

               31/08/2015 - Projeto para tratamento dos programas que geram 
                            criticas que necessitam de lancamentos manuais 
                            pela contabilidade. (Jaison/Marcos-Supero)

			   07/10/2016 - Alteração do diretório para geração de arquivo contábil.
                            P308 (Ricardo Linhares). 

			   13/10/2016 - Alterada leitura da tabela de parâmetros para utilização
							da rotina padrão. (Rodrigo)

               01/09/2017 - SD737676 - Para evitar duplicidade devido o Matera mudar
			               o nome do arquivo apos processamento, iremos gerar o arquivo
						   _Criticas com o sufixo do crrl gerado por este (Marcos-Supero)

............................................................................. */

  -- CURSORES
  -- Buscar informações da cooperativa
  CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT cop.cdcooper
          ,cop.dsdircop
          ,LPAD(cop.cdbcoctl,3,0)         cdbcoctl
          ,to_char(cop.cdagectl,'FM0000') cdagectl
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop        cr_crapcop%ROWTYPE;
  rw_crapcop_incorp cr_crapcop%ROWTYPE;     
  
  -- Selecionar Transferencias entre cooperativas
  CURSOR cr_craptco(pr_cdcopant IN craptco.cdcopant%TYPE
                   ,pr_nrctaant IN craptco.nrctaant%TYPE) IS
    SELECT tco.nrdconta
      FROM craptco tco
     WHERE tco.cdcopant = pr_cdcopant
       AND tco.nrctaant = pr_nrctaant
       AND tco.tpctatrf = 1;
  vr_nrdconta_incorp craptco.nrdconta%TYPE;

  -- Buscar compensação de cheque devolvido
  CURSOR cr_gncpdoc(pr_cdcooper    gncpdoc.cdcooper%TYPE
                   ,pr_dtmvtolt    gncpdoc.dtmvtolt%TYPE
                   ,pr_nrdconta    gncpdoc.nrdconta%TYPE
                   ,pr_tpdoctrf    gncpdoc.tpdoctrf%TYPE
                   ,pr_nrdocmto    gncpdoc.nrdocmto%TYPE
                   ,pr_vldocmto    gncpdoc.vldocmto%TYPE ) IS
    SELECT gncpdoc.rowid    gncpdoc_rowid
      FROM gncpdoc
     WHERE gncpdoc.cdcooper = pr_cdcooper
       AND gncpdoc.dtmvtolt = pr_dtmvtolt
       AND gncpdoc.cdtipreg = 2   /* Nossa Remessa */
       AND gncpdoc.nrdconta = pr_nrdconta
       AND gncpdoc.tpdoctrf = pr_tpdoctrf
       AND gncpdoc.nrdocmto = pr_nrdocmto
       AND gncpdoc.vldocmto = pr_vldocmto
     ORDER BY gncpdoc.progress_recid DESC;
  rw_gncpdoc        cr_gncpdoc%ROWTYPE;


  -- cursor de capas de lote
  CURSOR cr_craplot (pr_cdcooper  IN craplrg.cdcooper%TYPE      --> Código cooperativa
                    ,pr_dtmvtolt  IN craplrg.dtresgat%TYPE      --> Data movimento atual
                    ,pr_cdagenci  IN craplap.cdagenci%TYPE      --> código agência
                    ,pr_cdbccxlt  IN craplap.cdbccxlt%TYPE      --> Código caixa/banco
                    ,pr_nrdolote  IN craplap.nrdolote%TYPE) IS  --> Número do lote
    SELECT lot.nrseqdig
          ,ROWID
     FROM craplot lot
    WHERE lot.cdcooper = pr_cdcooper
      AND lot.dtmvtolt = pr_dtmvtolt
      AND lot.cdagenci = pr_cdagenci
      AND lot.cdbccxlt = pr_cdbccxlt
      AND lot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;  

  --Selecionar informacoes dos lancamentos na conta
  CURSOR cr_craplcm (pr_cdcooper craplcm.cdcooper%TYPE
                    ,pr_dtmvtolt craplcm.dtmvtolt%TYPE
                    ,pr_cdagenci craplcm.cdagenci%TYPE
                    ,pr_cdbccxlt craplcm.cdbccxlt%TYPE
                    ,pr_nrdolote craplcm.nrdolote%TYPE
                    ,pr_nrdctabb craplcm.nrdctabb%TYPE
                    ,pr_nrdocmto craplcm.nrdocmto%TYPE) IS
    SELECT /*+ INDEX (craplcm craplcm##craplcm1) */
          craplcm.vllanmto
     FROM craplcm craplcm
    WHERE cdcooper = pr_cdcooper
      AND dtmvtolt = pr_dtmvtolt
      AND cdagenci = pr_cdagenci
      AND cdbccxlt = pr_cdbccxlt
      AND nrdolote = pr_nrdolote
      AND nrdctabb = pr_nrdctabb
      AND nrdocmto = pr_nrdocmto;
  rw_craplcm cr_craplcm%ROWTYPE;
  
  -- Tipo e tabela temporária para o relatório
  TYPE typ_reg_relato
    IS RECORD (dtmvtolt gncpdoc.dtmvtolt%TYPE
              ,nrcctrcb gncpdoc.nrcctrcb%TYPE
              ,nrdocmto gncpdoc .nrdocmto%TYPE
              ,vldocmto gncpdoc.vldocmto%TYPE
              ,nmpesemi gncpdoc .nmpesemi%TYPE
              ,nrdconta gncpdoc.nrdconta%TYPE
              ,tpdoctrf gncpdoc.tpdoctrf%TYPE
              ,cdcmpchq gncpdoc .cdcmpchq%TYPE
              ,cdbccrcb gncpdoc.cdbccrcb%TYPE
              ,cdagercb gncpdoc.cdagercb%TYPE
              ,dvagenci gncpdoc.dvagenci%TYPE
              ,nmpesrcb gncpdoc.nmpesrcb%TYPE
              ,cpfcgrcb gncpdoc.cpfcgrcb%TYPE
              ,tpdctacr gncpdoc.tpdctacr%TYPE
              ,cdfinrcb gncpdoc.cdfinrcb%TYPE
              ,cpfcgemi gncpdoc.cpfcgemi%TYPE
              ,tpdctadb gncpdoc.tpdctadb%TYPE
              ,nrseqarq gncpdoc.nrseqarq%TYPE
              ,cdmotdev gncpdoc.cdmotdev%TYPE
              ,dslancto VARCHAR2(3)
              ,dsobserv VARCHAR2(15));
  TYPE typ_relato  
    IS TABLE OF typ_reg_relato
      INDEX BY BINARY_INTEGER;
  -- Tipo para armazenar a lista de arquivos
  TYPE typ_arquivo 
    IS TABLE OF VARCHAR2(1000) 
      INDEX BY BINARY_INTEGER;
  
  -- VARIÁVEIS
  -- Código do programa
  vr_cdprogra      VARCHAR2(10);
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;
  vr_dtmvtoan      crapdat.dtmvtoan%TYPE;
  vr_dtmvtaux      crapdat.dtmvtolt%TYPE;
  -- Variável de erros
  vr_des_erro      VARCHAR2(4000);
  -- Diretórios
  vr_diretori      VARCHAR2(200);
  vr_nom_direto    VARCHAR2(200);
  vr_dircop_rlnsv  VARCHAR2(200);
  -- Registros de arquivos
  vr_array_arquivo GENE0002.typ_split;
  vr_arquivo       typ_arquivo;
  vr_relato        typ_relato;
  -- Indice para o registro relato
  vr_inrelato      NUMBER;
  -- Validação de erros
  vr_typ_saida     VARCHAR2(100);
  vr_des_saida     VARCHAR2(2000);
  -- Arquivo lido
  vr_utlfileh      UTL_FILE.file_type;
  -- Índice para a linha do arquivo
  vr_nrlinha       NUMBER;
  
  -- Tratamento de erros
  vr_exc_saida      EXCEPTION;
  vr_exc_fimprg     EXCEPTION;
  -- Lista de arquivos da coop conectada 
  vr_listarq        VARCHAR2(32767);
  -- Lista de arquivos da coop integrada
  vr_listarq_incorp VARCHAR2(32767);
  -- Flag para guardar teste de arquivo de coop incorporada
  vr_flarqincorp BOOLEAN;
  
  vr_dircon VARCHAR2(200);
  vr_arqcon VARCHAR2(200);
  vc_dircon CONSTANT VARCHAR2(30) := 'arquivos_contabeis/ayllos'; 
  vc_cdacesso CONSTANT VARCHAR2(24) := 'ROOT_SISTEMAS';
  vc_cdtodascooperativas INTEGER := 0;
  
  vr_dstextab		craptab.dstextab%TYPE;  

BEGIN

  -- Código do programa
  vr_cdprogra := 'CRPS541';
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

  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra,
                             pr_action => NULL);

  -- Buscar os dados da cooperativa
  OPEN  cr_crapcop(pr_cdcooper);
  FETCH cr_crapcop INTO rw_crapcop;
  -- Se não encontrar registros
  IF cr_crapcop%NOTFOUND THEN
    pr_cdcritic := 651;
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    CLOSE cr_crapcop;
    RAISE vr_exc_saida;
  END IF;
  CLOSE cr_crapcop;
  
  -- Buscar informações das Cooperativas Incorporadas a 
  -- Viacredi (Concredi) e ScrCred (Credimilsul)
  IF pr_cdcooper IN(1,13) THEN
    -- Buscar informações da cooperativa Incorporada
    IF pr_cdcooper = 1 THEN
      OPEN cr_crapcop(4); --> Concredi
    ELSE
      OPEN cr_crapcop(15); --> CredimilSul
    END IF;  
    -- Buscar informações da mesma
    FETCH cr_crapcop INTO rw_crapcop_incorp;
    CLOSE cr_crapcop;
  END IF;

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
    -- Usamos o dia anterior
    vr_dtmvtaux := vr_dtmvtoan;
    -- Retornar ultimo dia util anterior a data anterior ao processo
    vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => vr_dtmvtoan
                                              ,pr_tipo     => 'A');
  ELSE
    -- Usarmos o dia atual
    vr_dtmvtaux := vr_dtmvtolt;
  END IF;

  -- Busca do diretório base da cooperativa para a geração de relatórios
  vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper);

  -- Define o diretório dos arquivos
  vr_diretori := vr_nom_direto || '/integra/';

  -- Retorna um array com todos os arquivos do diretório
  gene0001.pc_lista_arquivos(pr_path      => vr_diretori
                            ,pr_pesq      => '3'||rw_crapcop.cdagectl||'%.DVN'
                            ,pr_listarq   => vr_listarq
                            ,pr_des_erro  => pr_dscritic);

  -- Verifica se ocorreram erros no processo de listagem de arquivos
  IF pr_dscritic IS NOT NULL THEN
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 2, -- Erro tratato
                               pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' || pr_dscritic );
  END IF;
  
  -- Se houver cooperativa incorporadas
  IF rw_crapcop_incorp.cdcooper IS NOT NULL THEN
    -- Executar rotina para listar os arquivos da pasta
    gene0001.pc_lista_arquivos(pr_path     => vr_diretori
                              ,pr_pesq     => '3'||rw_crapcop_incorp.cdagectl||'%.DVN'
                              ,pr_listarq  => vr_listarq_incorp
                              ,pr_des_erro => pr_dscritic);
    -- Verifica se ocorreram erros no processo de listagem de arquivos
    IF pr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' || pr_dscritic );
    END IF;
    -- Se encontrar algo
    IF TRIM(vr_listarq_incorp) IS NOT NULL THEN
      -- Se existe lista da coop conectada
      IF TRIM(vr_listarq) IS NOT NULL THEN
        -- Concatenar as listas para trabalharmos como uma lógica única
        vr_listarq := vr_listarq||','||vr_listarq_incorp;
      ELSE
        -- Considerar apenas os arquivos incorporados
        vr_listarq := vr_listarq_incorp;
      END IF;  
    END IF;  
  END IF;
  
  -- Se retornou arquivos
  IF TRIM(vr_listarq) IS NOT NULL THEN
    -- Transforma em array com todos os arquivos da listagem
    vr_array_arquivo := gene0002.fn_quebra_string(pr_string => vr_listarq, pr_delimit => ',');
  END IF;
  
  -- Se não restarem arquivos
  IF vr_array_arquivo IS NULL OR vr_array_arquivo.count = 0 THEN
    pr_cdcritic := 182;
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    RAISE vr_exc_fimprg;
  ELSE
    -- Limpar o registro de memória para o relatório
    vr_relato.DELETE;
    
    -- Percorre todos os arquivos encontrados
    FOR ind IN vr_array_arquivo.first..vr_array_arquivo.last LOOP
      -- Pular se a nome estiver vazio
      CONTINUE WHEN trim(vr_array_arquivo(ind)) IS NULL;
      
      -- Se houver incorporação
      IF rw_crapcop_incorp.cdcooper IS NOT NULL THEN
        -- Guardar FLAG de arquivo de cooperativa incorporada 
        vr_flarqincorp := vr_array_arquivo(ind) LIKE '3'||rw_crapcop_incorp.cdagectl||'%.DVN';
      ELSE
        -- Arquivo atual não é incorporado
        vr_flarqincorp := FALSE;
      END IF;
      
      -- Abrir o arquivo em modo de leitura
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_diretori
                              ,pr_nmarquiv => vr_array_arquivo(ind)
                              ,pr_tipabert => 'R'
                              ,pr_utlfileh => vr_utlfileh
                              ,pr_des_erro => vr_des_erro);
      -- Verifica se houve erro ao abrir o arquivo
      IF vr_des_erro IS NOT NULL THEN
        pr_dscritic := vr_des_erro;
        RAISE vr_exc_saida;
      END IF;
      
      -- Limpar o registro de memória, Caso possua registros
      IF vr_arquivo.COUNT() > 0 THEN
        vr_arquivo.DELETE;
      END IF;

      -- Se o arquivo estiver aberto, percorre o mesmo e guarda todas as linhas
      -- em um registro de memória
      IF  utl_file.IS_OPEN(vr_utlfileh) THEN

        -- Ler todas as linhas do arquivo
        LOOP

          BEGIN
            -- Guarda todas as linhas do arquivo no array
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh --> Handle do arquivo aberto
                                        ,pr_des_text => vr_arquivo(vr_arquivo.count()+1)); --> Texto lido
          EXCEPTION
            WHEN no_data_found THEN -- não encontrou mais linhas
              EXIT;
            WHEN OTHERS THEN
              vr_des_erro := 'Erro arquivo ['||vr_array_arquivo(ind)||']: '||SQLERRM;
              pr_dscritic := vr_des_erro;
              RAISE vr_exc_saida;
          END;
        END LOOP;

        -- Fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh); --> Handle do arquivo aberto;
      END IF;

      -- Remover as linhas em branco do arquivo
      -- Enquanto a ultima linha possuir menos de 100 posições
      WHILE (length(vr_arquivo(vr_arquivo.last())) < 100 AND vr_arquivo.COUNT() > 0) LOOP
        -- Exclui a ultima linha lida no arquivo
        vr_arquivo.delete(vr_arquivo.last());
      END LOOP;

      -- Se encontrou linhas no arquivo
      IF vr_arquivo.count() > 0 THEN

        -- Verifica se o arquivo está completo
        IF SUBSTR(vr_arquivo(vr_arquivo.last()),1,10) <> '9999999999' THEN
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

        END IF; -- Se ultima linha diferente de '9999999999'

        -- Inicializa
        pr_cdcritic := 0;

        -- Valida o arquivo, conforme informações da primeira linha
        IF    SUBSTR(vr_arquivo(vr_arquivo.first()),1,10) <> '0000000000'    THEN
          pr_cdcritic := 468;  -- 468 - Tipo de registro errado.
        ELSIF SUBSTR(vr_arquivo(vr_arquivo.first()),21,06) <> 'DCR615'    THEN
          pr_cdcritic := 181;  -- 181 - Falta registro de controle no arquivo.
        ELSIF SUBSTR(vr_arquivo(vr_arquivo.first()),42,01) <> 2    THEN
          pr_cdcritic := 473;  -- 473 - Codigo de remessa invalido.
        ELSIF SUBSTR(vr_arquivo(vr_arquivo.first()),27,03) <> rw_crapcop.cdbcoctl THEN
          pr_cdcritic := 057;  -- 057 - BANCO NAO CADASTRADO.
        ELSIF SUBSTR(vr_arquivo(vr_arquivo.first()),31,08) <> to_char(vr_dtmvtaux,'YYYYMMDD') THEN
          pr_cdcritic := 013;  -- 013 - Data errada.
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

        -- Cria um log de execução
        pr_cdcritic := 219; -- "219 - INTEGRANDO ARQUIVO"
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        -- Gerar Log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 1, -- Processo normal
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || pr_dscritic||' - Arquivo: '
                                                         || vr_diretori||vr_array_arquivo(ind));

        pr_cdcritic := 0;
        pr_dscritic := NULL;

        -- Aponta para a segunda linha
        vr_nrlinha := vr_arquivo.next(vr_arquivo.first());

        -- Percorrer as linhas do arquivo
        LOOP

          -- Se encontrar a linha de finalização do arquivo
          EXIT WHEN SUBSTR(vr_arquivo(vr_nrlinha),1,10) = '9999999999';

          -- Define o indice para o relato
          vr_inrelato := NVL(vr_relato.count(),0) + 1;          

          BEGIN
            -- Extrair os dados da linha do arquivo
            vr_relato(vr_inrelato).cdbccrcb := TO_NUMBER(SUBSTR(vr_arquivo(vr_nrlinha),4,3));
            vr_relato(vr_inrelato).cdagercb := SUBSTR(vr_arquivo(vr_nrlinha),7,4);
            vr_relato(vr_inrelato).dvagenci := SUBSTR(vr_arquivo(vr_nrlinha),11,1);
            vr_relato(vr_inrelato).nrcctrcb := TO_NUMBER(SUBSTR(vr_arquivo(vr_nrlinha),12,13));
            vr_relato(vr_inrelato).nrdocmto := TO_NUMBER(SUBSTR(vr_arquivo(vr_nrlinha),25,6));
            vr_relato(vr_inrelato).vldocmto := TO_NUMBER(SUBSTR(vr_arquivo(vr_nrlinha),31,18)) / 100;
            vr_relato(vr_inrelato).nmpesrcb := SUBSTR(vr_arquivo(vr_nrlinha),49,40);
            vr_relato(vr_inrelato).cpfcgrcb := TO_NUMBER(SUBSTR(vr_arquivo(vr_nrlinha),89,14));
            vr_relato(vr_inrelato).tpdctacr := TO_NUMBER(SUBSTR(vr_arquivo(vr_nrlinha),103,2));
            vr_relato(vr_inrelato).cdfinrcb := TO_NUMBER(SUBSTR(vr_arquivo(vr_nrlinha),105,2));
            vr_relato(vr_inrelato).cdcmpchq := TO_NUMBER(SUBSTR(vr_arquivo(vr_nrlinha),118,3));
            vr_relato(vr_inrelato).nrdconta := TO_NUMBER(SUBSTR(vr_arquivo(vr_nrlinha),134,8));
            vr_relato(vr_inrelato).nmpesemi := SUBSTR(vr_arquivo(vr_nrlinha),142,40);
            vr_relato(vr_inrelato).cpfcgemi := TO_NUMBER(SUBSTR(vr_arquivo(vr_nrlinha),182,14));
            vr_relato(vr_inrelato).tpdctadb := TO_NUMBER(SUBSTR(vr_arquivo(vr_nrlinha),196,2));
            vr_relato(vr_inrelato).tpdoctrf := SUBSTR(vr_arquivo(vr_nrlinha),203,1);
            vr_relato(vr_inrelato).dtmvtolt := TO_DATE(SUBSTR(vr_arquivo(vr_nrlinha),215,08), 'YYYYMMDD');
            vr_relato(vr_inrelato).nrseqarq := TO_NUMBER(SUBSTR(vr_arquivo(vr_nrlinha),248,8));
            vr_relato(vr_inrelato).cdmotdev := TO_NUMBER(SUBSTR(vr_arquivo(vr_nrlinha),239,2));
            vr_relato(vr_inrelato).dslancto := 'NAO';
            
            -- Se for um arquivo incorporado
            IF vr_flarqincorp THEN
              -- Buscaremos a conta nova com base na antiga do arquivo
              OPEN cr_craptco(pr_cdcopant => rw_crapcop_incorp.cdcooper
                             ,pr_nrctaant => vr_relato(vr_inrelato).nrdconta); 
              FETCH cr_craptco
               INTO vr_nrdconta_incorp;
              -- Se não encontrar  
              IF cr_craptco%NOTFOUND THEN
                -- Critica 9 - Ass não encontrado
                CLOSE cr_craptco;
                RAISE vr_exc_saida; 
              ELSE
                -- Substituiremos pelo código da nova conta 
                CLOSE cr_craptco;
                vr_relato(vr_inrelato).nrdconta := vr_nrdconta_incorp;
                -- Adicionar observação
                vr_relato(vr_inrelato).dsobserv := substr('Ass.'||upper(rw_crapcop_incorp.dsdircop),1,15);
              END IF;  
            END IF;
            
          EXCEPTION
            WHEN vr_exc_saida THEN
              -- Cria um log de erro
              pr_cdcritic := 9; -- 9 - Associado não encontrado
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) || ' - LINHA: '||to_char(vr_nrlinha)|| ' - Ass. '||upper(rw_crapcop_incorp.dsdircop);
              -- Gerar Log
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, -- Erro tratado
                                         pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                               || vr_cdprogra || ' --> '
                                                               || pr_dscritic);
              pr_cdcritic := 0;
              pr_dscritic := NULL;

              -- Próxima linha do arquivo
              vr_nrlinha := vr_arquivo.next(vr_nrlinha);

              CONTINUE;
            
            WHEN OTHERS THEN
              -- Cria um log de erro
              pr_cdcritic := 843; -- 843 - Funcao com caracteres invalido
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) || ' - LINHA: '||to_char(vr_nrlinha);
              -- Gerar Log
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, -- Erro tratado
                                         pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                               || vr_cdprogra || ' --> '
                                                               || pr_dscritic);
              pr_cdcritic := 0;
              pr_dscritic := NULL;

              -- Próxima linha do arquivo
              vr_nrlinha := vr_arquivo.next(vr_nrlinha);

              CONTINUE;
          END;
          
          -- Buscar dados da devolução
          OPEN  cr_gncpdoc(pr_cdcooper                       -- pr_cdcooper
                          ,vr_dtmvtoan                       -- pr_dtmvtolt
                          ,vr_relato(vr_inrelato).nrdconta   -- pr_nrdconta
                          ,vr_relato(vr_inrelato).tpdoctrf   -- pr_tpdoctrf
                          ,vr_relato(vr_inrelato).nrdocmto   -- pr_nrdocmto
                          ,vr_relato(vr_inrelato).vldocmto); -- pr_vldocmto
          FETCH cr_gncpdoc INTO rw_gncpdoc;

          -- Se encontrar o registro
          IF cr_gncpdoc%FOUND THEN

            BEGIN

              -- Atualiza o registro
              UPDATE gncpdoc
                 SET cdmotdev = nvl(vr_relato(vr_inrelato).cdmotdev,0)
                   , flgconci = 1 -- TRUE
                   , dtliquid = vr_dtmvtolt
                   , flgpcctl = 0 -- FALSE
               WHERE ROWID    = rw_gncpdoc.gncpdoc_rowid;

            EXCEPTION
              WHEN OTHERS THEN
                -- Monta descricão do erro
                pr_dscritic := 'Erro ao atualizar gncpdoc: '||SQLERRM;
                -- Envio centralizado de log de erro
                RAISE vr_exc_saida;
            END;

          ELSE

            -- Insere um novo registro
            BEGIN
              INSERT INTO gncpdoc(dtliquid
                                 ,cdcooper
                                 ,cdagenci
                                 ,dtmvtolt
                                 ,cdcmpchq
                                 ,cdbccrcb
                                 ,cdagercb
                                 ,dvagenci
                                 ,nrcctrcb
                                 ,nrdocmto
                                 ,vldocmto
                                 ,nmpesrcb
                                 ,cpfcgrcb
                                 ,tpdctacr
                                 ,cdfinrcb
                                 ,cdagectl
                                 ,nrdconta
                                 ,nmpesemi
                                 ,cpfcgemi
                                 ,tpdctadb
                                 ,tpdoctrf
                                 ,qtdregen
                                 ,nmarquiv
                                 ,cdoperad
                                 ,hrtransa
                                 ,cdtipreg
                                 ,flgconci
                                 ,nrseqarq
                                 ,cdcritic
                                 ,cdmotdev
                                 ,flgpcctl)
                           VALUES(vr_dtmvtolt                                -- dtliquid
                                 ,nvl(pr_cdcooper,0)                         -- cdcooper
                                 ,0                                          -- cdagenci
                                 ,vr_dtmvtoan                                -- dtmvtolt
                                 ,nvl(vr_relato(vr_inrelato).cdcmpchq,0)     -- cdcmpchq
                                 ,nvl(vr_relato(vr_inrelato).cdbccrcb,0)     -- cdbccrcb
                                 ,nvl(vr_relato(vr_inrelato).cdagercb,0)     -- cdagercb
                                 ,nvl(vr_relato(vr_inrelato).dvagenci,' ')   -- dvagenci
                                 ,nvl(vr_relato(vr_inrelato).nrcctrcb,0)     -- nrcctrcb
                                 ,nvl(vr_relato(vr_inrelato).nrdocmto,0)     -- nrdocmto
                                 ,nvl(vr_relato(vr_inrelato).vldocmto,0)     -- vldocmto
                                 ,nvl(vr_relato(vr_inrelato).nmpesrcb,' ')   -- nmpesrcb
                                 ,nvl(vr_relato(vr_inrelato).cpfcgrcb,0)     -- cpfcgrcb
                                 ,nvl(vr_relato(vr_inrelato).tpdctacr,0)     -- tpdctacr
                                 ,nvl(vr_relato(vr_inrelato).cdfinrcb,0)     -- cdfinrcb
                                 ,nvl(rw_crapcop.cdagectl,0)                 -- cdagectl
                                 ,nvl(vr_relato(vr_inrelato).nrdconta,0)     -- nrdconta
                                 ,nvl(vr_relato(vr_inrelato).nmpesemi,' ')   -- nmpesemi
                                 ,nvl(vr_relato(vr_inrelato).cpfcgemi,0)     -- cpfcgemi
                                 ,nvl(vr_relato(vr_inrelato).tpdctadb,0)     -- tpdctadb
                                 ,nvl(vr_relato(vr_inrelato).tpdoctrf,0)     -- tpdoctrf
                                 ,0                                          -- qtdregen
                                 ,nvl(vr_array_arquivo(ind),' ')             -- nmarquiv
                                 ,'1'                                        -- cdoperad
                                 ,TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))        -- hrtransa
                                 ,2  /* Nossa Remessa */                     -- cdtipreg
                                 ,1                                          -- flgconci
                                 ,nvl(vr_relato(vr_inrelato).nrseqarq,0)     -- nrseqarq
                                 ,927                                        -- cdcritic
                                 ,nvl(vr_relato(vr_inrelato).cdmotdev,0)     -- cdmotdev
                                 ,0 );                                       -- flgpcctl

            EXCEPTION
              WHEN OTHERS THEN
                -- Monta descricão do erro
                pr_dscritic := 'Erro ao inserir gncpdoc: '||SQLERRM;
                -- Envio centralizado de log de erro
                RAISE vr_exc_saida;
            END;
          END IF;

          -- Fechar o cursor
          CLOSE cr_gncpdoc;

          -- Só realizar lancamento se o numero de conta for maior que zero
          IF nvl(vr_relato(vr_inrelato).nrdconta,0) > 0 THEN
            -- Se ainda não foi encontrado o Rowid do CrapLOT
            IF rw_craplot.rowid IS NULL THEN            
              -- Abre o cursor de capas de lote
              OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                              pr_dtmvtolt => vr_dtmvtolt,
                              pr_cdagenci => 1,
                              pr_cdbccxlt => 85,
                              pr_nrdolote => 10130);
              FETCH cr_craplot INTO rw_craplot;
              IF cr_craplot%NOTFOUND THEN -- Se nao existir insere a capa de lote
                BEGIN
                  INSERT INTO craplot
                    (dtmvtolt,
                     dtmvtopg,
                     cdagenci,
                     cdbccxlt,
                     cdoperad,
                     nrdolote,
                     tplotmov,
                     tpdmoeda,
                     cdhistor,
                     cdcooper,
                     nrseqdig)
                  VALUES
                    (vr_dtmvtolt,
                     vr_relato(vr_inrelato).dtmvtolt,
                     1,
                     85,
                     '1',
                     10130,
                     24,
                     1,
                     766,
                     pr_cdcooper,
                     0)
                   RETURNING ROWID,nrseqdig INTO rw_craplot.rowid, rw_craplot.nrseqdig;
                EXCEPTION
                  WHEN OTHERS THEN
                    pr_dscritic := 'Erro ao inserir CRAPLOT: ' ||SQLERRM;
                    RAISE vr_exc_saida;
                END;
              END IF;
              CLOSE cr_craplot;
            END IF;  

            -- Atualiza a tabela de capas de lote
            BEGIN
              UPDATE craplot
                 SET nrseqdig = nrseqdig + 1,
                     qtcompln = qtcompln + 1,
                     qtinfoln = qtinfoln + 1,
                     vlcompdb = vlcompdb + vr_relato(vr_inrelato).vldocmto,
                     vlcompcr = 0,
                     vlinfodb = vlcompdb + vr_relato(vr_inrelato).vldocmto,
                     vlinfocr = 0
               WHERE ROWID = rw_craplot.rowid
               RETURNING nrseqdig INTO rw_craplot.nrseqdig; --> Atualizar nrseqdig para insert na lcm
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao atualizar CRAPLOT: ' ||SQLERRM;
            END;

            -- Verificar existÊncia do lançamento em conta
            OPEN cr_craplcm(pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => vr_dtmvtolt
                           ,pr_cdagenci => 1
                           ,pr_cdbccxlt => 85
                           ,pr_nrdolote => 10130
                           ,pr_nrdctabb => nvl(vr_relato(vr_inrelato).nrdconta,0)
                           ,pr_nrdocmto => nvl(vr_relato(vr_inrelato).nrdocmto,0));
            FETCH cr_craplcm INTO rw_craplcm;
            
            -- Se nao existir insere lancamento
            IF cr_craplcm%NOTFOUND THEN 
              -- insere a devdoc na tabela de lancamentos
              BEGIN
                INSERT INTO craplcm
                  (dtmvtolt,
                   cdagenci,
                   cdbccxlt,
                   nrdolote,
                   nrdconta,
                   nrdocmto,
                   cdhistor,
                   nrseqdig,
                   vllanmto,
                   nrdctabb,
                   nrdctitg,
                   cdcooper,
                   dtrefere,
                   cdoperad)
                VALUES
                  (vr_dtmvtolt,                                       --dtmvtolt
                   1,                                                 --cdagenci            
                   85,                                                --cdbccxlt
                   10130,                                             --nrdolote
                   nvl(vr_relato(vr_inrelato).nrdconta,0),            --nrdconta
                   nvl(vr_relato(vr_inrelato).nrdocmto,0),            --nrdocmto
                   766,                                               --cdhistor  
                   nvl(rw_craplot.nrseqdig,0) + 1,                    --nrseqdig
                   vr_relato(vr_inrelato).vldocmto,                   --vllanmto  
                   nvl(vr_relato(vr_inrelato).nrdconta,0),            --nrdctabb  
                   gene0002.fn_mask(nvl(vr_relato(vr_inrelato).nrdconta,0),'99999999'),  --nrdctitg
                   pr_cdcooper,                                       --cdcooper
                   vr_dtmvtolt,                                       --dtrefere
                   '1');                                              --cdoperad
              EXCEPTION
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao inserir CRAPLCM: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
              -- Atualiza registro para indicar que ocorreu lançamento
              vr_relato(vr_inrelato).dslancto := 'SIM';  
            END IF;  
            
            CLOSE cr_craplcm;
          END IF;
          
          -- Se for a última linha a ser lida do arquivo
          EXIT WHEN vr_nrlinha = vr_arquivo.last;
          vr_nrlinha := vr_arquivo.next(vr_nrlinha); -- Próximo
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
                                                         || ' - Arquivo: integra/' || vr_array_arquivo(ind));
        pr_cdcritic := 0;
        pr_dscritic := NULL;

      END IF; -- Se encontrou linhas no arquivo

      /* Move o arquivo lido para o diretório salvar */
      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_diretori||vr_array_arquivo(ind)||' '||vr_nom_direto||'/salvar 2> /dev/null'
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_saida);

      -- Efetuar commit a cada arquivo envio a pasta salvar
      COMMIT;
      
    END LOOP; -- Fim leitura vr_array_arquivo

    /*** RELATÓRIO ***/

    -- Se tem dados para o relatório
    IF vr_relato.count() > 0 THEN

      -- Montar o XML para o relatório e solicitar o mesmo
      DECLARE

        -- Variáveis locais do bloco
        -- Nome do arquivo
        vr_nmarquiv          VARCHAR2(50) := 'crrl525.lst';
        vr_xml_clobxml       CLOB;
        vr_xml_dscpfcgc      VARCHAR2(20);
        vr_clobcri           CLOB;

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
        pc_escreve_clob(vr_xml_clobxml,'<?xml version="1.0" encoding="utf-8"?><crps541 >');

        -- Preparar o CLOB para armazenar as infos do arquivo
        dbms_lob.createtemporary(vr_clobcri, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clobcri, dbms_lob.lob_readwrite);

        -- Percorre todos os registros retornados pelo cursor
        FOR ind IN vr_relato.first..vr_relato.last LOOP

          -- Se o campo de CPF e CGC for menor que 12 posições
          IF length(vr_relato(ind).cpfcgemi) < 12 THEN
            -- CPF
            vr_xml_dscpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_relato(ind).cpfcgemi
                                                        ,pr_inpessoa => 1);
          ELSE
            -- CNPJ
            vr_xml_dscpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_relato(ind).cpfcgemi
                                                        ,pr_inpessoa => 2);
          END IF;

          -- Adiciona a linha ao XML
          pc_escreve_clob(vr_xml_clobxml,'<devolucao>'
                                       ||'  <cddbanco>'||to_char(vr_relato(ind).cdbccrcb,'FM000')||'</cddbanco>'
                                       ||'  <cdagenci>'||to_char(vr_relato(ind).cdagercb,'FM0000')||'-'||vr_relato(ind).dvagenci||'</cdagenci>'
                                       ||'  <nrctades>'||vr_relato(ind).nrcctrcb||'</nrctades>'
                                       ||'  <nrdocmto>'||vr_relato(ind).nrdocmto||'</nrdocmto>'
                                       ||'  <vldocmto>'||to_char(vr_relato(ind).vldocmto,'FM9G999G999G990D00')||'</vldocmto>'
                                       ||'  <cdmotivo>'||to_char(vr_relato(ind).cdmotdev,'FM00')||'</cdmotivo>'
                                       ||'  <nmremete>'||SUBSTR(vr_relato(ind).nmpesemi,1,24)||'</nmremete>'
                                       ||'  <dscpfcgc>'||vr_xml_dscpfcgc||'</dscpfcgc>'
                                       ||'  <nrctarem>'||TRIM(gene0002.fn_mask(vr_relato(ind).nrdconta,'zzzz.zzz.9'))||'</nrctarem>'
                                       ||'  <dtmvtolt>'||to_char(vr_relato(ind).dtmvtolt,'DD/MM/YY')||'</dtmvtolt>'
                                       ||'  <flglanca>'||vr_relato(ind).dslancto||'</flglanca>'
                                       ||'  <dsobserv>'||vr_relato(ind).dsobserv||'</dsobserv>'
                                       ||'</devolucao>');

          -- Adiciona a linha ao arquivo de criticas
          pc_escreve_clob(vr_clobcri,'50' || TO_CHAR(vr_dtmvtolt,'DDMMRR') || ',' || TO_CHAR(vr_dtmvtolt,'DDMMRR') ||
                                     ',1455,4894,' || TO_CHAR(vr_relato(ind).vldocmto,'fm9999999990d00','NLS_NUMERIC_CHARACTERS=.,') ||
                                     ',157,"DEVOLUCAO RECEBIDA DOC (CONFORME CRITICA RELATORIO 525)"' || chr(10));
        END LOOP;

        -- Adiciona a linha ao XML
        pc_escreve_clob(vr_xml_clobxml,'</crps541>');
        
        -- Somente se solicitado pela COMPEFORA
        IF pr_nmtelant = 'COMPEFORA' THEN
          -- Armazenar diretório para cópia (RLNSV)
          vr_dircop_rlnsv:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsubdir => 'rlnsv');
        END IF;
      
        -- Submeter o relatório
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                   ,pr_dtmvtolt  => vr_dtmvtolt                          --> Data do movimento atual
                                   ,pr_dsxml     => vr_xml_clobxml                       --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crps541/devolucao'                 --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl525.jasper'                     --> Arquivo de layout do iReport
                                   ,pr_dsparams  => null                                 --> Sem parâmetros
                                   ,pr_dsarqsaid => vr_nom_direto||'/rl/'||vr_nmarquiv   --> Arquivo final com o path
                                   ,pr_qtcoluna  => 132                                  --> 132 colunas
                                   ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                   ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => '132col'                             --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1                                    --> Número de cópias
                                   ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                   ,pr_dspathcop => vr_dircop_rlnsv                      --> Cópia ao RLNSV somente na COMPEFORA
                                   ,pr_des_erro  => vr_des_erro);                        --> Saída com erro

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_xml_clobxml);
        dbms_lob.freetemporary(vr_xml_clobxml);

        -- Verifica se ocorreram erros na geração do XML
        IF vr_des_erro IS NOT NULL THEN

          pr_dscritic := vr_des_erro;

          -- Gerar exceção
          RAISE vr_exc_saida;
        END IF;

       -- Busca o diretório para contabilidade
        vr_dircon := gene0001.fn_param_sistema('CRED', vc_cdtodascooperativas, vc_cdacesso);
        vr_dircon := vr_dircon || vc_dircon;
        vr_arqcon := TO_CHAR(vr_dtmvtolt,'RRMMDD') ||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_CRITICAS_525.txt';

        -- Chama a geracao do TXT
        GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper              --> Cooperativa conectada
                                           ,pr_cdprogra  => vr_cdprogra              --> Programa chamador
                                           ,pr_dtmvtolt  => vr_dtmvtolt              --> Data do movimento atual
                                           ,pr_dsxml     => vr_clobcri               --> Arquivo XML de dados
                                           ,pr_dsarqsaid => vr_nom_direto || '/contab/' || vr_arqcon    --> Arquivo final com o path
                                           ,pr_cdrelato  => NULL                     --> Código fixo para o relatório
                                           ,pr_flg_gerar => 'N'                      --> Apenas submeter
                                           ,pr_dspathcop => vr_dircon
                                           ,pr_fldoscop  => 'S'                                           
                                           ,pr_des_erro  => vr_des_erro);            --> Saída com erro
                                           
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clobcri);
        dbms_lob.freetemporary(vr_clobcri);

        -- Verifica se ocorreram erros na geracao do TXT
        IF vr_des_erro IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> ERRO NA GERACAO DO ' || vr_arqcon || ': '
                                                     || vr_des_erro );
          END IF;                                    

      END;

    END IF;

  END IF;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  -- Gravação final
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
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;
END pc_crps541;
/

