/*..............................................................................
   Programa: fontes/crps496.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Outubro/2007                 Ultima atualizacao:  24/09/2009    

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Recebimento de arquivos de devolucao de titulos do BANCOOB -
               Nossa Remessa. Emite relatorio crrl466.

   Alteracoes: 
               16/10/2007 -  Incluido campo  tipo de captura - listar no                                    relatorio 466/496 (Gabriel). 
               18/10/2007 -  Nao emissao de relatorios se nao houver movimento
                             (Gabriel).
                             
               24/09/2009 -  Incluida mensagem no log/proc_batch.log de 
                             integracao de arquivo (Diego).
                              
.............................................................................*/

{ includes/var_batch.i}   

DEF STREAM str_1.
DEF STREAM str_2.

DEF TEMP-TABLE w_relato  
    FIELD cddbanco AS INT  FORMAT "999"
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD vldocmto AS DEC  FORMAT "9999999999"
    FIELD cdmotivo AS INT  FORMAT "99"
    FIELD vltitulo AS DEC  FORMAT "999999999999"
    FIELD linhadig AS CHAR FORMAT "x(44)"
    FIELD tpcaptur AS CHAR FORMAT "x(1)". 


DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqdat AS CHAR                                           NO-UNDO.

DEF VAR aux_cddbanco AS INT  FORMAT "999"                              NO-UNDO.
DEF VAR aux_dtmvtolt AS DATE FORMAT "99/99/9999"                       NO-UNDO.
DEF VAR aux_vldocmto AS DEC  FORMAT "9999999999"                       NO-UNDO.
DEF VAR aux_vltitulo AS DEC  FORMAT "999999999999"                     NO-UNDO.
DEF VAR aux_cdmotivo AS INT  FORMAT "99"                               NO-UNDO.
DEF VAR aux_linhadig AS CHAR FORMAT "x(44)"                            NO-UNDO.
DEF VAR aux_tpcaptur AS CHAR FORMAT "x(1)"                             NO-UNDO.
DEF VAR aux_nmarqrel AS CHAR                                           NO-UNDO.
 

DEF VAR aux_dscaptur AS CHAR FORMAT "x(08)"                            NO-UNDO.

DEF VAR rel_nrmodulo AS INTE    FORMAT "9"                             NO-UNDO.
                
DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                         NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5                NO-UNDO.

DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                INIT ["DEP. A VISTA   ","CAPITAL        ",
                                      "EMPRESTIMOS    ","DIGITACAO      ",
                                      "GENERICO       "]               NO-UNDO.

FORM w_relato.cddbanco    AT   1   LABEL "Banco"
     w_relato.dtmvtolt    AT   7   LABEL "Data"
     w_relato.vldocmto    AT  18   LABEL "Valor Docmto"
     w_relato.vltitulo    AT  32   LABEL "Valor Titulo"
     w_relato.cdmotivo    AT  48   LABEL "Motivo"
     w_relato.linhadig    AT  55   LABEL "Linha Digitavel"
     aux_dscaptur         AT  100  LABEL "Captura"
     WITH DOWN NO-LABELS WIDTH 132 FRAME  f_relatorio.

ASSIGN glb_cdprogra = "crps496"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.    

IF  glb_cdcritic > 0  THEN
    DO:
        RUN fontes/fimprg.p.
        RETURN.
    END.
                     
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop  THEN
    DO:
        ASSIGN glb_cdcritic = 651.
        RUN fontes/critic.p.
        RUN fontes/fimprg.p.
        RETURN.
    END.

ASSIGN aux_nmarquiv =  "/usr/coop/" + crapcop.dsdircop +
                       "/integra/" + "2" +  STRING(crapcop.cdagebcb) +
                       "*.DV*".       

    
INPUT STREAM str_1 
             THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.
        
                                           
DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
                    
    SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .
                                  
    ASSIGN aux_nmarqdat = aux_nmarquiv.
    
    ASSIGN glb_cdcritic = 219.
    RUN fontes/critic.p.
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + glb_cdprogra
                      + "' --> '" + glb_dscritic + "' --> '" + aux_nmarqdat
                      + " >> log/proc_batch.log").

    ASSIGN glb_cdcritic = 0.
     
    INPUT STREAM str_2 FROM VALUE(aux_nmarqdat) NO-ECHO.
       
    /* Pula Header */ 
    IMPORT STREAM str_2 UNFORMATTED aux_setlinha.
        
    IF SUBSTR(aux_setlinha,48,6) <> "DVC615" THEN
       DO:
           ASSIGN glb_cdcritic = 173.
           RUN fontes/critic.p.
                                                  
           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                             " - " + glb_cdprogra + "' --> '"  +
                             glb_dscritic + " >> log/proc_batch.log").   
           
           RUN fontes/fimprg.p.
           RETURN.       
       END.
    
    DO  WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

        IMPORT STREAM str_2 UNFORMATTED aux_setlinha.
       
        /*  Verifica se eh final do Arquivo  */
        IF   INT(SUBSTR(aux_setlinha,1,1)) = 9  THEN
             LEAVE.
        
        ASSIGN aux_cddbanco =  INT(SUBSTR(aux_setlinha,1,3)) 
               aux_vldocmto =  (DEC(SUBSTR(aux_setlinha,10,10)) / 100)
               aux_cdmotivo =  INT(SUBSTR(aux_setlinha,51,2))
               aux_dtmvtolt =  DATE(SUBSTR(aux_setlinha,77,2) +
                                    SUBSTR(aux_setlinha,75,2) + 
                                    SUBSTR(aux_setlinha,71,4))
               aux_vltitulo =  (DEC(SUBSTR(aux_setlinha,85,12)) / 100)
               aux_linhadig =  SUBSTR(aux_setlinha,1,44)
               aux_tpcaptur =  SUBSTR(aux_setlinha,50,1). 
               
        CREATE  w_relato.
        ASSIGN  w_relato.cddbanco = aux_cddbanco
                w_relato.dtmvtolt = aux_dtmvtolt
                w_relato.vldocmto = aux_vldocmto 
                w_relato.vltitulo = aux_vltitulo
                w_relato.cdmotivo = aux_cdmotivo
                w_relato.dtmvtolt = aux_dtmvtolt
                w_relato.linhadig = aux_linhadig
                w_relato.tpcaptur = aux_tpcaptur.
                
          
    END. /** Fim DO WHILE TRUE **/
    
    INPUT STREAM str_2 CLOSE.
    
    UNIX SILENT VALUE("mv " + aux_nmarqdat + " salvar").
     
    UNIX SILENT VALUE("rm " + aux_nmarqdat + " 2> /dev/null").
    
    ASSIGN glb_cdcritic = 190.
    RUN fontes/critic.p.
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + 
                      glb_cdprogra + "' --> '" + glb_dscritic + "' --> '" +
                      aux_nmarqdat + " >> log/proc_batch.log").
    

END. /*** Fim do DO WHILE TRUE ***/        
         
INPUT STREAM str_1 CLOSE.


/***** RELATORIO *****/            

FIND FIRST w_relato NO-LOCK NO-ERROR.

IF   AVAIL w_relato  THEN
     DO:

       ASSIGN aux_nmarqrel = "rl/crrl466.lst".            
                       
       /*** Monta o cabecalho ***/
       { includes/cabrel132_1.i }     
                         
       OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) PAGED PAGE-SIZE 84.
                                    
       VIEW STREAM str_1 FRAME f_cabrel132_1.
     
       FOR  EACH w_relato:
    
   
           IF  w_relato.tpcaptur = '1'THEN 
               ASSIGN   aux_dscaptur = "CAIXA".
           ELSE
               IF  w_relato.tpcaptur = '2' THEN
                   ASSIGN aux_dscaptur = "INTERNET".
               ELSE
                   ASSIGN aux_dscaptur = "OUTROS".
            
           DISPLAY STREAM str_1  
                   w_relato.cddbanco
                   w_relato.dtmvtolt
                   w_relato.vldocmto FORMAT "zz,zzz,zz9.99"
                   w_relato.vltitulo FORMAT "zzzz,zzz,zz9.99"
                   w_relato.cdmotivo
                   w_relato.linhadig
                   aux_dscaptur
                   WITH DOWN FRAME f_relatorio.
               
           DOWN WITH FRAME f_relatorio.
  
       END.

       OUTPUT STREAM str_1 CLOSE.

       ASSIGN glb_nrcopias = 1
              glb_nmformul = "132col"
              glb_nmarqimp = aux_nmarqrel.
                      
       RUN fontes/imprim.p.  

     END.

RUN fontes/fimprg.p.                   
        
..............................................................................*/
