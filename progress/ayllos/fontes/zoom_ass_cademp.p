/*.............................................................................

   Programa: fontes/zoom_ass_cademp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Junho/2015                       Ultima alteracao: / /

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom do nome dos titular que nao estao vinculados ao 
               cadastro de empresas

   Alteracoes:

............................................................................. */

{ sistema/generico/includes/b1wgen0166tt.i &VAR-AMB=SIM }
{ includes/var_online.i }
{ includes/gg0000.i}
{ sistema/generico/includes/var_oracle.i }

DEF INPUT  PARAM par_cdcooper AS INTE                            NO-UNDO.
DEF OUTPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
DEF OUTPUT PARAM par_nmprimtl AS CHAR                            NO-UNDO.

DEF VAR tel_nmprimtl AS CHAR  FORMAT "x(40)"                     NO-UNDO.
DEF VAR tel_nrdctitg AS CHAR  FORMAT "x.xxx.xxx-x"               NO-UNDO.
DEF VAR tel_opnmprim AS CHAR  INIT  "Razao Social"               NO-UNDO.
DEF VAR tel_opcpfcgc AS CHAR  INIT  "CNPJ"                       NO-UNDO.
DEF VAR tel_tppesttl AS INT   INIT 0                             NO-UNDO.
DEF VAR aux_cdpesqui AS INT   INIT 0                             NO-UNDO.
DEF VAR tel_tpdorgan AS INT   INIT 1                             NO-UNDO.
DEF VAR tel_nrcpfcgc AS DECI  INIT "" FORMAT "99999999999999"    NO-UNDO.

DEF QUERY  bgnetcvla-q FOR tt-titular. 
DEF BROWSE bgnetcvla-b QUERY bgnetcvla-q
           DISP nrdconta                    COLUMN-LABEL "Conta/dv"
                nmpesttl    FORMAT "x(40)"  COLUMN-LABEL "Nome Pesquisado"
           WITH 7 DOWN OVERLAY TITLE " Associados ".

FORM bgnetcvla-b HELP "Use <ENTER> para selecionar um associado."
     WITH NO-BOX CENTERED OVERLAY ROW 7 FRAME f_alterar.

FORM "Conta/dv:"         tt-titular.nrdconta 
     "-"                 tt-titular.nmextttl FORMAT "x(40)"
     WITH WIDTH 78 ROW 18 COLUMN 2 OVERLAY NO-LABEL NO-BOX FRAME f_dados.

FORM SKIP(1)
     tel_opnmprim NO-LABEL AT 20 FORMAT "x(15)"
                  HELP "Pesquisar pela razao social."
     SPACE(4)
     tel_opcpfcgc NO-LABEL       FORMAT "x(8)"
                  HELP "Pesquisar por CNPJ."
     SKIP(1)
     tel_nmprimtl LABEL " Nome a pesquisar" 
                  HELP "Informe o nome ou parte dele para efetuar a pesquisa."
     SKIP(1)
     tel_nrcpfcgc LABEL "         CNPJ"
                  HELP "Informe o CNPJ para efetuar a pesquisa."
                 VALIDATE (tel_nrcpfcgc > 0, "027 - CNPJ com erro." )
     WITH ROW 8 CENTERED SIDE-LABELS OVERLAY
          TITLE COLOR NORMAL " Pesquisa de Associados "
          FRAME f_associado.

ON  VALUE-CHANGED, ENTRY OF bgnetcvla-b DO:
    IF  glb_cdprogra = "NOME"   THEN DO:
        DISPLAY tt-titular.nrdconta tt-titular.nmextttl
                WITH FRAME f_dados.          
    END.
END.

ON  RETURN OF bgnetcvla-b DO:
    IF  AVAILABLE tt-titular  THEN
        ASSIGN par_nrdconta = tt-titular.nrdconta
               par_nmprimtl = tt-titular.nmpesttl.

    HIDE FRAME f_dados.
    HIDE FRAME f_alterar.
    HIDE FRAME f_associado.
          
    CLOSE QUERY bgnetcvla-q.               
    APPLY "END-ERROR" TO bgnetcvla-b.
END.

DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

    DISPLAY tel_opnmprim
            tel_opcpfcgc
            WITH FRAME f_associado.
    
    CHOOSE FIELD tel_opnmprim
                 tel_opcpfcgc
                 WITH FRAME f_associado.
   
    IF  FRAME-VALUE = tel_opnmprim   THEN DO:
        ASSIGN aux_cdpesqui = 1.
   
        UPDATE tel_nmprimtl
               WITH FRAME f_associado.
   
        IF   TRIM(tel_nmprimtl) = ""   THEN
             NEXT.
    END.
    ELSE
    IF  FRAME-VALUE = tel_opcpfcgc   THEN DO:
        ASSIGN aux_cdpesqui = 2.
             
        UPDATE tel_nrcpfcgc
               WITH FRAME f_associado.
    END.

    MESSAGE "Pesquisando ...".

    FOR EACH crapass WHERE crapass.cdcooper = par_cdcooper
                       AND crapass.inpessoa <> 1
                       AND crapass.dtdemiss = ?
                       AND ((  tel_nmprimtl = ""   AND 
                             (tel_nrcpfcgc <> 0    AND crapass.nrcpfcgc = tel_nrcpfcgc))
                          OR (     tel_nrcpfcgc = 0
                              AND (tel_nmprimtl <> "" AND crapass.nmprimtl MATCHES("*" + tel_nmprimtl + "*")
                              )
                           ))
                       NO-LOCK:

        CREATE tt-titular.
        ASSIGN tt-titular.nrdconta = crapass.nrdconta
               tt-titular.nmpesttl = crapass.nmprimtl.
    END.

    HIDE MESSAGE NO-PAUSE.

    OPEN QUERY bgnetcvla-q FOR EACH tt-titular NO-LOCK.

    HIDE FRAME f_dados.
    HIDE FRAME f_alterar.
    HIDE FRAME f_associado.

    LEAVE.

END.  /*  Fim do DO WHILE TRUE  */


/* Volta para o campo na tela com valor ZERO */
IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN DO: /*   F4 OU FIM   */
    par_nrdconta = 0.
    par_nmprimtl = "NENHUM REGISTRO SELECIONADO".

    HIDE FRAME f_dados.
    HIDE FRAME f_alterar.
    HIDE FRAME f_associado.

    RETURN.
END.

/* Se houver associados, listar todos na tela para escolha */
IF  CAN-FIND(FIRST tt-titular)   THEN
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        SET bgnetcvla-b WITH FRAME f_alterar.
        LEAVE.
    END.  /*  Fim do DO WHILE TRUE  */
ELSE DO:

    HIDE FRAME f_dados.
    HIDE FRAME f_alterar.
    HIDE FRAME f_associado.

    /* Gera critica */
    glb_cdcritic = 407.
    RUN fontes/critic.p.
    MESSAGE glb_dscritic.
    PAUSE(2) NO-MESSAGE.

END.

glb_cdcritic = 0.

HIDE FRAME f_alterar NO-PAUSE.

/* .......................................................................... */
