/* .............................................................................

   Programa: Fontes/taxcdi.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Novembro/2003.                  Ultima atualizacao: 17/11/2011 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAXCDI.

   Alteracoes: 02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
 
               01/09/2006 - Usar a maior taxa CDI ou POUP(moeda tipo 8) +
                            22,5 maior percentual de IR (Magui).

               19/09/2006 - Mostrar Taxa CDI e Poupanca e indicar a maior
                            remuneracao (Elton).
                             
               19/03/2009 - Adicionada procedure proc_crialog, usada
                            na opcoes de  alteracao e inclusao (Fernando).  
                            
               17/11/2011 - Retirar a opcao "I" e "A"
                          - Incluir a coluna CDI Acumulado na opcao "C"
                           (Isara - RKAM).
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_dtinicon AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_tptaxcon AS INTE    FORMAT "9"                     NO-UNDO.

DEF        VAR tel_dtiniper AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_vlfaixas AS DECIMAL FORMAT "zzz,zz9.99"            NO-UNDO.
DEF        VAR tel_txdatrtr AS DECIMAL DECIMALS 6 FORMAT "zz9.999999" NO-UNDO.
DEF        VAR tel_tpvlinfo AS LOG     FORMAT "Oficial/Projetada"     NO-UNDO.
DEF        VAR tel_vlmoefix AS DECIMAL DECIMALS 6 FORMAT "zz9.999999" NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "z9"                    NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                   NO-UNDO.
                                                                     
DEF        VAR aux_dtmvtolt AS DATE                                   NO-UNDO.

DEF        VAR aux_tptaxcdi AS INTE               EXTENT 99           NO-UNDO.
DEF        VAR aux_vlfaixas AS DECIMAL            EXTENT 99           NO-UNDO.
DEF        VAR aux_txadical AS DECIMAL DECIMALS 6 EXTENT 99           NO-UNDO.

DEF        VAR aux_vllidtab AS CHAR                                   NO-UNDO.
DEF        VAR aux_qtdtxtab AS INTE                                   NO-UNDO.
DEF        VAR aux_cartaxas AS INTE                                   NO-UNDO.
DEF        VAR aux_flgexivl AS LOG                                    NO-UNDO.
DEF        VAR aux_dtfimper AS DATE    FORMAT 99/99/9999              NO-UNDO.
DEF        VAR aux_qtdiaute AS INTE                                   NO-UNDO.
DEF        VAR aux_txprodia AS DECIMAL DECIMALS 6                     NO-UNDO.
DEF        VAR aux_txmespop AS DECIMAL DECIMALS 6                     NO-UNDO.
DEF        VAR aux_txdiapop AS DECIMAL DECIMALS 6                     NO-UNDO.
DEF        VAR aux_vltxadic AS DECIMAL DECIMALS 6                     NO-UNDO.
DEF        VAR aux_prmconsu AS LOG                                    NO-UNDO.

DEF        VAR aux_rentrcda AS DECIMAL FORMAT 9.999999                NO-UNDO.
DEF        VAR aux_rentpoup AS DECIMAL FORMAT 9.999999                NO-UNDO.

DEF TEMP-TABLE w-crapmfx                                              NO-UNDO
    FIELD cdcooper LIKE crapmfx.cdcooper
    FIELD dtmvtolt LIKE crapmfx.dtmvtolt
    FIELD vlmofx08 AS CHAR FORMAT "x(10)"   
    FIELD vlmofx16 AS CHAR FORMAT "x(10)"
    FIELD vlmofx17 AS CHAR FORMAT "x(10)".

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela
     FRAME f_moldura.

FORM glb_cddopcao AT  03 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (C)."
                        VALIDATE(CAN-DO("C",glb_cddopcao),
                                 "014 - Opcao errada.")
     WITH ROW 6 COLUMN 3 NO-BOX NO-LABEL SIDE-LABELS OVERLAY  FRAME f_opcao.

FORM SKIP(3)
     tel_tpvlinfo     AT 03  LABEL "Oficial/Projetada" AUTO-RETURN
                             HELP "Informe se a taxa e a oficial ou a projetada"
     SKIP(1)                                 
     tel_dtiniper     AT 16  LABEL "Data" AUTO-RETURN
                        HELP "Entre com a data inicial de referencia."
                        VALIDATE(tel_dtiniper <> ?,"013 - Data errada.")
    
     SKIP(1)
     tel_txdatrtr     AT 17  LABEL "CDI" AUTO-RETURN
                         HELP "Entre com o valor do CDI"
     SKIP(1)
     tel_vlmoefix     AT 12 LABEL "POUPANCA" AUTO-RETURN
                         HELP "Entre com o valor da POUPANCA"
     WITH ROW 7 COLUMN 3 NO-BOX NO-LABEL SIDE-LABELS OVERLAY  FRAME f_taxcdi.

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
      
DEF QUERY  bcraptr1-q FOR craptrd , w-crapmfx FIELDS(vlmofx08 vlmofx16 vlmofx17).
DEF BROWSE bcraptr1-b QUERY bcraptr1-q
      DISP dtiniper               FORMAT "99/99/99"  COLUMN-LABEL "Periodo"    
           qtdiaute               FORMAT "z9"        COLUMN-LABEL "Ut"
           txofimes               FORMAT "z9.999999" COLUMN-LABEL "Mensal"
           txofidia               FORMAT "z9.999999" COLUMN-LABEL "Diaria"
           txprodia               FORMAT "z9.999999" COLUMN-LABEL "Projetada" 
           w-crapmfx.vlmofx08     FORMAT "x(10)"     COLUMN-LABEL "POUPANCA"   
           w-crapmfx.vlmofx16     FORMAT "x(10)"     COLUMN-LABEL "CDI" 
           w-crapmfx.vlmofx17     FORMAT "x(10)"     COLUMN-LABEL "CDI Acum."
           WITH 9 DOWN OVERLAY.   

DEF FRAME f_tipo_data
          bcraptr1-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 WIDTH 120.
/**********************************************/

ASSIGN  glb_cddopcao = "C"
        glb_cdcritic = 0.

VIEW FRAME f_moldura.

ASSIGN aux_tptaxcdi = 0
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
              aux_tptaxcdi[aux_contador] = craptab.tpregist
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
   VIEW FRAME f_taxcdi.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      HIDE FRAME f_consulta.
      
      UPDATE glb_cddopcao WITH FRAME f_opcao.
      
      IF   glb_cddopcao = "C"   THEN
           DO:
               ASSIGN aux_prmconsu = YES.
               HIDE FRAME f_taxcdi.
               VIEW FRAME f_consulta.
           END.
           
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "taxcdi"   THEN
                 DO:
                     HIDE FRAME f_moldura.
                     HIDE FRAME f_taxcdi.
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
          tel_vlmoefix = 0
          tel_tpvlinfo = YES.
   
   IF   glb_cddopcao = "C"   THEN
        DO:
            ASSIGN tel_tptaxcon = 1.
            { includes/taxcdic.i }
        END.
END.
            
/* .......................................................................... */

PROCEDURE proc_crialog:

DEF       INPUT PARAMETER  aux_tpopcao AS CHAR                      NO-UNDO.
    
    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "       +
                     STRING(TIME,"HH:MM:SS") + "' --> '"                      +
                     " Operador "   + glb_cdoperad                            +
                      aux_tpopcao + " a taxa "                                +
                     STRING(tel_tpvlinfo,"Oficial/Projetada")                 +
                     " do dia "     + STRING(tel_dtiniper, "99/99/9999")      +
                     " CDI "       + STRING(tel_txdatrtr,"zz9.999999")        +
                     " e POUPANCA " + STRING(tel_vlmoefix,"zz9.999999")       +
                     " >> log/taxcdi.log").
                                     
END PROCEDURE.
/*...........................................................................*/                 
