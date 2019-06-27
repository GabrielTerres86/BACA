/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL          |
  +------------------------------------------+------------------------------+
  | sistema/generico/includes/b1wgen0188tt.i | EMPR0002                     |
  +------------------------------------------+------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (AILOS)
   - MARCOS MARTINI      (ENVOLTI)

*******************************************************************************/

/*..............................................................................

    Programa: sistema/generico/includes/b1wgen0188tt.i                  
    Autor   : James Prust Junior
    Data    : Julho/2014                     Ultima atualizacao:

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0188.p

   Alteracoes: 16/03/2016 - Adição do campo vllimctr na tt-dados-cpa (Dionathan)
   
               12/02/2018 - P442 - Adição de novos campos para reaproveitamento 
                           (Marcos-Envolti)
..............................................................................*/

DEF TEMP-TABLE tt-dados-cpa NO-UNDO
    FIELD cdcooper LIKE crapepr.cdcooper
    FIELD nrdconta LIKE crapepr.nrdconta
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD idcarga  LIKE crapcpa.iddcarga
    FIELD cdlcremp LIKE crapcpa.cdlcremp
    FIELD vldiscrd AS DECI FORMAT "zzz,zzz,zz9.99-"
    FIELD txmensal AS DECI FORMAT "zzz,zzz,zz9.99-"
    FIELD vllimctr AS DECI FORMAT "zzz,zzz,zz9.99-" 
    FIELD vlcalpar AS DECI FORMAT "zzz,zzz,zz9.99-"
    FIELD flprapol LIKE craplcr.flprapol
    FIELD msgmanua AS CHAR FORMAT "x(1000)".


DEF TEMP-TABLE tt-parcelas-cpa NO-UNDO
    FIELD cdcooper LIKE crapepr.cdcooper
    FIELD nrdconta LIKE crapepr.nrdconta
    FIELD nrctremp LIKE crapepr.nrctremp
    FIELD nrparepr LIKE crappep.nrparepr
    FIELD vlparepr LIKE crappep.vlparepr
    FIELD dtvencto LIKE crappep.dtvencto
    FIELD flgdispo AS LOG INIT TRUE.
/*............................................................................*/
