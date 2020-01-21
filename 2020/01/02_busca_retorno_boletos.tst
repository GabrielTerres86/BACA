PL/SQL Developer Test script 3.0
779
/*
  INC0035854
  Script para atualizar no Aimaro os títulos que foram rejeitados e reprocessados
  com sucesso diretamente na Cabine JDNPC.
  Necessário essa atualização para garantir que a baixa efetiva seja processada
  após o pagamento do título.
*/
declare
  --
  type typ_reg_titulo is record
    (crapcob_rowid rowid
    ,tppessoa varchar2(1)
    ,nrinssac crapcob.nrinssac%type
    ,dhenvcip crapcob.dhenvcip%type
    ,nrdident crapcob.nrdident%type
    ,nratutit crapcob.nratutit%TYPE
    ,idopeleg VARCHAR2(10)
    ,idtitleg VARCHAR2(100)
    ,cdstiope VARCHAR2(10)
    ,idtitnpc VARCHAR2(10)
    ,iddopeJD VARCHAR2(100)
    ,tpoperac VARCHAR2(10));
  type typ_tab_titulo is table of typ_reg_titulo index by pls_integer;  
  --
  CURSOR cr_crapcob (pr_rowid IN ROWID) IS
  SELECT cob.insitpro,
         cob.flgcbdda,
         cob.inenvcip,
         cob.dhenvcip,
         cob.nrdident,
         cob.nratutit,
         cob.ininscip
    FROM crapcob cob
   WHERE rowid = pr_rowid;
   rw_crapcob cr_crapcob%ROWTYPE;
   
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
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN     
      pr_dscritic := 'Não foi possivel processar retorno de baixa: '||SQLERRM;  
  END pc_ret_baixa_tit_npc;
  
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
      vr_dsmensag := 'Alteração de Titulo Registrado no Sistema Financeiro Nacional';
      
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
  
begin
  --
  declare
    --
    vr_tab_titulo typ_tab_titulo;
    vr_qtregistro number(10) := 0;
    vr_flgsacad integer;
    vr_cdmotivo varchar2(2);
    vr_cdcritic integer;
    vr_dscritic varchar2(2000);
    vr_des_erro varchar2(200);
    
    vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
    vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/inc0035854';
    vr_nmarqimp        VARCHAR2(100)  := 'inc0035854-rollback.sql';  
    vr_ind_arquiv      utl_file.file_type;
    vr_cobrowid ROWID;
    --
  begin

    --Criar arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                            ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                            ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                            ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);      --> erro
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN        
      dbms_output.put_line('Erro ao criar arquivo');
    END IF;
    --
    --limpa tabela de memória para inicializar processamento
    vr_tab_titulo.delete;
    --
    --carrega tabela de memória com os títulos que devem ser processados
    SELECT crapcob_rowid, tppessoa, nrinssac, dhoperac, nrdident, nratutit, idopeleg, idtitleg, cdstiope, idtitnpc, iddopeJD, tpoperac
    bulk collect into vr_tab_titulo
    FROM (        SELECT tit.crapcob_rowid,
                 tit.tppessoa,
                 tit.nrinssac,
                 to_date(lgjd."DtHrOpJD", 'yyyymmddhh24miss') dhoperac,
                 lgjd."NumIdentcTit" nrdident,
                 lgjd."NumRefAtlCadTit" nratutit,
                 lgjd."IdOpLeg" idopeleg,
                 lgjd."IdTituloLeg" idtitleg,
                 lgjd."SitOpJD" cdstiope,
                 lgjd."NumIdentcTit" idtitnpc,
                 lgjd."IdOpJD" iddopeJD,
                 lgjd."TpOpJD" tpoperac
            FROM tbjdnpcdstleg_jd2lg_optit@jdnpcbisql lgjd,
                 (SELECT cob.rowid crapcob_rowid,
                         decode(cob.cdtpinsc, 1, 'F', 'J') tppessoa,
                         cob.nrinssac,
                         TRIM(to_char(cob.idopeleg)) idopeleg,
                         TRIM(to_char(cob.idtitleg)) idtitleg
                    FROM crapcco cco, crapcob cob
                   WHERE cob.incobran = 0
                     AND cco.cddbanco = 85
                     AND cco.cddbanco = cob.cdbandoc
                     AND cco.nrdctabb = cob.nrdctabb
                     AND cco.nrconven = cob.nrcnvcob
                     AND cco.cdcooper = cob.cdcooper
                     --
                     AND cob.rowid IN (
                     
SELECT c.rowid crapcob_rowid
  FROM crapcob c
      ,crapcol o
 WHERE c.dtmvtolt >= '20/12/2019' --20, 24 e 26
   AND o.dslogtit LIKE '%EDDA0076%'
   AND o.dtaltera >= to_date('21/12/2019', 'dd/mm/rrrr')
   AND o.cdcooper = c.cdcooper
   AND o.nrdconta = c.nrdconta
   AND o.nrdocmto = c.nrdocmto
   AND o.nrcnvcob = c.nrcnvcob
   AND c.incobran = 0
   AND c.flgregis = 1
   
                                      )
                   GROUP BY cob.rowid,
                            decode(cob.cdtpinsc, 1, 'F', 'J'),
                            cob.nrinssac,
                            cob.idopeleg,
                            cob.idtitleg) tit
           WHERE lgjd."TpOpJD" IN( 'RI','RA','RB')
             AND lgjd."CdLeg" = 'LEG'
             AND lgjd."IdOpLeg" = tit.idopeleg
             AND lgjd."IdTituloLeg" = tit.idtitleg
             AND lgjd."ISPBAdministrado" = 5463212
           GROUP BY tit.crapcob_rowid,
                    tit.tppessoa,
                    tit.nrinssac,
                    to_date(lgjd."DtHrOpJD", 'yyyymmddhh24miss'),
                    lgjd."NumIdentcTit",
                    lgjd."NumRefAtlCadTit",
                    lgjd."IdOpLeg",
                    lgjd."IdTituloLeg",
                    lgjd."SitOpJD",
                    lgjd."NumIdentcTit",
                    lgjd."IdOpJD",
                    lgjd."TpOpJD");
    --

    --commit para baixar as operações pendentes abertas pelo select no SQL Server
    commit;
    --
    --processar somente se existirem registros na tabela de memória
    if nvl(vr_tab_titulo.count,0) > 0 then
      --
      for i in vr_tab_titulo.first .. vr_tab_titulo.last
      loop

        OPEN cr_crapcob(vr_tab_titulo(i).crapcob_rowid);
        FETCH cr_crapcob INTO rw_crapcob;
        
        IF cr_crapcob%FOUND THEN
          CLOSE cr_crapcob;
           -- Gerar linha de rollback
           gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 
                                          'update crapcob cob '||
                                              'set cob.ininscip = '''||rw_crapcob.ininscip||''''||
                                               'where cob.rowid = '''||vr_tab_titulo(i).crapcob_rowid||
                                               ''';' ||chr(13));
        ELSE
          CLOSE cr_crapcob;
        END IF;       
        --
        vr_qtregistro := vr_qtregistro + 1;
        
        IF vr_tab_titulo(i).tpoperac = 'RI' AND rw_crapcob.inenvcip = 2 THEN --> Retorno Inclusao    
              
          --> Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
          pc_ret_inclusao_tit_npc ( pr_idtitleg  => vr_tab_titulo(i).idtitleg --> Identificador do titulo no legado
                                   ,pr_idopeleg  => vr_tab_titulo(i).idopeleg --> Identificador da operadao do legado
                                   ,pr_iddopeJD  => vr_tab_titulo(i).iddopeJD --> Identificador da operadao da JD
                                   ,pr_cdstiope  => vr_tab_titulo(i).cdstiope --> Situacao do envio da informaçcao
                                   ,pr_idtitnpc  => vr_tab_titulo(i).idtitnpc --> Identificador do titulo na CIP-NPC
                                   ,pr_nratutit  => vr_tab_titulo(i).nratutit --> Identificador do titulo alteracao na CIP-NPC
                                   ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                   ,pr_dscritic  => vr_dscritic);    
        ELSIF vr_tab_titulo(i).tpoperac = 'RA' AND rw_crapcob.ininscip = 1 THEN --> Retorno Alteração
       
          pc_ret_alteracao_tit_npc(pr_idtitleg  => vr_tab_titulo(i).idtitleg --> Identificador do titulo no legado
                                  ,pr_idopeleg  => vr_tab_titulo(i).idopeleg --> Identificador da operadao do legado
                                  ,pr_iddopeJD  => vr_tab_titulo(i).iddopeJD --> Identificador da operadao da JD
                                  ,pr_cdstiope  => vr_tab_titulo(i).cdstiope --> Situacao do envio da informaçcao
                                  ,pr_idtitnpc  => vr_tab_titulo(i).idtitnpc --> Identificador do titulo na CIP-NPC
                                  ,pr_nratutit  => vr_tab_titulo(i).nratutit --> Identificador do titulo alteracao na CIP-NPC
                                  ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                  ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
            
        ELSIF vr_tab_titulo(i).tpoperac = 'RB' AND rw_crapcob.ininscip = 1 THEN --> Retorno Baixa
             
          pc_ret_baixa_tit_npc (pr_idtitleg  => vr_tab_titulo(i).idtitleg --> Identificador do titulo no legado
                               ,pr_idopeleg  => vr_tab_titulo(i).idopeleg --> Identificador da operadao do legado
                               ,pr_iddopeJD  => vr_tab_titulo(i).iddopeJD --> Identificador da operadao da JD
                               ,pr_cdstiope  => vr_tab_titulo(i).cdstiope --> Situacao do envio da informaçcao
                               ,pr_idtitnpc  => vr_tab_titulo(i).idtitnpc --> Identificador do titulo na CIP-NPC
                               ,pr_nratutit  => vr_tab_titulo(i).nratutit --> Identificador do titulo alteracao na CIP-NPC
                               ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                               ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
        ELSIF vr_tab_titulo(i).tpoperac = 'CO' THEN --> Cancelamento da Baixa Operacional enviada pelo Banco Recebedor
          --> Acão ainda nao definida, será programada em segunda etapa
          NULL;
        ELSIF vr_tab_titulo(i).tpoperac = 'JB' THEN --> Baixa Efetiva feita diretamente no JDNPC(Contingência)
          --> Acão ainda nao definida, será programada em segunda etapa
          NULL;
        ELSIF vr_tab_titulo(i).tpoperac = 'DP' THEN --> Baixa por Decurso de Prazo
          --> Acão ainda nao definida, será programada em segunda etapa
          NULL;        
        ELSE
          -- Demais tipos de operacao serão ignoradas
          NULL;
        END IF;
        
        --commit a cada 50 registros
        if mod(vr_qtregistro,50) = 0 then
          commit;
        end if;
        --
      end loop;
      --
    end if;
    --
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'commit;'); 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;        
    --
    commit;
    --
    dbms_output.put_line('vr_qtregistro:'||vr_qtregistro);
    --
  end;
  --
exception
  when others then
    declare
      vr_dscritic varchar2(2000);
    BEGIN
      cecred.pc_internal_exception;
      vr_dscritic := 'Falha geral:'
                   ||dbms_utility.format_error_backtrace
            ||' - '||dbms_utility.format_error_stack;
      rollback;
      dbms_output.put_line(vr_dscritic||' - '||SQLERRM);
    end;
end;
0
0
