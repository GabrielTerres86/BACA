        /******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+---------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                   |
  +---------------------------------+---------------------------------------+
  |                                 |                                       |
  | CRPS075                         | PC_CRPS075                            |
  |                                 |                                       |
  +---------------------------------+---------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - IRLAN CHEQUER MAIA  (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/* ..........................................................................

   Programa: Fontes/crps075.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/93                         Ultima atualizacao: 22/07/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 013.
               Fazer limpeza mensal dos lancamentos automaticos.
               Rodara na primeira sexta-feira apos o processo mensal.

   Alteracoes: 29/06/95 - Alterado para tratar os lotes tipo 12 (Deborah).

               18/09/98 - Alterado para tratar os lotes tipo 17 (Deborah).

               10/01/2000 - Padronizar mensagens (Deborah).
                
               13/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)
               
               14/07/2009 - incluido no for each a condiçao - 
                            craplau.dsorigem <> "PG555" - Precise - Paulo
                            
               02/06/2011 - incluido no for each a condiçao - 
                            craplau.dsorigem <> "TAA" (Evandro).
                            
               30/09/2011 - incluido no for each a condigco -
                            craplau.dsorigem <> "CARTAOBB" (Ze). 
                            
               04/07/2013 - incluido no for each a condigco -
                            craplau.dsorigem <> "BLOQJUD" (Ze). 
                            
               09/12/2013 - Alterado indice leitura craplot (Daniel)             
               
               31/03/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
                            
               22/07/2014 - Adaptaçao do fontes para chamar a rotina 
                           convertida oracle (Odirlei-AMcom)
                           
............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps075"
       glb_cdcritic = 0
       glb_dscritic = "". 

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0 THEN
DO:
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
                      
   QUIT.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps075 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps075 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps075.pr_cdcritic WHEN pc_crps075.pr_cdcritic <> ?
       glb_dscritic = pc_crps075.pr_dscritic WHEN pc_crps075.pr_dscritic <> ?
       glb_stprogra = IF pc_crps075.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps075.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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


