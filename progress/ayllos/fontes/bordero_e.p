/* .............................................................................

   Programa: Fontes/bordero_e.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/2004                        Ultima atualizacao: 11/11/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para excluir os borderos de descontos de cheques.

   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
    
               16/09/2008 - Alterada chave de acesso a tabela crapldc
                            (Gabriel).
                            
               11/11/2015 - Chamar a mesma rotina de exclusao do Ayllos Web,
                            para logar a exclusao. Chamado 338694. 
                            (Gabriel-RKAM)             

............................................................................. */

DEF INPUT PARAM par_recid    AS INT                        NO-UNDO.

DEF STREAM str_1.

DEF BUTTON btn_btaosair label "Sair".

{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }

DEF VAR tel_qtcheque AS INT                                         NO-UNDO.

DEF VAR tel_vlcheque AS DECIMAL                                     NO-UNDO.

DEF VAR tel_dsobserv AS CHAR  VIEW-AS EDITOR SIZE 76 BY 4 
                        BUFFER-LINES 10       PFCOLOR 0             NO-UNDO.

DEF VAR tel_dsvisual AS CHAR VIEW-AS EDITOR SIZE 80 BY 15 PFCOLOR 0 NO-UNDO.

DEF VAR aux_confirma AS CHAR FORMAT "!"                             NO-UNDO.
DEF VAR tel_dsdlinha AS CHAR                                        NO-UNDO.
DEF VAR tel_dspesqui AS CHAR                                        NO-UNDO.
DEF VAR tel_dsopedig AS CHAR                                        NO-UNDO.
DEF VAR tel_dsopelib AS CHAR                                        NO-UNDO.

DEF VAR opc_dsimprim AS CHAR INIT "Imprimir"                        NO-UNDO.
DEF VAR opc_dsobserv AS CHAR INIT "Observacoes"                     NO-UNDO.
DEF VAR opc_dsvisual AS CHAR INIT "Visualizar Cheques"              NO-UNDO.

DEF VAR rel_nmcheque AS CHAR                                        NO-UNDO.
DEF VAR rel_dscpfcgc AS CHAR                                        NO-UNDO.

DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                        NO-UNDO.

DEF VAR h-b1wgen0009 AS HANDLE                                      NO-UNDO.


DEF FRAME f_visualiza
    tel_dsvisual HELP "Pressione <F4> ou <END> para finalizar" 
    WITH SIZE 76 BY 15 ROW 6 COLUMN 3 USE-TEXT NO-BOX NO-LABELS OVERLAY.

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
     opc_dsimprim     AT 18 NO-LABEL FORMAT "x(8)"
     opc_dsobserv     AT 29 NO-LABEL FORMAT "x(11)"
     opc_dsvisual     AT 43 NO-LABEL FORMAT "x(18)"
     WITH ROW 7 COLUMN 2 NO-LABELS SIDE-LABELS OVERLAY WIDTH 78
          TITLE COLOR NORMAL " Consulta de Bordero " FRAME f_bordero.

DEFINE    FRAME f_observacao
          tel_dsobserv  HELP "Use <TAB> para sair"          
          SKIP
          btn_btaosair  HELP "Tecle <Enter> para sair." AT 37
          WITH ROW 14 CENTERED NO-LABELS OVERLAY TITLE  " Observacoes ".

/* .......................................................................... */

DO WHILE TRUE TRANSACTION ON ERROR UNDO, RETURN:

   FIND crapbdc WHERE RECID(crapbdc) = par_recid NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapbdc   THEN
        RETURN.

   IF   crapbdc.insitbdc > 2   THEN
        DO:
            MESSAGE "O bordero deve estar na situacao"
                    "EM ESTUDO ou ANALISADO.".
            RETURN.
        END.
     
   FIND crapldc WHERE crapldc.cdcooper = glb_cdcooper       AND
                      crapldc.cddlinha = crapbdc.cddlinha   AND
                      crapldc.tpdescto = 2  
                      NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapldc   THEN
        RETURN.

   /*  Operadores ........................................................... */

  /*  Quem digitou  */
   FIND crapope WHERE crapope.cdcooper = glb_cdcooper       AND
                      crapope.cdoperad = crapbdc.cdoperad   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapope   THEN
        tel_dsopedig = STRING(crapbdc.cdoperad) + "- NAO CADASTRADO".
   ELSE
        tel_dsopedig = ENTRY(1,crapope.nmoperad," ").

   IF   crapbdc.dtlibbdc <> ?   THEN                        /*  Quem liberou  */
        DO:
            FIND crapope WHERE crapope.cdcooper = glb_cdcooper      AND
                               crapope.cdoperad = crapbdc.cdopelib  
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapope   THEN
                 tel_dsopelib = STRING(crapbdc.cdopelib) + "- NAO CADASTRADO".
            ELSE
                 tel_dsopelib = ENTRY(1,crapope.nmoperad," ").
        END.

   /* Documentos computados ................................................. */

   FIND craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                      craplot.dtmvtolt = crapbdc.dtmvtolt   AND
                      craplot.cdagenci = crapbdc.cdagenci   AND
                      craplot.cdbccxlt = crapbdc.cdbccxlt   AND
                      craplot.nrdolote = crapbdc.nrdolote
                      NO-LOCK NO-ERROR.
                       
   IF   NOT AVAILABLE craplot   THEN
        ASSIGN tel_qtcheque = 0
               tel_vlcheque = 0.
   ELSE
        ASSIGN tel_qtcheque = craplot.qtcompln
               tel_vlcheque = craplot.vlcompcr.

   /* ....................................................................... */

   ASSIGN tel_dspesqui = STRING(crapbdc.dtmvtolt,"99/99/9999") + "-" +
                         STRING(crapbdc.cdagenci,"999")        + "-" +
                         STRING(crapbdc.cdbccxlt,"999")        + "-" +
                         STRING(crapbdc.nrdolote,"999999")     + "-" +
                         STRING(crapbdc.hrtransa,"HH:MM:SS")
                
          tel_dsdlinha = STRING(crapbdc.cddlinha,"999") + "-" +
                         crapldc.dsdlinha.

   DISPLAY tel_dspesqui      crapbdc.nrborder  crapbdc.nrctrlim 
           tel_dsdlinha      tel_qtcheque      tel_dsopedig 
           tel_vlcheque      crapbdc.txmensal  crapbdc.dtlibbdc
           crapbdc.txdiaria  tel_dsopelib      crapbdc.txjurmor 
           opc_dsimprim      opc_dsobserv      opc_dsvisual  
           WITH FRAME f_bordero.

   RUN fontes/confirma.p (INPUT "",
                         OUTPUT aux_confirma).

   IF   aux_confirma <> "S" THEN  
        LEAVE.

   RUN sistema/generico/procedures/b1wgen0009.p PERSISTENT SET h-b1wgen0009.

   RUN efetua_exclusao_bordero IN h-b1wgen0009 (INPUT glb_cdcooper,
                                                INPUT 0,
                                                INPUT 0,
                                                INPUT glb_cdoperad,
                                                INPUT glb_dtmvtolt,
                                                INPUT 1,
                                                INPUT crapbdc.nrdconta,
                                                INPUT 1,
                                                INPUT glb_nmdatela,
                                                INPUT crapbdc.nrborder,
                                                INPUT TRUE,
                                                INPUT TRUE,
                                               OUTPUT TABLE tt-erro).
   DELETE PROCEDURE h-b1wgen0009.

   IF   RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF   AVAIL tt-erro  THEN
                 MESSAGE tt-erro.dscritic.
            ELSE 
                 MESSAGE "Erro na exclusao do bordero. Tente novamente.".

            PAUSE 3 NO-MESSAGE.
            HIDE MESSAGE.
            LEAVE.
        END.
       
   RUN fontes/bordero_lst.p.

   LEAVE.
  
END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_bordero.

/* .......................................................................... */

