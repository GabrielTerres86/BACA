/* .............................................................................

   Programa: Fontes/lancstd.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                         Ultima atualizacao: 30/01/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar o resumo dos lancamentos digitados na tela LANCST -
               Lancamentos de cheques em custodia.
               
   Alteracoes: 12/09/2001 - Excluida a variavel tab_inchqcop (Junior).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
............................................................................. */

{ includes/var_online.i }

{ includes/var_lancst.i }

DEF VAR res_qtchqcop AS INT            FORMAT "zzz,zz9"              NO-UNDO.
DEF VAR res_qtchqmen AS INT            FORMAT "zzz,zz9"              NO-UNDO.
DEF VAR res_qtchqmai AS INT            FORMAT "zzz,zz9"              NO-UNDO.

DEF VAR res_vlchqcop AS DECIMAL        FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF VAR res_vlchqmen AS DECIMAL        FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF VAR res_vlchqmai AS DECIMAL        FORMAT "zzz,zzz,zz9.99"       NO-UNDO.

DEF VAR res_dschqcop AS CHAR           FORMAT "x(20)"                NO-UNDO.

DEF VAR tot_qtcheque AS INT            FORMAT "zzz,zz9"              NO-UNDO.
DEF VAR tot_vlcheque AS DECIMAL        FORMAT "zzz,zzz,zz9.99"       NO-UNDO.

FORM SKIP(1)
     res_dschqcop AT  3 NO-LABEL
     res_qtchqcop AT 24 NO-LABEL
     res_vlchqcop AT 34 NO-LABEL
     SKIP(1)
     res_qtchqmen AT  7 LABEL "Cheques Menores"
     res_vlchqmen AT 34 NO-LABEL
     SKIP(1)
     res_qtchqmai AT  7 LABEL "Cheques Maiores" 
     res_vlchqmai AT 34 NO-LABEL "( >=" tab_vlchqmai NO-LABEL ")  "
     SKIP(1)
     tot_qtcheque AT  8 LABEL "TOTAL DIGITADO"
     tot_vlcheque AT 34 NO-LABEL
     SKIP(1)
     WITH ROW 10 CENTERED SIDE-LABELS OVERLAY TITLE " Resumo da Digitacao "
          FRAME f_resumo.

/*  Acessa dados da cooperativa  */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         RETURN.
     END.

res_dschqcop = "Cheques " + STRING(crapcop.nmrescop,"x(11)") + ":".

HIDE MESSAGE NO-PAUSE.

/*  Le tabela com o valor dos cheques maiores  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "MAIORESCHQ"   AND
                   craptab.tpregist = 1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     tab_vlchqmai = 1.
ELSE
     tab_vlchqmai = DECIMAL(SUBSTRING(craptab.dstextab,01,15)).

MESSAGE "Aguarde! Gerando resumo da digitacao!".

PAUSE 0.

FOR EACH crapcst WHERE crapcst.cdcooper = glb_cdcooper   AND 
                       crapcst.dtmvtolt = tel_dtmvtolt   AND
                       crapcst.cdagenci = tel_cdagenci   AND
                       crapcst.cdbccxlt = tel_cdbccxlt   AND
                       crapcst.nrdolote = tel_nrdolote   NO-LOCK:

    IF   crapcst.inchqcop = 1   THEN               /*  Cheque da Cooperativa  */
         DO:
             ASSIGN res_qtchqcop = res_qtchqcop + 1
                    res_vlchqcop = res_vlchqcop + crapcst.vlcheque.
             NEXT.
         END.

    IF   crapcst.vlcheque >= tab_vlchqmai   THEN
         ASSIGN res_qtchqmai = res_qtchqmai + 1
                res_vlchqmai = res_vlchqmai + crapcst.vlcheque.
    ELSE
         ASSIGN res_qtchqmen = res_qtchqmen + 1
                res_vlchqmen = res_vlchqmen + crapcst.vlcheque.
 
END.  /*  Fim do FOR EACH  --  Leitura dos cheques em custodia  */

ASSIGN tot_qtcheque = res_qtchqcop + res_qtchqmen + res_qtchqmai
       tot_vlcheque = res_vlchqcop + res_vlchqmen + res_vlchqmai.

DISPLAY res_qtchqcop  res_qtchqmen  res_qtchqmai
        res_vlchqcop  res_vlchqmen  res_vlchqmai
        tot_qtcheque  tot_vlcheque  tab_vlchqmai
        res_dschqcop
        WITH FRAME f_resumo.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   PAUSE MESSAGE "Tecle algo para encerrar...".
   
   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */  

HIDE MESSAGE NO-PAUSE.
HIDE FRAME f_resumo NO-PAUSE.

/* .......................................................................... */

