CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_DSCTO_TIT IS
  /*---------------------------------------------------------------------------------------------------------------------

    Programa : TELA_ATENDA_DSCTO_TIT
    Sistema  : Ayllos Web
    Autor    : Paulo Penteado (GFT) / Gustavo Sene (GFT)
    Data     : Março - 2018                 Ultima atualizacao: 01/03/2018

    Dados referentes ao programa:

    Objetivo  : Centralizar rotinas relacionadas a tela Limite Desconto de Títulos dentro da ATENDA

    Alteracoes: 01/03/2018 - Criação (Paulo Penteado (GFT))
                02/03/2018 - Inclusão da Função    fn_em_contingencia_ibratan (Gustavo Sene (GFT))
                02/03/2018 - Inclusão da Procedure pc_confirmar_novo_limite   (Gustavo Sene (GFT))
                02/03/2018 - Inclusão da Procedure pc_negar_proposta          (Gustavo Sene (GFT))
                13/03/2018 - Inclusão da Procedure pc_renovar_lim_desc_titulo (Leonardo Oliveira - GFT)
                16/03/2018 - Inclusão do parâmetro de input 'crapldc' na procedure pc_renovar_lim_desc_titulo (Leonardo Oliveira - GFT)

  ---------------------------------------------------------------------------------------------------------------------*/

/*Tabela que armazena as informações da proposta de limite de desconto de titulo*/
type typ_reg_dados_proposta is record
     (nrdconta       craplim.nrdconta%type
     ,insitlim       craplim.insitlim%type
     ,dtpropos       craplim.dtpropos%type
     ,dtinivig       craplim.dtinivig%type
     ,inbaslim       craplim.inbaslim%type
     ,vllimite       craplim.vllimite%type
     ,nrctrlim       craplim.nrctrlim%type
     ,cdmotcan       craplim.cdmotcan%type
     ,dtfimvig       craplim.dtfimvig%type
     ,qtdiavig       craplim.qtdiavig%type
     ,cdoperad       craplim.cdoperad%type
     ,dsencfin##1    craplim.dsencfin##1%type
     ,dsencfin##2    craplim.dsencfin##2%type
     ,dsencfin##3    craplim.dsencfin##3%type
     ,flgimpnp       craplim.flgimpnp%type
     ,nrctaav1       craplim.nrctaav1%type
     ,nrctaav2       craplim.nrctaav2%type
     ,dsendav1##1    craplim.dsendav1##1%type
     ,dsendav1##2    craplim.dsendav1##2%type
     ,dsendav2##1    craplim.dsendav2##1%type
     ,dsendav2##2    craplim.dsendav2##2%type
     ,nmdaval1       craplim.nmdaval1%type
     ,nmdaval2       craplim.nmdaval2%type
     ,dscpfav1       craplim.dscpfav1%type
     ,dscpfav2       craplim.dscpfav2%type
     ,nmcjgav1       craplim.nmcjgav1%type
     ,nmcjgav2       craplim.nmcjgav2%type
     ,dscfcav1       craplim.dscfcav1%type
     ,dscfcav2       craplim.dscfcav2%type
     ,tpctrlim       craplim.tpctrlim%type
     ,qtrenova       craplim.qtrenova%type
     ,cddlinha       craplim.cddlinha%type
     ,dtcancel       craplim.dtcancel%type
     ,cdopecan       craplim.cdopecan%type
     ,cdcooper       craplim.cdcooper%type
     ,qtrenctr       craplim.qtrenctr%type
     ,cdopelib       craplim.cdopelib%type
     ,nrgarope       craplim.nrgarope%type
     ,nrinfcad       craplim.nrinfcad%type
     ,nrliquid       craplim.nrliquid%type
     ,nrpatlvr       craplim.nrpatlvr%type
     ,idquapro       craplim.idquapro%type
     ,nrperger       craplim.nrperger%type
     ,vltotsfn       craplim.vltotsfn%type
     ,flgdigit       craplim.flgdigit%type
     ,dtrenova       craplim.dtrenova%type
     ,tprenova       craplim.tprenova%type
     ,dsnrenov       craplim.dsnrenov%type
     ,nrconbir       craplim.nrconbir%type
     ,dtconbir       craplim.dtconbir%type
     ,inconcje       craplim.inconcje%type
     ,cdopeori       craplim.cdopeori%type
     ,cdageori       craplim.cdageori%type
     ,dtinsori       craplim.dtinsori%type
     ,cdopeexc       craplim.cdopeexc%type
     ,cdageexc       craplim.cdageexc%type
     ,dtinsexc       craplim.dtinsexc%type
     ,dtrefatu       craplim.dtrefatu%type
     ,insitblq       craplim.insitblq%type
     ,insitest       craplim.insitest%type
     ,dtenvest       craplim.dtenvest%type
     ,hrenvest       craplim.hrenvest%type
     ,cdagenci       craplim.cdagenci%type
     ,hrinclus       craplim.hrinclus%type
     ,dtdscore       craplim.dtdscore%type
     ,dsdscore       craplim.dsdscore%type
     ,cdopeste       craplim.cdopeste%type
     ,flgaprvc       craplim.flgaprvc%type
     ,dtenefes       craplim.dtenefes%type
     ,dsprotoc       craplim.dsprotoc%type
     ,dtaprova       craplim.dtaprova%type
     ,insitapr       craplim.insitapr%type
     ,cdopeapr       craplim.cdopeapr%type
     ,hraprova       craplim.hraprova%type
     ,dtmanute       craplim.dtmanute%type
     ,dtenvmot       craplim.dtenvmot%type
     ,hrenvmot       craplim.hrenvmot%type
     ,dsnivris       craplim.dsnivris%type
     ,dsobscmt       craplim.dsobscmt%type
     ,dtrejeit       craplim.dtrejeit%type
     ,hrrejeit       craplim.hrrejeit%type
     ,cdoperej       craplim.cdoperej%type
     ,ininadim       craplim.ininadim%type
     ,dssitlim       varchar2(100)
     ,dssitest       varchar2(100)
     ,dssitapr       varchar2(100) );

type typ_tab_dados_proposta is table of typ_reg_dados_proposta index by pls_integer;

--> Procedure para validar a analise de limite, não permitir efetuar analise para limites antigos.
PROCEDURE pc_validar_data_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                   --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  );

--> Procedure para validação de informações ante de efetuar a confirmação do novo limite
PROCEDURE pc_validar_confirm_novo_limite(pr_cdcooper    in crapcop.cdcooper%type --> Código da Cooperativa
                                        ,pr_nrdconta    in crapass.nrdconta%type --> Número da Conta
                                        ,pr_nrctrlim    in craplim.nrctrlim%type --> Contrato
                                        ,pr_vllimite    in craplim.vllimite%type --> Valor do limite de desconto
                                         --------> OUT <--------
                                        ,pr_cdagenci    out crapass.cdagenci%type --> Codigo da agencia
                                        ,pr_tab_crapdat out btch0001.rw_crapdat%type --> Tipo de registro de datas
                                        ,pr_cdcritic    out pls_integer          --> Código da crítica
                                        ,pr_dscritic    out varchar2             --> Descrição da crítica
                                        );

PROCEDURE pc_analisar_proposta(pr_tpenvest in varchar2               --> Tipo do envio esteira
                              ,pr_nrctrlim in  craplim.nrctrlim%type --> Numero do Contrato do Limite.
                              ,pr_tpctrlim in  craplim.tpctrlim%type --> Tipo de contrato do limite
                              ,pr_nrdconta in  crapass.nrdconta%type --> Conta do associado
                              ,pr_dtmovito in  varchar2	             -- crapdat.dtmvtolt%type  --> Data do movimento atual
                              ,pr_xmllog   in  varchar2              --> XML com informações de LOG
                               --------> OUT <--------
                              ,pr_cdcritic out pls_integer           --> Codigo da critica
                              ,pr_dscritic out varchar2              --> Descricao da critica
                              ,pr_retxml   in  out nocopy xmltype    --> Arquivo de retorno do XML
                              ,pr_nmdcampo out varchar2              --> Nome do campo com erro
                              ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                              );


--> Função que retorna se o Serviço IBRATAN está em Contigência ou Não.
FUNCTION fn_em_contingencia_ibratan(pr_cdcooper IN crapcop.cdcooper%TYPE)
  RETURN BOOLEAN;


PROCEDURE pc_confirmar_novo_limite_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                      ,pr_cddopera  IN INTEGER               --> Resposta de confirmacao
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                       --------> OUT <--------
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);            --> Erros do processo


PROCEDURE pc_confirmar_novo_limite(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_nrdconta    IN crapass.nrdconta%TYPE --> Número da Conta
                                  ,pr_nrctrlim    IN craplim.nrctrlim%TYPE --> Contrato
                                  ,pr_tpctrlim    IN craplim.tpctrlim%TYPE --> Tipo de contrato de limite(2-Cheque / 3-Titulo)
                                  ,pr_vllimite    IN craplim.vllimite%TYPE --> Valor do Limite
                                  ,pr_cdoperad    IN crapope.cdoperad%TYPE --> Código do Operador
                                  ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Codigo da Agencia
                                  ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Numero Caixa
                                  ,pr_idorigem    IN INTEGER               --> Identificador Origem Chamada
                                  ,pr_tab_crapdat IN btch0001.rw_crapdat%TYPE --> Tipo de registro de datas
                                  ,pr_insitapr    IN craplim.insitapr%TYPE    --> Decisão (Dependente do Retorno da Análise)                                  
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                  );


PROCEDURE pc_negar_proposta(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                           ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                           ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                            --------> OUT <--------
                           ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                           ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);            --> Erros do processo
  

PROCEDURE pc_enviar_proposta_manual(pr_nrctrlim in  craplim.nrctrlim%type --> Numero do Contrato do Limite.
                                   ,pr_tpctrlim in  craplim.tpctrlim%type --> Tipo de contrato do limite
                                   ,pr_nrdconta in  crapass.nrdconta%type --> Conta do associado
                                   ,pr_dtmovito in  varchar2	             -- crapdat.dtmvtolt%type  --> Data do movimento atual
                                   ,pr_xmllog   in  varchar2              --> XML com informações de LOG
                                   ,pr_cdcritic out pls_integer           --> Codigo da critica
                                   ,pr_dscritic out varchar2              --> Descricao da critica
                                   ,pr_retxml   in  out nocopy xmltype    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo out varchar2              --> Nome do campo com erro
                                   ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                                   );

PROCEDURE pc_renovar_lim_desc_titulo(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_cddlinha  IN crapldc.cddlinha%TYPE --> Código da Linha
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      --------> OUT <--------
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

PROCEDURE pc_obtem_dados_proposta_web(pr_nrdconta in crapass.nrdconta%type --> Conta do associado
                                     ,pr_xmllog   in varchar2              --> XML com informações de LOG
                                      -- OUT
                                     ,pr_cdcritic out pls_integer          --> Codigo da critica
                                     ,pr_dscritic out varchar2             --> Descric?o da critica
                                     ,pr_retxml   in out nocopy xmltype    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                     ,pr_des_erro out varchar2             --> Erros do processo
                                     );

END TELA_ATENDA_DSCTO_TIT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_DSCTO_TIT IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : TELA_ATENDA_DSCTO_TIT
    Sistema  : Ayllos Web
    Autor    : Paulo Penteado (GFT) / Gustavo Sene (GFT)
    Data     : Março - 2018                 Ultima atualizacao: 01/03/2018

    Dados referentes ao programa:

    Objetivo  : Centralizar rotinas relacionadas a tela Limite Desconto de Títulos dentro da ATENDA

    Alteracoes: 
      01/03/2018 - Criação: Paulo Penteado (GFT) / Gustavo Sene (GFT)
      13/03/2018 - Alterado alerta de confirmação quando ocorre contingencia. Teremos que mostrar o alerta somente se 
                   tanto a esteira quanto o motor estiverem em contingencia (Paulo Penteado (GFT) KE00726701-276)

  ---------------------------------------------------------------------------------------------------------------------*/

PROCEDURE pc_validar_data_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_validar_data_proposta
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Março/2018                   Ultima atualizacao: 28/02/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure para validar a analise de limite, não permitir efetuar analise para limites antigos.

    Alteração : 28/02/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro exception;

   vr_dtviglim date;

   --> Buscar Contrato de limite
   cursor cr_craplim is
   select 1
   from   craplim lim
   where  lim.dtpropos < vr_dtviglim
   and    lim.cdcooper = pr_cdcooper
   and    lim.nrdconta = pr_nrdconta
   and    lim.nrctrlim = pr_nrctrlim
   and    lim.tpctrlim = pr_tpctrlim;
   rw_craplim cr_craplim%rowtype;

BEGIN
   vr_dtviglim := to_date(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdcooper => 0
                                                   ,pr_cdacesso => 'DT_VIG_LIMITE_DESC_TIT'), 'DD/MM/RRRR');

   open  cr_craplim;
   fetch cr_craplim into rw_craplim;
   if    cr_craplim%found then
         close cr_craplim;
         vr_dscritic := 'Esta proposta foi incluída no processo antigo. Favor cancela-la e incluir novamente através do novo processo.';
         raise vr_exc_erro;
   end   if;
   close cr_craplim;

EXCEPTION
   when vr_exc_erro then
        if  nvl(vr_cdcritic,0) <> 0 and trim(vr_dscritic) is null then
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        else
            pr_cdcritic := nvl(vr_cdcritic,0);
            pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
        end if;

  when others then
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := replace(replace('Erro pc_validar_data_proposta: ' || sqlerrm, chr(13)),chr(10));

END pc_validar_data_proposta;


PROCEDURE pc_validar_confirm_novo_limite(pr_cdcooper    in crapcop.cdcooper%type --> Código da Cooperativa
                                        ,pr_nrdconta    in crapass.nrdconta%type --> Número da Conta
                                        ,pr_nrctrlim    in craplim.nrctrlim%type --> Contrato
                                        ,pr_vllimite    in craplim.vllimite%type --> Valor do limite de desconto
                                         --------> OUT <--------
                                        ,pr_cdagenci    out crapass.cdagenci%type --> Codigo da agencia
                                        ,pr_tab_crapdat out btch0001.rw_crapdat%type --> Tipo de registro de datas
                                        ,pr_cdcritic    out pls_integer          --> Código da crítica
                                        ,pr_dscritic    out varchar2             --> Descrição da crítica
                                        ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_validar_confirm_novo_limite
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Gustavo Sene (GFT)
    Data     : Março/2018                   Ultima atualizacao: 03/03/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure para validação de informações ante de efetuar a confirmação do novo limite

    Alteração : 03/03/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Informações de data do sistema
   rw_crapdat  btch0001.rw_crapdat%TYPE;

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro

   -- Tratamento de erros
   vr_exc_saida exception;

   -- Verifica Conta (Cadastro de associados)
   cursor cr_crapass is
   select dtelimin
         ,cdsitdtl
         ,cdagenci
         ,inpessoa
         ,nrdconta
   from   crapass
   where  crapass.cdcooper = pr_cdcooper
   and    crapass.nrdconta = pr_nrdconta;
   rw_crapass cr_crapass%rowtype;

   -- Verifica Cadastro de Lancamento de Contratos de Descontos.
   cursor cr_crapcdc is
   select 1
   from   crapcdc
   where  cdcooper = pr_cdcooper
   and    nrdconta = pr_nrdconta
   and    nrctrlim = pr_nrctrlim
   and    tpctrlim = 3; -- 3 = Título
   rw_crapcdc cr_crapcdc%rowtype;

   -- Verifica limite
   cursor cr_craplim is
   select nrctrlim
   from   craplim
   where  cdcooper = pr_cdcooper
   and    nrdconta = pr_nrdconta
   and    tpctrlim = 3
   and    insitlim = 2;
   rw_craplim cr_craplim%rowtype;

   --     Verifica limite
   cursor cr_craplim_ctr is
   select insitlim
         ,insitest
         ,insitapr
         ,vllimite
   from   craplim
   where  cdcooper = pr_cdcooper
   and    nrdconta = pr_nrdconta
   and    nrctrlim = pr_nrctrlim
   and    tpctrlim = 3; -- 3 = Título
   rw_craplim_ctr cr_craplim_ctr%rowtype;

BEGIN

   --    Verifica se a data esta cadastrada
   open  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
   fetch btch0001.cr_crapdat into rw_crapdat;
   if    btch0001.cr_crapdat%notfound then
         close btch0001.cr_crapdat;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
         raise vr_exc_saida;
   else
         pr_tab_crapdat := rw_crapdat;
   end   if;
   close btch0001.cr_crapdat;

   --    Verifica se existe a conta
   open  cr_crapass;
   fetch cr_crapass into rw_crapass;
   if    cr_crapass%notfound then
         close cr_crapass;
         vr_cdcritic := 9;
         raise vr_exc_saida;
   else
         pr_cdagenci := rw_crapass.cdagenci;
   end   if;
   close cr_crapass;

   --  Verifica se a conta foi eliminada
   if  rw_crapass.dtelimin is not null then
       vr_cdcritic := 410;
       raise vr_exc_saida;
   end if;

   --  Verifica se a conta está em prejuizo
   if  rw_crapass.cdsitdtl in (5,6,7,8) then
       vr_cdcritic := 695;
       raise vr_exc_saida;
   end if;

   --  Verifica se conta esta bloqueada
   if  rw_crapass.cdsitdtl in (2,4) then
       vr_cdcritic := 95;
       raise vr_exc_saida;
   end if;

   --  Verifica se existe contrato
   if  pr_nrctrlim = 0 then
       vr_cdcritic := 22;
       raise vr_exc_saida;
   end if;

   --    Verifica se ja existe lancamento
   open  cr_crapcdc;
   fetch cr_crapcdc into rw_crapcdc;
   if    cr_crapcdc%found then
         close cr_crapcdc;
         vr_cdcritic := 92;
         raise vr_exc_saida;
   end   if;
   close cr_crapcdc;

   --    Verifica se ja existe limite ativo
   open  cr_craplim;
   fetch cr_craplim into rw_craplim;
   if    cr_craplim%found then
         close cr_craplim;
         vr_dscritic:= 'O contrato ' ||rw_craplim.nrctrlim || ' deve ser cancelado primeiro.';
         raise vr_exc_saida;
   end   if;
   close cr_craplim;

   --    Verifica se ja existe limite ativo
   open  cr_craplim_ctr;
   fetch cr_craplim_ctr into rw_craplim_ctr;
   if    cr_craplim_ctr%notfound then
         close cr_craplim_ctr;
         vr_cdcritic := 484;
         raise vr_exc_saida;
   end   if;
   close cr_craplim_ctr;

   --  Verifica se a situação do Limite está 'Em Estudo' ou 'Aprovado'
   if  rw_craplim_ctr.insitlim NOT IN (1,5) then
       vr_dscritic := 'Para esta operação, as Situações do Limite devem ser: "Em Estudo" ou "Aprovado".';
       raise vr_exc_saida;
   end if;

   --  Verifica se a situação da Análise está 'Não Enviado' ou 'Análise Finalizada'
   if  rw_craplim_ctr.insitest NOT IN (0,3) then
       vr_dscritic := 'Para esta operação, as Situações da Análise devem ser: "Não Enviado" ou "Análise Finalizada".';
       raise vr_exc_saida;
   end if;

   --  Verifica se o limite está diferente do registro
   if  rw_craplim_ctr.vllimite <> pr_vllimite then
       vr_cdcritic := 91;
       raise vr_exc_saida;
   end if;

EXCEPTION
   when vr_exc_saida then
        if  nvl(vr_cdcritic,0) <> 0 and trim(vr_dscritic) is null then
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        else
            pr_cdcritic := nvl(vr_cdcritic,0);
            pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
        end if;

  when others then
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := replace(replace('Erro pc_validar_data_proposta: ' || sqlerrm, chr(13)),chr(10));

END pc_validar_confirm_novo_limite;

PROCEDURE pc_analisar_proposta(pr_tpenvest in varchar2               --> Tipo do envio esteira
                              ,pr_nrctrlim in  craplim.nrctrlim%type --> Numero do Contrato do Limite.
                              ,pr_tpctrlim in  craplim.tpctrlim%type --> Tipo de contrato do limite
                              ,pr_nrdconta in  crapass.nrdconta%type --> Conta do associado
                              ,pr_dtmovito in  varchar2              --> Data do movimento atual
                              ,pr_xmllog   in  varchar2              --> XML com informações de LOG
                              ,pr_cdcritic out pls_integer           --> Codigo da critica
                              ,pr_dscritic out varchar2              --> Descricao da critica
                              ,pr_retxml   in  out nocopy xmltype    --> Arquivo de retorno do XML
                              ,pr_nmdcampo out varchar2              --> Nome do campo com erro
                              ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                              ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_validar_data_proposta
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Março/2018                   Ultima atualizacao: 28/02/2018

    Dados referentes ao programa:
    Tipo do envestimento I - inclusao Proposta
                         D - Derivacao Proposta
                         A - Alteracao Proposta
                         N - Alterar Numero Proposta
                         C - Cancelar Proposta
                         E - Efetivar Proposta

    Caso a proposta já tenha sido enviada para a Esteira iremos considerar uma Alteracao.
    Caso a proposta tenho sido reprovada pelo Motor, iremos considerar envio pois ela ainda nao foi a Esteira

    Frequencia: Sempre que for chamado

    Objetivo  : Procedure para validar a analise de limite, não permitir efetuar analise para limites antigos.

    Alteração : 28/02/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   vr_dsmensag varchar2(32767);

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_saida exception;

   -- Variaveis de entrada vindas no xml
   vr_cdcooper integer;
   vr_cdoperad varchar2(100);
   vr_nmdatela varchar2(100);
   vr_nmeacao  varchar2(100);
   vr_cdagenci varchar2(100);
   vr_nrdcaixa varchar2(100);
   vr_idorigem varchar2(100);

BEGIN

   pr_des_erro := pr_xmllog; -- somente para não haver hint, caso for usado, pode remover essa linha
   pr_des_erro := 'OK';
   pr_nmdcampo := null;

   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);

   este0003.pc_enviar_proposta_esteira(pr_cdcooper => vr_cdcooper
                                      ,pr_cdagenci => vr_cdagenci
                                      ,pr_cdoperad => vr_cdoperad
                                      ,pr_idorigem => vr_idorigem
                                      ,pr_tpenvest => pr_tpenvest
                                      ,pr_nrctrlim => pr_nrctrlim
                                      ,pr_tpctrlim => pr_tpctrlim
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_dtmovito => pr_dtmovito
                                      ,pr_dsmensag => vr_dsmensag
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic
                                      ,pr_des_erro => pr_des_erro);

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;

   vr_dsmensag := replace(replace(vr_dsmensag, '<b>', '\"'), '</b>', '\"');
   vr_dsmensag := replace(replace(vr_dsmensag, '<br>', ' '), '<BR>', ' ');
   pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                    '<Root><dsmensag>' || vr_dsmensag || '</dsmensag></Root>');
   dbms_output.put_line(vr_dsmensag);

   COMMIT;

EXCEPTION
  when vr_exc_saida then
       -- Se possui código de crítica e não foi informado a descrição
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descrição da crítica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;

       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       rollback;

  when others then
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na ESTE0003.pc_analisar_proposta: ' || sqlerrm;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       rollback;
end pc_analisar_proposta;


FUNCTION fn_em_contingencia_ibratan (pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN BOOLEAN IS

  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_em_contingencia_ibratan
    Sistema  : CRED
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Gustavo Guedes de Sene (GFT)
    Data     : Março/2018                   Ultima atualizacao: 01/03/2018

    Frequencia: Sempre que for chamado

    Objetivo  : Função que retorna se o Serviço IBRATAN está em Contigência ou Não.

    Alteração : 01/03/2018 - Criação (Gustavo Sene (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

  vr_inobriga varchar2(1);

  -- Variáveis de críticas
  vr_cdcritic crapcri.cdcritic%type;
  vr_dscritic varchar2(10000);

  -- Tratamento de erros
  vr_exc_saida exception;


BEGIN
  ESTE0003.pc_obrigacao_analise_automatic(pr_cdcooper => pr_cdcooper
                                         ,pr_inobriga => vr_inobriga
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic
                                         );

  if vr_inobriga = 'N' then -- Se análise IBRATAN não obrigatória
    return TRUE;  --> Em Contingência
  else                      -- Se análise IBRATAN obrigatória
    return FALSE; --> Não está em Contingêngia
  end if;

END fn_em_contingencia_ibratan;


PROCEDURE pc_confirmar_novo_limite_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                      ,pr_cddopera  IN INTEGER               --> Resposta de confirmacao
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
BEGIN
  /*----------------------------------------------------------------------------------
   Procedure: pc_confirmar_novo_limite_web
   Sistema  : CRED
   Sigla    : TELA_ATENDA_DSCTO_TIT
   Autor    : Gustavo Guedes de Sene - Company: GFT
   Data     : Criação: 22/02/2018    Ultima atualização: 22/02/2018

   Dados referentes ao programa:
  
   Frequencia:
   Objetivo  :

   Histórico de Alterações:
    22/02/2018 - Versão inicial
    13/03/2018 - Alterado alerta de confirmação quando ocorre contingencia. Teremos que mostrar o alerta
                 somente se tanto a esteira quanto o motor estiverem em contingencia (Paulo Penteado (GFT))
  ----------------------------------------------------------------------------------*/

  DECLARE

     -- Busca cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
     SELECT vlmaxleg
           ,vlmaxutl
           ,vlcnsscr
       FROM crapcop
      WHERE cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Informações de data do sistema
   rw_crapdat  btch0001.rw_crapdat%TYPE;

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida   EXCEPTION;
    vr_retorna_msg EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_cdagenci_ass VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis auxiliares
    vr_vlmaxleg     crapcop.vlmaxleg%TYPE;
    vr_vlmaxutl     crapcop.vlmaxutl%TYPE;
    vr_vlminscr     crapcop.vlcnsscr%TYPE;
    vr_par_nrdconta INTEGER;
    vr_par_dsctrliq VARCHAR2(1000);
    vr_par_vlutiliz NUMBER;
    vr_qtctarel     INTEGER;
    vr_flggrupo     INTEGER;
    vr_nrdgrupo     INTEGER;
    vr_dsdrisco     VARCHAR2(2);
    vr_gergrupo     VARCHAR2(1000);
    vr_dsdrisgp     VARCHAR2(1000);
    vr_mensagem_01  VARCHAR2(1000);
    vr_mensagem_02  VARCHAR2(1000);
    vr_mensagem_03  VARCHAR2(1000);
    vr_mensagem_04  VARCHAR2(1000);
    vr_mensagem_05  VARCHAR2(1000); -- Mensagem que informa se o Processo de Análise Automática (IBRATAN) está em Contingência
    vr_tab_grupo    geco0001.typ_tab_crapgrp;
    vr_valor        craplim.vllimite%TYPE;
    vr_index        INTEGER;
    vr_str_grupo    VARCHAR2(32767) := '';
    vr_vlutilizado  VARCHAR2(100) := '';
    vr_vlexcedido   VARCHAR2(100) := '';
    vr_em_contingencia_ibratan boolean;
    vr_flctgest     boolean;
    vr_flctgmot     boolean;

  BEGIN

    pr_des_erro := 'OK';

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                              ,pr_action => NULL);
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
    --  Se ocorrer algum erro
    IF  vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
    END IF;


    pc_validar_confirm_novo_limite(pr_cdcooper    => vr_cdcooper
                                  ,pr_nrdconta    => pr_nrdconta
                                  ,pr_nrctrlim    => pr_nrctrlim
                                  ,pr_vllimite    => pr_vllimite
                                  ,pr_cdagenci    => vr_cdagenci_ass
                                  ,pr_tab_crapdat => rw_crapdat
                                  ,pr_cdcritic    => vr_cdcritic
                                  ,pr_dscritic    => vr_dscritic);
    --  Se ocorrer algum erro
    IF  vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
    END IF;


    vr_cdagenci := nvl(nullif(vr_cdagenci, 0), vr_cdagenci_ass);

    -- Verificar se a esteira e/ou motor estão em contigencia e armazenar na variavel
    vr_em_contingencia_ibratan := fn_em_contingencia_ibratan(pr_cdcooper => vr_cdcooper);

    --  1º Passo: Executamos a Operação = 0 para verificar se existe alguma inconsistência para emitir mensagem de
    --  alerta, e solicitar confirmação do usuário para prosseguir com a confirmação do novo limite
    if  pr_cddopera = 0 then
        -- Inicializa variaveis
        vr_vlmaxleg     := 0;
        vr_vlmaxutl     := 0;
        vr_vlminscr     := 0;
        vr_par_nrdconta := pr_nrdconta;
        vr_par_dsctrliq := ' ';
        vr_par_vlutiliz := 0;
        vr_qtctarel     := 0;

        OPEN  cr_crapcop(vr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        if    cr_crapcop%FOUND then
              vr_vlmaxleg := rw_crapcop.vlmaxleg;
              vr_vlmaxutl := rw_crapcop.vlmaxutl;
              vr_vlminscr := rw_crapcop.vlcnsscr;
        end   if;
        CLOSE cr_crapcop;

        -- Verifica se tem grupo economico em formacao
        GECO0001.pc_busca_grupo_associado(pr_cdcooper => vr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_flggrupo => vr_flggrupo
                                         ,pr_nrdgrupo => vr_nrdgrupo
                                         ,pr_gergrupo => vr_gergrupo
                                         ,pr_dsdrisgp => vr_dsdrisgp);
        -- Se tiver grupo economico em formacao
        IF  vr_gergrupo IS NOT NULL THEN
            vr_mensagem_01 := vr_gergrupo || ' Confirma?';
        END IF;

        --  Se conta pertence a um grupo
        IF  vr_flggrupo = 1 THEN
            geco0001.pc_calc_endivid_grupo(pr_cdcooper  => vr_cdcooper
                                          ,pr_cdagenci  => vr_cdagenci
                                          ,pr_nrdcaixa  => 0
                                          ,pr_cdoperad  => vr_cdoperad
                                          ,pr_nmdatela  => vr_nmdatela
                                          ,pr_idorigem  => 1
                                          ,pr_nrdgrupo  => vr_nrdgrupo
                                          ,pr_tpdecons  => TRUE
                                          ,pr_dsdrisco  => vr_dsdrisco
                                          ,pr_vlendivi  => vr_par_vlutiliz
                                          ,pr_tab_grupo => vr_tab_grupo
                                          ,pr_cdcritic  => vr_cdcritic
                                          ,pr_dscritic  => vr_dscritic);

            IF  vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
            END IF;

            IF  vr_vlmaxutl > 0 THEN
                --  Verifica se o valor limite é maior que o valor da divida e pega o maior valor
                IF  pr_vllimite > vr_par_vlutiliz THEN
                    vr_valor := pr_vllimite;
                ELSE
                    vr_valor := vr_par_vlutiliz;
                END IF;

                --  Verifica se o valor é maior que o valor maximo utilizado pelo associado nos emprestimos
                IF  vr_valor > vr_vlmaxutl THEN
                    vr_mensagem_02 := 'Valores utilizados excedidos. Utilizado R$: ' ||
                                      to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                      to_char((vr_valor - vr_vlmaxutl),'999G999G990D00') ||'.';
                END IF;

                --  Verifica se o valor é maior que o valor legal a ser emprestado pela cooperativa
                IF  vr_valor > vr_vlmaxleg THEN
                    vr_mensagem_03 := 'Valor Legal Excedido';
                    vr_vlutilizado := to_char(vr_par_vlutiliz,'999G999G990D00');
                    vr_vlexcedido  := to_char((vr_valor - vr_vlmaxutl),'999G999G990D00');

                    -- Abre tabela do grupo
                    vr_str_grupo := '<grupo>';
                    vr_qtctarel  := 0;
                    vr_index     := vr_tab_grupo.first;

                    WHILE vr_index IS NOT NULL LOOP
                          -- Popula tabela do grupo
                          vr_str_grupo := vr_str_grupo || '<conta>' ||
                                          to_char(gene0002.fn_mask_conta((vr_tab_grupo(vr_index).nrctasoc)))
                                          || '</conta>';
                          vr_index     := vr_tab_grupo.next(vr_index);
                          vr_qtctarel  := vr_qtctarel + 1;
                    END   LOOP;

                    -- Encerra tabela grupo
                    vr_str_grupo := vr_str_grupo || '</grupo><qtctarel>' || vr_qtctarel || '</qtctarel>';
                END IF;

                --  Verifica se o valor é maior que o valor da consulta SCR
                IF  vr_valor > vr_vlminscr THEN
                    vr_mensagem_04 := 'Efetue consulta no SCR.';
                END IF;
            END IF;

        ELSE --  Se conta nao pertence a um grupo
            gene0005.pc_saldo_utiliza(pr_cdcooper    => vr_cdcooper
                                     ,pr_tpdecons    => 1
                                     ,pr_dsctrliq    => vr_par_dsctrliq
                                     ,pr_cdprogra    => vr_nmdatela
                                     ,pr_nrdconta    => vr_par_nrdconta
                                     ,pr_tab_crapdat => rw_crapdat
                                     ,pr_inusatab    => TRUE
                                     ,pr_vlutiliz    => vr_par_vlutiliz
                                     ,pr_cdcritic    => vr_cdcritic
                                     ,pr_dscritic    => vr_dscritic);

            --  Verifica se o valor limite é maior que o valor da divida e pega o maior valor
            IF  vr_vlmaxutl > 0 THEN
                IF  pr_vllimite > vr_par_vlutiliz THEN
                    vr_valor := pr_vllimite;
                ELSE
                    vr_valor := vr_par_vlutiliz;
                END IF;

                -- Verifica se o valor é maior que o valor maximo utilizado pelo associado nos emprestimos
                IF  vr_valor > vr_vlmaxutl THEN
                    vr_mensagem_02 := 'Valores utilizados excedidos. Utilizado R$: ' ||
                                      to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                      to_char((vr_valor - vr_vlmaxutl),'999G999G990D00') || '.';
                END IF;

                --  Verifica se o valor é maior que o valor legal a ser emprestado pela cooperativa
                IF  vr_valor > vr_vlmaxleg THEN
                    vr_mensagem_03 := 'Valor legal excedido. Utilizado R$: ' ||
                                      to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                      to_char((vr_valor - vr_vlmaxleg),'999G999G990D00') || '.';
                END IF;

                --  Verifica se o valor é maior que o valor da consulta SCR
                IF  vr_valor > vr_vlminscr THEN
                    vr_mensagem_04 := 'Efetue consulta no SCR.'; 
                END IF;
            END IF;
        END IF;

        --  Verificar se o tanto o motor quanto a esteria estão em contingencia para mostrar a mensagem de alerta, sou seja, mostrar
        --  mensagem de alerta somente se o motor E a esteira estiverem em contingencia.
        este0003.pc_verifica_contigenc_motor(pr_cdcooper => vr_cdcooper
                                            ,pr_flctgmot => vr_flctgmot
                                            ,pr_dsmensag => vr_mensagem_05 -- somente representativo para out
                                            ,pr_dscritic => vr_dscritic);

        este0003.pc_verifica_contigenc_esteira(pr_cdcooper => vr_cdcooper
                                              ,pr_flctgest => vr_flctgest
                                              ,pr_dsmensag => vr_mensagem_05 -- somente representativo para out
                                              ,pr_dscritic => vr_dscritic);

        if  vr_flctgest AND vr_flctgmot then
            vr_mensagem_05 := 'Atenção: Para confirmar é necessário ter efetuado a análise manual do limite! Confirma análise do limite?';
        end if;

        --  Se houver alguma Mensagem/Inconsistência, emitir mensagem para o usuario
        IF  vr_mensagem_01 IS NOT NULL OR vr_mensagem_02 IS NOT NULL OR vr_mensagem_03 IS NOT NULL OR
            vr_mensagem_04 IS NOT NULL OR vr_mensagem_05 IS NOT NULL THEN
            -- Criar cabecalho do XML
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root>' ||
                                     '<Msg>' ||
                                         '<msg_01>' || vr_mensagem_01 || '</msg_01>' ||
                                         '<msg_02>' || vr_mensagem_02 || '</msg_02>' ||
                                         '<msg_03>' || vr_mensagem_03 || '</msg_03>' ||
                                         '<msg_04>' || vr_mensagem_04 || '</msg_04>' ||
                                         '<msg_05>' || vr_mensagem_05 || '</msg_05>' ||
                                                       vr_str_grupo   ||
                                         '<vlutil>' || vr_vlutilizado || '</vlutil>' ||
                                         '<vlexce>' || vr_vlexcedido  || '</vlexce>' ||
                                     '</Msg></Root>');

        -- Se não houver nenhuma Mensagem/Inconsistência, efetuar o processo de Confirmação do novo Limite normalmente
        ELSE
           pc_confirmar_novo_limite(pr_cdcooper => vr_cdcooper
                                 	 ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctrlim => pr_nrctrlim
                                   ,pr_tpctrlim => 3 -- Título
                                   ,pr_vllimite => pr_vllimite
                                   ,pr_cdoperad => vr_cdoperad   --> Código do Operador
                                   ,pr_cdagenci => vr_cdagenci   --> Codigo da Agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa   --> Numero Caixa
                                   ,pr_idorigem => vr_idorigem   --> Identificador Origem Chamada
                                   ,pr_tab_crapdat => rw_crapdat --> Data de Movimento
                                   ,pr_insitapr => NULL -- Decisão = Retorno da IBRATAN
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
            --  Se ocorrer algum erro
            IF  vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
            END IF;

            -- Criar cabecalho do XML
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');
        END IF;

    --  2º Passo: Se houve alguma Mensagem/Inconsistência e o Operador Ayllos confirmou (ou seja, clicou em "SIM" ou "OK"),
    --  efetuar o processo de Confirmação do novo Limite.
    --  Se houver Contigência de Motor e/ou Esteira, será efetuada a Confirmação do novo Limite na situação de Contigência.
    else
        if  vr_em_contingencia_ibratan then
           pc_confirmar_novo_limite(pr_cdcooper => vr_cdcooper
                                 	 ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctrlim => pr_nrctrlim
                                   ,pr_tpctrlim => 3 -- Título
                                   ,pr_vllimite => pr_vllimite
                                   ,pr_cdoperad => vr_cdoperad   --> Código do Operador
                                   ,pr_cdagenci => vr_cdagenci   --> Codigo da Agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa   --> Numero Caixa
                                   ,pr_idorigem => vr_idorigem   --> Identificador Origem Chamada
                                   ,pr_tab_crapdat => rw_crapdat --> Data de Movimento
                                   ,pr_insitapr => 3 -- Decisão = APROVADO (CONTINGENCIA)      
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
          --  Se ocorrer algum erro
          IF  vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
          END IF;

        else
          pc_confirmar_novo_limite(pr_cdcooper => vr_cdcooper
                                 	 ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctrlim => pr_nrctrlim
                                   ,pr_tpctrlim => 3 -- Título
                                   ,pr_vllimite => pr_vllimite
                                   ,pr_cdoperad => vr_cdoperad   --> Código do Operador
                                   ,pr_cdagenci => vr_cdagenci   --> Codigo da Agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa   --> Numero Caixa
                                   ,pr_idorigem => vr_idorigem   --> Identificador Origem Chamada
                                   ,pr_tab_crapdat => rw_crapdat --> Data de Movimento
                                   ,pr_insitapr => NULL -- Decisão = Retorno da IBRATAN
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
          --  Se ocorrer algum erro
          IF  vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
          END IF;


        end if;

        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');
    end if;

  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_des_erro := 'NOK';
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_confirma_novo_limite_web: ' || SQLERRM;

      -- Carregar XML padrão para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;

END pc_confirmar_novo_limite_web;


PROCEDURE pc_confirmar_novo_limite(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_nrdconta    IN crapass.nrdconta%TYPE --> Número da Conta
                                  ,pr_nrctrlim    IN craplim.nrctrlim%TYPE --> Contrato
                                  ,pr_tpctrlim    IN craplim.tpctrlim%TYPE --> Tipo de contrato de Limite (2-Cheque / 3-Titulo)
                                  ,pr_vllimite    IN craplim.vllimite%TYPE --> Valor do Limite
                                  ,pr_cdoperad    IN crapope.cdoperad%TYPE --> Código do Operador
                                  ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Codigo da agencia
                                  ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Numero Caixa
                                  ,pr_idorigem    IN INTEGER               --> Identificador Origem Chamada
                                  ,pr_tab_crapdat IN btch0001.rw_crapdat%TYPE --> Tipo de registro de datas
                                  ,pr_insitapr    IN craplim.insitapr%TYPE    --> Decisão (Dependente do Retorno da Análise)
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER             --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2                --> Descricao da critica
                                  ) IS


BEGIN

  ----------------------------------------------------------------------------------
  --
  -- Procedure: pc_confirmar_novo_limite
  -- Sistema  : CRED
  -- Sigla    : TELA_ATENDA_DSCTO_TIT
  -- Autor    : Gustavo Guedes de Sene - Company: GFT
  -- Data     : Criação: 22/02/2018    Ultima atualização: 22/02/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia:
  -- Objetivo  :
  --
  --
  -- Histórico de Alterações:
  --  22/02/2018 - Versão inicial
  --
  --
  ----------------------------------------------------------------------------------

  DECLARE

   --     Verifica limite
   cursor cr_craplim is
   select 1
          -- idcobope
   from   craplim
   where  cdcooper = pr_cdcooper
   and    nrdconta = pr_nrdconta
   and    nrctrlim = pr_nrctrlim
   and    tpctrlim = pr_tpctrlim; -- 3 = Título
   rw_craplim cr_craplim%rowtype;



    -- Verifica Conta (Cadastro de associados)
    CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT dtelimin
            ,cdsitdtl
            ,cdagenci
            ,inpessoa
            ,nrdconta
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;


    -- Busca capa do lote
    CURSOR cr_craplot (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                      ,pr_cdagenci IN craplot.cdagenci%TYPE) IS
      SELECT nvl(MAX(nrdolote), 0) + 1
        FROM craplot
       WHERE cdcooper = pr_cdcooper
         AND dtmvtolt = pr_dtmvtolt
         AND cdagenci = pr_cdagenci
         AND cdbccxlt = 700;


    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida   EXCEPTION;
    vr_retorna_msg EXCEPTION;


    -- Variaveis auxiliares
    vr_nrdolote     craplot.nrdolote%TYPE;
    vr_rowid_log    ROWID;


    -- Variáveis incluídas
    vr_des_erro      VARCHAR2(3);                           -- 'OK' / 'NOK'
    vr_cdbattar      crapbat.cdbattar%TYPE := 'DSTCONTRPF'; -- Default = Pessoa Física
    vr_cdtarifa      craptar.cdtarifa%TYPE;
    vr_cdhistor      crapfvl.cdhistor%TYPE;
    vr_cdhisest      crapfvl.cdhisest%TYPE;
    vr_vltarifa      crapfco.vlmaxtar%TYPE;
    vr_dtdivulg      crapfco.dtdivulg%TYPE;
    vr_dtvigenc      crapfco.dtvigenc%TYPE;
    vr_cdfvlcop      crapfco.cdfvlcop%TYPE;
    vr_rowid_craplat ROWID;

    -- PL Tables
    vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
    vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
    vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_risco_tl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
    vr_tab_efetivacao       RATI0001.typ_tab_efetivacao;
    vr_tab_ratings          RATI0001.typ_tab_ratings;
    vr_tab_crapras          RATI0001.typ_tab_crapras;
    vr_tab_erro             GENE0001.typ_tab_erro;

  BEGIN

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                              ,pr_action => NULL);

   open  cr_craplim;
   fetch cr_craplim into rw_craplim;
   if    cr_craplim%notfound then
         close cr_craplim;
        vr_dscritic := 'Associado nao possui proposta de limite de credito. Conta: ' || pr_nrdconta || '.Contrato: ' || pr_nrctrlim;
         raise vr_exc_saida;
   end   if;
   close cr_craplim;


      -- Verifica se ja existe lote criado
      OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => pr_tab_crapdat.dtmvtolt
                     ,pr_cdagenci => pr_cdagenci);
      FETCH cr_craplot INTO vr_nrdolote;
      CLOSE cr_craplot;

      -- Se não, cria novo lote
      BEGIN
        INSERT INTO craplot (cdcooper
                            ,dtmvtolt
                            ,cdagenci
                            ,cdbccxlt
                            ,nrdolote
                            ,tplotmov
                            ,nrseqdig
                            ,qtcompln
                            ,qtinfoln
                            ,vlcompcr
                            ,vlinfocr
                            ,cdoperad)
                     VALUES (pr_cdcooper
                            ,pr_tab_crapdat.dtmvtolt
                            ,pr_cdagenci
                            ,700
                            ,vr_nrdolote
                            ,35 -- Título
                            ,1
                            ,1
                            ,1
                            ,pr_vllimite
                            ,pr_vllimite
                            ,pr_cdoperad);
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir capa do lote. ' || SQLERRM;
        RAISE vr_exc_saida;
      END;


      -- Atualiza Limite de Desconto de Título
      BEGIN
        UPDATE craplim
           SET insitlim = 2 -- Situação do Limite = ATIVO
              ,insitest = 3
              ,insitapr = nvl(pr_insitapr, insitapr) -- Decisão (Depende do Retorno da Análise...)
              ,qtrenova = 0
              ,dtinivig = pr_tab_crapdat.dtmvtolt
              ,dtfimvig = (pr_tab_crapdat.dtmvtolt + craplim.qtdiavig)
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrlim = pr_nrctrlim
           AND tpctrlim = pr_tpctrlim; -- 3 = Título
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar limite de desconto de título. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

/*
      -- Efetuar o bloqueio de possíveis coberturas vinculadas ao limite anterior
      BLOQ0001.pc_bloq_desbloq_cob_operacao(pr_nmdatela       => 'ATENDA'
                                           ,pr_idcobertura    => rw_craplim.idcobope
                                           ,pr_inbloq_desbloq => 'B'
                                           ,pr_cdoperador     => pr_cdoperad
                                           ,pr_flgerar_log    => 'S'
                                           ,pr_dscritic       => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
*/

      -- Cria lancamento de contratos de descontos.
      BEGIN
        INSERT INTO crapcdc (dtmvtolt
                            ,cdagenci
                            ,cdbccxlt
                            ,nrdolote
                            ,nrdconta
                            ,nrctrlim
                            ,vllimite
                            ,nrseqdig
                            ,cdcooper
                            ,tpctrlim)
                     VALUES (pr_tab_crapdat.dtmvtolt
                            ,pr_cdagenci
                            ,700
                            ,vr_nrdolote
                            ,pr_nrdconta
                            ,pr_nrctrlim
                            ,pr_vllimite
                            ,1
                            ,pr_cdcooper
                            ,pr_tpctrlim); -- Título
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao criar lancamento de contratos de descontos. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      OPEN  cr_crapass(pr_cdcooper, pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;

      IF rw_crapass.inpessoa = 1 THEN
        vr_cdbattar := 'DSTCONTRPF'; -- Pessoa Física
      ELSE
        vr_cdbattar := 'DSTCONTRPJ'; -- Pessoa Jurídica
      END IF;

      -- Buscar valores da tarifa vigente
      TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper    --> Codigo Cooperativa
                                           ,pr_cdbattar => vr_cdbattar    --> Codigo da sigla da tarifa (CRAPBAT) - Ao popular este parâmetro o pr_cdtarifa não é necessário
                                           ,pr_cdtarifa => vr_cdtarifa    --> Codigo da Tarifa (CRAPTAR) - Ao popular este parâmetro o pr_cdbattar não é necessário
                                           ,pr_vllanmto => pr_vllimite    --> Valor Lancamento
                                           ,pr_cdprogra => 'ATENDA'       --> Codigo Programa
                                            --
                                           ,pr_cdhistor => vr_cdhistor    --> Codigo Historico
                                           ,pr_cdhisest => vr_cdhisest    --> Historico Estorno
                                           ,pr_vltarifa => vr_vltarifa    --> Valor tarifa
                                           ,pr_dtdivulg => vr_dtdivulg    --> Data Divulgacao
                                           ,pr_dtvigenc => vr_dtvigenc    --> Data Vigencia
                                           ,pr_cdfvlcop => vr_cdfvlcop    --> Codigo faixa valor cooperativa
                                           ,pr_cdcritic => vr_cdcritic    --> Codigo Critica
                                           ,pr_dscritic => vr_dscritic    --> Descricao Critica
                                           ,pr_tab_erro => vr_tab_erro ); --> Tabela de retorno de erros


      -- Criar lançamento automático da tarifa
      TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper => pr_cdcooper           --> Codigo Cooperativa
                                      ,pr_nrdconta => pr_nrdconta           --> Numero da Conta
                                      ,pr_dtmvtolt => pr_tab_crapdat.dtmvtolt           --> Data Lancamento
                                      ,pr_cdhistor => vr_cdhistor           --> Codigo Historico
                                      ,pr_vllanaut => vr_vltarifa           --> Valor lancamento automatico
                                      ,pr_cdoperad => pr_cdoperad           --> Codigo Operador
                                      ,pr_cdagenci => 1                     --> Codigo Agencia
                                      ,pr_cdbccxlt => 100                   --> Codigo banco caixa
                                      ,pr_nrdolote => 8452                  --> Numero do lote
                                      ,pr_tpdolote => 1                     --> Tipo do lote (35 - Título)
                                      ,pr_nrdocmto => 0                     --> Numero do documento
                                      ,pr_nrdctabb => pr_nrdconta           --> Numero da conta
                                      ,pr_nrdctitg => to_char(pr_nrdconta, '99999999') --> Numero da conta integracao
                                      ,pr_cdpesqbb => ''                    --> Codigo pesquisa
                                      ,pr_cdbanchq => 0                     --> Codigo Banco Cheque
                                      ,pr_cdagechq => 0                     --> Codigo Agencia Cheque
                                      ,pr_nrctachq => 0                     --> Numero Conta Cheque
                                      ,pr_flgaviso => FALSE                 --> Flag aviso
                                      ,pr_tpdaviso => 0                     --> Tipo aviso
                                      ,pr_cdfvlcop => vr_cdfvlcop           --> Codigo cooperativa
                                      ,pr_inproces => 1                     --> Indicador processo 1 = Online
                                       --
                                      ,pr_rowid_craplat => vr_rowid_craplat --> Rowid do lancamento tarifa
                                      ,pr_tab_erro      => vr_tab_erro      --> Tabela retorno erro
                                      ,pr_cdcritic      => vr_cdcritic      --> Codigo Critica
                                      ,pr_dscritic      => vr_dscritic);    --> Descricao Critica


      -- Gera Rating
      rati0001.pc_gera_rating(pr_cdcooper => pr_cdcooper                         --> Codigo Cooperativa
                             ,pr_cdagenci => pr_cdagenci                         --> Codigo Agencia
                             ,pr_nrdcaixa => pr_nrdcaixa                         --> Numero Caixa
                             ,pr_cdoperad => pr_cdoperad                         --> Codigo Operador
                             ,pr_nmdatela => 'ATENDA'                            --> Nome da tela
                             ,pr_idorigem => pr_idorigem                         --> Identificador Origem
                             ,pr_nrdconta => pr_nrdconta                         --> Numero da Conta
                             ,pr_idseqttl => 1                                   --> Sequencial do Titular
                             ,pr_dtmvtolt => pr_tab_crapdat.dtmvtolt             --> Data de movimento
                             ,pr_dtmvtopr => pr_tab_crapdat.dtmvtopr             --> Data do próximo dia útil
                             ,pr_inproces => pr_tab_crapdat.inproces             --> Situação do processo
                             ,pr_tpctrrat => 3                                   --> Tipo Contrato Rating (2-Cheque / 3-Titulo)
                             ,pr_nrctrrat => pr_nrctrlim                         --> Numero Contrato Rating
                             ,pr_flgcriar => 1                                   --> Criar rating
                             ,pr_flgerlog => 1                                   -->  Identificador de geração de log
                             ,pr_tab_rating_sing => vr_tab_crapras               --> Registros gravados para rating singular
                             ,pr_tab_impress_coop => vr_tab_impress_coop         --> Registro impressão da Cooperado
                             ,pr_tab_impress_rating => vr_tab_impress_rating     --> Registro itens do Rating
                             ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                             ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                             ,pr_tab_impress_assina => vr_tab_impress_assina     --> Assinatura na impressao do Rating
                             ,pr_tab_efetivacao => vr_tab_efetivacao             --> Registro dos itens da efetivação
                             ,pr_tab_ratings  => vr_tab_ratings                  --> Informacoes com os Ratings do Cooperado
                             ,pr_tab_crapras  => vr_tab_crapras                  --> Tabela com os registros processados
                             ,pr_tab_erro => vr_tab_erro                         --> Tabela de retorno de erro
                             ,pr_des_reto => vr_des_erro);                       --> Ind. de retorno OK/NOK


      -- Em caso de erro
      IF vr_des_erro <> 'OK' THEN

        vr_cdcritic:= vr_tab_erro(0).cdcritic;
        vr_dscritic:= vr_tab_erro(0).dscritic;

        RAISE vr_exc_saida;
        RETURN;

      END IF;


      -- Efetua os inserts para apresentacao na tela VERLOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                          ,pr_dstransa => 'Confirmar Novo limite de desconto de títulos.'
                          ,pr_dttransa => trunc(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'ATENDA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_rowid_log);


    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_confirma_novo_limite_web: ' || SQLERRM;

      ROLLBACK;
  END;

END pc_confirmar_novo_limite;


PROCEDURE pc_negar_proposta(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                           ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                           ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                           ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
BEGIN

  ----------------------------------------------------------------------------------
  --
  -- Procedure: pc_negar_proposta
  -- Sistema  : CRED
  -- Sigla    : TELA_ATENDA_DSCTO_TIT
  -- Autor    : Gustavo Guedes de Sene - Company: GFT
  -- Data     : Criação: 01/03/2018    Ultima atualização: 01/03/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia:
  -- Objetivo  :
  --
  --
  -- Histórico de Alterações:
  --  01/03/2018 - Criação
  --
  --
  ----------------------------------------------------------------------------------

  DECLARE
    -- Verifica limite
    CURSOR cr_craplim_ctr (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE
                          ,pr_nrctrlim IN crapcdc.nrctrlim%TYPE) IS
      SELECT insitlim
            ,insitest
        FROM craplim
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrlim = pr_nrctrlim
         AND tpctrlim = 3; -- 3 = Título
    rw_craplim_ctr cr_craplim_ctr%ROWTYPE;

    -- Informações de data do sistema
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida   EXCEPTION;
    vr_retorna_msg EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis auxiliares
    vr_rowid_log    ROWID;

    -- PL Tables
    vr_tab_erro             GENE0001.typ_tab_erro;

  BEGIN

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                              ,pr_action => NULL);
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
    -- Se ocorrer algum erro
    IF vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;


    OPEN cr_craplim_ctr(vr_cdcooper, pr_nrdconta, pr_nrctrlim);
    FETCH cr_craplim_ctr INTO rw_craplim_ctr;
    CLOSE cr_craplim_ctr;

    -- Verifica se a situação do Limite está 'Em Estudo' ou 'Não Aprovado'
    IF rw_craplim_ctr.insitlim not in (1,6) THEN
      vr_dscritic := 'Para esta operação, as Situações do Limite devem ser: "Em Estudo" ou "Não Aprovado".';
      RAISE vr_exc_saida;
    END IF;

    -- Verifica se a situação da Análise está 'Não Enviado' ou 'Análise Finalizada'
    IF rw_craplim_ctr.insitest not in (0,3) THEN
      vr_dscritic := 'Para esta operação, as Situações da Análise devem ser: "Não Enviado" ou "Análise Finalizada".';
      RAISE vr_exc_saida;
    END IF;

    -- Se o serviço IBRATAN está em Contingência...
    IF fn_em_contingencia_ibratan(pr_cdcooper => vr_cdcooper) THEN

      -- Rejeita Limite de Desconto de Título (Em Contingência)
      BEGIN
        UPDATE craplim
           SET insitlim = 7 -- Situação do Limite  = REJEITADO
              ,insitest = 3
              ,insitapr = 6 -- Decisão             = REJEITADO CONTINGENCIA
         WHERE cdcooper = vr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrlim = pr_nrctrlim
           AND tpctrlim = 3; -- 3 = Título
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao rejeitar limite de desconto de título. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

    -- Se o serviço IBRATAN não está em Contingência...
    ELSE

      -- Rejeita Limite de Desconto de Título (Sem Contingência)
      BEGIN
        UPDATE craplim
           SET insitlim = 7 -- Situação do Limite  = REJEITADO
              ,insitest = 3
         WHERE cdcooper = vr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrlim = pr_nrctrlim
           AND tpctrlim = 3; -- 3 = Título
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao rejeitar limite de desconto de título. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

    END IF;
    --

    -- Em caso de erro
    IF pr_des_erro <> 'OK' THEN

      vr_cdcritic:= vr_tab_erro(0).cdcritic;
      vr_dscritic:= vr_tab_erro(0).dscritic;

      RAISE vr_exc_saida;
      RETURN;

    END IF;

    -- Efetua os inserts para apresentacao na tela VERLOG
    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => 'Confirmar Rejeição do Limite de Desconto de Títulos.'
                        ,pr_dttransa => trunc(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_rowid_log);

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');


    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
      pr_des_erro := 'NOK';
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_negar_limite_desc_titulo: ' || SQLERRM;

      -- Carregar XML padrão para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END;

END pc_negar_proposta;

PROCEDURE pc_enviar_proposta_manual(pr_nrctrlim in  craplim.nrctrlim%type --> Numero do Contrato do Limite.
                                   ,pr_tpctrlim in  craplim.tpctrlim%type --> Tipo de contrato do limite
                                   ,pr_nrdconta in  crapass.nrdconta%type --> Conta do associado
                                   ,pr_dtmovito in  varchar2	             -- crapdat.dtmvtolt%type  --> Data do movimento atual
                                   ,pr_xmllog   in  varchar2              --> XML com informações de LOG
                                   ,pr_cdcritic out pls_integer           --> Codigo da critica
                                   ,pr_dscritic out varchar2              --> Descricao da critica
                                   ,pr_retxml   in  out nocopy xmltype    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo out varchar2              --> Nome do campo com erro
                                   ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                                   ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_enviar_proposta_manual
    Sistema  : Cred
    Sigla    : TELA_ATENDA_LIMDESCTIT
    Autor    : Paulo Penteado (GFT) 
    Data     : Março/2018                   Ultima atualizacao: 05/03/2018
   
    Dados referentes ao programa:
   
    Frequencia: Sempre que for chamado
    
    Objetivo  : Procedure para enviar a analise para esteira após confirmação de senha
   
    Alteração : 05/03/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   vr_dsmensag varchar2(32767);
   
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);
     
   -- Tratamento de erros
   vr_exc_saida exception;

   -- Variaveis de entrada vindas no xml
   vr_cdcooper integer;
   vr_cdoperad varchar2(100);
   vr_nmdatela varchar2(100);
   vr_nmeacao  varchar2(100);
   vr_cdagenci varchar2(100);
   vr_nrdcaixa varchar2(100);
   vr_idorigem varchar2(100);

BEGIN

   pr_des_erro := pr_xmllog; -- somente para não haver hint, caso for usado, pode remover essa linha
   pr_des_erro := 'OK';
   pr_nmdcampo := null;

   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);

   este0003.pc_enviar_analise_manual(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_cdorigem => vr_idorigem
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrctrlim => pr_nrctrlim
                                    ,pr_tpctrlim => pr_tpctrlim
                                    ,pr_dtmvtolt => pr_dtmovito
                                    ,pr_nmarquiv => null
                                    ,vr_flgdebug => 'N'
                                    ,pr_dsmensag => vr_dsmensag
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_des_erro => pr_des_erro );

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;

   vr_dsmensag := replace(replace(vr_dsmensag, '<b>', '\"'), '</b>', '\"');
   vr_dsmensag := replace(replace(vr_dsmensag, '<br>', ' '), '<BR>', ' ');
   pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                    '<Root><dsmensag>' || vr_dsmensag || '</dsmensag></Root>');
   dbms_output.put_line(vr_dsmensag);
   
   COMMIT;

EXCEPTION
  when vr_exc_saida then
       -- Se possui código de crítica e não foi informado a descrição
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descrição da crítica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;
        
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       rollback;
        
  when others then
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na ESTE0003.pc_enviar_proposta_manual: ' || sqlerrm;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       rollback;
end pc_enviar_proposta_manual;


 
PROCEDURE pc_renovar_lim_desc_titulo(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_cddlinha  IN crapldc.cddlinha%TYPE --> Código da Linha
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_renovar_lim_desc_titulo
    Sistema : Ayllos Web
    Autor   : Leonardo Oliveira (GFT)
    Data    : Março/2018                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para renovar limite de desconto de titulos.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
      
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_cddlinha VARCHAR2(100);
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
      
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
      
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        
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
      
      -- Chama rotina de renovação
      LIMI0001.pc_renovar_lim_desc_titulo(pr_cdcooper => vr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_idseqttl => pr_idseqttl
                                         ,pr_vllimite => pr_vllimite
                                         ,pr_nrctrlim => pr_nrctrlim
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdoperad => vr_cdoperad
                                         ,pr_nmdatela => vr_nmdatela
                                         ,pr_cddlinha => pr_cddlinha
                                         ,pr_idorigem => vr_idorigem
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>ok</Dados></Root>');

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_renovar_lim_desc_titulo: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_renovar_lim_desc_titulo;
      
PROCEDURE pc_obtem_dados_proposta(pr_cdcooper           in crapcop.cdcooper%type   --> Cooperativa conectada
                                 ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                 ,pr_tpctrlim           in craplim.tpctrlim%type   --> Tipo de contrato de Limite
                                 ,pr_qtregist           out integer                --> Qtde total de registros
                                 ,pr_tab_dados_proposta out typ_tab_dados_proposta --> Saida com os dados do empréstimo
                                 ,pr_cdcritic           out pls_integer            --> Codigo da critica
                                 ,pr_dscritic           out varchar2               --> Descricao da critica
                                 ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_obtem_dados_proposta
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Março/2018                   Ultima atualizacao: 26/03/2018

    Objetivo  : Procedure para carregar as informações da proposta na type

    Alteração : 26/03/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro exception;
   
   vr_idxdados pls_integer;
   vr_dtpropos date;
   
   rw_crapdat  btch0001.cr_crapdat%rowtype;
   
   cursor cr_crawlim is
   select lim.nrctrlim
         ,lim.dtpropos
         ,lim.vllimite
         ,lim.dtinivig
         ,lim.qtdiavig
         ,lim.cddlinha
         ,lim.insitlim
         ,lim.insitest
         ,lim.insitapr
         ,case lim.insitlim when 1 then 'EM ESTUDO'
                            when 2 then 'ATIVO'
                            when 3 then 'CANCELADO'
                            when 4 then 'VIGENTE'
                            when 5 then 'APROVADO'
                            when 6 then 'NAO APROVADO'
                            when 7 then 'REJEITADO'
                            else        'DIFERENTE'
          end dssitlim
         ,case lim.insitest when 0 then 'NAO ENVIADO'
                            when 1 then 'ENVIADA ANALISE AUTOMATICA'
                            when 2 then 'ENVIADA ANALISE MANUAL'
                            when 3 then 'ANALISE FINALIZADA'
                            when 4 then 'EXPIRADO'
                            else        'DIFERENTE'
          end dssitest
         ,case lim.insitapr when 0 then 'NAO ANALISADO'
                            when 1 then 'APROVADO AUTOMATICAMENTE'
                            when 2 then 'APROVADO MANUAL'
                            when 3 then 'APROVADA'
                            when 4 then 'REJEITADO MANUAL'
                            when 5 then 'REJEITADO AUTOMATICAMENTE'
                            when 6 then 'REJEITADO'
                            when 7 then 'NAO ANALISADO'
                            when 8 then 'REFAZER'
                            else        'DIFERENTE'
          end dssitapr
   from   crawlim lim
   where  lim.dtpropos >= vr_dtpropos
   and    lim.tpctrlim  = pr_tpctrlim
   and    lim.nrdconta = pr_nrdconta
   and    lim.cdcooper = pr_cdcooper;
   rw_crawlim cr_crawlim%rowtype;
   
BEGIN
   vr_cdcritic := 0;
   vr_dscritic := null;
   
   open  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
   fetch btch0001.cr_crapdat into rw_crapdat;
   if    btch0001.cr_crapdat%notfound then
         close btch0001.cr_crapdat;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
         raise vr_exc_erro;
   end   if;
   close btch0001.cr_crapdat;

   vr_dtpropos := add_months(rw_crapdat.dtmvtolt, -3);
   
   open  cr_crawlim;
   loop
         fetch cr_crawlim into rw_crawlim;
         exit  when cr_crawlim%notfound;
         
         vr_idxdados := pr_tab_dados_proposta.count() + 1;
         
         pr_tab_dados_proposta(vr_idxdados).dtpropos := rw_crawlim.dtpropos;
         pr_tab_dados_proposta(vr_idxdados).nrctrlim := rw_crawlim.nrctrlim;
         pr_tab_dados_proposta(vr_idxdados).vllimite := rw_crawlim.vllimite;
         pr_tab_dados_proposta(vr_idxdados).qtdiavig := rw_crawlim.qtdiavig;
         pr_tab_dados_proposta(vr_idxdados).cddlinha := rw_crawlim.cddlinha;
         pr_tab_dados_proposta(vr_idxdados).dssitlim := rw_crawlim.dssitlim;
         pr_tab_dados_proposta(vr_idxdados).dssitest := rw_crawlim.dssitest;
         pr_tab_dados_proposta(vr_idxdados).dssitapr := rw_crawlim.dssitapr;
         
         pr_qtregist := nvl(pr_qtregist,0) + 1;
   end   loop;
   close cr_crawlim;

EXCEPTION
   when vr_exc_erro then
        if  nvl(vr_cdcritic,0) <> 0 and trim(vr_dscritic) is null then
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        else
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
        end if;

   when others then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace('Erro pc_obtem_dados_proposta: ' || sqlerrm, chr(13)),chr(10));
END pc_obtem_dados_proposta;


PROCEDURE pc_obtem_dados_proposta_web(pr_nrdconta in crapass.nrdconta%type --> Conta do associado
                                     ,pr_xmllog   in varchar2              --> XML com informações de LOG
                                      -- OUT
                                     ,pr_cdcritic out pls_integer          --> Codigo da critica
                                     ,pr_dscritic out varchar2             --> Descric?o da critica
                                     ,pr_retxml   in out nocopy xmltype    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                     ,pr_des_erro out varchar2             --> Erros do processo
                                     ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_obtem_dados_proposta_web
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Março/2018                   Ultima atualizacao: 26/03/2018

    Objetivo  : Procedure para carregar as informações da proposta na tela

    Alteração : 26/03/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   vr_tab_dados_proposta typ_tab_dados_proposta;
   vr_qtregist           number;

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_saida exception;

   -- Variaveis de entrada vindas no xml
   vr_cdcooper integer;
   vr_cdoperad varchar2(100);
   vr_nmdatela varchar2(100);
   vr_nmeacao  varchar2(100);
   vr_cdagenci varchar2(100);
   vr_nrdcaixa varchar2(100);
   vr_idorigem varchar2(100);

   -- Variáveis para armazenar as informações em XML
   vr_des_xml         clob;
   vr_texto_completo  varchar2(32600);
   vr_index           pls_integer;

   --------------------------- SUBROTINAS INTERNAS --------------------------
   -- Subrotina para escrever texto na variável CLOB do XML
   PROCEDURE pc_escreve_xml(pr_des_dados in varchar2
                           ,pr_fecha_xml in boolean default false
                           ) IS
   BEGIN
      gene0002.pc_escreve_xml(vr_des_xml
                             ,vr_texto_completo
                             ,pr_des_dados
                             ,pr_fecha_xml);
   END;

BEGIN
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);
                           
   pc_obtem_dados_proposta(pr_cdcooper           => vr_cdcooper
                          ,pr_nrdconta           => pr_nrdconta
                          ,pr_tpctrlim           => 3
                          ,pr_qtregist           => vr_qtregist
                          ,pr_tab_dados_proposta => vr_tab_dados_proposta
                          ,pr_cdcritic           => vr_cdcritic
                          ,pr_dscritic           => vr_dscritic
                          );

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;


   vr_des_xml        := null;
   vr_texto_completo := null;
   vr_index          := vr_tab_dados_proposta.first;
   
   dbms_lob.createtemporary(vr_des_xml, true);
   dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
   
   pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>' ||
                  '<Dados qtregist="' || vr_qtregist ||'" >');

   while vr_index is not null loop
         pc_escreve_xml('<inf>' ||
                           '<dtpropos>'|| to_char(vr_tab_dados_proposta(vr_index).dtpropos, 'DD/MM/RRRR') ||'</dtpropos>'||
                           '<nrctrlim>'|| vr_tab_dados_proposta(vr_index).nrctrlim ||'</nrctrlim>'||
                           '<vllimite>'|| to_char(vr_tab_dados_proposta(vr_index).vllimite, 'FM999G999G999G990D00') ||'</vllimite>'||
                           '<qtdiavig>'|| vr_tab_dados_proposta(vr_index).qtdiavig ||'</qtdiavig>'||
                           '<cddlinha>'|| vr_tab_dados_proposta(vr_index).cddlinha ||'</cddlinha>'||
                           '<dssitlim>'|| vr_tab_dados_proposta(vr_index).dssitlim ||'</dssitlim>'||
                           '<dssitest>'|| vr_tab_dados_proposta(vr_index).dssitest ||'</dssitest>'||
                           '<dssitapr>'|| vr_tab_dados_proposta(vr_index).dssitapr ||'</dssitapr>'||
                        '</inf>');

       vr_index := vr_tab_dados_proposta.next(vr_index);
   end loop;

   pc_escreve_xml ('</Dados></Root>',true);

   pr_retxml := xmltype.createxml(vr_des_xml);

   -- Liberando a memória alocada pro CLOB
   dbms_lob.close(vr_des_xml);
   dbms_lob.freetemporary(vr_des_xml);

EXCEPTION
  when vr_exc_saida then
       -- Se possui código de crítica e não foi informado a descrição
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descrição da crítica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;

       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  when others then
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_obtem_dados_proposta_web: ' || sqlerrm;
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

END pc_obtem_dados_proposta_web;


END TELA_ATENDA_DSCTO_TIT;
/
