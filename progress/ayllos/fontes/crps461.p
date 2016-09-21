
/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps461.p                | pc_crps461                        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/


/* ..........................................................................

   Programa: Fontes/crps461.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Janeiro/2006.                     Ultima atualizacao: 30/03/2015
      
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 5.(Exclusivo)
               Gera arquivo com informacoes gerenciais. 
               - Gera Relatorio no ultimo dia do mes.
               
   Alteracao : 09/03/2006 - Acerto no campo quantidade cooperados (Diego).
   
               12/05/2006 - Consertado numero de lancamentos (Diego).
   
               01/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                          
                          - Alterado para incluir e-mail denis@cecred.coop.br
                            (Gabriel).
               
               18/06/2008 - Incluida coluna com a situacao do PAC (Gabriel).
               
               15/10/2008 - Incluida coluna com Desconto de Titulo (Diego).
               
               18/12/2008 - Incluir e-mail da Rosangela (Gabriel).
               
               16/10/2009 - Retirar e-mail da Rosangela (Mirtes).
               
               06/03/2010 - Incluir e-mail da Priscila e do Ricardo (Gabriel).
               
               22/06/2011 - Incluir e_mail do Allan (Magui).
               
               04/09/2012 - Modificado nome do arquivo 
                          - Incluido e-mail ana.teixeira@cecred.coop.br (Diego).
                          
               16/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               30/03/2015 - Adaptaçao para fonte hibrido
                            Projeto Conversao Progress -> Oracle (Odirlei-AMcom)
                            
............................................................................. */

DEF VAR aux_dtultdia   AS DATE    FORMAT "99/99/99"                    NO-UNDO.
DEF VAR aux_dtpridia   AS DATE    FORMAT "99/99/99"                    NO-UNDO.
DEF VAR aux_nmarqimp   AS CHAR                                         NO-UNDO.

DEF STREAM str_1.   /*  Para base dados  */

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }
                               
ASSIGN glb_cdprogra = "crps461".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

     
ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_crps461 aux_handproc = PROC-HANDLE
     (INPUT glb_cdcooper,                                                  
      INPUT INT(STRING(glb_flgresta,"1/0")),
      INPUT 0,
      INPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps461 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }


ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps461.pr_cdcritic WHEN pc_crps461.pr_cdcritic <> ?
       glb_dscritic = pc_crps461.pr_dscritic WHEN pc_crps461.pr_dscritic <> ?
       glb_stprogra = IF pc_crps461.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps461.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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


RUN fontes/fimprg.p.

/* ......................................................................... */

