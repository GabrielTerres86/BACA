CREATE OR REPLACE PACKAGE CECRED.IINF0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : IINF0001
  --  Sistema  : Rotinas genericas referente a CADINF
  --  Sigla    : IINF
  --  Autor    : Jéssica Laverde Gracino (DB1)
  --  Data     : Agosto - 2015.                   Ultima atualizacao: 20/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a CADINF

  -- Alteracoes: 20/06/2016 - Correcao para o uso da function fn_busca_dstextab da TABE0001 em 
  --                          varias procedures desta package.(Carlos Rafael Tanholi). 
  ---------------------------------------------------------------------------------------------------------------

  /* Cooperativa Dispoe */
  TYPE typ_cadinf IS RECORD --(cadinf.p/w-cadinf) 
    (cdprogra INTEGER    
    ,cdrelato INTEGER    
    ,cdfenvio INTEGER      
    ,cdperiod INTEGER    
    ,envcpttl VARCHAR2(5)    
    ,envcobrg VARCHAR2(500) 
    ,nmrelato VARCHAR2(500)   
    ,dsfenvio VARCHAR2(500)   
    ,dsperiod VARCHAR2(500)
    ,existcra VARCHAR2(2)  
    ,todostit INTEGER
    ,nrdrowid ROWID); 
    
  --Tipo de Tabela de Cooperativa Dispoe
  TYPE typ_tab_cadinf IS TABLE OF typ_cadinf INDEX BY PLS_INTEGER;
  
  /* CECRED Dispoe */
  TYPE typ_informa IS RECORD --(cadinf.p/w-informa)  
    (cdprogra INTEGER 
    ,cdrelato INTEGER 
    ,cdfenvio INTEGER 
    ,cdperiod INTEGER 
    ,envcpttl INTEGER 
    ,nmrelato VARCHAR2(500)
    ,dsfenvio VARCHAR2(500)
    ,dsperiod VARCHAR2(500)
    ,cddfrenv INTEGER);

  --Tipo de Tabela de CECRED Dispoe
  TYPE typ_tab_informa IS TABLE OF typ_informa INDEX BY PLS_INTEGER;  
  
  /* Rotina referente a consulta de informativos Modo Web */
  PROCEDURE pc_consulta_informativo_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL           -->Data Movimento                                       
                                       ,pr_xmllog   IN VARCHAR2 DEFAULT NULL           -->XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER                    -->Código da crítica
                                       ,pr_dscritic OUT VARCHAR2                       -->Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType              -->Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2                       -->Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);                     -->Saida OK/NOK

  /* Rotina referente a consulta de informativos Modo Caracter */
  PROCEDURE pc_consulta_informativo_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                       ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                       ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                       ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                       ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento                                       
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                       ,pr_clob_ret OUT CLOB                 --> Tabela clob                                       
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                       ,pr_dscritic OUT VARCHAR2);           --> Descricao Erro

  /* Rotina referente a seleção de informativos para inclusão Modo Caracter */
  PROCEDURE pc_seleciona_informativo_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                        ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                        ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                        ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                        ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento                                                                               
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                        ,pr_clob_ret OUT CLOB                 --> Tabela clob                                       
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                        ,pr_dscritic OUT VARCHAR2);           --> Descricao Erro

  /* Rotina referente a seleção de informativos para inclusão Modo Web */
  PROCEDURE pc_seleciona_informativo_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL -->Data Movimento
                                        ,pr_xmllog   IN VARCHAR2 DEFAULT NULL -->XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          -->Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             -->Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    -->Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             -->Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2);           -->Saida OK/NOK


  /* Rotina referente a inclusao de informativos Modo Caracter */
  PROCEDURE pc_inclui_informativo_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                     ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                     ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                     ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                     ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                                     ,pr_cdrelato IN INTEGER  DEFAULT NULL --Cod.do informativo
                                     ,pr_cdprogra IN INTEGER  DEFAULT NULL --Cod.do programa
                                     ,pr_cddfrenv IN INTEGER  DEFAULT NULL --Cod.forma de envio
                                     ,pr_cdperiod IN INTEGER  DEFAULT NULL --Cod.periodicidade
                                     ,pr_flgobrig IN INTEGER             --Obrigatório
                                     ,pr_flgtitul IN INTEGER           --Possui Titular                                                                                                                                              
                                     ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                                     ,pr_clob_ret OUT CLOB                 --Tabela Informativos                                 
                                     ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                                     ,pr_dscritic OUT VARCHAR2);           --Descricao Erro

  /* Rotina referente a inclusão de informativos Modo Web */
  PROCEDURE pc_inclui_informativo_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL -->Data Movimento
                                     ,pr_flgtitul IN INTEGER              -->Possui Titular
                                     ,pr_flgobrig IN INTEGER              -->Obrigatório     
                                     ,pr_cdrelato IN INTEGER  DEFAULT NULL --Cod.do informativo
                                     ,pr_cdprogra IN INTEGER  DEFAULT NULL --Cod.do programa
                                     ,pr_cddfrenv IN INTEGER  DEFAULT NULL --Cod.forma de envio
                                     ,pr_cdperiod IN INTEGER  DEFAULT NULL --Cod.periodicidade                                
                                     ,pr_xmllog   IN VARCHAR2 DEFAULT NULL -->XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          -->Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             -->Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    -->Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             -->Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);           -->Saida OK/NOK

  /* Rotina referente a inclusao de informativos Modo Caracter */
  PROCEDURE pc_altera_informativo_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                     ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                     ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                     ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                     ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                                     ,pr_cdrelato IN INTEGER  DEFAULT NULL --Cod.do informativo
                                     ,pr_cdprogra IN INTEGER  DEFAULT NULL --Cod.do programa
                                     ,pr_cddfrenv IN INTEGER  DEFAULT NULL --Cod.forma de envio
                                     ,pr_cdperiod IN INTEGER  DEFAULT NULL --Cod.periodicidade
                                     ,pr_flgtitul IN INTEGER          --Possui Titular
                                     ,pr_flgobrig IN INTEGER          --Obrigatório                                                                                                         
                                     ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                                     ,pr_clob_ret OUT CLOB                 --Tabela XML                                 
                                     ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                                     ,pr_dscritic OUT VARCHAR2);           --Descricao Erro

  /* Rotina referente a alteração de informativos Modo Web */
  PROCEDURE pc_altera_informativo_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL -->Data Movimento
                                     ,pr_flgtitul IN INTEGER              -->Todos titulares?
                                     ,pr_flgobrig IN INTEGER              -->Envio obrigatorio?
                                     ,pr_nrdrowid IN  ROWID                -->Rowid do registro
                                     ,pr_xmllog   IN VARCHAR2 DEFAULT NULL -->XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          -->Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             -->Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    -->Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             -->Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);           -->Saida OK/NOK

  /* Rotina referente a consulta de informativos Modo Web */
  PROCEDURE pc_exclui_informativo_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL -->Data Movimento
                                     ,pr_rowid    IN ROWID                 -->Rowid do registro
                                     ,pr_fldelcra IN INTEGER DEFAULT NULL -->Deletar crapcra
                                     ,pr_xmllog   IN VARCHAR2 DEFAULT NULL -->XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          -->Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             -->Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    -->Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             -->Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);           -->Saida OK/NOK

  /* Rotina referente a consulta de informativos Modo Caracter */
  PROCEDURE pc_exclui_informativo_car(pr_cdcooper IN crapcop.cdcooper%type  -->Codigo Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                     ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                     ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                                     ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                     ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                                     ,pr_cdrelato IN INTEGER  DEFAULT NULL -->Cod.do informativo
                                     ,pr_cdprogra IN INTEGER  DEFAULT NULL -->Cod.do programa
                                     ,pr_cddfrenv IN INTEGER  DEFAULT NULL -->Cod.forma de envio
                                     ,pr_cdperiod IN INTEGER  DEFAULT NULL -->Cod.periodicidade
                                     ,pr_fldelcra IN INTEGER DEFAULT NULL --> Deletar crapcra
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                     ,pr_clob_ret OUT CLOB                 --> Tabela clob
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                     ,pr_dscritic OUT VARCHAR2);           --> Descricao Erro
   
  
                               
END IINF0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.IINF0001 AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: IINF0001
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Jéssica Laverde Gracino (DB1)
   Data    : 06/08/2015                        Ultima atualizacao: 20/06/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Controle de Informativos e Formas de Envio Aceitas
               pela Cooperativa.

   Alteracoes: 20/06/2016 - Correcao para o uso da function fn_busca_dstextabem da TABE0001 em 
                            varias procedures desta package.(Carlos Rafael Tanholi). 
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

  /* Rotina referente a consulta de informativos */
  PROCEDURE pc_consulta_informativo(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                   ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                   ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                                   ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                   ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento                                                                      
                                   ,pr_nmdcampo OUT VARCHAR2    -->Nome do campo com erro
                                   ,pr_tab_cadinf OUT IINF0001.typ_tab_cadinf --Tabela w-Cadinf                                   
                                   ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                                   ,pr_des_erro OUT VARCHAR2) IS -->Erros do processo
     /*---------------------------------------------------------------------------------------------------------------
     Programa: pc_consulta_informativo       Antiga: 
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 06/08/2015                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Processar a rotina de consulta da tela CADINF.

     Alteracoes: 06/08/2015 - Conversao Progress >> Oracle (PLSQL) - Jéssica (DB1)
    ---------------------------------------------------------------------------------------------------------------*/

-------------------Cursores-------------------------------------
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

    -- Busca dos dados dos informativos
    CURSOR cr_crapifc IS
    SELECT crapifc.cdprogra
          ,crapifc.cdrelato
          ,crapifc.cddfrenv
          ,crapifc.cdperiod
          ,crapifc.envcpttl
          ,crapifc.envcobrg
          ,ROWID
      FROM crapifc
     WHERE crapifc.cdcooper = pr_cdcooper
  ORDER BY crapifc.cdprogra;
    rw_crapifc cr_crapifc%ROWTYPE;

    -- Busca relatorios do sistema que podem ser disponibizados para os associados
    CURSOR cr_gnrlema(pr_cdprogra IN crapifc.cdprogra%TYPE
                     ,pr_cdrelato IN crapifc.cdrelato%TYPE) IS
    SELECT gnrlema.cdrelato,
           gnrlema.nmrelato
      FROM gnrlema
     WHERE gnrlema.cdprogra = pr_cdprogra
       AND gnrlema.cdrelato = pr_cdrelato;
    rw_gnrlema cr_gnrlema%ROWTYPE;

    
    CURSOR cr_gnfepri(pr_cdrelato IN crapifc.cdrelato%TYPE
                     ,pr_cdprogra IN crapifc.cdprogra%TYPE
                     ,pr_cddfrenv IN crapifc.cddfrenv%TYPE
                     ,pr_cdperiod IN crapifc.cdperiod%TYPE)IS
    SELECT gnfepri.envcpttl
      FROM gnfepri
     WHERE gnfepri.cdrelato = pr_cdrelato
       AND gnfepri.cdprogra = pr_cdprogra
       AND gnfepri.cddfrenv = pr_cddfrenv
       AND gnfepri.cdperiod = pr_cdperiod;
    rw_gnfepri cr_gnfepri%ROWTYPE;
------------------------Variaveis-------------------------------

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    --Variaveis de Indice
    vr_index PLS_INTEGER;    

    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;
    vr_exc_saida EXCEPTION;
    -- Guardar registro dstextab
    vr_dstextab craptab.dstextab%TYPE;          
    
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
      
      FOR rw_crapifc IN cr_crapifc LOOP

        vr_index := vr_index + 1;             

        pr_tab_cadinf(vr_index).cdprogra := rw_crapifc.cdprogra;
        pr_tab_cadinf(vr_index).cdrelato := rw_crapifc.cdrelato;
        pr_tab_cadinf(vr_index).cdfenvio := rw_crapifc.cddfrenv;
        pr_tab_cadinf(vr_index).cdperiod := rw_crapifc.cdperiod;
        pr_tab_cadinf(vr_index).envcpttl := rw_crapifc.envcpttl;
        pr_tab_cadinf(vr_index).envcobrg := rw_crapifc.envcobrg;
        pr_tab_cadinf(vr_index).nrdrowid := rw_crapifc.rowid;
        
        -- Verifica se existe registro
        OPEN cr_gnrlema (pr_cdprogra => rw_crapifc.cdprogra
                        ,pr_cdrelato => rw_crapifc.cdrelato);

        FETCH cr_gnrlema INTO rw_gnrlema;

        -- Se encontrar
        IF cr_gnrlema%FOUND THEN

          pr_tab_cadinf(vr_index).nmrelato := rw_gnrlema.nmrelato;
          
          CLOSE cr_gnrlema;

        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_gnrlema;
        END IF;
        
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 0
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'FORENVINFO'
                                                 ,pr_tpregist => rw_crapifc.cddfrenv);

        -- Se encontrar
        IF TRIM(vr_dstextab) IS NOT NULL THEN

          pr_tab_cadinf(vr_index).dsfenvio := substr(vr_dstextab,instr(vr_dstextab,',')+1);

          IF pr_tab_cadinf(vr_index).dsfenvio = 'CRAPCEM' THEN
             pr_tab_cadinf(vr_index).dsfenvio := 'E-MAIL';

          ELSIF pr_tab_cadinf(vr_index).dsfenvio = 'CRAPTFC,2' THEN
             pr_tab_cadinf(vr_index).dsfenvio := 'CELULAR';

          ELSIF pr_tab_cadinf(vr_index).dsfenvio = 'CRAPENC,12' THEN
             pr_tab_cadinf(vr_index).dsfenvio := 'CORREIO RESIDENCIAL';
             
          ELSIF pr_tab_cadinf(vr_index).dsfenvio = 'CRAPENC,9' THEN
             pr_tab_cadinf(vr_index).dsfenvio := 'CORREIO COMERCIAL';

          END IF;

        END IF;        

        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 0
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'PERIODICID'
                                                 ,pr_tpregist => rw_crapifc.cdperiod);

        -- Se encontrar
        IF TRIM(vr_dstextab) IS NOT NULL THEN
          pr_tab_cadinf(vr_index).dsperiod := vr_dstextab;
        END IF;
                
        -- Verificar controle para todos os titulares
        OPEN cr_gnfepri(pr_cdrelato => rw_crapifc.cdrelato
                       ,pr_cdprogra => rw_crapifc.cdprogra
                       ,pr_cddfrenv => rw_crapifc.cddfrenv
                       ,pr_cdperiod => rw_crapifc.cdperiod);

        FETCH cr_gnfepri INTO rw_gnfepri;

        -- Se encontrar
        IF cr_gnfepri%FOUND THEN        
          pr_tab_cadinf(vr_index).todostit := rw_gnfepri.envcpttl;

          CLOSE cr_gnfepri;    
              
        ELSE  
          vr_dscritic := 'Tabela gnferi nao foi encontrada.';
          RAISE vr_exc_erro;
        END IF; 

        pr_tab_cadinf(vr_index).existcra := 1;

        IF rw_crapifc.envcpttl = 0 THEN 

           pr_tab_cadinf(vr_index).existcra := 0;

        ELSE

           pr_tab_cadinf(vr_index).existcra := 1;

        END IF;       

      END LOOP;

      -- Retorno OK
      pr_des_erro:= 'OK';
          
    EXCEPTION
      WHEN vr_exc_erro THEN

        -- Retorno não OK
        pr_des_erro:= 'NOK';

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
        vr_dscritic := 'Erro na IINF0001.pc_consulta_informativo --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);


  END pc_consulta_informativo;
  
  /* Rotina referente a consulta de informativos Modo Caracter */
  PROCEDURE pc_consulta_informativo_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                       ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                       ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                       ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                       ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento                                       
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                       ,pr_clob_ret OUT CLOB                 --> Tabela clob                                       
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                       ,pr_dscritic OUT VARCHAR2) IS         --> Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_consulta_informativo_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 06/08/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a consulta de informativos modo Caracter

    Alteracoes: 06/08/2015 - Desenvolvimento - Jéssica (DB1)
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3) := NULL; 

    --Tabelas de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    vr_tab_cadinf IINF0001.typ_tab_cadinf;
    
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
      vr_tab_cadinf.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      --Consultar Informativos Cadastrados
      IINF0001.pc_consulta_informativo(pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                      ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                      ,pr_nrdcaixa => pr_nrdcaixa  --Numero Caixa
                                      ,pr_idorigem => pr_idorigem  --Origem Processamento
                                      ,pr_cdoperad => pr_cdoperad  --Operador
                                      ,pr_nmdatela => pr_nmdatela  --Nome da tela                                
                                      ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento                                                                                                      
                                      ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                      ,pr_tab_cadinf => vr_tab_cadinf --Tabela Contratos
                                      ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                      ,pr_des_erro => vr_des_reto); --Saida OK/NOK


      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a IINF0001.pc_consulta_informativo.';
        END IF;    
        
        --Levantar Excecao
        RAISE vr_exc_erro;
                           
      END IF;

      --Montar CLOB
      IF vr_tab_cadinf.COUNT > 0 THEN
        
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clob_ret, TRUE); 
        dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);
        
        -- Insere o cabeçalho do XML 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
         
        --Buscar Primeiro contrato
        vr_index:= vr_tab_cadinf.FIRST;
        
        --Percorrer todos os contratos
        WHILE vr_index IS NOT NULL LOOP
          vr_string:= '<inf>'||
                      '<cdprogra>'||NVL(TO_CHAR(vr_tab_cadinf(vr_index).cdprogra),'0')|| '</cdprogra>'|| 
                      '<cdrelato>'||NVL(TO_CHAR(vr_tab_cadinf(vr_index).cdrelato),'0')|| '</cdrelato>'|| 
                      '<cdfenvio>'||NVL(TO_CHAR(vr_tab_cadinf(vr_index).cdfenvio),'0')|| '</cdfenvio>'|| 
                      '<cdperiod>'||NVL(TO_CHAR(vr_tab_cadinf(vr_index).cdperiod),'0')|| '</cdperiod>'|| 
                      '<envcpttl>'||NVL(TO_CHAR(vr_tab_cadinf(vr_index).envcpttl),'0')|| '</envcpttl>'|| 
                      '<envcobrg>'||NVL(TO_CHAR(vr_tab_cadinf(vr_index).envcobrg),' ')|| '</envcobrg>'|| 
                      '<nmrelato>'||NVL(TO_CHAR(vr_tab_cadinf(vr_index).nmrelato),' ')|| '</nmrelato>'||
                      '<dsfenvio>'||NVL(TO_CHAR(vr_tab_cadinf(vr_index).dsfenvio),' ')|| '</dsfenvio>'||
                      '<dsperiod>'||NVL(TO_CHAR(vr_tab_cadinf(vr_index).dsperiod),' ')|| '</dsperiod>'||
                      '<todostit>'||NVL(TO_CHAR(vr_tab_cadinf(vr_index).todostit),'0')|| '</todostit>'||
                      '<nrdrowid>'||NVL(TO_CHAR(vr_tab_cadinf(vr_index).nrdrowid),' ')|| '</nrdrowid>'||
                      '<existcra>'||NVL(TO_CHAR(vr_tab_cadinf(vr_index).existcra),' ')|| '</existcra>'||
                      '</inf>';

          -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                                 ,pr_texto_completo => vr_dstexto 
                                 ,pr_texto_novo     => vr_string
                                 ,pr_fecha_xml      => FALSE);   
                                                    
          --Proximo Registro
          vr_index:= vr_tab_cadinf.NEXT(vr_index);
          
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
        pr_dscritic:= 'Erro na IINF0001.pc_consulta_informativo_car --> '|| SQLERRM;

  END pc_consulta_informativo_car;

  /* Rotina referente a consulta de informativos Modo Web */
  PROCEDURE pc_consulta_informativo_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL -->Data Movimento 
                                       ,pr_xmllog   IN VARCHAR2 DEFAULT NULL -->XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          -->Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             -->Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    -->Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             -->Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2) IS         -->Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_consulta_informativo_web      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 06/08/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a consulta de informativos modo Web

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3) := NULL; 
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    vr_tab_cadinf IINF0001.typ_tab_cadinf;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
        
    --Variaveis Arquivo Dados
    vr_dtmvtolt DATE;
    vr_auxconta PLS_INTEGER:= 0;
       
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
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
            
      --Consultar Informativos
      IINF0001.pc_consulta_informativo(pr_cdcooper => vr_cdcooper  --Codigo Cooperativa
                                      ,pr_cdagenci => vr_cdagenci  --Codigo Agencia
                                      ,pr_nrdcaixa => vr_nrdcaixa  --Numero Caixa
                                      ,pr_idorigem => vr_idorigem  --Origem Processamento
                                      ,pr_cdoperad => vr_cdoperad  --Operador
                                      ,pr_nmdatela => vr_nmdatela  --Nome da tela                                
                                      ,pr_dtmvtolt => vr_dtmvtolt  --Data Movimento                                                                                                      
                                      ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                      ,pr_tab_cadinf => vr_tab_cadinf --Tabela Contratos                                      
                                      ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                      ,pr_des_erro => vr_des_reto); --Saida OK/NOK                                      
     
      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na IINF0001.pc_consulta_informativo.';
        END IF;  
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF; 
      
      --Montar CLOB
      IF vr_tab_cadinf.COUNT > 0 THEN

        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
                
        --Buscar Primeiro beneficiario
        vr_index:= vr_tab_cadinf.FIRST;
        
        --Percorrer todos os beneficiarios
        WHILE vr_index IS NOT NULL LOOP

          -- Insere as tags dos campos da PLTABLE de aplicações
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdprogra', pr_tag_cont => TO_CHAR(vr_tab_cadinf(vr_index).cdprogra), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdrelato', pr_tag_cont => TO_CHAR(vr_tab_cadinf(vr_index).cdrelato), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdfenvio', pr_tag_cont => TO_CHAR(vr_tab_cadinf(vr_index).cdfenvio), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdperiod', pr_tag_cont => TO_CHAR(vr_tab_cadinf(vr_index).cdperiod), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'envcpttl', pr_tag_cont => TO_CHAR(vr_tab_cadinf(vr_index).envcpttl), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'envcobrg', pr_tag_cont => TO_CHAR(vr_tab_cadinf(vr_index).envcobrg), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmrelato', pr_tag_cont => TO_CHAR(vr_tab_cadinf(vr_index).nmrelato), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsfenvio', pr_tag_cont => TO_CHAR(vr_tab_cadinf(vr_index).dsfenvio), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsperiod', pr_tag_cont => TO_CHAR(vr_tab_cadinf(vr_index).dsperiod), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdrowid', pr_tag_cont => TO_CHAR(vr_tab_cadinf(vr_index).nrdrowid), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'todostit', pr_tag_cont => TO_CHAR(vr_tab_cadinf(vr_index).todostit), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'existcra', pr_tag_cont => TO_CHAR(vr_tab_cadinf(vr_index).existcra), pr_des_erro => vr_dscritic);
          
          -- Incrementa contador p/ posicao no XML
          vr_auxconta := vr_auxconta + 1;

          --Proximo Registro
          vr_index:= vr_tab_cadinf.NEXT(vr_index);
          
        END LOOP;
      ELSE
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');    
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
        pr_dscritic:= 'Erro na IINF0001.pc_consulta_informativo_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
                                         
  END pc_consulta_informativo_web;

  /* Rotina referente a seleção de informativos para inclusão*/
  PROCEDURE pc_seleciona_informativo(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                    ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                                    ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                    ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento                                     
                                    ,pr_nmdcampo OUT VARCHAR2    -->Nome do campo com erro
                                    ,pr_tab_informa OUT IINF0001.typ_tab_informa --Tabela w-inform
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                                    ,pr_des_erro OUT VARCHAR2) IS -->Erros do processo
     /*---------------------------------------------------------------------------------------------------------------
     Programa: pc_seleciona_informativo       Antiga: 
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 06/08/2015                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Processar a rotina de selecionar informativo para inclusão da tela CADINF.

     Alteracoes: 06/08/2015 - Conversao Progress >> Oracle (PLSQL) - Jéssica (DB1)
    ---------------------------------------------------------------------------------------------------------------*/

-------------------Cursores-------------------------------------
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

    -- Busca dos dados dos informativos
    CURSOR cr_crapifc (pr_cdcooper IN crapifc.cdcooper%TYPE
                      ,pr_cdprogra IN gnfepri.cdprogra%TYPE
                      ,pr_cdrelato IN gnfepri.cdrelato%TYPE
                      ,pr_cddfrenv IN gnfepri.cddfrenv%TYPE
                      ,pr_cdperiod IN gnfepri.cdperiod%TYPE) IS
    SELECT crapifc.cdprogra
          ,crapifc.cdrelato
          ,crapifc.cddfrenv
          ,crapifc.cdperiod
          ,crapifc.envcpttl
          ,crapifc.envcobrg
      FROM crapifc
     WHERE crapifc.cdcooper = pr_cdcooper
       AND crapifc.cdprogra = pr_cdprogra 
       AND crapifc.cdrelato = pr_cdrelato 
       AND crapifc.cddfrenv = pr_cddfrenv 
       AND crapifc.cdperiod = pr_cdperiod;
    rw_crapifc cr_crapifc%ROWTYPE;

    -- Busca relatorios do sistema que podem ser disponibizados para os associados
    CURSOR cr_gnrlema(pr_cdprogra IN gnfepri.cdprogra%TYPE
                     ,pr_cdrelato IN gnfepri.cdrelato%TYPE) IS
    SELECT gnrlema.cdrelato,
           gnrlema.nmrelato
      FROM gnrlema
     WHERE gnrlema.cdprogra = pr_cdprogra
       AND gnrlema.cdrelato = pr_cdrelato;
    rw_gnrlema cr_gnrlema%ROWTYPE;
    
    CURSOR cr_gnfepri IS
    SELECT gnfepri.cdrelato
          ,gnfepri.cdprogra
          ,gnfepri.cddfrenv
          ,gnfepri.cdperiod
          ,gnfepri.envcpttl
      FROM gnfepri;     
    rw_gnfepri cr_gnfepri%ROWTYPE;
      
    ---------------------Variaveis----------------------------------

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;
    vr_exc_saida EXCEPTION;
    -- Guardar registro dstextab
    vr_dstextab craptab.dstextab%TYPE;          

    BEGIN

      --Inicializar Variaveis
      vr_cdcritic := 0;
      vr_dscritic := NULL;    
      vr_index := 0;  

      pr_tab_informa.DELETE;
      
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

      -- Leitura para busca de informativos
      FOR rw_gnfepri IN cr_gnfepri LOOP

        -- Verifica todos os informativos para a cooperativa cadastrada
        OPEN cr_crapifc (pr_cdcooper => pr_cdcooper
                        ,pr_cdprogra => rw_gnfepri.cdprogra
                        ,pr_cdrelato => rw_gnfepri.cdrelato
                        ,pr_cddfrenv => rw_gnfepri.cddfrenv
                        ,pr_cdperiod => rw_gnfepri.cdperiod);

        FETCH cr_crapifc INTO rw_crapifc;

        -- Se encontrar
        IF cr_crapifc%FOUND THEN                     
          CLOSE cr_crapifc;
          CONTINUE;         
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_crapifc;
        END IF;
        
        vr_index := vr_index + 1;

        pr_tab_informa(vr_index).cdprogra := rw_gnfepri.cdprogra;
        pr_tab_informa(vr_index).cdrelato := rw_gnfepri.cdrelato;
        pr_tab_informa(vr_index).cdfenvio := rw_gnfepri.cddfrenv;
        pr_tab_informa(vr_index).cdperiod := rw_gnfepri.cdperiod;
        pr_tab_informa(vr_index).envcpttl := rw_gnfepri.envcpttl;
        pr_tab_informa(vr_index).cddfrenv := rw_gnfepri.cddfrenv;

        -- Verifica todos os informativos para a cooperativa cadastrada
        OPEN cr_gnrlema (pr_cdprogra => rw_gnfepri.cdprogra
                        ,pr_cdrelato => rw_gnfepri.cdrelato);

        FETCH cr_gnrlema INTO rw_gnrlema;

        -- Se encontrar
        IF cr_gnrlema%FOUND THEN
          pr_tab_informa(vr_index).nmrelato := rw_gnrlema.nmrelato;

          -- Apenas fechar o cursor
          CLOSE cr_gnrlema;          
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_gnrlema;
        END IF;        
       
        -- Buscar configuração na tabela
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 0
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'FORENVINFO'
                                                 ,pr_tpregist => rw_gnfepri.cddfrenv);        

        -- Se encontrar
        IF TRIM(vr_dstextab) IS NOT NULL THEN

          pr_tab_informa(vr_index).dsfenvio := substr(vr_dstextab,instr(vr_dstextab,',')+1);
          
          IF pr_tab_informa(vr_index).dsfenvio = 'CRAPCEM' THEN
             pr_tab_informa(vr_index).dsfenvio := 'E-MAIL';

          ELSIF pr_tab_informa(vr_index).dsfenvio = 'CRAPTFC,2' THEN
             pr_tab_informa(vr_index).dsfenvio := 'CELULAR';

          ELSIF pr_tab_informa(vr_index).dsfenvio = 'CRAPENC,12' THEN
             pr_tab_informa(vr_index).dsfenvio := 'CORREIO RESIDENCIAL';
             
          ELSIF pr_tab_informa(vr_index).dsfenvio = 'CRAPENC,9' THEN
             pr_tab_informa(vr_index).dsfenvio := 'CORREIO COMERCIAL';

          END IF;

        END IF;        

        -- Buscar configuração na tabela
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 0
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'PERIODICID'
                                                 ,pr_tpregist => rw_gnfepri.cdperiod);       

        -- Se encontrar
        IF TRIM(vr_dstextab) IS NOT NULL THEN
          pr_tab_informa(vr_index).dsperiod := vr_dstextab;
        END IF;        

      END LOOP;

      --Retorno OK
      pr_des_erro := 'OK';

    EXCEPTION
      WHEN vr_exc_erro THEN

        -- Retorno não OK
        pr_des_erro:= 'NOK';

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
        vr_dscritic := 'Erro na IINF0001.pc_seleciona_informativo --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);


  END pc_seleciona_informativo;

  /* Rotina referente a seleção de informativos para inclusão Modo Caracter */
  PROCEDURE pc_seleciona_informativo_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                        ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                        ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                        ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                        ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento                                                                               
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                        ,pr_clob_ret OUT CLOB                 --> Tabela clob                                       
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                        ,pr_dscritic OUT VARCHAR2) IS         --> Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_seleciona_informativo_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 06/08/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a seleção de informativos para inclusão modo Caracter

    Alteracoes: 06/08/2015 - Desenvolvimento - Jéssica (DB1)
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3) := NULL; 

    --Tabelas de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    vr_tab_informa IINF0001.typ_tab_informa;
    
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
      vr_tab_informa.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      --Selecionar informativos para inclusão
      IINF0001.pc_seleciona_informativo(pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                       ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                       ,pr_nrdcaixa => pr_nrdcaixa  --Numero Caixa
                                       ,pr_idorigem => pr_idorigem  --Origem Processamento
                                       ,pr_cdoperad => pr_cdoperad  --Operador
                                       ,pr_nmdatela => pr_nmdatela  --Nome da tela                                
                                       ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento                                                                               
                                       ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                       ,pr_tab_informa => vr_tab_informa --Tabela cadinf
                                       ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                       ,pr_des_erro => vr_des_reto); --Saida OK/NOK */ 

      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a IINF0001.pc_seleciona_informativo.';
        END IF;    
        
        --Levantar Excecao
        RAISE vr_exc_erro;
                           
      END IF;

      --Montar CLOB
      IF vr_tab_informa.COUNT > 0 THEN
        
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clob_ret, TRUE); 
        dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);
        
        -- Insere o cabeçalho do XML 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
         
        --Buscar Primeiro contrato
        vr_index:= vr_tab_informa.FIRST;
        
        --Percorrer todos os contratos
        WHILE vr_index IS NOT NULL LOOP
          vr_string:= '<inf>'||
                      '<cdprogra>'||NVL(TO_CHAR(vr_tab_informa(vr_index).cdprogra),'0')|| '</cdprogra>'|| 
                      '<cdrelato>'||NVL(TO_CHAR(vr_tab_informa(vr_index).cdrelato),'0')|| '</cdrelato>'|| 
                      '<cdfenvio>'||NVL(TO_CHAR(vr_tab_informa(vr_index).cdfenvio),'0')|| '</cdfenvio>'|| 
                      '<cdperiod>'||NVL(TO_CHAR(vr_tab_informa(vr_index).cdperiod),'0')|| '</cdperiod>'|| 
                      '<envcpttl>'||NVL(TO_CHAR(vr_tab_informa(vr_index).envcpttl),'0')|| '</envcpttl>'||                       
                      '<nmrelato>'||NVL(TO_CHAR(vr_tab_informa(vr_index).nmrelato),' ')|| '</nmrelato>'||
                      '<dsfenvio>'||NVL(TO_CHAR(vr_tab_informa(vr_index).dsfenvio),' ')|| '</dsfenvio>'||
                      '<dsperiod>'||NVL(TO_CHAR(vr_tab_informa(vr_index).dsperiod),' ')|| '</dsperiod>'||                      
                      '</inf>';

          -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                                 ,pr_texto_completo => vr_dstexto 
                                 ,pr_texto_novo     => vr_string
                                 ,pr_fecha_xml      => FALSE);   
                                                    
          --Proximo Registro
          vr_index:= vr_tab_informa.NEXT(vr_index);
          
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
        pr_dscritic:= 'Erro na IINF0001.pc_consulta_informativo_car --> '|| SQLERRM;

  END pc_seleciona_informativo_car; 

  /* Rotina referente a seleção de informativos para inclusão Modo Web */
  PROCEDURE pc_seleciona_informativo_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL -->Data Movimento
                                        ,pr_xmllog   IN VARCHAR2 DEFAULT NULL -->XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          -->Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             -->Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    -->Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             -->Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2) IS         -->Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_seleciona_informativo_web      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 11/08/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a selecão de Informativos modo Web

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3) := NULL; 
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    vr_tab_informa IINF0001.typ_tab_informa;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_mensagem VARCHAR2(500);
           
    --Variaveis Arquivo Dados
    vr_dtmvtolt DATE;
    vr_auxconta PLS_INTEGER:= 0;
        
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
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
                
      --Busca Informativos a serem incluídos
      IINF0001.pc_seleciona_informativo(pr_cdcooper => vr_cdcooper  --Codigo Cooperativa
                                       ,pr_cdagenci => vr_cdagenci  --Codigo Agencia
                                       ,pr_nrdcaixa => vr_nrdcaixa  --Numero Caixa
                                       ,pr_idorigem => vr_idorigem  --Origem Processamento
                                       ,pr_cdoperad => vr_cdoperad  --Operador
                                       ,pr_nmdatela => vr_nmdatela  --Nome da tela                                
                                       ,pr_dtmvtolt => vr_dtmvtolt  --Data Movimento                                        
                                       ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                       ,pr_tab_informa => vr_tab_informa --Tabela cadinf
                                       ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                       ,pr_des_erro => vr_des_reto); --Saida OK/NOK */  
                                       
      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na iinf0001.pc_seleciona_informativo.';
        END IF;  
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF; 

      --Montar CLOB
      IF vr_tab_informa.COUNT > 0 THEN

        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        --Buscar Primeiro avalista
        vr_index:= vr_tab_informa.FIRST;

        --Percorrer todos os avalistas
        WHILE vr_index IS NOT NULL LOOP

          -- Insere as tags dos campos da PLTABLE de avalistas
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdprogra', pr_tag_cont => TO_CHAR(vr_tab_informa(vr_index).cdprogra), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdrelato', pr_tag_cont => TO_CHAR(vr_tab_informa(vr_index).cdrelato), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdfenvio', pr_tag_cont => TO_CHAR(vr_tab_informa(vr_index).cdfenvio), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdperiod', pr_tag_cont => TO_CHAR(vr_tab_informa(vr_index).cdperiod), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'envcpttl', pr_tag_cont => TO_CHAR(vr_tab_informa(vr_index).envcpttl), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmrelato', pr_tag_cont => TO_CHAR(vr_tab_informa(vr_index).nmrelato), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsfenvio', pr_tag_cont => TO_CHAR(vr_tab_informa(vr_index).dsfenvio), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsperiod', pr_tag_cont => TO_CHAR(vr_tab_informa(vr_index).dsperiod), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cddfrenv', pr_tag_cont => TO_CHAR(vr_tab_informa(vr_index).cddfrenv), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'mensagem', pr_tag_cont => TO_CHAR(vr_mensagem), pr_des_erro => vr_dscritic);          

          -- Incrementa contador p/ posicao no XML
          vr_auxconta := vr_auxconta + 1;

          --Proximo Registro
          vr_index:= vr_tab_informa.NEXT(vr_index);

        END LOOP;
      ELSE
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
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
        pr_dscritic:= 'Erro na iinf0001.pc_seleciona_informativo_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_seleciona_informativo_web;   

  /* Rotina referente a inclusão de informativo */
  PROCEDURE pc_inclui_informativo(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                 ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                 ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                 ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                                 ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                 ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela
                                 ,pr_dtmvtolt IN VARCHAR2 DEFAULT NULL -->Data Movimento 
                                 ,pr_cdrelato IN INTEGER  DEFAULT NULL  -->Cod.do informativo
                                 ,pr_cdprogra IN INTEGER  DEFAULT NULL  -->Cod.do programa
                                 ,pr_cddfrenv IN INTEGER  DEFAULT NULL  -->Cod.forma de envio
                                 ,pr_cdperiod IN INTEGER  DEFAULT NULL  -->Cod.periodicidade    
                                 ,pr_flgobrig IN INTEGER              -->Obrigatório                                   
                                 ,pr_flgtitul IN INTEGER            -->Possui titular                                                            
                                 ,pr_cdcritic OUT PLS_INTEGER           -->Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              -->Descrição da crítica
                                 ,pr_nmdcampo OUT VARCHAR2              -->Nome do campo com erro                                  
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                                 ,pr_des_erro OUT VARCHAR2) IS          -->Erros do processo
     /*---------------------------------------------------------------------------------------------------------------
     Programa: pc_inclui_informativo       Antiga: 
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 06/08/2015                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Processar a rotina de inclusão da tela CADINF.

     Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------*/

    -----------------------CURSORES------------------------------
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

    ---------------------Variaveis----------------------------------

    --Variaveis de Criticas    
    vr_retornvl  VARCHAR2(3);

    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;
    vr_exc_saida EXCEPTION;

    BEGIN

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
        pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic);

       RAISE vr_exc_erro;

      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
            
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      
      FETCH btch0001.cr_crapdat iNTO rw_crapdat;
      
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        pr_cdcritic := 1;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
            
      BEGIN
        INSERT INTO crapifc 
                (cdcooper
                ,cdprogra
                ,cdrelato
                ,cddfrenv
                ,cdperiod
                ,envcobrg
                ,envcpttl)
         VALUES (pr_cdcooper,   
                 pr_cdprogra,
                 pr_cdrelato,    
                 pr_cddfrenv,    
                 pr_cdperiod,
                 pr_flgobrig,
                 pr_flgtitul);
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao inserir Informativo: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      --Gera log      
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'cadinf.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                    ' --> Operador: ' || pr_cdoperad || 
                                                    ' --> Inclusao do informativo - ' ||
                                                    'Programa: '|| pr_cdprogra || ', Codigo do relatorio: ' || pr_cdrelato || ', Forma de envio: ' ||
                                                    pr_cddfrenv || ', Periodicidade: ' || pr_cdperiod || ', Obrigatoriedade: ' || 
                                                    pr_flgobrig || ', Quem recebe:' || pr_flgtitul); 

      -- Retorno  OK
      pr_des_erro:= 'OK';
        
    EXCEPTION
      WHEN vr_exc_erro THEN

        -- Retorno não OK
        pr_des_erro:= vr_retornvl;

        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

      -- Efetuar rollback
      ROLLBACK;                                                          

      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';

        -- Chamar rotina de gravação de erro
        pr_dscritic := pr_dscritic || 'Erro na iinf0001.pc_inclui_informativo --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Efetuar rollback
        ROLLBACK;

  END pc_inclui_informativo;

  /* Rotina referente a inclusao de informativos Modo Caracter */
  PROCEDURE pc_inclui_informativo_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                     ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                     ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                     ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                     ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                                     ,pr_cdrelato IN INTEGER  DEFAULT NULL --Cod.do informativo
                                     ,pr_cdprogra IN INTEGER  DEFAULT NULL --Cod.do programa
                                     ,pr_cddfrenv IN INTEGER  DEFAULT NULL --Cod.forma de envio
                                     ,pr_cdperiod IN INTEGER  DEFAULT NULL --Cod.periodicidade
                                     ,pr_flgobrig IN INTEGER             --Obrigatório
                                     ,pr_flgtitul IN INTEGER           --Possui Titular                                                                         
                                     ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                                     ,pr_clob_ret OUT CLOB                 --Tabela Informativos                                 
                                     ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                                     ,pr_dscritic OUT VARCHAR2) IS         --Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_inclui_informativo_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 11/08/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a inclusão de informativos modo Caracter

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3) := NULL; 

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
      
      --Incluir Informativo      
      IINF0001.pc_inclui_informativo(pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                    ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                    ,pr_nrdcaixa => pr_nrdcaixa  --Numero Caixa
                                    ,pr_idorigem => pr_idorigem  --Origem Processamento
                                    ,pr_cdoperad => pr_cdoperad  --Operador
                                    ,pr_nmdatela => pr_nmdatela  --Nome da tela                                
                                    ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento 
                                    ,pr_cdrelato => pr_cdrelato  --Codigo do relatorio
                                    ,pr_cdprogra => pr_cdprogra  --Codigo do Programa
                                    ,pr_cddfrenv => pr_cddfrenv  --Codigo do envio
                                    ,pr_cdperiod => pr_cdperiod  --Codigo do período
                                    ,pr_flgobrig => pr_flgobrig  --Obrigatório
                                    ,pr_flgtitul => pr_flgtitul  --Possui Titular                                                                        
                                    ,pr_cdcritic => pr_cdcritic  --Codigo Erro
                                    ,pr_dscritic => pr_dscritic  --Descrição do Erro
                                    ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                    ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                    ,pr_des_erro => vr_des_reto); --Saida OK/NOK                                  
      

      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a iinf0001.pc_inclui_informativo.';
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
        pr_dscritic:= 'Erro na iinf0001.pc_inclui_informativo_car --> '|| SQLERRM;

  END pc_inclui_informativo_car;

  /* Rotina referente a inclusão de informativos Modo Web */
  PROCEDURE pc_inclui_informativo_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL -->Data Movimento
                                     ,pr_flgtitul IN INTEGER              -->Possui Titular
                                     ,pr_flgobrig IN INTEGER              -->Obrigatório     
                                     ,pr_cdrelato IN INTEGER  DEFAULT NULL --Cod.do informativo
                                     ,pr_cdprogra IN INTEGER  DEFAULT NULL --Cod.do programa
                                     ,pr_cddfrenv IN INTEGER  DEFAULT NULL --Cod.forma de envio
                                     ,pr_cdperiod IN INTEGER  DEFAULT NULL --Cod.periodicidade                                
                                     ,pr_xmllog   IN VARCHAR2 DEFAULT NULL -->XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          -->Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             -->Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    -->Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             -->Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS         -->Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_inclui_informativo_web      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 11/08/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a inclusão de Informativos modo Web

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3) := NULL; 
    
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

      --Incluir Informativo      
      IINF0001.pc_inclui_informativo(pr_cdcooper => vr_cdcooper  --Codigo Cooperativa
                                    ,pr_cdagenci => vr_cdagenci  --Codigo Agencia
                                    ,pr_nrdcaixa => vr_nrdcaixa  --Numero Caixa
                                    ,pr_idorigem => vr_idorigem  --Origem Processamento
                                    ,pr_cdoperad => vr_cdoperad  --Operador
                                    ,pr_nmdatela => vr_nmdatela  --Nome da tela                                
                                    ,pr_dtmvtolt => vr_dtmvtolt  --Data Movimento 
                                    ,pr_cdrelato => pr_cdrelato  --Codigo do relatorio
                                    ,pr_cdprogra => pr_cdprogra  --Codigo do Programa
                                    ,pr_cddfrenv => pr_cddfrenv  --Codigo do envio
                                    ,pr_cdperiod => pr_cdperiod  --Codigo do período
                                    ,pr_flgobrig => pr_flgobrig  --Obrigatório
                                    ,pr_flgtitul => pr_flgtitul  --Possui Titular                                                                       
                                    ,pr_cdcritic => pr_cdcritic  --Codigo Erro
                                    ,pr_dscritic => pr_dscritic  --Descrição do Erro
                                    ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                    ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                    ,pr_des_erro => vr_des_reto); --Saida OK/NOK 
                             
      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na iinf0001.pc_inclui_informativo.';
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
        pr_dscritic:= 'Erro na iinf0001.pc_inclui_informativo_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_inclui_informativo_web;
  
  /* Rotina referente a alteração cadastral dos informativos */
  PROCEDURE pc_altera_informativo(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                 ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                 ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                 ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                                 ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela
                                 ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador                                 
                                 ,pr_flgtitul IN INTEGER           -->Possui Titular
                                 ,pr_flgobrig IN INTEGER           -->Obrigatório                                
                                 ,pr_nrdrowid IN  ROWID                 -->Número do Rowid
                                 ,pr_cdrelato IN INTEGER  DEFAULT NULL  -->Cod.do informativo
                                 ,pr_cdprogra IN INTEGER  DEFAULT NULL  -->Cod.do programa
                                 ,pr_cddfrenv IN INTEGER  DEFAULT NULL  -->Cod.forma de envio
                                 ,pr_cdperiod IN INTEGER  DEFAULT NULL  -->Cod.periodicidade                                     
                                 ,pr_nmdcampo OUT VARCHAR2              -->Nome do campo com erro
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                                 ,pr_des_erro OUT VARCHAR2) IS          -->Erros do processo
     /*---------------------------------------------------------------------------------------------------------------
     Programa: pc_altera_informativo       Antiga: 
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 11/08/2015                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Processar a rotina de alteração da tela CADINF.

     Alteracoes: 11/08/2015 - Conversao Progress >> Oracle (PLSQL) - Jéssica (DB1)
    ---------------------------------------------------------------------------------------------------------------*/

-------------------Cursores-------------------------------------
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

    -- Busca dos dados dos informativos
    CURSOR cr_crapifc (pr_nrdrowid IN ROWID) IS
    SELECT crapifc.cdprogra
          ,crapifc.cdrelato
          ,crapifc.cddfrenv
          ,crapifc.cdperiod
          ,crapifc.envcpttl
          ,crapifc.envcobrg
          ,ROWID
      FROM crapifc
     WHERE crapifc.cdcooper = pr_cdcooper
       AND crapifc.rowid = pr_nrdrowid; 
    rw_crapifc cr_crapifc%ROWTYPE;

    CURSOR cr_gnfepri(pr_cdrelato IN crapifc.cdrelato%TYPE
                     ,pr_cdprogra IN crapifc.cdprogra%TYPE
                     ,pr_cddfrenv IN crapifc.cddfrenv%TYPE
                     ,pr_cdperiod IN crapifc.cdperiod%TYPE)IS
    SELECT gnfepri.cdrelato
          ,gnfepri.cdprogra
          ,gnfepri.cddfrenv
          ,gnfepri.cdperiod
          ,gnfepri.envcpttl
      FROM gnfepri
     WHERE gnfepri.cdrelato = pr_cdrelato
       AND gnfepri.cdprogra = pr_cdprogra
       AND gnfepri.cddfrenv = pr_cddfrenv
       AND gnfepri.cdperiod = pr_cdperiod;
    rw_gnfepri cr_gnfepri%ROWTYPE;
      
    -- Busca o rowid do informativo para alteracao
    CURSOR cr_crapifc_aux (pr_cdcooper IN crapifc.cdcooper%TYPE
                          ,pr_cdrelato IN crapifc.cdrelato%TYPE
                          ,pr_cdprogra IN crapifc.cdprogra%TYPE
                          ,pr_cddfrenv IN crapifc.cddfrenv%TYPE
                          ,pr_cdperiod IN crapifc.cdperiod%TYPE)IS
    SELECT ifc.rowid
      FROM crapifc ifc
     WHERE ifc.cdcooper = pr_cdcooper
       AND ifc.cdrelato = pr_cdrelato 
       AND ifc.cdprogra = pr_cdprogra 
       AND ifc.cddfrenv = pr_cddfrenv 
       AND ifc.cdperiod = pr_cdperiod;
    rw_crapifc_aux cr_crapifc_aux%ROWTYPE;
------------------------Variaveis-------------------------------

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
 
    vr_retornvl  VARCHAR2(3);

    vr_auxrowid ROWID;
    
    vr_flgtitul VARCHAR2(5);
    vr_flgobrig VARCHAR2(5);   
    vr_cdrelato INTEGER;
    vr_cdprogra INTEGER;
    vr_cddfrenv INTEGER;
    vr_cdperiod INTEGER;    

    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;
    vr_exc_saida EXCEPTION;
    
    BEGIN

      --Inicializar Variaveis
      vr_cdcritic := 0;
      vr_dscritic := NULL;

      -- Usar a PK da tabela caso o rowid nao seja informado      
      IF pr_nrdrowid IS NULL THEN
        vr_cdrelato := pr_cdrelato;
        vr_cdprogra := pr_cdprogra;
        vr_cddfrenv := pr_cddfrenv;
        vr_cdperiod := pr_cdperiod;
      END IF;
      
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

      -- Buscar o informativo a ser alterado
      OPEN cr_crapifc(pr_nrdrowid => pr_nrdrowid);
      
      FETCH cr_crapifc INTO rw_crapifc;

      -- Se encontrar
      IF cr_crapifc%FOUND THEN
        -- PK da tabela
        IF pr_nrdrowid IS NOT NULL THEN 
          vr_cdrelato := rw_crapifc.cdrelato;
          vr_cdprogra := rw_crapifc.cdprogra; 
          vr_cddfrenv := rw_crapifc.cddfrenv; 
          vr_cdperiod := rw_crapifc.cdperiod;         
        END IF;
                
        CLOSE cr_crapifc;  
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapifc;
      END IF;

     -- Rowid e campos que serao atualizados
      vr_auxrowid := pr_nrdrowid;
      vr_flgtitul := pr_flgtitul;
      vr_flgobrig := pr_flgobrig;
      
      -- Se o rowid for nulo, buscar atraves da PK
      IF vr_auxrowid IS NULL THEN        
        -- Buscar o rowid do registro a ser excluido
        OPEN cr_crapifc_aux (pr_cdcooper => pr_cdcooper
                            ,pr_cdrelato => vr_cdrelato
                            ,pr_cdprogra => vr_cdprogra
                            ,pr_cddfrenv => vr_cddfrenv
                            ,pr_cdperiod => vr_cdperiod);

        FETCH cr_crapifc_aux INTO rw_crapifc_aux;

        -- Se não encontrar
        IF cr_crapifc_aux%NOTFOUND THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic:= 'Registro para alteracao nao foi encontrado.';

          -- Apenas fechar o cursor
          CLOSE cr_crapifc_aux;

          RAISE vr_exc_erro;
        ELSE 
          -- Atribuir o rowid para alteracao
          vr_auxrowid := rw_crapifc_aux.rowid;    

          -- Apenas fechar o cursor
          CLOSE cr_crapifc_aux;        
        END IF;        
                
      END IF;
                    
      OPEN cr_gnfepri(pr_cdrelato => vr_cdrelato
                     ,pr_cdprogra => vr_cdprogra
                     ,pr_cddfrenv => vr_cddfrenv
                     ,pr_cdperiod => vr_cdperiod);

      FETCH cr_gnfepri INTO rw_gnfepri;
      
      -- Se encontrar
      IF cr_gnfepri%FOUND THEN  

        CLOSE cr_gnfepri;
      
        IF rw_gnfepri.envcpttl <> 0 THEN
          
          BEGIN
            UPDATE crapifc 
               SET crapifc.envcobrg = vr_flgobrig                  
             WHERE crapifc.rowid = vr_auxrowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar Informativo: '||SQLERRM;
              RAISE vr_exc_erro;
          END;                       
        ELSE                  

          BEGIN
            UPDATE crapifc 
               SET crapifc.envcpttl = vr_flgtitul
                  ,crapifc.envcobrg = vr_flgobrig                   
             WHERE crapifc.rowid = vr_auxrowid;
             
             -- Apagar informativos atribuidos aos 2 titulares
             DELETE crapcra
              WHERE cdcooper = pr_cdcooper
                AND idseqttl <> 1
                AND cdrelato = rw_crapifc.cdrelato
                AND cdprogra = rw_crapifc.cdprogra
                AND cddfrenv = rw_crapifc.cddfrenv                                               
                AND cdperiod = rw_crapifc.cdperiod;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar Informativo: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
          
        END IF;         
        
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_gnfepri;
      END IF;            
        
      --Retorno
      pr_des_erro:= 'OK';
      COMMIT;
                     
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
        vr_dscritic := 'Erro na IINF0001.pc_altera_informativo --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        ROLLBACK;


  END pc_altera_informativo;

  /* Rotina referente a inclusao de informativos Modo Caracter */
  PROCEDURE pc_altera_informativo_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                     ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                     ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                     ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                     ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                                     ,pr_cdrelato IN INTEGER  DEFAULT NULL --Cod.do informativo
                                     ,pr_cdprogra IN INTEGER  DEFAULT NULL --Cod.do programa
                                     ,pr_cddfrenv IN INTEGER  DEFAULT NULL --Cod.forma de envio
                                     ,pr_cdperiod IN INTEGER  DEFAULT NULL --Cod.periodicidade
                                     ,pr_flgtitul IN INTEGER          --Possui Titular
                                     ,pr_flgobrig IN INTEGER          --Obrigatório                                     
                                     ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                                     ,pr_clob_ret OUT CLOB                 --Tabela XML                                 
                                     ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                                     ,pr_dscritic OUT VARCHAR2) IS         --Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_altera_informativo_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 10/08/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a alteração de informativos modo Caracter

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*/
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3) := NULL; 

    --Tabelas de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    vr_tab_cadinf IINF0001.typ_tab_cadinf;    

    vr_auxrowid ROWID;
        
    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;                                       
        
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;

      --Limpar tabela dados
      vr_tab_cadinf.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;

      --Alterar Informativos Cadastrados
      IINF0001.pc_altera_informativo(pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                    ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                    ,pr_nrdcaixa => pr_nrdcaixa  --Numero Caixa
                                    ,pr_idorigem => pr_idorigem  --Origem Processamento                                                                
                                    ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento                                
                                    ,pr_nmdatela => pr_nmdatela  --Nome da tela
                                    ,pr_cdoperad => pr_cdoperad  --Operador
                                    ,pr_flgtitul => pr_flgtitul  --Possui Titular
                                    ,pr_flgobrig => pr_flgobrig  --Obrigatório  
                                    ,pr_nrdrowid => vr_auxrowid  --número do rowid 
                                    ,pr_cdrelato => pr_cdrelato  --Cod.do informativo
                                    ,pr_cdprogra => pr_cdprogra  --Cod.do programa
                                    ,pr_cddfrenv => pr_cddfrenv  --Cod.forma de envio
                                    ,pr_cdperiod => pr_cdperiod  --Cod.periodicidade                                                                                                                                                                                                                                                                                                                               
                                    ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                    ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                    ,pr_des_erro => vr_des_reto); --Saida OK/NOK                                                            

      
      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
          
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a IINF0001.pc_altera_informativo.';
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
        pr_dscritic:= 'Erro na IINF0001.pc_altera_informativo_car --> '|| SQLERRM;

  END pc_altera_informativo_car;

  /* Rotina referente a alteração de informativos Modo Web */
  PROCEDURE pc_altera_informativo_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL -->Data Movimento
                                     ,pr_flgtitul IN INTEGER              -->Possui Titular
                                     ,pr_flgobrig IN INTEGER              -->Obrigatório
                                     ,pr_nrdrowid IN  ROWID                -->Rowid do registro
                                     ,pr_xmllog   IN VARCHAR2 DEFAULT NULL -->XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          -->Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             -->Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    -->Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             -->Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS         -->Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_altera_informativo_web      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 11/08/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a alteração de informativos modo Web

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3) := NULL; 
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    vr_tab_cadinf IINF0001.typ_tab_cadinf;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_cdrelato INTEGER:=NULL;
    vr_cdprogra INTEGER:=NULL;
    vr_cddfrenv INTEGER:=NULL;
    vr_cdperiod INTEGER:=NULL;    
    
    --Variaveis Arquivo Dados
    vr_dtmvtolt DATE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;                                       
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;

      --Limpar tabela dados
      vr_tab_cadinf.DELETE;
                  
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

      --Alterar Informativos Cadastrados
      IINF0001.pc_altera_informativo(pr_cdcooper => vr_cdcooper  --Codigo Cooperativa
                                    ,pr_cdagenci => vr_cdagenci  --Codigo Agencia
                                    ,pr_nrdcaixa => vr_nrdcaixa  --Numero Caixa
                                    ,pr_idorigem => vr_idorigem  --Origem Processamento                                                                
                                    ,pr_dtmvtolt => vr_dtmvtolt  --Data Movimento                                
                                    ,pr_nmdatela => vr_nmdatela  --Nome da tela
                                    ,pr_cdoperad => vr_cdoperad  --Operador
                                    ,pr_flgtitul => pr_flgtitul  --Possui Titular
                                    ,pr_flgobrig => pr_flgobrig  --Obrigatório   
                                    ,pr_nrdrowid => pr_nrdrowid  --Número do Rowid 
                                    ,pr_cdrelato => vr_cdrelato  --Cod.do informativo
                                    ,pr_cdprogra => vr_cdprogra  --Cod.do programa
                                    ,pr_cddfrenv => vr_cddfrenv  --Cod.forma de envio
                                    ,pr_cdperiod => vr_cdperiod  --Cod.periodicidade                                                                                                                                                                                                                                     
                                    ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                    ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                    ,pr_des_erro => vr_des_reto); --Saida OK/NOK

      
      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
          
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a IINF0001.pc_altera_informativo.';
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
        pr_dscritic:= 'Erro na iinf0001.pc_altera_informativo_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_altera_informativo_web;

  -- Rotina geral para excluir informativos
  PROCEDURE pc_exclui_informativo(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                 ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                 ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                 ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                                 ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                 ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento                                   
                                 ,pr_rowid    IN ROWID         -->Número do Rowid
                                 ,pr_cdrelato IN INTEGER  DEFAULT NULL -->Cod.do informativo
                                 ,pr_cdprogra IN INTEGER  DEFAULT NULL -->Cod.do programa
                                 ,pr_cddfrenv IN INTEGER  DEFAULT NULL -->Cod.forma de envio
                                 ,pr_cdperiod IN INTEGER  DEFAULT NULL -->Cod.periodicidade
                                 ,pr_fldelcra IN INTEGER  DEFAULT NULL --> Deletar crapcra                                                                  
                                 ,pr_nmdcampo OUT VARCHAR2    -->Nome do campo com erro
                                 ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                                 ,pr_des_erro OUT VARCHAR2) IS -->Erros do processo
    /* .............................................................................

     Programa: pc_exclui_informativo
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 11/08/2015                        Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Rotina referente a exclusão de informativos

     Alteracoes:
    ..............................................................................*/

    -------------------Cursores-------------------------------------
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

    -- Busca dos dados dos informativos
    CURSOR cr_crapifc (pr_nrdrowid IN ROWID) IS
    SELECT crapifc.cdprogra
          ,crapifc.cdrelato
          ,crapifc.cddfrenv
          ,crapifc.cdperiod
          ,crapifc.envcpttl
          ,crapifc.envcobrg
          ,ROWID
      FROM crapifc
     WHERE crapifc.cdcooper = pr_cdcooper
       AND crapifc.rowid = pr_nrdrowid;
    rw_crapifc cr_crapifc%ROWTYPE;

    -- Busca o rowid do informativo para alteracao
    CURSOR cr_crapifc_aux (pr_cdcooper IN crapifc.cdcooper%TYPE
                          ,pr_cdrelato IN crapifc.cdrelato%TYPE
                          ,pr_cdprogra IN crapifc.cdprogra%TYPE
                          ,pr_cddfrenv IN crapifc.cddfrenv%TYPE
                          ,pr_cdperiod IN crapifc.cdperiod%TYPE)IS
    SELECT ROWID
      FROM crapifc
     WHERE crapifc.cdcooper = pr_cdcooper
       AND crapifc.cdrelato = pr_cdrelato 
       AND crapifc.cdprogra = pr_cdprogra 
       AND crapifc.cddfrenv = pr_cddfrenv 
       AND crapifc.cdperiod = pr_cdperiod;
    rw_crapifc_aux cr_crapifc_aux%ROWTYPE;
------------------------Variaveis-------------------------------

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_auxrowid ROWID;
    vr_retornvl  VARCHAR2(3);
        
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

      -- Verifica se a cooperativa esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
            
      -- Atribuir o rowid que veio por parametor
      vr_auxrowid := pr_rowid;

      -- Se o rowid for nulo, buscar atraves da PK
      IF vr_auxrowid IS NULL THEN
        -- Buscar o rowid do registro a ser excluido
        OPEN cr_crapifc_aux (pr_cdcooper => pr_cdcooper
                            ,pr_cdrelato => pr_cdrelato
                            ,pr_cdprogra => pr_cdprogra
                            ,pr_cddfrenv => pr_cddfrenv
                            ,pr_cdperiod => pr_cdperiod);

        FETCH cr_crapifc_aux INTO rw_crapifc_aux;

        -- Se não encontrar
        IF cr_crapifc_aux%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapifc_aux;

          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic:= 'Registro para exclusao nao foi encontrado';

          RAISE vr_exc_erro;
        ELSE 
          vr_auxrowid := rw_crapifc_aux.rowid;
          
          -- Apenas fechar o cursor
          CLOSE cr_crapifc_aux;
        END IF;        
      END IF;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapifc(pr_nrdrowid => vr_auxrowid);
      
      FETCH cr_crapifc INTO rw_crapifc;

      -- Se encontrar
      IF cr_crapifc%FOUND THEN        

        CLOSE cr_crapifc;
        
        -- Apagar os informativos utilizados pelo cooperado
        IF pr_fldelcra = '1' THEN
          BEGIN          
            DELETE crapcra
             WHERE cdcooper = pr_cdcooper
               AND cdrelato = rw_crapifc.cdrelato
               AND cdprogra = rw_crapifc.cdprogra
               AND cddfrenv = rw_crapifc.cddfrenv
               AND cdperiod = rw_crapifc.cdperiod;
             
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao excluir registro crapcra. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END; 
        END IF;
        
        BEGIN          
          -- Apagar o registro de informativo
          DELETE crapifc
           WHERE crapifc.rowid = vr_auxrowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao excluir registro crapifc. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END; 

      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapifc;
      END IF;
              
      --Gera log      
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'cadinf.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                    ' --> Operador: ' || pr_cdoperad || 
                                                    ' --> Inclusao do informativo - ' ||
                                                    'Programa: '|| rw_crapifc.cdprogra || ', Codigo do relatorio: ' || rw_crapifc.cdrelato || ', Forma de envio: ' ||
                                                    rw_crapifc.cddfrenv || ', Periodicidade: ' || rw_crapifc.cdperiod || ', Obrigatoriedade: ' || 
                                                    rw_crapifc.envcobrg || ', Quem recebe:' || rw_crapifc.envcpttl);    
      --Retorno
      pr_des_erro:= 'OK';  

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
        vr_dscritic := 'Erro na IINF0001.pc_exclui_informativo --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        ROLLBACK;

  END pc_exclui_informativo;

  /* Rotina referente a exclusão de informativos Modo Caracter */
  PROCEDURE pc_exclui_informativo_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                     ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                     ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                                     ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                     ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                                     ,pr_cdrelato IN INTEGER  DEFAULT NULL -->Cod.do informativo
                                     ,pr_cdprogra IN INTEGER  DEFAULT NULL -->Cod.do programa
                                     ,pr_cddfrenv IN INTEGER  DEFAULT NULL -->Cod.forma de envio
                                     ,pr_cdperiod IN INTEGER  DEFAULT NULL -->Cod.periodicidade
                                     ,pr_fldelcra IN INTEGER DEFAULT NULL -->Deletar crapcra
                                     ,pr_nmdcampo OUT VARCHAR2             -->Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2             -->Saida OK/NOK
                                     ,pr_clob_ret OUT CLOB                 -->Tabela clob
                                     ,pr_cdcritic OUT PLS_INTEGER          -->Codigo Erro
                                     ,pr_dscritic OUT VARCHAR2) IS         -->Descricao Erro


   /* .............................................................................

     Programa: pc_exclui_informativo_car
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 10/08/2015                        Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Rotina referente a exclusão de informativos modo Caracter

     Alteracoes:
    ..............................................................................*/

      
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3) := NULL;

    --Tabelas de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    vr_tab_cadinf IINF0001.typ_tab_cadinf;

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    --Variaveis de Excecoes    
    vr_exc_erro  EXCEPTION;

    vr_auxrowid ROWID;

    BEGIN

      --limpar tabela erros
      vr_tab_erro.DELETE;

      --Limpar tabela dados
      vr_tab_cadinf.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;

      --Excluir Informativos Cadastrados
      IINF0001.pc_exclui_informativo(pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                    ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                    ,pr_nrdcaixa => pr_nrdcaixa  --Numero Caixa
                                    ,pr_idorigem => pr_idorigem  --Origem Processamento
                                    ,pr_cdoperad => pr_cdoperad  --Operador
                                    ,pr_nmdatela => pr_nmdatela  --Nome da tela                                
                                    ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                    ,pr_rowid    => vr_auxrowid  --Número do rowid  
                                    ,pr_cdrelato => pr_cdrelato  --Codigo do Relatorio
                                    ,pr_cdprogra => pr_cdprogra  --Codigo do programa
                                    ,pr_cddfrenv => pr_cddfrenv  --Codigo da forma de envio
                                    ,pr_cdperiod => pr_cdperiod  --codigo do periodo                                  
                                    ,pr_fldelcra => pr_fldelcra  --flag para excluir a tabela                                  
                                    ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo                                   
                                    ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                    ,pr_des_erro => vr_des_reto); --Saida OK/NOK

      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a IINF0001.pc_exclui_informativo.';
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
        pr_dscritic:= 'Erro na IINF0001.pc_exclui_informativo_car --> '|| SQLERRM;

  END pc_exclui_informativo_car;

  -- Rotina de exclusao de informativos Modo WEB
  PROCEDURE pc_exclui_informativo_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL -->Data Movimento 
                                     ,pr_rowid    IN ROWID                 -->Rowid do registro
                                     ,pr_fldelcra IN INTEGER DEFAULT NULL -->Deletar crapcra
                                     ,pr_xmllog   IN VARCHAR2 DEFAULT NULL -->XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          -->Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             -->Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    -->Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             -->Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS         -->Saida OK/NOK

    /* .............................................................................

     Programa: pc_exclui_informativo_web
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 10/08/2015                        Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Rotina referente a exclusão de informativos modo WEB

     Alteracoes:
    ..............................................................................*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3) := NULL; 
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_cdrelato INTEGER:=NULL;
    vr_cdprogra INTEGER:=NULL;
    vr_cddfrenv INTEGER:=NULL;
    vr_cdperiod INTEGER:=NULL;    
   
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

      --Excluir Informativos
      IINF0001.pc_exclui_informativo(pr_cdcooper => vr_cdcooper  --Codigo Cooperativa
                                    ,pr_cdagenci => vr_cdagenci  --Codigo Agencia
                                    ,pr_nrdcaixa => vr_nrdcaixa  --Numero Caixa
                                    ,pr_idorigem => vr_idorigem  --Origem Processamento
                                    ,pr_cdoperad => vr_cdoperad  --Operador
                                    ,pr_nmdatela => vr_nmdatela  --Nome da tela                                
                                    ,pr_dtmvtolt => vr_dtmvtolt  --Data Movimento  
                                    ,pr_rowid    => pr_rowid     --Número do rowid
                                    ,pr_cdrelato => vr_cdrelato  --Codigo do Relatorio
                                    ,pr_cdprogra => vr_cdprogra  --Codigo do programa
                                    ,pr_cddfrenv => vr_cddfrenv  --Codigo da forma de envio
                                    ,pr_cdperiod => vr_cdperiod  --codigo do periodo                                           
                                    ,pr_fldelcra => pr_fldelcra  --flag para excluir a tabela                                  
                                    ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo                                    
                                    ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                    ,pr_des_erro => vr_des_reto); --Saida OK/NOK                                      

     
      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na IINF0001.pc_exclui_informativo.';
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
        pr_dscritic:= 'Erro na IINF0001.pc_exclui_informativo_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>'); 

  END pc_exclui_informativo_web;
                                        
END IINF0001;
/
