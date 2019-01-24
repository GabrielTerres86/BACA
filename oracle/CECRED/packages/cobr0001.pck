CREATE OR REPLACE PACKAGE CECRED.cobr0001 AS

/* .............................................................................

   Programa: cobr0001 (Antigo b1wgen0010.p)
   Autora  : Ze Eduardo
   Data    : 12/09/2005                     Ultima atualizacao: 15/06/2015

   Dados referentes ao programa:

   Objetivo  : bo consulta bloquetos de cobranca

   Alteracoes: 19/05/2006 - Incluido codigo da cooperativa nas leituras das
                            tabelas (Diego).

               10/08/2006 - Alterado parametro "p-ini-documento" de INTEGER
                            para DECIMEAL (Julio)

               16/10/2006 - Alterado estrutura da BO (David).

               04/12/2006 - Desabilitado calculo do digito verificador do nosso
                            numero. Alterada tabela crapttl para crapass na
                            gravacao da procedure proc_nosso_numero (David).

               22/12/2006 - Buscar dados do sacado na tabela crapsab (David).

               19/03/2007 - Acerto ao obter convenio CECRED - nrcnvceb (David).

               20/03/2007 - Permitir pesquisa pelo nome do sacado, e por nr.
                            do documento - INTERNET (David).

               20/04/2007 - Efetuar retorno do campo "Complemento" na
                            temp-table (David).

               23/07/2007 - Tratamento para strings que contenham o caracter
                            especial "&" (David).

               11/03/2008 - Implementacao da rotina gera_retorno_arq_cobranca
                            com base no programa crps464 (Sidnei - Precise).
                          - Utilizar include para temp-tables (David).

               02/04/2008 - Incluido na leitura do crapcob da rotina
                            gera_retorno_arq_cobranca a possiblidade de ler
                            registro com numero de convenio zerado (Elton).

               19/04/2008 - Limpar temp-table tt-arq-cobranca ao enviar arquivo
                            quando origem for AYLLOS (David).

               09/05/2008 - Retornar nome do titular nos boletos consultados
                            (David).

               25/07/2008 - Retornar situacao do boleto qndo nao for internet
                            (David).

               11/09/2008 - Corrigir forma para gravacao da quantidade de
                            registros encontrados na consulta efetuada pela
                            internet - campo tt-consulta-blt.nrregist (David).

               05/02/2009 - Incluir gera_retorno_arq_cobranca_viacredi.
                            Procedure temporaria e especifica para somente
                            um numero de convenio para a Viacredi. Utilizada
                            para atender o Software Alpes - Adilson (Ze).

               19/02/2009 - Melhorias no servico de cobranca (David).

               28/05/2009 - Carregar numero de variacao de carteira do convenio
                            para os boletos (David).

               01/06/2009 - Inclusao de procedures para validacao de arquivo
                            de cobranca, anteriormente implementada no programa
                            valcob ( Sidnei - Precise ).

               31/07/2009 - Efetuado acerto na critica ref. Numero de inscricao
                            (Diego).

               10/06/2010 - Tratamento para pagamento realizado atraves de TAA
                            (Elton).

               22/07/2010 - Incluido parametro p-flgdpagto na procedure
                            gera_retorno_arq_cobranca_viacredi  (Elton).

               31/08/2010 - Incluido caminho completo nos arquivos gravados
                            no diretorio "arq" (Elton).

               16/09/2010 - Alteracao dos parametros da procedure
                            gera_retorno_arq_cobranca_coopcob e alteracao da
                            logica para processar apenas convenios com
                            indicador CoopCob TRUE (Guilherme/Supero).

               15/02/2011 - Critica para verificar a existencia do registro
                            do crapceb (Gabriel).

               11/03/2011 - Retirar campo dsdemail e inarqcbr da crapass
                           (Gabriel).

               12/05/2011 - Tratamento para incobran 0,3,4,5 (Guilherme).

               26/05/2011 - Novos relatorios 5 e 6 (Guilherme/Supero).

               27/05/2011 - Adicionado campos nrinsava e cdtpinav para a
                            tt-consulta-blt (Jorge).

               21/06/2011 - Alterado gera_retorno_arq_cobranca
                            incluido parametro para filtrar cob sem reg.
                            (Rafael)

               24/06/2011 - replace de caracter especial em p_grava_boleto
                            tt-consulta-blt (Jorge).

               08/07/2011 - Adicionado condicional em consulta-bloqueto (Jorge).

               13/07/2011 - Gravado crapret.dtocorre no campo
                            tt-consulta-blt.dtocorre na procedure
                            consulta-bloqueto (Adriano).

               20/07/2011 - Adicionado em procedure consulta-bloqueto, quando
                            p-consultar = 14, busca de descricao do motivo
                            Adicionado parametros de Motivo (Jorge).

               22/07/2011 - Alteracao no tipo p-consultar = 14 para alimentar
                            os campos vloutdes, vloutcre (Adriano).

               04/08/2011 - Alterado procedure proc_nosso_numero, adicionado
                            condicoes 5 e 6 e 7 (Jorge).

               25/08/2011 - Criado procedure retorna-convenios-remessa (Jorge).

               05/09/2011 - Tratamento na geracao do arq. CoopCob (Ze).

               06/09/2011 - Adicionado campo nrlinseq (Jorge).

               14/09/2011 - Criado procedure consulta-boleto-2via (Jorge)

               06/10/2011 - Removido o filtro por crapceb.insitceb = 1 no
                            FIND LAST da crapceb, para as procedures
                            p_grava_bloqueto e proc_nosso_numero. Na procedure
                            consulta-bloqueto, filtrado no tipo de consulta 7,
                            pelo parametro da conta(p-nro-conta). (Fabricio)

               25/10/2011 - Tratamento de juros/multa/descto na rotina
                            p_grava_bloqueto (Fabricio).

               12/12/2011 - Adicionado nr do imovel no endereco do sacado
                            proc p_grava_bloqueto (Rafael).

               12/03/2012 - Alterado rotina de geracao de arquivo de retorno
                            ao cooperado pois estava provocando erro na cadeia.
                            Tarefa 45747. (Rafael)

               23/04/2012 - Quando consulta 6 utilizar conta/dv do cooperado
                            para localizar os titulos do sacado. (Rafael)

               04/06/2012 - Adaptaçao dos fontes para projeto Oracle. Retirada
                            do prefixo "banco" (Guilherme Maba).

               13/08/2012 - Ajuste na tt-consulta-blt ref aos titulos da cob.
                            registrada descontados. (Rafael)
                          - Adicionado campo de tipo de cobranca na rotina
                            de exportar titulos. (Rafael)

               27/08/2012 - Tratamento para Dt. de Venct. nao informada
                            (conv. pré-impresso) (Lucas).

               03/10/2012 - Ajuste na consulta de titulos ref a titulos pagos
                            com cheque (crapcob.dcmc7chq) (Rafael).

               15/10/2012 - Ajustes de performance em consulta-bloqueto.
                            (Rafael/Jorge)

               07/01/2013 - Ler todos os convenios de Internet na procedure
                            gera_totais_cobranca (David)

               22/01/2013 - Ajuste na rotina de geracao de arquivo CoopCob
                            ref. aos titulos migrados Alto Vale. (Rafael)
                          - Ajuste em campo tt-consulta-blt.nrnosnum da proc.
                            proc_nosso_numero. (Jorge/Rafael)

               19/02/2013 - Ajuste nossonumero ref. ao CEB 5 digitos (Rafael).

               08/03/2013 - Ajuste em gerar arquivo de retorno, data de credito
                            ajustada para pegar D + 1 ao invez de D + 0 quando
                            em condicao especial para boletos Banco do Brasil em
                            proc. p_gera_arquivo_febraban. (Jorge)

               11/04/2013 - Retirado condicao para nao imprimir boletos DDA em
                            proc. consulta-boleto-2via (Jorge).

               25/04/2013 - Projeto Melhorias da Cobranca - implementar rotina
                            de importacao de titulos CNAB240 - 085. (Rafael)

               03/05/2013 - Projeto Melhorias da Cobranca - implementar
                            instrucoes 7, 8 e 31 referentes a
                            "Conceder Desconto", "Cancelar Desconto" e
                            "Alterar Dados do Sacado" em proc. grava_instrucoes
                            (Jorge)

               31/05/2013 - Projeto Melhorias da Cobranca - implementar rotina
                            de importacao de titulos CNAB400 - 085.
                            (Anderson/AMCOM, Rafael)

               25/06/2013 - Buscar valores das tarifas da b1wgen00153 (Tiago).

               15/07/2013 - Buscar primeiro titular como cedente do boleto qdo
                            cooperado for PF. (Rafael)

               12/09/2013 - Ajuste no campo tt-consulta-blt.dtdocmto. (Rafael)

               11/10/2013 - Incluido parametro cdprogra nas procedures da
                            b1wgen0153 que carregam dados de tarifas (Tiago).

               06/11/2013 - Conversao Progress -> Oracle (Edison - AMcom)

               15/10/2014 - Alterado o index da temptable typ_tab_arq_cobranca
                           para correta leitura e ordenação do campo (Odirlei - AMcom)

               15/06/2015 - Adicionado pc_carrega_parcelas_carne para carregar as parcelas
                            pertencentes ao carnê, possibilitando a reimpressão do carnê
                            (Projeto Boleto Formato Carnê - Douglas)
............................................................................ */
  --Tipo de Registro para arquivos
  -- Indice: tparquiv nrconven nrdconta nrdocmto
  TYPE typ_reg_crawarq IS
    RECORD( tparquiv INTEGER
          ,nrdconta crapcob.nrdconta%TYPE
          ,nrconven crapcob.nrcnvcob%TYPE
          ,nrdocmto crapcob.nrdocmto%TYPE
          ,tamannro crapcco.tamannro%TYPE
          ,nrdctabb crapcco.nrdctabb%TYPE
          ,vldpagto crapcob.vldpagto%TYPE
          ,vlrtarcx crapcco.vlrtarcx%TYPE
          ,vlrtarnt crapcco.vlrtarnt%TYPE
          ,vlrtarcm crapcco.vlrtarif%TYPE
          ,vltrftaa crapcco.vltrftaa%TYPE
          ,indpagto crapcob.indpagto%TYPE
          ,inarqcbr INTEGER
          ,flgutceb crapcco.flgutceb%TYPE
          ,dsorgarq crapcco.dsorgarq%TYPE
          ,dtdpagto crapcob.dtdpagto%TYPE
          ,dsdemail crapcem.dsdemail%TYPE
          ,cdbandoc crapcob.cdbandoc%TYPE
          ,dtcredit crapcob.dtdpagto%TYPE);

  --Tipo de tabela de memoria para convenios
  TYPE typ_tab_crawarq IS TABLE OF typ_reg_crawarq INDEX BY VARCHAR2(100);

  -- Variavel para armazenar a tabela de memoria de convenios
  vr_tab_crawarq typ_tab_crawarq;

  -- tipo de tabela para conseguir controlar por tipo de arquivo
  TYPE typ_tab_arq  is table of typ_tab_crawarq index by pls_integer;

  --Tipo de Registro para arquivos de cobranca
  TYPE typ_reg_arq_cobranca IS
    RECORD ( cdseqlin NUMBER
            ,dslinha  VARCHAR2(4000));

  --Tipo de tabela de memoria para convenios
  TYPE typ_tab_arq_cobranca IS TABLE OF typ_reg_arq_cobranca INDEX BY VARCHAR2(100);

  -- Variavel para armazenar a tabela de memoria de convenios
  vr_tab_arq_cobranca typ_tab_arq_cobranca;

  -- Procedure para retornar o valor das tarifas
  PROCEDURE pc_pega_valor_tarifas( pr_cdcooper IN crapcop.cdcooper%type     -- Codigo da cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE     -- Numero Conta
                                  ,pr_cdprogra IN VARCHAR2                  -- Codigo do programa
                                  ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE     -- Codigo do convenio
                                  ,pr_inpessoa IN INTEGER                   -- Indica o tipo de pessoa Fisica/Juridica
                                  ,pr_cdhistor OUT INTEGER                  -- Codigo do historico
                                  ,pr_cdhisest OUT INTEGER                  -- Codigo do historico de estorno
                                  ,pr_dtdivulg OUT DATE                     -- Data divulgacao
                                  ,pr_dtvigenc OUT DATE                     -- data vigencia
                                  ,pr_cdfvlcop OUT INTEGER                  -- Codigo da cooperativa
                                  ,pr_vlrtarcx OUT NUMBER                   -- Valor tarifa caixa
                                  ,pr_vlrtarnt OUT NUMBER                   -- Valor tarifa internet
                                  ,pr_vltrftaa OUT NUMBER                   -- Valor tarifa TAA
                                  ,pr_vlrtarif OUT NUMBER                   -- Valor tarifa
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE    -- Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2                 -- Descricao da critica/erro
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro  ); -- Tabela de erros

  /* Gerar os arquivos de retorno das baixas processadas */
  PROCEDURE pc_gera_retorno_arq_cob_coop(pr_cdcooper IN crapcop.cdcooper%TYPE   -- Codigo da cooperativa
                                        ,pr_cdprogra IN VARCHAR2                -- Codigo do programa
                                        ,pr_dtmvtolt IN DATE                    -- Data do movimento
                                        ,pr_cdagenci IN INTEGER                 -- Codigo da agencia
                                        ,pr_nrocaixa IN INTEGER                 -- Codigo do caixa
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE  -- Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2               -- Descricao da critica
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro);-- tabela de erros

  /* Consulta de saques */
  PROCEDURE pc_taa_lancto_titulos_conv(pr_cdcooper        IN  crapcop.cdcooper%TYPE,
                                       pr_cdcoptfn        IN  craplcm.cdcoptfn%TYPE,
                                       pr_dtmvtoin        IN  DATE,
                                       pr_dtmvtofi        IN  DATE,
                                       pr_cdtplanc        IN  PLS_INTEGER,
                                       pr_dscritic        OUT VARCHAR2,
                                       pr_tab_lancamentos OUT CADA0001.typ_tab_lancamentos);

  /* Consulta de agendamento de pagamentos */
  PROCEDURE pc_taa_agenda_titulos_conv(pr_cdcooper        IN  crapcop.cdcooper%TYPE,
                                       pr_cdcoptfn        IN  craplcm.cdcoptfn%TYPE,
                                       pr_dtmvtoin        IN  DATE,
                                       pr_dtmvtofi        IN  DATE,
                                       pr_cdtplanc        IN  PLS_INTEGER,
                                       pr_dscritic        OUT VARCHAR2,
                                       pr_tab_lancamentos OUT CADA0001.typ_tab_lancamentos);

  /* Gerar os arquivos de retorno do arquivo de cobrança */
  PROCEDURE pc_gera_retorno_arq_cobranca(pr_cdcooper IN crapcop.cdcooper%TYPE        -- Codigo da cooperativa
                                        ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype  -- registro com as data do sistema
                                        ,pr_nrdconta IN crapass.nrdconta%type        -- Numero da conta
                                        ,pr_dtpgtini IN DATE                         -- data inicial do pagamento
                                        ,pr_dtpgtfim IN DATE                         -- Data final do pagamento
                                        ,pr_nrcnvcob IN INTEGER                      -- Numero do convenio de cobrança
                                        ,pr_cdagenci IN INTEGER                      -- Codigo da agencia para erros
                                        ,pr_nrdcaixa IN INTEGER                      -- Codigo do caixa para erros
                                        ,pr_origem   IN INTEGER                      -- indicador de origem /* 1-AYLLOS/2-CAIXA/3-INTERNET */
                                        ,pr_cdprogra IN VARCHAR2                     -- Codigo do programa
                                        ,pr_des_reto OUT VARCHAR2                    -- Descricao do retorno 'OK/NOK'
                                        ,pr_tab_arq_cobranca OUT COBR0001.typ_tab_arq_cobranca -- temptable com as linhas do arquivo de cobrança
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro);     -- tabela de erros
                                        
  /* Gerar os arquivos de retorno do arquivo de cobrança */
  PROCEDURE pc_gera_ret_arq_cobranca_car(pr_cdcooper IN crapcop.cdcooper%TYPE        -- Codigo da cooperativa                                            
                                        ,pr_nrdconta IN crapass.nrdconta%type        -- Numero da conta
                                        ,pr_dtpgtini IN DATE                         -- data inicial do pagamento
                                        ,pr_dtpgtfim IN DATE                         -- Data final do pagamento
                                        ,pr_nrcnvcob IN INTEGER                      -- Numero do convenio de cobrança
                                        ,pr_cdagenci IN INTEGER                      -- Codigo da agencia para erros
                                        ,pr_nrdcaixa IN INTEGER                      -- Codigo do caixa para erros
                                        ,pr_origem   IN INTEGER                      -- indicador de origem /* 1-AYLLOS/2-CAIXA/3-INTERNET */
                                        ,pr_cdprogra IN VARCHAR2                     -- Codigo do programa
                                        ,pr_nmdcampo OUT VARCHAR2                    --Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2                    --Saida OK/NOK
                                        ,pr_clob_ret OUT CLOB                        --Tabela arquivo cobranca
                                        ,pr_cdcritic OUT PLS_INTEGER                 --Codigo Erro
                                        ,pr_dscritic OUT VARCHAR2);                --Descricao Erro                                        

  /* Gerar os arquivos de retorno da febraban */
  PROCEDURE pc_gera_arquivo_febraban ( pr_cdcooper IN crapcop.cdcooper%TYPE       -- Codigo da cooperativa
                                      ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- registro com as data do sistema
                                      ,pr_crapcop  IN CRAPCOP%rowtype             -- Registro da cooperativa
                                      ,pr_cdagenci IN INTEGER                     -- Codigo da agencia para erros
                                      ,pr_nrdcaixa IN INTEGER                     -- Codigo do caixa para erros
                                      ,pr_origem   IN INTEGER                     -- indicador de origem /* 1-AYLLOS/2-CAIXA/3-INTERNET */
                                      ,pr_cdprogra IN VARCHAR2                    -- Codigo do programa
                                      ,pr_tab_crawarq IN typ_tab_crawarq          -- registros a serem gerados no arquivo
                                      ,pr_des_reto OUT VARCHAR2                   -- Descricao do retorno 'OK/NOK'
                                      ,pr_tab_arq_cobranca OUT COBR0001.typ_tab_arq_cobranca
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro);    -- tabela de erros

  /* Gerar os arquivos de retorno de cobrança outros */
  PROCEDURE pc_gera_arquivo_outros ( pr_cdcooper IN crapcop.cdcooper%TYPE       -- Codigo da cooperativa
                                    ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype -- registro com as data do sistema
                                    ,pr_crapcop  IN CRAPCOP%rowtype             -- Registro da cooperativa
                                    ,pr_cdagenci IN INTEGER                     -- Codigo da agencia para erros
                                    ,pr_nrdcaixa IN INTEGER                     -- Codigo do caixa para erros
                                    ,pr_origem   IN INTEGER                     -- indicador de origem /* 1-AYLLOS/2-CAIXA/3-INTERNET */
                                    ,pr_cdprogra IN VARCHAR2                    -- Codigo do programa
                                    ,pr_tab_crawarq IN typ_tab_crawarq          -- registros a serem gerados no arquivo
                                    ,pr_des_reto OUT VARCHAR2                   -- Descricao do retorno 'OK/NOK'
                                    ,pr_tab_arq_cobranca OUT COBR0001.typ_tab_arq_cobranca
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro);    -- tabela de erros

  /* Procedure de busca das parcelas do carnê */
  PROCEDURE pc_carrega_parcelas_carne(pr_cdcooper    IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                     ,pr_nrdconta    IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                     ,pr_dsboleto    IN VARCHAR2               -- Numero do Convenio
                                     ,pr_tab_boleto OUT CLOB                   -- XML da tabela de titulos
                                     ,pr_cdcritic   OUT INTEGER                -- Código do erro
                                     ,pr_dscritic   OUT VARCHAR2);             -- Descricao do erro
  
  /* Funcao que retorna se o Cooperado possui cadastro de emissao bloqueto ativo */
  FUNCTION fn_verif_ceb_ativo (pr_cdcooper IN crapcop.cdcooper%TYPE   -- Codigo da cooperativa
                              ,pr_nrdconta IN crapass.nrdconta%TYPE   -- Numero da conta do cooperado
                              ) RETURN INTEGER;
END cobr0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.cobr0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : cobr0001
  --  Sistema  : Procedimentos para arquivos de cobranca
  --  Sigla    : CRED
  --  Autor    : Edison Eduardo Bonomi (AMcom)
  --  Data     : Novembro/2013.                   Ultima atualizacao: 02/12/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para consulta de bloquetos de cobrança
  --
  -- Alteracoes: 15/06/2015 - Adicionado pc_carrega_parcelas_carne para carregar as parcelas
  --                          pertencentes ao carnê, possibilitando a reimpressão do carnê
  --                          (Projeto Boleto Formato Carnê - Douglas)
  --
  --             08/07/2015 - Alterar o tipo das variaveis do xml na pc_carrega_parcelas_carne 
  --                          para CLOB (Douglas - Chamado 303663)
	--
	--             02/12/2015 - PRJ 131. Alteradas procedures pc_taa_agenda_titulos_conv e 
  --                          pc_taa_lancto_titulos_conv (Reinert)	             
	--
  ---------------------------------------------------------------------------------------------------------------

  -- cadastro de emissao de bloquetos
  CURSOR cr_crapceb( pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_nrdconta IN crapceb.nrdconta%TYPE
                    ,pr_nrconven IN crapceb.nrconven%TYPE) IS
    SELECT crapceb.inarqcbr
          ,crapceb.cddemail
          ,crapceb.nrcnvceb
    FROM   crapceb
    WHERE  crapceb.cdcooper = pr_cdcooper
    AND    crapceb.nrdconta = pr_nrdconta
    AND    crapceb.nrconven = pr_nrconven
    ORDER BY cdcooper, nrdconta, nrconven, nrcnvceb;
  rw_crapceb cr_crapceb%ROWTYPE;


  -- Procedure para retornar o valor das tarifas
  PROCEDURE pc_pega_valor_tarifas( pr_cdcooper IN crapcop.cdcooper%type     -- Codigo da cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE     -- Numero Conta
                                  ,pr_cdprogra IN VARCHAR2                  -- Codigo do programa
                                  ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE     -- Codigo do convenio
                                  ,pr_inpessoa IN INTEGER                   -- Indica o tipo de pessoa Fisica/Juridica
                                  ,pr_cdhistor OUT INTEGER                  -- Codigo do historico
                                  ,pr_cdhisest OUT INTEGER                  -- Codigo do historico de estorno
                                  ,pr_dtdivulg OUT DATE                     -- Data divulgacao
                                  ,pr_dtvigenc OUT DATE                     -- data vigencia
                                  ,pr_cdfvlcop OUT INTEGER                  -- Codigo da cooperativa
                                  ,pr_vlrtarcx OUT NUMBER                   -- Valor tarifa caixa
                                  ,pr_vlrtarnt OUT NUMBER                   -- Valor tarifa internet
                                  ,pr_vltrftaa OUT NUMBER                   -- Valor tarifa TAA
                                  ,pr_vlrtarif OUT NUMBER                   -- Valor tarifa
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE    -- Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2                 -- Descricao da critica/erro
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro  ) IS -- Tabela de erros
  BEGIN
  /*-------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_pega_valor_tarifas           Antigo: Antigo b1wgen0010.p/pega_valor_tarifas
  --  Sistema  : Procedimentos para retornar o valor das tarifas para os motivos:
  --             - 03-Caixa da cooperativa
  --             - 31-Outras instituiçoes financeiras
  --             - 32-TAA
  --             - 33-Internet Banking
  --  Sigla    : CRED
  --  Autor    : Edison Eduardo Bonomi (AMcom)
  --  Data     : Novembro/2013.                Ultima atualizacao: 15/02/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para verificar valor das tarifas
  --
  -- Atualização: 09/05/2014 - Ajustado para somente buscar tarifa se
  --                           for inpessoa <> 3 (sem fins lucartivos) (Odirlei/AMcom)                             
  --
  --              15/02/2016 - Inclusao do parametro conta na chamada da
  --                           TARI0001.pc_carrega_dados_tarifa_cobr. (Jaison/Marcos)
  --
  ---------------------------------------------------------------------------------------------------------------*/

    DECLARE
      vr_cdhistor      INTEGER;   --Codigo Historico
      vr_cdhisest      INTEGER;   --Historico Estorno
      vr_dtdivulg      DATE;      --Data Divulgacao
      vr_dtvigenc      DATE;      --Data Vigencia
      vr_cdfvlcop      INTEGER;   --Codigo Cooperativa
      vr_exc_saida     EXCEPTION;
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(4000);
    BEGIN
      -- Inicializando as variaveis
      pr_vlrtarcx := 0;
      pr_vlrtarnt := 0;
      pr_vltrftaa := 0;
      pr_vlrtarif := 0;

      --somente buscar tarifa se for inpessoa <> 3(sem fins lucartivos)
      -- se for 3 vltarifa ficará zero
      IF pr_inpessoa <> 3 THEN

        -- Carregando os dados de tarifa de cobranca - 3-Caixa da cooperativa
        TARI0001.pc_carrega_dados_tarifa_cobr ( pr_cdcooper  => pr_cdcooper            --Codigo Cooperativa
                                                ,pr_nrdconta  => pr_nrdconta            --Numero Conta
                                                ,pr_nrconven  => pr_nrcnvcob            --Numero Convenio
                                                ,pr_dsincide  => 'RET'                  --Descricao Incidencia
                                                ,pr_cdocorre  => 0                      --Codigo Ocorrencia
                                                ,pr_cdmotivo  => '03'                      /* Caixa da cooperativa */
                                                ,pr_inpessoa  => pr_inpessoa            --Tipo Pessoa
                                                ,pr_vllanmto  => 1                      --Valor Lancamento
                                                ,pr_cdprogra  => NULL                   --Nome do programa
												,pr_flaputar  => 0                      /* Nao apurar */
                                                ,pr_cdhistor  => vr_cdhistor            --Codigo Historico
                                                ,pr_cdhisest  => vr_cdhisest            --Historico Estorno
                                                ,pr_vltarifa  => pr_vlrtarcx            --Valor Tarifa
                                                ,pr_dtdivulg  => vr_dtdivulg            --Data Divulgacao
                                                ,pr_dtvigenc  => vr_dtvigenc            --Data Vigencia
                                                ,pr_cdfvlcop  => vr_cdfvlcop            --Codigo Cooperativa
                                                ,pr_cdcritic  => vr_cdcritic            --Codigo Critica
                                                ,pr_dscritic  => vr_dscritic);          --Descricao Critica

        -- Se retornar com erro
        IF vr_dscritic IS NOT NULL THEN
          -- Escreve os erros no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || pr_cdprogra || ' --> '
                                                      || vr_dscritic);
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        END IF;--IF pr_dscritic IS NOT NULL THEN

        -- Carregando os dados de tarifa de cobranca - 33-Internet Banking
        TARI0001.pc_carrega_dados_tarifa_cobr ( pr_cdcooper   => pr_cdcooper            --Codigo Cooperativa
                                                ,pr_nrdconta  => pr_nrdconta            --Numero Conta
                                                ,pr_nrconven  => pr_nrcnvcob            --Numero Convenio
                                                ,pr_dsincide  => 'RET'                  --Descricao Incidencia
                                                ,pr_cdocorre  => 0                      --Codigo Ocorrencia
                                                ,pr_cdmotivo  => '33'                     /* Internet Banking */
                                                ,pr_inpessoa  => pr_inpessoa            --Tipo Pessoa
                                                ,pr_vllanmto  => 1                      --Valor Lancamento
                                                ,pr_cdprogra  => NULL                   --Nome do programa
                                                ,pr_flaputar  => 0                      /* Nao apurar */
                                                ,pr_cdhistor  => vr_cdhistor            --Codigo Historico
                                                ,pr_cdhisest  => vr_cdhisest            --Historico Estorno
                                                ,pr_vltarifa  => pr_vlrtarnt            --Valor Tarifa
                                                ,pr_dtdivulg  => vr_dtdivulg            --Data Divulgacao
                                                ,pr_dtvigenc  => vr_dtvigenc            --Data Vigencia
                                                ,pr_cdfvlcop  => vr_cdfvlcop            --Codigo Cooperativa
                                                ,pr_cdcritic  => vr_cdcritic            --Codigo Critica
                                                ,pr_dscritic  => vr_dscritic);          --Descricao Critica

        -- Se retornar com erro
        IF vr_dscritic IS NOT NULL THEN
          -- Escreve os erros no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || pr_cdprogra || ' --> '
                                                      || vr_dscritic);
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        END IF;--IF pr_dscritic IS NOT NULL THEN

        -- Carregando os dados de tarifa de cobranca - 32-TAA
        TARI0001.pc_carrega_dados_tarifa_cobr ( pr_cdcooper  => pr_cdcooper            --Codigo Cooperativa
                                                ,pr_nrdconta  => pr_nrdconta            --Numero Conta
                                                ,pr_nrconven  => pr_nrcnvcob            --Numero Convenio
                                                ,pr_dsincide  => 'RET'                  --Descricao Incidencia
                                                ,pr_cdocorre  => 0                      --Codigo Ocorrencia
                                                ,pr_cdmotivo  => '32'                     /* TAA */
                                                ,pr_inpessoa  => pr_inpessoa            --Tipo Pessoa
                                                ,pr_vllanmto  => 1                      --Valor Lancamento
                                                ,pr_cdprogra  => NULL                   --Nome do programa
                                                ,pr_flaputar  => 0                      /* Nao apurar */
                                                ,pr_cdhistor  => vr_cdhistor            --Codigo Historico
                                                ,pr_cdhisest  => vr_cdhisest            --Historico Estorno
                                                ,pr_vltarifa  => pr_vltrftaa            --Valor Tarifa
                                                ,pr_dtdivulg  => vr_dtdivulg            --Data Divulgacao
                                                ,pr_dtvigenc  => vr_dtvigenc            --Data Vigencia
                                                ,pr_cdfvlcop  => vr_cdfvlcop            --Codigo Cooperativa
                                                ,pr_cdcritic  => vr_cdcritic            --Codigo Critica
                                                ,pr_dscritic  => vr_dscritic);          --Descricao Critica

        -- Se retornar com erro
        IF vr_dscritic IS NOT NULL THEN
          -- Escreve os erros no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || pr_cdprogra || ' --> '
                                                      || vr_dscritic);
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        END IF;--IF pr_dscritic IS NOT NULL THEN

        -- Carregando os dados de tarifa de cobranca - 31-Outras instituiçoes financeiras
        TARI0001.pc_carrega_dados_tarifa_cobr ( pr_cdcooper  => pr_cdcooper            --Codigo Cooperativa
                                                ,pr_nrdconta  => pr_nrdconta            --Numero Conta
                                                ,pr_nrconven  => pr_nrcnvcob            --Numero Convenio
                                                ,pr_dsincide  => 'RET'                  --Descricao Incidencia
                                                ,pr_cdocorre  => 0                      --Codigo Ocorrencia
                                                ,pr_cdmotivo  => '31'                     /* Outras instituiçoes financeiras */
                                                ,pr_inpessoa  => pr_inpessoa            --Tipo Pessoa
                                                ,pr_vllanmto  => 1                      --Valor Lancamento
                                                ,pr_cdprogra  => NULL                   --Nome do programa
                                                ,pr_flaputar  => 0                      /* Nao apurar */
                                                ,pr_cdhistor  => vr_cdhistor            --Codigo Historico
                                                ,pr_cdhisest  => vr_cdhisest            --Historico Estorno
                                                ,pr_vltarifa  => pr_vlrtarif            --Valor Tarifa
                                                ,pr_dtdivulg  => vr_dtdivulg            --Data Divulgacao
                                                ,pr_dtvigenc  => vr_dtvigenc            --Data Vigencia
                                                ,pr_cdfvlcop  => vr_cdfvlcop            --Codigo Cooperativa
                                                ,pr_cdcritic  => vr_cdcritic            --Codigo Critica
                                                ,pr_dscritic  => vr_dscritic);          --Descricao Critica

        -- Se retornar com erro
        IF vr_dscritic IS NOT NULL THEN
          -- Escreve os erros no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || pr_cdprogra || ' --> '
                                                      || vr_dscritic);
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        END IF;--IF pr_dscritic IS NOT NULL THEN

      END IF; -- FIM IF inpessoa <> 3

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Retornando a critica para o programa chamdador
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Retornando a critica para o programa chamdador
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina COBR0001.pc_pega_valor_tarifas. '||sqlerrm;
    END; --DECLARE BEGIN
  END pc_pega_valor_tarifas;

  /* Gerar os arquivos de retorno das baixas processadas */
  PROCEDURE pc_gera_retorno_arq_cob_coop(pr_cdcooper IN crapcop.cdcooper%TYPE   -- Codigo da cooperativa
                                        ,pr_cdprogra IN VARCHAR2                -- Codigo do programa
                                        ,pr_dtmvtolt IN DATE                    -- Data do movimento
                                        ,pr_cdagenci IN INTEGER                 -- Codigo da agencia para erros
                                        ,pr_nrocaixa IN INTEGER                 -- Codigo do caixa para erros
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE  -- Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2               -- Descricao da critica
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro) IS -- tabela de erros
  BEGIN
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_retorno_arq_cob_coop           Antigo: Antigo b1wgen0010.p/gera_retorno_arq_cobranca_coopcob
  --  Sistema  : Procedimento para gerar o arquivo de retorno
  --  Sigla    : CRED
  --  Autor    : Edison Eduardo Bonomi (AMcom)
  --  Data     : Novembro/2013.                Ultima atualizacao: 14/03/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para gerar o arquivo de retorno das baixas processadas
  --
  -- Alteracoes: 14/03/2014 - Converter o arquivo ux2dos ao inves de somente copiar
  --                          (Gabriel)
  --
  --             07/08/2014 - Realizado ajustes para gravar corretamente o index da temp-table vr_tab_arq_cobranca
  --                          devido a ordenação do arquivo (Odirlei/Amcom SD162019)
  ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrdocnpj
              ,cop.cdagedbb
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Parametros do cadastro de cobrança
      CURSOR cr_crapcco( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcco.nrconven
              ,crapcco.tamannro
              ,crapcco.nrdctabb
              ,crapcco.flgutceb
              ,crapcco.dsorgarq
              ,crapcco.nmdireto
        FROM   crapcco
        WHERE  crapcco.cdcooper = pr_cdcooper
        AND    crapcco.flcopcob = 1;
      rw_crapcco cr_crapcco%ROWTYPE;

      -- Cadastro de bloquetos de cobranca
      CURSOR cr_crapcob( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt IN DATE
                        ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE) IS
        SELECT  crapcob.cdcooper
               ,crapcob.nrdconta
               ,crapcob.nrcnvcob
               ,crapcob.incobran
               ,crapcob.dtdpagto
               ,crapcob.nrdocmto
               ,crapcob.vldpagto
               ,crapcob.indpagto
        FROM   crapcob
        WHERE  crapcob.cdcooper  = pr_cdcooper
        AND    crapcob.dtdpagto  = pr_dtmvtolt
        AND    crapcob.nrcnvcob  = pr_nrcnvcob;
      rw_crapcob cr_crapcob%ROWTYPE;

      -- cadastro de emissao de bloquetos
      CURSOR cr_crapceb( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapceb.nrdconta%TYPE
                        ,pr_nrconven IN crapceb.nrconven%TYPE) IS
        SELECT crapceb.inarqcbr
              ,crapceb.cddemail
              ,crapceb.nrcnvceb
        FROM   crapceb
        WHERE  crapceb.cdcooper = pr_cdcooper
        AND    crapceb.nrdconta = pr_nrdconta
        AND    crapceb.nrconven = pr_nrconven
        ORDER BY crapceb.progress_recid;
      rw_crapceb cr_crapceb%ROWTYPE;

      -- cadastro de e-mails
      CURSOR cr_crapcem ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapcem.nrdconta%TYPE
                         ,pr_cddemail IN crapcem.cddemail%TYPE) IS
        SELECT crapcem.dsdemail
        FROM   crapcem
        WHERE  crapcem.cdcooper = rw_crapcob.cdcooper
        AND    crapcem.nrdconta = rw_crapcob.nrdconta
        AND    crapcem.idseqttl = 1
        AND    crapcem.cddemail = pr_cddemail;
      rw_crapcem cr_crapcem%ROWTYPE;

      -- cadastro de cooperados
      CURSOR cr_crapass ( pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.inpessoa
        FROM   crapass
        WHERE  crapass.cdcooper = pr_cdcooper
        AND    crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      -- variaveis de controle
      vr_nmarqind VARCHAR2(100);
      vr_nossonro VARCHAR2(100);
      vr_nossonr2 VARCHAR2(100);
      vr_dtmvtolt VARCHAR2(8);
      vr_dsdahora VARCHAR2(6);
      vr_qtregist INTEGER;
      vr_dsdatamv VARCHAR2(8);
      vr_vlcredit NUMBER;
      vr_vltarifa NUMBER;
      vr_cdseqlin INTEGER;
      vr_dslinha  VARCHAR2(4000);
      vr_dtdpagto VARCHAR2(8);
      vr_dsdircob VARCHAR2(100);
      vr_inarqcbr INTEGER;
      vr_cddemail INTEGER;
      vr_inpessoa crapass.inpessoa%TYPE;
      vr_cdhistor INTEGER;
      vr_cdhisest INTEGER;
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;
      vr_vlrtarcx NUMBER;
      vr_vlrtarnt NUMBER;
      vr_vltrftaa NUMBER;
      vr_vlrtarif NUMBER;
      vr_caminho_arq   VARCHAR2(200);
      vr_comando       VARCHAR2(1000);
      vr_typ_saida     VARCHAR2(1000);
      vr_indcrawarq    VARCHAR2(100);
      vr_indcrawarqaux VARCHAR2(100);
      vr_indarqcob     VARCHAR2(100);
      vr_convenioaux   INTEGER;
      vr_des_xml       CLOB;
      vr_exc_saida     EXCEPTION;
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(4000);

      /*rotina para grava linha do arq na temp-table de cobrança*/
      PROCEDURE pc_grava_tab_arq_cobranca(pr_nrconven IN NUMBER,
                                          pr_dslinha  IN VARCHAR2) IS
      BEGIN
        -- gerando o indice do registro
        vr_indarqcob := LPad(pr_nrconven,10,'0')||
                        LPad(vr_cdseqlin,10,'0');

        -- carregando a tabela auxiliar de cobranca
        vr_tab_arq_cobranca(vr_indarqcob).cdseqlin := vr_cdseqlin;
        vr_tab_arq_cobranca(vr_indarqcob).dslinha  := pr_dslinha;
        -- incrementando no numero de linhas
        vr_cdseqlin := Nvl(vr_cdseqlin,0) + 1;

      END;

    BEGIN
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        -- volta para o programa chamador
        RETURN;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Inicializando as tabelas temporarias
      vr_tab_crawarq.DELETE;
      vr_tab_arq_cobranca.DELETE;

      --Parametros do cadastro de cobrança
      OPEN cr_crapcco(pr_cdcooper => pr_cdcooper);
      LOOP
        FETCH cr_crapcco INTO rw_crapcco;
        EXIT WHEN cr_crapcco%NOTFOUND;

        -- Cadastro de bloquetos de cobranca
        OPEN cr_crapcob( pr_cdcooper => pr_cdcooper
                        ,pr_dtmvtolt => pr_dtmvtolt
                        ,pr_nrcnvcob => rw_crapcco.nrconven);
        LOOP
          FETCH cr_crapcob INTO rw_crapcob;
          EXIT WHEN cr_crapcob%NOTFOUND;

          /* Consistencia qdo execucao eh via Ayllos que ocorre na diaria */
          IF rw_crapcob.incobran <> 5 THEN
            CONTINUE;
          END IF;

          -- cadastro de emissao de bloquetos
          OPEN cr_crapceb( pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapcob.nrdconta
                          ,pr_nrconven => rw_crapcob.nrcnvcob);
          FETCH cr_crapceb INTO rw_crapceb;

          -- se nao existir, zera a variavel
          IF cr_crapceb%NOTFOUND THEN
            vr_inarqcbr := 0;
            vr_cddemail := 0;
          ELSE
            vr_inarqcbr := rw_crapceb.inarqcbr;
            vr_cddemail := rw_crapceb.cddemail;
          END IF;
          --fechando o cursor
          CLOSE cr_crapceb;

          -- seleciona o e-mail da conta do cooperado
          OPEN cr_crapcem ( pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_crapcob.nrdconta
                           ,pr_cddemail => vr_cddemail);
          FETCH cr_crapcem INTO rw_crapcem;
          CLOSE cr_crapcem;

          -- busca o cooperado
          OPEN cr_crapass ( pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_crapcob.nrdconta);
          FETCH cr_crapass INTO rw_crapass;
          -- se a conta existir
          IF cr_crapass%FOUND THEN
            vr_inpessoa := rw_crapass.inpessoa;
          ELSE
            vr_inpessoa := 2;
          END IF;
          -- fechando o cursor
          CLOSE cr_crapass;

          -- busca o valor das tarifas
          pc_pega_valor_tarifas( pr_cdcooper => pr_cdcooper         -- Codigo da cooperativa
                                ,pr_nrdconta => rw_crapcob.nrdconta -- Numero Conta
                                ,pr_cdprogra => pr_cdprogra         -- Codigo do programa
                                ,pr_nrcnvcob => rw_crapcob.nrcnvcob -- Codigo do convenio
                                ,pr_inpessoa => vr_inpessoa         -- Indica o tipo de pessoa Fisica/Juridica
                                ,pr_cdhistor => vr_cdhistor         -- Codigo do historico
                                ,pr_cdhisest => vr_cdhisest         -- Codigo do historico de estorno
                                ,pr_dtdivulg => vr_dtdivulg         -- Data divulgacao
                                ,pr_dtvigenc => vr_dtvigenc         -- data vigencia
                                ,pr_cdfvlcop => vr_cdfvlcop         -- Codigo da cooperativa
                                ,pr_vlrtarcx => vr_vlrtarcx         -- Valor tarifa caixa
                                ,pr_vlrtarnt => vr_vlrtarnt         -- Valor tarifa internet
                                ,pr_vltrftaa => vr_vltrftaa         -- Valor tarifa TAA
                                ,pr_vlrtarif => vr_vlrtarif         -- Valor tarifa
                                ,pr_cdcritic => pr_cdcritic         -- Codigo da critica
                                ,pr_dscritic => pr_dscritic         -- Descricao da critica
                                ,pr_tab_erro => pr_tab_erro);       -- Tabela de erros

          -- se ocorreu alguma critica, vai para o proximo registro
          IF pr_dscritic IS NOT NULL THEN
            CONTINUE;
          END IF;

          -- gerando o indice da tabela temporaria
          vr_indcrawarq := LPad(vr_inarqcbr,5,'0')||
                           LPad(rw_crapcob.nrcnvcob,10,'0')||
                           LPad(rw_crapcob.nrdconta,10,'0')||
                           To_Char(rw_crapcob.dtdpagto,'YYYYMMDD')||
                           LPad(rw_crapcob.nrdocmto,10,'0');

          -- alimentando a tabela temporaria
          vr_tab_crawarq(vr_indcrawarq).tparquiv := vr_inarqcbr;
          vr_tab_crawarq(vr_indcrawarq).nrdconta := rw_crapcob.nrdconta;
          vr_tab_crawarq(vr_indcrawarq).nrdocmto := rw_crapcob.nrdocmto;
          vr_tab_crawarq(vr_indcrawarq).nrconven := rw_crapcob.nrcnvcob;
          vr_tab_crawarq(vr_indcrawarq).tamannro := rw_crapcco.tamannro;
          vr_tab_crawarq(vr_indcrawarq).nrdctabb := rw_crapcco.nrdctabb;
          vr_tab_crawarq(vr_indcrawarq).vldpagto := rw_crapcob.vldpagto;
          vr_tab_crawarq(vr_indcrawarq).vlrtarcx := vr_vlrtarcx;
          vr_tab_crawarq(vr_indcrawarq).vlrtarnt := vr_vlrtarnt;
          vr_tab_crawarq(vr_indcrawarq).vltrftaa := vr_vltrftaa; /** TAA **/
          vr_tab_crawarq(vr_indcrawarq).vlrtarcm := vr_vlrtarif;
          vr_tab_crawarq(vr_indcrawarq).inarqcbr := vr_inarqcbr;
          vr_tab_crawarq(vr_indcrawarq).flgutceb := rw_crapcco.flgutceb;
          vr_tab_crawarq(vr_indcrawarq).dsorgarq := rw_crapcco.dsorgarq;
          vr_tab_crawarq(vr_indcrawarq).indpagto := rw_crapcob.indpagto;
          vr_tab_crawarq(vr_indcrawarq).dtdpagto := rw_crapcob.dtdpagto;
          vr_tab_crawarq(vr_indcrawarq).dsdemail := rw_crapcem.dsdemail;

          -- armazenando o diretorio padrao para arquivos texto
          vr_dsdircob := Trim(rw_crapcco.nmdireto);
        END LOOP; /* for each CRAPCOB */
        -- fechando o cursor
        CLOSE cr_crapcob;
      END LOOP; /* for each CRAPCCO */
      -- fechando o cursor
      CLOSE cr_crapcco;

      -- formatando a data e hora para exibir no arquivo
      vr_dtmvtolt := To_Char(SYSDATE, 'DDMMYYYY');
      vr_dsdahora := To_Char(SYSDATE,'HH24MISS');

      -- posicionando no primeiro registro da temp-table
      vr_indcrawarq := vr_tab_crawarq.first;
      -- inicializando a variável de quebra
      vr_convenioaux := 9999999999;

      -- percorrendo os registros da temp-table
      WHILE vr_indcrawarq IS NOT NULL LOOP
        -- processa somente os dados do tipo 2-Febraban
        IF vr_tab_crawarq(vr_indcrawarq).tparquiv = 2 THEN

          -- verificando se é FIRST-OF(crawarq.nrconven)
          IF vr_convenioaux <> vr_tab_crawarq(vr_indcrawarq).nrconven THEN

            -- inicializa o contador de linhas por convenio
            vr_cdseqlin := 1;

            /******** HEADER DO ARQUIVO ************/
            vr_dslinha := '00100000         2' ||
                          LPad(rw_crapcop.nrdocnpj,14,'0') ||
                          LPad(vr_tab_crawarq(vr_indcrawarq).nrconven,9,'0') ||
                          '           ' ||
                          LPad(rw_crapcop.cdagedbb,6,'0') ||
                          LPad(vr_tab_crawarq(vr_indcrawarq).nrdctabb,13,'0') ||
                          ' ' || RPad(rw_crapcop.nmrescop,30, ' ') ||
                          'BANCO DO BRASIL' || RPad(' ',25,' ') || '2' ||
                          vr_dtmvtolt ||
                          vr_dsdahora ||
                          '00000100001' || RPad(' ',72,' ');

            -- gravar linha na temp-table de cobrança
            pc_grava_tab_arq_cobranca(pr_nrconven => vr_tab_crawarq(vr_indcrawarq).nrconven,
                                      pr_dslinha  => vr_dslinha);

            /******** HEADER DO LOTE ************/
            vr_dslinha := '00100011T01  030 2' ||
                        LPad(rw_crapcop.nrdocnpj,15,'0') ||
                        LPad(vr_tab_crawarq(vr_indcrawarq).nrconven,9,'0') ||
                        '           ' ||
                        LPad(rw_crapcop.cdagedbb,6,'0') ||
                        LPad(vr_tab_crawarq(vr_indcrawarq).nrdctabb,13,'0') || ' ' ||
                        RPad(rw_crapcop.nmrescop,30,' ') || RPad(' ',80,' ') ||
                        '00000001' || vr_dtmvtolt ||
                        vr_dtmvtolt || RPad(' ',33,' ');


             -- gravar linha na temp-table de cobrança
            pc_grava_tab_arq_cobranca(pr_nrconven => vr_tab_crawarq(vr_indcrawarq).nrconven,
                                      pr_dslinha  => vr_dslinha);

          END IF;

          -- incrementando o quantidade de registros
          vr_qtregist := Nvl(vr_qtregist,0) + 1;

          -- atualiza os valores de credito e tarifa
          CASE vr_tab_crawarq(vr_indcrawarq).indpagto
            WHEN 0 THEN /**   compe  **/
              vr_vlcredit := ((Nvl(vr_tab_crawarq(vr_indcrawarq).vldpagto,0) * 100) -
                              (Nvl(vr_tab_crawarq(vr_indcrawarq).vlrtarcm,0) * 100));
              vr_vltarifa := Nvl(vr_tab_crawarq(vr_indcrawarq).vlrtarcm,0) * 100;
            WHEN 1 THEN /** caixa **/
              vr_vlcredit := ((Nvl(vr_tab_crawarq(vr_indcrawarq).vldpagto,0) * 100) -
                              (Nvl(vr_tab_crawarq(vr_indcrawarq).vlrtarcx,0) * 100));
              vr_vltarifa := Nvl(vr_tab_crawarq(vr_indcrawarq).vlrtarcx,0) * 100;
            WHEN 3 THEN /** internet **/
              vr_vlcredit := ((Nvl(vr_tab_crawarq(vr_indcrawarq).vldpagto,0) * 100) -
                              (Nvl(vr_tab_crawarq(vr_indcrawarq).vlrtarnt,0) * 100));
              vr_vltarifa := Nvl(vr_tab_crawarq(vr_indcrawarq).vlrtarnt,0) * 100;
            WHEN 4 THEN /** TAA **/
              vr_vlcredit := ((Nvl(vr_tab_crawarq(vr_indcrawarq).vldpagto,0) * 100) -
                              (Nvl(vr_tab_crawarq(vr_indcrawarq).vltrftaa,0) * 100));
              vr_vltarifa := Nvl(vr_tab_crawarq(vr_indcrawarq).vltrftaa,0) * 100;
          END CASE;

          -- condicao para gerar o nosso numero
          IF vr_tab_crawarq(vr_indcrawarq).dsorgarq = 'IMPRESSO PELO SOFTWARE' OR
             vr_tab_crawarq(vr_indcrawarq).dsorgarq = 'INTERNET'               OR
             vr_tab_crawarq(vr_indcrawarq).dsorgarq = 'MIGRACAO'               OR
             vr_tab_crawarq(vr_indcrawarq).dsorgarq = 'INCORPORACAO'           THEN

            -- concatena o numero da conta e o numero do documento
            vr_nossonro := LPad(vr_tab_crawarq(vr_indcrawarq).nrdconta,8,'0') ||
                           LPad(vr_tab_crawarq(vr_indcrawarq).nrdocmto,9,'0');
          END IF;

          -- verifica o tamanho do convenio
          IF LENGTH(vr_tab_crawarq(vr_indcrawarq).nrconven) = 7 THEN

            -- cadastro de emissao de bloquetos
            OPEN cr_crapceb( pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => vr_tab_crawarq(vr_indcrawarq).nrdconta
                            ,pr_nrconven => vr_tab_crawarq(vr_indcrawarq).nrconven);
            FETCH cr_crapceb INTO rw_crapceb;

            -- se existir dados, ajusta o nosso numero
            IF cr_crapceb%FOUND THEN
              IF  LENGTH(TRIM(rw_crapceb.nrcnvceb)) <= 4 THEN
                vr_nossonro := LPad(vr_tab_crawarq(vr_indcrawarq).nrconven,7,'0') ||
                               LPad(rw_crapceb.nrcnvceb,4,'0') ||
                               LPad(vr_tab_crawarq(vr_indcrawarq).nrdocmto,6);
              ELSE
                vr_nossonro := LPad(vr_tab_crawarq(vr_indcrawarq).nrconven,7,'0') ||
                               LPad(to_number(SUBSTR(TRIM(rw_crapceb.nrcnvceb),1,4)),4,'0') ||
                               LPad(vr_tab_crawarq(vr_indcrawarq).nrdocmto,6,'0');
              END IF;--IF  LENGTH(TRIM(rw_crapceb.nrcnvceb)) <= 4 THEN
            END IF;--IF cr_crapceb%NOTFOUND THEN
            --fechando o cursor
            CLOSE cr_crapceb;
          END IF; --IF LENGTH(vr_tab_crawarq(vr_indcrawarq).nrconven) = 7 THEN

          -- montando o nosso numero 2
          vr_nossonr2 := '21' || RPad(' ',23 - LENGTH(vr_nossonro),' ') || vr_nossonro;

          -- ajusta o valor do credito caso esteja negativo
          IF Nvl(vr_vlcredit,0) < 0 THEN
            vr_vlcredit := 0;
          END IF;

          -- gerando a proxima linha
          vr_dslinha := '00100013' || lpad(vr_qtregist,5,'0') ||
                      'T 06' || lpad(rw_crapcop.cdagedbb,6,'0')
                      || lpad(vr_tab_crawarq(vr_indcrawarq).nrdctabb,13,'0')
                      || ' ' || RPad(vr_nossonro,20,' ') || '1'
                      || RPad(' ',15,' ') || '00000000' ||
                      LPad((vr_tab_crawarq(vr_indcrawarq).vldpagto * 100),15,'0') ||
                      '001' || LPad(rw_crapcop.cdagedbb,6,'0') ||
                      RPad(vr_nossonr2,25,' ') || '09' ||
                      rpad('0',66,'0') ||
                      LPad(vr_vltarifa,15,'0') ||
                      '00        ' || RPad('0',17,'0');

           -- gravar linha na temp-table de cobrança
          pc_grava_tab_arq_cobranca(pr_nrconven => vr_tab_crawarq(vr_indcrawarq).nrconven,
                                    pr_dslinha  => vr_dslinha);

          -- incrementando a qtde de registros
          vr_qtregist := Nvl(vr_qtregist,0) + 1;

          -- formatando a data de pagamento no arquivo
          vr_dtdpagto := To_Char(vr_tab_crawarq(vr_indcrawarq).dtdpagto,'DDMMYYYY');

          -- gerando a proxima linha
          vr_dslinha  := '00100013' || LPad(vr_qtregist,5,'0') ||
                        'U 06' || RPad('0',60,'0') ||
                        LPad((vr_tab_crawarq(vr_indcrawarq).vldpagto * 100),15,'0') ||
                        LPad(vr_vlcredit,15,'0') ||
                        RPad('0',30,'0') || vr_dtdpagto ||
                        vr_dtdpagto ||
                        RPad(' ',12,' ') || RPad('0',15,'0') || RPad(' ',30,' ') ||
                        '000' || RPad(' ',27,' ');

          -- gravar linha na temp-table de cobrança
          pc_grava_tab_arq_cobranca(pr_nrconven => vr_tab_crawarq(vr_indcrawarq).nrconven,
                                    pr_dslinha  => vr_dslinha);

          -- busca o proximo registro para efetuar a verificação do last-of(nrconven)
          vr_indcrawarqaux := vr_tab_crawarq.NEXT(vr_indcrawarq);

          -- se não chegou no final da temp-table, armazena o proximo numero de convenio
          IF vr_indcrawarqaux IS NOT NULL THEN
            vr_convenioaux := vr_tab_crawarq(vr_indcrawarqaux).nrconven;
          END IF;

          -- se o numero do proximo convenio é diferente do atual ou se chegou
          -- no final da temp-table, é LAST-OF(crawarq.nrconven)
          IF vr_convenioaux <> vr_tab_crawarq(vr_indcrawarq).nrconven OR
             vr_indcrawarqaux IS NULL THEN

            /******** TRAILER DO LOTE ************/
            vr_dslinha := '00100015         ' ||
                          LPad((vr_qtregist + 2),6,'0') ||
                          LPad('0',123,'0') || RPad(' ',094,' ');

            -- gravar linha na temp-table de cobrança
            pc_grava_tab_arq_cobranca(pr_nrconven => vr_tab_crawarq(vr_indcrawarq).nrconven,
                                      pr_dslinha  => vr_dslinha);

            /******** TRAILER DO ARQUIVO ************/
            vr_dslinha := '00199999         000001' ||
                          LPad((vr_qtregist + 4),6,'0') ||
                          '000000' || RPad(' ',156,' ') ||
                          RPad('0',029,'0') || RPad(' ',020,' ');


             -- gravar linha na temp-table de cobrança
             pc_grava_tab_arq_cobranca(pr_nrconven => vr_tab_crawarq(vr_indcrawarq).nrconven,
                                       pr_dslinha  => vr_dslinha);

            vr_dsdatamv := To_Char(SYSDATE, 'DDMMYYYY');

            vr_nmarqind := 'CoopCob-' ||
                      LPad(vr_tab_crawarq(vr_indcrawarq).nrconven,8,'0') || '-' ||
                      vr_dsdatamv || '.dat';

            vr_qtregist := 0;

            -- Inicializar o CLOB
            dbms_lob.createtemporary(vr_des_xml, TRUE);
            dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

            /* gravar arquivo */
            -- posiciona no primeiro registro da temp-table
            vr_indarqcob := vr_tab_arq_cobranca.first;

            -- navega na temp-table para gerar o arquivo re retorno
            WHILE vr_indarqcob IS NOT NULL LOOP
              dbms_lob.writeappend(vr_des_xml
                                  ,length(vr_tab_arq_cobranca(vr_indarqcob).dslinha||Chr(13))
                                  ,vr_tab_arq_cobranca(vr_indarqcob).dslinha||Chr(13));
              vr_indarqcob := vr_tab_arq_cobranca.NEXT(vr_indarqcob);
            END LOOP;

            /* Limpar registros enviados */
            vr_tab_arq_cobranca.DELETE;

            -- Busca o diretorio da cooperativa conectada
            vr_caminho_arq := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                      ,pr_cdcooper => pr_cdcooper
                                                      ,pr_nmsubdir => 'arq');

            -- Escreve o clob no arquivo físico
            gene0002.pc_clob_para_arquivo(pr_clob => vr_des_xml
                                         ,pr_caminho => vr_caminho_arq
                                         ,pr_arquivo => vr_nmarqind
                                         ,pr_des_erro => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;

            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_des_xml);
            dbms_lob.freetemporary(vr_des_xml);

            -- Salvar arq. no diret. /micros/viacredi/cobranca
            vr_comando := 'ux2dos < '|| vr_caminho_arq || '/' || vr_nmarqind ||' | tr -d "\032" > ' || vr_dsdircob || '/' || vr_nmarqind || ' 2>/dev/null';
            --vr_comando := 'cp '||vr_caminho_arq||'/'||vr_nmarqind||' '||vr_dsdircob||' 2>/dev/null';

            -- Executar o comando no unix
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => pr_dscritic);

            -- Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
              vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
              RAISE vr_exc_saida;
            END IF;

            -- Remove o arquivo do diretorio da cooperativa
            vr_comando := 'rm '|| vr_caminho_arq ||'/'|| vr_nmarqind ||' 2>/dev/null';

            -- Executar o comando no unix
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => pr_dscritic);

            -- Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
              vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
              RAISE vr_exc_saida;
            END IF;

          END IF;-- last-of
        END IF; -- IF vr_tab_crawarq(vr_indcrawarq).tparquiv = 2 THEN
        --alimentando a variavel de controle de quebra
        vr_convenioaux := vr_tab_crawarq(vr_indcrawarq).nrconven;
        -- navegando para o proximo registro da temp-table
        vr_indcrawarq := vr_tab_crawarq.NEXT(vr_indcrawarq);
      END LOOP; --WHILE vr_indcrawarq IS NOT NULL LOOP
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Retornando a critica para o programa chamdador
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Retornando a critica para o programa chamdador
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina COBR0001.pc_gera_retorno_arq_cob_coop. '||sqlerrm;
    END;
  END pc_gera_retorno_arq_cob_coop;  /*  Fim  da  Procedure gera_retorno_arq_cobranca */


  PROCEDURE pc_taa_lancto_titulos_conv(pr_cdcooper        IN  crapcop.cdcooper%TYPE,
                                       pr_cdcoptfn        IN  craplcm.cdcoptfn%TYPE,
                                       pr_dtmvtoin        IN  DATE,
                                       pr_dtmvtofi        IN  DATE,
                                       pr_cdtplanc        IN  PLS_INTEGER,
                                       pr_dscritic        OUT VARCHAR2,
                                       pr_tab_lancamentos OUT CADA0001.typ_tab_lancamentos) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_taa_lancto_titulos_conv           Antigo: Antigo b1wgen0025.p/taa_lancto_titulos_convenvios
  --  Sistema  : Procedimentos para arquivos de cobranca
  --  Sigla    : CRED
  --  Autor    : Andrino Carlos de Souza Junior (RKAM)
  --  Data     : 06/05/2014                Ultima atualizacao: -
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Consulta por:
  --                Saques feitos no meu TAA por outras Coops (pr_cdcoptfn <> 0)
  --                Saques feitos por meus Assoc. em outras Coops (pr_cdcooper <> 0)
  --
  ---------------------------------------------------------------------------------------------------------------


    -- Cursor sobre os titulos acolhidos
    CURSOR cr_craptit IS
      SELECT cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta,
             SUM(vldpagto) vldpagto,
             COUNT(*) qtdmovto
        FROM craptit
       WHERE craptit.cdcoptfn  = pr_cdcoptfn
         AND craptit.cdagenci  = 91 -- PAC TRANSACOES TAA
         AND craptit.dtmvtolt >= pr_dtmvtoin
         AND craptit.dtmvtolt <= pr_dtmvtofi
         AND craptit.cdcooper <> craptit.cdcoptfn
       GROUP BY cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta;

    -- Cursor sobre os titulos acolhidos
    CURSOR cr_craptit_2 IS
      SELECT cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta,
             SUM(vldpagto) vldpagto,
             COUNT(*) qtdmovto
        FROM craptit
       WHERE craptit.cdcooper  = pr_cdcooper
         AND craptit.dtdpagto >= pr_dtmvtoin
         AND craptit.dtdpagto <= pr_dtmvtofi
         AND craptit.cdagenci = 91 -- PAC TRANSACOES TAA
         AND craptit.cdcooper <> craptit.cdcoptfn
         AND craptit.cdcoptfn <> 0
       GROUP BY cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta;


    -- Cursor sobre os lancamentos de faturas
    CURSOR cr_craplft IS
      SELECT cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta,
             SUM(vllanmto + vlrmulta + vlrjuros) vlrtotal,
             COUNT(*) qtdmovto
        FROM craplft
       WHERE craplft.cdcoptfn  = pr_cdcoptfn
         AND craplft.cdagenci  = 91 -- PAC TRANSACOES TAA
         AND craplft.dtmvtolt >= pr_dtmvtoin
         AND craplft.dtmvtolt <= pr_dtmvtofi
         AND craplft.cdcooper <> craplft.cdcoptfn
       GROUP BY cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta;

    -- Cursor sobre os lancamentos de faturas
    CURSOR cr_craplft_2 IS
      SELECT cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta,
             SUM(vllanmto + vlrmulta + vlrjuros) vlrtotal,
             COUNT(*) qtdmovto
        FROM craplft
       WHERE craplft.cdcooper  = pr_cdcooper
         AND craplft.dtmvtolt >= pr_dtmvtoin
         AND craplft.dtmvtolt <= pr_dtmvtofi
         AND craplft.cdagenci  = 91 -- PAC TRANSACOES TAA
         AND craplft.cdcooper <> craplft.cdcoptfn
         AND craplft.cdcoptfn <> 0
       GROUP BY cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta;

    CURSOR cr_tbgen_trans_pend IS
		  SELECT tbgen_trans_pend.cdcooper
						,tbgen_trans_pend.cdcoptfn
						,tbgen_trans_pend.cdagetfn						
						,tbgen_trans_pend.nrdconta
						,SUM(tbpagto_trans_pend.vlpagamento) vldpagto
						,COUNT(*) qtdmovto
			 FROM tbgen_trans_pend, tbpagto_trans_pend 
			WHERE tbgen_trans_pend.cdcoptfn = pr_cdcoptfn 
				AND tbgen_trans_pend.dtmvtolt >= pr_dtmvtoin
				AND tbgen_trans_pend.dtmvtolt <= pr_dtmvtofi
				AND tbgen_trans_pend.cdcooper <> tbgen_trans_pend.cdcoptfn
				AND tbgen_trans_pend.idorigem_transacao = 4 /* TAA */
				AND tbgen_trans_pend.tptransacao = 2 /* Pagamento */
				AND tbpagto_trans_pend.cdtransacao_pendente =
						tbgen_trans_pend.cdtransacao_pendente
				AND tbpagto_trans_pend.idagendamento = 1 /* Nesta Data */
	 GROUP BY tbgen_trans_pend.cdcooper
	 				 ,tbgen_trans_pend.cdcoptfn
					 ,tbgen_trans_pend.cdagetfn
					 ,tbgen_trans_pend.nrdconta;

    CURSOR cr_tbgen_trans_pend_2 IS
		  SELECT tbgen_trans_pend.cdcooper
						,tbgen_trans_pend.cdcoptfn
						,tbgen_trans_pend.cdagetfn
						,tbgen_trans_pend.nrdconta
						,SUM(tbpagto_trans_pend.vlpagamento) vldpagto
						,COUNT(*) qtdmovto
		   FROM tbgen_trans_pend, tbpagto_trans_pend 
			WHERE tbgen_trans_pend.cdcooper = pr_cdcooper
				AND tbgen_trans_pend.dtmvtolt >= pr_dtmvtoin
				AND tbgen_trans_pend.dtmvtolt <= pr_dtmvtofi
				AND tbgen_trans_pend.cdcooper <> tbgen_trans_pend.cdcoptfn
				AND tbgen_trans_pend.cdcoptfn <> 0
				AND tbgen_trans_pend.idorigem_transacao = 4 /* TAA */
				AND tbgen_trans_pend.tptransacao = 2 /* Pagamento */
				AND tbpagto_trans_pend.cdtransacao_pendente =
						tbgen_trans_pend.cdtransacao_pendente
				AND tbpagto_trans_pend.idagendamento = 1 /* Nesta Data */
	 GROUP BY tbgen_trans_pend.cdcooper
					 ,tbgen_trans_pend.cdcoptfn
					 ,tbgen_trans_pend.cdagetfn
					 ,tbgen_trans_pend.nrdconta;

    -- Variaveis gerais
    vr_ind VARCHAR2(38);              --> Indice da Pl_table pr_tab_lancamentos

  BEGIN
    pr_tab_lancamentos.delete;

    -- Saques feitos no meu TAA por outras Coops
    IF pr_cdcoptfn <> 0 THEN

      -- Loop sobre os titulos acolhidos
      FOR rw_craptit IN cr_craptit LOOP

        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')||lpad(rw_craptit.cdcooper,10,'0')||lpad(rw_craptit.cdcoptfn,10,'0')||
                  lpad(rw_craptit.cdagetfn,5,'0') ||lpad(rw_craptit.nrdconta,10,'0');

        -- Atualiza a temp-table de retorno
        pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
        pr_tab_lancamentos(vr_ind).cdcooper := rw_craptit.cdcooper;
        pr_tab_lancamentos(vr_ind).cdcoptfn := rw_craptit.cdcoptfn;
        pr_tab_lancamentos(vr_ind).cdagetfn := rw_craptit.cdagetfn;
        pr_tab_lancamentos(vr_ind).nrdconta := rw_craptit.nrdconta;
        pr_tab_lancamentos(vr_ind).qtdecoop := 1;
        pr_tab_lancamentos(vr_ind).dstplanc := 'Pagamento';
        pr_tab_lancamentos(vr_ind).tpconsul := 'TAA';
        pr_tab_lancamentos(vr_ind).qtdmovto := rw_craptit.qtdmovto;
        pr_tab_lancamentos(vr_ind).vlrtotal := rw_craptit.vldpagto;

      END LOOP;

      -- Loop sobre os lancamentos de faturas
      FOR rw_craplft IN cr_craplft LOOP

        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')||lpad(rw_craplft.cdcooper,10,'0')||lpad(rw_craplft.cdcoptfn,10,'0')||
                  lpad(rw_craplft.cdagetfn,5,'0') ||lpad(rw_craplft.nrdconta,10,'0');

        -- Verifica se existe registro
        IF pr_tab_lancamentos.exists(vr_ind) THEN
          -- Incrementa os totalizadores
          pr_tab_lancamentos(vr_ind).qtdmovto := pr_tab_lancamentos(vr_ind).qtdmovto + rw_craplft.qtdmovto;
          pr_tab_lancamentos(vr_ind).vlrtotal := pr_tab_lancamentos(vr_ind).vlrtotal + rw_craplft.vlrtotal;
        ELSE
          -- Atualiza a temp-table de retorno
          pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
          pr_tab_lancamentos(vr_ind).cdcooper := rw_craplft.cdcooper;
          pr_tab_lancamentos(vr_ind).cdcoptfn := rw_craplft.cdcoptfn;
          pr_tab_lancamentos(vr_ind).cdagetfn := rw_craplft.cdagetfn;
          pr_tab_lancamentos(vr_ind).nrdconta := rw_craplft.nrdconta;
          pr_tab_lancamentos(vr_ind).qtdecoop := 1;
          pr_tab_lancamentos(vr_ind).dstplanc := 'Pagamento';
          pr_tab_lancamentos(vr_ind).tpconsul := 'TAA';
          pr_tab_lancamentos(vr_ind).qtdmovto := rw_craplft.qtdmovto;
          pr_tab_lancamentos(vr_ind).vlrtotal := rw_craplft.vlrtotal;
        END IF;
      END LOOP;

			FOR rw_tbgen_trans_pend IN cr_tbgen_trans_pend LOOP
                  -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')
				        ||lpad(rw_tbgen_trans_pend.cdcooper,10,'0')
								||lpad(rw_tbgen_trans_pend.cdcoptfn,10,'0')
								||lpad(rw_tbgen_trans_pend.cdagetfn,5,'0') 
								||lpad(rw_tbgen_trans_pend.nrdconta,10,'0');

        -- Verifica se existe registro
        IF pr_tab_lancamentos.exists(vr_ind) THEN
          -- Incrementa os totalizadores
          pr_tab_lancamentos(vr_ind).qtdmovto := pr_tab_lancamentos(vr_ind).qtdmovto + rw_tbgen_trans_pend.qtdmovto;
          pr_tab_lancamentos(vr_ind).vlrtotal := pr_tab_lancamentos(vr_ind).vlrtotal + rw_tbgen_trans_pend.vldpagto;
        ELSE
          -- Atualiza a temp-table de retorno
          pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
          pr_tab_lancamentos(vr_ind).cdcooper := rw_tbgen_trans_pend.cdcooper;
          pr_tab_lancamentos(vr_ind).cdcoptfn := rw_tbgen_trans_pend.cdcoptfn;
          pr_tab_lancamentos(vr_ind).cdagetfn := rw_tbgen_trans_pend.cdagetfn;
          pr_tab_lancamentos(vr_ind).nrdconta := rw_tbgen_trans_pend.nrdconta;
          pr_tab_lancamentos(vr_ind).qtdecoop := 1;
          pr_tab_lancamentos(vr_ind).dstplanc := 'Pagamento';
          pr_tab_lancamentos(vr_ind).tpconsul := 'TAA';
          pr_tab_lancamentos(vr_ind).qtdmovto := rw_tbgen_trans_pend.qtdmovto;
          pr_tab_lancamentos(vr_ind).vlrtotal := rw_tbgen_trans_pend.vldpagto;
        END IF;				
			END LOOP;
    END IF; /* END do IF pr_cdcoptfn */


    -- Saques feitos por meus Assoc. em outras Coops
    IF pr_cdcooper <> 0 THEN

      -- Loop sobre os titulos acolhidos
      FOR rw_craptit IN cr_craptit_2 LOOP

        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')||lpad(rw_craptit.cdcooper,10,'0')||lpad(rw_craptit.cdcoptfn,10,'0')||
                  lpad(rw_craptit.cdagetfn,5,'0') ||lpad(rw_craptit.nrdconta,10,'0');

        -- Atualiza a temp-table de retorno
        pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
        pr_tab_lancamentos(vr_ind).cdcooper := rw_craptit.cdcooper;
        pr_tab_lancamentos(vr_ind).cdcoptfn := rw_craptit.cdcoptfn;
        pr_tab_lancamentos(vr_ind).cdagetfn := rw_craptit.cdagetfn;
        pr_tab_lancamentos(vr_ind).nrdconta := rw_craptit.nrdconta;
        pr_tab_lancamentos(vr_ind).qtdecoop := 1;
        pr_tab_lancamentos(vr_ind).dstplanc := 'Pagamento';
        pr_tab_lancamentos(vr_ind).tpconsul := 'Outras Coop';
        pr_tab_lancamentos(vr_ind).qtdmovto := rw_craptit.qtdmovto;
        pr_tab_lancamentos(vr_ind).vlrtotal := rw_craptit.vldpagto;

      END LOOP;

      -- Loop sobre os lancamentos de faturas
      FOR rw_craplft IN cr_craplft_2 LOOP

        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')||lpad(rw_craplft.cdcooper,10,'0')||lpad(rw_craplft.cdcoptfn,10,'0')||
                  lpad(rw_craplft.cdagetfn,5,'0') ||lpad(rw_craplft.nrdconta,10,'0');

        -- Verifica se existe registro
        IF pr_tab_lancamentos.exists(vr_ind) THEN
          -- Incrementa os totalizadores
          pr_tab_lancamentos(vr_ind).qtdmovto := pr_tab_lancamentos(vr_ind).qtdmovto + rw_craplft.qtdmovto;
          pr_tab_lancamentos(vr_ind).vlrtotal := pr_tab_lancamentos(vr_ind).vlrtotal + rw_craplft.vlrtotal;
        ELSE
          -- Atualiza a temp-table de retorno
          pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
          pr_tab_lancamentos(vr_ind).cdcooper := rw_craplft.cdcooper;
          pr_tab_lancamentos(vr_ind).cdcoptfn := rw_craplft.cdcoptfn;
          pr_tab_lancamentos(vr_ind).cdagetfn := rw_craplft.cdagetfn;
          pr_tab_lancamentos(vr_ind).nrdconta := rw_craplft.nrdconta;
          pr_tab_lancamentos(vr_ind).qtdecoop := 1;
          pr_tab_lancamentos(vr_ind).dstplanc := 'Pagamento';
          pr_tab_lancamentos(vr_ind).tpconsul := 'Outras Coop';
          pr_tab_lancamentos(vr_ind).qtdmovto := rw_craplft.qtdmovto;
          pr_tab_lancamentos(vr_ind).vlrtotal := rw_craplft.vlrtotal;
        END IF;
      END LOOP;
			
			FOR rw_tbgen_trans_pend_2 IN cr_tbgen_trans_pend_2 LOOP
        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')
				        ||lpad(rw_tbgen_trans_pend_2.cdcooper,10,'0')
								||lpad(rw_tbgen_trans_pend_2.cdcoptfn,10,'0')
								||lpad(rw_tbgen_trans_pend_2.cdagetfn,5,'0') 
								||lpad(rw_tbgen_trans_pend_2.nrdconta,10,'0');

        -- Verifica se existe registro
        IF pr_tab_lancamentos.exists(vr_ind) THEN
          -- Incrementa os totalizadores
          pr_tab_lancamentos(vr_ind).qtdmovto := pr_tab_lancamentos(vr_ind).qtdmovto + rw_tbgen_trans_pend_2.qtdmovto;
          pr_tab_lancamentos(vr_ind).vlrtotal := pr_tab_lancamentos(vr_ind).vlrtotal + rw_tbgen_trans_pend_2.vldpagto;
        ELSE
          -- Atualiza a temp-table de retorno
          pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
          pr_tab_lancamentos(vr_ind).cdcooper := rw_tbgen_trans_pend_2.cdcooper;
          pr_tab_lancamentos(vr_ind).cdcoptfn := rw_tbgen_trans_pend_2.cdcoptfn;
          pr_tab_lancamentos(vr_ind).cdagetfn := rw_tbgen_trans_pend_2.cdagetfn;
          pr_tab_lancamentos(vr_ind).nrdconta := rw_tbgen_trans_pend_2.nrdconta;
          pr_tab_lancamentos(vr_ind).qtdecoop := 1;
          pr_tab_lancamentos(vr_ind).dstplanc := 'Pagamento';
          pr_tab_lancamentos(vr_ind).tpconsul := 'Outras Coop';
          pr_tab_lancamentos(vr_ind).qtdmovto := rw_tbgen_trans_pend_2.qtdmovto;
          pr_tab_lancamentos(vr_ind).vlrtotal := rw_tbgen_trans_pend_2.vldpagto;
        END IF;
      END LOOP;
    END IF; /* END do IF pr_cdcooper */

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na COBR0001.pc_taa_lancto_titulos_conv: '||SQLerrm;
  END pc_taa_lancto_titulos_conv;


  PROCEDURE pc_taa_agenda_titulos_conv(pr_cdcooper        IN  crapcop.cdcooper%TYPE,
                                       pr_cdcoptfn        IN  craplcm.cdcoptfn%TYPE,
                                       pr_dtmvtoin        IN  DATE,
                                       pr_dtmvtofi        IN  DATE,
                                       pr_cdtplanc        IN  PLS_INTEGER,
                                       pr_dscritic        OUT VARCHAR2,
                                       pr_tab_lancamentos OUT CADA0001.typ_tab_lancamentos) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_taa_agenda_titulos_conv           Antigo: Antigo b1wgen0025.p/taa_agenda_titulos_convenvios
  --  Sistema  : Procedimentos para arquivos de cobranca
  --  Sigla    : CRED
  --  Autor    : Andrino Carlos de Souza Junior (RKAM)
  --  Data     : 06/05/2014                Ultima atualizacao: -
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Consulta por:
  --                Agendamentos de pagamento feitos no meu TAA por outras Coops (pr_cdcoptfn <> 0)
  --                Agendamentos de pagamento feitos por meus Assoc. em outras Coops (pr_cdcooper <> 0)
  --
  ---------------------------------------------------------------------------------------------------------------
    -- Cursor sobre os lancamentos automaticos
    CURSOR cr_craplau IS
      SELECT cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta,
             SUM(vllanaut) vllanaut,
             COUNT(*) qtdmovto
        FROM craplau
       WHERE craplau.cdcoptfn =  pr_cdcoptfn
         AND craplau.cdagenci =  91 -- PAC TRANSACOES TAA
         AND craplau.cdtiptra =  2 -- Pagamentos
         AND craplau.dtmvtolt >= pr_dtmvtoin
         AND craplau.dtmvtolt <= pr_dtmvtofi
         AND craplau.cdcooper <> craplau.cdcoptfn
       GROUP BY cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta;

    CURSOR cr_craplau_2 IS
      SELECT cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta,
             SUM(vllanaut) vllanaut,
             COUNT(*) qtdmovto
        FROM craplau
       WHERE craplau.cdcooper  = pr_cdcooper
         AND craplau.cdagenci =  91 -- PAC TRANSACOES TAA
         AND craplau.cdtiptra =  2 -- Pagamentos
         AND craplau.dtmvtolt >= pr_dtmvtoin
         AND craplau.dtmvtolt <= pr_dtmvtofi
         AND craplau.cdcooper <> craplau.cdcoptfn
       GROUP BY cdcooper,
             cdcoptfn,
             cdagetfn,
             nrdconta;

		CURSOR cr_tbgen_trans_pend IS
		  SELECT tbgen_trans_pend.cdcooper
						,tbgen_trans_pend.cdcoptfn
						,tbgen_trans_pend.cdagetfn
						,tbgen_trans_pend.nrdconta
						,SUM(tbpagto_trans_pend.vlpagamento) vldpagto
						,COUNT(*) qtdmovto
			 FROM tbgen_trans_pend, 
			      tbpagto_trans_pend 
			WHERE tbgen_trans_pend.cdcoptfn = pr_cdcoptfn 
				AND tbgen_trans_pend.dtmvtolt >= pr_dtmvtoin
				AND tbgen_trans_pend.dtmvtolt <= pr_dtmvtofi
				AND tbgen_trans_pend.cdcooper <> tbgen_trans_pend.cdcoptfn
				AND tbgen_trans_pend.idorigem_transacao = 4 /* TAA */
				AND tbgen_trans_pend.tptransacao = 2 /* Pagamento */
				AND tbpagto_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente
				AND tbpagto_trans_pend.idagendamento = 2 /* Agendamento */
	 GROUP BY tbgen_trans_pend.cdcooper
					 ,tbgen_trans_pend.cdcoptfn
					 ,tbgen_trans_pend.cdagetfn
					 ,tbgen_trans_pend.nrdconta;
					 
		CURSOR cr_tbgen_trans_pend_2 IS
		  SELECT tbgen_trans_pend.cdcooper
						,tbgen_trans_pend.cdcoptfn
						,tbgen_trans_pend.cdagetfn
						,tbgen_trans_pend.nrdconta
						,SUM(tbpagto_trans_pend.vlpagamento) vldpagto
						,COUNT(*) qtdmovto
			 FROM tbgen_trans_pend, 
			      tbpagto_trans_pend 
			WHERE tbgen_trans_pend.cdcooper = pr_cdcooper
				AND tbgen_trans_pend.dtmvtolt >= pr_dtmvtoin
				AND tbgen_trans_pend.dtmvtolt <= pr_dtmvtofi
				AND tbgen_trans_pend.cdcooper <> tbgen_trans_pend.cdcoptfn
				AND tbgen_trans_pend.cdcoptfn <> 0
				AND tbgen_trans_pend.idorigem_transacao = 4 /* TAA */
				AND tbgen_trans_pend.tptransacao = 2 /* Pagamento */
				AND tbpagto_trans_pend.cdtransacao_pendente =	tbgen_trans_pend.cdtransacao_pendente
				AND tbpagto_trans_pend.idagendamento = 2 /* Agendamento */
	 GROUP BY tbgen_trans_pend.cdcooper
					 ,tbgen_trans_pend.cdcoptfn
					 ,tbgen_trans_pend.cdagetfn
					 ,tbgen_trans_pend.nrdconta;

    -- Variaveis gerais
    vr_ind VARCHAR2(38);              --> Indice da Pl_table pr_tab_lancamentos

  BEGIN
    pr_tab_lancamentos.delete;

    -- Agendamentos de pagamento feitos no meu TAA por outras Coops
    IF pr_cdcoptfn <> 0 THEN

      -- Loop sobre os lancamentos automaticos
      FOR rw_craplau IN cr_craplau LOOP

        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')||lpad(rw_craplau.cdcooper,10,'0')||lpad(rw_craplau.cdcoptfn,5,'0')||
                  lpad(rw_craplau.cdagetfn,5,'0') ||lpad(rw_craplau.nrdconta,10,'0');

        -- Atualiza a temp-table de retorno
        pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
        pr_tab_lancamentos(vr_ind).cdcooper := rw_craplau.cdcooper;
        pr_tab_lancamentos(vr_ind).cdcoptfn := rw_craplau.cdcoptfn;
        pr_tab_lancamentos(vr_ind).cdagetfn := rw_craplau.cdagetfn;
        pr_tab_lancamentos(vr_ind).nrdconta := rw_craplau.nrdconta;
        pr_tab_lancamentos(vr_ind).qtdecoop := 1;
        pr_tab_lancamentos(vr_ind).dstplanc := 'Agendamento de Pagamento';
        pr_tab_lancamentos(vr_ind).tpconsul := 'TAA';
        pr_tab_lancamentos(vr_ind).qtdmovto := rw_craplau.qtdmovto;
        pr_tab_lancamentos(vr_ind).vlrtotal := rw_craplau.vllanaut;

      END LOOP;

			FOR rw_tbgen_trans_pend IN cr_tbgen_trans_pend LOOP

        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')
				        ||lpad(rw_tbgen_trans_pend.cdcooper,10,'0')
				        ||lpad(rw_tbgen_trans_pend.cdcoptfn,5,'0')
                ||lpad(rw_tbgen_trans_pend.cdagetfn,5,'0') 
								||lpad(rw_tbgen_trans_pend.nrdconta,10,'0');


        -- Verifica se existe registro
        IF pr_tab_lancamentos.exists(vr_ind) THEN
          -- Incrementa os totalizadores
          pr_tab_lancamentos(vr_ind).qtdmovto := pr_tab_lancamentos(vr_ind).qtdmovto + rw_tbgen_trans_pend.qtdmovto;
          pr_tab_lancamentos(vr_ind).vlrtotal := pr_tab_lancamentos(vr_ind).vlrtotal + rw_tbgen_trans_pend.vldpagto;
        ELSE
					-- Atualiza a temp-table de retorno
					pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
					pr_tab_lancamentos(vr_ind).cdcooper := rw_tbgen_trans_pend.cdcooper;
					pr_tab_lancamentos(vr_ind).cdcoptfn := rw_tbgen_trans_pend.cdcoptfn;
					pr_tab_lancamentos(vr_ind).cdagetfn := rw_tbgen_trans_pend.cdagetfn;
					pr_tab_lancamentos(vr_ind).nrdconta := rw_tbgen_trans_pend.nrdconta;
					pr_tab_lancamentos(vr_ind).qtdecoop := 1;
					pr_tab_lancamentos(vr_ind).dstplanc := 'Agendamento de Pagamento';
					pr_tab_lancamentos(vr_ind).tpconsul := 'TAA';
					pr_tab_lancamentos(vr_ind).qtdmovto := rw_tbgen_trans_pend.qtdmovto;
					pr_tab_lancamentos(vr_ind).vlrtotal := rw_tbgen_trans_pend.vldpagto;
				END IF;
      END LOOP;

    END IF; /* End If pr_cdcopftn */

    IF pr_cdcooper <> 0 THEN

      -- Loop sobre os lancamentos automaticos
      FOR rw_craplau IN cr_craplau_2 LOOP

        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')||lpad(rw_craplau.cdcooper,10,'0')||lpad(rw_craplau.cdcoptfn,10,'0')||
                  lpad(rw_craplau.cdagetfn,5,'0') ||lpad(rw_craplau.nrdconta,10,'0');

        -- Atualiza a temp-table de retorno
        pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
        pr_tab_lancamentos(vr_ind).cdcooper := rw_craplau.cdcooper;
        pr_tab_lancamentos(vr_ind).cdcoptfn := rw_craplau.cdcoptfn;
        pr_tab_lancamentos(vr_ind).cdagetfn := rw_craplau.cdagetfn;
        pr_tab_lancamentos(vr_ind).nrdconta := rw_craplau.nrdconta;
        pr_tab_lancamentos(vr_ind).qtdecoop := 1;
        pr_tab_lancamentos(vr_ind).dstplanc := 'Agendamento de Pagamento';
        pr_tab_lancamentos(vr_ind).tpconsul := 'Outras Coop';
        pr_tab_lancamentos(vr_ind).qtdmovto := rw_craplau.qtdmovto;
        pr_tab_lancamentos(vr_ind).vlrtotal := rw_craplau.vllanaut;

      END LOOP;

   		FOR rw_tbgen_trans_pend_2 IN cr_tbgen_trans_pend_2 LOOP

        -- Atualiza o indice
        vr_ind := lpad(pr_cdtplanc,3,'0')
				        ||lpad(rw_tbgen_trans_pend_2.cdcooper,10,'0')
								||lpad(rw_tbgen_trans_pend_2.cdcoptfn,10,'0')
                ||lpad(rw_tbgen_trans_pend_2.cdagetfn,5,'0') 
								||lpad(rw_tbgen_trans_pend_2.nrdconta,10,'0');

        -- Verifica se existe registro
        IF pr_tab_lancamentos.exists(vr_ind) THEN
          -- Incrementa os totalizadores
          pr_tab_lancamentos(vr_ind).qtdmovto := pr_tab_lancamentos(vr_ind).qtdmovto + rw_tbgen_trans_pend_2.qtdmovto;
          pr_tab_lancamentos(vr_ind).vlrtotal := pr_tab_lancamentos(vr_ind).vlrtotal + rw_tbgen_trans_pend_2.vldpagto;
        ELSE
					-- Atualiza a temp-table de retorno
					pr_tab_lancamentos(vr_ind).cdtplanc := pr_cdtplanc;
					pr_tab_lancamentos(vr_ind).cdcooper := rw_tbgen_trans_pend_2.cdcooper;
					pr_tab_lancamentos(vr_ind).cdcoptfn := rw_tbgen_trans_pend_2.cdcoptfn;
					pr_tab_lancamentos(vr_ind).cdagetfn := rw_tbgen_trans_pend_2.cdagetfn;
					pr_tab_lancamentos(vr_ind).nrdconta := rw_tbgen_trans_pend_2.nrdconta;
					pr_tab_lancamentos(vr_ind).qtdecoop := 1;
					pr_tab_lancamentos(vr_ind).dstplanc := 'Agendamento de Pagamento';
					pr_tab_lancamentos(vr_ind).tpconsul := 'Outras Coop';
					pr_tab_lancamentos(vr_ind).qtdmovto := rw_tbgen_trans_pend_2.qtdmovto;
					pr_tab_lancamentos(vr_ind).vlrtotal := rw_tbgen_trans_pend_2.vldpagto;
        END IF;			
		  END LOOP;

    END IF; /* End If pr_cdcooper */

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na COBR0001.pc_taa_agenda_titulos_conv: '||SQLerrm;
  END pc_taa_agenda_titulos_conv;

  /* Gerar os arquivos de retorno do arquivo de cobrança */
  PROCEDURE pc_gera_retorno_arq_cobranca(pr_cdcooper IN crapcop.cdcooper%TYPE        -- Codigo da cooperativa
                                        ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype  -- registro com as data do sistema
                                        ,pr_nrdconta IN crapass.nrdconta%type        -- Numero da conta
                                        ,pr_dtpgtini IN DATE                         -- data inicial do pagamento
                                        ,pr_dtpgtfim IN DATE                         -- Data final do pagamento
                                        ,pr_nrcnvcob IN INTEGER                      -- Numero do convenio de cobrança
                                        ,pr_cdagenci IN INTEGER                      -- Codigo da agencia para erros
                                        ,pr_nrdcaixa IN INTEGER                      -- Codigo do caixa para erros
                                        ,pr_origem   IN INTEGER                      -- indicador de origem /* 1-AYLLOS/2-CAIXA/3-INTERNET */
                                        ,pr_cdprogra IN VARCHAR2                     -- Codigo do programa
                                        ,pr_des_reto OUT VARCHAR2                    -- Descricao do retorno 'OK/NOK'
                                        ,pr_tab_arq_cobranca OUT COBR0001.typ_tab_arq_cobranca -- temptable com as linhas do arquivo de cobrança
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro) IS   -- tabela de erros

  /*--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_retorno_arq_cobranca           Antigo: b1wgen0010.p/gera_retorno_arq_cobranca
  --  Sistema  : Procedimentos para arquivos de cobranca
  --  Sigla    : CRED
  --  Autor    : Edison Eduardo Bonomi (AMcom)
  --  Data     : Junho/2014.                Ultima atualizacao: 17/06/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimento para gerar o arquivo de retorno arquivo de cobrança
  --
  -- Alteracoes: 17/06/2014 - Conversão Progres --> Oracle (Odirlei-AMcom)
  --
  --
  ---------------------------------------------------------------------------------------------------------------*/
    ------------------------------- CURSORES ---------------------------------
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.*
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Busca dos dados dos bloquetos de cobranca
    CURSOR cr_crapcob (pr_cdcooper crapcob.cdcooper%type,
                       pr_dtpgtini crapcob.dtdpagto%type,
                       pr_dtpgtfim crapcob.dtdpagto%type,
                       pr_nrcnvcob crapcob.nrcnvcob%type,
                       pr_nrdconta crapcob.nrdconta%type) IS
      SELECT flgregis,
             nrcnvcob,
             cdcooper,
             nrdconta,
             incobran,
             vldpagto,
             cdbandoc,
             indpagto,
             dtdpagto,
             nrdocmto
        FROM crapcob
       WHERE crapcob.cdcooper = pr_cdcooper
         AND crapcob.dtdpagto >= pr_dtpgtini
         AND crapcob.dtdpagto <= pr_dtpgtfim
         AND /*flgregis = FALSE - cob sem reg */
             crapcob.flgregis = 0 /*FALSE*/
         AND ((crapcob.nrcnvcob = pr_nrcnvcob) OR (nvl(pr_nrcnvcob,0) = 0))
         AND ((crapcob.nrdconta = pr_nrdconta) OR (nvl(pr_nrdconta,0) = 0));

    -- Busca dos dados dos parametros do cadastro de cobranca
    CURSOR cr_crapcco (pr_cdcooper crapcob.cdcooper%type,
                       pr_nrcnvcob crapcob.nrcnvcob%type) IS
      SELECT flgregis,
             dsorgarq,
             tamannro,
             nrdctabb,
             flgutceb
        FROM crapcco
       WHERE crapcco.cdcooper = pr_cdcooper
         AND crapcco.nrconven = pr_nrcnvcob;
    rw_crapcco cr_crapcco%rowtype;

    -- buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper crapcob.cdcooper%type,
                       pr_nrdconta crapcob.nrdconta%type) IS
      SELECT inpessoa
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;

    -- cadastro de e-mails
    CURSOR cr_crapcem ( pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapcem.nrdconta%TYPE
                       ,pr_cddemail IN crapcem.cddemail%TYPE) IS
      SELECT crapcem.dsdemail
      FROM   crapcem
      WHERE  crapcem.cdcooper = pr_cdcooper
      AND    crapcem.nrdconta = pr_nrdconta
      AND    crapcem.idseqttl = 1
      AND    crapcem.cddemail = pr_cddemail;
    rw_crapcem cr_crapcem%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

    ------------------------------- VARIAVEIS -------------------------------
    -- controle de criticas
    vr_exc_saida     EXCEPTION;
    vr_exc_erro      EXCEPTION;
    vr_cod_erro      crapcri.cdcritic%TYPE;
    vr_dsc_erro      VARCHAR2(4000);
    -- indicador de tipo de associado
    vr_inpessoa      crapass.inpessoa%type;
    -- Variaveis com informações da tarifa
    vr_tar_cdhistor  INTEGER;
    vr_tar_cdhisest  INTEGER;
    vr_tar_dtdivulg  DATE;
    vr_tar_dtvigenc  DATE;
    vr_tar_cdfvlcop  INTEGER;
    vr_tar_vlrtarcx  NUMBER;
    vr_tar_vlrtarnt  NUMBER;
    vr_tar_vltrftaa  NUMBER;
    vr_tar_vlrtarif  NUMBER;
    -- Data de credito
    vr_dtcredit      DATE;
    -- indice da tempTable
    vr_indcrawarq    VARCHAR2(100);
    vr_tab_arq       typ_tab_arq;

    --------------------------- SUBROTINAS INTERNAS --------------------------

  BEGIN
    --------------- VALIDACOES INICIAIS -----------------
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cod_erro := 651; --> 651 - Falta registro de controle da cooperativa - ERRO DE SISTEMA
      vr_dsc_erro := NULL;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- ler bloquetos de cobrança
    FOR rw_crapcob IN cr_crapcob ( pr_cdcooper => pr_cdcooper,
                                   pr_dtpgtini => pr_dtpgtini,
                                   pr_dtpgtfim => pr_dtpgtfim,
                                   pr_nrcnvcob => pr_nrcnvcob,
                                   pr_nrdconta => pr_nrdconta) LOOP

      -- ler parametros de cobrança
      OPEN cr_crapcco(pr_cdcooper => pr_cdcooper,
                      pr_nrcnvcob => rw_crapcob.nrcnvcob);
      FETCH cr_crapcco INTO rw_crapcco;
      -- Se não encontrar
      IF cr_crapcco%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcco;
        -- Montar mensagem de critica
        vr_cod_erro := 472; --> 472 - Falta tabela de convenio.
        vr_dsc_erro := NULL;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcco;
      END IF;

      /* Ajuste para evitar busca de tarifa incorreta */
      IF rw_crapcco.flgregis <> rw_crapcob.flgregis THEN
        -- ir para o proximo registro da crapcob
        continue;
      END IF;

      -- inicializar valor
      vr_inpessoa := 2;
      -- se foi informado o numero de conta, buscar dados do cooperado
      IF nvl(pr_nrdconta,0) <> 0 THEN
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        -- se encontrou associado, atribuir valor
        IF cr_crapass%FOUND THEN
          vr_inpessoa := rw_crapass.inpessoa;
        END IF;
        -- fechar cursor
        CLOSE cr_crapass;
      END IF;

      -- busca o valor das tarifas
      pc_pega_valor_tarifas( pr_cdcooper => pr_cdcooper         -- Codigo da cooperativa
                            ,pr_nrdconta => pr_nrdconta         -- Numero Conta
                            ,pr_cdprogra => pr_cdprogra         -- Codigo do programa
                            ,pr_nrcnvcob => rw_crapcob.nrcnvcob -- Codigo do convenio
                            ,pr_inpessoa => vr_inpessoa         -- Indica o tipo de pessoa Fisica/Juridica
                            ,pr_cdhistor => vr_tar_cdhistor     -- Codigo do historico
                            ,pr_cdhisest => vr_tar_cdhisest     -- Codigo do historico de estorno
                            ,pr_dtdivulg => vr_tar_dtdivulg     -- Data divulgacao
                            ,pr_dtvigenc => vr_tar_dtvigenc     -- data vigencia
                            ,pr_cdfvlcop => vr_tar_cdfvlcop     -- Codigo da cooperativa
                            ,pr_vlrtarcx => vr_tar_vlrtarcx     -- Valor tarifa caixa
                            ,pr_vlrtarnt => vr_tar_vlrtarnt     -- Valor tarifa internet
                            ,pr_vltrftaa => vr_tar_vltrftaa     -- Valor tarifa TAA
                            ,pr_vlrtarif => vr_tar_vlrtarif     -- Valor tarifa
                            ,pr_cdcritic => vr_cod_erro         -- Codigo da critica
                            ,pr_dscritic => vr_dsc_erro         -- Descricao da critica
                            ,pr_tab_erro => pr_tab_erro);       -- Tabela de erros

       -- se ocorreu alguma critica, vai para o proximo registro
      IF trim(vr_dsc_erro) IS NOT NULL THEN
        CONTINUE;
      END IF;

      -- cadastro de emissao de bloquetos
      OPEN cr_crapceb( pr_cdcooper => rw_crapcob.cdcooper
                      ,pr_nrdconta => rw_crapcob.nrdconta
                      ,pr_nrconven => rw_crapcob.nrcnvcob);
      FETCH cr_crapceb INTO rw_crapceb;

      -- se existir dados, ajusta o nosso numero
      IF cr_crapceb%NOTFOUND THEN
        close cr_crapceb;
        -- ir para o proximo registro da crapcob
        CONTINUE;
      ELSE
        close cr_crapceb;
      END IF;

      /* Consistencia qdo execucao eh via Ayllos que ocorre na diaria */
      IF pr_origem <> 3 THEN
        IF rw_crapcob.incobran <> 5 OR
          rw_crapcob.vldpagto  = 0 THEN
          -- ir para o proximo registro da crapcob
          continue;
        END IF;
      END IF;

      /* Consistencia qdo execucao eh via Ayllos que ocorre na diaria */
      IF pr_origem <> 3 THEN
        IF rw_crapceb.inarqcbr = 0  OR  /*  Nao recebe arq. de Retorno */
           (rw_crapceb.inarqcbr = 2 AND
            upper(rw_crapcco.dsorgarq) = 'PRE-IMPRESSO')  THEN
          -- ir para o proximo registro da crapcob
          continue;
        END IF;
      ELSIF pr_origem = 3 THEN   /* Internet */
        IF rw_crapceb.inarqcbr = 0  OR  /*  Nao recebe arq. de Retorno */
          (rw_crapceb.inarqcbr = 2 AND
           upper(rw_crapcco.dsorgarq) = 'PRE-IMPRESSO')  THEN

          -- Montar mensagem de critica
          vr_cod_erro := 36; --> 036 - Operacao nao autorizada.
          vr_dsc_erro := NULL;
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- seleciona o e-mail da conta do cooperado
      OPEN cr_crapcem ( pr_cdcooper => rw_crapcob.cdcooper
                       ,pr_nrdconta => rw_crapcob.nrdconta
                       ,pr_cddemail => rw_crapceb.cddemail);
      FETCH cr_crapcem INTO rw_crapcem;
      CLOSE cr_crapcem;

      -- se for banco 1 e compensado
      IF rw_crapcob.cdbandoc = 1 AND
         rw_crapcob.indpagto = 0 THEN -- 0-compensacao

        vr_dtcredit := rw_crapcob.dtdpagto + 1;
        -- buscar proximo dia util
        vr_dtcredit := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                   pr_dtmvtolt => vr_dtcredit,
                                                   pr_tipo => 'P',
                                                   pr_feriado => TRUE );


      ELSE
        vr_dtcredit := rw_crapcob.dtdpagto;
      END IF;

      -- gerando o indice da tabela temporaria
      vr_indcrawarq := LPad(rw_crapcob.nrcnvcob,10,'0')||
                       LPad(rw_crapcob.nrdconta,10,'0')||
                       To_Char(rw_crapcob.dtdpagto,'YYYYMMDD')||
                       LPad(rw_crapcob.nrdocmto,10,'0');

      -- alimentando a tabela temporaria
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).tparquiv := rw_crapceb.inarqcbr;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).nrdconta := rw_crapcob.nrdconta;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).nrdocmto := rw_crapcob.nrdocmto;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).nrconven := rw_crapcob.nrcnvcob;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).tamannro := rw_crapcco.tamannro;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).nrdctabb := rw_crapcco.nrdctabb;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).vldpagto := rw_crapcob.vldpagto;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).vlrtarcx := vr_tar_vlrtarcx;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).vlrtarnt := vr_tar_vlrtarnt;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).vltrftaa := vr_tar_vltrftaa; /** TAA **/
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).vlrtarcm := vr_tar_vlrtarif;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).inarqcbr := rw_crapceb.inarqcbr;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).flgutceb := rw_crapcco.flgutceb;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).dsorgarq := rw_crapcco.dsorgarq;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).indpagto := rw_crapcob.indpagto;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).dtdpagto := rw_crapcob.dtdpagto;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).dsdemail := rw_crapcem.dsdemail;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).cdbandoc := rw_crapcob.cdbandoc;
      vr_tab_arq(rw_crapceb.inarqcbr)(vr_indcrawarq).dtcredit := vr_dtcredit;

    END LOOP;  -- Fim LOOP crapcob

    -- verificar se existe informações para gerar arquivo da febraban
    IF vr_tab_arq.EXISTS(2) THEN
      /* Gerar os arquivos de retorno da febraban */
      COBR0001.pc_gera_arquivo_febraban
                               ( pr_cdcooper => pr_cdcooper   -- Codigo da cooperativa
                                ,pr_crapdat  => pr_crapdat    -- registro com as data do sistema
                                ,pr_crapcop  => rw_crapcop    -- Registro da cooperativa
                                ,pr_cdagenci => pr_cdagenci   -- Codigo da agencia para erros
                                ,pr_nrdcaixa => pr_nrdcaixa   -- Codigo do caixa para erros
                                ,pr_origem   => pr_origem     -- indicador de origem /* 1-AYLLOS/2-CAIXA/3-INTERNET */
                                ,pr_cdprogra => pr_cdprogra   -- Codigo do programa
                                ,pr_tab_crawarq => vr_tab_arq(2) -- registros a serem gerados no arquivo
                                ,pr_des_reto    => pr_des_reto-- Descricao do retorno 'OK/NOK'
                                ,pr_tab_arq_cobranca => pr_tab_arq_cobranca
                                ,pr_tab_erro => pr_tab_erro); -- tabela de erros

      IF NVL(pr_des_reto,'OK') <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -- verificar se existe informações para gerar aquivo dos outros
    IF vr_tab_arq.EXISTS(1) THEN
      /* Gerar os arquivos de retorno da febraban */
      COBR0001.pc_gera_arquivo_outros
                               ( pr_cdcooper => pr_cdcooper   -- Codigo da cooperativa
                                ,pr_crapdat  => pr_crapdat    -- registro com as data do sistema
                                ,pr_crapcop  => rw_crapcop    -- Registro da cooperativa
                                ,pr_cdagenci => pr_cdagenci   -- Codigo da agencia para erros
                                ,pr_nrdcaixa => pr_nrdcaixa   -- Codigo do caixa para erros
                                ,pr_origem   => pr_origem     -- indicador de origem /* 1-AYLLOS/2-CAIXA/3-INTERNET */
                                ,pr_cdprogra => pr_cdprogra   -- Codigo do programa
                                ,pr_tab_crawarq => vr_tab_arq(1) -- registros a serem gerados no arquivo
                                ,pr_des_reto    => pr_des_reto-- Descricao do retorno 'OK/NOK'
                                ,pr_tab_arq_cobranca => pr_tab_arq_cobranca
                                ,pr_tab_erro => pr_tab_erro); -- tabela de erros

      IF NVL(pr_des_reto,'OK') <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      NULL;
    WHEN vr_exc_saida THEN

      pr_des_reto := 'NOK';
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cod_erro
                           ,pr_dscritic => vr_dsc_erro
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- Retornando a critica para o programa chamdador
      vr_cod_erro := 0;
      vr_dsc_erro := 'Erro na rotina COBR0001.pc_gera_retorno_arq_cobranca. '||sqlerrm;

      pr_des_reto := 'NOK';
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cod_erro
                           ,pr_dscritic => vr_dsc_erro
                           ,pr_tab_erro => pr_tab_erro);


  END pc_gera_retorno_arq_cobranca;

  /* Gerar os arquivos de retorno do arquivo de cobrança */
  PROCEDURE pc_gera_ret_arq_cobranca_car(pr_cdcooper IN crapcop.cdcooper%TYPE        -- Codigo da cooperativa                                            
                                        ,pr_nrdconta IN crapass.nrdconta%type        -- Numero da conta
                                        ,pr_dtpgtini IN DATE                         -- data inicial do pagamento
                                        ,pr_dtpgtfim IN DATE                         -- Data final do pagamento
                                        ,pr_nrcnvcob IN INTEGER                      -- Numero do convenio de cobrança
                                        ,pr_cdagenci IN INTEGER                      -- Codigo da agencia para erros
                                        ,pr_nrdcaixa IN INTEGER                      -- Codigo do caixa para erros
                                        ,pr_origem   IN INTEGER                      -- indicador de origem /* 1-AYLLOS/2-CAIXA/3-INTERNET */
                                        ,pr_cdprogra IN VARCHAR2                     -- Codigo do programa
                                        ,pr_nmdcampo OUT VARCHAR2                    --Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2                    --Saida OK/NOK
                                        ,pr_clob_ret OUT CLOB                        --Tabela arquivo cobranca
                                        ,pr_cdcritic OUT PLS_INTEGER                 --Codigo Erro
                                        ,pr_dscritic OUT VARCHAR2) IS                --Descricao Erro
  /*--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_ret_arq_cobranca_car           
  --  Sistema  : Procedimentos para arquivos de cobranca
  --  Sigla    : CRED
  --  Autor    : Adriano
  --  Data     : Outubro/2015.                Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Fazer a chamada da rotina pc_gera_retorno_arq_cobranca
  --
  -- Alteracoes: 
  --
  --
  ---------------------------------------------------------------------------------------------------------------*/

    ------------------------------- VARIAVEIS -------------------------------
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Tabelas de Memoria    
    vr_tab_arq_cobranca COBR0001.typ_tab_arq_cobranca;

    --Variáveis locais
    vr_des_reto VARCHAR2(20) := null;
    
    --temptable de erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
        
    --Variaveis de Indice
    vr_index VARCHAR2(100);
    
    --Variaveis de Excecoes                                 
    vr_exc_erro  EXCEPTION; 

    --------------------------- SUBROTINAS INTERNAS --------------------------

  BEGIN
    --Limpar tabela dados
    vr_tab_arq_cobranca.DELETE;
      
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= null;
    
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
      
    pc_gera_retorno_arq_cobranca(pr_cdcooper => pr_cdcooper -- Codigo da cooperativa
                                ,pr_crapdat  => rw_crapdat  -- registro com as data do sistema
                                ,pr_nrdconta => pr_nrdconta -- Numero da conta
                                ,pr_dtpgtini => pr_dtpgtini -- data inicial do pagamento
                                ,pr_dtpgtfim => pr_dtpgtfim -- Data final do pagamento
                                ,pr_nrcnvcob => pr_nrcnvcob -- Numero do convenio de cobrança
                                ,pr_cdagenci => pr_cdagenci -- Codigo da agencia para erros
                                ,pr_nrdcaixa => pr_nrdcaixa -- Codigo do caixa para erros
                                ,pr_origem   => pr_origem   -- indicador de origem /* 1-AYLLOS/2-CAIXA/3-INTERNET */
                                ,pr_cdprogra => pr_cdprogra -- Codigo do programa
                                ,pr_des_reto => vr_des_reto -- Descricao do retorno 'OK/NOK'
                                ,pr_tab_arq_cobranca=> vr_tab_arq_cobranca -- temptable com as linhas do arquivo de cobrança
                                ,pr_tab_erro => vr_tab_erro); -- tabela de erros
                              
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN
        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a COBR0001.pc_gera_retorno_arq_cobranca.';
      END IF;    
        
      --Levantar Excecao
      RAISE vr_exc_erro;
                           
    END IF; 
        
    --Montar CLOB
    IF vr_tab_arq_cobranca.COUNT > 0 THEN
        
      -- Criar documento XML
      dbms_lob.createtemporary(pr_clob_ret, TRUE); 
      dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);
        
      -- Insere o cabeçalho do XML 
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                             ,pr_texto_completo => vr_dstexto 
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
         
      --Buscar Primeiro beneficiario
      vr_index:= vr_tab_arq_cobranca.FIRST;

      --Percorrer todos os beneficiarios
      WHILE vr_index IS NOT NULL LOOP
          
        vr_string:= '<DADOS>'||
                       '<cdseqlin>'||TO_CHAR(vr_tab_arq_cobranca(vr_index).cdseqlin)|| '</cdseqlin>'|| 
                       '<dsdlinha>'||NVL(TO_CHAR(vr_tab_arq_cobranca(vr_index).dslinha),' ')|| '</dsdlinha>'|| 
                    '</DADOS>';                      
                                                     
        -- Escrever no XML
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => vr_string
                               ,pr_fecha_xml      => FALSE);   
                                                    
        --Proximo Registro
        vr_index:= vr_tab_arq_cobranca.NEXT(vr_index);
          
      END LOOP;  
        
      -- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                             ,pr_texto_completo => vr_dstexto 
                             ,pr_texto_novo     => '</root>' 
                             ,pr_fecha_xml      => TRUE);
                               
    END IF;
                                         
    --Retorno
    pr_des_erro:= 'OK';      

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
        
      --Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;        
          
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
        
      pr_cdcritic:= 0;
      -- Chamar rotina de gravação de erro
      pr_dscritic:= 'Erro na COBR0001.pc_gera_retorno_arq_cobranca_car --> '|| SQLERRM;

  END pc_gera_ret_arq_cobranca_car;                                     
                                     
  /* Gerar os arquivos de retorno da febraban */
  PROCEDURE pc_gera_arquivo_febraban ( pr_cdcooper IN crapcop.cdcooper%TYPE   -- Codigo da cooperativa
                                      ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype     -- registro com as data do sistema
                                      ,pr_crapcop  IN CRAPCOP%rowtype         -- Registro da cooperativa
                                      ,pr_cdagenci IN INTEGER                 -- Codigo da agencia para erros
                                      ,pr_nrdcaixa IN INTEGER                 -- Codigo do caixa para erros
                                      ,pr_origem   IN INTEGER                 -- indicador de origem /* 1-AYLLOS/2-CAIXA/3-INTERNET */
                                      ,pr_cdprogra IN VARCHAR2                -- Codigo do programa
                                      ,pr_tab_crawarq IN typ_tab_crawarq      -- registros a serem gerados no arquivo
                                      ,pr_des_reto OUT VARCHAR2               -- Descricao do retorno 'OK/NOK'
                                      ,pr_tab_arq_cobranca OUT COBR0001.typ_tab_arq_cobranca
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro) IS -- tabela de erros

  /*--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_arquivo_febraban           Antigo: b1wgen0010.p/p_gera_arquivo_febraban
  --  Sistema  : Procedimentos para arquivos de cobranca
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana (AMcom)
  --  Data     : Junho/2014.                Ultima atualizacao: 17/17/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimento para gerar os arquivos de retorno da febraban
  --
  -- Alteracoes: 20/06/2014 - Conversão Progres --> Oracle (Odirlei-AMcom)
  --
  --             17/12/2014 - Tratamento incorporação( SD 234123 Odirlei-AMcom)
  ---------------------------------------------------------------------------------------------------------------*/
    ------------------------------- CURSORES ---------------------------------

    ------------------------------- VARIAVEIS -------------------------------
    -- controle de criticas
    vr_exc_saida     EXCEPTION;
    vr_cod_erro      crapcri.cdcritic%TYPE;
    vr_dsc_erro      VARCHAR2(4000);

    -- Nome do arquivo
    vr_nmarqind   varchar2(100) := NULL;
    -- Variáveis para armazenar as informações em XML
    vr_des_xml    clob;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  varchar2(32600);
    -- diretorio de geracao do relatorio
    vr_nom_direto VARCHAR2(100);
    -- indice da temptable
    vr_idx        VARCHAR2(100);
    vr_idxarq     VARCHAR2(100);
    -- Controlar find-first
    vr_nrconven   NUMBER;
    vr_nrdconta   NUMBER;
    -- Descrição da linha do arquivo
    vr_dslinha    VARCHAR2(2000);
    -- valores calculados para exibir no arquivo
    vr_vlcredit   NUMBER(35,10) := 0;
    vr_vltarifa   NUMBER(35,10) := 0;
    -- String com o nosso numero
    vr_nossonro   VARCHAR2(100);
    vr_nossonr2   VARCHAR2(100);
    -- Numero de linha/registro no arquivo
    vr_qtregist   INTEGER := 0;
    -- descrição da hora do processp
    vr_dsdahora   VARCHAR2(20);

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    procedure pc_escreve_xml(pr_des_dados in varchar2,
                             pr_fecha_xml in boolean default false) is
    begin
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    end;

    -- Incluir linha na temptable de cobrança
    PROCEDURE pc_inclui_arq_cobranca(pr_dslinha VARCHAR2) IS
      vr_cdseqlin VARCHAR2(100);
    BEGIN
      -- definir indice
      vr_cdseqlin := LPAD(nvl(pr_tab_arq_cobranca.count,0) + 1,'10','0');
      --incluir na temptable
      pr_tab_arq_cobranca(vr_cdseqlin).cdseqlin := vr_cdseqlin;
      pr_tab_arq_cobranca(vr_cdseqlin).dslinha  := pr_dslinha;

    END pc_inclui_arq_cobranca;

  BEGIN

    -- iniciar valores
    vr_nrconven := -1;
    vr_nrdconta := -1;
    -- armazenar a hora para todos os arquivos ficarem com a mesma hora no cabecalho
    vr_dsdahora := to_char(sysdate, 'HH24MISS');

    -- Busca do diretório base da cooperativa para PDF
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => null);

    --ler registros de cobrança
    vr_idx := pr_tab_crawarq.first;
    WHILE vr_idx IS NOT NULL LOOP

      IF vr_nrconven <> pr_tab_crawarq(vr_idx).nrconven OR
         vr_nrdconta <> pr_tab_crawarq(vr_idx).nrdconta THEN

        vr_nrconven := pr_tab_crawarq(vr_idx).nrconven;
        vr_nrdconta := pr_tab_crawarq(vr_idx).nrdconta;

        /******** HEADER DO ARQUIVO ************/
        vr_dslinha :='00100000'  ||
                     '         ' ||
                     '2'         ||
                    gene0002.fn_mask(pr_crapcop.nrdocnpj, '99999999999999')         ||
                    gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrconven, '999999999')  ||
                    '           '                                                   ||
                    gene0002.fn_mask(pr_crapcop.cdagedbb, '999999')                 ||
                    gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdctabb
                                    ,'9999999999999')                               ||
                    ' '                                                             ||
                    rpad(pr_crapcop.nmrescop, 30,' ')                               ||
                    'BANCO DO BRASIL'                                               ||
                    lpad(' ',25,' ')                                                ||
                    '2'                                                             ||
                    to_char(sysdate,'DDMMRRRR')                                     ||-->143
                    vr_dsdahora                                                     ||-->152
                    '000001'                                                        ||
                    '00001'                                                         ||
                    lpad(' ',72,' ') ;

        pc_inclui_arq_cobranca(pr_dslinha => vr_dslinha);

        /******** HEADER DO LOTE ************/
        vr_dslinha := '00100011T01  030 2'||
                    gene0002.fn_mask(pr_crapcop.nrdocnpj, '999999999999999') ||
                    gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrconven
                                     ,'999999999')                        ||
                    '           '                                         ||
                    gene0002.fn_mask(pr_crapcop.cdagedbb, '999999')       ||
                    gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdctabb
                                    ,'9999999999999')                     ||
                    ' '                                                   ||
                    rpad(pr_crapcop.nmrescop,30,' ')                      ||
                    lpad(' ',80,' ')                                      ||
                    '00000001'                                            ||
                    to_char(sysdate,'DDMMRRRR')                           ||
                    to_char(sysdate,'DDMMRRRR')                           ||
                    lpad(' ',33,' ');

        pc_inclui_arq_cobranca(pr_dslinha => vr_dslinha);

      END IF;

      vr_qtregist := nvl(vr_qtregist,0) + 1;

      -- Calcular valore de credito e de tarifa conforme indicador de pagamento
      IF pr_tab_crawarq(vr_idx).indpagto = 1 THEN    /** caixa **/
        vr_vlcredit := ((pr_tab_crawarq(vr_idx).vldpagto * 100) -
                        (pr_tab_crawarq(vr_idx).vlrtarcx * 100));
        vr_vltarifa := pr_tab_crawarq(vr_idx).vlrtarcx * 100;
      ELSIF pr_tab_crawarq(vr_idx).indpagto = 3 THEN   /** internet **/
        vr_vlcredit := ((pr_tab_crawarq(vr_idx).vldpagto * 100) -
                        (pr_tab_crawarq(vr_idx).vlrtarnt * 100));
        vr_vltarifa := pr_tab_crawarq(vr_idx).vlrtarnt * 100;
      ELSIF pr_tab_crawarq(vr_idx).indpagto = 4 THEN   /** TAA **/
        vr_vlcredit := ((pr_tab_crawarq(vr_idx).vldpagto * 100) -
                        (pr_tab_crawarq(vr_idx).vltrftaa * 100));
        vr_vltarifa := pr_tab_crawarq(vr_idx).vltrftaa * 100;
      END IF;

      -- Definir nosso nunmero
      IF pr_tab_crawarq(vr_idx).dsorgarq in ('IMPRESSO PELO SOFTWARE',
                                             'MIGRACAO',
                                             'INCORPORACAO',
                                             'INTERNET') THEN
        IF pr_tab_crawarq(vr_idx).flgutceb = 1 THEN
          -- cadastro de emissao de bloquetos
          OPEN cr_crapceb( pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_tab_crawarq(vr_idx).nrdconta
                          ,pr_nrconven => pr_tab_crawarq(vr_idx).nrconven);
          FETCH cr_crapceb INTO rw_crapceb;

          -- se existir dados, ajusta o nosso numero
          IF cr_crapceb%NOTFOUND THEN
            close cr_crapceb;
            --definir critica
            vr_cod_erro := 563;
            vr_dsc_erro := NULL;
            --abortar
            raise vr_exc_saida;
          ELSE
            close cr_crapceb;
          END IF;

          -- montar string nosso numero
          IF LENGTH(TRIM(gene0002.fn_mask(rw_crapceb.nrcnvceb,'zzzz9'))) <= 4 THEN
            vr_nossonro := gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrconven,'9999999') ||
                           gene0002.fn_mask(rw_crapceb.nrcnvceb,'9999')                   ||
                           gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdocmto,'999999');
          ELSE
            vr_nossonro := gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrconven,'9999999')           ||
                           gene0002.fn_mask(SUBSTR(TRIM(gene0002.fn_mask( rw_crapceb.nrcnvceb
                                                                        ,'zzzz9')),1,4),'9999') ||
                           gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdocmto,'999999');
          END IF;
        ELSE
          vr_nossonro := gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdconta,'99999999') ||
                         gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdocmto,'999999999');
        END IF; -- Fim IF flgutceb

      ELSE
        IF pr_tab_crawarq(vr_idx).tamannro = 12 THEN
          vr_nossonro := gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrconven,'999999') ||
                         gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdocmto,'999999');
        ELSE
          vr_nossonro := gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrconven,'9999999') ||
                         gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdocmto,'9999999999');
        END IF;
      END IF; -- Fim IF dsorgarq

      vr_nossonr2 := '21'||lpad(' ',23 - LENGTH(vr_nossonro),' ') || vr_nossonro;

      IF vr_vlcredit < 0 THEN
        vr_vlcredit := 0;
      END IF;

      vr_dslinha := '00100013'                                          ||
                    gene0002.fn_mask(vr_qtregist, '99999')              ||
                    'T 06'                                              ||
                    gene0002.fn_mask(pr_crapcop.cdagedbb, '999999')     ||
                    gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdctabb, '9999999999999') ||
                    ' '                                                 ||
                    RPAD(vr_nossonro, 20,' ')                          ||
                    '1'                                                 ||
                    LPAD(' ',15,' ')                                    ||
                    '00000000'                                          ||
                    gene0002.fn_mask((pr_tab_crawarq(vr_idx).vldpagto * 100), '999999999999999') ||
                    '001'                                               ||
                    gene0002.fn_mask(pr_crapcop.cdagedbb, '999999')        ||
                    RPAD(vr_nossonr2,25,' ')                           ||
                    '09'                                                ||
                    LPAD(0,66,'0')                                      ||
                    gene0002.fn_mask(vr_vltarifa, '999999999999999')    ||
                    '00        '                                        ||
                    LPAD('0',17,'0');

      pc_inclui_arq_cobranca(pr_dslinha => vr_dslinha);

      -- incrementar contador
      vr_qtregist := vr_qtregist + 1;

      vr_dslinha := '00100013'                             ||
                    gene0002.fn_mask(vr_qtregist, '99999') ||
                    'U 06'                                 ||
                    LPAD('0',60,0)                         ||
                    gene0002.fn_mask((pr_tab_crawarq(vr_idx).vldpagto * 100)
                                     ,'999999999999999')   ||
                    gene0002.fn_mask(vr_vlcredit, '999999999999999')      ||
                    LPAD('0',30,'0')                                          ||
                    to_char(pr_tab_crawarq(vr_idx).dtdpagto, 'DDMMRRRR')  ||
                    to_char(pr_tab_crawarq(vr_idx).dtcredit, 'DDMMRRRR')  ||
                    LPAD(' ',12,' ')                       ||
                    LPAD('0',15,'0')                       ||
                    LPAD(' ',30,' ')                       ||
                    '000'                                  ||
                    LPAD(' ',27,' ');

      pc_inclui_arq_cobranca(pr_dslinha => vr_dslinha);

      -- verificar se é o ultimo ou o convenio ou a conta irão mudar (Last-of)
      IF pr_tab_crawarq.NEXT(vr_idx) IS NULL OR
         (vr_nrconven <> pr_tab_crawarq(pr_tab_crawarq.NEXT(vr_idx)).nrconven OR
          vr_nrdconta <> pr_tab_crawarq(pr_tab_crawarq.NEXT(vr_idx)).nrdconta) THEN

        /******** TRAILER DO LOTE ************/
        vr_dslinha := '00100015'                                  ||
                      '         '                                 ||
                      gene0002.fn_mask(vr_qtregist + 2, '999999') ||
                      LPAD('0',123,'0')                           ||
                      LPAD(' ',094,' ');
        pc_inclui_arq_cobranca(pr_dslinha => vr_dslinha);

        /******** TRAILER DO ARQUIVO ************/
        vr_dslinha := '00199999'                                  ||
                      '         '                                 ||
                      '000001'                                    ||
                      gene0002.fn_mask(vr_qtregist + 4, '999999') ||
                      '000000'                                    ||
                      LPAD(' ',156,' ')                           ||
                      LPAD('0',029,'0')                           ||
                      LPAD(' ',020,' ');

        pc_inclui_arq_cobranca(pr_dslinha => vr_dslinha);

        /* Quando rotina chamada do Ayllos, deve-se enviar o arquivo
           de retorno de cobranca via e-mail */
        IF pr_origem <> 3 THEN
          -- Definir nome do arquivo
          IF pr_origem = 2 THEN
            vr_nmarqind := 'RET-caixa-';
          ELSE
            vr_nmarqind := 'RET-compe-';
          END IF;
          vr_nmarqind := vr_nmarqind ||
                         gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrconven,'99999999')|| '-' ||
                         gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdconta,'99999999')|| '-' ||
                         to_char(SYSDATE, 'DDMMRRRR');
          vr_qtregist := 0;

          -- Inicializar o CLOB
          vr_des_xml := null;
          dbms_lob.createtemporary(vr_des_xml, true);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
          -- Inicilizar as informações do XML
          vr_texto_completo := null;

          -- verificar se existe informações para colocar no arquivo
          IF pr_tab_arq_cobranca.COUNT > 0 THEN
            -- varrer as linhas para incluir no arquivo
            vr_idxarq := pr_tab_arq_cobranca.first;
            WHILE vr_idxarq IS NOT NULL LOOP
              pc_escreve_xml(substr(pr_tab_arq_cobranca(vr_idxarq).dslinha,1,240)||CHR(10));
              vr_idxarq := pr_tab_arq_cobranca.next(vr_idxarq);
            END LOOP;
            -- descarregar buffer
            pc_escreve_xml(NULL,TRUE);
          END IF;

          /* Solicitar geração do arquico */
          gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper,            --> Cooperativa conectada
                                              pr_cdprogra  => pr_cdprogra,            --> Programa chamador
                                              pr_dtmvtolt  => pr_crapdat.dtmvtolt,    --> Data do movimento atual
                                              pr_dsxml     => vr_des_xml,             --> Arquivo XML de dados
                                              pr_dsarqsaid => vr_nom_direto||'/arq/'||vr_nmarqind,   --> Path/Nome do arquivo PDF gerado
                                              pr_flg_gerar => 'N',                    --> Gerar o arquivo na hora
                                              pr_dspathcop => vr_nom_direto||'/salvar/',  --> Lista sep. por ';' de diretórios a copiar o arquivo
                                              pr_fldoscop  => 'S',                    --> Flag para converter o arquivo gerado em DOS antes da cópia
                                              pr_dsmailcop => pr_tab_crawarq(vr_idx).dsdemail,   --> Lista sep. por ';' de emails para envio do arquivo
                                              pr_dsassmail => 'ARQUIVO DE COBRANCA DA '||pr_crapcop.nmrescop,   --> Assunto do e-mail que enviará o arquivo
                                              pr_fldosmail => 'S',                    --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                              pr_flgremarq => 'S',                    --> Flag para remover o arquivo após cópia/email
                                              pr_des_erro  => vr_dsc_erro);           --> Saída com erro

          /* Limpar registros enviados */
          pr_tab_arq_cobranca.delete;

          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_des_xml);
          dbms_lob.freetemporary(vr_des_xml);

        END IF; -- Fim IF pr_origem <> 3

      END IF; -- Fim Last-Of

      -- buscar o proximo registro
      vr_idx := pr_tab_crawarq.next(vr_idx);
    END LOOP;

  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_des_reto := 'NOK';
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cod_erro
                           ,pr_dscritic => vr_dsc_erro
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- Retornando a critica para o programa chamdador
      vr_cod_erro := 0;
      vr_dsc_erro := 'Erro na rotina COBR0001.pc_gera_arquivo_febraban. '||sqlerrm;

      pr_des_reto := 'NOK';
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cod_erro
                           ,pr_dscritic => vr_dsc_erro
                           ,pr_tab_erro => pr_tab_erro);
  END pc_gera_arquivo_febraban;

  /* Gerar os arquivos de retorno de cobrança outros */
  PROCEDURE pc_gera_arquivo_outros ( pr_cdcooper IN crapcop.cdcooper%TYPE   -- Codigo da cooperativa
                                    ,pr_crapdat  IN BTCH0001.cr_crapdat%rowtype     -- registro com as data do sistema
                                    ,pr_crapcop  IN CRAPCOP%rowtype         -- Registro da cooperativa
                                    ,pr_cdagenci IN INTEGER                 -- Codigo da agencia para erros
                                    ,pr_nrdcaixa IN INTEGER                 -- Codigo do caixa para erros
                                    ,pr_origem   IN INTEGER                 -- indicador de origem /* 1-AYLLOS/2-CAIXA/3-INTERNET */
                                    ,pr_cdprogra IN VARCHAR2                -- Codigo do programa
                                    ,pr_tab_crawarq IN typ_tab_crawarq      -- registros a serem gerados no arquivo
                                    ,pr_des_reto OUT VARCHAR2               -- Descricao do retorno 'OK/NOK'
                                    ,pr_tab_arq_cobranca OUT COBR0001.typ_tab_arq_cobranca
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro) IS -- tabela de erros

  /*--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_arquivo_outros           Antigo: b1wgen0010.p/p_gera_arquivo_outros
  --  Sistema  : Procedimentos para arquivos de cobranca
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana (AMcom)
  --  Data     : Junho/2014.                      Ultima atualizacao: 17/12/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimento para gerar os arquivos de retorno de cobrança outros
  --
  -- Alteracoes: 23/06/2014 - Conversão Progres --> Oracle (Odirlei-AMcom)
  --
  --             17/12/2014 - Tratamento incorporação( SD 234123 Odirlei-AMcom)
  --
  --             22/12/2014 - Ajuste da variável de indice, devido a erro no processo
  --                          batch. ( Renato - Supero )
  ---------------------------------------------------------------------------------------------------------------*/
    ------------------------------- CURSORES ---------------------------------

    ------------------------------- VARIAVEIS -------------------------------
    -- controle de criticas
    vr_exc_saida     EXCEPTION;
    vr_cod_erro      crapcri.cdcritic%TYPE;
    vr_dsc_erro      VARCHAR2(4000);

    -- Nome do arquivo
    vr_nmarqind   varchar2(100) := NULL;
    -- Variáveis para armazenar as informações em XML
    vr_des_xml    clob;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  varchar2(32600);
    -- diretorio de geracao do relatorio
    vr_nom_direto VARCHAR2(100);
    -- indice da temptable
    vr_idx        VARCHAR2(100);
    vr_idcob      VARCHAR2(100);
    -- Controlar find-first
    vr_nrdconta   NUMBER;
    -- Descrição da linha do arquivo
    vr_dslinha    VARCHAR2(2000);
    -- String com o nosso numero
    vr_nossonro   VARCHAR2(100);
    -- Numero de linha/registro no arquivo
    vr_qtregist   INTEGER := 0;
    -- Valor acumulado
    vr_vlacumul   NUMBER;

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    procedure pc_escreve_xml(pr_des_dados in varchar2,
                             pr_fecha_xml in boolean default false) is
    begin
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    end;

    -- Incluir linha na temptable de cobrança
    PROCEDURE pc_inclui_arq_cobranca(pr_dslinha VARCHAR2) IS
      vr_cdseqlin VARCHAR2(100);
    BEGIN
      -- definir indice
      vr_cdseqlin := LPAD(nvl(pr_tab_arq_cobranca.count,0) + 1,'10','0');
      --incluir na temptable
      pr_tab_arq_cobranca(vr_cdseqlin).cdseqlin := vr_cdseqlin;
      pr_tab_arq_cobranca(vr_cdseqlin).dslinha  := pr_dslinha;

    END pc_inclui_arq_cobranca;

  BEGIN

    -- iniciar valores
    vr_nrdconta := -1;

    -- Busca do diretório base da cooperativa para PDF
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => null);

    --ler registros de cobrança
    vr_idx := pr_tab_crawarq.first;
    WHILE vr_idx IS NOT NULL LOOP

      IF vr_nrdconta <> pr_tab_crawarq(vr_idx).nrdconta THEN

        vr_nrdconta := pr_tab_crawarq(vr_idx).nrdconta;

        /******** HEADER DO ARQUIVO ************/
        vr_dslinha := '00000000000000000000000000000000000000000000000'||
                      'IED241'                    ||         /* Nome arquivo       */
                      '001'                       ||         /* Comp. Origem - 1   */
                      '0001'                      ||         /* Nro Versao - 1     */
                      '001'                       ||         /* Banco Destinatario */
                      '0'                         ||         /* Digito Verif. Banco*/
                      '3'                         ||         /* 3 - Remessa        */
                      to_char(sysdate,'RRRRMMDD') ||
                      lpad(' ',77,' ')            ||
                      gene0002.fn_mask(vr_qtregist, '9999999999');

        pc_inclui_arq_cobranca(pr_dslinha => vr_dslinha);

      END IF;
      --somar valor acumulado
      vr_vlacumul := nvl(vr_vlacumul,0) + (nvl(pr_tab_crawarq(vr_idx).vldpagto,0) * 100);
      vr_qtregist := nvl(vr_qtregist,0) + 1;

      -- Definir nosso nunmero
      IF pr_tab_crawarq(vr_idx).dsorgarq in ('IMPRESSO PELO SOFTWARE',
                                             'INTERNET',
                                             'MIGRACAO','INCORPORACAO') THEN
        IF pr_tab_crawarq(vr_idx).flgutceb = 1 THEN
          -- cadastro de emissao de bloquetos
          OPEN cr_crapceb( pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_tab_crawarq(vr_idx).nrdconta
                          ,pr_nrconven => pr_tab_crawarq(vr_idx).nrconven);
          FETCH cr_crapceb INTO rw_crapceb;

          -- se existir dados, ajusta o nosso numero
          IF cr_crapceb%NOTFOUND THEN
            close cr_crapceb;
            --definir critica
            vr_cod_erro := 563;
            vr_dsc_erro := NULL;
            --abortar
            raise vr_exc_saida;
          ELSE
            close cr_crapceb;
          END IF;

          -- montar string nosso numero
          IF LENGTH(TRIM(gene0002.fn_mask(rw_crapceb.nrcnvceb,'zzzz9'))) <= 4 THEN
            vr_nossonro := gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrconven,'9999999') ||
                           gene0002.fn_mask(rw_crapceb.nrcnvceb,'9999')                   ||
                           gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdocmto,'999999');
          ELSE
            vr_nossonro := gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrconven,'9999999')           ||
                           gene0002.fn_mask(SUBSTR(TRIM(gene0002.fn_mask( rw_crapceb.nrcnvceb
                                                                        ,'zzzz9')),1,4),'9999') ||
                           gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdocmto,'999999');
          END IF;
        ELSE
          vr_nossonro := gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdconta,'99999999') ||
                         gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdocmto,'999999999');
        END IF; -- Fim IF flgutceb

      ELSE
        IF pr_tab_crawarq(vr_idx).tamannro = 12 THEN
          vr_nossonro := gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrconven,'999999') ||
                         gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdocmto,'999999');
        ELSE
          vr_nossonro := gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrconven,'9999999') ||
                         gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdocmto,'9999999999');
        END IF;
      END IF; -- Fim IF dsorgarq


      vr_dslinha := '001'                     ||   /* Codigo do Banco       */
                    '9'                       ||   /* Codigo da Moeda       */
                    '000000000000000'         ||
                    '1'                       ||   /* Codigo da Carteira    */
                    '0001'                    ||   /* Codigo da Cooperativa */
                    RPAD(vr_nossonro, 20,' ') ||
                    '016 '                    ||   /* Compe.Origem          */
                    '99 '                     ||   /* Constante igual a 99  */
                    '001'                     ||   /* Codigo do Banco       */
                    '001'                     ||   /* Codigo da Agencia     */
                    '0000001'                 ||   /* Codigo do Lote        */
                    gene0002.fn_mask(vr_qtregist, '999')   ||
                    to_char(pr_tab_crawarq(vr_idx).dtdpagto, 'RRRRMMDD')  ||
                    LPAD(' ',06,' ')                       ||
                    gene0002.fn_mask((pr_tab_crawarq(vr_idx).vldpagto * 100)
                                     ,'999999999999')      ||
                    LPAD(' ',57,' ')                       ||
                    gene0002.fn_mask(vr_qtregist, '9999999999');

      pc_inclui_arq_cobranca(pr_dslinha => vr_dslinha);

      -- verificar se é o ultimo ou o convenio ou a conta irão mudar (Last-of)
      IF pr_tab_crawarq.NEXT(vr_idx) IS NULL OR
         (vr_nrdconta <> pr_tab_crawarq(pr_tab_crawarq.NEXT(vr_idx)).nrdconta) THEN

        vr_qtregist := nvl(vr_qtregist,0) + 1;

        /******** TRAILER DO ARQUIVO ************/
        vr_dslinha := '99999999999999999999999999999999999999999999999' ||
                      'IED241'                        ||  /* Nome arquivo     */
                      '001'                           ||  /* Comp. Origem - 1 */
                      '0001'                          ||  /* Nro Versao - 1   */
                      '001'                           ||  /* Banco Destinatario */
                      '0'                             ||  /* Digito Banco     */
                      '3'                             ||  /* 3 - Remessa      */
                      to_char(sysdate,'RRRRMMDD')     ||
                      gene0002.fn_mask(vr_vlacumul,'99999999999999999')      ||
                      LPAD(' ',60,' ')                ||
                      gene0002.fn_mask(vr_qtregist, '9999999999') ;

        pc_inclui_arq_cobranca(pr_dslinha => vr_dslinha);


        /* Quando rotina chamada do Ayllos, deve-se enviar o arquivo
           de retorno de cobranca via e-mail */
        IF pr_origem <> 3 THEN
          -- Definir nome do arquivo
          IF pr_origem = 2 THEN
            vr_nmarqind := 'cb'||
                           gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdconta,'99999999')||
                           to_char(SYSDATE, 'DDMM')||'-caixa.cob';
          ELSE
            vr_nmarqind := 'cb'||
                           gene0002.fn_mask(pr_tab_crawarq(vr_idx).nrdconta,'99999999')||
                           to_char(SYSDATE, 'DDMM')||'-compe.cob';
          END IF;

          vr_qtregist := 1;
          vr_vlacumul := 0;

          -- Inicializar o CLOB
          vr_des_xml := null;
          dbms_lob.createtemporary(vr_des_xml, true);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
          -- Inicilizar as informações do XML
          vr_texto_completo := null;

          -- verificar se existe informações para colocar no arquivo
          IF pr_tab_arq_cobranca.COUNT > 0 THEN
            -- varrer as linhas para incluir no arquivo
            vr_idcob := pr_tab_arq_cobranca.first;
            WHILE vr_idcob IS NOT NULL LOOP
              pc_escreve_xml(substr(pr_tab_arq_cobranca(vr_idcob).dslinha,1,160)||CHR(10));
              vr_idcob := pr_tab_arq_cobranca.next(vr_idcob);
            END LOOP;
            
            
            -- descarregar buffer
            pc_escreve_xml(NULL,TRUE);
          END IF;

          /* Solicitar geração do arquico */
          gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper,            --> Cooperativa conectada
                                              pr_cdprogra  => pr_cdprogra,            --> Programa chamador
                                              pr_dtmvtolt  => pr_crapdat.dtmvtolt,    --> Data do movimento atual
                                              pr_dsxml     => vr_des_xml,             --> Arquivo XML de dados
                                              pr_dsarqsaid => vr_nom_direto||'/arq/'||vr_nmarqind,   --> Path/Nome do arquivo PDF gerado
                                              pr_flg_gerar => 'N',                    --> Gerar o arquivo na hora
                                              pr_dspathcop => vr_nom_direto||'/salvar/',  --> Lista sep. por ';' de diretórios a copiar o arquivo
                                              pr_fldoscop  => 'S',                    --> Flag para converter o arquivo gerado em DOS antes da cópia
                                              pr_dsmailcop => pr_tab_crawarq(vr_idx).dsdemail,   --> Lista sep. por ';' de emails para envio do arquivo
                                              pr_dsassmail => 'ARQUIVO DE COBRANCA DA '||pr_crapcop.nmrescop,   --> Assunto do e-mail que enviará o arquivo
                                              pr_fldosmail => 'S',                    --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                              pr_flgremarq => 'S',                    --> Flag para remover o arquivo após cópia/email
                                              pr_des_erro  => vr_dsc_erro);           --> Saída com erro

          /* Limpar registros enviados */
          pr_tab_arq_cobranca.delete;

          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_des_xml);
          dbms_lob.freetemporary(vr_des_xml);

        END IF; -- Fim IF pr_origem <> 3

      END IF; -- Fim Last-Of

      -- buscar o proximo registro
      vr_idx := pr_tab_crawarq.next(vr_idx);
    END LOOP;

  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_des_reto := 'NOK';
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cod_erro
                           ,pr_dscritic => vr_dsc_erro
                           ,pr_tab_erro => pr_tab_erro);
    WHEN OTHERS THEN
      -- Retornando a critica para o programa chamdador
      vr_cod_erro := 0;
      vr_dsc_erro := 'Erro na rotina COBR0001.pc_gera_arquivo_outros. '||sqlerrm;

      pr_des_reto := 'NOK';
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cod_erro
                           ,pr_dscritic => vr_dsc_erro
                           ,pr_tab_erro => pr_tab_erro);
  END pc_gera_arquivo_outros;


  PROCEDURE  pc_carrega_parcelas_carne(pr_cdcooper    IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                      ,pr_nrdconta    IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                      ,pr_dsboleto    IN VARCHAR2               -- Numero do Convenio
                                      ,pr_tab_boleto OUT CLOB                   -- XML da tabela de titulos
                                      ,pr_cdcritic   OUT INTEGER                -- Código do erro
                                      ,pr_dscritic   OUT VARCHAR2) IS           -- Descricao do erro

  BEGIN
    /* .............................................................................
    Programa : COBR0001
    Sistema  : Rotina para buscar as parcelas que pertencem a um carnê, de acordo com a parcela selecionada
    Sigla    : COBR
    Autor    : Douglas Quisinski - CECRED
    Data     : Junho/2015.                      Ultima atualizacao: 16/08/2018

    Dados referentes ao programa:
    
    Frequencia: Sempre que Chamado
    Objetivo  : Rotina para buscar as parcelas que pertencem a um carnê, de acordo com a parcela selecionada

    Alteracoes: 08/07/2015 - Alterar o tipo das variaveis do xml para CLOB (Douglas - Chamado 303663)

			    03/10/2016 - Ajustes referente a melhoria M271. (Kelvin)
                
                29/09/2017 - Ajustar o campo flgdprot e adicionar os campos de Serasa
                             (Douglas - Chamado 754911)

				09/02/2018 - Adicionado novas tags referente ao PRJ285 - Novo IB (Rafael)
                
                02/08/2018 - Utilizar a procedure COBR0009.pc_busca_nome_imp_blt para retornar
                             o nome que deve ser impresso no carnê. Mesma regra utilizada no boleto
                             (Douglas - PRJ285 Nova Conta Online)
                            
                16/08/2018 - Retirado mensagem de serviço de protesto pelo BB (PRJ352 - Rafael).        
    ............................................................................. */
    DECLARE
      -- Variáveis para identificar os boletos
      vr_nrinssac crapcob.nrinssac%TYPE;
      vr_nrdocmto crapcob.nrdocmto%TYPE;
      vr_dsdoccop crapcob.dsdoccop%TYPE;
      vr_nrconven crapcco.nrconven%TYPE;

      -- Email do pagador
      vr_dsdemail    VARCHAR2(5000);

      -- Nome do Beneficiario para imprimir no boleto
      vr_nmbenefi    VARCHAR2(150);
      vr_des_erro_benef VARCHAR2(3);

      vr_xml_tab_temp VARCHAR2(32767) := '';

      -- Variaveis de Exception
      vr_exc_erro EXCEPTION;
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_des_erro VARCHAR2(1000);

      vr_ret_all_boletos gene0002.typ_split;
      vr_ret_boleto      gene0002.typ_split;
      
      vr_auxcont     INTEGER := 0;
      vr_parcela_ant INTEGER;
      vr_parcela_atu INTEGER;
      vr_dscodbar    VARCHAR2(50);
      vr_lindigit    VARCHAR2(100);
      vr_dsdespec    VARCHAR2(10);
      vr_nrborder    craptdb.nrborder%TYPE;
      vr_dsdinst1    VARCHAR2(200);
      vr_dsdinst2    VARCHAR2(200);      
      vr_dsdinst3    VARCHAR2(200);      
      vr_dsdinst4    VARCHAR2(200);      
      vr_dsdinst5    VARCHAR2(200);      
    
      vr_fim_parcelas EXCEPTION;
      vr_next EXCEPTION;
      
      -- CURSORES
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.cdagectl
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%TYPE
                        ,pr_nrdconta IN craptdb.nrdconta%TYPE
                        ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE
                        ,pr_nrdocmto IN craptdb.nrdocmto%TYPE) IS
         SELECT nrborder 
           FROM craptdb tdb, crapcco cco
          WHERE tdb.cdcooper = pr_cdcooper
            AND tdb.nrdconta = pr_nrdconta
            AND tdb.nrcnvcob = pr_nrcnvcob
            AND tdb.nrdocmto = pr_nrdocmto
            AND cco.cdcooper = pr_cdcooper
            AND cco.nrconven = pr_nrcnvcob
            AND tdb.nrdctabb = cco.nrdctabb
            AND tdb.cdbandoc = cco.cddbanco
            AND tdb.insittit = 4;
      
      rw_craptdb cr_craptdb%ROWTYPE;
            
      CURSOR cr_verifica_carne(pr_cdcooper IN crapcop.cdcooper%TYPE
                              ,pr_nrdconta IN crapass.nrdconta%TYPE
                              ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
                              ,pr_nrinssac IN crapcob.nrinssac%TYPE
                              ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE) IS
        SELECT cob.* 
        FROM crapcob cob, crapcol col
        WHERE col.cdcooper = cob.cdcooper
          AND col.nrdconta = cob.nrdconta
          AND col.nrdocmto = cob.nrdocmto
          AND cob.cdcooper = pr_cdcooper
          AND cob.nrdconta = pr_nrdconta
          AND cob.nrinssac = pr_nrinssac
          AND cob.nrdocmto = pr_nrdocmto
          AND cob.nrcnvcob = pr_nrcnvcob
          AND cob.incobran = 0
          AND upper(col.dslogtit) LIKE upper('%carne%');
      rw_verifica_carne cr_verifica_carne%ROWTYPE;

      CURSOR cr_primeira_parcela(pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_nrinssac IN crapcob.nrinssac%TYPE
                                ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
                                ,pr_dsdoccop IN crapcob.dsdoccop%TYPE
                                ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE) IS
        SELECT cob.* 
        FROM crapcob cob, crapcol col
        WHERE col.cdcooper = cob.cdcooper
          AND col.nrdconta = cob.nrdconta
          AND col.nrdocmto = cob.nrdocmto
          AND cob.cdcooper = pr_cdcooper
          AND cob.nrdconta = pr_nrdconta
          AND cob.nrinssac = pr_nrinssac
          AND cob.nrdocmto <= pr_nrdocmto
          AND cob.nrcnvcob = pr_nrcnvcob
          AND upper(cob.dsdoccop) LIKE upper(pr_dsdoccop)
        ORDER BY cob.nrdocmto DESC;
      rw_primeira_parcela cr_primeira_parcela%ROWTYPE;

      CURSOR cr_all_parcelas(pr_cdcooper IN crapcob.cdcooper%TYPE
                            ,pr_nrdconta IN crapcob.nrdconta%TYPE
                            ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                            ,pr_nrinssac IN crapcob.nrinssac%TYPE
                            ,pr_tpdmulta IN crapcob.tpdmulta%TYPE
                            ,pr_tpjurmor IN crapcob.tpjurmor%TYPE
                            ,pr_dsdoccop IN crapcob.dsdoccop%TYPE
                            ,pr_nrdocmto_min IN INTEGER
                            ,pr_nrdocmto_max IN INTEGER) IS
        SELECT 
          cob.cdcooper,
          cob.nrnosnum,
          cob.nmdsacad,
          cob.nrinssac,
          cob.dsendsac,
          cob.nmbaisac,
          cob.nmcidsac,
          cob.cdufsaca,
          cob.nrcepsac,
          cob.nmdavali,
          cob.nrdctabb,
          cob.nrdocmto,
          cob.dtmvtolt,
          cob.dsdinstr,
          cob.dsdoccop,
          cob.dtvencto,
          cob.dtdpagto,
          cob.vltitulo,
          cob.vldpagto,
          cob.cdtpinsc,
          cob.vldescto,
          cob.cdmensag,
          cob.dsinform,
          cob.vlabatim,
          cob.cddespec,
          cob.dtdocmto,
          cob.cdbanpag,
          cob.cdagepag,
          cob.dtelimin,
          cob.cdcartei,
          cob.cdbandoc,
          cob.flgregis,
          DECODE(cob.flgaceit, 1, 'S','N') flgaceit,
          cob.tpjurmor,
          cob.vljurdia,
          cob.tpdmulta,
          cob.vlrmulta,
          DECODE(cob.flgdprot, 1, 'S','N') flgdprot,
          cob.qtdiaprt,
          cob.indiaprt,
          cob.insitpro,
          cob.cdtpinav,
          cob.nrinsava,
          cob.incobran,
          DECODE(cob.flserasa, 1, 'S','N') flserasa,
          cob.qtdianeg,
          cob.inserasa,
          ass.nrcpfcgc,
          ass.inpessoa,
          ass.nmprimtl,
          cob.flgcbdda,
          cob.dtvctori,
          cob.nrcnvcob,
          cob.nrdconta,
          cob.nrctremp
        FROM crapcob cob, crapass ass
        WHERE ass.cdcooper = cob.cdcooper
          AND ass.nrdconta = cob.nrdconta
          AND cob.cdcooper = pr_cdcooper
          AND cob.nrdconta = pr_nrdconta
          AND cob.nrinssac = pr_nrinssac
          AND cob.tpdmulta = pr_tpdmulta
          AND cob.tpjurmor = pr_tpjurmor
          AND cob.nrdocmto BETWEEN pr_nrdocmto_min AND pr_nrdocmto_max
          AND cob.dsdoccop LIKE (pr_dsdoccop || '%')
          AND cob.nrcnvcob = pr_nrcnvcob
          AND cob.incobran = 0
        ORDER BY cob.nrdocmto ASC;

      rw_crapcob cr_all_parcelas%ROWTYPE;

      CURSOR cr_crapsab(pr_cdcooper IN crapsab.cdcooper%TYPE
                       ,pr_nrdconta IN crapsab.nrdconta%TYPE
                       ,pr_nrinssac IN crapsab.nrinssac%TYPE) IS
        SELECT sab.* 
        FROM crapsab sab
        WHERE sab.cdcooper = pr_cdcooper
          AND sab.nrdconta = pr_nrdconta
          AND sab.nrinssac = pr_nrinssac;
      rw_crapsab cr_crapsab%ROWTYPE;

      CURSOR cr_crapcco(pr_cdcooper IN crapcco.cdcooper%TYPE
                       ,pr_nrconven IN crapcco.nrconven%TYPE) IS
        SELECT cco.* 
        FROM crapcco cco
        WHERE cco.cdcooper = pr_cdcooper
          AND cco.nrconven = pr_nrconven;
      rw_crapcco cr_crapcco%ROWTYPE;
      
      CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                       ,pr_nrdconta IN crapceb.nrdconta%TYPE
                       ,pr_nrconven IN crapceb.nrconven%TYPE) IS
        SELECT ceb.* 
        FROM crapceb ceb
        WHERE ceb.cdcooper = pr_cdcooper
          AND ceb.nrdconta = pr_nrdconta
          AND ceb.nrconven = pr_nrconven;
      rw_crapceb cr_crapceb%ROWTYPE;

      TYPE typ_reg_nrdocmto IS
        RECORD(nrdocmto crapcob.nrdocmto%TYPE);
      TYPE typ_nrdocmto IS
        TABLE OF typ_reg_nrdocmto
        INDEX BY BINARY_INTEGER;
      /* Vetor para armazenar as informac?es de erro */
      vr_tab_nrdocmto typ_nrdocmto;
      
    BEGIN

      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- volta para o programa chamador
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);      
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;      

      -- Criando um Array com todos os boletos que estão tentando imprimir
      vr_ret_all_boletos := gene0002.fn_quebra_string(pr_dsboleto, ';');
      
      -- Inicia a montagem do XML
      BEGIN
        -- Monta documento XML do Perfil Informado.
        dbms_lob.createtemporary(pr_tab_boleto, TRUE);
        dbms_lob.open(pr_tab_boleto, dbms_lob.lob_readwrite);
        -- Insere o cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_tab_boleto
                               ,pr_texto_completo => vr_xml_tab_temp
                               ,pr_texto_novo     => '<dados>');
      
        -- Percorre todos os cheques para processá-los
        FOR vr_auxcont IN 1..vr_ret_all_boletos.count LOOP
          
          vr_ret_boleto := gene0002.fn_quebra_string(vr_ret_all_boletos(vr_auxcont), '|');  
          vr_nrdocmto := to_number(vr_ret_boleto(1));
          vr_nrconven := to_number(vr_ret_boleto(2));
          vr_nrinssac := to_number(vr_ret_boleto(3));
          
          IF vr_tab_nrdocmto.exists(vr_nrdocmto) THEN
            CONTINUE;
          END IF;
          
          BEGIN
            -- Verificar se o boleto que foi selecionado pertence a um carne
            OPEN cr_verifica_carne(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrdocmto => vr_nrdocmto
                                  ,pr_nrinssac => vr_nrinssac
                                  ,pr_nrcnvcob => vr_nrconven);
            
            FETCH cr_verifica_carne INTO rw_verifica_carne;
            IF cr_verifica_carne%NOTFOUND THEN
              CLOSE cr_verifica_carne;
              -- Se não é carnê vai para o próximo
              CONTINUE;
            END IF;  

            CLOSE cr_verifica_carne;
            
            -- Limitar a pesquisa pelo número do documento sem a parcela
            vr_dsdoccop := SUBSTR(rw_verifica_carne.dsdoccop,1,length(rw_verifica_carne.dsdoccop)-4);
            
            -- verificar o dsdoccop da primeira parcela
            OPEN cr_primeira_parcela(pr_cdcooper => rw_verifica_carne.cdcooper
                                    ,pr_nrdconta => rw_verifica_carne.nrdconta
                                    ,pr_nrinssac => rw_verifica_carne.nrinssac
                                    ,pr_nrdocmto => rw_verifica_carne.nrdocmto
                                    ,pr_dsdoccop => vr_dsdoccop || '0001'
                                    ,pr_nrcnvcob => rw_verifica_carne.nrcnvcob);

            FETCH cr_primeira_parcela INTO rw_primeira_parcela;
            IF cr_primeira_parcela%NOTFOUND THEN
              CLOSE cr_primeira_parcela;
              -- Se não encontrar a primeira parcela vai para a próxima
              CONTINUE;
            END IF;  
            
            CLOSE cr_primeira_parcela;
            
            -- Buscar as informações do sacado para imprimir na capa do carnê            
            OPEN cr_crapsab(pr_cdcooper => rw_primeira_parcela.cdcooper
                           ,pr_nrdconta => rw_primeira_parcela.nrdconta
                           ,pr_nrinssac => rw_primeira_parcela.nrinssac);
            FETCH cr_crapsab INTO rw_crapsab;
            
            IF cr_crapsab%NOTFOUND THEN
              CLOSE cr_crapsab;
              RAISE vr_next;
            END IF;
            CLOSE cr_crapsab;
            
            -- Buscar as informações 
            OPEN cr_crapcco(pr_cdcooper => rw_primeira_parcela.cdcooper
                           ,pr_nrconven => vr_nrconven);
            FETCH cr_crapcco INTO rw_crapcco;
            
            IF cr_crapcco%NOTFOUND THEN
              CLOSE cr_crapcco;
              RAISE vr_next;
            END IF;
            CLOSE cr_crapcco;
            
            -- Buscar as informações 
            OPEN cr_crapceb(pr_cdcooper => rw_primeira_parcela.cdcooper
                           ,pr_nrdconta => rw_primeira_parcela.nrdconta
                           ,pr_nrconven => vr_nrconven);
            FETCH cr_crapceb INTO rw_crapceb;
            
            IF cr_crapceb%NOTFOUND THEN
              CLOSE cr_crapceb;
              RAISE vr_next;
            END IF;
            CLOSE cr_crapceb;
            
            COBR0009.pc_busca_emails_pagador(pr_cdcooper  => rw_crapsab.cdcooper
                                            ,pr_nrdconta  => rw_crapsab.nrdconta
                                            ,pr_nrinssac  => rw_crapsab.nrinssac
                                            ,pr_dsdemail  => vr_dsdemail
                                            ,pr_des_erro  => vr_des_erro
                                            ,pr_dscritic  => vr_dscritic);
            
            -- Gerar a tag que agrupa todas as informações de carnê
            gene0002.pc_escreve_xml(pr_xml            => pr_tab_boleto
                                   ,pr_texto_completo => vr_xml_tab_temp
                                   ,pr_texto_novo     => '<carne>');
                                   
            -- Gerar a tag para agrupar os dados do pagador
            gene0002.pc_escreve_xml(pr_xml            => pr_tab_boleto
                                   ,pr_texto_completo => vr_xml_tab_temp
                                   ,pr_texto_novo     =>   '<pagador>'
                                                        || ' <nmdsacad>' || rw_crapsab.nmdsacad || '</nmdsacad>'
                                                        || ' <dsendsac>' || rw_crapsab.dsendsac || '</dsendsac>'
                                                        || ' <nrendsac>' || rw_crapsab.nrendsac || '</nrendsac>'
                                                        || ' <nmbaisac>' || rw_crapsab.nmbaisac || '</nmbaisac>'
                                                        || ' <nmcidsac>' || rw_crapsab.nmcidsac || '</nmcidsac>'
                                                        || ' <cdufsaca>' || rw_crapsab.cdufsaca || '</cdufsaca>'
                                                        || ' <nrcepsac>' || rw_crapsab.nrcepsac || '</nrcepsac>'
                                                        || ' <nrinssac>' || rw_crapsab.nrinssac || '</nrinssac>'
                                                        || ' <cdtpinsc>' || rw_crapsab.cdtpinsc || '</cdtpinsc>'
                                                        || ' <complend>' || rw_crapsab.complend || '</complend>'
                                                        || ' <flgemail>' || rw_crapsab.flgemail || '</flgemail>'
                                                        || ' <dsdemail>' || vr_dsdemail || '</dsdemail>'
                                                        || '</pagador>');

            -- Gerar a tag que agrupa todos boletos
            gene0002.pc_escreve_xml(pr_xml            => pr_tab_boleto
                                   ,pr_texto_completo => vr_xml_tab_temp
                                   ,pr_texto_novo     => '<boletos>');
            
            -- Zeramos a validação das parcelas, para não imprimir parcelas de carnês diferentes 
            vr_parcela_ant := 1;
            vr_parcela_atu := 0;
                                
            -- Buscar o nome do beneficiario que deve ser impresso no boleto
            -- O carnê é emitido pelo mesmo beneficário, então vamos buscar o nome com o IDSEQTTL da primeira parcela do carnê
            COBR0009.pc_busca_nome_imp_blt(pr_cdcooper => rw_primeira_parcela.cdcooper
                                          ,pr_nrdconta => rw_primeira_parcela.nrdconta
                                          ,pr_idseqttl => rw_primeira_parcela.idseqttl
                                          ,pr_nmprimtl => vr_nmbenefi
                                          ,pr_des_erro => vr_des_erro_benef
                                          ,pr_dscritic => vr_dscritic);
                                
            FOR rw_parcelas IN cr_all_parcelas(pr_cdcooper => rw_primeira_parcela.cdcooper
                                              ,pr_nrdconta => rw_primeira_parcela.nrdconta
                                              ,pr_nrcnvcob => rw_primeira_parcela.nrcnvcob
                                              ,pr_nrinssac => rw_primeira_parcela.nrinssac
                                              ,pr_tpdmulta => rw_primeira_parcela.tpdmulta
                                              ,pr_tpjurmor => rw_primeira_parcela.tpjurmor
                                              ,pr_dsdoccop => vr_dsdoccop
                                              ,pr_nrdocmto_min => rw_primeira_parcela.nrdocmto
                                              ,pr_nrdocmto_max => rw_primeira_parcela.nrdocmto + 120) LOOP

              vr_parcela_atu := to_number(SUBSTR(rw_parcelas.dsdoccop,length(rw_parcelas.dsdoccop)-3,length(rw_parcelas.dsdoccop)));
              IF vr_parcela_atu < vr_parcela_ant THEN
                -- A parcela pertence a outro carnê
                RAISE vr_fim_parcelas;
              END IF;
              -- Atualiza a parcela anterior
              vr_parcela_ant := vr_parcela_atu;
              IF rw_parcelas.incobran <> 0 THEN
                -- Ignoramos as parcelas que não estão mais abertas
                CONTINUE;
              END IF;

              vr_tab_nrdocmto(rw_parcelas.nrdocmto).nrdocmto := rw_parcelas.nrdocmto;

              CASE rw_parcelas.cddespec
                WHEN  1 THEN vr_dsdespec := 'DM';
                WHEN  2 THEN vr_dsdespec := 'DS';
                WHEN  3 THEN vr_dsdespec := 'NP';
                WHEN  4 THEN vr_dsdespec := 'MENS';
                WHEN  5 THEN vr_dsdespec := 'NF';
                WHEN  6 THEN vr_dsdespec := 'RECI';
                WHEN  7 THEN vr_dsdespec := 'OUTR';
              END CASE;              
              
              rw_craptdb := NULL;
              
              OPEN cr_craptdb( pr_cdcooper => rw_parcelas.cdcooper
                              ,pr_nrdconta => rw_parcelas.nrdconta
                              ,pr_nrcnvcob => rw_parcelas.nrcnvcob
                              ,pr_nrdocmto => rw_parcelas.nrdocmto);
              FETCH cr_craptdb INTO rw_craptdb;              
              CLOSE cr_craptdb;
              
              vr_nrborder := nvl(rw_craptdb.nrborder,0);              

              cobr0005.pc_calc_codigo_barras(pr_dtvencto => rw_parcelas.dtvencto
                                           , pr_cdbandoc => rw_parcelas.cdbandoc
                                           , pr_vltitulo => rw_parcelas.vltitulo
                                           , pr_nrcnvcob => rw_parcelas.nrcnvcob
                                           , pr_nrcnvceb => 0
                                           , pr_nrdconta => rw_parcelas.nrdconta
                                           , pr_nrdocmto => rw_parcelas.nrdocmto
                                           , pr_cdcartei => rw_parcelas.cdcartei
                                           , pr_cdbarras => vr_dscodbar );
              
              cobr0005.pc_calc_linha_digitavel(pr_cdbarras => vr_dscodbar
                                             , pr_lindigit => vr_lindigit);
                                             
              CASE rw_parcelas.cdmensag 
                 WHEN 0 THEN vr_dsdinst1 := ' ';
                 WHEN 1 THEN vr_dsdinst1 := 'MANTER DESCONTO ATE O VENCIMENTO';
                 WHEN 2 THEN vr_dsdinst1 := 'MANTER DESCONTO APOS O VENCIMENTO';
              ELSE 
                 vr_dsdinst1 := ' ';             
              END CASE;
              
              IF nvl(rw_parcelas.nrctremp,0) > 0 THEN
                 vr_dsdinst1 := '*** NAO ACEITAR PAGAMENTO APOS O VENCIMENTO ***';
              END IF;                    
              
              IF (rw_parcelas.tpjurmor <> 3) OR (rw_parcelas.tpdmulta <> 3) THEN
                
                vr_dsdinst2 := 'APOS VENCIMENTO, COBRAR: ';
                
                IF rw_parcelas.tpjurmor = 1 THEN 
                   vr_dsdinst2 := vr_dsdinst2 || 'R$ ' || to_char(rw_parcelas.vljurdia, 'fm999g999g990d00') || ' JUROS AO DIA';
                ELSIF rw_parcelas.tpjurmor = 2 THEN 
                   vr_dsdinst2 := vr_dsdinst2 || to_char(rw_parcelas.vljurdia, 'fm999g999g990d00') || '% JUROS AO MES';
                END IF;
          			
                IF rw_parcelas.tpjurmor <> 3 AND
                   rw_parcelas.tpdmulta <> 3 THEN
                   vr_dsdinst2 := vr_dsdinst2 || ' E ';
                END IF;

                IF rw_parcelas.tpdmulta = 1 THEN 
                   vr_dsdinst2 := vr_dsdinst2 || 'MULTA DE R$ ' || to_char(rw_parcelas.vlrmulta, 'fm999g999g990d00');
                ELSIF rw_parcelas.tpdmulta = 2 THEN 
                   vr_dsdinst2 := vr_dsdinst2 || 'MULTA DE ' || to_char(rw_parcelas.vlrmulta, 'fm999g999g990d00') || '%';
                END IF;
          			      			
              END IF;
              
              IF rw_parcelas.flgdprot = 'S' THEN
                 vr_dsdinst3 := 'PROTESTAR APOS ' || to_char(rw_parcelas.qtdiaprt,'fm00') || ' DIAS CORRIDOS DO VENCIMENTO.';
                 vr_dsdinst4 := ' ';
              END IF;
                        
              IF rw_parcelas.flserasa = 'S' AND rw_parcelas.qtdianeg > 0  THEN
                 vr_dsdinst3 := 'NEGATIVAR NA SERASA APOS ' || to_char(rw_parcelas.qtdianeg,'fm00') || ' DIAS CORRIDOS DO VENCIMENTO.';
                 vr_dsdinst4 := ' ';
              END IF;
                                             
              -- Se não retornou o nome do beneficiario da COBR0009, utilizamos o nome que estava sendo devolvido
              IF vr_des_erro_benef <> 'OK' THEN
                vr_nmbenefi := rw_parcelas.nmprimtl;
              END IF;

              -- Gera a informação dos boletos
              gene0002.pc_escreve_xml(pr_xml => pr_tab_boleto,
                                      pr_texto_completo => vr_xml_tab_temp,
                                      pr_texto_novo =>  '<boleto>'
                                                     || '<nrnosnum>' || rw_parcelas.nrnosnum || '</nrnosnum>'
                                                     || '<nmdsacad>' || rw_parcelas.nmdsacad || '</nmdsacad>'
                                                     || '<nrinssac>' || rw_parcelas.nrinssac || '</nrinssac>'
                                                     || '<dsendsac>' || rw_parcelas.dsendsac || '</dsendsac>'
                                                     || '<nmbaisac>' || rw_parcelas.nmbaisac || '</nmbaisac>'
                                                     || '<nmcidsac>' || rw_parcelas.nmcidsac || '</nmcidsac>'
                                                     || '<cdufsaca>' || rw_parcelas.cdufsaca || '</cdufsaca>'
                                                     || '<nrcepsac>' || rw_parcelas.nrcepsac || '</nrcepsac>'
                                                     || '<nmdavali>' || rw_parcelas.nmdavali || '</nmdavali>'
                                                     || '<nrdctabb>' || rw_parcelas.nrdctabb || '</nrdctabb>'
                                                     || '<nrcpfcgc>' || rw_parcelas.nrcpfcgc || '</nrcpfcgc>'
                                                     || '<nrdocmto>' || rw_parcelas.nrdocmto || '</nrdocmto>'
                                                     || '<dtmvtolt>' || to_char(rw_parcelas.dtmvtolt,'dd/mm/RRRR') || '</dtmvtolt>'
                                                     || '<dsdinstr>' || rw_parcelas.dsdinstr || '</dsdinstr>'
                                                     || '<dsdoccop>' || rw_parcelas.dsdoccop || '</dsdoccop>'
                                                     || '<dtvencto>' || to_char(rw_parcelas.dtvencto,'dd/mm/RRRR') || '</dtvencto>'
                                                     || '<dtdpagto>' || to_char(rw_parcelas.dtdpagto,'dd/mm/RRRR') || '</dtdpagto>'
                                                     || '<vltitulo>' || rw_parcelas.vltitulo || '</vltitulo>'
                                                     || '<vldpagto>' || rw_parcelas.vldpagto || '</vldpagto>'
                                                     || '<cdtpinsc>' || rw_parcelas.cdtpinsc || '</cdtpinsc>'
                                                     || '<inpessoa>' || rw_parcelas.inpessoa || '</inpessoa>'
                                                     || '<nmprimtl>' || vr_nmbenefi          || '</nmprimtl>'
                                                     || '<vldescto>' || rw_parcelas.vldescto || '</vldescto>'
                                                     || '<cdmensag>' || rw_parcelas.cdmensag || '</cdmensag>'
                                                     || '<dsinform>' || rw_parcelas.dsinform || '</dsinform>'
                                                     || '<vlabatim>' || rw_parcelas.vlabatim || '</vlabatim>'
                                                     || '<cddespec>' || rw_parcelas.cddespec || '</cddespec>'
                                                     || '<dtdocmto>' || to_char(rw_parcelas.dtdocmto,'dd/mm/RRRR') || '</dtdocmto>'
                                                     || '<cdbanpag>' || rw_parcelas.cdbanpag || '</cdbanpag>'
                                                     || '<cdagepag>' || rw_parcelas.cdagepag || '</cdagepag>'
                                                     || '<dtelimin>' || to_char(rw_parcelas.dtelimin,'dd/mm/RRRR') || '</dtelimin>'
                                                     || '<cdcartei>' || rw_parcelas.cdcartei || '</cdcartei>'
                                                     || '<cdbandoc>' || rw_parcelas.cdbandoc || '</cdbandoc>'
                                                     || '<flgregis>' || rw_parcelas.flgregis || '</flgregis>'
                                                     || '<nrnosnum>' || rw_parcelas.nrnosnum || '</nrnosnum>'
                                                     || '<flgaceit>' || rw_parcelas.flgaceit || '</flgaceit>'
                                                     || '<tpjurmor>' || rw_parcelas.tpjurmor || '</tpjurmor>'
                                                     || '<vljurdia>' || rw_parcelas.vljurdia || '</vljurdia>'
                                                     || '<tpdmulta>' || rw_parcelas.tpdmulta || '</tpdmulta>'
                                                     || '<vlrmulta>' || rw_parcelas.vlrmulta || '</vlrmulta>'
                                                     || '<flgdprot>' || rw_parcelas.flgdprot || '</flgdprot>'
                                                     || '<qtdiaprt>' || rw_parcelas.qtdiaprt || '</qtdiaprt>'
                                                     || '<indiaprt>' || rw_parcelas.indiaprt || '</indiaprt>'
                                                     || '<insitpro>' || rw_parcelas.insitpro || '</insitpro>'
                                                     || '<cdtpinav>' || rw_parcelas.cdtpinav || '</cdtpinav>'
                                                     || '<nrinsava>' || rw_parcelas.nrinsava || '</nrinsava>'
                                                     || '<nrvarcar>' || rw_crapcco.nrvarcar  || '</nrvarcar>'
                                                     || '<nragenci>' || rw_crapcop.cdagectl  || '</nragenci>'
                                                     || '<nrcnvceb>' || rw_crapceb.nrcnvceb  || '</nrcnvceb>'
                                                     || '<nrconven>' || rw_crapcco.nrconven  || '</nrconven>'
                                                     || '<nrdctabb>' || rw_parcelas.nrdctabb || '</nrdctabb>'
                                                     || '<flgaceit>' || rw_parcelas.flgaceit || '</flgaceit>'
                                                     || '<flserasa>' || rw_parcelas.flserasa || '</flserasa>'
                                                     || '<qtdianeg>' || rw_parcelas.qtdianeg || '</qtdianeg>'
                                                     || '<inserasa>' || rw_parcelas.inserasa || '</inserasa>'
                                                     || '<vldocmto_boleto>'  || rw_parcelas.vltitulo || '</vldocmto_boleto>' 
                                                     || '<vlcobrado_boleto>' || rw_parcelas.vltitulo || '</vlcobrado_boleto>'
                                                     || '<dtvencto_boleto>'  || to_char(rw_parcelas.dtvencto,'dd/mm/RRRR') || '</dtvencto_boleto>'
                                                     || '<linhadigitavel>'   || vr_lindigit         || '</linhadigitavel>'
                                                     || '<codigobarras>'     || vr_dscodbar         || '</codigobarras>'
                                                     || '<dsdespec>'         || vr_dsdespec         || '</dsdespec>'
                                                     || '<nrborder>'         || vr_nrborder         || '</nrborder>'
                                                     || '<dsdinst1>'         || vr_dsdinst1         || '</dsdinst1>'                                                     
                                                     || '<dsdinst2>'         || vr_dsdinst2         || '</dsdinst2>'                                                     
                                                     || '<dsdinst3>'         || vr_dsdinst3         || '</dsdinst3>'                                                     
                                                     || '<dsdinst4>'         || vr_dsdinst4         || '</dsdinst4>'                                                     
                                                     || '<dsdinst5>'         || vr_dsdinst5         || '</dsdinst5>'                                                                                                                                                                                                                                                                         
                                                     || '</boleto>');
            END LOOP;
            
          EXCEPTION 
            WHEN vr_fim_parcelas THEN
              -- Fecha a tag que agrupa todos os Boletos e Carnê
              gene0002.pc_escreve_xml(pr_xml            => pr_tab_boleto
                                     ,pr_texto_completo => vr_xml_tab_temp
                                     ,pr_texto_novo     => '</boletos></carne>');
              CONTINUE;
              
            WHEN vr_next THEN
              CONTINUE;
                
            WHEN OTHERS THEN
              -- Fecha a tag que agrupa todos os Boletos e Carnê
              gene0002.pc_escreve_xml(pr_xml            => pr_tab_boleto
                                     ,pr_texto_completo => vr_xml_tab_temp
                                     ,pr_texto_novo     => '</boletos></carne>');
                                     
              pr_dscritic := 'Erro na geracao dos boletos do carne: ' || SQLERRM;
              
              CONTINUE;
          END;
          
          -- Fecha a tag que agrupa todos os Boletos e Carnê
          gene0002.pc_escreve_xml(pr_xml            => pr_tab_boleto
                                 ,pr_texto_completo => vr_xml_tab_temp
                                 ,pr_texto_novo     => '</boletos></carne>');
        END LOOP;
        
        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => pr_tab_boleto
                               ,pr_texto_completo => vr_xml_tab_temp
                               ,pr_texto_novo     => '</dados>'
                               ,pr_fecha_xml      => TRUE);
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao montar XML. Rotina COBR0001.pc_carrega_parcelas_carne: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
        
    EXCEPTION
     WHEN vr_exc_erro THEN
       pr_cdcritic := NVL(vr_cdcritic,0);
       pr_dscritic := vr_dscritic;
     WHEN OTHERS THEN
       pr_cdcritic := 0;
       pr_dscritic := 'Erro na Rotina COBR0001.pc_carrega_parcelas_carne. Erro: ' || SQLERRM;
    END;
  END pc_carrega_parcelas_carne;
  
  /* Funcao que retorna se o Cooperado possui cadastro de emissao bloqueto ativo */
  FUNCTION fn_verif_ceb_ativo (pr_cdcooper IN crapcop.cdcooper%TYPE   -- Codigo da cooperativa
                              ,pr_nrdconta IN crapass.nrdconta%TYPE   -- Numero da conta do cooperado
                              ) RETURN INTEGER IS

  /*--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_verif_ceb_ativo           Antigo: b1wgen0082.p/verifica-cadastro-ativo 
  --  Sistema  : Procedimentos para arquivos de cobranca
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana (AMcom)
  --  Data     : Junho/2014.                      Ultima atualizacao: 17/12/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Funcao que retorna se o Cooperado possui cadastro de emissao bloqueto ativo
  --
  -- Alteracoes: 23/06/2014 - Conversão Progres --> Oracle (Odirlei-AMcom)
  --
  --             17/12/2014 - Tratamento incorporação( SD 234123 Odirlei-AMcom)
  --
  --             22/12/2014 - Ajuste da variável de indice, devido a erro no processo
  --                          batch. ( Renato - Supero )
  ---------------------------------------------------------------------------------------------------------------*/
    ------------------------------- CURSORES ---------------------------------
    CURSOR cr_crapceb_2 IS 
      SELECT 1
        FROM crapceb
       WHERE crapceb.cdcooper = pr_cdcooper
         AND crapceb.nrdconta = pr_nrdconta
	 UNION ALL
	    SELECT 1
        FROM tbcobran_crapceb crapceb
       WHERE crapceb.cdcooper = pr_cdcooper
         AND crapceb.nrdconta = pr_nrdconta;
       rw_crapceb cr_crapceb_2%ROWTYPE;
         
    ------------------------------- VARIAVEIS -------------------------------
  BEGIN
    -- verificar se a ceb esta ativa
    OPEN cr_crapceb_2;
    FETCH cr_crapceb_2 INTO rw_crapceb;
    
    IF cr_crapceb_2%FOUND THEN
      CLOSE cr_crapceb_2;
      RETURN 1; -- TRUE
    ELSE
      CLOSE cr_crapceb_2;
      RETURN 0; -- false
    END IF;
    
  END fn_verif_ceb_ativo; 
  
END cobr0001;
/
