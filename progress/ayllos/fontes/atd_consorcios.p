/* .............................................................................

   Programa: Fontes/atd_consorcios.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Carlos Henrique
   Data    : Julho/2013.                        Ultima atualizacao: 08/04/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratar CONSORCIOS para a tela ATENDA.

   Alteracoes: 08/04/2014 - Ajuste de whole index (Jean Michel).         
   
............................................................................. */

{ sistema/generico/includes/b1wgen0162tt.i }

{ includes/var_online.i }

DEF INPUT PARAM par_nrdconta AS INTE     NO-UNDO.

DEF VAR h-b1wgen0162 AS HANDLE           NO-UNDO.

DEF QUERY q_crawcns FOR tt-consorcios.

/* 
Cota = crapcns.nrcotcns 
Tipo = crapcns.tpconsor 
Inicio = crapcns.dtinicns
Valor carta = crapcns.vlrcarta
Parcelas = crapcns.qtparcns 
Valor Parcela = crapcns.vlrparcns
*/
DEF BROWSE b_crawcns QUERY q_crawcns
    DISP tt-consorcios.nrdgrupo COLUMN-LABEL "Grupo"         FORMAT "zzzzz9"
         tt-consorcios.nrcotcns COLUMN-LABEL "Cota"          FORMAT "zzzz9"
         tt-consorcios.dsconsor COLUMN-LABEL "Tipo"
         tt-consorcios.dtinicns COLUMN-LABEL "Inicio"        FORMAT "99/99/99"
         tt-consorcios.vlrcarta COLUMN-LABEL "Valor carta"   FORMAT "z,zzz,zz9.99"
         tt-consorcios.qtparcns COLUMN-LABEL "Parc."         FORMAT "zz9"
         tt-consorcios.vlparcns COLUMN-LABEL "Valor parcela" FORMAT "zz,zz9.99"
         tt-consorcios.instatus COLUMN-LABEL "Situacao"      FORMAT "X(9)"
         WITH CENTERED WIDTH 76 8 DOWN NO-BOX.

FORM b_crawcns HELP "Pressione ENTER para selecionar ou F4/END para sair."
    WITH WIDTH 78 ROW 9 NO-LABELS OVERLAY TITLE " Consorcios " CENTERED FRAME f_crawcns.


FORM 
    tt-consorcios.dsconsor AT  3 LABEL "Tipo de consorcio"
    tt-consorcios.nrctacns AT 48 LABEL "Conta consorcio" 
    SKIP(1)
    tt-consorcios.nrdgrupo AT 15 LABEL "Grupo"          FORMAT "zzzzzzzzzzz9"
    tt-consorcios.dtinicns AT 42                        FORMAT "99/99/9999"
    SKIP
    
    tt-consorcios.nrcotcns AT  6                        FORMAT "zzzzzzzzzzz9"
    HELP "Pressione F4/END para sair."
    tt-consorcios.dtfimcns AT 41                        FORMAT "99/99/9999"
    SKIP

    tt-consorcios.nrctrato AT 12                        FORMAT " zzz,zzz,zzz"
    tt-consorcios.nrdiadeb AT 50                        FORMAT "99"
    SKIP
    tt-consorcios.vlrcarta AT  6                        FORMAT "z,zzz,zz9.99"
    tt-consorcios.parcpaga AT 49 LABEL "Parcelas pagas" FORMAT "X(12)"
    SKIP
    tt-consorcios.qtparcns AT  2                        FORMAT "zzzz,zzz,999"
    tt-consorcios.instatus AT 55 LABEL "Situacao"       FORMAT "X(9)"
    SKIP
    tt-consorcios.vlparcns AT  4                        FORMAT "z,zzz,zz9.99"

    WITH TITLE COLOR NORMAL " Consorcios " 
    WIDTH 78 OVERLAY ROW 9 SIDE-LABEL CENTERED FRAME f_consorcio_detalhes.

ON "RETURN" OF b_crawcns IN FRAME f_crawcns DO:

    IF AVAIL tt-consorcios THEN
        DO:

            DO WHILE TRUE ON END-KEY UNDO, LEAVE:

                DISPLAY 
                    tt-consorcios.dsconsor tt-consorcios.nrctacns
                    tt-consorcios.nrcotcns
                    tt-consorcios.nrdgrupo tt-consorcios.dtinicns
                    tt-consorcios.nrctrato tt-consorcios.dtfimcns
                    tt-consorcios.nrdiadeb tt-consorcios.vlrcarta 
                    tt-consorcios.vlparcns tt-consorcios.parcpaga
                    tt-consorcios.qtparcns tt-consorcios.instatus
                    WITH FRAME f_consorcio_detalhes.
                PAUSE MESSAGE "Pressione F4 ou END para sair.".
            END.


            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                DO:
                    HIDE FRAME f_consorcio_detalhes NO-PAUSE.
                    APPLY "NEXT".
                END.
        END.

    APPLY "NEXT".
END.

/* ============================================================================= */


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    RUN sistema/generico/procedures/b1wgen0162.p PERSISTENT SET h-b1wgen0162.

    RUN lista_consorcio IN h-b1wgen0162 (INPUT glb_cdcooper,
                                         INPUT "",
                                         INPUT 0,
                                         INPUT par_nrdconta,
                                         OUTPUT TABLE tt-consorcios).
    DELETE PROCEDURE h-b1wgen0162.

    IF TEMP-TABLE tt-consorcios:HAS-RECORDS = FALSE THEN
        DO: 
            MESSAGE "Associado nao possui consorcios.".
            LEAVE.
        END.

       HIDE FRAME f_crawcns NO-PAUSE.

    /* Abrir o browser com consorcios */
    OPEN QUERY q_crawcns FOR EACH tt-consorcios NO-LOCK 
                    WHERE tt-consorcios.cdcooper = glb_cdcooper
                      AND tt-consorcios.nrdconta = par_nrdconta.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        HIDE MESSAGE.
        UPDATE b_crawcns WITH FRAME f_crawcns.
        LEAVE.
    END.
    
    

    /* Sair do brownse dos consorcios */
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            HIDE FRAME f_crawcns NO-PAUSE.
            LEAVE.
        END.

END. /* DO WHILE TRUE ON ENDKEY UNDO, LEAVE */
