CREATE OR REPLACE PACKAGE CECRED.CCRD0004 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CCRD0004
  --  Sistema  : Rotinas referente ao processo de domicilio bancario
  --  Sigla    : CCRD
  --  Autor    : Andrino Carlos de Souza Junior (RKAM)
  --  Data     : Setembro - 2015.                   Ultima atualizacao: 10/02/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas do domicilio bancario

  -- Alteracoes: 22/12/2015 - Incluida validacao para nao processar registros repetidos
  --                          Essa validacao e feita pelo campo NRSEQ_SICOOB
  --                          Chamado 372646 (Heitor - RKAM)
  --
  --			 22/04/2016 - Efetuado ajuste no procedimento que processa arquivo, para 
  --						  quando ocorre crítica na linha gravar na tabela situação 
  --						  2 – Erro, a descrição do Erro. Desta forma a linha não será 
  --						  processada, mas identificada que ocorreu erro.
  --						  Retirado a validação da data de lançamento ser inferior 
  --						  a data de processamento. Chamado 433399 (Gisele C. Neves - RKAM)
  --
  --       20/09/2016 - #523937 Criação de log de controle de início, erros e fim de execução
  --                    do job pc_efetua_processo (Carlos)
  --
  --       08/12/2016 - Tratamento para incorporacao/migracao de cooperativas. (Fabricio)
  --
  --       10/02/2017 - #602248 Melhoria de quando o programa pc_efetua_processo sinaliza o início 
  --                    da execução; retirada a verificação de final de semana pois o job do mesmo
  --                    executa apenas de seg a sex; criação da rotina pc_efetua_processo_web, chamada
  --                    pela tela CONLDB (Carlos)
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina para o processamento do arquivo oriundo do Sicoob
  PROCEDURE pc_efetua_processo(pr_cdcritic OUT crapcri.cdcritic%TYPE
                              ,pr_dscritic OUT VARCHAR2);

  -- Rotina para o processamento do arquivo oriundo do Sicoob (executada pela tela CONLDB)
  PROCEDURE pc_efetua_processo_web(pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica                                  
                                  ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Rotina para retornar os arquivos processados
  PROCEDURE pc_lista_arquivos(pr_dtinicio IN VARCHAR2               --> Data inicial da consulta
                             ,pr_dtfinal  IN VARCHAR2               --> Data final da consulta
                             ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
                             ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Rotina para retornar os arquivos processados
  PROCEDURE pc_lista_contas(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                           ,pr_cddregio IN crapreg.cddregio%TYPE  --> Codigo da regional
                           ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                           ,pr_dtinicio IN VARCHAR2               --> Data inicial do lancamento da consulta
                           ,pr_dtfinal  IN VARCHAR2               --> Data final do lancamento da consulta
                           ,pr_dtiniarq IN VARCHAR2               --> Data inicial do arquivo da consulta
                           ,pr_dtfimarq IN VARCHAR2               --> Data final do arquivo da consulta
                           ,pr_insituac IN tbdomic_arq_lancto_cartoes.insituacao%TYPE --> Situacao do registro
                           ,pr_tplancto IN tbdomic_arq_lancto_cartoes.tplancamento%TYPE --> Tipo de lancamento
                           ,pr_tpprodut IN tbdomic_arq_lancto_cartoes.tpproduto%TYPE --> Produto selecionado
                           ,pr_nmarquiv IN tbdomic_arq_lancto_cartoes.nmarquivo%TYPE --> Nome do arquivo
                           ,pr_insaida  IN PLS_INTEGER            --> Indicador de saida dos dados (1-Xml, 2-Arquivo CSV)
                           ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
                           ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                           ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Rotina para retornar as regionais para a tela CONLDB
  PROCEDURE pc_lista_regional(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                             ,pr_cddregio IN crapreg.cddregio%TYPE --> Codigo da regional
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);           --> Erros do processo


END CCRD0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CCRD0004 AS


  -- Rotina para retornar os arquivos processados
  PROCEDURE pc_lista_arquivos(pr_dtinicio IN VARCHAR2               --> Data inicial da consulta
                             ,pr_dtfinal  IN VARCHAR2               --> Data final da consulta
                             ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
                             ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

    -- Cursor sobre a tabela de associados que podem possuir contas duplicadas
    CURSOR cr_tabela(pr_dtinicio DATE, pr_dtfinal DATE) IS
      SELECT nmarquivo,
             to_char(MAX(dhinclusao),'DD/MM/YYYY') dtinclusao,
             to_char(MAX(dhinclusao),'hh24:mi') hrinclusao,
             SUM(decode(insituacao,0,1,0)) qtpendentes,
             SUM(decode(insituacao,1,1,0)) qtprocessados,
             SUM(decode(insituacao,2,1,0)) qterros
        FROM tbdomic_arq_lancto_cartoes
       WHERE trunc(dhinclusao) BETWEEN pr_dtinicio AND pr_dtfinal
       GROUP BY nmarquivo
       ORDER BY nmarquivo;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis gerais
      vr_dtinicio DATE;
      vr_dtfinal  DATE;
      vr_qt_tot_pendentes   PLS_INTEGER := 0;
      vr_qt_tot_processados PLS_INTEGER := 0;
      vr_qt_tot_erros       PLS_INTEGER := 0;
      vr_contador           PLS_INTEGER := 0;
      vr_posreg   PLS_INTEGER := 0; 
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;


      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN

      gene0001.pc_informa_acesso(pr_module => 'CCRD0004');

      -- Monta documento XML
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados><servico>');

      -- Popula a data de inicio
      IF TRIM(pr_dtinicio) IS NULL THEN
        vr_dtinicio := to_date('01/01/2000','dd/mm/yyyy');
      ELSE
        vr_dtinicio := to_date(pr_dtinicio,'dd/mm/yyyy');
      END IF;

      -- Popula a data de termino
      IF TRIM(pr_dtfinal) IS NULL THEN
        vr_dtfinal := to_date('31/12/2999','dd/mm/yyyy');
      ELSE
        vr_dtfinal := to_date(pr_dtfinal,'dd/mm/yyyy');
      END IF;
      
      
      -- Loop sobre as versoes do questionario de microcredito
      FOR rw_tabela IN cr_tabela(vr_dtinicio, vr_dtfinal) LOOP

        -- Incrementa o contador de registros
        vr_posreg := vr_posreg + 1;

        -- Enviar somente se a linha for superior a linha inicial
        IF nvl(pr_nriniseq,0) <= vr_posreg AND 
           vr_contador <  nvl(pr_nrregist,99999) THEN -- E enviados for menor que o solicitado

          -- Carrega os dados           
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<inf>'||
                                                          '<nmarquivo>'     || rw_tabela.nmarquivo     ||'</nmarquivo>'||
                                                          '<dtinclusao>'    || rw_tabela.dtinclusao    ||'</dtinclusao>'||
                                                          '<hrinclusao>'    || rw_tabela.hrinclusao    ||'</hrinclusao>'||
                                                          '<qtprocessados>' || rw_tabela.qtprocessados ||'</qtprocessados>'||
                                                          '<qtpendentes>'   || rw_tabela.qtpendentes   ||'</qtpendentes>'||
                                                          '<qterros>'       || rw_tabela.qterros       ||'</qterros>'||
                                                       '</inf>');
          vr_contador := vr_contador + 1;
        END IF;

--        -- Deve-se sair se o total de registros superar o total solicitado
--        EXIT WHEN vr_contador >= nvl(pr_nrregist,99999);
        
        -- Incremente os totalizadores
        vr_qt_tot_pendentes   := vr_qt_tot_pendentes   + rw_tabela.qtpendentes;
        vr_qt_tot_processados := vr_qt_tot_processados + rw_tabela.qtprocessados;
        vr_qt_tot_erros       := vr_qt_tot_erros       + rw_tabela.qterros;
      END LOOP;
      

      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</servico>'||
                                                   '<qtregist>'       ||vr_contador ||'</qtregist>'||
                                                   '<tot_processados>'|| vr_qt_tot_processados ||'</tot_processados>'||
                                                   '<tot_pendentes>'  || vr_qt_tot_pendentes ||'</tot_pendentes>'||
                                                   '<tot_erros>'      || vr_qt_tot_erros ||'</tot_erros>'||
                                                   '</Dados>'
                             ,pr_fecha_xml      => TRUE);
                
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob);

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_lista_arquivos: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    
  END pc_lista_arquivos;


  -- Rotina para retornar os arquivos processados
  PROCEDURE pc_lista_contas(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                           ,pr_cddregio IN crapreg.cddregio%TYPE  --> Codigo da regional
                           ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da agencia
                           ,pr_dtinicio IN VARCHAR2               --> Data inicial do lancamento da consulta
                           ,pr_dtfinal  IN VARCHAR2               --> Data final do lancamento da consulta
                           ,pr_dtiniarq IN VARCHAR2               --> Data inicial do arquivo da consulta
                           ,pr_dtfimarq IN VARCHAR2               --> Data final do arquivo da consulta
                           ,pr_insituac IN tbdomic_arq_lancto_cartoes.insituacao%TYPE --> Situacao do registro
                           ,pr_tplancto IN tbdomic_arq_lancto_cartoes.tplancamento%TYPE --> Tipo de lancamento
                           ,pr_tpprodut IN tbdomic_arq_lancto_cartoes.tpproduto%TYPE --> Produto selecionado
                           ,pr_nmarquiv IN tbdomic_arq_lancto_cartoes.nmarquivo%TYPE --> Nome do arquivo
                           ,pr_insaida  IN PLS_INTEGER            --> Indicador de saida dos dados (1-Xml, 2-Arquivo CSV)
                           ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
                           ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                           ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

      -- Cursor sobre a tabela de associados que podem possuir contas duplicadas
      CURSOR cr_tabela(pr_dtinicio DATE, pr_dtfinal DATE,
                       pr_dtiniarq DATE, pr_dtfimarq DATE) IS
        SELECT idlancamento   
              ,nrseq_sicoob   
              ,nmestabelecimento
              ,nrcpfcgc       
              ,tppessoa       
              ,cdagebcb       
              ,nrdconta       
              ,tplancamento   
              ,tpproduto      
              ,vllancamento   
              ,dtreferencia   
              ,nmarquivo      
              ,insituacao     
              ,decode(insituacao,0,'Pendente',1,'Processado','Erro') dssituacao
              ,dserro         
              ,nrdolote       
              ,nrseqdig       
              ,dhinclusao     
              ,dhprocessamento
          FROM tbdomic_arq_lancto_cartoes a
         WHERE a.dtreferencia BETWEEN pr_dtinicio AND pr_dtfinal
           AND trunc(a.dhinclusao) BETWEEN pr_dtiniarq AND pr_dtfimarq
           AND a.insituacao = decode(nvl(pr_insituac,9),9,a.insituacao,pr_insituac)
           AND a.tplancamento = decode(nvl(pr_tplancto,'X'),'X',a.tplancamento, pr_tplancto)
           AND a.tpproduto = decode(nvl(pr_tpprodut,'X'),'X',a.tpproduto, pr_tpprodut)
           AND upper(a.nmarquivo) = nvl(upper(pr_nmarquiv),upper(a.nmarquivo));

      -- Cursor sobre os associados
      CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT crapass.nmprimtl,
               crapass.cdagenci,
               crapage.cddregio
          FROM crapage,
               crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta
           AND crapage.cdcooper = crapass.cdcooper
           AND crapage.cdagenci = crapass.cdagenci;
      rw_crapass cr_crapass%ROWTYPE;


      -- Cursor sobre as agencias
      CURSOR cr_crapcop IS
        SELECT cdcooper,
               cdagebcb,
               nmrescop
          FROM crapcop;

      -- PL/Table para armazenar o resumo da listagem
      type typ_resumo IS RECORD (cdcooper crapass.cdcooper%TYPE,
                                 nmrescop crapcop.nmrescop%TYPE,
                                 cddregio crapreg.cddregio%TYPE,
                                 cdagenci crapage.cdagenci%TYPE,
                                 nrdconta VARCHAR2(20),
                                 nmprimtl tbdomic_arq_lancto_cartoes.nmestabelecimento%TYPE,
                                 nrcpfcgc VARCHAR2(50),
                                 tplancto tbdomic_arq_lancto_cartoes.tplancamento%TYPE,
                                 tpprodut tbdomic_arq_lancto_cartoes.tpproduto%TYPE,
                                 dtrefere DATE,
                                 dtinclus DATE,
                                 vllancto tbdomic_arq_lancto_cartoes.vllancamento%TYPE,
                                 dssituac VARCHAR2(10),
                                 dserro   tbdomic_arq_lancto_cartoes.dserro%TYPE);
      type typ_tab_resumo IS TABLE OF typ_resumo INDEX BY VARCHAR2(45); 
      vr_resumo       typ_tab_resumo;
      -- O índice da pl/table é nmrescop(20)+cdregio(5)+cdagenci(5)+nrdconta(10)+sequencial(5)
      vr_indice       VARCHAR2(45);
      vr_nrseq        PLS_INTEGER := 0;

      -- PL/Table para armazenar as agencias
      type typ_crapcop IS RECORD (cdcooper crapcop.cdcooper%TYPE,
                                  nmrescop crapcop.nmrescop%TYPE);
      type typ_tab_crapcop IS TABLE OF typ_crapcop INDEX BY PLS_INTEGER;
      vr_crapcop       typ_tab_crapcop;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_tab_erro       GENE0001.typ_tab_erro;
      vr_des_reto       VARCHAR2(10);
      vr_typ_saida      VARCHAR2(3);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper_conectado NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
      

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_dtinicio DATE;
      vr_dtfinal  DATE;
      vr_dtiniarq DATE;
      vr_dtfimarq DATE;
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_nmrescop crapcop.nmrescop%TYPE;
      vr_inpessoa crapass.inpessoa%TYPE;
      vr_lancamento tbdomic_arq_lancto_cartoes.vllancamento%TYPE := 0;
      vr_posreg   PLS_INTEGER := 0; 
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
      vr_dserro   VARCHAR2(50);
      vr_dsdiretorio VARCHAR2(100);      --> Local onde sera gerado o relatorio
      vr_nmarquivo   VARCHAR2(100);      --> Nome do relatorio CSV

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN

      gene0001.pc_informa_acesso(pr_module => 'CCRD0004');

      -- Busca os dados do XML padrao
      gene0004.pc_extrai_dados(pr_xml => pr_retxml
                              ,pr_cdcooper => vr_cdcooper_conectado
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Popula a pl/table de agencia
      FOR rw_crapcop IN cr_crapcop LOOP
        vr_crapcop(rw_crapcop.cdagebcb).cdcooper := rw_crapcop.cdcooper;
        vr_crapcop(rw_crapcop.cdagebcb).nmrescop := rw_crapcop.nmrescop;
      END LOOP;
      
      -- Popula a data de inicio do lancamento
      IF TRIM(pr_dtinicio) IS NULL THEN
        vr_dtinicio := to_date('01/01/2000','dd/mm/yyyy');
      ELSE
        vr_dtinicio := to_date(pr_dtinicio,'dd/mm/yyyy');
      END IF;

      -- Popula a data de termino do lancamento
      IF TRIM(pr_dtfinal) IS NULL THEN
        vr_dtfinal := to_date('31/12/2999','dd/mm/yyyy');
      ELSE
        vr_dtfinal := to_date(pr_dtfinal,'dd/mm/yyyy');
      END IF;

      -- Popula a data de inicio do arquivo
      IF TRIM(pr_dtiniarq) IS NULL THEN
        vr_dtiniarq := to_date('01/01/2000','dd/mm/yyyy');
      ELSE
        vr_dtiniarq := to_date(pr_dtiniarq,'dd/mm/yyyy');
      END IF;

      -- Popula a data de termino do arquivo
      IF TRIM(pr_dtfimarq) IS NULL THEN
        vr_dtfimarq := to_date('31/12/2999','dd/mm/yyyy');
      ELSE
        vr_dtfimarq := to_date(pr_dtfimarq,'dd/mm/yyyy');
      END IF;

      FOR rw_tabela IN cr_tabela(vr_dtinicio, vr_dtfinal, vr_dtiniarq, vr_dtfimarq) LOOP
        -- Busca a cooperativa
        IF vr_crapcop.exists(rw_tabela.cdagebcb) THEN
          vr_cdcooper := vr_crapcop(rw_tabela.cdagebcb).cdcooper;
          vr_nmrescop := vr_crapcop(rw_tabela.cdagebcb).nmrescop;
        ELSE
          vr_cdcooper := NULL;
          vr_nmrescop := NULL;
        END IF;
        
        -- Se foi colocado filtro por cooperativa
        IF nvl(pr_cdcooper,0) <> 0 THEN
          IF pr_cdcooper <> nvl(vr_cdcooper,0) THEN
            continue; -- Vai para o proximo registro
          END IF;
        END IF;
        
        -- Verifica se existe associado para o registro especifico
        OPEN cr_crapass(vr_cdcooper, rw_tabela.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;
        
        -- Se nao possui associado, mas possui filtro de regional ou agencia, deve-se ignorar o registro
        IF rw_crapass.nmprimtl IS NULL AND
          (nvl(pr_cddregio,0) <> 0 OR
           nvl(pr_cdagenci,0) <> 0) THEN
          continue; -- Vai para o proximo registro
        END IF;
        
        -- Se existir associado
        IF rw_crapass.nmprimtl IS NOT NULL THEN 
          -- Se a regional do parametro for diferente da regional do associado
          IF nvl(pr_cddregio,0) <> 0 AND pr_cddregio <> nvl(rw_crapass.cddregio,0) THEN
            continue; -- Vai para o proximo registro
          END IF;
          
          -- Se a agencia do parametro for diferente da agencia do associado
          IF nvl(pr_cdagenci,0) <> 0 AND pr_cdagenci <> rw_crapass.cdagenci THEN
            continue; -- Vai para o proximo registro
          END IF;
        END IF;
      
        -- Atualiza o indicador de pessoa
        IF rw_tabela.tppessoa = 'PF' THEN
          vr_inpessoa := 1;
        ELSE
          vr_inpessoa := 2;
        END IF;
        
        -- Incrementa o sequencial do registro
        vr_nrseq := vr_nrseq + 1;
        vr_lancamento := vr_lancamento + rw_tabela.vllancamento;

        -- Insere o registro na Pl/Table, pois o mesmo passou pelos filtros
        vr_indice := rpad(nvl(vr_nmrescop,' '),20)|| 
                     lpad(nvl(rw_crapass.cddregio,0),5,'0')||
                     lpad(nvl(rw_crapass.cdagenci,0),5,'0')||
                     lpad(rw_tabela.nrdconta,10,0)||
                     lpad(vr_nrseq,5,'0');
        
        -- Atualiza a pl/table com o registro
        vr_resumo(vr_indice).cdcooper := vr_cdcooper;
        vr_resumo(vr_indice).nmrescop := vr_nmrescop;
        vr_resumo(vr_indice).cddregio := rw_crapass.cddregio;
        vr_resumo(vr_indice).cdagenci := rw_crapass.cdagenci;
        vr_resumo(vr_indice).nrdconta := gene0002.fn_mask_conta(rw_tabela.nrdconta);
        vr_resumo(vr_indice).nmprimtl := nvl(rw_crapass.nmprimtl,rw_tabela.nmestabelecimento);
        vr_resumo(vr_indice).nrcpfcgc := gene0002.fn_mask_cpf_cnpj(rw_tabela.nrcpfcgc,vr_inpessoa);
        vr_resumo(vr_indice).tplancto := rw_tabela.tplancamento;
        vr_resumo(vr_indice).tpprodut := rw_tabela.tpproduto;
        vr_resumo(vr_indice).dtrefere := rw_tabela.dtreferencia;
        vr_resumo(vr_indice).dtinclus := trunc(rw_tabela.dhinclusao);
        vr_resumo(vr_indice).vllancto := rw_tabela.vllancamento;
        vr_resumo(vr_indice).dssituac := rw_tabela.dssituacao;
        vr_resumo(vr_indice).dserro   := rw_tabela.dserro;
       
      END LOOP;

      -- Cria a variavel CLOB
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

      -- Se for para gerar a saida no XML
      IF pr_insaida = 1 THEN
        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados><servico>');

      ELSE -- Se for para gerar para arquivo CSV

        -- Busca o diretorio onde esta os arquivos Sicoob
        vr_dsdiretorio := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                    pr_cdacesso => 'ROOT_DOMICILIO')||'/relatorios';
        vr_nmarquivo := 'CONLDB_'||to_char(SYSDATE,'HHMISS')||'.csv';
        -- Criar cabeçalho do CSV
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => 'Cooperativa;Regional;PA;Conta;Nome;CPF/CNPJ;Lct;Prd;Data Lct;Data Arq;Valor;Situacao;Erro'||chr(10));
      END IF;

      -- inicializa o loop sobre a pl/table
      vr_indice := vr_resumo.first;

      -- Loop sobre a pl/table
      LOOP
        -- Se o indice for nulo, entao eh o final da pl/table
        IF vr_indice IS NULL THEN
          EXIT;
        END IF;

        -- Se for para gerar a saida no XML
        IF pr_insaida = 1 THEN

          -- Incrementa o contador de registros
          vr_posreg := vr_posreg + 1;

          -- Enviar somente se a linha for superior a linha inicial
          IF nvl(pr_nriniseq,0) <= vr_posreg THEN

            -- Popula a variavel de erro
            IF vr_resumo(vr_indice).dserro IS NULL THEN
              vr_dserro := NULL;
            ELSE
              vr_dserro := substr(vr_resumo(vr_indice).dserro,1,30)||'...';
            END IF;
            
            -- Carrega os dados           
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<inf>'||
                                                            '<cdcooper>' || vr_resumo(vr_indice).cdcooper ||'</cdcooper>'||
                                                            '<nmrescop>' || vr_resumo(vr_indice).nmrescop ||'</nmrescop>'||
                                                            '<cddregio>' || vr_resumo(vr_indice).cddregio ||'</cddregio>'||
                                                            '<cdagenci>' || vr_resumo(vr_indice).cdagenci ||'</cdagenci>'||
                                                            '<nrdconta>' || vr_resumo(vr_indice).nrdconta ||'</nrdconta>'||
                                                            '<nmprimtl>' || vr_resumo(vr_indice).nmprimtl ||'</nmprimtl>'||
                                                            '<nrcpfcgc>' || vr_resumo(vr_indice).nrcpfcgc ||'</nrcpfcgc>'||
                                                            '<tplancto>' || vr_resumo(vr_indice).tplancto ||'</tplancto>'||
                                                            '<tpprodut>' || vr_resumo(vr_indice).tpprodut ||'</tpprodut>'||
                                                            '<dtrefere>' || to_char(vr_resumo(vr_indice).dtrefere,'DD/MM/YYYY')||'</dtrefere>'||
                                                            '<dtinclus>' || to_char(vr_resumo(vr_indice).dtinclus,'DD/MM/YYYY')||'</dtinclus>'||
                                                            '<vllancto>' || to_char(vr_resumo(vr_indice).vllancto,'fm999g999g990D00')||'</vllancto>'||
                                                            '<dssituac>' || vr_resumo(vr_indice).dssituac ||'</dssituac>'||
                                                            '<dserro>'   || vr_dserro ||'</dserro>'  ||
                                                         '</inf>');
            vr_contador := vr_contador + 1;
          END IF;

          -- Deve-se sair se o total de registros superar o total solicitado
          EXIT WHEN vr_contador >= nvl(pr_nrregist,99999);

        ELSE -- Se for para gerar no CSV
          -- Carrega os dados           
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => vr_resumo(vr_indice).nmrescop  ||';'||
                                                       vr_resumo(vr_indice).cddregio ||';'||
                                                       vr_resumo(vr_indice).cdagenci ||';'||
                                                       vr_resumo(vr_indice).nrdconta ||';'||
                                                       vr_resumo(vr_indice).nmprimtl ||';'||
                                                       vr_resumo(vr_indice).nrcpfcgc ||';'||
                                                       vr_resumo(vr_indice).tplancto ||';'||
                                                       vr_resumo(vr_indice).tpprodut ||';'||
                                                       to_char(vr_resumo(vr_indice).dtrefere,'DD/MM/YYYY') ||';'||
                                                       to_char(vr_resumo(vr_indice).dtinclus,'DD/MM/YYYY') ||';'||
                                                       to_char(vr_resumo(vr_indice).vllancto,'fm999999990D00')||';'||
                                                       vr_resumo(vr_indice).dssituac ||';'||
                                                       vr_resumo(vr_indice).dserro||chr(10));
        END IF;

        -- Vai para o proximo registro
        vr_indice := vr_resumo.next(vr_indice);

      END LOOP;

      -- Se for para gerar a saida no XML
      IF pr_insaida = 1 THEN

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</servico>'||
                                                     '<qtregist>'||vr_nrseq||'</qtregist>'||
                                                     '<vltotal>'||to_char(vr_lancamento,'fm999G999G990D00')||'</vltotal>'||
                                                     '</Dados>'
                               ,pr_fecha_xml      => TRUE);

        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

      ELSE

        -- Encerrar o Clob
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => ' '
                               ,pr_fecha_xml      => TRUE);
                               
        -- Gera o relatorio
        gene0002.pc_clob_para_arquivo(pr_clob => vr_clob,
                                      pr_caminho => vr_dsdiretorio,
                                      pr_arquivo => vr_nmarquivo,
                                      pr_des_erro => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- copia contrato pdf do diretorio da cooperativa para servidor web
        gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper_conectado
                                   , pr_cdagenci => NULL
                                   , pr_nrdcaixa => NULL
                                   , pr_nmarqpdf => vr_dsdiretorio||'/'||vr_nmarquivo
                                   , pr_des_reto => vr_des_reto
                                   , pr_tab_erro => vr_tab_erro
                                   );

        -- caso apresente erro na operação
        IF nvl(vr_des_reto,'OK') <> 'OK' THEN
          IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
            RAISE vr_exc_saida; -- encerra programa
          END IF;
        END IF;

        -- Remover relatorio do diretorio padrao da cooperativa
        gene0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'rm '||vr_dsdiretorio||'/'||vr_nmarquivo
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

        -- Se retornou erro
        IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT null THEN
          -- Concatena o erro que veio
          vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
          RAISE vr_exc_saida; -- encerra programa
        END IF;

        -- Criar XML de retorno para uso na Web
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqcsv>' || vr_nmarquivo|| '</nmarqcsv>');
        
      END IF;
                
      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob);
     
    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_lista_contas: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    
  END pc_lista_contas;


  -- Rotina para retornar as regionais para a tela CONLDB
  PROCEDURE pc_lista_regional(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                             ,pr_cddregio IN crapreg.cddregio%TYPE --> Codigo da regional
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
      -- Cursor sobre a tabela de regionais
      CURSOR cr_crapreg IS
        SELECT cddregio,
               dsdregio
          FROM crapreg
         WHERE cdcooper = pr_cdcooper 
           AND cddregio = decode(nvl(pr_cddregio,0),0,cddregio,pr_cddregio)
         ORDER BY cddregio;
      rw_crapreg cr_crapreg%ROWTYPE;

      -- Variaveis gerais
      vr_ind PLS_INTEGER := -1; -- Contador de registros

      -- Variaveis de critica
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

    BEGIN
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados/></Root>');

      -- Loop sobre a tabela de regional
      FOR rw_crapreg IN cr_crapreg LOOP
        vr_ind := vr_ind + 1;
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'      , pr_posicao => 0, pr_tag_nova => 'regionais', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'regionais',   pr_posicao => vr_ind, pr_tag_nova => 'cddregio', pr_tag_cont => rw_crapreg.cddregio, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'regionais',   pr_posicao => vr_ind, pr_tag_nova => 'dsdregio', pr_tag_cont => rw_crapreg.dsdregio, pr_des_erro => vr_dscritic);
        
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_lista_regional: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  -- Retorna a primeira posicao do pr_setlinha
  FUNCTION fn_retorna_texto(pr_setlinha IN OUT VARCHAR2,
                            pr_dstipo   IN     VARCHAR2,
                            pr_nmcampo  IN     VARCHAR2,
                            pr_dscritic IN OUT VARCHAR2) RETURN VARCHAR2 IS
    vr_setlinha VARCHAR2(500);
    vr_dttemp DATE;
    vr_vltemp NUMBER(20);
  BEGIN
    -- Se nao estiver nulo, eh que ja deu um erro anterior. Nao deve-se fazer nada
    IF pr_dscritic IS NOT NULL THEN
      RETURN NULL;
    END IF;
    
    -- Se nao tiver ponto e virgula, entao utiliza todo o texto
    IF instr(pr_setlinha,';') = 0 THEN
      vr_setlinha := pr_setlinha;
      pr_setlinha := NULL;
    ELSE
      vr_setlinha := substr(pr_setlinha,1,instr(pr_setlinha,';')-1);
      pr_setlinha := substr(pr_setlinha,instr(pr_setlinha,';')+1);
    END IF;
    
    -- Se for numero, tenta converter para valor para ver se veio somente numeros
    IF pr_dstipo = 'N' THEN
      vr_vltemp := vr_setlinha;
    ELSIF pr_dstipo = 'D' THEN -- Se for data, tenta converter para data
      vr_dttemp := to_date(vr_setlinha,'YYYYMMDD');
    END IF;
    
    RETURN vr_setlinha;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'campo '||pr_nmcampo;
      RETURN NULL;    
  END;

  -- Rotina para processar o arquivo do diretorio
  PROCEDURE processa_arquivos(pr_dsdiretorio IN VARCHAR2     --> Diretorio do arquivo
                             ,pr_nmarquivo   IN VARCHAR2     --> Nome do arquivo
                             ,pr_dscritic   OUT VARCHAR2) IS --> Descricao do erro
    -- Cursor sobre os arquivos processados
    CURSOR cr_tabela IS
      SELECT dhinclusao
        FROM tbdomic_arq_lancto_cartoes
       WHERE upper(nmarquivo) = upper(pr_nmarquivo);
    rw_tabela_processo cr_tabela%ROWTYPE;

    -- Cursor para buscar a maior sequencia para o lancamento
    CURSOR cr_sequencia IS
      SELECT nvl(MAX(idlancamento),0)+1 
        FROM tbdomic_arq_lancto_cartoes;
    
  
    -- Variável de críticas
    vr_dscritic      VARCHAR2(10000);
    vr_tipo_saida    VARCHAR2(100);

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;

    -- Record sobre a tabela 
    rw_tabela tbdomic_arq_lancto_cartoes%ROWTYPE;

    -- Variaveis gerais
    vr_arquivo       utl_file.file_type; -- arquivo que sera trabalhado
    vr_setlinha      varchar2(2000);     -- linha com o conteudo do arquivo
    vr_nrlinha       PLS_INTEGER := 0;   -- Numero da linha no arquivo
    vr_nrsequencia   tbdomic_arq_lancto_cartoes.idlancamento%TYPE; -- Sequencia de lancamento
	vr_insituacao    tbdomic_arq_lancto_cartoes.insituacao%TYPE;
	vr_dhprocessamento tbdomic_arq_lancto_cartoes.dhprocessamento%TYPE; 
  BEGIN
    -- Verifica se este arquivo ja nao foi processado  
    OPEN cr_tabela;
    FETCH cr_tabela INTO rw_tabela_processo;
    IF cr_tabela%FOUND THEN
      CLOSE cr_tabela;
      vr_dscritic := 'Arquivo '||pr_nmarquivo||' ja foi processado dia '||to_char(rw_tabela_processo.dhinclusao,'DD/MM/YYYY')||
                     ' as ' || to_char(rw_tabela_processo.dhinclusao,'HH24:mi')|| ' horas.';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_tabela;

    -- Busca a sequencia do lancamento
    OPEN cr_sequencia;
    FETCH cr_sequencia INTO vr_nrsequencia;
    CLOSE cr_sequencia; 
     
    -- Abre o arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => pr_dsdiretorio,
                             pr_nmarquiv => pr_nmarquivo,
                             pr_tipabert => 'R',
                             pr_utlfileh => vr_arquivo,
                             pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN 
      RAISE vr_exc_saida;
    END IF;
    
    -- Efetua o loop para todas as linhas do arquivo
    LOOP
      -- Leitura das linhas do arquivo
      BEGIN
        gene0001.pc_le_linha_arquivo(vr_arquivo,
                                     vr_setlinha);
      EXCEPTION
        WHEN no_data_found THEN
          -- Terminou o arquivo, deve sair do loop
          EXIT;
      END;
      
      -- Incrementa o numero da linha
      vr_nrlinha := vr_nrlinha + 1;
      
      -- Busca os dados da linha para os dados da tabela
	  vr_insituacao               := 0;  
      rw_tabela.nrseq_sicoob      := fn_retorna_texto(vr_setlinha, 'N','numero Sicoob',vr_dscritic);
      rw_tabela.nmestabelecimento := fn_retorna_texto(vr_setlinha, 'C','nome do estabelecimento',vr_dscritic);
      rw_tabela.nrcpfcgc          := fn_retorna_texto(vr_setlinha, 'N','CPF/CNPJ',vr_dscritic);
      rw_tabela.tppessoa          := fn_retorna_texto(vr_setlinha, 'C','tipo pessoa',vr_dscritic);
      rw_tabela.cdagebcb          := fn_retorna_texto(vr_setlinha, 'N','agencia Bancoob',vr_dscritic);
      rw_tabela.nrdconta          := fn_retorna_texto(vr_setlinha, 'N','numero da conta',vr_dscritic);
      rw_tabela.tplancamento      := fn_retorna_texto(vr_setlinha, 'C','tipo lancamento',vr_dscritic);
      rw_tabela.tpproduto         := fn_retorna_texto(vr_setlinha, 'C','tipo produto',vr_dscritic);
      rw_tabela.vllancamento      := fn_retorna_texto(vr_setlinha, 'N','valor lancamento',vr_dscritic)/100;
      rw_tabela.dtreferencia      := to_date(fn_retorna_texto(vr_setlinha, 'D','data de referencia',vr_dscritic),'yyyymmdd');

      -- Verifica se nao ocorreu erro na busca dos campos
      IF vr_dscritic IS NOT NULL THEN
		vr_dhprocessamento:= sysdate;
        vr_insituacao := 2;
        vr_dscritic := 'Erro ao buscar o '||vr_dscritic||' da linha '||vr_nrlinha;       
      END IF;
      
      -- Efetua a inclusao na tabela
      BEGIN
        INSERT INTO tbdomic_arq_lancto_cartoes
          (idlancamento
          ,nrseq_sicoob
          ,nmestabelecimento
          ,nrcpfcgc
          ,tppessoa
          ,cdagebcb
          ,nrdconta
          ,tplancamento
          ,tpproduto
          ,vllancamento
          ,dtreferencia
          ,nmarquivo
          ,insituacao
          ,dserro
          ,dhinclusao
		  ,dhprocessamento )
        VALUES
          (vr_nrsequencia
          ,NVL(rw_tabela.nrseq_sicoob, 0)
          ,NVL(rw_tabela.nmestabelecimento,0)
          ,NVL(rw_tabela.nrcpfcgc,0)
          ,NVL(rw_tabela.tppessoa,0)
          ,NVL(rw_tabela.cdagebcb,0)
          ,NVL(rw_tabela.nrdconta,0)
          ,NVL(rw_tabela.tplancamento,0)
          ,NVL(rw_tabela.tpproduto,0)
          ,NVL(rw_tabela.vllancamento,0)
          ,NVL(rw_tabela.dtreferencia, TRUNC(SYSDATE))
          ,pr_nmarquivo
          ,vr_insituacao
          ,SUBSTR(vr_dscritic, 0 , 100)
          ,SYSDATE
		  ,vr_dhprocessamento );
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tbdomic_arq_lancto_cartoes: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

	  -- Limpa critica por linha.
      vr_dhprocessamento := null; 
      vr_dscritic := null; 
      -- Incrementa o sequencial
      vr_nrsequencia := vr_nrsequencia + 1;

    END LOOP;

    -- Mover o arquivo processado para a pasta "processados" 
    gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_dsdiretorio||'/'||pr_nmarquivo||' '||pr_dsdiretorio||'/processados',
                                pr_typ_saida   => vr_tipo_saida,
                                pr_des_saida   => vr_dscritic);
    -- Testa erro
    IF vr_tipo_saida = 'ERR' THEN
      vr_dscritic := 'Erro ao mover o arquivo : '||pr_dscritic;
      RAISE vr_exc_saida;
    END IF;
      
    -- Efetua a confirmacao de insercao dos dados
    COMMIT;
                               
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
  END processa_arquivos;         

  -- Rotina para processar os lancamentos pendentes
  PROCEDURE processa_registros_pendentes(pr_cdcritic OUT crapcri.cdcritic%TYPE
                                        ,pr_dscritic OUT VARCHAR2)  IS

    -- Registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Cursor sobre os registros pendentes
    CURSOR cr_tabela IS
      SELECT idlancamento   
            ,nrcpfcgc       
            ,tppessoa       
            ,cdagebcb       
            ,nrdconta       
            ,tplancamento   
            ,tpproduto      
            ,vllancamento   
            ,dtreferencia   
            ,insituacao
            ,nrseq_sicoob
        FROM tbdomic_arq_lancto_cartoes
       WHERE insituacao = 0 -- Pendente
         AND (dtreferencia <= rw_crapdat.dtmvtolt
          OR  dhprocessamento IS NULL) -- Se nao tiver sido processado e for um lancamento futudo, deve-se
                                         -- processar para verificar se nao vai existir erro
       ORDER BY cdagebcb, tplancamento, tpproduto;

    -- Cursor sobre as agencias
    CURSOR cr_crapcop IS
      SELECT cdcooper,
             cdagebcb,
             nmrescop,
             flgativo
        FROM crapcop;
        
    -- Cursor sobre os associados
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT nrcpfcgc,
             inpessoa
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- cursor de capas de lote
    CURSOR cr_craplot (pr_cdcooper  IN craplrg.cdcooper%TYPE      --> Código cooperativa
                      ,pr_dtmvtolt  IN craplrg.dtresgat%TYPE      --> Data movimento atual
                      ,pr_cdagenci  IN craplap.cdagenci%TYPE      --> código agência
                      ,pr_cdbccxlt  IN craplap.cdbccxlt%TYPE      --> Código caixa/banco
                      ,pr_nrdolote  IN craplap.nrdolote%TYPE) IS  --> Número do lote
      SELECT lot.nrseqdig
            ,lot.cdcooper
            ,lot.nrdolote
            ,ROWID
       FROM craplot lot
      WHERE lot.cdcooper = pr_cdcooper
        AND lot.dtmvtolt = pr_dtmvtolt
        AND lot.cdagenci = pr_cdagenci
        AND lot.cdbccxlt = pr_cdbccxlt
        AND lot.nrdolote = pr_nrdolote;
    rw_craplot cr_craplot%ROWTYPE;

    --Chamado 372646
    CURSOR cr_registro_repetido (pnrseq_sicoob IN tbdomic_arq_lancto_cartoes.nrseq_sicoob%TYPE) IS
      SELECT t.dhprocessamento
        FROM tbdomic_arq_lancto_cartoes t
       WHERE nrseq_sicoob = pnrseq_sicoob
         AND insituacao   = 1;
    rw_registro_repetido cr_registro_repetido%ROWTYPE;

    CURSOR cr_craptco (pr_cdcopant IN crapcop.cdcooper%TYPE,
                       pr_nrctaant IN craptco.nrctaant%TYPE) IS
      SELECT tco.nrdconta,
             tco.cdcooper
        FROM craptco tco
       WHERE tco.cdcopant = pr_cdcopant
         AND tco.nrctaant = pr_nrctaant;
    rw_craptco cr_craptco%ROWTYPE;

    -- PL/Table para armazenar as agencias
    type typ_crapcop IS RECORD (cdcooper crapcop.cdcooper%TYPE,
                                nmrescop crapcop.nmrescop%TYPE,
                                flgativo crapcop.flgativo%TYPE);
    type typ_tab_crapcop IS TABLE OF typ_crapcop INDEX BY PLS_INTEGER;
    vr_crapcop       typ_tab_crapcop;

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;
    vr_erro          EXCEPTION;
    
    -- Constantes com os historicos dos lancamentos
    vc_cr_pd         craphis.cdhistor%TYPE := 1956; -- Tipo lancamento CREDITO para produto DEBITO
    vc_cr_pc         craphis.cdhistor%TYPE := 1957; -- Tipo lancamento CREDITO para produto CREDITO
    vc_db_pd         craphis.cdhistor%TYPE := 1959; -- Tipo lancamento DEBITO para produto DEBITO
    vc_at_pc         craphis.cdhistor%TYPE := 1958; -- Tipo lancamento ANTECIPACAO para produto CREDITO
    
    -- Variaveis gerais
    vr_dserro        VARCHAR2(100);         --> Variavel de erro
    vr_inpessoa      crapass.inpessoa%TYPE; --> Indicador de tipo de pessoa
    vr_cdcooper      crapcop.cdcooper%TYPE; --> Codigo da cooperativa
    vr_cdhistor      craphis.cdhistor%TYPE; --> Codigo do historico do lancamento
    vr_nrdolote      craplot.nrdolote%TYPE; --> Numero do lote
    vr_qterros       PLS_INTEGER := 0;      --> Quantidade de registros com erro
    vr_qtprocessados PLS_INTEGER := 0;      --> Quantidade de registros processados
    vr_qtfuturos     PLS_INTEGER := 0;      --> Quantidade de lancamentos futuros processados
    vr_inlctfut      VARCHAR2(01);          --> Indicador de lancamento futuro
    
    vr_coopdest      crapcop.cdcooper%TYPE; --> coop destino (incorporacao/migracao)
    vr_nrdconta      crapass.nrdconta%TYPE; 
  BEGIN
    -- Busca a data do sistema
    OPEN btch0001.cr_crapdat(3); -- Utiliza a cooperativa da Cecred
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    -- Popula a pl/table de agencia
    FOR rw_crapcop IN cr_crapcop LOOP
      vr_crapcop(rw_crapcop.cdagebcb).cdcooper := rw_crapcop.cdcooper;
      vr_crapcop(rw_crapcop.cdagebcb).nmrescop := rw_crapcop.nmrescop;
      vr_crapcop(rw_crapcop.cdagebcb).flgativo := rw_crapcop.flgativo;
    END LOOP;
      
    -- Efetua loop sobre os registros pendentes
    FOR rw_tabela IN cr_tabela LOOP
      -- Limpa a variavel de erro
      vr_dserro := NULL;  
      
      -- Verifica se eh um lancamento futuro
      IF rw_tabela.dtreferencia > rw_crapdat.dtmvtolt THEN
        vr_inlctfut := 'S';
      ELSE
        vr_inlctfut := 'N';
      END IF;
    
      -- Efetua todas as consistencias dentro deste BEGIN
      BEGIN
        -- Atualiza o indicador de inpessoa
        IF rw_tabela.tppessoa = 'PF' THEN
          vr_inpessoa := 1;
        ELSIF rw_tabela.tppessoa = 'PJ' THEN
          vr_inpessoa := 2;
        ELSE
          vr_dserro := 'Indicador de pessoa ('||rw_tabela.tppessoa||') nao previsto.';
          RAISE vr_erro;
        END IF;

        -- Verifica se a agencia informada existe
        IF NOT vr_crapcop.exists(rw_tabela.cdagebcb) THEN
          vr_dserro := 'Agencia informada ('||rw_tabela.cdagebcb||') nao cadastrada.';
          RAISE vr_erro;
        END IF;
      
        -- Efetua consistencia basica sobre os dados
        IF rw_tabela.tplancamento NOT IN ('CR','AT','DB') THEN
          vr_dserro := 'Tipo de lancamento ('||rw_tabela.tplancamento||') nao previsto.';
          RAISE vr_erro;
        ELSIF rw_tabela.tpproduto NOT IN ('PC','PD') THEN
          vr_dserro := 'Tipo de produto ('||rw_tabela.tpproduto||') nao previsto.';
          RAISE vr_erro;
        END IF;
          
        -- Efetua as consistencias sobre o registro pendente
        IF NOT vr_crapcop.exists(rw_tabela.cdagebcb) THEN
          vr_dserro := 'Agencia informada ('||rw_tabela.cdagebcb||') inexistente.';
          RAISE vr_erro;
        ELSIF rw_tabela.tplancamento = 'DB' AND rw_tabela.tpproduto = 'PC' THEN
          vr_dserro := 'Tipo de lancamento DEBITO nao contempla produto CREDITO';
          RAISE vr_erro;
        ELSIF rw_tabela.tplancamento = 'AT' AND rw_tabela.tpproduto = 'PD' THEN
          vr_dserro := 'Tipo de lancamento ANTECIPACAO nao contempla produto DEBITO';
          RAISE vr_erro;
        ELSIF rw_tabela.vllancamento = 0 THEN
          vr_dserro := 'Valor do lancamento zerado';
          RAISE vr_erro;
        END IF;
        
        IF vr_crapcop(rw_tabela.cdagebcb).flgativo = 0 THEN
          
          OPEN cr_craptco (pr_cdcopant => vr_crapcop(rw_tabela.cdagebcb).cdcooper,
                           pr_nrctaant => rw_tabela.nrdconta);
          FETCH cr_craptco INTO rw_craptco;
          
          IF cr_craptco%FOUND THEN
            vr_nrdconta := rw_craptco.nrdconta;
            vr_coopdest := rw_craptco.cdcooper;
          ELSE
           vr_nrdconta := 0;
           vr_coopdest := 0;
          END IF;
        
          CLOSE cr_craptco;
          
        ELSE
          vr_nrdconta := rw_tabela.nrdconta;
          vr_coopdest := vr_crapcop(rw_tabela.cdagebcb).cdcooper;          
        END IF;
        
        -- Busca os dados do associado
        OPEN cr_crapass(vr_coopdest, vr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN -- Se nao encontrar, deve-se gerar inconsistencia
          CLOSE cr_crapass;
          vr_dserro := 'Conta do associado ('||gene0002.fn_mask_conta(rw_tabela.nrdconta)||') inexistente para a cooperativa '||
                       vr_crapcop(rw_tabela.cdagebcb).nmrescop||'.';
          RAISE vr_erro;
        END IF;
        CLOSE cr_crapass;
        
        -- Efetua consistencia sobre o associado
        IF rw_crapass.inpessoa <> vr_inpessoa THEN
          vr_dserro := 'Associado eh uma pessoa ';
          IF rw_crapass.inpessoa = 1 THEN
            vr_dserro := vr_dserro ||'fisica, porem foi enviado um ';
          ELSE
            vr_dserro := vr_dserro ||'juridica, porem foi enviado um ';
          END IF;
          IF vr_inpessoa = 1 THEN
            vr_dserro := vr_dserro ||'CPF.';
          ELSE
            vr_dserro := vr_dserro ||'CNPJ.';
          END IF;
          RAISE vr_erro;
        ELSIF rw_crapass.nrcpfcgc <> rw_tabela.nrcpfcgc AND rw_crapass.inpessoa = 1 THEN
            vr_dserro := 'CPF informado ('||gene0002.fn_mask_cpf_cnpj(rw_tabela.nrcpfcgc,vr_inpessoa)||
                         ') difere do CPF do associado ('||gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,rw_crapass.inpessoa)||').';
          RAISE vr_erro;
        ELSIF substr(lpad(rw_crapass.nrcpfcgc,14,0),1,8) <> substr(lpad(rw_tabela.nrcpfcgc,14,0),1,8) AND rw_crapass.inpessoa = 2 then
          vr_dserro := 'Base do CNPJ informado ('||substr(lpad(rw_tabela.nrcpfcgc,14,0),1,8)||
                       ') difere da base do CNPJ do associado ('||substr(lpad(rw_crapass.nrcpfcgc,14,0),1,8)||').';
          RAISE vr_erro;
        END IF;
        
        --Validacao de registro repetido Chamado 372646
        OPEN cr_registro_repetido(rw_tabela.nrseq_sicoob);
        FETCH cr_registro_repetido INTO rw_registro_repetido;
        IF cr_registro_repetido%FOUND THEN -- Se nao encontrar, deve-se gerar inconsistencia
          vr_dserro := 'Registro ja processado no dia '||to_char(rw_registro_repetido.dhprocessamento,'DD/MM/YYYY')
                     ||' as '||to_char(rw_registro_repetido.dhprocessamento,'HH24:MI:SS');
          CLOSE cr_registro_repetido;
          RAISE vr_erro;
        END IF;
        CLOSE cr_registro_repetido;
        --Validacao de registro repetido
      EXCEPTION
        WHEN vr_erro THEN
          NULL;
      END;  
      
      -- Atualiza os historicos de lancamento
      IF rw_tabela.tplancamento = 'DB' THEN
        vr_cdhistor := vc_db_pd;
        vr_nrdolote := 8509;
      ELSIF rw_tabela.tplancamento = 'CR' THEN
        IF rw_tabela.tpproduto = 'PC' THEN
          vr_cdhistor := vc_cr_pc;
          vr_nrdolote := 8507;
        ELSE
          vr_cdhistor := vc_cr_pd;
          vr_nrdolote := 8508;
        END IF;
      ELSE
        vr_cdhistor := vc_at_pc;
        vr_nrdolote := 8510;
      END IF;


      -- Se nao existir erro, insere o lancamento
      IF vr_dserro IS NULL AND
         rw_tabela.dtreferencia <= rw_crapdat.dtmvtolt THEN -- Nao integrar lancamentos futuros

        -- Atualiza a cooperativa
        vr_cdcooper := vr_coopdest;

        -- Se nao existir registro na CRAPLOT ou 
        IF rw_craplot.cdcooper IS NULL OR 
           rw_craplot.cdcooper <> vr_cdcooper OR -- a cooperativa for diferente da que ja foi encontrada
           rw_craplot.nrdolote <> vr_nrdolote THEN -- o historico for diferente do que ja foi encontrado, verifica novamente
          -- Abre o cursor de capas de lote
          OPEN cr_craplot(pr_cdcooper => vr_cdcooper,
                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                          pr_cdagenci => 1,
                          pr_cdbccxlt => 100,
                          pr_nrdolote => vr_nrdolote);
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
                (rw_crapdat.dtmvtolt,
                 rw_crapdat.dtmvtolt,
                 1,
                 100,
                 '1',
                 vr_nrdolote,
                 9,
                 1,
                 vr_cdhistor,
                 vr_cdcooper,
                 0)
               RETURNING ROWID, nrseqdig, cdcooper, nrdolote
                    INTO rw_craplot.rowid, rw_craplot.nrseqdig, rw_craplot.cdcooper, rw_craplot.nrdolote;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir CRAPLOT: ' ||SQLERRM;
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
                 vlcompdb = vlcompdb + decode(rw_tabela.tpproduto,'PD',rw_tabela.vllancamento,0),
                 vlcompcr = vlcompcr + decode(rw_tabela.tpproduto,'PC',rw_tabela.vllancamento,0),
                 vlinfodb = vlcompdb + decode(rw_tabela.tpproduto,'PD',rw_tabela.vllancamento,0),
                 vlinfocr = vlcompcr + decode(rw_tabela.tpproduto,'PC',rw_tabela.vllancamento,0)
           WHERE ROWID = rw_craplot.rowid
           RETURNING nrseqdig INTO rw_craplot.nrseqdig; --> Atualizar nrseqdig para insert na lcm
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar CRAPLOT: ' ||SQLERRM;
        END;

        -- insere o registro na tabela de lancamentos
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
            (rw_crapdat.dtmvtolt,                               --dtmvtolt
             1,                                                 --cdagenci
             100,                                               --cdbccxlt
             vr_nrdolote,                                       --nrdolote
             vr_nrdconta,                                --nrdconta
             rw_craplot.nrseqdig,                               --nrdocmto
             vr_cdhistor,                                       --cdhistor
             rw_craplot.nrseqdig,                               --nrseqdig
             rw_tabela.vllancamento,                            --vllanmto
             vr_nrdconta,                                --nrdctabb
             gene0002.fn_mask(vr_nrdconta,'99999999'),   --nrdctitg
             vr_cdcooper,                                       --cdcooper
             rw_crapdat.dtmvtolt,                               --dtrefere
             '1');                                              --cdoperad
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir CRAPLCM: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Atualiza a quantidade de registros processados com sucesso
        vr_qtprocessados := vr_qtprocessados + 1;
      ELSIF vr_dserro IS NOT NULL THEN
        -- Atualiza a quantidade de registros com erros
        vr_qterros := vr_qterros + 1;
      
      ELSE -- Lancamentos futuros
        vr_qtfuturos := vr_qtfuturos + 1;
        
      END IF;
      
      -- Efetua a atualizacao da tabela de controle
      BEGIN
        UPDATE tbdomic_arq_lancto_cartoes
           SET insituacao = decode(vr_dserro,NULL,
                                                  decode(vr_inlctfut,'N',1,0),
                                                  2),
               dserro = vr_dserro,
               dhprocessamento = SYSDATE,
               nrdolote = decode(vr_dserro,NULL,
                                                decode(vr_inlctfut,'N',vr_nrdolote,NULL),
                                                NULL),
               nrseqdig = decode(vr_dserro,NULL,
                                                decode(vr_inlctfut,'N',rw_craplot.nrseqdig,NULL),
                                                NULL)
         WHERE idlancamento = rw_tabela.idlancamento;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar tabela tbdomic_arq_lancto_cartoes: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
    END LOOP;

    -- Se possuir algum registro com erro ou processado
    IF vr_qtprocessados > 0 OR vr_qterros > 0 OR vr_qtfuturos > 0 THEN
      -- Gera log de quantidade de registros processados
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
                                ,pr_ind_tipo_log => 1 -- Aviso
                                ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                 || 'Registros processados com sucesso: '||vr_qtprocessados
                                                 || '. Registros futuros processados com sucesso: '||vr_qtfuturos
                                                 || '. Registros com erro: '||vr_qterros||'.'
                                ,pr_nmarqlog => 'CONLDB');
    END IF;


  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
      pr_cdcritic := vr_cdcritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
    
  END;


  -- Rotina para processar os lancamentos pendentes
  PROCEDURE envia_email_falta_arquivo(pr_dscritic OUT VARCHAR2)  IS
    
    -- Cursor para verificar se existe lancamento neste dia
    CURSOR cr_tabela IS
      SELECT nvl(SUM(decode(tplancamento,'AT',1,0)),0) qtantecipacao,
             nvl(SUM(decode(tplancamento,'AT',0,1)),0) qtcre_deb
        FROM tbdomic_arq_lancto_cartoes
       WHERE trunc(dhinclusao) = trunc(SYSDATE);
    rw_tabela cr_tabela%ROWTYPE;

    -- Variável de críticas
    vr_dscritic      VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;
    
    -- Variaveis gerais
    vr_hrlimite_cre_deb DATE;  --> Horario limite do arquivo de credito e debito
    vr_hrlimite_antecip DATE;  --> Horario limite do arquivo de antecipacoes
    vr_dstexto VARCHAR2(500);  --> Texto que sera enviado no email
    vr_emaildst VARCHAR2(200); --> Endereco do e-mail de destino
  BEGIN
    -- Busca o horario limite para o arquivo de credito / debito
    vr_hrlimite_cre_deb := to_date(to_char(SYSDATE,'YYYYMMDD')||
           gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdacesso => 'HR_ARQ_CRE_DEB_DOMICILIO'),'YYYYMMDDHH24:MI');

    -- Busca o horario limite para o arquivo de antecipacoes
    vr_hrlimite_antecip := to_date(to_char(SYSDATE,'YYYYMMDD')||
           gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdacesso => 'HR_ARQ_ANTECIP_DOMICILIO'),'YYYYMMDDHH24:MI');

    -- Se passou de algum destes horarios, devera verificar se veio o arquivo
    IF SYSDATE > vr_hrlimite_antecip OR SYSDATE > vr_hrlimite_cre_deb THEN
      -- Busca a quantidade de registros por tipo de arquivo
      OPEN cr_tabela;
      FETCH cr_tabela INTO rw_tabela;
      CLOSE cr_tabela;
      
      -- Se ja passou do horario de antecipacoes, mas nao veio nenhuma informacao
      IF SYSDATE > vr_hrlimite_antecip AND rw_tabela.qtantecipacao = 0 THEN
        vr_dstexto := 'O arquivo de <b>ANTECIPACAO</b> do dia '||to_char(SYSDATE,'dd/mm/yyyy')||' nao foi recebido ate o presente horario ('||
                      to_char(sysdate,'HH24:MI')||'). Favor verificar!<br>';
      END IF;

      -- Se ja passou do horario de creditos / debitos, mas nao veio nenhuma informacao
      IF SYSDATE > vr_hrlimite_cre_deb AND rw_tabela.qtcre_deb = 0 THEN
        vr_dstexto := nvl(vr_dstexto,'')||
                      'O arquivo de <b>CREDITOS/DEBITOS</b> do dia '||to_char(SYSDATE,'dd/mm/yyyy')||' nao foi recebido ate o presente horario ('||
                      to_char(sysdate,'HH24:MI')||'). Favor verificar!';
      END IF;
      
      -- Se houve atraso, envia o email
      IF vr_dstexto IS NOT NULL THEN
        -- Gravar email destino
        vr_emaildst := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdacesso => 'EMAIL_DOMICILIO');
        -- Enviar e-mail dos dados deste sinistro
        gene0003.pc_solicita_email(pr_cdcooper        => 3
                                  ,pr_cdprogra        => 'CCRD0004'
                                  ,pr_des_destino     => vr_emaildst
                                  ,pr_des_assunto     => 'Atraso nos arquivos de DOMICILIO BANCARIO'
                                  ,pr_des_corpo       => vr_dstexto
                                  ,pr_des_anexo       => NULL
                                  ,pr_des_erro        => vr_dscritic);
        -- Caso encontre alguma critica no envio do email                          
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;  
    END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Atualiza variavel de retorno
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_dscritic := sqlerrm;
    
  END envia_email_falta_arquivo;

  -- Rotina para o processamento do arquivo oriundo do Sicoob
  PROCEDURE pc_efetua_processo(pr_cdcritic OUT crapcri.cdcritic%TYPE
                              ,pr_dscritic OUT VARCHAR2)  IS

    -- Cursor sobre a tabela de feriados
    CURSOR cr_crapfer IS
      SELECT 1
        FROM crapfer
       WHERE dtferiad = trunc(SYSDATE);
    rw_crapfer cr_crapfer%ROWTYPE;
    
    -- Verifica se alguma cooperativa esta em processo noturno
    CURSOR cr_crapdat IS
      SELECT 1
        FROM crapdat
       WHERE inproces <> 1; -- Diferente de processo normal
    rw_crapdat cr_crapdat%ROWTYPE;

    -- PL/Table que vai armazenar os nomes de arquivos a serem processados
    vr_tab_arqtmp      gene0002.typ_split;
    vr_indice          integer;

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;

    -- Variaveis gerais
    vr_dsdiretorio VARCHAR2(100);      --> Local onde esta os arquivos Sicoob
    vr_listaarq    VARCHAR2(4000);     --> Lista de arquivos

    vr_cdprogra    VARCHAR2(40) := 'PC_EFETUA_PROCESSO';
    vr_nomdojob    VARCHAR2(40) := 'JBCRD_DOMICILIO_BANCARIO';
    vr_flgerlog    BOOLEAN := FALSE;

    --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3    --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
    END pc_controla_log_batch;

    BEGIN
    
    -- Se for um feriado, nao deve executar o fonte
    OPEN cr_crapfer;
    FETCH cr_crapfer INTO rw_crapfer;
    IF cr_crapfer%FOUND THEN
      CLOSE cr_crapfer;
      RETURN; -- Encerra o programa;
    END IF;
    CLOSE cr_crapfer;
  
    -- Verifica se alguma cooperativa esta em processo noturno
    OPEN cr_crapdat;
    FETCH cr_crapdat INTO rw_crapdat;
    IF cr_crapdat%FOUND THEN
      CLOSE cr_crapdat;
      RETURN; -- Encerra o programa;
    END IF;
    CLOSE cr_crapdat;
    
    -- Busca o diretorio onde esta os arquivos Sicoob
    vr_dsdiretorio := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdacesso => 'ROOT_DOMICILIO');

    -- Listar arquivos
    gene0001.pc_lista_arquivos( pr_path     => vr_dsdiretorio
                               ,pr_pesq     => '%.csv'
                               ,pr_listarq  => vr_listaarq
                               ,pr_des_erro => vr_dscritic);
    -- Se ocorreu erro, cancela o programa
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Se possuir arquivos para serem processados
    IF vr_listaarq IS NOT NULL THEN

      -- Log de inicio de execucao
      pc_controla_log_batch(pr_dstiplog => 'I');

      --Carregar a lista de arquivos txt na pl/table
      vr_tab_arqtmp := gene0002.fn_quebra_string(pr_string => vr_listaarq);
      
      -- Leitura da PL/Table e processamento dos arquivos
      vr_indice := vr_tab_arqtmp.first;
      WHILE vr_indice is not null LOOP
        -- Chama o procedimento que faz a leitura do arquivo
        processa_arquivos(vr_dsdiretorio,
                          vr_tab_arqtmp(vr_indice),
                          vr_dscritic);
        -- Se ocorreu erro cancela o processo
        IF vr_dscritic IS NOT NULL THEN
          -- Gera log de arquivo com erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
                                    ,pr_ind_tipo_log => 3 -- Erro
                                    ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                     || 'Arquivo '||vr_tab_arqtmp(vr_indice)||' com erro: '||vr_dscritic
                                    ,pr_nmarqlog => 'CONLDB');

          RAISE vr_exc_saida;
        END IF;

        -- Gera log de arquivo processado
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
                                  ,pr_ind_tipo_log => 1 -- Aviso
                                  ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                   || 'Processado arquivo '||vr_tab_arqtmp(vr_indice)||' com sucesso'
                                  ,pr_nmarqlog => 'CONLDB');
        
        -- Vai para o proximo registro
        vr_indice := vr_tab_arqtmp.next(vr_indice);
      END LOOP;
    END IF;
    ------------ Fim do processo de leitura dos arquivos

    ------------ Inicio do processamento dos registros pendentes
    processa_registros_pendentes(vr_cdcritic, vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    -- Efetua gravacao dos registros
    COMMIT;
    
    -- Verifica se os arquivos foram exportados para envio do e-mail
    envia_email_falta_arquivo(vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Log de fim da execucao
    pc_controla_log_batch(pr_dstiplog => 'F');

    -- Efetua gravacao dos registros
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
      pr_cdcritic := vr_cdcritic;

      -- Log de erro de execucao
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => pr_dscritic);

      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;

      pc_internal_exception;
      
      -- Log de erro de execucao
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => pr_dscritic);

  END;
  
  PROCEDURE pc_efetua_processo_web(pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica                                  
                                  ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

  BEGIN
    BEGIN
      pc_efetua_processo(pr_cdcritic => pr_cdcritic, 
                         pr_dscritic => pr_dscritic);                       
      EXCEPTION
        WHEN OTHERS THEN
        pc_internal_exception(3, pr_dscritic);
  END;
  END; -- END pc_efetua_processo_web

END CCRD0004;
/
