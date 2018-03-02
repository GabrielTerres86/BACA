CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_LIMDESCTIT IS
  /*---------------------------------------------------------------------------------------------------------------------
  
    Programa : TELA_ATENDA_LIMDESCTIT
    Sistema  : Ayllos Web
    Autor    : Paulo Penteado (GFT) 
    Data     : Mar�o - 2018                 Ultima atualizacao: 01/03/2018
  
    Dados referentes ao programa:
  
    Objetivo  : Centralizar rotinas relacionadas a tela Limite Desconto de T�tulos dentro da ATENDA
  
    Alteracoes: 01/03/2018 - Cria��o (Paulo Penteado (GFT))
                02/03/2018 - Inclus�o da Fun��o fn_em_contingencia_ibratan (Gustavo Sene (GFT))
  
  ---------------------------------------------------------------------------------------------------------------------*/

--> Procedure para validar a analise de limite, n�o permitir efetuar analise para limites antigos.
PROCEDURE pc_validar_data_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  );
  
PROCEDURE pc_analisar_proposta(pr_tpenvest in varchar2               --> Tipo do envio esteira
                              ,pr_nrctrlim in  craplim.nrctrlim%type --> Numero do Contrato do Limite.
                              ,pr_tpctrlim in  craplim.tpctrlim%type --> Tipo de contrato do limite
                              ,pr_nrdconta in  crapass.nrdconta%type --> Conta do associado
                              ,pr_dtmovito in  varchar2	             -- crapdat.dtmvtolt%type  --> Data do movimento atual
                              ,pr_xmllog   in  varchar2              --> XML com informa��es de LOG
                              ,pr_cdcritic out pls_integer           --> Codigo da critica
                              ,pr_dscritic out varchar2              --> Descricao da critica
                              ,pr_retxml   in  out nocopy xmltype    --> Arquivo de retorno do XML
                              ,pr_nmdcampo out varchar2              --> Nome do campo com erro
                              ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                              );

END TELA_ATENDA_LIMDESCTIT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_LIMDESCTIT IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : TELA_ATENDA_LIMDESCTIT
    Sistema  : Ayllos Web
    Autor    : Paulo Penteado (GFT) 
    Data     : Mar�o - 2018                 Ultima atualizacao: 01/03/2018
  
    Dados referentes ao programa:
  
    Objetivo  : Centralizar rotinas relacionadas a tela Limite Desconto de T�tulos dentro da ATENDA
  
    Alteracoes: 01/03/2018 - Cria��o (Paulo Penteado (GFT))
  
  ---------------------------------------------------------------------------------------------------------------------*/
  
PROCEDURE pc_validar_data_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_validar_data_proposta
    Sistema  : Cred
    Sigla    : TELA_ATENDA_LIMDESCTIT
    Autor    : Paulo Penteado (GFT) 
    Data     : Mar�o/2018                   Ultima atualizacao: 28/02/2018
   
    Dados referentes ao programa:
   
    Frequencia: Sempre que for chamado
    Objetivo  : Procedure para validar a analise de limite, n�o permitir efetuar analise para limites antigos.
   
    Altera��o : 28/02/2018 - Cria��o (Paulo Penteado (GFT))
  
  ---------------------------------------------------------------------------------------------------------------------*/

   -- Vari�vel de cr�ticas
   vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
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
   vr_dtviglim := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                           ,pr_cdcooper => 0
                                           ,pr_cdacesso => 'DT_VIG_LIMITE_DESC_TIT');
  
   open  cr_craplim;
   fetch cr_craplim into rw_craplim;
   if    cr_craplim%found then
         close cr_craplim;
         vr_dscritic := 'Esta proposta foi inclu�da no processo antigo. Favor cancela-la e incluir novamente atrav�s do novo processo.';
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
       pr_dscritic := replace(replace('Erro pc_valida_analise_limdesct: ' || sqlerrm, chr(13)),chr(10));

END pc_validar_data_proposta;

PROCEDURE pc_analisar_proposta(pr_tpenvest in varchar2               --> Tipo do envio esteira
                              ,pr_nrctrlim in  craplim.nrctrlim%type --> Numero do Contrato do Limite.
                              ,pr_tpctrlim in  craplim.tpctrlim%type --> Tipo de contrato do limite
                              ,pr_nrdconta in  crapass.nrdconta%type --> Conta do associado
                              ,pr_dtmovito in  varchar2-- crapdat.dtmvtolt%type  --> Data do movimento atual
                              ,pr_xmllog   in  varchar2              --> XML com informa��es de LOG
                              ,pr_cdcritic out pls_integer           --> Codigo da critica
                              ,pr_dscritic out varchar2              --> Descricao da critica
                              ,pr_retxml   in  out nocopy xmltype    --> Arquivo de retorno do XML
                              ,pr_nmdcampo out varchar2              --> Nome do campo com erro
                              ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                              ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_validar_data_proposta
    Sistema  : Cred
    Sigla    : TELA_ATENDA_LIMDESCTIT
    Autor    : Paulo Penteado (GFT) 
    Data     : Mar�o/2018                   Ultima atualizacao: 28/02/2018
   
    Dados referentes ao programa:
    Tipo do envestimento I - inclusao Proposta
                         D - Derivacao Proposta
                         A - Alteracao Proposta
                         N - Alterar Numero Proposta
                         C - Cancelar Proposta
                         E - Efetivar Proposta

    Caso a proposta j� tenha sido enviada para a Esteira iremos considerar uma Alteracao.
    Caso a proposta tenho sido reprovada pelo Motor, iremos considerar envio pois ela ainda nao foi a Esteira 
   
    Frequencia: Sempre que for chamado
    
    Objetivo  : Procedure para validar a analise de limite, n�o permitir efetuar analise para limites antigos.
   
    Altera��o : 28/02/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   vr_dsmensag varchar2(32767);
   
   -- Vari�vel de cr�ticas
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

   pr_des_erro := pr_xmllog; -- somente para n�o haver hint, caso for usado, pode remover essa linha
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

   vr_dsmensag := replace(replace(vr_dsmensag, '<br>', ' '), '<BR>', ' ');
   pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                    '<Root><dsmensag>' || vr_dsmensag || '</dsmensag></Root>');
   dbms_output.put_line(vr_dsmensag);
   
   COMMIT;

EXCEPTION
  when vr_exc_saida then
       -- Se possui c�digo de cr�tica e n�o foi informado a descri��o
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descri��o da cr�tica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;
        
       -- Atribui exce��o para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       rollback;
        
  when others then
       -- Atribui exce��o para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na ESTE0003.pc_consulta_acionamento: ' || sqlerrm;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       rollback;
end pc_analisar_proposta;

END TELA_ATENDA_LIMDESCTIT;
/