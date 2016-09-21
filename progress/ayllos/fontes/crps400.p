/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps400.p                | pc_crps400                        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/












/* .............................................................................

   Programa: Fontes/crps400.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Novembro/04.                    Ultima atualizacao: 20/12/2013

   Dados referentes ao programa:

   Frequencia: MENSAL e PRIMEIRO DIA UTIL
   Objetivo  : Guardar relatorios para a auditoria
               Executado no script PROCDIA_unificado_cron.sh

   Alteracoes: 23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               01/09/2006 - Acerto no nome do diretorio. (Ze).

               23/05/2007 - Eliminada a atribuicao TRUE de glb_infimsol pois
                            nao e o ultimo programa da cadeia (Guilherme).
                            
               19/06/2008 - Copiar arquivo compactado para o diretorio salvar
                            (Diego).
                            
               02/06/2010 - Alteração do campo "pkzip25" para "zipcecred.pl" 
                           (Vitor).             
               
               22/06/2011 - Desprezar crrl227 e crrl354 do 1 dia mes (Magui).
               
               20/12/2013 - Restruturar programa para ser executado no 
                            script PROCDIA, fora da cadeia diaria, somente
                            na Cecred (David).
               
.......................................................................... .. */

{ includes/var_batch.i "NEW" }

DEF STREAM str_1. 

DEF VAR aux_nmarqzip AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqrel AS CHAR FORMAT "x(70)"                         NO-UNDO.
DEF VAR aux_flgfirst AS LOGI INIT FALSE                             NO-UNDO.

ASSIGN glb_cdprogra = "crps400"
       glb_cdcooper = 3.
       
FIND crapdat WHERE crapdat.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAIL crapdat  THEN
    DO:
        ASSIGN glb_cdcritic = 1.
        RUN fontes/critic.p.
        ASSIGN glb_cdcritic = 0.
        UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" +
                           glb_dscritic + " >> log/proc_batch.log").
        QUIT.
    END.

/** Salvar relatorios de todas as cooperativas **/
FOR EACH crapcop NO-LOCK:

    ASSIGN aux_flgfirst = FALSE.

    FOR EACH craprel WHERE craprel.cdcooper = crapcop.cdcooper AND
                           craprel.indaudit = 1                NO-LOCK:
    
        ASSIGN aux_nmarqrel = "crrl" + STRING(craprel.cdrelato,"999") + "*".    
        
        INPUT STREAM str_1 THROUGH VALUE("ls /usr/coop/" + crapcop.dsdircop +
                                         "/rl/" + aux_nmarqrel + 
                                         " 2> /dev/null")  NO-ECHO.
    
        DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    
           SET STREAM str_1 aux_nmarqrel FORMAT "x(70)" .
    
           IF   MONTH(crapdat.dtmvtolt) = MONTH(crapdat.dtmvtopr) AND
                CAN-DO("6,7,30,89,108,124,227,234,354",STRING(craprel.cdrelato))
                THEN
                NEXT.
            
           UNIX SILENT VALUE("ux2dos " + aux_nmarqrel + 
                             " > /micros/cecred/auditoria/" +
                             crapcop.dsdircop + "/" + 
                             SUBSTR(aux_nmarqrel,
                                    R-INDEX(aux_nmarqrel,"/") + 1)).

           ASSIGN aux_flgfirst = TRUE.
               
        END.  /*  Fim do DO WHILE TRUE  */
    
        INPUT STREAM str_1 CLOSE.
    
    END. /** Fim do FOR EACH craprel **/

    IF  aux_flgfirst  THEN
        DO:
            IF  MONTH(crapdat.dtmvtolt) = MONTH(crapdat.dtmvtopr)  THEN
                ASSIGN aux_nmarqzip = "audit" + STRING(YEAR(crapdat.dtmvtoan),
                                                       "zzz9")
                                      + TRIM(STRING(MONTH(crapdat.dtmvtoan),
                                                    "99")) + 
                                      ".zip".
            ELSE
                ASSIGN aux_nmarqzip = "audit" + STRING(YEAR(crapdat.dtmvtolt),
                                                       "zzz9")
                                      + TRIM(STRING(MONTH(crapdat.dtmvtolt),
                                                    "99")) + 
                                      ".zip".
    
            UNIX SILENT VALUE("chmod 666 /micros/cecred/auditoria/" + 
                              crapcop.dsdircop + "/" + aux_nmarqzip + 
                              " 2> /dev/null"). 
             
            UNIX SILENT VALUE("zipcecred.pl -silent -add " +
                              "/micros/cecred/auditoria/" + 
                              crapcop.dsdircop + "/" + aux_nmarqzip + " " +
                              "/micros/cecred/auditoria/" + 
                              crapcop.dsdircop + "/" + "crrl*.lst").
                              
            UNIX SILENT VALUE("cp /micros/cecred/auditoria/" + 
                              crapcop.dsdircop +
                              "/" + aux_nmarqzip + " /usr/coop/" +
                              crapcop.dsdircop + "/salvar/").
            
            UNIX SILENT VALUE("rm /micros/cecred/auditoria/" + 
                              crapcop.dsdircop +
                              "/crrl*").     
        
            ASSIGN glb_cdcritic = 807.
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.
            UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" + 
                               crapcop.nmrescop +
                               " - " + glb_dscritic + " >> log/proc_batch.log").
        END.
    ELSE
        DO:
            ASSIGN glb_cdcritic = 182.
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.
            UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" + 
                               crapcop.nmrescop +
                               " - " + glb_dscritic + " >> log/proc_batch.log").
        END.

END. /** Fim do FOR EACH crapcop **/

/** Eliminar arquivo de controle da salva **/
UNIX SILENT VALUE ("rm arquivos/Salva_Auditoria 2>/dev/null").

/*............................................................................*/
