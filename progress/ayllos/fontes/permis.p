/* .............................................................................

   Programa: Fontes/permis.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei 
   Data    : Outubro/2008.                       Ultima atualizacao: 26/05/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar controle de acesso das telas aos usuarios.

   Alteracoes:  03/03/2009 - Alterada permissoes pra certos programas do PROGRID
                             (Gabriel).
  
                09/04/2009 - Alterada novamente permissoes pro PROGRID
                             (Gabriel).
         
                17/04/2009 - Criada opcao "N" para liberacao de opcao de tela
                             por nivel de operador.
                           - Alterado relatorio 499 para 512 pois ele jah eh
                             utilizado pelo crps029.p (Gabriel).
                             
                25/05/2009 - Alteracao CDOPERAD (Kbase).

                14/09/2010 - Inclusao de Pesquisa por Tela,Rotina e Permissao.
                             Gera relatorio ao fim da consulta(crrl576)
                             (Guilherme/Supero)
                             
                16/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop 
                             na leitura e gravacao dos arquivos (Elton).

                21/03/2011 - Bloqueio para que nao seja realizada nenhuma 
                             alteracao nas permissoes do operador 888 (Henrique)
                             
                10/07/2012 - Inclusao de log para as opcoes "A","E","P","N"
                             (Lucas R.).
                             
                04/04/2013 - Retirado campo Acesso Intranet e adicionado campo
                             "Ambiente Acesso". (Jorge)
                             
                02/12/2013 - Melhorar performance copia de perfil (David).
                
                17/12/2013 - Inclusao de VALIDATE crapace (Carlos)
                
                27/01/2014 - Alterada opção A para incluir/deletar permissões
                             do AyllosWEB ao serem modificadas para o Caracter (Lucas).
                             
                03/02/2013 - Implementada a opcao I para importação de arquivo
                             .csv de permissões
                           -  Aumento do format no frame 'f_lanctos' (Lucas).
                           
                25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).
							 
                06/12/2016 - Alterado campo dsdepart para cddepart.
                             PRJ341 - BANCENJUD (Odirlei-AMcom)
							
			    22/12/2016 - Ajustar bloqueio dos departamentos para VIACREDI e CECRED, conforme
			                 solicitação feita no chamado 549118 (Renato Darosci - Supero)

				26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).
				
				16/08/2018 - Remover regras que impedia o controle de permissões para algumas 
				             telas do sistema Progrid. (INC0022095 - Wagner - Sustentação).

............................................................................. */

DEF NEW SHARED VAR shr_nmdatela AS CHAR                                NO-UNDO.
DEF NEW SHARED VAR shr_nmrotina AS CHAR                                NO-UNDO.
DEF NEW SHARED VAR shr_cdoperad AS CHAR                                NO-UNDO.

{ includes/var_online.i } 
{ includes/permis1.i NEW }

DEF STREAM str_1.
DEF STREAM str_2.

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF VAR tel_cdoperad    AS CHAR FORMAT "x(10)"                         NO-UNDO.
DEF VAR tel_nmoperad    AS CHAR FORMAT "x(30)"                         NO-UNDO.
DEF VAR tel_cdopedst    AS CHAR FORMAT "x(10)"                         NO-UNDO.
DEF VAR tel_nmopedst    AS CHAR FORMAT "x(30)"                         NO-UNDO.
DEF VAR tel_nmdatela    AS CHAR FORMAT "x(8)"                          NO-UNDO.
DEF VAR tel_tldatela    AS CHAR                                        NO-UNDO.
DEF VAR tel_nmarqint    AS CHAR FORMAT "x(60)"                      NO-UNDO.
DEF VAR tel_dsdireto    AS CHAR FORMAT "x(60)"                      NO-UNDO.
DEF VAR tel_dsdatela    AS CHAR EXTENT 4                               NO-UNDO.
DEF VAR tel_dtaltsnh    AS DATE FORMAT "99/99/9999"                    NO-UNDO.

DEF VAR tel_idambtel    AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX LIST-ITEMS
                                               "1 - CARACTER", 
                                               "2 - WEB", 
                                               "3 - PROGRID"           NO-UNDO.
DEF VAR tel_dtvalsnh    AS DATE FORMAT "99/99/9999"                    NO-UNDO.
DEF VAR tel_idfiltro    AS CHAR FORMAT "X(1)" INIT "T"                 NO-UNDO.
DEF VAR tel_nvoperad    AS CHAR FORMAT "x(15)" VIEW-AS COMBO-BOX LIST-ITEMS
                                               "1 - Operador",
                                               "2 - Supervisor",
                                               "3 - Gerente"           NO-UNDO.
DEF VAR tel_nmrotina    AS CHAR FORMAT "x(15)"                         NO-UNDO.
DEF VAR tel_cdpermis    AS CHAR FORMAT "x(1)"                          NO-UNDO.
DEF VAR tel_flgatual    AS LOGI FORMAT "SIM/NAO" INIT TRUE             NO-UNDO.
DEF VAR tel_flgcoops    AS LOGI                                        NO-UNDO.

DEF VAR aux_nmrotina    AS CHAR                                        NO-UNDO.
DEF VAR aux_flgfirst    AS LOGI                                        NO-UNDO.
DEF VAR aux_flgretor    AS LOGI                                        NO-UNDO.
DEF VAR aux_regexist    AS LOGI                                        NO-UNDO.
DEF VAR aux_confirma    AS CHAR FORMAT "x(1)"                          NO-UNDO.
DEF VAR aux_cddopcao    AS CHAR                                        NO-UNDO.
DEF VAR aux_setlinha    AS CHAR                                        NO-UNDO.
DEF VAR aux_contador    AS INT                                         NO-UNDO.
DEF VAR aux_nrindice    AS INT                                         NO-UNDO.
DEF VAR aux_foraduso    AS CHAR INIT "FORA DE USO"                     NO-UNDO.
DEF VAR aux_nmarqimp    AS CHAR FORMAT "x(40)"                         NO-UNDO.

/* variaveis para impressao */
DEF VAR aux_nmendter    AS CHAR FORMAT "x(20)"                         NO-UNDO.
DEF VAR par_flgrodar    AS LOGI INIT TRUE                              NO-UNDO.
DEF VAR aux_flgescra    AS LOGI                                        NO-UNDO.
DEF VAR aux_dscomand    AS CHAR                                        NO-UNDO.
DEF VAR par_flgfirst    AS LOGI INIT TRUE                              NO-UNDO.
DEF VAR tel_dsimprim    AS CHAR FORMAT "x(8)" INIT "Imprimir"          NO-UNDO.
DEF VAR tel_dscancel    AS CHAR FORMAT "x(8)" INIT "Cancelar"          NO-UNDO.
DEF VAR par_flgcance    AS LOGI                                        NO-UNDO.

DEF VAR aux_query       AS CHAR                                        NO-UNDO.
DEF VAR tel_nmdopcao    AS LOGI FORMAT "ARQUIVO/IMPRESSAO" INIT TRUE   NO-UNDO.

DEF VAR aux_qtalterados AS INT                                         NO-UNDO.
DEF VAR aux_inacesso    AS CHAR FORMAT "x(01)"                         NO-UNDO.
DEF VAR aux_iddopcao    AS INTE                                        NO-UNDO.

DEF   VAR tel_nmdireto AS   CHAR  FORMAT "x(20)"                    NO-UNDO.
DEF   VAR tel_nmarquiv AS   CHAR  FORMAT "x(25)"                    NO-UNDO.
DEF   VAR aux_nmrescop LIKE crapcop.nmrescop                        NO-UNDO.
DEF   VAR aux_dsdircop LIKE crapcop.dsdircop                        NO-UNDO.
DEF   VAR aux_nmarqdst AS CHAR                                      NO-UNDO.

DEFINE TEMP-TABLE tt-acesso                                            NO-UNDO
       FIELD  nmoperad  LIKE crapope.nmoperad
       FIELD  nmdatela  LIKE craptel.nmdatela
       FIELD  nmrotina  LIKE craptel.nmrotina
       FIELD  cdopptel  AS CHAR FORMAT "X(2)"
       FIELD  nmopptel  AS CHAR FORMAT "X(30)"
       FIELD  idaceant  AS LOGI FORMAT "S/N"
       FIELD  idacenov  AS LOGI FORMAT "S/N"
       FIELD  idevento  LIKE craptel.idevento
       FIELD  idambtel  LIKE craptel.idambtel.

DEFINE TEMP-TABLE tt-opcaotela                                         NO-UNDO
       FIELD  cdopptel  LIKE craptel.nmrotina
       FIELD  nmopptel  LIKE craptel.nmrotina.

DEFINE TEMP-TABLE w-operadores                                        NO-UNDO
       FIELD cdoperad LIKE crapope.cdoperad
       FIELD nmoperad LIKE crapope.nmoperad.

DEFINE TEMP-TABLE tt-importa-permissoes                               NO-UNDO
       FIELD cdoperad LIKE crapope.cdoperad
       FIELD nmdatela LIKE crapace.nmdatela
       FIELD idambace LIKE crapace.idambace
       FIELD nmrotina LIKE craptel.nmrotina
       FIELD cddopcao LIKE craptel.cdopptel
       .
       
DEF BUFFER b-tt-acesso FOR tt-acesso.

DEF QUERY q-operadores FOR w-operadores.
   
DEF BROWSE b-operadores QUERY q-operadores
           DISPLAY w-operadores.cdoperad FORMAT "x(10)"
                   w-operadores.nmoperad FORMAT "x(40)"
                   WITH 7 DOWN TITLE " Operadores ".

DEF QUERY q_tt-acesso_a FOR tt-acesso.
DEF QUERY q_tt-acesso_c FOR tt-acesso.
DEF QUERY q_tt-acesso_l FOR tt-acesso.

DEF BROWSE b_tt-acesso_c QUERY q_tt-acesso_c
    DISP tt-acesso.nmdatela COLUMN-LABEL "Tela"         FORMAT "x(08)"
         tt-acesso.nmrotina COLUMN-LABEL "Rotina"       FORMAT "x(30)"
         tt-acesso.nmopptel COLUMN-LABEL "Opcao"        FORMAT "x(30)"
         tt-acesso.idacenov COLUMN-LABEL "Lib"
         WITH 7 DOWN WIDTH 78 SCROLLBAR-VERTICAL.

DEF BROWSE b_tt-acesso_a QUERY q_tt-acesso_a
    DISP tt-acesso.nmdatela COLUMN-LABEL "Tela"         FORMAT "x(08)"
         tt-acesso.nmrotina COLUMN-LABEL "Rotina"       FORMAT "x(30)"
         tt-acesso.nmopptel COLUMN-LABEL "Opcao"        FORMAT "x(30)"
         tt-acesso.idacenov COLUMN-LABEL "Lib"
         ENABLE tt-acesso.idacenov AUTO-RETURN
                HELP "Informe o identificador de liberacao (Sim/Nao)."
         WITH 7 DOWN WIDTH 78 SCROLLBAR-VERTICAL.

DEF BROWSE b_tt-acesso_l QUERY q_tt-acesso_l
    DISP tt-acesso.nmrotina COLUMN-LABEL "Rotina"       FORMAT "x(20)"
         tt-acesso.nmopptel COLUMN-LABEL "Opcao Tela"   FORMAT "x(20)"
         tt-acesso.nmoperad COLUMN-LABEL "Operador"     FORMAT "x(30)"
         WITH 8 DOWN WIDTH 78 SCROLLBAR-VERTICAL.
                                                       
DEF QUERY q_opcoestela   FOR tt-opcaotela.
DEF BROWSE b_opcoestela  QUERY q_opcoestela
       DISPLAY tt-opcaotela.nmopptel FORMAT "x(30)" NO-LABEL
               WITH 6 DOWN WIDTH 30 NO-LABELS OVERLAY.

FORM b-operadores 
     HELP "Pressione <F1> para confirmar ou <DEL> para retirar operador."
     WITH NO-BOX ROW 8 SIDE-LABELS OVERLAY CENTERED FRAME f_ope.

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                   TITLE COLOR MESSAGE tel_tldatela
                   FRAME f_moldura.

FORM glb_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E, L, P, R, X, N, I)"
                        VALIDATE(CAN-DO("A,C,E,L,P,R,X,N,I",glb_cddopcao),
                                 "014 - Opcao errada.")
     
     tel_cdoperad AT 13 LABEL "Operador" AUTO-RETURN
                        HELP "Informe o codigo do operador."
                        VALIDATE(tel_cdoperad <> "",
                               "087 - Codigo do operador deve ser informado.")

     tel_nmoperad AT 35 NO-LABEL 
                        HELP "Informe o nome do operador (nome completo)."
     SKIP
     tel_idfiltro AT 02 LABEL "Filtro"
               HELP "Exibir 'Todas Opcoes'/'Liberadas'/'Nao Liberadas' (T/L/N)"
               VALIDATE(CAN-DO("T,L,N",tel_idfiltro),"014 - Opcao errada.")
     tel_nmdatela AT 17 LABEL "Tela" AUTO-RETURN
                        HELP "Informe o nome da tela - F7 para listar"
     tel_idambtel AT 35 LABEL "Ambiente Acesso" AUTO-RETURN
                        HELP  "Use as <SETAS> p/ selecionar o Ambiente de Acesso."
     SKIP(1)
     tel_dtaltsnh AT  3 LABEL "Ultima alteracao da senha"
     tel_dtvalsnh AT 43 LABEL "Valida ate"
     
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_permis.

FORM glb_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E, L, P, R, X, N, I)"
                        VALIDATE(CAN-DO("A,C,E,L,P,R,X,N,I",glb_cddopcao),
                                 "014 - Opcao errada.")
    
     tel_nmdatela AT 13 LABEL "Tela" AUTO-RETURN
                        HELP "Informe o nome da tela - F7 para listar"
                        VALIDATE(tel_nmdatela <> "",
                               "087 - Nome da Tela deve ser informado.")

     tel_nmrotina AT 29 LABEL "Rotina" AUTO-RETURN
          HELP "Informe o nome da rotina - F7 para listar ou <ENTER> para todos"

     tel_cdpermis AT 55 LABEL "Opcao da Tela"
          HELP "Informe a opcao da tela - F7 para listar ou <ENTER> para todos"
     SKIP
     tel_idambtel AT 02 LABEL "Ambiente Acesso" AUTO-RETURN
                        HELP  "Use as <SETAS> p/ selecionar o Ambiente de Acesso."
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_permis_tela.

FORM glb_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E, L, P, R, X, N, I)"
                        VALIDATE(CAN-DO("A,C,E,L,P,R,X,N,I",glb_cddopcao),
                                 "014 - Opcao errada.")
    
     tel_cdoperad AT 23 LABEL "Oper Orig" AUTO-RETURN
                        HELP "Informe o codigo do operador de origem."
                        VALIDATE(tel_cdoperad <> "",
                               "087 - Codigo do operador deve ser informado.")
     tel_nmoperad AT 45 NO-LABEL
                        HELP "Informe o nome do operador (nome completo)."
     SKIP
     tel_cdopedst AT 23 LABEL "Oper Dest" AUTO-RETURN
                        HELP "Informe o codigo do operador de destino."
                        VALIDATE(tel_cdopedst <> "",
                               "087 - Codigo do operador deve ser informado.")
     tel_nmopedst AT 45 NO-LABEL 
                        HELP "Informe o nome do operador (nome completo)."
     SKIP
     tel_idambtel AT 17 LABEL "Ambiente Acesso" AUTO-RETURN
                        HELP  "Use as <SETAS> p/ selecionar o Ambiente de Acesso."
     SKIP
     tel_flgatual AT 07 LABEL "Manter Permissoes Atuais?" AUTO-RETURN
                        HELP "Informe 'SIM' p/ manter permissoes atuais ou 'NAO' para remover."
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_copia.

FORM glb_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E, L, P, R, X, N, I)"
                        VALIDATE(CAN-DO("A,C,E,L,P,R,X,N,I",glb_cddopcao),
                                 "014 - Opcao errada.")
    
     tel_cdoperad AT 13 LABEL "Operador" AUTO-RETURN
                        HELP "Informe o codigo do operador."
                        VALIDATE(tel_cdoperad <> "",
                               "087 - Codigo do operador deve ser informado.")
     tel_nmoperad AT 35 NO-LABEL 
                        HELP "Informe o nome do operador (nome completo)."
     SKIP
     tel_idambtel AT 06 LABEL "Ambiente Acesso" AUTO-RETURN
                        HELP  "Use as <SETAS> p/ selecionar o Ambiente de Acesso."
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_lib_consulta.

FORM glb_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E, L, P, R, X, N, I)"
                        VALIDATE(CAN-DO("A,C,E,L,P,R,X,N,I",glb_cddopcao),
                                 "014 - Opcao errada.")

     tel_cdoperad AT 13 LABEL "Operador" AUTO-RETURN
                        HELP "Informe o codigo do operador."
                        VALIDATE(tel_cdoperad <> "",
                               "087 - Codigo do operador deve ser informado.")

     tel_nmoperad AT 35 NO-LABEL 
                        HELP "Informe o nome do operador (nome completo)."
     tel_idfiltro AT 50 LABEL "Filtro"
             HELP "Exibir 'Todas Opcoes'/'Liberadas'/'Nao Liberadas' (T/L/N)"
             VALIDATE(CAN-DO("T,L,N",tel_idfiltro),"014 - Opcao errada.")    
     tel_nmdopcao AT 62 LABEL "Saida"
                        HELP "(A)rquivo ou (I)mpressao."
     tel_idambtel AT 06 LABEL "Ambiente Acesso" AUTO-RETURN
                        HELP  "Use as <SETAS> p/ selecionar o Ambiente de Acesso."
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_relatorio.


FORM glb_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E, L, P, R, X, N, I)"
                        VALIDATE(CAN-DO("A,C,E,L,P,R,X,N,I",glb_cddopcao),
                                 "014 - Opcao errada.")
    
     tel_nvoperad AT 13 LABEL "Nivel do operador" AUTO-RETURN
                       HELP  "Use as <SETAS> p/ selecionar o nivel do operador."

     tel_nmdatela AT 55 LABEL "Tela" AUTO-RETURN
                        HELP "Informe o nome da tela - <ENTER> p/ listar."
						
     SKIP
     tel_idambtel AT 15 LABEL "Ambiente Acesso" AUTO-RETURN
                        HELP  "Use as <SETAS> p/ selecionar o Ambiente de Acesso."
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABEL FRAME f_libera_nivel.

FORM b_tt-acesso_c
        HELP "Pressione <F4> ou <END> p/ voltar."
  
     WITH NO-BOX CENTERED OVERLAY ROW 10 FRAME f_tt-acesso_c.

FORM b_tt-acesso_a
     WITH NO-BOX CENTERED OVERLAY ROW 10 FRAME f_tt-acesso_a.

FORM b_tt-acesso_l
        HELP "Pressione <F4> ou <END> p/ voltar."
  
     WITH NO-BOX CENTERED OVERLAY ROW 9 FRAME f_tt-acesso_l.

FORM SKIP(1)
     b_opcoestela HELP "Use ENTER para selecionar ou F4 para sair"
     SKIP
     WITH NO-BOX ROW 7 COLUMN 40 OVERLAY FRAME f_opcoestela.

FORM SKIP
     "RELATORIO DE OPCOES DE TELA - "    AT 18
     tel_nmdatela       AT 48 FORMAT "x(10)"
     SKIP(3)
     WITH NO-LABELS NO-BOX DOWN WIDTH 80 FRAME f_permis_cab.

FORM b-tt-acesso.nmrotina AT 1  LABEL "ROTINA"       FORMAT "x(20)"
     b-tt-acesso.nmopptel AT 23 LABEL "OPCAO TELA"   FORMAT "x(16)"
     b-tt-acesso.nmoperad AT 41 LABEL "OPERADOR"     FORMAT "x(37)"
     WITH NO-LABELS NO-BOX DOWN WIDTH 80 FRAME f_permis_relat.

ON VALUE-CHANGED OF tt-acesso.idacenov IN BROWSE b_tt-acesso_a DO:
     
     FIND FIRST b-tt-acesso NO-LOCK
          WHERE b-tt-acesso.nmdatela = 
                tt-acesso.nmdatela:screen-value IN BROWSE b_tt-acesso_a AND
                b-tt-acesso.nmrotina =
                tt-acesso.nmrotina:screen-value IN BROWSE b_tt-acesso_a AND
                b-tt-acesso.nmopptel = 
                tt-acesso.nmopptel:screen-value IN BROWSE b_tt-acesso_a
                NO-ERROR.
     IF AVAIL b-tt-acesso THEN
        ASSIGN aux_inacesso = IF tt-acesso.idacenov THEN "S" ELSE "N".

     IF tt-acesso.idacenov:screen-value IN BROWSE b_tt-acesso_a
        <> aux_inacesso THEN
        ASSIGN aux_qtalterados = aux_qtalterados + 1.

     IF aux_qtalterados = 100 THEN
        APPLY "END-ERROR".
END.

ON RETURN OF tel_nmrotina DO:

    EMPTY TEMP-TABLE tt-opcaotela.

    FIND FIRST craptel
         WHERE craptel.cdcooper = glb_cdcooper
           AND craptel.nmdatela = tel_nmdatela
           AND craptel.nmrotina = tel_nmrotina NO-LOCK NO-ERROR.
    IF AVAIL craptel THEN DO:

        DO aux_contador = 1 TO NUM-ENTRIES(craptel.cdopptel):

            CREATE tt-opcaotela.
            ASSIGN tt-opcaotela.cdopptel = ENTRY(aux_contador, craptel.cdopptel)
                   tt-opcaotela.nmopptel = ENTRY(aux_contador, craptel.lsopptel).
        END.
    END.

END.

ON RETURN OF b_opcoestela
   DO:
       ASSIGN tel_cdpermis = tt-opcaotela.cdopptel.

       DISPLAY tel_cdpermis WITH FRAME f_permis_tela.
       
       APPLY "GO".
   END.

ON GO , RETURN OF tel_nvoperad IN FRAME f_libera_nivel DO:

    APPLY "GO".

END.

ON GO , RETURN OF tel_idambtel IN FRAME f_libera_nivel DO:

    APPLY "GO".

END.

ON GO , RETURN OF tel_idambtel IN FRAME f_permis DO:
    
    APPLY "GO".

END.

ON GO , RETURN OF tel_idambtel IN FRAME f_permis_tela DO:

    APPLY "GO".

END.

ON GO , RETURN OF tel_idambtel IN FRAME f_lib_consulta DO:

    APPLY "GO".

END.

ON GO , RETURN OF tel_idambtel IN FRAME f_relatorio DO:

    APPLY "GO".

END.

ON GO OF tel_idambtel IN FRAME f_copia DO:

    APPLY "GO".

END.

ON RETURN OF tel_idambtel IN FRAME f_copia DO:

    APPLY "TAB".

END.

FIND craptel WHERE craptel.cdcooper = glb_cdcooper  AND
                   craptel.nmdatela = glb_nmdatela  NO-LOCK NO-ERROR.

ASSIGN glb_cddopcao = "C"
       tel_tldatela = " " + craptel.tldatela + " ".

VIEW FRAME f_moldura.

PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   RUN proc_hide_frame.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      CLEAR FRAME f_permis.
      UPDATE glb_cddopcao WITH FRAME f_permis.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "permis"   THEN
                 DO:
                     RUN proc_hide_frame.
                    
                     HIDE FRAME f_moldura.
                     
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

   glb_cdcritic = 0.
   
   ASSIGN tel_cdoperad = ""
          tel_nmoperad = ""
          tel_cdopedst = ""
          tel_nmopedst = ""
          tel_nmdatela = ""
          tel_dtaltsnh = ?
          tel_dtvalsnh = ?.
       
   IF   CAN-DO("C,A",glb_cddopcao)   THEN
     DO:
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                END.
           
           DISPLAY tel_nmoperad tel_nmdatela tel_dtaltsnh tel_dtvalsnh 
                   WITH FRAME f_permis.

           ASSIGN tel_nmoperad = "".
           UPDATE tel_cdoperad WITH FRAME f_permis.
           
           FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                              crapope.cdoperad = tel_cdoperad NO-LOCK NO-ERROR.

           IF   glb_cddepart <> 20 THEN  /* TI */
                IF AVAIL crapope         AND
                   crapope.cddepart = 20 THEN /* TI */
                     DO:
                         glb_cdcritic = 36.
                         NEXT.
                     END.

           IF   NOT AVAILABLE crapope   THEN
                DO:
                    glb_cdcritic = 67.
                    NEXT.
                END.

           IF  TRIM(tel_cdoperad) = "888" THEN
               DO:
                    ASSIGN glb_cdcritic = 627.
                    NEXT.
               END.
           
           ASSIGN tel_nmoperad = crapope.nmoperad
                  tel_dtaltsnh = crapope.dtaltsnh
                  tel_dtvalsnh = crapope.dtaltsnh + crapope.nrdedias.
        
           DISPLAY tel_nmoperad tel_dtaltsnh tel_dtvalsnh WITH FRAME f_permis.

           IF   crapope.cdsitope <> 1   THEN
                DO:
                    glb_cdcritic = 627.
                    NEXT.
                END.

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
               UPDATE tel_idfiltro WITH FRAME f_permis.
               tel_idfiltro = CAPS(tel_idfiltro).
               DISPLAY tel_idfiltro WITH FRAME f_permis.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                  UPDATE tel_nmdatela WITH FRAME f_permis
                  EDITING:
    
                      READKEY.
                      IF   LASTKEY = KEYCODE("F7")   THEN
                           DO:
                               shr_cdoperad = tel_cdoperad.
                               RUN fontes/zoom_tela.p.
                               
                               IF shr_nmdatela <> "" THEN
                                  DO:
                                      tel_nmdatela = shr_nmdatela.
                                      DISPLAY tel_nmdatela WITH FRAME f_permis.
                                  END.
                           END.
                      APPLY LASTKEY.
                  END.  /*  Fim do EDITING  */
                  
                  ASSIGN tel_idambtel = "".
                  
                  IF tel_nmdatela <> "" THEN
                     DO:
                         FIND FIRST craptel WHERE 
                                           craptel.cdcooper = glb_cdcooper  AND
                                           craptel.nmdatela = tel_nmdatela
                                           NO-LOCK NO-ERROR.
                         IF NOT AVAIL craptel THEN
                            DO:
                                glb_cdcritic = 322.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE COLOR NORMAL glb_dscritic .
                                NEXT.
                            END.
                         
                         IF  craptel.idsistem = 1 THEN
                             DO:
                                IF craptel.idambtel = 0 THEN
                                DO:
                                    ASSIGN tel_idambtel:LIST-ITEMS IN FRAME 
                                           f_permis = "1 - CARACTER,2 - WEB".
                                    ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME 
                                           f_permis = "1 - CARACTER".
                                END.
                                ELSE IF craptel.idambtel = 1 THEN
                                DO:
                                    ASSIGN tel_idambtel:LIST-ITEMS IN FRAME
                                           f_permis = "1 - CARACTER".
                                    ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME 
                                           f_permis = "1 - CARACTER".
                                END.
                                ELSE IF craptel.idambtel = 2 THEN
                                DO:
                                    ASSIGN tel_idambtel:LIST-ITEMS IN FRAME 
                                           f_permis = "2 - WEB".
                                    ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME 
                                           f_permis = "2 - WEB". 
                                END.
                                    
                             END.
                         ELSE
                             DO:
                                ASSIGN tel_idambtel:LIST-ITEMS IN FRAME 
                                       f_permis = "3 - PROGRID".
                                ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME 
                                       f_permis = "3 - PROGRID".
                             END.
                     END.
                  ELSE
                     DO:
                        ASSIGN tel_idambtel:LIST-ITEMS IN FRAME f_permis = 
                               "1 - CARACTER,2 - WEB,3 - PROGRID".
                        ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME f_permis = 
                               "1 - CARACTER".
                     END.
                     
                  tel_nmdatela = CAPS(tel_nmdatela).
                  DISPLAY tel_nmdatela WITH FRAME f_permis.
                  
                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      UPDATE tel_idambtel WITH FRAME f_permis. 
                      ASSIGN tel_idambtel = tel_idambtel:SCREEN-VALUE IN FRAME 
                                            f_permis.
                      LEAVE.
                  END.
                  IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /* F4 OU FIM */
                     NEXT.
                  ELSE
                     LEAVE.
               END.
               IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /* F4 OU FIM */
                  NEXT.
               ELSE
                  LEAVE.
           END.
           IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /* F4 OU FIM */
              NEXT.
           
           RUN busca-acessos.
           
           aux_query = "FOR EACH tt-acesso
                                  BY tt-acesso.nmdatela
                                  BY tt-acesso.nmrotina".
         
           IF glb_cddopcao = "C" THEN 
              DO:
                 QUERY q_tt-acesso_c:QUERY-CLOSE().
                 QUERY q_tt-acesso_c:QUERY-PREPARE(aux_query).

                 MESSAGE "Aguarde...".
                 QUERY q_tt-acesso_c:QUERY-OPEN().
    
                 HIDE MESSAGE NO-PAUSE.
          
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    UPDATE b_tt-acesso_c WITH FRAME f_tt-acesso_c.
                    LEAVE.
         
                 END.  /*  Fim do DO WHILE TRUE  */
                 QUERY q_tt-acesso_c:QUERY-CLOSE().
    
                 HIDE FRAME f_tt-acesso_c.
              END.
           ELSE
           IF glb_cddopcao = "A" THEN 
              DO:
                 QUERY q_tt-acesso_a:QUERY-CLOSE().
                 QUERY q_tt-acesso_a:QUERY-PREPARE(aux_query).

                 MESSAGE "Aguarde...".
                 QUERY q_tt-acesso_a:QUERY-OPEN().
    
                 HIDE MESSAGE NO-PAUSE.
                 
                 ASSIGN aux_qtalterados = 0.
                 
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                     
                    UPDATE b_tt-acesso_a WITH FRAME f_tt-acesso_a.
                    
                    LEAVE.
                 END. /*  Fim do DO WHILE TRUE  */
                 
                 /* pede confirmacao para alteracoes */
                 FIND FIRST tt-acesso NO-LOCK
                      WHERE tt-acesso.idaceant <> tt-acesso.idacenov NO-ERROR.
                 IF AVAIL tt-acesso THEN
                 DO:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       ASSIGN aux_confirma = "N".
                       /* por restricao do browser do progress, deve ser
                          confirmado a alteracao a cada 100 registros */
                       IF aux_qtalterados <> 100 THEN
                       DO:
                           glb_cdcritic = 78.
                           RUN fontes/critic.p.
                       END.
                       ELSE
                           ASSIGN glb_dscritic = "Atualizacao maxima de " 
                    + "100 registros por transacao. Confirma alteracoes?".
                       
                       BELL.
                       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                       LEAVE.
                    END.
                             
                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                         aux_confirma <> "S" THEN
                         DO:
                             glb_cdcritic = 79.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             glb_cdcritic = 0.
                             NEXT.
                         END.
                    
                    RUN atualiza_crapace(INPUT glb_cdcooper,
                                         INPUT glb_cdoperad,
                                         INPUT glb_cddopcao,
                                         INPUT tel_nmdatela,
                                         INPUT tel_cdoperad,
                                         INPUT tel_idambtel).
                   
                 END.

                 QUERY q_tt-acesso_a:QUERY-CLOSE().
    
                 glb_cdcritic = 0.
                 HIDE MESSAGE NO-PAUSE.
                 HIDE FRAME f_tt-acesso_a.
                 
                 IF  KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
                 DO:
                    MESSAGE "Operacao efetuada com sucesso!". 
                    PAUSE 3 NO-MESSAGE.
                 END.
              END.
        END.
     END.
   ELSE
   IF glb_cddopcao = "L" THEN
     DO:
        CLEAR FRAME f_permis_tela.
        DISP glb_cddopcao WITH FRAME f_permis_tela.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                END.

           HIDE FRAME f_permis.
           HIDE FRAME f_lib_consulta.
           HIDE FRAME f_copia.

           DISPLAY tel_nmdatela WITH FRAME f_permis_tela.

           UPDATE tel_nmdatela WITH FRAME f_permis_tela
           EDITING:

              READKEY.
              IF   LASTKEY = KEYCODE("F7")   THEN
                   DO:
                       shr_cdoperad = tel_cdoperad.
                       RUN fontes/zoom_tela.p.
                       
                       IF   shr_nmdatela <> "" THEN
                            DO:
                                tel_nmdatela = shr_nmdatela.
                                DISPLAY tel_nmdatela 
                                        WITH FRAME f_permis_tela.
                            END.
                       ELSE  
                            NEXT.
                   END.
              APPLY LASTKEY.
           END.  /*  Fim do EDITING  */
           
           ASSIGN tel_idambtel = "".

           IF tel_nmdatela <> "" THEN
              DO:
                 FIND FIRST craptel WHERE 
                                   craptel.cdcooper = glb_cdcooper  AND
                                   craptel.nmdatela = tel_nmdatela
                                   NO-LOCK NO-ERROR.
                 IF NOT AVAIL craptel THEN
                    DO:
                        glb_cdcritic = 322.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE COLOR NORMAL glb_dscritic .
                        NEXT.
                    END.
                 
                 IF  craptel.idsistem = 1 THEN
                     DO:
                        IF craptel.idambtel = 0 THEN
                        DO:
                            ASSIGN tel_idambtel:LIST-ITEMS IN FRAME 
                                   f_permis_tela = "1 - CARACTER,2 - WEB".
                            ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME 
                                   f_permis_tela = "1 - CARACTER".
                        END.
                        ELSE IF craptel.idambtel = 1 THEN
                        DO:
                            ASSIGN tel_idambtel:LIST-ITEMS IN FRAME
                                   f_permis_tela = "1 - CARACTER".
                            ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME 
                                   f_permis_tela = "1 - CARACTER".
                        END.
                        ELSE IF craptel.idambtel = 2 THEN
                        DO:
                            ASSIGN tel_idambtel:LIST-ITEMS IN FRAME 
                                   f_permis_tela = "2 - WEB".
                            ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME 
                                   f_permis_tela = "2 - WEB". 
                        END.
                            
                     END.
                 ELSE
                     DO:
                        ASSIGN tel_idambtel:LIST-ITEMS IN FRAME 
                               f_permis_tela = "3 - PROGRID".
                        ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME 
                               f_permis_tela = "3 - PROGRID".
                     END.
              END.
           ELSE
              DO:
                ASSIGN tel_idambtel:LIST-ITEMS IN FRAME f_permis_tela = 
                       "1 - CARACTER,2 - WEB,3 - PROGRID".
                ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME f_permis_tela = 
                       "1 - CARACTER".
              END.
             
           tel_nmdatela = CAPS(tel_nmdatela).
           DISPLAY tel_nmdatela WITH FRAME f_permis_tela.

           DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
              
              UPDATE tel_nmrotina WITH FRAME f_permis_tela
              EDITING:
    
                READKEY.
                IF LASTKEY = KEYCODE("F7")   THEN
                   DO:
                      ASSIGN shr_nmdatela = tel_nmdatela.
                      RUN fontes/zoom_rotina.p.
                          
                      IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                           NEXT.     

                      ASSIGN  tel_nmrotina = shr_nmrotina.
                      DISPLAY tel_nmrotina WITH FRAME f_permis_tela.
                  END.
                  APPLY LASTKEY.
              END.  /*  Fim do EDITING  */.
    
              tel_nmrotina = CAPS(tel_nmrotina).
              DISPLAY tel_nmrotina WITH FRAME f_permis_tela.

              DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  UPDATE tel_cdpermis WITH FRAME f_permis_tela
                  EDITING:
        
                       DO WHILE TRUE:
        
                          READKEY PAUSE 1.
        
                          IF   LASTKEY = KEYCODE("F7")  THEN
                               DO:
                                   HIDE MESSAGE.
                                   OPEN QUERY q_opcoestela
                                     FOR EACH tt-opcaotela NO-LOCK.
        
                                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                      UPDATE b_opcoestela WITH FRAME 
                                      f_opcoestela.
                                      LEAVE.
                                   END.
        
                                   HIDE FRAME f_opcoestela.
                                   NEXT.
                               END.
                          APPLY LASTKEY.
                          LEAVE.
        
                      END. /* fim DO WHILE */
                  END. /* fim do EDITING */

                  tel_cdpermis = CAPS(tel_cdpermis).
                  DISPLAY tel_cdpermis WITH FRAME f_permis_tela.

                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      UPDATE tel_idambtel WITH FRAME f_permis_tela. 
                      ASSIGN tel_idambtel = tel_idambtel:SCREEN-VALUE 
                                            IN FRAME f_permis_tela.
                      LEAVE.
                  END.
                  IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                     NEXT.
                  ELSE
                     LEAVE.

              END.
              IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                  NEXT.
              ELSE
                  LEAVE.

           END.
           IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
              NEXT.
                        
           MESSAGE "Aguarde...".
           RUN busca-acessos-tela.
             
           aux_query = "FOR EACH tt-acesso
                              BY tt-acesso.nmrotina
                              BY tt-acesso.nmopptel
                              BY tt-acesso.nmoperad".
            
           QUERY q_tt-acesso_l:QUERY-CLOSE().
           QUERY q_tt-acesso_l:QUERY-PREPARE(aux_query).
           
           QUERY q_tt-acesso_l:QUERY-OPEN().

           HIDE MESSAGE NO-PAUSE.

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               UPDATE b_tt-acesso_l WITH FRAME f_tt-acesso_l.
               LEAVE.
           END.  /*  Fim do DO WHILE TRUE  */
           QUERY q_tt-acesso_c:QUERY-CLOSE().

           HIDE FRAME f_tt-acesso_c.

           RUN pi_gerar_relatorio.
           
           IF  KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
           DO:
               MESSAGE "Operacao efetuada com sucesso!". 
               PAUSE 3 NO-MESSAGE.
           END.

        END. /** FIM do DO WHILE TRUE.... inicio **/

     END. /** FIM do IF "L" ....**/
   ELSE
   IF glb_cddopcao = "P" THEN
     DO:
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                END.

           DISPLAY tel_nmoperad tel_cdopedst tel_nmopedst tel_flgatual WITH FRAME f_copia.
 
           HIDE FRAME f_permis.
           HIDE FRAME f_permis_tela.
           HIDE FRAME f_lib_consulta.
           HIDE FRAME f_relatorio.
           
           DISP glb_cddopcao WITH FRAME f_copia.
           UPDATE tel_cdoperad WITH FRAME f_copia.

           FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                              crapope.cdoperad = tel_cdoperad NO-LOCK NO-ERROR.

           IF   glb_cddepart <> 20  THEN /* TI */
                IF AVAIL crapope         AND
                   crapope.cddepart = 20 THEN /* TI */
                     DO:
                         glb_cdcritic = 36.
                         NEXT.
                     END.
           
           IF   NOT AVAILABLE crapope   THEN
                DO:
                    glb_cdcritic = 67.
                    NEXT.
                END.

           IF  TRIM(tel_cdoperad) = "888" THEN
               DO:
                    glb_cdcritic = 627.
                    NEXT.
               END.
           
           ASSIGN tel_nmoperad = crapope.nmoperad.
        
           DISPLAY tel_nmoperad WITH FRAME f_copia.

           IF   crapope.cdsitope <> 1   THEN
                DO:
                    glb_cdcritic = 627.
                    NEXT.
                END.
                
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              UPDATE tel_cdopedst WITH FRAME f_copia.

              FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                 crapope.cdoperad = tel_cdopedst 
                                 NO-LOCK NO-ERROR.

              IF glb_cddepart <> 20 THEN /* TI */
                 IF AVAIL crapope AND crapope.cddepart = 20 THEN /* TI */
                    DO:
                       glb_cdcritic = 36.
                       NEXT.
                    END.
           
              IF NOT AVAILABLE crapope   THEN
                 DO:
                    glb_cdcritic = 67.
                    NEXT.
                 END.

              IF TRIM(tel_cdopedst) = "888" THEN
                 DO:
                    glb_cdcritic = 627.
                    NEXT.
                 END.
           
              ASSIGN tel_nmopedst = crapope.nmoperad.
        
              DISPLAY tel_nmopedst WITH FRAME f_copia.

              IF crapope.cdsitope <> 1   THEN
                 DO:
                    glb_cdcritic = 627.
                    NEXT.
                 END.
            
              ASSIGN tel_idambtel = "".
                
              ASSIGN tel_idambtel:LIST-ITEMS IN FRAME f_copia = 
                     "1 - CARACTER,2 - WEB,3 - PROGRID".
              ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME f_copia = 
                     "1 - CARACTER".

              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
                 UPDATE tel_idambtel tel_flgatual WITH FRAME f_copia. 
                 ASSIGN tel_idambtel = tel_idambtel:SCREEN-VALUE IN FRAME 
                                       f_copia
                        tel_flgcoops = FALSE.

                 IF glb_cdcooper = 3 AND CAN-DO("16," + /* SEGURANCA TI */
                                                "18," + /* SUPORTE      */
                                                "20"    /* TI           */
                                          ,STRING(glb_cddepart)) THEN
                    DO:
                       IF tel_cdoperad = tel_cdopedst THEN
                          DO:
                              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                 ASSIGN aux_confirma = "N".
                                 MESSAGE "ATENCAO: Operador de destino igual ao operador de origem da copia.".
                                 MESSAGE "Deseja copiar o perfil de acesso somente nas coops. singulares?"
                                 UPDATE aux_confirma.

                                 ASSIGN tel_flgcoops = TRUE.
                                
                                 LEAVE.
                              END.
                              
                              IF aux_confirma = "N" THEN
                                 DO:
                                     BELL.
                                     MESSAGE "Copia nao realizada!".
                                     glb_cdcritic = 0.
                                     NEXT.
                                 END.
                          END.
                       ELSE
                          DO:
                              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                 ASSIGN aux_confirma = "N".
                                 MESSAGE "Deseja copiar o perfil de acesso em todas as cooperativas?"
                                 UPDATE aux_confirma.

                                 ASSIGN tel_flgcoops = TRUE.
                                
                                 LEAVE.
                              END.                                      
                                
                              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                 ASSIGN aux_confirma = "N".  

                                 MESSAGE "Confirma copia de perfil de acesso?"
                                 UPDATE aux_confirma.

                                 LEAVE.
                              END.              

                              IF KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                                 aux_confirma <> "S" THEN
                                 DO:
                                    BELL.
                                    MESSAGE "Copia nao realizada!".
                                    glb_cdcritic = 0.
                                    NEXT.
                                 END.                                
                          END.
                    END.
                 ELSE   
                    DO:
                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          ASSIGN aux_confirma = "N".

                          MESSAGE "Confirma copia de perfil de acesso?"
                          UPDATE aux_confirma.

                          LEAVE.
                       END.              

                       IF KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                          aux_confirma <> "S" THEN
                          DO:
                             BELL.
                             MESSAGE "Copia nao realizada!".
                             glb_cdcritic = 0.
                             NEXT.
                          END.
                    END.
                                  
                 RUN copiar_perfil.   
                 RUN log-tela-permis (INPUT TODAY,
                                      INPUT glb_cdcooper,
                                      INPUT glb_cdoperad,
                                      INPUT glb_cddopcao,
                                      INPUT tel_nmdatela,
                                      INPUT tel_cdoperad,
                                      INPUT "",
                                      INPUT "",
                                      INPUT YES,
                                      INPUT YES,
                                      INPUT tel_cdopedst,
                                      INPUT "",
                                      INPUT "",
                                      INPUT INTEGER(
                                            SUBSTRING(tel_idambtel,1,1)),
                                      INPUT "").

                 LEAVE.

              END.

              IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                 NEXT.
              ELSE     
                 LEAVE.
           END.
           IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
              NEXT.
 
       END.
     END.
   ELSE
   IF glb_cddopcao = "X" THEN
     DO:
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                END.

           DISPLAY glb_cddopcao tel_nmoperad WITH FRAME f_lib_consulta.
           
           HIDE FRAME f_permis.
           HIDE FRAME f_permis_tela.
           HIDE FRAME f_copia.
           HIDE FRAME f_relatorio.

           UPDATE tel_cdoperad WITH FRAME f_lib_consulta.

           FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                              crapope.cdoperad = tel_cdoperad NO-LOCK NO-ERROR.

           IF   glb_cddepart <> 20 THEN /* TI */
                IF AVAIL crapope         AND
                   crapope.cddepart = 20 THEN /* TI */
                     DO:
                         glb_cdcritic = 36.
                         NEXT.
                     END.
           
           IF   NOT AVAILABLE crapope   THEN
                DO:
                    glb_cdcritic = 67.
                    NEXT.
                END.

           IF  TRIM(tel_cdoperad) = "888" THEN
               DO:
                    glb_cdcritic = 627.
                    NEXT.
               END.
           
           ASSIGN tel_nmoperad = crapope.nmoperad.
        
           DISPLAY tel_nmoperad WITH FRAME f_lib_consulta.


           IF   crapope.cdsitope <> 1   THEN
                DO:
                    glb_cdcritic = 627.
                    NEXT.
                END.
                
           ASSIGN tel_idambtel = "".
                
           ASSIGN tel_idambtel:LIST-ITEMS IN FRAME f_lib_consulta = 
                  "1 - CARACTER,2 - WEB,3 - PROGRID".
           ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME f_lib_consulta = 
                  "1 - CARACTER".

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              UPDATE tel_idambtel WITH FRAME f_lib_consulta. 
              ASSIGN tel_idambtel = tel_idambtel:SCREEN-VALUE IN FRAME f_lib_consulta.

              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 ASSIGN aux_confirma = "N".

                 MESSAGE COLOR NORMAL "Confirma liberacao de telas de consulta?"
                 
                 UPDATE aux_confirma.
                 LEAVE.
              END.
              IF KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S" THEN
                 DO:
                     BELL.
                     MESSAGE "Liberacao nao realizada!".
                     glb_cdcritic = 0.
                     NEXT.
                 END.
              ELSE
                 LEAVE.
           END.
           IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
              NEXT.
           ELSE
              LEAVE.
       END.
       IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
          NEXT.

       RUN  liberar_telas_consulta.        
     
     END.
   ELSE
   IF glb_cddopcao = "E" THEN
     DO:
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                END.

           DISPLAY glb_cddopcao tel_nmoperad WITH FRAME f_lib_consulta.
           
           HIDE FRAME f_permis.
           HIDE FRAME f_permis_tela.
           HIDE FRAME f_copia.
           HIDE FRAME f_relatorio.

           UPDATE tel_cdoperad WITH FRAME f_lib_consulta.

           FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                              crapope.cdoperad = tel_cdoperad NO-LOCK NO-ERROR.

           IF   glb_cddepart <> 20 THEN /* TI */
                IF AVAIL crapope         AND
                   crapope.cddepart = 20 THEN /* TI */
                     DO:
                         glb_cdcritic = 36.
                         NEXT.
                     END.
           
           IF   NOT AVAILABLE crapope   THEN
                DO:
                    glb_cdcritic = 67.
                    NEXT.
                END.

           ASSIGN tel_nmoperad = crapope.nmoperad.
        
           DISPLAY tel_nmoperad WITH FRAME f_lib_consulta.

           IF   crapope.cdsitope <> 1   THEN
                DO:
                    glb_cdcritic = 627.
                    NEXT.
                END.
                
           ASSIGN tel_idambtel = "".

           ASSIGN tel_idambtel:LIST-ITEMS IN FRAME f_lib_consulta = 
                  "1 - CARACTER,2 - WEB,3 - PROGRID".
           ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME f_lib_consulta = 
                  "1 - CARACTER".
           
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              UPDATE tel_idambtel WITH FRAME f_lib_consulta. 
              ASSIGN tel_idambtel = tel_idambtel:SCREEN-VALUE IN FRAME 
                                    f_lib_consulta.
              LEAVE.
           END.
           IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                NEXT.
           
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              ASSIGN aux_confirma = "N".

              MESSAGE COLOR NORMAL "Confirma exclusao dos acessos do operador?"
                      UPDATE aux_confirma.
    
              LEAVE.
           END.
                             
           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                aux_confirma <> "S" THEN
                DO:
                     BELL.
                     MESSAGE "Exclusao nao realizada!".
                     glb_cdcritic = 0.
                     NEXT.
                END.

           RUN exclusao_acesso.

           RUN log-tela-permis (INPUT TODAY,
                                INPUT glb_cdcooper,
                                INPUT glb_cdoperad,
                                INPUT glb_cddopcao,
                                INPUT tel_nmdatela,
                                INPUT tel_cdoperad,
                                INPUT "",
                                INPUT "",
                                INPUT YES,
                                INPUT YES,
                                INPUT "",
                                INPUT "",
                                INPUT "",
                                INPUT INTEGER(SUBSTRING(tel_idambtel,1,1)),
                                INPUT "").
       END.
     END.
   ELSE
   IF glb_cddopcao = "R" THEN
     DO:
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                END.

           DISPLAY glb_cddopcao tel_nmoperad FORMAT "X(14)"  
                   WITH FRAME f_relatorio.
           
           HIDE FRAME f_permis.
           HIDE FRAME f_permis_tela.
           HIDE FRAME f_lib_consulta.
           HIDE FRAME f_copia.    

           UPDATE tel_cdoperad WITH FRAME f_relatorio.

           FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                              crapope.cdoperad = tel_cdoperad NO-LOCK NO-ERROR.

           IF   glb_cddepart <> 20 THEN /* TI */
                IF AVAIL crapope         AND
                   crapope.cddepart = 20 THEN /* TI */
                     DO:
                         glb_cdcritic = 36.
                         NEXT.
                     END.

           IF   NOT AVAILABLE crapope   THEN
                DO:
                    glb_cdcritic = 67.
                    NEXT.
                END.

           ASSIGN tel_nmoperad = crapope.nmoperad.
        
           DISPLAY tel_nmoperad WITH FRAME f_relatorio.

           IF   crapope.cdsitope <> 1   THEN
                DO:
                    glb_cdcritic = 627.
                    NEXT.
                END.

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              
              UPDATE tel_idfiltro WITH FRAME f_relatorio.
              tel_idfiltro = CAPS(tel_idfiltro).
              DISPLAY tel_idfiltro WITH FRAME f_relatorio.

              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 
                 UPDATE tel_nmdopcao WITH FRAME f_relatorio.

                 ASSIGN tel_idambtel:LIST-ITEMS IN FRAME f_relatorio = 
                        "1 - CARACTER,2 - WEB,3 - PROGRID".
                 ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME f_relatorio = 
                        "1 - CARACTER".
    
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    UPDATE tel_idambtel WITH FRAME f_relatorio. 
                    ASSIGN tel_idambtel = tel_idambtel:SCREEN-VALUE IN FRAME 
                                          f_relatorio.
                    LEAVE.
                 END.
                 IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    NEXT.
                 ELSE
                    LEAVE.

              END.
              IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                 NEXT.
              ELSE                   
                 LEAVE.
           END.
           IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
              NEXT.
           ELSE
              LEAVE.
        END.
        IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
           NEXT.

        RUN executa_relatorio.

     END.
   ELSE
   IF  glb_cddopcao = "N"   THEN
       DO:
           HIDE FRAME f_permis.
           CLEAR FRAME f_libera_nivel.
           DISP glb_cddopcao WITH FRAME f_libera_nivel.

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE :
           
              UPDATE tel_nvoperad WITH FRAME f_libera_nivel.
              
              RUN proc_traz_operadores (INPUT SUBSTRING(tel_nvoperad,1,1)).

              IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 DO:
                    HIDE FRAME f_ope.
                    NEXT.
                 END.

              IF NOT TEMP-TABLE w-operadores:HAS-RECORDS  THEN
                 DO:
                    MESSAGE "Nenhum operador foi encontrado.".
                    PAUSE 3 NO-MESSAGE.
                    HIDE FRAME f_ope.
                    NEXT.
                 END.

              aux_confirma = "S".
              
              MESSAGE "Confirmar estes operadores ?" UPDATE aux_confirma.
              IF aux_confirma <> "S"   THEN 
                 DO:
                    glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    MESSAGE glb_dscritic.
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                 END.

              HIDE FRAME f_ope.

              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
                 UPDATE tel_nmdatela WITH FRAME f_libera_nivel
                 EDITING:

                   READKEY.
                   IF LASTKEY = KEYCODE("F7")   THEN
                      DO:
                         shr_cdoperad = tel_cdoperad.
                         RUN fontes/zoom_tela.p.
                           
                         IF shr_nmdatela <> "" THEN
                            DO:
                               tel_nmdatela = shr_nmdatela.
                               DISPLAY tel_nmdatela WITH FRAME f_libera_nivel.
                            END.
                      END.
                      APPLY LASTKEY.
                 END.  /*  Fim do EDITING  */
              
                 ASSIGN tel_idambtel = "".
              
                 IF tel_nmdatela <> "" THEN
                    DO:
                       FIND FIRST craptel WHERE 
                                   craptel.cdcooper = glb_cdcooper  AND
                                   craptel.nmdatela = tel_nmdatela
                                   NO-LOCK NO-ERROR.
                       IF NOT AVAIL craptel THEN
                          DO:
                             glb_cdcritic = 322.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE COLOR NORMAL glb_dscritic .
                             NEXT.
                          END.
                     
                       IF craptel.idsistem = 1 THEN
                          DO:
                             IF craptel.idambtel = 0 THEN
                             DO:
                                ASSIGN tel_idambtel:LIST-ITEMS IN FRAME 
                                       f_libera_nivel = "1 - CARACTER,2 - WEB".
                                ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME 
                                       f_libera_nivel = "1 - CARACTER".
                            END.
                            ELSE IF craptel.idambtel = 1 THEN
                            DO:
                                ASSIGN tel_idambtel:LIST-ITEMS IN FRAME
                                       f_libera_nivel = "1 - CARACTER".
                                ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME 
                                       f_libera_nivel = "1 - CARACTER".
                            END.
                            ELSE IF craptel.idambtel = 2 THEN
                            DO:
                                ASSIGN tel_idambtel:LIST-ITEMS IN FRAME 
                                       f_libera_nivel = "2 - WEB".
                                ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME 
                                       f_libera_nivel = "2 - WEB". 
                            END.
                                
                          END.
                       ELSE
                          DO:
                             ASSIGN tel_idambtel:LIST-ITEMS IN FRAME 
                                    f_libera_nivel = "3 - PROGRID".
                             ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME 
                                    f_libera_nivel = "3 - PROGRID".
                          END.
                    END.
                 ELSE
                    DO:
                       ASSIGN tel_idambtel:LIST-ITEMS IN FRAME f_libera_nivel = 
                              "1 - CARACTER,2 - WEB,3 - PROGRID".
                       ASSIGN tel_idambtel:SCREEN-VALUE IN FRAME f_libera_nivel =
                              "1 - CARACTER".
                    END.
                 
                 tel_nmdatela = CAPS(tel_nmdatela).
                 DISPLAY tel_nmdatela WITH FRAME f_libera_nivel.
            
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_idambtel WITH FRAME f_libera_nivel. 
                    ASSIGN tel_idambtel = tel_idambtel:SCREEN-VALUE IN FRAME 
                                       f_libera_nivel.
                    
                    RUN busca-acessos.

                    aux_query = "FOR EACH tt-acesso BY tt-acesso.nmdatela
                                                    BY tt-acesso.nmrotina".
                    QUERY q_tt-acesso_a:QUERY-CLOSE().
                                   
                    QUERY q_tt-acesso_a:QUERY-PREPARE(aux_query).
        
                    QUERY q_tt-acesso_a:QUERY-OPEN().
                                          
                    DO WHILE TRUE:
                   
                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                         
                          UPDATE b_tt-acesso_a WITH FRAME f_tt-acesso_a.
                          
                          RUN confirma.
        
                          IF aux_confirma <> "S"  THEN
                             NEXT.
            
                          IF NOT CAN-FIND (FIRST tt-acesso WHERE 
                                                 tt-acesso.idacenov NO-LOCK) THEN
                             DO:
                                MESSAGE "Nenhuma opcao de tela foi selecionada.".
                                NEXT.
                             END.
                       
                          /* Permissoes para todo o nivel selecionado */ 
                 
                          MESSAGE "Aguarde...".
            
                          RUN proc_libera_nivel(INPUT glb_cdcooper,
                                                INPUT glb_cdoperad,
                                                INPUT glb_cddopcao,
                                                INPUT tel_nmdatela,
                                                INPUT tel_cdoperad,
                                                INPUT tel_nvoperad). 
            
                          HIDE MESSAGE NO-PAUSE.
                          HIDE FRAME f_tt-acesso_a.
                          MESSAGE "Operacao efetuada com sucesso!". 
                          PAUSE 3 NO-MESSAGE. 
                          LEAVE.
        
                      END. /* Fim do DO WHILE TRUE */
                      IF CAN-DO("END-ERROR",KEYFUNCTION(LASTKEY)) THEN
                         DO:
                            HIDE FRAME f_tt-acesso_a.
                            LEAVE.
                         END.
                      ELSE
                         LEAVE.
                    END.
                 END.
                 IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                     NEXT.
                 ELSE
                     LEAVE.
              END.
              IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                 NEXT.
              ELSE
                 LEAVE.
           END.
           IF CAN-DO("END-ERROR",KEYFUNCTION(LASTKEY)) THEN
              NEXT.

       END.  /** Fim da Opcao "N", Libera nivel  **/
   ELSE
   IF  glb_cddopcao = "I"   THEN
       RUN opcao-importa-permis.

END.  /*  Fim do DO WHILE TRUE  */
 

/*********************************************************************/
PROCEDURE atualiza_crapace:

    DEF  INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF  INPUT PARAM par_cdopeglb AS CHAR                               NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                               NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
    DEF  INPUT PARAM par_idambtel AS CHAR                               NO-UNDO.

    DEF BUFFER crabace FOR crapace.

   DEF VAR aux_idambtel AS INTE                                         NO-UNDO.

   ASSIGN aux_idambtel = INTEGER(SUBSTRING(par_idambtel,1,1)).

   FOR EACH tt-acesso NO-LOCK
       WHERE tt-acesso.idaceant <> tt-acesso.idacenov:

       IF tt-acesso.idacenov = yes THEN
          DO:
              FIND FIRST crapace 
                   WHERE crapace.cdcooper = par_cdcooper AND
                         crapace.nmdatela = tt-acesso.nmdatela AND
                         crapace.nmrotina = tt-acesso.nmrotina AND
                         crapace.cddopcao = tt-acesso.cdopptel AND
                         crapace.cdoperad = par_cdoperad AND
                         crapace.idambace = aux_idambtel NO-LOCK NO-ERROR.

              IF  NOT AVAIL crapace THEN
                  DO:
                     CREATE crapace.
                     ASSIGN crapace.nmdatela = tt-acesso.nmdatela
                            crapace.nmrotina = tt-acesso.nmrotina
                            crapace.cddopcao = tt-acesso.cdopptel
                            crapace.cdoperad = par_cdoperad
                            crapace.cdcooper = par_cdcooper
                            crapace.idevento = tt-acesso.idevento
                            crapace.idambace = aux_idambtel.

                     VALIDATE crapace.

                     IF  aux_idambtel = 1 THEN /* CARACTER */
                         DO:
                             FIND FIRST crabace WHERE crabace.cdcooper = par_cdcooper       AND
                                                      crabace.nmdatela = tt-acesso.nmdatela AND
                                                      crabace.nmrotina = tt-acesso.nmrotina AND 
                                                      crabace.cddopcao = tt-acesso.cdopptel AND
                                                      crabace.cdoperad = par_cdoperad       AND
                                                      crabace.idambace = 2 /* WEB */
                                                      NO-LOCK NO-ERROR.

                             IF  NOT AVAIL crabace THEN
                                 DO:
                                    CREATE crapace.
                                    ASSIGN crapace.nmdatela = tt-acesso.nmdatela
                                           crapace.nmrotina = tt-acesso.nmrotina
                                           crapace.cddopcao = tt-acesso.cdopptel
                                           crapace.cdoperad = par_cdoperad
                                           crapace.cdcooper = par_cdcooper
                                           crapace.idevento = tt-acesso.idevento
                                           crapace.idambace = 2 /* WEB */.
                                 
                                    VALIDATE crapace.
                                 END.
                         END.
                  END.
          END.
       ELSE
          DO:
              FIND FIRST crapace EXCLUSIVE-LOCK
                   WHERE crapace.cdcooper = par_cdcooper AND
                         crapace.nmdatela = tt-acesso.nmdatela AND
                         crapace.nmrotina = tt-acesso.nmrotina AND
                         crapace.cddopcao = tt-acesso.cdopptel AND
                         crapace.cdoperad = par_cdoperad  AND 
                         crapace.idambace = aux_idambtel NO-ERROR.

              IF  AVAIL crapace THEN
                  DO:                       
                       DELETE crapace.

                       IF  aux_idambtel = 1 THEN /* CARACTER */
                           DO:
                               FIND FIRST crabace WHERE crabace.cdcooper = par_cdcooper       AND
                                                        crabace.nmdatela = tt-acesso.nmdatela AND
                                                        crabace.nmrotina = tt-acesso.nmrotina AND 
                                                        crabace.cddopcao = tt-acesso.cdopptel AND
                                                        crabace.cdoperad = par_cdoperad       AND
                                                        crabace.idambace = 2 /* WEB */
                                                        EXCLUSIVE-LOCK NO-ERROR.

                               IF  AVAIL crabace THEN
                                   DELETE crabace.
                           END. 
                  END.
         END.

         RUN log-tela-permis(INPUT TODAY,
                             INPUT par_cdcooper,
                             INPUT par_cdopeglb,
                             INPUT par_cddopcao,
                             INPUT tt-acesso.nmdatela,
                             INPUT par_cdoperad,
                             INPUT tt-acesso.nmrotina,
                             INPUT tt-acesso.cdopptel,
                             INPUT tt-acesso.idaceant,
                             INPUT tt-acesso.idacenov,
                             INPUT "",
                             INPUT "",
                             INPUT "",
                             INPUT tt-acesso.idambtel,
                             INPUT "").

   END.

END PROCEDURE.

/*********************************************************************/
PROCEDURE copiar_perfil:
   
   DEF BUFFER bcrapace FOR crapace.
   DEF BUFFER bcraptel FOR craptel.
   DEF VAR aux_idambtel AS INTE                               NO-UNDO.
   DEF VAR aux_cddopcao AS CHAR                               NO-UNDO.

   HIDE MESSAGE NO-PAUSE.
   
   ASSIGN aux_idambtel = INTEGER(SUBSTRING(tel_idambtel,1,1)).
   
   IF NOT tel_flgatual THEN
      DO: 
         MESSAGE "Aguarde, removendo permissoes atuais ...".
         FOR EACH crapcop WHERE crapcop.flgativo = TRUE AND
                              ((crapcop.cdcooper = glb_cdcooper AND
                                NOT tel_flgcoops) OR
                                tel_flgcoops) NO-LOCK:
                                
           IF crapcop.cdcooper = glb_cdcooper AND tel_cdoperad = tel_cdopedst THEN
              NEXT.

           FOR FIRST crapope WHERE crapope.cdcooper = crapcop.cdcooper AND 
                                   crapope.cdoperad = tel_cdopedst     NO-LOCK: END.
                                   
           IF NOT AVAIL crapope THEN
              NEXT.
           
           FOR EACH craptel WHERE craptel.cdcooper = crapcop.cdcooper NO-LOCK:
           
              DO aux_iddopcao = 1 TO NUM-ENTRIES(craptel.cdopptel,","):
              
                 ASSIGN aux_cddopcao = ENTRY(aux_iddopcao,craptel.cdopptel,",").
                
                 FOR EACH crapace WHERE crapace.cdcooper = craptel.cdcooper AND
                                        crapace.nmdatela = craptel.nmdatela AND
                                        crapace.nmrotina = craptel.nmrotina AND
                                        crapace.cddopcao = aux_cddopcao     AND
                                        crapace.cdoperad = tel_cdopedst     AND
                                        crapace.idambace = aux_idambtel
                                        EXCLUSIVE-LOCK:
                               
                    DELETE crapace.     
                   
                 END.
                 
              END.
              
           END.                       
         END.
      END.
      
   HIDE MESSAGE NO-PAUSE.   
   MESSAGE "Aguarde, copiando perfil ...".
   
   FOR EACH crapcop WHERE crapcop.flgativo = TRUE AND
                        ((crapcop.cdcooper = glb_cdcooper AND
                          NOT tel_flgcoops) OR
                          tel_flgcoops) NO-LOCK:

     FOR FIRST crapope WHERE crapope.cdcooper = crapcop.cdcooper AND 
                             crapope.cdoperad = tel_cdopedst     NO-LOCK: END.
                             
     IF NOT AVAIL crapope THEN
        NEXT.    
     
     FOR EACH craptel WHERE craptel.cdcooper = glb_cdcooper NO-LOCK:

         DO aux_iddopcao = 1 TO NUM-ENTRIES(craptel.cdopptel,","):

             ASSIGN aux_cddopcao = ENTRY(aux_iddopcao,craptel.cdopptel,",").
             
             FOR FIRST bcraptel WHERE bcraptel.cdcooper = crapcop.cdcooper AND 
                                      bcraptel.nmdatela = craptel.nmdatela AND
                                      bcraptel.nmrotina = craptel.nmrotina AND                                               
                                      bcraptel.idambtel = aux_idambtel     NO-LOCK: END.
                                      
             IF NOT AVAIL bcraptel OR NOT CAN-DO(bcraptel.cdopptel,aux_cddopcao) THEN
                NEXT.

             FOR EACH bcrapace  
                WHERE bcrapace.cdcooper = craptel.cdcooper AND
                      bcrapace.nmdatela = craptel.nmdatela AND
                      bcrapace.nmrotina = craptel.nmrotina AND
                      bcrapace.cddopcao = aux_cddopcao     AND
                      bcrapace.cdoperad = tel_cdoperad     AND
                      bcrapace.idambace = aux_idambtel NO-LOCK:
                
                FIND FIRST crapace 
                     WHERE crapace.cdcooper = crapope.cdcooper  AND
                           crapace.nmdatela = bcrapace.nmdatela AND
                           crapace.nmrotina = bcrapace.nmrotina AND 
                           crapace.cddopcao = bcrapace.cddopcao AND
                           crapace.cdoperad = tel_cdopedst      AND
                           crapace.idambace = bcrapace.idambace
                           NO-LOCK NO-ERROR.
                 
                IF NOT AVAIL crapace THEN
                   DO: 
                       CREATE crapace.
                       ASSIGN crapace.cdcooper = crapope.cdcooper
                              crapace.nmdatela = bcrapace.nmdatela
                              crapace.nmrotina = bcrapace.nmrotina
                              crapace.cddopcao = bcrapace.cddopcao
                              crapace.cdoperad = tel_cdopedst
                              crapace.idambace = bcrapace.idambace
                              crapace.idevento = bcrapace.idevento.
                       VALIDATE crapace.
                   END.
             END. 

         END.

     END.
     
   END.
                                 
   HIDE MESSAGE NO-PAUSE.
   MESSAGE "Copia realizada com sucesso!".
   
END PROCEDURE.

/*********************************************************************/
PROCEDURE busca-acessos:
  
  DEF VAR indice AS INTE FORMAT 99                              NO-UNDO.
  DEF VAR aux_idambtel AS INTE                                  NO-UNDO.
  DEF VAR aux_desquery AS CHAR                                  NO-UNDO.
  DEF VAR aux_qcraptel AS CHAR                                  NO-UNDO.
  DEF VAR aux_qcrapace AS CHAR                                  NO-UNDO.

  DEF QUERY q_craptel FOR craptel.

  EMPTY TEMP-TABLE tt-acesso.
  
  ASSIGN aux_idambtel = INTEGER(SUBSTRING(tel_idambtel,1,1)).
  
  IF  aux_idambtel = 3 THEN
      ASSIGN aux_qcraptel = "craptel.idsistem = 2".
  ELSE
      ASSIGN aux_qcraptel = "craptel.idsistem = 1 AND
                             (craptel.idambtel = " + STRING(aux_idambtel) + 
                             " OR craptel.idambtel = 0)".
 
  ASSIGN aux_query = "FOR EACH craptel NO-LOCK 
                         WHERE craptel.cdcooper = " + STRING(glb_cdcooper) +
                         " AND (('" + tel_nmdatela + "' = '') OR
                                ('" + tel_nmdatela + "' <> '' AND
                                craptel.nmdatela = '" + tel_nmdatela + "'))
                           AND " + aux_qcraptel + "       
                            BY craptel.nmdatela 
                            BY craptel.nmrotina:".
 
  QUERY q_craptel:QUERY-CLOSE().
  QUERY q_craptel:QUERY-PREPARE(aux_query).
  QUERY q_craptel:QUERY-OPEN().

  GET FIRST q_craptel.
  
  DO WHILE AVAIL(craptel):
    
     DO indice = 1 TO NUM-ENTRIES(craptel.cdopptel):
         
         IF  NUM-ENTRIES(craptel.cdopptel) <> NUM-ENTRIES(craptel.lsopptel) THEN
             NEXT.
         
         IF   glb_cddopcao = "N"   THEN
              DO:
                  RUN proc_permis(INPUT craptel.nmdatela,
                                  INPUT ENTRY(indice,craptel.cdopptel),
                                  INPUT craptel.idevento).
                 
                  IF  RETURN-VALUE = "NOK"   THEN
                      NEXT.
              END.   
         ELSE
              DO:
                  FIND crapope WHERE crapope.cdcooper = glb_cdcooper  AND
                                     crapope.cdoperad = tel_cdoperad  
                                     NO-LOCK NO-ERROR.
    
                  IF   AVAIL crapope   THEN DO:
                       IF glb_cdcooper <> 1 AND
					      glb_cdcooper <> 3 THEN DO:
					       IF  NOT CAN-DO("18," + /* SUPORTE */
                                          "14," + /* PRODUTOS */
                                          "10," + /* DESENVOLVIMENTO CECRED */
                                          "1"     /* CANAIS */
                                          ,STRING(crapope.cddepart))  THEN
                               DO:
                                   RUN proc_permis 
                                            (INPUT craptel.nmdatela,
                                             INPUT ENTRY(indice,craptel.cdopptel),
                                             INPUT craptel.idevento).
                               
                                   IF  RETURN-VALUE = "NOK"   THEN
                                       NEXT.
                               END.
				       END.
					   ELSE DO:
					       IF  NOT CAN-DO("18," + /* SUPORTE */
                                          "20"    /* TI */
                                          ,STRING(crapope.cddepart))  THEN
                           DO:
                               RUN proc_permis 
                                        (INPUT craptel.nmdatela,
                                         INPUT ENTRY(indice,craptel.cdopptel),
                                         INPUT craptel.idevento).
                               
                               IF  RETURN-VALUE = "NOK"   THEN
                                   NEXT.
                           END.
					   END.
                  END.
                  
                  IF   NOT AVAILABLE crapope   THEN
                       DO:
                           glb_cdcritic = 67.
                           NEXT.
                       END.    
                  
                  FIND FIRST crapace WHERE 
                             crapace.cdcooper = glb_cdcooper     AND
                             crapace.cdoperad = tel_cdoperad     AND
                             crapace.nmdatela = craptel.nmdatela AND
                             crapace.nmrotina = craptel.nmrotina AND
                             crapace.cddopcao = ENTRY(indice,craptel.cdopptel) AND
                             crapace.idambace = aux_idambtel
                             NO-LOCK NO-ERROR.
              END.
         
         /* Exibir somente liberados */
         IF   CAN-DO("C,A",glb_cddopcao)   THEN
              DO:
                  IF ((tel_idfiltro:SCREEN-VALUE IN FRAME f_permis = "L") 
                       AND  
                     (NOT AVAIL crapace))  THEN
                      NEXT.
                  ELSE
                  IF ((tel_idfiltro:SCREEN-VALUE IN FRAME f_permis = "N")
                       AND
                      (AVAIL crapace))  THEN
                      NEXT.
              END.
         ELSE       
         IF   glb_cddopcao = "R"    THEN
              DO:
                  IF ((tel_idfiltro:SCREEN-VALUE IN FRAME f_relatorio = "L") 
                       AND  
                     (NOT AVAIL crapace))  THEN
                      NEXT.
                  ELSE
                  IF ((tel_idfiltro:SCREEN-VALUE IN FRAME f_relatorio = "N")
                       AND
                      (AVAIL crapace))  THEN
                      NEXT.
              END.
         
         CREATE tt-acesso.
         ASSIGN tt-acesso.nmdatela = craptel.nmdatela
                tt-acesso.nmrotina = craptel.nmrotina
                tt-acesso.cdopptel = ENTRY(indice,craptel.cdopptel)
                tt-acesso.nmopptel = ENTRY(indice,craptel.lsopptel)
                tt-acesso.idevento = craptel.idevento
                tt-acesso.idambtel = aux_idambtel.
         
         IF   AVAIL crapace   AND   glb_cddopcao <> "N"   THEN
              ASSIGN tt-acesso.idacenov = TRUE
                     tt-acesso.idaceant = TRUE.
         ELSE           
              ASSIGN tt-acesso.idacenov = FALSE
                     tt-acesso.idaceant = FALSE.
     
     END. /* num_entries(craptel.cdopptel) */

     GET NEXT q_craptel.
  END.
  QUERY q_craptel:QUERY-CLOSE().    
  
END PROCEDURE.

/*********************************************************************/
PROCEDURE busca-acessos-tela:

  DEF VAR indice         AS INTE FORMAT 99                 NO-UNDO.
  DEF VAR aux_nmoperad   AS CHAR                           NO-UNDO.
  DEF VAR aux_idambtel   AS INTE                           NO-UNDO. 

  EMPTY TEMP-TABLE tt-acesso.
  
  ASSIGN aux_idambtel = INTEGER(SUBSTRING(tel_idambtel,1,1)).
    
  FOR EACH crapace NO-LOCK
     WHERE crapace.cdcooper = glb_cdcooper
       AND crapace.nmdatela = tel_nmdatela
       AND ((tel_nmrotina = "") OR
            (tel_nmrotina <> "" AND
             crapace.nmrotina = tel_nmrotina))
       AND ((tel_cdpermis = "") OR
            (tel_cdpermis <> "" AND
             crapace.cddopcao = tel_cdpermis))
       AND crapace.idambace = aux_idambtel:
      
      FIND FIRST crapope
           WHERE crapope.cdcooper = crapace.cdcooper
             AND crapope.cdoperad = crapace.cdoperad NO-LOCK NO-ERROR.
      IF NOT AVAIL crapope THEN
         NEXT. 
      ELSE 
           DO:
               IF  crapope.cdsitope = 2 THEN
                   NEXT.

               IF  crapope.cdoperad = "1" THEN
                   NEXT.
               
               aux_nmoperad = crapope.cdoperad + " - " +
                              crapope.nmoperad.
           END.

      FIND FIRST craptel
           WHERE craptel.cdcooper = crapace.cdcooper
             AND craptel.nmdatela = crapace.nmdatela
             AND craptel.nmrotina = crapace.nmrotina
            NO-LOCK NO-ERROR.

      IF AVAIL craptel THEN DO:
          DO indice = 1 TO NUM-ENTRIES(craptel.cdopptel):
              IF crapace.cddopcao = ENTRY(indice, craptel.cdopptel) THEN DO:                 
                 CREATE tt-acesso.
                 ASSIGN tt-acesso.nmoperad = aux_nmoperad
                        tt-acesso.nmrotina = crapace.nmrotina
                        tt-acesso.cdopptel = ENTRY(indice, craptel.cdopptel)
                        tt-acesso.nmopptel = ENTRY(indice, craptel.lsopptel).
              END.
              ELSE NEXT.
          END.
      END.

  END. /* FIM do FOR EACH crapace*/

END PROCEDURE.

/* ......................................................................... */
PROCEDURE liberar_telas_consulta:

  DEF VAR indice AS INTE FORMAT 99 NO-UNDO.
  DEF VAR aux_idambtel AS INTE NO-UNDO.
  DEF VAR aux_qcraptel AS CHAR NO-UNDO.                                 

  DEF QUERY q_craptel FOR craptel.

  HIDE MESSAGE NO-PAUSE.
  BELL.
  MESSAGE "Aguarde...".

  ASSIGN aux_idambtel = INTEGER(SUBSTRING(tel_idambtel,1,1)).

  IF  aux_idambtel = 3 THEN
      ASSIGN aux_qcraptel = "craptel.idsistem = 2".
  ELSE
      ASSIGN aux_qcraptel = "craptel.idsistem = 1 AND
                             (craptel.idambtel = " + STRING(aux_idambtel) + 
                             " OR craptel.idambtel = 0)".

  ASSIGN aux_query = "FOR EACH craptel NO-LOCK WHERE craptel.cdcooper = " + 
                            STRING(glb_cdcooper) + " AND " + aux_qcraptel + 
                            "BY craptel.nmdatela BY craptel.nmrotina:".
  
  QUERY q_craptel:QUERY-CLOSE().
  QUERY q_craptel:QUERY-PREPARE(aux_query).
  QUERY q_craptel:QUERY-OPEN().

  GET FIRST q_craptel.
  
  DO WHILE AVAIL(craptel):
                   
      DO indice = 1 TO NUM-ENTRIES(craptel.cdopptel):
          
          IF NUM-ENTRIES(craptel.cdopptel) <> NUM-ENTRIES(craptel.lsopptel) 
          THEN NEXT.

          IF TRIM(ENTRY(indice, craptel.lsopptel)) MATCHES "*CONSULTA*" THEN
            DO:                   
               FIND FIRST crapace 
                    WHERE crapace.cdcooper = glb_cdcooper AND
                          crapace.nmdatela = craptel.nmdatela AND
                          crapace.nmrotina = craptel.nmrotina AND
                          crapace.cddopcao = ENTRY(indice, craptel.cdopptel) AND
                          crapace.cdoperad = tel_cdoperad AND
                          crapace.idambace = aux_idambtel NO-LOCK NO-ERROR.
               
               IF NOT AVAIL crapace THEN
               DO:
                  CREATE crapace.            
                  ASSIGN crapace.nmdatela = craptel.nmdatela
                         crapace.nmrotina = craptel.nmrotina
                         crapace.cddopcao = ENTRY(indice, craptel.cdopptel)
                         crapace.cdoperad = tel_cdoperad
                         crapace.cdcooper = glb_cdcooper
                         crapace.idambace = aux_idambtel.
                  VALIDATE crapace.
               END.
            END.
      END.
      GET NEXT q_craptel.

   END.   
   
   QUERY q_craptel:QUERY-CLOSE().
   HIDE MESSAGE NO-PAUSE.
   BELL.
   MESSAGE "Telas de consulta liberadas para acesso!".

END PROCEDURE.

/* ......................................................................... */
PROCEDURE exclusao_acesso:
    
    DEF VAR aux_idambtel AS INTE NO-UNDO.

    HIDE MESSAGE NO-PAUSE.
    BELL.
    MESSAGE "Aguarde...".
    
    ASSIGN aux_idambtel = INTEGER(SUBSTRING(tel_idambtel,1,1)).

    FOR EACH craptel WHERE craptel.cdcooper = glb_cdcooper NO-LOCK:
        FOR EACH crapace EXCLUSIVE-LOCK
            WHERE crapace.cdcooper = craptel.cdcooper AND
                  crapace.nmdatela = craptel.nmdatela AND
                  crapace.nmrotina = craptel.nmrotina AND 
                  crapace.cdoperad = tel_cdoperad     AND
                  crapace.idambace = aux_idambtel:
            DELETE crapace.
        END.

        /* Se for CARACTER elimina opções WEB também */
        IF  aux_idambtel = 1 THEN
            FOR EACH crapace EXCLUSIVE-LOCK
                WHERE crapace.cdcooper = craptel.cdcooper AND
                      crapace.nmdatela = craptel.nmdatela AND
                      crapace.nmrotina = craptel.nmrotina AND 
                      crapace.cdoperad = tel_cdoperad     AND
                      crapace.idambace = 2:
                DELETE crapace.
        END.

    END.

    HIDE MESSAGE NO-PAUSE.
    BELL.
    MESSAGE "Exclusao realizada!".

END PROCEDURE.

/* ......................................................................... */
PROCEDURE executa_relatorio:

DEF   VAR aux_flgexist   AS LOGICAL                                  NO-UNDO.

DEF   VAR par_flgcance   AS LOGICAL                                  NO-UNDO.
DEF   VAR par_flgrodar   AS LOGICAL    INIT TRUE                     NO-UNDO.
DEF   VAR par_flgfirst   AS LOGICAL    INIT TRUE                     NO-UNDO.

DEF   VAR tel_dsimprim   AS CHAR  FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF   VAR tel_dscancel   AS CHAR  FORMAT "x(8)" INIT "Cancelar"      NO-UNDO. 
DEF   VAR tel_nmarquiv   AS CHAR  FORMAT "x(25)"                     NO-UNDO.
DEF   VAR tel_nmdireto   AS CHAR  FORMAT "x(20)"                     NO-UNDO.

DEF   VAR aux_flgescra   AS LOGICAL                                  NO-UNDO.
DEF   VAR aux_dscomand   AS CHAR                                     NO-UNDO.
DEF   VAR aux_contador   AS INT                                      NO-UNDO.

DEF   VAR aux_nmarqimp   AS CHAR                                     NO-UNDO.
DEF   VAR aux_nmendter   AS CHAR FORMAT "x(20)"                      NO-UNDO.   

DEF   VAR rel_nmempres   AS CHAR  FORMAT "x(15)"                     NO-UNDO.
DEF   VAR rel_nmrelato   AS CHAR  FORMAT "x(40)" EXTENT 5            NO-UNDO.
DEF   VAR rel_nrmodulo   AS INT   FORMAT "9"                         NO-UNDO.

DEF   VAR rel_nmresemp   AS CHAR                                     NO-UNDO.
DEF   VAR rel_nmmodulo   AS CHAR  FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.

FORM tt-acesso.nmdatela AT 10 LABEL "Tela"
     tt-acesso.nmrotina AT 21 LABEL "Rotina"  FORMAT "x(25)"
     tt-acesso.nmopptel AT 58 LABEL "Opcao"   FORMAT "x(35)"
     tt-acesso.idacenov       LABEL "Lib"     
     WITH WIDTH 110 ROW 12 COLUMN 2 NO-BOX NO-LABELS 9 DOWN OVERLAY FRAME f_lanctos.
     
FORM HEADER 
     "PERMISSOES DO OPERADOR:"
     tel_cdoperad                                       NO-LABEL
     "-"
     tel_nmoperad FORMAT "x(19)"                        NO-LABEL
     SKIP
     "AMBIENTE ACESSO:"
     tel_idambtel:SCREEN-VALUE IN FRAME f_relatorio  FORMAT "X(12)"    NO-LABEL
     SKIP(1)
     WITH PAGE-TOP FRAME f_permis_rel.
                                  
FORM
    "Diretorio:   "     AT 5
    tel_nmdireto
    tel_nmarquiv        HELP "Informe o nome do arquivo."
    WITH OVERLAY ROW 10 NO-LABEL NO-BOX COLUMN 2 FRAME f_diretorio.

    
        
    INPUT THROUGH basename `tty` NO-ECHO.

    SET aux_nmendter WITH FRAME f_terminal.

    INPUT CLOSE.
    
    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
    IF  tel_nmdopcao  THEN
        DO:
            ASSIGN tel_nmdireto = "/micros/" + crapcop.dsdircop + "/".
            
            DISP tel_nmdireto WITH FRAME f_diretorio.
            
            UPDATE tel_nmarquiv WITH FRAME f_diretorio.
            
            ASSIGN aux_nmarqimp = tel_nmdireto + tel_nmarquiv.
        END.
    ELSE
        ASSIGN aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + 
                              "/rl/crrl512.lst" .
   
    /* Inicializa Variaveis Relatorio */
       ASSIGN glb_cdcritic = 0
              glb_cdrelato[1] = 512.
             
    { includes/cabrel080_1.i }
   
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 80.
    
    VIEW STREAM str_1 FRAME f_cabrel080_1.

    VIEW STREAM str_1 FRAME f_permis_rel.

    RUN busca-acessos.        
    
    FOR EACH tt-acesso NO-LOCK:
            
        DISPLAY STREAM str_1 tt-acesso.nmdatela 
                             tt-acesso.nmrotina 
                             tt-acesso.nmopptel
                             tt-acesso.idacenov
                             WITH FRAME f_lanctos.
                               
        DOWN STREAM str_1 WITH FRAME f_lanctos.
                
        ASSIGN aux_flgexist = TRUE.
    END.
           
    OUTPUT STREAM str_1 CLOSE.    /* fim do arquivo */
            
    IF  tel_nmdopcao  THEN
        DO:
            UNIX SILENT VALUE("cp " + aux_nmarqimp + " " + aux_nmarqimp + 
                              "_copy").
                                           
            UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + "_copy" +
                              ' | tr -d "\032" > ' + aux_nmarqimp +
                              " 2>/dev/null").
                        
            UNIX SILENT VALUE("rm " + aux_nmarqimp + "_copy").

            BELL.
            MESSAGE "Arquivo gerado com sucesso no diretorio: " + aux_nmarqimp.
            PAUSE 3 NO-MESSAGE.
        END.
    ELSE
        IF  aux_flgexist  THEN
            DO:
                RUN confirma.
                IF  aux_confirma = "S"  THEN
                    DO:
                        ASSIGN  glb_nmformul = "80col"
                                glb_nrcopias = 1
                                glb_nmarqimp = aux_nmarqimp.
                        
                        FIND FIRST crapass NO-LOCK WHERE 
                                   crapass.cdcooper = glb_cdcooper NO-ERROR. 
                    
                        { includes/impressao.i }
                    END.
            END.
        ELSE
            DO:
                ASSIGN glb_cdcritic = 263.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                PAUSE 2 NO-MESSAGE.
                NEXT.
            END.
            
    HIDE FRAME f_diretorio.
    HIDE FRAME f_dados.
                             
END PROCEDURE.

PROCEDURE proc_permis: /* Permissos do progrid dependendo dos prog. e idevento*/

    DEF INPUT PARAM par_nmdatela AS CHAR          NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR INIT "1" NO-UNDO.
    DEF INPUT PARAM par_idevento AS INT           NO-UNDO.

    /*IF   CAN-DO("wpgd0007,wpgd0031,wpgd0032,wpgd0024,wpgd0010,wpgd0029," +
                "wpgd0019,wpgd0027,wpgd0018,wpgd0017,wpgd0039,wpgd0014",
                par_nmdatela)          AND
                par_idevento = 1   THEN
         DO:          
             IF   par_cddopcao <> "C"   THEN
                  RETURN "NOK".
         END.*/

    RETURN "OK".

END PROCEDURE.

PROCEDURE confirma.

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
      RUN fontes/critic.p.
      glb_cdcritic = 0.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 2 NO-MESSAGE.
            CLEAR FRAME f_cadgps.
        END. /* Mensagem de confirmacao */

END PROCEDURE.

PROCEDURE proc_traz_operadores:

   DEF INPUT PARAM par_nvoperad AS INTE                           NO-UNDO. 

   DEF VAR         aux_ultlinha AS INTE                           NO-UNDO.

   ON "DELETE" OF b-operadores IN FRAME f_ope DO:
   
       IF   NOT AVAILABLE w-operadores   THEN
            RETURN.
       
       DELETE w-operadores.
             
       /* linha que foi deletada */
       aux_ultlinha = CURRENT-RESULT-ROW("q-operadores").
          
       OPEN QUERY q-operadores FOR EACH w-operadores
                                           BY w-operadores.cdoperad.

       /* reposiciona o browse */
       REPOSITION q-operadores TO ROW aux_ultlinha.

   END. 
   
   EMPTY TEMP-TABLE w-operadores.
  
   ASSIGN par_nvoperad = 1 WHEN par_nvoperad = 0. 

   /* Traz os op. do nivel 1 - Operador, 2 - Supervisor ou 3 - Gerente) */
    
   FOR EACH crapope WHERE crapope.cdcooper = glb_cdcooper   AND
                          crapope.cdsitope = 1              AND
                          crapope.nvoperad = par_nvoperad   NO-LOCK:
                          
            /* Ignora operadores CECRED */
       IF   crapope.nmoperad MATCHES "*AILOS*"     OR
            crapope.cddepart = 20 /* TI */         THEN

            NEXT.
    
       CREATE w-operadores.
       ASSIGN w-operadores.cdoperad = crapope.cdoperad
              w-operadores.nmoperad = crapope.nmoperad.
                 
   END.                       

   OPEN QUERY q-operadores FOR EACH w-operadores BY w-operadores.nmoperad.
    
   DO WHILE TRUE ON ENDKEY UNDO , LEAVE:
    
      UPDATE b-operadores WITH FRAME f_ope.
      LEAVE. 
    
   END. 

END PROCEDURE.   

PROCEDURE proc_libera_nivel:

DEF INPUT PARAM par_cdcooper AS INTE                                    NO-UNDO.
DEF INPUT PARAM par_cdopeglb AS CHAR                                    NO-UNDO.
DEF INPUT PARAM par_cddopcao AS CHAR                                    NO-UNDO.
DEF INPUT PARAM par_nmdatela AS CHAR                                    NO-UNDO.
DEF INPUT PARAM par_cdoperad AS CHAR                                    NO-UNDO.
DEF INPUT PARAM par_nvoperad AS CHAR                                    NO-UNDO.
   
   /* Para cada opcao de rotina da tela selecionada ... */

    FOR EACH tt-acesso WHERE tt-acesso.idacenov NO-LOCK,     

       EACH w-operadores NO-LOCK:  /* Para cada operador selecionado */

            /* Se nao acha permissao entao cria ... */
                    
            IF NOT CAN-FIND(crapace WHERE 
                            crapace.cdcooper = par_cdcooper           AND
                            crapace.nmdatela = tt-acesso.nmdatela     AND
                            crapace.nmrotina = tt-acesso.nmrotina     AND
                            crapace.cddopcao = tt-acesso.cdopptel     AND
                            crapace.cdoperad = w-operadores.cdoperad  AND
                            crapace.idambace = tt-acesso.idambtel
                            NO-LOCK)                                  THEN
               DO:
                   CREATE crapace.
                   ASSIGN crapace.cdcooper = par_cdcooper
                          crapace.cdoperad = w-operadores.cdoperad
                          crapace.nmdatela = tt-acesso.nmdatela
                          crapace.cddopcao = tt-acesso.cdopptel
                          crapace.nmrotina = tt-acesso.nmrotina
                          crapace.nrmodulo = 1
                          crapace.idambace = tt-acesso.idambtel.
                   VALIDATE crapace.
               END.

            RUN log-tela-permis(INPUT TODAY,
                                INPUT glb_cdcooper,
                                INPUT glb_cdoperad,
                                INPUT glb_cddopcao,
                                INPUT tt-acesso.nmdatela,
                                INPUT tel_cdoperad,
                                INPUT tt-acesso.nmrotina,
                                INPUT tt-acesso.cdopptel,
                                INPUT tt-acesso.idaceant,
                                INPUT tt-acesso.idacenov,
                                INPUT "",
                                INPUT par_nvoperad,
                                INPUT w-operadores.cdoperad,
                                INPUT tt-acesso.idambtel,
                                INPUT "").
   
   END.   /* Fim da opcao da rotina da tela selecionada */

END PROCEDURE. /* Fim da procedure libera opcao da tela para o nivel */

PROCEDURE proc_hide_frame:
    
    HIDE FRAME f_permis
         FRAME f_permis_tela
         FRAME f_lib_consulta
         FRAME f_copia
         FRAME f_relatorio
         FRAME f_libera_nivel
         FRAME f_ope
         FRAME f_tt-acesso_c
         FRAME f_tt-acesso_l
         FRAME f_tt-acesso_a.

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_gerar_relatorio:

DEF   VAR tel_nmarquiv   AS CHAR  FORMAT "x(25)"                     NO-UNDO.
DEF   VAR tel_nmdireto   AS CHAR  FORMAT "x(20)"                     NO-UNDO.

FORM
    "Diretorio:   "     AT 5
    tel_nmdireto
    tel_nmarquiv        HELP "Informe o nome do arquivo."
    WITH OVERLAY ROW 10 NO-LABEL NO-BOX COLUMN 2 FRAME f_diretorio.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       ASSIGN aux_confirma = "N".
       RUN fontes/critic.p.
       glb_cdcritic = 0.
       BELL.
       MESSAGE COLOR NORMAL
          "Listar Opcoes Acesso em Arquivo? (S/N):" 
               UPDATE aux_confirma.
       LEAVE.
    END.  /*  Fim do DO WHILE TRUE  */

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
         DO:
             glb_cdcritic = 79.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             NEXT.
         END.

    IF aux_confirma = "S" THEN DO:

        HIDE FRAME f_tt-acesso_l.

        FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

        ASSIGN tel_nmdireto = "/micros/" + crapcop.dsdircop + "/".
        
        DISP tel_nmdireto WITH FRAME f_diretorio.
        
        UPDATE tel_nmarquiv WITH FRAME f_diretorio.
        
        ASSIGN aux_nmarqimp = tel_nmdireto + tel_nmarquiv.

        /*ASSIGN aux_nmarqimp = "rl/crrl576.lst".*/
        
        { includes/cabrel080_1.i }
        
        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
        
        VIEW STREAM str_1 FRAME f_cabrel080_1.
        
        DISPLAY STREAM str_1 tel_nmdatela
            WITH FRAME f_permis_cab.
        
        FOR EACH b-tt-acesso NO-LOCK
              BY b-tt-acesso.nmrotina
              BY b-tt-acesso.nmopptel
              BY b-tt-acesso.nmoperad:
         
              DISPLAY STREAM str_1 b-tt-acesso.nmrotina
                                   b-tt-acesso.nmopptel
                                   b-tt-acesso.nmoperad
                        WITH FRAME f_permis_relat.
              DOWN STREAM str_1 WITH FRAME f_permis_relat.
        END.
        
        OUTPUT STREAM str_1 CLOSE.

        MESSAGE "Relatorio gerado em " aux_nmarqimp.
        PAUSE 2 NO-MESSAGE.
    END.

END PROCEDURE.

PROCEDURE log-tela-permis:
   
   DEF INPUT PARAM par_dtmvtolt AS DATE              NO-UNDO.
   DEF INPUT PARAM par_cdcooper AS INT               NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR              NO-UNDO.
   DEF INPUT PARAM par_cddopcao AS CHAR              NO-UNDO.
   DEF INPUT PARAM par_nmdatela AS CHAR              NO-UNDO.
   DEF INPUT PARAM par_dscopera AS CHAR              NO-UNDO.
   DEF INPUT PARAM par_nmrotina AS CHAR              NO-UNDO.
   DEF INPUT PARAM par_cdopptel AS CHAR              NO-UNDO.
   DEF INPUT PARAM par_idaceant AS LOG               NO-UNDO.
   DEF INPUT PARAM par_idacenov AS LOG               NO-UNDO.
   DEF INPUT PARAM par_cdopedst AS CHAR              NO-UNDO.
   DEF INPUT PARAM par_nvoperad AS CHAR              NO-UNDO.
   DEF INPUT PARAM par_opaltera AS CHAR              NO-UNDO.
   DEF INPUT PARAM par_idambace AS INTE              NO-UNDO.
   DEF INPUT PARAM par_nmarquiv AS CHAR              NO-UNDO.

   IF par_cddopcao = "E" THEN
           UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")   +
                          " "     + STRING(TIME,"HH:MM:SS") + "' --> '"    +
                          " Opcao: " + par_cddopcao                        +
                          " - Operador: "  + par_cdoperad                  +
                          " - Operador excluido: " + par_dscopera          +
                          " - Ambiente: " + (IF par_idambace = 1 THEN " CARACTER" ELSE IF par_idambace = 2 THEN " WEB" ELSE " PROGRID") +
                          ". >> log/permis.log").
        ELSE
        IF par_cddopcao = "P" THEN
           UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")   +
                          " "     + STRING(TIME,"HH:MM:SS") + "' --> '"    +
                          " Opcao: " + par_cddopcao                        +
                          " - Operador: "  + par_cdoperad                  +
                          " - Operador Orig.: " + par_dscopera             +
                          " - Operador dest.: " + par_cdopedst             +
                          " - Ambiente: " + (IF par_idambace = 1 THEN " CARACTER" ELSE IF par_idambace = 2 THEN " WEB" ELSE " PROGRID") +
                          ". >> log/permis.log").
        ELSE
        IF par_cddopcao = "A" THEN
           UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                          " "     + STRING(TIME,"HH:MM:SS") + "' --> '"  +
                          " Opcao: " + par_cddopcao                      +
                          " - Operador: "  + par_cdoperad                +
                          " alterou o operador: " + par_dscopera         +
                          " - Tela: " + par_nmdatela                     +
                          " - Rotina: " + par_nmrotina                   +
                          " - Opcao: " + par_cdopptel                    +
                          " - Ambiente: " + (IF par_idambace = 1 THEN " CARACTER" ELSE IF par_idambace = 2 THEN " WEB" ELSE " PROGRID") +
                          " de " + (IF par_idaceant THEN "SIM" ELSE "NAO") + " para " + (IF par_idacenov THEN "SIM" ELSE "NAO") + 
                          ". >> log/permis.log").
        ELSE
        IF par_cddopcao = "N" THEN
           UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")   +
                          " "     + STRING(TIME,"HH:MM:SS") + "' --> '"    +
                          " Opcao: " + par_cddopcao                        +
                          " - Operador: "  + par_cdoperad                  +
                          " - Nivel Operad: " + par_nvoperad               +
                          " - Operador Alterado: " + par_opaltera          +
                          " - Tela: " + par_nmdatela                       +
                          " - Opcao: " + par_cdopptel                      +
                          " - Ambiente: " + (IF par_idambace = 1 THEN " CARACTER" ELSE IF par_idambace = 2 THEN " WEB" ELSE " PROGRID") +
                          " de " + (IF par_idaceant THEN "SIM" ELSE "NAO") + " para " + (IF par_idacenov THEN "SIM" ELSE "NAO") + 
                          ". >> log/permis.log").
        ELSE
        IF par_cddopcao = "I" THEN
           UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")        +
                          " "     + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                          " Opcao: " + par_cddopcao                             +
                          " - Operador: "  + par_cdoperad                       +
                          " - Realizou a importacao do arquivo de permissoes: " + par_nmarquiv +
                          ". >> log/permis.log").

END PROCEDURE.

PROCEDURE opcao-importa-permis:

    DEF VAR aux_confirma AS CHARACTER FORMAT "!(1)"                  NO-UNDO.

    FORM SKIP(2)
         "Nome do arquivo a ser importado:" AT 5
         SKIP(1)
         tel_dsdireto   AT 5  NO-LABEL
         SKIP(1)
         tel_nmarqint   AT 5  NO-LABEL
         HELP "Informe o diretorio do arquivo (.csv) p/ importar permissoes."
         VALIDATE(INPUT tel_nmarqint <> "","375 - O campo deve ser preenchido.")
         SKIP(2)
         WITH WIDTH 70 OVERLAY ROW 9 CENTERED SIDE-LABELS
              TITLE " Importacao de Arquivo de Permissoes " FRAME f_importa_permis.

    HIDE FRAME f_permis.
    HIDE FRAME f_lib_consulta.
    HIDE FRAME f_copia.

    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

    ASSIGN tel_nmarqint = ""
           tel_dsdireto = "/micros/" + crapcop.dsdircop + "/".

    DISPLAY tel_dsdireto WITH FRAME f_importa_permis.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_nmarqint WITH FRAME f_importa_permis.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           aux_confirma = "N".
           glb_cdcritic = 78.
           RUN fontes/critic.p.
           MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
           glb_cdcritic = 0.
           LEAVE.
        END.

        IF  aux_confirma <> "S" THEN
            DO:
                MESSAGE "Operacao nao efetuada.".
                NEXT.
            END.

        IF  INDEX(tel_nmarqint , ".csv") = 0 THEN
            ASSIGN tel_nmarqint = tel_nmarqint + ".csv".

        IF  SEARCH(tel_dsdireto + TRIM(tel_nmarqint)) = ?  THEN
            DO:
                MESSAGE "Arquivo nao localizado.".
                NEXT.
            END.

        RUN importa-arquivo-permissoes.

        IF  RETURN-VALUE <> "NOK" THEN
            MESSAGE "Operacao efetuada com sucesso!".

        LEAVE.
        
    END.

    glb_cdcritic = 0.
    HIDE FRAME f_importa_permis.

END PROCEDURE.

PROCEDURE importa-arquivo-permissoes:

    /* Layout do Arquivo: OPERADOR;TELA;AMBIENTE;ROTINA;OPCAO */

    DEF VAR aux_cdoperad    LIKE crapope.cdoperad                          NO-UNDO.
    DEF VAR aux_idambace    LIKE crapace.idambace                          NO-UNDO.
    DEF VAR aux_iddopcao    AS INTE                                        NO-UNDO.
    DEF VAR aux_contador    AS INTE   INIT 0                               NO-UNDO.
    DEF VAR aux_cddopcao    AS CHAR                                        NO-UNDO.
    DEF VAR aux_crittela    AS CHAR                                        NO-UNDO.
    DEF VAR aux_nmdatela    AS CHAR                                        NO-UNDO.
    DEF VAR aux_nmrotina    AS CHAR                                        NO-UNDO.
    
    ASSIGN aux_crittela =  "Tela(s) "
           tel_nmarqint = tel_dsdireto + TRIM(tel_nmarqint).

    INPUT STREAM str_1 FROM VALUE(tel_nmarqint) NO-ECHO.

    DO TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
            IMPORT STREAM str_1 UNFORMATTED aux_setlinha. 

            /* Despreza primeira linha */
            IF  CAPS(TRIM(ENTRY(1, aux_setlinha, ";"))) = CAPS("OPERADOR") OR
                aux_setlinha = " "                             THEN
                NEXT.

            ASSIGN aux_cdoperad = TRIM(ENTRY(1, aux_setlinha, ";"))
                   aux_nmrotina = TRIM(ENTRY(4, aux_setlinha, ";"))
                   aux_cddopcao = " ".

            FIND FIRST crapope WHERE crapope.cdcooper = crapcop.cdcooper AND
                                     crapope.cdoperad = aux_cdoperad     
                                     NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapope THEN
                NEXT.

            FIND FIRST craptel WHERE craptel.cdcooper = crapcop.cdcooper                  AND                                     
                                     craptel.nmdatela = TRIM(ENTRY(2, aux_setlinha, ";")) AND
                                     craptel.nmrotina = aux_nmrotina
                                     NO-LOCK NO-ERROR.

            IF  NOT AVAIL craptel THEN
                DO:
                    ASSIGN aux_crittela = aux_crittela + TRIM(ENTRY(2, aux_setlinha, ";")) + ","
                           aux_contador = aux_contador + 1.
                    NEXT.
                END.
            ELSE
                ASSIGN aux_nmdatela = craptel.nmdatela.
                
            FOR EACH craptel WHERE craptel.cdcooper = crapcop.cdcooper  AND
                                   craptel.nmdatela = aux_nmdatela      AND
                                   craptel.nmrotina = aux_nmrotina      NO-LOCK:

                /* Para cada Opção da Tela */
                DO aux_iddopcao = 1 TO NUM-ENTRIES(craptel.cdopptel,","):

                    IF  CAPS(TRIM(ENTRY(5, aux_setlinha, ";"))) = 
                        CAPS(ENTRY(aux_iddopcao,craptel.lsopptel,",")) THEN
                        DO:
                            ASSIGN aux_cddopcao = ENTRY(aux_iddopcao,craptel.cdopptel,",").
                            LEAVE.
                        END.
                        
                END.
                
            END.

            ASSIGN aux_idambace = INTE(TRIM(ENTRY(3, aux_setlinha, ";"))).

            IF  aux_cdoperad = " "  OR
                aux_idambace = 0    OR
                aux_cddopcao = " "  THEN
                NEXT.

            CREATE tt-importa-permissoes.
            ASSIGN tt-importa-permissoes.cdoperad = aux_cdoperad
                   tt-importa-permissoes.nmdatela = aux_nmdatela
                   tt-importa-permissoes.idambace = aux_idambace
                   tt-importa-permissoes.nmrotina = aux_nmrotina
                   tt-importa-permissoes.cddopcao = aux_cddopcao.

            NEXT.
        END.
    END.

    INPUT STREAM str_1 CLOSE.

    IF  NOT TEMP-TABLE tt-importa-permissoes:HAS-RECORDS THEN
        DO:
            MESSAGE "Arquivo para importacao sem telas validas.".
            RETURN "NOK".
        END.

    RUN cria-permissoes-importacao.

    IF  aux_contador > 0 THEN        
        DO: 
            ASSIGN aux_crittela = SUBSTRING(aux_crittela, 1, (LENGTH(aux_crittela) - 1)) + " nao encontrada(s).".
            MESSAGE aux_crittela.
        END.

    RUN log-tela-permis (INPUT TODAY,
                         INPUT glb_cdcooper,
                         INPUT glb_cdoperad,
                         INPUT glb_cddopcao,
                         INPUT "",
                         INPUT "",
                         INPUT "",
                         INPUT "",
                         INPUT YES,
                         INPUT YES,
                         INPUT "",
                         INPUT "",
                         INPUT "",
                         INPUT 0,
                         INPUT tel_nmarqint).

    RETURN "OK".

END PROCEDURE.

PROCEDURE cria-permissoes-importacao:
    
    /* Para cada registro no arquivo */
    FOR EACH tt-importa-permissoes NO-LOCK
                                   BREAK BY tt-importa-permissoes.cdoperad:

        /* Deleta todas as permissões do operador */
        IF  FIRST-OF(tt-importa-permissoes.cdoperad) THEN
            DO:
                FOR EACH craptel WHERE craptel.cdcooper = crapcop.cdcooper NO-LOCK.
                    FOR EACH crapace WHERE crapace.cdcooper = craptel.cdcooper           AND
                                           crapace.nmdatela = craptel.nmdatela           AND
                                           crapace.nmrotina = craptel.nmrotina           AND
                                           crapace.cdoperad = tt-importa-permissoes.cdoperad
                                           EXCLUSIVE-LOCK.
                        DELETE crapace.
                    END.
                END.
            END.

        /* Verifica se operador já tem permissão antes de criar */
        FIND FIRST crapace WHERE crapace.cdcooper = crapcop.cdcooper               AND
                                 crapace.nmdatela = tt-importa-permissoes.nmdatela AND
                                 crapace.nmrotina = tt-importa-permissoes.nmrotina AND 
                                 crapace.cddopcao = tt-importa-permissoes.cddopcao AND
                                 crapace.cdoperad = tt-importa-permissoes.cdoperad AND
                                 crapace.idambace = tt-importa-permissoes.idambace
                                 NO-LOCK NO-ERROR.
    
        /* Se não tiver, cria nova permissão */
        IF  NOT AVAIL crapace THEN
            DO:
                CREATE crapace.
                ASSIGN crapace.cdcooper = crapcop.cdcooper
                       crapace.nmdatela = tt-importa-permissoes.nmdatela
                       crapace.nmrotina = tt-importa-permissoes.nmrotina
                       crapace.cddopcao = tt-importa-permissoes.cddopcao
                       crapace.cdoperad = tt-importa-permissoes.cdoperad
                       crapace.idambace = tt-importa-permissoes.idambace.

                /* Se a nova permissão for para ambiente CARACTER, atribuir também à WEB */
                IF  tt-importa-permissoes.idambace = 1 THEN
                    DO:
                        CREATE crapace.
                        ASSIGN crapace.cdcooper = crapcop.cdcooper
                               crapace.nmdatela = tt-importa-permissoes.nmdatela
                               crapace.nmrotina = tt-importa-permissoes.nmrotina
                               crapace.cddopcao = tt-importa-permissoes.cddopcao
                               crapace.cdoperad = tt-importa-permissoes.cdoperad
                               crapace.idambace = 2 /* WEB */.
                    END.
            END.
    END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

