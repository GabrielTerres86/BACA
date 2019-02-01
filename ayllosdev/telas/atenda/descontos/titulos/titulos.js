 /*!
 * FONTE        : titulos.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : Março/2009
 * OBJETIVO     : Biblioteca de funções da subrotina de Descontos de Títulos
 * --------------
 * ALTERAÇÕES   : 26/04/2018
 * --------------
 * 000: [08/06/2010] David     (CECRED) : Adaptação para RATING
 * 000: [22/09/2010] David	   (CECRED) : Ajuste para enviar impressoes via email para o PAC Sede
 * 001: [04/05/2010] Rodolpho     (DB1) : Adaptação para o Zoom Endereço e Avalistas genérico
 * 002: [12/09/2011] Adriano   (CECRED) : Ajuste para Lista Negra
 * 003: [10/07/2012] Jorge	   (CECRED) : Alterado esquema para impressao em gerarImpressao().
 * 004: [11/07/2012] Lucas     (CECRED) : Lupas para listagem de Linhas de Desconto de Título disponíveis.
 * 005: [05/11/2012] Adriano   (CECRED) : Ajustes referente ao projeto GE.
 * 005: [01/04/2013] Lucas R.  (CECRED) : Ajustes na function controlaLupas.
 * 006: [21/05/2015] Reinert   (CECRED) : Alterado para apresentar mensagem ao realizar inclusao
 *								          de proposta de novo limite de desconto de titulo para
 *									      menores nao emancipados.
 * 007: [20/08/2015] Kelvin    (CECRED) : Ajuste feito para não inserir caracters 
 *  								      especiais na observação, conforme solicitado
 *										  no chamado 315453.
 *
 * 008: [17/12/2015] Lunelli   (CECRED) : Edição de número do contrato de limite (Lunelli - SD 360072 [M175])
 * 009: [27/06/2016] Jaison/James (CECRED) : Inicializacao da aux_inconfi6.
 * 010: [18/11/2016] Jaison/James (CECRED) : Reinicializa glb_codigoOperadorLiberacao somente quando pede a senha do coordenador.
 * 011: [22/11/2016] Jaison/James (CECRED) : Zerar glb_codigoOperadorLiberacao antes da cdopcolb.
 * 012: [09/03/2017] Adriano    (CECRED): Ajuste devido ao tratamento para validar titulos já inclusos em outro borderô - SD 603451.
 * 013: [26/06/2017] Jonata (RKAM): Ajuste para rotina ser chamada através da tela ATENDA > Produtos ( P364).
 * 014: [11/12/2017] P404 - Inclusão de Garantia de Cobertura das Operações de Crédito (Augusto / Marcos (Supero)) 
 * 015: [22/03/2018] Daniel (Cecred) Alteracoes para geracao no numero do contrato automaticamente.
 * 015: [13/03/2018] Leonardo Oliveira (GFT): Novos métodos 'acessaValorLimite', 'formataValorLimite', 'renovaValorLimite' e 'converteNumero'.
 * 016: [16/03/2018] Leonardo Oliveira (GFT): Alteração dos métodos 'acessaValorLimite', 'formataValorLimite' e 'renovaValorLimite' para mostrar dialogo de confirmação e condirerar alteração de linha
 * 017: [22/03/2018] Daniel (Cecred) Alteracoes para geracao no numero do contrato automaticamente. 
 * 018: [22/03/2018] Leonardo Oliveira (GFT): Ajustes no fluxo de renovação do limite de desconto de titulos, validação das linhas de credito bloqueadas
 * 019: [28/03/2018] Andre Avila (GFT): Criação do método carregaLimitesTitulosPropostas e carregaDadosAlteraLimiteDscTitPropostas. 
 * 020: [02/04/2018] Leonardo Oliveira (GFT): Criação dos metodos para mostrar detalhes do titulo do borderô 'selecionarTituloDeBordero' 'visualizarTituloDeBordero' 
 * 021: [06/04/2018] Luis Fernando (GFT): Mudanças de layot na inclusão de borderos
 * 022: [12/04/2018] Leonardo Oliveira (GFT): Criação dos métodos 'realizarManutencaoDeLimite', 'concluirManutencaoDeLimite' e 'formataManutencaoDeLimite' para a tela de manutenção de limite.
 * 023: [15/04/2018] Leonardo Oliveira (GFT): Criação dos métodos 'formatarTelaAcionamentosDaProposta', 'carregarAcionamentosDaProposta' e 'carregaDadosDetalhesProposta' para a tela de acionamentos/detalhes da proposta, correção dos códicos sobreescritos.
 * 024: [19/04/2018] Leonardo Oliveira (GFT): Criação do método 'selecionaLimiteTitulosProposta', novo parâmetro 'nrctrmnt'/ numero da proposta, ao selecionar uma proposta.
 * 025: [26/04/2018] Leonardo Oliveira (GFT): Ajuste nos valores retornados ao buscar propostas.
 * 026: [26/04/2018] Vitor Shimada Assanuma (GFT): Ajuste na funcao de chamada da proposta e manutencao
 * 027: [14/05/2018] Vitor Shimada Assanuma (GFT): Criacao da funcao mostrarBorderoPagar(), pagarTitulosVencidos() e efetuarPagamentoTitulosVencidos()
 * 028: [30/05/2018] Vitor Shimada Assanuma (GFT): Inclusão do css para alinhar a direita na Manutenção e 
 * 029: [02/06/2018] Vitor Shimada Assanuma (GFT): Criacao da funcao calculaValoresResumoBordero() para calculo do resumo dos valores do bordero
 * 030: [09/08/2018] Vitor Shimada Assanuma (GFT): Validação do parâmetro da #TAB052 de quantidade máxima de títulos ao incluir um título ao borderô
 * 027: [15/08/2018] Criada tela 'Motivos' e botão 'Anular'. PRJ 438 (Mateus Z - Mouts)
 
 * 033: [05/09/2018] Luis Fernando (GFT): Ajustada rotina de selecao de bordero para incluir prejuizo 
 */

 // variaveis propostas
var nrctrlim = $("#nrctrlim").val() != '' ? normalizaNumero($("#nrctrlim").val()) : 0; // limite
var vllimite = 0; // valor do limite
var nrctrmnt = 0; // contrato
var dssitlim = ''; // desc situação da proposta
var dssitest = ''; // desc situação da analise
var dssitapr = ''; // desc decisão
var insitlim = 0; // cod situação da proposta
var insitest = 0; // cod situação da analise
var insitapr = 0; // cod decisão
var inctrmnt = 0; // indica se é contrato de manutenção
var fl_sitbordero = ''; // indica a situacao do bordero selecionado

var contWin    = 0;  // Variável para contagem do número de janelas abertas para impressos
var nrcontrato = ""; // Variável para armazenar número do contrato de descto selecionado
var nrbordero = ""; // Variável para armazenar número do bordero de descto selecionado
var cd_situacao_lim = 0; // Variável para armazenar o código da situação do limite atualmente selecionado
var situacao_limite = ""; // Variável para armazenar a situação do limite atualmente selecionado
var idLinhaB   = 0;  // Variável para armazanar o id da linha que contém o bordero selecionado
var idLinhaL   = 0;  // Variável para armazanar o id da linha que contém o limite selecionado
var dtrating   = 0;  // Data rating (é calculada e alimentada no titulos_limite_incluir.php)
var diaratin   = 0;  // Dia do rating da tabela tt-risco (é alimentada no titulos_limite_incluir.php)
var vlrrisco   = 0;  // Valor do risco (é alimentada no titulos_limite_incluir.php)

var botaoLiberar = '';  // Botão Liberar borderô habilitado se analise confirmada. - GFT (André Ávila).
var sitinctrmnt  = "";  // Variável de parametro para identificar se a proposta é de manutenção. 0 = Não, 1 = Sim. - GFT (André Ávila).


// ALTERAÇÃO 001: Criação de variáveis globais 
var nomeForm    	= 'frmDadosLimiteDscTit'; 	// Variável para guardar o nome do formulário corrente
var boAvalista  	= 'b1wgen0028.p'; 			// BO para esta rotina
var procAvalista 	= 'carrega_avalista'; 		// Nome da procedures que busca os avalistas
var operacao		= '' 						// Operação corrente

var strHTML 		= ''; // Variável usada na criação da div de alerta do grupo economico.
var strHTML2 		= ''; // Variável usada na criação do form onde serão mostradas as mensagens de alerta do grupo economico.	
var dsmetodo   		= ''; // Variável usada para manipular o método a ser executado na função encerraMsgsGrupoEconomico.


var aux_inconfir = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi2 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi3 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi4 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi5 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi6 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/

var tpctrlim = "";
var idcobope = "";
var cdageori = "";


//novos
var situacao_analise = ""; // Variável para armazenar a situação da análise atualmente selecionado
var decisao = ""; // Variável para armazenar a decisão atualmente selecionado
var valor_limite = 0; // Variável para armazenar  o valor do limite atualmente selecionado


// ALTERAÇÃO 001: Carrega biblioteca javascript referente aos AVALISTAS
$.getScript(UrlSite + 'includes/avalistas/avalistas.js');


//Para inclusao de borderos
var tituloSelecionadoResumo = null;
// BORDERÔS DE DESCONTO DE TÍTULOS
// Mostrar o <div> com os borderos de desconto de títulos
function carregaBorderosTitulos() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando border&ocirc;s de desconto de t&iacute;tulos ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			executandoProdutos: executandoProdutos,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao2").html(response);
		}				
	});		
    return false;
}

// Função para seleção do bordero
function selecionaBorderoTitulos(id, qtBorderos, bordero, contrato, situacao) {
	var cor = "";

	// Formata cor da linha da tabela que lista os borderos de descto titulos
	for (var i = 1; i <= qtBorderos; i++) {		
		if (cor == "#F4F3F0") {
			cor = "#FFFFFF";
		} else {
			cor = "#F4F3F0";
		}		
		
		// Formata cor da linha
		$("#trBordero" + i).css("background-color",cor);

		if (i == id) {
			// Atribui cor de destaque para bordero selecionado
			$("#trBordero" + id).css("background-color","#FFB9AB");

			// Armazena número do bordero selecionado
			nrbordero  = retiraCaracteres(bordero,"0123456789",true);
			nrcontrato = retiraCaracteres(contrato,"0123456789",true);
            fl_sitbordero = situacao;
			idLinhaB  = id;		
		}
	}
    return false;
}

/*Mostra lupa de pagadores*/
function mostraPesquisaPagador(nrdconta,nomeForm){
    procedure = 'COBR_PESQUISA_PAGADORES';
    titulo = 'Pagador';
    qtReg = '30';
    filtros = ';nrinssac;;N;;N;;|Nome do Pagador;nmdsacad;280;S;;S;;|Conta;nrdconta;;N;' + normalizaNumero(nrdconta) + ';N;;';
    colunas = 'CPF/CNPJ;nrinssac;30%;center|Nome;nmdsacad;80%;left;|;nrdconta;;;;N';
    mostraPesquisa('COBRAN', procedure, titulo, qtReg, filtros, colunas, nomeForm, '$("#dtvencto","#'+nomeForm+'").focus();bloqueiaFundo(divRotina);');
    // $('#formPesquisa').css('display', 'none');
    return false;
}

/*Busca pagador da conta*/
function buscaPagador(nrdconta,nrinssac,nomeForm) {
    showMsgAguardo('Aguarde, buscando dados da Conta...');  
    
    nrdconta = normalizaNumero(nrdconta);
    nrinssac = normalizaNumero(nrinssac);
            
    $.ajax({        
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/atenda/descontos/manter_rotina.php', 
        data    : { 
                    operacao: 'BUSCAR_PAGADOR',
                    nrdconta: nrdconta,   
                    nrinssac: nrinssac,   
                    frmOpcao: nomeForm,
                    redirect: 'script_ajax'

                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','$(\'#nrinssac\',\''+nomeForm+'\').focus();');
                },
        success : function(response) { 
                    hideMsgAguardo();
                    bloqueiaFundo(divRotina);
                    eval(response);
                }
    }); 
}

function controlaOpcao(){
    $("#dtvencto").focus();
}

// OPÇÕES CONSULTA/EXCLUSÃO/IMPRIMIR/LIBERAÇÃO/ANÁLISE
// Mostrar dados do bordero para fazer
function mostraDadosBorderoDscTit(opcaomostra) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_carregadados.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			cddopcao: opcaomostra,
			nrborder: nrbordero,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
		}				
	});		
    return false;
}

// Mostrar tela de inclusao de borderos
function mostrarBorderoIncluir() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_incluir.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao3").html(response);
        }
    });
    return false;
}
// Mostrar dados para alterar um bordero
function mostrarBorderoAlterar() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_alterar.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrborder: nrbordero,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao3").html(response);
        }
    });
    return false;
}

// Mostrar tela de Pagar titulos do bordero
function mostrarBorderoPagar() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_pagar.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrborder: nrbordero,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao3").html(response);
        }
    });
    return false;
}

// FUNCAO PARA INCLUIR O TITULO NO BORDERO (MANDA DA TABELA DE FILTRO PARA A DE SELECIONADOS)
function incluiTituloBordero(td){
    var selecionados = $(".divRegistrosTitulosSelecionados table","#divIncluirBordero");
    var registros = $(".divRegistrosTitulos table","#divIncluirBordero");
    var td = $(td);
    var tr = td.parent();
    var id = tr.attr("id");

    //Verifica se ultrapassou o limite de numero de títulos no bordero
    if (typeof qtmaxtit !== 'undefined' && qtmaxtit > 0 && selecionados.find('tr').length > qtmaxtit){
        showError("error", "Quantidade de t&iacute;tulos excedida por border&ocirc;("+qtmaxtit+").", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    //Verifica se já está inserido na tabela de selecionados
    if (selecionados.find("#"+id).length>0){
        showError("error", "T&iacute;tulo j&aacute; incluso na lista de selecionados.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }
    else{
        td.removeClass('corSelecao');
        td.attr("onclick","");
        td.unbind('click').bind('click',function(){
            removeTituloBordero(td);
        });
        td.find("button").text("Remover");
        tr.unbind("click");

        selecionados.append(tr).zebraTabela();
        selecionados.trigger("update");
        registros.trigger("update");
        selecionados.find('> tbody > tr').each(function (i) {
            $(this).unbind('click').bind('click', function () {
                selecionados.zebraTabela(i);
            });
        });
        registros.find('> tbody > tr').each(function (i) {
            $(this).unbind('click').bind('click', function () {
                registros.zebraTabela(i);
            });
        });

        if (typeof arrayLarguraInclusaoBordero != 'undefined') {
            for (var i in arrayLarguraInclusaoBordero) {
                $('td:eq(' + i + ')', selecionados).css('width', arrayLarguraInclusaoBordero[i]);
                $('td:eq(' + i + ')', registros).css('width', arrayLarguraInclusaoBordero[i]);
            }       
        }
        /*Soma titulo incluso no valor total de titulos selecionados*/
        var vlseleci = $("#vlseleci","#divIncluirBordero"); //valor titulos selecionados
        var valor = converteMoedaFloat(tr.find("input[name='vltituloselecionado']").val());
        if(valor>0){
            var total = 0;
            total = converteMoedaFloat(vlseleci.val());
            total += valor;
            vlseleci.val(number_format(total,2,',','.'));
            calculaSaldoBordero();
        }   
        $('#divPesquisaRodape', '#divIncluirBordero').formataRodapePesquisa();
    }
}

function calculaSaldoBordero(){
    var vlutiliz = $("#vlutiliz","#divIncluirBordero"); //valor descontado
    var vldispon = $("#vldispon","#divIncluirBordero"); //valor disponivel
    var vlseleci = $("#vlseleci","#divIncluirBordero"); //valor titulos selecionados
    var vlsaldor = $("#vlsaldor","#divIncluirBordero"); //saldo restante
    var qtseleci = $("#qtseleci","#divIncluirBordero"); //saldo restante
    var total = 0;
    total = converteMoedaFloat(vldispon.val())-converteMoedaFloat(vlseleci.val());
    vlsaldor.val(number_format(total,2,',','.'));

    var selecionados = $(".divRegistrosTitulosSelecionados table","#divIncluirBordero");
    qtseleci.val(selecionados.find("input[name='selecionados']").length);
}
//Busca os titulos do bordero
function buscarTitulosBordero(nriniseq, nrregist) {
    showMsgAguardo('Aguarde, buscando dados da Conta...');  
    var nomeForm = "formPesquisaTitulos";
    var nrdconta = normalizaNumero($("#nrdconta","#"+nomeForm).val());
    var nrctrlim = normalizaNumero($("#nrctrlim","#"+nomeForm).val());
    var nrinssac = normalizaNumero($("#nrinssac","#"+nomeForm).val());
    var dtvencto = $("#dtvencto","#"+nomeForm).val();
    var vltitulo = $("#vltitulo","#"+nomeForm).val();
    var nrnosnum = normalizaNumero($("#nrnosnum","#"+nomeForm).val());
    var nrborder = normalizaNumero($("#nrborder","#"+nomeForm).val());

    $.ajax({        
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/atenda/descontos/manter_rotina.php', 
        data    : { 
                    operacao: 'BUSCAR_TITULOS_BORDERO',
                    nrdconta: nrdconta,
                    nrctrlim: nrctrlim,
                    nrinssac: nrinssac,
                    dtvencto: dtvencto,
                    vltitulo: vltitulo,
                    nrnosnum: nrnosnum,
                    nrborder: nrborder,
                    frmOpcao: nomeForm,
                    nriniseq: nriniseq,
                    nrregist: nrregist,
                    redirect: 'script_ajax'

                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','$(\'#nrinssac\',\''+nomeForm+'\').focus();');
                },
        success : function(response) { 
                    hideMsgAguardo();
                    var registros = $(".divRegistrosTitulos","#divIncluirBordero");
                    registros.parent().find("table").remove();                   //remove o cabecalho para poder regerar o formatatabela
                    registros.html(response);
                    var table = registros.find(">table");
                    var ordemInicial = new Array();
                    table.formataTabela( ordemInicial, arrayLarguraInclusaoBordero, arrayAlinhaInclusaoBordero, '' );
                    $('#divPesquisaRodape', '#divIncluirBordero').formataRodapePesquisa();
                    bloqueiaFundo(divRotina);
                }
    }); 
}
function buscarTitulosBorderoPaginacao(nriniseq, nrregist){
    buscarTitulosBordero(nriniseq, nrregist);

}
//Busca os titulos disponiveis para resgate
function buscarTitulosResgatar() {
    showMsgAguardo('Aguarde, buscando dados da Conta...');  
    var nomeForm = "formPesquisaTitulos";
    var nrdconta = normalizaNumero($("#nrdconta","#"+nomeForm).val());
    var nrctrlim = normalizaNumero($("#nrctrlim","#"+nomeForm).val());
    var nrinssac = normalizaNumero($("#nrinssac","#"+nomeForm).val());
    var dtvencto = $("#dtvencto","#"+nomeForm).val();
    var vltitulo = $("#vltitulo","#"+nomeForm).val();
    var nrnosnum = normalizaNumero($("#nrnosnum","#"+nomeForm).val());
    var nrborder = normalizaNumero($("#nrborder","#"+nomeForm).val());
    if(!nrnosnum && !dtvencto && !nrinssac){
        showError('error','Preencha a data de vencimento, pagador ou nosso n&uacute;mero.','Alerta - Aimaro','$(\'#nrinssac\',\''+nomeForm+'\').focus();hideMsgAguardo();bloqueiaFundo(divRotina);');        
    }
    else{
        $.ajax({        
            type    : 'POST',
            dataType: 'html',
            url     : UrlSite + 'telas/atenda/descontos/manter_rotina.php', 
            data    : { 
                        operacao: 'BUSCAR_TITULOS_RESGATE',
                        nrdconta: nrdconta,
                        nrctrlim: nrctrlim,
                        nrinssac: nrinssac,
                        dtvencto: dtvencto,
                        vltitulo: vltitulo,
                        nrnosnum: nrnosnum,
                        nrborder: nrborder,
                        frmOpcao: nomeForm,
                        redirect: 'script_ajax'
                    },
            error   : function(objAjax,responseError,objExcept) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','$(\'#nrinssac\',\''+nomeForm+'\').focus();');
                    },
            success : function(response) { 
                        hideMsgAguardo();
                        var registros = $(".divRegistrosTitulos","#divIncluirBordero");
                        registros.parent().find("table").remove();                   //remove o cabecalho para poder regerar o formatatabela
                        registros.html(response);
                        var table = registros.find(">table");
                        var ordemInicial = new Array();
                        table.formataTabela( ordemInicial, arrayLarguraInclusaoBordero, arrayAlinhaInclusaoBordero, '' );
                        bloqueiaFundo(divRotina);
                    }
        }); 
    }
}

// FUNCAO QUE REMOVE OS TITULOS DO BORDERO
function removeTituloBordero(td){
    var selecionados = $(".divRegistrosTitulosSelecionados table","#divIncluirBordero");
    var tr = td.parent();
    /*Soma titulo incluso no valor total de titulos selecionados*/
    var vlseleci = $("#vlseleci","#divIncluirBordero"); //valor titulos selecionados
    var valor = converteMoedaFloat(tr.find("input[name='vltituloselecionado']").val());
    if(valor>0){
        var total = 0;
        total = converteMoedaFloat(vlseleci.val());
        total -= valor;
        vlseleci.val(number_format(total,2,',','.'));
    }
    tr.remove();
    calculaSaldoBordero();
    selecionados.zebraTabela();
    selecionados.trigger("update");
    if (typeof arrayLarguraInclusaoBordero != 'undefined') {
        for (var i in arrayLarguraInclusaoBordero) {
            $('td:eq(' + i + ')', selecionados).css('width', arrayLarguraInclusaoBordero[i]);
        }       
    }   
    selecionados.find('> tbody > tr').each(function (i) {
        $(this).unbind('click').bind('click', function () {
            selecionados.zebraTabela(i);
        });
    });
}
// OPÇÃO CONSULTAR
// Mostrar títulos do bordero
function carregaTitulosBorderoDscTit() { 
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando t&iacute;tulos do border&ocirc; ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_consultar_visualizatitulos.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao4").html(response);
		}				
	});		
    return false;
} 

// OPÇÃO EXCLUIR
// Função para excluir um bordero de desconto de títulos
function excluirBorderoDscTit() {	
	// Se não tiver nenhum bordero selecionado
	if (nrbordero == "") {
		return false;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, excluindo border&ocirc; ...");
	
	// Executa script de exclusão através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_excluir.php", 
		data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
    return false;
}

// OPÇÃO IMPRIMIR
// Função para mostrar a opção Imprimir dos borderos de desconto de títulos
function mostraImprimirBordero(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Imprimir ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_imprimir.php",
		dataType: "html",
		data: {
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
		}				
	});
    return false;
}




// LIMITES DE DESCONTO DE TITULOS
function carregaLimitesTitulosPropostas() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando Propostas de limites de desconto de t&iacute;tulos ...");
    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_propostas.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });

    return false;
}


// LIMITES DE DESCONTO DE TITULOS
function carregaResgatarTitulos() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando Propostas de limites de desconto de t&iacute;tulos ...");
    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_resgatar.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrlim: normalizaNumero($("#frmTitulos #nrctrlim").val()),
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao2").html(response);
        }
    });

    return false;
}

// Carregar os dados para consulta de propostas de limite de desconto de títulos
function carregaDadosAlteraLimiteDscTitPropostas() {
    if (sitinctrmnt == 1){
        realizarManutencaoDeLimite(1,1);
        return false;

    } else {
        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, carregando dados da Proposta de limites de desconto de t&iacute;tulos ...");

        // Carrega conteúdo da opção através de ajax
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_alterar_propostas.php",
            dataType: "html",
            data: {
                nrdconta: nrdconta,
                nrctrlim: nrctrlim,
                redirect: "html_ajax"
            },
            error: function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function(response) {
                $("#divOpcoesDaOpcao3").html(response);
                controlaLupas(nrdconta);
            }
        });
    }

}


// Função para verificar se deve ser enviado e-mail ao PAC Sede
function verificaEnvioEmail(idimpres,limorbor) {
    showConfirmacao("Efetuar envio de e-mail para Sede?","Confirma&ccedil;&atilde;o - Aimaro","verificaImpressaoProposta(" + idimpres + "," + limorbor + ",'yes');","verificaImpressaoProposta(" + idimpres + "," + limorbor + ",'no');","sim.gif","nao.gif");
}

// Função para gerar impressão em PDF
function gerarImpressao(idimpres,limorbor,flgemail,fnfinish) {
	
	if (idimpres == 8) {
        imprimirRating(false,3,nrctrlim,"divOpcoesDaOpcao3",fnfinish);
        return false;       
	}
	
	$("#nrdconta","#frmImprimirDscTit").val(nrdconta);
	$("#idimpres","#frmImprimirDscTit").val(idimpres);
	$("#flgemail","#frmImprimirDscTit").val(flgemail);
    $("#nrctrlim","#frmImprimirDscTit").val(nrctrlim);
	$("#nrborder","#frmImprimirDscTit").val(nrbordero);		
	$("#limorbor","#frmImprimirDscTit").val(limorbor);
	
	var action = $("#frmImprimirDscTit").attr("action");
	var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";
	
	carregaImpressaoAyllos("frmImprimirDscTit",action,callafter);
    return false;
}

function verificaImpressaoProposta(idimpres,limorbor,flgemail,fnfinish) {
	
	if (idimpres == 3) {
   
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, verificando impressao ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/verifica_impressao.php",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
			idimpres: idimpres,
			limorbor: limorbor,
			flgemail: flgemail,
			fnfinish: fnfinish,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
				eval(response);
                //gerarImpressao(idimpres,limorbor,flgemail,fnfinish);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
    return false;
	} else {
		
		gerarImpressao(idimpres,limorbor,flgemail,fnfinish);
		
	}
}

// OPÇÃO ANALISAR
// Analisar bordero de desconto de títulos
function analisarBorderoDscTit() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, analisando o border&ocirc; ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        //url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_liberaranalisar.php",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_analisar.php",
        data: {
            nrdconta: nrdconta,
            nrborder: nrbordero,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                eval(response);
                //botaoLiberar = 'S';

            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
    return false;
}

// OPÇÃO LIBERAR
// Liberar/Analisar bordero de desconto de títulos
function liberaAnalisaBorderoDscTit(opcao,idconfir,idconfi2,idconfi3,idconfi4,idconfi5,idconfi6,indentra,indrestr) {

	var nrcpfcgc = normalizaNumero($("#nrcpfcgc","#frmCabAtenda").val());
    var mensagem = '';
    var cdopcoan = 0;
    var cdopcolb = 0;
    var url = "telas/atenda/descontos/titulos/titulos_bordero_analisar.php";
    if(!flgverbor){
        url = "telas/atenda/descontos/titulos/titulos_bordero_liberaranalisar.php";
    }
			
    // Reinicializa somente quando pede a senha
    if (idconfi6 == 51) {
        glb_codigoOperadorLiberacao = 0;
    }
			
	// Mostra mensagem de aguardo
	if (opcao == "N") {
		mensagem = "analisando";
        cdopcoan = glb_codigoOperadorLiberacao;
	} else {
		mensagem = "liberando";
        cdopcolb = glb_codigoOperadorLiberacao;
	}

	showMsgAguardo("Aguarde, "+mensagem+" o border&ocirc; ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
        url: UrlSite + url,
		data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
			cddopcao: opcao,
			inconfir: idconfir,
			inconfi2: idconfi2,
			inconfi3: idconfi3,
			inconfi4: idconfi4,
			inconfi5: idconfi5,
			inconfi6: idconfi6,
			indentra: indentra,
			indrestr: indrestr,
			nrcpfcgc: nrcpfcgc,
            cdopcoan: cdopcoan,
            cdopcolb: cdopcolb,
			redirect: "script_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}			
	});
    return false;
}

// LIMITES DE DESCONTO DE TITULOS
// Mostrar o <div> com os limites de desconto de títulos
function carregaLimitesTitulos() {
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando Contratos de limites de desconto de t&iacute;tulos ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao2").html(response);
		}				
	});		
    return false;
}

// Função para seleção do limite

function selecionaLimiteTitulos(id, qtLimites, limite, dssitlim, dssitest, insitapr, vlLimite) {

    situacao_analise = dssitest;
    decisao = insitapr;
    valor_limite = vlLimite;

    nrcontrato = null;
    idLinhaL = null;
    situacao_limite = null;

	var cor = "";
	
	// Formata cor da linha da tabela que lista os limites de descto titulos
	for (var i = 1; i <= qtLimites; i++) {		
		if (cor == "#F4F3F0") {
			cor = "#FFFFFF";
		} else {
			cor = "#F4F3F0";
		}		
		
		// Formata cor da linha
		$("#trLimite" + i).css("background-color",cor);
		
		if (i == id) {
			// Atribui cor de destaque para limite selecionado
			$("#trLimite" + id).css("background-color","#FFB9AB");
			// Armazena número do limite selecionado
			nrcontrato = limite;
            nrctrlim = limite;
			idLinhaL = id;
            cd_situacao_lim = insitlim;
			situacao_limite = dssitlim;

        }
    }
    return false;
}

function selecionaLimiteTitulosProposta(pr_id, pr_qtlimites, pr_nrctrlim, pr_vllimite, pr_nrctrmnt, pr_dssitlim, pr_dssitest, pr_dssitapr, pr_insitlim, pr_insitest, pr_insitapr, pr_inctrmnt) {
        
    idLinhaL = pr_id; // id linha
    qtLimites = pr_qtlimites; // qtd de propostas
    nrctrlim = pr_nrctrlim; // limite
    vllimite = pr_vllimite; // valor do limite
    nrctrmnt = pr_nrctrmnt; // contrato
    dssitlim = pr_dssitlim; // desc situação da proposta
    dssitest = pr_dssitest; // desc situação da analise
    dssitapr = pr_dssitapr; // desc decisão
    insitlim = pr_insitlim; // cod situação da proposta
    insitest = pr_insitest; // cod situação da analise
    insitapr = pr_insitapr; // cod decisão
    inctrmnt = pr_inctrmnt; // indica se é contrato de manutenção
    sitinctrmnt = pr_inctrmnt;

    var cor = "";
    
    // Formata cor da linha da tabela que lista os limites de descto titulos
    for (var i = 1; i <= qtLimites; i++) {      
        if (cor == "#F4F3F0") {
            cor = "#FFFFFF";
        } else {
            cor = "#F4F3F0";
        }       
        
        // Formata cor da linha
        $("#trLimite" + i).css("background-color",cor);
        
        if (i == pr_id) {
            // Atribui cor de destaque para limite selecionado
            $("#trLimite" + idLinhaL).css("background-color","#FFB9AB");
        }
    }
	
    return false;
}

// Função para mostrar a opção Imprimir dos limites de desconto de títulos
function mostraImprimirLimite(tipo) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Imprimir ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_imprimir.php",
		dataType: "html",
		data: {
            tipo: tipo,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
		}				
	});
    return false;
}

// Função para cancelar um limite de desconto de títulos
function cancelaLimiteDscTit() {	
	// Se não tiver nenhum limite selecionado
	if (nrcontrato == "") {
		return false;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, cancelando limite ...");
	
	// Executa script de cancelamento através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_cancelar.php", 
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrcontrato,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
    return false;
}

// Função para excluir um limite de desconto de títulos
function excluirLimiteDscTit() {	
	// Se não tiver nenhum limite selecionado
	if (nrcontrato == "") {
		return false;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, excluindo limite ...");
	
	// Executa script de exclusão através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_excluir.php", 
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrcontrato,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
    return false;
}

// OPÇÃO CONSULTAR
// Carregar os dados para consulta de limite de desconto de títulos
function carregaDadosConsultaLimiteDscTit() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados de desconto de t&iacute;tulos ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_consultar.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrcontrato,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
		}				
	});		
    return false;
}


function carregaDadosConsultaPropostaDscTit() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados de desconto de t&iacute;tulos ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_consultar_proposta.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $("#divOpcoesDaOpcao3").html(response);
        }               
    });
    return false;
}


// OPÇÃO INCLUIR
// Carregar os dados para inclusãoo de limite de títulos
function carregaDadosInclusaoLimiteDscTit(inconfir, tipo) {
	showMsgAguardo("Aguarde, carregando dados de desconto de t&iacute;tulos ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_incluir.php",
		dataType: "html",
		data: {
            tipo: tipo,
			nrdconta: nrdconta,
			inconfir: inconfir,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
			$("#divConteudoOpcao").css('display','none');
			controlaLupas(nrdconta);
		}				
	});		
    return false;
}

// OPÇÃO ALTERAR
function mostraTelaAltera() {

    showMsgAguardo('Aguarde, abrindo altera&ccedil;&atilde;o...');

    exibeRotina($('#divUsoGenerico'));

    if (situacao_limite != "EM ESTUDO") {
        showError("error", "N&atilde;o &eacute; poss&iacute;vel alterar contrato. Situa&ccedil;&atilde;o do limite ATIVO.", "Alerta - Aimaro", "fechaRotinaAltera();");
        return false;
    }
	

    limpaDivGenerica();

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/titulos/titulos_limite_alterar_form.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });

    $('#todaProp', '#frmAltera').focus();
    return false;
}

function confirmaEnvioAnalise(){
    showConfirmacao(
        "Confirma envio da Proposta para An&aacute;lise de Cr&eacute;dito?",
        "Confirma&ccedil;&atilde;o - Aimaro",
        "validaAnaliseTitulo();",
        "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))",
        "sim.gif",
        "nao.gif");
    return false;
}

//OPÇÂO ANALISAR
//Avaliar se é possível executar a ação de analisar
function validaAnaliseTitulo(){
    if (
        insitest == 3 &&        // insitest (cod situação da analise) ==  3 (ANALISE FINALIZADA)
        insitapr == 5 ){        // insitapr (cod decisão) == 5 (REJEITADO AUTOMATICAMENTE)
        showConfirmacao(
            "Confirma envio da Proposta para An&aacute;lise de Cr&eacute;dito? <br> Observa&ccedil;&atildeo: Ser&aacute; necess&aacute;ria aprova&ccedil;&atilde;o de seu Coordenador pois a mesma foi reprovada automaticamente!",
            "Confirma&ccedil;&atilde;o - Aimaro",
            "pedeSenhaCoordenador(2,\'enviarPropostaAnaliseComLIberacaoCordenador();\',\'divRotina\');",
            "controlaOperacao(\'\');",
            "sim.gif",
            "nao.gif");
    }else{
        enviarPropostaAnalise();
    }
    return false;
}

// funcao que é chamada caso seja aprovado com senha coordenador
function enviarPropostaAnaliseComLIberacaoCordenador(){
    showMsgAguardo("Aguarde, enviando dados para esteira ...");

    var operacao = "ENVIAR_ESTEIRA";

    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/manter_rotina.php",
        dataType: "html",
        data: {
            operacao: operacao,
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
            redirect: "html_ajax"
        },
        success: function(response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
            }
        },  
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
        }
                        
    }); 
    return false;
}


// OPÇÃO ANALISAR
// Carregar os dados para consulta de limite de desconto de títulos
function enviarPropostaAnalise() {
    //alert("Proposta enviada para analise.\nObs.: Função ainda em desenvolvimento!");
    
    showMsgAguardo("Aguarde, enviando proposta para an&aacute;lise ...");

    var operacao = "ENVIAR_ANALISE";
    
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/manter_rotina.php",
        dataType: "html",
        data: {
            operacao: operacao,
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
            }
            
        }               
    }); 
}

function efetuarNovoLimite(){
        showConfirmacao(
                        "Deseja confirmar a efetiva&ccedil;&atilde;o do limite?",
                        "Confirma&ccedil;&atilde;o - Aimaro",
                        "confirmaNovoLimite(0);",
                        "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))",
                        "sim.gif",
                        "nao.gif");
        return false;
}

function confirmaNovoLimite(cddopera) {
    showMsgAguardo("Aguarde, efetivando limite ...");
    var operacao = "CONFIMAR_NOVO_LIMITE";

    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/manter_rotina.php",
        dataType: "html",
        data: {
            operacao: operacao,
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
            vllimite: vllimite,
            cddopera: cddopera,
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                eval(response);
              } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
              }
        }           
    });
    return false;
}

function verificaMensagens(mensagem_01,mensagem_02,mensagem_03,mensagem_04,mensagem_05,qtctarel,grupo,vlutiliz,vlexcedi) {
    
    if (mensagem_01 != ''){

        showConfirmacao(mensagem_01
                       ,"Confirma&ccedil;&atilde;o - Aimaro"
                       ,"verificaMensagens('','" + mensagem_02 + "','" + mensagem_03 + "','" + mensagem_04 + "','"+ mensagem_05 + "','" + qtctarel + "','" + grupo + "','" + vlutiliz + "','" + vlexcedi + "');"
                       ,"telaOperacaoNaoEfetuada();"
                       ,"sim.gif","nao.gif");
    }
    else if (mensagem_02 != ''){

        showConfirmacao('<center>' + (mensagem_02 + "<br>Deseja confirmar esta operação?") + '</center>'
                       ,"Confirma&ccedil;&atilde;o - Aimaro"
                       ,"verificaMensagens('','','" + mensagem_03 + "','" + mensagem_04 + "','" + mensagem_05 + "','" + qtctarel + "','" + grupo + "','" + vlutiliz + "','" + vlexcedi + "');"
                       ,"telaOperacaoNaoEfetuada();"
                       ,"sim.gif","nao.gif");
    }
    else if (mensagem_03 != ''){

        exibeRotina($('#divUsoGenerico'));

        limpaDivGenerica();

        // Carrega conteúdo da opção através do Ajax
        $.ajax({
            type: 'POST',
            dataType: 'html',
            url: UrlSite + 'telas/atenda/descontos/titulos/titulos_tabela_grupo.php',
            data: {
                mensagem_03: mensagem_03,
                mensagem_04: mensagem_04,
                mensagem_05: mensagem_05,
                nrdconta: nrdconta,
                qtctarel: qtctarel,
                grupo: grupo,
                vlutiliz: vlutiliz,
                vlexcedi: vlexcedi,
                redirect: 'html_ajax'
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina);');
            },
            success: function (response) {
                $('#divUsoGenerico').html(response);
                layoutPadrao();
                formataMensagem03();
                hideMsgAguardo();
                bloqueiaFundo($('#divUsoGenerico'));
            }
        });
    }
    else if (mensagem_04 != ''){
        showError("inform",mensagem_04,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')));verificaMensagens('','','','','"+ mensagem_05 + "','" + qtctarel + "','" + grupo + "','" + vlutiliz + "','" + vlexcedi + "');");
    }
    else if(mensagem_05 != ''){
        showConfirmacao('<center>' + mensagem_05 + '</center>'
                       ,"Confirma&ccedil;&atilde;o - Aimaro"
                       ,"verificaMensagens('','','','', '','" + qtctarel + "','" + grupo + "','" + vlutiliz + "','" + vlexcedi + "');"
                       ,"telaOperacaoNaoEfetuada();"
                       ,"sim.gif","nao.gif");
    }
    else{
        confirmaNovoLimite(1);
    }
    return false;
}


function telaOperacaoNaoEfetuada() {
    fechaRotina($('#divUsoGenerico'),'divRotina');
    showError('inform','Opera&ccedil;&atilde;o n&atilde;o efetuada!','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
    return false;
}

function formataMensagem03() {

    var Labels = $('label[for="vlutiliz"],label[for="vlexcedi"]','#divGrupoEconomico');

    Labels.css({'width':'120px','height':'22px','float':'left','display':'block'});

    var Inputs = $('input','#divGrupoEconomico');
    Inputs.css({'width':'120px','text-align':'right','float':'left','display':'block'});
    Inputs.desabilitaCampo();

    var divRegistro = $('div.divRegistros','#divGrupoEconomico');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'100px'});
    divRegistro.css({'width':'250px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '230px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';

    var metodoTabela = '';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

    $('#btnContinuar').unbind('click');

    return false;
}

function aceitarRejeicao(confirm, tipo) {
    if(!confirm || confirm == 0){
        showConfirmacao(
                        "Deseja cancelar este limite?",
                        "Confirma&ccedil;&atilde;o - Aimaro",
                        "aceitarRejeicao(1);",
                        "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))",
                        "sim.gif",
                        "nao.gif");
        return false;
    }
    if(confirm == 1){
            showMsgAguardo("Aguarde, confirmando cancelamento da proposta...");

            var operacao = "ACEITAR_REJEICAO_LIMITE";

            $.ajax({        
                type: "POST", 
                url: UrlSite + "telas/atenda/descontos/manter_rotina.php",
                dataType: "html",
                data: {
                    tipo: tipo,
                    operacao: operacao,
                    nrdconta: nrdconta,
                    nrctrlim: nrctrlim,
                    vllimite: vllimite,
                    redirect: "html_ajax"
                },      
                error: function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
                },
                success: function(response) {
                    try {
                        eval(response);
                        hideMsgAguardo();
                    } catch (error) {
                        hideMsgAguardo();
                        showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
                    }
                }           
            }); 
        return false;
    }
}


function exibeAlteraNumero() {

    showMsgAguardo('Aguarde, abrindo altera&ccedil;&atilde;o...');

    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();
    
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/titulos/numero.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "bloqueiaFundo($('#divUsoGenerico'));");
        },
        success: function (response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });

    return false;
}

function fechaRotinaAltera() {

    fechaRotina($('#divUsoGenerico'), $('#divRotina'));
    carregaLimitesTitulos();
    return false;

}

function fecharRotinaGenerico(tipo){
    if(tipo === "CONTRATO"){
        fechaRotina($('#divUsoGenerico'), $('#divRotina'));
        carregaLimitesTitulos();
        return false;
    }else if(tipo === "PROPOSTA"){
         fechaRotina($('#divUsoGenerico'), $('#divRotina'));
        carregaLimitesTitulosPropostas();
        return false;
    }else if(tipo === "TITULOS"){
        voltaDiv(2,1,4,'DESCONTO DE T&Iacute;TULOS','DSC TITS');
        carregaTitulos(); 
        return false;
    }
    return false;

}

function limpaDivGenerica() {

    $('#numero').remove();
    $('#altera').remove();

    return false;
}

function confirmaAlteraNrContrato() {
    showConfirmacao("Alterar n&uacute;mero da proposta?", "Confirma&ccedil;&atilde;o - Aimaro", "AlteraNrContrato();", "$('#new_nrctrlim','#frmNumero').focus();blockBackground(parseInt($('#divUsoGenerico').css('z-index')));", "sim.gif", "nao.gif");
}

// Função para alterar apenas o numero de contrato de limite 
function AlteraNrContrato() {

    showMsgAguardo("Aguarde, alterando n&uacute;mero do contrato ...");

    var nrctrant = $('#nrctrlim', '#frmNumero').val().replace(/\./g, "");
    var nrctrlim = $('#new_nrctrlim', '#frmNumero').val().replace(/\./g, "");

    // Valida número do contrato
    if (nrctrlim == "" || nrctrlim == "0" || !validaNumero(nrctrlim, true, 0, 0)) {
        hideMsgAguardo();
        showError("error", "Numero da proposta deve ser diferente de zero.", "Alerta - Aimaro", "$('#new_nrctrlim','#frmNumero').focus();blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
        return false;
    }

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_alterar_numero.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
            nrctrant: nrctrant,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao3").html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });
}

// Carregar os dados para consulta de limite de desconto de títulos
function carregaDadosAlteraLimiteDscTit() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados de desconto de t&iacute;tulos ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_alterar.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrcontrato,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
			controlaLupas(nrdconta);
		}				
	});		
}

// Função para gravar dados do limite de desconto de titulo
function gravaLimiteDscTit(cddopcao, tipo) {

	var nrcpfcgc = $("#nrcpfcgc","#frmCabAtenda").val().replace(".","").replace(".","").replace("-","").replace("/","");
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, efetuando " + (cddopcao == "A" ? "altera&ccedil;&atilde;o" : "inclus&atilde;o") + " do limite ...");
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_grava_proposta.php",
		data: {
            tipo: tipo,
			nrdconta: nrdconta,
			cddopcao: cddopcao,
			nrcpfcgc: nrcpfcgc,
			
			nrctrlim: $("#nrctrlim","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			vllimite: $("#vllimite","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			dsramati: $("#dsramati","#frmDadosLimiteDscTit").val(),
            vlmedtit: $("#vlmedtit","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			vlfatura: $("#vlfatura","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			vloutras: $("#vloutras","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			vlsalari: $("#vlsalari","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			vlsalcon: $("#vlsalcon","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			dsdbens1: $("#dsdbens1","#frmDadosLimiteDscTit").val(),
			dsdbens2: $("#dsdbens2","#frmDadosLimiteDscTit").val(),            
			cddlinha: $("#cddlinha","#frmDadosLimiteDscTit").val(),
			dsobserv: removeCaracteresInvalidos(removeAcentos($("#dsobserv","#frmDadosLimiteDscTit").val())),
			qtdiavig: $("#qtdiavig","#frmDadosLimiteDscTit").val().replace(/dias/,""),

			// 1o. Avalista 
			nrctaav1: normalizaNumero($("#nrctaav1","#frmDadosLimiteDscTit").val()),
			nmdaval1: $("#nmdaval1","#frmDadosLimiteDscTit").val(),
			nrcpfav1: normalizaNumero($("#nrcpfav1","#frmDadosLimiteDscTit").val()),
			tpdocav1: $("#tpdocav1","#frmDadosLimiteDscTit").val(),
			dsdocav1: $("#dsdocav1","#frmDadosLimiteDscTit").val(),
			nmdcjav1: $("#nmdcjav1","#frmDadosLimiteDscTit").val(),
			cpfcjav1: normalizaNumero($("#cpfcjav1","#frmDadosLimiteDscTit").val()),
			tdccjav1: $("#tdccjav1","#frmDadosLimiteDscTit").val(),
			doccjav1: $("#doccjav1","#frmDadosLimiteDscTit").val(),
			ende1av1: $("#ende1av1","#frmDadosLimiteDscTit").val(),
			ende2av1: $("#ende2av1","#frmDadosLimiteDscTit").val(),
			nrcepav1: normalizaNumero($("#nrcepav1","#frmDadosLimiteDscTit").val()),
			nmcidav1: $("#nmcidav1","#frmDadosLimiteDscTit").val(),
			cdufava1: $("#cdufava1","#frmDadosLimiteDscTit").val(),
			nrfonav1: $("#nrfonav1","#frmDadosLimiteDscTit").val(),
			emailav1: $("#emailav1","#frmDadosLimiteDscTit").val(),
			nrender1: normalizaNumero($("#nrender1","#frmDadosLimiteDscTit").val()),
			complen1: $("#complen1","#frmDadosLimiteDscTit").val(),
			nrcxaps1: normalizaNumero($("#nrcxaps1","#frmDadosLimiteDscTit").val()),

			// 2o. Avalista 
			nrctaav2: normalizaNumero($("#nrctaav2","#frmDadosLimiteDscTit").val()),
			nmdaval2: $("#nmdaval2","#frmDadosLimiteDscTit").val(),
			nrcpfav2: normalizaNumero($("#nrcpfav2","#frmDadosLimiteDscTit").val()),
			tpdocav2: $("#tpdocav2","#frmDadosLimiteDscTit").val(),
			dsdocav2: $("#dsdocav2","#frmDadosLimiteDscTit").val(),
			nmdcjav2: $("#nmdcjav2","#frmDadosLimiteDscTit").val(),
			cpfcjav2: normalizaNumero($("#cpfcjav2","#frmDadosLimiteDscTit").val()),
			tdccjav2: $("#tdccjav2","#frmDadosLimiteDscTit").val(),
			doccjav2: $("#doccjav2","#frmDadosLimiteDscTit").val(),
			ende1av2: $("#ende1av2","#frmDadosLimiteDscTit").val(),
			ende2av2: $("#ende2av2","#frmDadosLimiteDscTit").val(),
			nrcepav2: normalizaNumero($("#nrcepav2","#frmDadosLimiteDscTit").val()),
			nmcidav2: $("#nmcidav2","#frmDadosLimiteDscTit").val(),
			cdufava2: $("#cdufava2","#frmDadosLimiteDscTit").val(),
			nrfonav2: $("#nrfonav2","#frmDadosLimiteDscTit").val(),
			emailav2: $("#emailav2","#frmDadosLimiteDscTit").val(),
			nrender2: normalizaNumero($("#nrender2","#frmDadosLimiteDscTit").val()),
			complen2: $("#complen2","#frmDadosLimiteDscTit").val(),
			nrcxaps2: normalizaNumero($("#nrcxaps2","#frmDadosLimiteDscTit").val()),
            idcobope: normalizaNumero($('#idcobert', '#frmDadosLimiteDscTit').val()),
			
			// Variáveis globais alimentadas na função validaDadosRating em rating.js 
			nrgarope: nrgarope,
			nrinfcad: nrinfcad,
			nrliquid: nrliquid,
			nrpatlvr: nrpatlvr,			
			vltotsfn: vltotsfn,
			perfatcl: perfatcl,
			nrperger: nrperger,	
			
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
}

// Validar os dados da proposta de limite
function validaLimiteDscTit(cddopcao,idconfir,idconfi2,idconfi5) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando dados do limite ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_valida_proposta.php",
		data: {
			nrdconta: nrdconta,
			nrctrlim: $("#nrctrlim","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			cddopcao: cddopcao,
			dtrating: dtrating, 
			diaratin: diaratin, 
			vlrrisco: vlrrisco, 
			vllimite: $("#vllimite","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			cddlinha: $("#cddlinha","#frmDadosLimiteDscTit").val(),
			inconfir: idconfir,
			inconfi2: idconfi2,
			inconfi4: 71,
			inconfi5: idconfi5,
			redirect: "html_ajax"
  	
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}			
	});
}

// Função para validar o numero de contrato
function validaNrContrato(tipo) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando n&uacute;mero do contrato ...");
	
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_incluir_validaconfirma.php",
		data: {
            tipo: tipo,
			nrdconta: nrdconta,
            nrctrlim: $("#nrctrlim","#frmDadosLimiteDscTit").val().replace(/\./g,""),

			nrctaav1: 0,
			nrctaav2: 0,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
}

/*!
 * OBJETIVO : Função para validar avalistas 
 * ALTERAÇÃO 001: Padronizado o recebimento de valores 
 */
function validarAvalistas(tipo) {

	showMsgAguardo('Aguarde, validando dados dos avalistas ...');	
	
	var nrctaav1 = normalizaNumero( $('#nrctaav1','#'+nomeForm).val() );
	var nrcpfav1 = normalizaNumero( $('#nrcpfav1','#'+nomeForm).val() );
	var cpfcjav1 = normalizaNumero( $('#cpfcjav1','#'+nomeForm).val() );
	var nrctaav2 = normalizaNumero( $('#nrctaav2','#'+nomeForm).val() );
	var nrcpfav2 = normalizaNumero( $('#nrcpfav2','#'+nomeForm).val() );
	var cpfcjav2 = normalizaNumero( $('#cpfcjav2','#'+nomeForm).val() );	
	
	var nmdaval1 = trim( $('#nmdaval1','#'+nomeForm).val() );
	var ende1av1 = trim( $('#ende1av1','#'+nomeForm).val() );
	var nrcepav1 = normalizaNumero($("#nrcepav1",'#'+nomeForm).val())
	
	var nmdaval2 = trim( $('#nmdaval2','#'+nomeForm).val() );
	var ende1av2 = trim( $('#ende1av2','#'+nomeForm).val() );
	var nrcepav2 = normalizaNumero($("#nrcepav2",'#'+nomeForm).val())
	
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/atenda/descontos/titulos/titulos_avalistas_validadados.php',
		data: {
            tipo: tipo,
			nrdconta: nrdconta,	nrctaav1: nrctaav1,	nmdaval1: nmdaval1,	
			nrcpfav1: nrcpfav1, cpfcjav1: cpfcjav1,	ende1av1: ende1av1,	
			nrctaav2: nrctaav2,	nmdaval2: nmdaval2, nrcpfav2: nrcpfav2,	
			cpfcjav2: cpfcjav2,	ende1av2: ende1av2, cddopcao: operacao,
			nrcepav1: nrcepav1, nrcepav2: nrcepav2, redirect: 'script_ajax'
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina);');
		},
		success: function(response) {
			try {
				eval(response);				
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. ' + error.message,'Alerta - Aimaro','bloqueiaFundo(divRotina);');
			}
		}				
	});
}

function controlaLupas(nrdconta) {

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDadosLimiteDscTit';
		
	// Atribui a classe lupa para os links de desabilita todos
	$('a','#'+nomeFormulario).addClass('lupa').css('cursor','auto');
	
	// Percorrendo todos os links
	$('a','#'+nomeFormulario).each( function(i) {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');
				
		$(this).click( function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');

				if ( campoAnterior == 'cddlinha' ) {
					bo			= 'b1wgen0030.p';
					procedure	= 'lista-linhas-desc-tit';
					titulo      = 'Linhas de Desconto de T&iacute;tulo';
					qtReg		= '5';
					filtros 	= 'C&oacutedigo;cddlinha;30px;S;0|Descr;cddlinh2;100px;S;;N;|Taxa;txmensal;100px;S;;N;codigo;|Conta;nrdconta;100px;S;' + nrdconta + ';N;codigo;';
					colunas 	= 'Cod.;cddlinha;15%;right|Descr;dsdlinha;65%;left|Taxa;txmensal;20%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;
				}
			}
		});
	});
	
	$('#cddlinha','#'+nomeFormulario).unbind('change').bind('change',function() {		
				
		//Adiciona filtro por conta para a Procedure
		var filtrosDesc = 'nrdconta|'+ nrdconta;
		
		buscaDescricao('b1wgen0030.p','lista-linhas-desc-tit','Linhas de Desconto de T&iacute;tulo',$(this).attr('name'),'cddlinh2',$(this).val(),'dsdlinha',filtrosDesc,nomeFormulario);
		return false;
	});	
	
	$('#cddlinha','#'+nomeFormulario).unbind('keypress').bind('keypress',function(e) {		
		
		if(e.keyCode == 13){
		
			//Adiciona filtro por conta para a Procedure
			var filtrosDesc = 'nrdconta|'+ nrdconta;
			
			buscaDescricao('b1wgen0030.p','lista-linhas-desc-tit','Linhas de Desconto de T&iacute;tulo',$(this).attr('name'),'cddlinh2',$(this).val(),'dsdlinha',filtrosDesc,nomeFormulario);
						
			return false;
			
		}
		
	});	
	
	
	return false;
}
// Função para fechar div com mensagens de alerta
function encerraMsgsGrupoEconomico(){
	
	// Esconde div
	$("#divMsgsGrupoEconomico").css("visibility","hidden");
	
	$("#divListaMsgsGrupoEconomico").html("&nbsp;");
	
	// Esconde div de bloqueio
	unblockBackground();
	blockBackground(parseInt($("#divRotina").css("z-index")));
	
	eval(dsmetodo);
	
	return false;
	
}

function mostraMsgsGrupoEconomico(){
	
	
	if(strHTML != ''){
		
		// Coloca conteúdo HTML no div
		$("#divListaMsgsGrupoEconomico").html(strHTML);
		$("#divMensagem").html(strHTML2);
				
		// Mostra div 
		$("#divMsgsGrupoEconomico").css("visibility","visible");
		
		exibeRotina($("#divMsgsGrupoEconomico"));
		
		// Esconde mensagem de aguardo
		hideMsgAguardo();
					
		// Bloqueia conteúdo que está átras do div de mensagens
		blockBackground(parseInt($("#divMsgsGrupoEconomico").css("z-index")));
				
	}
	
	return false;
	
}
function formataGrupoEconomico(){

	var divRegistro = $('div.divRegistros','#divMsgsGrupoEconomico');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'140px'});
	
	$('#divListaMsgsGrupoEconomico').css({'height':'200px'});
	$('#divMensagem').css({'width':'250px'});
	
	var ordemInicial = new Array();
					
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	
	tabela.formataTabela( ordemInicial, '', arrayAlinha );
	
	return false;
	
}



function buscaGrupoEconomico(tipo) {

	showMsgAguardo("Aguarde, verificando grupo econ&ocirc;mico...");
	
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/atenda/descontos/titulos/busca_grupo_economico.php',
		data: {
			nrdconta: nrdconta,	
            tipo: tipo,
			redirect: 'html_ajax'
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}							
	});
	
	return false;
	
}

function abrirTelaGAROPC(cddopcao) {

    showMsgAguardo('Aguarde, carregando ...');

    var idcobert = normalizaNumero($('#idcobert','#'+nomeForm).val());
    var codlinha = normalizaNumero($('#cddlinha','#'+nomeForm).val());
    var vlropera = $('#vllimite','#'+nomeForm).val();
    
    var nrctrlim = '';
    // Se estamos consultando e está em estudo ou se iremos incluir ou se iremos alterar o limite enviaremos o codigo do contrato ativo
    if ( (cddopcao == 'C' && cd_situacao_lim == 1) || cddopcao == 'I' || cddopcao == 'A') {
      nrctrlim = normalizaNumero($('#nrcontratoativo').val());
    }
  
    // Se estivermos alterando, porém não houver cobertura é por que estamos alterando algo antigo (devemos criar um novo para estes casos)
    if (cddopcao == 'A' && idcobert == '') {
      cddopcao = 'I';
    }

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/garopc/garopc.php',
        data: {
            tipaber      : cddopcao,
            idcobert     : idcobert,
            nrdconta     : nrdconta,
            tpctrato     : 3,
            dsctrliq     : nrctrlim,
            codlinha     : codlinha,
            vlropera     : vlropera
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            hideMsgAguardo();
            // Criaremos uma div oculta para conter toda a estrutura da tela GAROPC
            $('#divUsoGAROPC').html(response).hide();
            // Iremos incluir o conteúdo do form da div oculta dentro da div principal de descontos
            $("#frmGAROPC", "#divUsoGAROPC").appendTo('#divFormGAROPC');
            // Iremos remover os botões originais da GAROPC e usar os proprios da tela
            $("#divBotoes","#frmGAROPC").detach();
            dscShowHideDiv("divFormGAROPC;divBotoesGAROPC","divDscTit_Limite;divBotoesLimite");
            bloqueiaFundo($('#divFormGAROPC'));
            $("#frmDadosLimiteDscTit").css("width", 540);
        }
    });
}

function calcEndividRiscoGrupo(nrdgrupo, tipo) {

	showMsgAguardo("Aguarde, calculando endividamento e risco do grupo econ&ocirc;mico...");

	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/atenda/descontos/titulos/calc_endivid_grupo.php',
		data: {
            tipo: tipo,
			nrdconta: nrdconta,	
			nrdgrupo: nrdgrupo,
			redirect: 'html_ajax'
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}							
	});
	
	return false;
	
}
function removeAcentos(str){
	return str.replace(/[àáâãäå]/g,"a").replace(/[ÀÁÂÃÄÅ]/g,"A").replace(/[ÒÓÔÕÖØ]/g,"O").replace(/[òóôõöø]/g,"o").replace(/[ÈÉÊË]/g,"E").replace(/[èéêë]/g,"e").replace(/[Ç]/g,"C").replace(/[ç]/g,"c").replace(/[ÌÍÎÏ]/g,"I").replace(/[ìíîï]/g,"i").replace(/[ÙÚÛÜ]/g,"U").replace(/[ùúûü]/g,"u").replace(/[ÿ]/g,"y").replace(/[Ñ]/g,"N").replace(/[ñ]/g,"n");
}

function removeCaracteresInvalidos(str){
	return str.replace(/[^A-z0-9\sÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ\!\@\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\>\<]/g,"");				 
}

function mostraListagemRestricoes(opcao,idconfir,idconfi2,idconfi3,idconfi4,idconfi5,idconfi6,indentra,indrestr) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando listagem ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_restricoes.php",
		dataType: "html",
		data: {
			cddopcao: opcao,
			inconfir: idconfir,
			inconfi2: idconfi2,
			inconfi3: idconfi3,
			inconfi4: idconfi4,
			inconfi5: idconfi5,
			inconfi6: idconfi6,
			indentra: indentra,
			indrestr: indrestr,
			nrdconta: nrdconta,
			nrborder: nrbordero,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao2").html(response);
		}				
	});		
}

//Funcao para formatar a tabela com inconsistências encontradas
function tabela(){

	var divRegistro = $('div.divRegistros', '#divMsgsGenericas');
	var tabela      = $('table',divRegistro );	
	var linha		= $('table > tbody > tr', divRegistro );
			
	$('#divMsgsGenericas').css('width', '400px');
    divRegistro.css({ 'height': '230px', 'width' : '100%'});

	var ordemInicial = new Array();
		ordemInicial = [[1,0]];		
			
	var arrayLargura = new Array(); 
		arrayLargura[0] = '25%';

    var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
		
	var metodoTabela = '';
				
	tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,metodoTabela);			
			
    
	$('div.divRegistros', '#divListaMsgsGenericas').css('display', 'block');
		
}

    
// Função para fechar div com mensagens de alerta
function encerraMsgsGenericas(){
	
    // Esconde div
    $("#divMsgsGenericas").css("visibility", "hidden");
	
    $("#divListaMsgsGenericas").html("&nbsp;");
	
	// Esconde div de bloqueio
	unblockBackground();
	blockBackground(parseInt($("#divRotina").css("z-index")));
	
	return false;
	
}

function mostraMsgsGenericas(){
	if(strHTML != ''){
		
	    //Coloca o titulo na tela
	    $("#tituloDaTela", "#divMsgsGenericas").html("Inconsist&ecirc;ncias");

		// Coloca conteúdo HTML no div
	    $("#divListaMsgsGenericas").html(strHTML);
		
		// Mostra div 
	    $("#divMsgsGenericas").css("visibility", "visible");
		
        tabela();

	    exibeRotina($("#divMsgsGenericas"));
		
		// Esconde mensagem de aguardo
		hideMsgAguardo();
					
		// Bloqueia conteúdo que está átras do div de mensagens
		blockBackground(parseInt($("#divMsgsGenericas").css("z-index")));
				
	}
	
	return false;
	
}

function abreProtocoloAcionamento(dsprotocolo) {

    showMsgAguardo('Aguarde, carregando...');

    // Executa script de através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        //url: UrlSite + 'telas/atenda/emprestimos/form_acionamentos.php',
        url: UrlSite + 'telas/atenda/descontos/titulos/titulos_limite_protocolo_acionamento.php',
        data: {
            dsprotocolo: dsprotocolo,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            hideMsgAguardo();
            if (response.substr(0,4) == "hide") {
                eval(response);
            } else {
                $('#nmarquiv', '#frmImprimir').val(response);
                //var action = UrlSite + 'telas/atenda/emprestimos/form_acionamentos.php';
                var action = UrlSite + 'telas/atenda/descontos/titulos/titulos_limite_protocolo_acionamento.php';
                carregaImpressaoAyllos("frmImprimir",action,"bloqueiaFundo(divRotina);");
            }
            return false;
        }
    });
}

// renovação
function renovarLimiteTitulo() {
    showMsgAguardo('Aguarde, carregando ...');

    var vllimite = $('#vllimite','#frmTitulos').val();
    var nrctrlim = $('#nrctrlim','#frmTitulos').val();
    var flgstlcr = $('#flgstlcr','#frmTitulos').val() == "yes"?1:0;
    var cddlinha = $('#cddlinha','#frmTitulos').val();
    var dsdlinha = $('#dsdlinha','#frmTitulos').val();

    fluxoRenovacaoLimite(0, vllimite, nrctrlim, flgstlcr, cddlinha, dsdlinha);
}

function fluxoRenovacaoLimite(flgvalida, vllimite, nrctrlim, flgstlcr, cddlinha, dsdlinha){
    if(!flgvalida){
        flgvalida = 0;
    }
    var callback = "fluxoRenovacaoLimite(1, '"+vllimite+"', '"+nrctrlim+"', '"+flgstlcr+"', '"+cddlinha+"', '"+dsdlinha+"');";

    if(flgvalida == 0){
        if(flgstlcr == 1){
            showConfirmacao(
                "Deseja renovar o Limite de desconto de título atual?",
                "Confirma&ccedil;&atilde;o - Aimaro",
                callback,
                "voltaDiv(2,1,4,'DESCONTO DE T&Iacute;TULOS','DSC TITS'); carregaTitulos(); hideMsgAguardo();",
                "sim.gif",
                "nao.gif");
                return false;
        }else if(flgstlcr == 0){
            showError(
                "inform",
                "Linha de crédito bloqueada, para realizar a operação altere para uma linha liberada ou efetue o desbloqueio da linha",
                "Alerta - Aimaro",
                callback);
            return false;
        }
        return false;

    }else if(flgvalida == 1){
        if(flgstlcr == 1){
            renovaValorLimite(vllimite, nrctrlim, cddlinha);
            return false;
        }else if(flgstlcr == 0){
            //mostrat rotina valor limite
            exibeRotina($('#divUsoGenerico'));
            $.ajax({
                type: 'POST',
                dataType: 'html',
                url: UrlSite + 'telas/atenda/descontos/titulos/titulos_valor_limite.php',
                data: {
                    vllimite: vllimite,
                    nrctrlim: nrctrlim,
                    flgstlcr: flgstlcr,
                    cddlinha: cddlinha,
                    dsdlinha: dsdlinha,
                    redirect: 'html_ajax'
                },
                error: function (objAjax, responseError, objExcept) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
                },
                success: function (response) {
                    $("#divOpcoesDaOpcao2").html(response);
                    formataValorLimite();
                    $('#vllimite','#frmReLimite').desabilitaCampo();
                    hideMsgAguardo();
                }
            });
            return false;
        }
        return false;
    }
    return false;   
}

function formataValorLimite() {
    highlightObjFocus( $('#frmReLimite') );

    var Lvllimite = $('label[for="vllimite"]','#frmReLimite');
    var Lcddlinha = $('label[for="cddlinha"]','#frmReLimite');
    var Ldsdlinha = $('label[for="dsdlinha"]','#frmReLimite');

    
    var Cvllimite = $('#vllimite','#frmReLimite');
    var Ccddlinha = $('#cddlinha','#frmReLimite');
    var Cdsdlinha = $('#dsdlinha','#frmReLimite');
    var Cnrctrlim =$('#nrctrlim','#frmReLimite');

    if(Lcddlinha.length && Ccddlinha.length){

        Lcddlinha.css({'width': '60px'}).addClass('rotulo');
        Ccddlinha.css({'width': '60px'}).addClass('codigo pesquisa');

        Ldsdlinha.css({'width': '60px'}).addClass('rotulo');
        Cdsdlinha.css({'width': '180px'}).addClass('descricao');
        Ccddlinha.desabilitaCampo();
        Cdsdlinha.desabilitaCampo();

        //pesquisa
        var campoAnterior = '';
        var qtReg, filtrosPesq, filtrosDesc, colunas;
        fncOnClose = 'fecharPesquisa();';
      
        $('a', '#frmReLimite').ponteiroMouse();
        $('a', '#frmReLimite').each( function(i) {
        
            if ( !$(this).prev().hasClass('campoTelaSemBorda') ) {
                $(this).css('cursor','pointer');
            }
                    
            $(this).click( function() {

                    campoAnterior = $(this).prev().attr('name');

                    if ( campoAnterior == 'cddlinha' ) {

                    filtrosPesq =   'Código;cddlinha;30px;S;|Descrição;dsdlinha;200px;S;|;flgstlcr;;;1;N|Tipo;tpdescto;;;3;N';
                    colunas =       'Código;cddlinha;15%;right|Descrição;dsdlinha;60%;left|Status;flgstlcr;25%;center;';//|Tipo;tpdescto;;;;N

                        mostraPesquisa('zoom0001',
                        'BUSCALINHASTIT', 
                        'Linhas de Crédito',
                        '20', 
                        filtrosPesq,
                        colunas,
                        divRotina,
                        fncOnClose);
                    }
              
            });
        });

    }
    
    if(Lvllimite.length && Cvllimite.length){
        Lvllimite.css({'width': '60px'}).addClass('rotulo');
        Cvllimite.css({'width': '100px'});
        Cvllimite.habilitaCampo();
        Cvllimite.focus();

        Cvllimite.unbind('keypress').bind('keypress', function(e) {
            if ( divError.css('display') == 'block' ) { return false; }
            if ( e.keyCode == 13) {
                renovaValorLimite(Cvllimite.val(), Cnrctrlim.val(), Ccddlinha.val());
                return false;
            }
        });
    }

    return false;
}

function fecharPesquisa(){
    var vllimite = $('#vllimite','#frmReLimite').val();
    var nrctrlim = $('#nrctrlim','#frmReLimite').val();
    var flgstlcr = $('#flgstlcr','#frmReLimite').val().toLowerCase()  == "Bloqueado".toLowerCase()?0:1;
    var cddlinha = $('#cddlinha','#frmReLimite').val();
    var dsdlinha = $('#dsdlinha','#frmReLimite').val();
    var dsdlinha = $('#dsdlinha','#frmReLimite').val();

    fluxoRenovacaoLimite(0, vllimite, nrctrlim, flgstlcr, cddlinha, dsdlinha);   
}

function renovaValorLimite(vllimite, nrctrlim, cddlinha) {

    showMsgAguardo('Aguarde, efetuando renovacao...');

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_renova_limite.php",
        data: {
            nrdconta: nrdconta,
            cddlinha: cddlinha,
            nrctrlim: nrctrlim.replace(/[^0-9]/g,''),
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                eval(response);
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;
}

function converteNumero (numero){

  return numero.replace('.','').replace(',','.');
}

function mostrarBorderoResumo() {
    var nrctrlim = normalizaNumero($("#nrctrlim","#divIncluirBordero").val());
    /*Testa se o valor disponivel mais a tolerancia são maiores que o total de titulos selecionados*/
    var vlutiliz = $("#vlutiliz","#divIncluirBordero"); //valor descontado
    var vllimite = $("#vllimite","#divIncluirBordero"); //valor disponivel
    var vlseleci = $("#vlseleci","#divIncluirBordero"); //valor titulos selecionados
    var pctolera = $("#pctolera","#divIncluirBordero"); //porcentagem de tolerancia (tab052)
    var total = 0;
    vllimite = converteMoedaFloat(vllimite.val());
    vlutiliz = converteMoedaFloat(vlutiliz.val());
    vlseleci = converteMoedaFloat(vlseleci.val());
    pctolera = converteMoedaFloat(pctolera.val());

    total = vllimite + (vllimite * pctolera / 100) - vlutiliz; // valor disponivel considerando a tolerancia


    if(total<(vlseleci)){
        showError("error", "Valor do border&ocirc; excede o valor do limite dispon&iacute;vel. Permitido at&eacute;: "+number_format(total,2,',','.'), "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }
    else{
    var divSelecionados = $(".divRegistrosTitulosSelecionados table","#divIncluirBordero");
    var selecionados = $("input[name*='selecionados'",divSelecionados);
    if(selecionados.length>0){
        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, realizando an&aacute;lise do biro ...");
        // Carrega conteúdo da opção através de ajax
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/descontos/titulos/rotinas_analise.php",
            dataType: "html",
            data: {
                nrdconta: nrdconta,
                nrctrlim: nrctrlim,
                rotina: 'biro',
                selecionados: selecionados.map(function(){return $(this).val();}).get(),
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                var r = $.parseJSON(response);
                if (r.status=='erro'){
                    hideMsgAguardo();
                    showError("error", r.mensagem, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                }
                else{
                    showMsgAguardo("Aguarde, realizando an&aacute;lise dos sacados ...");
                    // Carrega conteúdo da opção através de ajax
                    $.ajax({
                        type: "POST",
                        url: UrlSite + "telas/atenda/descontos/titulos/rotinas_analise.php",
                        dataType: "html",
                        data: {
                            nrdconta: nrdconta,
                            nrctrlim: nrctrlim,
                            rotina: 'analise_pagadores',
                            selecionados: selecionados.map(function(){return $(this).val();}).get(),
                            redirect: "html_ajax"
                        },
                        error: function (objAjax, responseError, objExcept) {
                            hideMsgAguardo();
                            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                        },
                        success: function (response) {
                            var r = $.parseJSON(response);
                            if (r.status=='erro'){
                                hideMsgAguardo();
                                showError("error", r.mensagem, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                            }
                            else{
                                showMsgAguardo("Aguarde, carregando resumo dos t&iacute;tulos ...");
                                // Carrega conteúdo da opção através de ajax
                                $.ajax({
                                    type: "POST",
                                    url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_resumo.php",
                                    dataType: "html",
                                    data: {
                                        nrdconta: nrdconta,
                                                                nrctrlim: nrctrlim,
                                        selecionados: selecionados.map(function(){return $(this).val();}).get(),
                                        redirect: "html_ajax"
                                    },
                                    error: function (objAjax, responseError, objExcept) {
                                        hideMsgAguardo();
                                        showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                                    },
                                    success: function (response) {
                                        $("#divOpcoesDaOpcao4").html(response);
                                    }
                                });
                            }
                        }
                    });
                }
            }
        });
    }
    else{
        showError("error", "Adicione pelo menos um t&iacute;tulo.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }
    }
    return false;
}

function mostrarBorderoResumoAlterar() {
    var nrctrlim = normalizaNumero($("#nrctrlim","#divIncluirBordero").val());
    /*Testa se o valor disponivel mais a tolerancia são maiores que o total de titulos selecionados*/
    var vlutiliz = $("#vlutiliz","#divIncluirBordero"); //valor descontado
    var vllimite = $("#vllimite","#divIncluirBordero"); //valor disponivel
    var vlseleci = $("#vlseleci","#divIncluirBordero"); //valor titulos selecionados
    var pctolera = $("#pctolera","#divIncluirBordero"); //porcentagem de tolerancia (tab052)
    var nrborder = $("#nrborder","#divIncluirBordero"); //porcentagem de tolerancia (tab052)
    var total = 0;
    vllimite = converteMoedaFloat(vllimite.val());
    vlutiliz = converteMoedaFloat(vlutiliz.val());
    vlseleci = converteMoedaFloat(vlseleci.val());
    pctolera = converteMoedaFloat(pctolera.val());

    total = vllimite + (vllimite * pctolera / 100) - vlutiliz; // valor disponivel considerando a tolerancia


    if(total<(vlseleci)){
        showError("error", "Valor do border&ocirc; excede o valor do limite dispon&iacute;vel. Permitido at&eacute;: "+number_format(total,2,',','.'), "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }
    else{
        var divSelecionados = $(".divRegistrosTitulosSelecionados table","#divIncluirBordero");
        var selecionados = $("input[name*='selecionados'",divSelecionados);
        if(selecionados.length>0){
            // Mostra mensagem de aguardo
            showMsgAguardo("Aguarde, realizando an&aacute;lise do biro ...");

            // Carrega conteúdo da opção através de ajax
            $.ajax({
                type: "POST",
                url: UrlSite + "telas/atenda/descontos/titulos/rotinas_analise.php",
                dataType: "html",
                data: {
                    nrdconta: nrdconta,
                    nrctrlim: nrctrlim,
                    rotina: 'biro',
                    selecionados: selecionados.map(function(){return $(this).val();}).get(),
                    redirect: "html_ajax"
                },
                error: function (objAjax, responseError, objExcept) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                },
                success: function (response) {
                    var r = $.parseJSON(response);
                    if (r.status=='erro'){
                        hideMsgAguardo();
                        showError("error", r.mensagem, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                    }
                    else{
                        showMsgAguardo("Aguarde, realizando an&aacute;lise dos sacados ...");
                        // Carrega conteúdo da opção através de ajax
                        $.ajax({
                            type: "POST",
                            url: UrlSite + "telas/atenda/descontos/titulos/rotinas_analise.php",
                            dataType: "html",
                            data: {
                                nrdconta: nrdconta,
                                nrctrlim: nrctrlim,
                                rotina: 'analise_pagadores',
                                selecionados: selecionados.map(function(){return $(this).val();}).get(),
                                redirect: "html_ajax"
                            },
                            error: function (objAjax, responseError, objExcept) {
                                hideMsgAguardo();
                                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                            },
                            success: function (response) {
                                var r = $.parseJSON(response);
                                if (r.status=='erro'){
                                    hideMsgAguardo();
                                    showError("error", r.mensagem, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                                }
                                else{
                                    showMsgAguardo("Aguarde, carregando resumo dos t&iacute;tulos ...");
                                    // Carrega conteúdo da opção através de ajax
                                    $.ajax({
                                        type: "POST",
                                        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_resumo_alterar.php",
                                        dataType: "html",
                                        data: {
                                            nrdconta: nrdconta,
                                            nrborder: nrborder.val(),
                                            selecionados: selecionados.map(function(){return $(this).val();}).get(),
                                            redirect: "html_ajax"
                                        },
                                        error: function (objAjax, responseError, objExcept) {
                                            hideMsgAguardo();
                                            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                                        },
                                        success: function (response) {
                                            $("#divOpcoesDaOpcao4").html(response);
                                        }
                                    });
                                }
                            }
                        });
                    }
                }
            });
        }
        else{
            showError("error", "Adicione pelo menos um t&iacute;tulo.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        }
    }
    return false;
}

function mostrarBorderoResumoResgatar() {
    var divSelecionados = $(".divRegistrosTitulosSelecionados table","#divIncluirBordero");
    var selecionados = $("input[name*='selecionados'",divSelecionados);
    var nrctrlim = normalizaNumero($("#nrctrlim","#"+nomeForm).val());
    if(selecionados.length>0){
        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");

        // Carrega conteúdo da opção através de ajax
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_resumo_resgatar.php",
            dataType: "html",
            data: {
                nrdconta: nrdconta,
                nrctrlim: nrctrlim,
                selecionados: selecionados.map(function(){return $(this).val();}).get(),
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                $("#divOpcoesDaOpcao4").html(response);
            }
        });
    }
    else{
        showError("error", "Adicione pelo menos um t&iacute;tulo.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }
    return false;
}


function mostrarDetalhesPagador() {
    if(tituloSelecionadoResumo){
    showMsgAguardo("Aguarde, carregando dados do pagador ...");
        var id = 'titulo_'+tituloSelecionadoResumo;
        var tr = $("#"+id,"#divResumoBordero");
        var selecionados = $("input[name*='selecionados'",tr).val();
        var nrdconta = $("#nrdconta","#divResumoBordero").val();
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_detalhe.php",
            dataType: "html",
            data: {
                nrdconta:nrdconta,
                selecionados:selecionados,
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                $("#divOpcoesDaOpcao5").html(response);
            }
        });
    }
    else{
        showError("error","Selecione um t&iacute;tulo para ver os detalhes","Alerta - Aimaro","");
    }
    return false;
}

function selecionaTituloResumo(nrnosnum){
    tituloSelecionadoResumo = nrnosnum;
    return false;
}

function removerTituloResumo(){
    if(tituloSelecionadoResumo){
        /*Remove da tela de Resumo*/
        var selecionados = $(".divRegistrosTitulos table","#divResumoBordero");
        var id = 'titulo_'+tituloSelecionadoResumo;
        var tr = $("#"+id,"#divResumoBordero");
        tr.remove();
        selecionados.zebraTabela();
        selecionados.trigger("update");
        if (typeof arrayLarguraInclusaoBordero != 'undefined') {
            for (var i in arrayLarguraInclusaoBordero) {
                $('td:eq(' + i + ')', selecionados).css('width', arrayLarguraInclusaoBordero[i]);
            }       
        }   
        selecionados.find('> tbody > tr').each(function (i) {
            $(this).unbind('click').bind('click', function () {
                selecionados.zebraTabela(i);
            });
        });
        /*Remove da tela de Selecao*/
        var td = $(".divRegistrosTitulosSelecionados #"+id+" td:first-child","#divIncluirBordero");
        if(td.length>0){
            removeTituloBordero(td);
        }
        bloqueiaFundo(divRotina);

        //Remove a seleção do titulo e seleciona a primeira linha
        $("#divResumoBordero .divRegistrosTitulos .tituloRegistros tr").eq(1).click();
        calculaValoresResumoBordero();
    }
    else{
        showError("error","Selecione um t&iacute;tulo para remover","Alerta - Aimaro","");
    }
    return false;
}

function confirmarInclusao(){
    var divSelecionados = $(".divRegistrosTitulos table","#divResumoBordero");
    var selecionados = $("input[name*='selecionados'",divSelecionados);
    if(selecionados.length>0){
        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");

        // Carrega conteúdo da opção através de ajax
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/descontos/manter_rotina.php",
            dataType: "html",
            data: {
                nrdconta: nrdconta,
                operacao: 'INSERIR_BORDERO',
                selecionados: selecionados.map(function(){return $(this).val();}).get(),
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                try{
                    var r = $.parseJSON(response);
                    nrbordero = r.nrborder;
                    flrestricao = r.flrestricao;
                    
                    //Caso tenha restricao, mostrar confirmação para analisar
                    if (flrestricao == 1){
                        showConfirmacao("<center>"+r.msg+"<br>Deseja analisar o border&ocirc; de desconto de t&iacute;tulos?</center>",
                            "Confirma&ccedil;&atilde;o - Aimaro",
                            "analisarBorderoDscTit(); dscShowHideDiv(\'divOpcoesDaOpcao1\',\'divOpcoesDaOpcao2;divOpcoesDaOpcao3;divOpcoesDaOpcao4;divOpcoesDaOpcao5\');",
                            "carregaBorderosTitulos();dscShowHideDiv(\'divOpcoesDaOpcao1\',\'divOpcoesDaOpcao2;divOpcoesDaOpcao3;divOpcoesDaOpcao4;divOpcoesDaOpcao5\');",
                            "sim.gif",
                            "nao.gif"
                        );                
                    }else{
                        showError(
                            "inform",
                            r.msg,
                            "Alerta - Aimaro",
                            "carregaBorderosTitulos();dscShowHideDiv(\'divOpcoesDaOpcao1\',\'divOpcoesDaOpcao2;divOpcoesDaOpcao3;divOpcoesDaOpcao4;divOpcoesDaOpcao5\');"
                        );
                    }
                }catch(error){
                eval(response);
            }
            }
        });
    }
    else{
        showError("error", "Adicione pelo menos um t&iacute;tulo.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }
    
    return false;
}

function confirmarAlteracao(){
    var divSelecionados = $(".divRegistrosTitulos table","#divResumoBordero");
    var selecionados = $("input[name*='selecionados'",divSelecionados);
    if(selecionados.length>0){
        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");

        // Carrega conteúdo da opção através de ajax
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/descontos/manter_rotina.php",
            dataType: "html",
            data: {
                nrdconta: nrdconta,
                nrborder: nrbordero,
                operacao: 'ALTERAR_BORDERO',
                selecionados: selecionados.map(function(){return $(this).val();}).get(),
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                try{
                    var r = $.parseJSON(response);
                   
                    showConfirmacao("<center>"+r.msg+"<br>Deseja analisar o border&ocirc; de desconto de t&iacute;tulos?</center>",
                        "Confirma&ccedil;&atilde;o - Aimaro",
                        "analisarBorderoDscTit(); dscShowHideDiv(\'divOpcoesDaOpcao1\',\'divOpcoesDaOpcao2;divOpcoesDaOpcao3;divOpcoesDaOpcao4;divOpcoesDaOpcao5\');",
                        "carregaBorderosTitulos();dscShowHideDiv(\'divOpcoesDaOpcao2\',\'divOpcoesDaOpcao1;divOpcoesDaOpcao3;divOpcoesDaOpcao4;divOpcoesDaOpcao5\');",
                        "sim.gif",
                        "nao.gif"
                    );                
                }
                catch(e){
                eval(response);
            }
            }
        });
    }
    else{
        showError("error", "Adicione pelo menos um t&iacute;tulo.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }
    
    return false;
}

function calculaValoresResumoBordero(){
    var valorSomaResumo  = 0;
    var qtdTitulosResumo = 0;
    var valorTemp;
    $("#divResumoBordero #divTitulos .divRegistrosTitulos tr[id^='titulo_']").each(function(){
        //Atualiza o valor
        valorTemp = $(this).find(".tit-bord-res-vl").contents().get(1).nodeValue;
        valorSomaResumo += converteMoedaFloat(valorTemp);

        //Atualiza a quantidade
        qtdTitulosResumo += 1;
    });

    //Atualiza os campos
    $("#divBotoesTitulosLimite .tit-bord-res-qtd").text(qtdTitulosResumo);
    $("#divBotoesTitulosLimite .tit-bord-res-vltot").text(number_format(valorSomaResumo,2,',','.'));
}

function confirmarResgate(){
    var divSelecionados = $(".divRegistrosTitulos table","#divResumoBordero");
    var selecionados = $("input[name*='selecionados'",divSelecionados);
    var nrctrlim = normalizaNumero($("#nrctrlim","#frmTitulos").val());
    if(selecionados.length>0){
        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");

        // Carrega conteúdo da opção através de ajax
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/descontos/manter_rotina.php",
            dataType: "html",
            data: {
                nrdconta: nrdconta,
                nrctrlim: nrctrlim,
                operacao: 'RESGATAR_TITULOS',
                selecionados: selecionados.map(function(){return $(this).val();}).get(),
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                eval(response);
            }
        });
    }
    else{
        showError("error", "Adicione pelo menos um t&iacute;tulo.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }
    
    return false;
}

function selecionarTituloDeBordero(id, qtd, pr_nossonum) {
    var cor = "";

    var id = 'trTitBordero'+id;
    var tr = $("#"+id,"#divTitulosBorderos");
    selecionados = $("input[name*='selecionados'",tr).val();

    nossonum = pr_nossonum
    // Formata cor da linha da tabela que lista os borderos de descto titulos
    for (var i = 1; i <= qtd; i++) {
        if (cor == "#F4F3F0") {
            cor = "#FFFFFF";
        } else {
            cor = "#F4F3F0";
        }

        // Formata cor da linha
        $("#trTitBordero" + i).css("background-color", cor);

        if (i == id) {
            // Atribui cor de destaque para bordero selecionado
            $("#trTitBordero" + id).css("background-color", "#FFB9AB");
        }
    }
    return false;
}

function visualizarTituloDeBordero() {

    showMsgAguardo("Aguarde, carregando dados do pagador ...");
    var nrdconta = $("#nrdconta","#divTitulosBorderos").val();

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_visualizar_titulo.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            selecionados: selecionados,
            nrborder: nrbordero,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao5").html(response);
        }
    });
    return false;
}

function realizarManutencaoDeLimite(operacao, flgstlcr) {
    // operacao = 0 (mostrar dialogo confirmacao), operacao = 1 (carregar tela), operacao = 3 (executar operacao)
    showMsgAguardo("Aguarde, carregando dados do contrato...");
    var var_nrctrlim = normalizaNumero($("#nrctrlim","#frmTitulos").val());

    if(sitinctrmnt == 1){
        var_nrctrlim = nrctrlim;
    }

    if(!operacao){operacao = 0;}

    var callback = "realizarManutencaoDeLimite(1,"+flgstlcr+" );";

    if(var_nrctrlim == 0){
        showError(
                "inform",
                "Não existe contrato ativo.",
                "Alerta - Aimaro",
                "hideMsgAguardo();blockBackground(parseInt($('#divRotina').css('z-index')));");

        return false;
    }

    // linha bloqueada
    if(flgstlcr === 0){

        //se a operação não for a de carregar a tela
        if(operacao !== 1){
            showError(
                "inform",
                "Linha de descontos bloqueada, para realizar a operação altere para uma linha liberada ou efetue o desbloqueio da linha",
                "Alerta - Aimaro",
                callback);
            return false;
        }
    }
    // operação 0 mostra a janela de confirmação
    if(operacao === 0){
        showConfirmacao("Deseja realizar a manuten&ccedil;&atilde;o do contrato?",
            "Confirma&ccedil;&atilde;o - Aimaro",
            callback,
            "hideMsgAguardo();blockBackground(parseInt($('#divRotina').css('z-index')));",
            "sim.gif",
            "nao.gif");
        return false;
    }

    if(operacao === 1){
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_manutencao.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrlim: var_nrctrlim,
            inctrmnt: sitinctrmnt,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            if(sitinctrmnt == 1){
                $("#divOpcoesDaOpcao3").html(response);
            } else {
                $("#divOpcoesDaOpcao2").html(response);
            }

             formataManutencaoDeLimite();
             hideMsgAguardo();
             blockBackground(parseInt($('#divRotina').css('z-index')));

        }
    });
    return false;
}

    if(operacao == 2){
        concluirManutencaoDeLimite();
        return false;;
    }

    return false;
}

function concluirManutencaoDeLimite(){
    showMsgAguardo('Aguarde, realizando manutenção do limite do contrato...');
    //nrdconta
    var nrctrlim = normalizaNumero($("#nrctrlim","#frmTitLimiteManutencao").val());
    var vllimite = $('#vllimite','#frmTitLimiteManutencao').val().replace(/\./g,"");
    var cddlinha = $('#cddlinha','#frmTitLimiteManutencao').val();

    var per_vllimite = $('#per_vllimite','#frmTitLimiteManutencao').val().replace(/\./g,"");
    var per_cddlinha = $('#per_cddlinha','#frmTitLimiteManutencao').val();
    if(vllimite == per_vllimite &&
        cddlinha == per_cddlinha){
        showError('error','Nenhum valor foi alterado.','Alerta - Aimaro',"blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");
        hideMsgAguardo();
        return;
    }

    $.ajax({        
        type    : 'POST',
        dataType: 'html',
            url     : UrlSite + 'telas/atenda/descontos/manter_rotina.php', 
            data    : {
                        nrdconta: nrdconta,
                        nrctrlim: nrctrlim,
                        vllimite: vllimite,
                        cddlinha: cddlinha,
                        inctrmnt: sitinctrmnt,
                        operacao: 'REALIZAR_MANUTENCAO_LIMITE',
                        redirect: 'script_ajax'

                    },
            error   : function(objAjax,responseError,objExcept) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','$(\'#nrinssac\',\''+nomeForm+'\').focus();');
                    },
            success : function(response) { 
                        hideMsgAguardo();
                        bloqueiaFundo(divRotina);
                        eval(response);
                    }
        }); 
}

function formataManutencaoDeLimite(){
        var nomeForm = 'frmTitLimiteManutencao';

        $('#'+nomeForm).css('width','515px');
        highlightObjFocus( $('#'+nomeForm) );

        //pesquisa
        var campoAnterior = '';
        var qtReg, filtrosPesq, filtrosDesc, colunas;

        var Lnrctrlim = $('label[for="nrctrlim"]','#'+nomeForm);
        var Lvllimite = $('label[for="vllimite"]','#'+nomeForm);
        var Lqtdiavig = $('label[for="qtdiavig"]','#'+nomeForm);
        
        var Ltxjurmor = $('label[for="txjurmor"]','#'+nomeForm);
        var Ltxdmulta = $('label[for="txdmulta"]','#'+nomeForm);
        var Ldsramati = $('label[for="dsramati"]','#'+nomeForm);
        var Lvlmedtit = $('label[for="vlmedtit"]','#'+nomeForm);
        var Lvlfatura = $('label[for="vlfatura"]','#'+nomeForm);
        
        var Cnrctrlim = $('#nrctrlim','#'+nomeForm);
        var Cvllimite = $('#vllimite','#'+nomeForm);
        var Cqtdiavig = $('#qtdiavig','#'+nomeForm);
        var Ctxjurmor = $('#txjurmor','#'+nomeForm);
        var Ctxdmulta = $('#txdmulta','#'+nomeForm);
        var Cdsramati = $('#dsramati','#'+nomeForm);
        var Cvlmedtit = $('#vlmedtit','#'+nomeForm);
        var Cvlfatura = $('#vlfatura','#'+nomeForm);
        
        Lnrctrlim.addClass('rotulo').css('width','150px');
        Lvllimite.addClass('rotulo').css('width','150px');
        Lqtdiavig.css('width','130px');
        
        Ltxjurmor.addClass('rotulo').css('width','150px');
        Ltxdmulta.addClass('rotulo').css('width','150px');
        Ldsramati.addClass('rotulo').css('width','150px');
        Lvlmedtit.addClass('rotulo').css('width','150px');
        Lvlfatura.addClass('rotulo').css('width','150px');

        Cnrctrlim.setMask("INTEGER","z.zzz.zz9","");
        Cnrctrlim.css({'width':'100px','text-align':'right'});
        Cnrctrlim.desabilitaCampo();
        Cnrctrlim.focus();

        Cvllimite.setMask("DECIMAL","zzz.zzz.zz9,99","");
        Cvllimite.css({'width':'100px','text-align':'right'});

        Cqtdiavig.css({'width':'65px','text-align':'right'});
        Cqtdiavig.desabilitaCampo();

        //Ccddlinh2.css({'width':'255px'});
        Ctxjurmor.css({'width':'100px','text-align':'right'});
        Ctxjurmor.desabilitaCampo();

        Ctxdmulta.css({'width':'100px','text-align':'right'});
        Ctxdmulta.desabilitaCampo();

        Cdsramati.setMask("STRING","40",charPermitido(),"");
        Cdsramati.css({'width':'300px'});
        Cdsramati.desabilitaCampo();

        Cvlmedtit.setMask("DECIMAL","z.zzz.zz9,99","");
        Cvlmedtit.css({'width':'100px','text-align':'right'});
        Cvlmedtit.desabilitaCampo();

        Cvlfatura.setMask("DECIMAL","zzz.zzz.zz9,99","");
        Cvlfatura.css({'width':'100px','text-align':'right'});
        Cvlfatura.desabilitaCampo();

        //Lupa
        var Ccddlinha = $('#cddlinha','#'+nomeForm);
        var Lcddlinha = $('label[for="cddlinha"]','#'+nomeForm);

        var Cdsdlinha = $('#dsdlinha','#'+nomeForm);
        //var Ldsdlinha = $('label[for="dsdlinha"]','#'+nomeForm);

        if(Lcddlinha.length && Ccddlinha.length){

            Lcddlinha.css({'width': '150px'}).addClass('rotulo');
            //Lcddlinha.addClass('rotulo').css('width','150px');
            Ccddlinha.css({'width': '60px','text-align':'right'}).addClass('codigo pesquisa');

            //Ldsdlinha.css({'width': '60px'}).addClass('rotulo');

            Cdsdlinha.css({'width': '180px'}).addClass('descricao');
            Cdsdlinha.desabilitaCampo();

            fncOnClose = 'cddlinha = $("#cddlinha","#"+nomeForm).val()';

            $('a', '#'+nomeForm).ponteiroMouse();
            $('a', '#'+nomeForm).each( function(i) {
            
                if ( !$(this).prev().hasClass('campoTelaSemBorda') ) {
                    $(this).css('cursor','pointer');
                }
                        
                $(this).click( function() {
                        campoAnterior = $(this).prev().attr('name');

                        if ( campoAnterior == 'cddlinha' ) {
                            
                        filtrosPesq =   'Código;cddlinha;30px;S;|Descrição;dsdlinha;200px;S;|;flgstlcr;;;1;N|Tipo;tpdescto;;;3;N';
                        colunas =       'Código;cddlinha;15%;right|Descrição;dsdlinha;60%;left|Status;flgstlcr;25%;center;';//|Tipo;tpdescto;;;;N

                            mostraPesquisa('zoom0001',
                            'BUSCALINHASTIT', 
                            'Linhas de Crédito',
                            '20', 
                            filtrosPesq,
                            colunas,
                            divRotina,
                            fncOnClose);
                        }
                  
            });
    });
        }

        Cnrctrlim.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if(e.keyCode == 13){
                Cvllimite.focus();
            }
        });
        Cvllimite.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if(e.keyCode == 13){
                Ccddlinha.focus();
            }
        });
        Cdsramati.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if(e.keyCode == 13){
                Cvlmedtit.focus();
            }
        });
        Cvlmedtit.unbind('keypress').bind('keypress', function(e){
            /*Se foi pressionado a telca ENTER*/
            if(e.keyCode == 13){
                Cvlfatura.focus();
            }
        });
    return false;
}

function carregaDadosDetalhesProposta(tipo, nrctrlim, nrctrmnt){
    showMsgAguardo("Aguarde, carregando detalhes da proposta ...");

    exibeRotina($('#divOpcoesDaOpcao2'));

    if(!nrctrlim){
        nrctrlim = 0;
    }
    if(!nrctrmnt){
        nrctrmnt = 0;
    }

    // Carrega conteúdo da opção através de ajax
    $.ajax({        
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_detalhes_proposta.php",
        dataType: "html",
        data: {
            tipo: tipo,
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
            nrctrmnt: nrctrmnt,
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1) {
                carregarAcionamentosDaProposta(tipo, nrctrlim, nrctrmnt, response);
            } else {
                eval(response);
            }
            return false;
        }               
    });
    return false;
}

function carregarAcionamentosDaProposta(tipo, nrctrlim, nrctrmnt, body){
    showMsgAguardo('Aguarde, buscando acionamentos da Proposta');
    
    if(!body){
        body = null;
    }

    $.ajax({        
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/atenda/descontos/manter_rotina.php', 
        data    : { 
                    tipo: tipo,
                    operacao: 'BUSCAR_ACIONAMENTOS_PROPOSTA',
                    nrdconta: nrdconta,   
                    nrctrlim: nrctrlim,
                    nrctrmnt: nrctrmnt,
                    redirect: 'script_ajax'

                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','$(\'#nrinssac\',\''+nomeForm+'\').focus();');
                },
        success : function(response) {
                if(body !== null){
                    $('#divOpcoesDaOpcao2').html(body);
                    dscShowHideDiv("divOpcoesDaOpcao2","divOpcoesDaOpcao1;divOpcoesDaOpcao3");
                    body = null;
                }
                var tabConteudo = $("#tabConteudo");
                tabConteudo.html(response);
                formatarTelaAcionamentosDaProposta();
                formatarTabelaAcionamentosDaProposta();
            }
    });
    return false;
}
function formatarTelaAcionamentosDaProposta(){

    //$('#divResultadoAciona', '#divOpcoesDaOpcao2');
    var divFormContent = $('#divFormContent','#divForm');
    var tabConteudo    = $('#tabConteudo', '#divResultadoAciona');

    var Lnrctrlim = $('label[for="nrctrlim"]',divFormContent);
    var Cnrctrlim = $('#nrctrlim', divFormContent);
    var Cnrctrmnt = $('#nrctrmnt', divFormContent);
    var Ctipo = $('#tipo', divFormContent);

    divFormContent.css({'width':'360px', 'float':'left', 'display':'block'});//'width':'120px', 'height':'360px'


    Lnrctrlim.css({'width': '60px'}).addClass('rotulo');
    Cnrctrlim.css({'width': '300px'});
    
   

    if(Ctipo.val() === "PROPOSTA"){
        Cnrctrlim.desabilitaCampo();
        Cnrctrlim.focus();

    }else{
        Cnrctrlim.habilitaCampo();
        Cnrctrlim.focus();
        Cnrctrlim.unbind('change').bind('change',function() {  
            nrctrlim = Cnrctrlim.val();
            nrctrmnt = Cnrctrmnt.val();
            tipo = Ctipo.val();
            carregarAcionamentosDaProposta(tipo, nrctrlim, nrctrmnt);
        });
    }

    var divRegistro = $('div.divRegistros', '#divResultadoAciona');
    var tabela = $('table', divRegistro);
    var tabelaHeader = $('table > thead > tr > th', divRegistro);
    var fonteLinha = $('table > tbody > tr > td', divRegistro);

    tabelaHeader.css({'font-size': '11px'});
    fonteLinha.css({'font-size': '11px'});

    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});

    return false;
}

function formatarTabelaAcionamentosDaProposta(){
        // tabela
        var tabConteudo    = $('#tabConteudo', '#divResultadoAciona');
        var divRegistro = $('div.divRegistros', tabConteudo);
        var tabela = $('table', divRegistro);

        divRegistro.css({'width':'940px', 'height': '207px', 'padding-bottom': '2px'});

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        arrayLargura[0] = '13%';//Acionamento
        arrayLargura[1] = '10%';//PA
        arrayLargura[2] = '15%';//Operador
        arrayLargura[3] = '20%';//Operação
        arrayLargura[4] = '15%';//Data e Hora
        arrayLargura[5] = '25%';//Retorno
        
        var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';//Acionamento
        arrayAlinha[1] = 'center';//PA
        arrayAlinha[2] = 'center';//Operador
        arrayAlinha[3] = 'center';//Operação
        arrayAlinha[4] = 'center';//Data e Hora
        arrayAlinha[5] = 'center';//Retorno

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
        return false;
}

// Mostrar dados para liberar um bordero
function liberarBorderoDscTit(confirma) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, liberando o border&ocirc; ...");
    
    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_liberar.php",
        data: {
            nrdconta: nrdconta,
            nrborder: nrbordero,
            confirma: confirma,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
    return false;
}





// Mostrar dados para rejeitar um bordero
function rejeitarBorderoDscTit(confirma) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, rejeitando o border&ocirc; ...");
    
    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_rejeitar.php",
        data: {
            nrdconta: nrdconta,
            nrborder: nrbordero,
            confirma: confirma,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;
}




function mostrarBorderoAnalisar() {
    showConfirmacao("Deseja analisar o border&ocirc; de desconto de t&iacute;tulos?","Confirma&ccedil;&atilde;o - Aimaro","analisarBorderoDscTit();","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");
    return false;
}

function mostrarBorderoLiberar() {
    showConfirmacao("Deseja liberar o border&ocirc; de desconto de t&iacute;tulos?","Confirma&ccedil;&atilde;o - Aimaro","liberarBorderoDscTit(0);","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");
    return false;
}

function mostrarBorderoRejeitar(contingencia) {
    //Verifica se o bordero já está em uma situação que não se pode rejeitar
    switch(fl_sitbordero.toUpperCase()){
        case 'LIBERADO':
            showError("error", "N&atilde;o &eacute; poss&iacute;vel rejeitar um border&ocirc; LIBERADO.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            break;
        case 'LIQUIDADO':
            showError("error", "N&atilde;o &eacute; poss&iacute;vel rejeitar um border&ocirc; LIQUIDADO.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            break;
        case 'REJEITADO':
            showError("error", "N&atilde;o &eacute; poss&iacute;vel rejeitar um border&ocirc; REJEITADO.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            break;
        default:
    if (contingencia){
        showConfirmacao("An&aacute;lise em conting&ecirc;ncia. Deseja rejeitar?","Confirma&ccedil;&atilde;o - Aimaro","rejeitarBorderoDscTit(0);","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");
    }else{
        showConfirmacao("Deseja rejeitar o border&ocirc; de desconto de t&iacute;tulos?","Confirma&ccedil;&atilde;o - Aimaro","rejeitarBorderoDscTit(0);","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");
    }
            break;
    }
   
    return false;
}

function efetuarPagamentoTitulosVencidos(fl_avalista, arr_titulos){
    showMsgAguardo('Aguarde, efetuando pagamento...');
    $.ajax({        
            type    : 'POST',
            dataType: 'html',
            url     : UrlSite + 'telas/atenda/descontos/manter_rotina.php', 
            data    : { 
                        operacao: 'PAGAR_TITULOS_VENCIDOS',
                        fl_avalista: fl_avalista,      //True ou False se é pagamento via avalista
                        nrdconta: nrdconta,   
                        nrborder: nrbordero,
                        arr_nrdocmto: arr_titulos.split(","),          //Array contendo o numero dos titulos a serem pagos
                        redirect: 'script_ajax'
            },
            error   : function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success : function(response) {
                hideMsgAguardo();
                if (response == 1)
                    showError('inform','T&iacute;tulos pagos com sucesso!','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));carregaBorderosTitulos();voltaDiv(3,2,4,\'DESCONTO DE TÍTULOS - BORDERÔS\');');
                else{
                    eval(response);
                }
            }
        });
}

function pagarTitulosVencidos(){
    var msg_confirmacao = 'Confirmar Pagamento?';
    var arr_nrdocmto    = [];
    var pgto_avalista   = $(".pagar-com-avalista").is(":checked");
    var possui_saldo    = false;    

    //Coloca em um array todos os titulos que vao ser pagos
    $('.pagar-pgto-tit:checked').each(function() {
        arr_nrdocmto.push($(this).val());
    });

    //Caso nada tenha sido selecionado mostra erro
    if (arr_nrdocmto.length <= 0){
        showError("error", "Selecione ao menos um t&iacute;tulo.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }else {
        if(pgto_avalista){ 
            showMsgAguardo('Aguarde, pagamento com avalista calculando saldo em conta...');
    }else{
        showMsgAguardo('Aguarde, calculando saldo em conta...');
        }

        //Invoca AJAX para verificar se possui Saldo em Conta
        $.ajax({        
            type    : 'POST',
            dataType: 'html',
            url     : UrlSite + 'telas/atenda/descontos/manter_rotina.php', 
            data    : { 
                        operacao: 'CALCULAR_SALDO_TITULOS_VENCIDOS',
                        fl_avalista: pgto_avalista,      //True ou False se é pagamento via avalista
                        nrdconta: nrdconta,   
                        nrborder: nrbordero,
                        arr_nrdocmto: arr_nrdocmto,          //Array contendo o numero dos titulos a serem pagos
                        redirect: 'script_ajax'
            },
            error   : function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success : function(response) { //Response:: 0 = Sem saldo e alçada | 1 = Possui Saldo | 2 = Sem saldo mas com alçada
                hideMsgAguardo();
                //Caso nao possua saldo, altera a mensagem
                if (response == 0){
                    showError("error", "Saldo do cooperado insuficiente e operador n&atilde;o possui al&ccedil;ada.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                }
                else if (response == 2){
                    msg_confirmacao = "Saldo em conta insuficiente para pagamento do t&iacute;tulo. Confirmar Pagamento com al&ccedil;ada?";
                    showConfirmacao(msg_confirmacao,"Confirma&ccedil;&atilde;o - Aimaro","efetuarPagamentoTitulosVencidos('"+pgto_avalista+"','"+arr_nrdocmto+"');","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");
                }else{
                    //Invoca a funcao
                    showConfirmacao(msg_confirmacao,"Confirma&ccedil;&atilde;o - Aimaro","efetuarPagamentoTitulosVencidos('"+pgto_avalista+"','"+arr_nrdocmto+"');","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");
                }
            }
        });
       
    }
    return false;
}

function visualizarDetalhesTitulo(){
    showMsgAguardo("Aguarde, carregando dados do t&iacute;tulo ...");

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_visualizar_detalhes.php",
        dataType: "html",
        data: {
            nrdconta    : nrdconta,
            selecionados: selecionados,
            nrborder    : nrbordero,
            redirect    : "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao5").html(response);
        }
    });
    return false;
}


// PRJ 438 - Inicio
function carregaDadosConsultaMotivos() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando motivos ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_consultar_motivos.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1) {
                $("#divOpcoesDaOpcao3").html(response);
            } else {
                eval(response);
            }
        }               
    });
    return false;
}

function formatarTelaConsultaMotivos(){

    $('#frmDadosMotivos').css('width','500px');

    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px', 'padding': '10px 3px 5px 3px'});
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});

    return false;
}

function gravaMotivosAnulacao(){
    
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando alterado o motivo");

    var cdmotivo     = $("input[name='cdmotivo']:checked", "#frmDadosMotivos").val();
    var dsmotivo     = $('#dsmotivo'+cdmotivo,'#frmDadosMotivos').val();
    var dsobservacao = $('#dsobservacao'+cdmotivo,'#frmDadosMotivos').val();

    $.ajax({        
        type: "POST", 
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_grava_motivo.php",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
            cdmotivo: cdmotivo,
            dsmotivo: dsmotivo,
            dsobservacao: dsobservacao,
            redirect: "script_ajax"
        }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                eval(response);
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }               
    });
}

function controlarMotivos(cdMotivo){
    if($('#cdmotivo'+cdMotivo,'#frmDadosMotivos').is(':checked')) {
        // Desabilitar todos os outros campos de observação
        $('input[type=text]', '#frmDadosMotivos').each(function() {
            $($(this), '#frmDadosMotivos').desabilitaCampo();
            $($(this), '#frmDadosMotivos').val('');
        });
        // Habilitar somente o campo de observação do motivo selecionado
        $('#dsobservacao'+cdMotivo,'#frmDadosMotivos').habilitaCampo();
    }
}
// PRJ 438 - FIM

function formataTabelaCriticas(div){
    var tabela = div.find("table");
    div.zebraTabela();
    tabela.css("text-align","center");
}
