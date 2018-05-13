/* ..........................................................................

   Programa: Fontes/lislot_2.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Agosto/2006                      Ultima atualizacao: 02/06/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LISLOT.

   
   Alteracoes: 05/09/2006 - Tratamento para efetuar impressao ou gerar o
                            arquivo no diretorio /micros/coop/ (David).

               04/10/2006 - Substituido crapcop.cdcooper por glb_cdcooper
                            (Elton).
                            
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS.   
                          - Kbase IT Solutions - Eduardo Silva.   
                                      
               25/08/2008 - Alterado format campo documento para nao estourar
                            (Gabriel).

               05/05/2009 - Criado filtro para o campo Conta (Fernando).
               
               09/02/2010 - Incluidos na tela, campos Total de registros
                            e Total dos valores (GATI - Daniel).
                            
               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop na
                            leitura e gravacao dos arquivos (Elton).
                            
               27/07/2011 - Atribuido para tel_dtinicio o primeiro dia do mes
                            corrente, e, para tel_dttermin, a data em 
                            glb_dtmvtolt. Gerado log da operacao. (Fabricio)
                   
               24/07/2013 - Performance, alteracao na ordem das clausulas. 
                            (Passig - AMCOM)
               
               28/03/2014 - Adaptado para a B1wgen0184.p - Jéssica Laverde (DB1)   
               
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).   
                                   
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0184tt.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0184 AS HANDLE                                 NO-UNDO. 

DEF STREAM str_1.  

DEF   VAR tot_vllanmto   AS DEC                                      NO-UNDO.
DEF   VAR tot_registro   AS INT                                      NO-UNDO.
      
DEF   VAR tel_dtinicio   AS   DATE FORMAT "99/99/9999"               NO-UNDO.
DEF   VAR tel_dttermin   AS   DATE FORMAT "99/99/9999"               NO-UNDO.
DEF   VAR aux_dsexthst   LIKE craphis.dsexthst                       NO-UNDO.

DEF   VAR aux_confirma   AS CHAR FORMAT "!(1)"                       NO-UNDO.
DEF   VAR aux_flgexist   AS LOGICAL                                  NO-UNDO.

DEF   VAR par_flgcance   AS LOGICAL                                  NO-UNDO.
DEF   VAR par_flgrodar   AS LOGICAL    INIT TRUE                     NO-UNDO.
DEF   VAR par_flgfirst   AS LOGICAL    INIT TRUE                     NO-UNDO.

DEF   VAR tel_dsimprim   AS CHAR  FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF   VAR tel_dscancel   AS CHAR  FORMAT "x(8)" INIT "Cancelar"      NO-UNDO. 
DEF   VAR tel_nmarquiv   AS CHAR  FORMAT "x(25)"                     NO-UNDO.
DEF   VAR tel_nmdireto   AS CHAR  FORMAT "x(20)"                     NO-UNDO.

DEF   VAR tel_nmdopcao   AS LOG FORMAT "ARQUIVO/IMPRESSAO" INIT TRUE NO-UNDO.

DEF   VAR aux_flgescra   AS LOGICAL                                  NO-UNDO.
DEF   VAR aux_dscomand   AS CHAR                                     NO-UNDO.
DEF   VAR aux_contador   AS INT                                      NO-UNDO.
DEF   VAR aux_dslog      AS CHAR                                     NO-UNDO.

DEF   VAR aux_nmarqimp   AS CHAR                                     NO-UNDO.
DEF   VAR aux_nmendter   AS CHAR FORMAT "x(20)"                      NO-UNDO.   

DEF   VAR rel_nmempres   AS CHAR  FORMAT "x(15)"                     NO-UNDO.
DEF   VAR rel_nmrelato   AS CHAR  FORMAT "x(40)" EXTENT 5            NO-UNDO.
DEF   VAR rel_nrmodulo   AS INT   FORMAT "9"                         NO-UNDO.
DEF   VAR rel_nmmodulo   AS CHAR  FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.
DEF   VAR aux_qtdmeses   AS DEC                                      NO-UNDO. 


DEF  VAR tel_tpdopcao AS CHAR FORMAT "x(9)" 
     VIEW-AS COMBO-BOX INNER-LINES 3 
     LIST-ITEMS "COOPERADO", "CAIXA" , "LOTE P/PA"
     INIT "COOPERADO"                                                NO-UNDO.


DEF INPUT PARAM par_cdagenci AS INTE FORMAT "zz9"                NO-UNDO.
DEF INPUT PARAM par_cdhistor AS INTE FORMAT "zzz9"               NO-UNDO.
DEF INPUT PARAM par_nrdconta AS INTE FORMAT "zzzz,zzz,9"         NO-UNDO.
DEF INPUT PARAM par_cddopcao AS CHAR                             NO-UNDO.

DEF VAR aux_nmarqpdf         AS CHAR                             NO-UNDO.

FORM                                                                    
     "Data Inicial:"     AT 5                                            
      tel_dtinicio       HELP "Informe a data inicial da consulta."      
      SPACE(3)                                                           
      "Data Final:"                                                      
      tel_dttermin       HELP "Informe a data final da consulta."        
      SPACE(3)                                                           
      "Saida:"                                                           
      tel_nmdopcao       HELP "(A)rquivo ou (I)mpressao."                
      WITH FRAME f_dados overlay ROW 8 NO-LABEL NO-BOX COLUMN 2.         
                                                                         
FORM                                                                     
    "Diretorio:   "     AT 5                                             
    tel_nmdireto                                                         
    tel_nmarquiv        HELP "Informe o nome do arquivo."                
    WITH OVERLAY ROW 10 NO-LABEL NO-BOX COLUMN 2 FRAME f_diretorio.      
                                                                         
ASSIGN tel_dtinicio = DATE(MONTH(glb_dtmvtolt), 01, YEAR(glb_dtmvtolt))
       tel_dttermin = glb_dtmvtolt.

UPDATE tel_dtinicio tel_dttermin tel_nmdopcao WITH FRAME f_dados.

INPUT THROUGH basename `tty` NO-ECHO.
SET aux_nmendter WITH FRAME f_terminal.
INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

IF  tel_nmdopcao  THEN
    DO:
        ASSIGN tel_nmdireto = UPPER("/micros/") + glb_nmrescop + "/".

        DISP tel_nmdireto WITH FRAME f_diretorio.    
                                                     
        UPDATE tel_nmarquiv WITH FRAME f_diretorio.

        ASSIGN aux_nmendter = tel_nmarquiv.
    END.

RUN Gera_Impressao.

IF RETURN-VALUE <> "OK" THEN
    NEXT.

HIDE FRAME f_diretorio.
HIDE FRAME f_dados.

PROCEDURE confirma:

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


/* -------------------------------------------------------------------------- */
/*                      EFETUA A IMPRESSãO DOS HISTORICOS                     */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_Impressao:

    EMPTY TEMP-TABLE tt-erro.
    
    RUN conecta_handle.

    RUN Gera_Impressao IN h-b1wgen0184                           
                    (   INPUT glb_cdcooper,                  
                        INPUT par_cdagenci,
                        INPUT 0,                             
                        INPUT glb_cdoperad,                  
                        INPUT glb_nmdatela,                                                         
                        INPUT 1, /*idorigem*/             
                        INPUT glb_dsdepart,
                        INPUT glb_dtmvtolt,               
                        INPUT glb_cddopcao,               
                        INPUT tel_tpdopcao,               
                        INPUT par_nrdconta,               
                        INPUT tel_dtinicio,               
                        INPUT tel_dttermin,               
                        INPUT TRUE,                       
                        INPUT aux_nmendter,               
                        INPUT tel_nmdopcao,               
                        INPUT par_cdhistor,                                                         
                       OUTPUT aux_nmarqimp,                  
                       OUTPUT aux_nmarqpdf,
                       OUTPUT tel_nmdireto,
                       OUTPUT TABLE tt-erro) NO-ERROR.           
                                                                 
    RUN desconecta_handle.   

    HIDE FRAME f_diretorio.
    HIDE FRAME f_dados_1.

    CLEAR FRAME f_diretorio.
    CLEAR FRAME f_dados_1.
                                                                 
    IF  ERROR-STATUS:ERROR THEN                                  
        DO:                                                      
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".
        END.

    IF  tel_nmdopcao  THEN DO:
        BELL.
        MESSAGE "Arquivo gerado com sucesso no diretorio: " + tel_nmdireto.
        PAUSE 3 NO-MESSAGE.
    END.
    ELSE DO:
        RUN confirma.
                     
        IF  aux_confirma = "S"  THEN 
            DO:
        
                FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
                                                                                      
                { includes/impressao.i }                                                  
    
            END.
    
    END.
    
    HIDE MESSAGE NO-PAUSE.

    RETURN "OK".

END PROCEDURE. /* Gera_Impressao*/

PROCEDURE conecta_handle:

    IF  NOT VALID-HANDLE(h-b1wgen0184) THEN
            RUN sistema/generico/procedures/b1wgen0184.p
                PERSISTENT SET h-b1wgen0184.
END PROCEDURE.

PROCEDURE desconecta_handle:

    IF  VALID-HANDLE(h-b1wgen0184) THEN
            DELETE OBJECT h-b1wgen0184.
END PROCEDURE.
