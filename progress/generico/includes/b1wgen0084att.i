/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL          |
  +------------------------------------------+------------------------------+
  | sistema/generico/includes/b1wgen0084att.i| EMPR0001                     |
  +------------------------------------------+------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

*******************************************************************************/





/*..............................................................................

    Programa: sistema/generico/includes/b1wgen0084att.i                  
    Autor   : Irlan
    Data    : Outubro/2012                     Ultima atualizacao: 16/12/2015

    Dados referentes ao programa:

    Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0084a.p

    Alteracoes: 15/01/2013 - Incluido novo campo inliquid (David Kruger).
    
                12/03/2013 - Novo campo para identificacao de anteciapcao
                             (Gabriel)
                             
                11/06/2013 - 2a fase do Projeto do Credito (Gabriel).  
                
                09/06/2014 - Criacao da TEMP-TABLE "tt-dados-aval". (James)
                
                21/01/2015 - Alterado o formato do campo nrctremp para 8 
                             caracters (Kelvin - 233714)
                             
                16/12/2015 - Incluso novo campo nrseqpgo na tt-pagamentos-parcelas
                             (Daniel)
..............................................................................*/

DEFINE TEMP-TABLE tt-pagamentos-parcelas  NO-UNDO
    FIELD cdcooper AS INTE FORMAT "zz,zz9"        
    FIELD nrdconta AS INTE FORMAT "zzzz,zzz,9"    
    FIELD nrctremp AS INTE FORMAT "zz,zzz,zz9"     
    FIELD nrparepr AS INTE FORMAT "zz9"           
    FIELD vlparepr AS DECI FORMAT "zzz,zzz,zz9.99" DECIMALS 2 
    FIELD vljinpar AS DECI FORMAT "zzz,zzz,zz9.99" DECIMALS 2 
    FIELD vlmrapar AS DECI FORMAT "zzz,zzz,zz9.99" DECIMALS 2 
    FIELD vlmtapar AS DECI FORMAT "zzz,zzz,zz9.99" DECIMALS 2 
    FIELD vlmtzepr AS DECI FORMAT "zzz,zzz,zz9.99" DECIMALS 2 
    FIELD dtvencto AS DATE FORMAT "99/99/9999"    
    FIELD dtultpag AS DATE FORMAT "99/99/9999"    
    FIELD vlpagpar AS DECI FORMAT "zzz,zzz,zz9.99" DECIMALS 2 
    FIELD vlpagmta AS DECI FORMAT "zzz,zzz,zz9.99" DECIMALS 2 
    FIELD vlpagmra AS DECI FORMAT "zzz,zzz,zz9.99" DECIMALS 2 
    FIELD indpagto AS INTE FORMAT "9"              
    FIELD txjuremp AS DECI FORMAT "zzz,zz9.99"     DECIMALS 2 
    FIELD vlatupar AS DECI FORMAT "zzz,zzz,zz9.99" DECIMALS 2 
    FIELD vldespar AS DECI FORMAT "zzz,zzz,zz9.99" DECIMALS 2
    FIELD vlatrpag AS DECI                         DECIMALS 2
    FIELD vlsdvpar AS DECI
    FIELD vljinp59 AS DECI
    FIELD vljinp60 AS DECI
    FIELD inliquid AS INTE
    FIELD flgantec AS LOGI
    FIELD nrseqpgo AS INTE. 

DEF TEMP-TABLE tt-calculado NO-UNDO
    FIELD vlsdeved AS DECI
    FIELD vlsderel AS DECI 
    FIELD vlprepag AS DECI
    FIELD vlpreapg AS DECI
    FIELD qtprecal AS DECI
    FIELD vlsdvctr AS DECI.

DEF TEMP-TABLE tt-desconto NO-UNDO
    FIELD nrparepr AS INTE
    FIELD vldespar AS DECI FORMAT "zzz,zzz,zz9.99" DECIMALS 2.

DEF TEMP-TABLE tt-dados-aval NO-UNDO
    FIELD nrseqavl AS INTE
    FIELD nrcpfcgc AS CHAR
    FIELD inpessoa AS INTE
    FIELD nmdavali AS CHAR.
/* ..........................................................................*/
