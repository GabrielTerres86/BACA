/* ............................................................................

   Programa: Fontes/sldccr_j.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : André Euzébio - Supero.                   
   Data    : Julho/2011                      Ultima atualizacao:  /  / 


   Objetivo  : Rotina para consultar extrato do cartao de credito.

   Alteracoes: 
  
............................................................................ */

{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_sldccr.i }
{ includes/var_deschq.i "NEW" }
    

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcrcard AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_dtvctini AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtvctfim AS DATE                                  NO-UNDO.

DEF  STREAM str_1.
DEF  STREAM str_2.

/* variaveis para impressao */
DEF        VAR aux_nmarqimp AS CHAR FORMAT "x(40)"                     NO-UNDO.
DEF        VAR par_flgrodar AS LOGI INIT TRUE                          NO-UNDO.
DEF        VAR aux_flgescra AS LOGI                                    NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                    NO-UNDO.
DEF        VAR par_flgfirst AS LOGI INIT TRUE                          NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF        VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF        VAR par_flgcance AS LOGI                                    NO-UNDO.
                                                          
DEF        VAR aux_nmendter AS CHAR FORMAT "x(20)"                     NO-UNDO.
DEF        VAR tel_cddopcao AS CHAR FORMAT "x(1)"                      NO-UNDO.


/***Cabecalho****/                                                     
DEF VAR rel_nmresemp AS CHAR FORMAT "x(15)"                            NO-UNDO.
DEF VAR rel_nmrelato AS CHAR FORMAT "x(40)" EXTENT 5                   NO-UNDO.
DEF VAR rel_nrmodulo AS INTE FORMAT "9"                                NO-UNDO.
DEF VAR rel_nmempres AS CHAR FORMAT "x(15)"                            NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR FORMAT "x(15)" EXTENT 5
                                            INIT ["","","","",""]      NO-UNDO.


DEF VAR aux_ultdebit AS CHAR FORMAT "x(12)" INIT "Ult.debitos"         NO-UNDO.
DEF VAR aux_contadcd AS INTE                                           NO-UNDO.
DEF VAR aux_flgretor AS LOGI                                           NO-UNDO.

DEF VAR aux_nrcrcard AS CHAR                                          NO-UNDO.

DEF VAR h_b1wgen0028 AS HANDLE                                         NO-UNDO.

DEF VAR rel_vlcrdolr AS DECI  FORMAT "zzz,zzz,zz9.99"                  NO-UNDO.
DEF VAR rel_vldbdolr AS DECI  FORMAT "zzz,zzz,zz9.99"                  NO-UNDO.
DEF VAR rel_vlcrreal AS DECI  FORMAT "zzz,zzz,zz9.99"                  NO-UNDO.
DEF VAR rel_vldbreal AS DECI  FORMAT "zzz,zzz,zz9.99"                  NO-UNDO.

DEF VAR tot_vlcrdolr AS DECI  FORMAT "zzz,zzz,zz9.99"                  NO-UNDO.
DEF VAR tot_vldbdolr AS DECI  FORMAT "zzz,zzz,zz9.99"                  NO-UNDO.
DEF VAR tot_vlcrreal AS DECI  FORMAT "zzz,zzz,zz9.99"                  NO-UNDO.
DEF VAR tot_vldbreal AS DECI  FORMAT "zzz,zzz,zz9.99"                  NO-UNDO.
DEF VAR tot_vlrsaldo AS DECI  FORMAT "zzz,zzz,zz9.99"                  NO-UNDO.

DEF VAR tel_dtextrat AS CHAR                                           NO-UNDO.




FORM "EXTRATO CARTAO DE CREDITO CECRED VISA:"                     AT 47 SKIP(2)
     tt-extrato-cartao.nrdconta LABEL "NR CONTA"                  AT 2    
     tt-extrato-cartao.nmprimtl LABEL "NOME"      FORMAT "x(50)"  AT 42 SKIP 
     aux_nrcrcard               LABEL "NR CARTAO" FORMAT "x(22)"  AT 1
     tt-extrato-cartao.nmtitcrd LABEL "PORTADOR"                  AT 38 SKIP
     tel_dtextrat               LABEL "PERIODO"                   AT 3
     tt-extrato-cartao.vllimite LABEL "LIMITE(R$)"                AT 36 SKIP(2)
     
     WITH SIDE-LABELS WIDTH 132 FRAME f_infrelatorio.

DEF FRAME  f_titrelatorio
       "DT COMPRA"                                                AT 1
       "DESCRICAO"                                                AT 12
       "CIDADE"                                                   AT 47
       "CREDITO(US$)"                                             AT 72
       "DEBITO(US$)"                                              AT 87
       "CREDITO(R$)"                                              AT 103
       "DEBITO(R$)"                                               AT 118
       WITH SIDE-LABELS WIDTH 132 .

FORM tt-extrato-cartao.dtcompra                                   NO-LABEL     
     tt-extrato-cartao.dsestabe  FORMAT "x(30)"                   NO-LABEL 
     tt-extrato-cartao.nmcidade  FORMAT "x(20)"           AT 47   NO-LABEL 
     rel_vlcrdolr                FORMAT "zzz,zzz,zz9.99"  AT 70   NO-LABEL
     rel_vldbdolr                FORMAT "zzz,zzz,zz9.99"  AT 84   NO-LABEL
     rel_vlcrreal                FORMAT "zzz,zzz,zz9.99"  AT 100  NO-LABEL
     rel_vldbreal                FORMAT "zzz,zzz,zz9.99"  AT 114  NO-LABEL
     WITH DOWN WIDTH 132 FRAME f_detlhextrato CENTERED.      

FORM SKIP 
     "TOTAL:"                                            AT 60 
     tot_vlcrdolr               FORMAT "zzz,zzz,zz9.99"  AT 70    NO-LABEL 
     tot_vldbdolr               FORMAT "zzz,zzz,zz9.99"  AT 84    NO-LABEL 
     tot_vlcrreal               FORMAT "zzz,zzz,zz9.99"  AT 100   NO-LABEL 
     tot_vldbreal               FORMAT "zzz,zzz,zz9.99"  AT 114   NO-LABEL
     SKIP(1) 
     "TOTAL PARA PAGAMENTO:"                             AT 69
     tot_vlrsaldo               FORMAT "-zzz,zzz,zz9.99" AT 91    NO-LABEL
     WITH DOWN WIDTH 132 FRAME f_totvalor CENTERED.



RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

    RUN extrato_cartao_bradesco IN h_b1wgen0028
                            (INPUT par_cdcooper,
                             INPUT par_nrdconta,
                             INPUT par_nrcrcard,
                             INPUT par_dtvctini,
                             INPUT par_dtvctfim,
                            OUTPUT TABLE tt-extrato-cartao,
                            OUTPUT TABLE tt-erro).
DELETE PROCEDURE h_b1wgen0028.


IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        
         IF  AVAIL tt-erro  THEN
            DO:
                BELL.
                MESSAGE tt-erro.dscritic.
            END.

        RETURN "NOK".
    END.


FIND FIRST tt-extrato-cartao NO-LOCK NO-ERROR.

IF NOT AVAIL tt-extrato-cartao THEN DO: 
    MESSAGE "FATURA NAO ENCONTRADA!".
    RETURN  "NOK".
END.


ASSIGN glb_cdrelato[1] = 606
       aux_nmarqimp    = "rl/crrl606.lst"
       tot_vlcrdolr    = 0
       tot_vldbdolr    = 0
       tot_vlcrreal    = 0
       tot_vldbreal    = 0
       tel_dtextrat    = STRING(MONTH(par_dtvctini),"99") + "/" + 
                         STRING(YEAR(par_dtvctini))
       aux_nrcrcard = "****.****.****." + SUBSTR(STRING(par_nrcrcard),LENGTH(STRING(par_nrcrcard)) - 3).

{ includes/cabrel132_1.i }

OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 62.

VIEW STREAM str_1 FRAME f_cabrel132_1.


DISP STREAM str_1 tt-extrato-cartao.nrdconta
                  tt-extrato-cartao.nmprimtl
                  aux_nrcrcard
                  tt-extrato-cartao.vllimite 
                  tt-extrato-cartao.nmtitcrd
                  tel_dtextrat              
                  WITH FRAME f_infrelatorio.
                  DOWN WITH FRAME f_infrelatorio.

FIND crapass WHERE crapass.cdcooper = tt-extrato-cartao.cdcooper   AND
                   crapass.nrdconta = tt-extrato-cartao.nrdconta
             NO-LOCK NO-ERROR.

VIEW STREAM str_1 FRAME f_titrelatorio.

FOR EACH tt-extrato-cartao NO-LOCK
    BY tt-extrato-cartao.dtcompra
    BY tt-extrato-cartao.dsestabe
    BY tt-extrato-cartao.nmcidade:

   IF  tt-extrato-cartao.cdmoedtr = "R$" THEN DO:
       ASSIGN rel_vlcrdolr = 0             
              rel_vldbdolr = 0 .
       
       IF  tt-extrato-cartao.indebcre = "C" THEN 
           ASSIGN rel_vlcrreal = tt-extrato-cartao.vlcparea
                  rel_vldbreal = 0. 
   
       ELSE
           ASSIGN rel_vlcrreal = 0
                  rel_vldbreal = tt-extrato-cartao.vlcparea.
   END.
   ELSE
        
       IF tt-extrato-cartao.indebcre = "C" THEN 
           ASSIGN rel_vlcrreal = tt-extrato-cartao.vlcparea
                  rel_vldbreal = 0
                  rel_vlcrdolr = tt-extrato-cartao.vlcpaori             
                  rel_vldbdolr = 0.
       ELSE
           ASSIGN rel_vlcrreal = 0
                  rel_vldbreal = tt-extrato-cartao.vlcparea
                  rel_vlcrdolr = 0           
                  rel_vldbdolr = tt-extrato-cartao.vlcpaori.


    /***Soma dos valores de credito e debito em real e dolar e o Saldo.***/
    ASSIGN tot_vlcrdolr = tot_vlcrdolr + rel_vlcrdolr
           tot_vldbdolr = tot_vldbdolr + rel_vldbdolr
           tot_vlcrreal = tot_vlcrreal + rel_vlcrreal
           tot_vldbreal = tot_vldbreal + rel_vldbreal
           tot_vlrsaldo = tot_vldbreal - tot_vlcrreal
           tt-extrato-cartao.nmcidade  = SUBSTR(TRIM(tt-extrato-cartao.nmcidade),1,22).
    
    DISP STREAM str_1 tt-extrato-cartao.dtcompra
                      tt-extrato-cartao.dsestabe
                      tt-extrato-cartao.nmcidade
                      rel_vlcrdolr              
                      rel_vldbdolr              
                      rel_vlcrreal              
                      rel_vldbreal 
           WITH FRAME f_detlhextrato.
      DOWN WITH FRAME f_detlhextrato.

END.

    DISP STREAM str_1 tot_vlcrdolr 
                      tot_vldbdolr
                      tot_vlcrreal
                      tot_vldbreal 
                      tot_vlrsaldo
           WITH FRAME f_totvalor.
      DOWN WITH FRAME f_totvalor.

 
OUTPUT STREAM str_1 CLOSE.
       
HIDE MESSAGE NO-PAUSE.

 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   MESSAGE "(T)erminal ou (I)mpressora: " 
           UPDATE tel_cddopcao FORMAT "!(1)".

   IF   tel_cddopcao = "I"   THEN
        DO:
            /* somente para o includes/impressao.i */
            FIND FIRST crapass 
                       WHERE crapass.cdcooper = glb_cdcooper       
                       NO-LOCK NO-ERROR.

            glb_nmformul = "132col".
            
            { includes/impressao.i }
        END.
   ELSE
   IF   tel_cddopcao = "T"   THEN
        RUN fontes/visrel.p (INPUT aux_nmarqimp).
   ELSE
        DO: 
           glb_cdcritic = 14.
           RUN fontes/critic.p.
           BELL.
           MESSAGE glb_dscritic.
           glb_cdcritic = 0.
           NEXT.
        END.            
END.




