CREATE OR REPLACE PACKAGE CECRED.NPCB0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : NPCB0001
      Sistema  : Rotinas referentes a Nova Plataforma de Cobrança de Boletos
      Sigla    : NPCB
      Autor    : Odirlei Busana - AMcom
      Data     : Dezembro/2016.                   Ultima atualizacao: 16/12/2016

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a Nova Plataforma de Cobrança de Boletos

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  
  --> Rotina para verificar rollout da plataforma de cobrança
  FUNCTION fn_verifica_rollout ( pr_cdcooper     IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                                 pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE, --> Data do movimento
                                 pr_vltitulo     IN crapcob.vltitulo%TYPE, --> Valor do titulo
                                 pr_tpdregra     IN INTEGER)               --> Tipo de regra de rollout(1-registro,2-pagamento)
                                 RETURN INTEGER;
    
                                                                     
END NPCB0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.NPCB0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : NPCB0001
      Sistema  : Rotinas referentes a Nova Plataforma de Cobrança de Boletos
      Sigla    : NPCB
      Autor    : Odirlei Busana - AMcom
      Data     : Dezembro/2016.                   Ultima atualizacao: 16/12/2016

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas GERAIS referentes a Nova Plataforma de Cobrança de Boletos

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  -- Campos com os valores do rollout, guardados como global para nao serem buscados 
  -- toda vez que a rotina ser chamada, visto que os valores nao são alterados frequentemente
  TYPE typ_tab_dstextab IS TABLE OF craptab.dstextab%TYPE
       INDEX BY PLS_INTEGER;
  vr_dstextab_rollout_pag     typ_tab_dstextab;
  vr_dstextab_rollout_reg     typ_tab_dstextab;
  
  --> Para garantir o valor atualizado, informação será buscada a cada hora
  vr_nrctrlhr        NUMBER;
  
  --> Declaração geral de exception
  vr_exc_erro        EXCEPTION;     
  
  
  --> Rotina para verificar rollout da plataforma de cobrança
  FUNCTION fn_verifica_rollout ( pr_cdcooper     IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                                 pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE, --> Data de movimento
                                 pr_vltitulo     IN crapcob.vltitulo%TYPE, --> Valor do titulo
                                 pr_tpdregra     IN INTEGER)               --> Tipo de regra de rollout(1-registro,2-pagamento)
                                 RETURN INTEGER IS
  /* ..........................................................................
    
      Programa : fn_verifica_rollout        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Dezembro/2016.                   Ultima atualizacao: 16/12/2016
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para verificar rollout da plataforma de cobrança
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    ----------> VARIAVEIS <-----------
    vr_dstextab     craptab.dstextab%TYPE;  
    vr_tab_campos   gene0002.typ_split;  
    vr_cdacesso     craptab.cdacesso%TYPE;
    
  BEGIN   
  
     --> Definir cdacesso conforme tipo de rollout
     IF pr_tpdregra = 1 THEN
       vr_cdacesso := 'ROLLOUT_CIP_REG';
       IF vr_dstextab_rollout_reg.exists(pr_cdcooper) THEN
         vr_dstextab := vr_dstextab_rollout_reg(pr_cdcooper);
       END IF;
     ELSE
       vr_cdacesso := 'ROLLOUT_CIP_PAG';
       IF vr_dstextab_rollout_pag.exists(pr_cdcooper) THEN
         vr_dstextab := vr_dstextab_rollout_pag(pr_cdcooper);
       END IF;
     END IF;  
     
     -- Se ainda nao possui o valor da craptab
     IF vr_dstextab is NULL OR 
        -- ou passou a hora
        to_char(SYSDATE,'HH24') <> vr_nrctrlhr THEN
     
       vr_nrctrlhr := to_char(SYSDATE,'HH24');
     
       --> Buscar dados
       vr_dstextab := TABE0001.fn_busca_dstextab
                                       (pr_cdcooper => pr_cdcooper
                                       ,pr_nmsistem => 'CRED'
                                       ,pr_tptabela => 'GENERI'
                                       ,pr_cdempres => 0
                                       ,pr_cdacesso => vr_cdacesso
                                       ,pr_tpregist => 0); 
      
        --> Guardar valores 
        IF pr_tpdregra = 1 THEN
          vr_dstextab_rollout_reg(pr_cdcooper) := vr_dstextab;
        ELSE
          vr_dstextab_rollout_pag(pr_cdcooper) := vr_dstextab;
        END IF; 
      END IF;
      
      vr_tab_campos:= gene0002.fn_quebra_string(vr_dstextab,';');
      
      --> senao encontrar os parametros do rollout, retornar como nao esta na faixa
      IF vr_tab_campos.count <> 2 THEN
        RETURN 0; 
      END IF;
      
      --> Validar data
      IF pr_dtmvtolt >= to_date(vr_tab_campos(1),'DD/MM/RRRR')  THEN
        --> Validar valor
        IF pr_vltitulo >= gene0002.fn_char_para_number(vr_tab_campos(2)) THEN
          --> Retornar 1 - ja esta na faixa de rollout
          RETURN 1;
        END IF;
      END IF;
      
      RETURN 0;
      
  EXCEPTION 
    WHEN OTHERS THEN
      RETURN 0;      
  END fn_verifica_rollout;  
  
END NPCB0001;
/
