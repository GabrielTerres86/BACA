create or replace package cecred.ESTE0003 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0003
      Sistema  : Rotinas referentes a comunica�ao com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : CADA
      Autor    : Paulo Penteado (Gft)
      Data     : Mar�o/2018.                   Ultima atualizacao: 23/03/2018
      
      Dados referentes ao programa:
      Frequencia: Sempre que solicitado
      Objetivo  : Rotinas referentes a comunica�ao com a ESTEIRA de CREDITO da IBRATAN

      Alteracoes: 23/03/2018 - Alterado a referencia que era para a tabela CRAPLIM para a tabela CRAWLIM nos procedimentos 
                               Referentes a proposta. (Lindon Carlos Pecile - GFT)
                  14/04/2018 - Adicionado a procedure pc_crps703 (Paulo Penteado (GFT)) 
  
  ---------------------------------------------------------------------------------------------------------------*/

--> Tratamento de erro
vr_des_erro varchar2(4000);
vr_exc_erro exception;

--> Descri�ao e c�digo da critica
vr_cdcritic crapcri.cdcritic%type;
vr_dscritic varchar2(4000);


--> Rotina responsavel por verificar o stado de contingencia na esteira
PROCEDURE pc_verifica_contigenc_esteira(pr_cdcooper in crapcop.cdcooper%type       --> Codigo da cooperativa
                                       ,pr_flctgest out boolean                    --> Flag que indica o status de contigencia do motor.
                                       ,pr_dsmensag out varchar2                   --> Mensagem 
                                       ,pr_dscritic out varchar2                   --> Descricao da critica
                                       );

--> Rotina responsavel por verificar se o motor esta em conting�ncia
PROCEDURE pc_verifica_contigenc_motor(pr_cdcooper in crapcop.cdcooper%type         --> Codigo da cooperativa
                                     ,pr_flctgmot out boolean                      --> Flag que indica o status de contigencia do motor.
                                     ,pr_dsmensag out varchar2                     --> Mensagem 
                                     ,pr_dscritic out varchar2                     --> Descricao da critica
                                     );

--> Rotina responsavel por enviar a proposta para a esteira
procedure pc_enviar_proposta_esteira(pr_cdcooper in  crawlim.cdcooper%type             --> Codigo da cooperativa
                                    ,pr_cdagenci in  crapage.cdagenci%type             --> Codigo da agencia
                                    ,pr_cdoperad in  crapope.cdoperad%type             --> codigo do operador
                                    ,pr_idorigem in  integer                           --> Origem da operacao
                                    ,pr_tpenvest in  varchar2                          --> Tipo do envio esteira
                                    ,pr_nrctrlim in  crawlim.nrctrlim%type             --> Numero do Contrato do Limite.
                                    ,pr_tpctrlim in  crawlim.tpctrlim%type             --> Tipo de proposta do limite
                                    ,pr_nrdconta in  crapass.nrdconta%type             --> Conta do associado
                                    ,pr_dtmovito in  varchar2                          --> Data do movimento atual
                                    ,pr_dsmensag out varchar2                          --> Mensagem 
                                    ,pr_cdcritic out pls_integer                       --> Codigo da critica
                                    ,pr_dscritic out varchar2                          --> Descricao da critica
                                    ,pr_des_erro out varchar2                          --> Erros do processo OK ou NOK
                                    );

--> Rotina responsavel por executa a analise auto m�tica da esteira
procedure pc_obrigacao_analise_autom(pr_cdcooper in crapcop.cdcooper%type  --> C�d. cooperativa
                                    ,pr_inobriga out varchar2              --> Indicador de obriga�ao de an�lisa autom�tica ('S' - Sim / 'N' - Nao)
                                    ,pr_cdcritic out pls_integer           --> C�d. da cr�tica
                                    ,pr_dscritic out varchar2              --> Desc. da cr�tica
                                    );
  
procedure pc_verifica_regras(pr_cdcooper  in crawlim.cdcooper%type  --> Codigo da cooperativa                                        
                            ,pr_nrdconta  in crawlim.nrdconta%type  --> Numero da conta do cooperado
                            ,pr_nrctrlim  in crawlim.nrctrlim%type  --> Numero da Proposta 
                            ,pr_tpctrlim in crawlim.tpctrlim%type   --> Tipo de proposta do limite.
                            ,pr_tpenvest  in varchar2 default null  --> Tipo de envio
                            ,pr_cdcritic out number                 --> Codigo da critica
                            ,pr_dscritic out varchar2               --> Descricao da critica
                            );
  
--> Rotina para efetuar a deriva�ao de uma proposta para a Esteira
procedure pc_derivar_proposta(pr_cdcooper  in crawlim.cdcooper%type     --> Codigo da cooperativa
                             ,pr_cdagenci  in crapage.cdagenci%type     --> Codigo da agencia           
                             ,pr_cdoperad  in crapope.cdoperad%type     --> codigo do operador
                             ,pr_cdorigem  in integer                   --> Origem da operacao
                             ,pr_nrdconta  in crawlim.nrdconta%type     --> Numero da conta do cooperado
                             ,pr_nrctrlim  in crawlim.nrctrlim%type     --> Numero da proposta
                             ,pr_tpctrlim  in crawlim.tpctrlim%type     --> Tipo de proposta do limite
                             ,pr_dtmvtolt  in crapdat.dtmvtolt%type     --> Data do movimento
                             );
--> Rotina responsavel por incluir a proposta na esteira
procedure pc_incluir_proposta(pr_cdcooper  in crawlim.cdcooper%type     --> Codigo da cooperativa
                             ,pr_cdagenci  in crapage.cdagenci%type     --> Codigo da cooperativa
                             ,pr_cdoperad  in crapope.cdoperad%TYPE     --> codigo do operador
                             ,pr_cdorigem  in integer                   --> Origem da operacao
                             ,pr_nrdconta  in crawlim.nrdconta%type     --> Numero da conta do cooperado
                             ,pr_nrctrlim  in crawlim.nrctrlim%type     --> Numero da Proposta 
                             ,pr_tpctrlim  in crawlim.tpctrlim%type     --> Tipo de proposta do limite
                             ,pr_dtmvtolt  in crapdat.dtmvtolt%TYPE     --> Data do movimento
                             ,pr_nmarquiv  in varchar2                  --> Nome DO arquivo
                             ,pr_dsmensag out varchar2                  --> Descri�ao da mensagem
                             ,pr_cdcritic out number                    --> Codigo da cr�tica
                             ,pr_dscritic out varchar2                  --> Descri�ao da cr�tica
                             );

--> Rotina responsavel por gerar a alteracao da proposta para a esteira
procedure pc_alterar_proposta(pr_cdcooper  in crawlim.cdcooper%type  --> Codigo da cooperativa
                             ,pr_cdagenci  in crapage.cdagenci%type  --> Codigo da agencia                                          
                             ,pr_cdoperad  in crapope.cdoperad%type  --> codigo do operador
                             ,pr_cdorigem  in integer                --> Origem da operacao
                             ,pr_nrdconta  in crawlim.nrdconta%type  --> Numero da conta do cooperado
                             ,pr_nrctrlim  in crawlim.nrctrlim%type  --> Numero da proposta
                             ,pr_tpctrlim  in crawlim.tpctrlim%type  --> Tipo de proposta do limite.
                             ,pr_dtmvtolt  in crapdat.dtmvtolt%type  --> Data do movimento
                             ,pr_flreiflx  in integer                --> Indica se deve reiniciar o fluxo de aprovacao na esteira
                             ,pr_nmarquiv  in varchar2               --> Diretorio e nome do arquivo pdf da proposta
                             ,pr_cdcritic out number                 --> Codigo da critica
                             ,pr_dscritic out varchar2               --> Descricao da critica 
                             );

--> Rotina responsavel por enviar proposta para a esteira
procedure pc_enviar_analise(pr_cdcooper    in crapcop.cdcooper%type  --> Codigo da cooperativa
                           ,pr_cdagenci    in crapage.cdagenci%type  --> Codigo da agencia                                          
                           ,pr_cdoperad    in crapope.cdoperad%type  --> codigo do operador
                           ,pr_cdorigem    in integer                --> Origem da operacao
                           ,pr_nrdconta    in crawlim.nrdconta%type  --> Numero da conta do cooperado
                           ,pr_nrctrlim    in crawlim.nrctrlim%type  --> Numero da proposta
                           ,pr_dtmvtolt    in crapdat.dtmvtolt%type  --> Data do movimento                                      
                           ,pr_comprecu    in varchar2               --> Complemento do recuros da URI
                           ,pr_dsmetodo    in varchar2               --> Descricao do metodo
                           ,pr_conteudo    in clob                   --> Conteudo no Json para comunicacao
                           ,pr_dsoperacao  in varchar2               --> Operacao realizada
                           ,pr_tpenvest    in varchar2 default null  --> Tipo de envio, I-Inclusao C - Consultar(Get)
                           ,pr_dsprotocolo out varchar2              --> Protocolo retornado na requisi�ao
                           ,pr_dscritic    out varchar2
                           );

--> Rotina responsavel por a proposta para a analise manual.
procedure pc_enviar_analise_manual(pr_cdcooper    in crawlim.cdcooper%type  --> Codigo da cooperativa
                                   ,pr_cdagenci    in crapage.cdagenci%type  --> Codigo da agencia                                          
                                   ,pr_cdoperad    in crapope.cdoperad%type  --> codigo do operador
                                   ,pr_cdorigem    in integer                --> Origem da operacao
                                   ,pr_nrdconta    in crawlim.nrdconta%type  --> Numero da conta do cooperado
                                   ,pr_nrctrlim    in crawlim.nrctrlim%type  --> Numero da proposta
                                   ,pr_tpctrlim    in crawlim.tpctrlim%type  --> Tipo de proposta do limite
                                   ,pr_dtmvtolt    in VARCHAR2
                                   ,pr_nmarquiv  in varchar2                 --> Diretorio e nome do arquivo pdf da proposta
                                   ,vr_flgdebug  IN VARCHAR2                 --> Flag se debug ativo
                                   ,pr_dsmensag OUT VARCHAR2
                                   ,pr_cdcritic OUT NUMBER                --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2              --> Descricao da critica 
                                   ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                                   );
   

PROCEDURE pc_efetivar_limite_esteira(pr_cdcooper  IN crawlim.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_nrdconta  IN crawlim.nrdconta%TYPE --> Numero da conta do cooperado
                                    ,pr_nrctrlim  IN crawlim.nrctrlim%TYPE --> Numero da proposta
                                    ,pr_tpctrlim  IN crawlim.tpctrlim%TYPE --> Tipo da proposta
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo da agencia
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do operador
                                    ,pr_cdorigem  IN INTEGER               --> Codigo da Origem
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                    ---- OUT ----
                                    ,pr_cdcritic OUT NUMBER                --> Codigo da Critica
                                    ,pr_dscritic OUT VARCHAR2              --> Descri�ao da Critica
                                    );


PROCEDURE pc_crps703(pr_cdcritic OUT NUMBER   --> Codigo da Critica
                    ,pr_dscritic OUT VARCHAR2 --> Descri�ao da Critica
                    );

end ESTE0003;
/
create or replace package body cecred.ESTE0003 is

vr_dsmensag varchar2(1000);
vr_flctgest boolean;
vr_flctgmot boolean;

PROCEDURE pc_verifica_contigenc_esteira(pr_cdcooper in crapcop.cdcooper%type    --> Codigo da cooperativa
                                       ,pr_flctgest out boolean                 --> flag de contingencia da esteira
                                       ,pr_dsmensag out varchar2                --> Descri�ao da Mensagen
                                       ,pr_dscritic out varchar2                --> Descri�ao da Cr�tica
                                       ) is
   vr_contige_este VARCHAR2(500);
   vr_exc_erro EXCEPTION;
   vr_dscritic VARCHAR2(4000);
    
BEGIN  
   pr_flctgest := false;

   vr_contige_este := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'                           --> Nome DO sistema
                                               ,pr_cdcooper => pr_cdcooper                      --> Codigo da cooperativa
                                               ,pr_cdacesso => 'CONTIGENCIA_ESTEIRA_DESC');     --> C�digo de acesso. 
   if  vr_contige_este is null then
       vr_dscritic := 'Parametro CONTIGENCIA_ESTEIRA_DESC nao encontrado.';
       raise vr_exc_erro;      
   end if;
    
   if  vr_contige_este = '1' then
       pr_flctgest := true;
       pr_dsmensag := 'Aten�ao! O Envio para esteira est� em contingencia';      
   end if;
  
EXCEPTION
   when vr_exc_erro then     
        pr_dscritic := vr_dscritic;
    
   when others then
        pr_dscritic := 'Nao foi possivel buscar parametros da estira: '||sqlerrm;
END;


PROCEDURE pc_verifica_contigenc_motor(pr_cdcooper in crapcop.cdcooper%type    --> Codigo da cooperativa
                                     ,pr_flctgmot out boolean                 --> Flag de contingencia da esteira
                                     ,pr_dsmensag out varchar2                --> Decri�a~da Mensagem
                                     ,pr_dscritic out varchar2                --> Descri�ao da cr�tica
                                     ) is
   vr_contige_moto VARCHAR2(500);
   vr_exc_erro     EXCEPTION;
   vr_dscritic     VARCHAR2(4000);
    
BEGIN  
   pr_flctgmot := false; 

   vr_contige_moto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'                         --> Nome DO Sistema
                                               ,pr_cdcooper => pr_cdcooper                    --> Codigo da cooperativa
                                               ,pr_cdacesso => 'ANALISE_OBRIG_MOTOR_DESC');   --> C�digo de Acesso
   if  vr_contige_moto is null then
       vr_dscritic := 'Parametro ANALISE_OBRIG_MOTOR_DESC nao encontrado.';
       raise vr_exc_erro;      
   end if;
    
   if  vr_contige_moto = '0' then
       pr_flctgmot := true; 
       pr_dsmensag := 'Aten�ao! O Envio para o motor est� em contingencia';
   end if; 
  
EXCEPTION
   when vr_exc_erro then     
        pr_dscritic := vr_dscritic;
    
   when others then
        pr_dscritic := 'Nao foi possivel buscar parametros do motor: '||sqlerrm;
END;  

PROCEDURE pc_enviar_proposta_esteira(pr_cdcooper in  crawlim.cdcooper%type             --> Codigo da cooperativa
                                    ,pr_cdagenci in  crapage.cdagenci%type             --> Codigo da agencia
                                    ,pr_cdoperad in  crapope.cdoperad%type             --> codigo do operador
                                    ,pr_idorigem in  integer                           --> Origem da operacao
                                    ,pr_tpenvest in  varchar2                          --> Tipo do envio esteira
                                    ,pr_nrctrlim in  crawlim.nrctrlim%type             --> Numero da Proposta do Limite.
                                    ,pr_tpctrlim in  crawlim.tpctrlim%type             --> Tipo de proposta do limite
                                    ,pr_nrdconta in  crapass.nrdconta%type             --> Conta do associado
                                    ,pr_dtmovito in  varchar2                          --> Data do movimento atual
                                    ,pr_dsmensag out varchar2                          --> Mensagem 
                                    ,pr_cdcritic out pls_integer                       --> Codigo da critica
                                    ,pr_dscritic out varchar2                          --> Descricao da critica
                                    ,pr_des_erro out varchar2                          --> Erros do processo OK ou NOK
                                    ) is

  vr_dtmvtolt DATE;

  vr_cdagenci crapage.cdagenci%type; --> Codigo da agencia
  vr_inobriga varchar2(1);
  vr_tpenvest varchar2(1);
  
  --> Vari�vel de cr�ticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
    
  --> Tratamento de erros
  vr_exc_saida EXCEPTION;
  
  --> Busca do nome do associado
  cursor cr_crapass is
  select ass.nmprimtl
        ,ass.inpessoa
        ,ass.cdagenci
  from   crapass ass
  where  ass.cdcooper = pr_cdcooper
  and    ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%rowtype;

  --> busca do limite da proposta de limite
  cursor cr_crawlim is
  select lim.rowid
       , lim.*
  from   crawlim lim
  where  lim.cdcooper = pr_cdcooper  
  and    lim.nrdconta = pr_nrdconta
  and    lim.nrctrlim = pr_nrctrlim
  and    lim.tpctrlim = pr_tpctrlim;
  rw_crawlim cr_crawlim%ROWTYPE;

BEGIN
   pr_des_erro := 'OK';
   vr_tpenvest := pr_tpenvest;
   vr_dtmvtolt := TO_DATE(pr_dtmovito, 'DD/MM/YYYY');
  
  
   pc_verifica_contigenc_motor(pr_cdcooper => pr_cdcooper    --> Codigo da Cooperativa
                              ,pr_flctgmot => vr_flctgmot    --> Flag de contingencia flag de 
                              ,pr_dsmensag => pr_dsmensag    --> Flag descri�ao da mensagem
                              ,pr_dscritic => pr_dscritic);  --> Descri�ao da Cr�tica

   pc_verifica_contigenc_esteira(pr_cdcooper => pr_cdcooper   --> Codigo da Cooperativa
                                ,pr_flctgest => vr_flctgest   --> Flag de contingencia flag de 
                                ,pr_dsmensag => pr_dsmensag   --> Flag descri�ao da mensagem
                                ,pr_dscritic => pr_dscritic); --> Descri�ao da Cr�tica
                                
   if  vr_flctgmot and vr_flctgest then
       pr_cdcritic := 0;
       pr_dscritic := '';
       pr_dsmensag := 'O Motor e a Esteira estao em contingencia, efetue a an�lise manual e para efetivar pressione o botao \"Efetivar Limite\".';
       return;
   end if;
                          
   open  cr_crapass;
   fetch cr_crapass into rw_crapass;
   if    cr_crapass%notfound then
         close cr_crapass;
         vr_dscritic := 'Associado nao cadastrado. Conta: ' || pr_nrdconta;
         raise vr_exc_saida;
   end   if;
   close cr_crapass;
   
   vr_cdagenci := nvl(nullif(pr_cdagenci, 0), rw_crapass.cdagenci);
     
   open  cr_crawlim;
   fetch cr_crawlim into rw_crawlim;
   if    cr_crawlim%notfound then
         close cr_crawlim;
         vr_dscritic := 'Associado nao possui proposta de limite de credito. Conta: ' || pr_nrdconta || '.Proposta: ' || pr_nrctrlim;
         raise vr_exc_saida;
   end   if;
   close cr_crawlim;
   
   tela_atenda_dscto_tit.pc_validar_data_proposta(pr_cdcooper => pr_cdcooper          --> Codigo da Cooperativa      
                                                 ,pr_nrdconta => rw_crawlim.nrdconta  --> Numero da conta
                                                 ,pr_nrctrlim => pr_nrctrlim          --> Numero de crontrole de limite
                                                 ,pr_tpctrlim => pr_tpctrlim          --> Tipo de crontrole de limite       
                                                 ,pr_cdcritic => vr_cdcritic          --> C�digo da cr�tica
                                                 ,pr_dscritic => vr_dscritic);        --> descri�ao da cr�tica

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;

   if  vr_tpenvest = 'I' then
       vr_inobriga := 'N';
       
       --> Verificar se a proposta devera passar por analise automatica 
       pc_obrigacao_analise_autom(pr_cdcooper => pr_cdcooper    --> Codigo da Cooperativa 
                                 ,pr_inobriga => vr_inobriga    --> �ndice de Obriga�ao 
                                 ,pr_cdcritic => vr_cdcritic    --> Codigo da Critica
                                 ,pr_dscritic => vr_dscritic);  --> Descri�ao da Critica
       --> Se: 1 - Ja houve envio para a Esteira
       -->     2 - Nao precisar passar por Analise Automatica
       -->     3 - Nao existir protocolo gravado
       if  rw_crawlim.dtenvest is not null and vr_inobriga <> 'S' and (trim(rw_crawlim.dsprotoc) is null) then
           --> Significa que a proposta jah foi para a Esteira, entao devemos mandar um reinicio de Fluxo
           vr_tpenvest := 'A';
       end if;
   end if;

         
   /***** Verificar se a Esteira esta em contigencia *****/
   pc_verifica_regras(pr_cdcooper => pr_cdcooper          --> Codigo da Cooperativa 
                     ,pr_nrdconta => rw_crawlim.nrdconta  --> Numero da conta
                     ,pr_nrctrlim => pr_nrctrlim          --> Numero de crontrole de limite
                     ,pr_tpctrlim => pr_tpctrlim          --> Numero de crontrole de limite
                     ,pr_tpenvest => vr_tpenvest          --> Tipo de Envestimento
                     ,pr_cdcritic => vr_cdcritic          --> C�digo da cr�tica
                     ,pr_dscritic => vr_dscritic);        --> descri�ao da cr�tica

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;
       
   /***** INCLUIR/DERIVAR PROPOSTA *****/ 
   if  vr_tpenvest in ('I','D') then
       pc_incluir_proposta(pr_cdcooper => pr_cdcooper         --> Codigo da Cooperativa 
                          ,pr_cdagenci => vr_cdagenci         --> Numero da agencia
                          ,pr_cdoperad => pr_cdoperad         --> C�digo DO Operador
                          ,pr_cdorigem => pr_idorigem         --> C�digo da Origem
                          ,pr_nrdconta => pr_nrdconta         --> Numero da conta
                          ,pr_nrctrlim => pr_nrctrlim         --> Numero de crontrole de limite
                          ,pr_tpctrlim => pr_tpctrlim         --> Tipo DO crontrole de limite
                          ,pr_dtmvtolt => vr_dtmvtolt         --> Data DO Movimento
                          ,pr_nmarquiv => null                --> Nome DO arquivo
                          ,pr_dsmensag => pr_dsmensag         --> Descriao da Mensagem
                          ,pr_cdcritic => vr_cdcritic         --> C�digo da Critica
                          ,pr_dscritic => vr_dscritic);       --> Descri�ao da cr�tica

       if  vr_cdcritic > 0  or vr_dscritic is not null then
           raise vr_exc_saida;
       end if;
   end if;

   COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
       --> Se possui c�digo de cr�tica e nao foi informado a descri�ao
       IF  vr_cdcritic <> 0 and TRIM(vr_dscritic) IS NULL THEN
           --> Busca descri�ao da cr�tica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
        
       --> Atribui exce�ao para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_des_erro := 'NOK';

       ROLLBACK;
        
  WHEN OTHERS THEN
       --> Atribui exce�ao para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na ESTE0003.pc_enviar_proposta_esteira: ' || SQLERRM;
       pr_des_erro := 'NOK';

       ROLLBACK;
END pc_enviar_proposta_esteira;


PROCEDURE pc_obrigacao_analise_autom(pr_cdcooper in crapcop.cdcooper%type  --> C�d. cooperativa
                                    ---- OUT ----                                          
                                    ,pr_inobriga out varchar2              --> Indicador de obriga�ao de an�lisa autom�tica ('S' - Sim / 'N' - Nao)
                                    ,pr_cdcritic out pls_integer           --> C�d. da cr�tica
                                    ,pr_dscritic out varchar2) is          --> Desc. da cr�tica
vr_dsmensag varchar2(1000);
begin 
   pc_verifica_contigenc_motor(pr_cdcooper => pr_cdcooper          --> Codigo da cooperativa
                              ,pr_flctgmot => vr_flctgmot          --> Flag que indica o status de contigencia do motor.
                              ,pr_dsmensag => vr_dsmensag          --> Mensagem 
                              ,pr_dscritic => pr_dscritic);        --> Descricao da critica

   pc_verifica_contigenc_esteira(pr_cdcooper => pr_cdcooper        --> Codigo da cooperativa
                                ,pr_flctgest => vr_flctgest        --> Flag que indica o status de contigencia do motor.
                                ,pr_dsmensag => vr_dsmensag        --> Mensagem 
                                ,pr_dscritic => pr_dscritic);      --> Descricao da critica

   --> OU Esteira est� em contingencia 
   --> OU a Cooperativa nao Obriga An�lise Autom�tica
   if  vr_flctgest or vr_flctgmot then
       pr_inobriga := 'N';
   else 
       pr_inobriga := 'S';
   end if;
      
exception     
   when others then
        pr_cdcritic := 0;
        pr_dscritic := 'Erro inesperado na rotina que verifica o tipo de an�lise da proposta: '||sqlerrm;
end pc_obrigacao_analise_autom;


  --> Rotina para solicitar analises nao respondidas via POST ou solicitar a proposta enviada
  PROCEDURE pc_solicita_retorno(pr_cdcooper in crapcop.cdcooper%type
                               ,pr_nrdconta in crawlim.nrdconta%type
                               ,pr_nrctrlim in crawlim.nrctrlim%type
                               ,pr_tpctrlim in crawlim.tpctrlim%type
                               ,pr_cdagenci in crapage.cdagenci%type
                               ,pr_dsprotoc in crawlim.dsprotoc%type) is
        /* .........................................................................
    
    Programa : pc_solicita_retorno_analise
    Sistema  : 
    Sigla    : CRED
    Autor    : Paulo Penteado (GFT) 
    Data     : Fevereiro/2018                    Ultima atualizacao: 17/02/2018
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Tem como objetivo solicitar o retorno da analise no Motor
    Altera�ao : 
        
  ..........................................................................*/

  
  --> Tratamento de exce�oes
  vr_exc_erro EXCEPTION; 
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(10);
      
  --> Vari�veis auxiliares
  vr_qtsegund crapprm.dsvlrprm%TYPE;
  vr_host_esteira  VARCHAR2(4000);
  vr_recurso_este  VARCHAR2(4000);
  vr_dsdirlog      VARCHAR2(500);
  vr_chave_aplica  VARCHAR2(500);
  vr_autori_este   VARCHAR2(500);
  vr_idacionamento tbgen_webservice_aciona.idacionamento%TYPE;
  vr_nrdrowid ROWID;
  vr_dsresana VARCHAR2(100);
  vr_dssitret VARCHAR2(100);
  vr_indrisco VARCHAR2(100);
  vr_nrnotrat VARCHAR2(100);
  vr_nrinfcad VARCHAR2(100);
  vr_nrliquid VARCHAR2(100);
  vr_nrgarope VARCHAR2(100);
  vr_nrparlvr VARCHAR2(100);
  vr_nrperger VARCHAR2(100);
  vr_datscore VARCHAR2(100);
  vr_desscore VARCHAR2(100);
  vr_xmllog   VARCHAR2(4000);
  vr_retxml   xmltype;
  vr_nmdcampo VARCHAR2(100);
      
  vr_dsprotoc crawepr.dsprotoc%TYPE;
      
  --> Objeto json da proposta
  vr_obj_proposta json := json();
  vr_obj_retorno json := json();
  vr_obj_indicadores json := json();
  vr_request  json0001.typ_http_request;
  vr_response json0001.typ_http_response;
      
       --> Cursores
       rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
  --> Cooperativas com an�lise autom�tica obrigat�ria
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE cdcooper = NVL(pr_cdcooper,cdcooper)
       AND flgativo = 1
       AND GENE0001.FN_PARAM_SISTEMA('CRED',cdcooper,'ANALISE_OBRIG_MOTOR_DESC') = 1;
    
    --> Proposta sem retorno
    CURSOR cr_crawlim is
    select lim.cdcooper
          ,lim.nrdconta
          ,lim.nrctrlim
          ,lim.dsprotoc
          ,lim.dtenvest
          ,lim.hrenvest
          ,lim.insitest
          ,lim.insitapr
          ,lim.dtenvmot
          ,lim.hrenvmot
          ,lim.tpctrlim
          ,lim.rowid
    from   crawlim lim
    WHERE  lim.cdcooper = pr_cdcooper
    AND    lim.nrdconta = pr_nrdconta
    AND    lim.nrctrlim = pr_nrctrlim
    and    lim.tpctrlim = pr_tpctrlim
    AND    lim.dsprotoc = pr_dsprotoc
    AND    lim.insitest in (1,2);-- Enviadas para Analise Autom�tica ou Manual

    --> Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100);
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
              
      BEGIN
            --> Buscar todas as Coops com obrigatoriedade de An�lise Autom�tica    
  FOR rw_crapcop IN cr_crapcop LOOP
      
    --> Buscar o tempo m�ximo de espera em segundos pela analise do motor            
              vr_qtsegund := gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'TIME_RESP_MOTOR_DESC');
    
      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      --> Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        --> Montar mensagem de critica
        vr_dscritic:= gene0001.fn_busca_critica(1);
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_erro;
      ELSE
        --> Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;        
      
      --> Desde que nao estejamos com processo em execu�ao ou o dia util
      IF rw_crapdat.inproces = 1 /*AND trunc(SYSDATE) = rw_crapdat.dtmvtolt */ THEN
        
        --> Buscar DEBUG ativo ou nao
        vr_flgdebug := gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'DEBUG_MOTOR_IBRA');

        --> Se o DEBUG estiver habilitado
        IF vr_flgdebug = 'S' THEN
          --> Gravar dados log acionamento
          ESTE0001.pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,         
                                        pr_cdagenci              => pr_cdagenci,
                                        pr_cdoperad              => '1',          
                                        pr_cdorigem              => 5,          
                                        pr_nrctrprp              => 0,          
                                        pr_nrdconta              => 0,          
                                        pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                        pr_dsoperacao            => 'INICIO SOLICITA RETORNOS',       
                                        pr_dsuriservico          => NULL,       
                                        pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                                        pr_cdstatus_http         => 0,
                                        pr_dsconteudo_requisicao => null,
                                        pr_dsresposta_requisicao => null,
                                        pr_tpproduto             => 3, --> Desconto de t�tulos
                                        pr_idacionamento         => vr_idaciona,
                                        pr_dscritic              => vr_dscritic);
          --> Sem tratamento de exce�ao para DEBUG                    
          --IF TRIM(vr_dscritic) IS NOT NULL THEN
          -->  RAISE vr_exc_erro;
          --END IF;
        END IF;   
      
        --> Buscar todas as propostas enviadas para o motor e que ainda nao tenham retorno
        FOR rw_crawlim IN cr_crawlim LOOP
          
          --> Capturar o protocolo da proposta para apresentar na cr�tica caso ocorra algum erro
          vr_dsprotoc := rw_crawlim.dsprotoc;
          --> Carregar parametros para a comunicacao com a esteira
          este0001.pc_busca_param_ibra(pr_cdcooper      => rw_crawlim.cdcooper
                                      ,pr_tpenvest      => 'M'
                                      ,pr_host_esteira  => vr_host_esteira     --> Host da esteira
                                      ,pr_recurso_este  => vr_recurso_este     --> URI da esteira
                                      ,pr_dsdirlog      => vr_dsdirlog         --> Diretorio de log dos arquivos 
                                      ,pr_autori_este   => vr_autori_este      --> Authorization 
                                      ,pr_chave_aplica  => vr_chave_aplica     --> Chave de acesso
                                      ,pr_dscritic      => vr_dscritic    );       
          --> Se retornou cr�tica
          IF trim(vr_dscritic)  IS NOT NULL THEN
            --> Levantar exce�ao
            RAISE vr_exc_erro;
          END IF; 
                  
          vr_recurso_este := vr_recurso_este||'/instance/'||rw_crawlim.dsprotoc;

          vr_request.service_uri := vr_host_esteira;
          vr_request.api_route   := vr_recurso_este;
          vr_request.method      := 'GET';
          vr_request.timeout     := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_IBRA');
          
          vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
          vr_request.headers('Authorization') := vr_autori_este;
                  
          --> Se houver ApplicationKey
          IF vr_chave_aplica IS NOT NULL THEN 
            vr_request.headers('ApplicationKey') := vr_chave_aplica;
          END IF;
          
          --> Se o DEBUG estiver habilitado
          IF vr_flgdebug = 'S' THEN
            --> Gravar dados log acionamento
            ESTE0001.pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,         
                                          pr_cdagenci              => pr_cdagenci,          
                                          pr_cdoperad              => 'MOTOR',          
                                          pr_cdorigem              => 5,          
                                          pr_nrctrprp              => rw_crawlim.nrctrlim,          
                                          pr_nrdconta              => rw_crawlim.nrdconta,         
                                          pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                          pr_dsoperacao            => 'ANTES SOLICITA RETORNOS',       
                                          pr_dsuriservico          => NULL,       
                                          pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                                          pr_cdstatus_http         => 0,
                                          pr_dsconteudo_requisicao => null,
                                          pr_dsresposta_requisicao => null,
                                          pr_tpproduto             => 3, --> Desconto de t�tulos
                                          pr_idacionamento         => vr_idaciona,
                                          pr_dscritic              => vr_dscritic);
            --> Sem tratamento de exce�ao para DEBUG                    
            --IF TRIM(vr_dscritic) IS NOT NULL THEN
            -->  RAISE vr_exc_erro;
            --END IF;
          END IF;   
         
          --> Disparo do REQUEST
          json0001.pc_executa_ws_json(pr_request           => vr_request
                                     ,pr_response          => vr_response
                                     ,pr_diretorio_log     => vr_dsdirlog
                                     ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'
                                     ,pr_dscritic          => vr_dscritic); 
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF; 
          
          --> Iniciar status
          vr_dssitret := null;--'TEMPO ESGOTADO';
          
          --> HTTP 204 nao tem conte�do
          IF vr_response.status_code != 204 THEN
            --> Extrair dados de retorno
            vr_obj_retorno := json(vr_response.content);
            --> Resultado Analise Regra
            IF vr_obj_retorno.exist('resultadoAnaliseRegra') THEN
              vr_dsresana := ltrim(rtrim(vr_obj_retorno.get('resultadoAnaliseRegra').to_char(),'"'),'"');
              --> Montar a mensagem que ser� gravada no acionamento
              CASE lower(vr_dsresana)
                WHEN 'aprovar'  THEN vr_dssitret := 'APROVADO AUTOM.';
                WHEN 'reprovar' THEN vr_dssitret := 'REJEITADA AUTOM.';
                WHEN 'derivar'  THEN vr_dssitret := 'ENVIADA ANALISE MANUAL';
                WHEN 'erro'     THEN vr_dssitret := 'ERRO';
                ELSE vr_dssitret := 'DESCONHECIDA';
              END CASE;         
            END IF;  
          END IF; 

          --> Gravar dados log acionamento
          ESTE0001.pc_grava_acionamento(pr_cdcooper              => rw_crawlim.cdcooper,         
                                        pr_cdagenci              => pr_cdagenci,          
                                        pr_cdoperad              => 'MOTOR',
                                        pr_cdorigem              => 5, /*Ayllos*/
                                        pr_nrctrprp              => rw_crawlim.nrctrlim,          
                                        pr_nrdconta              => rw_crawlim.nrdconta,          
                                        pr_tpacionamento         => 2,  /* 1 - Envio, 2 � Retorno */      
                                        pr_dsoperacao            => 'RETORNO ANALISE AUTOMATICA DE CREDITO '||vr_dssitret,
                                        pr_dsuriservico          => vr_host_esteira||vr_recurso_este,       
                                        pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                                        pr_cdstatus_http         => vr_response.status_code,
                                        pr_dsconteudo_requisicao => vr_response.content,
                                        pr_dsresposta_requisicao => null,
                                        pr_dsprotocolo           => rw_crawlim.dsprotoc,
                                        pr_tpproduto             => 3, --> Desconto de t�tulos
                                        pr_idacionamento         => vr_idacionamento,
                                        pr_dscritic              => vr_dscritic);
                                       
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          IF vr_response.status_code NOT IN(200,204,429) THEN
            vr_dscritic := 'Nao foi possivel consultar informa�oes da Analise de Credito, '||
                           'favor entrar em contato com a equipe responsavel.  '|| 
                           '(Cod:'||vr_response.status_code||')';    
            RAISE vr_exc_erro;
          END IF;
                  
          --> Se recebemos o c�digo diferente de 200 
          IF vr_response.status_code != 200 THEN
            --> Checar expira�ao
            IF trunc(SYSDATE) > rw_crawlim.dtenvmot 
            OR to_number(to_char(SYSDATE, 'sssss')) - rw_crawlim.hrenvmot > vr_qtsegund THEN
              BEGIN
                UPDATE crawlim lim
                   SET lim.insitlim = 6 --> Nao aprovado
                      ,lim.insitest = 3 --> Analise Finalizada
                      ,lim.insitapr = 5 --> Rejeitado Automaticamente
                 WHERE lim.rowid = rw_crawlim.rowid;
              EXCEPTION
                WHEN OTHERS THEN 
                  vr_dscritic := 'Erro na expiracao da analise automatica: '||sqlerrm;
                  RAISE vr_exc_erro;      
              END;
                              
              --> Gerar informa�oes do log
              GENE0001.pc_gera_log(pr_cdcooper => rw_crawlim.cdcooper
                                  ,pr_cdoperad => 'MOTOR'
                                  ,pr_dscritic => ' '
                                  ,pr_dsorigem => 'AYLLOS'
                                  ,pr_dstransa => 'Expiracao da Analise Automatica'
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => 1 --> FALSE
                                  ,pr_hrtransa => gene0002.fn_busca_time
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => 'ESTEIRA'
                                  ,pr_nrdconta => rw_crawlim.nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid);                         
                  
              --> Log de item
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'insitest'
                                       ,pr_dsdadant => rw_crawlim.insitest
                                       ,pr_dsdadatu => 3);
              --> Log de item
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'insitapr'
                                       ,pr_dsdadant => rw_crawlim.insitapr
                                       ,pr_dsdadatu => 5);                                       
            END IF;
            
          ELSE
            
            --> Buscar IndicadoresCliente
            IF vr_obj_retorno.exist('indicadoresGeradosRegra') THEN
              
              vr_obj_indicadores := json(vr_obj_retorno.get('indicadoresGeradosRegra'));
            
              --> Nivel Risco Calculado --> 
              IF vr_obj_indicadores.exist('nivelRisco') THEN
                vr_indrisco := ltrim(rtrim(vr_obj_indicadores.get('nivelRisco').to_char(),'"'),'"');
              END IF;

              --> Rating Calculado --> 
              IF vr_obj_indicadores.exist('notaRating') THEN
                vr_nrnotrat := ltrim(rtrim(vr_obj_indicadores.get('notaRating').to_char(),'"'),'"');
              END IF;
                              
              --> Informa�ao Cadastral --> 
              IF vr_obj_indicadores.exist('informacaoCadastral') THEN
                vr_nrinfcad := ltrim(rtrim(vr_obj_indicadores.get('informacaoCadastral').to_char(),'"'),'"');
              END IF;

              --> Liquidez --> 
              IF vr_obj_indicadores.exist('liquidez') THEN
                vr_nrliquid := ltrim(rtrim(vr_obj_indicadores.get('liquidez').to_char(),'"'),'"');
              END IF;

              --> Garantia --> 
              IF vr_obj_indicadores.exist('garantia') THEN
                vr_nrgarope := ltrim(rtrim(vr_obj_indicadores.get('garantia').to_char(),'"'),'"');
              END IF;
                      
              --> Patrim�nio Pessoal Livre --> 
              IF vr_obj_indicadores.exist('patrimonioPessoalLivre') THEN
                vr_nrparlvr := ltrim(rtrim(vr_obj_indicadores.get('patrimonioPessoalLivre').to_char(),'"'),'"');
              END IF;

              --> Percep�ao Geral Empresa --> 
              IF vr_obj_indicadores.exist('percepcaoGeralEmpresa') THEN
                vr_nrperger := ltrim(rtrim(vr_obj_indicadores.get('percepcaoGeralEmpresa').to_char(),'"'),'"');
              END IF;
              
              --> Score Boa Vista --> 
              IF vr_obj_indicadores.exist('descricaoScoreBVS') THEN
                vr_desscore := ltrim(rtrim(vr_obj_indicadores.get('descricaoScoreBVS').to_char(),'"'),'"');
              END IF;
              
              --> Data Score Boa Vista --> 
              IF vr_obj_indicadores.exist('dataScoreBVS') THEN
                vr_datscore := ltrim(rtrim(vr_obj_indicadores.get('dataScoreBVS').to_char(),'"'),'"');
              END IF;
              
            END IF;  
            
            --> Se o DEBUG estiver habilitado
            IF vr_flgdebug = 'S' THEN
              --> Gravar dados log acionamento
              ESTE0001.pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,         
                                            pr_cdagenci              => pr_cdagenci,          
                                            pr_cdoperad              => 'MOTOR',          
                                            pr_cdorigem              => 5,          
                                            pr_nrctrprp              => rw_crawlim.nrctrlim,          
                                            pr_nrdconta              => rw_crawlim.nrdconta,         
                                            pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                            pr_dsoperacao            => 'ANTES PROCESSAMENTO RETORNO',       
                                            pr_dsuriservico          => NULL,       
                                            pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                                            pr_cdstatus_http         => 0,
                                            pr_dsconteudo_requisicao => null,
                                            pr_dsresposta_requisicao => null,
                                            pr_tpproduto             => 3, --> Desconto de t�tulos
                                            pr_idacionamento         => vr_idaciona,
                                            pr_dscritic              => vr_dscritic);
              --> Sem tratamento de exce�ao para DEBUG                    
              --IF TRIM(vr_dscritic) IS NOT NULL THEN
              -->  RAISE vr_exc_erro;
              --END IF;
            END IF; 
                        
            --> Gravar o retorno e proceder com o restante do processo p�s an�lise autom�tica
            WEBS0001.pc_retorno_analise_limdesct(pr_cdorigem => 5 /*Ayllos*/
                                                ,pr_dsprotoc => rw_crawlim.dsprotoc
                                                ,pr_nrtransa => vr_idacionamento 
                                                ,pr_dsresana => vr_dsresana
                                                ,pr_indrisco => vr_indrisco
                                                ,pr_nrnotrat => vr_nrnotrat
                                                ,pr_nrinfcad => vr_nrinfcad
                                                ,pr_nrliquid => vr_nrliquid
                                                ,pr_nrgarope => vr_nrgarope
                                                ,pr_nrparlvr => vr_nrparlvr
                                                ,pr_nrperger => vr_nrperger
                                                ,pr_desscore => vr_desscore
                                                ,pr_datscore => vr_datscore
                                                ,pr_dsrequis => vr_obj_proposta.to_char
                                                ,pr_namehost => vr_host_esteira||'/'||vr_recurso_este
                                                ,pr_xmllog   => vr_xmllog 
                                                ,pr_cdcritic => vr_cdcritic 
                                                ,pr_dscritic => vr_dscritic 
                                                ,pr_retxml   => vr_retxml   
                                                ,pr_nmdcampo => vr_nmdcampo 
                                                ,pr_des_erro => vr_des_erro );
          END IF;
          --> Efetuar commit
          COMMIT;
        END LOOP;
        --> Se o DEBUG estiver habilitado
        IF vr_flgdebug = 'S' THEN
          --> Gravar dados log acionamento
          ESTE0001.pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,         
                                        pr_cdagenci              => pr_cdagenci,          
                                        pr_cdoperad              => '1',          
                                        pr_cdorigem              => 5,          
                                        pr_nrctrprp              => 0,          
                                        pr_nrdconta              => 0,          
                                        pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                        pr_dsoperacao            => 'TERMINO SOLICITA RETORNOS',       
                                        pr_dsuriservico          => NULL,       
                                        pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                                        pr_cdstatus_http         => 0,
                                        pr_dsconteudo_requisicao => null,
                                        pr_dsresposta_requisicao => null,
                                        pr_tpproduto             => 3, --> Desconto de t�tulos
                                        pr_idacionamento         => vr_idaciona,
                                        pr_dscritic              => vr_dscritic);
          --> Sem tratamento de exce�ao para DEBUG                    
          --IF TRIM(vr_dscritic) IS NOT NULL THEN
          -->  RAISE vr_exc_erro;
          --END IF;
        END IF;
      END IF;  
      --> Grava�ao para libera�ao do registro
      COMMIT;
    END LOOP;  
      EXCEPTION
            WHEN vr_exc_erro THEN
                  --> Desfazer altera�oes
      ROLLBACK;
      --> Gerar log
                  btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 ||' - ESTE0001 --> Erro ao solicitor retorno Protocolo '
                                                 ||vr_dsprotoc||': '||vr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));

            WHEN OTHERS THEN
                  --> Desfazer altera�oes
      ROLLBACK;
      --> Gerar log
                  btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 ||' - ESTE0001 --> Erro ao solicitor retorno Protocolo '
                                                 ||vr_dsprotoc||': '||sqlerrm,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
   END pc_solicita_retorno;

  
PROCEDURE pc_verifica_regras(pr_cdcooper  IN crawlim.cdcooper%TYPE  --> Codigo da cooperativa                                        
                            ,pr_nrdconta  IN crawlim.nrdconta%TYPE  --> Numero da conta do cooperado
                            ,pr_nrctrlim  IN crawlim.nrctrlim%TYPE  --> Numero da proposta
                            ,pr_tpctrlim  in crawlim.tpctrlim%type  --> Tipo de proposta do limite.
                            ,pr_tpenvest  IN VARCHAR2 DEFAULT NULL  --> Tipo de envio
                            ,pr_cdcritic OUT NUMBER                 --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2) is           --> Descri�ao da Cr�tica
/* ..........................................................................
    
    Programa : pc_verifica_regras_esteira        
    Sistema  : 
    Sigla    : CRED
    Autor    : Paulo Penteado GFT
    Data     : Fevereiro/2018.                   Ultima atualizacao: 16/02/2018
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento para verificar as regras da esteira 
    
    Altera�ao : 
        
  ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar dados da proposta
    CURSOR cr_crawlim is
      select lim.insitest
           , lim.cdopeapr
           , lim.insitapr
      from   crawlim lim
      where  lim.cdcooper = pr_cdcooper
      and    lim.nrdconta = pr_nrdconta
      and    lim.nrctrlim = pr_nrctrlim
      and    lim.tpctrlim = pr_tpctrlim; 
    rw_crawlim cr_crawlim%ROWTYPE;
    
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;
    
  BEGIN
    --> Para inclusao, altera�ao ou deriva�ao
    IF nvl(pr_tpenvest,' ') IN ('I','A','D') THEN    
      
      --> Buscar dados da proposta
      OPEN  cr_crawlim;
      FETCH cr_crawlim INTO rw_crawlim;
      IF    cr_crawlim%NOTFOUND THEN
            CLOSE cr_crawlim;
            vr_cdcritic := 535; --> 535 - Proposta nao encontrada.
            RAISE vr_exc_erro;
      END IF;
      
      --> Somente permitir� se ainda nao enviada 
      --> OU se foi Reprovada pelo Motor
      --> ou se houve Erro Conexao
      --> OU se foi enviada e recebemos a Deriva�ao 
      IF  rw_crawlim.insitest = 0 
      OR (rw_crawlim.insitest = 3 AND rw_crawlim.insitapr = 5) 
      OR (rw_crawlim.insitest = 3 AND rw_crawlim.insitapr = 8 AND pr_tpenvest = 'I')       
      /*OR (rw_crawlim.insitest = 3 AND rw_crawlim.insitapr = 5)*/ THEN
        --> Sair pois pode ser enviada
        RETURN;
      END IF;
      --> Nao ser� poss�vel enviar/reenviar para a Esteira
      vr_dscritic := 'A proposta nao pode ser enviada para An�lise de cr�dito, verifique a situa��o da proposta!';
      RAISE vr_exc_erro;      
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        --> Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel verificar regras da An�lise de Cr�dito: '||SQLERRM;
END pc_verifica_regras;


PROCEDURE pc_derivar_proposta(pr_cdcooper  in crawlim.cdcooper%type     --> Codigo da cooperativa
                             ,pr_cdagenci  in crapage.cdagenci%type     --> Codigo da agencia           
                             ,pr_cdoperad  in crapope.cdoperad%type     --> Codigo do operador
                             ,pr_cdorigem  in integer                   --> Origem da operacao
                             ,pr_nrdconta  in crawlim.nrdconta%type     --> Numero da conta do cooperado
                             ,pr_nrctrlim  in crawlim.nrctrlim%type     --> Numero da proposta
                             ,pr_tpctrlim  in crawlim.tpctrlim%type     --> Tipo de proposta do limite
                             ,pr_dtmvtolt  in crapdat.dtmvtolt%type     --> Data do movimento
                             ) is
  /*..........................................................................
  Programa : pc_derivar_proposta_est
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Paulo Penteado (GFT) 
  Data     : fevereiro/2018                   Ultima atualizacao: 27/02/2018

  Dados referentes ao programa:

  Frequencia: Sempre que for chamado
  Objetivo  : Rotina responsavel por verificar a proposta e enviar inclusao ou altera�ao da proposta na esteira
  
  Altera�ao : 27/02/2018 cria�ao (Paulo Penteado (GFT))

  ..........................................................................*/

  --> Tratamento de erros
  vr_cdcritic number := 0;
  vr_dscritic varchar2(4000);
  vr_dsmensag varchar2(4000);
  vr_exc_erro exception;

  --> Buscar informa�oes da Proposta
  cursor cr_crawlim is
  select lim.insitest
        ,lim.insitapr
        ,lim.dtenvest
        ,lim.dsprotoc
  from   crawlim lim
  where  lim.cdcooper = pr_cdcooper
  and    lim.nrdconta = pr_nrdconta
  and    lim.nrctrlim = pr_nrctrlim
  and    lim.tpctrlim = pr_tpctrlim;
  rw_crawlim cr_crawlim%rowtype;

  --> Variaveis para DEBUG
  vr_flgdebug varchar2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
  vr_idaciona tbgen_webservice_aciona.idacionamento%type;

BEGIN
   -->  Se o DEBUG estiver habilitado
   if  vr_flgdebug = 'S' then
       ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper                    --> Codigo da cooperativa
                                    ,pr_cdagenci              => pr_cdagenci                    --> Codigo da agencia           
                                    ,pr_cdoperad              => pr_cdoperad                    --> Codigo do operador
                                    ,pr_cdorigem              => pr_cdorigem                    --> Origem da operacao
                                    ,pr_nrctrprp              => pr_nrctrlim                    --> Numero da proposta de limite
                                    ,pr_tpproduto             => 3 --> Desconto de t�tulos      --> Tipo de Produto
                                    ,pr_nrdconta              => pr_nrdconta                    --> Numero da Conta
                                    ,pr_tpacionamento         => 0  /* 0 - DEBUG */             --> Data do movimento
                                    ,pr_dsoperacao            => 'INICIO DERIVAR PROPOSTA'      --> Desxxri�ao da Opera�ao
                                    ,pr_dsuriservico          => null                           --> Descri�ao DO Servi�o           
                                    ,pr_dtmvtolt              => pr_dtmvtolt                    --> Data DO Movimento
                                    ,pr_cdstatus_http         => 0                              --> C�digo de STATUS 
                                    ,pr_dsconteudo_requisicao => null                           --> Descri�ao DO conteudo da requisi�ao
                                    ,pr_dsresposta_requisicao => null                           --> descri�ao da Resposta da requisi�ao
                                    ,pr_idacionamento         => vr_idaciona                    --> Identificadordo acionamento
                                    ,pr_dscritic              => vr_dscritic);                  --> Descri�ao da critica
       --> Sem tratamento de exce�ao para DEBUG
       --IF TRIM(vr_dscritic) IS NOT NULL THEN
       -->  RAISE vr_exc_erro;
       --END IF;
   end if;

   open  cr_crawlim;
   fetch cr_crawlim into rw_crawlim;
   close cr_crawlim;

   -->  Para Propostas ainda nao enviada para a Esteira
   if  rw_crawlim.dtenvest is null then
       --> Inclusao na esteira
       pc_incluir_proposta(pr_cdcooper => pr_cdcooper     --> Codigo da cooperativa
                          ,pr_cdagenci => pr_cdagenci     --> Codigo da agencia           
                          ,pr_cdoperad => pr_cdoperad     --> Codigo do operador
                          ,pr_cdorigem => pr_cdorigem     --> Origem da operacao
                          ,pr_nrdconta => pr_nrdconta     --> Numero da proposta de limite
                          ,pr_nrctrlim => pr_nrctrlim     --> Numero da Proposta
                          ,pr_tpctrlim => pr_tpctrlim     --> Tipo da proposta de limite
                          ,pr_dtmvtolt => pr_dtmvtolt     --> Data do movimento
                          ,pr_nmarquiv => null            --> Nome DO arquivo
                          ,pr_dsmensag => vr_dsmensag     --> Descri�ao Da mensagem
                          ,pr_cdcritic => vr_cdcritic     --> C�digo da Cr�tica
                          ,pr_dscritic => vr_dscritic);   --> Descri�ao da Critica
   else                                                       
       --> Atualiza�ao com rein�cio de fluxo                  
       pc_alterar_proposta(pr_cdcooper => pr_cdcooper     --> Codigo da cooperativa
                          ,pr_cdagenci => pr_cdagenci     --> Codigo da agencia           
                          ,pr_cdoperad => pr_cdoperad     --> Codigo do operador
                          ,pr_cdorigem => pr_cdorigem     --> Origem da operacao
                          ,pr_nrdconta => pr_nrdconta     --> Numero da proposta de limite
                          ,pr_nrctrlim => pr_nrctrlim     --> Numero da Proposta
                          ,pr_tpctrlim => pr_tpctrlim     --> Tipo da proposta de limite
                          ,pr_dtmvtolt => pr_dtmvtolt     --> Data do movimento
                          ,pr_flreiflx => 1               --> Nome DO arquivo
                          ,pr_nmarquiv => null            --> Descri�ao Da mensagem
                          ,pr_cdcritic => vr_cdcritic     --> C�digo da Cr�tica
                          ,pr_dscritic => vr_dscritic);   --> Descri�ao da Critica

   end if;

   if  nvl(vr_cdcritic,0) > 0 or vr_dscritic is not null then
       raise vr_exc_erro;
   end if;

   --> Se o DEBUG estiver habilitado
   if  vr_flgdebug = 'S' then
       ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper                  --> Codigo da cooperativa
                                    ,pr_cdagenci              => pr_cdagenci                  --> Codigo da agencia           
                                    ,pr_cdoperad              => pr_cdoperad                  --> Codigo do operador
                                    ,pr_cdorigem              => pr_cdorigem                  --> Origem da operacao
                                    ,pr_nrctrprp              => pr_nrctrlim                  --> Numero da proposta de limite
                                    ,pr_tpproduto             => 3 --> Desconto de t�tulos    --> Tipo de Produto
                                    ,pr_nrdconta              => pr_nrdconta                  --> Numero da Conta
                                    ,pr_tpacionamento         => 0  /* 0 - DEBUG */           --> Data do movimento
                                    ,pr_dsoperacao            => 'TERMINO DERIVAR PROPOSTA'   --> Desxxri�ao da Opera�ao
                                    ,pr_dsuriservico          => null                         --> Descri�ao DO Servi�o           
                                    ,pr_dtmvtolt              => pr_dtmvtolt                  --> Data DO Movimento
                                    ,pr_cdstatus_http         => 0                            --> C�digo de STATUS 
                                    ,pr_dsconteudo_requisicao => null                         --> Descri�ao DO conteudo da requisi�ao
                                    ,pr_dsresposta_requisicao => null                         --> Descri�ao da Resposta da requisi�ao
                                    ,pr_idacionamento         => vr_idaciona                  --> Identificadordo acionamento
                                    ,pr_dscritic              => vr_dscritic);                --> Descri�ao da critica
       --> Sem tratamento de exce�ao para DEBUG
       --IF TRIM(vr_dscritic) IS NOT NULL THEN
       -->  RAISE vr_exc_erro;
       --END IF;
   end if;

   COMMIT;

EXCEPTION
   when vr_exc_erro then
        --> Buscar critica
        if  nvl(vr_cdcritic,0) > 0 and trim(vr_dscritic) is null then
            --> Busca descricao
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        end if;

        --> Gerar em LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3                                                               
                                  ,pr_ind_tipo_log => 2
                                  ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')|| 
                                                      ' - WEBS0001 --> Erro ao solicitor Derivacao Automatica '||
                                                      ' do Protocolo: '||rw_crawlim.dsprotoc||
                                                      ', erro: '||vr_cdcritic||'-'||vr_dscritic
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                  ,pr_cdacesso     => 'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_flnovlog     => 'N'
                                  ,pr_flfinmsg     => 'S'
                                  ,pr_dsdirlog     => null
                                  ,pr_dstiplog     => 'O'
                                  ,pr_cdprograma   => null);

   when others then
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel realizar derivacao da proposta de An�lise de Cr�dito: '||sqlerrm;

        --> Gerar em LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2
                                  ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||
                                                      ' - WEBS0001 --> Erro ao solicitor Derivacao Automatica '||
                                                      ' do Protocolo: '||rw_crawlim.dsprotoc||
                                                      ', erro: '||vr_cdcritic||'-'||vr_dscritic
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                  ,pr_cdacesso     => 'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_flnovlog     => 'N'
                                  ,pr_flfinmsg     => 'S'
                                  ,pr_dsdirlog     => null
                                  ,pr_dstiplog     => 'O'
                                  ,pr_cdprograma   => null);
END pc_derivar_proposta;


PROCEDURE pc_incluir_proposta(pr_cdcooper  IN crawlim.cdcooper%TYPE   --> Codigo da cooperativa
                             ,pr_cdagenci  IN crapage.cdagenci%TYPE   --> Codigo da agencia           
                             ,pr_cdoperad  IN crapope.cdoperad%TYPE   --> Codigo do operador
                             ,pr_cdorigem  IN INTEGER                 --> Origem da operacao
                             ,pr_nrdconta  IN crawlim.nrdconta%TYPE   --> Numero da proposta de limite
                             ,pr_nrctrlim  IN crawlim.nrctrlim%TYPE   --> Numero da Proposta
                             ,pr_tpctrlim  in crawlim.tpctrlim%type   --> Tipo da proposta de limite
                             ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE   --> Data do movimento
                             ,pr_nmarquiv  IN VARCHAR2                --> Nome DO arquivo
                             ,pr_dsmensag OUT VARCHAR2                --> Descri�ao Da mensagem
                             ,pr_cdcritic OUT NUMBER                  --> C�digo da Cr�tica
                             ,pr_dscritic OUT VARCHAR2) IS            --> Descri�ao da Critica
  /* ...........................................................................
  
    Programa : pc_incluir_proposta_est        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Lindon Carlos Pecile - GFT-Brasil
    Data     : Fevereiro/2018.          Ultima atualizacao: 10/02/2018
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina responsavel por gerar a inclusao da proposta para a esteira    
    Altera�ao : 
                13/07/2017 - P337 - Ajustes para envio ao Motor - Marcos(Supero)
        
                15/12/2017 - P337 - SM - Ajustes no envio para retormar rein�cio 
                             de fluxo (Marcos-Supero)        
  ..........................................................................*/
    
  ----------- VARIAVEIS <-----------
  --> Tratamento de erros
  vr_cdcritic NUMBER := 0;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
    
  vr_obj_proposta json := json();
  vr_obj_proposta_clob clob;
    
  vr_dsprotoc VARCHAR2(1000);
  vr_comprecu VARCHAR2(1000);
    
  --> Buscar informa�oes da Proposta
  cursor cr_crawlim is
  select lim.insitest
        ,lim.insitapr
        ,lim.cdopeapr
        ,ass.cdagenci
        ,lim.nrctaav1
        ,lim.nrctaav2
        ,ass.inpessoa
        ,lim.dsprotoc
        ,lim.cddlinha
        ,lim.tpctrlim
        ,lim.rowid
  from   crapass ass
        ,crawlim lim
  where  ass.cdcooper = lim.cdcooper
  and    ass.nrdconta = lim.nrdconta
  and    lim.cdcooper = pr_cdcooper
  and    lim.nrdconta = pr_nrdconta
  and    lim.nrctrlim = pr_nrctrlim
  and    lim.tpctrlim = pr_tpctrlim;
  rw_crawlim cr_crawlim%ROWTYPE;
    
  --> Acionamentos de retorno
  cursor cr_aciona_retorno(pr_dsprotocolo varchar2) is
    select ac.dsconteudo_requisicao
    from   tbgen_webservice_aciona ac
    where  ac.cdcooper      = pr_cdcooper
    and    ac.nrdconta      = pr_nrdconta
    and    ac.nrctrprp      = pr_nrctrlim
    and    ac.dsprotocolo   = pr_dsprotocolo
    and    ac.tpacionamento = 2; 
  --> Somente Retorno
  vr_dsconteudo_requisicao tbgen_webservice_aciona.dsconteudo_requisicao%TYPE;
    
  --> Hora de Envio
  vr_hrenvest crawlim.hrenvest%TYPE;
  --> Quantidade de segundos de Espera
  vr_qtsegund NUMBER;
  --> Analise finalizada
  vr_flganlok boolean := FALSE;
    
  --> Objetos para retorno das mensagens
  vr_obj     cecred.json := json();
  vr_obj_anl cecred.json := json();
  vr_obj_lst cecred.json_list := json_list();
  vr_obj_msg cecred.json := json();
  vr_destipo varchar2(1000);
  vr_desmens varchar2(4000);
  vr_dsmensag VARCHAR2(32767);
    
  --> Variaveis para DEBUG
  vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
  vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
    
BEGIN    
    
  --> Se o DEBUG estiver habilitado
  IF vr_flgdebug = 'S' THEN
    --> Gravar dados log acionamento
    ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,                    --> Codigo da cooperativa              
                                  pr_cdagenci              => pr_cdagenci,                    --> Codigo da agencia           
                                  pr_cdoperad              => pr_cdoperad,                    --> Codigo do operador
                                  pr_cdorigem              => pr_cdorigem,                    --> Origem da operacao
                                  pr_nrctrprp              => pr_nrctrlim,                    --> Numero da proposta de limite
                                  pr_nrdconta              => pr_nrdconta,                    --> Numero da Conta
                                  pr_tpacionamento         => 0,  /* 0 - DEBUG */             --> Tipo de Acionamento
                                  pr_dsoperacao            => 'INICIO INCLUIR PROPOSTA',      --> Descri�ao da Opera�ao
                                  pr_dsuriservico          => NULL,                           --> Descri�ao DO Servi�o           
                                  pr_dtmvtolt              => pr_dtmvtolt,                    --> Data DO Movimento
                                  pr_cdstatus_http         => 0,                              --> C�digo de STATUS 
                                  pr_dsconteudo_requisicao => null,                           --> Descri�ao DO conteudo da requisi�ao
                                  pr_dsresposta_requisicao => null,                           --> Descri�ao da Resposta da requisi�ao
                                  pr_tpproduto             => 3, --> Desconto de t�tulos      --> Tipo DO Produto
                                  pr_idacionamento         => vr_idaciona,                    --> Identificadordo acionamento
                                  pr_dscritic              => vr_dscritic);                   --> Descri�ao da critica
                                 
    --> Sem tratamento de exce�ao para DEBUG                    
    --IF TRIM(vr_dscritic) IS NOT NULL THEN
    -->  RAISE vr_exc_erro;
    --END IF;
  END IF; 
  
  --> Buscar informa�oes da proposta
  OPEN cr_crawlim;
  FETCH cr_crawlim INTO rw_crawlim;
  CLOSE cr_crawlim;
    
  pc_verifica_contigenc_motor(pr_cdcooper => pr_cdcooper      --> Codigo da Cooperativa
                             ,pr_flctgmot => vr_flctgmot      --> Codigo da Cooperativa
                             ,pr_dsmensag => pr_dsmensag      --> Codigo da Cr�tica
                             ,pr_dscritic => pr_dscritic);    --> Descri�ao da Cr�tica
  
  --> Se Obrigatorio e ainda nao Enviada ou Enviada mas com Erro Conexao
  IF not(vr_flctgmot) AND (rw_crawlim.insitest = 0 OR rw_crawlim.insitapr = 8) THEN 
      
    --> Gerar informa�oes no padrao JSON da proposta          
    ESTE0004.pc_gera_json_analise_lim(pr_cdcooper  => pr_cdcooper           --> Codigo da cooperativa    
                                     ,pr_cdagenci  => rw_crawlim.cdagenci   --> Codigo da Agencia
                                     ,pr_nrdconta  => pr_nrdconta           --> Numero da Conta
                                     ,pr_nrctrlim  => pr_nrctrlim           --> Numero da Porposta de Limite
                                     ,pr_tpctrlim  => pr_tpctrlim           --> Tipo Da Proposta de Limite
                                     ,pr_nrctaav1  => rw_crawlim.nrctaav1   --> 
                                     ,pr_nrctaav2  => rw_crawlim.nrctaav2   --> 
                                     ,pr_dsjsonan  => vr_obj_proposta       --> Retorno do clob em modelo json das informa�oes
                                     ,pr_cdcritic  => vr_cdcritic           --> Codigo da critica
                                     ,pr_dscritic  => vr_dscritic);         --> Descricao da critica
      
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;        
    END IF;           
      
    --> Efetuar montagem do nome do Fluxo de An�lise Automatica conforme o tipo de pessoa da Proposta
    IF rw_crawlim.inpessoa = 1 THEN 
      vr_comprecu := '/definition/'|| gene0001.fn_param_sistema('CRED'
                                                                ,pr_cdcooper
                                                                ,'REGRA_ANL_MOTOR_PF_DESC')||'/start';    
    ELSE
      vr_comprecu := '/definition/'|| gene0001.fn_param_sistema('CRED'
                                                                ,pr_cdcooper
                                                                ,'REGRA_ANL_MOTOR_PJ_DESC')||'/start';            
    END IF;    
          
                                                          
    --> Criar o CLOB para converter JSON para CLOB
    dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
    json.to_clob(vr_obj_proposta,vr_obj_proposta_clob);
      
    --> Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,                      --> Codigo da cooperativa               
                                    pr_cdagenci              => pr_cdagenci,                      --> Codigo da agencia           
                                    pr_cdoperad              => pr_cdoperad,                      --> Codigo do operador
                                    pr_cdorigem              => pr_cdorigem,                      --> Origem da operacao
                                    pr_nrctrprp              => pr_nrctrlim,                      --> Numero da proposta de limite
                                    pr_nrdconta              => pr_nrdconta,                      --> Numero da Conta
                                    pr_tpacionamento         => 0,  /* 0 - DEBUG */               --> Tipo de Acionamento
                                    pr_dsoperacao            => 'ANTES ENVIAR PROPOSTA',          --> Descri�ao da Opera�ao
                                    pr_dsuriservico          => NULL,                             --> Descri�ao DO Servi�o           
                                    pr_dtmvtolt              => pr_dtmvtolt,                      --> Data DO Movimento
                                    pr_cdstatus_http         => 0,                                --> C�digo de STATUS 
                                    pr_dsconteudo_requisicao => vr_obj_proposta_clob,             --> Descri�ao DO conteudo da requisi�ao
                                    pr_dsresposta_requisicao => null,                             --> Descri�ao da Resposta da requisi�ao
                                    pr_tpproduto             => 3, --> Desconto de t�tulos        --> Tipo DO Produto
                                    pr_idacionamento         => vr_idaciona,                      --> Identificadordo acionamento
                                    pr_dscritic              => vr_dscritic);                     --> Descri�ao da critica
      --> Sem tratamento de exce�ao para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      -->  RAISE vr_exc_erro;
      --END IF;
    END IF;       
      
    --> Enviar dados para An�lise Autom�tica Esteira (Motor)
    pc_enviar_analise(pr_cdcooper    => pr_cdcooper                                               --> Codigo da cooperativa               
                     ,pr_cdagenci    => pr_cdagenci                                               --> Codigo da agencia           
                     ,pr_cdoperad    => pr_cdoperad                                               --> Codigo do operador
                     ,pr_cdorigem    => pr_cdorigem                                               --> Origem da operacao
                     ,pr_nrdconta    => pr_nrdconta                                               --> Numero da Conta
                     ,pr_nrctrlim    => pr_nrctrlim                                               --> Numero da Poposta
                     ,pr_dtmvtolt    => pr_dtmvtolt                                               --> Data DO Movimento
                     ,pr_comprecu    => vr_comprecu                                               --> 
                     ,pr_dsmetodo    => 'POST'                                                    --> Descri�ao DO Metodo           
                     ,pr_conteudo    => vr_obj_proposta_clob                                      --> Conteudo da proposta
                     ,pr_dsoperacao  => 'ENVIO DA PROPOSTA PARA ANALISE AUTOMATICA DE CREDITO'    --> Descri�ao da Opera�ao
                     ,pr_tpenvest    => 'M'                                                       --> Tipo de Envestimento
                     ,pr_dsprotocolo => vr_dsprotoc                                               --> Descri�ao DO PRotoco�o
                     ,pr_dscritic    => vr_dscritic);                                             --> Descri�ao da critica
                                                                                                  
    --> Liberando a mem�ria alocada pro CLOB                                                       
    dbms_lob.close(vr_obj_proposta_clob);
    dbms_lob.freetemporary(vr_obj_proposta_clob);                        
                        
    --> verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
      
    --> Atualizar a proposta
    vr_hrenvest := to_char(SYSDATE,'sssss');
    BEGIN
      UPDATE crawlim lim 
         SET lim.insitest = 2, --> Enviada Analise Manual 1, --> Enviada para Analise Autom
             lim.dtenvmot = trunc(SYSDATE), 
             lim.hrenvmot = vr_hrenvest,
             lim.cdopeste = pr_cdoperad,
             lim.dsprotoc = nvl(vr_dsprotoc,' '),
             lim.insitapr = 0,
             lim.cdopeapr = NULL,
             lim.dtaprova = NULL,
             lim.hraprova = 0
       WHERE lim.rowid = rw_crawlim.rowid;
    EXCEPTION    
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da An�lise Autom�tica de Cr�dito: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    --> Efetuar grava�ao
    COMMIT;
      
    --> Buscar a quantidade de segundos de espera pela An�lise Autom�tica
    vr_qtsegund := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'TIME_RESP_MOTOR_DESC'),30);

    --> Efetuar la�o para esperarmos (N) segundos ou o termino da analise recebido via POST
    WHILE NOT vr_flganlok AND to_number(to_char(sysdate,'sssss')) - vr_hrenvest < vr_qtsegund LOOP

      --> Aguardar 0.5 segundo para evitar sobrecarga de processador
      sys.dbms_lock.sleep(0.5);
        
      --> Verificar se a analise jah finalizou 
      OPEN cr_crawlim;
      FETCH cr_crawlim INTO rw_crawlim;
      CLOSE cr_crawlim;
        
      --> Se a proposta mudou de situa�ao Esteira
      IF rw_crawlim.insitest <> 2 THEN 
        --> Indica que terminou a analise 
        vr_flganlok := true;
      END IF;

    END LOOP;
      
    --> Se chegarmos neste ponto e a analise nao voltou OK signifca que houve timeout
    IF NOT vr_flganlok THEN 
      --> Entao acionaremos a rotina que solicita via GET o termino da an�lise
      --> e caso a mesma ainda nao tenha terminado, a proposta ser� salva como Expirada
      pc_solicita_retorno(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrctrlim => pr_nrctrlim
                         ,pr_tpctrlim => pr_tpctrlim
                         ,pr_cdagenci => pr_cdagenci
                         ,pr_dsprotoc => vr_dsprotoc);
    END IF;
      
    --> Reconsultar a situa�ao esteira e parecer para retorno
    OPEN  cr_crawlim;
    FETCH cr_crawlim INTO rw_crawlim;
    CLOSE cr_crawlim;
    
    --> Se houve expira�ao
    if    rw_crawlim.insitest = 0 then 
          pr_dsmensag := '<b>Nao enviado</b>';
    elsif rw_crawlim.insitest = 1 then 
          pr_dsmensag := '<b>Enviado para analise automatica</b>';
    elsif rw_crawlim.insitest = 2 then 
          pr_dsmensag := '<b>Enviada para analise manual</b>';
    elsif rw_crawlim.insitest = 3 then 
          --> Conforme tipo de aprovacao
          if    rw_crawlim.insitapr = 0 then 
                pr_dsmensag := '<b>Nao analisado</b>';
          elsif rw_crawlim.insitapr = 1 then
                pr_dsmensag := '<b>Aprovado automaticamente</b>';
          elsif rw_crawlim.insitapr = 2 then 
                pr_dsmensag := '<b>Aprovado manual</b>';          
          elsif rw_crawlim.insitapr = 3 then 
                pr_dsmensag := '<b>Aprovada contigencia</b>';        
          elsif rw_crawlim.insitapr = 4 then
                pr_dsmensag := '<b>Rejeitado manual</b>';
          elsif rw_crawlim.insitapr = 5 then
                pr_dsmensag := '<b>Rejeitado automaticamente</b>';
          elsif rw_crawlim.insitapr = 6 then
                pr_dsmensag := '<b>Rejeitado Contigencia</b>';
          elsif rw_crawlim.insitapr = 7 then
                pr_dsmensag := '<b>Nao analisado</b>';
          elsif rw_crawlim.insitapr = 8 then
                pr_dsmensag := '<b>Refazer</b>';
          end   if;
    end if; 
      
    --> Gerar mensagem padrao:
    pr_dsmensag := 'Resultado da Avalia�ao: '||pr_dsmensag;
      
    -->  Se houver protocolo e a analise foi encerrada ou derivada
    if  vr_dsprotoc is not null and rw_crawlim.insitest in (2,3) then 
        -->    Buscar os detalhes do acionamento de retorno
        open  cr_aciona_retorno(vr_dsprotoc);
        fetch cr_aciona_retorno into vr_dsconteudo_requisicao;
        if    cr_aciona_retorno%found then 
              --> Processar as mensagens para adicionar ao retorno
              begin 
                 --> Efetuar cast para JSON
                 vr_obj := json(vr_dsconteudo_requisicao);            

                 -->  Se existe o objeto de analise
                 if  vr_obj.exist('analises') then
                     vr_obj_anl := json(vr_obj.get('analises').to_char());        
                     
                     -->  Se existe a lista de mensagens
                     if  vr_obj_anl.exist('mensagensDeAnalise') then
                         vr_obj_lst := json_list(vr_obj_anl.get('mensagensDeAnalise').to_char());

                         -->   Para cada mensagem 
                         for vr_idx in 1..vr_obj_lst.count() loop
                             begin
                                vr_obj_msg := json( vr_obj_lst.get(vr_idx));
                                
                                -->  Se encontrar o atributo texto e tipo
                                if  vr_obj_msg.exist('texto') and vr_obj_msg.exist('tipo') then
                                    vr_desmens := gene0007.fn_convert_web_db(unistr(replace(rtrim(ltrim(vr_obj_msg.get('texto').to_char(),'"'),'"'),'\u','\')));
                                    vr_destipo := replace(rtrim(ltrim(vr_obj_msg.get('tipo').to_char(),'"'),'"'),'ERRO','REPROVAR');
                                end if;

                                if  vr_destipo <> 'DETALHAMENTO' then
                                    vr_dsmensag := vr_dsmensag || '<BR>['||vr_destipo||'] '||vr_desmens;                              
                                end if;
                             exception
                                when others then
                                     null; --> Ignorar essa linha
                             end;
                         end loop;
                     end if;
                 end if;
              exception
                 when others then 
                      null; --> Ignorar se o conteudo nao for JSON nao conseguiremos ler as mensagens
              end; 
        end   if;
        close cr_aciona_retorno;           

        -->  Se nao encontrou mensagem
        if  vr_dsmensag is null then 
            --> Usar mensagem padrao
            vr_dsmensag := '<br>Obs: Clique no bot�o <b>[Detalhes Proposta]</b> para visualiza��o de mais detalhes';
        else
            --> Gerar texto padrao 
            vr_dsmensag := '<br>Detalhes da decis�o:<br>###'|| vr_dsmensag;
        end if;

        pr_dsmensag := pr_dsmensag ||vr_dsmensag;
    end if;
      
    --> Commitar o encerramento da rotina 
    COMMIT;
      
  ELSE
    pc_enviar_analise_manual(pr_cdcooper => pr_cdcooper      --> Codigo da cooperativa
                            ,pr_cdagenci => pr_cdagenci      --> Codigo da agencia                                          
                            ,pr_cdoperad => pr_cdoperad      --> codigo do operador
                            ,pr_cdorigem => pr_cdorigem      --> Origem da operacao
                            ,pr_nrdconta => pr_nrdconta      --> Numero da conta do cooperado
                            ,pr_nrctrlim => pr_nrctrlim      --> Numero da proposta
                            ,pr_tpctrlim => pr_tpctrlim      --> Tipo de proposta de limite
                            ,pr_dtmvtolt => pr_dtmvtolt      --> Data do movimento
                            ,pr_nmarquiv => pr_nmarquiv      --> Indica se deve reiniciar o fluxo de aprovacao na esteira
                            ,vr_flgdebug => vr_flgdebug      --> Diretorio e nome do arquivo pdf da proposta
                            ,pr_dsmensag => pr_dsmensag      
                            ,pr_cdcritic => vr_cdcritic      
                            ,pr_dscritic => vr_dscritic      --> Descricao da critica 
                            ,pr_des_erro => vr_des_erro);    -- Descri�a� do ee
                                   
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;        
    END IF;
  END IF;  
    
  COMMIT;   
    
EXCEPTION
  WHEN vr_exc_erro THEN
      
    --> Buscar critica
    IF nvl(vr_cdcritic,0) > 0 AND 
      TRIM(vr_dscritic) IS NULL THEN
      --> Busca descricao        
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
    END IF;  
      
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
    
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Nao foi possivel realizar inclusao da proposta de An�lise de Cr�dito: '||SQLERRM;
END pc_incluir_proposta;

  --> Rotina responsavel por gerar a alteracao da proposta para a esteira
  procedure pc_alterar_proposta(pr_cdcooper  in crawlim.cdcooper%type  --> Codigo da cooperativa
                               ,pr_cdagenci  in crapage.cdagenci%type  --> Codigo da agencia                                          
                               ,pr_cdoperad  in crapope.cdoperad%type  --> codigo do operador
                               ,pr_cdorigem  in integer                --> Origem da operacao
                               ,pr_nrdconta  in crawlim.nrdconta%type  --> Numero da conta do cooperado
                               ,pr_nrctrlim  in crawlim.nrctrlim%type  --> Numero da proposta
                               ,pr_tpctrlim  in crawlim.tpctrlim%type  --> Tipo de proposta de limite
                               ,pr_dtmvtolt  in crapdat.dtmvtolt%type  --> Data do movimento
                               ,pr_flreiflx  in integer                --> Indica se deve reiniciar o fluxo de aprovacao na esteira
                               ,pr_nmarquiv  in varchar2               --> Diretorio e nome do arquivo pdf da proposta
                               ,pr_cdcritic out number                 --> Codigo da critica
                               ,pr_dscritic out varchar2               --> Descricao da critica 
                               ) is
    /* ..........................................................................
    
      Programa : pc_alterar_proposta_est        
      Sistema  : 
      Sigla    : CRED
      Autor    : Paulo Penteado (GFT) 
      Data     : Fevereiro/2018.                   Ultima atualizacao: 17/02/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a alteracao da proposta para a esteira    
      Altera�ao : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    --> Buscar operador
    CURSOR cr_crapope (pr_cdcooper  crapope.cdcooper%TYPE,
                       pr_cdoperad  crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);
    
    rw_crapope cr_crapope%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    --> Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_dsmensag VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
      
    --> Objeto json da proposta
    vr_obj_alter    json := json();
    vr_obj_proposta json := json();
    vr_obj_agencia  json := json();  
            vr_dsprotocolo  VARCHAR2(1000);
    vr_obj_proposta_clob clob;
    
    --> Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;    
    
  BEGIN                  
    
    --> Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                                    pr_cdagenci              => pr_cdagenci,          
                                    pr_cdoperad              => pr_cdoperad,          
                                    pr_cdorigem              => pr_cdorigem,          
                                    pr_nrctrprp              => pr_nrctrlim,          
                                    pr_nrdconta              => pr_nrdconta,          
                                    pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                    pr_dsoperacao            => 'INICIO ALTERAR PROPOSTA',       
                                    pr_dsuriservico          => NULL,       
                                    pr_dtmvtolt              => pr_dtmvtolt,       
                                    pr_cdstatus_http         => 0,
                                    pr_dsconteudo_requisicao => null,
                                    pr_dsresposta_requisicao => null,
                                    pr_tpproduto             => 3, --> Desconto de t�tulos
                                    pr_idacionamento         => vr_idaciona,
                                    pr_dscritic              => vr_dscritic);
      --> Sem tratamento de exce�ao para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      -->  RAISE vr_exc_erro;
      --END IF;
    END IF;   
  
    --> Gerar informa�oes no padrao JSON da proposta
    este0004.pc_gera_json_proposta_lim(pr_cdcooper  => pr_cdcooper
                                      ,pr_cdagenci  => pr_cdagenci
                                      ,pr_cdoperad  => pr_cdoperad
                                      ,pr_nrdconta  => pr_nrdconta
                                      ,pr_nrctrlim  => pr_nrctrlim
                                      ,pr_tpctrlim  => pr_tpctrlim
                                      ,pr_nmarquiv  => pr_nmarquiv  --> Diretorio e nome do arquivo pdf da proposta
                                      ,pr_proposta  => vr_obj_proposta  --> Retorno do clob em modelo json da proposta
                                      ,pr_cdcritic  => vr_cdcritic
                                      ,pr_dscritic  => vr_dscritic);
    
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;        
    END IF;  
    
    --> Buscar dados do operador
    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; --> 067 - Operador nao cadastrado.
      RAISE vr_exc_erro; 
    ELSE
      CLOSE cr_crapope;
    END IF;        
    
    --> Incluir objeto proposta
    vr_obj_alter.put('dadosAtualizados'      ,vr_obj_proposta);
    vr_obj_alter.put('operadorAlteracaoLogin',lower(pr_cdoperad));
    vr_obj_alter.put('operadorAlteracaoNome' ,rw_crapope.nmoperad) ;
    vr_obj_alter.put('dataHora'              ,este0001.fn_DataTempo_ibra(SYSDATE)) ;
    vr_obj_alter.put('reiniciaFluxo'         ,(pr_flreiflx = 1) ) ;
    
    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo'   , pr_cdcooper);
    vr_obj_agencia.put('PACodigo'            , pr_cdagenci);    
    vr_obj_alter.put('operadorAlteracaoPA'      , vr_obj_agencia);
    
    --> Criar o CLOB para converter JSON para CLOB
    dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
    json.to_clob(vr_obj_alter,vr_obj_proposta_clob);
    
    --> Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                                    pr_cdagenci              => pr_cdagenci,          
                                    pr_cdoperad              => pr_cdoperad,          
                                    pr_cdorigem              => pr_cdorigem,          
                                    pr_nrctrprp              => pr_nrctrlim,          
                                    pr_nrdconta              => pr_nrdconta,          
                                    pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                    pr_dsoperacao            => 'ANTES ALTERAR PROPOSTA',       
                                    pr_dsuriservico          => NULL,       
                                    pr_dtmvtolt              => pr_dtmvtolt,       
                                    pr_cdstatus_http         => 0,
                                    pr_dsconteudo_requisicao => vr_obj_proposta_clob,
                                    pr_dsresposta_requisicao => null,
                                    pr_tpproduto             => 3, --> Desconto de t�tulos
                                    pr_idacionamento         => vr_idaciona,
                                    pr_dscritic              => vr_dscritic);
      --> Sem tratamento de exce�ao para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      -->  RAISE vr_exc_erro;
      --END IF;
    END IF;  
    
    --> Enviar dados para Esteira
    pc_enviar_analise(pr_cdcooper    => pr_cdcooper
                     ,pr_cdagenci    => pr_cdagenci
                     ,pr_cdoperad    => pr_cdoperad
                     ,pr_cdorigem    => pr_cdorigem
                     ,pr_nrdconta    => pr_nrdconta
                     ,pr_nrctrlim    => pr_nrctrlim
                     ,pr_dtmvtolt    => pr_dtmvtolt
                     ,pr_comprecu    => null
                     ,pr_dsmetodo    => 'PUT'
                     ,pr_conteudo    => vr_obj_proposta_clob
                     ,pr_dsoperacao  => 'REENVIO DA PROPOSTA PARA ANALISE DE CREDITO'
                     ,pr_dsprotocolo => vr_dsprotocolo
                     ,pr_dscritic    => vr_dscritic);
    
    --> Se nao houve erro
    IF vr_dscritic IS NULL THEN 
    
    --> Atualizar proposta
    begin
      update crawlim lim 
      set    lim.insitest = 2 -->  2 � Reenviado para Analise
            ,lim.dtenvest = trunc(sysdate)
            ,lim.hrenvest = to_char(sysdate,'sssss')
            ,lim.cdopeste = pr_cdoperad
            ,lim.dsprotoc = nvl(vr_dsprotocolo,' ')
            ,lim.insitapr = 0
            ,lim.cdopeapr = null
            ,lim.dtaprova = null
            ,lim.hraprova = 0
      where  lim.cdcooper = pr_cdcooper
      and    lim.nrdconta = pr_nrdconta
      and    lim.nrctrlim = pr_nrctrlim
      and    lim.tpctrlim = pr_tpctrlim;
    exception    
      when others then
        vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da Analise de Credito: '||sqlerrm;
    end;         

    
    --> Caso tenhamos recebido critica de Proposta jah existente na Esteira
    ELSIF lower(vr_dscritic) LIKE '%proposta nao encontrada%' THEN

      --> Tentaremos enviar inclusao novamente na Esteira
      pc_incluir_proposta(pr_cdcooper => pr_cdcooper
                         ,pr_cdagenci => pr_cdagenci
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_cdorigem => pr_cdorigem
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrctrlim => pr_nrctrlim
                         ,pr_tpctrlim => pr_tpctrlim
                         ,pr_dtmvtolt => pr_dtmvtolt
                         ,pr_nmarquiv => NULL
                         ,pr_dsmensag => vr_dsmensag
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
    END IF;  

    --> verificar se retornou critica
    IF  vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF; 
    
    
    --> Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      --> Gravar dados log acionamento
      ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                                    pr_cdagenci              => pr_cdagenci,          
                                    pr_cdoperad              => pr_cdoperad,          
                                    pr_cdorigem              => pr_cdorigem,          
                                    pr_nrctrprp              => pr_nrctrlim,          
                                    pr_nrdconta              => pr_nrdconta,          
                                    pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                    pr_dsoperacao            => 'TERMINO ALTERAR PROPOSTA',       
                                    pr_dsuriservico          => NULL,       
                                    pr_dtmvtolt              => pr_dtmvtolt,       
                                    pr_cdstatus_http         => 0,
                                    pr_dsconteudo_requisicao => null,
                                    pr_dsresposta_requisicao => null,
                                    pr_tpproduto             => 3, --> Desconto de t�tulos
                                    pr_idacionamento         => vr_idaciona,
                                    pr_dscritic              => vr_dscritic);
      --> Sem tratamento de exce�ao para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      -->  RAISE vr_exc_erro;
      --END IF;
    END IF;       
    
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        --> Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Nao foi possivel realizar alteracao da proposta de Analise de Credito: '||SQLERRM;
  END pc_alterar_proposta;
  
 --> Rotina responsavel em enviar dos dados para a esteira
  PROCEDURE pc_enviar_analise(pr_cdcooper    IN crapcop.cdcooper%type  --> Codigo da cooperativa
                             ,pr_cdagenci    IN crapage.cdagenci%type  --> Codigo da agencia                                          
                             ,pr_cdoperad    IN crapope.cdoperad%type  --> codigo do operador
                             ,pr_cdorigem    IN integer                --> Origem da operacao
                             ,pr_nrdconta    IN crawlim.nrdconta%type  --> Numero da conta do cooperado
                             ,pr_nrctrlim    IN crawlim.nrctrlim%type  --> Numero da proposta
                             ,pr_dtmvtolt    IN crapdat.dtmvtolt%type  --> Data do movimento                                      
                             ,pr_comprecu    IN varchar2               --> Complemento do recuros da URI
                             ,pr_dsmetodo    IN varchar2               --> Descricao do metodo
                             ,pr_conteudo    IN clob                   --> Conteudo no Json para comunicacao
                             ,pr_dsoperacao  IN varchar2               --> Operacao realizada
                             ,pr_tpenvest    IN VARCHAR2 DEFAULT null  --> Tipo de envio, I-Inclusao C - Consultar(Get)
                             ,pr_dsprotocolo OUT varchar2              --> Protocolo retornado na requisi�ao
                             ,pr_dscritic    OUT VARCHAR2  ) IS

    --Parametros
    vr_host_esteira  VARCHAR2(4000);
    vr_recurso_este  VARCHAR2(4000);
    vr_dsdirlog      VARCHAR2(500);
    vr_autori_este   VARCHAR2(500);
    vr_chave_aplica  VARCHAR2(500);
    
    vr_dscritic      VARCHAR2(4000);
    vr_dscritic_aux  VARCHAR2(4000);
    vr_exc_erro      EXCEPTION;
    
    vr_request  json0001.typ_http_request;
    vr_response json0001.typ_http_response;
    
    vr_idacionamento  tbgen_webservice_aciona.idacionamento%TYPE;
            
    vr_tab_split     gene0002.typ_split;
    vr_idx_split     VARCHAR2(1000);
    
  BEGIN
    
    --> Carregar parametros para a comunicacao com a esteira
    este0001.pc_busca_param_ibra(pr_cdcooper     => pr_cdcooper
                                ,pr_tpenvest     => pr_tpenvest
                                ,pr_host_esteira => vr_host_esteira
                                ,pr_recurso_este => vr_recurso_este
                                ,pr_dsdirlog     => vr_dsdirlog
                                ,pr_autori_este  => vr_autori_este
                                ,pr_chave_aplica => vr_chave_aplica
                                ,pr_dscritic     => vr_dscritic);
    
    IF vr_dscritic  IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
    
    --> Atribuir valores necessarios para comunicacao
    vr_request.service_uri := vr_host_esteira;
    vr_request.api_route := vr_recurso_este||pr_comprecu;
    vr_request.method    := pr_dsmetodo;
    vr_request.timeout   := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_IBRA');
    
    vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
    vr_request.headers('Authorization') := vr_autori_este;
    
    --> Se houver ApplicationKey
    IF vr_chave_aplica IS NOT NULL THEN 
      vr_request.headers('ApplicationKey') := vr_chave_aplica;
    END IF;
    
    --> Para envio do Motor
    IF pr_tpenvest = 'M' THEN
      --> Incluiremos o Reply-To para devolu�ao da An�lise
      vr_request.headers('Reply-To') := gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_MOTOR_DEVOLUC');
    END IF;
    
        
    vr_request.content := pr_conteudo;
    
    --> Disparo do REQUEST
    json0001.pc_executa_ws_json(pr_request           => vr_request
                               ,pr_response          => vr_response
                               ,pr_diretorio_log     => vr_dsdirlog
                               ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'-- Este formato � o formato que deve ser passado, conforme alinhado com o Oscar
                               ,pr_dscritic          => vr_dscritic); 
                               
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
            
    --> Gravar dados log acionamento
    ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                                  pr_cdagenci              => pr_cdagenci,          
                                  pr_cdoperad              => pr_cdoperad,          
                                  pr_cdorigem              => pr_cdorigem,          
                                  pr_nrctrprp              => pr_nrctrlim,          
                                  pr_nrdconta              => pr_nrdconta,          
                                  pr_tpacionamento         => 1,  /* 1 - Envio, 2 � Retorno */      
                                  pr_dsoperacao            => pr_dsoperacao,       
                                  pr_dsuriservico          => vr_host_esteira||vr_recurso_este||pr_comprecu,       
                                  pr_dtmvtolt              => pr_dtmvtolt,       
                                  pr_cdstatus_http         => vr_response.status_code,
                                  pr_dsconteudo_requisicao => pr_conteudo,
                                  pr_dsresposta_requisicao => '{"StatusMessage":"'||vr_response.status_message||'"'||CHR(13)||
                                                              ',"Headers":"'||RTRIM(LTRIM(vr_response.headers,'""'),'""')||'"'||CHR(13)||
                                                              ',"Content":'||vr_response.content||'}',
                                  pr_tpproduto             => 3, --> Desconto de t�tulos
                                  pr_idacionamento         => vr_idacionamento,
                                  pr_dscritic              => vr_dscritic);
                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    IF vr_response.status_code NOT BETWEEN 200 AND 299 THEN
      --> Definir mensagem de critica
      CASE 
        WHEN pr_dsmetodo = 'POST' THEN
          vr_dscritic_aux := 'Nao foi possivel enviar proposta para An�lise de Credito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu IS NULL THEN   
          vr_dscritic_aux := 'Nao foi possivel reenviar a proposta para An�lise de Cr�dito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/numeroProposta' THEN   
          vr_dscritic_aux := 'Nao foi possivel alterar numero da proposta da An�lise de Cr�dito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/cancelar' THEN   
          vr_dscritic_aux := 'Nao foi possivel excluir a proposta da An�lise de Cr�dito.';   
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/efetivar' THEN   
          vr_dscritic_aux := 'Nao foi possivel enviar a efetivacao da proposta da An�lise de Cr�dito.';
        WHEN pr_dsmetodo = 'GET' THEN   
          vr_dscritic_aux := 'Nao foi possivel solicitar o retorno da An�lise Autom�tica de Cr�dito.';
        ELSE
          vr_dscritic_aux := 'Nao foi possivel enviar informacoes para An�lise de Cr�dito.';  
        END CASE;

      IF vr_response.status_code = 400 THEN
        pr_dscritic := este0001.fn_retorna_critica('{"Content":'||vr_response.content||'}');
        
        IF pr_dscritic IS NOT NULL THEN
          --> Tratar mensagem espec�fica de Fluxo Atacado:
          --> "Nao sera possivel enviar a proposta para analise. Classificacao de risco e endividamento fora dos parametros da cooperativa"
          IF pr_dscritic != 'Nao sera possivel enviar a proposta para analise. Classificacao de risco e endividamento fora dos parametros da cooperativa' THEN 
            --> Mensagens diferentes dela terao o prefixo, somente ela nao ter�
            pr_dscritic := vr_dscritic_aux||' '||pr_dscritic;            
          END IF;  
        ELSE
          pr_dscritic := vr_dscritic_aux;            
        END IF;
        
      ELSE  
        pr_dscritic := vr_dscritic_aux;    
      END IF;                         
      
    END IF;
            
    if  pr_tpenvest = 'M' and pr_dsmetodo = 'POST' then
        --> Transformar texto em objeto json
        begin
           --> Transformar os Headers em uma lista (\n � o separador)
           vr_tab_split := gene0002.fn_quebra_string(vr_response.headers,'\n');
           vr_idx_split  := vr_tab_split.first;
           --> Iterar sobre todos os headers at� encontrar o protocolo
           while vr_idx_split is not null and pr_dsprotocolo is null loop
                 --> Testar se � o Location
                 if  lower(vr_tab_split(vr_idx_split)) like 'location%' then
                     --> Extrair o final do atributo, ou seja, o conte�do ap�s a ultima barra
                     pr_dsprotocolo := substr(vr_tab_split(vr_idx_split),instr(vr_tab_split(vr_idx_split),'/',-1)+1);
                 end if;        
                 --> Buscar proximo header        
                 vr_idx_split := vr_tab_split.next(vr_idx_split);    
           end   loop;
        
           -->  Se conseguiu encontrar Protocolo
           if  pr_dsprotocolo is not null then 
               --> Atualizar acionamento                                                                                                                                                             
               update tbgen_webservice_aciona
               set    dsprotocolo = pr_dsprotocolo
               where  idacionamento = vr_idacionamento;
           else    
               --> Gerar erro 
               vr_dscritic := 'Nao foi possivel retornar Protocolo da An�lise Autom�tica de Cr�dito!';
               raise vr_exc_erro;                                                                                                                                     
           end if;
        exception
           when others then   
                vr_dscritic := 'Nao foi possivel retornar Protocolo de An�lise Autom�tica de Cr�dito!';
                raise vr_exc_erro;
        end;  
    end if;
            
  EXCEPTION
    WHEN vr_exc_erro THEN      
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel enviar proposta para An�lise de Cr�dito: '||SQLERRM;  
  END pc_enviar_analise;
      

  PROCEDURE pc_enviar_analise_manual(pr_cdcooper  IN crawlim.cdcooper%TYPE
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                    ,pr_cdorigem  IN INTEGER
                                    ,pr_nrdconta  IN crawlim.nrdconta%TYPE
                                    ,pr_nrctrlim  IN crawlim.nrctrlim%TYPE
                                    ,pr_tpctrlim  in crawlim.tpctrlim%type
                                    ,pr_dtmvtolt  IN VARCHAR2
                                    ,pr_nmarquiv  IN VARCHAR2
                                    ,vr_flgdebug  IN VARCHAR2
                                     ---- OUT ----
                                    ,pr_dsmensag OUT VARCHAR2
                                    ,pr_cdcritic OUT NUMBER
                                    ,pr_dscritic OUT VARCHAR2
                                    ,pr_des_erro OUT VARCHAR2) IS

 /* ...........................................................................

   Programa : pc_enviar_analise_manual        
   Sistema  : Conta-Corrente - Cooperativa de Credito
   Sigla    : CRED
   Autor    : Luis Fernando - GFT-Brasil
   Data     : Mar�o/2018.          Ultima atualizacao: 05/03/2018
        
   Dados referentes ao programa:
        
   Frequencia: Sempre que for chamado
   Objetivo  : Rotina responsavel por gerar a geracao e inclusao da proposta psistemara a esteira 

 ..........................................................................*/

 vr_dtmvtolt DATE;

 vr_cdagenci crapage.cdagenci%type; --> Codigo da agencia
    
 vr_exc_erro EXCEPTION;
 vr_dscritic VARCHAR2(4000);
 vr_cdcritic NUMBER;

 --> Hora de Envio
 vr_hrenvest crawlim.hrenvest%TYPE;

 vr_tpenvest varchar2(1);
 vr_obj_proposta json := json();
 vr_obj_proposta_clob clob;
        
 vr_dsprotoc VARCHAR2(1000);
 vr_idaciona tbgen_webservice_aciona.idacionamento%type;
  
  --> Busca do nome do associado
  cursor cr_crapass is
  select ass.nmprimtl
        ,ass.inpessoa
        ,ass.cdagenci
  from   crapass ass
  where  ass.cdcooper = pr_cdcooper
  and    ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%rowtype;

 BEGIN
   pc_verifica_contigenc_esteira(pr_cdcooper => pr_cdcooper
                                ,pr_flctgest => vr_flctgest
                                ,pr_dsmensag => pr_dsmensag
                                ,pr_dscritic => vr_dscritic);
                                
   if  vr_flctgest then
       vr_dscritic := pr_dsmensag;
       raise vr_exc_erro;
   end if;
    
  vr_dtmvtolt := TO_DATE(pr_dtmvtolt, 'DD/MM/YYYY');
                          
  open  cr_crapass;
  fetch cr_crapass into rw_crapass;
  if    cr_crapass%notfound then
        close cr_crapass;
        vr_dscritic := 'Associado nao cadastrado. Conta: ' || pr_nrdconta;
        raise vr_exc_erro;
  end   if;
  close cr_crapass;
  
  vr_cdagenci := nvl(nullif(pr_cdagenci, 0), rw_crapass.cdagenci);

   --> Gerar informa�oes no padrao JSON da proposta
   este0004.pc_gera_json_proposta_lim(pr_cdcooper  => pr_cdcooper
                                     ,pr_cdagenci  => vr_cdagenci
                                     ,pr_cdoperad  => pr_cdoperad
                                     ,pr_nrdconta  => pr_nrdconta
                                     ,pr_nrctrlim  => pr_nrctrlim
                                     ,pr_tpctrlim  => pr_tpctrlim
                                     ,pr_nmarquiv  => pr_nmarquiv  --> Diretorio e nome do arquivo pdf da proposta
                                     ---- OUT ----
                                     ,pr_proposta  => vr_obj_proposta  --> Retorno do clob em modelo json da proposta
                                     ,pr_cdcritic  => vr_cdcritic
                                     ,pr_dscritic  => vr_dscritic);
          
   IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
     RAISE vr_exc_erro;        
   END IF;  

   --> Se origem veio do Motor/Esteira
   IF pr_cdorigem = 9 THEN 
     --> � uma deriva�ao
     vr_tpenvest := 'D';
   ELSE 
     vr_tpenvest := 'I';
   END IF;

   --> Criar o CLOB para converter JSON para CLOB
   dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
   dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
   json.to_clob(vr_obj_proposta,vr_obj_proposta_clob);  
          
   --> Se o DEBUG estiver habilitado
   IF vr_flgdebug = 'S' THEN
     --> Gravar dados log acionamento
     ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                                   pr_cdagenci              => vr_cdagenci,          
                                   pr_cdoperad              => pr_cdoperad,          
                                   pr_cdorigem              => pr_cdorigem,          
                                   pr_nrctrprp              => pr_nrctrlim,          
                                   pr_nrdconta              => pr_nrdconta,          
                                   pr_tpacionamento         => 0,  --> 0 - DEBUG
                                   pr_dsoperacao            => 'ANTES ENVIAR PROPOSTA',       
                                   pr_dsuriservico          => NULL,       
                                   pr_dtmvtolt              => vr_dtmvtolt,       
                                   pr_cdstatus_http         => 0,
                                   pr_dsconteudo_requisicao => vr_obj_proposta_clob,
                                   pr_dsresposta_requisicao => null,
                                   pr_tpproduto             => 3, --> Desconto de t�tulos
                                   pr_idacionamento         => vr_idaciona,
                                   pr_dscritic              => vr_dscritic);
     --> Sem tratamento de exce�ao para DEBUG                    
     --IF TRIM(vr_dscritic) IS NOT NULL THEN
     -->  RAISE vr_exc_erro;
     --END IF;
   END IF;  
          
   --> Enviar dados para Esteira
   pc_enviar_analise (pr_cdcooper    => pr_cdcooper
                     ,pr_cdagenci    => vr_cdagenci
                     ,pr_cdoperad    => pr_cdoperad
                     ,pr_cdorigem    => pr_cdorigem
                     ,pr_nrdconta    => pr_nrdconta
                     ,pr_nrctrlim    => pr_nrctrlim
                     ,pr_dtmvtolt    => vr_dtmvtolt
                     ,pr_comprecu    => NULL
                     ,pr_dsmetodo    => 'POST'
                     ,pr_conteudo    => vr_obj_proposta_clob
                     ,pr_dsoperacao  => 'ENVIO DA PROPOSTA PARA ANALISE DE CREDITO'
                     ,pr_tpenvest    => vr_tpenvest
                     ,pr_dsprotocolo => vr_dsprotoc
                     ,pr_dscritic    => vr_dscritic);
          
   --> Caso tenhamos recebido critica de Proposta jah existente na Esteira
   IF lower(vr_dscritic) LIKE '%proposta%ja existente na esteira%' THEN

     --> Tentaremos enviar altera�ao com rein�cio de fluxo para a Esteira 
     pc_alterar_proposta(pr_cdcooper => pr_cdcooper
                        ,pr_cdagenci => vr_cdagenci
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_cdorigem => pr_cdorigem
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrctrlim => pr_nrctrlim
                        ,pr_tpctrlim => pr_tpctrlim
                        ,pr_dtmvtolt => vr_dtmvtolt
                        ,pr_flreiflx => 1
                        ,pr_nmarquiv => pr_nmarquiv
                        ,pr_cdcritic => vr_cdcritic
                        ,pr_dscritic => vr_dscritic);
     END IF;
          
   --> Liberando a mem�ria alocada pro CLOB
   dbms_lob.close(vr_obj_proposta_clob);
   dbms_lob.freetemporary(vr_obj_proposta_clob);    
          
   --> verificar se retornou critica
   IF vr_dscritic IS NOT NULL THEN
     RAISE vr_exc_erro;
   END IF; 
          
   vr_hrenvest := to_char(SYSDATE,'sssss');
          
   --> Atualizar proposta
   begin
      update crawlim lim
      set    insitlim = 1
            ,insitest = 2 -->  2 � Enviada para Analise Manual
            ,dtenvest = trunc(sysdate)
            ,hrenvest = vr_hrenvest
            ,cdopeste = pr_cdoperad
            ,dsprotoc = nvl(vr_dsprotoc,' ')
            ,insitapr = 0
            ,cdopeapr = null
            ,dtaprova = null
            ,hraprova = 0
      where  lim.cdcooper = pr_cdcooper
      and    lim.nrdconta = pr_nrdconta
      and    lim.nrctrlim = pr_nrctrlim
      and    lim.tpctrlim = pr_tpctrlim;
   exception    
      when others then
           vr_dscritic := 'Nao foi possivel atualizar proposta apos envio para An�lise de Cr�dito: '||sqlerrm;
           raise vr_exc_erro;
   end;
          
   pr_dsmensag := 'Proposta Enviada para Analise Manual de Credito.';
          
   --> Efetuar grava�ao
   COMMIT;
        
   EXCEPTION
     WHEN vr_exc_erro THEN
          --> Se possui c�digo de cr�tica e nao foi informado a descri�ao
          IF  vr_cdcritic <> 0 and TRIM(vr_dscritic) IS NULL THEN
              --> Busca descri�ao da cr�tica
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
                
          --> Atribui exce�ao para os parametros de cr�tica
          pr_cdcritic := nvl(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
          pr_des_erro := 'NOK';

          ROLLBACK;
                
     WHEN OTHERS THEN
          --> Atribui exce�ao para os parametros de cr�tica
          pr_cdcritic := nvl(vr_cdcritic,0);
          pr_dscritic := 'Erro nao tratado na ESTE0003.pc_enviar_analise_manual: ' || SQLERRM;
          pr_des_erro := 'NOK';

          ROLLBACK;
   END pc_enviar_analise_manual;
   

PROCEDURE pc_efetivar_limite_esteira(pr_cdcooper  IN crawlim.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_nrdconta  IN crawlim.nrdconta%TYPE --> Numero da conta do cooperado
                                    ,pr_nrctrlim  IN crawlim.nrctrlim%TYPE --> Numero da proposta
                                    ,pr_tpctrlim  IN crawlim.tpctrlim%TYPE --> Tipo da proposta
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo da agencia
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do operador
                                    ,pr_cdorigem  IN INTEGER               --> Codigo da Origem
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                    ---- OUT ----
                                    ,pr_cdcritic OUT NUMBER                --> Codigo da Critica
                                    ,pr_dscritic OUT VARCHAR2              --> Descri�ao da Critica
                                    ) IS
   /* ...........................................................................
  
    Programa : pc_efetivar_limite_esteira        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Paulo Penteado (GFT) 
    Data     : Abril/2018
    
    Dados referentes ao programa:
    
    Objetivo  : Enviadar proposta de limites de desconto de titulos como efetivadas para o Ibratan

    Altera�ao : 14/04/2018 - Cria��o Paulo Penteado (GFT) 
                
   ..........................................................................*/
   -- Tratamento de erros
   vr_cdcritic number := 0;
   vr_dscritic varchar2(4000);
   vr_exc_erro exception;

   -- Objeto json da proposta
   vr_obj_efetivar json := json();
   vr_obj_agencia  json := json();

   -- Auxiliares
   vr_dsprotocolo  varchar2(1000);
   vr_cdagenci     crapage.cdagenci%TYPE;

   -- Variaveis para DEBUG
   vr_flgdebug varchar2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
   vr_idaciona tbgen_webservice_aciona.idacionamento%type;

   --     Buscar dados do associado
   cursor cr_crapass is
   select ass.nrdconta
         ,ass.nmprimtl
         ,ass.cdagenci
         ,age.nmextage
         ,ass.inpessoa
         ,decode(ass.inpessoa,1,0,2,1) inpessoa_ibra
         ,ass.nrcpfcgc
   from   crapage age
         ,crapass ass
   where  ass.cdcooper = age.cdcooper
   and    ass.cdagenci = age.cdagenci
   and    ass.cdcooper = pr_cdcooper
   and    ass.nrdconta = pr_nrdconta;
   rw_crapass cr_crapass%rowtype;

   --     Buscar dados da proposta de limite
   cursor cr_crawlim is
   select lim.nrctrlim
         ,lim.vllimite
         ,0 qtpreemp
         ,lim.dtpropos
         ,lim.dtfimvig
         ,lim.hrinclus
         ,lim.cdagenci
         ,lim.cddlinha
         ,ldc.dsdlinha
         ,0 cdfinemp
         ,ldc.tpctrato
         ,lim.cdoperad
         ,ope.nmoperad nmoperad_efet
         ,lim.cdagenci cdagenci_efet
   from   crapope ope
         ,crapldc ldc
         ,crawlim lim
   where  ldc.cdcooper = lim.cdcooper
   and    ldc.cddlinha = lim.cddlinha
   and    ldc.tpdescto = lim.tpctrlim
   and    upper(ope.cdoperad(+))= upper(lim.cdoperad)
   and    ope.cdcooper       (+)= lim.cdcooper
   and    lim.tpctrlim = pr_tpctrlim
   and    lim.nrctrlim = pr_nrctrlim
   and    lim.nrdconta = pr_nrdconta
   and    lim.cdcooper = pr_cdcooper;
   rw_crawlim cr_crawlim%rowtype;

BEGIN
   open  cr_crapass;
   fetch cr_crapass into rw_crapass;
   if    cr_crapass%notfound then
         close cr_crapass;
         vr_cdcritic := 9;
         raise vr_exc_erro;
   end   if;
   close cr_crapass;
   
   vr_cdagenci := nvl(nullif(pr_cdagenci,0), rw_crapass.cdagenci);

   --  Se o DEBUG estiver habilitado
   if  vr_flgdebug = 'S' then
       -- Gravar dados log acionamento
       este0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper
                                    ,pr_cdagenci              => vr_cdagenci
                                    ,pr_cdoperad              => pr_cdoperad
                                    ,pr_cdorigem              => pr_cdorigem
                                    ,pr_nrctrprp              => pr_nrctrlim
                                    ,pr_nrdconta              => pr_nrdconta
                                    ,pr_tpproduto             => 3
                                    ,pr_tpacionamento         => 0  /* 0 - DEBUG */
                                    ,pr_dsoperacao            => 'INICIO EFETIVAR PROPOSTA'
                                    ,pr_dsuriservico          => null
                                    ,pr_dtmvtolt              => pr_dtmvtolt
                                    ,pr_cdstatus_http         => 0
                                    ,pr_dsconteudo_requisicao => null
                                    ,pr_dsresposta_requisicao => null
                                    ,pr_idacionamento         => vr_idaciona
                                    ,pr_dscritic              => vr_dscritic);
   end if;

   open  cr_crawlim;
   fetch cr_crawlim into rw_crawlim;
   if    cr_crawlim%notfound then
         close cr_crawlim;
         vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
         raise vr_exc_erro;
   end   if;
   close cr_crawlim;

   -- Criar objeto json para agencia da proposta
   vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
   vr_obj_agencia.put('PACodigo', rw_crawlim.cdagenci);
   vr_obj_efetivar.put('PA' ,vr_obj_agencia);
   vr_obj_agencia := json();

   -- Criar objeto json para agencia do cooperado
   vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
   vr_obj_agencia.put('PACodigo', rw_crapass.cdagenci);
   vr_obj_efetivar.put('cooperadoContaPA' ,vr_obj_agencia);
   vr_obj_agencia := json();

   -- Nr. conta sem o digito
   vr_obj_efetivar.put('cooperadoContaNum'      , to_number(substr(rw_crapass.nrdconta,1,length(rw_crapass.nrdconta)-1)));
   -- Somente o digito
   vr_obj_efetivar.put('cooperadoContaDv'       , to_number(substr(rw_crapass.nrdconta,-1)));

   if  rw_crapass.inpessoa = 1 then
       vr_obj_efetivar.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,11,'0'));
   else
       vr_obj_efetivar.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,14,'0'));
   end if;

   --  Verificar se possui o operador que realizou a efetivacao
   if  trim(rw_crawlim.cdoperad) is null then
       vr_dscritic := 'Operador da efetivacao da proposta nao encontrado.';
       raise vr_exc_erro;
   end if;

   vr_obj_efetivar.put('numero'                 , pr_nrctrlim);
   vr_obj_efetivar.put('operadorEfetivacaoLogin', rw_crawlim.cdoperad);
   vr_obj_efetivar.put('operadorEfetivacaoNome' , rw_crawlim.nmoperad_efet) ;
   -- Criar objeto json para agencia do cooperado
   vr_obj_agencia.put('cooperativaCodigo'       , pr_cdcooper);
   vr_obj_agencia.put('PACodigo'                , rw_crawlim.cdagenci_efet);
   vr_obj_efetivar.put('operadorEfetivacaoPA'   , vr_obj_agencia);
   vr_obj_efetivar.put('dataHora'               , este0001.fn_datatempo_ibra(sysdate)) ;
   vr_obj_efetivar.put('contratoNumero'         , pr_nrctrlim);
   vr_obj_efetivar.put('valor'                  , rw_crawlim.vllimite);

   vr_obj_efetivar.put('produtoCreditoSegmentoCodigo', 5);

   --  Se o DEBUG estiver habilitado
   if  vr_flgdebug = 'S' then
       -- Gravar dados log acionamento
       este0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper
                                    ,pr_cdagenci              => vr_cdagenci
                                    ,pr_cdoperad              => pr_cdoperad
                                    ,pr_cdorigem              => pr_cdorigem
                                    ,pr_nrctrprp              => pr_nrctrlim
                                    ,pr_nrdconta              => pr_nrdconta
                                    ,pr_tpproduto             => 3
                                    ,pr_tpacionamento         => 0  /* 0 - DEBUG */
                                    ,pr_dsoperacao            => 'ANTES EFETIVAR PROPOSTA'
                                    ,pr_dsuriservico          => null
                                    ,pr_dtmvtolt              => pr_dtmvtolt
                                    ,pr_cdstatus_http         => 0
                                    ,pr_dsconteudo_requisicao => vr_obj_efetivar.to_char
                                    ,pr_dsresposta_requisicao => null
                                    ,pr_idacionamento         => vr_idaciona
                                    ,pr_dscritic              => vr_dscritic);
   end if;

   -- Enviar dados para Esteira
   pc_enviar_analise(pr_cdcooper    => pr_cdcooper               --> Codigo da cooperativa
                    ,pr_cdagenci    => vr_cdagenci               --> Codigo da agencia
                    ,pr_cdoperad    => pr_cdoperad               --> codigo do operador
                    ,pr_cdorigem    => pr_cdorigem               --> Origem da operacao
                    ,pr_nrdconta    => pr_nrdconta               --> Numero da conta do cooperado
                    ,pr_nrctrlim    => pr_nrctrlim               --> Numero da proposta atual/antigo
                    ,pr_dtmvtolt    => pr_dtmvtolt               --> Data do movimento
                    ,pr_comprecu    => '/efetivar'               --> Complemento do recuros da URI
                    ,pr_dsmetodo    => 'PUT'                     --> Descricao do metodo
                    ,pr_conteudo    => vr_obj_efetivar.to_char   --> Conteudo no Json para comunicacao
                    ,pr_dsoperacao  => 'ENVIO DA EFETIVACAO DA PROPOSTA DE ANALISE DE CREDITO'       --> Operacao realizada
                    ,pr_dsprotocolo => vr_dsprotocolo
                    ,pr_dscritic    => vr_dscritic);

   --  verificar se retornou critica
   if  vr_dscritic is not null then
       raise vr_exc_erro;
   end if;

   -- Atualizar proposta
   begin
      update crawlim lim
      set    dtenefes = trunc(sysdate)
      where  lim.tpctrlim = pr_tpctrlim
      and    lim.nrctrlim = pr_nrctrlim
      and    lim.nrdconta = pr_nrdconta
      and    lim.cdcooper = pr_cdcooper;
   exception
      when others then
           vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da efetivacao de Analise de Credito: '||sqlerrm;
           raise vr_exc_erro;
   end;

   if  vr_flgdebug = 'S' then
       -- Gravar dados log acionamento
       este0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper
                                    ,pr_cdagenci              => vr_cdagenci
                                    ,pr_cdoperad              => pr_cdoperad
                                    ,pr_cdorigem              => pr_cdorigem
                                    ,pr_nrctrprp              => pr_nrctrlim
                                    ,pr_nrdconta              => pr_nrdconta
                                    ,pr_tpacionamento         => 0  /* 0 - DEBUG */
                                    ,pr_dsoperacao            => 'TERMINO EFETIVAR PROPOSTA'
                                    ,pr_dsuriservico          => null
                                    ,pr_dtmvtolt              => pr_dtmvtolt
                                    ,pr_cdstatus_http         => 0
                                    ,pr_dsconteudo_requisicao => null
                                    ,pr_dsresposta_requisicao => null
                                    ,pr_idacionamento         => vr_idaciona
                                    ,pr_dscritic              => vr_dscritic);
   end if;

EXCEPTION
   when vr_exc_erro then
        if  nvl(vr_cdcritic,0) > 0 and trim(vr_dscritic) is null then
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        end if;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

   when others then
        pr_cdcritic := 0;
        pr_dscritic := 'N�o foi possivel realizar efetivacao da proposta de Analise de Credito: '||sqlerrm;

END pc_efetivar_limite_esteira;

   

PROCEDURE pc_solicitar_limite_efetivacao(pr_cdcooper  IN crawlim.cdcooper%TYPE --> Codigo da cooperativa
                                        ,pr_tpctrlim  IN crawlim.tpctrlim%TYPE --> Tipo da proposta
                                        ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                        ,pr_cdcritic OUT NUMBER                --> Codigo da Critica
                                        ,pr_dscritic OUT VARCHAR2              --> Descri�ao da Critica
                                        ) IS
   /* ...........................................................................
  
    Programa : pc_solicitar_limite_efetivacao        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Paulo Penteado (GFT) 
    Data     : Abril/2018
    
    Dados referentes ao programa:
    
    Objetivo  : Buscar as propostas de limites de desconto de titulos que foram efetivadas
                no sistema Ayllos e ainda n�o foram enviadas como efetivadas para o Ibratan

    Altera�ao : 14/04/2018 - Cria��o Paulo Penteado (GFT) 
                
   ..........................................................................*/
    
   --> Tratamento de erros
   vr_cdcritic NUMBER := 0;
   vr_dscritic VARCHAR2(4000);
   vr_exc_erro EXCEPTION;

   --     buscar as propostas que j� foram analisada e efetivadas no Ayllos
   CURSOR cr_crawlim IS
   SELECT pro.cdcooper
         ,pro.nrdconta
         ,pro.nrctrlim
         ,pro.tpctrlim
         ,pro.cdagenci
         ,pro.cdoperad
         ,pro.dtenefes
   FROM   craplim ctr
         ,crawlim pro
   WHERE  ctr.dtpropos          < pr_dtmvtolt
   AND    ctr.tpctrlim          = pro.tpctrlim
   AND    ctr.nrctrlim          = pro.nrctrlim
   AND    ctr.nrdconta          = pro.nrdconta
   AND    ctr.cdcooper          = pro.cdcooper
   AND    pro.dtenefes          IS NULL
   AND    nvl(pro.cdopeapr,'#') <> 'MOTOR'
   AND    pro.dtenvest          IS NOT NULL
   AND    pro.insitlim          = 2
   AND    pro.tpctrlim          = pr_tpctrlim
   AND    pro.cdcooper          = pr_cdcooper;
   rw_crawlim cr_crawlim%ROWTYPE;

BEGIN
   OPEN  cr_crawlim;
   LOOP
         FETCH cr_crawlim INTO rw_crawlim;
         EXIT  WHEN cr_crawlim%NOTFOUND;
         
         pc_efetivar_limite_esteira(pr_cdcooper => rw_crawlim.cdcooper
                                   ,pr_nrdconta => rw_crawlim.nrdconta
                                   ,pr_nrctrlim => rw_crawlim.nrctrlim
                                   ,pr_tpctrlim => rw_crawlim.tpctrlim
                                   ,pr_cdagenci => rw_crawlim.cdagenci
                                   ,pr_cdoperad => rw_crawlim.cdoperad
                                   ,pr_cdorigem => 9 /*Esteira */
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic );

         IF  nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro;
         END IF;
   END   LOOP;
   CLOSE cr_crawlim; 

EXCEPTION
   WHEN vr_exc_erro THEN
        IF  cr_crawlim%ISOPEN THEN
            CLOSE cr_crawlim;
        END IF;

        IF  nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    
   WHEN OTHERS THEN
        IF  cr_crawlim%ISOPEN THEN
            CLOSE cr_crawlim;
        END IF;

        pr_cdcritic := 0;
        pr_dscritic := 'Nao foi possivel realizar a efetiva��o de proposta de An�lise de Cr�dito: '||SQLERRM;

END pc_solicitar_limite_efetivacao;


PROCEDURE pc_crps703(pr_cdcritic OUT NUMBER   --> Codigo da Critica
                    ,pr_dscritic OUT VARCHAR2 --> Descri�ao da Critica
                    ) IS
   /* ...........................................................................
  
    Programa : pc_crps703        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Paulo Penteado (GFT) 
    Data     : Abril/2018
    
    Dados referentes ao programa:
    
    Objetivo  : Enviar a proposta de limite de desconto de t�tulos e Borderos ao Ibratan
                ap�s a an�lise e efetiva��o de ambor, para confirmar ao Ibratan que for�o
                efetivados no sistema Ayllos

    Altera�ao : 14/04/2018 - Cria��o Paulo Penteado (GFT) 
                
   ..........................................................................*/
    
   --> Tratamento de erros
   vr_cdcritic NUMBER := 0;
   vr_dscritic VARCHAR2(4000);
   vr_exc_erro EXCEPTION;

   --     buscar todas as cooperativas ativas sem nenhum processamento ativo
   CURSOR cr_copdat is
   SELECT cop.cdcooper
         ,dat.dtmvtolt
   FROM   crapdat dat
         ,crapcop cop
   WHERE  dat.inproces  = 1 -- online
   AND    dat.cdcooper  = cop.cdcooper
   AND    cop.flgativo  = 1; -- ativas
   rw_copdat cr_copdat%ROWTYPE;

BEGIN
   OPEN  cr_copdat;
   LOOP
         FETCH cr_copdat INTO rw_copdat;
         EXIT  WHEN cr_copdat%NOTFOUND;
         
         pc_verifica_contigenc_esteira(pr_cdcooper => rw_copdat.cdcooper
                                      ,pr_flctgest => vr_flctgest
                                      ,pr_dsmensag => vr_dsmensag
                                      ,pr_dscritic => vr_dscritic);     

         IF  TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro;
         END IF; 

         IF  vr_flctgest THEN -- se a esteira estiver em contigencia
             vr_dscritic := vr_dsmensag;
             RAISE vr_exc_erro;
         END IF;
         
         pc_solicitar_limite_efetivacao(pr_cdcooper => rw_copdat.cdcooper
                                       ,pr_tpctrlim => 3
                                       ,pr_dtmvtolt => rw_copdat.dtmvtolt
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic );

         IF  nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro;
         END IF;
         
   END   LOOP;
   CLOSE cr_copdat;

   COMMIT;   
    
EXCEPTION
   WHEN vr_exc_erro THEN
        IF  cr_copdat%ISOPEN THEN
            CLOSE cr_copdat;
        END IF;
   
        IF  nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
        END IF;
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        ROLLBACK;
    
   WHEN OTHERS THEN
        IF  cr_copdat%ISOPEN THEN
            CLOSE cr_copdat;
        END IF;

        pr_cdcritic := 0;
        pr_dscritic := 'Nao foi possivel realizar a efetiva��o de proposta de An�lise de Cr�dito: '||SQLERRM;
        
        ROLLBACK;

END pc_crps703;

END ESTE0003;
/
