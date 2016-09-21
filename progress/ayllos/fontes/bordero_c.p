/* .............................................................................

   Programa: Fontes/bordero_c.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003                          Ultima atualizacao: 15/09/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para consultar os borderos de descontos de cheques.

   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
    
               15/09/2008 - Alterada chave de acesso para a tabela crapldc
                            (Gabriel).
                          - Retirado opcao observacoes pois nunca eh alimentado
                            (Guilherme).
............................................................................. */

DEF INPUT PARAM par_recid    AS INT                                  NO-UNDO.

DEF STREAM str_1.

DEF BUTTON btn_btaosair label "Sair".

{ includes/var_online.i }
{ includes/var_atenda.i }

DEF VAR tel_qtcheque AS INT                                          NO-UNDO.

DEF VAR tel_vlcheque AS DECIMAL                                      NO-UNDO.

DEF VAR tel_dsobserv AS CHAR  VIEW-AS EDITOR SIZE 76 BY 4 
                              BUFFER-LINES 10  PFCOLOR 0             NO-UNDO.

DEF VAR tel_dsvisual AS CHAR VIEW-AS EDITOR SIZE 80 BY 15 PFCOLOR 0  NO-UNDO. 

DEF FRAME f_visualiza
    tel_dsvisual HELP "Pressione <F4> ou <END> para finalizar" 
    WITH SIZE 76 BY 15 ROW 6 COLUMN 3 USE-TEXT NO-BOX NO-LABELS OVERLAY.

DEF VAR tel_dsdlinha AS CHAR                                         NO-UNDO.
DEF VAR tel_dspesqui AS CHAR                                         NO-UNDO.
DEF VAR tel_dsopedig AS CHAR                                         NO-UNDO.
DEF VAR tel_dsopelib AS CHAR                                         NO-UNDO.

DEF VAR opc_dsimprim AS CHAR INIT "Imprimir"                         NO-UNDO.
DEF VAR opc_dsvisual AS CHAR INIT "Visualizar Cheques"               NO-UNDO.

DEF VAR rel_nmcheque AS CHAR                                         NO-UNDO.
DEF VAR rel_dscpfcgc AS CHAR                                         NO-UNDO.

DEF VAR aux_nmendter AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                         NO-UNDO.

FORM SKIP(1)
     tel_dspesqui     AT 22 LABEL "Pesquisa" FORMAT "x(40)"
     crapbdc.nrborder AT 23 LABEL "Bordero"    SKIP
     crapbdc.nrctrlim AT 22 LABEL "Contrato"   SKIP
     tel_dsdlinha     AT 13 LABEL "Linha de Desconto" FORMAT "x(40)"
     SKIP(1)
     tel_qtcheque     AT 10 LABEL "Qtd. Cheques"  FORMAT "zzz,zz9"
     tel_dsopedig     AT 42 LABEL "Digitado por"  FORMAT "x(20)" SKIP
     tel_vlcheque     AT 17 LABEL "Valor" FORMAT "zzz,zzz,zz9.99" SKIP
     crapbdc.txmensal AT 11 LABEL "Taxa Mensal" "%"
     crapbdc.dtlibbdc AT 43 LABEL "Liberado em" SKIP
     crapbdc.txdiaria AT 11 LABEL "Taxa Diaria" "%"
     tel_dsopelib     AT 56 NO-LABEL FORMAT "x(20)" SKIP
     crapbdc.txjurmor AT 10 LABEL "Taxa de Mora" "%"
     SKIP(1)
     opc_dsimprim     AT 24 NO-LABEL FORMAT "x(8)"
     opc_dsvisual     AT 38 NO-LABEL FORMAT "x(18)"
     WITH ROW 7 COLUMN 2 NO-LABELS SIDE-LABELS OVERLAY WIDTH 78
          TITLE COLOR NORMAL " Consulta de Bordero " FRAME f_bordero.

/* .......................................................................... */

FIND crapbdc WHERE RECID(crapbdc) = par_recid NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapbdc   THEN
     RETURN.
     
/*FIND crapldc OF crapbdc NO-LOCK NO-ERROR.*/

FIND crapldc WHERE crapldc.cdcooper = glb_cdcooper      AND
                   crapldc.cddlinha = crapbdc.cddlinha  AND
                   crapldc.tpdescto = 2
                   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapldc   THEN
     RETURN.

/*  Operadores .............................................................. */

/*FIND crapope OF crapbdc NO-LOCK NO-ERROR. */              /*  Quem digitou  */

FIND crapope WHERE crapope.cdcooper = glb_cdcooper      AND
                   crapope.cdoperad = crapbdc.cdoperad  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapope   THEN
     tel_dsopedig = STRING(crapbdc.cdoperad) + "- NAO CADASTRADO".
ELSE
     tel_dsopedig = ENTRY(1,crapope.nmoperad," ").

IF   crapbdc.dtlibbdc <> ?   THEN                           /*  Quem liberou  */
     DO:
         FIND crapope WHERE crapope.cdcooper = glb_cdcooper     AND
                            crapope.cdoperad = crapbdc.cdopelib
                            NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE crapope   THEN
              tel_dsopelib = STRING(crapbdc.cdopelib) + "- NAO CADASTRADO".
         ELSE
              tel_dsopelib = ENTRY(1,crapope.nmoperad," ").
     END.

/* Documentos computados .................................................... */

FIND craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                   craplot.dtmvtolt = crapbdc.dtmvtolt   AND
                   craplot.cdagenci = crapbdc.cdagenci   AND
                   craplot.cdbccxlt = crapbdc.cdbccxlt   AND
                   craplot.nrdolote = crapbdc.nrdolote   NO-LOCK NO-ERROR.
                       
IF   NOT AVAILABLE craplot   THEN
     RETURN.
     
ASSIGN tel_qtcheque = craplot.qtcompln
       tel_vlcheque = craplot.vlcompcr.

/* .......................................................................... */

ASSIGN tel_dspesqui = STRING(crapbdc.dtmvtolt,"99/99/9999") + "-" +
                      STRING(crapbdc.cdagenci,"999")        + "-" +
                      STRING(crapbdc.cdbccxlt,"999")        + "-" +
                      STRING(crapbdc.nrdolote,"999999")     + "-" +
                      STRING(crapbdc.hrtransa,"HH:MM:SS")

       tel_dsdlinha = STRING(crapbdc.cddlinha,"999") + "-" +
                      crapldc.dsdlinha.

CONSULTA:

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   DISPLAY tel_dspesqui      crapbdc.nrborder  crapbdc.nrctrlim 
           tel_dsdlinha      tel_qtcheque      tel_dsopedig 
           tel_vlcheque      crapbdc.txmensal  crapbdc.dtlibbdc
           crapbdc.txdiaria  tel_dsopelib      crapbdc.txjurmor 
           opc_dsimprim      opc_dsvisual  
           WITH FRAME f_bordero.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      CHOOSE FIELD opc_dsimprim opc_dsvisual WITH FRAME f_bordero.

      IF   FRAME-VALUE = opc_dsimprim   THEN
           DO:
               RUN p_impressao.
           END.
      ELSE
      IF   FRAME-VALUE = opc_dsvisual   THEN
           DO:
               RUN p_visualiza_cheques.
           END.
   
   END.  /*  Fim do DO WHILE TRUE  */

   LEAVE.
   
END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_bordero.

/* .......................................................................... */

PROCEDURE p_impressao:

    RUN fontes/bordero_m.p (INPUT par_recid, INPUT crapbdc.insitbdc).

END PROCEDURE.

PROCEDURE p_visualiza_cheques:

    RUN fontes/bordero_vc.p (INPUT par_recid).

END PROCEDURE.

/* .......................................................................... */


