/* .............................................................................

   Programa: Fontes/taxrda.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Janeiro/2002.                   Ultima atualizacao: 02/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAXRDA.

   Alteracoes: 25/09/2003 - Atualizar campo de T.R usada (Margarete).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_dtinicon AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_tptaxcon AS INTE    FORMAT "9"                     NO-UNDO.

DEF        VAR tel_dtiniper AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_vlfaixas AS DECIMAL FORMAT "zzz,zz9.99"            NO-UNDO.
DEF        VAR tel_txdatrtr AS DECIMAL DECIMALS 6 FORMAT "zz9.999999" NO-UNDO.
DEF        VAR tel_tpvlinfo AS LOG     FORMAT "Oficial/Projetada"     NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "z9"                    NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                   NO-UNDO.
                                                                     
DEF        VAR aux_dtmvtolt AS DATE                                   NO-UNDO.

DEF        VAR aux_tptaxrda AS INTE               EXTENT 99           NO-UNDO.
DEF        VAR aux_vlfaixas AS DECIMAL            EXTENT 99           NO-UNDO.
DEF        VAR aux_txadical AS DECIMAL DECIMALS 6 EXTENT 99           NO-UNDO.

DEF        VAR aux_vllidtab AS CHAR                                   NO-UNDO.
DEF        VAR aux_qtdtxtab AS INTE                                   NO-UNDO.
DEF        VAR aux_cartaxas AS INTE                                   NO-UNDO.
DEF        VAR aux_flgexivl AS LOG                                    NO-UNDO.
DEF        VAR aux_dtfimper AS DATE    FORMAT 99/99/9999              NO-UNDO.
DEF        VAR aux_qtdiaute AS INTE                                   NO-UNDO.
DEF        VAR aux_txprodia AS DECIMAL DECIMALS 6                     NO-UNDO.
DEF        VAR aux_vltxadic AS DECIMAL DECIMALS 6                     NO-UNDO.
DEF        VAR aux_prmconsu AS LOG                                    NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela
     FRAME f_moldura.

FORM glb_cddopcao AT  03 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (A, C ou I)."
                        VALIDATE(CAN-DO("A,C,I",glb_cddopcao),
                                 "014 - Opcao errada.")
     
     WITH ROW 6 COLUMN 3 NO-BOX NO-LABEL SIDE-LABELS OVERLAY  FRAME f_opcao.

FORM SKIP(3)
     tel_tpvlinfo     AT 03  LABEL "Oficial/Projetada" AUTO-RETURN
                             HELP "Informe se a taxa e a oficial ou a projetada"
                             /*  Magui 22/02/2002
                             VALIDATE(tel_tpvlinfo = yes,
                                      "513 - Tipo errado")
                                      ***/
     SKIP(1)                                 
     tel_dtiniper     AT 16  LABEL "Data" AUTO-RETURN
                        HELP "Entre com a data inicial de referencia."
                        VALIDATE(tel_dtiniper <> ?,"013 - Data errada.")
    
     SKIP(1)
     tel_txdatrtr     AT 16  LABEL "T.R." AUTO-RETURN
                         HELP "Entr com o valor da T.R."
      
     WITH ROW 7 COLUMN 3 NO-BOX NO-LABEL SIDE-LABELS OVERLAY  FRAME f_taxrda.

/* variaveis para mostrar a consulta por tipo e data */          
 
FORM tel_tptaxcon  AT 15 LABEL "Tipo de Taxa" AUTO-RETURN
                   HELP "1 RDCA, 2 Poup.Progr., 3 RDCA60"
                   VALIDATE(CAN-DO("1,2,3",STRING(tel_tptaxcon)),
                            "014 - Opcao errada.") 
     tel_dtinicon  AT 32 LABEL "Data"
                   VALIDATE(tel_dtinicon <> ?, "013 - Data errada.")
     tel_vlfaixas  AT 50 LABEL "Faixa"
                   HELP "Entre com o valor da faixa"
     SKIP(8)
     
     WITH ROW 7 COLUMN 3 NO-BOX NO-LABELS SIDE-LABELS OVERLAY
          FRAME f_consulta.
      
DEF QUERY  bcraptr1-q FOR craptrd.
DEF BROWSE bcraptr1-b QUERY bcraptr1-q
      DISP dtiniper
           qtdiaute                     COLUMN-LABEL "Ut"
           txofimes                     COLUMN-LABEL "Mensal"
           txofidia                     COLUMN-LABEL "Diaria"
           txprodia                     COLUMN-LABEL "Projetada"
           vltrapli                     COLUMN-LABEL "T.R. Usada"
           WITH 9 DOWN OVERLAY.    

DEF FRAME f_tipo_data
          bcraptr1-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8.
/**********************************************/

ASSIGN  glb_cddopcao = "C"
        glb_cdcritic = 0.

VIEW FRAME f_moldura.

ASSIGN aux_tptaxrda = 0
       aux_vlfaixas = 0
       aux_txadical = 0
       aux_contador = 0.
       
FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                       craptab.nmsistem = "CRED"           AND
                       craptab.tptabela = "CONFIG"         AND
                       craptab.cdacesso = "TXADIAPLIC"     NO-LOCK:
                       
    DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):
       ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
              aux_contador = aux_contador + 1
              aux_tptaxrda[aux_contador] = craptab.tpregist
              aux_txadical[aux_contador] = DECIMAL(ENTRY(2,aux_vllidtab,"#"))
              aux_vlfaixas[aux_contador] = DECIMAL(ENTRY(1,aux_vllidtab,"#")).
    END.
END.                  

PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   IF  glb_cdcritic <> 0 THEN
       DO:
          RUN fontes/critic.p.
          BELL.
          MESSAGE glb_dscritic.
          glb_cdcritic = 0.
       END.

   VIEW FRAME f_opcao.
   VIEW FRAME f_taxrda.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      HIDE FRAME f_consulta.
      
      UPDATE glb_cddopcao WITH FRAME f_opcao.
      
      IF   glb_cddopcao = "C"   THEN
           DO:
               ASSIGN aux_prmconsu = YES.
               HIDE FRAME f_taxrda.
               VIEW FRAME f_consulta.
           END.
           
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "taxrda"   THEN
                 DO:
                     HIDE FRAME f_moldura.
                     HIDE FRAME f_taxrda.
                     HIDE FRAME f_consulta.
                     HIDE FRAME f_tipo_data.
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

   ASSIGN tel_dtiniper = ?
          tel_vlfaixas = 0
          tel_txdatrtr = 0
          tel_tpvlinfo = YES.
   
   IF   glb_cddopcao = "A"   THEN
        DO:
            { includes/taxrdaa.i }   
        END.
   ELSE      
        IF   glb_cddopcao = "C"   THEN
             DO:
                 ASSIGN tel_tptaxcon = 1.
                 { includes/taxrdac.i }
             END.
        ELSE
             IF   glb_cddopcao = "I"   THEN
                  DO:
                      { includes/taxrdai.i }
                  END.
END.
            
/* .......................................................................... */
