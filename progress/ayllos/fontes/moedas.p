/* .............................................................................

   Programa: Fontes/moedas.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/92.                       Ultima atualizacao: 28/07/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela MOEDAS.

   Alteracoes: 09/09/94 - Alterado valor da moeda para 8 casas decimais
                          (Deborah).

               15/03/95 - Alterado para aceitar tipo de moeda 12 (Odair).

               14/03/97 - Alterado para aceitar tipo de moedas 14 (Deborah).

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/01/2007 - Alterado help dos campos da tela (Elton).

               31/08/2009 - Alterado para aceitar tipo de moeda 8 - somente
                            CECRED (Fernando).
                            
               21/11/2011 - Inclusão da opção "R" para gerar o Relatório de 
                            Taxas e Inclusco do tipo 11-TR
                            (Isara - RKAM).
                            
               03/02/2014 - Incluido var aux_msgdolog  para log e inclusao de
                            campos no relatorio (Jean Michel).
                            
               21/02/2014 - Adicionado tpmoefix = 21 (IPCA) e alterado
                            para list-box o campo do tipo de moeda (tpmoefix).
                            (Fabricio)
                            
               30/06/2014 - Retirado as opcoes de POUP, SELIC Meta e TR, projeto
                            de novos produtos de captacao (Jean Michel)
                            
               28/07/2014 - Retirado a opcao de IPCA (Jean Michel).
                          
............................................................................. */

{ includes/var_online.i }

DEF STREAM str_1.

DEF        VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_tpmoefix AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_vlmoefix AS DECIMAL FORMAT "zzz,zzz,zz9.99999999" NO-UNDO.

DEF        VAR tel_dtinicio AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_dttermin AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR aux_dtmvtolt            LIKE   glb_dtmvtolt           NO-UNDO.

DEF        VAR aux_tpmoefix AS CHAR FORMAT "x(10)" VIEW-AS COMBO-BOX
    LIST-ITEMS "UFIR","IDTR","US$ PAR","US$ OF","URV","UFIR C.M."

    PFCOLOR 2 NO-UNDO.

DEF        VAR aux_vlmoefix AS DECIMAL FORMAT "zzz,zzz,zz9.99999999" NO-UNDO.
DEF        VAR aux_vlpoupan AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_flgderro AS LOGICAL                               NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtfimper AS DATE                                  NO-UNDO.
DEF        VAR aux_qtdiaute AS INT                                   NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR par_flgrodar AS LOGI INIT TRUE                        NO-UNDO.

DEF        VAR aux_msgdolog AS CHAR                                  NO-UNDO.

DEF        VAR tel_cddopcao AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR par_dscritic AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen0128 AS HANDLE                                NO-UNDO.

/* Cabecalho Relatorio */
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF        VAR rel_nrmodulo AS INTE    FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5        
                                            INIT ["","","","",""]    NO-UNDO.

/* Variaveis para a includes de impressao */
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR aux_flgescra AS LOGI                                  NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR par_flgfirst AS LOGI                                  NO-UNDO.
DEF        VAR par_flgcance AS LOGI                                  NO-UNDO.

DEF BUFFER b-crapmfx FOR crapmfx.


DEF TEMP-TABLE tt-taxas
    FIELD dtmvtolt      AS DATE FORMAT "99/99/9999"
    FIELD qtdiaute      AS INT  FORMAT "Z99"
    FIELD vlcdiano      AS DEC  FORMAT "zz9.99999999"
    FIELD vlcdidia      AS DEC  FORMAT "zz9.99999999"
    FIELD vlcdiacu      AS DEC  FORMAT "zz9.99999999"
    FIELD vlcdimes      AS DEC  FORMAT "zz9.99999999"
    FIELD vltaxaTR      AS DEC  FORMAT "zz9.99999999"
    FIELD vldapoup      AS DEC  FORMAT "zz9.99999999"
    FIELD vlpoupIR      AS DEC  FORMAT "zz9.99999999"
    FIELD vlpoupnr      AS DEC  FORMAT "zz9.99999999"
    FIELD vlponrir      AS DEC  FORMAT "zz9.99999999"
    FIELD vlpoupsl      AS DEC  FORMAT "zz9.99999999".


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.


FORM glb_cddopcao LABEL "Opcao" AUTO-RETURN
                  HELP "Informe a opcao desejada (A,C,E,I,R)."
                  VALIDATE(CAN-DO("A,C,E,I,R",glb_cddopcao),
                                  "014 - Opcao errada.")
     WITH ROW 8 COLUMN 28 SIDE-LABELS NO-BOX OVERLAY FRAME f_opcao.
     
FORM tel_dtinicio    LABEL "Data Inicio " AUTO-RETURN
                     HELP "Informe a data de inicio."
     SKIP(1)
     tel_dttermin    LABEL "Data Termino" AUTO-RETURN
                     HELP "Informe a data de termino."
     WITH ROW 10 COLUMN 21 SIDE-LABELS NO-BOX OVERLAY FRAME f_relatorio.


FORM tel_dtmvtolt    LABEL "Data " AUTO-RETURN
                     HELP "Informe a data de referencia."
                     VALIDATE(tel_dtmvtolt <> ?,"013 - Data errada.")
     SKIP(1)
     aux_tpmoefix    LABEL "Tipo " HELP "Selecione o tipo de indice/taxa."
     SKIP(1)
     tel_vlmoefix    LABEL "Valor" AUTO-RETURN
                     HELP "Informe o valor da moeda fixa."
                     VALIDATE(tel_vlmoefix > 0,
                              "164 - Valor da moeda errado.")
     SKIP(5)
     WITH ROW 10 COLUMN 28 SIDE-LABELS NO-BOX OVERLAY FRAME f_moedas.
     
FORM tt-taxas.dtmvtolt        LABEL "Data"             AT 1
     tt-taxas.qtdiaute        LABEL "Dias Uteis"
     tt-taxas.vlcdiano        LABEL "% CDI Ano"
     tt-taxas.vlcdidia        LABEL "% CDI Dia"
     tt-taxas.vlcdiacu        LABEL "% CDI Dia Acum."
     tt-taxas.vlcdimes        LABEL "% CDI Mes"
     tt-taxas.vltaxaTR        LABEL "% TR"
     tt-taxas.vldapoup        LABEL "% Poupanca" 
     tt-taxas.vlpoupIR        LABEL "% Poupanca + IR"
     tt-taxas.vlpoupnr        LABEL "% Poup. Nova Regra"
     tt-taxas.vlponrir        LABEL "% Poup. Nova + IR"
     tt-taxas.vlpoupsl        LABEL "% SELIC Meta"
     WITH DOWN NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 234 FRAME f_taxas.

FORM SKIP(3)
     "RELACAO  DE  TAXAS  DE  CAPTACAO" AT 41
     SKIP
     tel_dtinicio   AT 44 FORMAT "99/99/9999"
     " A "          AT 55
     tel_dttermin   AT 59 FORMAT "99/99/9999"
     SKIP(3)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 234 FRAME f_refere.

FORM SKIP(4)
     "Conferencia: _________________________________"
     SPACE(3)
     "Visto da Coordenacao: _________________________________" 
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_assina.

VIEW FRAME f_moldura.


PAUSE(0).

ASSIGN glb_cddopcao = "C".

ON RETURN OF aux_tpmoefix DO:

    CASE aux_tpmoefix:SCREEN-VALUE:

        WHEN "UFIR" THEN
            ASSIGN tel_tpmoefix = 2.

        WHEN "IDTR" THEN
            ASSIGN tel_tpmoefix = 3.

        WHEN "US$ PAR" THEN
            ASSIGN tel_tpmoefix = 4.

        WHEN "US$ OF" THEN
            ASSIGN tel_tpmoefix = 5.
       
        WHEN "URV" THEN
            ASSIGN tel_tpmoefix = 9.

       WHEN "UFIR C.M." THEN
            ASSIGN tel_tpmoefix = 12.

    END CASE.

    APPLY "GO".
END.
      

DO WHILE TRUE:
   FIND crapcop WHERE cdcooper = glb_cdcooper NO-LOCK NO-ERROR NO-WAIT.
    
   RUN fontes/inicia.p.
  
   CLEAR FRAME f_opcao.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN tel_dtmvtolt = glb_dtmvtolt
             tel_vlmoefix = 0
             tel_dtinicio = ?
             tel_dttermin = ?
             tel_tpmoefix = 0.

      UPDATE glb_cddopcao WITH FRAME f_opcao.

      IF   glb_cddopcao = "R" THEN
        UPDATE tel_dtinicio tel_dttermin WITH FRAME f_relatorio.
      ELSE
        UPDATE tel_dtmvtolt aux_tpmoefix WITH FRAME f_moedas.
        
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "MOEDAS"   THEN
                 DO:
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_moedas.
                     HIDE FRAME f_relatorio.
   
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   ASSIGN aux_dtmvtolt = tel_dtmvtolt
   /*       aux_tpmoefix = tel_tpmoefix*/
          tel_vlmoefix = 0.

   IF   glb_cdcooper <> 3 THEN
        DO:
            IF    (tel_tpmoefix = 11 OR tel_tpmoefix = 19 OR 
                   tel_tpmoefix = 21) AND
                  glb_cddopcao <> "C"  THEN
                  DO:
                      MESSAGE "Alteracao somente pela CENTRAL.".
                      NEXT.
                  END.
        END.
   ELSE
        IF (tel_tpmoefix = 11 OR tel_tpmoefix = 19 OR tel_tpmoefix = 21) AND
           glb_cddopcao = "E"  THEN
            DO:
                glb_cdcritic = 323. 
                RUN fontes/critic.p.
                MESSAGE glb_dscritic.
                glb_cdcritic = 0.
                NEXT.
            END.
                     
   /*  Tipo de Moeda 8-Poupança somente pode ser consultado  */
   IF    tel_tpmoefix = 8     AND
         glb_cddopcao <> "C"  THEN
         DO:
             glb_cdcritic = 323. 
             RUN fontes/critic.p.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             NEXT.
        END.
   

   IF   glb_cddopcao = "A" THEN
        DO:
            { includes/moedasa.i }
        END.
   ELSE
        IF   glb_cddopcao = "C" THEN
             DO:
                { includes/moedasc.i }
             END.
        ELSE
             IF   glb_cddopcao = "E"   THEN
                  DO:
                      { includes/moedase.i }
                  END.
             ELSE
                  IF   glb_cddopcao = "I"   THEN
                       DO:                
                           IF tel_tpmoefix = 11 OR tel_tpmoefix = 19 THEN
                                DO:
                                    IF   MONTH(tel_dtmvtolt) <>
                                         MONTH(glb_dtmvtolt) THEN
                                         DO:
                                             BELL.
                                             MESSAGE "Nao e possivel alterar " +                                                      "do mes anterior.".
                                             NEXT.
                                         END.
                                END.
                                             
                           { includes/moedasi.i }
                       END.
                   ELSE
                        IF   glb_cddopcao = "R"   THEN /* Relatorio de Taxas */
                             DO:
                                { includes/moedasr.i }
                             END.
END.
/* .......................................................................... */
