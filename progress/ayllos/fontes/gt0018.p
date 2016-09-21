/* ............................................................................

   Programa: Fontes/gt0018.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Lunelli
   Data    : Março/2013                        Ultima Atualizacao: 05/03/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Consulta Convenios SICREDI (Generico)
   
   Alteracoes: 23/04/2014 - Incluir glb_cddopcao e devidos ajutes, 
                            softdesk 148645 (Lucas R.)
   
               05/03/2015 - Retirado a condicao
                            " crapscn.dsnomcnv MATCHES "*FEBRABAN*" "
                            do fonte (SD 233749 - Tiago).
.............................................................................*/

{ includes/var_online.i  }

DEF  VAR  tel_dsempcnv    AS CHAR    FORMAT "x(05)"                   NO-UNDO.
DEF  VAR  tel_dsnomcnv    AS CHAR    FORMAT "x(35)"                   NO-UNDO.
DEF  VAR  tel_cdempcon    AS CHAR    FORMAT "x(4)"                    NO-UNDO.

DEF  VAR  tel_vltarint    AS DECI    FORMAT "zz9.99"                  NO-UNDO.
DEF  VAR  tel_vltartaa    AS DECI    FORMAT "zz9.99"                  NO-UNDO.
DEF  VAR  tel_vltarcxa    AS DECI    FORMAT "zz9.99"                  NO-UNDO.
DEF  VAR  tel_vltardeb    AS DECI    FORMAT "zz9.99"                  NO-UNDO.
DEF  VAR  tel_vltarcor    AS DECI    FORMAT "zz9.99"                  NO-UNDO.
DEF  VAR  tel_vltararq    AS DECI    FORMAT "zz9.99"                  NO-UNDO.
DEF  VAR  tel_dtcancel    AS DATE    FORMAT "99/99/9999"              NO-UNDO.
DEF  VAR  tel_nrrenorm    LIKE crapscn.nrrenorm                       NO-UNDO.
DEF  VAR  tel_nrtolera    LIKE crapscn.nrtolera                       NO-UNDO.
DEF  VAR  tel_cdsegmto    LIKE crapscn.cdsegmto                       NO-UNDO.
DEF  VAR  tel_dsdianor    LIKE crapscn.dsdianor                       NO-UNDO.

DEF  VAR aux_cddopcao  AS CHAR                                        NO-UNDO.
DEF  VAR aux_confirma  AS CHAR     FORMAT "!"                         NO-UNDO.
DEF  VAR aux_msgdolog  AS CHAR                                        NO-UNDO.

DEF TEMP-TABLE tt-convenios NO-UNDO
    FIELD cdempcon AS CHAR 
    FIELD cdsegmto AS CHAR
    FIELD dsempcnv AS CHAR
    FIELD dsnomcnv AS CHAR.

DEF QUERY q-empr-conve FOR crapscn.

DEF BROWSE b-empr-conve QUERY q-empr-conve
      DISP SPACE(2)
           cdempres                     COLUMN-LABEL "Codigo"
           SPACE(1)
           dsnomcnv                     COLUMN-LABEL "Nome Fantasia"
           WITH 9 DOWN OVERLAY NO-BOX.

DEF FRAME f-empr-conve
          b-empr-conve HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7 VIEW-AS DIALOG-BOX.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     glb_cddopcao AT 3 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (C ou A)"
                        VALIDATE(CAN-DO("C,A",glb_cddopcao),
                                 "014 - Opcao errada.")
     tel_dsempcnv   AT 13  LABEL "Cod.Sicredi"
                    HELP "Informe o codigo ou tecle <F7> para listar os convenios."
     tel_dsnomcnv   AT 33 LABEL "Convenio"
                    HELP "Informe o nome da empresa ou tecle <F7> para listar."
     WITH NO-LABELS ROW 5 OVERLAY COLUMN 2 FRAME f_gt0018 NO-BOX SIDE-LABELS.

FORM tel_cdempcon   AT 12  LABEL "Cod.Empresa"
     tel_cdsegmto   AT 58 LABEL "Segmento"
     SKIP(1)
     tel_vltarcxa   AT 5  LABEL "Valor Tarifa Caixa"
     tel_vltardeb   AT 42 LABEL "Valor Tarifa Deb. Autom."
     SKIP(1)
     tel_vltarint   AT 2  LABEL "Valor Tarifa Internet"
     tel_vltarcor   AT 36 LABEL "Valor Tarifa Corresp. Bancario"
     SKIP(1)
     tel_vltartaa   AT 7  LABEL "Valor Tarifa TAA"
     tel_vltararq   AT 36 LABEL "Valor Tarifa Arquivo(CNAB 240)"
     SKIP(1)
     tel_nrrenorm   AT 10 LABEL "Dias de Float"
     tel_dtcancel   AT 34  LABEL "Data do Cancelamento do Convenio"
     SKIP(1)
     tel_dsdianor   AT 7 LABEL "Forma de Repasse"
     tel_nrtolera   AT 32 LABEL "Dias de Tolerancia Apos Vencimento"
     WITH NO-LABELS ROW 9 OVERLAY COLUMN 2 FRAME f_tarifas NO-BOX SIDE-LABELS.
    
ON END-ERROR OF b-empr-conve DO:

    DISABLE b-empr-conve WITH FRAME f-empr-conve.

    CLOSE QUERY q-empr-conve.
    HIDE FRAME f-empr-conve.

    NEXT-PROMPT tel_dsempcnv WITH FRAME f_gt0018.

END.

VIEW FRAME f_moldura.
PAUSE(0).

RUN fontes/inicia.p.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0. 

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

lab:
DO WHILE TRUE:
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        CLEAR FRAME f_gt0018.
        HIDE FRAME f_tarifas.

        UPDATE glb_cddopcao WITH FRAME f_gt0018.
        
        LEAVE.
    END.

    /* F4 ou FIM */
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "GT0018" THEN
                DO:
                    HIDE FRAME f_gt0018.
                    HIDE FRAME f_tarifas.
                    
                    RETURN.
                END.
            ELSE
                NEXT.
            
        END.

    IF  aux_cddopcao <> glb_cddopcao THEN
        DO:
           { includes/acesso.i }
           aux_cddopcao = glb_cddopcao.
        END.
    
    ASSIGN aux_msgdolog = "".

    VIEW FRAME f_gt0018.

    ASSIGN tel_cdempcon = ""
           tel_cdsegmto = ""
           tel_vltarint = 0
           tel_vltartaa = 0
           tel_vltarcxa = 0
           tel_vltardeb = 0
           tel_vltarcor = 0
           tel_vltararq = 0
           tel_nrrenorm = 0
           tel_dsdianor = ""
           tel_dtcancel = ?
           tel_nrtolera = 0.
    
    UPDATE tel_dsempcnv
           WITH FRAME f_gt0018
        EDITING:
    
            READKEY.
            IF  LASTKEY =  KEYCODE("F7") THEN
                RUN pi-exibe-browse (INPUT FRAME-FIELD,
                                     INPUT INPUT tel_dsnomcnv).
    
            APPLY LASTKEY.
        END. /* Editing */
        
    dsconv:
    DO WHILE TRUE ON ENDKEY UNDO, NEXT lab:
    
        UPDATE tel_dsnomcnv WHEN INPUT tel_dsempcnv = " "
               WITH FRAME f_gt0018
            EDITING:
    
            READKEY.
    
            IF  LASTKEY =  KEYCODE("F7") OR
                LASTKEY =  13            THEN
                DO:
                    RUN pi-exibe-browse (INPUT FRAME-FIELD,
                                         INPUT INPUT tel_dsnomcnv).
    
                    IF  RETURN-VALUE = "NOK" THEN
                        DO:
                            MESSAGE "Convenio SICREDI nao encontrado.".
                            CLEAR FRAME f_gt0018.
                            PAUSE 1 NO-MESSAGE.
                            
                            NEXT dsconv.
                        END.
    
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
                        NEXT dsconv.
                END.
    
            APPLY LASTKEY.
    
        END. /* Editing */
    
        LEAVE.
    
    END. /* DO WHILE TRUE */
    
    FIND crapscn WHERE crapscn.cdempres = tel_dsempcnv NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL crapscn THEN
        DO: 
            MESSAGE "Convenio SICREDI nao encontrado.".
            NEXT.
        END.
    
    IF  crapscn.cdempcon <> 0 THEN
        ASSIGN tel_cdempcon = STRING(crapscn.cdempcon).
    
    IF  crapscn.cdempco2 <> 0 THEN
        ASSIGN tel_cdempcon = tel_cdempcon + "/" + STRING(crapscn.cdempco2).
    
    IF  crapscn.cdempco3 <> 0 THEN
        ASSIGN tel_cdempcon = tel_cdempcon + "/" + STRING(crapscn.cdempco3).
    
    IF  crapscn.cdempco4 <> 0 THEN
        ASSIGN tel_cdempcon = tel_cdempcon + "/" + STRING(crapscn.cdempco4).
    
    IF  crapscn.cdempco5 <> 0 THEN
        ASSIGN tel_cdempcon = tel_cdempcon + "/" + STRING(crapscn.cdempco5).
    
    ASSIGN tel_nrrenorm = crapscn.nrrenorm
           tel_dsdianor = crapscn.dsdianor
           tel_dtcancel = crapscn.dtencemp
           tel_dsnomcnv = crapscn.dsnomcnv
           tel_nrtolera = crapscn.nrtolera
           tel_cdsegmto = crapscn.cdsegmto.
    
    DISPLAY tel_dsnomcnv WITH FRAME f_gt0018.
    
    /* Tipos de Arrecadação SICREDI 
       A - ATM 
       B - Correspondente Bancário 
       C - Caixa 
       D - Internet Banking
       E - Debito Auto
       F - Arquivo de Pagamento (CNAB 240)  */

    IF  glb_cddopcao = "C" THEN
        DO:       
            FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                     crapstn.tpmeiarr = "A" 
                                     NO-LOCK NO-ERROR.
           
            IF  AVAIL crapstn THEN
                ASSIGN tel_vltartaa = crapstn.vltrfuni.
            
            FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                     crapstn.tpmeiarr = "B" 
                                     NO-LOCK NO-ERROR.
           
            IF  AVAIL crapstn THEN
                ASSIGN tel_vltarcor = crapstn.vltrfuni.
           
            FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                     crapstn.tpmeiarr = "C" 
                                     NO-LOCK NO-ERROR.
           
            IF  AVAIL crapstn THEN
                ASSIGN tel_vltarcxa = crapstn.vltrfuni.
           
            FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                     crapstn.tpmeiarr = "D" 
                                     NO-LOCK NO-ERROR.
           
            IF  AVAIL crapstn THEN
                ASSIGN tel_vltarint = crapstn.vltrfuni.
           
            FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                     crapstn.tpmeiarr = "E" 
                                     NO-LOCK NO-ERROR.
           
            IF  AVAIL crapstn THEN
                ASSIGN tel_vltardeb = crapstn.vltrfuni.
           
            FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres AND
                                     crapstn.tpmeiarr = "F" 
                                     NO-LOCK NO-ERROR.
           
            IF  AVAIL crapstn THEN
                ASSIGN tel_vltararq = crapstn.vltrfuni.
           
            DISPLAY tel_cdempcon
                    tel_cdsegmto
                    tel_vltarint
                    tel_vltartaa
                    tel_vltarcxa
                    tel_vltardeb
                    tel_vltarcor
                    tel_vltararq
                    tel_nrrenorm
                    tel_dtcancel
                    tel_dsdianor
                    tel_nrtolera
                    WITH FRAME f_tarifas.
            
            WAIT-FOR ANY-KEY OF CURRENT-WINDOW.
            
            ASSIGN tel_dsempcnv = ""
                   tel_dsnomcnv = "".
            
            DISPLAY tel_dsempcnv
                    tel_dsnomcnv WITH FRAME f_gt0018.
            
            HIDE FRAME f_tarifas.

            PAUSE(0).
        END. /* Fim da opcao C */
    ELSE
    IF  glb_cddopcao = "A" THEN
        DO:
              
            /* Se nao achou, nao devera alterar este convenio */
            FIND FIRST crapscn WHERE 
                       crapscn.dsoparre = "E"                AND
                      (crapscn.cddmoden = "A"                OR 
                       crapscn.cddmoden = "C")               AND 
                       crapscn.cdempres = tel_dsempcnv
                       NO-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL crapscn THEN
                DO:
                    MESSAGE "Nao permitido alteracao deste tipo de Convenio.".
                    PAUSE 3 NO-MESSAGE.
                    HIDE MESSAGE.
                    CLEAR FRAME f_gt0018.
                    NEXT.    
                END.

            UPDATE tel_cdempcon
                   tel_cdsegmto
                   WITH FRAME f_tarifas.
            
            FIND crapscn WHERE crapscn.cdempres = tel_dsempcnv 
                               EXCLUSIVE-LOCK NO-ERROR.
    
            IF  NOT AVAIL crapscn THEN
                DO: 
                    MESSAGE "Convenio SICREDI nao encontrado.".
                    NEXT.
                END.
            ELSE
                DO:
                    FIND FIRST tt-convenios WHERE 
                               tt-convenios.dsempcnv = tel_dsempcnv 
                               NO-LOCK NO-ERROR.

                    IF  NOT AVAIL tt-convenios THEN
                        DO: 
                            CREATE tt-convenios.
                            ASSIGN tt-convenios.cdempcon = STRING(crapscn.cdempcon)
                                   tt-convenios.cdsegmto = STRING(crapscn.cdsegmto)
                                   tt-convenios.dsempcnv = tel_dsempcnv.
                        END.
                END.

            ASSIGN aux_confirma = "N".
            RUN fontes/confirma.p (INPUT  "",
                                  OUTPUT aux_confirma).
            
            IF  aux_confirma = "S" THEN 
                DO: 
                    FIND FIRST tt-convenios WHERE 
                               tt-convenios.dsempcnv = tel_dsempcnv 
                               NO-LOCK NO-ERROR.

                    IF  NOT AVAIL tt-convenios THEN
                        DO:
                            UNIX SILENT VALUE 
                                ("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                                 " - " +   STRING(TIME,"HH:MM:SS")           +
                                 " Operador: "  + glb_cdoperad               +
                                 " --> Codigo sicredi nao encontrado."       +
                                 " >> /usr/coop/" + TRIM(crapcop.dsdircop)   +
                                 "/log/gt0018.log").
                            NEXT.
                        END.

                    IF  tel_cdempcon <> STRING(crapscn.cdempcon) THEN
                        UNIX SILENT VALUE 
                            ("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                             " - " +   STRING(TIME,"HH:MM:SS")           +
                             " Operador: "  + glb_cdoperad               +  
                             " alterou para o convenio "                 +
                             STRING(tel_dsempcnv)                        +
                             " - " + TRIM(tel_dsnomcnv)                  + 
                             " o codigo de empresa "                     + 
                             TRIM(tt-convenios.cdempcon)                 +
                             " para " + TRIM(tel_cdempcon)               +
                             ". >> /usr/coop/" + TRIM(crapcop.dsdircop)  +
                             "/log/gt0018.log").

                    IF  tel_cdsegmto <> STRING(crapscn.cdsegmto) THEN
                        UNIX SILENT VALUE 
                            ("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                             " - " +   STRING(TIME,"HH:MM:SS")           +
                             " Operador: "  + glb_cdoperad               +  
                             " alterou para o convenio "                 +
                             STRING(tel_dsempcnv)                        +
                             " - " + TRIM(tel_dsnomcnv)                  + 
                             " o codigo do segmento "                    + 
                             TRIM(tt-convenios.cdsegmto)                 +
                             " para " + TRIM(tel_cdsegmto)               +
                             ". >> /usr/coop/" + TRIM(crapcop.dsdircop)  +
                             "/log/gt0018.log").

                    ASSIGN crapscn.cdempcon = INTE(tel_cdempcon)
                           crapscn.cdsegmto = tel_cdsegmto.

                END.
        END. /* Fim da opcao A */
END.

PROCEDURE pi-exibe-browse:

    DEF  INPUT   PARAM  par_frmfield    AS CHAR                   NO-UNDO.
    DEF  INPUT   PARAM  par_dsnomcnv    AS CHAR                   NO-UNDO.

    IF  par_frmfield = "tel_dsempcnv" THEN
        OPEN QUERY q-empr-conve FOR EACH   crapscn WHERE
                                NO-LOCK BY crapscn.cdempres.
    ELSE
        OPEN QUERY q-empr-conve FOR EACH crapscn WHERE
                                         crapscn.dsnomcnv MATCHES "*" + par_dsnomcnv + "*"
                                         NO-LOCK BY crapscn.cdempres.

    IF  NOT AVAIL crapscn THEN
        RETURN "NOK".

    ENABLE b-empr-conve WITH FRAME f-empr-conve.

    WAIT-FOR RETURN OF b-empr-conve.

    DISABLE b-empr-conve WITH FRAME f-empr-conve.

    ASSIGN tel_dsempcnv = crapscn.cdempres
           tel_dsnomcnv = crapscn.dsnomcnv.
    
    DISPLAY tel_dsempcnv
            tel_dsnomcnv WITH FRAME f_gt0018.
    
    CLOSE QUERY q-empr-conve.
    HIDE FRAME f-empr-conve. 

    RETURN "OK".
    
END PROCEDURE.
