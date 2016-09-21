/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps266.p                | pc_crps266                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

*******************************************************************************/

/* ..........................................................................

   Programa: Fontes/crps266.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Julho/99                        Ultima alteracao: 09/09/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Emitir listagem dos lancamentos de transferencia de mesma 
               titularidade sem cobranca de CPMF.
               Atende a solicitacao 02.
               Gera relatorio 215.
               Exclusividade 2 (Paralelo).

   Alteracao : 19/07/99 - Alterado para chamar a rotina de impressao (Edson).

               14/08/2000 - Alterado para na leitura do historico 303, testar
                            tambem o valor do lancamento (Edson).

               28/10/2004 - Tratar conta integracao (Margarete).

               08/06/2005 - Incluidos Tipos de Conta 17 e 18(Mirtes).

               05/01/2006 - Cancelar impressao para Coope 1 (Magui).
                
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               25/05/2007 - Retirado vinculacao imprim.p ao codigo da
                            cooperativa(Guilherme).
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero). 
                            
               23/02/2015 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Vanessa)            
............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps266"
       glb_cdcritic = 0
       glb_dscritic = "".

RUN fontes/iniprg.p.
                                                                        
IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

    QUIT.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps266 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INTE(STRING(glb_flgresta,"1/0")),
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
    QUIT.
END.

CLOSE STORED-PROCEDURE pc_crps266 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps266.pr_cdcritic WHEN pc_crps266.pr_cdcritic <> ?
       glb_dscritic = pc_crps266.pr_dscritic WHEN pc_crps266.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps266.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps266.pr_infimsol = 1 THEN
                         TRUE
                      ELSE
                         FALSE.

IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                          "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

        QUIT.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
RUN fontes/fimprg.p.

/* .......................................................................... */


