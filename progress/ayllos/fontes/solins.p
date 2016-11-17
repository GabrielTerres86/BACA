/*..............................................................................

   Programa: Fontes/solins.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Janeiro/2008                    Ultima Atualizacao: 30/10/2013

   Dados referentes ao programa:

   Frequencia: Diario(on-line)
   Objetivo  : Mostrar a tela SOLINS - Modulo de pgto do INSS
   
   Alteracoes: 19/02/2008 - Alterado para gerar log/solins.log (Gabriel).
               
               24/02/2010 - Remove o arquivo solins.txt apos a impressao 
                            (Elton).
                            
               18/11/2011 - Centralizado toda a regra pertinente ao cadastro
                            da solicitacao na b1wgen0113.
                            Motivo: utilizado tanto para Ayllos Web 
                                    quanto caracter.
                            (Fabricio)
                            
               22/12/2011 - Correcoes solicitadas na tarefa 42237, sobre
                            tratamento de erros, e leituras de tabela fisica
                            (Tiago).       
               
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
               
               30/10/2013 - Corrigida a saida da tela no update do PA (Carlos)                   
..............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0091tt.i }

DEF   VAR tel_cdagenci LIKE crapcbi.cdagenci                           NO-UNDO.
DEF   VAR tel_nmrecben LIKE crapcbi.nmrecben           FORMAT "x(31)"  NO-UNDO.
DEF   VAR tel_nrbenefi LIKE crapcbi.nrbenefi                           NO-UNDO.
DEF   VAR tel_nrrecben LIKE crapcbi.nrrecben                           NO-UNDO.
DEF   VAR tel_cdmotsol LIKE crapsci.cdmotsol           FORMAT "z"      NO-UNDO.
DEF   VAR tel_tpsolici LIKE crapsci.cdmotsol           FORMAT "z"      NO-UNDO.
DEF   VAR tel_nrseqdig AS   INTEGER                                    NO-UNDO.
                                                                      
DEF   VAR aux_confirma AS   CHARACTER                  FORMAT "!(1)"   NO-UNDO.
DEF   VAR aux_cddopcao AS   CHARACTER                                  NO-UNDO.

DEF   VAR aux_nmarqimp AS   CHARACTER                                  NO-UNDO.
DEF   VAR aux_nmarqpdf AS   CHARACTER                                  NO-UNDO.
DEF   VAR aux_nmendter AS   CHARACTER                                  NO-UNDO. 
DEF   VAR aux_contador AS   INTEGER                                    NO-UNDO.
DEF   VAR par_flgrodar AS   LOGICAL    INITIAL TRUE                    NO-UNDO.
DEF   VAR aux_flgescra AS   LOGICAL                                    NO-UNDO.
DEF   VAR aux_dscomand AS   CHARACTER                                  NO-UNDO.
DEF   VAR aux_qtregist AS   INTEGER                                    NO-UNDO.
DEF   VAR par_flgfirst AS   LOGICAL    INITIAL TRUE                    NO-UNDO. 
DEF   VAR tel_dsimprim AS   CHARACTER  INIT "Imprimir" FORMAT "x(8)"   NO-UNDO.
DEF   VAR tel_dscancel AS   CHARACTER  INIT "Cancelar" FORMAT "x(8)"   NO-UNDO.
DEF   VAR par_flgcance AS   LOGICAL                                    NO-UNDO.

DEF   VAR aux_dscritic AS   CHARACTER                                  NO-UNDO.
                                                                         
      /* Variavel para verificar se o campo foi alterado */
DEF   VAR aux_cdmotsol LIKE crapsci.cdmotsol                           NO-UNDO.

      /* Variavel para gerar log */
DEF   VAR aux_tpsolici AS   CHARACTER                                  NO-UNDO.

DEF   VAR h-b1crap85   AS   HANDLE                                     NO-UNDO.
DEF   VAR h-b1wgen0113 AS   HANDLE                                     NO-UNDO.
DEF   VAR h-b1wgen0091 AS   HANDLE                                     NO-UNDO.

DEF  QUERY   q_nome    FOR  tt-benefic.
                                                                            
DEF  BROWSE  b_nome QUERY q_nome
     DISPLAY tt-benefic.nmrecben COLUMN-LABEL "Nome" FORMAT "x(30)"
             tt-benefic.nrbenefi COLUMN-LABEL "NB"
             tt-benefic.nrrecben COLUMN-LABEL "NIT"
             WITH 5 DOWN TITLE " Nomes dos Beneficiarios ".

FORM SKIP(2)
     
     tel_cdagenci  AT 05
         HELP "Informe o numero do PA."
         VALIDATE(tel_cdagenci <> " ", "Numero do PA incorreto.")
      
     tel_nmrecben  AT 25 LABEL "Beneficiario"    
         HELP "Informe o nome do beneficiario ou pressione <ENTER> p/ listar."
     
     SKIP   
     tel_nrbenefi  AT 05 LABEL "NB " FORMAT "zzzzzzzzzz"  
         HELP "Informe o numero identificador do beneficio."
         VALIDATE(tel_nrbenefi <> " ", "357 - O campo deve ser prenchido.")
         
     tel_nrrecben  AT 34 LABEL "NIT" FORMAT "zzzzzzzzzzz"  
         HELP "Informe o numero de identificacao do recebedor do beneficio."
         VALIDATE(tel_nrrecben <> "", "357 - O campo deve ser prenchido.")
               
     SKIP(2)
     tel_tpsolici  AT 05  LABEL "Opcoes"
         HELP "Informe a opcao (1- 2a. Via de cartao, 2- 2a. Via de senha)"
         VALIDATE (tel_tpsolici = 1 OR tel_tpsolici = 2, "Opcao incorreta.")
     
     SKIP(4) 
     tel_cdmotsol  AT 05 LABEL "Motivo da solicitacao"
     
     
     SKIP(4)
     WITH OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_solins.
     
     
FORM SKIP
     
     b_nome HELP "Use as SETAS para navegar ou F4 para sair"
     WITH NO-BOX ROW 9 WIDTH 59 SIDE-LABELS OVERLAY CENTERED FRAME f_query.
     
     
/* Retorna Nome do beneficiario */
ON RETURN OF b_nome 
   DO:
       ASSIGN  tel_nmrecben = tt-benefic.nmrecben
               tel_nrbenefi = tt-benefic.nrbenefi
               tel_nrrecben = tt-benefic.nrrecben.
              
       DISPLAY tel_nmrecben
               tel_nrbenefi 
               tel_nrrecben WITH FRAME f_solins.
                
       APPLY "GO".
                
   END.

ASSIGN glb_cddopcao = "I".


DO WHILE TRUE:

   RUN fontes/inicia.p.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      ASSIGN   tel_cdagenci = 0
               tel_nmrecben = ""
               tel_nrbenefi = 0 
               tel_nrrecben = 0
               tel_cdmotsol = 0
               tel_tpsolici = 0.
      
      DISPLAY  tel_cdagenci
               tel_nmrecben
               tel_nrbenefi  
               tel_nrrecben     
               tel_cdmotsol
               tel_tpsolici WITH FRAME f_solins.
    
      IF   aux_cddopcao <> glb_cddopcao   THEN
           DO:
               { includes/acesso.i }
               
               aux_cddopcao = glb_cddopcao.
           END.

      LEAVE.
   
   END.    /*  Fim do DO WHILE TRUE */
   

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       UPDATE tel_cdagenci
              tel_nmrecben WITH FRAME f_solins.

       LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN         /*  F4 ou Fim  */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "SOLINS"   THEN
                 DO:
                     HIDE FRAME f_solins.
                     RETURN.
                 END.
            ELSE
                 NEXT.    
        END.

   RUN sistema/generico/procedures/b1wgen0091.p PERSISTENT SET h-b1wgen0091.
   
   RUN busca-benefic IN h-b1wgen0091(INPUT glb_cdcooper,
                                     INPUT 0,
                                     INPUT 0, 
                                     INPUT tel_nmrecben,
                                     INPUT tel_cdagenci,
                                     INPUT 9999,
                                     INPUT 1,
                                     OUTPUT aux_qtregist,
                                     OUTPUT TABLE tt-erro,                            
                                     OUTPUT TABLE tt-benefic).                         
 
   DELETE PROCEDURE h-b1wgen0091.

   IF RETURN-VALUE <> "OK" THEN
      DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF AVAIL(tt-erro) THEN
            MESSAGE tt-erro.dscritic.
        ELSE
            MESSAGE "Nao foi possivel buscar beneficiario".
        NEXT.
      END.

   OPEN QUERY q_nome FOR EACH tt-benefic NO-LOCK.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE b_nome WITH FRAME f_query.
      LEAVE.
   END.
                       
   HIDE FRAME f_query.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        NEXT.
 
   UPDATE tel_tpsolici WITH FRAME f_solins.
      
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      IF   tel_tpsolici = 1   THEN
           DO:
               aux_tpsolici = "Segunda via de cartao".
               
               tel_cdmotsol:HELP = "Motivo da solicitacao(1- Perda/Extravio," + 
                                                        " 2- Roubo)".
               UPDATE tel_cdmotsol WITH FRAME f_solins.
               
               DO WHILE tel_cdmotsol <> 1   AND 
                        tel_cdmotsol <> 2:   
                  
                  MESSAGE "Motivo da solicitacao incorreto.".
                  UPDATE tel_cdmotsol WITH FRAME f_solins.
               END.  
           
           END.
      
      ELSE
           DO:
               aux_tpsolici = "Segunda via de senha".
               
               tel_cdmotsol:HELP = "Motivo (1-Perda/Extravio," +
                                          " 2- Roubo," +
                                          " 3- Esquecimento da senha.)". 
               
               UPDATE tel_cdmotsol WITH FRAME f_solins.
               
               DO WHILE tel_cdmotsol <> 1   AND 
                        tel_cdmotsol <> 2   AND
                        tel_cdmotsol <> 3: 
                  
                  MESSAGE "Motivo da solicitacao incorreto". 
                  UPDATE tel_cdmotsol WITH FRAME f_solins.
               END.
           
           END.
     
      RUN fontes/confirma.p(INPUT "",
                            OUTPUT aux_confirma).
                                         
      IF   aux_confirma = "S"   THEN  
           DO: 
                
               ASSIGN aux_nmendter = STRING(TIME).

               RUN sistema/generico/procedures/b1wgen0113.p PERSISTENT SET
                                                            h-b1wgen0113.

               RUN cadastra_solicitacao IN h-b1wgen0113(INPUT glb_cdcooper,
                                                        INPUT tel_cdagenci,
                                                        INPUT glb_dtmvtolt,
                                                        INPUT glb_cdoperad,
                                                        INPUT 1, /* Ayllos */
                                                        INPUT tel_nrrecben,
                                                        INPUT tel_nrbenefi,
                                                        INPUT tel_nmrecben,
                                                        INPUT tel_tpsolici,
                                                        INPUT tel_cdmotsol,
                                                        INPUT aux_nmendter,
                                                        OUTPUT aux_nmarqimp,
                                                        OUTPUT aux_nmarqpdf,
                                                        OUTPUT aux_dscritic).

               DELETE PROCEDURE h-b1wgen0113.
               
               IF RETURN-VALUE <> "OK" THEN
                  DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                    IF AVAIL(tt-erro) THEN
                        MESSAGE tt-erro.dscritic.
                    ELSE
                        MESSAGE "Nao foi possivel cadastrar a solicitacao".
                    NEXT.
                  END.


               ASSIGN glb_nmformul = "80col"
                      glb_nrdevias = 1.
                    
               FIND FIRST crapass WHERE
                          crapass.cdcooper = glb_cdcooper
                                             NO-LOCK NO-ERROR.
               
               { includes/impressao.i }
               
               
               LEAVE.      
      
           END.  /*  Fim do Confirma  */

   END.  /*  Fim do DO WHILE TRUE  */
      
END.  /* Fim do DO WHILE TRUE */ 
/* .......................................................................... */
