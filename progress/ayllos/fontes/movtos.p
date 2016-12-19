/*..............................................................................

   Programa: Fontes/movtos.p
   Sistema : Conta-Corrente - Cooperativa de Credito 
   Sigla   : CRED
   Autor   : Adriano
   Data    : Setembro/2010.                    Ultima Atualizacao: 05/12/2016

   Dados referentes ao programa:

   Frequencia: Diario 
   Objetivo  : Mostra a tela MOVTOS.
               Visualizacao de cooperados que nao tenham             
               movimentacao nos ultimos 6 meses.

   Alteracoes: 27/10/2010 - Incluida a opcao R (Henrique).

               05/10/2010 - Incluida a opcao L (Henrique).

               30/03/2011 - Incluido F7 para listar as opcoes. (Fabricio)

               05/04/2011 - Incluido a opcao "F" emprestimos em aberto da
                            empresa (Adriano).

               14/06/2011 - Incluido parametro na opcao "S" para listar todas
                            as contas ou, somente contas ITG (Adriano).

               18/10/2011 - Incluir Baca como opção "C" no programa movtos
                            (Isara - RKAM)

               20/12/2011 - Ajuste na opcao "L" (David).             

               23/03/2012 - Alteracoes na opcao C:
                            Mostrar o arquivo em um browse.
                            Incluir periodo para consulta.
                            Incluir saida do arquivo para diretorio padrao.
                            (Gabriel)  

               28/06/2012 - Alterada busca na tabela craplgm da opcao "L" ref.
                            cobranca (Diego). 

               03/07/2012 - Alteração na opcao "C" incluido novo campo "Tipo"
                            para novas modalidades de consulta (David Kruger).

               27/07/2012 - Efetuar tratamento nas opções F,L,R e S para
                            tambem gerar relatorios em arquivo (Lucas R).

               10/08/2012 - Ajuste na opcao "L" para utilizar nova descricao
                            em liberacoes de acesso a Internet (David).

               10/08/2012 - Inclusão da opção de situação do cartão para 
                            todos os cartões tambem. (Lucas R.)

               05/10/2012 - Criacao da opcao "A" Relacao dos emprestimos de
                            acordo com as linhas de creditos e finalidades
                            (Tiago).            

               29/11/2012 - Alteracao da funcao "L", relatorio diferenciado
                            para Cecred e para outras coops
                            (Guilherme/Supero)

               14/12/2012 - Inclusao da opcao "E" - Autorizacoes de Debito
                            (Guilherme/Supero)
                            
               21/12/2012 - Implementar opcao de geracao da base de cartoes
                            bradesco (Gabriel).             
                            
               06/02/2013 - Incluir campo de dia do debito nos relatorios da 
                            opcao C (Gabriel).            
                            
               28/02/2013 - Fechada a STREAM str_1 onde a procedure carrega_dados_c
                            é chamada e tirado o OUTPUT STREAM de dentro da
                            procedure (Daniele).     
                            
               07/03/2103 - Ajuste na verificacao se o cartao eh BB ou nao
                            (Gabriel).                       
                                  
               03/07/2013 - Criada procedure busca_valores_cartao que pega
                            o valor dos 3 ultimos meses da fatura do cartao 
                            especifico (Tiago).
                            
               09/07/2013 - Incluida coluna cpf no relatorio (Tiago).             
               
               05/11/2013 - Incluida validacoes da migracao da altovale(2013)
                            acredicop(2014) e alterado a descricao PAC para PA
                            (Tiago).
                            
               07/11/2013 - Ajsutes realizados:
                            - Ajustes necessarios para considerar movimentacao
                              dos ultimos 6 meses que eh buscado na procedeure
                              busca_valores_cartao;
                            - Incluido a procedure carrega_dados_cartoes_bb_bebito
                              e realizado os devidos ajustes para contemplar
                              o relatorio gerado nela.
                            (Adriano).     
                            
               02/12/2013 - Ajustes necessarios para considerar movimentacao
                            dos ultimos 3 meses que eh buscado na procedeure
                            busca_valores_cartao
                            (Adriano).                     
                         
               03/12/2013 - Ajustes realizados:
                            - Limitado em no maximo um mes, as consultas onde
                              informamos um periodo;
                            - Format nos campos do relatorio.
                            - Ajuste para memlhorar a performance na 
                              carrega_dados_cartoes_bb_bebito
                            (Adriano).        
               
               08/04/2014 - Adicionado parametros de paginacao em chamada da
                            proc. obtem-dados-emprestimos da BO0002. (Jorge) 
               
               28/04/2014 - Adaptado para a B1wgen0185.p - Jéssica Laverde (DB1) 
               
               10/06/2014 - Adicionado validacao dtdemiss = ? na opcao "L"
                            (Douglas - Chamado 159143)
                            
               16/06/2014 - Alterado cdlcremp de 3 posicoes para 4 Softdesk 
                            137074 (Lucas R.)
                            
               27/10/2014 - Não exibir cartões CECRED(sicobb) para outras cooperativas que 
                            não forem viacredi (Felipe)

               27/11/2014 - Ajustes para liberacao (Adriano).
               
               02/03/2015 - Ajustando format dos campos de codigo da
                            finalidade de emprestimo e da linha de
                            credito para "zzz9". SD - 259996.
                            (Andre Santos - SUPERO)
               
               05/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
.............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/b1wgen0185tt.i }
{ sistema/generico/includes/var_internet.i }

DEF STREAM str_1.

DEF VAR h-b1wgen0185 AS HANDLE                                    NO-UNDO. 
                                                                  
DEF VAR tel_cddopcao AS CHAR  FORMAT "!(1)"                       NO-UNDO.
DEF VAR tel_cdagenci AS INTE  FORMAT "zz9"                        NO-UNDO.
DEF VAR tel_tppessoa AS INTE  FORMAT "9"                          NO-UNDO.
DEF VAR tel_cdultrev AS INTE  FORMAT "zz9"                        NO-UNDO.
DEF VAR tel_dtinicio AS DATE  FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR tel_ddtfinal AS DATE  FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR tel_nmdireto AS CHAR  FORMAT "x(20)"                      NO-UNDO.
DEF VAR tel_dtprdini AS DATE  FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR tel_dtprdfin AS DATE  FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR tel_cdempres AS INTE  FORMAT "zzzz9"                      NO-UNDO.
DEF VAR tel_nmarquiv AS CHAR  FORMAT "x(25)"                      NO-UNDO.
DEF VAR tel_nmarqint AS CHAR  FORMAT "x(40)"                      NO-UNDO.
DEF VAR tel_tpcontas AS CHAR  FORMAT "x(10)"                      
      VIEW-AS COMBO-BOX LIST-ITEMS "TODAS",                       
                                   "CONTA ITG" PFCOLOR 2          NO-UNDO.
                                                                  
DEF VAR tel_tpdopcao AS   CHAR  FORMAT "X(13)"                    
      VIEW-AS COMBO-BOX INNER-LINES 3                             
      LIST-ITEMS "Todos Cartoes" , "Por Periodo" , "Gerar base"   NO-UNDO.
                                                                  
DEF VAR tel_dsadmcrd AS   CHAR  FORMAT "x(15)"                    
        VIEW-AS COMBO-BOX INNER-LINES 2                           
        LIST-ITEMS "BANCO DO BRASIL", "BRADESCO"                  
        INIT "BANCO DO BRASIL"                                    NO-UNDO.
                                                                  
DEF VAR tel_tpdomvto AS   CHAR  FORMAT "X(1)"                     
        VIEW-AS COMBO-BOX INNER-LINES 2                           
        LIST-ITEMS "C","D"                                        NO-UNDO.
                                                                  
DEF VAR tel_lgvisual AS CHAR  FORMAT "!(1)" INIT "T"              NO-UNDO.
DEF VAR aux_tamarqui AS CHAR                                      NO-UNDO.
DEF VAR tel_situacao AS CHAR                                      NO-UNDO.
DEF VAR aux_dsdopcao AS CHAR                                      NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                      NO-UNDO.
      
/* variaveis para impressao */
DEF VAR aux_contador AS INTE                                      NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                      NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                      NO-UNDO.
DEF VAR par_flgrodar AS LOGI  INIT TRUE                           NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                      NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                      NO-UNDO.
DEF VAR par_flgfirst AS LOGI  INIT TRUE                           NO-UNDO.
DEF VAR tel_dsimprim AS CHAR  INIT "Imprimir" FORMAT "x(8)"       NO-UNDO.
DEF VAR tel_dscancel AS CHAR  INIT "Cancelar" FORMAT "x(8)"       NO-UNDO.
DEF VAR par_flgcance AS LOGI                                      NO-UNDO.

DEF VAR aux_nmarqpdf AS CHAR                                      NO-UNDO.
DEF VAR aux_confirma AS CHAR  FORMAT "!(1)"                       NO-UNDO.
                                                                  
DEF VAR aux_ultlinha AS INTE                                      NO-UNDO.
DEF VAR aux_nmarqdst AS CHAR                                      NO-UNDO. 
DEF VAR aux_nmarquiv AS CHAR                                      NO-UNDO.
DEF VAR aux_dtrefere AS CHAR  EXTENT 3                            NO-UNDO.
DEF VAR aux_qtlibera AS INTE  EXTENT 3                            NO-UNDO.
DEF VAR aux_qtacesso AS INTE  EXTENT 3                            NO-UNDO.
DEF VAR aux_qtacetri AS INTE  EXTENT 3                            NO-UNDO.
DEF VAR aux_qtcopace AS INTE                                      NO-UNDO.    
DEF VAR aux_dtprdini AS DATE                                      NO-UNDO.
DEF VAR aux_dtprdfin AS DATE                                      NO-UNDO.

DEF VAR aux_sellincr AS CHAR                                      NO-UNDO.
DEF VAR aux_selfinal AS CHAR                                      NO-UNDO.
DEF VAR aux_flgresel AS LOGI INITIAL NO                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                      NO-UNDO. 
DEF VAR aux_nmdcampo AS INTE                                      NO-UNDO. 

DEF QUERY q-lincred            FOR tt-lincred.
DEF QUERY q-finalidade         FOR tt-finalidade.
DEF QUERY q-lista              FOR tt-lista SCROLLING.
DEF QUERY q_situacao           FOR tt-situacao.
DEF QUERY q_cartoes            FOR tt-cartoes.
DEF QUERY q_cartoes_debito_bb  FOR tt-cartoes.

DEF BROWSE b-lista QUERY q-lista
    DISPLAY cddopcao COLUMN-LABEL "Cod."
            dscopcao COLUMN-LABEL "Descricao"
            WITH CENTERED 5 DOWN WIDTH 76 TITLE "Selecione a opcao desejada".

DEF BROWSE b-lincred QUERY q-lincred
    DISPLAY tt-lincred.flgmarca COLUMN-LABEL "" FORMAT "*"
            tt-lincred.cdcodigo COLUMN-LABEL "Cod"       FORMAT "zzz9"
            tt-lincred.dsdescri COLUMN-LABEL "Descricao" FORMAT "x(28)"
            WITH 9 DOWN WIDTH 38 TITLE "Escolha Linha Credito".

DEF BROWSE b-finalidade QUERY q-finalidade
    DISPLAY tt-finalidade.flgmarca COLUMN-LABEL "" FORMAT "*"
            tt-finalidade.cdcodigo COLUMN-LABEL "Cod" FORMAT "zzz9"
            tt-finalidade.dsdescri COLUMN-LABEL "Descricao" FORMAT "x(28)"
            WITH 9 DOWN WIDTH 38 TITLE "Escolha finalidade".

DEF BROWSE b_situacao QUERY q_situacao
    DISPLAY tt-situacao.sqsitcrd  COLUMN-LABEL "SEQ."      FORMAT "9"
            tt-situacao.dssitcrd  COLUMN-LABEL "DESCRICAO" FORMAT "x(20)"
            WITH 7 DOWN WIDTH 30 TITLE "Situacao do Cartao".

DEF BROWSE b_cartoes QUERY q_cartoes
    DISPLAY tt-cartoes.nmrescop COLUMN-LABEL "Cooperativa"
            tt-cartoes.cdagenci COLUMN-LABEL "PA"               
            tt-cartoes.nrdconta COLUMN-LABEL "Conta/DV"          
            tt-cartoes.nrdctitg COLUMN-LABEL "Conta/ITG"         
            tt-cartoes.nmtitcrd COLUMN-LABEL "Titular do Cartao" FORMAT "x(27)"
            tt-cartoes.nrcpftit COLUMN-LABEL "CPF Titular"
                                             FORMAT "xxx.xxx.xxx-xx"
            tt-cartoes.dsadmcrd COLUMN-LABEL "Administradora"    FORMAT "x(15)"                   
            tt-cartoes.dssitcrd COLUMN-LABEL "Sit."              FORMAT "x(7)"    
            tt-cartoes.nrcrcard COLUMN-LABEL "Numero do Cartao/Conta Cartao"  
            tt-cartoes.dtpropos COLUMN-LABEL "Dt.Proposta"                                                          
            tt-cartoes.dtsolici COLUMN-LABEL "Dt.Pedido"      
            tt-cartoes.dtcancel COLUMN-LABEL "Dt.Cancelamento"                        
            tt-cartoes.dtentreg COLUMN-LABEL "Dt.Entrega"     
            tt-cartoes.dddebito COLUMN-LABEL "Dia do debito C/C"
            tt-cartoes.vllimcrd COLUMN-LABEL "Limite de Credito"
            tt-cartoes.vllimdeb COLUMN-LABEL "Limite de Debito"
            tt-cartoes.nrreside COLUMN-LABEL "Telefone Res."
            tt-cartoes.nrcelula COLUMN-LABEL "Telefone Cel."
            tt-cartoes.vlrrendi COLUMN-LABEL "Rendimento"
            tt-cartoes.outroren COLUMN-LABEL "Outros Rendimentos"
            tt-cartoes.vlfatdb1 COLUMN-LABEL "Fatura"
            tt-cartoes.vlfatdb2 COLUMN-LABEL "Fatura"
            tt-cartoes.vlfatdb3 COLUMN-LABEL "Fatura"
            WITH 12 DOWN WIDTH 78 TITLE " CARTOES ".       

DEF BROWSE b_cartoes_debito_bb QUERY q_cartoes_debito_bb
    DISPLAY tt-cartoes.dtmvtolt COLUMN-LABEL "Data"
            tt-cartoes.nmrescop COLUMN-LABEL "Cooperativa"
            tt-cartoes.cdagenci COLUMN-LABEL "PA"               
            tt-cartoes.nrdconta COLUMN-LABEL "Conta/DV"          
            tt-cartoes.nrdctitg COLUMN-LABEL "Conta/ITG"         
            tt-cartoes.nmtitcrd COLUMN-LABEL "Titular do Cartao" FORMAT "x(27)"
            tt-cartoes.nrcpftit COLUMN-LABEL "CPF Titular"
                                             FORMAT "xxx.xxx.xxx-xx"
            tt-cartoes.dsadmcrd COLUMN-LABEL "Administradora"    FORMAT "x(15)"                   
            tt-cartoes.dssitcrd COLUMN-LABEL "Sit."              FORMAT "x(7)"    
            tt-cartoes.nrcrcard COLUMN-LABEL "Conta Cartao"  
            tt-cartoes.dtpropos COLUMN-LABEL "Dt.Proposta"                                                          
            tt-cartoes.dtsolici COLUMN-LABEL "Dt.Pedido"      
            tt-cartoes.dtcancel COLUMN-LABEL "Dt.Cancelamento"                        
            tt-cartoes.dtentreg COLUMN-LABEL "Dt.Entrega"     
            tt-cartoes.dddebito COLUMN-LABEL "Dia do debito C/C"
            tt-cartoes.vllimcrd COLUMN-LABEL "Limite de Credito"
            tt-cartoes.vllimdeb COLUMN-LABEL "Limite de Debito"
            tt-cartoes.nrreside COLUMN-LABEL "Telefone Res."
            tt-cartoes.nrcelula COLUMN-LABEL "Telefone Cel."
            tt-cartoes.vlrrendi COLUMN-LABEL "Rendimento"
            tt-cartoes.outroren COLUMN-LABEL "Outros Rend."
            tt-cartoes.histo613 COLUMN-LABEL "Hist.613 DB."
            tt-cartoes.histo614 COLUMN-LABEL "Hist.614 SAQ."
            tt-cartoes.histo668 COLUMN-LABEL "Hist.668 TRF."
            WITH 12 DOWN WIDTH 78 TITLE " CARTOES ".  

FORM b-lista
    WITH NO-BOX OVERLAY ROW 6 COLUMN 3 WIDTH 76 FRAME f_lista.

FORM b-finalidade
    HELP "Barra de espaco para selecionar. <F1> ou <ENTER> para confirmar"
    WITH NO-BOX OVERLAY ROW 8 COLUMN 42 WIDTH 38 FRAME f_finalidade.

FORM b-lincred
    HELP "Barra de espaco para selecionar. <F1> ou <ENTER> para confirmar"
    WITH NO-BOX OVERLAY ROW 8 COLUMN 2 WIDTH 38 FRAME f_lincred.

FORM b_cartoes
    WITH SCROLLABLE NO-BOX OVERLAY ROW 6 WIDTH 78 CENTERED FRAME f_cartoes.

FORM b_cartoes_debito_bb
    WITH SCROLLABLE NO-BOX OVERLAY ROW 6 WIDTH 78 
         CENTERED FRAME f_cartoes_debito_bb.

FORM SKIP(1)
    tel_cddopcao COLON 10 LABEL "Opcao"   AUTO-RETURN
          HELP "Informe a opcao desejada (C,F,L,R,S,A,E) ou <F7> para listar."
    VALIDATE(CAN-DO("C,F,L,R,S,A,E",tel_cddopcao), "014 - Opcao errada.")
    SKIP(14)
    WITH ROW 4 OVERLAY WIDTH 80 SIDE-LABELS TITLE glb_tldatela FRAME f_movtos.

FORM SKIP(1)
    tel_cdagenci LABEL "PA" AUTO-RETURN
                 HELP "Entre com o numero do PA." 
    VALIDATE(CAN-FIND(crapage NO-LOCK WHERE
                      crapage.cdcooper = glb_cdcooper AND
                      crapage.cdagenci = tel_cdagenci),
                      "PA nao cadastrado.")
    tel_tpcontas AT 20 AUTO-RETURN LABEL "Conta"
                 HELP "Informe o tipo da conta."
    WITH NO-BOX ROW 5 COLUMN 20 OVERLAY SIDE-LABELS FRAME f_movtos_s.    

FORM SKIP(1)
    tel_cdagenci LABEL "PA" AUTO-RETURN
                 HELP "Entre com o numero do PA." 
                 VALIDATE(CAN-FIND(crapage NO-LOCK WHERE
                                   crapage.cdcooper = glb_cdcooper AND
                                   crapage.cdagenci = tel_cdagenci),
                                   "PA nao cadastrado.")
    SPACE(3)
    tel_tppessoa LABEL "Tp.Natureza" AUTO-RETURN
                 HELP "1 - Fisica, 2 - Juridica"
                 VALIDATE(CAN-DO("1,2",tel_tppessoa),"014 - Opcao errada.")
    SPACE(3)
    tel_cdultrev LABEL "Revisao a mais de" AUTO-RETURN
                 HELP "Informe o numero de meses"
                 VALIDATE(NOT CAN-DO("0",tel_cdultrev),
                          "O periodo deve ser superior a 0.")
    WITH NO-BOX ROW 5 COLUMN 20 OVERLAY SIDE-LABELS FRAME f_movtos_r.    

FORM SKIP(1)
    tel_tpdopcao LABEL "Tipo"
                 HELP "'T' para todos os cartoes e 'P' por periodo."
    SPACE(2)             
    WITH NO-BOX ROW 5 COLUMN 17 OVERLAY SIDE-LABELS FRAME f_movtos_tp.

FORM SKIP(1)
    tel_dtinicio LABEL "Inicial" AUTO-RETURN
                 HELP "Data inicial do periodo desejado."           
                 VALIDATE(tel_dtinicio <> ?, "Informe a data inicial")
    SPACE(1)
    tel_ddtfinal LABEL "Final" AUTO-RETURN
                 HELP "Data final do periodo desejado."
                 VALIDATE(tel_ddtfinal <> ?, "Informe a data final")
                  
    WITH NO-BOX ROW 5 COLUMN 42 OVERLAY SIDE-LABELS FRAME f_movtos_l.
     
FORM SKIP(1)
    tel_cdempres LABEL "Empresa"   
                 HELP "Informe o codigo da empresa."
    WITH NO-BOX ROW 5 COLUMN 20 OVERLAY SIDE-LABELS FRAME f_movtos_f.

FORM tel_dsadmcrd LABEL "Cartao"   
                  HELP "Selecione o cartao"
    WITH NO-BOX ROW 7 COLUMN 21 OVERLAY SIDE-LABELS FRAME f_movtos_c1.

FORM tel_tpdomvto LABEL "Movimento"   
                  HELP "Selecione o tipo de movimento: (C)redito/(D)ebito."
    WITH NO-BOX ROW 8 COLUMN 21 OVERLAY SIDE-LABELS FRAME f_movtos_c2.

FORM tel_dtprdini LABEL "Inicial" AUTO-RETURN
                  HELP "Data inicial do periodo desejado."           
                  VALIDATE(tel_dtprdini <> ?, "Informe a data inicial")
    SPACE(1)
    tel_dtprdfin LABEL "Final" AUTO-RETURN
                 HELP "Data final do periodo desejado."
                 VALIDATE(tel_dtprdfin <> ?, "Informe a data inicial")
                  
    WITH NO-BOX ROW 9 COLUMN 23 OVERLAY SIDE-LABELS FRAME f_movtos_c3.

FORM b_situacao  
    HELP "Pressione <DEL> p/ Excluir / <F4> p/ Sair / <F1> p/ Continuar"
    WITH NO-BOX ROW 10 COLUMN 20 OVERLAY SIDE-LABELS FRAME f_movtos_c4.

FORM "Diretorio:   "     AT 5
    tel_nmdireto
    tel_nmarquiv        HELP "Informe o nome do arquivo."
    WITH OVERLAY ROW 10 NO-LABEL NO-BOX COLUMN 2 FRAME f_diretorio.     
          
 FORM SKIP(1)
    "Diretorio:   "    
    tel_nmdireto
    tel_nmarquiv        HELP "Informe o nome do arquivo."
    WITH OVERLAY ROW 5 COLUMN 18 NO-LABEL NO-BOX FRAME f_diretorio_a.     


FORM crapcop.nmrescop NO-LABEL 
    SKIP(1)
    aux_dtrefere[1] NO-LABEL FORMAT "x(7)"    AT 24
    aux_dtrefere[2] NO-LABEL FORMAT "x(7)"
    aux_dtrefere[3] NO-LABEL FORMAT "x(7)"
    SKIP
    "------- ------- -------" AT 24
    SKIP
    "Liberacoes de acesso:"
    aux_qtlibera[1] NO-LABEL FORMAT "zzz,zz9" AT 23
    aux_qtlibera[2] NO-LABEL FORMAT "zzz,zz9"
    aux_qtlibera[3] NO-LABEL FORMAT "zzz,zz9"
    SKIP
    "Contas que acessaram:"
    aux_qtacetri[1] NO-LABEL FORMAT "zzz,zz9" AT 23
    aux_qtacetri[2] NO-LABEL FORMAT "zzz,zz9"
    aux_qtacetri[3] NO-LABEL FORMAT "zzz,zz9"
    SKIP
    "    Total de acessos:"
    aux_qtacesso[1] NO-LABEL FORMAT "zzz,zz9" AT 23
    aux_qtacesso[2] NO-LABEL FORMAT "zzz,zz9"
    aux_qtacesso[3] NO-LABEL FORMAT "zzz,zz9"
    SKIP(1)
    aux_qtcopace LABEL "Cooperados com acesso liberado" FORMAT "zzz,zz9"
    SKIP(2)
    WITH NO-BOX SIDE-LABELS FRAME f_totais.


ON ANY-KEY OF BROWSE b-lincred
   DO:
      IF LASTKEY = 8   OR 
         LASTKEY = 32  OR 
         LASTKEY = 127 THEN
         DO:
            IF LASTKEY = 32 THEN
               DO:
                  IF tt-lincred.flgmarca = NO THEN
                     ASSIGN tt-lincred.flgmarca = YES.
                  ELSE
                      ASSIGN tt-lincred.flgmarca = NO.
               END.
            ELSE
               ASSIGN tt-lincred.flgmarca = NO.
   
            ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("q-lincred").
   
            OPEN QUERY q-lincred FOR EACH tt-lincred NO-LOCK 
                                       BY tt-lincred.cdcodigo.
   
            REPOSITION q-lincred TO ROW aux_ultlinha.
   
            VIEW FRAME f_lincred.

         END.
   
      IF KEY-FUNCTION(LASTKEY) = "TAB"    OR 
         KEY-FUNCTION(LASTKEY) = "RETURN" THEN
         DO:
             APPLY "GO".
         END.
   
   END.

ON ANY-KEY OF BROWSE b-finalidade
   DO:
      IF LASTKEY = 8   OR 
         LASTKEY = 32  OR 
         LASTKEY = 127 THEN
         DO:
            IF LASTKEY = 32 THEN
               DO:
                  IF tt-finalidade.flgmarca = NO THEN
                     ASSIGN tt-finalidade.flgmarca = YES.
                  ELSE
                     ASSIGN tt-finalidade.flgmarca = NO.
               END.
            ELSE
               ASSIGN tt-finalidade.flgmarca = NO.
   
            ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("q-finalidade").
   
            OPEN QUERY q-finalidade FOR EACH tt-finalidade NO-LOCK 
                                          BY tt-finalidade.cdcodigo.
   
            REPOSITION q-finalidade TO ROW aux_ultlinha.
   
            VIEW FRAME f_finalidade.

         END.
   
         IF KEY-FUNCTION(LASTKEY) = "TAB"    OR
            KEY-FUNCTION(LASTKEY) = "RETURN" THEN
            DO:
                APPLY "GO".
            END.

   END.

ON RETURN OF tel_tpcontas 
   DO:
      APPLY "GO".
   END.

ON RETURN OF tel_dsadmcrd 
   DO:
      APPLY "GO".
   END.

ON RETURN OF tel_tpdomvto 
   DO:
      APPLY "GO".
   END.

ON RETURN OF tel_tpdopcao 
   DO:
      APPLY "GO". 
   END.

ON RETURN OF b-lista IN FRAME f_lista 
   DO:
      IF AVAILABLE tt-lista THEN
         DO:
            ASSIGN tel_cddopcao = tt-lista.cddopcao.
   
            DISPLAY tel_cddopcao WITH FRAME f_movtos.
         END.
   
   	HIDE FRAME f_lista.
   
   	APPLY "GO".

   END.

ON RETURN OF b_situacao IN FRAME f_movtos_c4
   DO:
      APPLY "GO".
   END.
   
ON "DELETE" OF b_situacao IN FRAME f_movtos_c4 
   DO:
      IF NOT AVAILABLE tt-situacao THEN
         RETURN.
           
      DELETE tt-situacao. 
      
      /* linha que foi deletada */
      ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("q_situacao").

      OPEN QUERY q_situacao FOR EACH tt-situacao.
   
      /* reposiciona o browse */
      REPOSITION q_situacao TO ROW aux_ultlinha.

   END.

EMPTY TEMP-TABLE tt-lista.

CREATE tt-lista.
ASSIGN tt-lista.cddopcao = "C"
       tt-lista.dscopcao = "Relacao de cartao de credito".

CREATE tt-lista.
ASSIGN tt-lista.cddopcao = "F"
       tt-lista.dscopcao = "Emprestimos em aberto da empresa".

CREATE tt-lista.
ASSIGN tt-lista.cddopcao = "L"
       tt-lista.dscopcao = 
          "Qtde liberacoes para uso Internet, emissao boletos e Ura no periodo".

CREATE tt-lista.
ASSIGN tt-lista.cddopcao = "R"
       tt-lista.dscopcao = "Cooperados e data do ultimo recadastramento".
       
CREATE tt-lista.
ASSIGN tt-lista.cddopcao = "S"
       tt-lista.dscopcao = 
          "Contas sem movimentacao a mais de seis meses no PA".

CREATE tt-lista.
ASSIGN tt-lista.cddopcao = "A"
       tt-lista.dscopcao = "Gerar arquivo de empr/fin. por linha de credito e finalidade.".


CREATE tt-lista.
ASSIGN tt-lista.cddopcao = "E"
       tt-lista.dscopcao = "Relacao de autorizacoes de debito".

ASSIGN glb_cddopcao = "C".
                             
DO WHILE TRUE:
   
   RUN fontes/inicia.p.

   CLEAR FRAME f_movtos NO-PAUSE.
   HIDE FRAME f_lista.
    
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
     
      ASSIGN tel_cddopcao = "C"
   	         tel_cdagenci = 0
             tel_tppessoa = 0
             tel_cdultrev = 0
             tel_tpdopcao = "Todos Cartoes"
             tel_tpdomvto:SCREEN-VALUE = "C"
             tel_tpcontas:SCREEN-VALUE = "TODAS"
             tel_dsadmcrd:SCREEN-VALUE = "BANCO DO BRASIL"
             tel_dtprdini = ?
             tel_dtprdfin = ?
             tel_dtinicio = ?
             tel_ddtfinal = ?
             tel_nmarquiv = ""
             tel_situacao = ""
             aux_dtprdini = ?
             aux_dtprdfin = ?
             aux_confirma = ""
             aux_sellincr = ""
             aux_selfinal = ""
             aux_flgresel = FALSE
             aux_nmarquiv = ""
             tel_cdempres = 0. 

   	  UPDATE tel_cddopcao WITH FRAME f_movtos
       
   	  EDITING:
         READKEY.
         
         IF LASTKEY = KEYCODE("F7") THEN
            DO:
               IF FRAME-FIELD = "tel_cddopcao" THEN
                  DO:
                     OPEN QUERY q-lista FOR EACH tt-lista.
               
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE b-lista WITH FRAME f_lista.
                        LEAVE.
                     END.
               
                     HIDE FRAME f_lista.
                  END.
               ELSE
                  APPLY LASTKEY.
            END.
         ELSE
            APPLY LASTKEY.

   	  END.
       
      LEAVE.

   END.

   IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
      DO:             
         RUN fontes/novatela.p.
                    
         IF CAPS(glb_nmdatela) <> "MOVTOS" THEN
            DO:
                HIDE FRAME f_movtos.
                HIDE FRAME f_movtos_s.
                HIDE FRAME f_movtos_r.
                HIDE FRAME f_movtos_l.
                HIDE FRAME f_movtos_f.
                HIDE FRAME f_movtos_c1.
                HIDE FRAME f_movtos_c4.
                HIDE FRAME f_movtos_op.
                RETURN.
            END.
         ELSE
            NEXT.
      END.

   IF aux_cddopcao <> glb_cddopcao   THEN
      DO:
          { includes/acesso.i }
          ASSIGN aux_cddopcao = glb_cddopcao
                 glb_cdcritic = 0.

      END.  
   
   IF tel_cddopcao = "S" THEN
      DO:
          VIEW FRAME f_movtos_s.

          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
          
             UPDATE tel_cdagenci 
                    tel_tpcontas WITH FRAME f_movtos_s.

             LEAVE.

          END.

          IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
             NEXT.

      END. /* Fim opcao S */
   ELSE
   IF tel_cddopcao = "R" THEN
      DO:
         VIEW FRAME f_movtos_r.             
      
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            UPDATE tel_cdagenci 
                   tel_tppessoa 
                   tel_cdultrev 
                   WITH FRAME f_movtos_r. 

   	   	    LEAVE.

         END.
      
         IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            NEXT.

      END. /* Fim da opcao R */
   ELSE
   IF tel_cddopcao = "L" THEN
      DO:
         VIEW FRAME f_movtos_l.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            UPDATE tel_dtinicio 
                   tel_ddtfinal  
                   WITH FRAME f_movtos_l.

            LEAVE.

         END.

         IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            NEXT.

         ASSIGN aux_dtprdini = tel_dtinicio
                aux_dtprdfin = tel_ddtfinal.

      END. /* Fim opcao L */
   ELSE
   IF tel_cddopcao = "F" THEN
      DO:
         ASSIGN tel_cdempres = 0.

         VIEW FRAME f_movtos_f.
          
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
            UPDATE tel_cdempres 
                   WITH FRAME f_movtos_f.

   	   	    LEAVE.

         END.

         IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
            NEXT.

      END. /* Fim da opcao F */
   ELSE
   IF tel_cddopcao = "C" THEN
   	  DO: 
   	 	 HIDE tel_dtinicio tel_ddtfinal IN FRAME f_movtos_l.
         
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   	 	    UPDATE tel_tpdopcao 
                   WITH FRAME f_movtos_tp.

            LEAVE.

         END.
         
         IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
            DO:
               HIDE FRAME f_movtos_tp.
               NEXT.

            END.

   	 	 IF tel_tpdopcao:SCREEN-VALUE = "Por Periodo" THEN
   	 	 	DO:
   	 	 	   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  UPDATE tel_dtinicio 
                         tel_ddtfinal  
                         WITH FRAME f_movtos_l.

                  LEAVE.

               END.
                
   	 	 	   IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
   	 	 	   	  NEXT.

               ASSIGN aux_dtprdini = tel_dtinicio 
                      aux_dtprdfin = tel_ddtfinal.
                
   	 	 	   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
   	 	 	   	  UPDATE tel_dsadmcrd 
                         WITH FRAME f_movtos_c1.
         
   	 	 	      LEAVE.
         
   	 	 	   END.
                    
   	 	 	   IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
   	 	 	   	  DO: 
   	 	 	   	  	 HIDE FRAME f_movtos_c1.
   	 	 	   	     NEXT.
   	 	 	   	  END.
         
               RUN conecta_handle.

   	 	 	   RUN carrega_situacao IN h-b1wgen0185(INPUT tel_dsadmcrd:SCREEN-VALUE,
                                                    INPUT TRUE, /*flgconsu*/
                                                    INPUT tel_situacao,
                                                    OUTPUT TABLE tt-situacao).

               RUN desconecta_handle.

               IF RETURN-VALUE <> "OK" THEN
                  DO:
                      MESSAGE "Nao foi possivel carregar as situacoes.".
                      NEXT.

                  END.
                    
   	 	 	   OPEN QUERY q_situacao FOR EACH tt-situacao.
                
   	 	 	   IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
   	 	 	   	  LEAVE.
                
   	 	 	   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:   
         
   	 	 	   	  UPDATE b_situacao
                         WITH FRAME f_movtos_c4.
         
   	 	 	   	  FOR EACH tt-situacao:
   	 	 	   	      ASSIGN tel_situacao = tel_situacao + 
                                            STRING(tt-situacao.sqsitcrd) + ",".
   	 	 	   	  END.
                  
   	 	 	   	  LEAVE.
         
   	 	 	   END.
                
   	 	 	   IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
   	 	 	      LEAVE.
                     
   	 	 	END.
   	 	 ELSE
   	 	 IF tel_tpdopcao:SCREEN-VALUE = "Todos Cartoes" THEN
   	 	 	DO:
   	 	 	   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
   	 	 	      UPDATE tel_dsadmcrd 
                         WITH FRAME f_movtos_c1.
         
   	 	 	   	  LEAVE.
         
   	 	 	   END.
         
   	 	 	   IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
   	 	 	      DO: 
   	 	 	         HIDE FRAME f_movtos_c1.
   	 	 	       	 NEXT.
   	 	 	      END.
         
   	 	 	   IF tel_dsadmcrd:SCREEN-VALUE <> "BRADESCO" THEN
   	 	 	   	  DO:
   	 	 	   	  	 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     
   	 	 	   	  	 	UPDATE tel_tpdomvto 
   	 	 	   	  	           WITH FRAME f_movtos_c2.
                     
   	 	 	   	  	 	LEAVE.
                     
   	 	 	   	  	 END.
                             
   	 	 	   	  	 IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
   	 	 	   	  	 	DO: 
   	 	 	   	  	 		HIDE FRAME f_movtos_c2.
   	 	 	   	  	 		NEXT.
   	 	 	   	  	 	END.
                     
   	 	 	   	  	 IF tel_tpdomvto:SCREEN-VALUE = "D" THEN
   	 	 	   	  	 	DO:
   	 	 	   	  	 	   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                   
   	 	 	   	  	 	      UPDATE tel_dtprdini 
   	 	 	   	  	 	   	         tel_dtprdfin 
   	 	 	   	  	 	             WITH FRAME f_movtos_c3.
                     
   	 	 	   	  	 	   	  /*Por questoes de performance na leitura da lcm,
   	 	 	   	  	 	   	   o periodo informado sera limitado em no maximo
   	 	 	   	  	 	   	   um mes para realizacao da consulta.*/
   	 	 	   	  	 	   	  IF ADD-INTERVAL(tel_dtprdfin,-(tel_dtprdfin - 
   	 	 	   	  	 	   	   		           tel_dtprdini),"DAY") <
   	 	 	   	  	 	   	     ADD-INTERVAL(tel_dtprdfin,-1,"MONTH") THEN
   	 	 	   	  	 	   	   	 DO:
   	 	 	   	  	 	   	   	     MESSAGE "Periodo de consulta deve "    +
   	 	 	   	  	 	   	   	             "contemplar no maximo um mes.".
                               
   	 	 	   	  	 	   	   		 NEXT.
                               
   	 	 	   	  	 	   	     END.
                               
   	 	 	   	  	 	   	   IF tel_dtprdfin < tel_dtprdini THEN
   	 	 	   	  	 	   	   	  DO:
   	 	 	   	  	 	   	   	      MESSAGE "Data inicial deve ser menor " + 
   	 	 	   	  	 	   	   		          "que a final.".
                               
   	 	 	   	  	 	   	   		  NEXT.
                               
   	 	 	   	  	 	   	   	  END.
                                     
   	 	 	   	  	 	   	   LEAVE.
                     
   	 	 	   	  	 	   END.
                                  
   	 	 	   	  	 	   IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
   	 	 	   	  	 	   	  DO: 
   	 	 	   	  	 	   	  	 HIDE FRAME f_movtos_c3.
   	 	 	   	  	 	   		 NEXT.
   	 	 	   	  	 	   	  END.
                     
   	 	 	   	  	 	   ASSIGN aux_dtprdini = tel_dtprdini
                                  aux_dtprdfin = tel_dtprdfin.
                     
   	 	 	   	  	 	END.
   	 	 	   	  END.
         
               RUN conecta_handle.

               RUN carrega_situacao IN h-b1wgen0185(INPUT tel_dsadmcrd:SCREEN-VALUE,
                                                    INPUT TRUE, /*flgconsu*/
                                                    INPUT tel_situacao,
                                                    OUTPUT TABLE tt-situacao).

               RUN desconecta_handle.
               
               IF RETURN-VALUE <> "OK" THEN
                  DO:
                      MESSAGE "Nao foi possivel carregar as situacoes.".
                      NEXT.

                  END.
                    
   	 	 	   OPEN QUERY q_situacao FOR EACH tt-situacao.
         
   	 	 	   IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
   	 	 	   	  LEAVE.
         
   	 	 	   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:  
         
   	 	 	   	  UPDATE b_situacao 
   	 	 	   	         WITH FRAME f_movtos_c4.
                  
   	 	 	   	  FOR EACH tt-situacao:
   	 	 	   	      ASSIGN tel_situacao = tel_situacao + 
                                            STRING(tt-situacao.sqsitcrd) + ",".
   	 	 	   	  END.
                  
   	 	 	   	  LEAVE.
                  
   	 	 	   END.
                
   	 	 	   IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
   	 	 	   	  LEAVE.    
         
   	 	 	END.
         ELSE         
            ASSIGN tel_lgvisual = "A".
              
         ASSIGN aux_dsdopcao = "(T)erminal ou (A)rquivo: ".

         tt-cartoes.vlfatdb1:LABEL IN BROWSE b_cartoes = "Fatura "             +
                 STRING(MONTH(ADD-INTERVAL(glb_dtmvtolt, -3, "months"))) + "/" +
                 STRING(YEAR(ADD-INTERVAL(glb_dtmvtolt, -3, "months"))).
                
         tt-cartoes.vlfatdb2:LABEL IN BROWSE b_cartoes = "Fatura "             +
                 STRING(MONTH(ADD-INTERVAL(glb_dtmvtolt, -2, "months"))) + "/" +
                 STRING(YEAR(ADD-INTERVAL(glb_dtmvtolt, -2, "months"))).
                
         tt-cartoes.vlfatdb3:LABEL IN BROWSE b_cartoes = "Fatura "             +
                 STRING(MONTH(ADD-INTERVAL(glb_dtmvtolt, -1, "months"))) + "/" +
                 STRING(YEAR(ADD-INTERVAL(glb_dtmvtolt, -1, "months"))).
         
   	 END. /* Fim da opcao C */
   ELSE         
   IF tel_cddopcao = "A" THEN
   	  DO: 
   	  	 IF glb_cddepart = 20  OR   /* TI         */
   	  	 	  glb_cddepart = 11  OR   /* FINANCEIRO */
   	  	 	  glb_cddepart = 18  THEN /* SUPORTE    */
            DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
                  RUN conecta_handle.
               
                  MESSAGE "Aguarde consultando informacoes...".
                  
                  RUN busca_linhas_finalidades 
                      IN h-b1wgen0185(INPUT glb_cdcooper,
                                      INPUT 0, /*cdagenci*/
                                      INPUT 0, /*nrdcaixa*/ 
                                      INPUT glb_cdoperad,
                                      INPUT glb_nmdatela,
                                      INPUT 1, /*idorigem*/
                                      INPUT glb_cddepart,
                                      INPUT glb_dtmvtolt,
                                      INPUT 0, /*nrregist*/
                                      INPUT 9999, /*nriniseq*/
                                      INPUT TRUE, /*flgerlog*/
                                      OUTPUT aux_qtregist,
                                      OUTPUT aux_nmdcampo, 
                                      OUTPUT TABLE tt-lincred,
                                      OUTPUT TABLE tt-finalidade,
                                      OUTPUT TABLE tt-erro) NO-ERROR. 
               
                  HIDE MESSAGE NO-PAUSE.
                  
                  RUN desconecta_handle.
                  
                  IF ERROR-STATUS:ERROR THEN
                     DO:
                        MESSAGE ERROR-STATUS:GET-MESSAGE(1).
                        LEAVE.
                     END.
                  
                  IF RETURN-VALUE <> "OK"           OR 
                     TEMP-TABLE tt-erro:HAS-RECORDS THEN
                     DO:
                        FIND FIRST tt-erro NO-ERROR.
                  
                        IF AVAILABLE tt-erro THEN
                           MESSAGE tt-erro.dscritic.
                  
                        LEAVE.
                  
                     END.
                  
                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                     IF NOT aux_flgresel THEN
                        DO: 
                           /*digita caminho arquivo a ser gerado*/
                           RUN caminho_arquivo(INPUT glb_cdcooper,
                                               OUTPUT aux_nmarquiv).
                  
                           IF KEY-FUNCTION(LASTKEY) = "END-ERROR" THEN
	              	   	  	  LEAVE.
               
                        END.
                     ELSE
                        ASSIGN aux_flgresel = NO.
               
                     /*mostra os browsers para selecao das linhas*/
                     OPEN QUERY q-lincred FOR EACH tt-lincred NO-LOCK 
                                                   BY tt-lincred.cdcodigo.  
                        
                     VIEW FRAME f_lincred. 
                     
                     /*mostra os browsers para selecao das finalidades*/
                     OPEN QUERY q-finalidade FOR EACH tt-finalidade NO-LOCK 
                                                 BY tt-finalidade.cdcodigo.  
               
                     VIEW FRAME f_finalidade. 
                  
                     /*(update)selecionar linhas de credito*/
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE b-lincred WITH FRAME f_lincred.
                        LEAVE.
                     END.
                     
                     IF KEY-FUNCTION(LASTKEY) = "END-ERROR" THEN
                        DO:
                           CLOSE QUERY q-lincred.
                           CLOSE QUERY q-finalidade.
               
                           HIDE FRAME f_lincred.
                           HIDE FRAME f_finalidade.
               
                           NEXT.
                        END.
               
                     /*(update)selecionar finalidades*/
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE b-finalidade WITH FRAME f_finalidade.
                        LEAVE.
                     END. 
               
                     CLOSE QUERY q-lincred.
                     CLOSE QUERY q-finalidade.
               
                     HIDE FRAME f_lincred.
                     HIDE FRAME f_finalidade.
               
                     IF KEY-FUNCTION(LASTKEY) = "END-ERROR" THEN
                        NEXT.
                     
                     /*mostra os registros selecionados no browser 
                       para conferencia do usuario e retorna a lista
                       para geracao do arquivo*/
                     ASSIGN aux_sellincr = ""
                            aux_selfinal = "".
               
                     RUN mostra_selecionados(OUTPUT aux_sellincr,
                                             OUTPUT aux_selfinal).

                     RUN fontes/confirma.p (INPUT  "",
                                            OUTPUT aux_confirma).
                  
                     /*se nao confirmar operacao seta flag para 
                       reselecionar os registros*/
                     IF aux_confirma = "S" THEN
                        DO:
                           IF LENGTH(aux_sellincr) = 0 THEN
                              DO:
                                 MESSAGE "Nenhuma linha de credito foi " + 
                                         "selecionada.".
                                 HIDE FRAME f_selecionados NO-PAUSE.
                                 ASSIGN aux_flgresel = YES.
                                 NEXT.
                              END.
                           ELSE
                           IF LENGTH(aux_selfinal) = 0 THEN
                              DO:
                                 MESSAGE "Nenhuma finalidade foi selecionada.".
                                 HIDE FRAME f_selecionados NO-PAUSE.
                                 ASSIGN aux_flgresel = YES.
                                 NEXT.
                              END.

                           LEAVE.

                        END.
                     ELSE
                        DO:
                           HIDE FRAME f_selecionados.
                           ASSIGN aux_flgresel = YES.
                        END.
                          
                  END.
               
                  LEAVE.
               
               END.
               
               /*se confirmou inicia geracao do relatorio(arquivo)*/
               IF aux_confirma = "S"       AND
                  LENGTH(aux_sellincr) > 0 AND
                  LENGTH(aux_selfinal) > 0 THEN
                  DO: 
                     RUN Gera_Impressao(INPUT glb_cdcooper,              
                                        INPUT 0, /*cdagenci,*/
                                        INPUT 0, /*nrdcaixa,*/
                                        INPUT glb_cdoperad,
                                        INPUT glb_nmdatela,
                                        INPUT 1, /*dorigem*/
                                        INPUT glb_inproces,
                                        INPUT glb_cddepart,
                                        INPUT glb_dtmvtolt,
                                        INPUT tel_cddopcao,
                                        INPUT "", /*tpdopcao*/
                                        INPUT ?, /*dtprdini*/
                                        INPUT TRUE, /*flgerlog*/ 
                                        INPUT 0, /*cdempres*/
                                        INPUT 0, /*tppessoa*/
                                        INPUT glb_dtmvtopr,              
                                        INPUT "A", /*lgvisual*/
                                        INPUT ?, /*dtprdfin*/
                                        INPUT 0, /*cdultrev*/
                                        INPUT "", /*tpcontas*/
                                        INPUT "", /*dsadmcrd*/
                                        INPUT "", /*tpdomvto*/
                                        INPUT "", /*situacao*/
                                        INPUT aux_sellincr,
                                        INPUT aux_selfinal,
                                        INPUT aux_nmarquiv,
                                        INPUT 0 /*cdagesel*/).
               
                     IF RETURN-VALUE = "OK" THEN
                        DO: 
                           HIDE MESSAGE NO-PAUSE.
                           MESSAGE "Arquivo gerado.".
                        END.

                  END.
               
	           HIDE FRAME f_selecionados.
               
            END.
   	  	 ELSE
   	  	 	MESSAGE "Acesso negado.".
         
   	  	 NEXT.

   	  END.  
   ELSE
   IF tel_cddopcao = "E" THEN 
   	  DO:
   	      RUN fontes/confirma.p(INPUT "",
                                OUTPUT aux_confirma).
        
   	      IF aux_confirma <> "S"   THEN 
   	         NEXT.

   	  END. /* Fim opcao E */

   RUN Gera_Impressao(INPUT glb_cdcooper,              
                      INPUT 0, /*cdagenci*/
                      INPUT 0, /*nrdcaixa*/
                      INPUT glb_cdoperad,
                      INPUT glb_nmdatela,
                      INPUT 1, /*idorigem*/
                      INPUT glb_inproces,
                      INPUT glb_cddepart,
                      INPUT glb_dtmvtolt,
                      INPUT tel_cddopcao,
                      INPUT tel_tpdopcao:SCREEN-VALUE IN FRAME f_movtos_tp,
                      INPUT aux_dtprdini,
                      INPUT TRUE, /*flgerlog*/ 
                      INPUT tel_cdempres,
                      INPUT tel_tppessoa,
                      INPUT glb_dtmvtopr,   
                      INPUT "", /*lgvisual*/
                      INPUT aux_dtprdfin,
                      INPUT tel_cdultrev,
                      INPUT tel_tpcontas,
                      INPUT tel_dsadmcrd,
                      INPUT tel_tpdomvto:SCREEN-VALUE IN FRAME f_movtos_c2,
                      INPUT tel_situacao,
                      INPUT aux_sellincr,
                      INPUT aux_selfinal,
                      INPUT aux_nmarquiv,
                      INPUT tel_cdagenci).

   RUN limpa_arq_temp.
  
END. /* Fim do DO WHILE TRUE */   


/* ............................... PROCEDURES .............................. */
PROCEDURE caminho_arquivo:

   DEF INPUT PARAM par_cdcooper AS INT                               NO-UNDO.

   DEF OUTPUT PARAM par_nmarquiv AS CHAR                             NO-UNDO.

   FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                            NO-LOCK NO-ERROR.

   ASSIGN tel_nmdireto = "/micros/" + LOWER(crapcop.dsdircop) + "/".

   DISP tel_nmdireto WITH FRAME f_diretorio_a.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_nmarquiv WITH FRAME f_diretorio_a.

      IF LENGTH(tel_nmarquiv) > 0 THEN
         LEAVE.
      ELSE
         MESSAGE "Nome do arquivo vazio.".
   END.

   ASSIGN par_nmarquiv = tel_nmarquiv.

   RETURN "OK".

END.

PROCEDURE mostra_selecionados:
    
    DEF OUTPUT PARAM par_sellincr   AS  CHAR                    NO-UNDO.
    DEF OUTPUT PARAM par_selfinal   AS  CHAR                    NO-UNDO.
    
    DEF VAR aux_dsseleci AS   CHAR 
        VIEW-AS EDITOR SIZE 76 BY 13 BUFFER-LINES 10            NO-UNDO.

    FORM aux_dsseleci 
    WITH OVERLAY NO-LABEL CENTERED ROW 6 WIDTH 78 FRAME f_selecionados.

    /*mostra linhas de credito selecionadas no browse*/
    ASSIGN aux_dsseleci = "Linhas de credito: ".

    FOR EACH tt-lincred NO-LOCK BY tt-lincred.cdcodigo:

        IF tt-lincred.flgmarca THEN
           DO:
              ASSIGN aux_dsseleci = aux_dsseleci + 
                                    STRING(tt-lincred.cdcodigo) + ";"
                     par_sellincr = par_sellincr + 
                                    STRING(tt-lincred.cdcodigo) + ",".
    
           END.                                                         
    END.

    /*mostra as finalidades selecionadas no browse*/
    ASSIGN aux_dsseleci = aux_dsseleci + CHR(10) + CHR(10) + "Finalidades: ".

    FOR EACH tt-finalidade NO-LOCK BY tt-finalidade.cdcodigo:

        IF tt-finalidade.flgmarca THEN
           DO:
              ASSIGN aux_dsseleci = aux_dsseleci + 
                                    STRING(tt-finalidade.cdcodigo) + ";"
                     par_selfinal = par_selfinal + 
                                    STRING(tt-finalidade.cdcodigo) + ",".

           END.                                                         
    END.
    
    DISPLAY aux_dsseleci WITH FRAME f_selecionados.

    RETURN "OK".

END.

PROCEDURE limpa_arq_temp:

	/* Apaga arquivos temporarios */
	IF aux_nmarqimp <> "" THEN
       DO:
           UNIX SILENT VALUE ("rm " + aux_nmarqimp + " 2> /dev/null" ).
       END.

	IF aux_nmarqdst <> "" THEN
       DO:
           UNIX SILENT VALUE ("rm " + aux_nmarqdst + " 2> /dev/null" ).
       END.

END PROCEDURE.

/* -------------------------------------------------------------------------- */
/*                      EFETUA A IMPRESSãO DOS HISTORICOS                     */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_Impressao:

   DEF INPUT PARAM par_cdcooper AS INT                             NO-UNDO.   
   DEF INPUT PARAM par_cdagenci AS INT                             NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INT                             NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.   
   DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.   
   DEF INPUT PARAM par_idorigem AS INT                             NO-UNDO.
   DEF INPUT PARAM par_inproces AS INT                             NO-UNDO.  
   DEF INPUT PARAM par_cddepart AS INT                             NO-UNDO.   
   DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.  
   DEF INPUT PARAM par_cddopcao AS CHAR                            NO-UNDO.   
   DEF INPUT PARAM par_tpdopcao AS CHAR                            NO-UNDO.
   DEF INPUT PARAM par_dtprdini AS DATE                            NO-UNDO.   
   DEF INPUT PARAM par_flgerlog AS LOG                             NO-UNDO.
   DEF INPUT PARAM par_cdempres AS INT                             NO-UNDO.
   DEF INPUT PARAM par_tppessoa AS CHAR                            NO-UNDO.   
   DEF INPUT PARAM par_dtmvtopr AS DATE                            NO-UNDO.   
   DEF INPUT PARAM par_lgvisual AS CHAR                            NO-UNDO.   
   DEF INPUT PARAM par_dtprdfin AS DATE                            NO-UNDO.   
   DEF INPUT PARAM par_cdultrev AS INT                             NO-UNDO.
   DEF INPUT PARAM par_tpcontas AS CHAR                            NO-UNDO.   
   DEF INPUT PARAM par_dsadmcrd AS CHAR                            NO-UNDO.   
   DEF INPUT PARAM par_tpdomvto AS CHAR                            NO-UNDO.   
   DEF INPUT PARAM par_situacao AS CHAR                            NO-UNDO.   
   DEF INPUT PARAM par_sellincr AS CHAR                            NO-UNDO.   
   DEF INPUT PARAM par_selfinal AS CHAR                            NO-UNDO.   
   DEF INPUT PARAM par_nmarquiv AS CHAR                            NO-UNDO.
   DEF INPUT PARAM par_cdagesel AS INT                             NO-UNDO.
   
   INPUT THROUGH basename `tty` NO-ECHO.

   SET aux_nmendter WITH FRAME f_terminal.

   INPUT CLOSE.
   
   IF par_cddopcao <> "A" THEN
      DO:
         IF par_cddopcao <> "C" THEN
            DO:
               ASSIGN aux_dsdopcao = "(T)erminal, (I)mpressora ou (A)rquivo: ".
         
               IF par_cddopcao = "E" THEN
                  ASSIGN aux_dsdopcao = "(A)rquivo ou (I)mpressora: "
                         tel_lgvisual = "A".
         
            END.
         
         IF par_cddopcao = "C"          AND 
            par_tpdopcao = "Gerar Base" THEN 
            ASSIGN tel_nmarquiv:HELP IN FRAME f_diretorio = 
                                "Informe o nome do arquivo a ser importado.".
         ELSE
            DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:   
         
                  MESSAGE aux_dsdopcao UPDATE tel_lgvisual. 
                  LEAVE.
           
               END.
           
               IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
           	      DO:
           	         HIDE FRAME f_movtos_c1. 
           		     HIDE FRAME f_movtos_c4. 
           		     RETURN "OK".
           	      END.   
         
               ASSIGN tel_nmarquiv:HELP IN FRAME f_diretorio = 
         	         "Informe o nome do arquivo.".
         
            END.
         
         /*Se o tipo de visualizacao for diferente do permitido ou, nao for 
           permitido para a opcao selecionada.*/
         IF (tel_lgvisual <> "A"   AND
             tel_lgvisual <> "I"   AND
             tel_lgvisual <> "T" ) OR 
            ((tel_lgvisual = "T"   AND 
             tel_cddopcao = "E")   OR
            (tel_lgvisual = "I"    AND 
             tel_cddopcao = "C" )) THEN
            DO:
                MESSAGE "Opcao incorreta !!".
                PAUSE 2 NO-MESSAGE.
                RETURN "NOK".
             END.  
         
         IF tel_lgvisual = "A"  THEN /* Arquivo */
            DO:  
               HIDE FRAME  f_movtos_c4.
         
               FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                                        NO-LOCK NO-ERROR.
         
               ASSIGN tel_nmdireto = "/micros/" + LOWER(crapcop.dsdircop) + "/"
                      aux_nmarqdst = aux_nmarqimp. 
              
               DISP tel_nmdireto WITH FRAME f_diretorio.
                           
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
                  UPDATE tel_nmarquiv WITH FRAME f_diretorio.

                  IF LENGTH(tel_nmarquiv) > 0 THEN
                     LEAVE.
                  ELSE
                     MESSAGE "Nome do arquivo vazio.".
         
               END.
              
               IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                  RETURN "NOK".                    
         
               ASSIGN aux_nmarquiv = tel_nmarquiv.
         
            END.

      END.

   RUN conecta_handle.

   MESSAGE "Aguarde consultando informacoes...".
       
   RUN Gera_Impressao IN h-b1wgen0185
   				     (INPUT par_cdcooper,              
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,                       
                      INPUT par_cdoperad,              
                      INPUT par_nmdatela,              
                      INPUT par_idorigem,
                      INPUT par_inproces,
                      INPUT par_cddepart,              
                      INPUT par_dtmvtolt,              
                      INPUT par_cddopcao,
                      INPUT par_tpdopcao,
                      INPUT par_dtprdini,                        
                      INPUT TRUE, /*flgerlog*/                     
                      INPUT aux_nmendter,              
                      INPUT par_cdempres,              
                      INPUT par_tppessoa,              
                      INPUT par_dtmvtopr,              
                      INPUT tel_lgvisual,              
                      INPUT par_dtprdfin,              
                      INPUT par_cdultrev,              
                      INPUT par_tpcontas,              
                      INPUT par_dsadmcrd,              
                      INPUT par_tpdomvto,              
                      INPUT par_situacao,
                      INPUT par_sellincr,
                      INPUT par_selfinal,
                      INPUT par_cdagesel,
                      INPUT aux_nmarquiv,
                     OUTPUT aux_nmarqimp,              
                     OUTPUT aux_nmarqpdf,                     
                     OUTPUT TABLE tt-cartoes,
                     OUTPUT TABLE tt-erro) NO-ERROR.     

   HIDE MESSAGE NO-PAUSE.

   RUN desconecta_handle.                                      
   
   IF ERROR-STATUS:ERROR THEN
      DO:
         MESSAGE ERROR-STATUS:GET-MESSAGE(1).
         RETURN "NOK".
      END. 

   IF RETURN-VALUE <> "OK"           OR 
      TEMP-TABLE tt-erro:HAS-RECORDS THEN
      DO:
         FIND FIRST tt-erro NO-ERROR.

         IF AVAILABLE tt-erro THEN
            MESSAGE tt-erro.dscritic.

         RETURN "NOK".  

      END.

   IF par_cddopcao = "A" THEN
      RETURN "OK".

   IF tel_lgvisual = "T" AND 
      par_cddopcao = "C" THEN
      DO:
         IF par_tpdomvto = "C" THEN
     	     DO:
     	  	    OPEN QUERY q_cartoes FOR EACH tt-cartoes NO-LOCK.
            
     	  		DO WHILE TRUE ON ENDKEY UNDO, LEAVE:            
     	  		   UPDATE b_cartoes WITH FRAME f_cartoes.
     	  		   LEAVE.
     	  		END.
             
     	  		IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
     	  		   RETURN "OK".                    
        
     	  	 END.
     	  ELSE
     	     DO:
     	  	    OPEN QUERY q_cartoes_debito_bb 
                    FOR EACH tt-cartoes NO-LOCK BY tt-cartoes.cdcooper 
     	  		     					          BY tt-cartoes.dtmvtolt
     	  								           BY tt-cartoes.nrdconta.
            
     	        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:            
        
     	  		   UPDATE b_cartoes_debito_bb 
                         WITH FRAME f_cartoes_debito_bb.
        
     	  		   LEAVE.
        
     	  		END.
             
     	  		IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
     	  		   RETURN "OK".                    
        
     	  	  END.

         RETURN "OK".

      END.

   IF par_cddopcao <> "C" THEN
      DO:
         /* Verifica se o arquivo esta vazio e critica */
       	 INPUT STREAM str_1 THROUGH VALUE("wc -m " + aux_nmarqimp +
   	                                      " 2> /dev/null") NO-ECHO.
            
   	     SET STREAM str_1 aux_tamarqui FORMAT "x(30)".
             
   	     IF INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0 THEN
   	        DO:
   	         	BELL.
   	          	MESSAGE "Nenhuma ocorrencia encontrada.".
   	          	INPUT STREAM str_1 CLOSE.
   	          	UNIX SILENT VALUE ("rm " + aux_nmarqimp + " 2> /dev/null").
   	            RETURN "OK".
   	        END.    
             
   	     INPUT STREAM str_1 CLOSE. 

      END.

   IF tel_lgvisual = "T"   THEN /* Mostrar na tela */
      RUN fontes/visrel.p (INPUT aux_nmarqimp).
   ELSE
   IF tel_lgvisual = "I"   THEN /* Impressao */    
      DO: 
         ASSIGN glb_nmformul = "132col".
                                    
         FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper 
                                  NO-LOCK NO-ERROR.

         ASSIGN glb_nrdevias = 1.                           

         {includes/impressao.i}   

      END.

   RETURN "OK".

END PROCEDURE. /* Gera_Impressao */

/*----------------------------------------------------------------------------*/
PROCEDURE conecta_handle:

   IF NOT VALID-HANDLE(h-b1wgen0185) THEN
      RUN sistema/generico/procedures/b1wgen0185.p PERSISTENT SET h-b1wgen0185.
	
END PROCEDURE.

PROCEDURE desconecta_handle:

   IF VALID-HANDLE(h-b1wgen0185) THEN
      DELETE OBJECT h-b1wgen0185.
		
END PROCEDURE.
