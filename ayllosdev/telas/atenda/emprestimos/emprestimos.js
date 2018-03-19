/*!
 * FONTE        : emprestimos.js                            Última alteração: 01/12/2017
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 08/02/2011
 * OBJETIVO     : Biblioteca de funções na rotina Emprestimos da tela ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [06/05/2011] Adicionado tratamento de Habilita/Desabilita campo nos formulários. ( Gabriel/DB1 )
 * 001: [06/05/2011] Adicionado rotina de persistencia de dados. ( Gabriel/DB1 )
 * 002: [13/05/2011] Adicionado rotina que verifica mensagens antes da persistência de dados. ( Gabriel/DB1 )
 * 003: [22/07/2011] Adicionado funcionalidades da rotina de proposta. ( Marcelo/Gati )
 * 004: [16/09/2011] Correções gerais da homologação da proposta. ( Marcelo/Gati )
 * 005: [31/10/2011] Ajuste para Lista Negra (Adriano)
 * 006: [29/11/2011] Ajuste para a inclusao do campo Justificativa. (Adriano)
 * 007: [16/12/2011] Alterando modo de listagem do rating ( Marcelo/Gati )
 * 008: [15/02/2012] Alterando propriedades do campo "liberar em" e criado funcao calculadiasuteis (Tiago)
 * 009: [05/03/2012] Alterado parametros para verifica-outras-propostas, pois ocorria erro na alteracao da mesma (Tiago).
 * 010: [05/04/2012] Incluido campo dtlibera (Gabriel)
 * 011: [10/04/2012] Funcao que preenche a variaveis arrayFeriados com os feriados do calendario da cooperativa (Tiago).
 * 012: [19/04/2012] Modificado a funcao calcula_dias_uteis (Tiago).
 * 013: [26/04/2012] Correcoes calendario (Tiago).
 * 014: [12/06/2012] Mostrar tela de liquidacoes de contratos no comeco da proposta (Gabriel)
 * 015: [13/06/2012] Tratar da liquidacao na 1a tela (Gabriel).
 * 016: [16/07/2012] Salvar campo da quantidade de notas promissorias (Gabriel).
 * 017: [04/09/2012] Validar todos os campos antes de sair da tela de analise da proposta (Gabriel).
 * 018: [12/09/2012] Limitar a quantidade de caracteres para 660 no campo da observacao (Gabriel).
 * 019: [05/10/2012] Trazer sempre o avalista quando digitada a conta (Gabriel)
 * 020: [01/11/2012] Retirado marcara campo CPF proprietario. (Daniel)
 * 021: [21/11/2012] Tratar quantidade de dias de liberação dependendo do produto (Gabriel)
 * 022: [22/11/2012] Ajustes referente ao projeto GE (Adriano).
 * 023: [25/02/2013] Enviar o numero do contrato para a validacao da liquidacao(Gabriel).
 * 024: [08/05/2013] Bloquear Qtd. Notas Promissorias para edição. Utilizar param. da TAB016 (Lucas).
 * 025: [04/06/2013] Segunda fase Projeto Credito (Gabriel).
 * 026: [27/07/2013] Controle na liquidacao de contratos (Gabriel)
 * 027: [16/09/2013] Incluido ajax para funcionamento do novo botão "Registrar Gravames" (André Euzébio / Supero).
 * 028: [14/10/2013] Incluido o case 'A_BUSCA_OBS' na função controlaOperação (Adriano);
 * 029: [28/10/2013] Ajuste na função insereIntervente para alimentar o campo "complend";
 Ajuste na função controlaLayout "Interveniente" para incluir tratamento change no campo "nrctaava" (Adriano)
 * 030: [26/11/2013] Alterado o cddopcao da opcao GRAVAMES de EG para G para o controle de permissoes (Guilherme/SUPERO)
 * 031: [29/11/2013] Ajuste na função controlaLayout, opção I_PROT_CRED/A_PROT_CRED para habilitar os campos da "Central
 de risco - Bacen" quando a conta em questao tiver algum registro de movimentação financeira
 (Adriano).
 * 032: [06/12/2013] Incluido o trigger("change") para cCateg e validaçoes dos bens(Guilherme/SUPERO).
 * 033: [23/12/2013] Comentado replace de "," por "." do campo vlopescr em funcao manterRotina() (Jorge)
 * 034: [23/12/2013] Retirado condicao entre "Imprimir" e "Nao Imprimiri", em case "I_DADOS_AVAL" da funcao controlaOperacao(). (Jorge)
 * 				     Alteração de operacoes de fluxo do botao continuar para "Consulta". (Jorge)
 *					 Atribuição de var qtpromis voltada para array de proposta em funcao manterRotina(). (Jorge)
 * 035: [23/01/2014] Adicionados parametros para validação de CPF/CNPJ do proprietário dos bens como interveniente (Lucas).
 * 036: [27/01/2014] Ajuste para bloquear a tela no momento que é fechado a tela de liquidações na inclusão da proposta (James).
 * 037: [29/01/2014] - Incluido tratamento para o campo "uflicenc" (Guilherme/SUPERO).
 *                   - Novo parametro dschassi enviado para a valida_alienacao.php
 *                   - Nova funcao para buscar UF do PA do Associado
 * 038: [05/02/2014] Adicionado campo percetop em validaDadosGerais(). (Jorge)
 * 039  [21/02/2014] Ajustes em acentuacao em mensagens de aguardo. (Jorge)
 * 040  [13/03/2014] Campos nr contrato inicial vazios. (Jorge)
 * 041  [17/03/2014] Campos novos passados para o valida_alienacao.php
 Campo idseqbem no array de Alienacoes  (Guilherme/SUPERO)
 * 042  [20/03/2014] Ajuste em campos passados com acentuacao para funcao de pesquisa. (Jorge)
 * 043  [21/03/2014] Ajustes para melhoria no log de alteracoes (tela altera) (Carlos)
 * 044  [27/03/2014] Ajuste para somente permitir informar no campo "Liberar em" no máximo 1 dígito.
 * 045  [16/04/2014] Adicionado campos de taxa, prestacao maxima e garantia no zoom da pesquisa de linhas de crédito (Reinert).
 * 046: [15/07/2014] Incluso tratamento para novos campos( inpessoa e dtnascto ) do avalista 1 e 2 (Daniel).
 * 047: [17/07/2014] Limpar o nrdplaca se for 000-0000(Nao preenchido) - Guilherme(SUPERO)
 * 048: [30/07/2014] Ajustado campos liberar em, data liberacao, data pagto e cet para ficar no layout correto de acordo com Projeto CET (Lucas R./Gielow)
 * 049: [22/08/2014] Ajustado critica "CPF Invalido" dos avalistas (Daniel) SoftDesk 192704  
 * 050: [28/08/2014] Ajustado titulo de "linha de credito" pois estava aparecendo "Linha de Cre" (Daniele).
 * 051: [08/09/2014] Projeto Automatização de Consultas em Propostas de Crédito (Jonata-RKAM).
 * 052: [07/11/2014] Inclusao do campo cdorigem na funcao controlaOperacao. (Jaison)
 * 053: [14/11/2014] (Chamado 219339) - Nao limpar o formulario de avalista durante alteracao de contrato (Tiago Castro - RKAM).
 * 053: [26/11/2014] Nao permitir efetuar consultas do conjuge quando o mesmo nao tem CPF (Jonata-RKAM)
 * 054: [27/11/2014] Correcao para salvar o nrinfcad quando PJ (Jonata-RKAM)
 * 055: [02/12/2014] Nao permitir alterar os valores do 2.do titular (Jonata-RKAM).
 * 056: [05/12/2014] Alterar mensagem de efetuar consultas (Jonata-RKAM) 
 * 057: [08/12/2014] Alteração do "maxlength" do cChassi de 35 para 20 (Guilherme/SUPERO) 
 * 058: [17/12/2014] (Chamado 229867) Alteração na mostraContrato. Não chamara mais a contrato.php e o numero do contrato sera gerado automaticamente. (Jean - RKAM ) 
 * 059: [05/01/2015] Projeto microcredito (Jonata - RKAM)
 * 060: [14/01/2015] Ajuste de layout para adicionar campo tipo de veiculo. (Jorge/Gielow) - SD 241854
 * 061: [12/02/2015] Correção no cadastro de bens onde estava sendo passado parâmetro errado para o array  SD 244368 (Kelvin)
 * 062: [08/04/2015] Implementacao do campo tipo de veiculo. Melhorias em bens da proposta. (Jorge/Gielow - SD 241854)
 * 063: [08/04/2015] Consultas automatizadas para o limite de credito (Jonata-RKAM).
 * 064: [11/05/2015] Verificacao de alteracao de numero de novos contratos maior que zero na opcao 'F_NUMERO'. (Jaison/Gielow - SD: 282303)
 * 065: [15/05/2015] Projeto Cessao de Credito. (James)
 * 066: [28/05/2015] Alterado para apresentar mensagem de confirmacao para cooperados menores de idade nao emancipados. (Reinert)
 * 067: [24/06/2015] Alterações referente Projeto 215 - DV 3 (Daniel)
 * 067: [30/06/2015] Ajuste no calculo do Risco. (James)
 * 068: [17/07/2015] Tratamento para remover caracteres especiais e acentos conforme relatado o chamado 301458. (Kelvin)
 * 069: [07/08/2015] Ajustado para nao permitir informar o campo "Liberar em", quando o tipo do emprestimo for PP. (James)
 * 070: [24/08/2015] Retirada de caracteres especiais em descricao do bem e na observacao da proposta. (Jorge/Gielow) SD - 320666
 * 071: [11/09/2015] Desenvolvimento do Projeto 215 - Estorno. (James)
 * 072: [15/10/2015] Chamada da funcao removeCaracteresInvalidos ao grava os bens. SD 320666 (Kelvin)
 * 073: [15/10/2015] Alteracao na controlaOperacao no retorno da execucao do RECALCULAR_EMPRESTIMO. (Jaison/Oscar)
 * 074: [08/12/2015] Validacoes no campo chassi para nao digitar caracteres especiais e letras I Q (Tiago/Gielow SD369691)
 * 075: [23/12/2015] Ajustado validacao no campo chassi para nao digitar letras I,O e Q  devido ao keycode nao diferenciar maiusculos e minusculos
 *                   Ajustado também onblur e keyup para permitir as letras I,O, e Q para maquinas  (Odirlei-AMcom SD378702)
 * 076: [21/01/2016] Incluido tratamento para apresentar mensagem de aviso nas garantias. (James)
 * 077: [01/02/2016] Ajustado para recarregar o campo tipo emprestimo com a opcao selecionada com operacao for VI (Tiago/Gielow SD384504)
 * 078: [01/03/2016] PRJ Esteira de Credito. (Jaison/Oscar)
 * 079: [16/03/2016] Inclusao da operacao ENV_ESTEIRA. PRJ207 Esteira de Credito. (Odirlei-AMcom) 
 * 080: [05/04/2016] Incluido tratamento na efetuar_consultas para para verificar se deve validar permitir consulta caso ja esteja na esteira
 *                   PRJ207 Esteira de Credito. (Odirlei-AMcom) 
 * 081: [15/07/2016] Adicionado pergunta para bloquear a oferta de credito pre-aprovado. PRJ299/3 Pre aprovado. (Lombardi) 
 * 082: [03/08/2016] Auste para utilizar a rotina convertida para encontrar as finalidades de empréstimos (Andrei - RKAM).
 * 083: [18/08/2016] Alteração da função controlaFoco - (Evandro - RKAM)
 * 084: [19/10/2016] Incluido registro de log sobre liberacao de alienacao de bens 10x maior que o valor do emprestimo, SD-507761 (Jean Michel).
 * 085: [03/11/2016] Correcao de contagem de dias para as propostas de emprestimos, chamado 535609. (Gil Furtado - MOUTS).
 * 086: [01/02/2017] Listar todas as Linhas de Credito. Listar as Finalidades conforme Linha selecionada. Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)
 * 086: [29/03/2017] Ajustado para nao permitir selecionar finalidade de tipo 2 - cessao de credito( PRJ343 - Cessao de credito - Odirlei-AMcom)
 * 087: [25/04/2017] Adicionado tratamentos para o projeto 337 - Motor de crédito. (Reinert)
 * 088: [12/06/2017] Retornar o protocolo. (Jaison/Marcos - PRJ337)
 * 089: [08/05/2017] Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
 * 090: [13/06/2017] Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			         crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
					 (Adriano - P339).
 * 091: [26/06/2017] Ajuste para rotina ser chamada através da tela ATENDA > Produtos (P364).
 * 092: [20/09/2017] Projeto 410 - Incluir campo Indicador de financiamento do IOF (Diogo - Mouts)
 * 093: [21/09/2017] Ajustes realizado para que nao ser possivel inserir caracteres invalidos nas descricoes dos bens de hipoteca. (Kelvin - 751548)
 * 094: [23/10/2017] Bloquear temporariamente a opcao de Simulacao de emprestimo (function validaSimulacao). (Chamado 780355) - (Fabricio)
 * 095: [27/11/2017] Desbloquear opcao de Simulacao de emprestimo (function validaSimulacao) conforme solicitado no tramite acima. (Chamado 800969) - (Fabricio)
 * 096: [01/12/2017] Não permitir acesso a opção de incluir quando conta demitida (Jonata - RKAM P364).
 * 097: [14/12/2017] Incluão de novas regras de alteração, registro de gravamos e análise, Prj. 402 (Jean Michel).
 * 098: [21/12/2017] Alterado para nao permitir alterar nome do local de trabalho do conjuge. PRJ339 CRM (Odirlei-AMcom)  
 * 099: [24/10/2017] Ajustes ao carregar dados do avalista e controle de alteração. PRJ339 CRM (Odirlei-AMcom)                                            
 * 100: [29/11/2017] Retirar caracteres especiais do campo Nome da tela Portabilidade - SD 779305 - Marcelo Telles Coelho - Mouts
 * 101: [25/01/2018] Inclusao do filtro de finalidade nas linhas de credito. (Jaison/James - PRJ298)
 * 102: [07/02/2017] Forçar o preenchimento da primeira categoria para emprestimos Imoveis ou Veiculos - Antonio R. Jr - Mouts - Chamado 809763
 * 102: [26/02/2018] Ajuste na tela da simulacao da proposta para filtrar a linha de credito dos produtos TR/PP. (James)
 * 102: [21/12/2017] Alterado para quando a linha de credito for (6901 - Cessao Cartao Credito) a 
 *                   qualificacao da operacao seja (5 - Cessao de Cartao) (Diego Simas - AMcom)
* 103: [21/02/2018] Alterado para tratar limite/adp na tela de seleção para liquidar (Simas - AMcom)
 * ##############################################################################
 FONTE SENDO ALTERADO - DUVIDAS FALAR COM DANIEL OU JAMES
 * ##############################################################################
 */

var qtmesblq = 0;
var bloquear_pre_aprovado = false;
 
var nrctremp = '';
var operacao = '';
var cddopcao = '';
var nomeAcaoCall = '';
var idseqttl = 1;
var indarray = '';
var dtmvtolt = '';
var idseqbem = 0;

var auxind = '';
var maxBens = 6
var nomeForm = '';

var nrctaava = 0;
var nrcpfcgc = 0;

var vleprori = '';

var nrAvalistas = 0;
var contAvalistas = 0;
var nrAvalistaSalvo = 0;
var nrAlienacao = 0;
var contAlienacao = 0;
var nrIntervis = 0;
var contIntervis = 0;
var nrHipotecas = 0;
var contHipotecas = 0;
var largura = 0;
var altura = 0;
//varivel para indicar o tipo do cooperado (Portabilidade)
var indTipCoop = inpessoa;

var inpessoa = 0;

var bemcdcooper = '';
var bemnrdconta = '';
var bemidseqttl = '';
var bemnrcpfcgc = '';

var nrcpfcgcOld = 0;

var ddmesnov = '';
var dtdpagt2 = '';
var lscatbem = '';
var lscathip = '';

var cdlcremp = '';
var vlempres = '';
var qtparepr = '';
var qtdialib = '';

var insitapv = 0;
var dsobscmt = '';

var aux_nrctremp = 0;
var aux_nrctrem2 = 0;

//*********************

var nrpagina = 0;
var idimpres = 0;
var promsini = 1;
var flgemail = true;
var flgimpnp = '';
var flgimppr = '';
var portabil = '';
var cdorigem = 0;
var tplcremp = '';
var dsctrliq = '';
var nrdrecid = 0;
var qtpromis = 0;
var nrJanelas = 0;
var numeroProposta = '';
var possuiPortabilidade = '';
var cadastroNovo = '';
var modalidade = '0';

//******************************
//Variaveis aux. de persistencia
//******************************

var aux_nmdaval1 = '';
var aux_nrcpfav1 = '';
var aux_tpdocav1 = '';
var aux_dsdocav1 = '';
var aux_nmdcjav1 = '';
var aux_cpfcjav1 = '';
var aux_tdccjav1 = '';
var aux_doccjav1 = '';
var aux_ende1av1 = '';
var aux_ende2av1 = '';
var aux_nrfonav1 = '';
var aux_emailav1 = '';
var aux_nmcidav1 = '';
var aux_cdufava1 = '';
var aux_nrcepav1 = '';
var aux_cdnacio1 = '';
var aux_vledvmt1 = '';
var aux_vlrenme1 = '';
var aux_nrender1 = '';
var aux_complen1 = '';
var aux_nrcxaps1 = '';
// Daniel
var aux_inpesso1 = '';
var aux_dtnasct1 = '';

var aux_nmdaval0 = '';
var aux_nrcpfav0 = '';
var aux_tpdocav0 = '';
var aux_dsdocav0 = '';
var aux_nmdcjav0 = '';
var aux_cpfcjav0 = '';
var aux_tdccjav0 = '';
var aux_doccjav0 = '';
var aux_ende1av0 = '';
var aux_ende2av0 = '';
var aux_nrfonav0 = '';
var aux_emailav0 = '';
var aux_nmcidav0 = '';
var aux_cdufava0 = '';
var aux_nrcepav0 = '';
var aux_cdnacio0 = '';
var aux_vledvmt0 = '';
var aux_vlrenme0 = '';
var aux_nrender0 = '';
var aux_complen0 = '';
var aux_nrcxaps0 = '';
// Daniel
var aux_inpesso0 = '';
var aux_dtnasct0 = '';

var aux_dsdbeavt = '';
var aux_dsdfinan = '';
var aux_dsdrendi = '';
var aux_dsdebens = '';
var aux_dsdalien = '';

var vlutiliz = '';
var dsmesage = '';
var dsmensag = '';
var inconfir = 1;
var bkp_vlpreemp = 0;
var bkp_dslcremp = 0;
var bkp_dsfinemp = 0;
var bkp_tplcremp = 0;
var strValor = '';
var flgconsu = false;
var resposta = '';

var new_nrctremp = 0;

var aux_inconfir = 1;

var tot_vlsdeved = 0;

//Numero maximo de avalista
var maxAvalista = 2;

//Numero maximo de Interveniente
var maxInterv = 5;

//Numero maximo de Faturamentos
var maxFaturamento = 3;

//******************************

var arrayBensAssoc = new Array();

var arrayBemBusca = new Array();

var arrayAvalBusca = new Object();

var arrayFiadores = new Array();

var arrayLiquidacoes = new Array();

var arrayInfoParcelas = new Array();

var arrayRatings = new Array();

var arrayFeriados = new Array();

var arrayQuestionario = new Array();

var aDadosPropostaFinalidade = new Array();

var arrayDadosPortabilidade = new Array();

var strHTML = ''; // Variável usada na criação da div de alerta do grupo economico.
var strHTML2 = ''; // Variável usada na criação do form onde serão mostradas as mensagens de alerta do grupo economico.
var dsmetodo = ''; // Variável usada para manipular o método a ser executado na função encerraMsgsGrupoEconomico.
var inconfi2 = ''; // Variável usada para controlar a exibição de que o ge está sendo formando ou não.
var idSocio = 0;

// Motor de Crédito
var insitapr = '';
var dssitest = '';
var inobriga = '';

//emprestimo
var booPrimeiroBen = false; //809763

$.getScript(UrlSite + "telas/atenda/emprestimos/impressao.js");
$.getScript(UrlSite + "telas/atenda/emprestimos/simulacao/simulacao.js");
$.getScript(UrlSite + "includes/consultas_automatizadas/protecao_credito.js");

function acessaOpcaoAba(nrOpcoes, id, opcao) {

    // Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, carregando...');

    // Atribui cor de destaque para aba da opção
    for (var i = 0; i < nrOpcoes; i++) {
        if (!$('#linkAba' + id)) {
            continue;
        }

        if (id == i) { // Atribui estilos para foco da opção
            $('#linkAba' + id).attr('class', 'txtBrancoBold');
            $('#imgAbaEsq' + id).attr('src', UrlImagens + 'background/mnu_sle.gif');
            $('#imgAbaDir' + id).attr('src', UrlImagens + 'background/mnu_sld.gif');
            $('#imgAbaCen' + id).css('background-color', '#969FA9');
            continue;
        }

        $('#linkAba' + i).attr('class', 'txtNormalBold');
        $('#imgAbaEsq' + i).attr('src', UrlImagens + 'background/mnu_nle.gif');
        $('#imgAbaDir' + i).attr('src', UrlImagens + 'background/mnu_nld.gif');
        $('#imgAbaCen' + i).css('background-color', '#C6C8CA');
    }

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/principal.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            operacao: operacao,
            inconfir: 1,
			executandoProdutos: executandoProdutos,
			sitaucaoDaContaCrm: sitaucaoDaContaCrm,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1) {
                $('#divConteudoOpcao').html(response);
				
                // $('#divConteudoOpcao').centralizaRotinaH();				
            } else {
                eval(response);
                controlaFoco(operacao);
            }

            return false;
        }
    });
}

function controlaOperacao(operacao) {

    cdlcremp = '';
    vlempres = '';
    qtparepr = '';
    qtdialib = '';
    dtdpagto = '';
    tpemprst = 0;
    vlpreemp = '';
    dscatbem = '';
    idfiniof = '';
    cdfinemp = '';
    dsctrliq = '';
	idcarenc = '';
    dtcarenc = '';

    var simula = false;

    // Se a operação necessita filtrar somente um registro, então filtro abaixo
    // Para isso verifico a linha que está selecionado e pego o valor do INPUT HIDDEN desta linha
    if (in_array(operacao, ['TA', 'TE', 'TC', 'A_NOVA_PROP', 'A_NUMERO', 'A_VALOR', 'A_AVALISTA', 'IMP', 'REG_GRAVAMES', 'VAL_GRAVAMES',
                            'PORTAB_CRED_C', 'VAL_RECALCULAR_EMPRESTIMO', 'RECALCULAR_EMPRESTIMO', 'PORTAB_CRED_A', 'PORTAB_CRED_I', 'ENV_ESTEIRA',
							'ACIONAMENTOS'])) {

        nrctremp = (nrctremp == '') ? '' : nrctremp;
        tplcremp = (tplcremp == 0) ? 0 : tplcremp;
        flgimppr = (flgimppr == '') ? '' : flgimppr;
        flgimpnp = (flgimpnp == '') ? '' : flgimpnp;
        portabil = (portabil == '') ? '' : portabil;
        cdorigem = 0;
        qtpromis = '';
        nrdrecid = '';
        dsctrliq = '';

        $('table > tbody > tr', 'div.divRegistros').each(function() {
            if ($(this).hasClass('corSelecao')) {
                nrctremp = $('#nrctremp', $(this)).val();
                tplcremp = $('#tplcremp', $(this)).val();
                flgimppr = $('#flgimppr', $(this)).val();
                flgimpnp = $('#flgimpnp', $(this)).val();
                portabil = $('#portabil', $(this)).val();
                cdorigem = $('#cdorigem', $(this)).val();
                qtpromis = $('#qtpromis', $(this)).val();
                nrdrecid = $('#nrdrecid', $(this)).val();
                dsctrliq = $('#dsctrliq', $(this)).val();

                nomeAcaoCall = ''; // Reseta a global
            }
        });
        if ((nrctremp == '' || tplcremp == 0 || flgimppr == '' || flgimpnp == '') && (operacao != 'PORTAB_CRED_I')) {
            return false;
        }

    }

    arrayBemBusca.length = 0;

    var mensagem = '';
    var iddoaval_busca = 0;
    var inpessoa_busca = 0;
    var nrdconta_busca = 0;
    var nrcpfcgc_busca = 0;
    var qtpergun = 0;
    var nrseqrrq = 0;

    switch (operacao) {
        case 'CONSULTAS':
            efetuar_consultas(1,operacao);
            return;
        case 'TC' :
            idSocio = 0;
            mensagem = 'abrindo consultar ...';
            cddopcao = 'C';
            break;
        case 'C_INICIO':
        case 'CF' :
            operacao = 'CF';
            contAvalistas = 0;
            contAlienacao = 0;
            contHipotecas = 0;
            idSocio = 0;
            mensagem = 'abrindo consultar ...';
            cddopcao = 'C';
            break;
        case 'C_COMITE_APROV' :
            mensagem = 'abrindo consultar ...';
            cddopcao = 'C';
            break;
        case 'C_DADOS_PROP_PJ' :
            mensagem = 'abrindo consultar ...';
            cddopcao = 'C';
            break;
        case 'C_DADOS_PROP' :
            if (inpessoa == 1) {
                mensagem = 'abrindo consultar ...';
                cddopcao = 'C';
            } else {
                controlaOperacao('C_DADOS_PROP_PJ');
                return false;
            }
            break;
        case 'C_DADOS_AVAL' :
            if (contAvalistas < nrAvalistas) {
                mensagem = 'abrindo consultar ...';
                cddopcao = 'C';
            } else {
                contAvalistas = 0;
                controlaOperacao('C_DADOS_PROP');
                return false;
            }
            break;
        case 'C_ALIENACAO' :
            if (contAlienacao < nrAlienacao) {
                mensagem = 'abrindo consultar ...';
                cddopcao = 'C';
            } else {
                contAlienacao = 0;
                controlaOperacao('C_INTEV_ANU');
                return false;
            }
            break;
        case 'C_INTEV_ANU' :
            if (contIntervis < nrIntervis) {
                mensagem = 'abrindo consultar ...';
                cddopcao = 'C';
            } else {
                contIntervis = 0;
                controlaOperacao('C_PROT_CRED');
                return false;
            }
            break;
        case 'C_HIPOTECA' :
            if (contHipotecas < nrHipotecas) {
                mensagem = 'abrindo consultar ...';
                cddopcao = 'C';
            } else {
                contHipotecas = 0;
                controlaOperacao('C_PROT_CRED');
                return false;
            }
            break;
        case 'C_PROT_CRED' :
            mensagem = 'abrindo consultar ...';
            cddopcao = 'C';
            break;
        case 'C_BENS_ASSOC' :
            initArrayBens('C_BENS_ASSOC');
            mostraTabelaBens('BT', 'C_BENS_ASSOC');
            return false;
            break;
        case 'TA' :
            idSocio = 0;
            if (msgDsdidade != '') {
                showError('inform', msgDsdidade, 'Alerta - Ayllos', 'mostraTelaAltera("");');
            } else {
                mostraTelaAltera('');
            }
            return false;
            break;
        case 'F_NUMERO' :
            new_nrctremp = normalizaNumero($('#new_nrctremp', '#frmNumero').val());
            if (new_nrctremp > 0) {
                showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'F_NUMERO\');', 'bloqueiaFundo( $(\'#divUsoGenerico\') );$(\'#new_nrctremp\',\'#frmNumero\').focus();', 'sim.gif', 'nao.gif');
            } else {
                showError('error', 'Numero do contrato deve ser diferente de zero.', 'Alerta - Ayllos', '$(\'#new_nrctremp\',\'#frmNumero\').focus();');
            }
            return false;
            break;
        case 'A_BUSCA_OBS':

            if ($("#nrinfcad", "#frmOrgaos").val() != undefined) {
                arrayProtCred['dtcnsspc'] = $("#dtcnsspc", "#frmOrgaos").val();
                arrayProtCred['nrinfcad'] = $("#nrinfcad", "#frmOrgaos").val();
            }

            buscaObs('A');
            return false;
            break;
        case 'A_NUMERO' :
            mensagem = 'abrindo altera ...';
            cddopcao = 'A';
            break;
        case 'A_VALOR' :
            mensagem = 'abrindo altera ...';
            cddopcao = 'A';
            break;
        case 'F_VALOR' :
            if (dsmesage != '') {
                showError('inform', dsmesage, 'Alerta - Ayllos', 'dsmesage="";controlaOperacao("F_VALOR");');
            } else {
                showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'F_VALOR\');', 'undoValor();bloqueiaFundo(divRotina);', 'sim.gif', 'nao.gif');
            }
            return false;
            break;
        case 'A_AVALISTA' :
            mensagem = 'abrindo altera ...';
            cddopcao = 'A';
            nomeAcaoCall = operacao;
            break;
        case 'F_AVALISTA' :
            if (dsmesage != '') {
                showError('inform', dsmesage, 'Alerta - Ayllos', 'dsmesage="";controlaOperacao("F_AVALISTA");');
            } else {
                showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'F_AVALISTA\');', 'bloqueiaFundo(divRotina);', 'sim.gif', 'nao.gif');
            }
            return false;
            break;
        case 'V_VALOR' :
            controlaOperacao('F_VALOR');
            return false;
            break;
        case 'A_NOVA_PROP' :
            mensagem = 'abrindo altera ...';
            cddopcao = 'A';
            break;
        case 'A_INICIO' :
            contAvalistas = 0;
            contAlienacao = 0;
            contHipotecas = 0;
            contIntervis = 0;
            idSocio = 0;
            mensagem = 'abrindo altera ...';
            cddopcao = 'A';
            break;
        case 'AI_DADOS_AVAL' :
            mensagem = 'abrindo altera ...';
            cddopcao = 'A';
            break;
        case 'A_DADOS_AVAL' :
            if (contAvalistas < nrAvalistas) {
                mensagem = 'abrindo altera ...';
                cddopcao = 'A';
            } else {
                if (contAvalistas == nrAvalistas) {
                    if (nrAvalistas == maxAvalista) {
                        contAvalistas = 0;
                        controlaOperacao('A_DADOS_PROP');
                        return false;
                    } else {
                        controlaOperacao('AI_DADOS_AVAL');
                        return false;
                    }
                } else {
                    contAvalistas = 0;
                    controlaOperacao('A_DADOS_PROP');
                    return false;
                }
            }
            break;
        case 'A_PROTECAO_AVAL':
            iddoaval_busca = contAvalistas;
            inpessoa_busca = arrayAvalistas[contAvalistas - 1]['inpessoa'];
            nrdconta_busca = retiraCaracteres(arrayAvalistas[contAvalistas - 1]['nrctaava'], '0123456789', true);
            nrcpfcgc_busca = arrayAvalistas[contAvalistas - 1]['nrcpfcgc'];
            mensagem = 'consultando dados ...';
            break;
        case 'C_PROTECAO_AVAL':
            iddoaval_busca = contAvalistas;
            inpessoa_busca = arrayAvalistas[contAvalistas - 1]['inpessoa'];
            nrdconta_busca = retiraCaracteres(arrayAvalistas[contAvalistas - 1]['nrctaava'], '0123456789', true);
            nrcpfcgc_busca = arrayAvalistas[contAvalistas - 1]['nrcpfcgc'];
            mensagem = 'consultando dados ...';
            break;
        case 'I_PROTECAO_TIT':
        case 'A_PROTECAO_TIT':
            iddoaval_busca = 0;
            inpessoa_busca = inpessoa;
            nrdconta_busca = nrdconta;
            nrcpfcgc_busca = 0;
            mensagem = 'consultando dados ...';
            break;
        case 'A_PROTECAO_CONJ':
            iddoaval_busca = 99;
            inpessoa_busca = 1;
            nrdconta_busca = arrayAssociado['nrctacje'];
            nrcpfcgc_busca = arrayAssociado['nrcpfcjg'];
            mensagem = 'consultando dados ...';
            break;
        case 'C_PROTECAO_CONJ':
            iddoaval_busca = 99;
            inpessoa_busca = 1;
            nrdconta_busca = arrayAssociado['nrctacje'];
            nrcpfcgc_busca = arrayAssociado['nrcpfcjg'];
            mensagem = 'consultando dados ...';
            break;
        case 'C_PROTECAO_SOC':
            idSocio = idSocio + 1;
            iddoaval_busca = 0;
            inpessoa_busca = inpessoa;
            nrdconta_busca = nrdconta;
            nrcpfcgc_busca = 0;
            break;
        case 'A_PROTECAO_SOC':
            idSocio = idSocio + 1;
            iddoaval_busca = 0;
            inpessoa_busca = inpessoa;
            nrdconta_busca = nrdconta;
            nrcpfcgc_busca = 0;
            break;
        case 'C_PROTECAO_TIT':
            iddoaval_busca = 0;
            inpessoa_busca = inpessoa;
            nrdconta_busca = nrdconta;
            nrcpfcgc_busca = 0;
            break;
        case 'A_BENS_ASSOC' :
            initArrayBens(operacao);
            mostraTabelaBens('BT', 'A_BENS_ASSOC');
            return false;
            break;
        case 'A_DADOS_PROP' :
            if (inpessoa == 1) {
                mensagem = 'abrindo consultar ...';
                cddopcao = 'A';
            } else {
                controlaOperacao('A_DADOS_PROP_PJ');
                return false;
            }
            break;
        case 'A_DADOS_PROP_PJ' :
            mensagem = 'abrindo altera ...';
            cddopcao = 'A';
            break;
        case 'A_BENS_TITULAR' :
            initArrayBens(operacao);
            mostraTabelaBens('BT', 'A_BENS_TITULAR');
            return false;
            break;
        case 'A_PROT_CRED':
            mensagem = 'abrindo altera ...';
            cddopcao = 'A';
            break;
        case 'A_COMITE_APROV':
            mensagem = 'abrindo altera ...';
            cddopcao = 'A';
            break;
        case 'AI_ALIENACAO':
            mensagem = 'abrindo altera ...';
            cddopcao = 'A';
            booPrimeiroBen = false; //809763
            break;
        case 'A_ALIENACAO' :

            if (arrayProposta['tplcremp'] == 2) {
                if (contAlienacao < nrAlienacao) {
                    mensagem = 'abrindo altera ...';
                    cddopcao = 'A';
                } else {
                    if (contAlienacao == nrAlienacao) {
                        controlaOperacao('AI_ALIENACAO');
                        return false;
                    } else {
                        contAlienacao = 0;
                        controlaOperacao('A_INTEV_ANU');
                        return false;
                    }
                }
            } else if (arrayProposta['tplcremp'] == 3) {
                controlaOperacao('A_HIPOTECA');
                return false;
            } else {
                //controlaOperacao('A_FINALIZA');
                controlaOperacao('A_DEMONSTRATIVO_EMPRESTIMO');                
                return false;
            }
            break;
        case 'AI_HIPOTECA':
            mensagem = 'abrindo altera ...';
            cddopcao = 'A';
            break;
        case 'A_HIPOTECA' :
            if (contHipotecas < nrHipotecas) {
                mensagem = 'abrindo altera ...';
                cddopcao = 'A';
            } else {
                if (contHipotecas == nrHipotecas) {
                    controlaOperacao('AI_HIPOTECA');
                    return false;
                } else {
                    contHipotecas = 0;
                    controlaOperacao('A_FINALIZA');
                    return false;
                }
            }
            break;
        case 'AI_INTEV_ANU':
            mensagem = 'abrindo altera ...';
            cddopcao = 'A';
            break;
        case 'A_INTEV_ANU' :

            if (arrayCooperativa['flginter'] == 'yes') {
                if (contIntervis < nrIntervis) {
                    mensagem = 'abrindo consultar ...';
                    cddopcao = 'A';
                } else {
                    if (contIntervis == nrIntervis) {
                        if (nrIntervis == maxInterv) {
                            contIntervis = 0;
                            controlaOperacao('A_FINALIZA');
                            return false;
                        } else {
                            controlaOperacao('AI_INTEV_ANU');
                            return false;
                        }
                    } else {
                        contIntervis = 0;
                        controlaOperacao('A_FINALIZA');
                        return false;
                    }
                }
            } else {
                contIntervis = 0;
                controlaOperacao('A_FINALIZA');
                return false;
            }
            break;
        case 'A_FINALIZA' :
            mensagem = 'finalizando...';
            cddopcao = 'A';
            break;
        case 'I' :
            booprimeirbooPrimeiroBen = false;
            if (msgDsdidade != '') {
                showError('inform', msgDsdidade, 'Alerta - Ayllos', 'controlaOperacao("TI");');
            } else if (possuiPortabilidade == 'S' && cadastroNovo == 'N') { /* portabilidade */
                controlaOperacao('I_INICIO');
            } else {
                cadastroNovo = 'S';
                controlaOperacao('TI');
            }
            return false;
            break;
        case 'TI' :
            mensagem = 'abrindo inclus&atilde;o...';
            nrctremp = 0;
            resposta = '';
            cddopcao = 'I';
            if (typeof aux_cdmodali_simulacao != 'undefined' && aux_cdmodali_simulacao != '') {
                simula = true;
            }
            break;
        case 'GPR' :
            mensagem = 'abrindo inclus&atilde;o...';
            nrctremp = 0;
            resposta = '';
            cddopcao = 'I';
            simula = true;
            operacao = 'TI';
            break;
        case 'I_INICIO' :
            mensagem = 'abrindo inclus&atilde;o...';
            contAvalistas = 0;
            contAlienacao = 0;
            contHipotecas = 0;
            contIntervis = 0;
            resposta = '';
            cddopcao = 'I';
            booPrimeiroBen = false;//809763
            break;
        case 'I_DADOS_AVAL' :
            if (contAvalistas < nrAvalistas) {
                controlaOperacao('IA_DADOS_AVAL');
                return false;
            } else {
                if (contAvalistas == nrAvalistas) {
                    if (nrAvalistas == maxAvalista) {
                        contAvalistas = 0;
                        controlaOperacao('I_DADOS_PROP');
                        return false;
                    } else {
                        cddopcao = 'I';
                    }
                } else {
                    contAvalistas = 0;
                    controlaOperacao('I_DADOS_PROP');
                    return false;
                }
            }
            break;
        case 'IA_DADOS_AVAL':
            cddopcao = 'I';
            break;
        case 'I_BENS_ASSOC' :
            initArrayBens(operacao);
            mostraTabelaBens('BT', 'I_BENS_ASSOC');
            return false;
            break;
        case 'I_DADOS_PROP' :
            if (inpessoa == 1) {
                cddopcao = 'I';
            } else {
                controlaOperacao('I_DADOS_PROP_PJ');
                return false;
            }
            break;
        case 'I_DADOS_PROP_PJ' :
            cddopcao = 'I';
            break;
        case 'I_BENS_TITULAR' :
            initArrayBens(operacao);
            mostraTabelaBens('BT', 'I_BENS_TITULAR');
            return false;
            break;
        case 'I_PROT_CRED':
            cddopcao = 'I';
            break;
        case 'I_BUSCA_OBS':
            arrayProtCred['dtcnsspc'] = $("#dtcnsspc", "#frmOrgaos").val();
            arrayProtCred['nrinfcad'] = $("#nrinfcad", "#frmOrgaos").val();
            mostraBuscaObs('');
            return false;
            break;
        case 'I_COMITE_APROV':
            cddopcao = 'I';
            break;
        case 'I_ALIENACAO' :

            if (arrayProposta['tplcremp'] == 1) {
                controlaOperacao('I_CONTRATO');
                return false;
            } else if (arrayProposta['tplcremp'] == 2) {

                if (contAlienacao < nrAlienacao) {
                    controlaOperacao('IA_ALIENACAO');
                    return false;
                } else {
                    if (contAlienacao == nrAlienacao) {
                        cddopcao = 'I';
                    } else {
                        contAlienacao = 0;
                        controlaOperacao('I_INTEV_ANU');
                        return false;
                    }
                }
            } else if (arrayProposta['tplcremp'] == 3) {
                controlaOperacao('I_HIPOTECA');
                return false;
            } else {
                //controlaOperacao('');
                controlaOperacao('I_DEMONSTRATIVO_EMPRESTIMO');
                return false;
            }
            break;
        case 'IA_ALIENACAO':
            cddopcao = 'I';
            break;
        case 'I_HIPOTECA' :
            if (contHipotecas < nrHipotecas) {
                controlaOperacao('IA_HIPOTECA');
                return false;
            } else {
                if (contHipotecas == nrHipotecas) {
                    cddopcao = 'I';
                } else {
                    contHipotecas = 0;
                    controlaOperacao('I_FINALIZA');
                    return false;
                }
            }
            break;
        case 'IA_HIPOTECA':
            cddopcao = 'I';
            break;
        case 'I_INTEV_ANU' :
            if (arrayCooperativa['flginter'] == 'yes') {
                if (contIntervis < nrIntervis) {
                    controlaOperacao('IA_INTEV_ANU');
                    return false;
                } else {
                    if (contIntervis == nrIntervis) {
                        if (nrIntervis == maxInterv) {
                            contIntervis = 0;
                            controlaOperacao('I_FINALIZA');
                            return false;
                        } else {
                            mensagem = 'carregando ...';
                            cddopcao = 'I';
                        }
                    } else {
                        contIntervis = 0;
                        controlaOperacao('I_FINALIZA');
                        return false;
                    }
                }
            } else {
                contIntervis = 0;
                controlaOperacao('I_FINALIZA');
                return false;
            }
            break;
        case 'IA_INTEV_ANU':
            cddopcao = 'I';
            break;
        case 'I_CONTRATO' :
            controlaOperacao('I_DEMONSTRATIVO_EMPRESTIMO');
            cddopcao = 'I';
            return false;
            break;
        case 'I_MICRO_PERG':
            cddopcao = 'I';
            qtpergun = $("#qtpergun", "#frmQuestionario").val();
            break;
        case 'C_MICRO_PERG':
            cddopcao = 'C';
            qtpergun = $("#qtpergun", "#frmQuestionario").val();
            nrseqrrq = arrayProposta['nrseqrrq'];
            break;
        case 'A_MICRO_PERG':
            cddopcao = 'A';
            qtpergun = $("#qtpergun", "#frmQuestionario").val();
            nrseqrrq = arrayProposta['nrseqrrq'];
            break;
        case 'I_FINALIZA' :
            mensagem = 'finalizando...';
            cddopcao = 'I';
            break;
        case 'TE' :
            mensagem = 'processando exclus&atilde;o...';
            cddopcao = 'E';
            break;
        case 'E_COMITE_APROV' :
            mensagem = 'processando exclus&atilde;o...';
            cddopcao = 'E';
            break;
        case 'AT' :
            showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'arrayInfoParcelas = new Array();controlaOperacao();', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
            return false;
            break;
        case 'IT' :
            showConfirmacao('Deseja cancelar inclus&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'controlaOperacao()', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
            return false;
            break;
        case 'VA' :
            showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'VA\');', 'controlaOperacao(\'\')', 'sim.gif', 'nao.gif');
            return false;
            break;
        case 'VI':
            
            /*Recarregar o campo tipo emprestimo com a opcao selecionada*/
            var cTipoEmprRec = $('#tpemprst', '#frmNovaProp');
            var tpemprstRec = arrayProposta['tpemprst'];
            var cdtpemprRec = arrayProposta['cdtpempr'];
            var dstpemprRec = arrayProposta['dstpempr'];
            var cdtpemprRec = cdtpemprRec.split(",");
            var dstpemprRec = dstpemprRec.split(",");
            var x = 0;

            for (x = 0; x < cdtpemprRec.length; x++) {
                if (tpemprstRec == cdtpemprRec[x]) {
                    cTipoEmprRec.append("<option value='" + cdtpemprRec[x] + "' selected>" + dstpemprRec[x] + "</option>");
                } else {
                    cTipoEmprRec.append("<option value='" + cdtpemprRec[x] + "'>" + dstpemprRec[x] + "</option>");
                }
            }
            /*Fim Recarregar o campo tipo emprestimo com a opcao selecionada*/

            showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'flgconsu = true; manterRotina(\'VI\')', 'controlaOperacao(\'\')', 'sim.gif', 'nao.gif');
            return false;
            break;
        case 'IV' :
            manterRotina(operacao);
            return false;
            break;
        case 'VI' :
            manterRotina(operacao);
            return false;
            break;
        case 'EV' :
            showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'E\');', 'controlaOperacao(\'\');', 'sim.gif', 'nao.gif');
            return false;
            break;
        case 'VE' :
            manterRotina(operacao);
            return false;
            break;

        case 'IMP' :
            validaImpressao(operacao);
            return false;
            break;
        case 'DIV_IMP' :
            cddopcao = 'M';
            break;
        case 'A_PARC_VALOR':
            mensagem = 'abrindo altera ...';
            cdlcremp = arrayInfoParcelas['cdlcremp'];
            operacao = 'A_VALOR';
            break;
        case 'A_V_PARCELAS':
            mensagem = 'carregando parcelas...';
            cdlcremp = arrayInfoParcelas['cdlcremp'];
            vlempres = arrayInfoParcelas['vlempres'];
            qtparepr = arrayInfoParcelas['qtparepr'];
            qtdialib = arrayInfoParcelas['qtdialib'];
            dtdpagto = arrayInfoParcelas['dtdpagto'];
            operacao = 'A_PARCELAS';
            break;
        case 'C_V_PARCELAS':
            mensagem = 'carregando parcelas...';
            cdlcremp = arrayInfoParcelas['cdlcremp'];
            vlempres = arrayInfoParcelas['vlempres'];
            qtparepr = arrayInfoParcelas['qtparepr'];
            qtdialib = arrayInfoParcelas['qtdialib'];
            dtdpagto = arrayInfoParcelas['dtdpagto'];
            operacao = 'C_PARCELAS';
            break;
        case 'I_V_PARCELAS':
            mensagem = 'carregando parcelas...';
            cdlcremp = arrayInfoParcelas['cdlcremp'];
            vlempres = arrayInfoParcelas['vlempres'];
            qtparepr = arrayInfoParcelas['qtparepr'];
            qtdialib = arrayInfoParcelas['qtdialib'];
            dtdpagto = arrayInfoParcelas['dtdpagto'];
            operacao = 'I_PARCELAS';
            break;
        case 'A_PARCELAS':
        case 'V_PARCELAS':
        case 'C_PARCELAS':
        case 'I_PARCELAS':
            mensagem = 'carregando parcelas...';
            cdlcremp = $('#cdlcremp', '#frmNovaProp').val();
            vlempres = $('#vlemprst', '#frmNovaProp').val();
            qtparepr = $('#qtpreemp', '#frmNovaProp').val();
            qtdialib = $('#qtdialib', '#frmNovaProp').val();
            dtdpagto = $('#dtdpagto', '#frmNovaProp').val();

            arrayInfoParcelas['cdlcremp'] = cdlcremp;
            arrayInfoParcelas['vlempres'] = vlempres;
            arrayInfoParcelas['qtparepr'] = qtparepr;
            arrayInfoParcelas['qtdialib'] = qtdialib;
            arrayInfoParcelas['dtdpagto'] = dtdpagto;

            arrayProposta['tpemprst'] = $('#tpemprst', '#frmNovaProp').val();
            break;
        case 'T_EFETIVA':
            
            // Busca os valores selecionados
            $('table > tbody > tr', 'div.divRegistros').each(function() {
                if ($(this).hasClass('corSelecao')) {
                    portabil = $('#portabil', $(this)).val();
                    err_efet = $('#err_efet', $(this)).val();
                }
            });

            // Nao sera permitido efetivar uma proposta de portabilidade manualmente quando o campo flgerro_efetivacao = FALSE
            if (portabil == 'S' && err_efet == 0) {
                showError('error', 'Não é permitida a efetivação manual de proposta de portabilidade.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina);');
                return false;
            }

            mensagem = 'carregando tela de efetivacao da proposta...';
            cddopcao = 'F';
            $('table > tbody > tr', 'div.divRegistros').each(function() {
                if ($(this).hasClass('corSelecao')) {
                    nrctremp = $('#nrctremp', $(this)).val();
                }
            });
            break;
        case 'T_AVALISTA1':
            mensagem = 'verificando dados do avalista 1...';
            nrctremp = arrayStatusApprov['nrctremp'];
            break;
        case 'T_AVALISTA2':
            mensagem = 'verificando dados do avalista 2...';
            nrctremp = arrayStatusApprov['nrctremp'];
            break;
        case 'V_EFETIVA' :
            showConfirmacao('Deseja cancelar a efetiva&ccedil;&atilde;o da proposta?', 'Confirma&ccedil;&atilde;o - Ayllos', 'controlaOperacao()', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
            return false;
            break;
        case 'RATING' :
            mensagem = 'carregando tabela de rating...';
            cddopcao = 'M';
            break;
            break;
        case 'VAL_GRAVAMES' :
            showConfirmacao('Deseja incluir o registro do bem no Gravames?', 'Confirma&ccedil;&atilde;o - Ayllos', 'controlaOperacao(\'REG_GRAVAMES\')', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
            return false;
            break;
        case 'REG_GRAVAMES' :
            mensagem = 'Registrando Gravame...';
            cddopcao = 'G';
            break;
        case 'VAL_RECALCULAR_EMPRESTIMO' :
            showConfirmacao('Deseja atualizar a data de libera&ccedil;&atilde;o do recurso?', 'Confirma&ccedil;&atilde;o - Ayllos', 'controlaOperacao(\'RECALCULAR_EMPRESTIMO\')', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
            return false;
            break;
        case 'RECALCULAR_EMPRESTIMO' :
            mensagem = 'Recalculando Empr&eacute;stimo...';
            cddopcao = 'R';
            break;
		case 'ACIONAMENTOS': /* Esteira - Acionamentos - Consulta */
            cddopcao = 'C';
        //    numeroProposta = (numeroProposta == 0) ? $("#divEmpres table tr.corSelecao").find("input[id='nrctremp']").val() : numeroProposta;
			mensagem = 'Carregando Consulta de Detalhes da Proposta...';
            break;
        case 'PORTAB_CRED_I': /*Portabilidade - Insercao*/
            cddopcao = 'I';
            //apenas contas de pessoa fisica podem fazer a portabilidade
            if (indTipCoop == 2) {
                showError("error", "Operação não permitida para conta PJ", "Alerta - Ayllos", "bloqueiaFundo(divRotina);");
                return false;
            } else {
                mensagem = 'Carregando Cadastro de Portabilidade...';
            }

            if (typeof aux_cdmodali_simulacao == 'undefined' || aux_cdmodali_simulacao == '') {
                numeroProposta = 0
            }
            break;
        case 'PORTAB_CRED_C': /*Portabilidade - Consulta*/
            cddopcao = 'C';
            numeroProposta = (numeroProposta == 0) ? $("#divEmpres table tr.corSelecao").find("input[id='nrctremp']").val() : numeroProposta;
            mensagem = 'Carregando Consulta de Portabilidade...';
            break;
        case 'PORTAB_CRED_A': /*Portabilidade - Altera*/
            cddopcao = 'A';
            numeroProposta = (numeroProposta == 0) ? $("#divEmpres table tr.corSelecao").find("input[id='nrctremp']").val() : numeroProposta;
            mensagem = 'Carregando Altera&ccedil;&atilde;o de Portabilidade...';
            break;
        case 'ENV_ESTEIRA':
			      insitapr = $("#divEmpres table tr.corSelecao").find("input[id='insitapr']").val();
			      dssitest = $("#divEmpres table tr.corSelecao").find("input[id='dssitest']").val();
            mensagem = 'Enviando Proposta para An&aacute;lise de Cr&eacute;dito...';
			if (dssitest == 'Analise Finalizada' && insitapr == 2){				
				showConfirmacao('Confirma envio da Proposta para An&aacute;lise de Cr&eacute;dito? <br> Observa&ccedil;&atildeo: Ser&aacute; necess&aacute;ria aprova&ccedil;&atilde;o de seu Coordenador pois a mesma foi reprovada automaticamente!', 'Confirma&ccedil;&atilde;o - Ayllos', 'pedeSenhaCoordenador(2,\'manterRotina("ENV_ESTEIRA")\',\'divRotina\');', 'controlaOperacao(\'\');', 'sim.gif', 'nao.gif');
			}else{
				showConfirmacao('Confirma envio da Proposta para An&aacute;lise de Cr&eacute;dito?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'ENV_ESTEIRA\');', 'controlaOperacao(\'\');', 'sim.gif', 'nao.gif');
			}
            return false;
            break;
        //case 'DEMONSTRATIVO_EMPRESTIMO':
        case 'A_DEMONSTRATIVO_EMPRESTIMO':
        case 'I_DEMONSTRATIVO_EMPRESTIMO':
            tpemprst = arrayProposta['tpemprst'];
            cdlcremp = arrayProposta['cdlcremp'];
            vlempres = number_format(parseFloat(arrayProposta['vlemprst'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
            qtparepr = arrayProposta['qtpreemp'];
            qtdialib = arrayProposta['dtlibera'];
            dtdpagto = arrayProposta['dtdpagto'];
			dsctrliq = arrayProposta['dsctrliq'];
			idcarenc = arrayProposta['idcarenc'];
			dtcarenc = arrayProposta['dtcarenc'];
            cddopcao = 'C';
            vlpreemp = number_format(parseFloat(arrayProposta['vlpreemp'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
            mensagem = 'Carregando Demonstrativo da Proposta...';
            dscatbem = '';
            cdfinemp = arrayProposta['cdfinemp']
            //Carrega a lista de bens para enviar junto no POST
            for (i in arrayHipotecas) {
                dscatbem += arrayHipotecas[i]['dscatbem'] + '|';
            }
            for (i in arrayAlienacoes) {
                dscatbem += arrayAlienacoes[i]['dscatbem'] + '|';
            }            
            idfiniof = arrayProposta['idfiniof'];
            break;
        default:
            operacao = '';
            nrctremp = '';
            cddopcao = '@';
            modalidade = '0';
            possuiPortabilidade = '';
            cadastroNovo = '';
            mensagem = 'carregando...';
            arrayDadosPortabilidade = new Array();
            numeroProposta = ''
            aux_cdmodali_simulacao = '';
    }

    var inconcje = 0;
    var tplcremp = (typeof arrayProposta == 'undefined') ? 0 : arrayProposta['tplcremp'];
    var dtcnsspc = (typeof arrayProtCred == 'undefined') ? '' : arrayProtCred['dtcnsspc'];

    if (inpessoa == 1) {
        inconcje = (arrayRendimento['inconcje'] == 'yes') ? 1 : 0;
    }
	/*
    if ( ( operacao != 'RECALCULAR_EMPRESTIMO') && ( operacao != '') ) {
        $('.divRegistros').remove();
    }
*/
    mensagem = (mensagem == "") ? 'carregando...' : mensagem;

    showMsgAguardo('Aguarde, ' + mensagem);

    // Executa script de através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/principal.php',
        data: {
            nrdconta: nrdconta, idseqttl: idseqttl,
            operacao: operacao, nrctremp: nrctremp,
            cdlcremp: cdlcremp, vlempres: vlempres,
            qtparepr: qtparepr, qtdialib: qtdialib,
            dtdpagto: dtdpagto, tpemprst: tpemprst,
            cddopcao: cddopcao, tplcremp: tplcremp,
            dtcnsspc: dtcnsspc, idSocio: idSocio,
            inconcje: inconcje, qtpergun: qtpergun,
            nrseqrrq: nrseqrrq, inprodut: 1,
            nrdocmto: nrctremp, vlpreemp: vlpreemp,
            iddoaval_busca: iddoaval_busca,
            inpessoa_busca: inpessoa_busca,
            nrdconta_busca: nrdconta_busca,
            nrcpfcgc_busca: nrcpfcgc_busca,
            inpessoa: inpessoa, dscatbem: dscatbem,
            idfiniof: idfiniof, cdfinemp: cdfinemp,
            inconfir: 1, dsctrliq : dsctrliq,
			dtcarenc: dtcarenc, idcarenc:idcarenc, 
            nomeAcaoCall: nomeAcaoCall,
			executandoProdutos: executandoProdutos,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
			
			if ( operacao != 'RECALCULAR_EMPRESTIMO') {
				$('.divRegistros').remove();
			}
			
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
			
			if ( operacao != 'RECALCULAR_EMPRESTIMO') {
				$('.divRegistros').remove();
			}
			
            if (response.indexOf('showError("error"') == -1) {

                if (cddopcao == 'G') {
                    hideMsgAguardo();
                    showError('inform', 'Registro de alienacao do Gravame incluido com sucesso!', 'Alerta - Ayllos', 'controlaOperacao("");');
                } else {
                    if (simula == true) {
                        buscarDadosSimulacao(auxind, operacao, response);
                    } else {
                        if (operacao == 'RECALCULAR_EMPRESTIMO') {
                            hideMsgAguardo();
                            bloqueiaFundo(divRotina);
                            eval(response);
                        } else {
							
							if (nomeAcaoCall == 'A_AVALISTA'){
								if (operacao == 'A_AVALISTA') {
									$('#divConteudoOpcao').hide();
									$('#divRotina').hide();
								}else if ((operacao == 'AI_DADOS_AVAL') || (operacao == 'A_DADOS_AVAL')){
									$('#divConteudoOpcao').show();
									$('#divRotina').show();
								}
							}
							
                            $('#divConteudoOpcao').html(response);

							if (operacao == 'ACIONAMENTOS') {
								formataAcionamento();
                        }
                        }
                        //consulta campos de portabilidade	
                        if (in_array(operacao, ['PORTAB_CRED_C', 'PORTAB_CRED_I', 'PORTAB_CRED_A'])) {
                            //carrega os campos da tela
                            carregaCamposPortabilidade(cdcooper, nrdconta, numeroProposta, 'PROPOSTA');
                        }
                    }
                }

                if ((operacao == 'C_ALIENACAO') ||
                        (operacao == 'AI_ALIENACAO') ||
                        (operacao == 'A_ALIENACAO') ||
                        (operacao == 'E_ALIENACAO') ||
                        (operacao == 'I_ALIENACAO') ||
                        (operacao == 'IA_ALIENACAO')) {
                    busca_uf_pa_ass();
                }
                
                if (arrayProposta['tpemprst'] == 0){
                    $("#idfiniof").desabilitaCampo();
                    $("#idfiniof").val(0);
                    arrayProposta['tpemprst'] = 0;
                }
                
            } else {
                eval(response);
            }
            return false;
        }
    });
}

//001: Passado os dados via Ajax para o manter_rotina.php
function manterRotina(operacao) {

    var nrcpfcgc = normalizaNumero($("#nrcpfcgc", "#frmCabAtenda").val());

    hideMsgAguardo();

    var mensagem = '';
    switch (operacao) {
        case 'F_VALOR':
            mensagem = 'alterando';
            break;
        case 'F_NUMERO':
            mensagem = 'alterando';
            break;
        case 'F_AVALISTA':
            mensagem = 'alterando';
            break;
        case 'AV':
            mensagem = 'validando altera&ccedil;&atilde;o';
            break;
        case 'IV':
            mensagem = 'validando inclus&atilde;o';
            break;
        case 'EV':
            mensagem = 'validando exclus&atilde;o';
            break;
        case 'VA':
            mensagem = 'alterando';
            break;
        case 'VI':
            mensagem = 'incluindo';
            break;
        case 'E':
            mensagem = 'excluindo';
            break;
        case 'ENV_ESTEIRA':
            mensagem = 'Enviando Proposta para An&aacute;lise de Cr&eacute;dito...';
            break;
        default:
            controlaOperacao();
            return false;
            break;
    }

    showMsgAguardo('Aguarde, ' + mensagem + '...');

    if (operacao != 'ENV_ESTEIRA' ){
        
    var aux_nrctaav0 = 0;
    var aux_nrctaav1 = 0;

    for (i in arrayAvalistas) {
        eval('aux_nrctaav' + i + ' = arrayAvalistas[' + i + '][\'nrctaava\'];')
    }

    geraRegsDinamicos();

    
    var flgcmtlc = (typeof arrayCooperativa['flgcmtlc'] == 'undefined') ? '' : arrayCooperativa['flgcmtlc'];
    var vllimapv = (typeof arrayCooperativa['vllimapv'] == 'undefined') ? '' : arrayCooperativa['vllimapv'];

    var vlemprst = (typeof arrayProposta['vlemprst'] == 'undefined') ? '' : arrayProposta['vlemprst'];
    var vlpreemp = (typeof arrayProposta['vlpreemp'] == 'undefined') ? '' : arrayProposta['vlpreemp'];
    var tpemprst = (typeof arrayProposta['tpemprst'] == 'undefined') ? '' : arrayProposta['tpemprst'];
    var qtpreemp = (typeof arrayProposta['qtpreemp'] == 'undefined') ? '' : arrayProposta['qtpreemp'];
    var dsnivris = (typeof arrayProposta['nivrisco'] == 'undefined') ? '' : arrayProposta['nivrisco'];
    var cdlcremp = (typeof arrayProposta['cdlcremp'] == 'undefined') ? '' : arrayProposta['cdlcremp'];
    var cdfinemp = (typeof arrayProposta['cdfinemp'] == 'undefined') ? '' : arrayProposta['cdfinemp'];
    var qtdialib = (typeof arrayProposta['qtdialib'] == 'undefined') ? '' : arrayProposta['qtdialib'];
    var flgimppr = (typeof arrayProposta['flgimppr'] == 'undefined') ? '' : arrayProposta['flgimppr'];
    var flgimpnp = (typeof arrayProposta['flgimpnp'] == 'undefined') ? '' : arrayProposta['flgimpnp'];
    var percetop = (typeof arrayProposta['percetop'] == 'undefined') ? '' : arrayProposta['percetop'];
    var idquapro = (typeof arrayProposta['idquapro'] == 'undefined') ? '' : arrayProposta['idquapro'];
    var dtdpagto = (typeof arrayProposta['dtdpagto'] == 'undefined') ? '' : arrayProposta['dtdpagto'];
    var qtpromia = (typeof arrayProposta['qtpromis'] == 'undefined') ? '' : arrayProposta['qtpromis'];
    var flgpagto = (typeof arrayProposta['flgpagto'] == 'undefined') ? '' : arrayProposta['flgpagto'];
    var dsctrliq = (typeof arrayProposta['dsctrliq'] == 'undefined') ? '' : arrayProposta['dsctrliq'];
    var dtlibera = (typeof arrayProposta['dtlibera'] == 'undefined') ? '' : arrayProposta['dtlibera'];
    var dsobserv = (typeof arrayProposta['dsobserv'] == 'undefined') ? '' : arrayProposta['dsobserv'];
    var idfiniof = (typeof arrayProposta['idfiniof'] == 'undefined') ? '' : arrayProposta['idfiniof'];
    var vliofepr = (typeof arrayProposta['vliofepr'] == 'undefined') ? '' : arrayProposta['vliofepr'];
    var vlrtarif = (typeof arrayProposta['vlrtarif'] == 'undefined') ? '' : arrayProposta['vlrtarif'];
    var vlrtotal = (typeof arrayProposta['vlrtotal'] == 'undefined') ? '' : arrayProposta['vlrtotal'];
    var vlfinanc = (typeof arrayProposta['vlfinanc'] == 'undefined') ? '' : arrayProposta['vlfinanc'];

    var nrctaava = (typeof aux_nrctaav0 == 'undefined') ? '' : aux_nrctaav0;
    var nrctaav2 = (typeof aux_nrctaav1 == 'undefined') ? '' : aux_nrctaav1;
    var idcarenc = (typeof arrayProposta['idcarenc'] == 'undefined') ? '' : arrayProposta['idcarenc'];
    var dtcarenc = (typeof arrayProposta['dtcarenc'] == 'undefined') ? '' : arrayProposta['dtcarenc'];

    var nrgarope = (typeof arrayProtCred['nrgarope'] == 'undefined') ? '' : arrayProtCred['nrgarope'];
    var nrperger = (typeof arrayProtCred['nrperger'] == 'undefined') ? '' : arrayProtCred['nrperger'];
    var dtcnsspc = (typeof arrayProtCred['dtcnsspc'] == 'undefined') ? '' : arrayProtCred['dtcnsspc'];
    var nrinfcad = (typeof arrayProtCred['nrinfcad'] == 'undefined') ? '' : arrayProtCred['nrinfcad'];
    var dtdrisco = (typeof arrayProtCred['dtdrisco'] == 'undefined') ? '' : arrayProtCred['dtdrisco'];
    var vltotsfn = (typeof arrayProtCred['vltotsfn'] == 'undefined') ? '' : arrayProtCred['vltotsfn'];
    var qtopescr = (typeof arrayProtCred['qtopescr'] == 'undefined') ? '' : arrayProtCred['qtopescr'];
    var qtifoper = (typeof arrayProtCred['qtifoper'] == 'undefined') ? '' : arrayProtCred['qtifoper'];
    var nrliquid = (typeof arrayProtCred['nrliquid'] == 'undefined') ? '' : arrayProtCred['nrliquid'];
    var vlopescr = (typeof arrayProtCred['vlopescr'] == 'undefined') ? '' : arrayProtCred['vlopescr'];
    var vlrpreju = (typeof arrayProtCred['vlrpreju'] == 'undefined') ? '' : arrayProtCred['vlrpreju'];
    var nrpatlvr = (typeof arrayProtCred['nrpatlvr'] == 'undefined') ? '' : arrayProtCred['nrpatlvr'];
    var dtoutspc = (typeof arrayProtCred['dtoutspc'] == 'undefined') ? '' : arrayProtCred['dtoutspc'];
    var dtoutris = (typeof arrayProtCred['dtoutris'] == 'undefined') ? '' : arrayProtCred['dtoutris'];
    var vlsfnout = (typeof arrayProtCred['vlsfnout'] == 'undefined') ? '' : arrayProtCred['vlsfnout'];

    var vlsalari = (typeof arrayRendimento['vlsalari'] == 'undefined') ? '' : arrayRendimento['vlsalari'];
    var vloutras = (typeof arrayRendimento['vloutras'] == 'undefined') ? '' : arrayRendimento['vloutras'];
    var vlalugue = (typeof arrayRendimento['vlalugue'] == 'undefined') ? '' : arrayRendimento['vlalugue'];
    var inconcje = (typeof arrayRendimento['inconcje'] == 'undefined') ? '' : arrayRendimento['inconcje'];
    var vlsalcon = (typeof arrayRendimento['vlsalcon'] == 'undefined') ? '' : arrayRendimento['vlsalcon'];
    var nmempcje = (typeof arrayRendimento['nmextemp'] == 'undefined') ? '' : arrayRendimento['nmextemp'];
    var flgdocje = (typeof arrayRendimento['flgdocje'] == 'undefined') ? '' : arrayRendimento['flgdocje'];

    if (flgdocje == 'no') {
        var nrctacje = 0;
        var nrcpfcjg = 0;
    } else {
        var nrctacje = (typeof arrayAssociado['nrctacje'] == 'undefined') ? '' : arrayAssociado['nrctacje'];
        var nrcpfcjg = (typeof arrayAssociado['nrcpfcjg'] == 'undefined') ? '' : arrayAssociado['nrcpfcjg'];
    }

    var perfatcl = (typeof arrayRendimento['perfatcl'] == 'undefined') ? '' : arrayRendimento['perfatcl'];
    var vlmedfat = (typeof arrayRendimento['vlmedfat'] == 'undefined') ? '' : arrayRendimento['vlmedfat'];
    var dsjusren = (typeof arrayRendimento['dsjusren'] == 'undefined') ? '' : arrayRendimento['dsjusren'];

    var dsdfinan = (typeof aux_dsdfinan == 'undefined') ? '' : aux_dsdfinan;
    var dsdrendi = (typeof aux_dsdrendi == 'undefined') ? '' : aux_dsdrendi;
    var dsdebens = (typeof aux_dsdebens == 'undefined') ? '' : aux_dsdebens;
    var dsdalien = (typeof aux_dsdalien == 'undefined') ? '' : aux_dsdalien;
    var dsinterv = (typeof par_dsinterv == 'undefined') ? '' : par_dsinterv;

    var nmdaval1 = (typeof aux_nmdaval0 == 'undefined') ? '' : aux_nmdaval0;
    var nrcpfav1 = (typeof aux_nrcpfav0 == 'undefined') ? '' : aux_nrcpfav0;
    var tpdocav1 = (typeof aux_tpdocav0 == 'undefined') ? '' : aux_tpdocav0;
    var dsdocav1 = (typeof aux_dsdocav0 == 'undefined') ? '' : aux_dsdocav0;
    var nmdcjav1 = (typeof aux_nmdcjav0 == 'undefined') ? '' : aux_nmdcjav0;
    var cpfcjav1 = (typeof aux_cpfcjav0 == 'undefined') ? '' : aux_cpfcjav0;
    var tdccjav1 = (typeof aux_tdccjav0 == 'undefined') ? '' : aux_tdccjav0;
    var doccjav1 = (typeof aux_doccjav0 == 'undefined') ? '' : aux_doccjav0;
    var ende1av1 = (typeof aux_ende1av0 == 'undefined') ? '' : aux_ende1av0;
    var ende2av1 = (typeof aux_ende2av0 == 'undefined') ? '' : aux_ende2av0;
    var nrfonav1 = (typeof aux_nrfonav0 == 'undefined') ? '' : aux_nrfonav0;
    var emailav1 = (typeof aux_emailav0 == 'undefined') ? '' : aux_emailav0;
    var nmcidav1 = (typeof aux_nmcidav0 == 'undefined') ? '' : aux_nmcidav0;
    var cdufava1 = (typeof aux_cdufava0 == 'undefined') ? '' : aux_cdufava0;
    var nrcepav1 = (typeof aux_nrcepav0 == 'undefined') ? '' : aux_nrcepav0;
    var cdnacio1 = (typeof aux_cdnacio0 == 'undefined') ? '' : aux_cdnacio0;
    var vledvmt1 = (typeof aux_vledvmt0 == 'undefined') ? '' : aux_vledvmt0;
    var vlrenme1 = (typeof aux_vlrenme0 == 'undefined') ? '' : aux_vlrenme0;
    var nrender1 = (typeof aux_nrender0 == 'undefined') ? '' : aux_nrender0;
    var complen1 = (typeof aux_complen0 == 'undefined') ? '' : aux_complen0;
    var nrcxaps1 = (typeof aux_nrcxaps0 == 'undefined') ? '' : aux_nrcxaps0;

    // Daniel
    var inpesso1 = (typeof aux_inpesso0 == 'undefined') ? '' : aux_inpesso0;
    var dtnasct1 = (typeof aux_dtnasct0 == 'undefined') ? '' : aux_dtnasct0;

    var nmdaval2 = (typeof aux_nmdaval1 == 'undefined') ? '' : aux_nmdaval1;
    var nrcpfav2 = (typeof aux_nrcpfav1 == 'undefined') ? '' : aux_nrcpfav1;
    var tpdocav2 = (typeof aux_tpdocav1 == 'undefined') ? '' : aux_tpdocav1;
    var dsdocav2 = (typeof aux_dsdocav1 == 'undefined') ? '' : aux_dsdocav1;
    var nmdcjav2 = (typeof aux_nmdcjav1 == 'undefined') ? '' : aux_nmdcjav1;
    var cpfcjav2 = (typeof aux_cpfcjav1 == 'undefined') ? '' : aux_cpfcjav1;
    var tdccjav2 = (typeof aux_tdccjav1 == 'undefined') ? '' : aux_tdccjav1;
    var doccjav2 = (typeof aux_doccjav1 == 'undefined') ? '' : aux_doccjav1;
    var ende1av2 = (typeof aux_ende1av1 == 'undefined') ? '' : aux_ende1av1;
    var ende2av2 = (typeof aux_ende2av1 == 'undefined') ? '' : aux_ende2av1;
    var nrfonav2 = (typeof aux_nrfonav1 == 'undefined') ? '' : aux_nrfonav1;
    var emailav2 = (typeof aux_emailav1 == 'undefined') ? '' : aux_emailav1;
    var nmcidav2 = (typeof aux_nmcidav1 == 'undefined') ? '' : aux_nmcidav1;
    var cdufava2 = (typeof aux_cdufava1 == 'undefined') ? '' : aux_cdufava1;
    var nrcepav2 = (typeof aux_nrcepav1 == 'undefined') ? '' : aux_nrcepav1;
    var cdnacio2 = (typeof aux_cdnacio1 == 'undefined') ? '' : aux_cdnacio1;
    var vledvmt2 = (typeof aux_vledvmt1 == 'undefined') ? '' : aux_vledvmt1;
    var vlrenme2 = (typeof aux_vlrenme1 == 'undefined') ? '' : aux_vlrenme1;
    var nrender2 = (typeof aux_nrender1 == 'undefined') ? '' : aux_nrender1;
    var complen2 = (typeof aux_complen1 == 'undefined') ? '' : aux_complen1;
    var nrcxaps2 = (typeof aux_nrcxaps1 == 'undefined') ? '' : aux_nrcxaps1;
    } 
    // Daniel
    var inpesso2 = (typeof aux_inpesso1 == 'undefined') ? '' : aux_inpesso1;
    var dtnasct2 = (typeof aux_dtnasct1 == 'undefined') ? '' : aux_dtnasct1;

    var dsdbeavt = (typeof aux_dsdbeavt == 'undefined') ? '' : aux_dsdbeavt;

    var vlpreant = (typeof vleprori == 'undefined') ? '' : vleprori;

    var dsdopcao = "SVP";

    var nrctrant = (typeof nrctremp == 'undefined') ? '' : nrctremp;

    var nrctreax = (operacao == 'F_NUMERO') ? new_nrctremp : nrctremp;

    //Retira  caracteres
    // 032 : comentado replace do campo vlopescr
    //vlopescr = parseFloat( vlopescr.replace(',','.') );

    if (operacao != 'ENV_ESTEIRA' ){
    vlemprst = number_format(parseFloat(vlemprst.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    percetop = number_format(parseFloat(percetop.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    vltotsfn = number_format(parseFloat(vltotsfn.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    vlrpreju = number_format(parseFloat(vlrpreju.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    vlsfnout = number_format(parseFloat(vlsfnout.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    vloutras = number_format(parseFloat(vloutras.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    vlalugue = number_format(parseFloat(vlalugue.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    vlsalcon = number_format(parseFloat(vlsalcon.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    vledvmt2 = number_format(parseFloat(vledvmt2.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    vlrenme2 = number_format(parseFloat(vlrenme2.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    vlsalari = number_format(parseFloat(vlsalari.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    vlmedfat = number_format(parseFloat(vlmedfat.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    vledvmt1 = number_format(parseFloat(vledvmt1.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    vlrenme1 = number_format(parseFloat(vlrenme1.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');

    dtcnsspc = (dtcnsspc == '') ? '?' : dtcnsspc;
    dtdpagto = (dtdpagto == '') ? '?' : dtdpagto;
    dtoutspc = (dtoutspc == '') ? '?' : dtoutspc;
    dtoutris = (dtoutris == '') ? '?' : dtoutris;
    nrinfcad = (nrinfcad == '') ? 1 : nrinfcad;
    idfiniof = (idfiniof == '') ? 1 : idfiniof;

    nrcpfcjg = normalizaNumero(nrcpfcjg);
    nrcpfav1 = normalizaNumero(nrcpfav1);
    cpfcjav1 = normalizaNumero(cpfcjav1);
    nrcpfav2 = normalizaNumero(nrcpfav2);
    cpfcjav2 = normalizaNumero(cpfcjav2);
    nrcepav2 = normalizaNumero(nrcepav2);
    nrctaava = normalizaNumero(nrctaava);
    nrctaav2 = normalizaNumero(nrctaav2);

    nrcepav1 = normalizaNumero(nrcepav1);
    nrender1 = normalizaNumero(nrender1);
    nrcxaps1 = normalizaNumero(nrcxaps1);

    dsobserv = dsobserv.replace(/\r\n/g, ' ').replace("'", "");
    dsobserv = removeCaracteresInvalidos(dsobserv);
    }   

    var dscatbem = "";
    //Carrega a lista de bens para enviar junto no POST
    for (i in arrayHipotecas) {
        dscatbem += arrayHipotecas[i]['dscatbem'] + '|';
    }
    for (i in arrayAlienacoes) {
        dscatbem += arrayAlienacoes[i]['dscatbem'] + '|';
    }

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/emprestimos/manter_rotina.php',
        data: {
            nrdconta: nrdconta, idseqttl: idseqttl, inpessoa: inpessoa,
            nrctremp: nrctreax, flgcmtlc: flgcmtlc, vlutiliz: vlutiliz,
            vllimapv: vllimapv, vlemprst: vlemprst, vlpreemp: vlpreemp,
            qtpreemp: qtpreemp, dsnivris: dsnivris, cdlcremp: cdlcremp,
            cdfinemp: cdfinemp, qtdialib: qtdialib, flgimppr: flgimppr,
            flgimpnp: flgimpnp, percetop: percetop, idquapro: idquapro,
            dtdpagto: dtdpagto, qtpromis: qtpromia, flgpagto: flgpagto,
            dsctrliq: dsctrliq, nrctaava: nrctaava, nrctaav2: nrctaav2,
            nrgarope: nrgarope, nrperger: nrperger, dtcnsspc: dtcnsspc,
            nrinfcad: nrinfcad, dtdrisco: dtdrisco, vltotsfn: vltotsfn,
            qtopescr: qtopescr, qtifoper: qtifoper, nrliquid: nrliquid,
            vlopescr: vlopescr, vlrpreju: vlrpreju, nrpatlvr: nrpatlvr,
            dtoutspc: dtoutspc, dtoutris: dtoutris, vlsfnout: vlsfnout,
            vlsalari: vlsalari, vloutras: vloutras, vlalugue: vlalugue,
            vlsalcon: vlsalcon, nmempcje: nmempcje, flgdocje: flgdocje,
            nrctacje: nrctacje, nrcpfcjg: nrcpfcjg, perfatcl: perfatcl,
            vlmedfat: vlmedfat, dsobserv: dsobserv, dsdfinan: dsdfinan,
            dsdrendi: dsdrendi, dsdebens: dsdebens, dsdalien: dsdalien,
            dsinterv: dsinterv, nmdaval1: nmdaval1, nrcpfav1: nrcpfav1,
            tpdocav1: tpdocav1, dsdocav1: dsdocav1, nmdcjav1: nmdcjav1,
            cpfcjav1: cpfcjav1, tdccjav1: tdccjav1, doccjav1: doccjav1,
            ende1av1: ende1av1, ende2av1: ende2av1, nrfonav1: nrfonav1,
            emailav1: emailav1, nmcidav1: nmcidav1, cdufava1: cdufava1,
            nrcepav1: nrcepav1, cdnacio1: cdnacio1, vledvmt1: vledvmt1,
            nrender1: nrender1, complen1: complen1, nrcxaps1: nrcxaps1,
            nmdaval2: nmdaval2, nrcpfav2: nrcpfav2, tpdocav2: tpdocav2,
            dsdocav2: dsdocav2, nmdcjav2: nmdcjav2, cpfcjav2: cpfcjav2,
            tdccjav2: tdccjav2, doccjav2: doccjav2, ende1av2: ende1av2,
            ende2av2: ende2av2, nrfonav2: nrfonav2, emailav2: emailav2,
            nmcidav2: nmcidav2, cdufava2: cdufava2, nrcepav2: nrcepav2,
            cdnacio2: cdnacio2, vlrenme1: vlrenme1, vledvmt2: vledvmt2,
            vlrenme2: vlrenme2, nrender2: nrender2, complen2: complen2,
            nrcxaps2: nrcxaps2, dsdbeavt: dsdbeavt, dsdopcao: dsdopcao,
            vlpreant: vlpreant, nrctrant: nrctrant, operacao: operacao,
            tpemprst: tpemprst, nrcpfcgc: nrcpfcgc, dsjusren: dsjusren,
            dtlibera: dtlibera, inconcje: inconcje, flgconsu: flgconsu,
            blqpreap: (bloquear_pre_aprovado ? 1 : 0),
            idcarenc: idcarenc, dtcarenc: dtcarenc,
            // Daniel
            inpesso1: inpesso1, dtnasct1: dtnasct1, dscatbem: dscatbem,
            inpesso2: inpesso2, dtnasct2: dtnasct2, cddopcao: cddopcao,
            resposta: resposta, idfiniof: idfiniof, vliofepr: vliofepr,
            vlrtarif: vlrtarif, vlrtotal: vlrtotal, vlfinanc: vlfinanc,
            executandoProdutos: executandoProdutos, redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {
                
                eval(response);

               if (operacao != 'ENV_ESTEIRA'){ 
                if (typeof arrayDadosPortabilidade['nrcnpjbase_if_origem'] != 'undefined' &&
                        typeof arrayDadosPortabilidade['nrcontrato_if_origem'] != 'undefined' &&
                        typeof arrayDadosPortabilidade['nmif_origem'] != 'undefined' &&
                        cddopcao == 'I') {

                    //cadastra a proposta de portabilidade
                    cadastraPortabilidade(nrdconta, nrctremp, 1,
                            arrayDadosPortabilidade['nrcnpjbase_if_origem'],
                            arrayDadosPortabilidade['nmif_origem'],
                            arrayDadosPortabilidade['nrcontrato_if_origem'])
                }
                }

                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });
}

function retornaListaFeriados() {

    $.ajax({
        type: "POST",
        async: true,
        url: UrlSite + "telas/atenda/emprestimos/busca_feriados.php",
        data: {
            cdcooper: arrayProposta['cdcooper'],
            dtmvtolt: arrayProposta['dtmvtolt'],
            redirect: 'script_ajax' // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "unblockBackground()");
        },
        success: function(response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
            }
        }
    });

}

function calculaDiasUteis(dataFinal) {

    if ($("#qtdialib").prop("disabled")) {
        return false;
    }

    showMsgAguardo("Aguarde, calculando dias &uacute;teis ...");

    var dtfinper = dataFinal;
    var dtiniper = arrayProposta['dtmvtolt'];

    if (operacao == "TI" || operacao == "I_INICIO" || operacao == "A_NOVA_PROP") {
        dtiniper = "";
    }

    $.ajax({
        type: "POST",
        async: true,
        url: UrlSite + "telas/atenda/emprestimos/calcula_dias_uteis.php",
        data: {
            dtfinper: dtfinper,
            dtiniper: dtiniper,
            redirect: 'script_ajax' // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "unblockBackground()");
        },
        success: function(response) {
            try {
                eval(response);
                bloqueiaFundo(divRotina);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
            }
        }
    });

}

function verificaQtDiaLib() {

    $('#flgpagto').habilitaCampo();

    switch ($('#tpemprst').val()) {
        case '0': // TR
            $('#qtdialib').habilitaCampo();
            $("#qtdialib").datepicker('enable');
            if ($('#qtdialib').val().length > 1) {
                showError('error', 'A data de libera&ccedil;&atilde;o n&atilde;o pode ser maior que 9 dias.', 'Alerta - Ayllos', 'focaCampoErro(\'qtdialib\',\'frmNovaProp\');bloqueiaFundo(divRotina);');
                $('#qtdialib').val('0');
                $('#qtdialib').change();
            }
            $("#idfiniof").desabilitaCampo();
            $("#idfiniof").val(0);
            break;
        case '1': // Pre-Fixado
            $('#qtdialib').desabilitaCampo();
            $("#qtdialib").datepicker('disable');
            $('#qtdialib').val('0');
            $('#qtdialib').change();
            $("#idfiniof").habilitaCampo();
            break;
        case '2': // Pos-Fixado
            $('#flgpagto').desabilitaCampo();
            $('#qtdialib').desabilitaCampo();
            $("#qtdialib").datepicker('disable');
            $('#qtdialib').val('0');
            $('#qtdialib').change();
            $("#idfiniof").habilitaCampo();
            break;
    }
    return true;
}

//000: Habilitado/Desabilitado campos dependendo da operação
function controlaLayout(operacao) {

    // Visualização em tabela
    if (in_array(operacao, ['AT', 'IT', 'FI', 'FA', 'FE', 'SC', ''])) {

        var divRegistro = $('div.divRegistros');
        var tabela = $('table', divRegistro);
        var linha = $('table > tbody > tr', divRegistro);

        divRegistro.css('height', '150px');

        altura = '230px';
        largura = '950px';

        var ordemInicial = new Array();
        //ordemInicial = [[0, 0]];

        var arrayLargura = new Array();
        arrayLargura[0] = '60px';
        arrayLargura[1] = '60px';
        arrayLargura[2] = '130px';
        arrayLargura[3] = '75px';
        arrayLargura[4] = '75px';
        arrayLargura[5] = '65px';
        arrayLargura[6] = '35px';
        arrayLargura[7] = '35px';
        arrayLargura[8] = '35px';
        arrayLargura[9] = '65px';
        arrayLargura[10] = '120px';


        var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'right';
        arrayAlinha[2] = 'center';
        arrayAlinha[3] = 'right';
        arrayAlinha[4] = 'right';
        arrayAlinha[5] = 'right';
        arrayAlinha[6] = 'center';
        arrayAlinha[7] = 'center';
        arrayAlinha[8] = 'center';
        arrayAlinha[9] = 'center';
        arrayAlinha[10] = 'center';
        arrayAlinha[11] = 'center';

        var metodoTabela = 'controlaOperacao(\'TA\')';
        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

        // Operação Alterando/Incluindo
    } else if (in_array(operacao, ['TI', 'TE', 'TC', 'TA', 'CF', 'A_NOVA_PROP', 'A_NUMERO', 'I_CONTRATO', 'I_FINALIZA', 'A_FINALIZA', 'I_INICIO', 'A_INICIO', 'A_VALOR', 'A_AVALISTA'])) {


        nomeForm = 'frmNovaProp';
        altura = '340px';
        largura = '465px';

        inconfir = 1;
        inconfi2 = 30;

        var rRotulos = $('label[for="nivrisco"],label[for="qtpreemp"],label[for="vlpreemp"],label[for="vlemprst"],label[for="flgpagto"],label[for="tpemprst"],label[for="dsctrliq"],label[for="vlfinanc"]', '#' + nomeForm);
        var cTodos = $('select,input', '#' + nomeForm);
        var r_Linha1 = $('label[for="cdlcremp"]', '#' + nomeForm);
        var rCet = $('label[for="percetop"]', '#' + nomeForm);
        var rDiasUteis = $('#duteis', '#' + nomeForm);
        var r_Linha2 = $('label[for="nivcalcu"],label[for="flgimpnp"],label[for="dtdpagto"],label[for="vlpreemp"]', '#' + nomeForm);
        var cCodigo = $('#cdfinemp,#idquapro,#cdlcremp', '#' + nomeForm);
        var cDescricao = $('#dslcremp,#dsquapro,#dsfinemp', '#' + nomeForm);

        var rNivelRic = $('label[for="nivrisco"]', '#' + nomeForm);
        var rRiscoCalc = $('label[for="nivcalcu"]', '#' + nomeForm);
        var rVlEmpr = $('label[for="vlemprst"]', '#' + nomeForm);
        var rLnCred = $('label[for="cdlcremp"]', '#' + nomeForm);
        var rDsLnCred = $('label[for="dslcremp"]', '#' + nomeForm);
        var rVlPrest = $('label[for="vlpreemp"]', '#' + nomeForm);
        var rFinali = $('label[for="cdfinemp"]', '#' + nomeForm);
        var rDsFinali = $('label[for="dsfinemp"]', '#' + nomeForm);
        var rQtParc = $('label[for="qtpreemp"]', '#' + nomeForm);
        var rQualiParc = $('label[for="idquapro"]', '#' + nomeForm);
        var rDsQualiParc = $('label[for="dsquapro"]', '#' + nomeForm);
        var rDebitar = $('label[for="flgpagto"]', '#' + nomeForm);
        var rLiberar = $('label[for="qtdialib"]', '#' + nomeForm);
        var rDtLiberar = $('label[for="dtlibera"]', '#' + nomeForm);
        var rDtPgmento = $('label[for="dtdpagto"]', '#' + nomeForm);
        var rDtUltPag = $('label[for="dtultpag"]', '#' + nomeForm);
        var rDtLiquidacao = $('label[for="dtliquidacao"]', '#' + nomeForm);
        var rPercCET = $('label[for="percetop"]', '#' + nomeForm);
        var rProposta = $('label[for="flgimppr"]', '#' + nomeForm);
        var rNtPromis = $('label[for="flgimpnp"]', '#' + nomeForm);
        var rLiquidacoes = $('label[for="dsctrliq"]', '#' + nomeForm);
        var rVliofepr = $('label[for="vliofepr"]', '#' + nomeForm);
        var rVlrtarif = $('label[for="vlrtarif"]', '#' + nomeForm);
        var rVlrtotal = $('label[for="vlrtotal"]', '#' + nomeForm);
        var rIdcarenc = $('label[for="idcarenc"]', '#' + nomeForm);
        var rDtcarenc = $('label[for="dtcarenc"]', '#' + nomeForm);
		var rVlFinanc = $('label[for="vlfinanc"]', '#' + nomeForm);

        var cNivelRic = $('#nivrisco', '#' + nomeForm);
        var cRiscoCalc = $('#nivcalcu', '#' + nomeForm);
        var cVlEmpr = $('#vlemprst', '#' + nomeForm);
        var cLnCred = $('#cdlcremp', '#' + nomeForm);
        var cDsLnCred = $('#dslcremp', '#' + nomeForm);
        var cVlPrest = $('#vlpreemp', '#' + nomeForm);
        var cFinali = $('#cdfinemp', '#' + nomeForm);
        var cDsFinali = $('#dsfinemp', '#' + nomeForm);
        var cQtParc = $('#qtpreemp', '#' + nomeForm);
        var cQualiParc = $('#idquapro', '#' + nomeForm);
        var cDsQualiParc = $('#dsquapro', '#' + nomeForm);
        var cDebitar = $('#flgpagto', '#' + nomeForm);
        var cTipoEmpr = $('#tpemprst', '#' + nomeForm);
        var cVliofepr = $('#vliofepr', '#' + nomeForm);
        var cVlrtarif = $('#vlrtarif', '#' + nomeForm);
        var cVlrtotal = $('#vlrtotal', '#' + nomeForm);
        var cVlFinanc = $('#vlfinanc', '#' + nomeForm);

        var cLiberar = $('#qtdialib', '#' + nomeForm);
        var cDtlibera = $('#dtlibera', '#' + nomeForm);
        var cDtPgmento = $('#dtdpagto', '#' + nomeForm);
        var cDtUltPag = $('#dtultpag', '#' + nomeForm);
        var cDtliquidacao = $('#dtliquidacao', '#' + nomeForm);
        var cPercCET = $('#percetop', '#' + nomeForm);
        var cProposta = $('#flgimppr', '#' + nomeForm);
        var cNtPromis = $('#flgimpnp', '#' + nomeForm);
        var cLiquidacoes = $('#dsctrliq', '#' + nomeForm);
        var rImgCalen = $('#imgcalen', '#' + nomeForm);
        var cIdcarenc = $('#idcarenc', '#' + nomeForm);
        var cDtcarenc = $('#dtcarenc', '#' + nomeForm);

        cNivelRic.addClass('rotulo').css('width', '90px');
        cRiscoCalc.addClass('').css('width', '108px');
        cVlEmpr.addClass('rotulo moeda').css('width', '90px');
        cLnCred.addClass('rotulo').css('width', '35px').attr('maxlength', '3');
        cDsLnCred.css('width', '108px');
        cVlPrest.addClass('moeda').css('width', '90px');
        cFinali.addClass('rotulo').css('width', '35px');
        cDsFinali.css('width', '108px');
        cQtParc.addClass('rotulo').css('width', '50px').setMask('INTEGER', 'zz9', '', '');
        cQualiParc.addClass('rotulo').css('width', '35px');
        cDsQualiParc.addClass('').css('width', '108');
        cDebitar.addClass('rotulo').css('width', '90px');
        cPercCET.addClass('rotulo moeda').css('width', '50px');
        cTipoEmpr.addClass('rotulo').css('width', '90px');
        cLiberar.addClass('rotulo inteiro').css('width', '45px').attr('maxlength', '1');
        cDtlibera.css('width', '108px').setMask("DATE", "", "", "divRotina");
        cDtliquidacao.css('width', '108px').setMask("DATE", "", "", "divRotina");
        cDtPgmento.css('width', '108px').setMask("DATE", "", "", "divRotina");
        cDtUltPag.css('width', '108px');
        cProposta.addClass('rotulo').css('width', '108px');
        cNtPromis.addClass('').css('width', '108px');
        cLiquidacoes.addClass('rotulo alphanum').css('width', '320px');
        cIdcarenc.css('width', '108px');
        cDtcarenc.css('width', '108px');

        rRotulos.addClass('rotulo').css('width', '75px');

        rVliofepr.addClass('rotulo').css('width', '75px');
        cVliofepr.addClass('rotulo moeda').css('width', '90px');
        rVlrtarif.addClass('rotulo').css('width', '75px');
        cVlrtarif.addClass('rotulo moeda').css('width', '90px');
        rVlrtotal.addClass('rotulo').css('width', '75px');
        cVlrtotal.addClass('rotulo moeda').css('width', '90px');
        rVlFinanc.addClass('rotulo').css('width', '75px');
        cVlFinanc.addClass('rotulo moeda').css('width', '90px');

        rDtLiberar.css('width', '97px');
        rLiberar.css('width', '137px');
        rDtLiberar.css('width', '153px');
        rLiberar.css('width', '135px');
        rProposta.css('width', '321px');
        rImgCalen.css('margin-top', '-5px');

        rRiscoCalc.addClass('').css('width', '153px');
        rLnCred.addClass('').css('width', '95px');
        rFinali.addClass('').css('width', '95px');
        rQualiParc.addClass('').css('width', '95px');
        rPercCET.addClass('').css('width', '153px');
        rDtPgmento.addClass('').css('width', '159px');
        rDtUltPag.addClass('').css('width', '321px');
        rDtLiquidacao.addClass('rotulo').css('width', '265px');
        rNtPromis.addClass('rotulo-linha').css('width', '318px');
        rDiasUteis.addClass('rotulo-linha');
        rIdcarenc.addClass('rotulo').css('width', '75px');
        rDtcarenc.addClass('').css('width', '135px');

        cTodos.addClass('campo');
        cDescricao.addClass('descricao');
        cCodigo.addClass('codigo pesquisa').attr('maxlength', '3');
        cCodigo.unbind('blur').bind('blur', function() {
            controlaPesquisas();
        });

        if (in_array(operacao, ['TI', 'I_INICIO', 'A_VALOR', 'A_AVALISTA', 'A_NOVA_PROP', 'A_INICIO', 'TC', 'CF'])) {

            if (operacao == 'A_NOVA_PROP') {
                cQtParc.focus();
            }

            $('#tpemprst', '#frmNovaProp').unbind('change').bind('change', function() {

                // Reseta os campos Finalidade e Linha de Credito
                cLnCred.val(0);
                cDsLnCred.val('');
                cFinali.val(0);
                cDsFinali.val('');

                if ($('#tpemprst', '#frmNovaProp').val() == 1 || // Price Pre-Fixado
                    $('#tpemprst', '#frmNovaProp').val() == 2) { // Pos-Fixado
                    // no - Conta   yes - Folha
                    $('#flgpagto', '#frmNovaProp').val('no');

                } else {
                    // no - Conta   yes - Folha
                    $('#flgpagto', '#frmNovaProp').val(arrayProposta['flgpagto']);
                }

                //Ajusta o tamanho do campo "Imprime proposta" de acordo com o tipo de empréstimo
                var rProposta = $('label[for="flgimppr"]', '#frmNovaProp');
                rProposta.css('width', '321px');

                verificaQtDiaLib();
                exibeLinhaCarencia();
            });

            $('#idcarenc', '#frmNovaProp').unbind('change').bind('change', function() {
                calculaDataCarencia();
            });

            $('#dtdpagto', '#frmNovaProp').unbind('blur').bind('blur', function() {
                // Se for Pos Fixado
                if ($('#tpemprst', '#frmNovaProp').val() == 2) {
                    calculaDataCarencia();
        }
            });

        }

        if (operacao == 'A_VALOR' && arrayInfoParcelas['vlempres'] != 'undefined') {
            cVlEmpr.val(arrayProposta['vlemprst']);
        }

        if (operacao == 'TI' || operacao == 'I_INICIO') {
            cTodos.habilitaCampo();
            cNivelRic.desabilitaCampo();
            cRiscoCalc.desabilitaCampo();
            cQualiParc.desabilitaCampo();
            cLiquidacoes.attr('disabled', true);
            cVlPrest.desabilitaCampo();
            cDtlibera.desabilitaCampo();
            cDtUltPag.desabilitaCampo();
            cPercCET.desabilitaCampo();
            if (arrayProposta['tpemprst'] == '1') {
                $("#qtdialib").desabilitaCampo();
                $("#qtdialib").datepicker('disable');
            }

            if (cDebitar.val() == 'yes') {
                cDtPgmento.desabilitaCampo();
            }

            if (cDebitar.val() == 'yes') {
                cDtPgmento.val(dtdpagt2);
            }

            var aux_vlemprst = parseFloat(cVlEmpr.val().replace(/[.R$ ]*/g, '').replace(',', '.'));
            var aux_vlemprs1 = parseFloat(arrayCooperativa['vlemprst'].replace(/[.R$ ]*/g, '').replace(',', '.'));

            if (aux_vlemprst > aux_vlemprs1) {
                cProposta.val('yes');
            }

            cVlEmpr.unbind('change').bind('change', function() {

                if (parseFloat($(this).val().replace(/[.R$ ]*/g, '').replace(',', '.')) >
                        parseFloat(arrayCooperativa['vlemprst'].replace(/[.R$ ]*/g, '').replace(',', '.'))) {
                    cProposta.val('yes');
                }

            });

            cDebitar.unbind('change').bind('change', function() {

                if ($(this).val() == 'yes') {
                    cDtPgmento.desabilitaCampo();
                } else {
                    cDtPgmento.habilitaCampo();
                }

                if ($(this).val() == 'yes') {
                    cDtPgmento.val(dtdpagt2);
                }
            });

            cProposta.unbind('change').bind('change', function(e) {
                return false;
            });
            cTipoEmpr.focus();


            if (possuiPortabilidade == 'S') {
                $("#cdfinemp", "#frmNovaProp").desabilitaCampo();
                $("#tpemprst", "#frmNovaProp").desabilitaCampo();
            }


        } else if (in_array(operacao, ['CF', 'TC', 'TE', 'I_CONTRATO', 'I_FINALIZA', 'A_FINALIZA'])) {
            cTodos.desabilitaCampo();
            //botao voltar
            if (possuiPortabilidade == 'S') {
                $("#btVoltar", "#divBotoes").attr('onClick', "controlaOperacao('PORTAB_CRED_C');");
                $("#btVoltar", "#divBotoes").unbind('click').bind('click', function() {
                    controlaOperacao('PORTAB_CRED_C');
                });                
            }
            
        } else if (operacao == 'A_NOVA_PROP' || operacao == 'A_INICIO') {

            cTodos.habilitaCampo();
            cNivelRic.desabilitaCampo();
            cRiscoCalc.desabilitaCampo();
            cVlEmpr.desabilitaCampo();
            cVlPrest.desabilitaCampo();
            cQualiParc.desabilitaCampo();
            cLiquidacoes.attr('disabled', true);
            cDtlibera.desabilitaCampo();
            cDtUltPag.desabilitaCampo();
            cPercCET.desabilitaCampo();

            if (arrayProposta['tpemprst'] == '1') {
                $("#qtdialib").desabilitaCampo();
                $("#qtdialib").datepicker('disable');
            }

            if (arrayProposta['tpemprst'] == '0') {
                $("#idfiniof").desabilitaCampo();
                $("#idfiniof").val(0);
            }            

            if (cDebitar.val() == 'yes') {
                cDtPgmento.desabilitaCampo();
            }

            if (cDebitar.val() == 'yes') {
                cDtPgmento.val(dtdpagt2);
            }

            var aux_vlemprst = parseFloat(cVlEmpr.val().replace(/[.R$ ]*/g, '').replace(',', '.'));
            var aux_vlemprs1 = parseFloat(arrayCooperativa['vlemprst'].replace(/[.R$ ]*/g, '').replace(',', '.'));

            if (aux_vlemprst > aux_vlemprs1) {
                cProposta.val('yes');
            }

            cVlEmpr.unbind('change').bind('change', function() {

                if (parseFloat($(this).replace(/[.R$ ]*/g, '').replace(',', '.')) >
                        parseFloat(arrayCooperativa['vlemprst'].replace(/[.R$ ]*/g, '').replace(',', '.'))) {
                    cProposta.val('yes');
                }
            });

            cDebitar.unbind('change').bind('change', function() {

                if ($(this).val() == 'yes') {
                    cDtPgmento.desabilitaCampo();
                } else {
                    cDtPgmento.habilitaCampo();
                }

                if ($(this).val() == 'yes') {
                    cDtPgmento.val(dtdpagt2);
                }
            });

            cProposta.unbind('change').bind('change', function(e) {
                return false;
            });

        } else if (operacao == 'A_VALOR') {
            cTodos.desabilitaCampo();
            cVlEmpr.habilitaCampo();
        } else if (operacao == 'A_NUMERO') {
            cTodos.desabilitaCampo();
        }

        if (in_array(operacao, ['TI', 'TE', 'TC', 'TA', 'CF', 'A_NOVA_PROP', 'A_NUMERO', 'A_VALOR', 'A_AVALISTA', 'I_CONTRATO', 'A_FINALIZA', 'A_INICIO', 'I_INICIO'])) {
            tpemprst = arrayProposta['tpemprst'];
            cdtpempr = arrayProposta['cdtpempr'];
            dstpempr = arrayProposta['dstpempr'];
            cdtpempr = cdtpempr.split(",");
            dstpempr = dstpempr.split(",");
            for (x = 0; x < cdtpempr.length; x++)
            {
                if (tpemprst == cdtpempr[x]) {
                    cTipoEmpr.append("<option value='" + cdtpempr[x] + "' selected>" + dstpempr[x] + "</option>");
                } else {
                    cTipoEmpr.append("<option value='" + cdtpempr[x] + "'>" + dstpempr[x] + "</option>");
                }
            }
        }

        /* PORTABILIDADE - valida a existencia de um contrato de portabilidade */
        if (possuiPortabilidade == 'S') {
            //muda o tratamento dos botoes
            if (operacao == 'A_NOVA_PROP' || operacao == 'A_INICIO') {

                $("#btVoltar", "#divBotoes").attr('onClick', "controlaOperacao('PORTAB_CRED_A');");
                $("#btVoltar", "#divBotoes").unbind('click').bind('click', function() {
                    controlaOperacao('PORTAB_CRED_A');
                });
                
                //atribui o novo parametro para o evento click do botao
                $("#btSalvar", "#divBotoes").attr('onClick', "buscaLiquidacoes('PORTAB_A');");
                //fiz esta adaptacao tecnica para obrigar o IE a executar a nova funcao se o botao for clicado.
                $("#btSalvar", "#divBotoes").unbind('click').bind('click', function() {
                    buscaLiquidacoes('PORTAB_A');
                });
                
                //desabilita o campo tipo de emprestimo
                cTipoEmpr.attr('disabled', 'disabled');
                //carrega finalidade especifica de portabilidade
                carregaFinalidadePortabilidade();
            } else if (operacao == 'TC') {
                $("#btVoltar", "#divBotoes").attr('onClick', "controlaOperacao('PORTAB_CRED_C');");
                $("#btVoltar", "#divBotoes").unbind('click').bind('click', function() {
                    controlaOperacao('PORTAB_CRED_C');
                });
            } else if (operacao == 'TI' || operacao == 'I_INICIO') {
                //carrega o campo finalidade 
                if ($("#cdfinemp").val() == 0 && $("#dsfinemp").val() == '') {
                    carregaFinalidadePortabilidade();
                }
                cTipoEmpr.attr('disabled', 'disabled');
                
                $("#btVoltar", "#divBotoes").attr('onClick', "controlaOperacao('PORTAB_CRED_I');");                
                //seta acao do botao voltar
                $("#btVoltar", "#divBotoes").unbind('click').bind('click', function() {
                    controlaOperacao('PORTAB_CRED_I');
                });

                cadastroNovo = (operacao == 'TI') ? 'S' : 'N';
                
                //atribui o novo parametro para o evento click do botao
                $("#btSalvar", "#divBotoes").attr('onClick', "buscaLiquidacoes('PORTAB_I');");
                //fiz esta adaptacao tecnica para obrigar o IE a executar a nova funcao se o botao for clicado.
                $("#btSalvar", "#divBotoes").unbind('click').bind('click', function() {
                    buscaLiquidacoes('PORTAB_I');
                });

            }
        }

        //Controle de ordem de digitação
        cTipoEmpr.attr('tabindex', parseInt(cRiscoCalc.attr('tabindex')) + 1);
        cVlEmpr.attr('tabindex', parseInt(cTipoEmpr.attr('tabindex')) + 1);
        cQtParc.attr('tabindex', parseInt(cVlEmpr.attr('tabindex')) + 1);
        cFinali.attr('tabindex', parseInt(cQtParc.attr('tabindex')) + 1);
        cLnCred.attr('tabindex', parseInt(cFinali.attr('tabindex')) + 1);
        cPercCET.attr('tabindex', parseInt(cLnCred.attr('tabindex')) + 1);
        cLiberar.attr('tabindex', parseInt(cPercCET.attr('tabindex')) + 1);
        cDebitar.attr('tabindex', parseInt(cLiberar.attr('tabindex')) + 1);
        cDtPgmento.attr('tabindex', parseInt(cDebitar.attr('tabindex')) + 1);
        cProposta.attr('tabindex', parseInt(cDtPgmento.attr('tabindex')) + 1);
        cNtPromis.attr('tabindex', parseInt(cProposta.attr('tabindex')) + 1);
        cNtPromis.unbind('focusout').bind('focusout', function() {
            $('#btSalvar', '#divBotoes').focus();
            return false;
        });

        cProposta.unbind('keydown').bind('keydown', function(e) {
            if (e.keyCode == 13 || e.keyCode == 9) {
                showMsgAguardo('Aguarde, validando dados ...');
                setTimeout('validaDados("' + cdcooper + '")', 400);
            }
        });

        //campo data de liquidacao do contrato (PORTABILIDADE)
        cDtliquidacao.removeClass('campo');
        cDtliquidacao.addClass('campoTelaSemBorda').attr('disabled', 'disabled');

        cVlrtarif.desabilitaCampo();
        cVliofepr.desabilitaCampo();
        cVlrtotal.desabilitaCampo();
        cVlFinanc.desabilitaCampo();

    } else if (in_array(operacao, ['C_DADOS_PROP', 'A_DADOS_PROP', 'I_DADOS_PROP'])) {

        nomeForm = 'frmDadosProp';
        altura = '430px';
        largura = '462px';

        var cTodos = $('input', '#' + nomeForm + ' fieldset:eq(0)');
        var rendimento = false;

        var rSalario = $('label[for="vlsalari"]', '#' + nomeForm);
        var rDemais = $('label[for="vloutras"]', '#' + nomeForm);

        var cSalario = $('#vlsalari', '#' + nomeForm);
        var cDemais = $('#vloutras', '#' + nomeForm);

        rSalario.addClass('rotulo').css('width', '50');
        rDemais.addClass('').css('width', '187');
        cSalario.addClass('rotulo moeda_6').css('width', '90px');
        cDemais.addClass('moeda_6').css('width', '100px');

        // FIELDSET OUTROS RENDIMENTOS
        var rCodigos = $('label[for="tpdrend1"],label[for="tpdrend2"],label[for="tpdrend3"],label[for="tpdrend4"],label[for="tpdrend5"],label[for="tpdrend6"]', '#' + nomeForm);
        var rValores = $('label[for="vldrend1"],label[for="vldrend2"],label[for="vldrend3"],label[for="vldrend4"],label[for="vldrend5"],label[for="vldrend6"]', '#' + nomeForm);
        var rJustif = $('label[for="dsjusren"', '#' + nomeForm);

        rCodigos.addClass('rotulo').css('width', '50px');
        rValores.addClass('rotulo-linha');
        rJustif.addClass('rotulo').css('width', '70px');

        var cTodos_1 = $('input', '#' + nomeForm + ' fieldset:eq(1)');
        var cCodigos_1 = $('#tpdrend1,#tpdrend2,#tpdrend3,#tpdrend4,#tpdrend5,#tpdrend6', '#' + nomeForm);
        var cDesc_1 = $('#dsdrend1,#dsdrend2,#dsdrend3,#dsdrend4,#dsdrend5,#dsdrend6', '#' + nomeForm);
        var cValores_1 = $('#vldrend1,#vldrend2,#vldrend3,#vldrend4,#vldrend5,#vldrend6', '#' + nomeForm);
        var cJustif = $('#dsjusren', '#' + nomeForm);

        cCodigos_1.addClass('codigo pesquisa');
        cDesc_1.addClass('descricao').css('width', '187px');
        cValores_1.addClass('moeda').css('width', '100px');
        cJustif.addClass('alphanum').css('width', '325px').css('overflow-y', 'scroll').css('overflow-x', 'hidden').css('height', '60').css('margin-left', '36').setMask('STRING', '160', charPermitido(), '');

        var cTodos_2 = $('input', '#' + nomeForm + ' fieldset:eq(2)');
        var rRotulo_2 = $('label[for="vlsalcon"],label[for="flgdocje"]', '#' + nomeForm);
        var rLocalTrab = $('label[for="nmextemp"]', '#' + nomeForm);
        var rVlAlug = $('label[for="vlalugue"]', '#' + nomeForm);

        var cSalConj = $('#vlsalcon', '#' + nomeForm);
        var cLocalTrab = $('#nmextemp', '#' + nomeForm);
        var cCoresp = $('input[name="flgdocje"]', '#' + nomeForm);
        var cInconcje = $('input[name="inconcje"]', '#' + nomeForm);
        var cVlAlug = $('#vlalugue', '#' + nomeForm);

        rRotulo_2.addClass('rotulo').css('width', '100px');
        rLocalTrab.addClass('').css('width', '116px');
        rVlAlug.addClass('').css('width', '116px');
        cSalConj.addClass('rotulo moeda').css('width', '90px');
        cLocalTrab.addClass('alphanum').css('width', '121px').attr('maxlength', '20');
        cVlAlug.addClass('moeda_6').css('width', '121px');
        cCoresp.css('width', '22px');
        cInconcje.css('width', '22px');


        if (operacao == 'C_DADOS_PROP') {
            cTodos.desabilitaCampo();
            cTodos_1.desabilitaCampo();
            cTodos_2.desabilitaCampo();
            cJustif.desabilitaCampo();

            if (arrayProposta['insitest'] != 3) {
                carregaDadosPropostaLinhaCredito();
            }

        } else if (operacao == 'A_DADOS_PROP') {
            cTodos.habilitaCampo();
            cTodos_1.habilitaCampo();
            cTodos_2.habilitaCampo();
            cJustif.desabilitaCampo();

            for (var i = 1; i <= contRend; i++) {
                if (arrayRendimento['tpdrend' + i] == 6) {
                    cJustif.habilitaCampo();
                }

            }


        } else if (operacao == 'I_DADOS_PROP') {
            cTodos.habilitaCampo();
            cTodos_1.habilitaCampo();
            cTodos_2.habilitaCampo();
            cJustif.desabilitaCampo();

            for (var i = 1; i <= contRend; i++) {
                if (arrayRendimento['tpdrend' + i] == 6) {
                    cJustif.habilitaCampo();
                }

            }

        }

        //Manter campo bloqueado, dado deve ser apenas alterado na tela Contas
        cLocalTrab.desabilitaCampo();

        //Se não tem conjuge, desabilita campos 'Conjugê - Salário', 'Local Trabalho' e 'Co-responsável' e 'Consultar Conjuge'
        if (arrayRendimento['flgconju'] == 'no') {
            cSalConj.desabilitaCampo();
            cLocalTrab.desabilitaCampo();
            cCoresp.desabilitaCampo();
        }

        // Se o conjuge nao tem CPF cadastrado, desabilitar as consultas
        if (arrayRendimento['nrcpfcjg'] == 0 && arrayRendimento['nrctacje'] == 0) {
            cInconcje.desabilitaCampo();
        }

    } else if (in_array(operacao, ['E_COMITE_APROV', 'C_COMITE_APROV', 'I_COMITE_APROV', 'A_COMITE_APROV'])) {

        nomeForm = 'frmComiteAprov';
        if (operacao == 'A_COMITE_APROV' || operacao == 'I_COMITE_APROV') {
            altura = '150px';
        } else {
            altura = '252px';
        }
        largura = '442px';

        var cComite = $('#dsobscmt', '#' + nomeForm);
        var cObs = $('#dsobserv', '#' + nomeForm);

        cObs.unbind('keypress').bind('keypress', function(e) {

            if ($(this).val().length >= 660) {
                return false;
            }

        });


        cComite.addClass('alphanum').css({'width': '420px', 'height': '80px', 'float': 'left', 'margin': '3px 0px 3px 3px', 'padding-right': '1px'});
        cObs.addClass('alphanum').css({'width': '420px', 'height': '80px', 'float': 'left', 'margin': '3px 0px 3px 3px', 'padding-right': '1px'});

        if (operacao == 'C_COMITE_APROV' || operacao == 'E_COMITE_APROV') {
            cComite.desabilitaCampo();
            cObs.desabilitaCampo();
        } else if (operacao == 'A_COMITE_APROV' || operacao == 'I_COMITE_APROV') {
            cObs.habilitaCampo();
            $('fieldset:eq(0)', '#' + nomeForm).css('display', 'none');
            cComite.css('display', 'none');
        }

    } else if (in_array(operacao, ['C_DADOS_AVAL', 'A_DADOS_AVAL', 'I_DADOS_AVAL', 'AI_DADOS_AVAL', 'IA_DADOS_AVAL'])) {

        nomeForm = 'frmDadosAval';
        altura = '420px'; // Zimmermann 392
        largura = '508px';

        var cTodos = $('select,input', '#' + nomeForm + ' fieldset:eq(0)');
        //odirlei PRJ339
        var rRotulo = $('label[for="qtpromis"],label[for="nrcpfcgc"],label[for="tpdocava"]', '#' + nomeForm);

        var rConta = $('label[for="nrctaava"]', '#' + nomeForm);
        //odirlei PRJ339
        var rNmdavali = $('label[for="nmdavali"]', '#' + nomeForm);
        var rInpessoa = $('label[for="inpessoa"]', '#' + nomeForm);
        var rNacio = $('label[for="cdnacion"]', '#' + nomeForm);
        var rDtnascto = $('label[for="dtnascto"]', '#' + nomeForm);

        var cQntd = $('#qtpromis', '#' + nomeForm);
        var cConta = $('#nrctaava', '#' + nomeForm);
        var cCPF = $('#nrcpfcgc', '#' + nomeForm);
        var cNome = $('#nmdavali', '#' + nomeForm);
        var cDoc = $('#tpdocava', '#' + nomeForm);
        var cNrDoc = $('#nrdocava', '#' + nomeForm);
        var cInpessoa = $('#inpessoa', '#' + nomeForm);
        var cNacio = $('#cdnacion', '#' + nomeForm);
        var cDsnacio = $('#dsnacion', '#' + nomeForm);
        var cDtnascto = $('#dtnascto', '#' + nomeForm);

        rRotulo.addClass('rotulo').css('width', '40px');
        //odirlei PRJ339
        rConta.css('width', '70px');
        rInpessoa.css('width', '70px');
        rNmdavali.css('width', '45px');
        rNacio.addClass('rotulo').css('width', '40px');
        rDtnascto.css('width', '72px');

        cQntd.css('width', '60px').setMask('INTEGER', 'zz9', '', '');
        cConta.addClass('conta pesquisa').css('width', '115px');
        cCPF.css('width', '134px');
        cNome.addClass('alphanum').css('width', '255px').attr('maxlength', '40');
        cDoc.css('width', '50px');
        cNrDoc.addClass('alphanum').css('width', '202px').attr('maxlength', '40');        
        cInpessoa.css({'width': '99px'});
        cNacio.addClass('codigo pesquisa').css('width', '50px');
        cDsnacio.css('width', '155px');
        cDtnascto.addClass('data').css({'width': '100px'});

        cConta.unbind('change').bind('change', function() {

            nrctaava = normalizaNumero($(this).val());

            if (nrctaava != 0) {
                // Verifica se a conta é válida
                if (!validaNroConta(nrctaava)) {
                    showError('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Anota', 'focaCampoErro(\'nrctaava\',\'frmDadosAval\');bloqueiaFundo(divRotina);');
                    return false;
                } else {
                    Busca_Associado(nrctaava, 0, contAvalistas - 1);
                }
            }
        });

        // Se pressionar alguma tecla no campo numero da conta, verificar a tecla pressionada e toda a devida ação (keydown)
        cConta.unbind('keydown').bind('keydown', function(e) {

            if (divError.css('display') == 'block') {
                return false;
            }

            // Se é a tecla TAB, verificar numero conta e realizar as devidas operações
            if (e.keyCode == 9) {

                // Armazena o número da conta na variável global
                nrctaava = normalizaNumero($(this).val());
                nrctaavaOld = nrctaava;

                if (nrctaava != 0) {
                    // Verifica se a conta é válida
                    if (!validaNroConta(nrctaava)) {
                        showError('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Anota', 'focaCampoErro(\'nrctaava\',\'frmDadosAval\');bloqueiaFundo(divRotina);');
                        return false;
                    } else {
                        Busca_Associado(nrctaava, 0, contAvalistas - 1);
                    }
                } else {
                    //	$('#'+nomeForm).limpaFormulario();
                    // odirlei prj339
                    /*cTodos.habilitaCampo();
                    cTodos_1.habilitaCampo();
                    cTodos_2.habilitaCampo();
                    cTodos_3.habilitaCampo();
                    cTodos_4.habilitaCampo();
                    cConta.desabilitaCampo().val(nrctaava);
                    cQntd.desabilitaCampo().val(arrayProposta['qtpromis']);

                    $('#dsendre1,#cdufresd,#dsendre2,#nmcidade,#dsnacion', '#' + nomeForm).desabilitaCampo();
                    controlaPesquisas();
                    cNome.focus();*/
                    cInpessoa.habilitaCampo();
                    cInpessoa.focus();
                    
                }

                return false;
            }
        });

        // Odirlei PRJ339
        // Se pressionar alguma tecla no campo numero da conta, verificar a tecla pressionada e toda a devida ação
        cInpessoa.unbind('keydown').bind('keydown', function(e) { // Zimmermann

            if (divError.css('display') == 'block') {
                return false;
            }

            // Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
            if (e.keyCode == 9) {
                
                pessoa = normalizaNumero(cInpessoa.val());
                if (pessoa == "" ) {
                    showError('error', 'Selecione o tipo de pessoa', 'Aten;&atilde;o', '$("#inpessoa","#frmDadosAval").focus();bloqueiaFundo(divRotina);');
                    return false;
                }else {
                
                    cCPF.habilitaCampo();
                    cCPF.focus();
                }

                return false;
            }
        });
        
        // Odirlei PRJ339
        // Se pressionar alguma tecla no campo numero da conta, verificar a tecla pressionada e toda a devida ação (keydown)
        cCPF.unbind('change').bind('change', function (e) {

            if (divError.css('display') == 'block') {
                return false;
            }

                // Armazena o número da conta na variável global
                nrcpfcgc = normalizaNumero(cCPF.val());
                nrcpfcgcOld = nrcpfcgc;

                pessoa = normalizaNumero(cInpessoa.val());

                if (nrcpfcgc != 0) {

                    // Valida o CPF
                    if (!validaCpfCnpj(nrcpfcgc, pessoa)) {
                        showError('error', 'CPF/CNPJ inv&aacute;lido.', 'Valida&ccedil;&atilde;o CPF', '$("#inpessoa","#frmDadosAval").focus();bloqueiaFundo(divRotina);');
                        return false;
                    } else {

                        Busca_Associado(0, nrcpfcgc, contAvalistas - 1);

                    // Se nao for acessado via CRM, pode habilitar os campos
                    if ($('#crm_inacesso', '#' + nomeForm).val() != 1 ) {
                        cTodos.habilitaCampo();
                        cTodos_1.habilitaCampo();
                        cTodos_2.habilitaCampo();
                        cTodos_3.habilitaCampo();
                        cTodos_4.habilitaCampo();
                        cConta.desabilitaCampo().val(nrctaava);
                        cQntd.desabilitaCampo().val(arrayProposta['qtpromis']);

                        $('#dsendre1,#cdufresd,#dsendre2,#nmcidade,#dsnacion', '#' + nomeForm).desabilitaCampo();
                        controlaPesquisas();
                        cNome.focus();
                        
                    }


                    }

                    // Caso em que o cpf é zero
                } else {

                }

                return false;
        
        });

        

        var cTodos_1 = $('select,input', '#' + nomeForm + ' fieldset:eq(1)');

        var rRotulo_1 = $('label[for="nmconjug"],label[for="tpdoccjg"]', '#' + nomeForm);
        var rCpf_1 = $('label[for="nrcpfcjg"]', '#' + nomeForm);

        var cConj = $('#nmconjug', '#' + nomeForm);
        var cCPF_1 = $('#nrcpfcjg', '#' + nomeForm);
        var cDoc_1 = $('#tpdoccjg', '#' + nomeForm);
        var cNrDoc_1 = $('#nrdoccjg', '#' + nomeForm);

        rRotulo_1.addClass('rotulo').css('width', '50px');
        rCpf_1.addClass('').css('width', '40px');

        cConj.addClass('alphanum').css('width', '250px').attr('maxlength', '40');
        cCPF_1.addClass('cpf').css('width', '134px');
        cDoc_1.css('width', '50px');
        cNrDoc_1.addClass('alphanum').css('width', '197px').attr('maxlength', '40');

        var cTodos_2 = $('select,input', '#' + nomeForm + ' fieldset:eq(2)');

        // RÓTULOS - ENDEREÇO
        var rCep = $('label[for="nrcepend"]', '#' + nomeForm);
        var rEnd = $('label[for="dsendre1"]', '#' + nomeForm);
        var rBai = $('label[for="dsendre2"]', '#' + nomeForm);
        var rEst = $('label[for="cdufresd"]', '#' + nomeForm);
        var rCid = $('label[for="nmcidade"]', '#' + nomeForm);
        //Campos projeto CEP
        var rNum = $('label[for="nrendere"]', '#' + nomeForm);
        var rCom = $('label[for="complend"]', '#' + nomeForm);
        var rCax = $('label[for="nrcxapst"]', '#' + nomeForm);

        rCep.addClass('rotulo').css('width', '55px');
        rEnd.addClass('rotulo-linha').css('width', '35px');
        rNum.addClass('rotulo').css('width', '55px');
        rCom.addClass('rotulo-linha').css('width', '52px');
        rCax.addClass('rotulo').css('width', '55px');
        rBai.addClass('rotulo-linha').css('width', '52px');
        rEst.addClass('rotulo').css('width', '55px');
        rCid.addClass('rotulo-linha').css('width', '52px');

        // CAMPOS - ENDEREÇO
        var cCep = $('#nrcepend', '#' + nomeForm);
        var cEnd = $('#dsendre1', '#' + nomeForm);
        var cBai = $('#dsendre2', '#' + nomeForm);
        var cEst = $('#cdufresd', '#' + nomeForm);
        var cCid = $('#nmcidade', '#' + nomeForm);
        //Campos projeto CEP
        var cNum = $('#nrendere', '#' + nomeForm);
        var cCom = $('#complend', '#' + nomeForm);
        var cCax = $('#nrcxapst', '#' + nomeForm);

        cCep.addClass('cep pesquisa').css('width', '65px').attr('maxlength', '9');
        cEnd.addClass('alphanum').css('width', '300px').attr('maxlength', '40');
        cNum.addClass('numerocasa').css('width', '65px').attr('maxlength', '7');
        cCom.addClass('alphanum').css('width', '300px').attr('maxlength', '40');
        cCax.addClass('caixapostal').css('width', '65px').attr('maxlength', '6');
        cBai.addClass('alphanum').css('width', '300px').attr('maxlength', '40');
        cEst.css('width', '65px');
        cCid.addClass('alphanum').css('width', '300px').attr('maxlength', '25');

        //Controle contato
        var cTodos_3 = $('select,input', '#' + nomeForm + ' fieldset:eq(3)');

        var rFone = $('label[for="nrfonres"]', '#' + nomeForm);
        var rEmail = $('label[for="dsdemail"]', '#' + nomeForm);

        rFone.addClass('rotulo-linha');
        rEmail.addClass('rotulo').css('width', '55px');

        var cFone = $('#nrfonres', '#' + nomeForm);
        var cEmail = $('#dsdemail', '#' + nomeForm);

        cFone.addClass('alphanum').css('width', '150px').attr('maxlength', '19');
        cEmail.addClass('alphanum').css('width', '237px').attr('maxlength', '30');

        var cTodos_4 = $('select,input', '#' + nomeForm + ' fieldset:eq(4)');

        var rEndiv = $('label[for="vledvmto"]', '#' + nomeForm);
        var rRenda = $('label[for="vlrenmes"]', '#' + nomeForm);

        rRenda.css('width', '110px');
        rEndiv.addClass('rotulo').css('width', '105px');

        var cEndiv = $('#vledvmto', '#' + nomeForm);
        var cRenda = $('#vlrenmes', '#' + nomeForm);

        cEndiv.addClass('moeda').css('width', '130px');
        cRenda.addClass('moeda').css('width', '130px');

        if (operacao == 'C_DADOS_AVAL') {
            cTodos.desabilitaCampo();
            cTodos_1.desabilitaCampo();
            cTodos_2.desabilitaCampo();
            cTodos_3.desabilitaCampo();
            cTodos_4.desabilitaCampo();
        } else if (operacao == 'A_DADOS_AVAL' || operacao == 'IA_DADOS_AVAL') {

            //Formatação inicial dos Avalistas
            iniciaAval();

            //Projeto CEP
            $('#dsendre1,#cdufresd,#dsendre2,#nmcidade', '#' + nomeForm).desabilitaCampo();

        } else if (operacao == 'AI_DADOS_AVAL' || operacao == 'I_DADOS_AVAL') {

            // $('#'+nomeForm).limpaFormulario();

            //Formatação inicial dos Avalistas
            iniciaAval();

            i = arrayAvalistas.length + 1;

            $('#qtpromis', '#frmDadosAval').desabilitaCampo();

            $('legend:first', '#frmDadosAval').html('Dados dos Avalistas/Fiadores ' + i);

            //Projeto CEP
            $('#dsendre1,#cdufresd,#dsendre2,#nmcidade', '#' + nomeForm).desabilitaCampo();

        }
    } else if (in_array(operacao, ['A_PROTECAO_AVAL', 'A_PROTECAO_TIT', 'A_PROTECAO_CONJ', 'C_PROTECAO_TIT',
        'C_PROTECAO_AVAL', 'C_PROTECAO_CONJ', 'C_PROTECAO_SOC', 'A_PROTECAO_SOC',
        'I_PROTECAO_TIT'])) {

        altura = '430px';
        largura = '510px';

        // Caso for Cessao de Credito sera fixado o valor
        if (aDadosPropostaFinalidade['flgcescr']) {
            formata_protecao(operacao, aDadosPropostaFinalidade['nrinfcad'], aDadosPropostaFinalidade['dsinfcad']);
        } else {
            formata_protecao(operacao, arrayProtCred['nrinfcad'], arrayProtCred['dsinfcad']);
        }

        // Cessao de credito nao podera alterar o campo
        if ((aDadosPropostaFinalidade['flgcescr']) || (arrayProposta['flgcescr']) || inobriga == 'S') {
            $('#nrinfcad', '#frmOrgaos').desabilitaCampo();
        }

    }
    else if (in_array(operacao, ['I_MICRO_PERG', 'A_MICRO_PERG', 'C_MICRO_PERG'])) {

        nomeForm = 'frmQuestionario';
        altura = '470px';
        largura = '500px';

        var rTodos = $('label', '#' + nomeForm);
        var cTodos = $("select,input", '#' + nomeForm);
        var cDescricao = $('input[name="descricao"]', '#' + nomeForm);
        var cInteiros = $('input[name="inteiro"]', "#" + nomeForm);

        rTodos.addClass('rotulo-linha').css('width', '55%');
        cTodos.addClass('campo').css({'width': '40%', 'margin-left': '10px'});
        cDescricao.addClass('alphanum');
        cDescricao.attr('maxlength', '50');
        cInteiros.addClass('campo inteiro').css({'text-align': 'right'}).setMask('INTEGER', 'zzz.zz9', '.', '');

        if (cddopcao == 'C') {
            cTodos.desabilitaCampo();
        } else {



            // Se mudou alguma resposta, verificar se tem que habilitar/desabilitar alguma pergunta
            cTodos.unbind("change").bind("change", function(e) {

                // Sequencia de pergunta e resposta da pergunta que foi modificada
                var nrseqper = $(this).attr('id');
                var nrseqres = $(this).val();

                // Percorrer todas as perguntas
                cTodos.each(function(j) {

                    var dsregexi = $(this).attr('dsregexi');

                    // Se tem regra definida para este elemento
                    if (typeof (dsregexi) != 'undefined' && dsregexi != '') {

                        var nrseqper_ant = dsregexi.substr(8, dsregexi.indexOf('=') - 8);
                        var nrseqres_ant = dsregexi.substr(dsregexi.indexOf('resposta') + 8);
                        var nrseqper_atu = $(this).attr('id');

                        // Se tem regra para o elemento que foi modificado						
                        if (nrseqper == nrseqper_ant) {
                            if (nrseqres == nrseqres_ant) {
                                $("#" + nrseqper_atu, "#frmQuestionario").habilitaCampo();
                            }
                            else {
                                $("#" + nrseqper_atu, "#frmQuestionario").val("");
                                $("#" + nrseqper_atu, "#frmQuestionario").desabilitaCampo();
                            }
                            $("#" + nrseqper_atu, "#frmQuestionario").trigger('change');
                        }
                    }
                });
            });

            // Percorrer todas as perguntas para habilitar/desabilitar
            cTodos.each(function(e) {
                $(this).trigger('change');
            });
        }
    }
    else if (in_array(operacao, ['C_HIPOTECA', 'AI_HIPOTECA', 'A_HIPOTECA', 'I_HIPOTECA', 'IA_HIPOTECA'])) {

        nomeForm = 'frmHipoteca';
        altura = '160px';
        largura = '452px';

        var cTodos = $('select,input', '#' + nomeForm);
        var rRotulo = $('label[for="dscatbem"],label[for="dsbemfin"],label[for="dscorbem"]', '#' + nomeForm);
        var rVlMerc = $('label[for="vlmerbem"]', '#' + nomeForm);
        var rTitulo = $('#lsbemfin', '#' + nomeForm);

        var cCateg = $('#dscatbem', '#' + nomeForm);
        var cVlMerc = $('#vlmerbem', '#' + nomeForm);
        var cDesc = $('#dsbemfin', '#' + nomeForm);
        var cEnd = $('#dscorbem', '#' + nomeForm);

        rRotulo.addClass('rotulo').css('width', '60px');
        rTitulo.addClass('').css({'width': '253px', 'clear': 'both'});
        rVlMerc.addClass('rotulo-linha');

        cCateg.css('width', '132px');
        cVlMerc.addClass('moeda').css('width', '132px');
        cDesc.addClass('alphanum').css('width', '370px').attr('maxlength', '50');
        cEnd.addClass('alphanum').css('width', '370px').attr('maxlength', '50');

        // Para chamar o evento de onChange - Ocorria que qndo voltava o campo nao era ajustada a mascara.
        cCateg.trigger("change");

        if (operacao == 'C_HIPOTECA') {
            cTodos.desabilitaCampo();
        } else if (operacao == 'A_HIPOTECA' || operacao == 'IA_HIPOTECA') {
            cTodos.habilitaCampo();
            if (contHipotecas == 1) {
                $('#btDeletar', '#divBotoes').css('display', 'none');
            }
        } else if (operacao == 'AI_HIPOTECA' || operacao == 'I_HIPOTECA') {
            cTodos.habilitaCampo();
            strSelect(lscathip, 'dscatbem', 'frmHipoteca');
            $('#' + nomeForm).limpaFormulario();
            rTitulo.html('( ' + (contHipotecas + 1) + '° Imovel )');
        }

    } else if (in_array(operacao, ['C_PROT_CRED', 'A_PROT_CRED', 'I_PROT_CRED'])) {

        nomeForm = 'frmOrgProtCred';
        altura = '220px';
        largura = '495px';
        
        // Exibe o Fieldset de GARANTIAS
        $('#' + nomeForm + ' fieldset:eq(1)').show();

        var rRotulo = $('label[for="dtcnsspc"],label[for="dtoutspc"]', '#' + nomeForm);
        var rInfCad = $('label[for="nrinfcad"]', '#' + nomeForm);
        var r2Tit = $('label[for="dtoutspc"]', '#' + nomeForm);

        var c1Tit = $('#dtcnsspc', '#' + nomeForm);
        var cInfCad = $('#nrinfcad', '#' + nomeForm);
        var cDsInfCad = $('#dsinfcad', '#' + nomeForm);
        var cCodigo = $('#nrinfcad, #nrgarope, #nrliquid, #nrpatlvr, #nrperger', '#' + nomeForm);

        var c2Tit = $('#dtoutspc', '#' + nomeForm);

        rRotulo.addClass('rotulo').css('width', '133px');
        rInfCad.addClass('rotulo-linha');

        c1Tit.css('width', '75px').setMask("DATE", "", "", "divRotina");
        cInfCad.addClass('codigo').css('width', '32px');
        cDsInfCad.addClass('descricao').css('width', '125px');
        c2Tit.css('width', '75px').setMask("DATE", "", "", "divRotina");
        cCodigo.addClass('pesquisa');

        var cTodos_1 = $('input', '#' + nomeForm + ' fieldset:eq(0)');
        var rRotulo_1 = $('label[for="dtdrisco"],label[for="vltotsfn"],label[for="dtoutris"]', '#' + nomeForm);

        var rQtIF = $('label[for="qtifoper"]', '#' + nomeForm);
        var rQtOpe = $('label[for="qtopescr"]', '#' + nomeForm);
        var rVencidas = $('label[for="vlopescr"]', '#' + nomeForm);
        var rPrej = $('label[for="vlrpreju"]', '#' + nomeForm);
        var rEndiv = $('label[for="vlsfnout"]', '#' + nomeForm);
        var r2Tit_1 = $('label[for="dtoutris"]', '#' + nomeForm);

        var c1Tit_1 = $('#dtdrisco', '#' + nomeForm);
        var cQtIF = $('#qtifoper', '#' + nomeForm);
        var cQtOpe = $('#qtopescr', '#' + nomeForm);
        var cEndiv = $('#vltotsfn', '#' + nomeForm);
        var cVenc = $('#vlopescr', '#' + nomeForm);
        var cPrej = $('#vlrpreju', '#' + nomeForm);
        var c2Tit_1 = $('#dtoutris', '#' + nomeForm);
        var c2TitEndv = $('#vlsfnout', '#' + nomeForm);

        rRotulo_1.addClass('rotulo').css('width', '110px');
        rQtIF.css('width', '112px');
        rQtOpe.addClass('rotulo-linha');
        rVencidas.addClass('rotulo-linha');
        rPrej.addClass('rotulo-linha');
        rEndiv.css('width', '176px');

        c1Tit_1.css('width', '85px').setMask("DATE", "", "", "divRotina");
        cQtIF.addClass('inteiro').css('width', '30px').attr('maxlength', '2');
        cQtOpe.addClass('').css('width', '30px').setMask('INTEGER', 'zzz.zz9', '.', '');
        cEndiv.addClass('moeda').css('width', '85px');
        cVenc.addClass('moeda_6').css('width', '85px');
        cPrej.addClass('moeda_6').css('width', '90px');
        c2Tit_1.css('width', '85px').setMask("DATE", "", "", "divRotina");
        c2TitEndv.addClass('moeda_6').css('width', '90px');
		
        var cTodos_2 = $('input', '#' + nomeForm + ' fieldset:eq(1)');
        var rRotulo_2 = $('label[for="nrgarope"],label[for="nrpatlvr"],label[for="nrperger"]', '#' + nomeForm);

        var rGarantia = $('label[for="nrgarope"]', '#' + nomeForm);
        var rLiquidez = $('label[for="nrliquid"]', '#' + nomeForm);
        var rPatriLv = $('label[for="nrpatlvr"]', '#' + nomeForm);
        var rPercep = $('label[for="nrperger"]', '#' + nomeForm);

        var cCodigo = $('#nrgarope,#nrliquid,#nrpatlvr,#nrperger', '#' + nomeForm);

        var cGarantia = $('#dsgarope', '#' + nomeForm);
        var cLiquidez = $('#dsliquid', '#' + nomeForm);
        var cPatriLv = $('#dspatlvr', '#' + nomeForm);
        var cPercep = $('#nrperger', '#' + nomeForm);
        var cDsPercep = $('#dsperger', '#' + nomeForm);
        var lupa = $('#lupanrperger', '#' + nomeForm);

        rRotulo_2.addClass('rotulo');
        rLiquidez.addClass('rotulo-linha');
        rPatriLv.css('width', '106px');
        rPercep.addClass('rotulo-linha');
        rGarantia.addClass('rotulo-linha');

        cCodigo.addClass('codigo').css('width', '35px');
        cGarantia.addClass('descricao').css('width', '123px');
        cLiquidez.addClass('descricao').css('width', '123px');
        cPatriLv.addClass('descricao').css('width', '302px');
        cDsPercep.addClass('descricao').css('width', '181px');

        if (operacao == 'C_PROT_CRED') {
            cTodos_1.desabilitaCampo();
            cTodos_2.desabilitaCampo();

            if (inobriga == 'S' && arrayProposta['insitest'] < 2) {
                $('#' + nomeForm + ' fieldset:eq(1)').hide();
                altura = '135px';
            }

        } else if (operacao == 'A_PROT_CRED' || operacao == 'I_PROT_CRED') {
            cTodos_1.desabilitaCampo();
            cTodos_2.habilitaCampo();

			if (inobriga == 'S'){
                $('#' + nomeForm + ' fieldset:eq(1)').hide();
                altura = '135px';
			}
			
            if (arrayProtCred['flgcentr'] == 'no') {

                c1Tit_1.habilitaCampo();
                cQtIF.habilitaCampo();
                cQtOpe.habilitaCampo();
                cEndiv.habilitaCampo();
                cVenc.habilitaCampo();
                cPrej.habilitaCampo();
            }

            /* Cessao de Credito */
            if ((aDadosPropostaFinalidade['flgcescr']) || (arrayProposta['flgcescr'])) {
                $('#nrinfcad, #nrgarope, #nrliquid, #nrpatlvr, #nrperger', '#' + nomeForm).desabilitaCampo();
            }
        }

        if (inpessoa == 1) {
            r2Tit.css('display', 'block');
            c2Tit.css('display', 'block');

            r2Tit_1.css('display', 'block');
            c2Tit_1.css('display', 'block');

            rEndiv.css('display', 'block');
            c2TitEndv.css('display', 'block');

            rPercep.css('display', 'none');
            cPercep.css('display', 'none');
            lupa.css('display', 'none');
            cDsPercep.css('display', 'none');
        } else {
            r2Tit.css('display', 'none');
            c2Tit.css('display', 'none');

            r2Tit_1.css('display', 'none');
            c2Tit_1.css('display', 'none');

            rEndiv.css('display', 'none');
            c2TitEndv.css('display', 'none');

            rPercep.css('display', 'block');
            cPercep.css('display', 'block');
            lupa.css('display', 'block');
            cDsPercep.css('display', 'block');
        }


    } else if (in_array(operacao, ['C_DADOS_PROP_PJ', 'A_DADOS_PROP_PJ', 'I_DADOS_PROP_PJ'])) {

        nomeForm = 'frmDadosPropPj';
        altura = '135';
        largura = '460px';

        var cTodos = $('input', '#' + nomeForm);
        var rRotulo = $('label[for="vlmedfat"],label[for="perfatcl"],label[for="vlalugue"]', '#' + nomeForm);
        var rMedia = $('#vlmedfat2', '#' + nomeForm);

        var cCampos = $('#vlmedfat,#perfatcl,#vlalugue', '#' + nomeForm);
        var cMedia = $('#vlmedfat', '#' + nomeForm);
        var cPecent = $('#perfatcl', '#' + nomeForm);
        var cAluguel = $('#vlalugue', '#' + nomeForm);

        rRotulo.addClass('rotulo').css('width', '240px');
        rMedia.addClass('rotulo-linha');
        cCampos.css('width', '85px');
        cMedia.addClass('moeda');
        cPecent.addClass('porcento');
        cAluguel.addClass('moeda_6');

        if (operacao == 'C_DADOS_PROP_PJ') {
            cTodos.desabilitaCampo();
        } else if (operacao == 'A_DADOS_PROP_PJ' || operacao == 'I_DADOS_PROP_PJ') {
            cTodos.habilitaCampo();
            cMedia.desabilitaCampo();
        }

    } else if (in_array(operacao, ['C_ALIENACAO', 'AI_ALIENACAO', 'A_ALIENACAO', 'I_ALIENACAO', 'IA_ALIENACAO'])) {

        nomeForm = 'frmAlienacao';
        altura = '215px';
        largura = '462px';

        var cTodos = $('select,input', '#' + nomeForm);
        var rRotulo = $('label[for="dscatbem"],label[for="dsbemfin"],label[for="dscorbem"],label[for="ufdplaca"],label[for="nrrenava"],label[for="nrmodbem"]', '#' + nomeForm);
        var rNrBem = $('#lsbemfin', '#' + nomeForm);
        var rVlBem = $('label[for="vlmerbem"]', '#' + nomeForm);
        var rTpCHassi = $('label[for="tpchassi"]', '#' + nomeForm);
        var rLinha = $('label[for="dschassi"],label[for="uflicenc"],label[for="nrcpfbem"]', '#' + nomeForm);
        var rAnoFab = $('label[for="nranobem"]', '#' + nomeForm);
        var rTpBem = $('label[for="dstipbem"]', '#' + nomeForm);

        var cCateg = $('#dscatbem', '#' + nomeForm);
        var cTpBem = $('#dstipbem', '#' + nomeForm);
        var cVlMercad = $('#vlmerbem', '#' + nomeForm);
        var cDesc = $('#dsbemfin', '#' + nomeForm);
        var cTpChassi = $('#tpchassi', '#' + nomeForm);
        var cCor = $('#dscorbem', '#' + nomeForm);
        var cChassi = $('#dschassi', '#' + nomeForm);
        var cUfPlaca = $('#ufdplaca', '#' + nomeForm);
        var cNrPlaca = $('#nrdplaca', '#' + nomeForm);
        var cUfLicenc = $('#uflicenc', '#' + nomeForm);
        var cRenavan = $('#nrrenava', '#' + nomeForm);
        var cAnoFab = $('#nranobem', '#' + nomeForm);
        var cAnoMod = $('#nrmodbem', '#' + nomeForm);
        var cCPF = $('#nrcpfbem', '#' + nomeForm);

        rRotulo.addClass('rotulo').css('width', '67px');
        rNrBem.css('width', '245px');
        rVlBem.css('width', '140px');
        rTpCHassi.addClass('rotulo-linha');
        rLinha.css('width', '103px');
        rAnoFab.addClass('rotulo-linha');
        rTpBem.css('width', '140px');

        cCateg.css('width', '156px');
        cVlMercad.addClass('moeda').css('width', '87px');
        cDesc.addClass('alphanum').css('width', '225px').attr('maxlength', '25');
        cTpChassi.css('width', '87px');
        cCor.addClass('alphanum').css('width', '156px').attr('maxlength', '35');

        cUfPlaca.css('width', '45px');
        cNrPlaca.addClass('placa').css({'width': '70px', 'text-transform': 'uppercase'});
        cUfLicenc.css('width', '45px');
        cRenavan.addClass('renavan2').css('width', '118px');
        cAnoFab.addClass('inteiro').css('width', '60px').attr('maxlength', '4');
        cAnoMod.addClass('inteiro').css('width', '118px').attr('maxlength', '4');

        cCPF.css('width', '162px');

        cCateg.unbind('change').bind('change', function() {

            if (in_array(cCateg.val(), ['AUTOMOVEL', 'MOTO', 'CAMINHAO'])) {
                rTpBem.css('visibility', 'visible');
                cTpBem.css({'visibility': 'visible', 'width': '87px'}).habilitaCampo();
                cChassi.addClass('alphanum').css('width', '162px').attr('maxlength', '17');
                cTpBem.unbind('change').bind('change', function() {
                    if (cTpBem.val() == 'ZERO KM') {
                        cUfPlaca.val('').desabilitaCampo();
                        cNrPlaca.val('').desabilitaCampo();
                        cRenavan.val('').desabilitaCampo();
                    } else {
                        cUfPlaca.habilitaCampo();
                        cNrPlaca.habilitaCampo();
                        cRenavan.habilitaCampo();
                        busca_uf_pa_ass();
                    }
                });
            } else {
                rTpBem.css('visibility', 'hidden');
                cTpBem.css('visibility', 'hidden').desabilitaCampo();
                cChassi.addClass('alphanum').css('width', '162px').attr('maxlength', '20');
            }
        });

        // Para chamar o evento de onChange - Ocorria que qndo voltava o campo nao era ajustada a mascara.
        cCateg.trigger("change");

        // Se pressionar alguma tecla no campo Chassi/N.Serie, verificar a tecla pressionada e toda a devida ação
        cChassi.unbind('keydown').bind('keydown', function(event) {
			
			if (in_array(cCateg.val(), ['AUTOMOVEL', 'MOTO', 'CAMINHAO'])) {
			
				var tecla = event.which || event.keyCode;
				
				// Se é a tecla "Q" ou "q"
				if (tecla == 81){
					return false;
				}
				
				// Se é a tecla "I" ou "i"			
				if (tecla == 73){
					return false;
				}
				
				// Se é a tecla "O" ou "o"
				if (tecla == 79){
					return false;
				}			
				
			}	
        });

		//Remover caracteres especiais
		cChassi.unbind('keyup').bind('keyup', function(e){
			
			var re = /[^\w\s]/gi;
			
			if(re.test(cChassi.val())){
				cChassi.val(cChassi.val().replace(re, ''));
			}		            
            
			if (in_array(cCateg.val(), ['AUTOMOVEL', 'MOTO', 'CAMINHAO'])) {
                re = /[\Q\q\I\i\O\o\_]/g;
                
                if(re.test(cChassi.val())){
                    cChassi.val(cChassi.val().replace(re, ''));
                }			
			}
			re = / /g;
			
			if(re.test(cChassi.val())){
				cChassi.val(cChassi.val().replace(re, ''));
			}			
		});
		
		cChassi.unbind('blur').bind('blur', function(){
			cChassi.val(cChassi.val().replace(/[^\w\s]/gi, ''));
            
            if (in_array(cCateg.val(), ['AUTOMOVEL', 'MOTO', 'CAMINHAO'])) {
			  cChassi.val(cChassi.val().replace(/[\Q\q\I\i\O\o\_]/g, ''));
            }
            
			cChassi.val(cChassi.val().replace(/ /g,''));			
		});
		
        if (operacao == 'C_ALIENACAO') {
            cTodos.desabilitaCampo();
        } else if (operacao == 'A_ALIENACAO' || operacao == 'IA_ALIENACAO') {
            cTodos.habilitaCampo();
            if (cTpBem.val() == 'ZERO KM') {
                cUfPlaca.val('').desabilitaCampo();
                cNrPlaca.val('').desabilitaCampo();
                cRenavan.val('').desabilitaCampo();
            }
            if (contAlienacao == 1) {
                $('#btDeletar', '#divBotoes').css('display', 'none');
            }
        } else if (operacao == 'AI_ALIENACAO' || operacao == 'I_ALIENACAO') {
            cTodos.habilitaCampo();
            strSelect(lscatbem, 'dscatbem', 'frmAlienacao');
            $('#' + nomeForm).limpaFormulario();
            rNrBem.html('( ' + (contAlienacao + 1) + 'º Bem )');
            cTpChassi.val(2)
        }

        cUfLicenc.desabilitaCampo();


    } else if (in_array(operacao, ['C_INTEV_ANU', 'A_INTEV_ANU', 'AI_INTEV_ANU', 'I_INTEV_ANU', 'IA_INTEV_ANU'])) {

        nomeForm = 'frmIntevAnuente';
        altura = '415px';
        largura = '498px';

        var cTodos = $('input,select', '#' + nomeForm + ' fieldset:eq(0)');

        var rRotulo = $('label[for="nrctaava"],label[for="nmdavali"],label[for="tpdocava"]', '#' + nomeForm);

        var rCpf = $('label[for="nrcpfcgc"]', '#' + nomeForm);
        var rNacio = $('label[for="cdnacion"]', '#' + nomeForm);

        var cConta = $('#nrctaava', '#' + nomeForm);
        var cCPF = $('#nrcpfcgc', '#' + nomeForm);
        var cNome = $('#nmdavali', '#' + nomeForm);
        var cDoc = $('#tpdocava', '#' + nomeForm);
        var cNrDoc = $('#nrdocava', '#' + nomeForm);
        var cNacio = $('#cdnacion', '#' + nomeForm);
        var cDsnacio = $('#dsnacion', '#' + nomeForm);
        var cInpessoa = $('#inpessoa', '#' + nomeForm);

        rRotulo.addClass('rotulo').css('width', '40px');
        rCpf.css('width', '45px');
        rNacio.addClass('rotulo').css('width', '40px');

        cConta.addClass('conta pesquisa').css('width', '115px');
        cCPF.css('width', '134px');

        cNome.addClass('alphanum').css('width', '255px').attr('maxlength', '40');
        cDoc.css('width', '50px');
        cNrDoc.addClass('alphanum').css('width', '202px').attr('maxlength', '40');
        cNacio.addClass('codigo pesquisa').css('width', '50px');
        cDsnacio.css('width', '182px');

        cConta.unbind('change').bind('change', function() {

            nrctaava = normalizaNumero($(this).val());

            if (nrctaava != 0) {
                // Verifica se a conta é válida
                if (!validaNroConta(nrctaava)) {
                    showError('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Anota', 'focaCampoErro(\'nrctaava\',\'frmIntevAnuente\');bloqueiaFundo(divRotina);');
                    return false;
                } else {
                    Busca_Associado(nrctaava, 0, contIntervis - 1);
                }
            }
        });

        // Se pressionar alguma tecla no campo numero da conta, verificar a tecla pressionada e toda a devida ação
        cConta.unbind('keydown').bind('keydown', function(e) {

            if (divError.css('display') == 'block') {
                return false;
            }

            // Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
            if (e.keyCode == 9) {
                // Armazena o número da conta na variável global
                nrctaava = normalizaNumero($(this).val());
                nrctaavaOld = nrctaava;

                // Verifica se o número da conta é vazio
                if (nrctaava != 0) {

                    // Verifica se a conta é válida
                    if (!validaNroConta(nrctaava)) {
                        showError('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Anota', 'focaCampoErro(\'nrctaava\',\'frmIntevAnuente\');bloqueiaFundo(divRotina);');
                        return false;
                    }

                    Busca_Associado(nrctaava, 0, contAvalistas - 1);
                } else {
                    cTodos.habilitaCampo();
                    cTodos_1.habilitaCampo();
                    cTodos_2.habilitaCampo();
                    cTodos_3.habilitaCampo();
                    cConta.desabilitaCampo();
                    //Projeto CEP
                    $('#dsendre1,#cdufresd,#dsendre2,#nmcidade,#dsnacion', '#' + nomeForm).desabilitaCampo();

                    controlaPesquisas();

                    cNome.focus();
                }

                return false;
            }
        });

        // Se pressio/*nar alguma tecla no campo numero da conta, verificar a tecla pressionada e toda a devida ação
        cInpessoa.unbind('keydown').bind('keydown', function(e) {

            if (divError.css('display') == 'block') {
                return false;
            }

            // Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
            if (e.keyCode == 9) {
                // Armazena o número da conta na variável global
                nrcpfcgc = normalizaNumero(cCPF.val());
                nrcpfcgcOld = nrcpfcgc;

                pessoa = normalizaNumero(cInpessoa.val());

                if (nrcpfcgc != 0) {

                    // Valida o CPF
                    if (!validaCpfCnpj(nrcpfcgc, pessoa)) {
                        showError('error', 'CPF/CNPJ inv&aacute;lido.', 'Valida&ccedil;&atilde;o CPF', '$("#inpessoa","#frmIntevAnuente").focus();bloqueiaFundo(divRotina);');
                        return false;
                    } else {

                        Busca_Associado(0, nrcpfcgc, contAvalistas - 1);

                    }

                    // Caso em que o cpf é zero
                } else {

                }

                return false;
            }
        });

        var cTodos_1 = $('input,select', '#' + nomeForm + ' fieldset:eq(1)');

        var rRotulo_1 = $('label[for="nmconjug"],label[for="tpdoccjg"]', '#' + nomeForm);
        var rCpf_1 = $('label[for="nrcpfcjg"]', '#' + nomeForm);

        var cConj = $('#nmconjug', '#' + nomeForm);
        var cCPF_1 = $('#nrcpfcjg', '#' + nomeForm);
        var cDoc_1 = $('#tpdoccjg', '#' + nomeForm);
        var cNrDoc_1 = $('#nrdoccjg', '#' + nomeForm);

        rRotulo_1.addClass('rotulo').css('width', '50px');
        rCpf_1.addClass('').css('width', '40px');

        cConj.addClass('alphanum').css('width', '250px').attr('maxlength', '40');
        cCPF_1.addClass('cpf').css('width', '134px');
        cDoc_1.css('width', '50px');
        cNrDoc_1.addClass('alphanum').css('width', '197px').attr('maxlength', '40');

        var cTodos_2 = $('input,select', '#' + nomeForm + ' fieldset:eq(2)');

        // RÓTULOS - ENDEREÇO
        var rCep = $('label[for="nrcepend"]', '#' + nomeForm);
        var rEnd = $('label[for="dsendre1"]', '#' + nomeForm);
        var rBai = $('label[for="dsendre2"]', '#' + nomeForm);
        var rEst = $('label[for="cdufresd"]', '#' + nomeForm);
        var rCid = $('label[for="nmcidade"]', '#' + nomeForm);
        //Campos projeto CEP
        var rNum = $('label[for="nrendere"]', '#' + nomeForm);
        var rCom = $('label[for="complend"]', '#' + nomeForm);
        var rCax = $('label[for="nrcxapst"]', '#' + nomeForm);

        rCep.addClass('rotulo').css('width', '55px');
        rEnd.addClass('rotulo-linha').css('width', '35px');
        rNum.addClass('rotulo').css('width', '55px');
        rCom.addClass('rotulo-linha').css('width', '52px');
        rCax.addClass('rotulo').css('width', '55px');
        rBai.addClass('rotulo-linha').css('width', '52px');
        rEst.addClass('rotulo').css('width', '55px');
        rCid.addClass('rotulo-linha').css('width', '52px');

        // CAMPOS - ENDEREÇO
        var cCep = $('#nrcepend', '#' + nomeForm);
        var cEnd = $('#dsendre1', '#' + nomeForm);
        var cBai = $('#dsendre2', '#' + nomeForm);
        var cEst = $('#cdufresd', '#' + nomeForm);
        var cCid = $('#nmcidade', '#' + nomeForm);
        //Campos projeto CEP
        var cNum = $('#nrendere', '#' + nomeForm);
        var cCom = $('#complend', '#' + nomeForm);
        var cCax = $('#nrcxapst', '#' + nomeForm);

        cCep.addClass('cep pesquisa').css('width', '65px').attr('maxlength', '9');
        cEnd.addClass('alphanum').css('width', '300px').attr('maxlength', '40');
        cNum.addClass('numerocasa').css('width', '65px').attr('maxlength', '7');
        cCom.addClass('alphanum').css('width', '300px').attr('maxlength', '40');
        cCax.addClass('caixapostal').css('width', '65px').attr('maxlength', '6');
        cBai.addClass('alphanum').css('width', '300px').attr('maxlength', '40');
        cEst.css('width', '65px');
        cCid.addClass('alphanum').css('width', '300px').attr('maxlength', '25');

        //Controle contato
        var cTodos_3 = $('select,input', '#' + nomeForm + ' fieldset:eq(3)');

        var rFone = $('label[for="nrfonres"]', '#' + nomeForm);
        var rEmail = $('label[for="dsdemail"]', '#' + nomeForm);

        rFone.addClass('rotulo-linha');
        rEmail.addClass('rotulo').css('width', '55px');

        var cFone = $('#nrfonres', '#' + nomeForm);
        var cEmail = $('#dsdemail', '#' + nomeForm);

        cFone.addClass('alphanum').css('width', '150px').attr('maxlength', '19');
        cEmail.addClass('alphanum').css('width', '237px').attr('maxlength', '30');

        if (operacao == 'C_INTEV_ANU') {
            cTodos.desabilitaCampo();
            cTodos_1.desabilitaCampo();
            cTodos_2.desabilitaCampo();
            cTodos_3.desabilitaCampo();
        } else if (operacao == 'A_INTEV_ANU' || operacao == 'IA_INTEV_ANU') {
            iniciaInterv();
        } else if (operacao == 'AI_INTEV_ANU' || operacao == 'I_INTEV_ANU') {
            iniciaInterv();
            //Projeto CEP
            $('#dsendre1,#cdufresd,#dsendre2,#nmcidade', '#' + nomeForm).desabilitaCampo();

            $('#' + nomeForm).limpaFormulario();
            $('legend:first', '#frmIntevAnuente').html('Dados do Interveniente Anuente ' + (contIntervis + 1));
        }

    } else if (in_array(operacao, ['A_PARCELAS', 'V_PARCELAS', 'C_PARCELAS', 'I_PARCELAS'])) {
        // Monta Tabela de parcelas
        $('#divParcelasTab > div > table > tbody').html('');

        for (var i in arrayParcelas) {
            $('#divParcelasTab > div > table > tbody').append('<tr></tr>');
            $('#divParcelasTab > div > table > tbody > tr:last-child').append('<td>' + arrayParcelas[i]['nrparepr'] + '</td>');
            $('#divParcelasTab > div > table > tbody > tr:last-child').append('<td>' + arrayParcelas[i]['dtparepr'] + '</td>');
            $('#divParcelasTab > div > table > tbody > tr:last-child').append('<td><span>' + arrayParcelas[i]['vlparepr'].replace(',', '.') + '</span>' + number_format(parseFloat(arrayParcelas[i]['vlparepr'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.') + '</td>');
        }

        altura = '300px';
        largura = '440px';

        var divRegistro = $('#divParcelasTab > div.divRegistros');
        var tabela = $('table', divRegistro);

        divRegistro.css('height', '230px');

        var ordemInicial = new Array();
        ordemInicial = [[0, 0]];

        var arrayLargura = new Array();
        arrayLargura[0] = '140px';
        arrayLargura[1] = '140px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'right';
        arrayAlinha[1] = 'right';
        arrayAlinha[2] = 'right';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    } else if (in_array(operacao, ['T_EFETIVA'])) {

        $('#linkAba0').html('Principal');
        altura = '215px';
        largura = '433px';
        nomeForm = 'frmEfetivaProp';

        var cTodos = $('select,input', '#' + nomeForm);

        var cFinalidEmpr = $('#cdfinemp', '#' + nomeForm);
        var cLinhaCredit = $('#cdlcremp', '#' + nomeForm);
        var cNivelRisco = $('#nivrisco', '#' + nomeForm);
        var cValorEmpr = $('#vlemprst', '#' + nomeForm);
        var cValorParc = $('#vlpreemp', '#' + nomeForm);
        var cQtdeParc = $('#qtpreemp', '#' + nomeForm);
        var cDebito = $('#flgpagto', '#' + nomeForm);
        var cDtPagamento = $('#dtdpagto', '#' + nomeForm);
        var cContaAval1 = $('#nrctaav1', '#' + nomeForm);
        var cDocAval1 = $('#avalist1', '#' + nomeForm);
        var cContaAval2 = $('#nrctaav2', '#' + nomeForm);
        var cDocAval2 = $('#avalist2', '#' + nomeForm);
        var cVlFinanc = $('#vlfinanc', '#' + nomeForm);

        var rFinalidEmpr = $('label[for="cdfinemp"]', '#' + nomeForm);
        var rLinhaCredit = $('label[for="cdlcremp"]', '#' + nomeForm);
        var rNivelRisco = $('label[for="nivrisco"]', '#' + nomeForm);
        var rValorEmpr = $('label[for="vlemprst"]', '#' + nomeForm);
        var rValorParc = $('label[for="vlpreemp"]', '#' + nomeForm);
        var rQtdeParc = $('label[for="qtpreemp"]', '#' + nomeForm);
        var rDtPagamento = $('label[for="dtdpagto"]', '#' + nomeForm);
        var rDebito = $('label[for="flgpagto"]', '#' + nomeForm);
        var rContaAval1 = $('label[for="nrctaav1"]', '#' + nomeForm);
        var rDocAval1 = $('label[for="avalist1"]', '#' + nomeForm);
        var rContaAval2 = $('label[for="nrctaav2"]', '#' + nomeForm);
        var rDocAval2 = $('label[for="avalist2"]', '#' + nomeForm);
        var rVlFinanc = $('label[for="vlfinanc"]', '#' + nomeForm);

        cFinalidEmpr.addClass('rotulo').css('width', '80px');
        cLinhaCredit.addClass('rotulo').css('width', '35px').attr('maxlength', '3');
        cNivelRisco.addClass('rotulo').css('width', '30px');
        cValorEmpr.addClass('moeda').css('width', '70px');
        cValorParc.addClass('rotulo moeda').css('width', '70px');
        cQtdeParc.addClass('').css('width', '50px').setMask('INTEGER', 'zz9', '', '');
        cDtPagamento.addClass('').css('width', '90px');
        cDebito.addClass('rotulo').css('width', '70px');
        cContaAval1.addClass('rotulo').css('width', '90px');
        cDocAval1.addClass('').css('width', '90px');
        cContaAval2.addClass('rotulo').css('width', '90px');
        cDocAval2.addClass('').css('width', '90px');
        cVlFinanc.addClass('rotulo moeda').css('width', '70px');

        rFinalidEmpr.addClass('rotulo').css('width', '110px');
        rLinhaCredit.css('width', '120px');
        rNivelRisco.addClass('rotulo').css('width', '110px');
        rValorEmpr.css('width', '170px');
        rValorParc.addClass('rotulo').css('width', '110px');
        rQtdeParc.css('width', '130px');
        rDtPagamento.addClass('rotulo').css('width', '110px');
        rDebito.css('width', '110px');
        rContaAval1.addClass('rotulo').css('width', '110px');
        rDocAval1.css('width', '110px');
        rContaAval2.addClass('rotulo').css('width', '110px');
        rDocAval2.css('width', '110px');
        rVlFinanc.addClass('rotulo').css('width', '110px');

        cTodos.addClass('campo');
        cFinalidEmpr.desabilitaCampo();
        cLinhaCredit.desabilitaCampo();
        cNivelRisco.desabilitaCampo();
        cValorEmpr.desabilitaCampo();
        cValorParc.desabilitaCampo();
        cQtdeParc.desabilitaCampo();
        cDebito.desabilitaCampo();
        cDtPagamento.desabilitaCampo();
        cContaAval1.desabilitaCampo();
        cDocAval1.desabilitaCampo();
        cContaAval2.desabilitaCampo();
        cDocAval2.desabilitaCampo();
        cVlFinanc.desabilitaCampo();

        if (arrayStatusApprov['flgpagto'] == 'yes')
            var tipoPagamento = 'Folha';
        else
            var tipoPagamento = 'C/C';

        cFinalidEmpr.val(arrayStatusApprov['cdfinemp']);
        cLinhaCredit.val(arrayStatusApprov['cdlcremp']);
        cNivelRisco.val(arrayStatusApprov['nivriori'] != '' ? arrayStatusApprov['nivriori'] : arrayStatusApprov['nivriris']);
        cValorEmpr.val(arrayStatusApprov['vlemprst']);
        cValorParc.val(arrayStatusApprov['vlpreemp']);
        cQtdeParc.val(arrayStatusApprov['qtpreemp']);
        cDebito.val(tipoPagamento);
        cDtPagamento.val(arrayStatusApprov['dtdpagto']);
        cContaAval1.val(arrayStatusApprov['nrctaav1']);
        cDocAval1.val(arrayStatusApprov['avalist1']);
        cContaAval2.val(arrayStatusApprov['nrctaav2']);
        cDocAval2.val(arrayStatusApprov['avalist2']);
        cVlFinanc.val(arrayStatusApprov['vlfinanc']);

        $('#btSalvar', '#divBotoes').unbind('click').bind('click', function() {
            flggravp = true;
            for (var i in arrayMensagemAval) {
                dsmensag = arrayMensagemAval[i]['dsmensag'];
                flggravp = false;
                controlaOperacao('T_AVALISTA' + arrayMensagemAval[i]['cdavalis']);
                return false;
            }

            if (flggravp)
                showConfirmacaoEfetiva();
        });

        hideMsgAguardo();
        bloqueiaFundo($('#divRotina'));

    } else if (in_array(operacao, ['T_AVALISTA1', 'T_AVALISTA2'])) {

        altura = '70px';
        largura = '300px';


        $('#btSalvar', '#divBotoes').unbind('click').bind('click', function() {
            showConfirmacao(dsmensag, 'Confirma&ccedil;&atilde;o - Ayllos', 'avancarAvalista(operacao)', 'bloqueiaFundo(divRotina);', 'sim.gif', 'nao.gif');
        });

        // Monta Tabela de parcelas
        $('#divEmprAvalTab > div > table > tbody').html('');

        arrayEmprestimosAvalista = new Array();

        if (operacao == 'T_AVALISTA1')
        {
            arrayEmprestimosAvalista = arrayEmprestimosAvalista1;
            $('#linkAba0').html('Empr&eacute;stimos Avalista 1');
        }
        else
        {
            arrayEmprestimosAvalista = arrayEmprestimosAvalista2;
            $('#linkAba0').html('Empr&eacute;stimos Avalista 2');
        }

        for (var i in arrayEmprestimosAvalista) {
            $('#divEmprAvalTab > div > table > tbody').append('<tr></tr>');
            $('#divEmprAvalTab > div > table > tbody > tr:last-child').append('<td>' + arrayEmprestimosAvalista[i]['nrdconta'] + '</td>');
            $('#divEmprAvalTab > div > table > tbody > tr:last-child').append('<td>' + arrayEmprestimosAvalista[i]['nrctremp'] + '</td>');
            $('#divEmprAvalTab > div > table > tbody > tr:last-child').append('<td>' + arrayEmprestimosAvalista[i]['dtmvtolt'] + '</td>');
            $('#divEmprAvalTab > div > table > tbody > tr:last-child').append('<td><span>' + arrayEmprestimosAvalista[i]['vlemprst'].replace(',', '.') + '</span>' + number_format(parseFloat(arrayEmprestimosAvalista[i]['vlemprst'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.') + '</td>');
            $('#divEmprAvalTab > div > table > tbody > tr:last-child').append('<td>' + arrayEmprestimosAvalista[i]['qtpreemp'] + '</td>');
            $('#divEmprAvalTab > div > table > tbody > tr:last-child').append('<td><span>' + arrayEmprestimosAvalista[i]['vlpreemp'].replace(',', '.') + '</span>' + number_format(parseFloat(arrayEmprestimosAvalista[i]['vlpreemp'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.') + '</td>');
            $('#divEmprAvalTab > div > table > tbody > tr:last-child').append('<td><span>' + arrayEmprestimosAvalista[i]['vlsdeved'].replace(',', '.') + '</span>' + number_format(parseFloat(arrayEmprestimosAvalista[i]['vlsdeved'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.') + '</td>');
        }

        altura = '210px';
        largura = '580px';

        var divRegistro = $('#divEmprAvalTab > div.divRegistros');
        var tabela = $('table', divRegistro);

        divRegistro.css('height', '150px');

        var ordemInicial = new Array();
        ordemInicial = [[0, 0]];

        var arrayLargura = new Array();
        arrayLargura[0] = '70px';
        arrayLargura[1] = '70px';
        arrayLargura[2] = '80px';
        arrayLargura[3] = '80px';
        arrayLargura[4] = '70px';
        arrayLargura[5] = '70px';
        arrayLargura[6] = '70px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'right';
        arrayAlinha[1] = 'right';
        arrayAlinha[2] = 'right';
        arrayAlinha[3] = 'right';
        arrayAlinha[4] = 'right';
        arrayAlinha[5] = 'right';
        arrayAlinha[6] = 'right';
        arrayAlinha[7] = 'right';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

        hideMsgAguardo();
        bloqueiaFundo($('#divRotina'));

    } else if (in_array(operacao, ['RATING'])) {

        var divRegistro = $('div.divRegistros');
        var tabela = $('table', divRegistro);
        var linha = $('table > tbody > tr', divRegistro);

        divRegistro.css('height', '150px');

        for (var i in arrayRatings) {
            $('#divParcelasTab > div > table > tbody').append('<tr></tr>');
            $('#divParcelasTab > div > table > tbody > tr:last-child').append('<td>' + arrayRatings[i]['dtmvtolt'] + '</td>');
            $('#divParcelasTab > div > table > tbody > tr:last-child').append('<td>' + arrayRatings[i]['dsdopera'] + '</td>');
            $('#divParcelasTab > div > table > tbody > tr:last-child').append('<td>' + arrayRatings[i]['nrctrrat'] + '</td>');
            $('#divParcelasTab > div > table > tbody > tr:last-child').append('<td>' + arrayRatings[i]['indrisco'] + '</td>');
            $('#divParcelasTab > div > table > tbody > tr:last-child').append('<td><span>' + arrayRatings[i]['nrnotrat'].replace(',', '.') + '</span>' + number_format(parseFloat(arrayRatings[i]['nrnotrat'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.') + '</td>');
            $('#divParcelasTab > div > table > tbody > tr:last-child').append('<td><span>' + arrayRatings[i]['vlutlrat'].replace(',', '.') + '</span>' + number_format(parseFloat(arrayRatings[i]['vlutlrat'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.') + '</td>');
        }

        altura = '210px';
        largura = '560px';

        var ordemInicial = new Array();
        ordemInicial = [[0, 0]];

        var arrayLargura = new Array();
        arrayLargura[0] = '66px';
        arrayLargura[1] = '66px';
        arrayLargura[2] = '76px';
        arrayLargura[3] = '66px';
        arrayLargura[4] = '66px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'right';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'right';
        arrayAlinha[5] = 'right';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    } else if (operacao == 'PORTAB_CRED_I') { /*Portabilidade - Insercao*/
        nomeForm = 'frmPortabilidadeCredito';
        largura = '465px';
        altura = '190px';

        var caracEspeciais = '!@#$%&*()-_+=�:<>;/?[]{}���������\\|\',.�`�^~';

        /* desabilita nr.portabilidade e situacao */
        $('label[for="nrunico_portabilidade"]', '#frmPortabilidadeCredito').hide();
        $('#nrunico_portabilidade', '#frmPortabilidadeCredito').hide();
        $('label[for="dssit_portabilidade"]', '#frmPortabilidadeCredito').hide();
        $('#dssit_portabilidade', '#frmPortabilidadeCredito').hide();
        //formata o campo CNPJ IF Credora
        $("#nrcnpjbase_if_origem", "#frmPortabilidadeCredito").addClass('cnpj');
        //formata o campo de nome da instituicao financeira
        $("#nmif_origem", "#frmPortabilidadeCredito").attr('maxlength', '40');
        //formata o campo de numero de contrato
        $("#nrcontrato_if_origem", "#frmPortabilidadeCredito").attr('maxlength', '40');
        //mascara par ao campo
        $("#nrcontrato_if_origem", "#frmPortabilidadeCredito").setMask('STRING', 'zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz', caracEspeciais, '');
        //seta o foco no primeiro campo
        $("#nrispbif", "#frmPortabilidadeCredito").focus();
        //seta a acao do botao continuar
        $("#btSalvar", "#divBotoesFormPortabilidade").unbind('click').bind('click', function() {
            validaDados(0);
        });

        // tratamento para o botao voltar
        $("#btVoltar", "#divBotoesFormPortabilidade").unbind('click').bind('click', function() {
            controlaOperacao('IT');
        });

        // Retirar caracteres especiais - SD 779305
        $('#nmif_origem', '#frmPortabilidadeCredito').unbind('blur').bind('blur', function () {
            $(this).val(removeAcentos($(this).val()));
            $(this).val(removeCaracteresInvalidos($(this).val()));
        });
        // Fim SD 779305


    } else if (operacao == 'PORTAB_CRED_C') { /*Portabilidade - Consulta*/
        nomeForm = 'frmPortabilidadeCredito';
        largura = '465px';
        altura = '235px';

        /* habilita nr.portabilidade e situacao */
        $('label[for="nrunico_portabilidade"]', '#frmPortabilidadeCredito').show();
        $('#nrunico_portabilidade', '#frmPortabilidadeCredito').show();
        $('label[for="dssit_portabilidade"]', '#frmPortabilidadeCredito').show();
        $('#dssit_portabilidade', '#frmPortabilidadeCredito').show();

        //formata o campo CNPJ IF Credora
        $("#nrcnpjbase_if_origem", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
        //formata o nome da instituicao
        $("#nmif_origem", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
        //formata o campo de numero de contrato
        $("#nrcontrato_if_origem", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
        //formata o campo de modalidade
        $("#cdmodali_portabilidade", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
        //formata o campo de numero unico portabilidade
        $("#nrunico_portabilidade", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
        //formata o campo situacao da portabilidade
        $("#dssit_portabilidade", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
        //seta a acao do botao continuar
        $("#btSalvar", "#divBotoesFormPortabilidade").unbind('click').bind('click', function() {
            controlaOperacao('TC');
        });
        // tratamento para o botao voltar
        $("#btVoltar", "#divBotoesFormPortabilidade").unbind('click').bind('click', function() {
            controlaOperacao();
        });

    } else if (operacao == 'PORTAB_CRED_A') { /*Portabilidade - Alteracao*/
        nomeForm = 'frmPortabilidadeCredito';
        largura = '465px';
        altura = '205px';

        /* habilita nr.portabilidade e desabilitia a situacao */
        $('label[for="nrunico_portabilidade"]', '#frmPortabilidadeCredito').show();
        $('#nrunico_portabilidade', '#frmPortabilidadeCredito').show();
        $('label[for="dssit_portabilidade"]', '#frmPortabilidadeCredito').hide();
        $('#dssit_portabilidade', '#frmPortabilidadeCredito').hide();

        //formata o campo CNPJ IF Credora
        $("#nrcnpjbase_if_origem", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
        //formata o nome da instituicao
        $("#nmif_origem", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
        //formata o campo de numero de contrato
        $("#nrcontrato_if_origem", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
        //formata o campo de modalidade
        $("#cdmodali_portabilidade", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda');
        //formata o campo de numero unico portabilidade
        $("#nrunico_portabilidade", "#frmPortabilidadeCredito").addClass('campoTelaSemBorda').attr('disabled', 'disabled');
        //seta a acao do botao continuar
        $("#btSalvar", "#divBotoesFormPortabilidade").unbind('click').bind('click', function() {
            validaDados(0);
        });
        // tratamento para o botao voltar
        $("#btVoltar", "#divBotoesFormPortabilidade").unbind('click').bind('click', function() {
            controlaOperacao('AT');
        });

        // Retirar caracteres especiais - SD 779305
        $('#nmif_origem', '#frmPortabilidadeCredito').unbind('blur').bind('blur', function () {
            $(this).val(removeAcentos($(this).val()));
            $(this).val(removeCaracteresInvalidos($(this).val()));
        });
        // Fim SD 779305
       } else if (in_array(operacao, ['I_DEMONSTRATIVO_EMPRESTIMO', 'A_DEMONSTRATIVO_EMPRESTIMO'])){
        nomeForm = 'frmDemonstracaoEmprestimo';
        largura = '345px';
        altura = '205px';

        var rVlemprst = $('label[for="vlemprst"]', '#' + nomeForm);
        var rVliofepr = $('label[for="vliofepr"]', '#' + nomeForm);
        var rVlrtarif = $('label[for="vlrtarif"]', '#' + nomeForm);
        var rVlrtotal = $('label[for="vlrtotal"]', '#' + nomeForm);
        var rVlpreemp = $('label[for="vlpreemp"]', '#' + nomeForm);
        var rPercetop = $('label[for="percetop"]', '#' + nomeForm);

        var cVlemprst = $('#vlemprst', '#' + nomeForm);
        var cVliofepr = $('#vliofepr', '#' + nomeForm);
        var cVlrtarif = $('#vlrtarif', '#' + nomeForm);
        var cVlrtotal = $('#vlrtotal', '#' + nomeForm);
        var cVlpreemp = $('#vlpreemp', '#' + nomeForm);
        var cPercetop = $('#percetop', '#' + nomeForm);

        rVlemprst.addClass('rotulo').css('width', '100px');
        rVliofepr.addClass('rotulo').css('width', '100px');
        rVlrtarif.addClass('rotulo').css('width', '100px');
        rVlrtotal.addClass('rotulo').css('width', '100px');
        rVlpreemp.addClass('rotulo').css('width', '100px');
        rPercetop.addClass('rotulo').css('width', '100px');

        cVlemprst.addClass('moeda');
        cVliofepr.addClass('moeda');
        cVlrtarif.addClass('moeda');
        cVlrtotal.addClass('moeda');
        cVlpreemp.addClass('moeda');
        cPercetop.addClass('moeda');

        cVlemprst.desabilitaCampo();
        cVliofepr.desabilitaCampo();
        cVlrtarif.desabilitaCampo();
        cVlrtotal.desabilitaCampo();
        cVlpreemp.desabilitaCampo();
        cPercetop.desabilitaCampo();
    }
    
    if (operacao == 'TC') {
        atualizaCampoData();
    }

    divRotina.css('width', largura);
    $('#divConteudoOpcao').css({'height': altura, 'width': largura});
    layoutPadrao();
    removeOpacidade('divConteudoOpcao');
    if (!in_array(operacao, ['AT', 'IT', 'FI', 'FA', 'FE', 'SC', 'T_AVALISTA1', 'T_AVALISTA2', ''])) {
        $('input,select', '#' + nomeForm).trigger('blur');
        if (operacao == 'TI') {
            cVlEmpr.val('0,00');
        }
    }

    controlaPesquisas();
    hideMsgAguardo();
    bloqueiaFundo(divRotina);
    removeOpacidade('divConteudoOpcao');
    controlaFoco(operacao);
    divRotina.centralizaRotinaH();
    exibeLinhaCarencia();

    return false;
}

function microcredito(cddopcao) {

    var nrseqrrq = (typeof arrayProposta == 'undefined') ? 0 : arrayProposta['nrseqrrq'];

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/emprestimos/microcredito.php',
        data: {
            cdlcremp: arrayProposta['cdlcremp'],
            cddopcao: cddopcao,
            nrseqrrq: nrseqrrq,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });
}

function verificaObs(operacao) {

    // Alteracao 069
    $('#dsobserv', '#frmComiteAprov').val(retiraCaracteres($('#dsobserv', '#frmComiteAprov').val(), "'|\\;", false));

    var cObs = $('#dsobserv', '#frmComiteAprov').val().length;

    if (cObs > 660) {
        showError('error', 'Lim&iacute;te de caracteres ultrapassado. Permitido at&eacute; 660 caracteres.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        return;
    }

    arrayProposta['dsobscmt'] = $('#dsobscmt', '#frmComiteAprov').val();
    arrayProposta['dsobserv'] = $('#dsobserv', '#frmComiteAprov').val();

    microcredito(operacao.substr(0, 1));

}

function atualizaArray(novaOp, cdcooper) {

    showMsgAguardo('Aguarde, validando dados ...');
    setTimeout('attArray(\'' + novaOp + '\',\'' + cdcooper + '\')', 400);
    return false;
}

function copiaProposta(novaOp) {
    arrayProposta['nivrisco'] = $('#nivrisco', '#frmNovaProp').val();
    arrayProposta['nivriori'] = $('#nivrisco', '#frmNovaProp').val(); // nivel de risco original
    arrayProposta['nivcalcu'] = $('#nivcalcu', '#frmNovaProp').val();
    arrayProposta['vlemprst'] = $('#vlemprst', '#frmNovaProp').val();
    arrayProposta['cdlcremp'] = $('#cdlcremp', '#frmNovaProp').val();
    arrayProposta['vlpreemp'] = $('#vlpreemp', '#frmNovaProp').val();
    arrayProposta['cdfinemp'] = $('#cdfinemp', '#frmNovaProp').val();
    arrayProposta['qtpreemp'] = $('#qtpreemp', '#frmNovaProp').val();
    arrayProposta['idquapro'] = $('#idquapro', '#frmNovaProp').val();
    arrayProposta['idquapro'] = $('#idquapro', '#frmNovaProp').val();
    arrayProposta['flgpagto'] = $('#flgpagto', '#frmNovaProp').val();
    arrayProposta['percetop'] = $('#percetop', '#frmNovaProp').val();
    arrayProposta['qtdialib'] = $('#qtdialib', '#frmNovaProp').val();
    arrayProposta['dtdpagto'] = $('#dtdpagto', '#frmNovaProp').val();
    arrayProposta['flgimppr'] = $('#flgimppr', '#frmNovaProp').val();
    arrayProposta['flgimpnp'] = $('#flgimpnp', '#frmNovaProp').val();
    arrayProposta['dsctrliq'] = $('#dsctrliq', '#frmNovaProp').val();
	arrayProposta['idfiniof'] = $('#idfiniof', '#frmNovaProp').val();
	arrayProposta['vlfinanc'] = $('#vlfinanc', '#frmNovaProp').val();

    flgimppr = arrayProposta['flgimppr'];
    flgimpnp = arrayProposta['flgimpnp'];

    controlaOperacao(novaOp);

    return false;
}

function attArray(novaOp, cdcooper) {

    var mtdDelecao = verificaDelecao(novaOp);

    if (mtdDelecao != '') {
        eval(mtdDelecao);
        return false;
    }
    if (!validaDados(cdcooper)) {
        return false;
    }

    var atual = 0;

    if (in_array(operacao, ['TI', 'TA', 'A_NOVA_PROP', 'A_VALOR', 'A_AVALISTA', 'I_INICIO', 'A_INICIO', 'I_PARCELAS'])) {

        if (dsmensag != '') {

            var mtdSim = 'bloqueiaFundo(divRotina);showMsgAguardo("Aguarde, validando dados ...");inconfir=parseInt(inconfir)+1;inconfi2=parseInt(inconfi2)+1;attArray("' + novaOp + '");';
            var mtdNao = 'bloqueiaFundo(divRotina);inconfir=1;inconfi2=30;';

            showConfirmacao(dsmensag, 'Confirma&ccedil;&atilde;o - Ayllos', mtdSim, mtdNao, 'sim.gif', 'nao.gif');
            return false;
        }

        arrayProposta['nivrisco'] = $('#nivrisco', '#frmNovaProp').val();
        arrayProposta['nivriori'] = $('#nivrisco', '#frmNovaProp').val();
        arrayProposta['nivcalcu'] = $('#nivcalcu', '#frmNovaProp').val();
        arrayProposta['vlemprst'] = $('#vlemprst', '#frmNovaProp').val();
        arrayProposta['cdlcremp'] = $('#cdlcremp', '#frmNovaProp').val();
        arrayProposta['vlpreemp'] = $('#vlpreemp', '#frmNovaProp').val();
        arrayProposta['cdfinemp'] = $('#cdfinemp', '#frmNovaProp').val();
        arrayProposta['qtpreemp'] = $('#qtpreemp', '#frmNovaProp').val();
        arrayProposta['idquapro'] = $('#idquapro', '#frmNovaProp').val();
        arrayProposta['flgpagto'] = $('#flgpagto', '#frmNovaProp').val();
        arrayProposta['percetop'] = $('#percetop', '#frmNovaProp').val();
        arrayProposta['qtdialib'] = $('#qtdialib', '#frmNovaProp').val();
        arrayProposta['dtlibera'] = $('#dtlibera', '#frmNovaProp').val();
        arrayProposta['dtdpagto'] = $('#dtdpagto', '#frmNovaProp').val();
        arrayProposta['flgimppr'] = $('#flgimppr', '#frmNovaProp').val();
        arrayProposta['flgimpnp'] = $('#flgimpnp', '#frmNovaProp').val();
        arrayProposta['dsctrliq'] = $('#dsctrliq', '#frmNovaProp').val();
        arrayProposta['tpemprst'] = $('#tpemprst', '#frmNovaProp').val();
        arrayProposta['idfiniof'] = $('#idfiniof', '#frmNovaProp').val();
        arrayProposta['vliofepr'] = $('#vliofepr', '#frmNovaProp').val();
        arrayProposta['vlrtarif'] = $('#vlrtarif', '#frmNovaProp').val();
        arrayProposta['vlrtotal'] = $('#vlrtotal', '#frmNovaProp').val();
        arrayProposta['idcarenc'] = $('#idcarenc', '#frmNovaProp').val();
        arrayProposta['dtcarenc'] = $('#dtcarenc', '#frmNovaProp').val();
		arrayProposta['vlfinanc'] = $('#vlfinanc', '#frmNovaProp').val();

        flgimppr = arrayProposta['flgimppr'];
        flgimpnp = arrayProposta['flgimpnp'];

        tpemprst = arrayProposta['tpemprst'];
        cdtpempr = arrayProposta['cdtpempr'];
        dstpempr = arrayProposta['dstpempr'];

        calculaCet(operacao);

    } else if (in_array(operacao, ['A_COMITE_APROV', 'I_COMITE_APROV'])) {

        arrayProposta['dsobscmt'] = $('#dsobscmt', '#frmComiteAprov').val();
        arrayProposta['dsobserv'] = $('#dsobserv', '#frmComiteAprov').val();

        if (novaOp == operacao.substr(0, 1) + '_ALIENACAO') {
            controlaOperacao(operacao.substr(0, 1) + '_ALIENACAO');
        }

        return false;

    } else if (in_array(operacao, ['A_DADOS_PROP', 'I_DADOS_PROP'])) {

        for (var i = 1; i <= contRend; i++) {
            arrayRendimento['tpdrend' + i] = $('#tpdrend' + i, '#frmDadosProp').val();
            arrayRendimento['dsdrend' + i] = $('#dsdrend' + i, '#frmDadosProp').val();
            arrayRendimento['vldrend' + i] = $('#vldrend' + i, '#frmDadosProp').val();

        }

        arrayRendimento['vlsalcon'] = $('#vlsalcon', '#frmDadosProp').val();
        arrayRendimento['nmextemp'] = $('#nmextemp', '#frmDadosProp').val();
        arrayRendimento['perfatcl'] = $('#perfatcl', '#frmDadosProp').val();
        arrayRendimento['vlmedfat'] = $('#vlmedfat', '#frmDadosProp').val();
        arrayRendimento['inpessoa'] = $('#inpessoa', '#frmDadosProp').val();
        arrayRendimento['vlsalari'] = $('#vlsalari', '#frmDadosProp').val();
        arrayRendimento['dsjusren'] = $('#dsjusren', '#frmDadosProp').val();

        if ($('#flgYes', '#frmDadosProp').prop('checked')) {
            arrayRendimento['flgdocje'] = 'yes'
        } else {
            arrayRendimento['flgdocje'] = 'no'
        }

        arrayRendimento['vloutras'] = $('#vloutras', '#frmDadosProp').val();
        arrayRendimento['vlalugue'] = $('#vlalugue', '#frmDadosProp').val();

        if ($('#inconcje_1', '#frmDadosProp').prop('checked')) {
            arrayRendimento['inconcje'] = 'yes';
        } else {
            arrayRendimento['inconcje'] = 'no';
        }

    } else if (in_array(operacao, ['A_DADOS_AVAL', 'AI_DADOS_AVAL', 'I_DADOS_AVAL', 'IA_DADOS_AVAL'])) {


        atual = contAvalistas - 1;

        arrayAvalistas[atual]['nrctaava'] = $('#nrctaava', '#frmDadosAval').val();
        arrayAvalistas[atual]['cdnacion'] = $('#cdnacion', '#frmDadosAval').val();
        arrayAvalistas[atual]['dsnacion'] = $('#dsnacion', '#frmDadosAval').val();
        arrayAvalistas[atual]['tpdocava'] = $('#tpdocava', '#frmDadosAval').val();
        arrayAvalistas[atual]['nmconjug'] = $('#nmconjug', '#frmDadosAval').val();
        arrayAvalistas[atual]['tpdoccjg'] = $('#tpdoccjg', '#frmDadosAval').val();
        arrayAvalistas[atual]['dsendre1'] = $('#dsendre1', '#frmDadosAval').val();
        arrayAvalistas[atual]['nrfonres'] = $('#nrfonres', '#frmDadosAval').val();
        arrayAvalistas[atual]['nmcidade'] = $('#nmcidade', '#frmDadosAval').val();
        arrayAvalistas[atual]['nrcepend'] = $('#nrcepend', '#frmDadosAval').val();
        arrayAvalistas[atual]['nmdavali'] = $('#nmdavali', '#frmDadosAval').val();
        arrayAvalistas[atual]['nrcpfcgc'] = $('#nrcpfcgc', '#frmDadosAval').val();
        arrayAvalistas[atual]['nrdocava'] = $('#nrdocava', '#frmDadosAval').val();
        arrayAvalistas[atual]['nrcpfcjg'] = $('#nrcpfcjg', '#frmDadosAval').val();
        arrayAvalistas[atual]['nrdoccjg'] = $('#nrdoccjg', '#frmDadosAval').val();
        arrayAvalistas[atual]['dsendre2'] = $('#dsendre2', '#frmDadosAval').val();
        arrayAvalistas[atual]['dsdemail'] = $('#dsdemail', '#frmDadosAval').val();
        arrayAvalistas[atual]['cdufresd'] = $('#cdufresd', '#frmDadosAval').val();
        arrayAvalistas[atual]['vlrenmes'] = $('#vlrenmes', '#frmDadosAval').val();
        arrayAvalistas[atual]['vledvmto'] = $('#vledvmto', '#frmDadosAval').val();
        //Campos projeto CEP
        arrayAvalistas[atual]['nrendere'] = $('#nrendere', '#frmDadosAval').val();
        arrayAvalistas[atual]['complend'] = $('#complend', '#frmDadosAval').val();
        arrayAvalistas[atual]['nrcxapst'] = $('#nrcxapst', '#frmDadosAval').val();

        //Daniel
        arrayAvalistas[atual]['inpessoa'] = $('#inpessoa', '#frmDadosAval').val();
        arrayAvalistas[atual]['dtnascto'] = $('#dtnascto', '#frmDadosAval').val();

    } else if (in_array(operacao, ['AI_ALIENACAO', 'A_ALIENACAO', 'IA_ALIENACAO', 'I_ALIENACAO'])) {

        atual = contAlienacao - 1;

        arrayAlienacoes[atual]['dscatbem'] = $('#dscatbem', '#frmAlienacao').val();
        arrayAlienacoes[atual]['dstipbem'] = $('#dstipbem', '#frmAlienacao').val();
        arrayAlienacoes[atual]['dsbemfin'] = removeAcentos(removeCaracteresInvalidos($('#dsbemfin', '#frmAlienacao').val().replace("<", "").replace(">", "")));
        arrayAlienacoes[atual]['dscorbem'] = removeAcentos(removeCaracteresInvalidos($('#dscorbem', '#frmAlienacao').val().replace("<", "").replace(">", "")));
        arrayAlienacoes[atual]['dschassi'] = $('#dschassi', '#frmAlienacao').val();
        arrayAlienacoes[atual]['nranobem'] = $('#nranobem', '#frmAlienacao').val();
        arrayAlienacoes[atual]['nrmodbem'] = $('#nrmodbem', '#frmAlienacao').val();
        arrayAlienacoes[atual]['nrdplaca'] = $('#nrdplaca', '#frmAlienacao').val();
        arrayAlienacoes[atual]['nrrenava'] = $('#nrrenava', '#frmAlienacao').val();
        arrayAlienacoes[atual]['tpchassi'] = $('#tpchassi', '#frmAlienacao').val();
        arrayAlienacoes[atual]['ufdplaca'] = $('#ufdplaca', '#frmAlienacao').val();
        arrayAlienacoes[atual]['nrcpfbem'] = $('#nrcpfbem', '#frmAlienacao').val();
        arrayAlienacoes[atual]['dscpfbem'] = $('#dscpfbem', '#frmAlienacao').val();
        arrayAlienacoes[atual]['vlmerbem'] = $('#vlmerbem', '#frmAlienacao').val();
        arrayAlienacoes[atual]['idalibem'] = $('#idalibem', '#frmAlienacao').val();
        arrayAlienacoes[atual]['uflicenc'] = $('#uflicenc', '#frmAlienacao').val(); // GRAVAMES */
		arrayAlienacoes[atual]['cdcoplib'] = glb_codigoOperadorLiberacao;
    } else if (in_array(operacao, ['AI_INTEV_ANU', 'A_INTEV_ANU', 'IA_INTEV_ANU', 'I_INTEV_ANU'])) {

        atual = contIntervis - 1;

        arrayIntervs[atual]['nrctaava'] = $('#nrctaava', '#frmIntevAnuente').val();
        arrayIntervs[atual]['cdnacion'] = $('#cdnacion', '#frmIntevAnuente').val();
        arrayIntervs[atual]['dsnacion'] = $('#dsnacion', '#frmIntevAnuente').val();
        arrayIntervs[atual]['tpdocava'] = $('#tpdocava', '#frmIntevAnuente').val();
        arrayIntervs[atual]['nmconjug'] = $('#nmconjug', '#frmIntevAnuente').val();
        arrayIntervs[atual]['tpdoccjg'] = $('#tpdoccjg', '#frmIntevAnuente').val();
        arrayIntervs[atual]['dsendre1'] = $('#dsendre1', '#frmIntevAnuente').val();
        arrayIntervs[atual]['nrfonres'] = $('#nrfonres', '#frmIntevAnuente').val();
        arrayIntervs[atual]['nmcidade'] = $('#nmcidade', '#frmIntevAnuente').val();
        arrayIntervs[atual]['nrcepend'] = $('#nrcepend', '#frmIntevAnuente').val();
        arrayIntervs[atual]['nmdavali'] = $('#nmdavali', '#frmIntevAnuente').val();
        arrayIntervs[atual]['nrcpfcgc'] = $('#nrcpfcgc', '#frmIntevAnuente').val();
        arrayIntervs[atual]['nrdocava'] = $('#nrdocava', '#frmIntevAnuente').val();
        arrayIntervs[atual]['nrcpfcjg'] = $('#nrcpfcjg', '#frmIntevAnuente').val();
        arrayIntervs[atual]['nrdoccjg'] = $('#nrdoccjg', '#frmIntevAnuente').val();
        arrayIntervs[atual]['dsendre2'] = $('#dsendre2', '#frmIntevAnuente').val();
        arrayIntervs[atual]['dsdemail'] = $('#dsdemail', '#frmIntevAnuente').val();
        arrayIntervs[atual]['cdufresd'] = $('#cdufresd', '#frmIntevAnuente').val();
        //Campos projeto CEP
        arrayIntervs[atual]['nrendere'] = $('#nrendere', '#frmIntevAnuente').val();
        arrayIntervs[atual]['complend'] = $('#complend', '#frmIntevAnuente').val();
        arrayIntervs[atual]['nrcxapst'] = $('#nrcxapst', '#frmIntevAnuente').val();

    } else if (in_array(operacao, ['A_PROT_CRED', 'I_PROT_CRED'])) {
        arrayProtCred['nrperger'] = $('#nrperger', '#frmOrgProtCred').val();
        arrayProtCred['dsperger'] = $('#dsperger', '#frmOrgProtCred').val();
        arrayProtCred['dtcnsspc'] = $('#dtcnsspc', '#frmOrgProtCred').val();
        arrayProtCred['nrinfcad'] = $('#nrinfcad', '#frmOrgProtCred').val();
        arrayProtCred['dsinfcad'] = $('#dsinfcad', '#frmOrgProtCred').val();
        arrayProtCred['dtdrisco'] = $('#dtdrisco', '#frmOrgProtCred').val();
        arrayProtCred['vltotsfn'] = $('#vltotsfn', '#frmOrgProtCred').val();
        arrayProtCred['qtopescr'] = $('#qtopescr', '#frmOrgProtCred').val();
        arrayProtCred['qtifoper'] = $('#qtifoper', '#frmOrgProtCred').val();
        arrayProtCred['nrliquid'] = $('#nrliquid', '#frmOrgProtCred').val();
        arrayProtCred['dsliquid'] = $('#dsliquid', '#frmOrgProtCred').val();
        arrayProtCred['vlopescr'] = $('#vlopescr', '#frmOrgProtCred').val();
        arrayProtCred['vlrpreju'] = $('#vlrpreju', '#frmOrgProtCred').val();
        arrayProtCred['nrpatlvr'] = $('#nrpatlvr', '#frmOrgProtCred').val();
        arrayProtCred['dspatlvr'] = $('#dspatlvr', '#frmOrgProtCred').val();
        arrayProtCred['nrgarope'] = $('#nrgarope', '#frmOrgProtCred').val();
        arrayProtCred['dsgarope'] = $('#dsgarope', '#frmOrgProtCred').val();
        arrayProtCred['dtoutspc'] = $('#dtoutspc', '#frmOrgProtCred').val();
        arrayProtCred['dtoutris'] = $('#dtoutris', '#frmOrgProtCred').val();
        arrayProtCred['vlsfnout'] = $('#vlsfnout', '#frmOrgProtCred').val();
        arrayProtCred['flgcentr'] = $('#flgcentr', '#frmOrgProtCred').val();
        arrayProtCred['flgcoout'] = $('#flgcoout', '#frmOrgProtCred').val();

    } else if (in_array(operacao, ['AI_HIPOTECA', 'A_HIPOTECA', 'I_HIPOTECA', 'IA_HIPOTECA'])) {

        atual = contHipotecas - 1;

        arrayHipotecas[atual]['dscatbem'] = $('#dscatbem', '#frmHipoteca').val();
        arrayHipotecas[atual]['dsbemfin'] = $('#dsbemfin', '#frmHipoteca').val();
        arrayHipotecas[atual]['dscorbem'] = $('#dscorbem', '#frmHipoteca').val();
        arrayHipotecas[atual]['idseqhip'] = $('#idseqhip', '#frmHipoteca').val();
        arrayHipotecas[atual]['vlmerbem'] = $('#vlmerbem', '#frmHipoteca').val();

    } else if (in_array(operacao, ['V_PARCELAS'])) {
        arrayProposta['nivrisco'] = $('#nivrisco', '#frmNovaProp').val();
        arrayProposta['nivriori'] = $('#nivriori', '#frmNovaProp').val();
        arrayProposta['nivcalcu'] = $('#nivcalcu', '#frmNovaProp').val();
        arrayProposta['vlemprst'] = $('#vlemprst', '#frmNovaProp').val();
        arrayProposta['cdlcremp'] = $('#cdlcremp', '#frmNovaProp').val();
        arrayProposta['vlpreemp'] = $('#vlpreemp', '#frmNovaProp').val();
        arrayProposta['cdfinemp'] = $('#cdfinemp', '#frmNovaProp').val();
        arrayProposta['qtpreemp'] = $('#qtpreemp', '#frmNovaProp').val();
        arrayProposta['idquapro'] = $('#idquapro', '#frmNovaProp').val();
        arrayProposta['flgpagto'] = $('#flgpagto', '#frmNovaProp').val();
        arrayProposta['percetop'] = $('#percetop', '#frmNovaProp').val();
        arrayProposta['qtdialib'] = $('#qtdialib', '#frmNovaProp').val();
        arrayProposta['dtdpagto'] = $('#dtdpagto', '#frmNovaProp').val();
        arrayProposta['flgimppr'] = $('#flgimppr', '#frmNovaProp').val();
        arrayProposta['flgimpnp'] = $('#flgimpnp', '#frmNovaProp').val();
        arrayProposta['dsctrliq'] = $('#dsctrliq', '#frmNovaProp').val();
        arrayProposta['tpemprst'] = $('#tpemprst', '#frmNovaProp').val();
        arrayProposta['vlfinanc'] = $('#vlfinanc', '#frmNovaProp').val();

        flgimppr = arrayProposta['flgimppr'];
        flgimpnp = arrayProposta['flgimpnp'];

        tpemprst = arrayProposta['tpemprst'];
        cdtpempr = arrayProposta['cdtpempr'];
        dstpempr = arrayProposta['dstpempr'];
    }

    controlaOperacao(novaOp);
    glb_codigoOperadorLiberacao = '';
    return false;
}

function verificaDelecao() {

    var mtdRetorno = '';
    var aux_conta = 0;
    var aux_cpf = 0;
    var atual = 0;
    var novaOp = '';

    if (in_array(operacao, ['A_DADOS_AVAL', 'IA_DADOS_AVAL'])) {

        aux_conta = normalizaNumero($('#nrctaava', '#frmDadosAval').val());
        aux_cpf = normalizaNumero($('#nrcpfcgc', '#frmDadosAval').val());

        novaOp = (operacao == 'IA_DADOS_AVAL') ? 'I_DADOS_AVAL' : operacao;

        if (aux_conta == 0 && aux_cpf == 0) {
            mtdRetorno = 'deletaAvalista("' + novaOp + '")';
        }

    } else if (in_array(operacao, ['IA_ALIENACAO', 'A_ALIENACAO'])) {

        if (contAlienacao > 1 && $('#dscatbem', '#frmAlienacao').val() == '' && $('#dsbemfin', '#frmAlienacao').val() == '') {
                novaOp = (operacao == 'IA_ALIENACAO') ? 'I_ALIENACAO' : operacao;
                mtdRetorno = 'deletaAlienacao("' + novaOp + '");';
            }

    } else if (in_array(operacao, ['IA_INTEV_ANU', 'A_INTEV_ANU'])) {

        aux_conta = normalizaNumero($('#nrctaava', '#frmIntevAnuente').val());
        aux_cpf = normalizaNumero($('#nrcpfcgc', '#frmIntevAnuente').val());

        novaOp = (operacao == 'IA_INTEV_ANU') ? 'I_INTEV_ANU' : operacao;

        if (aux_conta == 0 && aux_cpf == 0) {
            mtdRetorno = 'deletaIntervente("' + novaOp + '");';
        }

    } else if (in_array(operacao, ['IA_HIPOTECA', 'A_HIPOTECA'])) {

        if ((typeof $('#dscatbem', '#frmHipoteca').val() == 'object') || ($('#dscatbem', '#frmHipoteca').val() == '')) {
            novaOp = (operacao == 'IA_HIPOTECA') ? 'I_HIPOTECA' : operacao;
            mtdRetorno = 'deletaHipoteca("' + novaOp + '");';
        }

    }

    return mtdRetorno;
}

function atualizaTela() {

    if (in_array(operacao, ['TI', 'TE', 'TC', 'TA', 'CF', 'A_NOVA_PROP', 'A_NUMERO', 'A_VALOR', 'A_AVALISTA', 'I_CONTRATO', 'I_FINALIZA', 'A_FINALIZA', 'A_INICIO', 'I_INICIO'])) {

        $('#nivrisco option:selected', '#frmNovaProp').val();
        $('#nivrisco', '#frmNovaProp').val(arrayProposta['nivriori'] != '' ? arrayProposta['nivriori'] : arrayProposta['nivrisco']);

        if (operacao == 'TI') {
            arrayProposta['dtdpagto'] = dtdpagt2;
        }
        $('#nivcalcu', '#frmNovaProp').val(arrayProposta['nivcalcu']);
        $('#vlemprst', '#frmNovaProp').val(arrayProposta['vlemprst']);
        $('#cdfinemp', '#frmNovaProp').val(arrayProposta['cdfinemp']);
        $('#cdlcremp', '#frmNovaProp').val(arrayProposta['cdlcremp']);
        $('#vlpreemp', '#frmNovaProp').val(arrayProposta['vlpreemp']);
        $('#tpemprst', '#frmNovaProp').val(arrayProposta['tpemprst']);
        $('#qtpreemp', '#frmNovaProp').val(arrayProposta['qtpreemp']);
        $('#idquapro', '#frmNovaProp').val(arrayProposta['idquapro']);
        $('#dsquapro', '#frmNovaProp').val(arrayProposta['dsquapro']);
        $('#flgpagto', '#frmNovaProp').val(arrayProposta['flgpagto']);
        $('#percetop', '#frmNovaProp').val(arrayProposta['percetop']);
        $('#qtdialib', '#frmNovaProp').val(arrayProposta['qtdialib']);
        $('#dtdpagto', '#frmNovaProp').val(arrayProposta['dtdpagto']);
        $('#flgimppr', '#frmNovaProp').val(arrayProposta['flgimppr']);
        $('#flgimpnp', '#frmNovaProp').val(arrayProposta['flgimpnp']);
        $('#dsctrliq', '#frmNovaProp').val(arrayProposta['dsctrliq']);
        $('#dslcremp', '#frmNovaProp').val(arrayProposta['dslcremp']);
        $('#dsfinemp', '#frmNovaProp').val(arrayProposta['dsfinemp']);
        $('#dtlibera', '#frmNovaProp').val(arrayProposta['dtlibera']);
        $('#idfiniof', '#frmNovaProp').val(arrayProposta['idfiniof']);
        $('#vliofepr', '#frmNovaProp').val(arrayProposta['vliofepr']);
        $('#vlrtarif', '#frmNovaProp').val(arrayProposta['vlrtarif']);
        $('#vlrtotal', '#frmNovaProp').val(arrayProposta['vlrtotal']);
        $('#idcarenc', '#frmNovaProp').val(arrayProposta['idcarenc']);
        $('#dtcarenc', '#frmNovaProp').val(arrayProposta['dtcarenc']);
		$('#vlfinanc', '#frmNovaProp').val(arrayProposta['vlfinanc']);        

        if (operacao == 'TI') {

            // Quando Price Pre-Fixado e Debitar em Folha alterar para Debitar em  Conta
            if (arrayProposta['tpemprst'] == 1 && arrayProposta['flgpagto'] == 'yes') {
                // 0 - Price TR   1 - Price Pre-Fixado
                // no - Conta   yes - Folha

                $('#flgpagto', '#frmNovaProp').val('no');
            }
        }

    } else if (in_array(operacao, ['E_COMITE_APROV', 'C_COMITE_APROV', 'I_COMITE_APROV', 'A_COMITE_APROV'])) {

        $('#dsobscmt', '#frmComiteAprov').val(arrayProposta['dsobscmt']);
        $('#dsobserv', '#frmComiteAprov').val(arrayProposta['dsobserv']);

    } else if (in_array(operacao, ['C_DADOS_PROP_PJ', 'A_DADOS_PROP_PJ', 'I_DADOS_PROP_PJ'])) {

        $('#vlmedfat', '#frmDadosPropPj').val(arrayRendimento['vlmedfat']);
        $('#perfatcl', '#frmDadosPropPj').val(arrayRendimento['perfatcl']);
        $('#vlalugue', '#frmDadosPropPj').val(arrayRendimento['vlalugue']);

    } else if (in_array(operacao, ['C_DADOS_PROP', 'A_DADOS_PROP', 'I_DADOS_PROP'])) {

        for (var i = 1; i <= contRend; i++) {
            $('#tpdrend' + i, '#frmDadosProp').val(arrayRendimento['tpdrend' + i]);
            $('#dsdrend' + i, '#frmDadosProp').val(arrayRendimento['dsdrend' + i]);
            $('#vldrend' + i, '#frmDadosProp').val(arrayRendimento['vldrend' + i]);
        }

        $('#vlsalari', '#frmDadosProp').val(arrayRendimento['vlsalari']);
        $('#vlsalcon', '#frmDadosProp').val(arrayRendimento['vlsalcon']);
        $('#nmextemp', '#frmDadosProp').val(arrayRendimento['nmextemp']);
        $('#perfatcl', '#frmDadosProp').val(arrayRendimento['perfatcl']);
        $('#vlmedfat', '#frmDadosProp').val(arrayRendimento['vlmedfat']);
        $('#inpessoa', '#frmDadosProp').val(arrayRendimento['inpessoa']);
        $('#flgconju', '#frmDadosProp').val(arrayRendimento['flgconju']);
        if (arrayRendimento['flgdocje'] == 'yes') {
            $('#flgYes', '#frmDadosProp').prop('checked', true);
        } else {
            $('#flgNo', '#frmDadosProp').prop('checked', true);
        }
        $('#vloutras', '#frmDadosProp').val(arrayRendimento['vloutras']);
        $('#vlalugue', '#frmDadosProp').val(arrayRendimento['vlalugue']);
        $('#dsjusren', '#frmDadosProp').val(arrayRendimento['dsjusren']);

        $('#nrctacje', '#frmDadosProp').val(arrayAssociado['nrctacje']);
        $('#nrcpfcjg', '#frmDadosProp').val(arrayAssociado['nrcpfcjg']);

        if (arrayRendimento['inconcje'] == 'yes') {
            $('#inconcje_1', '#frmDadosProp').prop('checked', true);
        }
        else {
            $('#inconcje_2', '#frmDadosProp').prop('checked', true);
        }

    } else if (in_array(operacao, ['C_DADOS_AVAL', 'A_DADOS_AVAL', 'IA_DADOS_AVAL'])) {

        $('#nrctaava', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['nrctaava']);
        $('#cdnacion', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['cdnacion']);
        $('#dsnacion', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['dsnacion']);
        $('#tpdocava', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['tpdocava']);
        $('#nmconjug', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['nmconjug']);
        $('#tpdoccjg', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['tpdoccjg']);
        $('#dsendre1', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['dsendre1']);
        $('#nrfonres', '#frmDadosAval').val(telefone(arrayAvalistas[contAvalistas]['nrfonres']));
        $('#nmcidade', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['nmcidade']);
        $('#nrcepend', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['nrcepend']);
        $('#nmdavali', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['nmdavali']);
        $('#nrcpfcgc', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['nrcpfcgc']);
        $('#nrdocava', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['nrdocava']);
        $('#nrcpfcjg', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['nrcpfcjg']);
        $('#nrdoccjg', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['nrdoccjg']);
        $('#dsendre2', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['dsendre2']);
        $('#dsdemail', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['dsdemail']);
        $('#cdufresd', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['cdufresd']);
        $('#vlrenmes', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['vlrenmes']);
        $('#vledvmto', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['vledvmto']);

        $('#inpessoa', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['inpessoa']);
        $('#dtnascto', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['dtnascto']);

        //Campos projeto CEP
        $('#nrendere', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['nrendere']);
        $('#complend', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['complend']);
        $('#nrcxapst', '#frmDadosAval').val(arrayAvalistas[contAvalistas]['nrcxapst']);

        $('#qtpromis', '#frmDadosAval').val(arrayProposta['qtpromis']);

        contAvalistas++;

        $('legend:first', '#frmDadosAval').html('Dados dos Avalistas/Fiadores ' + contAvalistas);

    } else if (in_array(operacao, ['C_ALIENACAO', 'A_ALIENACAO', 'IA_ALIENACAO'])) {

        strSelect(lscatbem, 'dscatbem', 'frmAlienacao');

        $('#dscatbem', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['dscatbem']);
        $('#dstipbem', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['dstipbem']);
        $('#dsbemfin', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['dsbemfin']);
        $('#dscorbem', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['dscorbem']);
        $('#dschassi', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['dschassi']);
        $('#nranobem', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['nranobem']);
        $('#nrmodbem', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['nrmodbem']);
        $('#nrdplaca', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['nrdplaca']);
        $('#nrrenava', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['nrrenava']);
        $('#tpchassi', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['tpchassi']);
        $('#ufdplaca', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['ufdplaca']);
        $('#nrcpfbem', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['nrcpfbem']);
        $('#dscpfbem', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['dscpfbem']);
        $('#vlmerbem', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['vlmerbem']);
        $('#idalibem', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['idalibem']);
        $('#uflicenc', '#frmAlienacao').val(arrayAlienacoes[contAlienacao]['uflicenc']); //GRAVAMES */
        $('#lsbemfin', '#frmAlienacao').html(arrayAlienacoes[contAlienacao]['lsbemfin']);

        if (arrayAlienacoes[contAlienacao]['dstipbem'] == 'ZERO KM') {
            $('#ufdplaca', '#frmAlienacao').val('').desabilitaCampo();
            $('#nrdplaca', '#frmAlienacao').val('').desabilitaCampo();
            $('#nrrenava', '#frmAlienacao').val('').desabilitaCampo();
        }

        idseqbem = arrayAlienacoes[contAlienacao]['idseqbem'];

        contAlienacao++;

    } else if (in_array(operacao, ['C_INTEV_ANU', 'A_INTEV_ANU', 'IA_INTEV_ANU'])) {

        $('#nrctaava', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['nrctaava']);
        $('#cdnacion', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['cdnacion']);
        $('#dsnacion', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['dsnacion']);
        $('#tpdocava', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['tpdocava']);
        $('#nmconjug', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['nmconjug']);
        $('#tpdoccjg', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['tpdoccjg']);
        $('#dsendre1', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['dsendre1']);
        $('#nrfonres', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['nrfonres']);
        $('#nmcidade', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['nmcidade']);
        $('#nrcepend', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['nrcepend']);
        $('#nmdavali', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['nmdavali']);
        $('#nrcpfcgc', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['nrcpfcgc']);
        $('#nrdocava', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['nrdocava']);
        $('#nrcpfcjg', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['nrcpfcjg']);
        $('#nrdoccjg', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['nrdoccjg']);
        $('#dsendre2', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['dsendre2']);
        $('#dsdemail', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['dsdemail']);
        $('#cdufresd', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['cdufresd']);
        //Campos projeto CEP
        $('#nrendere', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['nrendere']);
        $('#complend', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['complend']);
        $('#nrcxapst', '#frmIntevAnuente').val(arrayIntervs[contIntervis]['nrcxapst']);

        contIntervis++;

        $('legend:first', '#frmIntevAnuente').html('Dados do Interveniente Anuente ' + contIntervis);

    } else if (in_array(operacao, ['C_PROT_CRED', 'A_PROT_CRED', 'I_PROT_CRED'])) {
        /* Projeto Cessao de Credito */
        if ((in_array(operacao, ['A_PROT_CRED', 'I_PROT_CRED'])) && (aDadosPropostaFinalidade['flgcescr'])) {
            $('#nrperger', '#frmOrgProtCred').val(aDadosPropostaFinalidade['nrperger']);
            $('#dsperger', '#frmOrgProtCred').val(aDadosPropostaFinalidade['dsperger']);
            $('#nrinfcad', '#frmOrgProtCred').val(aDadosPropostaFinalidade['nrinfcad']);
            $('#dsinfcad', '#frmOrgProtCred').val(aDadosPropostaFinalidade['dsinfcad']);
            $('#nrliquid', '#frmOrgProtCred').val(aDadosPropostaFinalidade['nrliquid']);
            $('#dsliquid', '#frmOrgProtCred').val(aDadosPropostaFinalidade['dsliquid']);
            $('#nrpatlvr', '#frmOrgProtCred').val(aDadosPropostaFinalidade['nrpatlvr']);
            $('#dspatlvr', '#frmOrgProtCred').val(aDadosPropostaFinalidade['dspatlvr']);
            $('#nrgarope', '#frmOrgProtCred').val(aDadosPropostaFinalidade['nrgarope']);
            $('#dsgarope', '#frmOrgProtCred').val(aDadosPropostaFinalidade['dsgarope']);

        } else {
            $('#nrperger', '#frmOrgProtCred').val(arrayProtCred['nrperger']);
            $('#dsperger', '#frmOrgProtCred').val(arrayProtCred['dsperger']);
            $('#nrinfcad', '#frmOrgProtCred').val(arrayProtCred['nrinfcad']);
            $('#dsinfcad', '#frmOrgProtCred').val(arrayProtCred['dsinfcad']);
            $('#nrliquid', '#frmOrgProtCred').val(arrayProtCred['nrliquid']);
            $('#dsliquid', '#frmOrgProtCred').val(arrayProtCred['dsliquid']);
            $('#nrpatlvr', '#frmOrgProtCred').val(arrayProtCred['nrpatlvr']);
            $('#dspatlvr', '#frmOrgProtCred').val(arrayProtCred['dspatlvr']);
            $('#nrgarope', '#frmOrgProtCred').val(arrayProtCred['nrgarope']);
            $('#dsgarope', '#frmOrgProtCred').val(arrayProtCred['dsgarope']);
        }

        $('#dtcnsspc', '#frmOrgProtCred').val(arrayProtCred['dtcnsspc']);
        $('#dtdrisco', '#frmOrgProtCred').val(arrayProtCred['dtdrisco']);
        $('#vltotsfn', '#frmOrgProtCred').val(arrayProtCred['vltotsfn']);
        $('#qtopescr', '#frmOrgProtCred').val(arrayProtCred['qtopescr']);
        $('#qtifoper', '#frmOrgProtCred').val(arrayProtCred['qtifoper']);
        $('#vlopescr', '#frmOrgProtCred').val(arrayProtCred['vlopescr']);
        $('#vlrpreju', '#frmOrgProtCred').val(arrayProtCred['vlrpreju']);
        $('#dtoutspc', '#frmOrgProtCred').val(arrayProtCred['dtoutspc']);
        $('#dtoutris', '#frmOrgProtCred').val(arrayProtCred['dtoutris']);
        $('#vlsfnout', '#frmOrgProtCred').val(arrayProtCred['vlsfnout']);
        $('#flgcentr', '#frmOrgProtCred').val(arrayProtCred['flgcentr']);
        $('#flgcoout', '#frmOrgProtCred').val(arrayProtCred['flgcoout']);

    } else if (in_array(operacao, ['C_HIPOTECA', 'A_HIPOTECA', 'IA_HIPOTECA'])) {

        $('#lsbemfin', '#frmHipoteca').html(arrayHipotecas[contHipotecas]['lsbemfin']);

        strSelect(lscathip, 'dscatbem', 'frmHipoteca');

        $('#dscatbem', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['dscatbem']);
        $('#dsbemfin', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['dsbemfin']);
        $('#dscorbem', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['dscorbem']);
        $('#idseqhip', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['idseqhip']);
        $('#vlmerbem', '#frmHipoteca').val(arrayHipotecas[contHipotecas]['vlmerbem']);

        contHipotecas++;

    } else if (in_array(operacao, ['I_DEMONSTRATIVO_EMPRESTIMO', 'A_DEMONSTRATIVO_EMPRESTIMO'])) {
        $('#vliofepr', '#frmDemonstracaoEmprestimo').val(arrayProposta['vliofepr']);
        $('#vlrtarif', '#frmDemonstracaoEmprestimo').val(arrayProposta['vlrtarif']);
        $('#vlrtotal', '#frmDemonstracaoEmprestimo').val(arrayProposta['vlrtotal']);
        $('#percetop', '#frmDemonstracaoEmprestimo').val(arrayProposta['percetop']);
        $('#vlemprst', '#frmDemonstracaoEmprestimo').val(arrayProposta['vlemprst']);
        $('#vlpreemp', '#frmDemonstracaoEmprestimo').val(arrayProposta['vlpreemp']);
    }

    return false;

}

function exibeAguardo(mensagem, metodo, tempo) {

    showMsgAguardo(mensagem);

    setTimeout(metodo, tempo);

    return false;
}

function insereAvalista(OpContinua) {

    var novaOp = '';

    var aux_conta = normalizaNumero($('#nrctaava', '#frmDadosAval').val());
    var aux_cpf = normalizaNumero($('#nrcpfcgc', '#frmDadosAval').val());
    var aux_nome = normalizaNumero($("#nmdavali", "#frmDadosAval").val());

    if (!validaDadosAval()) {
        return false;
    }

    i = arrayAvalistas.length;

    if (aux_conta == 0 && aux_cpf == 0) {
        if (nomeAcaoCall == 'A_AVALISTA') {
            controlaOperacao('F_AVALISTA');
        } else {
        controlaOperacao(OpContinua);
        }
        return false;
    }

    eval('var arrayAvalista' + i + ' = new Object();');
    eval('arrayAvalista' + i + '["nrctaava"] = $("#nrctaava","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["cdnacion"] = $("#cdnacion","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["dsnacion"] = $("#dsnacion","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["tpdocava"] = $("#tpdocava","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["nmconjug"] = $("#nmconjug","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["tpdoccjg"] = $("#tpdoccjg","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["dsendre1"] = $("#dsendre1","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["nrfonres"] = $("#nrfonres","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["nmcidade"] = $("#nmcidade","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["nrcepend"] = $("#nrcepend","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["nmdavali"] = $("#nmdavali","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["nrcpfcgc"] = $("#nrcpfcgc","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["nrdocava"] = $("#nrdocava","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["nrcpfcjg"] = $("#nrcpfcjg","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["nrdoccjg"] = $("#nrdoccjg","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["dsendre2"] = $("#dsendre2","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["dsdemail"] = $("#dsdemail","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["cdufresd"] = $("#cdufresd","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["vlrenmes"] = $("#vlrenmes","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["vledvmto"] = $("#vledvmto","#frmDadosAval").val();');

    eval('arrayAvalista' + i + '["nrendere"] = $("#nrendere","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["complend"] = $("#complend","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["nrcxapst"] = $("#nrcxapst","#frmDadosAval").val();');

    // Daniel
    eval('arrayAvalista' + i + '["inpessoa"] = $("#inpessoa","#frmDadosAval").val();');
    eval('arrayAvalista' + i + '["dtnascto"] = $("#dtnascto","#frmDadosAval").val();');

    eval('var arrayBensAval' + i + ' = new Array();');

    eval('arrayAvalista' + i + '["bensaval"] = arrayBensAval' + i + ';');

    for (j in arrayBemBusca) {

        eval('var arrayAux' + j + ' = new Object();');
        for (campo in arrayBemBusca[j]) {
            eval('arrayAux' + j + '[\'' + campo + '\']= arrayBemBusca[' + j + '][\'' + campo + '\'];');
        }
        eval('arrayAvalista' + i + '["bensaval"][' + j + '] = arrayAux' + j + ';');
    }

    eval('arrayAvalistas[' + i + '] = arrayAvalista' + i + ';');

    nrAvalistas++;
    contAvalistas++;

    if (operacao == 'AI_DADOS_AVAL') {
        novaOp = 'A_BENS_ASSOC';
    } else {
        novaOp = 'I_BENS_ASSOC';
    }

    controlaOperacao(novaOp);
    return false;

}

function deletaAvalista(operacao) {

    var atual = contAvalistas - 1;

    arrayAvalistas.splice(atual, 1);

    nrAvalistas--;
    contAvalistas--;

    controlaOperacao(operacao);

    return false;
}

function insereAlienacao(operacao, opContinua) {

    idseqbem = 0;

    // Alteracao 069
    $('#dsbemfin', '#frmAlienacao').val(retiraCaracteres($('#dsbemfin', '#frmAlienacao').val(), "'|;", false));

    if (((typeof $('#dscatbem', '#frmAlienacao').val() == 'object') || $('#dscatbem', '#frmAlienacao').val() == '') &&
            $('#dsbemfin', '#frmAlienacao').val() == '')
    {
        controlaOperacao(opContinua);
        return false;
    }

    i = arrayAlienacoes.length;

    eval('var arrayAlienacao' + i + ' = new Object();');
    eval('arrayAlienacao' + i + '["dscatbem"] = $("#dscatbem","#frmAlienacao").val();');
    eval('arrayAlienacao' + i + '["dstipbem"] = $("#dstipbem","#frmAlienacao").val();');
    eval('arrayAlienacao' + i + '["dsbemfin"] = removeAcentos(removeCaracteresInvalidos($("#dsbemfin","#frmAlienacao").val().replace("<","").replace(">","")));');
    eval('arrayAlienacao' + i + '["dscorbem"] = removeAcentos(removeCaracteresInvalidos($("#dscorbem","#frmAlienacao").val().replace("<","").replace(">","")));');
    eval('arrayAlienacao' + i + '["dschassi"] = $("#dschassi","#frmAlienacao").val();');
    eval('arrayAlienacao' + i + '["nranobem"] = $("#nranobem","#frmAlienacao").val();');
    eval('arrayAlienacao' + i + '["nrmodbem"] = $("#nrmodbem","#frmAlienacao").val();');
    eval('arrayAlienacao' + i + '["nrdplaca"] = $("#nrdplaca","#frmAlienacao").val();');
    eval('arrayAlienacao' + i + '["nrrenava"] = $("#nrrenava","#frmAlienacao").val();');
    eval('arrayAlienacao' + i + '["tpchassi"] = $("#tpchassi","#frmAlienacao").val();');
    eval('arrayAlienacao' + i + '["ufdplaca"] = $("#ufdplaca","#frmAlienacao").val();');
    eval('arrayAlienacao' + i + '["nrcpfbem"] = $("#nrcpfbem","#frmAlienacao").val();');
    eval('arrayAlienacao' + i + '["dscpfbem"] = $("#dscpfbem","#frmAlienacao").val();');
    eval('arrayAlienacao' + i + '["vlmerbem"] = $("#vlmerbem","#frmAlienacao").val();');
    eval('arrayAlienacao' + i + '["uflicenc"] = $("#uflicenc","#frmAlienacao").val();'); // GRAVAMES*/
    eval('arrayAlienacao' + i + '["idseqbem"] = ' + idseqbem + ';');
    eval('arrayAlienacao' + i + '["idalibem"] = "";');
    eval('arrayAlienacao' + i + '["lsbemfin"] = "";');
    eval('arrayAlienacao' + i + '["cdcoplib"] = "' + glb_codigoOperadorLiberacao + '";');

    eval('arrayAlienacoes[' + i + '] = arrayAlienacao' + i + ';');

    nrAlienacao++;
    contAlienacao++;

    arrayAlienacoes[i]["lsbemfin"] = '( ' + contAlienacao + ' Bem )';

    controlaOperacao(operacao);
    glb_codigoOperadorLiberacao = '';
    return false;

}

function deletaAlienacao(operacao) {

    var atual = contAlienacao - 1;

    arrayAlienacoes.splice(atual, 1);

    nrAlienacao--;
    contAlienacao--;

    controlaOperacao(operacao);

    return false;
}

function insereHipoteca(operacao, opContinua) {

	var opContinua = opContinua || '';

    if ((typeof $('#dscatbem', '#frmHipoteca').val() == 'object') || ($('#dscatbem', '#frmHipoteca').val() == '')) {
        controlaOperacao(opContinua);
        return false;
    }

    i = arrayHipotecas.length;

    eval('var arrayHipoteca' + i + ' = new Object();');
    eval('arrayHipoteca' + i + '["dscatbem"] = $("#dscatbem","#frmHipoteca").val();');
    eval('arrayHipoteca' + i + '["dsbemfin"] = removeCaracteresInvalidos($("#dsbemfin","#frmHipoteca").val(), true);');
    eval('arrayHipoteca' + i + '["dscorbem"] = removeCaracteresInvalidos($("#dscorbem","#frmHipoteca").val(), true);');
    eval('arrayHipoteca' + i + '["idseqhip"] = $("#idseqhip","#frmHipoteca").val();');
    eval('arrayHipoteca' + i + '["vlmerbem"] = $("#vlmerbem","#frmHipoteca").val();');
    eval('arrayHipoteca' + i + '["lsbemfin"] = "";');

    eval('arrayHipotecas[' + i + '] = arrayHipoteca' + i + ';');

    nrHipotecas++;
    contHipotecas++;

    controlaOperacao(operacao);
    return false;
}

function deletaHipoteca(operacao) {

    var atual = contHipotecas - 1;

    arrayHipotecas.splice(atual, 1);

    nrHipotecas--;
    contHipotecas--;

    controlaOperacao(operacao);

    return false;
}

function insereIntervente(operacao, opContinua) {

    var conta = normalizaNumero($('#nrctaava', '#frmIntevAnuente').val());
    var cpf = normalizaNumero($('#nrcpfcgc', '#frmIntevAnuente').val());

    if (conta == 0 && cpf == 0) {
        controlaOperacao(opContinua);
        return false;
    }

    if (!validaDadosInterv()) {
        return false;
    }

    i = arrayIntervs.length;

    eval('var arrayInterv' + i + ' = new Object();');
    eval('arrayInterv' + i + '["nrctaava"] = $("#nrctaava","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["cdnacion"] = $("#cdnacion","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["dsnacion"] = $("#dsnacion","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["tpdocava"] = $("#tpdocava","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["nmconjug"] = $("#nmconjug","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["tpdoccjg"] = $("#tpdoccjg","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["dsendre1"] = $("#dsendre1","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["nrfonres"] = $("#nrfonres","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["nmcidade"] = $("#nmcidade","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["nrcepend"] = $("#nrcepend","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["nmdavali"] = $("#nmdavali","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["nrcpfcgc"] = $("#nrcpfcgc","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["nrdocava"] = $("#nrdocava","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["nrcpfcjg"] = $("#nrcpfcjg","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["nrdoccjg"] = $("#nrdoccjg","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["dsendre2"] = $("#dsendre2","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["dsdemail"] = $("#dsdemail","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["cdufresd"] = $("#cdufresd","#frmIntevAnuente").val();');
    eval('arrayInterv' + i + '["complend"] = $("#complend","#frmIntevAnuente").val();');

    eval('arrayIntervs[' + i + '] = arrayInterv' + i + ';');

    nrIntervis++;
    contIntervis++;

    controlaOperacao(operacao);
    return false;

}

function deletaIntervente(operacao) {

    var atual = contIntervis - 1;

    arrayIntervs.splice(atual, 1);

    nrIntervis--;
    contIntervis--;

    controlaOperacao(operacao);

    return false;
}

function initArrayBens(operacao) {

    arrayBensAssoc.length = 0;

    if (operacao == 'A_BENS_ASSOC' || operacao == 'I_BENS_ASSOC') {

        var atual = contAvalistas - 1;

        for (i in arrayAvalistas[atual]['bensaval']) {
            eval('var arrayAux' + i + ' = new Object();');
            for (campo in arrayAvalistas[atual]['bensaval'][i]) {
                eval('arrayAux' + i + '[\'' + campo + '\']= arrayAvalistas[' + atual + '][\'bensaval\'][' + i + '][\'' + campo + '\'];');
            }
            eval('arrayBensAssoc[' + i + '] = arrayAux' + i + ';');
        }

        bemnrdconta = normalizaNumero(arrayAvalistas[atual]['nrctaava']);
        bemnrcpfcgc = normalizaNumero(arrayAvalistas[atual]['nrcpfcgc']);

    } else if (operacao == 'A_BENS_TITULAR' || operacao == 'I_BENS_TITULAR' || operacao == 'C_BENS_ASSOC') {

        for (i in arrayBensAss) {
            eval('var arrayAux' + i + ' = new Object();');
            for (campo in arrayBensAss[0]) {
                eval('arrayAux' + i + '[\'' + campo + '\']= arrayBensAss[' + i + '][\'' + campo + '\'];');
            }
            eval('arrayBensAssoc[' + i + '] = arrayAux' + i + ';');
        }

        bemnrdconta = nrdconta;
        bemnrcpfcgc = 0;

    }

    return false;
}

function sincronizaArrayBens() {

    if (in_array(operacao, ['AI_DADOS_AVAL', 'A_DADOS_AVAL', 'I_DADOS_AVAL', 'IA_DADOS_AVAL'])) {

        var atual = contAvalistas - 1;

        arrayAvalistas[atual]['bensaval'].length = 0;

        for (i in arrayBensAssoc) {

            eval('var arrayAux' + i + ' = new Object();');
            for (campo in arrayBensAssoc[i]) {
                eval('arrayAux' + i + '[\'' + campo + '\']= arrayBensAssoc[' + i + '][\'' + campo + '\'];');
            }
            eval('arrayAvalistas[' + atual + '][\'bensaval\'][' + i + '] = arrayAux' + i + ';');
        }

    } else if (in_array(operacao, ['A_DADOS_PROP', 'A_DADOS_PROP_PJ', 'I_DADOS_PROP', 'I_PROTECAO_TIT_PJ'])) {

        arrayBensAss.length = 0;

        for (i in arrayBensAssoc) {
            eval('var arrayAux' + i + ' = new Object();');
            for (campo in arrayBensAssoc[i]) {
                eval('arrayAux' + i + '[\'' + campo + '\']= arrayBensAssoc[' + i + '][\'' + campo + '\'];');
            }
            eval('arrayBensAss[' + i + '] = arrayAux' + i + ';');
        }

    }

    return false;
}

function Busca_Associado(nrctaava, nrcpfcgc, indxaval) {

    var fonteBusca = '';

    if (operacao == 'A_DADOS_AVAL' || operacao == 'AI_DADOS_AVAL' || operacao == 'I_DADOS_AVAL' || operacao == 'IA_DADOS_AVAL') {
        fonteBusca = 'busca_avalista.php';
    } else if (operacao == 'A_INTEV_ANU' || operacao == 'AI_INTEV_ANU' || operacao == 'I_INTEV_ANU' || operacao == 'IA_INTEV_ANU') {
        fonteBusca = 'busca_intervente.php';
    }


    showMsgAguardo('Aguarde, buscando dados...');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/emprestimos/' + fonteBusca,
        data: {
            nrdconta: nrdconta, idseqttl: idseqttl,
            nrctaava: nrctaava, nrcpfcgc: nrcpfcgc,
            indxaval: indxaval, operacao: operacao,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {

                if (response.indexOf('showError("error"') == -1) {
                    eval(response);

                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);

                    verificaBusca();
                } else {
                    hideMsgAguardo();
                    eval(response);
                }


                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });

    return false;

}

function verificaBusca() {

    if (operacao == 'A_DADOS_AVAL' || operacao == 'AI_DADOS_AVAL' || operacao == 'I_DADOS_AVAL' || operacao == 'IA_DADOS_AVAL') {
        if (arrayFiadores.length > 0) {
            mostraTabelaFiadores(operacao);
        } else {
            carregaBusca();
        }
    } else if (operacao == 'A_INTEV_ANU' || operacao == 'AI_INTEV_ANU' || operacao == 'I_INTEV_ANU' || operacao == 'IA_INTEV_ANU') {
        carregaBusca();
    }
    return false;
}

function carregaBusca() {

    var atual = contAvalistas - 1;
    var formBusca = '';

    if (operacao == 'A_DADOS_AVAL' || operacao == 'AI_DADOS_AVAL' || operacao == 'I_DADOS_AVAL' || operacao == 'IA_DADOS_AVAL') {
        formBusca = 'frmDadosAval';

        if (operacao == 'A_DADOS_AVAL' || operacao == 'IA_DADOS_AVAL') {

            arrayAvalistas[atual]['bensaval'].length = 0;

            for (i in arrayBemBusca) {

                eval('var arrayAux' + i + ' = new Object();');
                for (campo in arrayBemBusca[i]) {
                    eval('arrayAux' + i + '[\'' + campo + '\']= arrayBemBusca[' + i + '][\'' + campo + '\'];');
                }
                eval('arrayAvalistas[' + atual + '][\'bensaval\'][' + i + '] = arrayAux' + i + ';');
            }
        }

    } else if (operacao == 'A_INTEV_ANU' || operacao == 'AI_INTEV_ANU' || operacao == 'I_INTEV_ANU' || operacao == 'IA_INTEV_ANU') {
        formBusca = 'frmIntevAnuente';
    }

    if (formBusca != '') {

        $('#nrctaava', '#' + formBusca).val(arrayAvalBusca['nrctaava']);
        $('#cdnacion', '#' + formBusca).val(arrayAvalBusca['cdnacion']);
        $('#dsnacion', '#' + formBusca).val(arrayAvalBusca['dsnacion']);
        $('#tpdocava', '#' + formBusca).val(arrayAvalBusca['tpdocava']);
        $('#nmconjug', '#' + formBusca).val(arrayAvalBusca['nmconjug']);
        $('#tpdoccjg', '#' + formBusca).val(arrayAvalBusca['tpdoccjg']);
        $('#dsendre1', '#' + formBusca).val(arrayAvalBusca['dsendre1']);
        $('#nrfonres', '#' + formBusca).val(telefone(arrayAvalBusca['nrfonres']));
        $('#nmcidade', '#' + formBusca).val(arrayAvalBusca['nmcidade']);
        $('#nrcepend', '#' + formBusca).val(arrayAvalBusca['nrcepend']);
        $('#nmdavali', '#' + formBusca).val(arrayAvalBusca['nmdavali']);
        $('#nrcpfcgc', '#' + formBusca).val(arrayAvalBusca['nrcpfcgc']);
        $('#nrdocava', '#' + formBusca).val(arrayAvalBusca['nrdocava']);
        $('#nrcpfcjg', '#' + formBusca).val(arrayAvalBusca['nrcpfcjg']);
        $('#nrdoccjg', '#' + formBusca).val(arrayAvalBusca['nrdoccjg']);
        $('#dsendre2', '#' + formBusca).val(arrayAvalBusca['dsendre2']);
        $('#dsdemail', '#' + formBusca).val(arrayAvalBusca['dsdemail']);
        $('#cdufresd', '#' + formBusca).val(arrayAvalBusca['cdufresd']);
        $('#vlrenmes', '#' + formBusca).val(arrayAvalBusca['vlrenmes']);
        $('#vledvmto', '#' + formBusca).val(arrayAvalBusca['vledvmto']);
        $('#nrendere', '#' + formBusca).val(arrayAvalBusca['nrendere']);
        $('#complend', '#' + formBusca).val(arrayAvalBusca['complend']);
        $('#nrcxapst', '#' + formBusca).val(arrayAvalBusca['nrcxapst']);

        // Daniel
        $('#inpessoa', '#' + formBusca).val(arrayAvalBusca['inpessoa']);
        $('#dtnascto', '#' + formBusca).val(arrayAvalBusca['dtnascto']);

        if (normalizaNumero($('#nrctaava', '#' + formBusca).val()) != 0) {
            $('select,input', '#' + formBusca + ' fieldset').desabilitaCampo();
        }
        $('#nrctaava', '#' + formBusca).habilitaCampo().focus();

    }

    $('input', '#' + formBusca).trigger('blur');

    return false;
}

function limpaDivGenerica() {

    $('#tbfiador').remove();
    $('#buscaObs').remove();
    $('#contrato').remove();
    $('#valores').remove();
    $('#numero').remove();
    $('#tbbens').remove();
    $('#altera').remove();
    $('#tbfat').remove();
    $('#tdImp').remove();
    $('#tbliq').remove();
    $('#tdNP').remove();

    return false;
}

function validaDadosGerais() {

    var cdlcremp = $('#cdlcremp', '#frmNovaProp').val();
    var qtpreemp = $('#qtpreemp', '#frmNovaProp').val();
    var dsctrliq = $('#dsctrliq', '#frmNovaProp').val();
    var vlemprst = $('#vlemprst', '#frmNovaProp').val();
    var dtdpagto = $('#dtdpagto', '#frmNovaProp').val();
    var flgpagto = $('#flgpagto', '#frmNovaProp').val();
    var cdfinemp = $('#cdfinemp', '#frmNovaProp').val();
    var qtdialib = $('#qtdialib', '#frmNovaProp').val();
    var tpemprst = $('#tpemprst', '#frmNovaProp').val();
    var dtlibera = $('#dtlibera', '#frmNovaProp').val();
    var percetop = $('#percetop', '#frmNovaProp').val();
    var tpfinali = $("#frmNovaprop #tpfinali").val();
    var idcarenc = $('#idcarenc', '#frmNovaProp').val();
    var dtcarenc = $('#dtcarenc', '#frmNovaProp').val();
    var idfiniof = $('#idfiniof', '#frmNovaProp').val();

    var tpaltera = (operacao == 'A_VALOR') ? '2' : '1';

    var cdempres = arrayAssociado['cdempres'];
    var cdageass = arrayAssociado['cdagenci'];
    var inmatric = arrayAssociado['inmatric'];

    var vlmaxutl = arrayCooperativa['vlmaxutl'];
    var vlmaxleg = arrayCooperativa['vlmaxleg'];
    var vlcnsscr = arrayCooperativa['vlcnsscr'];

    if (possuiPortabilidade == "S")
        var cdmodali = arrayDadosPortabilidade['cdmodali'];
    else
        var cdmodali = "0";

    vlemprst = number_format(parseFloat(vlemprst.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');

    //consiste o cadastro da finalidade de portabilidade para propostas de emprestimos
    if (typeof arrayDadosPortabilidade['nrcnpjbase_if_origem'] == 'undefined' &&
            typeof arrayDadosPortabilidade['nrcontrato_if_origem'] == 'undefined' &&
            typeof arrayDadosPortabilidade['nmif_origem'] == 'undefined' &&
            tpfinali == "2") //finalidade de portabilidade
    {
        hideMsgAguardo();
        showError('error', 'Finalidade não permitida para este tipo de proposta.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina)");
        return false;
    }

    var aux_retorno = false;

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        async: false,
        url: UrlSite + 'telas/atenda/emprestimos/valida_dados_gerais.php',
        data: {
            nrdconta: nrdconta, idseqttl: idseqttl,
            nrctremp: nrctremp, cdageass: cdageass,
            cdlcremp: cdlcremp, qtpreemp: qtpreemp,
            dsctrliq: dsctrliq, vlmaxutl: vlmaxutl,
            vlmaxleg: vlmaxleg, vlcnsscr: vlcnsscr,
            vlemprst: vlemprst, dtdpagto: dtdpagto,
            inconfir: inconfir, tpaltera: tpaltera,
            cdempres: cdempres, flgpagto: flgpagto,
            dtdpagt2: dtdpagt2, ddmesnov: ddmesnov,
            cdfinemp: cdfinemp, qtdialib: qtdialib,
            inmatric: inmatric, operacao: operacao,
            tpemprst: tpemprst, dtlibera: dtlibera,
            inconfi2: inconfi2, percetop: percetop,
            cdmodali: cdmodali, idcarenc: idcarenc,
            dtcarenc: dtcarenc, idfiniof: idfiniof,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            aux_retorno = false;
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {

            try {

                if (response.indexOf('showError("error"') == -1) {
                    aux_retorno = true;
                    eval(response);

                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);

                } else {
                    aux_retorno = false;
                    hideMsgAguardo();
                    eval(response);


                }

            } catch (error) {
                aux_retorno = false;
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });

    return aux_retorno;
}

function validaDadosAval() {

    $('input,select', '#' + nomeForm).removeClass('campoErro');

    var qtpromis = $('#qtpromis', '#frmDadosAval').val();
    var nmdavali = $('#nmdavali', '#frmDadosAval').val();
    var nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#frmDadosAval').val());
    var nrctaava = normalizaNumero($('#nrctaava', '#frmDadosAval').val());
    var nrcpfcjg = normalizaNumero($('#nrcpfcjg', '#frmDadosAval').val());
    var dsendre1 = $('#dsendre1', '#frmDadosAval').val();
    var cdufresd = $('#cdufresd', '#frmDadosAval').val();
    var nrcepend = normalizaNumero($('#nrcepend', '#frmDadosAval').val());

    var qtpreemp = arrayProposta['qtpreemp'];

    var idavalis = contAvalistas;

    // Daniel
    var inpessoa = $('#inpessoa', '#frmDadosAval').val();
    var dtnascto = $('#dtnascto', '#frmDadosAval').val();

    if (operacao == 'AI_DADOS_AVAL' || operacao == 'I_DADOS_AVAL') {
        idavalis++;
    }

    var nrcpfav1 = 0;
    var nrctaav1 = 0;

    if (arrayAvalistas.length > 0) {
        nrctaav1 = normalizaNumero(arrayAvalistas[0]['nrctaava']);
        nrcpfav1 = normalizaNumero(arrayAvalistas[0]['nrcpfcgc']);
    } else if (idavalis == 1) {
        nrctaav1 = normalizaNumero($('#nrctaava', '#frmDadosAval').val());
        nrcpfav1 = normalizaNumero($('#nrcpfcjg', '#frmDadosAval').val());
    }

    var aux_retorno = false;

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        async: false,
        url: UrlSite + 'telas/atenda/emprestimos/valida_avalistas.php',
        data: {
            nrdconta: nrdconta, idseqttl: idseqttl,
            qtpreemp: qtpreemp, qtpromis: qtpromis,
            nrcpfav1: nrcpfav1, idavalis: idavalis,
            nmdavali: nmdavali, nrcpfcgc: nrcpfcgc,
            nrctaava: nrctaava, nrctaav1: nrctaav1,
            nrcpfcjg: nrcpfcjg, dsendre1: dsendre1,
            cdufresd: cdufresd, nrcepend: nrcepend,
            operacao: operacao, nomeform: nomeForm,
            // Daniel
            inpessoa: inpessoa, dtnascto: dtnascto,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {

                if (response.indexOf('showError("error"') == -1) {

                    aux_retorno = true;
                    eval(response);

                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);

                } else {

                    aux_retorno = false;
                    hideMsgAguardo();
                    eval(response);
                }


            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });

    return aux_retorno;
}

function validaDadosInterv() {

    $('input,select', '#' + nomeForm).removeClass('campoErro').removeClass('campoErro');

    var nrctaava = normalizaNumero($("#nrctaava", "#frmIntevAnuente").val());
    var cdnacion = $("#cdnacion", "#frmIntevAnuente").val();
    var tpdocava = $("#tpdocava", "#frmIntevAnuente").val();
    var nmconjug = $("#nmconjug", "#frmIntevAnuente").val();
    var tpdoccjg = $("#tpdoccjg", "#frmIntevAnuente").val();
    var dsendre1 = $("#dsendre1", "#frmIntevAnuente").val();
    var nrfonres = $("#nrfonres", "#frmIntevAnuente").val();
    var nmcidade = $("#nmcidade", "#frmIntevAnuente").val();
    var nrcepend = normalizaNumero($("#nrcepend", "#frmIntevAnuente").val());
    var nmdavali = $("#nmdavali", "#frmIntevAnuente").val();
    var nrcpfcgc = normalizaNumero($("#nrcpfcgc", "#frmIntevAnuente").val());
    var nrdocava = $("#nrdocava", "#frmIntevAnuente").val();
    var nrcpfcjg = normalizaNumero($("#nrcpfcjg", "#frmIntevAnuente").val());
    var nrdoccjg = $("#nrdoccjg", "#frmIntevAnuente").val();
    var dsendre2 = $("#dsendre2", "#frmIntevAnuente").val();
    var dsdemail = $("#dsdemail", "#frmIntevAnuente").val();
    var cdufresd = $("#cdufresd", "#frmIntevAnuente").val();

    var aux_retorno = false;

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        async: false,
        url: UrlSite + 'telas/atenda/emprestimos/valida_interveniente.php',
        data: {
            nrctaava: nrctaava, cdnacion: cdnacion, tpdocava: tpdocava,
            nmconjug: nmconjug, tpdoccjg: tpdoccjg, dsendre1: dsendre1,
            nrfonres: nrfonres, nmcidade: nmcidade, nrcepend: nrcepend,
            nmdavali: nmdavali, nrcpfcgc: nrcpfcgc, nrdocava: nrdocava,
            nrcpfcjg: nrcpfcjg, nrdoccjg: nrdoccjg, dsendre2: dsendre2,
            dsdemail: dsdemail, cdufresd: cdufresd, operacao: operacao,
            nomeform: nomeForm, redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {

                if (response.indexOf('showError("error"') == -1) {

                    aux_retorno = true;
                    eval(response);

                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);

                } else {

                    aux_retorno = false;
                    hideMsgAguardo();
                    eval(response);
                }


            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });

    return aux_retorno;
}

function validaHipoteca(nmfuncao, operacao) {

    if (((typeof $('#dscatbem', '#frmHipoteca').val() == 'object') || ($('#dscatbem', '#frmHipoteca').val() == '')) && booPrimeiroBen) { //809763	
		eval(nmfuncao);
        return true;
    }
	
	showMsgAguardo('Aguarde, validando dados...');
	
    $('input,select', '#' + nomeForm).removeClass('campoErro');

    // Alteracao 069
    $('#dsbemfin', '#frmHipoteca').val(retiraCaracteres($('#dsbemfin', '#frmHipoteca').val(), "'|;", false));

    var dsbemfin  = $('#dsbemfin', '#frmHipoteca').val();
    var vlmerbem  = $('#vlmerbem', '#frmHipoteca').val();
    var dscatbem  = $('#dscatbem', '#frmHipoteca').val();
	var fVlemprst = $('#vlemprst', '#frmNovaProp').val();
	var fVlemprst = arrayProposta['vlemprst'];
		fVlemprst = number_format(parseFloat(fVlemprst.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');

    var idcatbem = contHipotecas;

    if (!booPrimeiroBen) {//809763
        if (dscatbem == '') {//809763
            showError('error', 'O campo categoria &eacute; obrigat&oacute;rio, preencha-o para continuar.', 'Alerta - Ayllos', 'focaCampoErro(\'dscatbem\',\'frmAlienacao\');hideMsgAguardo();bloqueiaFundo(divRotina);');//809763
            return false;//809763
        } 
    }//809763

    if (operacao == 'AI_HIPOTECA' || operacao == 'I_HIPOTECA') {
        idcatbem++;
    }

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        async: false,
        url: UrlSite + 'telas/atenda/emprestimos/valida_hipoteca.php',
        data: {
            dscatbem: dscatbem, dsbemfin: dsbemfin,
            vlmerbem: vlmerbem, idcatbem: idcatbem,
			nmfuncao: nmfuncao, vlemprst: fVlemprst,
            operacao: operacao, nomeform: nomeForm,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {
                if (response.indexOf('showError("error"') == -1) {
                    eval(response);
                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);
                    booPrimeiroBen = true;//809763
                } else {
                    hideMsgAguardo();
                    eval(response);
                }

            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });
	return true;
}

function validaAlienacao(nmfuncao, operacao) {
	
    if (((typeof $('#dscatbem', '#frmAlienacao').val() == 'object') || $('#dscatbem', '#frmAlienacao').val() == '') && $('#dsbemfin', '#frmAlienacao').val() == '' && booPrimeiroBen) {//809763
        eval(nmfuncao);
        return false;
}

	showMsgAguardo('Aguarde, validando dados...');

    $('input,select', '#' + nomeForm).removeClass('campoErro');

    // Alteracao 069
    $('#dsbemfin', '#frmAlienacao').val(retiraCaracteres($('#dsbemfin', '#frmAlienacao').val(), "'|;", false));

    var dscatbem  = $.trim($('#dscatbem', '#frmAlienacao').val());
    var vlmerbem  = $.trim(number_format(parseFloat($('#vlmerbem', '#frmAlienacao').val().replace(/[. ]*/g, '').replace(',', '.')), 2, ',', ''));
    var dsbemfin  = removeAcentos(removeCaracteresInvalidos($.trim($('#dsbemfin', '#frmAlienacao').val().replace("<", "").replace(">", ""))));
    var tpchassi  = $.trim($('#tpchassi', '#frmAlienacao').val());
    var dscorbem  = removeAcentos(removeCaracteresInvalidos($.trim($('#dscorbem', '#frmAlienacao').val().replace("<", "").replace(">", ""))));
    var ufdplaca  = $.trim($('#ufdplaca', '#frmAlienacao').val());
    var nrdplaca  = $.trim($('#nrdplaca', '#frmAlienacao').val());
    var dschassi  = $.trim($('#dschassi', '#frmAlienacao').val());
    var nrrenava  = $.trim(normalizaNumero($('#nrrenava', '#frmAlienacao').val()));
    var nranobem  = $.trim($('#nranobem', '#frmAlienacao').val());
    var nrmodbem  = $.trim($('#nrmodbem', '#frmAlienacao').val());
    var nrcpfbem  = $.trim(normalizaNumero($('#nrcpfbem', '#frmAlienacao').val()));
    var uflicenc  = $.trim($('#uflicenc', '#frmAlienacao').val());
    var dstipbem  = $.trim($('#dstipbem', '#frmAlienacao').val());
	var fVlemprst = arrayProposta['vlemprst'];
		fVlemprst = number_format(parseFloat(fVlemprst.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');

    var idcatbem = contAlienacao;

    if (!booPrimeiroBen) {//809763
        if (dscatbem == '') {//809763
            showError('error', 'O campo categoria &eacute; obrigat&oacute;rio, preencha-o para continuar.', 'Alerta - Ayllos', 'focaCampoErro(\'dscatbem\',\'frmAlienacao\');hideMsgAguardo();bloqueiaFundo(divRotina);');//809763
            return false;//809763
        } 
    }//809763

    if (operacao == 'AI_ALIENACAO' || operacao == 'I_ALIENACAO') {
        idcatbem++;
    }

    var aux_retorno = false;

    if (in_array(dscatbem, ['AUTOMOVEL', 'MOTO', 'CAMINHAO'])) {
        var msgerro = '';
        var camperr = '';

        if (dsbemfin == '') {
            msgerro = 'Descri&ccedil;&atilde;o';
            camperr = 'dsbemfin';
        } else if (dscorbem == '') {
            msgerro = 'Cor Classe';
            camperr = 'dscorbem';
        } else if (vlmerbem == '0,00') {
            msgerro = 'Valor de Mercado';
            camperr = 'vlmerbem';
        } else if (tpchassi == '') {
            msgerro = 'Tipo Chassi';
            camperr = 'tpchassi';
        } else if (dstipbem == 'USADO' && ufdplaca == '') {
            msgerro = 'UF Placa';
            camperr = 'ufdplaca';
        } else if (dstipbem == 'USADO' && nrdplaca == '') {
            msgerro = 'Numero Placa';
            camperr = 'nrdplaca';
        } else if (dschassi == '') {
            msgerro = 'Chassi N.Serie';
            camperr = 'dschassi';
        } else if (dstipbem == 'USADO' && nrrenava == '0') {
            msgerro = 'RENAVAM';
            camperr = 'nrrenava';
        } else if (uflicenc == '') {
            msgerro = 'UF Licenciamento';
            camperr = 'uflicenc';
        } else if (nranobem == '') {
            msgerro = 'Ano Fab.';
            camperr = 'nranobem';
        } else if (nrmodbem == '') {
            msgerro = 'Ano Mod.';
            camperr = 'nrmodbem';
        }

        if (msgerro != '') {
            showError('error', 'O campo ' + msgerro + ' &eacute; obrigat&oacute;rio, preencha-o para continuar.', 'Alerta - Ayllos', 'focaCampoErro(\'' + camperr + '\',\'frmAlienacao\');hideMsgAguardo();bloqueiaFundo(divRotina);');
            return false;
        }
    }

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        async: false,
        url: UrlSite + 'telas/atenda/emprestimos/valida_alienacao.php',
        data: {
            nrdconta: nrdconta, nrctremp: nrctremp,
            dscatbem: dscatbem, dsbemfin: dsbemfin,
            vlmerbem: vlmerbem, tpchassi: tpchassi,
            dschassi: dschassi, dscorbem: dscorbem,
            ufdplaca: ufdplaca, nrrenava: nrrenava,
            nranobem: nranobem, nrmodbem: nrmodbem,
            nrcpfbem: nrcpfbem, idcatbem: idcatbem,
            operacao: operacao, cddopcao: cddopcao,
            nrdplaca: nrdplaca, idseqbem: idseqbem,
            nomeform: nomeForm, dstipbem: dstipbem,
            uflicenc: uflicenc, nmfuncao: nmfuncao,
			vlemprst: fVlemprst,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {

                if (response.indexOf('showError("error"') == -1) {
                    eval(response);
                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);
                    booPrimeiroBen = true;//809763
                } else {
                    hideMsgAguardo();
                    eval(response);
                }


            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });
    return true;
}

function validaAnaliseProposta() {

    $('input,select', '#frmOrgProtCred').removeClass('campoErro');

    var dtcnsspc = $('#dtcnsspc', '#frmOrgProtCred').val();
    var nrinfcad = $('#nrinfcad', '#frmOrgProtCred').val();
    var dtoutspc = $('#dtoutspc', '#frmOrgProtCred').val();
    var dtdrisco = $('#dtdrisco', '#frmOrgProtCred').val();
    var dtoutris = $('#dtoutris', '#frmOrgProtCred').val();
    var nrgarope = $('#nrgarope', '#frmOrgProtCred').val();
    var nrliquid = $('#nrliquid', '#frmOrgProtCred').val();
    var nrpatlvr = $('#nrpatlvr', '#frmOrgProtCred').val();
    var nrperger = $('#nrperger', '#frmOrgProtCred').val();


    var aux_retorno = false;

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        async: false,
        url: UrlSite + 'telas/atenda/emprestimos/valida_analise_proposta.php',
        data: {
            nrdconta: nrdconta, idseqttl: idseqttl,
            dtcnsspc: dtcnsspc, nrinfcad: nrinfcad,
            dtoutspc: dtoutspc, dtdrisco: dtdrisco,
            dtoutris: dtoutris, nrgarope: nrgarope,
            nrliquid: nrliquid, nrpatlvr: nrpatlvr,
            nrperger: nrperger, inobriga: inobriga,
			nomeform: nomeForm, redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {

                if (response.indexOf('showError("error"') == -1) {

                    aux_retorno = true;
                    eval(response);

                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);

                } else {

                    aux_retorno = false;
                    hideMsgAguardo();
                    eval(response);
                }
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });

    return aux_retorno;
}

function limpaMsg(retorno, msgerro) {

    hideMsgAguardo();
    bloqueiaFundo(divRotina);

    if (!retorno && msgerro != '') {
        showError('error', msgerro, 'Alerta - Ayllos', 'bloqueiaFundo(divRotina);');
    }

    return retorno;

}

function validaDados(cdcooper) {

    if (in_array(operacao, ['TA', 'A_NOVA_PROP', 'A_INICIO', 'A_VALOR', 'A_AVALISTA', 'TI', 'I_INICIO'])) {

        var vlemprst = $('#vlemprst', '#frmNovaProp').val();

        if (vlemprst <= 0) {
            return limpaMsg(false, '269 - Valor errado.');
        }

        if (!validaDadosGerais()) {
            return false;
        }
		
		carregaDadosPropostaLinhaCredito();

    } else if (in_array(operacao, ['A_DADOS_PROP_PJ', 'I_DADOS_PROP_PJ'])) {

        var perfatcl = $('#perfatcl', '#frmDadosPropPj').val();

        if (perfatcl <= 0 || perfatcl > 100) {
            return limpaMsg(false, '269 - Valor errado.');
        }

    } else if (in_array(operacao, ['A_DADOS_PROP', 'A_DADOS_PROP'])) {

        var tpdrend = 0;
        var vldrend = 0;

        for (var i = 1; i <= contRend; i++) {

            tpdrend = $('#tpdrend' + i, '#frmDadosProp').val();
            vldrend = parseFloat($('#vldrend' + i, '#frmDadosProp').val().replace(',', '.'));

            vldrend = (isNaN(vldrend)) ? 0 : vldrend;
            tpdrend = (isNaN(tpdrend)) ? 0 : tpdrend;

            if ((tpdrend == 0 && vldrend > 0) || (tpdrend > 0 && vldrend == 0)) {
                return limpaMsg(false, '375 - O campo deve ser preenchido.');
            }

        }

    } else if (in_array(operacao, ['A_DADOS_AVAL', 'I_DADOS_AVAL'])) {

        if (!validaDadosAval()) {
            return false;
        }

    } else if (in_array(operacao, ['AI_INTEV_ANU', 'A_INTEV_ANU', 'IA_INTEV_ANU', 'I_INTEV_ANU'])) {

        if (!validaDadosInterv()) {
            return false;
        }

    } else if (in_array(operacao, ['A_PROT_CRED', 'I_PROT_CRED'])) {

        var aux_dtmvtolt = dataParaTimestamp(dtmvtolt);
		
		if (inobriga == 'N'){
			if (!validaAnaliseProposta()) {
				return false;
			}
		}
    }
    else if (in_array(operacao, ['A_PROTECAO_TIT'])) {

        if (!validaItensRating(operacao, true)) {
            return false;
        }
    } else if (in_array(operacao, ['PORTAB_CRED_I', 'PORTAB_CRED_A'])) { /*PORTABILIDADE*/
        if (validaPortabilidadeCredito(operacao) == false) {
            return false;
        }
    }

    return true;
}

//002: Rotina que verifica a proposta de emprestimo antes de persistir  dados e mostra critica se necessário
function verificaPropostas() {

    var arrayBensAlien = arrayAlienacoes;

    // var vlemprst = parseFloat(arrayCooperativa['vlemprst'].replace(/[.R$ ]*/g,'').replace(',','.'));
    var vlemprst = number_format(parseFloat(arrayProposta['vlemprst'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    var vlminimo = number_format(parseFloat(arrayCooperativa['vlminimo'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    vleprori = number_format(parseFloat(vleprori.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');

    var qtpromis = arrayProposta["qtpromis"];
    var qtpreemp = arrayProposta['qtpreemp'];
    var cdlcremp = arrayProposta['cdlcremp'];

    var aux_retorno = false;

    // Limpa Formatação do CPF
    for (i in arrayAlienacoes) {
        arrayBensAlien[i]['nrcpfbem'] = normalizaNumero(arrayAlienacoes[i]['nrcpfbem']);
    }

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        async: false,
        url: UrlSite + 'telas/atenda/emprestimos/verifica_propostas.php',
        data: {
            nrdconta: nrdconta, idseqttl: idseqttl,
            nrctremp: nrctremp, vlemprst: vlemprst,
            vleprori: vleprori, vlminimo: vlminimo,
            qtpromis: qtpromis, qtpreemp: qtpreemp,
            cdlcremp: cdlcremp, operacao: operacao,
            arrayIntervs: arrayIntervs, /* Array de Intervenientes */
            arrayBensAlien: arrayBensAlien, /* Array de Bens Alienação */
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {

                if (response.indexOf('showError("error"') == -1) {

                    aux_retorno = true;

                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);

                    eval(response);

                } else {

                    aux_retorno = false;
                    hideMsgAguardo();
                    eval(response);
                }


            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });

    return false;
}

function geraRegsDinamicos() {


    //Limpo as variaveis
    for (var i = 0; i < 2; i++) {
        eval('aux_nmdaval' + i + ' = "";');
        eval('aux_nrcpfav' + i + ' = "";');
        eval('aux_tpdocav' + i + ' = "";');
        eval('aux_dsdocav' + i + ' = "";');
        eval('aux_nmdcjav' + i + ' = "";');
        eval('aux_cpfcjav' + i + ' = "";');
        eval('aux_tdccjav' + i + ' = "";');
        eval('aux_doccjav' + i + ' = "";');
        eval('aux_ende1av' + i + ' = "";');
        eval('aux_ende2av' + i + ' = "";');
        eval('aux_nrfonav' + i + ' = "";');
        eval('aux_emailav' + i + ' = "";');
        eval('aux_nmcidav' + i + ' = "";');
        eval('aux_cdufava' + i + ' = "";');
        eval('aux_nrcepav' + i + ' = "";');
        eval('aux_dsnacio' + i + ' = "";');
        eval('aux_vledvmt' + i + ' = "";');
        eval('aux_vlrenme' + i + ' = "";');
        eval('aux_nrender' + i + ' = "";');
        eval('aux_complen' + i + ' = "";');
        eval('aux_nrcxaps' + i + ' = "";');
        // Daniel
        eval('aux_inpesso' + i + ' = "";');
        eval('aux_dtnasct' + i + ' = "";');
    }

    //Array avalistas
    for (var i = 0; i < arrayAvalistas.length; i++) {
        eval('aux_nmdaval' + i + ' = arrayAvalistas[' + i + '][\'nmdavali\'];');
        eval('aux_nrcpfav' + i + ' = arrayAvalistas[' + i + '][\'nrcpfcgc\'];');
        eval('aux_tpdocav' + i + ' = arrayAvalistas[' + i + '][\'tpdocava\'];');
        eval('aux_dsdocav' + i + ' = arrayAvalistas[' + i + '][\'nrdocava\'];');
        eval('aux_nmdcjav' + i + ' = arrayAvalistas[' + i + '][\'nmconjug\'];');
        eval('aux_cpfcjav' + i + ' = arrayAvalistas[' + i + '][\'nrcpfcjg\'];');
        eval('aux_tdccjav' + i + ' = arrayAvalistas[' + i + '][\'tpdoccjg\'];');
        eval('aux_doccjav' + i + ' = arrayAvalistas[' + i + '][\'nrdoccjg\'];');
        eval('aux_ende1av' + i + ' = arrayAvalistas[' + i + '][\'dsendre1\'];');
        eval('aux_ende2av' + i + ' = arrayAvalistas[' + i + '][\'dsendre2\'];');
        eval('aux_nrfonav' + i + ' = arrayAvalistas[' + i + '][\'nrfonres\'];');
        eval('aux_emailav' + i + ' = arrayAvalistas[' + i + '][\'dsdemail\'];');
        eval('aux_nmcidav' + i + ' = arrayAvalistas[' + i + '][\'nmcidade\'];');
        eval('aux_cdufava' + i + ' = arrayAvalistas[' + i + '][\'cdufresd\'];');
        eval('aux_nrcepav' + i + ' = arrayAvalistas[' + i + '][\'nrcepend\'];');
        eval('aux_cdnacio' + i + ' = arrayAvalistas[' + i + '][\'cdnacion\'];');
        eval('aux_vledvmt' + i + ' = arrayAvalistas[' + i + '][\'vledvmto\'];');
        eval('aux_vlrenme' + i + ' = arrayAvalistas[' + i + '][\'vlrenmes\'];');
        eval('aux_nrender' + i + ' = arrayAvalistas[' + i + '][\'nrendere\'];');
        eval('aux_complen' + i + ' = arrayAvalistas[' + i + '][\'complend\'];');
        eval('aux_nrcxaps' + i + ' = arrayAvalistas[' + i + '][\'nrcxapst\'];');
        // Daniel
        eval('aux_inpesso' + i + ' = arrayAvalistas[' + i + '][\'inpessoa\'];');
        eval('aux_dtnasct' + i + ' = arrayAvalistas[' + i + '][\'dtnascto\'];');
    }

    montaString();

    return false;

}

function maiorIdseqbem() {

    var aux_idseqbem = 0;

    for (i in arrayAvalistas) {

        for (j in arrayAvalistas[i]['bensaval']) {

            if (aux_idseqbem < arrayAvalistas[i]['bensaval'][j]['idseqbem']) {
                aux_idseqbem = arrayAvalistas[i]['bensaval'][j]['idseqbem'];
            }

        }
    }

    return aux_idseqbem;
}

function montaString() {

    //Bens Avalistas ( Uma string com os bens dos dois avalistas)
    var aux_cont = maiorIdseqbem();
    var aux_index = 0;

    aux_dsdbeavt = '';

    for (i in arrayAvalistas) {

        for (j in arrayAvalistas[i]['bensaval']) {

            if (aux_dsdbeavt != '') {
                aux_dsdbeavt = aux_dsdbeavt + '|';
            }

            aux_cont++;
            aux_index = aux_cont;

            aux_dsdbeavt = aux_dsdbeavt +
                    arrayAvalistas[i]['bensaval'][j]['nrdconta'] + ';' +
                    normalizaNumero(arrayAvalistas[i]['nrcpfcgc']) + ';' +
                    arrayAvalistas[i]['bensaval'][j]['dsrelbem'] + ';' +
                    number_format(parseFloat(arrayAvalistas[i]['bensaval'][j]['persemon'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '') + ';' +
                    arrayAvalistas[i]['bensaval'][j]['qtprebem'] + ';' +
                    number_format(parseFloat(arrayAvalistas[i]['bensaval'][j]['vlprebem'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '') + ';' +
                    number_format(parseFloat(arrayAvalistas[i]['bensaval'][j]['vlrdobem'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '') + ';' + aux_index;

        }
    }

    //Faturamentos

    aux_dsdfinan = '';

    for (i in arrayFaturamentos) {

        if (aux_dsdfinan != '') {
            aux_dsdfinan = aux_dsdfinan + '|';
        }

        aux_dsdfinan = aux_dsdfinan +
                arrayFaturamentos[i]['anoftbru'] + ';' +
                arrayFaturamentos[i]['mesftbru'] + ';' +
                arrayFaturamentos[i]['vlrftbru'];
    }

    //Rendimentos

    aux_dsdrendi = '';

    for (var i = 1; i <= contRend; i++) {

        // Se nao tem um tipo de rendimento valido
        if (!in_array(arrayRendimento['tpdrend' + i], ['1', '2', '3', '4', '5', '6', '7'])) {
            continue;
        }

        if (aux_dsdrendi != '') {
            aux_dsdrendi = aux_dsdrendi + '|';
        }

        aux_dsdrendi = aux_dsdrendi +
                arrayRendimento['tpdrend' + i] + ';' +
                arrayRendimento['vldrend' + i];
    }

    //Bens do cooperado

    aux_dsdebens = '';

    for (i in arrayBensAss) {

        if (aux_dsdebens != '') {
            aux_dsdebens = aux_dsdebens + '|';
        }

        aux_dsdebens = aux_dsdebens +
                arrayBensAss[i]['nrdconta'] + ';;' +
                removeAcentos(removeCaracteresInvalidos(arrayBensAss[i]['dsrelbem'])) + ';' +
                number_format(parseFloat(arrayBensAss[i]['persemon'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '') + ';' +
                arrayBensAss[i]['qtprebem'] + ';' +
                number_format(parseFloat(arrayBensAss[i]['vlprebem'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '') + ';' +
                number_format(parseFloat(arrayBensAss[i]['vlrdobem'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '') + ';' +
                arrayBensAss[i]['idseqbem'];

    }


    //Bens alienação
    aux_dsdalien = '';
    for (i in arrayAlienacoes) {

        if (aux_dsdalien != '') {
            aux_dsdalien = aux_dsdalien + '|';
        }

        aux_dsdalien = aux_dsdalien +
                arrayAlienacoes[i]['dscatbem'] + ';' +
                removeAcentos(removeCaracteresInvalidos(arrayAlienacoes[i]['dsbemfin'].replace("<", "").replace(">", ""))) + ';' +
                removeAcentos(removeCaracteresInvalidos(arrayAlienacoes[i]['dscorbem'].replace("<", "").replace(">", ""))) + ';' +
                number_format(parseFloat(arrayAlienacoes[i]['vlmerbem'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '') + ';' +
                arrayAlienacoes[i]['dschassi'] + ';' +
                arrayAlienacoes[i]['nranobem'] + ';' +
                arrayAlienacoes[i]['nrmodbem'] + ';' +
                arrayAlienacoes[i]['nrdplaca'].replace('000-0000', '').replace('-', '') + ';' +
                normalizaNumero(arrayAlienacoes[i]['nrrenava']) + ';' +
                arrayAlienacoes[i]['tpchassi'] + ';' +
                arrayAlienacoes[i]['ufdplaca'] + ';' +
                normalizaNumero(arrayAlienacoes[i]['nrcpfbem']) + ';' +
                arrayAlienacoes[i]['uflicenc'] /* GRAVAMES*/ + ';' +
                arrayAlienacoes[i]['dstipbem'] + ';' +
                arrayAlienacoes[i]['idseqbem'] + ';' + /* GRAVAMES*/
                arrayAlienacoes[i]['cdcoplib']; /* OPERADOR DE LIBERACAO */
    }

    //Interneiente anuente
    par_dsinterv = '';

    for (i in arrayIntervs) {

        if (par_dsinterv != '') {
            par_dsinterv = par_dsinterv + '|';
        }

        par_dsinterv = par_dsinterv +
                normalizaNumero(arrayIntervs[i]['nrcpfcgc']) + ';' +
                arrayIntervs[i]['nmdavali'] + ';' +
                normalizaNumero(arrayIntervs[i]['nrcpfcjg']) + ';' +
                arrayIntervs[i]['nmconjug'] + ';' +
                arrayIntervs[i]['tpdoccjg'] + ';' +
                arrayIntervs[i]['nrdoccjg'] + ';' +
                arrayIntervs[i]['tpdocava'] + ';' +
                arrayIntervs[i]['nrdocava'] + ';' +
                arrayIntervs[i]['dsendre1'] + ';' +
                arrayIntervs[i]['dsendre2'] + ';' +
                arrayIntervs[i]['nrfonres'] + ';' +
                arrayIntervs[i]['dsdemail'] + ';' +
                arrayIntervs[i]['nmcidade'] + ';' +
                arrayIntervs[i]['cdufresd'] + ';' +
                normalizaNumero(arrayIntervs[i]['nrcepend']) + ';' +
                arrayIntervs[i]['cdnacion'] + ';' +
                normalizaNumero(arrayIntervs[i]['nrendere']) + ';' +
                arrayIntervs[i]['complend'] + ';' +
                normalizaNumero(arrayIntervs[i]['nrcxapst']);
    }

    //Hipoteca
    for (i in arrayHipotecas) {

        if (aux_dsdalien != '') {
            aux_dsdalien = aux_dsdalien + '|';
        }

        aux_dsdalien = aux_dsdalien +
                arrayHipotecas[i]['dscatbem'] + ';' +
                arrayHipotecas[i]['dsbemfin'] + ';' +
                arrayHipotecas[i]['dscorbem'] + ';' +
                arrayHipotecas[i]['vlmerbem'] + ';;;;;;;;;;;';
        /* GRAVAMES - String de 15 entradas
         Tratado na BO0002 e monta_registros_proposta */
    }

    return false;
}

function undoValor() {

    arrayProposta["vlemprst"] = vleprori;
    arrayProposta["vlpreemp"] = bkp_vlpreemp;
    arrayProposta["dslcremp"] = bkp_dslcremp;
    arrayProposta["dsfinemp"] = bkp_dsfinemp;
    arrayProposta["tplcremp"] = bkp_tplcremp;

    $("#vlemprst", "#frmNovaProp").val(vleprori);
    $("#vlpreemp", "#frmNovaProp").val(bkp_vlpreemp);
    $("#dslcremp", "#frmNovaProp").val(bkp_dslcremp);
    $("#dsfinemp", "#frmNovaProp").val(bkp_dsfinemp);
    $("#tplcremp", "#frmNovaProp").val(bkp_tplcremp);

    $("#vlemprst", "#frmNovaProp").trigger('blur');
    $("#vlpreemp", "#frmNovaProp").trigger('blur');

    return false;
}

//000: Formatação inicial dos avalistas
function iniciaAval() {

    var nomeForm = 'frmDadosAval';
    var cConta = $('#nrctaava', '#' + nomeForm);
    var cQntd = $('#qtpromis', '#' + nomeForm);

    $('select,input', '#' + nomeForm + ' fieldset').desabilitaCampo();

    if (normalizaNumero(cConta.val()) == 0) {
        cConta.habilitaCampo();
    }

    if (operacao == 'A_DADOS_AVAL' || operacao == 'IA_DADOS_AVAL') {
        cQntd.desabilitaCampo();
        cQntd.val(arrayProposta['qtpromis']);
        cConta.habilitaCampo();
    } else if (operacao == 'AI_DADOS_AVAL' || operacao == 'I_DADOS_AVAL') {
        if (contAvalistas != 0) {
            cQntd.desabilitaCampo();
            cQntd.val(arrayProposta['qtpromis']);

        } else {
            cQntd.val(arrayProposta['qtpromis']);
        }
    }

    return false;
    }

function fechaAvalista() {
    showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'controlaOperacao(\'\')', 'bloqueiaFundo(divRotina);', 'sim.gif', 'nao.gif');
    fechaRotina($('#divUsoGenerico'), $('#divRotina'));
    return false;
}

//000: Formatação inicial dos intervenientes
function iniciaInterv() {

    var nomeForm = 'frmIntevAnuente';
    $('input,select', '#' + nomeForm + ' fieldset').desabilitaCampo();

    highlightObjFocus($('#frmIntevAnuente'));

    if (normalizaNumero($('#nrctaava', '#' + nomeForm).val()) == 0) {
        $('#nrctaava', '#' + nomeForm).habilitaCampo();
    }

    return false;
}

//**************************************************
//**        GERENCIAMENTO DA TABELA RATING        **
//**************************************************

function verificaCriticasRating() {

    var dsctrliq = $('#dsctrliq', '#' + nomeForm).val();

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/verifica_rating.php',
        data: {
            nrdconta: nrdconta, dsctrliq: dsctrliq,
            operacao: operacao, redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {
                $('#divUsoGenerico').html(response);

            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });

    return false;
}

function montaRating() {

    limpaDivGenerica();

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        asysnc: false,
        url: UrlSite + 'telas/atenda/emprestimos/rating.php',
        data: {
            operacao: operacao,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
        }
    });

    return false;
}

function fechaRating() {

    fechaRotina($('#divUsoGenerico'), $('#divRotina'));

    controlaOperacao('');
    validaImpressao();

    return false;
}

//***************************************************

//**************************************************
//**     GERENCIAMENTO DA TABELA DE FIADORES      **
//**************************************************

function mostraTabelaFiadores(operacao) {
    showMsgAguardo('Aguarde, buscando fiadores...');

    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();

    var nrctaava = arrayAvalBusca['nrctaava'];
    var nmdavali = arrayAvalBusca['nmdavali'];

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/fiadores/fiadores.php',
        data: {
            operacao: operacao, nrctaava: nrctaava,
            nmdavali: nmdavali, redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
            controlaLayoutFiador(operacao);
        }
    });
    return false;
}

// Controla o layout da descrição dos Faturamentos
function controlaLayoutFiador(operacao) {

    // Formata o tamanho da tabela
    $('#divTabFiadores').css({'height': '208px', 'width': '580px'});

    // Monta Tabela dos Itens
    $('#divTabFiadores > div > table > tbody').html('');

    for (var i in arrayFiadores) {

        $('#divTabFiadores > div > table > tbody').append('<tr></tr>');
        $('#divTabFiadores > div > table > tbody > tr:last-child').append('<td><span>' + arrayFiadores[i]['nrdconta'] + '</span>' + arrayFiadores[i]['nrdconta'] + '</td>');
        $('#divTabFiadores > div > table > tbody > tr:last-child').append('<td><span>' + arrayFiadores[i]['nrctremp'] + '</span>' + formataContrato(arrayFiadores[i]['nrctremp']) + '</td>');
        $('#divTabFiadores > div > table > tbody > tr:last-child').append('<td>' + arrayFiadores[i]['dtmvtolt'] + '</td>');
        $('#divTabFiadores > div > table > tbody > tr:last-child').append('<td><span>' + arrayFiadores[i]['vlemprst'].replace(',', '.') + '</span>' + number_format(parseFloat(arrayFiadores[i]['vlemprst'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.') + '</td>');
        $('#divTabFiadores > div > table > tbody > tr:last-child').append('<td>' + arrayFiadores[i]['qtpreemp'] + '</td>');
        $('#divTabFiadores > div > table > tbody > tr:last-child').append('<td><span>' + arrayFiadores[i]['vlpreemp'].replace(',', '.') + '</span>' + number_format(parseFloat(arrayFiadores[i]['vlpreemp'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.') + '</td>');
        $('#divTabFiadores > div > table > tbody > tr:last-child').append('<td><span>' + arrayFiadores[i]['vlsdeved'].replace(',', '.') + '</span>' + number_format(parseFloat(arrayFiadores[i]['vlsdeved'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.') + '</td>');

    }

    var divRegistro = $('#divTabFiadores > div.divRegistros');
    var tabela = $('table', divRegistro);

    divRegistro.css('height', '150px');

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '70px';
    arrayLargura[1] = '60px';
    arrayLargura[2] = '60px';
    arrayLargura[3] = '70px';
    arrayLargura[4] = '35px';
    arrayLargura[5] = '70px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';

    var metodo = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodo);

    hideMsgAguardo();
    bloqueiaFundo($('#divUsoGenerico'));

    $('#divUsoGenerico').centralizaRotinaH();

    $('#btContinuar', '#divTabFaturamento').focus();

    return false;
}

function fechaFiadores() {

    var mtdSim = 'fechaRotina($(\'#divUsoGenerico\'),$(\'#divRotina\'));carregaBusca();bloqueiaFundo(divRotina);';
    var mtdNao = 'fechaRotina($(\'#divUsoGenerico\'),$(\'#divRotina\'));$(\'#nrctaava\',\'#frmDadosAval\').focus();bloqueiaFundo(divRotina);';

    showConfirmacao('Confirma fiador nestas condi&ccedil;&otilde;es?', 'Confirma&ccedil;&atilde;o - Ayllos', mtdSim, mtdNao, 'sim.gif', 'nao.gif');

    return false;

}

function formataContrato(contrato) {

    var newContrato = '';
    var tamanho = contrato.length;

    if (tamanho > 3) {
        newContrato = contrato.substring(0, (tamanho - 3)) + '.' + contrato.substring((tamanho - 3), tamanho);
    } else {
        newContrato = contrato;
    }

    return newContrato;
}

//***************************************************

//**************************************************
//**    GERENCIAMENTO DA ROTINA DE SIMULAÇÕES     **
//**************************************************

function mostraTabelaSimulacao(operacao) {
    showMsgAguardo('Aguarde, buscando simula&ccedil;&otilde;es...');

    $("#divRotina").css("visibility", "hidden");
    exibeRotina($('#divUsoGenerico'));
    $('#divUsoGenerico').css("z-index", 100);
    limpaDivGenerica();

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/simulacao/principal.php',
        data: {
            operacao: operacao,
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            if (response.substr(0, 14) == 'hideMsgAguardo')
                eval(response);
            else {
                $('#divUsoGenerico').html(response);
                hideMsgAguardo();
                controlaLayoutTabelaSimulacao();
            }
        }
    });
    return false;
}

function controlaLayoutTabelaSimulacao()
{
    var divRegistro = $('#divProcSimulacoesTabela > div.divRegistros');
    var tabela = $('table', divRegistro);

    divRegistro.css('height', '150px');

    var ordemInicial = new Array();
    ordemInicial = [[0, 1]];

    var arrayLargura = new Array();
    arrayLargura[0] = '35px';
    arrayLargura[1] = '85px';
    arrayLargura[2] = '90px';
    arrayLargura[3] = '40px';
    arrayLargura[4] = '40px';
    arrayLargura[5] = '60px';
    arrayLargura[6] = '75px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
    layoutPadrao();

    $('table > tbody > tr', '#divProcSimulacoesTabela > div.divRegistros').each(function() {
        if ($(this).hasClass('corSelecao')) {
            indarray = $('input', $(this)).val();
            auxind = indarray;
        }
    });

    divRotina.css('width', largura);
    $('#divConteudoOpcao').css({'height': altura, 'width': largura});

    controlaPesquisas();
    bloqueiaFundo(divRotina);
    removeOpacidade('divConteudoOpcao');
    divRotina.centralizaRotinaH();
}

function fechaSimulacoes(encerrarRotina) {
    $('#divProcSimulacoesFormulario').remove();
    $('#divProcSimulacoesTabela').remove();
    $('#divUsoGenerico').html('');
    fechaRotina($('#divUsoGenerico'));
    if (encerrarRotina)
    {
        fechaRotina($('#divUsoGenerico'), $('#divRotina'));
        encerraRotina(true);
    }
    else
    {
        exibeRotina($('#divRotina'));
        controlaOperacao('');
    }
    return false;
}

function validaSimulacao() {

    showMsgAguardo('Aguarde, validando ...');
    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/emprestimos/valida_simulacao.php',
        data: {
            nrdconta: nrdconta, idseqttl: idseqttl,
            operacao: operacao, redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            eval(response);
        }
    });

    return false;
}

//***************************************************

//**************************************************
//**       GERENCIAMENTO DA ROTINA DE BENS        **
//**************************************************

function mostraTabelaBens(operacaoBem, operacao) {
    showMsgAguardo('Aguarde, buscando bens...');

    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/bens.php',
        data: {
            operacao: operacao,
            qtavalis: contAvalistas,
            nrAvalistaSalvo: nrAvalistaSalvo,
            nomeAcaoCall: nomeAcaoCall,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
            controlaOperacaoBens(operacaoBem, operacao);
        }
    });
    return false;
}

//Controla as operações da descrição de bens
function controlaOperacaoBens(operacao, operacaoPrinc) {

    var msgOperacao = '';

    if (operacao == 'BF' || operacao == 'E') {
        indarray = '';
        $('table > tbody > tr', '#divProcBensTabela > div.divRegistros').each(function() {
            if ($(this).hasClass('corSelecao')) {
                indarray = $('input', $(this)).val();
                auxind = indarray;
            }
        });
        if (indarray == '') {
            return false;
        }
    }

    switch (operacao) {
        //Mostra o formulario de bens
        case 'BF':
            //Oculto a tabela e mostro o formulario
            $('#divProcBensFormulario').css('display', 'block');
            $('#divProcBensTabela').css('display', 'none');
            //Preencho o formulario com os dados do bem selecionado;
            $('input[name="dsrelbem"]', '#divProcBensFormulario').val(arrayBensAssoc[indarray]['dsrelbem']);
            $('input[name="persemon"]', '#divProcBensFormulario').val(arrayBensAssoc[indarray]['persemon']);
            $('input[name="qtprebem"]', '#divProcBensFormulario').val(arrayBensAssoc[indarray]['qtprebem']);
            $('input[name="vlprebem"]', '#divProcBensFormulario').val(arrayBensAssoc[indarray]['vlprebem']);
            $('input[name="vlrdobem"]', '#divProcBensFormulario').val(arrayBensAssoc[indarray]['vlrdobem']);
            $('input[name="idseqbem"]', '#divProcBensFormulario').val(arrayBensAssoc[indarray]['idseqbem']);
            msgOperacao = 'abrindo bens';
            break;

            //Inclusão. Mostra formulario de bens vazio.
        case 'BI':
            if (arrayBensAssoc.length < maxBens) {
                $('#divProcBensFormulario').css('display', 'block');
                $('#divProcBensTabela').css('display', 'none');
                msgOperacao = 'abrindo formul&aacute;rio de bens';
            } else {
                showError('error', 'Limite de cadastramento atingido', 'Alerta - Ayllos', "bloqueiaFundo($('#divUsoGenerico'));");
                return false;
            }
            break;

            // Mostra a tabela de bens
        case 'BT':
            // Oculto o formulario e mostro a tabela
            msgOperacao = 'abrindo tabela de bens';
            break;
        case 'BR':
            // Oculto o formulario e mostro a tabela
            showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'mostraTabelaBens(\'BT\')', 'bloqueiaFundo($(\'#divUsoGenerico\'))', 'sim.gif', 'nao.gif');
            return false;
            break;
            // Confirmação de exclusão de bem
        case 'E':
            // Oculto o formulario e mostro a tabela
            showConfirmacao('Deseja confirmar exclus&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'controlaOperacaoBens(\'E_BEM\')', 'bloqueiaFundo($(\'#divUsoGenerico\'))', 'sim.gif', 'nao.gif');
            return false;
            break;
            //Excluindo bem do Array
        case 'E_BEM':
            showMsgAguardo('Aguarde, excluindo ...');
            arrayBensAssoc.splice(indarray, 1);
            mostraTabelaBens('BT');
            return false;
            break;

            //Salvando alterações do bem no Array
        case 'AS':
            arrayBensAssoc[indarray]['dsrelbem'] = $('input[name="dsrelbem"]', '#divProcBensFormulario').val();
            arrayBensAssoc[indarray]['persemon'] = $('input[name="persemon"]', '#divProcBensFormulario').val();
            arrayBensAssoc[indarray]['qtprebem'] = $('input[name="qtprebem"]', '#divProcBensFormulario').val();
            arrayBensAssoc[indarray]['vlprebem'] = $('input[name="vlprebem"]', '#divProcBensFormulario').val();
            arrayBensAssoc[indarray]['vlrdobem'] = $('input[name="vlrdobem"]', '#divProcBensFormulario').val();
            arrayBensAssoc[indarray]['idseqbem'] = $('input[name="idseqbem"]', '#divProcBensFormulario').val();
            mostraTabelaBens('BT');
            return false
            break;

            //Salvando inclusões do bem no Array
        case 'IS':

            i = arrayBensAssoc.length;

            eval('var arrayBemGenerico' + i + ' = new Object();');
            eval('arrayBemGenerico' + i + '["dsrelbem"] = $(\'input[name="dsrelbem"]\',\'#divProcBensFormulario\').val();');
            eval('arrayBemGenerico' + i + '["cdsequen"] = \'\';');
            eval('arrayBemGenerico' + i + '["nrdrowid"] = \'\';');
            eval('arrayBemGenerico' + i + '["dtmvtolt"] = \'\';');
            eval('arrayBemGenerico' + i + '["dtaltbem"] = \'\';');
            eval('arrayBemGenerico' + i + '["idseqttl"] = 1;');
            eval('arrayBemGenerico' + i + '["cdoperad"] = "' + cdoperad + '";');
            eval('arrayBemGenerico' + i + '["nrdconta"] = ' + bemnrdconta + ';');
            eval('arrayBemGenerico' + i + '["nrcpfcgc"] = ' + bemnrcpfcgc + ';');
            eval('arrayBemGenerico' + i + '["persemon"] = $(\'input[name="persemon"]\',\'#divProcBensFormulario\').val();');
            eval('arrayBemGenerico' + i + '["qtprebem"] = $(\'input[name="qtprebem"]\',\'#divProcBensFormulario\').val();');
            eval('arrayBemGenerico' + i + '["vlprebem"] = $(\'input[name="vlprebem"]\',\'#divProcBensFormulario\').val();');
            eval('arrayBemGenerico' + i + '["vlrdobem"] = $(\'input[name="vlrdobem"]\',\'#divProcBensFormulario\').val();');
            eval('arrayBemGenerico' + i + '["idseqbem"] = $(\'input[name="idseqbem"]\',\'#divProcBensFormulario\').val();');
            eval('arrayBensAssoc[' + i + '] = arrayBemGenerico' + i + ';');
            mostraTabelaBens('BT');
            return false
            break;
        default:
            break;
    }
    showMsgAguardo('Aguarde, ' + msgOperacao + ' ...');
    controlaLayoutBens(operacao, operacaoPrinc);
    return false;
}

// Controla o layout da descrição de bens
function controlaLayoutBens(operacao, operacaoPrinc) {

    // Operação consultando
    if (operacao == 'BT') {
        $('#divProcBensTabela').css('display', 'block');
        $('#divProcBensFormulario').css('display', 'none');

        // Formata o tamanho da tabela
        $('#divProcBensTabela').css({'height': '215px', 'width': '517px'});

        // Monta Tabela dos Itens
        $('#divProcBensTabela > div > table > tbody').html('');

        for (var i in arrayBensAssoc) {
            desc = (arrayBensAssoc[i]['dsrelbem'].length > 16) ? arrayBensAssoc[i]['dsrelbem'].substr(0, 17) + '...' : arrayBensAssoc[i]['dsrelbem'];
            $('#divProcBensTabela > div > table > tbody').append('<tr></tr>');
            $('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td><span>' + arrayBensAssoc[i]['dsrelbem'] + '</span>' + desc
                    + '<input type="hidden" id="indarray" name="indarray" value="' + i + '" />'
                    + '<input type="hidden" id="idseqbem" name="idseqbem" value="' + arrayBensAssoc[i]['idseqbem'] + '" /></td>').css({'text-transform': 'uppercase'});
            $('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td><span>' + arrayBensAssoc[i]['persemon'].replace(',', '.') + '</span>' + number_format(parseFloat(arrayBensAssoc[i]['persemon'].replace(',', '.')), 2, ',', '.') + '</td>');
            $('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td>' + arrayBensAssoc[i]['qtprebem'] + '</td>');
            $('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td><span>' + arrayBensAssoc[i]['vlprebem'].replace(',', '.') + '</span>' + number_format(parseFloat(arrayBensAssoc[i]['vlprebem'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.') + '</td>');
            $('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td><span>' + arrayBensAssoc[i]['vlrdobem'].replace(',', '.') + '</span>' + number_format(parseFloat(arrayBensAssoc[i]['vlrdobem'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.') + '</td>');
        }


        var divRegistro = $('#divProcBensTabela > div.divRegistros');
        var tabela = $('table', divRegistro);

        divRegistro.css('height', '150px');

        var ordemInicial = new Array();
        ordemInicial = [[0, 0]];

        var arrayLargura = new Array();
        arrayLargura[0] = '160px';
        arrayLargura[1] = '60px';
        arrayLargura[2] = '60px';
        arrayLargura[3] = '83px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'right';
        arrayAlinha[2] = 'right';
        arrayAlinha[3] = 'right';
        arrayAlinha[4] = 'right';

        var metodo = (operacaoPrinc == 'C_BENS_ASSOC') ? '' : 'controlaOperacaoBens(\'BF\');';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodo);

        if (in_array(operacao, ['BT'])) {
            SelecionaItem('indarray', tabela, auxind);
        }

        //  Operação Alterando/Incluindo - Formatando o formulário
    } else {

        var persemon, qtprebem, vlrdobem;

        var cTodos = $('#dsrelbem,#persemon,#qtprebem,#vlprebem,#vlrdobem', '#frmProcBens');
        var cDescricao = $('#dsrelbem', '#frmProcBens');
        var cPercentual = $('#persemon', '#frmProcBens');
        var cQtParcela = $('#qtprebem', '#frmProcBens');
        var cVlParcela = $('#vlprebem', '#frmProcBens');
        var cVlBem = $('#vlrdobem', '#frmProcBens');
        var cIdSeqBem = $('#idseqbem', '#frmProcBens');

        // Controla largura dos campos
        $('label', '#frmProcBens').css({'width': '195px'}).addClass('rotulo');
        cDescricao.css({'width': '275px'});
        cPercentual.css({'width': '50px'});
        cQtParcela.css({'width': '50px'});
        cVlParcela.css({'width': '135px', 'text-align': 'right'}).attr('alt', 'p6p3c2D').autoNumeric().trigger('blur');
        cVlBem.css({'width': '135px'});

        // Se inclusão, limpar dados do formulário
        if (operacao == 'BI') {
            $('#frmProcBens').limpaFormulario();
            $('#btSalvar', '#divProcBensFormulario').unbind('click');
            $('#btSalvar', '#divProcBensFormulario').click(function() {
                validaBens('IS');
                return false;
            });
        } else if (operacao == 'BF') {
            $('#btSalvar', '#divProcBensFormulario').unbind('click');
            $('#btSalvar', '#divProcBensFormulario').click(function() {
                validaBens('AS');
                return false;
            });
        }

        // Formata o tamanho do Formulário
        $('#divProcBensFormulario').css({'height': '165px', 'width': '517px'});

        // Adicionando as classes
        cTodos.removeClass('campoErro').habilitaCampo();

        // Se percentual sem ônus = 100, trava os campos "qtprebem" e "vlprebem"
        persemon = cPercentual.val();
        persemon = (typeof persemon == 'undefined') ? 0 : persemon.replace(',', '.');
        persemon = parseFloat(persemon);

        if (persemon == 100) {
            cQtParcela.unbind().val(0).desabilitaCampo();
            cVlParcela.unbind().val(0, 00).desabilitaCampo();
        }

        // Valida Percentual sem Ônus
        cPercentual.change(function() {
            persemon = parseFloat(cPercentual.val().replace(',', '.'));
            // Se maior do que 100, mostra mensagem de erro e retorna o foco no mesmo campo
            if (persemon > 100) {
                showError('error', 'Valor Percentual sem &ocirc;nus deve ser menor ou igual a 100,00.', 'Alerta - Ayllos', 'bloqueiaFundo($("#divUsoGenerico"),\'persemon\',\'frmProcBens\')');
            } else {
                cPercentual.removeClass('campoErro');
                if (persemon == 100) {
                    cQtParcela.unbind().val(0).desabilitaCampo();
                    cVlParcela.unbind().val(0, 00).desabilitaCampo();
                    layoutPadrao();
                } else {
                    cQtParcela.habilitaCampo();
                    cVlParcela.habilitaCampo();
                    cVlParcela.css({'width': '135px', 'text-align': 'right'}).attr('alt', 'p6p3c2D').autoNumeric().trigger('blur');
                    cQtParcela.focus();
                }
            }
        });

        // Valida Quantidade de parcelas
        // Ao mudar a Quantidade de parcelas, não permitir valores menores ou iguais a zero
        cQtParcela.change(function() {
            if ($(this).hasClass('campo')) {
                qtprebem = parseFloat(cQtParcela.val().replace(',', '.').replace('', '0'));
                if (qtprebem <= 0) {
                    showError('error', 'Parcelas a pagar deve ser maior que zero.', 'Alerta - Ayllos', 'bloqueiaFundo($("#divUsoGenerico"),\'qtprebem\',\'frmProcBens\')');
                } else {
                    cQtParcela.removeClass('campoErro');
                }
            }
        });

        // Valida Valor das parcelas
        cVlParcela.change(function() {
            if ($(this).hasClass('campo')) {
                vlprebem = parseFloat(cVlParcela.val().replace(',', '.').replace('', '0'));
                if (vlprebem <= 0) {
                    showError('error', 'Valor da parcela deve ser maior que zero.', 'Alerta - Ayllos', 'bloqueiaFundo($("#divUsoGenerico"),\'vlprebem\',\'frmProcBens\')');
                } else {
                    cVlParcela.removeClass('campoErro');
                }
            }
        });

        // Valida Valor do Bem
        cVlBem.change(function() {
            vlrdobem = parseFloat(cVlBem.val().replace(',', '.').replace('', '0'));
            if (vlrdobem <= 0) {
                showError('error', 'Valor do Bem deve ser maior que zero.', 'Alerta - Ayllos', 'bloqueiaFundo($("#divUsoGenerico"),\'vlrdobem\',\'frmProcBens\')');
            } else {
                cVlBem.removeClass('campoErro');
            }
        });
    }

    layoutPadrao();
    hideMsgAguardo();
    bloqueiaFundo($('#divUsoGenerico'));
    if (operacao != 'BT') {
        $('#dsrelbem', '#divProcBensFormulario').focus();
    } else {
        $('#btContinuar', '#divProcBensTabela').focus();
    }
    return false;
}


function validaBens(operacao) {

    showMsgAguardo('Aguarde, validando bens...');

    // Alteracao 069
    $('#dsrelbem', '#frmProcBens').val(retiraCaracteres($('#dsrelbem', '#frmProcBens').val(), "'|\\;", false));

    var dsrelbem = $('#dsrelbem', '#frmProcBens').val();
    var qtprebem = $('#qtprebem', '#frmProcBens').val();
    var persemon = $('#persemon', '#frmProcBens').val();
    var vlprebem = $('#vlprebem', '#frmProcBens').val();
    var vlrdobem = $('#vlrdobem', '#frmProcBens').val();
    //var idseqbem = 0;
    var idseqbem = $('#idseqbem', '#frmProcBens').val();
    var cddopcao = '';

    cddopcao = (operacao == 'IS') ? 'I' : 'A';

    persemon = number_format(parseFloat(persemon.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    vlprebem = number_format(parseFloat(vlprebem.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');
    vlrdobem = number_format(parseFloat(vlrdobem.replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        async: false,
        url: UrlSite + 'telas/atenda/emprestimos/valida_bens.php',
        data: {
            dsrelbem: dsrelbem, qtprebem: qtprebem, persemon: persemon,
            vlprebem: vlprebem, vlrdobem: vlrdobem, nrdconta: nrdconta,
            idseqttl: idseqttl, idseqbem: idseqbem, cddopcao: cddopcao,
            operacao: operacao, redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo($(\'#divUsoGenerico\'))');
        },
        success: function(response) {
            try {

                if (response.indexOf('showError("error"') == -1) {
                    hideMsgAguardo();
                    bloqueiaFundo($('#divUsoGenerico'));
                    controlaOperacaoBens(operacao);

                } else {
                    hideMsgAguardo();
                    eval(response);
                }


            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo($(\'#divUsoGenerico\'))');
            }
        }
    });

    return false;

}

function fechaBens() {

    fechaTelaBens();

    if (operacao == 'A_DADOS_AVAL' || operacao == 'AI_DADOS_AVAL') {
        sincronizaArrayBens();

        if (operacao == 'A_DADOS_AVAL') {
            atualizaArray('A_PROTECAO_AVAL');
        }
        else {
            controlaOperacao('A_DADOS_AVAL');
        }

    } else if (operacao == 'I_DADOS_AVAL' || operacao == 'IA_DADOS_AVAL') {
        sincronizaArrayBens();
        controlaOperacao('I_DADOS_AVAL');
    } else if (operacao == 'A_DADOS_PROP_PJ' || operacao == 'A_DADOS_PROP') {
        sincronizaArrayBens();
        controlaOperacao('A_PROT_CRED');
    } else if (operacao == 'I_DADOS_PROP_PJ' || operacao == 'I_DADOS_PROP') {
        sincronizaArrayBens();
        controlaOperacao('I_PROT_CRED');
    } else {

        var tplcremp = (typeof arrayProposta == 'undefined') ? 1 : arrayProposta['tplcremp'];

        if (tplcremp == 1) {
            controlaOperacao('C_PROT_CRED');
        }
        else if (tplcremp == 2) {
            controlaOperacao('C_ALIENACAO');
        }
        else {
            controlaOperacao('C_HIPOTECA');
        }


    }
    return false;
}

//***************************************************

//**************************************************
//**   GERENCIAMENTO DA ROTINA DE FATURAMENTOS    **
//**************************************************

function mostraFaturamento(opFat, operacao) {
    showMsgAguardo('Aguarde, buscando faturamentos...');

    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/faturamento/faturamento.php',
        data: {
            operacao: operacao,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
            controlaOperacaoFat(opFat, operacao);
        }
    });
    return false;
}

//Controla as operações da descrição do Faturamento
function controlaOperacaoFat(operacao, operacaoPrinc) {

    var msgOperacao = '';
    if (operacao == 'BF' || operacao == 'E') {
        indarray = '';
        $('table > tbody > tr', '#divTabFaturamento > div.divRegistros').each(function() {
            if ($(this).hasClass('corSelecao')) {
                indarray = $('input', $(this)).val();
                auxind = indarray;
            }
        });
        if (indarray == '') {
            return false;
        }
    }

    switch (operacao) {
        //Mostra o formulario de Faturamento
        case 'BF':
            //Oculto a tabela e mostro o formulario
            $('#frmFaturamento').css('display', 'block');
            $('#divTabFaturamento').css('display', 'none');
            //Preencho o formulario com os dados do Faturamento selecionado;
            $('input[name="mesftbru"]', '#frmFaturamento').val(arrayFaturamentos[indarray]['mesftbru']);
            $('input[name="anoftbru"]', '#frmFaturamento').val(arrayFaturamentos[indarray]['anoftbru']);
            $('input[name="vlrftbru"]', '#frmFaturamento').val(arrayFaturamentos[indarray]['vlrftbru']);
            $('input[name="nrposext"]', '#frmFaturamento').val(arrayFaturamentos[indarray]['nrposext']);
            msgOperacao = 'abrindo faturamento';
            break;

            //Inclusão. Mostra formulario do Faturamento vazio.
        case 'BI':
            $('#frmFaturamento').css('display', 'block');
            $('#divTabFaturamento').css('display', 'none');
            msgOperacao = 'abrindo formul&aacute;rio';
            break;

            // Mostra a tabela de Faturamentos
        case 'BT':
            // Oculto o formulario e mostro a tabela
            msgOperacao = 'abrindo tabela';
            break;
        case 'BR':
            // Oculto o formulario e mostro a tabela
            showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'mostraFaturamento(\'BT\')', 'bloqueiaFundo($(\'#divUsoGenerico\'))', 'sim.gif', 'nao.gif');
            return false;
            break;

            // Confirmação de exclusão de faturamento
        case 'E':
            // Oculto o formulario e mostro a tabela
            showConfirmacao('Deseja confirmar exclus&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'controlaOperacaoFat(\'E_FAT\')', 'bloqueiaFundo($(\'#divUsoGenerico\'))', 'sim.gif', 'nao.gif');
            return false;
            break;

            //Excluindo Faturamento do Array
        case 'E_FAT':
            showMsgAguardo('Aguarde, excluindo ...');
            arrayFaturamentos.splice(indarray, 1);
            mostraFaturamento('BT');
            return false;
            break;

            //Salvando alterações do Faturamento no Array
        case 'AS':
            arrayFaturamentos[indarray]['mesftbru'] = $('input[name="mesftbru"]', '#frmFaturamento').val();
            arrayFaturamentos[indarray]['anoftbru'] = $('input[name="anoftbru"]', '#frmFaturamento').val();
            arrayFaturamentos[indarray]['vlrftbru'] = $('input[name="vlrftbru"]', '#frmFaturamento').val();
            mostraFaturamento('BT');
            return false
            break;

            //Salvando inclusões do Faturamento no Array
        case 'IS':
            i = arrayFaturamentos.length;
            eval('var arrayFaturamento' + i + ' = new Object();');
            eval('arrayFaturamento' + i + '["nrdrowid"] = \'\';');
            eval('arrayFaturamento' + i + '["vlrftbru"] = $(\'input[name="vlrftbru"]\',\'#frmFaturamento\').val();');
            eval('arrayFaturamento' + i + '["anoftbru"] = $(\'input[name="anoftbru"]\',\'#frmFaturamento\').val();');
            eval('arrayFaturamento' + i + '["mesftbru"] = $(\'input[name="mesftbru"]\',\'#frmFaturamento\').val();');
            eval('arrayFaturamentos[' + i + '] = arrayFaturamento' + i + ';');

            excluiAntigo('BT');
            return false
            break;
        default:
            break;
    }
    showMsgAguardo('Aguarde, ' + msgOperacao + ' ...');
    controlaLayoutFat(operacao, operacaoPrinc);
    return false;
}

//Verifica se arrayFaturamentos tem mais que maxFaturamento, se sim, exclui mais antigo.
function excluiAntigo(novaOp) {

    var tamanho = arrayFaturamentos.length;
    var ano, mes, indece;

    while (parseInt(maxFaturamento) < parseInt(tamanho)) {
        ano = 9999;
        mes = 13;
        indece = -1;

        for (i in arrayFaturamentos) {

            if (parseInt(arrayFaturamentos[i]['anoftbru']) <= parseInt(ano)) {
                if (parseInt(arrayFaturamentos[i]['anoftbru']) < parseInt(ano)) {
                    ano = parseInt(arrayFaturamentos[i]['anoftbru']);
                    mes = parseInt(arrayFaturamentos[i]['mesftbru']);
                    indece = i;
                } else {
                    if (parseInt(arrayFaturamentos[i]['mesftbru']) < parseInt(mes)) {
                        mes = parseInt(arrayFaturamentos[i]['mesftbru']);
                        indece = i;
                    }
                }
            }

        }

        if (parseInt(indece) >= 0) {
            arrayFaturamentos.splice(indece, 1);
            tamanho = parseInt(arrayFaturamentos.length);
        }
    }
    mostraFaturamento(novaOp);
    return false;
}

// Controla o layout da descrição dos Faturamentos
function controlaLayoutFat(operacao, operacaoPrinc) {

    // Operação consultando
    if (operacao == 'BT') {
        $('#divTabFaturamento').css('display', 'block');
        $('#frmFaturamento').css('display', 'none');

        // Formata o tamanho da tabela
        $('#divTabFaturamento').css({'height': '208px', 'width': '350px'});

        // Monta Tabela dos Itens
        $('#divTabFaturamento > div > table > tbody').html('');

        for (var i in arrayFaturamentos) {

            desc = (arrayFaturamentos[i]['mesftbru'].length > 16) ? arrayFaturamentos[i]['mesftbru'].substr(0, 17) + '...' : arrayFaturamentos[i]['mesftbru'];
            $('#divTabFaturamento > div > table > tbody').append('<tr></tr>');
            $('#divTabFaturamento > div > table > tbody > tr:last-child').append('<td><span>' + arrayFaturamentos[i]['mesftbru'] + '</span>' + desc + '<input type="hidden" id="indarray" name="indarray" value="' + i + '" /></td>').css({'text-transform': 'uppercase'});
            $('#divTabFaturamento > div > table > tbody > tr:last-child').append('<td><span>' + arrayFaturamentos[i]['anoftbru'] + '</span>' + arrayFaturamentos[i]['anoftbru'] + '</td>');
            $('#divTabFaturamento > div > table > tbody > tr:last-child').append('<td><span>' + arrayFaturamentos[i]['vlrftbru'] + '</span>' + number_format(parseFloat(arrayFaturamentos[i]['vlrftbru'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.') + '</td>');
        }

        var divRegistro = $('#divTabFaturamento > div.divRegistros');
        var tabela = $('table', divRegistro);

        divRegistro.css('height', '150px');

        var ordemInicial = new Array();
        ordemInicial = [[1, 1], [0, 1]];

        var arrayLargura = new Array();
        arrayLargura[0] = '70px';
        arrayLargura[1] = '100px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'right';

        var metodo = (operacaoPrinc == 'C_BENS_ASSOC') ? '' : 'controlaOperacaoFat(\'BF\');';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodo);

        if (in_array(operacao, ['BT'])) {
            SelecionaItem('indarray', tabela, auxind);
        }

        //  Operação Alterando/Incluindo - Formatando o formulário
    } else {

        var persemon, qtprebem, vlrdobem;

        var rotulos = $('label[for="mesftbru"],label[for="anoftbru"],label[for="vlrftbru"]', '#frmFat');
        var cTodos = $('#mesftbru,#anoftbru,#vlrftbru', '#frmFat');
        var cMes = $('#mesftbru', '#frmFat');
        var cAno = $('#anoftbru', '#frmFat');
        var cFaturamento = $('#vlrftbru', '#frmFat');

        // Controla largura dos campos
        rotulos.addClass('rotulo').css({'width': '170px'});
        cMes.css({'width': '38px'}).attr('maxlength', '2').addClass('inteiro');
        cAno.css({'width': '38px'}).attr('maxlength', '4').addClass('inteiro');
        cFaturamento.css({'width': '100px'}).attr('maxlength', '14').addClass('moeda');

        // Se inclusão, limpar dados do formulário
        if (operacao == 'BI') {
            $('#frmFat').limpaFormulario();
            $('#btSalvar', '#frmFaturamento').unbind('click');
            $('#btSalvar', '#frmFaturamento').click(function() {
                validaFaturamento('IS');
                return false;
            });
        } else if (operacao == 'BF') {
            $('#btSalvar', '#frmFaturamento').unbind('click');
            $('#btSalvar', '#frmFaturamento').click(function() {
                validaFaturamento('AS');
                return false;
            });
        }

        // Formata o tamanho do Formulário
        $('#frmFaturamento').css({'height': '115px', 'width': '350px'});

        // Adicionando as classes
        cTodos.removeClass('campoErro').habilitaCampo();

    }

    layoutPadrao();
    hideMsgAguardo();
    bloqueiaFundo($('#divUsoGenerico'));

    if (operacao != 'BT') {
        $('#mesftbru', '#frmFaturamento').focus();
    } else {
        $('#btIncluir', '#divTabFaturamento').focus();
    }
    return false;
}

function validaFaturamento(operacao) {

    var cMes = parseFloat($('#mesftbru', '#frmFat').val());
    var cAno = parseFloat($('#anoftbru', '#frmFat').val());
    var nrposext = $('#nrposext', '#frmFat').val();

    var mes = parseFloat(dtmvtolt.substr(3, 2));
    var ano = parseFloat(dtmvtolt.substr(6, 4));
    var tamanho = arrayFaturamentos.length;

    if ((cMes > 12 || cMes < 1) || (cAno < 1000) || (ano < cAno) || ((ano == cAno) && (cMes > mes))) {
        showError('error', '013 - Data errada.', 'Alerta - Ayllos', 'bloqueiaFundo($("#divUsoGenerico"));');
        return false;
    }

    for (var i = 0; i < tamanho; i++) {

        if ((parseFloat(arrayFaturamentos[i]['mesftbru']) == cMes) &&
                (parseFloat(arrayFaturamentos[i]['anoftbru']) == cAno) &&
                (arrayFaturamentos[i]['nrposext'] != nrposext)) {

            showError('error', 'Já existe um faturamento com este mes e ano.', 'Alerta - Ayllos', 'bloqueiaFundo($("#divUsoGenerico"));');
            return false;

        }

    }

    controlaOperacaoFat(operacao);
    return false;

}

function calculaMediaFat() {

    var tamanho = arrayFaturamentos.length;
    var total = 0;
    var media = 0;
    var vlrftbru = 0;

    if (tamanho == 0) {
        $('#vlmedfat', '#frmDadosPropPj').val('0,00');
        return false;
    }

    for (var i = 0; i < tamanho; i++) {
        vlrftbru = parseFloat(arrayFaturamentos[i]['vlrftbru'].replace(/[.R$ ]*/g, '').replace(',', '.'));
        total = total + vlrftbru;
    }

    media = total / tamanho;

    media = number_format(media, 2, ',', '.');

    $('#vlmedfat', '#frmDadosPropPj').val(media);

    return false;
}

function fechaFaturamentos() {

    $('#frmFaturamento').remove();
    fechaRotina($('#divUsoGenerico'), $('#divRotina'));

    return false;
}

//***************************************************

//***************************************************
//** GERENCIAMENTO DA TELA COM OPÇÕES DA ALTERAÇÃO **
//***************************************************

function mostraTelaAltera(operacao) {
    showMsgAguardo('Aguarde, abrindo altera&ccedil;&atilde;o...');

    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();
    
    inobriga = $("#divEmpres table tr.corSelecao").find("input[id='inobriga']").val();
    
    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/altera.php',
        data: {
            operacao: operacao,
            inobriga: inobriga,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });

    $('#todaProp', '#frmAltera').focus();

    return false;
}

function fechaAltera(operacao) {

    fechaRotina($('#divUsoGenerico'), $('#divRotina'));

    possuiPortabilidade = $("#divEmpres table tr.corSelecao").find("input[id='portabil']").val();

    if (operacao != 'fechar') {
        if (operacao == 'A_NOVA_PROP') {
            direcionaAlteracao(operacao);
        } else {
            controlaOperacao(operacao);
        }
    }

    return false;

}

//***************************************************

//***************************************************
//**        GERENCIAMENTO CONTRATO IMPRESSO        **
//***************************************************

function mostraContrato(operacao) {
    fechaContrato('I_FINALIZA');
    /*
     // Jean C. Reddiga - 17/12/2014
     // Retirado para atender ao chamado 
     // 229867 – Automatizar Número de Contratos de Crédito
     
     showMsgAguardo('Aguarde, carregando...');
     
     exibeRotina($('#divUsoGenerico'));
     
     limpaDivGenerica();
     
     // Executa script de confirmação através de ajax
     $.ajax({
     type: 'POST',
     dataType: 'html',
     url: UrlSite + 'telas/atenda/emprestimos/contrato.php',
     data: {
     operacao: operacao,
     redirect: 'html_ajax'
     },
     error: function(objAjax,responseError,objExcept) {
     hideMsgAguardo();
     showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
     },
     success: function(response) {
     $('#divUsoGenerico').html(response);
     layoutPadrao();
     hideMsgAguardo();
     bloqueiaFundo($('#divUsoGenerico'));
     $('#nrctremp','#frmContrato').focus();
     }
     });
     
     return false; 
     */
}

function formatacaoInicial() {

    var nrctremp_1 = $('#nrctremp', '#frmContrato');
    var btVoltar = $('#btVoltar', '#divConteudoValor');
    var btSalvar = $('#btSalvar', '#divConteudoValor');
    var rNrctremp_1 = $('label[for="nrctremp"]', '#frmContrato');

    highlightObjFocus($('#frmContrato'));

    aux_nrctremp = 0;

    nrctremp_1.val('');

    rNrctremp_1.addClass('rotulo').css('width', '205px').html('Numero do contrato impresso:');

    nrctremp_1.addClass('inteiro').css('width', '90px');

    nrctremp_1.habilitaCampo();


    layoutPadrao();

    btVoltar.unbind('click').bind('click', function() {
        fechaContrato('');
        return false;
    });

    btSalvar.unbind('click').bind('click', function() {
        verificaContrato();
        return false;
    });

    nrctremp_1.focus();

    return false;
}

function confirmaContrato() {

    var nrctremp_1 = $('#nrctremp', '#frmContrato');
    var btVoltar = $('#btVoltar', '#divConteudoValor');
    var btSalvar = $('#btSalvar', '#divConteudoValor');
    var rNrctremp_1 = $('label[for="nrctremp"]', '#frmContrato');

    aux_nrctrem2 = 0;

    rNrctremp_1.css('width', '240px').html('Confirme o numero do contrato impresso:');

    aux_nrctremp = normalizaNumero(nrctremp_1.val());

    nrctremp_1.val('');

    btVoltar.unbind('click').bind('click', function() {
        formatacaoInicial();
        return false;
    });

    btSalvar.unbind('click').bind('click', function() {
        fechaContrato('I_FINALIZA');
        return false;
    });

    return false;
}

function verificaContrato(novaOp) {

    var nrctremp = normalizaNumero($('#nrctremp', '#frmContrato').val());
    var nrctrem2 = arrayCooperativa['nrctremp'];
    var inusatab = arrayCooperativa['inusatab'];
    var nralihip = arrayCooperativa['nralihip'];

    showMsgAguardo('Aguarde, verificando...');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/emprestimos/verifica_contrato.php',
        data: {
            nrdconta: nrdconta, nrctremp: nrctremp,
            nrctrem2: nrctrem2, inusatab: inusatab,
            nralihip: nralihip, operacao: operacao,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo($(\'#divUsoGenerico\'));');
        },
        success: function(response) {
            try {

                if (response.indexOf('showError("error"') == -1) {

                    hideMsgAguardo();
                    bloqueiaFundo($('#divUsoGenerico'));
                    eval(response);

                } else {

                    hideMsgAguardo();
                    eval(response);
                }


            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo($(\'#divUsoGenerico\'));');
            }
        }
    });

    return false;
}

function fechaContrato(operacao) {

    if (operacao == 'I_FINALIZA') {

        aux_nrctrem2 = normalizaNumero($('#nrctremp', '#frmContrato').val());

        if (aux_nrctremp != aux_nrctrem2) {
            showError('error', '301 - DADOS NAO CONFEREM!', 'Alerta - Ayllos', 'bloqueiaFundo($(\'#divUsoGenerico\'));');
            return false;
        }

        nrctremp = aux_nrctrem2;

    } else {
        fechaRotina($('#divUsoGenerico'), $('#divRotina'));
        showConfirmacao('Deseja cancelar inclus&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'controlaOperacao(\'\')', 'controlaOperacao(\'I_INICIO\')', 'sim.gif', 'nao.gif');
        return false;
    }

    fechaRotina($('#divUsoGenerico'), $('#divRotina'));

    controlaOperacao(operacao);

    return false;

}

//***************************************************

//***************************************************
//**   GERENCIAMENTO ALTEÇÃO NUMERO DO CONTRATO    **
//***************************************************

function mostraNumero(operacao) {
    showMsgAguardo('Aguarde, abrindo altera&ccedil;&atilde;o...');

    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/numero.php',
        data: {
            operacao: operacao,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "bloqueiaFundo($('#divUsoGenerico'));");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });

    return false;
}

function fechaNumero(operacao) {

    fechaRotina($('#divUsoGenerico'), $('#divRotina'));

    controlaOperacao(operacao);

    return false;

}

function validaItensRating(operacao, flgarray) {

    var nrgarope = (flgarray) ? arrayProtCred['nrgarope'] : $("#nrgarope", "#frmOrgProtCred").val();
    var nrinfcad = (flgarray) ? $("#nrinfcad", "#frmOrgaos").val() : 1;
    var nrliquid = (flgarray) ? arrayProtCred['nrliquid'] : $("#nrliquid", "#frmOrgProtCred").val();
    var nrpatlvr = (flgarray) ? arrayProtCred['nrpatlvr'] : $("#nrpatlvr", "#frmOrgProtCred").val();
    var nrperger = (flgarray) ? arrayProtCred['nrperger'] : $("#nrperger", "#frmOrgProtCred").val();

    var aux_retorno = false;

    showMsgAguardo('Aguarde, validando ...');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/emprestimos/valida_itens_rating.php',
        async: false,
        data: {
            nrdconta: nrdconta,
            nrgarope: nrgarope,
            nrinfcad: nrinfcad,
            nrliquid: nrliquid,
            nrpatlvr: nrpatlvr,
            nrperger: nrperger,
            inprodut: 1,
            inpessoa: inpessoa,
            vlprodut: arrayProposta['vlemprst'],
            cdfinemp: arrayProposta['cdfinemp'],
            cdlcremp: arrayProposta['cdlcremp'],
            inobriga: inobriga,
            operacao: operacao,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            aux_retorno = false;
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', 'bloqueiaFundo($(\'#divRotina\'))');
        },
        success: function(response) {
            try {
                if (response.indexOf('showError("error"') == -1) {

                    aux_retorno = true;
                    eval(response);

                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);

                } else {

                    aux_retorno = false;
                    hideMsgAguardo();
                    eval(response);
                }

            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo($(\'#divRotina\'))');
            }
        }
    });
    return aux_retorno;
}

//***************************************************

//***************************************************
//**        GERENCIAMENTO BUSCA OBSERVAÇÃO         **
//***************************************************

function mostraBuscaObs(operacao) {
    showMsgAguardo('Aguarde, abrindo busca...');

    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/observacao.php',
        data: {
            operacao: operacao,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
            $('#nrctrobs', '#frmBuscaObs').focus();
        }
    });

    return false;
}

function buscaObs(opcao) {

    var nrctrobs = normalizaNumero($('#nrctrobs', '#frmBuscaObs').val());

    if (nrctrobs == 0) {
        fechaBuscaObs(opcao + '_COMITE_APROV');
        return false;
    }

    showMsgAguardo('Aguarde, buscando...');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/emprestimos/busca_obs.php',
        data: {
            nrctrobs: nrctrobs, nrdconta: nrdconta,
            operacao: operacao, redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {

                if (response.indexOf('showError("error"') == -1) {

                    eval(response);

                } else {

                    hideMsgAguardo();
                    eval(response);
                }


            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });

    return false;

}

function fechaBuscaObs(operacao) {

    fechaRotina($('#divUsoGenerico'), $('#divRotina'));

    controlaOperacao(operacao);

    return false;

}

//***************************************************

//***************************************************
//**         GERENCIAMENTO DA TELA VALORES         **
//***************************************************

function mostraValores(strMsg, flmudfai) {

    strValor = strMsg;
    showMsgAguardo('Aguarde, abrindo valores...');

    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/valores.php',
        data: {
            flmudfai: flmudfai,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });

    return false;
}

function fechaValores(flmudfai) {

    fechaRotina($('#divUsoGenerico'), $('#divRotina'));

	if (flmudfai == 'N'){
		exibirMensagens(strValor, 'confirmaConsultas("' + flmudfai + '" , "SVP");controlaOperacao("");');
	}else{
		exibirMensagens(strValor, 'controlaOperacao("");');
	}

    return false;

}

function confirmaConsultas(flmudfai, cddopcao) {

    if (flmudfai == 'N') {
        showConfirmacao('Deseja efetuar as consultas?', 'Confirma&ccedil;&atilde;o - Ayllos', 'efetuar_consultas(0);controlaOperacao("");', 'efetuar_consultas(1);controlaOperacao("");', 'nao.gif', 'sim.gif');
    }

}

//***************************************************

//***************************************************
//**       GERENCIAMENTO DA TELA LIQUIDACOES       **
//***************************************************

function buscaLiquidacoes(operacao) {
	
    var dsctrliq = $('#dsctrliq', '#' + nomeForm).val();
    //variavel que contem o valor de "Emprestimos" na tela atenda    
    var vltotemp = parseFloat($('#valueRot1').html().replace(/[.R$ ]*/g, '').replace(',', '.'));
    var cdlcremp = $('#cdlcremp', '#' + nomeForm).val();

    //Variaveis para contabilizar e deixar selecionar LIMITE/ADP quando não houver empréstimos a renegociar
    var vlDepAVista = parseFloat($('#valueRot3').html().replace(/[.R$ ]*/g, '').replace(',', '.'));
    var vlLimCred = parseFloat($('#valueRot4').html().replace(/[.R$ ]*/g, '').replace(',', '.'));
    var vlLimiteAdp = vlDepAVista + vlLimCred;

    //Alterado a forma como abre as liquidacoes, para considerar também limite/adp quando não houver empréstimos a renegociar
    if (((vltotemp > 0) && (cdlcremp != 100)) || vlLimiteAdp < 0) {

        showMsgAguardo('Aguarde, buscando liquida&ccedil;&otilde;es...');

        // Executa script de confirmação através de ajax
        $.ajax({
            type: 'POST',
            url: UrlSite + 'telas/atenda/emprestimos/liquidacoes/busca_liquidacoes.php',
            data: {
                nrdconta: nrdconta,
                idseqttl: idseqttl,
                dsctrliq: dsctrliq,
                operacao: operacao,
                cdlcremp: cdlcremp,
				inpessoa: inpessoa,
                redirect: 'script_ajax'
            },
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            },
            success: function(response) {
                try {
                    if (response.indexOf('showError("error"') == -1) {
                        hideMsgAguardo();
                        bloqueiaFundo(divRotina);
                        eval(response);
                    } else {
                        hideMsgAguardo();
                        bloqueiaFundo(divRotina);
                        eval(response);
                    }
                } catch (error) {
                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                }
            }
        });

    } else {
        $('#dsctrliq', '#' + nomeForm).val('Sem liquidacoes');
        //validacao para portabilidade
        if (operacao == 'PORTAB_I') {
            operacao = 'I_DADOS_AVAL';
        } else if (operacao == 'PORTAB_A') {
            operacao = 'A_DADOS_AVAL';
        }

        atualizaArray(operacao);
    }

    return false;
}

function carregaLiquidacoes(opLiq) {

    var vlsdeved = 0;
    tot_vlsdeved = 0;
    nrSelec = 0;

    for (var i in arrayLiquidacoes) {
        if (arrayLiquidacoes[i]['idseleca'] == '*') {
            vlsdeved = parseFloat(arrayLiquidacoes[i]['vlsdeved'].replace(/[.R$ ]*/g, '').replace(',', '.'));
            tot_vlsdeved = tot_vlsdeved + vlsdeved;
            nrSelec++;
        }
    }

    mostraLiquidacoes(opLiq, operacao);

    return false;
}

function controlaLiquidacoes() {

    indarray = '';

    $('table > tbody > tr', '#divTabLiquidacoes > div.divRegistros').each(function() {
        if ($(this).hasClass('corSelecao')) {
            indarray = $('input', $(this)).val();
            auxind = indarray;
        }
    });

    if (arrayLiquidacoes[indarray]['idseleca'] == '*') {

        vlsdeved = parseFloat(arrayLiquidacoes[indarray]['vlsdeved'].replace(/[.R$ ]*/g, '').replace(',', '.'));
        tot_vlsdeved = tot_vlsdeved - vlsdeved;
        nrSelec--;
        arrayLiquidacoes[indarray]['idseleca'] = '';
        mostraLiquidacoes('', operacao);

    } else {
        validaLiquidacoes(false, '');
    }

    return false;
}

function validaLiquidacoes(flgContinuar, operacao) {

    var dtmvtoep = (flgContinuar) ? "" : arrayLiquidacoes[indarray]['dtmvtolt'];
    var qtlinsel = nrSelec;
    var vlemprst = $("#vlemprst", "#frmNovaProp").val();
    var vlsdeved = (flgContinuar) ? 0 : arrayLiquidacoes[indarray]['vlsdeved'];
    var tosdeved = number_format(tot_vlsdeved, 2, ',', '');
    var nrctremp = (flgContinuar) ? 0 : arrayLiquidacoes[indarray]['nrctremp'];    
    var idenempr = (flgContinuar) ? 0 : arrayLiquidacoes[indarray]['idenempr'];

    if (!flgContinuar && vlsdeved == '0') {
        return;
    }

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/emprestimos/liquidacoes/valida_liquidacoes.php',
        data: {
            nrdconta: nrdconta, idseqttl: idseqttl,
            dtmvtoep: dtmvtoep, qtlinsel: qtlinsel,
            vlemprst: vlemprst, vlsdeved: vlsdeved,
            tosdeved: tosdeved, operacao: operacao,
            nrctremp: nrctremp, idenempr: idenempr,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {

                if (response.indexOf('showError("error"') == -1) {
                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);
                    eval(response);

                } else {
                    hideMsgAguardo();
                    eval(response);
                }

            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });

    return false;
}

function mostraLiquidacoes(opLiq, operacao) {

    showMsgAguardo('Aguarde, buscando liquida&ccedil;&otilde;es...');

    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/liquidacoes/liquidacoes.php',
        data: {
            operacao: operacao,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);

            controlaLayoutLiq(opLiq);
        }
    });
    return false;
}

function controlaLayoutLiq(operacao) {

    var aux_nrctremp, aux_vlemprst, 
        aux_vlpreemp, aux_vlsdeved, 
        aux_tpemprst, aux_dstipemp,
        aux_cdfinemp, aux_cdlcremp,
        aux_idenempr;

    // Formata o tamanho da tabela
    $('#divTabLiquidacoes').css({'height': '208px', 'width': '625px'});

    // Monta Tabela dos Itens
    $('#divTabLiquidacoes > div > table > tbody').html('');

    for (var i in arrayLiquidacoes) {

        aux_nrctremp = formataContrato(arrayLiquidacoes[i]['nrctremp'].replace(/[. ]*/g, ''));
        aux_vlemprst = number_format(parseFloat(arrayLiquidacoes[i]['vlemprst'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.');
        aux_vlpreemp = number_format(parseFloat(arrayLiquidacoes[i]['vlpreemp'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.');
        aux_vlsdeved = number_format(parseFloat(arrayLiquidacoes[i]['vlsdeved'].replace(/[.R$ ]*/g, '').replace(',', '.')), 2, ',', '.');

        aux_idenempr = arrayLiquidacoes[i]['idenempr'];           
        aux_cdfinemp = arrayLiquidacoes[i]['cdfinemp'];
        aux_cdlcremp = arrayLiquidacoes[i]['cdlcremp'];
        aux_qtpreemp = arrayLiquidacoes[i]['qtpreemp'];

        // Tratamento para verificar Tipo de Emprestimo
        switch (arrayLiquidacoes[i]['tpemprst']) {
            case '0': // TR
            aux_tpemprst = 'TR';
                break;
            case '1': // Pre-Fixado
            aux_tpemprst = 'PP';
                break;
            case '2': // Pos-Fixado
                aux_tpemprst = 'POS';
                break;
        if (aux_idenempr == 2){
            aux_cdfinemp = ' - ';
            aux_cdlcremp = ' - ';
            aux_vlemprst = ' - ';
            aux_qtpreemp = ' - ';
            aux_vlpreemp = ' - '; 
            aux_dstipemp = 'CC';
        }
 
        $('#divTabLiquidacoes > div > table > tbody').append('<tr></tr>');
        $('#divTabLiquidacoes > div > table > tbody > tr:last-child').append('<td><span>' + arrayLiquidacoes[i]['idseleca'] + '</span>' + arrayLiquidacoes[i]['idseleca'] + '<input type="hidden" id="indarray" name="indarray" value="' + i + '" /></td>');
        $('#divTabLiquidacoes > div > table > tbody > tr:last-child').append('<td>' + aux_cdfinemp + '</td>');
        $('#divTabLiquidacoes > div > table > tbody > tr:last-child').append('<td>' + aux_cdlcremp + '</td>');
        $('#divTabLiquidacoes > div > table > tbody > tr:last-child').append('<td>' + aux_nrctremp + '</td>');
        $('#divTabLiquidacoes > div > table > tbody > tr:last-child').append('<td>' + arrayLiquidacoes[i]['dtmvtolt'] + '</td>');
        $('#divTabLiquidacoes > div > table > tbody > tr:last-child').append('<td>' + aux_vlemprst + '</td>');
        $('#divTabLiquidacoes > div > table > tbody > tr:last-child').append('<td>' + aux_qtpreemp + '</td>');
        $('#divTabLiquidacoes > div > table > tbody > tr:last-child').append('<td>' + aux_vlpreemp + '</td>');
        $('#divTabLiquidacoes > div > table > tbody > tr:last-child').append('<td>' + aux_vlsdeved + '</td>');
        $('#divTabLiquidacoes > div > table > tbody > tr:last-child').append('<td>' + aux_dstipemp + '</td>'); 
 
    }

    var divRegistro = $('#divTabLiquidacoes > div.divRegistros');
    var tabela = $('table', divRegistro);

    divRegistro.css('height', '150px');

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '15px';
    arrayLargura[1] = '30px';
    arrayLargura[2] = '30px';
    arrayLargura[3] = '35px';
    arrayLargura[4] = '58px';
    arrayLargura[5] = '55px';
    arrayLargura[6] = '80px';
    arrayLargura[7] = '37px';
    arrayLargura[8] = '80px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'right';
    arrayAlinha[8] = 'right';
    arrayAlinha[9] = 'right';

    var metodo = 'controlaLiquidacoes();';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodo);

    hideMsgAguardo();
    bloqueiaFundo($('#divUsoGenerico'));

    $('#divUsoGenerico').centralizaRotinaH();

    $('#btContinuar', '#divTabLiquidacoes').focus();

    return false;
}

function selecionaLiquidacao() {

    var vlsdeved = parseFloat(arrayLiquidacoes[indarray]['vlsdeved'].replace(/[.R$ ]*/g, '').replace(',', '.'));

    arrayLiquidacoes[indarray]['idseleca'] = '*';
    tot_vlsdeved = tot_vlsdeved + vlsdeved;
    nrSelec++;
    mostraLiquidacoes('', operacao);

    return false;
}

function fechaLiquidacoes(operacao) {
	
    var dsctrliq = '';

    for (var i in arrayLiquidacoes) {
        if (arrayLiquidacoes[i]['idseleca'] == '*') {
            dsctrliq += formataContrato(arrayLiquidacoes[i]['nrctremp'].replace(/[. ]*/g, '')) + ',';
        }
    }

    dsctrliq = dsctrliq.slice(0, -1);
	
	if (dsctrliq != '' && qtmesblq != 0 && operacao[0] == 'I')        
		showConfirmacao('Deseja bloquear a oferta de cr&eacute;dito pr&eacute;-aprovado na conta durante o per&iacute;odo de ' + qtmesblq + ' mes(es)?',
						'Confirma&ccedil;&atilde;o - Ayllos', 
						'bloqueiaFundo( $(\'#divRotina\') );bloquear_pre_aprovado = true;fechaLiquidacoesAposConfirmacao("' + dsctrliq + '", "' + operacao + '");',
						'bloqueiaFundo( $(\'#divRotina\') );bloquear_pre_aprovado = false;fechaLiquidacoesAposConfirmacao("'+dsctrliq+'", "'+operacao+'");', 
						'sim.gif', 
						'nao.gif');
    else
		fechaLiquidacoesAposConfirmacao(dsctrliq, operacao);
    return false;
}

function fechaLiquidacoesAposConfirmacao(dsctrliq, operacao){
	
	$('#dsctrliq', '#' + nomeForm).val(dsctrliq);

	if ($('#dsctrliq', '#' + nomeForm).val() != '') {
		qualificaOperacao();
	} else {
        if ($('#cdlcremp', '#' + nomeForm).val() == 6901) {
            $('#idquapro', '#' + nomeForm).val(5);
            $('#dsquapro', '#' + nomeForm).val('CESSAO DE CREDITO');
            arrayProposta["dsquapro"] = "CESSAO DE CREDITO";
        }else{
		$('#idquapro', '#' + nomeForm).val(1);
            $('#dsquapro', '#' + nomeForm).val('OPERACAO NORMAL');        
        }		
	}

	limpaDivGenerica();
	fechaRotina($('#divUsoGenerico'), $('#divRotina'));
	showMsgAguardo('Aguarde, carregando...');

	validaLiquidacoes(true, operacao);
	
    return false;
}

function qualificaOperacao() {

    var dsctrliq = $('#dsctrliq', '#' + nomeForm).val();

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/emprestimos/liquidacoes/qualifica_operacao.php',
        async: false,
        data: {
            nrdconta: nrdconta, dsctrliq: dsctrliq,
            operacao: operacao, redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            try {

                if (response.indexOf('showError("error"') == -1) {

                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);
                    eval(response);

                } else {
                    hideMsgAguardo();
                    eval(response);
                }


            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });

    return false;

}

//***************************************************

//***************************************************
//** GERENCIAMENTO DA TELA COM OPÇÕES DA ALTERAÇÃO **
//***************************************************

//Função seleciona a linha referente ao item consultado/alterado
function SelecionaItem(name, tabela, rowid) {

    var divRegistro = tabela.parent();
    var linha = $('table > tbody > tr', divRegistro);

    $(linha, divRegistro).each(function(i) {
        if ($('input[name="' + name + '"]', $(this)).val() == rowid) {
            tabela.zebraTabela(i);
            $('tbody > tr:eq(' + i + ') > td', tabela).first().focus();
        }
    });
}

function controlaFoco(operacao) {
    $('#divConteudoOpcao').each(function () {
        $(this).find("#divBotoes > a").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > a").last().addClass("LastInputModal");
    });

    //Se estiver com foco na classe LastInputModal
    $(".LastInputModal").focus(function () {
        var pressedShift = false;

        $(this).bind('keyup', function (e) {
            if (e.keyCode == 16) {
                pressedShift = false;//Quando tecla shift for solta passa valor false 
    }
        })

        $(this).bind('keydown', function (e) {
            e.stopPropagation();
            e.preventDefault();

            if (e.keyCode == 13) {
                $(".LastInputModal").click();
            }
            if (e.keyCode == 16) {
                pressedShift = true;//Quando tecla shift for pressionada passa valor true 
            }
            if ((e.keyCode == 9) && pressedShift == true) {
                return setFocusCampo($(target), e, false, 0);
            }
            else if (e.keyCode == 9) {
                $(".FirstInputModal").focus();
    }
        });
    });

    $(".FirstInputModal").focus();
}

function controlaPesquisas() {

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var nomeCampo = '';
    var bo, procedure, titulo, qtReg, filtros, colunas, varAux, varMod, nrtopico, nritetop, varTip;

    // a variavel camposOrigem deve ser composta:
    // 1) os cincos primeiros campos são os retornados para o formulario de origem
    // 2) o sexto campo é o campo q será focado após o retorno ao formulario de origem, que
    // pelo requisito na maioria dos casos será o NUMERO do endereço
    var camposOrigem = 'nrcepend;dsendre1;nrendere;complend;nrcxapst;dsendre2;cdufresd;nmcidade';

    if (nomeForm == '') {
        return false;
    }

    // Atribui a classe lupa para os links de desabilita todos
    var lupas = $('a:not(.lupaFat)', '#' + nomeForm);

    lupas.addClass('lupa').css('cursor', 'auto');

    // Percorrendo todos os links
    lupas.each(function() {

        if (!$(this).prev().hasClass('campoTelaSemBorda'))
            $(this).css('cursor', 'pointer');

        $(this).prev().unbind('blur').bind('blur', function() {

            if (divError.css('display') == 'block') {
                return false;
            }

            rendimento = false;
            if (typeof (contRend) != "undefined") {
                for (var i = 1; i <= contRend; i++) {
                    if ($('#tpdrend' + i, '#frmDadosProp').val() == 6) {
                        rendimento = true;
                    }
                }
            }

            if (rendimento == true) {
                $('#dsjusren', '#frmDadosProp').habilitaCampo();
            } else {
                $('#dsjusren', '#frmDadosProp').desabilitaCampo();
                $('#dsjusren', '#frmDadosProp').val('');
            }

            if (!$(this).hasClass('campoTelaSemBorda')) {
                controlaPesquisas();
            }

            return false;

        });

        $(this).unbind('click').bind('click', function() {

            if ($(this).prev().hasClass('campoTelaSemBorda')) {
                return false;
            } else {
                // Obtenho o nome do campo anterior
                campoAnterior = $(this).prev().attr('name');

                // Nacionalidade
                if (campoAnterior == 'cdnacion') {
                    bo = 'b1wgen0059.p';
                    procedure = 'busca_nacionalidade';
                    titulo = 'Nacionalidade';
                    qtReg = '50';
                    filtros = 'Codigo;cdnacion;30px;N;|Nacionalidade;dsnacion;200px;S;';
                    colunas = 'Codigo;cdnacion;15%;left|Descrição;dsnacion;85%;left';
                    mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, divRotina);
                    return false;
                    // Naturalidade
                } else if (campoAnterior == 'dsnatura') {
                    bo = 'b1wgen0059.p';
                    procedure = 'Busca_Naturalidade';
                    titulo = 'Naturalidade';
                    qtReg = '50';
                    filtros = 'Naturalidade;dsnatura;200px;S;';
                    colunas = 'Naturalidade;dsnatura;100%;left';
                    mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, divRotina);
                    return false;
                } else if (campoAnterior == 'cdlcremp') {
                    bo = 'b1wgen0059.p';
                    procedure = 'busca_linhas_credito';
                    titulo = 'Linhas de Cr&eacute;dito';
                    qtReg = '20';
                    varFin = $('#cdfinemp', '#' + nomeForm).val();
                    varMod = (modalidade == 0) ? $("#cdmodali", '#' + nomeForm).val() : modalidade; //modalidade previamente carregada no cadastro da portabilidade
                    varTip = $("#tpemprst", '#' + nomeForm).val();
                    if ((varTip == 0) || (varTip == undefined)) {	
                        varTip = 1;
                    }
                    filtros = 'C&oacuted. Linha Cr&eacutedito;cdlcremp;30px;S;0|Descri&ccedil&atildeo;dslcremp;200px;S|;' + null + ';;N;;N|;' + null + ';;N;;N|;' + null + ';;N;;N|;cdfinemp;;;' + varFin + ';N|;cdmodali;;;' + varMod + ';N|;flgstlcr;;;yes;N|;tpprodut;;;' + varTip + ';N';
                    colunas = 'C&oacutedigo;cdlcremp;15%;right|Linha de Cr&eacutedito;dslcremp;40%;left|Taxa;txbaspre;10%;right|Prest. Max.;nrfimpre;10%;right|Garantia;dsgarant;25%;left';

                    mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, divRotina);

                    return false;
                } else if (campoAnterior == 'nrgarope') {
                    bo = 'b1wgen0059.p';
                    procedure = 'busca_seqrating';
                    titulo = 'Itens do Rating';
                    qtReg = '20';
                    nrtopico = (inpessoa == 1) ? '2' : '4';
                    nritetop = (inpessoa == 1) ? '2' : '2';
                    filtrosPesq = 'C&oacuted. Inf. Cadastral;nrgarope;30px;S;0|Inf. Cadastral;dsgarope;200px;S;|;nrtopico;;;' + nrtopico + ';N|;nritetop;;;' + nritetop + ';N|;flgcompl;;;no;N';
                    colunas = 'Seq. Item;nrseqite;20%;right|Descri&ccedil&atildeo Seq. Item;dsseqite;80%;left;dsseqit1';
                    mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
                    return false;

                } else if (campoAnterior == 'nrliquid') {
                    bo = 'b1wgen0059.p';
                    procedure = 'busca_seqrating';
                    titulo = 'Itens do Rating';
                    qtReg = '20';
                    nrtopico = (inpessoa == 1) ? '2' : '4';
                    nritetop = (inpessoa == 1) ? '3' : '3';
                    filtrosPesq = 'C&oacuted. Inf. Cadastral;nrliquid;30px;S;0|Inf. Cadastral;dsliquid;200px;S;|;nrtopico;;;' + nrtopico + ';N|;nritetop;;;' + nritetop + ';N|;flgcompl;;;no;N';
                    colunas = 'Seq. Item;nrseqite;20%;right|Descri&ccedil&atildeo Seq. Item;dsseqite;80%;left;dsseqit1';
                    mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
                    return false;

                } else if (campoAnterior == 'nrpatlvr') {
                    bo = 'b1wgen0059.p';
                    procedure = 'busca_seqrating';
                    titulo = 'Itens do Rating';
                    qtReg = '20';
                    nrtopico = (inpessoa == 1) ? '1' : '3';
                    nritetop = (inpessoa == 1) ? '8' : '9';
                    filtrosPesq = 'C&oacuted. Inf. Cadastral;nrpatlvr;30px;S;0|Inf. Cadastral;dspatlvr;200px;S;|;nrtopico;;;' + nrtopico + ';N|;nritetop;;;' + nritetop + ';N|;flgcompl;;;no;N';
                    colunas = 'Seq. Item;nrseqite;20%;right|Descri&ccedil&atildeo Seq. Item;dsseqite;80%;left;dsseqit1';
                    mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
                    return false;

                } else if (campoAnterior == 'nrperger') {
                    bo = 'b1wgen0059.p';
                    procedure = 'busca_seqrating';
                    titulo = 'Itens do Rating';
                    qtReg = '20';
                    nrtopico = '3';
                    nritetop = '11';
                    filtrosPesq = 'C&oacuted. Inf. Cadastral;nrperger;30px;S;0|Inf. Cadastral;dsperger;200px;S;|;nrtopico;;;' + nrtopico + ';N|;nritetop;;;' + nritetop + ';N|;flgcompl;;;no;N';
                    colunas = 'Seq. Item;nrseqite;20%;right|Descri&ccedil&atildeo Seq. Item;dsseqite;80%;left;dsseqit1';
                    mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
                    return false;

                } else if (campoAnterior == 'cdfinemp') {
                    varAux = $('#cdlcremp', '#' + nomeForm).val();
                    filtros = 'Finalidade do Empr.;cdfinemp;30px;S;0|Descri&ccedil&atildeo;dsfinemp;200px;S;|;flgstfin;;;1;N|;cdlcrhab;;;' + varAux + ';N';
                    colunas = 'C&oacutedigo;cdfinemp;20%;right|Finalidade;dsfinemp;80%;left|Flag;flgstfin;0%;left;;N';
                    var vFuncao = (nomeForm == 'frmSimulacao') ? 'habilitaModalidade("")' : '';
                    
                    //Exibir a pesquisa
                    mostraPesquisa("zoom0001", "BUSCAFINEMPR", "Finalidade do Empr&eacutestimo", "30", filtros, colunas, divRotina, vFuncao);

                    return false;
                } else if (campoAnterior == 'nrctaava') {

                    mostraPesquisaAssociado('nrctaava', nomeForm, divRotina);

                    return false;
                } else if (in_array(campoAnterior, ['tpdrend1', 'tpdrend2', 'tpdrend3', 'tpdrend4', 'tpdrend5', 'tpdrend6'])) {
                    bo = 'b1wgen0059.p';
                    procedure = 'busca_tipo_rendimento';
                    titulo = 'Origem Rendimento';
                    qtReg = '30';
                    colunas = 'C&oacutedigo;tpdrendi;20%;right|Origem Rendimento;dsdrendi;80%;left';

                    if (campoAnterior == 'tpdrend1') {
                        campoDescricao = 'dsdrend1';
                    }
                    else if (campoAnterior == 'tpdrend2') {
                        campoDescricao = 'dsdrend2';
                    }
                    else if (campoAnterior == 'tpdrend3') {
                        campoDescricao = 'dsdrend3';
                    }
                    else if (campoAnterior == 'tpdrend4') {
                        campoDescricao = 'dsdrend4';
                    }
                    else if (campoAnterior == 'tpdrend5') {
                        campoDescricao = 'dsdrend5';
                    }
                    else if (campoAnterior == 'tpdrend6') {
                        campoDescricao = 'dsdrend6';
                    }

                    filtrosPesq = 'C&oacuted. Origem;' + campoAnterior + ';30px;S;0|Descri&ccedil&atildeo;' + campoDescricao + ';200px;S;';
                    mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);
                    return true;

                    // Pesquisa Endereço
                } else if (campoAnterior == 'nrcepend') {
                    mostraPesquisaEndereco(nomeForm, camposOrigem, divRotina);
                    return false;
                }
            }
        });
    });

    // Controle da lupaFat
    var lupaFat = $('.lupaFat', '#frmDadosPropPj');

    lupaFat.css('cursor', 'pointer');
    lupaFat.unbind('click').bind('click', function() {
        auxind = '';
        mostraFaturamento('BT');
        return false;
    });


    // Tipo Rendimento
    $('#tpdrend1,#tpdrend2,#tpdrend3,#tpdrend4,#tpdrend5,#tpdrend6', '#' + nomeForm).unbind('change').bind('change', function() {
        bo = 'b1wgen0059.p';
        titulo = 'Origem Rendimento';
        procedure = 'busca_tipo_rendimento';
        filtrosDesc = 'tpdrendi|' + $(this).val();

        if ($(this).attr('name') == 'tpdrend1') {
            campoDescricao = 'dsdrend1';
            nomeCampo = 'tpdrend1';
        }
        else if ($(this).attr('name') == 'tpdrend2') {
            campoDescricao = 'dsdrend2';
            nomeCampo = $(this).attr('name');
        }
        else if ($(this).attr('name') == 'tpdrend3') {
            campoDescricao = 'dsdrend3';
            nomeCampo = $(this).attr('name');
        }
        else if ($(this).attr('name') == 'tpdrend4') {
            campoDescricao = 'dsdrend4';
            nomeCampo = $(this).attr('name');
        }
        else if ($(this).attr('name') == 'tpdrend5') {
            campoDescricao = 'dsdrend5';
            nomeCampo = $(this).attr('name');
        }
        else if ($(this).attr('name') == 'tpdrend6') {
            campoDescricao = 'dsdrend6';
            nomeCampo = $(this).attr('name');
        }

        buscaDescricao(bo, procedure, titulo, nomeCampo, campoDescricao, $(this).val(), 'dsdrendi', filtrosDesc, nomeForm);

    });



    // Finalidade de emprestimo
    $('#cdfinemp', '#' + nomeForm).unbind('change').bind('change', function() {
        bo = 'zoom0001';
        procedure = 'BUSCAFINEMPR';
        titulo = 'Finalidade do Empr&eacute;stimo';
        filtrosDesc = 'flgstfin|1;nriniseq|1;nrregist|30';
        buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsfinemp', $(this).val(), 'dsfinemp', filtrosDesc, nomeForm);

        if (nomeForm != 'frmSimulacao') {

            carregaDadosPropostaFinalidade();
        }
    });


    // Linha de Credito
    $('#cdlcremp', '#' + nomeForm).unbind('change').bind('change', function() {
        // Alterado para quando a linha de credito for (Cessao de Cartao) a
        // Qualificacao da Operacao recebe ( 5 - Cessao de Cartao)
        if($('#cdlcremp', '#' + nomeForm).val() == 6901){
            $('#idquapro', '#' + nomeForm).val(5);
            $('#dsquapro', '#' +nomeForm).val('CESSAO DE CREDITO');
            arrayProposta["dsquapro"] = "CESSAO DE CREDITO";
        }else{
            $('#idquapro', '#' + nomeForm).val(1);
            $('#dsquapro', '#' + nomeForm).val('OPERACAO NORMAL'); 
        }

        bo = 'b1wgen0059.p';
        procedure = 'busca_linhas_credito';
        titulo = 'Linhas de Cr&eacute;dito';
        varAux = $('#cdfinemp', '#' + nomeForm).val();
        //modalidade previamente carregada no cadastro da portabilidade
        varMod = (modalidade == 0) ? $("#cdmodali", '#' + nomeForm).val() : modalidade; //modalidade previamente carregada no cadastro da portabilidade        
        varMod = (varMod == undefined) ? 0 : varMod;
        varTip = $("#tpemprst", '#' + nomeForm).val();
        if ((varTip == 0) || (varTip == undefined)) {
            varTip = 1;
        }
        filtrosDesc = 'flgstlcr|yes;cdfinemp|' + varAux + ';cdmodali|' + varMod + ';tpprodut|' + varTip;
        buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dslcremp', $(this).val(), 'dslcremp', filtrosDesc, nomeForm);
		
		if (nomeForm != 'frmSimulacao') {
            carregaDadosPropostaLinhaCredito();
        }
    });

    // Quantidade de dias de liberacao
    $('#qtdialib', '#' + nomeForm).unbind('change').bind('change', function() {

        showMsgAguardo('Aguarde, calculando data de libera&ccedil;&atilde;o ...');

        $.ajax({
            type: 'POST',
            dataType: 'script',
            url: UrlSite + 'telas/atenda/emprestimos/retorna_data_util.php',
            data: {
                dtmvtolt: arrayProposta['dtmvtolt'],
                qtdialib: $(this).val(),
                redirect: 'html_ajax'
            },
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function(response) {
                eval(response);
            }
        });
    });

    $('#nrgarope', '#' + nomeForm).unbind('change').bind('change', function() {
        bo = 'b1wgen0059.p';
        procedure = 'busca_seqrating';
        titulo = 'Garantia';
        nrtopico = (inpessoa == 1) ? '2' : '4';
        nritetop = (inpessoa == 1) ? '2' : '2';
        filtrosDesc = 'nrtopico|' + nrtopico + ';nritetop|' + nritetop + ';flgcompl|no;nrseqite|' + $(this).val();
        buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsgarope', $(this).val(), 'dsseqit1', filtrosDesc, nomeForm);
    });

    $('#nrliquid', '#' + nomeForm).unbind('change').bind('change', function() {
        bo = 'b1wgen0059.p';
        procedure = 'busca_seqrating';
        titulo = 'Liquidez';
        nrtopico = (inpessoa == 1) ? '2' : '4';
        nritetop = (inpessoa == 1) ? '3' : '2';
        filtrosDesc = 'nrtopico|' + nrtopico + ';nritetop|' + nritetop + ';flgcompl|no;nrseqite|' + $(this).val();
        buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsliquid', $(this).val(), 'dsseqit1', filtrosDesc, nomeForm);
    });

    $('#nrpatlvr', '#' + nomeForm).unbind('change').bind('change', function() {
        bo = 'b1wgen0059.p';
        procedure = 'busca_seqrating';
        titulo = 'Patrim&ocircnio Livre';
        nrtopico = (inpessoa == 1) ? '1' : '3';
        nritetop = (inpessoa == 1) ? '8' : '9';
        filtrosDesc = 'nrtopico|' + nrtopico + ';nritetop|' + nritetop + ';flgcompl|no;nrseqite|' + $(this).val();
        buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dspatlvr', $(this).val(), 'dsseqit1', filtrosDesc, nomeForm);
    });

    $('#nrperger', '#' + nomeForm).unbind('change').bind('change', function() {
        bo = 'b1wgen0059.p';
        procedure = 'busca_seqrating';
        titulo = 'Patrim&ocircnio Livre';
        nrtopico = '3';
        nritetop = '11';
        filtrosDesc = 'nrtopico|' + nrtopico + ';nritetop|' + nritetop + ';flgcompl|no;nrseqite|' + $(this).val();
        buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsperger', $(this).val(), 'dsseqit1', filtrosDesc, nomeForm);
    });

    $('#nrcepend', '#' + nomeForm).buscaCEP(nomeForm, camposOrigem, divRotina);

    return false;
}

function strSelect(str, campo, form) {

    var arrayOption = new Array();
    var select = $('#' + campo, '#' + form);

    arrayOption = str.split(',');

    for (var i = arrayOption.length - 1; i >= 0; i--) {
        select.append('<option value="' + arrayOption[i] + '">' + arrayOption[i] + '</option>');
    }

    return false;

}

function limpaForm(form) {

    var aux = '';

    if (form == 'frmDadosAval') {
        aux = $('#qtpromis', '#' + form).val();
    }

    $('#' + form).limpaFormulario();

    if (form == 'frmDadosAval') {

        if (operacao == 'A_DADOS_AVAL' || operacao == 'IA_DADOS_AVAL') {
            var atual = contAvalistas - 1;
            arrayAvalistas[atual]['nrctaava'] = '';
            arrayAvalistas[atual]['cdnacion'] = '';
            arrayAvalistas[atual]['dsnacion'] = '';
            arrayAvalistas[atual]['tpdocava'] = '';
            arrayAvalistas[atual]['nmconjug'] = '';
            arrayAvalistas[atual]['tpdoccjg'] = '';
            arrayAvalistas[atual]['dsendre1'] = '';
            arrayAvalistas[atual]['nrfonres'] = '';
            arrayAvalistas[atual]['nmcidade'] = '';
            arrayAvalistas[atual]['nrcepend'] = '';
            arrayAvalistas[atual]['nmdavali'] = '';
            arrayAvalistas[atual]['nrcpfcgc'] = '';
            arrayAvalistas[atual]['nrdocava'] = '';
            arrayAvalistas[atual]['nrcpfcjg'] = '';
            arrayAvalistas[atual]['nrdoccjg'] = '';
            arrayAvalistas[atual]['dsendre2'] = '';
            arrayAvalistas[atual]['dsdemail'] = '';
            arrayAvalistas[atual]['cdufresd'] = '';
            arrayAvalistas[atual]['bensaval'].length = 0;
            // Daniel
            arrayAvalistas[atual]['inpessoa'] = '';
            arrayAvalistas[atual]['dtnascto'] = '';

        }

        $('#qtpromis', '#' + form).val(aux);
        iniciaAval();
    }
    else if (form == 'frmIntevAnuente') {
        iniciaInterv();
    }

    $('.campo:first', '#' + form).focus();

    return false;
}


function showConfirmacaoEfetiva() {
    showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'efetivaProposta();', 'bloqueiaFundo( $(\'#divRotina\') );', 'sim.gif', 'nao.gif');
}

function efetivaProposta() {

    showMsgAguardo('Aguarde, efetivando a proposta...');
    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();

    nrdconta = arrayStatusApprov['nrdconta'];
    nrctremp = arrayStatusApprov['nrctremp'];
    dtdpagto = arrayStatusApprov['dtdpagto'];

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/efetiva_proposta.php',
        data: {
            nrdconta: nrdconta, idseqttl: idseqttl,
            nrctremp: nrctremp, insitapv: insitapv,
            dtdpagto: dtdpagto, redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            eval(response);
        }
    });

    return false;
}

function verificaBotaoParcelas(operacao)
{
    var tpemprst = $('#tpemprst', '#frmNovaProp').val();
    if (tpemprst == 1)
    {
        switch (operacao)
        {
            case 'TI':
                atualizaArray('I_DADOS_AVAL');
                return false;
                break;
            case 'I_INICIO':
                atualizaArray('I_DADOS_AVAL');
                return false;
                break;
            case 'A_VALOR':
                atualizaArray('V_VALOR');
                return false;
                break;
            case 'A_NOVA_PROP':
                atualizaArray('A_DADOS_AVAL');
                return false;
                break;
            case 'A_INICIO':
                atualizaArray('A_DADOS_AVAL');
                return false;
                break;
            case 'TC':
                controlaOperacao('C_COMITE_APROV');
                return false;
                break;
            case 'CF':
                controlaOperacao('C_COMITE_APROV');
                return false;
                break;
        }
    }
    else
    {
        switch (operacao)
        {
            case 'TI':
                atualizaArray('I_DADOS_AVAL');
                return false;
                break;
            case 'I_INICIO':
                atualizaArray('I_DADOS_AVAL');
                return false;
                break;
            case 'A_VALOR':
                atualizaArray('V_VALOR');
                return false;
                break;
            case 'A_NOVA_PROP':
                atualizaArray('A_DADOS_AVAL');
                return false;
                break;
            case 'A_INICIO':
                atualizaArray('A_DADOS_AVAL');
                return false;
                break;
            case 'TC':
                controlaOperacao('C_COMITE_APROV');
                return false;
                break;
            case 'CF':
                controlaOperacao('C_COMITE_APROV');
                return false;
                break;
        }
    }
}

function voltarAlteraTudo()
{
    tpemprst = arrayProposta['tpemprst'];
    if (tpemprst == 1)
        controlaOperacao('A_V_PARCELAS');
    else
        controlaOperacao('A_INICIO');

    return false;
}

function avancarAvalista(operacao)
{
    if (operacao == 'T_AVALISTA1' && arrayMensagemAval[1]['cdavalis'] == 2) {
        dsmensag = arrayMensagemAval[1]['dsmensag'];
        controlaOperacao('T_AVALISTA2');
        return false;
    } else {
        showConfirmacaoEfetiva();
    }
}

function voltarInclusaoAval()
{
    tpemprst = arrayProposta['tpemprst'];
    if (tpemprst == 1)
        controlaOperacao('I_V_PARCELAS');
    else
        controlaOperacao('I_INICIO');

    return false;
}

function validaJustificativa(operacao) {

    var rendimento = false;

    for (var i = 1; i <= contRend; i++) {
        if ($('#tpdrend' + i, '#frmDadosProp').val() == 6) {
            rendimento = true;

        }
    }

    if (rendimento == true && $('#dsjusren', '#frmDadosProp').val() == '') {
        showError('inform', 'Deve ser informado uma justificativa.', 'Alerta - Ayllos', '$(\'#dsjusren\',\'#frmDadosProp\').focus;');
        return false;
    } else {
        atualizaArray(operacao);
    }


}


// Função para fechar div com mensagens de alerta
function encerraMsgsGrupoEconomico() {

    // Esconde div
    $("#divMsgsGrupoEconomico").css("visibility", "hidden");

    $("#divListaMsgsGrupoEconomico").html("&nbsp;");

    // Esconde div de bloqueio
    unblockBackground();
    blockBackground(parseInt($("#divRotina").css("z-index")));

    eval(dsmetodo);

    return false;

}

function mostraMsgsGrupoEconomico() {


    if (strHTML != '') {

        // Coloca conteúdo HTML no div
        $("#divListaMsgsGrupoEconomico").html(strHTML);
        $("#divMensagem").html(strHTML2);

        // Mostra div
        $("#divMsgsGrupoEconomico").css("visibility", "visible");

        exibeRotina($("#divMsgsGrupoEconomico"));

        // Esconde mensagem de aguardo
        hideMsgAguardo();

        // Bloqueia conteúdo que está átras do div de mensagens
        blockBackground(parseInt($("#divMsgsGrupoEconomico").css("z-index")));

    }

    return false;

}

function formataGrupoEconomico() {

    var divRegistro = $('div.divRegistros', '#divMsgsGrupoEconomico');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({'height': '140px'});

    $('#divListaMsgsGrupoEconomico').css({'height': '200px'});
    $('#divMensagem').css({'width': '250px'});

    var ordemInicial = new Array();

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';

    tabela.formataTabela(ordemInicial, '', arrayAlinha);

    return false;

}

function busca_uf_pa_ass() {

    var xnrdconta = normalizaNumero(nrdconta);

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/emprestimos/busca_uf_pa_ass.php',
        data: {
            nrdconta: xnrdconta,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            showError('error', 'Não foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            eval(response);
        }
    });

}

function calculaCet(operacao) {

    showMsgAguardo('Aguarde, calculando o cet...');

    var vlemprst = $('#vlemprst', '#frmNovaProp').val();
    var dtdpagto = $('#dtdpagto', '#frmNovaProp').val();
    var dtlibera = $('#dtlibera', '#frmNovaProp').val();
    var vlpreemp = $('#vlpreemp', '#frmNovaProp').val();
    var qtpreemp = $('#qtpreemp', '#frmNovaProp').val();
    var cdlcremp = $('#cdlcremp', '#frmNovaProp').val();
    var tpemprst = $('#tpemprst', '#frmNovaProp').val();
    var cdfinemp = $('#cdfinemp', '#frmNovaProp').val();    

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/emprestimos/calculo_cet.php',
        data: {
            vlemprst: vlemprst,
            dtdpagto: dtdpagto,
            dtlibera: dtlibera,
            vlpreemp: vlpreemp,
            qtpreemp: qtpreemp,
            inpessoa: inpessoa,
            cdlcremp: cdlcremp,
            tpemprst: tpemprst,
            nrctremp: nrctremp,
            nrdconta: nrdconta,
            cdfinemp: cdfinemp,
            operacao: operacao,
       portabilidade: possuiPortabilidade,
            dsctrliq: arrayProposta['dsctrliq'],
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            hideMsgAguardo();
            eval(response);
            return false;
        }
    });
    return false;
}

function efetuar_consultas(insolici,operacao) {

    if (insolici == 1) {
        showMsgAguardo('Aguarde, efetuando consultas ...');
    }
    else {
        showMsgAguardo('Aguarde, carregando ...');
    }

    var flvalest = 0;
    if (operacao == 'CONSULTAS'){
        flvalest = 1;
    }
       
    $.ajax({
        type: 'POST',
        url: UrlSite + 'includes/consultas_automatizadas/efetuar_consultas.php',
        data: {
            nrdconta: nrdconta,
            nrdocmto: nrctremp,
            inprodut: 1,
            insolici: insolici,
            flvalest: flvalest,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            hideMsgAguardo();
            eval(response);
            return false;
        }
    });
    return false;
}

function controlaSocios(operacao, cdcooper, idSocio, qtSocios) {

    if (operacao == "A_PROTECAO_TIT") {
        if ($("#nrinfcad", "#frmOrgaos").val() != undefined) {
            arrayProtCred['dtcnsspc'] = $("#dtcnsspc", "#frmOrgaos").val();
            arrayProtCred['nrinfcad'] = $("#nrinfcad", "#frmOrgaos").val();
        }
    }

    if (idSocio > qtSocios) {
        if (operacao.substr(0, 1) == 'C') {
            controlaOperacao('C_COMITE_APROV');
        } else {
            atualizaArray('A_BUSCA_OBS', cdcooper);
        }
    }
    else {
        controlaOperacao(operacao.substr(0, 2) + "PROTECAO_SOC");
    }

}

function salvaQuestionario(operacao) {

    var arr_perguntas = new Array();
    var arr_respostas = new Array();
    var ele_perguntas = $('label[name="pergunta"]', '#frmQuestionario');
    var ele_respostas = $('input[type="text"],select', '#frmQuestionario');
    var flg_valida = true;

    ele_respostas.removeClass('campoErro');

    // Validar se as perguntas obrigatorias foram respondidas
    $(ele_respostas.get().reverse()).each(function(e) {

        var inobriga = $(this).attr('inobriga');

        // Se a pergunta e' obrigatoria e nao foi respondida
        if (inobriga == 1 && $(this).val() == '' && isHabilitado($(this))) {
            showError('error', '375 - O campo deve ser preenchido.', 'Alerta - Ayllos', 'focaCampoErro("' + $(this).attr('id') + '" , "frmQuestionario");bloqueiaFundo(divRotina);');
            flg_valida = false;
            return;
        }

    });

    if (!flg_valida) {
        return false;
    }

    // Armazenar as perguntas
    ele_perguntas.each(function(e) {
        arr_perguntas.unshift(this.id);
    });

    // Armazenar as respostas
    ele_respostas.each(function(e) {
        arr_respostas.unshift(this.value);
    });

    // Armazenar perguntas e respostas
    ele_respostas.each(function(e) {
        arrayQuestionario[ arr_perguntas.pop() ] = this.name.substr(0, 1) + "-" + arr_respostas.pop();
    });

    resposta = '';

    // Concatenar todas as respostas em uma String
    for (index in arrayQuestionario) {

        resposta += '<respostas>' +
                '<nrseqper>' + index + '</nrseqper>';

        if (arrayQuestionario[index].substr(0, 1) == 'r') {
            resposta += '<nrseqres>' + arrayQuestionario[index].substr(2) + '</nrseqres>' +
                    '<dsrespos></dsrespos>';
        } else {
            resposta += '<dsrespos>' + removeAcentos(removeCaracteresInvalidos(arrayQuestionario[index].substr(2))) + '</dsrespos>' +
                    '<nrseqres></nrseqres>';
        }

        resposta += '</respostas>';
    }

    if (operacao == 'A' || operacao == 'I') {
        atualizaArray(operacao + '_ALIENACAO');
    }
    else {
        controlaOperacao(operacao);
    }

}

function carregaDadosPropostaFinalidade() {

    var tpemprst = $('#tpemprst', '#frmNovaProp').val();
    var cdfinemp = $('#cdfinemp', '#frmNovaProp').val();
    var cdlcremp = $('#cdlcremp', '#frmNovaProp').val();

    showMsgAguardo('Aguarde, carregando os dados...');

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/emprestimos/carrega_dados_proposta_finalidade.php',
        data: {
            tpemprst: tpemprst,
            cdfinemp: cdfinemp,
            cdlcremp: cdlcremp,
            nrdconta: nrdconta,
            dsctrliq: dsctrliq,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            hideMsgAguardo();
            bloqueiaFundo(divRotina);
            eval(response);
            return false;
        }
    });
    return false;
}

function carregaDadosPropostaLinhaCredito() {

    var cdfinemp = $('#cdfinemp', '#frmNovaProp').val();
    var cdlcremp = $('#cdlcremp', '#frmNovaProp').val();
    var dsctrliq = $('#dsctrliq', '#frmNovaProp').val();

    showMsgAguardo('Aguarde, carregando os dados...');

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/emprestimos/carrega_dados_proposta_linha_credito.php',
        data: {
            cdfinemp: cdfinemp,
            cdlcremp: cdlcremp,
            nrdconta: nrdconta,     
            dsctrliq: dsctrliq,            
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            hideMsgAguardo();
            bloqueiaFundo(divRotina);
            eval(response);
            return false;
        }
    });
    return false;
}

function confirmaInclusaoMenor(cddopcao, operacao, inconfir) {

    // Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, carregando...');

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/principal.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            operacao: operacao,
            cddopcao: cddopcao,
            inconfir: inconfir,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1) {
                $('#divConteudoOpcao').html(response);
            } else {

                eval(response);
                controlaFoco(operacao);
            }

            return false;
        }
    });

}

function removeAcentos(str) {
    return str.replace(/[àáâãäå]/g, "a").replace(/[ÀÿÂÃÄÅ]/g, "A").replace(/[ÒÓÔÕÖØ]/g, "O").replace(/[òóôõöø]/g, "o").replace(/[ÈÉÊË]/g, "E").replace(/[èéêë]/g, "e").replace(/[Ç]/g, "C").replace(/[ç]/g, "c").replace(/[ÌÿÎÿ]/g, "I").replace(/[ìíîï]/g, "i").replace(/[ÙÚÛÜ]/g, "U").replace(/[ùúûü]/g, "u").replace(/[ÿ]/g, "y").replace(/[Ñ]/g, "N").replace(/[ñ]/g, "n");
}

function removeCaracteresInvalidos(str) {
    return str.replace(/[^A-z0-9\sÀÿÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÿÎÿìíîïÙÚÛÜùúûüÿÑñ\!\@\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\>\<]/g, "");
}
function direcionaAlteracao(tipo_altera) {

    if (possuiPortabilidade == 'N') {
        controlaOperacao(tipo_altera);
    } else if (possuiPortabilidade == 'S') {
        controlaOperacao('PORTAB_CRED_A');
    }

}

/**
 * 
 * @param Integer cdcooper
 * @param Integer nrdconta
 * @param Integer nrctremp
 * @param String tipo_consulta ('PROPOSTA', 'CONTRATO')
 * @returns carrega os campos em tela
 */
function carregaCamposPortabilidade(cdcooper, nrdconta, nrctremp, tipo_consulta)
{

    if ((typeof arrayDadosPortabilidade['nrcnpjbase_if_origem'] == 'undefined' ||
            typeof arrayDadosPortabilidade['nrcontrato_if_origem'] == 'undefined' ||
            typeof arrayDadosPortabilidade['nmif_origem'] == 'undefined' ||
            typeof arrayDadosPortabilidade['cdmodali'] == 'undefined') && $.trim(nrctremp) != '')
    {
        // Mostra mensagem de aguardo
        showMsgAguardo('Aguarde, carregando...');

        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/emprestimos/portabilidade/ajax_portabilidade.php",
            dataType: "json",
            async: false,
            data: {
                flgopcao: 'CP',
                cdcooper: cdcooper,
                nrdconta: nrdconta,
                nrctremp: nrctremp,
                tipo_consulta: tipo_consulta
            },
            success: function(data) {
                if (data.rows > 0) {
                    $.each(data.records, function(i, item) {
                        if (i == 0) {
                            //CNPJ IF Credora
                            $("#nrcnpjbase_if_origem", "#frmPortabilidadeCredito").val(item.nrcnpjbase_if_origem);
                            //Nome IF Credora
                            $("#nmif_origem", "#frmPortabilidadeCredito").val(item.nmif_origem);
                            //numero de contrato
                            $("#nrcontrato_if_origem", "#frmPortabilidadeCredito").val(item.nrcontrato_if_origem);
                            //modalidade
                            $("#frmPortabilidadeCredito #cdmodali_portabilidade option").each(function() {
                                if (item.cdmodali == $(this).val()) {
                                    $(this).attr('selected', 'selected');
                                }
                            });
                            //numero unico portabilidade
                            $("#nrunico_portabilidade", "#frmPortabilidadeCredito").val(item.nrunico_portabilidade);
                            //situacao da portabilidade
                            $("#dssit_portabilidade", "#frmPortabilidadeCredito").val(item.dssit_portabilidade);

                            arrayDadosPortabilidade['nrcnpjbase_if_origem'] = item.nrcnpjbase_if_origem;
                            arrayDadosPortabilidade['nrcontrato_if_origem'] = item.nrcontrato_if_origem;
                            arrayDadosPortabilidade['nmif_origem'] = item.nmif_origem;
                            arrayDadosPortabilidade['cdmodali'] = item.cdmodali;
                            arrayDadosPortabilidade['nrunico_portabilidade'] = item.nrunico_portabilidade;
                            arrayDadosPortabilidade['dssit_portabilidade'] = item.dssit_portabilidade;
                        }
                        hideMsgAguardo();
                        bloqueiaFundo(divRotina);
                    });
                } else {
                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);
                    eval(data);
                }
            }
        });
    } else {

        // Mostra mensagem de aguardo
        showMsgAguardo('Aguarde, carregando...');

        //CNPJ IF Credora
        $("#nrcnpjbase_if_origem", "#frmPortabilidadeCredito").val(arrayDadosPortabilidade['nrcnpjbase_if_origem']);
        //Nome IF Credora
        $("#nmif_origem", "#frmPortabilidadeCredito").val(arrayDadosPortabilidade['nmif_origem']);
        //numero de contrato
        $("#nrcontrato_if_origem", "#frmPortabilidadeCredito").val(arrayDadosPortabilidade['nrcontrato_if_origem']);
        //valida se a modalidade foi informada na tela de cadastro de simulacao
        var mod = (typeof aux_cdmodali_simulacao == 'undefined' || aux_cdmodali_simulacao == '') ? arrayDadosPortabilidade['cdmodali'] : aux_cdmodali_simulacao;
        //modalidade
        $("#frmPortabilidadeCredito #cdmodali_portabilidade option").each(function() {
            if (mod == $(this).val()) {
                $(this).attr('selected', 'selected');
            }
        });
        //numero unico portabilidade
        $("#nrunico_portabilidade", "#frmPortabilidadeCredito").val(arrayDadosPortabilidade['nrunico_portabilidade']);
        //situacao da portabilidade
        $("#dssit_portabilidade", "#frmPortabilidadeCredito").val(arrayDadosPortabilidade['dssit_portabilidade']);

        hideMsgAguardo();
        bloqueiaFundo(divRotina);
    }

}


function cadastraPortabilidade(nrdconta, nrctremp, tpoperacao, cnpj, nome, contrato)
{

    showMsgAguardo("Aguarde, cadastrando portabilidade...");

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/emprestimos/portabilidade/ajax_portabilidade.php",
        dataType: "json",
        async: false,
        data: {
            flgopcao: 'GP',
            nrdconta: nrdconta,
            nrctremp: nrctremp,
            tpoperacao: tpoperacao,
            nrcnpjbase_if_origem: cnpj,
            nmif_origem: nome,
            nrcontrato_if_origem: contrato
        },
        success: function(data) {
            if (data.erro == 'S') {
                showError('error', data.msg, 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            } else {
                //limpa variaveis de controle
                possuiPortabilidade = '';
                cadastroNovo = '';
                numeroProposta = '';
                //limpa array de informacoes da portabilidade
                arrayDadosPortabilidade = new Array();
                aux_cdmodali_simulacao = '';
            }
        }
    });

    hideMsgAguardo();

}

/**
 * Funcao para validacao do cadastro de portabilidade
 * @param String operacao
 * @returns {Boolean}
 */
function validaPortabilidadeCredito(operacao)
{

    var retorno = '';
    var formulario = '#frmPortabilidadeCredito';

    var cnpj = $("#nrcnpjbase_if_origem", formulario).val();
    var nome = $("#nmif_origem", formulario).val();
    var contrato = $("#nrcontrato_if_origem", formulario).val();
    modalidade = $("#cdmodali_portabilidade option:selected", formulario).val();

    showMsgAguardo("Aguarde, validando dados...");

    if (operacao == 'PORTAB_CRED_I') {

        //CNPJ
        if ($.trim(cnpj) == '' || cnpj == 0) {
            showError("error", "Informe o CNPJ da Instituicao Credora.", "Alerta - Ayllos", "$('#nrcnpjbase_if_origem', '" + formulario + "').val('').focus();hideMsgAguardo();");
            return false;
        } else { //valida CNPJ informado
            retorno = validaCpfCnpj(cnpj, 2);
            if (retorno === false) {
                showError("error", "CNPJ inválido.", "Alerta - Ayllos", "$('#nrcnpjbase_if_origem', '" + formulario + "').val('').focus();hideMsgAguardo();");
                return false;
            }
        }

        //NOME
        if ($.trim(nome) == '') {
            showError("error", "Informe o Nome da Instituicao Credora.", "Alerta - Ayllos", "$('#nmif_origem', '" + formulario + "').val('').focus();hideMsgAguardo();");
            return false;
        }

        //CONTRATO
        if ($.trim(contrato) == '' || contrato == 0) {
            showError("error", "Informe o numero do Contrato na Instituicao Credora.", "Alerta - Ayllos", "$('#nrcontrato_if_origem', '" + formulario + "').val('').focus();hideMsgAguardo();");
            return false;
        } else {
            var caracEspeciais = '!@#$%&*()-_+=�:<>;/?[]{}���������\\|\',.�`�^~';
            var cnpjValido = retiraCaracteres(contrato, caracEspeciais, false);
            $("#nrcontrato_if_origem", formulario).val(cnpjValido);
        }

        //MODALIDADE
        if ($.trim(modalidade) == '' || modalidade == 0) {
            showError("error", "Selecione uma Modalidade.", "Alerta - Ayllos", "$('#cdmodali_portabilidade', '" + formulario + "').val('').focus();hideMsgAguardo();");
            return false;
        }

    } else if (operacao == 'PORTAB_CRED_A') {

        //MODALIDADE
        if ($.trim(modalidade) == '' || modalidade == 0) {
            showError("error", "Selecione uma Modalidade.", "Alerta - Ayllos", "$('#cdmodali_portabilidade', '" + formulario + "').val('').focus();hideMsgAguardo();");
            return false;
        }

        //CONTRATO
        if ($.trim(contrato) == '' || contrato == 0) {
            showError("error", "Preencha Contrato Original.", "Alerta - Ayllos", "$('#nrcontrato_if_origem', '" + formulario + "').val('').focus();hideMsgAguardo();");
            return false;
        } else {
            var caracEspeciais = '!@#$%&*()-_+=�:<>;/?[]{}���������\\|\',.�`�^~';
            var cnpjValido = retiraCaracteres(contrato, caracEspeciais, false);
            $("#nrcontrato_if_origem", formulario).val(cnpjValido);
        }
    }

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/emprestimos/portabilidade/ajax_portabilidade.php",
        dataType: "json",
        async: false,
        data: {
            flgopcao: 'VP',
            operacao: operacao,
            nrcnpjbase_if_origem: cnpj,
            nmif_origem: nome,
            nrcontrato_if_origem: contrato,
            cdmodali_portabilidade: modalidade
        },
        success: function(data) {
            if (data.erro == 'S') {
                showError('error', data.msg, 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            } else {
                $.each(data.records, function(i, item) {
                    if (item.nrcnpjbase_if_origem != 'S') {
                        if (item.nrcnpjbase_if_origem == 'N') {
                            showError("error", "CNPJ da Inst. Credora. Invalido", "Alerta - Ayllos", "$('#nrcnpjbase_if_origem', '" + formulario + "').val('').focus();hideMsgAguardo();");
                            return false;
                        } else if (item.nrcnpjbase_if_origem == 'IN') { //erro retornado quando se tratar de um CNPJ de uma cooperativa
                            showError("error", "Portabilidade de forma eletronica nao permitida entre cooperativas do Sistema.", "Alerta - Ayllos", "$('#nrcnpjbase_if_origem', '" + formulario + "').val('').focus();hideMsgAguardo();");
                            return false;
                        }
                    } else if (item.nrcontrato_if_origem == 'N') {
                        showError("error", "Contrato Original Invalido", "Alerta - Ayllos", "$('#nrcontrato_if_origem', '" + formulario + "').val('').focus();hideMsgAguardo();");
                        return false;
                    } else if (item.nmif_origem == 'N') {
                        showError("error", "Nome da Inst. Credora. Invalido", "Alerta - Ayllos", "$('#nmif_origem', '" + formulario + "').val('').focus();hideMsgAguardo();");
                        return false;
                    } else if (item.cdmodali == 'N') {
                        showError("error", "Modalidade Invalida", "Alerta - Ayllos", "$('#cdmodali_portabilidade', '" + formulario + "').val('').focus();hideMsgAguardo();");
                        return false;
                    }

                    montarDadosPortabilidade(operacao);
                });

            }
        }
    });

}


function montarDadosPortabilidade(operacao)
{

    arrayDadosPortabilidade['nrcnpjbase_if_origem'] = $('#nrcnpjbase_if_origem', '#frmPortabilidadeCredito').val();
    arrayDadosPortabilidade['nrcontrato_if_origem'] = $('#nrcontrato_if_origem', '#frmPortabilidadeCredito').val();
    arrayDadosPortabilidade['nmif_origem'] = $('#nmif_origem', '#frmPortabilidadeCredito').val();
    arrayDadosPortabilidade['cdmodali'] = $('#cdmodali_portabilidade', '#frmPortabilidadeCredito').val();
    arrayDadosPortabilidade['nrunico_portabilidade'] = $('#nrunico_portabilidade', '#frmPortabilidadeCredito').val();
    arrayDadosPortabilidade['dssit_portabilidade'] = $('#dssit_portabilidade', '#frmPortabilidadeCredito').val();

    hideMsgAguardo();

    possuiPortabilidade = 'S';

    $("#frmNovaProp #portabilidade").val(possuiPortabilidade);

    if (operacao == 'PORTAB_CRED_A') {
        controlaOperacao('A_NOVA_PROP');
    } else if (operacao == 'PORTAB_CRED_I') {
        controlaOperacao('I');
    }

}


function carregaFinalidadePortabilidade()
{

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/emprestimos/portabilidade/ajax_portabilidade.php",
        dataType: "json",
        async: false,
        data: {
            flgopcao: 'CF'
        },
        success: function(data) {
            if (data.erro == 'S') {
                showError('error', data.msg, 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            } else {
                if (data.rows > 0) {
                    $.each(data.records, function(i, item) {
                        $("#cdfinemp", "#frmNovaProp").val(item.cdfinemp);
                        $("#dsfinemp", "#frmNovaProp").val(item.dsfinemp);
                    });
                }
            }
            //desabilita campo finalidade
            $("#cdfinemp", "#frmNovaProp").desabilitaCampo();
        }
    });

}

function direcionaConsulta()
{
    possuiPortabilidade = $("#divEmpres table tr.corSelecao").find("input[id='portabil']").val();

    if (possuiPortabilidade == 'N') {
        controlaOperacao('TC');
    } else if (possuiPortabilidade == 'S') {
        controlaOperacao('PORTAB_CRED_C');
    }
}


/**
 * Funcao para soma de dias em uma data
 * @param String txtData - data inicial
 * @param Integer DiasAdd - quantos dias se quer adicionar
 * @returns String Data
 */
function SomarData(txtData, DiasAdd)
{
    // Tratamento das Variaveis.
    // var txtData = "01/01/2007"; //poder ser qualquer outra
    // var DiasAdd = 10 // Aqui vem quantos dias você quer adicionar a data
    var d = new Date();
    // Aqui eu "mudo" a configuração de datas.
    // Crio um obj Date e pego o campo txtData e 
    // "recorto" ela com o split("/") e depois dou um
    // reverse() para deixar ela em padrão americanos YYYY/MM/DD
    // e logo em seguida eu coloco as barras "/" com o join("/")
    // depois, em milisegundos, eu multiplico um dia (86400000 milisegundos)
    // pelo número de dias que quero somar a txtData.
    d.setTime(Date.parse(txtData.split("/").reverse().join("/")) + (86400000 * (DiasAdd)))

    // Crio a var da DataFinal			
    var DataFinal;

    var DataParam = txtData.split("/");
    DataFinal = DataParam[0] + '/';

    var mes = d.getMonth() + 1; //soma 1 pq getMonth retorno de 0 a 11

    // Aqui, já com a soma do mês, vejo se é menor do que 10
    // se for coloco o zero ou não.
    if ((mes) < 10) {
        DataFinal += "0" + (mes).toString() + "/" + d.getFullYear().toString();
    } else {
        DataFinal += (mes).toString() + "/" + d.getFullYear().toString();
    }

    return DataFinal;
}

function atualizaCampoData()
{
    if ($("#qtpreemp", "#frmNovaProp").val() > 0 && $("#dtdpagto", "#frmNovaProp").val() !== '') {

        //pega a data de pagamento
        var dataPag = $('#dtdpagto', '#frmNovaProp').val();
        //correcao da contagem de datas erradas, apos o dia 22; 
        var vr_dt = dataPag.split('/');
        if (vr_dt[0] > 22) {
            var ndias = 45;
        } else {
            var ndias = 30;
        }
        //quantidade de meses * 30 - 30 ou 45 pois a primeia parcela sera na data de liberacao
        var qtdDias = ($('#qtpreemp', '#frmNovaProp').val() * 30.5) - ndias;
        //retorno da consulta
        var retorno = SomarData(dataPag, qtdDias);
        //atualiza data ultimo pagamento
        $('#dtultpag', '#frmNovaProp').val(retorno);
    } else {
        //limpa data ultimo pagamento
        $('#dtultpag', '#frmNovaProp').val('');
    }
}

function habilitaModalidade(pr_finalidade)
{
    //recupera o valor gravado no hidden tpfinali pela rotina de pesquisa (busca_descricao) ou o valor do parametro
    var vfinalidade = (pr_finalidade == '') ? $.trim($("#tpfinali", "#frmSimulacao").val()) : pr_finalidade;

    if (vfinalidade == "2") {
        $("#cdmodali", "#frmSimulacao").habilitaCampo();
    } else {
        $('#frmSimulacao #cdmodali option[value="0"]').attr('selected', 'selected');
        $("#cdmodali", "#frmSimulacao").desabilitaCampo();
    }
}

function fechaTelaBens()
{
    $('#divProcBensFormulario').remove();
    fechaRotina($('#divUsoGenerico'), $('#divRotina'));
}

function gravaAvalista()
{
    showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 
                    'Confirma&ccedil;&atilde;o - Ayllos', 
                    'fechaTelaBens(); manterRotina(\'F_AVALISTA\');', 
                    'bloqueiaFundo( $(\'#divUsoGenerico\') );', 
                    'sim.gif', 
                    'nao.gif');
}

function formataAcionamento() {

    var divRegistro = $('div.divRegistros', '#divResultadoAciona');
    var tabela = $('table', divRegistro);
    var tabelaHeader = $('table > thead > tr > th', divRegistro);
    var fonteLinha = $('table > tbody > tr > td', divRegistro);

    tabelaHeader.css({'font-size': '11px'});
    fonteLinha.css({'font-size': '11px'});

    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});


    var ordemInicial = new Array();

    var arrayLargura = new Array();

    arrayLargura[0] = '80px';
	  arrayLargura[1] = '110px';
    arrayLargura[2] = '100px';
    arrayLargura[3] = '196px';
    arrayLargura[4] = '120px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'left';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'left';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
    return false;
}

function validaDadosAlterarSomenteValorProposta(){
	
	hideMsgAguardo();
	showMsgAguardo("Aguarde, validando os dados...");
	
	var fVlemprst = $('#vlemprst', '#frmNovaProp').val();
	
	$.ajax({
		type: "POST",
		url: UrlSite + 'telas/atenda/emprestimos/valida_dados_alterar_valor_proposta.php',
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl,
			nrctremp: nrctremp, vlemprst: fVlemprst,
			redirect: "script_ajax"
		},
		error: function(objAjax,responseError,objExcept){
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
			}
		}
	});	
    return false;
}

function abreProtocoloAcionamento(dsprotocolo) {

    showMsgAguardo('Aguarde, carregando...');

    // Executa script de através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/form_acionamentos.php',
        data: {
            dsprotocolo: dsprotocolo,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            hideMsgAguardo();
			if (response.substr(0,4) == "hide") {
				eval(response);
			} else {
                $('#nmarquiv', '#frmImprimir').val(response);
                var action = UrlSite + 'telas/atenda/emprestimos/form_acionamentos.php';
                carregaImpressaoAyllos("frmImprimir",action,"bloqueiaFundo(divRotina);");
			}
            return false;
        }
    });
}

function exibeLinhaCarencia() {
    if ($("#tpemprst", "#frmNovaProp").val() == 2) { // Se for Pos-Fixado
        $("#linCarencia","#frmNovaProp").show();
        calculaDataCarencia();
    } else {
        $("#linCarencia","#frmNovaProp").hide();
    }
}

function calculaDataCarencia() {

    hideMsgAguardo();
	showMsgAguardo("Aguarde, calculando os dados...");

    var idcarenc = normalizaNumero($("#idcarenc", "#frmNovaProp").val());
    var dtlibera = $("#dtlibera", "#frmNovaProp").val();
    var dtdpagto = $("#dtdpagto", "#frmNovaProp").val();
    var dtcarenc = dtdpagto.substr(0, 2) + '/' + dtlibera.substr(3, 2) + '/' + dtmvtolt.substr(6, 4);
	
	$.ajax({
		type: "POST",
		url: UrlSite + 'telas/atenda/emprestimos/busca_dados.php',
		data: {
			acao    : 'CALC_DATA_CARENCIA',
            idcarenc: idcarenc,
			dtcarenc: dtcarenc,
			redirect: "script_ajax"
		},
		error: function(objAjax,responseError,objExcept){
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
                bloqueiaFundo(divRotina);
				eval(response);
            return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
			}
        }
    });

    return false;
}

function maskTelefone(nrfonemp){
	fone = nrfonemp.value.replace(/[^0-9]/g,'');	
	
	fone = fone.replace(/\D/g,"");                 //Remove tudo o que não é dígito
	fone = fone.replace(/^(\d\d)(\d)/g,"($1) $2"); //Coloca parênteses em volta dos dois primeiros dígitos
	
	if (fone.length < 14)
		fone = fone.replace(/(\d{4})(\d)/,"$1-$2");    //Coloca hífen entre o quarto e o quinto dígito
	else
		fone = fone.replace(/(\d{5})(\d)/,"$1-$2");    //Coloca hífen entre o quinto e o sexto dígito
	
	nrfonemp.value = fone.substring(0, 15);
	
	return true;
}

function telefone(fone){
	fone = fone.replace(/\D/g,"");                 //Remove tudo o que não é dígito
	if (fone.length < 10 || fone.length > 11)
		return '';
	fone = fone.replace(/^(\d\d)(\d)/g,"($1) $2"); //Coloca parênteses em volta dos dois primeiros dígitos
	fone = fone.replace(/(\d{4})(\d)/,"$1-$2");    //Coloca hífen entre o quarto e o quinto dígitos
	return fone;
}
