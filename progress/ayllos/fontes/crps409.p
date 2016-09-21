/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+---------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                   |
  +---------------------------------+---------------------------------------+
  |                                 |                                       |
  |      crps409.p                  |        pc_crps409                     |
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

   Programa: fontes/crps409.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Setembro/2004                   Ultima atualizacao: 26/11/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 082. 
               Gerar arquivo com SALDO DISPONIVEL (COO404) na c/c dos 
               associados para enviar ao B. Brasil - CHEQUES COMPE.

   Alteracoes: 28/03/2005 - Gerar Saldo Disponivel + Limite Credito(Mirtes)

               06/04/2005 - Gravar os erros no log da tela PRCITG (Evandro).

               29/07/2005 - Alterada mensagem Log referente critica 847        
                            (Diego).

               23/09/2005 - Zerar o total para cada arquivo (Evandro).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               01/11/2005 - Alterado limite de registros por arquivo (Evandro).

               03/11/2005 - Corrigida leitura do bloqueio da craptab (Evandro).

               10/01/2006 - Correcao das mensagens para o LOG (Evandro).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               04/01/2007 - Somente enviar o arquivo de saldos se a conta for
                            do tipo - conta integracao (12,13,14,15,17,18)
                            (Evandro).

               12/04/2007 - Enviar arquivo de saldo se conta for itg.
                            Devido aos debitos automaticos(Mirtes)

               30/10/2012 - Ajustes para migracao contas Altovale (Tiago).     

               04/01/2013 - Incluido condicao (craptco.tpctatrf <> 3) na busca
                            da craptco (Tiago).

               16/12/2013 - Ajuste migraçao Acredi. (Rodrigo)                                  

               04/06/2014 - Ajuste no valor do Saldo Disponivel, buscando via
                            obtem-saldo-dia e nao mais pelo valor da SLD
                            (Guilherme/SUPERO)
                            
               11/09/2014 - Ajustes devido a migracao Concredi e Credimilsul
                            (Odirlei/Amcom).           
                
               12/06/2015 - Adaptaçao fonte hibrido progress -> Oracle 
                            (Odirlei-AMcom) 
............................................................................ */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF     VAR aux_nmarqimp AS CHAR      FORMAT "x(50)"                 NO-UNDO.
DEF     VAR aux_nrtextab AS INT                                      NO-UNDO.
DEF     VAR aux_nrregist AS INT                                      NO-UNDO.
DEF     VAR aux_dsdlinha AS CHAR      FORMAT "x(70)"                 NO-UNDO.

DEF     VAR aux_nrdctitg LIKE crapass.nrdctitg                       NO-UNDO.
DEF     VAR aux_digctitg AS CHAR                                     NO-UNDO.
DEF     VAR aux_vltotsld AS DECIMAL                                  NO-UNDO.

DEF     VAR aux_vlsddisp      AS DEC                                 NO-UNDO.
DEF     VAR aux_vlsddisp_tot  AS DEC                                 NO-UNDO.
DEF     VAR aux_indvlsdd      AS CHAR FORMAT "x(01)"                 NO-UNDO.

DEF     VAR aux_cdcooper      LIKE  crapcop.cdcooper                 NO-UNDO.
DEF     VAR aux_nrdconta      LIKE  crapass.nrdconta                 NO-UNDO.

/* nome do arquivo de log */
DEF     VAR aux_nmarqlog      AS CHAR                                NO-UNDO.


ASSIGN glb_cdprogra = "crps409"
       glb_flgbatch = FALSE
       aux_nmarqlog = "log/prcitg_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps409 aux_handproc = PROC-HANDLE
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
    RETURN.
END.

CLOSE STORED-PROCEDURE pc_crps409 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps409.pr_cdcritic WHEN pc_crps409.pr_cdcritic <> ?
       glb_dscritic = pc_crps409.pr_dscritic WHEN pc_crps409.pr_dscritic <> ?
       glb_stprogra = IF pc_crps409.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps409.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


/*...........................................................................*/
