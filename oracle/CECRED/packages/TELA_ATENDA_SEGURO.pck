CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_SEGURO IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_SEGURO
  --  Sistema  : Procedimentos para tela Atenda / Seguros
  --  Sigla    : CRED
  --  Autor    : Marcos Martini - Supero
  --  Data     : Junho/2016.                
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações da Atenda Seguros
  --
  ---------------------------------------------------------------------------------------------------------------
  
  /* Busca quantidade de seguros do Cooperado */
  FUNCTION fn_qtd_seguros_novos(pr_cdcooper   IN crapcop.cdcooper%TYPE     --Código da cooperativa
                               ,pr_nrdconta   IN crapceb.nrdconta%TYPE)   --Número da conta solicitada;
                                  RETURN NUMBER;
  
  /* Busca dos seguros do Cooperado */
  PROCEDURE pc_busca_seguros(pr_nrdconta   IN crapceb.nrdconta%TYPE --Número da conta solicitada;
                            ,pr_dtmvtolt   IN VARCHAR2              --Data atual
                            ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                            ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                            ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                            ,pr_retxml     IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                            ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                            ,pr_des_erro  OUT VARCHAR2);            --Saida OK/NOK

  /* Detalhamento das informações de seguro vida contratado na conta */
  PROCEDURE pc_detalha_seguro_vida(pr_nrdconta   IN crapceb.nrdconta%TYPE --> Número da conta solicitada;
                                  ,pr_idcontrato IN crapceb.nrconven%TYPE --> ID Do contrato a detalhar
                                  ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                  ,pr_xmlseguro  IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                  ,pr_des_erro  OUT VARCHAR2);            --Saida OK/NOK  

  /* Detalhamento das informações de seguro AUTO contratado na conta */
  PROCEDURE pc_detalha_seguro_auto(pr_nrdconta   IN crapceb.nrdconta%TYPE --> Número da conta solicitada;
                                  ,pr_idcontrato IN crapceb.nrconven%TYPE --> ID Do contrato a detalhar
                                  ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                  ,pr_xmlseguro IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                  ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo                             

  /* Detalhamento das informações de seguro CASA contratado via SIGAS */
  PROCEDURE pc_detalha_seguro_casa_sigas(pr_nrdconta   IN crapass.nrdconta%TYPE --> Número da conta solicitada;
                                        ,pr_cdcooper   IN crapass.cdcooper%TYPE --> ID Do contrato a detalhar
                                        ,pr_idcontrato IN tbseg_producao_sigas.id%TYPE             --> Id contrato
                                        ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                        ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                        ,pr_xmlseguro IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                        ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo                                      

  /* Detalhamento das informações de seguro CASA contratado via SIGAS */
  PROCEDURE pc_cancela_seguro_casa_sigas(pr_cdidsegp   IN VARCHAR2              --> Apolice
                                        ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Número da conta solicitada;
                                        ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                        ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                        ,pr_xmlseguro IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                        ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo                                      

END TELA_ATENDA_SEGURO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_SEGURO IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_SEGURO
  --  Sistema  : Procedimentos para tela Atenda / Seguros
  --  Sigla    : CRED
  --  Autor    : Marcos Martini - Supero
  --  Data     : Junho/2016.                
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações da Atenda Seguros
  --
  -- Alteracoes: 28/10/2016 - Alterado pc_busca_seguros para que os resultados da 
  --                          consulta nao se lmitem apenas a um ano (Tiago/Thiago 506860)
  ---------------------------------------------------------------------------------------------------------------
  
  /* Busca quantidade de seguros do Cooperado */
  FUNCTION fn_qtd_seguros_novos(pr_cdcooper   IN crapcop.cdcooper%TYPE     --Código da cooperativa
                               ,pr_nrdconta   IN crapceb.nrdconta%TYPE)   --Número da conta solicitada;
                                   RETURN NUMBER IS
  BEGIN

    /* .............................................................................

    Programa: fn_qtd_seguros_novos
    Sistema : Ayllos Web
    Autor   : Marcos Martini - Supero
    Data    : Junho/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Retornar a quantidade de seguros novos contratados na conta

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Busca dos contratos
      CURSOR cr_tbseg_qtd IS
         SELECT COUNT(1)
           FROM tbseg_contratos segNov
               ,crapcsg         csg
               ,tbseg_parceiro  par
          WHERE segNov.cdparceiro = par.cdparceiro
            AND segNov.cdcooper   = csg.cdcooper
            AND segNov.cdsegura   = csg.cdsegura
            AND segNov.cdcooper   = pr_cdcooper
            AND segNov.nrdconta   = pr_nrdconta
            AND segNov.nrapolice > 0;
      vr_qtd NUMBER := 0;
    BEGIN
      -- Busca da quantidade
      OPEN cr_tbseg_qtd;
      FETCH cr_tbseg_qtd
       INTO vr_qtd;
      CLOSE cr_tbseg_qtd;
      -- Retornar quantidade encontrada
      RETURN vr_qtd;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END fn_qtd_seguros_novos;
  
  /* Busca dos seguros do Cooperado */
  PROCEDURE pc_busca_seguros(pr_nrdconta   IN crapceb.nrdconta%TYPE --Número da conta solicitada;
                            ,pr_dtmvtolt   IN VARCHAR2              --Data atual
                            ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                            ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                            ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                            ,pr_retxml     IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                            ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                            ,pr_des_erro  OUT VARCHAR2) IS          --Saida OK/NOK
  BEGIN

    /* .............................................................................

    Programa: pc_busca_seguros
    Sistema : Ayllos Web
    Autor   : Marcos Martini - Supero
    Data    : Junho/2016                 Ultima atualizacao: 08/07/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Retornar a listagem dos seguros contratados na conta corrente repassada. 
                Esta rotina é uma versão simplifica da busca_seguros na Bo33, e criamos a mesma 
                pois como haverá consulta em tabela nova disponível somente no Oracle, não 
                poderemos utilizá-la na BO33.

    Alteracoes: 05/06/2018 - Alterado pc_busca_seguros para listar descricao de motivo
                             de cancelamento.
                             (Marcel Kohls - AMCom)
                
                08/07/2019 - Alterada para receber seguros do sigas na listagem em tela.
                             (Darlei Zillmer / Supero)
    ..............................................................................*/

    DECLARE

      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Handle para a consulta dinâmica
      vr_ctx DBMS_XMLGEN.ctxHandle;
      vr_xmldata CLOB;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_dtmvtolt DATE:=to_date(pr_dtmvtolt,'DD/MM/RRRR');

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      -- Se encontrar erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Criação do contexto para a consulta 
      vr_ctx := 
         dbms_xmlgen.newcontext(' SELECT dsTipo       as "dsTipo",
                                         tpSeguro     as "tpSeguro",
                                         nrApolice2   as "nrApolice2",
                                         nrApolice    as "nrApolice",
                                         dtIniVigen   as "dtIniVigen",
                                         dtFimVigen   as "dtFimVigen",
                                         dsSeguradora as "dsSeguradora",
                                         dsSituac     as "dsSituac",
                                         idOrigem     as "idOrigem",
                                         idContrato   as "idContrato",
                                         nmParceiro   as "nmParceiro",
                                         cdSegura     as "cdSegura",
                                         nmdsegur     as "nmdsegur",
                                         tpplaseg     as "tpplaseg",
                                         dtcancel     as "dtcancel",
                                         vlpreseg     as "vlpreseg",
                                         qtprepag     as "qtprepag",
                                         vlprepag     AS "vlprepag",
                                         dtdebito     AS "dtdebito",
                                         dtiniseg     AS "dtiniseg",
                                         dtmvtolt     AS "dtmvtolt",
                                         cdsexosg     AS "cdsexosg",
                                         qtparcel     AS "qtparcel",
                                         nmbenvid_1   AS "nmbenvid_1",
                                         nmbenvid_2   AS "nmbenvid_2",
                                         nmbenvid_3   AS "nmbenvid_3",
                                         nmbenvid_4   AS "nmbenvid_4",
                                         nmbenvid_5   AS "nmbenvid_5",
                                         dsgraupr_1   AS "dsgraupr_1",
                                         dsgraupr_2   AS "dsgraupr_2",
                                         dsgraupr_3   AS "dsgraupr_3",
                                         dsgraupr_4   AS "dsgraupr_4",
                                         dsgraupr_5   AS "dsgraupr_5",
                                         txpartic_1   AS "txpartic_1",
                                         txpartic_2   AS "txpartic_2",
                                         txpartic_3   AS "txpartic_3",
                                         txpartic_4   AS "txpartic_4",
                                         txpartic_5   AS "txpartic_5",
                                         dsmotcan     AS "dsMotcan",
                                         dscanal      AS "dscanal"
                                    FROM (SELECT decode(seg.tpseguro,
                                                1,
                                                ''CASA'',
                                                11,
                                                ''CASA'',
                                                2,
                                                ''AUTO'',
                                                3,
                                                ''VIDA'',
                                                4,
                                                ''PRST'',
                                                ''    '') dsTipo,
                                         seg.tpseguro tpSeguro,
                                         ltrim(gene0002.fn_mask(seg.nrctrseg, ''zzzzz.zz9'')) nrApolice,
                                         to_char(seg.dtinivig, ''dd/mm/rrrr'') dtIniVigen,
                                         to_char(wseg.dtfimvig, ''dd/mm/rrrr'') dtFimVigen,
                                         csg.nmresseg dsSeguradora,
                                         decode(seg.cdsitseg,
                                                3,
                                                ''Ativo'',
                                                11,
                                                ''Ativo'',
                                                1,
                                                ''Ativo'',
                                                2,
                                                ''Cancelado'',
                                                3,
                                                ''S'' || gene0002.fn_mask(seg.nrctratu, ''zzzzz.zz9''),
                                                4,
                                                ''Vencido'',
                                                ''?????????'') dsSituac,
                                         ''A'' idOrigem,
                                         seg.progress_recid idContrato,
                                         '' '' nmParceiro,
                                         seg.nrctrseg nrApolice2,
                                         seg.cdsegura cdSegura,
                                         NVL(TRIM(wseg.nmdsegur), '' '') nmdsegur,
                                         NVL(wseg.tpplaseg, 0) tpplaseg,
                                         to_char(seg.dtcancel, ''dd/mm/rrrr'') dtcancel,
                                         to_char(seg.vlpreseg,
                                                 ''fm999g999g990d00'',
                                                 ''NLS_NUMERIC_CHARACTERS=,.'') vlpreseg,
                                         seg.qtprepag qtprepag,
                                         to_char(seg.vlprepag,
                                                 ''fm999g999g990d00'',
                                                 ''NLS_NUMERIC_CHARACTERS=,.'') vlprepag,
                                         to_char(seg.dtdebito, ''dd/mm/rrrr'') dtdebito,
                                         to_char(seg.dtiniseg, ''dd/mm/rrrr'') dtiniseg,
                                         to_char(seg.dtmvtolt, ''dd/mm/rrrr'') dtmvtolt,
                                         wseg.cdsexosg cdsexosg,
                                         wseg.qtparcel qtparcel,
                                         seg.nmbenvid##1 nmbenvid_1,
                                         seg.nmbenvid##2 nmbenvid_2,
                                         seg.nmbenvid##3 nmbenvid_3,
                                         seg.nmbenvid##4 nmbenvid_4,
                                         seg.nmbenvid##5 nmbenvid_5,
                                         seg.dsgraupr##1 dsgraupr_1,
                                         seg.dsgraupr##2 dsgraupr_2,
                                         seg.dsgraupr##3 dsgraupr_3,
                                         seg.dsgraupr##4 dsgraupr_4,
                                         seg.dsgraupr##5 dsgraupr_5,
                                         seg.txpartic##1 txpartic_1,
                                         seg.txpartic##2 txpartic_2,
                                         seg.txpartic##3 txpartic_3,
                                         seg.txpartic##4 txpartic_4,
                                         seg.txpartic##5 txpartic_5,
                                         decode(seg.cdmotcan,
                                                1,
                                                ''Nao Interesse pelo Seguro'',
                                                2,
                                                ''Desligamento da Empresa (Estipulante)'',
                                                3,
                                                ''Falecimento'',
                                                4,
                                                ''Outros'',
                                                5,
                                                ''Alteracao de endereco'',
                                                6,
                                                ''Alteracao de plano'',
                                                7,
                                                ''Venda do imovel'',
                                                8,
                                                ''Insuficiencia de saldo'',
                                                9,
                                                ''Encerramento de conta'',
                                                10,
                                                ''Insatisfação'',
                                                11,
                                                ''Perdido para a concorrência'',
                                                12,
                                                ''Insuf. saldo e/ou Inadimplencia (autom.)'',
                                                '' '') dsMotcan,
                                                ''AIMARO'' dscanal
                                    FROM crapseg seg, crapcsg csg, crawseg wseg
                                   WHERE seg.cdcooper = csg.cdcooper
                                     AND seg.cdsegura = csg.cdsegura
                                     AND seg.cdcooper = '||vr_cdcooper||'
                                     AND seg.nrdconta = '||pr_nrdconta||'
                                     AND seg.cdcooper = wseg.cdcooper(+)
                                     AND seg.nrdconta = wseg.nrdconta(+)
                                     AND seg.nrctrseg = wseg.nrctrseg(+)
                                     AND seg.cdsitseg in (1, 2, 3, 4, 11)
                                  UNION ALL
                                  SELECT decode(segNov.tpseguro,
                                                ''C'',
                                                ''CASA'',
                                                ''A'',
                                                ''AUTO'',
                                                ''V'',
                                                ''VIDA'',
                                                ''G'',
                                                ''VIDA'',
                                                ''P'',
                                                ''PRST'',
                                                ''    '') dsTipo,
                                         decode(segNov.tpseguro,
                                                ''C'',
                                                11,
                                                ''A'',
                                                2,
                                                ''V'',
                                                3,
                                                ''G'',
                                                3,
                                                ''P'',
                                                4,
                                                0) tpSeguro,
                                         ltrim(gene0002.fn_mask(segNov.nrapolice, ''zzzzz.zz9'')) nrApolice,
                                         to_char(segNov.dtinicio_vigencia, ''dd/mm/rrrr'') dtIniVigen,
                                         to_char(segNov.dttermino_vigencia, ''dd/mm/rrrr'') dtFimVigen,
                                         csg.nmresseg dsSeguradora,
                                         decode(segNov.indsituacao,
                                                ''A'',
                                                ''Ativo'',
                                                ''R'',
                                                ''Renovado'',
                                                ''C'',
                                                ''Cancelado'',
                                                ''V'',
                                                ''Vencido'',
                                                ''?????????'') dsSituac,
                                         ''N'' idOrigem,
                                         segNov.idcontrato idContrato,
                                         par.nmparceiro nmParceiro,
                                         segNov.nrapolice nrApolice2,
                                         segNov.cdsegura cdsegura,
                                         TRIM(segNov.nmsegurado) nmdsegur,
                                         0 tpplaseg,
                                         to_char(segNov.dtcancela, ''dd/mm/rrrr'') dtcancel,
                                         ''0'' vlpreseg,
                                         0 qtprepag,
                                         ''0'' vlprepag,
                                         to_char(SYSDATE, ''dd/mm/rrrr'') dtdebito,
                                         to_char(SYSDATE, ''dd/mm/rrrr'') dtiniseg,
                                         to_char(segNov.dtmvtolt, ''dd/mm/rrrr'') dtmvtolt,
                                         0 cdsexosg,
                                         segNov.qtparcelas qtparcel,
                                         '' '' nmbenvid_1,
                                         '' '' nmbenvid_2,
                                         '' '' nmbenvid_3,
                                         '' '' nmbenvid_4,
                                         '' '' nmbenvid_5,
                                         '' '' dsgraupr_1,
                                         '' '' dsgraupr_2,
                                         '' '' dsgraupr_3,
                                         '' '' dsgraupr_4,
                                         '' '' dsgraupr_5,
                                         0 txpartic_1,
                                         0 txpartic_2,
                                         0 txpartic_3,
                                         0 txpartic_4,
                                         0 txpartic_5,
                                         '' '' dsmotcan,
                                         ''AIMARO'' dscanal
                                    FROM tbseg_contratos segNov, crapcsg csg, tbseg_parceiro par
                                   WHERE segNov.cdparceiro = par.cdparceiro
                                     AND segNov.cdcooper = csg.cdcooper
                                     AND segNov.cdsegura = csg.cdsegura
                                     AND segNov.cdcooper = '||vr_cdcooper||'
                                     AND segNov.nrdconta = '||pr_nrdconta||'
                                     AND segNov.flgvigente = 1
                                     AND segNov.nrapolice > 0
                                   UNION ALL
                                  SELECT decode(segpro.idproduto,
                                                125,
                                                ''CASA''
                                                ) dsTipo,
                                         segpro.idproduto tpSeguro,
                                         ltrim(gene0002.fn_mask(segpro.nrproposta, ''zzzzz.zz9'')) nrApolice,
                                         to_char(segpro.dtfim_vigencia, ''dd/mm/rrrr'') dtIniVigen,
                                         to_char(segpro.dtinicio_vigencia, ''dd/mm/rrrr'') dtFimVigen,
                                         segpro.nmseguradora dsSeguradora,
                                         decode(segpro.tpproposta,
                                                ''AGENDADO'',
                                                ''Agendado'',
                                                ''NOVO'',
                                                ''Novo'',
                                                ''RENOVACAO'',
                                                ''Renovado'',
                                                ''ENDOSSO'',
                                                ''Endosso'',
                                                ''CANCELAMENTO'',
                                                ''Cancelado'',
                                                ''FATURA'',
                                                ''Fatura'',
                                                ''?????????'') dsSituac,
                                         ''S'' idOrigem,
                                         segpro.id idContrato,
                                         '' '' nmParceiro,
                                         to_number(segpro.nrapolice_certificado) nrApolice2,
                                         segpro.idseguradora cdSegura,
                                         NVL(TRIM(segpro.nmsegurado), '' '') nmdsegur,
                                         0 tpplaseg,
                                         '' '' dtcancel,
                                         ''0'' vlpreseg,
                                         to_number(segpro.dsparcelamento) qtprepag,
                                         ''0'' vlprepag,
                                         ''0'' dtdebito,
                                         to_char(segpro.dtinicio_vigencia, ''dd/mm/rrrr'') dtiniseg,
                                         to_char(segpro.dtprocessamento, ''dd/mm/rrrr'') dtmvtolt,
                                         DECODE(segpro.tpsexo, 
                                                ''M'', 
                                                  1,
                                                ''F'', 
                                                  2, 
                                                  0) cdsexosg,
                                         to_number(segpro.dsparcelamento) qtparcel,
                                         ''-'' nmbenvid_1,
                                         ''-'' nmbenvid_2,
                                         ''-'' nmbenvid_3,
                                         ''-'' nmbenvid_4,
                                         ''-'' nmbenvid_5,
                                         ''-'' dsgraupr_1,
                                         ''-'' dsgraupr_2,
                                         ''-'' dsgraupr_3,
                                         ''-'' dsgraupr_4,
                                         ''-'' dsgraupr_5,
                                         0 txpartic_1,
                                         0 txpartic_2,
                                         0 txpartic_3,
                                         0 txpartic_4,
                                         0 txpartic_5,
                                         '' '' dsMotcan,
                                         ''SIGAS'' dscanal
                                    FROM tbseg_producao_sigas segpro, crapass ass
                                   WHERE segpro.cden2 = '||vr_cdcooper||'
                                     AND ass.nrdconta = segpro.nrdconta
                                     AND segpro.nrdconta = '||pr_nrdconta||'

                                  -- Apolices sigas
                                  --    UNION ALL
                                  --    SELECT decode(segapo.idproduto,
                                  --                  125,
                                  --                  ''CASA''
                                  --                  ) dsTipo,
                                  --           segapo.idproduto tpSeguro,
                                  --           ltrim(gene0002.fn_mask(segapo.nrproposta, ''zzzzz.zz9'')) nrApolice,
                                  --           to_char(segapo.dtfim_vigencia, ''dd/mm/rrrr'') dtIniVigen,
                                  --           to_char(segapo.dtinicio_vigencia, ''dd/mm/rrrr'') dtFimVigen,
                                  --           segapo.nmseguradora dsSeguradora,
                                  --           decode(segapo.tpproposta,
                                  --                  ''AGENDADO'',
                                  --                  ''Agendado'',
                                  --                  ''NOVO'',
                                  --                  ''Novo'',
                                  --                  ''RENOVACAO'',
                                  --                  ''Renovado'',
                                  --                  ''ENDOSSO'',
                                  --                  ''Endosso'',
                                  --                  ''CANCELAMENTO'',
                                  --                  ''Cancelado'',
                                  --                  ''FATURA'',
                                  --                  ''Fatura'',
                                  --                  ''?????????'') dsSituac,
                                  --           ''S'' idOrigem,
                                  --           segapo.id idContrato,
                                  --           '' '' nmParceiro,
                                  --           to_number(segapo.nrapolice_certificado) nrApolice2,
                                  --           segapo.idseguradora cdSegura,
                                  --           NVL(TRIM(segapo.nmsegurado), '' '') nmdsegur,
                                  --           0 tpplaseg,
                                  --           '' '' dtcancel,
                                  --           ''0'' vlpreseg,
                                  --           to_number(segapo.dsparcelamento) qtprepag,
                                  --           ''0'' vlprepag,
                                  --           ''0'' dtdebito,
                                  --           to_char(segapo.dtinicio_vigencia, ''dd/mm/rrrr'') dtiniseg,
                                  --           to_char(segapo.dtprocessamento, ''dd/mm/rrrr'') dtmvtolt,
                                  --           DECODE(segapo.tpsexo, 
                                  --                  ''M'', 
                                  --                    1,
                                  --                  ''F'', 
                                  --                    2, 
                                  --                    0) cdsexosg,
                                  --           to_number(segapo.dsparcelamento) qtparcel,
                                  --           ''-'' nmbenvid_1,
                                  --           ''-'' nmbenvid_2,
                                  --           ''-'' nmbenvid_3,
                                  --           ''-'' nmbenvid_4,
                                  --           ''-'' nmbenvid_5,
                                  --           ''-'' dsgraupr_1,
                                  --           ''-'' dsgraupr_2,
                                  --           ''-'' dsgraupr_3,
                                  --           ''-'' dsgraupr_4,
                                  --           ''-'' dsgraupr_5,
                                  --           0 txpartic_1,
                                  --           0 txpartic_2,
                                  --           0 txpartic_3,
                                  --           0 txpartic_4,
                                  --           0 txpartic_5,
                                  --           '' '' dsMotcan,
                                  --           ''SIGAS'' dscanal
                                  --      FROM tbseg_apolices_sigas segapo, crapass ass
                                  --     WHERE segapo.cden2 = '||vr_cdcooper||'
                                  --       AND segapo.nrcpf_cnpj = ass.nrcpfcgc
                                  --       AND ass.nrdconta = '||pr_nrdconta||'
                                       )
                               ORDER BY dsSituac, dsTipo, dtFimVigen DESC, nrApolice2
                                 ');
                                           -- AND segNov.nrapolice > 0 é para nao mostrar propostas
      -- Renomeando as tags padrão
      dbms_xmlgen.setRowSetTag(vr_ctx, 'Contratos');
      dbms_xmlgen.setrowtag(vr_ctx, 'Contrato');
      
      /* Retornar o XML montado no parâmetro de saída CLOB */
      vr_xmldata := dbms_xmlgen.getXML(ctx => vr_ctx);
      IF vr_xmldata IS NOT NULL THEN
        vr_xmldata := replace(vr_xmldata,'version="1.0"','version="1.0" encoding="ISO-8859-1"');
        pr_retxml := XMLType.createXML(vr_xmldata);
      ELSE
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Contratos/>');
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_SEGURO - pc_busca_seguros: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATENDA_SEGURO - pc_busca_seguros: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_seguros;
  
  /* Detalhamento das informações de seguro vida contratado na conta */
  PROCEDURE pc_detalha_seguro_vida(pr_nrdconta   IN crapceb.nrdconta%TYPE --> Número da conta solicitada;
                                  ,pr_idcontrato IN crapceb.nrconven%TYPE --> ID Do contrato a detalhar
                                  ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                  ,pr_xmlseguro  IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                  ,pr_des_erro  OUT VARCHAR2) IS          --Saida OK/NOK                           
  BEGIN

    /* .............................................................................

    Programa: pc_detalha_seguro_vida
    Sistema : Ayllos Web
    Autor   : Marcos Martini - Supero
    Data    : Junho/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Novo procedimento que receberá a Cooperativa, Conta e ID do contrato 
                para detalhamento das informações de seguro vida contratado na conta.
                Este procedimento só será acionado para contratos armazenados nas 
                novas tabelas de seguros.

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Handle para a consulta dinâmica
      vr_ctx DBMS_XMLGEN.ctxHandle;
      vr_xml_benefici XMLTYPE;
      vr_xmldata CLOB;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      
      gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_SEGURO');
      
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_xmlseguro
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      -- Se encontrar erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      /* Montando a Query pai */
      vr_ctx := 
             dbms_xmlgen.newcontext(' SELECT segNov.nmsegurado AS "nmSegurado"
                                            ,decode(segNov.tpseguro,''C'',''CASA''
                                                                   ,''A'',''AUTO''
                                                                   ,''V'',''VIDA''
                                                                   ,''G'',''VIDA''
                                                                   ,''P'',''PRST'',''    '') AS "dsTpSeguro"
                                            ,csg.nmresseg AS "nmSeguradora"                       
                                            ,to_char(segNov.dtinicio_vigencia,''dd/mm/rrrr'')  AS "dtIniVigen"
                                            ,to_char(segNov.dttermino_vigencia,''dd/mm/rrrr'') AS "dtFimVigen"
                                            ,ltrim(gene0002.fn_mask(segNov.nrproposta,''zzzzz.zz9'')) AS "nrProposta"
                                            ,ltrim(gene0002.fn_mask(segNov.nrapolice,''zzzzz.zz9''))  AS "nrApolice"
                                            ,ltrim(gene0002.fn_mask(segNov.nrendosso,''zzzzz.zz9''))  AS "nrEndosso"
                                            ,segNov.dsplano AS "dsPlano"
                                            ,to_char(segNov.Vlcapital,''fm999g999g990d00'') AS "vlCapital"
                                            ,ltrim(gene0002.fn_mask(segNov.nrapolice_renovacao,''zzzzz.zz9''))  AS "nrApoliceRenova"
                                            ,to_char(segNov.vlpremio_liquido,''fm999g999g990d00'') AS "vlPremioLiquido"
                                            ,to_char(segNov.qtparcelas,''fm999g999g990'') AS "qtParcelas"
                                            ,to_char(segNov.vlpremio_total,''fm999g999g990d00'') AS "vlPremioTotal"
                                            ,to_char(segNov.vlparcela,''fm999g999g990d00'') AS "vlParcela"
                                            ,segNov.nrdiadebito AS "ddMelhorDia"
                                            ,to_char(segNov.percomissao,''fm990d00'')  AS "perComissao"
                                            ,segNov.dsobservacao AS "dsObservacoes"
                                        FROM tbseg_contratos segNov
                                            ,crapcsg         csg
                                       WHERE segNov.cdcooper   = csg.cdcooper
                                         AND segNov.cdsegura   = csg.cdsegura
                                         AND segNov.cdcooper   = '||vr_cdcooper||'
                                         AND segNov.nrdconta   = '||pr_nrdconta||'
                                         AND segNov.idcontrato = '||pr_idcontrato);
      dbms_xmlgen.setRowSetTag(vr_ctx, NULL);
      dbms_xmlgen.setrowtag(vr_ctx, 'Contrato');
      
      /* Enfim efetua a Query e gera o XML com as informações do contrado */
           
      /* Retornar o XML montado no parâmetro de saída CLOB */
      vr_xmldata := dbms_xmlgen.getXML(ctx => vr_ctx);
      IF vr_xmldata IS NOT NULL THEN
        vr_xmldata := replace(vr_xmldata,'version="1.0"','version="1.0" encoding="ISO-8859-1"');
        pr_xmlseguro := XMLType.createXML(vr_xmldata);
      ELSE
        pr_xmlseguro := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Contratos/>');
      END IF;

      gene0007.pc_insere_tag(pr_xml => pr_xmlseguro, pr_tag_pai => 'Contrato', pr_posicao => 0, pr_tag_nova => 'Beneficiarios', pr_tag_cont => '', pr_des_erro => pr_des_erro);
      
      /* Somente se encontrou registros */
      IF dbms_xmlgen.getNumRowsProcessed(vr_ctx) > 0 THEN
        
        /* Adicionando os beneficiários */
        vr_ctx := 
               dbms_xmlgen.newcontext(' SELECT segBen.nmbenefici AS "nmBenefici"
                                              ,to_char(segBen.dtnascimento,''dd/mm/rrrr'') AS "dtNascimento"
                                              ,decode(segBen.dsgrau_parente,''F'',''FILHO(A)'',''P'',''PAIS'',''C'',''CONJUGE'',''OUTROS'') AS "dsGrauParente"
                                              ,to_char(segBen.perparticipacao,''fm990d00'')  AS "perParticipa"
                                          FROM tbseg_vida_benefici segBen
                                         WHERE segBen.idcontrato = '||pr_idcontrato);
        dbms_xmlgen.setRowSetTag(vr_ctx, NULL);
        dbms_xmlgen.setrowtag(vr_ctx, 'Benef');
        
        vr_xml_benefici := dbms_xmlgen.getxmlType(vr_ctx);
        
        /* Somente se encontrou registros */
        IF dbms_xmlgen.getNumRowsProcessed(vr_ctx) > 0 THEN
        
          /* Adicionaremos aos beneficiarios ao XML do Contrato */
          pr_xmlseguro := XmlType.appendChildXML(pr_xmlseguro
                                                ,'/Contrato/Beneficiarios'
                                                ,vr_xml_benefici);
        END IF;

      END IF;
       
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_SEGURO - pc_detalha_seguro_vida: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_xmlseguro := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATENDA_SEGURO - pc_detalha_seguro_vida: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_xmlseguro := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_detalha_seguro_vida;  


  /* Detalhamento das informações de seguro AUTO contratado na conta */
  PROCEDURE pc_detalha_seguro_auto(pr_nrdconta   IN crapceb.nrdconta%TYPE --> Número da conta solicitada;
                                  ,pr_idcontrato IN crapceb.nrconven%TYPE --> ID Do contrato a detalhar
                                  ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                  ,pr_xmlseguro IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                  ,pr_des_erro  OUT VARCHAR2) IS          --Saida OK/NOK                           
  BEGIN

    /* .............................................................................

    Programa: pc_detalha_seguro_auto
    Sistema : Ayllos Web
    Autor   : Guilherme/SUPERO
    Data    : Junho/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Novo procedimento que receberá a Cooperativa, Conta e ID do contrato 
                para detalhamento das informações de seguro auto contratado na conta.
                Este procedimento só será acionado para contratos armazenados nas 
                novas tabelas de seguros.

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Variavel de criticas
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Handle para a consulta dinâmica
      vr_ctx DBMS_XMLGEN.ctxHandle;
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_xmlseguro
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      -- Se encontrar erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      /* Montando a Query pai */
      vr_ctx := 
             dbms_xmlgen.newcontext(' SELECT segNov.nmsegurado                                        AS "nmSegurado"
                                            ,''AUTOMOVEL''                                            AS "dsTpSeguro"
                                            ,UPPER(gene0007.fn_caract_acento(csg.nmsegura))           AS "nmSeguradora"                       
                                            ,to_char(segNov.dtinicio_vigencia,''dd/mm/rrrr'')         AS "dtIniVigen"
                                            ,to_char(segNov.dttermino_vigencia,''dd/mm/rrrr'')        AS "dtFimVigen"
                                            ,ltrim(segNov.nrproposta)                                 AS "nrProposta"
                                            ,ltrim(segNov.nrapolice)                                  AS "nrApolice"
                                            ,ltrim(segNov.nrendosso)                                  AS "nrEndosso"
                                            ,NVL(gene0007.fn_caract_acento(tipsub.dsendosso),'' '')   AS "dsEndosso"
                                            ,NVL(gene0007.fn_caract_acento(tipsub.dssub_endosso),'' '') AS "dsSubEndosso"

                                            ,UPPER(gene0007.fn_caract_acento(auto.nmmarca))           AS "nmMarca"
                                            ,UPPER(gene0007.fn_caract_acento(auto.dsmodelo))          AS "nmModelo"
                                            ,auto.nrano_fabrica                                       AS "nrAnoFab"
                                            ,auto.nrano_modelo                                        AS "nrAnoMod"
                                            ,auto.dsplaca                                             AS "dsPlaca"
                                            ,auto.dschassi                                            AS "dsChassi"
                                            ,to_char(auto.vlfranquia,''fm999g999g990d00'',''NLS_NUMERIC_CHARACTERS=,.'') AS "vlFranquia"

                                            ,to_char(segNov.vlpremio_liquido,''fm999g999g990d00'',''NLS_NUMERIC_CHARACTERS=,.'')    AS "vlPremioLiquido"
                                            ,to_char(segNov.vlpremio_total,''fm999g999g990d00'',''NLS_NUMERIC_CHARACTERS=,.'')      AS "vlPremioTotal"
                                            ,to_char(segNov.qtparcelas,''fm999g999g990'')             AS "qtParcelas"
                                            ,to_char(segNov.vlparcela,''fm999g999g990d00'',''NLS_NUMERIC_CHARACTERS=,.'')           AS "vlParcela"
                                            ,segNov.nrdiadebito                                       AS "ddMelhorDia"
                                            ,to_char(segNov.percomissao,''fm990d00'',''NLS_NUMERIC_CHARACTERS=,.'')                 AS "perComissao"
                                        FROM tbseg_contratos segNov
                                            ,crapcsg         csg
                                            ,tbseg_auto_veiculos auto
                                            ,tbseg_tipos_endosso tipsub
                                       WHERE csg.cdcooper         = 1
                                         AND csg.cdsegura         = segNov.cdsegura
                                         AND segNov.cdcooper      = '||vr_cdcooper||'
                                         AND segNov.nrdconta      = '||pr_nrdconta||'
                                         AND segNov.idcontrato    = '||pr_idcontrato ||'
                                         AND segNov.tpseguro      = ''A''
                                         AND segNov.idcontrato    = auto.idcontrato
                                         AND segNov.tpendosso     = tipsub.tpendosso(+)
                                         AND segNov.tpsub_endosso = tipsub.tpsub_endosso(+)');
      dbms_xmlgen.setRowSetTag(vr_ctx, NULL);
      dbms_xmlgen.setrowtag(vr_ctx, 'Contrato');
      
      /* Enfim efetua a Query e gera o XML com as informações do contrado */
      pr_xmlseguro := dbms_xmlgen.getXMLType(vr_ctx);

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_SEGURO - pc_detalha_seguro_auto: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_xmlseguro := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATENDA_SEGURO - pc_detalha_seguro_auto: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_xmlseguro := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_detalha_seguro_auto;  
  
  /* Detalhamento das informações de seguro CASA contratado via SIGAS */
  PROCEDURE pc_detalha_seguro_casa_sigas(pr_nrdconta   IN crapass.nrdconta%TYPE --> Número da conta solicitada;
                                        ,pr_cdcooper   IN crapass.cdcooper%TYPE --> ID Do contrato a detalhar
                                        ,pr_idcontrato IN tbseg_producao_sigas.id%TYPE   --> Id contrato
                                        ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                        ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                        ,pr_xmlseguro IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                        ,pr_des_erro  OUT VARCHAR2) IS          --Saida OK/NOK                           
  BEGIN

    /* .............................................................................

    Programa: pc_detalha_seguro_casa_sigas
    Sistema : Ayllos Web
    Autor   : Darlei Fernando Zillmer (Supero)
    Data    : Julho/2019                 Ultima atualizacao: 08/07/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Novo procedimento para detalhamento das informações de seguro casa
                contratado via SIGAS para a conta.
                Este procedimento só será usado para contratos armazenados nas 
                novas tabelas de seguros SIGAS.

    Alteracoes: 08/07/2019 - Alterada para retornar detalhes dos seguros sigas.
                             (Darlei Zillmer / Supero)
    ..............................................................................*/

    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Handle para a consulta dinâmica
      vr_ctx DBMS_XMLGEN.ctxHandle;
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_xmlseguro
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      -- Se encontrar erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      /* Montando a Query pai */
      vr_ctx := 
             dbms_xmlgen.newcontext('SELECT segpro.nmsegurado                   segurado
                                           ,segpro.tpproposta                   tpseguro
                                           ,segpro.id                           cdidsegp
                                           ,segpro.cdseguradora                 cdresseg
                                           ,segpro.nmseguradora                 nmresseg
                                           ,to_char(segpro.dtinicio_vigencia, ''dd/mm/rrrr'')            dtinivig
                                           ,to_char(segpro.dtfim_vigencia, ''dd/mm/rrrr'')               dtfimvig
                                           ,segpro.nrproposta                   nrproposta
                                           ,segpro.nrapolice_certificado        nrapolice
                                           ,segpro.nrendosso                    nrendosso
                                           ,segpro.nmproduto                    dsplano
                                           ,(SELECT dsvalor 
                                               FROM tbseg_bens_sigas s
                                              WHERE s.cdtipo = ''CodigoTipoImovel''
                                                AND s.id = segpro.id)         dsmoradia
                                           ,(SELECT dsvalor 
                                               FROM tbseg_bens_sigas s
                                              WHERE s.cdtipo = ''CodigoLogradouro''
                                                AND s.id = segpro.id)         dsendres
                                           ,(SELECT dsvalor 
                                               FROM tbseg_bens_sigas s
                                              WHERE s.cdtipo = ''CodigoNumero''
                                                AND s.id = segpro.id)         nrendere
                                           ,(SELECT dsvalor 
                                               FROM tbseg_bens_sigas s
                                              WHERE s.cdtipo = ''CodigoComplemento''
                                                AND s.id = segpro.id)         complend
                                           ,(SELECT dsvalor 
                                               FROM tbseg_bens_sigas s
                                              WHERE s.cdtipo = ''CodigoBairro''
                                                AND s.id = segpro.id)         nmbairro
                                           ,(SELECT dsvalor 
                                               FROM tbseg_bens_sigas s
                                              WHERE s.cdtipo = ''CodigoCidade''
                                                AND s.id = segpro.id)         nmcidade
                                           ,(SELECT dsvalor 
                                               FROM tbseg_bens_sigas s
                                              WHERE s.cdtipo = ''CodigoUF''
                                                AND s.id = segpro.id)         cdufresd
                                           ,to_char(segpro.vlpremio_liquido,''fm999G999G999G999D00'',''NLS_NUMERIC_CHARACTERS=,.'')               nrpreliq
                                           ,to_char(segpro.vlpremio_bruto,''fm999G999G999G999D00'',''NLS_NUMERIC_CHARACTERS=,.'')                 nrpretot
                                           ,segpro.dsparcelamento               nrqtparce
                                           ,''''                                nrvalparc
                                           ,''''                                nrmdiaven
                                           ,to_char(segpro.vlpercentual_comissao,''fm999G999G999G999D00'',''NLS_NUMERIC_CHARACTERS=,.'')          nrpercomi
                                           ,segpro.nrcpf_cnpj                   dscdsegu
                                       FROM tbseg_producao_sigas segpro, crapass ass
                                     WHERE segpro.cden2 = '||pr_cdcooper||'
                                       AND segpro.nrdconta = ass.nrdconta
                                       AND ass.nrdconta = '||pr_nrdconta||'
                                       AND segpro.id = '||pr_idcontrato||'
                                ');
      dbms_xmlgen.setRowSetTag(vr_ctx, NULL);
      dbms_xmlgen.setrowtag(vr_ctx, 'Contrato');
      
      /* Enfim efetua a Query e gera o XML com as informações do contrado */
      pr_xmlseguro := dbms_xmlgen.getXMLType(vr_ctx);

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_SEGURO - pc_detalha_seguro_casa_sigas: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_xmlseguro := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATENDA_SEGURO - pc_detalha_seguro_casa_sigas: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_xmlseguro := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_detalha_seguro_casa_sigas;  

  PROCEDURE pc_cancela_seguro_casa_sigas(pr_cdidsegp   IN VARCHAR2              --> Apolice
                                        ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Número da conta solicitada;
                                        ,pr_xmllog     IN VARCHAR2              --XML com informações de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER           --Código da crítica
                                        ,pr_dscritic  OUT VARCHAR2              --Descrição da crítica
                                        ,pr_xmlseguro IN OUT NOCOPY XMLType     --Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2              --Nome do Campo
                                        ,pr_des_erro  OUT VARCHAR2) IS          --Saida OK/NOK                           
  BEGIN

    /* .............................................................................

    Programa: pc_cancela_seguro_casa_sigas
    Sistema : Ayllos Web
    Autor   : Darlei Fernando Zillmer (Supero)
    Data    : Julho/2019                 Ultima atualizacao: 15/07/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Altera status do contrato sigas

    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Handle para a consulta dinâmica
      vr_ctx DBMS_XMLGEN.ctxHandle;
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      UPDATE tbseg_producao_sigas 
         SET tpproposta = 'CANCELAMENTO' 
       WHERE id = pr_cdidsegp;
      commit;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_SEGURO - pc_detalha_seguro_casa_sigas: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_xmlseguro := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        rollback;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_ATENDA_SEGURO - pc_detalha_seguro_casa_sigas: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_xmlseguro := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        rollback;
    END;
  END pc_cancela_seguro_casa_sigas;

END TELA_ATENDA_SEGURO;
/
