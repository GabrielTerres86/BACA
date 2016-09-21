/* ...........................................................................

   Programa: Fontes/importa_cartao.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Janeiro/2013                      Ultima atualizacao: 04/03/2013 

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Importar uma lista de cartoes para geracao de relatorio.

   Alteracoes: 04/02/2013 - Tratamento quando nao encontrado o cartao e 
                            quando existe mais de um registro com o mesmo 
                            numero do cartao (Gabriel).         
                            
               04/03/2013 - Incluir a informacao do PAC (Gabriel).                                                               
                                                                                                                             
............................................................................*/

DEF INPUT PARAM par_cdcooper AS INTE                                 NO-UNDO.
DEF INPUT PARAM par_nmarqimp AS CHAR                                 NO-UNDO.


DEFINE STREAM str_1.
DEFINE STREAM str_2.

DEFINE VARIABLE aux_nmarqdst AS CHARACTER                            NO-UNDO.
DEFINE VARIABLE aux_nmarqrel AS CHARACTER                            NO-UNDO.
DEFINE VARIABLE aux_setlinha AS CHARACTER                            NO-UNDO.
DEFINE VARIABLE aux_nrcrcard AS CHARACTER                            NO-UNDO.
DEFINE VARIABLE aux_vllimcrd AS DECIMAL                              NO-UNDO.
DEFINE VARIABLE aux_nrdoccrd LIKE crawcrd.nrdoccrd                   NO-UNDO.
DEFINE VARIABLE aux_dtnasccr LIKE crawcrd.dtnasccr                   NO-UNDO.
DEFINE VARIABLE aux_dsendere LIKE crapenc.dsendere                   NO-UNDO.
DEFINE VARIABLE aux_nrendere LIKE crapenc.nrendere                   NO-UNDO.
DEFINE VARIABLE aux_nmbairro LIKE crapenc.nmbairro                   NO-UNDO.
DEFINE VARIABLE aux_nmcidade LIKE crapenc.nmcidade                   NO-UNDO.
DEFINE VARIABLE aux_cdufende LIKE crapenc.cdufende                   NO-UNDO.
DEFINE VARIABLE aux_nrcepend LIKE crapenc.nrcepend                   NO-UNDO.
DEFINE VARIABLE aux_dssitcrd AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_dscomple AS CHAR                                 NO-UNDO.

DEFINE VARIABLE h-b1wgen0028 AS HANDLE                               NO-UNDO.

                                                     
FORM crapcrd.nrcrcard COLUMN-LABEL "Numero do cartao"  FORMAT "9999,9999,9999,9999" 
     crapcrd.nmtitcrd COLUMN-LABEL "Titular do cartao" FORMAT "x(40)"     
     crapcrd.cdcooper COLUMN-LABEL "Cod.Coop."         FORMAT "zz9"                               
     crapcrd.nrdconta COLUMN-LABEL "Conta/dv"          FORMAT "zzzz,zzz,9"     
     crapass.cdagenci COLUMN-LABEL "PAC"               FORMAT "zz9" 
     crapcrd.nrcpftit COLUMN-LABEL "CPF do titular"    FORMAT "zzzzzzzzzz9" 
     aux_dssitcrd     COLUMN-LABEL "Sit.Cartao."       FORMAT "x(15)"  
     crapcrd.dddebito COLUMN-LABEL "Dia debito"      
     crapcrd.dtvalida COLUMN-LABEL "Validade cartao"
     aux_vllimcrd     COLUMN-LABEL "Lim.Cartao "       FORMAT "zzz,zzz,zzz,zz9.99"
     aux_dsendere     COLUMN-LABEL "Endereco"          FORMAT "x(35)" 
     aux_dscomple     COLUMN-LABEL "Complemento"       FORMAT "x(25)"
     aux_nrendere     COLUMN-LABEL "Nro."                  
     aux_nmbairro     COLUMN-LABEL "Bairro"            FORMAT "x(25)"                    
     aux_nmcidade     COLUMN-LABEL "Cidade"            FORMAT "x(25)"                          
     aux_cdufende     COLUMN-LABEL "U.F."                                        
     aux_nrcepend     COLUMN-LABEL "C.E.P."                                                 
     WITH DOWN WIDTH 362 FRAME f_list_cartoes.


/******************************************************************************/
FUNCTION Retira_Caracteres RETURN CHAR(INPUT par_string   AS CHARACTER,
                                       INPUT par_listacar AS CHARACTER):

    DEFINE VARIABLE aux_contador AS INTEGER NO-UNDO.
    
    DO aux_contador = 1 TO NUM-ENTRIES(par_listacar,";") ON ERROR UNDO, RETURN "NOK":

        ASSIGN par_string = REPLACE(par_string,ENTRY(aux_contador,par_listacar,";"),"").
    END.
    
    RETURN par_string.
  
END. /* Retira_Caracteres */

/******************************************************************************/

FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

ASSIGN aux_nmarqrel = "/micros/" + crapcop.dsdircop + "/movtos_" + 
                      STRING(TIME) + "_2.txt"
       aux_nmarqdst = "/micros/" + crapcop.dsdircop + "/movtos_" + 
                      STRING(TIME) + ".txt".

IF   SEARCH(par_nmarqimp) = ?   THEN
     DO:
         MESSAGE "Arquivo informado nao foi encontrado.".   
         RETURN "NOK".
     END.

INPUT  STREAM str_1 FROM VALUE(par_nmarqimp).
OUTPUT STREAM str_2 TO VALUE(aux_nmarqrel).

RUN pi-importacao-dados.

OUTPUT STREAM str_2 CLOSE.
INPUT  STREAM str_1 CLOSE.

IF   aux_nmarqrel <> ""  THEN
     DO:
         UNIX SILENT VALUE("ux2dos " + aux_nmarqrel + " > " + aux_nmarqdst).
     
         UNIX SILENT VALUE("rm " + aux_nmarqrel).
     END.

MESSAGE "Relatorio gerado com sucesso em " + aux_nmarqdst
    VIEW-AS ALERT-BOX INFO BUTTONS OK.

RETURN "OK".

PROCEDURE pi-importacao-dados:

    DEF VAR aux_flgregis AS LOGI                                NO-UNDO.

    MESSAGE "Gerando arquivo...".

    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h-b1wgen0028.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE
                   ON ERROR  UNDO, LEAVE:

        IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

        ASSIGN aux_flgregis = FALSE.

        FOR EACH crapcop NO-LOCK,
       
            EACH crapcrd WHERE crapcrd.cdcooper = crapcop.cdcooper AND
                               crapcrd.nrcrcard = DECIMAL(aux_setlinha)
                               USE-INDEX crapcrd3 NO-LOCK:

            /* Se foi uma conta migrada, next */
            FIND FIRST craptco WHERE craptco.cdcopant = crapcrd.cdcooper   AND
                                     craptco.nrctaant = crapcrd.nrdconta   AND
                                     craptco.tpctatrf <> 3                  
                                     NO-LOCK NO-ERROR.

            IF   AVAIL craptco   THEN
                 NEXT.

            ASSIGN aux_flgregis = TRUE.

            FIND crapass WHERE crapass.cdcooper = crapcrd.cdcooper   AND
                               crapass.nrdconta = crapcrd.nrdconta
                               NO-LOCK NO-ERROR.

            FIND FIRST crawcrd WHERE crawcrd.cdcooper = crapcrd.cdcooper
                                 AND crawcrd.nrdconta = crapcrd.nrdconta
                                 AND crawcrd.nrctrcrd = crapcrd.nrctrcrd 
                                     USE-INDEX crawcrd1 NO-LOCK NO-ERROR.
            IF   AVAIL crawcrd THEN
                 ASSIGN aux_nrdoccrd = crawcrd.nrdoccrd
                        aux_dtnasccr = crawcrd.dtnasccr.
            ELSE
                 ASSIGN aux_nrdoccrd = ""
                        aux_dtnasccr = ?.

            FIND craptlc WHERE craptlc.cdcooper = crapcrd.cdcooper   AND
                               craptlc.cdadmcrd = crapcrd.cdadmcrd   AND
                               craptlc.tpcartao = crapcrd.tpcartao   AND
                               craptlc.cdlimcrd = crapcrd.cdlimcrd   AND
                               craptlc.dddebito = 0  
                               NO-LOCK NO-ERROR.

            IF   AVAIL craptlc   THEN
                 ASSIGN aux_vllimcrd = craptlc.vllimcrd.
            ELSE
                 ASSIGN aux_vllimcrd = 0.
    
            FIND FIRST crapenc WHERE crapenc.cdcooper = crapcrd.cdcooper
                                 AND crapenc.nrdconta = crawcrd.nrdconta
                                 AND crapenc.idseqttl = 1
                                 AND crapenc.cdseqinc = 1 
                                     USE-INDEX crapenc1  NO-LOCK NO-ERROR.

            IF   AVAIL crapenc THEN
                 DO:
                     IF crawcrd.cdgraupr = 5 OR    /* Primeiro Titular */
                        crawcrd.cdgraupr = 6 THEN  /* Segundo Titular */
                         ASSIGN aux_dsendere = REPLACE(SUBSTRING(crapenc.dsendere,1,33),",","")
                                aux_dsendere = Retira_Caracteres(aux_dsendere,".;/;-;:;=")
                                aux_dscomple = crapenc.complend
                                aux_nrendere = crapenc.nrendere
                                aux_nmbairro = Retira_Caracteres(crapenc.nmbairro,".")
                                aux_nmcidade = Retira_Caracteres(crapenc.nmcidade,".;-;,")
                                aux_cdufende = crapenc.cdufende
                                aux_nrcepend = crapenc.nrcepend.
                     ELSE
                         ASSIGN  aux_dsendere = ""
                                 aux_dscomple = ""
                                 aux_nrendere = 0
                                 aux_nmbairro = ""
                                 aux_nmcidade = ""
                                 aux_cdufende = ""
                                 aux_nrcepend = 0.
                 END.
            ELSE
                 ASSIGN aux_dsendere = ""
                        aux_dscomple = ""
                        aux_nrendere = 0
                        aux_nmbairro = ""
                        aux_nmcidade = ""
                        aux_cdufende = ""
                        aux_nrcepend = 0.

            IF   AVAIL crawcrd THEN
                 ASSIGN aux_dssitcrd = 
                       DYNAMIC-FUNCTION("retorna-situacao" IN h-b1wgen0028,
                                     INPUT crawcrd.insitcrd,
                                     INPUT crawcrd.dtsol2vi,
                                     INPUT crawcrd.cdadmcrd).
            ELSE
                 ASSIGN aux_dssitcrd = "".

            DISPLAY STREAM str_2 crapcrd.nrcrcard
                                 crapcrd.nmtitcrd
                                 crapcrd.cdcooper
                                 crapcrd.nrdconta
                                 crapass.cdagenci WHEN AVAIL crapass
                                 crapcrd.nrcpftit
                                 aux_dssitcrd    
                                 crapcrd.dddebito
                                 crapcrd.dtvalida
                                 aux_vllimcrd    
                                 aux_dsendere    
                                 aux_dscomple    
                                 aux_nrendere    
                                 aux_nmbairro    
                                 aux_nmcidade    
                                 aux_cdufende    
                                 aux_nrcepend    
                                 WITH FRAME f_list_cartoes.

            DOWN WITH FRAME f_list_cartoes.
        END.

        IF   NOT aux_flgregis   THEN
             DO:
                 ASSIGN aux_nrcrcard = REPLACE(STRING(aux_setlinha,"9999,9999,9999,9999"),",",".").

                 DISPLAY STREAM str_2  
                     aux_nrcrcard FORMAT "x(19)" @ crapcrd.nrcrcard 
                     "0"                         @ crapcrd.nmtitcrd
                      0                          @ crapcrd.cdcooper
                      0                          @ crapcrd.nrdconta
                      0                          @ crapass.cdagenci
                      0                          @ crapcrd.nrcpftit
                     "0"                         @ aux_dssitcrd    
                      0                          @ crapcrd.dddebito
                      0                          @ crapcrd.dtvalida
                      0                          @ aux_vllimcrd    
                     "0"                         @ aux_dsendere    
                     "0"                         @ aux_dscomple    
                      0                          @ aux_nrendere    
                     "0"                         @ aux_nmbairro    
                     "0"                         @ aux_nmcidade    
                     "0"                         @ aux_cdufende    
                      0                          @ aux_nrcepend    
                     WITH FRAME f_list_cartoes.

                 DOWN WITH FRAME f_list_cartoes.
                                      
             END.     
    END.

    HIDE MESSAGE NO-PAUSE.

    DELETE PROCEDURE h-b1wgen0028.

END PROCEDURE.           

