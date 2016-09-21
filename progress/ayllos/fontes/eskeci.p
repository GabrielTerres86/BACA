/* .............................................................................

   Programa: Fontes/eskeci.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Maior/99                            Ultima atualizacao: 28/10/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela ESKECI -- Manutencao de senha do cartao 
                                        magnetico.

               08/09/2004 - Tratar conta integracao (Margarete).
               
               07/07/2005 - Tratar alteracao de senha para cartoes de 
                            operadores do cash (Edson).
               
               26/01/2006 - Unificacao dos bancos - SQLWorks - Fernando
               
               18/12/2009 - Eliminado campo crapass.cddsenha (Diego).
               
               12/01/2011 - Alterada a colunas dos campos para acomodar o campo
                            nmprimtl (Kbase- Gilnei) 
                            
               12/05/2011 - Alterado para utilizar a BO 98 (Henrique).
               
               19/01/2012 - Alterado nrsencar para dssencar (Guilherme).
               
               06/11/2013 - Adicionado param. glb_cdoperad em chamada da proc.
                            busca-cartao (Jorge).
                            
               24/07/2015 - Alterado para nao apresentar limite e forma de saque
                            (James).         
                            
               28/10/2015 - Ajutes permissao de acesso conforme PERMIS (David).
                                 
............................................................................. */

{ includes/var_online.i }
{ includes/var_altera.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0098tt.i }

DEF        VAR tel_nrcartao AS DECIMAL FORMAT "9999,9999,9999,9999"  NO-UNDO.
DEF        VAR tel_nrsennov AS CHAR    FORMAT "x(6)"                 NO-UNDO.
DEF        VAR tel_nrsencon AS CHAR    FORMAT "x(6)"                 NO-UNDO. 

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.

DEF VAR h-b1wgen0098 AS HANDLE                                       NO-UNDO.

FORM SKIP(1)
     tel_nrcartao        COLON 25 LABEL "Numero do Cartao" 
                         HELP "Informe o numero do cartao magnetico."
     SKIP(1)
     tt-crapcrm.nrdconta COLON 25 LABEL "Conta/dv" FORMAT "zzzz,zzz,9"
     SKIP
     tt-crapcrm.nrdctitg COLON 25 LABEL "Conta/ITG" FORMAT "9.999.999-X"   
     tt-crapcrm.dssititg NO-LABEL
     SKIP(1)
     tt-crapcrm.nmprimtl COLON 25 LABEL "Titular da Conta"   FORMAT "x(50)"
     tt-crapcrm.nmtitcrd COLON 25 LABEL "Titular do Cartao"  FORMAT "x(50)"     
     SKIP(2)
     tt-crapcrm.dtemscar COLON 25 LABEL "Emitido em"
     tt-crapcrm.dtvalcar COLON 25 LABEL "Valido ate"
     SKIP(1)
     tel_nrsennov     COLON 25 LABEL "Nova Senha"            BLANK
     tel_nrsencon     COLON 25 LABEL "Confirme a Nova Senha" BLANK
     SKIP
     WITH ROW 4 COLUMN 1 OVERLAY WIDTH 80 SIDE-LABELS NO-LABELS
          TITLE glb_tldatela FRAME f_eskeci.

ASSIGN  glb_cddopcao = "A"
        tel_nrcartao = 0
        glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
       UPDATE tel_nrcartao WITH FRAME f_eskeci.

       IF  aux_cddopcao <> glb_cddopcao  THEN
           DO:
               { includes/acesso.i }
               aux_cddopcao = glb_cddopcao.
           END.
       
       RUN sistema/generico/procedures/b1wgen0098.p PERSISTENT SET h-b1wgen0098.
       
       RUN busca-cartao IN h-b1wgen0098 (INPUT glb_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT tel_nrcartao,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-crapcrm).
       
       DELETE PROCEDURE h-b1wgen0098.
       
       IF  RETURN-VALUE = "NOK"  THEN
           DO:
               CLEAR FRAME f_eskeci.

               FIND FIRST tt-erro NO-LOCK NO-ERROR.

               IF  AVAILABLE tt-erro  THEN
                   MESSAGE tt-erro.dscritic.
               
               NEXT.
           END.
       
       FIND FIRST tt-crapcrm NO-LOCK NO-ERROR.
        
       IF  NOT AVAILABLE tt-crapcrm  THEN
           DO:
               MESSAGE "Registro de cartao nao encontrado.".
               NEXT.
           END.

       DISP tt-crapcrm.nrdconta
            tt-crapcrm.nrdctitg
            tt-crapcrm.dssititg
            tt-crapcrm.nmprimtl
            tt-crapcrm.nmtitcrd            
            tt-crapcrm.dtemscar
            tt-crapcrm.dtvalcar
            WITH FRAME f_eskeci.
       
       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
           UPDATE tel_nrsennov tel_nrsencon WITH FRAME f_eskeci.
      
           RUN sistema/generico/procedures/b1wgen0098.p 
               PERSISTENT SET h-b1wgen0098.
      
           RUN verifica-nova-senha IN h-b1wgen0098 (INPUT glb_cdcooper,
                                                    INPUT 0,
                                                    INPUT 0,
                                                    INPUT glb_cdoperad,
                                                    INPUT glb_nmdatela,
                                                    INPUT 1,
                                                    INPUT tt-crapcrm.nrdconta,
                                                    INPUT 1,
                                                    INPUT TRUE,
                                                    INPUT tel_nrcartao,
                                                    INPUT tel_nrsennov,
                                                    INPUT tel_nrsencon,
                                                   OUTPUT TABLE tt-erro).      
           
           DELETE PROCEDURE h-b1wgen0098.
      
           IF  RETURN-VALUE = "NOK" THEN
               DO:
                   FIND FIRST tt-erro NO-LOCK NO-ERROR.

                   IF  AVAILABLE tt-erro  THEN
                       MESSAGE tt-erro.dscritic.
                   
                   NEXT.
               END.
           
           RUN fontes/confirma.p (INPUT  "",
                                 OUTPUT aux_confirma).
           
           IF  aux_confirma = "N"  THEN
               LEAVE.
           
           RUN sistema/generico/procedures/b1wgen0098.p 
               PERSISTENT SET h-b1wgen0098.
           
           RUN grava-nova-senha IN h-b1wgen0098 
                               (INPUT glb_cdcooper,
                                INPUT 0,
                                INPUT 0,
                                INPUT glb_cdoperad,
                                INPUT glb_nmdatela,
                                INPUT 1,
                                INPUT tt-crapcrm.nrdconta,
                                INPUT 1,
                                INPUT TRUE,
                                INPUT glb_dtmvtolt,
                                INPUT tel_nrcartao,
                                INPUT tel_nrsennov,
                               OUTPUT TABLE tt-erro).
           
           DELETE PROCEDURE h-b1wgen0098.
           
           IF RETURN-VALUE = "NOK" THEN
              DO:
                 FIND FIRST tt-erro NO-LOCK NO-ERROR.

                 IF  AVAILABLE tt-erro  THEN
                     MESSAGE tt-erro.dscritic.

                 NEXT.
              END.

           ASSIGN tel_nrcartao = 0.

           CLEAR FRAME f_eskeci.
           
           LEAVE.
               
       END. /* FIM DO WHILE TRUE - senha */
           
   END. /* FIM DO WHILE TRUE - nrcartao */
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "ESKECI"   THEN
                 DO:
                     HIDE FRAME f_eskeci.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

END. /* Fim do DO WHILE TRUE */

/*...........................................................................*/

