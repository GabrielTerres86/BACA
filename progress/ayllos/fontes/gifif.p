/*.............................................................................

   Programa: Fontes/gifif.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : HENRIQUE
   Data    : MARCO/2011                     Ultima Atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gera arquivo para a contabilidade.
..............................................................................*/

{ includes/var_online.i }

DEF STREAM str_1.

DEF VAR tel_dsdopcao    AS CHAR FORMAT "!(1)"                       NO-UNDO.
DEF VAR tel_dsdtrela    AS CHAR FORMAT "xx/xxxx"                    NO-UNDO.

DEF VAR aux_nmarquiv    AS CHAR                                     NO-UNDO.
DEF VAR aux_nmarqcon    AS CHAR                                     NO-UNDO.
DEF VAR aux_dtrelato    AS DATE                                     NO-UNDO.
DEF VAR aux_linhaarq    AS CHAR                                     NO-UNDO.
DEF VAR aux_dscritic    AS CHAR FORMAT "x(40)"                      NO-UNDO.

DEF VAR aux_nrdocnpj    AS CHAR FORMAT "x(8)"  EXTENT 2             NO-UNDO.
DEF VAR aux_nmextcop    AS CHAR FORMAT "x(100)"                     NO-UNDO.
DEF VAR aux_dsendcop    AS CHAR FORMAT "x(100)"                     NO-UNDO.
DEF VAR aux_nrinsmun    AS CHAR FORMAT "x(15)"                      NO-UNDO.

FORM SPACE (1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 
     TITLE "Geracao de arquivos prefeitura de Florianopolis" FRAME f_moldura.

FORM tel_dsdopcao LABEL "Opcao" AT 2 AUTO-RETURN HELP "G - geracao de arquivo"
                  VALIDATE (CAN-DO("G", tel_dsdopcao), "014 - Opcao Errada.")
     tel_dsdtrela LABEL "Mes/Ano" AT 14
     WITH OVERLAY ROW 6 NO-BOX SIDE-LABELS COLUMN 2 FRAME f_opcao.

FORM "Gerando arquivos..."
     SKIP
     aux_nmarquiv  FORMAT "x(50)"
     SKIP
     aux_nmarqcon  FORMAT "x(50)"
     WITH OVERLAY CENTERED ROW 12 NO-LABELS FRAME f_arquivos.
 
VIEW FRAME f_moldura.

PAUSE 0.

DO WHILE TRUE:

    RUN fontes/inicia.p.
    
    ASSIGN  tel_dsdopcao = "G"
            aux_dtrelato = glb_dtmvtolt - DAY(glb_dtmvtolt)
            tel_dsdtrela = STRING(MONTH(aux_dtrelato), "99") + 
                           STRING(YEAR(aux_dtrelato), "9999").
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE tel_dsdopcao WITH FRAME f_opcao.
    
        DO WHILE TRUE:
    
            UPDATE tel_dsdtrela WITH FRAME f_opcao.
        
            ASSIGN aux_dtrelato = DATE(INT(SUBSTRING(tel_dsdtrela,1,2)),01,
                                      INT(SUBSTRING(tel_dsdtrela,3,4)))NO-ERROR.
        
            IF  ERROR-STATUS:ERROR THEN
                DO:
                    MESSAGE "013 - Data invalida".
                    NEXT.
                END.
            
            LEAVE.
        END.
        
        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN     /*   F4 OU FIM   */
            DO:
               RUN fontes/novatela.p.
               IF  CAPS(glb_nmdatela) <> "GIFIF"  THEN
                   DO:
                      HIDE FRAME f_opcao.
                      HIDE FRAME f_moldura.
                      RETURN.
                   END.
               NEXT. 
            END. 
    
    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
        
    IF  AVAIL crapcop THEN
        DO:
        
            ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/salvar/" +
                                  STRING(YEAR(aux_dtrelato),"9999") + 
                                  STRING(MONTH(aux_dtrelato),"99")  +
                                  "GIFIF.txt".
                   aux_nmarqcon = "/micros/" + crapcop.dsdircop + "/contab/" + 
                                  STRING(YEAR(aux_dtrelato),"9999") +
                                  STRING(MONTH(aux_dtrelato),"99")  +
                                  "GIFIF.txt".

            DISP aux_nmarquiv WITH FRAME f_arquivos.
            
            PAUSE 0.
            
            OUTPUT STREAM str_1 TO VALUE (aux_nmarquiv).    

            /* PRIMEIRA LINHA */
            IF  crapcop.nrdocnpj > 0 THEN
                DO:
                    ASSIGN aux_nrdocnpj[1] = SUBSTRING(STRING(crapcop.nrdocnpj)
                                          ,1,7).
                END.
            ELSE
                DO:
                    ASSIGN aux_dscritic = "A cooperativa nao possui" +
                                          "CNPJ cadastrado".
                    MESSAGE aux_dscritic VIEW-AS ALERT-BOX.
                    NEXT.
                END.
                
            IF  crapcop.nmextcop <> "" THEN
                DO:
                    ASSIGN aux_nmextcop = crapcop.nmextcop.
                END.
            ELSE
                DO:
                    ASSIGN aux_dscritic = "A cooperativa nao possui razao" +
                                          " social cadastrada".
                    MESSAGE aux_dscritic VIEW-AS ALERT-BOX.
                    NEXT.
                END.
                
            IF  crapcop.nrdocnpj > 0 THEN
                DO:
                    ASSIGN aux_nrdocnpj[2] = STRING(crapcop.nrdocnpj)
                           aux_nrdocnpj[2] = SUBSTRING(aux_nrdocnpj[2],
                                             LENGTH(aux_nrdocnpj[2]) - 5,6).
                END.
            ELSE
                DO:
                    ASSIGN aux_dscritic = "A cooperativa nao possui" +
                                          "CNPJ cadastrado".
                    MESSAGE aux_dscritic VIEW-AS ALERT-BOX.
                    NEXT.
                END.
        
            ASSIGN aux_linhaarq = "000001|" + "0000|0" + 
                                  aux_nrdocnpj[1] +
                                  "|" + aux_nmextcop + "|R|" + 
                                  "4205407|" +
                                  STRING(YEAR(aux_dtrelato),"9999") +
                                  STRING(MONTH(aux_dtrelato),"99")  +
                                  "|" + 
                                  STRING(YEAR(aux_dtrelato),"9999") +
                                  STRING(MONTH(aux_dtrelato),"99")  +
                                  "|2|1||1|" + aux_nrdocnpj[2].

            PUT STREAM str_1 UNFORMAT aux_linhaarq SKIP.
            /* Fim - PRIMEIRA LINHA */

            /* SEGUNDA LINHA */
            IF  crapcop.nrinsmun <> 0 THEN
                DO:
                    ASSIGN  aux_nrinsmun = STRING(crapcop.nrinsmun).
                END.
            ELSE
                DO:
                    ASSIGN aux_dscritic = "A cooperativa nao possui" +
                                          "Inscricao Municipal cadastrada".
                    MESSAGE aux_dscritic VIEW-AS ALERT-BOX.
                    NEXT.
                END.

            IF  crapcop.nrdocnpj > 0 THEN
                DO:
                    ASSIGN aux_nrdocnpj[1] = STRING(crapcop.nrdocnpj)
                           aux_nrdocnpj[1] = SUBSTRING(aux_nrdocnpj[1],
                                             LENGTH(aux_nrdocnpj[1]) - 5,6).
                END.
            ELSE
                DO:
                    ASSIGN aux_dscritic = "A cooperativa nao possui" +
                                          "CNPJ cadastrado".
                    MESSAGE aux_dscritic VIEW-AS ALERT-BOX.
                    NEXT.
                END.
        
            IF  crapcop.dsendcop <> "" AND
                crapcop.nrendcop <> 0  AND
                crapcop.nmbairro <> "" THEN
                DO:
                    
                    ASSIGN aux_dsendcop = crapcop.dsendcop  + " " +
                                   STRING(crapcop.nrendcop) + " " +
                                   crapcop.nmbairro.
                END.
            ELSE                   
                DO:
                    ASSIGN aux_dscritic = "A cooperativa nao possui" +
                                          "endereco cadastrado".
                    MESSAGE aux_dscritic VIEW-AS ALERT-BOX.
                    NEXT.
                END.
                
           ASSIGN aux_linhaarq = "000002|" + "0400|" + aux_nrinsmun +
                                 "|1|" + aux_nrdocnpj[1] +
                                 "|1|" + aux_dsendcop + "|" + aux_nrdocnpj[1] +
                                 "|4205407|2|" + "||".
           
           PUT STREAM str_1 UNFORMAT aux_linhaarq SKIP.
           /* FIM - SEGUNDA LINHA */

        END. /* end if avail */
        
    OUTPUT STREAM str_1 CLOSE.

    DISP aux_nmarqcon WITH FRAME f_arquivos.

    UNIX SILENT VALUE ("cp " + aux_nmarquiv + " " + aux_nmarqcon).

    PAUSE 1 MESSAGE "Aguarde...".
    MESSAGE "Arquivos gerados com sucesso!" VIEW-AS ALERT-BOX.
    HIDE FRAME f_arquivos.
    PAUSE 0.

END. /* END WHILE TRUE */

