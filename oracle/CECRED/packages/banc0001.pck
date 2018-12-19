CREATE OR REPLACE PACKAGE CECRED.BANC0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : BANC0001
  --  Sistema  : Rotinas genericas referente a BANCOS
  --  Sigla    : BANC
  --  Autor    : Jéssica Laverde Gracino (DB1)
  --  Data     : Junho - 2015.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a BANCOS

  -- Alteracoes: Incluido novos campos na tela: flgoppag, dtaltstr e dtaltpag. 
  --             PRJ-312 (Reinert)
  --
  ---------------------------------------------------------------------------------------------------------------

  --Tipo de Registros de bancos
  TYPE typ_reg_bancos IS RECORD
    (nmresbcc crapban.nmresbcc%TYPE 
    ,cdbccxlt crapban.cdbccxlt%TYPE 
    ,nrispbif crapban.nrispbif%TYPE 
    ,flgdispb crapban.flgdispb%TYPE);
    
  --Tipo de Tabela de bancos
  TYPE typ_tab_bancos IS TABLE OF typ_reg_bancos INDEX BY PLS_INTEGER;
  
  /* Rotina referente a consulta de bancos Modo Web */
  PROCEDURE pc_consulta_banco_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL           -->Data Movimento
                                 ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0 -->Código do Banco
                                 ,pr_nrispbif IN INTEGER DEFAULT 0               -->Numero do ISPB
                                 ,pr_cddopcao IN VARCHAR2 DEFAULT NULL           -->Codigo da opcao
                                 ,pr_xmllog   IN VARCHAR2 DEFAULT NULL           -->XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER                    -->Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                       -->Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType              -->Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2                       -->Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2);                     -->Saida OK/NOK

  /*\* Rotina referente a consulta de bancos Modo Caracter *\
  PROCEDURE pc_consulta_banco_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                 ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                 ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                 ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                 ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                 ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                                 ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0  -->Código do Banco
                                 ,pr_nrispbif IN INTEGER DEFAULT 0     --> número do ISPB
                                 ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --> código da opção
                                 ,pr_nmresbcc OUT VARCHAR2             --> nome do banco abreviado
                                 ,pr_nmextbcc OUT VARCHAR2             --> nome do banco por extenso
                                 ,pr_auxnrisp OUT INTEGER              --> parametro auxiliar caso informe somente o código do banco
                                 ,pr_auxcdbcc OUT INTEGER              --> parametro auxiliar caso informe somente o número do ISPB
                                 ,pr_flgdispb OUT VARCHAR2             --> operando no SPB
                                 ,pr_dtinispb OUT DATE                 --> inicio da operação
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                 ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                 ,pr_dscritic OUT VARCHAR2);           --> Descricao Erro
*/

  /* Rotina referente a inclusao de bancos Modo Caracter */
  /*PROCEDURE pc_inclui_banco_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                               ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                               ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                               ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                               ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                               ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                               ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0  -->Código do Banco
                               ,pr_nrispbif IN INTEGER DEFAULT 0     -->Numero do ISPB
                               ,pr_cddopcao IN VARCHAR2 DEFAULT NULL -->codigo da opção
                               ,pr_nmresbcc IN VARCHAR2              -->nome do banco abrevido
                               ,pr_nmextbcc IN VARCHAR2              -->nome do banco por extenso
                               ,pr_flgdispb IN VARCHAR2              -->operando no SPB
                               ,pr_dtinispb IN DATE                  -->inicio da operação
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                               ,pr_clob_ret OUT CLOB                 --Tabela XML                                 
                               ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                               ,pr_dscritic OUT VARCHAR2);           --Descricao Erro*/

  /* Rotina referente a inclusão de bancos Modo Web */
  PROCEDURE pc_inclui_banco_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL            -->Data Movimento
                               ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0  -->Código do Banco
                               ,pr_nrispbif IN INTEGER DEFAULT 0                -->Numero ISPB
                               ,pr_cddopcao IN VARCHAR2 DEFAULT NULL            -->Codigo da Opção                   
                               ,pr_nmresbcc IN VARCHAR2                         -->Nome do banco Abreviado
                               ,pr_nmextbcc IN VARCHAR2                         -->Nome do banco por extenso
                               ,pr_flgdispb IN INTEGER                          -->Operando no SPB-STR
                               ,pr_dtinispb IN VARCHAR2                         -->Inicio da operação
                               ,pr_flgoppag IN INTEGER                          -->Operando no SPB-PAG
                               ,pr_xmllog   IN VARCHAR2 DEFAULT NULL            -->XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                     -->Código da crítica
                               ,pr_dscritic OUT VARCHAR2                        -->Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType               -->Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                        -->Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);                      -->Saida OK/NOK

  /* Rotina referente a inclusao de bancos Modo Caracter */
  /*PROCEDURE pc_altera_banco_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                               ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                               ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                               ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                               ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                               ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                               ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0  -->Código do Banco
                               ,pr_nrispbif IN INTEGER DEFAULT 0     -->numero do ISPB
                               ,pr_cddopcao IN VARCHAR2 DEFAULT NULL -->codigo da opcao
                               ,pr_nmresbcc IN VARCHAR2              -->Nome do banco abreviado
                               ,pr_nmextbcc IN VARCHAR2              -->Nome do banco por extenso
                               ,pr_flgdispb IN VARCHAR2              -->Operando no spb
                               ,pr_dtinispb IN DATE              -->inicio da operacao
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                               ,pr_clob_ret OUT CLOB                 --Tabela XML                                 
                               ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                               ,pr_dscritic OUT VARCHAR2);           --Descricao Erro*/

  /* Rotina referente a alteração de bancos Modo Web */
  PROCEDURE pc_altera_banco_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL            -->Data Movimento
                               ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0  -->Código do Banco
                               ,pr_nrispbif IN INTEGER DEFAULT 0                -->Numero ISPB
                               ,pr_cddopcao IN VARCHAR2 DEFAULT NULL            -->Codigo da opcao                   
                               ,pr_nmresbcc IN VARCHAR2                         -->Nome do banco abreviado          
                               ,pr_nmextbcc IN VARCHAR2                         -->Nome do banco por extenso
                               ,pr_flgdispb IN INTEGER                         -->Operando no SPB-STR
                               ,pr_dtinispb IN VARCHAR2 DEFAULT NULL            -->Inicio da operacao
															 ,pr_flgoppag IN INTEGER                          -->Operando no SPB-PAG
                               ,pr_xmllog   IN VARCHAR2 DEFAULT NULL            -->XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                     -->Código da crítica
                               ,pr_dscritic OUT VARCHAR2                        -->Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType               -->Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                        -->Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);                      -->Saida OK/NOK
  
  /* Rotina referente a pesquisa de bancos Modo Caracter */
  /*PROCEDURE pc_pesquisa_banco_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                 ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                 ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                 ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                 ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                 ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                                                  
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                 ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                 ,pr_dscritic OUT VARCHAR2);           --> Descricao Erro*/

  /* Rotina referente a pesquisa de bancos Modo Web */
  PROCEDURE pc_pesquisa_banco_web(pr_cdbccxlt IN crapban.cdbccxlt%TYPE --Codigo do banco
                                 ,pr_nmresbcc IN VARCHAR2              --Nome do banco
                                 ,pr_nrispbif IN crapban.nrispbif%TYPE --Numero do SPB 
                                 ,pr_nrregist IN INTEGER               --Numero Registros
                                 ,pr_nriniseq IN INTEGER               --Numero Sequencia Inicial
                                 ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2);
                                 
  PROCEDURE pc_altera_cnpj_banco(pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0  -->Código do Banco
                               ,pr_nrispbif IN INTEGER DEFAULT 0                -->Numero ISPB
                               ,pr_nrcnpjif IN INTEGER                          -->CNPJ do Banco Participante da PCPS
                               ,pr_xmllog   IN VARCHAR2 DEFAULT NULL            -->XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                     -->Código da crítica
                               ,pr_dscritic OUT VARCHAR2                        -->Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType               -->Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                        -->Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);
                               
END BANC0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.BANC0001 AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: BANC0001
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Jéssica Laverde Gracino (DB1)
   Data    : 20/07/2015                        Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Consulta, Inclusão e Alteração de Banco.

   Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------*/

  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
  SELECT cop.cdcooper
        ,cop.nmrescop
        ,cop.nrtelura
        ,cop.cdbcoctl
        ,cop.cdagectl
        ,cop.dsdircop
    FROM crapcop cop
   WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Cursor generico de calendario
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  /* Rotina referente a consulta de bancos */
  PROCEDURE pc_consulta_banco(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                             ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                             ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                             ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                             ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                             ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                             ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0  -->Código do Banco
                             ,pr_nrispbif IN INTEGER DEFAULT 0 --> número do ISPB
                             ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --> código da opção
                             ,pr_nmresbcc OUT VARCHAR2    --> nome do banco abreviado
                             ,pr_nmextbcc OUT VARCHAR2    --> nome do banco por extenso
                             ,pr_auxnrisp OUT INTEGER     --> parametro auxiliar caso seja informado apenas o codigo do banco 
                             ,pr_auxcdbcc OUT INTEGER     --> parametro auxiliar caso seja informado apenas o numero do ISPB
                             ,pr_flgdispb OUT INTEGER    --> operando no SPB-STR
                             ,pr_dtinispb OUT DATE        --> Inicio da Operação
                             ,pr_flgoppag OUT INTEGER     --> operando no SPB-PAG
                             ,pr_nrcnpjif OUT INTEGER     --> CNPJ do Banco Participante da PCPS
                             ,pr_dtaltstr OUT DATE        --> Data última alteração do campo "Operando no SPB-STR"
                             ,pr_dtaltpag OUT DATE        --> Data última alteração do campo "Operando no SPB-PAG"
                             ,pr_cdcritic OUT PLS_INTEGER -->Código da crítica
                             ,pr_dscritic OUT VARCHAR2    -->Descrição da crítica
                             ,pr_nmdcampo OUT VARCHAR2    -->Nome do campo com erro														 
                             ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                             ,pr_des_erro OUT VARCHAR2) IS -->Erros do processo
     /*---------------------------------------------------------------------------------------------------------------
     Programa: pc_consulta_banco       Antiga: bancosc.i
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 23/06/2015                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Processar a rotina de consulta da tela BANCOS.

     Alteracoes: 23/06/2015 - Conversao Progress >> Oracle (PLSQL) - Jéssica (DB1)
    ---------------------------------------------------------------------------------------------------------------*/


    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Cursor para buscar o nome do banco
    CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
    SELECT substr(nmresbcc,1,15) nmresbcc
          ,crapban.cdbccxlt
          ,crapban.nmextbcc
          ,crapban.nrispbif
          ,crapban.flgdispb
          ,crapban.dtinispb
          ,crapban.flgoppag
          ,crapban.dtaltstr
          ,crapban.dtaltpag
          ,crapban.nrcnpjif
      FROM crapban
     WHERE crapban.cdbccxlt = pr_cdbccxlt;
    rw_crapban cr_crapban%ROWTYPE;

    -- Cursor para buscar o nome do banco
    CURSOR cr_crapban1(pr_nrispbif IN crapban.nrispbif%TYPE) IS
    SELECT substr(nmresbcc,1,15) nmresbcc
          ,crapban.cdbccxlt
          ,crapban.nmextbcc
          ,crapban.nrispbif
          ,crapban.flgdispb
          ,crapban.dtinispb
          ,crapban.flgoppag
          ,crapban.dtaltstr
          ,crapban.dtaltpag
          ,crapban.nrcnpjif
      FROM crapban
     WHERE crapban.nrispbif = pr_nrispbif;
    rw_crapban1 cr_crapban1%ROWTYPE;


    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    vr_retornvl  VARCHAR2(3):= 'NOK';
        
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;
    vr_exc_saida EXCEPTION;

    BEGIN

      --Inicializar Variaveis
      vr_cdcritic := 0;
      vr_dscritic := NULL;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);

      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN

        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;

        -- Montar mensagem de critica
        vr_cdcritic := 651;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);

       RAISE vr_exc_erro;

      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      
      IF pr_cdbccxlt <> 0 OR pr_nrispbif >= 0  THEN
        IF pr_cdbccxlt <> 0  THEN

          OPEN cr_crapban(pr_cdbccxlt => pr_cdbccxlt);

          FETCH cr_crapban INTO rw_crapban;

          -- Se encontrar registro
          IF cr_crapban%FOUND THEN
            pr_auxcdbcc := rw_crapban.cdbccxlt;
            pr_nmresbcc := rw_crapban.nmresbcc;
            pr_nmextbcc := rw_crapban.nmextbcc;
            pr_auxnrisp := rw_crapban.nrispbif;
            pr_flgdispb := rw_crapban.flgdispb;
            pr_dtinispb := rw_crapban.dtinispb;
            pr_flgoppag := rw_crapban.flgoppag;
            pr_dtaltstr := rw_crapban.dtaltstr;
            pr_dtaltpag := rw_crapban.dtaltpag;
            pr_nrcnpjif := rw_crapban.nrcnpjif;
                        
          ELSE
            -- Fechar o cursor pois haverá raise
            CLOSE cr_crapban;

            -- Montar mensagem de critica
            vr_cdcritic := 57;
            -- Busca critica
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
            pr_nmdcampo:= 'cdbccxlt';

            RAISE vr_exc_erro;

          END IF;

          CLOSE cr_crapban;

        ELSE

          OPEN cr_crapban1(pr_nrispbif => pr_nrispbif);

          FETCH cr_crapban1 INTO rw_crapban1;

          -- Se encontrar registro
          IF cr_crapban1%FOUND THEN
            pr_auxcdbcc := rw_crapban1.cdbccxlt;
            pr_nmresbcc := rw_crapban1.nmresbcc;
            pr_nmextbcc := rw_crapban1.nmextbcc;
            pr_auxnrisp := rw_crapban1.nrispbif;            
            pr_flgdispb := rw_crapban1.flgdispb;
            pr_dtinispb := rw_crapban1.dtinispb;
            pr_flgoppag := rw_crapban1.flgoppag;
            pr_dtaltstr := rw_crapban1.dtaltstr;
            pr_dtaltpag := rw_crapban1.dtaltpag;
            pr_nrcnpjif := rw_crapban1.nrcnpjif;

          ELSE
            -- Fechar o cursor pois haverá raise
            CLOSE cr_crapban1;

            -- Montar mensagem de critica
            vr_cdcritic := 57;
            -- Busca critica
            vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
            pr_nmdcampo:= 'cdbccxlt';

            RAISE vr_exc_erro;

          END IF;

          CLOSE cr_crapban1;

        END IF;

      ELSIF pr_cdbccxlt IS NULL OR pr_nrispbif IS NULL THEN

        -- Montar mensagem de critica
        vr_cdcritic := 57;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        pr_nmdcampo:= 'cdbccxlt';

        RAISE vr_exc_erro;

      END IF;


    EXCEPTION
      WHEN vr_exc_erro THEN

        -- Retorno não OK
        pr_des_erro:= vr_retornvl;

        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';

        -- Chamar rotina de gravação de erro
        vr_dscritic := 'Erro na banc0001.pc_consulta_banco --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);


  END pc_consulta_banco;

  /* Rotina referente a pesquisa de bancos */
  PROCEDURE pc_pesquisa_banco(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                             ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                             ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                             ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT NULL--Codigo do banco
                             ,pr_nmresbcc IN VARCHAR2 DEFAULT NULL             --Nome do banco
                             ,pr_nrispbif IN crapban.nrispbif%TYPE DEFAULT NULL--Numero do SPB
                             ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                             ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                             ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                                          
                             ,pr_nmdcampo OUT VARCHAR2    -->Nome do campo com erro
                             ,pr_tab_bancos OUT banc0001.typ_tab_bancos --Tabela Contratos                             
                             ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                             ,pr_des_erro OUT VARCHAR2) IS -->Erros do processo
     /*---------------------------------------------------------------------------------------------------------------
     Programa: pc_pesquisa_banco       Antiga: rotina chamada ao pressionar a tecla F7
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 23/06/2015                        Ultima atualizacao: 19/08/2016

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Processar a rotina de pesquisa da tela BANCOS.

     Alteracoes: 23/06/2015 - Conversao Progress >> Oracle (PLSQL) - Jéssica (DB1)
                 
                 19/08/2016 - Adicionado dois novos filtros, codigo e nome do banco,
                              conforme solicitado no chamado 5044701. (Kelvin)
    ---------------------------------------------------------------------------------------------------------------*/


    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Cursor para buscar o nome do banco
    CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE
                     ,pr_nmresbcc IN crapban.nmresbcc%TYPE
                     ,pr_nrispbif IN crapban.nrispbif%TYPE) IS
    SELECT substr(nmresbcc,1,15) nmresbcc
          ,crapban.cdbccxlt
          ,crapban.nrispbif
          ,crapban.flgdispb
      FROM crapban
     WHERE ((crapban.cdbccxlt = pr_cdbccxlt) OR (pr_cdbccxlt IS NULL))
       AND ((UPPER(crapban.nmresbcc) LIKE '%'|| UPPER(pr_nmresbcc) ||'%') OR (pr_nmresbcc IS NULL))
       AND ((crapban.nrispbif = pr_nrispbif) OR (pr_nrispbif IS NULL))
     ORDER BY crapban.nmresbcc;

    rw_crapban cr_crapban%ROWTYPE;

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    --Variaveis de Indice
    vr_index PLS_INTEGER;

    vr_retornvl  VARCHAR2(3):= 'NOK';
    
    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;
    vr_exc_saida EXCEPTION;

    BEGIN

      --Inicializar Variaveis
      vr_cdcritic := 0;
      vr_dscritic := NULL;
      vr_index := 0;
     
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);

      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN

        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;

        -- Montar mensagem de critica
        vr_cdcritic := 651;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);

       RAISE vr_exc_erro;

      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
                  
      FOR rw_crapban IN cr_crapban(pr_cdbccxlt
                                  ,pr_nmresbcc
                                  ,pr_nrispbif) LOOP

        vr_index:= vr_index + 1;

        pr_tab_bancos(vr_index).cdbccxlt := rw_crapban.cdbccxlt;
        pr_tab_bancos(vr_index).nmresbcc := rw_crapban.nmresbcc;
        pr_tab_bancos(vr_index).nrispbif := rw_crapban.nrispbif;
        pr_tab_bancos(vr_index).flgdispb := rw_crapban.flgdispb;        

      END LOOP;      
            
    EXCEPTION
      WHEN vr_exc_erro THEN

        -- Retorno não OK
        pr_des_erro:= vr_retornvl;

        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';

        -- Chamar rotina de gravação de erro
        vr_dscritic := 'Erro na banc0001.pc_pesquisa_banco --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);


  END pc_pesquisa_banco;

  /*\* Rotina referente a pesquisa de bancos Modo Caracter *\
  PROCEDURE pc_pesquisa_banco_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                 ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                 ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                 ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                 ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                 ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                                                  
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                 ,pr_clob_ret OUT CLOB                 --> Tabela bancos                                 
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                 ,pr_dscritic OUT VARCHAR2) IS         --> Descricao Erro
  \*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_pesquisa_banco_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 28/07/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a consulta de bancos modo Caracter

    Alteracoes: 28/07/2015 - Desenvolvimento - Jéssica (DB1)
                 
  ---------------------------------------------------------------------------------------------------------------*\

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabelas de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    vr_tab_bancos banc0001.typ_tab_bancos;
    
    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
            
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;                                       
        
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;

      --Limpar tabela dados
      vr_tab_bancos.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      --Consultar Bancos Cadastrados
      banc0001.pc_pesquisa_banco(pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                ,pr_nrdcaixa => pr_nrdcaixa  --Numero Caixa
                                ,pr_idorigem => pr_idorigem  --Origem Processamento
                                ,pr_cdoperad => pr_cdoperad  --Operador
                                ,pr_nmdatela => pr_nmdatela  --Nome da tela                                                                
                                ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                ,pr_tab_bancos => vr_tab_bancos --Tabela Bancos
                                ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                ,pr_des_erro => vr_des_reto); --Saida OK/NOK


      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a banc0001.pc_pesquisa_banco.';
        END IF;    
        
        --Levantar Excecao
        RAISE vr_exc_erro;
                           
      END IF;

      --Montar CLOB
      IF vr_tab_bancos.COUNT > 0 THEN
        
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clob_ret, TRUE); 
        dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);
        
        -- Insere o cabeçalho do XML 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
         
        --Buscar Primeiro avalista
        vr_index:= vr_tab_bancos.FIRST;
        
        --Percorrer todos os avalistas
        WHILE vr_index IS NOT NULL LOOP
          vr_string:= '<aval>'||
                      '<nmresbcc>'||NVL(TO_CHAR(vr_tab_bancos(vr_index).nmresbcc),' ')|| '</nmresbcc>'|| 
                      '<cdbccxlt>'||NVL(TO_CHAR(vr_tab_bancos(vr_index).cdbccxlt),'0')|| '</cdbccxlt>'|| 
                      '<nrispbif>'||NVL(TO_CHAR(vr_tab_bancos(vr_index).nrispbif),'0')|| '</nrispbif>'||
                      '<flgdispb>'||NVL(TO_CHAR(vr_tab_bancos(vr_index).flgdispb),' ')|| '</flgdispb>'|| 
                      '</aval>';
                      
          -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                                 ,pr_texto_completo => vr_dstexto 
                                 ,pr_texto_novo     => vr_string
                                 ,pr_fecha_xml      => FALSE);   
                                                    
          --Proximo Registro
          vr_index:= vr_tab_bancos.NEXT(vr_index);
          
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
        pr_dscritic:= 'Erro na banc0001.pc_pesquisa_banco_car --> '|| SQLERRM;

  END pc_pesquisa_banco_car;*/

  /* Rotina referente a pesquisa de bancos Modo Web */
  PROCEDURE pc_pesquisa_banco_web(pr_cdbccxlt IN crapban.cdbccxlt%TYPE --Codigo do banco
                                 ,pr_nmresbcc IN VARCHAR2              --Nome do banco
                                 ,pr_nrispbif IN crapban.nrispbif%TYPE --Numero do SPB 
                                 ,pr_nrregist IN INTEGER               --Numero Registros
                                 ,pr_nriniseq IN INTEGER               --Numero Sequencia Inicial
                                 ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS         --Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_pesquisa_banco_web      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 28/07/2015                        Ultima atualizacao: 19/08/2016

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a pesquisa de bancos modo Web

    Alteracoes: 19/08/2016 - Adicionado dois novos filtros, codigo e nome do banco,
                             conforme solicitado no chamado 5044701. (Kelvin)
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de bancos
    vr_tab_bancos banc0001.typ_tab_bancos;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    
    --Variaveis Arquivo Dados
    vr_qtregist INTEGER := 0;
    
    --Variaveis Locais
    vr_nrregist INTEGER;
    vr_auxconta PLS_INTEGER:= 0;
        
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;                                       
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;

      --Limpar tabela dados
      vr_tab_bancos.DELETE;
                  
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      vr_nrregist:= pr_nrregist;

      vr_index := 0;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      
      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      --Consultar Bancos Cadastrados
      banc0001.pc_pesquisa_banco(pr_cdcooper => vr_cdcooper  --Codigo Cooperativa
                                ,pr_cdagenci => vr_cdagenci  --Codigo Agencia
                                ,pr_nrdcaixa => vr_nrdcaixa  --Numero Caixa
                                ,pr_idorigem => vr_idorigem  --Origem Processamento
                                ,pr_cdbccxlt => pr_cdbccxlt  --Codigo do banco
                                ,pr_nmresbcc => pr_nmresbcc  --Nome do banco
                                ,pr_nrispbif => pr_nrispbif  --Numero do SPB
                                ,pr_cdoperad => vr_cdoperad  --Operador
                                ,pr_nmdatela => vr_nmdatela  --Nome da tela                                                                
                                ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                ,pr_tab_bancos => vr_tab_bancos --Tabela Bancos
                                ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                ,pr_des_erro => vr_des_reto); --Saida OK/NOK


      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a banc0001.pc_pesquisa_banco.';
        END IF;    
        
        --Levantar Excecao
        RAISE vr_exc_erro;
                           
      END IF;

      --Montar CLOB
      IF vr_tab_bancos.COUNT > 0 THEN

        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
        
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Root',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Dados',
                               pr_tag_cont => '',
                               pr_des_erro => vr_dscritic);
                           
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF; 
                
        --Buscar Primeiro banco
        vr_index:= vr_tab_bancos.FIRST;
        
        --Percorrer todos os bancos
        WHILE vr_index IS NOT NULL LOOP
          
          --Incrementar Quantidade Registros do Parametro
          vr_qtregist:= nvl(vr_qtregist,0) + 1;
          
          -- controles da paginacao 
          IF (vr_qtregist < pr_nriniseq) OR
             (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
             
            --Proximo Registro
            vr_index:= vr_tab_bancos.NEXT(vr_index);
          
            --Proximo Titular
            CONTINUE;
          END IF; 
          
          --Numero Registros
          IF vr_nrregist > 0 THEN 
            
            -- Insere as tags dos campos da PLTABLE de bancos
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdbccxlt', pr_tag_cont => TO_CHAR(vr_tab_bancos(vr_index).cdbccxlt), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrispbif', pr_tag_cont => TO_CHAR(vr_tab_bancos(vr_index).nrispbif), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmresbcc', pr_tag_cont => TO_CHAR(vr_tab_bancos(vr_index).nmresbcc), pr_des_erro => vr_dscritic);--          
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'flgdispb', pr_tag_cont => CASE vr_tab_bancos(vr_index).flgdispb WHEN 1 THEN 'Sim' ELSE 'Nao' END, pr_des_erro => vr_dscritic); 
                                                                                                                                                                                                         
            
          END IF;
          
          -- Incrementa contador p/ posicao no XML
          vr_auxconta := vr_auxconta + 1;
            
          --Diminuir registros
          vr_nrregist:= nvl(vr_nrregist,0) - 1;  
        
          --Proximo Registro
          vr_index:= vr_tab_bancos.NEXT(vr_index);
                    
        END LOOP;
      ELSE
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');    
        
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Root',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Dados',
                               pr_tag_cont => '',
                               pr_des_erro => vr_dscritic);
                           
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;                                                                                     
                           
      END IF;  
      
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Dados'             --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_qtregist         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;                                   
                                              
      --Retorno
      pr_des_erro:= 'OK';    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na banc0001.pc_consulta_banco_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_pesquisa_banco_web;

  /* Rotina referente a consulta de bancos Modo Caracter */
/*  PROCEDURE pc_consulta_banco_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                 ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                 ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                 ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                 ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                 ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                                 ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0  -->Código do Banco
                                 ,pr_nrispbif IN INTEGER DEFAULT 0     --> número do ISPB
                                 ,pr_cddopcao IN VARCHAR2 DEFAULT NULL --> código da opção
                                 ,pr_nmresbcc OUT VARCHAR2             --> nome do banco abreviado
                                 ,pr_nmextbcc OUT VARCHAR2             --> nome do banco por extenso
                                 ,pr_auxnrisp OUT INTEGER              --> parametro auxiliar caso informe somente o código do banco
                                 ,pr_auxcdbcc OUT INTEGER              --> parametro auxiliar caso informe somente o número do ISPB
                                 ,pr_flgdispb OUT VARCHAR2             --> operando no SPB
                                 ,pr_dtinispb OUT DATE                 --> inicio da operação
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                 ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                 ,pr_dscritic OUT VARCHAR2) IS         --> Descricao Erro
  \*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_consulta_banco_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 28/07/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a consulta de bancos modo Caracter

    Alteracoes: 28/07/2015 - Desenvolvimento - Jéssica (DB1)
                 
  ---------------------------------------------------------------------------------------------------------------*\

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabelas de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;                                       
        
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      --Consultar Bancos Cadastrados
      banc0001.pc_consulta_banco(pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                ,pr_nrdcaixa => pr_nrdcaixa  --Numero Caixa
                                ,pr_idorigem => pr_idorigem  --Origem Processamento
                                ,pr_cdoperad => pr_cdoperad  --Operador
                                ,pr_nmdatela => pr_nmdatela  --Nome da tela                                
                                ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento                                
                                ,pr_cdbccxlt => pr_cdbccxlt  --Codigo do Banco
                                ,pr_nrispbif => pr_nrispbif  --Numero ISPB
                                ,pr_cddopcao => pr_cddopcao  --código da opção
                                ,pr_nmresbcc => pr_nmresbcc  --Nome do banco abreviado
                                ,pr_nmextbcc => pr_nmextbcc  --Nome do banco por extenso
                                ,pr_auxnrisp => pr_auxnrisp  --Parametro auxiliar caso seja informado apenas o codigo do banco
                                ,pr_auxcdbcc => pr_auxcdbcc  --Parametro auxiliar caso seja informado apenas o numero do ISPB
                                ,pr_flgdispb => pr_flgdispb  --Operando no SPB
                                ,pr_dtinispb => pr_dtinispb  --Incio da operação
                                ,pr_cdcritic => pr_cdcritic  --Codigo Erro
                                ,pr_dscritic => pr_dscritic  --Descrição do Erro
                                ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                ,pr_des_erro => vr_des_reto); --Saida OK/NOK


      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a banc0001.pc_consulta_banco.';
        END IF;    
        
        --Levantar Excecao
        RAISE vr_exc_erro;
                           
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
        pr_dscritic:= 'Erro na banc0001.pc_consulta_banco_car --> '|| SQLERRM;

  END pc_consulta_banco_car;*/

  /* Rotina referente a consulta de bancos Modo Web */
  PROCEDURE pc_consulta_banco_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL           -->Data Movimento
                                 ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0 -->Código do Banco
                                 ,pr_nrispbif IN INTEGER DEFAULT 0               -->Numero do ISPB
                                 ,pr_cddopcao IN VARCHAR2 DEFAULT NULL           -->Codigo da opcao
                                 ,pr_xmllog   IN VARCHAR2 DEFAULT NULL           -->XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER                    -->Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                       -->Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType              -->Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2                       -->Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS                   -->Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_consulta_banco_web      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 28/07/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a consulta de bancos modo Web

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_nmresbcc VARCHAR2(100);
    vr_nmextbcc VARCHAR2(100);
    vr_auxnrisp INTEGER; 
    vr_auxcdbcc INTEGER; 
    vr_flgdispb INTEGER;
    vr_flgoppag INTEGER;
    vr_nrcnpjif INTEGER;
    vr_dtinispb DATE;
    vr_dtaltstr DATE;
    vr_dtaltpag DATE;
    
    --Variaveis Arquivo Dados
    vr_dtmvtolt DATE;
    vr_auxconta PLS_INTEGER:= 0;
    
    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;                                       
    
    --Variaveis de auxiliar
    aux_vr_nrcnpjif VARCHAR2(25);
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
                  
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      
      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      BEGIN                                                  
        --Pega a data de movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
            
      --Consultar Bancos
      banc0001.pc_consulta_banco(pr_cdcooper => vr_cdcooper  --Codigo Cooperativa
                                ,pr_cdagenci => vr_cdagenci  --Codigo Agencia
                                ,pr_nrdcaixa => vr_nrdcaixa  --Numero Caixa
                                ,pr_idorigem => vr_idorigem  --Origem Processamento
                                ,pr_cdoperad => vr_cdoperad  --Operador
                                ,pr_nmdatela => vr_nmdatela  --Nome da tela                                
                                ,pr_dtmvtolt => vr_dtmvtolt  --Data Movimento                                
                                ,pr_cdbccxlt => pr_cdbccxlt  --Codigo do banco
                                ,pr_nrispbif => pr_nrispbif  --Numero ISPB
                                ,pr_cddopcao => pr_cddopcao  --Codigo de opção
                                ,pr_nmresbcc => vr_nmresbcc  --Nome do banco abreviado
                                ,pr_nmextbcc => vr_nmextbcc  --Nome do banco por extenso
                                ,pr_auxnrisp => vr_auxnrisp  --parametro auxiliar caso seja informado apenas o código do banco
                                ,pr_auxcdbcc => vr_auxcdbcc  --parametro auxiliar caso seja informado apenas o numero do ISPB
                                ,pr_flgdispb => vr_flgdispb  --Operando no SPB-STR
                                ,pr_dtinispb => vr_dtinispb  --Inicio da Operação
                                ,pr_flgoppag => vr_flgoppag  --Operando no SPB-PAG
                                ,pr_nrcnpjif => vr_nrcnpjif  --CNPJ do Banco Participante da PCPS
                                ,pr_dtaltstr => vr_dtaltstr  --Data última alteração do campo "Operando no SPB-STR"
                                ,pr_dtaltpag => vr_dtaltpag  --Data última alteração do campo "Operando no SPB-PAG"
                                ,pr_cdcritic => pr_cdcritic  --Codigo Erro
                                ,pr_dscritic => pr_dscritic  --Descrição do Erro
                                ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                ,pr_des_erro => vr_des_reto); --Saida OK/NOK                                      

     
      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na banc0001.pc_consulta_banco.';
        END IF;  
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF; 
      
      if vr_nrcnpjif = 0 THEN
        aux_vr_nrcnpjif:= '';
      ELSE
        aux_vr_nrcnpjif:= gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_nrcnpjif, pr_inpessoa => 2);
      END IF;
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');       
        
      -- Insere as tags dos campos da PLTABLE de bancos      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdbccxlt', pr_tag_cont => TO_CHAR(pr_cdbccxlt), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrispbif', pr_tag_cont => TO_CHAR(pr_nrispbif), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmresbcc', pr_tag_cont => TO_CHAR(vr_nmresbcc), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmextbcc', pr_tag_cont => TO_CHAR(vr_nmextbcc), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'auxnrisp', pr_tag_cont => TO_CHAR(vr_auxnrisp), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'auxcdbcc', pr_tag_cont => TO_CHAR(vr_auxcdbcc), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'flgdispb', pr_tag_cont => TO_CHAR(vr_flgdispb), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtinispb', pr_tag_cont => TO_CHAR(vr_dtinispb, 'dd/mm/YYYY'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'flgoppag', pr_tag_cont => TO_CHAR(vr_flgoppag), pr_des_erro => vr_dscritic);      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrcnpjif', pr_tag_cont => aux_vr_nrcnpjif, pr_des_erro => vr_dscritic);      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtaltstr', pr_tag_cont => TO_CHAR(vr_dtaltstr, 'dd/mm/YYYY'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtaltpag', pr_tag_cont => TO_CHAR(vr_dtaltpag, 'dd/mm/YYYY'), pr_des_erro => vr_dscritic);            
          
      --Retorno
      pr_des_erro:= 'OK';    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na banc0001.pc_consulta_banco_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_consulta_banco_web;

  /* Rotina referente a inclusão de bancos */
  PROCEDURE pc_inclui_banco(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                           ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                           ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                           ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                           ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                           ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                           ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0  -->Código do Banco
                           ,pr_nrispbif IN INTEGER DEFAULT 0      -->Numero do ISPB
                           ,pr_cddopcao IN VARCHAR2 DEFAULT NULL  -->Codigo da opção
                           ,pr_nmresbcc IN VARCHAR2               -->Nome do banco abreviado
                           ,pr_nmextbcc IN VARCHAR2               -->Nome do banco por extenso
                           ,pr_flgdispb IN INTEGER                -->Operando no SPB-STR
                           ,pr_dtinispb IN DATE                   -->Inicio da operação
                           ,pr_flgoppag IN INTEGER                -->Operando no SPB-PAG
                           ,pr_cdcritic OUT PLS_INTEGER           -->Código da crítica
                           ,pr_dscritic OUT VARCHAR2              -->Descrição da crítica
                           ,pr_nmdcampo OUT VARCHAR2              -->Nome do campo com erro                           
                           ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                           ,pr_des_erro OUT VARCHAR2) IS          -->Erros do processo
     /*---------------------------------------------------------------------------------------------------------------
     Programa: pc_inclui_banco       Antiga: bancosi.i
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 29/07/2015                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Processar a rotina de inclusão da tela BANCOS.

     Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------*/


    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Cursor genérico de calendário
    rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;

    -- Cursor para buscar o nome do banco
    CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
    SELECT substr(nmresbcc,1,15) nmresbcc
          ,crapban.cdbccxlt
          ,crapban.nmextbcc
          ,crapban.nrispbif
          ,crapban.flgdispb
          ,crapban.dtinispb
          ,crapban.flgoppag
      FROM crapban
     WHERE crapban.cdbccxlt = pr_cdbccxlt;
    rw_crapban cr_crapban%ROWTYPE;

    -- Cursor para buscar o nome do banco
    CURSOR cr_crapban1(pr_nrispbif IN crapban.nrispbif%TYPE) IS
    SELECT substr(nmresbcc,1,15) nmresbcc
          ,crapban.cdbccxlt
          ,crapban.nmextbcc
          ,crapban.nrispbif
          ,crapban.flgdispb
          ,crapban.dtinispb
          ,crapban.flgoppag
      FROM crapban
     WHERE crapban.nrispbif = pr_nrispbif;
    rw_crapban1 cr_crapban1%ROWTYPE;


    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    vr_cdbccxlt  INTEGER;
    

    vr_retornvl  VARCHAR2(3):= 'NOK';

    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;
    vr_exc_saida EXCEPTION;

    BEGIN

      --Inicializar Variaveis
      vr_cdcritic := 0;
      vr_dscritic := NULL;      
      vr_cdbccxlt := pr_cdbccxlt;

      IF pr_cdbccxlt IS NULL THEN

        vr_cdbccxlt := 0;

      END IF;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);

      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN

        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;

        -- Montar mensagem de critica
        pr_cdcritic := 651;
        -- Busca critica
        pr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);

       RAISE vr_exc_erro;

      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      
      IF vr_cdbccxlt > 0 THEN

        OPEN cr_crapban(pr_cdbccxlt => vr_cdbccxlt);

        FETCH cr_crapban INTO rw_crapban;

        -- Se encontrar registro
        IF cr_crapban%FOUND THEN
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapban;

          -- Montar mensagem de critica
          vr_cdcritic := 709;
          -- Busca critica
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);

          pr_nmdcampo:= 'cdbccxlt';

          RAISE vr_exc_erro;
          
        END IF;

        CLOSE cr_crapban;

      END IF;

      OPEN cr_crapban1(pr_nrispbif => pr_nrispbif);

      FETCH cr_crapban1 INTO rw_crapban1;

      -- Se encontrar registro
      IF cr_crapban1%FOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapban1;

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        -- Busca critica
        vr_dscritic:= 'ISPB ja cadastrado.';

        pr_nmdcampo:= 'cdbccxlt';

        RAISE vr_exc_erro;

      END IF;

      CLOSE cr_crapban1;
      
      IF pr_nrispbif = 0 OR pr_nrispbif IS NULL THEN

         -- Montar mensagem de critica
        vr_cdcritic := 0;
        -- Busca critica
        vr_dscritic:= 'Informe o número ISPB.';

        pr_nmdcampo:= 'nrispbif';

        RAISE vr_exc_erro;
                
      END IF;

      IF TRIM(pr_nmresbcc) IS NULL THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        -- Busca critica
        vr_dscritic:= 'Informe o nome abreviado da IF.';

        pr_nmdcampo:= 'nmresbcc';

        RAISE vr_exc_erro;

      END IF;

      IF TRIM(pr_nmextbcc) IS NULL THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        -- Busca critica
        vr_dscritic:= 'Informe o nome extenso da IF.';

        pr_nmdcampo:= 'nmextbcc';

        RAISE vr_exc_erro;

      END IF;                   

      IF vr_cdbccxlt <> 1 AND   /** Banco do Brasil **/
         pr_flgdispb = 1  AND
         (pr_nrispbif = 0 OR pr_nrispbif IS NULL)  THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        -- Busca critica
        vr_dscritic:= 'É necessário informar o número do ISPB.';

        pr_nmdcampo:= 'cdbccxlt';

        RAISE vr_exc_erro;

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
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      BEGIN
        INSERT INTO crapban 
                (cdbccxlt,
                 nrispbif,
                 nmresbcc,
                 nmextbcc,
                 flgdispb,
                 cdoperad,
                 dtmvtolt,
                 dtinispb,
                 flgoppag,
                 dtaltstr,
                 dtaltpag,
                 nrcnpjif)
               VALUES
                (vr_cdbccxlt,   -- cdbccxlt
                 pr_nrispbif,   -- ispb
                 UPPER(pr_nmresbcc),    -- nome do banco abreviado
                 UPPER(pr_nmextbcc),    -- nome do banco por extenso
                 pr_flgdispb,    -- Operando no SPB-STR
                 pr_cdoperad,    -- codigo do operador
                 rw_crapdat.dtmvtolt, -- dtmvtolt
                 pr_dtinispb,    -- inicio da operação
                 pr_flgoppag,    -- Operando no SPB-PAG
                 rw_crapdat.dtmvtolt, -- Data última alteração SPB-STR
                 rw_crapdat.dtmvtolt,  -- Data última alteração SPB-PAG
                 0     
                );
      
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao inserir Banco: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

    --Salvar
    COMMIT;

    -- Inclui mensagem no log
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 1, -- Somente mensagem
                               pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' --> '
                                               || 'Operador ' || pr_cdoperad 
                                               || ' | Incluiu Banco/Caixa'
                                               || to_char(pr_cdbccxlt));

    EXCEPTION
      WHEN vr_exc_erro THEN

        -- Retorno não OK
        pr_des_erro:= vr_retornvl;

        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

      -- Efetuar rollback
      ROLLBACK;                                                          

      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';

        -- Chamar rotina de gravação de erro
        pr_dscritic := 'Erro na banc0001.pc_inclui_banco --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Efetuar rollback
        ROLLBACK;


  END pc_inclui_banco;

  /* Rotina referente a inclusao de bancos Modo Caracter */
/*  PROCEDURE pc_inclui_banco_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                               ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                               ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                               ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                               ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                               ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                               ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0  -->Código do Banco
                               ,pr_nrispbif IN INTEGER DEFAULT 0     -->Numero do ISPB
                               ,pr_cddopcao IN VARCHAR2 DEFAULT NULL -->codigo da opção
                               ,pr_nmresbcc IN VARCHAR2              -->nome do banco abrevido
                               ,pr_nmextbcc IN VARCHAR2              -->nome do banco por extenso
                               ,pr_flgdispb IN VARCHAR2              -->operando no SPB
                               ,pr_dtinispb IN DATE                  -->inicio da operação
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                               ,pr_clob_ret OUT CLOB                 --Tabela XML                                 
                               ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                               ,pr_dscritic OUT VARCHAR2) IS         --Descricao Erro
  \*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_inclui_banco_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 29/07/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a inclusão de bancos modo Caracter

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*\

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabelas de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;                                       
        
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      --Incluir Banco
      banc0001.pc_inclui_banco(pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                              ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                              ,pr_nrdcaixa => pr_nrdcaixa  --Numero Caixa
                              ,pr_idorigem => pr_idorigem  --Origem Processamento
                              ,pr_cdoperad => pr_cdoperad  --Operador
                              ,pr_nmdatela => pr_nmdatela  --Nome da tela                                
                              ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento                                
                              ,pr_cdbccxlt => pr_cdbccxlt  --Codigo do banco
                              ,pr_nrispbif => pr_nrispbif  --Numero ISPB
                              ,pr_cddopcao => pr_cddopcao  --Codigo da opção
                              ,pr_nmresbcc => pr_nmresbcc  --Nome do banco abreviado
                              ,pr_nmextbcc => pr_nmextbcc  --Nome do banco por extenso
                              ,pr_flgdispb => pr_flgdispb  --Operando no SPB
                              ,pr_dtinispb => pr_dtinispb  --Incio da operação
                              ,pr_cdcritic => pr_cdcritic  --Codigo Erro
                              ,pr_dscritic => pr_dscritic  --Descrição do Erro
                              ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                              ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                              ,pr_des_erro => vr_des_reto); --Saida OK/NOK


      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a banc0001.pc_inclui_banco.';
        END IF;    
        
        --Levantar Excecao
        RAISE vr_exc_erro;
                           
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
        pr_dscritic:= 'Erro na banc0001.pc_inclui_banco_car --> '|| SQLERRM;

  END pc_inclui_banco_car;*/

  /* Rotina referente a inclusão de bancos Modo Web */
  PROCEDURE pc_inclui_banco_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL            -->Data Movimento
                               ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0  -->Código do Banco
                               ,pr_nrispbif IN INTEGER DEFAULT 0                -->Numero ISPB
                               ,pr_cddopcao IN VARCHAR2 DEFAULT NULL            -->Codigo da Opção                   
                               ,pr_nmresbcc IN VARCHAR2                         -->Nome do banco Abreviado
                               ,pr_nmextbcc IN VARCHAR2                         -->Nome do banco por extenso
                               ,pr_flgdispb IN INTEGER                          -->Operando no SPB-STR
                               ,pr_dtinispb IN VARCHAR2                         -->Inicio da operação
                               ,pr_flgoppag IN INTEGER                          -->Operando no SPB-PAG
                               ,pr_xmllog   IN VARCHAR2 DEFAULT NULL            -->XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                     -->Código da crítica
                               ,pr_dscritic OUT VARCHAR2                        -->Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType               -->Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                        -->Nome do Campo
                               ,pr_des_erro OUT VARCHAR2) IS                    -->Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_inclui_banco_web      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 29/07/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a inclusão de bancos modo Web

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dtinispb DATE;
            
    --Variaveis Arquivo Dados
    vr_dtmvtolt DATE;
    vr_auxconta PLS_INTEGER:= 0;
        
    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;                                       
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
                  
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      
      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      BEGIN                                                  
        --Pega a data de movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      vr_dtinispb := to_date(pr_dtinispb,'DD/MM/YYYY');
          
      --Incluir bancos
      banc0001.pc_inclui_banco(pr_cdcooper => vr_cdcooper  --Codigo Cooperativa
                              ,pr_cdagenci => vr_cdagenci  --Codigo Agencia
                              ,pr_nrdcaixa => vr_nrdcaixa  --Numero Caixa
                              ,pr_idorigem => vr_idorigem  --Origem Processamento
                              ,pr_cdoperad => vr_cdoperad  --Operador
                              ,pr_nmdatela => vr_nmdatela  --Nome da tela                                
                              ,pr_dtmvtolt => vr_dtmvtolt  --Data Movimento                                
                              ,pr_cdbccxlt => pr_cdbccxlt  --Codigo do Banco
                              ,pr_nrispbif => pr_nrispbif  --Numero ISPB
                              ,pr_cddopcao => pr_cddopcao  --Codigo da opção
                              ,pr_nmresbcc => pr_nmresbcc  --Nome do banco abreviado
                              ,pr_nmextbcc => pr_nmextbcc  --Nome do banco por extenso
                              ,pr_flgdispb => pr_flgdispb  --Operando no SPB-STR
                              ,pr_dtinispb => vr_dtinispb  --Incio da operação
                              ,pr_flgoppag => pr_flgoppag  -->Operando no SPB-PAG
                              ,pr_cdcritic => pr_cdcritic  --Codigo Erro
                              ,pr_dscritic => pr_dscritic  --Descrição do Erro
                              ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                              ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                              ,pr_des_erro => vr_des_reto); --Saida OK/NOK                                      

      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na banc0001.pc_inclui_banco.';
        END IF;  
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF; 
                 
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');       
        
      -- Insere as tags dos campos da tela bancos      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdbccxlt', pr_tag_cont => TO_CHAR(pr_cdbccxlt), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrispbif', pr_tag_cont => TO_CHAR(pr_nrispbif), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmresbcc', pr_tag_cont => TO_CHAR(pr_nmresbcc), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmextbcc', pr_tag_cont => TO_CHAR(pr_nmextbcc), pr_des_erro => vr_dscritic);      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'flgdispb', pr_tag_cont => TO_CHAR(pr_flgdispb), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtinispb', pr_tag_cont => TO_CHAR(pr_dtinispb), pr_des_erro => vr_dscritic);                
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'flgoppag', pr_tag_cont => TO_CHAR(pr_flgoppag), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrcnpjif', pr_tag_cont => TO_CHAR(0), pr_des_erro => vr_dscritic);
                                        
      --Retorno
      pr_des_erro:= 'OK';    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na banc0001.pc_inclui_banco_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_inclui_banco_web;
  
  /* Rotina referente a alteração cadastral dos bancos */
  PROCEDURE pc_altera_banco(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                           ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                           ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                           ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                           ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela
                           ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                           ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0  -->Código do Banco
                           ,pr_nrispbif IN INTEGER DEFAULT 0      -->Numero do ISPB
                           ,pr_cddopcao IN VARCHAR2 DEFAULT NULL  -->Codigo da opção
                           ,pr_nmresbcc IN OUT VARCHAR2           -->nome do banco abreviado
                           ,pr_nmextbcc IN OUT VARCHAR2           -->Nome do banco por extenso                     
                           ,pr_flgdispb IN OUT INTEGER           -->Operando no SPb
                           ,pr_dtinispb IN OUT DATE               -->Incio da operação
                           ,pr_flgoppag IN INTEGER                --Operando no SPB-STR
                           ,pr_cdcritic OUT PLS_INTEGER           -->Código da crítica
                           ,pr_dscritic OUT VARCHAR2              -->Descrição da crítica
                           ,pr_nmdcampo OUT VARCHAR2              -->Nome do campo com erro
                           ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                           ,pr_des_erro OUT VARCHAR2) IS          -->Erros do processo
     /*---------------------------------------------------------------------------------------------------------------
     Programa: pc_altera_banco       Antiga: bancosa.i
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 27/07/2015                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Processar a rotina de alteração da tela BANCOS.

     Alteracoes: 27/07/2015 - Conversao Progress >> Oracle (PLSQL) - Jéssica (DB1)
    ---------------------------------------------------------------------------------------------------------------*/


    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Cursor para buscar o nome do banco
    CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
    SELECT substr(nmresbcc,1,15) nmresbcc
          ,crapban.cdbccxlt
          ,crapban.nmextbcc
          ,crapban.nrispbif
          ,crapban.flgdispb
          ,crapban.dtinispb
          ,crapban.flgoppag
          ,crapban.nrcnpjif
      FROM crapban
     WHERE crapban.cdbccxlt = pr_cdbccxlt;
    rw_crapban cr_crapban%ROWTYPE;

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3);

    vr_tab_erro gene0001.typ_tab_erro;

    vr_auxnrisp INTEGER;
    vr_auxcdbcc INTEGER;

    vr_nmresbcc VARCHAR2(100); 
    vr_nmextbcc VARCHAR2(100);
    vr_flgoppag INTEGER;
    vr_flgdispb INTEGER;
    vr_nrcnpjif INTEGER;
    vr_dtinispb DATE; 
    vr_dtaltstr DATE;
    vr_dtaltpag DATE;    

    vr_log_nmresbcc VARCHAR2(200);
    vr_log_nmextbcc VARCHAR2(200);
    vr_log_flgdispb VARCHAR2(200);
    vr_log_flgoppag INTEGER;
    vr_log_nrcnpjif INTEGER;
    vr_log_dtinispb DATE;
    vr_log_nrispbif INTEGER;
    vr_retornvl  VARCHAR2(3):= 'NOK';

    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;
    vr_exc_saida EXCEPTION;
    
    -- Variável exceção para locke
    vr_exc_locked EXCEPTION;
    PRAGMA EXCEPTION_INIT(vr_exc_locked, -54);

    --> Tabela de retorno do operadores que estao alocando a tabela especifidada
    vr_tab_locktab GENE0001.typ_tab_locktab;
    
    BEGIN
      
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
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      --Inicializar Variaveis
      vr_cdcritic := 0;
      vr_dscritic := NULL;
            
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);

      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN

        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;

        -- Montar mensagem de critica
        vr_cdcritic := 651;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);

       RAISE vr_exc_erro;

      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      --Consultar Bancos
      banc0001.pc_consulta_banco(pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                ,pr_nrdcaixa => pr_nrdcaixa  --Numero Caixa
                                ,pr_idorigem => pr_idorigem  --Origem Processamento
                                ,pr_cdoperad => pr_cdoperad  --Operador
                                ,pr_nmdatela => pr_nmdatela  --Nome da tela                                
                                ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento                                
                                ,pr_cdbccxlt => pr_cdbccxlt  --Codigo do Banco
                                ,pr_nrispbif => pr_nrispbif  --Numero ISPB
                                ,pr_cddopcao => pr_cddopcao  --Codigo da Opcao
                                ,pr_nmresbcc => vr_nmresbcc  --Nome do banco abreviado
                                ,pr_nmextbcc => vr_nmextbcc  --Nome do banco por extenso
                                ,pr_auxnrisp => vr_auxnrisp  --parametro auxiliar caso seja informado apenas o codigo do banco
                                ,pr_auxcdbcc => vr_auxcdbcc  --parametro auxiliar caso seja informado apenas o numero do ISPB
                                ,pr_flgdispb => vr_flgdispb  --Operando no SPB-STR
                                ,pr_dtinispb => vr_dtinispb  --Inicio da Operacao
                                ,pr_flgoppag => vr_flgoppag  --Operando no SPB-PAG
                                ,pr_nrcnpjif => vr_nrcnpjif  -->CNPJ do Banco Participante da PCPS
                                ,pr_dtaltstr => vr_dtaltstr  --Data última alteração do campo "Operando no SPB-STR"
                                ,pr_dtaltpag => vr_dtaltpag  --Data última alteração do campo "Operando no SPB-PAG"
                                ,pr_cdcritic => pr_cdcritic  --Codigo Erro
                                ,pr_dscritic => pr_dscritic  --Descrição do Erro
                                ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                ,pr_des_erro => vr_des_reto); --Saida OK/NOK


      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a banc0001.pc_consulta_banco.';
        END IF;    
        
        --Levantar Excecao
        RAISE vr_exc_erro;

      ELSE

        IF TRIM(pr_nmresbcc) IS NOT NULL THEN

          vr_nmresbcc := UPPER(pr_nmresbcc);
        
        END IF;

        IF TRIM(pr_nmextbcc) IS NOT NULL THEN

          vr_nmextbcc := UPPER(pr_nmextbcc);
        
        END IF;
        
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapban (pr_cdbccxlt => pr_cdbccxlt);

      FETCH cr_crapban INTO rw_crapban;

      -- Se encontrar
      IF cr_crapban%FOUND THEN
        
        vr_log_nmresbcc := rw_crapban.nmresbcc;
        vr_log_nmextbcc := rw_crapban.nmextbcc;
        vr_log_flgdispb := rw_crapban.flgdispb;
        vr_log_dtinispb := rw_crapban.dtinispb;
        vr_log_flgoppag := rw_crapban.flgoppag;
        
      END IF;
      -- Fecha cursor
      CLOSE cr_crapban;        

      BEGIN
        -- Busca associado
        OPEN cr_crapban(pr_cdbccxlt => pr_cdbccxlt);
        FETCH cr_crapban
         INTO rw_crapban;

        -- Gerar erro caso não encontre
        IF cr_crapban%NOTFOUND THEN

          -- Fechar cursor pois teremos raise
          CLOSE cr_crapban;

          -- Sair com erro
          vr_cdcritic := 0;
          vr_dscritic := 'Banco nao encontrado!';

          pr_nmdcampo := 'cdbccxlt';

          -- Gera exceção
          RAISE vr_exc_erro;

        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_crapban;
        END IF;

      EXCEPTION
        WHEN vr_exc_locked THEN
          gene0001.pc_ver_lock(pr_nmtabela    => 'CRAPBAN'
                              ,pr_nrdrecid    => ''
                              ,pr_des_reto    => vr_des_reto
                              ,pt_tab_locktab => vr_tab_locktab);

          IF vr_des_reto = 'OK' THEN
            FOR VR_IND IN 1..vr_tab_locktab.COUNT LOOP
              vr_dscritic := 'Registro sendo alterado em outro terminal (CRAPBAN)' ||
                             ' - ' || vr_tab_locktab(VR_IND).nmusuari;
            END LOOP;
          END IF;

          RAISE vr_exc_erro;

      END;

      IF TRIM(vr_nmresbcc) IS NULL THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        -- Busca critica
        vr_dscritic:= 'Informe o nome abreviado da IF.';

        pr_nmdcampo:= 'nmresbcc';

        RAISE vr_exc_erro;

      END IF;

      IF TRIM(vr_nmextbcc) IS NULL THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        -- Busca critica
        vr_dscritic:= 'Informe o nome extenso da IF.';

        pr_nmdcampo:= 'nmextbcc';

        RAISE vr_exc_erro;

      END IF;
                
      IF pr_cdbccxlt <> 1 AND   /** Banco do Brasil **/
         pr_flgdispb = 1  AND
         (pr_nrispbif = 0 OR pr_nrispbif IS NULL)  THEN

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        -- Busca critica
        vr_dscritic:= 'É necessário informar o número do ISPB.';

        pr_nmdcampo:= 'nrispbif';

        RAISE vr_exc_erro;

      END IF;       

                            
      IF pr_cdbccxlt > 0 THEN             
                        
        BEGIN
         UPDATE crapban 
            SET crapban.nmresbcc = UPPER(vr_nmresbcc)
               ,crapban.nmextbcc = vr_nmextbcc
               ,crapban.flgdispb = pr_flgdispb
               ,crapban.dtinispb = pr_dtinispb
               ,crapban.flgoppag = pr_flgoppag
               ,crapban.dtaltstr = (CASE WHEN pr_flgdispb <> rw_crapban.flgdispb THEN 
                                              rw_crapdat.dtmvtolt 
                                         ELSE crapban.dtaltstr END)
               ,crapban.dtaltpag = (CASE WHEN pr_flgoppag <> rw_crapban.flgoppag THEN 
                                             rw_crapdat.dtmvtolt 
                                         ELSE crapban.dtaltstr END)
         WHERE crapban.cdbccxlt = pr_cdbccxlt;
          

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar Banco: '||SQLERRM;
            RAISE vr_exc_erro;
        END;

      ELSE

        BEGIN
         UPDATE crapban 
            SET crapban.nmresbcc = UPPER(vr_nmresbcc)
               ,crapban.nmextbcc = vr_nmextbcc
               ,crapban.flgdispb = pr_flgdispb
               ,crapban.dtinispb = vr_dtinispb
               ,crapban.flgoppag = pr_flgoppag
               ,crapban.dtaltstr = (CASE WHEN pr_flgdispb <> rw_crapban.flgdispb THEN 
                                              rw_crapdat.dtmvtolt 
                                         ELSE crapban.dtaltstr END)
               ,crapban.dtaltpag = (CASE WHEN pr_flgoppag <> rw_crapban.flgoppag THEN 
                                              rw_crapdat.dtmvtolt 
                                         ELSE crapban.dtaltstr END)
         WHERE crapban.nrispbif = pr_nrispbif;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar Banco: '||SQLERRM;
            RAISE vr_exc_erro;
        END;

      END IF;
            
      --Retorno
      pr_des_erro:= 'OK';
      COMMIT;

      IF vr_nmresbcc <> vr_log_nmresbcc THEN 

        -- Inclui mensagem no log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 1, -- Somente mensagem
                                   pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' --> '
                                                   || 'Operador: ' || pr_cdoperad || ' | '
                                                   || 'ISPB: ' || to_char(pr_nrispbif, '00000000') || ' | ' 
                                                   || ' Alterou o nome abreviado do banco de '
                                                   || to_char(vr_log_nmresbcc) || ' para '
                                                   || to_char(vr_nmresbcc),
                                   pr_nmarqlog     => 'bancos.log' );

      END IF;


      IF vr_nmextbcc <> vr_log_nmextbcc   THEN 
        -- Inclui mensagem no log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 1, -- Somente mensagem
                                   pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' --> '
                                                   || 'Operador: ' || pr_cdoperad || ' | '
                                                   || 'ISPB: ' || to_char(pr_nrispbif, '00000000') || ' | ' 
                                                   || ' Alterou o nome completo do banco de '
                                                   || to_char(vr_log_nmextbcc) || ' para '
                                                   || to_char(vr_nmextbcc),
                                   pr_nmarqlog     => 'bancos.log');

      END IF;  
               
      IF pr_nrispbif <> vr_log_nrispbif   THEN 
        -- Inclui mensagem no log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 1, -- Somente mensagem
                                   pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' --> '
                                                   || 'Operador: ' || pr_cdoperad || ' | '
                                                   || 'ISPB: ' || to_char(pr_nrispbif, '00000000') || ' | ' 
                                                   || ' Alterou o numero ISPB do banco de '
                                                   || to_char(vr_log_nrispbif) || ' para '
                                                   || to_char(pr_nrispbif),
                                   pr_nmarqlog     => 'bancos.log' );

      END IF;
               
      IF pr_flgdispb <> vr_log_flgdispb   THEN 
        -- Inclui mensagem no log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 1, -- Somente mensagem
                                   pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' --> '
                                                   || 'Operador: ' || pr_cdoperad || ' | '
                                                   || 'ISPB: ' || to_char(pr_nrispbif, '00000000') || ' | ' 
                                                   || ' Alterou opção Operando no SPB-STR de '
                                                   || REPLACE(REPLACE(to_char(vr_log_flgdispb), '1','SIM'), '0', 'NÃO') 
                                                   || ' para '      
                                                   || REPLACE(REPLACE(to_char(pr_flgdispb), '1','SIM'), '0', 'NÃO'),
                                   pr_nmarqlog     => 'bancos.log');

      END IF;
      
      IF pr_flgoppag <> vr_log_flgoppag   THEN
        -- Inclui mensagem no log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 1, -- Somente mensagem
                                   pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' --> '
                                                   || 'Operador: ' || pr_cdoperad || ' | '
                                                   || 'ISPB: ' || to_char(pr_nrispbif, '00000000') || ' | ' 
                                                   || ' Alterou opção Operando no SPB-PAG de '
                                                   || REPLACE(REPLACE(to_char(vr_log_flgoppag), '1','SIM'), '0', 'NÃO') 
                                                   || ' para '      
                                                   || REPLACE(REPLACE(to_char(pr_flgoppag), '1','SIM'), '0', 'NÃO'),
                                   pr_nmarqlog     => 'bancos.log');

      END IF;
               
    EXCEPTION
      WHEN vr_exc_erro THEN

        -- Retorno não OK
        pr_des_erro:= vr_retornvl;

        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        ROLLBACK;                             

      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';

        -- Chamar rotina de gravação de erro
        vr_dscritic := 'Erro na banc0001.pc_altera_banco --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        ROLLBACK;


  END pc_altera_banco;

  /* Rotina referente a inclusao de bancos Modo Caracter */
/*  PROCEDURE pc_altera_banco_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                               ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                               ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                               ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                               ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                               ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                               ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0  -->Código do Banco
                               ,pr_nrispbif IN INTEGER DEFAULT 0     -->numero do ISPB
                               ,pr_cddopcao IN VARCHAR2 DEFAULT NULL -->codigo da opcao
                               ,pr_nmresbcc IN VARCHAR2              -->Nome do banco abreviado
                               ,pr_nmextbcc IN VARCHAR2              -->Nome do banco por extenso
                               ,pr_flgdispb IN VARCHAR2              -->Operando no spb
                               ,pr_dtinispb IN DATE              -->inicio da operacao
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                               ,pr_clob_ret OUT CLOB                 --Tabela XML                                 
                               ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                               ,pr_dscritic OUT VARCHAR2) IS         --Descricao Erro
  \*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_altera_banco_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 29/07/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a alteração de bancos modo Caracter

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*\

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabelas de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    
    vr_nmresbcc VARCHAR2(100); 
    vr_nmextbcc VARCHAR2(100);
    vr_flgdispb VARCHAR2(3);
    vr_dtinispb DATE;
        
    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;                                       
        
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;

      vr_nmresbcc := pr_nmresbcc; 
      vr_nmextbcc := pr_nmextbcc;
      vr_flgdispb := pr_flgdispb;
      vr_dtinispb := pr_dtinispb;
      
      vr_dtinispb := to_date(pr_dtinispb,'MM/DD/YY');


      --Alterar Bancos Cadastrados
      banc0001.pc_altera_banco(pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                              ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                              ,pr_nrdcaixa => pr_nrdcaixa  --Numero Caixa
                              ,pr_idorigem => pr_idorigem  --Origem Processamento
                              ,pr_cdoperad => pr_cdoperad  --Operador
                              ,pr_nmdatela => pr_nmdatela  --Nome da tela                                
                              ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento                                
                              ,pr_cdbccxlt => pr_cdbccxlt  --codigo do banco
                              ,pr_nrispbif => pr_nrispbif  --Numero ISPB
                              ,pr_cddopcao => pr_cddopcao  --codigo da opcao
                              ,pr_nmresbcc => vr_nmresbcc  --Nome do banco abreviado
                              ,pr_nmextbcc => vr_nmextbcc  --Nome do banco por extenso
                              ,pr_flgdispb => vr_flgdispb  --Operando no SPB
                              ,pr_dtinispb => vr_dtinispb  --Inicio da operação
                              ,pr_cdcritic => pr_cdcritic  --Codigo Erro
                              ,pr_dscritic => pr_dscritic  --Descrição do Erro
                              ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                              ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                              ,pr_des_erro => vr_des_reto); --Saida OK/NOK

        --Se Ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          
          --Se possuir dados na tabela
          IF vr_tab_erro.COUNT > 0 THEN
            --Mensagem erro
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            --Mensagem erro
            vr_dscritic:= 'Erro ao executar a banc0001.pc_altera_banco.';
          END IF;    
          
          --Levantar Excecao
          RAISE vr_exc_erro;

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
        pr_dscritic:= 'Erro na banc0001.pc_altera_banco_car --> '|| SQLERRM;

  END pc_altera_banco_car;*/

  /* Rotina referente a alteração de bancos Modo Web */
  PROCEDURE pc_altera_banco_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL            -->Data Movimento
                               ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0  -->Código do Banco
                               ,pr_nrispbif IN INTEGER DEFAULT 0                -->Numero ISPB
                               ,pr_cddopcao IN VARCHAR2 DEFAULT NULL            -->Codigo da opcao                   
                               ,pr_nmresbcc IN VARCHAR2                         -->Nome do banco abreviado          
                               ,pr_nmextbcc IN VARCHAR2                         -->Nome do banco por extenso
                               ,pr_flgdispb IN INTEGER                         -->Operando no SPB-STR
                               ,pr_dtinispb IN VARCHAR2 DEFAULT NULL            -->Inicio da operacao
                               ,pr_flgoppag IN INTEGER                          -->Operando no SPB-PAG
                               ,pr_xmllog   IN VARCHAR2 DEFAULT NULL            -->XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                     -->Código da crítica
                               ,pr_dscritic OUT VARCHAR2                        -->Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType               -->Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                        -->Nome do Campo
                               ,pr_des_erro OUT VARCHAR2) IS                    -->Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_altera_banco_web      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 28/07/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a alteração de bancos modo Web

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_nmresbcc VARCHAR2(100);
    vr_nmextbcc VARCHAR2(100);
    vr_flgdispb INTEGER;
    vr_dtinispb DATE;
            
    --Variaveis Arquivo Dados
    vr_dtmvtolt DATE;
           
    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;                                       
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
                  
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      vr_nmresbcc := pr_nmresbcc; 
      vr_nmextbcc := pr_nmextbcc;
      vr_flgdispb := pr_flgdispb;
      vr_dtinispb := to_date(pr_dtinispb,'DD/MM/YYYY');
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      
      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      BEGIN                                                  
        --Pega a data de movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
                   
      --Alterar Bancos Cadastrados
      banc0001.pc_altera_banco(pr_cdcooper => vr_cdcooper  --Codigo Cooperativa
                              ,pr_cdagenci => vr_cdagenci  --Codigo Agencia
                              ,pr_nrdcaixa => vr_nrdcaixa  --Numero Caixa
                              ,pr_idorigem => vr_idorigem  --Origem Processamento
                              ,pr_cdoperad => vr_cdoperad  --Operador
                              ,pr_nmdatela => vr_nmdatela  --Nome da tela                                
                              ,pr_dtmvtolt => vr_dtmvtolt  --Data Movimento                                
                              ,pr_cdbccxlt => pr_cdbccxlt  --Codigo do banco
                              ,pr_nrispbif => pr_nrispbif  --Numero ISPB
                              ,pr_cddopcao => pr_cddopcao  --Codigo da opção
                              ,pr_nmresbcc => vr_nmresbcc  --Nome do banco abreviado
                              ,pr_nmextbcc => vr_nmextbcc  --Nome do banco por extenso
                              ,pr_flgdispb => vr_flgdispb  --Operando no SPB-STR
                              ,pr_dtinispb => vr_dtinispb  --Incio da operação
                              ,pr_flgoppag => pr_flgoppag  --Operando no SPB-PAG
                              ,pr_cdcritic => pr_cdcritic  --Codigo Erro
                              ,pr_dscritic => pr_dscritic  --Descrição do Erro
                              ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                              ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                              ,pr_des_erro => vr_des_reto); --Saida OK/NOK

      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
          
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a banc0001.pc_altera_banco.';
        END IF;    
          
        --Levantar Excecao
        RAISE vr_exc_erro;

      END IF;                   
                                        
      --Retorno
      pr_des_erro:= 'OK';    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na banc0001.pc_altera_banco_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_altera_banco_web;
 

  /* Rotina referente a alteração do CNPJ de um banco */
  PROCEDURE pc_altera_cnpj_banco(pr_cdbccxlt IN crapban.cdbccxlt%TYPE DEFAULT 0  -->Código do Banco
                               ,pr_nrispbif IN INTEGER DEFAULT 0                -->Numero ISPB
                               ,pr_nrcnpjif IN INTEGER                          -->CNPJ do Banco Participante da PCPS
                               ,pr_xmllog   IN VARCHAR2 DEFAULT NULL            -->XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                     -->Código da crítica
                               ,pr_dscritic OUT VARCHAR2                        -->Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType               -->Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                        -->Nome do Campo
                               ,pr_des_erro OUT VARCHAR2) IS          -->Erros do processo
     /*---------------------------------------------------------------------------------------------------------------
     Programa: pc_altera_cnpj_banco       Antiga: 
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Marcelo Ricardo Kestring (Supero)
     Data    : 25/10/2018                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Processar a rotina de alteração de CNPJ da tela BANCOS.

     Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------*/


    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Cursor para buscar o nome do banco
    CURSOR cr_crapban IS
    SELECT crapban.nrcnpjif
      FROM crapban
     WHERE crapban.cdbccxlt = pr_cdbccxlt;
    rw_crapban cr_crapban%ROWTYPE;

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3);

    vr_tab_erro gene0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dscnpjde VARCHAR2(100);
    vr_dscnpjpr VARCHAR2(100);

    vr_retornvl  VARCHAR2(3):= 'NOK';

    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;
    vr_exc_saida EXCEPTION;
    
    -- Variável exceção para locke
    vr_exc_locked EXCEPTION;
    PRAGMA EXCEPTION_INIT(vr_exc_locked, -54);

    --> Tabela de retorno do operadores que estao alocando a tabela especifidada
    vr_tab_locktab GENE0001.typ_tab_locktab;
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
             
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Buscar informações do banco
      OPEN  cr_crapban;
      FETCH cr_crapban INTO rw_crapban;
      
      -- Se não encontrar o banco
      IF cr_crapban%NOTFOUND THEN
        -- fechar o cursor
        CLOSE cr_crapban;
      
        vr_dscritic := 'Banco nao encontrado!';
        RAISE vr_exc_erro;
      END IF;
      
      -- fechar o cursor
      CLOSE cr_crapban;
      
      
      BEGIN
        
       UPDATE crapban 
          SET crapban.nrcnpjif = NVL(pr_nrcnpjif,0)
       WHERE crapban.nrispbif = pr_nrispbif;

       EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar Banco: '||SQLERRM;
          RAISE vr_exc_erro;
      END;


      --Retorno
      pr_des_erro:= 'OK';
      COMMIT;
      
      IF pr_nrcnpjif <> rw_crapban.nrcnpjif   THEN
        
        vr_dscnpjde := GENE0002.fn_mask_cpf_cnpj(rw_crapban.nrcnpjif,2);
        vr_dscnpjpr := GENE0002.fn_mask_cpf_cnpj(pr_nrcnpjif,2);
        
        -- Inclui mensagem no log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                   pr_ind_tipo_log => 1, -- Somente mensagem
                                   pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss') || ' --> '
                                                   || 'Operador: ' || vr_cdoperad || ' | '
                                                   || 'ISPB: ' || to_char(pr_nrispbif, '00000000') || ' | ' 
                                                   || ' Alterou o numero CNPJ do banco de '
                                                   || vr_dscnpjde || ' para '
                                                   || vr_dscnpjpr,
                                   pr_nmarqlog     => 'bancos.log' );

      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';

        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;

        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     

      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na banc0001.pc_altera_banco_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_altera_cnpj_banco;


END BANC0001;
/
