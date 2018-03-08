create or replace package cecred.ESTE0003 is
/* --------------------------------------------------------------------------------------------------

      Programa : ESTE0003
      Sistema  : BO - CRÉDITO CONSIGNADO
      Sigla    : XXXX
      Autor    : Lindon Carlos Pecile - GFT-Brasil
      Data     : Fevereiro/2018.          Ultima atualizacao: 10/02/2018

      Dados referentes ao programa:

      Frequencia: Sempre que solicitado
      Objetivo  : BO - Rotinas para envio de informacoes para a Esteira de Credito

      Alteracoes: 18/02/2018 Criação (Carlos Lindon (GFT))
                  18/02/2018 Adicionado pc_enviar_proposta_esteira (Paulo Penteado (GFT)) 

.................................................................................................
 Declaração das Procedure para incluir  proposta ao motor
.................................................................................................*/

/* Tratamento de erro */
vr_des_erro varchar2(4000);
vr_exc_erro exception;

/* Descrição e código da critica */
vr_cdcritic crapcri.cdcritic%type;
vr_dscritic varchar2(4000);


--> Funcao para formatar data hora conforme padrao da IBRATAN
function fn_datatempo_ibra (pr_data in date
                           ) return varchar2;

procedure pc_enviar_proposta_esteira(pr_cdcooper in  craplim.cdcooper%type --> Codigo da cooperativa
                                    ,pr_cdagenci in  crapage.cdagenci%type --> Codigo da agencia
                                    ,pr_cdoperad in  crapope.cdoperad%type --> codigo do operador
                                    ,pr_idorigem in  integer               --> Origem da operacao
                                    ,pr_tpenvest in  varchar2              --> Tipo do envio esteira
                                    ,pr_nrctrlim in  craplim.nrctrlim%type --> Numero do Contrato do Limite.
                                    ,pr_tpctrlim in  craplim.tpctrlim%type --> Tipo de contrato do limite
                                    ,pr_nrdconta in  crapass.nrdconta%type --> Conta do associado
                                    ,pr_dtmovito in  varchar2 -- crapdat.dtmvtolt%type --> Data do movimento atual
                                    ,pr_dsmensag out varchar2              --> Mensagem 
                                    ,pr_cdcritic out pls_integer           --> Codigo da critica
                                    ,pr_dscritic out varchar2              --> Descricao da critica
                                    ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                                    );

/*procedure pc_gera_json_proposta(pr_cdcooper  in craplim.cdcooper%type  --> Codigo da cooperativa
                               ,pr_cdagenci  in crapage.cdagenci%type  --> Codigo da agencia                                            
                               ,pr_cdoperad  in crapope.cdoperad%type  --> codigo do operado
                               ,pr_cdorigem  in integer                --> Origem da operacao
                               ,pr_nrdconta  in craplim.nrdconta%type  --> Numero da conta do cooperado
                               ,pr_nrctrlim  in craplim.nrctrlim%type  --> Numero da proposta
                               ,pr_tpctrlim  in craplim.tpctrlim%type  --> Tipo de contrato do limite
                               ,pr_nmarquiv  in varchar2               --> Diretorio e nome do arquivo pdf da proposta
                               ---- OUT ----
                               ,pr_proposta out json                   --> Retorno do clob em modelo json da proposta
                               ,pr_cdcritic out number                 --> Codigo da critica
                               ,pr_dscritic out varchar2               --> Descricao da critica
                               );*/
	
procedure pc_obrigacao_analise_automatic(pr_cdcooper in crapcop.cdcooper%type  -- Cód. cooperativa
                                         ---- OUT ----                                          
                                        ,pr_inobriga out varchar2              -- Indicador de obrigaçao de análisa automática ('S' - Sim / 'N' - Nao)
                                        ,pr_cdcritic out pls_integer           -- Cód. da crítica
                                        ,pr_dscritic out varchar2              -- Desc. da crítica
                                        );
  
procedure pc_verifica_regras_esteira (pr_cdcooper  in craplim.cdcooper%type  -- Codigo da cooperativa                                        
                                     ,pr_nrdconta  in craplim.nrdconta%type  -- Numero da conta do cooperado
                                     ,pr_nrctrlim  in craplim.nrctrlim%type  -- Numero do contrato
                                     ,pr_tpctrlim in craplim.tpctrlim%type  --> Tipo de contrato do limite.
                                     ,pr_tpenvest  in varchar2 default null  -- Tipo de envio
                                      ---- OUT ----                                        
                                     ,pr_cdcritic out number                 -- Codigo da critica
                                     ,pr_dscritic out varchar2               -- Descricao da critica
                                     );
  
--> Rotina para efetuar a derivação de uma proposta para a Esteira
procedure pc_derivar_proposta_est(pr_cdcooper  in craplim.cdcooper%type     --> Codigo da cooperativa
                                 ,pr_cdagenci  in crapage.cdagenci%type     --> Codigo da agencia           
                                 ,pr_cdoperad  in crapope.cdoperad%type     --> codigo do operador
                                 ,pr_cdorigem  in integer                   --> Origem da operacao
                                 ,pr_nrdconta  in craplim.nrdconta%type     --> Numero da conta do cooperado
                                 ,pr_nrctrlim  in craplim.nrctrlim%type     --> Numero da proposta
                                 ,pr_tpctrlim  in craplim.tpctrlim%type     --> Tipo de contrato do limite
                                 ,pr_dtmvtolt  in crapdat.dtmvtolt%type     --> Data do movimento
                                 );

procedure pc_incluir_proposta_est(pr_cdcooper  in craplim.cdcooper%type
                                 ,pr_cdagenci  in crapage.cdagenci%type
                                 ,pr_cdoperad  in crapope.cdoperad%type
                                 ,pr_cdorigem  in integer
                                 ,pr_nrdconta  in craplim.nrdconta%type
                                 ,pr_nrctrlim  in craplim.nrctrlim%type
                                 ,pr_tpctrlim  in craplim.tpctrlim%type
                                 ,pr_dtmvtolt  in crapdat.dtmvtolt%type
                                 ,pr_nmarquiv  in varchar2
                                  ---- OUT ----
                                 ,pr_dsmensag out varchar2
                                 ,pr_cdcritic out number
                                 ,pr_dscritic out varchar2
                                 );

--> Rotina responsavel por gerar a alteracao da proposta para a esteira
procedure pc_alterar_proposta_est(pr_cdcooper  in craplim.cdcooper%type  --> Codigo da cooperativa
                                 ,pr_cdagenci  in crapage.cdagenci%type  --> Codigo da agencia                                          
                                 ,pr_cdoperad  in crapope.cdoperad%type  --> codigo do operador
                                 ,pr_cdorigem  in integer                --> Origem da operacao
                                 ,pr_nrdconta  in craplim.nrdconta%type  --> Numero da conta do cooperado
                                 ,pr_nrctrlim  in craplim.nrctrlim%type  --> Numero da proposta
                                 ,pr_tpctrlim  in craplim.tpctrlim%type  --> Tipo de contrato do limite.
                                 ,pr_dtmvtolt  in crapdat.dtmvtolt%type  --> Data do movimento
                                 ,pr_flreiflx  in integer                --> Indica se deve reiniciar o fluxo de aprovacao na esteira
                                 ,pr_nmarquiv  in varchar2               --> Diretorio e nome do arquivo pdf da proposta
                                 ---- OUT ----                           
                                 ,pr_cdcritic out number                 --> Codigo da critica
                                 ,pr_dscritic out varchar2               --> Descricao da critica 
                                 );

procedure pc_enviar_esteira (pr_cdcooper    in crapcop.cdcooper%type  --> Codigo da cooperativa
                            ,pr_cdagenci    in crapage.cdagenci%type  --> Codigo da agencia                                          
                            ,pr_cdoperad    in crapope.cdoperad%type  --> codigo do operador
                            ,pr_cdorigem    in integer                --> Origem da operacao
                            ,pr_nrdconta    in craplim.nrdconta%type  --> Numero da conta do cooperado
                            ,pr_nrctrlim    in craplim.nrctrlim%type  --> Numero da proposta
                            ,pr_dtmvtolt    in crapdat.dtmvtolt%type  --> Data do movimento                                      
                            ,pr_comprecu    in varchar2               --> Complemento do recuros da URI
                            ,pr_dsmetodo    in varchar2               --> Descricao do metodo
                            ,pr_conteudo    in clob                   --> Conteudo no Json para comunicacao
                            ,pr_dsoperacao  in varchar2               --> Operacao realizada
                            ,pr_tpenvest    in varchar2 default null  --> Tipo de envio, I-Inclusao C - Consultar(Get)
                            ,pr_dsprotocolo out varchar2              --> Protocolo retornado na requisição
                            ,pr_dscritic    out varchar2
                            );
                                          
-- Rotina para solicitar analises não respondidas via POST ou solicitar a proposta enviada
procedure pc_solicita_retorno_analise(pr_cdcooper in crapcop.cdcooper%type
                                     ,pr_nrdconta in craplim.nrdconta%type
                                     ,pr_nrctrlim in craplim.nrctrlim%type
                                     ,pr_tpctrlim in craplim.tpctrlim%type
                                     ,pr_dsprotoc in craplim.dsprotoc%type
                                     );



procedure pc_enviar_analise_manual(pr_cdcooper    in craplim.cdcooper%type  --> Codigo da cooperativa
                                   ,pr_cdagenci    in crapage.cdagenci%type  --> Codigo da agencia                                          
                                   ,pr_cdoperad    in crapope.cdoperad%type  --> codigo do operador
                                   ,pr_cdorigem    in integer                --> Origem da operacao
                                   ,pr_nrdconta    in craplim.nrdconta%type  --> Numero da conta do cooperado
                                   ,pr_nrctrlim    in craplim.nrctrlim%type  --> Numero da proposta
                                   ,pr_tpctrlim    in craplim.tpctrlim%type  --> Tipo de contrato do limite
                                   ,pr_dtmvtolt    in VARCHAR2
                                   ,pr_nmarquiv  in varchar2                 --> Diretorio e nome do arquivo pdf da proposta
                                   ,vr_flgdebug  IN VARCHAR2                 --> Flag se debug ativo
                                    ---- OUT ----
                                   ,pr_dsmensag OUT VARCHAR2
                                   ,pr_cdcritic OUT NUMBER
                                   ,pr_dscritic OUT VARCHAR2
                                   ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                                   );

end ESTE0003;
/
create or replace package body cecred.ESTE0003 is

vr_flctgest boolean;
vr_flctgmot boolean;

--> Funcao para formatar data hora conforme padrao da IBRATAN
FUNCTION fn_DataTempo_ibra (pr_data IN DATE) RETURN VARCHAR2 IS
BEGIN
   RETURN to_char(pr_data,'RRRR-MM-DD"T"HH24:MI:SS".000Z"');
END fn_DataTempo_ibra;

PROCEDURE pc_verifica_contigenc_esteira(pr_cdcooper in crapcop.cdcooper%type
                                       ,pr_flctgest out boolean
                                       ,pr_dsmensag out varchar2
                                       ,pr_dscritic out varchar2
                                       ) is
   vr_contige_este VARCHAR2(500);
   vr_exc_erro EXCEPTION;
   vr_dscritic VARCHAR2(4000);
    
BEGIN  
   pr_flctgest := false;

   vr_contige_este := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_cdacesso => 'CONTIGENCIA_ESTEIRA_DESC');
   if  vr_contige_este is null then
       vr_dscritic := 'Parametro CONTIGENCIA_ESTEIRA_DESC não encontrado.';
       raise vr_exc_erro;      
   end if;
    
   if  vr_contige_este = '1' then
       pr_flctgest := true;
       pr_dsmensag := 'Atenção! O Envio para esteira está em contingencia';      
   end if;
  
EXCEPTION
   when vr_exc_erro then     
        pr_dscritic := vr_dscritic;
    
   when others then
        pr_dscritic := 'Não foi possivel buscar parametros da estira: '||sqlerrm;
END;


PROCEDURE pc_verifica_contigenc_motor(pr_cdcooper in crapcop.cdcooper%type
                                     ,pr_flctgmot out boolean
                                     ,pr_dsmensag out varchar2
                                     ,pr_dscritic out varchar2
                                     ) is
   vr_contige_moto VARCHAR2(500);
   vr_exc_erro     EXCEPTION;
   vr_dscritic     VARCHAR2(4000);
    
BEGIN  
   pr_flctgmot := false; 

   vr_contige_moto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_cdacesso => 'ANALISE_OBRIG_MOTOR_DESC');
   if  vr_contige_moto is null then
       vr_dscritic := 'Parametro ANALISE_OBRIG_MOTOR_DESC não encontrado.';
       raise vr_exc_erro;      
   end if;
    
   if  vr_contige_moto = '0' then
       pr_flctgmot := true; 
       pr_dsmensag := 'Atenção! O Envio para o motor está em contingencia';
   end if; 
  
EXCEPTION
   when vr_exc_erro then     
        pr_dscritic := vr_dscritic;
    
   when others then
        pr_dscritic := 'Não foi possivel buscar parametros do motor: '||sqlerrm;
END;


PROCEDURE pc_carrega_param_ibra(pr_cdcooper      IN crapcop.cdcooper%type  -- Codigo da cooperativa
                               ,pr_tpenvest      IN VARCHAR2 DEFAULT null  --> Tipo de envio C - Consultar(Get)
                               ,pr_host_esteira  OUT varchar2               -- Host da esteira
                               ,pr_recurso_este  OUT varchar2               -- URI da esteira
                               ,pr_dsdirlog      OUT varchar2               -- Diretorio de log dos arquivos 
                               ,pr_autori_este   OUT varchar2               -- Chave de acesso
                               ,pr_chave_aplica  OUT varchar2               -- App Key
                               ,pr_dscritic      OUT VARCHAR2) IS
  
    
  /* ..........................................................................
    
    Programa : pc_carrega_param_ibra        
    Sistema  : 
    Sigla    : CRED
    Autor    : Paulo Penteado (GFT)
    Data     : Fevereiro/2018.                   Ultima atualizacao: 16/02/2018
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Carregar parametros para uso na comunicacao com a esteira
    
    Alteração : 
        
  ..........................................................................*/  
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic NUMBER;
    
  BEGIN    
    -- Se houve erro
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF; 
  
   IF pr_tpenvest = 'M' THEN
   --> Buscar hots so webservice do motor
   pr_host_esteira := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                          pr_cdcooper => pr_cdcooper, 
                          pr_cdacesso => 'HOST_WEBSRV_MOTOR_IBRA');
   IF pr_host_esteira IS NULL THEN      
    vr_dscritic := 'Parametro HOST_WEBSRV_MOTOR_IBRA não encontrado.';
    RAISE vr_exc_erro;      
   END IF;
                                                   
   --> Buscar recurso uri do motor
   pr_recurso_este := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                          pr_cdcooper => pr_cdcooper, 
                          pr_cdacesso => 'URI_WEBSRV_MOTOR_IBRA');
   
   IF pr_recurso_este IS NULL THEN      
    vr_dscritic := 'Parametro URI_WEBSRV_MOTOR_IBRA não encontrado.';
    RAISE vr_exc_erro;      
   END IF;  
     
   --> Buscar chave de acesso do motor (Autorization é igual ao Consultas Automatizadas)
   pr_autori_este := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                  pr_cdcooper =>  pr_cdcooper,
                                                  pr_cdacesso => 'AUTORIZACAO_IBRATAN');
      IF pr_autori_este IS NULL THEN      
    vr_dscritic := 'Parametro AUTORIZACAO_IBRATAN não encontrado.';
    RAISE vr_exc_erro;      
   END IF;  
      
      -- Concatenar o Prefixo
      pr_autori_este := 'CECRED'||lpad(pr_cdcooper,2,'0')||':'||pr_autori_este;
      
      -- Gerar Base 64
      pr_autori_este := 'Ibratan '||sspc0001.pc_encode_base64(pr_autori_este);
      
   --> Buscar chave de aplicação do motor
   pr_chave_aplica := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                         pr_cdcooper => pr_cdcooper, 
                         pr_cdacesso => 'KEY_WEBSRV_MOTOR_IBRA');
   
   IF pr_chave_aplica IS NULL THEN      
    vr_dscritic := 'Parametro KEY_WEBSRV_MOTOR_IBRA não encontrado.';
    RAISE vr_exc_erro;      
   END IF;         
   
  ELSE
   --> Buscar hots so webservice da esteira
   pr_host_esteira := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                          pr_cdcooper => pr_cdcooper, 
                          pr_cdacesso => 'HOSWEBSRVCE_ESTEIRA_IBRA');
   IF pr_host_esteira IS NULL THEN      
    vr_dscritic := 'Parametro HOSWEBSRVCE_ESTEIRA_IBRA não encontrado.';
    RAISE vr_exc_erro;      
   END IF;
                                                   
   --> Buscar recurso uri da esteira
   pr_recurso_este := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                          pr_cdcooper => pr_cdcooper, 
                          pr_cdacesso => 'URIWEBSRVCE_RECURSO_IBRA');                                             
   
   IF pr_recurso_este IS NULL THEN      
    vr_dscritic := 'Parametro URIWEBSRVCE_RECURSO_IBRA não encontrado.';
    RAISE vr_exc_erro;      
   END IF;  
     
   --> Buscar chave de acesso da esteira
   pr_autori_este := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                          pr_cdcooper => pr_cdcooper, 
                          pr_cdacesso => 'KEYWEBSRVCE_ESTEIRA_IBRA');                                             
   
   IF pr_autori_este IS NULL THEN      
    vr_dscritic := 'Parametro KEYWEBSRVCE_ESTEIRA_IBRA não encontrado.';
    RAISE vr_exc_erro;      
   END IF;  
       
    END IF;
    --> Buscar diretorio do log
    pr_dsdirlog := gene0001.fn_diretorio(pr_tpdireto => 'C', 
                                         pr_cdcooper => 3, 
                                         pr_nmsubdir => '/log/webservices' ); 
  
  
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel buscar parametros da estira: '||SQLERRM;
  END;
  

PROCEDURE pc_enviar_proposta_esteira(pr_cdcooper in  craplim.cdcooper%type --> Codigo da cooperativa
                                    ,pr_cdagenci in  crapage.cdagenci%type --> Codigo da agencia
                                    ,pr_cdoperad in  crapope.cdoperad%type --> codigo do operador
                                    ,pr_idorigem in  integer               --> Origem da operacao
                                    ,pr_tpenvest in  varchar2              --> Tipo do envio esteira
                                    ,pr_nrctrlim in  craplim.nrctrlim%type --> Numero do Contrato do Limite.
                                    ,pr_tpctrlim in  craplim.tpctrlim%type --> Tipo de contrato do limite
                                    ,pr_nrdconta in  crapass.nrdconta%type --> Conta do associado
                                    ,pr_dtmovito in  varchar2 -- crapdat.dtmvtolt%type --> Data do movimento atual
                                    ,pr_dsmensag out varchar2              --> Mensagem 
                                    ,pr_cdcritic out pls_integer           --> Codigo da critica
                                    ,pr_dscritic out varchar2              --> Descricao da critica
                                    ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                                    ) is

  vr_dtmvtolt DATE;

  vr_cdagenci crapage.cdagenci%type; --> Codigo da agencia
  vr_inobriga varchar2(1);
  vr_tpenvest varchar2(1);
  
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
    
  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  
  -- Busca do nome do associado
  cursor cr_crapass is
  select ass.nmprimtl
        ,ass.inpessoa
        ,ass.cdagenci
  from   crapass ass
  where  ass.cdcooper = pr_cdcooper
  and    ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%rowtype;

  -- busca do limite do contrato
  cursor cr_craplim is
  select lim.rowid
       , lim.*
  from   craplim lim
  where  lim.cdcooper = pr_cdcooper  
  and    lim.nrdconta = pr_nrdconta
  and    lim.nrctrlim = pr_nrctrlim
  and    lim.tpctrlim = pr_tpctrlim;
  rw_craplim cr_craplim%ROWTYPE;

BEGIN
   pr_des_erro := 'OK';
   vr_tpenvest := pr_tpenvest;
   vr_dtmvtolt := TO_DATE(pr_dtmovito, 'DD/MM/YYYY');
  
  
   pc_verifica_contigenc_motor(pr_cdcooper => pr_cdcooper
                              ,pr_flctgmot => vr_flctgmot
                              ,pr_dsmensag => pr_dsmensag
                              ,pr_dscritic => pr_dscritic);

   pc_verifica_contigenc_esteira(pr_cdcooper => pr_cdcooper
                                ,pr_flctgest => vr_flctgest
                                ,pr_dsmensag => pr_dsmensag
                                ,pr_dscritic => pr_dscritic);
                                
   if  vr_flctgmot and vr_flctgest then
       pr_cdcritic := 0;
       pr_dscritic := '';
       pr_dsmensag := 'O Motor e a Esteira estão em contingência, efetue a análise manual e para efetivar pressione o botão \"Confirmar Novo Limite\".';
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
     
   open  cr_craplim;
   fetch cr_craplim into rw_craplim;
   if    cr_craplim%notfound then
         close cr_craplim;
         vr_dscritic := 'Associado nao possui proposta de limite de credito. Conta: ' || pr_nrdconta || '.Contrato: ' || pr_nrctrlim;
         raise vr_exc_saida;
   end   if;
   close cr_craplim;
   
   tela_atenda_limdesctit.pc_validar_data_proposta(pr_cdcooper => pr_cdcooper
                                                  ,pr_nrdconta => rw_craplim.nrdconta
                                                  ,pr_nrctrlim => pr_nrctrlim
                                                  ,pr_tpctrlim => pr_tpctrlim
                                                  ,pr_cdcritic => vr_cdcritic
                                                  ,pr_dscritic => vr_dscritic);

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;

   if  vr_tpenvest = 'I' then
       vr_inobriga := 'N';
       
       -- Verificar se a proposta devera passar por analise automatica
       pc_obrigacao_analise_automatic(pr_cdcooper => pr_cdcooper
                                     ,pr_inobriga => vr_inobriga
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
       -- Se: 1 - Ja houve envio para a Esteira
       --     2 - Nao precisar passar por Analise Automatica
       --     3 - Nao existir protocolo gravado
       if  rw_craplim.dtenvest is not null and vr_inobriga <> 'S' and (trim(rw_craplim.dsprotoc) is null) then
           -- Significa que a proposta jah foi para a Esteira, entao devemos mandar um reinicio de Fluxo
           vr_tpenvest := 'A';
       end if;
   end if;

         
   /***** Verificar se a Esteira esta em contigencia *****/
   pc_verifica_regras_esteira(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => rw_craplim.nrdconta
                             ,pr_nrctrlim => pr_nrctrlim
                             ,pr_tpctrlim => pr_tpctrlim
                             ,pr_tpenvest => vr_tpenvest
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;
       
   /***** INCLUIR/DERIVAR PROPOSTA *****/ 
   if  vr_tpenvest in ('I','D') then
       pc_incluir_proposta_est(pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_cdorigem => pr_idorigem
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrctrlim => pr_nrctrlim
                              ,pr_tpctrlim => pr_tpctrlim
                              ,pr_dtmvtolt => vr_dtmvtolt
                              ,pr_nmarquiv => null
                              -- out
                              ,pr_dsmensag => pr_dsmensag
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

       if  vr_cdcritic > 0  or vr_dscritic is not null then
           raise vr_exc_saida;
       end if;
   end if;

   COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
       -- Se possui código de crítica e não foi informado a descrição
       IF  vr_cdcritic <> 0 and TRIM(vr_dscritic) IS NULL THEN
           -- Busca descrição da crítica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
        
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_des_erro := 'NOK';

       ROLLBACK;
        
  WHEN OTHERS THEN
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na ESTE0003.pc_enviar_proposta_esteira: ' || SQLERRM;
       pr_des_erro := 'NOK';

       ROLLBACK;
END pc_enviar_proposta_esteira;

/*PROCEDURE pc_gera_json_proposta(pr_cdcooper  IN craplim.cdcooper%TYPE  --> Codigo da cooperativa
                               ,pr_cdagenci  IN crapage.cdagenci%TYPE  --> Codigo da agencia                                            
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE  --> codigo do operado
                               ,pr_cdorigem  IN INTEGER                --> Origem da operacao
                               ,pr_nrdconta  IN craplim.nrdconta%TYPE  --> Numero da conta do cooperado
                               ,pr_nrctrlim  IN craplim.nrctrlim%TYPE  --> Numero da proposta de emprestimo
                               ,pr_tpctrlim  in craplim.tpctrlim%type  --> Tipo de contrato do limite
                               ,pr_nmarquiv  IN VARCHAR2               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                               ---- OUT ----
                               ,pr_proposta OUT JSON                   --> Retorno do clob em modelo json da proposta de emprestimo
                               ,pr_cdcritic OUT NUMBER                 --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2               --> Descricao da critica
                               ) is
begin 
  popd implementar para limite, igual ao emprestimo, verificar se haverá a necessidade por enquanto, pois a geração de pdf
  está no progress, e no emprestimo chama a rotina do progress por shell execute
  null;
end;*/

PROCEDURE pc_obrigacao_analise_automatic(pr_cdcooper in crapcop.cdcooper%type  -- Cód. cooperativa
                                         ---- OUT ----                                          
                                        ,pr_inobriga out varchar2              -- Indicador de obrigaçao de análisa automática ('S' - Sim / 'N' - Nao)
                                        ,pr_cdcritic out pls_integer           -- Cód. da crítica
                                        ,pr_dscritic out varchar2) is          -- Desc. da crítica
vr_dsmensag varchar2(1000);
begin 
   pc_verifica_contigenc_motor(pr_cdcooper => pr_cdcooper
                              ,pr_flctgmot => vr_flctgmot
                              ,pr_dsmensag => vr_dsmensag
                              ,pr_dscritic => pr_dscritic);

   pc_verifica_contigenc_esteira(pr_cdcooper => pr_cdcooper
                                ,pr_flctgest => vr_flctgest
                                ,pr_dsmensag => vr_dsmensag
                                ,pr_dscritic => pr_dscritic);

   -- OU Esteira está em contingencia 
   -- OU a Cooperativa nao Obriga Análise Automática
   if  vr_flctgest or vr_flctgmot then
       pr_inobriga := 'N';
   else 
       pr_inobriga := 'S';
   end if;
      
exception     
   when others then
        pr_cdcritic := 0;
        pr_dscritic := 'Erro inesperado na rotina que verifica o tipo de análise da proposta: '||sqlerrm;
end pc_obrigacao_analise_automatic;  

  
PROCEDURE pc_verifica_regras_esteira (pr_cdcooper  IN craplim.cdcooper%TYPE  -- Codigo da cooperativa                                        
                                     ,pr_nrdconta  IN craplim.nrdconta%TYPE  -- Numero da conta do cooperado
                                     ,pr_nrctrlim  IN craplim.nrctrlim%TYPE  -- Numero do contrato de emprestimo
                                     ,pr_tpctrlim  in craplim.tpctrlim%type  --> Tipo de contrato do limite.
                                     ,pr_tpenvest  IN VARCHAR2 DEFAULT NULL  -- Tipo de envio
                                      ---- OUT ----                                        
                                     ,pr_cdcritic OUT NUMBER                 -- Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2) is
/* ..........................................................................
    
    Programa : pc_verifica_regras_esteira        
    Sistema  : 
    Sigla    : CRED
    Autor    : Paulo Penteado GFT
    Data     : Fevereiro/2018.                   Ultima atualizacao: 16/02/2018
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento para verificar as regras da esteira 
    
    Alteração : 
        
  ..........................................................................*/
    -----------> CURSORES <-----------
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_craplim is
      select lim.insitest
           , lim.cdopeapr
           , lim.insitapr
      from   craplim lim
      where  lim.cdcooper = pr_cdcooper
      and    lim.nrdconta = pr_nrdconta
      and    lim.nrctrlim = pr_nrctrlim
      and    lim.tpctrlim = pr_tpctrlim; 
    rw_craplim cr_craplim%ROWTYPE;
    
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;
    
  BEGIN
    -- Para inclusão, alteração ou derivação
    IF nvl(pr_tpenvest,' ') IN ('I','A','D') THEN    
      
      --> Buscar dados da proposta
      OPEN  cr_craplim;
      FETCH cr_craplim INTO rw_craplim;
      IF    cr_craplim%NOTFOUND THEN
            CLOSE cr_craplim;
            vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
            RAISE vr_exc_erro;
      END IF;
      
      -- Somente permitirá se ainda não enviada 
      -- OU se foi Reprovada pelo Motor
      -- ou se houve Erro Conexão
      -- OU se foi enviada e recebemos a Derivação 
      IF  rw_craplim.insitest = 0 
      OR (rw_craplim.insitest = 3 AND rw_craplim.insitapr = 5) 
      OR (rw_craplim.insitest = 3 AND rw_craplim.insitapr = 8 AND pr_tpenvest = 'I')       
      /*OR (rw_craplim.insitest = 3 AND rw_craplim.insitapr = 5)*/ THEN
        -- Sair pois pode ser enviada
        RETURN;
      END IF;
      -- Não será possível enviar/reenviar para a Esteira
      vr_dscritic := 'A proposta não pode ser enviada para Análise de crédito, verifique a situação da proposta!';
      RAISE vr_exc_erro;      
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel verificar regras da Análise de Crédito: '||SQLERRM;
END pc_verifica_regras_esteira;  


PROCEDURE pc_derivar_proposta_est(pr_cdcooper  in craplim.cdcooper%type     --> Codigo da cooperativa
                                 ,pr_cdagenci  in crapage.cdagenci%type     --> Codigo da agencia           
                                 ,pr_cdoperad  in crapope.cdoperad%type     --> codigo do operador
                                 ,pr_cdorigem  in integer                   --> Origem da operacao
                                 ,pr_nrdconta  in craplim.nrdconta%type     --> Numero da conta do cooperado
                                 ,pr_nrctrlim  in craplim.nrctrlim%type     --> Numero da proposta
                                 ,pr_tpctrlim  in craplim.tpctrlim%type     --> Tipo de contrato do limite
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
  Objetivo  : Rotina responsavel por verificar a proposta e enviar inclusao ou alteração da proposta na esteira
  
  Alteração : 27/02/2018 criação (Paulo Penteado (GFT))

  ..........................................................................*/

  -- Tratamento de erros
  vr_cdcritic number := 0;
  vr_dscritic varchar2(4000);
  vr_dsmensag varchar2(4000);
  vr_exc_erro exception;

  -- Buscar informações da Proposta
  cursor cr_craplim is
  select lim.insitest
        ,lim.insitapr
        ,lim.dtenvest
        ,lim.dsprotoc
  from   craplim lim
  where  lim.cdcooper = pr_cdcooper
  and    lim.nrdconta = pr_nrdconta
  and    lim.nrctrlim = pr_nrctrlim
  and    lim.tpctrlim = pr_tpctrlim;
  rw_craplim cr_craplim%rowtype;

  -- Variaveis para DEBUG
  vr_flgdebug varchar2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
  vr_idaciona tbgen_webservice_aciona.idacionamento%type;

BEGIN
   --  Se o DEBUG estiver habilitado
   if  vr_flgdebug = 'S' then
       ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper
                                    ,pr_cdagenci              => pr_cdagenci
                                    ,pr_cdoperad              => pr_cdoperad
                                    ,pr_cdorigem              => pr_cdorigem
                                    ,pr_nrctrprp              => pr_nrctrlim
                                    ,pr_tpproduto             => 3 --> Desconto de títulos
                                    ,pr_nrdconta              => pr_nrdconta
                                    ,pr_tpacionamento         => 0  /* 0 - DEBUG */
                                    ,pr_dsoperacao            => 'INICIO DERIVAR PROPOSTA'
                                    ,pr_dsuriservico          => null
                                    ,pr_dtmvtolt              => pr_dtmvtolt
                                    ,pr_cdstatus_http         => 0
                                    ,pr_dsconteudo_requisicao => null
                                    ,pr_dsresposta_requisicao => null
                                    ,pr_idacionamento         => vr_idaciona
                                    ,pr_dscritic              => vr_dscritic);
       -- Sem tratamento de exceção para DEBUG
       --IF TRIM(vr_dscritic) IS NOT NULL THEN
       --  RAISE vr_exc_erro;
       --END IF;
   end if;

   open  cr_craplim;
   fetch cr_craplim into rw_craplim;
   close cr_craplim;

   --  Para Propostas ainda não enviada para a Esteira
   if  rw_craplim.dtenvest is null then
       -- Inclusão na esteira
       pc_incluir_proposta_est(pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => pr_cdagenci
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_cdorigem => pr_cdorigem
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrctrlim => pr_nrctrlim
                              ,pr_tpctrlim => pr_tpctrlim
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_nmarquiv => null
                              ,pr_dsmensag => vr_dsmensag
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
   else
       -- Atualização com reinício de fluxo
       pc_alterar_proposta_est(pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => pr_cdagenci
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_cdorigem => pr_cdorigem
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrctrlim => pr_nrctrlim
                              ,pr_tpctrlim => pr_tpctrlim
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_flreiflx => 1
                              ,pr_nmarquiv => null
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

   end if;

   if  nvl(vr_cdcritic,0) > 0 or vr_dscritic is not null then
       raise vr_exc_erro;
   end if;

   -- Se o DEBUG estiver habilitado
   if  vr_flgdebug = 'S' then
       ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper
                                    ,pr_cdagenci              => pr_cdagenci
                                    ,pr_cdoperad              => pr_cdoperad
                                    ,pr_cdorigem              => pr_cdorigem
                                    ,pr_nrctrprp              => pr_nrctrlim
                                    ,pr_tpproduto             => 3 --> Desconto de títulos
                                    ,pr_nrdconta              => pr_nrdconta
                                    ,pr_tpacionamento         => 0  /* 0 - DEBUG */
                                    ,pr_dsoperacao            => 'TERMINO DERIVAR PROPOSTA'
                                    ,pr_dsuriservico          => null
                                    ,pr_dtmvtolt              => pr_dtmvtolt
                                    ,pr_cdstatus_http         => 0
                                    ,pr_dsconteudo_requisicao => null
                                    ,pr_dsresposta_requisicao => null
                                    ,pr_idacionamento         => vr_idaciona
                                    ,pr_dscritic              => vr_dscritic);
       -- Sem tratamento de exceção para DEBUG
       --IF TRIM(vr_dscritic) IS NOT NULL THEN
       --  RAISE vr_exc_erro;
       --END IF;
   end if;

   COMMIT;

EXCEPTION
   when vr_exc_erro then
        --> Buscar critica
        if  nvl(vr_cdcritic,0) > 0 and trim(vr_dscritic) is null then
            -- Busca descricao
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        end if;

        --> Gerar em LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2
                                  ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')|| 
                                                      ' - WEBS0001 --> Erro ao solicitor Derivacao Automatica '||
                                                      ' do Protocolo: '||rw_craplim.dsprotoc||
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
        vr_dscritic := 'Não foi possivel realizar derivacao da proposta de Análise de Crédito: '||sqlerrm;

        --> Gerar em LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2
                                  ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||
                                                      ' - WEBS0001 --> Erro ao solicitor Derivacao Automatica '||
                                                      ' do Protocolo: '||rw_craplim.dsprotoc||
                                                      ', erro: '||vr_cdcritic||'-'||vr_dscritic
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                  ,pr_cdacesso     => 'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_flnovlog     => 'N'
                                  ,pr_flfinmsg     => 'S'
                                  ,pr_dsdirlog     => null
                                  ,pr_dstiplog     => 'O'
                                  ,pr_cdprograma   => null);
END pc_derivar_proposta_est;


PROCEDURE pc_incluir_proposta_est(pr_cdcooper  IN craplim.cdcooper%TYPE
                                 ,pr_cdagenci  IN crapage.cdagenci%TYPE
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                 ,pr_cdorigem  IN INTEGER
                                 ,pr_nrdconta  IN craplim.nrdconta%TYPE
                                 ,pr_nrctrlim  IN craplim.nrctrlim%TYPE
                                 ,pr_tpctrlim  in craplim.tpctrlim%type
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                 ,pr_nmarquiv  IN VARCHAR2
                                  ---- OUT ----
                                 ,pr_dsmensag OUT VARCHAR2
                                 ,pr_cdcritic OUT NUMBER
                                 ,pr_dscritic OUT VARCHAR2) IS
  /* ...........................................................................
  
    Programa : pc_incluir_proposta_est        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Lindon Carlos Pecile - GFT-Brasil
    Data     : Fevereiro/2018.          Ultima atualizacao: 10/02/2018
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina responsavel por gerar a inclusao da proposta para a esteira    
    Alteraçao : 
                13/07/2017 - P337 - Ajustes para envio ao Motor - Marcos(Supero)
        
                15/12/2017 - P337 - SM - Ajustes no envio para retormar reinício 
                             de fluxo (Marcos-Supero)        
  ..........................................................................*/
    
  ----------- VARIAVEIS <-----------
  -- Tratamento de erros
  vr_cdcritic NUMBER := 0;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
    
  vr_obj_proposta json := json();
  vr_obj_proposta_clob clob;
    
  vr_dsprotoc VARCHAR2(1000);
  vr_comprecu VARCHAR2(1000);
    
  -- Buscar informaçoes da Proposta
  cursor cr_craplim is
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
        ,craplim lim
  where  ass.cdcooper = lim.cdcooper
  and    ass.nrdconta = lim.nrdconta
  and    lim.cdcooper = pr_cdcooper
  and    lim.nrdconta = pr_nrdconta
  and    lim.nrctrlim = pr_nrctrlim
  and    lim.tpctrlim = pr_tpctrlim;
  rw_craplim cr_craplim%ROWTYPE;
    
  -- Acionamentos de retorno
  cursor cr_aciona_retorno(pr_dsprotocolo varchar2) is
    select ac.dsconteudo_requisicao
    from   tbgen_webservice_aciona ac
    where  ac.cdcooper      = pr_cdcooper
    and    ac.nrdconta      = pr_nrdconta
    and    ac.nrctrprp      = pr_nrctrlim
    and    ac.dsprotocolo   = pr_dsprotocolo
    and    ac.tpacionamento = 2; 
  -- Somente Retorno
  vr_dsconteudo_requisicao tbgen_webservice_aciona.dsconteudo_requisicao%TYPE;
    
  -- Hora de Envio
  vr_hrenvest craplim.hrenvest%TYPE;
  -- Quantidade de segundos de Espera
  vr_qtsegund NUMBER;
  -- Analise finalizada
  vr_flganlok boolean := FALSE;
    
  -- Objetos para retorno das mensagens
  vr_obj     cecred.json := json();
  vr_obj_anl cecred.json := json();
  vr_obj_lst cecred.json_list := json_list();
  vr_obj_msg cecred.json := json();
  vr_destipo varchar2(1000);
  vr_desmens varchar2(4000);
  vr_dsmensag VARCHAR2(32767);
    
  -- Variaveis para DEBUG
  vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
  vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
    
BEGIN    
    
  -- Se o DEBUG estiver habilitado
  IF vr_flgdebug = 'S' THEN
    -- Gravar dados log acionamento
    ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                                  pr_cdagenci              => pr_cdagenci,          
                                  pr_cdoperad              => pr_cdoperad,          
                                  pr_cdorigem              => pr_cdorigem,          
                                  pr_nrctrprp              => pr_nrctrlim,          
                                  pr_nrdconta              => pr_nrdconta,          
                                  pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                  pr_dsoperacao            => 'INICIO INCLUIR PROPOSTA',       
                                  pr_dsuriservico          => NULL,       
                                  pr_dtmvtolt              => pr_dtmvtolt,       
                                  pr_cdstatus_http         => 0,
                                  pr_dsconteudo_requisicao => null,
                                  pr_dsresposta_requisicao => null,
                                  pr_tpproduto             => 3, --> Desconto de títulos
                                  pr_idacionamento         => vr_idaciona,
                                  pr_dscritic              => vr_dscritic);
                                 
    -- Sem tratamento de exceçao para DEBUG                    
    --IF TRIM(vr_dscritic) IS NOT NULL THEN
    --  RAISE vr_exc_erro;
    --END IF;
  END IF; 
  
  -- Buscar informaçoes da proposta
  OPEN cr_craplim;
  FETCH cr_craplim INTO rw_craplim;
  CLOSE cr_craplim;
    
  pc_verifica_contigenc_motor(pr_cdcooper => pr_cdcooper
                             ,pr_flctgmot => vr_flctgmot
                             ,pr_dsmensag => pr_dsmensag
                             ,pr_dscritic => pr_dscritic);
  
  -- Se Obrigatorio e ainda nao Enviada ou Enviada mas com Erro Conexao
  IF not(vr_flctgmot) AND (rw_craplim.insitest = 0 OR rw_craplim.insitapr = 8) THEN 
      
    -- Gerar informaçoes no padrao JSON da proposta de emprestimo
    ESTE0004.pc_gera_json_analise_lim(pr_cdcooper  => pr_cdcooper
                                     ,pr_cdagenci  => rw_craplim.cdagenci
                                     ,pr_nrdconta  => pr_nrdconta
                                     ,pr_nrctrlim  => pr_nrctrlim
                                     ,pr_tpctrlim  => pr_tpctrlim
                                     ,pr_nrctaav1  => rw_craplim.nrctaav1
                                     ,pr_nrctaav2  => rw_craplim.nrctaav2
                                     ---- OUT ----
                                     ,pr_dsjsonan  => vr_obj_proposta     -- Retorno do clob em modelo json das informaçoes
                                     ,pr_cdcritic  => vr_cdcritic         -- Codigo da critica
                                     ,pr_dscritic  => vr_dscritic);        -- Descricao da critica
      
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;        
    END IF;           
      
    -- Efetuar montagem do nome do Fluxo de Análise Automatica conforme o tipo de pessoa da Proposta
    IF rw_craplim.inpessoa = 1 THEN 
      vr_comprecu := '/definition/'|| gene0001.fn_param_sistema('CRED'
                                                                ,pr_cdcooper
                                                                ,'REGRA_ANL_MOTOR_PF_DESC')||'/start';    
    ELSE
      vr_comprecu := '/definition/'|| gene0001.fn_param_sistema('CRED'
                                                                ,pr_cdcooper
                                                                ,'REGRA_ANL_MOTOR_PJ_DESC')||'/start';            
    END IF;    
          
                                                          
    -- Criar o CLOB para converter JSON para CLOB
    dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
    json.to_clob(vr_obj_proposta,vr_obj_proposta_clob);
      
    -- Se o DEBUG estiver habilitado
    IF vr_flgdebug = 'S' THEN
      -- Gravar dados log acionamento
      ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                                    pr_cdagenci              => pr_cdagenci,          
                                    pr_cdoperad              => pr_cdoperad,          
                                    pr_cdorigem              => pr_cdorigem,          
                                    pr_nrctrprp              => pr_nrctrlim,          
                                    pr_nrdconta              => pr_nrdconta,          
                                    pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                    pr_dsoperacao            => 'ANTES ENVIAR PROPOSTA',       
                                    pr_dsuriservico          => NULL,       
                                    pr_dtmvtolt              => pr_dtmvtolt,       
                                    pr_cdstatus_http         => 0,
                                    pr_dsconteudo_requisicao => vr_obj_proposta_clob,
                                    pr_dsresposta_requisicao => null,
                                    pr_tpproduto             => 3, --> Desconto de títulos
                                    pr_idacionamento         => vr_idaciona,
                                    pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceçao para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;       
      
    -- Enviar dados para Análise Automática Esteira (Motor)
    pc_enviar_esteira(pr_cdcooper    => pr_cdcooper
                     ,pr_cdagenci    => pr_cdagenci
                     ,pr_cdoperad    => pr_cdoperad
                     ,pr_cdorigem    => pr_cdorigem
                     ,pr_nrdconta    => pr_nrdconta
                     ,pr_nrctrlim    => pr_nrctrlim
                     ,pr_dtmvtolt    => pr_dtmvtolt
                     ,pr_comprecu    => vr_comprecu
                     ,pr_dsmetodo    => 'POST'
                     ,pr_conteudo    => vr_obj_proposta_clob
                     ,pr_dsoperacao  => 'ENVIO DA PROPOSTA PARA ANALISE AUTOMATICA DE CREDITO'
                     ,pr_tpenvest    => 'M'
                     ,pr_dsprotocolo => vr_dsprotoc
                     ,pr_dscritic    => vr_dscritic);

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_obj_proposta_clob);
    dbms_lob.freetemporary(vr_obj_proposta_clob);                        
                        
    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
      
    -- Atualizar a proposta
    vr_hrenvest := to_char(SYSDATE,'sssss');
    BEGIN
      UPDATE craplim lim 
         SET lim.insitest = 2, -- Enviada Analise Manual 1, -- Enviada para Analise Autom
             lim.dtenvmot = trunc(SYSDATE), 
             lim.hrenvmot = vr_hrenvest,
             lim.cdopeste = pr_cdoperad,
             lim.dsprotoc = nvl(vr_dsprotoc,' '),
             lim.insitapr = 0,
             lim.cdopeapr = NULL,
             lim.dtaprova = NULL,
             lim.hraprova = 0
       WHERE lim.rowid = rw_craplim.rowid;
    EXCEPTION    
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da Análise Automática de Crédito: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Efetuar gravaçao
    COMMIT;
      
    -- Buscar a quantidade de segundos de espera pela Análise Automática
    vr_qtsegund := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'TIME_RESP_MOTOR_DESC'),30);

    -- Efetuar laço para esperarmos (N) segundos ou o termino da analise recebido via POST
    WHILE NOT vr_flganlok AND to_number(to_char(sysdate,'sssss')) - vr_hrenvest < vr_qtsegund LOOP

      -- Aguardar 0.5 segundo para evitar sobrecarga de processador
      sys.dbms_lock.sleep(0.5);
        
      -- Verificar se a analise jah finalizou 
      OPEN cr_craplim;
      FETCH cr_craplim INTO rw_craplim;
      CLOSE cr_craplim;
        
      -- Se a proposta mudou de situaçao Esteira
      IF rw_craplim.insitest <> 2 THEN 
        -- Indica que terminou a analise 
        vr_flganlok := true;
      END IF;

    END LOOP;
      
    -- Se chegarmos neste ponto e a analise nao voltou OK signifca que houve timeout
    IF NOT vr_flganlok THEN 
      -- Entao acionaremos a rotina que solicita via GET o termino da análise
      -- e caso a mesma ainda nao tenha terminado, a proposta será salva como Expirada
      pc_solicita_retorno_analise(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctrlim => pr_nrctrlim
                                 ,pr_tpctrlim => pr_tpctrlim
                                 ,pr_dsprotoc => vr_dsprotoc);
    END IF;
      
    -- Reconsultar a situaçao esteira e parecer para retorno
    OPEN  cr_craplim;
    FETCH cr_craplim INTO rw_craplim;
    CLOSE cr_craplim;
      
    -- Se houve expiraçao
    if    rw_craplim.insitest = 0 then 
          pr_dsmensag := '<b>Não enviado</b>';
    elsif rw_craplim.insitest = 1 then 
          pr_dsmensag := '<b>Enviado para analise automatica</b>';
    elsif rw_craplim.insitest = 2 then 
          pr_dsmensag := '<b>Enviada para analise manual</b>';
    elsif rw_craplim.insitest = 3 then 
          -- Conforme tipo de aprovacao
          if    rw_craplim.insitapr = 0 then 
                pr_dsmensag := '<b>Não analisado</b>';
          elsif rw_craplim.insitapr = 1 then
                pr_dsmensag := '<b>Aprovado automaticamente</b>';
          elsif rw_craplim.insitapr = 2 then 
                pr_dsmensag := '<b>Aprovado manual</b>';          
          elsif rw_craplim.insitapr = 3 then 
                pr_dsmensag := '<b>Aprovada contigencia</b>';        
          elsif rw_craplim.insitapr = 4 then
                pr_dsmensag := '<b>Rejeitado manual</b>';
          elsif rw_craplim.insitapr = 5 then
                pr_dsmensag := '<b>Rejeitado automaticamente</b>';
          elsif rw_craplim.insitapr = 6 then
                pr_dsmensag := '<b>Rejeitado Contigencia</b>';
          elsif rw_craplim.insitapr = 7 then
                pr_dsmensag := '<b>Não analisado</b>';
          elsif rw_craplim.insitapr = 8 then
                pr_dsmensag := '<b>Refazer</b>';
          end   if;
    elsif rw_craplim.insitest = 4 then
          pr_dsmensag := '<b>Expirada</b> apos '||vr_qtsegund||' segundos de espera.';        
    else 
          pr_dsmensag := '<b>Finalizada</b> com situaçao indefinida!';
    end   if;
      
    -- Gerar mensagem padrao:
    pr_dsmensag := 'Resultado da Avaliaçao: '||pr_dsmensag;
      
    --  Se houver protocolo e a analise foi encerrada ou derivada
    if  vr_dsprotoc is not null and rw_craplim.insitest in (2,3) then 
        --    Buscar os detalhes do acionamento de retorno
        open  cr_aciona_retorno(vr_dsprotoc);
        fetch cr_aciona_retorno into vr_dsconteudo_requisicao;
        if    cr_aciona_retorno%found then 
              -- Processar as mensagens para adicionar ao retorno
              begin 
                 -- Efetuar cast para JSON
                 vr_obj := json(vr_dsconteudo_requisicao);            

                 --  Se existe o objeto de analise
                 if  vr_obj.exist('analises') then
                     vr_obj_anl := json(vr_obj.get('analises').to_char());        
                     
                     --  Se existe a lista de mensagens
                     if  vr_obj_anl.exist('mensagensDeAnalise') then
                         vr_obj_lst := json_list(vr_obj_anl.get('mensagensDeAnalise').to_char());

                         --   Para cada mensagem 
                         for vr_idx in 1..vr_obj_lst.count() loop
                             begin
                                vr_obj_msg := json( vr_obj_lst.get(vr_idx));
                                
                                --  Se encontrar o atributo texto e tipo
                                if  vr_obj_msg.exist('texto') and vr_obj_msg.exist('tipo') then
                                    vr_desmens := gene0007.fn_convert_web_db(unistr(replace(rtrim(ltrim(vr_obj_msg.get('texto').to_char(),'"'),'"'),'\u','\')));
                                    vr_destipo := replace(rtrim(ltrim(vr_obj_msg.get('tipo').to_char(),'"'),'"'),'ERRO','REPROVAR');
                                end if;

                                if  vr_destipo <> 'DETALHAMENTO' then
                                    vr_dsmensag := vr_dsmensag || '<BR>['||vr_destipo||'] '||vr_desmens;                              
                                end if;
                             exception
                                when others then
                                     null; -- Ignorar essa linha
                             end;
                         end loop;
                     end if;
                 end if;
              exception
                 when others then 
                      null; -- Ignorar se o conteudo nao for JSON nao conseguiremos ler as mensagens
              end; 
        end   if;
        close cr_aciona_retorno;           

        --  Se nao encontrou mensagem
        if  vr_dsmensag is null then 
            -- Usar mensagem padrao
            vr_dsmensag := '<br>Obs: Clique no botão \"Detalhes Proposta\" para visualização de mais detalhes';
        else
            -- Gerar texto padrao 
            vr_dsmensag := '<br>Detalhes da decisao: <br>'|| vr_dsmensag;
        end if;

        pr_dsmensag := pr_dsmensag ||vr_dsmensag;
    end if;
      
    -- Commitar o encerramento da rotina 
    COMMIT;
      
  ELSE
    pc_enviar_analise_manual(pr_cdcooper => pr_cdcooper
                            ,pr_cdagenci => pr_cdagenci
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_cdorigem => pr_cdorigem
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrctrlim => pr_nrctrlim
                            ,pr_tpctrlim => pr_tpctrlim
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_nmarquiv => pr_nmarquiv
                            ,vr_flgdebug => vr_flgdebug
                             ---- OUT ----
                            ,pr_dsmensag => pr_dsmensag
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic
                            ,pr_des_erro => vr_des_erro);
                                   
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;        
    END IF;
  END IF;  
    
  COMMIT;   
    
EXCEPTION
  WHEN vr_exc_erro THEN
      
    -- Buscar critica
    IF nvl(vr_cdcritic,0) > 0 AND 
      TRIM(vr_dscritic) IS NULL THEN
      -- Busca descricao        
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
    END IF;  
      
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
    
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Nao foi possivel realizar inclusao da proposta de Análise de Crédito: '||SQLERRM;
END pc_incluir_proposta_est;

  --> Rotina responsavel por gerar a alteracao da proposta para a esteira
  procedure pc_alterar_proposta_est(pr_cdcooper  in craplim.cdcooper%type  --> Codigo da cooperativa
                                   ,pr_cdagenci  in crapage.cdagenci%type  --> Codigo da agencia                                          
                                   ,pr_cdoperad  in crapope.cdoperad%type  --> codigo do operador
                                   ,pr_cdorigem  in integer                --> Origem da operacao
                                   ,pr_nrdconta  in craplim.nrdconta%type  --> Numero da conta do cooperado
                                   ,pr_nrctrlim  in craplim.nrctrlim%type  --> Numero da proposta de emprestimo
                                   ,pr_tpctrlim  in craplim.tpctrlim%type  --> Tipo de contrato do limite
                                   ,pr_dtmvtolt  in crapdat.dtmvtolt%type  --> Data do movimento
                                   ,pr_flreiflx  in integer                --> Indica se deve reiniciar o fluxo de aprovacao na esteira
                                   ,pr_nmarquiv  in varchar2               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                   ---- OUT ----                           
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
      Alteração : 
        
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
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_dsmensag VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
      
    -- Objeto json da proposta
    vr_obj_alter    json := json();
    vr_obj_proposta json := json();
    vr_obj_agencia  json := json();  
            vr_dsprotocolo  VARCHAR2(1000);
    vr_obj_proposta_clob clob;
    
    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100) := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DEBUG_MOTOR_IBRA');
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;    
    
  BEGIN                  
    
    -- Se o DEBUG estiver habilitado
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
                                    pr_tpproduto             => 3, --> Desconto de títulos
                                    pr_idacionamento         => vr_idaciona,
                                    pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;   
  
    --> Gerar informações no padrao JSON da proposta de emprestimo
    este0004.pc_gera_json_proposta(pr_cdcooper  => pr_cdcooper
                                  ,pr_cdagenci  => pr_cdagenci
                                  ,pr_cdoperad  => pr_cdoperad
                                  ,pr_nrdconta  => pr_nrdconta
                                  ,pr_nrctrlim  => pr_nrctrlim
                                  ,pr_tpctrlim  => pr_tpctrlim
                                  ,pr_nmarquiv  => pr_nmarquiv  --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                  ---- OUT ----
                                  ,pr_proposta  => vr_obj_proposta  --> Retorno do clob em modelo json da proposta de emprestimo
                                  ,pr_cdcritic  => vr_cdcritic
                                  ,pr_dscritic  => vr_dscritic);
    
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;        
    END IF;  
    
    -- Buscar dados do operador
    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
      RAISE vr_exc_erro; 
    ELSE
      CLOSE cr_crapope;
    END IF;        
    
    -- Incluir objeto proposta
    vr_obj_alter.put('dadosAtualizados'      ,vr_obj_proposta);
    vr_obj_alter.put('operadorAlteracaoLogin',lower(pr_cdoperad));
    vr_obj_alter.put('operadorAlteracaoNome' ,rw_crapope.nmoperad) ;
    vr_obj_alter.put('dataHora'              ,fn_DataTempo_ibra(SYSDATE)) ;
    vr_obj_alter.put('reiniciaFluxo'         ,(pr_flreiflx = 1) ) ;
    
    --> Criar objeto json para agencia do cooperado
    vr_obj_agencia.put('cooperativaCodigo'   , pr_cdcooper);
    vr_obj_agencia.put('PACodigo'            , pr_cdagenci);    
    vr_obj_alter.put('operadorAlteracaoPA'      , vr_obj_agencia);
    
    -- Criar o CLOB para converter JSON para CLOB
    dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
    json.to_clob(vr_obj_alter,vr_obj_proposta_clob);
    
    -- Se o DEBUG estiver habilitado
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
                                    pr_tpproduto             => 3, --> Desconto de títulos
                                    pr_idacionamento         => vr_idaciona,
                                    pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;  
    
    --> Enviar dados para Esteira
    pc_enviar_esteira(pr_cdcooper    => pr_cdcooper
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
    
    -- Se não houve erro
    IF vr_dscritic IS NULL THEN 
    
    --> Atualizar proposta
    begin
      update craplim lim 
      set    lim.insitest = 2 -->  2 – Reenviado para Analise
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

    
    -- Caso tenhamos recebido critica de Proposta jah existente na Esteira
    ELSIF lower(vr_dscritic) LIKE '%proposta nao encontrada%' THEN

      -- Tentaremos enviar inclusão novamente na Esteira
      pc_incluir_proposta_est(pr_cdcooper => pr_cdcooper
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

    -- verificar se retornou critica
    IF  vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF; 
    
    
    -- Se o DEBUG estiver habilitado
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
                                    pr_tpproduto             => 3, --> Desconto de títulos
                                    pr_idacionamento         => vr_idaciona,
                                    pr_dscritic              => vr_dscritic);
      -- Sem tratamento de exceção para DEBUG                    
      --IF TRIM(vr_dscritic) IS NOT NULL THEN
      --  RAISE vr_exc_erro;
      --END IF;
    END IF;       
    
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar alteracao da proposta de Analise de Credito: '||SQLERRM;
  END pc_alterar_proposta_est;
  
 -- Rotina responsavel em enviar dos dados para a esteira
  PROCEDURE pc_enviar_esteira (pr_cdcooper    IN crapcop.cdcooper%type  --> Codigo da cooperativa
                              ,pr_cdagenci    IN crapage.cdagenci%type  --> Codigo da agencia                                          
                              ,pr_cdoperad    IN crapope.cdoperad%type  --> codigo do operador
                              ,pr_cdorigem    IN integer                --> Origem da operacao
                              ,pr_nrdconta    IN craplim.nrdconta%type  --> Numero da conta do cooperado
                              ,pr_nrctrlim    IN craplim.nrctrlim%type  --> Numero da proposta de emprestimo
                              ,pr_dtmvtolt    IN crapdat.dtmvtolt%type  --> Data do movimento                                      
                              ,pr_comprecu    IN varchar2               --> Complemento do recuros da URI
                              ,pr_dsmetodo    IN varchar2               --> Descricao do metodo
                              ,pr_conteudo    IN clob                   --> Conteudo no Json para comunicacao
                              ,pr_dsoperacao  IN varchar2               --> Operacao realizada
                              ,pr_tpenvest    IN VARCHAR2 DEFAULT null  --> Tipo de envio, I-Inclusao C - Consultar(Get)
                              ,pr_dsprotocolo OUT varchar2              --> Protocolo retornado na requisição
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
    
    -- Carregar parametros para a comunicacao com a esteira
    pc_carrega_param_ibra(pr_cdcooper     => pr_cdcooper
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
    
    -- Atribuir valores necessarios para comunicacao
    vr_request.service_uri := vr_host_esteira;
    vr_request.api_route := vr_recurso_este||pr_comprecu;
    vr_request.method    := pr_dsmetodo;
    vr_request.timeout   := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_IBRA');
    
    vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
    vr_request.headers('Authorization') := vr_autori_este;
    
    -- Se houver ApplicationKey
    IF vr_chave_aplica IS NOT NULL THEN 
      vr_request.headers('ApplicationKey') := vr_chave_aplica;
    END IF;
    
    -- Para envio do Motor
    IF pr_tpenvest = 'M' THEN
      -- Incluiremos o Reply-To para devolução da Análise
      vr_request.headers('Reply-To') := gene0001.fn_param_sistema('CRED',pr_cdcooper,'URI_WEBSRV_MOTOR_DEVOLUC');
    END IF;
    
        
    vr_request.content := pr_conteudo;
    
    -- Disparo do REQUEST
    json0001.pc_executa_ws_json(pr_request           => vr_request
                               ,pr_response          => vr_response
                               ,pr_diretorio_log     => vr_dsdirlog
                               ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'-- Este formato é o formato que deve ser passado, conforme alinhado com o Oscar
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
                                  pr_tpacionamento         => 1,  /* 1 - Envio, 2 – Retorno */      
                                  pr_dsoperacao            => pr_dsoperacao,       
                                  pr_dsuriservico          => vr_host_esteira||vr_recurso_este||pr_comprecu,       
                                  pr_dtmvtolt              => pr_dtmvtolt,       
                                  pr_cdstatus_http         => vr_response.status_code,
                                  pr_dsconteudo_requisicao => pr_conteudo,
                                  pr_dsresposta_requisicao => '{"StatusMessage":"'||vr_response.status_message||'"'||CHR(13)||
                                                              ',"Headers":"'||RTRIM(LTRIM(vr_response.headers,'""'),'""')||'"'||CHR(13)||
                                                              ',"Content":'||vr_response.content||'}',
                                  pr_tpproduto             => 3, --> Desconto de títulos
                                  pr_idacionamento         => vr_idacionamento,
                                  pr_dscritic              => vr_dscritic);
                         
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    IF vr_response.status_code NOT BETWEEN 200 AND 299 THEN
      --> Definir mensagem de critica
      CASE 
        WHEN pr_dsmetodo = 'POST' THEN
          vr_dscritic_aux := 'Nao foi possivel enviar proposta para Análise de Credito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu IS NULL THEN   
          vr_dscritic_aux := 'Nao foi possivel reenviar a proposta para Análise de Crédito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/numeroProposta' THEN   
          vr_dscritic_aux := 'Nao foi possivel alterar numero da proposta da Análise de Crédito.';
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/cancelar' THEN   
          vr_dscritic_aux := 'Nao foi possivel excluir a proposta da Análise de Crédito.';   
        WHEN pr_dsmetodo = 'PUT' AND pr_comprecu = '/efetivar' THEN   
          vr_dscritic_aux := 'Nao foi possivel enviar a efetivacao da proposta da Análise de Crédito.';
        WHEN pr_dsmetodo = 'GET' THEN   
          vr_dscritic_aux := 'Nao foi possivel solicitar o retorno da Análise Automática de Crédito.';
        ELSE
          vr_dscritic_aux := 'Nao foi possivel enviar informacoes para Análise de Crédito.';  
        END CASE;

      IF vr_response.status_code = 400 THEN
        pr_dscritic := este0001.fn_retorna_critica('{"Content":'||vr_response.content||'}');
        
        IF pr_dscritic IS NOT NULL THEN
          -- Tratar mensagem específica de Fluxo Atacado:
          -- "Nao sera possivel enviar a proposta para analise. Classificacao de risco e endividamento fora dos parametros da cooperativa"
          IF pr_dscritic != 'Nao sera possivel enviar a proposta para analise. Classificacao de risco e endividamento fora dos parametros da cooperativa' THEN 
            -- Mensagens diferentes dela terão o prefixo, somente ela não terá
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
           -- Transformar os Headers em uma lista (\n é o separador)
           vr_tab_split := gene0002.fn_quebra_string(vr_response.headers,'\n');
           vr_idx_split  := vr_tab_split.first;
           -- Iterar sobre todos os headers até encontrar o protocolo
           while vr_idx_split is not null and pr_dsprotocolo is null loop
                 -- Testar se é o Location
                 if  lower(vr_tab_split(vr_idx_split)) like 'location%' then
                     -- Extrair o final do atributo, ou seja, o conteúdo após a ultima barra
                     pr_dsprotocolo := substr(vr_tab_split(vr_idx_split),instr(vr_tab_split(vr_idx_split),'/',-1)+1);
                 end if;        
                 -- Buscar proximo header        
                 vr_idx_split := vr_tab_split.next(vr_idx_split);    
           end   loop;
        
           --  Se conseguiu encontrar Protocolo
           if  pr_dsprotocolo is not null then 
               -- Atualizar acionamento                                                                                                                                                             
               update tbgen_webservice_aciona
               set    dsprotocolo = pr_dsprotocolo
               where  idacionamento = vr_idacionamento;
           else    
               -- Gerar erro 
               vr_dscritic := 'Nao foi possivel retornar Protocolo da Análise Automática de Crédito!';
               raise vr_exc_erro;                                                                                                                                     
           end if;
        exception
           when others then   
                vr_dscritic := 'Nao foi possivel retornar Protocolo de Análise Automática de Crédito!';
                raise vr_exc_erro;
        end;  
    end if;
            
  EXCEPTION
    WHEN vr_exc_erro THEN      
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel enviar proposta para Análise de Crédito: '||SQLERRM;  
  END pc_enviar_esteira;
  
  -- Rotina para solicitar analises não respondidas via POST ou solicitar a proposta enviada
  PROCEDURE pc_solicita_retorno_analise(pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_nrdconta IN craplim.nrdconta%TYPE
                                       ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                                       ,pr_tpctrlim in craplim.tpctrlim%type
                                       ,pr_dsprotoc IN craplim.dsprotoc%TYPE) IS
        /* .........................................................................
    
    Programa : pc_solicita_retorno_analise
    Sistema  : 
    Sigla    : CRED
    Autor    : Paulo Penteado (GFT) 
    Data     : Fevereiro/2018                    Ultima atualizacao: 17/02/2018
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Tem como objetivo solicitar o retorno da analise no Motor
    Alteração : 
        
  ..........................................................................*/

  
  -- Tratamento de exceções
  vr_exc_erro EXCEPTION; 
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(10);
      
  -- Variáveis auxiliares
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
      
  -- Objeto json da proposta
  vr_obj_proposta json := json();
  vr_obj_retorno json := json();
  vr_obj_indicadores json := json();
  vr_request  json0001.typ_http_request;
  vr_response json0001.typ_http_response;
      
       -- Cursores
       rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
  -- Cooperativas com análise automática obrigatória
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE cdcooper = NVL(pr_cdcooper,cdcooper)
       AND flgativo = 1
       AND GENE0001.FN_PARAM_SISTEMA('CRED',cdcooper,'ANALISE_OBRIG_MOTOR_DESC') = 1;
    
    -- Proposta sem retorno
    CURSOR cr_craplim is
    select lim.cdcooper
          ,lim.nrdconta
          ,lim.nrctrlim
          ,lim.dsprotoc
          ,lim.dtenvest
          ,lim.hrenvest
          ,lim.insitest
          ,lim.cdagenci
          ,lim.insitapr
          ,lim.dtenvmot
          ,lim.hrenvmot
          ,lim.tpctrlim
          ,lim.rowid
    from   craplim lim
    WHERE  lim.cdcooper = pr_cdcooper
    AND    lim.nrdconta = pr_nrdconta
    AND    lim.nrctrlim = pr_nrctrlim
    and    lim.tpctrlim = pr_tpctrlim
    AND    lim.dsprotoc = pr_dsprotoc
    AND    lim.insitest in (1,2);-- Enviadas para Analise Automática ou Manual

    -- Variaveis para DEBUG
    vr_flgdebug VARCHAR2(100);
    vr_idaciona tbgen_webservice_aciona.idacionamento%TYPE;
              
      BEGIN
            -- Buscar todas as Coops com obrigatoriedade de Análise Automática    
  FOR rw_crapcop IN cr_crapcop LOOP
      
    -- Buscar o tempo máximo de espera em segundos pela analise do motor            
              vr_qtsegund := gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'TIME_RESP_MOTOR_DESC');
    
      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_dscritic:= gene0001.fn_busca_critica(1);
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;        
      
      -- Desde que não estejamos com processo em execução ou o dia util
      IF rw_crapdat.inproces = 1 /*AND trunc(SYSDATE) = rw_crapdat.dtmvtolt */ THEN
        
        -- Buscar DEBUG ativo ou não
        vr_flgdebug := gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'DEBUG_MOTOR_IBRA');

        -- Se o DEBUG estiver habilitado
        IF vr_flgdebug = 'S' THEN
          --> Gravar dados log acionamento
          ESTE0001.pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,         
                                        pr_cdagenci              => 1,          
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
                                        pr_tpproduto             => 3, --> Desconto de títulos
                                        pr_idacionamento         => vr_idaciona,
                                        pr_dscritic              => vr_dscritic);
          -- Sem tratamento de exceção para DEBUG                    
          --IF TRIM(vr_dscritic) IS NOT NULL THEN
          --  RAISE vr_exc_erro;
          --END IF;
        END IF;   
      
        -- Buscar todas as propostas enviadas para o motor e que ainda não tenham retorno
        FOR rw_craplim IN cr_craplim LOOP
          
          -- Capturar o protocolo do contrato para apresentar na crítica caso ocorra algum erro
          vr_dsprotoc := rw_craplim.dsprotoc;
          -- Carregar parametros para a comunicacao com a esteira
          pc_carrega_param_ibra(pr_cdcooper      => rw_craplim.cdcooper
                               ,pr_tpenvest      => 'M'
                               ,pr_host_esteira  => vr_host_esteira     -- Host da esteira
                               ,pr_recurso_este  => vr_recurso_este     -- URI da esteira
                               ,pr_dsdirlog      => vr_dsdirlog         -- Diretorio de log dos arquivos 
                               ,pr_autori_este   => vr_autori_este      -- Authorization 
                               ,pr_chave_aplica  => vr_chave_aplica     -- Chave de acesso
                               ,pr_dscritic      => vr_dscritic    );       
          -- Se retornou crítica
          IF trim(vr_dscritic)  IS NOT NULL THEN
            -- Levantar exceção
            RAISE vr_exc_erro;
          END IF; 
                  
          vr_recurso_este := vr_recurso_este||'/instance/'||rw_craplim.dsprotoc;

          vr_request.service_uri := vr_host_esteira;
          vr_request.api_route   := vr_recurso_este;
          vr_request.method      := 'GET';
          vr_request.timeout     := gene0001.fn_param_sistema('CRED',0,'TIMEOUT_CONEXAO_IBRA');
          
          vr_request.headers('Content-Type') := 'application/json; charset=UTF-8';
          vr_request.headers('Authorization') := vr_autori_este;
                  
          -- Se houver ApplicationKey
          IF vr_chave_aplica IS NOT NULL THEN 
            vr_request.headers('ApplicationKey') := vr_chave_aplica;
          END IF;
          
          -- Se o DEBUG estiver habilitado
          IF vr_flgdebug = 'S' THEN
            --> Gravar dados log acionamento
            ESTE0001.pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,         
                                          pr_cdagenci              => rw_craplim.cdagenci,          
                                          pr_cdoperad              => 'MOTOR',          
                                          pr_cdorigem              => 5,          
                                          pr_nrctrprp              => rw_craplim.nrctrlim,          
                                          pr_nrdconta              => rw_craplim.nrdconta,         
                                          pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                          pr_dsoperacao            => 'ANTES SOLICITA RETORNOS',       
                                          pr_dsuriservico          => NULL,       
                                          pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                                          pr_cdstatus_http         => 0,
                                          pr_dsconteudo_requisicao => null,
                                          pr_dsresposta_requisicao => null,
                                          pr_tpproduto             => 3, --> Desconto de títulos
                                          pr_idacionamento         => vr_idaciona,
                                          pr_dscritic              => vr_dscritic);
            -- Sem tratamento de exceção para DEBUG                    
            --IF TRIM(vr_dscritic) IS NOT NULL THEN
            --  RAISE vr_exc_erro;
            --END IF;
          END IF;   
         
          -- Disparo do REQUEST
          json0001.pc_executa_ws_json(pr_request           => vr_request
                                     ,pr_response          => vr_response
                                     ,pr_diretorio_log     => vr_dsdirlog
                                     ,pr_formato_nmarquivo => 'YYYYMMDDHH24MISSFF3".[api].[method]"'
                                     ,pr_dscritic          => vr_dscritic); 
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF; 
          
          -- Iniciar status
          vr_dssitret := null;--'TEMPO ESGOTADO';
          
          -- HTTP 204 não tem conteúdo
          IF vr_response.status_code != 204 THEN
            -- Extrair dados de retorno
            vr_obj_retorno := json(vr_response.content);
            -- Resultado Analise Regra
            IF vr_obj_retorno.exist('resultadoAnaliseRegra') THEN
              vr_dsresana := ltrim(rtrim(vr_obj_retorno.get('resultadoAnaliseRegra').to_char(),'"'),'"');
              -- Montar a mensagem que será gravada no acionamento
              CASE lower(vr_dsresana)
                WHEN 'aprovar'  THEN vr_dssitret := 'APROVADO AUTOM.';
                WHEN 'reprovar' THEN vr_dssitret := 'REJEITADA AUTOM.';
                WHEN 'derivar'  THEN vr_dssitret := 'ANALISAR MANUAL';
                WHEN 'erro'     THEN vr_dssitret := 'ERRO';
                ELSE vr_dssitret := 'DESCONHECIDA';
              END CASE;         
            END IF;  
          END IF; 

          --> Gravar dados log acionamento
          ESTE0001.pc_grava_acionamento(pr_cdcooper              => rw_craplim.cdcooper,         
                                        pr_cdagenci              => rw_craplim.cdagenci,          
                                        pr_cdoperad              => 'MOTOR',
                                        pr_cdorigem              => 5, /*Ayllos*/
                                        pr_nrctrprp              => rw_craplim.nrctrlim,          
                                        pr_nrdconta              => rw_craplim.nrdconta,          
                                        pr_tpacionamento         => 2,  /* 1 - Envio, 2 – Retorno */      
                                        pr_dsoperacao            => 'RETORNO ANALISE AUTOMATICA DE CREDITO '||vr_dssitret,
                                        pr_dsuriservico          => vr_host_esteira||vr_recurso_este,       
                                        pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                                        pr_cdstatus_http         => vr_response.status_code,
                                        pr_dsconteudo_requisicao => vr_response.content,
                                        pr_dsresposta_requisicao => null,
                                        pr_dsprotocolo           => rw_craplim.dsprotoc,
                                        pr_tpproduto             => 3, --> Desconto de títulos
                                        pr_idacionamento         => vr_idacionamento,
                                        pr_dscritic              => vr_dscritic);
                                       
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          IF vr_response.status_code NOT IN(200,204,429) THEN
            vr_dscritic := 'Não foi possivel consultar informações da Analise de Credito, '||
                           'favor entrar em contato com a equipe responsavel.  '|| 
                           '(Cod:'||vr_response.status_code||')';    
            RAISE vr_exc_erro;
          END IF;
                  
          -- Se recebemos o código diferente de 200 
          IF vr_response.status_code != 200 THEN
            -- Checar expiração
            IF trunc(SYSDATE) > rw_craplim.dtenvmot 
            OR to_number(to_char(SYSDATE, 'sssss')) - rw_craplim.hrenvmot > vr_qtsegund THEN
              BEGIN
                UPDATE craplim lim
                   SET lim.insitlim = 6 --> Não aprovado
                      ,lim.insitest = 3 --> Analise Finalizada
                      ,lim.insitapr = 5 --> Rejeitado Automaticamente
                 WHERE lim.rowid = rw_craplim.rowid;
              EXCEPTION
                WHEN OTHERS THEN 
                  vr_dscritic := 'Erro na expiracao da analise automatica: '||sqlerrm;
                  RAISE vr_exc_erro;      
              END;
                              
              -- Gerar informações do log
              GENE0001.pc_gera_log(pr_cdcooper => rw_craplim.cdcooper
                                  ,pr_cdoperad => 'MOTOR'
                                  ,pr_dscritic => ' '
                                  ,pr_dsorigem => 'AYLLOS'
                                  ,pr_dstransa => 'Expiracao da Analise Automatica'
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => 1 --> FALSE
                                  ,pr_hrtransa => gene0002.fn_busca_time
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => 'ESTEIRA'
                                  ,pr_nrdconta => rw_craplim.nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid);                         
                  
              -- Log de item
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'insitest'
                                       ,pr_dsdadant => rw_craplim.insitest
                                       ,pr_dsdadatu => 3);
              -- Log de item
              GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'insitapr'
                                       ,pr_dsdadant => rw_craplim.insitapr
                                       ,pr_dsdadatu => 5);                                       
            END IF;
            
          ELSE
            
            -- Buscar IndicadoresCliente
            IF vr_obj_retorno.exist('indicadoresGeradosRegra') THEN
              
              vr_obj_indicadores := json(vr_obj_retorno.get('indicadoresGeradosRegra'));
            
              -- Nivel Risco Calculado -- 
              IF vr_obj_indicadores.exist('nivelRisco') THEN
                vr_indrisco := ltrim(rtrim(vr_obj_indicadores.get('nivelRisco').to_char(),'"'),'"');
              END IF;

              -- Rating Calculado -- 
              IF vr_obj_indicadores.exist('notaRating') THEN
                vr_nrnotrat := ltrim(rtrim(vr_obj_indicadores.get('notaRating').to_char(),'"'),'"');
              END IF;
                              
              -- Informação Cadastral -- 
              IF vr_obj_indicadores.exist('informacaoCadastral') THEN
                vr_nrinfcad := ltrim(rtrim(vr_obj_indicadores.get('informacaoCadastral').to_char(),'"'),'"');
              END IF;

              -- Liquidez -- 
              IF vr_obj_indicadores.exist('liquidez') THEN
                vr_nrliquid := ltrim(rtrim(vr_obj_indicadores.get('liquidez').to_char(),'"'),'"');
              END IF;

              -- Garantia -- 
              IF vr_obj_indicadores.exist('garantia') THEN
                vr_nrgarope := ltrim(rtrim(vr_obj_indicadores.get('garantia').to_char(),'"'),'"');
              END IF;
                      
              -- Patrimônio Pessoal Livre -- 
              IF vr_obj_indicadores.exist('patrimonioPessoalLivre') THEN
                vr_nrparlvr := ltrim(rtrim(vr_obj_indicadores.get('patrimonioPessoalLivre').to_char(),'"'),'"');
              END IF;

              -- Percepção Geral Empresa -- 
              IF vr_obj_indicadores.exist('percepcaoGeralEmpresa') THEN
                vr_nrperger := ltrim(rtrim(vr_obj_indicadores.get('percepcaoGeralEmpresa').to_char(),'"'),'"');
              END IF;
              
              -- Score Boa Vista -- 
              IF vr_obj_indicadores.exist('descricaoScoreBVS') THEN
                vr_desscore := ltrim(rtrim(vr_obj_indicadores.get('descricaoScoreBVS').to_char(),'"'),'"');
              END IF;
              
              -- Data Score Boa Vista -- 
              IF vr_obj_indicadores.exist('dataScoreBVS') THEN
                vr_datscore := ltrim(rtrim(vr_obj_indicadores.get('dataScoreBVS').to_char(),'"'),'"');
              END IF;
              
            END IF;  
            
            -- Se o DEBUG estiver habilitado
            IF vr_flgdebug = 'S' THEN
              --> Gravar dados log acionamento
              ESTE0001.pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,         
                                            pr_cdagenci              => rw_craplim.cdagenci,          
                                            pr_cdoperad              => 'MOTOR',          
                                            pr_cdorigem              => 5,          
                                            pr_nrctrprp              => rw_craplim.nrctrlim,          
                                            pr_nrdconta              => rw_craplim.nrdconta,         
                                            pr_tpacionamento         => 0,  /* 0 - DEBUG */      
                                            pr_dsoperacao            => 'ANTES PROCESSAMENTO RETORNO',       
                                            pr_dsuriservico          => NULL,       
                                            pr_dtmvtolt              => rw_crapdat.dtmvtolt,       
                                            pr_cdstatus_http         => 0,
                                            pr_dsconteudo_requisicao => null,
                                            pr_dsresposta_requisicao => null,
                                            pr_tpproduto             => 3, --> Desconto de títulos
                                            pr_idacionamento         => vr_idaciona,
                                            pr_dscritic              => vr_dscritic);
              -- Sem tratamento de exceção para DEBUG                    
              --IF TRIM(vr_dscritic) IS NOT NULL THEN
              --  RAISE vr_exc_erro;
              --END IF;
            END IF; 
                        
            -- Gravar o retorno e proceder com o restante do processo pós análise automática
            WEBS0001.pc_retorno_analise_limdesct(pr_cdorigem => 5 /*Ayllos*/
                                                ,pr_dsprotoc => rw_craplim.dsprotoc
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
          -- Efetuar commit
          COMMIT;
        END LOOP;
        -- Se o DEBUG estiver habilitado
        IF vr_flgdebug = 'S' THEN
          --> Gravar dados log acionamento
          ESTE0001.pc_grava_acionamento(pr_cdcooper              => rw_crapcop.cdcooper,         
                                        pr_cdagenci              => 1,          
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
                                        pr_tpproduto             => 3, --> Desconto de títulos
                                        pr_idacionamento         => vr_idaciona,
                                        pr_dscritic              => vr_dscritic);
          -- Sem tratamento de exceção para DEBUG                    
          --IF TRIM(vr_dscritic) IS NOT NULL THEN
          --  RAISE vr_exc_erro;
          --END IF;
        END IF;
      END IF;  
      -- Gravação para liberação do registro
      COMMIT;
    END LOOP;  
      EXCEPTION
            WHEN vr_exc_erro THEN
                  -- Desfazer alterações
      ROLLBACK;
      -- Gerar log
                  btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 ||' - ESTE0001 --> Erro ao solicitor retorno Protocolo '
                                                 ||vr_dsprotoc||': '||vr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));

            WHEN OTHERS THEN
                  -- Desfazer alterações
      ROLLBACK;
      -- Gerar log
                  btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                 ||' - ESTE0001 --> Erro ao solicitor retorno Protocolo '
                                                 ||vr_dsprotoc||': '||sqlerrm,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                                              pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
      END pc_solicita_retorno_analise;
      

  PROCEDURE pc_enviar_analise_manual(pr_cdcooper  IN craplim.cdcooper%TYPE
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                    ,pr_cdorigem  IN INTEGER
                                    ,pr_nrdconta  IN craplim.nrdconta%TYPE
                                    ,pr_nrctrlim  IN craplim.nrctrlim%TYPE
                                    ,pr_tpctrlim  in craplim.tpctrlim%type
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
   Data     : Março/2018.          Ultima atualizacao: 05/03/2018
        
   Dados referentes ao programa:
        
   Frequencia: Sempre que for chamado
   Objetivo  : Rotina responsavel por gerar a geracao e inclusao da proposta psistemara a esteira 

 ..........................................................................*/

 vr_dtmvtolt DATE;

 vr_cdagenci crapage.cdagenci%type; --> Codigo da agencia
    
 vr_exc_erro EXCEPTION;
 vr_dscritic VARCHAR2(4000);
 vr_cdcritic NUMBER;

 -- Hora de Envio
 vr_hrenvest craplim.hrenvest%TYPE;

 vr_tpenvest varchar2(1);
 vr_obj_proposta json := json();
 vr_obj_proposta_clob clob;
        
 vr_dsprotoc VARCHAR2(1000);
 vr_idaciona tbgen_webservice_aciona.idacionamento%type;
  
  -- Busca do nome do associado
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

   -- Gerar informaçoes no padrao JSON da proposta de emprestimo
   este0004.pc_gera_json_proposta(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdagenci  => vr_cdagenci
                                 ,pr_cdoperad  => pr_cdoperad
                                 ,pr_nrdconta  => pr_nrdconta
                                 ,pr_nrctrlim  => pr_nrctrlim
                                 ,pr_tpctrlim  => pr_tpctrlim
                                 ,pr_nmarquiv  => pr_nmarquiv  --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                 ---- OUT ----
                                 ,pr_proposta  => vr_obj_proposta  --> Retorno do clob em modelo json da proposta de emprestimo
                                 ,pr_cdcritic  => vr_cdcritic
                                 ,pr_dscritic  => vr_dscritic);
          
   IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
     RAISE vr_exc_erro;        
   END IF;  

   -- Se origem veio do Motor/Esteira
   IF pr_cdorigem = 9 THEN 
     -- É uma derivaçao
     vr_tpenvest := 'D';
   ELSE 
     vr_tpenvest := 'I';
   END IF;

   -- Criar o CLOB para converter JSON para CLOB
   dbms_lob.createtemporary(vr_obj_proposta_clob, TRUE, dbms_lob.CALL);
   dbms_lob.open(vr_obj_proposta_clob, dbms_lob.lob_readwrite);
   json.to_clob(vr_obj_proposta,vr_obj_proposta_clob);  
          
   -- Se o DEBUG estiver habilitado
   IF vr_flgdebug = 'S' THEN
     -- Gravar dados log acionamento
     ESTE0001.pc_grava_acionamento(pr_cdcooper              => pr_cdcooper,         
                                   pr_cdagenci              => vr_cdagenci,          
                                   pr_cdoperad              => pr_cdoperad,          
                                   pr_cdorigem              => pr_cdorigem,          
                                   pr_nrctrprp              => pr_nrctrlim,          
                                   pr_nrdconta              => pr_nrdconta,          
                                   pr_tpacionamento         => 0,  -- 0 - DEBUG
                                   pr_dsoperacao            => 'ANTES ENVIAR PROPOSTA',       
                                   pr_dsuriservico          => NULL,       
                                   pr_dtmvtolt              => vr_dtmvtolt,       
                                   pr_cdstatus_http         => 0,
                                   pr_dsconteudo_requisicao => vr_obj_proposta_clob,
                                   pr_dsresposta_requisicao => null,
                                   pr_tpproduto             => 3, --> Desconto de títulos
                                   pr_idacionamento         => vr_idaciona,
                                   pr_dscritic              => vr_dscritic);
     -- Sem tratamento de exceçao para DEBUG                    
     --IF TRIM(vr_dscritic) IS NOT NULL THEN
     --  RAISE vr_exc_erro;
     --END IF;
   END IF;  
          
   -- Enviar dados para Esteira
   pc_enviar_esteira (pr_cdcooper    => pr_cdcooper
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
          
   -- Caso tenhamos recebido critica de Proposta jah existente na Esteira
   IF lower(vr_dscritic) LIKE '%proposta%ja existente na esteira%' THEN

     -- Tentaremos enviar alteraçao com reinício de fluxo para a Esteira 
     pc_alterar_proposta_est(pr_cdcooper => pr_cdcooper
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
          
   -- Liberando a memória alocada pro CLOB
   dbms_lob.close(vr_obj_proposta_clob);
   dbms_lob.freetemporary(vr_obj_proposta_clob);    
          
   -- verificar se retornou critica
   IF vr_dscritic IS NOT NULL THEN
     RAISE vr_exc_erro;
   END IF; 
          
   vr_hrenvest := to_char(SYSDATE,'sssss');
          
   -- Atualizar proposta
   begin
      update craplim lim
      set    insitlim = 1
            ,insitest = 2 --  2 – Enviada para Analise Manual
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
           vr_dscritic := 'Nao foi possivel atualizar proposta apos envio para Análise de Crédito: '||sqlerrm;
           raise vr_exc_erro;
   end;
          
   pr_dsmensag := 'Proposta Enviada para Analise Manual de Credito.';
          
   -- Efetuar gravaçao
   COMMIT;
        
   EXCEPTION
     WHEN vr_exc_erro THEN
          -- Se possui código de crítica e não foi informado a descrição
          IF  vr_cdcritic <> 0 and TRIM(vr_dscritic) IS NULL THEN
              -- Busca descrição da crítica
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
                
          -- Atribui exceção para os parametros de crítica
          pr_cdcritic := nvl(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
          pr_des_erro := 'NOK';

          ROLLBACK;
                
     WHEN OTHERS THEN
          -- Atribui exceção para os parametros de crítica
          pr_cdcritic := nvl(vr_cdcritic,0);
          pr_dscritic := 'Erro nao tratado na ESTE0003.pc_enviar_analise_manual: ' || SQLERRM;
          pr_des_erro := 'NOK';

          ROLLBACK;
   END pc_enviar_analise_manual;
END ESTE0003;
/
