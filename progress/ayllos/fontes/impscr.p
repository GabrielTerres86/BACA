/* ............................................................................

   Programa: fontes/impscr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Lunelli
   Data    : Setembro/2012                    Ultima alteracao: 19/09/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gerar as informações da SCR - BACEN em arquivo
   
   Alteracoes: 27/09/2012 - Inclusao da funcao ux2dos na geracao do arquivo.
                            (Lucas R.)
              
               14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               19/09/2014 - Ajustes em performance, adicionado data em FIND
                            LAST crapris para pegar o indice. 
                            (Jorge/Rosangela - SD 157831)
............................................................................ */

{ sistema/generico/includes/var_internet.i } 
{ includes/var_online.i }

DEF STREAM str_1.

DEF   VAR tel_dtdebase AS DATE   FORMAT "99/99/9999"            NO-UNDO.
DEF   VAR tel_dtbasmes AS INTE                                  NO-UNDO.
DEF   VAR tel_dtbasano AS INTE                                  NO-UNDO.
DEF   VAR aux_confirma AS CHAR   FORMAT "!"                     NO-UNDO.
DEF   VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF   VAR tel_nmdireto AS CHAR FORMAT "x(20)"                   NO-UNDO.
DEF   VAR aux_extensao AS CHAR                                  NO-UNDO.
DEF   VAR tel_nmarquiv AS CHAR FORMAT "x(25)"                   NO-UNDO. 
DEF   VAR aux_nmarquivo AS CHAR                                  NO-UNDO.
DEF   VAR aux_nmarqdst AS CHAR                                  NO-UNDO.
/* Para o relatório */
DEF   VAR aux_dtrefere LIKE crapopf.dtrefere                    NO-UNDO.
DEF   VAR aux_dtrefris LIKE crapris.dtrefere                    NO-UNDO.
DEF   VAR aux_vlopesfn LIKE crapvop.vlvencto                    NO-UNDO.
DEF   VAR aux_dtrefbac AS CHAR FORMAT "x(08)"                   NO-UNDO.
DEF   VAR aux_vlopbase LIKE crapris.vldivida                    NO-UNDO.
DEF   VAR aux_vlopcoop LIKE crapris.vldivida                    NO-UNDO.
DEF   VAR aux_vlopevnc LIKE crapvop.vlvencto                    NO-UNDO.
DEF   VAR aux_vlopeprj LIKE crapvop.vlvencto                    NO-UNDO.
DEF   VAR aux_vlvencer LIKE crapvop.vlvencto                    NO-UNDO.
DEF   VAR aux_vllimite LIKE crapvop.vlvencto                    NO-UNDO.
DEF   VAR aux_mensagem AS CHAR FORMAT "x(60)"                   NO-UNDO.
DEF   VAR aux_contador AS INT                                   NO-UNDO.
DEF   VAR aux_iniconta AS INT                                   NO-UNDO.
DEF   VAR aux_relatori AS LOG                                   NO-UNDO.
DEF   VAR aux_contregi AS INT INIT 0                            NO-UNDO. 
DEF   VAR aux_contarqv AS INT INIT 0                            NO-UNDO.
DEF   VAR aux_flgprime AS LOG INIT YES                          NO-UNDO. 
DEF   VAR aux_msgauxil AS CHAR                                  NO-UNDO.

DEF TEMP-TABLE tt-conscr NO-UNDO 
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc 
    FIELD vlopesfn LIKE crapvop.vlvencto
    FIELD dtrefbac AS CHAR FORMAT "x(08)"
    FIELD vlopbase LIKE crapris.vldivida
    FIELD dtrefere LIKE crapopf.dtrefere 
    FIELD vlopcoop LIKE crapris.vldivida  
    FIELD vlopevnc LIKE crapvop.vlvencto  
    FIELD vlopeprj LIKE crapvop.vlvencto  
    FIELD vlvencer LIKE crapvop.vlvencto  
    FIELD vllimite LIKE crapvop.vlvencto  
    FIELD mensagem AS CHAR FORMAT "x(60)"
    FIELD nmtitula AS CHAR FORMAT "x(40)"
    INDEX id-tt-conscr IS PRIMARY 
          cdagenci 
          nrdconta 
          nrcpfcgc.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 3 LABEL "Opcao" AUTO-RETURN
                       HELP "Opção A: Arquivo."
                       VALIDATE(CAN-DO("A",glb_cddopcao),
                                "014 - Opcao errada.")
    "Data Base:"  AT 14
     tel_dtbasmes NO-LABEL FORMAT "z9"
        HELP "Insira um mes base para consulta."
        VALIDATE(tel_dtbasmes <= 12 AND tel_dtbasmes <> 0, "O mes inserido e invalido.")
      "/"
     tel_dtbasano NO-LABEL FORMAT "zzz9"
        HELP "Insira um ano base para consulta."
        VALIDATE(LENGTH(STRING(tel_dtbasano), "CHARACTER") >=4, "O ANO inserido e invalido.")
     WITH ROW 6 COLUMN 2 SIDE-LABEL OVERLAY NO-BOX FRAME f_impscr.
                   
FORM "Deseja gerar o arquivo? " AT 5
     aux_confirma AT 29 NO-LABEL
     HELP "Digite 'S' para SIM e 'N' para NAO."
     WITH ROW 11 COLUMN 24 OVERLAY WIDTH 35 SIDE-LABELS FRAME f_confirma.

FORM "Diretorio:"        AT 14
     tel_nmdireto        AT 25
     SKIP(1)      
     "Arquivo:"          AT 16
     tel_nmarquiv        AT 25 FORMAT "X(25)"
                         HELP "Informe o nome do arquivo (nome a criterio da cooperativa)."
                         VALIDATE(tel_nmarquiv <> " ",
                                 "Insira um nome para o arquivo.")
     aux_extensao
     WITH FRAME f_diretorio OVERLAY ROW 8 NO-LABEL NO-BOX COLUMN 2.
     
VIEW FRAME f_moldura.
PAUSE(0).

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop   THEN
    DO:
        glb_cdcritic = 651.
        RUN fontes/critic.p.
        MESSAGE glb_dscritic.
        RETURN.
    END.

ASSIGN glb_cddopcao = "A"
       glb_cdcritic = 0
       tel_dtbasmes = MONTH(glb_dtmvtolt)
       tel_dtbasano = YEAR(glb_dtmvtolt)
       tel_nmdireto = "/micros/" + crapcop.dsdircop + "/"
       aux_extensao = ".txt".

RUN fontes/inicia.p.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    IF  glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.
    LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

VIEW FRAME f_diretorio.
DISPLAY tel_nmdireto aux_extensao WITH FRAME f_diretorio.

DISPLAY glb_cddopcao  WITH FRAME f_impscr.
  
IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
    DO:
        RUN fontes/novatela.p.

        IF  CAPS(glb_nmdatela) <> "IMPSCR"  THEN
            DO:
                HIDE FRAME f_moldura.
                RETURN.
            END.
        ELSE
            NEXT.
    END.

IF  aux_cddopcao <> glb_cddopcao THEN
    DO:
        { includes/acesso.i }
        aux_cddopcao = glb_cddopcao.
    END.

lab:
DO WHILE TRUE ON ENDKEY UNDO, RETURN:

    NEXT-PROMPT tel_dtbasmes WITH FRAME f_impscr.

    UPDATE glb_cddopcao
           tel_dtbasmes
           tel_dtbasano WITH FRAME f_impscr.

    /* Monta data base */
    ASSIGN tel_dtdebase = DATE("25/" + STRING(tel_dtbasmes) + "/" + STRING(tel_dtbasano))
           tel_dtdebase = tel_dtdebase + 15
           tel_dtdebase = tel_dtdebase - DAY(tel_dtdebase). 

    FIND FIRST crapopf NO-LOCK 
          WHERE crapopf.dtrefere = tel_dtdebase NO-ERROR.

    IF  NOT AVAIL crapopf THEN
        DO:
            ASSIGN  glb_dscritic = "Nenhum registro referente a essa data base.".
            MESSAGE glb_dscritic.
            NEXT.
        END.

    DISPLAY tel_nmdireto aux_extensao WITH FRAME f_diretorio.

    DO WHILE TRUE ON ENDKEY UNDO, NEXT lab:

        UPDATE tel_nmarquiv WITH FRAME f_diretorio.

        ASSIGN aux_confirma = "N".
        UPDATE aux_confirma WITH FRAME f_confirma.
            
        IF  aux_confirma <> "S" THEN
            DO: 
                HIDE FRAME f_confirma.
                CLEAR FRAME f_diretorio.
                DISPLAY tel_nmdireto aux_extensao WITH FRAME f_diretorio.
                NEXT lab.
            END.
        LEAVE.
    END.

    LEAVE.
END.

FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF NOT AVAIL crapdat THEN
DO:
    ASSIGN  glb_dscritic = "Base de data nao encontrado para esta cooperativa.".
    MESSAGE glb_dscritic.
    RETURN "NOK".
END.

FIND LAST crapris NO-LOCK 
    WHERE crapris.cdcooper = glb_cdcooper
      AND crapris.dtrefere <= crapdat.dtultdma
      AND crapris.inddocto = 1 NO-ERROR.

IF AVAIL crapris THEN                                 
    ASSIGN aux_dtrefris = crapris.dtrefere.    

HIDE FRAME f_confirma.
ASSIGN aux_msgauxil = "GERANDO ARQUIVO".
ASSIGN aux_contregi = 0.
MESSAGE aux_msgauxil.

FOR EACH crapass NO-LOCK WHERE crapass.cdcooper = glb_cdcooper
                           AND crapass.dtdemiss = ?
                      BREAK BY crapass.cdagenci
                            BY crapass.nrdconta:  
    /*** contador para a barra de geracao do arquivo ***/
    ASSIGN aux_contregi = aux_contregi + 1.
    IF  aux_contregi MOD 500 = 0 THEN
    DO:
        PAUSE(0).
        ASSIGN aux_msgauxil = aux_msgauxil + "|".
        MESSAGE aux_msgauxil.
        IF  aux_contregi MOD 32500 = 0 THEN
            aux_msgauxil = "GERANDO ARQUIVO".
    END. 

    /*** Buscar os titulares ***/
    IF crapass.inpessoa = 1 THEN /*** PESSOA FISICA ***/ 
            FOR EACH crapttl FIELDS(nrcpfcgc nmextttl) NO-LOCK
               WHERE crapttl.cdcooper = crapass.cdcooper
                 AND crapttl.nrdconta = crapass.nrdconta:
                
                RUN consulta_dados(INPUT crapttl.nrcpfcgc,
                                   INPUT crapttl.nmextttl).
            END.
    ELSE /*** PESSOA JURIDICA ***/ 
        RUN consulta_dados(INPUT crapass.nrcpfcgc,
                           INPUT crapass.nmprimtl).
END.

ASSIGN aux_contregi = 0.
            
FOR EACH tt-conscr NO-LOCK:

    IF  aux_contregi MOD 50000 = 0 THEN
        DO:
            aux_contarqv = aux_contarqv + 1.

            IF  NOT aux_flgprime THEN
            DO:
                OUTPUT CLOSE.
                UNIX SILENT VALUE("ux2dos " + aux_nmarqdst + " > " +  aux_nmarquivo).
                IF  aux_nmarqdst <> ""  THEN
                    UNIX SILENT VALUE ("rm " + aux_nmarqdst + " 2> /dev/null" ). 
            END.
                
                ASSIGN aux_nmarquivo =  tel_nmdireto + tel_nmarquiv + 
                                    "_" + STRING(aux_contarqv) + aux_extensao.
                                                                     
                ASSIGN aux_nmarqdst = "rl/impscr" + "_" + 
                                            STRING(aux_contarqv) + ".txt".
        
            OUTPUT TO VALUE(aux_nmarqdst).
            
            PUT UNFORMATTED                                                               
                "PA"                            + ";"                                     
                "Conta"                         + ";"                                     
                "Nome"                          + ";"                                     
                "CPF/CNPJ"                      + ";"                                     
                "Operacoes Credito SFN"         + ";"                                     
                "Data BACEN"                    + ";"                                     
                "Operacoes Credito Coop. Atual" + ";"                                     
                "Data Atual"                    + ";"                                     
                "Operacoes Credito Coop. BACEN" + ";"                                     
                "Operacoes Vencidas"            + ";"                                     
                "Operacoes em Prejuizo"         + ";"                                     
                "Operacoes a Vencer"            + ";"                                     
                "Limite"                        + ";"                                     
                "Mensagem"                                                                
                 SKIP.
                            
            ASSIGN aux_relatori = YES 
                   aux_flgprime = NO.
                                                                     
        END.
                                                                     
    PUT UNFORMATTED
        STRING(tt-conscr.cdagenci,"zz9")                  + ";"                   
        STRING(tt-conscr.nrdconta,"zzzz,zzz,9")           + ";"
        STRING(tt-conscr.nmtitula, "X(40)")               + ";"
        "'" + STRING(tt-conscr.nrcpfcgc,"zzzzzzzzzzzzz9") + ";"
        STRING(tt-conscr.vlopesfn,"zzz,zzz,zzz,zz9.99")   + ";"
        STRING(tt-conscr.dtrefbac,"x(08)")                + ";"
        STRING(tt-conscr.vlopcoop,"zzz,zzz,zzz,zz9.99-")  + ";"
        STRING(tt-conscr.dtrefere,"99/99/9999")           + ";"
        STRING(tt-conscr.vlopbase,"zzz,zzz,zzz,zz9.99-")  + ";"
        STRING(tt-conscr.vlopevnc,"zzz,zzz,zzz,zz9.99")   + ";"
        STRING(tt-conscr.vlopeprj,"zzz,zzz,zzz,zz9.99")   + ";"
        STRING(tt-conscr.vlvencer,"zzz,zzz,zzz,zz9.99")   + ";"
        STRING(tt-conscr.vllimite,"zzz,zzz,zzz,zz9.99")   + ";"
        tt-conscr.mensagem
        SKIP.
                                                                     
        aux_contregi = aux_contregi + 1.
                                                                     
END.                                                                          

OUTPUT CLOSE.

IF  aux_contregi <> 50000 THEN
    DO:
        UNIX SILENT VALUE("ux2dos " + aux_nmarqdst + " > " +  aux_nmarquivo).
        IF  aux_nmarqdst <> ""  THEN
            UNIX SILENT VALUE ("rm " + aux_nmarqdst + " 2> /dev/null" ).
    END.

IF aux_relatori THEN
   MESSAGE "Relatorio gerado com sucesso."
        VIEW-AS ALERT-BOX INFO BUTTONS OK.

PROCEDURE consulta_dados:

    DEF INPUT PARAM par_nrcpfcgc AS DECIMAL                            NO-UNDO.
    DEF INPUT PARAM par_nmtitula AS CHARACTER                          NO-UNDO.

    ASSIGN aux_dtrefere = tel_dtdebase
           aux_vlopesfn = 0
           aux_dtrefbac = ""
           aux_vlopbase = 0
           aux_vlopcoop = 0
           aux_vlopevnc = 0
           aux_vlopeprj = 0
           aux_vlvencer = 0
           aux_vllimite = 0
           aux_mensagem = "".

    /*** Buscar as informações na crapopf, crapvop através do CPF/CNPJ ***/
    FIND LAST crapopf NO-LOCK 
        WHERE crapopf.nrcpfcgc = par_nrcpfcgc  
          AND crapopf.dtrefere = aux_dtrefere NO-ERROR. 

    IF AVAIL crapopf THEN 
        DO: 
            FOR EACH crapvop NO-LOCK  
               WHERE crapvop.nrcpfcgc = crapopf.nrcpfcgc 
                 AND crapvop.dtrefere = crapopf.dtrefere:

                /*** Total de Operações de Crédito no SFN ***/
                aux_vlopesfn = aux_vlopesfn + crapvop.vlvencto.

                /*** Limites ***/
                IF crapvop.cdvencto < 110 THEN
                    aux_vllimite = aux_vllimite + crapvop.vlvencto.

                /*** Operacoes a Vencer ***/
                IF  crapvop.cdvencto >= 110 AND
                    crapvop.cdvencto <= 199 THEN
                    aux_vlvencer = aux_vlvencer + crapvop.vlvencto.

                /*** Operacoes Vencidas ***/
                IF  crapvop.cdvencto >= 205 AND
                    crapvop.cdvencto <= 290 THEN
                    aux_vlopevnc = aux_vlopevnc + crapvop.vlvencto.
        
                /*** Operacoes em Prejuizo ***/
                IF  crapvop.cdvencto >= 310 AND
                    crapvop.cdvencto <= 330 THEN
                    aux_vlopeprj = aux_vlopeprj + crapvop.vlvencto.
            END.
                
            ASSIGN aux_dtrefere = crapopf.dtrefere.
        
            RUN verifica_data_bacen.
            
            /*** Total de Operações de Crédito na Cooperativa Data Base BACEN ***/
            FOR EACH crapris FIELDS(vldivida) NO-LOCK
               WHERE crapris.cdcooper = crapass.cdcooper
                 AND crapris.nrcpfcgc = crapopf.nrcpfcgc
                 AND crapris.nrdconta = crapass.nrdconta
                 AND crapris.dtrefere = aux_dtrefere
                 AND crapris.inddocto = 1
                 USE-INDEX crapris1:
        
                aux_vlopbase = aux_vlopbase + crapris.vldivida.
            END.
        END.
    ELSE
        DO:
            FIND crapces WHERE crapces.nrcpfcgc = par_nrcpfcgc AND
                               crapces.dtrefere = aux_dtrefere
                               NO-LOCK NO-ERROR.

            IF NOT AVAIL(crapces) THEN
                ASSIGN aux_mensagem = "Informacoes do BACEN deste CPF/CNPJ nao estao disponiveis".
        END.
    
    IF  aux_dtrefris <> ? THEN
        ASSIGN aux_dtrefere = aux_dtrefris.

    /*** Total de Operações de Crédito na Cooperativa Data Base Atual ***/
                 
    FOR EACH crapris FIELDS(vldivida) NO-LOCK 
       WHERE crapris.cdcooper = crapass.cdcooper 
         AND crapris.nrcpfcgc = par_nrcpfcgc   
         AND crapris.dtrefere = aux_dtrefere       
         AND crapris.nrdconta = crapass.nrdconta
         AND crapris.inddocto = 1 
         USE-INDEX crapris1:
                                    
        ASSIGN aux_vlopcoop = aux_vlopcoop + crapris.vldivida.
    END.
    
    IF NOT CAN-FIND(FIRST tt-conscr
                    WHERE tt-conscr.cdagenci = crapass.cdagenci  
                      AND tt-conscr.nrdconta = crapass.nrdconta  
                      AND tt-conscr.nrcpfcgc = par_nrcpfcgc
                    USE-INDEX id-tt-conscr) THEN
        DO: 
            CREATE tt-conscr.
            ASSIGN tt-conscr.cdagenci = crapass.cdagenci  
                   tt-conscr.nrdconta = crapass.nrdconta  
                   tt-conscr.nrcpfcgc = par_nrcpfcgc 
                   tt-conscr.vlopesfn = aux_vlopesfn 
                   tt-conscr.dtrefbac = aux_dtrefbac
                   tt-conscr.vlopbase = aux_vlopbase
                   tt-conscr.dtrefere = aux_dtrefere
                   tt-conscr.vlopcoop = aux_vlopcoop
                   tt-conscr.vlopevnc = aux_vlopevnc 
                   tt-conscr.vlopeprj = aux_vlopeprj 
                   tt-conscr.vlvencer = aux_vlvencer 
                   tt-conscr.vllimite = aux_vllimite
                   tt-conscr.mensagem = aux_mensagem
                   tt-conscr.nmtitula = par_nmtitula.
        END.
    
END PROCEDURE.

PROCEDURE verifica_data_bacen:         
           
    CASE (MONTH(aux_dtrefere)):    
        WHEN 1 THEN         
            ASSIGN aux_dtrefbac = "Jan/"+ STRING(YEAR(aux_dtrefere)).           
        WHEN 2 THEN         
            ASSIGN aux_dtrefbac = "Fev/"+ STRING(YEAR(aux_dtrefere)).          
        WHEN 3 THEN         
            ASSIGN aux_dtrefbac = "Mar/"+ STRING(YEAR(aux_dtrefere)).          
        WHEN 4 THEN         
            ASSIGN aux_dtrefbac = "Abr/"+ STRING(YEAR(aux_dtrefere)).        
        WHEN 5 THEN         
            ASSIGN aux_dtrefbac = "Mai/"+ STRING(YEAR(aux_dtrefere)).       
        WHEN 6 THEN         
            ASSIGN aux_dtrefbac = "Jun/"+ STRING(YEAR(aux_dtrefere)).        
        WHEN 7 THEN         
            ASSIGN aux_dtrefbac = "Jul/"+ STRING(YEAR(aux_dtrefere)).
        WHEN 8 THEN         
            ASSIGN aux_dtrefbac = "Ago/"+ STRING(YEAR(aux_dtrefere)).    
        WHEN 9 THEN         
            ASSIGN aux_dtrefbac = "Set/"+ STRING(YEAR(aux_dtrefere)).    
        WHEN 10 THEN         
            ASSIGN aux_dtrefbac = "Out/"+ STRING(YEAR(aux_dtrefere)).    
        WHEN 11 THEN         
            ASSIGN aux_dtrefbac = "Nov/"+ STRING(YEAR(aux_dtrefere)).          
        WHEN 12 THEN         
            ASSIGN aux_dtrefbac = "Dez/"+ STRING(YEAR(aux_dtrefere)).    
    END CASE.    
    
END PROCEDURE.
