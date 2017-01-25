/* .............................................................................

   Programa: Fontes/tab004.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 07/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB004.

   Alteracoes: 10/11/94 - Alterado para incluir a taxa de saque sobre deposi-
                          tos bloqueados. (Deborah).

               28/04/97 - Alterado para permitir somente consulta das
                          tabelas (Edson).

                          DEVERA TER APENAS A OPCAO CONSULTA.
                          AS DEMAIS OPCOES SAO TRATADAS PELA TELA TAXMES.

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               11/04/2007 - Retirar campo Taxa de Cheque Especial, passa para a
                            tela TELAX (Ze).
                            
               12/06/2013 - Incluido a possibilidade de Alterar. (James) 
               
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
               
               23/07/2015 - Alterado var de tel_txjurneg para tel_txnegcal e 
                            tel_txjursaq para tel_txsaqcal. Adicionado var
                            tel_txnegfix e tel_txsaqfix. Adicionado campos de 
                            Taxa fixa. (Jorge - Rodrigo) - SD 307304
                            
               07/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_txnegcal AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR tel_txnegfix AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_txsaqcal AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR tel_txsaqfix AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR log_txjurneg AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR log_txjursaq AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.

DEF        VAR aux_dsacesso AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_dstexesp AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_dstexneg AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_dstexsaq AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

FORM SKIP (3)
     "Opcao:"     AT 4
     glb_cddopcao AT 11 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada (A,C)"
                  VALIDATE(CAN-DO("A,C",glb_cddopcao),"014 - Opcao errada.")
     SKIP (1)
     "Calculada"  AT 44
     "Fixa"       AT 60 
     SKIP (1)
     tel_txnegcal AT 15 LABEL "Taxa para Saldos Negativos" "%"
     tel_txnegfix AT 58 NO-LABEL AUTO-RETURN 
                  HELP
                  "Entre a taxa de juros a ser cobrada s/saldo medio negativo."
                  VALIDATE(tel_txnegfix > 0,"185 - Taxa errada.")
     "%"
     SKIP(1)
     tel_txsaqcal AT 15 LABEL "Taxa para Saque  Bloqueado" "%"
     tel_txsaqfix AT 58 NO-LABEL AUTO-RETURN 
                  HELP
                 "Entre com a taxa de juros a ser cobrada s/saque s/bloqueado."
                  VALIDATE(tel_txsaqcal > 0,"185 - Taxa errada.")
     "%"
     SKIP(6)
     WITH SIDE-LABELS TITLE COLOR MESSAGE " Taxas de Juros de Conta-Corrente"
          ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_tab004.

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_tab004.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TAB004"   THEN
                 DO:
                     HIDE FRAME f_tab004.
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

   ASSIGN tel_txnegcal = 0
          tel_txsaqcal = 0.

   IF   glb_cddopcao = "C" THEN
        DO:
            { includes/tab004c.i }
        END.
   ELSE

   /* Opcao = Alterar */
   IF glb_cddopcao = "A" THEN
        DO:
            /* Permissoes de acesso */
            IF  glb_cddepart <> 20 AND  /* TI       */
                glb_cddepart <> 14 THEN /* PRODUTOS */
                DO:
                    glb_cdcritic = 36.
                    NEXT.
                END.
            {includes/tab004a.i }
        END.
   
END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
