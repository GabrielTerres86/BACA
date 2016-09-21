/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+---------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                   |
  +---------------------------------+---------------------------------------+
  |                                 |                                       |
  | CRPS096                         | PC_CRPS096                            |
  |                                 |                                       |
  +---------------------------------+---------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - IRLAN CHEQUER MAIA    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/* ..........................................................................

   Programa: Fontes/crps096.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Setembro/94.                     Ultima atualizacao: 21/07/2014

   Dados referentes ao programa:

   Frequencia: Roda Mensalmente no Processo de Limpeza
   Objetivo  : Limpeza dos Cartoes de Cheque Especial Vencidos.

               Atende a Solicitacao 013.
               Ordem da Solicitacao 065.
               Exclusividade = 2
               Ordem do Programa na Solicitacao = 12

   Alteracao - 16/12/94 - Alterado para nao flegar a solicitacao como atendida e
                          nao atualizar a tabela de Execucao. (Odair).

               10/01/2000 - Padronizar mensagens (Deborah).
               
               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre.
               
               24/05/2007 - Fazer limpeza das tabelas:
                            crawcrd/crapcrd(Ha mais de 3 anos) - BB,  
                            craphdp/crapddp/crapmdp(Ha mais de 6 meses),
                            crapcch(Ha mais de 6 meses) (Guilherme).
                            
               18/06/2014 - Exclusao do uso da tabela crapcar.
                            (Tiago Castro - Tiago RKAM)
                            
               21/07/2014 - Adaptaçao do fontes para chamar a rotina 
                           convertida oracle (Odirlei-AMcom)
                           
............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN  glb_cdprogra = "crps096"
       glb_cdcritic = 0
       glb_dscritic = "". 

RUN fontes/iniprg.p.

IF glb_cdcritic > 0 THEN
DO:
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
                      
   QUIT.
END.
 
ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps096 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INT(STRING(glb_flgresta,"1/0")),
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

CLOSE STORED-PROCEDURE pc_crps096 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps096.pr_cdcritic WHEN pc_crps096.pr_cdcritic <> ?
       glb_dscritic = pc_crps096.pr_dscritic WHEN pc_crps096.pr_dscritic <> ?
       glb_stprogra = IF pc_crps096.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps096.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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
