CREATE OR REPLACE PACKAGE CECRED.empr0013 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0013
  --  Sistema  : Rotinas focando nas funcionalidades de empréstimos consignados
  --  Sigla    : EMPR
  --  Autor    : Paulo Penteado
  --  Data     : Fevereiro/2018.                   Ultima atualizacao: 14/02/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genéricas dos sistemas Oracle
  --
  -- Alteração :
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Tipo com as informacoes do registro de consignado */
  TYPE typ_reg_dados_consignado IS RECORD(
     idcontrato_cons   NUMBER(10)
    ,nrctremp          NUMBER(10)
    ,nrdconta          NUMBER(10)
    ,cdcooper          NUMBER(10)
    ,dtmovimento       DATE
    ,vlfinanciado      NUMBER(25,2)
    ,qtparcelas        NUMBER(5)
    ,vlparcela         NUMBER(25,2)
    ,pecet_operacao    NUMBER(6,2)
    ,cdoperad          VARCHAR2(10)
    ,inrisco_calulado  NUMBER(5)
    ,inrisco_proposta  NUMBER(5)
    ,dtvencto_operacao DATE
    ,vljuros_atrazo_60 NUMBER(25,2)
    ,vldivida_060      NUMBER(25,2)
    ,vldivida_180      NUMBER(25,2)
    ,vldivida_360      NUMBER(25,2)
    ,vldivida_999      NUMBER(25,2)
    ,vlvencer_180      NUMBER(25,2)
    ,vlvencer_360      NUMBER(25,2)
    ,vlvencer_999      NUMBER(25,2)
    ,vldivida_total    NUMBER(25,2)
    ,vlprox_parcela    NUMBER(25,2)
    ,dtprox_parcela    DATE
    ,dsproduto         VARCHAR2(1000)
    ,dstipocontrato    VARCHAR2(1000)
    ,vlprestacao       VARCHAR2(1)
    ,inpr              VARCHAR2(1)
    ,inlcr             VARCHAR2(1)
    ,dssitest          VARCHAR2(1)
    ,dssitapr          VARCHAR2(1));

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_dados_consignado IS TABLE OF typ_reg_dados_consignado INDEX BY VARCHAR2(100);


  

  /* Procedure para obter dados de emprestimos consignado do associado */
  PROCEDURE pc_obtem_dados_consignado(pr_nrdconta         IN  crapass.nrdconta%TYPE    --> Conta do associado
                                     ,pr_qtregist         OUT INTEGER                  --> Qtde total de registros
                                     ,pr_tab_dados_consig OUT typ_tab_dados_consignado --> Saida com os dados do emprestimo
                                     ,pr_des_reto         OUT VARCHAR                  --> Retorno OK / NOK
                                     ,pr_tab_erro         OUT gene0001.typ_tab_erro    --> Tabela com possives erros
                                     );

  PROCEDURE pc_obtem_dados_consignado_web(pr_nrdconta IN  crapass.nrdconta%TYPE --> Conta do associado
                                         ,pr_xmllog   IN  VARCHAR2              --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                         ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);






  PROCEDURE pc_obtem_emprestimos_selecion(pr_cdcooper  IN crawepr.cdcooper%TYPE, --> Codigo da cooperativa
                                          pr_cdagenci  IN crapage.cdagenci%TYPE,    --> Codigo da agencia                                          
                                          pr_nrdcaixa  IN INTEGER,                  --> Número do caixa 
                                          pr_cdoperad  IN crapope.cdoperad%TYPE,    --> codigo do operador
                                          pr_nmdatela  IN VARCHAR2,                  --> Nome da tela
                                          pr_cdorigem  IN INTEGER,                  --> Origem da operacao
                                          pr_nrdconta  IN crawepr.nrdconta%TYPE,    --> Numero da conta do cooperado
                                          pr_idseqttl  IN INTEGER,                   --> Sequêncial do titular
                                          pr_flgerlog  IN VARCHAR2,                  --> Identificador se deve gerar log S-Sim e N-Nao
                                          pr_dsctrliq  IN VARCHAR2,                  --> Lista de descrições de situação dos contratos
                                          pr_cdlcremp  IN INTEGER,                   --> Linha de crédito do empréstimo
                                          pr_nrctremp  IN crawepr.nrctremp%TYPE,    --> Numero da proposta de emprestimo atual/antigo
                                          --> OUT 
                                          -- pr_tab_dados_epr IN typ_tab_dados_epr,     --> Dados do empréstimo
                                          pr_tab_erro  IN gene0001.typ_tab_erro     --> Tabela com possíveis erros
                                          );

  
  PROCEDURE pc_obtem_dados_liquidacoes(pr_cdcooper  IN crawepr.cdcooper%TYPE,    --> Codigo da cooperativa
                                      pr_cdagenci  IN crapage.cdagenci%TYPE,    --> Codigo da agencia  
                                      pr_nrdcaixa  IN INTEGER,                  --> Número do caixa 
                                      pr_cdoperad  IN crapope.cdoperad%TYPE,    --> codigo do operador
                                      pr_nmdatela  IN VARCHAR2,                  --> Nome da tela
                                      pr_idorigem  IN INTEGER,                  --> Identificação da origem
                                      pr_nrdconta  IN crawepr.nrdconta%TYPE,    --> Numero da conta do cooperado
                                      pr_idseqttl  IN INTEGER,                   --> Sequêncial do titular
                                      pr_flgerlog  IN VARCHAR2,                  --> Identificador se deve gerar log S-Sim e N-Nao
                                      pr_dsctrliq  IN VARCHAR2,                  --> Lista de descrições de situação dos contratos
                                      pr_cdlcremp  IN INTEGER,                   --> Linha de crédito do empréstimo
                                      pr_nrctremp  IN crawepr.nrctremp%TYPE,    --> Numero da proposta de emprestimo atual/antigo
                                      pr_dtcalcul	 IN DATE,		                  -->Data solicitada do calculo
                                      pr_cdprogra	 IN VARCHAR2,                  -->Programa conectado
                                      --> OUT
                                      pr_retxml   IN  OUT NOCOPY XMLType,        --> Arquivo de retorno do XML
                                      pr_cdcritic OUT NUMBER,                   --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2                --> Descricao da critica.                                    
                                    );


END empr0013;
/
CREATE OR REPLACE PACKAGE BODY CECRED.empr0013 as

  /* Tratamento de erro */
  vr_des_erro VARCHAR2(4000);
  vr_exc_erro EXCEPTION;

  /* Descrição e código da critica */
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);

  /* Erro em chamadas da pc_gera_erro */
  vr_des_reto VARCHAR2(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  /* Procedure para obter dados de emprestimos consignado do associado */
  PROCEDURE pc_obtem_dados_consignado(pr_nrdconta         IN  crapass.nrdconta%TYPE    --> Conta do associado
                                     ,pr_qtregist         OUT INTEGER                  --> Qtde total de registros
                                     ,pr_tab_dados_consig OUT typ_tab_dados_consignado --> Saida com os dados do emprestimo
                                     ,pr_des_reto         OUT VARCHAR                  --> Retorno OK / NOK
                                     ,pr_tab_erro         OUT gene0001.typ_tab_erro    --> Tabela com possives erros
                                     ) is
  /*.............................................................................
       Programa: pc_obtem_dados_consignado
       Sistema :
       Sigla   : CRED
       Autor   : Paulo Penteado
       Data    : Fevereio/2018                         Ultima atualizacao: 01/02/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Procedure para obter dados de emprestimos consignado do associado

       Alteracoes:  01/02/2018 Criacao (Paulo Penteado)
  ............................................................................. */

  vr_idtabconsig number;

  cursor cr_consig is
  select consig.idcontrato_cons
       , consig.nrctremp
       , consig.nrdconta
       , consig.cdcooper
       , consig.dtmovimento
       , consig.vlfinanciado
       , consig.qtparcelas
       , consig.vlparcela
       , consig.pecet_operacao
       , consig.cdoperad
       , consig.inrisco_calulado
       , consig.inrisco_proposta
       , consig.dtvencto_operacao
       , consig.vljuros_atrazo_60
       , consig.vldivida_060
       , consig.vldivida_180
       , consig.vldivida_360
       , consig.vldivida_999
       , consig.vlvencer_180
       , consig.vlvencer_360
       , consig.vlvencer_999
       , consig.vldivida_total
       , consig.vlprox_parcela
       , consig.dtprox_parcela
       , 'PRIVE PRE-FIXADO' dsproduto
       , 'Emp. Consignado' dstipocontrato
       , '-' vlprestacao
       , '-' inpr
       , '-' inlcr
       , '-' dssitest
       , '-' dssitapr
  from   tbepr_consignado_contrato consig
  where  consig.nrdconta = pr_nrdconta;
  rw_consig cr_consig%rowtype;

  BEGIN
     open  cr_consig;
     loop
           fetch cr_consig into rw_consig;
           exit  when cr_consig%notfound;

           vr_idtabconsig := pr_tab_dados_consig.COUNT + 1;

           pr_tab_dados_consig(vr_idtabconsig).idcontrato_cons   := rw_consig.idcontrato_cons;
           pr_tab_dados_consig(vr_idtabconsig).nrctremp          := rw_consig.nrctremp;
           pr_tab_dados_consig(vr_idtabconsig).nrdconta          := rw_consig.nrdconta;
           pr_tab_dados_consig(vr_idtabconsig).cdcooper          := rw_consig.cdcooper;
           pr_tab_dados_consig(vr_idtabconsig).dtmovimento       := rw_consig.dtmovimento;
           pr_tab_dados_consig(vr_idtabconsig).vlfinanciado      := rw_consig.vlfinanciado;
           pr_tab_dados_consig(vr_idtabconsig).qtparcelas        := rw_consig.qtparcelas;
           pr_tab_dados_consig(vr_idtabconsig).vlparcela         := rw_consig.vlparcela;
           pr_tab_dados_consig(vr_idtabconsig).pecet_operacao    := rw_consig.pecet_operacao;
           pr_tab_dados_consig(vr_idtabconsig).cdoperad          := rw_consig.cdoperad;
           pr_tab_dados_consig(vr_idtabconsig).inrisco_calulado  := rw_consig.inrisco_calulado;
           pr_tab_dados_consig(vr_idtabconsig).inrisco_proposta  := rw_consig.inrisco_proposta;
           pr_tab_dados_consig(vr_idtabconsig).dtvencto_operacao := rw_consig.dtvencto_operacao;
           pr_tab_dados_consig(vr_idtabconsig).vljuros_atrazo_60 := rw_consig.vljuros_atrazo_60;
           pr_tab_dados_consig(vr_idtabconsig).vldivida_060      := rw_consig.vldivida_060;
           pr_tab_dados_consig(vr_idtabconsig).vldivida_180      := rw_consig.vldivida_180;
           pr_tab_dados_consig(vr_idtabconsig).vldivida_360      := rw_consig.vldivida_360;
           pr_tab_dados_consig(vr_idtabconsig).vldivida_999      := rw_consig.vldivida_999;
           pr_tab_dados_consig(vr_idtabconsig).vlvencer_180      := rw_consig.vlvencer_180;
           pr_tab_dados_consig(vr_idtabconsig).vlvencer_360      := rw_consig.vlvencer_360;
           pr_tab_dados_consig(vr_idtabconsig).vlvencer_999      := rw_consig.vlvencer_999;
           pr_tab_dados_consig(vr_idtabconsig).vldivida_total    := rw_consig.vldivida_total;
           pr_tab_dados_consig(vr_idtabconsig).vlprox_parcela    := rw_consig.vlprox_parcela;
           pr_tab_dados_consig(vr_idtabconsig).dtprox_parcela    := rw_consig.dtprox_parcela;
           pr_tab_dados_consig(vr_idtabconsig).dsproduto         := rw_consig.dsproduto;
           pr_tab_dados_consig(vr_idtabconsig).dstipocontrato    := rw_consig.dstipocontrato;
           pr_tab_dados_consig(vr_idtabconsig).vlprestacao       := rw_consig.vlprestacao;
           pr_tab_dados_consig(vr_idtabconsig).inpr              := rw_consig.inpr;
           pr_tab_dados_consig(vr_idtabconsig).inlcr             := rw_consig.inlcr;
           pr_tab_dados_consig(vr_idtabconsig).dssitest          := rw_consig.dssitest;
           pr_tab_dados_consig(vr_idtabconsig).dssitapr          := rw_consig.dssitapr;
     end   loop;
  EXCEPTION
     WHEN OTHERS THEN
          -- Retorno não OK
          pr_des_reto := 'NOK';
          -- Montar descrição de erro não tratado
          vr_dscritic := 'Erro não tratado na EMPR0001.pc_obtem_dados_consignado --> ' ||sqlerrm;
  end pc_obtem_dados_consignado;

  PROCEDURE pc_obtem_dados_consignado_web(pr_nrdconta IN  crapass.nrdconta%TYPE --> Conta do associado
                                         ,pr_xmllog   IN  VARCHAR2              --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                         ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2
                                         ) is
  -- variaveis de retorno
  vr_tab_dados_consig typ_tab_dados_consignado;
  vr_tab_erro         gene0001.typ_tab_erro;
  vr_qtregist         NUMBER;

  -- Variaveis de entrada vindas no xml
  vr_cdcooper INTEGER;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);

  -- Variáveis para armazenar as informações em XML
  vr_des_xml        CLOB;
  vr_texto_completo VARCHAR2(32600);
  vr_index          VARCHAR2(100);

  PROCEDURE pc_escreve_xml( pr_des_dados IN VARCHAR2
                          , pr_fecha_xml IN BOOLEAN DEFAULT FALSE
                          ) IS
  BEGIN
      gene0002.pc_escreve_xml( vr_des_xml
                             , vr_texto_completo
                             , pr_des_dados
                             , pr_fecha_xml );
  END;

  begin
    gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                            , pr_cdcooper => vr_cdcooper
                            , pr_nmdatela => vr_nmdatela
                            , pr_nmeacao  => vr_nmeacao
                            , pr_cdagenci => vr_cdagenci
                            , pr_nrdcaixa => vr_nrdcaixa
                            , pr_idorigem => vr_idorigem
                            , pr_cdoperad => vr_cdoperad
                            , pr_dscritic => vr_dscritic);

    pc_obtem_dados_consignado( pr_nrdconta
                             , vr_qtregist
                             , vr_tab_dados_consig
                             , vr_des_reto
                             , vr_tab_erro);

    if  vr_des_reto = 'NOK' then
        if  vr_tab_erro.exists(vr_tab_erro.first) then
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        else
            vr_dscritic := 'Não foi possivel obter dados de consignado.';
        end if;

        raise vr_exc_erro;
    end if;

    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;

    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                   '<Root><Dados qtregist="' || vr_qtregist ||'" >');

    -- ler os registros de consignado e incluir no xml
    vr_index := vr_tab_dados_consig.first;
    while vr_index IS NOT NULL loop
          pc_escreve_xml('<inf>'||
                         '<dtmvtolt>'|| to_char(vr_tab_dados_consig(vr_index).dtmovimento,'DD/MM/RRRR') ||'</dtmvtolt>'||
                         '<nrctremp>'|| vr_tab_dados_consig(vr_index).nrctremp    ||'</nrctremp>'||
                         '<vlemprst>'|| vr_tab_dados_consig(vr_index).vlprestacao ||'</vlemprst>'||
                         '<vlpreemp>'|| vr_tab_dados_consig(vr_index).vlprestacao ||'</vlpreemp>'||
                         '<qtpreemp>'|| vr_tab_dados_consig(vr_index).vlprestacao ||'</qtpreemp>'||
                         '<cdlcremp>'|| vr_tab_dados_consig(vr_index).inpr        ||'</cdlcremp>'||
                         '<cdfinemp>'|| vr_tab_dados_consig(vr_index).inlcr       ||'</cdfinemp>'||
                         '<cdoperad>'|| vr_tab_dados_consig(vr_index).cdoperad    ||'</cdoperad>'||
                         '<dssitest>'|| vr_tab_dados_consig(vr_index).dssitest    ||'</dssitest>'||
                         '<dssitapr>'|| vr_tab_dados_consig(vr_index).dssitapr    ||'</dssitapr>'||
                         '</inf>'
                        );
        -- buscar proximo
        vr_index := vr_tab_dados_consig.next(vr_index);
    end loop;

    pc_escreve_xml ('</Dados></Root>',TRUE);

    pr_retxml := XMLType.createXML(vr_des_xml);

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
  EXCEPTION
    WHEN vr_exc_erro THEN
         -- Se foi retornado apenas código
         IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             -- Buscar a descrição
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         --Variavel de erro recebe erro ocorrido
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
         -- Montar descrição de erro não tratado
         pr_dscritic := 'Erro não tratado na EMPR0001.pc_obtem_dados_consignado_web ' ||SQLERRM;
  end;


  PROCEDURE pc_obtem_dados_liquidacoes(
                                       pr_cdcooper  IN crawepr.cdcooper%TYPE,    --> Codigo da cooperativa
                                       pr_cdagenci  IN crapage.cdagenci%TYPE,    --> Codigo da agencia  
                                       pr_nrdcaixa  IN INTEGER,                  --> Número do caixa 
                                       pr_cdoperad  IN crapope.cdoperad%TYPE,    --> codigo do operador
                                       pr_nmdatela  IN VARCHAR2,                  --> Nome da tela
                                       pr_idorigem  IN INTEGER,                  --> Identificação da origem
                                       pr_nrdconta  IN crawepr.nrdconta%TYPE,    --> Numero da conta do cooperado
                                       pr_idseqttl  IN INTEGER,                   --> Sequêncial do titular
                                       pr_flgerlog  IN VARCHAR2,                  --> Identificador se deve gerar log S-Sim e N-Nao
                                       pr_dsctrliq  IN VARCHAR2,                  --> Lista de descrições de situação dos contratos
                                       pr_cdlcremp  IN INTEGER,                   --> Linha de crédito do empréstimo
                                       pr_nrctremp  IN crawepr.nrctremp%TYPE,    --> Numero da proposta de emprestimo atual/antigo
                                       pr_dtcalcul	 IN DATE,		                  -->Data solicitada do calculo
                                       pr_cdprogra	 IN VARCHAR2,                  -->Programa conectado
                                       --> OUT
                                       pr_retxml   IN  OUT NOCOPY XMLType,        --> Arquivo de retorno do XML
                                       pr_cdcritic OUT NUMBER,                   --> Codigo da critica
                                       pr_dscritic OUT VARCHAR2                  --> Descricao da critica.                                    
                                       ) IS
  
/* DECLARAÇÃO DE CURSORES */




/* DECLARAÇÃO DE VARIAVEIS */
vr_cdcritic NUMBER := 0;                           --> Codigo da critica
vr_dscritic VARCHAR2 (100) :='';                   --> Descricao da critica.
-- variaveis de retorno
--vr_tab_dados_epr GENE0001.typ_tab_dados_epr;
vr_tab_erro      GENE0001.typ_tab_erro;
vr_qtregist      NUMBER;
--Variaveis para busca de parametros
vr_dstextab            craptab.dstextab%TYPE;
vr_dstextab_parempctl  craptab.dstextab%TYPE;
vr_dstextab_digitaliza craptab.dstextab%TYPE;
-- Variaveis de entrada vindas no xml
vr_cdcooper INTEGER;
vr_cdoperad VARCHAR2(100);
vr_nmdatela VARCHAR2(100);
vr_nmeacao  VARCHAR2(100);
vr_cdagenci VARCHAR2(100);
vr_nrdcaixa VARCHAR2(100);
vr_idorigem VARCHAR2(100);
--Indicador de utilização da tabela
vr_inusatab BOOLEAN;
-- Variáveis para armazenar as informações em XML
vr_des_xml         CLOB;
vr_texto_completo  VARCHAR2(32600);
vr_index           VARCHAR2(100);  

  BEGIN
    
    /* TESTAR PARÂMETROS DE ENTRADA */
    /* Verifica Codigo da cooperativa */
    IF pr_cdcooper IS NULL or pr_cdcooper = 0 THEN
       pr_cdcritic:=1143;
       pr_dscritic:='Cooperativa deve ser informada.';
       --pr_retxml:='';
       RETURN;
    END IF;
    /* Verifica  */
    IF pr_cdoperad IS NULL or pr_cdoperad = 0 THEN
       pr_cdcritic:=087;
       pr_dscritic:='Codigo do operador deve ser informado.';
       --pr_retxml:='';
       RETURN;
    END IF;
    /* Verifica  */
    IF pr_cdagenci IS NULL or pr_cdagenci = 0 THEN
       pr_cdcritic:=89;
       pr_dscritic:='Agencia devera ser informada.';
       --pr_retxml:='';
       RETURN;
    END IF;                                  
    /* Verifica  */
    IF pr_nrdconta IS NULL or pr_nrdconta = '' THEN
       pr_cdcritic:=1144;
       pr_dscritic:='Conta deve ser informada.';
       --pr_retxml:='';
       RETURN;
    END IF;   
    /* Verifica  */
    IF pr_nrctremp IS NULL or pr_nrctremp = 0 THEN
       pr_cdcritic:=1145;
       pr_dscritic:='Contrato deve ser informado.';
       --pr_retxml:='';
       RETURN;
    END IF;   
    /* Verifica  */
    IF pr_dtcalcul IS NULL THEN
       pr_cdcritic:=0;
       pr_dscritic:='';
       --pr_retxml:='';
       RETURN;
    END IF;   
    /* Verifica  */
    IF pr_cdprogra IS NULL or pr_cdprogra = '' THEN
       pr_cdcritic:=0;
       pr_dscritic:='';
       --pr_retxml:='';
       RETURN;
    END IF;   
    /* SE PARÂMETROS ESTIVER OK, ABRIR CURSOR */
    
    
    /* CHAMA PROCEDURE DE BUSCA DOS DADOS */
    /* 1.	Chama o procedimento empr0001.pc_obtem_dados_empresti para obter os dados do empréstimo */
    /* Procedure para obter dados de emprestimos do associado */

    empr0001.pc_obtem_dados_empresti(pr_cdcooper       => vr_cdcooper           --> Cooperativa conectada
                                     ,pr_cdagenci       => vr_cdagenci           --> Código da agência
                                     ,pr_nrdcaixa       => vr_nrdcaixa           --> Número do caixa
                                     ,pr_cdoperad       => vr_cdoperad           --> Código do operador
                                     ,pr_nmdatela       => vr_nmdatela           --> Nome datela conectada
                                     ,pr_idorigem       => vr_idorigem           --> Indicador da origem da chamada
                                     ,pr_nrdconta       => pr_nrdconta           --> Conta do associado
                                     ,pr_idseqttl       => pr_idseqttl           --> Sequencia de titularidade da conta
                                     ,pr_rw_crapdat     => rw_crapdat            --> Vetor com dados de parâmetro (CRAPDAT)
                                     ,pr_dtcalcul       => pr_dtcalcul           --> Data solicitada do calculo
                                     ,pr_nrctremp       => nvl(pr_nrctremp,0)    --> Número contrato empréstimo
                                     ,pr_cdprogra       => pr_cdprogra           --> Programa conectado
                                     ,pr_inusatab       => vr_inusatab     --> Indicador de utilização da tabela
                                     ,pr_flgerlog       => pr_flgerlog           --> Gerar log S/N
                                     --,pr_flgcondc       => (CASE pr_flgcondc     --> Mostrar emprestimos liquidados sem prejuizo
                                                              --WHEN 1 THEN TRUE
                                                              --ELSE FALSE END)
                                     --,pr_nmprimtl       => rw_crapass.nmprimtl   --> Nome Primeiro Titular
                                     ,pr_tab_parempctl  => vr_dstextab_parempctl --> Dados tabela parametro
                                     ,pr_tab_digitaliza => vr_dstextab_digitaliza--> Dados tabela parametro
                                     --,pr_nriniseq       => pr_nriniseq           --> Numero inicial da paginacao
                                     --,pr_nrregist       => pr_nrregist           --> Numero de registros por pagina
                                     ,pr_qtregist       => vr_qtregist           --> Qtde total de registros
                                     --,pr_tab_dados_epr  => vr_tab_dados_epr      --> Saida com os dados do empréstimo
                                     ,pr_des_reto       => vr_des_reto           --> Retorno OK / NOK
                                     ,pr_tab_erro       => vr_tab_erro);         --> Tabela com possíves erros

    /* ARMAZENA VALORES A SEREM TRATADOS */
    
    
    
    /* TESTA OCORRÊNCIA DE ERRO */                                   
    /* 2.	Se ocorrer algum erro, monta um xml com o conteúdo do erro. */
    
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        ELSE
          vr_dscritic := 'Não foi possivel obter dados de emprestimos.';
        END IF;
        RAISE vr_exc_erro;
      END IF;
    
    /* OBTEM OS DADOS DO EMPRÉSTIMO */
    /* 3.	Chama o procedimento empr0001.pc_obtem_empresti_selecionados para atualizar o conjunto de dados do empréstimo obtido na regra 1 */
    /* Pre-selecao das linhas do browse */
    pc_obtem_emprestimos_selecion ( aux_cdcooper => pr_cdcooper,          --> Cooperativa conectada
                                    aux_cdagenci => pr_cdagenci,           
                                    aux_nrdcaixa => pr_nrdcaixa,           
                                    aux_cdoperad => pr_cdoperad,
                                    aux_nmdatela => pr_nmdatela,
                                    aux_idorigem => pr_idorigem,           
                                    aux_nrdconta => pr_nrdconta,
                                    aux_idseqttl => pr_idseqttl,           
                                    TRUE,
                                    aux_dsctrliq => pr_dsctrliq,
                                    aux_cdlcremp => pr_cdlcremp,
                                    tt-dados-epr => vr_tab_dados_epr,     --> Saida com os dados do empréstimo
                                    tt-erro      => vr_tab_erro);         --> Tabela com possíves erros
      /* GERA LOG DE ANALISE DE ERRO */
      /* 4.	Se ocorrer algum erro, monta um xml com o conteúdo do erro. */
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
            
            /*
            
            GENE0001.pc_xml_tab_erro(pr_tab_erro   IN OUT GENE0001.typ_tab_erro, --> TempTable de erro
                                     pr_xml_erro   IN OUT CLOB,                  --> XML dos registros da temptable de erro
                                     pr_tipooper   IN INTEGER,                   --> Tipo de operação, 1 - Gerar XML, 2 --Gerar pltable
                                     pr_dscritic   OUT VARCHAR2) IS              --> descrição da critica do erro
            */
          
        ELSE
          
          vr_dscritic := 'Não foi possivel obter dados de emprestimos.';
        END IF;
        RAISE vr_exc_erro;
      END IF;
     /* ATUALIZA O XML */
     /* 5.	Se não ocorrer nenhum erro, monta o xml com os dados do empréstimo. */
     --ELSE 
     --   DO:
     --       RUN piXmlNew.
     --       RUN piXmlExport (INPUT TEMP-TABLE tt-dados-epr:HANDLE,
     --                        INPUT "Proposta").
     --       RUN piXmlSave.
     --   END.
     /* GERA LOG DE CONSULTA */
     
     
     /* TRATA AS EXCESSÕES */
--  EXCEPTION

  /*  FECHA A PROCEDURE */
  END pc_obtem_dados_liquidacoes;


  pc_obtem_emprestimos_selecion ( aux_cdcooper => pr_cdcooper,          --> Cooperativa conectada
                                  aux_cdagenci => pr_cdagenci,           
                                  aux_nrdcaixa => pr_nrdcaixa,           
                                  aux_cdoperad => pr_cdoperad,
                                  aux_nmdatela => pr_nmdatela,
                                  aux_idorigem => pr_idorigem,           
                                  aux_nrdconta => pr_nrdconta,
                                  aux_idseqttl => pr_idseqttl,           
                                  TRUE,
                                  aux_dsctrliq => pr_dsctrliq,
                                  aux_cdlcremp => pr_cdlcremp,
                                  tt-dados-epr => vr_tab_dados_epr,     --> Saida com os dados do empréstimo
                                  tt-erro      => vr_tab_erro)IS
                                      
                                      
                                      
  END pc_obtem_emprestimos_selecion;



END empr0013;
/
