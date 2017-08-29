/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL          |
  +------------------------------------------+------------------------------+
  | sistema/generico/includes/b1wgen0046tt.i | SSPB0001                     |
  |     tt-situacao-if                       |      typ_tab_situacao_if     |
  +------------------------------------------+------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - DANIEL ZIMMERMANN    (CECRED)

*******************************************************************************/




/*..............................................................................

   Programa: b1wgen0046tt.i                  
   Autor   : David
   Data    : Novembro/2009                     Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0046.p

   Alteracoes: 
                               
..............................................................................*/

DEF TEMP-TABLE tt-situacao-if               NO-UNDO
    FIELD nrispbif AS INTE
    FIELD cdsitope AS INTE
    INDEX tt-situacao-if1 AS PRIMARY nrispbif.

/*............................................................................*/
 