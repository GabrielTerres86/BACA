/* ............................................................................

   Programa: Fontes/domins.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Junho/2009                         Ultima atualizacao: 05/08/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela DOMINS - Alteracao de Domincilio Bancario.

   
   Alteracoes: 01/07/2009 - Incluido campo "Seq. Ttl." e alterada a procedure 
                            gera_log para logar Titularidade, PA e Orgao 
                            pagador (Fernando).
                            
               27/11/2009 - Alterado para enviar no arquivo, espacos em brancos 
                            (" ") no lugar do nome do beneficiario;
                          - Retirado "Nome do Beneficiario" do log para nao
                            ocorrer problemas nele e na tela quando haver um 
                            apostrofo ( ' ) no nome (Elton).
                            
               17/09/2010 - Incluido o nome do operador no termo (Vitor)
               
               13/05/2011 - Adaptacao para BO. (André - DB1)
               
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
               
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
   
............................................................................ */
                           
{ includes/var_online.i }   
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0091tt.i }

DEF STREAM str_1.

DEF NEW SHARED VAR shr_nrdconta  LIKE crapttl.nrdconta              NO-UNDO.
DEF NEW SHARED VAR shr_idseqttl  LIKE crapttl.idseqttl              NO-UNDO.

DEF VAR tel_nrdconta  LIKE crapass.nrdconta                         NO-UNDO.
DEF VAR tel_cdagenci  LIKE crapcbi.cdagenci                         NO-UNDO.
DEF VAR tel_nmresage  LIKE crapage.nmresage                         NO-UNDO.
DEF VAR tel_nmrecben  LIKE crapcbi.nmrecben                         NO-UNDO.
DEF VAR tel_nrrecben  LIKE crapcbi.nrrecben                         NO-UNDO.
DEF VAR tel_nrbenefi  LIKE crapcbi.nrbenefi                         NO-UNDO.
DEF VAR tel_cdorgpag  LIKE crapage.cdorgpag                         NO-UNDO.
DEF VAR tel_nrctacre  LIKE crapass.nrdconta                         NO-UNDO.
DEF VAR tel_idseqttl  LIKE crapttl.idseqttl                         NO-UNDO.

DEF VAR aux_cddopcao  AS CHAR                                       NO-UNDO.
        
/** VARIAVEIS PARA IMPRESSAO **/
DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                        NO-UNDO.
DEF VAR par_flgrodar AS LOGI    INIT TRUE                           NO-UNDO.
DEF VAR par_flgfirst AS LOGI    INIT TRUE                           NO-UNDO.
DEF VAR par_flgcance AS LOGI                                        NO-UNDO.
DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"       NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"       NO-UNDO.
DEF VAR aux_nmendter AS CHAR    FORMAT "x(20)"                      NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                        NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                        NO-UNDO.
DEF VAR par_nmarqimp AS CHAR                                        NO-UNDO.
DEF VAR par_nmarqpdf AS CHAR                                        NO-UNDO.
DEF VAR par_nmdcampo AS CHAR                                        NO-UNDO.

DEF VAR h-b1wgen0091 AS HANDLE                                      NO-UNDO.
          
FORM  tel_nrdconta  LABEL "Conta/dv"                        AT 3
         HELP  "Informe o numero da conta do cooperado."
         VALIDATE(CAN-FIND(crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                         crapass.nrdconta = INPUT tel_nrdconta),
                                         "009 - Associado nao cadastrado.")
      tel_idseqttl  LABEL "Seq. Ttl."                       AT 30
         HELP "Informe a sequencia ou  F7 para listar."        
         VALIDATE(CAN-FIND(crapttl WHERE crapttl.cdcooper = glb_cdcooper 
                                     AND crapttl.nrdconta = INPUT tel_nrdconta
                                     AND crapttl.idseqttl = INPUT tel_idseqttl),
                                     "110 - Situacao do titular errada.")  
      tel_cdagenci  LABEL "PA"                             AT 50  
      "-"
      tel_nmresage  NO-LABEL                                           SKIP(2)
      tel_nmrecben  LABEL "Nome do beneficiario"            AT 2
         HELP  "Informe o nome do beneficiario."                       SKIP(1)
      tel_nrbenefi  LABEL "NB"                              AT 20
         HELP  "Informe o numero do beneficio."                        SKIP(1)
      tel_nrrecben  LABEL "NIT"                             AT 19
         HELP  "Informe o numero de identificacao do trabalhador."     SKIP(1)
      tel_cdorgpag  LABEL "Orgao pagador"                   AT 9
         HELP  "Informe o orgao pagador."                              SKIP(1)
      tel_nrctacre  LABEL "Conta/dv para credito"
         HELP  "Informe a c/c ou pressione 'Enter' para manter a mesma." 
      WITH SIDE-LABELS NO-BOX ROW 6 COLUMN 2 OVERLAY FRAME f_dados.

FORM  WITH ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela 
      FRAME f_moldura.

ASSIGN glb_cddopcao = "A". 

RUN fontes/inicia.p.

VIEW FRAME f_moldura.

PAUSE 0.
                        
IF  NOT VALID-HANDLE(h-b1wgen0091)  THEN
    RUN sistema/generico/procedures/b1wgen0091.p 
        PERSISTENT SET h-b1wgen0091.

INICIO: DO WHILE TRUE ON ENDKEY UNDO, LEAVE :
       
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE   tel_nrdconta tel_idseqttl WITH FRAME f_dados
        
        EDITING:
        
            READKEY.
                 
            IF  LASTKEY = KEYCODE("F7") THEN
                DO:
                    IF  FRAME-FIELD = "tel_idseqttl"   THEN
                        DO:

                            IF  INPUT FRAME f_dados tel_nrdconta = 0   THEN
                                DO:
                                    glb_cdcritic = 127.
                                    RUN fontes/critic.p.
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    glb_cdcritic = 0.
                                    NEXT.
                                END.

                            ASSIGN shr_nrdconta = INPUT FRAME f_dados
                                                        tel_nrdconta
                                   shr_idseqttl = INPUT FRAME f_dados
                                                        tel_idseqttl.
                          
                            RUN fontes/zoom_seq_titulares.p (glb_cdcooper).
                          
                            IF  shr_idseqttl <> 0 THEN
                                DO:
                                    ASSIGN tel_idseqttl = shr_idseqttl.
                                    DISPLAY tel_idseqttl WITH FRAME f_dados.
                                    NEXT-PROMPT tel_idseqttl
                                                WITH FRAME f_dados.
                                END.
                        END.
                              
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                        NEXT.
                END.

            APPLY LASTKEY.
        
        END. /* Fim do EDITING */
        
        LEAVE.
    END. /* Fim do DO WHILE TRUE */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:                
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "DOMINS"   THEN
                DO:  
                   HIDE FRAME f_dados.
                   LEAVE.             
                END.
            ELSE
                NEXT.
        END.         
    
    IF  aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }      
            ASSIGN aux_cddopcao = glb_cddopcao.
        END.          
    
    RUN busca-domins.

    IF  RETURN-VALUE <> "OK" THEN
        NEXT INICIO.

    RUN atualiza-tela.

    IF  RETURN-VALUE <> "OK" THEN
        NEXT INICIO.
    
    DISPLAY tel_cdagenci  tel_nmresage
            tel_nmrecben  tel_cdorgpag 
            tel_nrctacre  WITH FRAME f_dados.

    UPDATE  tel_nrbenefi tel_nrrecben  WITH FRAME f_dados

    EDITING:
        READKEY.
        APPLY LASTKEY.

        IF  GO-PENDING  THEN
            DO: 
                ASSIGN INPUT tel_nrbenefi
                       INPUT tel_nrrecben.

                /* Atualizacao de dados cadastrais */
                RUN valida-nbnit IN h-b1wgen0091 
                    ( INPUT glb_cdcooper,    
                      INPUT 0,               
                      INPUT 0,               
                      INPUT glb_cdoperad,    
                      INPUT glb_nmdatela,    
                      INPUT 1,               
                      INPUT tel_nrdconta,    
                      INPUT 0,               
                      INPUT YES,             
                      INPUT 30,
                      INPUT tel_nrbenefi,
                      INPUT tel_nrrecben,
                     OUTPUT par_nmdcampo,
                     OUTPUT TABLE tt-erro ).
            
                IF  RETURN-VALUE <> "OK" THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        
                        IF  AVAILABLE tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                                {sistema/generico/includes/foco_campo.i
                                            &VAR-GERAL="sim"
                                            &NOME-FRAME="f_dados"
                                            &NOME-CAMPO=par_nmdcampo }
                            END.
                    END.
            END.

    END.

    FIND FIRST tt-domins NO-LOCK NO-ERROR.

    IF  NOT AVAIL tt-domins THEN
        DO:
            MESSAGE "Dados para geracao de impressao não encontrados.".
            NEXT INICIO.
        END.

    INPUT THROUGH basename `tty` NO-ECHO.
    
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter. 

    RUN gera-impressao IN h-b1wgen0091
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT tel_nrdconta,
          INPUT tel_idseqttl,
          INPUT TRUE,
          INPUT tt-domins.cdagebcb,
          INPUT glb_dtmvtolt,
          INPUT tel_nrbenefi,
          INPUT tel_nrctacre,
          INPUT tel_cdorgpag,
          INPUT tel_nrrecben,
          INPUT tel_nmrecben,
          INPUT tt-domins.dsdircop,
          INPUT tt-domins.nmextttl,
          INPUT tt-domins.nmoperad,
          INPUT tt-domins.nmcidade,
          INPUT tt-domins.nmextcop,
          INPUT tt-domins.nmrescop,
          INPUT aux_nmendter,
         OUTPUT par_nmarqimp,
         OUTPUT par_nmarqpdf,
         OUTPUT TABLE tt-erro ).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                DO:
                    MESSAGE tt-erro.dscritic.
                    NEXT.
                END.
        END.

    ASSIGN glb_nmformul = ""
           glb_nrdevias = 1
           aux_nmarqimp = par_nmarqimp.

    FIND FIRST crapass WHERE 
               crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

    { includes/impressao.i }    
                         
    UNIX SILENT VALUE("rm " + aux_nmarqimp + "* 2> /dev/null").
     
    LEAVE.
END.

IF  VALID-HANDLE(h-b1wgen0091)  THEN
    DELETE PROCEDURE h-b1wgen0091.


/* ******************************PROCEDURES********************************* */

PROCEDURE busca-domins:

    RUN busca-domins IN h-b1wgen0091
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
         OUTPUT TABLE tt-erro,
         OUTPUT TABLE tt-domins ) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.
          
            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
          
            RETURN "NOK".
        END.

    RETURN "OK".
END PROCEDURE.


PROCEDURE atualiza-tela:

    FIND FIRST tt-domins NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-domins THEN 
        DO:
            ASSIGN tel_cdagenci = tt-domins.cdagenci
                   tel_nmresage = tt-domins.nmresage
                   tel_nmrecben = tt-domins.nmrecben
                   tel_cdorgpag = tt-domins.cdorgpag
                   tel_nrctacre = tt-domins.nrdconta.
            
        END.
    ELSE
        ASSIGN tel_cdagenci = 0
               tel_nmresage = ""
               tel_nmrecben = ""
               tel_cdorgpag = 0
               tel_nrctacre = 0.

    RETURN "OK".
END PROCEDURE .
                    
