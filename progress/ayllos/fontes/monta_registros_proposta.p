/* ............................................................................

   Programa: fontes/monta_registros_proposta.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Setembro/2010                       Ultima atualizacao: 22/01/2015
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Montar os registros das propostas de credito em variaveis para
               poderem ser passadas por parametro para as BO. 

   Alteracoes: 14/04/2011 - Alterações devido a CEP integrado. Campos
                            nrendere, complend e nrcxapst. (André - DB1)

               26/12/2013 - Preparar a variavel par_dsdalien para BO 0002
                            gravar-alienacao-hipoteca (Guilherme/SUPERO)
                            
               30/07/2014 - Ajuste para dar replace em caracteres que possam 
                            causar erro no ato de construir a string de bens.
                            (Jorge/Gielow) - SD 183551
                            
               22/01/2015 - Adicionado campo dstipbem "Tipo Veiculo".
                            (Jorge/Gielow) - SD 241854                          
.............................................................................*/

{ sistema/generico/includes/b1wgen0002tt.i}
{ sistema/generico/includes/b1wgen0056tt.i }
{ sistema/generico/includes/b1wgen0069tt.i }
  
DEF TEMP-TABLE tt-aval-crapbem                                         NO-UNDO
    LIKE tt-crapbem.

DEF INPUT PARAM TABLE FOR tt-aval-crapbem.                      
DEF INPUT PARAM TABLE FOR tt-faturam.                           
DEF INPUT PARAM TABLE FOR tt-crapbem.                           
DEF INPUT PARAM TABLE FOR tt-bens-alienacao.                             
DEF INPUT PARAM TABLE FOR tt-hipoteca.
DEF INPUT PARAM TABLE FOR tt-interv-anuentes.                              
DEF INPUT PARAM par_tpdrendi  AS INTE EXTENT 6                         NO-UNDO.
DEF INPUT PARAM par_vldrendi  AS DECI EXTENT 6                         NO-UNDO.

DEF OUTPUT PARAM par_dsdbeavt AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM par_dsdfinan AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM par_dsdrendi AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM par_dsdebens AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM par_dsdalien AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM par_dsinterv AS CHAR                                  NO-UNDO.

DEF VAR aux_contador          AS INTE                                  NO-UNDO.
DEF VAR aux_dsrelbem          AS CHAR                                  NO-UNDO.

/* Bens dos avalistas */
IF   TEMP-TABLE tt-aval-crapbem:HAS-RECORDS THEN
     FOR EACH tt-aval-crapbem NO-LOCK:

         ASSIGN aux_dsrelbem = REPLACE(tt-aval-crapbem.dsrelbem,";",",").
         ASSIGN aux_dsrelbem = REPLACE(aux_dsrelbem,"|","-").

         IF   par_dsdbeavt <> "" THEN
              ASSIGN par_dsdbeavt = par_dsdbeavt + "|".

         ASSIGN par_dsdbeavt = par_dsdbeavt + 
                              STRING(tt-aval-crapbem.nrdconta) + ";" +
                              STRING(tt-aval-crapbem.nrcpfcgc) + ";" +
                                                 aux_dsrelbem  + ";" +
                              STRING(tt-aval-crapbem.persemon) + ";" +
                              STRING(tt-aval-crapbem.qtprebem) + ";" +
                              STRING(tt-aval-crapbem.vlprebem) + ";" +
                              STRING(tt-aval-crapbem.vlrdobem) + ";" + 
                              STRING(tt-aval-crapbem.idseqbem).                                  
     END.

/* Faturamento mensal (P. Juridicas) */
IF   TEMP-TABLE tt-faturam:HAS-RECORDS  THEN 
     FOR EACH tt-faturam NO-LOCK:
        
         /* Separar os Registros por '|' e campos por ';' */
         IF   par_dsdfinan <> ""   THEN
              par_dsdfinan = par_dsdfinan + "|".
              
         ASSIGN par_dsdfinan = par_dsdfinan + STRING(tt-faturam.anoftbru) +
                               ";"          + STRING(tt-faturam.mesftbru) +
                               ";"          + STRING(tt-faturam.vlrftbru).     
     END.

/* Juntar os rendimentos  */
DO aux_contador = 1 TO 6:

   IF   par_tpdrendi[aux_contador] = 0   THEN
        NEXT.

   IF   par_dsdrendi <> ""  THEN
        par_dsdrendi = par_dsdrendi + "|". 
                         
   ASSIGN par_dsdrendi = par_dsdrendi + 
                    STRING(par_tpdrendi[aux_contador]) + ";" +
                    STRING(par_vldrendi[aux_contador]).                
END.

ASSIGN aux_dsrelbem = "".

/* Juntar os bens do cooperado */
IF   TEMP-TABLE tt-crapbem:HAS-RECORDS   THEN
     FOR EACH tt-crapbem NO-LOCK:
        
         ASSIGN aux_dsrelbem = REPLACE(tt-crapbem.dsrelbem,";",",").
         ASSIGN aux_dsrelbem = REPLACE(aux_dsrelbem,"|","-").

         IF   par_dsdebens <> ""  THEN
              par_dsdebens = par_dsdebens + "|".
            
          /* Esta montagem tem que ficar no mesmo estilo dos bens dos aval */
          /* Neste caso vai sem CPF apos a conta */
          ASSIGN par_dsdebens = par_dsdebens + 
                                        STRING(tt-crapbem.nrdconta) + ";;" +
                                                      aux_dsrelbem  + ";"  +
                                        STRING(tt-crapbem.persemon) + ";"  +
                                        STRING(tt-crapbem.qtprebem) + ";"  +
                                        STRING(tt-crapbem.vlprebem) + ";"  +
                                        STRING(tt-crapbem.vlrdobem) + ";"  +
                                        STRING(tt-crapbem.idseqbem).                                 
     END.

ASSIGN aux_dsrelbem = "".

/* Bens Alienacao */
IF   TEMP-TABLE tt-bens-alienacao:HAS-RECORDS  THEN 
     FOR EACH tt-bens-alienacao NO-LOCK:

         ASSIGN aux_dsrelbem = REPLACE(tt-bens-alienacao.dsbemfin,";",",").
         ASSIGN aux_dsrelbem = REPLACE(aux_dsrelbem,"|","-").

         IF   par_dsdalien <> ""  THEN
              par_dsdalien = par_dsdalien + "|".
         
         /* Esta variavel é usada na hipoteca tambem */    
         ASSIGN par_dsdalien = par_dsdalien + 
                                  tt-bens-alienacao.dscatbem  + ";" +
                                                aux_dsrelbem  + ";" +
                                  tt-bens-alienacao.dscorbem  + ";" +
                           STRING(tt-bens-alienacao.vlmerbem) + ";" +
                                  tt-bens-alienacao.dschassi  + ";" +
                           STRING(tt-bens-alienacao.nranobem) + ";" + 
                           STRING(tt-bens-alienacao.nrmodbem) + ";" +
                                  tt-bens-alienacao.nrdplaca  + ";" +
                           STRING(tt-bens-alienacao.nrrenava) + ";" +
                           STRING(tt-bens-alienacao.tpchassi) + ";" +
                                  tt-bens-alienacao.ufdplaca  + ";" +
                           STRING(tt-bens-alienacao.nrcpfbem) + ";" +
                                  tt-bens-alienacao.uflicenc  + ";" +
                                  tt-bens-alienacao.dstipbem  + ";" +
                           STRING(tt-bens-alienacao.idseqbem).
     END.

/* Juntar os intervenientes  */
IF   TEMP-TABLE tt-interv-anuentes:HAS-RECORDS  THEN
     FOR EACH tt-interv-anuentes NO-LOCK:
         
         IF   par_dsinterv <> ""  THEN
              par_dsinterv = par_dsinterv + "|". 
                           
         ASSIGN par_dsinterv = par_dsinterv + 
                             STRING(tt-interv-anuentes.nrcpfcgc)   + ";" +
                                    tt-interv-anuentes.nmdavali    + ";" +
                             STRING(tt-interv-anuentes.nrcpfcjg)   + ";" +
                                    tt-interv-anuentes.nmconjug    + ";" +
                                    tt-interv-anuentes.tpdoccjg    + ";" +
                                    tt-interv-anuentes.nrdoccjg    + ";" +
                                    tt-interv-anuentes.tpdocava    + ";" +
                             STRING(tt-interv-anuentes.nrdocava)   + ";" +
                                    tt-interv-anuentes.dsendres[1] + ";" + 
                                    tt-interv-anuentes.dsendres[2] + ";" +
                                    tt-interv-anuentes.nrfonres    + ";" +
                                    tt-interv-anuentes.dsdemail    + ";" +
                                    tt-interv-anuentes.nmcidade    + ";" +
                                    tt-interv-anuentes.cdufresd    + ";" +
                             STRING(tt-interv-anuentes.nrcepend)   + ";" +
                                    tt-interv-anuentes.dsnacion    + ";" +
                             STRING(tt-interv-anuentes.nrendere)   + ";" +
                                    tt-interv-anuentes.complend    + ";" +
                             STRING(tt-interv-anuentes.nrcxapst).
              
     END.

ASSIGN aux_dsrelbem = "".  

/* Bens hipoteca */
IF   TEMP-TABLE tt-hipoteca:HAS-RECORDS THEN
     FOR EACH tt-hipoteca NO-LOCK:
        
         ASSIGN aux_dsrelbem = REPLACE(tt-hipoteca.dsbemfin,";",",").
         ASSIGN aux_dsrelbem = REPLACE(aux_dsrelbem,"|","-").

         IF   par_dsdalien <> ""  THEN
              par_dsdalien = par_dsdalien + "|".

         /* Esta variavel é usada na alienaçao tambem */    
         /* Demais campos nao utilizados, entao colocar soh ; */
         ASSIGN par_dsdalien = par_dsdalien + 
                                  tt-hipoteca.dscatbem  + ";" +
                                          aux_dsrelbem  + ";" +
                                  tt-hipoteca.dscorbem  + ";" +
                           STRING(tt-hipoteca.vlmerbem) +
                                  ";;;;;;;;;;;".
     END.
       
/* .......................................................................... */
