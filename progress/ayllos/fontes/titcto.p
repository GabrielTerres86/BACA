/* .............................................................................

   Programa: Fontes/titcto.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Setembro/2008                   Ultima atualizacao: 13/04/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela titcto - desconto de titulos.

   Alteracoes: 18/02/2008 - D+1 no Saldo contabil opcao "S" (Guilherme).

               12/03/2009 - Acerto no saldo contabil (Guilherme). 
               
               26/03/2009 - Na opcao "S" na baixa sem pagamentos, ignorar
                            os titulos de final de semana na segunda-feira
                            (Guilherme).

               01/04/2009 - Tratar titulos em Desconto pagos via internet como
                            CAIXA cob.indpagto = 3 cob.indpagto = 1
                            Tarefa 23393 - (Evandro/Guilherme).                

               21/05/2009 - Opcao "T"  listar todos os titulos descontados do 
                            cooperado - Tarefa 23461(Guilherme).
                            
               05/08/2009 - Na opcao "T" listar por Aberto, Liquidados, Todos
                            (Guilherme).
                            
               18/09/2009 - Melhoria no controle de fim de semana e feriados
                            na opcao "S" para datas passadas nos titulos
                            baixados sem pagamento (Evandro).
               
               11/06/2010 - Tratamento para pagamento feito atraves de TAA
                            (Elton).
                            
               16/08/2010 - Corrigido calculo do primeiro dia util apos
                            feriado ou fim de semana (Evandro).
                            
               09/02/2011 - Quebrar a clausula or do FOR EACH (Guilherme).
               
               24/08/2012 - Alterações em todas as opções para filtrar consultas
                            por Tipo de Cobrança (Lucas).
                            
               30/10/2012 - Ajuste na rotina de Saldo de Títulos. Considerar
                            pagtos pela compe 085 em D-0 (Rafael).
                            
               08/06/2013 - INTERVENCAO TI - Excesso de leituras na craptdb.
                            Opcao "S" bloqueado temporariamente. (Rafael)
                            
               10/06/2013 - INTERVENCAO TI - Liberado opção "S". (Rafael)
               
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               18/12/2013 - Ajuste processo de leitura crapcob (Daniel).   
               
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

               02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).
							
			   13/04/2016 - Ajustado a tela para que na opcao "S" nao leve em consideracao 
                            a data de vencimento para computar o saldo e sim a data de debito
                            conforme solicitado no chamado 432131. (Kelvin)    
                           
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0030tt.i }

DEF BUFFER crabass FOR crapass.
DEF VAR h-browse   AS HANDLE                                   NO-UNDO.

DEF VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"            NO-UNDO.
DEF VAR tel_nrcpfcgc AS DEC     FORMAT "zzzzzzzzzzzzz9"        NO-UNDO.
DEF VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"                 NO-UNDO.
DEF VAR tel_dtvencto AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF VAR tel_dtiniper AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF VAR tel_dtfimper AS DATE    FORMAT "99/99/9999"            NO-UNDO.

DEF VAR tel_cdagenci AS INT     FORMAT "zz9"                   NO-UNDO.

DEF VAR res_qtderesg AS INT     FORMAT "zzz,zz9-"              NO-UNDO.
DEF VAR res_qttitulo AS INT     FORMAT "zzz,zz9"               NO-UNDO.
DEF VAR res_qtcredit AS INT     FORMAT "zzz,zz9-"              NO-UNDO.
DEF VAR res_qtsldant AS INT     FORMAT "zzz,zz9-"              NO-UNDO.
DEF VAR res_qtvencid AS INT     FORMAT "zzz,zz9-"              NO-UNDO.
DEF VAR res_qtdpagto AS INTE    FORMAT "zzz,zz9-"              NO-UNDO.

DEF VAR res_vldpagto AS DECIMAL FORMAT "zzz,zzz,zz9.99-"       NO-UNDO.
DEF VAR res_vlderesg AS DECIMAL FORMAT "zzz,zzz,zz9.99-"       NO-UNDO.
DEF VAR res_vltitulo AS DECIMAL FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF VAR res_vlcredit AS DECIMAL FORMAT "zzz,zzz,zz9.99-"       NO-UNDO.
DEF VAR res_vlsldant AS DECIMAL FORMAT "zzz,zzz,zz9.99-"       NO-UNDO.
DEF VAR res_vlvencid AS DECIMAL FORMAT "zzz,zzz,zz9.99-"       NO-UNDO.

DEF VAR aux_contador AS INT     FORMAT "99"                    NO-UNDO.
DEF VAR aux_stimeout AS INT                                    NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                   NO-UNDO.
DEF VAR aux_confirma AS CHAR    FORMAT "!"                     NO-UNDO.
DEF VAR aux_dtvenct1 AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF VAR aux_dtvenct2 AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF VAR vlr_pgdepois AS DECIMAL FORMAT "zzz,zzz,zz9.99-"       NO-UNDO.
DEF VAR vlr_rgdepois AS DECIMAL FORMAT "zzz,zzz,zz9.99-"       NO-UNDO.
DEF VAR vlr_bxdepois AS DECIMAL FORMAT "zzz,zzz,zz9.99-"       NO-UNDO.
DEF VAR vlr_liberado AS DECIMAL FORMAT "zzz,zzz,zz9.99-"       NO-UNDO.
DEF VAR vlr_saldo    AS DECIMAL FORMAT "zzz,zzz,zz9.99-"       NO-UNDO.
DEF VAR qtd_pgdepois AS INTEGER                                NO-UNDO.
DEF VAR qtd_rgdepois AS INTEGER                                NO-UNDO.
DEF VAR qtd_bxdepois AS INTEGER                                NO-UNDO.
DEF VAR qtd_liberado AS INTEGER                                NO-UNDO.
DEF VAR qtd_saldo    AS INTEGER                                NO-UNDO.

DEF VAR aux_imprimir AS LOGICAL FORMAT "I/T" INIT FALSE NO-UNDO.
DEF VAR aux_resgatad AS LOGICAL FORMAT "S/N" INIT FALSE NO-UNDO.
DEF VAR aux_bscsacad AS LOGICAL              INIT FALSE NO-UNDO.
DEF VAR aux_arqvazio AS LOGICAL                         NO-UNDO.
DEF VAR aux_notfound AS LOGICAL                         NO-UNDO.

DEF VAR tel_nrdocmto AS INTE                             NO-UNDO.
DEF VAR tel_vltitulo AS DECIMAL                          NO-UNDO.
DEF VAR aux_dsoperad AS CHAR                             NO-UNDO.
DEF VAR rel_tpcobran AS CHAR FORMAT "X(12)"              NO-UNDO.
DEF VAR tel_tpcobran AS CHAR FORMAT "X(12)" INIT "TODOS" NO-UNDO.
DEF VAR aux_tpcobran AS CHAR                             NO-UNDO.
DEF VAR aux_diffdias AS INTE                             NO-UNDO.

/* variaveis para includes/cabrel080_1.i  e  includes/cabrel132_1.i*/
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                       NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5              NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                           NO-UNDO.
DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                       NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["","","","",""]         NO-UNDO.
DEF VAR rel_nmarqimp AS CHAR                                         NO-UNDO.

/* variaveis para impressao */
DEF VAR aux_nmarqimp AS CHAR                                        NO-UNDO.
DEF VAR aux_nmendter AS CHAR    FORMAT "x(20)"                      NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL INIT TRUE                           NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                     NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                        NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                           NO-UNDO.
DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"       NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"       NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                     NO-UNDO.
DEF VAR aux_dtrefere AS DATE                                        NO-UNDO.
DEF VAR aux_dtmvtoan AS DATE                                        NO-UNDO.
DEF VAR tel_tpdepesq AS CHAR    FORMAT "x(10)" INIT "Todos" VIEW-AS
                                COMBO-BOX LIST-ITEMS "Todos",
                                                     "Abertos",
                                                     "Liquidados"   NO-UNDO.
DEF TEMP-TABLE w_titulos NO-UNDO
    FIELD dtlibbdt LIKE craptdb.dtlibbdt
    FIELD nrborder LIKE craptdb.nrborder
    FIELD dtvencto LIKE craptdb.dtvencto
    FIELD cdbandoc LIKE craptdb.cdbandoc
    FIELD nrcnvcob LIKE craptdb.nrcnvcob
    FIELD nrdocmto LIKE craptdb.nrdocmto
    FIELD vltitulo LIKE craptdb.vltitulo
    FIELD dtderesg LIKE craptdb.dtresgat
    FIELD dsoperes AS CHAR
    FIELD nrdconta LIKE craptdb.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD cdagenci LIKE crapbdt.nrdolote
    FIELD cdbccxlt LIKE crapbdt.cdbccxlt
    FIELD nrdolote LIKE crapbdt.nrdolote
    FIELD tpcobran AS CHAR FORMAT "X(11)".

DEF STREAM str_1. /* do arquivo para fazer impressao da consulta */

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_tpdepesq LABEL "Sit" AUTO-RETURN
                  HELP  "Use as <SETAS> p/ selecionar o tipo da pesquisa."
     tel_nrdocmto LABEL "Boleto" FORMAT "zzz,zz9"
     tel_vltitulo LABEL "Valor"  FORMAT "zzz,zzz,zz9.99"
     WITH ROW 7 COLUMN 3 SIDE-LABELS OVERLAY NO-BOX FRAME f_seltodos.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
         HELP "Informe (C)ons, (F)echam, (L)otes, (S)aldo, (T)pesq ou (Q)uem."
         VALIDATE(CAN-DO("C,F,L,S,T,Q",glb_cddopcao),"014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_titcto.

FORM tel_tpcobran AT 2 LABEL "Tipo de cobranca" FORMAT "X(12)"
                       HELP "'R' Cobranca Registrada, 'S' Cobranca S/ Registro, 'T' Todos."
                       VALIDATE(CAN-DO("SEM REGISTRO,REGISTRADA,TODOS",tel_tpcobran),
                                 "014 - Opcao errada.")                                
     WITH ROW 8 COLUMN 2 SIDE-LABELS NO-BOX OVERLAY FRAME f_tpcobran.


FORM tel_nrdconta AT 1  LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta do associado"
     tel_nmprimtl AT 25 NO-LABEL
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_conta.
     
FORM tel_nrdconta AT 1  LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta do associado."
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_favorecido.

FORM tel_nrcpfcgc AT 1  LABEL "CPF/CNPJ"  AUTO-RETURN
                        HELP "Informe o numero do CPF/CNPJ do pagador."
     WITH ROW 6 COLUMN 39 SIDE-LABELS OVERLAY NO-BOX FRAME f_cpf/cgc.          

FORM tel_nmprimtl AT 1  LABEL "Titular"
     WITH ROW 7 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_titular.
     
FORM "Liberado"          AT 01
     "Vencto  "          AT 10
     "Bco"               AT 19
     "  Convenio"        AT 23
     "Tipo Cobr. "       AT 34
     "Boleto "           AT 47
     "Bordero "          AT 55
     "         Valor"    AT 65
     "Resgate "          AT 80
     "Operador  "        AT 89

     "--------"          AT 01
     "--------"          AT 10
     "---"               AT 19
     "----------"        AT 23
     "-----------"       AT 34
     "-------"           AT 47
     "---------"         AT 55
     "--------------"    AT 65
     "--------"          AT 80
     "---------------"   AT 89
     WITH WIDTH 108 CENTERED OVERLAY NO-LABEL NO-BOX FRAME f_label.
     
FORM SKIP(2)
     "      QUANTIDADE TOTAL: " res_qttitulo
     SPACE(10)
     "VALOR TOTAL: " res_vltitulo
     WITH WIDTH 84 CENTERED OVERLAY NO-LABEL NO-BOX FRAME f_total.
         
FORM craptdb.dtlibbdt AT 01 FORMAT "99/99/99"
     craptdb.dtvencto AT 10 FORMAT "99/99/99"
     craptdb.cdbandoc AT 19 FORMAT "zz9"
     craptdb.nrcnvcob AT 23 FORMAT "zz,zzz,zz9"
     rel_tpcobran     AT 34 FORMAT "X(12)"
     craptdb.nrdocmto AT 47 FORMAT "zzz,zz9"
     craptdb.nrborder AT 55 FORMAT "z,zzz,zz9"
     craptdb.vltitulo AT 65 FORMAT "zzz,zzz,zz9.99"
     craptdb.dtresgat AT 80 FORMAT "99/99/99"
     aux_dsoperad     AT 89 FORMAT "x(15)"
     WITH WIDTH 132 CENTERED OVERLAY NO-LABEL NO-BOX FRAME f_tits.

FORM tel_dtvencto AT 20 LABEL "Vencimento para"
     SKIP(1)
     "Qtd.           Valor" AT 41
     SKIP(1)
     res_qttitulo AT 18 LABEL "Titulos Recebidos"
     res_vltitulo AT 47 NO-LABEL
     res_qtderesg AT 17 LABEL "Titulos Resgatados"
     res_vlderesg AT 47 NO-LABEL
     res_qtdpagto AT 22 LABEL "Titulos Pagos"
     res_vldpagto AT 47 NO-LABEL
     SKIP(1)
     res_qtcredit AT 20 LABEL "Valor a LIBERAR"
     res_vlcredit AT 47 NO-LABEL     
     SKIP(1)
     WITH ROW 10 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_fechamento.

FORM tel_dtvencto AT 20 LABEL "Saldo Contabil em"
     SKIP(1)
     "Qtd.           Valor" AT 41
     SKIP(1)
     res_qtsldant AT 21 LABEL "Saldo Anterior"
     res_vlsldant AT 47 NO-LABEL
     res_qttitulo AT 18 LABEL "Titulos Recebidos"
     res_vltitulo AT 47 NO-LABEL
     res_qtvencid AT 17 LABEL "Vencimentos no dia"
     res_vlvencid AT 47 NO-LABEL
     res_qtderesg AT 17 LABEL "Titulos Resgatados"
     res_vlderesg AT 47 NO-LABEL
     SKIP(1)
     res_qtcredit AT 24 LABEL "SALDO ATUAL"
     res_vlcredit AT 47 NO-LABEL
     SKIP(1)
     WITH ROW 10 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_contabilidade.

FORM tel_dtmvtolt AT 1 LABEL "Listar os lotes do dia"
     tel_cdagenci      LABEL "    PA"
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_movto.

FORM "  A G U A R D E ...  " 
     WITH ROW 10 CENTERED OVERLAY FRAME f_aguarde.

DEF QUERY q_titulos  FOR w_titulos.
DEF QUERY q_titulos2 FOR w_titulos.
DEF QUERY q_titulosq FOR w_titulos.

DEF BROWSE b_titulos QUERY q_titulos
    DISP w_titulos.dtlibbdt COLUMN-LABEL "Liberado"    FORMAT "99/99/99"
         w_titulos.dtvencto COLUMN-LABEL "Vencto"      FORMAT "99/99/99"
         w_titulos.nrcnvcob COLUMN-LABEL "Convenio"   
         w_titulos.tpcobran COLUMN-LABEL "Tipo Cobr."
         w_titulos.cdbandoc COLUMN-LABEL "Bco"         FORMAT "zz9"
         w_titulos.nrdocmto COLUMN-LABEL "Boleto"     
         w_titulos.nrborder COLUMN-LABEL "Bordero"     
         w_titulos.vltitulo COLUMN-LABEL "Valor"       FORMAT "z,zzz,zz9.99"
         w_titulos.dtderesg COLUMN-LABEL "Resgate"     FORMAT "99/99/99"
         w_titulos.dsoperes COLUMN-LABEL "Operador"    FORMAT "x(10)"
         w_titulos.nrdconta COLUMN-LABEL "Desctdo por"
         w_titulos.nmprimtl COLUMN-LABEL "Nome"
    WITH 8 DOWN NO-BOX WITH WIDTH 76.
    
DEF BROWSE b_titulosq QUERY q_titulosq
    DISP w_titulos.dtlibbdt COLUMN-LABEL "Liberado"    FORMAT "99/99/99"
         w_titulos.dtvencto COLUMN-LABEL "Vencto"      FORMAT "99/99/99"
         w_titulos.nrcnvcob COLUMN-LABEL "Convenio"   
         w_titulos.tpcobran COLUMN-LABEL "Tipo Cobr."
         w_titulos.cdbandoc COLUMN-LABEL "Bco"         FORMAT "zz9"
         w_titulos.nrdocmto COLUMN-LABEL "Boleto"     
         w_titulos.nrborder COLUMN-LABEL "Bordero"     FORMAT "z,zzz,zz9"
         w_titulos.vltitulo COLUMN-LABEL "Valor"       FORMAT "z,zzz,zz9.99"
         w_titulos.nrdconta COLUMN-LABEL "Desctdo por"
         w_titulos.nmprimtl COLUMN-LABEL "Nome"
    WITH 9 DOWN NO-BOX WITH WIDTH 76.    

FORM b_titulos HELP "Utilize as SETAS para navegar / F4 ou END para sair."
     WITH ROW 11 COLUMN 2 OVERLAY NO-BOX CENTERED FRAME f_browse.
     
FORM b_titulosq HELP "Utilize as SETAS para navegar / F4 ou END para sair."
     WITH ROW 10 COLUMN 2 OVERLAY NO-BOX CENTERED FRAME f_browseq.     
     
DEF BROWSE b_titulos2 QUERY q_titulos2
    DISP w_titulos.dtlibbdt COLUMN-LABEL "Liberado"  FORMAT "99/99/99"
         w_titulos.cdagenci COLUMN-LABEL "PA"        FORMAT "zz9"
         w_titulos.cdbccxlt COLUMN-LABEL "Bc/Cx"     FORMAT "zz9"
         w_titulos.nrdolote COLUMN-LABEL "Lote"      FORMAT "zzz,zz9"
         w_titulos.dtvencto COLUMN-LABEL "Vencto"    FORMAT "99/99/99"
         w_titulos.cdbandoc COLUMN-LABEL "Bco"       FORMAT "zz9"
         w_titulos.nrcnvcob COLUMN-LABEL "Convenio"
         w_titulos.tpcobran COLUMN-LABEL "Tipo Cobr."
         w_titulos.nrdocmto COLUMN-LABEL "Boleto" 
         w_titulos.vltitulo COLUMN-LABEL "Valor"     FORMAT "z,zzz,zz9.99"
    WITH 9 DOWN NO-BOX WITH WIDTH 76.

FORM b_titulos2 HELP "Utilize as SETAS para navegar / F4 ou END para sair."
     WITH ROW 10 COLUMN 2 OVERLAY NO-BOX CENTERED FRAME f_browse2.

FORM HEADER   glb_nmrescop               AT   1 FORMAT "x(15)"
              "-"                        AT  16
              "Opcao Consulta"           AT  18 
              "- REF."                   AT  55
              glb_dtmvtolt               AT  65 FORMAT "99/99/99"
              "TITCTO/"                  AT  86
              glb_progerad               AT  94 FORMAT "x(03)"
              "EM"                       AT  98
              TODAY                      AT 101 FORMAT "99/99/99"
              "AS"                       AT 110
              STRING(TIME,"HH:MM")       AT 113 FORMAT "x(5)"
              "HR PAG.:"                 AT 119
              PAGE-NUMBER(str_1)         AT 127 FORMAT "zzzz9"
              SKIP(2)
            "Consulta de titulos descontados que nao foram pagos" AT 37
            "---------------------------------------------------" AT 37
            WITH PAGE-TOP NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_cabecalho.

ON  RETURN OF tel_tpdepesq DO:
    APPLY "TAB".
END.

ON  VALUE-CHANGED OF tel_tpcobran IN FRAME f_tpcobran
    DO:
        IF  FRAME-VALUE = "s" OR
            FRAME-VALUE = "S" THEN
            ASSIGN tel_tpcobran = "SEM REGISTRO"
                   aux_tpcobran = "S".
          
        IF  FRAME-VALUE = "r" OR 
            FRAME-VALUE = "R" THEN
            ASSIGN tel_tpcobran = "REGISTRADA"
                   aux_tpcobran = "R".
          
        IF  FRAME-VALUE = "t" OR
            FRAME-VALUE = "T" THEN
            ASSIGN tel_tpcobran = "TODOS"
                   aux_tpcobran = "T".
                            
        DISPLAY tel_tpcobran WITH FRAME f_tpcobran.
        NEXT-PROMPT tel_tpcobran WITH FRAME f_tpcobran.
    END.

FUNCTION isFeriadoFds RETURN LOGICAL(INPUT par_data AS DATE):

    IF  CAN-DO("1,7",STRING(WEEKDAY(par_data)))   OR
        CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper AND
                               crapfer.dtferiad = par_data)   THEN
        RETURN TRUE.
    ELSE
        RETURN FALSE.

END FUNCTION.

FUNCTION dia_util_anterior RETURNS DATE(INPUT par_data AS DATE):

    /* Retorna dia util anterior */
       
    DEF VAR tmp_utilante    AS DATE                         NO-UNDO.
    
    /* Pega o ultimo dia util */
    tmp_utilante = par_data - 1.
    
    DO  WHILE TRUE:

        IF   WEEKDAY(tmp_utilante) = 1   OR
             WEEKDAY(tmp_utilante) = 7   THEN
             DO:
                tmp_utilante = tmp_utilante - 1.
                NEXT.
             END.
                                    
        FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper   AND
                           crapfer.dtferiad = tmp_utilante
                           NO-LOCK NO-ERROR.
                                                            
        IF   AVAILABLE crapfer   THEN
             DO:
                tmp_utilante = tmp_utilante - 1.
                NEXT.
             END.

        LEAVE.
    END.  /*  Fim do DO WHILE TRUE  */
    
    RETURN tmp_utilante.

END FUNCTION.

FUNCTION calcula_data RETURNS DATE(INPUT par_data AS DATE):

    /* 
       No caso de feriado ou fim de semana, a data de vencimento eh postergada
       para o proximo dia util, exemplo:
       
       Vencimento do Titulo: 01/01/09 (feriado)
       
       No dia 02/01/09 o titulo esta vencido mas ainda pode ser pago sem
       problemas, entao o mesmo somente pode ser debitado do Beneficiário no
       processo do dia 03/01/09
    */
       
    DEF VAR tmp_dtrefere    AS DATE                         NO-UNDO.
    DEF VAR tmp_utilante    AS DATE                         NO-UNDO.
    
    /* Pega o ultimo dia util */
    tmp_utilante = dia_util_anterior(par_data).
    
    /* Pega o ultimo dia util */
    tmp_dtrefere = dia_util_anterior(tmp_utilante).
    
    /* Se teve fim de semana ou feriado */
    IF  tmp_utilante - tmp_dtrefere > 1  THEN
        RETURN tmp_dtrefere.
    ELSE
        RETURN tmp_utilante.

END FUNCTION.

FUNCTION calc_dia_util_ao_ant RETURNS DATE(INPUT par_data AS DATE):

    /* 
        Calcular o dia anterior a data de ontem
        - Usada para lancar liquidacao de titulo recebido para desconto
        com D+1 pois os titulos do BB sao D+1.
    */
       
    DEF VAR tmp_dtrefere    AS DATE                         NO-UNDO.

    
    /* Pega o ultimo dia util antes de ontem */
    tmp_dtrefere = par_data - 1.
    
    DO  WHILE TRUE:

        IF   WEEKDAY(tmp_dtrefere) = 1   OR
             WEEKDAY(tmp_dtrefere) = 7   THEN
             DO:
                tmp_dtrefere = tmp_dtrefere - 1.
                NEXT.
             END.
                                    
        FIND crapfer WHERE crapfer.cdcooper = glb_cdcooper AND
                           crapfer.dtferiad = tmp_dtrefere
                           NO-LOCK NO-ERROR.
                                                            
        IF   AVAILABLE crapfer   THEN
             DO:
                tmp_dtrefere = tmp_dtrefere - 1.
                NEXT.
             END.

        LEAVE.
    END.  /*  Fim do DO WHILE TRUE  */
    
    RETURN tmp_dtrefere.

END FUNCTION.  

VIEW FRAME f_moldura.

PAUSE (0).

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_dtvencto = ?.

/*  Acessa dados da cooperativa  */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         RETURN.
     END.

DO WHILE TRUE:

   RUN fontes/inicia.p.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      HIDE FRAME f_movto.
      HIDE FRAME f_label.
      HIDE FRAME f_fechamento.
      HIDE FRAME f_contabilidade.
      HIDE FRAME f_conta.
      HIDE FRAME f_favorecido.
      HIDE FRAME f_seltodos.
      HIDE FRAME f_cpf/cgc.
      HIDE FRAME f_titular.
      HIDE FRAME f_tpcobran.
      
      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_titcto NO-PAUSE.
               glb_cdcritic = 0.
           END.
           
      EMPTY TEMP-TABLE w_titulos.
      
      UPDATE glb_cddopcao WITH FRAME f_titcto.
            
      IF   NOT CAN-DO("L,S,C",glb_cddopcao)  THEN
           DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                  IF   glb_cdcritic > 0   THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           CLEAR FRAME f_conta       NO-PAUSE.
                           ASSIGN glb_cdcritic =0.
                       END.
                  
                  UPDATE tel_nrdconta WITH FRAME f_conta.
                  
                  IF   tel_nrdconta = 0   THEN
                       DO:
                           ASSIGN tel_nmprimtl = "  ** FECHAMENTO **".
                           LEAVE.
                       END.

                  ASSIGN glb_nrcalcul = tel_nrdconta.
                  
                  RUN fontes/digfun.p.
                  
                  IF   NOT glb_stsnrcal   THEN
                       DO:
                           glb_cdcritic = 8.
                           NEXT.
                       END.

                  FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                     crapass.nrdconta = tel_nrdconta
                                     NO-LOCK NO-ERROR.
                                     
                  IF   NOT AVAILABLE crapass   THEN
                       DO:
                           ASSIGN glb_cdcritic = 9.
                           NEXT.
                       END.
                       
                  ASSIGN tel_nmprimtl = crapass.nmprimtl.
                  
                  LEAVE.
               
               END. /* Fim do DO WHILE */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    DO:
                        HIDE FRAME f_conta.
                        NEXT.
                    END.
                    
               DISPLAY tel_nmprimtl WITH FRAME f_conta.
               
           END.
           
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "titcto"   THEN
                 DO:
                     HIDE FRAME f_titcto.
                     HIDE FRAME f_conta.
                     HIDE FRAME f_favorecido.
                     HIDE FRAME f_cpg/cgc.
                     HIDE FRAME f_titular.
                     HIDE FRAME f_label.
                     HIDE FRAME f_moldura.
                     HIDE FRAME f_fechamento.
                     HIDE FRAME f_contabilidade.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

    IF  glb_cddopcao = "C" THEN
        DO:
            DO WHILE TRUE:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   
                   ASSIGN aux_bscsacad = FALSE.
            
                   IF   glb_cdcritic > 0   THEN
                        DO:
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            CLEAR FRAME f_favorecido  NO-PAUSE.
                            CLEAR FRAME f_cpf/cgc     NO-PAUSE.
                            CLEAR FRAME f_titular     NO-PAUSE.
                            glb_cdcritic = 0.
                        END.
                      
                   UPDATE tel_nrdconta WITH FRAME f_favorecido.
                   
                   IF   tel_nrdconta = 0   THEN
                        DO:
                            ASSIGN aux_bscsacad = TRUE.
                            LEAVE.
                        END.
            
                   glb_nrcalcul = tel_nrdconta.
            
                   RUN fontes/digfun.p.
            
                   IF   NOT glb_stsnrcal   THEN
                        DO:
                            glb_cdcritic = 8.
                            NEXT.
                        END.
                             
                    FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                       crapass.nrdconta = tel_nrdconta 
                                       NO-LOCK NO-ERROR.
            
                    IF   NOT AVAILABLE crapass   THEN
                         DO:
                             glb_cdcritic = 9.
                             NEXT.
                         END.
                                  
                    ASSIGN tel_nmprimtl = crapass.nmprimtl
                           tel_nrcpfcgc = 0.
                            
                    DISPLAY tel_nmprimtl WITH FRAME f_titular.
                   
                    ASSIGN aux_contador = 0
                           aux_resgatad = FALSE
                           aux_imprimir = FALSE.
            
                    UPDATE tel_tpcobran WITH FRAME f_tpcobran.

                    MESSAGE "Deseja listar os resgatados ?"
                            UPDATE aux_resgatad.
                
                    MESSAGE "Informe 'T' p/ visualizar ou 'I' " +
                            "p/ imprimir o relatorio: "
                            UPDATE aux_imprimir.

                    IF FRAME-VALUE =  "T" THEN
                        ASSIGN aux_imprimir = FALSE.
                    ELSE
                        ASSIGN aux_imprimir = TRUE.
            
                    IF  NOT aux_imprimir  THEN /* Terminal */
                        DO:
                            IF  aux_resgatad  THEN
                                FOR EACH craptdb 
                                   WHERE (craptdb.cdcooper = crapass.cdcooper AND
                                          craptdb.insittit = 4                AND 
                                          craptdb.nrdconta = crapass.nrdconta) OR
                                         (craptdb.cdcooper = crapass.cdcooper AND
                                          craptdb.insittit = 1                AND
                                          craptdb.nrdconta = crapass.nrdconta)
                                         NO-LOCK,
                                EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                  crapcob.cdbandoc = craptdb.cdbandoc AND
                                  crapcob.nrdctabb = craptdb.nrdctabb AND
                                  crapcob.nrdconta = craptdb.nrdconta AND
                                  crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                  crapcob.nrdocmto = craptdb.nrdocmto AND
                                 (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                 (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK
                                  BY crapcob.flgregis DESC
                                  BY crapcob.cdbandoc DESC
                                  BY crapass.nrdconta:
            
                                    FIND FIRST crapope 
                                     WHERE crapope.cdcooper = craptdb.cdcooper AND
                                           crapope.cdoperad = craptdb.cdoperes 
                                           NO-LOCK NO-ERROR.
                                       
                                    IF  NOT AVAIL crapope  THEN    
                                        aux_dsoperad = "".
                                    ELSE
                                        aux_dsoperad = crapope.cdoperad + "-" +
                                                       crapope.nmoperad.
                                               
                                    FIND FIRST crapass WHERE 
                                               crapass.cdcooper = craptdb.cdcooper
                                           AND crapass.nrdconta = craptdb.nrdconta
                                           NO-LOCK NO-ERROR.
                                    
                                    CREATE w_titulos.
                                    ASSIGN w_titulos.dtlibbdt = craptdb.dtlibbdt
                                           w_titulos.dtvencto = craptdb.dtvencto
                                           w_titulos.nrborder = craptdb.nrborder
                                           w_titulos.cdbandoc = craptdb.cdbandoc
                                           w_titulos.nrcnvcob = craptdb.nrcnvcob
                                           w_titulos.nrdocmto = craptdb.nrdocmto
                                           w_titulos.vltitulo = craptdb.vltitulo
                                           w_titulos.dtderesg = craptdb.dtresgat
                                           w_titulos.dsoperes = aux_dsoperad
                                           w_titulos.nrdconta = craptdb.nrdconta
                                           w_titulos.nmprimtl = crapass.nmprimt 
                                                                WHEN AVAIL crapass
                                           w_titulos.tpcobran = IF  crapcob.flgregis = TRUE  AND
                                                                    crapcob.cdbandoc = 085  THEN
                                                                    "Coop. Emite"
                                                                ELSE 
                                                                IF  crapcob.flgregis = TRUE  AND
                                                                    crapcob.cdbandoc <> 085 THEN 
                                                                   "Banco Emite"
                                                                ELSE
                                                                IF  crapcob.flgregis = FALSE THEN 
                                                                    "S/registro"
                                                                ELSE
                                                                    " ".
            
                                END.                 
                            ELSE
                                FOR EACH craptdb 
                                   WHERE craptdb.cdcooper = crapass.cdcooper AND
                                         craptdb.insittit = 4                AND 
                                         craptdb.nrdconta = crapass.nrdconta
                                         NO-LOCK,
                                EACH crapcob 
                                    WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                          crapcob.cdbandoc = craptdb.cdbandoc AND
                                          crapcob.nrdctabb = craptdb.nrdctabb AND 
                                          crapcob.nrdconta = craptdb.nrdconta AND
                                          crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                          crapcob.nrdocmto = craptdb.nrdocmto AND
                                         (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                         (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK
                                          BY crapcob.flgregis DESC
                                          BY crapcob.cdbandoc DESC
                                          BY crapass.nrdconta:
                                         
                                    FIND FIRST crapass WHERE 
                                               crapass.cdcooper = craptdb.cdcooper
                                           AND crapass.nrdconta = craptdb.nrdconta
                                           NO-LOCK NO-ERROR.
                                    
                                    CREATE w_titulos.
                                    ASSIGN w_titulos.dtlibbdt = craptdb.dtlibbdt
                                           w_titulos.dtvencto = craptdb.dtvencto
                                           w_titulos.nrborder = craptdb.nrborder
                                           w_titulos.cdbandoc = craptdb.cdbandoc
                                           w_titulos.nrcnvcob = craptdb.nrcnvcob
                                           w_titulos.nrdocmto = craptdb.nrdocmto
                                           w_titulos.vltitulo = craptdb.vltitulo
                                           w_titulos.nrdconta = craptdb.nrdconta
                                           w_titulos.nmprimtl = crapass.nmprimtl 
                                                                WHEN AVAIL crapass
                                           w_titulos.tpcobran = IF  crapcob.flgregis = TRUE  AND
                                                                    crapcob.cdbandoc = 085  THEN
                                                                    "Coop. Emite"
                                                                ELSE 
                                                                IF  crapcob.flgregis = TRUE  AND
                                                                    crapcob.cdbandoc <> 085 THEN 
                                                                   "Banco Emite"
                                                                ELSE
                                                                IF  crapcob.flgregis = FALSE THEN 
                                                                    "S/registro"
                                                                ELSE
                                                                    " ".
                                END.
                            
                            CLOSE QUERY q_titulos. 
                        
                            OPEN QUERY q_titulos FOR EACH w_titulos.
            
                            IF  QUERY q_titulos:NUM-RESULTS = 0  THEN
                                DO:
                                    MESSAGE "Nao ha registros para listar.".
                                    BELL.
                                    NEXT.
                                END.
                        
                            ENABLE b_titulos WITH FRAME f_browse.
                            
                            WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                
                            HIDE FRAME f_browse. 
                        
                            HIDE MESSAGE NO-PAUSE.                    
                        END.
                    ELSE
                        DO:
                            INPUT THROUGH basename `tty` NO-ECHO.
            
                            SET aux_nmendter WITH FRAME f_terminal.
            
                            INPUT CLOSE.
                            
                            aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                                  aux_nmendter.
                        
                            UNIX SILENT VALUE("rm rl/" + aux_nmendter + 
                                              "* 2> /dev/null").
            
                            ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + 
                                                  STRING(TIME) + ".ex"
                                   glb_cdempres = 11
                                   glb_nrdevias = 1
                                   glb_nmformul = "132col".
            
                           OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 84.
            
                           VIEW STREAM str_1 FRAME f_cabecalho.

                           IF  NOT aux_resgatad  THEN
                               FOR  EACH craptdb 
                                   WHERE craptdb.cdcooper = crapass.cdcooper AND
                                         craptdb.insittit = 4                AND
                                         craptdb.nrdconta = crapass.nrdconta 
                                         NO-LOCK,
                               EACH crapcob 
                                    WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                          crapcob.cdbandoc = craptdb.cdbandoc AND
                                          crapcob.nrdctabb = craptdb.nrdctabb AND
                                          crapcob.nrdconta = craptdb.nrdconta AND
                                          crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                          crapcob.nrdocmto = craptdb.nrdocmto AND
                                         (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                         (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK
                                          BREAK BY craptdb.nrdconta
                                                BY crapcob.flgregis DESC
                                                BY crapcob.cdbandoc DESC:
                       
                                   IF  FIRST-OF(craptdb.nrdconta)  THEN
                                       DO:
                                           DISPLAY STREAM str_1 SKIP 
                                            "Conta/dv:" crapass.nrdconta NO-LABEL
                                            "-" crapass.nmprimtl NO-LABEL.
                                           DISPLAY STREAM str_1 SKIP(1).     
                                           VIEW STREAM str_1 FRAME f_label.
                                       END.
                           
                                   ASSIGN aux_arqvazio = FALSE
                                          res_qttitulo = res_qttitulo + 1
                                          res_vltitulo = res_vltitulo + 
                                                         craptdb.vltitulo
                                          rel_tpcobran = IF  crapcob.flgregis = TRUE  AND
                                                             crapcob.cdbandoc = 085  THEN
                                                             "Coop. Emite"
                                                         ELSE 
                                                         IF  crapcob.flgregis = TRUE  AND
                                                             crapcob.cdbandoc <> 085 THEN 
                                                            "Banco Emite"
                                                         ELSE
                                                         IF  crapcob.flgregis = FALSE THEN 
                                                             "S/registro"
                                                         ELSE
                                                             " ".
            
                                   DISPLAY STREAM str_1 craptdb.dtlibbdt
                                                        craptdb.dtvencto 
                                                        craptdb.cdbandoc 
                                                        craptdb.nrcnvcob
                                                        craptdb.nrdocmto
                                                        craptdb.nrborder
                                                        craptdb.vltitulo
                                                        rel_tpcobran
                                                        WITH FRAME f_tits.
                
                                   DOWN STREAM str_1 WITH FRAME f_tits.
            
                                   IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1) THEN
                                        DO:
                                            PAGE STREAM str_1.
                                            VIEW STREAM str_1 FRAME f_label.
                                        END.
                                        
                               END. /* Fim do FOR EACH */
                           ELSE
                               FOR  EACH craptdb 
                                   WHERE (craptdb.cdcooper = crapass.cdcooper AND
                                          craptdb.insittit = 4                AND 
                                          craptdb.nrdconta = crapass.nrdconta) OR
                                         (craptdb.cdcooper = crapass.cdcooper AND
                                          craptdb.insittit = 1                AND
                                          craptdb.nrdconta = crapass.nrdconta)
                                         NO-LOCK,
                                   EACH crapcob 
                                    WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                          crapcob.cdbandoc = craptdb.cdbandoc AND
                                          crapcob.nrdctabb = craptdb.nrdctabb AND
                                          crapcob.nrdconta = craptdb.nrdconta AND
                                          crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                          crapcob.nrdocmto = craptdb.nrdocmto AND
                                         (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                         (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK
                                          BREAK BY craptdb.nrdconta
                                                BY crapcob.flgregis DESC
                                                BY crapcob.cdbandoc DESC:
                       
                                   IF  FIRST-OF(craptdb.nrdconta)  THEN
                                       DO:
                                           DISPLAY STREAM str_1 SKIP
                                            "Conta/dv:" crapass.nrdconta NO-LABEL
                                                "-" crapass.nmprimtl NO-LABEL.
                                           DISPLAY STREAM str_1 SKIP(1).     
                                           VIEW STREAM str_1 FRAME f_label.
                                       END.
                                    
                                   FIND FIRST crapope 
                                     WHERE crapope.cdcooper = craptdb.cdcooper AND
                                           crapope.cdoperad = craptdb.cdoperes 
                                           NO-LOCK NO-ERROR.
                                       
                                   IF  NOT AVAIL crapope  THEN    
                                       aux_dsoperad = "".
                                   ELSE
                                       aux_dsoperad = crapope.cdoperad + "-" +
                                                      crapope.nmoperad.
                               
                                   ASSIGN aux_arqvazio = FALSE
                                          res_qttitulo = res_qttitulo + 1
                                          res_vltitulo = res_vltitulo + 
                                                         craptdb.vltitulo
                                          rel_tpcobran = IF  crapcob.flgregis = TRUE  AND
                                                             crapcob.cdbandoc = 085  THEN
                                                             "Coop. Emite"
                                                         ELSE 
                                                         IF  crapcob.flgregis = TRUE  AND
                                                             crapcob.cdbandoc <> 085 THEN 
                                                            "Banco Emite"
                                                         ELSE
                                                         IF  crapcob.flgregis = FALSE THEN 
                                                             "S/registro"
                                                         ELSE
                                                             " ".
            
                                   DISPLAY STREAM str_1 craptdb.dtlibbdt
                                                        craptdb.dtvencto 
                                                        craptdb.cdbandoc
                                                        craptdb.nrcnvcob
                                                        craptdb.nrdocmto 
                                                        craptdb.nrborder
                                                        craptdb.vltitulo 
                                                        craptdb.dtresgat 
                                                        aux_dsoperad
                                                        rel_tpcobran
                                                        WITH FRAME f_tits.
                
                                   DOWN STREAM str_1 WITH FRAME f_tits.
            
                                   IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1) THEN
                                        DO:
                                            PAGE STREAM str_1.
                                            VIEW STREAM str_1 FRAME f_label.
                                        END.
            
                               END. /* Fim do FOR EACH */                   
                        
                           DISPLAY STREAM str_1 
                                        res_qttitulo 
                                        res_vltitulo
                                        WITH FRAME f_total.
            
                           ASSIGN res_qttitulo = 0
                                  res_vltitulo = 0.
                           
                           OUTPUT STREAM str_1 CLOSE.                    
                       
                           IF  aux_arqvazio  THEN
                               DO:
                                   MESSAGE "Nao ha registros para listar.".
                                   BELL.
                                   NEXT.
                               END.
                       
                            RUN imprime.                
                        END.
                   
                    LEAVE.
                   
                END.  /*  Fim do DO WHILE TRUE  */
            
                IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   
                     DO:
                         HIDE FRAME f_favorecido.
                         DISABLE b_titulos WITH FRAME f_browse.
                         HIDE FRAME f_browse.                     
                         LEAVE.
                     END.
            
                IF  aux_bscsacad  THEN
                    DO:
                        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            UPDATE tel_nrcpfcgc WITH FRAME f_cpf/cgc.
            
                            ASSIGN aux_notfound = FALSE.
                            
                            IF  tel_nrcpfcgc = 0 THEN
                                DO:
                                    ASSIGN aux_notfound = TRUE.
                                    LEAVE.
                                END.
            
                            LEAVE.
                        END.
                        
                        IF  aux_notfound  THEN
                            LEAVE.
                        
                        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   
                             DO:
                                 HIDE FRAME f_favorecido.
                                 DISABLE b_titulos WITH FRAME f_browse.
                                 HIDE FRAME f_browse.                     
                                 NEXT.
                             END.
                             
                        IF  NOT CAN-FIND(FIRST crapsab WHERE 
                                   crapsab.cdcooper = glb_cdcooper AND
                                   crapsab.nrinssac = tel_nrcpfcgc 
                                   NO-LOCK) THEN
                            DO:       
                                MESSAGE "Nao existe titulos gerados para este CPF.".
                                NEXT.
                            END.
                            
                        ASSIGN aux_resgatad = FALSE
                               aux_imprimir = FALSE.
                               
                        MESSAGE "Deseja listar os resgatados ?"
                                UPDATE aux_resgatad.
                
                        MESSAGE "Informe 'T' p/ visualizar ou 'I' " +
                                "p/ imprimir o relatorio: "
                                UPDATE aux_imprimir.            

                        IF FRAME-VALUE =  "T" THEN
                            ASSIGN aux_imprimir = FALSE.
                        ELSE
                            ASSIGN aux_imprimir = TRUE.
            
                        ASSIGN aux_arqvazio = TRUE.
                                            
                        IF  NOT aux_imprimir  THEN /* Terminal */
                            DO:
                                IF  aux_resgatad  THEN                        
                                    FOR EACH crapsab WHERE
                                             crapsab.cdcooper = glb_cdcooper AND
                                             crapsab.nrinssac = tel_nrcpfcgc
                                             NO-LOCK,
                                        EACH crapcob WHERE 
                                             crapcob.cdcooper = glb_cdcooper     AND
                                             crapcob.nrinssac = crapsab.nrinssac AND
                                             crapcob.nrdconta = crapsab.nrdconta AND
                                            (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                            (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) 
                                             NO-LOCK, 
                                        EACH craptdb WHERE
                                            (craptdb.cdcooper = crapcob.cdcooper AND
                                             craptdb.cdbandoc = crapcob.cdbandoc AND
                                             craptdb.nrdctabb = crapcob.nrdctabb AND
                                             craptdb.nrcnvcob = crapcob.nrcnvcob AND
                                             craptdb.nrdconta = crapcob.nrdconta AND
                                             craptdb.nrdocmto = crapcob.nrdocmto AND
                                             craptdb.insittit = 1) OR
                                            (craptdb.cdcooper = crapcob.cdcooper AND
                                             craptdb.cdbandoc = crapcob.cdbandoc AND
                                             craptdb.nrdctabb = crapcob.nrdctabb AND
                                             craptdb.nrcnvcob = crapcob.nrcnvcob AND
                                             craptdb.nrdconta = crapcob.nrdconta AND
                                             craptdb.nrdocmto = crapcob.nrdocmto AND
                                             craptdb.insittit = 4) NO-LOCK
                                             BY crapcob.flgregis DESC
                                             BY crapcob.cdbandoc DESC
                                             BY craptdb.nrdconta:
                            
                                        ASSIGN aux_arqvazio = FALSE.
                                        
                                        FIND FIRST crapope WHERE
                                             crapope.cdcooper = craptdb.cdcooper AND
                                             crapope.cdoperad = craptdb.cdoperes 
                                             NO-LOCK NO-ERROR.
                                       
                                        IF  NOT AVAIL crapope  THEN    
                                            aux_dsoperad = "".
                                        ELSE
                                            aux_dsoperad = crapope.cdoperad + "-" +
                                                           crapope.nmoperad.
                                               
                                        FIND FIRST crapass WHERE 
                                               crapass.cdcooper = craptdb.cdcooper
                                           AND crapass.nrdconta = craptdb.nrdconta
                                           NO-LOCK NO-ERROR.
                                        
                                        CREATE w_titulos.
                                        ASSIGN w_titulos.dtlibbdt = craptdb.dtlibbdt
                                               w_titulos.dtvencto = craptdb.dtvencto
                                               w_titulos.nrborder = craptdb.nrborder
                                               w_titulos.cdbandoc = craptdb.cdbandoc
                                               w_titulos.nrcnvcob = craptdb.nrcnvcob
                                               w_titulos.nrdocmto = craptdb.nrdocmto
                                               w_titulos.vltitulo = craptdb.vltitulo
                                               w_titulos.dtderesg = craptdb.dtresgat
                                               w_titulos.dsoperes = aux_dsoperad
                                               w_titulos.nrdconta = craptdb.nrdconta
                                               w_titulos.nmprimtl = crapass.nmprimtl
                                                                 WHEN AVAIL crapass
                                               w_titulos.tpcobran = IF  crapcob.flgregis = TRUE  AND
                                                                        crapcob.cdbandoc = 085  THEN
                                                                        "Coop. Emite"
                                                                    ELSE 
                                                                    IF  crapcob.flgregis = TRUE  AND
                                                                        crapcob.cdbandoc <> 085 THEN 
                                                                       "Banco Emite"
                                                                    ELSE
                                                                    IF  crapcob.flgregis = FALSE THEN 
                                                                        "S/registro"
                                                                    ELSE
                                                                        " ".
                                    END.         
                                ELSE
                                    FOR EACH crapsab WHERE
                                             crapsab.cdcooper = glb_cdcooper AND
                                             crapsab.nrinssac = tel_nrcpfcgc 
                                             NO-LOCK,
                                        EACH crapcob WHERE 
                                             crapcob.cdcooper = glb_cdcooper     AND
                                             crapcob.nrinssac = crapsab.nrinssac AND
                                             crapcob.nrdconta = crapsab.nrdconta AND
                                            (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                            (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) 
                                             NO-LOCK, 
                                        EACH craptdb WHERE
                                             craptdb.cdcooper = crapcob.cdcooper AND
                                             craptdb.cdbandoc = crapcob.cdbandoc AND
                                             craptdb.nrdctabb = crapcob.nrdctabb AND
                                             craptdb.nrcnvcob = crapcob.nrcnvcob AND
                                             craptdb.nrdconta = crapcob.nrdconta AND
                                             craptdb.nrdocmto = crapcob.nrdocmto AND
                                             craptdb.insittit = 4
                                             NO-LOCK
                                             BY crapcob.flgregis DESC
                                             BY crapcob.cdbandoc DESC
                                             BY craptdb.nrdconta:
                            
                                        ASSIGN aux_arqvazio = FALSE.    
                                        
                                        FIND FIRST crapass WHERE 
                                               crapass.cdcooper = craptdb.cdcooper
                                           AND crapass.nrdconta = craptdb.nrdconta
                                           NO-LOCK NO-ERROR.
                                        
                                        CREATE w_titulos.
                                        ASSIGN w_titulos.dtlibbdt = craptdb.dtlibbdt
                                               w_titulos.dtvencto = craptdb.dtvencto
                                               w_titulos.nrborder = craptdb.nrborder
                                               w_titulos.cdbandoc = craptdb.cdbandoc
                                               w_titulos.nrcnvcob = craptdb.nrcnvcob
                                               w_titulos.nrdocmto = craptdb.nrdocmto
                                               w_titulos.vltitulo = craptdb.vltitulo
                                               w_titulos.nrdconta = craptdb.nrdconta
                                               w_titulos.nmprimtl = crapass.nmprimtl
                                                                WHEN AVAIL crapass
                                               w_titulos.tpcobran = IF  crapcob.flgregis = TRUE  AND
                                                                        crapcob.cdbandoc = 085  THEN
                                                                        "Coop. Emite"
                                                                    ELSE 
                                                                    IF  crapcob.flgregis = TRUE  AND
                                                                        crapcob.cdbandoc <> 085 THEN 
                                                                       "Banco Emite"
                                                                    ELSE
                                                                    IF  crapcob.flgregis = FALSE THEN 
                                                                        "S/registro"
                                                                    ELSE
                                                                        " ".
                                    END.
            
                                CLOSE QUERY q_titulos. 
                        
                                OPEN QUERY q_titulos FOR EACH w_titulos.
            
                                IF  QUERY q_titulos:NUM-RESULTS = 0  THEN
                                    DO:
                                        MESSAGE "Nao ha registros para listar.".
                                        HIDE tel_nrcpfcgc IN FRAME f_cpf/cgc.
                                        BELL.
                                        NEXT.
                                    END.
                        
                                ENABLE b_titulos WITH FRAME f_browse.
                            
                                WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                
                                HIDE FRAME f_browse. 
                        
                                HIDE MESSAGE NO-PAUSE.
                            END.                    
                        ELSE
                            DO:
                                INPUT THROUGH basename `tty` NO-ECHO.
            
                                SET aux_nmendter WITH FRAME f_terminal.
            
                                INPUT CLOSE.     
                                
                                aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                                      aux_nmendter.
                        
                                UNIX SILENT VALUE("rm rl/" + aux_nmendter + 
                                                  "* 2> /dev/null").
            
                                ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + 
                                                       STRING(TIME) + ".ex"
                                       glb_cdempres = 11
                                       glb_nrdevias = 1
                                       glb_nmformul = "132col".
            
                                OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) 
                                        PAGE-SIZE 84.
            
                                VIEW STREAM str_1 FRAME f_cabecalho.
                       
                                IF  NOT aux_resgatad  THEN
                                    FOR EACH crapsab WHERE 
                                             crapsab.cdcooper = glb_cdcooper AND
                                             crapsab.nrinssac = tel_nrcpfcgc
                                             NO-LOCK,
                                        EACH crapcob WHERE 
                                             crapcob.cdcooper = glb_cdcooper     AND
                                             crapcob.nrinssac = crapsab.nrinssac AND
                                             crapcob.nrdconta = crapsab.nrdconta AND
                                            (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                            (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) 
                                             NO-LOCK,
                                        EACH craptdb WHERE
                                             craptdb.cdcooper = crapcob.cdcooper AND
                                             craptdb.cdbandoc = crapcob.cdbandoc AND
                                             craptdb.nrdctabb = crapcob.nrdctabb AND
                                             craptdb.nrcnvcob = crapcob.nrcnvcob AND
                                             craptdb.nrdconta = crapcob.nrdconta AND
                                             craptdb.nrdocmto = crapcob.nrdocmto AND
                                             craptdb.insittit = 4  
                                             NO-LOCK
                                             BREAK BY crapcob.nrdconta
                                                   BY crapcob.flgregis DESC
                                                   BY crapcob.cdbandoc DESC:
            
                                        IF  FIRST-OF(crapcob.nrdconta)  THEN
                                            DO:
                                             FIND FIRST crapass WHERE 
                                             crapass.cdcooper = crapcob.cdcooper AND
                                             crapass.nrdconta = crapcob.nrdconta
                                             NO-LOCK NO-ERROR.
                                           
                                             IF  NOT AVAIL crapass  THEN
                                                 DO:
                                                    DISPLAY STREAM str_1 SKIP
                                               "Conta/dv:" crapcob.nrdconta NO-LABEL
                                               "- ERRO! Conta inexistente" NO-LABEL.
                                                    DISPLAY STREAM str_1 SKIP(1).
                                                    VIEW STREAM str_1 FRAME f_label.
                                                 END.    
                                            ELSE 
                                                DO:   
                                                    DISPLAY STREAM str_1 SKIP
                                               "Conta/dv:" crapass.nrdconta NO-LABEL
                                               "-" crapass.nmprimtl NO-LABEL.
                                                   DISPLAY STREAM str_1 SKIP(1). 
                                                   VIEW STREAM str_1 FRAME f_label.
                                                END.    
                                            END.
                                
                                        ASSIGN aux_arqvazio = FALSE
                                               res_qttitulo = res_qttitulo + 1
                                               res_vltitulo = res_vltitulo + 
                                                              craptdb.vltitulo
                                               rel_tpcobran = IF  crapcob.flgregis = TRUE  AND
                                                                  crapcob.cdbandoc = 085  THEN
                                                                  "Coop. Emite"
                                                              ELSE 
                                                              IF  crapcob.flgregis = TRUE  AND
                                                                  crapcob.cdbandoc <> 085 THEN 
                                                                 "Banco Emite"
                                                              ELSE
                                                              IF  crapcob.flgregis = FALSE THEN 
                                                                  "S/registro"
                                                              ELSE
                                                                  " ".
            
                                        DISPLAY STREAM str_1 craptdb.dtlibbdt
                                                             craptdb.dtvencto 
                                                             craptdb.cdbandoc 
                                                             craptdb.nrcnvcob
                                                             craptdb.nrdocmto
                                                             craptdb.nrborder
                                                             craptdb.vltitulo 
                                                             rel_tpcobran
                                                             WITH FRAME f_tits.
                
                                        DOWN STREAM str_1 WITH FRAME f_tits.
            
                                       IF   LINE-COUNTER(str_1) >= 
                                            PAGE-SIZE(str_1) THEN
                                            DO:
                                                 PAGE STREAM str_1.
                                                 VIEW STREAM str_1 FRAME f_label.
                                             END.                                
            
                                    END.
                                ELSE       
                                    FOR EACH crapsab WHERE 
                                             crapsab.cdcooper = glb_cdcooper AND
                                             crapsab.nrinssac = tel_nrcpfcgc
                                             NO-LOCK,
                                        EACH crapcob WHERE 
                                             crapcob.cdcooper = glb_cdcooper     AND
                                             crapcob.nrinssac = crapsab.nrinssac AND
                                             crapcob.nrdconta = crapsab.nrdconta AND
                                            (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                            (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) 
                                             NO-LOCK,
                                        EACH craptdb WHERE
                                            (craptdb.cdcooper = crapcob.cdcooper AND
                                             craptdb.cdbandoc = crapcob.cdbandoc AND
                                             craptdb.nrdctabb = crapcob.nrdctabb AND
                                             craptdb.nrcnvcob = crapcob.nrcnvcob AND
                                             craptdb.nrdconta = crapcob.nrdconta AND
                                             craptdb.nrdocmto = crapcob.nrdocmto AND
                                             craptdb.insittit = 4) OR
                                            (craptdb.cdcooper = crapcob.cdcooper AND
                                             craptdb.cdbandoc = crapcob.cdbandoc AND
                                             craptdb.nrdctabb = crapcob.nrdctabb AND
                                             craptdb.nrcnvcob = crapcob.nrcnvcob AND
                                             craptdb.nrdconta = crapcob.nrdconta AND
                                             craptdb.nrdocmto = crapcob.nrdocmto AND
                                             craptdb.insittit = 1) 
                                             NO-LOCK
                                             BREAK BY crapcob.nrdconta
                                                   BY crapcob.flgregis DESC
                                                   BY crapcob.cdbandoc DESC:
            
                                        IF  FIRST-OF(crapcob.nrdconta)  THEN
                                            DO:
                                                FIND FIRST crapass WHERE 
                                                           crapass.cdcooper = 
                                                             crapcob.cdcooper AND
                                                           crapass.nrdconta = 
                                                             crapcob.nrdconta
                                                           NO-LOCK NO-ERROR.
                                           
                                                IF  NOT AVAIL crapass  THEN
                                                    DO:
                                                    DISPLAY STREAM str_1 SKIP
                                               "Conta/dv:" crapcob.nrdconta NO-LABEL
                                               "- ERRO! Conta inexistente" NO-LABEL.
                                                    DISPLAY STREAM str_1 SKIP(1).
                                                    VIEW STREAM str_1 FRAME f_label.
                                                    END.    
                                                ELSE 
                                                DO:   
                                                DISPLAY STREAM str_1 SKIP
                                               "Conta/dv:" crapass.nrdconta NO-LABEL
                                               "-" crapass.nmprimtl NO-LABEL.
                                                DISPLAY STREAM str_1 SKIP(1).     
                                                VIEW STREAM str_1 FRAME f_label.
                                                END.    
                                            END.
                                        
                                        FIND FIRST crapope WHERE
                                           crapope.cdcooper = craptdb.cdcooper AND
                                           crapope.cdoperad = craptdb.cdoperes 
                                           NO-LOCK NO-ERROR.
                                       
                                        IF  NOT AVAIL crapope  THEN    
                                            aux_dsoperad = "".
                                        ELSE
                                            aux_dsoperad = crapope.cdoperad + "-" +
                                                           crapope.nmoperad.
                                
                                        ASSIGN aux_arqvazio = FALSE
                                               res_qttitulo = res_qttitulo + 1
                                               res_vltitulo = res_vltitulo + 
                                                              craptdb.vltitulo
                                               rel_tpcobran = IF  crapcob.flgregis = TRUE  AND
                                                                  crapcob.cdbandoc = 085  THEN
                                                                  "Coop. Emite"
                                                              ELSE 
                                                              IF  crapcob.flgregis = TRUE  AND
                                                                  crapcob.cdbandoc <> 085 THEN 
                                                                 "Banco Emite"
                                                              ELSE
                                                              IF  crapcob.flgregis = FALSE THEN 
                                                                  "S/registro"
                                                              ELSE
                                                                  " ".
            
                                        DISPLAY STREAM str_1 craptdb.dtlibbdt
                                                             craptdb.dtvencto 
                                                             craptdb.cdbandoc 
                                                             craptdb.nrcnvcob
                                                             craptdb.nrdocmto 
                                                             craptdb.nrborder
                                                             craptdb.vltitulo 
                                                             craptdb.dtresgat
                                                             aux_dsoperad
                                                             rel_tpcobran
                                                             WITH FRAME f_tits.
                
                                        DOWN STREAM str_1 WITH FRAME f_tits.
            
                                        IF   LINE-COUNTER(str_1) >= 
                                             PAGE-SIZE(str_1) THEN
                                             DO:
                                                 PAGE STREAM str_1.
                                                 VIEW STREAM str_1 FRAME f_label.
                                             END.                                
            
                                    END.
                                
                                DISPLAY STREAM str_1 
                                        res_qttitulo
                                        res_vltitulo
                                        WITH FRAME f_total.
            
                                ASSIGN res_qttitulo = 0
                                       res_vltitulo = 0.
                                
                                OUTPUT STREAM str_1 CLOSE.                    
                       
                                IF  aux_arqvazio  THEN
                                    DO:
                                        MESSAGE "Nao ha registros para listar.".
                                        BELL.
                                        NEXT.
                                    END.
                                RUN imprime.     
                            END.
                    END. /* final da busca por Pagador */
                LEAVE.    
                
            END.    /* Do while true */
        END.  /* glb_cdcopcao = C */
   ELSE
   IF   glb_cddopcao = "F"   THEN  /*  FECHAMENTO PARA A CONTA  */
        DO:
            tel_dtvencto = glb_dtmvtopr.
            
            CLEAR FRAME f_fechamento NO-PAUSE.
            
            DO WHILE TRUE:
            
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  UPDATE tel_tpcobran WITH FRAME f_tpcobran.
             
                  UPDATE tel_dtvencto 
                         HELP "Informe data especifica ou ? para saber o total"
                         WITH FRAME f_fechamento.

                  LEAVE.
            
               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    LEAVE.
                 
               VIEW FRAME f_aguarde.
               
               RUN proc_datas.

               RUN proc_fechamento (INPUT aux_tpcobran).
               
               HIDE FRAME f_aguarde NO-PAUSE.        
                       
               ASSIGN res_qtcredit = res_qttitulo - res_qtderesg - res_qtdpagto
                      res_vlcredit = res_vltitulo - res_vlderesg - res_vldpagto.
               
               DISPLAY tel_dtvencto 
                       res_qttitulo res_vltitulo
                       res_qtderesg res_vlderesg
                       res_vldpagto res_qtdpagto
                       res_qtcredit res_vlcredit
                       WITH FRAME f_fechamento.
               
            END.  /*  Fim do DO WHILE TRUE  */
        END.
   ELSE 
   IF   glb_cddopcao = "L"   THEN   /*  Relatorio de lotes */
        DO:
            ASSIGN tel_dtmvtolt = glb_dtmvtolt
                   tel_cdagenci = 0.
        
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               UPDATE tel_dtmvtolt tel_cdagenci WITH FRAME f_movto.
               
               RUN fontes/titcto_lote.p (INPUT tel_dtmvtolt,
                                         INPUT tel_cdagenci).
            
            END.  /*  Fim do DO WHILE TRUE  */
         
            HIDE FRAME f_movto.
        END.
   ELSE
   IF   glb_cddopcao = "S"   THEN    /*  SALDO EM DESCTO  */
        DO: 
           tel_dtvencto = glb_dtmvtolt.

           CLEAR FRAME f_contabilidade NO-PAUSE.

           DO WHILE TRUE:
            
              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                 UPDATE tel_tpcobran WITH FRAME f_tpcobran.
                 UPDATE tel_dtvencto WITH FRAME f_contabilidade.

                 IF   tel_dtvencto = ?   THEN
                      tel_dtvencto = glb_dtmvtolt.
                      
                 IF   tel_dtvencto > glb_dtmvtolt   THEN
                      DO:
                          glb_cdcritic = 13.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          CLEAR FRAME f_contabilidade NO-PAUSE.
                          glb_cdcritic = 0.
                          NEXT.
                      END.
               
                 LEAVE.
            
              END.  /*  Fim do DO WHILE TRUE  */

              IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                   LEAVE.
                 
              ASSIGN res_qtderesg = 0
                     res_vlderesg = 0
                     res_qtsldant = 0
                     res_vlsldant = 0
                     res_qtvencid = 0
                     res_vlvencid = 0
                     res_qttitulo = 0
                     res_vltitulo = 0
                     
                     vlr_pgdepois = 0
                     vlr_rgdepois = 0
                     vlr_bxdepois = 0
                     vlr_saldo    = 0
                     vlr_liberado = 0
                     qtd_pgdepois = 0
                     qtd_rgdepois = 0
                     qtd_bxdepois = 0
                     qtd_saldo    = 0
                     qtd_liberado = 0.

              IF   tel_dtvencto = ?   THEN
                   tel_dtvencto = glb_dtmvtolt.
               
              RUN proc_datas.

              VIEW FRAME f_aguarde.

              /* Resgatados no dia */
              FOR EACH craptdb WHERE craptdb.cdcooper = glb_cdcooper AND
                                     craptdb.insittit = 1            AND
                                     craptdb.dtresgat = tel_dtvencto
                                     NO-LOCK,
                  EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                     crapcob.cdbandoc = craptdb.cdbandoc AND
                                     crapcob.nrdctabb = craptdb.nrdctabb AND
                                     crapcob.nrdconta = craptdb.nrdconta AND
                                     crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                     crapcob.nrdocmto = craptdb.nrdocmto AND
                                    (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                    (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK:
                                     
                  ASSIGN res_qtderesg = res_qtderesg - 1
                         res_vlderesg = res_vlderesg - craptdb.vltitulo.
              END.
              
              ASSIGN aux_dtrefere = calcula_data(tel_dtvencto)
                     aux_dtmvtoan = dia_util_anterior(tel_dtvencto).

              /* Baixados sem pagamento no dia */                     
              FOR EACH craptdb WHERE craptdb.cdcooper  = glb_cdcooper   AND
                                     craptdb.dtdebito = tel_dtvencto    AND
                                     craptdb.insittit  = 3              
                                     NO-LOCK USE-INDEX craptdb2,
                  EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                     crapcob.cdbandoc = craptdb.cdbandoc AND
                                     crapcob.nrdctabb = craptdb.nrdctabb AND
                                     crapcob.nrdconta = craptdb.nrdconta AND
                                     crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                     crapcob.nrdocmto = craptdb.nrdocmto AND
                                    (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                    (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK:

                  /* No caso de fim de semana e feriado, nao pega os titulos
                     que ja foram pegos no dia anterior a ontem */
                  IF  aux_dtrefere     <> aux_dtmvtoan   AND
                      craptdb.dtvencto  = aux_dtrefere   THEN
                      NEXT.                       

                  /* Nao contabilizar os titulos que vencem no final de semana
                     ou feriado no primeiro dia util seguinte, por causa da
                     postergacao de data */
                  IF  (CAN-DO("1,7",STRING(WEEKDAY(craptdb.dtvencto))) OR
                       CAN-FIND(crapfer WHERE
                                crapfer.cdcooper = glb_cdcooper AND
                                crapfer.dtferiad = craptdb.dtvencto))       AND
                      /* primeiro dia util seguinte */
                      (tel_dtvencto - aux_dtrefere > 1  AND
                       tel_dtvencto - aux_dtmvtoan > 1)                     THEN 
                      NEXT.
                       
                  ASSIGN res_qtvencid = res_qtvencid - 1
                         res_vlvencid = res_vlvencid - craptdb.vltitulo.
                                                
              END.

              /* Pagos pelo Pagador - via COMPE... */                 
              aux_dtrefere = dia_util_anterior(aux_dtmvtoan).

              FOR EACH craptdb WHERE craptdb.cdcooper  = glb_cdcooper   AND
                                     craptdb.dtdpagto  > aux_dtrefere   AND
                                     craptdb.dtdpagto <= aux_dtmvtoan   AND
                                     craptdb.insittit  = 2
                                     NO-LOCK USE-INDEX craptdb2,
                  EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                     crapcob.cdbandoc = craptdb.cdbandoc AND
                                     crapcob.nrdconta = craptdb.nrdconta AND
                                     crapcob.nrdctabb = craptdb.nrdctabb AND
                                     crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                     crapcob.nrdocmto = craptdb.nrdocmto AND
                                    (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                    (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK:
 
                  /* Pago pela COMPE */
                  /* apenas para titulos do BB */
                  IF  crapcob.indpagto = 0 AND 
                      crapcob.cdbandoc = 001 THEN
                      DO:
                         ASSIGN res_qtvencid = res_qtvencid - 1
                                res_vlvencid = res_vlvencid - craptdb.vltitulo.
                      END.
         
              END. /* Fim do FOR EACH craptdb */


              /* Pagos pelo Pagador - via CAIXA... */
              FOR EACH craptdb WHERE craptdb.cdcooper  = glb_cdcooper   AND
                                     craptdb.dtdpagto  > aux_dtmvtoan   AND
                                     craptdb.dtdpagto <= tel_dtvencto   AND
                                     craptdb.insittit  = 2
                                     NO-LOCK USE-INDEX craptdb2,
                  EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                     crapcob.cdbandoc = craptdb.cdbandoc AND
                                     crapcob.nrdctabb = craptdb.nrdctabb AND
                                     crapcob.nrdconta = craptdb.nrdconta AND
                                     crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                     crapcob.nrdocmto = craptdb.nrdocmto AND
                                    (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                    (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK:
 

                  /* Pago pelo CAIXA, InternetBank ou TAA, e compe 085 */
                  IF  crapcob.indpagto = 1  OR 
                      crapcob.indpagto = 3  OR
                      crapcob.indpagto = 4  OR  /**TAA**/
                      (crapcob.indpagto = 0 AND crapcob.cdbandoc = 085) THEN  
                      DO:
                         ASSIGN res_qtvencid = res_qtvencid - 1
                                res_vlvencid = res_vlvencid - craptdb.vltitulo.
                      END.
         
              END. /* Fim do FOR EACH craptdb */

              /* Recebidos no dia */
              FOR EACH craptdb WHERE craptdb.cdcooper = glb_cdcooper AND
                                     craptdb.dtlibbdt = tel_dtvencto
                                     NO-LOCK,
                  EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                     crapcob.cdbandoc = craptdb.cdbandoc AND
                                     crapcob.nrdctabb = craptdb.nrdctabb AND
                                     crapcob.nrdconta = craptdb.nrdconta AND
                                     crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                     crapcob.nrdocmto = craptdb.nrdocmto AND
                                    (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                    (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK:

                  ASSIGN res_qttitulo = res_qttitulo + 1
                         res_vltitulo = res_vltitulo + craptdb.vltitulo.
              END.

              /* Saldo Anterior */
              FOR EACH craptdb WHERE craptdb.cdcooper = glb_cdcooper NO-LOCK,
                  EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                     crapcob.cdbandoc = craptdb.cdbandoc AND
                                     crapcob.nrdctabb = craptdb.nrdctabb AND
                                     crapcob.nrdconta = craptdb.nrdconta AND
                                     crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                     crapcob.nrdocmto = craptdb.nrdocmto AND
                                    (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                    (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK:


                  /* Utiliza essas duas variaveis para pegar TODOS os títulos LIBERADOS
                    até a data informada, pois ele subtrai TODOS os com data de liberação a partir
                    da data informada (qtd_liberado) de todos os liberados da craptdb (qtd_saldo)  */
                  IF  craptdb.dtlibbdt >= tel_dtvencto  THEN
                      ASSIGN vlr_liberado = vlr_liberado + craptdb.vltitulo
                             qtd_liberado = qtd_liberado + 1.
    
                  IF  craptdb.insittit = 4  THEN
                      DO:
                          ASSIGN vlr_saldo = vlr_saldo + craptdb.vltitulo
                                 qtd_saldo = qtd_saldo + 1.
                          NEXT.
                      END.
       
                  /* D + 1 para titulos pagos via COMPE */
                  /* apenas para titulos do BB */
                  IF  crapcob.indpagto = 0 AND
                      crapcob.cdbandoc = 001 THEN
                      DO:
                          IF  craptdb.dtdpagto >= aux_dtmvtoan   THEN
                              DO:
                                  ASSIGN vlr_pgdepois = vlr_pgdepois + 
                                                        craptdb.vltitulo
                                         qtd_pgdepois = qtd_pgdepois + 1.
                                  NEXT.
                              END.
                      END.    
                  ELSE
                      IF  craptdb.dtdpagto >= tel_dtvencto  THEN
                          DO:
                              ASSIGN vlr_pgdepois = vlr_pgdepois + 
                                                    craptdb.vltitulo
                                     qtd_pgdepois = qtd_pgdepois + 1.
                              NEXT.
                          END.

                  IF  craptdb.dtresgat >= tel_dtvencto  THEN
                      DO:
                          ASSIGN vlr_rgdepois = vlr_rgdepois + craptdb.vltitulo
                                 qtd_rgdepois = qtd_rgdepois + 1.
                          NEXT.
                      END.

                  
                  ASSIGN aux_diffdias = (aux_dtmvtoan) - (craptdb.dtvencto).
                  
                  /* Quando a pessoa informa um dia que for terca feira 
                     contabilizar os baixados sem pagamento do final de semana
                     passado na terca feira */ 
                  IF  (WEEKDAY(craptdb.dtvencto) = 7  OR  /* sabado  */
                       WEEKDAY(craptdb.dtvencto) = 1) AND /* domingo */
                       WEEKDAY(aux_dtmvtoan) = 2      AND /* segunda */
                       craptdb.insittit  = 3          AND 
                       CAN-DO("1,2,3",STRING(aux_diffdias)) THEN 
                       DO:
                           ASSIGN vlr_bxdepois = vlr_bxdepois + craptdb.vltitulo
                                  qtd_bxdepois = qtd_bxdepois + 1.

                           NEXT.
                       END.

                  IF  craptdb.insittit  = 3              AND
                      (craptdb.dtdebito > aux_dtmvtoan OR (craptdb.dtdebito = ? AND craptdb.dtvencto >= aux_dtmvtoan)) THEN
                      DO:
                          ASSIGN vlr_bxdepois = vlr_bxdepois + craptdb.vltitulo
                                 qtd_bxdepois = qtd_bxdepois + 1.

                      END.

              END. 

              HIDE FRAME f_aguarde NO-PAUSE.

              ASSIGN res_qtsldant = (qtd_pgdepois + qtd_rgdepois + 
                                     qtd_bxdepois) + 
                                     (qtd_saldo - qtd_liberado)
                     res_qtcredit = res_qtsldant + res_qtvencid +
                                    res_qttitulo + res_qtderesg

                     res_vlsldant = (vlr_pgdepois + vlr_rgdepois +
                                     vlr_bxdepois) + 
                                    (vlr_saldo - vlr_liberado)
                     res_vlcredit = res_vlsldant + res_vlvencid +
                                    res_vltitulo + res_vlderesg.

              DISPLAY res_qtsldant res_vlsldant
                      tel_dtvencto res_qtderesg
                      res_vlderesg res_qtvencid
                      res_vlvencid res_qttitulo
                      res_vltitulo res_qtcredit
                      res_vlcredit
                      WITH FRAME f_contabilidade.
                        
           END.  /*  Fim do DO WHILE TRUE  */
        
           HIDE FRAME f_contabilidade NO-PAUSE.
           CLEAR FRAME f_contabilidade NO-PAUSE.

        END.  /*  Fim do DO WHILE TRUE  */
    ELSE
    IF  glb_cddopcao = "Q"   THEN
        DO:
            VIEW FRAME f_tpcobran.

            IF  tel_nrdconta = 0  THEN
                DO:
                    glb_cdcritic = 9.
                    PAUSE 0.
                    NEXT.
                END.

            UPDATE tel_tpcobran WITH FRAME f_tpcobran.

            FOR EACH crapsab WHERE crapsab.cdcooper = glb_cdcooper AND
                                   crapsab.nrinssac = crapass.nrcpfcgc
                                   NO-LOCK,
                EACH crapcob WHERE crapcob.cdcooper = glb_cdcooper     AND
                                   crapcob.nrinssac = crapsab.nrinssac AND
                                   crapcob.nrdconta = crapsab.nrdconta AND
                (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE)
                                   NO-LOCK, 
                EACH craptdb WHERE craptdb.cdcooper = crapcob.cdcooper AND
                                   craptdb.cdbandoc = crapcob.cdbandoc AND
                                   craptdb.nrdctabb = crapcob.nrdctabb AND
                                   craptdb.nrcnvcob = crapcob.nrcnvcob AND
                                   craptdb.nrdconta = crapcob.nrdconta AND
                                   craptdb.nrdocmto = crapcob.nrdocmto AND
                                   craptdb.insittit = 4 NO-LOCK
                                   BY crapcob.flgregis DESC
                                   BY crapcob.cdbandoc DESC
                                   BY crapcob.nrdconta:

                FIND crabass WHERE crabass.cdcooper = crapcob.cdcooper AND
                                   crabass.nrdconta = craptdb.nrdconta
                                   NO-LOCK NO-ERROR.
                
                CREATE w_titulos.
                ASSIGN w_titulos.dtlibbdt = craptdb.dtlibbdt
                       w_titulos.dtvencto = craptdb.dtvencto
                       w_titulos.cdbandoc = craptdb.cdbandoc
                       w_titulos.nrcnvcob = craptdb.nrcnvcob
                       w_titulos.nrdocmto = craptdb.nrdocmto
                       w_titulos.vltitulo = craptdb.vltitulo
                       w_titulos.nrdconta = craptdb.nrdconta
                       w_titulos.nmprimtl = crabass.nmprimtl WHEN AVAIL crabass
                       w_titulos.tpcobran = IF  crapcob.flgregis = TRUE  AND
                                                crapcob.cdbandoc = 085  THEN
                                                "Coop. Emite"
                                            ELSE 
                                            IF  crapcob.flgregis = TRUE  AND
                                                crapcob.cdbandoc <> 085 THEN 
                                               "Banco Emite"
                                            ELSE
                                            IF  crapcob.flgregis = FALSE THEN 
                                                "S/registro"
                                            ELSE
                                                " ".
            END.    
            
            CLOSE QUERY q_titulosq. 
                    
            OPEN QUERY q_titulosq FOR EACH w_titulos.

            IF  QUERY q_titulosq:NUM-RESULTS = 0  THEN
                DO:
                    BELL.
                    MESSAGE "Nao ha registros para listar.".
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
                    
            ENABLE b_titulosq WITH FRAME f_browseq.
                        
            WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
           
            HIDE FRAME f_browseq. 
                    
            HIDE MESSAGE NO-PAUSE.    
            
        END.
    ELSE
    IF  glb_cddopcao = "T"   THEN      /*  PESQUISA TITULOS EM DESCONTO  */
        DO:
            IF  tel_nrdconta = 0  THEN
                DO:
                    glb_cdcritic = 9.
                    PAUSE 0.
                    NEXT.
                END.
        
            VIEW FRAME f_seltodos.
            VIEW FRAME f_tpcobran.
                                    
            ASSIGN tel_nrdocmto = 0
                   tel_vltitulo = 0.
            
            DO WHILE TRUE:
            
               EMPTY TEMP-TABLE w_titulos.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                       
                  UPDATE tel_tpdepesq tel_nrdocmto tel_vltitulo
                         WITH FRAME f_seltodos.

                  UPDATE tel_tpcobran WITH FRAME f_tpcobran.

                  IF  tel_nrdocmto = 0  AND
                      tel_vltitulo = 0  THEN
                      DO:
                          MESSAGE "Informe pelo menos uma selecao!".
                          NEXT.
                      END.
               
                  LEAVE.
            
               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                    LEAVE.
            
               ASSIGN aux_notfound = FALSE.
               
               IF  SUBSTR(tel_tpdepesq,1,1) = "T"  THEN /* Todos */
               FOR EACH craptdb WHERE (craptdb.cdcooper = glb_cdcooper AND
                                       craptdb.nrdconta = tel_nrdconta AND
                                       craptdb.insittit = 2) 
                                      OR
                                      (craptdb.cdcooper = glb_cdcooper AND
                                       craptdb.nrdconta = tel_nrdconta AND
                                       craptdb.insittit = 3)
                                      OR
                                      (craptdb.cdcooper = glb_cdcooper AND
                                       craptdb.nrdconta = tel_nrdconta AND
                                       craptdb.insittit = 4)
                                      NO-LOCK,
                   EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                      crapcob.cdbandoc = craptdb.cdbandoc AND
                                      crapcob.nrdctabb = craptdb.nrdctabb AND
                                      crapcob.nrdconta = craptdb.nrdconta AND
                                      crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                      crapcob.nrdocmto = craptdb.nrdocmto AND
                                     (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                     (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK
                                      BY crapcob.flgregis DESC
                                      BY crapcob.cdbandoc DESC
                                      BY crapass.nrdconta:

                   IF   (tel_nrdocmto <> 0  AND
                         tel_nrdocmto <> craptdb.nrdocmto)
                   OR   (tel_vltitulo <> 0  AND
                         tel_vltitulo <> craptdb.vltitulo)   THEN
                         NEXT. 

                   FIND crapbdt WHERE crapbdt.cdcooper = craptdb.cdcooper AND
                                      crapbdt.nrborder = craptdb.nrborder
                                      NO-LOCK NO-ERROR.
                                                         
                   ASSIGN aux_notfound = TRUE.
                   
                   CREATE w_titulos.
                   ASSIGN w_titulos.dtlibbdt = craptdb.dtlibbdt
                          w_titulos.cdagenci = crapbdt.cdagenci
                          w_titulos.cdbccxlt = crapbdt.cdbccxlt
                          w_titulos.nrdolote = crapbdt.nrdolote
                          w_titulos.dtvencto = craptdb.dtvencto
                          w_titulos.cdbandoc = craptdb.cdbandoc
                          w_titulos.nrcnvcob = craptdb.nrcnvcob
                          w_titulos.nrdocmto = craptdb.nrdocmto
                          w_titulos.vltitulo = craptdb.vltitulo
                          w_titulos.tpcobran = IF  crapcob.flgregis = TRUE  AND
                                                   crapcob.cdbandoc = 085  THEN
                                                   "Coop. Emite"
                                               ELSE 
                                               IF  crapcob.flgregis = TRUE  AND
                                                   crapcob.cdbandoc <> 085 THEN 
                                                  "Banco Emite"
                                               ELSE
                                               IF  crapcob.flgregis = FALSE THEN 
                                                   "S/registro"
                                               ELSE
                                                   " ".

               END.  /*  Fim do FOR EACH  */
               ELSE
               IF  SUBSTR(tel_tpdepesq,1,1) = "A"  THEN /* Em aberto */
               FOR EACH craptdb WHERE craptdb.cdcooper = glb_cdcooper AND
                                      craptdb.nrdconta = tel_nrdconta AND
                                      craptdb.insittit = 4 NO-LOCK,
                   EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                      crapcob.cdbandoc = craptdb.cdbandoc AND
                                      crapcob.nrdctabb = craptdb.nrdctabb AND
                                      crapcob.nrdconta = craptdb.nrdconta AND
                                      crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                      crapcob.nrdocmto = craptdb.nrdocmto AND
                                     (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                     (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK
                                      BY crapcob.flgregis DESC
                                      BY crapcob.cdbandoc DESC
                                      BY crapass.nrdconta:
                   
                   IF   (tel_nrdocmto <> 0  AND
                         tel_nrdocmto <> craptdb.nrdocmto)
                   OR   (tel_vltitulo <> 0  AND
                         tel_vltitulo <> craptdb.vltitulo)   THEN
                         NEXT. 
                  
                   IF  craptdb.dtvencto <= glb_dtmvtoan THEN
                       NEXT.
                   
                   FIND crapbdt WHERE crapbdt.cdcooper = craptdb.cdcooper AND
                                      crapbdt.nrborder = craptdb.nrborder
                                      NO-LOCK NO-ERROR.
                                                         
                   ASSIGN aux_notfound = TRUE.
                   
                   CREATE w_titulos.
                   ASSIGN w_titulos.dtlibbdt = craptdb.dtlibbdt
                          w_titulos.cdagenci = crapbdt.cdagenci
                          w_titulos.cdbccxlt = crapbdt.cdbccxlt
                          w_titulos.nrdolote = crapbdt.nrdolote
                          w_titulos.dtvencto = craptdb.dtvencto
                          w_titulos.cdbandoc = craptdb.cdbandoc
                          w_titulos.nrcnvcob = craptdb.nrcnvcob
                          w_titulos.nrdocmto = craptdb.nrdocmto
                          w_titulos.vltitulo = craptdb.vltitulo
                          w_titulos.tpcobran = IF  crapcob.flgregis = TRUE  AND
                                                   crapcob.cdbandoc = 085  THEN
                                                   "Coop. Emite"
                                               ELSE 
                                               IF  crapcob.flgregis = TRUE  AND
                                                   crapcob.cdbandoc <> 085 THEN 
                                                  "Banco Emite"
                                               ELSE
                                               IF  crapcob.flgregis = FALSE THEN 
                                                   "S/registro"
                                               ELSE
                                                   " ".

               END.  /*  Fim do FOR EACH  */
               ELSE  /* Liquidados */
               FOR EACH craptdb WHERE craptdb.cdcooper = glb_cdcooper AND
                                      craptdb.nrdconta = tel_nrdconta AND
                                      craptdb.insittit = 2 NO-LOCK,
                   EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                      crapcob.cdbandoc = craptdb.cdbandoc AND
                                      crapcob.nrdctabb = craptdb.nrdctabb AND
                                      crapcob.nrdconta = craptdb.nrdconta AND
                                      crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                      crapcob.nrdocmto = craptdb.nrdocmto AND
                                     (IF aux_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                     (IF aux_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK
                                      BY crapcob.flgregis DESC
                                      BY crapcob.cdbandoc DESC
                                      BY crapass.nrdconta:
                   
                   IF   (tel_nrdocmto <> 0  AND
                         tel_nrdocmto <> craptdb.nrdocmto)
                   OR   (tel_vltitulo <> 0  AND
                         tel_vltitulo <> craptdb.vltitulo)   THEN
                         NEXT. 
                  
                   FIND crapbdt WHERE crapbdt.cdcooper = craptdb.cdcooper AND
                                      crapbdt.nrborder = craptdb.nrborder
                                      NO-LOCK NO-ERROR.
                                                         
                   ASSIGN aux_notfound = TRUE.
                   
                   CREATE w_titulos.
                   ASSIGN w_titulos.dtlibbdt = craptdb.dtlibbdt
                          w_titulos.cdagenci = crapbdt.cdagenci
                          w_titulos.cdbccxlt = crapbdt.cdbccxlt
                          w_titulos.nrdolote = crapbdt.nrdolote
                          w_titulos.dtvencto = craptdb.dtvencto
                          w_titulos.cdbandoc = craptdb.cdbandoc
                          w_titulos.nrcnvcob = craptdb.nrcnvcob
                          w_titulos.nrdocmto = craptdb.nrdocmto
                          w_titulos.vltitulo = craptdb.vltitulo
                          w_titulos.tpcobran = IF  crapcob.flgregis = TRUE  AND
                                                   crapcob.cdbandoc = 085  THEN
                                                   "Coop. Emite"
                                               ELSE 
                                               IF  crapcob.flgregis = TRUE  AND
                                                   crapcob.cdbandoc <> 085 THEN 
                                                  "Banco Emite"
                                               ELSE
                                               IF  crapcob.flgregis = FALSE THEN 
                                                   "S/registro"
                                               ELSE
                                                   " ".

               END.  /*  Fim do FOR EACH  */
               
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   
                    NEXT.

               IF   NOT aux_notfound   THEN
                    DO:
                        ASSIGN aux_notfound = FALSE.
                        MESSAGE "Sem registros para listar.".
                        NEXT.
                    END.
                    
               CLOSE QUERY q_titulos2. 
                    
               OPEN QUERY q_titulos2 FOR EACH w_titulos.

               IF  QUERY q_titulos2:NUM-RESULTS = 0  THEN
                   DO:
                       MESSAGE "Nao ha registros para listar.".
                       HIDE tel_nrcpfcgc IN FRAME f_cpf/cgc.
                       BELL.
                       NEXT.
                   END.
                    
               ENABLE b_titulos2 WITH FRAME f_browse2.
                        
               WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
               
               HIDE FRAME f_browse2. 
               HIDE FRAME f_seltodos.
                    
               HIDE MESSAGE NO-PAUSE.     

            END. /* do DO WHILE TRUE */
                    
        END. /* do  IF da selecao */            

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

PROCEDURE proc_datas:

    aux_dtvenct1 = tel_dtvencto.
    
    DO WHILE TRUE:
               
       aux_dtvenct1 = aux_dtvenct1 - 1.
       
       IF  isFeriadoFds(aux_dtvenct1)  THEN
           NEXT.

       LEAVE.
               
    END.  /*  Fim do DO WHILE TRUE  */
               
    aux_dtvenct2 = tel_dtvencto.
    
    DO WHILE TRUE:

       IF  isFeriadoFds(aux_dtvenct2)  THEN
           DO:
               aux_dtvenct2 = aux_dtvenct2 + 1.
               NEXT.
           END.
          
       aux_dtvenct2 = aux_dtvenct2 + 1.
       
       LEAVE.
               
    END.  /*  Fim do DO WHILE TRUE  */

END PROCEDURE.

PROCEDURE imprime:

    /* somente para a includes/impressao.i */
    FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
                 
    { includes/impressao.i }

END PROCEDURE.

PROCEDURE proc_fechamento:

    DEF INPUT PARAM par_tpcobran AS CHAR                    NO-UNDO.

    ASSIGN res_qtderesg = 0
           res_vlderesg = 0
           res_qttitulo = 0
           res_vltitulo = 0
           res_qtdpagto = 0
           res_vldpagto = 0.

    IF   tel_nrdconta > 0   THEN
         DO:
             IF  tel_dtvencto <> ?   THEN
                 DO:      
                    FOR EACH craptdb WHERE
                             craptdb.cdcooper  = glb_cdcooper AND
                             craptdb.nrdconta  = tel_nrdconta AND
                             craptdb.dtvencto  > aux_dtvenct1 AND
                             craptdb.dtvencto <= tel_dtvencto AND
                             craptdb.dtlibbdt <> ?
                             NO-LOCK,
                        EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                           crapcob.cdbandoc = craptdb.cdbandoc AND
                                           crapcob.nrdctabb = craptdb.nrdctabb AND
                                           crapcob.nrdconta = craptdb.nrdconta AND
                                           crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                           crapcob.nrdocmto = craptdb.nrdocmto AND
                                          (IF par_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                          (IF par_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK:
                                  
                        ASSIGN res_qttitulo = res_qttitulo + 1
                               res_vltitulo = res_vltitulo + craptdb.vltitulo.
                        
                        IF  craptdb.insittit  = 1             THEN
                            ASSIGN res_qtderesg = res_qtderesg + 1
                                   res_vlderesg = res_vlderesg + 
                                                    craptdb.vltitulo.
                                                    
                        IF  craptdb.insittit  = 2  OR
                            craptdb.insittit  = 3  THEN
                            ASSIGN res_qtdpagto = res_qtdpagto + 1
                                   res_vldpagto = res_vldpagto + 
                                                    craptdb.vltitulo.

                    END. /* Fim do FOR EACH  */
                 END.
             ELSE
                 DO:
                    FOR EACH craptdb WHERE craptdb.cdcooper  = glb_cdcooper  AND
                                           craptdb.nrdconta  = tel_nrdconta  AND
                                           craptdb.dtlibbdt <> ?             AND
                                           craptdb.dtvencto  > glb_dtmvtolt
                                           NO-LOCK USE-INDEX craptdb2,
                        EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                           crapcob.cdbandoc = craptdb.cdbandoc AND
                                           crapcob.nrdctabb = craptdb.nrdctabb AND
                                           crapcob.nrdconta = craptdb.nrdconta AND
                                           crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                           crapcob.nrdocmto = craptdb.nrdocmto AND
                                          (IF par_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                          (IF par_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK:

                        ASSIGN res_qttitulo = res_qttitulo + 1
                               res_vltitulo = res_vltitulo + craptdb.vltitulo.
                        
                        IF  craptdb.insittit  = 1  THEN
                            ASSIGN res_qtderesg = res_qtderesg + 1
                                   res_vlderesg = res_vlderesg +
                                                       craptdb.vltitulo.
                            
                        IF  craptdb.insittit  = 2  OR
                            craptdb.insittit  = 3  THEN
                            ASSIGN res_qtdpagto = res_qtdpagto + 1
                                   res_vldpagto = res_vldpagto + 
                                                    craptdb.vltitulo.
                            
                    END.  /*  Fim do FOR EACH  */
                 END.
         END.
    ELSE
         DO:
             IF   tel_dtvencto <> ?   THEN
                  FOR EACH craptdb WHERE craptdb.cdcooper  = glb_cdcooper   AND
                                         craptdb.dtlibbdt <> ?              AND
                                         craptdb.dtvencto  > aux_dtvenct1   AND
                                         craptdb.dtvencto <= tel_dtvencto
                                         NO-LOCK USE-INDEX craptdb3,
                      EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                         crapcob.cdbandoc = craptdb.cdbandoc AND
                                         crapcob.nrdctabb = craptdb.nrdctabb AND
                                         crapcob.nrdconta = craptdb.nrdconta AND
                                         crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                         crapcob.nrdocmto = craptdb.nrdocmto AND
                                        (IF par_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                        (IF par_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK:

                      ASSIGN res_qttitulo = res_qttitulo + 1
                             res_vltitulo = res_vltitulo + craptdb.vltitulo.

                      IF  craptdb.insittit = 1  THEN
                          ASSIGN res_qtderesg = res_qtderesg + 1
                                 res_vlderesg = res_vlderesg +
                                                     craptdb.vltitulo.
                                                     
                      IF  craptdb.insittit = 2  OR
                          craptdb.insittit = 3  THEN        
                          ASSIGN res_qtdpagto = res_qtdpagto + 1
                                 res_vldpagto = res_vldpagto +
                                                     craptdb.vltitulo.
                     
                  END.  /*  Fim do FOR EACH  */
             ELSE
                  FOR EACH craptdb WHERE craptdb.cdcooper  = glb_cdcooper   AND
                                         craptdb.dtvencto  > glb_dtmvtolt   AND
                                         craptdb.dtlibbdt <> ?  
                                         NO-LOCK USE-INDEX craptdb3,
                      EACH crapcob WHERE crapcob.cdcooper = craptdb.cdcooper AND
                                         crapcob.cdbandoc = craptdb.cdbandoc AND
                                         crapcob.nrdctabb = craptdb.nrdctabb AND
                                         crapcob.nrdconta = craptdb.nrdconta AND
                                         crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                         crapcob.nrdocmto = craptdb.nrdocmto AND
                                        (IF par_tpcobran = "S" THEN crapcob.flgregis = FALSE ELSE TRUE) AND
                                        (IF par_tpcobran = "R" THEN crapcob.flgregis = TRUE  ELSE TRUE) NO-LOCK:

                      ASSIGN res_qttitulo = res_qttitulo + 1
                             res_vltitulo = res_vltitulo + craptdb.vltitulo.
                      
                      IF   craptdb.insittit  = 1  THEN
                           ASSIGN res_qtderesg = res_qtderesg + 1
                                  res_vlderesg = res_vlderesg +
                                                      craptdb.vltitulo.
                     
                      IF  craptdb.insittit = 2  OR
                          craptdb.insittit = 3  THEN        
                          ASSIGN res_qtdpagto = res_qtdpagto + 1
                                 res_vldpagto = res_vldpagto +
                                                     craptdb.vltitulo.
                      
                  END.  /*  Fim do FOR EACH  */
         END.

END PROCEDURE.

/* .......................................................................... */
