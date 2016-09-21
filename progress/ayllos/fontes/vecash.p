/* .............................................................................

   Programa: Fontes/vecash.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Maio/2006                         Ultima Atualizacao: 27/06/2014

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Gerar Arquivo e Efetuar Impressao com Informacoes do CASH.

   Alteracoes: 02/08/2006 - Acrescentado EMPTY TEMP-TABLE (Diego).
               
               19/01/2007 - Alterado formato das variaveis do tipo DATE de 
                            "99/99/99" para "99/99/9999" (Elton).

               19/03/2007 - Inclusoes de campos referente a deposito, variaveis
                            de totais e retirada de campos do relatorio quando
                            for gerado arquivo (David).
                            
               14/10/2008 - Inclusoes de campos Vlr e Qtd. de Estornos (Ze).
               
               07/11/2008 - Troca do Histor. 359 p/ 767 (Estorno Debito) (Ze).
               
               02/10/2009 - Aumento do campo nrdocash (Diego).
               
               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop na
                            leitura e gravacao dos arquivos (Elton).
                           
               15/03/2013 - Incluir informacoes de transferencia 
                            interCooperativa (Gabriel).
                            
               19/07/2013 - Substituido campos Maior Saque e Falhas por Valor 
                            Saques Intercoop. e Saques Intercoop.. Adicionado 
                            Estorno Intercoop.. Alterada forma de pesquisa do 
                            numero do cash. (Douglas).
                            
               23/08/2013 - Ajuste de colunas para impressao (Douglas).
               
               15/10/2013 - Usar cdcoptfn para buscar os dados da crapltr e
                            tratamento especifico para transferencias;
                            Ajustar quebra de pagina e totalizadores;
                            Preparacao para melhoria de performance (Evandro).
                            
               28/10/2013 - Ajuste na busca dos TAAs quando informado zero
                            (Evandro).
                            
               06/03/2014 - Convertido craptab.tpregist para INTEGER. (Reinert)
               
               28/04/2014 - #137902 Melhoria do relatorio: relatório para todas
                            as cooperativas quando for CECRED. Tanto para
                            impressao em tela quanto em impressora (Carlos)
                            
               27/06/2014 - #171693 Retirados os cabecalhos das cooperativas,
                            deixando os registros sem espaco estre eles (Carlos)
               
..............................................................................*/

{ includes/var_online.i }

DEF STREAM str_1. 

DEF VAR tel_nrdcash1 AS INT          FORMAT "zzz9"                    NO-UNDO.
DEF VAR tel_nrdcash2 AS INT          FORMAT "zzz9"                    NO-UNDO.
DEF VAR tel_iniperio AS DATE         FORMAT "99/99/9999"              NO-UNDO.
DEF VAR tel_fimperio AS DATE         FORMAT "99/99/9999"              NO-UNDO.
DEF VAR tel_nmdopcao AS LOGICAL      FORMAT "ARQUIVO/IMPRESSAO"       NO-UNDO.
DEF VAR tel_nmdireto AS CHAR         FORMAT "x(25)"                   NO-UNDO.

DEF VAR tel_dsimprim AS CHAR         FORMAT "x(8)" INIT "Imprimir"    NO-UNDO.
DEF VAR tel_dscancel AS CHAR         FORMAT "x(8)" INIT "Cancelar"    NO-UNDO.
                                                                      
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                            NO-UNDO.
DEF VAR aux_tpcartao AS INT EXTENT 5 FORMAT "zzz,zz9"                 NO-UNDO.
DEF VAR aux_tottpcar AS INT                                           NO-UNDO.
DEF VAR aux_totsldfi AS DECIMAL      FORMAT "zzz,zzz,zz9.99"          NO-UNDO.
DEF VAR aux_saldomed AS DECIMAL      FORMAT "zzz,zzz,zz9.99"          NO-UNDO.
DEF VAR aux_qtdddias AS INT                                           NO-UNDO.
DEF VAR aux_totsaque AS INT          FORMAT "zz,zz9"                  NO-UNDO.
DEF VAR aux_totsaqin AS INT          FORMAT "zz,zz9"                  NO-UNDO.
DEF VAR aux_totestor AS INT          FORMAT "zz,zz9"                  NO-UNDO.
DEF VAR aux_totsaldo AS INT          FORMAT "zz,zz9"                  NO-UNDO.
DEF VAR aux_totextra AS INT          FORMAT "zz,zz9"                  NO-UNDO.
DEF VAR aux_totdepos AS INT          FORMAT "zz,zz9"                  NO-UNDO.
DEF VAR aux_tottrans AS INT          FORMAT "zz,zz9"                  NO-UNDO.
DEF VAR aux_tottrain AS INTE         FORMAT "zz,zz9"                  NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR         FORMAT "x(40)"                   NO-UNDO.
DEF VAR aux_nmdireto AS CHAR         FORMAT "x(20)"                   NO-UNDO.

DEF VAR aux_nmendter AS CHAR         FORMAT "x(20)"                   NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                       NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                          NO-UNDO.
DEF VAR aux_flgfirst AS LOGICAL                                       NO-UNDO.
DEF VAR aux_contador AS INT                                           NO-UNDO.
DEF VAR aux_dtmvtolt AS DATE                                          NO-UNDO.
DEF VAR aux_nrterfin AS INT                                           NO-UNDO.

DEF VAR par_flgrodar AS LOGICAL INIT TRUE                             NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                             NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                       NO-UNDO.

DEF VAR rel_nmempres AS CHAR         FORMAT "x(15)"                   NO-UNDO.
DEF VAR rel_nmrelato AS CHAR         FORMAT "x(40)" EXTENT 5          NO-UNDO.

DEF VAR rel_nrmodulo AS INT          FORMAT "9"                       NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR         FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]       NO-UNDO.


DEF VAR aux_tpcartao_1 AS INT                                         NO-UNDO.
DEF VAR aux_tpcartao_2 AS INT                                         NO-UNDO.
DEF VAR aux_tpcartao_3 AS INT                                         NO-UNDO.
DEF VAR aux_tpcartao_4 AS INT                                         NO-UNDO.
DEF VAR aux_tottpcar_c AS INT                                         NO-UNDO.

DEF VAR aux_nrdcash1 AS INT          FORMAT "zzz9"                    NO-UNDO.
DEF VAR aux_nrdcash2 AS INT          FORMAT "zzz9"                    NO-UNDO.


DEF TEMP-TABLE w-movimento   NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD cdagenci AS INT      FORMAT "zz9"            
    FIELD dtmvtolt AS DATE     FORMAT "99/99/99"       
    FIELD nrdocash AS INT      FORMAT "zzz9"           
    FIELD vlsaqint AS DECIMAL  FORMAT "zzz,zz9.99"        
    FIELD qtsaqint AS INT      FORMAT "z,zz9"          
    FIELD qtestint AS INT      FORMAT "z,zz9"
    FIELD qtsaques AS INT      FORMAT "z,zz9"
    FIELD vlsaques AS DECIMAL  FORMAT "zzzzz,zz9.99"    
    FIELD qtestorn AS INT      FORMAT "zzz9"           
    FIELD vlestorn AS DECIMAL  FORMAT "zzzz,zz9.99"    
    FIELD qtdeposi AS INT      FORMAT "zzz9"           
    FIELD vldeposi AS DECIMAL  FORMAT "zzzz,zz9.99"    
    FIELD qttransf AS INT      FORMAT "z,zz9"          
    FIELD vltransf AS DECIMAL  FORMAT "zzzz,zz9.99"    
    FIELD qttraint AS INTE     FORMAT "z,zz9"          
    FIELD vltraint AS DECI     FORMAT "zzzz,zz9.99" 
    FIELD qtsaldos AS INT      FORMAT "z,zz9"             
    FIELD qtextrat AS INT      FORMAT "z,zz9"            
    FIELD sldfinal AS DECIMAL  FORMAT "-zzzzz,zz9.99"   
    INDEX cash1 cdcooper cdagenci dtmvtolt nrdocash.

FORM "Saque Intercooperativa"           AT  39
     "Intercooperativa"                 AT  78
     "Transferencia Intracooperativa"   AT 123
     "Transferencia Intercooperativa"   AT 155
     SKIP
     "----------------------"           AT  39
     "----------------"                 AT  78
     "------------------------------"   AT 123
     "------------------------------"   AT 155
     SKIP
     " PA Dia      Cash Saques Valor Saques Quantidade       Valor "
     " Valor Estorno      Estorno     Depositos   Valor Deposito "
     "Quantidade               Valor  Quantidade               Valor"
     "  Saldos Extrato    Saldo Final"
   SKIP(1)
   WITH NO-BOX WIDTH 234 FRAME f_cabecalho.

FORM "Saque Intercooperativa"           AT  45
     "Intercooperativa"                 AT  84
     "Transferencia Intracooperativa"   AT 129
     "Transferencia Intercooperativa"   AT 161
     SKIP
     "----------------------"           AT  45
     "----------------"                 AT  84
     "------------------------------"   AT 129
     "------------------------------"   AT 161
     SKIP
     "Coop.  PA Dia      Cash Saques Valor Saques Quantidade       Valor "
     " Valor Estorno      Estorno     Depositos   Valor Deposito "
     "Quantidade               Valor  Quantidade               Valor"
     "  Saldos Extrato    Saldo Final"
   SKIP(1)
   WITH NO-BOX WIDTH 234 FRAME f_cabecalho_cecred.

FORM w-movimento.cdagenci   
     w-movimento.dtmvtolt   
     w-movimento.nrdocash    AT  14  
     w-movimento.qtsaques    AT  20  
     w-movimento.vlsaques    AT  26  
     w-movimento.qtsaqint    AT  44
     w-movimento.vlsaqint    AT  51
     w-movimento.vlestorn    AT  66
     w-movimento.qtestint    AT  85
     w-movimento.qtdeposi    AT 100 
     w-movimento.vldeposi    AT 110 
     w-movimento.qttransf    AT 128   
     w-movimento.vltransf    AT 142      
     w-movimento.qttraint    AT 160
     w-movimento.vltraint    AT 174
     w-movimento.qtsaldos    AT 189 
     w-movimento.qtextrat    AT 197  
     w-movimento.sldfinal    AT 204  
     WITH NO-BOX NO-LABEL DOWN WIDTH 234 FRAME f_dados1.

FORM w-movimento.cdcooper FORMAT "z,zz9"
     w-movimento.cdagenci   
     w-movimento.dtmvtolt   
     w-movimento.nrdocash    AT  20  
     w-movimento.qtsaques    AT  26  
     w-movimento.vlsaques    AT  32  
     w-movimento.qtsaqint    AT  50
     w-movimento.vlsaqint    AT  57
     w-movimento.vlestorn    AT  72
     w-movimento.qtestint    AT  91
     w-movimento.qtdeposi    AT 106 
     w-movimento.vldeposi    AT 116 
     w-movimento.qttransf    AT 134   
     w-movimento.vltransf    AT 148      
     w-movimento.qttraint    AT 166
     w-movimento.vltraint    AT 180
     w-movimento.qtsaldos    AT 195 
     w-movimento.qtextrat    AT 203  
     w-movimento.sldfinal    AT 210  
     WITH NO-BOX NO-LABEL DOWN WIDTH 234 FRAME f_dados1_cecred.

FORM SKIP(2)
     "Saques"             AT  19
     "Saques Inter."      AT  39
     "Qtd. Estornos"      AT  64
     "Depositos"          AT  95
     "Transf. Intracoop." AT 132
     "Transf. Intercoop." AT 164
     "Saldos"             AT 188
     "Extr."              AT 197
     "Saldo Final"        AT 206  SKIP
     "TOTAIS: "           AT  06
     aux_totsaque         AT  19
     aux_totsaqin         AT  43
     aux_totestor         AT  71
     aux_totdepos         AT  98
     aux_tottrans         AT 127
     aux_tottrain         AT 159
     aux_totsaldo         AT 188
     aux_totextra         AT 196 
     aux_totsldfi         AT 203
     SKIP(1)
     aux_saldomed    LABEL  "Saldo Medio"   AT  106
     SKIP(2)
     aux_tpcartao[1] LABEL "Solicitados" SKIP
     aux_tpcartao[2] LABEL "     Ativos" SKIP
     aux_tpcartao[3] LABEL " Cancelados" SKIP
     aux_tpcartao[4] LABEL " Bloqueados" SKIP(1)
     aux_tottpcar    LABEL "      Total"         FORMAT "zzz,zz9"
     WITH SIDE-LABELS NO-BOX NO-LABEL WIDTH 234 FRAME f_dados2.

FORM SKIP(2)
     "Saques"             AT  25
     "Saques Inter."      AT  45
     "Qtd. Estornos"      AT  70
     "Depositos"          AT 101
     "Transf. Intracoop." AT 138
     "Transf. Intercoop." AT 170
     "Saldos"             AT 194
     "Extr."              AT 203
     "Saldo Final"        AT 212  SKIP
     "TOTAIS: "           AT  12
     aux_totsaque         AT  25
     aux_totsaqin         AT  49
     aux_totestor         AT  77
     aux_totdepos         AT 104
     aux_tottrans         AT 133
     aux_tottrain         AT 165
     aux_totsaldo         AT 194
     aux_totextra         AT 202 
     aux_totsldfi         AT 209
     SKIP(1)
     aux_saldomed    LABEL  "Saldo Medio"   AT  112
     SKIP(2)
     "       Coop: " crapcop.cdcooper    SKIP
     aux_tpcartao[1] LABEL "Solicitados" SKIP
     aux_tpcartao[2] LABEL "     Ativos" SKIP
     aux_tpcartao[3] LABEL " Cancelados" SKIP
     aux_tpcartao[4] LABEL " Bloqueados" SKIP(1)
     aux_tottpcar    LABEL "      Total"         FORMAT "zzz,zz9"
     WITH SIDE-LABELS NO-BOX NO-LABEL WIDTH 234 FRAME f_dados2_cecred.

FORM
     aux_tpcartao[1] LABEL "Solicitados" SKIP
     aux_tpcartao[2] LABEL "     Ativos" SKIP
     aux_tpcartao[3] LABEL " Cancelados" SKIP
     aux_tpcartao[4] LABEL " Bloqueados" SKIP
     aux_tottpcar    LABEL "      Total"         FORMAT "zzz,zz9"
     WITH ROW 15 COLUMN 29 OVERLAY SIDE-LABELS NO-BOX NO-LABEL FRAME f_dados.

FORM
     aux_tpcartao_1 LABEL "Solicitados" SKIP
     aux_tpcartao_2 LABEL "     Ativos" SKIP
     aux_tpcartao_3 LABEL " Cancelados" SKIP
     aux_tpcartao_4 LABEL " Bloqueados" SKIP
     aux_tottpcar_c  LABEL "      Total"         FORMAT "zzz,zz9"
     WITH ROW 15 COLUMN 29 OVERLAY SIDE-LABELS NO-BOX NO-LABEL FRAME f_dados_cecred.

FORM "         CASH - "       
     tel_nrdcash1   LABEL  "Inicio"           AT 18   
                    HELP "Informe o numero do CASH Inicial ou 0 para TODOS."
                    
     tel_nrdcash2   LABEL  "   Fim"           AT 36  
                    HELP "Informe o numero do CASH Final ou 0 para TODOS."
     SKIP(1)
     "      Periodo - "
     tel_iniperio   LABEL  "Inicio"           AT 18         
                    HELP "Informe o inicio do periodo."     
                    
     tel_fimperio   LABEL  "   Fim"           AT 36     
                    HELP "Informe o final do periodo."      SKIP(1)
                    
     "         Saida: "
     tel_nmdopcao                             AT 18
                    HELP "(A)rquivo  ou  (I)mpressao"  
     SKIP(1)
     "Diretorio: "   AT  6
     aux_nmdireto    AT 18
     tel_nmdireto    AT 38    HELP "Informe o nome do arquivo."  
     WITH ROW 7 COLUMN 10 OVERLAY SIDE-LABELS NO-BOX NO-LABEL FRAME f_consulta.

FORM WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela          
     ROW 4 COLUMN 1 SIZE 80 BY 18 OVERLAY WITH FRAME f_moldura.


RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE (0).
                              
DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
   
   HIDE aux_nmdireto tel_nmdireto FRAME f_consulta.
   
   ASSIGN tel_nmdireto = "". 
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      UPDATE tel_nrdcash1 tel_nrdcash2 tel_iniperio tel_fimperio 
             tel_nmdopcao  WITH FRAME f_consulta.
      
      LEAVE.
    
   END.
    
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "VECASH"   THEN
                 DO:
                     HIDE FRAME f_consulta.
                     LEAVE.
                 END.
            ELSE
                 NEXT.
        END.
   
   IF   tel_iniperio = ?  THEN
        DO:
            ASSIGN tel_iniperio = TODAY.
            DISPLAY tel_iniperio WITH FRAME f_consulta.
        END.

   IF   tel_fimperio = ?  THEN 
        DO:
            ASSIGN tel_fimperio = tel_iniperio.
            DISPLAY tel_fimperio WITH FRAME f_consulta.
        END.

   IF   tel_fimperio < tel_iniperio  THEN
        DO:
            MESSAGE "Data Final deve ser maior ou igual a Inicial.".
            PAUSE 3 NO-MESSAGE.
            NEXT-PROMPT tel_fimperio WITH FRAME f_consulta.
            NEXT.  
        END.
      
   IF   tel_nrdcash2 < tel_nrdcash1  THEN
        DO:
            MESSAGE "Numero de CASH Final deve ser maior"
                    "ou igual ao Inicial".
            PAUSE 3 NO-MESSAGE.
            NEXT-PROMPT tel_nrdcash2 WITH FRAME f_consulta.
            NEXT.
        END.
      
   IF   tel_nrdcash1 = 0 AND tel_nrdcash2 = 0 AND glb_cdcooper <> 3 THEN
        DO: 
            FIND FIRST craptfn WHERE craptfn.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
            IF  AVAIL craptfn THEN 
                ASSIGN tel_nrdcash1 = craptfn.nrterfin.
            ELSE 
                ASSIGN tel_nrdcash1 = 0.
              
            FIND LAST  craptfn WHERE craptfn.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
            IF  AVAIL craptfn THEN 
                ASSIGN tel_nrdcash2 = craptfn.nrterfin.
            ELSE 
                ASSIGN tel_nrdcash2 = 0.

            DISPLAY tel_nrdcash1 tel_nrdcash2 WITH FRAME f_consulta.
        END.
   

   DO WHILE TRUE:
      
      FIND crapcop WHERE
           crapcop.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.
      
      IF   tel_nmdopcao  THEN
           DO:
               ASSIGN aux_nmdireto = "/micros/" + crapcop.dsdircop + "/".
               DISPLAY aux_nmdireto WITH FRAME f_consulta.
 
               UPDATE tel_nmdireto WITH FRAME f_consulta.
               
               ASSIGN aux_nmarqimp = aux_nmdireto + tel_nmdireto.
           END.
      ELSE
           ASSIGN aux_nmarqimp = "rl/dados_cash.txt".

      RELEASE crapcop.

      RUN fontes/confirma.p (INPUT "",
                            OUTPUT aux_confirma).

      IF  aux_confirma = "S"  THEN
          DO:
             MESSAGE  "Aguarde! Gerando Relatorio ...".
         
             EMPTY TEMP-TABLE w-movimento.
             
             ASSIGN aux_totsaque = 0
                    aux_totsaqin = 0
                    aux_totestor = 0
                    aux_totdepos = 0
                    aux_tottrans = 0
                    aux_tottrain = 0
                    aux_totsaldo = 0
                    aux_totextra = 0
                    aux_totsldfi = 0
                    aux_saldomed = 0.

             FOR EACH crapcop WHERE crapcop.cdcooper <> 3 
                 NO-LOCK BY crapcop.cdcooper:

                 IF  glb_cdcooper <> 3  AND 
                     glb_cdcooper <> crapcop.cdcooper THEN
                     NEXT.

                 ASSIGN aux_nrdcash1 = tel_nrdcash1
                        aux_nrdcash2 = tel_nrdcash2.

                 IF  glb_cdcooper = 3 THEN DO:

                     IF  tel_nrdcash1 = 0 THEN DO:
                         FIND FIRST craptfn WHERE craptfn.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

                         IF AVAIL craptfn THEN 
                             ASSIGN aux_nrdcash1 = craptfn.nrterfin.
                         ELSE 
                             ASSIGN aux_nrdcash1 = 0.
                     END.
                     IF  tel_nrdcash2 = 0 THEN DO:
                         FIND LAST craptfn WHERE craptfn.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
                         IF AVAIL craptfn THEN 
                             ASSIGN aux_nrdcash2 = craptfn.nrterfin.
                         ELSE 
                             ASSIGN aux_nrdcash2 = 0.
                     END.
                 END.

                 FOR EACH craptab WHERE
                          craptab.cdcooper = crapcop.cdcooper  AND 
                          craptab.nmsistem = "CRED"            AND
                          craptab.tptabela = "AUTOMA"          AND
                          craptab.tpregist >= aux_nrdcash1     AND
                          craptab.tpregist <= aux_nrdcash2
                          NO-LOCK:

                     IF   NOT(CAN-DO("SD,EC,IS",SUBSTRING(craptab.cdacesso,1,2)))
                          THEN  NEXT.
                     
                     IF   DATE(INT(SUBSTR(craptab.cdacesso,7,2)),
                             INT(SUBSTR(craptab.cdacesso,9,2)),
                             INT(SUBSTR(craptab.cdacesso,3,4))) > (tel_iniperio - 1)
                          AND
                          DATE(INT(SUBSTR(craptab.cdacesso,7,2)),
                             INT(SUBSTR(craptab.cdacesso,9,2)),
                             INT(SUBSTR(craptab.cdacesso,3,4))) < (tel_fimperio + 1)
                          THEN .   /* Continua Rotina Normalmente */
                     ELSE 
                          NEXT.
    
                     FIND FIRST w-movimento WHERE
                                w-movimento.cdcooper = crapcop.cdcooper  AND
                                w-movimento.nrdocash = craptab.tpregist  AND
                                w-movimento.dtmvtolt =
                                            DATE(INT(SUBSTR(craptab.cdacesso,7,2)),
                                                 INT(SUBSTR(craptab.cdacesso,9,2)),
                                                 INT(SUBSTR(craptab.cdacesso,3,4)))
                                NO-ERROR.
                                   
                     IF   NOT AVAILABLE w-movimento  THEN
                          DO:
                              FIND FIRST craptfn WHERE 
                                   craptfn.cdcooper = crapcop.cdcooper AND
                                   craptfn.nrterfin = INTE(craptab.tpregist)  
                                   NO-LOCK NO-ERROR.
                 
                              IF  NOT AVAIL craptfn THEN
                                  NEXT.

                              CREATE w-movimento.
                              ASSIGN w-movimento.cdcooper = craptab.cdcooper
                                     w-movimento.nrdocash = craptab.tpregist
                                     w-movimento.dtmvtolt =
                                            DATE(INT(SUBSTR(craptab.cdacesso,7,2)),
                                                 INT(SUBSTR(craptab.cdacesso,9,2)),
                                                 INT(SUBSTR(craptab.cdacesso,3,4)))
                                     w-movimento.cdagenci = craptfn.cdagenci.
                          END.
             
                     IF   SUBSTRING(craptab.cdacesso,1,2) = "SD"   THEN
                          ASSIGN w-movimento.qtsaldos = w-movimento.qtsaldos +
                                                        INT(craptab.dstextab).
                     ELSE
                     IF   SUBSTRING(craptab.cdacesso,1,2) = "EC"   THEN
                          ASSIGN w-movimento.qtextrat = w-movimento.qtextrat +
                                                        INT(craptab.dstextab).
                     ELSE
                          NEXT.
                                                      
                 END.
                 

                 /* Log Operacoes Caixa */
                 DO  aux_dtmvtolt = tel_iniperio TO tel_fimperio:
    
                     DO  aux_nrterfin = tel_nrdcash1 TO tel_nrdcash2:
                                                                   
                         FOR EACH crapltr WHERE crapltr.cdcoptfn = crapcop.cdcooper   AND 
                                                crapltr.dttransa = aux_dtmvtolt       AND
                                                crapltr.nrterfin = aux_nrterfin
                                                NO-LOCK:

                             FIND FIRST w-movimento WHERE 
                                        w-movimento.cdcooper = crapltr.cdcoptfn  AND
                                        w-movimento.nrdocash = crapltr.nrterfin  AND
                                        w-movimento.dtmvtolt = crapltr.dttransa  NO-ERROR.
                             
                             IF   NOT AVAILABLE w-movimento  THEN
                                  DO:
                                      FIND craptfn WHERE 
                                           craptfn.cdcooper = crapcop.cdcooper AND
                                           craptfn.nrterfin = crapltr.nrterfin  
                                           NO-LOCK NO-ERROR.
                         
                                      IF  NOT AVAIL craptfn THEN
                                          NEXT.

                                      CREATE w-movimento.
                                      ASSIGN w-movimento.cdcooper = crapcop.cdcooper
                                             w-movimento.nrdocash = crapltr.nrterfin
                                             w-movimento.dtmvtolt = crapltr.dttransa
                                             w-movimento.cdagenci = craptfn.cdagenci.
                                  END.
                         
                             IF   crapltr.cdhistor = 316  THEN
                                  DO:
                                      ASSIGN w-movimento.qtsaques = w-movimento.qtsaques + 1
                                             w-movimento.vlsaques = w-movimento.vlsaques +
                                                                    crapltr.vllanmto.
                                  END.
                             ELSE
                             IF  (crapltr.cdhistor = 359  OR
                                  crapltr.cdhistor = 767) THEN
                                  ASSIGN w-movimento.qtestorn = w-movimento.qtestorn + 1
                                         w-movimento.vlestorn = w-movimento.vlestorn + 
                                                                crapltr.vllanmto.
                             ELSE
                             IF   crapltr.cdhistor = 698  THEN
                                  ASSIGN w-movimento.qtdeposi = w-movimento.qtdeposi + 1
                                         w-movimento.vldeposi = w-movimento.vldeposi +
                                                                crapltr.vllanmto.
                             ELSE
                             IF   crapltr.cdhistor = 918 THEN DO:
                                  ASSIGN 
                                         w-movimento.qtsaqint = w-movimento.qtsaqint + 1
                                         w-movimento.vlsaqint = w-movimento.vlsaqint + 
                                                                 crapltr.vllanmto.
                             END.
                             ELSE
                             IF   crapltr.cdhistor = 920 THEN
                                  ASSIGN w-movimento.qtestint = w-movimento.qtestint + 1.
                         END.


                         /* Log de Transferencias, nao tem alimentacao do cdcoptfn */
                         FOR EACH crapltr WHERE (crapltr.dttransa = aux_dtmvtolt       AND
                                                 crapltr.nrterfin = aux_nrterfin       AND
                                                 crapltr.cdcooper = crapcop.cdcooper   AND
                                                 crapltr.cdhistor = 375)
                                                OR
                                                (crapltr.dttransa = aux_dtmvtolt       AND
                                                 crapltr.nrterfin = aux_nrterfin       AND
                                                 crapltr.cdcooper = crapcop.cdcooper   AND
                                                 crapltr.cdhistor = 376)
                                                OR
                                                (crapltr.dttransa = aux_dtmvtolt       AND
                                                 crapltr.nrterfin = aux_nrterfin       AND
                                                 crapltr.cdcooper = crapcop.cdcooper   AND
                                                 crapltr.cdhistor = 1009)              NO-LOCK:
                         
                             FIND FIRST w-movimento WHERE 
                                        w-movimento.cdcooper = crapcop.cdcooper  AND
                                        w-movimento.nrdocash = crapltr.nrterfin  AND
                                        w-movimento.dtmvtolt = crapltr.dttransa  NO-ERROR.
                             
                             IF   NOT AVAILABLE w-movimento  THEN
                                  DO:
                                      FIND craptfn WHERE 
                                           craptfn.cdcooper = crapcop.cdcooper AND
                                           craptfn.nrterfin = crapltr.nrterfin  
                                           NO-LOCK NO-ERROR.
                         
                                      IF  NOT AVAIL craptfn THEN
                                          NEXT.

                                      CREATE w-movimento.
                                      ASSIGN w-movimento.cdcooper = crapcop.cdcooper
                                             w-movimento.nrdocash = crapltr.nrterfin
                                             w-movimento.dtmvtolt = crapltr.dttransa
                                             w-movimento.cdagenci = craptfn.cdagenci.
                                  END.
                         
                             IF   crapltr.cdhistor = 1009   THEN
                                  ASSIGN w-movimento.qttraint = w-movimento.qttraint + 1
                                         w-movimento.vltraint = w-movimento.vltraint + 
                                                                crapltr.vllanmto.
                             ELSE
                                  ASSIGN w-movimento.qttransf = w-movimento.qttransf + 1
                                         w-movimento.vltransf = w-movimento.vltransf +
                                                                crapltr.vllanmto.
                         END.
                     END. /* Fim DO..TO.. */
                 END. /* Fim DO..TO.. */
      
                 /* Saldo diario Terminal Financeiro */
                 FOR EACH crapstf WHERE crapstf.dtmvtolt > (tel_iniperio - 1)  AND
                                        crapstf.dtmvtolt < (tel_fimperio + 1)  AND
                                        crapstf.nrterfin >= tel_nrdcash1       AND
                                        crapstf.nrterfin <= tel_nrdcash2       AND
                                        crapstf.cdcooper = crapcop.cdcooper 
                                        NO-LOCK:
    
                     FIND FIRST w-movimento WHERE
                                w-movimento.cdcooper = crapcop.cdcooper AND
                                w-movimento.nrdocash = crapstf.nrterfin AND
                                w-movimento.dtmvtolt = crapstf.dtmvtolt NO-ERROR.
                                   
                     IF   NOT AVAILABLE w-movimento  THEN
                          DO:
                              FIND craptfn WHERE 
                                   craptfn.cdcooper = crapcop.cdcooper AND
                                   craptfn.nrterfin = crapstf.nrterfin  
                                   NO-LOCK NO-ERROR.

                              IF  NOT AVAIL craptfn THEN
                                  NEXT.

                              CREATE w-movimento.
                              ASSIGN w-movimento.cdcooper = crapcop.cdcooper
                                     w-movimento.nrdocash = crapstf.nrterfin
                                     w-movimento.dtmvtolt = crapstf.dtmvtolt
                                     w-movimento.cdagenci = craptfn.cdagenci.
                          END.
                     
                     ASSIGN w-movimento.sldfinal = crapstf.vldsdfin
                            aux_totsldfi = aux_totsldfi + crapstf.vldsdfin
                            aux_qtdddias = aux_qtdddias + 1.
                 
                 END.
    
                 ASSIGN aux_saldomed = aux_totsldfi / aux_qtdddias.
             
             END. /* for each crapcop */

             /* Somente para utilizar  includes/impressao.i */
             FIND FIRST crapass NO-LOCK WHERE
                        crapass.cdcooper = glb_cdcooper NO-ERROR. 

             { includes/cabrel234_1.i }

             IF   tel_nmdopcao   THEN
                  OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp).
             ELSE
                  DO:
                      OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 62.
             
                      VIEW STREAM str_1 FRAME f_cabrel234_1.  
                  END.
             
             VIEW STREAM str_1 FRAME f_cabecalho_cecred.

             FOR EACH crapcop WHERE crapcop.cdcooper <> 3 
                 NO-LOCK BY crapcop.cdcooper:

                 IF  glb_cdcooper <> 3  AND 
                     glb_cdcooper <> crapcop.cdcooper THEN
                     NEXT.

                 ASSIGN aux_totsaque = 0
                        aux_totsaqin = 0
                        aux_totestor = 0
                        aux_totdepos = 0
                        aux_tottrans = 0
                        aux_tottrain = 0
                        aux_totsaldo = 0
                        aux_totextra = 0
                        aux_totsldfi = 0
                        aux_saldomed = 0.

                 /* Inicializa Variaveis Relatorio */
                 ASSIGN glb_cdcritic    = 0
                        glb_cdempres    = 11
                        glb_cdrelato[1] = 437
                        aux_tpcartao[1] = 0
                        aux_tpcartao[2] = 0
                        aux_tpcartao[3] = 0
                        aux_tpcartao[4] = 0
                        aux_tottpcar    = 0.

                 FOR EACH w-movimento WHERE w-movimento.cdcooper = crapcop.cdcooper
                     USE-INDEX cash1:
    
                     ASSIGN aux_totsaque = aux_totsaque + w-movimento.qtsaques
                            aux_totsaqin = aux_totsaqin + w-movimento.qtsaqint
                            aux_totestor = aux_totestor + w-movimento.qtestorn
                            aux_totsaldo = aux_totsaldo + w-movimento.qtsaldos
                            aux_totextra = aux_totextra + w-movimento.qtextrat
                            aux_totdepos = aux_totdepos + w-movimento.qtdeposi
                            aux_tottrans = aux_tottrans + w-movimento.qttransf
                            aux_tottrain = aux_tottrain + w-movimento.qttraint.
                      
                     DISPLAY STREAM str_1
                             w-movimento.cdcooper
                             w-movimento.cdagenci
                             w-movimento.dtmvtolt
                             w-movimento.nrdocash
                             w-movimento.qtsaques
                             w-movimento.vlsaques
                             w-movimento.qtsaqint
                             w-movimento.vlsaqint
                             w-movimento.vlestorn
                             w-movimento.qtestint
                             w-movimento.vltransf
                             w-movimento.qttransf
                             w-movimento.qttraint
                             w-movimento.vltraint
                             w-movimento.qtsaldos
                             w-movimento.qtdeposi
                             w-movimento.vldeposi
                             w-movimento.qtextrat
                             w-movimento.sldfinal
                             WITH FRAME f_dados1_cecred.
               
                     DOWN STREAM str_1 WITH FRAME f_dados1_cecred.  
                 
                     IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   AND
                          NOT tel_nmdopcao                         THEN
                          DO:
                              PAGE STREAM str_1.
                              VIEW STREAM str_1 FRAME f_cabrel234_1.  
                          END.             
                 END.
    
                 FOR EACH crapcrm NO-LOCK WHERE
                          crapcrm.cdcooper = crapcop.cdcooper.
    
                     ASSIGN aux_tpcartao[cdsitcar] = aux_tpcartao[cdsitcar] + 1.
        
                 END.
    
                 ASSIGN aux_tottpcar = aux_tpcartao[1] + aux_tpcartao[2] + 
                                       aux_tpcartao[3] + aux_tpcartao[4].

                 ASSIGN aux_tpcartao_1 = aux_tpcartao_1 + aux_tpcartao[1]
                        aux_tpcartao_2 = aux_tpcartao_2 + aux_tpcartao[2]
                        aux_tpcartao_3 = aux_tpcartao_3 + aux_tpcartao[3]
                        aux_tpcartao_4 = aux_tpcartao_4 + aux_tpcartao[4]
                        aux_tottpcar_c = aux_tottpcar_c + aux_tottpcar.

                 IF  NOT tel_nmdopcao  THEN DO:
                 
                     DISPLAY STREAM str_1
                                    crapcop.cdcooper
                                    aux_totsaque    aux_totsaqin    aux_totestor
                                    aux_totextra    aux_totsaldo    aux_totsldfi
                                    aux_totdepos    aux_tottrans    aux_tottrain
                                    aux_saldomed    aux_tpcartao[1] aux_tpcartao[2] 
                                    aux_tpcartao[3] aux_tpcartao[4] aux_tottpcar
                                    WITH FRAME f_dados2_cecred.
                 END.

             END. /* for each crapcop */

             OUTPUT STREAM str_1 CLOSE.
                 
             IF   tel_nmdopcao  THEN /* tel_nmdopcao = arquivo (yes) */
                  DO:
                      IF glb_cdcooper <> 3 THEN DO:
                          DISP aux_tpcartao[1] aux_tpcartao[2] 
                          aux_tpcartao[3] aux_tpcartao[4] 
                          aux_tottpcar
                          WITH FRAME f_dados.
                      END.
                      ELSE
                      DO:
                          DISP aux_tpcartao_1 aux_tpcartao_2 
                               aux_tpcartao_3 aux_tpcartao_4 
                               aux_tottpcar_c
                          WITH FRAME f_dados_cecred.
                      END.

                      UNIX SILENT VALUE("cp " + aux_nmarqimp + " " +  
                                         aux_nmarqimp + "_ux").
                      
                      UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + "_ux" + 
                                        ' | tr -d "\032"' +
                                        " > " + aux_nmdireto + tel_nmdireto + 
                                        " 2>/dev/null").
                      
                      /* apaga a copia */
                      UNIX SILENT VALUE("rm " + aux_nmarqimp + "_ux").
                  END.
             ELSE
                  DO:
                      ASSIGN glb_nmformul = "234dh".

                      { includes/impressao.i } 
                  END.


             HIDE MESSAGE NO-PAUSE.
             MESSAGE "Relatorio Gerado com Sucesso!!!".
             PAUSE(3) NO-MESSAGE.
             
             LEAVE.      
      
          END.
      ELSE
          DO:
              CLEAR FRAME f_cadgps.
              LEAVE.
          END.
   END.

END.   
    
/*............................................................................*/
