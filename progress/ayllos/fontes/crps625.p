/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps625.p                | pc_crps625                        |
  +---------------------------------+-----------------------------------+
  
   TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 04/MAR/2015 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - IRLAN CHEQUER MAIA  (CECRED)
   - MARCOS MARTINI      (SUPERO)

******************************************************************************/

/* ............................................................................

   Programa: Fontes/crps625.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : André Santos/Supero
   Data    : Agosto/2012                        Ultima atualizacao: 23/07/2016.

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar/Gerar arquivos TIC
               Recebe arquivo TIC614 gera TIC606

   Alteracoes: 13/08/2012 - Primeira Versao
   
               24/10/2012 - Alterar Agencia Apresentante para Depositante (Ze).
               
               25/02/2013 - Alterado estrutura da procedure p_elimina_tic.
                            (Fabricio)
                            
               12/08/2014 - Ajustes na geracao do arquivo TIC606 para 
                            tratar a Unificacao das SIRC's; 018.
                            (Chamado 146058) - (Fabricio)
                            
               29/05/2015 - Conversão Progress >> Oracle (Jean Michel).
                                
			   23/07/2016 - Finalizacao da Conversao (Jonata-Rkam)
                                
............................................................................ */


{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps625"
       glb_flgbatch = FALSE. 

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " +
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
    RETURN.
END.
ERROR-STATUS:ERROR = FALSE.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps625 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INT(STRING(glb_flgresta,"1/0")),
    INPUT glb_nmtelant,
    OUTPUT 0,
    OUTPUT 0,
    OUTPUT 0, 
    OUTPUT "").

IF  ERROR-STATUS:ERROR  THEN DO:
    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + 
                              ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
        
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao executar Stored Procedure: '" +
                      aux_msgerora + "' >> log/proc_batch.log").
    RETURN.
END.

CLOSE STORED-PROCEDURE pc_crps625 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps625.pr_cdcritic WHEN pc_crps625.pr_cdcritic <> ?
       glb_dscritic = pc_crps625.pr_dscritic WHEN pc_crps625.pr_dscritic <> ?
       glb_stprogra = IF pc_crps625.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps625.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " +
                          "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
        RETURN.
    END.

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
