/* .............................................................................

   Programa: Fontes/transf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Outubro/91                      Ultima Atualizacao: 10/10/2006
                                                                           
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TRANSF.

   Alteracoes: 17/04/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               09/12/98 - Eliminar a mensagem de solicitacao ao CPD (Deborah).
               
               02/07/2000 - Duplicar on_line a conta (Odair)
               
               02/01/2002 - Transferir o valor minimo do capital quando uma 
                            conta for duplicada.

               10/09/2004 - Retirada opcao tel_tptransa = 1(Transf)(Mirtes)

               21/09/2004 - Atualiza numero Conta Investimento - Campo
                            crapass.nrctainv(Mirtes).
                            
               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                      
               23/05/2006 - Criar crapenc na duplicacao (Magui).  
                    
               07/08/2006 - Desabilitada Opcao "E" (David).
               
               02/10/2006 - Alterado help dos campos (Elton).
               
               10/10/2006 - Alterado help do campo opcao (Elton).
............................................................................. */

{ includes/var_online.i } 

DEF BUFFER crabass FOR crapass.
DEF BUFFER crabcot FOR crapcot.
DEF BUFFER crabenc FOR crapenc.
DEF BUFFER crabcje FOR crapcje.
DEF BUFFER crabjur FOR crapjur.
DEF BUFFER crabavt FOR crapavt.
DEF BUFFER crabttl FOR crapttl.
DEF BUFFER crabtfc FOR craptfc.

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_nrsconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nrmatric AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_tptransa AS INT     FORMAT "z"                    NO-UNDO.
DEF        VAR tel_dstransa AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR tel_sttransa AS CHAR    FORMAT "x(20)"                NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_nrsconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.

DEF        VAR aux_vlcapmin AS DECIMAL                               NO-UNDO.

DEF VAR aux_nrdconta LIKE crapass.nrdconta                      NO-UNDO.
DEF VAR aux_digito   AS INT     INIT 0                          NO-UNDO.
DEF VAR aux_posicao  AS INT     INIT 0                          NO-UNDO.
DEF VAR aux_peso     AS INT     INIT 9                          NO-UNDO.
DEF VAR aux_calculo  AS INT     INIT 0                          NO-UNDO.
DEF VAR aux_resto    AS INT     INIT 0                          NO-UNDO.
DEF VAR aux_numero   AS CHAR                                    NO-UNDO.

 
FORM SKIP (2)
     "                 Opcao:" AT 3
     glb_cddopcao              AT 27 NO-LABEL AUTO-RETURN
                               HELP "Informe a opcao desejada (C,I)."
                               VALIDATE(glb_cddopcao = "C" OR
                                        glb_cddopcao = "I",
                                        "014 - Opcao errada.")
     SKIP (1)
     "     Conta/dv original:" AT 3
     tel_nrdconta              AT 27 NO-LABEL AUTO-RETURN
                               HELP "Informe o numero da conta."
     tel_nmprimtl              AT 38 NO-LABEL
     SKIP (1)
     " Conta/dv a ser criada:" AT 3
     tel_nrsconta              AT 27 NO-LABEL AUTO-RETURN
                              HELP "Informe o numero da conta que sera criada."
     SKIP (1)
     "Matricula do cooperado:" AT 3
     tel_nrmatric              AT 27 NO-LABEL AUTO-RETURN
                               HELP "Informe a matricula do cooperado."
     SKIP (1)
     "     Tipo da transacao:" AT 3
     tel_tptransa              AT 27 NO-LABEL
                               HELP
                               "Informe '2' para conta duplicada."
                               VALIDATE( tel_tptransa = 2,
                                        "129 - Tipo de transacao errado")
     tel_dstransa              AT 28 NO-LABEL
     SKIP (1)
     " Situacao da transacao:" AT 3
     tel_sttransa              AT 27 NO-LABEL
     SKIP (3)
     WITH SIDE-LABELS
     TITLE COLOR MESSAGE " Transferencia e Duplicacao de Matricula "
           ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_transf.
           
FORM  " Confirme conta/dv a ser criada:" AT 3
      aux_nrsconta            AT 37 NO-LABEL AUTO-RETURN
      HELP "Entre com a conta a ser criada para confirmacao."
      "  "
      WITH  ROW 11 COLUMN 14 OVERLAY FRAME f_verifica.

glb_cddopcao = "C".

DO WHILE TRUE:

        RUN fontes/inicia.p.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
           UPDATE glb_cddopcao WITH FRAME f_transf.
          
           LEAVE.
        
        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "TRANSF"   THEN
                      DO:
                          HIDE FRAME f_transf.
                          HIDE FRAME f_verifica.
                          RETURN.
                      END.
                 ELSE
                      NEXT.
             END.

        IF   aux_cddopcao <> glb_cddopcao   THEN
             DO:
                 { includes/acesso.i }
                 aux_cddopcao = glb_cddopcao.
             END.

        IF   glb_cddopcao = "C" THEN
             DO:
                 { includes/transfc.i }
             END.
        ELSE
             IF   glb_cddopcao = "I" THEN
                  DO:
                      { includes/transfi.i }
                  END.
            
             /** David 07/08/2006 - Sem funcionalidade no momento **
             ELSE
                  IF   glb_cddopcao = "E" THEN
                       DO:
                           { includes/transfe.i }
                       END.
             ** Fim do comentario **/
        
END.

/* .......................................................................... */
