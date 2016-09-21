/*..............................................................................

   Programa: b1wnet0158tt.i                  
   Autor   : Jorge I. Hamaguchi
   Data    : Julho/2013                        Ultima atualizacao: 
   
   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis temp-tables utlizadas na BO b1wnet0158.p

   Alteracoes:
   
..............................................................................*/

DEF TEMP-TABLE tt-blqsnh                                               NO-UNDO
    FIELD cdagenci AS INTE
    FIELD nmresage AS CHAR
    FIELD nrdconta AS DECI
    FIELD idseqttl AS INTE
    FIELD nrcpfope AS DECI
    FIELD nmpessoa AS CHAR
    FIELD dtblutsh AS DATE
    FIELD dtaltsnh AS DATE
    FIELD nrtelefo AS CHAR
    FIELD flgcbloq AS LOGI   /* true - bloqueado false - vai ser */
    FIELD cdtpbloq AS INTE.  /* 1 - Titular 2 - Operador */
