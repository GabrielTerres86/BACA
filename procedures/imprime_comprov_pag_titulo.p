/* ............................................................................

Procedure: imprime_comprov_pag_titulo.p 
Objetivo : Montar impressao do comprovante de pagamento de titulo
Autor    : Odirlei Busana - AMcom
Data     : Junho/2016


Ultima alteração:

............................................................................ */

DEFINE TEMP-TABLE tt-comprovantes_imp NO-UNDO
       FIELD dtmvtolt AS DATE  /* Data do comprovantes       */
       FIELD dscedent AS CHAR  /* Descricao do comprovante   */
       FIELD vldocmto AS DECI  /* Valor do documento         */
       FIELD dsinform AS CHAR  /* Tipo de pagamento          */
       FIELD lndigita AS CHAR  /* Linha digitavel            */
       FIELD nrtransf AS INTE  /* Conta transferencia        */
       FIELD nmtransf AS CHAR EXTENT 2  /* Nome conta acima  */
       FIELD tpdpagto AS CHAR
       FIELD dsprotoc AS CHAR
       FIELD cdbcoctl AS INTE  /* Banco 085 */
       FIELD cdagectl AS INTE  /* Agencia da cooperativa */
       FIELD dsagectl AS CHAR
       FIELD nrtelefo AS CHAR  /* Nr telefone */
       FIELD nmopetel AS CHAR  /* Nome operadora */
       FIELD dsnsuope AS CHAR  /* NSU operadora */      
       FIELD dspagador      AS CHAR  /* nome do pagador do boleto */
       FIELD nrcpfcgc_pagad AS CHAR  /* NRCPFCGC_PAGAD */
       FIELD dtvenctit      AS CHAR  /* vencimento do titulo */
       FIELD vlrtitulo      AS CHAR  /* valor do titulo */
       FIELD vlrjurmul      AS CHAR  /* valor de juros + multa */
       FIELD vlrdscaba      AS CHAR  /* valor de desconto + abatimento */
       FIELD nrcpfcgc_benef AS CHAR. /* CPF/CNPJ do beneficiario  */   

DEFINE INPUT PARAMETER par_dsprotoc AS CHAR                        NO-UNDO.
DEFINE INPUT PARAMETER TABLE FOR tt-comprovantes_imp.
DEFINE OUTPUT PARAMETER par_flgderro AS LOGICAL.

{ includes/var_taa.i }


DEFINE         VARIABLE aux_dsdtoday    AS CHAR                     NO-UNDO.     
DEFINE         VARIABLE aux_dsmvtolt    AS CHAR                     NO-UNDO.
DEFINE         VARIABLE aux_hrtransa    AS INT                      NO-UNDO.
  

DEFINE         VARIABLE xml_req         AS CHAR                     NO-UNDO.
DEFINE         VARIABLE xDoc            AS HANDLE                   NO-UNDO.  
DEFINE         VARIABLE xRoot           AS HANDLE                   NO-UNDO. 
DEFINE         VARIABLE xRoot2          AS HANDLE                   NO-UNDO. 
DEFINE         VARIABLE xField          AS HANDLE                   NO-UNDO.
DEFINE         VARIABLE xText           AS HANDLE                   NO-UNDO.


/* grava no log local - FireBird */
DEFINE VARIABLE conexao                 AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE resultado               AS COM-HANDLE               NO-UNDO.
DEFINE VARIABLE comando                 AS COM-HANDLE               NO-UNDO.

DEFINE VARIABLE tmp_tximpres            AS CHARACTER                NO-UNDO.
DEFINE VARIABLE tmp_inestorn            AS INT                      NO-UNDO.

DEFINE VARIABLE aux_nrtelsac            AS CHARACTER                NO-UNDO.
DEFINE VARIABLE aux_nrtelouv            AS CHARACTER                NO-UNDO.

RUN procedures/grava_log.p (INPUT "Montando comprovante pagamento de titulo...").

/* Se foi informado o dsprotoc, deve buscar o protocolo e posicionar o registro*/
IF par_dsprotoc <> "" THEN
DO:
   
    RUN procedures/obtem_comprovantes.p (INPUT TODAY - 1,
                                         INPUT TODAY + 1 ,
                                        OUTPUT par_flgderro,
                                        OUTPUT TABLE tt-comprovantes_imp).

    IF  NOT par_flgderro THEN
    DO:
        FIND FIRST tt-comprovantes_imp
             WHERE tt-comprovantes_imp.dsprotoc = par_dsprotoc
            NO-ERROR.
        IF NOT AVAIL tt-comprovantes_imp THEN
        DO:       

            RUN procedures/grava_log.p (INPUT "Comprovante não encontrado: " + par_dsprotoc).

            RUN mensagem.w (INPUT YES,
                            INPUT "      ERRO!",
                            INPUT "",
                            INPUT "Comprovante não encontrado",
                            INPUT "",
                            INPUT "",
                            INPUT "").

            PAUSE 3 NO-MESSAGE.
            h_mensagem:HIDDEN = YES.

            par_flgderro = YES.
            RETURN "NOK".
        END.

    END.

END.
ELSE
DO:
    

    FIND FIRST tt-comprovantes_imp
        NO-ERROR.
    IF NOT AVAIL tt-comprovantes_imp THEN
    DO:            

        RUN procedures/grava_log.p (INPUT "Comprovante não encontrado: " + par_dsprotoc).

        RUN mensagem.w (INPUT YES,
                        INPUT "      ERRO!",
                        INPUT "",
                        INPUT xText:NODE-VALUE,
                        INPUT "Comprovante não encontrado",
                        INPUT "",
                        INPUT "").

        PAUSE 3 NO-MESSAGE.
        h_mensagem:HIDDEN = YES.

        par_flgderro = YES.
        RETURN "NOK".
    END.

END.


aux_hrtransa = TIME.

/* São 48 caracteres */

RUN procedures/obtem_informacoes_comprovante.p (OUTPUT aux_nrtelsac,
                                                OUTPUT aux_nrtelouv,
                                                OUTPUT par_flgderro).

/* centraliza o cabeçalho */
                      /* Coop do Associado */
ASSIGN tmp_tximpres = TRIM(glb_nmrescop) + " AUTOATENDIMENTO"
       tmp_tximpres = FILL(" ",INT((48 - LENGTH(tmp_tximpres)) / 2)) + tmp_tximpres
       tmp_tximpres = tmp_tximpres + FILL(" ",48 - length(tmp_tximpres))
       tmp_tximpres = tmp_tximpres +
                      "                                                "   +
                      "EMISSAO: " + STRING(TODAY,"99/99/9999") + "      "  +
                              "               " + STRING(TIME,'HH:MM:SS')  +
                      "                                                "   +
                      /* dados do TAA */             /* agencia na central, sem digito */
                      "COOPERATIVA/PA/TERMINAL: " + STRING(glb_agctltfn,"9999") + "/" +
                                                    STRING(glb_cdagetfn,"9999") + "/" +
                                                    STRING(glb_nrterfin,"9999") +
                                                             "         "
       tmp_tximpres = tmp_tximpres +
                      "                                                " +
                      "            COMPROVANTE DE PAGAMENTO            " +
                      "                                                "

       tmp_tximpres = tmp_tximpres +
                      "  BANCO: " + STRING(tt-comprovantes_imp.cdbcoctl, "999")

        tmp_tximpres = tmp_tximpres +
                      "                                    "             +
                      "AGENCIA: " + STRING(tt-comprovantes_imp.cdagectl, "9999")
    
       tmp_tximpres = tmp_tximpres +
                      "                                   "              +
                      "  CONTA: " + STRING(glb_nrdconta,"zzzz,zzz,9")    +
                      " - " + STRING(glb_nmtitula[1],"x(26)").

/* Segundo titular */
IF  glb_nmtitula[2] <> ""  THEN
    tmp_tximpres = tmp_tximpres +
                   "                    " + STRING(glb_nmtitula[2],"x(28)").


RUN incluir_linha (INPUT "                                                ").
RUN incluir_linha (INPUT "                                                ").
RUN incluir_linha (INPUT CAPS(STRING(tt-comprovantes_imp.tpdpagto,"x(48)"))).
RUN incluir_linha (INPUT "BENEFICIARIO: " + tt-comprovantes_imp.dscedent).

IF tt-comprovantes_imp.nrcpfcgc_benef <> "" THEN
DO:
    RUN incluir_linha (INPUT CAPS(tt-comprovantes_imp.nrcpfcgc_benef)).
END.

IF tt-comprovantes_imp.dspagador <> "" THEN
DO:
    
    RUN incluir_linha (INPUT CAPS(tt-comprovantes_imp.dspagador)).
END.

IF tt-comprovantes_imp.nrcpfcgc_pagad <> "" THEN
DO:
    RUN incluir_linha (INPUT CAPS(tt-comprovantes_imp.nrcpfcgc_pagad)).
END.
                                                                     
IF tt-comprovantes_imp.dtvenctit <> "" THEN
DO:
    RUN incluir_linha (INPUT CAPS(tt-comprovantes_imp.dtvenctit)).
END.

IF tt-comprovantes_imp.vlrtitulo <> "" THEN
DO:
    RUN incluir_linha (INPUT CAPS(tt-comprovantes_imp.vlrtitulo)).
END.
                      
IF tt-comprovantes_imp.vlrjurmul <> "" THEN
DO:
    RUN incluir_linha (INPUT CAPS( tt-comprovantes_imp.vlrjurmul)).
END.

IF tt-comprovantes_imp.vlrdscaba <> "" THEN
DO:
    RUN incluir_linha (INPUT CAPS(tt-comprovantes_imp.vlrdscaba)).
END.

RUN incluir_linha (INPUT "DATA DO PAGAMENTO: " + STRING(tt-comprovantes_imp.dtmvtolt,"99/99/9999")).
RUN incluir_linha (INPUT "VALOR DO PAGAMENTO: " + TRIM(STRING(tt-comprovantes_imp.vldocmto,"zz,zzz,zz9.99"))).
RUN incluir_linha (INPUT "                                                ").
RUN incluir_linha (INPUT CAPS(SUBSTRING(tt-comprovantes_imp.lndigita,1,41))).
RUN incluir_linha (INPUT "                 " + SUBSTRING(tt-comprovantes_imp.lndigita,43,29)).
RUN incluir_linha (INPUT "                                                ").
RUN incluir_linha (INPUT "   PROTOCOLO: " + STRING(tt-comprovantes_imp.dsprotoc,"x(29)")).

tmp_inestorn = INDEX(tt-comprovantes_imp.dsprotoc,"ESTORNADO").

IF  tmp_inestorn > 0  THEN
    tmp_tximpres = tmp_tximpres + "              " +
                   STRING(SUBSTRING(tt-comprovantes_imp.dsprotoc,tmp_inestorn),"x(33)") +
                   " ".


IF   glb_dtmvtocd > TODAY   THEN
     ASSIGN tmp_tximpres = tmp_tximpres + 
           "ESTE PAGAMENTO SERA PROCESSADO NO PROXIMO DIA   " +
           "UTIL.                                           ".  

ASSIGN tmp_tximpres = tmp_tximpres +
           "                                                ".

ASSIGN tmp_tximpres = tmp_tximpres +
               "    SAC - Servico de Atendimento ao Cooperado   " +

             FILL(" ", 14) + STRING(aux_nrtelsac, "x(20)") + FILL(" ", 14) +

               "     Atendimento todos os dias das 6h as 22h    " +
               "                                                " +
               "                   OUVIDORIA                    " +

             FILL(" ", 14) + STRING(aux_nrtelouv, "x(20)") + FILL(" ", 14) +               
    
               "    Atendimento nos dias uteis das 8h as 17h    " +
               "                                                " +
               "            **  FIM DA IMPRESSAO  **            " +
               "                                                " +
               "                                                ".

/* se a impressora estiver habilitada e com papel */
IF  xfs_impressora       AND
    NOT xfs_impsempapel  THEN
    RUN impressao_visualiza.w (INPUT "Comprovante...",
                               INPUT  tmp_tximpres,
                               INPUT 0, /*Comprovante*/
                               INPUT "").

RUN procedures/grava_log.p (INPUT "Montagem do comprovante pagamento de titulo com sucesso.").

RETURN "OK".

PROCEDURE incluir_linha:
    DEF INPUT PARAM par_texto AS CHAR       NO-UNDO.

    tmp_tximpres = tmp_tximpres + STRING(par_texto,"x(48)").


END PROCEDURE.

/* ......................................................................... */

