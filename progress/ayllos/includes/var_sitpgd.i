/*............................................................................

   Programa: Includes/var_sitpgd.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Maio/2009                          Ultima atualizacao: 09/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (Online).
   Objetivo  : Usado pelo fontes/sitpgdp.p para variaveis e forms do item
               RELACION da tela ATENDA (Eventos do PROGRID).

   Alteracoes: 24/08/2009 - Incluir tratamento para avisar o usuario de
                            inscricoes ja existentes para um dado evento
                            (Gabriel)
                            
               23/10/2009 - Retirar validacao fixa, usar temp-table 
                            (Gabriel).             
                           
               04/06/2010 - Retirar validacao das datas do questionario,
                            passado o controle para a BO 39 (Gabriel).
                            
               01/11/2010 - Inclusao do campo "Data de digitacao" em 
                            f_questionario (Vitor).
                            
               07/02/2011 - Incluir variaveis para tratamento de impressao
                            do historico (Gabriel).             
                            
               26/09/2012 - Aumentado o FORMAT do campo relativo ao nome do
                            evento no browse 'b-historico-evento' (Lucas)
                            
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).
.............................................................................*/

DEF STREAM str_1. /* Termo de compromisso */

/* Botoes da tela principal, Relacionamento  */
DEFINE VAR tel_qtpenden AS CHAR INIT "Pre-Inscricao:   Pendente:"      NO-UNDO.
DEFINE VAR tel_qtconfir AS CHAR INIT "               Confirmada:"      NO-UNDO.
DEFINE VAR tel_qtandame AS CHAR INIT "     Eventos em andamento:"      NO-UNDO.
DEFINE VAR tel_qthistor AS CHAR INIT "Historico de participacao:"      NO-UNDO.
DEFINE VAR tel_question AS CHAR INIT "             Questionario:"      NO-UNDO.

/* Botoes da tela Eventos em andamento */
DEFINE VAR tel_eveopcao AS CHAR EXTENT 4 INIT[" Detalhes do Evento ",
                                              " Pre-inscricao ", 
                                              " Situacao da inscricao ", 
                                              " Historico "]           NO-UNDO.

/* Parametro de chamada de BO para eventos em andamento */ 
DEFINE VAR par_dsobserv AS CHAR                                        NO-UNDO.

/* Botoes da tela Situacao da inscricao */
DEFINE VAR tel_sitopcao AS CHAR EXTENT 6 INIT[" Pendente ",
                                              " Confirmado ",
                                              " Desistente ",
                                              " Excluido ",
                                              " Excedente",
                                              " Termo "]               NO-UNDO.

/* Variaveis da tela Pre-Inscricao */
DEFINE VAR tel_nmextttl AS CHAR FORMAT "x(40)"  VIEW-AS COMBO-BOX      NO-UNDO.
DEFINE VAR tel_confirma AS CHAR INIT "  <Nao>  "                       NO-UNDO.
DEFINE VAR tel_confirm2 AS CHAR INIT "  <Sim>  "                       NO-UNDO.

DEFINE VAR aux_dsdetalh AS CHAR                                        NO-UNDO.

 
DEFINE VAR tel_tpinseve AS LOGI FORMAT "Propria/Outra Pessoa"INIT TRUE NO-UNDO.
 
/* Variaveis da tela Historico */
DEFINE VAR tel_dtanoage AS INTE EXTENT 2                               NO-UNDO.
DEFINE VAR tel_nmevento AS CHAR                                        NO-UNDO.

/* Indice para opcoes eventos em andamento */
DEFINE VAR ind_opcaoeve AS INTE INITIAL 1                              NO-UNDO.

/* Indice para opcao de situacao da inscricao */
DEFINE VAR ind_opcaosit AS INTE INITIAL 1                              NO-UNDO.

DEFINE VAR par_nrdrowid AS ROWID                                       NO-UNDO.
DEFINE VAR par_flgcoope AS LOGI                                        NO-UNDO.

/* Variaveis auxiliares ... */
DEFINE VAR aux_nmextttl AS CHAR                                        NO-UNDO.
DEFINE VAR aux_contaopc AS INTE                                        NO-UNDO.
DEFINE VAR aux_idseqttl AS INTE                                        NO-UNDO.
DEFINE VAR aux_confirma AS CHAR FORMAT "!"                             NO-UNDO.
DEFINE VAR aux_flginscr AS LOGI                                        NO-UNDO.
DEFINE VAR aux_idstains AS INTE                                        NO-UNDO.
DEFINE VAR aux_flgpesqu AS LOGI                                        NO-UNDO.
DEFINE VAR aux_cdevento AS INTE                                        NO-UNDO.
DEFINE VAR aux_idevento AS INTE                                        NO-UNDO.
DEFINE VAR aux_nmarqimp AS CHAR                                        NO-UNDO.
DEFINE VAR aux_flgcontr AS LOGI                                        NO-UNDO.
DEFINE VAR aux_dsdbusca AS CHAR                                        NO-UNDO.

/* Variaveis de impressao */
DEF VAR tel_dsimprim    AS CHAR FORMAT "x(8)" INIT "Imprimir"          NO-UNDO.
DEF VAR tel_dscancel    AS CHAR FORMAT "x(8)" INIT "Cancelar"          NO-UNDO.
DEF VAR aux_nmendter    AS CHAR                                        NO-UNDO.
DEF VAR aux_flgescra    AS LOGI                                        NO-UNDO.
DEF VAR aux_dscomand    AS CHAR                                        NO-UNDO.
DEF VAR par_flgrodar    AS LOGI                                        NO-UNDO.
DEF VAR par_flgfirst    AS LOGI                                        NO-UNDO.
DEF VAR par_flgcance    AS LOGI                                        NO-UNDO.
DEF VAR par_nmarquiv    AS CHAR                                        NO-UNDO.
DEF VAR par_nmarqpdf    AS CHAR                                        NO-UNDO.


/* Browse com a lista dos eventos em andamento do PAC do associado */
DEFINE QUERY q-eventos-andamento FOR tt-eventos-andamento.

DEFINE BROWSE b-eventos-andamento QUERY q-eventos-andamento 
       DISPLAY tt-eventos-andamento.nmevento  LABEL "Evento"   FORMAT "x(25)"
               tt-eventos-andamento.qtmaxtur  LABEL "Turma"    FORMAT "z,zz9"
               tt-eventos-andamento.qtpenden  LABEL "Pre-Ins"  FORMAT "zzz9"
               tt-eventos-andamento.qtconfir  LABEL "Conf"     FORMAT "zzz9"
               tt-eventos-andamento.dtinieve  LABEL "Inicio"   FORMAT "x(8)"
               tt-eventos-andamento.dtfineve  LABEL "Fim"      FORMAT "x(8)"
               tt-eventos-andamento.dsobserv  LABEL "Obs."     FORMAT "x(7)"
               WITH 4 DOWN.

/* Browse com a lista dos inscritos do associado num dado evento */
DEFINE QUERY q-situacao-inscricao FOR tt-situacao-inscricao.

DEFINE BROWSE b-situacao-inscricao QUERY q-situacao-inscricao
       DISPLAY tt-situacao-inscricao.nmevento LABEL "Evento"   FORMAT "x(20)"
               tt-situacao-inscricao.dtinieve LABEL "Inicio"
               tt-situacao-inscricao.nminseve LABEL "Inscrito" FORMAT "x(15)"
               tt-situacao-inscricao.dsstaeve LABEL "Situacao" FORMAT "x(10)"
               tt-situacao-inscricao.dtconins LABEL "Confirm."   
               tt-situacao-inscricao.flginsin LABEL "Int."     FORMAT "Sim/Nao"
               WITH 4 DOWN.

/* Lista os eventos para a pesquisa no historico */
DEF QUERY q-lista-eventos FOR tt-lista-eventos.

DEF BROWSE b-lista-eventos QUERY q-lista-eventos
    DISPLAY tt-lista-eventos.nmevento         LABEL "Evento"   FORMAT "x(63)"
            WITH NO-BOX 5 DOWN.

/* Browse com a lista dos eventos em que o cooperado ja participou */
DEF QUERY q-historico-evento FOR tt-historico-evento.

DEF BROWSE b-historico-evento QUERY q-historico-evento
    DISPLAY tt-historico-evento.nminseve LABEL "Nome inscrito"  FORMAT "x(30)"
            tt-historico-evento.nmevento LABEL "Nome evento"    FORMAT "x(62)"
            tt-historico-evento.dsstains LABEL "Situacao"       FORMAT "x(12)" 
            tt-historico-evento.dtinieve LABEL "Inicio"    FORMAT "99/99/9999" 
            tt-historico-evento.dtfineve LABEL "Fim"       FORMAT "99/99/9999"
            WITH WIDTH 74 SCROLLBAR-VERTICAL NO-BOX 4 DOWN.

FORM SKIP(1)
     tel_qtandame                  AT 03 NO-LABEL            FORMAT "x(26)"
        HELP "Pressione <ENTER> p/ visualizar os eventos em andamento."
        
     tt-qtdade-eventos.qtandame    AT 30 NO-LABEL            FORMAT "z,zz9"  
     
     tel_qthistor                  AT 03 NO-LABEL            FORMAT "x(26)"  
        HELP "Pressione <ENTER> p/ visualizar o historico de participacao."
     
     tt-qtdade-eventos.qthispar    AT 30 NO-LABEL            FORMAT "z,zz9"    
     
     SKIP(1)

     tel_qtpenden                  AT 03 NO-LABEL            FORMAT "x(26)"
        HELP "Pressione <ENTER> p/ visualizar as pre-inscricoes pendentes."
         
     tt-qtdade-eventos.qtpenden    AT 30 NO-LABEL            FORMAT "z,zz9"
     
     tel_qtconfir                  AT 03 NO-LABEL            FORMAT "x(26)"
        HELP "Pressione <ENTER> p/ visualizar as inscricoes confirmadas."

     tt-qtdade-eventos.qtconfir    AT 30 NO-LABEL            FORMAT "z,zz9" 
     
     SKIP(1)
 
     tel_question                  AT 03 NO-LABEL            FORMAT "x(26)"
        HELP "Pressione <ENTER> p/ alterar as datas do questionario."
          
     tt-qtdade-eventos.dtinique    AT 30 NO-LABEL            FORMAT "99/99/9999"
     "-"                           AT 42
     tt-qtdade-eventos.dtfimque    AT 45 NO-LABEL            FORMAT "99/99/9999"
     
     SKIP(1)
     
     WITH WIDTH 78 CENTERED OVERLAY SIDE-LABELS ROW 11 
          
                   TITLE " Relacionamento " FRAME f_relacionamento.

FORM b-eventos-andamento
        HELP "Utilize as <SETAS> p/ selecionar - ou digite o nome do evento."
         
     tel_eveopcao[1]               AT 02 NO-LABEL            FORMAT "x(20)"
     
     tel_eveopcao[2]               AT 23 NO-LABEL            FORMAT "x(15)"
     
     tel_eveopcao[3]               AT 39 NO-LABEL            FORMAT "x(23)"

     tel_eveopcao[4]               AT 63 NO-LABEL            FORMAT "x(12)"
     
     WITH CENTERED WIDTH 78 OVERLAY ROW 11 
                   
                   TITLE " Eventos em andamento " FRAME f_eventos_andamento.

FORM aux_dsdbusca                         FORMAT "x(29)"

     WITH ROW 16 CENTERED OVERLAY NO-LABEL FRAME f_busca.


DEF FRAME f_detalhe_evento 

     tt-detalhe-evento.nmevento    AT 06 LABEL "Evento"      FORMAT "x(60)"

     SKIP(1)   
     
     tt-detalhe-evento.dtinieve    AT 05 LABEL "Periodo"     FORMAT "x(10)"
     
     "a"                           AT 25 
     
     tt-detalhe-evento.dtfineve    AT 27 NO-LABEL            FORMAT "x(10)"
     
     tt-detalhe-evento.dshroeve    AT 50 LABEL "Horario"     FORMAT "x(15)"
                                                     
     SKIP(1)
                                                     
     tt-detalhe-evento.dslocali    AT 07 LABEL "Local"       FORMAT "x(60)"
                                                  
     SKIP(1)
                                                  
     tt-detalhe-evento.nmfornec    AT 02 LABEL "Fornecedor"  FORMAT "x(62)"
                                                   
     SKIP(1)
                                                   
     tt-detalhe-evento.nmfacili    AT 01 LABEL "Facilitador" FORMAT "x(60)"

     SKIP(1)
     
     tt-detalhe-evento.dsconteu[1] AT 04 LABEL "Conteudo"
                                                             FORMAT "x(62)"
                                   
     tt-detalhe-evento.dsconteu[2] AT 13 NO-LABEL            FORMAT "x(63)"
     
     tt-detalhe-evento.dsconteu[3] AT 13 NO-LABEL            FORMAT "x(63)"
                                 
     tt-detalhe-evento.dsconteu[4]  AT 13 NO-LABEL           FORMAT "x(63)"
     
     tt-detalhe-evento.dsconteu[5]  AT 13 NO-LABEL           FORMAT "x(63)"

     tt-detalhe-evento.dsconteu[6]  AT 13 NO-LABEL           FORMAT "x(63)"

     tt-detalhe-evento.dsconteu[7]  AT 13 NO-LABEL           FORMAT "x(63)"

     tt-detalhe-evento.dsconteu[8]  AT 13 NO-LABEL           FORMAT "x(63)"

     tt-detalhe-evento.dsconteu[9]  AT 13 NO-LABEL           FORMAT "x(63)"    

     tt-detalhe-evento.dsconteu[10] AT 13 NO-LABEL           FORMAT "x(63)"
     
     WITH CENTERED WIDTH 78 OVERLAY ROW 7 SIDE-LABELS
     
                   TITLE " Detalhes do Evento " SCROLLBAR-VERTICAL.  

FORM SKIP(1)

     tt-eventos-andamento.nmevento AT 17 NO-LABEL            FORMAT "x(60)"

     tt-eventos-andamento.dsrestri AT 17 NO-LABEL            FORMAT "x(60)"

     SKIP(10)
     WITH CENTERED WIDTH 78 OVERLAY ROW 7 SIDE-LABELS
       
                   TITLE " Pre-Inscricao " FRAME f_pre_inscricao.


/*   Os proximos 3 frame sao usados quando o coop faz uma inscricao de um
     evento que ja participu ou esta participando (Relacionados a esta conta) */


FORM "O cooperado ja possui inscricoes nesse evento sob sua responsabilidade:"
     SKIP(1)
     "  PA               Data        Inscrito"
     SKIP(3)
     aux_dsdetalh AT 3   NO-LABEL FORMAT "x(35)"
     SKIP(1)
     "Deseja prosseguir com a pre-inscricao?"
     
     WITH CENTERED WIDTH 76 OVERLAY ROW 9 TITLE " Inscricoes " FRAME f_possui.


FORM tt-inscricoes-conta.nmresage AT  3 NO-LABEL  FORMAT "x(15)"
     
     tt-inscricoes-conta.dtmvtolt AT 20 NO-LABEL  FORMAT "x(10)"

     tt-inscricoes-conta.nminseve AT 32 NO-LABEL  FORMAT "x(30)"
     
     
     WITH NO-BOX 3 DOWN CENTERED WIDTH 74 OVERLAY ROW 13 FRAME f_possui_2.
     
     
FORM tel_confirm2  FORMAT "x(9)"
        HELP "Utilize as <SETAS> p/ navegar - <ENTER> p/ confirmar."

     tel_confirma  FORMAT "x(9)"
        HELP "Utilize as <SETAS> p/ navegar - <ENTER> p/ confirmar."
 
     WITH NO-LABEL NO-BOX COLUMN 45 OVERLAY ROW 18 FRAME f_possui_3.


FORM tel_nmextttl                  AT 17 LABEL "Titular"     FORMAT "x(45)"
        HELP "Utilize as <SETAS> e <ENTER> para selecionar o titular."
     
     SKIP(1)
     tel_tpinseve                  AT 15 LABEL "Inscricao"   
        HELP "Informe o tipo de inscricao, (P)ropria ou (O)utra Pessoa." 
     
     tt-info-cooperado.cdgraupr    AT 03 LABEL "Vinculo com cooperado"
                                                             FORMAT "9"   
        HELP "1-Conjuge, 2-Pai/Mae, 3-Filho, 4-Companheiro, 5-Outro, 9-Nenhum."
     
        VALIDATE (CAN-FIND(tt-grau-parentesco WHERE
                           tt-grau-parentesco.cdgraupr = 
                                tt-info-cooperado.cdgraupr),
                  "023 - Grau de parentesco errado.")

     tt-info-cooperado.dsgraupr    AT 28  NO-LABEL           FORMAT "x(20)"
                                                          
     tt-info-cooperado.nminseve    AT 20 LABEL "Nome"        FORMAT "x(40)"
        HELP "Informe o nome do inscrito."
        VALIDATE (tt-info-cooperado.nminseve <> "",
                  "375 - O campo deve ser preenchido.")

     tt-info-cooperado.dsdemail    AT 18 LABEL "E-mail"      FORMAT "x(40)"
        HELP "Informe o e-mail do inscrito."
                  
     tt-info-cooperado.nrdddins    AT 16 LABEL "DDD/Fone"    FORMAT "999"
        HELP "Informe o DDD do inscrito."

     tt-info-cooperado.nrtelefo    AT 30 NO-LABEL            FORMAT "zzzzzzzzz9"
        HELP "Informe o telefone do inscrito."

     tt-info-cooperado.dsobserv    AT 14 LABEL "Observacao"  FORMAT "x(50)"
        HELP "Informe, se necessario, alguma observacao."
        
     tt-info-cooperado.flgdispe    AT 13 LABEL "Confirmacao"
                                                      FORMAT "Dispensar/Pedir"
        HELP "Informe (P)edir ou (D)ispensar a confirmacao do cooperado."
        
     WITH CENTERED WIDTH 76 OVERLAY ROW 12 SIDE-LABELS 
     
                   NO-BOX FRAME f_pre_inscricao_2.


FORM b-situacao-inscricao
        HELP "Utilize as <SETAS> p/ navegar e <ENTER> p/ alterar a situacao."

     tel_sitopcao[1]               AT 02 NO-LABEL            FORMAT "x(10)"
     
     tel_sitopcao[2]               AT 14 NO-LABEL            FORMAT "x(12)"
     
     tel_sitopcao[3]               AT 28 NO-LABEL            FORMAT "x(12)"
     
     tel_sitopcao[4]               AT 42 NO-LABEL            FORMAT "x(10)"
     
     tel_sitopcao[5]               AT 54 NO-LABEL            FORMAT "x(11)"
     
     tel_sitopcao[6]               AT 67 NO-LABEL            FORMAT "x(7)"

     WITH CENTERED WIDTH 78 OVERLAY ROW 11 SIDE-LABELS
                
                   TITLE " Situacao da Inscricao " FRAME f_situacao_inscricao. 

FORM SKIP(1)
     tel_dtanoage[1]               AT 03 LABEL "Periodo de (aaaa)" 
        VALIDATE (INPUT tel_dtanoage[1] <= YEAR(glb_dtmvtolt),
                  "013 - Data errada.") 
                                                            FORMAT "zzz9"
        HELP "Informe o ano inicial p/ a pesquisa - 0 <ZERO> p/ todos."

     "a"                           AT 28
     
     tel_dtanoage[2]               AT 31 NO-LABEL           FORMAT "zzz9"
        HELP "Informe o ano final p/ a pesquisa - 0 <ZERO> p/ todos."

        VALIDATE (INPUT tel_dtanoage[2] >= INPUT tel_dtanoage[1]  AND
                  INPUT tel_dtanoage[2] <= YEAR(glb_dtmvtolt),
                  "013 - Data errada.")
        
     SKIP(1)
     
     tel_nmevento                  AT 03 LABEL "Evento"     FORMAT "x(55)"
        HELP "Pressione <ENTER> p/ todos os eventos ou <F7> p/ selecionar." 

     SKIP(1)
     WITH CENTERED WIDTH 76 OVERLAY ROW 13 SIDE-LABELS
      
                   TITLE " Pesquisa Historico " FRAME f_pesquisa_historico. 

FORM b-lista-eventos
        HELP "Use as <SETAS> p/ navegar e <ENTER> p/ selecionar o evento."
    
     WITH CENTERED WIDTH 70 OVERLAY ROW 12 SIDE-LABELS
                    
                   FRAME f_lista_eventos.
                   
DEF FRAME f_historico_evento    
     
          b-historico-evento
            HELP "Use as <SETAS> p/ outras informacoes - <END> p/ voltar."
        
          WITH CENTERED OVERLAY ROW 13 
                   
                   TITLE " Historico do cooperado ".

FORM SKIP(1)

     tt-qtdade-eventos.dtinique    AT 06 LABEL "Questionario entregue" 
                                                            FORMAT "99/99/9999"
        HELP "Informe a data da entrega do questionario."  
       
     SKIP(1)
     tt-qtdade-eventos.dtfimque    AT 05 LABEL "Questionario devolvido"
                                                            FORMAT "99/99/9999"
        HELP "Informe a data da devolucao do questionario."

     tt-qtdade-eventos.dtcadqst    AT 42 LABEL "Data de digitacao" 
                                                            FORMAT "99/99/9999"

     SKIP(2)

     WITH CENTERED WIDTH 76 OVERLAY ROW 13 SIDE-LABELS
                
                   TITLE " Questionario " FRAME f_questionario.
             

FORM tt-termo.nmextcop FORMAT "x(40)"

     " - " 

     tt-termo.nmrescop FORMAT "x(15)"
        
     WITH NO-BOX DOWN NO-LABELS WIDTH 102 FRAME f_termo_coop.
     
                   
FORM SKIP(4)

     "                                 TERMO DE COMPROMISSO           "   

     SKIP(4)
     
     "Eu,"   tt-termo.nmextttl FORMAT "x(40)" ", inscrito(a) no curso"   

     SKIP(2) tt-termo.nmevento FORMAT "x(40)" 
          
     "promovido pela " tt-termo.nmrescop  FORMAT "x(15)" "," SKIP(2)
     
     "assino este termo, comprometendo-me a participar do curso com" 
     
     "frequencia minima" SKIP(2) "de " tt-termo.prfreque  "%,"   

     "caso contrario, autorizo o debito de R$ " tt-termo.vldebito SKIP(2)
      
     "("  tt-termo.dsdebito FORMAT "x(50)" "), correspondente a" 

     tt-termo.prdescon "%" SKIP(2) 
     
     "do valor do curso, na minha conta corrente n: "  tt-termo.nrdconta "." 

     WITH NO-BOX DOWN NO-LABELS WIDTH 102 FRAME f_termo_propria.
                                   
    
FORM SKIP(4)

     "                                 TERMO DE COMPROMISSO           "   

     SKIP(4)
 
     "Eu," tt-termo.nmextttl FORMAT "x(35)" " assino este termo, firmando o" 

     SKIP(2) "compromisso de que " tt-termo.nminseve FORMAT "x(30)" 
     
     " inscrito(a) no curso" SKIP(2) tt-termo.nmevento FORMAT "x(25)" 
     
     "promovido pela" tt-termo.nmrescop  FORMAT "x(15)" ", participara "

     SKIP(2)
     
     "do curso com frequencia minima de" tt-termo.prfreque "%, caso contrario,"
  
     "autorizo o debito de" SKIP(2) "R$ "  tt-termo.vldebito "(" 
     
     tt-termo.dsdebito FORMAT "x(52)" ")," SKIP(2) "correspondente a "  
     
     tt-termo.prdescon "% do valor do curso, na minha conta n: "

     tt-termo.nrdconta "."                     
     
     WITH NO-BOX DOWN NO-LABELS WIDTH 102 FRAME f_termo_outra.

FORM SKIP(7)

     "                     ------------------------------------------      "
     
     SKIP(1)
     
     tt-termo.nmextttl  FORMAT "x(40)" AT 23
     
     SKIP(6)

     tt-termo.dspacdat  FORMAT "x(45)" AT 40
     
     WITH NO-BOX DOWN NO-LABELS WIDTH 102 FRAME f_termo_assinatura.
 

/*...........................................................................*/
