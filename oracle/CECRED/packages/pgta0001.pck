CREATE OR REPLACE PACKAGE CECRED.PGTA0001 IS

---------------------------------------------------------------------------------------------------------------
--
--  Programa : PGTA0001
--  Sistema  : Rotinas genericas focando nas funcionalidades de Pagamento de Titulos Lote
--  Sigla    : PGTA
--  Autor    : Daniel Zimmermann
--  Data     : Abril/2014.                   Ultima atualizacao:  20/06/2016
--
-- Dados referentes ao programa:
--
-- Frequencia: -----
-- Objetivo  : Agrupar rotinas gen�ricas dos sistemas Oracle

-- Alteracoes:
--              25/08/2014 - Continuacao do Projeto Upload, novas procedures e ajustes nas atuais
--                          (Guilherme/SUPERO)

--             19/01/2016 - Adicionado ao arquivo de retorno nova linha incluindo informa��es como,
--                         autentica��o, documento, data, hora e protocolo (Kelvin).
--
--             20/06/2016 - Correcao para o uso da function fn_busca_dstextab da TABE0001 em 
--                          varias procedures desta package.(Carlos Rafael Tanholi). 
---------------------------------------------------------------------------------------------------------------

    -- Tabela de memoria que ira conter os titulos que foram marcados como retorno
    TYPE typ_rec_titulos IS
        RECORD(dtmvtolt DATE
              ,nmarquiv craphpt.nmarquiv%TYPE
              ,nrremret craphpt.nrremret%TYPE
              ,idarquiv ROWID);

    TYPE typ_tab_titulos IS
        TABLE OF typ_rec_titulos
        INDEX BY BINARY_INTEGER;

    -- Procedure para Verificar o Aceite do Cooperado ao Convenio
    PROCEDURE pc_verif_aceite_conven(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                    ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                    ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                    ,pr_tab_cpt      OUT CLOB                   -- Retorna Tabela CRACPT
                                    ,pr_vretorno     OUT VARCHAR2    --> Retorna OK/NOK
                                    ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                    ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro

   -- Procedure para retornar o termo de Aceite ou de Cancelamento do Servico
   PROCEDURE pc_busca_termo_servico(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                   ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                   ,pr_tpdtermo      IN INTEGER                -- Tipo do Termo
                                   ,pr_idorigem      IN PLS_INTEGER            -- ID Origem
                                   ,pr_dsdtermo     OUT CLOB                   -- Conteudo do Termo
                                   ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                   ,pr_dscritic     OUT VARCHAR2);


    -- Procedure para Efetuar/Cancelar o aceite do associado no Convenio
    PROCEDURE pc_efetua_aceite_cancel(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                     ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                     ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                     ,pr_tpdtermo      IN INTEGER                -- Tipo do Termo
                                     ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                     ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                     ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                     ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro


  -- Procedure para validar arquivo de remessa
  PROCEDURE pc_validar_arq_pgto  (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                 ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                 ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                 ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                 ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                 ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                 ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                 ,pr_nrremess     OUT craphpt.nrremret%TYPE
                                 ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                 ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro

  -- Procedure para processar os registos na wt_crapdcc
  PROCEDURE pc_processar_arq_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                  ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                  ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                  ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                  ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                  ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                  ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Operador
                                  ,pr_nrremess      IN craphpt.nrremret%TYPE  -- Numero da Remessa do Cooperado
                                  ,pr_nrremret     OUT craphpt.nrremret%TYPE  -- Numero Remessa/Retorno
                                  ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                  ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro

   PROCEDURE pc_cadastrar_agend_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                    ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                    ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                    ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                    ,pr_cdagenci      IN crapage.cdagenci%TYPE
                                    ,pr_nrdcaixa      IN craplot.nrdcaixa%TYPE
                                    ,pr_idseqttl      IN crapttl.idseqttl%TYPE
                                    ,pr_dsorigem      IN craplau.dsorigem%TYPE
                                    ,pr_cdtiptra      IN craplau.cdtiptra%TYPE
                                    ,pr_idtpdpag      IN INTEGER
                                    ,pr_dscedent      IN craplau.dscedent%TYPE
                                    ,pr_dscodbar      IN craplau.dscodbar%TYPE
                                    ,pr_lindigi1      IN INTEGER
                                    ,pr_lindigi2      IN INTEGER
                                    ,pr_lindigi3      IN INTEGER
                                    ,pr_lindigi4      IN INTEGER
                                    ,pr_lindigi5      IN INTEGER
                                    ,pr_cdhistor      IN craplau.cdhistor%TYPE
                                    ,pr_dtmvtopg      IN craplau.dtmvtopg%TYPE
                                    ,pr_vllanaut      IN craplau.vllanaut%TYPE
                                    ,pr_dtvencto      IN craplau.dtvencto%TYPE
                                    ,pr_cddbanco      IN craplau.cddbanco%TYPE
                                    ,pr_cdageban      IN craplau.cdageban%TYPE
                                    ,pr_nrctadst      IN craplau.nrctadst%TYPE
                                    ,pr_cdcoptfn      IN craplau.cdcoptfn%TYPE
                                    ,pr_cdagetfn      IN craplau.cdagetfn%TYPE
                                    ,pr_nrterfin      IN craplau.nrterfin%TYPE
                                    ,pr_nrcpfope      IN craplau.nrcpfope%TYPE
                                    ,pr_idtitdda      IN craplau.idtitdda%TYPE
                                    ,pr_dstransa      OUT VARCHAR2
                                    ,pr_cdcritic      OUT INTEGER                -- C�digo do erro
                                    ,pr_dscritic      OUT VARCHAR2);

  PROCEDURE pc_cancelar_agend_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                   ,pr_cdagenci      IN crapage.cdagenci%TYPE
                                   ,pr_nrdolote      IN craplot.nrdolote%TYPE
                                   ,pr_cdbccxlt      IN craplot.cdbccxlt%TYPE
                                   ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                   ,pr_cdtiptra      IN craplau.cdtiptra%TYPE
                                   ,pr_dscodbar      IN craplau.dscodbar%TYPE
                                   ,pr_dtvencto      IN craplau.dtvencto%TYPE
                                   ,pr_dtmvtopg      IN craplau.dtmvtopg%TYPE
                                   ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                   ,pr_cdcritic      OUT INTEGER                -- C�digo do erro
                                   ,pr_dscritic      OUT VARCHAR2);

  -- Procedure para rejeitar arquivo de remessa que tenha critica
  PROCEDURE pc_rejeitar_arq_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                 ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                 ,pr_nrconven      IN craphpt.nrconven%TYPE  -- Numero do Convenio
                                 ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                 ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                 ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                 ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                 ,pr_dsmsgrej      IN VARCHAR2               -- Motivo da Rejei��o
                                 ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                 ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro

  PROCEDURE pc_gera_retorno_tit_pago (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                     ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                     ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                     ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Operador
                                     ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                     ,pr_dscritic     OUT VARCHAR2);

  PROCEDURE pc_gerar_arq_log_pgto(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                 ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                 ,pr_descerro      IN VARCHAR2               -- Descri��o do Erro
                                 ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                 ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro




   -- Procedure para gerar arquivo de retorno
   PROCEDURE pc_gerar_arq_ret_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                   ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                   ,pr_nrremret      IN craphpt.nrremret%TYPE  -- Numero Remessa/Retorno
                                   ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                   ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                   ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                   ,pr_nmarquiv     OUT VARCHAR2               -- Nome do Arquivo
                                   ,pr_dsarquiv     OUT CLOB                   -- Conteudo do Arquivo -> Apenas quando origem Internet Banking
                                   ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                   ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro


    -- Procedure para logar no arquivo cst_arquivo.log
    PROCEDURE pc_logar_cst_arq_pgto(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                   ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                   ,pr_textolog      IN VARCHAR2               -- Texto a ser Incluso Log
                                   ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                   ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro

    -- Procedure de retorno de titulos agendados
    PROCEDURE pc_retorna_titulo_agendado(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                        ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                        ,pr_nrconven      IN craphpt.nrconven%TYPE  -- Numero do Convenio
                                        ,pr_dtinicon      IN DATE                   -- Data Inicial
                                        ,pr_dtfincon      IN DATE                   -- Data Final
                                        ,pr_tab_titulo   OUT CLOB                   -- XML da tabela de titulos
                                        ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                        ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro

END PGTA0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PGTA0001 IS

---------------------------------------------------------------------------------------------------------------
--
--  Programa : PGTA0001
--  Sistema  : Rotinas genericas focando nas funcionalidades do pagamento por arquivo
--  Sigla    : PGTA
--  Autor    : Daniel Zimmermann
--  Data     : Maio/2014.                   Ultima atualizacao: 20/06/2016
--
-- Dados referentes ao programa:
--
-- Frequencia: Sempre que Chamado
-- Objetivo  : Agrupar rotinas gen�ricas dos sistemas Oracle

-- Alteracoes: 15/07/2015 - Adicionado troca de acentuacao do nmcedent em proc. pc_validar_arq_pgto.
--                          (Jorge/Rafael) - SD 304877                          

--             19/01/2016 - Adicionado ao arquivo de retorno nova linha incluindo informa��es como,
--                         autentica��o, documento, data, hora e protocolo (Kelvin).        
--
--             20/06/2016 - Correcao para o uso da function fn_busca_dstextabem da TABE0001 em 
--                          procedures desta package.(Carlos Rafael Tanholi).                                 
---------------------------------------------------------------------------------------------------------------


  -- Descricao e codigo da critica
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  
  --Tipo de Dados para cursor data
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  
  -- Procedure para Verificar o Aceite do Cooperado ao Convenio
  PROCEDURE pc_verif_aceite_conven (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                   ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                   ,pr_tab_cpt      OUT CLOB                   -- Retorna Tabela CRACPT
                                   ,pr_vretorno     OUT VARCHAR2               --> Retorna OK/NOK
                                   ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                   ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro

  BEGIN

  DECLARE

     -- CURSORES

     -- Seleciona os dados da Cooperativa
     CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
     SELECT crapcop.nrdconta
           ,crapcop.cdagectl
       FROM crapcop crapcop
      WHERE crapcop.cdcooper = pr_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;


     --Selecionar os dados da tabela de Associados
     CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
     SELECT crapass.nrdconta
           ,crapass.cdagenci
           ,crapass.nrcpfcgc
           ,crapass.inpessoa
       FROM crapass crapass
      WHERE crapass.cdcooper = pr_cdcooper
        AND crapass.nrdconta = pr_nrdconta;
     rw_crapass cr_crapass%ROWTYPE;


     -- Verifica se convenio existe pro Associado
     CURSOR cr_crapcpt (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrconven IN crapcpt.nrconven%TYPE) IS
     SELECT crapcpt.nrconven
           ,crapcpt.dtdadesa
           ,crapcpt.cdoperad ||' - '|| crapope.nmoperad        cdoperad
           ,DECODE(crapcpt.flgativo,1,'ATIVO','INATIVO')       flgativo
           ,DECODE(crapcpt.cdoperad,'996','INTERNET','AYLLOS') dsorigem
       FROM crapcpt crapcpt
           ,crapope crapope
      WHERE crapope.cdcooper = crapcpt.cdcooper
        AND crapope.cdoperad = crapcpt.cdoperad
        AND crapcpt.cdcooper = pr_cdcooper
        AND crapcpt.nrdconta = pr_nrdconta
        AND crapcpt.nrconven = pr_nrconven;
     rw_crapcpt cr_crapcpt%ROWTYPE;


     -- Buscar o n�mero da ultima Remessa
     CURSOR cr_craphpt (pr_cdcooper IN craphpt.cdcooper%TYPE
                       ,pr_nrdconta IN craphpt.nrdconta%TYPE
                       ,pr_nrconven IN craphpt.nrconven%TYPE) IS
       SELECT nvl(max(craphpt.nrremret),0) nrremret
         FROM craphpt craphpt
        WHERE craphpt.cdcooper = pr_cdcooper
          AND craphpt.nrdconta = pr_nrdconta
          AND craphpt.nrconven = pr_nrconven
          AND craphpt.intipmvt = 1; -- Remessa
     rw_craphpt cr_craphpt%ROWTYPE;

     -- Variaveis para Tratamento erro
     vr_exc_saida    EXCEPTION;
     vr_exc_erro     EXCEPTION;
     vr_existe_aceit EXCEPTION;
     vr_des_erro     VARCHAR2(4000);
     vr_hrfimpag     VARCHAR2(50);
     vr_nrremret     craphpt.nrremret%TYPE;

     vr_xml_tab_temp VARCHAR(32767);

  BEGIN

    -- Verifica se a cooperativa esta cadastrada
     OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
     FETCH cr_crapcop
      INTO rw_crapcop;
     -- Se n�o encontrar
     IF cr_crapcop%NOTFOUND THEN
       -- Fechar o cursor pois haver� raise
       CLOSE cr_crapcop;
       vr_des_erro := 'Cooperativa nao cadastrada.';
       RAISE vr_exc_saida;
     ELSE
       -- Apenas fechar o cursor

       CLOSE cr_crapcop;
     END IF;


     -- Verifica se o cooperado esta cadastrado
     OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta);
     FETCH cr_crapass
      INTO rw_crapass;
     -- Se n�o encontrar
     IF cr_crapass%NOTFOUND THEN
       -- Fechar o cursor pois haver� raise
       CLOSE cr_crapass;
       vr_des_erro := 'Cooperado nao cadastrado.';
       RAISE vr_exc_saida;
     ELSE
       -- Apenas fechar o cursor
       CLOSE cr_crapass;
    END IF;


     -- Verifica se associado tem Aceite no Convenio
     OPEN cr_crapcpt(pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrconven => pr_nrconven);
     FETCH cr_crapcpt INTO rw_crapcpt;
     -- Se n�o encontrar
     IF cr_crapcpt%NOTFOUND THEN
       -- Fechar o cursor pois haver� raise
       CLOSE cr_crapcpt;
       vr_des_erro := 'Para utiliza��o, fa�a o aceite no Termo de utiliza��o do servi�o.';
       RAISE vr_existe_aceit;
     ELSE

       IF rw_crapcpt.flgativo <> 'ATIVO' THEN
          pr_dscritic := 'Cooperado com Conv�nio INATIVO!';
       END IF;


       -- Verifica ultima sequencia da Remessa
       OPEN cr_craphpt(pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrconven => pr_nrconven);
       FETCH cr_craphpt
        INTO rw_craphpt;
       -- Se encontrar arquivo
       IF cr_craphpt%FOUND THEN
         -- Fechar o cursor pois haver� raise
         CLOSE cr_craphpt;
         vr_nrremret := rw_craphpt.nrremret;
       ELSE
         -- Fechar o cursor
         CLOSE cr_craphpt;
         vr_nrremret := 0;
       END IF;

       -- Prepara para envio do XML
       dbms_lob.createtemporary(pr_tab_cpt, TRUE);
       dbms_lob.open(pr_tab_cpt, dbms_lob.lob_readwrite);

       -- Insere o cabe�alho do XML
       gene0002.pc_escreve_xml(pr_xml            => pr_tab_cpt
                              ,pr_texto_completo => vr_xml_tab_temp
                              ,pr_texto_novo     => '<raiz>');
       LOOP
          EXIT WHEN cr_crapcpt%NOTFOUND;
          
          
          vr_hrfimpag := to_char(
                            to_date(
                               SubStr(TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                                ,pr_nmsistem => 'CRED'
                                                                ,pr_tptabela => 'GENERI'
                                                                ,pr_cdempres => 0
                                                                ,pr_cdacesso => 'HRPGTARQ'
                                                                ,pr_tpregist => 90)
                                     ,0,5)
                               ,'sssss')
                         , 'hh24:mi:ss');


          gene0002.pc_escreve_xml(pr_xml            => pr_tab_cpt
                                 ,pr_texto_completo => vr_xml_tab_temp
                                 ,pr_texto_novo     => '<arquivo>'
                                                    || '<nrconven>'||rw_crapcpt.nrconven||'</nrconven>'
                                                    || '<dtdadesa>'||TO_CHAR(rw_crapcpt.dtdadesa,'DD/MM/YYYY')||'</dtdadesa>'
                                                    || '<cdoperad>'||rw_crapcpt.cdoperad||'</cdoperad>'
                                                    || '<flgativo>'||rw_crapcpt.flgativo||'</flgativo>'
                                                    || '<dsorigem>'||rw_crapcpt.dsorigem||'</dsorigem>'
                                                    || '<hrfimpag>'||vr_hrfimpag        ||'</hrfimpag>'
                                                    || '<nrremret>'||vr_nrremret        ||'</nrremret>'
                                                    || '</arquivo>');
          FETCH cr_crapcpt INTO rw_crapcpt;
       END LOOP;

       -- Encerrar a tag raiz
       gene0002.pc_escreve_xml(pr_xml            => pr_tab_cpt
                              ,pr_texto_completo => vr_xml_tab_temp
                              ,pr_texto_novo     => '</raiz>'
                              ,pr_fecha_xml      => TRUE);

       -- Apenas fechar o cursor
       pr_vretorno := 'OK';
       CLOSE cr_crapcpt;
     END IF;

  EXCEPTION
    WHEN vr_existe_aceit THEN
      -- Efetuar retorno do erro
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_des_erro;
      pr_vretorno := 'OK';

    WHEN vr_exc_saida THEN
      -- Efetuar retorno do erro
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_des_erro;
      pr_vretorno := 'NOK';

    WHEN OTHERS THEN
      -- Apenas retornar a vari�vel de saida
      pr_cdcritic := 0;
      pr_dscritic := 'Erro PGTA0001.pc_verif_aceite_conven: ' || SQLERRM;
      pr_vretorno := 'NOK';

  END;

  END pc_verif_aceite_conven;


  -- Procedure para retornar o termo de Aceite ou de Cancelamento do Servico
  PROCEDURE pc_busca_termo_servico (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                   ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                   ,pr_tpdtermo      IN INTEGER                -- Tipo do Termo
                                   ,pr_idorigem      IN PLS_INTEGER            -- ID Origem
                                   ,pr_dsdtermo     OUT CLOB                   -- Conteudo do Termo
                                   ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                   ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro

  BEGIN

  DECLARE
     vr_cdacesso    craptab.cdacesso%TYPE;
     vr_arq_tmp     VARCHAR2(32767);
     vr_dtdehoje    VARCHAR2(100);
     vr_dsendere    VARCHAR2(100);

  /** Campos do Termo - Tabelionato, Data, nr Registro, Nr Livro e Nr Folha - Variaveis por cooperativa **/
     vr_dsregis     VARCHAR2(100);
     vr_dtregis	    VARCHAR2(10);
     vr_nrregis	    VARCHAR2(10);
     vr_nrlivro	    VARCHAR2(5);
     vr_nrfolha 	  VARCHAR2(5);
     vr_dstermo     VARCHAR(9000);

     -- CURSORES

     -- Seleciona os dados da Cooperativa
     CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
     SELECT crapcop.nrdconta
           ,gene0002.fn_mask(crapcop.cdagectl,'9999') cdagectl
           ,gene0002.fn_mask(crapcop.cdbcoctl,'9999') cdbcoctl
           ,gene0002.fn_mask_cpf_cnpj(crapcop.nrdocnpj,2) nrdocnpj
           ,UPPER(crapcop.nmrescop)     nmrescop
           ,INITCAP(crapcop.nmextcop)   nmextcop
           ,UPPER(crapcop.nmcidade)     nmcidade
           ,UPPER(crapcop.cdufdcop)     cdufdcop
           ,INITCAP(crapcop.dsendcop)||', '||crapcop.nrendcop||DECODE(crapcop.nrcxapst,0,'',', Cx Postal: '||crapcop.nrcxapst) dsendcop
           ,INITCAP(crapcop.nmbairro)||', '||INITCAP(crapcop.nmcidade)||'/'||crapcop.cdufdcop||' - CEP '||gene0002.fn_mask(crapcop.nrcepend,'99999-999') dscompl
     FROM crapcop crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;


     --Selecionar os dados da tabela de Associados
     CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
       SELECT crapass.cdcooper
             ,TRIM(gene0002.fn_mask(crapass.nrdconta,'Z.ZZZ.ZZ9-9')) nrdconta
             ,crapass.cdagenci
             ,gene0002.fn_mask_cpf_cnpj(crapass.nrcpfcgc,crapass.inpessoa) nrcpfcgc
             ,crapass.nmprimtl
             ,crapass.inpessoa
             ,craptip.dstipcta
             ,INITCAP(crapenc.dsendere)||', '||crapenc.nrendere||DECODE(crapenc.complend,' ','',', '||crapenc.complend) dsendere
             ,crapenc.nmcidade
             ,crapenc.cdufende
             ,gene0002.fn_mask(crapenc.nrcepend,'99999-999') nrcepend
             ,gene0002.fn_mask(crapass.cdbcochq,'9999') cdbcoctl
             ,gene0002.fn_mask(crapass.cdagenci,'9999') cdagectl
         FROM crapass crapass
             ,craptip craptip
             ,crapenc crapenc
        WHERE crapass.cdcooper = craptip.cdcooper
          AND crapass.cdtipcta = craptip.cdtipcta
          AND crapass.cdcooper = crapenc.cdcooper
          AND crapass.nrdconta = crapenc.nrdconta
          AND crapass.cdcooper = pr_cdcooper
          AND crapass.nrdconta = pr_nrdconta
          AND crapenc.cdseqinc = 1
          AND crapenc.idseqttl = 1;
     rw_crapass cr_crapass%ROWTYPE;

     -- Verifica se convenio existe pro Associado
     CURSOR cr_crapcpt (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrconven IN crapcpt.nrconven%TYPE) IS
     SELECT crapcpt.nrconven
       FROM crapcpt crapcpt
      WHERE crapcpt.cdcooper = pr_cdcooper
        AND crapcpt.nrdconta = pr_nrdconta
        AND crapcpt.nrconven = pr_nrconven
        AND crapcpt.flgativo = 1; --ATIVO
     rw_crapcpt cr_crapcpt%ROWTYPE;


     -- Busca Endereco do Associado
     CURSOR cr_crapenc (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapenc.nrdconta%TYPE
                       ,pr_tpendass IN crapenc.tpendass%TYPE) IS
     SELECT  crapenc.tpendass
            ,crapenc.dsendere
            ,crapenc.nrendere
            ,crapenc.complend
            ,crapenc.nmbairro
            ,crapenc.nmcidade
            ,crapenc.nrcepend
            ,crapenc.cdufende
       FROM crapenc crapenc
      WHERE crapenc.cdcooper = pr_cdcooper
        AND crapenc.nrdconta = pr_nrdconta
        AND crapenc.idseqttl = 1
        AND crapenc.tpendass = pr_tpendass;
     rw_crapenc cr_crapenc%ROWTYPE;

     -- VARIAVEL AUX
     vr_dstextab VARCHAR2(32767);
     vr_trmcompl VARCHAR2(300);     -- Complemento do termo -> Deixar em branco quando termo nao estiver registrado

     -- Variaveis para Tratamento erro
     vr_exc_saida EXCEPTION;
     vr_exc_erro  EXCEPTION;
     vr_existe_aceite EXCEPTION;
     vr_des_erro VARCHAR2(4000);

  BEGIN
    
     vr_trmcompl := '';

     -- Verifica se a cooperativa esta cadastrada
     OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
     FETCH cr_crapcop
      INTO rw_crapcop;
     -- Se n�o encontrar
     IF cr_crapcop%NOTFOUND THEN
       -- Fechar o cursor pois haver� raise
       CLOSE cr_crapcop;
       vr_des_erro := 'Cooperativa nao cadastrada.';
       RAISE vr_exc_saida;
     ELSE
       -- Apenas fechar o cursor

       CLOSE cr_crapcop;
     END IF;


     -- Verifica se o cooperado esta cadastrado
     OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta);
     FETCH cr_crapass
      INTO rw_crapass;
     -- Se n�o encontrar
     IF cr_crapass%NOTFOUND THEN
       -- Fechar o cursor pois haver� raise
       CLOSE cr_crapass;
       vr_des_erro := 'Cooperado nao cadastrado.';
       RAISE vr_exc_saida;
     ELSE
       -- Apenas fechar o cursor
       CLOSE cr_crapass;
    END IF;


    IF  pr_tpdtermo = 0
    AND pr_idorigem = 3 THEN -- Se for Cancelamento e InternetBank, verifica se tem Aceite
       -- Verifica se associado tem Aceite no Convenio
       OPEN cr_crapcpt(pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrconven => pr_nrconven);
       FETCH cr_crapcpt
       INTO rw_crapcpt;
       -- Se n�o encontrar
       IF cr_crapcpt%NOTFOUND THEN
          -- Fechar o cursor pois haver� raise
          CLOSE cr_crapcpt;
          vr_des_erro := 'Cooperado sem Aceite ou Inativo no Pagamento por Arquivo.';
          RAISE vr_existe_aceite;
       ELSE
          -- Apenas fechar o cursor
          CLOSE cr_crapcpt;
       END IF;
    END IF;



    -- Busca enderecos do Associado - Tipo 12
    OPEN cr_crapenc(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_tpendass => 12);
    FETCH cr_crapenc
     INTO rw_crapenc;
    -- Se n�o encontrar
    IF cr_crapenc%NOTFOUND THEN
       -- Fechar o cursor pois pesquisar� com outro tipo
       CLOSE cr_crapenc;

       -- Busca enderecos do Associado - Tipo 10
       OPEN cr_crapenc(pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_tpendass => 10);
       FETCH cr_crapenc
        INTO rw_crapenc;
       -- Se n�o encontrar
       IF cr_crapenc%NOTFOUND THEN
         -- Fechar o cursor pois pesquisar� com outro tipo
         CLOSE cr_crapenc;

         -- Busca enderecos do Associado - Tipo 9
         OPEN cr_crapenc(pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_tpendass => 9);
         FETCH cr_crapenc
          INTO rw_crapenc;
         -- Se n�o encontrar
         IF cr_crapenc%NOTFOUND THEN
           -- Fechar o cursor pois haver� raise
           CLOSE cr_crapenc;
           vr_des_erro := 'Cooperado sem endere�o cadastrado!';
           RAISE vr_exc_saida;
         ELSE -- Encontrou tipo 9
           CLOSE cr_crapenc;
           vr_dsendere := TRIM(rw_crapenc.dsendere) || ' Nr.: ' || to_char(rw_crapenc.nrendere) || ' - ' || TRIM(rw_crapenc.complend);
         END IF;
       ELSE --Encontrou tipo 10
         CLOSE cr_crapenc;
         vr_dsendere := TRIM(rw_crapenc.dsendere) || ' Nr.: ' || to_char(rw_crapenc.nrendere) || ' - ' || TRIM(rw_crapenc.complend);
       END IF;
     ELSE  -- Encontrou tipo 12
       CLOSE cr_crapenc;
       vr_dsendere := TRIM(rw_crapenc.dsendere) || ' Nr.: ' || to_char(rw_crapenc.nrendere) || ' - ' || TRIM(rw_crapenc.complend);
     END IF;


     vr_dtdehoje := rw_crapcop.nmcidade || '/'  ||
                    rw_crapcop.cdufdcop || ', ' ||  TO_CHAR(sysdate, 'DD "de" fmMonth "de" YYYY','nls_date_language=portuguese') ||'.';


     IF pr_idorigem = 3 THEN -- InternetBank

        -- BUSCA TAB COM CONTEUDO DO TERMO
        IF pr_tpdtermo = 1 THEN -- ADESAO
           vr_cdacesso := 'TAPGTFPA';
        ELSE
           vr_cdacesso := 'TCPGTFPA';
        END IF;

        -- Buscar configura��o na tabela
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => vr_cdacesso
                                                 ,pr_tpregist => 90);           
        
        
        -- Se n�o encontrar
        IF TRIM(vr_dstextab) IS NULL THEN 
          vr_des_erro := 'Termo do Servi�o n�o encontrado![' || vr_cdacesso || ']';
          RAISE vr_exc_saida;
        ELSE


          -- OBS.: Situa��o tempor�ria pois cart�rios de Blumenau n�o est�o registrando Contratos/Termos temporariamente
          IF pr_cdcooper = 1 THEN
             vr_trmcompl := '';
          ELSE
             vr_trmcompl := ', registrado no  #DSREGIS#, em #DTREGIS#, sob o n#ordm#; #NRREGIS#, livro #NRLIVRO#, folha #NRFOLHA#';
          END IF;

          -- TROCA CARACTERES CURINGA POR DADOS DO ASSOCIADO
          vr_dstextab := REPLACE(vr_dstextab,'#NMPRIMTL#',rw_crapass.nmprimtl );
          vr_dstextab := REPLACE(vr_dstextab,'#NRCPFCGC#',rw_crapass.nrcpfcgc );
          vr_dstextab := REPLACE(vr_dstextab,'#CDAGENCI#',rw_crapass.cdagenci );
          vr_dstextab := REPLACE(vr_dstextab,'#NRDCONTA#',TO_CHAR(rw_crapass.nrdconta) );
          vr_dstextab := REPLACE(vr_dstextab,'#DSENDERE#',vr_dsendere );
          vr_dstextab := REPLACE(vr_dstextab,'#NMRESCOP#',rw_crapcop.nmrescop );
          vr_dstextab := REPLACE(vr_dstextab,'#NMEXTCOP#',rw_crapcop.nmextcop );
          vr_dstextab := REPLACE(vr_dstextab,'#DATA#'    ,vr_dtdehoje );


          -- Inicializar o CLOB
          dbms_lob.createTemporary(pr_dsdtermo, true);
          dbms_lob.open(pr_dsdtermo, dbms_lob.lob_readwrite);

          gene0002.pc_escreve_xml(pr_xml            => pr_dsdtermo
                                 ,pr_texto_completo => vr_arq_tmp
                                 ,pr_texto_novo     => '<termo>' || vr_dstextab);

          gene0002.pc_escreve_xml(pr_xml            => pr_dsdtermo
                                 ,pr_texto_completo => vr_arq_tmp
                                 ,pr_texto_novo     => '</termo>'
                                 ,pr_fecha_xml      => TRUE);

        END IF;

     ELSE -- Ayllos WEB

        -- BUSCA TAB COM VARIAVEIS DO TERMO  (#DSREGIS# #DTREGIS# #NRREGIS# #NRLIVRO# #NRFOLHA#)
        IF pr_tpdtermo = 1 THEN -- ADESAO
           vr_cdacesso := 'TAPGTFPA2';

           -- OBS.: Situa��o tempor�ria pois cart�rios de Blumenau n�o est�o registrando Contratos/Termos temporariamente
           IF pr_cdcooper = 1 THEN
              vr_trmcompl := '';
           ELSE
              vr_trmcompl := 'registrado no #DSREGIS#, em #DTREGIS#, sob o n#ordm#; #NRREGIS#, livro #NRLIVRO#, folha #NRFOLHA#, ';
           END IF;
           
           vr_dstermo  := '';
           vr_dstermo  := '#center##B#TERMO DE ADES&Atilde;O A PRESTA&Ccedil;&Atilde;O DE SERVI&Ccedil;O PARA#/BR#' ||
                          'PAGAMENTO ATRAV&Eacute;S DE TROCA ELETR&Ocirc;NICA DE ARQUIVOS#/B##/CENTER#' ||
                          '#/BR##/BR##B#COOPERATIVA#/B#' ||
                          '#table# border=1 cellspacing=0 cellpadding=0 width=100#PERCENT#>' ||
                          ' #TR#' ||
                          '  #TD|# width=100#PERCENT# class=tbord>' ||
                          '  #P##NMEXTCOP# - #NMRESCOP##/P#' ||
                          '  #/TD#' ||
                          ' #/TR#' ||
                          ' #TR#' ||
                          '  #TD|# width=100#PERCENT class=tbord>' ||
                          '  #P#CNPJ:#/BR#' ||
                          '  #NRDOCNPJ# #/P#' ||
                          '  #/TD#' ||
                          ' #/TR#' ||
                          ' #TR#' ||
                          '  #TD|# width=100#PERCENT# class=tbord>' ||
                          '  #P#Endere&ccedil;o: #/BR#' ||
                          '  #DSENDCOP# #/BR#' ||
                          '  Bairro: #DSCOMPL# #/P#' ||
                          '  #/TD#' ||
                          ' #/TR#' ||
                          '#/TABLE##/BR#' ||
                          '#B#COOPERADO#/B#' ||
                          '#table# border=1 cellspacing=0 cellpadding=0 width=100#PERCENT#>' ||
                          ' #TR#' ||
                          '  #TD|# width=50#PERCENT# class=tbord>' ||
                          '  #P#Nome/Raz&atilde;o  Social:#/BR#  #NMPRIMTL##/P#' ||
                          '  #/TD#' ||
                          '  #TD|# width=50#PERCENT# colspan=2 class=tbord>' ||
                          '  #P#CPF/CNPJ:#/BR#  #NRCPFCGC##P#' ||
                          '  #/TD#' ||
                          ' #/TR#' ||
                          ' #TR#' ||
                          '  #TD|# width=50#PERCENT# colspan=3 class=tbord>' ||
                          '  #P#Endere&ccedil;o:#/BR#  #DSENDERE##/P#' ||
                          ' #/TD#' ||
                          ' #/TR#' ||
                          ' #TR#' ||
                          '  #TD|# width=50#PERCENT# class=tbord>' ||
                          '  #P#Cidade:#/BR#  #NMCID##/P#' ||
                          '  #/TD#' ||
                          '  #TD|# width=10#PERCENT# class=tbord>' ||
                          '  #P#UF:#/BR#  #CDUF##/P#' ||
                          '  #/TD#' ||
                          '  #TD|# width=40#PERCENT# class=tbord>' ||
                          '  #P#CEP:#/BR#  #NRCEP##/P#' ||
                          '  #/TD#' ||
                          ' #/TR#' ||
                          ' #TR#' ||
                          '  #TD|# colspan=3 width=50#PERCENT# class=tbord>' ||
                          '  #P#Conta eleg&iacute;vel:#/BR#  Banco: #CDBCOCTL# | Ag./Coop.: #CDAGECTL# | Conta: #NRDCONTA##/P#' ||
                          '  #/TD#' ||
                          ' #/TR#' ||
                          '#/TABLE##/BR##/BR#' ||
                          'Pelo presente instrumento, o #B#COOPERADO#/B# acima identificado e qualificado, adere ao servi&ccedil;o ' ||
                          'de pagamento atrav&eacute;s de troca eletr&ocirc;nica de arquivos e declara, em car&aacute;ter ' ||
                          'irrevog&aacute;vel e irretrat&aacute;vel, para todos os efeitos legais, o seguinte:#/BR##/BR#' ||
                          '1 - Est&atilde;o cientes e de pleno acordo com as disposi&ccedil;&otilde;es contidas nas Cl&aacute;usulas' ||
                          ' e Condi&ccedil;&otilde;es Gerais Aplic&aacute;veis ao Contrato de Presta&ccedil;&atilde;o de Servi&ccedil;o' ||
                          ' para Pagamento atrav&eacute;s de Troca Eletr&ocirc;nica de Arquivos, #TRMCOMPL#' ||
                          'as quais integram este Contrato/Termo de Ades&atilde;o, para os devidos fins, formando ' ||
                          'um documento &uacute;nico e indivis&iacute;vel, cujo teor declara conhecer e entender e com o qual concordam, ' ||
                          'passando a assumir todas as prerrogativas e obriga&ccedil;&otilde;es que lhes s&atilde;o atribu&iacute;das, ' ||
                          'na condi&ccedil;&atilde;o de #B#COOPERADO#/B#.#/BR##/BR#' ||
                          '2 - A presta&ccedil;&atilde;o regular deste servi&ccedil;o est&aacute; condicionada a remessa pelo COOPERADO de ' ||
                          'apenas t&iacute;tulos n&atilde;o vencidos. Havendo envio de boletos vencidos de outras institui&ccedil;&otilde;es ' ||
                          'financeiras, o pagamento ser&aacute; rejeitado e encaminhado atrav&eacute;s do arquivo de retorno.' ||
                          '#/BR##/BR#' ||
                          '3 - O COOPERADO compromete-se a manter recursos dispon&iacute;veis para a efetiva&ccedil;&atilde;o de todos os ' ||
                          'pagamentos enviados atrav&eacute;s de arquivo, bem como remete-los &agrave; COOPERATIVA com, no m&iacute;nimo, ' ||
                          '01 (um) dia antes da data do vencimento dos boletos.  #/BR##/BR#' ||
                          '4 - Para efetiva&ccedil;&atilde;o dos pagamentos, os arquivos dever&atilde;o ser enviados pelo COOPERADO at&eacute; ' ||
                          'o hor&aacute;rio limite estabelecido pela COOPERATIVA. Os arquivos enviados ap&oacute;s aquele hor&aacute;rio ' ||
                          'ser&atilde;o rejeitados.#/BR##/BR#' ||
                          'E, por estarem assim justas e contratadas, firmam o presente Contrato/Termo de Ades&atilde;o em tantas vias quantas ' ||
                          'forem necess&aacute;rias para a entrega de uma via para cada parte, na presen&ccedil;a das duas testemunhas abaixo ' ||
                          'identificadas, que, estando cientes, tamb&eacute;m assinam, para que produza os devidos e legais efeitos.#/BR##/BR#' ||
                          '#/BR##/BR##/BR#' ||
                          '#center##DATA##/CENTER#' ||
                          '#/BR##/BR##/BR##/BR##/BR##P#__________________________________________#/BR#' ||
                          'Cooperado#/BR##NMPRIMTL##/P#' ||
                          '#/BR##P#__________________________________________#/BR#' ||
                          '  #NMEXTCOP# - #NMRESCOP##/P##/BR##/BR#' ||
                          '#P##B#TESTEMUNHAS#/B##/P#' ||
                          '#/BR##table#  border=0 width=100#PERCENT#>' ||
                          ' #TR#' ||
                          '  #TD|# width=50#PERCENT#>' ||
                          '  #P|# align=center style="text-align:left">______________________________________#/BR#' ||
                          '  Nome:#/BR#CPF:#/P##/TD#' ||
                          '  #TD|# width=50#PERCENT#>' ||
                          '  #P|# align=center style="text-align:left">______________________________________#/BR#' ||
                          '  Nome:#/BR#' ||
                          '  CPF:#/P#' ||
                          '  #/TD#' ||
                          ' #/TR#' ||
                          '#/TABLE#';
        ELSE
           vr_cdacesso := 'TCPGTFPA2';

           -- OBS.: Situa��o tempor�ria pois cart�rios de Blumenau n�o est�o registrando Contratos/Termos temporariamente
           IF pr_cdcooper = 1 THEN
              vr_trmcompl := '';
           ELSE
              vr_trmcompl := ', registrado no  #DSREGIS#, em #DTREGIS#, sob o n#ordm#; #NRREGIS#, livro #NRLIVRO#, folha #NRFOLHA#';
           END IF;

           vr_dstermo  := '';
           vr_dstermo  := '#center##B#TERMO DE EXCLUS&Atilde;O A PRESTA&Ccedil;&Atilde;O DE SERVI&Ccedil;O PARA#/BR#' ||
                          'PAGAMENTO ATRAV&Eacute;S DE TROCA ELETR&Ocirc;NICA DE ARQUIVOS#/B##/CENTER#' ||
                          '#/BR##/BR##B#COOPERATIVA#/B#' ||
                          '#table# border=1 cellspacing=0 cellpadding=0 width=100#PERCENT#>' ||
                          '  #TR#' ||
                          '    #TD|# width=100#PERCENT# class=tbord>' ||
                          '     #P##NMEXTCOP# - #NMRESCOP##/P#' ||
                          '    #/TD#' ||
                          '  #/TR#' ||
                          '  #TR#' ||
                          '    #TD|# width=100#PERCENT# class=tbord>' ||
                          '      #P#CNPJ:#/BR#' ||
                          '      #NRDOCNPJ##/P#' ||
                          '    #/TD#' ||
                          '  #/TR#' ||
                          '  #TR#' ||
                          '    #TD|# width=100#PERCENT# class=tbord>' ||
                          '      #P#Endere&ccedil;o:#/BR#' ||
                          '      #DSENDCOP##/BR#' ||
                          '      Bairro: #DSCOMPL##/P#' ||
                          '    #/TD#' ||
                          '  #/TR#' ||
                          '#/TABLE#' ||
                          '#/BR#' ||
                          '#B#COOPERADO#/B#' ||
                          '#table# border=1 cellspacing=0 cellpadding=0 width=100#PERCENT#>' ||
                          ' #TR#' ||
                          '  #TD|# width=50#PERCENT# class=tbord>' ||
                          '  #P#Nome/Raz&atilde;o  Social:#/BR#' ||
                          '  #NMPRIMTL##/P#' ||
                          '  #/TD#' ||
                          '  #TD|# width=50#PERCENT# colspan=2 class=tbord>' ||
                          '  #P#CPF/CNPJ:#/BR#' ||
                          '  #NRCPFCGC##P#' ||
                          '  #/TD#' ||
                          ' #/TR#' ||
                          ' #TR#' ||
                          '  #TD|# width=50#PERCENT# colspan=3 class=tbord>' ||
                          '  #P#Endere&ccedil;o:#/BR#' ||
                          '  #DSENDERE##/P#' ||
                          '  #/TD#' ||
                          ' #/TR#' ||
                          ' #TR#' ||
                          '  #TD|# width=50#PERCENT# class=tbord>' ||
                          '  #P#Cidade:#/BR#' ||
                          '  #NMCID##/P#' ||
                          '  #/TD#' ||
                          '  #TD|# width=10#PERCENT# class=tbord>' ||
                          '  #P#UF:#/BR#' ||
                          '  #CDUF##/P#' ||
                          '  #/TD#' ||
                          '  #TD|# width=40#PERCENT# class=tbord>' ||
                          '  #P#CEP:#/BR#' ||
                          '  #NRCEP##/P#' ||
                          '  #/TD#' ||
                          ' #/TR#' ||
                          ' #TR#' ||
                          '  #TD|# colspan=3 width=50#PERCENT# class=tbord>' ||
                          '  #P#Conta eleg&iacute;vel:#/BR#' ||
                          '  Banco: #CDBCOCTL# | Ag./Coop: #CDAGECTL# | Conta: #NRDCONTA##/P#' ||
                          '  #/TD#' ||
                          ' #/TR#' ||
                          '#/TABLE##/BR##/BR#' ||
                          'Pelo presente instrumento, o #B#COOPERADO#/B# requer a exclus&atilde;o ao Servi&ccedil;o ' ||
                          'de pagamento atrav&eacute;s de troca eletr&ocirc;nica de arquivos.#/BR#' ||
                          '#/BR#' ||
                          '1 - O #B#COOPERADO#/B# declara estar ciente das consequ&ecirc;ncias decorrentes da ' ||
                          'exclus&atilde;o solicitada, estabelecidas na Cl&aacute;usula e Condi&ccedil;&otilde;es ' ||
                          'Gerais Aplic&aacute;veis ao Contrato para Presta&ccedil;&atilde;o de Servi&ccedil;o De ' ||
                          'Pagamento atrav&eacute;s de Troca Eletr&ocirc;nica de Arquivos' ||
                          '#TRMCOMPL#.#/BR#' ||
                          '#/BR#' ||
                          '2 - Declara estar ciente ainda que, a sua exclus&atilde;o do #B#SERVI&Ccedil;O#/B#, ' ||
                          'importar&aacute; na exclus&atilde;o autom&aacute;tica e imediata de seus #B#OPERADORES#/B#, ' ||
                          'aos quais se obriga a informar sobre a presente solicita&ccedil;&atilde;o.#/BR#' ||
                          '#/BR#' ||
                          '3 - O #B#COOPERADO#/B# isenta a #B#COOPERATIVA#/B# de qualquer preju&iacute;zo ou responsabilidade, ' ||
                          'nos termos contratuais, decorrentes da presente solicita&ccedil;&atilde;o.#/BR#' ||
                          '#/BR#' ||
                          'E, por estarem assim justas e contratadas, firmam o presente Contrato/Termo de Exlcus&atilde;o em tantas ' ||
                          'vias quantas forem necess&aacute;rias para a entrega de uma via para cada parte, na presen&ccedil;a das ' ||
                          'duas testemunhas abaixo identificadas, que, estando cientes, tamb&eacute;m assinam, para que produza os ' ||
                          'devidos e legais efeitos.#/BR##/BR#' ||
                          '#/BR##/BR##/BR#' ||
                          '#center##DATA##/CENTER#' ||
                          '#/BR##/BR##/BR##/BR##/BR##P#__________________________________________#/BR#' ||
                          'Cooperado#/BR##NMPRIMTL##/P#' ||
                          '#/BR##P#__________________________________________#/BR#' ||
                          '  #NMEXTCOP# - #NMRESCOP##/P##/BR##/BR#' ||
                          '#P##B#TESTEMUNHAS#/B##/P#' ||
                          '#/BR##table#  border=0 width=100#PERCENT#>' ||
                          ' #TR#' ||
                          '  #TD|# width=50#PERCENT#>' ||
                          '  #P|# align=center style="text-align:left">______________________________________#/BR#' ||
                          '  Nome:#/BR#CPF:#/P##/TD#' ||
                          '  #TD|# width=50#PERCENT#>' ||
                          '  #P|# align=center style="text-align:left">______________________________________#/BR#' ||
                          '  Nome:#/BR#' ||
                          '  CPF:#/P#' ||
                          '  #/TD#' ||
                          ' #/TR#' ||
                          '#/TABLE#';
        END IF;

        -- Buscar configura��o na tabela
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => vr_cdacesso
                                                 ,pr_tpregist => 90);
        
       -- Se n�o encontrar
       IF TRIM(vr_dstextab) IS NULL THEN 
          vr_des_erro := 'Termo do Servi�o n�o encontrado![' || vr_cdacesso || ']';
          RAISE vr_exc_saida;
       ELSE

          -- Busca as variaveis gravadas na TAB - Apenas para Ayllos WEB
          vr_dsregis := gene0002.fn_busca_entrada(pr_postext => 1
                                                 ,pr_dstext      => vr_dstextab
                                                 ,pr_delimitador => '|');
          vr_dtregis := gene0002.fn_busca_entrada(pr_postext => 2
                                                 ,pr_dstext      => vr_dstextab
                                                 ,pr_delimitador => '|');
          vr_nrregis := gene0002.fn_busca_entrada(pr_postext => 3
                                                 ,pr_dstext      => vr_dstextab
                                                 ,pr_delimitador => '|');
          vr_nrlivro := gene0002.fn_busca_entrada(pr_postext => 4
                                                 ,pr_dstext      => vr_dstextab
                                                 ,pr_delimitador => '|');
          vr_nrfolha := gene0002.fn_busca_entrada(pr_postext => 5
                                                 ,pr_dstext      => vr_dstextab
                                                 ,pr_delimitador => '|');
              
          vr_dstextab := '';
          vr_dstextab := vr_dstermo;

          --TROCA CARACTERES CURINGA POR DADOS DO ASSOCIADO
          -- Informacoes do Documento
          vr_dstextab := REPLACE(vr_dstextab,'#DSENDCOP#',rw_crapcop.dsendcop);
          vr_dstextab := REPLACE(vr_dstextab,'#DSCOMPL#' ,rw_crapcop.dscompl);
          vr_dstextab := REPLACE(vr_dstextab,'#NMRESCOP#',rw_crapcop.nmrescop);
          vr_dstextab := REPLACE(vr_dstextab,'#NMEXTCOP#',rw_crapcop.nmextcop);
          vr_dstextab := REPLACE(vr_dstextab,'#NRDOCNPJ#',rw_crapcop.nrdocnpj);

          vr_dstextab := REPLACE(vr_dstextab,'#NMPRIMTL#',rw_crapass.nmprimtl);
          vr_dstextab := REPLACE(vr_dstextab,'#NRCPFCGC#',rw_crapass.nrcpfcgc);
          vr_dstextab := REPLACE(vr_dstextab,'#NRDCONTA#',rw_crapass.nrdconta);
          vr_dstextab := REPLACE(vr_dstextab,'#DSENDERE#',rw_crapass.dsendere);
          vr_dstextab := REPLACE(vr_dstextab,'#NMCID#',rw_crapass.nmcidade);
          vr_dstextab := REPLACE(vr_dstextab,'#CDUF#',rw_crapass.cdufende);
          vr_dstextab := REPLACE(vr_dstextab,'#NRCEP#',rw_crapass.nrcepend);
          vr_dstextab := REPLACE(vr_dstextab,'#CDBCOCTL#',rw_crapcop.cdbcoctl);
          vr_dstextab := REPLACE(vr_dstextab,'#CDAGECTL#',rw_crapcop.cdagectl);
          vr_dstextab := REPLACE(vr_dstextab,'#DSTIPCTA#',rw_crapass.dstipcta);

          -- Variaveis do Termo - Detalhes do Registro do Termo
          vr_dsregis  := REPLACE(vr_dsregis,'#ordm#','&ordm');
          vr_dsregis  := REPLACE(vr_dsregis,'#iacute#','&iacute');
              
          vr_trmcompl := REPLACE(vr_trmcompl,'#DSREGIS#',vr_dsregis);
          vr_trmcompl := REPLACE(vr_trmcompl,'#ordm#','&ordm');
          vr_trmcompl := REPLACE(vr_trmcompl,'#DTREGIS#',vr_dtregis);
          vr_trmcompl := REPLACE(vr_trmcompl,'#NRREGIS#',vr_nrregis);
          vr_trmcompl := REPLACE(vr_trmcompl,'#NRLIVRO#',vr_nrlivro);
          vr_trmcompl := REPLACE(vr_trmcompl,'#NRFOLHA#',vr_nrfolha);

          vr_dstextab := REPLACE(vr_dstextab,'#TRMCOMPL#',vr_trmcompl);

          vr_dstextab := REPLACE(vr_dstextab,'#DATA#'    ,vr_dtdehoje );

          -- Inicializar o CLOB
          dbms_lob.createTemporary(pr_dsdtermo, true);
          dbms_lob.open(pr_dsdtermo, dbms_lob.lob_readwrite);

          gene0002.pc_escreve_xml(pr_xml            => pr_dsdtermo
                                 ,pr_texto_completo => vr_arq_tmp
                                 ,pr_texto_novo     => '<termo>' || vr_dstextab);

          gene0002.pc_escreve_xml(pr_xml            => pr_dsdtermo
                                 ,pr_texto_completo => vr_arq_tmp
                                 ,pr_texto_novo     => '</termo>'
                                 ,pr_fecha_xml      => TRUE);
       END IF;

     END IF;


  EXCEPTION
    WHEN vr_existe_aceite THEN
      -- Efetuar retorno do erro
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_des_erro;

    WHEN vr_exc_saida THEN
      -- Efetuar retorno do erro
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_des_erro;

    WHEN OTHERS THEN
      -- Apenas retornar a vari�vel de saida
      pr_cdcritic := 0;
      pr_dscritic := 'Erro PGTA0001.pc_busca_termo_servico: ' || SQLERRM;

   END;

  END pc_busca_termo_servico;


  -- Procedure para Efetuar o aceite do associado no Convenio
  PROCEDURE pc_efetua_aceite_cancel (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                    ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                    ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                    ,pr_tpdtermo      IN INTEGER                -- Tipo do Termo
                                    ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                    ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                    ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                    ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro
  BEGIN

  DECLARE

     -- CURSORES

     -- Seleciona os dados da Cooperativa
     CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
     SELECT crapcop.nrdconta
           ,crapcop.cdagectl
       FROM crapcop crapcop
      WHERE crapcop.cdcooper = pr_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;


     --Selecionar os dados da tabela de Associados
     CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
     SELECT crapass.nrdconta
           ,crapass.cdagenci
           ,crapass.nrcpfcgc
           ,crapass.inpessoa
       FROM crapass crapass
      WHERE crapass.cdcooper = pr_cdcooper
        AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;


     -- Verifica se convenio existe pro Associado
     CURSOR cr_crapcpt (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrconven IN crapcpt.nrconven%TYPE) IS
     SELECT crapcpt.nrconven,
            crapcpt.flgativo
       FROM crapcpt crapcpt
      WHERE crapcpt.cdcooper = pr_cdcooper
        AND crapcpt.nrdconta = pr_nrdconta
        AND crapcpt.nrconven = pr_nrconven;
     rw_crapcpt cr_crapcpt%ROWTYPE;

     -- Variaveis para Tratamento erro
     vr_exc_saida     EXCEPTION;
     vr_exc_erro      EXCEPTION;
     vr_finaliza_proc EXCEPTION;
     vr_erro_update   EXCEPTION;
     vr_des_erro VARCHAR2(4000);

  BEGIN

    -- Verifica se a cooperativa esta cadastrada
     OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
     FETCH cr_crapcop
      INTO rw_crapcop;
     -- Se n�o encontrar
     IF cr_crapcop%NOTFOUND THEN
       -- Fechar o cursor pois haver� raise
       CLOSE cr_crapcop;
       vr_des_erro := 'Cooperativa nao cadastrada.';
       RAISE vr_exc_saida;
     ELSE
       -- Apenas fechar o cursor
       CLOSE cr_crapcop;
     END IF;


     -- Verifica se o cooperado esta cadastrado
     OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta);
     FETCH cr_crapass
      INTO rw_crapass;
     -- Se n�o encontrar
     IF cr_crapass%NOTFOUND THEN
       -- Fechar o cursor pois haver� raise
       CLOSE cr_crapass;
       vr_des_erro := 'Cooperado nao cadastrado.';
       RAISE vr_exc_saida;
     ELSE
       IF  rw_crapass.inpessoa <> 2 THEN
           CLOSE cr_crapass;
           vr_des_erro := 'Permitido apenas para Pessoa Jur�dica.';
           RAISE vr_exc_saida;
       END IF;
       -- Apenas fechar o cursor
       CLOSE cr_crapass;
    END IF;


    IF pr_tpdtermo = 1 THEN -- ADESAO
       -- Verifica se associado tem Aceite no Convenio
       OPEN cr_crapcpt(pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrconven => pr_nrconven);
       FETCH cr_crapcpt
        INTO rw_crapcpt;
       -- Se encontrar e estiver ativo
       IF cr_crapcpt%FOUND THEN
          -- Se Ativo, retorna Critica
          CLOSE cr_crapcpt;
          IF rw_crapcpt.flgativo = 1 THEN
             vr_des_erro := 'Cooperado j� possui Aceite no Pagamento por Arquivo.';
             RAISE vr_exc_saida;
          -- Se estiver INATIVO, atualiza para Ativo
          ELSIF rw_crapcpt.flgativo = 0 THEN
             -- Efetua a Atualizacao do Aceite do Convenio
             BEGIN
                UPDATE crapcpt
                   SET flgativo = 1 -- Ativo
                 WHERE crapcpt.cdcooper = pr_cdcooper
                   AND crapcpt.nrdconta = pr_nrdconta
                   AND crapcpt.nrconven = pr_nrconven;

                IF SQL%ROWCOUNT = 0 THEN
                   RAISE vr_erro_update;
                END IF;

             EXCEPTION
                WHEN vr_erro_update THEN
                   -- Atualiza campo de erro
                   vr_cdcritic := 0;
                   vr_des_erro := 'Erro ao atualizar dados na CRAPCPT: ' || SQLERRM;
                   RAISE vr_exc_saida;
                WHEN OTHERS THEN
                   -- Atualiza campo de erro
                   vr_cdcritic := 0;
                   vr_des_erro := 'Erro na atualiza��o de dados na CRAPCPT: ' || SQLERRM;
                   RAISE vr_exc_saida;
             END;

          END IF;
       ELSE  -- Se NAO existir, Insere...
          CLOSE cr_crapcpt;
          BEGIN
             INSERT INTO crapcpt
               (cdcooper,
                nrdconta,
                nrconven,
                dtdadesa,
                nrctrcpt,
                idretorn,
                cdoperad,
                flgativo,
                flghomol
                )
              VALUES
               (pr_cdcooper,
                pr_nrdconta,
                1,   -- Fixo - Pagto Titulos Por Arquivo
                pr_dtmvtolt,
                1,   -- nrctrcpt
                1,   -- idretorn
                pr_cdoperad,
                1,    -- flgativo = 1 (ATIVO)
                1     -- flghomol = 1 (HOMOLOGADO)
                );
             -- Se nao inseriu registro
             IF SQL%ROWCOUNT = 0 THEN
                RAISE vr_finaliza_proc; -- Finaliza o processo e retorna NOK
             END IF;
          EXCEPTION
             WHEN vr_finaliza_proc THEN
                pr_cdcritic := 0;
                vr_des_erro := ' Nao foi possivel cadastrar o Aceite. Erro: '||SQLERRM;
                RAISE vr_exc_saida;
             WHEN OTHERS THEN
                vr_des_erro := 'Erro ao inserir crapcpt(PGTA0001.pc_efetua_aceite_cancel): '||SQLERRM;
                --Levantar Excecao
                RAISE vr_exc_saida;
          END;
       END IF;

       COMMIT;

    ELSE -- CANCELAMENTO

       -- Verifica se associado tem Aceite no Convenio
       OPEN cr_crapcpt(pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrconven => pr_nrconven);
       FETCH cr_crapcpt
        INTO rw_crapcpt;
       -- Se encontrar e estiver ativo
       IF cr_crapcpt%NOTFOUND THEN
          -- Fechar o cursor pois haver� raise
          CLOSE cr_crapcpt;
          vr_des_erro := 'Cooperado n�o possui Aceite para Cancelamento no Pagamento por Arquivo.';
          RAISE vr_exc_saida;
       ELSE
          CLOSE cr_crapcpt;
          -- Se estiver ATIVO, marca como INATIVO
          IF rw_crapcpt.flgativo = 1 THEN
             -- Efetua a Atualizacao do Aceite do Convenio
             BEGIN
                UPDATE crapcpt
                   SET flgativo = 0 -- Inativo
                 WHERE crapcpt.cdcooper = pr_cdcooper
                   AND crapcpt.nrdconta = pr_nrdconta
                   AND crapcpt.nrconven = pr_nrconven;

                IF SQL%ROWCOUNT = 0 THEN
                   RAISE vr_erro_update;
                END IF;

             EXCEPTION
                WHEN vr_erro_update THEN
                   -- Atualiza campo de erro
                   vr_cdcritic := 0;
                   vr_des_erro := 'Erro ao atualizar dados na CRAPCPT: ' || SQLERRM;
                   RAISE vr_exc_saida;
                WHEN OTHERS THEN
                   -- Atualiza campo de erro
                   vr_cdcritic := 0;
                   vr_des_erro := 'Erro na atualiza��o de dados na CRAPCPT: ' || SQLERRM;
                   RAISE vr_exc_saida;
             END;
          END IF;
       END IF;

       COMMIT;

    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Efetuar retorno do erro
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_des_erro;
      -- Efetua Rollback
      ROLLBACK;

    WHEN OTHERS THEN
      -- Apenas retornar a vari�vel de saida
      pr_cdcritic := 0;
      pr_dscritic := 'Erro PGTA0001.pc_efetua_aceite_conven: ' || SQLERRM;
      -- Efetua Rollback
      ROLLBACK;

  END;

  END pc_efetua_aceite_cancel;



  -- Procedure para validar arquivo de pagamentos
  PROCEDURE pc_validar_arq_pgto  (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                 ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                 ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                 ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                 ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                 ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                 ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                 ,pr_nrremess     OUT craphpt.nrremret%TYPE
                                 ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                 ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro

  BEGIN

  DECLARE

     -- CURSORES

     --Selecionar os dados da tabela de Associados
     CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
       SELECT crapass.nrdconta
             ,crapass.cdagenci
             ,crapass.nrcpfcgc
             ,crapass.inpessoa
        FROM crapass crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
     rw_crapass cr_crapass%ROWTYPE;

     -- Seleciona os dados da Cooperativa
     CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
       SELECT crapcop.nrdconta
             ,crapcop.cdagectl
         FROM crapcop crapcop
        WHERE crapcop.cdcooper = pr_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;

     -- Seleciona os dados do Convenio
     CURSOR cr_crapcpt (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapcop.nrdconta%TYPE
                       ,pr_nrconven IN crapcpt.nrconven%TYPE) IS
     SELECT crapcpt.flghomol
       FROM crapcpt crapcpt
      WHERE crapcpt.cdcooper = pr_cdcooper
        AND crapcpt.nrdconta = pr_nrdconta
        AND crapcpt.nrconven = pr_nrconven;
     rw_crapcpt cr_crapcpt%ROWTYPE;

     -- Selecionar os dados da Remessa
     CURSOR cr_craphpt (pr_cdcooper IN craphpt.cdcooper%TYPE
                       ,pr_nrdconta IN craphpt.nrdconta%TYPE
                       ,pr_nrconven IN craphpt.nrconven%TYPE
                       ,pr_nrremret IN craphpt.nrremret%TYPE) IS
       SELECT craphpt.nrremret
         FROM craphpt craphpt
         WHERE craphpt.cdcooper = pr_cdcooper
           AND craphpt.nrdconta = pr_nrdconta
           AND craphpt.nrconven = pr_nrconven
           AND craphpt.nrremret = pr_nrremret
           AND craphpt.intipmvt = 1; -- Remessa
     rw_craphpt cr_craphpt%ROWTYPE;

     -- Cursor para verificar C�digo de Barra em Duplicidade
     CURSOR cr_crapdpt (pr_cdcooper IN crapdpt.cdcooper%TYPE 
                       ,pr_nrdconta IN crapdpt.nrdconta%TYPE
                       ,pr_nrremret IN crapdpt.nrremret%TYPE
                       ,pr_dscodbar IN crapdpt.dscodbar%TYPE) IS
       SELECT crapdpt.dscodbar
         FROM crapdpt crapdpt
        WHERE crapdpt.cdcooper = pr_cdcooper
          AND crapdpt.nrdconta = pr_nrdconta
          AND crapdpt.nrremret = pr_nrremret
          AND crapdpt.dscodbar = pr_dscodbar          
          AND crapdpt.intipmvt = 1; -- Remessa
     rw_crapdpt cr_crapdpt%ROWTYPE;

     -- Declarando handle do Arquivo
     vr_ind_arquivo utl_file.file_type;
     vr_des_erro VARCHAR2(4000);

     -- Variaveis para Tratamento erro
     vr_erro_arq   EXCEPTION;
     vr_exc_saida  EXCEPTION;
     vr_exc_erro   EXCEPTION;

     -- Nome do Arquivo
     vr_nmarquiv  VARCHAR2(200);
     vr_nmdireto  VARCHAR2(4000);

     vr_des_linha VARCHAR2(1000);

     -- Numero Remessa/Retorno
     vr_nrremret craphpt.nrremret%TYPE;

     -- Contador Registros Detalhe
     vr_contador NUMBER;

     -- Controle se Arquivo possui Trailer Arquivo e Lote
     vr_trailer_lot BOOLEAN;
     vr_trailer_arq BOOLEAN;
     vr_header_lot  BOOLEAN;
     vr_header_arq  BOOLEAN;

     vr_cdtipmvt crapdpt.cdtipmvt%TYPE;
     vr_cdocorre crapdpt.cdocorre%TYPE;
     vr_cdinsmvt crapdpt.cdinsmvt%TYPE;

     vr_nrseqarq NUMBER;

     vr_dscodbar VARCHAR2(100);
     vr_nmcedent VARCHAR2(100);
     vr_dtvencto DATE;
     vr_vltitulo NUMBER;
     vr_vldescto NUMBER;
     vr_vlacresc NUMBER;
     vr_dtdpagto DATE;
     vr_vldpagto NUMBER;
     vr_dsusoemp VARCHAR2(20);
     vr_dsnosnum VARCHAR2(20);
     vr_dtmvtopg DATE;
     vr_dtmvtolt DATE;

  BEGIN
     vr_nmarquiv := pr_nmarquiv;

     vr_nrseqarq := 0;
     vr_contador := 0;

     vr_trailer_lot := FALSE;
     vr_trailer_arq := FALSE;
     vr_header_lot  := FALSE;
     vr_header_arq  := FALSE;
     
     OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
     FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
     -- Se n�o encontrar
     IF BTCH0001.cr_crapdat%NOTFOUND THEN
       -- Fechar o cursor pois haver� raise
       CLOSE BTCH0001.cr_crapdat;
       -- Montar mensagem de critica
       vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
       RAISE vr_exc_saida;
     ELSE
       -- Apenas fechar o cursor
       CLOSE BTCH0001.cr_crapdat;
     END IF;
     
     -- Armazenar a data de movimento do dia
     vr_dtmvtolt := rw_crapdat.dtmvtolt;

     -- Define o diret�rio do arquivo
     vr_nmdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/upload') ;

     -- Abrir Arquivo de Remessa (.REM)
     GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto            --> Diret�rio do arquivo
                             ,pr_nmarquiv => vr_nmarquiv            --> Nome do arquivo
                             ,pr_tipabert => 'R'                    --> Modo de abertura (R,W,A)
                             ,pr_utlfileh => vr_ind_arquivo         --> Handle do arquivo aberto
                             ,pr_des_erro => vr_des_erro);          --> Erro
     IF vr_des_erro IS NOT NULL THEN
       --Levantar Excecao
       RAISE vr_exc_saida;
     END IF;

     -- Se o arquivo estiver aberto
     IF  utl_file.IS_OPEN(vr_ind_arquivo) THEN

       -- Percorrer as linhas do arquivo
       BEGIN
         LOOP

           GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquivo
                                       ,pr_des_text => vr_des_linha);


           -- VALIDA��O HEADER DO ARQUIVO
           -- ERROS NO HEADER SAEM POR RAISE: SIGNIFA ERRO NO ARQUIVO, NAO CONTINUAR.

           IF SUBSTR(vr_des_linha,08,01) = '0' THEN -- HEADER DO ARQUIVO

             -- Contador Registros Processados
             vr_contador := vr_contador + 1;

             -- Verifica se o cooperado esta cadastrada
             OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta);
             FETCH cr_crapass
              INTO rw_crapass;
             -- Se n�o encontrar
             IF cr_crapass%NOTFOUND THEN
               -- Fechar o cursor pois haver� raise
               CLOSE cr_crapass;
               vr_des_erro := 'Cooperado nao cadastrado: ' || pr_nrdconta;
               RAISE vr_exc_saida;
             ELSE
               -- Apenas fechar o cursor
               CLOSE cr_crapass;
            END IF;


            -- Verifica se a cooperativa esta cadastrada
             OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
             FETCH cr_crapcop
              INTO rw_crapcop;
             -- Se n�o encontrar
             IF cr_crapcop%NOTFOUND THEN
               -- Fechar o cursor pois haver� raise
               CLOSE cr_crapcop;
               vr_des_erro := 'Cooperativa nao cadastrada: ' || pr_cdcooper;
               RAISE vr_exc_saida;
             ELSE
               -- Apenas fechar o cursor
               CLOSE cr_crapcop;
             END IF;

             -- Verifica se o convenio esta cadastrada
             OPEN cr_crapcpt(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrconven => pr_nrconven);
             FETCH cr_crapcpt
              INTO rw_crapcpt;
             -- Se n�o encontrar
             IF cr_crapcpt%NOTFOUND THEN
               -- Fechar o cursor pois haver� raise
               CLOSE cr_crapcpt;
               vr_des_erro := 'Convenio nao Cadastrado: ' || pr_nrconven;
               RAISE vr_exc_saida;
             ELSE
               -- Apenas fechar o cursor
               CLOSE cr_crapcpt;
             END IF;

             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,158,06)) = FALSE ) THEN
               vr_des_erro := 'Numero Sequencial do Arquivo Invalido: ' || SUBSTR(vr_des_linha,158,06);
               RAISE vr_exc_saida;
             ELSE
               vr_nrremret := to_number(SUBSTR(vr_des_linha,158,06));
               pr_nrremess := vr_nrremret;
             END IF;

             -- Verifica sequencial do Arquivo (NSU)
             OPEN cr_craphpt(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrconven => pr_nrconven
                            ,pr_nrremret => vr_nrremret);
             FETCH cr_craphpt
              INTO rw_craphpt;
             -- Se encontrar arquivo
             IF cr_craphpt%FOUND THEN
               -- Fechar o cursor pois haver� raise
               CLOSE cr_craphpt;
               vr_des_erro := 'Numero Sequencial do Arquivo j� Processado: ' || vr_nrremret;
               RAISE vr_exc_saida;
             ELSE
               -- Fechar o cursor
               CLOSE cr_craphpt;
             END IF;

             -- 01.0 Codigo do banco na compensacao
             IF SUBSTR(vr_des_linha,01,03) <> '085' THEN
               vr_des_erro := 'Codigo do banco na compensacao invalido: ' || SUBSTR(vr_des_linha,01,03);
               RAISE vr_exc_saida;
             END IF;

             -- 02.0 Lote de Servico
             IF SUBSTR(vr_des_linha,04,04) <> '0000' THEN
               vr_des_erro := 'Lote de Servico Invalido: '|| SUBSTR(vr_des_linha,04,04);
               RAISE vr_exc_saida;
             END IF;

             -- 03.0 Tipo de Registro
             IF SUBSTR(vr_des_linha,08,01) <> '0' THEN
               vr_des_erro := 'Tipo de Registro Invalido: ' || SUBSTR(vr_des_linha,08,01);
               RAISE vr_exc_saida;
             END IF;

             -- 05.0 Tipo de Inscricao do Cooperado
             IF --SUBSTR(vr_des_linha,18,01) <> '1' AND   -- Pessoa Fisica
                SUBSTR(vr_des_linha,18,01) <> '2' THEN  -- Pessoa Juridica
               vr_des_erro := 'Tipo de Inscricao Invalida: ' || SUBSTR(vr_des_linha,18,01);
               RAISE vr_exc_saida;
             END IF;

             -- 06.0 Numero de Inscricao do Cooperado
             IF ( GENE0002.fn_numerico(pr_vlrteste => TRIM(SUBSTR(vr_des_linha,19,14))) = FALSE ) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header Arquivo Invalido: ' || TRIM(SUBSTR(vr_des_linha,19,14));
               RAISE vr_exc_saida;
             ELSIF rw_crapass.nrcpfcgc <> to_number(SUBSTR(vr_des_linha,19,14),'99999999999999') THEN
               vr_des_erro := 'CPF/CNPJ Informado Header Arquivo Invalido: ' || TRIM(SUBSTR(vr_des_linha,19,14));
               RAISE vr_exc_saida;
             ELSIF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,18,01)) = FALSE ) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header Arquivo incompativel com Tipo Inscricao: ' || SUBSTR(vr_des_linha,18,01);
               RAISE vr_exc_saida;
             ELSIF rw_crapass.inpessoa <> to_number(SUBSTR(vr_des_linha,18,01)) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header Arquivo incompativel com Tipo Inscricao: ' || SUBSTR(vr_des_linha,18,01);
               RAISE vr_exc_saida;
             END IF;

             -- 07.0 C�digo do Conv�nio no Banco
             IF ( GENE0002.fn_numerico(pr_vlrteste => TRIM(SUBSTR(vr_des_linha,33,20))) = FALSE ) THEN
                vr_des_erro := 'Codigo do Convenio Invalido: ' || TRIM(SUBSTR(vr_des_linha,33,20));
                RAISE vr_exc_saida;
             ELSIF pr_nrconven <> to_number(SUBSTR(vr_des_linha,33,20)) THEN
                vr_des_erro := 'Codigo do Convenio Invalido: ' || TRIM(SUBSTR(vr_des_linha,33,20));
                RAISE vr_exc_saida;
             ELSIF rw_crapcpt.flghomol = 0 THEN
                vr_des_erro := 'Convenio nao Homologado.';
                RAISE vr_exc_saida;
             END IF;

             -- 08.0 a 09.0 Ag�ncia Mantenedora da Conta
             IF ( GENE0002.fn_numerico(pr_vlrteste => trim(SUBSTR(vr_des_linha,53,05))) = FALSE ) THEN
               vr_des_erro := 'Agencia Mantenedora da Conta Invalida: ' || trim(SUBSTR(vr_des_linha,53,05));
               RAISE vr_exc_saida;
             ELSIF to_number(SUBSTR(vr_des_linha,53,05)) <> rw_crapcop.cdagectl THEN
               vr_des_erro := 'Agencia Mantenedora da Conta Invalida: ' || trim(SUBSTR(vr_des_linha,53,05));
               RAISE vr_exc_saida;
             END IF;

             -- 10.0 a 11.0 Conta/DV
             IF ( GENE0002.fn_numerico(pr_vlrteste => TRIM(SUBSTR(vr_des_linha,59,13))) = FALSE ) THEN
               vr_des_erro := 'Conta/DV Header Arquivo Invalida: ' || TRIM(SUBSTR(vr_des_linha,59,13));
               RAISE vr_exc_saida;
             ELSIF to_number(SUBSTR(vr_des_linha,59,13)) <> pr_nrdconta THEN
               vr_des_erro := 'Conta/DV Header Arquivo Invalida: ' || TRIM(SUBSTR(vr_des_linha,59,13));
               RAISE vr_exc_saida;
             END IF;

             -- 16.0 Codigo Remessa/Retorno
             IF SUBSTR(vr_des_linha,143,01) <> '1' THEN -- '1' = Remessa (Cliente -> Banco)
               vr_des_erro := 'Codigo de Remessa nao encontrado no segmento header do arquivo: ' || SUBSTR(vr_des_linha,143,01);
               RAISE vr_exc_saida;
             END IF;

             -- 17.0 Data de Geracao de Arquivo
             IF ( GENE0002.fn_data(pr_vlrteste => SUBSTR(vr_des_linha,144,08)
                                  ,pr_formato  => 'DD/MM/RRRR') = FALSE ) THEN
               vr_des_erro := 'Data de geracao do arquivo fora do periodo permitido: ' || SUBSTR(vr_des_linha,144,08);
               RAISE vr_exc_saida;
             ELSE
               IF ( TO_DATE(SUBSTR(vr_des_linha,144,08), 'DD/MM/RRRR') > vr_dtmvtolt ) OR
                  ( TO_DATE(SUBSTR(vr_des_linha,144,08), 'DD/MM/RRRR') < (vr_dtmvtolt - 30)) THEN
                 vr_des_erro := 'Data de geracao do arquivo fora do periodo permitido: ' || TO_CHAR(TO_DATE(SUBSTR(vr_des_linha,144,08), 'DD/MM/RRRR'), 'DD/MM/RRRR') ;
                 RAISE vr_exc_saida;
               END IF;
             END IF;

             -- Controle se arquivo possui Header de Arquivo
             vr_header_arq := TRUE;

           END IF; -- Header do Arquivo

           -- Incluir tratamento para garantir que arquivo tenha Header de Arquivo
           IF vr_header_arq = FALSE THEN
             vr_des_erro := 'Arquivo nao possui Header de Arquivo.';
             RAISE vr_exc_saida;
           END IF;



           -- HEADER DO LOTE --
           -- ERROS NO HEADER LOTE SAEM POR RAISE: SIGNIFA ERRO NO ARQUIVO, NAO CONTINUAR.

           IF SUBSTR(vr_des_linha,08,01) = '1' THEN -- Header do Lote
             -- Inicializa Variaveis
             vr_contador := vr_contador + 1;

             -- 09.1 a 10.1  Numero de Inscricao do Cooperado
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,19,14)) = FALSE ) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header do Lote Invalido: ' || SUBSTR(vr_des_linha,19,14);
               RAISE vr_exc_saida;
             ELSIF rw_crapass.nrcpfcgc <> to_number(SUBSTR(vr_des_linha,19,14),'99999999999999') THEN
               vr_des_erro := 'CPF/CNPJ Informado Header do Lote Invalido: ' || SUBSTR(vr_des_linha,19,14);
               RAISE vr_exc_saida;
             ELSIF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,18,01)) = FALSE ) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header do Lote incompativel com Tipo Inscricao: '|| SUBSTR(vr_des_linha,18,01);
               RAISE vr_exc_saida;
             ELSIF rw_crapass.inpessoa <> to_number(SUBSTR(vr_des_linha,18,01)) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header do Lote incompativel com Tipo Inscricao: '|| SUBSTR(vr_des_linha,18,01);
               RAISE vr_exc_saida;
             END IF;

             -- 14.1 a 15.1 Conta/DV
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,59,13)) = FALSE ) THEN
               vr_des_erro := 'Conta/DV Header do Lote Invalida: '|| SUBSTR(vr_des_linha,59,13);
               RAISE vr_exc_saida;
             ELSIF to_number(SUBSTR(vr_des_linha,59,13)) <> pr_nrdconta THEN
               vr_des_erro := 'Conta/DV Header do Lote Invalida: ' || SUBSTR(vr_des_linha,59,13);
               RAISE vr_exc_saida;
             END IF;

             -- 12.1 Ag�ncia Mantenedora da Conta
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,53,05)) = FALSE ) THEN
               vr_des_erro := 'Agencia Mantenedora da Conta Invalida: ' || SUBSTR(vr_des_linha,53,05);
               RAISE vr_exc_saida;
             ELSIF to_number(SUBSTR(vr_des_linha,53,05)) <> rw_crapcop.cdagectl THEN
               vr_des_erro := 'Agencia Mantenedora da Conta Invalida: ' || SUBSTR(vr_des_linha,53,05);
               RAISE vr_exc_saida;
             END IF;

             -- 11.1 C�digo do Conv�nio no Banco
             IF ( GENE0002.fn_numerico(pr_vlrteste => TRIM(SUBSTR(vr_des_linha,33,20))) = FALSE ) THEN
                vr_des_erro := 'Codigo do Convenio Header do Lote Invalida: '|| TRIM(SUBSTR(vr_des_linha,33,20));
                RAISE vr_exc_saida;
             ELSIF pr_nrconven <> to_number(SUBSTR(vr_des_linha,33,20)) THEN
                vr_des_erro := 'Codigo do Convenio Header do Lote Invalida: ' || TRIM(SUBSTR(vr_des_linha,33,20));
                RAISE vr_exc_saida;
             END IF;

             -- Controle se o Arquivo Possui Header de Lote
             vr_header_lot := TRUE;

           END IF;  -- Header do Lote

           -- Tratamento para garantir que arquivo tenha Header do Lote
           -- Utilizo contador para garantir que j� validou Header de Arquivo
           IF vr_contador > 1 AND vr_header_lot = FALSE THEN
             vr_des_erro := 'Arquivo nao possui Header de Lote.';
             RAISE vr_exc_saida;
           END IF;



           -- LINHA REGISTRO DETALHE
           -- EM CASO DE ERRO, DEVE GRAVAR LOG E CONTINUAR... NAO FAZ RAISE

           IF SUBSTR(vr_des_linha,08,01) = '3' THEN -- Registro Detalhe

             -- Quantidade Registros Processados
             vr_contador := vr_contador + 1;

             -- Quantidade Registros Detalhe
             vr_nrseqarq := vr_nrseqarq + 1;


             IF vr_nrseqarq = 1 THEN
               -- Insere registro na tabela Lote do Arquivo (craphpt)
               BEGIN
               INSERT INTO craphpt
                 (cdcooper,
                  nrdconta,
                  nrconven,
                  intipmvt,
                  nrremret,
                  dtmvtolt,
                  nmarquiv,
                  idorigem,
                  dtdgerac,
                  hrdgerac,
                  insithpt,
                  cdoperad)
                VALUES
                 (pr_cdcooper,
                  pr_nrdconta,
                  pr_nrconven,
                  1, -- Remessa
                  vr_nrremret,
                  pr_dtmvtolt,
                  pr_nmarquiv,
                  pr_idorigem,
                  vr_dtmvtolt,
                  to_char(SYSDATE,'HH24MISS'),
                  1, -- Pendente
                  pr_cdoperad);
               EXCEPTION
               WHEN OTHERS THEN
                 vr_des_erro := 'Erro ao inserir CRAPHPT(PGTA0001.pc_validar_arq_pgto): '||SQLERRM;
                 -- Rotina para gerar <arquivo> .LOG
                 PGTA0001.pc_gerar_arq_log_pgto(pr_cdcooper => pr_cdcooper
                                               ,pr_nmarquiv => vr_nmarquiv
                                               ,pr_descerro => vr_des_erro
                                               ,pr_cdcritic => pr_cdcritic
                                               ,pr_dscritic => pr_dscritic);
               END;
             END IF;

             -- Inicializa Variaveis
             vr_dscodbar := NULL;
             vr_dtdpagto := NULL;
             vr_cdtipmvt := NULL;
             vr_cdocorre := NULL;
             vr_cdinsmvt := NULL;

             -- 06.3J Tipo de Movimento
             -- 0 = Indica INCLUS�O
             -- 1 = Indica CONSULTA
             -- 2 = Indica SUSPENS�O
             -- 3 = Indica ESTORNO (somente para retorno)
             -- 4 = Indica REATIVA��O
             -- 5 = Indica ALTERA��O
             -- 7 = Indica LIQUIDA�AO
             -- 9 = Indica EXCLUS�O
             IF SUBSTR(vr_des_linha,15,01) NOT IN ('0','9') THEN -- Neste momento, liberado apenas INCLUSAO ou EXCLUSAO
               -- ESTAVA --> ('0','1','2','4','5','7','9')
               vr_cdtipmvt := nvl(to_number(SUBSTR(vr_des_linha,15,01)),0);    -- G060
               vr_cdocorre := nvl(vr_cdocorre,'AJ'); --G059 -> 'AJ' = Tipo de Movimento Inv�lido
             ELSE
               vr_cdtipmvt := to_number(SUBSTR(vr_des_linha,15,01));
             END IF;

             -- 07.3J Tipo de Instru��o p/ Movimento
             -- '00' = Inclus�o de Registro Detalhe Liberado
             -- '99' = Exclus�o do Registro Detalhe Inclu�do Anteriormente
             IF SUBSTR(vr_des_linha,16,02) NOT IN ('00','99') THEN -- Neste momento, liberado apenas INCLUSAO ou EXCLUSAO
                -- Estava --> ('00','09','10','11','17','19','23','25','27','33','40','99')
                vr_cdinsmvt := nvl(to_number(SUBSTR(vr_des_linha,16,02)),0); -- Pega o Codigo da Instrucao que veio no Arquivo
                vr_cdocorre := nvl(vr_cdocorre,'HK'); -- G059 -> 'HK' = Codigo de Remessa/Retorno invalido
             ELSE
               	vr_cdinsmvt := to_number(SUBSTR(vr_des_linha,16,02)); -- Pega o Codigo da Instrucao que veio no Arquivo
             END IF;

             -- 08.3J C�digo Barras
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,18,44)) = FALSE ) THEN
               -- (21,06) Codigo da Finalidade Invalido
               --vr_cdtipmvt := nvl(vr_cdtipmvt,0);    -- G060
               vr_dscodbar := NVL(SUBSTR(vr_des_linha,18,44),0);
               vr_cdocorre := nvl(vr_cdocorre,'CC'); -- G059 -> 'CC' = Codigo de Barras - Digito Verificador invalido
             ELSE
               vr_dscodbar:= SUBSTR(vr_des_linha,18,44);
             END IF;

             IF TRIM(vr_dscodbar) IS NOT NULL THEN
               -- Verifica se C�digo de Barra j� esta no Arquivo
               OPEN cr_crapdpt(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrremret => pr_nrremess
                              ,pr_dscodbar => vr_dscodbar);
               FETCH cr_crapdpt INTO rw_crapdpt;
               -- Se encontrar registro
               IF cr_crapdpt%FOUND THEN
                 -- Fechar o cursor
                 CLOSE cr_crapdpt;
                 -- (21,09) Cheque em Duplicidade
                 --vr_cdtipmvt := nvl(vr_cdtipmvt,0);    -- G060
                 -- Fora do G059 -> 0A = Codigo de Barras em duplicidade no arquivo
                 vr_cdocorre := nvl(vr_cdocorre,'0A'); 
               ELSE
                 -- Apenas fechar o cursor
                 CLOSE cr_crapdpt;
               END IF;

             END IF;

             -- 09.3J Nome do Cedente
             vr_nmcedent:= NVL(TRIM(SUBSTR(vr_des_linha,62,30)),' ');
             -- retira acentucao e & (e comercial)
             vr_nmcedent:= GENE0007.fn_caract_acento(vr_nmcedent,1,'&','E');

             -- 10.3J Data do Vencimento
             IF GENE0002.fn_data(pr_vlrteste => SUBSTR(vr_des_linha,92,08)
                                ,pr_formato => 'DD/MM/RRRR') = FALSE THEN
                -- (21,13) Data do Vencimento Invalida
                
                vr_dtvencto := vr_dtmvtolt; -- Nao tenho como pegar o conteudo dessa posicao e
                                            -- gravar numa variavel/tabela DPT - Tipos incompativeis                
                --vr_cdtipmvt := nvl(vr_cdtipmvt,0);     -- G060
                vr_cdocorre := nvl(vr_cdocorre,'AP');  -- G059 - 'AP' = Data Lan�amento Inv�lido
             ELSE
               IF ( to_date(SUBSTR(vr_des_linha,92,08),'DD/MM/RRRR') < vr_dtmvtolt ) THEN
                 -- (21,13) Data do Vencimento Invalida
                 --vr_cdtipmvt := nvl(vr_cdtipmvt,0);     -- G060
                 vr_dtvencto := to_date(SUBSTR(vr_des_linha,92,08),'DD/MM/RRRR');
                 vr_cdocorre := nvl(vr_cdocorre,'AP');  -- G059 - 'AP' = Data Lan�amento Inv�lido
               ELSE
                 vr_dtvencto := to_date(SUBSTR(vr_des_linha,92,08),'DD/MM/RRRR');
               END IF;

             END IF;

             -- 11.3J Valor do Titulo (Nominal)
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,100,15)) = FALSE ) THEN
                 -- (21,08) Valor do Titulo Invalido
                 --vr_cdtipmvt := nvl(vr_cdtipmvt,0);     -- G060
                 vr_vltitulo := 0; -- Nao tenho como pegar o conteudo dessa posicao e
                                   -- gravar numa variavel/tabela DPT - Tipos incompativeis
                 vr_cdocorre := nvl(vr_cdocorre,'CF');  -- G059 - 'CF' = Valor do Documento Inv�lido
             ELSE
                 vr_vltitulo := to_number(SUBSTR(vr_des_linha,100,15),'999999999999999') / 100;
             END IF;

             -- 12.3J Valor do Desconto + Abatimento
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,115,15)) = FALSE ) THEN
                -- (21,08) Valor do Desconto + Abatimento Invalido
                --vr_cdtipmvt := nvl(vr_cdtipmvt,0);     -- G060
                vr_vldescto := 0; -- Nao tenho como pegar o conteudo dessa posicao e
                                  -- gravar numa variavel/tabela DPT - Tipos incompativeis
                vr_cdocorre := nvl(vr_cdocorre,'CH');  -- G059 - 'CH' = Valor de Desconto Inv�lido
             ELSE
               vr_vldescto := to_number(SUBSTR(vr_des_linha,115,15),'999999999999999') / 100;
             END IF;

             -- 13.3J Valor da Mora + Multa
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,130,15)) = FALSE ) THEN
                -- (21,08) Valor do Desconto + Abatimento Invalido
                --vr_cdtipmvt := nvl(vr_cdtipmvt,0);     -- G060
                vr_vlacresc := 0; -- Nao tenho como pegar o conteudo dessa posicao e
                                  -- gravar numa variavel/tabela DPT - Tipos incompativeis
                vr_cdocorre := nvl(vr_cdocorre,'CI');  -- G059 - 'CI' = Valor de Mora Inv�lido
             ELSE
                vr_vlacresc := to_number(SUBSTR(vr_des_linha,130,15),'999999999999999') / 100;
             END IF;

             -- 14.3J Data do Pagamento
             IF GENE0002.fn_data(pr_vlrteste => SUBSTR(vr_des_linha,145,08)
                                ,pr_formato => 'DD/MM/RRRR') = FALSE THEN
                -- (21,13) Data do Pagamento Invalida
                --vr_cdtipmvt := nvl(vr_cdtipmvt,0);     -- G060
                vr_dtdpagto := vr_dtmvtolt; -- Nao tenho como pegar o conteudo dessa posicao e
                                            -- gravar numa variavel/tabela DPT - Tipos incompativeis
                vr_cdocorre := nvl(vr_cdocorre,'AP');  -- G059 - 'AP' = Data Lan�amento Inv�lido
             ELSE
               IF ( to_date(SUBSTR(vr_des_linha,145,08),'DD/MM/RRRR') < vr_dtmvtolt ) THEN
                 -- (21,13) Data do Pagamento Invalida
                 --vr_cdtipmvt := nvl(vr_cdtipmvt,0);     -- G060
                 vr_dtdpagto := to_date(SUBSTR(vr_des_linha,145,08),'DD/MM/RRRR');
                 vr_cdocorre := nvl(vr_cdocorre,'AP');  -- G059 - 'AP' = Data Lan�amento Inv�lido
               ELSE
                 vr_dtdpagto := to_date(SUBSTR(vr_des_linha,145,08),'DD/MM/RRRR');
               END IF;

             END IF;

             -- 15.3J Valor do Pagamento
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,153,15)) = FALSE ) THEN
               -- (21,08) Valor do Pagamento Invalido
               --vr_cdtipmvt := nvl(vr_cdtipmvt,0);     -- G060
               vr_vldpagto := 0; -- Nao tenho como pegar o conteudo dessa posicao e
                                 -- gravar numa variavel/tabela DPT - Tipos incompativeis
               vr_cdocorre := nvl(vr_cdocorre,'AR');  -- G059 - 'AR' = Valor do Lan�amento Inv�lido
             ELSE
               vr_vldpagto := to_number(SUBSTR(vr_des_linha,153,15),'999999999999999') / 100;
             END IF;

             -- 16.3J Quantidade da Moeda
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,168,05)) = FALSE ) THEN
               -- (21,08) Quantidade da Moeda Invalido
               --vr_cdtipmvt := nvl(vr_cdtipmvt,0);    -- G060
               vr_cdocorre := nvl(vr_cdocorre,'AQ'); -- G059 - 'AQ' = Tipo/Quantidade da Moeda Inv�lido
             END IF;

             -- 17.3J Numero Atribuido pelo Cooperado
             vr_dsusoemp := SUBSTR(vr_des_linha,183,20);
             
             -- 18.3J Nosso Numero
             vr_dsnosnum := SUBSTR(vr_des_linha,203,20);

             -- 19.3J C�digo da Moeda
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,223,02)) = FALSE ) THEN
               -- (21,08) C�digo da Moeda Invalido
               --vr_cdtipmvt := nvl(vr_cdtipmvt,0);    -- G060
               vr_cdocorre := nvl(vr_cdocorre,'AQ'); -- G059 - 'AQ' = Tipo/Quantidade da Moeda Inv�lido
             END IF;

             IF vr_dtdpagto IS NOT NULL THEN

               -- Daniel Incluir tratamento para caso arquivo seja processado feriado ou final semana
               IF vr_dtdpagto = vr_dtmvtolt THEN
                  vr_dtmvtopg := vr_dtdpagto;
               ELSE

                 -- Calcular a proxima data util
                  vr_dtmvtopg := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,
                                                             pr_dtmvtolt  => vr_dtdpagto,
                                                             pr_tipo      => 'P',    -- Proxima
                                                             pr_feriado   => TRUE,
                                                             pr_excultdia => FALSE);
               END IF;
             END IF;


             -- Caso n�o tenha error assume como Inclus�o Efetuada
             vr_cdtipmvt := nvl(vr_cdtipmvt,0);    -- G060 - 0' = Indica INCLUS�O
             vr_cdocorre := nvl(vr_cdocorre,'BD'); -- G059 - 'BD'= Inclus�o Efetuada com Sucesso
             vr_cdinsmvt := nvl(vr_cdinsmvt,0);    -- G061 - '00' = Inclus�o de Registro Detalhe Liberado

             -- Se a instrucao for 99 - EXCLUSAO, Altera o tipo do movimento
             IF vr_cdinsmvt = 99 THEN
                vr_cdtipmvt := 9;        -- G060 -> '9'  - Indica EXCLUSAO
                vr_cdocorre := 'BF';     -- G059 -> 'BF' - Exclusao Efetuada com Sucesso
             END IF;


             -- Insere registro na tabela Detalhamento Pagamento Titulos
             BEGIN
             INSERT INTO crapdpt
               (cdcooper,
                nrdconta,
                nrconven,
                intipmvt,
                nrremret,
                nrseqarq,
                cdtipmvt,
                cdinsmvt,
                dscodbar,
                nmcedent,
                dtvencto,
                vltitulo,
                vldescto,
                vlacresc,
                dtdpagto,
                vldpagto,
                dsusoemp,
                dsnosnum,
                cdocorre,
                dtmvtopg,
                intipreg)
              VALUES
               (pr_cdcooper,
                pr_nrdconta,
                pr_nrconven,
                1, -- Remessa
                vr_nrremret,
                vr_nrseqarq,
                vr_cdtipmvt, -- cdtipmvt -> 0-Indica INCLUS�O (Aqui estava 1 *fixo )
                vr_cdinsmvt,
                vr_dscodbar,
                vr_nmcedent,
                vr_dtvencto,
                vr_vltitulo,
                vr_vldescto,
                vr_vlacresc,
                vr_dtdpagto,
                vr_vldpagto,
                vr_dsusoemp,
                vr_dsnosnum,
                vr_cdocorre,
                vr_dtmvtopg,
                0);
             EXCEPTION
             WHEN OTHERS THEN
               vr_des_erro := 'Erro ao inserir CRAPDPT(PGTA0001.pc_validar_arq_pgto): '||SQLERRM || ' SEQ: '
                              || vr_nrseqarq || ' COD.BAR.:' || vr_dscodbar;
               -- Rotina para gerar <arquivo> .LOG
               PGTA0001.pc_gerar_arq_log_pgto(pr_cdcooper => pr_cdcooper
                                             ,pr_nmarquiv => vr_nmarquiv
                                             ,pr_descerro => vr_des_erro
                                             ,pr_cdcritic => pr_cdcritic
                                             ,pr_dscritic => pr_dscritic);
             END;


           END IF; -- FIM REGISTRO DETALHE



           IF SUBSTR(vr_des_linha,08,01) = '5' THEN -- Trailer de Lote
             vr_trailer_lot := TRUE;
           END IF; -- TRAILER DE LOTE



           IF SUBSTR(vr_des_linha,08,01) = '9' THEN -- Trailer de Arquivo
             vr_trailer_arq := TRUE;
           END IF; -- TRAILER DE ARQUIVO


         END LOOP; -- Fim LOOP linhas do arquivo
       EXCEPTION
         WHEN no_data_found THEN
           -- Acabou a leitura
           NULL;
       END;

       -- Fechar o arquivo
       GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo); --> Handle do arquivo aberto;

       -- Caso n�o tenha Trailer de Lote Rejeita Arquivo
       IF vr_trailer_lot = FALSE THEN
          vr_des_erro := 'Arquivo nao possui Trailer de Lote.';
          RAISE vr_exc_saida;
       END IF;

       -- Caso n�o tenha Trailer de Arquivo Rejeita Arquivo
       IF vr_trailer_arq = FALSE THEN
           vr_des_erro := 'Arquivo nao possui Trailer de Arquivo.';
           RAISE vr_exc_saida;
       END IF;

     END IF; -- vr_arquivo.count() > 0

  EXCEPTION
     WHEN vr_exc_saida THEN
        -- Fechar Handle do Arquivo Aberto
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

        -- Rotina para gerar <arquivo> .LOG
        PGTA0001.pc_gerar_arq_log_pgto(pr_cdcooper => pr_cdcooper
                                      ,pr_nmarquiv => vr_nmarquiv
                                      ,pr_descerro => vr_des_erro
                                      ,pr_cdcritic => pr_cdcritic
                                      ,pr_dscritic => pr_dscritic);

        -- Arquivo possui erros criticos, aborta processo de valida��o
        PGTA0001.pc_rejeitar_arq_pgto(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrconven => pr_nrconven
                                     ,pr_dtmvtolt => pr_dtmvtolt
                                     ,pr_nmarquiv => vr_nmarquiv
                                     ,pr_idorigem => pr_idorigem
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_dsmsgrej => vr_des_erro
                                     ,pr_cdcritic => pr_cdcritic
                                     ,pr_dscritic => pr_dscritic);

        -- Efetuar retorno do erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_des_erro;

        -- Efetua Rollback
        --ROLLBACK; -- Nao efetuar� ROLLBACK... sera controlado no CRPS689

     WHEN OTHERS THEN
        -- Fechar Handle do Arquivo Aberto
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

        -- Apenas retornar a vari�vel de saida
        pr_cdcritic := 0;
        pr_dscritic := 'Erro PGTA0001.pc_validar_arq_pgto: ' || SQLERRM;

        -- Efetua Rollback
        --ROLLBACK; -- Nao efetuar� ROLLBACK... sera controlado no CRPS689
  END;

  END pc_validar_arq_pgto;


  -- Procedure para processar o arquivo de remessa e gerar arquivo retorno
  PROCEDURE pc_processar_arq_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                  ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                  ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                  ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                  ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                  ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                  ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Operador
                                  ,pr_nrremess      IN craphpt.nrremret%TYPE  -- Numero da Remessa do Cooperado
                                  ,pr_nrremret     OUT craphpt.nrremret%TYPE  -- Numero Remessa/Retorno
                                  ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                  ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro
   BEGIN
     DECLARE
       -- CURSORES

       -- Dados do arquivo de remessa
       CURSOR cr_crapdpt(pr_cdcooper IN crapdpt.cdcooper%TYPE
                        ,pr_nrdconta IN crapdpt.nrdconta%TYPE
                        ,pr_nrconven IN crapdpt.nrconven%TYPE
                        ,pr_nrremess IN crapdpt.nrremret%TYPE) IS
        SELECT crapdpt.cdcooper
              ,crapdpt.nrdconta
              ,crapdpt.nrconven
              ,crapdpt.intipmvt
              ,crapdpt.nrremret
              ,crapdpt.nrseqarq
              ,crapdpt.cdtipmvt
              ,crapdpt.cdinsmvt
              ,crapdpt.dscodbar
              ,crapdpt.nmcedent
              ,crapdpt.dtvencto
              ,crapdpt.vltitulo
              ,crapdpt.vldescto
              ,crapdpt.vlacresc
              ,crapdpt.dtdpagto
              ,crapdpt.vldpagto
              ,crapdpt.dsusoemp
              ,crapdpt.dsnosnum
              ,crapdpt.cdocorre
              ,crapdpt.dtmvtopg
              ,crapdpt.intipreg
         FROM crapdpt crapdpt
        WHERE crapdpt.cdcooper = pr_cdcooper
          AND crapdpt.nrdconta = pr_nrdconta
          AND crapdpt.nrconven = pr_nrconven
          AND crapdpt.nrremret = pr_nrremess
          AND crapdpt.intipmvt = 1; -- Remessa
       rw_crapdpt cr_crapdpt%ROWTYPE;

       -- Buscar ultimo numero de retorno utilizado
       CURSOR cr_craphpt(pr_cdcooper IN craphpt.cdcooper%TYPE     --> C�digo da cooperativa
                        ,pr_nrdconta IN craphpt.nrdconta%TYPE     --> Numero da Conta
                        ,pr_nrconven IN craphpt.nrconven%TYPE) IS --> Numero do Convenio
         SELECT NVL(MAX(nrremret),0) nrremret
           FROM craphpt
          WHERE craphpt.cdcooper = pr_cdcooper
            AND craphpt.nrdconta = pr_nrdconta
            AND craphpt.nrconven = pr_nrconven
            AND craphpt.intipmvt = 2 -- Retorno
          ORDER BY craphpt.cdcooper,
                   craphpt.nrdconta,
                   craphpt.nrconven,
                   craphpt.intipmvt;
       rw_craphpt  cr_craphpt%ROWTYPE;


       --Selecionar os dados da tabela de Associados
       CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
         SELECT crapass.nrdconta
               ,crapass.cdagenci
               ,crapass.nrcpfcgc
               ,crapass.inpessoa
          FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
       rw_crapass cr_crapass%ROWTYPE;



       vr_nrremret craphpt.nrremret%TYPE;
       vr_nmarquiv craphpt.nmarquiv%TYPE;

       -- Variaveis OUT do valida-titulo
       vr_dscodbar crapdpt.dscodbar%TYPE;
       vr_dtmvtopg crapdpt.dtmvtopg%TYPE;
       vr_lindigi1 NUMBER;
       vr_lindigi2 NUMBER;
       vr_lindigi3 NUMBER;
       vr_lindigi4 NUMBER;
       vr_lindigi5 NUMBER;

       vr_nmextbcc VARCHAR2(100);
       vr_vlfatura NUMBER;
       vr_dtdifere BOOLEAN;
       vr_vldifere BOOLEAN;
       vr_nrctacob INTEGER;
       vr_insittit INTEGER;
       vr_intitcop INTEGER;
       vr_nrcnvcob NUMBER;
       vr_nrboleto NUMBER;
       vr_nrdctabb INTEGER;
       vr_dstransa VARCHAR2(100);
       vr_cobregis BOOLEAN;
       vr_msgalert VARCHAR2(300);
       vr_vlrjuros NUMBER;
       vr_vlrmulta NUMBER;
       vr_vldescto NUMBER;
       vr_vlabatim NUMBER;
       vr_vloutdeb NUMBER;
       vr_vloutcre NUMBER;
       vr_cdocorre VARCHAR2(5);
       vr_dtmvtolt DATE;


       vr_exc_critico EXCEPTION;
       vr_tab_erro GENE0001.typ_tab_erro;

       vr_utlfileh    VARCHAR2(4000);
       vr_origem_arq  VARCHAR2(4000);
       vr_destino_arq VARCHAR2(4000);

       BEGIN
         
         OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
         FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
         -- Se n�o encontrar
         IF BTCH0001.cr_crapdat%NOTFOUND THEN
           -- Fechar o cursor pois haver� raise
           CLOSE BTCH0001.cr_crapdat;
           -- Montar mensagem de critica
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
           RAISE vr_exc_critico;
         ELSE
           -- Apenas fechar o cursor
           CLOSE BTCH0001.cr_crapdat;
         END IF;
         
         vr_dtmvtolt := rw_crapdat.dtmvtolt;
       

         -- Gerar Informa��o de Retorno ao Cooperado (.RET)

         -- Buscar o �ltimo Lote de Retorno do Cooperado
         OPEN cr_craphpt(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrconven => pr_nrconven);
         FETCH cr_craphpt INTO rw_craphpt;

         -- Verifica se a retornou registro
         IF cr_craphpt%NOTFOUND THEN
            CLOSE cr_craphpt;
            -- Numero de Retorno
            vr_nrremret := 1;
         ELSE
            CLOSE cr_craphpt;
            -- Numero de Retorno
            vr_nrremret := rw_craphpt.nrremret + 1;
         END IF;


         -- Buscar dados do cooperado
         OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
         FETCH cr_crapass
          INTO rw_crapass;
         -- Se n�o encontrar
         IF cr_crapass%NOTFOUND THEN
           -- Fechar o cursor pois haver� raise
           CLOSE cr_crapass;
           vr_dscritic := 'Cooperado nao cadastrado.';
           RAISE vr_exc_critico;
         ELSE
           -- Apenas fechar o cursor
           CLOSE cr_crapass;
        END IF;


         vr_nmarquiv := 'PGT_' || TRIM(to_char(pr_nrdconta,'00000000'))  || '_' ||
                                  TRIM(to_char(vr_nrremret,'000000000')) || '.RET';

         -- Criar Lote de Informa��es de Retorno (craphpt)
         BEGIN
             INSERT INTO craphpt
               (cdcooper,
                nrdconta,
                nrconven,
                intipmvt,
                nrremret,
                dtmvtolt,
                nmarquiv,
                idorigem,
                dtdgerac,
                hrdgerac,
                insithpt,
                cdoperad)
             VALUES
               (pr_cdcooper,
                pr_nrdconta,
                pr_nrconven,
                2, -- Retorno
                vr_nrremret,
                pr_dtmvtolt,
                vr_nmarquiv,
                pr_idorigem,
                vr_dtmvtolt,
                to_char(SYSDATE,'HH24MISS'),
                1, -- Pendente
                pr_cdoperad);
         EXCEPTION
            WHEN OTHERS THEN
               vr_cdcritic := 0;
               vr_dscritic := 'Erro ao inserir craphpt: '||SQLERRM;
               RAISE vr_exc_critico;
         END;

         -- Gravar Variavel de Sa�da com o Numero do Retorno
         pr_nrremret := vr_nrremret;
         vr_cdocorre := '';

         -- Incluir todos os Registros da cr_crapdpt Usando Lote de Retorno (vr_nrremret)

         -- Ler todos os registros da crapdpt (Remessa) e gravar na crapdpt (Retorno)
         FOR rw_crapdpt IN cr_crapdpt(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrconven => pr_nrconven
                                     ,pr_nrremess => pr_nrremess) LOOP

            vr_dscodbar := rw_crapdpt.dscodbar;
            vr_dtmvtopg := rw_crapdpt.dtmvtopg;
            vr_cdocorre := rw_crapdpt.cdocorre;

            -- Verificar o parametro rw_crapdpt.cdinsmvt... se for 99 cancela...
            IF rw_crapdpt.cdinsmvt = 99 THEN -- 99 Exclusao do Agendamento
               pc_cancelar_agend_pgto (pr_cdcooper => rw_crapdpt.cdcooper
                                      ,pr_cdagenci => 90
                                      ,pr_nrdolote => 11900            -- (11000 + nrdcaixa)
                                      ,pr_cdbccxlt => 100              -- cdbccxlt
                                      ,pr_dtmvtolt => pr_dtmvtolt
                                      ,pr_nrdconta => rw_crapdpt.nrdconta
                                      ,pr_cdtiptra => 2                -- PAGAMENTO
                                      ,pr_dscodbar => vr_dscodbar
                                      ,pr_dtvencto => rw_crapdpt.dtvencto
                                      ,pr_dtmvtopg => rw_crapdpt.dtmvtopg
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_cdcritic => vr_cdcritic           --C�digo da critica
                                      ,pr_dscritic => vr_dscritic);         --Descricao critica
               -- Se deu algum erro na exclusao do agendamento

               IF TRIM(vr_dscritic) IS NOT NULL AND SUBSTR(vr_dscritic,01,01) = 'X' THEN
               -- Usado o pr_dscritic como retorno de sucesso em uma determinada situacao
                  vr_cdocorre := TRIM(vr_dscritic); -- Retornar� 'X' mais um numero
               ELSE
                  IF NOT (NVL(vr_cdcritic,0) = 0 AND TRIM(vr_dscritic) IS NULL) THEN
                     -- Caso tenha dado algum erro...
                     vr_cdocorre := '90';   -- Fora G059 - 90 - Lan�amento n�o encontrado
                     vr_dscritic := vr_dscritic || ' - CODBAR: ' || TO_CHAR(vr_dscodbar);
                     GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                          ,pr_cdagenci => 90
                                          ,pr_nrdcaixa => 900
                                          ,pr_nrsequen => 1 --> Fixo
                                          ,pr_cdcritic => 0 --> Critica 0 para n�o buscar do cadastro
                                          ,pr_dscritic => vr_dscritic
                                          ,pr_tab_erro => vr_tab_erro);
                     -- Envio centralizado de log de erro
                     btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                                pr_nmarqlog     => NULL,
                                                pr_ind_tipo_log => 2, -- Erro tratato
                                                pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                                   ' - PGTA0001.pc_processar_arq_pgto --> '
                                                                   || vr_dscritic);
                  ELSE
                    vr_cdocorre := 'BF';   -- G059 - 'BF' = Exclus�o Efetuada com Sucesso
                  END IF;
               END IF;
            ELSE
              --Verificar titulo
              vr_lindigi1 := 0;
              vr_lindigi2 := 0;
              vr_lindigi3 := 0;
              vr_lindigi4 := 0;
              vr_lindigi5 := 0;

              PAGA0001.pc_verifica_titulo (pr_cdcooper => pr_cdcooper           --Codigo da cooperativa
                                          ,pr_nrdconta => rw_crapdpt.nrdconta   --Numero da conta
                                          ,pr_idseqttl => 1                     --FIXO ---> Sequencial titular
                                          ,pr_idagenda => 2                     --Indicador agendamento 2-Agendamento
                                          ,pr_lindigi1 => vr_lindigi1           --Linha digitavel 1
                                          ,pr_lindigi2 => vr_lindigi2           --Linha digitavel 2
                                          ,pr_lindigi3 => vr_lindigi3           --Linha digitavel 3
                                          ,pr_lindigi4 => vr_lindigi4           --Linha digitavel 4
                                          ,pr_lindigi5 => vr_lindigi5           --Linha digitavel 5
                                          ,pr_cdbarras => vr_dscodbar           --IN OUT --Codigo de Barras
                                          ,pr_vllanmto => rw_crapdpt.vldpagto   --Valor Lancamento
                                          ,pr_dtagenda => vr_dtmvtopg           --IN OUT --Data agendamento
                                          ,pr_idorigem => pr_idorigem           --Indicador de origem
                                          ,pr_indvalid => 1                     --nao validar
                                          -- Abaixo, todas OUT...
                                          ,pr_nmextbcc => vr_nmextbcc           --Nome do banco
                                          ,pr_vlfatura => vr_vlfatura           --Valor fatura
                                          ,pr_dtdifere => vr_dtdifere           --Indicador data diferente
                                          ,pr_vldifere => vr_vldifere           --Indicador valor diferente
                                          ,pr_nrctacob => vr_nrctacob           --Numero Conta Cobranca
                                          ,pr_insittit => vr_insittit           --Indicador Situacao Titulo
                                          ,pr_intitcop => vr_intitcop           --Indicador Titulo Cooperativa
                                          ,pr_nrcnvcob => vr_nrcnvcob           --Numero Convenio Cobranca
                                          ,pr_nrboleto => vr_nrboleto           --Numero Boleto
                                          ,pr_nrdctabb => vr_nrdctabb           --Numero conta
                                          ,pr_dstransa => vr_dstransa           --Descricao transacao
                                          ,pr_cobregis => vr_cobregis           --Cobranca Registrada
                                          ,pr_msgalert => vr_msgalert           --mensagem alerta
                                          ,pr_vlrjuros => vr_vlrjuros           --Valor Juros
                                          ,pr_vlrmulta => vr_vlrmulta           --Valor Multa
                                          ,pr_vldescto => vr_vldescto           --Valor desconto
                                          ,pr_vlabatim => vr_vlabatim           --Valor Abatimento
                                          ,pr_vloutdeb => vr_vloutdeb           --Valor saida debito
                                          ,pr_vloutcre => vr_vloutcre           --Valor saida credito
                                          ,pr_cdcritic => vr_cdcritic           --C-odigo da critica
                                          ,pr_dscritic => vr_dscritic);         --Descricao critica
              --Se nao ocorreu erro
              IF NVL(vr_cdcritic,0) = 0 AND TRIM(vr_dscritic) IS NULL THEN
                 IF gene0002.fn_existe_valor(pr_base => 'BD' -- Situacoes de SUCESSO
                                            ,pr_busca => vr_cdocorre
                                            ,pr_delimite => ',' ) = 'S' THEN
                 --Executar Rotina Agendamento de titulo
                 PGTA0001.pc_cadastrar_agend_pgto(pr_cdcooper => rw_crapdpt.cdcooper
                                                 ,pr_nrdconta => rw_crapdpt.nrdconta
                                                 ,pr_dtmvtolt => pr_dtmvtolt
                                                 ,pr_cdoperad => pr_cdoperad
                                                 ,pr_cdagenci => 90
                                                 ,pr_nrdcaixa => 900
                                                 ,pr_idseqttl => 1                -- FIXO
                                                 ,pr_dsorigem => 'INTERNET'
                                                 ,pr_cdtiptra => 2                -- PAGAMENTO
                                                 ,pr_idtpdpag => 2                -- PGTO TITULO
                                                 ,pr_dscedent => rw_crapdpt.nmcedent
                                                 ,pr_dscodbar => vr_dscodbar
                                                 ,pr_lindigi1 => vr_lindigi1
                                                 ,pr_lindigi2 => vr_lindigi2
                                                 ,pr_lindigi3 => vr_lindigi3
                                                 ,pr_lindigi4 => vr_lindigi4
                                                 ,pr_lindigi5 => vr_lindigi5
                                                 ,pr_cdhistor => 508
                                                 ,pr_dtmvtopg => vr_dtmvtopg
                                                 ,pr_vllanaut => rw_crapdpt.vldpagto
                                                 ,pr_dtvencto => rw_crapdpt.dtvencto
                                                 ,pr_cddbanco => 0
                                                 ,pr_cdageban => 0
                                                 ,pr_nrctadst => 0
                                                 ,pr_cdcoptfn => 0
                                                 ,pr_cdagetfn => 0
                                                 ,pr_nrterfin => 0
                                                 ,pr_nrcpfope => 0
                                                 ,pr_idtitdda => 0
                                                 ,pr_dstransa => vr_dstransa
                                                 ,pr_cdcritic => vr_cdcritic           --C�digo da critica
                                                 ,pr_dscritic => vr_dscritic);         --Descricao critica
                 -- Se deu algum erro na inclusao do agendamento
                 IF NOT (NVL(vr_cdcritic,0) = 0 AND TRIM(vr_dscritic) IS NULL) THEN
                    -- Caso tenha dado algum erro...
                    vr_cdocorre := '99';   -- Fora G059 - 99 - Erro ao cadastrar agendamento
                    vr_dscritic := vr_dscritic || ' - CODBAR: ' || TO_CHAR(vr_dscodbar);
                    GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                         ,pr_cdagenci => 90
                                         ,pr_nrdcaixa => 900
                                         ,pr_nrsequen => 1 --> Fixo
                                         ,pr_cdcritic => 0 --> Critica 0 para n�o buscar do cadastro
                                         ,pr_dscritic => vr_dscritic
                                         ,pr_tab_erro => vr_tab_erro);
                    END IF;
                 END IF;
              ELSE
                
                 CASE nvl(vr_dscritic,' ')
                    WHEN 'Data do agendamento deve ser um dia util.'  THEN vr_cdocorre := '0B';
                    WHEN 'Titulo vencido.'                            THEN vr_cdocorre := '0C';
                    WHEN 'Agendamento nao permitido apos vencimento.' THEN vr_cdocorre := '0D';
                    WHEN 'Pagamento ja efetuado na cooperativa.'      THEN vr_cdocorre := '0E';
                    WHEN 'Agendamento ja existe.'                     THEN vr_cdocorre := '0F';
                    WHEN 'Banco nao encontrado.'                      THEN vr_cdocorre := '0G';
                    WHEN '008 - Digito errado.'                       THEN vr_cdocorre := 'CC';
		                WHEN 'Codigo de Barras invalido.'                 THEN vr_cdocorre := 'CC';
                    WHEN '057 - BANCO NAO CADASTRADO.'                THEN vr_cdocorre := '0G';
		                WHEN '965 - Convenio do cooperado nao homologado' THEN vr_cdocorre := '0H';
		                WHEN '966 - Cooperado sem convenio cadastrado'    THEN vr_cdocorre := '0I'; 
                    WHEN 'Valor nao permitido para agendamento.'      THEN vr_cdocorre := '0J'; /* VR Boleto */
	                  WHEN '592 - Bloqueto nao encontrado.'             THEN vr_cdocorre := '0K'; /* bloqueto n�o encontrado */
                    WHEN '594 - Bloqueto ja processado.'              THEN vr_cdocorre := '0L'; /* bloqueto j� pago */
                    WHEN 'Dados incompativeis. Pagamento nao realizado!' THEN vr_cdocorre := '0M'; /* codigo de barras fraudulento */
                 ELSE
                    vr_cdocorre := '99';
                 END CASE;
                 
                 IF vr_cdocorre = '99' THEN
                   CASE vr_cdcritic
                      WHEN 008 THEN vr_cdocorre := 'CC';
                      WHEN 092 THEN vr_cdocorre := '0E';
                      WHEN 057 THEN vr_cdocorre := '0G';
                      WHEN 965 THEN vr_cdocorre := '0H';
                      WHEN 966 THEN vr_cdocorre := '0I';
                      WHEN 592 THEN vr_cdocorre := '0K';
                      WHEN 594 THEN vr_cdocorre := '0L';
                   ELSE
                      vr_cdocorre := '99';
                   END CASE;                   
                 END IF;
                 
                 vr_dscritic := vr_dscritic || ' - CODBAR: ' || TO_CHAR(vr_dscodbar);

                 GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => 90
                                      ,pr_nrdcaixa => 900
                                      ,pr_nrsequen => 1 --> Fixo
                                      ,pr_cdcritic => 0 --> Critica 0 para n�o buscar do cadastro
                                      ,pr_dscritic => vr_dscritic
                                      ,pr_tab_erro => vr_tab_erro);
                 -- Envio centralizado de log de erro
                 btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                            pr_nmarqlog     => NULL,
                                            pr_ind_tipo_log => 2, -- Erro tratato
                                            pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                               ' - PGTA0001.pc_processar_arq_pgto --> '
                                                               || vr_dscritic);
              END IF;
            END IF; -- Fim do IF do cdinsmvt

            -- Insere dados na tabela crapdpt
            BEGIN
              INSERT INTO crapdpt
                (cdcooper,
                 nrdconta,
                 nrconven,
                 intipmvt,
                 nrremret,
                 nrseqarq,
                 cdtipmvt,
                 cdinsmvt,
                 dscodbar,
                 nmcedent,
                 dtvencto,
                 vltitulo,
                 vldescto,
                 vlacresc,
                 dtdpagto,
                 vldpagto,
                 dsusoemp,
                 dsnosnum,
                 cdocorre,
                 dtmvtopg,
                 intipreg)
              VALUES
                (rw_crapdpt.cdcooper,
                 rw_crapdpt.nrdconta,
                 rw_crapdpt.nrconven,
                 2, -- Retorno
                 vr_nrremret,
                 rw_crapdpt.nrseqarq,
                 rw_crapdpt.cdtipmvt,
                 rw_crapdpt.cdinsmvt,
                 rw_crapdpt.dscodbar,
                 rw_crapdpt.nmcedent,
                 rw_crapdpt.dtvencto,
                 rw_crapdpt.vltitulo,
                 rw_crapdpt.vldescto,
                 rw_crapdpt.vlacresc,
                 rw_crapdpt.dtdpagto,
                 rw_crapdpt.vldpagto,
                 rw_crapdpt.dsusoemp,
                 rw_crapdpt.dsnosnum,
                 vr_cdocorre,
                 rw_crapdpt.dtmvtopg,
                 rw_crapdpt.intipreg);

            EXCEPTION
               WHEN OTHERS THEN
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao inserir crapdpt: '||SQLERRM;
                  RAISE vr_exc_critico;
            END;

         END LOOP;

         -- OBSERVACAO:
         -- Se terminou de processasr os DPT, e nao ocorreu RAISE, limpa as variaveis de critica.
         -- Nesse ponto, se as informacoes foram tratadas corretamente sem EXCEPTION,
         -- devem ser gravadas na base. Se retornar cdcritic ou dscritic, o chamador far�  o
         -- RAISE, e consequentemente, um ROLLBACK, perdendo as informa��es.
         vr_cdcritic := 0;
         vr_dscritic := '';


         -- Rotina para mover o arquivo processado para a pasta
         -- <cooperativa>/salvar

         -- Define o diret�rio do arquivo
         vr_utlfileh := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                             ,pr_cdcooper => pr_cdcooper);
         -- Local Origem Arquivo
         vr_origem_arq  := vr_utlfileh || '/upload/' || pr_nmarquiv;

         -- Local Destino Arquivo
         vr_destino_arq := vr_utlfileh || '/salvar/' || pr_nmarquiv;


        -- Verifica se nome do arquivo foi informado
        IF LENGTH(pr_nmarquiv) > 0 THEN
          -- Move o Arquivo Processado para Pasta Salvar
          GENE0001.pc_OScommand_Shell('mv ' || vr_origem_arq || ' ' || vr_destino_arq);
        END IF;

     EXCEPTION
       WHEN vr_exc_critico THEN
         -- Atualiza campo de erro
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
         --ROLLBACK; -- Nao efetuar� ROLLBACK... sera controlado no CRPS689
       WHEN OTHERS THEN
         -- Atualiza campo de erro
         pr_cdcritic := 0;
         pr_dscritic := 'Erro PGTA0001.pc_processar_arq_pgto: ' || SQLERRM;
         --ROLLBACK; -- Nao efetuar� ROLLBACK... sera controlado no CRPS689
     END;

     -- Salva Altera��es Efetuadas
     -- COMMIT; -- Nao efetuar� COMMIT... sera controlado no CRPS689

  END pc_processar_arq_pgto;
 

  -- Procedure para Cadastrar o agendamento do PAgamento do Titulo
  PROCEDURE pc_cadastrar_agend_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                    ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                    ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                    ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                    ,pr_cdagenci      IN crapage.cdagenci%TYPE
                                    ,pr_nrdcaixa      IN craplot.nrdcaixa%TYPE
                                    ,pr_idseqttl      IN crapttl.idseqttl%TYPE
                                    ,pr_dsorigem      IN craplau.dsorigem%TYPE
                                    ,pr_cdtiptra      IN craplau.cdtiptra%TYPE
                                    ,pr_idtpdpag      IN INTEGER
                                    ,pr_dscedent      IN craplau.dscedent%TYPE
                                    ,pr_dscodbar      IN craplau.dscodbar%TYPE
                                    ,pr_lindigi1      IN INTEGER
                                    ,pr_lindigi2      IN INTEGER
                                    ,pr_lindigi3      IN INTEGER
                                    ,pr_lindigi4      IN INTEGER
                                    ,pr_lindigi5      IN INTEGER
                                    ,pr_cdhistor      IN craplau.cdhistor%TYPE
                                    ,pr_dtmvtopg      IN craplau.dtmvtopg%TYPE
                                    ,pr_vllanaut      IN craplau.vllanaut%TYPE
                                    ,pr_dtvencto      IN craplau.dtvencto%TYPE
                                    ,pr_cddbanco      IN craplau.cddbanco%TYPE
                                    ,pr_cdageban      IN craplau.cdageban%TYPE
                                    ,pr_nrctadst      IN craplau.nrctadst%TYPE
                                    ,pr_cdcoptfn      IN craplau.cdcoptfn%TYPE
                                    ,pr_cdagetfn      IN craplau.cdagetfn%TYPE
                                    ,pr_nrterfin      IN craplau.nrterfin%TYPE
                                    ,pr_nrcpfope      IN craplau.nrcpfope%TYPE
                                    ,pr_idtitdda      IN craplau.idtitdda%TYPE
                                    ,pr_dstransa      OUT VARCHAR2
                                    ,pr_cdcritic      OUT INTEGER                -- C�digo do erro
                                    ,pr_dscritic      OUT VARCHAR2) IS
    BEGIN

    DECLARE

      -- CURSORES

      -- Busca dados da tabela de Associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nrdconta
              ,crapass.cdagenci
              ,crapass.nrcpfcgc
              ,crapass.inpessoa
          FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Buscar os dados da tabela de Convenio
      CURSOR cr_crapcon (pr_cdcooper IN crapcon.cdcooper%TYPE
                        ,pr_cdempcon IN crapcon.cdempcon%TYPE
                        ,pr_cdsegmto IN crapcon.cdsegmto%TYPE) IS
        SELECT crapcon.cdcooper
        FROM crapcon crapcon
       WHERE crapcon.cdcooper = pr_cdcooper
         AND crapcon.cdempcon = pr_cdempcon
         AND crapcon.cdsegmto = pr_cdsegmto
         AND crapcon.flgcnvsi = 0; -- True

      -- Buscas dados da capa de lote
      CURSOR cr_craplot(pr_cdcooper craplot.cdcooper%TYPE,
                        pr_dtmvtolt craplot.dtmvtolt%TYPE,
                        pr_cdagenci craplot.cdagenci%TYPE,
                        pr_nrdolote craplot.nrdolote%TYPE) IS
        SELECT dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               tplotmov,
               vlinfocr,
               vlcompcr,
               qtinfoln,
               qtcompln,
               nrseqdig,
               ROWID
          FROM craplot
         WHERE craplot.cdcooper = pr_cdcooper
           AND craplot.dtmvtolt = pr_dtmvtolt
           AND craplot.cdagenci = pr_cdagenci
           AND craplot.cdbccxlt = 100
           AND craplot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

      vr_dslindig VARCHAR2(4000);

      vr_nrdolote NUMBER := 0;
      vr_cdtiptra NUMBER := 0;
      vr_cdtiptra NUMBER := 0;

      vr_tpdvalor NUMBER := 0;

      vr_nrcpfpre NUMBER := 0;

      vr_nmprepos VARCHAR2(4000);

      vr_exc_saida     EXCEPTION;
      vr_erro_update   EXCEPTION;

      vr_tab_erro GENE0001.typ_tab_erro;
      vr_dtmvtolt DATE;

      BEGIN
        
         OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
         FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
         -- Se n�o encontrar
         IF BTCH0001.cr_crapdat%NOTFOUND THEN
           -- Fechar o cursor pois haver� raise
           CLOSE BTCH0001.cr_crapdat;
           -- Montar mensagem de critica
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
           RAISE vr_exc_saida;
         ELSE
           -- Apenas fechar o cursor
           CLOSE BTCH0001.cr_crapdat;
         END IF;
         
         -- Armazenar a data de movimento do dia
         vr_dtmvtolt := rw_crapdat.dtmvtolt;
        

         IF pr_cdtiptra = 2  THEN
            IF pr_idtpdpag = 1  THEN
               pr_dstransa := 'Agendamento para Pagamento de Convenio (Fatura)';
            ELSE
               pr_dstransa := 'Agendamento para Pagamento de Titulo';
            END IF;

         END IF;

         -- Verifica se o cooperado esta cadastrada
         OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
         FETCH cr_crapass INTO rw_crapass;
         -- Se n�o encontrar
         IF cr_crapass%NOTFOUND THEN
           -- Fechar o cursor pois haver� raise
           CLOSE cr_crapass;
           vr_dscritic := 'Associado nao cadastrado.';
           RAISE vr_exc_saida;
         ELSE
           -- Apenas fechar o cursor
           CLOSE cr_crapass;
         END IF;


         IF pr_cdtiptra = 2  THEN -- Pagamento

            -- Monta numero do lote
            vr_nrdolote := 11000 + pr_nrdcaixa;

            IF pr_idtpdpag = 1 THEN -- Sera usado futuramente.
               -- Linha Digitavel
               vr_dslindig := SUBSTR(GENE0002.fn_mask(pr_lindigi1,'999999999999'),1,11) || '-' ||
                              SUBSTR(GENE0002.fn_mask(pr_lindigi1,'999999999999'),12,1) || ' ' ||
                              SUBSTR(GENE0002.fn_mask(pr_lindigi2,'999999999999'),1,11) || '-' ||
                              SUBSTR(GENE0002.fn_mask(pr_lindigi2,'999999999999'),12,1) || ' ' ||
                              SUBSTR(GENE0002.fn_mask(pr_lindigi3,'999999999999'),1,11) || '-' ||
                              SUBSTR(GENE0002.fn_mask(pr_lindigi3,'999999999999'),12,1) || ' ' ||
                              SUBSTR(GENE0002.fn_mask(pr_lindigi4,'999999999999'),1,11) || '-' ||
                              SUBSTR(GENE0002.fn_mask(pr_lindigi4,'999999999999'),12,1);

               -- Verifica se � convenio Sicredi
               OPEN cr_crapcon(pr_cdcooper => pr_cdcooper
                              ,pr_cdempcon => to_number(SUBSTR(to_char(pr_lindigi2,'999999999999'),5,4))
                              ,pr_cdsegmto => to_number(SUBSTR(to_char(pr_lindigi1,'999999999999'),2,1)));
               -- Se n�o encontrar
               IF cr_crapcon%FOUND THEN
                  vr_tpdvalor := 1;
               END IF;
            ELSE
               IF pr_idtpdpag = 2  THEN
                  vr_dslindig := GENE0002.fn_mask(pr_lindigi1,'99999.99999')   || ' ' ||
                                 GENE0002.fn_mask(pr_lindigi2,'99999.999999')  || ' ' ||
                                 GENE0002.fn_mask(pr_lindigi3,'99999.999999')  || ' ' ||
                                 GENE0002.fn_mask(pr_lindigi4,'9')             || ' ' ||
                                 GENE0002.fn_mask(pr_lindigi5,'99999999999999');
               END IF;
            END IF;
         END IF;

         -- Verifica se existe capa de lote agendamento
         OPEN cr_craplot(pr_cdcooper
                        ,pr_dtmvtolt
                        ,pr_cdagenci
                        ,vr_nrdolote);
         FETCH cr_craplot INTO rw_craplot;
         IF cr_craplot%NOTFOUND THEN
            -- Se nao existir cria a capa de lote
            BEGIN
               INSERT INTO craplot
                  (cdcooper,
                   dtmvtolt,
                   cdbccxlt,
                   nrdolote,
                   nrdcaixa,
                   cdoperad,
                   cdopecxa,
                   tplotmov)
                   VALUES
                  (pr_cdcooper,
                   pr_dtmvtolt,
                   100,          --cdbccxlt
                   vr_nrdolote,
                   pr_nrdcaixa,
                   pr_cdoperad,
                   pr_cdoperad,
                   12)           --tplotmov
                   RETURNING dtmvtolt,
                             cdagenci,
                             cdbccxlt,
                             nrdolote,
                             tplotmov,
                             vlinfocr,
                             vlcompcr,
                             qtinfoln,
                             qtcompln,
                             nrseqdig,
                             ROWID
                    INTO rw_craplot.dtmvtolt,
                         rw_craplot.cdagenci,
                         rw_craplot.cdbccxlt,
                         rw_craplot.nrdolote,
                         rw_craplot.tplotmov,
                         rw_craplot.vlinfocr,
                         rw_craplot.vlcompcr,
                         rw_craplot.qtinfoln,
                         rw_craplot.qtcompln,
                         rw_craplot.nrseqdig,
                         rw_craplot.rowid;
            EXCEPTION
               WHEN OTHERS THEN
                  -- Gerar erro 0 com critica montada com o erro do insert
                  vr_dscritic := 'Erro ao inserir na CRAPLOT : ' || SQLERRM;
                  -- Levantar excecao
                  RAISE vr_exc_saida;
            END;
         END IF;
         -- Fecha o cursor de capas de lote
         CLOSE cr_craplot;

         vr_nmprepos := ' ';
         vr_nrcpfpre := 0;


         BEGIN
            INSERT INTO craplau
               (cdcooper
               ,nrdconta
               ,idseqttl
               ,dttransa
               ,hrtransa
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,nrseqdig
               ,nrdocmto
               ,cdhistor
               ,dsorigem
               ,insitlau
               ,cdtiptra
               ,dscedent
               ,dscodbar
               ,dslindig
               ,dtmvtopg
               ,vllanaut
               ,dtvencto
               ,cddbanco
               ,cdageban
               ,nrctadst
               ,cdcoptfn
               ,cdagetfn
               ,nrterfin
               ,nrcpfope
               ,nrcpfpre
               ,nmprepos
               ,idtitdda
               ,tpdvalor)
             VALUES
               (pr_cdcooper
               ,pr_nrdconta
               ,pr_idseqttl
               ,trunc(vr_dtmvtolt)
               ,to_number(to_char(SYSDATE,'SSSSS'))
               ,pr_dtmvtolt
               ,rw_craplot.cdagenci
               ,rw_craplot.cdbccxlt
               ,rw_craplot.nrdolote
               ,rw_craplot.nrseqdig + 1
               ,rw_craplot.nrseqdig + 1
               ,pr_cdhistor  -- 508
               ,pr_dsorigem  -- INTERNET
               ,1            -- Pendente insitlau
               ,pr_cdtiptra  -- pgto titulo (2)
               ,UPPER(pr_dscedent)
               ,pr_dscodbar
               ,vr_dslindig
               ,pr_dtmvtopg
               ,pr_vllanaut
               ,pr_dtvencto
               ,pr_cddbanco
               ,pr_cdageban
               ,pr_nrctadst
               ,pr_cdcoptfn
               ,pr_cdagetfn
               ,pr_nrterfin
               ,pr_nrcpfope
               ,vr_nrcpfpre
               ,vr_nmprepos
               ,pr_idtitdda
               ,vr_tpdvalor);
         EXCEPTION
            WHEN OTHERS THEN
               vr_dscritic := 'Nao foi possivel agendar o pagamento. ';
               vr_dscritic := vr_dscritic || SQLERRM;
               --Levantar Excecao
               RAISE vr_exc_saida;
         END;

         BEGIN
            UPDATE craplot
               SET vlinfodb = vlinfodb + pr_vllanaut, -- Debito
                   vlcompdb = vlcompdb + pr_vllanaut, -- Debito
                   qtinfoln = qtinfoln + 1,
                   qtcompln = qtcompln + 1,
                   nrseqdig = nrseqdig + 1
             WHERE ROWID = rw_craplot.rowid
             RETURNING vlinfocr,
                       vlcompcr,
                       qtinfoln,
                       qtcompln,
                       nrseqdig
                  INTO rw_craplot.vlinfocr,
                       rw_craplot.vlcompcr,
                       rw_craplot.qtinfoln,
                       rw_craplot.qtcompln,
                       rw_craplot.nrseqdig;
         EXCEPTION
            WHEN OTHERS THEN
               -- Gerar erro 0 com critica montada com o erro do update
               vr_dscritic := 'Erro ao atualizar a CRAPLOT : ' || SQLERRM;
               GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_nrsequen => 1 --> Fixo
                                    ,pr_cdcritic => 0 --> Critica 0 para n�o buscar do cadastro
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_tab_erro => vr_tab_erro);
               -- Envio centralizado de log de erro
               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                          pr_nmarqlog     => NULL,
                                          pr_ind_tipo_log => 2, -- Erro tratato
                                          pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                             ' - PGTA0001.pc_cadastrar_agend_pgto --> '
                                                             || vr_dscritic);
               -- Levantar excecao
               RAISE vr_exc_saida;
         END;

         -- DDA
         IF pr_idtitdda > 0 THEN

            DDDA0001.pc_atualz_situac_titulo_sacado(pr_cdcooper => pr_cdcooper
                                                   ,pr_cdagecxa => pr_cdagenci
                                                   ,pr_nrdcaixa => 900
                                                   ,pr_cdopecxa => '996'
                                                   ,pr_nmdatela => 'INTERNETBANK'
                                                   ,pr_idorigem => 3 -- Internet
                                                   ,pr_nrdconta => pr_nrdconta
                                                   ,pr_idseqttl => pr_idseqttl
                                                   ,pr_idtitdda => pr_idtitdda
                                                   ,pr_cdsittit => 2 -- Agendado
                                                   ,pr_flgerlog => FALSE
                                                   ,pr_des_erro => vr_dscritic
                                                   ,pr_tab_erro => vr_tab_erro);

            IF TRIM(vr_dscritic) IS NOT NULL OR
               vr_tab_erro.COUNT > 0 THEN

               -- Tenta buscar o erro no vetor de erro
               IF vr_tab_erro.COUNT > 0 THEN
                  vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                  vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
               ELSE
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Falha na requisicao ao DDA..';
               END IF;

               RAISE vr_exc_saida;

            END IF;
         END IF;


      EXCEPTION
         WHEN vr_exc_saida THEN
            pr_cdcritic := 0;
            pr_dscritic := vr_dscritic;
            --ROLLBACK; -- Nao efetuar� ROLLBACK... sera controlado no CRPS689
         WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := vr_dscritic;
            --ROLLBACK; -- Nao efetuar� ROLLBACK... sera controlado no CRPS689
      END;

  END pc_cadastrar_agend_pgto;


  PROCEDURE pc_cancelar_agend_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                   ,pr_cdagenci      IN crapage.cdagenci%TYPE
                                   ,pr_nrdolote      IN craplot.nrdolote%TYPE
                                   ,pr_cdbccxlt      IN craplot.cdbccxlt%TYPE
                                   ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                   ,pr_cdtiptra      IN craplau.cdtiptra%TYPE
                                   ,pr_dscodbar      IN craplau.dscodbar%TYPE
                                   ,pr_dtvencto      IN craplau.dtvencto%TYPE
                                   ,pr_dtmvtopg      IN craplau.dtmvtopg%TYPE
                                   ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                   ,pr_cdcritic      OUT INTEGER                -- C�digo do erro
                                   ,pr_dscritic      OUT VARCHAR2) IS

     CURSOR cr_craplau_1 (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN craplau.nrdconta%TYPE
                         ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE
                         ,pr_dscodbar IN craplau.dscodbar%TYPE) IS
       SELECT
             /*+index (craplau craplau##craplau2)*/
              craplau.cdcooper
             ,craplau.dtmvtopg
             ,craplau.nrdconta
             ,craplau.ROWID
        FROM craplau craplau
       WHERE craplau.cdcooper = pr_cdcooper
         AND craplau.nrdconta = pr_nrdconta
         AND craplau.cdhistor = 508
         AND craplau.dscodbar = pr_dscodbar
         AND craplau.dtmvtopg = pr_dtmvtopg
         AND craplau.cdtiptra = 2
         AND craplau.insitlau = 1;
     rw_craplau_sit_1 cr_craplau_1%ROWTYPE;


     CURSOR cr_craplau_2 (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN craplau.nrdconta%TYPE
                         ,pr_dtmvtopg IN craplau.dtmvtopg%TYPE
                         ,pr_dscodbar IN craplau.dscodbar%TYPE) IS
       SELECT /*+index (craplau craplau##craplau2)*/
              craplau.cdcooper
             ,craplau.dtmvtopg
             ,craplau.nrdconta
             ,craplau.insitlau
             ,craplau.ROWID
        FROM craplau craplau
       WHERE craplau.cdcooper = pr_cdcooper
         AND craplau.nrdconta = pr_nrdconta
         AND craplau.cdhistor = 508
         AND craplau.dscodbar = pr_dscodbar
         AND craplau.dtmvtopg = pr_dtmvtopg
         AND craplau.cdtiptra = 2;
     rw_craplau_sem_sit cr_craplau_2%ROWTYPE;


     vr_rowid         ROWID;

     vr_tab_erro GENE0001.typ_tab_erro;

     vr_exc_saida     EXCEPTION;
     vr_erro_update   EXCEPTION;

     BEGIN

        OPEN cr_craplau_1(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_dtmvtopg => pr_dtmvtopg
                         ,pr_dscodbar => pr_dscodbar);
        FETCH cr_craplau_1 INTO rw_craplau_sit_1;

        IF cr_craplau_1%NOTFOUND THEN
           -- Se n�o encontrar - Pesquisa via cr_craplau_2
           OPEN cr_craplau_2(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_dtmvtopg => pr_dtmvtopg
                            ,pr_dscodbar => pr_dscodbar);
           FETCH cr_craplau_2 INTO rw_craplau_sem_sit;

           IF cr_craplau_2%FOUND THEN
              pr_dscritic := 'X' || to_char(rw_craplau_sem_sit.insitlau);
           END IF;
           -- Fechar o cursor
           CLOSE cr_craplau_2;
        ELSE
           vr_rowid := rw_craplau_sit_1.rowid;
           -- Fechar o cursor
           CLOSE cr_craplau_1;
        END IF;


        IF vr_rowid IS NOT NULL THEN
           BEGIN
              UPDATE craplau
                 SET craplau.insitlau = 3
                    ,craplau.dtdebito = craplau.dtmvtopg
               WHERE craplau.rowid    = vr_rowid;

           EXCEPTION
              WHEN OTHERS THEN
                 -- Gerar erro 0 com critica montada com o erro do update
                 vr_dscritic := 'Erro ao atualizar a CRAPLAU : ' || SQLERRM;
                 GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci
                                      ,pr_nrdcaixa => 900
                                      ,pr_nrsequen => 1 --> Fixo
                                      ,pr_cdcritic => 0 --> Critica 0 para n�o buscar do cadastro
                                      ,pr_dscritic => vr_dscritic
                                      ,pr_tab_erro => vr_tab_erro);
                 btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                            pr_nmarqlog     => NULL,
                                            pr_ind_tipo_log => 2, -- Erro tratato
                                            pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                               ' - PGTA0001.pc_cancelar_agend_pgto --> '
                                                               || vr_dscritic);
                 -- Levantar excecao
                 RAISE vr_exc_saida;
           END;
        ELSE
           IF  pr_dscritic IS NULL THEN -- Se nao for NULO � pq caiu no cursor LAU_2
               vr_dscritic := 'Nao foi possivel localizar agendamento do pagamento.';
               RAISE vr_exc_saida;
           END IF;
        END IF;

     EXCEPTION
        WHEN vr_exc_saida THEN
           pr_cdcritic := 0;
           pr_dscritic := vr_dscritic;
           --ROLLBACK; -- Nao efetuar� ROLLBACK... sera controlado no CRPS689
        WHEN OTHERS THEN
           pr_cdcritic := 0;
           pr_dscritic := vr_dscritic;
           --ROLLBACK; -- Nao efetuar� ROLLBACK... sera controlado no CRPS689

  END pc_cancelar_agend_pgto;


  -- Procedure para rejeitar arquivo de remessa
  PROCEDURE pc_rejeitar_arq_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                 ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                 ,pr_nrconven      IN craphpt.nrconven%TYPE  -- Numero do Convenio
                                 ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                 ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                 ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                 ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                 ,pr_dsmsgrej      IN VARCHAR2               -- Motivo da Rejei��o
                                 ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                 ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro
  PRAGMA AUTONOMOUS_TRANSACTION;                                 
  BEGIN

  DECLARE

    -- Verificar qual Tipo de Retorno o Cooperado Possui
    CURSOR cr_crapcpt (pr_cdcooper IN crapcpt.cdcooper%TYPE
                      ,pr_nrdconta IN crapcpt.nrdconta%TYPE
                      ,pr_nrconven IN crapcpt.nrconven%TYPE) IS
      SELECT crapcpt.idretorn
      FROM crapcpt crapcpt
      WHERE crapcpt.cdcooper = pr_cdcooper AND
            crapcpt.nrdconta = pr_nrdconta AND
            crapcpt.nrconven = pr_nrconven;
    rw_crapcpt cr_crapcpt%ROWTYPE;

    -- Busca dados da Cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapccc.cdcooper%TYPE) IS
      SELECT crapcop.dsdircop
      FROM crapcop crapcop
      WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Nome do Arquivo .ERR
    vr_nmarquivo_err VARCHAR2(4000);

    -- Nome do Arquivo .LOG
    vr_nmarquivo_log VARCHAR2(4000);

    vr_exc_erro EXCEPTION;
    vr_nrdrowid ROWID;

    -- Descri��o da Origem
    vr_dsorigem VARCHAR2(100);

    vr_diretorio_log VARCHAR2(4000);
    vr_diretorio_err VARCHAR2(4000);
    vr_dir_coop VARCHAR2(4000);

    vr_serv_ftp VARCHAR2(100);
    vr_user_ftp VARCHAR2(100);
    vr_pass_ftp VARCHAR2(100);

    vr_comando VARCHAR2(4000);

    vr_typ_saida VARCHAR2(3);

    vr_dir_retorno VARCHAR2(4000);

    vr_script_pgto VARCHAR2(4000);

  BEGIN
    -- Inicializa Variaveis
    vr_cdcritic:= 0;
    vr_dscritic:= NULL;

    -- Monta nome do Arquivo de Erro (.ERR)
    vr_nmarquivo_err := REPLACE(UPPER(pr_nmarquiv),'.REM','.ERR');

    -- Monta nome do Arquivo de Log (.LOG)
    vr_nmarquivo_log := REPLACE(UPPER(pr_nmarquiv),'.REM','.LOG');

    -- Verificar qual Tipo de Retorno o Cooperado Possui
    OPEN cr_crapcpt(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrconven => pr_nrconven);
    FETCH cr_crapcpt INTO rw_crapcpt;
    --Se nao encontrou
    IF cr_crapcpt%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcpt;
      vr_cdcritic := 0;
      vr_dscritic := 'Cooperado sem Tipo de Retorno Cadastrado.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      --Fechar Cursor
      CLOSE cr_crapcpt;
    END IF;

    -- Busca nome resumido da cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 0;
      vr_dscritic := 'Cooperativa nao Cadastrada.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      --Fechar Cursor
      CLOSE cr_crapcop;
    END IF;

    -- Diret�rio da Cooperativa
    vr_dir_coop := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper);

    -- Diret�rio do arquivo de Log (.LOG)
    vr_diretorio_log := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/arq') ;

    -- Diret�rio do arquivo de Erro (.ERR)
    vr_diretorio_err := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/upload') ;

    -- Renomeia o Arquivo .REM para .ERR
    GENE0001.pc_OScommand_Shell('mv ' || vr_diretorio_err || '/' || pr_nmarquiv || ' ' ||
                                vr_diretorio_err || '/' || vr_nmarquivo_err);

    IF rw_crapcpt.idretorn = 2 THEN -- Retorno via FTP

      -- Caminho script que envia/recebe arquivos via FTP
      vr_script_pgto := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                 ,pr_cdcooper => '0'
                                                 ,pr_cdacesso => 'SCRIPT_ENV_REC_PGTO_ARQ');

      vr_serv_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'PGTO_ARQ_SERV_FTP');

      vr_user_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'PGTO_ARQ_USER_FTP');

      vr_pass_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'PGTO_ARQ_PASS_FTP');

      vr_dir_retorno := '/' ||TRIM(rw_crapcop.dsdircop)   ||
                        '/' || TRIM(to_char(pr_nrdconta)) || '/RETORNO';

      -- Copia Arquivo .ERR para Servidor FTP
      vr_comando := vr_script_pgto                                 || ' ' ||
      '-envia'                                                     || ' ' ||
      '-srv '         || vr_serv_ftp                               || ' ' || -- Servidor
      '-usr '         || vr_user_ftp                               || ' ' || -- Usuario
      '-pass '        || vr_pass_ftp                               || ' ' || -- Senha
      '-arq '         || CHR(39) || vr_nmarquivo_err || CHR(39)    || ' ' || -- .ERR
      '-dir_local '   || vr_diretorio_err                          || ' ' || -- /usr/coop/<cooperativa>/upload
      '-dir_remoto '  || vr_dir_retorno                            || ' ' || -- /<conta do cooperado>/RETORNO
      '-salvar '      || vr_dir_coop || '/salvar'                  || ' ' || -- /usr/coop/<cooperativa>/salvar
      '-log '         || vr_dir_coop || '/log/pgto_por_arquivo.log';         -- /usr/coop/<cooperativa>/log/pgto_por_arquivo.log

      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => pr_dscritic
                           ,pr_flg_aguard  => 'S');

      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
        RAISE vr_exc_erro;
      END IF;


      -- Copia Arquivo .LOG para Servidor FTP
      vr_comando := vr_script_pgto                                 || ' ' ||
      '-envia'                                                     || ' ' ||
      '-srv '         || vr_serv_ftp                               || ' ' || -- Servidor
      '-usr '         || vr_user_ftp                               || ' ' || -- Usuario
      '-pass '        || vr_pass_ftp                               || ' ' || -- Senha
      '-arq '         || vr_nmarquivo_log                          || ' ' || -- .LOG
      '-dir_local '   || vr_diretorio_log                          || ' ' || -- /usr/coop/<cooperativa>/arq
      '-dir_remoto '  || vr_dir_retorno                            || ' ' || -- /<coop>/<conta do cooperado>/RETORNO
      '-salvar '      || vr_dir_coop || '/salvar'                  || ' ' || -- /usr/coop/<cooperativa>/salvar
      '-log '         || vr_dir_coop || '/log/pgto_por_arquivo.log';         -- /usr/coop/<cooperativa>/log/pgto_por_arquivo.log

      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => pr_dscritic
                           ,pr_flg_aguard  => 'S');

      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
        RAISE vr_exc_erro;
      END IF;
/*
    ELSE -- rw_crapccc.idretorn = 1 (InternetBanking)

      -- Verifica a exist�ncia do arquivo .LOG
      IF GENE0001.fn_exis_arquivo(pr_caminho => vr_diretorio_log || '/' || vr_nmarquivo_log) THEN
        -- Verifica se nome do arquivo foi informado
        IF LENGTH(TRIM(vr_nmarquivo_log)) > 0 THEN
           -- Deletar arquivo .LOG
           GENE0001.pc_OScommand_Shell('rm ' || vr_diretorio_log || '/' || vr_nmarquivo_log);
        END IF;
      END IF;

      -- Verifica a exist�ncia do arquivo .ERR
      IF GENE0001.fn_exis_arquivo(pr_caminho => vr_diretorio_err || '/' || vr_nmarquivo_err) THEN
        -- Verifica se nome do arquivo foi informado
        IF length(vr_nmarquivo_err) > 0 THEN
           -- Deletar arquivo .ERR
           GENE0001.pc_OScommand_Shell('rm ' || vr_diretorio_err || '/' || vr_nmarquivo_err);
        END IF;
      END IF;

      vr_cdcritic := 0;
      vr_dscritic := 'Arquivo Invalido. Erro de Estrutura!';*/
    END IF;

    -- Verifica Qual a Origem
    CASE pr_idorigem
      WHEN 1 THEN vr_dsorigem := 'AYLLOS';
      WHEN 3 THEN vr_dsorigem := 'INTERNET';
      --WHEN 3 THEN vr_dsorigem := 'FTP';
      ELSE vr_dsorigem := ' ';
    END CASE;

    -- Gerar log ao cooperado (b1wgen0014 - gera_log);
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => pr_dsmsgrej
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => 'Arquivo ' || pr_nmarquiv || ' de pagamentos foi rejeitado!'
                        ,pr_dttransa => pr_dtmvtolt
                        ,pr_flgtrans => 0 -- TRUE
                        ,pr_hrtransa => to_number(to_char(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => ' '
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

    COMMIT; -- Commita a transa��o de cria��o do registro de log

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorna variaveis de saida
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Atualiza campo de erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro PGTA0001.pc_rejeitar_arq_pgto: ' || SQLERRM;
  END;


  END pc_rejeitar_arq_pgto;


  -- Gera retorno dos titulos PAGOS - Que ja foram processados pela DEBNET(CRPS509)
  PROCEDURE pc_gera_retorno_tit_pago (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                     ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                     ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                     ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Operador
                                     ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                     ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro

     -- Dados do arquivo de remessa
     CURSOR cr_crapdpt(pr_cdcooper IN crapdpt.cdcooper%TYPE
                      ,pr_dtmvtopg IN crapdpt.dtmvtopg%TYPE) IS
      SELECT crapdpt.cdcooper
            ,crapdpt.nrdconta
            ,crapdpt.nrconven
            ,crapdpt.intipmvt
            ,crapdpt.nrremret
            ,crapdpt.nrseqarq
            ,crapdpt.cdtipmvt
            ,crapdpt.cdinsmvt
            ,crapdpt.dscodbar
            ,crapdpt.nmcedent
            ,crapdpt.vltitulo
            ,crapdpt.vldescto
            ,crapdpt.vlacresc
            ,crapdpt.dtdpagto
            ,crapdpt.vldpagto
            ,crapdpt.dsusoemp
            ,crapdpt.dsnosnum
            ,crapdpt.cdocorre
            ,crapdpt.intipreg
            ,craplau.insitlau
            ,craplau.dtmvtopg
            ,craplau.dtvencto
            ,ROW_NUMBER () OVER (PARTITION BY crapdpt.nrdconta
                                     ORDER BY crapdpt.nrdconta) sqatureg
            ,COUNT(1) OVER (PARTITION BY crapdpt.nrdconta)      qtregtot
       FROM crapdpt crapdpt
           ,craplau craplau
      WHERE crapdpt.cdcooper = pr_cdcooper
        AND crapdpt.dtmvtopg = pr_dtmvtopg
        AND crapdpt.intipmvt = 2      -- Retorno
        AND crapdpt.cdtipmvt = 0      -- Inclusao
        AND crapdpt.cdocorre = 'BD'   -- Inclusao Sucesso
        AND craplau.cdcooper = crapdpt.cdcooper
        AND craplau.dtmvtopg = crapdpt.dtmvtopg
        AND craplau.nrdconta = crapdpt.nrdconta
        AND craplau.dscodbar = crapdpt.dscodbar
        AND craplau.insitlau IN(2,4)  -- 2-Efetivado ou 4-Nao Efetivado
      ORDER BY crapdpt.nrdconta;
     rw_crapdpt cr_crapdpt%ROWTYPE;

     -- Buscar ultimo numero de retorno utilizado
     CURSOR cr_craphpt(pr_cdcooper IN craphpt.cdcooper%TYPE     --> C�digo da cooperativa
                      ,pr_nrdconta IN craphpt.nrdconta%TYPE     --> Numero da Conta
                      ,pr_nrconven IN craphpt.nrconven%TYPE) IS --> Numero do Convenio
      SELECT NVL(MAX(nrremret),0) nrremret
        FROM craphpt
       WHERE craphpt.cdcooper = pr_cdcooper
         AND craphpt.nrdconta = pr_nrdconta
         AND craphpt.nrconven = pr_nrconven
         AND craphpt.intipmvt = 2 -- Retorno
       ORDER BY craphpt.cdcooper,
                craphpt.nrdconta,
                craphpt.nrconven,
                craphpt.intipmvt;
     rw_craphpt cr_craphpt%ROWTYPE;

     vr_nrremret craphpt.nrremret%TYPE;
     vr_nmarquiv craphpt.nmarquiv%TYPE;
     vr_cdtipmvt crapdpt.cdtipmvt%TYPE;
     vr_cdinsmvt crapdpt.cdinsmvt%TYPE;
     vr_cdocorre VARCHAR2(5);
     vr_nrseqarq crapdpt.nrseqarq%TYPE;

     vr_exc_critico EXCEPTION;
     vr_tab_erro GENE0001.typ_tab_erro;
     vr_dtmvtolt DATE;

     BEGIN
       
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        -- Se n�o encontrar
        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois haver� raise
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
          RAISE vr_exc_critico;
        ELSE
          -- Apenas fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;
              
        -- Armazenar a data de movimento do dia
        vr_dtmvtolt := rw_crapdat.dtmvtolt;
     
        -- Gerar Informa��o de Retorno ao Cooperado - Efetivacao do Pagametno (.RET)

        -- Ler todos os registros da crapdpt (Retorno) e gravar na crapdpt (Liquidado)
        FOR rw_crapdpt IN cr_crapdpt(pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtopg => pr_dtmvtolt) LOOP

           IF rw_crapdpt.sqatureg = 1 THEN  -- Primeiro Registro - FIRST-OF do NrdConta

              vr_nrremret := 0;
              vr_nrseqarq := 0;
              vr_nmarquiv := '';

              -- Buscar o �ltimo Lote de Retorno do Cooperado
              OPEN cr_craphpt(pr_cdcooper => rw_crapdpt.cdcooper
                             ,pr_nrdconta => rw_crapdpt.nrdconta
                             ,pr_nrconven => rw_crapdpt.nrconven);
              FETCH cr_craphpt INTO rw_craphpt;
              -- Verifica se a retornou registro
              IF cr_craphpt%NOTFOUND THEN
                 CLOSE cr_craphpt;
                 -- Numero de Retorno
                 vr_nrremret := 1;
              ELSE
                 CLOSE cr_craphpt;
                 -- Numero de Retorno
                 vr_nrremret := rw_craphpt.nrremret + 1;
              END IF;

              vr_nmarquiv := 'PGT_' || TRIM(to_char(rw_crapdpt.nrdconta,'00000000'))  || '_' ||
                                       TRIM(to_char(vr_nrremret,'000000000')) || '.RET';

              -- Criar Lote de Informa��es de Retorno (craphpt)
              BEGIN
                 INSERT INTO craphpt
                     (cdcooper,
                      nrdconta,
                      nrconven,
                      intipmvt,
                      nrremret,
                      dtmvtolt,
                      nmarquiv,
                      idorigem,
                      dtdgerac,
                      hrdgerac,
                      insithpt,
                      cdoperad)
                   VALUES
                     (rw_crapdpt.cdcooper,
                      rw_crapdpt.nrdconta,
                      rw_crapdpt.nrconven,
                      2, -- Retorno
                      vr_nrremret,
                      pr_dtmvtolt,
                      vr_nmarquiv,
                      pr_idorigem,
                      vr_dtmvtolt,
                      to_char(SYSDATE,'HH24MISS'),
                      2, -- Processado
                      pr_cdoperad);

              IF SQL%ROWCOUNT = 0 THEN
                 RAISE vr_exc_critico;
              END IF;

              EXCEPTION
                 WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao inserir CRAPHPT: '||SQLERRM;
                    GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                         ,pr_cdagenci => 90
                                         ,pr_nrdcaixa => 900
                                         ,pr_nrsequen => 1 --> Fixo
                                         ,pr_cdcritic => 0 --> Critica 0 para n�o buscar do cadastro
                                         ,pr_dscritic => vr_dscritic
                                         ,pr_tab_erro => vr_tab_erro);
                    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                               pr_nmarqlog     => NULL,
                                               pr_ind_tipo_log => 2, -- Erro tratato
                                               pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                                  ' - PGTA0001.pc_gera_retorno_tit_pago --> '
                                                                  || vr_dscritic);
                    RAISE vr_exc_critico;
              END;
           END IF;

           vr_nrseqarq := nvl(vr_nrseqarq,0) + 1;

           IF rw_crapdpt.insitlau = 2 THEN -- PAGO
              vr_cdtipmvt := 7; -- LIQUIDADO
              vr_cdinsmvt := 0;
              vr_cdocorre := '00';
           ELSIF rw_crapdpt.insitlau = 3 THEN  -- CANCELADO
              vr_cdtipmvt := 3; -- ESTORNO
              vr_cdinsmvt := 33;
              vr_cdocorre := '02';              
           ELSIF rw_crapdpt.insitlau = 4  THEN -- SALDO INFERIOR
              vr_cdtipmvt := 3; -- ESTORNO
              vr_cdinsmvt := 33;
              vr_cdocorre := '01';
           END IF;

           -- Insere dados na tabela crapdpt
           BEGIN
              INSERT INTO crapdpt
                 (cdcooper,
                 nrdconta,
                 nrconven,
                 intipmvt,
                 nrremret,
                 nrseqarq,
                 cdtipmvt,
                 cdinsmvt,
                 dscodbar,
                 nmcedent,
                 dtvencto,
                 vltitulo,
                 vldescto,
                 vlacresc,
                 dtdpagto,
                 vldpagto,
                 dsusoemp,
                 dsnosnum,
                 cdocorre,
                 dtmvtopg,
                 intipreg)
              VALUES
                (rw_crapdpt.cdcooper,
                 rw_crapdpt.nrdconta,
                 rw_crapdpt.nrconven,
                 2, -- Retorno
                 vr_nrremret,
                 vr_nrseqarq,
                 vr_cdtipmvt,
                 vr_cdinsmvt,
                 rw_crapdpt.dscodbar,
                 rw_crapdpt.nmcedent,
                 rw_crapdpt.dtvencto,
                 rw_crapdpt.vltitulo,
                 rw_crapdpt.vldescto,
                 rw_crapdpt.vlacresc,
                 rw_crapdpt.dtdpagto,
                 rw_crapdpt.vldpagto,
                 rw_crapdpt.dsusoemp,
                 rw_crapdpt.dsnosnum,
                 vr_cdocorre,
                 rw_crapdpt.dtmvtopg,
                 rw_crapdpt.intipreg);

           IF SQL%ROWCOUNT = 0 THEN
               RAISE vr_exc_critico;
           END IF;

           EXCEPTION
              WHEN OTHERS THEN
                 vr_cdcritic := 0;
                 vr_dscritic := 'Erro ao inserir CRAPDPT: '||SQLERRM;
                 GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => 90
                                      ,pr_nrdcaixa => 900
                                      ,pr_nrsequen => 2 --> Fixo
                                      ,pr_cdcritic => 0 --> Critica 0 para n�o buscar do cadastro
                                      ,pr_dscritic => vr_dscritic
                                      ,pr_tab_erro => vr_tab_erro);
                 btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                            pr_nmarqlog     => NULL,
                                            pr_ind_tipo_log => 2, -- Erro tratato
                                            pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                               ' - PGTA0001.pc_gera_retorno_tit_pago --> '
                                                               || vr_dscritic);
                 RAISE vr_exc_critico;
           END;

        END LOOP;

        -- Salva Altera��es Efetuadas
        --COMMIT; -- Controlado pelo CRPS509

  EXCEPTION
     WHEN vr_exc_critico THEN
        -- Atualiza campo de erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic  || SQLERRM;
        ROLLBACK; -- Controlado pelo CRPS509
     WHEN OTHERS THEN
        -- Atualiza campo de erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic  || SQLERRM;
        ROLLBACK; -- Controlado pelo CRPS509

  END pc_gera_retorno_tit_pago;



  PROCEDURE pc_gerar_arq_log_pgto(pr_cdcooper  IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                 ,pr_nmarquiv  IN VARCHAR2               -- Nome do Arquivo
                                 ,pr_descerro  IN VARCHAR2               -- Descri��o do Erro
                                 ,pr_cdcritic OUT INTEGER                -- C�digo do erro
                                 ,pr_dscritic OUT VARCHAR2) IS           -- Descricao do erro

    BEGIN

    DECLARE

      -- Nome do Arquivo
      vr_nmarquiv  VARCHAR2(100);

      vr_setlinha VARCHAR2(400);

      vr_utlfileh VARCHAR2(4000);

      -- Declarando Handle do Arquivo
      vr_ind_arquivo utl_file.file_type;
      vr_exc_saida  EXCEPTION;
      vr_exc_erro   EXCEPTION;

    BEGIN

      --Inicializar variaveis retorno
      pr_cdcritic:= 0;
      pr_dscritic:= NULL;

      -- Define nome do arquivo .LOG com base nome do Arquivo de Remessa
      vr_nmarquiv := REPLACE(UPPER(pr_nmarquiv),'.REM','.LOG');

      -- Define o diret�rio do arquivo
      vr_utlfileh := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/arq') ;

      -- Abre arquivo em modo de Escrita (W)
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh         --> Diret�rio do arquivo
                              ,pr_nmarquiv => vr_nmarquiv         --> Nome do arquivo
                              ,pr_tipabert => 'W'                 --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arquivo      --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);       --> Erro


      IF vr_dscritic IS NOT NULL THEN
        -- Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      -- Linha do Erro Apresentado
      vr_setlinha:= to_char(SYSDATE,'DD/MM/RRRR')     || ' - ' ||
                    to_char(SYSDATE,'HH24:MI:SS')     || ' - ' ||
                    TRIM(pr_descerro)                 || CHR(13);

      -- Escrever Erro Apresentado no Arquivo
      GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);

      -- Fechar o arquivo
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := 0;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro PGTA0001.pc_gerar_arq_log_pgto: ' || SQLERRM;
    END;

  END pc_gerar_arq_log_pgto;


  -- Procedure para gerar arquivo de retorno
  PROCEDURE pc_gerar_arq_ret_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                  ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                  ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                  ,pr_nrremret      IN craphpt.nrremret%TYPE  -- Numero Remessa/Retorno
                                  ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                  ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                  ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                  ,pr_nmarquiv     OUT VARCHAR2               -- Nome do Arquivo
                                  ,pr_dsarquiv     OUT CLOB                   -- Conteudo do Arquivo -> Apenas quando origem Internet Banking
                                  ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                  ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro

  BEGIN

  DECLARE

    -- CURSORES

    -- Busca do diret�rio conforme a cooperativa conectada
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapcop.cdcooper
            ,crapcop.dsdircop
            ,crapcop.cdagectl
            ,crapcop.nmrescop
            ,crapcop.nmextcop
      FROM crapcop crapcop
      WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    --Selecionar os dados da tabela de Associados
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta
            ,crapass.cdagenci
            ,crapass.nrcpfcgc
            ,crapass.inpessoa
            ,crapass.nmprimtl
      FROM crapass crapass
      WHERE crapass.cdcooper = pr_cdcooper
      AND   crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Selecionar os Detalhamentos dos Cheques
    CURSOR cr_crapdpt(pr_cdcooper IN crapdpt.cdcooper%TYPE
                     ,pr_nrdconta IN crapdpt.nrdconta%TYPE
                     ,pr_nrconven IN crapdpt.nrconven%TYPE
                     ,pr_nrremret IN crapdpt.nrremret%TYPE) IS
      SELECT dpt.cdcooper
            ,dpt.nrdconta
            ,dpt.nrconven
            ,dpt.intipmvt
            ,dpt.nrremret
            ,dpt.nrseqarq
            ,dpt.cdtipmvt
            ,dpt.cdinsmvt
            ,dpt.dscodbar
            ,dpt.nmcedent
            ,dpt.dtvencto
            ,dpt.vltitulo
            ,dpt.vldescto
            ,dpt.vlacresc
            ,dpt.dtdpagto
            ,dpt.vldpagto
            ,dpt.dsusoemp
            ,dpt.dsnosnum
            ,dpt.cdocorre
            ,dpt.dtmvtopg
            ,dpt.intipreg
            ,pro.nrseqaut
            ,pro.nrdocmto
            ,pro.dsprotoc
            ,pro.dtmvtolt
            ,pro.hrautent
        FROM crapdpt dpt
        LEFT JOIN craptit tit
          ON tit.cdcooper = dpt.cdcooper
         AND UPPER(tit.dscodbar) = UPPER(dpt.dscodbar)
         AND tit.dtmvtolt = dpt.dtdpagto
        LEFT JOIN crapaut aut
          ON aut.cdcooper = dpt.cdcooper
         AND aut.dtmvtolt = dpt.dtdpagto
         AND aut.cdagenci = tit.cdagenci
         AND aut.nrdcaixa = tit.nrdolote - 16000
         AND aut.nrsequen = tit.nrautdoc
        LEFT JOIN crappro pro
          ON pro.cdcooper = aut.cdcooper
         AND UPPER(pro.dsprotoc) = UPPER(aut.dsprotoc)
       WHERE dpt.cdcooper = pr_cdcooper
         AND dpt.nrdconta = pr_nrdconta
         AND dpt.nrconven = pr_nrconven
         AND dpt.nrremret = pr_nrremret
         AND dpt.intipmvt = 2;
    rw_crapdpt cr_crapdpt%ROWTYPE;

    -- Verificar qual Tipo de Retorno o Cooperado Possui
    CURSOR cr_crapcpt (pr_cdcooper IN crapcpt.cdcooper%TYPE
                      ,pr_nrdconta IN crapcpt.nrdconta%TYPE
                      ,pr_nrconven IN crapcpt.nrconven%TYPE) IS
      SELECT crapcpt.idretorn
      FROM crapcpt crapcpt
      WHERE crapcpt.cdcooper = pr_cdcooper AND
            crapcpt.nrdconta = pr_nrdconta AND
            crapcpt.nrconven = pr_nrconven;
    rw_crapcpt cr_crapcpt%ROWTYPE;

    -- Nome do Arquivo
    vr_nmarquiv  VARCHAR2(100);

    vr_utlfileh VARCHAR2(4000);

    -- Declarando handle do Arquivo
    vr_ind_arquivo utl_file.file_type;

    vr_exc_saida   EXCEPTION;
    vr_exc_erro    EXCEPTION;
    vr_erro_update EXCEPTION;
    vr_exc_critico EXCEPTION;

    vr_setlinha VARCHAR2(400);
    vr_arq_tmp  VARCHAR2(32767);

    -- Agencia Mantedora
    vr_cdageman NUMBER;

    -- Hora Gera��o
    vr_horagera VARCHAR2(100);

    -- Variaveis Acumuladoras
    vr_qtd_registro  NUMBER :=0 ;
    vr_vlr_tot_pgto  NUMBER :=0 ;
    vr_qtd_reg_lote  NUMBER :=0 ;

    vr_nr_sequencial NUMBER := 0;

    vr_aux_cdocorre VARCHAR2(2);

    vr_nrdrowid ROWID;

    vr_dsorigem VARCHAR2(10);

  BEGIN
    --Inicializar variaveis retorno
    pr_cdcritic:= 0;
    pr_dscritic:= NULL;

    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de cooperativa nao encontrado.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;

    -- Montando nome arquivo retorno.
    vr_nmarquiv := 'PGT_' || TRIM(to_char(pr_nrdconta,'00000000'))  || '_'
                          || TRIM(to_char(pr_nrremret,'000000000')) || '.RET';

    -- Define o diret�rio do arquivo
    vr_utlfileh := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/arq') ;

    -- Abre arquivo em modo de escrita (W)
    GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh         --> Diret�rio do arquivo
                            ,pr_nmarquiv => vr_nmarquiv         --> Nome do arquivo
                            ,pr_tipabert => 'W'                 --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_ind_arquivo      --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);       --> Erro


    IF vr_dscritic IS NOT NULL THEN
      -- Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    -- Localizar Cooperado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    --Fechar Cursor
    CLOSE cr_crapass;

    -- Agencia Mantenedora
    vr_cdageman:= to_number(GENE0002.fn_mask(rw_crapcop.cdagectl,'9999')||'0');

    --Hora geracao
    vr_horagera:= to_char(SYSDATE,'HH24MISS');

    -- Quantidade de Registros Lote
    vr_qtd_registro := 0;

    -- Valor Total Pagamentos
    vr_vlr_tot_pgto  := 0;

    ------------- HEADER DO ARQUIVO -------------
    vr_qtd_registro := vr_qtd_registro + 1;

    vr_setlinha:= '085'                                                     || -- 01.0 - Banco
                  '0000'                                                    || -- 02.0 - Lote
                  '0'                                                       || -- 03.0 - Tipo Registro
                  LPAD(' ',9,' ')                                           || -- 04.0 - Brancos
                  rw_crapass.inpessoa                                       || -- 05.0 - Tp Inscricao
                  GENE0002.fn_mask(rw_crapass.nrcpfcgc,'99999999999999')    || -- 06.0 - CNPJ/CPF
                  GENE0002.fn_mask(pr_nrconven,'99999999999999999999')      || -- 07.0 - Convenio
                  GENE0002.fn_mask(vr_cdageman,'999999')                    || -- 08.0 - Age Mantenedora
                  GENE0002.fn_mask(rw_crapass.nrdconta,'9999999999999')     || -- 10.0 - Conta/Digito
                  LPAD(' ',1,' ')                                           || -- 12.0 - Dig Verf Age/Cta
                  substr(rpad(rw_crapass.nmprimtl,30,' '),1,30)             || -- 13.0 - Nome Empresa
                  substr(rpad(rw_crapcop.nmextcop,30,' '),1,30)             || -- 14.0 - Nome Banco
                  LPAD(' ',10,' ')                                          || -- 15.0 - Brancos
                  '2'                                                       || -- 16.0 - C�digo Remessa/Retorno
                  to_char(SYSDATE,'DDMMYYYY')                               || -- 17.0 - Data de Gera��o do Arquivo
                  GENE0002.fn_mask(vr_horagera,'999999')                    || -- 18.0 - Hora de Gera��o do Arquivo
                  GENE0002.fn_mask(pr_nrremret,'999999')                    || -- 19.0 - Numero Sequencial do Arquivo
                  '088'                                                     || -- 20.0 - Layout do Arquivo
                  '00000'                                                   || -- 21.0 - Densidade de Grava��o do Arquivo
                  LPAD(' ',20,' ')                                          || -- 22.0 - Uso Reservado do Banco
                  LPAD(' ',20,' ')                                          || -- 23.0 - Uso Reservado da Empresa
                  LPAD(' ',29,' ')                                          || -- 24.0 - Uso Exclusivo FEBRABAN
                  CHR(13);

    -- Escrever Linha do Header do Arquivo CNAB240 - Item 1.0
    GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);

    ------------- HEADER DO LOTE -------------
    vr_qtd_registro := vr_qtd_registro + 1;

    vr_setlinha:= '085'                                                    || -- 01.1 - Banco
                  '0001'                                                   || -- 02.1 - Lote
                  '1'                                                      || -- 03.1 - Tipo Registro
                  'C'                                                      || -- 04.1 - Tipo de Opera��o
                  '98'                                                     || -- 05.1 - Tipo de Servi�o
                  '11'                                                     || -- 06.1 - Forma de Lan�amento '11' = Pagamento de Contas e Tributos com C�digo de Barras
                  '040'                                                    || -- 07.1 - Layout do Arquivo
                  LPAD(' ',1,' ')                                          || -- 08.1 - Uso Exclusivo FEBRABAN
                  rw_crapass.inpessoa                                      || -- 09.1 - Tipo de Inscricao Empresa
                  GENE0002.fn_mask(rw_crapass.nrcpfcgc,'99999999999999')   || -- 10.1 - CNPJ/CPF da Empresa
                  GENE0002.fn_mask(pr_nrconven,'99999999999999999999')     || -- 11.1 - Convenio
                  GENE0002.fn_mask(vr_cdageman,'999999')                   || -- 12.1 - Agencia Mantenedora da Conta + Digito
                  GENE0002.fn_mask(rw_crapass.nrdconta,'9999999999999')    || -- 14.1 - Conta/Digito
                  LPAD(' ',1,' ')                                          || -- 16.1 - Digito Verfificador Ag/Conta
                  substr(rpad(rw_crapass.nmprimtl,30,' '),1,30)            || -- 17.1 - Nome da Empresa
                  LPAD(' ',40,' ')                                         || -- 18.1 - Mensagem
                  LPAD(' ',80,' ')                                         || -- 19.1 - Endere�o da Empresa
                  LPAD(' ',08,' ')                                         || -- 26.1 - Uso Exclusivo FEBRABAN
                  LPAD(' ',10,' ')                                         || -- 27.1 - Ocorrencias p/ Retorno
                  CHR(13);

    -- Escreve Linha do header do Lote CNAB240 - Item 1.1
    GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);

    ------------- SEGMENTO J -------------
    FOR rw_crapdpt IN cr_crapdpt(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrconven => pr_nrconven
                                ,pr_nrremret => pr_nrremret) LOOP

      vr_nr_sequencial := vr_nr_sequencial + 1;

      IF TRIM(rw_crapdpt.cdocorre) IS NULL THEN
        vr_aux_cdocorre := LPAD(' ',02,' ');
      ELSE
        vr_aux_cdocorre := LPAD(rw_crapdpt.cdocorre,02,' ');
      END IF;

      vr_setlinha:=
          '085'                                                                || -- 01.3J - Banco
          '0001'                                                               || -- 02.3J - Lote
          '3'                                                                  || -- 03.3J - Tipo Registro
          GENE0002.fn_mask(vr_nr_sequencial,'99999')                           || -- 04.3J - Nro. Sequencial Reg. no Lote
          'J'                                                                  || -- 05.3J - Codigo Segmento Detalhe
          GENE0002.fn_mask(rw_crapdpt.cdtipmvt,'9')                            || -- 06.3J - Tipo de Movimento
          GENE0002.fn_mask(rw_crapdpt.cdinsmvt,'99')                           || -- 07.3J - C�digo da Instru��o p/ Movimento
          LPAD(rw_crapdpt.dscodbar,44,'0')                                     || -- 08.3J - Codigo de Barra
          RPAD(rw_crapdpt.nmcedent,30,' ')                                     || -- 09.3J - Nome do Cedente
          NVL(to_char(rw_crapdpt.dtvencto,'DDMMRRRR'),to_char(trunc(SYSDATE),'DDMMRRRR')) || -- 10.3J - Data de Vencimento (Nominal)
          GENE0002.fn_mask(NVL(rw_crapdpt.vltitulo,0) * 100,'999999999999999') || -- 11.3J - Valor do Titulo (Nominal)
          GENE0002.fn_mask(NVL(rw_crapdpt.vldescto,0) * 100,'999999999999999') || -- 12.3J - Valor do Desconto + Abatimento
          GENE0002.fn_mask(NVL(rw_crapdpt.vlacresc,0) * 100,'999999999999999') || -- 13.3J - Valor da Mora + Multa
          NVL(to_char(rw_crapdpt.dtdpagto,'DDMMRRRR'),to_char(trunc(SYSDATE),'DDMMRRRR')) || -- 14.3J - Data do Pagamento
          GENE0002.fn_mask(NVL(rw_crapdpt.vldpagto,0) * 100,'999999999999999') || -- 15.3J - Valor do Pagamento
          LPAD('0',15,'0')                                                     || -- 16.3J - Quantidade da Moeda
          RPAD(rw_crapdpt.dsusoemp,20,' ')                                     || -- 17.3J - Numero Atribuido pelo Cliente
          RPAD(rw_crapdpt.dsnosnum,20,' ')                                     || -- 18.3J - Nosso Numero - Uso Exclusivo do Banco
          '09'                                                                 || -- 19.3J - C�digo da Moeda
          LPAD(' ',06,' ')                                                     || -- 20.3J - Uso exclusivo FEBRABAN
          NVL(vr_aux_cdocorre,'00') || LPAD(' ',08,' ')                        || -- 21.3J - Codigo das Ocorrencias
          CHR(13);

      -- Escreve Linha do Trailer de Lote CNAB240 - Item 1.5
      GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);

      -- Quantidade de Registros (Usado no Trailer do Arquivo)
      vr_qtd_registro := vr_qtd_registro + 1;

      -- Quantidade de Registros (Usado no Trailer do Lote)
      vr_qtd_reg_lote := vr_qtd_reg_lote + 1;

      -- Valor  - Somatoria dos Valores
      vr_vlr_tot_pgto := vr_vlr_tot_pgto + NVL(rw_crapdpt.vldpagto,0);

      ------------- SEGMENTO J99 -------------
      IF rw_crapdpt.cdtipmvt = 7 THEN
        
        vr_nr_sequencial := vr_nr_sequencial + 1;
        
        vr_setlinha:=
          '085'                                                                                                          || -- 01.4J99 - Banco
          '0001'                                                                                                         || -- 02.4J99 - Lote
          '3'                                                                                                            || -- 03.4J99 - Tipo Registro
          GENE0002.fn_mask(vr_nr_sequencial,'99999')                                                                     || -- 04.4J99 - Nro. Sequencial Reg. no Lote
          'J'                                                                                                            || -- 05.4J99 - Codigo Segmento Detalhe
 	        GENE0002.fn_mask(rw_crapdpt.cdtipmvt,'9')                                                                      || -- 06.4J99 - Tipo de Movimento
          GENE0002.fn_mask(rw_crapdpt.cdinsmvt,'99')                                                                     || -- 07.4J99 - C�digo da Instru��o p/ Movimento          
          '99'                                                                                                           || -- 08.4J99 - Codigo de Barra
          GENE0002.fn_mask(rw_crapdpt.nrseqaut,'9999999999')                                                             || -- 09.4J99 - C�digo de Autentica��o
          GENE0002.fn_mask(rw_crapdpt.nrdocmto,'9999999999999999999999999')                                              || -- 10.4J99 - N�mero do Documento
          NVL(to_char(rw_crapdpt.dtmvtolt,'DDMMRRRR'),to_char(trunc(SYSDATE),'DDMMRRRR'))                                || -- 11.4J99 - Data do Pagamento
          GENE0002.fn_mask(rw_crapdpt.hrautent,'999999')                                                                 || -- 12.4J99 - Hora do Pagamento
          RPAD(rw_crapdpt.dsprotoc,70,' ')                                                                                 || -- 12.4J99 - Hora do Pagamento
          LPAD(' ',101,' ')                                                                                              || -- 13.4J99 - CNAB Uso Exclusivo Cecred
          CHR(13);  
          
          -- Escreve Linha do Trailer de Lote CNAB240 - Item 1.5
          GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);
          
          -- Quantidade de Registros (Usado no Trailer do Arquivo)
          vr_qtd_registro := vr_qtd_registro + 1;

          -- Quantidade de Registros (Usado no Trailer do Lote)
          vr_qtd_reg_lote := vr_qtd_reg_lote + 1;
          
      END IF;

    END LOOP;

    ------------- TRAILER DO LOTE -------------
    vr_qtd_registro := vr_qtd_registro + 1;

    vr_setlinha:= '085'                                                        || -- 01.5 - Banco
                  '0001'                                                       || -- 02.5 - Lote de Servi�o
                  '5'                                                          || -- 03.5 - Registro Trailer de Lote
                  LPAD(' ',9,' ')                                              || -- 04.5 - Uso Exclusivo FEBRABAN
                  GENE0002.fn_mask(vr_qtd_reg_lote,'999999')                   || -- 05.5 - Qtd Registros do Lote
                  GENE0002.fn_mask(vr_vlr_tot_pgto * 100,'999999999999999999') || -- 06.5 - Somatoria dos Valores
                  '000000000000000000'                                         || -- 07.5 - Somatoria Quantidade Moeda
                  LPAD('0',06,'0')                                             || -- 08.5 - Numero Aviso de Debito
                  LPAD(' ',165,' ')                                            || -- 09.5 - Uso Exclusivo FEBRABAN
                  LPAD(' ',10,' ')                                             || -- 10.5 - Ocorrencias Lote
                  CHR(13);

    -- Escreve Linha do Trailer de Lote CNAB240 - Item 1.5
    GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);


    ------------- TRAILER DO ARQUIVO -------------
    vr_qtd_registro := vr_qtd_registro + 1;

    vr_setlinha:= '085'                                      || -- 01.9 - Banco
                  '9999'                                     || -- 02.9 - Lote de Servi�o
                  '9'                                        || -- 03.9 - Tipo Registro
                  LPAD(' ',9,' ')                            || -- 04.9 - Uso Exclusivo FEBRABAN
                  '000001'                                   || -- 05.9 - Qtd de Lotes do Arquivo
                  GENE0002.fn_mask(vr_qtd_registro,'999999') || -- 06.9 - Qtd Registros do Arquivo
                  '000001'                                   || -- 07.9 - Qtd Contas p/ Conciliar
                  LPAD(' ',205,' ')                          || -- 08.9 - Uso Exclusivo FEBRABAN
                  CHR(13);

    -- Escreve Linha do Trailer de Arquivo CNAB240 - Item 1.9
    GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);


    -- Fechar o arquivo
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

    -- Verificar qual Tipo de Retorno o Cooperado Possui
    OPEN cr_crapcpt(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrconven => pr_nrconven);
    FETCH cr_crapcpt INTO rw_crapcpt;
    --Se nao encontrou
    IF cr_crapcpt%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcpt;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Cooperado sem Tipo de Retorno Cadastrado.';

      -- Registrar Log;
      PGTA0001.pc_logar_cst_arq_pgto(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nmarquiv => vr_nmarquiv
                                   ,pr_textolog => 'Cooperado sem Tipo de Retorno Cadastrado'
                                   ,pr_cdcritic => pr_cdcritic
                                   ,pr_dscritic => pr_dscritic);

      --Levantar Excecao
      RAISE vr_exc_critico;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcpt;




    --------- SE FOR ORIGEM INTERNET BANKING, ABRE O ARQUIVO, GRAVA NO CLOB E DEVOLVE NO OUT.
    IF pr_idorigem = 3 THEN     -- INTERNET
      -- Define o diret�rio do arquivo
      vr_utlfileh := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/arq') ;

      -- Abre arquivo em modo de leitura (R)
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh         --> Diret�rio do arquivo
                              ,pr_nmarquiv => vr_nmarquiv         --> Nome do arquivo
                              ,pr_tipabert => 'R'                 --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arquivo      --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);       --> Erro
      IF vr_dscritic IS NOT NULL THEN
        -- Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      -- Inicializar o CLOB
      dbms_lob.createtemporary(pr_dsarquiv, true);
      dbms_lob.open(pr_dsarquiv, dbms_lob.lob_readwrite);

      gene0002.pc_escreve_xml(pr_xml            => pr_dsarquiv
                             ,pr_texto_completo => vr_arq_tmp
                             ,pr_texto_novo     => '<retorno><arquivo>' || vr_nmarquiv || '</arquivo>');

      --Percorrer cada linha do arquivo
      LOOP
        BEGIN
          -- Verifica se o arquivo est� aberto
          IF  utl_file.IS_OPEN(vr_ind_arquivo) THEN
            -- Le os dados em peda�os e escreve no Clob
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquivo --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido

            gene0002.pc_escreve_xml(pr_xml            => pr_dsarquiv
                                   ,pr_texto_completo => vr_arq_tmp
                                   ,pr_texto_novo     => '<linha>' || vr_setlinha || '</linha>');
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN -- Quando chegar na ultima linha do arquivo
             EXIT;
        END;

      END LOOP;

      -- Fechar o arquivo
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

      gene0002.pc_escreve_xml(pr_xml            => pr_dsarquiv
                             ,pr_texto_completo => vr_arq_tmp
                             ,pr_texto_novo     => '</retorno>'
                             ,pr_fecha_xml      => TRUE);


    END IF;

    -- Registrar Log;
    PGTA0001.pc_logar_cst_arq_pgto(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nmarquiv => vr_nmarquiv
                                 ,pr_textolog => 'Arquivo de Retorno Gerado com Sucesso'
                                 ,pr_cdcritic => pr_cdcritic
                                 ,pr_dscritic => pr_dscritic);


    -- Verifica Qual a Origem
    CASE pr_idorigem
      WHEN 1 THEN vr_dsorigem := 'AYLLOS';
      WHEN 3 THEN vr_dsorigem := 'INTERNET';
      WHEN 3 THEN vr_dsorigem := 'FTP';
      ELSE vr_dsorigem := ' ';
    END CASE;

    -- Gerar registro de log (craplgm)
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => 'Gerado arquivo de retorno de pagamento por arquivo: ' || vr_nmarquiv
                        ,pr_dttransa => pr_dtmvtolt
                        ,pr_flgtrans => 0 -- TRUE
                        ,pr_hrtransa => to_number(to_char(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => ' '
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

      -- Retorna nome do Arquivo
      pr_nmarquiv := vr_nmarquiv;

      -- Efetua a Atualizacao do Registro do Arquivo para Processado
      BEGIN
        UPDATE craphpt
           SET insithpt = 2 -- Processado
       WHERE craphpt.cdcooper = pr_cdcooper
         AND craphpt.nrdconta = pr_nrdconta
         AND craphpt.nrconven = pr_nrconven
         AND craphpt.intipmvt = 2 -- Retorno
         AND craphpt.nrremret = pr_nrremret;

       IF SQL%ROWCOUNT = 0 THEN
         RAISE vr_erro_update;
       END IF;

      EXCEPTION
        WHEN vr_erro_update THEN
          -- Atualiza campo de erro
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar dados na CRAPHPT: ' || SQLERRM;
          RAISE vr_exc_critico;
        WHEN OTHERS THEN
          -- Atualiza campo de erro
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar dados na CRAPHPT: ' || SQLERRM;
          RAISE vr_exc_critico;
      END;

      -- Salva Altera��es
      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Atualiza campo de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN vr_exc_critico THEN
        -- Atualiza campo de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        -- Atualiza campo de erro
        pr_cdcritic := 0;
        pr_dscritic := 'Erro pc_gerar_arq_ret_pgto: ' || SQLERRM;
        ROLLBACK;
    END;

   END pc_gerar_arq_ret_pgto;



   PROCEDURE pc_logar_cst_arq_pgto(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                  ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                  ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                  ,pr_textolog      IN VARCHAR2               -- Texto a ser Incluso Log
                                  ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                  ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro

    BEGIN

    DECLARE

      -- Variaveis Log
      vr_nmarqlog   VARCHAR2(100);

      vr_nmdirlog   VARCHAR2(4000);
      vr_input_file utl_file.file_type;
      vr_datdodia   DATE;

      -- Descri��o do Erro
      vr_des_erro VARCHAR2(4000);

      vr_exc_erro EXCEPTION;

      vr_setlinha VARCHAR2(4000);

      BEGIN

        -- Nome do Arquivo de Log
        vr_nmarqlog := 'pgto_por_arquivo.log';

        --Buscar diretorio padrao cooperativa
        vr_nmdirlog := GENE0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/log') || '/' ; --> Ir para diretorio log

        --Abrir arquivo modo append
        GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirlog    --> Diretorio do arquivo
                                ,pr_nmarquiv => vr_nmarqlog    --> Nome do arquivo
                                ,pr_tipabert => 'A'            --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                ,pr_des_erro => vr_des_erro);  --> Erro

        IF vr_des_erro IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        --Buscar data do dia
        vr_datdodia:= PAGA0001.fn_busca_datdodia (pr_cdcooper => pr_cdcooper);

        -- Montar linha que sera gravada no log
        -- <data/hora> <conta> <arquivo> - Arquivo de Retorno Gerado com Sucesso
        vr_setlinha:= to_char(vr_datdodia,'DD/MM/YYYY')       || ' '||
                      to_char(SYSDATE,'HH24:MI:SS')           || ' --> '||
                      GENE0002.fn_mask_conta(pr_nrdconta)     || ' | ';
        IF TRIM(pr_nmarquiv) IS NOT NULL THEN
          vr_setlinha:= vr_setlinha || pr_nmarquiv            || ' | ';
        END IF;
          vr_setlinha:= vr_setlinha || pr_textolog;

        --Escrever linha log
        GENE0001.pc_escr_linha_arquivo(vr_input_file,vr_setlinha);

        -- Fechar Arquivo
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Retorna Erro
          pr_cdcritic := 0;
          pr_dscritic := vr_des_erro;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro na Rotina PGTA0001.pc_logar_cst_arq_pgto. Erro: ' || SQLERRM;
      END;

    END pc_logar_cst_arq_pgto;

    -- Procedure de retorno de titulos agendados
    PROCEDURE pc_retorna_titulo_agendado(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- C�digo da cooperativa
                                        ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                        ,pr_nrconven      IN craphpt.nrconven%TYPE  -- Numero do Convenio
--                                        ,pr_nrremret      INT craphpt.nrremret%TYPE -- Numero da remessa retorno
                                        ,pr_dtinicon      IN DATE                   -- Data Inicial
                                        ,pr_dtfincon      IN DATE                   -- Data Final
                                        ,pr_tab_titulo     OUT CLOB                   -- XML da tabela de titulos
                                        ,pr_cdcritic     OUT INTEGER                -- C�digo do erro
                                        ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : PGTA0001
    --  Sistema  : Rotinas genericas focando nas funcionalidades do pagamento por arquivo
    --  Sigla    : PGTA
    --  Autor    : Andre Santos - SUPERO
    --  Data     : Setembro/2014.                   Ultima atualizacao:  /  /
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que Chamado
    -- Objetivo  : Retorna tabela de titulos agendados.

    -- Alteracoes:
    ---------------------------------------------------------------------------------------------------------------

    -- CURSORES

    CURSOR cr_ret_titulo(p_cdcooper IN craphpt.cdcooper%TYPE
                        ,p_nrdconta IN craphpt.nrdconta%TYPE
                        ,p_nrconven IN craphpt.nrconven%TYPE
                        ,p_nrremret IN craphpt.nrremret%TYPE
                        ,p_dtinicon IN DATE
                        ,p_dtfimcon IN DATE) IS
      SELECT hpt.dtmvtolt
            ,hpt.nmarquiv
            ,hpt.nrremret
            ,ROWID
        FROM craphpt hpt
       WHERE hpt.cdcooper = p_cdcooper
         AND hpt.nrdconta = p_nrdconta
         AND hpt.nrconven = p_nrconven
         AND hpt.intipmvt = 2 -- 1-REMESSA/2-RETORNO
--         AND hpt.nrremret = p_nrremret
         AND hpt.dtmvtolt BETWEEN p_dtinicon AND p_dtfimcon;

    -- Variaveis
    vr_tab_titulos PGTA0001.typ_tab_titulos;
    vr_id_titulos  PLS_INTEGER;
    vr_xml_tab_temp VARCHAR2(32726)    := '';

    -- Variaveis de Exception
    vr_exc_erro EXCEPTION;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);

    BEGIN
       -- Inicia variavel
       vr_id_titulos := 0;
       vr_cdcritic   := 0;
       vr_dscritic   := NULL;
       -- Busca todos os titulos marcados como RETORNO
       FOR rw_titulos IN cr_ret_titulo(pr_cdcooper
                                      ,pr_nrdconta
                                      ,pr_nrconven
                                      ,1 --pr_nrremret
                                      ,pr_dtinicon
                                      ,pr_dtfincon) LOOP
          -- Cria chave da tabela temporaria
          vr_id_titulos := vr_tab_titulos.COUNT()+1;
          -- Cria o registro de titulos
          vr_tab_titulos(vr_id_titulos).dtmvtolt := rw_titulos.dtmvtolt;
          vr_tab_titulos(vr_id_titulos).nmarquiv := rw_titulos.nmarquiv;
          vr_tab_titulos(vr_id_titulos).nrremret := rw_titulos.nrremret;
          vr_tab_titulos(vr_id_titulos).idarquiv := rw_titulos.rowid;
       END LOOP;
       -- Se n�o encontrou registro, gera critica
       IF vr_tab_titulos.COUNT() = 0 THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Nenhum titulo encontrado!';
          RAISE vr_exc_erro;
       END IF;
       -- Inicia a montagem do XML
       BEGIN
          -- Monta documento XML do Perfil Informado.
          dbms_lob.createtemporary(pr_tab_titulo, TRUE);
          dbms_lob.open(pr_tab_titulo, dbms_lob.lob_readwrite);
          -- Insere o cabe�alho do XML
          gene0002.pc_escreve_xml(pr_xml            => pr_tab_titulo
                                 ,pr_texto_completo => vr_xml_tab_temp
                                 ,pr_texto_novo     => '<raiz>');
          -- Leitura da tabela de memoria
          vr_id_titulos := vr_tab_titulos.FIRST();
          WHILE vr_id_titulos IS NOT NULL LOOP
             gene0002.pc_escreve_xml(pr_xml            => pr_tab_titulo
                                    ,pr_texto_completo => vr_xml_tab_temp
                                    ,pr_texto_novo     => '<arquivo>'
                                    || '<dtmvtolt>'||TO_CHAR(vr_tab_titulos(vr_id_titulos).dtmvtolt,'DD/MM/RRRR') ||'</dtmvtolt>'
                                    || '<nmarquiv>'||NVL(vr_tab_titulos(vr_id_titulos).nmarquiv,' ') ||'</nmarquiv>'
                                    || '<nrremret>'||TO_CHAR(vr_tab_titulos(vr_id_titulos).nrremret) ||'</nrremret>'
                                    || '<idarquiv>'||TO_CHAR(vr_tab_titulos(vr_id_titulos).idarquiv) ||'</idarquiv>'
                                    || '</arquivo>');
             vr_id_titulos:= vr_tab_titulos.NEXT(vr_id_titulos); -- Proximo registro
          END LOOP;
          -- Encerrar a tag raiz
          gene0002.pc_escreve_xml(pr_xml            => pr_tab_titulo
                                 ,pr_texto_completo => vr_xml_tab_temp
                                 ,pr_texto_novo     => '</raiz>'
                                 ,pr_fecha_xml      => TRUE);
       EXCEPTION
          WHEN OTHERS THEN
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao montar XML. Rotina PGTA0001.pc_retorna_titulo_agendado: '||SQLERRM;
             RAISE vr_exc_erro;
       END;

    EXCEPTION
        WHEN vr_exc_erro THEN
           pr_cdcritic := NVL(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro na Rotina PGTA0001.pc_retorna_titulo_agendado. Erro: ' || SQLERRM;
    END pc_retorna_titulo_agendado;

END PGTA0001;
/
