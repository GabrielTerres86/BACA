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
  ******************************************************************************/
  -- CONSTANTES
  vr_cdprogra     CONSTANT VARCHAR2(10) := 'crps718';     -- Nome do programa
  vr_dsarqlog     CONSTANT VARCHAR2(12) := 'crps718.log'; -- Nome do arquivo de log

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
  vr_cdcritic           NUMBER;
  vr_dscritic           VARCHAR2(1000);

  vr_flgerlog           BOOLEAN;
  vr_cdcooper           crapcop.cdcooper%TYPE;
  
  -- EXCEPTIONS
  vr_exc_saida          EXCEPTION;               
  
  --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                  pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    vr_dscritic_aux VARCHAR2(4000);
  BEGIN
  
    --> Apenas gerar log se for processo batch/job ou erro  
    IF nvl(pr_nrdconta,0) = 0 OR pr_dstiplog = 'E' THEN
    
      vr_dscritic_aux := pr_dscritic;
      
      --> Se é erro e possui conta, concatenar o numero da conta no erro
      IF pr_nrdconta <> 0 THEN
        vr_dscritic_aux := vr_dscritic_aux||' - Conta: '||pr_nrdconta;
      END IF;
      
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => pr_cdcooper    --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_cdprogra    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => vr_dscritic_aux    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
  
    END IF;
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
    vr_dslogmes crapprm.dsvlrprm%TYPE;   
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
    --  Data     : Janeiro/2017.                   Ultima atualizacao: 12/07/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
    --
    -- Alteracoes: 12/07/2017 - Atualizar motivo A4 na confirmação do boleto na crapret (Rafael)
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
      vr_dsmensag := 'Titulo Registrado - CIP';
    ELSE
      vr_insitpro := 0; --> Sacado comun
      vr_inenvcip := 4; -- Rejeitadp
      vr_flgcbdda := 0;
      vr_dhenvcip := NULL;
      vr_dsmensag := 'Titulo Rejeitado na CIP';
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
         
         UPDATE crapret ret
            SET cdmotivo = 'A4' || cdmotivo
          WHERE ret.cdcooper = rw_crapcob.cdcooper
            AND ret.nrdconta = rw_crapcob.nrdconta
            AND ret.nrcnvcob = rw_crapcob.nrcnvcob
            AND ret.nrdocmto = rw_crapcob.nrdocmto
            AND ret.cdocorre = 2; -- 2=Confirmacao de registro de boleto
            
        END IF;
        
    EXCEPTION
      WHEN OTHERS THEN
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
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
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
    
    vr_insitpro   crapcob.insitpro%TYPE;
    vr_inenvcip   crapcob.inenvcip%TYPE;
    vr_flgcbdda   crapcob.flgcbdda%TYPE;
    vr_dhenvcip   crapcob.dhenvcip%TYPE;
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
      vr_dsmensag := 'Alteração de Titulo Registrado - CIP';
      
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
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
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
    
    vr_insitpro   crapcob.insitpro%TYPE;
    vr_inenvcip   crapcob.inenvcip%TYPE;
    vr_flgcbdda   crapcob.flgcbdda%TYPE;
    vr_dhenvcip   crapcob.dhenvcip%TYPE;
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
         
      vr_dsmensag := 'Baixa de Titulo Registrado - CIP';                   
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
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
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
      
    --Variaveis Locais
    vr_index     INTEGER;
    vr_index_ret INTEGER;
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

        SELECT 
          cob.idtitleg,
          cob.inenvcip,
          cob.ininscip,
          cob.idopeleg,
          ret.cdocorre
          FROM crapret ret, 
               crapcob cob, crapcco cco --, crapceb ceb 
        WHERE cco.cdcooper > 0
          AND cco.cddbanco = 85
          AND ret.cdcooper = cco.cdcooper
          AND ret.nrcnvcob = cco.nrconven
          AND ret.dtocorre BETWEEN rw_crapcop.dtmvtoan AND rw_crapcop.dtmvtolt
          AND cob.cdcooper = ret.cdcooper
          AND cob.nrcnvcob = ret.nrcnvcob
          AND cob.nrdconta = ret.nrdconta
          AND cob.nrdctabb = cco.nrdctabb
          AND cob.nrdocmto = ret.nrdocmto
          AND cob.cdbandoc = cco.cddbanco
          AND cob.idtitleg > 0
          AND ((cob.inenvcip = 2 AND cob.dtmvtolt BETWEEN rw_crapcop.dtmvtoan AND rw_crapcop.dtmvtolt) OR
               (cob.ininscip = 1 AND trunc(cob.dhinscip) BETWEEN rw_crapcop.dtmvtoan AND rw_crapcop.dtmvtolt))       
          AND cob.cdbandoc = 85
      ) LOOP
    
        --> buscar retornos disponibilizados
        FOR rw_retnpc IN cr_retnpc(pr_cdlegado => 'LEG'
                                  ,pr_nrispbif => '5463212'
                                  ,pr_idtitleg => rw.idtitleg
                                  ,pr_idopeleg => rw.idopeleg) LOOP
                      

          IF rw_retnpc.tpoperac = 'RI' AND rw.inenvcip = 2 THEN --> Retorno Inclusao          
              --> Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
              pc_ret_inclusao_tit_npc ( pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                       ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                       ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                       ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informaçcao
                                       ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                       ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                       ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                       ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
                                       
            ELSIF rw_retnpc.tpoperac = 'RA' AND rw.ininscip = 1 THEN --> Retorno Alteração
              pc_ret_alteracao_tit_npc (pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                       ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                       ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                       ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informaçcao
                                       ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                       ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                       ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                       ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
            
            ELSIF rw_retnpc.tpoperac = 'RB' AND rw.ininscip = 1 THEN --> Retorno Baixa
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
                      
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                       pr_ind_tipo_log => 2, 
                                       pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                      ' - PC_CRPS718 -> ' || vr_dscritic,
                                       pr_nmarqlog     => vr_dsarqlog);
             
          END IF; 
                  
        END LOOP; -- loop retnpc
        
        COMMIT;
      
      END LOOP; -- loop rw 
      
    
  EXCEPTION
    
    WHEN vr_exc_erro THEN     
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN     
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;      
  
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
                     ,pr_idtitleg IN tbjdnpcdstleg_jd2lg_optit."IdTituloLeg"@jdnpcbisql%TYPE) IS
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
      
    --Variaveis Locais
    vr_index     INTEGER;
    vr_index_ret INTEGER;
    vr_dhenvini  DATE := to_date((to_char(SYSDATE, 'DD/MM/RRRR') || ' 00:00:01'),'DD/MM/RRRR HH24:MI:SS');
    vr_dhenvfin  DATE := to_date((to_char(SYSDATE, 'DD/MM/RRRR') || ' 23:59:59'),'DD/MM/RRRR HH24:MI:SS');
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
      IF to_date(vr_tab_campos(2),'DD/MM/RRRR') = trunc(SYSDATE) THEN  
    
        OPEN cr_crapcop;
        FETCH cr_crapcop INTO rw_crapcop;
        CLOSE cr_crapcop;      
              
        FOR rw IN (

          SELECT 
            cob.idtitleg,
            cob.inenvcip,
            cob.ininscip,
            cob.idopeleg
            FROM crapcob cob, crapcco cco --, crapceb ceb 
          WHERE cco.cdcooper > 0
            AND cco.cddbanco = 85
            AND cob.cdcooper = cco.cdcooper
            AND cob.nrcnvcob = cco.nrconven
            AND cob.nrdctabb = cco.nrdctabb
            AND cob.cdbandoc = cco.cddbanco
            AND cob.idtitleg > 0
            AND cob.inenvcip = 2
            AND cob.inregcip IN (0,1,2)
            AND cob.dhenvcip BETWEEN vr_dhenvini AND vr_dhenvfin
            AND cob.cdbandoc = 85
            AND cob.vltitulo >= vr_tab_campos(3)
            
        ) LOOP
        
          --> buscar retornos disponibilizados
          FOR rw_retnpc IN cr_retnpc(pr_cdlegado => 'LEG'
                                    ,pr_nrispbif => '5463212'
                                    ,pr_idtitleg => rw.idtitleg ) LOOP
                          

            IF rw_retnpc.tpoperac = 'RI' AND rw.inenvcip = 2 THEN --> Retorno Inclusao          
                --> Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
                pc_ret_inclusao_tit_npc ( pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                         ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                         ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                         ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informaçcao
                                         ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                         ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                         ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                         ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
                                           
              ELSIF rw_retnpc.tpoperac = 'RA' AND rw.ininscip = 1 THEN --> Retorno Alteração
                pc_ret_alteracao_tit_npc (pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                         ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                         ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                         ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informaçcao
                                         ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                         ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                         ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                         ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
                
              ELSIF rw_retnpc.tpoperac = 'RB' AND rw.ininscip = 1 THEN --> Retorno Baixa
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
                          
              btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                         pr_ind_tipo_log => 2, 
                                         pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                        ' - PC_CRPS718 -> ' || vr_dscritic,
                                         pr_nmarqlog     => vr_dsarqlog);
                 
            END IF; 
                      
          END LOOP; -- loop retnpc
            
          COMMIT;
          
        END LOOP; -- loop rw 
          
      END IF;
        
    END IF;
    
  EXCEPTION
    
    WHEN vr_exc_erro THEN     
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN     
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;      
  
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
    pc_controla_log_batch(pr_cdcooper  => rw_crapcop.cdcooper,
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
    pc_controla_log_batch(pr_cdcooper  => rw_crapcop.cdcooper,
                          pr_dstiplog  => 'F');    
                                                  
  END LOOP; -- Fim loop cooperativas   
  
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
    
    -- Log de erro início da execução
    pc_controla_log_batch(pr_cdcooper  => vr_cdcooper,
                          pr_dstiplog  => 'F',
                          pr_dscritic  => pr_dscritic);
    
    
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
      
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    
    -- Log de erro início da execução
    pc_controla_log_batch(pr_cdcooper  => vr_cdcooper,
                          pr_dstiplog  => 'F',
                          pr_dscritic  => pr_dscritic);
    
    -- Efetuar rollback
    ROLLBACK;
END pc_crps718;
/
