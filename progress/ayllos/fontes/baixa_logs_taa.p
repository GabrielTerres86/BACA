/* ..........................................................................

   Programa: fontes/baixa_logs_taa.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Junho/2010                     Ultima atualizacao: 25/06/2010

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado pela CRON
   Objetivo  : Baixar os logs dos caixas com sistema TAA

   Alteracoes: 25/06/2010 - Passar o diretorio da cooperativa para o 
                            script (Evandro).
                            
               -------------------- 04/04/2011 --------------------------
               Alteracao temporaria para descobrir problema de travamento
               do programa (Evandro).
               ----------------------------------------------------------
               
               
   
.......................................................................... */
   
DEFINE VARIABLE glb_cdcooper    AS INT          NO-UNDO.

DEFINE VARIABLE aux_nmusuari    AS CHAR         NO-UNDO.
DEFINE VARIABLE aux_dsdsenha    AS CHAR         NO-UNDO.
DEFINE VARIABLE aux_nmdireto    AS CHAR         NO-UNDO.
DEFINE VARIABLE aux_nmlogtaa    AS CHAR         NO-UNDO.
DEFINE VARIABLE aux_dscomand    AS CHAR         NO-UNDO.

DEFINE VARIABLE aux_nmarqlog    AS CHAR         NO-UNDO.
DEFINE VARIABLE aux_flgexist    AS LOGICAL      NO-UNDO.


ASSIGN aux_nmusuari = "ftp_cash"
       aux_dsdsenha = "cash$"
       aux_nmdireto = "LOG"
       aux_nmarqlog = "/usr/coop/cecred/log/TAA/Busca_Log_TAA.log".


UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") + " - " +
                   STRING(TIME,"HH:MM:SS") + " - " +
                   "Inicio da recepcao do log dos TAAs" +
                   " >> " + aux_nmarqlog).

FOR EACH crapcop NO-LOCK BY crapcop.cdcooper:
    
    aux_flgexist = NO.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

    UNIX SILENT VALUE ("echo >> " + aux_nmarqlog).
    UNIX SILENT VALUE ("echo Cooperativa: " +
                       STRING(crapcop.cdcooper,"z99") + " - " +
                       TRIM(crapcop.nmrescop) + 
                       " em " + STRING(crapdat.dtmvtolt,"99/99/9999") +
                       " >> " + aux_nmarqlog).

    FOR EACH craptfn WHERE craptfn.cdcooper = crapcop.cdcooper   AND
                           craptfn.cdsitfin < 8  /* 8-desat.*/   AND
                           craptfn.flsistaa = YES
                           NO-LOCK BY craptfn.cdagenci
                                     BY craptfn.nrterfin:


        ASSIGN aux_nmlogtaa = "LG" +
                              STRING(craptfn.nrterfin,"9999") + "_" +
                              STRING(YEAR(crapdat.dtmvtolt),"9999") +
                              STRING(MONTH(crapdat.dtmvtolt),"99")  +
                              STRING(DAY(crapdat.dtmvtolt),"99")    +
                              ".log"

               aux_dscomand = "BuscaArquivoTAA.sh"            + " " +
                              TRIM(craptfn.nmnarede)          + " " +
                              aux_nmdireto                    + " " +
                              aux_dsdsenha                    + " " +
                              aux_nmusuari                    + " " +
                              aux_nmlogtaa                    + " " +
                              STRING(craptfn.nrterfin,"9999") + " " +
                              TRIM(crapcop.dsdircop)          + " " +
                              "1>>/usr/coop/cecred/log/TAA/" +
                              "Busca_Log_TAA_erros.log " +
                              "2>>/usr/coop/cecred/log/TAA/" +
                              "Busca_Log_TAA_erros.log".
                              
               aux_flgexist = YES.

        UNIX SILENT VALUE (aux_dscomand).
    END. /* fim craptfn */
    

    IF  NOT aux_flgexist  THEN
        UNIX SILENT VALUE ("echo   - Nenhum TAA encontrado" +
                           " >> " + aux_nmarqlog).

    UNIX SILENT VALUE ("echo Fim da Cooperativa: " +
                       STRING(crapcop.cdcooper,"z99") + " - " +
                       TRIM(crapcop.nmrescop) + 
                       " >> " + aux_nmarqlog).
   
END. /* fim crapcop */

UNIX SILENT VALUE ("echo >> " + aux_nmarqlog).
UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") + " - " +
                   STRING(TIME,"HH:MM:SS") + " - " +
                   "Fim da recepcao do log dos TAAs" +
                   " >> " + aux_nmarqlog).

/* ....................................................................... */
