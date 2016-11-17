/*..............................................................................

   Programa: b1wgen0076tt.i                  
   Autor   : Guilherme
   Data    : Agosto/2010                  Ultima atualizacao:   /  /    
   Dados referentes ao programa:

   Objetivo  : Temp-tables utlizadas na BO b1wgen0076.p 

   Alteracoes: 
                            
..............................................................................*/
    
DEF TEMP-TABLE arq-header NO-UNDO
    FIELD con-banco           AS INT
    FIELD con-lote            AS INT
    FIELD con-registro        AS INT
    FIELD insc-tipo           AS INT
    FIELD insc-numero         AS CHAR
    FIELD convenio            AS INT   FORMAT '>>>,>>>,>>9'
    FIELD emp-banco           AS CHAR
    FIELD ag-codigo           AS INT
    FIELD ag-dv               AS CHAR
    FIELD cta-numero          AS CHAR
    FIELD cta-dv              AS CHAR
    FIELD ag-ct-dv            AS CHAR
    FIELD nome                AS CHAR 
    FIELD banco               AS CHAR
    FIELD identificador       AS INT 
    FIELD dat-gera            AS CHAR  /*ddmmaaaa*/ 
    FIELD hora-gera           AS CHAR  /*ddmmaaaa*/ 
    FIELD seq                 AS INT 
    FIELD ver-layout          AS INT 
    FIELD densidade           AS INT 
    FIELD reserv-banco        AS CHAR 
    FIELD reserv-emp          AS CHAR 
    FIELD cod-retorno         AS CHAR
    FIELD cod-ocor-retorno    AS CHAR.

DEF TEMP-TABLE arq-header-lote NO-UNDO
    FIELD cont                AS INT
    FIELD con-banco           AS INT
    FIELD con-lote            AS INT
    FIELD con-registro        AS INT
    FIELD s-ope               AS CHAR
    FIELD s-serv              AS INT
    FIELD s-flanc             AS INT
    FIELD ver-layout          AS INT
    FIELD ins-tipo            AS INT
    FIELD ins-numero          AS CHAR
    FIELD e-convenio          AS INT   FORMAT ">>>,>>>,>>9"
    FIELD e-banco             AS CHAR
    FIELD e-agencia           AS INT
    FIELD e-dv-aencia         AS CHAR
    FIELD e-remessa           AS INT
    FIELD ag-codigo           AS INT
    FIELD ag-dv               AS CHAR
    FIELD con-numero          AS INT 
    FIELD con-dv              AS CHAR 
    FIELD ag-ct-dv            AS CHAR
    FIELD e-nome              AS CHAR
    FIELD e-dat-remessa       AS CHAR  /*ddmmaaaa*/
    FIELD num-remessa         AS CHAR
    FIELD c-livre1            AS CHAR
    FIELD inf1                AS CHAR
    FIELD end-logradouro      AS CHAR
    FIELD end-numero          AS CHAR
    FIELD end-complemento     AS CHAR
    FIELD end-cidade          AS CHAR
    FIELD end-cep             AS CHAR
    FIELD end-comp-cep        AS CHAR
    FIELD end-uf              AS CHAR
    FIELD cod-retorno         AS CHAR
    FIELD cod-ocor-retorno    AS CHAR.

DEF TEMP-TABLE arq-det-seg NO-UNDO
    FIELD cont                AS INT
    FIELD con-banco           AS INT
    FIELD con-lote            AS INT
    FIELD con-registro        AS INT
    FIELD s-num-registro      AS INT
    FIELD s-segmento          AS CHAR
    FIELD s-mov-tipo          AS INT
    FIELD s-mov-cod           AS INT
    FIELD c-cmc7              AS CHAR
    FIELD c-cmc7-ori          AS CHAR
    FIELD c-cgc               AS CHAR
    FIELD c-valor             AS DEC
    FIELD dat-bom             AS DATE   /*ddmmaaaa*/
    FIELD campo-livre         AS CHAR
    FIELD banco               AS CHAR
    FIELD v-comp-depositante  AS INT
    FIELD v-banco-rem         AS INT
    FIELD v-ag-rem            AS INT
    FIELD v-ag-dep            AS INT
    FIELD v-num-cta           AS CHAR
    FIELD d-juros             AS DEC
    FIELD d-iof               AS DEC
    FIELD d-outros            AS DEC
    FIELD cod-retorno         AS CHAR
    FIELD cod-ocor-retorno    AS CHAR.

DEF TEMP-TABLE arq-lote NO-UNDO
    FIELD cont                AS INT
    FIELD con-banco           AS INT
    FIELD con-lote            AS INT
    FIELD con-registro        AS INT
    FIELD qtd-reg             AS INT
    FIELD val-cheques         AS DEC
    FIELD qtd-cheques         AS INT
    FIELD tot-d-juros         AS DEC
    FIELD tot-d-iof           AS DEC
    FIELD tot-d-outros        AS DEC
    FIELD re-qtd-processado   AS INT
    FIELD re-val-processado   AS DEC.

DEF TEMP-TABLE arq-trailer NO-UNDO
    FIELD con-banco           AS INT
    FIELD con-lote            AS INT
    FIELD con-registro        AS INT
    FIELD qtd-lote            AS INT
    FIELD qtd-registros       AS INT
    FIELD qtd-cta             AS INT.

DEF TEMP-TABLE tt-retorno NO-UNDO LIKE crapcst
    FIELD c-cmc7-ori          AS CHAR
    FIELD s-num-registro      AS INT
    FIELD lote-cont           AS INT
    FIELD flgderro            AS LOG
    FIELD corrente            AS INT
    INDEX tt-retorno1 AS PRIMARY lote-cont s-num-registro c-cmc7-ori
    INDEX tt-retorno2 flgderro.

DEF TEMP-TABLE tt-erros-arq NO-UNDO
    FIELD nrdolote            AS INT
    FIELD flgderro            AS LOG
    FIELD nrsequen            AS INT
    FIELD dsdoerro            AS CHAR
    FIELD c-cmc7-ori          AS CHAR
    INDEX tt-erros-arq1 nrdolote.
    
/* ......................................................................... */ 
