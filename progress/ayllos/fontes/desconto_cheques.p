/* .............................................................................

   Programa: Fontes/desconto_cheques.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003                          Ultima atualizacao: 17/09/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratar limite de descontos de cheques para a tela
               ATENDA.

   Alteracoes: 30/07/2003 - Inclusao da rotina ver_cadastro (Julio).
   
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               19/09/2006 - Permitir o uso do F2-AJUDA (Evandro).

               10/09/2007 - Conversao de rotina ver_capital e 
                            ver_cadastro para BO (Sidnei/Precise)

               17/09/2008 - Alteraca chave de acesso a tabela crapldc
                            (Gabriel).

............................................................................. */

{ includes/var_online.i }

{ includes/var_atenda.i }

{ sistema/generico/includes/var_internet.i }
DEF VAR h-b1wgen0001 AS HANDLE                                       NO-UNDO.

DEF STREAM str_1.

DEF VAR tel_dsborder AS CHAR    FORMAT "x(8)" INIT "Borderos"        NO-UNDO.
DEF VAR tel_dslimite AS CHAR    FORMAT "x(6)" INIT "Limite"          NO-UNDO.

DEF VAR tel_vllimite AS DECI                                         NO-UNDO.
DEF VAR tel_nrctrlim AS INT                                          NO-UNDO.
DEF VAR tel_qtdiavig AS INT                                          NO-UNDO.
DEF VAR tel_vlalugue AS DECI                                         NO-UNDO.
DEF VAR tel_vloutras AS DECI                                         NO-UNDO.
DEF VAR tel_vlsalari AS DECI                                         NO-UNDO.
DEF VAR tel_vlsalcon AS DECI                                         NO-UNDO.
DEF VAR tel_dsobserv AS CHAR                                         NO-UNDO.

DEF VAR tel_qtrenova AS INT                                          NO-UNDO.
DEF VAR tel_vlutiliz AS DECIMAL                                      NO-UNDO.
DEF VAR tel_qtutiliz AS INT                                          NO-UNDO.

DEF VAR tel_nrctrpro AS INT                                          NO-UNDO.
DEF VAR tel_cdmotivo AS INT                                          NO-UNDO.
DEF VAR tel_dtinivig AS DATE                                         NO-UNDO.
DEF VAR tel_dtfimvig AS DATE                                         NO-UNDO.
DEF VAR tel_dsdlinha AS CHAR                                         NO-UNDO.
DEF VAR tel_cdldscto AS INT                                          NO-UNDO.
DEF VAR tel_vlfatura AS DECIMAL                                      NO-UNDO.
DEF VAR tel_txjurmor AS DECIMAL DECIMALS 7                           NO-UNDO.
DEF VAR tel_vldmulta AS DECIMAL                                      NO-UNDO.
DEF VAR tel_vlmedchq AS DECIMAL                                      NO-UNDO.
DEF VAR tel_dsramati AS CHAR                                         NO-UNDO.

DEF VAR opcao        AS INT                                          NO-UNDO.
DEF VAR p_opcao      AS CHAR    EXTENT 2 INIT ["Borderos","Limite"]  NO-UNDO.

DEF VAR tab_cddopcao AS CHAR    EXTENT 9 INIT ["B","L"]              NO-UNDO.

FORM SKIP(1)
     tel_nrctrlim AT  9 FORMAT " z,zzz,zz9"     LABEL "Contrato"
     tel_dtinivig AT 33 FORMAT "99/99/9999"     LABEL "Inicio"
     tel_qtdiavig AT 56 FORMAT "zz9"            LABEL "Vigencia"
     "dias"      
     SKIP(1)
     tel_vllimite AT 11 FORMAT "zzz,zzz,zz9.99" LABEL "Limite"
     tel_qtrenova AT 52 FORMAT "9" LABEL "Renovado por" "vezes"
     SKIP(1)
     tel_dsdlinha AT 10 FORMAT "x(40)"          LABEL "Linha de Descontos"
     SKIP(1)
     tel_vlutiliz AT 13 FORMAT "zzz,zzz,zz9.99" LABEL "Valor utilizado"
     "("          AT 46
     tel_qtutiliz AT 47 FORMAT "zz,zz9" NO-LABEL
     "cheques)"
     SKIP(1)
     WITH ROW 9 CENTERED SIDE-LABELS NO-LABELS OVERLAY TITLE COLOR NORMAL
          " Desconto de Cheques " WIDTH  78 FRAME f_limite.

FORM SPACE(30)
     p_opcao[1] FORMAT "x(8)" 
     p_opcao[2] FORMAT "x(6)"
     SPACE(31)
     WITH ROW 20 CENTERED NO-BOX NO-LABELS OVERLAY FRAME f_opcoes.


RUN sistema/generico/procedures/b1wgen0001.p
    PERSISTENT SET h-b1wgen0001.
        
IF   VALID-HANDLE(h-b1wgen0001)   THEN
DO:
     RUN ver_capital IN h-b1wgen0001(INPUT  glb_cdcooper,
                                     INPUT  tel_nrdconta,
                                     INPUT  0, /* cod-agencia */
                                     INPUT  0, /* nro-caixa   */
                                     0,
                                     INPUT  glb_dtmvtolt,
                                     INPUT  "desconto_cheques",
                                     INPUT  1, /* AYLLOS */
                                     OUTPUT TABLE tt-erro).
     /* Verifica se houve erro */
     FIND FIRST tt-erro NO-LOCK NO-ERROR.

     IF   AVAILABLE tt-erro   THEN
     DO:
          ASSIGN glb_cdcritic = tt-erro.cdcritic
                 glb_dscritic = tt-erro.dscritic.
     END.
     ELSE
     DO:
          RUN ver_cadastro IN h-b1wgen0001(INPUT  glb_cdcooper,
                                           INPUT  tel_nrdconta,
                                           INPUT  0, /* cod-agencia */
                                           INPUT  0, /* nro-caixa   */
                                           INPUT  glb_dtmvtolt,
                                           INPUT  1, /* AYLLOS */
                                           OUTPUT TABLE tt-erro).

          /* Verifica se houve erro */
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
          IF   AVAILABLE tt-erro   THEN
          DO:
               ASSIGN glb_cdcritic = tt-erro.cdcritic
                      glb_dscritic = tt-erro.dscritic.
          END.
     END.
     DELETE PROCEDURE h-b1wgen0001.
END.
/************************************/
    
IF   glb_cdcritic > 0   THEN
     RETURN.

HIDE MESSAGE NO-PAUSE.
   
FIND FIRST craplim WHERE craplim.cdcooper = glb_cdcooper    AND
                         craplim.nrdconta = tel_nrdconta    AND
                         craplim.tpctrlim = 2               AND
                         craplim.insitlim = 2  /* ATIVO */  NO-LOCK NO-ERROR.                                
IF   NOT AVAILABLE craplim   THEN 
     DO:
         ASSIGN tel_nrctrlim = 0
                tel_dtinivig = ?
                tel_qtdiavig = 0
                tel_vllimite = 0
                tel_qtrenova = 0
                tel_dsdlinha = ""
                tel_vlutiliz = 0
                tel_qtutiliz = 0
                opcao        = 2.
     END.
ELSE
     DO:
         /*FIND crapldc OF craplim NO-LOCK NO-ERROR.*/
         FIND crapldc WHERE crapldc.cdcooper = glb_cdcooper     AND
                            crapldc.cddlinha = craplim.cddlinha AND
                            crapldc.tpdescto = 2
                            NO-LOCK NO-ERROR.
           
         IF   NOT AVAILABLE crapldc   THEN
              tel_dsdlinha = STRING(craplim.cddlinha) + " - " +
                             "NAO CADASTRADA".
         ELSE
              tel_dsdlinha = STRING(crapldc.cddlinha) + " - " +
                             crapldc.dsdlinha.
                 
         ASSIGN tel_nrctrlim = craplim.nrctrlim
                tel_dtinivig = craplim.dtinivig
                tel_qtdiavig = craplim.qtdiavig
                tel_vllimite = craplim.vllimite
                tel_qtrenova = craplim.qtrenova
                opcao        = 1.
     END.

ASSIGN tel_vlutiliz = aux_vldscchq
       tel_qtutiliz = aux_qtdscchq.

DISPLAY tel_nrctrlim  tel_dtinivig  tel_qtdiavig 
        tel_vllimite  tel_qtrenova  tel_dsdlinha
        tel_vlutiliz  tel_qtutiliz  
        WITH FRAME f_limite.

PAUSE 0.

COLOR DISPLAY MESSAGE p_opcao[opcao] WITH FRAME f_opcoes. 
DISPLAY p_opcao WITH FRAME f_opcoes.

_pick:
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            MESSAGE glb_dscritic.
            BELL.
            glb_cdcritic = 0.
        END.

   glb_nmrotina = "DSC CHQS".
   
   READKEY.

   PAUSE 0.

   IF   CAN-DO("GO,RETURN",KEYFUNCTION(LASTKEY))   THEN
        DO: /*
            ASSIGN glb_cddopcao = tab_cddopcao[opcao]
                   glb_nmrotina = "DESCONTO CHEQUE".

            { includes/acesso.i }
            */
            IF   opcao = 1   THEN
                 DO:
                     glb_nmrotina = "DSC CHQS - BORDERO".
                     
                     RUN fontes/bordero.p.
                 END.
            ELSE
            IF   opcao = 2   THEN
                 DO:
                     glb_nmrotina = "DSC CHQS - LIMITE".
                     
                     RUN fontes/deschq.p.
                 END.

            NEXT _pick.
        END.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"   OR
        KEYFUNCTION(LASTKEY) = "CURSOR-UP"      OR
        KEYFUNCTION(LASTKEY) = " "              THEN
        DO:
            COLOR DISPLAY NORMAL p_opcao[opcao] WITH FRAME f_opcoes.
            opcao = opcao + 1.
            IF   opcao > 2   THEN
                 opcao = 1.
            COLOR DISPLAY MESSAGES p_opcao[opcao] WITH FRAME f_opcoes.
            DISPLAY p_opcao WITH FRAME f_opcoes.
        END.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
        KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
        DO:
            COLOR DISPLAY NORMAL p_opcao[opcao] WITH FRAME f_opcoes.
            opcao = opcao - 1.
            IF   opcao < 1   THEN
                 opcao = 2.
            COLOR DISPLAY MESSAGES p_opcao[opcao] WITH FRAME f_opcoes.
            DISPLAY p_opcao WITH FRAME f_opcoes.
        END.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        LEAVE _pick.
   ELSE
   IF   KEYFUNCTION(LASTKEY) = "HELP"   THEN
        APPLY "HELP".

END.

HIDE FRAME pick1    NO-PAUSE.
HIDE FRAME f_opcoes NO-PAUSE.
HIDE FRAME f_limite NO-PAUSE.

RELEASE crapass.
RELEASE craplim.

HIDE MESSAGE NO-PAUSE.

/* .......................................................................... */
