/* ANTES DE TESTAR O PROGRAMA COMENTAR A includes/envia_dados_postmix.i */
/*.............................................................................

   Programa: Fontes/upload.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : HENRIQUE
   Data    : MARCO/2011                          Ultima Atualizacao: 16/04/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Enviar arquivos para a PostMix
   
   Alteracoes: 16/04/2012 - Fonte substituido por uploadp.p (Tiago). 
..............................................................................*/

{ includes/var_online.i }

{ includes/var_informativos.i "NEW" }
{ includes/gg0000.i }

DEF STREAM str_1.
  
DEF TEMP-TABLE w-arq NO-UNDO
    FIELD nrarquiv AS INT
    FIELD nmarquiv AS CHAR
    FIELD dsarquiv AS CHAR.

DEF QUERY upload-q FOR w-arq.

DEF BROWSE upload-b QUERY upload-q
    DISP w-arq.nrarquiv FORMAT "zz9"
         w-arq.dsarquiv FORMAT "x(60)"
    WITH NO-LABEL 12 DOWN NO-BOX.
    
DEF VAR aux_nmarquiv AS CHAR    FORMAT "x(50)"                      NO-UNDO.
DEF VAR aux_confirma AS CHAR    FORMAT "!(1)"                       NO-UNDO.
DEF VAR aux_statusgn AS LOGI                                        NO-UNDO.
DEF VAR aux_msgenvio AS CHAR                                        NO-UNDO.

FORM aux_msgenvio FORMAT "x(55)"
     WITH ROW 10 CENTERED OVERLAY WIDTH 58 NO-LABEL
     TITLE " Enviando... " FRAME f_envio.

FORM SPACE (1) 
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE " Envio de arquivos PostMix "
     FRAME f_moldura.

VIEW FRAME f_moldura.
PAUSE(0).

FORM upload-b
    HELP "Tecle <F4> ou END para continuar"
    WITH NO-LABEL ROW 6 OVERLAY WIDTH 77 CENTERED 
    TITLE " Lista de arquivos " FRAME f_upload.
    

ON END-ERROR OF upload-b DO:
    DO WHILE TRUE:
        FIND FIRST w-arq NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL w-arq THEN
            LEAVE.
        ASSIGN aux_confirma = "N".

        MESSAGE "Deseja enviar os arquivos?" UPDATE aux_confirma.
    
        IF  aux_confirma = "S" THEN
            DO:
                FOR EACH w-arq NO-LOCK:
                            
                    ASSIGN aux_msgenvio = "Enviando arquivo " + w-arq.nmarquiv
                           aux_nmdatspt = w-arq.nmarquiv.
                    DISP aux_msgenvio WITH FRAME f_envio.   
                    
                    { includes/envia_dados_postmix.i &AGUARDA="SIM" }

                    ASSIGN aux_msgenvio = "Arquivo enviado " + w-arq.nmarquiv.
                   
                    DISP aux_msgenvio WITH FRAME f_envio.
                    PAUSE 0.
                   
                    UNIX SILENT VALUE ("rm -f " +  w-arq.dsarquiv + 
                                       " 2> /dev/null").
                                       
                    HIDE FRAME f_envio.

                END.
                
                MESSAGE "Arquivos enviados!" + CHR(10) + "Verifique o log."
                        VIEW-AS ALERT-BOX.
                LEAVE.
            END.
        ELSE
        IF  aux_confirma = "N" THEN
            DO:
                MESSAGE "Arquivos nao enviados." VIEW-AS ALERT-BOX.
                LEAVE.
            END.

        NEXT.
    END. /* Fim DO WHILE TRUE */
END. /* Fim do evento END-ERROR */
                          
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK.

DO WHILE TRUE:

    RUN fontes/inicia.p.
    
    EMPTY TEMP-TABLE w-arq.

    ASSIGN aux_nrarquiv = 0.
    
    /* VERIFICA OS ARQUIVOS E CRIA TEMP-TABLE */
    /* Pega os nomes dos arquivos na pasta */
    INPUT STREAM str_1 THROUGH VALUE("ll /usr/coop/cecred/postmix/ | awk "  +
                                      chr(123) + "'print $9'" + chr(125) +
                                      " 2> /dev/null").
                                      
    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
        
        IMPORT STREAM str_1 UNFORMATTED aux_nmarquiv.

        IF TRIM(aux_nmarquiv) <> "" AND 
           SUBSTRING(TRIM(aux_nmarquiv), LENGTH(aux_nmarquiv) - 2, 3) = "dat" 
           THEN
        DO:
            CREATE w-arq.
            ASSIGN aux_nrarquiv   = aux_nrarquiv + 1
                   w-arq.nrarquiv = aux_nrarquiv
                   w-arq.nmarquiv = "postmix/" + aux_nmarquiv
                   w-arq.dsarquiv = "/usr/coop/cecred/postmix/" + aux_nmarquiv.
        END.
    
    END. /* Fim DO WHILE TRUE */
    
    /* FIM DA CRIACAO DA TEMP-TABLE */
    
    OPEN QUERY upload-q FOR EACH w-arq.
    
    ENABLE upload-b WITH FRAME f_upload.

    WAIT-FOR END-ERROR OF upload-b.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "UPLOAD"  THEN
                DO:
                    HIDE FRAME f_upload.
                    HIDE FRAME f_moldura.
                    ASSIGN aux_statusgn = f_verconexaogener().
                    IF  aux_statusgn THEN
                        RUN p_desconectagener.
                    RETURN.
                END.
        END.    
END. /* END WHILE TRUE */
/*............................................................................*/

