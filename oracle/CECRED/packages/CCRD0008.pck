CREATE OR REPLACE PACKAGE CECRED.CCRD0008 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CCRD0008
  --  Sistema  : Impressão de Termos de Adesão
  --  Sigla    : CCRD
  --  Autor    : Paulo Roberto da Silva (Supero)
  --  Data     : março/2018.                   Ultima atualizacao: 09/03/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas para impressão de termos de adesão
  --
  -- Alteracoes:
  --
  --------------------------------------------------------------------------------------------------------------
                                     
  -- Rotina para geração do Termo de Adesão PF
  PROCEDURE pc_impres_termo_adesao_pf(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     ,pr_nmarquiv IN VARCHAR2               --> Identificacao da sessao do usuario
                                     --------> OUT <--------
                                     ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros                           
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica

  -- Rotina para geração do Termo de Adesão PJ
  PROCEDURE pc_impres_termo_adesao_pj(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     ,pr_nmarquiv IN VARCHAR2               --> Identificacao da sessao do usuario
                                     --------> OUT <--------
                                     ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros                           
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica
                                     
  --> Rotina para geração do Termo de Adesão  - Ayllos Web
  PROCEDURE pc_impres_termo_adesao_pf_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> Número da Conta
                                         ,pr_nrctrcrd   IN crapcrd.nrctrcrd%TYPE  --> Contrato
                                         ,pr_dsiduser   IN VARCHAR2               --> Identificacao da sessao do usuario
                                         ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                         ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                         ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2);             --> Erros do processo

  PROCEDURE pc_impres_termo_adesao_pj_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> Número da Conta
                                         ,pr_nrctrcrd   IN crapcrd.nrctrcrd%TYPE  --> Contrato
                                         ,pr_dsiduser   IN VARCHAR2               --> Identificacao da sessao do usuario
                                         ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                         ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                         ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2);           --> Erros do processo

  --> Rotina para retornar o tipo de envio
  PROCEDURE pc_retorna_tipo_envio(pr_nrdconta   IN crapass.nrdconta%TYPE  --> Número da Conta
                                 ,pr_nrctrcrd   IN crapcrd.nrctrcrd%TYPE  --> Contrato
                                 ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                 ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                 ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);             --> Erros do processo

END CCRD0008;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CCRD0008 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CCRD0008
  --  Sistema  : Impressão de Termos de Adesão
  --  Sigla    : CCRD
  --  Autor    : Paulo Roberto da Silva (Supero)
  --  Data     : março/2018.                   Ultima atualizacao: 27/06/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas para impressão de termos de adesão
  --
  -- Alteracoes: 27/06/2019 - Ajustar para passar o false na fn_data_extenso, assim garantimos
  --                          que iremos usar o ano correto na data por extenso (Lucas Ranghetti INC0017300)
  ---------------------------------------------------------------------------------------------------------------

  --> Armazenar dados do contrato
  TYPE typ_rec_dados_ctr 
       IS RECORD (nrctrcrd crapcrd.nrctrcrd%TYPE, --Nr Contrato
                  cdagenci crapage.cdagenci%TYPE, --Código PA
                  nmresage crapage.nmresage%TYPE, --Posto Atendimento
                  nrdconta crapass.nrdconta%TYPE, --Conta Corrente
                  nmresadm crapadc.nmresadm%TYPE,--Tipo Cartão CECRED
                  nmprimtl crapass.nmprimtl%TYPE, --Nome Completo
                  dsendere crapenc.dsendere%TYPE, --Endereço
                  nrendere crapenc.nrendere%TYPE, --Número
                  nmbairro crapenc.nmbairro%TYPE, --Bairro
                  nmcidade crapenc.nmcidade%TYPE, --Cidade
                  cdufende crapenc.cdufende%TYPE, --UF Endereço
                  nrcepend crapenc.nrcepend%TYPE, --CEP				  
                  nmextcopcop crapcop.nmextcop%TYPE, --Nome Cooperativa
                  nrdocnpjcop crapcop.nrdocnpj%TYPE, --CNPJ Cooperativa
                  dsendcopcop crapcop.dsendcop%TYPE, --Endereço Cooperativa
                  nrcependcop crapcop.nrcepend%TYPE, --CEP Cooperativa
                  nmcidadecop crapcop.nmcidade%TYPE, --Cidade Cooperativa				  
                  nrcpfcgc VARCHAR2(100),         --CPF/CNPJ
                  razaosocial   VARCHAR2(200),    -- Razão Social
                  dtconstituicao  VARCHAR2(10), -- Data da Constituição
                  nmimpresso       VARCHAR2(200),   -- Nome Impresso
                  vlfaturamentoanual   crapjur.vlfatano%TYPE, -- Faturamento Anual
                  nmfantasia       VARCHAR2(200),    -- Nome Fantasia
                  nmtitcrd crawcrd.nmtitcrd%TYPE, --Nome Impresso Cartão
                  dtnasctl crapass.dtnasctl%TYPE, --Data Nascimento
                  nrdocttl crapttl.nrdocttl%TYPE, --Nr Identidade
                  cdorgao_expedidor tbgen_orgao_expedidor.cdorgao_expedidor%TYPE, --Órgão Expedidor
                  cdufdttl crapttl.cdufdttl%TYPE, --UF Identidade
                  dtemdttl crapttl.dtemdttl%TYPE, --Data Emissão Identidade
                  cdsexotl crapass.cdsexotl%TYPE, --Sexo
                  dssexotl VARCHAR2(1),           --Descrição Sexo
                  dsnatura crapttl.dsnatura%TYPE, --Naturalidade
                  dsnacion crapnac.dsnacion%TYPE, --Nacionalidade
                  rsestcvl gnetcvl.rsestcvl%TYPE, --Estado Civil
                  vrnrtere VARCHAR2(40),          --Nr Telefone Residencial
                  vrnrteco VARCHAR2(40),          --Nr Telefone Comercial
                  vrnrtece VARCHAR2(40),          --Nr Telefone Celular
                  vlrenda  crapttl.vlsalari%TYPE,   -- Renda
                  vllimsug crawcrd.vllimcrd%TYPE,   -- Limite de credito
                  vllimcon crawcrd.vllimcrd%TYPE,   -- Limite de credito
                  vllimest crawcrd.vllimcrd%TYPE,   -- Limite de credito
                  dsdadosSolicitacao VARCHAR2(500), -- Responsavel solicitação
                  dsdadosAprovacao VARCHAR2(500),  -- Responsavel aprovação
                  tpforma_pagamento VARCHAR2(100), -- Forma de pagamento
                  nmlocaldata      VARCHAR2(200),   -- Local e Data Assinatura
                  indspc           VARCHAR2(1),     -- Indicador se está no SPC
                  indserasa        VARCHAR2(1),     -- Indicador se está no SERASA   
                  nrdia_pagamento VARCHAR2(2),
                  nrcpftit        VARCHAR2(100),
                  cdgraupr crawcrd.cdgraupr%TYPE,    -- Dia de pagamento 
				  dsenderecoentrega VARCHAR2(250),  --Endereço em que foi entregue o cartão         
                  dsnovotermo VARCHAR2(1),          --Indicador ára utilização do Termo versão Novo
                  dsrepresentante VARCHAR2(500));   --Representante da Pessoa Jurídica
                  
  TYPE typ_tab_dados_ctr IS TABLE OF typ_rec_dados_ctr
       INDEX BY PLS_INTEGER;                
                  
  --> Armazenar dados das assinaturas
  TYPE typ_rec_assinaturas_ctr 
       IS RECORD (hraprovacao      tbcrd_aprovacao_cartao.hraprovacao%TYPE, -- Hora da assinatura
                  dtaprovacao      tbcrd_aprovacao_cartao.dtaprovacao%TYPE,    -- Data da assinatura
                  nmaprovador      tbcrd_aprovacao_cartao.nmaprovador%TYPE,  -- Nome da assinatura  
                  idaprovacao      tbcrd_aprovacao_cartao.idaprovacao%TYPE,
                  nrctrcrd         tbcrd_aprovacao_cartao.nrctrcrd%TYPE,
                  indtipo_senha    tbcrd_aprovacao_cartao.indtipo_senha%TYPE,
                  nrcpf            tbcrd_aprovacao_cartao.nrcpf%TYPE,
                  nmtextoassinatura VARCHAR2(4000),
                  nmtextoasssuperv  VARCHAR2(4000));
                                  
  TYPE typ_tab_assinaturas_ctr IS TABLE OF typ_rec_assinaturas_ctr
       INDEX BY PLS_INTEGER;
  
  --> Armazenar dados dos cartões adicionais
  TYPE typ_rec_cartoes_ctr 
       IS RECORD (nmpessoa tbcadast_pessoa.nmpessoa%TYPE, --NOME PESSOA
                  dtnascimento tbcadast_pessoa_fisica.dtnascimento%TYPE, --DATA NASCIMENTO
                  nrcpfcgc varchar2(50), --NR CPF
                  nrdocumento tbcadast_pessoa_fisica.nrdocumento%TYPE, --NR RG
                  nmtitcrd crawcrd.nmtitcrd%TYPE);  --NOME IMPRESSO NO CARTÃO
                   
  TYPE typ_tab_cartoes_ctr IS TABLE OF typ_rec_cartoes_ctr
       INDEX BY PLS_INTEGER;
       
  --> Rotina para buscar dados para impressao do Termo de Adesão PF
  PROCEDURE pc_obtem_dados_contrato (pr_cdcooper        IN crapcop.cdcooper%TYPE  --> Código da Cooperativa 
                                    ,pr_cdagenci        IN crapage.cdagenci%TYPE  --> Código da agencia
                                    ,pr_nrdcaixa        IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                    ,pr_cdoperad        IN crapope.cdoperad%TYPE  --> Código do Operador
                                    ,pr_idorigem        IN INTEGER                --> Identificador de Origem
                                    ,pr_nrdconta        IN crapass.nrdconta%TYPE  --> Número da Conta
                                    ,pr_nrctrlim        IN craplim.nrctrlim%TYPE  --> Contrato
                                    ,pr_nmdatela        IN craptel.nmdatela%TYPE
                                    ,pr_dstipopessoa    IN VARCHAR2               --> Tipo da Pessoa
                                    ,pr_tab_dados_ctr   OUT typ_tab_dados_ctr      --> Dados do contrato 
                                    ,pr_tab_crapavt     OUT cada0001.typ_tab_crapavt_58
                                    ,pr_tab_bens        OUT cada0001.typ_tab_bens    
                                    ,pr_tab_assinaturas_ctr OUT typ_tab_assinaturas_ctr                               
                                    ,pr_tab_cartoes_ctr OUT typ_tab_cartoes_ctr --CARTOES ADICIONAIS                          
                                    ,pr_cdcritic        OUT PLS_INTEGER            --> Código da crítica
                                    ,pr_dscritic        OUT VARCHAR2) IS           --> Descrição da crít
                                      
    /* .............................................................................

     Programa: pc_obtem_dados_contrato
     Sistema : Rotinas referentes ao Termo Adesão Cartão de Crédito
     Sigla   : CRED
     Autor   : Paulo Silva - Supero
     Data    : Março/2018.                    Ultima atualizacao: 27/06/2019

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para buscar dados para impressao do Termo de Adesão
     
     Alteracoes: 28/09/2018 - Ajuste para pegar valor numerico do limite de esteira 
                              no json. INC0023773 (Lombardi)
        				 20/02/2019 - Implementação de nova versão do Termo de Adesão do Cartão
				              			  de crédito. (PJ429 - Lucas - Supero)
                 27/06/2019 - Ajustar para passar o false na fn_data_extenso, assim garantimos
                              que iremos usar o ano correto na data por extenso (Lucas Ranghetti INC0017300)
    ..............................................................................*/

    ---------->> CURSORES <<--------
    --> Buscar dados associado PF
    CURSOR cr_crapttl (pr_nrcpfcgc crapttl.nrcpfcgc%TYPE)IS
      SELECT ttl.dsnatura,
             ttl.cdestcvl,
             ttl.vlsalari,
             ttl.dtnasttl,
             ttl.nrdocttl,
             ttl.tpdocttl,
             ttl.idorgexp,
             ttl.dtemdttl,
             ttl.cdufdttl,
             ttl.cdsexotl,
             decode(ttl.cdsexotl,1,'M',2,'F') dssexotl,
             ttl.cdnacion
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.nrcpfcgc = pr_nrcpfcgc;
    rw_crapttl cr_crapttl%ROWTYPE;
    
		-- cursor para encontrar dados do avalista de PJ
		CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%TYPE,
											 pr_nrdconta IN crapavt.nrdconta%TYPE,
											 pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE) IS
		SELECT avt.nrdconta
					,NVL(ttl.tpdocttl,avt.tpdocava) tpdocava
					,NVL(ttl.nmextttl,avt.nmdavali) nmdavali
					,NVL(ttl.cdestcvl,avt.cdestcvl) cdestcvl
					,avt.nrcpfcgc
					,NVL(ttl.nrdocttl,avt.nrdocava) nrdocava
					,NVL(ttl.idorgexp,avt.idorgexp) idorgexp
					,NVL(ttl.cdufdttl,avt.cdufddoc) cdufddoc
					,NVL(ttl.dtnasttl,avt.dtnascto) dtnascto
					,DECODE(NVL(ttl.cdsexotl,avt.cdsexcto),1,'2',2,'1','0') sexbancoob
					,NVL(ttl.inpessoa,DECODE(avt.inpessoa,0,1,avt.inpessoa)) inpessoa
			FROM crapttl ttl
				 , crapavt avt
		 WHERE ttl.cdcooper(+) = avt.cdcooper
			 AND ttl.nrdconta(+) = avt.nrdctato
			 AND avt.tpctrato = 6 -- Contrato pessoa juridica
			 AND avt.cdcooper = pr_cdcooper
			 AND avt.nrdconta = pr_nrdconta
			 AND avt.nrcpfcgc = pr_nrcpfcgc ;
		rw_crapavt cr_crapavt%ROWTYPE;
    
    --> Buscar dados cooperado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE )IS
      SELECT ass.nrcpfcgc,
             ass.nmprimtl,
             ass.cdagenci,
             ass.inpessoa,
             ass.nrdconta,
             ass.nrdocptl,
             ass.tpdocptl,
             ass.dtemdptl,
             ass.inadimpl,
             ass.idorgexp,
             ass.cdufdptl,
             ass.dtnasctl,
             ass.cdsexotl,
             decode(ass.cdsexotl,1,'M',2,'F') dssexotl,
             ass.cdnacion
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.nrdocnpj
            ,age.dsendcop
            ,age.nrendere
            ,age.nmbairro
            ,age.nmcidade
            ,age.cdufdcop
			      ,age.nrcepend
        FROM crapcop cop
            ,crapage age
       WHERE cop.cdcooper = pr_cdcooper
         AND age.cdcooper = cop.cdcooper
         AND age.cdagenci = (SELECT age.cdagenci
                               FROM crapass ass,
                                    crapage age
                              WHERE ass.cdagenci = age.cdagenci
                                AND age.cdcooper = ass.cdcooper
                                AND ass.nrdconta = pr_nrdconta
                                AND ass.cdcooper = pr_cdcooper);
    rw_crapcop cr_crapcop%ROWTYPE; 
    
    --> Buscar enderecos do cooperado.
    CURSOR cr_crapenc IS
      SELECT enc.nrdconta,
             enc.dsendere,
             enc.nrcepend,
             enc.nmbairro,
             enc.nmcidade,
             enc.nrendere,
             enc.cdufende,
             enc.tpendass
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta
         AND enc.idseqttl = 1
         AND enc.cdseqinc = 1;
    rw_crapenc cr_crapenc%ROWTYPE;
    
    --> buscar operador
    CURSOR cr_crapope(pr_cdcooper crapage.cdcooper%TYPE,
                      pr_cdoperad crapope.cdoperad%TYPE) IS
      SELECT ope.cdoperad
            ,ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad;
    rw_crapope_solicitante cr_crapope%ROWTYPE;
    rw_crapope_aprovador   cr_crapope%ROWTYPE;
    
    --> Buscar Dados agencia
    CURSOR cr_crapage(pr_cdcooper crapage.cdcooper%TYPE,
                      pr_cdagenci crapage.cdagenci%TYPE) IS
      SELECT age.nmcidade
            ,age.nmresage
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;
    
    --> Para pessoa juridica - faturamento unico cliente 
    CURSOR cr_crapjfn IS
      SELECT jfn.cdcooper,
             jfn.perfatcl,
             ((jfn.vlrftbru##1 + jfn.vlrftbru##2 + jfn.vlrftbru##3 +
               jfn.vlrftbru##4 + jfn.vlrftbru##5 + jfn.vlrftbru##6 +
               jfn.vlrftbru##7 + jfn.vlrftbru##8 + jfn.vlrftbru##9 +
               jfn.vlrftbru##10 + jfn.vlrftbru##11 + jfn.vlrftbru##12)/12) vlfatur
        FROM crapjfn jfn
       WHERE jfn.cdcooper = pr_cdcooper
         AND jfn.nrdconta = pr_nrdconta;
    rw_crapjfn cr_crapjfn%ROWTYPE;
         
    --> Buscar informações do contrato
    CURSOR cr_crawcrd IS
      SELECT crd.nrctrcrd
            ,crd.dtinsori
            ,crd.cdadmcrd
            ,crd.nmtitcrd
            ,crd.dddebito
            ,DECODE(crd.tpdpagto,
                    1,'Débito Automático (Total)',
                    2,'Débito Automático (Mínimo)',
                    3,'Fatura','') ds_forma_pagto
            ,DECODE(crd.tpdpagto,
                    1,'debitoTotal',
                    2,'debitoMinimo',
                    3,'fatura','') forma_pagto        
            ,crd.cdoperad
            ,crd.dtsolici
            ,crd.dtaprova
            ,crd.vllimcrd
            ,crd.dsjustif
            ,crd.cdgraupr
            ,crd.insitcrd
            ,crd.insitdec
            ,crd.nmextttl
            ,crd.dtnasccr
			      ,crd.nrcpftit
            ,crd.dtpropos
            ,crd.nrdoccrd
            ,crd.dsprotoc
            ,crd.dsendenv
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         and crd.nrdconta = pr_nrdconta
         and crd.nrctrcrd = pr_nrctrlim;
    rw_crawcrd cr_crawcrd%ROWTYPE;
    
    -- Busca historico de limite
    CURSOR cr_lim_contratado(prm_cdcooper    tbcrd_limite_atualiza.cdcooper%TYPE
                            ,prm_nrdconta    tbcrd_limite_atualiza.nrdconta%TYPE
                            ,prm_dsprotoc    tbcrd_limite_atualiza.dsprotocolo%TYPE) IS
      SELECT tbla.vllimite_anterior
      FROM tbcrd_limite_atualiza tbla
      WHERE cdcooper = pr_cdcooper
      AND   nrdconta = pr_nrdconta
      AND   dsprotocolo = prm_dsprotoc
      AND   rownum   = 1
      ORDER BY tbla.idatualizacao ASC;
      
    rw_lim_contratado    cr_lim_contratado%ROWTYPE;
    
    --> Busca Administradora
    CURSOR cr_crapadc (pr_cdadmcrd crapadc.cdadmcrd%TYPE) IS
      SELECT (adc.nmresadm) nmresadm
      FROM CRAPADC adc
           WHERE adc.cdcooper = pr_cdcooper
           AND adc.cdadmcrd = pr_cdadmcrd
           AND adc.insitadc = 0; --Normal  
    rw_crapadc cr_crapadc%ROWTYPE;
    
    --> Busca Nacionalidade
    CURSOR cr_crapnac (pr_cdnacion crapnac.cdnacion%TYPE) IS
      SELECT dsnacion
        FROM crapnac
       WHERE cdnacion = pr_cdnacion;
    rw_crapnac cr_crapnac%ROWTYPE;
    
    --> Busca Estado Civil
    CURSOR cr_gnetcvl (pr_cdestcvl gnetcvl.cdestcvl%TYPE) IS    
      SELECT rsestcvl
        FROM gnetcvl
       WHERE cdestcvl = pr_cdestcvl;
    rw_gnetcvl cr_gnetcvl%ROWTYPE;
    
    -- cursor para adquirir telefones do cooperado
    CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%TYPE,
                       pr_nrdconta IN craptfc.nrdconta%TYPE,
                       pr_tptelefo IN craptfc.tptelefo%TYPE) IS
    SELECT tfc.nrtelefo
          ,tfc.nrdddtfc
      FROM craptfc tfc
     WHERE tfc.cdcooper = pr_cdcooper
       AND tfc.nrdconta = pr_nrdconta
       AND tfc.tptelefo = pr_tptelefo;
       
    rw_craptfc_resid   cr_craptfc%ROWTYPE;   
    rw_craptfc_celu    cr_craptfc%ROWTYPE; 
    rw_craptfc_comer   cr_craptfc%ROWTYPE;
    
    --> Buscar dados assinatura
    CURSOR cr_tbaprc (pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE,
                      pr_nrctrcrd crawcrd.nrctrcrd%TYPE)IS
      SELECT idaprovacao,
             cdcooper,
             nrdconta,
             nrctrcrd,
             indtipo_senha,
             dtaprovacao,
             hraprovacao,
             nrcpf,
             nmaprovador,
             cdaprovador
        FROM tbcrd_aprovacao_cartao
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrcrd = pr_nrctrcrd;
    rw_tbaprc cr_tbaprc%ROWTYPE;
    
    --> Busca os dados da pessoa Juridica
    CURSOR cr_crapjur IS
      select jur.nmfansia
            ,jur.dtiniatv
            ,jur.vlfatano
        from crapjur jur
      where cdcooper = pr_cdcooper
      and   nrdconta = pr_nrdconta;
    rw_crapjur    cr_crapjur%ROWTYPE;   
    
    CURSOR cr_aciona_motor(pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE
                          ,pr_dsprotoc IN crawcrd.dsprotoc%TYPE) IS
      SELECT dsconteudo_requisicao
        FROM tbgen_webservice_aciona
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrprp = pr_nrctrcrd
         AND tpacionamento = 2
         AND cdoperad = 'MOTOR'
         AND tpproduto = 4
         AND dsprotocolo = pr_dsprotoc
       ORDER BY idacionamento ASC;
    vr_dsconteudo CLOB;
    
    CURSOR cr_envio_esteira(pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE) IS
      SELECT dsconteudo_requisicao
        FROM tbgen_webservice_aciona
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrprp = pr_nrctrcrd
         AND tpacionamento = 1
         AND (dsoperacao = 'ENVIO DA PROPOSTA PARA ANALISE DE CREDITO' OR
              dsoperacao = 'REENVIO DA PROPOSTA PARA ANALISE DE CREDITO')
         AND tpproduto = 4
       ORDER BY dhacionamento DESC;
       
    CURSOR cr_retorno_esteira(pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE) IS
      SELECT dsconteudo_requisicao
        FROM tbgen_webservice_aciona
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrprp = pr_nrctrcrd
         AND tpacionamento = 2
         AND dsoperacao LIKE '%RETORNO PROPOSTA%'
         AND tpproduto = 4
       ORDER BY dhacionamento DESC;
    
   CURSOR cr_tbgen_versao_termo(pr_cdcooper crapage.cdcooper%TYPE,
                                pr_dtadesao date ) IS
    SELECT DECODE(MAX(tbgen.dschave_versao), null, 'N', 'S') as dsnovotermo                                         
      FROM TBGEN_VERSAO_TERMO tbgen
     WHERE tbgen.cdcooper = pr_cdcooper
       AND pr_dtadesao > tbgen.dtinicio_vigencia
       AND upper(tbgen.dsnome_jasper) = upper(decode(pr_dstipopessoa, 'PF', 'termo_adesao_pf_novo.jasper', 'PJ', 'termo_adesao_pj_novo.jasper'));
    rw_tbgen_versao_termo cr_tbgen_versao_termo%rowtype;
    
    CURSOR cr_cartoes_adicionais(pr_cdcooper crapage.cdcooper%TYPE,
                                 pr_nrdconta crapass.nrdconta%TYPE) IS
     SELECT tbcadast_pessoa.nmpessoa, 
        tbcadast_pessoa_fisica.dtnascimento,
        tbcadast_pessoa.nrcpfcgc,
        tbcadast_pessoa_fisica.tpdocumento,
        tbcadast_pessoa_fisica.nrdocumento,
        crawcrd.nmtitcrd
   FROM crawcrd,
        tbcadast_pessoa,
        tbcadast_pessoa_fisica
  WHERE crawcrd.nrdconta = pr_nrdconta
    AND crawcrd.cdcooper = pr_cdcooper
    AND crawcrd.INSITCRD = 4
    AND tbcadast_pessoa.nrcpfcgc = crawcrd.nrcpftit
    AND tbcadast_pessoa_fisica.idpessoa = tbcadast_pessoa.idpessoa;
    rw_cartoes_adicionais  cr_cartoes_adicionais%rowtype;
    
   CURSOR cr_representante_legal(pr_nrdconta crapass.nrdconta%TYPE) IS
     SELECT '2.2 Representante legal:  '||tbcadast_pessoa.nmpessoa||', '||crapnac.dsnacion||', natural de '||mun2.dscidade||', '||
            gnetcvl.dsestcvl||', nascido em '||to_char(tbcadast_pessoa_fisica.dtnascimento, 'dd/mm/yyyy')||', inscrito(a) no CPF sob o nº '||gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => tbcadast_pessoa.nrcpfcgc, pr_inpessoa => 1)||
            ', com endereço residencial na Rua '||tbcadast_pessoa_endereco.nmlogradouro||', nº '||tbcadast_pessoa_endereco.nrlogradouro||
            ', bairro '||tbcadast_pessoa_endereco.nmbairro||', cidade de '||mun1.dscidade||'/'||mun1.cdestado||', CEP '||gene0002.fn_mask_cep(tbcadast_pessoa_endereco.nrcep) as dsrepresentante
        FROM  crapavt
              ,tbcadast_pessoa
              ,tbcadast_pessoa_fisica
              ,tbcadast_pessoa_endereco
              ,crapnac
              ,gnetcvl
              ,crapmun mun1
              ,crapmun mun2
       WHERE crapavt.nrdconta = pr_nrdconta
        AND tbcadast_pessoa.nrcpfcgc = crapavt.nrcpfcgc
        AND tbcadast_pessoa.idpessoa = tbcadast_pessoa_fisica.idpessoa
        AND tbcadast_pessoa_endereco.idpessoa = tbcadast_pessoa_fisica.idpessoa
        AND tbcadast_pessoa_endereco.tpendereco = 10
        AND tbcadast_pessoa_endereco.nrseq_endereco = 1      
        AND crapnac.cdnacion = tbcadast_pessoa_fisica.cdnacionalidade
        AND gnetcvl.cdestcvl = tbcadast_pessoa_fisica.cdestado_civil              
        AND tbcadast_pessoa_endereco.idcidade = mun1.idcidade
        AND mun2.idcidade = tbcadast_pessoa_fisica.cdnaturalidade
        AND crapavt.dtvalida > sysdate  
        AND ROWNUM = 1
        ORDER BY crapavt.progress_recid ASC;
        rw_representante_legal cr_representante_legal%rowtype;
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    vr_idxctr          PLS_INTEGER;
    vr_idxassinaturas  PLS_INTEGER;
    vr_idxcartoes  PLS_INTEGER;
    vr_tab_dados_ctr   typ_tab_dados_ctr;    
    
    vr_cdoedrep        tbgen_orgao_expedidor.cdorgao_expedidor%TYPE;
    vr_nmorgexp        tbgen_orgao_expedidor.nmorgao_expedidor%TYPE;
    vr_nrdocttl        crapttl.nrdocttl%TYPE;
    vr_localedata      VARCHAR2(200);
    vr_dt_constituicao VARCHAR2(10); -- Data da constituição da empresa (PJ)
    vr_vllimsug        NUMBER := 0;
    vr_vllimest        NUMBER := 0;
    vr_codcateg        VARCHAR2(4000);
    vr_retorno         VARCHAR2(4000);
    
    vr_dsDadosSolicitante    VARCHAR2(500);
    vr_dsDadosAprovador      VARCHAR2(500);
    
    vr_obj      cecred.json := json();
    vr_obj_alt  cecred.json := json();
    vr_obj_lst  json_list := json_list();
    vr_obj_crd  cecred.json := json();
    vr_obj_anl  cecred.json := json();
    
    vr_tab_crapavt       cada0001.typ_tab_crapavt_58;
    vr_tab_bens          cada0001.typ_tab_bens;
    vr_tab_erro          gene0001.typ_tab_erro;
    vr_tab_assinaturas_ctr  typ_tab_assinaturas_ctr;
    vr_tab_cartoes_ctr  typ_tab_cartoes_ctr;
    
    --variaveis de restrições
    vr_nrconbir          crapcbd.nrconbir%TYPE;
    vr_nrseqdet          crapcbd.nrseqdet%TYPE;
    vr_cdbircon          crapbir.cdbircon%TYPE;
    vr_dsbircon          crapbir.dsbircon%TYPE;
    vr_cdmodbir          crapmbr.cdmodbir%TYPE;
    vr_dsmodbir          crapmbr.dsmodbir%TYPE;
    vr_flsituac          VARCHAR2(10);
    
    vr_existe_cartao    VARCHAR2(1);
                                                 
  BEGIN
  
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN   
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;
    
    --> Buscar cooperado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN 
      CLOSE cr_crapass;
      vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;
    
    --> Buscar contrato
    OPEN cr_crawcrd;
    FETCH cr_crawcrd INTO rw_crawcrd;
    IF cr_crawcrd%NOTFOUND THEN
      CLOSE cr_crawcrd;
      vr_dscritic := 'Contrato nao encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crawcrd;
    END IF;
    
    --> Buscar ultimo historico de limite
    OPEN cr_lim_contratado(pr_cdcooper
                          ,pr_nrdconta
                          ,rw_crawcrd.dsprotoc);
    FETCH cr_lim_contratado INTO rw_lim_contratado;
    CLOSE cr_lim_contratado;
    
    IF rw_crapass.inpessoa = 1 THEN
      --> Buscar dados PF
      OPEN cr_crapttl(pr_nrcpfcgc => trunc(rw_crawcrd.nrcpftit));
      FETCH cr_crapttl INTO rw_crapttl;
      IF cr_crapttl%NOTFOUND THEN 
        CLOSE cr_crapttl;
        vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapttl;
      END IF;
      
      -- Buscar estado civil  
      OPEN cr_gnetcvl(pr_cdestcvl => rw_crapttl.cdestcvl);
      FETCH cr_gnetcvl INTO rw_gnetcvl;
      IF cr_gnetcvl%NOTFOUND THEN 
        CLOSE cr_gnetcvl;
        vr_dscritic := 'Estado civil nao cadastrado';
        --RAISE vr_exc_erro;
      ELSE
        CLOSE cr_gnetcvl;

      END IF;
      
      --> Buscar dados de Nacionalidade                           
      OPEN cr_crapnac(rw_crapttl.cdnacion); 
      FETCH cr_crapnac INTO rw_crapnac;    
      IF cr_crapnac%NOTFOUND THEN
        CLOSE cr_crapnac;
        vr_dscritic := 'Nacionalidade nao encontrada.';
        --RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapnac;
      END IF;
      -- Buscar telefone residencial
      OPEN cr_craptfc(pr_cdcooper
                     ,pr_nrdconta
                     ,1);
      FETCH cr_craptfc INTO rw_craptfc_resid;
      IF cr_craptfc%NOTFOUND THEN
        CLOSE cr_craptfc;
        vr_dscritic := 'Telefone residencial não encontrado.';
        --RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craptfc;
      END IF;
    END IF;
    
    --> Buscar endereço do cooperado
    OPEN cr_crapenc;
    FETCH cr_crapenc INTO rw_crapenc;
    IF cr_crapenc%NOTFOUND THEN
      CLOSE cr_crapenc;
      vr_dscritic := 'Endereco nao cadastrado.';
      --RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapenc;
    END IF;
    
    --> buscar dados do operador solicitante                                         
    OPEN cr_crapope(pr_cdcooper
                   ,rw_crawcrd.cdoperad); 
    FETCH cr_crapope INTO rw_crapope_solicitante;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_dscritic := 'Operador solicitante nao cadastrado.';
      --RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapope;

    END IF;
    
    --> buscar dados do operador aprovador                                         
    OPEN cr_crapope(pr_cdcooper
                   ,rw_crawcrd.cdoperad); 
    FETCH cr_crapope INTO rw_crapope_aprovador;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_dscritic := 'Operador aprovador nao cadastrado.';
      --RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapope;

    END IF;
    
    --> Buscar Dados agencia
    OPEN cr_crapage(pr_cdcooper => pr_cdcooper ,
                    pr_cdagenci => rw_crapass.cdagenci);
    FETCH cr_crapage INTO rw_crapage;
    CLOSE cr_crapage;        
    
    --> Para pessoa juridica - faturamento unico cliente 
    OPEN cr_crapjfn ;   
    FETCH cr_crapjfn INTO rw_crapjfn;
    CLOSE cr_crapjfn;
    
    --> Buscar dados da Administradora                           
    OPEN cr_crapadc(rw_crawcrd.cdadmcrd); 
    FETCH cr_crapadc INTO rw_crapadc;    
    IF cr_crapadc%NOTFOUND THEN
      CLOSE cr_crapadc;
      vr_dscritic := 'Administradora nao encontrada.';
      --RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapadc;
    END IF;
    
    -- Buscar telefone celular
    OPEN cr_craptfc(pr_cdcooper
                   ,pr_nrdconta
                   ,2);
    FETCH cr_craptfc INTO rw_craptfc_celu;
    IF cr_craptfc%NOTFOUND THEN
      CLOSE cr_craptfc;
      vr_dscritic := 'Telefone celular não encontrado.';
      --RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craptfc;
    END IF;
    -- Buscar telefone comercial
    OPEN cr_craptfc(pr_cdcooper
                   ,pr_nrdconta
                   ,3);
    FETCH cr_craptfc INTO rw_craptfc_comer;
    CLOSE cr_craptfc;  
    
  	OPEN cr_representante_legal(pr_nrdconta => rw_crapass.nrdconta);
    FETCH cr_representante_legal 
	 INTO rw_representante_legal;
    CLOSE cr_representante_legal;  
  
    -- Buscar assinatura
    -- Necessário verificação na tbcrd_aprovacao_cartao para garantir que a proposta foi assinada.
    BEGIN
      select 'S'
      INTO  vr_existe_cartao
      from  crawcrd crd
      where crd.nrcrcard <> '0'
      and   crd.insitcrd <> '0'
      AND NOT EXISTS (SELECT 1 FROM tbcrd_aprovacao_cartao tbac
                       WHERE tbac.nrctrcrd = pr_nrctrlim
                         AND tbac.nrdconta = pr_nrdconta
                         AND tbac.cdcooper = pr_cdcooper)
      AND   crd.nrdconta = pr_nrdconta
      AND   crd.nrctrcrd = pr_nrctrlim
      AND   crd.cdcooper = pr_cdcooper;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao verificar se o cartão já existe';
        RAISE vr_exc_erro;  
    END;
    
    IF vr_existe_cartao IS NOT NULL THEN
      vr_tab_assinaturas_ctr(1).nmtextoassinatura := 'Proposta assinada manualmente, termo pré impresso.';
    ELSE
      BEGIN
        vr_idxassinaturas := 0;
        FOR rw_tbaprc IN cr_tbaprc(pr_cdcooper
                                  ,pr_nrdconta
                                  ,rw_crawcrd.nrctrcrd) 
        LOOP
          vr_idxassinaturas := vr_tab_assinaturas_ctr.count() + 1;
          
          vr_tab_assinaturas_ctr(vr_idxassinaturas).hraprovacao := rw_tbaprc.hraprovacao;
          vr_tab_assinaturas_ctr(vr_idxassinaturas).dtaprovacao := rw_tbaprc.dtaprovacao;
          vr_tab_assinaturas_ctr(vr_idxassinaturas).nmaprovador := rw_tbaprc.nmaprovador;
          vr_tab_assinaturas_ctr(vr_idxassinaturas).idaprovacao := rw_tbaprc.idaprovacao;
          vr_tab_assinaturas_ctr(vr_idxassinaturas).nrctrcrd := rw_tbaprc.nrctrcrd;
          vr_tab_assinaturas_ctr(vr_idxassinaturas).indtipo_senha := rw_tbaprc.indtipo_senha;
          vr_tab_assinaturas_ctr(vr_idxassinaturas).nrcpf := rw_tbaprc.nrcpf;
          IF (TRIM(rw_tbaprc.cdaprovador) IS NULL) THEN
          vr_tab_assinaturas_ctr(vr_idxassinaturas).nmtextoassinatura := 'Assinado eletronicamente, mediante aposição de senha do '
                                                              ||rw_tbaprc.nmaprovador||', no dia '||to_char(rw_tbaprc.dtaprovacao,'DD/MM/YYYY')
                                                              ||' e na hora '||rw_tbaprc.hraprovacao;
          ELSE
            vr_tab_assinaturas_ctr(vr_idxassinaturas).nmtextoasssuperv := 'Solicitado pelo '||rw_tbaprc.cdaprovador||' - '
                                                              ||rw_tbaprc.nmaprovador||', no dia '||to_char(rw_tbaprc.dtaprovacao,'DD/MM/YYYY')
                                                              ||' e na hora '||rw_tbaprc.hraprovacao;
          END IF;
        END LOOP; 
      EXCEPTION
        WHEN no_data_found THEN
           vr_dscritic := 'Assinatura não encontrada.';
           vr_tab_assinaturas_ctr(1).nmtextoassinatura := 'Proposta assinada manualmente, termo pré impresso.';
           --RAISE vr_exc_erro;
      END;
      
      IF vr_idxassinaturas = 0 THEN
         vr_dscritic := 'Assinatura não encontrada.';
         vr_tab_assinaturas_ctr(1).nmtextoassinatura := 'Proposta assinada manualmente, termo pré impresso.';
         vr_tab_assinaturas_ctr(1).nmtextoasssuperv := '';
      END IF;
      
    END IF;
    
    -- Se for pessoa Juridica
    IF rw_crapass.inpessoa > 1 THEN
      OPEN cr_crapjur;
      FETCH cr_crapjur INTO rw_crapjur;
      IF cr_crapjur%NOTFOUND THEN
        CLOSE cr_crapjur;
        vr_dscritic := 'Dados da pessoa Juridica não encontrado.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapjur;
      END IF;
    END IF;  
    
    --Busca Cartoes Adicionais
    BEGIN
      vr_idxcartoes := 0;
      FOR rw_cartoes_adicionais IN cr_cartoes_adicionais(pr_cdcooper,
                                                         pr_nrdconta) 
      LOOP
        vr_idxcartoes := vr_tab_cartoes_ctr.count() + 1;      
        vr_tab_cartoes_ctr(vr_idxcartoes).nmpessoa := rw_cartoes_adicionais.nmpessoa;
        vr_tab_cartoes_ctr(vr_idxcartoes).dtnascimento := rw_cartoes_adicionais.dtnascimento;
        vr_tab_cartoes_ctr(vr_idxcartoes).nrcpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_cartoes_adicionais.nrcpfcgc,
                                                                        pr_inpessoa => 1);
        vr_tab_cartoes_ctr(vr_idxcartoes).nrdocumento := rw_cartoes_adicionais.nrdocumento;
        vr_tab_cartoes_ctr(vr_idxcartoes).nmtitcrd := rw_cartoes_adicionais.nmtitcrd;
      END LOOP;
    EXCEPTION
      WHEN no_data_found THEN
        vr_dscritic := 'Cartão adicional não encontrado.';
        --RAISE vr_exc_erro;
        IF vr_idxcartoes = 0 THEN
          vr_dscritic := 'Cartão adicional não encontrado.';
        END IF;
    END;
    
    
    
    -- Busca restrições 
    sspc0001.pc_busca_consulta_biro(pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_nrconbir => vr_nrconbir,
                                    pr_nrseqdet => vr_nrseqdet);
    
    --Verifica se esta no SPC/SERASA
    sspc0001.pc_verifica_situacao(pr_nrconbir => vr_nrconbir
                                 ,pr_nrseqdet => vr_nrseqdet
                                 ,pr_cdbircon => vr_cdbircon
                                 ,pr_dsbircon => vr_dsbircon
                                 ,pr_cdmodbir => vr_cdmodbir
                                 ,pr_dsmodbir => vr_dsmodbir
                                 ,pr_flsituac => vr_flsituac); 
    
    -- Monta o Local e Data
    vr_localedata := SUBSTR(rw_crapage.nmcidade,1,15) ||', ' || gene0005.fn_data_extenso(nvl(rw_crawcrd.dtinsori,rw_crawcrd.dtpropos),FALSE);
    
    IF rw_crapass.inpessoa = 1 THEN
      
      IF rw_crapttl.tpdocttl = 'CI' THEN
        vr_nrdocttl := rw_crapttl.nrdocttl;
      END IF;
      
      --Busca Órgão Expedidor
      cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crapttl.idorgexp, 
                                        pr_cdorgao_expedidor => vr_cdoedrep, 
                                        pr_nmorgao_expedidor => vr_nmorgexp, 
                                        pr_cdcritic          => vr_cdcritic, 
                                        pr_dscritic          => vr_dscritic);
                                        
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        vr_cdoedrep := 'NAO CADAST';
      END IF;
		ELSE
			--
			-- Representante do tipo OUTROS
			IF rw_crawcrd.cdgraupr = 9 THEN
				--
				--vr_dtnascto   := rw_crawcrd.dtnasccr;
				--vr_nrdocttl   := ' ';
				vr_nrdocttl   := rw_crawcrd.nrdoccrd;
				--vr_idorgexp   := NULL;
				--vr_cdufdttl   := ' ';
				--vr_nmdavali   := rw_crawcrd.nmtitcrd;                
				--vr_sexbancoob := 0;
				--vr_cdestcvl   := 0;
				--vr_nrcpfcgc   := rw_crawcrd.nrcpftit;
				--vr_inpessoa   := 1;
        --        
			ELSE
				-- Busca registro de representante para pessoa jurídica
				OPEN cr_crapavt(pr_cdcooper => pr_cdcooper,
												pr_nrdconta => pr_nrdconta,
												pr_nrcpfcgc => rw_crawcrd.nrcpftit);
				FETCH cr_crapavt INTO rw_crapavt;
					CLOSE cr_crapavt;

				-- Somente alimenta varíaveis com informações de Documento for Carteira de Identidade
				IF rw_crapavt.tpdocava = 'CI' THEN
					vr_nrdocttl := rw_crapavt.nrdocava;
					--vr_idorgexp := rw_crapavt.idorgexp;
					--vr_cdufdttl := rw_crapavt.cdufddoc;
					--vr_nmdavali := rw_crapavt.nmdavali;
				ELSE
					vr_nrdocttl := ' ';
					--vr_idorgexp := NULL;
					--vr_cdufdttl := ' ';
					--vr_nmdavali := rw_crapavt.nmdavali;
				END IF;

				-- Assume a data de nascimento
				--vr_dtnascto   := rw_crapavt.dtnascto;
				--vr_sexbancoob := rw_crapavt.sexbancoob;
				--vr_cdestcvl   := rw_crapavt.cdestcvl;
				--vr_nrcpfcgc   := rw_crapavt.nrcpfcgc;
				--vr_inpessoa   := rw_crapavt.inpessoa;
        --
			END IF;
			--
    END IF;  
    
    IF rw_crapjur.dtiniatv IS NOT NULL THEN
      vr_dt_constituicao := to_char(rw_crapjur.dtiniatv,'DD/MM/YYYY');
    END IF;
    
    --Valor Limite Sugerido
    OPEN cr_aciona_motor(pr_nrctrcrd => rw_crawcrd.nrctrcrd
                        ,pr_dsprotoc => rw_crawcrd.dsprotoc);
    FETCH cr_aciona_motor INTO vr_dsconteudo;
    IF cr_aciona_motor%FOUND THEN
        
      BEGIN
        vr_obj := json(vr_dsconteudo);

        vr_obj_anl := json(vr_obj.get('indicadoresGeradosRegra').to_char());
        
        vr_obj_lst := json_list(vr_obj_anl.get('sugestaoCartaoCecred').to_char());
          
        FOR vr_idx IN 1..vr_obj_lst.count() LOOP
          BEGIN
            vr_obj_crd := json( vr_obj_lst.get(vr_idx));
            vr_codcateg := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_crd.get('codigoCategoria').to_char(),'"'),'"'),'\u','\')));
              
            IF vr_codcateg = rw_crawcrd.cdadmcrd THEN
              vr_vllimsug := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_crd.get('vlLimite').to_char(),'"'),'"'),'\u','\')));
              vr_dsDadosAprovador := 'Motor de Crédito em '|| to_char(rw_crawcrd.dtinsori,'DD/MM/YYYY');
              EXIT;
            END IF;
          END;
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          vr_vllimsug := 0;
      END;
    END IF;
    CLOSE cr_aciona_motor;

    --Valor Limite Esteira
    IF rw_crawcrd.insitdec IN (1,3,8) and rw_crawcrd.insitcrd !=4 THEN
      OPEN cr_envio_esteira(pr_nrctrcrd => rw_crawcrd.nrctrcrd);
      FETCH cr_envio_esteira INTO vr_dsconteudo;
      IF cr_envio_esteira%FOUND THEN
        vr_obj := json(vr_dsconteudo);
        
        IF vr_obj.exist('valor') THEN
          vr_vllimest := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('valor').get_number,'"'),'"'),'\u','\')));
          vr_dsDadosAprovador := 'Esteira de Crédito em '|| to_char(rw_crawcrd.dtaprova,'DD/MM/YYYY');
        ELSIF vr_obj.exist('dadosAtualizados') THEN
          vr_obj_alt := json(vr_obj.get('dadosAtualizados'));
          IF vr_obj_alt.exist('valor') THEN
            vr_vllimest := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_alt.get('valor').get_number,'"'),'"'),'\u','\')));
            vr_dsDadosAprovador := 'Esteira de Crédito em '|| to_char(rw_crawcrd.dtaprova,'DD/MM/YYYY');
          END IF;
        END IF;
      
        OPEN cr_retorno_esteira(pr_nrctrcrd => rw_crawcrd.nrctrcrd);
        FETCH cr_retorno_esteira INTO vr_dsconteudo;
        IF cr_retorno_esteira%FOUND THEN
          vr_obj := json(vr_dsconteudo);
          
          IF vr_obj.exist('insitapr') THEN
            vr_retorno := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('insitapr').to_char(),'"'),'"'),'\u','\')));
          END IF;
          
          IF vr_retorno = '4' THEN
            -- retorno de rafazer na esteira com isso mostra que esta em analise
            vr_dsDadosAprovador := 'Em análise pela Esteira.';  
          ELSIF vr_retorno <> '1' THEN
            vr_vllimest := NULL;
            vr_dsDadosAprovador := null;
          END IF;
        ELSE
          vr_dsDadosAprovador := 'Em análise pela Esteira.';
        END IF;
        CLOSE cr_retorno_esteira;
      END IF;
      CLOSE cr_envio_esteira;
    ELSIF rw_crawcrd.insitdec=3 and rw_crawcrd.insitcrd = 4 THEN
      -- sempre que o cartao estiver em uso o limite esteira sera o mesmo
      -- solucao para nao gerar apresentar falha na reimpressao
      vr_vllimest := rw_crawcrd.vllimcrd;
      vr_dsDadosAprovador := 'Esteira de Crédito em '|| to_char(rw_crawcrd.dtaprova,'DD/MM/YYYY');
    END IF;
    
         
   -- Buscar vigência termo
    OPEN cr_tbgen_versao_termo(pr_cdcooper
                   ,nvl(rw_crawcrd.dtinsori,rw_crawcrd.dtpropos));
    FETCH cr_tbgen_versao_termo INTO rw_tbgen_versao_termo;
    CLOSE cr_tbgen_versao_termo;  
    
    -- Monta os dados do Aprovador
    IF rw_crawcrd.cdadmcrd IN (16,17) THEN --Débito
      --O mesmo da solicitação
      vr_dsDadosAprovador := rw_crawcrd.cdoperad ||' - '|| rw_crapope_aprovador.nmoperad ||' em '|| to_char(rw_crawcrd.dtpropos,'DD/MM/YYYY');
    END IF;
    
    -- Monta os dados do Solicitante
    vr_dsDadosSolicitante := rw_crawcrd.cdoperad ||' - '|| rw_crapope_solicitante.nmoperad ||' em '|| to_char(rw_crawcrd.dtpropos,'DD/MM/YYYY');
    
    --> Carregar temptable do contrato
    vr_idxctr := vr_tab_dados_ctr.count() + 1;
    --
    vr_tab_dados_ctr(vr_idxctr).nrctrcrd := rw_crawcrd.nrctrcrd;    --Nr Contrato
    vr_tab_dados_ctr(vr_idxctr).cdagenci := rw_crapass.cdagenci;    --Posto Atendimento
    vr_tab_dados_ctr(vr_idxctr).nmresage := rw_crapage.nmresage;    --Posto Atendimento
    vr_tab_dados_ctr(vr_idxctr).nrdconta := pr_nrdconta;            --Conta Corrente
    vr_tab_dados_ctr(vr_idxctr).nmresadm := rw_crawcrd.cdadmcrd;    --Tipo Cartão CECRED
    vr_tab_dados_ctr(vr_idxctr).nmtitcrd := rw_crawcrd.nmtitcrd;  --Nome Impresso Cartão
    vr_tab_dados_ctr(vr_idxctr).nrdocttl := vr_nrdocttl;          --Nr Identidade
    vr_tab_dados_ctr(vr_idxctr).cdorgao_expedidor := vr_cdoedrep; --Órgão Expedidor
    vr_tab_dados_ctr(vr_idxctr).cdufdttl := rw_crapttl.cdufdttl;  --UF Identidade
    vr_tab_dados_ctr(vr_idxctr).dtemdttl := rw_crapttl.dtemdttl;  --Data Emissão Identidade
    vr_tab_dados_ctr(vr_idxctr).cdsexotl := rw_crapttl.cdsexotl;  --Sexo
    vr_tab_dados_ctr(vr_idxctr).dssexotl := rw_crapttl.dssexotl;  --Descrição Sexo
    vr_tab_dados_ctr(vr_idxctr).dsnatura := rw_crapttl.dsnatura;  --Naturalidade
    vr_tab_dados_ctr(vr_idxctr).dsnacion := rw_crapnac.dsnacion;  --Nacionalidade
    vr_tab_dados_ctr(vr_idxctr).rsestcvl := rw_gnetcvl.rsestcvl;  --Estado Civil
    vr_tab_dados_ctr(vr_idxctr).nmprimtl := rw_crawcrd.nmextttl;  --Nome Completo
    

	vr_tab_dados_ctr(vr_idxctr).dsendere := rw_crapenc.dsendere;  --Endereço
	vr_tab_dados_ctr(vr_idxctr).nrendere := rw_crapenc.nrendere;  --Número
	vr_tab_dados_ctr(vr_idxctr).nmbairro := rw_crapenc.nmbairro;  --Bairro 
	vr_tab_dados_ctr(vr_idxctr).nmcidade := rw_crapenc.nmcidade;  --Cidade
	vr_tab_dados_ctr(vr_idxctr).cdufende := rw_crapenc.cdufende;  --UF Endereço
	vr_tab_dados_ctr(vr_idxctr).nrcepend := rw_crapenc.nrcepend;  --CEP	
	
	vr_tab_dados_ctr(vr_idxctr).nmextcopcop := rw_crapcop.nmextcop;  --Nome Cooperativa
	vr_tab_dados_ctr(vr_idxctr).nrdocnpjcop := rw_crapcop.nrdocnpj;  --CNPJ Cooperativa
	vr_tab_dados_ctr(vr_idxctr).dsendcopcop := rw_crapcop.dsendcop;  --Endereço Cooperativa
	vr_tab_dados_ctr(vr_idxctr).nrcependcop := rw_crapcop.nrcepend;  --CEP Cooperativa
	vr_tab_dados_ctr(vr_idxctr).nmcidadecop := rw_crapcop.nmcidade;  --Cidade Cooperativa	
    
    IF rw_crapass.inpessoa = 1 THEN
      vr_tab_dados_ctr(vr_idxctr).nrcpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crawcrd.nrcpftit,
                                                                        pr_inpessoa => rw_crapass.inpessoa);--CPF/CNPJ
      vr_tab_dados_ctr(vr_idxctr).vlrenda  := rw_crapttl.vlsalari;  --Rendimento, Salário
      vr_tab_dados_ctr(vr_idxctr).dtnasctl := rw_crapttl.dtnasttl;  --Data Nascimento
    ELSE
      vr_tab_dados_ctr(vr_idxctr).razaosocial :=rw_crapass.nmprimtl;  -- Razão Social
      vr_tab_dados_ctr(vr_idxctr).nrcpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                                                      pr_inpessoa => rw_crapass.inpessoa);--CPF/CNPJ
      vr_tab_dados_ctr(vr_idxctr).nmfantasia := rw_crapjur.nmfansia;  -- Nome fantasia
      vr_tab_dados_ctr(vr_idxctr).dtconstituicao := vr_dt_constituicao;    -- Data da Constituição
      vr_tab_dados_ctr(vr_idxctr).nmimpresso := rw_crawcrd.nmtitcrd;  -- Nome impresso do PJ
      vr_tab_dados_ctr(vr_idxctr).vlfaturamentoanual := rw_crapjur.vlfatano;      -- Faturamento atual
      vr_tab_dados_ctr(vr_idxctr).vlrenda  := rw_crapjfn.vlfatur;     -- Rendimento, Salário
      vr_tab_dados_ctr(vr_idxctr).dtnasctl := rw_crawcrd.dtnasccr;  --Data Nascimento
    END IF;
    
    vr_tab_dados_ctr(vr_idxctr).vrnrtere := rw_craptfc_resid.nrdddtfc ||' '|| rw_craptfc_resid.nrtelefo;          --Nr Telefone Residencial
    vr_tab_dados_ctr(vr_idxctr).vrnrteco := rw_craptfc_comer.nrdddtfc ||' '|| rw_craptfc_comer.nrtelefo;          --Nr Telefone Comercial
    vr_tab_dados_ctr(vr_idxctr).vrnrtece := rw_craptfc_celu.nrdddtfc ||' '||  rw_craptfc_celu.nrtelefo;  
             --Nr Telefone Celular
    vr_tab_dados_ctr(vr_idxctr).vllimsug := vr_vllimsug;                        -- Limite de credito sugerido
    
    IF rw_lim_contratado.vllimite_anterior IS NULL THEN
       vr_tab_dados_ctr(vr_idxctr).vllimcon := rw_crawcrd.vllimcrd;                -- Limite de credito contratado
    ELSE
      vr_tab_dados_ctr(vr_idxctr).vllimcon := rw_lim_contratado.vllimite_anterior;                -- Limite de credito contratado
    END IF;
    
    vr_tab_dados_ctr(vr_idxctr).vllimest := vr_vllimest;                        -- Limite de credito esteira
    vr_tab_dados_ctr(vr_idxctr).nrcpftit := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crawcrd.nrcpftit,
                                                                      pr_inpessoa => 1);--CPF da proposta
    vr_tab_dados_ctr(vr_idxctr).dsdadosSolicitacao := vr_dsDadosSolicitante;    -- Operador Solicitante
    vr_tab_dados_ctr(vr_idxctr).dsdadosAprovacao := nvl(vr_dsDadosAprovador, ' ');       -- Operador Aprovador
    vr_tab_dados_ctr(vr_idxctr).tpforma_pagamento := rw_crawcrd.forma_pagto;    -- Forma de pagamento
    vr_tab_dados_ctr(vr_idxctr).nrdia_pagamento := rw_crawcrd.dddebito;         -- Dia de pagamento
    vr_tab_dados_ctr(vr_idxctr).nmlocaldata := vr_localedata;                   -- Local e Data da Assinatura    
    vr_tab_dados_ctr(vr_idxctr).cdgraupr := rw_crawcrd.cdgraupr;                --Representante Outros
    
    IF rw_crapass.inadimpl = 1 OR (nvl(vr_flsituac,'N') = 'S' AND UPPER(vr_dsbircon) = 'SPC') THEN
      vr_tab_dados_ctr(vr_idxctr).indspc := 'S';
    ELSE
      vr_tab_dados_ctr(vr_idxctr).indspc := 'N';
    END IF;
    
    IF nvl(vr_flsituac,'N') = 'S' THEN
      IF UPPER(vr_dsbircon) = 'SERASA' THEN
        vr_tab_dados_ctr(vr_idxctr).indserasa := 'S';
      ELSE
        vr_tab_dados_ctr(vr_idxctr).indserasa := 'N';
      END IF;
    ELSE
      vr_tab_dados_ctr(vr_idxctr).indserasa := 'N';
    END IF;  
       
	  IF TRIM(rw_crawcrd.dsendenv) IS NOT NULL THEN
        vr_tab_dados_ctr(vr_idxctr).dsenderecoentrega := rw_crawcrd.dsendenv;       --Endereço de envio definido na criação da prosta
    ELSE
        vr_tab_dados_ctr(vr_idxctr).dsenderecoentrega := rw_crapcop.dsendcop || ', ' || rw_crapcop.nrendere || ' - ' || rw_crapcop.nmbairro || ' - ' || rw_crapcop.nmcidade || ' - ' || rw_crapcop.cdufdcop || ' - CEP: ' || rw_crapcop.nrcepend;
    END IF;
    
	vr_tab_dados_ctr(vr_idxctr).dsnovotermo := rw_tbgen_versao_termo.dsnovotermo;
	vr_tab_dados_ctr(vr_idxctr).dsrepresentante := rw_representante_legal.dsrepresentante;
	
    -- Se for pessoa Juridica
    IF rw_crapass.inpessoa > 1 THEN
    
      --Busca representantes/procuradores
      cada0001.pc_busca_dados_58(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_nrdcaixa => pr_nrdcaixa
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_nmdatela => pr_nmdatela
                                ,pr_idorigem => pr_idorigem
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_idseqttl => 0
                                ,pr_flgerlog => FALSE
                                ,pr_cddopcao => 'C'
                                ,pr_nrdctato => 0
                                ,pr_nrcpfcto => 0
                                ,pr_nrdrowid => NULL
                                ,pr_tab_crapavt => vr_tab_crapavt
                                ,pr_tab_bens => vr_tab_bens
                                ,pr_tab_erro => vr_tab_erro
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
                               
    END IF;
    
    --> Retornar dados encontrados
    pr_tab_dados_ctr  := vr_tab_dados_ctr; -- Dados do cooperado
    pr_tab_crapavt    := vr_tab_crapavt;
    pr_tab_bens       := vr_tab_bens;
    pr_tab_assinaturas_ctr := vr_tab_assinaturas_ctr;
    pr_tab_cartoes_ctr := vr_tab_cartoes_ctr;
    
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao buscar dados para impressao: ' || SQLERRM, chr(13)),chr(10));   
  END pc_obtem_dados_contrato;
  
  -- Rotina para geração do Termo de Adesão PF
  PROCEDURE pc_impres_termo_adesao_pf(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     ,pr_nmarquiv IN VARCHAR2               --> Identificacao da sessao do usuario
                                     --------> OUT <--------
                                     ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros                           
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .............................................................................

     Programa: pc_impres_termo_adesao_pf
     Sistema : Rotinas referentes ao cartão de crédito
     Sigla   : CRED
     Autor   : Paulo Silva - Supero
     Data    : Março/2018.                    Ultima atualizacao: 28/11/2018

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para geração do Termo de Adesão PF
     
     Alteracoes: 28/11/2018 - PJ345 Ajustado o nome do arquivo (Rafael Faria - Supero)
     
    ..............................................................................*/
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    vr_des_reto        VARCHAR2(100);
    vr_tab_erro        GENE0001.typ_tab_erro;
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_dsorigem        craplgm.dsorigem%TYPE;
    vr_dstransa        craplgm.dstransa%TYPE := 'Impressao do termo de adesao PF do carta de credito Ailos';
    vr_nrdrowid        ROWID;

    vr_localdata       VARCHAR2(200);
    vr_localdatasup    VARCHAR2(200);
    
    vr_idseqttl        crapttl.idseqttl%TYPE;
    
    vr_dsdireto        VARCHAR2(4000);
    vr_nmendter        VARCHAR2(4000);     
    vr_dscomand        VARCHAR2(4000);
    vr_typsaida        VARCHAR2(100);    
    vr_nmarquiv        VARCHAR2(100);
    
    vr_tab_dados_ctr   typ_tab_dados_ctr;
    vr_tab_crapavt     cada0001.typ_tab_crapavt_58;
    vr_tab_bens        cada0001.typ_tab_bens;
    vr_tab_assinaturas_ctr  typ_tab_assinaturas_ctr;
    vr_tab_cartoes_ctr typ_tab_cartoes_ctr;
    
    vr_termo_jasper VARCHAR2(100);
    vr_relatorio_jasper NUMBER;
    
    vr_idxctr          PLS_INTEGER;
    vr_idxass          PLS_INTEGER;
    
    --vr_dsextmail       VARCHAR2(3);
    vr_dsmailcop       VARCHAR2(4000);
    vr_dsassmail       VARCHAR2(200);
    vr_dscormail       VARCHAR2(50);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    
    l_offset     NUMBER:=0;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN    
    --> Definir transação
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    END IF; 
    
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper);
                                         
    /* Caso o nome esteja vazio vamos setar algum valor para impedir 
       apagar todos os relatorios da pasta rl.
       Apesar disso, logamos para saber do ocorrido */
    vr_nmarquiv := pr_nmarquiv;
    IF trim(vr_nmarquiv) is null THEN
      vr_nmarquiv := dbms_random.string('A', 27);
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                           pr_cdoperad => pr_cdopecxa, 
                           pr_dscritic => 'Impressao do termo de adesao do cartao com nome vazio', 
                           pr_dsorigem => vr_dsorigem, 
                           pr_dstransa => vr_dstransa, 
                           pr_dttransa => trunc(SYSDATE),
                           pr_flgtrans =>  1, -- True
                           pr_hrtransa => gene0002.fn_busca_time, 
                           pr_idseqttl => vr_idseqttl, 
                           pr_nmdatela => pr_nmdatela, 
                           pr_nrdconta => pr_nrdconta, 
                           pr_nrdrowid => vr_nrdrowid);  
    END IF;
    
    vr_nmendter := vr_dsdireto ||'/rl/' || vr_nmarquiv;
    
    vr_dscomand := 'rm '||vr_nmendter||'* 2>/dev/null';
    
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF; 
    
    --> Montar nome do arquivo
    pr_nmarqpdf := vr_nmarquiv|| gene0002.fn_busca_time || '.pdf';
      
    --> Buscar dados para impressao do Termo de Adesão PF
    pc_obtem_dados_contrato (  pr_cdcooper        => pr_cdcooper  --> Código da Cooperativa 
                              ,pr_cdagenci        => pr_cdagecxa  --> Código da agencia
                              ,pr_nrdcaixa        => pr_nrdcaixa  --> Numero do caixa do operador
                              ,pr_cdoperad        => pr_cdopecxa  --> Código do Operador
                              ,pr_idorigem        => pr_idorigem  --> Identificador de Origem
                              ,pr_nrdconta        => pr_nrdconta  --> Número da Conta
                              ,pr_nrctrlim        => pr_nrctrlim  --> Contrato
                              ,pr_nmdatela        => pr_nmdatela  --> Nome da Tela
                              ,pr_dstipopessoa    => 'PF'         --> Tipo da Pessoa
                              ,pr_tab_dados_ctr   => vr_tab_dados_ctr    --> Dados do contrato 
                              ,pr_tab_crapavt     => vr_tab_crapavt     
                              ,pr_tab_bens        => vr_tab_bens  
                              ,pr_tab_assinaturas_ctr => vr_tab_assinaturas_ctr                                  
                              ,pr_tab_cartoes_ctr => vr_tab_cartoes_ctr                         
                              ,pr_cdcritic        => vr_cdcritic         --> Código da crítica
                              ,pr_dscritic        => vr_dscritic);       --> Descrição da crít
                                      
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;   
    
    
    vr_idxctr := vr_tab_dados_ctr.first;
    --> Verificar se retornou informacao
    IF vr_idxctr IS NULL THEN
      vr_dscritic := 'Nao foi possivel gerar a impressao.';
      RAISE vr_exc_erro;
    END IF;
    
    vr_idxass := vr_tab_assinaturas_ctr.first;
    --> Verificar se retornou informacao
    IF vr_idxass IS NULL THEN
      vr_dscritic := 'Termo não foi assinado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    
    vr_txtcompl := NULL;
   
    IF vr_tab_assinaturas_ctr(1).nmtextoasssuperv IS NOT NULL THEN
        vr_localdatasup := vr_tab_dados_ctr(vr_idxctr).nmlocaldata;
        vr_localdata    := ' ';
    ELSE
        vr_localdatasup := ' ';
        vr_localdata    := vr_tab_dados_ctr(vr_idxctr).nmlocaldata;
    END IF;
  
    --> INICIO
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>
                    <nmprimtl>'|| vr_tab_dados_ctr(vr_idxctr).nmprimtl ||'</nmprimtl>'); 
    
    pc_escreve_xml('<nrctrd>'||vr_tab_dados_ctr(vr_idxctr).nrctrcrd||'</nrctrd>'||
                   '<nomeCompleto>'|| vr_tab_dados_ctr(vr_idxctr).nmprimtl     ||'</nomeCompleto>'||     
				   
                   '<endere>'|| vr_tab_dados_ctr(vr_idxctr).dsendere ||'</endere>' ||
                   '<nrende>'|| vr_tab_dados_ctr(vr_idxctr).nrendere ||'</nrende>' ||
                   '<bairro>'|| vr_tab_dados_ctr(vr_idxctr).nmbairro ||'</bairro>' ||
                   '<cidade>'|| vr_tab_dados_ctr(vr_idxctr).nmcidade ||'</cidade>' ||
                   '<ufend>'|| vr_tab_dados_ctr(vr_idxctr).cdufende  ||'</ufend>' ||
                   '<cep>'|| gene0002.fn_mask_cep(vr_tab_dados_ctr(vr_idxctr).nrcepend)  || '</cep>' ||  
				   
                   '<cpf>'|| vr_tab_dados_ctr(vr_idxctr).nrcpfcgc                 ||'</cpf>'||
                   '<nomeImpresso>'|| vr_tab_dados_ctr(vr_idxctr).nmtitcrd ||'</nomeImpresso>'||
                   '<dataNascimento>'|| to_char(vr_tab_dados_ctr(vr_idxctr).dtnasctl,'DD/MM/RRRR') ||'</dataNascimento>'||
                   '<identidade>'|| vr_tab_dados_ctr(vr_idxctr).nrdocttl ||'</identidade>'|| 
                   '<postoAtendimento>'|| vr_tab_dados_ctr(vr_idxctr).cdagenci ||' - '|| vr_tab_dados_ctr(vr_idxctr).nmresage ||'</postoAtendimento>'||
                   '<contaCorrente>'||  gene0002.fn_mask_conta(vr_tab_dados_ctr(vr_idxctr).nrdconta) ||'</contaCorrente>'||
                   '<tpcartao>'|| vr_tab_dados_ctr(vr_idxctr).nmresadm ||'</tpcartao>'||
                   '<emissor>'|| vr_tab_dados_ctr(vr_idxctr).cdorgao_expedidor ||'</emissor>'||
                   '<uf>'|| vr_tab_dados_ctr(vr_idxctr).cdufdttl ||'</uf>'||
                   '<sexo>'|| vr_tab_dados_ctr(vr_idxctr).dssexotl ||'</sexo>'||
                   '<naturalidade>'|| vr_tab_dados_ctr(vr_idxctr).dsnatura ||'</naturalidade>'||
                   '<nacionalidade>'|| vr_tab_dados_ctr(vr_idxctr).dsnacion ||'</nacionalidade>'||
                   '<estadocivil>'|| vr_tab_dados_ctr(vr_idxctr).rsestcvl ||'</estadocivil>'||
                   '<foneRes>'|| vr_tab_dados_ctr(vr_idxctr).vrnrtere ||'</foneRes>'||
                   '<foneCom>'|| vr_tab_dados_ctr(vr_idxctr).vrnrteco ||'</foneCom>'||
                   '<celular>'|| vr_tab_dados_ctr(vr_idxctr).vrnrtece ||'</celular>'||
                   '<renda>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vlrenda,'FM99G999G990D00') ||'</renda>'||
                   '<limiteSugerido>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vllimsug,'FM99G999G990D00') ||'</limiteSugerido>'||
                   '<limiteContratado>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vllimcon,'FM99G999G990D00') ||'</limiteContratado>'||
                   '<limiteEsteira>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vllimest,'FM99G999G990D00') ||'</limiteEsteira>'||
                   '<dadosSolicitacao>'|| vr_tab_dados_ctr(vr_idxctr).dsdadosSolicitacao ||'</dadosSolicitacao>'||
                   '<dadosAprovacao>'|| vr_tab_dados_ctr(vr_idxctr).dsdadosAprovacao ||'</dadosAprovacao>'||
                   '<localEData>'|| vr_localdata ||'</localEData>'||
                   '<localEDataSup>'|| vr_localdatasup ||'</localEDataSup>'||
                   '<formaPagamento>'|| vr_tab_dados_ctr(vr_idxctr).tpforma_pagamento ||'</formaPagamento>'||
                   '<assinatura>'||vr_tab_assinaturas_ctr(1).nmtextoassinatura||'</assinatura>'||
                   '<asssuperv>'||vr_tab_assinaturas_ctr(1).nmtextoasssuperv||'</asssuperv>'||
                   '<spc>'|| vr_tab_dados_ctr(vr_idxctr).indspc ||'</spc>'||
                   '<serasa>'|| vr_tab_dados_ctr(vr_idxctr).indserasa ||'</serasa>'||
                   '<diaPagamento>'|| vr_tab_dados_ctr(vr_idxctr).nrdia_pagamento ||'</diaPagamento>'||
				   '<nmextcopcop>'|| vr_tab_dados_ctr(vr_idxctr).nmextcopcop ||'</nmextcopcop>'||
				   '<nrdocnpjcop>'|| vr_tab_dados_ctr(vr_idxctr).nrdocnpjcop ||'</nrdocnpjcop>'||
				   '<dsendcopcop>'|| vr_tab_dados_ctr(vr_idxctr).dsendcopcop ||'</dsendcopcop>'||
				   '<nrcependcop>'|| gene0002.fn_mask_cep(vr_tab_dados_ctr(vr_idxctr).nrcependcop) ||'</nrcependcop>'||
				   '<nmcidadecop>'|| vr_tab_dados_ctr(vr_idxctr).nmcidadecop ||'</nmcidadecop>'||
				   '<dsenderecoentrega>'|| vr_tab_dados_ctr(vr_idxctr).dsenderecoentrega ||'</dsenderecoentrega>');
               
          pc_escreve_xml('<cartoes>');
            FOR rindex IN 1..vr_tab_cartoes_ctr.count LOOP
              -- 
              pc_escreve_xml('<cartao>');
              pc_escreve_xml('<nomeCompleto>'||vr_tab_cartoes_ctr(rindex).nmpessoa||'</nomeCompleto>'||
                             '<nomeImpresso>'||vr_tab_cartoes_ctr(rindex).nmtitcrd||'</nomeImpresso>'||
                             '<cpf>'||vr_tab_cartoes_ctr(rindex).nrcpfcgc||'</cpf>'||
                             '<dataNascimento>'||to_char(vr_tab_cartoes_ctr(rindex).dtnascimento,'DD/MM/RRRR')||'</dataNascimento>'||
                             '<identidade>'||vr_tab_cartoes_ctr(rindex).nrdocumento||'</identidade>'||
                             '<tagCont>'||rindex||'</tagCont>');
              pc_escreve_xml('</cartao>'); 
              --
            END LOOP;
                      
          pc_escreve_xml('</cartoes>');
                    
    
    --> Descarregar buffer    
    pc_escreve_xml(' ',TRUE); 
    
    --> Descarregar buffer    
    pc_escreve_xml('</raiz>',TRUE); 
    
   loop exit when l_offset > dbms_lob.getlength(vr_des_xml);
   DBMS_OUTPUT.PUT_LINE (dbms_lob.substr( vr_des_xml, 254, l_offset) || '~');
   l_offset := l_offset + 255;
   end loop;
    
	 select decode(vr_tab_dados_ctr(vr_idxctr).dsnovotermo,
				 'S',
				 'termo_adesao_pf_novo.jasper',
				 'termo_adesao_pf.jasper'),
		  decode(vr_tab_dados_ctr(vr_idxctr).dsnovotermo, 'S', 777, 280)
	 into vr_termo_jasper, vr_relatorio_jasper
	 from dual;   
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => pr_cdprogra
                               , pr_dtmvtolt  => pr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/raiz'
                               , pr_dsjasper  => vr_termo_jasper
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 234
                               , pr_cdrelato  => vr_relatorio_jasper
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_dsextmail => NULL
                               , pr_dsmailcop => vr_dsmailcop
                               , pr_dsassmail => vr_dsassmail
                               , pr_dscormail => vr_dscormail
                               , pr_des_erro  => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF;        
    
    IF pr_idorigem = 5 THEN
      -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
      GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => NULL
                                  ,pr_nrdcaixa => NULL
                                  ,pr_nmarqpdf => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                                  ,pr_des_reto => vr_des_reto
                                  ,pr_tab_erro => vr_tab_erro);
      -- Se retornou erro
      IF NVL(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_erro; -- encerra programa
        END IF;
      END IF;

      -- Remover relatorio do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm '||vr_dsdireto ||'/rl/'||pr_nmarqpdf
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;        
    
    --> Gerar log de sucesso
    IF pr_flgerlog = 1 THEN
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                           pr_cdoperad => pr_cdopecxa, 
                           pr_dscritic => NULL, 
                           pr_dsorigem => vr_dsorigem, 
                           pr_dstransa => vr_dstransa, 
                           pr_dttransa => trunc(SYSDATE),
                           pr_flgtrans =>  1, -- True
                           pr_hrtransa => gene0002.fn_busca_time, 
                           pr_idseqttl => vr_idseqttl, 
                           pr_nmdatela => pr_nmdatela, 
                           pr_nrdconta => pr_nrdconta, 
                           pr_nrdrowid => vr_nrdrowid);
                             
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                pr_nmdcampo => 'nrctrlim', 
                                pr_dsdadant => NULL, 
                                pr_dsdadatu => pr_nrctrlim);
    END IF;
    
    COMMIT;
    
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
      
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => vr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrlim', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrlim);
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao gerar impressao do contrato: ' || SQLERRM, chr(13)),chr(10));   
  
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => vr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrlim', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrlim);
      END IF; 
      
  END pc_impres_termo_adesao_pf;
  
  -- Rotina para geração do Termo de Adesão PJ
  PROCEDURE pc_impres_termo_adesao_pj(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     ,pr_nmarquiv IN VARCHAR2               --> Identificacao da sessao do usuario
                                     --------> OUT <--------
                                     ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros                           
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .............................................................................

     Programa: pc_impres_termo_adesao_pj
     Sistema : Rotinas referentes ao cartão de crédito
     Sigla   : CRED
     Autor   : Carlos Lima - Supero
     Data    : Abril/2018.                    Ultima atualizacao: 28/11/2018

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para geração do Termo de Adesão PJ
     
     Alteracoes: 28/11/2018 - PJ345 Ajustado o nome do arquivo (Rafael Faria - Supero)
     
    ..............................................................................*/
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    vr_des_reto        VARCHAR2(100);
    vr_tab_erro        GENE0001.typ_tab_erro;
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_dsorigem        craplgm.dsorigem%TYPE;
    vr_dstransa        craplgm.dstransa%TYPE := 'Impressao do termo de adesao PJ do carta de credito Ailos';
    vr_nrdrowid        ROWID;

    vr_idseqttl        crapttl.idseqttl%TYPE;
    
    vr_dsdireto        VARCHAR2(4000);
    vr_nmendter        VARCHAR2(4000);     
    vr_dscomand        VARCHAR2(4000);
    vr_typsaida        VARCHAR2(100);    
    vr_nmarquiv        VARCHAR2(100);
    
    vr_tab_dados_ctr   typ_tab_dados_ctr;
    vr_tab_crapavt     cada0001.typ_tab_crapavt_58;
    vr_tab_bens        cada0001.typ_tab_bens;
    vr_tab_assinaturas_ctr  typ_tab_assinaturas_ctr;
    vr_tab_cartoes_ctr typ_tab_cartoes_ctr;
    
    vr_localdata       VARCHAR2(200);
    vr_localdatasup    VARCHAR2(200);
    
    vr_idxctr          PLS_INTEGER;
    vr_idxass          PLS_INTEGER;
    
    vr_termo_jasper VARCHAR2(100);
    vr_relatorio_jasper NUMBER;
    
    --vr_dsextmail       VARCHAR2(3);
    vr_dsmailcop       VARCHAR2(4000);
    vr_dsassmail       VARCHAR2(200);
    vr_dscormail       VARCHAR2(50);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    
    l_offset     NUMBER:=0;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN    
    --> Definir transação
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    END IF; 
    
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper);
                                         
    /* Caso o nome esteja vazio vamos setar algum valor para impedir 
       apagar todos os relatorios da pasta rl.
       Apesar disso, logamos para saber do ocorrido */
    vr_nmarquiv := pr_nmarquiv;
    IF trim(vr_nmarquiv) is null THEN
      vr_nmarquiv := dbms_random.string('A', 27);
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                           pr_cdoperad => pr_cdopecxa, 
                           pr_dscritic => 'Impressao do termo de adesao do cartao com nome vazio', 
                           pr_dsorigem => vr_dsorigem, 
                           pr_dstransa => vr_dstransa, 
                           pr_dttransa => trunc(SYSDATE),
                           pr_flgtrans =>  1, -- True
                           pr_hrtransa => gene0002.fn_busca_time, 
                           pr_idseqttl => vr_idseqttl, 
                           pr_nmdatela => pr_nmdatela, 
                           pr_nrdconta => pr_nrdconta, 
                           pr_nrdrowid => vr_nrdrowid);  
    END IF;
                                         
    vr_nmendter := vr_dsdireto ||'/rl/' || vr_nmarquiv;
    
    vr_dscomand := 'rm '||vr_nmendter||'* 2>/dev/null';
    
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF; 
    
    --> Montar nome do arquivo
    pr_nmarqpdf := vr_nmarquiv|| gene0002.fn_busca_time || '.pdf';
      
    --> Buscar dados para impressao do Termo de Adesão PF
    pc_obtem_dados_contrato (  pr_cdcooper        => pr_cdcooper  --> Código da Cooperativa 
                              ,pr_cdagenci        => pr_cdagecxa  --> Código da agencia
                              ,pr_nrdcaixa        => pr_nrdcaixa  --> Numero do caixa do operador
                              ,pr_cdoperad        => pr_cdopecxa  --> Código do Operador
                              ,pr_idorigem        => pr_idorigem  --> Identificador de Origem
                              ,pr_nrdconta        => pr_nrdconta  --> Número da Conta
                              ,pr_nrctrlim        => pr_nrctrlim  --> Contrato
                              ,pr_nmdatela        => pr_nmdatela  --> Nome da tela
                              ,pr_dstipopessoa    => 'PF'         --> Tipo da Pessoa                              
                              ,pr_tab_dados_ctr   => vr_tab_dados_ctr    --> Dados do contrato 
                              ,pr_tab_crapavt     => vr_tab_crapavt     
                              ,pr_tab_bens        => vr_tab_bens  
                              ,pr_tab_assinaturas_ctr => vr_tab_assinaturas_ctr                                       
                              ,pr_tab_cartoes_ctr => vr_tab_cartoes_ctr                                             
                              ,pr_cdcritic        => vr_cdcritic         --> Código da crítica
                              ,pr_dscritic        => vr_dscritic);          --> Descrição da crít
                                      
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;   
    
    
    vr_idxctr := vr_tab_dados_ctr.first;
    --> Verificar se retornou informacao
    IF vr_idxctr IS NULL THEN
      vr_dscritic := 'Nao foi possivel gerar a impressao.';
      RAISE vr_exc_erro;
    END IF;
    
    vr_idxass := vr_tab_assinaturas_ctr.first;
    --> Verificar se retornou informacao
    IF vr_idxass IS NULL THEN
      vr_dscritic := 'Termo não foi assinado.';
      RAISE vr_exc_erro;
    END IF;
   
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    
    vr_txtcompl := NULL;
   
    IF vr_tab_assinaturas_ctr(1).nmtextoasssuperv IS NOT NULL THEN
        vr_localdatasup := vr_tab_dados_ctr(vr_idxctr).nmlocaldata;
        vr_localdata    := ' ';
    ELSE
        vr_localdatasup := ' ';
        vr_localdata    := vr_tab_dados_ctr(vr_idxctr).nmlocaldata;
    END IF;
   
    --> INICIO
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>
                    <nmprimtl>'|| vr_tab_dados_ctr(vr_idxctr).nmprimtl ||'</nmprimtl>'); 
    
    pc_escreve_xml('<nrctrd>'||vr_tab_dados_ctr(vr_idxctr).nrctrcrd||'</nrctrd>'||
                   '<postoAtendimento>'|| vr_tab_dados_ctr(vr_idxctr).cdagenci ||' - '|| vr_tab_dados_ctr(vr_idxctr).nmresage ||'</postoAtendimento>'||
                   '<contaCorrente>'|| gene0002.fn_mask_conta(vr_tab_dados_ctr(vr_idxctr).nrdconta) ||'</contaCorrente>'||
                   '<razaoSocial>'|| vr_tab_dados_ctr(vr_idxctr).razaosocial ||'</razaoSocial>'||
                   '<cnpj>'|| vr_tab_dados_ctr(vr_idxctr).nrcpfcgc ||'</cnpj>'||
                   '<nomeFantasia>'|| vr_tab_dados_ctr(vr_idxctr).nmfantasia ||'</nomeFantasia>'||
                   '<dataConstituicao>'|| vr_tab_dados_ctr(vr_idxctr).dtconstituicao ||'</dataConstituicao>'||
                   '<nomeImpresso>'|| vr_tab_dados_ctr(vr_idxctr).nmimpresso ||'</nomeImpresso>'||
                   
                   '<endere>'|| vr_tab_dados_ctr(vr_idxctr).dsendere ||'</endere>' ||
                   '<nrende>'|| vr_tab_dados_ctr(vr_idxctr).nrendere ||'</nrende>' ||
                   '<bairro>'|| vr_tab_dados_ctr(vr_idxctr).nmbairro ||'</bairro>' ||
                   '<cidade>'|| vr_tab_dados_ctr(vr_idxctr).nmcidade ||'</cidade>' ||
                   '<ufend>'|| vr_tab_dados_ctr(vr_idxctr).cdufende  ||'</ufend>' ||
                   '<cep>'|| gene0002.fn_mask_cep(vr_tab_dados_ctr(vr_idxctr).nrcepend)  || '</cep>' ||  
                   
                   '<nmextcopcop>'|| vr_tab_dados_ctr(vr_idxctr).nmextcopcop ||'</nmextcopcop>'||
                   '<nrdocnpjcop>'|| vr_tab_dados_ctr(vr_idxctr).nrdocnpjcop ||'</nrdocnpjcop>'||
                   '<dsendcopcop>'|| vr_tab_dados_ctr(vr_idxctr).dsendcopcop ||'</dsendcopcop>'||
                   '<nrcependcop>'|| gene0002.fn_mask_cep(vr_tab_dados_ctr(vr_idxctr).nrcependcop) ||'</nrcependcop>'||
                   '<nmcidadecop>'|| vr_tab_dados_ctr(vr_idxctr).nmcidadecop ||'</nmcidadecop>'||
                                      
                   '<faturamentoAnual>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vlfaturamentoanual,'FM99G999G990D00') ||'</faturamentoAnual>'||
                   '<tipoCartao>'|| vr_tab_dados_ctr(vr_idxctr).nmresadm ||'</tipoCartao>'||
                   '<foneComercial>'|| vr_tab_dados_ctr(vr_idxctr).vrnrteco ||'</foneComercial>'||
                   '<foneCelular>'|| vr_tab_dados_ctr(vr_idxctr).vrnrtece ||'</foneCelular>'||
                   '<rendimentos>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vlrenda,'FM99G999G990D00') ||'</rendimentos>'||
                   '<limiteSugerido>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vllimsug,'FM99G999G990D00') ||'</limiteSugerido>'||
                   '<limiteContratado>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vllimcon,'FM99G999G990D00') ||'</limiteContratado>'||
                   '<limiteEsteira>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vllimest,'FM99G999G990D00') ||'</limiteEsteira>'||
                   '<formaPagamento>'|| vr_tab_dados_ctr(vr_idxctr).tpforma_pagamento ||'</formaPagamento>'||
                   '<dadosSolicitacao>'|| vr_tab_dados_ctr(vr_idxctr).dsdadosSolicitacao ||'</dadosSolicitacao>'||
                   '<dadosAprovacao>'|| vr_tab_dados_ctr(vr_idxctr).dsdadosAprovacao ||'</dadosAprovacao>'||
                   '<localEData>'|| vr_localdata ||'</localEData>'||
                   '<localEDataSup>'|| vr_localdatasup ||'</localEDataSup>'||
                   '<spc>'|| vr_tab_dados_ctr(vr_idxctr).indspc ||'</spc>'||
                   '<serasa>'|| vr_tab_dados_ctr(vr_idxctr).indserasa ||'</serasa>'||
                   '<diaPagamento>'|| vr_tab_dados_ctr(vr_idxctr).nrdia_pagamento ||'</diaPagamento>'||
                   '<cdgraupr>'|| vr_tab_dados_ctr(vr_idxctr).cdgraupr ||'</cdgraupr>'||
                   '<dsenderecoentrega>'|| vr_tab_dados_ctr(vr_idxctr).dsenderecoentrega ||'</dsenderecoentrega>'||
                   '<dsrepresentante>'|| vr_tab_dados_ctr(vr_idxctr).dsrepresentante||'</dsrepresentante>');
    pc_escreve_xml('<cartoes>');
      FOR rindex IN 1..vr_tab_cartoes_ctr.count LOOP
        -- 
        pc_escreve_xml('<cartao>');
        pc_escreve_xml('<nomeCompleto>'||vr_tab_cartoes_ctr(rindex).nmpessoa||'</nomeCompleto>'||
                       '<nomeImpresso>'||vr_tab_cartoes_ctr(rindex).nmtitcrd||'</nomeImpresso>'||
                       '<cpf>'||vr_tab_cartoes_ctr(rindex).nrcpfcgc||'</cpf>'||
                       '<dataNascimento>'||to_char(vr_tab_cartoes_ctr(rindex).dtnascimento,'DD/MM/RRRR')||'</dataNascimento>'||
                       '<identidade>'||vr_tab_cartoes_ctr(rindex).nrdocumento||'</identidade>'||
                       '<tagCont>'||rindex||'</tagCont>');
        pc_escreve_xml('</cartao>'); 
        --
      END LOOP;
                      
    pc_escreve_xml('</cartoes>');               
                     
    pc_escreve_xml('<portadores>');
    
    IF vr_tab_dados_ctr(vr_idxctr).cdgraupr = 9 THEN
      pc_escreve_xml('<portador>');
      pc_escreve_xml('<nomeCompleto>'||vr_tab_dados_ctr(vr_idxctr).nmprimtl||'</nomeCompleto>'||
                     '<nomeImpresso>'||vr_tab_dados_ctr(vr_idxctr).nmtitcrd||'</nomeImpresso>'||
                     '<cpf>'||vr_tab_dados_ctr(vr_idxctr).nrcpftit||'</cpf>'||
                     '<dataNascimento>'||to_char(vr_tab_dados_ctr(vr_idxctr).dtnasctl,'DD/MM/RRRR')||'</dataNascimento>'||
                     '<identidade>'||vr_tab_dados_ctr(vr_idxctr).nrdocttl||'</identidade>'||
                     '<emissor>'||vr_tab_dados_ctr(vr_idxctr).cdorgao_expedidor||'</emissor>'||
                     '<ufEmissao>'||vr_tab_dados_ctr(vr_idxctr).cdufdttl||'</ufEmissao>'||
                     '<tagCont>0</tagCont>');
      pc_escreve_xml('</portador>');
    ELSE
      FOR rindex IN 1..vr_tab_crapavt.count LOOP
        --
        IF gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_crapavt(rindex).nrcpfcgc,
                                     pr_inpessoa => 1) = vr_tab_dados_ctr(vr_idxctr).nrcpftit THEN
          pc_escreve_xml('<portador>');
          pc_escreve_xml('<nomeCompleto>'||vr_tab_crapavt(rindex).nmdavali||'</nomeCompleto>'||
                         '<nomeImpresso>'||vr_tab_crapavt(rindex).nmdavali||'</nomeImpresso>'||
                         '<cpf>'||vr_tab_crapavt(rindex).nrcpfcgc||'</cpf>'||
                         '<dataNascimento>'||to_char(vr_tab_crapavt(rindex).dtnascto,'DD/MM/RRRR')||'</dataNascimento>'||
                         '<identidade>'||vr_tab_crapavt(rindex).nrdocava||'</identidade>'||
                         '<emissor>'||vr_tab_crapavt(rindex).cdoeddoc||'</emissor>'||
                         '<ufEmissao>'||vr_tab_crapavt(rindex).cdufddoc||'</ufEmissao>'||
                         '<tagCont>'||rindex||'</tagCont>');
          pc_escreve_xml('</portador>');
        END IF;
        --
      END LOOP;
    END IF;
    
    pc_escreve_xml('</portadores>');
    
    pc_escreve_xml('<assinaturas>');
    
    FOR rindex IN 1..vr_tab_assinaturas_ctr.count LOOP
      pc_escreve_xml('<assinatura>');
      pc_escreve_xml('<txtassinatura>'||vr_tab_assinaturas_ctr(rindex).nmtextoassinatura||'</txtassinatura>');
      pc_escreve_xml('</assinatura>');
    END LOOP;
    
    IF vr_tab_assinaturas_ctr(1).nmtextoasssuperv IS NOT NULL THEN
        pc_escreve_xml('<asssuperv>'||vr_tab_assinaturas_ctr(1).nmtextoasssuperv||'</asssuperv>');

    END IF;
    
    pc_escreve_xml('</assinaturas>');
        
    --> Descarregar buffer    
    pc_escreve_xml(' ',TRUE); 
    
    --> Descarregar buffer    
    pc_escreve_xml('</raiz>',TRUE); 
    
   loop exit when l_offset > dbms_lob.getlength(vr_des_xml);
   DBMS_OUTPUT.PUT_LINE (dbms_lob.substr( vr_des_xml, 254, l_offset) || '~');
   l_offset := l_offset + 255;
   end loop;
    
   select decode(vr_tab_dados_ctr(vr_idxctr).dsnovotermo,
               'S',
               'termo_adesao_pj_novo.jasper',
               'termo_adesao_pj.jasper'),
        decode(vr_tab_dados_ctr(vr_idxctr).dsnovotermo, 'S', 780, 280)
   into vr_termo_jasper, vr_relatorio_jasper
   from dual;
   
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => pr_cdprogra
                               , pr_dtmvtolt  => pr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/raiz'
                               , pr_dsjasper  => vr_termo_jasper
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 234
                               , pr_cdrelato  => vr_relatorio_jasper
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_dsextmail => NULL
                               , pr_dsmailcop => vr_dsmailcop
                               , pr_dsassmail => vr_dsassmail
                               , pr_dscormail => vr_dscormail
                               , pr_des_erro  => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF;        
    
    IF pr_idorigem = 5 THEN
      -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
      GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => NULL
                                  ,pr_nrdcaixa => NULL
                                  ,pr_nmarqpdf => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                                  ,pr_des_reto => vr_des_reto
                                  ,pr_tab_erro => vr_tab_erro);
      -- Se retornou erro
      IF NVL(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_erro; -- encerra programa
        END IF;
      END IF;

      -- Remover relatorio do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm '||vr_dsdireto ||'/rl/'||pr_nmarqpdf||' 2>/dev/null'
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      
      -- Se retornou erro
      IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;        
    
    --> Gerar log de sucesso
    IF pr_flgerlog = 1 THEN
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                           pr_cdoperad => pr_cdopecxa, 
                           pr_dscritic => NULL, 
                           pr_dsorigem => vr_dsorigem, 
                           pr_dstransa => vr_dstransa, 
                           pr_dttransa => trunc(SYSDATE),
                           pr_flgtrans =>  1, -- True
                           pr_hrtransa => gene0002.fn_busca_time, 
                           pr_idseqttl => vr_idseqttl, 
                           pr_nmdatela => pr_nmdatela, 
                           pr_nrdconta => pr_nrdconta, 
                           pr_nrdrowid => vr_nrdrowid);
                             
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                pr_nmdcampo => 'nrctrlim', 
                                pr_dsdadant => NULL, 
                                pr_dsdadatu => pr_nrctrlim);
    END IF;
    
    COMMIT;
    
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
      
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => vr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrlim', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrlim);
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao gerar impressao do contrato: ' || SQLERRM, chr(13)),chr(10));   
  
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => vr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrlim', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrlim);
      END IF; 
      
  END pc_impres_termo_adesao_pj;
  
  --> Rotina para geração do Termo de Adesão PF  - Ayllos Web
  PROCEDURE pc_impres_termo_adesao_pf_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> Número da Conta
                                         ,pr_nrctrcrd   IN crapcrd.nrctrcrd%TYPE  --> Contrato
                                         ,pr_dsiduser   IN VARCHAR2               --> Identificacao da sessao do usuario
                                         ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                         ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                         ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_impres_termo_adesao_pf_web
    Sistema : Ayllos Web
    Autor   : Paulo Silva - Supero
    Data    : Março/2018                 Ultima atualizacao: 28/11/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para chamar as impressoes pelo Ayllos Web

    Alteracoes: 28/11/2018 - PJ345 Ajustado o nome do arquivo (Rafael Faria - Supero)
    ..............................................................................*/
    DECLARE
      -- Cursor da data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis gerais
      vr_nmarqpdf VARCHAR2(1000);

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
                              
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_gera_impressao'
                                ,pr_action => vr_nmeacao);

      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      pc_impres_termo_adesao_pf(pr_cdcooper => vr_cdcooper  --> Código da Cooperativa
                               ,pr_cdagecxa => vr_cdagenci  --> Código da agencia
                               ,pr_nrdcaixa => vr_nrdcaixa  --> Numero do caixa do operador
                               ,pr_cdopecxa => vr_cdoperad  --> Código do Operador
                               ,pr_nmdatela => vr_nmdatela  --> Nome da Tela
                               ,pr_idorigem => vr_idorigem  --> Identificador de Origem
                               ,pr_cdprogra => 'ATENDA'  --> Codigo do programa
                               ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data de Movimento
                               ,pr_nrctrlim => pr_nrctrcrd  --> Contrato
                               ,pr_flgerlog => 1            --> True 
                               ,pr_nmarquiv => pr_dsiduser
                               --------> OUT <--------
                               ,pr_nmarqpdf => vr_nmarqpdf       --> Retornar quantidad de registros                           
                               ,pr_cdcritic => vr_cdcritic       --> Código da crítica
                               ,pr_dscritic => vr_dscritic);     --> Descrição da crítica

      -- Se retornou erro
      IF NVL(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmarqpdf'
                            ,pr_tag_cont => vr_nmarqpdf
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_impres_termo_adesao_pf_web: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_impres_termo_adesao_pf_web;
  
  --> Rotina para geração do Termo de Adesão PJ  - Ayllos Web
  PROCEDURE pc_impres_termo_adesao_pj_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> Número da Conta
                                         ,pr_nrctrcrd   IN crapcrd.nrctrcrd%TYPE  --> Contrato
                                         ,pr_dsiduser   IN VARCHAR2               --> Identificacao da sessao do usuario
                                         ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                         ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                         ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_impres_termo_adesao_pj_web
    Sistema : Ayllos Web
    Autor   : Carlos Lima - Supero
    Data    : Abril/2018                 Ultima atualizacao: 28/11/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para chamar as impressoes pelo Ayllos Web

    Alteracoes: 28/11/2018 - PJ345 Ajustado o nome do arquivo (Rafael Faria - Supero)
    ..............................................................................*/
    DECLARE
      -- Cursor da data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis gerais
      vr_nmarqpdf VARCHAR2(1000);

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

      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_impres_termo_adesao_pj_web'
                                ,pr_action => vr_nmeacao);
      
      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      pc_impres_termo_adesao_pj(pr_cdcooper => vr_cdcooper  --> Código da Cooperativa
                               ,pr_cdagecxa => vr_cdagenci  --> Código da agencia
                               ,pr_nrdcaixa => vr_nrdcaixa  --> Numero do caixa do operador
                               ,pr_cdopecxa => vr_cdoperad  --> Código do Operador
                               ,pr_nmdatela => vr_nmdatela  --> Nome da Tela
                               ,pr_idorigem => vr_idorigem  --> Identificador de Origem
                               ,pr_cdprogra => 'ATENDA'  --> Codigo do programa
                               ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data de Movimento
                               ,pr_nrctrlim => pr_nrctrcrd  --> Contrato
                               ,pr_flgerlog => 1            --> True 
                               ,pr_nmarquiv => pr_dsiduser
                               --------> OUT <--------
                               ,pr_nmarqpdf => vr_nmarqpdf       --> Retornar quantidad de registros                           
                               ,pr_cdcritic => vr_cdcritic       --> Código da crítica
                               ,pr_dscritic => vr_dscritic);     --> Descrição da crítica

      -- Se retornou erro
      IF NVL(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmarqpdf'
                            ,pr_tag_cont => vr_nmarqpdf
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_impres_termo_adesao_pj_web: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_impres_termo_adesao_pj_web;
  
  --> Rotina para retornar o tipo de envio
  PROCEDURE pc_retorna_tipo_envio(pr_nrdconta   IN crapass.nrdconta%TYPE  --> Número da Conta
                                 ,pr_nrctrcrd   IN crapcrd.nrctrcrd%TYPE  --> Contrato
                                 ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                 ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                 ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_retorna_tipo_envio
    Sistema : Ayllos Web
    Autor   : Anderson - Supero
    Data    : Março/2019                 Ultima atualizacao: 00/00/0000

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para chamar as impressoes pelo Ayllos Web

    Alteracoes:
    ..............................................................................*/
    DECLARE
      
      CURSOR cr_tbcrd_endereco_entrega(pr_cdcooper crapage.cdcooper%TYPE,
                                       pr_nrdconta crapass.nrdconta%TYPE,
                                       pr_nrctrcrd crapcrd.nrctrcrd%TYPE) IS
      SELECT tbend.idtipoenvio
      FROM tbcrd_endereco_entrega tbend
          ,tbcrd_dominio_campo tbdom
       WHERE tbend.idtipoenvio = tbdom.cddominio
       AND tbdom.nmdominio = 'TPENDERECOENTREGA'
       AND tbend.cdcooper = pr_cdcooper
       AND tbend.nrdconta = pr_nrdconta
       AND tbend.nrctrcrd = pr_nrctrcrd;
       rw_tbcrd_endereco_entrega cr_tbcrd_endereco_entrega%rowtype;
    
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      
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
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      OPEN cr_tbcrd_endereco_entrega(pr_cdcooper => vr_cdcooper ,
                                     pr_nrdconta => pr_nrdconta,
                                     pr_nrctrcrd => pr_nrctrcrd);
      FETCH cr_tbcrd_endereco_entrega 
       INTO rw_tbcrd_endereco_entrega;
      CLOSE cr_tbcrd_endereco_entrega;
      
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'tipo_envio',
                             pr_tag_cont => rw_tbcrd_endereco_entrega.idtipoenvio,
                             pr_des_erro => vr_dscritic);
    

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_retorna_tipo_envio: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_retorna_tipo_envio;
END CCRD0008;
/
