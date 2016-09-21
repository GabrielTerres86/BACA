/* .............................................................................

   Programa: Fontes/gt0014.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Setembro/2006                  Ultima Atualizacao: 21/02/2013.  

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Mostrar situacao dos helps das telas e permitir alteracao do
               campo craptel.idambtel.
         
   Alteracao : 15/01/2007 - Incluida opcao de busca por nome ou por titulo da
                            tela (Elton).
                            
               06/08/2008 - Incluida opcao "L" para liberacao de telas 
                            na INTRANET (Gabriel).

               23/01/2009 - Retirada permissao do operador 799 e permissao ao
                            979 (Gabriel). 

               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               16/04/2012 - Fonte substituido por gt0014p.p (Tiago).
               
               21/02/2013 - Retirado campo craptel.flgdonet por craptel.idambtel
                            'Ambiente Acesso' (Jorge).
............................................................................. */

{ includes/var_online.i } 

DEF VAR tel_opcao    AS CHAR    FORMAT "!(1)" INIT "C"                 NO-UNDO.
DEF VAR tel_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR tel_tldatela AS CHAR    FORMAT "x(25)"                         NO-UNDO.
DEF VAR tel_idambtel AS INTE    FORMAT "9"                             NO-UNDO.
DEF VAR aux_confirma AS LOGICAL FORMAT "S/N"                           NO-UNDO.

DEF TEMP-TABLE w-gnchelp                                               NO-UNDO
    FIELD nmdatela LIKE gnchelp.nmdatela  
    FIELD nrversao LIKE gnchelp.nrversao
    FIELD nmrotina LIKE gnchelp.nmrotina
    FIELD dtmvtolt LIKE gnchelp.dtmvtolt
    FIELD conthelp AS CHAR                  FORMAT "!(3)".


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM "Opcao:" 
     glb_cddopcao  
     HELP "Informe 'C' p/consulta por nome, 'D' por descr. e 'L' liberacao."
     VALIDATE (CAN-DO("L,C,D",glb_cddopcao),"014 - Opcao errada.")
     WITH FRAME f_opcao NO-BOX NO-LABEL  ROW 6  COLUMN 4 OVERLAY.

FORM "Nome da Tela:"
     tel_nmdatela
     HELP "Informe o nome da tela ou deixe em branco para listar todas."
     WITH FRAME f_nome_tela NO-BOX NO-LABEL  ROW 6  COLUMN 17 OVERLAY.

FORM "Descricao da Tela:" 
     tel_tldatela     
     HELP "Informe a descricao da tela ou deixe em branco para listar todas."
     WITH FRAME f_titulo_tela NO-BOX NO-LABEL  ROW 6  COLUMN 17 OVERLAY.

FORM "Ambiente de Acesso:"
     tel_idambtel 
     HELP "Informe 0 - Todos, 1 - Caracter, 2 - Web"
     WITH CENTERED FRAME f_craptel NO-LABEL SIDE-LABELS ROW 10 OVERLAY.

FORM craptel.tldatela LABEL "Descricao da Tela" 
     WITH FRAME f_dados NO-BOX NO-LABEL SIDE-LABELS ROW 20 COLUMN 4 OVERLAY.

DEF QUERY  telas-q FOR craptel, w-gnchelp FIELDS(conthelp nrversao dtmvtolt).
DEF BROWSE telas-b QUERY telas-q 
      
      DISPLAY   craptel.nmdatela     COLUMN-LABEL "Tela"      FORMAT "x(8)"
                craptel.tldatela     COLUMN-LABEL "Descricao" FORMAT "x(22)"
                craptel.nmrotina                              FORMAT "x(16)"
                (IF craptel.idambtel = 0 THEN 'TODOS'  ELSE
                 IF craptel.idambtel = 1 THEN 'CARAC'  ELSE
                 IF craptel.idambtel = 2 THEN 'WEB'    ELSE '')     
                                     COLUMN-LABEL "Amb."      FORMAT "X(6)"    
                w-gnchelp.conthelp   COLUMN-LABEL "Help"   
                w-gnchelp.nrversao   COLUMN-LABEL "Ver."      FORMAT "zz9" 
                w-gnchelp.dtmvtolt   COLUMN-LABEL "Data"    
                WITH WIDTH 78 9 DOWN OVERLAY NO-BOX.    

DEF FRAME f_telas_help
          telas-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 COLUMN 3.

ON  VALUE-CHANGED, ENTRY OF telas-b 
    DO:
        IF  AVAILABLE w-gnchelp  THEN
            DISP craptel.tldatela 
                 WITH FRAME f_dados.           
        ELSE    
            MESSAGE "Nao foram encontrados registros referente a consulta.".
    END.

ON RETURN OF telas-b
   DO:
       IF   CAN-DO("C,D",glb_cddopcao)   THEN
            HIDE FRAME f_telas_help
                 FRAME f_dados
                 FRAME f_titulo_tela.

       APPLY "GO".
   END.

RUN fontes/inicia.p.
          
VIEW FRAME f_moldura.
PAUSE (0).

glb_cddopcao = "C".  
  
DO  WHILE TRUE ON ENDKEY UNDO, LEAVE :  

    HIDE FRAME f_craptel.
    
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE : 
        UPDATE glb_cddopcao WITH FRAME f_opcao. 
        LEAVE.
    END.
    
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
         DO:            
             RUN  fontes/novatela.p.
                  IF   CAPS(glb_nmdatela) <> "GT0014"   THEN
                       LEAVE.
                  ELSE
                       NEXT.
         END.    
    
    IF  glb_cddopcao = "L"   OR
        glb_cddopcao = "C"   THEN
        DO:
            ASSIGN tel_nmdatela = "".
            
            UPDATE tel_nmdatela WITH FRAME f_nome_tela.
            
            EMPTY TEMP-TABLE w-gnchelp.
            FOR EACH craptel WHERE 
                             craptel.cdcooper = glb_cdcooper AND 
                             craptel.flgtelbl = yes          AND
                             craptel.nmdatela MATCHES "*" + tel_nmdatela + "*"
                             NO-LOCK:
                
                CREATE  w-gnchelp.
                ASSIGN  w-gnchelp.nmdatela = craptel.nmdatela
                        w-gnchelp.nmrotina = craptel.nmrotina. 
             END.
        END.
    ELSE
        IF glb_cddopcao = "D" THEN
           DO:
               ASSIGN tel_tldatela = "".
            
               UPDATE tel_tldatela WITH FRAME f_titulo_tela.
                   
               EMPTY TEMP-TABLE w-gnchelp.
               FOR EACH craptel WHERE craptel.cdcooper = glb_cdcooper AND 
                                      craptel.flgtelbl = yes          AND
                                      craptel.tldatela MATCHES "*" +
                                      tel_tldatela + "*"
                                      NO-LOCK:
                
                    CREATE  w-gnchelp.
                    ASSIGN  w-gnchelp.nmdatela = craptel.nmdatela
                            w-gnchelp.nmrotina = craptel.nmrotina.
               END.          
           END.
    
    FOR EACH w-gnchelp NO-LOCK:
    
        FIND LAST gnchelp WHERE  gnchelp.nmdatela = w-gnchelp.nmdatela AND
                                 gnchelp.nmrotina = w-gnchelp.nmrotina
                                 NO-LOCK NO-ERROR.
            
        IF  AVAILABLE gnchelp THEN
            DO:
               ASSIGN     w-gnchelp.conthelp = 'SIM'
                          w-gnchelp.nrversao = gnchelp.nrversao
                          w-gnchelp.dtmvtolt = gnchelp.dtmvtolt.
            END.
        ELSE
             w-gnchelp.conthelp = 'NAO'.
    END.

    OPEN QUERY telas-q FOR EACH craptel WHERE 
                                craptel.cdcooper = glb_cdcooper AND
                                craptel.flgtelbl = yes          
                                NO-LOCK,
                
                           LAST w-gnchelp WHERE 
                                w-gnchelp.nmdatela = craptel.nmdatela AND
                                w-gnchelp.nmrotina = craptel.nmrotina
                                NO-LOCK.
                               
    UPDATE telas-b WITH FRAME f_telas_help.

    IF   glb_cddopcao = "L"   THEN
         DO: 
             IF   glb_dsdepart <> "TI"                   AND
                  glb_dsdepart <> "SUPORTE"              AND
                  glb_dsdepart <> "COORD.ADM/FINANCEIRO" AND
                  glb_dsdepart <> "COORD.PRODUTOS"       THEN
                  DO:
                      glb_cdcritic = 36.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      glb_cdcritic = 0.
                      LEAVE.
                  END.
             
             ASSIGN tel_idambtel = craptel.idambtel
                    tel_nmdatela = craptel.nmdatela.
                    
             DISPLAY tel_nmdatela WITH FRAME f_nome_tela.       
             
             UPDATE tel_idambtel WITH FRAME f_craptel.
         
             DO WHILE TRUE:
                ASSIGN aux_confirma = NO
                       glb_cdcritic = 78.
                RUN fontes/critic.p.
                MESSAGE glb_dscritic UPDATE aux_confirma.
                ASSIGN glb_cdcritic = 0.
                LEAVE.
             END.   
               
             IF   NOT aux_confirma   THEN
                  DO:
                      ASSIGN glb_cdcritic = 79.
                      RUN fontes/critic.p.
                      MESSAGE glb_dscritic.
                      PAUSE 1 NO-MESSAGE.
                      glb_cdcritic = 0.
                      LEAVE.
                  END.

             HIDE FRAME f_telas_help
                  FRAME f_dados.
             
             FIND CURRENT craptel EXCLUSIVE-LOCK.
             
             ASSIGN craptel.idambtel = tel_idambtel
                    tel_nmdatela     = "".
         
             DISPLAY tel_nmdatela WITH FRAME f_nome_tela.
         
             MESSAGE "Operacao efetuada com sucesso.".
             
         END.
END.

/*...........................................................................*/

