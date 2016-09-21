/* .............................................................................

   Programa: Fontes/tab027.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Marco/2004                          Ultima alteracao: 15/03/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB027 - Tarifa para o Conta Negativa.
   
   Alteracoes: 12/04/2004 - Incluir Manutencao Tab.Tarifa DOC/TED (VLTARIF355)
                          - Incluir Manutencao Tab.Cheque Adminis (VLTARIF055)
                          - Incluir Manutencao Tab.Debito Conta C.(VLTARIFDCC)
                          - Tab.VLTARIFEST alterada para VLTARIFDIV(Mirtes)
                          - Incluido Vlr.Tarifa/Vlr.Cheque Baixo Vlr(Mirtes)

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               26/10/2006 - Incluido Tarifas Saque Cartao BB e Transf. Contas
                            do Cartao BB (David).
                            
               22/12/2006 - Alterado help dos campos da tela (Elton).

               23/01/2007 - Incluido campos para tarifas: (David)
                            > tel_vl2viacr - 2a. via de cartao magnetico
                            > tel_vlregccf - Renovacao de cheuqe especial
                            
               20/11/2007 - Alterado tel_vlregccf p/ tel_vlregccf
                            Tarifa para regularizacao CCF(Guilherme).
                            
               30/09/2011 - Incluir Tarifa Transferência entre Cooperativas.
                            Alinhar Labels a direita. (Gabriel).         
                            
               02/04/2012 - Incluir Tarifa TED Internet. (David Kruger)    
               
               15/03/2013 - Incluir tarifa transferencia interCooperativas
                            (Gabriel).                                         
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_vltarest AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vltardoc AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vltarchq AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vltardcc AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vltarchb AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vlchequb AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vlcardbb AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vltrnsbb AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vl2viacr AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vlregccf AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vltracoo AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vltarted AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vltrataa AS DECIMAL FORMAT "zz9.99"               NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.


FORM SKIP(1)
     glb_cddopcao AT  3 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                        HELP "Informe a opcao desejada (A ou C)."
                        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(1)
     tel_vltarest AT 28 LABEL "Tarifa Conta Negativa"
        HELP "Informe o valor da tarifa para Conta Negativa."
     SKIP
     tel_vltardoc AT 35 LABEL "Tarifa DOC/TED"     
        HELP "Informe o valor da tarifa para DOC/TED."
     SKIP
     tel_vltarted AT 30 LABEL "Tarifa TED Internet"
        HELP "Informe o valor da tarifa para TED/Internet."
     SKIP
     tel_vltarchq AT 21 LABEL "Tarifa Cheque Administrativo"
        HELP "Informe o valor da tarifa para Cheque Administrativo."
     SKIP
     tel_vltardcc AT 21 LABEL "Tarifa Debito Conta Corrente"
        HELP "Informe o valor da tarifa para Debito Conta Corrente."
     SKIP
     tel_vlchequb AT 4 LABEL "Cobrar Tarifa p/Cheque Vlr.Igual ou Abaixo de"
        HELP "Valor do cheque (igual ou abaixo de) para ser cobrado tarifa."
     SKIP
     tel_vltarchb AT 24 LABEL "Tarifa Cheque Baixo Valor"
        HELP "Informe o valor da tarifa para Cheques Baixo Valor."    
     SKIP
     tel_vlcardbb AT 27 LABEL "Tarifa Saque Cartao BB"
        HELP "Informe o valor da tarifa para Saques do Cartao BB."
     SKIP
     tel_vltrnsbb AT 9  LABEL "Tarifa Transferencias Contas (Cartao BB)"
        HELP "Informe a tarifa para Transferencias de Contas (Cartao BB)."
     SKIP
     tel_vl2viacr AT 11 LABEL "Tarifa Segunda Via de Cartao Magnetico"
        HELP "Informe a tarifa para Segunda Via de Cartao Magnetico."
     SKIP
     tel_vlregccf AT 25 LABEL "Tarifa Regularizacao CCF"
        HELP "Informe a tarifa para Renovacao de Cheque Especial."
     tel_vltracoo AT 05 LABEL "Tarifa Transf. entre Cooperativas Presencial"  
         HELP "Informe a tarifa de Transf. entre Cooperativas Presencial."
     tel_vltrataa AT 05 LABEL "Tarifa Transf. entre Cooperativas Eletronica"
         HELP "Informe a tarifa de Transf. entre Cooperativas Eletronica."
     WITH ROW 4 OVERLAY SIDE-LABELS SIZE 80 BY 18 TITLE glb_tldatela 
          FRAME f_tab027.


ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_tab027 NO-PAUSE.
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao  WITH FRAME f_tab027.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "tab027"   THEN
                 DO:
                     HIDE FRAME f_tab027.
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

   IF   glb_cddopcao = "A" THEN
        DO TRANSACTION ON ERROR UNDO, NEXT:
           
           DO WHILE TRUE:
              
              FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                                 craptab.nmsistem = "CRED"         AND
                                 craptab.tptabela = "USUARI"       AND
                                 craptab.cdempres = 00             AND
                                 craptab.cdacesso = "VLTARIFDIV"   AND
                                 craptab.tpregist = 1 
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE craptab   THEN
                   IF   LOCKED craptab   THEN
                        DO:
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.
                   ELSE
                        DO:
                            glb_cdcritic = 55.
                            LEAVE.
                        END.
              
              LEAVE.
              
           END.  /*  Fim do DO WHILE TRUE  */
           
           IF   glb_cdcritic > 0   THEN
                NEXT.

           ASSIGN tel_vltarest = DECIMAL(SUBSTR(craptab.dstextab,1,12)) 
                  tel_vltardoc = DECIMAL(SUBSTR(craptab.dstextab,14,12))
                  tel_vltarchq = DECIMAL(SUBSTR(craptab.dstextab,27,12))
                  tel_vltardcc = DECIMAL(SUBSTR(craptab.dstextab,40,12)) 
                  tel_vlchequb = DECIMAL(SUBSTR(craptab.dstextab,53,12)) 
                  tel_vltarchb = DECIMAL(SUBSTR(craptab.dstextab,66,12))
                  tel_vlcardbb = DECIMAL(SUBSTR(craptab.dstextab,79,12))
                  tel_vltrnsbb = DECIMAL(SUBSTR(craptab.dstextab,92,12))
                  tel_vl2viacr = DECIMAL(SUBSTR(craptab.dstextab,105,12))
                  tel_vlregccf = DECIMAL(SUBSTR(craptab.dstextab,118,12))
                  tel_vltracoo = DECIMAL(SUBSTR(craptab.dstextab,131,12))
                  tel_vltarted = DECIMAL(SUBSTR(craptab.dstextab,144,12))
                  tel_vltrataa = DECIMAL(SUBSTR(craptab.dstextab,157,12)).

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
              UPDATE tel_vltarest
                     tel_vltardoc
                     tel_vltarted
                     tel_vltarchq
                     tel_vltardcc
                     tel_vlchequb
                     tel_vltarchb
                     tel_vlcardbb
                     tel_vltrnsbb
                     tel_vl2viacr
                     tel_vlregccf
                     tel_vltracoo 
                     tel_vltrataa WITH FRAME f_tab027.

              RUN fontes/confirma.p (INPUT "",
                                    OUTPUT aux_confirma).

              IF   aux_confirma <> "S"   THEN
                   NEXT.                   

              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */
       
           IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                NEXT.

         ASSIGN
         SUBSTR(craptab.dstextab,1,12)   = STRING(tel_vltarest,"999999999.99") 
         SUBSTR(craptab.dstextab,14,12)  = STRING(tel_vltardoc,"999999999.99") 
         SUBSTR(craptab.dstextab,27,12)  = STRING(tel_vltarchq,"999999999.99")
         SUBSTR(craptab.dstextab,40,12)  = STRING(tel_vltardcc,"999999999.99") 
         SUBSTR(craptab.dstextab,53,12)  = STRING(tel_vlchequb,"999999999.99") 
         SUBSTR(craptab.dstextab,66,12)  = STRING(tel_vltarchb,"999999999.99")
         SUBSTR(craptab.dstextab,79,12)  = STRING(tel_vlcardbb,"999999999.99")
         SUBSTR(craptab.dstextab,92,12)  = STRING(tel_vltrnsbb,"999999999.99")
         SUBSTR(craptab.dstextab,105,12) = STRING(tel_vl2viacr,"999999999.99")
         SUBSTR(craptab.dstextab,118,12) = STRING(tel_vlregccf,"999999999.99")
         SUBSTR(craptab.dstextab,131,12) = STRING(tel_vltracoo,"999999999.99")
         SUBSTR(craptab.dstextab,144,12) = STRING(tel_vltarted,"999999999.99")
         SUBSTR(craptab.dstextab,157,12) = STRING(tel_vltrataa,"999999999.99").

         CLEAR FRAME f_tab027 NO-PAUSE.

        END.  /*  Fim do DO TRANSACTION  */
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:                         
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 00             AND
                               craptab.cdacesso = "VLTARIFDIV"   AND
                               craptab.tpregist = 1 
                               NO-LOCK NO-ERROR.
           
            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 55.
                     NEXT.
                 END.

            ASSIGN tel_vltarest = DECIMAL(SUBSTR(craptab.dstextab,1,12)) 
                   tel_vltardoc = DECIMAL(SUBSTR(craptab.dstextab,14,12))
                   tel_vltarchq = DECIMAL(SUBSTR(craptab.dstextab,27,12))
                   tel_vltardcc = DECIMAL(SUBSTR(craptab.dstextab,40,12)) 
                   tel_vlchequb = DECIMAL(SUBSTR(craptab.dstextab,53,12)) 
                   tel_vltarchb = DECIMAL(SUBSTR(craptab.dstextab,66,12))
                   tel_vlcardbb = DECIMAL(SUBSTR(craptab.dstextab,79,12))
                   tel_vltrnsbb = DECIMAL(SUBSTR(craptab.dstextab,92,12))
                   tel_vl2viacr = DECIMAL(SUBSTR(craptab.dstextab,105,12))
                   tel_vlregccf = DECIMAL(SUBSTR(craptab.dstextab,118,12))
                   tel_vltracoo = DECIMAL(SUBSTR(craptab.dstextab,131,12))
                   tel_vltarted = DECIMAL(SUBSTR(craptab.dstextab,144,12))
                   tel_vltrataa = DECIMAL(SUBSTR(craptab.dstextab,157,12)).

            DISPLAY tel_vltarest
                    tel_vltardoc
                    tel_vltarted
                    tel_vltarchq
                    tel_vltardcc
                    tel_vlchequb
                    tel_vltarchb
                    tel_vlcardbb
                    tel_vltrnsbb
                    tel_vl2viacr
                    tel_vlregccf
                    tel_vltracoo
                    tel_vltrataa WITH FRAME f_tab027.
        END.

   RELEASE craptab.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

