/* ..........................................................................

   Programa: fontes/dirfg.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio/Evandro
   Data    : Janeiro/2005                       Ultima atualizacao: 04/12/2013
      

   Dados referentes ao programa:

   Frequencia: Ayllos.
   Objetivo  : Atende a solicitacao 50 ordem _. 
               Tela para geracao de arquivo para DIRF.

   Alteracoes: 01/07/2005 - Alimentado campo cdcooper da tabela crapdrf (Diego).

               27/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               12/09/2006 - Alterado o help dos campos da tela (Elton).            
               
               21/12/2011 - Corrigido warnings (Tiago).
               
               04/12/2013 - Inclusao de VALIDATE crapdrf (Carlos)
............................................................................ */

{ includes/var_online.i }
{ includes/var_conta.i  "NEW" }

DEF   VAR   tel_nranocal   LIKE crapdrf.nranocal                    NO-UNDO.
DEF   VAR   tel_tpdeclar   LIKE crapdrf.tpdeclar                    NO-UNDO.
DEF   VAR   tel_nrcpfres   LIKE crapdrf.nrcpfres                    NO-UNDO.
DEF   VAR   tel_nrcpfent   LIKE crapdrf.nrcpfent                    NO-UNDO.
DEF   VAR   tel_nmresent   LIKE crapdrf.nmresent                    NO-UNDO.
DEF   VAR   tel_nrultdec   LIKE crapdrf.nrultdec                    NO-UNDO.
DEF   VAR   tel_nrdddcop   LIKE crapdrf.nrdddcop                    NO-UNDO.
DEF   VAR   tel_nrfoncop   LIKE crapdrf.nrfoncop                    NO-UNDO.

DEF   VAR   aux_nmarquiv   AS CHAR                                  NO-UNDO.
DEF   VAR   aux_nmprgana   AS CHAR                                  NO-UNDO.
DEF   VAR   aux_nmprgenv   AS CHAR                                  NO-UNDO.

FORM tel_nranocal  AT 16 VALIDATE(INPUT tel_nranocal > 1900 AND 
                                   NOT CAN-FIND(crapdrf WHERE
                                   crapdrf.cdcooper = glb_cdcooper       AND
                                   crapdrf.nranocal = INPUT tel_nranocal AND
                                   crapdrf.tpregist = 1                  AND
                                   TRIM(crapdrf.dsobserv) <> ""),
                  "A DIRF para o ano calendario informado ja esta finalizada!")
                   HELP "Informe o ano de referencia para geracao do arquivo."
     SKIP(1)
     tel_tpdeclar  AT 12 FORMAT "!(1)" 
                         VALIDATE(tel_tpdeclar = "O" OR tel_tpdeclar = "R",
                                  "Opcao Invalida")
                         HELP '"O" - Original / "R" - Retificadora'
     SKIP(1)                    
     tel_nrcpfres  AT  9 FORMAT "999,999,999,99" LABEL "CPF Responsavel Legal"
                         VALIDATE(tel_nrcpfres > 0, 
                                  "380 - Numero errado")     
     SKIP(1)
     tel_nrcpfent  AT 18 FORMAT "999,999,999,99" LABEL "CPF Contador"
                         VALIDATE(tel_nrcpfent > 0,
                                  "380 - Numero errado")
     SKIP(1)
     tel_nmresent  AT 17 FORMAT "x(43)"          LABEL "Nome Contador"
                         VALIDATE(INPUT tel_nmresent <> "",
                                  "Nome Contador deve ser informado")
     SKIP(1)
     tel_nrultdec  AT  3  HELP "Se for declaracao retificadora, informe o numero da ultima." 
     SKIP(1)      
     tel_nrdddcop  AT 15  LABEL "DDD Cooperativa"
                          VALIDATE(tel_nrdddcop > 0, 
                                   "Codigo DDD deve ser informado")
             HELP "Informe o codigo DDD referente ao telefone da Cooperativa."
     SKIP(1)     
     tel_nrfoncop  AT 14  LABEL "Fone Cooperativa" FORMAT "zzzz,zzz9" 
                          VALIDATE(tel_nrfoncop > 0, 
                                   "045 - Telefone deve ser informado")
                          HELP "Informe o numero do telefone da Cooperativa."
     WITH WIDTH 78 OVERLAY ROW 5 CENTERED SIDE-LABELS 
          TITLE "GERACAO DO ARQUIVO" FRAME fr_gera_arq.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     RETURN.

ASSIGN glb_cddopcao = "G"
       tel_nrcpfres = crapcop.nrcpftit
       tel_nrcpfent = crapcop.nrcpfctr
       tel_nmresent = crapcop.nmctrcop.

{ includes/acesso.i }

HIDE MESSAGE NO-PAUSE.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   UPDATE tel_nranocal 
          tel_tpdeclar 
          tel_nrcpfres 
          tel_nrcpfent
          tel_nmresent
          tel_nrultdec        
          tel_nrdddcop 
          tel_nrfoncop WITH FRAME fr_gera_arq.
    
   DO WHILE TRUE:

      IF   (INPUT tel_nrultdec = 0 AND INPUT tel_tpdeclar = "R")   THEN
           DO:
               MESSAGE "Numero deve ser informado para delcaracao retificadora".
               PROMPT-FOR tel_nrultdec WITH FRAME fr_gera_arq.
               NEXT.
           END. 
      ELSE
      IF   (INPUT tel_nrultdec > 0 AND INPUT tel_tpdeclar = "O")   THEN
           DO:
               MESSAGE 
                  "Quando declaracao for tipo 'O', este numero deve ser zero".
               PROMPT-FOR tel_nrultdec WITH FRAME fr_gera_arq.
               NEXT.
           END.        
   
      /* verifica se os CPF's estao corretos */
      /* CPF do responsavel */
      glb_nrcalcul = INPUT tel_nrcpfres.
      RUN fontes/cpfcgc.p.
   
      IF   glb_stsnrcal = NO   THEN
           DO:
               glb_cdcritic = 027.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               PROMPT-FOR tel_nrcpfres WITH FRAME fr_gera_arq.
               NEXT.
           END.
   
      /* CPF do contador */
      glb_nrcalcul = INPUT tel_nrcpfent.
      RUN fontes/cpfcgc.p.
   
      IF   glb_stsnrcal = NO   THEN
           DO:
               glb_cdcritic = 027.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               PROMPT-FOR tel_nrcpfent WITH FRAME fr_gera_arq.
               NEXT.
           END.
      
      LEAVE.
   END.          

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      aux_confirma = "N".
      glb_cdcritic = 78.
      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.
   END.
     
   IF   aux_confirma <> "S"   THEN
        NEXT.

   DO TRANSACTION: 

      FIND crapdrf WHERE crapdrf.cdcooper = glb_cdcooper    AND
                         crapdrf.nranocal = tel_nranocal    AND
                         crapdrf.tpregist = 1            
                         EXCLUSIVE-LOCK NO-ERROR.

      IF   NOT AVAILABLE crapdrf   THEN
           CREATE crapdrf.
         
      ASSIGN crapdrf.dtmvtolt = glb_dtmvtolt
             crapdrf.inpessoa = 2
             crapdrf.nmdeclar = crapcop.nmextcop
             crapdrf.nmresent = CAPS(tel_nmresent)
             crapdrf.nranocal = tel_nranocal
             crapdrf.nrcpfcgc = crapcop.nrdocnpj
             crapdrf.nrcpfres = tel_nrcpfres
             crapdrf.nrcpfent = tel_nrcpfent
             crapdrf.nrdddcop = tel_nrdddcop
             crapdrf.nrfoncop = tel_nrfoncop
             crapdrf.nrultdec = tel_nrultdec
             crapdrf.tpdeclar = tel_tpdeclar
             crapdrf.tpregist = 1
             crapdrf.dsobserv = "GERACAO OK"
             crapdrf.cdcooper = glb_cdcooper.

      VALIDATE crapdrf.

   END.
   
   ASSIGN aux_nmarquiv = "Dirf" + STRING(tel_nranocal) + "_" + 
                         tel_tpdeclar + ".txt"
          aux_nmprgana = "Dirf" + STRING(tel_nranocal + 1) +
                         "Analisador.exe"
          aux_nmprgenv = "receitanet" + STRING(tel_nranocal + 1) +
                         "_01A.exe".
                         
   RUN fontes/gera_arq_dirf.p 
      ("arq/" + aux_nmarquiv, tel_nranocal, tel_tpdeclar).

   MESSAGE "O arquivo '" aux_nmarquiv "', foi  gravado  no diretorio\n"
           "'dirf/enviar' do servidor. Atente agora para os proximos\n" 
           "passos:                                                 \n\n"
           "1) Fazer a conferencia das informacoes utilizando-se dos\n" 
           "   relatorios   que  estao   a  disposicao  na  tela  de\n" 
           "   visualizacao da DIRF;                                \n"
           "2) Validar  o  arquivo   gerado  utilizando  o  programa\n" 
           "   analisador da DIRF '" aux_nmprgana "';       \n" 
           "3) Enviar  o  arquivo para  a Receita Federal atraves do\n" 
           "   programa '" aux_nmprgenv "'.                 " 
           VIEW-AS ALERT-BOX.
                                           
   LEAVE.

END. 

/* ......................................................................... */
