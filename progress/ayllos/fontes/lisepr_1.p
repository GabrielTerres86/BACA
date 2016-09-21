/* ..........................................................................

   Programa: Fontes/lisepr_1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Junho/2007                         Ultima atualizacao: 20/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a opcao 'T' da tela LISEPR.

   
   Alteracoes: 06/05/2008 - Alterado formato dos campos "Conta/dv", "Valor" e
                            "Saldo" do browser (Elton).
               
               06/05/2009   - Incluir campos "Data da proposta" e "Saldo Medio"
                              (Fernando).
                              
               02/03/2010  - Alteracao feita para tratar cheques e titulos
                             (GATI - Daniel).   
                             
               15/04/2013 - Incluido totalizador  de lancamentos (Daniele).  
               
               20/06/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Lucas R./Gielow).
........................................................................... */

{includes/var_online.i}

DEF TEMP-TABLE tt-emprestimo NO-UNDO
    FIELD cdagenci AS INT      FORMAT "zz9"  
    FIELD nrdconta AS INT      FORMAT "zzzz,zzz,9" 
    FIELD nmprimtl AS CHAR     FORMAT "x(40)"
    FIELD nrctremp AS INT      FORMAT "zzz,zzz,zz9"
    FIELD dtmvtolt AS DATE     FORMAT "99/99/9999"
    FIELD vlemprst AS DECIMAL  FORMAT "zzz,zzz,zzz,zz9"
    FIELD vlsdeved AS DECIMAL  FORMAT "zzz,zzz,zz9"
    FIELD cdlcremp AS INT      FORMAT "zzz9"
    FIELD diaprmed AS INT      FORMAT "zz9"
    FIELD dtmvtprp AS DATE     FORMAT "99/99/9999"
    FIELD dsorigem AS CHAR.

DEF VAR tel_dtinicio AS DATE FORMAT "99/99/9999"    NO-UNDO.
DEF VAR tel_dttermin AS DATE FORMAT "99/99/9999"    NO-UNDO.

DEF INPUT PARAM TABLE FOR tt-emprestimo.
DEF INPUT PARAM par_contador AS INTE NO-UNDO.
DEF INPUT PARAM par_totvlemp AS DECI NO-UNDO.

FORM "Data Inicial:"     AT 5
     tel_dtinicio       HELP "Informe a data inicial da consulta." 
     SPACE(3)                                               
     "Data Final:"  
     tel_dttermin       HELP "Informe a data final da consulta." 
     WITH FRAME f_dados OVERLAY ROW 8 NO-LABEL NO-BOX COLUMN 2.

DEF QUERY q_emprestimo FOR tt-emprestimo.

DEF BROWSE b_emprestimo QUERY q_emprestimo
    DISP tt-emprestimo.cdagenci COLUMN-LABEL "PA"
         tt-emprestimo.nrdconta COLUMN-LABEL "Conta/dv"
         tt-emprestimo.nrctremp COLUMN-LABEL "Contrato"  FORMAT "zzz,zz9" 
         tt-emprestimo.dtmvtolt COLUMN-LABEL "Data Emp"  FORMAT "99/99/9999" 
         tt-emprestimo.vlemprst COLUMN-LABEL "Valor"     FORMAT "z,zzz,zz9.99"
         tt-emprestimo.vlsdeved COLUMN-LABEL "Saldo"     FORMAT "z,zzz,zz9.99-"
         tt-emprestimo.cdlcremp COLUMN-LABEL "Linha"
         WITH 4 DOWN.    

FORM b_emprestimo  HELP "Use as SETAS para navegar ou <F4> para sair." SKIP
                   WITH  NO-BOX CENTERED OVERLAY ROW 10 FRAME f_emprestimo.

FORM tt-emprestimo.nmprimtl LABEL "Nome"         AT 01 SKIP
     tt-emprestimo.dtmvtprp LABEL "Data Prop"    AT 01
     par_contador           LABEL "Qtd. "        AT 35 SKIP
     tt-emprestimo.diaprmed LABEL "Prazo Med"    AT 01
     par_totvlemp           LABEL "Valor TOTAL " AT 35 FORMAT "zzz,zzz,zz9.99" SKIP
     WITH NO-BOX SIDE-LABELS CENTERED OVERLAY ROW 18 FRAME f_nome.
               
ON VALUE-CHANGED OF b_emprestimo
   DO:
       DISPLAY tt-emprestimo.nmprimtl 
               tt-emprestimo.dtmvtprp
               tt-emprestimo.diaprmed 
               WITH FRAME f_nome.

   END.
    
OPEN QUERY q_emprestimo FOR EACH tt-emprestimo.
ENABLE b_emprestimo WITH FRAME f_emprestimo.
PAUSE 0. 
IF AVAILABLE tt-emprestimo THEN
DO:
   DISPLAY tt-emprestimo.nmprimtl 
           par_contador
           tt-emprestimo.dtmvtprp 
           par_totvlemp
           tt-emprestimo.diaprmed
           WITH FRAME f_nome.

END.
  
HIDE MESSAGE NO-PAUSE.   

WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

HIDE FRAME f_emprestimo.
HIDE FRAME f_nome.

