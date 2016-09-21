/* ............................................................................
                    
   Programa: Fontes/admcrd.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Marco/2004                         Ultima atualizacao: 23/09/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela ADMCRD - Cadastro de Administradoras de 
                                       Cartoes de Credito.   
   
   Alteracoes: 07/05/2004 - Alterada a descricao da situacao da administradora
                            de cancelada para desativada (Julio).

               23/06/2005 - Alimentado campo cdcooper da tabela 4~crapadc        
                            (Diego).
               
               10/11/2005 - Alteracao no cadastr de e-mail's (Julio)

               25/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane 

               30/01/2007 - Cadastrar e-mail com ate 35 caracteres (David).
               
               26/08/2010 - Inclucao campo Habilita PJ (Sandro-GATI).
               
               23/09/2011 - Adicionado controle de cobranca de anuidade
                            (Evandro).
............................................................................ */

{ includes/var_online.i }

DEF   VAR   tel_cdadmcrd LIKE crapadc.cdadmcrd                      NO-UNDO.
DEF   VAR   tel_cdagecta LIKE crapadc.cdagecta                      NO-UNDO.
DEF   VAR   tel_cddigage LIKE crapadc.cddigage                      NO-UNDO.
DEF   VAR   tel_cdufende LIKE crapadc.cdufende                      NO-UNDO.
DEF   VAR   tel_dsendere LIKE crapadc.dsendere                      NO-UNDO.
DEF   VAR   tel_nmadmcrd LIKE crapadc.nmadmcrd                      NO-UNDO.
DEF   VAR   tel_nmagecta LIKE crapadc.nmagecta                      NO-UNDO.
DEF   VAR   tel_nmbairro LIKE crapadc.nmbairro                      NO-UNDO.
DEF   VAR   tel_nmbandei LIKE crapadc.nmbandei                      NO-UNDO.
DEF   VAR   tel_nmcidade LIKE crapadc.nmcidade                      NO-UNDO.
DEF   VAR   tel_nmpescto LIKE crapadc.nmpescto                      NO-UNDO.
DEF   VAR   tel_nmresadm LIKE crapadc.nmresadm                      NO-UNDO.
DEF   VAR   tel_nrcepend LIKE crapadc.nrcepend                      NO-UNDO.
DEF   VAR   tel_nrctacor LIKE crapadc.nrctacor                      NO-UNDO.
DEF   VAR   tel_nrdigcta LIKE crapadc.nrdigcta                      NO-UNDO.
DEF   VAR   tel_nrrazcta LIKE crapadc.nrrazcta                      NO-UNDO.
DEF   VAR   tel_qtcarnom LIKE crapadc.qtcarnom                      NO-UNDO.
DEF   VAR   tel_dsemail1 LIKE crapadc.dsdemail                      NO-UNDO.
DEF   VAR   tel_dsemail2 LIKE crapadc.dsdemail                      NO-UNDO.
DEF   VAR   tel_dsemail3 LIKE crapadc.dsdemail                      NO-UNDO.
DEF   VAR   tel_dsemail4 LIKE crapadc.dsdemail                      NO-UNDO.
DEF   VAR   tel_dsemail5 LIKE crapadc.dsdemail                      NO-UNDO.
DEF   VAR   tel_inanuida LIKE crapadc.inanuida                      NO-UNDO.
DEF   VAR   tel_flghabcj AS LOGICAL FORMAT "Sim/Nao" 
                                    INITIAL NO                      NO-UNDO.

DEF   VAR   tel_insitadc AS LOGICAL FORMAT "ATIVADA/DESATIVADA" 
                                    INITIAL TRUE                    NO-UNDO.
                                    
DEF   VAR   aux_cddopcao AS CHAR                                    NO-UNDO.
DEF   VAR   aux_confirma AS CHAR  FORMAT "!(1)"                     NO-UNDO.
DEF   VAR   aux_contador AS INT                                     NO-UNDO.
 
FORM SKIP(1)
     "Opcao:" AT 5
     glb_cddopcao HELP "Informe a opcao desejada: (C, A, I, E)"
     SKIP(1)
     "Codigo Adm.    :" AT 5  tel_cdadmcrd SKIP 
     "Nome Adm.      :" AT 5  tel_nmadmcrd SKIP   
     "Nome Resumido  :" AT 5  tel_nmresadm  
     "Situacao:"        AT 53 tel_insitadc 
                        HELP "Situacao: 'Desativada' ou 'Ativada'" SKIP
     "Bandeira Cartao:" AT 5  tel_nmbandei 
     "Qtd.Caract.Nome:" AT 53 tel_qtcarnom 
            HELP "Informe a quantidade caracteres no nome do titular do cartao" SKIP
     "Habilita PJ    :" AT 5  tel_flghabcj
            HELP "Informe (S)im p/ habilitar ou (N)ao p/ nao habiltar cartao PJ"
     "Anuidade       :" AT 53 tel_inanuida
            HELP "0-Nao cobrar,1-Apenas p/ PF,2-Apenas p/ PJ,3-Cobrar p/ todos"
     SKIP(1)
     "Conta Corrente :" AT 5  tel_nrctacor "DIG:" tel_nrdigcta FORMAT "z9"
     "Razao C/C:"       AT 56 tel_nrrazcta SKIP
     "Agencia        :" AT 5  tel_nmagecta  
     "Cta.Agencia:"     AT 48 tel_cdagecta "DIG:" tel_cddigage FORMAT "zz9" 
     SKIP(1)
     "Endereco       :" AT 5  tel_dsendere FORMAT "x(54)" SKIP
     "Bairro         :" AT 5  tel_nmbairro 
     "Cidade:"          AT 40 tel_nmcidade   
     "UF:"              AT 70 tel_cdufende SKIP
     "CEP            :" AT 5  tel_nrcepend SKIP
     "Pessoa Contato :" AT 5  tel_nmpescto SKIP
     SKIP
     WITH  NO-LABEL TITLE COLOR MESSAGE 
           "Cadastramento de Administradoras de Cartao de Credito"
           ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_cadadm.
           
FORM SKIP(1)
     "e-mail Contato :" AT 5  
     tel_dsemail1 AT 22 FORMAT "x(35)" SKIP
     tel_dsemail2 AT 22 FORMAT "x(35)" SKIP
     tel_dsemail3 AT 22 FORMAT "x(35)" SKIP
     tel_dsemail4 AT 22 FORMAT "x(35)" SKIP
     tel_dsemail5 AT 22 FORMAT "x(35)" SKIP
     SKIP(1)
     WITH  NO-LABEL ROW 12 COLUMN 2 OVERLAY WIDTH 78 FRAME f_email.        

FUNCTION f_consulta RETURN LOGICAL(INPUT par_cdadmcrd AS INTEGER,
                                   INPUT par_flglocar AS LOGICAL ):
       
  DO aux_contador = 1 TO 10:

     IF   par_flglocar   THEN
          FIND crapadc WHERE crapadc.cdcooper = glb_cdcooper    AND 
                             crapadc.cdadmcrd = par_cdadmcrd 
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
     ELSE
          FIND crapadc WHERE crapadc.cdcooper = glb_cdcooper    AND
                             crapadc.cdadmcrd = par_cdadmcrd 
                             NO-LOCK NO-ERROR NO-WAIT.
                               
     IF   NOT AVAILABLE crapadc   THEN
          DO:
              IF   LOCKED crapadc  THEN
                   DO:
                       glb_cdcritic = 341.
                       RUN fontes/critic.p.                         
                       MESSAGE glb_dscritic.
                       PAUSE(1) NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   DO:
                       glb_cdcritic = 605.
                       RUN fontes/critic.p.
                       MESSAGE glb_dscritic.
                       BELL.                       
                       RETURN FALSE.
                   END.
          END.
     ELSE
          DO:
              ASSIGN tel_nmadmcrd = crapadc.nmadmcrd            
                     tel_nmresadm = crapadc.nmresadm 
                     tel_insitadc = (crapadc.insitadc = 0)
                     tel_qtcarnom = crapadc.qtcarnom 
                     tel_nmbandei = crapadc.nmbandei
                     tel_nrctacor = crapadc.nrctacor
                     tel_nrdigcta = crapadc.nrdigcta 
                     tel_nrrazcta = crapadc.nrrazcta 
                     tel_nmagecta = crapadc.nmagecta  
                     tel_cdagecta = crapadc.cdagecta 
                     tel_cddigage = crapadc.cddigage 
                     tel_dsendere = crapadc.dsendere 
                     tel_nmbairro = crapadc.nmbairro 
                     tel_nmcidade = crapadc.nmcidade   
                     tel_cdufende = crapadc.cdufende 
                     tel_nrcepend = crapadc.nrcepend 
                     tel_nmpescto = crapadc.nmpescto 
                     tel_flghabcj = crapadc.flghabcj
                     tel_inanuida = crapadc.inanuida
                     tel_dsemail1 = ENTRY(1, crapadc.dsdemail)
                     tel_dsemail2 = ENTRY(2, crapadc.dsdemail)
                     tel_dsemail3 = ENTRY(3, crapadc.dsdemail)
                     tel_dsemail4 = ENTRY(4, crapadc.dsdemail)
                     tel_dsemail5 = ENTRY(5, crapadc.dsdemail). 
                            
              DISP tel_cdadmcrd   tel_nmadmcrd   tel_nmresadm
                   tel_insitadc   tel_qtcarnom   tel_nmbandei 
                   tel_nrctacor   tel_nrdigcta   tel_nrrazcta 
                   tel_nmagecta   tel_cdagecta   tel_cddigage 
                   tel_dsendere   tel_nmbairro   tel_nmcidade   
                   tel_cdufende   tel_nrcepend   tel_nmpescto
                   tel_flghabcj   tel_inanuida
                   WITH FRAME f_cadadm.
              
              IF   NOT par_flglocar   THEN
                   DO:
                       PAUSE.
                
                       DISP tel_dsemail1   tel_dsemail2   tel_dsemail3 
                            tel_dsemail4   tel_dsemail5   WITH FRAME f_email.
                   END.
                
              RETURN TRUE.
          END.
  END. /* DO TO */
  
  RETURN FALSE.
  
END. /* FUNCTION */

glb_cddopcao = "C".

DO WHILE TRUE TRANSACTION:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_cadadm.
      LEAVE.

   END.

   HIDE MESSAGE.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "ADMCRD"   THEN
                 DO:
                     HIDE FRAME f_cadadm.
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

   IF   glb_cddopcao = "C"   THEN
        DO:
            UPDATE tel_cdadmcrd WITH FRAME f_cadadm.

            f_consulta(INPUT tel_cdadmcrd, FALSE).
        END.    
   ELSE
   IF   glb_cddopcao = "A"   THEN  
        DO:

            UPDATE tel_cdadmcrd WITH FRAME f_cadadm.

            IF   f_consulta(INPUT tel_cdadmcrd, TRUE)   THEN
                 DO:
                     UPDATE tel_nmadmcrd   tel_nmresadm   tel_insitadc   
                            tel_nmbandei   tel_qtcarnom   tel_flghabcj
                            tel_inanuida   tel_nrctacor   tel_nrdigcta
                            tel_nrrazcta   tel_nmagecta   tel_cdagecta
                            tel_cddigage   tel_dsendere   tel_nmbairro
                            tel_nmcidade   tel_cdufende   tel_nrcepend
                            tel_nmpescto 
                            WITH FRAME f_cadadm.

                     UPDATE tel_dsemail1   tel_dsemail2   tel_dsemail3 
                            tel_dsemail4   tel_dsemail5   WITH FRAME f_email.

                     ASSIGN crapadc.nmadmcrd = tel_nmadmcrd           
                            crapadc.nmresadm = tel_nmresadm
                            crapadc.insitadc = IF tel_insitadc THEN 0
                                               ELSE 1
                            crapadc.qtcarnom = tel_qtcarnom 
                            crapadc.nmbandei = tel_nmbandei 
                            crapadc.nrctacor = tel_nrctacor 
                            crapadc.nrdigcta = tel_nrdigcta 
                            crapadc.nrrazcta = tel_nrrazcta 
                            crapadc.nmagecta = tel_nmagecta  
                            crapadc.cdagecta = tel_cdagecta 
                            crapadc.cddigage = tel_cddigage 
                            crapadc.dsendere = tel_dsendere 
                            crapadc.nmbairro = tel_nmbairro 
                            crapadc.nmcidade = tel_nmcidade   
                            crapadc.cdufende = tel_cdufende 
                            crapadc.nrcepend = tel_nrcepend 
                            crapadc.nmpescto = tel_nmpescto 
                            crapadc.flghabcj = tel_flghabcj
                            crapadc.inanuida = tel_inanuida
                            crapadc.dsdemail = tel_dsemail1 + "," +
                                               tel_dsemail2 + "," + 
                                               tel_dsemail3 + "," + 
                                               tel_dsemail4 + "," + 
                                               tel_dsemail5.
                     RELEASE crapadc.

                 END.              
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN  
        DO:
            UPDATE tel_cdadmcrd WITH FRAME f_cadadm.

            IF   f_consulta(INPUT tel_cdadmcrd, TRUE)   THEN
                 DO:
                     aux_confirma = "N".
                     MESSAGE COLOR NORMAL 
                             "Deseja realmente excluir esta administradora ?"
                             UPDATE aux_confirma.
                             
                     IF   aux_confirma = "N"   THEN
                          HIDE MESSAGE.
                     ELSE
                          DO:
                              DELETE crapadc.
                              HIDE MESSAGE.
                          END.
                 END.
        END.              
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            UPDATE tel_cdadmcrd WITH FRAME f_cadadm.
            
            IF   NOT CAN-FIND(crapadc WHERE
                              crapadc.cdcooper = glb_cdcooper   AND
                              crapadc.cdadmcrd = INPUT tel_cdadmcrd)   THEN
                 DO:
                     ASSIGN tel_nmadmcrd = ""         
                            tel_nmresadm = ""
                            tel_insitadc = TRUE
                            tel_qtcarnom = 0
                            tel_nmbandei = ""
                            tel_nrctacor = 0
                            tel_nrdigcta = 0
                            tel_nrrazcta = 0
                            tel_nmagecta = ""
                            tel_cdagecta = 0
                            tel_cddigage = 0
                            tel_dsendere = ""
                            tel_nmbairro = ""
                            tel_nmcidade = "" 
                            tel_cdufende = ""
                            tel_nrcepend = 0
                            tel_nmpescto = ""
                            tel_dsemail1 = "" 
                            tel_dsemail2 = "" 
                            tel_dsemail3 = "" 
                            tel_dsemail4 = "" 
                            tel_dsemail5 = ""
                            tel_flghabcj = NO
                            /* padrao, cobrar de todos */
                            tel_inanuida = 3.
                                             
                     CREATE crapadc.
                     ASSIGN crapadc.cdadmcrd = INPUT tel_cdadmcrd.
                 
                     UPDATE tel_nmadmcrd   tel_nmresadm   tel_insitadc   
                            tel_nmbandei   tel_qtcarnom   tel_flghabcj
                            tel_inanuida   tel_nrctacor   tel_nrdigcta
                            tel_nrrazcta   tel_nmagecta   tel_cdagecta
                            tel_cddigage   tel_dsendere   tel_nmbairro
                            tel_nmcidade   tel_cdufende   tel_nrcepend
                            tel_nmpescto 
                            WITH FRAME f_cadadm.

                     UPDATE tel_dsemail1   tel_dsemail2   tel_dsemail3 
                            tel_dsemail4   tel_dsemail5   WITH FRAME f_email.

                     ASSIGN crapadc.nmadmcrd = tel_nmadmcrd           
                            crapadc.nmresadm = tel_nmresadm
                            crapadc.insitadc = IF tel_insitadc THEN 0
                                               ELSE 1
                            crapadc.qtcarnom = tel_qtcarnom 
                            crapadc.nmbandei = tel_nmbandei 
                            crapadc.nrctacor = tel_nrctacor 
                            crapadc.nrdigcta = tel_nrdigcta 
                            crapadc.nrrazcta = tel_nrrazcta 
                            crapadc.nmagecta = tel_nmagecta  
                            crapadc.cdagecta = tel_cdagecta 
                            crapadc.cddigage = tel_cddigage 
                            crapadc.dsendere = tel_dsendere 
                            crapadc.nmbairro = tel_nmbairro 
                            crapadc.nmcidade = tel_nmcidade   
                            crapadc.cdufende = tel_cdufende 
                            crapadc.nrcepend = tel_nrcepend 
                            crapadc.nmpescto = tel_nmpescto 
                            crapadc.dsdemail = tel_dsemail1 + "," +
                                               tel_dsemail2 + "," + 
                                               tel_dsemail3 + "," + 
                                               tel_dsemail4 + "," + 
                                               tel_dsemail5
                            crapadc.flghabcj = tel_flghabcj
                            crapadc.inanuida = tel_inanuida
                            crapadc.cdcooper = glb_cdcooper.
                            
                     RELEASE crapadc.    
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 790.
                     RUN fontes/critic.p.
                     MESSAGE glb_dscritic.
                     BELL.
                 END.
                     
        END.
END.

/* ......................................................................... */
