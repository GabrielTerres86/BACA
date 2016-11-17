/* .............................................................................

   Programa: Fontes/seguro_x.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                           Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento do cancelamento do seguro.

   Alteracoes: 06/03/97 - Imprimir cancelamento de seguros (Odair).

               25/04/97 - Alterado para tratar automacao do seguro (Edson).

               11/11/97 - Alterado para tratar cancelamento de seguro com
                          pagamento unico (Edson).

               02/08/1999 - Tratar seguro de vida em grupo (Deborah).

               06/08/1999 - Nao permitir cancelamento de seguro de vida se
                            o debito do mes anteior ainda nao foi feito
                            (Deborah).
                            
               28/10/1999 - Buscar os dados da cooperativa no crapcop (Edson).
                            Acertos no layout do relatorio (Deborah).

               10/11/1999 - Seguro de vida para conjuge (Deborah).

               20/01/2000 - Tratar seguro prestamista (Deborah).
               
               09/12/2003 - Buscar nome da cidade no crapcop (Junior).

               30/03/2005 - Acertos para novo modelo de cadastramento de
                            seguro - Unibanco (Evandro).
                            
               20/04/2005 - Retirada a critica para o seguro do tipo 11;
                            Tratado termo de cancelamento conforme a data
                            do debito do seguro tipo 11 (Diego).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               17/01/2006 - Permitir o "DESCANCELAMENTO" do seguro no mesmo dia
                            do cancelamento (Evandro).
                              
               11/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando               
               13/02/2006 - Inclusao do parametro glb_cdcooper para a chamada 
                            do programa fontes/pedesenha.p - SQLWorks - 
                            Fernando.

               22/04/2009 - Retirado tudo do seguro AUTO (Gabriel).
               
               31/03/2010 - Adaptacao para browse dinamico. Retirar comentarios
                            desnecessarios (Gabriel).
                            
               30/08/2011 - Para cancelamento de seguro residencial agora
                            e solicitado o motivo do cancelamento.
                            Retirado campo "numero da apolice" e adicionado
                            campo no relatorio que mostra o motivo selecionado
                            Adicionada chamada para cancelar_seguro e
                            desfaz_canc_seguro da b1wgen0033
                            (Gati - Oliver).
                            
               25/01/2012 - Efetuada correcao na chamada do botao 
                            'Desfazer Cancelamento', pois estava executando 
                            somente para seguro CASA (Diego).
                            
               12/11/2012 - Alteracao de parametro da procedure 
                            'cancelar_seguro' para ativar log (David Kruger).   
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
............................................................................. */

DEF  INPUT PARAM par_tpseguro AS INTE                                 NO-UNDO.
DEF  INPUT PARAM par_nrctrseg AS INTE                                 NO-UNDO.

{ includes/var_online.i }                                           
{ includes/var_atenda.i }
{ includes/var_seguro.i }
{ sistema/generico/includes/var_internet.i }

DEF STREAM str_1.

DEF        VAR tel_cdmotcan AS INTEGER   FORMAT "9"                  NO-UNDO.
DEF        VAR aux_cdmotcan AS CHARACTER FORMAT "x(40)"              NO-UNDO.

DEF        VAR aux_dsmesref AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmendter AS CHAR  FORMAT "x(20)"                  NO-UNDO.
DEF        VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.

DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.

DEFINE VARIABLE aux_nmarqpdf AS CHARACTER                            NO-UNDO.

DEF        VAR rel_nrdconta AS INT                                   NO-UNDO.
DEF        VAR rel_dstipseg AS CHAR                                  NO-UNDO.
DEF        VAR rel_dsseguro AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmresseg AS CHAR                                  NO-UNDO.
DEF        VAR rel_nrctrseg AS INT                                   NO-UNDO.
DEF        VAR rel_cdcalcul AS INT                                   NO-UNDO.
DEF        VAR rel_tpplaseg AS INT                                   NO-UNDO.
DEF        VAR rel_ddvencto AS INT                                   NO-UNDO.
DEF        VAR rel_vlpreseg AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vlcobert AS DECIMAL                               NO-UNDO.
DEF        VAR rel_dsbemseg AS CHAR    EXTENT 5                      NO-UNDO.
DEF        VAR rel_dsmvtolt AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmdsegur AS CHAR                                  NO-UNDO.
DEF        VAR rel_nrcpfcgc AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmbenefi AS CHAR    EXTENT 5                      NO-UNDO.
DEF        VAR rel_dsgraupr AS CHAR    EXTENT 5                      NO-UNDO.
DEF        VAR rel_txpartic AS DECIMAL EXTENT 5                      NO-UNDO.
DEF        VAR rel_dtinivig AS DATE                                  NO-UNDO.
DEF        VAR rel_dtfimvig AS DATE                                  NO-UNDO.
DEF        VAR par_qtregist AS INTE                                  NO-UNDO.                                                                  

DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL      INIT TRUE                NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.

DEF        VAR aux_cdsitseg LIKE crapseg.cdsitseg                    NO-UNDO.

DEF        VAR tel_imprcanc AS CHAR    EXTENT 2 INIT ["IMPRIMIR TERMO",
                                                      "DESFAZER CANCELAMENTO"]
                                                                     NO-UNDO.
DEF NEW SHARED VAR aut_flgsenha AS LOGICAL                           NO-UNDO.
DEF NEW SHARED VAR aut_cdoperad AS CHAR                              NO-UNDO.

FORM " Aguarde... Imprimindo CANCELAMENTO DE SEGURO! "
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.
          
FORM SKIP(1)
     tel_imprcanc[1]    FORMAT "x(14)"    AT 7
     SPACE(7)
     tel_imprcanc[2]    FORMAT "x(21)"
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56 FRAME f_imprime_desfaz.

FORM
    tel_cdmotcan LABEL "Motivo do Cancelamento"
                 HELP "Entre com o motivo do cancelamento - F7 Zoom"
                 VALIDATE(CAN-DO("1,2,3,4,5,6,7,8,9",tel_cdmotcan),
                                 "014 - Opcao errada.")
    "  "
    aux_cdmotcan
    WITH SIDE-LABELS ROW 14 COLUMN 6
    OVERLAY NO-LABELS WIDTH 71 FRAME f_motivo_canc_casa.

ON RETURN OF b_motivos IN FRAME f_motivos DO:
    ASSIGN aux_cdmotcan:SCREEN-VALUE IN FRAME f_motivo_canc_casa =
               tt-mot-can.dsmotcan.
           tel_cdmotcan:SCREEN-VALUE IN FRAME f_motivo_canc_casa =
               string(tt-mot-can.cdmotcan).

    APPLY "GO".
END.

aux_dsmesref = "JANEIRO,FEVEREIRO,MARCO,ABRIL,MAIO,JUNHO," +
               "JULHO,AGOSTO,SETEMBRO,OUTUBRO,NOVEMBRO,DEZEMBRO".

DO WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE:

    RUN sistema/generico/procedures/b1wgen0033.p
        PERSISTENT SET h-b1wgen0033.

    RUN busca_seguros IN h-b1wgen0033(INPUT glb_cdcooper,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT glb_cdoperad,
                                      INPUT glb_dtmvtolt,
                                      INPUT tel_nrdconta,
                                      INPUT 1,
                                      INPUT 1,
                                      INPUT glb_nmdatela,
                                      INPUT FALSE,
                                      OUTPUT TABLE tt-seguros,
                                      OUTPUT aux_qtsegass,
                                      OUTPUT aux_vltotseg,
                                      OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0033.

    IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF   AVAIL tt-erro   THEN
                DO:
                    ASSIGN glb_dscritic = tt-erro.dscritic
                           glb_cdcritic = tt-erro.cdcritic.
                    RETURN.
                END.
        END.
    
   FIND FIRST tt-seguros WHERE
              tt-seguros.cdcooper = glb_cdcooper  AND
              tt-seguros.nrdconta = tel_nrdconta  AND
              tt-seguros.tpseguro = par_tpseguro  AND
              tt-seguros.nrctrseg = par_nrctrseg  NO-ERROR.

  /* Botao imprimir dentro da consulta */
   IF   FRAME-VALUE = "Imprimir"   THEN
        LEAVE.
   ELSE
   /* Botao Cancelar - Possibilita a Impressao ou Desfazer o cancelamento */

   IF   tt-seguros.cdsitseg <> 1  AND
        NOT(tt-seguros.cdsitseg = 3 AND tt-seguros.tpseguro = 11) THEN
        DO:
            DISPLAY tel_imprcanc WITH FRAME f_imprime_desfaz.
            CHOOSE FIELD tel_imprcanc WITH FRAME f_imprime_desfaz.
            
            HIDE FRAME f_imprime_desfaz NO-PAUSE.

            IF   FRAME-VALUE = tel_imprcanc[1]   THEN
                 LEAVE.  /* vai para o termo de cancelamento */

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               ASSIGN aux_confirma = "N"
                      glb_cdcritic = 78.

               RUN fontes/critic.p.
               BELL.
               glb_cdcritic = 0.
               MESSAGE COLOR NORMAL "DESFAZER O CANCELAMENTO DO SEGURO ->"
                           glb_dscritic UPDATE aux_confirma.
               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) <> "END-ERROR"   AND
                 aux_confirma = "S"                    THEN
                 DO:
                    RUN sistema/generico/procedures/b1wgen0033.p 
                        PERSISTENT SET h-b1wgen0033.

                    RUN desfaz_canc_seguro
                        IN h-b1wgen0033(INPUT glb_cdcooper,
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT glb_cdoperad,
                                        INPUT glb_dtmvtolt,
                                        INPUT tel_nrdconta,
                                        INPUT 1,
                                        INPUT 1,
                                        INPUT glb_nmdatela,
                                        INPUT FALSE,
                                        INPUT tt-seguros.tpseguro,
                                        INPUT tt-seguros.nrctrseg,
                                        OUTPUT TABLE tt-erro).

                    DELETE PROCEDURE h-b1wgen0033.

                    IF   RETURN-VALUE <> "OK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                            IF   AVAIL tt-erro   THEN
                                DO:
                                    MESSAGE tt-erro.dscritic.
                                END.
                        END.

                    RETURN.
                 END.
            ELSE
                 RETURN.
        END.



    IF tt-seguros.tpseguro = 11 THEN
        DO:
            DISP tel_cdmotcan
                 aux_cdmotcan
                WITH FRAME f_motivo_canc_casa.

            EMPTY TEMP-TABLE tt-mot-can.

            RUN sistema/generico/procedures/b1wgen0033.p 
                PERSISTENT SET h-b1wgen0033.

            RUN buscar_motivo_can IN h-b1wgen0033(INPUT glb_cdcooper,
                                                  INPUT 0,
                                                  INPUT 0,
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_dtmvtolt,
                                                  INPUT tel_nrdconta,
                                                  INPUT 1,
                                                  INPUT 1,
                                                  INPUT glb_nmdatela,
                                                  INPUT FALSE,
                                                  INPUT 0, /* cdmotcan */
                                                  INPUT "",
                                                  OUTPUT par_qtregist,
                                                  OUTPUT TABLE tt-mot-can,
                                                  OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0033.

            UPDATE tel_cdmotcan
                WITH FRAME f_motivo_canc_casa
            EDITING:
                DO WHILE TRUE:
                    READKEY.
                    IF LASTKEY = KEYCODE("F7") THEN DO:

                        OPEN QUERY q_motivos
                            FOR EACH tt-mot-can.
    
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            UPDATE b_motivos WITH FRAME f_motivos.
                            LEAVE.
                        END.

                        HIDE FRAME f_motivos.
                        NEXT.
                    END.
                    ELSE DO:
                        APPLY LASTKEY.

                        FIND FIRST tt-mot-can WHERE
                                   tt-mot-can.cdmotcan =
                                     INPUT tel_cdmotcan NO-ERROR.
                        IF AVAIL tt-mot-can THEN
                            ASSIGN aux_cdmotcan:SCREEN-VALUE =
                                   tt-mot-can.dsmotcan.
                        ELSE
                            ASSIGN aux_cdmotcan:SCREEN-VALUE = "".
                    END.
                    LEAVE.
                END.
            END.

            ASSIGN INPUT FRAME f_motivo_canc_casa aux_cdmotcan.
        END.
   
    RUN fontes/confirma.p  (INPUT "ATENCAO: CANCELAMENTO DO SEGURO -> " +
                                  "078 - Confirma a operacao? (S/N):",
                           OUTPUT aux_confirma).

    HIDE FRAME f_motivo_canc_casa.
    HIDE FRAME f_motivos.

    IF   aux_confirma <> "S"  THEN
         RETURN.

    RUN sistema/generico/procedures/b1wgen0033.p 
        PERSISTENT SET h-b1wgen0033.

    RUN cancelar_seguro IN h-b1wgen0033(INPUT glb_cdcooper,
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT glb_cdoperad,
                                        INPUT glb_dtmvtolt,
                                        INPUT tel_nrdconta,
                                        INPUT 1,
                                        INPUT 1,
                                        INPUT glb_nmdatela,
                                        INPUT TRUE,
                                        INPUT tt-seguros.tpseguro,
                                        INPUT tt-seguros.nrctrseg,
                                        INPUT tel_cdmotcan,
                                        OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0033.

    IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF   AVAIL tt-erro   THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    RETURN.
                END.
        END.
  
   LEAVE.      

END.  /* DO WHILE TRUE */

INPUT THROUGH basename `tty` NO-ECHO.

   SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter. 

RUN sistema/generico/procedures/b1wgen0033.p
    PERSISTENT SET h-b1wgen0033.

RUN imprimir_termo_cancelamento IN h-b1wgen0033(INPUT glb_cdcooper,
                                                INPUT 0,
                                                INPUT 0,
                                                INPUT glb_cdoperad,
                                                INPUT glb_dtmvtolt,
                                                INPUT tel_nrdconta,
                                                INPUT tt-seguros.nrctrseg,
                                                INPUT tt-seguros.tpseguro,
                                                INPUT 1,
                                                INPUT 1,
                                                INPUT glb_nmdatela,
                                                INPUT FALSE,
                                                INPUT aux_nmendter,
                                                OUTPUT aux_nmarqimp,
                                                OUTPUT aux_nmarqpdf,
                                                OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0033.

ASSIGN glb_nrdevias = 1.
     
FIND FIRST crapass WHERE
       crapass.cdcooper = glb_cdcooper         AND
       crapass.nrdconta = tt-seguros.nrdconta  NO-ERROR.

{ includes/impressao.i }

/* .......................................................................... */
