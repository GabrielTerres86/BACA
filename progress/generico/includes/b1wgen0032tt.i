/*..............................................................................

   Programa: b1wgen0032tt.i                  
   Autor   : Guilherme
   Data    : Agosto/2008                       Ultima atualizacao: 23/07/2015

   Dados referentes ao programa:

   Objetivo  : Temp-tables utlizadas na BO b1wgen0032.p - Cartoes Magneticos

   Alteracoes: 10/09/2008 - Continuar desenvolvimento da BO b1wgen0032 (David).
    
               07/11/2012 - Adicionado campo 'tpusucar' na temp-table
                            'tt-cartoes-magneticos' (Lucas).
               
               23/07/2015 - Remover os campos inrecsaq, dsrecsaq, vlsaqmax e
                            insaqmax. (James)
..............................................................................*/

DEF TEMP-TABLE tt-cartoes-magneticos                                    NO-UNDO
    FIELD nmtitcrd AS CHAR
    FIELD nrcartao AS CHAR
    FIELD dssitcar AS CHAR
    FIELD tpusucar AS INTE.

DEF TEMP-TABLE tt-dados-carmag                                          NO-UNDO
    FIELD nmtitcrd AS CHAR
    FIELD nrcartao AS CHAR
    FIELD nrseqcar AS INTE
    FIELD inpessoa AS INTE
    FIELD dsusucar AS CHAR    
    FIELD dtcancel AS DATE
    FIELD dscarcta AS CHAR
    FIELD cdsitcar AS INTE
    FIELD dssitcar AS CHAR
    FIELD nmoperad AS CHAR
    FIELD dttransa AS DATE
    FIELD hrtransa AS CHAR
    FIELD dtentcrm AS DATE
    FIELD dtemscar AS DATE
    FIELD dtvalcar AS DATE
    FIELD tpusucar AS INTE    
    FIELD tpcarcta AS INTE.   

DEF TEMP-TABLE tt-titular-magnetico                                     NO-UNDO
    FIELD tpusucar AS INTE
    FIELD dsusucar AS CHAR
    FIELD nmtitcrd AS CHAR
    FIELD flusucar AS LOGI.
    
DEF TEMP-TABLE tt-preposto-carmag NO-UNDO
    FIELD nrdctato AS INTE
    FIELD nmdavali AS CHAR
    FIELD nrcpfcgc AS DECI
    FIELD dscpfcgc AS CHAR
    FIELD dsproftl AS CHAR
    FIELD flgatual AS LOGI.

DEF TEMP-TABLE tt-termo-magnetico NO-UNDO
    FIELD nmrescop AS CHAR 
    FIELD nmextcop AS CHAR 
    FIELD nrdocnpj AS CHAR
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD nmoperad AS CHAR
    FIELD nmcidade AS CHAR
    FIELD dsrefere AS CHAR
    FIELD dsmvtolt AS CHAR.

DEF TEMP-TABLE tt-represen-carmag NO-UNDO
    FIELD nrdctato AS INTE
    FIELD nmdavali AS CHAR
    FIELD nrcpfppt AS CHAR
    FIELD cdestcvl AS INTE
    FIELD dsestcvl AS CHAR
    FIELD dsproftl AS CHAR
    FIELD flgprepo AS LOGI
    FIELD dsendere AS CHAR
    FIELD nrendere AS CHAR
    FIELD complend AS CHAR
    FIELD nmbairro AS CHAR
    FIELD nmcidade AS CHAR
    FIELD cdufende AS CHAR.

DEF TEMP-TABLE tt-declar-recebimento NO-UNDO
    FIELD nmrescop AS CHAR
    FIELD nmextcop AS CHAR
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR
    FIELD inpessoa AS INTE
    FIELD nrcartao AS DECI
    FIELD tpcarcta AS INTE    
    FIELD dtvalcar AS DATE
    FIELD dtemscar AS DATE    
    FIELD nmoperad AS CHAR
    FIELD dsmvtolt AS CHAR
    FIELD dsrefere AS CHAR
    FIELD dsparuso AS CHAR
    FIELD dsdnivel AS CHAR.
       
/*............................................................................*/
