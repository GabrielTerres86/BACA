CREATE OR REPLACE PACKAGE CECRED.PGTA0001 IS

---------------------------------------------------------------------------------------------------------------
--
--  Programa : PGTA0001
--  Sistema  : Rotinas genericas focando nas funcionalidades de Pagamento de Titulos Lote
--  Sigla    : PGTA
--  Autor    : Daniel Zimmermann
--  Data     : Abril/2014.                   Ultima atualizacao:  15/12/2017
--
-- Dados referentes ao programa:
--
-- Frequencia: -----
-- Objetivo  : Agrupar rotinas genéricas dos sistemas Oracle

-- Alteracoes:
--              25/08/2014 - Continuacao do Projeto Upload, novas procedures e ajustes nas atuais
--                          (Guilherme/SUPERO)

--             19/01/2016 - Adicionado ao arquivo de retorno nova linha incluindo informações como,
--                         autenticação, documento, data, hora e protocolo (Kelvin).
--
--             20/06/2016 - Correcao para o uso da function fn_busca_dstextab da TABE0001 em 
--                          varias procedures desta package.(Carlos Rafael Tanholi). 
--
--             22/02/2017 - Ajustes para correçao de crítica de pagamento DARF/DAS (Lucas Lunelli - P.349.2)
--
--             21/03/2017 - Incluido DECODE para tratamento de inpessoa > 2 (Diego).
--
--             05/07/2017 - Ajuste nas procedures pc_rejeitar_arq_pgto e pc_gerar_arq_log_pgto
--                          para buscarem tambem arquivos com extensao .TXT gerados no sistema MATERA (Diego).
--
--             11/12/2017 - Ajuste na pc_gerar_arq_ret_pgto para que não escreva no arquivo o CHR(13)
--                          pois a procedure pc_escreve_linha ja adiciona a quebra de linha
--                        - Ajuste na validação de retorno quando deve ser enviado para o FTP
--                        - Ajuste para converter o arquivo de UNIX para WINDOWS
--                        (Douglas - Chamado 805535) 
--
--             15/12/2017 - Com a eliminação das descrições fixas na PAGA0001
--                          Ajuste da descrição fixa incluindo o codigo junto
--                          (Belli - Envolti - Chamado 779415)  
--
--             16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
--                     Heitor (Mouts)
-- 
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

    -- Tabela de memoria que ira conter os agendamentos feitos por arquivo
    TYPE typ_rec_agd_pgt_arq IS
        RECORD(nmarquiv craphpt.nmarquiv%TYPE -- Nome do arquivo de Remessa
              ,dhdgerac VARCHAR2(30)  -- Data/Hora da geração da Remessa
              ,nmcedent crapdpt.nmcedent%TYPE -- Nome do Cedente do boleto
              ,dtvencto VARCHAR2(15)  -- Data de Vencimento do Titulo
              ,dtdpagto VARCHAR2(15)  -- Data de Pagamento do Titulo
              ,vltitulo NUMBER(25,2)  -- Valor do Titulo
              ,vldpagto NUMBER(25,2)  -- Valor do Pago
              ,cdocorre VARCHAR2(2)   -- Codigo da Ocorrencia
              ,dsocorre VARCHAR2(100) -- Descrição da ocorrencia da Remessa
              ,dscodbar VARCHAR2(44)  -- Codigo de Barras
              ,dslindig VARCHAR2(55)  -- Linha Digitavel
              ,dssituac VARCHAR2(100) -- Descrição da Situação
              ,dsprotoc crappro.dsprotoc%TYPE -- Protocolo
              ,nrdocmto crappro.nrdocmto%TYPE -- Numero Documento
              ,nrseqaut crappro.nrseqaut%TYPE -- Sequencia Autenticação
              ,dsinfor1 crappro.dsinform##1%TYPE -- Informação ##1
              ,dsinfor2 crappro.dsinform##2%TYPE -- Informação ##2
              ,dsinfor3 crappro.dsinform##3%TYPE -- Informação ##3
              ,cdtippro crappro.cdtippro%TYPE -- Tipo de Protocolo
              ,nmprepos crappro.nmprepos%TYPE -- Nome do Preposto
              ,nrnivel_urp  INTEGER -- Nivel do ultimo registro de processado
              ,intipmvt_urp INTEGER -- Tipo de Movimento do ultimo registro de processado
              ,nrremret_urp INTEGER -- Numero de Remessa do ultimo registro de processado
              ,nrseqarq_urp INTEGER -- Sequencia no Arquivo do ultimo registro de processado
              ,nrconven INTEGER     -- Numero do Convenio
              ,dttransa VARCHAR2(10)-- Data do Protocolo
              ,hrautent VARCHAR2(8) -- Hora do Protocolo
              ,dtmvtolt VARCHAR2(10)-- Data de Movimento
        );

    TYPE typ_tab_agd_pgt_arq IS
        TABLE OF typ_rec_agd_pgt_arq
        INDEX BY BINARY_INTEGER;

    TYPE typ_tab_err_arq_agend IS
        TABLE OF VARCHAR2(5000)
        INDEX BY BINARY_INTEGER;

    TYPE typ_reg_rel_pgt_arq IS RECORD
       (dssituacao   VARCHAR2(9) 
       ,nrremret     craphpt.nrremret%TYPE
       ,cdbanco      INTEGER
       ,dhdgerac_rem DATE
       ,dtparadebito DATE
       ,dtvencto     DATE
       ,vldpagto     crapdpt.vldpagto%TYPE
       ,nmcedent     crapdpt.nmcedent%TYPE
       ,dsnosnum     crapdpt.dsnosnum%TYPE
       ,dscodbar     crapdpt.dscodbar%TYPE
       ,vltitulo     crapdpt.vltitulo%TYPE
       ,vldescto     crapdpt.vldescto%TYPE
       ,vlacresc     crapdpt.vlacresc%TYPE
       ,vlpagurp     crapdpt.vldpagto%TYPE
       ,dtpagto      crapdpt.dtdpagto%TYPE
       ,dsocorre_urp VARCHAR2(105)
       ,nrdconta     craphpt.nrdconta%TYPE
       ,estorno      INTEGER);
       
    TYPE typ_tab_rel_arq IS 
         TABLE OF typ_reg_rel_pgt_arq 
         INDEX BY VARCHAR2(15);

    -- Tabela de memoria para armazenar as criticas encontradas no Header e Trailer 
    -- P500
    TYPE typ_erros_headtrailer IS
        RECORD(tporigem varchar2(15)
              ,tperrocnab tbtransf_erros_cnab.tperrocnab%type
              ,dscampo    varchar2(240));

    TYPE typ_tab_typ_erros_headtrailer IS
        TABLE OF typ_erros_headtrailer
        INDEX BY PLS_INTEGER;
    
    TYPE typ_dados_segmento_a IS
        RECORD (cdbco_comp varchar2(03),
              nrlote_ser  varchar2(04),
              dstipo_reg  varchar2(01),
              nrseq_reg   varchar2(05),
              cdsegmento  varchar2(01),     
              dstipo_mov  varchar2(01),     
              cdbco_fav   varchar2(03),     
              cdage_conta varchar2(05),     
              nrdconta    varchar2(13),     
              nmfavorecido varchar2(30),    
              dtprv_pgto  varchar2(08),    
              dsmoeda     varchar2(03),     
              vlrpgto     varchar2(15),     
              dshistorico varchar2(20),     
              dsins_fav   varchar2(01),     
              nr_cpf_cnpj_fav varchar2(14), 
              dsfinalidade varchar2(05),
              tperrocnab  varchar2(02),
              dslinha_seg_a varchar2(240));  
     TYPE typ_tab_dados_segmento_a IS
        TABLE OF typ_dados_segmento_a
        INDEX BY PLS_INTEGER;           
    
        
    -- Procedure para Verificar o Aceite do Cooperado ao Convenio
    PROCEDURE pc_verif_aceite_conven(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                    ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                    ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                    ,pr_tab_cpt      OUT CLOB                   -- Retorna Tabela CRACPT
                                    ,pr_vretorno     OUT VARCHAR2    --> Retorna OK/NOK
                                    ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                    ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro

   -- Procedure para retornar o termo de Aceite ou de Cancelamento do Servico
   PROCEDURE pc_busca_termo_servico(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                   ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                   ,pr_tpdtermo      IN INTEGER                -- Tipo do Termo
                                   ,pr_idorigem      IN PLS_INTEGER            -- ID Origem
                                   ,pr_dsdtermo     OUT CLOB                   -- Conteudo do Termo
                                   ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                   ,pr_dscritic     OUT VARCHAR2);


    -- Procedure para Efetuar/Cancelar o aceite do associado no Convenio
    PROCEDURE pc_efetua_aceite_cancel(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                     ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                     ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                     ,pr_tpdtermo      IN INTEGER                -- Tipo do Termo
                                     ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                     ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                     ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                     ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro


  -- Procedure para validar arquivo de remessa
  PROCEDURE pc_validar_arq_pgto  (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                 ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                 ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                 ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                 ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                 ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                 ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                 ,pr_nrremess     OUT craphpt.nrremret%TYPE
                                 ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                 ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro

  -- Procedure para processar os registos na wt_crapdcc
  PROCEDURE pc_processar_arq_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                  ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                  ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                  ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                  ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                  ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                  ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Operador
                                  ,pr_nrremess      IN craphpt.nrremret%TYPE  -- Numero da Remessa do Cooperado
                                  ,pr_nrremret     OUT craphpt.nrremret%TYPE  -- Numero Remessa/Retorno
                                  ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                  ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro

   PROCEDURE pc_cadastrar_agend_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                    ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                    ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                    ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                    ,pr_nrconven      IN INTEGER
                                    ,pr_nrremret      IN INTEGER
                                    ,pr_nmarquiv      IN VARCHAR2
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
                                    ,pr_vldocnto      IN crapdpt.vltitulo%TYPE
                                    ,pr_cddbanco      IN craplau.cddbanco%TYPE
                                    ,pr_cdageban      IN craplau.cdageban%TYPE
                                    ,pr_nrctadst      IN craplau.nrctadst%TYPE
                                    ,pr_cdcoptfn      IN craplau.cdcoptfn%TYPE
                                    ,pr_cdagetfn      IN craplau.cdagetfn%TYPE
                                    ,pr_nrterfin      IN craplau.nrterfin%TYPE
                                    ,pr_nrcpfope      IN craplau.nrcpfope%TYPE
                                    ,pr_idtitdda      IN craplau.idtitdda%TYPE
                                    ,pr_cdctrlcs      IN tbcobran_consulta_titulo.cdctrlcs%TYPE DEFAULT NULL --> Numero de controle da consulta no NPC
                                    ,pr_idlancto      OUT INTEGER   -- ID do lançamento
                                    ,pr_dstransa      OUT VARCHAR2
                                    ,pr_cdcritic      OUT INTEGER                -- Código do erro
                                    ,pr_dscritic      OUT VARCHAR2);

  PROCEDURE pc_cancelar_agend_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
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
                                   ,pr_cdcritic      OUT INTEGER                -- Código do erro
                                   ,pr_dscritic      OUT VARCHAR2);

  -- Procedure para rejeitar arquivo de remessa que tenha critica
  PROCEDURE pc_rejeitar_arq_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                 ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                 ,pr_nrconven      IN craphpt.nrconven%TYPE  -- Numero do Convenio
                                 ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                 ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                 ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                 ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                 ,pr_dsmsgrej      IN VARCHAR2               -- Motivo da Rejeição
                                 ,pr_nrremret      IN INTEGER                -- Numero da Remessa do cooperado
                                 ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                 ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro

  PROCEDURE pc_gera_retorno_tit_pago (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                     ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                     ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                     ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Operador
                                     ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                     ,pr_dscritic     OUT VARCHAR2);

  PROCEDURE pc_gerar_arq_log_pgto(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                 ,pr_nrdconta  IN INTEGER                -- Numero da Conta
                                 ,pr_nrconven  IN INTEGER                -- Numero do Convenio
                                 ,pr_nrremret  IN INTEGER                -- Numero da Remessa
                                 ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                 ,pr_tab_err   IN PGTA0001.typ_tab_err_arq_agend -- Erros gerados no arquivo
                                 ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                 ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro

   -- Procedure para gerar arquivo de retorno
   PROCEDURE pc_gerar_arq_ret_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                   ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                   ,pr_nrremret      IN craphpt.nrremret%TYPE  -- Numero Remessa/Retorno
                                   ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                   ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                   ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                   ,pr_nmarquiv     OUT VARCHAR2               -- Nome do Arquivo
                                   ,pr_dsarquiv     OUT CLOB                   -- Conteudo do Arquivo -> Apenas quando origem Internet Banking
                                   ,pr_dsinform     OUT VARCHAR2               -- Mensagem Informativa
                                   ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                   ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro


    -- Procedure para logar no arquivo cst_arquivo.log
    PROCEDURE pc_logar_cst_arq_pgto(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                   ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                   ,pr_textolog      IN VARCHAR2               -- Texto a ser Incluso Log
                                   ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                   ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro

    -- Procedure de retorno de titulos agendados
    PROCEDURE pc_retorna_titulo_agendado(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                        ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                        ,pr_nrconven      IN craphpt.nrconven%TYPE  -- Numero do Convenio
                                        ,pr_dtinicon      IN DATE                   -- Data Inicial
                                        ,pr_dtfincon      IN DATE                   -- Data Final
                                        ,pr_tab_titulo   OUT CLOB                   -- XML da tabela de titulos
                                        ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                        ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro

    PROCEDURE pc_deleta_email_ret(pr_cdcooper IN crapcop.cdcooper%TYPE      --> Cooperativa
                                 ,pr_nrdconta IN crapcpt.nrdconta%TYPE      --> Numero da conta
                                 ,pr_nrconven IN crapcpt.nrconven%TYPE      --> Numero convenio
                                 ,pr_idseqttl IN crapttl.idseqttl%TYPE      --> Titular
                                 ,pr_cdcritic OUT INTEGER                   --> Código do erro
                                 ,pr_dscritic OUT VARCHAR2);                --> Descricao do erro

    PROCEDURE pc_cancela_convenio(pr_nrdconta IN crapcpt.nrdconta%TYPE   --> Numero da conta
                                 ,pr_nrconven IN crapcpt.nrconven%TYPE   --> Numero convenio
                                 ,pr_xmllog   IN VARCHAR2                --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype      --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);

    PROCEDURE pc_inserir_convenio(pr_nrdconta IN crapcpt.nrdconta%TYPE   --> Numero da conta
                                 ,pr_nrconven IN crapcpt.nrconven%TYPE   --> Numero convenio
                                 ,pr_flghomol IN crapcpt.flghomol%TYPE   --> Homologado
                                 ,pr_idretorn IN crapcpt.idretorn%TYPE   --> Tipo de transmissao (1=Internet, 2=FTP)
                                 ,pr_flgativo IN crapcpt.flgativo%TYPE   --> Convenio ativo
                                 ,pr_xmllog   IN VARCHAR2                --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype      --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);
                                 
    PROCEDURE pc_inserir_emails(pr_nrdconta IN crapcpt.nrdconta%TYPE   --> Numero da conta
                               ,pr_nrconven IN crapcpt.nrconven%TYPE   --> Numero convenio
                               ,pr_lstemail IN VARCHAR2                --> lista de emails
                               ,pr_cddopcao IN VARCHAR2                --> Opcao da tela
                               ,pr_xmllog   IN VARCHAR2                --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype      --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);
                             
    PROCEDURE pc_alterar_convenio(pr_nrdconta IN crapcpt.nrdconta%TYPE   --> Numero da conta
                                 ,pr_nrconven IN crapcpt.nrconven%TYPE   --> Numero convenio
                                 ,pr_flghomol IN crapcpt.flghomol%TYPE   --> Homologado
                                 ,pr_idretorn IN crapcpt.idretorn%TYPE   --> Tipo de transmissao (1=Internet, 2=FTP)
                                 ,pr_flgativo IN crapcpt.flgativo%TYPE   --> Convenio ativo
                                 ,pr_xmllog   IN VARCHAR2                --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype      --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);

    PROCEDURE pc_consulta_log(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                             ,pr_dtiniper IN VARCHAR2 --> Inicio do periodo
                             ,pr_dtfimper IN VARCHAR2 --> Fim do periodo
                             ,pr_nmtabela IN tbcobran_cpt_log.nmtabela%TYPE --> Nome da tabela
                             ,pr_nmdocampo IN tbcobran_cpt_log.nmdcampo%TYPE --> Nome do campo
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);
             
    PROCEDURE pc_carrega_crapcem(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);
                    
    PROCEDURE pc_carrega_cptcem(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);
                                           
    -- Procedure para verificar se o cooperado possui o convenio homologado e algum arquivo de remessa enviado
    PROCEDURE pc_verifica_conv_pgto(pr_cdcooper  IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                   ,pr_nrconven OUT INTEGER                -- Numero do Convenio
                                   ,pr_dtadesao OUT DATE                   -- Data de adesao
                                   ,pr_flghomol OUT INTEGER                -- Convenio esta homologado
                                   ,pr_idretorn OUT INTEGER                -- Retorno para o Cooperado (1-Internet/2-FTP)
                                   ,pr_fluppgto OUT INTEGER                -- Flag possui convenio habilitado
                                   ,pr_flrempgt OUT INTEGER                -- Flag possui arquivo de remessa enviado
                                   ,pr_cdcritic OUT INTEGER                -- Código do erro
                                   ,pr_dscritic OUT VARCHAR2);             -- Descricao do erro

  -- Procedure para gerar LOG referente ao processamento do arquivo de agendamento de pagamento
    PROCEDURE pc_gera_log_arq_web(pr_nrdconta    IN crawepr.nrdconta%TYPE --> Nr. da Conta
                                 ,pr_nrconven    IN INTEGER               --> Convenio
                                 ,pr_tpmovimento IN INTEGER               --> Indicador do tipo de movimento (1-Remessa/ 2-Retorno)
                                 ,pr_nrremret    IN INTEGER               --> Numero da Remessa
                                 ,pr_nmoperad_online IN VARCHAR2          --> Nome do operador logado na conta online
                                 ,pr_cdprograma  IN VARCHAR2              --> Programa que chamou a gravacao
                                 ,pr_nmtabela    IN VARCHAR2              --> Tabela que foi manipulada para gerar o log
                                 ,pr_nmarquivo   IN VARCHAR2              --> Nome do arquivo que esta sendo processado
                                 ,pr_dsmsglog    IN VARCHAR2              --> Descricao do LOG
                                 ,pr_xmllog      IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic    OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic    OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml      IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo    OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro    OUT VARCHAR2);

  -- Procedure para gerar LOG referente ao processamento do arquivo de agendamento de pagamento
  PROCEDURE pc_gera_log_arq_pgto(pr_cdcooper        IN INTEGER,  -- Cooperativa
                                 pr_nrdconta        IN INTEGER,  -- Conta
                                 pr_nrconven        IN INTEGER,  -- Convenio
                                 pr_tpmovimento     IN INTEGER,  -- Indicador do tipo de movimento (1-Remessa/ 2-Retorno)
                                 pr_nrremret        IN INTEGER,  -- Numero da Remessa
                                 pr_cdoperad        IN VARCHAR2, -- Operador logado na conta online
                                 pr_nmoperad_online IN VARCHAR2, -- Nome do operador logado na conta online
                                 pr_cdprograma      IN VARCHAR2, -- Programa que chamou a gravacao
                                 pr_nmtabela        IN VARCHAR2, -- Tabela que foi manipulada para gerar o log
                                 pr_nmarquivo       IN VARCHAR2, -- Nome do arquivo que esta sendo processado
                                 pr_dsmsglog        IN VARCHAR2, -- Descricao do LOG
                                 pr_cdcritic       OUT INTEGER,  -- Código do erro
                                 pr_dscritic       OUT VARCHAR2);-- Descricao do erro
                                 
  -- Procedure para consultar LOG referente ao processamento do arquivo de agendamento de pagamento
  PROCEDURE pc_consulta_log_arq_pgto(pr_cdcooper  IN INTEGER, -- Cooperativa
                                     pr_nrdconta  IN INTEGER, -- Conta
                                     pr_nrconven  IN INTEGER, -- Convenio
                                     pr_nrremret  IN INTEGER, -- Numero da Remessa
                                     pr_nmtabela  IN VARCHAR2, -- Tabela que foi manipulada para gerar o log
                                     pr_nmarquivo IN VARCHAR2, -- Nome do arquivo que esta sendo processado
                                     pr_dtinilog  IN VARCHAR2, -- Data inicial de pesquisa do log
                                     pr_dtfimlog  IN VARCHAR2, -- Data inicial de pesquisa do log
                                     pr_xml_log   OUT NOCOPY CLOB, -- Descricao do LOG
                                     pr_cdcritic  OUT INTEGER, -- Código do erro
                                     pr_dscritic  OUT VARCHAR2); -- Descricao do erro                                 

  -- Procedure para consultar LOG referente ao processamento do arquivo de agendamento de pagamento
  PROCEDURE pc_consulta_log_arq_web(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                                   ,pr_nrconven IN INTEGER               --> Convenio
                                   ,pr_nrremret IN INTEGER               --> Numero da Remessa
                                   ,pr_nmtabela IN VARCHAR2              --> Tabela que foi manipulada para gerar o log
                                   ,pr_nmarquivo IN VARCHAR2             --> Nome do arquivo que esta sendo processado
                                   ,pr_dtinilog IN VARCHAR2              --> Data inicial de pesquisa do log
                                   ,pr_dtfimlog IN VARCHAR2              --> Data inicial de pesquisa do log
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Descricao do erro
                                   
  -- Procedure para consultar LOG referente ao processamento do arquivo de agendamento de pagamento
  PROCEDURE pc_cons_tit_arq_pgto_car(pr_cdcooper         IN INTEGER,  -- Cooperativa
                                     pr_nrdconta         IN INTEGER,  -- Conta
                                     pr_nrremess         IN INTEGER,  -- Numero da Remessa
                                     pr_nmarquiv         IN VARCHAR2, -- Nome do arquivo que esta sendo processado
                                     pr_nmbenefi         IN VARCHAR2, -- Nome do arquivo que esta sendo processado
                                     pr_dscodbar         IN VARCHAR2, -- Nome do arquivo que esta sendo processado
                                     pr_idstatus         IN INTEGER,  -- Status do Titulo (1-Todos /2-Liquidado /3-Pendente de Liquidação / 4-Com erro
                                     pr_tpdata           IN INTEGER,  -- Tipo de Data que está sendo pesquisada (1-Data de Remessa / 2-Data de Vencimento / 3-Data Agendada para Pagamento)
                                     pr_dtiniper         IN VARCHAR2, -- Data inicial de pesquisa
                                     pr_dtfimper         IN VARCHAR2, -- Data final   de pesquisa
                                     pr_iniconta         IN INTEGER,  -- Numero de Registros da Tela
                                     pr_nrregist         IN INTEGER,  -- Numero da Registros -> Informar NULL para carregar todos os registros
                                     pr_qttotage        OUT INTEGER,  -- Quantidade Total de Agendamentos
                                     pr_xml             OUT NOCOPY CLOB, -- Descricao do LOG
                                     pr_cdcritic        OUT INTEGER,     -- Código do erro
                                     pr_dscritic        OUT VARCHAR2);   -- Descricao do erro

  -- Procedure para consultar LOG referente ao processamento do arquivo de agendamento de pagamento
  PROCEDURE pc_cons_tit_arq_pgto_web(pr_nrdconta IN INTEGER   -- Conta
                                    ,pr_nrremess IN INTEGER   -- Numero da Remessa
                                    ,pr_nmarquiv IN VARCHAR2  -- Nome do arquivo que esta sendo processado
                                    ,pr_nmbenefi IN VARCHAR2  -- Nome do arquivo que esta sendo processado
                                    ,pr_dscodbar IN VARCHAR2  -- Nome do arquivo que esta sendo processado
                                    ,pr_idstatus IN INTEGER   -- Status do Titulo (1-Todos /2-Liquidado /3-Pendente de Liquidação / 4-Com erro
                                    ,pr_tpdata   IN INTEGER   -- Tipo de Data que está sendo pesquisada (1-Data de Remessa / 2-Data de Vencimento / 3-Data Agendada para Pagamento)
                                    ,pr_dtiniper IN VARCHAR2  -- Data inicial de pesquisa
                                    ,pr_dtfimper IN VARCHAR2  -- Data final   de pesquisa
                                    ,pr_iniconta IN INTEGER   -- Numero de Registros da Tela
                                    ,pr_nrregist IN INTEGER   -- Numero da Registros -> Informar NULL para carregar todos os registros                                    
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);
                                    
  -- Procedure para consultar LOG referente ao processamento do arquivo de agendamento de pagamento
  PROCEDURE pc_canc_agd_pgto_tit_car(pr_cdcooper         IN INTEGER,  -- Cooperativa
                                     pr_nrdconta         IN INTEGER,  -- Conta
                                     pr_nrconven         IN INTEGER,  -- Numero do Convenio
                                     pr_dtmvtolt         IN VARCHAR2, -- Data do Sistema
                                     pr_cdoperad         IN VARCHAR2, -- Operador
                                     pr_idorigem         IN INTEGER,  -- Origem
                                     -- Dados para identificar o agendamento que esta sendo cancelado
                                     pr_intipmvt         IN INTEGER,  -- Tipo de Movimento
                                     pr_nrremret         IN INTEGER,  -- Numero de Remessa
                                     pr_nrseqarq         IN INTEGER,  -- Sequencia do agendamento no arquivo
                                     -- Novo Numero de Remessa e Nova Sequencia do arquivo
                                     pr_nrremret_new     IN INTEGER,  -- Numero da Sequencia dentro do arquivo
                                     pr_nrseqarq_new     IN INTEGER,  -- Numero da Sequencia dentro do arquivo
                                     -- OUT
                                     pr_nrremret_out    OUT INTEGER,     -- Numero do Arquivo de Retorno
                                     pr_cdcritic        OUT INTEGER,     -- Código do erro
                                     pr_dscritic        OUT VARCHAR2);   -- Descricao do erro
                                      
  PROCEDURE pc_consulta_conta(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);
                             
  PROCEDURE pc_relato_arq_pgto(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cod Cooperativa
                              ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                              ,pr_cdagenci IN crapass.cdagenci%TYPE --> PA
                              ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE --> Numero caixa
                              ,pr_cdoperad IN crapope.cdoperad%TYPE --> Cod Operador
                              ,pr_nrdconta IN INTEGER               --> Conta
                              ,pr_nrremess IN INTEGER               --> Numero da Remessa
                              ,pr_nmarquiv IN VARCHAR2              --> Nome do arquivo que esta sendo processado
                              ,pr_nmbenefi IN VARCHAR2              --> Nome do beneficiario
                              ,pr_dscodbar IN VARCHAR2              --> Codigo de barras
                              ,pr_idstatus IN INTEGER               --> Status do Titulo (1-Todos /2-Liquidado /3-Pendente de Liquidação / 4-Com erro
                              ,pr_tpdata   IN INTEGER               --> Tipo de Data que está sendo pesquisada (1-Data de Remessa / 2-Data de Vencimento / 3-Data Agendada para Pagamento)
                              ,pr_dtiniper IN DATE                  --> Data inicial de pesquisa
                              ,pr_dtfimper IN DATE                  --> Data final   de pesquisa
                              ,pr_idorigem IN INTEGER               --> Sistema de origem chamador
                              ,pr_tprelato IN INTEGER               --> Tipo do relatorio (1-PDF /2-CSV)
                              ,pr_iddspscp IN INTEGER               --> Parametro criado para permitir a geracao do relatorio para o IB atual e para o IB novo
                              ,pr_nmrelato OUT VARCHAR2             --> Nome do arquivo do relatorio com extensao
                              ,pr_dssrvarq OUT VARCHAR2             --> Nome do servidor para download do arquivo
                              ,pr_dsdirarq OUT VARCHAR2             --> Nome do diretório para download do arquivo                                                               
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2);                             
                              
  PROCEDURE pc_relato_arq_pgto_web(pr_nrdconta IN INTEGER               --> Conta
                                  ,pr_nrremess IN INTEGER               --> Numero da Remessa
                                  ,pr_nmarquiv IN VARCHAR2              --> Nome do arquivo que esta sendo processado
                                  ,pr_nmbenefi IN VARCHAR2              --> Nome do beneficiario
                                  ,pr_dscodbar IN VARCHAR2              --> Codigo de barras
                                  ,pr_idstatus IN INTEGER               --> Status do Titulo (1-Todos /2-Liquidado /3-Pendente de Liquidação / 4-Com erro
                                  ,pr_tpdata   IN INTEGER               --> Tipo de Data que está sendo pesquisada (1-Data de Remessa / 2-Data de Vencimento / 3-Data Agendada para Pagamento)
                                  ,pr_dtiniper IN VARCHAR2              --> Data inicial de pesquisa
                                  ,pr_dtfimper IN VARCHAR2              --> Data final   de pesquisa
                                  ,pr_tprelato IN INTEGER               --> Tipo do relatorio (1-PDF /2-CSV)
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_relato_arq_pgto_ib(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cod Cooperativa
                                 ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --> PA
                                 ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE --> Numero caixa
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE --> Cod Operador
                                 ,pr_nrdconta IN INTEGER               --> Conta
                                 ,pr_nrremess IN INTEGER               --> Numero da Remessa
                                 ,pr_nmarquiv IN VARCHAR2              --> Nome do arquivo que esta sendo processado
                                 ,pr_nmbenefi IN VARCHAR2              --> Nome do beneficiario
                                 ,pr_dscodbar IN VARCHAR2              --> Codigo de barras
                                 ,pr_idstatus IN INTEGER               --> Status do Titulo (1-Todos /2-Liquidado /3-Pendente de Liquidação / 4-Com erro
                                 ,pr_tpdata   IN INTEGER               --> Tipo de Data que está sendo pesquisada (1-Data de Remessa / 2-Data de Vencimento / 3-Data Agendada para Pagamento)
                                 ,pr_dtiniper IN VARCHAR2              --> Data inicial de pesquisa
                                 ,pr_dtfimper IN VARCHAR2              --> Data final   de pesquisa
                                 ,pr_idorigem IN INTEGER               --> Sistema de origem chamador
                                 ,pr_tprelato IN INTEGER               --> Tipo do relatorio (1-PDF /2-CSV)
                                 ,pr_iddspscp IN INTEGER               --> Parametro criado para permitir a geracao do relatorio para o IB atual e para o IB novo
                                 ,pr_nmrelato OUT VARCHAR2             --> Nome do arquivo do relatorio com extensao
                                 ,pr_dssrvarq OUT VARCHAR2             --> Nome do servidor para download do arquivo
                                 ,pr_dsdirarq OUT VARCHAR2             --> Nome do diretório para download do arquivo                                                                  
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2);           --> Descricao da critica

  PROCEDURE pc_importa_pagarq(pr_cdcooper  IN crapcop.cdcooper%TYPE
                             ,pr_dsarquiv  IN VARCHAR2
                             ,pr_dsdireto  IN VARCHAR2
                             ,pr_dscritic  OUT VARCHAR2
                             ,pr_retxml    OUT CLOB);
                             
  PROCEDURE pc_importa_pagarq_web(pr_dsarquiv   IN VARCHAR2            --> Informações do arquivo
                                 ,pr_dsdireto   IN VARCHAR2            --> Informações do diretório do arquivo
                                 ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                 ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);
                                 
  FUNCTION fn_converte_fator_vencimento(pr_dtmvtolt IN DATE    --Data Movimento
                                       ,pr_nrdfator IN INTEGER --Fator de vencimento
                                       ) RETURN DATE;
                                       
  procedure pc_verifica_layout_ted (pr_cdcooper   in craphis.cdcooper%type
                               ,pr_nrdconta   in crapass.nrdconta%type
                               ,pr_nmarquiv   in varchar2
                               ,pr_retxml in out nocopy XMLType
                               ,pr_cdcritic  out pls_integer
                               ,pr_dscritic  out varchar2); 
                               
 procedure pc_importa_arquivo_ted (pr_cdcooper   in crapatr.cdcooper%type  --> Número da cooperativa do cooperado
                                   ,pr_nrdconta   in crapass.nrdconta%type  --> Número da conta do cooperado
                                   ,pr_dsarquiv   IN VARCHAR2       --> Informações do arquivo
                                   ,pr_dsdireto   IN VARCHAR2       --> Informações do diretório do arquivo                                  
                                   ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);  
                                    
procedure pc_consulta_arquivo_remessa   (pr_cdcooper   in crapatr.cdcooper%type  --> Número da cooperativa do cooperado
                                   ,pr_nrdconta   in crapass.nrdconta%type  --> Número da conta do cooperado
                                   ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);        --> Erros do processo                             
                                                                                                    

procedure pc_salva_arquivo_remessa (pr_nrseq_arq_ted   in tbtransf_arquivo_ted.nrseq_arq_ted%type  --> Número de identificação do arquivo
                                   ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);        --> Erros do processo 
                                                                     

procedure pc_gerar_seg_arquivo_retorno (pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2    --> Descrição da crítica
                                   );                                                                     
END PGTA0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PGTA0001 IS

---------------------------------------------------------------------------------------------------------------
--
--  Programa : PGTA0001
--  Sistema  : Rotinas genericas focando nas funcionalidades do pagamento por arquivo
--  Sigla    : PGTA
--  Autor    : Daniel Zimmermann
--  Data     : Maio/2014.                   Ultima atualizacao: 03/09/2018
--
-- Dados referentes ao programa:
--
-- Frequencia: Sempre que Chamado
-- Objetivo  : Agrupar rotinas genéricas dos sistemas Oracle

-- Alteracoes: 15/07/2015 - Adicionado troca de acentuacao do nmcedent em proc. pc_validar_arq_pgto.
--                          (Jorge/Rafael) - SD 304877                          

--             19/01/2016 - Adicionado ao arquivo de retorno nova linha incluindo informações como,
--                         autenticação, documento, data, hora e protocolo (Kelvin).        
--
--             20/06/2016 - Correcao para o uso da function fn_busca_dstextabem da TABE0001 em 
--                          procedures desta package.(Carlos Rafael Tanholi).                                 
--
--             17/01/2017 - Ajustar a procedure pc_validar_arq_pgto para verificar se a conta que
--                          esta realizando o agendamento possui privilegios de PAGADORVIP,
--                          para não criticar a data de vencimento do titulo que esta sendo agendado 
--                          (Douglas - Chamado 551630).
--
--             22/02/2017 - Ajustes para correçao de crítica de pagamento DARF/DAS (Lucas Lunelli - P.349.2)
--
--             18/05/2017 - Ajustado rotina pc_processar_arq_pgto para realizar consulta NPC.
--                     
--             28/08/2017 - Ajustado rotina pc_gerar_arq_ret_pgto para gravar situação da transação corretamente
--                          ao gravar o log da operação
--                          (Adriano - SD 738594).
--
--             12/09/2017 - Ajuste contigencia NPC. PRJ340 (Odirlei-AMcom)   
--
--             03/10/2017 - #766774 Na rotina pc_processar_arq_pgto, alterado o arquivo de log de null (proc_batch)
--                          para proc_message (Carlos)
--
--             10/10/2017 - Ajuste na geração da linha do SEGMENTO J99 para gerar com 
--                          240 posições (Douglas - Chamado 751271)
--
--             27/10/2017 - #781654 Na rotina pc_processar_arq_pgto, alterado o arquivo de log de null (proc_batch)
--                          para proc_message (Carlos)
--
--             11/12/2017 - Alterar campo flgcnvsi por tparrecd.
--                          PRJ406-FGTS (Odirlei-AMcom)  
----
--             15/12/2017 - Com a eliminação das descrições fixas na PAGA0001
--                          Incluido codigo junto com a descrição em condição
--                          Quando todos programas gerarem codigo a descrição pode ser eliminada
--                          (Belli - Envolti - Chamado 779415)  

--
--             18/12/2017 - Efetuado alteração para controle de lock (Jonata - Mouts).  
--
--             26/02/2018 - Alterado cursor cr_crapass da procedure pc_busca_termo_servico, 
--                          substituindo o acesso à tabela CRAPTIP, pela tabela TBCC_TIPO_CONTA.
--                          PRJ366 (Lombardi).
--
--             03/09/2018 - Correção para remover lote (Jonata - Mouts).
--
--             04/07/2019 - Ajuste de validações no segmento a.
--                          Jose Dill - Mouts (P500 - SM01)
--
---------------------------------------------------------------------------------------------------------------


  -- Descricao e codigo da critica
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(4000);
  vr_nmarqlog varchar2(100) := 'pgto_por_arquivo.log';

  --Tipo de Dados para cursor data
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  
  --P500
  vr_nrseq_arq_ted  VARCHAR2(06);
  vr_nmarvalidar    VARCHAR2(100); 
  vr_id_nrseq_arq_ted  tbtransf_arquivo_ted.nrseq_arq_ted%type;
  vr_clob_ted       CLOB;
  vr_qtreg_lote     INTEGER :=0;
  vr_qtreg_header_lote INTEGER :=0;
  vr_qtreg_arq_total   INTEGER :=0;
  vr_vlrpgt_segm_a  NUMBER(15,2):= 0;
  vr_nr_seq_gravada INTEGER:= 0;

  
  -- Procedure para Verificar o Aceite do Cooperado ao Convenio
  PROCEDURE pc_verif_aceite_conven (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                   ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                   ,pr_tab_cpt      OUT CLOB                   -- Retorna Tabela CRACPT
                                   ,pr_vretorno     OUT VARCHAR2               --> Retorna OK/NOK
                                   ,pr_cdcritic     OUT INTEGER                -- Código do erro
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
           ,DECODE(crapcpt.flgativo,1,'ATIVO','INATIVO')       dsflgativo
           ,crapcpt.flgativo
           ,DECODE(crapcpt.flghomol,1,'SIM','NAO')             dsflghomol
           ,crapcpt.flghomol
           ,crapcpt.dtdhomol
           ,DECODE(crapcpt.idretorn,1,'INTERNET','FTP')        dsidretorn
           ,crapcpt.idretorn
           ,DECODE(crapcpt.cdoperad,'996','INTERNET','AIMARO') dsorigem
           ,crapcpt.dtaltera
           ,(SELECT crapope.cdoperad || ' - ' || crapope.nmoperad 
               FROM crapope ope 
              WHERE ope.cdcooper = crapcpt.cdcooper 
                AND ope.cdoperad = crapcpt.cdopehom) cdopehom
       FROM crapcpt crapcpt
           ,crapope crapope
      WHERE crapope.cdcooper = crapcpt.cdcooper
        AND crapope.cdoperad = crapcpt.cdoperad
        AND crapcpt.cdcooper = pr_cdcooper
        AND crapcpt.nrdconta = pr_nrdconta
        AND crapcpt.nrconven = pr_nrconven;
     rw_crapcpt cr_crapcpt%ROWTYPE;


     -- Buscar o número da ultima Remessa
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
     -- Se não encontrar
     IF cr_crapcop%NOTFOUND THEN
       -- Fechar o cursor pois haverá raise
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
     -- Se não encontrar
     IF cr_crapass%NOTFOUND THEN
       -- Fechar o cursor pois haverá raise
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
     -- Se não encontrar
     IF cr_crapcpt%NOTFOUND THEN
       -- Fechar o cursor pois haverá raise
       CLOSE cr_crapcpt;
       vr_des_erro := 'Para utilização, faça o aceite no Termo de utilização do serviço.';
       RAISE vr_existe_aceit;
     ELSE
       -- Se nao estiver ativo
       IF rw_crapcpt.flgativo <> 1 THEN
          pr_dscritic := 'Cooperado com Convênio INATIVO!';
       END IF;


       -- Verifica ultima sequencia da Remessa
       OPEN cr_craphpt(pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrconven => pr_nrconven);
       FETCH cr_craphpt
        INTO rw_craphpt;
       -- Se encontrar arquivo
       IF cr_craphpt%FOUND THEN
         -- Fechar o cursor pois haverá raise
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

       -- Insere o cabeçalho do XML
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
                                                    || '<flghomol>'||rw_crapcpt.flghomol||'</flghomol>'
                                                    || '<dtdhomol>'||TO_CHAR(rw_crapcpt.dtdhomol,'DD/MM/YYYY')||'</dtdhomol>'
                                                    || '<idretorn>'||rw_crapcpt.idretorn||'</idretorn>'
                                                    || '<dtaltera>'||TO_CHAR(rw_crapcpt.dtaltera,'DD/MM/YYYY')||'</dtaltera>'
                                                    || '<cdopehom>'||rw_crapcpt.cdopehom||'</cdopehom>'
                                                    || '<dsflgativo>'||rw_crapcpt.dsflgativo||'</dsflgativo>'
                                                    || '<dsflghomol>'||rw_crapcpt.dsflghomol||'</dsflghomol>'
                                                    || '<dsidretorn>'||rw_crapcpt.dsidretorn||'</dsidretorn>'
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
      -- Apenas retornar a variável de saida
      pr_cdcritic := 0;
      pr_dscritic := 'Erro PGTA0001.pc_verif_aceite_conven: ' || SQLERRM;
      pr_vretorno := 'NOK';

  END;

  END pc_verif_aceite_conven;


  -- Procedure para retornar o termo de Aceite ou de Cancelamento do Servico
  PROCEDURE pc_busca_termo_servico (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                   ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                   ,pr_tpdtermo      IN INTEGER                -- Tipo do Termo
                                   ,pr_idorigem      IN PLS_INTEGER            -- ID Origem
                                   ,pr_dsdtermo     OUT CLOB                   -- Conteudo do Termo
                                   ,pr_cdcritic     OUT INTEGER                -- Código do erro
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
             ,tpcta.dstipo_conta
             ,INITCAP(crapenc.dsendere)||', '||crapenc.nrendere||DECODE(crapenc.complend,' ','',', '||crapenc.complend) dsendere
             ,crapenc.nmcidade
             ,crapenc.cdufende
             ,gene0002.fn_mask(crapenc.nrcepend,'99999-999') nrcepend
             ,gene0002.fn_mask(crapass.cdbcochq,'9999') cdbcoctl
             ,gene0002.fn_mask(crapass.cdagenci,'9999') cdagectl
         FROM crapass crapass
             ,tbcc_tipo_conta tpcta
             ,crapenc crapenc
        WHERE crapass.inpessoa = tpcta.inpessoa
          AND crapass.cdtipcta = tpcta.cdtipo_conta
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
     -- Se não encontrar
     IF cr_crapcop%NOTFOUND THEN
       -- Fechar o cursor pois haverá raise
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
     -- Se não encontrar
     IF cr_crapass%NOTFOUND THEN
       -- Fechar o cursor pois haverá raise
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
       -- Se não encontrar
       IF cr_crapcpt%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
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
    -- Se não encontrar
    IF cr_crapenc%NOTFOUND THEN
       -- Fechar o cursor pois pesquisará com outro tipo
       CLOSE cr_crapenc;

       -- Busca enderecos do Associado - Tipo 10
       OPEN cr_crapenc(pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_tpendass => 10);
       FETCH cr_crapenc
        INTO rw_crapenc;
       -- Se não encontrar
       IF cr_crapenc%NOTFOUND THEN
         -- Fechar o cursor pois pesquisará com outro tipo
         CLOSE cr_crapenc;

         -- Busca enderecos do Associado - Tipo 9
         OPEN cr_crapenc(pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_tpendass => 9);
         FETCH cr_crapenc
          INTO rw_crapenc;
         -- Se não encontrar
         IF cr_crapenc%NOTFOUND THEN
           -- Fechar o cursor pois haverá raise
           CLOSE cr_crapenc;
           vr_des_erro := 'Cooperado sem endereço cadastrado!';
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

        -- Buscar configuração na tabela
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => vr_cdacesso
                                                 ,pr_tpregist => 90);           
        
        
        -- Se não encontrar
        IF TRIM(vr_dstextab) IS NULL THEN 
          vr_des_erro := 'Termo do Serviço não encontrado![' || vr_cdacesso || ']';
          RAISE vr_exc_saida;
        ELSE


          -- OBS.: Situação temporária pois cartórios de Blumenau não estão registrando Contratos/Termos temporariamente
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

           -- OBS.: Situação temporária pois cartórios de Blumenau não estão registrando Contratos/Termos temporariamente
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

           -- OBS.: Situação temporária pois cartórios de Blumenau não estão registrando Contratos/Termos temporariamente
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

        -- Buscar configuração na tabela
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => vr_cdacesso
                                                 ,pr_tpregist => 90);
        
       -- Se não encontrar
       IF TRIM(vr_dstextab) IS NULL THEN 
          vr_des_erro := 'Termo do Serviço não encontrado![' || vr_cdacesso || ']';
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
          vr_dstextab := REPLACE(vr_dstextab,'#DSTIPCTA#',rw_crapass.dstipo_conta);

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
      -- Apenas retornar a variável de saida
      pr_cdcritic := 0;
      pr_dscritic := 'Erro PGTA0001.pc_busca_termo_servico: ' || SQLERRM;

   END;

  END pc_busca_termo_servico;


  -- Procedure para Efetuar o aceite do associado no Convenio
  PROCEDURE pc_efetua_aceite_cancel (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                    ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                    ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                    ,pr_tpdtermo      IN INTEGER                -- Tipo do Termo
                                    ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                    ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                    ,pr_cdcritic     OUT INTEGER                -- Código do erro
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
          -- ,crapass.inpessoa
		   ,DECODE(crapass.inpessoa,1,1,2,2,2) inpessoa
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
     -- Se não encontrar
     IF cr_crapcop%NOTFOUND THEN
       -- Fechar o cursor pois haverá raise
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
     -- Se não encontrar
     IF cr_crapass%NOTFOUND THEN
       -- Fechar o cursor pois haverá raise
       CLOSE cr_crapass;
       vr_des_erro := 'Cooperado nao cadastrado.';
       RAISE vr_exc_saida;
     ELSE
       IF  rw_crapass.inpessoa <> 2 THEN
           CLOSE cr_crapass;
           vr_des_erro := 'Permitido apenas para Pessoa Jurídica.';
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
             vr_des_erro := 'Cooperado já possui Aceite no Pagamento por Arquivo.';
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
                   vr_des_erro := 'Erro na atualização de dados na CRAPCPT: ' || SQLERRM;
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
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapcpt;
          vr_des_erro := 'Cooperado não possui Aceite para Cancelamento no Pagamento por Arquivo.';
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
                   vr_des_erro := 'Erro na atualização de dados na CRAPCPT: ' || SQLERRM;
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
      -- Apenas retornar a variável de saida
      pr_cdcritic := 0;
      pr_dscritic := 'Erro PGTA0001.pc_efetua_aceite_conven: ' || SQLERRM;
      -- Efetua Rollback
      ROLLBACK;

  END;

  END pc_efetua_aceite_cancel;
  
  -- Procedure para identificar se o titulo eh da cooperativa, ou se eh de outra IF
  PROCEDURE pc_identifica_interbancario(pr_cdcooper  IN INTEGER      --Codigo Cooperativa
                                       ,pr_codbarra  IN VARCHAR2     --Codigo Barras
                                       ,pr_intitcop OUT INTEGER      --Indicador titulo cooperativa (1-Cooperativa / 0-Outra IF)
                                       ,pr_cdcritic OUT INTEGER      --Codigo do erro
                                       ,pr_dscritic OUT VARCHAR2) IS --Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_identifica_interbancario
  --  Sistema  : Procedure para identificar titulo cooperativa
  --  Sigla    : PGTA
  --  Autor    : Douglas Quisinski
  --  Data     : Março/2017                     Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Nova Procedure para identificar titulo cooperativa
  --
  -- Alteracoes:      
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Cursores Locais
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT crapcop.cdcooper
              ,crapcop.nmrescop
              ,crapcop.cdbcoctl
              ,crapcop.cdagectl
              ,crapcop.cdagebcb
          FROM crapcop
         WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      
      --Selecionar informacoes convenio cobranca
      CURSOR cr_crapcco (pr_cdcooper  IN crapcco.cdcooper%type
                        ,pr_nrconven  IN crapcco.nrconven%TYPE) IS
        SELECT crapcco.cddbanco
              ,crapcco.dsorgarq
              ,crapcco.flgutceb
              ,crapcco.nrconven
              ,crapcco.nrdctabb
              ,crapcco.flgregis
        FROM crapcco
        WHERE crapcco.cdcooper = pr_cdcooper
          AND crapcco.nrconven = pr_nrconven;
      rw_crapcco cr_crapcco%ROWTYPE;

      --Selecionar de qual cooperativa o convenio pertencia
      CURSOR cr_ceb_ant (pr_cdcooper IN crapcco.cdcooper%TYPE
                        ,pr_nrdconta IN crapceb.nrdconta%TYPE
                        ,pr_nrconven IN crapcco.nrconven%TYPE) IS
        SELECT cco.cdcooper cco_cdcopant
              ,cco.dsorgarq
              ,tco.cdcooper tco_cdcooper
              ,tco.nrdconta tco_nrdconta
          FROM crapcco cco, crapceb ceb, craptco tco
         WHERE cco.cdcooper <> pr_cdcooper
           AND cco.nrconven = pr_nrconven
           AND ceb.cdcooper = cco.cdcooper
           AND ceb.nrdconta = pr_nrdconta
           AND ceb.nrconven = cco.nrconven
           AND tco.cdcopant = cco.cdcooper
           AND tco.nrctaant = ceb.nrdconta;
      rw_ceb_ant cr_ceb_ant%ROWTYPE;

      --Selecionar informacoes convenio 'IMPRESSO PELO SOFTWARE'
      CURSOR cr_cco_impresso (pr_nrconven IN crapcco.nrconven%TYPE) IS
        SELECT crapcco.cddbanco
              ,crapcco.dsorgarq
              ,crapcco.nrconven
              ,crapcco.nrdctabb
        FROM crapcco
        WHERE crapcco.cdcooper > 0
          AND crapcco.nrconven = pr_nrconven
          AND crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE';
      rw_cco_impresso cr_cco_impresso%ROWTYPE;

      --Selecionar cadastro emissao bloquetos - conv 6 digitos
      CURSOR cr_crapceb1 (pr_cdcooper IN crapceb.cdcooper%type
                         ,pr_nrconven IN crapceb.nrconven%type
                         ,pr_nrdconta IN crapceb.nrdconta%TYPE) IS
        SELECT crapceb.cdcooper
              ,crapceb.nrconven
              ,crapceb.nrcnvceb
              ,crapceb.nrdconta
              ,crapceb.flgcebhm
              ,crapceb.insitceb
        FROM crapceb
        WHERE  crapceb.cdcooper = pr_cdcooper
          AND  crapceb.nrconven = pr_nrconven
          AND  crapceb.nrdconta = pr_nrdconta;
      rw_crapceb1 cr_crapceb1%ROWTYPE;

      --Selecionar cadastro emissao bloquetos - conv 7 digitos
      CURSOR cr_crapceb2 (pr_cdcooper IN crapceb.cdcooper%type
                         ,pr_nrconven IN crapceb.nrconven%type
                         ,pr_nrcnvceb IN varchar2) IS
        SELECT crapceb.cdcooper
              ,crapceb.nrconven
              ,crapceb.nrcnvceb
              ,crapceb.nrdconta
        FROM crapceb
        WHERE  crapceb.cdcooper = pr_cdcooper
        AND    crapceb.nrconven = pr_nrconven
        AND    crapceb.nrcnvceb = pr_nrcnvceb;
      rw_crapceb2 cr_crapceb2%ROWTYPE;

      -- Verificar se cooperado entrou na cooperativa pela conta anterior
      CURSOR cr_craptco (pr_cdcooper IN craptco.cdcooper%type
                        ,pr_nrctaant IN craptco.nrctaant%TYPE
                        ,pr_flgativo IN craptco.flgativo%TYPE
                        ,pr_tpctatrf IN craptco.tpctatrf%type) IS
        SELECT craptco.nrdconta
        FROM craptco
        WHERE craptco.cdcooper = pr_cdcooper
        AND   craptco.nrctaant = pr_nrctaant
        AND   craptco.flgativo = pr_flgativo
        AND   craptco.tpctatrf <> pr_tpctatrf;
      rw_craptco cr_craptco%ROWTYPE;

      -- Verificar se cooperado saiu da cooperativa pela conta anterior
      CURSOR cr_craptco2(pr_cdcopant IN craptco.cdcopant%type
                        ,pr_nrctaant IN craptco.nrctaant%TYPE
                        ,pr_flgativo IN craptco.flgativo%TYPE
                        ,pr_tpctatrf IN craptco.tpctatrf%type) IS
        SELECT craptco.nrdconta
        FROM craptco
        WHERE craptco.cdcopant = pr_cdcopant
        AND   craptco.nrctaant = pr_nrctaant
        AND   craptco.flgativo = pr_flgativo
        AND   craptco.tpctatrf <> pr_tpctatrf;
      rw_craptco2 cr_craptco2%ROWTYPE;

      -- Verificar se cooperado entrou na cooperativa pela conta nova
      CURSOR cr_craptco3 (pr_cdcooper IN craptco.cdcooper%type
                        ,pr_nrdconta IN craptco.nrctaant%TYPE
                        ,pr_flgativo IN craptco.flgativo%TYPE
                        ,pr_tpctatrf IN craptco.tpctatrf%type) IS
        SELECT craptco.nrdconta
        FROM craptco
        WHERE craptco.cdcooper = pr_cdcooper
        AND   craptco.nrdconta = pr_nrdconta
        AND   craptco.flgativo = pr_flgativo
        AND   craptco.tpctatrf <> pr_tpctatrf;
      rw_craptco3 cr_craptco3%ROWTYPE;


      --Selecionar informacoes cobranca
      CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%type
                        ,pr_cdbandoc IN crapcob.cdbandoc%type
                        ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                        ,pr_nrdctabb IN crapcob.nrdctabb%type
                        ,pr_nrdocmto IN crapcob.nrdocmto%type
                        ,pr_nrdconta IN crapcob.nrdconta%type) IS
        SELECT crapcob.cdbandoc
              ,crapcob.cdcooper
              ,crapcob.nrcnvcob
              ,crapcob.nrdconta
              ,crapcob.nrdocmto
              ,crapcob.incobran
              ,crapcob.dtretcob
              ,crapcob.nrdctabb
        FROM crapcob
        WHERE crapcob.cdcooper = pr_cdcooper
        AND   crapcob.cdbandoc = pr_cdbandoc
        AND   crapcob.nrcnvcob = pr_nrcnvcob
        AND   crapcob.nrdctabb = pr_nrdctabb
        AND   crapcob.nrdocmto = pr_nrdocmto
        AND   crapcob.nrdconta = pr_nrdconta;
      rw_crapcob cr_crapcob%ROWTYPE;

      --Variaveis Locais
      vr_banco        INTEGER;
      vr_convenio     INTEGER;
      vr_convenio1    NUMBER;
      vr_convenio2    NUMBER;
      vr_bloqueto     NUMBER;
      vr_bloqueto1    NUMBER;
      vr_bloqueto2    NUMBER;
      vr_nrdconta     INTEGER;
      vr_nrdconta1    INTEGER;
      vr_nrconvceb    INTEGER;
      --Variaveis Excecao
      vr_exc_saida EXCEPTION;

    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      
      -- Inicializar variavel com 0 - "Outra Cooperativa / Outra IF"
      pr_intitcop:= 0; 
      
      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;
      
      --Quebrar o codigo de barras
      vr_banco:= TO_NUMBER(SUBSTR(pr_codbarra, 1, 3));
      vr_convenio1:= TO_NUMBER(SUBSTR(pr_codbarra, 20, 6));  -- Conv 6 digitos
      vr_convenio2:= TO_NUMBER(SUBSTR(pr_codbarra, 26, 7));  -- Conv 7 digitos
      vr_nrconvceb:= TO_NUMBER(SUBSTR(pr_codbarra, 33, 4));  -- CEB
      vr_nrdconta1:= TO_NUMBER(SUBSTR(pr_codbarra, 26, 8));  -- Conta 6 digitos
      vr_bloqueto1:= TO_NUMBER(SUBSTR(pr_codbarra, 34, 9));  -- Boleto 6 digitos
      vr_bloqueto2:= TO_NUMBER(SUBSTR(pr_codbarra, 37, 6));  -- Boleto 7 digitos

      --Se for banco brasil
      IF vr_banco = 1 THEN
        --Selecionar convenio 6 digitos
        OPEN cr_crapcco (pr_cdcooper  => rw_crapcop.cdcooper
                        ,pr_nrconven  => vr_convenio1);
        --Posicionar no primeiro registro
        FETCH cr_crapcco INTO rw_crapcco;
        --Se encontrou convenio 6 digitos
        IF cr_crapcco%FOUND THEN
          CLOSE cr_crapcco;
          -- se convenio BB com registro, entao Liq Interbancaria
          IF rw_crapcco.flgregis = 1 THEN
            RAISE vr_exc_saida;
          END IF;

          --Selecionar cadastro emissao bloquetos - conv 6 digitos
          OPEN cr_crapceb1 (pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_nrconven => rw_crapcco.nrconven
                           ,pr_nrdconta => vr_nrdconta1);
          --Posicionar no proximo registro
          FETCH cr_crapceb1 INTO rw_crapceb1;
          --Se Encontrou
          IF cr_crapceb1%FOUND THEN
            CLOSE cr_crapceb1;
            -- verificar se cooperado saiu da cooperativa
            OPEN cr_craptco2(pr_cdcopant => rw_crapcop.cdcooper
                            ,pr_nrctaant => vr_nrdconta1
                            ,pr_flgativo => 1
                            ,pr_tpctatrf => 3);
            FETCH cr_craptco2 INTO rw_craptco2;
            -- se encontrou, entao cooperado saiu e eh Liq Interbancaria
            IF cr_craptco2%FOUND THEN
              CLOSE cr_craptco2;
              RAISE vr_exc_saida;
            ELSE
              vr_nrdconta := vr_nrdconta1;
              vr_bloqueto := vr_bloqueto1;
              IF cr_craptco2%ISOPEN THEN
                CLOSE cr_craptco2;
              END IF;
            END IF;
          ELSE
            IF cr_crapceb1%ISOPEN THEN
              CLOSE cr_crapceb1;
            END IF;

            --Selecionar de qual cooperativa o convenio pertencia
            OPEN cr_ceb_ant(pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_nrdconta => vr_nrdconta1
                           ,pr_nrconven => vr_convenio1);
            FETCH cr_ceb_ant INTO rw_ceb_ant;

            IF cr_ceb_ant%FOUND THEN
              CLOSE cr_ceb_ant;
              -- verificar se cooperado entrou na cooperativa 
              IF rw_ceb_ant.tco_cdcooper = rw_crapcop.cdcooper THEN
                -- Selecionar cadastro emissao bloquetos - conv 6 digitos
                OPEN cr_crapceb1 (pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_nrconven => rw_crapcco.nrconven
                                 ,pr_nrdconta => rw_ceb_ant.tco_nrdconta);
                --Posicionar no proximo registro
                FETCH cr_crapceb1 INTO rw_crapceb1;
                IF cr_crapceb1%FOUND THEN
                  CLOSE cr_crapceb1;
                  vr_nrdconta := rw_ceb_ant.tco_nrdconta;
                  vr_bloqueto := vr_bloqueto1;
                ELSE
                  IF cr_crapceb1%ISOPEN THEN
                    CLOSE cr_crapceb1;
                  END IF;
                  -- eh cooperado migrado e nao tem CEB, Liq Interbancaria
                  RAISE vr_exc_saida;
                END IF;
              ELSE
                -- não eh cooperado migrado e nao tem CEB, Liq Interbancaria
                RAISE vr_exc_saida;
              END IF;
            ELSE
              CLOSE cr_ceb_ant;
            END IF;
          END IF;
        ELSE
          -- verificar se eh convenio de 7 digitos
          IF cr_crapcco%ISOPEN THEN
            CLOSE cr_crapcco;
          END IF;

          --Selecionar convenio 7 digitos
          OPEN cr_crapcco (pr_cdcooper  => rw_crapcop.cdcooper
                          ,pr_nrconven  => vr_convenio2);
          --Posicionar no primeiro registro
          FETCH cr_crapcco INTO rw_crapcco;
          --Se encontrou convenio 7 digitos
          IF cr_crapcco%FOUND THEN
            CLOSE cr_crapcco;

            -- se convenio BB com registro, entao Liq Interbancaria
            IF rw_crapcco.flgregis = 1 THEN
              RAISE vr_exc_saida;
            END IF;

            --Selecionar cadastro emissao bloquetos - conv 7 digitos
            OPEN cr_crapceb2 (pr_cdcooper => rw_crapcop.cdcooper
                             ,pr_nrconven => rw_crapcco.nrconven
                             ,pr_nrcnvceb => vr_nrconvceb);
            --Posicionar no proximo registro
            FETCH cr_crapceb2 INTO rw_crapceb2;
            --Se Encontrou
            IF cr_crapceb2%FOUND THEN
              CLOSE cr_crapceb2;
              -- verificar se cooperado saiu da cooperativa
              OPEN cr_craptco2(pr_cdcopant => rw_crapcop.cdcooper
                              ,pr_nrctaant => rw_crapceb2.nrdconta
                              ,pr_flgativo => 1
                              ,pr_tpctatrf => 3);
              FETCH cr_craptco2 INTO rw_craptco2;
              -- se encontrou, entao cooperado saiu e eh Liq Interbancaria 
              IF cr_craptco2%FOUND THEN
                CLOSE cr_craptco2;
                RAISE vr_exc_saida;
              ELSE
                 vr_nrdconta := rw_crapceb2.nrdconta;
                 vr_bloqueto := vr_bloqueto2;
                 IF cr_craptco2%ISOPEN THEN
                   CLOSE cr_craptco2;
                 END IF;
              END IF;
            ELSE
              IF cr_crapceb2%ISOPEN THEN
                CLOSE cr_crapceb2;
              END IF;

              -- verificar se cooperado entrou na cooperativa pela conta nova
              OPEN cr_craptco3(pr_cdcooper => rw_crapcop.cdcooper
                              ,pr_nrdconta => rw_crapceb2.nrdconta
                              ,pr_flgativo => 1
                              ,pr_tpctatrf => 3);
              FETCH cr_craptco3 INTO rw_craptco3;
              -- se encontrou, entao cooperado saiu e eh Liq Interbancaria 
              IF cr_craptco3%FOUND THEN
                vr_nrdconta := rw_craptco3.nrdconta;
                vr_bloqueto := vr_bloqueto2;
                IF cr_craptco3%ISOPEN THEN
                  CLOSE cr_craptco3;
                END IF;
              ELSE
                IF cr_craptco3%ISOPEN THEN
                  CLOSE cr_craptco3;
                END IF;
                -- nao tem CEB, entao eh Liq Interbancaria
                RAISE vr_exc_saida;
              END IF;
            END IF;
          ELSE
            -- convenio nao encontrado
            --Fechar Cursores
            IF cr_crapcco%ISOPEN THEN
              CLOSE cr_crapcco;
            END IF;
            RAISE vr_exc_saida;
          END IF;
        END IF;

        --se nao encontrou bloqueto ou conta, sair
        IF nvl(vr_bloqueto,0) = 0 OR
           nvl(vr_nrdconta,0) = 0 THEN
          RAISE vr_exc_saida;
        END IF;

        --Selecionar informacoes cobranca
        OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_cdbandoc => rw_crapcco.cddbanco
                        ,pr_nrcnvcob => rw_crapcco.nrconven
                        ,pr_nrdctabb => rw_crapcco.nrdctabb
                        ,pr_nrdocmto => vr_bloqueto
                        ,pr_nrdconta => vr_nrdconta);
        --Posicionar no proximo registro
        FETCH cr_crapcob INTO rw_crapcob;
        --Se nao encontrar
        IF cr_crapcob%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapcob;

          IF rw_crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE' THEN
            -- Realizava o INSERT do boleto
            pr_intitcop:= 1;
          ELSE
            IF rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
              -- verificar se o convenio migrado eh 'IMPRESSO PELO SOFTWARE'
              OPEN cr_cco_impresso( pr_nrconven => rw_crapcco.nrconven );
              FETCH cr_cco_impresso INTO rw_cco_impresso;
              -- se o convenio existir, entao criar boleto crapcob
              IF cr_cco_impresso%FOUND THEN
                -- Realizava o INSERT do boleto
                pr_intitcop:= 1;
              ELSE
                IF cr_cco_impresso%ISOPEN THEN
                  CLOSE cr_cco_impresso;
                END IF;
                RAISE vr_exc_saida;
              END IF; -- cco_impresso%found
            END IF; -- 'MIGRACAO,INCORPORACAO'
          END IF; -- 'IMPRESSO PELO SOFTWARE'
        END IF; -- cr_crapcob%NOTFOUND

        --Valores de retorno
        pr_intitcop:= 1;

        --Fechar Cursor
        IF cr_crapcco%ISOPEN THEN
          CLOSE cr_crapcco;
        END IF;

        --Fechar Cursor
        IF cr_crapcob%ISOPEN THEN
          CLOSE cr_crapcob;
        END IF;

      ELSIF vr_banco = rw_crapcop.cdbcoctl  THEN /* CECRED */

        vr_nrdconta := vr_nrdconta1;
        vr_bloqueto := vr_bloqueto1;
        vr_convenio := vr_convenio1;

        --Selecionar informacoes cadastro cobranca
        OPEN cr_crapcco (pr_cdcooper  => rw_crapcop.cdcooper
                        ,pr_nrconven  => vr_convenio);
        --Posicionar no primeiro registro
        FETCH cr_crapcco INTO rw_crapcco;
        --Se encontrou
        IF cr_crapcco%FOUND THEN
          IF rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
            OPEN cr_ceb_ant(pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_nrdconta => vr_nrdconta
                           ,pr_nrconven => vr_convenio);
            FETCH cr_ceb_ant INTO rw_ceb_ant;

            IF cr_ceb_ant%FOUND THEN
              CLOSE cr_ceb_ant;
              IF rw_ceb_ant.tco_cdcooper = rw_crapcop.cdcooper THEN
                vr_nrdconta := rw_ceb_ant.tco_nrdconta;
              ELSE
                -- não eh cooperado migrado, Liq Interbancaria
                --Fechar Cursores
                RAISE vr_exc_saida;
              END IF;
            ELSE
              CLOSE cr_ceb_ant;
            END IF;
          END IF;

          --Selecionar cadastro emissao bloquetos
          OPEN cr_crapceb1 (pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_nrconven => rw_crapcco.nrconven
                           ,pr_nrdconta => vr_nrdconta);
          --Posicionar no proximo registro
          FETCH cr_crapceb1 INTO rw_crapceb1;
          IF cr_crapceb1%FOUND THEN
            CLOSE cr_crapceb1;

            -- verificar se cooperado saiu da cooperativa 
            OPEN cr_craptco2( pr_cdcopant => rw_crapcop.cdcooper
                             ,pr_nrctaant => vr_nrdconta
                             ,pr_flgativo => 1
                             ,pr_tpctatrf => 3);
            FETCH cr_craptco2 INTO rw_craptco2;
            -- se encontrou, entao cooperado saiu e eh Liq Interbancaria 
            IF cr_craptco2%FOUND THEN
              CLOSE cr_craptco2;
              RAISE vr_exc_saida;
            ELSE
              vr_nrdconta := rw_crapceb1.nrdconta;
            END IF;
          ELSE
            
            IF cr_crapceb1%ISOPEN THEN
              CLOSE cr_crapceb1;
            END IF;

            -- verificar se cooperado migrado entrou na cooperativa pela conta anterior 
            OPEN cr_craptco (pr_cdcooper => rw_crapcop.cdcooper
                            ,pr_nrctaant => vr_nrdconta
                            ,pr_flgativo => 1
                            ,pr_tpctatrf => 3);
            --Posicionar no proximo registro
            FETCH cr_craptco INTO rw_craptco;
            --Se nao encontrar
            IF cr_craptco%FOUND THEN
              CLOSE cr_craptco;
              --Selecionar cadastro emissao bloquetos - conv 6 digitos
              OPEN cr_crapceb1 (pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_nrconven => rw_crapcco.nrconven
                               ,pr_nrdconta => rw_craptco.nrdconta);
              --Posicionar no proximo registro
              FETCH cr_crapceb1 INTO rw_crapceb1;
              IF cr_crapceb1%FOUND THEN
                CLOSE cr_crapceb1;
                vr_nrdconta := rw_craptco.nrdconta;
              ELSE
                IF cr_crapceb1%ISOPEN THEN
                  CLOSE cr_crapceb1;
                END IF;
                -- eh cooperado migrado e nao tem CEB, Liq Interbancaria
                RAISE vr_exc_saida;
              END IF;
            ELSE
              IF cr_craptco%ISOPEN THEN
                CLOSE cr_craptco;
              END IF;

              IF cr_crapceb1%ISOPEN THEN
                CLOSE cr_crapceb1;
              END IF;

              -- liq interbancaria (nesse caso, de outra cooperativa)
              RAISE vr_exc_saida;

            END IF; -- craptco%FOUND
          END IF; -- cr_crapceb1%FOUND

          --Selecionar informacoes cobranca
          OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_cdbandoc => rw_crapcco.cddbanco
                          ,pr_nrcnvcob => rw_crapcco.nrconven
                          ,pr_nrdctabb => rw_crapcco.nrdctabb
                          ,pr_nrdocmto => vr_bloqueto
                          ,pr_nrdconta => vr_nrdconta);
          --Posicionar no proximo registro
          FETCH cr_crapcob INTO rw_crapcob;

          --Se nao encontrar
          IF cr_crapcob%NOTFOUND THEN
             --Fechar Cursor
             CLOSE cr_crapcob;

             IF rw_crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE' THEN
               -- Realizava o INSERT do boleto
               pr_intitcop:= 1;
               
             ELSE -- 'IMPRESSO PELO SOFTWARE'

               IF rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN

                 OPEN cr_cco_impresso( pr_nrconven => rw_crapcco.nrconven );
                 FETCH cr_cco_impresso INTO rw_cco_impresso;

                 IF cr_cco_impresso%FOUND THEN
                   -- criar boleto
                   CLOSE cr_cco_impresso;

                   --Retornar valores
                   pr_intitcop:= 1;
                 ELSE
                   IF cr_cco_impresso%ISOPEN THEN
                     CLOSE cr_cco_impresso;
                   END IF;
                   -- convenio eh migrado mas nao eh 'IMPRESSO PELO SOFTWARE', entao Liq interbancaria
                   RAISE vr_exc_saida;
                 END IF;
               END IF; -- 'MIGRACAO,INCORPORACAO'

             END IF; -- 'IMPRESSO PELO SOFTWARE'

          ELSE -- cr_crapcob%NOTFOUND

            CLOSE cr_crapcob;
            --Retornar valores
            pr_intitcop:= 1;
          END IF; -- cr_crapcob%NOTFOUND
          --Fechar Cursor
          IF cr_crapcob%ISOPEN THEN
            CLOSE cr_crapcob;
          END IF;
        ELSE
          -- convenio 085 nao encontrado na cooperativa, Liq Interbancaria
          RAISE vr_exc_saida;
        END IF; -- crapcco%FOUND
      ELSE
        -- Liq Interbancaria
        RAISE vr_exc_saida;
      END IF; -- vr_banco = 1

    EXCEPTION
       WHEN vr_exc_saida THEN
         IF cr_crapcco%ISOPEN THEN CLOSE cr_crapcco; END IF;
         IF cr_crapceb1%ISOPEN THEN CLOSE cr_crapceb1; END IF;
         IF cr_crapceb2%ISOPEN THEN CLOSE cr_crapceb2; END IF;
         IF cr_craptco%ISOPEN THEN CLOSE cr_craptco; END IF;
         IF cr_craptco2%ISOPEN THEN CLOSE cr_craptco2; END IF;
         IF cr_craptco3%ISOPEN THEN CLOSE cr_craptco3; END IF;
         IF cr_crapcob%ISOPEN THEN CLOSE cr_crapcob; END IF;
         IF cr_ceb_ant%ISOPEN THEN CLOSE cr_ceb_ant; END IF;
       WHEN OTHERS THEN
         IF cr_crapcco%ISOPEN THEN CLOSE cr_crapcco; END IF;
         IF cr_crapceb1%ISOPEN THEN CLOSE cr_crapceb1; END IF;
         IF cr_crapceb2%ISOPEN THEN CLOSE cr_crapceb2; END IF;
         IF cr_craptco%ISOPEN THEN CLOSE cr_craptco; END IF;
         IF cr_craptco2%ISOPEN THEN CLOSE cr_craptco2; END IF;
         IF cr_craptco3%ISOPEN THEN CLOSE cr_craptco3; END IF;
         IF cr_crapcob%ISOPEN THEN CLOSE cr_crapcob; END IF;
         IF cr_ceb_ant%ISOPEN THEN CLOSE cr_ceb_ant; END IF;
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina PGTA0001.pc_identifica_interbancario. '||SQLERRM;
    END;
  END pc_identifica_interbancario;

  /*Procedure copiada do CRPS594 10/03/2017*/
  PROCEDURE pc_verifica_vencimento_titulo (pr_cdcooper IN crapcob.cdcooper%TYPE        --Código da cooperativa
                                          ,pr_dtvencto IN crapcob.dtvencto%TYPE        --Data Vencimento
                                          ,pr_flgvenci OUT BOOLEAN                     --Vencido = true
                                          ,pr_cdcritic OUT INTEGER                     --Codigo da Critica
                                          ,pr_dscritic OUT VARCHAR2) IS                --Descricao do erro     
  BEGIN
    DECLARE
      vr_dtdiautil DATE;
      rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
    BEGIN
      --Inicializar Variaveis Erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      -- Busca a data do movimento
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
          
      --Inicializar Retorno
      pr_flgvenci:= FALSE;
          
      /** Pagamento no dia **/
      IF pr_dtvencto > rw_crapdat.dtmvtocd  OR  rw_crapdat.dtmvtoan < pr_dtvencto THEN
        RETURN;
      END IF;
          
      --Inicializar Retorno
      pr_flgvenci:= TRUE;
            
      /** Tratamento para permitir pagamento no primeiro dia util do **/
      /** ano de titulos vencidos no ultimo dia util do ano anterior **/
          
      IF to_number(to_char(rw_crapdat.dtmvtoan,'YYYY')) <> to_number(to_char(rw_crapdat.dtmvtocd,'YYYY')) THEN
        --Dia Util
        vr_dtdiautil:= to_date('3112'||to_char(rw_crapdat.dtmvtoan,'YYYY'),'DDMMYYYY');
        /** Se dia 31/12 for segunda-feira obtem data do sabado **/
        /** para aceitar vencidos do ultimo final de semana     **/
        IF to_number(to_char(vr_dtdiautil,'D')) IN (1,2) THEN
          --Dia Util
          vr_dtdiautil:= to_date('2912'||to_char(rw_crapdat.dtmvtoan,'YYYY'),'DDMMYYYY');
        ELSIF to_number(to_char(vr_dtdiautil,'D')) = 7 THEN  
          --Dia Util
          vr_dtdiautil:= to_date('3012'||to_char(rw_crapdat.dtmvtoan,'YYYY'),'DDMMYYYY');
        END IF;
        /** Verifica se pode aceitar o titulo vencido **/
        IF  pr_dtvencto >= vr_dtdiautil THEN 
           --Nao Criticar
           pr_flgvenci:= FALSE; 
        END IF;  
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina pc_verifica_vencimento_titulo. '||sqlerrm;
    END;    
  END pc_verifica_vencimento_titulo;

  -- Procedure para validar arquivo de pagamentos
  PROCEDURE pc_validar_arq_pgto  (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                 ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                 ,pr_nrconven      IN crapcpt.nrconven%TYPE  -- Numero do Convenio
                                 ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                 ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                 ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                 ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                 ,pr_nrremess     OUT craphpt.nrremret%TYPE
                                 ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                 ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro

  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : PGTA0001
    --  Sistema  : Rotinas genericas focando nas funcionalidades do pagamento por arquivo
    --  Sigla    : PGTA
    --  Autor    : Desconhecido (Nao colocou cabeçalho quando criou a procedure)
    --  Data     : Desconhecido                     Ultima atualizacao: 30/08/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que Chamado
    -- Objetivo  : Validar arquivo de pagamentos

    -- Alteracoes: 16/03/2017 - Ajustado a validacao para aceitar apenas o agendamento de titulos vencidos
    --                          que são emitidos e pagos na mesma cooperativa. Titulos vencidos de outros 
    --                          bancos ou outra cooperativa (liquidacao interbancaria) devem ser rejeitados
    --                        - Ajustado para quando a data de pagamento do titulo for anterior a data de 
    --                          movimento, assumir que a data de pagamento será a data de movimento    
    --                       (Douglas - Chamado 629635)
	--           
	--             21/03/2017 - Incluido DECODE para tratamento de inpessoa > 2 (Diego).
    --
    --             30/08/2017 - Adicionar validações das linhas do arquivo de agendamento de 
    --                          pagamento (Douglas - Melhoria 271.3)
    ---------------------------------------------------------------------------------------------------------------
  DECLARE

     -- CURSORES

     --Selecionar os dados da tabela de Associados
     CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
       SELECT crapass.nrdconta
             ,crapass.cdagenci
             ,crapass.nrcpfcgc
             --,crapass.inpessoa
			 ,DECODE(crapass.inpessoa,1,1,2,2,2) inpessoa
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

     -- Cursor para verificar Código de Barra em Duplicidade
     CURSOR cr_crapdpt (pr_cdcooper IN crapdpt.cdcooper%TYPE 
                       ,pr_nrdconta IN crapdpt.nrdconta%TYPE
                       ,pr_nrconven IN crapdpt.nrconven%TYPE
                       ,pr_nrremret IN crapdpt.nrremret%TYPE
                       ,pr_dscodbar IN crapdpt.dscodbar%TYPE) IS
       SELECT crapdpt.dscodbar
         FROM crapdpt crapdpt
        WHERE crapdpt.cdcooper = pr_cdcooper
          AND crapdpt.nrdconta = pr_nrdconta
          AND crapdpt.nrconven = pr_nrconven
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
     vr_utlfileh    VARCHAR2(4000);
     vr_origem_arq  VARCHAR2(4000);
     vr_destino_arq VARCHAR2(4000);

     -- Numero Remessa/Retorno
     vr_nrremret craphpt.nrremret%TYPE;

     -- Contador Registros Detalhe
     vr_contador NUMBER;
     vr_idlinha  INTEGER;

     -- Controle se Arquivo possui Trailer Arquivo e Lote
     vr_trailer_lot BOOLEAN;
     vr_trailer_arq BOOLEAN;
     vr_detalhe     BOOLEAN;
     vr_header_lot  BOOLEAN;
     vr_header_arq  BOOLEAN;

     vr_cdtipmvt crapdpt.cdtipmvt%TYPE;
     vr_cdocorre crapdpt.cdocorre%TYPE;
     vr_cdinsmvt crapdpt.cdinsmvt%TYPE;

     vr_nrseqarq NUMBER;

     vr_dscodbar VARCHAR2(100);
     vr_nmcedent VARCHAR2(100);
     vr_dtvencto DATE;
     vr_flgvenci BOOLEAN;
     vr_vltitulo NUMBER;
     vr_vldescto NUMBER;
     vr_vlacresc NUMBER;
     vr_dtdpagto DATE;
     vr_vldpagto NUMBER;
     vr_dsusoemp VARCHAR2(20);
     vr_dsnosnum VARCHAR2(20);
     vr_dtmvtopg DATE;
     vr_dtmvtolt DATE;

     -- Identificador do titulo da cooperativa 
     vr_intitcop INTEGER;

     -- Tabela erros identificados durante o processamento do arquivo
     vr_tab_err_arq PGTA0001.typ_tab_err_arq_agend;
     
  BEGIN
     vr_nmarquiv := pr_nmarquiv;

     vr_nrseqarq := 0;
     vr_contador := 0;

     vr_trailer_lot := FALSE;
     vr_trailer_arq := FALSE;
     vr_detalhe     := FALSE;
     vr_header_lot  := FALSE;
     vr_header_arq  := FALSE;
     
     OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
     FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
     -- Se não encontrar
     IF BTCH0001.cr_crapdat%NOTFOUND THEN
       -- Fechar o cursor pois haverá raise
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

     -- Define o diretório do arquivo
     vr_nmdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/upload') ;

     -- Abrir Arquivo de Remessa (.REM)
     GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto            --> Diretório do arquivo
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

       -- Zerar a posicao da linha
       vr_idlinha := 0;
       
       -- Limpar a tabela de erros 
       vr_tab_err_arq.DELETE;
       
       -- Percorrer as linhas do arquivo
       BEGIN
         LOOP
           vr_idlinha := vr_idlinha + 1;

           GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquivo
                                       ,pr_des_text => vr_des_linha);

           -- Ignorar as linhas em branco
           IF TRIM(vr_des_linha) IS NULL THEN
             CONTINUE;
           END IF;
           
           -- Tamanho da linha fora do padrão
           IF LENGTH(vr_des_linha) <> 241 THEN
             vr_des_erro := 'Tamanho da linha divergente do padrao CNAB240! Linha: ' || vr_idlinha;
             vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
           END IF;

           -- VALIDAÇÃO HEADER DO ARQUIVO
           -- ERROS NO HEADER SAEM POR RAISE: SIGNIFA ERRO NO ARQUIVO, NAO CONTINUAR.

           IF SUBSTR(vr_des_linha,08,01) = '0' THEN -- HEADER DO ARQUIVO

             -- Contador Registros Processados
             vr_contador := vr_contador + 1;

             -- Verifica se o cooperado esta cadastrada
             OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta);
             FETCH cr_crapass
              INTO rw_crapass;
             -- Se não encontrar
             IF cr_crapass%NOTFOUND THEN
               -- Fechar o cursor pois haverá raise
               CLOSE cr_crapass;
               vr_des_erro := 'Cooperado nao cadastrado: ' || pr_nrdconta;
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSE
               -- Apenas fechar o cursor
               CLOSE cr_crapass;
            END IF;

            -- Verifica se a cooperativa esta cadastrada
             OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
             FETCH cr_crapcop
              INTO rw_crapcop;
             -- Se não encontrar
             IF cr_crapcop%NOTFOUND THEN
               -- Fechar o cursor pois haverá raise
               CLOSE cr_crapcop;
               vr_des_erro := 'Cooperativa nao cadastrada: ' || pr_cdcooper;
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
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
             -- Se não encontrar
             IF cr_crapcpt%NOTFOUND THEN
               -- Fechar o cursor pois haverá raise
               CLOSE cr_crapcpt;
               vr_des_erro := 'Convenio nao Cadastrado: ' || pr_nrconven;
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSE
               -- Apenas fechar o cursor
               CLOSE cr_crapcpt;
             END IF;

             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,158,06)) = FALSE ) THEN
               vr_des_erro := 'Numero Sequencial do Arquivo Invalido: ' || SUBSTR(vr_des_linha,158,06);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
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
               -- Fechar o cursor pois haverá raise
               CLOSE cr_craphpt;
               vr_des_erro := 'Numero Sequencial do Arquivo já Processado: ' || vr_nrremret;
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSE
               -- Fechar o cursor
               CLOSE cr_craphpt;
             END IF;

             -- 01.0 Codigo do banco na compensacao
             IF SUBSTR(vr_des_linha,01,03) <> '085' THEN
               vr_des_erro := 'Banco de compensação do arquivo divergente do banco de'||
                              ' compensação do cooperado! - Header Arquivo : ' || 
                              SUBSTR(vr_des_linha,01,03);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- 02.0 Lote de Servico
             IF SUBSTR(vr_des_linha,04,04) <> '0000' THEN
               vr_des_erro := 'Lote de Servico no header do arquivo Invalido: '|| SUBSTR(vr_des_linha,04,04);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- 03.0 Tipo de Registro
             IF SUBSTR(vr_des_linha,08,01) <> '0' THEN
               vr_des_erro := 'Tipo de Registro Invalido: ' || SUBSTR(vr_des_linha,08,01);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- 05.0 Tipo de Inscricao do Cooperado
             IF --SUBSTR(vr_des_linha,18,01) <> '1' AND   -- Pessoa Fisica
                SUBSTR(vr_des_linha,18,01) <> '2' THEN  -- Pessoa Juridica
               vr_des_erro := 'Tipo de Inscricao Invalida: ' || SUBSTR(vr_des_linha,18,01);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- 06.0 Numero de Inscricao do Cooperado
             IF ( GENE0002.fn_numerico(pr_vlrteste => TRIM(SUBSTR(vr_des_linha,19,14))) = FALSE ) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header Arquivo Invalido: ' || TRIM(SUBSTR(vr_des_linha,19,14));
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSIF rw_crapass.nrcpfcgc <> to_number(SUBSTR(vr_des_linha,19,14),'99999999999999') THEN
               vr_des_erro := 'CPF/CNPJ Informado Header Arquivo Invalido: ' || TRIM(SUBSTR(vr_des_linha,19,14));
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSIF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,18,01)) = FALSE ) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header Arquivo incompativel com Tipo Inscricao: ' || SUBSTR(vr_des_linha,18,01);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSIF rw_crapass.inpessoa <> to_number(SUBSTR(vr_des_linha,18,01)) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header Arquivo incompativel com Tipo Inscricao: ' || SUBSTR(vr_des_linha,18,01);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- 07.0 Código do Convênio no Banco
             IF ( GENE0002.fn_numerico(pr_vlrteste => TRIM(SUBSTR(vr_des_linha,33,20))) = FALSE ) THEN
                vr_des_erro := 'Codigo do Convenio Invalido: ' || TRIM(SUBSTR(vr_des_linha,33,20));
                vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSIF pr_nrconven <> to_number(SUBSTR(vr_des_linha,33,20)) THEN
                vr_des_erro := 'Codigo do Convenio Invalido: ' || TRIM(SUBSTR(vr_des_linha,33,20));
                vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSIF rw_crapcpt.flghomol = 0 THEN
                vr_des_erro := 'Convenio nao Homologado.';
                vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- 08.0 a 09.0 Agência Mantenedora da Conta
             IF ( GENE0002.fn_numerico(pr_vlrteste => trim(SUBSTR(vr_des_linha,53,05))) = FALSE ) THEN
               vr_des_erro := 'Agencia Mantenedora da Conta Invalida: ' || trim(SUBSTR(vr_des_linha,53,05));
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSIF to_number(SUBSTR(vr_des_linha,53,05)) <> rw_crapcop.cdagectl THEN
               vr_des_erro := 'Agencia Mantenedora da Conta Invalida: ' || trim(SUBSTR(vr_des_linha,53,05));
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- 10.0 a 11.0 Conta/DV
             IF ( GENE0002.fn_numerico(pr_vlrteste => TRIM(SUBSTR(vr_des_linha,59,13))) = FALSE ) THEN
               vr_des_erro := 'Conta/DV Header Arquivo Invalida: ' || TRIM(SUBSTR(vr_des_linha,59,13));
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSIF to_number(SUBSTR(vr_des_linha,59,13)) <> pr_nrdconta THEN
               vr_des_erro := 'Conta/DV Header Arquivo Invalida: ' || TRIM(SUBSTR(vr_des_linha,59,13));
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- 16.0 Codigo Remessa/Retorno
             IF SUBSTR(vr_des_linha,143,01) <> '1' THEN -- '1' = Remessa (Cliente -> Banco)
               vr_des_erro := 'Codigo de Remessa nao encontrado no segmento header do arquivo: ' || SUBSTR(vr_des_linha,143,01);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- 17.0 Data de Geracao de Arquivo
             IF ( GENE0002.fn_data(pr_vlrteste => SUBSTR(vr_des_linha,144,08)
                                  ,pr_formato  => 'DD/MM/RRRR') = FALSE ) THEN
               vr_des_erro := 'Data de geracao do arquivo fora do periodo permitido: ' || SUBSTR(vr_des_linha,144,08);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSE
               IF ( TO_DATE(SUBSTR(vr_des_linha,144,08), 'DD/MM/RRRR') > vr_dtmvtolt ) OR
                  ( TO_DATE(SUBSTR(vr_des_linha,144,08), 'DD/MM/RRRR') < (vr_dtmvtolt - 30)) THEN
                 vr_des_erro := 'Data de geracao do arquivo fora do periodo permitido: ' || TO_CHAR(TO_DATE(SUBSTR(vr_des_linha,144,08), 'DD/MM/RRRR'), 'DD/MM/RRRR') ;
                 vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
               END IF;
             END IF;

             -- Controle se arquivo possui Header de Arquivo
             vr_header_arq := TRUE;

           END IF; -- Header do Arquivo

           -- Incluir tratamento para garantir que arquivo tenha Header de Arquivo
           IF vr_header_arq = FALSE THEN
             vr_des_erro := 'Arquivo nao possui Header de Arquivo.';
             vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
           END IF;


           -- HEADER DO LOTE --
           -- ERROS NO HEADER LOTE SAEM POR RAISE: SIGNIFA ERRO NO ARQUIVO, NAO CONTINUAR.
           IF SUBSTR(vr_des_linha,08,01) = '1' THEN -- Header do Lote
             -- Inicializa Variaveis
             vr_contador := vr_contador + 1;

             -- 01.1 Codigo do banco na compensacao
             IF SUBSTR(vr_des_linha,01,03) <> '085' THEN
               vr_des_erro := 'Banco de compensação do arquivo divergente do banco de'||
                              ' compensação do cooperado! - Header Lote : ' || 
                              SUBSTR(vr_des_linha,01,03);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- Tipo de Operacao
			 IF  SUBSTR(vr_des_linha,09,01) != 'C' THEN
               vr_des_erro := 'Tipo de registro header do lote sem tipo de operação C:' || SUBSTR(vr_des_linha,09,01);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- 09.1 a 10.1  Numero de Inscricao do Cooperado
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,19,14)) = FALSE ) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header do Lote Invalido: ' || SUBSTR(vr_des_linha,19,14);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSIF rw_crapass.nrcpfcgc <> to_number(SUBSTR(vr_des_linha,19,14),'99999999999999') THEN
               vr_des_erro := 'CPF/CNPJ Informado Header do Lote Invalido: ' || SUBSTR(vr_des_linha,19,14);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSIF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,18,01)) = FALSE ) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header do Lote incompativel com Tipo Inscricao: '|| SUBSTR(vr_des_linha,18,01);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSIF rw_crapass.inpessoa <> to_number(SUBSTR(vr_des_linha,18,01)) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header do Lote incompativel com Tipo Inscricao: '|| SUBSTR(vr_des_linha,18,01);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- 14.1 a 15.1 Conta/DV
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,59,13)) = FALSE ) THEN
               vr_des_erro := 'Conta/DV Header do Lote Invalida: '|| SUBSTR(vr_des_linha,59,13);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSIF to_number(SUBSTR(vr_des_linha,59,13)) <> pr_nrdconta THEN
               vr_des_erro := 'Conta/DV Header do Lote Invalida: ' || SUBSTR(vr_des_linha,59,13);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- 12.1 Agência Mantenedora da Conta
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,53,05)) = FALSE ) THEN
               vr_des_erro := 'Agencia Mantenedora da Conta Invalida: ' || SUBSTR(vr_des_linha,53,05);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSIF to_number(SUBSTR(vr_des_linha,53,05)) <> rw_crapcop.cdagectl THEN
               vr_des_erro := 'Agencia Mantenedora da Conta Invalida: ' || SUBSTR(vr_des_linha,53,05);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- 11.1 Código do Convênio no Banco
             IF ( GENE0002.fn_numerico(pr_vlrteste => TRIM(SUBSTR(vr_des_linha,33,20))) = FALSE ) THEN
                vr_des_erro := 'Codigo do Convenio Header do Lote Invalida: '|| TRIM(SUBSTR(vr_des_linha,33,20));
                vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             ELSIF pr_nrconven <> to_number(SUBSTR(vr_des_linha,33,20)) THEN
                vr_des_erro := 'Codigo do Convenio Header do Lote Invalida: ' || TRIM(SUBSTR(vr_des_linha,33,20));
                vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- Controle se o Arquivo Possui Header de Lote
             vr_header_lot := TRUE;

           END IF;  -- Header do Lote

           -- Tratamento para garantir que arquivo tenha Header do Lote
           -- Utilizo contador para garantir que já validou Header de Arquivo
           IF vr_contador > 1 AND vr_header_lot = FALSE THEN
             vr_des_erro := 'Arquivo nao possui Header de Lote.';
             vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
           END IF;

           -- LINHA REGISTRO DETALHE
           -- EM CASO DE ERRO, DEVE GRAVAR LOG E CONTINUAR... NAO FAZ RAISE

           IF SUBSTR(vr_des_linha,08,01) = '3' THEN -- Registro Detalhe
             -- Existe linha de detalhe
             vr_detalhe := TRUE;

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
                  TRUNC(SYSDATE),
                  to_char(SYSDATE,'HH24MISS'),
                  1, -- Pendente
                  pr_cdoperad);
               EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                 vr_des_erro := 'Registro de cabecalho ja existente.';
                 vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
               WHEN OTHERS THEN
                 vr_des_erro := 'Erro ao inserir CRAPHPT(PGTA0001.pc_validar_arq_pgto): '||SQLERRM;
                 vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
               END;
             END IF;

             -- Inicializa Variaveis
             vr_dscodbar := NULL;
             vr_dtdpagto := NULL;
             vr_cdtipmvt := NULL;
             vr_cdocorre := NULL;
             vr_cdinsmvt := NULL;

             -- 06.3J Tipo de Movimento
             -- 0 = Indica INCLUSÃO
             -- 1 = Indica CONSULTA
             -- 2 = Indica SUSPENSÃO
             -- 3 = Indica ESTORNO (somente para retorno)
             -- 4 = Indica REATIVAÇÃO
             -- 5 = Indica ALTERAÇÃO
             -- 7 = Indica LIQUIDAÇAO
             -- 9 = Indica EXCLUSÃO
             IF SUBSTR(vr_des_linha,15,01) NOT IN ('0','9') THEN -- Neste momento, liberado apenas INCLUSAO ou EXCLUSAO
               -- ESTAVA --> ('0','1','2','4','5','7','9')
               vr_cdtipmvt := nvl(to_number(SUBSTR(vr_des_linha,15,01)),0);    -- G060
               vr_cdocorre := nvl(vr_cdocorre,'AJ'); --G059 -> 'AJ' = Tipo de Movimento Inválido
             ELSE
               vr_cdtipmvt := to_number(SUBSTR(vr_des_linha,15,01));
             END IF;

             -- 07.3J Tipo de Instrução p/ Movimento
             -- '00' = Inclusão de Registro Detalhe Liberado
             -- '99' = Exclusão do Registro Detalhe Incluído Anteriormente
             IF SUBSTR(vr_des_linha,16,02) NOT IN ('00','99') THEN -- Neste momento, liberado apenas INCLUSAO ou EXCLUSAO
                -- Estava --> ('00','09','10','11','17','19','23','25','27','33','40','99')
                vr_cdinsmvt := nvl(to_number(SUBSTR(vr_des_linha,16,02)),0); -- Pega o Codigo da Instrucao que veio no Arquivo
                vr_cdocorre := nvl(vr_cdocorre,'HK'); -- G059 -> 'HK' = Codigo de Remessa/Retorno invalido
             ELSE
               	vr_cdinsmvt := to_number(SUBSTR(vr_des_linha,16,02)); -- Pega o Codigo da Instrucao que veio no Arquivo
             END IF;

             -- Tipo de Operacao 'J'
             IF SUBSTR(vr_des_linha,14,01) != 'J' THEN
               vr_cdocorre := nvl(vr_cdocorre,'AI'); -- G059 -> 'AI' = Código de Segmento de Detalhe Inválido
             END IF;

             -- 08.3J Código Barras
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,18,44)) = FALSE ) THEN
               -- (21,06) Codigo da Finalidade Invalido
               --vr_cdtipmvt := nvl(vr_cdtipmvt,0);    -- G060
               vr_dscodbar := NVL(SUBSTR(vr_des_linha,18,44),0);
               vr_cdocorre := nvl(vr_cdocorre,'CC'); -- G059 -> 'CC' = Codigo de Barras - Digito Verificador invalido
             ELSE
               vr_dscodbar:= SUBSTR(vr_des_linha,18,44);
             END IF;

             IF TRIM(vr_dscodbar) IS NOT NULL THEN
               -- Verifica se Código de Barra já esta no Arquivo
               OPEN cr_crapdpt(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrconven => pr_nrconven
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
                vr_cdocorre := nvl(vr_cdocorre,'AP');  -- G059 - 'AP' = Data Lançamento Inválido
             ELSE

               -- Verificar se o titulo está vencido
               vr_dtvencto := to_date(SUBSTR(vr_des_linha,92,08),'DD/MM/RRRR');
               pc_verifica_vencimento_titulo (pr_cdcooper => pr_cdcooper
                                             ,pr_dtvencto => vr_dtvencto
                                             ,pr_flgvenci => vr_flgvenci
                                             ,pr_cdcritic => pr_cdcritic
                                             ,pr_dscritic => pr_dscritic);

               --se o título estiver vencido
               IF vr_flgvenci THEN
                 -- (21,13) Data do Vencimento Invalida
                 --vr_cdtipmvt := nvl(vr_cdtipmvt,0);     -- G060
                 
                 -- Identificar se o boleto em questao eh da cooperativa, ou eh interbancario
                 pc_identifica_interbancario(pr_cdcooper => pr_cdcooper -- Cooperativa
                                            ,pr_codbarra => vr_dscodbar -- Codigo Barras
                                            ,pr_intitcop => vr_intitcop -- Indicador titulo (1-Cooperativa / 0-Outra IF)
                                            ,pr_cdcritic => pr_cdcritic -- Codigo do erro
                                            ,pr_dscritic => pr_dscritic); -- Descricao do Erro
                 -- Verificar se o titulo eh da cooperativa
                 IF vr_intitcop <> 1 THEN
                   -- TITULO interbancario ou titulo de outra cooperativa singular
                   vr_cdocorre := nvl(vr_cdocorre,'0D');  -- G059 - '0D' = Agendamento Não Permitido Após o Vencimento
                 END IF;
                 
               END IF;

             END IF;

             -- 11.3J Valor do Titulo (Nominal)
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,100,15)) = FALSE ) THEN
                 -- (21,08) Valor do Titulo Invalido
                 --vr_cdtipmvt := nvl(vr_cdtipmvt,0);     -- G060
                 vr_vltitulo := 0; -- Nao tenho como pegar o conteudo dessa posicao e
                                   -- gravar numa variavel/tabela DPT - Tipos incompativeis
                 vr_cdocorre := nvl(vr_cdocorre,'CF');  -- G059 - 'CF' = Valor do Documento Inválido
             ELSE
                 vr_vltitulo := to_number(SUBSTR(vr_des_linha,100,15),'999999999999999') / 100;
             END IF;

             -- 12.3J Valor do Desconto + Abatimento
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,115,15)) = FALSE ) THEN
                -- (21,08) Valor do Desconto + Abatimento Invalido
                --vr_cdtipmvt := nvl(vr_cdtipmvt,0);     -- G060
                vr_vldescto := 0; -- Nao tenho como pegar o conteudo dessa posicao e
                                  -- gravar numa variavel/tabela DPT - Tipos incompativeis
                vr_cdocorre := nvl(vr_cdocorre,'CH');  -- G059 - 'CH' = Valor de Desconto Inválido
             ELSE
               vr_vldescto := to_number(SUBSTR(vr_des_linha,115,15),'999999999999999') / 100;
             END IF;

             -- 13.3J Valor da Mora + Multa
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,130,15)) = FALSE ) THEN
                -- (21,08) Valor do Desconto + Abatimento Invalido
                --vr_cdtipmvt := nvl(vr_cdtipmvt,0);     -- G060
                vr_vlacresc := 0; -- Nao tenho como pegar o conteudo dessa posicao e
                                  -- gravar numa variavel/tabela DPT - Tipos incompativeis
                vr_cdocorre := nvl(vr_cdocorre,'CI');  -- G059 - 'CI' = Valor de Mora Inválido
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
                vr_cdocorre := nvl(vr_cdocorre,'AP');  -- G059 - 'AP' = Data Lançamento Inválido
             ELSE

               -- Se a data de pagamento do titulo for anterior a data de movimento,
               -- deve-se assumir que a data de pagamento será a data de movimento
               vr_dtdpagto := to_date(SUBSTR(vr_des_linha,145,08),'DD/MM/RRRR');
               IF ( to_date(SUBSTR(vr_des_linha,145,08),'DD/MM/RRRR') < vr_dtmvtolt ) THEN
                 vr_dtdpagto := vr_dtmvtolt;
               END IF;
             END IF;

             -- 15.3J Valor do Pagamento
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,153,15)) = FALSE ) THEN
               -- (21,08) Valor do Pagamento Invalido
               --vr_cdtipmvt := nvl(vr_cdtipmvt,0);     -- G060
               vr_vldpagto := 0; -- Nao tenho como pegar o conteudo dessa posicao e
                                 -- gravar numa variavel/tabela DPT - Tipos incompativeis
               vr_cdocorre := nvl(vr_cdocorre,'AR');  -- G059 - 'AR' = Valor do Lançamento Inválido
             ELSE
               vr_vldpagto := to_number(SUBSTR(vr_des_linha,153,15),'999999999999999') / 100;
             END IF;

             -- 16.3J Quantidade da Moeda
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,168,05)) = FALSE ) THEN
               -- (21,08) Quantidade da Moeda Invalido
               --vr_cdtipmvt := nvl(vr_cdtipmvt,0);    -- G060
               vr_cdocorre := nvl(vr_cdocorre,'AQ'); -- G059 - 'AQ' = Tipo/Quantidade da Moeda Inválido
             END IF;

             -- 17.3J Numero Atribuido pelo Cooperado
             vr_dsusoemp := SUBSTR(vr_des_linha,183,20);
             
             -- 18.3J Nosso Numero
             vr_dsnosnum := SUBSTR(vr_des_linha,203,20);

             -- 19.3J Código da Moeda
             IF ( GENE0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,223,02)) = FALSE ) THEN
               -- (21,08) Código da Moeda Invalido
               --vr_cdtipmvt := nvl(vr_cdtipmvt,0);    -- G060
               vr_cdocorre := nvl(vr_cdocorre,'AQ'); -- G059 - 'AQ' = Tipo/Quantidade da Moeda Inválido
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


             -- Caso não tenha error assume como Inclusão Efetuada
             vr_cdtipmvt := nvl(vr_cdtipmvt,0);    -- G060 - 0' = Indica INCLUSÃO
             vr_cdocorre := nvl(vr_cdocorre,'BD'); -- G059 - 'BD'= Inclusão Efetuada com Sucesso
             vr_cdinsmvt := nvl(vr_cdinsmvt,0);    -- G061 - '00' = Inclusão de Registro Detalhe Liberado

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
                vr_cdtipmvt, -- cdtipmvt -> 0-Indica INCLUSÃO (Aqui estava 1 *fixo )
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
             WHEN DUP_VAL_ON_INDEX THEN
               vr_des_erro := 'Registro de titulo ja existente. SEQ: '
                              || vr_nrseqarq || ' COD.BAR.:' || vr_dscodbar;
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;               
             WHEN OTHERS THEN
               vr_des_erro := 'Erro ao inserir CRAPDPT(PGTA0001.pc_validar_arq_pgto): '||SQLERRM || ' SEQ: '
                              || vr_nrseqarq || ' COD.BAR.:' || vr_dscodbar;
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END;


           END IF; -- FIM REGISTRO DETALHE



           IF SUBSTR(vr_des_linha,08,01) = '5' THEN -- Trailer de Lote
             vr_trailer_lot := TRUE;

             -- 01.5 Codigo do banco na compensacao
             IF SUBSTR(vr_des_linha,01,03) <> '085' THEN
               vr_des_erro := 'Banco de compensação do arquivo divergente do banco de'||
                              ' compensação do cooperado! - Trailer Lote : ' || 
                              SUBSTR(vr_des_linha,01,03);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

           END IF; -- TRAILER DE LOTE


           IF SUBSTR(vr_des_linha,08,01) = '9' THEN -- Trailer de Arquivo
             vr_trailer_arq := TRUE;

             -- 01.9 Codigo do banco na compensacao
             IF SUBSTR(vr_des_linha,01,03) <> '085' THEN
               vr_des_erro := 'Banco de compensação do arquivo divergente do banco de'||
                              ' compensação do cooperado! - Trailer Arquivo : ' || 
                              SUBSTR(vr_des_linha,01,03);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;

             -- 02.9 Lote de Servico
             IF SUBSTR(vr_des_linha,04,04) <> '9999' THEN
               vr_des_erro := 'Lote de Servico no trailer do arquivo Invalido: '|| SUBSTR(vr_des_linha,04,04);
               vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
             END IF;
           END IF; -- TRAILER DE ARQUIVO


         END LOOP; -- Fim LOOP linhas do arquivo
       EXCEPTION
         WHEN no_data_found THEN
           -- Acabou a leitura
           NULL;
       END;

       -- Se o arquivo estiver aberto
       IF  utl_file.IS_OPEN(vr_ind_arquivo) THEN
         -- Fechar o arquivo
         GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo); --> Handle do arquivo aberto;
       END  IF;

       -- Caso não tenha Detalhe Rejeita Arquivo
       IF vr_detalhe = FALSE THEN
          vr_des_erro := 'Arquivo nao possui linha de Detalhe.';
          vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
       END IF;

       -- Caso não tenha Trailer de Lote Rejeita Arquivo
       IF vr_trailer_lot = FALSE THEN
          vr_des_erro := 'Arquivo nao possui Trailer de Lote.';
          vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
       END IF;

       -- Caso não tenha Trailer de Arquivo Rejeita Arquivo
       IF vr_trailer_arq = FALSE THEN
           vr_des_erro := 'Arquivo nao possui Trailer de Arquivo.';
           vr_tab_err_arq(vr_tab_err_arq.COUNT() + 1) := vr_des_erro;
       END IF;
       
       -- Verificar se houve erro nas validações do arquivo
       IF vr_tab_err_arq.COUNT > 0 THEN
         RAISE vr_exc_saida;
       END IF;
       
       -- Rotina para mover o arquivo processado para a pasta
       -- <cooperativa>/salvar

       -- Define o diretório do arquivo
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

     END IF; -- Arquivo Aberto
     
  EXCEPTION
     WHEN vr_exc_saida THEN
      -- Se o arquivo estiver aberto
      IF  utl_file.IS_OPEN(vr_ind_arquivo) THEN
        -- Fechar o arquivo
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo); --> Handle do arquivo aberto;
      END  IF;

        -- Rotina para gerar <arquivo> .LOG
        PGTA0001.pc_gerar_arq_log_pgto(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrconven => pr_nrconven
                                    ,pr_nrremret => vr_nrremret
                                      ,pr_nmarquiv => vr_nmarquiv
                                    ,pr_tab_err  => vr_tab_err_arq
                                      ,pr_cdcritic => pr_cdcritic
                                      ,pr_dscritic => pr_dscritic);

        -- Arquivo possui erros criticos, aborta processo de validação
        PGTA0001.pc_rejeitar_arq_pgto(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrconven => pr_nrconven
                                     ,pr_dtmvtolt => pr_dtmvtolt
                                     ,pr_nmarquiv => vr_nmarquiv
                                     ,pr_idorigem => pr_idorigem
                                     ,pr_cdoperad => pr_cdoperad
                                   ,pr_dsmsgrej => 'Houveram erros no processamento do arquivo ' || vr_nmarquiv
                                   ,pr_nrremret => vr_nrremret
                                     ,pr_cdcritic => pr_cdcritic
                                     ,pr_dscritic => pr_dscritic);

        -- Efetuar retorno do erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := 'Houveram erros no processamento do arquivo ' || vr_nmarquiv;

        -- Efetua Rollback
        --ROLLBACK; -- Nao efetuará ROLLBACK... sera controlado no CRPS689

     WHEN OTHERS THEN
        -- Fechar Handle do Arquivo Aberto
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

        -- Apenas retornar a variável de saida
        pr_cdcritic := 0;
        pr_dscritic := 'Erro PGTA0001.pc_validar_arq_pgto: ' || SQLERRM;

        -- Efetua Rollback
        --ROLLBACK; -- Nao efetuará ROLLBACK... sera controlado no CRPS689
  END;

  END pc_validar_arq_pgto;


  -- Procedure para processar o arquivo de remessa e gerar arquivo retorno
  PROCEDURE pc_processar_arq_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                  ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                  ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                  ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                  ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                  ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                  ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Operador
                                  ,pr_nrremess      IN craphpt.nrremret%TYPE  -- Numero da Remessa do Cooperado
                                  ,pr_nrremret     OUT craphpt.nrremret%TYPE  -- Numero Remessa/Retorno
                                  ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                  ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro

  ---------------------------------------------------------------------------------------------------------------
  --  Programa : PGTA0001
  --  Sistema  : Rotinas genericas focando nas funcionalidades do pagamento por arquivo
  --  Sigla    : PGTA
  --  Autor    : Desconhecido (Nao colocou cabeçalho quando criou a procedure)
  --  Data     : Desconhecido                     Ultima atualizacao: 03/12/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : 

  -- Alteracoes: 
  --
  -- 15/12/2017 - Com a eliminação das descrições fixas na PAGA0001
  --              Incluido codigo junto com a descrição em condição
  --              Quando todos programas gerarem codigo a descrição pode ser eliminada
  --              (Belli - Envolti - Chamado 779415)  
  --    
  -- 03/12/2018 - Quando a crítica da consulta na CIP é 940 ou 950
  --              deve ser retornada uma mensagem significativa para o cooperado.
  --              A mensagem retornada apontava erro no parse do xml.
  --              (AJFink - INC0027949)
  --
  ---------------------------------------------------------------------------------------------------------------
                                 
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
       CURSOR cr_craphpt(pr_cdcooper IN craphpt.cdcooper%TYPE     --> Código da cooperativa
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

       vr_cdcritic_aux crapcri.cdcritic%TYPE;
       vr_dscritic_aux VARCHAR2(4000);

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
       vr_idlancto INTEGER;

       -- variaveis NCP
       vr_nrdocbenf NUMBER;  
       vr_tppesbenf VARCHAR2(100); 
       vr_dsbenefic VARCHAR2(100); 
       vr_vlrtitulo NUMBER;       
       vr_cdctrlcs  VARCHAR2(100);  
       vr_tbtitulocip NPCB0001.typ_reg_titulocip;        
       vr_flblq_valor INTEGER;
       vr_flgtitven   INTEGER;
       vr_flcontig    NUMBER;

       vr_exc_critico EXCEPTION;

       vr_utlfileh    VARCHAR2(4000);
       vr_origem_arq  VARCHAR2(4000);
       vr_destino_arq VARCHAR2(4000);

       --Agrupa os parametros - 15/12/2017 - Chamado 779415 
       vr_dsparame VARCHAR2(4000);

       BEGIN
         -- Incluido nome do módulo logado - 15/12/2017 - Chamado 779415
         GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'PGTA0001.pc_processar_arq_pgto'); 
         
         --Ajuste mensagem de erro - 15/12/2017 - Chamado 779415
         vr_dsparame := 'pr_cdcooper:'   || pr_cdcooper || 
                        ' ,pr_nrdconta:' || pr_nrdconta || 
                        ' ,pr_nrconven:' || pr_nrconven || 
                        ' ,pr_nmarquiv:' || pr_nmarquiv ||
                        ' ,pr_dtmvtolt:' || pr_dtmvtolt || 
                        ' ,pr_idorigem:' || pr_idorigem || 
                        ' ,pr_cdoperad:' || pr_cdoperad || 
                        ' ,pr_nrremess:' || pr_nrremess;     
         
         OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
         FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
         -- Se não encontrar
         IF BTCH0001.cr_crapdat%NOTFOUND THEN
           -- Fechar o cursor pois haverá raise
           CLOSE BTCH0001.cr_crapdat;
           -- Ajuste mensagem de erro - 15/12/2017 - Chamado 779415
           -- Montar mensagem de critica
           vr_cdcritic := 1;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           RAISE vr_exc_critico;
         ELSE
           -- Apenas fechar o cursor
           CLOSE BTCH0001.cr_crapdat;
         END IF;
         
         vr_dtmvtolt := rw_crapdat.dtmvtolt;
       

         -- Gerar Informação de Retorno ao Cooperado (.RET)

         -- Buscar o Último Lote de Retorno do Cooperado
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
         -- Se não encontrar
         IF cr_crapass%NOTFOUND THEN
           -- Fechar o cursor pois haverá raise
           CLOSE cr_crapass;
           -- Ajuste mensagem de erro - 15/12/2017 - Chamado 779415
           -- Montar mensagem de critica
           vr_cdcritic := 9; -- Cooperado nao cadastrado
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           RAISE vr_exc_critico;
         ELSE
           -- Apenas fechar o cursor
           CLOSE cr_crapass;
        END IF;


         vr_nmarquiv := 'PGT_' || TRIM(to_char(pr_nrdconta,'00000000'))  || '_' ||
                                  TRIM(to_char(vr_nrremret,'000000000')) || '.RET';

         -- Criar Lote de Informações de Retorno (craphpt)
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
                TRUNC(SYSDATE),
                to_char(SYSDATE,'HH24MISS'),
                1, -- Pendente
                pr_cdoperad);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               -- Ajuste mensagem de erro - 15/12/2017 - Chamado 779415
               -- Montar mensagem de critica
               vr_cdcritic := 1140; -- Registro de cabecalho ja existente
               vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
               RAISE vr_exc_critico;
            WHEN OTHERS THEN
               -- No caso de erro de programa gravar tabela especifica de log - 15/12/2017 - Chamado 779415 
               CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
               -- Ajuste mensagem de erro - 15/12/2017 - Chamado 779415 
               vr_cdcritic := 1034;
               vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                              'craphpt:' || 
                              ' cdcooper:'  || pr_cdcooper || 
                              ' ,nrdconta:' || pr_nrdconta ||
                              ' ,nrconven:' || pr_nrconven || 
                              ' ,intipmvt:' || 2           ||
                              ' ,nrremret:' || vr_nrremret || 
                              ' ,dtmvtolt:' || pr_dtmvtolt ||
                              ' ,nmarquiv:' || vr_nmarquiv ||
                              ' ,idorigem:' || pr_idorigem ||
                              ' ,dtdgerac:' || TRUNC(SYSDATE) || 
                              ' ,hrdgerac:' || to_char(SYSDATE,'HH24MISS') ||
                              ' ,insithpt:' || 1           || 
                              ' ,cdoperad:' || pr_cdoperad ||
                              '. ' ||SQLERRM;
               --Levantar Excecao
               RAISE vr_exc_critico;
         END;

         -- Gravar Variavel de Saída com o Numero do Retorno
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
                                      ,pr_cdcritic => vr_cdcritic           --Código da critica
                                      ,pr_dscritic => vr_dscritic);         --Descricao critica
               -- Incluido nome do módulo logado - 15/12/2017 - Chamado 779415
               GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'PGTA0001.pc_processar_arq_pgto');
               -- Se deu algum erro na exclusao do agendamento

               IF TRIM(vr_dscritic) IS NOT NULL AND SUBSTR(vr_dscritic,01,01) = 'X' THEN
               -- Usado o pr_dscritic como retorno de sucesso em uma determinada situacao
                  vr_cdocorre := TRIM(vr_dscritic); -- Retornará 'X' mais um numero
               ELSE
                  IF NOT (NVL(vr_cdcritic,0) = 0 AND TRIM(vr_dscritic) IS NULL) THEN
                     -- Caso tenha dado algum erro...
                     vr_cdocorre := '90';   -- Fora G059 - 90 - Lançamento não encontrado
                     vr_dscritic := vr_dscritic || ' - CODBAR: ' || TO_CHAR(vr_dscodbar);

                     pgta0001.pc_gera_log_arq_pgto(pr_cdcooper => pr_cdcooper
                                                  ,pr_nrdconta => pr_nrdconta
                                                  ,pr_nrconven => pr_nrconven
                                                  ,pr_tpmovimento => 1 -- Movimento de REMESSA
                                                  ,pr_nrremret => pr_nrremess -- Numero da Remessa do Cooperado
                                                  ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                                  ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                                  ,pr_cdprograma => 'pc_processar_arq_pgto-can_agd'
                                                  ,pr_nmtabela => 'CRAPHPT'
                                                  ,pr_nmarquivo => pr_nmarquiv
                                                  ,pr_dsmsglog => vr_dscritic
                                                  ,pr_cdcritic => vr_cdcritic_aux
                                                  ,pr_dscritic => vr_dscritic_aux);
                     -- Incluido nome do módulo logado - 15/12/2017 - Chamado 779415
                     GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'PGTA0001.pc_processar_arq_pgto'); 

                     -- Envio centralizado de log de erro
                     pgta0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapdpt.cdcooper
                                                   ,pr_nrdconta => rw_crapdpt.nrdconta
                                                   ,pr_nmarquiv => 'PGTA0001.PC_CANCELAR_AGEND_PGTO'
                                                   ,pr_textolog => vr_dscritic
                                                   ,pr_cdcritic => vr_cdcritic_aux
                                                   ,pr_dscritic => vr_dscritic_aux);
                     -- Incluido nome do módulo logado - 15/12/2017 - Chamado 779415
                     GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'PGTA0001.pc_processar_arq_pgto'); 
                  ELSE
                    vr_cdocorre := 'BF';   -- G059 - 'BF' = Exclusão Efetuada com Sucesso
                  END IF;
               END IF;
            ELSE
              --Verificar titulo
              vr_lindigi1 := 0;
              vr_lindigi2 := 0;
              vr_lindigi3 := 0;
              vr_lindigi4 := 0;
              vr_lindigi5 := 0;

              -- Chamar a rotina de consulta dos dados      
              NPCB0002.pc_consultar_titulo_cip(pr_cdcooper      => pr_cdcooper 
                                              ,pr_nrdconta      => rw_crapdpt.nrdconta      
                                              ,pr_cdagenci      => 90
                                              ,pr_flmobile      => 0
                                              ,pr_dtmvtolt      => trunc(SYSDATE)
                                              ,pr_titulo1       => vr_lindigi1  
                                              ,pr_titulo2       => vr_lindigi2  
                                              ,pr_titulo3       => vr_lindigi3  
                                              ,pr_titulo4       => vr_lindigi4  
                                              ,pr_titulo5       => vr_lindigi5  
                                              ,pr_codigo_barras => vr_dscodbar  
                                              ,pr_cdoperad      => 996  
                                              ,pr_idorigem      => pr_idorigem     
                                              ,pr_nrdocbenf     => vr_nrdocbenf
                                              ,pr_tppesbenf     => vr_tppesbenf
                                              ,pr_dsbenefic     => vr_dsbenefic      
                                              ,pr_vlrtitulo     => vr_vlrtitulo      
                                              ,pr_vlrjuros      => vr_vlrjuros       
                                              ,pr_vlrmulta      => vr_vlrmulta       
                                              ,pr_vlrdescto     => vr_vldescto      
                                              ,pr_cdctrlcs      => vr_cdctrlcs       
                                              ,pr_tbtitulocip   => vr_tbtitulocip    
                                              ,pr_flblq_valor   => vr_flblq_valor    
                                              ,pr_fltitven      => vr_flgtitven
                                              ,pr_flcontig     => vr_flcontig
                                              ,pr_des_erro      => vr_des_erro       
                                              ,pr_cdcritic      => vr_cdcritic       
                                              ,pr_dscritic      => vr_dscritic);     
              -- Incluido nome do módulo logado - 15/12/2017 - Chamado 779415
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'PGTA0001.pc_processar_arq_pgto'); 
                                                   
              -- Se der erro não retorna informações   
              IF vr_des_erro = 'NOK' THEN
                --INC0027949
                if nvl(vr_cdcritic,0) = 940 then
                  vr_dscritic := 'Tempo de consulta excedido. Informe o titulo novamente.';
                elsif nvl(vr_cdcritic,0) = 950 then
                  vr_dscritic := 'Boleto nao registrado. Favor entrar em contato com o beneficiario.';
                end if;
              END IF;
              
              --> Validar apenas se nao encontrou erro
              IF nvl(vr_cdcritic,0) = 0 AND 
                 TRIM(vr_dscritic) IS NULL THEN
                 
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
			      	                      ,pr_flmobile => 0                     --Indicador mobile
                                            ,pr_cdctrlcs => vr_cdctrlcs           --Numero de controle de connsulta NPC
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
                -- Incluido nome do módulo logado - 15/12/2017 - Chamado 779415
                GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'PGTA0001.pc_processar_arq_pgto');
              
              END IF;
                                          
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
                                                   ,pr_nrconven => pr_nrconven
                                                   ,pr_nrremret => pr_nrremess
                                                   ,pr_nmarquiv => pr_nmarquiv
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
                                                 ,pr_vldocnto => rw_crapdpt.vltitulo
                                                 ,pr_cddbanco => 0
                                                 ,pr_cdageban => 0
                                                 ,pr_nrctadst => 0
                                                 ,pr_cdcoptfn => 0
                                                 ,pr_cdagetfn => 0
                                                 ,pr_nrterfin => 0
                                                 ,pr_nrcpfope => 0
                                                 ,pr_idtitdda => 0
                                                 ,pr_cdctrlcs => vr_cdctrlcs
                                                   ,pr_idlancto => vr_idlancto
                                                 ,pr_dstransa => vr_dstransa
                                                 ,pr_cdcritic => vr_cdcritic           --Código da critica
                                                 ,pr_dscritic => vr_dscritic);         --Descricao critica
                 -- Incluido nome do módulo logado - 15/12/2017 - Chamado 779415
                 GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'PGTA0001.pc_processar_arq_pgto');
                 -- Se deu algum erro na inclusao do agendamento
                 IF NOT (NVL(vr_cdcritic,0) = 0 AND TRIM(vr_dscritic) IS NULL) THEN
                    -- Caso tenha dado algum erro...
                    vr_cdocorre := '99';   -- Fora G059 - 99 - Erro ao cadastrar agendamento
                    vr_dscritic := vr_dscritic || ' - CODBAR: ' || TO_CHAR(vr_dscodbar);

                     pgta0001.pc_gera_log_arq_pgto(pr_cdcooper => pr_cdcooper
                                                  ,pr_nrdconta => pr_nrdconta
                                                  ,pr_nrconven => pr_nrconven
                                                  ,pr_tpmovimento => 1 -- Movimento de REMESSA
                                                  ,pr_nrremret => pr_nrremess -- Numero da Remessa do Cooperado
                                                  ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                                  ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                                  ,pr_cdprograma => 'pc_processar_arq_pgto-agd_tit'
                                                  ,pr_nmtabela => 'CRAPHPT'
                                                  ,pr_nmarquivo => pr_nmarquiv
                                                  ,pr_dsmsglog => vr_dscritic
                                                  ,pr_cdcritic => vr_cdcritic_aux
                                                  ,pr_dscritic => vr_dscritic_aux);
                     -- Incluido nome do módulo logado - 15/12/2017 - Chamado 779415
                     GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'PGTA0001.pc_processar_arq_pgto'); 

                    END IF;
                 END IF;
              ELSE
  -- Nova descrição utilizar somente codigo e incluir no proximo CASE - 15/12/2017 - Chamado 779415
                  CASE nvl(vr_dscritic,' ')
                   WHEN 'Data do agendamento deve ser um dia util.'     THEN vr_cdocorre := '0B';
                   WHEN 'Titulo vencido.'                               THEN vr_cdocorre := '0C';
                   WHEN 'Agendamento nao permitido apos vencimento.'    THEN vr_cdocorre := '0D';
                   WHEN 'Pagamento ja efetuado na cooperativa.'         THEN vr_cdocorre := '0E';
                   WHEN 'Agendamento ja existe.'                        THEN vr_cdocorre := '0F';
                   WHEN 'Banco nao encontrado.'                         THEN vr_cdocorre := '0G';
                   WHEN '008 - Digito errado.'                          THEN vr_cdocorre := 'CC';
                   WHEN 'Codigo de Barras invalido.'                    THEN vr_cdocorre := 'CC';
                   WHEN '057 - BANCO NAO CADASTRADO.'                   THEN vr_cdocorre := '0G';
                   WHEN '965 - Convenio do cooperado nao homologado'    THEN vr_cdocorre := '0H';
                   WHEN '966 - Cooperado sem convenio cadastrado'       THEN vr_cdocorre := '0I'; 
                   WHEN 'Valor nao permitido para agendamento.'         THEN vr_cdocorre := '0J'; /* VR Boleto */
                   WHEN '592 - Bloqueto nao encontrado.'                THEN vr_cdocorre := '0K'; /* bloqueto não encontrado */
                   WHEN '594 - Bloqueto ja processado.'                 THEN vr_cdocorre := '0L'; /* bloqueto já pago */
                   WHEN 'Dados incompativeis. Pagamento nao realizado!' THEN vr_cdocorre := '0M'; /* codigo de barras fraudulento */
                   ELSE vr_cdocorre := '99';
                 END CASE;
                 
                -- Incluido codigo - 15/12/2017 - Chamado 779415
                -- Quando todos programas gerarem codigo a descrição pode ser eliminada
                 IF vr_cdocorre = '99' THEN
                  CASE nvl(vr_cdcritic,0)
                   WHEN 1093 THEN vr_cdocorre := '0B'; -- Data do agendamento deve ser um dia util
                   WHEN 1105 THEN vr_cdocorre := '0C'; -- Titulo vencido
                   WHEN 1106 THEN vr_cdocorre := '0D'; -- Agendamento nao permitido apos vencimento
                   WHEN 1107 THEN vr_cdocorre := '0E'; -- Pagamento ja efetuado na cooperativa
                   WHEN 1109 THEN vr_cdocorre := '0F'; -- Agendamento ja existe
                   WHEN 0057 THEN vr_cdocorre := '0G'; -- Banco nao encontrado
                   WHEN 0008 THEN vr_cdocorre := 'CC'; -- Digito errado
                   WHEN 1096 THEN vr_cdocorre := 'CC'; -- Codigo de Barras invalido
                   WHEN 0965 THEN vr_cdocorre := '0H'; -- Convenio do cooperado nao homologado
                   WHEN 0966 THEN vr_cdocorre := '0I'; -- Cooperado sem convenio cadastrado
                   WHEN 0592 THEN vr_cdocorre := '0K'; -- Bloqueto nao encontrado
                   WHEN 0594 THEN vr_cdocorre := '0L'; -- Bloqueto ja processado
                   ELSE vr_cdocorre := '99';
                   END CASE;
                END IF;
                 
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

                 pgta0001.pc_gera_log_arq_pgto(pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => pr_nrdconta
                                              ,pr_nrconven => pr_nrconven
                                              ,pr_tpmovimento => 1 -- Movimento de REMESSA
                                              ,pr_nrremret => pr_nrremess -- Numero da Remessa do Cooperado
                                              ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                              ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                              ,pr_cdprograma => 'pc_processar_arq_pgto-ver_tit'
                                              ,pr_nmtabela => 'CRAPHPT'
                                              ,pr_nmarquivo => pr_nmarquiv
                                              ,pr_dsmsglog => vr_dscritic
                                              ,pr_cdcritic => vr_cdcritic_aux
                                              ,pr_dscritic => vr_dscritic_aux);
                 -- Incluido nome do módulo logado - 15/12/2017 - Chamado 779415
                 GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'PGTA0001.pc_processar_arq_pgto'); 

                 -- Envio centralizado de log de erro
                 pgta0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapdpt.cdcooper
                                               ,pr_nrdconta => rw_crapdpt.nrdconta
                                               ,pr_nmarquiv => 'PGTA0001->PC_VERIFICA_TITULO'
                                               ,pr_textolog => vr_dscritic
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
                 -- Incluido nome do módulo logado - 15/12/2017 - Chamado 779415
                 GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'PGTA0001.pc_processar_arq_pgto'); 
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
                 intipreg,
                 tpmvtorg,
                 nrmvtorg,
                 nrarqorg,
                 idlancto)
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
                 rw_crapdpt.intipreg,
                 rw_crapdpt.intipmvt,
                 rw_crapdpt.nrremret,
                 rw_crapdpt.nrseqarq,
                 vr_idlancto);

            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                 -- Ajuste mensagem de erro - 15/12/2017 - Chamado 779415
                 -- Montar mensagem de critica
                 vr_cdcritic := 1141; -- 'Registro de titulo ja existente
                 vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                 RAISE vr_exc_critico;                
               WHEN OTHERS THEN
                  -- No caso de erro de programa gravar tabela especifica de log - 15/12/2017 - Chamado 779415 
                  CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
                  -- Ajuste mensagem de erro - 15/12/2017 - Chamado 779415 
                  vr_cdcritic := 1034;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                'crapdpt:' || 
                                ' cdcooper:' || rw_crapdpt.cdcooper || 
                                ', nrdconta:' || rw_crapdpt.nrdconta ||
                                ', nrconven:' || rw_crapdpt.nrconven || 
                                ', intipmvt:' || 2                   ||
                                ', nrremret:' || vr_nrremret         || 
                                ', nrseqarq:' || rw_crapdpt.nrseqarq ||
                                ', cdtipmvt:' || rw_crapdpt.cdtipmvt ||
                                ', cdinsmvt:' || rw_crapdpt.cdinsmvt ||
                                ', dscodbar:' || rw_crapdpt.dscodbar || 
                                ', nmcedent:' || rw_crapdpt.nmcedent ||
                                ', dtvencto:' || rw_crapdpt.dtvencto || 
                                ', vltitulo:' || rw_crapdpt.vltitulo ||
                                ', vldescto:' || rw_crapdpt.vldescto || 
                                ', vlacresc:' || rw_crapdpt.vlacresc ||
                                ', dtdpagto:' || rw_crapdpt.dtdpagto || 
                                ', vldpagto:' || rw_crapdpt.vldpagto ||
                                ', dsusoemp:' || rw_crapdpt.dsusoemp || 
                                ', dsnosnum:' || rw_crapdpt.dsnosnum ||
                                ', cdocorre:' || vr_cdocorre         || 
                                ', dtmvtopg:' || rw_crapdpt.dtmvtopg ||
                                ', intipreg:' || rw_crapdpt.intipreg || 
                                ', tpmvtorg:' || rw_crapdpt.intipmvt ||
                                ', nrmvtorg:' || rw_crapdpt.nrremret || 
                                ', nrarqorg:' || rw_crapdpt.nrseqarq ||
                                ', idlancto:' || vr_idlancto         || 
                                '. ' ||SQLERRM;
                  --Levantar Excecao
                  RAISE vr_exc_critico;
            END;
            
            -- Atualizar crapdpt original com o mesmo IDLANCTO
            BEGIN
              UPDATE crapdpt dpt
                 SET dpt.idlancto = vr_idlancto
               WHERE dpt.nrseqarq = rw_crapdpt.nrseqarq
                 AND dpt.nrremret = rw_crapdpt.nrremret
                 AND dpt.intipmvt = rw_crapdpt.intipmvt
                 AND dpt.nrconven = rw_crapdpt.nrconven
                 AND dpt.nrdconta = rw_crapdpt.nrdconta
                 AND dpt.cdcooper = rw_crapdpt.cdcooper;
            EXCEPTION
               WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 15/12/2017 - Chamado 779415 
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
                -- Ajuste mensagem de erro - 15/12/2017 - Chamado 779415 
                vr_cdcritic := 1035;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                               'crapdpt:'    ||
                               ' idlancto:'  || vr_idlancto || 
                               ', nrseqarq:' || rw_crapdpt.nrseqarq ||
                               ', nrremret:' || rw_crapdpt.nrremret || 
                               ', intipmvt:' || rw_crapdpt.intipmvt ||
                               ', nrconven:' || rw_crapdpt.nrconven || 
                               ', nrdconta:' || rw_crapdpt.nrdconta ||
                               ', cdcooper:' || rw_crapdpt.cdcooper || 
                               '. ' ||SQLERRM;
                --Levantar Excecao
                  RAISE vr_exc_critico;
            END;

         END LOOP;

         -- OBSERVACAO:
         -- Se terminou de processasr os DPT, e nao ocorreu RAISE, limpa as variaveis de critica.
         -- Gerar o LOG de arquivo processado com sucesso
         PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrconven => pr_nrconven
                                      ,pr_tpmovimento => 1 -- Movimento de REMESSA
                                      ,pr_nrremret => pr_nrremess -- Numero da Remessa do Cooperado
                                      ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                      ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                      ,pr_cdprograma => 'pc_processar_arq_pgto'
                                      ,pr_nmtabela => 'CRAPHPT'
                                      ,pr_nmarquivo => pr_nmarquiv
                                      ,pr_dsmsglog => 'Arquivo importado com sucesso (Etapa 3 de 3)'
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);

         -- Nesse ponto, se as informacoes foram tratadas corretamente sem EXCEPTION,
         -- devem ser gravadas na base. Se retornar cdcritic ou dscritic, o chamador fará  o
         -- RAISE, e consequentemente, um ROLLBACK, perdendo as informações.
         vr_cdcritic := 0;
         vr_dscritic := '';

       -- Incluido nome do módulo logado - 15/12/2017 - Chamado 779415
       GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
     EXCEPTION
       --Ajuste mensagem de erro - 15/12/2017 - Chamado 779415 
       WHEN vr_exc_critico THEN
         -- Atualiza campo de erro
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic, vr_dscritic) ||
                       ' ' || vr_dsparame;
         -- Gerar o LOG do erro que aconteceu durante o processamento
         PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrconven => pr_nrconven
                                      ,pr_tpmovimento => 1 -- Movimento de REMESSA
                                      ,pr_nrremret => pr_nrremess -- Numero da Remessa do Cooperado
                                      ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                      ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                      ,pr_cdprograma => 'pc_processar_arq_pgto'
                                      ,pr_nmtabela => 'CRAPHPT'
                                      ,pr_nmarquivo => pr_nmarquiv
                                      ,pr_dsmsglog => pr_dscritic
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
         --ROLLBACK; -- Nao efetuará ROLLBACK... sera controlado no CRPS689
         -- Incluido nome do módulo logado - 15/12/2017 - Chamado 779415
         GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
       WHEN OTHERS THEN
         -- Atualiza campo de erro
         pr_cdcritic := 9999;
         pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       'PGTA0001.pc_processar_arq_pgto' || 
                       '. ' || sqlerrm ||
                       '. ' || vr_dsparame; 
         
         cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                     ,pr_compleme => pr_dscritic);
         
         -- Gerar o LOG do erro que aconteceu durante o processamento
         PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrconven => pr_nrconven
                                      ,pr_tpmovimento => 1 -- Movimento de REMESSA
                                      ,pr_nrremret => pr_nrremess -- Numero da Remessa do Cooperado
                                      ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                      ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                      ,pr_cdprograma => 'pc_processar_arq_pgto'
                                      ,pr_nmtabela => 'CRAPHPT'
                                      ,pr_nmarquivo => pr_nmarquiv
                                      ,pr_dsmsglog =>  pr_dscritic
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
         --ROLLBACK; -- Nao efetuará ROLLBACK... sera controlado no CRPS689
         -- Incluido nome do módulo logado - 15/12/2017 - Chamado 779415
         GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
     END;

     -- Salva Alterações Efetuadas
     -- COMMIT; -- Nao efetuará COMMIT... sera controlado no CRPS689

  END pc_processar_arq_pgto;
 

  -- Procedure para Cadastrar o agendamento do PAgamento do Titulo
  PROCEDURE pc_cadastrar_agend_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                    ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                    ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                    ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                    ,pr_nrconven      IN INTEGER                -- Numero do Convenio
                                    ,pr_nrremret      IN INTEGER                -- Numero da Remessa do Cooperado
                                    ,pr_nmarquiv      IN VARCHAR2               -- Nome do arquivo
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
                                    ,pr_vldocnto      IN crapdpt.vltitulo%TYPE
                                    ,pr_cddbanco      IN craplau.cddbanco%TYPE
                                    ,pr_cdageban      IN craplau.cdageban%TYPE
                                    ,pr_nrctadst      IN craplau.nrctadst%TYPE
                                    ,pr_cdcoptfn      IN craplau.cdcoptfn%TYPE
                                    ,pr_cdagetfn      IN craplau.cdagetfn%TYPE
                                    ,pr_nrterfin      IN craplau.nrterfin%TYPE
                                    ,pr_nrcpfope      IN craplau.nrcpfope%TYPE
                                    ,pr_idtitdda      IN craplau.idtitdda%TYPE
                                    ,pr_cdctrlcs      IN tbcobran_consulta_titulo.cdctrlcs%TYPE DEFAULT NULL --> Numero de controle da consulta no NPC
                                    ,pr_idlancto      OUT INTEGER   -- ID do lançamento
                                    ,pr_dstransa      OUT VARCHAR2
                                    ,pr_cdcritic      OUT INTEGER                -- Código do erro
                                    ,pr_dscritic      OUT VARCHAR2) IS
    BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : PGTA0001
    --  Sistema  : Rotinas genericas focando nas funcionalidades do pagamento por arquivo
    --  Sigla    : PGTA
    --  Autor    : Desconhecido (Nao colocou cabeçalho quando criou a procedure)
    --  Data     : Desconhecido                     Ultima atualizacao: 03/09/2018
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que Chamado
    -- Objetivo  : Cadastrar o agendamento do Pagamento do Titulo

    -- Alteracoes: 16/03/2017 - Ajustado a criacao do lote para gravar o codigo do PA (Douglas)
    --
    --             18/12/2017 - Efetuado alteração para controle de lock (Jonata - Mouts).
	-- 
	--             03/09/2018 - Correção para remover lote (Jonata - Mouts).
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

      -- CURSORES

      -- Busca dados da tabela de Associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nrdconta
              ,crapass.cdagenci
              ,crapass.nrcpfcgc
              ,crapass.inpessoa
              ,crapass.idastcjt
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
         AND crapcon.tparrecd <> 1; -- Diferente Sicredi

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
           AND craplot.nrdolote = pr_nrdolote
           FOR UPDATE NOWAIT;
      rw_craplot cr_craplot%ROWTYPE;

      vr_cdcritic_aux crapcri.cdcritic%TYPE;
      vr_dscritic_aux VARCHAR2(4000);

      vr_dslindig VARCHAR2(4000);

      vr_nrdolote NUMBER := 0;
      vr_cdtiptra NUMBER := 0;
      vr_cdtiptra NUMBER := 0;

      vr_tpdvalor NUMBER := 0;

      vr_nrcpfpre NUMBER := 0;
      vr_nrcpfcgc NUMBER := 0;
      vr_inpessoa NUMBER := 0;
      vr_idastcjt NUMBER := 0;

      vr_cdcoptfn NUMBER := 0;
      vr_cdagetfn NUMBER := 0;
      vr_nrterfin NUMBER := 0;
      vr_nrseqdig craplcm.nrseqdig%TYPE := 0;

      vr_nmprepos VARCHAR2(4000);

      vr_exc_saida     EXCEPTION;
      vr_erro_update   EXCEPTION;

      vr_dtmvtolt DATE;

      BEGIN
        
         OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
         FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
         -- Se não encontrar
         IF BTCH0001.cr_crapdat%NOTFOUND THEN
           -- Fechar o cursor pois haverá raise
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
         -- Se não encontrar
         IF cr_crapass%NOTFOUND THEN
           -- Fechar o cursor pois haverá raise
           CLOSE cr_crapass;
           vr_dscritic := 'Associado nao cadastrado.';
           RAISE vr_exc_saida;
         ELSE
           -- Apenas fechar o cursor
           vr_inpessoa := rw_crapass.inpessoa;
           vr_idastcjt := rw_crapass.idastcjt;
           CLOSE cr_crapass;
         END IF;


         IF pr_cdtiptra = 2  THEN -- Pagamento

            -- Monta numero do lote
            vr_nrdolote := 11000 + pr_nrdcaixa;
            vr_nrseqdig := fn_sequence('CRAPLOT'
                                      ,'NRSEQDIG'
                                      ,''||pr_cdcooper||';'
                                         ||to_char(pr_dtmvtolt,'DD/MM/RRRR')||';'
                                         ||pr_cdagenci||';'
                                         ||100||';'
                                         ||vr_nrdolote);  

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

               -- Verifica se é convenio Sicredi
               OPEN cr_crapcon(pr_cdcooper => pr_cdcooper
                              ,pr_cdempcon => to_number(SUBSTR(to_char(pr_lindigi2,'999999999999'),5,4))
                              ,pr_cdsegmto => to_number(SUBSTR(to_char(pr_lindigi1,'999999999999'),2,1)));
               -- Se não encontrar
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

         -- Tentar criar registro de lote ate 10 vezes
         -- senao abortar
         FOR i IN 1..10 LOOP
           vr_dscritic := NULL;

           BEGIN
             --> buscar lote
             OPEN cr_craplot (pr_cdcooper  => pr_cdcooper ,
                              pr_dtmvtolt  => pr_dtmvtolt ,
                              pr_cdagenci  => pr_cdagenci ,
                              pr_nrdolote  => vr_nrdolote );
         FETCH cr_craplot INTO rw_craplot;
         IF cr_craplot%NOTFOUND THEN
               CLOSE cr_craplot;
               -- se não localizou, deve criar o registro de lote
            BEGIN
               INSERT INTO craplot
                  (cdcooper,
                   cdagenci,
                   dtmvtolt,
                   cdbccxlt,
                   nrdolote,
                   nrdcaixa,
                   cdoperad,
                   cdopecxa,
                   tplotmov)
                   VALUES
                  (pr_cdcooper,
                   pr_cdagenci,
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
             ELSE
         CLOSE cr_craplot;
         END IF;
             -- se não deu erro, sair do loop
             EXIT;
 
           EXCEPTION
             WHEN vr_exc_saida THEN
               RAISE vr_exc_saida;
             WHEN OTHERS THEN
 
               vr_dscritic := 'Tabela de lotes esta '||
                              'sendo alterada. Tente novamente.';
               -- aguardar um segundo e tentar novamente
               sys.dbms_lock.sleep(1);
               continue;
           END;

         END LOOP;
         vr_nmprepos := ' ';
         vr_nrcpfpre := 0;

         IF (vr_inpessoa = 2 OR vr_inpessoa = 3) AND 
              vr_idastcjt = 1 THEN
              --Cria transacao pendente de pagamento
              INET0002.pc_cria_trans_pend_pagto( pr_cdagenci => 90             --> Codigo do PA
                                                ,pr_nrdcaixa => 900            --> Numero do Caixa
                                                ,pr_cdoperad => '996'          --> Codigo do Operados
                                                ,pr_nmdatela => 'INTERNETBANK' --> Nome da Tela
                                                ,pr_idorigem => 3              --> Origem da solicitacao
                                                ,pr_idseqttl => pr_idseqttl    --> Sequencial de Titular
                                                ,pr_nrcpfope => pr_nrcpfope    --> Numero do cpf do operador juridico
                                                ,pr_nrcpfrep => (CASE WHEN pr_nrcpfope > 0 THEN 0 ELSE NVL(vr_nrcpfcgc,0) END) --> Numero do cpf do representante legal
                                                ,pr_cdcoptfn => vr_cdcoptfn    --> Cooperativa do Terminal
                                                ,pr_cdagetfn => vr_cdagetfn    --> Agencia do Terminal
                                                ,pr_nrterfin => vr_nrterfin    --> Numero do Terminal Financeiro
                                                ,pr_dtmvtolt => pr_dtmvtolt    --> Data do movimento
                                                ,pr_cdcooper => pr_cdcooper    --> Codigo da cooperativa
                                                ,pr_nrdconta => pr_nrdconta    --> Numero da Conta
                                                ,pr_idtippag => pr_idtpdpag    --> Identificacao do tipo de pagamento (1 – Convenio / 2 – Titulo)
                                                ,pr_vllanmto => pr_vllanaut    --> Valor do pagamento
                                                ,pr_dtmvtopg => pr_dtmvtopg    --> Data do debito
                                                ,pr_idagenda => 2              --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                                ,pr_dscedent => pr_dscedent    --> Descricao do cedente do documento
                                                ,pr_dscodbar => pr_dscodbar    --> Descricao do codigo de barras
                                                ,pr_dslindig => vr_dslindig    --> Descricao da linha digitavel
                                                ,pr_vlrdocto => pr_vldocnto    --> Valor do documento
                                                ,pr_dtvencto => pr_dtvencto    --> Data de vencimento do documento
                                                ,pr_tpcptdoc => 2              --> Tipo de captura do documento
                                                ,pr_idtitdda => 0              --> Identificador do titulo no DDA
                                                ,pr_idastcjt => vr_idastcjt    --> Indicador de Assinatura Conjunta
												,pr_cdctrlcs => pr_cdctrlcs	   --> Controle de consulta NPC
                                                ,pr_cdcritic => vr_cdcritic    --> Codigo de Critica
                                                ,pr_dscritic => vr_dscritic);  --> Descricao de Critica

              -- Verificar se retornou critica
              IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                -- se possui codigo, porém não possui descrição
                IF nvl(vr_cdcritic,0) > 0 AND
                   TRIM(vr_dscritic) IS NULL THEN
                  -- buscar descrição
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

                END IF;
                vr_dscritic := vr_dscritic||' - '||pr_dscedent;

                -- Se retornou critica , deve abortar
                RAISE vr_exc_saida;
              END IF;
         ELSE 
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
               ,tpdvalor
               ,cdctrlcs)
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
               ,vr_nrseqdig
               ,vr_nrseqdig
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
               ,vr_tpdvalor
               ,nvl(pr_cdctrlcs,' '))
            RETURNING idlancto INTO pr_idlancto;
         EXCEPTION
            WHEN OTHERS THEN
               vr_dscritic := 'Nao foi possivel agendar o pagamento. ';
               vr_dscritic := vr_dscritic || SQLERRM;
               --Levantar Excecao
               RAISE vr_exc_saida;
         END;
       END IF;


         -- DDA
         IF pr_idtitdda > 0 OR 
            TRIM(pr_cdctrlcs) IS NOT NULL THEN
           --> Rotina não atualiza como agendado, pois titulo pode ser de outra instituição
            -- fazendo com que não encontre o titulo para atualizar
            NULL;
            /*
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
                                                   ,pr_flgerlog => 0                -- Gerar Log
                                                   ,pr_cdctrlcs => pr_cdctrlcs      -- Codigo de controle de consulta NPC
                                                   ,pr_cdcritic => vr_cdcritic      -- Codigo de critica
                                                   ,pr_dscritic => vr_dscritic);    -- Descrição de critica

            --Se ocorreu erro
            IF nvl(vr_cdcritic,0) > 0 OR 
               TRIM(vr_dscritic) IS NOT NULL THEN        
              --Levantar Excecao
               RAISE vr_exc_saida;
            END IF;*/

         END IF;


      EXCEPTION
         WHEN vr_exc_saida THEN
            pr_cdcritic := 0;
            pr_dscritic := vr_dscritic;
            -- Gerar o LOG do erro que aconteceu durante o processamento
            PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrconven => pr_nrconven
                                         ,pr_tpmovimento => 2 -- Movimento de RETORNO
                                         ,pr_nrremret => pr_nrremret -- Numero da Remessa do Cooperado
                                         ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                         ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                         ,pr_cdprograma => 'pc_processar_arq_pgto'
                                         ,pr_nmtabela => 'CRAPHPT'
                                         ,pr_nmarquivo => pr_nmarquiv
                                         ,pr_dsmsglog => 'Erro na PGTA0001.pc_cadastrar_agend_pgto: ' ||
                                                         vr_dscritic
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
            --ROLLBACK; -- Nao efetuará ROLLBACK... sera controlado no CRPS689
         WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro na PGTA0001.pc_cadastrar_agend_pgto: ' ||
                           vr_dscritic || SQLERRM;
            cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                        ,pr_compleme => 'PGTA0001.pc_cadastrar_agend_pgto - ' || 
                                                        pr_dscritic);
            -- Gerar o LOG do erro que aconteceu durante o processamento
            PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrconven => pr_nrconven
                                         ,pr_tpmovimento => 2 -- Movimento de RETORNO
                                         ,pr_nrremret => pr_nrremret -- Numero da Remessa do Cooperado
                                         ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                         ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                         ,pr_cdprograma => 'pc_processar_arq_pgto'
                                         ,pr_nmtabela => 'CRAPHPT'
                                         ,pr_nmarquivo => pr_nmarquiv
                                         ,pr_dsmsglog => 'Erro na PGTA0001.pc_cadastrar_agend_pgto: ' ||
                                                         vr_dscritic
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
            --ROLLBACK; -- Nao efetuará ROLLBACK... sera controlado no CRPS689
      END;

  END pc_cadastrar_agend_pgto;


  PROCEDURE pc_cancelar_agend_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
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
                                   ,pr_cdcritic      OUT INTEGER                -- Código do erro
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
             ,craplau.idtitdda
             ,craplau.cdctrlcs
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

     vr_cdcritic_aux crapcri.cdcritic%TYPE;
     vr_dscritic_aux VARCHAR2(4000);

     vr_rowid         ROWID;

     vr_exc_saida     EXCEPTION;
     vr_erro_update   EXCEPTION;

     BEGIN

        OPEN cr_craplau_1(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_dtmvtopg => pr_dtmvtopg
                         ,pr_dscodbar => pr_dscodbar);
        FETCH cr_craplau_1 INTO rw_craplau_sit_1;

        IF cr_craplau_1%NOTFOUND THEN
           -- Se não encontrar - Pesquisa via cr_craplau_2
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

                 pgta0001.pc_logar_cst_arq_pgto(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_nmarquiv => 'PGTA0001.PC_CANCELAR_AGEND_PGTO'
                                               ,pr_textolog => vr_dscritic
                                               ,pr_cdcritic => vr_cdcritic_aux
                                               ,pr_dscritic => vr_dscritic_aux);
                 -- Levantar excecao
                 RAISE vr_exc_saida;
           END;
        
           IF rw_craplau_sit_1.idtitdda > 0 OR 
              TRIM(rw_craplau_sit_1.cdctrlcs) IS NOT NULL THEN 
    
              --Atualizar situacao titulo
              DDDA0001.pc_atualz_situac_titulo_sacado (pr_cdcooper => pr_cdcooper   --Codigo da Cooperativa
                                                      ,pr_cdagecxa => pr_cdagenci   --Codigo da Agencia
                                                      ,pr_nrdcaixa => 900           --Numero do Caixa
                                                      ,pr_cdopecxa => '996'         --Codigo Operador Caixa
                                                      ,pr_nmdatela => 'INTERNETBANK'--Nome da tela
                                                      ,pr_idorigem => 3             --Indicador Origem
                                                      ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                                      ,pr_idseqttl => 1             --Sequencial do titular
                                                      ,pr_idtitdda => rw_craplau_sit_1.idtitdda   --Indicador Titulo DDA
                                                      ,pr_cdctrlcs => rw_craplau_sit_1.cdctrlcs   --Identificador da consulta
                                                      ,pr_cdsittit => 1                --Situacao Titulo
                                                      ,pr_flgerlog => 0                --Gerar Log
                                                      ,pr_cdcritic => vr_cdcritic      --Codigo de critica
                                                      ,pr_dscritic => vr_dscritic);    --Descrição de critica
              --Se ocorreu erro
              IF nvl(vr_cdcritic,0) > 0 OR 
                 TRIM(vr_dscritic) IS NOT NULL THEN        
                --Levantar Excecao
                RAISE vr_exc_saida;
              END IF;
            
            END IF; 
        
        ELSE
           IF  pr_dscritic IS NULL THEN -- Se nao for NULO é pq caiu no cursor LAU_2
               vr_dscritic := 'Nao foi possivel localizar agendamento do pagamento.';
               RAISE vr_exc_saida;
           END IF;
        END IF;

     EXCEPTION
        WHEN vr_exc_saida THEN
           pr_cdcritic := 0;
           pr_dscritic := vr_dscritic;
           --ROLLBACK; -- Nao efetuará ROLLBACK... sera controlado no CRPS689
        WHEN OTHERS THEN
           pr_cdcritic := 0;
           pr_dscritic := vr_dscritic;
           --ROLLBACK; -- Nao efetuará ROLLBACK... sera controlado no CRPS689

  END pc_cancelar_agend_pgto;

  -- Procedure para rejeitar arquivo de remessa
  PROCEDURE pc_rejeitar_arq_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                 ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                 ,pr_nrconven      IN craphpt.nrconven%TYPE  -- Numero do Convenio
                                 ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                 ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                 ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                 ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                 ,pr_dsmsgrej      IN VARCHAR2               -- Motivo da Rejeição
                                 ,pr_nrremret      IN INTEGER                -- Numero da Remessa do cooperado
                                 ,pr_cdcritic     OUT INTEGER                -- Código do erro
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

    CURSOR cr_email (pr_cdcooper IN INTEGER
                    ,pr_nrdconta IN INTEGER
                    ,pr_nrconven IN INTEGER) IS
      SELECT cem.dsdemail
        FROM crapcem cem, cecred.tbcobran_cpt_cem cptcem
       WHERE cem.cddemail = cptcem.cddemail
         AND cem.idseqttl = cptcem.idseqttl
         AND cem.nrdconta = cptcem.nrdconta
         AND cem.cdcooper = cptcem.cdcooper
            --
         AND cptcem.nrconven = pr_nrconven
         AND cptcem.nrdconta = pr_nrdconta
         AND cptcem.cdcooper = pr_cdcooper;
    rw_email cr_email%ROWTYPE;

    -- Nome do Arquivo .ERR
    vr_nmarquivo_err VARCHAR2(4000);

    -- Nome do Arquivo .LOG
    vr_nmarquivo_log VARCHAR2(4000);

    vr_exc_erro EXCEPTION;
    vr_nrdrowid ROWID;

    -- Descrição da Origem
    vr_dsorigem VARCHAR2(100);

    vr_diretorio_log VARCHAR2(4000);
    vr_diretorio_err VARCHAR2(4000);
    vr_diretorio_con VARCHAR2(4000);
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

	vr_nmarquivo_err := REPLACE(UPPER(vr_nmarquivo_err),'.TXT','.ERR');

    -- Monta nome do Arquivo de Log (.LOG)
    vr_nmarquivo_log := REPLACE(UPPER(pr_nmarquiv),'.REM','.LOG');

	vr_nmarquivo_log := REPLACE(UPPER(vr_nmarquivo_log),'.TXT','.LOG');

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

    -- Diretório da Cooperativa
    vr_dir_coop := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper);

    -- Diretório do arquivo de Log (.LOG)
    vr_diretorio_log := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/arq') ;

    -- Diretório do arquivo de Erro (.ERR)
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
                                                 ,pr_cdacesso => 'SCRIPT_ENV_REC_ARQ_CUST');

      vr_serv_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'CUST_CHQ_ARQ_SERV_FTP');

      vr_user_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'CUST_CHQ_ARQ_USER_FTP');

      vr_pass_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'CUST_CHQ_ARQ_PASS_FTP');

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

    ELSE -- Se o retorno não é por FTP, vamos enviar o arquivo por e-mail

      --Selecionar Cadastro email
      OPEN cr_email (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrconven => pr_nrconven);
      --Primeiro registro
      FETCH cr_email INTO rw_email;
      --Se Encontrou
      IF cr_email%FOUND THEN
        --Fechar Cursor
        CLOSE cr_email;
        -- Converter o arquivo de ERRO com ux2dos
        GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper      --> Cooperativa
                                    ,pr_nmarquiv => vr_diretorio_err || '/' || vr_nmarquivo_err --> Caminho e nome do arquivo a ser convertido
                                    ,pr_nmarqenv => vr_nmarquivo_err --> Nome desejado para o arquivo convertido
                                    ,pr_des_erro => vr_dscritic);    --> Retorno da critica
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        -- Converter o arquivo de LOG com ux2dos
        GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper      --> Cooperativa
                                    ,pr_nmarquiv => vr_diretorio_log || '/' || vr_nmarquivo_log --> Caminho e nome do arquivo a ser convertido
                                    ,pr_nmarqenv => vr_nmarquivo_log --> Nome desejado para o arquivo convertido
                                    ,pr_des_erro => vr_dscritic);    --> Retorno da critica
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
      END IF;

        -- Obter caminho do /converte
        vr_diretorio_con := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsubdir => 'converte');

        --Enviar Email
        gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                  ,pr_cdprogra        => 'PC_CRPS689'
                                  ,pr_des_destino     => rw_email.dsdemail
                                  ,pr_des_assunto     => 'ERRO NO PROCESSAMENTO DO ARQUIVO DA AGENDAMENTO DE PAGAMENTO'
                                  ,pr_des_corpo       => 'Olá! <br><br>' ||
                                                         'Houveram erros no processamento do arquivo '  || pr_nmarquiv || 
                                                         ', referente ao agendametno de titulos para pagamento. <br><br>' ||
                                                         'Favor verificar o arquivo de LOG, e o arquivo de ERRO em anexo!'
                                  ,pr_des_anexo       => vr_diretorio_con ||'/'||vr_nmarquivo_err || ';' ||
                                                         vr_diretorio_con ||'/'||vr_nmarquivo_log
                                  ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                  ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                  ,pr_flg_log_batch   => 'N' --> Incluir inf. no log
                                  ,pr_des_erro        => vr_dscritic);
        --Se ocorreu erro
        IF trim(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Fechar Cursor
      IF cr_email%ISOPEN THEN
        CLOSE cr_email;
      END IF;
    END IF;

    -- Verifica Qual a Origem
    CASE pr_idorigem
      WHEN 1 THEN vr_dsorigem := 'AIMARO';
      WHEN 3 THEN vr_dsorigem := 'INTERNET';
      WHEN 7 THEN vr_dsorigem := 'FTP';
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

    COMMIT; -- Commita a transação de criação do registro de log

  EXCEPTION
    WHEN vr_exc_erro THEN
      COMMIT;
      -- Retorna variaveis de saida
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Gerar o LOG do erro que aconteceu durante o processamento
      PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrconven => pr_nrconven
                                   ,pr_tpmovimento => 1 -- Movimento de REMESSA
                                   ,pr_nrremret => pr_nrremret -- Numero da Remessa do Cooperado
                                   ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                   ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                   ,pr_cdprograma => 'pgta0001.pc_validar_arq_pgto'
                                   ,pr_nmtabela => 'CRAPHPT'
                                   ,pr_nmarquivo => pr_nmarquiv
                                   ,pr_dsmsglog => 'Arquivo nao importado. ' ||
                                                   'Erro na PGTA0001.pc_rejeitar_arq_pgto: ' ||
                                                   vr_dscritic || '(Etapa 3 de 3)'
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);      
      
    WHEN OTHERS THEN
      COMMIT;
      -- Atualiza campo de erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro PGTA0001.pc_rejeitar_arq_pgto: ' || SQLERRM;
      
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                  ,pr_compleme => pr_dscritic);
                                  
      -- Gerar o LOG do erro que aconteceu durante o processamento
      PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrconven => pr_nrconven
                                   ,pr_tpmovimento => 1 -- Movimento de REMESSA
                                   ,pr_nrremret => pr_nrremret -- Numero da Remessa do Cooperado
                                   ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                   ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                   ,pr_cdprograma => 'pgta0001.pc_validar_arq_pgto'
                                   ,pr_nmtabela => 'CRAPHPT'
                                   ,pr_nmarquivo => pr_nmarquiv
                                   ,pr_dsmsglog => 'Arquivo nao importado. ' ||
                                                   pr_dscritic || '(Etapa 3 de 3)'
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);      
      
  END;

  END pc_rejeitar_arq_pgto;


  -- Gera retorno dos titulos PAGOS - Que ja foram processados pela DEBNET(CRPS509)
  PROCEDURE pc_gera_retorno_tit_pago (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                     ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                     ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                     ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Operador
                                     ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                     ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro

     -- Dados do arquivo de remessa
     CURSOR cr_crapdpt(pr_cdcooper IN crapdpt.cdcooper%TYPE
                      ,pr_dtmvtopg IN crapdpt.dtmvtopg%TYPE) IS
        SELECT cdcooper,
               nrdconta,
               nrconven,
               intipmvt,
               nrremret,
               nrseqarq,
               cdtipmvt,
               cdinsmvt,
               dscodbar,
               nmcedent,
               vltitulo,
               vldescto,
               vlacresc,
               dtdpagto,
               vldpagto,
               dsusoemp,
               dsnosnum,
               cdocorre,
               intipreg,
               insitlau,
               dtmvtopg,
               dtvencto,
               idlancto,
               nmarquiv,
               row_number() OVER(PARTITION BY nrdconta ORDER BY nrdconta) sqatureg,
               COUNT(1) OVER(PARTITION BY nrdconta) qtregtot
          FROM (
                /*select que retorna os registros incluídos antes da melhoria 271.3*/
                SELECT dpt.cdcooper,
                       dpt.nrdconta,
                       dpt.nrconven,
                       dpt.intipmvt,
                       dpt.nrremret,
                       dpt.nrseqarq,
                       dpt.cdtipmvt,
                       dpt.cdinsmvt,
                       dpt.dscodbar,
                       dpt.nmcedent,
                       dpt.vltitulo,
                       dpt.vldescto,
                       dpt.vlacresc,
                       dpt.dtdpagto,
                       dpt.vldpagto,
                       dpt.dsusoemp,
                       dpt.dsnosnum,
                       dpt.cdocorre,
                       dpt.intipreg,
                       lau.insitlau,
                       lau.dtmvtopg,
                       lau.dtvencto,
                       lau.idlancto,
                       hpt.nmarquiv
                  FROM craplau lau, craphpt hpt, crapdpt dpt
                 WHERE lau.dscodbar = dpt.dscodbar || ''
                   AND lau.cdtiptra = 2 -- fixo pgta0001.pc_cadastrar_agend_pgto
                   AND lau.cdhistor = 508 -- fixo pgta0001.pc_cadastrar_agend_pgto
                   AND lau.nrdctabb = 0 -- fixo pgta0001.pc_cadastrar_agend_pgto insere null e assume valor default
                   AND lau.nrdolote = 11900 -- fixo pgta0001.pc_cadastrar_agend_pgto
                   AND lau.cdbccxlt = 100 -- fixo pgta0001.pc_cadastrar_agend_pgto
                   AND lau.cdagenci = 90 -- fixo pgta0001.pc_processar_arq_pgto
                   AND lau.dtmvtolt = hpt.dtmvtolt + 0
                   AND lau.nrdconta = dpt.nrdconta + 0
                   AND lau.cdcooper = dpt.cdcooper + 0
                   AND lau.insitlau IN (2, 4) -- 2-efetivado ou 4-nao efetivado
                      --
                   AND hpt.nrremret = dpt.nrremret + 0
                   AND hpt.intipmvt = dpt.intipmvt + 0
                   AND hpt.nrconven = dpt.nrconven + 0
                   AND hpt.nrdconta = dpt.nrdconta + 0
                   AND hpt.cdcooper = dpt.cdcooper + 0
                      --
                   AND dpt.idlancto IS NULL
                   AND dpt.intipmvt = 2 -- retorno
                   AND dpt.cdtipmvt = 0 -- inclusao
                   AND dpt.cdocorre = 'BD' -- inclusao sucesso
                   AND dpt.dtmvtopg = pr_dtmvtopg
                   AND dpt.cdcooper = pr_cdcooper
                UNION ALL
                /*select que retorna os registros incluídos após a melhoria 271.3*/
                SELECT dpt.cdcooper,
                       dpt.nrdconta,
                       dpt.nrconven,
                       dpt.intipmvt,
                       dpt.nrremret,
                       dpt.nrseqarq,
                       dpt.cdtipmvt,
                       dpt.cdinsmvt,
                       dpt.dscodbar,
                       dpt.nmcedent,
                       dpt.vltitulo,
                       dpt.vldescto,
                       dpt.vlacresc,
                       dpt.dtdpagto,
                       dpt.vldpagto,
                       dpt.dsusoemp,
                       dpt.dsnosnum,
                       dpt.cdocorre,
                       dpt.intipreg,
                       lau.insitlau,
                       lau.dtmvtopg,
                       lau.dtvencto,
                       lau.idlancto,
                       hpt.nmarquiv
                  FROM craplau lau, crapdpt dpt, craphpt hpt
                 WHERE lau.insitlau IN (2, 4) -- 2-efetivado ou 4-nao efetivado
                   AND lau.idlancto = dpt.idlancto + 0
                      --
                   AND hpt.nrremret = dpt.nrremret + 0
                   AND hpt.intipmvt = dpt.intipmvt + 0
                   AND hpt.nrconven = dpt.nrconven + 0
                   AND hpt.nrdconta = dpt.nrdconta + 0
                   AND hpt.cdcooper = dpt.cdcooper + 0
                      --
                   AND dpt.idlancto IS NOT NULL
                   AND dpt.intipmvt = 2 -- retorno
                   AND dpt.cdtipmvt = 0 -- inclusao
                   AND dpt.cdocorre = 'BD' -- inclusao sucesso
                   AND dpt.dtmvtopg = pr_dtmvtopg
                   AND dpt.cdcooper = pr_cdcooper)
         ORDER BY nrdconta;      
     rw_crapdpt cr_crapdpt%ROWTYPE;

     -- Buscar ultimo numero de retorno utilizado
     CURSOR cr_craphpt(pr_cdcooper IN craphpt.cdcooper%TYPE     --> Código da cooperativa
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

     vr_cdcritic_aux crapcri.cdcritic%TYPE;
     vr_dscritic_aux VARCHAR2(4000);

     vr_nrremret craphpt.nrremret%TYPE;
     vr_nmarquiv craphpt.nmarquiv%TYPE;
     vr_cdtipmvt crapdpt.cdtipmvt%TYPE;
     vr_cdinsmvt crapdpt.cdinsmvt%TYPE;
     vr_cdocorre VARCHAR2(5);
     vr_nrseqarq crapdpt.nrseqarq%TYPE;

     vr_exc_critico EXCEPTION;
     vr_dtmvtolt DATE;

     BEGIN
       
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        -- Se não encontrar
        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
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
     
        -- Gerar Informação de Retorno ao Cooperado - Efetivacao do Pagametno (.RET)

        -- Ler todos os registros da crapdpt (Retorno) e gravar na crapdpt (Liquidado)
        FOR rw_crapdpt IN cr_crapdpt(pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtopg => pr_dtmvtolt) LOOP

           IF rw_crapdpt.sqatureg = 1 THEN  -- Primeiro Registro - FIRST-OF do NrdConta

              vr_nrremret := 0;
              vr_nrseqarq := 0;
              vr_nmarquiv := '';

              -- Buscar o Último Lote de Retorno do Cooperado
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

              -- Criar Lote de Informações de Retorno (craphpt)
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
                      TRUNC(SYSDATE),
                      to_char(SYSDATE,'HH24MISS'),
                      2, -- Processado
                      pr_cdoperad);

              IF SQL%ROWCOUNT = 0 THEN
                 RAISE vr_exc_critico;
              END IF;

              EXCEPTION
                 WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'PGTA0001.pc_gera_retorno_tit_pago: ' ||
                                   'Erro ao inserir CRAPHPT: ' || SQLERRM;

                    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                                ,pr_compleme => vr_dscritic);
         
                    -- Gerar o LOG do erro que aconteceu durante o processamento
                    PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => rw_crapdpt.cdcooper
                                                 ,pr_nrdconta => rw_crapdpt.nrdconta
                                                 ,pr_nrconven => rw_crapdpt.nrconven
                                                 ,pr_tpmovimento => 2 -- Movimento de RETORNO
                                                 ,pr_nrremret => rw_crapdpt.nrremret -- Numero da Remessa do Cooperado
                                                 ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                                 ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                                 ,pr_cdprograma => 'pc_gera_retorno_tit_pago'
                                                 ,pr_nmtabela => 'CRAPHPT'
                                                 ,pr_nmarquivo => rw_crapdpt.nmarquiv
                                                 ,pr_dsmsglog => vr_dscritic
                                                 ,pr_cdcritic => vr_cdcritic_aux
                                                 ,pr_dscritic => vr_dscritic_aux);                    

                    pgta0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapdpt.cdcooper
                                                  ,pr_nrdconta => rw_crapdpt.nrdconta
                                                  ,pr_nmarquiv => 'PGTA0001.PC_GERA_RETORNO_TIT_PAGO'
                                                  ,pr_textolog => vr_dscritic
                                                  ,pr_cdcritic => vr_cdcritic_aux
                                                  ,pr_dscritic => vr_dscritic_aux);

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
                 intipreg,
                 tpmvtorg,
                 nrmvtorg,
                 nrarqorg,
                 idlancto)
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
                 rw_crapdpt.intipreg,
                 rw_crapdpt.intipmvt,
                 rw_crapdpt.nrremret,
                 rw_crapdpt.nrseqarq,
                 rw_crapdpt.idlancto);

           IF SQL%ROWCOUNT = 0 THEN
               RAISE vr_exc_critico;
           END IF;

           EXCEPTION
              WHEN OTHERS THEN
                 vr_cdcritic := 0;
                 vr_dscritic := 'PGTA0001.pc_gera_retorno_tit_pago: ' ||
                                'Erro ao inserir CRAPDPT: '||SQLERRM;
                 cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                             ,pr_compleme => vr_dscritic);
         
                 -- Gerar o LOG do erro que aconteceu durante o processamento
                 PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => rw_crapdpt.cdcooper
                                              ,pr_nrdconta => rw_crapdpt.nrdconta
                                              ,pr_nrconven => rw_crapdpt.nrconven
                                              ,pr_tpmovimento => 2 -- Movimento de RETORNO
                                              ,pr_nrremret => rw_crapdpt.nrremret -- Numero da Remessa do Cooperado
                                              ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                              ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                              ,pr_cdprograma => 'pc_gera_retorno_tit_pago'
                                              ,pr_nmtabela => 'CRAPHPT'
                                              ,pr_nmarquivo => rw_crapdpt.nmarquiv
                                              ,pr_dsmsglog => vr_dscritic
                                              ,pr_cdcritic => vr_cdcritic_aux
                                              ,pr_dscritic => vr_dscritic_aux);                    

                 pgta0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapdpt.cdcooper
                                               ,pr_nrdconta => rw_crapdpt.nrdconta
                                               ,pr_nmarquiv => 'PGTA0001.PC_GERA_RETORNO_TIT_PAGO'
                                               ,pr_textolog => vr_dscritic
                                               ,pr_cdcritic => vr_cdcritic_aux
                                               ,pr_dscritic => vr_dscritic_aux);

                 RAISE vr_exc_critico;
           END;

        END LOOP;

        -- Salva Alterações Efetuadas
        --COMMIT; -- Controlado pelo CRPS509

  EXCEPTION
     WHEN vr_exc_critico THEN
        -- Atualiza campo de erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic  || SQLERRM;
        -- ROLLBACK; -- Controlado pelo CRPS509
     WHEN OTHERS THEN
        -- Atualiza campo de erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic  || SQLERRM;
        --- ROLLBACK; -- Controlado pelo CRPS509

  END pc_gera_retorno_tit_pago;


  PROCEDURE pc_gerar_arq_log_pgto(pr_cdcooper  IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                 ,pr_nrdconta  IN INTEGER                -- Numero da Conta
                                 ,pr_nrconven  IN INTEGER                -- Numero do Convenio
                                 ,pr_nrremret  IN INTEGER                -- Numero da Remessa
                                 ,pr_nmarquiv  IN VARCHAR2               -- Nome do Arquivo
                                 ,pr_tab_err   IN PGTA0001.typ_tab_err_arq_agend -- Erros gerados no arquivo
                                 ,pr_cdcritic OUT INTEGER                -- Código do erro
                                 ,pr_dscritic OUT VARCHAR2) IS           -- Descricao do erro
      -- Nome do Arquivo
      vr_nmarquiv  VARCHAR2(100);

      vr_setlinha VARCHAR2(400);

      vr_utlfileh VARCHAR2(4000);

      -- Declarando Handle do Arquivo
      vr_ind_arquivo utl_file.file_type;
      vr_exc_saida  EXCEPTION;
      vr_exc_erro   EXCEPTION;

    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    BEGIN

      --Inicializar variaveis retorno
      pr_cdcritic:= 0;
      pr_dscritic:= NULL;

      -- Define nome do arquivo .LOG com base nome do Arquivo de Remessa
      vr_nmarquiv := REPLACE(UPPER(pr_nmarquiv),'.REM','.LOG');

	  vr_nmarquiv := REPLACE(UPPER(vr_nmarquiv),'.TXT','.LOG');

      -- Define o diretório do arquivo
      vr_utlfileh := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/arq') ;

      -- Abre arquivo em modo de Escrita (W)
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh         --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nmarquiv         --> Nome do arquivo
                              ,pr_tipabert => 'W'                 --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arquivo      --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);       --> Erro

      IF vr_dscritic IS NOT NULL THEN
        -- Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

    
      -- Linha do Erro Apresentado
    vr_setlinha:= 'Foram identificadas ' || pr_tab_err.COUNT || 
                  ' inconsistencias no arquivo.' || CHR(13);

      -- Escrever Erro Apresentado no Arquivo
      GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);

    -- Gerar o LOG de arquivo processado com sucesso
    PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrconven => pr_nrconven
                                 ,pr_tpmovimento => 1 -- Movimento de REMESSA
                                 ,pr_nrremret => pr_nrremret -- Numero da Remessa do Cooperado
                                 ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                 ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                 ,pr_cdprograma => 'pgta0001.pc_validar_arq_pgto'
                                 ,pr_nmtabela => 'CRAPHPT'
                                 ,pr_nmarquivo => pr_nmarquiv
                                 ,pr_dsmsglog => vr_setlinha
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
    -- Ignorar as criticas do LOG
    vr_cdcritic := NULL;
    vr_dscritic := NULL;                                   
        
    FOR x IN pr_tab_err.FIRST..pr_tab_err.LAST LOOP
      -- Linha do Erro Apresentado
      vr_setlinha:= TRIM(pr_tab_err(x)) || CHR(13);

      -- Escrever Erro Apresentado no Arquivo
      GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);
      
      -- Gerar o LOG de arquivo processado com sucesso
      PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrconven => pr_nrconven
                                   ,pr_tpmovimento => 1 -- Movimento de REMESSA
                                   ,pr_nrremret => pr_nrremret -- Numero da Remessa do Cooperado
                                   ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                   ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                   ,pr_cdprograma => 'pc_gerar_arq_log_pgto'
                                   ,pr_nmtabela => 'CRAPHPT'
                                   ,pr_nmarquivo => pr_nmarquiv
                                   ,pr_dsmsglog => vr_setlinha
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
      -- Ignorar as criticas do LOG
      vr_cdcritic := NULL;
      vr_dscritic := NULL;                                   
    END LOOP;

      -- Fechar o arquivo
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := 0;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro PGTA0001.pc_gerar_arq_log_pgto: ' || SQLERRM;

  END pc_gerar_arq_log_pgto;


  -- Procedure para gerar arquivo de retorno
  PROCEDURE pc_gerar_arq_ret_pgto (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                  ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                  ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                  ,pr_nrremret      IN craphpt.nrremret%TYPE  -- Numero Remessa/Retorno
                                  ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                  ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                  ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                  ,pr_nmarquiv     OUT VARCHAR2               -- Nome do Arquivo
                                  ,pr_dsarquiv     OUT CLOB                   -- Conteudo do Arquivo -> Apenas quando origem Internet Banking
                                  ,pr_dsinform     OUT VARCHAR2               -- Mensagem Informativa
                                  ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                  ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro

  BEGIN

  DECLARE

    -- CURSORES

    -- Busca do diretório conforme a cooperativa conectada
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
      SELECT dpt.cdcooper,
             dpt.nrdconta,
             dpt.nrconven,
             dpt.intipmvt,
             dpt.nrremret,
             dpt.nrseqarq,
             dpt.cdtipmvt,
             dpt.cdinsmvt,
             dpt.dscodbar,
             dpt.nmcedent,
             dpt.dtvencto,
             dpt.vltitulo,
             dpt.vldescto,
             dpt.vlacresc,
             dpt.dtdpagto,
             dpt.vldpagto,
             dpt.dsusoemp,
             dpt.dsnosnum,
             dpt.cdocorre,
             dpt.dtmvtopg,
             dpt.intipreg,
             pro.nrseqaut,
             pro.nrdocmto,
             pro.dsprotoc,
             pro.dtmvtolt,
             pro.hrautent
        FROM crappro pro, crapaut aut, craptit tit, crapdpt dpt
       WHERE UPPER(pro.dsprotoc(+)) = UPPER(aut.dsprotoc)
         AND pro.cdcooper(+) = aut.cdcooper
            --
         AND aut.nrsequen(+) = tit.nrautdoc
         AND aut.nrdcaixa(+) = (tit.nrdolote - 16000) /*conforme regra em cxon0014.pc_gera_titulos_iptu*/
         AND aut.cdagenci(+) = tit.cdagenci
         AND aut.dtmvtolt(+) = tit.dtmvtolt
         AND aut.cdcooper(+) = tit.cdcooper
            --
         AND tit.dtmvtolt(+) = dpt.dtdpagto
         AND UPPER(tit.dscodbar(+)) = UPPER(dpt.dscodbar)
         AND tit.cdcooper(+) = dpt.cdcooper
            --
         AND dpt.idlancto IS NULL
         AND dpt.intipmvt = 2 /*retorno*/
         AND dpt.nrremret = pr_nrremret
         AND dpt.nrconven = pr_nrconven
         AND dpt.nrdconta = pr_nrdconta
         AND dpt.cdcooper = pr_cdcooper
      UNION ALL
      SELECT dpt.cdcooper,
             dpt.nrdconta,
             dpt.nrconven,
             dpt.intipmvt,
             dpt.nrremret,
             dpt.nrseqarq,
             dpt.cdtipmvt,
             dpt.cdinsmvt,
             dpt.dscodbar,
             dpt.nmcedent,
             dpt.dtvencto,
             dpt.vltitulo,
             dpt.vldescto,
             dpt.vlacresc,
             dpt.dtdpagto,
             dpt.vldpagto,
             dpt.dsusoemp,
             dpt.dsnosnum,
             dpt.cdocorre,
             dpt.dtmvtopg,
             dpt.intipreg,
             pro.nrseqaut,
             pro.nrdocmto,
             pro.dsprotoc,
             pro.dtmvtolt,
             pro.hrautent
        FROM crappro pro, crapaut aut, craptit tit, craplau lau, crapdpt dpt
       WHERE UPPER(pro.dsprotoc(+)) = UPPER(aut.dsprotoc)
         AND pro.cdcooper(+) = aut.cdcooper + 0
            --
         AND aut.nrsequen(+) = tit.nrautdoc + 0
         AND aut.dtmvtolt(+) = tit.dtmvtolt + 0
         AND aut.nrdcaixa(+) = (tit.nrdolote - 16000) /*conforme regra em cxon0014.pc_gera_titulos_iptu*/
         AND aut.cdagenci(+) = tit.cdagenci + 0
         AND aut.cdcooper(+) = tit.cdcooper + 0
            --
         AND UPPER(tit.dscodbar(+)) = UPPER(lau.dscodbar)
         AND tit.nrdolote(+) = 16900 /*fixo cxon0014.pc_gera_titulos_iptu*/
         AND tit.cdbccxlt(+) = 11 /*fixo cxon0014.pc_gera_titulos_iptu*/
         AND tit.cdagenci(+) = lau.cdagenci + 0
         AND tit.dtmvtolt(+) = lau.dtmvtopg + 0
         AND tit.cdcooper(+) = lau.cdcooper + 0
            --
         AND lau.idlancto(+) = dpt.idlancto + 0
            --
         AND dpt.idlancto IS NOT NULL
         AND dpt.intipmvt = 2 /*retorno*/
         AND dpt.nrremret = pr_nrremret
         AND dpt.nrconven = pr_nrconven
         AND dpt.nrdconta = pr_nrdconta
         AND dpt.cdcooper = pr_cdcooper
       ORDER BY nrseqarq;
      
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

    -- Hora Geração
    vr_horagera VARCHAR2(100);

    -- Variaveis Acumuladoras
    vr_qtd_registro  NUMBER :=0 ;
    vr_vlr_tot_pgto  NUMBER :=0 ;
    vr_qtd_reg_lote  NUMBER :=0 ;

    vr_nr_sequencial NUMBER := 0;

    vr_aux_cdocorre VARCHAR2(2);

    vr_nrdrowid ROWID;

    vr_dsorigem VARCHAR2(10);

    vr_serv_ftp VARCHAR2(100);
    vr_user_ftp VARCHAR2(100);
    vr_pass_ftp VARCHAR2(100);
    vr_comando VARCHAR2(4000);

    vr_typ_saida VARCHAR2(3);

    vr_dir_retorno VARCHAR2(4000);
    vr_dir_coop    VARCHAR2(4000);

    vr_script_pgto VARCHAR2(4000);
    
    vr_exists_arq_ret BOOLEAN;

  BEGIN
    --Inicializar variaveis retorno
    pr_cdcritic:= 0;
    pr_dscritic:= NULL;
    pr_dsinform := '';
    vr_exists_arq_ret := FALSE;

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

    -- Define o diretório do arquivo
    vr_dir_coop := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '') ;
  
    -- Define o diretório do arquivo
    vr_utlfileh := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/arq') ;

    -- Abre arquivo em modo de escrita (W)
    GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh         --> Diretório do arquivo
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
                  '2'                                                       || -- 16.0 - Código Remessa/Retorno
                  to_char(SYSDATE,'DDMMYYYY')                               || -- 17.0 - Data de Geração do Arquivo
                  GENE0002.fn_mask(vr_horagera,'999999')                    || -- 18.0 - Hora de Geração do Arquivo
                  GENE0002.fn_mask(pr_nrremret,'999999')                    || -- 19.0 - Numero Sequencial do Arquivo
                  '088'                                                     || -- 20.0 - Layout do Arquivo
                  '00000'                                                   || -- 21.0 - Densidade de Gravação do Arquivo
                  LPAD(' ',20,' ')                                          || -- 22.0 - Uso Reservado do Banco
                  LPAD(' ',20,' ')                                          || -- 23.0 - Uso Reservado da Empresa
                  LPAD(' ',29,' ');                                            -- 24.0 - Uso Exclusivo FEBRABAN

    -- Escrever Linha do Header do Arquivo CNAB240 - Item 1.0
    GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);

    ------------- HEADER DO LOTE -------------
    vr_qtd_registro := vr_qtd_registro + 1;

    vr_setlinha:= '085'                                                    || -- 01.1 - Banco
                  '0001'                                                   || -- 02.1 - Lote
                  '1'                                                      || -- 03.1 - Tipo Registro
                  'C'                                                      || -- 04.1 - Tipo de Operação
                  '98'                                                     || -- 05.1 - Tipo de Serviço
                  '11'                                                     || -- 06.1 - Forma de Lançamento '11' = Pagamento de Contas e Tributos com Código de Barras
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
                  LPAD(' ',80,' ')                                         || -- 19.1 - Endereço da Empresa
                  LPAD(' ',08,' ')                                         || -- 26.1 - Uso Exclusivo FEBRABAN
                  LPAD(' ',10,' ');                                           -- 27.1 - Ocorrencias p/ Retorno

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
          GENE0002.fn_mask(rw_crapdpt.cdinsmvt,'99')                           || -- 07.3J - Código da Instrução p/ Movimento
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
          '09'                                                                 || -- 19.3J - Código da Moeda
          LPAD(' ',06,' ')                                                     || -- 20.3J - Uso exclusivo FEBRABAN
          NVL(vr_aux_cdocorre,'00') || LPAD(' ',08,' ');                        -- 21.3J - Codigo das Ocorrencias

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
          GENE0002.fn_mask(rw_crapdpt.cdinsmvt,'99')                                                                     || -- 07.4J99 - Código da Instrução p/ Movimento          
          '99'                                                                                                           || -- 08.4J99 - Codigo de Barra
          GENE0002.fn_mask(rw_crapdpt.nrseqaut,'9999999999')                                                             || -- 09.4J99 - Código de Autenticação
          GENE0002.fn_mask(rw_crapdpt.nrdocmto,'9999999999999999999999999')                                              || -- 10.4J99 - Número do Documento
          NVL(to_char(rw_crapdpt.dtmvtolt,'DDMMRRRR'),to_char(trunc(SYSDATE),'DDMMRRRR'))                                || -- 11.4J99 - Data do Pagamento
          GENE0002.fn_mask(rw_crapdpt.hrautent,'999999')                                                                 || -- 12.4J99 - Hora do Pagamento
          RPAD(rw_crapdpt.dsprotoc,70,' ')                                                                                 || -- 12.4J99 - Hora do Pagamento
          LPAD(' ',102,' ');                                                                                                -- 13.4J99 - CNAB Uso Exclusivo Cecred
          
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
                  '0001'                                                       || -- 02.5 - Lote de Serviço
                  '5'                                                          || -- 03.5 - Registro Trailer de Lote
                  LPAD(' ',9,' ')                                              || -- 04.5 - Uso Exclusivo FEBRABAN
                  GENE0002.fn_mask(vr_qtd_reg_lote,'999999')                   || -- 05.5 - Qtd Registros do Lote
                  GENE0002.fn_mask(vr_vlr_tot_pgto * 100,'999999999999999999') || -- 06.5 - Somatoria dos Valores
                  '000000000000000000'                                         || -- 07.5 - Somatoria Quantidade Moeda
                  LPAD('0',06,'0')                                             || -- 08.5 - Numero Aviso de Debito
                  LPAD(' ',165,' ')                                            || -- 09.5 - Uso Exclusivo FEBRABAN
                  LPAD(' ',10,' ');                                               -- 10.5 - Ocorrencias Lote

    -- Escreve Linha do Trailer de Lote CNAB240 - Item 1.5
    GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);


    ------------- TRAILER DO ARQUIVO -------------
    vr_qtd_registro := vr_qtd_registro + 1;

    vr_setlinha:= '085'                                      || -- 01.9 - Banco
                  '9999'                                     || -- 02.9 - Lote de Serviço
                  '9'                                        || -- 03.9 - Tipo Registro
                  LPAD(' ',9,' ')                            || -- 04.9 - Uso Exclusivo FEBRABAN
                  '000001'                                   || -- 05.9 - Qtd de Lotes do Arquivo
                  GENE0002.fn_mask(vr_qtd_registro,'999999') || -- 06.9 - Qtd Registros do Arquivo
                  '000001'                                   || -- 07.9 - Qtd Contas p/ Conciliar
                  LPAD(' ',205,' ');                            -- 08.9 - Uso Exclusivo FEBRABAN

    -- Escreve Linha do Trailer de Arquivo CNAB240 - Item 1.9
    GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);


    -- Fechar o arquivo
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

    -- UX2DOS
    GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper                  --> Cooperativa
                                ,pr_nmarquiv => vr_utlfileh||'/'||vr_nmarquiv --> Caminho e nome do arquivo a ser convertido
                                ,pr_nmarqenv => vr_nmarquiv                  --> Nome desejado para o arquivo convertido
                                ,pr_des_erro => vr_dscritic);                --> Retorno da critica

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    -- Apos converte o arquivo, vamos buscar o arquivo convertido e sobrescrever o 
    -- arquivo que acabamos de gerar
    vr_comando:= 'mv '||vr_dir_coop||'/converte/'||vr_nmarquiv||' '||
                 vr_utlfileh||'/'||vr_nmarquiv||' 2> /dev/null';
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typ_saida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
      RAISE vr_exc_erro;
    END IF;
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
    -- Verificamos se o cooperado possui retorno pela Internet
    IF rw_crapcpt.idretorn = 1 THEN -- Retorno Internet
    IF pr_idorigem = 3 THEN     -- INTERNET
      -- Define o diretório do arquivo
      vr_utlfileh := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/arq') ;

      -- Abre arquivo em modo de leitura (R)
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh         --> Diretório do arquivo
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
          -- Verifica se o arquivo está aberto
          IF  utl_file.IS_OPEN(vr_ind_arquivo) THEN
            -- Le os dados em pedaços e escreve no Clob
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquivo --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido

            gene0002.pc_escreve_xml(pr_xml            => pr_dsarquiv
                                   ,pr_texto_completo => vr_arq_tmp
                                     ,pr_texto_novo     => '<linha>' || REPLACE(REPLACE(vr_setlinha,CHR(10),''),CHR(13),'') || '</linha>');
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

        -- Gerar o LOG do erro que aconteceu durante o processamento
        PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrconven => pr_nrconven
                                     ,pr_tpmovimento => 2 -- Movimento de RETORNO
                                     ,pr_nrremret => pr_nrremret -- Numero da Remessa do Cooperado
                                     ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                     ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                     ,pr_cdprograma => 'pc_gerar_arq_ret_pgto'
                                     ,pr_nmtabela => 'CRAPHPT'
                                     ,pr_nmarquivo => vr_nmarquiv
                                     ,pr_dsmsglog => 'Retorno do arquivo pelo Internet Banking'
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
      
      END IF;
    ELSE
      --- Verificamos se o cooperado possui retorno pelo FTP
      IF rw_crapcpt.idretorn = 2 THEN

        -- Caminho script que envia/recebe arquivos via FTP
        vr_script_pgto := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdcooper => '0'
                                                   ,pr_cdacesso => 'SCRIPT_ENV_REC_ARQ_CUST');

        vr_serv_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => '0'
                                                ,pr_cdacesso => 'CUST_CHQ_ARQ_SERV_FTP');

        vr_user_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => '0'
                                                ,pr_cdacesso => 'CUST_CHQ_ARQ_USER_FTP');

        vr_pass_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => '0'
                                                ,pr_cdacesso => 'CUST_CHQ_ARQ_PASS_FTP');

        vr_dir_retorno := '/' ||TRIM(rw_crapcop.dsdircop)   ||
                          '/' || TRIM(to_char(pr_nrdconta)) || '/RETORNO';

        -- Copia Arquivo .ERR para Servidor FTP
        vr_comando := vr_script_pgto                            || ' ' ||
        '-envia'                                                || ' ' ||
        '-srv '         || vr_serv_ftp                          || ' ' || -- Servidor
        '-usr '         || vr_user_ftp                          || ' ' || -- Usuario
        '-pass '        || vr_pass_ftp                          || ' ' || -- Senha
        '-arq '         || CHR(39) || vr_nmarquiv || CHR(39)    || ' ' || -- .ERR
        '-dir_local '   || vr_utlfileh                          || ' ' || -- /usr/coop/<cooperativa>/upload
        '-dir_remoto '  || vr_dir_retorno                       || ' ' || -- /<conta do cooperado>/RETORNO
        '-salvar '      || vr_dir_coop || '/salvar'             || ' ' || -- /usr/coop/<cooperativa>/salvar
        '-log '         || vr_dir_coop || '/log/pgto_por_arquivo.log';    -- /usr/coop/<cooperativa>/log/pgto_por_arquivo.log

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
        
        pr_dsinform := gene0007.fn_caract_acento('O arquivo de retorno foi disponibilizado no FTP.');
        
        -- Gerar o LOG do erro que aconteceu durante o processamento
        PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrconven => pr_nrconven
                                     ,pr_tpmovimento => 2 -- Movimento de RETORNO
                                     ,pr_nrremret => pr_nrremret -- Numero da Remessa do Cooperado
                                     ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                     ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                     ,pr_cdprograma => 'pc_gerar_arq_ret_pgto'
                                     ,pr_nmtabela => 'CRAPHPT'
                                     ,pr_nmarquivo => vr_nmarquiv
                                     ,pr_dsmsglog => 'Retorno do arquivo por FTP'
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
      END IF;
    END IF;

    -- Verifica Qual a Origem
    CASE pr_idorigem
      WHEN 1 THEN vr_dsorigem := 'AIMARO';
      WHEN 3 THEN vr_dsorigem := 'INTERNET';
      WHEN 7 THEN vr_dsorigem := 'FTP';
      ELSE vr_dsorigem := ' ';
    END CASE;

    -- Gerar registro de log (craplgm)
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => 'Gerado arquivo de retorno de pagamento por arquivo: ' || vr_nmarquiv
                        ,pr_dttransa => pr_dtmvtolt
                        ,pr_flgtrans => 1 -- TRUE
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

      -- Salva Alterações
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

      WHEN OTHERS THEN
        -- Atualiza campo de erro
        pr_cdcritic := 0;
        pr_dscritic := 'Erro pc_gerar_arq_ret_pgto: ' || SQLERRM;
    END;

   END pc_gerar_arq_ret_pgto;



   PROCEDURE pc_logar_cst_arq_pgto(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                  ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                  ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                  ,pr_textolog      IN VARCHAR2               -- Texto a ser Incluso Log
                                  ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                  ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro

    BEGIN

    DECLARE

      -- Variaveis Log
      vr_nmdirlog   VARCHAR2(4000);
      vr_input_file utl_file.file_type;
      vr_datdodia   DATE;

      -- Descrição do Erro
      vr_des_erro VARCHAR2(4000);

      vr_exc_erro EXCEPTION;

      vr_setlinha VARCHAR2(4000);

      BEGIN

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
    PROCEDURE pc_retorna_titulo_agendado(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                        ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                        ,pr_nrconven      IN craphpt.nrconven%TYPE  -- Numero do Convenio
--                                        ,pr_nrremret      INT craphpt.nrremret%TYPE -- Numero da remessa retorno
                                        ,pr_dtinicon      IN DATE                   -- Data Inicial
                                        ,pr_dtfincon      IN DATE                   -- Data Final
                                        ,pr_tab_titulo     OUT CLOB                   -- XML da tabela de titulos
                                        ,pr_cdcritic     OUT INTEGER                -- Código do erro
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
       -- Se não encontrou registro, gera critica
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
          -- Insere o cabeçalho do XML
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


  PROCEDURE pc_gera_log_conv(pr_cdcooper       IN  crapcop.cdcooper%TYPE
                            ,pr_nrdconta       IN  crapass.nrdconta%TYPE                            
                            ,pr_nrconven       IN  crapcpt.nrconven%TYPE
                            ,pr_cdoperad       IN  crapope.cdoperad%TYPE
                            ,pr_cdprograma     IN  tbcobran_cpt_log.cdprograma%TYPE
                            ,pr_tpmanipulacao  IN  tbcobran_cpt_log.tpmanipulacao%TYPE
                            ,pr_nmtabela       IN  tbcobran_cpt_log.nmtabela%TYPE
                            ,pr_nmdcampo       IN  tbcobran_cpt_log.nmdcampo%TYPE
                            ,pr_dsinf_anterior IN  tbcobran_cpt_log.dsinf_anterior%TYPE
                            ,pr_dsinf_atual    IN  tbcobran_cpt_log.dsinf_atual%TYPE
                            ,pr_cdcritic       OUT PLS_INTEGER                           --> Código da crítica
                            ,pr_dscritic       OUT VARCHAR2) IS                          --> Descrição da crítica
  BEGIN

    /* .............................................................................

    Programa: pc_gera_log_conv
    Sistema : Ayllos Web
    Autor   : Tiago
    Data    : Agosto - 2017.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gerar logs para o convenio de pagto por arquivo

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados do indicador
			CURSOR cr_crapcpt(pr_cdcooper crapcpt.cdcooper%TYPE
                       ,pr_nrdconta crapcpt.nrdconta%TYPE
                       ,pr_nrconven crapcpt.nrconven%TYPE) IS
			  SELECT * 
          FROM crapcpt
         WHERE crapcpt.cdcooper = pr_cdcooper
           AND crapcpt.nrdconta = pr_nrdconta
           AND crapcpt.nrconven = pr_nrconven;
      rw_crapcpt cr_crapcpt%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
			
    BEGIN

      BEGIN
        INSERT 
          INTO tbcobran_cpt_log(cdcooper, 
                                nrdconta, 
                                nrconven, 
                                dhgerlog, 
                                cdoperad, 
                                cdprograma, 
                                tpmanipulacao, 
                                nmtabela, 
                                nmdcampo, 
                                dsinf_anterior, 
                                dsinf_atual)
        VALUES(pr_cdcooper
              ,pr_nrdconta
              ,pr_nrconven
              ,SYSDATE
              ,pr_cdoperad
              ,pr_cdprograma
              ,pr_tpmanipulacao
              ,pr_nmtabela
              ,pr_nmdcampo
              ,pr_dsinf_anterior
              ,pr_dsinf_atual);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral na rotina PGTA0001.pc_gera_log_conv: Chave duplicada.';          
          ROLLBACK;
        WHEN OTHERS THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral na rotina PGTA0001.pc_gera_log_conv: ' || SQLERRM;
          
          ROLLBACK;
      END; 
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina PGTA0001.pc_gera_log_conv: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_gera_log_conv;
  
  PROCEDURE pc_deleta_email_ret(pr_cdcooper IN crapcop.cdcooper%TYPE      --> Cooperativa
                               ,pr_nrdconta IN crapcpt.nrdconta%TYPE      --> Numero da conta
                               ,pr_nrconven IN crapcpt.nrconven%TYPE      --> Numero convenio
                               ,pr_idseqttl IN crapttl.idseqttl%TYPE      --> Titular
                               ,pr_cdcritic OUT INTEGER                   --> Código do erro
                               ,pr_dscritic OUT VARCHAR2) IS              --> Descricao do erro                               
  BEGIN

    /* .............................................................................

    Programa: pc_deleta_email_ret
    Sistema : Ayllos Web
    Autor   : Tiago
    Data    : Agosto - 2017.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para limpar os email de retorno do convenio de arquivo de pagto.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
			
    BEGIN
      BEGIN
        DELETE FROM tbcobran_cpt_cem 
        WHERE tbcobran_cpt_cem.cdcooper = pr_cdcooper
          AND tbcobran_cpt_cem.nrdconta = pr_nrdconta
          AND tbcobran_cpt_cem.nrconven = pr_nrconven;
      EXCEPTION
        WHEN OTHERS THEN
           vr_dscritic := 'Problemas para limpar os emails de retorno, detalhes: '||SQLERRM;
           RAISE vr_exc_saida;          
      END;      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;        
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina PGTA0001.pc_deleta_email_ret: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_deleta_email_ret;
  
	PROCEDURE pc_cancela_convenio(pr_nrdconta IN crapcpt.nrdconta%TYPE   --> Numero da conta
                               ,pr_nrconven IN crapcpt.nrconven%TYPE   --> Numero convenio
                               ,pr_xmllog   IN VARCHAR2                --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype      --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS           --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_cancela_convenio
    Sistema : Ayllos Web
    Autor   : Tiago
    Data    : Agosto - 2017.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para cancelar o convenio de pagto por arquivo

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados do indicador
			CURSOR cr_crapcpt(pr_cdcooper crapcpt.cdcooper%TYPE
                       ,pr_nrdconta crapcpt.nrdconta%TYPE
                       ,pr_nrconven crapcpt.nrconven%TYPE) IS
			  SELECT * 
          FROM crapcpt
         WHERE crapcpt.cdcooper = pr_cdcooper
           AND crapcpt.nrdconta = pr_nrdconta
           AND crapcpt.nrconven = pr_nrconven;
      rw_crapcpt cr_crapcpt%ROWTYPE;

      CURSOR cr_craphpt(pr_cdcooper craphpt.cdcooper%TYPE
                       ,pr_nrdconta craphpt.nrdconta%TYPE
                       ,pr_nrconven craphpt.nrconven%TYPE) IS
        SELECT COUNT(*) quantidade
          FROM craphpt hpt
         WHERE hpt.intipmvt = 1 /*remessa*/
           AND hpt.nrdconta = pr_nrdconta
           AND hpt.cdcooper = pr_cdcooper
           AND hpt.nrconven = pr_nrconven;
      rw_craphpt cr_craphpt%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Cancelamento do convenio pagamento por arquivo';
			vr_nrdrowid ROWID;
			vr_dsfativo VARCHAR2(10);
			vr_tpindica VARCHAR2(100);
			
    BEGIN

			-- Extrai dados do xml
			gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

		  -- Alimenta descrição da origem
		  vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));

		  OPEN cr_crapcpt(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrconven => pr_nrconven);
			FETCH cr_crapcpt INTO rw_crapcpt;

			-- Se existe
			IF cr_crapcpt%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_crapcpt;
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Atenção! Convenio nao encontrado!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;
			-- Fecha cursor
			CLOSE cr_crapcpt;
      
		  OPEN cr_craphpt(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrconven => pr_nrconven);
			FETCH cr_craphpt INTO rw_craphpt;

			-- Se existe
			IF cr_craphpt%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_craphpt;
				-- Gera crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Atenção! Nao foi possivel consultar as remessas do convenio!';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;
			-- Fecha cursor
			CLOSE cr_craphpt;      

      IF rw_craphpt.quantidade > 0 THEN 
         vr_cdcritic := 0;
				 vr_dscritic := 'Atenção! Convenio com remessa, nao e possivel cancelar!';
				 -- Levanta exceção
				 RAISE vr_exc_saida;
      END IF;       

      pc_deleta_email_ret(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrconven => pr_nrconven
                         ,pr_idseqttl => 1
                         ,pr_cdcritic => vr_dscritic
                         ,pr_dscritic => vr_cdcritic);
                         
      IF vr_cdcritic > 0 OR
         vr_dscritic IS NOT NULL THEN
				 -- Levanta exceção
				 RAISE vr_exc_saida;
      END IF;       

      BEGIN
        
        DELETE 
          FROM crapcpt
         WHERE crapcpt.cdcooper = vr_cdcooper
           AND crapcpt.nrdconta = pr_nrdconta
           AND crapcpt.nrconven = pr_nrconven;
           
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Atenção! Houve erro durante a exclusao, detalhes: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;
      
      pc_gera_log_conv(pr_cdcooper       => vr_cdcooper
                      ,pr_nrdconta       => pr_nrdconta
                      ,pr_nrconven       => pr_nrconven
                      ,pr_cdoperad       => vr_cdoperad
                      ,pr_cdprograma     => 'PGTA0001.pc_cancela_convenio'
                      ,pr_tpmanipulacao  => 2 --> Exclusao
                      ,pr_nmtabela       => 'CRAPCPT'
                      ,pr_nmdcampo       => NULL
                      ,pr_dsinf_anterior => NULL
                      ,pr_dsinf_atual    => 'Exclusao do convênio de agendamento de pagamento'
                      ,pr_cdcritic       => vr_cdcritic
                      ,pr_dscritic       => vr_dscritic);
                      
      IF vr_cdcritic > 0 OR
         vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
      
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina PGTA0001.pc_cancela_convenio: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_cancela_convenio;

	PROCEDURE pc_inserir_convenio(pr_nrdconta IN crapcpt.nrdconta%TYPE   --> Numero da conta
                               ,pr_nrconven IN crapcpt.nrconven%TYPE   --> Numero convenio
                               ,pr_flghomol IN crapcpt.flghomol%TYPE   --> Homologado
                               ,pr_idretorn IN crapcpt.idretorn%TYPE   --> Tipo de transmissao (1=Internet, 2=FTP)
                               ,pr_flgativo IN crapcpt.flgativo%TYPE   --> Convenio ativo
                               ,pr_xmllog   IN VARCHAR2                --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype      --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS           --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_inserir_convenio
    Sistema : Ayllos Web
    Autor   : Tiago
    Data    : Agosto - 2017.                Ultima atualizacao: 24/11/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para incluir o convenio de pagto por arquivo

    Alteracoes: 24/11/2017 - Adicinar DECODE no campo inpessoa (Douglas - Melhoria 271.3)
                20/04/2018 - Adicionada verificação de adesao do produto 39 Pagamento por 
                             por Arquivo. PRJ366 (Lombardi).
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Inclusao do convenio pagamento por arquivo';
			vr_nrdrowid ROWID;
			vr_dsfativo VARCHAR2(10);
			vr_tpindica VARCHAR2(100);
      
      CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT DECODE(crapass.inpessoa,1,1,2) inpessoa
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
          
			
    BEGIN

			-- Extrai dados do xml
			gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      
      IF cr_crapass%NOTFOUND THEN
         CLOSE cr_crapass;         
         vr_dscritic := 'Atencao! Conta nao encontrada.';
         RAISE vr_exc_saida;
      END IF;
      
      CLOSE cr_crapass;

      IF rw_crapass.inpessoa <> 2 THEN
         vr_dscritic := 'Inclusao permitida apenas para Pessoa Jurídica.';
         RAISE vr_exc_saida;
      END IF;


      -- Valida adesao do produto
      CADA0006.pc_valida_adesao_produto(pr_cdcooper => vr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_cdprodut => 39 -- Pagto por Arquivo
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
      
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
		  -- Alimenta descrição da origem
		  --vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));

      BEGIN
        INSERT 
          INTO crapcpt(cdcooper
                      ,nrdconta
                      ,nrconven
                      ,dtdadesa
                      ,nrctrcpt
                      ,flghomol
                      ,dtdhomol
                      ,cdopehom
                      ,idretorn
                      ,cdoperad
                      ,dtaltera
                      ,flgativo)
           VALUES(vr_cdcooper
                 ,pr_nrdconta
                 ,pr_nrconven
                 ,TRUNC(SYSDATE)
                 ,1
                 ,pr_flghomol
                 ,DECODE(pr_flghomol,1,TRUNC(SYSDATE),NULL)
                 ,DECODE(pr_flghomol,1,vr_cdoperad,NULL)
                 ,pr_idretorn
                 ,vr_cdoperad
                 ,TRUNC(SYSDATE)
                 ,pr_flgativo);
           
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Atenção! Houve erro durante a inclusao, detalhes: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;      

      pc_gera_log_conv(pr_cdcooper       => vr_cdcooper
                      ,pr_nrdconta       => pr_nrdconta
                      ,pr_nrconven       => pr_nrconven
                      ,pr_cdoperad       => vr_cdoperad
                      ,pr_cdprograma     => 'PGTA0001.pc_inserir_convenio'
                      ,pr_tpmanipulacao  => 0 --> Inclusao
                      ,pr_nmtabela       => 'CRAPCPT'
                      ,pr_nmdcampo       => NULL
                      ,pr_dsinf_anterior => NULL
                      ,pr_dsinf_atual    => 'Adesão ao convênio de agendamento de pagamento'
                      ,pr_cdcritic       => vr_cdcritic
                      ,pr_dscritic       => vr_dscritic);
                      
      IF vr_cdcritic > 0 OR
         vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;                      

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina PGTA0001.pc_inserir_convenio: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_inserir_convenio;

  PROCEDURE pc_inserir_emails(pr_nrdconta IN crapcpt.nrdconta%TYPE   --> Numero da conta
                             ,pr_nrconven IN crapcpt.nrconven%TYPE   --> Numero convenio
                             ,pr_lstemail IN VARCHAR2                --> lista de emails
                             ,pr_cddopcao IN VARCHAR2                --> Opcao da tela
                             ,pr_xmllog   IN VARCHAR2                --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype      --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS           --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_inserir_emails
    Sistema : Ayllos Web
    Autor   : Tiago
    Data    : Agosto - 2017.                Ultima atualizacao: 24/11/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para incluir os emails de retorno do convenio de pagto por arquivo,
                ***apaga todos emails e insere novamente

    Alteracoes: 24/11/2017 - Adicinar DECODE no campo inpessoa (Douglas - Melhoria 271.3)
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Inclusao de emails do convenio pagamento por arquivo';
			vr_nrdrowid ROWID;
			vr_dsfativo VARCHAR2(10);
			vr_tpindica VARCHAR2(100);
      
      vr_ind INTEGER;
      
      -- Array para guardar o split dos dados contidos na dstexttb
      vr_vet_dados gene0002.typ_split;
      
      
      CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT DECODE(crapass.inpessoa,1,1,2) inpessoa
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;


      CURSOR cr_cptcem( pr_cdcooper crapceb.cdcooper%TYPE,
                        pr_nrdconta crapceb.nrdconta%TYPE ) IS
        SELECT crapcem.dsdemail,
               crapcem.cddemail
          FROM tbcobran_cpt_cem,
               crapcem 
         WHERE tbcobran_cpt_cem.cdcooper = pr_cdcooper
           AND tbcobran_cpt_cem.nrdconta = pr_nrdconta
           AND tbcobran_cpt_cem.idseqttl = 1 /*primeiro titular*/
           AND tbcobran_cpt_cem.cdcooper = crapcem.cdcooper
           AND tbcobran_cpt_cem.nrdconta = crapcem.nrdconta
           AND tbcobran_cpt_cem.idseqttl = crapcem.idseqttl
           AND tbcobran_cpt_cem.cddemail = crapcem.cddemail; 
      rw_cptcem cr_cptcem%ROWTYPE;
      
      CURSOR cr_crapcem(pr_cdcooper crapceb.cdcooper%TYPE,
                        pr_nrdconta crapceb.nrdconta%TYPE,
                        pr_cddemail crapcem.cddemail%TYPE) IS
        SELECT crapcem.dsdemail
          FROM crapcem 
         WHERE crapcem.cdcooper = pr_cdcooper
           AND crapcem.nrdconta = pr_nrdconta
           AND crapcem.cddemail = pr_cddemail
           AND crapcem.idseqttl = 1;
      rw_crapcem cr_crapcem%ROWTYPE;
      
      TYPE typ_tab_email IS TABLE OF cr_cptcem%ROWTYPE
      INDEX BY VARCHAR2(5); --nrconven(5)
      
      vr_tab_email typ_tab_email; 
			
    BEGIN

			-- Extrai dados do xml
			gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;
      
      vr_tab_email.DELETE;
      FOR rw_cptcem IN cr_cptcem(pr_cdcooper => vr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP
          vr_tab_email(TO_CHAR(rw_cptcem.cddemail)) := rw_cptcem;
      END LOOP;      
      
      vr_vet_dados := gene0002.fn_quebra_string(pr_string => pr_lstemail, pr_delimit => ';');      

      IF vr_vet_dados.count() = 0 THEN
         vr_dscritic := 'Para forma de envio de arquivos Internet Banking é obrigatorio informar endereço de e-mail.';
         RAISE vr_exc_saida;         
      END IF;   

      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      
      IF cr_crapass%NOTFOUND THEN
         CLOSE cr_crapass;         
         vr_dscritic := 'Atencao! Conta nao encontrada.';
         RAISE vr_exc_saida;
      END IF;
      
      CLOSE cr_crapass;

      IF rw_crapass.inpessoa <> 2 THEN
         vr_dscritic := 'Inclusao permitida apenas para Pessoa Jurídica.';
         RAISE vr_exc_saida;
      END IF;

      pc_deleta_email_ret(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrconven => pr_nrconven
                         ,pr_idseqttl => 1
                         ,pr_cdcritic => vr_dscritic
                         ,pr_dscritic => vr_cdcritic);
                         
      IF vr_cdcritic > 0 OR
         vr_dscritic IS NOT NULL THEN
				 -- Levanta exceção
				 RAISE vr_exc_saida;
      END IF;       

      vr_ind := vr_vet_dados.FIRST;
      
      WHILE vr_ind IS NOT NULL LOOP       
        
        IF NOT vr_tab_email.EXISTS(vr_vet_dados(vr_ind)) THEN

          OPEN cr_crapcem(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_cddemail => vr_vet_dados(vr_ind));
          FETCH cr_crapcem INTO rw_crapcem;
          
          IF cr_crapcem%NOTFOUND THEN             
             CLOSE cr_crapcem;
             vr_dscritic := 'Email nao encontrado.';
             RAISE vr_exc_saida;
          END IF;

          CLOSE cr_crapcem;
          
          pc_gera_log_conv(pr_cdcooper       => vr_cdcooper
                          ,pr_nrdconta       => pr_nrdconta
                          ,pr_nrconven       => pr_nrconven
                          ,pr_cdoperad       => vr_cdoperad
                          ,pr_cdprograma     => 'PGTA0001.pc_inserir_emails'
                          ,pr_tpmanipulacao  => 0 --> Inclusao
                          ,pr_nmtabela       => 'TBCOBRAN_CPT_CEM'
                          ,pr_nmdcampo       => NULL
                          ,pr_dsinf_anterior => NULL
                          ,pr_dsinf_atual    => rw_crapcem.dsdemail
                          ,pr_cdcritic       => vr_cdcritic
                          ,pr_dscritic       => vr_dscritic);
                          
          IF vr_cdcritic > 0 OR
             vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;                     
          
        END IF;      
      
        BEGIN
          INSERT 
            INTO tbcobran_cpt_cem(cdcooper
                                 ,nrdconta
                                 ,nrconven
                                 ,idseqttl
                                 ,cddemail)
                          VALUES(vr_cdcooper
                                ,pr_nrdconta
                                ,pr_nrconven
                                ,1
                                ,vr_vet_dados(vr_ind));
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Atenção! Houve erro durante a inclusao, detalhes: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;      
        
        vr_ind := vr_vet_dados.next(vr_ind);   
      END LOOP;
      
      vr_ind := vr_tab_email.FIRST;
      
      WHILE vr_ind IS NOT NULL LOOP       
      
      
        
          IF NOT vr_vet_dados.EXISTS(vr_ind) THEN
            --Logar como removido
            pc_gera_log_conv(pr_cdcooper       => vr_cdcooper
                            ,pr_nrdconta       => pr_nrdconta
                            ,pr_nrconven       => pr_nrconven
                            ,pr_cdoperad       => vr_cdoperad
                            ,pr_cdprograma     => 'PGTA0001.pc_inserir_emails'
                            ,pr_tpmanipulacao  => 2 --> Exclusao
                            ,pr_nmtabela       => 'TBCOBRAN_CPT_CEM'
                            ,pr_nmdcampo       => NULL
                            ,pr_dsinf_anterior => NULL
                            ,pr_dsinf_atual    => vr_tab_email(vr_ind).dsdemail
                            ,pr_cdcritic       => vr_cdcritic
                            ,pr_dscritic       => vr_dscritic);
                            
            IF vr_cdcritic > 0 OR
               vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
            END IF;
                  
          END IF;
      
        vr_ind := vr_tab_email.next(vr_ind);   
        
      END LOOP;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina PGTA0001.pc_inserir_convenio: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_inserir_emails;


	PROCEDURE pc_alterar_convenio(pr_nrdconta IN crapcpt.nrdconta%TYPE   --> Numero da conta
                               ,pr_nrconven IN crapcpt.nrconven%TYPE   --> Numero convenio
                               ,pr_flghomol IN crapcpt.flghomol%TYPE   --> Homologado
                               ,pr_idretorn IN crapcpt.idretorn%TYPE   --> Tipo de transmissao (1=Internet, 2=FTP)
                               ,pr_flgativo IN crapcpt.flgativo%TYPE   --> Convenio ativo
                               ,pr_xmllog   IN VARCHAR2                --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype      --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS           --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_alterar_convenio
    Sistema : Ayllos Web
    Autor   : Tiago
    Data    : Agosto - 2017.                Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar o convenio de pagto por arquivo

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

			-- Variaveis auxiliares
      vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
			vr_dstransa VARCHAR2(1000) := 'Alteracao do convenio pagamento por arquivo';
			vr_nrdrowid ROWID;
			vr_dsfativo VARCHAR2(10);
			vr_tpindica VARCHAR2(100);
      
      --Flag para logar os campos
      log_flghomol BOOLEAN:=FALSE;
      log_cdopehom BOOLEAN:=FALSE;
      log_dtdhomol BOOLEAN:=FALSE;
      log_idretorn BOOLEAN:=FALSE;
      log_flgativo BOOLEAN:=FALSE;
      
      vr_flghomol crapcpt.flghomol%TYPE;
      vr_cdopehom crapcpt.cdopehom%TYPE;
      vr_dtdhomol crapcpt.dtdhomol%TYPE;
      vr_idretorn crapcpt.idretorn%TYPE;
      vr_flgativo crapcpt.flgativo%TYPE;
      
      CURSOR cr_crapcpt(pr_cdcooper crapcpt.cdcooper%TYPE
                       ,pr_nrdconta crapcpt.nrdconta%TYPE
                       ,pr_nrconven crapcpt.nrconven%TYPE) IS
        SELECT * 
          FROM crapcpt
         WHERE crapcpt.cdcooper = pr_cdcooper
           AND crapcpt.nrdconta = pr_nrdconta
           AND crapcpt.nrconven = pr_nrconven;
      rw_crapcpt cr_crapcpt%ROWTYPE;     
			
    BEGIN

			-- Extrai dados do xml
			gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

		  -- Alimenta descrição da origem
		  --vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));

      OPEN cr_crapcpt(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrconven => pr_nrconven);
      FETCH cr_crapcpt INTO rw_crapcpt;
      
      IF cr_crapcpt%NOTFOUND THEN
         CLOSE cr_crapcpt;
         
				 vr_dscritic := 'Atenção! Nao foi possivel encontrar o convenio.';
				 RAISE vr_exc_saida;        
      END IF;              

      CLOSE cr_crapcpt;
      
      IF pr_idretorn > 1 THEN
        
        pc_deleta_email_ret(pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrconven => pr_nrconven
                           ,pr_idseqttl => 1
                           ,pr_cdcritic => vr_dscritic
                           ,pr_dscritic => vr_cdcritic);        

        IF vr_cdcritic > 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
           -- Levanta exceção
           RAISE vr_exc_saida;
        END IF;       
                           
      END IF;

      IF pr_flghomol <> rw_crapcpt.flghomol THEN
         vr_flghomol := pr_flghomol;
         
         --Se tirou de homolgado zera os valores         
         IF pr_flghomol = 0 THEN
           vr_dtdhomol := NULL;
           vr_cdopehom := '';
         ELSE
           vr_dtdhomol := TRUNC(SYSDATE);        
           vr_cdopehom := vr_cdoperad;
         END IF;
         
         log_flghomol := TRUE;
      ELSE
         vr_flghomol := rw_crapcpt.flghomol;
         vr_cdopehom := rw_crapcpt.cdopehom;
         vr_dtdhomol := rw_crapcpt.dtdhomol;        
         
         log_flghomol := FALSE;         
      END IF;

      IF pr_idretorn <> rw_crapcpt.idretorn THEN
         vr_idretorn := pr_idretorn;
         
         log_idretorn := TRUE;
      ELSE
         vr_idretorn := rw_crapcpt.idretorn;  
         
         log_idretorn := FALSE;
      END IF;
      
      IF pr_flgativo <> rw_crapcpt.flgativo THEN
         vr_flgativo := pr_flgativo;
         
         log_flgativo := TRUE;
      ELSE
         vr_flgativo := rw_crapcpt.flgativo;  
         
         log_flgativo := FALSE;
      END IF;
      

      BEGIN
        
        UPDATE crapcpt
           SET flghomol = vr_flghomol
              ,dtdhomol = vr_dtdhomol
              ,cdopehom = vr_cdopehom
              ,idretorn = vr_idretorn
              ,cdoperad = vr_cdoperad
              ,dtaltera = TRUNC(SYSDATE)
              ,flgativo = vr_flgativo
         WHERE crapcpt.cdcooper = vr_cdcooper
           AND crapcpt.nrconven = pr_nrconven
           AND crapcpt.nrdconta = pr_nrdconta;
           
			EXCEPTION
				WHEN OTHERS THEN
					vr_dscritic := 'Atenção! Houve erro durante a alteracao, detalhes: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;      

      --Verificar se os campoos foram alterados e gravar LOG      
      vr_cdcritic := 0;
      vr_dscritic := NULL;
      
      IF log_flghomol THEN
      
        pc_gera_log_conv(pr_cdcooper       => vr_cdcooper
                        ,pr_nrdconta       => pr_nrdconta
                        ,pr_nrconven       => pr_nrconven
                        ,pr_cdoperad       => vr_cdoperad
                        ,pr_cdprograma     => 'PGTA0001.pc_alterar_convenio'
                        ,pr_tpmanipulacao  => 1 --> Alteracao
                        ,pr_nmtabela       => 'CRAPCPT'
                        ,pr_nmdcampo       => 'FLGHOMOL'
                        ,pr_dsinf_anterior => TO_CHAR(rw_crapcpt.flghomol)
                        ,pr_dsinf_atual    => TO_CHAR(vr_flghomol)
                        ,pr_cdcritic       => vr_cdcritic
                        ,pr_dscritic       => vr_dscritic);
                        
        IF vr_cdcritic > 0 OR
           vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
        END IF;

        pc_gera_log_conv(pr_cdcooper       => vr_cdcooper
                        ,pr_nrdconta       => pr_nrdconta
                        ,pr_nrconven       => pr_nrconven
                        ,pr_cdoperad       => vr_cdoperad
                        ,pr_cdprograma     => 'PGTA0001.pc_alterar_convenio'
                        ,pr_tpmanipulacao  => 1 --> Alteracao
                        ,pr_nmtabela       => 'CRAPCPT'
                        ,pr_nmdcampo       => 'CDOPEHOM'
                        ,pr_dsinf_anterior => TO_CHAR(rw_crapcpt.cdopehom)
                        ,pr_dsinf_atual    => TO_CHAR(vr_cdopehom)
                        ,pr_cdcritic       => vr_cdcritic
                        ,pr_dscritic       => vr_dscritic);

        IF vr_cdcritic > 0 OR
           vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
        END IF;

        pc_gera_log_conv(pr_cdcooper       => vr_cdcooper
                        ,pr_nrdconta       => pr_nrdconta
                        ,pr_nrconven       => pr_nrconven
                        ,pr_cdoperad       => vr_cdoperad
                        ,pr_cdprograma     => 'PGTA0001.pc_alterar_convenio'
                        ,pr_tpmanipulacao  => 1 --> Alteracao
                        ,pr_nmtabela       => 'CRAPCPT'
                        ,pr_nmdcampo       => 'DTDHOMOL'
                        ,pr_dsinf_anterior => TO_CHAR(rw_crapcpt.dtdhomol,'DD/MM/RRRR')
                        ,pr_dsinf_atual    => TO_CHAR(vr_dtdhomol,'DD/MM/RRRR')
                        ,pr_cdcritic       => vr_cdcritic
                        ,pr_dscritic       => vr_dscritic);

        IF vr_cdcritic > 0 OR
           vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
        END IF;
        
      END IF;
      
      IF log_idretorn THEN

        pc_gera_log_conv(pr_cdcooper       => vr_cdcooper
                        ,pr_nrdconta       => pr_nrdconta
                        ,pr_nrconven       => pr_nrconven
                        ,pr_cdoperad       => vr_cdoperad
                        ,pr_cdprograma     => 'PGTA0001.pc_alterar_convenio'
                        ,pr_tpmanipulacao  => 1 --> Alteracao
                        ,pr_nmtabela       => 'CRAPCPT'
                        ,pr_nmdcampo       => 'IDRETORN'
                        ,pr_dsinf_anterior => TO_CHAR(rw_crapcpt.idretorn)
                        ,pr_dsinf_atual    => TO_CHAR(vr_idretorn)
                        ,pr_cdcritic       => vr_cdcritic
                        ,pr_dscritic       => vr_dscritic);

        IF vr_cdcritic > 0 OR
           vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
        END IF;
        
      END IF;
      
      IF log_flgativo THEN

        pc_gera_log_conv(pr_cdcooper       => vr_cdcooper
                        ,pr_nrdconta       => pr_nrdconta
                        ,pr_nrconven       => pr_nrconven
                        ,pr_cdoperad       => vr_cdoperad
                        ,pr_cdprograma     => 'PGTA0001.pc_alterar_convenio'
                        ,pr_tpmanipulacao  => 1 --> Alteracao
                        ,pr_nmtabela       => 'CRAPCPT'
                        ,pr_nmdcampo       => 'FLGATIVO'
                        ,pr_dsinf_anterior => TO_CHAR(rw_crapcpt.flgativo)
                        ,pr_dsinf_atual    => TO_CHAR(vr_flgativo)
                        ,pr_cdcritic       => vr_cdcritic
                        ,pr_dscritic       => vr_dscritic);
                        
        IF vr_cdcritic > 0 OR
           vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
        END IF;
        
      END IF;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina PGTA0001.pc_inserir_convenio: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_alterar_convenio;

  PROCEDURE pc_consulta_log(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                             ,pr_dtiniper IN VARCHAR2 --> Inicio do periodo
                             ,pr_dtfimper IN VARCHAR2 --> Fim do periodo
                             ,pr_nmtabela IN tbcobran_cpt_log.nmtabela%TYPE --> Nome da tabela
                             ,pr_nmdocampo IN tbcobran_cpt_log.nmdcampo%TYPE --> Nome do campo
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................
    
        Programa: pc_consulta_log
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Tiago
        Data    : Agosto/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Retornar lista com os log do convenio 
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    ---------> CURSORES <--------
    --> Buscar logs
    CURSOR cr_tbcobran_cpt_log( pr_cdcooper crapceb.cdcooper%TYPE,
                                pr_nrdconta crapceb.nrdconta%TYPE,
                                pr_dtiniper crapdat.dtmvtolt%TYPE,
                                pr_dtfimper crapdat.dtmvtolt%TYPE) IS
      SELECT to_char(log.dhgerlog,'DD/MM/RRRR HH24:MI:SS') dhgerlog
            ,log.cdoperad
            ,ope.nmoperad
            ,log.cdprograma
            ,log.tpmanipulacao
            ,log.nmtabela
            ,log.nmdcampo
            ,log.dsinf_anterior
            ,log.dsinf_atual
        FROM tbcobran_cpt_log log
            ,crapope ope
       WHERE log.cdcooper = pr_cdcooper
         AND log.nrdconta = pr_nrdconta
         AND TRUNC(log.dhgerlog) BETWEEN pr_dtiniper AND pr_dtfimper
         AND ope.cdcooper = log.cdcooper
         AND ope.cdoperad = log.cdoperad
         ORDER BY log.dhgerlog DESC;
    
    -- Variaveis genericas
    vr_dtiniper crapdat.dtmvtolt%TYPE;
    vr_dtfimper crapdat.dtmvtolt%TYPE;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
      
    vr_dsmanipulacao  VARCHAR2(40);
    vr_nmdcampo       tbcobran_cpt_log.nmdcampo%TYPE;
    vr_nmtabela       tbcobran_cpt_log.nmtabela%TYPE;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
  BEGIN
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    BEGIN
      vr_dtiniper := TO_DATE(pr_dtiniper,'DD/MM/RRRR');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Data inicial invalida.';
        RAISE vr_exc_saida;
    END ;

    BEGIN
      vr_dtfimper := TO_DATE(pr_dtfimper,'DD/MM/RRRR');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Data final invalida.';
        RAISE vr_exc_saida;
    END ;
    
    -- Leitura da PL/Table e geração do arquivo XML
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
    
    --> buscar logs ceb
    FOR rw_log IN cr_tbcobran_cpt_log ( pr_cdcooper => vr_cdcooper,
                                        pr_nrdconta => pr_nrdconta,
                                        pr_dtiniper => vr_dtiniper,
                                        pr_dtfimper => vr_dtfimper ) LOOP
                                        
      CASE rw_log.tpmanipulacao
        WHEN 0 THEN vr_dsmanipulacao := 'INCLUSAO';
        WHEN 1 THEN vr_dsmanipulacao := 'ALTERACAO';
        WHEN 2 THEN vr_dsmanipulacao := 'EXCLUSAO';
        ELSE vr_dsmanipulacao := '';
      END CASE;

      CASE UPPER(rw_log.nmtabela)
        WHEN 'CRAPCPT' THEN vr_nmtabela := 'CONVENIO';
        WHEN 'TBCOBRAN_CPT_CEM' THEN vr_nmtabela := 'EMAIL';
        ELSE vr_nmtabela := '';
      END CASE;

      CASE UPPER(rw_log.nmdcampo)
        WHEN 'CDOPEHOM' THEN vr_nmdcampo := 'OPERADOR HOMOLOGACAO';
        WHEN 'FLGHOMOL' THEN vr_nmdcampo := 'HOMOLOGADO';
        WHEN 'DTDHOMOL' THEN vr_nmdcampo := 'DATA HOMOLOGACAO';
        WHEN 'IDRETORN' THEN vr_nmdcampo := 'TIPO RETORNO';
        WHEN 'FLGATIVO' THEN vr_nmdcampo := 'ATIVO';
        WHEN 'DTDADESA' THEN vr_nmdcampo := 'DATA ADESAO';
        ELSE vr_nmdcampo := '';
      END CASE;
                                          
      pc_escreve_xml('<inf>'||
                        '<dhgerlog>' || rw_log.dhgerlog ||'</dhgerlog>' ||
                        '<cdoperad>' || rw_log.cdoperad ||'</cdoperad>' ||
                        '<nmoperad>' || rw_log.nmoperad    ||'</nmoperad>' ||
                        '<cdprograma>' || rw_log.cdprograma ||'</cdprograma>' ||
                        '<tpmanipulacao>' || rw_log.tpmanipulacao ||'</tpmanipulacao>' ||
                        '<dsmanipulacao>' || vr_dsmanipulacao ||'</dsmanipulacao>' ||
                        '<nmtabela>' || rw_log.nmtabela ||'</nmtabela>' ||
                        '<nmdcampo>' || rw_log.nmdcampo ||'</nmdcampo>' ||
                        '<dsdadant>' || rw_log.dsinf_anterior ||'</dsdadant>' ||
                        '<dsdadatu>' || rw_log.dsinf_atual ||'</dsdadatu>' ||
                        '<dsnmdcampo>' || vr_nmdcampo ||'</dsnmdcampo>' ||
                        '<dsnmtabela>' || vr_nmtabela ||'</dsnmtabela>' ||
                     '</inf>');
                     
    END LOOP;
    
    pc_escreve_xml('</dados></root>',TRUE);    
    pr_retxml := XMLType.createXML(vr_des_xml);
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_consulta_log;     

  PROCEDURE pc_carrega_crapcem(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................
    
        Programa: pc_carrega_crapcem
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Tiago
        Data    : Agosto/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Retornar lista com os emails cadastrados na crapcem para a conta
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    ---------> CURSORES <--------
    --> Buscar logs
    CURSOR cr_crapcem( pr_cdcooper crapceb.cdcooper%TYPE,
                       pr_nrdconta crapceb.nrdconta%TYPE ) IS
      SELECT *
        FROM crapcem             
       WHERE crapcem.cdcooper = pr_cdcooper
         AND crapcem.nrdconta = pr_nrdconta
         AND crapcem.idseqttl = 1; /*primeiro titular*/
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
      
    vr_dsmanipulacao  VARCHAR2(40);
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
  BEGIN
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    -- Leitura da PL/Table e geração do arquivo XML
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
    
    --> buscar logs ceb
    FOR rw_crapcem IN cr_crapcem ( pr_cdcooper => vr_cdcooper,
                                   pr_nrdconta => pr_nrdconta ) LOOP
      pc_escreve_xml('<inf>'||
                        '<cddemail>' || rw_crapcem.cddemail ||'</cddemail>' ||
                        '<dsdemail>' || rw_crapcem.dsdemail ||'</dsdemail>' ||
                     '</inf>');
                     
    END LOOP;
    
    pc_escreve_xml('</dados></root>',TRUE);    
    pr_retxml := XMLType.createXML(vr_des_xml);
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_carrega_crapcem;     

  PROCEDURE pc_carrega_cptcem(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................
    
        Programa: pc_carrega_cptcem
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Tiago
        Data    : Agosto/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Retornar lista com os emails cadastrados na tbcobran_cpt_cem para a conta
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    ---------> CURSORES <--------
    --> Buscar logs
    CURSOR cr_cptcem( pr_cdcooper crapceb.cdcooper%TYPE,
                      pr_nrdconta crapceb.nrdconta%TYPE ) IS
      SELECT crapcem.dsdemail,
             crapcem.cddemail
        FROM tbcobran_cpt_cem,
             crapcem 
       WHERE tbcobran_cpt_cem.cdcooper = pr_cdcooper
         AND tbcobran_cpt_cem.nrdconta = pr_nrdconta
         AND tbcobran_cpt_cem.idseqttl = 1 /*primeiro titular*/
         AND tbcobran_cpt_cem.cdcooper = crapcem.cdcooper
         AND tbcobran_cpt_cem.nrdconta = crapcem.nrdconta
         AND tbcobran_cpt_cem.idseqttl = crapcem.idseqttl
         AND tbcobran_cpt_cem.cddemail = crapcem.cddemail; 
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
      
    vr_dsmanipulacao  VARCHAR2(40);
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
  BEGIN
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    -- Leitura da PL/Table e geração do arquivo XML
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
    
    --> buscar logs ceb
    FOR rw_cptcem IN cr_cptcem ( pr_cdcooper => vr_cdcooper,
                                 pr_nrdconta => pr_nrdconta ) LOOP
      pc_escreve_xml('<inf>'||
                        '<cddemail>' || rw_cptcem.cddemail ||'</cddemail>' ||
                        '<dsdemail>' || rw_cptcem.dsdemail ||'</dsdemail>' ||
                     '</inf>');
                     
    END LOOP;
    
    pc_escreve_xml('</dados></root>',TRUE);    
    pr_retxml := XMLType.createXML(vr_des_xml);
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_carrega_cptcem;     

  -- Procedure para verificar se o cooperado possui o convenio homologado e algum arquivo de remessa enviado
  PROCEDURE pc_verifica_conv_pgto(pr_cdcooper  IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                 ,pr_nrconven OUT INTEGER                -- Numero do Convenio
                                 ,pr_dtadesao OUT DATE                   -- Data de adesao
                                 ,pr_flghomol OUT INTEGER                -- Convenio esta homologado
                                 ,pr_idretorn OUT INTEGER                -- Retorno para o Cooperado (1-Internet/2-FTP)
                                 ,pr_fluppgto OUT INTEGER                -- Flag possui convenio habilitado
                                 ,pr_flrempgt OUT INTEGER                -- Flag possui arquivo de remessa enviado
                                 ,pr_cdcritic OUT INTEGER                -- Código do erro
                                 ,pr_dscritic OUT VARCHAR2) IS           -- Descricao do erro
  /* .............................................................................

     Programa: pc_verifica_conv_pgto
     Sistema : CECRED
     Sigla   : PGTA
     Autor   : Douglas Quisinski
     Data    : Agosto/17.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Identificar se o cooperado possui convenio homologado para 
                 upload do arquivo de agendamento de pagamento e se possui 
                 algum arquivo enviado

     Observacao: -----

     Alteracoes:
  ..............................................................................*/
  
    ---------> CURSORES <--------
    -- Identificar se o cooperado possui convenio homologado
    CURSOR cr_convenio (pr_cdcooper IN INTEGER
                       ,pr_nrdconta IN INTEGER) IS
      SELECT cpt.cdcooper
            ,cpt.nrdconta
            ,cpt.nrconven
            ,cpt.dtdadesa
            ,cpt.flghomol
            ,cpt.idretorn
        FROM crapcpt cpt
       WHERE cpt.cdcooper = pr_cdcooper 
         AND cpt.nrdconta = pr_nrdconta
         AND cpt.flghomol = 1;
    rw_convenio cr_convenio%ROWTYPE;
    
    -- Identificar se o cooperado possui algum arquivo de
    CURSOR cr_arquivo (pr_cdcooper IN INTEGER
                      ,pr_nrdconta IN INTEGER) IS
      SELECT hpt.cdcooper 
            ,hpt.nrdconta 
        FROM craphpt hpt
       WHERE hpt.cdcooper = pr_cdcooper 
         AND hpt.nrdconta = pr_nrdconta;
    rw_arquivo cr_arquivo%ROWTYPE;
    
  BEGIN
    -- Inicializar os retornos
    pr_nrconven := 0; -- Convenio
    pr_dtadesao := NULL;
    pr_flghomol := 0; -- Nao Homologado
    pr_idretorn := 0;
    pr_fluppgto := 0;
    pr_flrempgt := 0;

    -- Identificar se o convenio está homologado
    OPEN cr_convenio(pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta);
    FETCH cr_convenio INTO rw_convenio;
    -- Encontrou registro ?
    IF cr_convenio%FOUND THEN
      -- Se o convenio está homologado, então tem acesso a opção de UPLOAD
      pr_fluppgto := 1;
      -- Se o convenio esta homologado devolver os dados
      pr_nrconven := rw_convenio.nrconven;
      pr_dtadesao := rw_convenio.dtdadesa;
      pr_flghomol := rw_convenio.flghomol;
      pr_idretorn := rw_convenio.idretorn;
    END IF;
    -- Fechar o cursor
    CLOSE cr_convenio;
      
    -- Identificar se o cooperado enviou algum arquivo
    OPEN cr_arquivo(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_arquivo INTO rw_arquivo;
    -- Encontrou registro ?
    IF cr_arquivo%FOUND THEN
      -- Se o convenio está homologado, então tem acesso a opção de UPLOAD
      pr_flrempgt := 1;
    END IF;
    -- Fechar o cursor
    CLOSE cr_arquivo;
  
  EXCEPTION
    WHEN OTHERS THEN
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na rotina PGTA0001.pc_verifica_conv_pgto: ' || SQLERRM;
      ROLLBACK;

  END pc_verifica_conv_pgto;     

  -- Procedure para gerar LOG referente ao processamento do arquivo de agendamento de pagamento
  PROCEDURE pc_gera_log_arq_pgto(pr_cdcooper        IN INTEGER,  -- Cooperativa
                                 pr_nrdconta        IN INTEGER,  -- Conta
                                 pr_nrconven        IN INTEGER,  -- Convenio
                                 pr_tpmovimento     IN INTEGER,  -- Indicador do tipo de movimento (1-Remessa/ 2-Retorno)
                                 pr_nrremret        IN INTEGER,  -- Numero da Remessa
                                 pr_cdoperad        IN VARCHAR2, -- Operador logado na conta online
                                 pr_nmoperad_online IN VARCHAR2, -- Nome do operador logado na conta online
                                 pr_cdprograma      IN VARCHAR2, -- Programa que chamou a gravacao
                                 pr_nmtabela        IN VARCHAR2, -- Tabela que foi manipulada para gerar o log
                                 pr_nmarquivo       IN VARCHAR2, -- Nome do arquivo que esta sendo processado
                                 pr_dsmsglog        IN VARCHAR2, -- Descricao do LOG
                                 pr_cdcritic       OUT INTEGER,  -- Código do erro
                                 pr_dscritic       OUT VARCHAR2) IS -- Descricao do erro
    /* .............................................................................
    
       Programa: pc_verifica_conv_pgto
       Sistema : CECRED
       Sigla   : PGTA
       Autor   : Douglas Quisinski
       Data    : Agosto/17.                    Ultima atualizacao: --/--/----
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado
    
       Objetivo  : Gerar LOG referente ao processamento do arquivo de agendamento de pagamento
    
       Observacao: -----
    
       Alteracoes:
    ..............................................................................*/
    --
      PRAGMA AUTONOMOUS_TRANSACTION;
    --
  BEGIN
    INSERT INTO tbcobran_hpt_log
      (cdcooper,
       nrdconta,
       nrconven,
       tpmovimento,
       nrremret,
       dhgerlog,
       cdoperad,
       nmoperad_online,
       cdprograma,
       nmtabela,
       nmarquivo,
       dsmsglog)
    VALUES
      (pr_cdcooper, -- Cooperativa
       pr_nrdconta, -- Conta
       pr_nrconven, -- Convenio
       pr_tpmovimento, -- Indicador do tipo de movimento (1-Remessa/ 2-Retorno)
       pr_nrremret, -- Numero da Remessa
       SYSDATE, -- Data e Hora da geração do log
       pr_cdoperad, -- Operador logado na conta online
       pr_nmoperad_online, -- Nome do operador logado na conta online
       pr_cdprograma, -- Programa que chamou a gravacao
       pr_nmtabela, -- Tabela que foi manipulada para gerar o log
       pr_nmarquivo, -- Nome do arquivo que esta sendo processado
       pr_dsmsglog); -- Descricao do LOG
    COMMIT;
  EXCEPTION
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na rotina PGTA0001.pc_gera_log_arq_pgto: ' ||
                     SQLERRM;
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper,
                                   pr_compleme => 'LOG: ' || pr_dsmsglog || ' - ' || pr_dscritic);
      COMMIT;
                     
  END pc_gera_log_arq_pgto;
  
  
/**************************************************************************************************/
  PROCEDURE pc_gera_log_arq_web(pr_nrdconta    IN crawepr.nrdconta%TYPE --> Nr. da Conta
                               ,pr_nrconven    IN INTEGER               --> Convenio
                               ,pr_tpmovimento IN INTEGER               --> Indicador do tipo de movimento (1-Remessa/ 2-Retorno)
                               ,pr_nrremret    IN INTEGER               --> Numero da Remessa
                               ,pr_nmoperad_online IN VARCHAR2          --> Nome do operador logado na conta online
                               ,pr_cdprograma  IN VARCHAR2              --> Programa que chamou a gravacao
                               ,pr_nmtabela    IN VARCHAR2              --> Tabela que foi manipulada para gerar o log
                               ,pr_nmarquivo   IN VARCHAR2              --> Nome do arquivo que esta sendo processado
                               ,pr_dsmsglog    IN VARCHAR2              --> Descricao do LOG
                               ,pr_xmllog      IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic    OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic    OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml      IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo    OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro    OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................
    
        Programa: pc_gera_log_arq_web
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Tiago
        Data    : Agosto/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Gerar log de arquivo de remessa
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    ---------> CURSORES <--------
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
      
    vr_dsmanipulacao  VARCHAR2(40);
    vr_nmdcampo       tbcobran_cpt_log.nmdcampo%TYPE;
    vr_nmtabela       tbcobran_cpt_log.nmtabela%TYPE;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
  BEGIN
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    -- Leitura da PL/Table e geração do arquivo XML
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');

    pc_gera_log_arq_pgto(pr_cdcooper => vr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrconven => pr_nrconven
                        ,pr_tpmovimento => pr_tpmovimento
                        ,pr_nrremret => pr_nrremret
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_nmoperad_online => pr_nmoperad_online
                        ,pr_cdprograma => pr_cdprograma
                        ,pr_nmtabela => pr_nmtabela
                        ,pr_nmarquivo => pr_nmarquivo
                        ,pr_dsmsglog => pr_dsmsglog
                        ,pr_cdcritic => vr_cdcritic
                        ,pr_dscritic => vr_dscritic);
    
    IF vr_cdcritic > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;    
                                          
    pc_escreve_xml('<msgsucess>OK</msgsucess>');
    pc_escreve_xml('</dados></root>',TRUE);    
    pr_retxml := XMLType.createXML(vr_des_xml);
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_gera_log_arq_web;
/**************************************************************************************************/ 
  
  
  -- Procedure para consultar LOG referente ao processamento do arquivo de agendamento de pagamento
  PROCEDURE pc_consulta_log_arq_pgto(pr_cdcooper  IN INTEGER, -- Cooperativa
                                     pr_nrdconta  IN INTEGER, -- Conta
                                     pr_nrconven  IN INTEGER, -- Convenio
                                     pr_nrremret  IN INTEGER, -- Numero da Remessa
                                     pr_nmtabela  IN VARCHAR2, -- Tabela que foi manipulada para gerar o log
                                     pr_nmarquivo IN VARCHAR2, -- Nome do arquivo que esta sendo processado
                                     pr_dtinilog  IN VARCHAR2, -- Data inicial de pesquisa do log
                                     pr_dtfimlog  IN VARCHAR2, -- Data inicial de pesquisa do log
                                     pr_xml_log   OUT NOCOPY CLOB, -- Descricao do LOG
                                     pr_cdcritic  OUT INTEGER, -- Código do erro
                                     pr_dscritic  OUT VARCHAR2) IS -- Descricao do erro
    /* .............................................................................
    
       Programa: pc_consulta_log_arq_pgto
       Sistema : CECRED
       Sigla   : PGTA
       Autor   : Douglas Quisinski
       Data    : Agosto/17.                    Ultima atualizacao: --/--/----
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado
    
       Objetivo  : Consultar LOG referente ao processamento do arquivo de agendamento de pagamento
    
       Observacao: -----
    
       Alteracoes:
    ..............................................................................*/

    CURSOR cr_log(pr_cdcooper IN INTEGER,
                  pr_nrdconta IN INTEGER,
                  pr_nrremret IN INTEGER,
                  pr_dtinilog IN VARCHAR2,
                  pr_dtfimlog IN VARCHAR2,
                  pr_nmarquiv IN VARCHAR2) IS
      SELECT hlog.nmarquivo,
             hlog.dsmsglog,
             to_char(hlog.dhgerlog, 'DD/MM/YYYY HH24:MI:SS') dhgerlog,
             NVL(hlog.nmoperad_online, ope.nmoperad) nmoperad
        FROM crapope ope, tbcobran_hpt_log hlog
       WHERE ope.cdoperad = hlog.cdoperad
         AND ope.cdcooper = hlog.cdcooper
         AND UPPER(hlog.nmtabela) = UPPER(pr_nmtabela)
         AND TRUNC(hlog.dhgerlog) >= TRUNC(to_date(pr_dtinilog, 'DD/MM/YYYY'))
         AND TRUNC(hlog.dhgerlog) <= TRUNC(to_date(pr_dtfimlog, 'DD/MM/YYYY'))
         AND UPPER(hlog.nmarquivo) LIKE UPPER('%' || NVL(TRIM(pr_nmarquiv), hlog.nmarquivo) || '%')
         AND hlog.nrremret = NVL(pr_nrremret, hlog.nrremret)
         AND hlog.tpmovimento = 1 -- Remessa
         AND hlog.cdcooper = pr_cdcooper
         AND hlog.nrdconta = pr_nrdconta
         AND hlog.nrconven = pr_nrconven
       ORDER BY hlog.idhptlog ASC;

    vr_xml_log      CLOB;
    vr_xml_log_temp VARCHAR(32767);

  BEGIN
    
    -- Prepara para envio do XML
    dbms_lob.createtemporary(vr_xml_log, TRUE);
    dbms_lob.open(vr_xml_log, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_xml_log,
                            pr_texto_completo => vr_xml_log_temp,
                            pr_texto_novo     => '<dados_log>');
                            
    FOR rw_log IN cr_log(pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrremret => pr_nrremret,
                         pr_dtinilog => pr_dtinilog,
                         pr_dtfimlog => pr_dtfimlog,
                         pr_nmarquiv => pr_nmarquivo) LOOP
    
      -- Escrever o LOG
      gene0002.pc_escreve_xml(pr_xml            => vr_xml_log,
                              pr_texto_completo => vr_xml_log_temp,
                              pr_texto_novo     => '<log>' || 
                                                    '<nmarquiv>' || rw_log.nmarquivo || '</nmarquiv>' ||
                                                    '<dsmsglog>' || rw_log.dsmsglog  || '</dsmsglog>' ||
                                                    '<dhgerlog>' || rw_log.dhgerlog  || '</dhgerlog>' ||
                                                    '<nmoperad>' || rw_log.nmoperad  || '</nmoperad>' || 
                                                   '</log>');
    END LOOP;

    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_xml_log,
                            pr_texto_completo => vr_xml_log_temp,
                            pr_texto_novo     => '</dados_log>',
                            pr_fecha_xml      => TRUE);

    pr_xml_log := vr_xml_log;
    
  EXCEPTION

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na rotina PGTA0001.pc_consulta_log_arq_pgto: ' || SQLERRM;
    
      pc_internal_exception(pr_cdcooper => pr_cdcooper,
                            pr_compleme => 'ERRO: ' || pr_dscritic);
    
  END pc_consulta_log_arq_pgto;


  PROCEDURE pc_consulta_log_arq_web(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                                   ,pr_nrconven IN INTEGER               --> Convenio
                                   ,pr_nrremret IN INTEGER               --> Numero da Remessa
                                   ,pr_nmtabela IN VARCHAR2              --> Tabela que foi manipulada para gerar o log
                                   ,pr_nmarquivo IN VARCHAR2             --> Nome do arquivo que esta sendo processado
                                   ,pr_dtinilog IN VARCHAR2              --> Data inicial de pesquisa do log
                                   ,pr_dtfimlog IN VARCHAR2              --> Data inicial de pesquisa do log
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................
    
        Programa: pc_consulta_log_arq_web
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Tiago
        Data    : Setembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Retornar dados do logs dos arquivos
    
        Observacao: -----
    
        Alteracoes: 
    ..............................................................................*/
    ---------> CURSORES <--------
    --> Buscar logs
    CURSOR cr_log(pr_cdcooper IN INTEGER,
                  pr_nrdconta IN INTEGER,
                  pr_nrremret IN INTEGER,
                  pr_dtinilog IN VARCHAR2,
                  pr_dtfimlog IN VARCHAR2,
                  pr_nmarquiv IN VARCHAR2) IS
      SELECT hlog.nmarquivo,
             hlog.dsmsglog,
             to_char(hlog.dhgerlog, 'DD/MM/YYYY HH24:MI:SS') dhgerlog,
             NVL(hlog.nmoperad_online, ope.nmoperad) nmoperad
        FROM crapope ope, tbcobran_hpt_log hlog
       WHERE ope.cdoperad = hlog.cdoperad
         AND ope.cdcooper = hlog.cdcooper
         AND UPPER(hlog.nmtabela) = UPPER(pr_nmtabela)
         AND TRUNC(hlog.dhgerlog) >= TRUNC(to_date(pr_dtinilog, 'DD/MM/YYYY'))
         AND TRUNC(hlog.dhgerlog) <= TRUNC(to_date(pr_dtfimlog, 'DD/MM/YYYY'))
         AND UPPER(hlog.nmarquivo) LIKE UPPER('%' || NVL(TRIM(pr_nmarquiv), hlog.nmarquivo) || '%')
         AND hlog.nrremret = NVL(pr_nrremret, hlog.nrremret)
         AND hlog.tpmovimento = 1 -- Remessa
         AND hlog.cdcooper = pr_cdcooper
         AND hlog.nrdconta = pr_nrdconta
         AND hlog.nrconven = pr_nrconven
       ORDER BY hlog.idhptlog ASC;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
      
    vr_dsmanipulacao  VARCHAR2(40);
    vr_nmdcampo       tbcobran_cpt_log.nmdcampo%TYPE;
    vr_nmtabela       tbcobran_cpt_log.nmtabela%TYPE;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
  BEGIN
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    -- Leitura da PL/Table e geração do arquivo XML
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
    
    FOR rw_log IN cr_log(pr_cdcooper => vr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrremret => pr_nrremret,
                         pr_dtinilog => pr_dtinilog,
                         pr_dtfimlog => pr_dtfimlog,
                         pr_nmarquiv => pr_nmarquivo) LOOP
    
      -- Escrever o LOG
      pc_escreve_xml('<log>'||
                        '<nmarquiv>' || rw_log.nmarquivo || '</nmarquiv>' ||
                        '<dsmsglog>' || rw_log.dsmsglog  || '</dsmsglog>' ||
                        '<dhgerlog>' || rw_log.dhgerlog  || '</dhgerlog>' ||
                        '<nmoperad>' || rw_log.nmoperad  || '</nmoperad>' || 
                     '</log>');
                                                   
    END LOOP;                                       
    
    pc_escreve_xml('</dados></root>',TRUE);    
    pr_retxml := XMLType.createXML(vr_des_xml);
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_consulta_log_arq_web;     


  -- Procedure para consultar Titulos que foram agendados por arquivo de pagamento
  PROCEDURE pc_consulta_tit_arq_pgto(pr_cdcooper         IN INTEGER,  -- Cooperativa
                                     pr_nrdconta         IN INTEGER,  -- Conta
                                     pr_nrremess         IN INTEGER,  -- Numero da Remessa
                                     pr_nmarquiv         IN VARCHAR2, -- Nome do arquivo que esta sendo processado
                                     pr_nmbenefi         IN VARCHAR2, -- Nome do arquivo que esta sendo processado
                                     pr_dscodbar         IN VARCHAR2, -- Nome do arquivo que esta sendo processado
                                     pr_idstatus         IN INTEGER,  -- Status do Titulo (1-Todos /2-Liquidado /3-Pendente de Liquidação / 4-Com erro
                                     pr_tpdata           IN INTEGER,  -- Tipo de Data que está sendo pesquisada (1-Data de Remessa / 2-Data de Vencimento / 3-Data Agendada para Pagamento)
                                     pr_dtiniper         IN DATE,     -- Data inicial de pesquisa
                                     pr_dtfimper         IN DATE,     -- Data final   de pesquisa
                                     pr_iniconta         IN INTEGER,  -- Numero de Registros da Tela
                                     pr_nrregist         IN INTEGER,  -- Numero da Registros -> Informar NULL para carregar todos os registros
                                     pr_qttotage        OUT INTEGER,  -- Quantidade Total de Agendamentos
                                     pr_tab_agd_pgt_arq OUT NOCOPY typ_tab_agd_pgt_arq, -- Tabela de Memoria com os titulos
                                     pr_cdcritic        OUT INTEGER,     -- Código do erro
                                     pr_dscritic        OUT VARCHAR2) IS -- Descricao do erro
    /* .............................................................................
    
       Programa: pc_consulta_tit_arq_pgto
       Sistema : CECRED
       Sigla   : PGTA
       Autor   : Douglas Quisinski
       Data    : Agosto/17.                    Ultima atualizacao: --/--/----
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado
    
       Objetivo  : Consultar todos os titulos que foram agendados via arquivo de upload
    
       Observacao: -----
    
       Alteracoes:
    ..............................................................................*/

    CURSOR cr_agendamentos(pr_cdcooper     IN INTEGER,
                           pr_nrdconta     IN INTEGER,
                           pr_nrremess     IN INTEGER,
                           pr_nmarquiv     IN VARCHAR2,
                           pr_dscodbar     IN VARCHAR2,
                           pr_nmbenefi     IN VARCHAR2,
                           pr_idstatus     IN INTEGER,
                           pr_dtremess_ini IN DATE,
                           pr_dtremess_fim IN DATE,
                           pr_dtvencto_ini IN DATE,
                           pr_dtvencto_fim IN DATE,
                           pr_dtdpagto_ini IN DATE,
                           pr_dtdpagto_fim IN DATE) IS
      -- Cursor definido pelo Ademir, na especificação da Melhoria 271.3
      SELECT hpt_rem.cdcooper,
             hpt_rem.nrdconta,
             hpt_rem.nrremret,
             dpt_rem.nrseqarq,
             hpt_rem.nmarquiv nmarquiv_rem,
             to_date(to_char(hpt_rem.dtdgerac, 'ddmmyyyy') || ' ' ||
                     lpad(hpt_rem.hrdgerac, 6, '0'),
                     'ddmmyyyy hh24miss') dhdgerac_rem,
             dpt_rem.nmcedent,
             dpt_rem.dscodbar,
             dpt_rem.dtvencto,
             dpt_rem.dtdpagto,
             dpt_rem.vltitulo,
             dpt_rem.vldpagto,
             dpt_rem.cdocorre || '-' || g059_rem.dsdominio dsocorre_rem,
             -- Ultimo Registro Processado
             remessa.nrnivel_urp,
             remessa.intipmvt_urp,
             remessa.nrremret_urp,
             remessa.nrseqarq_urp,
             remessa.nrconven,
             decode(dpt_urp.intipmvt, 1, 'Remessa', 2, 'Retorno') dstipmvt_urp,
             hpt_urp.nmarquiv nmarquiv_urp,
             to_date(to_char(hpt_urp.dtdgerac, 'ddmmyyyy') || ' ' ||
                     lpad(hpt_urp.hrdgerac, 6, '0'),
                     'ddmmyyyy hh24miss') dhdgerac_urp,
             dpt_urp.cdocorre cdocorre_urp,
             dpt_urp.cdocorre || '-' || g059_urp.dsdominio dsocorre_urp,
             decode(dpt_urp.cdocorre, '00', 'Liquidado', 'BD', 'Pendente de Liquidação', 'Com Erro') dssituac,
             dpt_urp.idlancto
        FROM cecred.tbcobran_arq_pgt_dominio g059_urp,
             crapdpt dpt_urp,
             craphpt hpt_urp,
             cecred.tbcobran_arq_pgt_dominio g059_rem,
             crapdpt dpt_rem,
             craphpt hpt_rem,
             (SELECT referencia.cdcooper,
                     referencia.nrdconta,
                     referencia.nrconven,
                     referencia.intipmvt,
                     referencia.nrremret,
                     referencia.nrseqarq,
                     to_number(substr(referencia.ult_reg_prc, 1, 3)) nrnivel_urp,
                     to_number(substr(referencia.ult_reg_prc, 4, 5)) intipmvt_urp,
                     to_number(substr(referencia.ult_reg_prc, 9, 10)) nrremret_urp,
                     to_number(substr(referencia.ult_reg_prc, 19, 10)) nrseqarq_urp
                FROM (SELECT dptr.cdcooper,
                             dptr.nrdconta,
                             dptr.nrconven,
                             dptr.intipmvt,
                             dptr.nrremret,
                             dptr.nrseqarq,
                             ( --  query com hierarquia para buscar a última ocorrencia de processamento do registro
                              SELECT MAX(to_char(LEVEL, 'fm000') ||
                                         to_char(dptho.intipmvt, 'fm00000') ||
                                         to_char(dptho.nrremret, 'fm0000000000') ||
                                         to_char(dptho.nrseqarq, 'fm0000000000')) dsocorre
                                FROM crapdpt dptho
                               START WITH dptho.rowid = dptr.rowid
                              CONNECT BY dptho.cdcooper = PRIOR dptho.cdcooper
                                     AND dptho.nrdconta = PRIOR dptho.nrdconta
                                     AND dptho.nrconven = PRIOR dptho.nrconven
                                     AND dptho.tpmvtorg = PRIOR dptho.intipmvt
                                     AND dptho.nrmvtorg = PRIOR dptho.nrremret
                                     AND dptho.nrarqorg = PRIOR dptho.nrseqarq) ult_reg_prc
                        FROM crapdpt dptr, craphpt hptr
                       WHERE dptr.nrremret = hptr.nrremret
                         AND dptr.intipmvt = hptr.intipmvt
                         AND dptr.nrconven = hptr.nrconven
                         AND dptr.nrdconta = hptr.nrdconta
                         AND dptr.cdcooper = hptr.cdcooper
                         AND hptr.dtmvtolt >= (
                                               select min(hptref.dtmvtolt)
                                               from crapdpt dptref
                                                   ,craphpt hptref
                                               where dptref.tpmvtorg is not null
                                                 and dptref.nrremret = hptref.nrremret
                                                 and dptref.intipmvt = hptref.intipmvt
                                                 and dptref.nrconven = hptref.nrconven
                                                 and dptref.nrdconta = hptref.nrdconta
                                                 and dptref.cdcooper = hptref.cdcooper
                                                 and hptref.intipmvt = 2 /*retorno*/
                                                 and hptref.nrconven = hptr.nrconven
                                                 and hptref.nrdconta = hptr.nrdconta
                                                 and hptref.cdcooper = hptr.cdcooper
                                              )                         
                            -- Numero da Remessa
                         AND (pr_nrremess IS NULL OR
                             (pr_nrremess IS NOT NULL AND
                             hptr.nrremret = pr_nrremess))
                            -- Nome do arquivo
                         AND (TRIM(pr_nmarquiv) IS NULL OR
                             (TRIM(pr_nmarquiv) IS NOT NULL AND
                             hptr.nmarquiv LIKE
                             '%' || TRIM(pr_nmarquiv) || '%'))
                            -- DATA DE REMESSA
                         AND ((pr_dtremess_ini IS NULL OR
                             (pr_dtremess_ini IS NOT NULL AND
                             TRUNC(hptr.dtdgerac) >= pr_dtremess_ini)) AND
                             (pr_dtremess_fim IS NULL OR
                             (pr_dtremess_fim IS NOT NULL AND
                             TRUNC(hptr.dtdgerac) <= pr_dtremess_fim)))
                            -- DATA DE VENCIMENTO
                         AND ((pr_dtvencto_ini IS NULL OR
                             (pr_dtvencto_ini IS NOT NULL AND
                             TRUNC(dptr.dtvencto) >= pr_dtvencto_ini)) AND
                             (pr_dtvencto_fim IS NULL OR
                             (pr_dtvencto_fim IS NOT NULL AND
                             TRUNC(dptr.dtvencto) <= pr_dtvencto_fim)))
                            -- DATA AGENDADA PARA PAGAMENTO
                         AND ((pr_dtdpagto_ini IS NULL OR
                             (pr_dtdpagto_ini IS NOT NULL AND
                             TRUNC(dptr.dtdpagto) >= pr_dtdpagto_ini)) AND
                             (pr_dtdpagto_fim IS NULL OR
                             (pr_dtdpagto_fim IS NOT NULL AND
                             TRUNC(dptr.dtdpagto) <= pr_dtdpagto_fim)))
                            --
                         AND hptr.intipmvt = 1 /*remessa*/
                         AND hptr.nrdconta = pr_nrdconta
                         AND hptr.cdcooper = pr_cdcooper) referencia) remessa
       WHERE g059_urp.cddominio(+) = dpt_urp.cdocorre
         AND g059_urp.cdcampo(+) = 'G059'
            --
         AND hpt_urp.nrremret = dpt_urp.nrremret
         AND hpt_urp.intipmvt = dpt_urp.intipmvt
         AND hpt_urp.nrconven = dpt_urp.nrconven
         AND hpt_urp.nrdconta = dpt_urp.nrdconta
         AND hpt_urp.cdcooper = dpt_urp.cdcooper
            --
         AND dpt_urp.nrseqarq = remessa.nrseqarq_urp
         AND dpt_urp.nrremret = remessa.nrremret_urp
         AND dpt_urp.intipmvt = remessa.intipmvt_urp
         AND dpt_urp.nrconven = remessa.nrconven
         AND dpt_urp.nrdconta = remessa.nrdconta
         AND dpt_urp.cdcooper = remessa.cdcooper
            --
         AND g059_rem.cddominio(+) = dpt_rem.cdocorre
         AND g059_rem.cdcampo(+) = 'G059'
            --
         AND hpt_rem.nrremret = dpt_rem.nrremret
         AND hpt_rem.intipmvt = dpt_rem.intipmvt
         AND hpt_rem.nrconven = dpt_rem.nrconven
         AND hpt_rem.nrdconta = dpt_rem.nrdconta
         AND hpt_rem.cdcooper = dpt_rem.cdcooper
            --
         AND dpt_rem.nrseqarq = remessa.nrseqarq
         AND dpt_rem.nrremret = remessa.nrremret
         AND dpt_rem.intipmvt = remessa.intipmvt
         AND dpt_rem.nrconven = remessa.nrconven
         AND dpt_rem.nrdconta = remessa.nrdconta
         AND dpt_rem.cdcooper = remessa.cdcooper
            -- Filtros da TELA
            -- Status do Titulo
         AND ( -- Liquidado
              (pr_idstatus = 2 AND dpt_urp.cdocorre = '00') OR
              -- Pendente de Liquidacao
              (pr_idstatus = 3 AND dpt_urp.cdocorre = 'BD') OR
              -- Com erro
              (pr_idstatus = 4 AND dpt_urp.cdocorre NOT IN ('00', 'BD')) OR
              -- Todos 
              (pr_idstatus = 1 OR pr_idstatus IS NULL))
              
            -- Nome do Beneficiario
         AND (TRIM(pr_nmbenefi) IS NULL OR
              (TRIM(pr_nmbenefi) IS NOT NULL AND
               UPPER(dpt_rem.nmcedent) LIKE
               UPPER('%' || TRIM(pr_nmbenefi) || '%')))
              
            -- Codigo de Barras
         AND (TRIM(pr_dscodbar) IS NULL OR
              (TRIM(pr_dscodbar) IS NOT NULL AND
               dpt_rem.dscodbar LIKE '%' || TRIM(pr_dscodbar) || '%'))
       ORDER BY hpt_rem.cdcooper,
                hpt_rem.nrdconta,
                hpt_rem.nrremret,
                dpt_rem.nrseqarq;

    -- Buscar os dados para impressão do comprovante
    CURSOR cr_comprovante(pr_idlancto INTEGER) IS
      SELECT pro.dsprotoc
             ,pro.nrdocmto
             ,pro.nmprepos
             ,pro.nrseqaut
             ,pro.dttransa
             ,pro.dsinform##1
             ,pro.dsinform##2
             ,pro.dsinform##3
             ,pro.cdtippro
             ,to_char(to_date(pro.hrautent, 'SSSSS'), 'HH24:MI:SS') hrautent
             ,pro.dtmvtolt
        FROM crappro pro, crapaut aut, craptit tit, craplau lau
       WHERE UPPER(pro.dsprotoc) = UPPER(aut.dsprotoc)
         AND pro.cdcooper = aut.cdcooper
            --
         AND aut.nrsequen = tit.nrautdoc
         AND aut.dtmvtolt = tit.dtmvtolt
         AND aut.nrdcaixa = (tit.nrdolote - 16000) -- conforme regra em cxon0014.pc_gera_titulos_iptu
         AND aut.cdagenci = tit.cdagenci
         AND aut.cdcooper = tit.cdcooper
            --
         AND UPPER(tit.dscodbar) = UPPER(lau.dscodbar)
         AND tit.nrdolote = 16900 -- fixo cxon0014.pc_gera_titulos_iptu
         AND tit.cdbccxlt = 11 -- fixo cxon0014.pc_gera_titulos_iptu
         AND tit.cdagenci = lau.cdagenci
         AND tit.dtmvtolt = lau.dtmvtopg
         AND tit.cdcooper = lau.cdcooper
            --
         AND lau.idlancto = pr_idlancto;
    rw_comprovante cr_comprovante%ROWTYPE;
    
    -- Data de Remessa
    vr_dtremess_ini DATE;
    vr_dtremess_fim DATE;
    -- Data de Vencimento
    vr_dtvencto_ini DATE;
    vr_dtvencto_fim DATE;
    -- Data Agendada para Pagamento
    vr_dtdpagto_ini DATE;
    vr_dtdpagto_fim DATE;
    
    -- Indice da PL_TABLE
    vr_idx INTEGER;
    
  BEGIN
    -- Limpar a tabela de titulos que foram agendados por arquivo 
    pr_tab_agd_pgt_arq.DELETE;
    vr_idx := 0;

    -- Zerar a informação de data de REMESSA
    vr_dtremess_ini := NULL;
    vr_dtremess_fim := NULL;
    -- Zerar a informação de data de VENCIMENTO
    vr_dtvencto_ini := NULL;
    vr_dtvencto_fim := NULL;
    -- Zerar a informação de data de AGENDADA PARA PAGAMENTO
    vr_dtdpagto_ini := NULL;
    vr_dtdpagto_fim := NULL;

    -- Verificar qual é o parametro de DATA que foi selecionado para filtrar
    IF pr_tpdata = 1 THEN
      -- Foi selecionado em tela a DATA DA REMESSA
      vr_dtremess_ini := pr_dtiniper;
      vr_dtremess_fim := pr_dtfimper;
    ELSIF pr_tpdata = 2 THEN
      -- Foi selecionado em tela a DATA DE VENCIMENTO
      vr_dtvencto_ini := pr_dtiniper;
      vr_dtvencto_fim := pr_dtfimper;
    ELSIF pr_tpdata = 3 then
      -- Foi selecionado em tela a AGENDADA PARA PAGAMENTO
      vr_dtdpagto_ini := pr_dtiniper;
      vr_dtdpagto_fim := pr_dtfimper;
    END IF;
    
    -- Inicializar a quantidade de agendamentos
    pr_qttotage := 0;

    -- Buscar todos os agendamentos de acordo com os Filtros informados    
    FOR rw IN cr_agendamentos(pr_cdcooper     => pr_cdcooper,
                              pr_nrdconta     => pr_nrdconta,
                              pr_nrremess     => pr_nrremess,
                              pr_nmarquiv     => pr_nmarquiv,
                              pr_dscodbar     => pr_dscodbar,
                              pr_nmbenefi     => pr_nmbenefi,
                              pr_idstatus     => pr_idstatus,
                              pr_dtremess_ini => vr_dtremess_ini,
                              pr_dtremess_fim => vr_dtremess_fim,
                              pr_dtvencto_ini => vr_dtvencto_ini,
                              pr_dtvencto_fim => vr_dtvencto_fim,
                              pr_dtdpagto_ini => vr_dtdpagto_ini,
                              pr_dtdpagto_fim => vr_dtdpagto_fim) LOOP
      
      -- Quantidade total de agendamentos encontrados no FOR EACH
      pr_qttotage := pr_qttotage + 1;
      -- Retornar somente limite de registros selecionados na tela
      IF (pr_nrregist IS NULL) OR ( pr_qttotage > pr_iniconta AND
                                    pr_nrregist >= (pr_qttotage - pr_iniconta)) THEN
        vr_idx := vr_idx + 1;  
        pr_tab_agd_pgt_arq(vr_idx).nmarquiv := rw.nmarquiv_rem;
        pr_tab_agd_pgt_arq(vr_idx).dhdgerac := to_char(rw.dhdgerac_rem,'DD/MM/YYYY HH24:MI:SS');
        pr_tab_agd_pgt_arq(vr_idx).nmcedent := rw.nmcedent;
        pr_tab_agd_pgt_arq(vr_idx).dtvencto := to_char(rw.dtvencto,'DD/MM/YYYY');
        pr_tab_agd_pgt_arq(vr_idx).dtdpagto := to_char(rw.dtdpagto,'DD/MM/YYYY');
        pr_tab_agd_pgt_arq(vr_idx).vltitulo := rw.vltitulo;
        pr_tab_agd_pgt_arq(vr_idx).vldpagto := rw.vldpagto;
        pr_tab_agd_pgt_arq(vr_idx).nrconven := rw.nrconven;
        pr_tab_agd_pgt_arq(vr_idx).cdocorre := rw.cdocorre_urp;
        pr_tab_agd_pgt_arq(vr_idx).dsocorre := rw.dsocorre_urp;
        pr_tab_agd_pgt_arq(vr_idx).nrnivel_urp := rw.nrnivel_urp;
        pr_tab_agd_pgt_arq(vr_idx).intipmvt_urp := rw.intipmvt_urp;
        pr_tab_agd_pgt_arq(vr_idx).nrremret_urp := rw.nrremret_urp;
        pr_tab_agd_pgt_arq(vr_idx).nrseqarq_urp := rw.nrseqarq_urp;
        
        pr_tab_agd_pgt_arq(vr_idx).dssituac := rw.dssituac;
        pr_tab_agd_pgt_arq(vr_idx).dscodbar := rw.dscodbar;
        -- Montar a Linha Digitavel
        COBR0005.pc_calc_linha_digitavel(pr_cdbarras => pr_tab_agd_pgt_arq(vr_idx).dscodbar 
                                        ,pr_lindigit => pr_tab_agd_pgt_arq(vr_idx).dslindig);
                                        
        -- verificar se a ultima ocorrencia é a Liquidação do boleto
        IF rw.cdocorre_urp = '00' THEN
          -- Buscar os dados do comprovante
          -- Verificar se o cursor esta aberto 
          IF cr_comprovante%ISOPEN THEN
            --Fechar o cursor
            CLOSE cr_comprovante;
          END IF;
          
          OPEN cr_comprovante(pr_idlancto => rw.idlancto);
          FETCH cr_comprovante INTO rw_comprovante;
          IF cr_comprovante%FOUND THEN
            -- Fechar Cursor 
            CLOSE cr_comprovante;
            pr_tab_agd_pgt_arq(vr_idx).dsprotoc := rw_comprovante.dsprotoc;
            pr_tab_agd_pgt_arq(vr_idx).nrdocmto := rw_comprovante.nrdocmto;
            pr_tab_agd_pgt_arq(vr_idx).nrseqaut := rw_comprovante.nrseqaut;
            pr_tab_agd_pgt_arq(vr_idx).dsinfor1 := rw_comprovante.dsinform##1;
            pr_tab_agd_pgt_arq(vr_idx).dsinfor2 := rw_comprovante.dsinform##2;
            pr_tab_agd_pgt_arq(vr_idx).dsinfor3 := rw_comprovante.dsinform##3;
            pr_tab_agd_pgt_arq(vr_idx).cdtippro := rw_comprovante.cdtippro;
            pr_tab_agd_pgt_arq(vr_idx).nmprepos := rw_comprovante.nmprepos;
            pr_tab_agd_pgt_arq(vr_idx).dttransa := to_char(rw_comprovante.dttransa, 'dd/mm/yyyy');
            pr_tab_agd_pgt_arq(vr_idx).hrautent := rw_comprovante.hrautent;
            pr_tab_agd_pgt_arq(vr_idx).dtmvtolt := to_char(rw_comprovante.dtmvtolt, 'dd/mm/yyyy');
            
          ELSE 
            -- Fechar cursor
            CLOSE cr_comprovante;
          END IF;
        END IF; -- Agendamento LIQUIDADO
      END IF;-- Adicionar na lista de registros para devolver para a tela
    END LOOP;

    -- Verificar se o cursor ficou aberto
    IF cr_comprovante%ISOPEN THEN
      --Fechar o cursor
      CLOSE cr_comprovante;
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na rotina PGTA0001.pc_consulta_tit_arq_pgto: ' || SQLERRM;
    
      pc_internal_exception(pr_cdcooper => pr_cdcooper,
                            pr_compleme => 'ERRO: ' || pr_dscritic);
    
  END pc_consulta_tit_arq_pgto;

  -- Procedure para consultar LOG referente ao processamento do arquivo de agendamento de pagamento
  PROCEDURE pc_cons_tit_arq_pgto_car(pr_cdcooper         IN INTEGER,  -- Cooperativa
                                     pr_nrdconta         IN INTEGER,  -- Conta
                                     pr_nrremess         IN INTEGER,  -- Numero da Remessa
                                     pr_nmarquiv         IN VARCHAR2, -- Nome do arquivo que esta sendo processado
                                     pr_nmbenefi         IN VARCHAR2, -- Nome do arquivo que esta sendo processado
                                     pr_dscodbar         IN VARCHAR2, -- Nome do arquivo que esta sendo processado
                                     pr_idstatus         IN INTEGER,  -- Status do Titulo (1-Todos /2-Liquidado /3-Pendente de Liquidação / 4-Com erro
                                     pr_tpdata           IN INTEGER,  -- Tipo de Data que está sendo pesquisada (1-Data de Remessa / 2-Data de Vencimento / 3-Data Agendada para Pagamento)
                                     pr_dtiniper         IN VARCHAR2, -- Data inicial de pesquisa
                                     pr_dtfimper         IN VARCHAR2, -- Data final   de pesquisa
                                     pr_iniconta         IN INTEGER,  -- Numero de Registros da Tela
                                     pr_nrregist         IN INTEGER,  -- Numero da Registros -> Informar NULL para carregar todos os registros
                                     pr_qttotage        OUT INTEGER,  -- Quantidade Total de Agendamentos
                                     pr_xml             OUT NOCOPY CLOB, -- Descricao do LOG
                                     pr_cdcritic        OUT INTEGER,     -- Código do erro
                                     pr_dscritic        OUT VARCHAR2) IS -- Descricao do erro
    /* .............................................................................
    
       Programa: pc_cons_tit_arq_pgto_car
       Sistema : CECRED
       Sigla   : PGTA
       Autor   : Douglas Quisinski
       Data    : Agosto/17.                    Ultima atualizacao: 17/11/2017
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado
    
       Objetivo  : Procedure para que o Progress possa consultar os titulos agendados por arquivo
    
       Observacao: -----
    
       Alteracoes: 17/11/2017 - Ajustes de format vltitulo, vlpagto melhoria 271.3 (Tiago)
    ..............................................................................*/

    -- Tabela para arqmazenar os titulos agendados
    vr_tab_agd_pgt_arq typ_tab_agd_pgt_arq;

    vr_dtiniper DATE;
    vr_dtfimper DATE;


    vr_xml      CLOB;
    vr_xml_temp VARCHAR(32767);
 
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_exec_err EXCEPTION;

  BEGIN
    
    -- Limpar a tabela de Titulos Agendados por Arquivo
    vr_tab_agd_pgt_arq.DELETE;
    
    -- converter as datas que recebemos por STRING em DATE
    vr_dtiniper := to_date(pr_dtiniper,'DD/MM/YYYY');
    vr_dtfimper := to_date(pr_dtfimper,'DD/MM/YYYY');

    PGTA0001.pc_consulta_tit_arq_pgto(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrremess => pr_nrremess
                                     ,pr_nmarquiv => pr_nmarquiv
                                     ,pr_nmbenefi => pr_nmbenefi
                                     ,pr_dscodbar => pr_dscodbar
                                     ,pr_idstatus => pr_idstatus
                                     ,pr_tpdata   => pr_tpdata
                                     ,pr_dtiniper => vr_dtiniper
                                     ,pr_dtfimper => vr_dtfimper
                                     ,pr_iniconta => pr_iniconta
                                     ,pr_nrregist => pr_nrregist
                                     ,pr_qttotage => pr_qttotage
                                     ,pr_tab_agd_pgt_arq => vr_tab_agd_pgt_arq
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
    
    IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exec_err;
    END IF;
  
  
    -- Prepara para envio do XML
    dbms_lob.createtemporary(vr_xml, TRUE);
    dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_xml,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => '<dados>');
                            
    IF vr_tab_agd_pgt_arq.COUNT > 0 THEN
      FOR vr_idx IN vr_tab_agd_pgt_arq.FIRST..vr_tab_agd_pgt_arq.LAST LOOP
        -- Escrever o LOG
        gene0002.pc_escreve_xml(pr_xml            => vr_xml,
                                pr_texto_completo => vr_xml_temp,
                                pr_texto_novo     => '<titulo>' || 
                                                     ' <nmarquiv>' || vr_tab_agd_pgt_arq(vr_idx).nmarquiv || '</nmarquiv>' ||
                                                     ' <dhdgerac>' || vr_tab_agd_pgt_arq(vr_idx).dhdgerac || '</dhdgerac>' ||
                                                     ' <nmcedent>' || vr_tab_agd_pgt_arq(vr_idx).nmcedent || '</nmcedent>' ||
                                                     ' <dtvencto>' || vr_tab_agd_pgt_arq(vr_idx).dtvencto || '</dtvencto>' ||
                                                     ' <dtdpagto>' || vr_tab_agd_pgt_arq(vr_idx).dtdpagto || '</dtdpagto>' ||
                                                     ' <vltitulo>' || to_char(vr_tab_agd_pgt_arq(vr_idx).vltitulo,'fm999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''')||'</vltitulo>'||
                                                     ' <vldpagto>' || to_char(vr_tab_agd_pgt_arq(vr_idx).vldpagto,'fm999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''')||'</vldpagto>'||
                                                     ' <nrconven>' || vr_tab_agd_pgt_arq(vr_idx).nrconven || '</nrconven>' ||
                                                     ' <cdocorre>' || vr_tab_agd_pgt_arq(vr_idx).cdocorre || '</cdocorre>' ||
                                                     ' <dsocorre>' || vr_tab_agd_pgt_arq(vr_idx).dsocorre || '</dsocorre>' ||
                                                     ' <nrnivel_urp>'  || vr_tab_agd_pgt_arq(vr_idx).nrnivel_urp  || '</nrnivel_urp>' ||
                                                     ' <intipmvt_urp>' || vr_tab_agd_pgt_arq(vr_idx).intipmvt_urp || '</intipmvt_urp>' ||
                                                     ' <nrremret_urp>' || vr_tab_agd_pgt_arq(vr_idx).nrremret_urp || '</nrremret_urp>' ||
                                                     ' <nrseqarq_urp>' || vr_tab_agd_pgt_arq(vr_idx).nrseqarq_urp || '</nrseqarq_urp>' ||
                                                     ' <dscodbar>' || vr_tab_agd_pgt_arq(vr_idx).dscodbar || '</dscodbar>' ||
                                                     ' <dslindig>' || vr_tab_agd_pgt_arq(vr_idx).dslindig || '</dslindig>' ||
                                                     ' <dssituac>' || vr_tab_agd_pgt_arq(vr_idx).dssituac || '</dssituac>' ||
                                                     ' <dsprotoc>' || NVL(vr_tab_agd_pgt_arq(vr_idx).dsprotoc, ' ') || '</dsprotoc>' ||
                                                     ' <nrdocmto>' || NVL(vr_tab_agd_pgt_arq(vr_idx).nrdocmto, 0 )  || '</nrdocmto>' ||
                                                     ' <nrseqaut>' || NVL(vr_tab_agd_pgt_arq(vr_idx).nrseqaut, 0 )  || '</nrseqaut>' ||
                                                     ' <dsinfor1>' || NVL(vr_tab_agd_pgt_arq(vr_idx).dsinfor1, ' ') || '</dsinfor1>' ||
                                                     ' <dsinfor2>' || NVL(vr_tab_agd_pgt_arq(vr_idx).dsinfor2, ' ') || '</dsinfor2>' ||
                                                     ' <dsinfor3>' || NVL(vr_tab_agd_pgt_arq(vr_idx).dsinfor3, ' ') || '</dsinfor3>' ||
                                                     ' <cdtippro>' || NVL(vr_tab_agd_pgt_arq(vr_idx).cdtippro, 0 )  || '</cdtippro>' ||
                                                     ' <nmprepos>' || NVL(vr_tab_agd_pgt_arq(vr_idx).nmprepos, ' ') || '</nmprepos>' ||
                                                     ' <dttransa>' || NVL(vr_tab_agd_pgt_arq(vr_idx).dttransa, ' ') || '</dttransa>' ||
                                                     ' <hrautent>' || NVL(vr_tab_agd_pgt_arq(vr_idx).hrautent, ' ') || '</hrautent>' ||
                                                     ' <dtmvtolt>' || NVL(vr_tab_agd_pgt_arq(vr_idx).dtmvtolt, ' ') || '</dtmvtolt>' ||
                                                     -- Quantidade total de registros
                                                     ' <qttotage>' || pr_qttotage || '</qttotage>' ||
                                                     '</titulo>');
      END LOOP;
    END IF;

    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_xml,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => '</dados>',
                            pr_fecha_xml      => TRUE);

    pr_xml := vr_xml;
    
    -- Limpar a tabela de memória
    vr_tab_agd_pgt_arq.DELETE;

  EXCEPTION
    WHEN vr_exec_err THEN
      -- Limpar a tabela de memória
      vr_tab_agd_pgt_arq.DELETE;
      -- Retornar a critica
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      -- Limpar a tabela de memória
      vr_tab_agd_pgt_arq.DELETE;
      -- Retornar a critica      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na rotina PGTA0001.pc_cons_tit_arq_pgto_car: ' || SQLERRM;
    
      pc_internal_exception(pr_cdcooper => pr_cdcooper,
                            pr_compleme => 'ERRO: ' || pr_dscritic);
    
  END pc_cons_tit_arq_pgto_car;

  PROCEDURE pc_cons_tit_arq_pgto_web(pr_nrdconta IN INTEGER   -- Conta
                                    ,pr_nrremess IN INTEGER   -- Numero da Remessa
                                    ,pr_nmarquiv IN VARCHAR2  -- Nome do arquivo que esta sendo processado
                                    ,pr_nmbenefi IN VARCHAR2  -- Nome do arquivo que esta sendo processado
                                    ,pr_dscodbar IN VARCHAR2  -- Nome do arquivo que esta sendo processado
                                    ,pr_idstatus IN INTEGER   -- Status do Titulo (1-Todos /2-Liquidado /3-Pendente de Liquidação / 4-Com erro
                                    ,pr_tpdata   IN INTEGER   -- Tipo de Data que está sendo pesquisada (1-Data de Remessa / 2-Data de Vencimento / 3-Data Agendada para Pagamento)
                                    ,pr_dtiniper IN VARCHAR2  -- Data inicial de pesquisa
                                    ,pr_dtfimper IN VARCHAR2  -- Data final   de pesquisa
                                    ,pr_iniconta IN INTEGER   -- Numero de Registros da Tela
                                    ,pr_nrregist IN INTEGER   -- Numero da Registros -> Informar NULL para carregar todos os registros                                    
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................
    
        Programa: pc_cons_tit_arq_pgto_web
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Tiago
        Data    : Agosto/17.                    Ultima atualizacao: 17/11/2017
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Retornar dados da conta
    
        Observacao: -----
    
        Alteracoes: 17/11/2017 - Ajustes de format vltitulo melhoria 271.3 (Tiago)
    ..............................................................................*/
    ---------> CURSORES <--------
    --> Buscar logs
    vr_tab_agd_pgt_arq typ_tab_agd_pgt_arq;

    vr_dtiniper DATE;
    vr_dtfimper DATE;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
      
    vr_dsmanipulacao  VARCHAR2(40);
    vr_nmdcampo       tbcobran_cpt_log.nmdcampo%TYPE;
    vr_nmtabela       tbcobran_cpt_log.nmtabela%TYPE;
    
    vr_qttotage       INTEGER;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
  BEGIN
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    -- Leitura da PL/Table e geração do arquivo XML
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    
    vr_dtiniper := TO_DATE(pr_dtiniper,'DD/MM/RRRR');
    vr_dtfimper := TO_DATE(pr_dtfimper,'DD/MM/RRRR');
    
    PGTA0001.pc_consulta_tit_arq_pgto(pr_cdcooper => vr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrremess => pr_nrremess
                                     ,pr_nmarquiv => pr_nmarquiv
                                     ,pr_nmbenefi => pr_nmbenefi
                                     ,pr_dscodbar => pr_dscodbar
                                     ,pr_idstatus => pr_idstatus
                                     ,pr_tpdata   => pr_tpdata
                                     ,pr_dtiniper => vr_dtiniper
                                     ,pr_dtfimper => vr_dtfimper
                                     ,pr_iniconta => pr_iniconta
                                     ,pr_nrregist => pr_nrregist
                                     ,pr_qttotage => vr_qttotage
                                     ,pr_tab_agd_pgt_arq => vr_tab_agd_pgt_arq
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
    
    IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
    pc_escreve_xml('<qttotage>'||NVL(vr_qttotage,0)||'</qttotage>');
    pc_escreve_xml('<titulos>');
                            
    IF vr_tab_agd_pgt_arq.COUNT > 0 THEN
      FOR vr_idx IN vr_tab_agd_pgt_arq.FIRST..vr_tab_agd_pgt_arq.LAST LOOP
        -- Escrever o LOG
       pc_escreve_xml( '<titulo>' || 
                       ' <nmarquiv>' || vr_tab_agd_pgt_arq(vr_idx).nmarquiv || '</nmarquiv>' ||
                       ' <dhdgerac>' || vr_tab_agd_pgt_arq(vr_idx).dhdgerac || '</dhdgerac>' ||
                       ' <nmcedent>' || vr_tab_agd_pgt_arq(vr_idx).nmcedent || '</nmcedent>' ||
                       ' <dtvencto>' || vr_tab_agd_pgt_arq(vr_idx).dtvencto || '</dtvencto>' ||
                       ' <dtdpagto>' || vr_tab_agd_pgt_arq(vr_idx).dtdpagto || '</dtdpagto>' ||
                       ' <vltitulo>' || to_char(vr_tab_agd_pgt_arq(vr_idx).vltitulo,'fm999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''')||'</vltitulo>'||
                       ' <nrconven>' || vr_tab_agd_pgt_arq(vr_idx).nrconven || '</nrconven>' ||
                       ' <cdocorre>' || vr_tab_agd_pgt_arq(vr_idx).cdocorre || '</cdocorre>' ||
                       ' <dsocorre>' || vr_tab_agd_pgt_arq(vr_idx).dsocorre || '</dsocorre>' ||
                       ' <nrnivel_urp>'  || vr_tab_agd_pgt_arq(vr_idx).nrnivel_urp  || '</nrnivel_urp>' ||
                       ' <intipmvt_urp>' || vr_tab_agd_pgt_arq(vr_idx).intipmvt_urp || '</intipmvt_urp>' ||
                       ' <nrremret_urp>' || vr_tab_agd_pgt_arq(vr_idx).nrremret_urp || '</nrremret_urp>' ||
                       ' <nrseqarq_urp>' || vr_tab_agd_pgt_arq(vr_idx).nrseqarq_urp || '</nrseqarq_urp>' ||
                       ' <dscodbar>' || vr_tab_agd_pgt_arq(vr_idx).dscodbar || '</dscodbar>' ||
                       ' <dslindig>' || vr_tab_agd_pgt_arq(vr_idx).dslindig || '</dslindig>' ||
                       ' <dssituac>' || vr_tab_agd_pgt_arq(vr_idx).dssituac || '</dssituac>' ||
                       ' <dsprotoc>' || NVL(vr_tab_agd_pgt_arq(vr_idx).dsprotoc, ' ') || '</dsprotoc>' ||
                       ' <nrdocmto>' || NVL(vr_tab_agd_pgt_arq(vr_idx).nrdocmto, 0 )  || '</nrdocmto>' ||
                       ' <nrseqaut>' || NVL(vr_tab_agd_pgt_arq(vr_idx).nrseqaut, 0 )  || '</nrseqaut>' ||
                       ' <dsinfor1>' || NVL(vr_tab_agd_pgt_arq(vr_idx).dsinfor1, ' ') || '</dsinfor1>' ||
                       ' <dsinfor2>' || NVL(vr_tab_agd_pgt_arq(vr_idx).dsinfor2, ' ') || '</dsinfor2>' ||
                       ' <dsinfor3>' || NVL(vr_tab_agd_pgt_arq(vr_idx).dsinfor3, ' ') || '</dsinfor3>' ||
                       ' <cdtippro>' || NVL(vr_tab_agd_pgt_arq(vr_idx).cdtippro, 0 )  || '</cdtippro>' ||
                       ' <nmprepos>' || NVL(vr_tab_agd_pgt_arq(vr_idx).nmprepos, ' ') || '</nmprepos>' ||
                       ' <dttransa>' || NVL(vr_tab_agd_pgt_arq(vr_idx).dttransa, ' ') || '</dttransa>' ||
                       ' <hrautent>' || NVL(vr_tab_agd_pgt_arq(vr_idx).hrautent, ' ') || '</hrautent>' ||
                       ' <dtmvtolt>' || NVL(vr_tab_agd_pgt_arq(vr_idx).dtmvtolt, ' ') || '</dtmvtolt>' ||
                       -- Quantidade total de registros
                       ' <qttotage>' || vr_qttotage || '</qttotage>' ||
                       '</titulo>');
      END LOOP;
    END IF;
    
    pc_escreve_xml('</titulos>');
    pc_escreve_xml('</dados></root>',TRUE);    
    pr_retxml := XMLType.createXML(vr_des_xml);
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_cons_tit_arq_pgto_web;     


  -- Procedure para consultar LOG referente ao processamento do arquivo de agendamento de pagamento
  PROCEDURE pc_canc_agd_pgto_tit_car(pr_cdcooper         IN INTEGER,  -- Cooperativa
                                     pr_nrdconta         IN INTEGER,  -- Conta
                                     pr_nrconven         IN INTEGER,  -- Numero do Convenio
                                     pr_dtmvtolt         IN VARCHAR2, -- Data do Sistema
                                     pr_cdoperad         IN VARCHAR2, -- Operador
                                     pr_idorigem         IN INTEGER,  -- Origem
                                     -- Dados para identificar o agendamento que esta sendo cancelado
                                     pr_intipmvt         IN INTEGER,  -- Tipo de Movimento
                                     pr_nrremret         IN INTEGER,  -- Numero de Remessa
                                     pr_nrseqarq         IN INTEGER,  -- Sequencia do agendamento no arquivo
                                     -- Novo Numero de Remessa e Nova Sequencia do arquivo
                                     pr_nrremret_new     IN INTEGER,  -- Numero da Sequencia dentro do arquivo
                                     pr_nrseqarq_new     IN INTEGER,  -- Numero da Sequencia dentro do arquivo
                                     -- OUT
                                     pr_nrremret_out    OUT INTEGER,     -- Numero do Arquivo de Retorno
                                     pr_cdcritic        OUT INTEGER,     -- Código do erro
                                     pr_dscritic        OUT VARCHAR2) IS -- Descricao do erro
    /* .............................................................................
    
       Programa: pc_canc_agd_pgto_tit_car
       Sistema : CECRED
       Sigla   : PGTA
       Autor   : Douglas Quisinski
       Data    : Agosto/17.                    Ultima atualizacao: --/--/----
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado
    
       Objetivo  : Procedure para Cancelar o Agendamento do Pagamento do titulo
    
       Observacao: -----
    
       Alteracoes:
    ..............................................................................*/

    -- Variaveis
    vr_dtmvtolt DATE;
    vr_cdocorre crapdpt.cdocorre%TYPE;
    vr_nrremret_new INTEGER;
    vr_nmarquiv VARCHAR2(500);
    
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_exec_err EXCEPTION;
    
    -- Dados do arquivo de remessa
    CURSOR cr_crapdpt(pr_cdcooper IN crapdpt.cdcooper%TYPE
                     ,pr_nrdconta IN crapdpt.nrdconta%TYPE
                     ,pr_nrconven IN crapdpt.nrconven%TYPE
                     ,pr_nrremret IN crapdpt.nrremret%TYPE
                     ,pr_intipmvt IN crapdpt.intipmvt%TYPE
                     ,pr_nrseqarq IN crapdpt.nrseqarq%TYPE) IS
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
            ,dpt.cdocorre 
            ,dpt.dtmvtopg 
            ,dpt.intipreg 
            ,dpt.dsnosnum 
            ,dpt.tpmvtorg 
            ,dpt.nrmvtorg 
            ,dpt.nrarqorg 
            ,dpt.idlancto
        FROM crapdpt dpt
       WHERE dpt.cdcooper = pr_cdcooper
         AND dpt.nrdconta = pr_nrdconta
         AND dpt.nrconven = pr_nrconven
         AND dpt.intipmvt = pr_intipmvt
         AND dpt.nrremret = pr_nrremret
         AND dpt.nrseqarq = pr_nrseqarq;
    rw_crapdpt cr_crapdpt%ROWTYPE;
        
    -- Procedure para verificar se devemos criar o registro de Header para retorno do Cancelamento
    PROCEDURE pc_verifica_criar_hpt(pr_cdcooper IN INTEGER
                                   ,pr_nrdconta IN INTEGER
                                   ,pr_nrconven IN INTEGER
                                   ,pr_nrremret IN INTEGER
                                   ,pr_dtmvtolt IN DATE
                                   ,pr_idorigem IN INTEGER
                                   ,pr_cdoperad IN VARCHAR2
                                   ,pr_nrremret_new OUT INTEGER
                                   ,pr_nmarquiv OUT VARCHAR2
                                   ,pr_cdcritic OUT INTEGER
                                   ,pr_dscritic OUT VARCHAR2) IS
      -- Variaveis locais                             
      vr_nmarquiv craphpt.nmarquiv%TYPE;
      vr_nrremret INTEGER;
      -- Critica
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_exc_critico EXCEPTION; 

      -- Buscar ultimo numero de retorno utilizado
      CURSOR cr_craphpt(pr_cdcooper IN craphpt.cdcooper%TYPE     --> Código da cooperativa
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
      
    BEGIN
      -- Inicializar o numero de remessa 
      pr_nrremret_new := 0;
      
      -- Verificar se o numero de remessa foi informado
      IF NVL(pr_nrremret, 0) <> 0 THEN
        -- Se existe, vamos utilizar o mesmo numero de retorno
        vr_nrremret := pr_nrremret;
      ELSE
        -- Se for ZERO devemos criar um registro para armazenar todos os cancelamentos
        -- Buscar o Último Lote de Retorno do Cooperado
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

        vr_nmarquiv := 'PGT_' || TRIM(to_char(pr_nrdconta,'00000000'))  || '_' ||
                                 TRIM(to_char(vr_nrremret,'000000000')) || '.RET';
	
        -- Criar Lote de Informações de Retorno (craphpt)
        BEGIN
          INSERT INTO craphpt (cdcooper,
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
                       VALUES (pr_cdcooper,
                               pr_nrdconta,
                               pr_nrconven,
                               2, -- Retorno
                               vr_nrremret,
                               pr_dtmvtolt,
                               vr_nmarquiv,
                               pr_idorigem,
                               TRUNC(SYSDATE),
                               to_char(SYSDATE,'HH24MISS'),
                               1, -- Pendente
                               pr_cdoperad);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir craphpt: '||SQLERRM;
            RAISE vr_exc_critico;
        END;
      END IF;

      -- Gravar Variavel de Saída com o Numero do Retorno
      pr_nrremret_new := vr_nrremret;
      pr_nmarquiv := vr_nmarquiv;
         
    EXCEPTION
      WHEN vr_exc_critico THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na verificação do registro de retorno (pc_verifica_criar_hpt): ' || SQLERRM;
        
        pc_internal_exception(pr_cdcooper => pr_cdcooper
                             ,pr_compleme => pr_dscritic);
    END pc_verifica_criar_hpt;
    
  BEGIN
    
    -- Converter a data
    vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/YYYY');
    
    -- Ler todos os registros da crapdpt e realizar o cancelamento desses agendamentos
    OPEN cr_crapdpt(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrconven => pr_nrconven
                   ,pr_nrremret => pr_nrremret
                   ,pr_intipmvt => pr_intipmvt
                   ,pr_nrseqarq => pr_nrseqarq);
    FETCH cr_crapdpt INTO rw_crapdpt;
    
    -- Verificamos se existe o Detalhe do Agendamento
    IF cr_crapdpt%NOTFOUND THEN
      -- Fechar Cursor
      CLOSE cr_crapdpt;
      -- Abortar o cancelamento
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de agendamento não encontrado.';
      RAISE vr_exec_err;
    END IF;  
    
    IF cr_crapdpt%ISOPEN THEN
      -- Fechar Cursor
      CLOSE cr_crapdpt;
    END IF;
    
    -- Verificar se devemos criar um registro de header para o retorno
    pc_verifica_criar_hpt(pr_cdcooper => rw_crapdpt.cdcooper
                         ,pr_nrdconta => rw_crapdpt.nrdconta
                         ,pr_nrconven => rw_crapdpt.nrconven
                         ,pr_nrremret => pr_nrremret_new
                         ,pr_dtmvtolt => vr_dtmvtolt
                         ,pr_idorigem => pr_idorigem
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_nrremret_new => vr_nrremret_new
                         ,pr_nmarquiv => vr_nmarquiv
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
    -- Verificar se ocorreu erro na validacao
    IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exec_err;
    END IF;
    
    -- Realizar o cancelamento do agendamento do titulo
    pc_cancelar_agend_pgto (pr_cdcooper => rw_crapdpt.cdcooper
                           ,pr_cdagenci => 90
                           ,pr_nrdolote => 11900       -- (11000 + nrdcaixa)
                           ,pr_cdbccxlt => 100         -- cdbccxlt
                           ,pr_dtmvtolt => vr_dtmvtolt
                           ,pr_nrdconta => rw_crapdpt.nrdconta
                           ,pr_cdtiptra => 2           -- PAGAMENTO
                           ,pr_dscodbar => rw_crapdpt.dscodbar
                           ,pr_dtvencto => rw_crapdpt.dtvencto
                           ,pr_dtmvtopg => rw_crapdpt.dtmvtopg
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_cdcritic => vr_cdcritic   -- Codigo da critica
                           ,pr_dscritic => vr_dscritic); -- Descricao critica

    -- Se deu algum erro na exclusao do agendamento
    IF TRIM(vr_dscritic) IS NOT NULL AND SUBSTR(vr_dscritic,01,01) = 'X' THEN
      -- Usado o pr_dscritic como retorno de sucesso em uma determinada situacao
      vr_cdocorre := TRIM(vr_dscritic); -- Retornará 'X' mais um numero
    ELSE
      IF NOT (NVL(vr_cdcritic,0) = 0 AND TRIM(vr_dscritic) IS NULL) THEN
        -- Caso tenha dado algum erro...
        vr_cdocorre := '90';   -- Fora G059 - 90 - Lançamento não encontrado
        vr_dscritic := vr_dscritic || ' - CODBAR: ' || TO_CHAR(rw_crapdpt.dscodbar);
         
        PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => rw_crapdpt.cdcooper
                                     ,pr_nrdconta => rw_crapdpt.nrdconta
                                     ,pr_nrconven => rw_crapdpt.nrconven
                                     ,pr_tpmovimento => 2 -- Retorno
                                     ,pr_nrremret => vr_nrremret_new
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_nmoperad_online => NULL
                                     ,pr_cdprograma => 'pc_canc_agd_pgto_tit_car'
                                     ,pr_nmtabela => 'CRAPDPT'
                                     ,pr_nmarquivo => vr_nmarquiv
                                     ,pr_dsmsglog => vr_dscritic
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
        -- Ignorar a critica do LOG
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
      ELSE
        vr_cdocorre := 'BF';   -- G059 - 'BF' = Exclusão Efetuada com Sucesso
      END IF;
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
         intipreg,
         tpmvtorg,
         nrmvtorg,
         nrarqorg,
         idlancto)
      VALUES
        (rw_crapdpt.cdcooper,
         rw_crapdpt.nrdconta,
         rw_crapdpt.nrconven,
         2, -- Retorno
         vr_nrremret_new, -- Numero da Remessa que geramos
         pr_nrseqarq_new, -- Numero de Sequencia (programa chamador deve controlar)
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
         rw_crapdpt.intipreg,
         rw_crapdpt.tpmvtorg,
         rw_crapdpt.nrmvtorg,
         rw_crapdpt.nrarqorg,
         rw_crapdpt.idlancto);

    EXCEPTION
       WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir crapdpt: '||SQLERRM;
          RAISE vr_exec_err;
    END;

    -- Se chegou aqui, o processo todo foi executado
    -- Dessa forma devolvemos o Numero de Retorno que geramos
    pr_nrremret_out := vr_nrremret_new;
    
  EXCEPTION
    WHEN vr_exec_err THEN
      -- Retornar a critica      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro PGTA0001.pc_canc_agd_pgto_tit_car: ' || vr_dscritic;
      
    WHEN OTHERS THEN
      -- Retornar a critica      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na rotina PGTA0001.pc_canc_agd_pgto_tit_car: ' || SQLERRM;
    
      pc_internal_exception(pr_cdcooper => pr_cdcooper,
                            pr_compleme => 'ERRO: ' || pr_dscritic);
    
  END pc_canc_agd_pgto_tit_car;

  PROCEDURE pc_consulta_conta(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................
    
        Programa: pc_consulta_conta
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Tiago
        Data    : Setembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Retornar dados da conta
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    ---------> CURSORES <--------
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT crapcop.cdagectl
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    CURSOR cr_crapass( pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE ) IS
      SELECT crapass.cdcooper
            ,crapass.nrdconta
            ,crapass.nmprimtl
            ,crapass.nrcpfcgc
            ,crapass.inpessoa
            ,crapass.cdagenci
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;     
    
    CURSOR cr_crapcpt(pr_cdcooper crapcop.cdcooper%TYPE    
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT *
        FROM crapcpt
       WHERE crapcpt.cdcooper = pr_cdcooper
         AND crapcpt.nrdconta = pr_nrdconta
         AND crapcpt.nrconven = 1;
    rw_crapcpt cr_crapcpt%ROWTYPE;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
      
    vr_dsmanipulacao  VARCHAR2(40);
    vr_nmdcampo       tbcobran_cpt_log.nmdcampo%TYPE;
    vr_nmtabela       tbcobran_cpt_log.nmtabela%TYPE;
    
    vr_flghomol       crapcpt.flghomol%TYPE;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
  BEGIN
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    -- Leitura da PL/Table e geração do arquivo XML
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
    
    OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    
    IF cr_crapcop%NOTFOUND THEN
       CLOSE cr_crapcop;
       vr_dscritic := 'Cooperativa nao encontrada!';
       RAISE vr_exc_saida;
    END IF;
       
    CLOSE cr_crapcop;
    
    
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    IF cr_crapass%NOTFOUND THEN
       CLOSE cr_crapass;
       vr_dscritic := 'Conta nao encontrada!';
       RAISE vr_exc_saida;
    END IF;
       
    CLOSE cr_crapass;
                                       

    OPEN cr_crapcpt(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapcpt INTO rw_crapcpt;
    
    IF cr_crapcpt%NOTFOUND THEN
       vr_flghomol := 0;
    ELSE
       vr_flghomol := rw_crapcpt.flghomol;  
    END IF;
       
    CLOSE cr_crapcpt;
    
                                       
    pc_escreve_xml('<inf>'||
                      '<nrdconta>' || rw_crapass.nrdconta ||'</nrdconta>' ||
                      '<nmprimtl>' || rw_crapass.nmprimtl ||'</nmprimtl>' ||
                      '<nrcpfcgc>' || rw_crapass.nrcpfcgc ||'</nrcpfcgc>' ||
                      '<inpessoa>' || rw_crapass.inpessoa ||'</inpessoa>' ||
                      '<cdagectl>' || rw_crapcop.cdagectl ||'</cdagectl>' ||
                      '<flghomol>' || vr_flghomol ||'</flghomol>' ||
                   '</inf>');
    
    pc_escreve_xml('</dados></root>',TRUE);    
    pr_retxml := XMLType.createXML(vr_des_xml);
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_consulta_conta;     

  PROCEDURE pc_relato_arq_pgto_csv(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cod cooperativa
                                  ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                  ,pr_cdagenci IN crapass.cdagenci%TYPE --> PA
                                  ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE --> Numero caixa
                                  ,pr_idorigem IN INTEGER               --> Sistema origem
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE --> Cod Operador
                                  ,pr_iddspscp IN INTEGER               --> Parametro criado para permitir a geracao do relatorio para o IB atual e para o IB novo
                                  ,pr_tab_agend_rel  IN typ_tab_rel_arq       --> PLTABLE com os dados
                                  ,pr_tab_liqui_rel  IN typ_tab_rel_arq       --> PLTABLE com os dados
                                  ,pr_tab_rejei_rel  IN typ_tab_rel_arq       --> PLTABLE com os dados
                                  ,pr_nmarquiv OUT VARCHAR2             --> Nome do arquivo gerado
                                  ,pr_dssrvarq OUT VARCHAR2             --> Nome do servidor para download do arquivo
                                  ,pr_dsdirarq OUT VARCHAR2             --> Nome do diretório para download do arquivo                                                                                                 
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_relato_arq_pgto_csv
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Tiago
        Data    : Setembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Retornar relatorio referentes aos agendamentos de pagamento de 
                    titulos que foram integrados no ayllos por arquivo.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    ---------> CURSORES <--------
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    vr_des_erro VARCHAR2(1000); --> Desc. Erro
    vr_des_reto VARCHAR2(03);           --> OK ou NOK
    vr_tab_erro GENE0001.typ_tab_erro;  --> Tabela com erros
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    vr_indice         VARCHAR2(15);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml       CLOB;
    vr_des_txt       VARCHAR2(32700);
    vr_dslinha       VARCHAR2(4000);
    -- Variável para o caminho e nome do arquivo base
    vr_nom_diretorio VARCHAR2(200);
    vr_nom_arquivo   VARCHAR2(200);
    
  BEGIN
    
    -- Inicializar o CLOB
    vr_des_xml := null;
    vr_des_txt := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);


    vr_dslinha :=       'SITUACAO' ||
                  ';'|| 'NUMERO REMESSA' ||
                  ';'|| 'CODIGO BANCO'  ||
                  ';'|| 'DATA/HORA GERASSAO REMESSA' ||
                  ';'|| 'DATA PARA DEBITO' ||
                  ';'|| 'DATA DE VENCIMENTO' ||
                  ';'|| 'VALOR DO PAGAMENTO' ||
                  ';'|| 'NOME' ||
                  ';'|| 'NOSSO NUMERO' ||
                  ';'|| 'CODIGO DE BARRAS' ||
                  ';'|| 'VALOR TITULO' ||
                  ';'|| 'VALOR DESCONTO' ||
                  ';'|| 'VALOR ACRESCIMO' ||
                  ';'|| 'VALOR URP' ||                    
                  ';'|| 'DATA PAGAMENTO'  ||
                  ';'|| 'SITUACAO DO TITULO' ||
                  ';'|| 'CONTA' ||
                  ';'|| 'ESTORNO'  || chr(13);
                    
    
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,vr_dslinha,FALSE);            



    /**********AGENDADOS**************************************/  
    vr_indice := pr_tab_agend_rel.FIRST;
    
    WHILE vr_indice IS NOT NULL LOOP
    
      vr_dslinha :=       pr_tab_agend_rel(vr_indice).dssituacao ||
                    ';'|| TO_CHAR(pr_tab_agend_rel(vr_indice).nrremret,'fm999999g990') ||
                    ';'|| TO_CHAR(pr_tab_agend_rel(vr_indice).cdbanco,'fm999999g990')  ||
                    ';'|| TO_CHAR(pr_tab_agend_rel(vr_indice).dhdgerac_rem,'DD/MM/RRRR HH:MM:SS') ||
                    ';'|| TO_CHAR(pr_tab_agend_rel(vr_indice).dtparadebito,'DD/MM/RRRR') ||
                    ';'|| TO_CHAR(pr_tab_agend_rel(vr_indice).dtvencto,'DD/MM/RRRR') ||
                    ';'|| TO_CHAR(pr_tab_agend_rel(vr_indice).vldpagto,'fm99999g999g990d00') ||
                    ';'|| pr_tab_agend_rel(vr_indice).nmcedent ||
                    ';'|| pr_tab_agend_rel(vr_indice).dsnosnum ||
                    ';'''|| pr_tab_agend_rel(vr_indice).dscodbar || '''' ||
                    ';'|| TO_CHAR(pr_tab_agend_rel(vr_indice).vltitulo,'fm99999g999g990d00') ||
                    ';'|| TO_CHAR(pr_tab_agend_rel(vr_indice).vldescto,'fm99999g999g990d00') ||
                    ';'|| TO_CHAR(pr_tab_agend_rel(vr_indice).vlacresc,'fm99999g999g990d00') ||
                    ';'|| TO_CHAR(pr_tab_agend_rel(vr_indice).vlpagurp,'fm99999g999g990d00') ||                    
                    ';'|| TO_CHAR(pr_tab_agend_rel(vr_indice).dtpagto,'DD/MM/RRRR')  ||
                    ';'|| GENE0007.fn_caract_acento(pr_tab_agend_rel(vr_indice).dsocorre_urp) ||
                    ';'|| pr_tab_agend_rel(vr_indice).nrdconta ||
                    ';'|| pr_tab_agend_rel(vr_indice).estorno  || chr(13);
                    
    
      gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,vr_dslinha,FALSE);            
    
      vr_indice := pr_tab_agend_rel.next(vr_indice);
    END LOOP;

    /**********LIQUIDADOS**************************************/  
    vr_indice := pr_tab_liqui_rel.FIRST;
    
    WHILE vr_indice IS NOT NULL LOOP
    
      vr_dslinha :=       pr_tab_liqui_rel(vr_indice).dssituacao ||
                    ';'|| TO_CHAR(pr_tab_liqui_rel(vr_indice).nrremret,'fm999999g990') ||
                    ';'|| TO_CHAR(pr_tab_liqui_rel(vr_indice).cdbanco,'fm999999g990')  ||
                    ';'|| TO_CHAR(pr_tab_liqui_rel(vr_indice).dhdgerac_rem,'DD/MM/RRRR HH:MM:SS') ||
                    ';'|| TO_CHAR(pr_tab_liqui_rel(vr_indice).dtparadebito,'DD/MM/RRRR')  ||
                    ';'|| TO_CHAR(pr_tab_liqui_rel(vr_indice).dtvencto,'DD/MM/RRRR')  ||
                    ';'|| TO_CHAR(pr_tab_liqui_rel(vr_indice).vldpagto,'fm99999g999g990d00') ||
                    ';'|| pr_tab_liqui_rel(vr_indice).nmcedent ||
                    ';'|| pr_tab_liqui_rel(vr_indice).dsnosnum ||
                    ';'''|| pr_tab_liqui_rel(vr_indice).dscodbar || '''' ||
                    ';'|| TO_CHAR(pr_tab_liqui_rel(vr_indice).vltitulo,'fm99999g999g990d00') ||
                    ';'|| TO_CHAR(pr_tab_liqui_rel(vr_indice).vldescto,'fm99999g999g990d00') ||
                    ';'|| TO_CHAR(pr_tab_liqui_rel(vr_indice).vlacresc,'fm99999g999g990d00') ||
                    ';'|| TO_CHAR(pr_tab_liqui_rel(vr_indice).vlpagurp,'fm99999g999g990d00') ||                    
                    ';'|| TO_CHAR(pr_tab_liqui_rel(vr_indice).dtpagto,'DD/MM/RRRR')   ||
                    ';'|| GENE0007.fn_caract_acento(pr_tab_liqui_rel(vr_indice).dsocorre_urp) ||
                    ';'|| pr_tab_liqui_rel(vr_indice).nrdconta ||
                    ';'|| pr_tab_liqui_rel(vr_indice).estorno  || chr(13);
                    
    
      gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,vr_dslinha,FALSE);            
    
      vr_indice := pr_tab_liqui_rel.next(vr_indice);
    END LOOP;

    /**********REJEITADOS**************************************/  
    vr_indice := pr_tab_rejei_rel.FIRST;
    
    WHILE vr_indice IS NOT NULL LOOP
    
      vr_dslinha :=       pr_tab_rejei_rel(vr_indice).dssituacao ||
                    ';'|| TO_CHAR(pr_tab_rejei_rel(vr_indice).nrremret,'fm999999g990') ||
                    ';'|| TO_CHAR(pr_tab_rejei_rel(vr_indice).cdbanco,'fm999999g990')  ||
                    ';'|| TO_CHAR(pr_tab_rejei_rel(vr_indice).dhdgerac_rem,'DD/MM/RRRR HH:MM:SS') ||
                    ';'|| TO_CHAR(pr_tab_rejei_rel(vr_indice).dtparadebito,'DD/MM/RRRR') ||
                    ';'|| TO_CHAR(pr_tab_rejei_rel(vr_indice).dtvencto,'DD/MM/RRRR') ||
                    ';'|| TO_CHAR(pr_tab_rejei_rel(vr_indice).vldpagto,'fm99999g999g990d00') ||
                    ';'|| pr_tab_rejei_rel(vr_indice).nmcedent ||
                    ';'|| pr_tab_rejei_rel(vr_indice).dsnosnum ||
                    ';'''|| pr_tab_rejei_rel(vr_indice).dscodbar || '''' ||
                    ';'|| TO_CHAR(pr_tab_rejei_rel(vr_indice).vltitulo,'fm99999g999g990d00') ||
                    ';'|| TO_CHAR(pr_tab_rejei_rel(vr_indice).vldescto,'fm99999g999g990d00') ||
                    ';'|| TO_CHAR(pr_tab_rejei_rel(vr_indice).vlacresc,'fm99999g999g990d00') ||
                    ';'|| TO_CHAR(pr_tab_rejei_rel(vr_indice).vlpagurp,'fm99999g999g990d00') ||                    
                    ';'|| TO_CHAR(pr_tab_rejei_rel(vr_indice).dtpagto,'DD/MM/RRRR')  ||
                    ';'|| GENE0007.fn_caract_acento(pr_tab_rejei_rel(vr_indice).dsocorre_urp) ||
                    ';'|| pr_tab_rejei_rel(vr_indice).nrdconta ||
                    ';'|| pr_tab_rejei_rel(vr_indice).estorno  || chr(13);
                    
    
      gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,vr_dslinha,FALSE);            
    
      vr_indice := pr_tab_rejei_rel.next(vr_indice);
    END LOOP;
  
  
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,' ',TRUE); --> Fechar xml


    -- Busca do diretório base da cooperativa
    vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                              pr_cdcooper => pr_cdcooper,
                                              pr_nmsubdir => '/rl'); --> Utilizaremos o rl

    -- Nome do arquivo
    vr_nom_arquivo := 'REL_AGDPGT_' ||TO_CHAR(SYSDATE, 'ddmmrrrrhh24mmss') ||'.csv';
                          
    -- Envia o arquivo por e-mail e move para o diretório "salvar"
    gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper,  --> Cooperativa conectada
                                        pr_cdprogra  => 'UPPGTO',     --> Programa chamador
                                        pr_dtmvtolt  => SYSDATE,      --> Data do movimento atual
                                        pr_dsxml     => vr_des_xml,   --> Arquivo XML de dados (CLOB)
                                        pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo, --> Arquivo final
                                        pr_flg_impri => 'N',          --> Chamar a impressão (Imprim.p)
                                        pr_flg_gerar => 'S',          --> Gerar o arquivo na hora
                                        pr_dspathcop => gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                                              pr_cdcooper => pr_cdcooper,
                                                                              pr_nmsubdir => '/salvar'),    --> Diretórios a copiar o relatório
                                        pr_dsextcop  => 'txt',        --> Extensão para cópia do relatório aos diretórios
--                                          pr_flgremarq => 'S',                 --> Flag para remover o arquivo após cópia/email
                                        pr_des_erro  => vr_dscritic); --> Saída com erro
                                            
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
  
    IF pr_iddspscp = 0 THEN -- Manter cópia do arquivo via scp para o servidor destino
    CASE gene0001.vr_vet_des_origens(pr_idorigem)
      WHEN 'AIMARO WEB' THEN
        gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_nmarqpdf => vr_nom_diretorio||'/'||vr_nom_arquivo
                                    ,pr_des_reto => vr_des_erro
                                    ,pr_tab_erro => vr_tab_erro);
      WHEN 'INTERNET' THEN
        gene0002.pc_efetua_copia_arq_ib(pr_cdcooper => pr_cdcooper 
                                       ,pr_nmarqpdf => vr_nom_diretorio||'/'||vr_nom_arquivo
                                       ,pr_des_erro => vr_des_erro);
      ELSE NULL;        
    END CASE;
    ELSE     
      gene0002.pc_copia_arq_para_download(pr_cdcooper => pr_cdcooper
                                         ,pr_dsdirecp => vr_nom_diretorio||'/'
                                         ,pr_nmarqucp => vr_nom_arquivo
                                         ,pr_flgcopia => 0
                                         ,pr_dssrvarq => pr_dssrvarq
                                         ,pr_dsdirarq => pr_dsdirarq
                                         ,pr_des_erro => vr_dscritic);
                                         
      IF vr_dscritic IS NOT NULL AND TRIM(vr_dscritic) <> ' ' THEN
        RAISE vr_exc_saida;
      END IF;
    END IF;
  
    pr_nmarquiv := vr_nom_arquivo;
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || pr_nmdatela || ': ' || SQLERRM;
      
      ROLLBACK;

  END pc_relato_arq_pgto_csv;   

  PROCEDURE pc_relato_arq_pgto_pdf(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cod cooperativa
                                  ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                  ,pr_cdagenci IN crapass.cdagenci%TYPE --> PA
                                  ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE --> Numero caixa
                                  ,pr_idorigem IN INTEGER               --> Sistema origem
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE --> Cod Operador
                                  ,pr_nrdconta IN VARCHAR2              --> Conta 
                                  ,pr_nmarquvo IN VARCHAR2              --> Arquivo
                                  ,pr_nrremess IN VARCHAR2              --> Numero remessa
                                  ,pr_dstpdata IN VARCHAR2              --> Descricao Tipo de data
                                  ,pr_dtiniper IN DATE                  --> Data inicio periodo
                                  ,pr_dtfimper IN DATE                  --> Data fim do periodo
                                  ,pr_nmbenefi IN VARCHAR2              --> Nome beneficiario
                                  ,pr_dscodbar IN VARCHAR2              --> Codigo barras
                                  ,pr_cdsittit IN VARCHAR2              --> Situacao do titulo                                   
                                  ,pr_iddspscp IN INTEGER               --> Parametro criado para permitir a geracao do relatorio para o IB atual e para o IB novo                                                                   
                                  ,pr_tab_agend_rel  IN typ_tab_rel_arq --> PLTABLE com os dados
                                  ,pr_tab_liqui_rel  IN typ_tab_rel_arq --> PLTABLE com os dados
                                  ,pr_tab_rejei_rel  IN typ_tab_rel_arq --> PLTABLE com os dados
                                  ,pr_nmarquiv OUT VARCHAR2             --> Nome do arquivo gerado
                                  ,pr_dssrvarq OUT VARCHAR2             --> Nome do servidor para download do arquivo
                                  ,pr_dsdirarq OUT VARCHAR2             --> Nome do diretório para download do arquivo                                                                                                                                   
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_relato_arq_pgto_pdf
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Tiago
        Data    : Setembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Retornar relatorio referentes aos agendamentos de pagamento de 
                    titulos que foram integrados no ayllos por arquivo.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    ---------> CURSORES <--------
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    vr_des_erro VARCHAR2(1000); --> Desc. Erro
    vr_des_reto VARCHAR2(03);           --> OK ou NOK
    vr_tab_erro GENE0001.typ_tab_erro;  --> Tabela com erros
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    vr_indice         VARCHAR2(15);
    vr_flagenda       BOOLEAN;
    vr_flrejeit       BOOLEAN;
    vr_flliquid       BOOLEAN;
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml       CLOB;
    vr_des_txt       VARCHAR2(32700);
    vr_dslinha       VARCHAR2(4000);
    -- Variável para o caminho e nome do arquivo base
    vr_nom_diretorio VARCHAR2(200);
    vr_nom_arquivo   VARCHAR2(200);
    
    vr_dssituacao    VARCHAR2(9);
    
  BEGIN
    
    -- Inicializar o CLOB
    vr_des_xml := null;
    vr_des_txt := null;
    dbms_lob.createtemporary(vr_des_xml, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    
    --Escrever no arquivo XML
    gene0002.pc_escreve_xml(vr_des_xml, vr_des_txt,'<?xml version="1.0" encoding="UTF-8"?><uppgto><dados>');

    --Cabeçalho
    vr_dslinha:=  '<cabecalho>'       ||
                    '<nrdconta>'     || NVL(pr_nrdconta,' ') || '</nrdconta>' ||
                    '<nmarquiv>'     || NVL(pr_nmarquvo,' ') || '</nmarquiv>' ||
                    '<nrremess>'     || NVL(to_char(pr_nrremess,'fm999999g990'),' ') || '</nrremess>' ||
                    '<dtremess>'     || NVL(pr_dstpdata,' ')  || '</dtremess>'  ||
                    '<dtiniper>'     || NVL(to_char(pr_dtiniper,'DD/MM/RRRR'),' ') || '</dtiniper>' ||           
                    '<dtfimper>'     || NVL(to_char(pr_dtfimper,'DD/MM/RRRR'),' ') || '</dtfimper>' ||
                    '<nmbenefi>'     || NVL(pr_nmbenefi,' ')                   || '</nmbenefi>' ||
                    '<dscodbar>'     || NVL(pr_dscodbar,' ')                   || '</dscodbar>' ||
                    '<cdsittit>'     || NVL(pr_cdsittit,' ')              || '</cdsittit>' ||
                  '</cabecalho><agendados>';

    gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,vr_dslinha,FALSE);            

    vr_indice := pr_tab_agend_rel.FIRST;
    
    WHILE vr_indice IS NOT NULL LOOP
             
      vr_dslinha:=  '<agendado>'       ||
                      '<nrremret>'     || to_char(pr_tab_agend_rel(vr_indice).nrremret,'fm999999g990') || '</nrremret>' ||
                      '<cdbanco>'      || to_char(pr_tab_agend_rel(vr_indice).cdbanco,'fm999999g990')  || '</cdbanco>'  ||
                      '<dhdgerac_rem>' || to_char(pr_tab_agend_rel(vr_indice).dhdgerac_rem,'DD/MM/RRRR') || '</dhdgerac_rem>' ||           
                      '<dtparadebito>' || to_char(pr_tab_agend_rel(vr_indice).dtparadebito,'DD/MM/RRRR') || '</dtparadebito>' ||
                      '<dtvencto>'     || to_char(pr_tab_agend_rel(vr_indice).dtvencto,'DD/MM/RRRR')     || '</dtvencto>' ||
                      '<nmcedent>'     || pr_tab_agend_rel(vr_indice).nmcedent                         || '</nmcedent>' ||
                      '<dsnosnum>'     || pr_tab_agend_rel(vr_indice).dsnosnum                         || '</dsnosnum>' ||
                      '<vltitulo>'     || to_char(pr_tab_agend_rel(vr_indice).vltitulo,'fm99999g999g990d00')   || '</vltitulo>' ||
                      '<vldescto>'     || to_char(pr_tab_agend_rel(vr_indice).vldescto,'fm99999g999g990d00')   || '</vldescto>' ||
                      '<vlacresc>'     || to_char(pr_tab_agend_rel(vr_indice).vlacresc,'fm99999g999g990d00')   || '</vlacresc>' ||
                      '<vlpagurp>'     || to_char(pr_tab_agend_rel(vr_indice).vlpagurp,'fm99999g999g990d00')   || '</vlpagurp>' ||
                      '<dscodbar>'     || pr_tab_agend_rel(vr_indice).dscodbar                         || '</dscodbar>' ||
                    '</agendado>';
                        
      gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,vr_dslinha,FALSE);            
    
      vr_indice := pr_tab_agend_rel.next(vr_indice);
                        
    END LOOP;

    gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'</agendados><liquidados>',FALSE);            

    vr_indice := pr_tab_liqui_rel.FIRST;
     
    WHILE vr_indice IS NOT NULL LOOP
        
      vr_dslinha:=  '<liquidado>'      ||
                      '<nrremret>'     || to_char(pr_tab_liqui_rel(vr_indice).nrremret,'fm999999g990') || '</nrremret>' ||
                      '<cdbanco>'      || to_char(pr_tab_liqui_rel(vr_indice).cdbanco,'fm999999g990')  || '</cdbanco>' ||
                      '<dhdgerac_rem>' || to_char(pr_tab_liqui_rel(vr_indice).dhdgerac_rem,'DD/MM/RRRR') || '</dhdgerac_rem>' ||           
                      '<dtparadebito>' || to_char(pr_tab_liqui_rel(vr_indice).dtparadebito,'DD/MM/RRRR') || '</dtparadebito>' ||
                      '<dtvencto>'     || to_char(pr_tab_liqui_rel(vr_indice).dtvencto,'DD/MM/RRRR')     || '</dtvencto>' ||
                      '<nmcedent>'     || pr_tab_liqui_rel(vr_indice).nmcedent                         || '</nmcedent>' ||
                      '<dsnosnum>'     || pr_tab_liqui_rel(vr_indice).dsnosnum                         || '</dsnosnum>' ||
                      '<vltitulo>'     || to_char(pr_tab_liqui_rel(vr_indice).vltitulo,'fm99999g999g990d00')   || '</vltitulo>' ||
                      '<vldescto>'     || to_char(pr_tab_liqui_rel(vr_indice).vldescto,'fm99999g999g990d00')   || '</vldescto>' ||
                      '<vlacresc>'     || to_char(pr_tab_liqui_rel(vr_indice).vlacresc,'fm99999g999g990d00')   || '</vlacresc>' ||
                      '<vlpagurp>'     || to_char(pr_tab_liqui_rel(vr_indice).vlpagurp,'fm99999g999g990d00')   || '</vlpagurp>' ||
                      '<estorno>'      || pr_tab_liqui_rel(vr_indice).estorno                          || '</estorno>'  ||
                      '<dscodbar>'     || pr_tab_liqui_rel(vr_indice).dscodbar                         || '</dscodbar>' ||
                    '</liquidado>';

      gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,vr_dslinha,FALSE);            
    
      vr_indice := pr_tab_liqui_rel.next(vr_indice);

    END LOOP;          
    
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'</liquidados><rejeitados>',FALSE);            
    vr_indice := pr_tab_rejei_rel.FIRST;
    
    WHILE vr_indice IS NOT NULL LOOP
        
      vr_dslinha:=  '<rejeitado>'      ||
                      '<nrremret>'     || to_char(pr_tab_rejei_rel(vr_indice).nrremret,'fm999999g990') || '</nrremret>' ||
                      '<cdbanco>'      || to_char(pr_tab_rejei_rel(vr_indice).cdbanco,'fm999999g990')  || '</cdbanco>' ||
                      '<dhdgerac_rem>' || to_char(pr_tab_rejei_rel(vr_indice).dhdgerac_rem,'DD/MM/RRRR') || '</dhdgerac_rem>' ||           
                      '<dtparadebito>' || to_char(pr_tab_rejei_rel(vr_indice).dtparadebito,'DD/MM/RRRR') || '</dtparadebito>' ||
                      '<nmcedent>'     || pr_tab_rejei_rel(vr_indice).nmcedent                         || '</nmcedent>' ||
                      '<dsnosnum>'     || pr_tab_rejei_rel(vr_indice).dsnosnum                         || '</dsnosnum>' ||
                      '<dscodbar>'     || pr_tab_rejei_rel(vr_indice).dscodbar                         || '</dscodbar>' ||
                      '<vltitulo>'     || to_char(pr_tab_rejei_rel(vr_indice).vltitulo,'fm99999g999g990d00')   || '</vltitulo>' ||
                      '<dsocorre_urp>' || pr_tab_rejei_rel(vr_indice).dsocorre_urp                     || '</dsocorre_urp>' ||
                    '</rejeitado>';
                          
      gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,vr_dslinha,FALSE);            
    
      vr_indice := pr_tab_rejei_rel.next(vr_indice);
                        
    END LOOP;
         
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,'</rejeitados></dados></uppgto>',FALSE);            
    gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,' ',TRUE); --> Fechar xml


    -- Busca do diretório base da cooperativa
    vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                              pr_cdcooper => pr_cdcooper,
                                              pr_nmsubdir => '/rl'); --> Utilizaremos o rl

    -- Nome do arquivo
    vr_nom_arquivo := 'REL_AGDPGT_' ||TO_CHAR(SYSDATE, 'ddmmrrrrhh24mmss')||'.pdf';

    -- Gera relatório crrl073
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                               ,pr_cdprogra  => 'UPPGTO'                      --> Programa chamador
                               ,pr_dtmvtolt  => SYSDATE                       --> Data do movimento atual
                               ,pr_dsxml     => vr_des_xml                    --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/uppgto/dados'               --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'uppgto.jasper'               --> Arquivo de layout do iReport
                               ,pr_dsparams  => NULL                          --> Sem parâmetros
                               ,pr_cdrelato => 735                            --> Código fixo para o relatório (nao busca pelo sqcabrel)                                       
                               ,pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo --> Arquivo final com o path
                               ,pr_qtcoluna  => 234                           --> Colunas do relatorio
                               ,pr_flg_gerar => 'S'                           --> Geraçao na hora
                               ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => '234col'                       --> Nome do formulário para impressão
                               ,pr_nrcopias  => 1                             --> Número de cópias
                               --,pr_sqcabrel  => 1                             --> Qual a seq do cabrel
                               --,pr_flappend  => 'S'                           --> Fazer append do relatorio se ja existir
                               ,pr_des_erro  => vr_dscritic);                 --> Saída com erro
    --Se ocorreu erro no relatorio
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_saida;
    END IF; 

    --Fechar Clob e Liberar Memoria  
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);             

    IF pr_iddspscp = 0 THEN -- Manter cópia do arquivo via scp para o servidor destino
    CASE gene0001.vr_vet_des_origens(pr_idorigem)
      WHEN 'AIMARO WEB' THEN
        --Enviar arquivo para Web
        gene0002.pc_efetua_copia_pdf (pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                     ,pr_cdagenci => pr_cdagenci     --> Codigo da agencia para erros
                                     ,pr_nrdcaixa => pr_nrdcaixa     --> Codigo do caixa para erros
                                     ,pr_nmarqpdf => vr_nom_diretorio||'/'||vr_nom_arquivo --> Arquivo PDF  a ser gerado
                                     ,pr_des_reto => vr_des_reto     --> Saída com erro
                                     ,pr_tab_erro => vr_tab_erro);
      
        --Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          --Se tem erro na tabela 
          IF vr_tab_erro.COUNT > 0 THEN
             vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
             vr_dscritic:= 'Erro ao enviar arquivo para web.';  
          END IF;  
          --Sair 
          RAISE vr_exc_saida;
        END IF;
        
      WHEN 'INTERNET' THEN
        gene0002.pc_efetua_copia_arq_ib(pr_cdcooper => pr_cdcooper 
                                       ,pr_nmarqpdf => vr_nom_diretorio||'/'||vr_nom_arquivo
                                       ,pr_des_erro => vr_des_erro);
      ELSE NULL;        
    END CASE;
    ELSE
      gene0002.pc_copia_arq_para_download(pr_cdcooper => pr_cdcooper
                                         ,pr_dsdirecp => vr_nom_diretorio||'/'
                                         ,pr_nmarqucp => vr_nom_arquivo
                                         ,pr_flgcopia => 0
                                         ,pr_dssrvarq => pr_dssrvarq
                                         ,pr_dsdirarq => pr_dsdirarq
                                         ,pr_des_erro => vr_dscritic);
                                         
      IF vr_dscritic IS NOT NULL AND TRIM(vr_dscritic) <> ' ' THEN
        RAISE vr_exc_saida;
      END IF;
    END IF;
  
    pr_nmarquiv := vr_nom_arquivo;
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || pr_nmdatela || ': ' || SQLERRM;
      
      ROLLBACK;

  END pc_relato_arq_pgto_pdf;   

  PROCEDURE pc_relato_arq_pgto(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cod Cooperativa
                              ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                              ,pr_cdagenci IN crapass.cdagenci%TYPE --> PA
                              ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE --> Numero caixa
                              ,pr_cdoperad IN crapope.cdoperad%TYPE --> Cod Operador
                              ,pr_nrdconta IN INTEGER               --> Conta
                              ,pr_nrremess IN INTEGER               --> Numero da Remessa
                              ,pr_nmarquiv IN VARCHAR2              --> Nome do arquivo que esta sendo processado
                              ,pr_nmbenefi IN VARCHAR2              --> Nome do beneficiario
                              ,pr_dscodbar IN VARCHAR2              --> Codigo de barras
                              ,pr_idstatus IN INTEGER               --> Status do Titulo (1-Todos /2-Liquidado /3-Pendente de Liquidação / 4-Com erro
                              ,pr_tpdata   IN INTEGER               --> Tipo de Data que está sendo pesquisada (1-Data de Remessa / 2-Data de Vencimento / 3-Data Agendada para Pagamento)
                              ,pr_dtiniper IN DATE                  --> Data inicial de pesquisa
                              ,pr_dtfimper IN DATE                  --> Data final   de pesquisa
                              ,pr_idorigem IN INTEGER               --> Sistema de origem chamador
                              ,pr_tprelato IN INTEGER               --> Tipo do relatorio (1-PDF /2-CSV)
                              ,pr_iddspscp IN INTEGER               --> Parametro criado para permitir a geracao do relatorio para o IB atual e para o IB novo
                              ,pr_nmrelato OUT VARCHAR2             --> Nome do arquivo do relatorio com extensao
                              ,pr_dssrvarq OUT VARCHAR2             --> Nome do servidor para download do arquivo
                              ,pr_dsdirarq OUT VARCHAR2             --> Nome do diretório para download do arquivo                                                               
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_relato_arq_pgto
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Tiago
        Data    : Setembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Retornar relatorio referentes aos agendamentos de pagamento de 
                    titulos que foram integrados no ayllos por arquivo.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    ---------> CURSORES <--------
    CURSOR cr_relat( pr_cdcooper     crapass.cdcooper%TYPE
                    ,pr_nrdconta     crapass.nrdconta%TYPE
                    ,pr_nrremret     craphpt.nrremret%TYPE
                    ,pr_nmarquiv     craphpt.nmarquiv%TYPE
                    ,pr_dscodbar     VARCHAR2
                    ,pr_nmbenefi     VARCHAR2
                    ,pr_idstatus     INTEGER
                    ,pr_dtmvtolt     DATE
                    ,pr_dtremess_ini DATE
                    ,pr_dtremess_fim DATE 
                    ,pr_dtvencto_ini DATE 
                    ,pr_dtvencto_fim DATE
                    ,pr_dtdpagto_ini DATE  
                    ,pr_dtdpagto_fim DATE) IS
      SELECT decode(remessa.nrnivel_urp
                   ,2,decode(dpt_urp.cdocorre,'BD','Agendado','Rejeitado')
                   ,3,decode(dpt_urp.cdocorre,'00','Liquidado','Rejeitado')
                   ,'Rejeitado') dssituacao
            ,hpt_rem.nrremret
            ,to_number(substr(dpt_rem.dscodbar,1,3)) cdbanco
            ,to_date(to_char(hpt_rem.dtdgerac,'ddmmyyyy')||' '||lpad(hpt_rem.hrdgerac,6,'0'),'ddmmyyyy hh24miss') dhdgerac_rem
            ,pgta0001.fn_converte_fator_vencimento(pr_dtmvtolt => TRUNC(pr_dtmvtolt), pr_nrdfator => SUBSTR(dpt_rem.dscodbar,6,4)) dtparadebito
            ,pgta0001.fn_converte_fator_vencimento(pr_dtmvtolt => TRUNC(pr_dtmvtolt), pr_nrdfator => SUBSTR(dpt_rem.dscodbar,6,4)) dtvencto
            ,dpt_rem.vldpagto
            ,dpt_rem.nmcedent
            ,dpt_rem.dsnosnum
            ,dpt_rem.dscodbar
            ,dpt_rem.vltitulo
            ,dpt_rem.vldescto
            ,dpt_rem.vlacresc
            ,dpt_urp.vldpagto vlpagurp
            ,dpt_urp.dtdpagto dtpagto
            ,dpt_urp.cdocorre||'-'||g059_urp.dsdominio dsocorre_urp
            ,hpt_urp.nrdconta
            ,nvl(
                 (
                  SELECT aut.estorno
                    FROM crapaut aut_est
                        ,crapaut aut
                        ,craptit tit
                        ,craplau lau
                   WHERE aut_est.estorno  <> 0
                     AND aut_est.nrseqaut = aut.nrsequen
                     AND aut_est.dtmvtolt = aut.dtmvtolt
                     AND aut_est.nrdcaixa = aut.nrdcaixa
                     AND aut_est.cdagenci = aut.cdagenci
                     AND aut_est.cdcooper = aut.cdcooper
                     --
                     AND aut.nrsequen = tit.nrautdoc
                     AND aut.dtmvtolt = tit.dtmvtolt
                     AND aut.nrdcaixa = (tit.nrdolote-16000) /*conforme regra em cxon0014.pc_gera_titulos_iptu*/
                     AND aut.cdagenci = tit.cdagenci
                     AND aut.cdcooper = tit.cdcooper
                     --
                     AND upper(tit.dscodbar) = upper(lau.dscodbar)
                     AND tit.nrdolote = 16900 /*fixo cxon0014.pc_gera_titulos_iptu*/
                     AND tit.cdbccxlt = 11 /*fixo cxon0014.pc_gera_titulos_iptu*/
                     AND tit.cdagenci = lau.cdagenci
                     AND tit.dtmvtolt = lau.dtmvtopg
                     AND tit.cdcooper = lau.cdcooper
                     --
                     AND lau.idlancto IN dpt_rem.idlancto
                 )
                ,0) estorno
      FROM cecred.tbcobran_arq_pgt_dominio g059_urp
          ,crapdpt dpt_urp
          ,craphpt hpt_urp
          ,cecred.tbcobran_arq_pgt_dominio g059_rem
          ,crapdpt dpt_rem
          ,craphpt hpt_rem
          ,(
            SELECT referencia.cdcooper
                  ,referencia.nrdconta
                  ,referencia.nrconven
                  ,referencia.intipmvt
                  ,referencia.nrremret
                  ,referencia.nrseqarq
                  ,to_number(substr(referencia.ult_reg_prc,1,3)) nrnivel_urp
                  ,to_number(substr(referencia.ult_reg_prc,4,5)) intipmvt_urp
                  ,to_number(substr(referencia.ult_reg_prc,9,10)) nrremret_urp
                  ,to_number(substr(referencia.ult_reg_prc,19,10)) nrseqarq_urp
              FROM (
                  SELECT dptr.cdcooper
                        ,dptr.nrdconta
                        ,dptr.nrconven
                        ,dptr.intipmvt
                        ,dptr.nrremret
                        ,dptr.nrseqarq
                        ,(/*query com hierarquia para buscar a última ocorrencia de processamento do registro*/
                          SELECT MAX(
                                     to_char(level,'fm000')
                                   ||to_char(dptho.intipmvt,'fm00000')
                                   ||to_char(dptho.nrremret,'fm0000000000')
                                   ||to_char(dptho.nrseqarq,'fm0000000000')
                                    ) dsocorre
                            FROM crapdpt dptho
                          START WITH dptho.rowid = dptr.rowid
                          CONNECT BY dptho.cdcooper = PRIOR dptho.cdcooper
                                 AND dptho.nrdconta = PRIOR dptho.nrdconta
                                 AND dptho.nrconven = PRIOR dptho.nrconven
                                 AND dptho.tpmvtorg = PRIOR dptho.intipmvt
                                 AND dptho.nrmvtorg = PRIOR dptho.nrremret
                                 AND dptho.nrarqorg = PRIOR dptho.nrseqarq
                         ) ult_reg_prc
                    FROM crapdpt dptr
                        ,craphpt hptr
                   WHERE dptr.nrremret = hptr.nrremret
                     AND dptr.intipmvt = hptr.intipmvt
                     AND dptr.nrconven = hptr.nrconven
                     AND dptr.nrdconta = hptr.nrdconta
                     AND dptr.cdcooper = hptr.cdcooper
                     AND hptr.dtmvtolt >= (
                                           select min(hptref.dtmvtolt)
                                           from crapdpt dptref
                                               ,craphpt hptref
                                           where dptref.tpmvtorg is not null
                                             and dptref.nrremret = hptref.nrremret
                                             and dptref.intipmvt = hptref.intipmvt
                                             and dptref.nrconven = hptref.nrconven
                                             and dptref.nrdconta = hptref.nrdconta
                                             and dptref.cdcooper = hptref.cdcooper
                                             and hptref.intipmvt = 2 /*retorno*/
                                             and hptref.nrconven = hptr.nrconven
                                             and hptref.nrdconta = hptr.nrdconta
                                             and hptref.cdcooper = hptr.cdcooper
                                          )                     
                     --
                     AND hptr.nrremret = NVL(pr_nrremret,hptr.nrremret)
                     AND (hptr.nmarquiv LIKE '%'||TRIM(pr_nmarquiv)||'%' OR TRIM(pr_nmarquiv) IS NULL)
                     AND (TRUNC(hptr.dtdgerac) BETWEEN pr_dtremess_ini AND pr_dtremess_fim OR pr_dtremess_ini IS NULL)
                     AND (TRUNC(hptr.dtdgerac) BETWEEN pr_dtvencto_ini AND pr_dtvencto_fim OR pr_dtvencto_ini IS NULL)
                     AND (TRUNC(hptr.dtdgerac) BETWEEN pr_dtdpagto_ini AND pr_dtdpagto_fim OR pr_dtdpagto_ini IS NULL)
                     --
                     AND hptr.intipmvt = 1 /*remessa*/
                     AND hptr.nrdconta = NVL(pr_nrdconta,hptr.nrdconta)
                     AND hptr.cdcooper = NVL(pr_cdcooper,hptr.cdcooper)
                 ) referencia
           ) remessa
     WHERE g059_urp.cddominio (+) = dpt_urp.cdocorre
       AND g059_urp.cdcampo (+) = 'G059'
       --
       AND hpt_urp.nrremret = dpt_urp.nrremret
       AND hpt_urp.intipmvt = dpt_urp.intipmvt
       AND hpt_urp.nrconven = dpt_urp.nrconven
       AND hpt_urp.nrdconta = dpt_urp.nrdconta
       AND hpt_urp.cdcooper = dpt_urp.cdcooper
       --
       AND dpt_urp.nrseqarq = remessa.nrseqarq_urp
       AND dpt_urp.nrremret = remessa.nrremret_urp
       AND dpt_urp.intipmvt = remessa.intipmvt_urp
       AND dpt_urp.nrconven = remessa.nrconven
       AND dpt_urp.nrdconta = remessa.nrdconta    
       AND dpt_urp.cdcooper = remessa.cdcooper
       --
       AND g059_rem.cddominio (+) = dpt_rem.cdocorre
       AND g059_rem.cdcampo (+) = 'G059'
       --
       AND hpt_rem.nrremret = dpt_rem.nrremret
       AND hpt_rem.intipmvt = dpt_rem.intipmvt
       AND hpt_rem.nrconven = dpt_rem.nrconven
       AND hpt_rem.nrdconta = dpt_rem.nrdconta
       AND hpt_rem.cdcooper = dpt_rem.cdcooper
       --
       AND dpt_rem.nrseqarq = remessa.nrseqarq
       AND dpt_rem.nrremret = remessa.nrremret
       AND dpt_rem.intipmvt = remessa.intipmvt
       AND dpt_rem.nrconven = remessa.nrconven
       AND dpt_rem.nrdconta = remessa.nrdconta
       AND dpt_rem.cdcooper = remessa.cdcooper
       -- Filtros da TELA       
         -- Nome do Beneficiario
       AND (UPPER(dpt_rem.nmcedent) LIKE '%'||TRIM(UPPER(pr_nmbenefi))||'%' OR TRIM(pr_nmbenefi) IS NULL)             
         -- Codigo de Barras
       AND (UPPER(dpt_rem.dscodbar) LIKE '%'||TRIM(UPPER(pr_dscodbar))||'%' OR TRIM(pr_dscodbar) IS NULL)
         -- Status do Titulo
       AND ( -- Liquidado
            (pr_idstatus = 2 AND dpt_urp.cdocorre = '00') OR
            -- Pendente de Liquidacao
            (pr_idstatus = 3 AND dpt_urp.cdocorre = 'BD') OR
            -- Com erro
            (pr_idstatus = 4 AND dpt_urp.cdocorre NOT IN ('00', 'BD')) OR
            -- Todos 
            (pr_idstatus = 1 OR pr_idstatus IS NULL));
            
    rw_relat cr_relat%ROWTYPE; 
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variveis de controle
    vr_nragenda NUMBER(6);
    vr_nrliquid NUMBER(6);
    vr_nrrejeit NUMBER(6);
    
    -- Data de Remessa
    vr_dtremess_ini DATE;
    vr_dtremess_fim DATE;
    -- Data de Vencimento
    vr_dtvencto_ini DATE;
    vr_dtvencto_fim DATE;
    -- Data Agendada para Pagamento
    vr_dtdpagto_ini DATE;
    vr_dtdpagto_fim DATE;
    
    vr_deschave VARCHAR2(15);    
    
    vr_dstpdata VARCHAR2(25);
    vr_dsstatus VARCHAR2(25); 
    
    --pl table com os dados do relatorio
    vr_tab_rel typ_tab_rel_arq;
    
    vr_tab_agend_rel typ_tab_rel_arq;
    vr_tab_liqui_rel typ_tab_rel_arq;
    vr_tab_rejei_rel typ_tab_rel_arq;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
      
    vr_dsmanipulacao  VARCHAR2(40);
    vr_nmdcampo       tbcobran_cpt_log.nmdcampo%TYPE;
    vr_nmtabela       tbcobran_cpt_log.nmtabela%TYPE;
    
    vr_flghomol       crapcpt.flghomol%TYPE;
    
  BEGIN

    vr_tab_agend_rel.DELETE;
    vr_tab_liqui_rel.DELETE;
    vr_tab_rejei_rel.DELETE;
    
    -- Zerar a informação de data de REMESSA
    vr_dtremess_ini := NULL;
    vr_dtremess_fim := NULL;
    -- Zerar a informação de data de VENCIMENTO
    vr_dtvencto_ini := NULL;
    vr_dtvencto_fim := NULL;
    -- Zerar a informação de data de AGENDADA PARA PAGAMENTO
    vr_dtdpagto_ini := NULL;
    vr_dtdpagto_fim := NULL;

    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;


    -- Verificar qual é o parametro de DATA que foi selecionado para filtrar
    IF pr_tpdata = 1 THEN
      -- Foi selecionado em tela a DATA DA REMESSA
      vr_dtremess_ini := pr_dtiniper;
      vr_dtremess_fim := pr_dtfimper;
      vr_dstpdata := 'DATA DA REMESSA';
    ELSIF pr_tpdata = 2 THEN
      -- Foi selecionado em tela a DATA DE VENCIMENTO
      vr_dtvencto_ini := pr_dtiniper;
      vr_dtvencto_fim := pr_dtfimper;
      vr_dstpdata := 'DATA DE VENCIMENTO';
    ELSIF pr_tpdata = 3 then
      -- Foi selecionado em tela a AGENDADA PARA PAGAMENTO
      vr_dtdpagto_ini := pr_dtiniper;
      vr_dtdpagto_fim := pr_dtfimper;
      vr_dstpdata := 'AGENDADA PARA PAGAMENTO';
    END IF;
    
    IF pr_idstatus = 1 THEN
       vr_dsstatus := 'TODOS';
    ELSIF pr_idstatus = 2 THEN
       vr_dsstatus := 'LIQUIDADO';
    ELSIF pr_idstatus = 3 THEN
       vr_dsstatus := 'PENDENTE DE LIQUIDAÇÃO';
    ELSIF pr_idstatus = 4 THEN
       vr_dsstatus := 'COM ERRO';
    END IF;
    
    FOR rw_relat IN cr_relat(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nmarquiv => pr_nmarquiv
                            ,pr_nrremret => pr_nrremess
                            ,pr_dscodbar => pr_dscodbar
                            ,pr_nmbenefi => pr_nmbenefi
                            ,pr_idstatus => pr_idstatus
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_dtremess_ini => vr_dtremess_ini
                            ,pr_dtremess_fim => vr_dtremess_fim
                            ,pr_dtvencto_ini => vr_dtvencto_ini
                            ,pr_dtvencto_fim => vr_dtvencto_fim
                            ,pr_dtdpagto_ini => vr_dtdpagto_ini
                            ,pr_dtdpagto_fim => vr_dtdpagto_fim) LOOP
          
                      
      CASE UPPER(rw_relat.dssituacao)
        WHEN 'AGENDADO'  THEN 
          vr_nragenda := NVL(vr_nragenda,0) + 1; 
          vr_deschave := UPPER(rw_relat.dssituacao)||LPAD(TO_CHAR(vr_nragenda),6,'0');

          vr_tab_agend_rel(vr_deschave).dssituacao   := UPPER(rw_relat.dssituacao);
          vr_tab_agend_rel(vr_deschave).nrremret     := rw_relat.nrremret;
          vr_tab_agend_rel(vr_deschave).cdbanco      := rw_relat.cdbanco;
          vr_tab_agend_rel(vr_deschave).dhdgerac_rem := rw_relat.dhdgerac_rem;
          vr_tab_agend_rel(vr_deschave).dtparadebito := rw_relat.dtparadebito;
          vr_tab_agend_rel(vr_deschave).dtvencto     := rw_relat.dtvencto;
          vr_tab_agend_rel(vr_deschave).vldpagto     := rw_relat.vldpagto;
          vr_tab_agend_rel(vr_deschave).nmcedent     := rw_relat.nmcedent;
          vr_tab_agend_rel(vr_deschave).dsnosnum     := rw_relat.dsnosnum;
          vr_tab_agend_rel(vr_deschave).dscodbar     := rw_relat.dscodbar;
          vr_tab_agend_rel(vr_deschave).vltitulo     := rw_relat.vltitulo;
          vr_tab_agend_rel(vr_deschave).vldescto     := rw_relat.vldescto;
          vr_tab_agend_rel(vr_deschave).vlacresc     := rw_relat.vlacresc;
          vr_tab_agend_rel(vr_deschave).vlpagurp     := rw_relat.vlpagurp;
          vr_tab_agend_rel(vr_deschave).dtpagto      := rw_relat.dtpagto;
          vr_tab_agend_rel(vr_deschave).dsocorre_urp := rw_relat.dsocorre_urp;
          vr_tab_agend_rel(vr_deschave).nrdconta     := rw_relat.nrdconta;
          vr_tab_agend_rel(vr_deschave).estorno      := rw_relat.estorno;
          
          
        WHEN 'LIQUIDADO' THEN 
          vr_nrliquid := NVL(vr_nrliquid,0) + 1; 
          vr_deschave := UPPER(rw_relat.dssituacao)||LPAD(TO_CHAR(vr_nrliquid),6,'0');

          vr_tab_liqui_rel(vr_deschave).dssituacao   := UPPER(rw_relat.dssituacao);
          vr_tab_liqui_rel(vr_deschave).nrremret     := rw_relat.nrremret;
          vr_tab_liqui_rel(vr_deschave).cdbanco      := rw_relat.cdbanco;
          vr_tab_liqui_rel(vr_deschave).dhdgerac_rem := rw_relat.dhdgerac_rem;
          vr_tab_liqui_rel(vr_deschave).dtparadebito := rw_relat.dtparadebito;
          vr_tab_liqui_rel(vr_deschave).dtvencto     := rw_relat.dtvencto;
          vr_tab_liqui_rel(vr_deschave).vldpagto     := rw_relat.vldpagto;
          vr_tab_liqui_rel(vr_deschave).nmcedent     := rw_relat.nmcedent;
          vr_tab_liqui_rel(vr_deschave).dsnosnum     := rw_relat.dsnosnum;
          vr_tab_liqui_rel(vr_deschave).dscodbar     := rw_relat.dscodbar;
          vr_tab_liqui_rel(vr_deschave).vltitulo     := rw_relat.vltitulo;
          vr_tab_liqui_rel(vr_deschave).vldescto     := rw_relat.vldescto;
          vr_tab_liqui_rel(vr_deschave).vlacresc     := rw_relat.vlacresc;
          vr_tab_liqui_rel(vr_deschave).vlpagurp     := rw_relat.vlpagurp;
          vr_tab_liqui_rel(vr_deschave).dtpagto      := rw_relat.dtpagto;
          vr_tab_liqui_rel(vr_deschave).dsocorre_urp := rw_relat.dsocorre_urp;
          vr_tab_liqui_rel(vr_deschave).nrdconta     := rw_relat.nrdconta;
          vr_tab_liqui_rel(vr_deschave).estorno      := rw_relat.estorno;
          
          
        WHEN 'REJEITADO' THEN 
          vr_nrrejeit := NVL(vr_nrrejeit,0) + 1; 
          vr_deschave := UPPER(rw_relat.dssituacao)||LPAD(TO_CHAR(vr_nrrejeit),6,'0');
          
          vr_tab_rejei_rel(vr_deschave).dssituacao   := UPPER(rw_relat.dssituacao);
          vr_tab_rejei_rel(vr_deschave).nrremret     := rw_relat.nrremret;
          vr_tab_rejei_rel(vr_deschave).cdbanco      := rw_relat.cdbanco;
          vr_tab_rejei_rel(vr_deschave).dhdgerac_rem := rw_relat.dhdgerac_rem;
          vr_tab_rejei_rel(vr_deschave).dtparadebito := rw_relat.dtparadebito;
          vr_tab_rejei_rel(vr_deschave).dtvencto     := rw_relat.dtvencto;
          vr_tab_rejei_rel(vr_deschave).vldpagto     := rw_relat.vldpagto;
          vr_tab_rejei_rel(vr_deschave).nmcedent     := rw_relat.nmcedent;
          vr_tab_rejei_rel(vr_deschave).dsnosnum     := rw_relat.dsnosnum;
          vr_tab_rejei_rel(vr_deschave).dscodbar     := rw_relat.dscodbar;
          vr_tab_rejei_rel(vr_deschave).vltitulo     := rw_relat.vltitulo;
          vr_tab_rejei_rel(vr_deschave).vldescto     := rw_relat.vldescto;
          vr_tab_rejei_rel(vr_deschave).vlacresc     := rw_relat.vlacresc;
          vr_tab_rejei_rel(vr_deschave).vlpagurp     := rw_relat.vlpagurp;
          vr_tab_rejei_rel(vr_deschave).dtpagto      := rw_relat.dtpagto;
          vr_tab_rejei_rel(vr_deschave).dsocorre_urp := rw_relat.dsocorre_urp;
          vr_tab_rejei_rel(vr_deschave).nrdconta     := rw_relat.nrdconta;
          vr_tab_rejei_rel(vr_deschave).estorno      := rw_relat.estorno;
          
        ELSE NULL;
      END CASE;
      
    END LOOP;
    
    IF vr_tab_agend_rel.count() = 0 AND
       vr_tab_liqui_rel.count() = 0 AND
       vr_tab_rejei_rel.count() = 0 THEN
       vr_cdcritic := 0;
       vr_dscritic := 'Nao ha informacoes para serem exibidas no relatorio.';
       RAISE vr_exc_saida;
    END IF;
    
    /*Relatorio em PDF*/
    IF pr_tprelato = 1 THEN
       pc_relato_arq_pgto_pdf(pr_cdcooper => pr_cdcooper   --> Cooperativa
                             ,pr_nmdatela => pr_nmdatela   --> Nome da tela
                             ,pr_cdagenci => pr_cdagenci   --> PA
                             ,pr_nrdcaixa => pr_nrdcaixa   --> Numero caixa
                             ,pr_idorigem => pr_idorigem   --> Sistema origem
                             ,pr_cdoperad => pr_cdoperad   --> Cod Operador
                             ,pr_nrdconta => pr_nrdconta   --> Conta 
                             ,pr_nmarquvo => pr_nmarquiv   --> Arquivo
                             ,pr_nrremess => pr_nrremess   --> Numero remessa
                             ,pr_dstpdata => vr_dstpdata   --> Descricao Tipo de data
                             ,pr_dtiniper => pr_dtiniper   --> Data inicio periodo
                             ,pr_dtfimper => pr_dtfimper   --> Data fim do periodo
                             ,pr_nmbenefi => pr_nmbenefi   --> Nome beneficiario
                             ,pr_dscodbar => pr_dscodbar   --> Codigo barras
                             ,pr_cdsittit => vr_dsstatus   --> Situacao do titulo
                             ,pr_iddspscp => pr_iddspscp   --> Parametro criado para permitir a geracao do relatorio para o IB atual e para o IB novo
                             ,pr_tab_agend_rel  => vr_tab_agend_rel    --> PLTABLE com os dados
                             ,pr_tab_liqui_rel  => vr_tab_liqui_rel    --> PLTABLE com os dados
                             ,pr_tab_rejei_rel  => vr_tab_rejei_rel    --> PLTABLE com os dados
                             ,pr_nmarquiv => pr_nmrelato   --> Nome do arquivo gerado
                             ,pr_dssrvarq => pr_dssrvarq
                             ,pr_dsdirarq => pr_dsdirarq                             
                             ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                             ,pr_dscritic => vr_dscritic); --> Descricao da critica
    END IF;

    /*Relatorio em CSV*/
    IF pr_tprelato = 2 THEN
       pc_relato_arq_pgto_csv(pr_cdcooper => pr_cdcooper   --> Cooperativa
                             ,pr_nmdatela => pr_nmdatela   --> Nome da tela
                             ,pr_cdagenci => pr_cdagenci   --> PA
                             ,pr_nrdcaixa => pr_nrdcaixa   --> Numero caixa
                             ,pr_idorigem => pr_idorigem   --> Sistema origem
                             ,pr_cdoperad => pr_cdoperad   --> Cod Operador
                             ,pr_iddspscp => pr_iddspscp   --> Parametro criado para permitir a geracao do relatorio para o IB atual e para o IB novo
                             ,pr_tab_agend_rel  => vr_tab_agend_rel    --> PLTABLE com os dados
                             ,pr_tab_liqui_rel  => vr_tab_liqui_rel    --> PLTABLE com os dados
                             ,pr_tab_rejei_rel  => vr_tab_rejei_rel    --> PLTABLE com os dados
                             ,pr_nmarquiv => pr_nmrelato   --> Nome do arquivo gerado
                             ,pr_dssrvarq => pr_dssrvarq
                             ,pr_dsdirarq => pr_dsdirarq                             
                             ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                             ,pr_dscritic => vr_dscritic); --> Descricao da critica
       
    END IF;

    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      ROLLBACK;

  END pc_relato_arq_pgto;     
  

  PROCEDURE pc_relato_arq_pgto_web(pr_nrdconta IN INTEGER               --> Conta
                                  ,pr_nrremess IN INTEGER               --> Numero da Remessa
                                  ,pr_nmarquiv IN VARCHAR2              --> Nome do arquivo que esta sendo processado
                                  ,pr_nmbenefi IN VARCHAR2              --> Nome do beneficiario
                                  ,pr_dscodbar IN VARCHAR2              --> Codigo de barras
                                  ,pr_idstatus IN INTEGER               --> Status do Titulo (1-Todos /2-Liquidado /3-Pendente de Liquidação / 4-Com erro
                                  ,pr_tpdata   IN INTEGER               --> Tipo de Data que está sendo pesquisada (1-Data de Remessa / 2-Data de Vencimento / 3-Data Agendada para Pagamento)
                                  ,pr_dtiniper IN VARCHAR2              --> Data inicial de pesquisa
                                  ,pr_dtfimper IN VARCHAR2              --> Data final   de pesquisa
                                  ,pr_tprelato IN INTEGER               --> Tipo do relatorio (1-PDF /2-CSV)
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................
    
        Programa: pc_relato_arq_pgto
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Tiago
        Data    : Setembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Retornar relatorio referentes aos agendamentos de pagamento de 
                    titulos que foram integrados no ayllos por arquivo.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    ---------> CURSORES <--------
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    --pl table com os dados do relatorio
    vr_tab_rel typ_tab_rel_arq;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_nmrelato VARCHAR2(100);
    vr_dssrvarq VARCHAR2(200);
    vr_dsdirarq VARCHAR2(200);    
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
      
    vr_dsmanipulacao  VARCHAR2(40);
    vr_nmdcampo       tbcobran_cpt_log.nmdcampo%TYPE;
    vr_nmtabela       tbcobran_cpt_log.nmtabela%TYPE;
    
    vr_flghomol       crapcpt.flghomol%TYPE;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
  BEGIN
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    pc_relato_arq_pgto(pr_cdcooper => vr_cdcooper
                      ,pr_nmdatela => vr_nmdatela
                      ,pr_cdagenci => vr_cdagenci
                      ,pr_nrdcaixa => vr_nrdcaixa
                      ,pr_cdoperad => vr_cdoperad
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrremess => pr_nrremess
                      ,pr_nmarquiv => pr_nmarquiv
                      ,pr_nmbenefi => pr_nmbenefi
                      ,pr_dscodbar => pr_dscodbar
                      ,pr_idstatus => pr_idstatus
                      ,pr_tpdata =>   pr_tpdata
                      ,pr_dtiniper => TO_DATE(pr_dtiniper,'DD/MM/RRRR')
                      ,pr_dtfimper => TO_DATE(pr_dtfimper,'DD/MM/RRRR')
                      ,pr_idorigem => vr_idorigem
                      ,pr_tprelato => pr_tprelato
                      ,pr_iddspscp => 0
                      ,pr_nmrelato => vr_nmrelato
                      ,pr_dssrvarq => vr_dssrvarq
                      ,pr_dsdirarq => vr_dsdirarq
                      ,pr_cdcritic => vr_cdcritic
                      ,pr_dscritic => vr_dscritic);
    
    IF vr_cdcritic <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;
    
    -- Leitura da PL/Table e geração do arquivo XML
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
                                       
    pc_escreve_xml('<inf>'||                      
                      '<nmrelato>' || vr_nmrelato ||'</nmrelato>' ||
                   '</inf>');
    
    pc_escreve_xml('</dados></root>',TRUE);    
    pr_retxml := XMLType.createXML(vr_des_xml);
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_relato_arq_pgto_web;     


  PROCEDURE pc_relato_arq_pgto_ib(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cod Cooperativa
                                 ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --> PA
                                 ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE --> Numero caixa
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE --> Cod Operador
                                 ,pr_nrdconta IN INTEGER               --> Conta
                                 ,pr_nrremess IN INTEGER               --> Numero da Remessa
                                 ,pr_nmarquiv IN VARCHAR2              --> Nome do arquivo que esta sendo processado
                                 ,pr_nmbenefi IN VARCHAR2              --> Nome do beneficiario
                                 ,pr_dscodbar IN VARCHAR2              --> Codigo de barras
                                 ,pr_idstatus IN INTEGER               --> Status do Titulo (1-Todos /2-Liquidado /3-Pendente de Liquidação / 4-Com erro
                                 ,pr_tpdata   IN INTEGER               --> Tipo de Data que está sendo pesquisada (1-Data de Remessa / 2-Data de Vencimento / 3-Data Agendada para Pagamento)
                                 ,pr_dtiniper IN VARCHAR2              --> Data inicial de pesquisa
                                 ,pr_dtfimper IN VARCHAR2              --> Data final   de pesquisa
                                 ,pr_idorigem IN INTEGER               --> Sistema de origem chamador
                                 ,pr_tprelato IN INTEGER               --> Tipo do relatorio (1-PDF /2-CSV)
                                 ,pr_iddspscp IN INTEGER               --> Parametro criado para permitir a geracao do relatorio para o IB atual e para o IB novo
                                 ,pr_nmrelato OUT VARCHAR2             --> Nome do arquivo do relatorio com extensao
                                 ,pr_dssrvarq OUT VARCHAR2             --> Nome do servidor para download do arquivo
                                 ,pr_dsdirarq OUT VARCHAR2             --> Nome do diretório para download do arquivo                                 
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_relato_arq_pgto_ib
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Tiago
        Data    : Setembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Retornar relatorio referentes aos agendamentos de pagamento de 
                    titulos que foram integrados no ayllos por arquivo.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    vr_dtiniper DATE;
    vr_dtfimper DATE;
  BEGIN
    
    vr_dtiniper := to_date(pr_dtiniper,'DD/MM/YYYY');
    vr_dtfimper := to_date(pr_dtfimper,'DD/MM/YYYY');
    
    pc_relato_arq_pgto(pr_cdcooper => pr_cdcooper
                      ,pr_nmdatela => pr_nmdatela
                      ,pr_cdagenci => pr_cdagenci
                      ,pr_nrdcaixa => pr_nrdcaixa
                      ,pr_cdoperad => pr_cdoperad
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrremess => pr_nrremess
                      ,pr_nmarquiv => pr_nmarquiv
                      ,pr_nmbenefi => pr_nmbenefi
                      ,pr_dscodbar => pr_dscodbar
                      ,pr_idstatus => pr_idstatus
                      ,pr_tpdata   => pr_tpdata  
                      ,pr_dtiniper => vr_dtiniper
                      ,pr_dtfimper => vr_dtfimper
                      ,pr_idorigem => pr_idorigem
                      ,pr_tprelato => pr_tprelato
                      ,pr_iddspscp => pr_iddspscp
                      ,pr_nmrelato => pr_nmrelato
                      ,pr_dssrvarq => pr_dssrvarq
                      ,pr_dsdirarq => pr_dsdirarq
                      ,pr_cdcritic => pr_cdcritic
                      ,pr_dscritic => pr_dscritic);
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral PGTA0001.pc_relato_arq_pgto_ib: ' || SQLERRM;
      ROLLBACK;

  END pc_relato_arq_pgto_ib;

  --importa arquivo 
  PROCEDURE pc_importa_pagarq(pr_cdcooper  IN crapcop.cdcooper%TYPE
                             ,pr_dsarquiv  IN VARCHAR2
                             ,pr_dsdireto  IN VARCHAR2
                             ,pr_dscritic  OUT VARCHAR2
                             ,pr_retxml    OUT CLOB) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_importa_pagarq                  Antigo: Não há
  --  Sistema  : IB
  --  Sigla    : CRED
  --  Autor    : Tiago Machado flor - CECRED
  --  Data     : SET/2015.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Rotina para a importacao do arquivo
  --
  -- Alterações:
  ---------------------------------------------------------------------------------------------------------------

    -- CURSORES
    -- Registros
    TYPE typ_reccritc IS RECORD (nrdlinha NUMBER
                                ,dscritic VARCHAR2(1000));
    TYPE typ_tbcritic IS TABLE OF typ_reccritc INDEX BY BINARY_INTEGER;
    vr_tbcritic    typ_tbcritic; -- Tabela de criticas encontradas na validação do arquivo

    -- Variaveis
    vr_excerror    EXCEPTION;

    vr_dsdireto    VARCHAR2(100);
    vr_dsdlinha    VARCHAR2(500);
    vr_dscrilot    VARCHAR2(500); -- Critica a ser replicada no arquivo
    vr_dscriarq    VARCHAR2(500); -- Critica a ser replicada no arquivo
    vr_cdcritic    INTEGER;
    vr_dscritic    VARCHAR2(500); -- Critica
    vr_typ_said    VARCHAR2(50); -- Critica
    vr_des_erro    VARCHAR2(500); -- Critica
    vr_dsalert     VARCHAR2(500); -- Critica
    vr_tpregist    NUMBER;
    vr_qtlinhas    NUMBER;
    vr_indice      INTEGER;

    vr_nrdconta    NUMBER;
    vr_nmarquiv    VARCHAR2(100); -- Nome do arquivo gerado para gravação dos dados

    vr_clitmxml    CLOB;
    vr_dsitmxml    VARCHAR2(32767);

    vr_retxml      XMLType;
    vr_dsauxml     varchar2(32767);
    
    vr_tab_linhas  gene0009.typ_tab_linhas;
    vr_cdprogra    VARCHAR2(50) := 'PGTA0001.pc_importa_pagarq';

  BEGIN
    -- Busca o diretório do upload do arquivo
    vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'upload');

    -- Realizar a cópia do arquivo
    GENE0001.pc_OScommand_Shell(gene0001.fn_param_sistema('CRED',0,'SCRIPT_RECEBE_ARQUIVOS')||' '||pr_dsdireto||pr_dsarquiv||' S'
                               ,pr_typ_saida   => vr_typ_said
                               ,pr_des_saida   => vr_des_erro);

      -- Testar erro
    IF vr_typ_said = 'ERR' THEN
      -- O comando shell executou com erro, gerar log e sair do processo
      vr_dscritic := 'Erro realizar o upload do arquivo: ' || vr_des_erro;
      RAISE vr_excerror;
    END IF;

    -- Verifica se o arquivo existe
    IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdireto||'/'||pr_dsarquiv) THEN
      -- Retorno de erro
      vr_dscritic := 'Erro no upload do arquivo: '||REPLACE(vr_dsdireto,'/','-')||'-'||pr_dsarquiv;
      RAISE vr_excerror;
    END IF;    
    
    vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root></Root>');
    -- Converter o XML
    pr_retxml := vr_retxml.getClobVal();

  EXCEPTION
    WHEN vr_excerror THEN
      pr_dscritic := vr_dscritic;

      vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros</Erro></Root>');
       -- Converter o XML
      pr_retxml := vr_retxml.getClobVal();
    WHEN OTHERS THEN
      GENE0001.pc_OScommand_Shell('rm ' || vr_dsdireto || '/' || pr_dsarquiv);

      pr_dscritic := 'Erro geral na rotina pc_importa_pagarq: '||SQLERRM;
      
      vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros</Erro></Root>');
                                     
       -- Converter o XML
      pr_retxml := vr_retxml.getClobVal();
      
  END pc_importa_pagarq;
  
  /* Rotina para importacao do arquivo tela UPPGTO Através do AyllosWeb */
  PROCEDURE pc_importa_pagarq_web(pr_dsarquiv   IN VARCHAR2            --> Informações do arquivo
                                 ,pr_dsdireto   IN VARCHAR2            --> Informações do diretório do arquivo
                                 ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                 ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_importa_pagarq_web                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Tiago Machado Flor
  --  Data     : Set/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Rotina importacao arquivo
  --
  ---------------------------------------------------------------------------------------------------------------

    -- Variáveis
    vr_cdcooper    NUMBER;
    vr_nmdatela    VARCHAR2(25);
    vr_nmeacao     VARCHAR2(25);
    vr_cdagenci    VARCHAR2(25);
    vr_nrdcaixa    VARCHAR2(25);
    vr_idorigem    VARCHAR2(25);
    vr_cdoperad    VARCHAR2(25);
    vr_retxml      CLOB;

    vr_excerror    EXCEPTION;
    
  BEGIN

    -- Extrair informacoes padrao do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);

    -- Se houve erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_excerror;
    END IF;

    -- Realiza a chamada da rotina
    pc_importa_pagarq(pr_cdcooper => vr_cdcooper
                     ,pr_dsarquiv => pr_dsarquiv
                     ,pr_dsdireto => pr_dsdireto
                     ,pr_dscritic => pr_dscritic
                     ,pr_retxml   => vr_retxml);

    -- Se houve erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_excerror;
    END IF;

    -- Cria o XML de retorno
    pr_retxml := XMLType.createXML(vr_retxml);

  EXCEPTION
    WHEN vr_excerror THEN
      pr_des_erro := pr_dscritic;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros</Erro></Root>');
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral na rotina pc_importa_pagarq_web: '||SQLERRM;
      pr_des_erro := pr_dscritic;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>Rotina com erros</Erro></Root>');
  END pc_importa_pagarq_web;

  FUNCTION fn_converte_fator_vencimento(pr_dtmvtolt IN DATE    --Data Movimento
                                       ,pr_nrdfator IN INTEGER --Fator de vencimento
                                       ) RETURN DATE IS 
    --
    vr_dtvencto DATE := NULL; --Data de vencimento convertida
    --
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --
  BEGIN 
    --
    BEGIN 
      --
      cxon0014.pc_calcula_data_vencimento(pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_de_campo => pr_nrdfator
                                         ,pr_dtvencto => vr_dtvencto
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      --
    EXCEPTION 
      WHEN OTHERS THEN 
        vr_dtvencto := NULL;
    END;
    --
    RETURN TRUNC(vr_dtvencto);
    --
  END fn_converte_fator_vencimento;
  
/* Funcao para validacao dos caracteres */
FUNCTION fn_valida_caracteres (pr_flgnumer IN BOOLEAN,  -- Validar Numeros?
                               pr_flgletra IN BOOLEAN,  -- Validar Letras?
                               pr_listaesp IN VARCHAR2, -- Lista de Caracteres Validos
                               pr_dsvalida IN VARCHAR2  -- Texto para ser validado
                              ) RETURN BOOLEAN IS       -- ERRO -> TRUE
/* ............................................................................

  Programa: fn_valida_caracteres                           antiga:b1wgen0090/valida_caracteres
  Autor   : Douglas Quisinski
  Data    : Dezembro/2015                  Ultima atualizacao:

  Dados referentes ao programa:

  Objetivo  : Rotina de validacao de caracteres com base parametros informados
              Se o texto que esta sendo validado tiver algum caracter que nao esta na lista
              vai retornar ERRO -> TRUE

  Parametros : pr_flgnumer : Validar lista de numeros ?
               pr_flgletra : Validar lista de letras  ?
               pr_listaesp : Lista de caracteres validados.
               pr_validar  : Campo a ser validado.

  Alteracoes: 
............................................................................ */   
  vr_dsvalida VARCHAR2(30000);
      
  vr_numeros  VARCHAR2(10) := '0123456789';
--Necessario acrescentar esta variavel por causa da 
  --funcao CAN-DO do Progress, que permite simbolos como "(" e ")";
  vr_simbolos VARCHAR2(10) := '().,/-_:';
  vr_letras   VARCHAR2(49) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  --vr_letras   VARCHAR2(49) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÀÄÂÃÉÈËÊÍÌÏÎÓÒÖÔÕÚÙÜÛÇ';
  vr_validar  VARCHAR2(30000);
  vr_caracter VARCHAR2(1);
      
  TYPE typ_tab_char IS TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(1);
  vr_tab_char typ_tab_char;
            
BEGIN
      
  vr_dsvalida := REPLACE(UPPER(pr_dsvalida),' ','');
  -- Caso nao tenha campos a validar retorna OK
  IF TRIM(vr_dsvalida) IS NULL THEN
    RETURN FALSE;
  END IF;

  -- Numeros
  IF pr_flgnumer THEN
    -- Todos os caracteres devem ser numeros
    vr_validar:= vr_validar || vr_numeros;
  END IF;

  -- Letras 
  IF pr_flgletra THEN
    -- Todos os caracteres devem ser numeros
    vr_validar:= vr_validar || vr_letras;
  END IF;
      
  -- Lista Caracteres Aceitos
  IF TRIM(pr_listaesp) IS NOT NULL THEN
    vr_validar:= vr_validar || pr_listaesp;
  END IF;

--Necessario permitir simbolos "(" e ")";
  vr_validar := vr_validar || vr_simbolos;
  FOR vr_pos IN 1..length(vr_validar) LOOP
    vr_caracter:= SUBSTR(vr_validar,vr_pos,1);
    vr_tab_char(vr_caracter) := vr_caracter;
  END LOOP;
    
  FOR vr_pos IN 1..length(vr_dsvalida) LOOP
    vr_caracter:= SUBSTR(vr_dsvalida,vr_pos,1);
    IF NOT vr_tab_char.exists(vr_caracter) THEN
      RETURN TRUE;
    END IF;
  END LOOP;

  RETURN FALSE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END fn_valida_caracteres;

-- Funcao true or false para tratar conversao para numero sem gerar exceção
FUNCTION fn_numerico(pr_dsdtext IN VARCHAR2) RETURN BOOLEAN IS
  vr_nrdtext NUMBER;
BEGIN
  vr_nrdtext := to_number(pr_dsdtext);
  IF vr_nrdtext IS NOT NULL THEN
    RETURN TRUE;
  END IF;
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END;

PROCEDURE pc_val_headerarq_cnab240_ted (pr_linha_arquivo in varchar2
                             ,pr_nrdconta in integer
                             ,pr_cdcooper in integer
                             ,pr_tab_erros_headtrailer in out NOCOPY pgta0001.typ_tab_typ_erros_headtrailer -- Tabela de Memoria com as criticas
                             ,pr_cdcritic  out pls_integer
                             ,pr_dscritic  out varchar2) is

    /* .............................................................................
    
        Programa: pc_val_headerarq_cnab240_ted
        Sistema : CECRED
        Autor   : Jose Dill
        Data    : Maior/19.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Objetivo  : Validar as informações do Header do arquivo cnab 240 para teds e trasnferências.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/

  --> Buscar dados do associado
  CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                     pr_nrdconta crapass.nrdconta%TYPE) IS
  SELECT ass.nrcpfcgc,
         ass.inpessoa
    FROM crapass ass
   WHERE ass.cdcooper = pr_cdcooper
     AND ass.nrdconta = pr_nrdconta
     AND ass.dtdemiss is null;
  rw_crapass cr_crapass%ROWTYPE;

  --> Buscar agência 
  CURSOR cr_crapage (pr_cdcooper crapass.cdcooper%TYPE,
                     pr_cdagenci varchar2) IS     
  SELECT *
  FROM crapcop cop 
  WHERE cop.cdcooper = pr_cdcooper
  AND   lpad(cdagectl, 5, '0') = pr_cdagenci;
  rw_crapage cr_crapage%ROWTYPE;

  --Variaveis de exceção
  vr_exc_erro EXCEPTION;        
  
  vr_index      integer;             
  vr_bco_comp varchar2(03);
  vr_lote_ser varchar2(04);
  vr_insc_emp varchar2(01);
  vr_nrcpfcgc varchar2(14);
  vr_age_cop  varchar2(05);
  vr_nrdconta varchar2(13);
  vr_nmempre  varchar2(30);
  vr_cdremre  varchar2(01);
  vr_dtgerarq varchar2(08);
  vr_layout   varchar2(03);
  --
    
BEGIN
  /* Somatoria total de registros no arquivo */
  vr_qtreg_arq_total := vr_qtreg_arq_total + 1;
  -- 
  /*Código do Banco na Compensação */ 
  vr_bco_comp := substr(pr_linha_arquivo,1,3);
  IF vr_bco_comp <> '085' THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Arq';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AZ';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_bco_comp;
  END IF;
  /*Lote de Serviço*/
  vr_lote_ser := substr(pr_linha_arquivo,4,4);
  IF vr_lote_ser <> '0000' THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Arq';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'HH';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_lote_ser;
  END IF;
  /*Tipo Inscrição da Empresa*/
  vr_insc_emp := substr(pr_linha_arquivo,18,1);
  IF vr_insc_emp not in ('1','2') THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Arq';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AE';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_insc_emp;
  END IF;
  /*Número Inscrição (CPF/CNPJ)*/
  vr_nrcpfcgc:= substr(pr_linha_arquivo,19,14);
  --> Buscar dados do associado
  OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                   pr_nrdconta => pr_nrdconta);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%NOTFOUND THEN
    CLOSE cr_crapass;
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Arq';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AE';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_nrcpfcgc;
  ELSE
    CLOSE cr_crapass;
    --
    IF rw_crapass.nrcpfcgc <> TO_NUMBER(vr_nrcpfcgc) THEN       	
      vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
      pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Arq';
      pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AE';
      pr_tab_erros_headtrailer(vr_index).dscampo := vr_nrcpfcgc;
    END IF;  
    --    
    IF rw_crapass.inpessoa <> TO_NUMBER(vr_insc_emp) THEN       	
      vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
      pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Arq';
      pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AE';
      pr_tab_erros_headtrailer(vr_index).dscampo := vr_insc_emp;
    END IF;  

  END IF;  
  /*Agência Cooperativa*/
  vr_age_cop := substr(pr_linha_arquivo,53,5);
  OPEN cr_crapage (pr_cdcooper => pr_cdcooper,
                   pr_cdagenci => vr_age_cop);
  FETCH cr_crapage INTO rw_crapage;
  IF cr_crapage%NOTFOUND THEN
    CLOSE cr_crapage;
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Arq';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AG';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_age_cop;
  ELSE
    CLOSE cr_crapage;
  END IF;    
  /*Conta Corrente + Dígito*/
  vr_nrdconta := substr(pr_linha_arquivo,59,13);
  IF TO_NUMBER(vr_nrdconta) <> pr_nrdconta THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Arq';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'C1';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_nrdconta;
  END IF;
  /*Nome da Empresa*/
  vr_nmempre := substr(pr_linha_arquivo,73,30);
  IF vr_nmempre IS NULL THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Arq';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'NE';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_nmempre;
  END IF;
  /*Código remessa/Retorno*/
  vr_cdremre := substr(pr_linha_arquivo,143,1);
  IF vr_cdremre <> '1' THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Arq';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'HK';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_cdremre;
  END IF;
  /*Data geração do Arquivo*/
  vr_dtgerarq := substr(pr_linha_arquivo,144,8);
  IF to_date(vr_dtgerarq,'DDMMYYYY') < (SYSDATE - 30) THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Arq';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'DG';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_dtgerarq;
  END IF;
  /*Número sequencial do arquivo*/
  vr_nrseq_arq_ted := substr(pr_linha_arquivo,158,6);
  --
  IF TO_NUMBER(vr_nrseq_arq_ted) <= vr_nr_seq_gravada THEN  
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Arq';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AH';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_nrseq_arq_ted;
  END IF;

  /*Nº versão Layout*/
  vr_layout := substr(pr_linha_arquivo,164,3);
  IF vr_layout <> '087' THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Arq';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'HL';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_layout;
  END IF; 
  --
  BEGIN
    
    -- Grava a linha do header do arquivo na tabela de controle 
    INSERT INTO tbtransf_arquivo_ted_linhas (nrseq_arq_ted_linha, 
                                            nrseq_arq_ted,                                           
                                            dslinha_arq, 
                                            dsret_cnab, 
                                            dstipo_reg,
                                            dtgeracao)
                                    values (null,
                                            vr_id_nrseq_arq_ted,                                         
                                            substr(pr_linha_arquivo,1,240),
                                            'BD',
                                            '0',
                                            sysdate);
    --   
  EXCEPTION
   WHEN OTHERS THEN
      vr_dscritic := 'Erro ao inserir dados do header arq na tbtransf_arquivo_ted_linhas: '||sqlerrm;
      RAISE vr_exc_erro;
  END;   
EXCEPTION
  WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
  WHEN OTHERS THEN
      pr_dscritic:= 'Erro na proc pc_val_headerarq_cnab240_ted '||sqlerrm;

END pc_val_headerarq_cnab240_ted;

PROCEDURE pc_val_headerlot_cnab240_ted (pr_linha_arquivo in varchar2
                             ,pr_nrdconta in integer
                             ,pr_cdcooper in integer
                             ,pr_tab_erros_headtrailer in out NOCOPY pgta0001.typ_tab_typ_erros_headtrailer -- Tabela de Memoria com as criticas
                             ,pr_cdcritic  out pls_integer
                             ,pr_dscritic  out varchar2) is

    /* .............................................................................
    
        Programa: pc_val_headerlot_cnab240_ted
        Sistema : CECRED
        Autor   : Jose Dill
        Data    : Maior/19.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Objetivo  : Validar as informações do Header Lote do arquivo cnab 240 para teds e trasnferências.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/

 --> Buscar dados do associado
  CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                     pr_nrdconta crapass.nrdconta%TYPE) IS
  SELECT ass.nrcpfcgc,
         ass.inpessoa
    FROM crapass ass
   WHERE ass.cdcooper = pr_cdcooper
     AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  --> Buscar agência 
  CURSOR cr_crapage (pr_cdcooper crapass.cdcooper%TYPE,
                     pr_cdagenci varchar2) IS     
  SELECT *
  FROM crapcop cop 
  WHERE cop.cdcooper = pr_cdcooper
  AND   lpad(cdagectl, 5, '0') = pr_cdagenci;
  rw_crapage cr_crapage%ROWTYPE;
  
  --Variaveis de exceção
  vr_exc_erro EXCEPTION;        
  
  vr_index      integer;             
  vr_bco_comp varchar2(03);
  vr_lote_ser varchar2(04);
  vr_tpoperac varchar2(01);
  vr_tpservic varchar2(02);
  vr_insc_emp varchar2(01);
  vr_nrcpfcgc varchar2(14);
  vr_age_cop  varchar2(05);
  vr_nrdconta varchar2(13);
  vr_nmempre  varchar2(30);
  vr_layout   varchar2(03);
    
BEGIN
  /* Somatoria para validar qtde de registros do lote */
  vr_qtreg_lote := vr_qtreg_lote + 1;
  /* Somatoria para validar qtde de registros do header lote */
  vr_qtreg_header_lote := vr_qtreg_header_lote + 1;
  /* Somatoria total de registros no arquivo */
  vr_qtreg_arq_total := vr_qtreg_arq_total + 1;
  --
  /*Código do Banco na Compensação */ 
  vr_bco_comp := substr(pr_linha_arquivo,1,3);
  IF vr_bco_comp <> '085' THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Lote';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AZ';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_bco_comp;
  END IF;
  /*Tipo de operacao*/
  vr_tpoperac := substr(pr_linha_arquivo,9,1);
  IF vr_tpoperac <> 'D' THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Lote';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AB';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_tpoperac;
  END IF;
  /*Tipo de serviço*/
  vr_tpservic := substr(pr_linha_arquivo,10,2);
  IF vr_tpservic <> '01' THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Lote';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AC';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_tpservic;
  END IF;  
  /*Nº versão Layout*/
  vr_layout := substr(pr_linha_arquivo,14,3);
  IF vr_layout <> '018' THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Lote';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'HL';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_layout;
  END IF;   
  /*Tipo Inscrição da Empresa*/
  vr_insc_emp := substr(pr_linha_arquivo,18,1);
  IF vr_insc_emp not in ('1','2') THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Lote';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AE';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_insc_emp;
  END IF;  
  /*Número Inscrição (CPF/CNPJ)*/
  vr_nrcpfcgc:= substr(pr_linha_arquivo,19,14);
  --> Buscar dados do associado
  OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                   pr_nrdconta => pr_nrdconta);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%NOTFOUND THEN
    CLOSE cr_crapass;
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Lote';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AE';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_nrcpfcgc;    
  ELSE
    CLOSE cr_crapass;
    --
    IF rw_crapass.nrcpfcgc <> TO_NUMBER(vr_nrcpfcgc) THEN       	
      vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
      pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Lote';
      pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AE';
      pr_tab_erros_headtrailer(vr_index).dscampo := vr_nrcpfcgc;
    END IF;    
    --
    IF rw_crapass.inpessoa <> TO_NUMBER(vr_insc_emp) THEN       	
      vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
      pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Lote';
      pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AE';
      pr_tab_erros_headtrailer(vr_index).dscampo := vr_insc_emp;
    END IF;        
  END IF;  
  /*Agência Cooperativa*/
  vr_age_cop := substr(pr_linha_arquivo,53,5);
  OPEN cr_crapage (pr_cdcooper => pr_cdcooper,
                   pr_cdagenci => vr_age_cop);
  FETCH cr_crapage INTO rw_crapage;
  IF cr_crapage%NOTFOUND THEN
    CLOSE cr_crapage;
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Lote';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AG';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_age_cop;
  ELSE
    CLOSE cr_crapage;
  END IF;    
  
  /*Conta Corrente + Dígito*/
  vr_nrdconta := substr(pr_linha_arquivo,59,13);
  IF TO_NUMBER(vr_nrdconta) <> pr_nrdconta THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Lote';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'C1';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_nrdconta;
  END IF;
  /*Nome da Empresa*/
  vr_nmempre := substr(pr_linha_arquivo,73,30);
  IF vr_nmempre IS NULL THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Header Lote';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'NE';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_nmempre;
  END IF; 
  BEGIN
    -- Grava a linha do header do lote na tabela de controle 
    INSERT INTO tbtransf_arquivo_ted_linhas (nrseq_arq_ted_linha, 
                                            nrseq_arq_ted,                                           
                                            dslinha_arq, 
                                            dsret_cnab,
                                            dstipo_reg,
                                            dtgeracao)
                                    values (null,
                                            vr_id_nrseq_arq_ted,                                         
                                            substr(pr_linha_arquivo,1,240),
                                            'BD',
                                            '1',
                                            sysdate);
    --   
  EXCEPTION
   WHEN OTHERS THEN
      vr_dscritic := 'Erro ao inserir dados do header lot na tbtransf_arquivo_ted_linhas: '||sqlerrm;
      RAISE vr_exc_erro;
  END;

EXCEPTION
  WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
  WHEN OTHERS THEN
      pr_dscritic:= 'Erro na proc pc_val_headerlot_cnab240_ted '||sqlerrm;

END pc_val_headerlot_cnab240_ted;

PROCEDURE pc_val_trailerlot_cnab240_ted (pr_linha_arquivo in varchar2
                             ,pr_nrdconta in integer
                             ,pr_cdcooper in integer
                             ,pr_tab_erros_headtrailer in out NOCOPY pgta0001.typ_tab_typ_erros_headtrailer -- Tabela de Memoria com as criticas
                             ,pr_cdcritic  out pls_integer
                             ,pr_dscritic  out varchar2) is

    /* .............................................................................
    
        Programa: pc_val_trailerlot_cnab240_ted
        Sistema : CECRED
        Autor   : Jose Dill
        Data    : Maior/19.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Objetivo  : Validar as informações do Trailer do lote cnab 240 para teds e trasnferências.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/

  vr_index     integer;             
  vr_bco_comp  varchar2(03);
  vr_lote_ser  varchar2(04);
  vr_qtde_lote varchar2(06);
  vr_vlr_ope   varchar2(18);
  
  vr_exc_erro  exception;

    
BEGIN
  /* Somatoria para validar qtde de registros do lote */
  vr_qtreg_lote := vr_qtreg_lote + 1;
  /* Somatoria total de registros no arquivo */
  vr_qtreg_arq_total := vr_qtreg_arq_total + 1;
  --
  /*Código do Banco na Compensação */ 
  vr_bco_comp := substr(pr_linha_arquivo,1,3);
  IF vr_bco_comp <> '085' THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Trailer Lote';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AZ';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_bco_comp;
  END IF;
  /*Quantidade de lote arquivo*/
  vr_qtde_lote := substr(pr_linha_arquivo,18,6);
  IF TO_NUMBER(vr_qtde_lote) <> vr_qtreg_lote THEN 
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Trailer Lote';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'TA';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_qtde_lote;
  END IF;  
  /*Valor total das Operações*/
  vr_vlr_ope := substr(pr_linha_arquivo,24,18);
  IF TO_NUMBER(vr_vlr_ope) <> vr_vlrpgt_segm_a THEN 
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Trailer Lote';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'VT';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_vlr_ope;
  END IF;  
  --
  BEGIN
    -- Grava a linha do trailer do lote na tabela de controle 
    INSERT INTO tbtransf_arquivo_ted_linhas (nrseq_arq_ted_linha, 
                                            nrseq_arq_ted,                                           
                                            dslinha_arq, 
                                            dsret_cnab, 
                                            dstipo_reg,
                                            dtgeracao)
                                    values (null,
                                            vr_id_nrseq_arq_ted,                                         
                                            substr(pr_linha_arquivo,1,240),
                                            'BD',
                                            '5',
                                            sysdate);
    --   
  EXCEPTION
   WHEN OTHERS THEN
      vr_dscritic := 'Erro ao inserir dados do trailer lot na tbtransf_arquivo_ted_linhas: '||sqlerrm;
      RAISE vr_exc_erro;
  END;    
  
EXCEPTION
  WHEN vr_exc_erro THEN
    pr_dscritic := vr_dscritic; 
    -- 
  WHEN OTHERS THEN
    pr_dscritic:= 'Erro na proc pc_val_trailerlot_cnab240_ted '||sqlerrm;
    --
END pc_val_trailerlot_cnab240_ted;

PROCEDURE pc_val_trailerarq_cnab240_ted (pr_linha_arquivo in varchar2
                             ,pr_nrdconta in integer
                             ,pr_cdcooper in integer
                             ,pr_tab_erros_headtrailer in out NOCOPY pgta0001.typ_tab_typ_erros_headtrailer -- Tabela de Memoria com as criticas
                             ,pr_cdcritic  out pls_integer
                             ,pr_dscritic  out varchar2) is

    /* .............................................................................
    
        Programa: pc_val_trailerarq_cnab240_ted
        Sistema : CECRED
        Autor   : Jose Dill
        Data    : Maior/19.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Objetivo  : Validar as informações do Trailer do arquivo cnab 240 para teds e trasnferências.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/

  vr_index     integer;             
  vr_bco_comp  varchar2(03);
  vr_lote_ser  varchar2(04);
  vr_qtde_lote varchar2(06);
  vr_qtde_reg  varchar2(06);
  vr_exc_erro  exception;
    
BEGIN
  /* Somatoria total de registros no arquivo */
  vr_qtreg_arq_total := vr_qtreg_arq_total + 1;
  --
  /*Código do Banco na Compensação */ 
  vr_bco_comp := substr(pr_linha_arquivo,1,3);
  IF vr_bco_comp <> '085' THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Trailer Arq';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AZ';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_bco_comp;
  END IF;
  /*Lote de Serviço*/
  vr_lote_ser := substr(pr_linha_arquivo,4,4);
  IF vr_lote_ser <> '9999' THEN
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Trailer Arq';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'AC';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_lote_ser;
  END IF;
  /*Quantidade de lote arquivo*/
  vr_qtde_lote := substr(pr_linha_arquivo,18,6);
  IF TO_NUMBER(vr_qtde_lote) <> vr_qtreg_header_lote THEN 
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Trailer Arq';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'TA';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_qtde_lote;
  END IF;  
  /*Quantidade de registros arquivo*/
  vr_qtde_reg := substr(pr_linha_arquivo,24,6);
  IF TO_NUMBER(vr_qtde_reg) <> vr_qtreg_arq_total THEN 
    vr_index := pr_tab_erros_headtrailer.COUNT() + 1;
    pr_tab_erros_headtrailer(vr_index).tporigem := 'Trailer Arq';
    pr_tab_erros_headtrailer(vr_index).tperrocnab := 'TA';
    pr_tab_erros_headtrailer(vr_index).dscampo := vr_qtde_reg;
  END IF;  
  BEGIN
    -- Grava a linha do trailer do arquivo na tabela de controle 
    INSERT INTO tbtransf_arquivo_ted_linhas (nrseq_arq_ted_linha, 
                                            nrseq_arq_ted,                                           
                                            dslinha_arq, 
                                            dsret_cnab, 
                                            dstipo_reg,
                                            dtgeracao)
                                    values (null,
                                            vr_id_nrseq_arq_ted,                                         
                                            substr(pr_linha_arquivo,1,240),
                                            'BD',
                                            '9',
                                            sysdate);
    --   
  EXCEPTION
   WHEN OTHERS THEN
      vr_dscritic := 'Erro ao inserir dados do trailer arq na tbtransf_arquivo_ted_linhas: '||sqlerrm;
      RAISE vr_exc_erro;
  END;    
  
EXCEPTION
  WHEN vr_exc_erro THEN
    pr_dscritic := vr_dscritic; 
    -- 
  WHEN OTHERS THEN
      pr_dscritic:= 'Erro na proc pc_val_trailer_cnab240_ted '||sqlerrm;

END pc_val_trailerarq_cnab240_ted;

PROCEDURE pc_val_segment_a_cnab240_ted (pr_linha_arquivo in varchar2
                             ,pr_nrdconta in integer
                             ,pr_cdcooper in integer
                             ,pr_tab_dados_segmento_a in out NOCOPY pgta0001.typ_tab_dados_segmento_a -- Tabela de memoria do segmento a
                             ,pr_cdcritic  out pls_integer
                             ,pr_dscritic  out varchar2) is

    /* .............................................................................
    
        Programa: pc_val_segment_a_cnab240_ted
        Sistema : CECRED
        Autor   : Jose Dill
        Data    : Maior/19.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Objetivo  : Validar as informações do segmento A do arquivo cnab 240 para teds e trasnferências.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/

  CURSOR cr_bcofav (pr_bcofav in number) IS 
  SELECT 1
  FROM crapban ban
  WHERE ban.cdbccxlt = pr_bcofav;
  rr_bcofav cr_bcofav%ROWTYPE;  

  CURSOR cr_crapagb (pr_cddbanco in number
                   ,pr_cdagenci in number) IS   
  SELECT *
  FROM crapagb agb
  WHERE agb.cddbanco = pr_cddbanco
  and   agb.cdageban = pr_cdagenci;
  rr_crapagb cr_crapagb%ROWTYPE;  
  
  CURSOR cr_crapcop (pr_cdagenci in number) IS    
  SELECT cop.cdagectl
        ,cop.cdcooper
  FROM crapcop cop
  WHERE cop.cdagectl = pr_cdagenci;
  rr_crapcop cr_crapcop%ROWTYPE; 

 --> Buscar dados do associado
  CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                     pr_nrdconta crapass.nrdconta%TYPE) IS
  SELECT ass.nrcpfcgc,
         ass.inpessoa
    FROM crapass ass
   WHERE ass.cdcooper = pr_cdcooper
     AND ass.nrdconta = pr_nrdconta
     AND ass.dtdemiss is null;
  rw_crapass cr_crapass%ROWTYPE;

 --> Buscar dados da finalidade
  CURSOR cr_crapfin (pr_cdcooper crapass.cdcooper%TYPE,
                     pr_finalide integer) IS  
  SELECT tab.tpregist, tab.dstextab 
  FROM craptab tab
  WHERE tab.cdacesso = 'FINTRFTEDS'
  AND tab.cdcooper   = pr_cdcooper
  AND tab.tpregist   = pr_finalide;
  rr_crapfin cr_crapfin%ROWTYPE;
  
  -- Exceptions
  vr_erro_segmento_a exception;
  vr_exc_saida       exception;
   
  
  -- Variaveis    
  vr_index     integer;             
  vr_bco_comp  varchar2(03);
  vr_lote_ser  varchar2(04);
  vr_cdsegme   varchar2(01);
  vr_tpmovime  varchar2(01);
  vr_bcofavo   varchar2(03);
  vr_agefav    varchar2(05);
  vr_nrdconta  varchar2(12);
  vr_nrddgcta  varchar2(01);
  vr_nmfavor   varchar2(30);
  vr_dtpgto    varchar2(08);
  vr_tpmoeda   varchar2(03);
  vr_vlrpgt    varchar2(15);
  vr_insc_emp  varchar2(01);
  vr_nrcpfcgc  varchar2(14);
  vr_finalida  varchar2(05);
  vr_histra    varchar2(20);
  vr_stsnrcal  boolean;
  vr_inpessoa  integer:= null;
  vr_cdcooper_int crapcop.cdcooper%type;
  vr_flgnumer BOOLEAN;


BEGIN
  /* Seleciona todas as informacoes do arquivo para gravar na tabela temp e depois faz as validações*/
  vr_bco_comp := substr(pr_linha_arquivo,1,3);
  vr_lote_ser := substr(pr_linha_arquivo,4,4);
  vr_cdsegme := substr(pr_linha_arquivo,14,1);
  vr_tpmovime := substr(pr_linha_arquivo,15,1);
  vr_bcofavo := substr(pr_linha_arquivo,21,3);
  vr_agefav := substr(pr_linha_arquivo,24,5);
  vr_nmfavor := substr(pr_linha_arquivo,44,30);
  vr_nmfavor := replace(vr_nmfavor,'&','e');
  -- Validar os caracteres especiais do favorecido
  IF fn_valida_caracteres(pr_flgnumer => TRUE,   -- Validar Numeros
                        pr_flgletra => TRUE,   -- Validar Letras
                        pr_listaesp => '',     -- Lista Caracteres Validos (incluir caracteres que sao validos apenas para este campo)
                        pr_dsvalida => vr_nmfavor ) THEN 
    vr_dscritic:= 'Nome do favorecido possui caracteres especiais. '||vr_nmfavor;
    raise vr_exc_saida;
  END IF;
  --
  vr_agefav := substr(pr_linha_arquivo,24,5);
  vr_nrdconta:= substr(pr_linha_arquivo,30,12);
  vr_nrddgcta:= substr(pr_linha_arquivo,42,1);
  vr_dtpgto := substr(pr_linha_arquivo,94,8);
  vr_tpmoeda := substr(pr_linha_arquivo,102,3);
  vr_vlrpgt := substr(pr_linha_arquivo,120,15);
  vr_vlrpgt_segm_a := vr_vlrpgt_segm_a + TO_NUMBER(vr_vlrpgt);
  vr_finalida := substr(pr_linha_arquivo,220,5);
  vr_histra := substr(pr_linha_arquivo,178,20);
  vr_histra := replace(vr_histra,'&','e');
  -- Validar os caracteres especiais do histrocio
  IF fn_valida_caracteres(pr_flgnumer => TRUE,   -- Validar Numeros
                        pr_flgletra => TRUE,   -- Validar Letras
                        pr_listaesp => '',     -- Lista Caracteres Validos (incluir caracteres que sao validos apenas para este campo)
                        pr_dsvalida => vr_histra ) THEN 
    vr_dscritic:= 'Historico possui caracteres especiais. '||vr_histra;
    raise vr_exc_saida;
  END IF;
  --  
  vr_insc_emp := substr(pr_linha_arquivo,203,1);
  vr_nrcpfcgc:= substr(pr_linha_arquivo,204,14);
  --
  -- Atualiza temp
  vr_index := pr_tab_dados_segmento_a.COUNT() + 1;
  pr_tab_dados_segmento_a(vr_index).cdbco_comp := vr_bco_comp;
  pr_tab_dados_segmento_a(vr_index).nrlote_ser := vr_lote_ser;
  pr_tab_dados_segmento_a(vr_index).dstipo_reg := '3'; 
  pr_tab_dados_segmento_a(vr_index).cdsegmento := vr_cdsegme;
  pr_tab_dados_segmento_a(vr_index).dstipo_mov := vr_tpmovime;
  pr_tab_dados_segmento_a(vr_index).cdbco_fav := vr_bcofavo;
  pr_tab_dados_segmento_a(vr_index).cdage_conta := vr_agefav;
  pr_tab_dados_segmento_a(vr_index).nrdconta := Substr(vr_nrdconta||vr_nrddgcta,2,12);
  pr_tab_dados_segmento_a(vr_index).nmfavorecido := vr_nmfavor;
  pr_tab_dados_segmento_a(vr_index).dtprv_pgto := vr_dtpgto ;
  pr_tab_dados_segmento_a(vr_index).dsmoeda := vr_tpmoeda;
  pr_tab_dados_segmento_a(vr_index).vlrpgto := vr_vlrpgt;
  pr_tab_dados_segmento_a(vr_index).dshistorico := vr_histra;
  pr_tab_dados_segmento_a(vr_index).dsins_fav := vr_insc_emp;
  pr_tab_dados_segmento_a(vr_index).nr_cpf_cnpj_fav := vr_nrcpfcgc;
  pr_tab_dados_segmento_a(vr_index).dsfinalidade := vr_finalida;
  pr_tab_dados_segmento_a(vr_index).dslinha_seg_a := substr(pr_linha_arquivo,1,240);
  --  
  /* Somatoria para validar qtde de registros do lote */
  vr_qtreg_lote := vr_qtreg_lote + 1;
  /* Somatoria total de registros no arquivo */
  vr_qtreg_arq_total := vr_qtreg_arq_total + 1;
  --
  --SM01 Verificar se o numero da conta possui alfanumerico.  
  vr_flgnumer := fn_numerico(vr_nrddgcta);
  IF not vr_flgnumer THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'C1'; 
     raise vr_erro_segmento_a;
  END IF;
  --
  vr_flgnumer := fn_numerico(vr_nrdconta);
  IF not vr_flgnumer THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'C1'; 
     raise vr_erro_segmento_a;
  END IF;
  -- 
  
  /*Código do Banco na Compensação */ 
  IF vr_bco_comp <> '085' THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'AZ';
     raise vr_erro_segmento_a;
  END IF;
  /*Lote de Serviço*/
  /*IF vr_lote_ser <> '0001' THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'AC';
     raise vr_erro_segmento_a;
  END IF;*/
 
  /*Código Segmento*/
  IF vr_cdsegme <> 'A' THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'AI';
     raise vr_erro_segmento_a;
  END IF; 
   /*Tipo de Movimento*/
  IF vr_tpmovime not in ('1','2','3') THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'AJ';
     raise vr_erro_segmento_a;
  END IF; 
  /*Código Banco Favorecido*/
  OPEN cr_bcofav (TO_NUMBER(vr_bcofavo));  
  FETCH cr_bcofav into rr_bcofav;
  IF cr_bcofav%NOTFOUND THEN
     CLOSE cr_bcofav; 
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'AL';
     raise vr_erro_segmento_a;
  END IF;     
  CLOSE cr_bcofav;  
  --
  /*Agência Mantedora da conta*/
  IF vr_bcofavo = '085' THEN
    /* Se o banco for da cooperativa e o tipo de conta for conta corrente ou poupança, valida agência*/
    IF vr_tpmovime in ('1','2') THEN
      OPEN cr_crapcop (TO_NUMBER(vr_agefav));  
      FETCH cr_crapcop into rr_crapcop;
      IF cr_crapcop%NOTFOUND THEN
         CLOSE cr_crapcop;
         pr_tab_dados_segmento_a(vr_index).tperrocnab := 'A2';
         raise vr_erro_segmento_a; 
      END IF;    
      vr_cdcooper_int := rr_crapcop.cdcooper; 
      CLOSE cr_crapcop;
    END IF;
  ELSE
    /* Não será validada a agência para o tipo de conta Pagamento */
    IF vr_tpmovime in ('1','2') THEN
      /* Valida agência de outros bancos */
      OPEN cr_crapagb (TO_NUMBER(vr_bcofavo), TO_NUMBER(vr_agefav));  
      FETCH cr_crapagb into rr_crapagb;
      IF cr_crapagb%NOTFOUND THEN
         CLOSE cr_crapagb;
         pr_tab_dados_segmento_a(vr_index).tperrocnab := 'A2';
         raise vr_erro_segmento_a; 
      END IF;     
      CLOSE cr_crapagb; 
    END IF;   
  END IF;
  /*Digito da conta*/
  IF ltrim(vr_nrddgcta) is null THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'C2';
     raise vr_erro_segmento_a;  
  END IF; 
  /*Número da Conta Corrente*/
  IF vr_nrdconta = '000000000000' THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'C1';
     raise vr_erro_segmento_a;    
  ELSE
    IF  vr_bcofavo = '085' THEN         
      --> Buscar dados do associado
      OPEN cr_crapass (pr_cdcooper => vr_cdcooper_int,
                       pr_nrdconta => TO_NUMBER(vr_nrdconta||vr_nrddgcta));
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN        
         CLOSE cr_crapass;
         pr_tab_dados_segmento_a(vr_index).tperrocnab := 'C1';
         raise vr_erro_segmento_a; 
      END IF; 
      CLOSE cr_crapass;  
      --
      --SM01 Verificar se o cpf do favorecido é igual ao do seu cadastro
      IF rw_crapass.Nrcpfcgc <> TO_NUMBER(vr_nrcpfcgc) THEN
         pr_tab_dados_segmento_a(vr_index).tperrocnab := 'AE';
         raise vr_erro_segmento_a;
      END IF;
      --
    END IF;
  END IF; 
  
  /*Nome do Favorecido*/
  IF ltrim(vr_nmfavor) IS NULL THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'AO';
     raise vr_erro_segmento_a;
  END IF; 
 
  /*Data prevista para pagamento*/
  IF TO_DATE(vr_dtpgto,'DDMMYYYY') <= TRUNC(SYSDATE) THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'AP';
     raise vr_erro_segmento_a;
  END IF; 
   
  /*Tipo da Moeda*/
  IF vr_tpmoeda <> 'BRL' THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'AQ';
     raise vr_erro_segmento_a;
  END IF;
 
  /*Valor do Pagamento/Débito*/
  IF TO_NUMBER(vr_vlrpgt) = 0 THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'AR';
     raise vr_erro_segmento_a;
  END IF;   
 
  /*Tipo Inscrição da Empresa*/
  IF vr_insc_emp not in ('1','2') THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'AT';
     raise vr_erro_segmento_a;
  END IF;
  /*Número Inscrição (CPF/CNPJ)*/
  -- Validação Básica
  gene0005.pc_valida_cpf_cnpj(TO_NUMBER(vr_nrcpfcgc),
                              vr_stsnrcal,
                              vr_inpessoa);
  IF NOT vr_stsnrcal THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'AT';
     raise vr_erro_segmento_a;
  END IF;
  -- Valida se o tipo de pessoa esta correto (1 - PF)
  IF vr_insc_emp = '1' AND vr_inpessoa <> 1 THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'AT';
     raise vr_erro_segmento_a;
  END IF;
  -- Valida se o tipo de pessoa esta correto (2 PJ)
  IF vr_insc_emp = '2' AND vr_inpessoa <> 2 THEN
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'AT';
     raise vr_erro_segmento_a;
  END IF;  
  
  /*Finalidade da Operação/TED*/
  OPEN cr_crapfin (pr_cdcooper, TO_NUMBER(vr_finalida));  
  FETCH cr_crapfin into rr_crapfin;
  IF cr_crapfin%NOTFOUND THEN
     CLOSE cr_crapfin; 
     pr_tab_dados_segmento_a(vr_index).tperrocnab := 'YD';
     raise vr_erro_segmento_a;
  END IF;     
  CLOSE cr_crapfin;      

  /*Histórico da Transação*/
  IF vr_finalida = '99999'  THEN
    IF ltrim(vr_histra) IS NULL THEN
       pr_tab_dados_segmento_a(vr_index).tperrocnab := 'YE';
       raise vr_erro_segmento_a;
    END IF;
  END IF;
  -- Não encontrou nenhuma inconsistência
  pr_tab_dados_segmento_a(vr_index).tperrocnab := 'BD';
        
EXCEPTION
  WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic;  
  WHEN vr_erro_segmento_a THEN
      NULL;
  WHEN OTHERS THEN
      pr_dscritic:= 'Erro na proc pc_val_segment_a_cnab240_ted. Cta: '||vr_nrdconta||' Dtpgt: '||vr_dtpgto||' Vlr'||vr_vlrpgt||' - '||sqlerrm;
 
END pc_val_segment_a_cnab240_ted;


                             
procedure pc_verifica_layout_ted (pr_cdcooper   in craphis.cdcooper%type
                             ,pr_nrdconta   in crapass.nrdconta%type
                             ,pr_nmarquiv   in varchar2
                             ,pr_retxml in out nocopy XMLType
                             ,pr_cdcritic  out pls_integer
                             ,pr_dscritic  out varchar2) is

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_verifica_layout_ted
  --  Sistema  : Ayllos Web
  --  Autor    : Jose Dill
  --  Data     : Maio/2019                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Validar as informações do layout do arquivo (header, trailer, segmento a),
  --             gravar as informações em tabela e realizar o agendamento das Teds/Transferencias. 
  --             
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  CURSOR cr_errocnab (pr_tperrocnab  tbtransf_erros_cnab.tperrocnab%type) IS
  SELECT tec.dserrocnab 
  FROM TBTRANSF_ERROS_CNAB tec
  WHERE tec.tperrocnab =pr_tperrocnab;
  rr_errocnab cr_errocnab%rowtype;
  
  CURSOR cr_crapban (pr_cdbanco crapban.cdbccxlt%type) IS
  SELECT ban.nrispbif
  FROM crapban ban
  WHERE ban.cdbccxlt = pr_cdbanco;
  rr_crapban cr_crapban%rowtype;
  
  CURSOR cr_arqrem (pr_cdcooper tbtransf_arquivo_ted.cdcooper%type
                   ,pr_nrdconta tbtransf_arquivo_ted.nrdconta%type
                   ,pr_nrseqarq tbtransf_arquivo_ted.nrseq_arquivo%type) IS
  SELECT 
    ltrim(substr(tatl.dslinha_arq,1,230) || tatl.dsret_cnab||substr(tatl.dslinha_arq,233,8)) linharem
  FROM tbtransf_arquivo_ted tat
  , tbtransf_arquivo_ted_linhas tatl
  WHERE tatl.nrseq_arq_ted = tat.nrseq_arq_ted
  AND   tat.nrdconta = pr_nrdconta
  AND   tat.cdcooper = pr_cdcooper
  AND   tat.nrseq_arquivo = pr_nrseqarq
  AND   ltrim(tatl.cdbco_comp) IS NOT NULL  
  ORDER BY tatl.nrseq_arq_ted_linha ASC;
  rr_arqrem  cr_arqrem%rowtype; 
  
  -- Seleciona os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
  SELECT crapcop.cdagectl
  FROM crapcop crapcop
  WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  -- Declaracao de variaveis
  vr_contador  number := 0;
  vr_exc_saida exception;
  vr_cdcritic  pls_integer;
  vr_destexto  varchar2(100);
  vr_nmdireto  varchar2(100);
  vr_linhaxml  varchar2(100);
  vr_linhaarq  varchar2(4000);
  vr_dscritic  varchar2(1000);
  vr_utlfile   utl_file.file_type;
  vr_nrdconta  crapass.nrdconta%type;
  vr_index     integer :=0;
  
  /* Variaveis dos arquivos */
  vr_tipo_registro varchar2(01);
  vr_cod_febraban varchar2(02);
  
  vr_existe_header_arq  boolean := false;
  vr_existe_header_lot  boolean := false;
  vr_existe_trailer_arq boolean := false;
  vr_existe_trailer_lot boolean := false;
  vr_cdtiptra           integer;
  vr_cdhisdeb           integer;
  vr_dtmvtopg           date;
  vr_vllanmto           number(15,2);
  vr_cddbanco           integer; 
  vr_cdageban           integer;
  vr_nrctadst           integer;
  vr_idlancto           craplau.idlancto%TYPE;
  vr_dstrans1           varchar2(500) := NULL;
  vr_msgofatr           varchar2(500);
  vr_cdempcon           number;
  vr_cdsegmto           varchar2(500);
  vr_cdfinali           number;
  vr_gravou_ted         boolean := False;  
  vr_dsretorno          varchar2(500);
  vr_qtde_carac         integer;
  vr_qtlinhas           integer := 0;
  vr_qtlinhas_total     integer := 0;
  
  vr_linha_header_arq   VARCHAR2(240);
  vr_linha_header_lot   VARCHAR2(240);
  vr_linha_trailer_arq  VARCHAR2(240);
  vr_linha_trailer_lot  VARCHAR2(240);  
  vr_arq_ted_rowid      ROWID;
  
  vr_nmtitula VARCHAR2(500);
  vr_intipcta crapcti.intipcta%TYPE;        
  vr_inpessoa crapcti.inpessoa%TYPE;
  vr_nrcpffav crapcti.nrcpfcgc%TYPE;
  vr_cdispbif crapban.nrispbif%TYPE;
  vr_nrctatrf NUMBER(13);
  vr_dscpfcgc VARCHAR2(500);
  vr_nmdcampo VARCHAR2(500);                  
  vr_msgaviso VARCHAR2(1000) := NULL;
  vr_tab_erro gene0001.typ_tab_erro; --> Tabela com erros
  vr_flgctafa BOOLEAN;
  vr_nmtitul2 VARCHAR2(500);
  
   
  vr_arq_remessa        CLOB;
  vr_texto_arq_remessa  VARCHAR2(32767);
  
  --pl table com os dados do relatorio
  vr_tab_err_headtrailer pgta0001.typ_tab_typ_erros_headtrailer;
  vr_tab_dados_segmento_a pgta0001.typ_tab_dados_segmento_a;


PROCEDURE pc_grava_favorito_ted IS
 /* Objetivo: Criar o registro de favorito para a transferência ou TED */
   
 PRAGMA AUTONOMOUS_TRANSACTION; 
 
BEGIN
  -- Executa rotina para gravar favorito
  IF vr_cdtiptra = 4 THEN
      /* TED */
      -- Busca ISPB
      OPEN cr_crapban (vr_cddbanco);
      FETCH cr_crapban INTO rr_crapban;
      IF cr_crapban%FOUND THEN
        vr_cdispbif := rr_crapban.nrispbif;
      ELSE
        --gerar erro
        null;
      END IF;
      CLOSE cr_crapban;
            
      -- Chamar a rotina valida-inclusao-conta-transferencia convertida da Bo15
      cada0002.pc_val_inclui_conta_transf(pr_cdcooper => pr_cdcooper
                                         ,pr_cdagenci => 90
                                         ,pr_nrdcaixa => 900
                                         ,pr_cdoperad => '1'
                                         ,pr_nmdatela => 'PGTA0001'
                                         ,pr_idorigem => 1 
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_idseqttl => 1 
                                         ,pr_dtmvtolt => TRUNC(SYSDATE) --pr_dtmvtolt ???
                                         ,pr_flgerlog => 1 /*TRUE*/
                                         ,pr_cddbanco => vr_cddbanco 
                                         ,pr_cdispbif => vr_cdispbif
                                         ,pr_cdageban => vr_cdageban
                                         ,pr_nrctatrf => vr_nrctatrf
                                         ,pr_intipdif => 2
                                         ,pr_intipcta => vr_intipcta
                                         ,pr_insitcta => 2
                                         ,pr_inpessoa => vr_inpessoa
                                         ,pr_nrcpfcgc => vr_nrcpffav
                                         ,pr_flvldinc => 1
                                         ,pr_rowidcti => NULL
                                         ,pr_nmtitula => vr_nmtitula
                                         ,pr_dscpfcgc => vr_dscpfcgc
                                         ,pr_nmdcampo => vr_nmdcampo
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
            
      /* Desconsiderar critica de Favorecido ja cadastrado */
      IF (nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL) AND nvl(vr_cdcritic, 0) <> 979 THEN
          IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
              pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          ELSE
              pr_dscritic := vr_dscritic;
          END IF;
      END IF;
            
      /* Não chamar a inclusao se favorecido jah cadastrado */
      IF nvl(vr_cdcritic, 0) <> 979 THEN
          -- Se tudo corer bem com a validação:
          -- Chamar a rotina para inclusão do favorecido
          cada0002.pc_inclui_conta_transf(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                                         ,pr_cdagenci => 90          --> Codigo da agencia
                                         ,pr_nrdcaixa => 900         --> Numero do caixa
                                         ,pr_cdoperad => '1'         --> Cod. do operador
                                         ,pr_nmdatela => 'PGTA0001'  --> Nome da tela
                                         ,pr_idorigem => 1           --> Identificador de origem 
                                         ,pr_nrdconta => pr_nrdconta --> Numero da conta
                                         ,pr_idseqttl => 1           --> Seq. do titular
                                         ,pr_dtmvtolt => TRUNC(SYSDATE) --> Data do movimento ???
                                         ,pr_nrcpfope => 0              --> CPF operador juridico ???
                                         ,pr_flgerlog => 1 /*TRUE*/ --> flg geracao log
                                         ,pr_cddbanco => vr_cddbanco --> Codigo do banco destino
                                         ,pr_cdageban => vr_cdageban --> Agencia destino
                                         ,pr_nrctatrf => vr_nrctatrf --> Nr. conta transf
                                         ,pr_nmtitula => vr_nmtitula --> Nome titular
                                         ,pr_nrcpfcgc => vr_nrcpffav --> CPF titulat 
                                         ,pr_inpessoa => vr_inpessoa --> Tipo pessoa
                                         ,pr_intipcta => vr_intipcta --> Tipo de conta
                                         ,pr_intipdif => 2           --> tipo de inst. financeira da conta (Outras)
                                         ,pr_rowidcti => NULL        --> Recid da cta transf
                                         ,pr_cdispbif => vr_cdispbif --> Nr do ISPB do banco
                                          -- OUT
                                         ,pr_msgaviso => vr_msgaviso --> Mensagem de aviso
                                         ,pr_des_erro => vr_des_erro --> Indicador se retornou com erro (OK ou NOK)
                                         ,pr_cdcritic => vr_cdcritic --> Codigo da critica
                                         ,pr_dscritic => pr_dscritic); --> Descricao da critica
                
          IF vr_des_erro <> 'OK' THEN
              IF TRIM(pr_dscritic) IS NULL THEN
                  vr_dscritic := 'Erro na inclusao da conta favorita.'||pr_dscritic;
                  RAISE vr_exc_saida;
              END IF;
          END IF;
                
      END IF;
            
  ELSE
            
      /* Validar a conta de destino da transferencia */
      inet0001.pc_valida_conta_destino(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                      ,pr_cdagenci => 90          --Agencia do Associado
                                      ,pr_nrdcaixa => 900         --Numero caixa
                                      ,pr_cdoperad => '1'         --Codigo Operador
                                      ,pr_nrdconta => pr_nrdconta --Numero da conta
                                      ,pr_idseqttl => 1           --Identificador Sequencial titulo
                                      ,pr_cdagectl => vr_cdageban --Codigo Agencia
                                      ,pr_nrctatrf => vr_nrctatrf --Numero Conta Transferencia
                                      ,pr_dtmvtolt => TRUNC(SYSDATE) --Data Movimento ???
                                      ,pr_cdtiptra => vr_cdtiptra --Tipo de Transferencia
                                      ,pr_flgctafa => vr_flgctafa --Indicador conta cadastrada ???
                                      ,pr_nmtitula => vr_nmtitula --Nome titular
                                      ,pr_nmtitul2 => vr_nmtitul2 --Nome segundo titular???
                                      ,pr_cddbanco => vr_cddbanco --Codigo banco
                                      ,pr_dscritic => vr_des_erro --Retorno OK/NOK
                                      ,pr_tab_erro => vr_tab_erro); --Tabela de retorno de erro
            
      IF vr_des_erro <> 'OK' THEN
          IF vr_tab_erro.exists(vr_tab_erro.first) THEN
              vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          ELSE
              vr_dscritic := 'Erro na validacao da conta destino.';
          END IF;
          -- se retornou critica deve abortar processo
          RAISE vr_exc_saida;
      END IF;
            
      IF NOT vr_flgctafa THEN
          cada0002.pc_inclui_conta_transf(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                                         ,pr_cdagenci => 90          --> Codigo da agencia
                                         ,pr_nrdcaixa => 900         --> Numero do caixa
                                         ,pr_cdoperad => '1'         --> Cod. do operador
                                         ,pr_nmdatela => 'PGTA0001'  --> Nome da tela
                                         ,pr_idorigem => 1           --> Identificador de origem
                                         ,pr_nrdconta => pr_nrdconta --> Numero da conta
                                         ,pr_idseqttl => 1           --> Seq. do titular 
                                         ,pr_dtmvtolt => TRUNC(SYSDATE) --> Data do movimento ???
                                         ,pr_nrcpfope => 0              --> CPF operador juridico
                                         ,pr_flgerlog => 1 /*TRUE*/     --> flg geracao log
                                         ,pr_cddbanco => vr_cddbanco --> Codigo do banco destino
                                         ,pr_cdageban => vr_cdageban --> Agencia destino
                                         ,pr_nrctatrf => vr_nrctatrf --> Nr. conta transf
                                         ,pr_nmtitula => NULL        --> Nome titular
                                         ,pr_nrcpfcgc => 0           --> CPF titulat
                                         ,pr_inpessoa => 0           --> Tipo pessoa
                                         ,pr_intipcta => 1           --> Tipo de conta
                                         ,pr_intipdif => 1           --> tipo de inst. financeira da conta
                                         ,pr_rowidcti => NULL        --> Recid da cta transf
                                         ,pr_cdispbif => vr_cdispbif --> Nr do ISPB do banco
                                          -- OUT
                                         ,pr_msgaviso => vr_msgaviso --> Mensagem de aviso
                                         ,pr_des_erro => vr_des_erro --> Indicador se retornou com erro (OK ou NOK)
                                         ,pr_cdcritic => vr_cdcritic --> Codigo da critica
                                         ,pr_dscritic => pr_dscritic); --> Descricao da critica
                
          IF vr_des_erro <> 'OK' THEN
              IF TRIM(pr_dscritic) IS NULL THEN
                  vr_dscritic := 'Erro na inclusao da conta favorita.'||pr_dscritic;
                  RAISE vr_exc_saida;
              END IF;
          END IF;
      END IF;
  END IF;
  --
  COMMIT;
  --
  EXCEPTION 
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN others THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado na rotina PGTA0001.pc_grava_favorito_ted: '||sqlerrm;

END pc_grava_favorito_ted;
  
BEGIN

  -- Busca do diretorio base da cooperativa
  vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                      ,pr_cdcooper => pr_cdcooper);

  -- Se o arquivo estiver aberto
  IF  utl_file.IS_OPEN(vr_utlfile) THEN
    -- Fechar o arquivo
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfile); --> Handle do arquivo aberto;
  END  IF; 
  -- Abre arquivo 
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto||'/arq',
                           pr_nmarquiv => pr_nmarquiv,
                           pr_tipabert => 'R',
                           pr_utlfileh => vr_utlfile,
                           pr_des_erro => vr_dscritic);
  
  --Se ocorreu erro
  IF vr_dscritic is not null THEN
    /* Tratamento de erro */
    pr_dscritic:= vr_dscritic;
    raise vr_exc_saida;
  END IF;                            
  --
  vr_tab_err_headtrailer.DELETE;
  vr_tab_dados_segmento_a.DELETE;
  --
  -- Verificar a qtde de linhas do arquivo para tratar o header e o trailer 
  BEGIN 
    LOOP  
      -- Varre linhas do arquivo
      gene0001.pc_le_linha_arquivo(vr_utlfile,vr_linhaarq);
      --
      vr_qtlinhas_total :=  vr_qtlinhas_total + 1;
      IF vr_qtlinhas_total > 2000 THEN
         vr_dscritic:= 'Arquivo com mais de 2000 linhas!';
         raise vr_exc_saida;
      END IF;
    END LOOP;  
    EXCEPTION
      WHEN no_data_found THEN
       -- Acabou a leitura do arquivo
           -- Se o arquivo estiver aberto
      IF  utl_file.IS_OPEN(vr_utlfile) THEN
        -- Fechar o arquivo
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfile); --> Handle do arquivo aberto;
      END  IF;
  END;
  -- Abre arquivo para execução das validações
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto||'/arq',
                           pr_nmarquiv => pr_nmarquiv,
                           pr_tipabert => 'R',
                           pr_utlfileh => vr_utlfile,
                           pr_des_erro => vr_dscritic);
  
  --Se ocorreu erro
  IF vr_dscritic is not null THEN
    /* Tratamento de erro */
    pr_dscritic:= vr_dscritic;
    raise vr_exc_saida;
  END IF;                            
  --           
  --
  BEGIN
    BEGIN 
      LOOP  
        -- Varre linhas do arquivo
        gene0001.pc_le_linha_arquivo(vr_utlfile,vr_linhaarq);
        --
        vr_qtde_carac := length(ltrim(vr_linhaarq));
        IF vr_qtde_carac > 241 THEN
           vr_dscritic:= 'Arquivo com linha superior a 240 caracteres!';
           raise vr_exc_saida;
        END IF; 
        IF vr_qtde_carac < 240 THEN
           vr_dscritic:= 'Arquivo nao processado - Tamanho de linha invalida (CNAB 240)';
           raise vr_exc_saida;
        END IF;         
        vr_qtlinhas := vr_qtlinhas + 1;
        IF vr_qtlinhas = 1 THEN
          -- Gravar o registro de cabeçalho na tabela de controle  
          BEGIN
            /*Número sequencial do arquivo*/
            vr_nrseq_arq_ted := substr(vr_linhaarq,158,6);
            /*Busca ultima sequencia gravada antes de incluir o registro na tabela de controle*/
            SELECT NVL(MAX(tat.nrseq_arquivo),0) INTO vr_nr_seq_gravada
            FROM tbtransf_arquivo_ted tat
            WHERE tat.cdcooper = pr_cdcooper
            AND   tat.nrdconta = pr_nrdconta;            
            --
            INSERT INTO tbtransf_arquivo_ted (nrseq_arq_ted,   
                                             nmarquivo, 
                                             nrseq_arquivo,
                                             nrdconta,    
                                             cdcooper, 
                                             dtgeracao, 
                                             dsarquivo,
                                             idtipoarq)
                                     values (null , 
                                             vr_nmarvalidar,             
                                             vr_nrseq_arq_ted,
                                             pr_nrdconta, 
                                             pr_cdcooper,   
                                             sysdate, 
                                             vr_clob_ted,
                                             1 /*Primeiro arquivo de retorno*/)
                                     RETURNING nrseq_arq_ted, rowid
                                     INTO vr_id_nrseq_arq_ted, vr_arq_ted_rowid;     
           --
          EXCEPTION
           WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir dados na tbtransf_arquivo_ted: '||sqlerrm;
              RAISE vr_exc_saida;
          END;   
        END IF;       

        -- Identificar o tipo de registro
        vr_tipo_registro:= substr(vr_linhaarq,8,1);
        --
        /* Realiza validações das linhas iniciais e finais (header e trailer)quando é segmento A */
        IF vr_tipo_registro = '3' THEN
           IF vr_qtlinhas in (1,2) --Tipo de registro Header Arquivo e Lote
           OR vr_qtlinhas = (vr_qtlinhas_total  -1) -- Tipo de registro Trailer Lote
           OR vr_qtlinhas =  vr_qtlinhas_total      -- Tipo de registro Trailer Arquivo
           THEN
             vr_index := vr_tab_err_headtrailer.COUNT() + 1;
             IF vr_qtlinhas = 1 THEN
                vr_tab_err_headtrailer(vr_index).tporigem := 'Header Arq';
             ELSIF  vr_qtlinhas = 2 THEN
                 vr_tab_err_headtrailer(vr_index).tporigem := 'Header Lote';
             ELSIF vr_qtlinhas = (vr_qtlinhas_total - 1) THEN
                 vr_tab_err_headtrailer(vr_index).tporigem := 'Trailer Lote';               
             ELSIF vr_qtlinhas = vr_qtlinhas_total THEN
                 vr_tab_err_headtrailer(vr_index).tporigem := 'Trailer Arq';               
             END IF;
             vr_tab_err_headtrailer(vr_index).tperrocnab := 'HJ';
             vr_tab_err_headtrailer(vr_index).dscampo := vr_tipo_registro;  
             --
             CONTINUE;
           END IF;
        END IF;  
        /* Realiza validações das linhas iniciais e finais (header e trailer) */
        IF vr_qtlinhas in (1,2) --Tipo de registro Header Arquivo e Lote
        OR vr_qtlinhas = (vr_qtlinhas_total  -1) -- Tipo de registro Trailer Lote
        OR vr_qtlinhas =  vr_qtlinhas_total      -- Tipo de registro Trailer Arquivo
        THEN
          
          IF vr_qtlinhas = 1 and vr_tipo_registro <> '0' THEN
            vr_index := vr_tab_err_headtrailer.COUNT() + 1; 
            vr_tab_err_headtrailer(vr_index).tporigem := 'Header Arq';
            vr_tab_err_headtrailer(vr_index).tperrocnab := 'HJ';
            vr_tab_err_headtrailer(vr_index).dscampo := vr_tipo_registro;  
            continue;            
          ELSIF  vr_qtlinhas = 2 and vr_tipo_registro <> '1' THEN
            vr_index := vr_tab_err_headtrailer.COUNT() + 1;
            vr_tab_err_headtrailer(vr_index).tporigem := 'Header Lote';
            vr_tab_err_headtrailer(vr_index).tperrocnab := 'HJ';
            vr_tab_err_headtrailer(vr_index).dscampo := vr_tipo_registro;  
            continue;            
          ELSIF vr_qtlinhas = (vr_qtlinhas_total - 1) and vr_tipo_registro <> '5' THEN
            vr_index := vr_tab_err_headtrailer.COUNT() + 1;
            vr_tab_err_headtrailer(vr_index).tporigem := 'Trailer Lote';               
            vr_tab_err_headtrailer(vr_index).tperrocnab := 'HJ';
            vr_tab_err_headtrailer(vr_index).dscampo := vr_tipo_registro;  
            continue;            
          ELSIF vr_qtlinhas = vr_qtlinhas_total and vr_tipo_registro <> '9' THEN
            vr_index := vr_tab_err_headtrailer.COUNT() + 1;
            vr_tab_err_headtrailer(vr_index).tporigem := 'Trailer Arq';  
            vr_tab_err_headtrailer(vr_index).tperrocnab := 'HJ';
            vr_tab_err_headtrailer(vr_index).dscampo := vr_tipo_registro;  
            continue;            
          END IF;
        END IF;         
        
        IF vr_tipo_registro = '0' and vr_qtlinhas = 1 THEN
           -- HEADER DO ARQUIVO
           vr_existe_header_arq:= true;
           --
           pc_val_headerarq_cnab240_ted (pr_linha_arquivo         => vr_linhaarq
                                , pr_nrdconta                  => pr_nrdconta
                                , pr_cdcooper                  => pr_cdcooper
                                , pr_tab_erros_headtrailer => vr_tab_err_headtrailer
                                , pr_cdcritic              => vr_cdcritic
                                , pr_dscritic              => vr_dscritic);
           -- 
           --Se ocorreu erro
           IF vr_dscritic is not null THEN
              /* Tratamento de erro */
              raise vr_exc_saida;
           END IF;  
           --
           vr_linha_header_arq :=  substr(vr_linhaarq,1,240);                          
           --  
        ELSIF vr_tipo_registro = '1' and vr_qtlinhas = 2 THEN
           -- HEADER DO LOTE
           vr_existe_header_lot:= true;
           --
           pc_val_headerlot_cnab240_ted (pr_linha_arquivo  => vr_linhaarq
                                , pr_nrdconta              => pr_nrdconta
                                , pr_cdcooper              => pr_cdcooper
                                , pr_tab_erros_headtrailer => vr_tab_err_headtrailer
                                , pr_cdcritic              => vr_cdcritic
                                , pr_dscritic              => vr_dscritic);
           -- 
           --Se ocorreu erro
           IF vr_dscritic is not null THEN
              /* Tratamento de erro */
              raise vr_exc_saida;
           END IF;    
           --
           vr_linha_header_lot :=  substr(vr_linhaarq,1,240);                         
           --                                          
        ELSIF vr_tipo_registro = '3' THEN
           -- SEGMENTO A
           pc_val_segment_a_cnab240_ted (pr_linha_arquivo  => vr_linhaarq
                                , pr_nrdconta              => pr_nrdconta
                                , pr_cdcooper              => pr_cdcooper
                                , pr_tab_dados_segmento_a  => vr_tab_dados_segmento_a
                                , pr_cdcritic              => vr_cdcritic
                                , pr_dscritic              => vr_dscritic); 
           --Se ocorreu erro
           IF vr_dscritic is not null THEN
              /* Tratamento de erro */
              raise vr_exc_saida;
           END IF;                             
           --                                  
        ELSIF vr_tipo_registro = '5' and vr_qtlinhas = (vr_qtlinhas_total  -1) THEN
           -- TRAILER DO LOTE
           vr_existe_trailer_lot:= true;
           --
           pc_val_trailerlot_cnab240_ted (pr_linha_arquivo  => vr_linhaarq
                                , pr_nrdconta              => pr_nrdconta
                                , pr_cdcooper              => pr_cdcooper
                                , pr_tab_erros_headtrailer => vr_tab_err_headtrailer
                                , pr_cdcritic              => vr_cdcritic
                                , pr_dscritic              => vr_dscritic);
           --Se ocorreu erro
           IF vr_dscritic is not null THEN
              /* Tratamento de erro */
              raise vr_exc_saida;
           END IF;  
           --
           vr_linha_trailer_lot :=  substr(vr_linhaarq,1,240);                            
           --                                       
        ELSIF vr_tipo_registro = '9' and vr_qtlinhas = (vr_qtlinhas_total) THEN
           -- TRAILER DO ARQUIVO
           vr_existe_trailer_arq:= true;
           --
           pc_val_trailerarq_cnab240_ted (pr_linha_arquivo  => vr_linhaarq
                                , pr_nrdconta              => pr_nrdconta
                                , pr_cdcooper              => pr_cdcooper
                                , pr_tab_erros_headtrailer => vr_tab_err_headtrailer
                                , pr_cdcritic              => vr_cdcritic
                                , pr_dscritic              => vr_dscritic); 
           --Se ocorreu erro
           IF vr_dscritic is not null THEN
              /* Tratamento de erro */
              raise vr_exc_saida;
           END IF;  
           --
           vr_linha_trailer_arq :=  substr(vr_linhaarq,1,240);                           
           --                                        
        ELSE
          /* Validar tipo de registro diferente de 0,1,3,5 e 9 (exceção)
              Gerar a critica HJ.
          */
          vr_index := vr_tab_err_headtrailer.COUNT() + 1;
          IF vr_qtlinhas = 1 THEN
             vr_tab_err_headtrailer(vr_index).tporigem := 'Header Arq';
          ELSIF vr_qtlinhas = 2 THEN
             vr_tab_err_headtrailer(vr_index).tporigem := 'Header Lote';
          ELSIF vr_qtlinhas = (vr_qtlinhas_total-1) THEN
             vr_tab_err_headtrailer(vr_index).tporigem := 'Trailer Lote';
          ELSIF vr_qtlinhas = vr_qtlinhas_total THEN
             vr_tab_err_headtrailer(vr_index).tporigem := 'Trailer Arq';
          ELSE
             vr_tab_err_headtrailer(vr_index).tporigem := 'Segmento A';     
          END IF;     
          vr_tab_err_headtrailer(vr_index).tperrocnab := 'HJ';
          vr_tab_err_headtrailer(vr_index).dscampo := vr_tipo_registro;           
        END IF;
                        

      END LOOP;
    EXCEPTION
      WHEN no_data_found THEN
         -- Acabou a leitura do arquivo
         NULL;
    END;    
    
    /*Verificar se foram geradas criticas no Header e Trailer. Se foram, gera o XML com as criticas */   
    IF vr_tab_err_headtrailer.COUNT() > 0 THEN
       --
       ROLLBACK; --Para as informacoes incluídas para o header e o trailer
       --
       -- Criar cabeçalho do XML
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
       gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Root',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Dados',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);
     
       --
       vr_contador:= 0;
       FOR vr_idx IN vr_tab_err_headtrailer.FIRST..vr_tab_err_headtrailer.LAST LOOP
         --Gravar xml com as criticas geradas no header e trailer
          
         OPEN cr_errocnab (vr_tab_err_headtrailer(vr_idx).tperrocnab);
         FETCH cr_errocnab INTO rr_errocnab;
         CLOSE cr_errocnab;
         vr_dsretorno:= vr_tab_err_headtrailer(vr_idx).tporigem ||' - '||rr_errocnab.dserrocnab||' - '||vr_tab_err_headtrailer(vr_idx).dscampo;
         --
         -- Insere as tags
         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Dados',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'criticas',
                                 pr_tag_cont => NULL,
                                 pr_des_erro => vr_dscritic);
           
         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'criticas',
                                 pr_posicao  => vr_contador,
                                 pr_tag_nova => 'dscritic',
                                 pr_tag_cont => vr_dsretorno,
                                 pr_des_erro => vr_dscritic);
                                       
         vr_contador:= vr_contador + 1;                   
                            
       END LOOP;  
       
    END IF;
    --  
    /* Selecionar agência da cooperativa de origem */
    OPEN cr_crapcop (pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    CLOSE cr_crapcop;
    --            
    IF vr_tab_dados_segmento_a.COUNT() > 0 AND  vr_tab_err_headtrailer.COUNT() = 0 THEN
       --Processa o Segmento A, caso nao haja criticas no HEADER/TRAILERs
       FOR vr_idx IN vr_tab_dados_segmento_a.FIRST..vr_tab_dados_segmento_a.LAST LOOP
         -- Chamar a rotina para agendamento das transferências
         IF vr_tab_dados_segmento_a(vr_idx).tperrocnab = 'BD'  THEN
            -- BD - Registro do arquivo integro
            IF vr_tab_dados_segmento_a(vr_idx).cdbco_fav = '085'  THEN
               -- Agendamento de transferência
               IF TO_NUMBER(vr_tab_dados_segmento_a(vr_idx).cdage_conta) <> rw_crapcop.cdagectl                  THEN
                  -- Transferencia intercooperativa
                  vr_cdhisdeb:= 1009;
                  vr_cdtiptra:= 5;
               ELSE
                  -- Transferencia intracooperativa
                  vr_cdhisdeb:= 537;
                  vr_cdtiptra:= 1;
               END IF; 
            ELSE
              -- Agendamento de Ted
              vr_cdtiptra:= 4;
              vr_cdhisdeb:= 555;
            END IF;
            --
            vr_dtmvtopg:=  TO_DATE(vr_tab_dados_segmento_a(vr_idx).dtprv_pgto,'DDMMYYYY');
            vr_vllanmto:= TO_NUMBER(vr_tab_dados_segmento_a(vr_idx).vlrpgto,'999999999999999') / 100;
            vr_cddbanco:= TO_NUMBER(vr_tab_dados_segmento_a(vr_idx).cdbco_fav);
            vr_cdageban:= TO_NUMBER(vr_tab_dados_segmento_a(vr_idx).cdage_conta);
            vr_nrctadst:= TO_NUMBER(vr_tab_dados_segmento_a(vr_idx).nrdconta);
            vr_cdfinali:= TO_NUMBER(vr_tab_dados_segmento_a(vr_idx).dsfinalidade);
            /* Dados favorecido TED */
            vr_nmtitula := vr_tab_dados_segmento_a(vr_idx).nmfavorecido; --pr_nmtitula;
            vr_intipcta := vr_tab_dados_segmento_a(vr_idx).dstipo_mov;   --pr_intipcta;
            vr_inpessoa := vr_tab_dados_segmento_a(vr_idx).dsins_fav;    --pr_inpessoa;
            vr_nrcpffav := vr_tab_dados_segmento_a(vr_idx).nr_cpf_cnpj_fav; --pr_nrcpfcgc;
            vr_nrctatrf := TO_NUMBER(vr_tab_dados_segmento_a(vr_idx).nrdconta);
            --
            vr_idlancto:= NULL;
            vr_dscritic:= NULL;
            --
            -- Executa rotina para gravar favorito
            pc_grava_favorito_ted;
            --
            PAGA0002.pc_cadastrar_agendamento
                               ( pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                                ,pr_cdagenci => 90           --> Codigo da agencia 
                                ,pr_nrdcaixa => 900          --> Numero do caixa 
                                ,pr_cdoperad => '1'          --> Codigo do operador
                                ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
                                ,pr_idseqttl => 1            --> Sequencial do titular
                                ,pr_dtmvtolt => TRUNC(SYSDATE) --> Data do movimento 
                                ,pr_cdorigem => 1            --> Origem 
                                ,pr_dsorigem => 'AIMARO'     --> Descrição de origem do registro 
                                ,pr_nmprogra => 'PGTA0001'   --> Nome do programa que chamou
                                ,pr_cdtiptra => vr_cdtiptra  --> Tipo de transação
                                ,pr_idtpdpag => 0            --> Indicador de tipo de agendamento
                                ,pr_dscedent => ' '          --> Descrição do cedente
                                ,pr_dscodbar => ' '          --> Descrição codbarras
                                ,pr_lindigi1 => 0            --> 1° parte da linha digitavel
                                ,pr_lindigi2 => 0            --> 2° parte da linha digitavel
                                ,pr_lindigi3 => 0            --> 3° parte da linha digitavel
                                ,pr_lindigi4 => 0            --> 4° parte da linha digitavel
                                ,pr_lindigi5 => 0            --> 5° parte da linha digitavel
                                ,pr_cdhistor => vr_cdhisdeb  --> Codigo do historico
                                ,pr_dtmvtopg => vr_dtmvtopg  --> Data de pagamento
                                ,pr_vllanaut => vr_vllanmto  --> Valor do lancamento automatico
                                ,pr_dtvencto => NULL         --> Data de vencimento
                                ,pr_cddbanco => vr_cddbanco  --> Codigo do banco
                                ,pr_cdageban => vr_cdageban  --> Codigo de agencia bancaria
                                ,pr_nrctadst => vr_nrctadst  --> Numero da conta destino
                                ,pr_cdcoptfn => null         --> Codigo que identifica a cooperativa do cash.
                                ,pr_cdagetfn => null        --> Numero do pac do cash.
                                ,pr_nrterfin => null        --> Numero do terminal financeiro.

                                ,pr_nrcpfope => 0            --> Numero do cpf do operador juridico 
                                ,pr_idtitdda => 0            --> Contem o identificador do titulo dda.
                                ,pr_cdtrapen => 0            --> Codigo da Transacao Pendente
                                ,pr_flmobile => 0            --> Indicador Mobile 
                                ,pr_idtipcar => 0            --> Indicador Tipo Cartão Utilizado
                                ,pr_nrcartao => 0            --> Nr Cartao

                                ,pr_cdfinali => vr_cdfinali  --> Codigo de finalidade
                                ,pr_dstransf => ''           --> Descricao da transferencia 
                                ,pr_dshistor => ''     --> Descricao da finalidade 
                                ,pr_iptransa => null   --> IP da transacao no IBank/mobile
                                ,pr_cdctrlcs => null         
                                ,pr_iddispos => null   --> Identificador do dispositivo movel 
                                /* parametros de saida */
                                ,pr_idlancto => vr_idlancto
                                ,pr_dstransa => vr_dstrans1  --> Descrição de transação
                                ,pr_msgofatr => vr_msgofatr
                                ,pr_cdempcon => vr_cdempcon
                                ,pr_cdsegmto => vr_cdsegmto
                                ,pr_dscritic => vr_dscritic);--> Descricao critica  
            
           /* Verifica se o agendamento retornou alguma critica e neste caso faz o devido tratamento e muda a situação
              do agendamento de BD para a situação correta. */                     
           IF vr_dscritic IS NOT NULL THEN 
              IF   vr_dscritic = '1431 - Ja existe TED de mesmo valor e favorecido. Consulte seus agendamentos ou tente novamente em 10 min.(1)' THEN
                 vr_tab_dados_segmento_a(vr_idx).tperrocnab:= 'YS';
              ELSE
                 vr_tab_dados_segmento_a(vr_idx).tperrocnab:= 'YK';
              END IF;
           END IF;   
         END IF;     
         
         -- Gravar os registros nas tabelas de controle  
         BEGIN
           --
           -- Grava as informações do agendamento na tabela de controle
           INSERT INTO tbtransf_arquivo_ted_linhas (nrseq_arq_ted_linha, 
                                                    nrseq_arq_ted, 
                                                    cdbco_comp, 
                                                    nrlote_ser, 
                                                    dstipo_reg, 
                                                    nrseq_reg, 
                                                    cdsegmento, 
                                                    dstipo_mov, 
                                                    cdbco_fav, 
                                                    cdage_conta, 
                                                    nrdconta, 
                                                    nmfavorecido, 
                                                    dtprv_pgto, 
                                                    dsmoeda, 
                                                    vlrpgto, 
                                                    dshistorico, 
                                                    dsins_fav, 
                                                    nr_cpf_cnpj_fav, 
                                                    dsfinalidade, 
                                                    dslinha_arq, 
                                                    dsret_cnab, 
                                                    dtgeracao,
                                                    idlancto,
                                                    dserro)
                                            values (null,
                                                    vr_id_nrseq_arq_ted,
                                                    vr_tab_dados_segmento_a(vr_idx).cdbco_comp,
                                                    vr_tab_dados_segmento_a(vr_idx).nrlote_ser,
                                                    vr_tab_dados_segmento_a(vr_idx).dstipo_reg,
                                                    vr_tab_dados_segmento_a(vr_idx).nrseq_reg,
                                                    vr_tab_dados_segmento_a(vr_idx).cdsegmento,
                                                    vr_tab_dados_segmento_a(vr_idx).dstipo_mov,
                                                    vr_tab_dados_segmento_a(vr_idx).cdbco_fav,
                                                    vr_tab_dados_segmento_a(vr_idx).cdage_conta,
                                                    vr_tab_dados_segmento_a(vr_idx).nrdconta,
                                                    vr_tab_dados_segmento_a(vr_idx).nmfavorecido,
                                                    vr_tab_dados_segmento_a(vr_idx).dtprv_pgto,
                                                    vr_tab_dados_segmento_a(vr_idx).dsmoeda,
                                                    vr_tab_dados_segmento_a(vr_idx).vlrpgto,
                                                    vr_tab_dados_segmento_a(vr_idx).dshistorico,
                                                    vr_tab_dados_segmento_a(vr_idx).dsins_fav,
                                                    vr_tab_dados_segmento_a(vr_idx).nr_cpf_cnpj_fav,
                                                    vr_tab_dados_segmento_a(vr_idx).dsfinalidade,
                                                    vr_tab_dados_segmento_a(vr_idx).dslinha_seg_a,
                                                    vr_tab_dados_segmento_a(vr_idx).tperrocnab,
                                                    sysdate,
                                                    vr_idlancto,
                                                    vr_dscritic);
           --
           vr_dscritic := null;
           vr_idlancto := null;                                         
           --        
         EXCEPTION
           WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir dados do segmento a na tabela tbtransf_arquivo_ted_linhas: Cta-'||vr_tab_dados_segmento_a(vr_idx).nrdconta||' Dt-'||vr_tab_dados_segmento_a(vr_idx).dtprv_pgto||' Vlr-'||vr_tab_dados_segmento_a(vr_idx).vlrpgto||sqlerrm;
              RAISE vr_exc_saida;
         END;      

       END LOOP;          
    END IF;
    --
    /* Gerar o arquivo de remessa com o retorno do segmento A */   
    IF vr_tab_dados_segmento_a.COUNT() > 0 AND  vr_tab_err_headtrailer.COUNT() = 0 THEN
      -- Inicializa CLOB XML
      dbms_lob.createtemporary(vr_arq_remessa, TRUE);
      dbms_lob.open(vr_arq_remessa, dbms_lob.lob_readwrite);
      --
      vr_linha_header_arq := substr(vr_linha_header_arq,1,142)||'2'||substr(vr_linha_header_arq,144,97);
      gene0002.pc_escreve_xml(vr_arq_remessa,vr_texto_arq_remessa,vr_linha_header_arq||chr(10));
      gene0002.pc_escreve_xml(vr_arq_remessa,vr_texto_arq_remessa,vr_linha_header_lot||chr(10));
      --
      -- Segmento A
      FOR rr_arqrem in cr_arqrem (pr_cdcooper, pr_nrdconta, vr_nrseq_arq_ted) LOOP
         --
         gene0002.pc_escreve_xml(vr_arq_remessa,vr_texto_arq_remessa,rr_arqrem.linharem||chr(10));
         --
      END LOOP;
      --
      gene0002.pc_escreve_xml(vr_arq_remessa,vr_texto_arq_remessa,vr_linha_trailer_lot||chr(10));
      gene0002.pc_escreve_xml(vr_arq_remessa,vr_texto_arq_remessa,vr_linha_trailer_arq,TRUE);
      --
      -- Atualizar o arquivo de remessa na tabela de controle com o status de retorno no arquivo
      UPDATE TBTRANSF_ARQUIVO_TED TAT
      SET tat.dsarquivo = vr_arq_remessa,
          tat.nmarquivo = REPLACE(REPLACE(tat.nmarquivo,'TXT','RET'),'REM','RET')
      WHERE       tat.ROWID = vr_arq_ted_rowid
      and tat.nrseq_arq_ted = vr_id_nrseq_arq_ted;
      --      
      -- Liberando a memoria alocada pro CLOB
      dbms_lob.close(vr_arq_remessa);
      dbms_lob.freetemporary(vr_arq_remessa);
    END IF;
    --      
    -- Se o arquivo estiver aberto
    IF  utl_file.IS_OPEN(vr_utlfile) THEN
      -- Fechar o arquivo
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfile); --> Handle do arquivo aberto;
    END  IF;
    COMMIT;
    --
  EXCEPTION
    -- Caso chegue ao fim do arquivo
    -- ou esteja vazio, fecha o mesmo
    WHEN no_data_found THEN
      gene0001.pc_fecha_arquivo(vr_utlfile);
    -- Acontecimento mais comum
    WHEN vr_exc_saida THEN
      raise vr_exc_saida;
    WHEN others THEN
      IF substr(sqlcode,2,5) = 29282 THEN
        vr_dscritic := 'Arquivo não encontrado ou com nomes incompatíveis: '||sqlerrm;
      ELSE
        vr_dscritic := 'Erro ao verificar layout: '||sqlerrm;
      END IF;
      RAISE vr_exc_saida;
  END;
 
  --Se ocorreu erro
  IF vr_dscritic is not null THEN
    raise vr_exc_saida;
  END IF;  

   
EXCEPTION

  WHEN vr_exc_saida THEN
      
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;

  WHEN others THEN

    pr_cdcritic := 0;
    pr_dscritic := 'Erro não tratado na rotina PGTA0001.pc_verifica_layout_ted: '||sqlerrm;
      
END pc_verifica_layout_ted;

procedure pc_importa_arquivo_ted   (pr_cdcooper   in crapatr.cdcooper%type  --> Número da cooperativa do cooperado
                                   ,pr_nrdconta   in crapass.nrdconta%type  --> Número da conta do cooperado
                                   ,pr_dsarquiv   IN VARCHAR2       --> Informações do arquivo
                                   ,pr_dsdireto   IN VARCHAR2       --> Informações do diretório do arquivo                                  
                                   ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_importa_arquivo_ted
  --  Sistema  : Ayllos Web
  --  Autor    : Jose Dill
  --  Data     : Maio/2019                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Realizar a importação do arquivo de TED/Transferência
  --          
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  CURSOR cr_infarq (pr_nrdconta tbtransf_arquivo_ted.nrdconta%type) IS 
  SELECT max(tat.nrseq_arquivo) nrseq_arq
  FROM TBTRANSF_ARQUIVO_TED tat
  WHERE tat.nrdconta = pr_nrdconta;
   
  -- Declaracao padrao de variaveis
  vr_dscritic  varchar2(1000);
  vr_exc_saida exception;
  vr_exc_layout exception;
  vr_cdcritic  pls_integer;
  vr_nrsequen  pls_integer;
  vr_nrdrowid  rowid;
  vr_dsupload  VARCHAR2(100);
  vr_dirarqui  VARCHAR2(100);
  vr_typ_said  VARCHAR2(50); -- Critica
  vr_des_erro  VARCHAR2(500); -- Critica
  vr_typ_saida VARCHAR2(100);
  vr_des_saida VARCHAR2(2000);
  vr_dscomand VARCHAR2(1000);
    
  vr_contador  number := 0;
  vr_flgarqui  boolean := false;

  -- Variáveis da proc
  vr_nrdcontavld  crapass.nrdconta%type;
  vr_nrsequencial  integer;
  vr_nrsequencial_atual  integer:= 0;
  
  -- Variaveis padrao                            
  vr_nmdatela  varchar2(100);                                  
  vr_nmeacao   varchar2(100);                                  
  vr_cdagenci  varchar2(100);                                  
  vr_nrdcaixa  varchar2(100);                                  
  vr_idorigem  varchar2(100);                                  
  vr_cdoperad  varchar2(100);  
  vr_cdcooper  integer;
  vr_caract_arq integer;
 
BEGIN
  -- Extrai cooperativa do xml
  gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                          ,pr_cdcooper => vr_cdcooper
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nmeacao  => vr_nmeacao
                          ,pr_cdagenci => vr_cdagenci
                          ,pr_nrdcaixa => vr_nrdcaixa
                          ,pr_idorigem => vr_idorigem
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => vr_dscritic);

  -- Aborta em caso de erro
  IF trim(vr_dscritic) is not null THEN
    NULL;
  END IF;
    
  /* Realizar a validação do arquivo */
 
  /* Nome do arquivo - Inicio */
  vr_nmarvalidar := '';
  vr_caract_arq  := length(pr_dsarquiv) - 22;
  vr_nmarvalidar := SUBSTR(pr_dsarquiv,vr_caract_arq,23);
  IF SUBSTR(vr_nmarvalidar,1,3) <> 'TED' THEN
     vr_dscritic := 'Nome do arquivo nao esta no padrao!';
     raise vr_exc_saida;
  END IF;  
  /* Nome do arquivo - Extensao */
  IF SUBSTR(vr_nmarvalidar,21,3) NOT IN ('TXT','REM') THEN
     vr_dscritic := 'Extensao do arquivo nao esta no padrao!'||SUBSTR(vr_nmarvalidar,21,3);
     raise vr_exc_saida;
  END IF;
  /* Conta corrente */
  vr_nrdcontavld := TO_NUMBER(SUBSTR(vr_nmarvalidar,5,8));
  IF vr_nrdcontavld <> pr_nrdconta THEN
     vr_dscritic := 'Numero da conta do arquivo nao corresponde a conta informada no arquivo!';
     raise vr_exc_saida;
  END IF;  
  /* Numero sequencial */ 
  vr_nrsequencial := TO_NUMBER(SUBSTR(vr_nmarvalidar,14,6));
  --Verificar o ultimo sequencial desta conta (pendente - depende das novas tabelas)
  OPEN cr_infarq (pr_nrdconta);
  FETCH cr_infarq  INTO vr_nrsequencial_atual;
  CLOSE cr_infarq;
  IF vr_nrsequencial <= NVL(vr_nrsequencial_atual,0) THEN
     vr_dscritic := 'Numero sequencial do arquivo inferior ao ultimo processado!';
     raise vr_exc_saida;
  END IF;  
  
  -- Busca o diretório do upload do arquivo
  vr_dsupload := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                      ,pr_cdcooper => pr_cdcooper
                                      ,pr_nmsubdir => 'upload');
                                        
  -- Busca o diretório do upload do arquivo
  vr_dirarqui := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                      ,pr_cdcooper => pr_cdcooper
                                      ,pr_nmsubdir => 'arq');



  WHILE NOT vr_flgarqui LOOP

      GENE0001.pc_OScommand_Shell(gene0001.fn_param_sistema('CRED',0,'SCRIPT_RECEBE_ARQUIVOS')||' '||pr_dsdireto||pr_dsarquiv||' S'
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_des_erro);
 
    -- Testar erro
    IF vr_typ_said = 'ERR' THEN
      -- O comando shell executou com erro, gerar log e sair do processo
      vr_dscritic := 'Erro realizar o upload do arquivo: ' || vr_des_erro;
      RAISE vr_exc_saida;
    END IF;

    -- Verifica se o arquivo existe
    IF GENE0001.fn_exis_arquivo(pr_caminho => vr_dsupload||'/'||pr_dsarquiv) THEN
      vr_flgarqui := true;
    -- Tenta criar copia dez vezes
    ELSIF vr_contador = 10 THEN
      vr_flgarqui := true;
    END IF;
      
    vr_contador := vr_contador + 1;
    
  END LOOP;
    
  vr_contador := 0;

  -- Verifica se o arquivo existe
  IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsupload||'/'||pr_dsarquiv) THEN
    -- Retorno de erro
    vr_dscritic := 'Arquivo não encontrado no diretório: '||REPLACE(vr_dsupload,'/','-')||'-'||pr_dsarquiv;
    RAISE vr_exc_saida;
  END IF;
  --
  vr_clob_ted := gene0002.fn_arq_para_clob(vr_dsupload, pr_dsarquiv);
  --   
  /* Move o arquivo lido para o diretório salvar */
  gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_dsupload||'/'||pr_dsarquiv||' '||vr_dirarqui||'/'||pr_dsarquiv||' 2> /dev/null'
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_des_saida);

  -- Se retornar uma indicação de erro
  IF NVL(vr_typ_saida,' ') = 'ERR' THEN
    vr_cdcritic := 1054; -- Erro pc_OScommand_Shell                       
    raise vr_exc_saida;
  END IF;

  -- Faz validacoes basicas no conteudo do arquivo
  pc_verifica_layout_ted (pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nmarquiv => pr_dsarquiv
                     ,pr_retxml   => pr_retxml
                     ,pr_cdcritic => vr_cdcritic
                     ,pr_dscritic => vr_dscritic); 

  -- Retorna inconsistencias caso encontradas
  IF nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null THEN
    raise vr_exc_saida;
  END IF;
  --
  pr_des_erro := 'OK';
  --
 
EXCEPTION
  
  WHEN vr_exc_saida THEN
    rollback;
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
    pr_des_erro := 'NOK';
    -- Carregar XML padrão para variável de retorno não utilizada.
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
  WHEN OTHERS THEN 
    rollback;    
    pr_cdcritic := 0;
    pr_dscritic := 'Erro não tratado na PGTA0001.pc_importa_arquivo_ted: '||sqlerrm;
    pr_des_erro := 'NOK';
    -- Carregar XML padrão para variável de retorno não utilizada.
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

END pc_importa_arquivo_ted;

procedure pc_consulta_arquivo_remessa   (pr_cdcooper   in crapatr.cdcooper%type  --> Número da cooperativa do cooperado
                                   ,pr_nrdconta   in crapass.nrdconta%type  --> Número da conta do cooperado
                                   ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_consulta_arquivo_remessa
  --  Sistema  : Ayllos Web
  --  Autor    : Jose Dill
  --  Data     : Maio/2019                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Buscar as informacoes dos arquivos de remessa TED/Transferência
  --          
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  CURSOR cr_arqrem (pr_cdcooper in tbtransf_arquivo_ted.cdcooper%type
                   ,pr_nrdconta in tbtransf_arquivo_ted.nrdconta%type ) IS
  SELECT tat.nmarquivo
        ,TO_CHAR(trunc(tat.dtgeracao),'DD/MM/YYYY') dtgeracao
        ,tat.dsarquivo 
        ,tat.nrseq_arq_ted
  FROM tbtransf_arquivo_ted tat
  WHERE tat.nrdconta = pr_nrdconta
  AND   tat.cdcooper = pr_cdcooper 
  ORDER BY tat.dtgeracao desc;
     
  -- Declaracao padrao de variaveis
  vr_dscritic  varchar2(1000);
  vr_exc_saida exception;
  vr_cdcritic  pls_integer;
      
  
  -- Variaveis padrao                            
  vr_nmdatela  varchar2(100);                                  
  vr_nmeacao   varchar2(100);                                  
  vr_cdagenci  varchar2(100);                                  
  vr_nrdcaixa  varchar2(100);                                  
  vr_idorigem  varchar2(100);                                  
  vr_cdoperad  varchar2(100);  
  vr_cdcooper  integer;
  
  vr_contador  integer;
  vr_sequencia integer;
  
BEGIN

  -- Extrai cooperativa do xml
  gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                          ,pr_cdcooper => vr_cdcooper
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nmeacao  => vr_nmeacao
                          ,pr_cdagenci => vr_cdagenci
                          ,pr_nrdcaixa => vr_nrdcaixa
                          ,pr_idorigem => vr_idorigem
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => vr_dscritic);

  -- Aborta em caso de erro
  IF trim(vr_dscritic) is not null THEN
    NULL;
  END IF;

  -- Criar cabeçalho do XML
  pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Root',
                         pr_posicao  => 0,
                         pr_tag_nova => 'Remessa',
                         pr_tag_cont => NULL,
                         pr_des_erro => vr_dscritic);
  vr_contador:= 0;
  vr_sequencia:= 0;
  --
  FOR rr_arqrem IN cr_arqrem(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta=> pr_nrdconta) LOOP
                            
    vr_sequencia:= vr_sequencia + 1;       
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Remessa',
                           pr_posicao  => 0,
                           pr_tag_nova => 'DadosRem',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
               
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'DadosRem',
                           pr_posicao  => vr_contador,
                           pr_tag_nova => 'sequenci',
                           pr_tag_cont => vr_sequencia,
                           pr_des_erro => vr_dscritic);
                           
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'DadosRem',
                           pr_posicao  => vr_contador,
                           pr_tag_nova => 'nomereme',
                           pr_tag_cont => rr_arqrem.nmarquivo,
                           pr_des_erro => vr_dscritic);                           

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'DadosRem',
                           pr_posicao  => vr_contador,
                           pr_tag_nova => 'datareme',
                           pr_tag_cont => rr_arqrem.dtgeracao,
                           pr_des_erro => vr_dscritic);
                           
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'DadosRem',
                           pr_posicao  => vr_contador,
                           pr_tag_nova => 'nrseqarq',
                           pr_tag_cont => rr_arqrem.nrseq_arq_ted,
                           pr_des_erro => vr_dscritic);  
                           
                                                                                     
    vr_contador:= vr_contador + 1;                                            
  END LOOP;                                   
  --
 
EXCEPTION
  
  WHEN vr_exc_saida THEN

    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
    pr_des_erro := 'NOK';
    -- Carregar XML padrão para variável de retorno não utilizada.
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
  WHEN OTHERS THEN 
        
    pr_cdcritic := 0;
    pr_dscritic := 'Erro não tratado na PGTA0001.pc_consulta_arquivo_remessa: '||sqlerrm;
    pr_des_erro := 'NOK';
    -- Carregar XML padrão para variável de retorno não utilizada.
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

END pc_consulta_arquivo_remessa;


procedure pc_salva_arquivo_remessa (pr_nrseq_arq_ted   in tbtransf_arquivo_ted.nrseq_arq_ted%type  --> Número de identificação do arquivo
                                   ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_salva_arquivo_remessa
  --  Sistema  : Ayllos Web
  --  Autor    : Jose Dill
  --  Data     : Maio/2019                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Buscar o arquivo de retorno para fazer o seu download
  --          
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  CURSOR cr_arqrem (pr_nrseq_arq_ted in tbtransf_arquivo_ted.nrseq_arq_ted%type) IS
  SELECT tat.dsarquivo 
        ,tat.nmarquivo
  FROM tbtransf_arquivo_ted tat
  WHERE tat.nrseq_arq_ted = pr_nrseq_arq_ted;
     
  -- Declaracao padrao de variaveis
  vr_dscritic  varchar2(1000);
  vr_exc_saida exception;
  vr_cdcritic  pls_integer;
  
  vr_arq_rem_0  VARCHAR2(32767);
  vr_arq_rem_1  VARCHAR2(32767);
  vr_arq_rem_2  VARCHAR2(32767);    
  vr_arq_rem_3  VARCHAR2(32767);
  vr_arq_rem_4  VARCHAR2(32767);
  vr_arq_rem_5  VARCHAR2(32767);
  vr_arq_rem_6  VARCHAR2(32767);
  vr_arq_rem_7  VARCHAR2(32767);
  vr_arq_rem_8  VARCHAR2(32767);
  vr_arq_rem_9  VARCHAR2(32767);
  vr_arq_rem_10 VARCHAR2(32767);
  vr_arq_rem_11 VARCHAR2(32767);
  vr_arq_rem_12 VARCHAR2(32767);
  vr_arq_rem_13 VARCHAR2(32767);
  vr_arq_rem_14 VARCHAR2(32767);
  vr_arq_rem_15 VARCHAR2(32767);
  vr_arq_rem_16 VARCHAR2(32767);
  vr_arq_rem_17 VARCHAR2(32767);
  vr_arq_rem_18 VARCHAR2(32767);
  vr_arq_rem_19 VARCHAR2(32767);
  
  -- Variaveis padrao                            
  vr_nmdatela  varchar2(100);                                  
  vr_nmeacao   varchar2(100);                                  
  vr_cdagenci  varchar2(100);                                  
  vr_nrdcaixa  varchar2(100);                                  
  vr_idorigem  varchar2(100);                                  
  vr_cdoperad  varchar2(100);  
  vr_cdcooper  integer;
  
  vr_contador  integer;
  vr_sequencia integer;
  
BEGIN

 
  -- Extrai cooperativa do xml
  gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                          ,pr_cdcooper => vr_cdcooper
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nmeacao  => vr_nmeacao
                          ,pr_cdagenci => vr_cdagenci
                          ,pr_nrdcaixa => vr_nrdcaixa
                          ,pr_idorigem => vr_idorigem
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => vr_dscritic);

  -- Aborta em caso de erro
  IF trim(vr_dscritic) is not null THEN
    NULL;
  END IF;

  -- Criar cabeçalho do XML
  pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
  gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                         pr_tag_pai  => 'Root',
                         pr_posicao  => 0,
                         pr_tag_nova => 'Download',
                         pr_tag_cont => NULL,
                         pr_des_erro => vr_dscritic);
  vr_contador:= 0;
  vr_sequencia:= 0;
    FOR rr_arqrem IN cr_arqrem(pr_nrseq_arq_ted => pr_nrseq_arq_ted) LOOP
                            
    vr_sequencia:= vr_sequencia + 1;       
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Download',
                           pr_posicao  => 0,
                           pr_tag_nova => 'DadosDown',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);              
   
    vr_arq_rem_0:= substr( rr_arqrem.dsarquivo,1, 32737);
    vr_arq_rem_1:= substr( rr_arqrem.dsarquivo,32738, 32737);
    vr_arq_rem_2:= substr( rr_arqrem.dsarquivo,65475, 32737);
    vr_arq_rem_3:= substr( rr_arqrem.dsarquivo,98212, 32737);
    vr_arq_rem_4:= substr( rr_arqrem.dsarquivo,130949, 32737);
    vr_arq_rem_5:= substr( rr_arqrem.dsarquivo,163686, 32737);
    vr_arq_rem_6:= substr( rr_arqrem.dsarquivo,196423, 32737);
    vr_arq_rem_7:= substr( rr_arqrem.dsarquivo,229160, 32737);
    vr_arq_rem_8:= substr( rr_arqrem.dsarquivo,261897, 32737);
    vr_arq_rem_9:= substr( rr_arqrem.dsarquivo,294634, 32737);
    vr_arq_rem_10:= substr( rr_arqrem.dsarquivo,327371, 32737);
    vr_arq_rem_11:= substr( rr_arqrem.dsarquivo,360108, 32737);
    vr_arq_rem_12:= substr( rr_arqrem.dsarquivo,392845, 32737);
    vr_arq_rem_13:= substr( rr_arqrem.dsarquivo,425582, 32737);
    vr_arq_rem_14:= substr( rr_arqrem.dsarquivo,458319, 32737);
    vr_arq_rem_15:= substr( rr_arqrem.dsarquivo,491056, 32737);
    vr_arq_rem_16:= substr( rr_arqrem.dsarquivo,523793, 32737);
    vr_arq_rem_17:= substr( rr_arqrem.dsarquivo,556530, 32737);
    vr_arq_rem_18:= substr( rr_arqrem.dsarquivo,589267, 32737);
    vr_arq_rem_19:= substr( rr_arqrem.dsarquivo,622004, 32737);

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'DadosDown',
                           pr_posicao  => vr_contador,
                           pr_tag_nova => 'arqclob1',
                           pr_tag_cont => vr_arq_rem_0||vr_arq_rem_1,                                       
                           pr_des_erro => vr_dscritic);
                           
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'DadosDown',
                           pr_posicao  => vr_contador,
                           pr_tag_nova => 'arqclob2',
                           pr_tag_cont => vr_arq_rem_2||vr_arq_rem_3,                                       
                           pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'DadosDown',
                           pr_posicao  => vr_contador,
                           pr_tag_nova => 'arqclob3',
                           pr_tag_cont => vr_arq_rem_4||vr_arq_rem_5,                                       
                           pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'DadosDown',
                           pr_posicao  => vr_contador,
                           pr_tag_nova => 'arqclob4',
                           pr_tag_cont => vr_arq_rem_6||vr_arq_rem_7,                                       
                           pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'DadosDown',
                           pr_posicao  => vr_contador,
                           pr_tag_nova => 'arqclob5',
                           pr_tag_cont => vr_arq_rem_8||vr_arq_rem_9,                                       
                           pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'DadosDown',
                           pr_posicao  => vr_contador,
                           pr_tag_nova => 'arqclob6',
                           pr_tag_cont => vr_arq_rem_10||vr_arq_rem_11,                                       
                           pr_des_erro => vr_dscritic);                   

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'DadosDown',
                           pr_posicao  => vr_contador,
                           pr_tag_nova => 'arqclob7',
                           pr_tag_cont => vr_arq_rem_12||vr_arq_rem_13,                                       
                           pr_des_erro => vr_dscritic);  
                           
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'DadosDown',
                           pr_posicao  => vr_contador,
                           pr_tag_nova => 'arqclob8',
                           pr_tag_cont => vr_arq_rem_14||vr_arq_rem_15,                                       
                           pr_des_erro => vr_dscritic);  
                           
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'DadosDown',
                           pr_posicao  => vr_contador,
                           pr_tag_nova => 'arqclob9',
                           pr_tag_cont => vr_arq_rem_16||vr_arq_rem_17,                                       
                           pr_des_erro => vr_dscritic);  
                           
                           
     gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'DadosDown',
                           pr_posicao  => vr_contador,
                           pr_tag_nova => 'arqclob10',
                           pr_tag_cont => vr_arq_rem_18||vr_arq_rem_19,                                       
                           pr_des_erro => vr_dscritic);  
                                                                                                                                                                                                 
    vr_contador:= vr_contador + 1;                                            
  END LOOP;                                   
  --
 
EXCEPTION
  
  WHEN vr_exc_saida THEN

    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
    pr_des_erro := 'NOK';
    -- Carregar XML padrão para variável de retorno não utilizada.
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
  WHEN OTHERS THEN 
        
    pr_cdcritic := 0;
    pr_dscritic := 'Erro não tratado na PGTA0001.pc_salva_arquivo_remessa: '||sqlerrm;
    pr_des_erro := 'NOK';
    -- Carregar XML padrão para variável de retorno não utilizada.
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

END pc_salva_arquivo_remessa;


procedure pc_gerar_seg_arquivo_retorno (pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2    --> Descrição da crítica
                                   ) IS       

  ---------------------------------------------------------------------------
  --
  --  Programa : pc_gerar_seg_arquivo_retorno
  --  Sistema  : Ayllos Web
  --  Autor    : Jose Dill
  --  Data     : Julho/2019                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Gerar o segundo arquivo de retorno cnab de Transferência e Teds (Diário)
  --          
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  
  /*Seleciona os agendamentos incluídos com sucesso através do Upload de arquivo CNAB
    de acordo com a data informada (diária)*/
  CURSOR cr_segret (pr_dtretorno IN DATE) IS
  select tat.cdcooper
        ,tat.nrdconta
        ,tat.nmarquivo
        ,tat.nrseq_arquivo
        ,decode(tatl.cdbco_fav, '085','Transferencia','TED') Tipo_operacao
        ,tat.nrseq_arq_ted
        ,tatl.dslinha_arq
        ,tatl.dsprotocolo
        ,tatl.idlancto
        ,tatl.cdbco_comp
        ,tatl.vlrpgto
  from tbtransf_arquivo_ted_linhas tatl
      ,tbtransf_arquivo_ted tat
  where tat.nrseq_arq_ted = tatl.nrseq_arq_ted
  and   tatl.dsret_cnab = 'BD'
  and   tatl.cdsegmento = 'A'
  and   tatl.cdbco_comp is not null
  and   to_date(tatl.dtprv_pgto) = pr_dtretorno
  order by tat.cdcooper, tat.nrdconta, tat.nrseq_arquivo, tatl.nrseq_arq_ted_linha;
  
  rw_segret cr_segret%ROWTYPE;
  
  /* Busca a situação do TED na LOGSPB */
  CURSOR cr_sitted (pr_cdcooper in crapcop.cdcooper%type
                   ,pr_idlancto in craplau.idlancto%type) IS
  select tela_logspb.fn_define_situacao_enviada(tvl.idmsgenv) situacao
        ,lau.insitlau
  from craplau lau
      ,craptvl tvl
      ,tbspb_msg_enviada tme
  where lau.cdcooper = pr_cdcooper
  and   lau.idlancto = pr_idlancto
  and   lau.cdcooper = tvl.cdcooper
  and   lau.idlancto = tvl.idlancto
  and   tvl.idmsgenv = tme.nrseq_mensagem;
  
  rw_sitted cr_sitted%ROWTYPE;


  /* Busca situação da Transferencia */
  CURSOR cr_sittrf (pr_cdcooper in crapcop.cdcooper%type
                   ,pr_idlancto in craplau.idlancto%type) IS
  select lau.insitlau
  from craplau lau
  where lau.cdcooper = pr_cdcooper
  and   lau.idlancto = pr_idlancto;
  
  rw_sittrf cr_sittrf%ROWTYPE; 
   
  -- Tratamento de erros
  vr_exc_erro  EXCEPTION;
  vr_dscritic VARCHAR2(4000);
  vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
  
  -- Variaveis de sistemas
  vr_cdcooper crapcop.cdcooper%type;
  vr_nrdconta crapass.nrdconta%type;
  vr_fgprimeiro        BOOLEAN:= false;
  vr_fgheader          BOOLEAN:= true;
  vr_arq_retorno       CLOB;
  vr_texto_arq_retorno VARCHAR2(32767);
  vr_segmento_a        tbtransf_arquivo_ted_linhas.dslinha_arq%type;
  vr_segmento_b        tbtransf_arquivo_ted_linhas.dslinha_arq%type;
  vr_header_0          tbtransf_arquivo_ted_linhas.dslinha_arq%type;
  vr_header_1          tbtransf_arquivo_ted_linhas.dslinha_arq%type;    
  vr_trailer_5         tbtransf_arquivo_ted_linhas.dslinha_arq%type;    
  vr_trailer_9         tbtransf_arquivo_ted_linhas.dslinha_arq%type;    
  vr_nmarquivo_ret     VARCHAR2(50);
  vr_codcnabret        VARCHAR2(02);
  vr_nr_seq_segret     NUMBER:= 0;
  vr_qt_reg_conta      NUMBER;
  vr_nrseq_arq_ted     tbtransf_arquivo_ted.nrseq_arq_ted%type;
  vr_qt_reg_a_b_header NUMBER:= 0;
  vr_qt_reg_total      NUMBER:= 0;
  v_vlr_segmento_a     NUMBER(15,2):= 0;
  vr_dtretorno         DATE;
  vr_nrseq_reglote_a_b NUMBER:=0;

PROCEDURE pc_gerar_segmento_b (pr_banco_comp    IN VARCHAR2
                              ,pr_dsprotocolo   IN VARCHAR2) IS 
/* .............................................................................
   
    Objetivo  : Gerar a linha do segmento b.
    
    Observacao: 
    
    Alteracoes:
..............................................................................*/
  
  vr_banco_comp VARCHAR2(03);
  vr_lote_ser   VARCHAR2(04):= '0001';
  vr_tipo_reg   VARCHAR2(01):= '3';
  vr_nrseq_reglote VARCHAR2(05):= ' ';
  vr_codsegmento VARCHAR2(01):= 'B';
  vr_cnab        VARCHAR2(03):= ' ';
  vr_autentetic  VARCHAR2(56):= ' ';
  vr_cnab_aux    VARCHAR2(157):= ' ';
  vr_ocorrencia  VARCHAR2(10):= ' ';
BEGIN
  --
  vr_banco_comp := pr_banco_comp;  
  vr_tipo_reg   := '3';
  --
  vr_nrseq_reglote_a_b:= vr_nrseq_reglote_a_b + 1;
  vr_nrseq_reglote := lpad(vr_nrseq_reglote_a_b,5,'0');
  vr_codsegmento := 'B';
  vr_cnab        := rpad(vr_cnab,3,' '); 
  vr_autentetic  := rpad(NVL(pr_dsprotocolo,' '),56,' '); 
  vr_cnab_aux    := rpad(vr_cnab_aux,157,' '); 
  vr_ocorrencia  := lpad(' ',10,' '); 
  --   
  vr_segmento_b:= vr_banco_comp||vr_lote_ser||vr_tipo_reg||vr_nrseq_reglote
                ||vr_codsegmento||vr_cnab||vr_autentetic||vr_cnab_aux||vr_ocorrencia;
  -- 
  vr_qt_reg_a_b_header:= vr_qt_reg_a_b_header + 1;
  vr_qt_reg_total     := vr_qt_reg_total + 1;
  -- 
EXCEPTION
  WHEN OTHERS THEN
    vr_dscritic := 'Erro na pc_gerar_segmento_b: '||sqlerrm;
    RAISE vr_exc_erro;
END pc_gerar_segmento_b;

FUNCTION fn_retorna_situacao (pr_idlancto      IN CRAPLAU.IDLANCTO%TYPE
                              ,pr_tipo_operacao IN VARCHAR2) RETURN VARCHAR2 IS 
/* .............................................................................
   
    Objetivo  : Buscar a situação da TED/Transferencia e retorna-la.
    
    Observacao: 
    
    Alteracoes:
..............................................................................*/
  

BEGIN
  IF pr_tipo_operacao = 'TED' THEN
    --TED
    OPEN cr_sitted(vr_cdcooper, pr_idlancto);
    FETCH cr_sitted INTO rw_sitted;
    IF cr_sitted%FOUND THEN
     IF rw_sitted.Insitlau = 2 THEN
       IF rw_sitted.situacao = 'EFETIVADA' THEN
         vr_codcnabret := 'YI';
       ELSIF rw_sitted.situacao = 'DEVOLVIDA' THEN
            vr_codcnabret := 'YM';
       ELSIF rw_sitted.situacao = 'ESTORNADA' THEN
            vr_codcnabret := 'YN';
       ELSIF rw_sitted.situacao = 'REJEITADA' THEN
            vr_codcnabret := 'YP';
       ELSIF rw_sitted.situacao = 'PENDENTE CAMARA' THEN
            vr_codcnabret := 'YQ';
       ELSIF rw_sitted.situacao = 'EM PROCESSAMENTO' THEN
            vr_codcnabret := 'YR';
       ELSE
         vr_codcnabret := 'YK';  
       END IF;          
     ELSE
       IF rw_sitted.Insitlau = 3 THEN
         vr_codcnabret := 'YL';
       ELSIF rw_sitted.Insitlau = 4 THEN
         vr_codcnabret := 'HF';  
       ELSE
         vr_codcnabret := 'YK';
       END IF;  
     END IF;           
    ELSE
     vr_codcnabret := 'YK'; 
    END IF;
    CLOSE cr_sitted;
    --
  ELSE
    -- Transferencia
    OPEN cr_sittrf(vr_cdcooper, pr_idlancto);
    FETCH cr_sittrf INTO rw_sittrf;
    IF cr_sittrf%FOUND THEN    
     IF rw_sittrf.insitlau = 2  THEN
         vr_codcnabret := 'YI';
     ELSE
       IF rw_sittrf.Insitlau = 3 THEN
         vr_codcnabret := 'YL';
       ELSIF rw_sittrf.Insitlau = 4 THEN
         vr_codcnabret := 'HF';  
       ELSE
         vr_codcnabret := 'YK';
       END IF;  
     END IF;           
    ELSE
     vr_codcnabret := 'YK'; 
    END IF;
    CLOSE cr_sittrf;
  END IF;   
  --
  RETURN vr_codcnabret;
EXCEPTION
  WHEN OTHERS THEN
    vr_dscritic := 'Erro na fn_retorna_situacao: '||sqlerrm;
    RAISE vr_exc_erro;
END fn_retorna_situacao;


PROCEDURE pc_gerar_header (pr_nrseq_arq_ted in tbtransf_arquivo_ted_linhas.nrseq_arq_ted%type) IS 
/* .............................................................................
   
    Objetivo  : Gerar as linhas do header.
    
    Observacao: 
    
    Alteracoes:
..............................................................................*/

  CURSOR cr_dadheader (pr_nrseq_arq_ted in tbtransf_arquivo_ted_linhas.nrseq_arq_ted%type) is
  select tatl.dslinha_arq
       , tatl.dstipo_reg
  from tbtransf_arquivo_ted_linhas tatl
  where tatl.nrseq_arq_ted = pr_nrseq_arq_ted
  and   tatl.dstipo_reg in ('0','1') /*0 - Header Arquivo, 1 - Header Lote */
  order by tatl.dstipo_reg ;

BEGIN
  FOR rw_dadheader in cr_dadheader (pr_nrseq_arq_ted) LOOP 
    --
    IF rw_dadheader.Dstipo_Reg = '0' THEN
      -- Buscar nr de sequencia do segundo arquivo de retorno
      SELECT NVL(MAX(TAT.NRSEQ_ARQUIVO),0) + 1 INTO vr_nr_seq_segret
      FROM TBTRANSF_ARQUIVO_TED TAT
      WHERE TAT.CDCOOPER = vr_cdcooper
      AND   TAT.NRDCONTA = vr_nrdconta
      AND   TAT.IDTIPOARQ = 2;     
      -- 
      vr_header_0 := rw_dadheader.dslinha_arq;
      vr_header_0 := Substr(vr_header_0,1,143)||
                     To_char(vr_dtretorno,'DDMMYYYY')||
                     Substr(vr_header_0,152,6)||
                     LPad(To_char(vr_nr_seq_segret),6,'0')||
                     Substr(vr_header_0,164,75);
      --
      vr_qt_reg_a_b_header:= vr_qt_reg_a_b_header + 1;
      vr_qt_reg_total:= vr_qt_reg_total +1;
      --               
    ELSE
      vr_header_1 := rw_dadheader.dslinha_arq; 
      --
      vr_qt_reg_a_b_header:= vr_qt_reg_a_b_header + 1;
      vr_qt_reg_total:= vr_qt_reg_total + 1;
      --               
    END IF;       
  END LOOP;
  --  
EXCEPTION
  WHEN OTHERS THEN
    vr_dscritic := 'Erro na pc_gerar_header: '||sqlerrm;
    RAISE vr_exc_erro;
  
END pc_gerar_header;

PROCEDURE pc_gerar_trailer (pr_nrseq_arq_ted in tbtransf_arquivo_ted_linhas.nrseq_arq_ted%type) IS 
/* .............................................................................
   
    Objetivo  : Gerar as linhas do trailer.
    
    Observacao: 
    
    Alteracoes:
..............................................................................*/  
    
  CURSOR cr_dadheader (pr_nrseq_arq_ted in tbtransf_arquivo_ted_linhas.nrseq_arq_ted%type) is
  select tatl.dslinha_arq
       , tatl.dstipo_reg
  from tbtransf_arquivo_ted_linhas tatl
  where tatl.nrseq_arq_ted = pr_nrseq_arq_ted
  and   tatl.dstipo_reg in ('5','9') /*5 - Trailer Lote, 9 - Trailer Arquivo*/
  order by tatl.dstipo_reg ;

BEGIN
  FOR rw_dadheader in cr_dadheader (pr_nrseq_arq_ted) LOOP 
    --
    IF rw_dadheader.Dstipo_Reg = '5' THEN /*Trailer Lote*/
      -- 
      vr_trailer_5 := rw_dadheader.dslinha_arq;
      vr_trailer_5 := Substr(vr_trailer_5,1,17)||
                      LPad(To_Char(vr_qt_reg_a_b_header),6,'0')|| 
                      LPad(To_Char((v_vlr_segmento_a * 100)),18 ,'0')|| 
                      Substr(vr_trailer_5,42,199);
      --
      vr_qt_reg_total:= vr_qt_reg_total + 1;
    ELSE /*Trailer Arquivo*/
      vr_qt_reg_total:= vr_qt_reg_total + 1;
      --
      vr_trailer_9 := rw_dadheader.dslinha_arq; 
      vr_trailer_9 := Substr(vr_trailer_9,1,23)||
                      LPad(To_Char(vr_qt_reg_total),6,'0')|| 
                      Substr(vr_trailer_9,30,211);      
    END IF;       
  END LOOP;
  --
  vr_qt_reg_a_b_header:= 0;
  v_vlr_segmento_a    := 0;
  vr_qt_reg_total     := 0;  
  --

EXCEPTION
  WHEN OTHERS THEN
    vr_dscritic := 'Erro na pc_gerar_trailer: '||sqlerrm;
    RAISE vr_exc_erro;
  
END pc_gerar_trailer;
   
BEGIN
   vr_cdcooper:= null;
   vr_nrdconta:= null;
   vr_qt_reg_conta:= 0;
   vr_dtretorno:= trunc(sysdate);
   --
   FOR rw_segret in cr_segret (vr_dtretorno) LOOP   
      -- Agrupar por Cooperativa e Conta
      IF rw_segret.cdcooper = vr_cdcooper  AND rw_segret.nrdconta = vr_nrdconta THEN
        -- Gerar informação do Segmento A
        vr_segmento_a := rw_segret.dslinha_arq;  
        vr_segmento_a := Substr(vr_segmento_a,1,3)||'0001'||Substr(vr_segmento_a,8,233);
        --
        vr_qt_reg_a_b_header:= vr_qt_reg_a_b_header + 1;
        vr_qt_reg_total     := vr_qt_reg_total    + 1;
        v_vlr_segmento_a := v_vlr_segmento_a + TO_NUMBER(rw_segret.vlrpgto,'999999999999999') / 100; 
        --
        -- Gerar informação do Segmento B
        IF fn_retorna_situacao(rw_segret.idlancto
                              ,rw_segret.tipo_operacao) = 'YI' THEN
            
          -- Gravar linhas do Segmento A 
          /* Atualiza o numero de sequencia do lote no segmento a*/
          vr_nrseq_reglote_a_b:= vr_nrseq_reglote_a_b + 1;
          vr_segmento_a:= Substr(vr_segmento_a,1,8)||lpad(vr_nrseq_reglote_a_b,5,0)||Substr(vr_segmento_a,14,237);
          /* Atualiza o código de retorno no segmento a*/
          vr_segmento_a:= Substr(vr_segmento_a,1,238)||vr_codcnabret;
          /* Atualiza o numero sequencial do arquivo no segmento a*/
          vr_segmento_a:= Substr(vr_segmento_a,1,154)||LPad(rw_segret.nrseq_arquivo,8,'0')||Substr(vr_segmento_a,163,78);
          --
          pc_gerar_segmento_b(rw_segret.cdbco_comp
                             ,rw_segret.dsprotocolo); 
          --                   
          gene0002.pc_escreve_xml(vr_arq_retorno,vr_texto_arq_retorno,vr_segmento_a||chr(10));
          gene0002.pc_escreve_xml(vr_arq_retorno,vr_texto_arq_retorno,vr_segmento_b||chr(10)); 
          --
        ELSE
          -- Gravar linha do Segmento A 
          /* Atualiza o numero de sequencia do lote no segmento a*/
          vr_nrseq_reglote_a_b:= vr_nrseq_reglote_a_b + 1;
          vr_segmento_a:= Substr(vr_segmento_a,1,8)||lpad(vr_nrseq_reglote_a_b,5,0)||Substr(vr_segmento_a,14,237);
        
          /* Atualiza o código de retorno no segmento a*/
          vr_segmento_a:= Substr(vr_segmento_a,1,238)||vr_codcnabret;
          /* Atualiza o numero sequencial do arquivo no segmento a*/
          vr_segmento_a:= Substr(vr_segmento_a,1,154)||LPad(rw_segret.nrseq_arquivo,8,'0')||Substr(vr_segmento_a,163,78);
          --
          gene0002.pc_escreve_xml(vr_arq_retorno,vr_texto_arq_retorno,vr_segmento_a||chr(10));
        END IF;                   
       
      ELSE
        -- Senão for o primeiro registro, gerar informações do Trailer
        IF vr_fgprimeiro THEN
           --           
           -- Gerar informações do Trailer da Conta Anterior   
           pc_gerar_trailer(vr_nrseq_arq_ted);
           --
           gene0002.pc_escreve_xml(vr_arq_retorno,vr_texto_arq_retorno,vr_trailer_5||chr(10));
           gene0002.pc_escreve_xml(vr_arq_retorno,vr_texto_arq_retorno,vr_trailer_9,True);                  
           -- Criar registro de retorno           
           BEGIN
              vr_nmarquivo_ret:= 'TED_'||LPAD(vr_nrdconta,8,0)||'_MOV'||TO_CHAR(vr_dtretorno,'DDMMYYYY')||'.RET';
              INSERT INTO tbtransf_arquivo_ted (nrseq_arq_ted,   
                                               nmarquivo, 
                                               nrseq_arquivo,
                                               nrdconta,    
                                               cdcooper, 
                                               dtgeracao, 
                                               dsarquivo)
                                       values (null , 
                                               vr_nmarquivo_ret,
                                               vr_nr_seq_segret, 
                                               vr_nrdconta, 
                                               vr_cdcooper,   
                                               sysdate, 
                                               vr_arq_retorno);     
             --
           EXCEPTION
             WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir dados na tbtransf_arquivo_ted segundo arquivo: '||sqlerrm;
                RAISE vr_exc_erro;
           END;   

           -- Fechar arquivo de retorno 
           -- Liberando a memoria alocada pro CLOB
           dbms_lob.close(vr_arq_retorno);
           dbms_lob.freetemporary(vr_arq_retorno);
           -- Criar novo arquivo de retorno
           vr_fgheader:= True;
           -- Inicializar arquivo
           dbms_lob.createtemporary(vr_arq_retorno, TRUE);
           dbms_lob.open(vr_arq_retorno, dbms_lob.lob_readwrite);
        ELSE
           --Primeiro registro processado
           vr_fgprimeiro:= true;
           -- Criar arquivo de retorno           
           -- Inicializar arquivo
           dbms_lob.createtemporary(vr_arq_retorno, TRUE);
           dbms_lob.open(vr_arq_retorno, dbms_lob.lob_readwrite);
            --
        END IF;      
        --
        vr_qt_reg_conta:= vr_qt_reg_conta + 1;
        --
        vr_cdcooper := rw_segret.cdcooper;
        vr_nrdconta := rw_segret.nrdconta;
        vr_nrseq_arq_ted:= rw_segret.nrseq_arq_ted;
        -- Gerar informacoes do header
        IF vr_fgheader THEN
          -- Buscar informações do header do arquivo de retorno
          vr_fgheader:= false;
          -- Grava informações do header no arquivo de retorno
          pc_gerar_header(rw_segret.nrseq_arq_ted);
          --
          gene0002.pc_escreve_xml(vr_arq_retorno,vr_texto_arq_retorno,vr_header_0||chr(10));
          gene0002.pc_escreve_xml(vr_arq_retorno,vr_texto_arq_retorno,vr_header_1||chr(10));  
          --      
        END IF;  
        -- Gerar informação do Segmento A
        vr_segmento_a := rw_segret.dslinha_arq;
        vr_segmento_a := Substr(vr_segmento_a,1,3)||'0001'||Substr(vr_segmento_a,8,233);     
        --
        
        vr_qt_reg_a_b_header:= vr_qt_reg_a_b_header + 1;
        vr_qt_reg_total     := vr_qt_reg_total      + 1;
        v_vlr_segmento_a    := v_vlr_segmento_a + TO_NUMBER(rw_segret.vlrpgto,'999999999999999') / 100;
        --              
        -- Gerar informação do Segmento B
        IF fn_retorna_situacao(rw_segret.idlancto
                              ,rw_segret.tipo_operacao) = 'YI' THEN
   
          -- Gravar linhas do Segmento A
          /* Atualiza o numero de sequencia do lote no segmento a*/
          vr_nrseq_reglote_a_b:= vr_nrseq_reglote_a_b + 1;
          vr_segmento_a:= Substr(vr_segmento_a,1,8)||lpad(vr_nrseq_reglote_a_b,5,0)||Substr(vr_segmento_a,14,237);
          
          /* Atualiza o código de retorno no segmento a*/
          vr_segmento_a:= Substr(vr_segmento_a,1,238)||vr_codcnabret;
          /* Atualiza o numero sequencial do arquivo no segmento a*/
          vr_segmento_a:= Substr(vr_segmento_a,1,154)||LPad(rw_segret.nrseq_arquivo,8,'0')||Substr(vr_segmento_a,163,78);
          --
          pc_gerar_segmento_b(rw_segret.cdbco_comp
                             ,rw_segret.dsprotocolo);
          --          
          gene0002.pc_escreve_xml(vr_arq_retorno,vr_texto_arq_retorno,vr_segmento_a||chr(10));
          gene0002.pc_escreve_xml(vr_arq_retorno,vr_texto_arq_retorno,vr_segmento_b||chr(10)); 
          --
        ELSE
          -- Gravar linha do Segmento A 
          /* Atualiza o numero de sequencia do lote no segmento a*/
          vr_nrseq_reglote_a_b:= vr_nrseq_reglote_a_b + 1;
          vr_segmento_a:= Substr(vr_segmento_a,1,8)||lpad(vr_nrseq_reglote_a_b,5,0)||Substr(vr_segmento_a,14,237);
          
          /* Atualiza o código de retorno no segmento a*/
          vr_segmento_a:= Substr(vr_segmento_a,1,238)||vr_codcnabret;
          /* Atualiza o numero sequencial do arquivo no segmento a*/
          vr_segmento_a:= Substr(vr_segmento_a,1,154)||LPad(rw_segret.nrseq_arquivo,8,'0')||Substr(vr_segmento_a,163,78);
          --
          gene0002.pc_escreve_xml(vr_arq_retorno,vr_texto_arq_retorno,vr_segmento_a||chr(10));
        END IF;                   
        
      END IF;   

   END LOOP;
   --
   IF vr_qt_reg_conta > 0 THEN
     --Gerar informações do Trailer da última Conta 
     pc_gerar_trailer(vr_nrseq_arq_ted);
     --
     gene0002.pc_escreve_xml(vr_arq_retorno,vr_texto_arq_retorno,vr_trailer_5||chr(10));
     gene0002.pc_escreve_xml(vr_arq_retorno,vr_texto_arq_retorno,vr_trailer_9,True);        
     -- Criar registro de retorno
     BEGIN
        vr_nmarquivo_ret:= 'TED_'||LPAD(vr_nrdconta,8,0)||'_MOV'||TO_CHAR(vr_dtretorno,'DDMMYYYY')||'.RET';
        INSERT INTO tbtransf_arquivo_ted (nrseq_arq_ted,   
                                         nmarquivo, 
                                         nrseq_arquivo,
                                         nrdconta,    
                                         cdcooper, 
                                         dtgeracao, 
                                         dsarquivo,
                                         idtipoarq)
                                 values (null , 
                                         vr_nmarquivo_ret,             
                                         vr_nr_seq_segret,
                                         vr_nrdconta, 
                                         vr_cdcooper,   
                                         sysdate, 
                                         vr_arq_retorno,
                                         2 /*Segundo arquivo de retorno*/);     
       --
     EXCEPTION
       WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir dados na tbtransf_arquivo_ted segundo arquivo: '||sqlerrm;
          RAISE vr_exc_erro;
     END;  
     -- Fechar arquivo de retorno 
     -- Liberando a memoria alocada pro CLOB
     dbms_lob.close(vr_arq_retorno);
     dbms_lob.freetemporary(vr_arq_retorno);   
     --
   END IF;
   COMMIT;
   --
   DECLARE
     vr_aux_dsdemail VARCHAR2(1000);
     vr_aux_dscorpo  VARCHAR2(1000); 
   BEGIN

     vr_aux_dsdemail:= gene0001.fn_param_sistema('CRED',0,'EMAIL_RETORNO_TEDS');
     vr_aux_dscorpo := 'Informamos que o arquivo retorno consolidado foi disponibilizado para download na tela UPPGTO > Opção E.';
     --
     pr_cdcritic     := null;
     pr_dscritic     := null;
     --
     -- Enviar Email para o responsavel
    gene0003.pc_solicita_email(pr_cdcooper        => 3
                              ,pr_cdprogra        => 'UPPGTO'
                              ,pr_des_destino     => vr_aux_dsdemail
                              ,pr_des_assunto     => 'Arquivo Retorno – TED e Transferências'
                              ,pr_des_corpo       => vr_aux_dscorpo
                              ,pr_des_anexo       => ''
                              ,pr_flg_enviar      => 'S'
                              ,pr_flg_log_batch   => 'N' 
                              ,pr_des_erro        => vr_dscritic);
     -- Se ocorreu erro
     IF trim(vr_dscritic) IS NOT NULL THEN
       NULL;
     END IF;
     COMMIT;
  END;
         
EXCEPTION
  WHEN vr_exc_erro THEN
    Rollback;
    pr_dscritic := vr_dscritic;
    --
    CECRED.pc_log_programa(pr_dstiplog  => 'E'
                      ,pr_cdprograma    => 'PGTA0001'
                      ,pr_cdcooper      => 3
                      ,pr_tpexecucao    => 2 
                      ,pr_tpocorrencia  => 2
                      ,pr_cdcriticidade => 3
                      ,pr_cdmensagem    => null
                      ,pr_dsmensagem    => pr_dscritic
                      ,pr_idprglog      => vr_idprglog
                      ,pr_nmarqlog      => NULL);
    --      
    CECRED.pc_internal_exception( pr_cdcooper => 3 ,pr_compleme => pr_dscritic );
    --
  WHEN OTHERS THEN
    Rollback;
    -- Monta mensagem de erro
    pr_dscritic := 'Erro em pc_gerar_seg_arquivo_retorno: ' || SQLERRM;
    --
    CECRED.pc_log_programa(pr_dstiplog  => 'E'
                      ,pr_cdprograma    => 'PGTA0001'
                      ,pr_cdcooper      => 3
                      ,pr_tpexecucao    => 2 
                      ,pr_tpocorrencia  => 2
                      ,pr_cdcriticidade => 3
                      ,pr_cdmensagem    => null
                      ,pr_dsmensagem    => pr_dscritic
                      ,pr_idprglog      => vr_idprglog
                      ,pr_nmarqlog      => NULL);
    --                   
    CECRED.pc_internal_exception( pr_cdcooper => 3 
                                 ,pr_compleme => pr_dscritic );   
end pc_gerar_seg_arquivo_retorno;


END PGTA0001;
/
