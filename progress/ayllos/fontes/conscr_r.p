/*..............................................................................
   Programa: Fontes/conscr_r.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Vitor
   Data    : Julho/2010                     Ultima Atualizacao:  25/06/2014

   Dados referentes ao programa:
   Frequencia : Diario (on-line)
   Objetivo   : Imprimir as consultas da tela CONSCR.(Consulta Sisbacen)
   
   Alteracoes : 24/09/2010 - Alterado formato das variaveis aux_opdtbase,
                             aux_opcooper (Adriano).
                             
                06/05/2011 - Alterada a chamada do programa fontes/conscr.p
                             para fontes/conscrp.p (Isara - RKAM).
                
                21/05/2012 - Implementado tratamento crapces (Tiago).
                
                10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (André Euzébio - Supero).   
                             
                29/05/2014 - Concatena o numero do servidor no endereco do
                             terminal (Tiago-RKAM).
                             
                25/06/2014 -  Ajuste leitura CRAPRIS (Daniel) SoftDesk 137892. 
..............................................................................*/
DEF STREAM str_1.

{includes/var_online.i } 

DEF INPUT PARAMETER par_nrcpfcgc AS DECIMAL FORMAT "zzzzzzzzzzzzz9"    NO-UNDO.
DEF INPUT PARAMETER par_nrdconta AS INT                                NO-UNDO.
DEF INPUT PARAMETER par_cdagenci AS INT init 1                         NO-UNDO.

DEF VAR tel_dtrefere AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdconta AS INTE    FORMAT "zzzz,zzz,9"                    NO-UNDO.
DEF VAR aux_nrcpfcgc LIKE crapass.nrcpfcgc                             NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.

DEF VAR aux_contador AS INT     FORMAT "zz9"                           NO-UNDO.
DEF VAR aux_dtrefere AS DATE    FORMAT "99/99/9999"                    NO-UNDO.
DEF VAR aux_dtrefris AS DATE    FORMAT "99/99/9999"                    NO-UNDO.
DEF VAR aux_qtopesfn AS INTE                                           NO-UNDO.
DEF VAR aux_qtifssfn AS INTE                                           NO-UNDO.
DEF VAR aux_opfinanc AS DECI    FORMAT "z,zzz,zzz,zz9.99"              NO-UNDO.
DEF VAR aux_opvencid AS DECI                                           NO-UNDO.
DEF VAR aux_opcooper AS DECI    FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
DEF VAR aux_oprejuiz AS DECI                                           NO-UNDO.
DEF VAR aux_opdtbase AS DECI    FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
                                                                   
DEF VAR aux_disponiv AS CHAR                                           NO-UNDO.

/* Variaveis para impressao */                                     
DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"          NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"          NO-UNDO.

DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                        NO-UNDO.
DEF VAR aux_dscomand AS CHARACTER                                      NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL                                        NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL                                        NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                        NO-UNDO.
                                                                    
/* Variaveis cabecalho */                                           
DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                         NO-UNDO.
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                         NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5                NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                             NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5                NO-UNDO.
DEF VAR rel_nmmesref AS CHAR    FORMAT "x(014)"                        NO-UNDO.


DEF VAR aux_dtultdma AS DATE                                           NO-UNDO.             

FORM "Consulta Central de Risco - Data Base Bacen:" tel_dtrefere SKIP(1)
    WITH 8 DOWN ROW 10 COLUMN 2 WIDTH 132 OVERLAY NO-BOX NO-LABEL FRAME f_titulo. 

FORM aux_cdagenci LABEL "PA"                  FORMAT "zzz"                               
     aux_nrdconta LABEL "Conta"               FORMAT "zzzz,zzz,9"
     aux_nrcpfcgc LABEL "CPF/CNPJ"            FORMAT "zzzzzzzzzzzzz9"
     aux_nmprimtl LABEL "Nome"                FORMAT "x(10)" 
     aux_qtopesfn LABEL "QtOper"              FORMAT "zzz9"
     aux_qtifssfn LABEL "QtIfs"               FORMAT "zzz9"                               
     aux_opfinanc LABEL "Op.SFN"              FORMAT "z,zzz,zzz,zz9.99"        
     aux_opvencid LABEL "Op.Vencidas"         FORMAT "zzz,zzz,zz9.99"                           
     aux_oprejuiz LABEL "Op.Prejuizo"         FORMAT "zzz,zzz,zz9.99"                           
     aux_opcooper LABEL "Op.Coop. Atual"      FORMAT "zzz,zzz,zz9.99"                          
     aux_opdtbase LABEL "Op.Coop. Bacen"      FORMAT "zzz,zzz,zz9.99"                           
     WITH 8 DOWN ROW 13 COLUMN 2 WIDTH 132 OVERLAY NO-BOX NO-LABEL FRAME f_dados. 

FORM aux_cdagenci LABEL "PA"                  FORMAT "zzz"                               
     aux_nrdconta LABEL "Conta"               FORMAT "zzzz,zzz,9"
     aux_nrcpfcgc LABEL "CPF/CNPJ"            FORMAT "zzzzzzzzzzzzz9"
     aux_nmprimtl LABEL "Nome"                FORMAT "x(40)"                SKIP  
     aux_disponiv LABEL ""                    FORMAT "x(14)"                AT 1     
     aux_qtopesfn LABEL "QtOper"              FORMAT "zzz9"                 AT 40
     aux_qtifssfn LABEL "QtIfs"               FORMAT "zzz9"                               
     aux_opfinanc LABEL "Op.SFN"              FORMAT "z,zzz,zzz,zz9.99"        
     aux_opvencid LABEL "Op.Vencidas"         FORMAT "zzz,zzz,zz9.99"                           
     aux_oprejuiz LABEL "Op.Prejuizo"         FORMAT "zzz,zzz,zz9.99"                           
     aux_opcooper LABEL "Op.Coop. Atual"      FORMAT "zzz,zzz,zz9.99"                          
     aux_opdtbase LABEL "Op.Coop. Bacen"      FORMAT "zzz,zzz,zz9.99"                                 
     WITH 8 DOWN  COLUMN 2 WIDTH 132 OVERLAY NO-BOX NO-LABEL FRAME f_dados2linhas. 

ASSIGN glb_cdrelato[1] = 569.

INPUT THROUGH basename `tty` NO-ECHO.
SET aux_nmendter WITH FRAME f_terminal.
INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 80.

{ includes/cabrel132_1.i }

VIEW STREAM str_1 FRAME f_cabrel132_1.   

/* Ultimo dia do mes passado */
ASSIGN aux_dtultdma = glb_dtmvtolt - DAY(glb_dtmvtolt).

FIND LAST crapris WHERE crapris.cdcooper = glb_cdcooper  AND
                        crapris.dtrefere <= aux_dtultdma AND 
                        crapris.inddocto = 1 NO-LOCK NO-ERROR.
IF AVAIL crapris THEN
    ASSIGN aux_dtrefris = crapris.dtrefere.

FIND LAST crapopf USE-INDEX crapopf2 NO-LOCK NO-ERROR.
IF AVAILABLE crapopf THEN
    aux_dtrefere = crapopf.dtrefere.

CASE (MONTH(aux_dtrefere)):    
    WHEN 1 THEN         
        ASSIGN tel_dtrefere = "Jan/"+ STRING(YEAR(aux_dtrefere)).           
    WHEN 2 THEN         
        ASSIGN tel_dtrefere = "Fev/"+ STRING(YEAR(aux_dtrefere)).          
    WHEN 3 THEN         
        ASSIGN tel_dtrefere = "Mar/"+ STRING(YEAR(aux_dtrefere)).          
    WHEN 4 THEN         
        ASSIGN tel_dtrefere = "Abr/"+ STRING(YEAR(aux_dtrefere)).        
    WHEN 5 THEN         
        ASSIGN tel_dtrefere = "Mai/"+ STRING(YEAR(aux_dtrefere)).       
    WHEN 6 THEN         
        ASSIGN tel_dtrefere = "Jun/"+ STRING(YEAR(aux_dtrefere)).        
    WHEN 7 THEN         
        ASSIGN tel_dtrefere = "Jul/"+ STRING(YEAR(aux_dtrefere)).
    WHEN 8 THEN         
        ASSIGN tel_dtrefere = "Ago/"+ STRING(YEAR(aux_dtrefere)).    
    WHEN 9 THEN         
        ASSIGN tel_dtrefere = "Set/"+ STRING(YEAR(aux_dtrefere)).    
    WHEN 10 THEN         
        ASSIGN tel_dtrefere = "Out/"+ STRING(YEAR(aux_dtrefere)).    
    WHEN 11 THEN         
        ASSIGN tel_dtrefere = "Nov/"+ STRING(YEAR(aux_dtrefere)).          
    WHEN 12 THEN         
        ASSIGN tel_dtrefere = "Dez/"+ STRING(YEAR(aux_dtrefere)).    
END CASE.

DISPLAY STREAM str_1 tel_dtrefere WITH FRAME f_titulo.

/* Procura por CPF/CNPJ */
IF par_nrcpfcgc <> 0 THEN
DO:     
    FOR EACH crapttl WHERE crapttl.cdcooper = glb_cdcooper AND
                           crapttl.nrcpfcgc = par_nrcpfcgc AND 
                           crapttl.nrdconta = par_nrdconta NO-LOCK:

        FIND FIRST crapass WHERE crapass.cdcooper = crapttl.cdcooper AND
                                 crapass.nrdconta = crapttl.nrdconta AND
                                 crapass.dtdemiss = ?   NO-LOCK NO-ERROR.
        
        IF AVAILABLE crapass THEN
        DO:
            ASSIGN aux_opfinanc = 0
                   aux_opvencid = 0
                   aux_oprejuiz = 0
                   aux_opcooper = 0
                   aux_opdtbase = 0
                   aux_qtopesfn = 0
                   aux_qtifssfn = 0
                  
                   aux_disponiv = "".
                
            FIND LAST crapopf WHERE crapopf.dtrefere = aux_dtrefere AND
                                    crapopf.nrcpfcgc = crapttl.nrcpfcgc
                                    NO-LOCK NO-ERROR.
                              
            IF  NOT AVAIL(crapopf) THEN
                DO:
                                              
                   FIND crapces WHERE crapces.nrcpfcgc  = crapttl.nrcpfcgc AND
                                      crapces.dtrefere  = aux_dtrefere
                                      NO-LOCK NO-ERROR.
                                                              
                   IF  NOT AVAIL(crapces) THEN
                       DO:
                       
                           ASSIGN aux_opfinanc = 0
                                  aux_opvencid = 0
                                  aux_oprejuiz = 0
                                  aux_qtopesfn = 9999
                                  aux_qtifssfn = 9999
                                  aux_disponiv = "NAO DISPONIVEL".
                       
                       END.
                                            
                END.                              
                              
            IF AVAILABLE crapopf THEN
               DO:
                   ASSIGN aux_qtopesfn = crapopf.qtopesfn
                          aux_qtifssfn = crapopf.qtifssfn.
    
                   FOR EACH crapvop WHERE crapvop.dtrefere = crapopf.dtrefere AND
                                          crapvop.nrcpfcgc = crapttl.nrcpfcgc
                                          NO-LOCK:
                       ASSIGN aux_opfinanc = aux_opfinanc + crapvop.vlvencto.
    
                        /*Operações Vencidas*/
                        IF crapvop.cdvencto >= 205 AND
                           crapvop.cdvencto <= 290 THEN
                           ASSIGN aux_opvencid = aux_opvencid + crapvop.vlvencto.
    
                        /*Operações Prejuizo */
                        IF crapvop.cdvencto >= 310 AND
                           crapvop.cdvencto <= 330 THEN
                           ASSIGN aux_oprejuiz = aux_oprejuiz + crapvop.vlvencto.
    
                   END. /* for each crapvop */

                   IF crapttl.idseqttl = 1 THEN
                        /*Coop Data Base*/
                         FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper      AND
                                                crapris.nrdconta = crapttl.nrdconta  AND
                                                crapris.dtrefere = aux_dtrefere      AND
                                                crapris.inddocto = 1                
                                                USE-INDEX crapris1 
                                                NO-LOCK:

                             ASSIGN aux_opdtbase = aux_opdtbase + crapris.vldivida.
                        END.
                
               END. /*IF AVAILABLE crapopf*/


            ASSIGN aux_cdagenci = crapass.cdagenci
                   aux_nrdconta = crapttl.nrdconta
                   aux_nrcpfcgc = crapttl.nrcpfcgc
                   aux_nmprimtl = crapttl.nmextttl.

            /*Op Cooper*/
            IF crapttl.idseqttl = 1 THEN
                    FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper     AND
                                           crapris.nrdconta = crapttl.nrdconta AND
                                           crapris.dtrefere = aux_dtrefris     AND
                                           crapris.inddocto = 1 
                                           USE-INDEX crapris1
                                           NO-LOCK:
                        ASSIGN aux_opcooper = aux_opcooper + crapris.vldivida.
                    END.

            DISP STREAM str_1
                        aux_cdagenci
                        aux_nrdconta
                        aux_nrcpfcgc
                        aux_nmprimtl
                        aux_disponiv
                        aux_qtopesfn
                        aux_qtifssfn
                        aux_opfinanc
                        aux_opvencid
                        aux_oprejuiz
                        aux_opcooper
                        aux_opdtbase
                        WITH FRAME f_dados2linhas.
            DOWN STREAM str_1 WITH FRAME f_dados2linhas.

        END. /*if available crapass*/
    END. /*crapttl*/

    FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper AND
                           crapass.nrcpfcgc = par_nrcpfcgc AND
                           crapass.nrdconta = par_nrdconta AND
                          (crapass.inpessoa = 2            OR
                           crapass.inpessoa = 3)           AND
                           crapass.dtdemiss = ? NO-LOCK:
    
            ASSIGN aux_opfinanc = 0
                   aux_opvencid = 0
                   aux_oprejuiz = 0
                   aux_opcooper = 0
                   aux_opdtbase = 0
                   aux_qtopesfn = 0
                   aux_qtifssfn = 0
                
                   aux_disponiv = "".
    
            FIND LAST crapopf WHERE crapopf.dtrefere = aux_dtrefere AND
                                    crapopf.nrcpfcgc = crapass.nrcpfcgc
                              NO-LOCK NO-ERROR.
            IF AVAILABLE crapopf THEN
               DO:
                   ASSIGN aux_qtopesfn = crapopf.qtopesfn
                          aux_qtifssfn = crapopf.qtifssfn.
    
                   FOR EACH crapvop WHERE crapvop.dtrefere = crapopf.dtrefere AND
                                          crapvop.nrcpfcgc = crapass.nrcpfcgc
                                          NO-LOCK:
                       ASSIGN aux_opfinanc = aux_opfinanc + crapvop.vlvencto.
    
                        /*Operações Vencidas*/
                        IF crapvop.cdvencto >= 205 AND
                           crapvop.cdvencto <= 290 THEN
                           ASSIGN aux_opvencid = aux_opvencid + crapvop.vlvencto.
    
                        /*Operações Prejuizo */
                        IF crapvop.cdvencto >= 310 AND
                           crapvop.cdvencto <= 330 THEN
                           ASSIGN aux_oprejuiz = aux_oprejuiz + crapvop.vlvencto.
    
                   END. /* for each crapvop */
    
                   /*Coop Data Base*/
                   FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper      AND
                                          crapris.nrdconta = crapass.nrdconta  AND
                                          crapris.dtrefere = aux_dtrefere      AND
                                          crapris.inddocto = 1 
                                          USE-INDEX crapris1
                                          NO-LOCK:

                       ASSIGN aux_opdtbase = aux_opdtbase + crapris.vldivida.
                  END.
    
               END. /*IF AVAILABLE crapopf*/

           ELSE
               DO:
                   ASSIGN aux_opfinanc = 0
                          aux_opvencid = 0
                          aux_oprejuiz = 0
                          aux_qtopesfn = 9999
                          aux_qtifssfn = 9999
                          
                          aux_disponiv = "NAO DISPONIVEL".
               END.

            ASSIGN aux_cdagenci = crapass.cdagenci
                   aux_nrdconta = crapass.nrdconta
                   aux_nrcpfcgc = crapass.nrcpfcgc
                   aux_nmprimtl = crapass.nmprimtl.

            /*Op Cooper*/
            FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper     AND
                                   crapris.nrdconta = crapass.nrdconta AND
                                   crapris.dtrefere = aux_dtrefris     AND
                                   crapris.inddocto = 1 
                                   USE-INDEX crapris1
                                   NO-LOCK:
                ASSIGN aux_opcooper = aux_opcooper + crapris.vldivida.
            END.

            DISP STREAM str_1
                        aux_cdagenci
                        aux_nrdconta
                        aux_nrcpfcgc
                        aux_nmprimtl
                        aux_disponiv
                        aux_qtopesfn
                        aux_qtifssfn
                        aux_opfinanc
                        aux_opvencid
                        aux_oprejuiz
                        aux_opcooper
                        aux_opdtbase
                        WITH FRAME f_dados2linhas.
            DOWN STREAM str_1 WITH FRAME f_dados2linhas.
            

    END. /* for each crapass */
END. /* if par_nrcpfcgc <> 0 */

/* Procura por agencia */
ELSE
DO:
    FOR EACH crapass NO-LOCK WHERE crapass.cdcooper = glb_cdcooper AND
                                 ( crapass.cdagenci = par_cdagenci OR
                                       par_cdagenci = 0 )          AND
                                   crapass.dtdemiss = ? 
                                   BY crapass.cdagenci
                                   BY crapass.nrdconta:

        IF crapass.inpessoa = 1 THEN
            FOR EACH crapttl WHERE crapttl.cdcooper = glb_cdcooper AND
                                   crapttl.nrdconta = crapass.nrdconta NO-LOCK:

                ASSIGN aux_opfinanc = 0
                       aux_opvencid = 0
                       aux_oprejuiz = 0
                       aux_opcooper = 0
                       aux_opdtbase = 0
                       aux_qtopesfn = 0
                       aux_qtifssfn = 0
                    
                       aux_disponiv = "".

                FIND LAST crapopf WHERE crapopf.dtrefere = aux_dtrefere AND
                                        crapopf.nrcpfcgc = crapttl.nrcpfcgc
                                  NO-LOCK NO-ERROR.
                IF AVAILABLE crapopf THEN
                   DO:
                       ASSIGN aux_qtopesfn = crapopf.qtopesfn
                              aux_qtifssfn = crapopf.qtifssfn.

                       FOR EACH crapvop WHERE crapvop.nrcpfcgc = crapttl.nrcpfcgc AND
                                              crapvop.dtrefere = crapopf.dtrefere
                                              NO-LOCK:
                           ASSIGN aux_opfinanc = aux_opfinanc + crapvop.vlvencto.

                            /*Operações Vencidas*/
                            IF crapvop.cdvencto >= 205 AND
                               crapvop.cdvencto <= 290 THEN
                               ASSIGN aux_opvencid = aux_opvencid + crapvop.vlvencto.

                            /*Operações Prejuizo */
                            IF crapvop.cdvencto >= 310 AND
                               crapvop.cdvencto <= 330 THEN
                               ASSIGN aux_oprejuiz = aux_oprejuiz + crapvop.vlvencto.

                       END. /* for each crapvop */

                       IF crapttl.idseqttl = 1 THEN
                          /*Coop Data Base*/
                          FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper      AND
                                                 crapris.nrdconta = crapttl.nrdconta  AND
                                                 crapris.dtrefere = aux_dtrefere      AND
                                                 crapris.inddocto = 1                 
                                                 USE-INDEX crapris1
                                                 NO-LOCK:

                              ASSIGN aux_opdtbase = aux_opdtbase + crapris.vldivida.
                          END.
                    
                   END. /*IF AVAILABLE crapopf*/

                ELSE
                    DO:
                        ASSIGN aux_opfinanc = 0
                               aux_opvencid = 0
                               aux_oprejuiz = 0
                               aux_qtopesfn = 9999
                               aux_qtifssfn = 9999

                               aux_disponiv = "NAO DISPONIVEL".
                    END.

                ASSIGN aux_cdagenci = crapass.cdagenci
                       aux_nrdconta = crapttl.nrdconta
                       aux_nrcpfcgc = crapttl.nrcpfcgc
                       aux_nmprimtl = crapttl.nmextttl.

                IF crapttl.idseqttl = 1 THEN
                    /*Op Cooper*/
                    FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper     AND
                                           crapris.nrdconta = crapttl.nrdconta AND
                                           crapris.dtrefere = aux_dtrefris     AND
                                           crapris.inddocto = 1 
                                           USE-INDEX crapris1
                                           NO-LOCK:
                        ASSIGN aux_opcooper = aux_opcooper + crapris.vldivida.
                    END.

                DISP STREAM str_1
                            aux_cdagenci
                            aux_nrdconta
                            aux_nrcpfcgc
                            aux_nmprimtl
                            aux_disponiv
                            aux_qtopesfn
                            aux_qtifssfn
                            aux_opfinanc
                            aux_opvencid
                            aux_oprejuiz
                            aux_opcooper
                            aux_opdtbase
                            WITH FRAME f_dados2linhas.
                DOWN STREAM str_1 WITH FRAME f_dados2linhas.

            END. /*For each crapttl*/
        ELSE
            IF crapass.inpessoa <> 1 THEN
            DO:
                ASSIGN aux_opfinanc = 0
                       aux_opvencid = 0
                       aux_oprejuiz = 0
                       aux_opdtbase = 0
                       aux_qtopesfn = 0
                       aux_qtifssfn = 0
                    
                       aux_disponiv = "".

                FIND LAST crapopf WHERE crapopf.dtrefere = aux_dtrefere AND
                                        crapopf.nrcpfcgc = crapass.nrcpfcgc
                                  NO-LOCK NO-ERROR.
                IF AVAILABLE crapopf THEN
                   DO:
                       ASSIGN aux_qtopesfn = crapopf.qtopesfn
                              aux_qtifssfn = crapopf.qtifssfn.

                       FOR EACH crapvop WHERE crapvop.dtrefere = crapopf.dtrefere AND
                                              crapvop.nrcpfcgc = crapass.nrcpfcgc
                                              NO-LOCK:
                           ASSIGN aux_opfinanc = aux_opfinanc + crapvop.vlvencto.

                            /*Operações Vencidas*/
                            IF crapvop.cdvencto >= 205 AND
                               crapvop.cdvencto <= 290 THEN
                               ASSIGN aux_opvencid = aux_opvencid + crapvop.vlvencto.

                            /*Operações Prejuizo */
                            IF crapvop.cdvencto >= 310 AND
                               crapvop.cdvencto <= 330 THEN
                               ASSIGN aux_oprejuiz = aux_oprejuiz + crapvop.vlvencto.

                       END. /* for each crapvop */

                       /*Coop Data Base*/
                       FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper      AND
                                              crapris.nrdconta = crapass.nrdconta  AND
                                              crapris.dtrefere = aux_dtrefere      AND
                                              crapris.inddocto = 1                 
                                              USE-INDEX crapris1
                                              NO-LOCK:

                           ASSIGN aux_opdtbase = aux_opdtbase + crapris.vldivida.
                      END.

                   END. /*IF AVAILABLE crapopf*/

                ELSE
                    DO:
                        ASSIGN aux_opfinanc = 0
                               aux_opvencid = 0
                               aux_oprejuiz = 0
                               aux_qtopesfn = 9999
                               aux_qtifssfn = 9999

                               aux_disponiv = "NAO DISPONIVEL".
                    END.

                ASSIGN aux_cdagenci = crapass.cdagenci
                       aux_nrdconta = crapass.nrdconta
                       aux_nrcpfcgc = crapass.nrcpfcgc
                       aux_nmprimtl = crapass.nmprimtl.

                /*Op Cooper*/
                FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper     AND
                                       crapris.nrdconta = crapass.nrdconta AND
                                       crapris.dtrefere = aux_dtrefris     AND
                                       crapris.inddocto = 1 
                                       USE-INDEX crapris1
                                       NO-LOCK:
                    ASSIGN aux_opcooper = aux_opcooper + crapris.vldivida.
                END.

                DISP STREAM str_1
                            aux_cdagenci
                            aux_nrdconta
                            aux_nrcpfcgc
                            aux_nmprimtl
                            aux_disponiv
                            aux_qtopesfn
                            aux_qtifssfn
                            aux_opfinanc
                            aux_opvencid
                            aux_oprejuiz
                            aux_opcooper
                            aux_opdtbase
                            WITH FRAME f_dados2linhas.
                DOWN STREAM str_1 WITH FRAME f_dados2linhas.

            END. /*crapass.inpessoa <> 1*/
    END. /* for each crapass */           
END. /* if par_cdagenci <> 0 */

/* Cabecalho para rotina impressao acessar ass */
  
FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapass THEN
     NEXT.

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrdevias = 1
       par_flgrodar = TRUE
       glb_nmformul = "132col".

{ includes/impressao.i }

PROCEDURE p_impressao:

    RUN fontes/conscrp.p (INPUT par_nrcpfcgc, INPUT par_cdagenci).

END PROCEDURE.
