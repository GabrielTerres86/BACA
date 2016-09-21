/* .............................................................................

   Programa: Fontes/compefora.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jonatas - Supero TI
   Data    : Julho/2010.                     Ultima atualizacao:

   Dados referentes ao programa:

   Objetivo  : Programa utilizado para processar os arquivos manualmente
               quando o mesmo nao chegou a tempo.

   Alteracoes: 18/12/2013 - Inclusao de VALIDATE crapsol (Carlos)

............................................................................. */

{ includes/var_batch.i "NEW" }

DEF VAR aux_nrsolici AS INT                                            NO-UNDO.
DEF VAR aux_contador AS INT                                            NO-UNDO.
DEF VAR aux_contaarq AS INT                                            NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_tparquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.
DEF VAR aux_cdrelato AS CHAR                                           NO-UNDO.
DEF VAR aux_ultlinha AS INTE                                           NO-UNDO.
DEF VAR aux_datatual AS DATE        INIT TODAY                         NO-UNDO.
DEF VAR aux_setlinha AS CHAR        FORMAT "x(110)"                    NO-UNDO.
DEF VAR aux_confirma AS CHAR        FORMAT "!(1)"                      NO-UNDO.
DEF VAR aux_execfon  AS CHAR                                           NO-UNDO.
DEF VAR aux_posidata AS INT                                            NO-UNDO.
DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nomedarq AS CHAR                                           NO-UNDO.
DEF VAR aux_tamarqui AS CHAR                                           NO-UNDO.
DEF VAR aux_rodaopci AS CHAR                                           NO-UNDO.
DEF VAR aux_nmrelato AS CHAR                                           NO-UNDO.
DEF VAR aux_coopesld AS INT                                            NO-UNDO. 
DEF VAR aux_nmarqsld AS CHAR                                           NO-UNDO.
DEF VAR hst_int_dia  AS CHAR                                           NO-UNDO.
DEF VAR hst_int_apos AS CHAR                                           NO-UNDO.
DEF VAR rel_vlsddisp AS DECIMAL                                        NO-UNDO.
DEF VAR rel_vlsdbloq AS DECIMAL                                        NO-UNDO.
DEF VAR rel_vlsdblpr AS DECIMAL                                        NO-UNDO.
DEF VAR rel_vlsdblfp AS DECIMAL                                        NO-UNDO.
DEF VAR rel_vlsdchsl AS DECIMAL                                        NO-UNDO.
DEF VAR aux_vlipmfap AS DECIMAL                                        NO-UNDO.
DEF VAR rel_qtcmpbcb AS INTEGER                                        NO-UNDO. 
DEF VAR rel_vlcmpbcb AS DECIMAL                                        NO-UNDO.
DEF VAR rel_vllimcre AS DECIMAL                                        NO-UNDO.
DEF VAR aux_msgrodap AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_datnmarq AS CHAR                                           NO-UNDO.
DEF VAR ret_flgdatas AS LOG                                            NO-UNDO.
DEF VAR aux_lgretorn AS LOG                                            NO-UNDO.
DEF VAR aux_nmdbanco AS CHAR                                           NO-UNDO.
DEF VAR aux_dssituac AS CHAR                                           NO-UNDO.
DEF VAR aux_dtbrowse AS CHAR                                           NO-UNDO.
DEF VAR aux_dspermis AS CHAR                                           NO-UNDO.
DEF VAR aux_arqpermi AS CHAR        FORMAT "x(110)"                    NO-UNDO.

DEF BUFFER crablcm FOR craplcm.

DEF VAR tel_cddopcao AS CHAR        FORMAT "x(23)" VIEW-AS COMBO-BOX 
    INNER-LINES 5  NO-UNDO.

DEF VAR tel_pesquisa AS CHAR                                           NO-UNDO.
DEF VAR tel_cdopbanc AS LOGICAL     FORMAT "BB/BANCOOB"                NO-UNDO.
DEF VAR tel_dscooper AS CHAR                                           NO-UNDO.

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_log.
DEF STREAM str_permis.

DEF TEMP-TABLE tt-verarqui                                             NO-UNDO
         FIELD  cdcooper      LIKE crapcop.cdcooper
         FIELD  dsdircop      AS CHAR
         FIELD  nmdbanco      AS CHAR
         FIELD  nmarquiv      AS CHAR
         FIELD  dtarquiv      AS CHAR 
         FIELD  cdprogra      AS CHAR
         FIELD  dspermis      AS CHAR
         FIELD  cdrelato      AS CHAR
         FIELD  dssituac      AS CHAR.

DEF QUERY q_tt-verarqui FOR tt-verarqui.

DEF BROWSE b_tt-verarqui QUERY q_tt-verarqui
    DISPLAY tt-verarqui.nmdbanco COLUMN-LABEL "Banco"            FORMAT "x(10)"
            tt-verarqui.nmarquiv COLUMN-LABEL "Arquivos"         FORMAT "x(20)"
            tt-verarqui.dtarquiv COLUMN-LABEL "Data"             
            tt-verarqui.cdprogra COLUMN-LABEL "Programa"         FORMAT "x(10)"
            tt-verarqui.dspermis COLUMN-LABEL "Permissao"        FORMAT "x(10)"
            tt-verarqui.cdrelato COLUMN-LABEL "Rel"              FORMAT "x(10)"
            tt-verarqui.dssituac COLUMN-LABEL "Situacao"         FORMAT "x(10)"
    WITH 5 DOWN WIDTH 74 TITLE "Arquivos a serem integrados".

FORM tel_dscooper     LABEL "Coop "            FORMAT "x(16)"           AT 01
     glb_dtmvtolt     LABEL "Dt Movto "        FORMAT "99/99/9999"      AT 26
     aux_datatual     LABEL "Dt Atual "        FORMAT "99/99/9999"      AT 54
     SKIP(2)
     b_tt-verarqui                                                      AT 03 
                      HELP "Pressione DELETE para excluir / F4 para sair"
     aux_msgrodap     NO-LABEL                 FORMAT "x(75)"           AT 01
     SKIP(1)
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_compefora_browse.


FORM SKIP(2)
     tel_cddopcao AT 05 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao a processar ou <END> para sair"
     WITH SIDE-LABELS OVERLAY NO-BOX FRAME f_filtro.

FORM tel_pesquisa  LABEL "Pesquisar " FORMAT "x(40)" AT 01
                   HELP "Informe texto para pesquisa"
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao_l.

FORM tt-verarqui.dsdircop  LABEL "Cooperativa "  FORMAT "x(12)"      AT 01
     tt-verarqui.nmarquiv  LABEL "Arquivo "      FORMAT "x(15)"      AT 15
     aux_nmrelato          LABEL "Relatorio"     FORMAT "x(45)"      AT 32
     WITH ROW 5 OVERLAY DOWN NO-BOX FRAME f_relato.
    
FORM tel_cdopbanc           LABEL "Que Banco nao integrou"            AT 01
                            HELP "Informe o banco (BB/BANCOOB)"
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_saldo.

{ includes/gg0000.i }

IF   NOT f_conectagener() THEN 
     DO:
         MESSAGE "Erro na conexao com o banco Generico." VIEW-AS ALERT-BOX.
         RETURN.
     END.    

glb_cdcooper = INT(OS-GETENV("CDCOOPER")).
glb_nmtelant = "COMPEFORA".

IF   glb_cdcooper = ?   THEN
     DO:
         MESSAGE "Cooperativa Nao Identificado".
         NEXT.
     END.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
 
IF   NOT AVAILABLE crapcop THEN
     DO:
         MESSAGE "ERRO - Sem registro de crapcop".
         NEXT.
     END.

FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapdat THEN
     DO:
         MESSAGE "ERRO - Sem registro de crapdat".
         NEXT.
     END.


ASSIGN glb_dtmvtolt = crapdat.dtmvtolt.
        

ON RETURN OF tel_cddopcao 
   DO:
       tel_cddopcao = tel_cddopcao:SCREEN-VALUE.
       APPLY "GO".
   END.


/* Deleta linhas do frame */
ON "DELETE" OF b_tt-verarqui IN FRAME f_compefora_browse
   DO:
       IF   NOT AVAILABLE tt-verarqui  THEN
            RETURN.

       DELETE tt-verarqui.
       
       ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("q_tt-verarqui").

       CLOSE QUERY q_tt-verarqui.
        
       OPEN QUERY q_tt-verarqui FOR EACH tt-verarqui BY tt-verarqui.nmarquiv.

       REPOSITION q_tt-verarqui TO ROW aux_ultlinha.
   END.


/* mudança de registro, mensagem rodapé.*/
ON VALUE-CHANGED, ENTRY OF b_tt-verarqui 
   DO:
       IF   tt-verarqui.dssituac = "ERRO"  THEN
            DISPLAY aux_msgrodap
                WITH FRAME f_compefora_browse.
   END.

ASSIGN tel_cddopcao:LIST-ITEMS = "Verifica Arquivos,Integrar Arquivos," +
                                 "Log do Processo,Saldo Apos processo," +
                                 "Relatorios Gerados".

DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        UPDATE tel_cddopcao WITH FRAME f_filtro.
        LEAVE.
    END.
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        LEAVE.

    ASSIGN aux_msgrodap = "Observacao: Arquivo com Data" + 
                          " diferenciada no nome com o HEADER".
    
        ASSIGN tel_dscooper = CAPS(crapcop.dsdircop).
        
    CASE tel_cddopcao:
        WHEN "Verifica Arquivos" THEN 
             DO:
                 RUN pi_verifica_arquivos.
            
                 DISPLAY  tel_dscooper  aux_datatual  glb_dtmvtolt 
                          WITH FRAME f_compefora_browse. 
            
                 OPEN QUERY q_tt-verarqui
                      FOR EACH tt-verarqui NO-LOCK
                               BY tt-verarqui.nmarquiv.

                 ENABLE b_tt-verarqui WITH FRAME f_compefora_browse.
                 
                 IF  NUM-RESULTS("q_tt-verarqui") = 0  THEN
                    DO:
                        BELL.
                        MESSAGE "Nao foram encontrados arquivos pendentes.".
                        CLOSE QUERY q_tt-verarqui.
                        HIDE FRAME f_compefora_browse.
                        NEXT.
                    END.

                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    UPDATE b_tt-verarqui WITH FRAME f_compefora_browse.
                    LEAVE.
                 END.
            
                 CLOSE QUERY q_tt-verarqui.

                 HIDE FRAME f_compefora_browse.
             END.
    
        WHEN "Integrar Arquivos" THEN 
             DO: 
                 ASSIGN aux_rodaopci = "N"
                        aux_contaarq = 0.

                 FOR EACH tt-verarqui:
                     aux_contaarq = aux_contaarq + 1.
                 END.

                 IF   aux_contaarq = 0 THEN
                      DO:
                          MESSAGE "Necessario rodar antes a opção Verifica Arq."
                                  VIEW-AS ALERT-BOX INFO BUTTONS OK.
                          NEXT.
                      END.            

                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    ASSIGN aux_confirma = "N"
                           glb_cdcritic = 78.
                    RUN fontes/critic.p.
                    ASSIGN glb_cdcritic = 0.
                    BELL.
                    MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                    LEAVE.
                 END.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                      aux_confirma <> "S"                 THEN
                      DO:
                          ASSIGN glb_cdcritic = 79.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          ASSIGN glb_cdcritic = 0.
                          NEXT.
                      END.
            
                 FOR EACH tt-verarqui WHERE tt-verarqui.dssituac = "OK"
                                      BREAK BY tt-verarqui.cdcooper
                                            BY tt-verarqui.cdprogra:

                     IF   FIRST-OF(tt-verarqui.cdprogra)  THEN
                          DO:
                              IF   tt-verarqui.cdprogra = "crps375" OR
                                   tt-verarqui.cdprogra = "crps500" THEN
                                   aux_nrsolici = 005.
                              ELSE
                                   aux_nrsolici = 001.
                       
                              FIND crapsol WHERE 
                                           crapsol.cdcooper = glb_cdcooper AND
                                           crapsol.nrsolici = aux_nrsolici 
                                           NO-LOCK NO-ERROR.

                              IF   NOT AVAILABLE crapsol   THEN
                                   DO TRANSACTION:
                                      CREATE CRAPSOL.
                                      ASSIGN crapsol.nrsolici = aux_nrsolici
                                             crapsol.dtrefere = crapdat.dtmvtolt
                                             crapsol.nrseqsol = 1
                                             crapsol.cdempres = 11
                                             crapsol.dsparame = ""
                                             crapsol.insitsol = 1
                                             crapsol.nrdevias = 1
                                             crapsol.cdcooper = glb_cdcooper.

                                      VALIDATE crapsol.

                                   END.
          
                       
                              ASSIGN aux_execfon = "fontes/" +
                                                   tt-verarqui.cdprogra + ".p".
                   
                              MESSAGE "Executando " + 
                                      CAPS(tt-verarqui.cdprogra) + "...".

                              RUN VALUE(aux_execfon). 

                              MESSAGE "Termino do " + 
                                      CAPS(tt-verarqui.cdprogra) + "...".

                              HIDE MESSAGE NO-PAUSE.
                       
                              DO TRANSACTION: 
                                 FIND crapsol WHERE 
                                      crapsol.cdcooper = glb_cdcooper AND
                                      crapsol.nrsolici = aux_nrsolici 
                                      NO-ERROR.
                               
                                 IF   AVAILABLE crapsol   THEN 
                                      DELETE crapsol.
                              END.
                          END.
                 END.
            
                 ASSIGN aux_rodaopci = "S".

                 MESSAGE "Arquivos Integrados, favor " +
                         "verificar sua execução no LOG do Processo".
             END.
    
        WHEN "Log do Processo" THEN
             DO:   
                 RUN pi_opcao_l.
                 HIDE FRAME f_opcao_l.
             END.

        WHEN "Saldo Apos processo" THEN 
             DO:
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    ASSIGN aux_confirma = "N"
                           glb_cdcritic = 78.
                    RUN fontes/critic.p.
                    ASSIGN glb_cdcritic = 0.
                    BELL.
                    MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                    LEAVE.
                 END.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                      aux_confirma <> "S"                 THEN
                      DO:
                          ASSIGN glb_cdcritic = 79.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          ASSIGN glb_cdcritic = 0.
                          NEXT.
                      END.

                 FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper AND
                                    crapsol.nrsolici = 63 
                                    NO-LOCK NO-ERROR.
                          
                 IF   NOT AVAILABLE crapsol   THEN
                      DO TRANSACTION:
                         CREATE CRAPSOL.
                         ASSIGN crapsol.nrsolici = 063
                                crapsol.dtrefere = crapdat.dtmvtolt
                                crapsol.nrseqsol = 1
                                crapsol.cdempres = 11
                                crapsol.dsparame = "999"
                                crapsol.insitsol = 1
                                crapsol.nrdevias = 1
                                crapsol.cdcooper = glb_cdcooper.

                         VALIDATE crapsol.
                      END.

                 MESSAGE "Executando crps121...".

                 RUN fontes/crps121.p "new".

                 PAUSE (0).
                 
                 DO TRANSACTION:
                   
                    FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper AND
                                       crapsol.nrsolici = 63 
                                       NO-ERROR.
                                       
                    IF   AVAILABLE crapsol   THEN
                         DELETE crapsol.
                 END.

                 ASSIGN aux_coopesld = crapcop.cdcooper.

                 PAUSE (5) NO-MESSAGE.
 
/*                  IF   tel_cdopbanc then                                        */
/*                       ASSIGN aux_nmarqsld = "bb_" + crapcop.dsdircop + ".txt"  */
/*                              /* Hist. Integrou apos o processo */              */
/*                              hst_int_apos = "50,59"                            */
/*                              hst_int_dia  = "313,340".                         */
/*                  ELSE                                                          */
/*                       ASSIGN aux_nmarqsld = "bcb_" + crapcop.dsdircop + ".txt" */
/*                              /* Hist. Integrou apos o processo */              */
/*                              hst_int_apos  = "313,340"                         */
/*                              hst_int_dia = "50,59".                            */
/*                                                                                */
/*                  OUTPUT TO VALUE(aux_nmarqsld).                                */

/*                  RUN pi_calcula_saldo. */

/*                  UNIX SILENT VALUE("ux2dos " + aux_nmarqsld +      */
/*                                    " > /micros/teste/" +           */
/*                                    aux_nmarqsld + " 2>/dev/null"). */
           
             END.
        
        WHEN "Relatorios Gerados" THEN 
             DO:
                 IF   aux_contaarq > 0 AND aux_rodaopci = "S" THEN
                      DO:
                          FOR EACH tt-verarqui 
                                   BREAK BY tt-verarqui.cdcooper
                                            BY tt-verarqui.cdprogra:
                    
                              IF   FIRST-OF(tt-verarqui.cdprogra)  THEN
                                   DO:
                                        FOR EACH craprel WHERE 
                                                 craprel.cdcooper = 
                                                    tt-verarqui.cdcooper AND
                                                 CAN-DO(tt-verarqui.cdrelato,
                                                    STRING(craprel.cdrelato)):

                                            ASSIGN aux_nmrelato =
                                                     STRING(craprel.cdrelato) +
                                                     " - " + craprel.nmrelato.
                                  
                                            DISPLAY tt-verarqui.dsdircop
                                                    tt-verarqui.nmarquiv
                                                    aux_nmrelato 
                                                    WITH FRAME f_relato.
                                  
                                            DOWN WITH FRAME f_relato.
                    
                                        END. /* End for each craprel */
                                   END.
                          END. /* End for each tt-verarqui */               
                      END.
                 ELSE
                      DO:
                          MESSAGE "Necessario rodar antes a Integracao."
                                  VIEW-AS ALERT-BOX INFO BUTTONS OK.
                          NEXT.
                      END.
             END.
    END CASE.

END.

PROCEDURE pi_verifica_arquivos.

    DEF VAR aux_cdconven AS CHAR    NO-UNDO.

    EMPTY TEMP-TABLE tt-verarqui.

    IF   glb_cdcooper <> 3 THEN 
         DO:
             /*** Arquivos DEB558 ***/
             ASSIGN aux_tparquiv = "DEB558 - BASE"
                    aux_cdprogra = "crps346"
                    aux_cdrelato = "291"
                    aux_posidata = 182
                    aux_nmdbanco = 'BB'. 
                
             RUN pi_busca_convenio(INPUT 346,
                                   OUTPUT aux_cdconven).
             ASSIGN aux_nmarquiv = "/usr/coop/" + lc(crapcop.dsdircop) 
                                   + "/compbb/deb558*" + aux_cdconven + "*".
                                    
             RUN pi_lista_arquivos.
    
                
             ASSIGN aux_tparquiv = "DEB558 - ITG"
                    aux_cdprogra = "crps444"
                    aux_cdrelato = "414"
                    aux_posidata = 182
                    aux_nmdbanco = 'BB'.
    
             RUN pi_busca_convenio(INPUT 444,
                                   OUTPUT aux_cdconven).

             ASSIGN aux_nmarquiv = "/usr/coop/" + lc(crapcop.dsdircop) 
                                   + "/compbb/deb558*" + aux_cdconven + "*".
             RUN pi_lista_arquivos.
            
                
             /*** Arquivos DNR259 ***/
             ASSIGN aux_nmarquiv = "/usr/coop/" + lc(crapcop.dsdircop) 
                                   + "/compbb/dnr259*"
                    aux_tparquiv = "DNR259"
                    aux_cdprogra = "crps360"
                    aux_cdrelato = "310,309"
                    aux_posidata = 06
                    aux_nmdbanco = 'BB'.
                       
             RUN pi_lista_arquivos.
                
                
             /*** Arquivos IED241 ***/
             ASSIGN aux_nmarquiv = "/usr/coop/" + lc(crapcop.dsdircop) 
                                   + "/compbb/ied241*"
                    aux_tparquiv = "IED241"
                    aux_cdprogra = "crps375"
                    aux_cdrelato = "325"
                    aux_posidata = 144
                    aux_nmdbanco = 'BB'.
                       
             RUN pi_lista_arquivos.            
            
                
             /*** Arquivos 1*.RT* ***/
             ASSIGN aux_nmarquiv = "/usr/coop/" + lc(crapcop.dsdircop) 
                                   + "/integra/1*.RT*"
                    aux_tparquiv = "1*.RT*"
                    aux_cdprogra = "crps250"
                    aux_cdrelato = "203"
                    aux_posidata = 70
                    aux_nmdbanco = 'BANCOOB'.

             RUN pi_lista_arquivos.
                
             /*** Arquivos 3*.RT* ***/
             ASSIGN aux_nmarquiv = "/usr/coop/" + lc(crapcop.dsdircop) 
                                   + "/integra/3*.RT*"
                    aux_tparquiv = "3*.RT*"
                    aux_cdprogra = "crps252"
                    aux_cdrelato = "205"
                    aux_posidata = 35
                    aux_nmdbanco = 'BANCOOB'.
                       
             RUN pi_lista_arquivos.
        
                
             /*** Arquivos 1*.DV* ***/
             ASSIGN aux_nmarquiv = "/usr/coop/" + lc(crapcop.dsdircop) 
                                   + "/integra/1*DV1"
                    aux_tparquiv = "1*.DV*"
                    aux_cdprogra = "crps327"
                    aux_cdrelato = "276,277"
                    aux_posidata = 70
                    aux_nmdbanco = 'BANCOOB'.
                       
             RUN pi_lista_arquivos.
        
     
             ASSIGN aux_nmarquiv = "/usr/coop/" + lc(crapcop.dsdircop) 
                                   + "/integra/1*DV2"
                    aux_tparquiv = "1*.DV*"
                    aux_cdprogra = "crps327"
                    aux_cdrelato = "276,277"
                    aux_posidata = 70
                    aux_nmdbanco = 'BANCOOB'.
                       
             RUN pi_lista_arquivos.
        
 
             /*** Arquivos 2*.DV* ***/
             ASSIGN aux_nmarquiv = "/usr/coop/" + lc(crapcop.dsdircop) 
                                   + "/integra/2*.DV1"
                    aux_tparquiv = "2*.DV*"
                    aux_cdprogra = "crps496"
                    aux_cdrelato = "466"
                    aux_posidata = 70
                    aux_nmdbanco = 'BANCOOB'.
                       
             RUN pi_lista_arquivos.
        
             ASSIGN aux_nmarquiv = "/usr/coop/" + lc(crapcop.dsdircop) 
                                   + "/integra/2*.DV2"
                    aux_tparquiv = "2*.DV*"
                    aux_cdprogra = "crps496"
                    aux_cdrelato = "466"
                    aux_posidata = 70
                    aux_nmdbanco = 'BANCOOB'.
                      
             RUN pi_lista_arquivos.
        
 
             /*** Arquivos SRABBC ***/
             ASSIGN aux_nmarquiv = "/usr/coop/" + lc(crapcop.dsdircop) 
                                   + "/integra/1*.RET"
                    aux_tparquiv = "SRABBC"
                    aux_cdprogra = "crps533"
                    aux_cdrelato = "526,564"
                    aux_posidata = 70
                    aux_nmdbanco = 'ABBC'.
                       
             RUN pi_lista_arquivos.
                
             
             ASSIGN aux_nmarquiv = "/usr/coop/" + lc(crapcop.dsdircop) 
                                   + "/integra/3*.RET"
                    aux_tparquiv = "SRABBC"
                    aux_cdprogra = "crps534"
                    aux_cdrelato = "527,563"
                    aux_posidata = 35
                    aux_nmdbanco = 'ABBC'.
                       
             RUN pi_lista_arquivos.
                
             
             ASSIGN aux_nmarquiv = "/usr/coop/" + LC(crapcop.dsdircop) 
                                   + "/integra/1*.D*N"
                    aux_tparquiv = "SRABBC"
                    aux_cdprogra = "crps535"
                    aux_cdrelato = "529,530"
                    aux_posidata = 70
                    aux_nmdbanco = 'ABBC'.
                       
             RUN pi_lista_arquivos.
                
                
             ASSIGN aux_nmarquiv = "/usr/coop/" + LC(crapcop.dsdircop) 
                                   + "/integra/2*.DVN"
                    aux_tparquiv = "SRABBC"
                    aux_cdprogra = "crps536"
                    aux_cdrelato = "521"
                    aux_posidata = 70
                    aux_nmdbanco = 'ABBC'.
                       
             RUN pi_lista_arquivos.
                
                
             ASSIGN aux_nmarquiv = "/usr/coop/" + LC(crapcop.dsdircop) 
                                   + "/integra/3*.DVN"
                    aux_tparquiv = "SRABBC"
                    aux_cdprogra = "crps541"
                    aux_cdrelato = "525"
                    aux_posidata = 35
                    aux_nmdbanco = 'ABBC'.
                       
             RUN pi_lista_arquivos.
        
                
             /*** Arquivos CCABBC ***/
             ASSIGN aux_nmarquiv = "/usr/coop/" + LC(crapcop.dsdircop) 
                                   + "/integra/1*.REM"
                    aux_tparquiv = "CCABBC"
                    aux_cdprogra = "crps537"
                    aux_cdrelato = "522"
                    aux_posidata = 70
                    aux_nmdbanco = 'ABBC'.
                       
             RUN pi_lista_arquivos.
                
                
             ASSIGN aux_nmarquiv = "/usr/coop/" + LC(crapcop.dsdircop) 
                                   + "/integra/1*.NAC"
                    aux_tparquiv = "CCABBC"
                    aux_cdprogra = "crps537"
                    aux_cdrelato = "522"
                    aux_posidata = 70
                    aux_nmdbanco = 'ABBC'.
                      
             RUN pi_lista_arquivos.
                
                
             ASSIGN aux_nmarquiv = "/usr/coop/" + LC(crapcop.dsdircop) 
                                   + "/integra/2*.REM"
                    aux_tparquiv = "CCABBC"
                    aux_cdprogra = "crps538"
                    aux_cdrelato = "523"
                    aux_posidata = 70
                    aux_nmdbanco = 'ABBC'.
                       
             RUN pi_lista_arquivos.
                
                
             ASSIGN aux_nmarquiv = "/usr/coop/" + LC(crapcop.dsdircop) 
                                   + "/integra/3*.REM"
                    aux_tparquiv = "CCABBC"
                    aux_cdprogra = "crps539"
                    aux_cdrelato = "524"
                    aux_posidata = 35
                    aux_nmdbanco = 'ABBC'.
                       
             RUN pi_lista_arquivos.
                
                
             ASSIGN aux_nmarquiv = "/usr/coop/" + LC(crapcop.dsdircop) 
                                   + "/integra/1*.REM"
                    aux_tparquiv = "CCABBC"
                    aux_cdprogra = "crps540"
                    aux_cdrelato = "531"
                    aux_posidata = 70
                    aux_nmdbanco = 'ABBC'.
                       
             RUN pi_lista_arquivos.
                
                
             ASSIGN aux_nmarquiv = "/usr/coop/" + LC(crapcop.dsdircop) 
                                   + "/integra/1*.DVD"
                    aux_tparquiv = "CCABBC"
                    aux_cdprogra = "crps540"
                    aux_cdrelato = "531"
                    aux_posidata = 70
                    aux_nmdbanco = 'ABBC'.
                       
             RUN pi_lista_arquivos.  
                
                
             ASSIGN aux_nmarquiv = "/usr/coop/" + LC(crapcop.dsdircop) 
                                   + "/integra/1*.DVT"
                    aux_tparquiv = "CCABBC"
                    aux_cdprogra = "crps540"
                    aux_cdrelato = "531"
                    aux_posidata = 70
                    aux_nmdbanco = 'ABBC'.
                       
             RUN pi_lista_arquivos.


             /*** Exclusivo Transpocred **/
             IF glb_cdcooper = 9 THEN DO:
                 ASSIGN aux_nmarquiv = "/usr/coop/" + LC(crapcop.dsdircop) 
                                       + "/compbb/cbr643*.*"
                        aux_tparquiv = "CBR643"
                        aux_cdprogra = "crps500"
                        aux_cdrelato = "474"
                        aux_posidata = 95
                        aux_nmdbanco = 'BB'.
                           
                 RUN pi_lista_arquivos.
             END.

    END.
    ELSE
         DO:
             /*** Arquivos FACROC ***/
             ASSIGN aux_nmarquiv = "/usr/coop/" + LC(crapcop.dsdircop)
                                   + "/integra/FAC640N9.*"
                    aux_tparquiv = "FAC640"
                    aux_cdprogra = "crps543"
                    aux_cdrelato = "-"
                    aux_posidata = 12
                    aux_nmdbanco = 'CECRED'.
                   
             RUN pi_lista_arquivos.
                
             ASSIGN aux_nmarquiv = "/usr/coop/" + LC(crapcop.dsdircop) 
                                   + "/integra/ROC640N9.*"
                    aux_tparquiv = "ROC640"
                    aux_cdprogra = "crps544"
                    aux_cdrelato = "-"
                    aux_posidata = 12
                    aux_nmdbanco = 'CECRED'.
                   
             RUN pi_lista_arquivos.
                
             ASSIGN aux_nmarquiv = "/usr/coop/" + LC(crapcop.dsdircop) 
                                   + "/integra/R650*.*"
                    aux_tparquiv = "R650"
                    aux_cdprogra = "crps571"
                    aux_cdrelato = "-"
                    aux_posidata = 12
                    aux_nmdbanco = 'CECRED'.
                   
             RUN pi_lista_arquivos.                        
         END.
END PROCEDURE.


PROCEDURE pi_lista_arquivos:

    DEF VAR aux_dtmesdia AS CHAR             NO-UNDO.
    DEF VAR aux_mesrefer AS INT              NO-UNDO.
    DEF VAR aux_nmarqres AS CHAR             NO-UNDO.

    INPUT STREAM str_1 THROUGH VALUE("ls " + aux_nmarquiv + " 2> /dev/null")
          NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
       
       SET STREAM str_1 aux_nmarqimp FORMAT "x(110)" WITH FRAME AA WIDTH 120.   
       ASSIGN aux_datnmarq = "".

       CASE aux_tparquiv:

           WHEN "DEB558 - BASE"   OR
           WHEN "DEB558 - ITG"    OR
           WHEN "IED241"          OR
           WHEN "DNR259"          OR
           WHEN "CBR643"          THEN 
                DO:
                    aux_dtmesdia = SUBSTR(aux_nmarqimp,INDEX(aux_nmarqimp,
                                          ENTRY(3,aux_nmarqimp,".")),6).
                    aux_dtbrowse = TRIM(SUBSTR(aux_dtmesdia,1,2) + "/" +
                                   SUBSTR(aux_dtmesdia,3,2)).  /* DDMM */
                    aux_datnmarq = TRIM(SUBSTR(aux_dtmesdia,1,2) +
                                   SUBSTR(aux_dtmesdia,3,2)).  /* DDMM */

                    RUN pi_compara_datas(INPUT  TRUE,
                                         INPUT  "DDMM", 
                                         OUTPUT ret_flgdatas).
                END.

           WHEN "R650" THEN 
                DO:
                    aux_nmarqres = SUBSTR(aux_nmarqimp,
                                     R-INDEX(aux_nmarqimp,"/") + 1,12).
                    aux_datnmarq = TRIM(TRIM(SUBSTR(aux_nmarqres,7,2) +
                                   SUBSTR(aux_nmarqres,5,2))).  /* MMDD */
                    aux_dtbrowse = TRIM(SUBSTR(aux_nmarqres,5,2) + "/" +
                                   SUBSTR(aux_nmarqres,7,2)).  /* DDMM */

                    RUN pi_compara_datas(INPUT  TRUE,
                                         INPUT  "MMDD",
                                         OUTPUT ret_flgdatas).
                END.

           WHEN "FAC640" OR
           WHEN "ROC640" THEN
                DO:
                    aux_dtbrowse = STRING(DAY(TODAY),"99") + "/" +
                                   STRING(MONTH(TODAY),"99").  /* DDMM */

                    RUN pi_compara_datas(INPUT  FALSE,
                                         INPUT  "MMDD",
                                         OUTPUT ret_flgdatas).
                END.
               

           OTHERWISE 
                DO:
                    aux_nmarqres = SUBSTR(aux_nmarqimp,
                                     R-INDEX(aux_nmarqimp,"/") + 1,12).
                                     
                    CASE SUBSTR(aux_nmarqres,6,1):
                         WHEN "O" THEN aux_mesrefer = 10.
                         WHEN "N" THEN aux_mesrefer = 11.
                         WHEN "D" THEN aux_mesrefer = 12.
                         OTHERWISE aux_mesrefer = INT(SUBSTR(aux_nmarqres,6,1)).
                    END CASE.

                    aux_datnmarq = TRIM(STRING(aux_mesrefer,"99") +
                                   SUBSTR(aux_nmarqres,7,2)). /* MMDD */
                    aux_dtbrowse = TRIM(SUBSTR(aux_nmarqres,7,2) + "/" +
                                   STRING(aux_mesrefer,"99")).  /* DDMM */

                    RUN pi_compara_datas(INPUT  TRUE,
                                         INPUT  "MMDD",
                                         OUTPUT ret_flgdatas).
                END.

       END CASE.

       IF   ret_flgdatas THEN
            aux_dssituac = "OK".
       ELSE
            aux_dssituac = "ERRO".

       RUN pi_busca_permissao.

       DO TRANSACTION:         
          CREATE tt-verarqui.
          ASSIGN tt-verarqui.cdcooper = crapcop.cdcooper
                 tt-verarqui.dsdircop = crapcop.dsdircop
                 tt-verarqui.nmdbanco = aux_nmdbanco
                 tt-verarqui.nmarquiv = aux_tparquiv
                 tt-verarqui.dtarquiv = aux_dtbrowse
                 tt-verarqui.cdprogra = aux_cdprogra
                 tt-verarqui.dspermis = aux_dspermis
                 tt-verarqui.cdrelato = aux_cdrelato
                 tt-verarqui.dssituac = aux_dssituac.
       END.          

    END.  /*  Fim do DO WHILE TRUE  */

    INPUT STREAM str_1 CLOSE.

END PROCEDURE.


PROCEDURE pi_opcao_l:
     
    ASSIGN tel_pesquisa = "".
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE tel_pesquisa WITH FRAME f_opcao_l.
       LEAVE.
    END.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN DO: /* F4 OU FIM */
         NEXT.
    END.    

    ASSIGN aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop + "/log/proc_batch.log".

    IF   SEARCH(aux_nmarqlog) = ?   THEN 
         DO:
             MESSAGE "NAO HA REGISTRO DE LOG PARA ESTA COOPERATIVA!".
             PAUSE 1 NO-MESSAGE.
             RETURN.
         END.


    ASSIGN aux_nomedarq = "log/arquivo_tel1".
            
    IF   TRIM(tel_pesquisa) = ""   THEN 
         UNIX SILENT VALUE("cp " + aux_nmarqlog + " " + aux_nomedarq).
    ELSE 
         UNIX SILENT VALUE ("grep -i '" + tel_pesquisa + "' " + aux_nmarqlog + 
                            " > "   + aux_nomedarq + " 2> /dev/null").

    aux_nmarqlog = aux_nomedarq.
            
    /* Verifica se o arquivo esta vazio e critica */
    INPUT STREAM str_log THROUGH VALUE("wc -m " + aux_nmarqlog + 
                                       " 2> /dev/null") NO-ECHO.

    SET STREAM str_log aux_tamarqui FORMAT "x(30)".

    IF   INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0 THEN
         DO:
             BELL. 
             MESSAGE "Nenhuma ocorrencia encontrada.".
             INPUT STREAM str_log CLOSE.
             NEXT.
         END.

    INPUT STREAM str_log CLOSE.

    RUN fontes/visrel.p (INPUT aux_nmarqlog).

    /* apaga arquivos temporarios */
    IF   aux_nomedarq <> ""   THEN
         UNIX SILENT VALUE ("rm " + aux_nomedarq + " 2> /dev/null").

END PROCEDURE.


PROCEDURE pi_calcula_saldo:
    
    FIND crapdat WHERE crapdat.cdcooper = aux_coopesld NO-LOCK.
    
    FOR EACH crapass WHERE crapass.cdcooper = aux_coopesld 
                           NO-LOCK BREAK BY crapass.cdagenci:

        FIND crapsld WHERE crapsld.cdcooper = aux_coopesld     AND
                           crapsld.nrdconta = crapass.nrdconta 
                           NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapsld   THEN
             NEXT.

        ASSIGN rel_vlsddisp = (crapsld.vlsddisp + crapsld.vlsdbloq +
                               crapsld.vlsdblpr + crapsld.vlsdblfp)
               rel_qtcmpbcb = 0
               rel_vlcmpbcb = 0
               rel_vllimcre = (crapass.vllimcre * -1).
        
         
         /*  Leitura dos lancamentos do dia  */
         FIND FIRST craplcm WHERE craplcm.cdcooper = aux_coopesld       AND
                                  craplcm.nrdconta = crapsld.nrdconta   AND
                                  craplcm.dtmvtolt = crapdat.dtmvtoan   AND
                           CAN-DO(hst_int_dia,STRING(craplcm.cdhistor)) AND
                                  craplcm.dtrefere = crapdat.dtmvtoan
                                  NO-LOCK NO-ERROR.
                               
         IF   NOT AVAILABLE craplcm THEN 
              NEXT.

         FIND FIRST crablcm WHERE crablcm.cdcooper = aux_coopesld       AND
                                  crablcm.nrdconta = crapsld.nrdconta   AND
                                  crablcm.dtmvtolt = crapdat.dtmvtolt   AND
                           CAN-DO(hst_int_apos,STRING(craplcm.cdhistor))
                                  USE-INDEX craplcm2 NO-LOCK NO-ERROR.
                               
         IF   AVAILABLE crablcm THEN 
              NEXT.

         IF   rel_vlsddisp < rel_vllimcre THEN
              DO:
                  DISP crapass.cdagenci
                       crapass.nrdconta
                       crapass.nmprimtl   FORMAT "x(30)"
                       rel_vlsddisp       FORMAT "zzz,zzz,zz9.99-"
                                          COLUMN-lABEL "Disponivel"
                      (rel_vllimcre * -1) COLUMN-LABEL "Limite"
                       WITH TITLE "Relacao de Cheques a Serem Devolvidos\n\n".
             END.
     END.
END.


PROCEDURE pi_compara_datas:
/*********
DETALHES DOS PARAMETROS:
    - 1 Indica se ira ou nao verificar a data no nome do arquivo
    - 2 Indica o formato da data
    - 3 Indica a situacao das verificacoes da data FALSE = "ERRO", TRUE = "OK"
*******/
    DEF INPUT  PARAM par_vrfnmarq AS LOG                     NO-UNDO.
    DEF INPUT  PARAM par_dataform AS CHAR                    NO-UNDO.
    DEF OUTPUT PARAM ret_flgdatas AS LOG                     NO-UNDO.

    DEF VAR aux_dtmvtoan AS CHAR                             NO-UNDO.

    IF  par_dataform = "MMDD" THEN
        aux_dtmvtoan = STRING(STRING(MONTH(crapdat.dtmvtoan),"99") +
                              STRING(  DAY(crapdat.dtmvtoan),"99") ).
    ELSE
        aux_dtmvtoan = STRING(STRING(DAY  (crapdat.dtmvtoan),"99") +
                              STRING(MONTH(crapdat.dtmvtoan),"99") ).
                              
   INPUT STREAM str_2 THROUGH VALUE("head " + aux_nmarqimp) NO-ECHO. 

   SET STREAM  str_2 aux_setlinha WITH FRAME AA WIDTH 255 . 

   INPUT STREAM str_2 CLOSE.

   ASSIGN ret_flgdatas = FALSE.
   
   /***** Validacoes da data ****/

   /* 1 - Compara a data no nome do arquivo com a data do cabecalho */
   IF  par_vrfnmarq THEN
       ret_flgdatas = (aux_datnmarq = SUBSTR(aux_setlinha,aux_posidata,4)).

   
   /*  2 - Se passou da primeira validacao,                            */
   /*      verifica se a data do cabecalho eh igual a data do dtmvtoan */
   IF ret_flgdatas THEN
      ret_flgdatas = (aux_dtmvtoan = SUBSTR(aux_setlinha,aux_posidata,4) ).

END PROCEDURE.


PROCEDURE pi_busca_permissao:   

   INPUT STREAM str_permis THROUGH VALUE("ls -l " + aux_nmarquiv +
                                         " 2> /dev/null") NO-ECHO.
                                                               
   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    
      SET STREAM str_permis aux_arqpermi WITH FRAME AA WIDTH 255 .

      aux_dspermis = ENTRY(1,~aux_arqpermi,"  ").
                                        
   END.  /*  Fim do DO WHILE TRUE  */
            
   INPUT STREAM str_permis CLOSE.

END PROCEDURE.



PROCEDURE pi_busca_convenio:

   DEF INPUT  PARAM par_cdprogra AS INT       NO-UNDO.
   DEF OUTPUT PARAM ret_cdconven AS CHAR     NO-UNDO.

   FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                      craptab.nmsistem = "CRED"           AND
                      craptab.tptabela = "GENERI"         AND
                      craptab.cdempres = 0                AND
                      craptab.cdacesso = "COMPEARQBB"     AND
                      craptab.tpregist = par_cdprogra 
                      NO-LOCK NO-ERROR.

   IF   AVAIL craptab THEN
        ret_cdconven = SUBSTR(craptab.dstextab,1,9).
   ELSE
        ret_cdconven = "".     

END PROCEDURE.

/* .......................................................................... */
