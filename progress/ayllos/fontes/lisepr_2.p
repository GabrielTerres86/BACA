/* ..........................................................................

   Programa: Fontes/lisepr_2.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Junho/2007                      Ultima atualizacao: 20/06/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a opcao 'I' da tela LISEPR.

   
   Alteracoes: 13/03/2008 - Alterado para mostrar o valor total de emprestimos
                            liberados, e saldo devedor no relatorio (Gabriel).
                            
               06/05/2008 - Alterado formato do campo "CONTA" e o formato dos
                            campos "VALOR EMP" e "SALDO DEV" para mostrar casas
                            decimais (Elton).

               06/05/2009 - Incluir campos "Data da proposta" e "Saldo Medio"
                            (Fernando).
                            
               02/03/2010  - Alteracao feita para tratar cheques e titulos
                             (GATI - Daniel).
                             
               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop na
                            leitura e gravacao dos arquivos (Elton).
                            
               15/04/2013 - Incluido totalizador  de lancamentos (Daniele).  
               
               20/06/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Lucas R./Gielow).
............................................................................. */

{ includes/var_online.i }
                                
 DEF TEMP-TABLE tt-emprestimo NO-UNDO
    FIELD cdagenci AS INT      FORMAT "zz9"  
    FIELD nrdconta AS INT      FORMAT "zzzz,zzz,9"
    FIELD nmprimtl AS CHAR     FORMAT "x(36)"
    FIELD nrctremp AS INT      FORMAT "zzz,zzz,zz9"
    FIELD dtmvtolt AS DATE     FORMAT "99/99/9999"
    FIELD vlemprst AS DECIMAL  FORMAT "zzz,zzz,zz9.99"
    FIELD vlsdeved AS DECIMAL  FORMAT "zzz,zzz,zz9.99-"
    FIELD cdlcremp AS INT      FORMAT "zzz9"
    FIELD diaprmed AS INT      FORMAT "zz9"
    FIELD dtmvtprp AS DATE     FORMAT "99/99/9999"
    FIELD dsorigem AS CHAR.                             
DEF STREAM str_1.                                        

DEF VAR aux_confirma AS CHAR    FORMAT "!(1)"                        NO-UNDO.
DEF VAR aux_flgexist AS LOGICAL                                      NO-UNDO.

DEF VAR par_flgcance AS LOGICAL                                      NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL INIT TRUE                            NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                            NO-UNDO.

DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"        NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"        NO-UNDO. 
DEF VAR tel_nmarquiv AS CHAR    FORMAT "x(25)"                       NO-UNDO.
DEF VAR tel_nmdireto AS CHAR    FORMAT "x(20)"                       NO-UNDO.
DEF VAR tel_nmdopcao AS LOG     FORMAT "ARQUIVO/IMPRESSAO" INIT TRUE NO-UNDO.

/* variaveis para valores totais */
DEF VAR tel_vlemprst AS DEC     FORMAT "zz,zzz,zzz,zz9.99"           NO-UNDO.
DEF VAR tel_vlsdeved AS DEC     FORMAT "zzz,zzz,zz9.99-"             NO-UNDO. 

DEF VAR aux_flgescra AS LOGICAL                                      NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                         NO-UNDO.

DEF VAR aux_contador AS INT                                        NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR                                         NO-UNDO.
DEF VAR aux_nmendter AS CHAR    FORMAT "x(20)"                       NO-UNDO. 
DEF VAR contador     AS INT                                          NO-UNDO.

DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                       NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5              NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                           NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5       
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.
    
DEF INPUT PARAM TABLE FOR tt-emprestimo.
DEF INPUT PARAM tel_dtinicio AS DATE FORMAT "99/99/9999"             NO-UNDO.
DEF INPUT PARAM tel_dttermin AS DATE FORMAT "99/99/9999"             NO-UNDO.
     
FORM tt-emprestimo.cdagenci LABEL "PA"
     tt-emprestimo.nrdconta LABEL "CONTA"
     tt-emprestimo.nmprimtl LABEL "NOME"    
     tt-emprestimo.nrctremp LABEL "CONTRATO"
     tt-emprestimo.dtmvtprp LABEL "DATA PROP"
     tt-emprestimo.dtmvtolt LABEL "DATA EMP"
     tt-emprestimo.diaprmed LABEL "PRAZO MED"
     tt-emprestimo.vlemprst LABEL "VALOR EMP"
     tt-emprestimo.vlsdeved LABEL "SALDO DEV"
     tt-emprestimo.cdlcremp LABEL "LINHA"
     WITH NO-BOX NO-LABEL DOWN FRAME f_rel_historico WIDTH 132.

FORM 
    "Data Inicial:"     AT 5
     tel_dtinicio       HELP "Informe a data inicial da consulta." 
     SPACE(3)
    "Data Final:"  
     tel_dttermin       HELP "Informe a data final da consulta."
    "Saida:"           
     tel_nmdopcao       HELP "(A)rquivo ou (I)mpressao."
     WITH FRAME f_dados OVERLAY ROW 8 NO-LABEL NO-BOX COLUMN 2.

FORM
    "Diretorio:   "     AT 5
     tel_nmdireto
     tel_nmarquiv        HELP "Informe o nome do arquivo."
     WITH OVERLAY ROW 10 NO-LABEL NO-BOX COLUMN 2 FRAME f_diretorio.
        
FORM
    "De:"   tel_dtinicio    SPACE(3)
    "Ate:"  tel_dttermin    SPACE(3) 
    SKIP(1) WITH FRAME f_dados2 NO-LABEL NO-BOX WIDTH 132.
    
FORM SKIP(1)    
     "Qtde.Registros:" 
     aux_contador      
     "Total:"      AT 81         
     tel_vlemprst  AT 94     
     tel_vlsdeved  AT 112   
     WITH FRAME f_dados3 NO-LABEL NO-BOX WIDTH 132.
    
    HIDE MESSAGE NO-PAUSE.
    
    DISPLAY tel_dtinicio 
            tel_dttermin
            WITH FRAME f_dados.
            
    UPDATE tel_nmdopcao 
           WITH FRAME f_dados.
    
    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR. 
    
    IF  tel_nmdopcao  THEN
        DO:
            ASSIGN tel_nmdireto = "/micros/" + crapcop.dsdircop + "/".
            DISP   tel_nmdireto WITH FRAME f_diretorio.
            UPDATE tel_nmarquiv WITH FRAME f_diretorio.
            ASSIGN aux_nmarqimp = tel_nmdireto + tel_nmarquiv.
        END.
    ELSE
        ASSIGN aux_nmarqimp = "rl/lisepr.lst".   

    /* Inicializa Variaveis Relatorio */
       ASSIGN glb_cdcritic    = 0
              glb_cdrelato[1] = 451.        
             
    { includes/cabrel132_1.i }
   
    OUTPUT  STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
   
    VIEW    STREAM str_1 FRAME f_cabrel132_1.
                               
    DISPLAY STREAM str_1 tel_dtinicio   
                         tel_dttermin   
                         WITH FRAME f_dados2.
   
    ASSIGN aux_flgexist = FALSE 
           tel_vlemprst = 0
           tel_vlsdeved = 0.
    
    FOR EACH tt-emprestimo:
        DISP STREAM str_1
             tt-emprestimo.cdagenci  
             tt-emprestimo.nrdconta  
             tt-emprestimo.nmprimtl  
             tt-emprestimo.nrctremp 
             tt-emprestimo.dtmvtprp
             tt-emprestimo.dtmvtolt
             tt-emprestimo.diaprmed
             tt-emprestimo.vlemprst
             tt-emprestimo.vlsdeved 
             tt-emprestimo.cdlcremp
             WITH FRAME f_rel_historico.
       
        DOWN STREAM str_1 WITH FRAME f_rel_historico.

        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
             DO:
                PAGE STREAM str_1.
                VIEW STREAM str_1 FRAME f_cabrel132_1.
             END.   
                        
        ASSIGN aux_flgexist = TRUE    /* vlr emprestimo total e saldo dev */
               tel_vlemprst = tel_vlemprst + tt-emprestimo.vlemprst
               tel_vlsdeved = tel_vlsdeved + tt-emprestimo.vlsdeved
               aux_contador = aux_contador + 1. 
    END.

    DISP STREAM str_1 aux_contador
                      tel_vlemprst 
                      tel_vlsdeved WITH FRAME f_dados3.
    
    OUTPUT STREAM str_1 CLOSE.     

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
                        ASSIGN  glb_nmformul = "132col"
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
