CREATE OR REPLACE PROCEDURE CECRED.pc_crps718(pr_cdcooper  IN craptab.cdcooper%type,
                                              pr_nrdconta  IN crapcob.nrdconta%TYPE,                                              
                                              pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                              pr_dscritic OUT VARCHAR2) AS

  /******************************************************************************
    Programa: pc_crps718 
    Sistema : Cobranca - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Rafael Cechet
    Data    : abril/2017.                     Ultima atualizacao: 28/07/2017
 
    Dados referentes ao programa:
 
    Frequencia: Diario.
    Objetivo  : Buscar confirmacao de registros e intrucoes
                comandadas dos titulos na CIP.
    
    Observacoes: Horario de execucao: todos os dias, a cada 5 minutos.
                                      
    Alteracoes: 12/07/2017 - Permitir que o programa rode em todas as cooperativas
                             diariamente, inclusive finais de semana. (Rafael)        
                             
                20/07/2017 - Movido procedures da package DDDA0001 para o pc_crps718
                             em função dos erros com o dblink JDNPCBISQL (Rafael).
                             
                28/07/2017 - Gerar log de erro no log do boleto (Rafael)
                           - Ajustado ordenação na busca do processamento do 
                             boleto DDA nas tabelas da JD. (Rafael)
                             
                31/08/2017 - Criado procedure para buscar o retorno do registro
                             CIP dos titulos da carga por faixa de rollout. (Rafael)
                             
                28/09/2017 - Ajuste para buscar o retorno apenas da operação em pendente
                             utilizando o idopleg, pois estava buscando todos os retornos,
                             assim ocorria de ainda nao ter o retorno da transação e acabava
                             pegando da instrução anterior, assim o nrauttit ficava desposiionado.
                             SD722965 (Odirlei-AMcom)

                21/05/2018 - Incluída validação para identificar se o título já foi processado.
                             Ajuste na gravação do log. Enviar notificação em caso de erro no programa.
                             Aumentar o prazo para busca dos registros de retorno da Cabine JDNPC.
                             (INC0013085 - AJFink)

  ******************************************************************************/
  -- CONSTANTES
  vr_cdprogra     CONSTANT VARCHAR2(10) := 'crps718';     -- Nome do programa

  -- CURSORES 
  -- Buscar as cooperativas para processamento
  -- Quanto a cooperativa do parametro for 3, ira processar todas as coops 
  -- exceto CECRED, quando outra cooperativa for informada, gerar para a propria
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
         , cop.cdbcoctl
         , cop.cdagectl
      FROM crapcop cop
     WHERE cop.cdcooper = 3;  
    
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  -- VARIÁVEIS
  vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;
  vr_iderro    varchar2(1) := 'N';
  vr_cdcritic           NUMBER;
  vr_dscritic           VARCHAR2(1000);

  vr_cdcooper           crapcop.cdcooper%TYPE;
  
  -- EXCEPTIONS
  vr_exc_saida          EXCEPTION;               
  
  PROCEDURE pc_controla_log_batch(pr_cdcooper_in   IN crapcop.cdcooper%TYPE
                                 ,pr_dstiplog      IN VARCHAR2 -- 'I' início; 'F' fim; 'E' erro
                                 ,pr_dscritic      IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 0
                                 ,pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%type DEFAULT 0) IS
    --
    /*procedure que grava log do programa*/
    --
    -- Refeita rotina de log - 10/10/2017 - Ch 758611 
    vr_dscritic_aux VARCHAR2(4000);
    vr_tpocorrencia tbgen_prglog_ocorrencia.tpocorrencia%type;
  BEGIN
    --> Apenas gerar log se for processo batch/job ou erro  
    IF nvl(pr_nrdconta,0) = 0 OR pr_dstiplog = 'E' THEN
      --
      vr_dscritic_aux := pr_dscritic||', cdcooper:'||pr_cdcooper_in||', nrdconta:'||pr_nrdconta;
      IF pr_dstiplog IN ('O', 'I', 'F') THEN
        vr_tpocorrencia := 4; 
      ELSE
        vr_tpocorrencia := 2;       
      END IF;
      --> Controlar geração de log de execução dos jobs 
      CECRED.pc_log_programa(pr_dstiplog      => NVL(pr_dstiplog,'E')
                            ,pr_cdprograma    => vr_cdprogra
                            ,pr_cdcooper      => pr_cdcooper_in
                            ,pr_tpexecucao    => 2 --job
                            ,pr_tpocorrencia  => vr_tpocorrencia
                            ,pr_cdcriticidade => pr_cdcriticidade
                            ,pr_cdmensagem    => pr_cdmensagem
                            ,pr_dsmensagem    => vr_dscritic_aux
                            ,pr_idprglog      => vr_idprglog
                            ,pr_nmarqlog      => NULL);
      --
    END IF;
    --
  EXCEPTION  
    WHEN OTHERS THEN  
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper_in);   
  END pc_controla_log_batch;
  
  PROCEDURE pc_trata_retorno_erro ( pr_idtabcob       IN  ROWID                   --> rowid crapcob 
                                   ,pr_tpdopera       IN  VARCHAR2                --> Tipo de operacao
                                   ,pr_idtitleg       IN  crapcob.idtitleg%TYPE   --> Identificador do titulo no legado
                                   ,pr_idopeleg       IN  crapcob.idopeleg%TYPE   --> Identificador da operadao do legado
                                   ,pr_iddopeJD       IN  VARCHAR2) IS            --> Identificador da operadao da JD                                   
                                   
  
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_trata_retorno_erro  
    --  Sistema  : DDDA
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Janeiro/2017.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para tratar as criticas no retorno da CIP-NPC
    --
    -- Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------
  
    ---------->>> CURSORES <<<-----------
    --> Listar criticas da operacao
    CURSOR cr_optiterr IS
    SELECT err."CdErro"   codderro,
           err."NmColuna" nmcoluna,
           NVL(dsc1."DESCRICAO",dsc2."DSC_ERRO") dsdoerro
      FROM TBJDNPCDSTLEG_JD2LG_OpTit_ERR@Jdnpcbisql err,
           TBJDMSG_ERROGEN@Jdnpcsql dsc1,
           TBJDNPC_ERRO@Jdnpcsql    dsc2
     WHERE err."CdLeg" = 'LEG'
       AND err."IdTituloLeg" = pr_idtitleg
       AND err."IdOpLeg"     = pr_idopeleg
       AND err."IdOpJD"      = pr_iddopejd
       AND err."CdErro"      = dsc1."CODERRO"(+)
       AND err."CdErro"      = dsc2."CD_ERRO"(+); 
    
     ---------->>> VARIAVEIS <<<-----------   
    vr_dscritic   VARCHAR2(2000);   
    vr_des_erro   VARCHAR2(100);    
       
  BEGIN
    
    CASE pr_tpdopera
      WHEN 'I' THEN
        vr_dscritic := 'Inclusao';
      WHEN 'A' THEN
        vr_dscritic := 'Alteracao';
      WHEN 'B' THEN
        vr_dscritic := 'Baixa';    
      ELSE        
        vr_dscritic := 'Operacao';
    END CASE;    
  
    vr_dscritic := vr_dscritic || ' Rejeitada na CIP';
                   
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => pr_idtabcob
                                 ,pr_cdoperad => '1'
                                 ,pr_dtmvtolt => SYSDATE
                                 ,pr_dsmensag => vr_dscritic
                                 ,pr_des_erro => vr_des_erro
                                 ,pr_dscritic => vr_dscritic);
                   
    
    --> Listar criticas por campo
    FOR rw_optiterr IN cr_optiterr LOOP
      vr_dscritic := rw_optiterr.nmcoluna||': '|| 
                     rw_optiterr.codderro||' - '||rw_optiterr.dsdoerro;    
                     
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => pr_idtabcob
                                   ,pr_cdoperad => '1'
                                   ,pr_dtmvtolt => SYSDATE
                                   ,pr_dsmensag => trim(substr(vr_dscritic,1,350))
                                   ,pr_des_erro => vr_des_erro
                                   ,pr_dscritic => vr_dscritic);
                     
    END LOOP;         
  
  END pc_trata_retorno_erro;  
  
  --> Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
  PROCEDURE pc_ret_inclusao_tit_npc ( pr_idtitleg       IN  crapcob.idtitleg%TYPE --> Identificador do titulo no legado
                                     ,pr_idopeleg       IN  crapcob.idopeleg%TYPE --> Identificador da operadao do legado
                                     ,pr_iddopeJD       IN  VARCHAR2              --> Identificador da operadao da JD
                                     ,pr_cdstiope       IN  VARCHAR2              --> Situacao do envio da informaçcao
                                     ,pr_idtitnpc       IN  crapcob.nrdident%TYPE --> Identificador do titulo na CIP-NPC
                                     ,pr_nratutit       IN  crapcob.nratutit%TYPE --> Identificador do titulo alteracao na CIP-NPC
                                     ,pr_cdcritic      OUT crapcri.cdcritic%type --Codigo de Erro
                                     ,pr_dscritic      OUT VARCHAR2) IS          --Descricao de Erro
  
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_ret_inclusao_tit_npc  
    --  Sistema  : DDDA
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Janeiro/2017.                   Ultima atualizacao: 23/01/2018
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
    --
    -- Alteracoes: 12/07/2017 - Atualizar motivo A4 na confirmação do boleto na crapret (Rafael)
    --
    --             23/01/2018 - Atualizar motivo PC se o pagador nao for DDA (Rafael)    
    ---------------------------------------------------------------------------------------------------------------
  
    ---------->>> CURSORES <<<-----------
    --> buscar boleto
    CURSOR cr_crapcob IS
      SELECT  cob.rowid rowidcob
             ,cob.cdcooper       
             ,cob.nrdconta
             ,cob.nrcnvcob
             ,cob.nrdocmto            
             ,cob.inregcip            
             ,decode(cob.cdtpinsc,1,'F','J') tppessoa
             ,cob.nrinssac            
        FROM crapcob cob
       WHERE cob.idtitleg = pr_idtitleg;
    rw_crapcob cr_crapcob%ROWTYPE;   
       
    ---------->>> VARIAVEIS <<<-----------   
    vr_cdcritic   INTEGER;
    vr_dscritic   VARCHAR2(2000);
    vr_des_erro   VARCHAR2(200);
    vr_exc_erro   EXCEPTION;
    
    vr_insitpro   crapcob.insitpro%TYPE;
    vr_inenvcip   crapcob.inenvcip%TYPE;
    vr_flgcbdda   crapcob.flgcbdda%TYPE;
    vr_dhenvcip   crapcob.dhenvcip%TYPE;
    vr_dsmensag   crapcol.dslogtit%TYPE;
    vr_inregcip   crapcob.inregcip%TYPE;
    vr_cdmotivo   VARCHAR2(2);
    vr_flgsacad   INTEGER := 0;    
    
  BEGIN
  
    --> CDSTIOPE
    --> PJ - Processada no JDNPC
    --> EJ – Erro JDNPC
    --> RC – Operação registrada na CIP-NPC
    --> EC – Erro na CIP-NPC
    --> IC – Informação enviada pela CIP-NPC (Apenas para complemento)
    
    OPEN cr_crapcob;
    FETCH cr_crapcob INTO rw_crapcob;
    IF cr_crapcob%NOTFOUND THEN
      vr_dscritic := 'Boleto não encontrado';
      CLOSE cr_crapcob;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcob;
    
    vr_insitpro := NULL;
    vr_inenvcip := NULL;
    vr_flgcbdda := NULL;
    vr_dhenvcip := NULL;
    vr_dsmensag := NULL;
    vr_inregcip := NULL;
    
    IF pr_cdstiope = 'PJ' THEN
      vr_insitpro := 2; --> 2-RecebidoJD
    ELSIF pr_cdstiope = 'RC' THEN --Registrado com sucesso
      vr_insitpro := 3; --> 3-RC registro CIP
      vr_inenvcip := 3; -- confirmado
      vr_flgcbdda := 1;
      vr_dhenvcip := SYSDATE;
      vr_dsmensag := 'Boleto registrado no Sistema Financeiro Nacional';
    ELSE
      vr_insitpro := 0; --> Sacado comun
      vr_inenvcip := 4; -- Rejeitadp
      vr_flgcbdda := 0;
      vr_dhenvcip := NULL;
      vr_dsmensag := 'Falha ao registrar boleto no Sistema Financeiro Nacional';
      vr_inregcip := 0; -- sem registro na CIP;
    END IF;
    
    --> Atualizar informações do boleto
    BEGIN
      UPDATE crapcob cob
         SET cob.insitpro =  nvl(vr_insitpro,cob.insitpro)
           , cob.flgcbdda =  nvl(vr_flgcbdda,cob.flgcbdda)
           , cob.inenvcip =  nvl(vr_inenvcip,cob.inenvcip)
           , cob.dhenvcip =  nvl(vr_dhenvcip,cob.dhenvcip)
           , cob.inregcip =  nvl(vr_inregcip,cob.inregcip)
           , cob.nrdident =  nvl(pr_idtitnpc,cob.nrdident)           
           , cob.nratutit =  nvl(pr_nratutit,cob.nratutit)
       WHERE cob.rowid    = rw_crapcob.rowidcob;
       
       IF pr_cdstiope = 'RC' THEN
         
         -- verificar se o pagador eh DDA         
         DDDA0001.pc_verifica_sacado_DDA(pr_tppessoa => rw_crapcob.tppessoa
                                        ,pr_nrcpfcgc => rw_crapcob.nrinssac
                                        ,pr_flgsacad => vr_flgsacad
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                                        
         IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro;
         END IF;                                                             

         IF vr_flgsacad = 1 THEN
           -- A4 = Pagador DDA
           vr_cdmotivo := 'A4';
         ELSE
           -- PC = Boleto PCR (ou NPC)
           vr_cdmotivo := 'PC';
         END IF;
                            
         UPDATE crapret ret
            SET cdmotivo = vr_cdmotivo || cdmotivo
          WHERE ret.cdcooper = rw_crapcob.cdcooper
            AND ret.nrdconta = rw_crapcob.nrdconta
            AND ret.nrcnvcob = rw_crapcob.nrcnvcob
            AND ret.nrdocmto = rw_crapcob.nrdocmto
            AND ret.cdocorre = 2; -- 2=Confirmacao de registro de boleto
            
        END IF;
        
    EXCEPTION
      WHEN OTHERS THEN
        vr_iderro := 'S';--ocorreu erro no processamento
        vr_dscritic := 'Erro ao atualizar CRAPCOB: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    --> Se conter mensagem deve gerar log
    IF trim(vr_dsmensag) IS NOT NULL THEN        
      -- Cria o log da cobrança
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                   ,pr_cdoperad => '1'
                                   ,pr_dtmvtolt => SYSDATE
                                   ,pr_dsmensag => vr_dsmensag
                                   ,pr_des_erro => vr_des_erro
                                   ,pr_dscritic => vr_dscritic);
            
      -- Se ocorrer erro
      IF vr_des_erro <> 'OK' THEN        
        RAISE vr_exc_erro;
      END IF;
    
    END IF;  
    
    --> Gerar log de rejeicao
    IF pr_cdstiope IN ('EJ','EC') THEN
      pc_trata_retorno_erro ( pr_idtabcob   => rw_crapcob.rowidcob  --> ROWID crapcob
                             ,pr_tpdopera   => 'I'                  --> Tipo de operacao
                             ,pr_idtitleg   => pr_idtitleg          --> Identificador do titulo no legado
                             ,pr_idopeleg   => pr_idopeleg          --> Identificador da operadao do legado
                             ,pr_iddopeJD   => pr_iddopeJD);        --> Identificador da operadao da JD                                         
    END IF;
            
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      vr_iderro := 'S';--ocorreu erro no processamento
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      vr_iderro := 'S';--ocorreu erro no processamento
      pr_dscritic := 'Não foi possivel processar retorno de inclusao: '||SQLERRM;  
  END pc_ret_inclusao_tit_npc;
  
   --> Procedure para processar o retorno de alteração do titulo do NPC-CIP
  PROCEDURE pc_ret_alteracao_tit_npc( pr_idtitleg       IN  crapcob.idtitleg%TYPE --> Identificador do titulo no legado
                                     ,pr_idopeleg       IN  crapcob.idopeleg%TYPE --> Identificador da operadao do legado
                                     ,pr_iddopeJD       IN  VARCHAR2              --> Identificador da operadao da JD
                                     ,pr_cdstiope       IN  VARCHAR2              --> Situacao do envio da informaçcao
                                     ,pr_idtitnpc       IN  crapcob.nrdident%TYPE --> Identificador do titulo na CIP-NPC
                                     ,pr_nratutit       IN  crapcob.nratutit%TYPE --> Identificador do titulo alteracao na CIP-NPC
                                     ,pr_cdcritic      OUT crapcri.cdcritic%type --Codigo de Erro
                                     ,pr_dscritic      OUT VARCHAR2) IS          --Descricao de Erro
  
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_ret_alteracao_tit_npc  
    --  Sistema  : DDDA
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Janeiro/2017.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para processar o retorno de alteracao do titulo do NPC-CIP
    --
    -- Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------
  
    ---------->>> CURSORES <<<-----------
    --> buscar boleto
    CURSOR cr_crapcob IS
      SELECT  cob.rowid rowidcob
             ,cob.cdcooper       
             ,cob.nrdconta
             ,cob.nrcnvcob
             ,cob.nrdocmto            
        FROM crapcob cob
       WHERE cob.idtitleg = pr_idtitleg;
    rw_crapcob cr_crapcob%ROWTYPE;   
       
    ---------->>> VARIAVEIS <<<-----------   
    vr_cdcritic   INTEGER;
    vr_dscritic   VARCHAR2(2000);
    vr_des_erro   VARCHAR2(200);
    vr_exc_erro   EXCEPTION;
    
    vr_dsmensag   crapcol.dslogtit%TYPE;
    
  BEGIN
  
    --> CDSTIOPE
    --> PJ - Processada no JDNPC
    --> EJ – Erro JDNPC
    --> RC – Operação registrada na CIP-NPC
    --> EC – Erro na CIP-NPC
    --> IC – Informação enviada pela CIP-NPC (Apenas para complemento)
    
    OPEN cr_crapcob;
    FETCH cr_crapcob INTO rw_crapcob;
    IF cr_crapcob%NOTFOUND THEN
      vr_dscritic := 'Boleto não encontrado';
      CLOSE cr_crapcob;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcob;
    
    
    IF pr_cdstiope = 'PJ' THEN
      NULL;
    ELSIF pr_cdstiope = 'RC' THEN --Registrado com sucesso      
      vr_dsmensag := 'Alteração de vencimento registrada no Sistema Financeiro Nacional';
      
      --> Atualizar informações do boleto
      BEGIN
        UPDATE crapcob cob
           SET cob.nratutit = nvl(pr_nratutit,cob.nratutit)
              ,cob.ininscip = 2
         WHERE cob.rowid    = rw_crapcob.rowidcob;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPCOB: '||SQLERRM;
          RAISE vr_exc_erro;
      END;            
    ELSIF pr_cdstiope IN ('EJ','EC') THEN
      vr_dsmensag := 'Alteração de Titulo Rejeitado na CIP';      
    END IF;       
        
    --> Se conter mensagem deve gerar log
    IF trim(vr_dsmensag) IS NOT NULL THEN        
      -- Cria o log da cobrança
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                   ,pr_cdoperad => '1'
                                   ,pr_dtmvtolt => SYSDATE
                                   ,pr_dsmensag => vr_dsmensag
                                   ,pr_des_erro => vr_des_erro
                                   ,pr_dscritic => vr_dscritic);
            
      -- Se ocorrer erro
      IF vr_des_erro <> 'OK' THEN        
        RAISE vr_exc_erro;
      END IF;
    
    END IF;  
    
    --> Gerar log de rejeicao
    IF pr_cdstiope IN ('EJ','EC') THEN
      pc_trata_retorno_erro ( pr_idtabcob   => rw_crapcob.rowidcob  --> ROWID crapcob      
                             ,pr_tpdopera   => 'A'                  --> Tipo de operacao
                             ,pr_idtitleg   => pr_idtitleg          --> Identificador do titulo no legado
                             ,pr_idopeleg   => pr_idopeleg          --> Identificador da operadao do legado
                             ,pr_iddopeJD   => pr_iddopeJD);        --> Identificador da operadao da JD                                   
                             
      --> Atualizar informações do boleto
      BEGIN
        UPDATE crapcob cob
           SET cob.nratutit = nvl(pr_nratutit,cob.nratutit)
              ,cob.ininscip = 2
         WHERE cob.rowid    = rw_crapcob.rowidcob;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPCOB: '||SQLERRM;
          RAISE vr_exc_erro;
      END;                                         
      
    END IF;
            
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      vr_iderro := 'S';--ocorreu erro no processamento
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      vr_iderro := 'S';--ocorreu erro no processamento
      pr_dscritic := 'Não foi possivel processar retorno de alteracao: '||SQLERRM;  
  END pc_ret_alteracao_tit_npc;
  
   --> Procedure para processar o retorno de baixa do titulo do NPC-CIP
  PROCEDURE pc_ret_baixa_tit_npc( pr_idtitleg       IN  crapcob.idtitleg%TYPE --> Identificador do titulo no legado
                                 ,pr_idopeleg       IN  crapcob.idopeleg%TYPE --> Identificador da operadao do legado
                                 ,pr_iddopeJD       IN  VARCHAR2              --> Identificador da operadao da JD
                                 ,pr_cdstiope       IN  VARCHAR2              --> Situacao do envio da informaçcao
                                 ,pr_idtitnpc       IN  crapcob.nrdident%TYPE --> Identificador do titulo na CIP-NPC
                                 ,pr_nratutit       IN  crapcob.nratutit%TYPE --> Identificador do titulo alteracao na CIP-NPC
                                 ,pr_cdcritic      OUT crapcri.cdcritic%type --Codigo de Erro
                                 ,pr_dscritic      OUT VARCHAR2) IS          --Descricao de Erro
  
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_ret_baixa_tit_npc  
    --  Sistema  : DDDA
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Janeiro/2017.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para processar o retorno de baixa do titulo do NPC-CIP
    --
    -- Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------
  
    ---------->>> CURSORES <<<-----------
    --> buscar boleto
    CURSOR cr_crapcob IS
      SELECT  cob.rowid rowidcob
             ,cob.cdcooper       
             ,cob.nrdconta
             ,cob.nrcnvcob
             ,cob.nrdocmto            
        FROM crapcob cob
       WHERE cob.idtitleg = pr_idtitleg;
    rw_crapcob cr_crapcob%ROWTYPE;   
       
    ---------->>> VARIAVEIS <<<-----------   
    vr_cdcritic   INTEGER;
    vr_dscritic   VARCHAR2(2000);
    vr_des_erro   VARCHAR2(200);
    vr_exc_erro   EXCEPTION;
    
    vr_dsmensag   crapcol.dslogtit%TYPE;
    
  BEGIN
  
    --> CDSTIOPE
    --> PJ - Processada no JDNPC
    --> EJ – Erro JDNPC
    --> RC – Operação registrada na CIP-NPC
    --> EC – Erro na CIP-NPC
    --> IC – Informação enviada pela CIP-NPC (Apenas para complemento)
    
    OPEN cr_crapcob;
    FETCH cr_crapcob INTO rw_crapcob;
    IF cr_crapcob%NOTFOUND THEN
      vr_dscritic := 'Boleto não encontrado';
      CLOSE cr_crapcob;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcob;    
    
    IF pr_cdstiope = 'PJ' THEN
      NULL;
    ELSIF pr_cdstiope = 'RC' THEN --Registrado com sucesso 
      
      --> Atualizar informações do boleto
      BEGIN
        UPDATE crapcob cob
           SET cob.nratutit = nvl(pr_nratutit,cob.nratutit)
              ,cob.ininscip = 2
         WHERE cob.rowid    = rw_crapcob.rowidcob;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPCOB: '||SQLERRM;
          RAISE vr_exc_erro;
      END;            
         
      vr_dsmensag := 'Boleto Baixado no Sistema Financeiro Nacional';
    ELSIF pr_cdstiope IN ('EJ','EC') THEN
      vr_dsmensag := 'Baixa de Titulo Rejeitado na CIP';      
      
      --> Atualizar informações do boleto
      BEGIN
        UPDATE crapcob cob
           SET cob.ininscip = 2
         WHERE cob.rowid    = rw_crapcob.rowidcob;
         
         --dbms_output.put_line(rw_crapcob.rowidcob);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPCOB: '||SQLERRM;
          RAISE vr_exc_erro;
      END;            
      
    END IF;       
        
    --> Se conter mensagem deve gerar log
    IF trim(vr_dsmensag) IS NOT NULL THEN        
      -- Cria o log da cobrança
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                   ,pr_cdoperad => '1'
                                   ,pr_dtmvtolt => SYSDATE
                                   ,pr_dsmensag => vr_dsmensag
                                   ,pr_des_erro => vr_des_erro
                                   ,pr_dscritic => vr_dscritic);
            
      -- Se ocorrer erro
      IF vr_des_erro <> 'OK' THEN        
        RAISE vr_exc_erro;
      END IF;
    
    END IF;  
    
    --> Gerar log de rejeicao
    IF pr_cdstiope IN ('EJ','EC') THEN
      pc_trata_retorno_erro ( pr_idtabcob   => rw_crapcob.rowidcob  --> ROWID crapcob      
                             ,pr_tpdopera   => 'B'                  --> Tipo de operacao
                             ,pr_idtitleg   => pr_idtitleg          --> Identificador do titulo no legado
                             ,pr_idopeleg   => pr_idopeleg          --> Identificador da operadao do legado
                             ,pr_iddopeJD   => pr_iddopeJD);        --> Identificador da operadao da JD                                   
      
    END IF;
            
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      vr_iderro := 'S';--ocorreu erro no processamento
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      vr_iderro := 'S';--ocorreu erro no processamento
      pr_dscritic := 'Não foi possivel processar retorno de baixa: '||SQLERRM;  
  END pc_ret_baixa_tit_npc;
  
  
  /* Procedure para Executar retorno operacao Titulos NPC */
  PROCEDURE pc_retorno_operacao_tit_NPC(pr_cdcritic        OUT crapcri.cdcritic%type --Codigo de Erro
                                       ,pr_dscritic        OUT VARCHAR2) IS --Descricao de Erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_retorno_operacao_tit_NPC    Antigo: procedures/b1wgen0087.p/Retorno-Operacao-Titulos-DDA
    --  Sistema  : PProcedure para Executar retorno operacao Titulos NPC
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Janeiro/2017.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para Executar retorno operacao Titulos NPC
    --
    -- Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------
    --> Buscar retornos 
    CURSOR cr_retnpc (pr_cdlegado IN tbjdnpcdstleg_jd2lg_optit."CdLeg"@jdnpcbisql%type
                     ,pr_nrispbif IN tbjdnpcdstleg_jd2lg_optit."ISPBAdministrado"@jdnpcbisql%TYPE
                     ,pr_idtitleg IN tbjdnpcdstleg_jd2lg_optit."IdTituloLeg"@jdnpcbisql%TYPE
                     ,pr_idopeleg IN tbjdnpcdstleg_jd2lg_optit."IdOpLeg"@jdnpcbisql%TYPE) IS
      SELECT tit."ISPBAdministrado" AS nrispbif
            ,tit."TpOpJD"           AS tpoperac
            ,tit."IdOpJD"           AS idoperac
            ,tit."DtHrOpJD"         AS dhoperac
            ,tit."SitOpJD"          AS cdstiope
            ,tit."IdTituloLeg"      AS idtitleg
            ,tit."NumIdentcTit"     AS idtitnpc
            ,tit."IdOpLeg"          AS idopeleg
            ,tit."IdOpJD"           AS iddopeJD
            ,tit."NumRefAtlCadTit"  AS nratutit
        FROM tbjdnpcdstleg_jd2lg_optit@jdnpcbisql tit
       WHERE tit."CdLeg"            = pr_cdlegado
         AND tit."ISPBAdministrado" = pr_nrispbif
         AND tit."IdTituloLeg"      = pr_idtitleg
         AND tit."IdOpLeg"          = pr_idopeleg
         AND tit."TpOpJD"           IN ('RI','RA','RB')
       ORDER BY tit."DtHrOpJD" ASC;
    rw_retnpc cr_retnpc%ROWTYPE;
      
    CURSOR cr_crapcop IS
      SELECT MIN(dat.dtmvtoan) dtmvtoan,
             MAX(dat.dtmvtolt) dtmvtolt
        FROM crapcop cop,
             crapdat dat
       WHERE cop.cdcooper > 0
         AND cop.cdcooper <> 3
         AND cop.flgativo = 1
         AND dat.cdcooper = cop.cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;    
      
    cursor cr_titulo(pr_crapcob_rowid in rowid) is
      select cob.idtitleg
            ,cob.inenvcip
            ,cob.ininscip
            ,cob.idopeleg
            ,ret.cdocorre
      from crapcob cob
          ,crapret ret
          ,crapcco cco
      where cob.idtitleg > 0
        and ((cob.inenvcip = 2 and cob.dtmvtolt between (rw_crapcop.dtmvtoan-2) and rw_crapcop.dtmvtolt) or
             (cob.ininscip = 1 and trunc(cob.dhinscip) between (rw_crapcop.dtmvtoan-2) and rw_crapcop.dtmvtolt))
        and cob.nrdocmto = ret.nrdocmto
        and cob.nrdconta = ret.nrdconta
        and cob.nrcnvcob = ret.nrcnvcob
        and cob.nrdctabb = cco.nrdctabb
        and cob.cdbandoc = cco.cddbanco
        and cob.cdcooper = ret.cdcooper
        --
        and ret.dtocorre between (rw_crapcop.dtmvtoan-2) and rw_crapcop.dtmvtolt
        and ret.nrcnvcob = cco.nrconven
        and ret.cdcooper = cco.cdcooper
        --
        and cco.cddbanco = 85
        and cco.cdcooper >= 1
        and cob.rowid = pr_crapcob_rowid;
    rw_titulo cr_titulo%rowtype;

    --Variaveis Locais
    vr_idregprc  number(1);
    vr_crapcob_rowid rowid;
    vr_execcomm  number(1);
    --Variaveis Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis Excecao
    vr_exc_erro EXCEPTION;    
          
  BEGIN
    
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    CLOSE cr_crapcop;      
          
      FOR rw IN (
                  select cob.rowid crapcob_rowid
                  from crapcob cob
                      ,crapret ret
                      ,crapcco cco
                  where cob.idtitleg > 0
                    and ((cob.inenvcip = 2 and cob.dtmvtolt between (rw_crapcop.dtmvtoan-2) and rw_crapcop.dtmvtolt) or
                         (cob.ininscip = 1 and trunc(cob.dhinscip) between (rw_crapcop.dtmvtoan-2) and rw_crapcop.dtmvtolt))
                    and cob.nrdocmto = ret.nrdocmto
                    and cob.nrdconta = ret.nrdconta
                    and cob.nrcnvcob = ret.nrcnvcob
                    and cob.nrdctabb = cco.nrdctabb
                    and cob.cdbandoc = cco.cddbanco
                    and cob.cdcooper = ret.cdcooper
                    --
                    and ret.dtocorre between (rw_crapcop.dtmvtoan-2) and rw_crapcop.dtmvtolt
                    and ret.nrcnvcob = cco.nrconven
                    and ret.cdcooper = cco.cdcooper
                    --
                    and cco.cddbanco = 85
                    and cco.cdcooper >= 1
                )
      LOOP
        --
        vr_idregprc := 0; --marcar o registro como não processado
        vr_execcomm := 0; --marcar o registro como não deve haver commit;
        vr_crapcob_rowid := rw.crapcob_rowid;
        --
        open cr_titulo(pr_crapcob_rowid => vr_crapcob_rowid);
        fetch cr_titulo into rw_titulo;
        --se o cursor não retornou nada é porque o registro já foi processado por outro job
        if cr_titulo%notfound then
          --
          vr_idregprc := 1; --marcar o registro como processado
          --
        end if;
        close cr_titulo;
        --
        if vr_idregprc = 0 then
        --> buscar retornos disponibilizados
        FOR rw_retnpc IN cr_retnpc(pr_cdlegado => 'LEG'
                                  ,pr_nrispbif => '5463212'
                                    ,pr_idtitleg => rw_titulo.idtitleg
                                    ,pr_idopeleg => rw_titulo.idopeleg) LOOP

            vr_execcomm := 1; --marcar o registro como não haver commit;

            IF rw_retnpc.tpoperac = 'RI' AND rw_titulo.inenvcip = 2 THEN --> Retorno Inclusao          
              --> Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
              pc_ret_inclusao_tit_npc ( pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                       ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                       ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                       ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informaçcao
                                       ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                       ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                       ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                       ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
                                       
              ELSIF rw_retnpc.tpoperac = 'RA' AND rw_titulo.ininscip = 1 THEN --> Retorno Alteração
              pc_ret_alteracao_tit_npc (pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                       ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                       ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                       ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informaçcao
                                       ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                       ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                       ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                       ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
            
              ELSIF rw_retnpc.tpoperac = 'RB' AND rw_titulo.ininscip = 1 THEN --> Retorno Baixa
               pc_ret_baixa_tit_npc ( pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                     ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                     ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                     ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informaçcao
                                     ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                     ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                     ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                     ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
                                     
            ELSIF rw_retnpc.tpoperac = 'CO' THEN --> Cancelamento da Baixa Operacional enviada pelo Banco Recebedor
              --> Acão ainda nao definida, será programada em segunda etapa
              NULL;
            ELSIF rw_retnpc.tpoperac = 'JB' THEN --> Baixa Efetiva feita diretamente no JDNPC(Contingência)
              --> Acão ainda nao definida, será programada em segunda etapa
              NULL;
            ELSIF rw_retnpc.tpoperac = 'DP' THEN --> Baixa por Decurso de Prazo
              --> Acão ainda nao definida, será programada em segunda etapa
              NULL;        
            ELSE
              -- Demais tipos de operacao serão ignoradas
              NULL;
          END IF;    
          
          --> verificar se transacao apresentou erro
          IF nvl(vr_cdcritic,0) > 0 OR
             vr_dscritic IS NOT NULL THEN         
            ROLLBACK;
            
            vr_dscritic := 'Erro ao processar retorno idtitleg: '||rw_retnpc.idtitleg||' -> '||
                           vr_dscritic;
                      
              pc_controla_log_batch(pr_cdcooper_in   => vr_cdcooper
                                   ,pr_dstiplog      => 'E'
                                   ,pr_dscritic      => vr_dscritic
                                   ,pr_cdcriticidade => 1
                                   ,pr_cdmensagem    => 0);
             
          END IF; 
                  
        END LOOP; -- loop retnpc
        
          if vr_execcomm = 1 then
        COMMIT;
          end if;

        end if;
      
      END LOOP; -- loop rw 
      
  EXCEPTION
    
    WHEN vr_exc_erro THEN     
      vr_iderro := 'S';--ocorreu erro no processamento
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN     
    begin
      --
      vr_iderro := 'S';--ocorreu erro no processamento
      pr_cdcritic := vr_cdcritic;
      vr_dscritic := 'pc_retorno_operacao_tit_npc:'
                   ||dbms_utility.format_error_backtrace
            ||' - '||dbms_utility.format_error_stack;
      --
      pc_controla_log_batch(pr_cdcooper_in   => vr_cdcooper
                           ,pr_dstiplog      => 'E'
                           ,pr_dscritic      => vr_dscritic
                           ,pr_cdcriticidade => 1
                           ,pr_cdmensagem    => 0);
      --
      pr_dscritic := vr_dscritic;      
      --
    end;
  
  END pc_retorno_operacao_tit_NPC;  
  
  /* Procedure para Executar retorno da carga por faixa de rollout de Titulos NPC */
  PROCEDURE pc_retorno_carga_tit_NPC(pr_cdcritic        OUT crapcri.cdcritic%type --Codigo de Erro
                                    ,pr_dscritic        OUT VARCHAR2) IS --Descricao de Erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_retorno_carga_tit_NPC    
    --  Sistema  : Procedure para Executar retorno operacao Titulos NPC
    --  Sigla    : CRED
    --  Autor    : Rafael Cechet
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para buscar o retorno da carga por faixa de rollout de titulos NPC
    --
    -- Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------
    --> Buscar retornos 
    CURSOR cr_retnpc (pr_cdlegado IN tbjdnpcdstleg_jd2lg_optit."CdLeg"@jdnpcbisql%type
                     ,pr_nrispbif IN tbjdnpcdstleg_jd2lg_optit."ISPBAdministrado"@jdnpcbisql%TYPE
                     ,pr_idtitleg IN tbjdnpcdstleg_jd2lg_optit."IdTituloLeg"@jdnpcbisql%TYPE
                     ,pr_idopeleg IN tbjdnpcdstleg_jd2lg_optit."IdOpLeg"@jdnpcbisql%TYPE) IS
      SELECT tit."ISPBAdministrado" AS nrispbif
            ,tit."TpOpJD"           AS tpoperac
            ,tit."IdOpJD"           AS idoperac
            ,tit."DtHrOpJD"         AS dhoperac
            ,tit."SitOpJD"          AS cdstiope
            ,tit."IdTituloLeg"      AS idtitleg
            ,tit."NumIdentcTit"     AS idtitnpc
            ,tit."IdOpLeg"          AS idopeleg
            ,tit."IdOpJD"           AS iddopeJD
            ,tit."NumRefAtlCadTit"  AS nratutit
        FROM tbjdnpcdstleg_jd2lg_optit@jdnpcbisql tit
       WHERE tit."CdLeg"            = pr_cdlegado
         AND tit."ISPBAdministrado" = pr_nrispbif
         AND tit."IdTituloLeg"      = pr_idtitleg
         AND tit."IdOpLeg"          = pr_idopeleg
         AND tit."TpOpJD"           IN ('RI','RA','RB')
       ORDER BY tit."DtHrOpJD" ASC;
    rw_retnpc cr_retnpc%ROWTYPE;
      
    cursor cr_titulo(pr_crapcob_rowid in rowid
                    ,pr_vltitulo_cr   in crapcob.vltitulo%type) is
      select cob.idtitleg
            ,cob.inenvcip
            ,cob.ininscip
            ,cob.idopeleg
      from crapcco cco
          ,crapcob cob
      where cco.cddbanco = 85
        and cco.cddbanco = cob.cdbandoc
        and cco.nrdctabb = cob.nrdctabb
        and cco.nrconven = cob.nrcnvcob
        and cco.cdcooper = cob.cdcooper
        --
        and cob.idtitleg > 0
        and cob.cdbandoc = 85
        and cob.vltitulo >= pr_vltitulo_cr
        and cob.dhenvcip >= trunc(sysdate)-7
        and cob.inregcip in (0,1,2)
        and cob.inenvcip = 2
        and cob.cdcooper >= 1
        and cob.rowid = pr_crapcob_rowid;
    rw_titulo cr_titulo%rowtype;
      
    --Variaveis Locais
    vr_idregprc  number(1);
    vr_crapcob_rowid rowid;
    vr_execcomm  number(1);
    --Variaveis Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_dstextab     craptab.dstextab%TYPE;  
    vr_tab_campos   gene0002.typ_split;      
    --Variaveis Excecao
    vr_exc_erro EXCEPTION;    
          
  BEGIN
    
    vr_dstextab := TABE0001.fn_busca_dstextab
                                     (pr_cdcooper => pr_cdcooper
                                     ,pr_nmsistem => 'CRED'
                                     ,pr_tptabela => 'GENERI'
                                     ,pr_cdempres => 0
                                     ,pr_cdacesso => 'ROLLOUT_CIP_CARGA'
                                     ,pr_tpregist => 0); 
      
    vr_tab_campos:= gene0002.fn_quebra_string(vr_dstextab,';');
    
    IF vr_tab_campos.count > 0 THEN

      --> Verificar se esta no dia da carga inicial da faixa de rollout
      IF  trunc(SYSDATE) >= to_date(vr_tab_campos(2),'DD/MM/RRRR')
      AND trunc(SYSDATE) <  to_date(vr_tab_campos(2),'DD/MM/RRRR')+7 THEN
              
        FOR rw IN (
                    select cob.rowid crapcob_rowid
                    from crapcco cco
                        ,crapcob cob
                    where cco.cddbanco = 85
                      and cco.cddbanco = cob.cdbandoc
                      and cco.nrdctabb = cob.nrdctabb
                      and cco.nrconven = cob.nrcnvcob
                      and cco.cdcooper = cob.cdcooper
                      --
                      and cob.idtitleg > 0
                      and cob.cdbandoc = 85
                      and cob.vltitulo >= to_number(vr_tab_campos(3),'999999d99','NLS_NUMERIC_CHARACTERS = ''.,''')
                      and cob.dhenvcip >= trunc(sysdate)-7
                      and cob.inregcip in (0,1,2)
                      and cob.inenvcip = 2
                      and cob.cdcooper >= 1
                  )
        LOOP
          --
          vr_idregprc := 0; --marcar o registro como não processado
          vr_execcomm := 0; --marcar o registro como não deve haver commit;
          vr_crapcob_rowid := rw.crapcob_rowid;
          --
          open cr_titulo(pr_crapcob_rowid => vr_crapcob_rowid
                        ,pr_vltitulo_cr => to_number(vr_tab_campos(3),'999999d99','NLS_NUMERIC_CHARACTERS = ''.,'''));
          fetch cr_titulo into rw_titulo;
          --se o cursor não retornou nada é porque o registro já foi processado por outro job
          if cr_titulo%notfound then
            --
            vr_idregprc := 1; --marcar o registro como processado
            --
          end if;
          close cr_titulo;
          --
          if vr_idregprc = 0 then
          --> buscar retornos disponibilizados
          FOR rw_retnpc IN cr_retnpc(pr_cdlegado => 'LEG'
                                    ,pr_nrispbif => '5463212'
                                      ,pr_idtitleg => rw_titulo.idtitleg
                                      ,pr_idopeleg => rw_titulo.idopeleg) LOOP

              vr_execcomm := 1; --marcar o registro como deve haver commit;

              IF rw_retnpc.tpoperac = 'RI' AND rw_titulo.inenvcip = 2 THEN --> Retorno Inclusao          
                --> Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
                pc_ret_inclusao_tit_npc ( pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                         ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                         ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                         ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informaçcao
                                         ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                         ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                         ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                         ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
                                           
                ELSIF rw_retnpc.tpoperac = 'RA' AND rw_titulo.ininscip = 1 THEN --> Retorno Alteração
                pc_ret_alteracao_tit_npc (pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                         ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                         ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                         ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informaçcao
                                         ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                         ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                         ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                         ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
                
                ELSIF rw_retnpc.tpoperac = 'RB' AND rw_titulo.ininscip = 1 THEN --> Retorno Baixa
                 pc_ret_baixa_tit_npc ( pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                       ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                       ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                       ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informaçcao
                                       ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                       ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                       ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                       ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
                                         
              ELSIF rw_retnpc.tpoperac = 'CO' THEN --> Cancelamento da Baixa Operacional enviada pelo Banco Recebedor
                --> Acão ainda nao definida, será programada em segunda etapa
                NULL;
              ELSIF rw_retnpc.tpoperac = 'JB' THEN --> Baixa Efetiva feita diretamente no JDNPC(Contingência)
                --> Acão ainda nao definida, será programada em segunda etapa
                NULL;
              ELSIF rw_retnpc.tpoperac = 'DP' THEN --> Baixa por Decurso de Prazo
                --> Acão ainda nao definida, será programada em segunda etapa
                NULL;        
              ELSE
                -- Demais tipos de operacao serão ignoradas
                NULL;
            END IF;    
              
            --> verificar se transacao apresentou erro
            IF nvl(vr_cdcritic,0) > 0 OR
               vr_dscritic IS NOT NULL THEN         
              ROLLBACK;
                
              vr_dscritic := 'Erro ao processar retorno idtitleg: '||rw_retnpc.idtitleg||' -> '||
                             vr_dscritic;
                          
                pc_controla_log_batch(pr_cdcooper_in   => vr_cdcooper
                                     ,pr_dstiplog      => 'E'
                                     ,pr_dscritic      => vr_dscritic
                                     ,pr_cdcriticidade => 1
                                     ,pr_cdmensagem    => 0);
                 
            END IF; 
                      
          END LOOP; -- loop retnpc
            
            if vr_execcomm = 1 then
          COMMIT;
            end if;

          end if;
          
        END LOOP; -- loop rw 
          
      END IF;
        
    END IF;
    
  EXCEPTION
    
    WHEN vr_exc_erro THEN     
      vr_iderro := 'S';--ocorreu erro no processamento
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN     
    begin
      --
      vr_iderro := 'S';--ocorreu erro no processamento
      pr_cdcritic := vr_cdcritic;
      vr_dscritic := 'pc_retorno_carga_tit_npc:'
                   ||dbms_utility.format_error_backtrace
            ||' - '||dbms_utility.format_error_stack;
      --
      pc_controla_log_batch(pr_cdcooper_in   => vr_cdcooper
                           ,pr_dstiplog      => 'E'
                           ,pr_dscritic      => vr_dscritic
                           ,pr_cdcriticidade => 1
                           ,pr_cdmensagem    => 0);
      --
      pr_dscritic := vr_dscritic;      
      --
    end;
  END pc_retorno_carga_tit_NPC;  
  
  /**********************************************************/
   
BEGIN
  
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_'||UPPER(vr_cdprogra),
                             pr_action => vr_cdprogra);
  
  -- Percorrer as cooperativas
  FOR rw_crapcop IN cr_crapcop LOOP
  
    /* Busca data do sistema */ 
    OPEN  BTCH0001.cr_crapdat(rw_crapcop.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Verificar se existe informação, e gerar erro caso não exista
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      -- Gerar exceção
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      RAISE vr_exc_saida;
    END IF;
    -- Fechar 
    CLOSE BTCH0001.cr_crapdat;
        
    -- Log de início da execução
    pc_controla_log_batch(pr_cdcooper_in  => rw_crapcop.cdcooper,
                          pr_dstiplog  => 'I');
    
    --> variavel apenas para controle do log, caso seja abortado o programa
    vr_cdcooper := rw_crapcop.cdcooper;                
    
    --> Buscar retorno operacao Titulos NPC
    pc_retorno_operacao_tit_NPC(pr_cdcritic => vr_cdcritic  --Codigo de Erro
                                        ,pr_dscritic => vr_dscritic); --Descricao de Erro    
                                        
    -- Verifica se ocorreu erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    COMMIT;                                          
    
    --> Buscar retorno carga de Titulos NPC por faixa de rollout
    pc_retorno_carga_tit_NPC(pr_cdcritic => vr_cdcritic  --Codigo de Erro
                            ,pr_dscritic => vr_dscritic); --Descricao de Erro    
                                        
    -- Verifica se ocorreu erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    COMMIT;                                              
    
    -- Log de fim da execução
    pc_controla_log_batch(pr_cdcooper_in => rw_crapcop.cdcooper
                         ,pr_dstiplog => 'F');
                                                  
  END LOOP; -- Fim loop cooperativas   
  
  if vr_iderro = 'S' then
    --
    cobr0009.pc_notifica_cobranca(pr_dsassunt => 'CRPS718 - Falha ao receber movimento da cobranca da JD'
                                 ,pr_dsmensag => 'Ocorreu falhar ao receber movimento da cobranca bancaria da Cabine JD.'
                                               ||' Entre em contato com a área de Sustentação de Sistemas para analise dos logs('||vr_idprglog||'). (PC_CRPS718(1))'
                                 ,pr_idprglog => vr_idprglog);
    --
  end if;

EXCEPTION
  WHEN vr_exc_saida THEN
      
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    --
    -- Efetuar rollback
    ROLLBACK;
    --
    if vr_iderro = 'S' then
      --
      cobr0009.pc_notifica_cobranca(pr_dsassunt => 'CRPS718 - Falha ao receber movimento da cobranca da JD'
                                   ,pr_dsmensag => 'Ocorreu falhar ao receber movimento da cobranca bancaria da Cabine JD.'
                                                 ||' Entre em contato com a área de Sustentação de Sistemas para analise dos logs('||vr_idprglog||'). (PC_CRPS718(2))'
                                   ,pr_idprglog => vr_idprglog);
      --
      COMMIT;
      --
    end if;

    -- Log de erro início da execução
    pc_controla_log_batch(pr_cdcooper_in  => vr_cdcooper,
                          pr_dstiplog  => 'F');

  WHEN OTHERS THEN
      
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    vr_dscritic := 'pc_crps718 geral:'
                 ||dbms_utility.format_error_backtrace
          ||' - '||dbms_utility.format_error_stack;
    --
    -- Efetuar rollback
    ROLLBACK;
    --
    pc_controla_log_batch(pr_cdcooper_in   => vr_cdcooper
                         ,pr_dstiplog      => 'E'
                         ,pr_dscritic      => vr_dscritic
                         ,pr_cdcriticidade => 1
                         ,pr_cdmensagem    => 0);

    if vr_iderro = 'S' then
      --
      cobr0009.pc_notifica_cobranca(pr_dsassunt => 'CRPS718 - Falha ao receber movimento da cobranca da JD'
                                   ,pr_dsmensag => 'Ocorreu falhar ao receber movimento da cobranca bancaria da Cabine JD.'
                                                 ||' Entre em contato com a área de Sustentação de Sistemas para analise dos logs('||vr_idprglog||'). (PC_CRPS718(3))'
                                   ,pr_idprglog => vr_idprglog);
      --
      COMMIT;
      --
    end if;

    pr_dscritic := vr_dscritic;

    -- Log de erro início da execução
    pc_controla_log_batch(pr_cdcooper_in  => vr_cdcooper,
                          pr_dstiplog  => 'F');
END pc_crps718;
/
