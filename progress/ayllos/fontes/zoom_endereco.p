/*.............................................................................

   Programa: fontes/zoom_endereco.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : André Socoloski (DB1)
   Data    : Abril/2011                   Ultima alteracao: 04/04/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela de enderecos 

   Alteracoes:
   
   04/04/2012 - Adicionado idorigem em chamada da proc. busca-endereco em
                BO 38 . (Jorge)
............................................................................ */
{ sistema/generico/includes/b1wgen0038tt.i }
{ includes/var_online.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_internet.i }

DEF  INPUT PARAM par_nrceplog AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR tt-endereco.                           
                                                                        
DEF VAR tel_dsendere AS CHAR FORMAT "X(40)" LABEL "Endereco"           NO-UNDO.
DEF VAR tel_nmcidade AS CHAR FORMAT "X(25)" LABEL "Cidade  "           NO-UNDO.
DEF VAR tel_cdufende AS CHAR FORMAT "!(2)"  LABEL "UF"                 NO-UNDO.
DEF VAR tel_dscmpend AS CHAR FORMAT "X(61)" EXTENT 2                   NO-UNDO.
DEF VAR tel_dsoricad AS CHAR FORMAT "x(40)" LABEL "Origem"             NO-UNDO.
                                                                        
DEF VAR p_cddopcao   AS CHAR INIT "I"                                  NO-UNDO.
                                                                        
DEF VAR p_cduflogr   AS CHAR INIT ""                                   NO-UNDO.
DEF VAR p_dscmplog   AS CHAR EXTENT 2 INIT ""                          NO-UNDO.
DEF VAR p_dstiplog   AS CHAR INIT ""                                   NO-UNDO.
DEF VAR p_nmresbai   AS CHAR INIT ""                                   NO-UNDO.
DEF VAR p_nmrescid   AS CHAR INIT ""                                   NO-UNDO.
DEF VAR p_nmreslog   AS CHAR INIT ""                                   NO-UNDO.
DEF VAR p_nrceplog   AS INTE INIT ""                                   NO-UNDO.

DEF VAR aux_nrcepend AS INTE                                           NO-UNDO.
DEF VAR aux_dsendere AS CHAR                                           NO-UNDO.
DEF VAR aux_dscmpend AS CHAR                                           NO-UNDO.
DEF VAR aux_dsendcmp AS CHAR                                           NO-UNDO. 
DEF VAR aux_cdufende AS CHAR                                           NO-UNDO. 
DEF VAR aux_nmbairro AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidade AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0038 AS HANDLE                                         NO-UNDO.

DEF QUERY q_endereco FOR tt-endereco.

DEF BROWSE b_endereco QUERY q_endereco
    DISP tt-endereco.nrcepend LABEL "CEP"
         tt-endereco.dsendere LABEL "Endereco" WIDTH 43
         tt-endereco.nmbairro LABEL "Bairro"   WIDTH 30
         tt-endereco.nmcidade LABEL "Cidade"
         tt-endereco.cdufende LABEL "UF"
    WITH 9 DOWN NO-BOX CENTERED WIDTH 76.


FORM b_endereco HELP "Escolha com as setas, pgant, pgseg e tecle <Entra>"
     SKIP
     "-------------------------------------" AT 3
     SPACE(0)
     "-------------------------------------"
     tel_dscmpend[1] AT 3 LABEL "Complemento" SKIP
     tel_dscmpend[2] AT 16 NO-LABEL SKIP
     tel_dsoricad    AT 8 LABEL "Origem"
     WITH ROW 5 COL 1 WIDTH 80 OVERLAY CENTERED SIDE-LABELS TITLE " Enderecos " 
          FRAME f_endereco.

FORM tel_dsendere AT 02
     SKIP
     tel_nmcidade AT 02
     tel_cdufende AT 46
     WITH ROW 11 COL 2 WIDTH 54 OVERLAY CENTERED SIDE-LABELS 
          TITLE " Pesquisar Endereco " FRAME f_pesquisa.

FORM SKIP(1)
     p_nrceplog AT 03 FORMAT "99999,999" LABEL "        CEP" 
                VALIDATE(p_nrceplog <> 0,"Informe o CEP")
                HELP "Informe o cep do endereco" 
     SKIP
     p_dstiplog AT 03 FORMAT "x(25)" LABEL "       Tipo"
                VALIDATE(p_dstiplog <> "","Informe o tipo do logradouro")
                HELP  "Informe o tipo do logradouro (Ex: Rua, Avenida, Rodovia)"
     SKIP
     p_nmreslog AT 03 FORMAT "x(40)" LABEL " Logradouro"
                VALIDATE(p_nmreslog <> "","Informe o logradouro")
                HELP  "Informe o logradouro"
     SKIP
     p_dscmplog[1] AT 03 FORMAT "x(45)" LABEL "Complemento"
                HELP "Informe o complemento do logradouro"
     SKIP
     p_dscmplog[2] AT 16 FORMAT "x(45)" NO-LABEL 
                HELP "Informe o complemento do logradouro"
     SKIP
     p_nmresbai AT 03 FORMAT "x(40)" LABEL "     Bairro"
                VALIDATE(p_nmresbai <> "","Informe o bairro")
                HELP  "Informe o bairro"
     SKIP
     p_nmrescid AT 03 FORMAT "x(25)" LABEL "     Cidade"
                VALIDATE(p_nmrescid <> "","Informe a cidade")
                HELP  "Informe a cidade"
     SKIP
     p_cduflogr AT 03 FORMAT "!(2)"  LABEL "         UF"
                VALIDATE(p_cduflogr <> "","Informe a Sigla do Estado")
                HELP "Informe a Sigla do Estado"
     SKIP(1)
     WITH WIDTH 64 ROW 8 CENTERED SIDE-LABELS OVERLAY TITLE 
            " Inclusao de Endereco " FRAME f_alt_endere.

ON  RETURN OF b_endereco DO:
    IF  AVAIL tt-endereco THEN
        DO:

            ASSIGN aux_nrcepend = tt-endereco.nrcepend 
                   aux_dsendere = tt-endereco.dsendere 
                   aux_dscmpend = tt-endereco.dscmpend 
                   aux_dsendcmp = tt-endereco.dsendcmp 
                   aux_cdufende = tt-endereco.cdufende 
                   aux_nmbairro = tt-endereco.nmbairro 
                   aux_nmcidade = tt-endereco.nmcidade.
        
            EMPTY TEMP-TABLE tt-endereco.
        
            CREATE tt-endereco.
            ASSIGN tt-endereco.nrcepend = aux_nrcepend 
                   tt-endereco.dsendere = aux_dsendere 
                   tt-endereco.dscmpend = aux_dscmpend 
                   tt-endereco.dsendcmp = aux_dsendcmp 
                   tt-endereco.cdufende = aux_cdufende 
                   tt-endereco.nmbairro = aux_nmbairro 
                   tt-endereco.nmcidade = aux_nmcidade. 
        
            CLOSE QUERY q_endereco.
            APPLY "GO".
        END.
END.

ON  ENTRY, VALUE-CHANGED OF b_endereco DO:
    IF  AVAIL tt-endereco  THEN
        DO:
            ASSIGN tel_dscmpend[1] = SUBSTR(tt-endereco.dscmpend,1,61)
                   tel_dscmpend[2] = SUBSTR(tt-endereco.dscmpend,62)
                   tel_dsoricad    = tt-endereco.dsoricad.
            DISPLAY tel_dscmpend tel_dsoricad WITH FRAME f_endereco.
        END.    
END.

ON  ANY-KEY OF b_endereco DO:
    IF  KEYFUNCTION(LASTKEY) = "INSERT-MODE" OR
        LASTKEY = KEYCODE("F8")              THEN
        DO:
            RUN Processa_Endere.
            HIDE FRAME f_alt_endere.
            APPLY "VALUE-CHANGED" TO b_endereco.
            RETURN NO-APPLY.
        END.
END.

IF  par_nrceplog = 0  THEN
    DO:
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            UPDATE tel_dsendere 
                   tel_nmcidade 
                   tel_cdufende WITH FRAME f_pesquisa.
            LEAVE.
        END.
    END.

IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
    DO:
        HIDE FRAME f_pesquisa.
        LEAVE.
    END.

HIDE FRAME f_pesquisa.

IF  tel_dsendere <> "" OR 
    tel_nmcidade <> "" OR
    tel_cdufende <> "" OR
    par_nrceplog <> 0  THEN

    RUN Busca_Dados( INPUT par_nrceplog, 
                     INPUT tel_dsendere,
                     INPUT tel_nmcidade,
                     INPUT tel_cdufende,
                     OUTPUT TABLE tt-endereco ).

/* Controla entrada na busca quando passado cep */
IF  par_nrceplog <> 0  THEN 
    DO:
        FIND tt-endereco 
            WHERE tt-endereco.nrcepend = par_nrceplog  NO-LOCK NO-ERROR.
    END.

IF  (par_nrceplog = 0) OR (AMBIGUOUS tt-endereco)  THEN
    DO:

        OPEN QUERY q_endereco FOR EACH tt-endereco NO-LOCK.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            MESSAGE "Tecle F8 para Inclusao de Endereco".
            UPDATE b_endereco WITH FRAME f_endereco.
            LEAVE.
        END.

        IF  KEYFUNCTION(LASTKEY) = "end-error"  THEN
            EMPTY TEMP-TABLE tt-endereco.

        HIDE FRAME f_endereco NO-PAUSE.

        CLOSE QUERY q_endereco.

    END.

/* ............................... FCUNTIONS ............................... */

FUNCTION ValidaUF RETURN LOGI (INPUT par_cdufende AS CHAR):

    RETURN CAN-DO("AC,AL,AP,AM,BA,CE,DF,ES,GO,MA,MT,MS,MG,PA,PB,PR,PE,PI,RJ," +
                  "RN,RS,RO,RR,SC,SP,SE,TO",par_cdufende).

END FUNCTION.

FUNCTION ValidaStringEndereco 
         RETURNS LOGI (INPUT par_dsstrenc AS CHAR,
                       INPUT par_nmdcampo AS CHAR,
                      OUTPUT par_dscritic AS CHAR):

    IF  INDEX(par_dsstrenc,";") > 0  THEN
        DO: 
            ASSIGN par_dscritic = 'Nao deve haver ";" no campo "' +
                                   par_nmdcampo + '".'.
            RETURN FALSE.
        END.
    
    RETURN TRUE.

END FUNCTION.

/* ............................. PROCEDURES ............................... */

PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_nrceplog AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-endereco.

    DEF VAR aux_qtregist AS INTE                                       NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen0038) THEN
        RUN sistema/generico/procedures/b1wgen0038.p
            PERSISTENT SET h-b1wgen0038.

    MESSAGE "Aguarde... buscando enderecos.".
    
    RUN busca-endereco IN h-b1wgen0038
        ( INPUT par_nrceplog,
          INPUT par_dsendere,
          INPUT par_nmcidade,
          INPUT par_cdufende,
          INPUT 999999,
          INPUT 1,
          INPUT 1, /* idorigem 1 - ayllos */
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-endereco ).

    DELETE PROCEDURE h-b1wgen0038.

    HIDE MESSAGE NO-PAUSE.

END PROCEDURE.


PROCEDURE Processa_Endere:
                                                                     
    DEF VAR aux_dscritic AS CHAR INIT ""                              NO-UNDO.
    DEF VAR aux_nmdcampo AS CHAR                                      NO-UNDO.

    HIDE MESSAGE NO-PAUSE.

    ASSIGN p_cduflogr = ""
           p_dscmplog = ""
           p_dstiplog = ""
           p_nmresbai = ""
           p_nmrescid = ""
           p_nmreslog = ""
           p_nrceplog = 0.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE p_nrceplog
               p_dstiplog 
               p_nmreslog
               p_dscmplog[1]
               p_dscmplog[2]
               p_nmresbai 
               p_nmrescid 
               p_cduflogr    
               WITH FRAME f_alt_endere

        EDITING:

            READKEY.

            APPLY LASTKEY.

            IF  GO-PENDING  THEN 
                DO:

                    RUN Valida_Dados (OUTPUT aux_dscritic,
                                      OUTPUT aux_nmdcampo).

                    IF  RETURN-VALUE <> "OK" THEN
                        DO:
                            /* se ocorreu erro, posiciona no campo correto */
                            {sistema/generico/includes/foco_campo.i 
                                                  &VAR-GERAL=SIM 
                                                  &NOME-FRAME="f_alt_endere"
                                                  &NOME-CAMPO=aux_nmdcampo }
                        END.
                END.
        END.

        IF  aux_dscritic = ""  THEN
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0038) THEN
                    RUN sistema/generico/procedures/b1wgen0038.p
                        PERSISTENT SET h-b1wgen0038.

                RUN gravar-endereco-cep IN h-b1wgen0038
                    ( INPUT glb_cdcooper, 
                      INPUT 0,            
                      INPUT 0,            
                      INPUT glb_cdoperad,
                      INPUT 1,            
                      INPUT glb_dtmvtolt,
                      INPUT YES,
                      INPUT p_nrceplog,
                      INPUT p_cduflogr,
                      INPUT p_dstiplog,
                      INPUT p_nmreslog,
                      INPUT p_nmreslog,
                      INPUT p_nmresbai,
                      INPUT p_nmresbai,
                      INPUT p_nmrescid,
                      INPUT p_nmrescid,
                      INPUT p_dscmplog[1] + p_dscmplog[2],
                      INPUT ?,   /* ROWID     */
                      INPUT NO,  /* ALTERACAO */
                     OUTPUT TABLE tt-erro ).

                DELETE PROCEDURE h-b1wgen0038.

                LEAVE.
            END.
    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) <> "END-ERROR"  THEN
        RUN Busca_Dados( INPUT p_nrceplog, 
                         INPUT tel_dsendere, 
                         INPUT tel_nmcidade,
                         INPUT tel_cdufende,
                        OUTPUT TABLE tt-endereco ).

    CLOSE QUERY q_endereco.
    OPEN QUERY q_endereco FOR EACH tt-endereco NO-LOCK.

    MESSAGE "Tecle F8 para Inclusao de Endereco".

    HIDE FRAME f_alt_endere NO-PAUSE.

END PROCEDURE.


PROCEDURE Valida_Dados:

    DEF OUTPUT PARAMETER aux_dscritic AS CHAR NO-UNDO.
    DEF OUTPUT PARAMETER aux_nmdcampo AS CHAR NO-UNDO.

    DO WITH FRAME f_alt_endere:
        ASSIGN 
            INPUT p_nrceplog
            INPUT p_cduflogr
            INPUT p_dstiplog
            INPUT p_nmreslog
            INPUT p_nmresbai
            INPUT p_nmrescid
            INPUT p_dscmplog[1]
            INPUT p_dscmplog[2].
    END.

    IF  NOT VALID-HANDLE(h-b1wgen0038) THEN
        RUN sistema/generico/procedures/b1wgen0038.p
            PERSISTENT SET h-b1wgen0038.

    RUN valida-endereco-cep IN h-b1wgen0038
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT p_nrceplog,
          INPUT p_cduflogr,
          INPUT p_dstiplog,
          INPUT p_nmreslog,
          INPUT p_nmreslog,
          INPUT p_nmresbai,
          INPUT p_nmresbai,
          INPUT p_nmrescid,
          INPUT p_nmrescid,
          INPUT p_dscmplog[1] + p_dscmplog[2],
          INPUT ?,
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-erro ).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               MESSAGE tt-erro.dscritic.

           RETURN "NOK".
        END.

    ASSIGN aux_nmdcampo = "p_" + aux_nmdcampo WHEN aux_nmdcampo <> "".
            
    DELETE PROCEDURE h-b1wgen0038.

    RETURN "OK".

END PROCEDURE.
