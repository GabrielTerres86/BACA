/* .............................................................................

   Programa: fontes/pedido.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/92.                     Ultima atualizacao: 16/04/2012 
         
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela PEDIDO.

   Alteracoes: 03/04/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               28/06/99 - Tratar pedidos roubados (Odair)
               
               16/07/2003 - Declaracao da variavel aux_lsconta2 (Fernando).

               09/09/2004 - Tratar conta integracao (Margarete).

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               26/02/2009 - Substituir a leitura da tabela craptab pelo
                            ver_ctace.p para informacoes de conta convenio
                            (Sidnei - Precise IT)
                            
               16/04/2012 - Fonte substituido por pedidop.p (Tiago).             
............................................................................. */

DEF STREAM str_1.

{ includes/var_online.i }

DEF        BUFFER crabcch FOR crapcch.
DEF        BUFFER crabass5 FOR crapass.

DEF        VAR tel_nrpedido AS INT     FORMAT "zzzzz9"               NO-UNDO.
DEF        VAR tel_nrseqped AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_dtsolped AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_dtlibped AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_nrdctabb AS INT     FORMAT "zzzz,zz9,9"           NO-UNDO.
DEF        VAR tel_nrinital AS INT     FORMAT "zz,zzz"               NO-UNDO.
DEF        VAR tel_nrinichq AS INT     FORMAT "zzz,zzz,z"            NO-UNDO.
DEF        VAR tel_nrfintal AS INT     FORMAT "zz,zzz"               NO-UNDO.
DEF        VAR tel_nrfinchq AS INT     FORMAT "zzz,zzz,z"            NO-UNDO.
DEF        VAR tel_qtfolhas AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_dspedido AS CHAR    FORMAT "x(45)"                NO-UNDO.

DEF        VAR aux_nrchqini LIKE crapcch.nrchqini                    NO-UNDO.
DEF        VAR aux_nrchqfim LIKE crapcch.nrchqfim                    NO-UNDO.
DEF        VAR aux_nrposchq AS INT                                   NO-UNDO.
DEF        VAR aux_ctpsqitg LIKE craplcm.nrdctabb                    NO-UNDO.
DEF        VAR aux_nrdctitg LIKE crapass.nrdctitg                    NO-UNDO.
DEF        VAR aux_nrctaass AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR aux_contatal AS INT                                   NO-UNDO.
DEF        VAR aux_qtlibblq AS INT                                   NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgerros AS LOGICAL                               NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_dtemstal AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR aux_dtrettal AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR aux_lspedrou AS CHAR                                  NO-UNDO.

DEF        VAR aux_lscontas AS CHAR                                  NO-UNDO.

FORM SPACE(1) WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela
                   FRAME f_moldura.

FORM glb_cddopcao AT  3 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (B, C ou L)"
                        VALIDATE (glb_cddopcao = "B" OR glb_cddopcao = "C" OR
                                  glb_cddopcao = "L","014 - Opcao errada.")

     tel_nrpedido AT  15 LABEL "Numero do Pedido" AUTO-RETURN
                         HELP "Informe o numero do pedido"


     "T A L A O          C H E Q U E"                         AT 45
     SKIP(1)
     "  Ped. Seq  Solicit.   Liberado  Conta Base  Qtd. Folhas" AT  1
     "Inicial      Final"                                       AT 61
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_pedido.

FORM tel_nrpedido AT  1
     tel_nrseqped AT  8
     tel_dtsolped AT 12
     tel_dtlibped AT 23
     tel_dspedido AT 34
     WITH ROW 10 COLUMN 2 NO-BOX NO-LABELS 11 DOWN OVERLAY FRAME f_lanctos.

VIEW FRAME f_moldura.

PAUSE(0).

FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                   craptab.nmsistem = "CRED"          AND
                   craptab.tptabela = "USUARI"        AND
                   craptab.cdempres = 0               AND
                   craptab.cdacesso = "PEDROUBADO"    AND
                   craptab.tpregist = 0               NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     aux_lspedrou = "".
ELSE
     aux_lspedrou = craptab.dstextab.

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 0,
                       OUTPUT aux_lscontas).

IF   aux_lscontas = "" THEN
     DO:
         glb_cdcritic = 393.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
         RETURN.
     END.

glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_pedido.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "PEDIDO"   THEN
                 DO:
                     HIDE FRAME f_pedido.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "B"   THEN
        DO:
            { includes/pedidob.i }
        END.
   ELSE                                                 
        IF   glb_cddopcao = "C"   THEN
             DO:
                 { includes/pedidoc.i }
             END.    
        ELSE
             IF   glb_cddopcao = "L"   THEN
                  DO:
                      { includes/pedidol.i }
                  END.                                  
                      
END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */


