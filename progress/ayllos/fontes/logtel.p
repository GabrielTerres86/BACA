/*..............................................................................

   Programa: Fontes/logtel.p
   Sistema : Conta-Corrente - Cooperativa de Credito 
   Sigla   : CRED
   Autor   : Martin
   Data    : Junho/2008.                        Ultima Atualizacao: 15/09/2010
            
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LOGTEL.
               Visualizacao log das transacoes de diversos arquivos de LOG.

   Alteracoes: 03/09/2009 - Corrigir duplicacao dos arquivos do log do F7
                            (Gabriel)
               
               22/10/2009 - Critica quando não encontra ocorrencias (Elton).

               23/04/2010 - Ajuste no F7 das telas. (Comando ls no diretorio
                            do log) (Gabriel).
               
               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop 
                            na leitura e gravacao dos arquivos (Elton).
.............................................................................*/

{ includes/var_online.i }

DEF   VAR tel_dtmvtolt AS   DATE       FORMAT "99/99/9999"             NO-UNDO.
DEF   VAR tel_nomelog  AS   CHARACTER  FORMAT "x(10)"                  NO-UNDO.
DEF   VAR tel_pesquisa AS   CHARACTER  FORMAT "x(25)"                  NO-UNDO.
DEF   VAR tel_lgvisual AS   CHARACTER  FORMAT "!(1)" INIT "T"          NO-UNDO.
DEF   VAR aux_tipodlog AS   CHARACTER                                  NO-UNDO.
DEF   VAR aux_nomedarq AS   CHARACTER  EXTENT 2                        NO-UNDO.

DEF   VAR aux_cddopcao AS   CHARACTER                                  NO-UNDO.
DEF   VAR aux_linha    AS   CHARACTER                                  NO-UNDO.

      /* variaveis para impressao */
DEF   VAR aux_contador AS   INTEGER                                    NO-UNDO.
DEF   VAR aux_nmarqimp AS   CHARACTER                                  NO-UNDO.
DEF   VAR aux_nmendter AS   CHARACTER                                  NO-UNDO.
DEF   VAR par_flgrodar AS   LOGICAL    INIT TRUE                       NO-UNDO.
DEF   VAR aux_flgescra AS   LOGICAL                                    NO-UNDO.
DEF   VAR aux_dscomand AS   CHARACTER                                  NO-UNDO.
DEF   VAR par_flgfirst AS   LOGICAL    INIT TRUE                       NO-UNDO.
DEF   VAR tel_dsimprim AS   CHARACTER  INIT "Imprimir" FORMAT "x(8)"   NO-UNDO.
DEF   VAR tel_dscancel AS   CHARACTER  INIT "Cancelar" FORMAT "x(8)"   NO-UNDO.
DEF   VAR par_flgcance AS   LOGICAL                                    NO-UNDO.

DEF   VAR aux_nmdatela AS   CHAR                                       NO-UNDO.

DEF   VAR aux_tamarqui AS   CHARACTER                                  NO-UNDO.         

DEF STREAM str_1.
DEF STREAM str_2.

DEF TEMP-TABLE tt-arqlog
    FIELD nomearq AS CHAR FORMAT "x(10)"
    INDEX idx nomearq.
    
FORM SKIP(1)
     tel_dtmvtolt COLON 10 LABEL "Data Log"   AUTO-RETURN
             HELP "Informe a data de referencia (RETURN para qualquer data)."

     tel_nomelog COLON 30 LABEL "Tela" AUTO-RETURN
                 HELP "Informe o nome da tela ou pressione <F7> para listar."
                 VALIDATE (tel_nomelog <> "","375 - O campo deve ser preenchido.")
                      
     tel_pesquisa COLON 52 LABEL "Pesquisar"
                  HELP "Informe texto a pesquisar (espaco em branco, tudo)."
     SKIP(14)
     WITH ROW 4 OVERLAY WIDTH 80 SIDE-LABELS TITLE glb_tldatela FRAME f_logspb.

/* variaveis para mostrar a consulta (F7) */          
 
DEF QUERY  arqlog-q FOR tt-arqlog.
DEF BROWSE arqlog-b QUERY arqlog-q
      DISP SPACE(5)
           nomearq                     COLUMN-LABEL "Nome do Log"
           SPACE(5)
           WITH 9 DOWN OVERLAY.    
     
DEF FRAME f_arqlog
          arqlog-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7.

ON RETURN OF arqlog-b 
   DO:
       IF   AVAILABLE tt-arqlog THEN
            DO:
                tel_nomelog = tt-arqlog.nomearq.
                CLOSE QUERY arqlog-q.               
                APPLY "END-ERROR" TO arqlog-b.
            END.
   END.


/** INICIO DO PROGRAMA ***/

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.       

INPUT STREAM str_1 THROUGH VALUE("ls -1 /usr/coop/" 
                                             + crapcop.dsdircop
                                             + "/log/*.log").

EMPTY TEMP-TABLE tt-arqlog.

REPEAT:
   IMPORT STREAM str_1 UNFORMATTED aux_linha.
   
   /* Tirar o diretorio e o .log */
   ASSIGN aux_nmdatela = SUBSTR(aux_linha,R-INDEX(aux_linha,"/") + 1)
        
          aux_nmdatela = SUBSTR(aux_nmdatela,1,INDEX(aux_nmdatela,".log") - 1).

   /* So telas do Sistema ... */
   IF   NOT CAN-FIND(FIRST craptel WHERE 
                           craptel.cdcooper = glb_cdcooper   AND
                           craptel.nmdatela = aux_nmdatela)  THEN
        NEXT.

   CREATE tt-arqlog.          /* Tirar o diretorio */
   ASSIGN tt-arqlog.nomearq = SUBSTR(aux_linha,R-INDEX(aux_linha,"/") + 1).

END.

INPUT STREAM str_1 CLOSE.


DO WHILE TRUE:

   RUN fontes/inicia.p.
    
   ASSIGN tel_dtmvtolt = ?
          tel_pesquisa = ""
          tel_nomelog = "".
   
   CLEAR FRAME f_logspb NO-PAUSE. 
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE tel_dtmvtolt WITH FRAME f_logspb.
      LEAVE.
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"    THEN
        DO:
            RUN fontes/novatela.p.
                       
            IF   CAPS(glb_nmdatela) <> "LOGTEL"    THEN
                 DO:
                     HIDE FRAME f_logspb.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      UPDATE tel_nomelog WITH FRAME f_logspb EDITING:
        
        READKEY.
        
            IF   LASTKEY = KEYCODE("F7") THEN 
                 DO:
                     OPEN QUERY arqlog-q FOR EACH tt-arqlog NO-LOCK.
   
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:   
                       
                        SET arqlog-b WITH FRAME f_arqlog.
                        LEAVE.
                 
                     END.  /*  Fim do DO WHILE TRUE  */
   
                     HIDE FRAME f_arqlog NO-PAUSE.
                
                     DISPLAY tel_nomelog WITH FRAME f_logspb.
                 END.
            ELSE
                 APPLY LASTKEY.
        
        END.  /*  Fim do EDITING  */
      
      LEAVE.
      
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        NEXT.
   
   ASSIGN aux_nmarqimp = "log/" + tel_nomelog. 
                         
   /* Adicionar o .log */
   IF  NOT aux_nmarqimp MATCHES "*.log"   THEN
       DO:
            ASSIGN aux_nmarqimp = aux_nmarqimp + ".log"
                   tel_nomelog  = tel_nomelog  + ".log".

            DISPLAY tel_nomelog WITH FRAME f_logspb.
           
       END.
       
   IF   SEARCH(aux_nmarqimp) = ?   THEN
        DO:
            MESSAGE "Nao existe o log da tela informada.".
            PAUSE 2 NO-MESSAGE.
            NEXT. 
        END.
              
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      UPDATE tel_pesquisa WITH FRAME f_logspb.
      LEAVE.
      
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        NEXT.
   
   ASSIGN aux_nomedarq[1] = "log/arquivo_tel1"
          aux_nomedarq[2] = "log/arquivo_tel2".
            
   IF   TRIM(tel_pesquisa) = ""   THEN 
        UNIX SILENT VALUE("cp " + aux_nmarqimp + " " + aux_nomedarq[1]).
   
   ELSE 
        UNIX SILENT VALUE ("grep " + tel_pesquisa + " " + aux_nmarqimp + 
                           " > "   + aux_nomedarq[1] + " 2> /dev/null").
  
   IF   tel_dtmvtolt = ? THEN 
        UNIX SILENT VALUE("cp " + aux_nomedarq[1] + " " + aux_nomedarq[2]).
   
   ELSE 
        UNIX SILENT VALUE ("grep " 
                           + string(tel_dtmvtolt,"99/99/9999") 
                           + " " + aux_nomedarq[1] 
                           + " > "   + aux_nomedarq[2] + " 2> /dev/null").
                    
   aux_nmarqimp = aux_nomedarq[2].
            
   /* Verifica se o arquivo esta vazio e critica */
   INPUT STREAM str_2 THROUGH VALUE( "wc -m " + aux_nmarqimp + " 2> /dev/null") 
                                    NO-ECHO.

   SET STREAM str_2 aux_tamarqui FORMAT "x(30)".

   IF   INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0   THEN
        DO:
             BELL. 
             MESSAGE "Nenhuma ocorrencia encontrada.".
             INPUT STREAM str_2 CLOSE.
             NEXT.
        END.

   INPUT STREAM str_2 CLOSE.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_lgvisual. 
      LEAVE.
   
   END.
      
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        NEXT.
   
   IF   tel_lgvisual = "T"   THEN DO:
        RUN fontes/visrel.p (INPUT aux_nmarqimp).
   END.     
   ELSE
   IF   tel_lgvisual = "I"   THEN     
        DO:
            FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                                     NO-LOCK NO-ERROR.
            ASSIGN glb_nrdevias = 1
                   glb_nmformul = "".      
                                
            { includes/impressao.i }   
        END.
   ELSE 
        DO:
            MESSAGE "Opcao incorreta !!".
            PAUSE 2 NO-MESSAGE.
            NEXT.
        END.    
        
        /* apaga arquivos temporarios */
   IF   aux_nomedarq[2] <> ""   THEN
        DO:
            UNIX SILENT VALUE ("rm " + aux_nomedarq[1] + " 2> /dev/null").
            UNIX SILENT VALUE ("rm " + aux_nomedarq[2] + " 2> /dev/null").
        END.                                       
   
END. /* Fim do DO WHILE TRUE */   

/*...........................................................................*/
