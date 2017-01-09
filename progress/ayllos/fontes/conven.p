/* .............................................................................

   Programa: Fontes/conven.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Agosto/2002                     Ultima Atualizacao: 01/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CONVENIOS.

   ALTERACAO : 13/11/2002 - Incluir campos para facilitar repasse (Margarete).
   
               26/01/2005 - Mudado LABEL do campo "tel_cdagercb" de "Age" para
                            "PA" e mudado o HELP de "com a agencia que" para
                            "com o PA que" (Evandro).

               19/09/2005 - Inclusao do campo segmento do conveno (Julio)
               
               24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               09/08/2007 - Incluido campo "Pagamento na Internet" (Diego).
               
               12/08/2008 - Unificacao dos bancos, incluido cdcooper na busca da
                            da tabela craphis(Guilherme).
                            
               03/03/2009 - Permitir somente operador 799 ou 1 nas
                            opcoes A,I,E.   (Fernando).
                            
               11/05/2009 - Alteracao CDOPERAD (Kbase).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase). 
                           
               10/05/2011 - Desenvolvimento da funcao X - Efetuar replicacao 
                            dos dados de um convênio para demais cooperativas 
                            do sistema (Gati - Diego).
               
               11/01/2012 - Permite aos operadores 126, 979 e 997 alterarem
                            a tela CONVEN (Elton).
                            
               23/04/2012 - Incluido o departamento "COMPE" validacao
                            de departamentos (Adriano).       
                                  
              10/01/2013 - Retirado o operador "997" e incluido o "30097" nas
                           opcoes de repasse.(Mirtes)
                           
              11/03/2013 - Incluido campo "Sicredi" e adicionado coluna "Sicredi"
                           no BROWSE 'bconvenios-b'(Daniele).  
              
              22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)                       
                           
              01/12/2016 - Alterado campo dsdepart para cddepart.
                           PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
............................................................................. */

{ includes/var_online.i } 
DEF NEW SHARED VAR shr_inpessoa AS INT   NO-UNDO.                             

DEF        VAR tel_cdempcon AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF        VAR tel_nmrescon AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR tel_nmextcon AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_cdhistor AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF        VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_cdbccrcb AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF        VAR tel_cdagercb AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF        VAR tel_cpfcgrcb AS DEC     FORMAT "zzzzzzzzzzzzzz"       NO-UNDO.
DEF        VAR tel_nrccdrcb AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_cdfinrcb AS INT     FORMAT "zzzz9"                NO-UNDO.
DEF        VAR tel_dssegmto AS CHAR    FORMAT "x(40)"   
      VIEW-AS COMBO-BOX LIST-ITEMS "1 - Prefeituras",
                                   "2 - Saneamento",
                                   "3 - Energia Eletria e Gas",
                                   "4 - Telecomunicacoes",
                                   "5 - Orgaos Governamentais",
                                   "6 - Orgaos identificados atraves do CNPJ",
                                   "7 - Multas de Transito",
                                   "9 - Uso interno do banco"      
                                   PFCOLOR 2                         NO-UNDO.
DEF        VAR tel_flginter AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO. 
DEF        VAR tel_flgcnvsi AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO. 

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdsegmto AS INT                                   NO-UNDO.
DEF        VAR aux_qtsegmto AS INTEGER                               NO-UNDO.

DEF        VAR aux_pesquisa AS LOGICAL FORMAT "S/N"                  NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_contalin AS INT                                   NO-UNDO.
DEF        VAR aux_dspescto AS CHAR                                  NO-UNDO.
DEF        VAR tel_dspescto AS CHAR  VIEW-AS EDITOR SIZE 76 BY 3 
                                BUFFER-LINES 10       PFCOLOR 0      NO-UNDO.
DEF        VAR tel_cnpescto AS CHAR  VIEW-AS EDITOR SIZE 76 BY 3 
                                BUFFER-LINES 10       PFCOLOR 0      NO-UNDO.

DEF        BUTTON btn_btaosair LABEL "Sair".
DEF        BUTTON btn_btcnsair LABEL "Sair".

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM "Opcao:"     AT 6
     glb_cddopcao AUTO-RETURN
                  HELP "Entre com a opcao desejada ( A , C , E , I ou X )"
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                            glb_cddopcao = "E" OR glb_cddopcao = "I" OR
                            glb_cddopcao = "X" , "014 - Opcao errada.")
     SKIP (1)
     tel_cdempcon AT 11 AUTO-RETURN LABEL "Empresa......."
          HELP "Entre com o codigo da empresa conveniada / F7 Consulta."
     tel_dssegmto AT 11 AUTO-RETURN LABEL "Segmento......"
                  HELP "Entre com o segmento/ramo de atividade da empresa."
     tel_nmrescon AT 11 AUTO-RETURN LABEL "Nome Fantasia." 
                  HELP "Entre com o nome fantasia da empresa."
                  VALIDATE (tel_nmrescon <> " ",
                            "357 - O campo deve ser preenchido.")
     tel_cpfcgrcb       AUTO-RETURN LABEL " C.N.P.J"
                  HELP "Entre com o C.N.P.J da empresa"
     tel_nmextcon AT 11 AUTO-RETURN LABEL "Razao Social.."
                  HELP
            "Entre com a razao social da empresa."
                  VALIDATE (tel_nmextcon <> " ",
                            "357 - O campo deve ser preenchido.")
     tel_cdhistor AT 11 AUTO-RETURN LABEL "Historico....."
                  HELP "Entre com o codigo do historico a ser usado"
                  VALIDATE (CAN-FIND(craphis WHERE 
                                     craphis.cdcooper = glb_cdcooper AND
                                     craphis.cdhistor = tel_cdhistor),
                                     "526 - Historico nao encontrado.")
     tel_nrdolote AT 43 AUTO-RETURN LABEL " Nro.Lote......."
                  HELP "Entre com o numero do lote a ser usado"
                  VALIDATE (tel_nrdolote <> 0,
                            "357 - O Campo deve ser preenchido")
     SKIP
     tel_flginter AT 04 LABEL "Pagamento na Internet"  
                  HELP "Informe (S)im ou (N)ao para pagamento na Internet"

    tel_flgcnvsi  AT 44   LABEL "Convenio Sicredi"
                  HELP "Possui ou nao convenio SICREDI"
     SKIP(1)
     "REPASSES===>"   AT 11
     tel_cdbccrcb AUTO-RETURN LABEL "Bco"
                  HELP "Entre com o banco que recebera o repasse"
     tel_cdagercb       AUTO-RETURN LABEL "Age"
                  HELP "Entre com a Agencia que recebera o repasse"
     tel_nrccdrcb       AUTO-RETURN LABEL "Conta"
                  HELP "Entre com a conta corrente para o repasse"
     tel_cdfinrcb       AUTO-RETURN LABEL "Finalidade"
                  HELP "Entre com a finalidade do repasse"    
                      
     WITH NO-LABELS 
     ROW 5 OVERLAY COLUMN 2 FRAME f_emp_convenio NO-BOX SIDE-LABELS PFCOLOR 1.

DEF  FRAME f_contatos
     tel_dspescto  HELP "Use <TAB> para sair"          
     SKIP
     btn_btaosair  HELP
                   "Tecle <Enter> para confirmar o cadastro dos contatos" AT 37
     WITH ROW 15 CENTERED NO-LABELS OVERLAY TITLE " Contatos ".

DEF  FRAME f_consulta_contatos
     tel_cnpescto  HELP "Use <TAB> para sair"          
     SKIP
     btn_btcnsair  HELP
                   "Tecle <Enter> para confirmar o cadastro dos contatos" AT 37
     WITH ROW 15 CENTERED NO-LABELS OVERLAY TITLE " Contatos ".

/* variaveis para mostrar a consulta */          
 
DEF QUERY  bconvenios-q FOR crapcon.
DEF BROWSE bconvenios-b QUERY bconvenios-q
      DISP SPACE(1)
           nmextcon                     COLUMN-LABEL "Nome Convenio"
           SPACE(2)
           cdempcon                     COLUMN-LABEL "Codigo"
           SPACE(1)
           cdsegmto                     COLUMN-LABEL "Segmento"
           SPACE(2)
           flgcnvsi                     COLUMN-LABEL "Sicredi"
           SPACE(1)
           WITH 9 DOWN OVERLAY NO-BOX.   

DEF FRAME f_emp_convenioc
          bconvenios-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7 VIEW-AS DIALOG-BOX.
/**********************************************/
   
ON RETURN OF tel_dssegmto DO:
   APPLY "F1".
END.
       
ON ANY-PRINTABLE OF tel_dssegmto DO:
   /* Posiciona no combo de acordo com a tecla pressionada */
   
   Posiciona:

   DO aux_qtsegmto = 1 TO SELF:NUM-ITEMS:
   
      IF   SELF:ENTRY(aux_qtsegmto) BEGINS LAST-EVENT:FUNCTION   THEN 
           DO:
               SELF:SCREEN-VALUE = SELF:ENTRY(aux_qtsegmto).
               LEAVE Posiciona.  
           END.
   END.

END.

ON END-ERROR OF bconvenios-b DO:
   DISABLE bconvenios-b WITH FRAME f_emp_convenioc.
   CLOSE QUERY bconvenios-q.
   HIDE FRAME f_emp_convenioc.
END.
      
PROCEDURE pConsConven:  
   
   OPEN QUERY bconvenios-q FOR EACH crapcon WHERE 
                                    crapcon.cdcooper = glb_cdcooper NO-LOCK
                                      BY crapcon.flgcnvsi
                                      BY crapcon.cdempcon.
                                    
   ENABLE bconvenios-b WITH FRAME f_emp_convenioc.
   WAIT-FOR RETURN OF bconvenios-b.
   DISABLE bconvenios-b WITH FRAME f_emp_convenioc.

   ASSIGN tel_cdempcon = crapcon.cdempcon
          aux_cdsegmto = crapcon.cdsegmto
          tel_flgcnvsi = crapcon.flgcnvsi.
    
   Posiciona:
  
   DO aux_qtsegmto = 1 TO tel_dssegmto:NUM-ITEMS IN FRAME f_emp_convenio:
   
      IF   tel_dssegmto:ENTRY(aux_qtsegmto) BEGINS STRING(aux_cdsegmto)  THEN 
           DO:
               tel_dssegmto:SCREEN-VALUE = tel_dssegmto:ENTRY(aux_qtsegmto).
               LEAVE Posiciona.  
           END.
   END.
  
   CLOSE QUERY bconvenios-q.
   HIDE FRAME f_emp_convenioc. 

END.

VIEW FRAME f_moldura.
PAUSE 0.
VIEW FRAME f_emp_convenio.
VIEW FRAME f_contatos.

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:

        RUN fontes/inicia.p.
        VIEW FRAME f_contatos.
        
        DISPLAY glb_cddopcao WITH FRAME f_emp_convenio.
        
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           UPDATE glb_cddopcao tel_cdempcon tel_dssegmto
                  WITH FRAME f_emp_convenio
              EDITING:
              
                 READKEY.
                 
                 IF   FRAME-FIELD = "tel_cdempcon"   THEN 
                      IF   LASTKEY = KEYCODE("F7")   THEN
                           DO:
                               RUN pConsConven.
                               DISPLAY tel_cdempcon WITH FRAME f_emp_convenio.
                           END.
                           
                 APPLY LASTKEY.
              END.
                  
              IF   glb_cddopcao <> "C"      THEN
                   IF   glb_cddepart <> 20          AND  /* TI          */
                        glb_cddepart <> 11          AND  /* FINANCEIRO  */
                        glb_cddepart <>  4          AND  /* COMPE       */
                        glb_cdoperad <> "126"       AND 
                        glb_cdoperad <> "979"       AND 
                        glb_cdoperad <> "30097"     THEN
                        DO: 
                           glb_cdcritic = 36.
                           RUN fontes/critic.p.
                           MESSAGE glb_dscritic.
                           PAUSE 2 NO-MESSAGE.
                           glb_cdcritic = 0.
                           NEXT.
                        END.
           LEAVE.
        END.

        ASSIGN aux_cdsegmto = INT(SUBSTR(tel_dssegmto:SCREEN-VALUE,1,1)).

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "CONVEN"   THEN
                      DO:
                          HIDE FRAME f_emp_convenio.
                          HIDE FRAME f_emp_convenioc.
                          HIDE FRAME f_consulta_contatos.
                          HIDE FRAME f_contatos.
                          RETURN.
                      END.
                 ELSE
                      NEXT.
             END.

        IF   aux_cddopcao <> INPUT glb_cddopcao THEN
             DO:
                 { includes/acesso.i }
                 aux_cddopcao = INPUT glb_cddopcao.
             END.

        ASSIGN tel_nmrescon = CAPS(INPUT tel_nmrescon)
               tel_nmextcon = CAPS(INPUT tel_nmextcon)
               tel_cdbccrcb = 0 
               tel_cdagercb = 0
               tel_cpfcgrcb = 0
               tel_nrccdrcb = 0
               tel_cdfinrcb = 0
               glb_cddopcao = INPUT glb_cddopcao.

        IF   INPUT glb_cddopcao = "A" THEN
             DO:
                 { includes/convena.i }
             END.
        ELSE
        IF   INPUT glb_cddopcao = "C" THEN
             DO:
                HIDE FRAME f_contatos.
                VIEW FRAME f_consulta_contatos.
                { includes/convenc.i }
             END.
         ELSE
         IF INPUT glb_cddopcao = "E"   THEN
             DO:
                HIDE FRAME f_contatos.
                VIEW FRAME f_consulta_contatos.
                { includes/convene.i }
             END.

         ELSE
         IF  INPUT glb_cddopcao = "X"   THEN
             DO: 
                { includes/convenx.i }
             END.
         ELSE
         IF  INPUT glb_cddopcao = "I"   THEN
             DO:
                { includes/conveni.i }
             END.
         
END.

/* ....................................................................... */
