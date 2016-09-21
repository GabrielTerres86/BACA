CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS034(pr_cdcooper  IN craptab.cdcooper%TYPE --> Cooperativa Solicitada
                                      ,pr_flgresta  IN PLS_INTEGER           --> Flag 0/1 para utilizar restart na chamada
                                      ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2)  IS         --> Texto de erro/critica encontrada
/* ..........................................................................

   Programa: PC_CRPS034                  Antigo: Fontes/crps034.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/92.                          Ultima atualizacao: 04/12/2013

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 004.
               Emite relatorio dos associados demitidos no mes (rel 033).

   Alteracoes: 03/04/95 - Alterado para incluir contador de contas excluidas
                          (Edson).

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               20/01/99 - Mudar relatorio para laser (Odair).

               29/12/1999 - Nao gerar mais pedido de impressao (Edson).

               11/02/2000 - Gerar pedido de impressao (Deborah).

               08/07/2005 - Incluidos novos campos no relatorio e geracao
                            de um arquivo para cada PAC (Evandro).

               13/09/2005 - Incluido o operador de demissao (Evandro).

               14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               22/01/2007 - Substituicao do formato das variaveis do tipo DATE
                            para "99/99/9999" (Elton).

               13/02/2007 - Concertado para disponibilizar relatorio na
                            Intranet (Diego).

               19/02/2007 - Alterado Termo Qtd.Associados Excluidos para
                            Demitidos (Mirtes)

               30/06/2008 - Incluida a chave de acesso (craphis.cdcooper =
                            glb_cdcooper) no "find".
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               14/07/2009 - Alteracao CDOPERAD (Diego).

               11/09/2013 - Conversão Progress >> Oracle PL/SQL (Renato - Supero).
                          - Alterado a nomenclatura de PAC para PA.

               08/10/2013 - Alteração nos tratamentos de critica e saídas
                            de rotinas ( Renato - Supero )

               18/11/2013 - Passagem de parâmetro para remover o relatório 99
                            após sua impressão (imprim.p) (Marcos-Supero)

               28/11/2013 - Ajustes nas variaveis tratadas durante a iniprg (Marcos-Supero)

               15/08/2013 - Nova forma de chamar as agências, de PAC agora
                            a escrita será PA (André Euzébio - Supero).

               28/10/2013 - Alterado totalizador de 99 para 999. (Reinert)

............................................................................. */

  -- CURSORES
  -- Buscar informações da cooperativa
  CURSOR cr_crapcop IS
    SELECT crapcop.dsdircop
         , LPAD(crapcop.cdbcoctl,3,0) cdbcoctl
         , crapcop.cdagectl
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;

  -- Buscar os dados dos demitidos
  CURSOR cr_crapass(pr_dtdemiss   DATE) IS
    SELECT crapass.cdagenci
         , crapass.inmatric
         , crapass.nrdconta
         , crapass.cdopedem
         , crapass.cdmotdem
         , crapass.nrmatric
         , crapass.nmprimtl
         , crapass.dtdemiss
         , COUNT(1) OVER (PARTITION BY crapass.cdagenci) totreg
         , ROW_NUMBER () OVER (PARTITION BY crapass.cdagenci ORDER BY crapass.cdagenci) nrseq
      FROM crapass
     WHERE crapass.cdcooper  = pr_cdcooper
       AND crapass.dtdemiss >= pr_dtdemiss
     ORDER BY crapass.cdagenci
            , crapass.nrdconta;

  -- Buscar as informações do PA
  CURSOR cr_crapage(pr_cdagenci crapage.cdagenci%TYPE) IS
    SELECT crapage.nmresage
      FROM crapage
     WHERE crapage.cdcooper = pr_cdcooper
       AND crapage.cdagenci = pr_cdagenci;

  -- Buscar dados para calcular o saldo capital no mês
  CURSOR cr_crapcot(pr_nrdconta  crapcot.nrdconta%TYPE
                   ,pr_inmes     NUMBER) IS
    SELECT decode(pr_inmes, 0, crapcot.vlcotant -- Se passar zero, deve puxar a conta anterior
                          , 1, crapcot.vlcapmes##1
                          , 2, crapcot.vlcapmes##2
                          , 3, crapcot.vlcapmes##3
                          , 4, crapcot.vlcapmes##4
                          , 5, crapcot.vlcapmes##5
                          , 6, crapcot.vlcapmes##6
                          , 7, crapcot.vlcapmes##7
                          , 8, crapcot.vlcapmes##8
                          , 9, crapcot.vlcapmes##9
                          ,10, crapcot.vlcapmes##10
                          ,11, crapcot.vlcapmes##11
                          ,12, crapcot.vlcapmes##12
                          , 0)  vlcapmes
      FROM crapcot
     WHERE crapcot.cdcooper = pr_cdcooper
       AND crapcot.nrdconta = pr_nrdconta;

  -- Busca todos os lançamentos de cotas e capitais
  CURSOR cr_craplct(pr_nrdconta  craplct.nrdconta%TYPE
                   ,pr_dtmvtolt  craplct.dtmvtolt%TYPE) IS
    SELECT craplct.cdhistor
         , craplct.vllanmto
      FROM craplct
     WHERE craplct.cdcooper             = pr_cdcooper
       AND craplct.nrdconta             = pr_nrdconta
       AND TRUNC(craplct.dtmvtolt,'MM') = TRUNC(pr_dtmvtolt,'MM');

  -- Buscar o indicador de debito ou credito do histórico do sistema
  CURSOR cr_craphis(pr_cdhistor  craphis.cdhistor%TYPE) IS
    SELECT indebcre
      FROM craphis
     WHERE craphis.cdcooper = pr_cdcooper
       AND craphis.cdhistor = pr_cdhistor;

  -- Buscar o operador da demissão
  CURSOR cr_crapope(pr_cdoperad  crapope.cdoperad%TYPE) IS
    SELECT crapope.nmoperad
      FROM crapope
     WHERE crapope.cdcooper = pr_cdcooper
       AND crapope.cdoperad = pr_cdoperad;

  -- REGISTROS
  rw_crapcop    cr_crapcop%ROWTYPE;
  rw_crapage    cr_crapage%ROWTYPE;

  -- TIPOS
  TYPE rec_demiss  IS RECORD(cdagenci     crapage.cdagenci%TYPE
                            ,dsagenci     VARCHAR2(50)
                            ,nrdconta     crapass.nrdconta%TYPE
                            ,nrmatric     crapass.nrmatric%TYPE
                            ,nmprimtl     crapass.nmprimtl%TYPE
                            ,vlcapmes     NUMBER
                            ,dtdemiss     crapass.dtdemiss%TYPE
                            ,dsoperad     VARCHAR2(100)
                            ,dsmotdem     VARCHAR2(200)
                            ,dsobserv     VARCHAR2(20)
                            ,induplic     NUMBER);
  TYPE typ_demiss  IS TABLE OF rec_demiss INDEX BY BINARY_INTEGER;

  -- VARIÁVEIS
  -- Código do programa
  vr_cdprogra      CONSTANT VARCHAR2(10) := 'CRPS034';
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;
  -- Data base para buscar as demissões
  vr_dtdemiss      crapdat.dtmvtolt%TYPE;
  -- Dados dos demitidos
  vr_tbdemiss      typ_demiss;
  vr_indemiss      NUMBER;
  -- Contadores do relatório
  vr_qtdtotal      NUMBER := 0;
  vr_qttotdup      NUMBER := 0;
  vr_qtexclui      NUMBER := 0;
  vr_vltotcap      NUMBER := 0;
  -- Valor
  vr_vlcapmes      NUMBER := 0;
  -- Indicador de debito ou credito do histórico do sistema
  vr_indebcre      craphis.indebcre%TYPE;
  -- Nome do operador da demissão
  vr_nmoperad      crapope.nmoperad%TYPE;
  -- Motivo de demissão
  vr_dsmotdem      craptab.dstextab%TYPE;
  -- Código e descrição de erros/criticas
  vr_cdcritic      NUMBER;
  vr_dscritic      VARCHAR2(4000);
  -- Variável de erros
  vr_des_erro      VARCHAR2(4000);
  -- Diretório
  vr_nom_direto    VARCHAR2(200);
  -- Descrição da data de referencia
  vr_dsrefere      VARCHAR2(20);
  -- Tratamento de erros
  vr_exc_saida     EXCEPTION;

BEGIN

  -- Validações iniciais do programa
  BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                            ,pr_flgbatch => 1 -- Fixo
                            ,pr_cdprogra => vr_cdprogra
                            ,pr_infimsol => pr_infimsol
                            ,pr_cdcritic => vr_cdcritic);

  -- Se retornou algum erro
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS034',
                             pr_action => vr_cdprogra);

  -- Buscar os dados da cooperativa
  OPEN  cr_crapcop;
  FETCH cr_crapcop INTO rw_crapcop;

  -- Se não encontrar registros
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor
    CLOSE cr_crapcop;
    -- Crítica
    pr_cdcritic := 651;
    -- Encerra programa
    RAISE vr_exc_saida;
  END IF;

  CLOSE cr_crapcop;

  -- Buscar a data do movimento
  OPEN  btch0001.cr_crapdat(pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;

  -- Se não encontrar o registro de movimento
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;

    -- 001 - Sistema sem data de movimento.
    pr_cdcritic := 1;

    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  ELSE
    -- Atribuir os valores as variáveis
    vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
    vr_dtdemiss := TRUNC(btch0001.rw_crapdat.dtmvtolt,'MM');
  END IF;

  CLOSE btch0001.cr_crapdat;

  -- Busca do diretório base da cooperativa para a geração de relatórios
  vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper);

  -- Chama a rotina sem passar o motivo de demissão para carregar o registro de memória
  CADA0001.pc_busca_motivo_demissao(pr_cdcooper => pr_cdcooper
                                   ,pr_cdmotdem => NULL
                                   ,pr_dsmotdem => vr_dsmotdem
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_des_erro => vr_dscritic);
  vr_dscritic := NULL;

  -- Leitura do cadastro selecionando os demitidos no mês
  FOR rw_crapass IN cr_crapass(vr_dtdemiss) LOOP

    -- Define o índice para o registro de memória
    vr_indemiss := vr_tbdemiss.COUNT() + 1;

    -- Guarda os dados para o relatório
    vr_tbdemiss(vr_indemiss).cdagenci := rw_crapass.cdagenci;
    vr_tbdemiss(vr_indemiss).nrdconta := rw_crapass.nrdconta;
    vr_tbdemiss(vr_indemiss).nrmatric := rw_crapass.nrmatric;
    vr_tbdemiss(vr_indemiss).nmprimtl := rw_crapass.nmprimtl;
    vr_tbdemiss(vr_indemiss).dtdemiss := rw_crapass.dtdemiss;

    -- Busca as informações do PA - Posto de Atendimento
    OPEN  cr_crapage(rw_crapass.cdagenci);
    FETCH cr_crapage INTO rw_crapage;

    -- Se encontrar registros
    IF cr_crapage%FOUND THEN
      -- Guardar a descrição do Posto de Atendimento - PA
      vr_tbdemiss(vr_indemiss).dsagenci := LPAD(rw_crapass.cdagenci,3,'0')||'-'||rw_crapage.nmresage;
    ELSE
      -- Guarda a descrição padrão para PA não encontrado
      vr_tbdemiss(vr_indemiss).dsagenci := LPAD(rw_crapass.cdagenci,3,'0')||'- *** PA NAO CADASTRADO ***';
    END IF;

    CLOSE cr_crapage;

    -- Se a matricula é original(1) ou duplic/transferida(2)
    IF rw_crapass.inmatric = 1 THEN
      vr_tbdemiss(vr_indemiss).dsobserv := NULL;
      vr_tbdemiss(vr_indemiss).induplic := 0;
      vr_qtdtotal := vr_qtdtotal + 1;
    ELSE
      vr_tbdemiss(vr_indemiss).dsobserv := 'MATR.DUPLIC.';
      vr_tbdemiss(vr_indemiss).induplic := 1;
      vr_qttotdup := vr_qttotdup + 1;
    END IF;

    vr_vlcapmes := 0;

    -- Calcular o saldo capital no mês (valor anterior + integralizacoes)
    OPEN  cr_crapcot(rw_crapass.nrdconta, (to_number(to_char(vr_dtmvtolt,'MM'))-1) );
    FETCH cr_crapcot INTO vr_vlcapmes;
    CLOSE cr_crapcot;

    -- Percorrer todos os lançamentos
    FOR rw_craplct IN cr_craplct(rw_crapass.nrdconta, vr_dtmvtolt) LOOP

      -- Busca a informação do historico
      OPEN  cr_craphis(rw_craplct.cdhistor);
      FETCH cr_craphis INTO vr_indebcre;
      -- Se encontrar registros
      IF cr_craphis%NOTFOUND THEN
        -- atribui null a variável
        vr_indebcre := NULL;
      END IF;
      CLOSE cr_craphis;

      -- Se buscou o indicador de crédito
      IF nvl(vr_indebcre,' ') = 'C' THEN
        vr_vlcapmes := NVL(vr_vlcapmes,0) + rw_craplct.vllanmto;
      END IF;

    END LOOP; -- cr_craplct

    -- Guarda o valor para o relatório
    vr_tbdemiss(vr_indemiss).vlcapmes := vr_vlcapmes;

    -- Quantidade de contas excluídas
    vr_qtexclui := vr_qtexclui + 1;
    -- Total do saldo capital
    vr_vltotcap := vr_vltotcap + vr_vlcapmes;

    -- Buscar o operador de demissão
    OPEN  cr_crapope(rw_crapass.cdopedem);
    FETCH cr_crapope INTO vr_nmoperad;

    -- Se não encontrar o operador
    IF cr_crapope%NOTFOUND THEN
      vr_tbdemiss(vr_indemiss).dsoperad := NULL;
    ELSE
      vr_tbdemiss(vr_indemiss).dsoperad := RPAD(rw_crapass.cdopedem,10, ' ')||'-'||vr_nmoperad;
    END IF;

    CLOSE cr_crapope;

    -- Buscar/montar o motivo da demissão
    CADA0001.pc_busca_motivo_demissao(pr_cdcooper => pr_cdcooper
                                     ,pr_cdmotdem => rw_crapass.cdmotdem
                                     ,pr_dsmotdem => vr_dsmotdem
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_des_erro => vr_des_erro);

    -- Guarda o motivo da demissão para o relatório
    vr_tbdemiss(vr_indemiss).dsmotdem := to_char(rw_crapass.cdmotdem,'fm00')||'-'||vr_dsmotdem;

  END LOOP; -- cr_crapass

  -- Monta data de referencia
  vr_dsrefere := GENE0001.vr_vet_nmmesano(TO_NUMBER(TO_CHAR(vr_dtmvtolt, 'MM')))||'/'||TO_CHAR(vr_dtmvtolt, 'YYYY');

  /*** RELATÓRIO ***/
  -- Se tem dados para o relatório
  IF vr_tbdemiss.count() > 0 THEN


    -- Montar o XML para o relatório e solicitar o mesmo
    DECLARE

      -- Variáveis locais do bloco
      -- Nome do arquivo
      vr_xml_clobpar       CLOB;
      vr_xml_clobgrl       CLOB;
      vr_xml_dsregis       VARCHAR2(32000);
      vr_xml_cdagaux       NUMBER;
      vr_xml_nmarqlst      VARCHAR2(20);

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;

    BEGIN

      -- Preparar os CLOBs para armazenar as infos dos arquivos
      -- Cria o CLOB geral
      dbms_lob.createtemporary(vr_xml_clobgrl, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_xml_clobgrl, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_xml_clobgrl,'<?xml version="1.0" encoding="utf-8"?>'||chr(13)||
                                     '<crps033 dsrefere="'||vr_dsrefere||'" >'||chr(13));

      -- Percorer todos os registros em memória
      FOR ind IN vr_tbdemiss.FIRST..vr_tbdemiss.LAST LOOP

        IF vr_tbdemiss.PRIOR(ind) IS NULL THEN
          vr_xml_cdagaux := -1;
        ELSE
          vr_xml_cdagaux := vr_tbdemiss(vr_tbdemiss.PRIOR(ind)).cdagenci;
        END IF;

        -- Se for o primeiro registro da agencia
        IF vr_tbdemiss(ind).cdagenci <> vr_xml_cdagaux THEN

          -- Cria o CLOB parcial
          dbms_lob.createtemporary(vr_xml_clobpar, TRUE, dbms_lob.CALL);
          dbms_lob.open(vr_xml_clobpar, dbms_lob.lob_readwrite);

          -- Escreve o cabeçalho do arquivo parcial
          pc_escreve_clob(vr_xml_clobpar,'<?xml version="1.0" encoding="utf-8"?>'||chr(13)||
                                         '<crps033 dsrefere="'||vr_dsrefere||'" >'||chr(13)||
                                         '  <agencia cdagenci="'||LPAD(vr_tbdemiss(ind).cdagenci,3,'0')||'"  '||
                                                   ' dsagenci="'||vr_tbdemiss(ind).dsagenci||'" >'||chr(13));

          -- Escreve a tag de abertura da agencia no arquivo
          pc_escreve_clob(vr_xml_clobgrl,'<agencia cdagenci="'||LPAD(vr_tbdemiss(ind).cdagenci,3,'0')||'"  '||
                                                 ' dsagenci="'||vr_tbdemiss(ind).dsagenci||'" >'||chr(13));

        END IF;

        -- Monta a linha de registro do relatório
        vr_xml_dsregis := '<demissao >'||chr(13)||
                          '  <nrdconta>'||TRIM(gene0002.fn_mask(vr_tbdemiss(ind).nrdconta,'zzzz.zzz.9'))||'</nrdconta>'||chr(13)||
                          '  <nrmatric>'||TRIM(gene0002.fn_mask(vr_tbdemiss(ind).nrmatric,'zzz.zz9'   ))||'</nrmatric>'||chr(13)||
                          '  <nmprimtl>'||SUBSTR(vr_tbdemiss(ind).nmprimtl,1,23)||'</nmprimtl>'||chr(13)||
                          '  <vlcapmes>'||TO_CHAR(vr_tbdemiss(ind).vlcapmes,'FM9G999G999G990D00')||'</vlcapmes>'||chr(13)||
                          '  <dtdemiss>'||TO_CHAR(vr_tbdemiss(ind).dtdemiss,'DD/MM/YYYY')||'</dtdemiss>'||chr(13)||
                          '  <dsoperad>'||SUBSTR(vr_tbdemiss(ind).dsoperad,1,20)||'</dsoperad>'||chr(13)||
                          '  <dsmotdem>'||SUBSTR(vr_tbdemiss(ind).dsmotdem,1,20)||'</dsmotdem>'||chr(13)||
                          '  <dsobserv>'||vr_tbdemiss(ind).dsobserv||'</dsobserv>'||chr(13)||
                          '  <induplic>'||vr_tbdemiss(ind).induplic||'</induplic>'||chr(13)||
                          '</demissao >'||chr(13);

        -- Escreve as linhas nos XMLs
        pc_escreve_clob(vr_xml_clobpar,vr_xml_dsregis);
        pc_escreve_clob(vr_xml_clobgrl,vr_xml_dsregis);

        IF vr_tbdemiss.NEXT(ind) IS NULL THEN
          vr_xml_cdagaux := -1;
        ELSE
          vr_xml_cdagaux := vr_tbdemiss(vr_tbdemiss.NEXT(ind)).cdagenci;
        END IF;

        -- Se for o último registro da agencia
        IF vr_tbdemiss(ind).cdagenci <> vr_xml_cdagaux THEN

          -- Finaliza a TAG de agencia do XML Geral
          pc_escreve_clob(vr_xml_clobgrl,'</agencia >'||chr(13));

          -- Finaliza o XML parcial
          pc_escreve_clob(vr_xml_clobpar,'</agencia ></crps033 >'||chr(13));

          -- Define o nome do arquivo
          vr_xml_nmarqlst := 'crrl033_'||LPAD(vr_tbdemiss(ind).cdagenci,3,'0')||'.lst';

          -- Submeter o relatório
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                     ,pr_dtmvtolt  => vr_dtmvtolt                          --> Data do movimento atual
                                     ,pr_dsxml     => vr_xml_clobpar                       --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crps033/agencia/demissao'          --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl033.jasper'                     --> Arquivo de layout do iReport
                                     ,pr_dsparams  => null                                 --> Sem parâmetros
                                     ,pr_dsarqsaid => vr_nom_direto||'/rl/'||vr_xml_nmarqlst--> Arquivo final com o path
                                     ,pr_qtcoluna  => 132                                  --> 132 colunas
                                     ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                     ,pr_flg_impri => 'N'                                  --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => '132dm'                              --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 1                                    --> Número de cópias
                                     ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                     ,pr_des_erro  => pr_dscritic);                        --> Saída com erro


          -- Liberando a memória alocada pelo CLOB parcial
          dbms_lob.close(vr_xml_clobpar);
          dbms_lob.freetemporary(vr_xml_clobpar);

          -- Verifica se ocorreram erros na geração
          IF pr_dscritic IS NOT NULL THEN
            -- Gerar exceção
            RAISE vr_exc_saida;
          END IF;

        END IF; -- Ultimo registro da agencia

      END LOOP;

      -- Monta o XML com os totalizadores
      dbms_lob.createtemporary(vr_xml_clobpar, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_xml_clobpar, dbms_lob.lob_readwrite);

      -- Escreve o cabeçalho do arquivo parcial
      pc_escreve_clob(vr_xml_clobpar,'<?xml version="1.0" encoding="utf-8"?>'||chr(13)||
                                     '<crps033 dsrefere="'||vr_dsrefere||'" >'||chr(13));

      -- Escreve as tags de agencia e demissão vazias, pois as mesmas são necessárias devida a estrutura do iReport
      pc_escreve_clob(vr_xml_clobpar,'<agencia cdagenci=""  dsagenci="" >'||chr(13)||
                                         '  <demissao >'||chr(13)||
                                         '  </demissao>'||chr(13)||
                                         '</agencia >'||chr(13));

      -- Monta o nodo com os totalizadores
      vr_xml_dsregis := '<totalgeral >'||chr(13)||
                        '  <qtdtotal>'||to_char(NVL(vr_qtdtotal,0),'FM9G999G999G990')||'</qtdtotal>'||chr(13)||
                        '  <qttotdup>'||to_char(NVL(vr_qttotdup,0),'FM9G999G999G990')||'</qttotdup>'||chr(13)||
                        '  <qtexclui>'||to_char(NVL(vr_qtexclui,0),'FM9G999G999G990')||'</qtexclui>'||chr(13)||
                        '  <vltotcap>'||to_char(NVL(vr_vltotcap,0),'FM9G999G999G990D00')||'</vltotcap>'||chr(13)||
                        '</totalgeral >'||chr(13)||
                        '</crps033 >'||chr(13);

      -- Escreve as linhas nos XMLs
      pc_escreve_clob(vr_xml_clobpar,vr_xml_dsregis);
      pc_escreve_clob(vr_xml_clobgrl,vr_xml_dsregis);

      /** Relatório de totalizadores **/
      -- Define o nome do arquivo
      vr_xml_nmarqlst := 'crrl033_998.lst';

      -- Submeter o relatório
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => vr_dtmvtolt                          --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml_clobpar                       --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crps033/agencia/demissao'          --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl033.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/rl/'||vr_xml_nmarqlst--> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'N'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132dm'                              --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_des_erro  => pr_dscritic);                        --> Saída com erro

      -- Liberando a memória alocada pelo CLOB parcial
      dbms_lob.close(vr_xml_clobpar);
      dbms_lob.freetemporary(vr_xml_clobpar);

      -- Verifica se ocorreram erros na geração
      IF pr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      /** Relatório GERAL **/
      -- Define o nome do arquivo
      vr_xml_nmarqlst := 'crrl033_999.lst';

      -- Submeter o relatório
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => vr_dtmvtolt                          --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml_clobgrl                       --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crps033/agencia/demissao'          --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl033.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/rl/'||vr_xml_nmarqlst--> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132dm'                              --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_flgremarq => 'S'                                  --> Remove arquivo após geração
                                 ,pr_des_erro  => pr_dscritic);                        --> Saída com erro

      -- Liberando a memória alocada pelo CLOB geral
      dbms_lob.close(vr_xml_clobgrl);
      dbms_lob.freetemporary(vr_xml_clobgrl);

      -- Verifica se ocorreram erros na geração do XML
      IF pr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

    END;

  ELSE
    -- Montar o XML para o relatório e solicitar o mesmo
    DECLARE

      -- Variáveis locais do bloco
      -- Nome do arquivo
      vr_xml_clobpar       CLOB;
      vr_xml_clobgrl       CLOB;
      vr_xml_dsregis       VARCHAR2(32000);
      vr_xml_nmarqlst      VARCHAR2(20);


      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;

    BEGIN
      --caso não encontrar, gerar o crrl003_998 zerado
      -- Monta o XML com os totalizadores
      dbms_lob.createtemporary(vr_xml_clobpar, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_xml_clobpar, dbms_lob.lob_readwrite);

      -- Escreve o cabeçalho do arquivo parcial
      pc_escreve_clob(vr_xml_clobpar,'<?xml version="1.0" encoding="utf-8"?>'||chr(13)||
                                     '<crps033 dsrefere="'||vr_dsrefere||'" >'||chr(13));

      -- Escreve as tags de agencia e demissão vazias, pois as mesmas são necessárias devida a estrutura do iReport
      pc_escreve_clob(vr_xml_clobpar,'<agencia cdagenci=""  dsagenci="" >'||chr(13)||
                                         '  <demissao >'||chr(13)||
                                         '  </demissao>'||chr(13)||
                                         '</agencia >'||chr(13));

      -- Monta o nodo com os totalizadores
      vr_xml_dsregis := '<totalgeral >'||chr(13)||
                        '  <qtdtotal>'||to_char(NVL(vr_qtdtotal,0),'FM9G999G999G990')||'</qtdtotal>'||chr(13)||
                        '  <qttotdup>'||to_char(NVL(vr_qttotdup,0),'FM9G999G999G990')||'</qttotdup>'||chr(13)||
                        '  <qtexclui>'||to_char(NVL(vr_qtexclui,0),'FM9G999G999G990')||'</qtexclui>'||chr(13)||
                        '  <vltotcap>'||to_char(NVL(vr_vltotcap,0),'FM9G999G999G990D00')||'</vltotcap>'||chr(13)||
                        '</totalgeral >'||chr(13)||
                        '</crps033 >'||chr(13);

      -- Escreve as linhas nos XMLs
      pc_escreve_clob(vr_xml_clobpar,vr_xml_dsregis);

      /** Relatório de totalizadores **/
      -- Define o nome do arquivo
      vr_xml_nmarqlst := 'crrl033_998.lst';

      -- Submeter o relatório
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => vr_dtmvtolt                          --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml_clobpar                       --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crps033/agencia/demissao'          --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl033.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/rl/'||vr_xml_nmarqlst--> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'N'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132dm'                              --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_des_erro  => pr_dscritic);                        --> Saída com erro

      -- Liberando a memória alocada pelo CLOB parcial
      dbms_lob.close(vr_xml_clobpar);
      dbms_lob.freetemporary(vr_xml_clobpar);
    END;
  END IF;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Grava as informações (Relatórios)
  COMMIT;

EXCEPTION
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
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS034;
/

