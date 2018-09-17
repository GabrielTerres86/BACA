/***********************************************************************
      Fonte: pagamento_titulo_arq.js
      Autor: Andre Santos - SUPERO
      Data : Setembro/2014            Ultima atualizacao:01/11/2017

      Objetivo  : Biblioteca de funcoes da rotina PAGTO TITULOS POR ARQUIVO tela ATENDA.

      Alteracoes:
      25/07/2016 - Adicionado função controlaFoco.(Evandro - RKAM).
	  
	  01/11/2017 - Adicionado varias procedures referente a Melhoria 271.3 (Tiago)
 ***********************************************************************/

var dsdregis = "";  // Variavel para armazenar os valores dos titulares
var nrconven = 0;   // Variavel para guardar o convenio no inclui-altera.php
var mensagem = "Deseja efetuar impress&atilde;o do Termo de Ades&atilde;o ?"; // Mensagem de confirmacao de impressao
var callafterCobranca = '';
var Ldsemailsel;
var Cdsemailsel;
var Cdsemailadd; 

function habilitaSetor(setorLogado) {

    var setoresHabilitados = ['COBRANCA', 'TI', 'SUPORTE'];

    if (setoresHabilitados.indexOf(setorLogado) == -1) {
        $('#flgcebhm', '#frmConsulta').desabilitaCampo();
    }
}


// Acessar tela principal da rotina
function acessaOpcaoAba() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando os pagtos de titulos...");

    // Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/pagamento_titulo_arq/principal.php",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
			$("#divOpcaoConsulta").css('display', 'none');			
			$("#divLog").css('display', 'none');			
			
            $("#divConteudoOpcao").html(response);
			$("#divConteudoOpcao").css('display', 'block');
            controlaFoco();
        }
    });
}

//Função para controle de navegação
function controlaFoco() {
	/*
    $('#divConteudoOpcao').each(function () {
        $(this).find("#divBotoes > :input[type=image]").addClass("FluxoNavega");
        $(this).find("#divBotoes > :input[type=image]").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > :input[type=image]").last().addClass("LastInputModal");
    });
*/
    //Se estiver com foco na classe FluxoNavega
    $(".FluxoNavega").focus(function () {
        $(this).bind('keydown', function (e) {
            if (e.keyCode == 13) {
                $(this).click();
            }
        });
    });

    $(".FirstInputModal").focus();
}

/* Iniciar Impressao Termo de Servi&ccedil;o */
function acessaImpressaoTermo() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando Termo de Servi&ccedil;o ...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/pagamento_titulo_arq/imprimir.php",
        data: {
            nrdconta: nrdconta,
            nmdatela: "ATENDA",
            nmrotina: "PAGTO POR ARQUIVO",
            redirect: "html_ajax" // Tipo de retorno do ajax			
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {
            $("#divRotina").html(response);
        }
    });
}


/* Voltar para a rotina de Pagto por Arquivo */
function encerrarImpressaoTermo() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando Termo de Servi&ccedil;o ...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/pagamento_titulo_arq/pagamento_titulo_arq.php",
        data: {
            nrdconta: nrdconta,
            nmdatela: "ATENDA",
            nmrotina: "PAGTO POR ARQUIVO",
            redirect: "html_ajax" // Tipo de retorno do ajax			
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {
            $("#divRotina").html(response);
        }
    });
}


// Confirma se o convenio deve ser excluido
function confirmaExclusao() {

    var nrconven = $("#nrconven", "#divConteudoOpcao").val();

    // Convenio nao selecionado
    if (nrconven == "") {
        showError("error", "Selecione algum conv&ecirc;nio para excluir.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    showConfirmacao('078 - Confirma cancelamento do servi&ccedil;o? (S/N)', "Confirma&ccedil;&atilde;o - Ayllos", 'cancelar('+nrconven+');', "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
}

function cancelar(pr_nrconven){
	showMsgAguardo("Aguarde, efetuando a Altera&ccedil;&atilde;o do convenio ...");

	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/pagamento_titulo_arq/cancelar_convenio.php",
		data: {
			nrdconta: nrdconta,
			nrconven: pr_nrconven,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			try {
				hideMsgAguardo();
				msg = 'Cancelamento do convenio efetuado com sucesso!';
				showError("inform", msg, "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));acessaOpcaoAba();");
				eval(response);
			} catch (error) {
				hideMsgAguardo();
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
    });	
}

// Confirma inclusao de convenio
function confirmaAlteracao(pr_nrconven, pr_flghomol, pr_cdopehom, pr_idretorn, pr_flgativo, pr_lstemail) {
    showConfirmacao('078 - Confirma Altera&ccedil;&atilde;o do convenio? (S/N)', "Confirma&ccedil;&atilde;o - Ayllos", 'alterar('+pr_nrconven+', '+pr_flghomol+', "'+pr_cdopehom+'", '+pr_idretorn+', '+pr_flgativo+', "'+pr_lstemail+'");', "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
}

function alterar(pr_nrconven, pr_flghomol, pr_cdopehom, pr_idretorn, pr_flgativo, pr_lstemail){

	showMsgAguardo("Aguarde, efetuando a Altera&ccedil;&atilde;o do convenio ...");

	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/pagamento_titulo_arq/alterar_convenio.php",
		data: {
			nrdconta: nrdconta,
			nrconven: pr_nrconven,
			flghomol: pr_flghomol,
			cdopehom: pr_cdopehom,
			idretorn: pr_idretorn,
			flgativo: pr_flgativo,
			lstemail: pr_lstemail,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			try {
				hideMsgAguardo();
				msg = 'Altera&ccedil;&atilde;o do convenio efetuado com sucesso!';
				showError("inform", msg, "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));acessaOpcaoAba();");
				eval(response);
			} catch (error) {
				hideMsgAguardo();
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
    });
	
}

// Confirma inclusao de convenio
function confirmaInclusao(pr_nrconven, pr_flghomol, pr_cdopehom, pr_idretorn, pr_flgativo, pr_lstemail) {	
    showConfirmacao('078 - Confirma Ades&atilde;o ao servi&ccedil;o? (S/N)', "Confirma&ccedil;&atilde;o - Ayllos", 'incluir('+pr_nrconven+', '+pr_flghomol+', "'+pr_cdopehom+'", '+pr_idretorn+', '+pr_flgativo+', "'+pr_lstemail+'");', "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
}

function incluir(pr_nrconven, pr_flghomol, pr_cdopehom, pr_idretorn, pr_flgativo, pr_lstemail){
	
	showMsgAguardo("Aguarde, efetuando a Ades&atilde;o do Servi&ccedil;o ...");

	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/pagamento_titulo_arq/incluir_convenio.php",
		data: {
			nrdconta: normalizaNumero( nrdconta ),
			nrconven: pr_nrconven,
			flghomol: pr_flghomol,
			cdopehom: pr_cdopehom,
			idretorn: pr_idretorn,
			flgativo: pr_flgativo,
			lstemail: pr_lstemail,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			try {
				hideMsgAguardo();
				msg = 'Ades&atilde;o do Servi&ccedil;o efetuado com sucesso! <br/>Favor imprimir o Termo de Ades&atilde;o para o cooperado.';
				showError("inform", msg, "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));acessaOpcaoAba();");
				eval(response);
			} catch (error) {
				hideMsgAguardo();
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
    });
	
}


function VerifConvenioAceiteCancel(tpdtermo) {

    var msg;

    // Quantdo Cancelar o Convenio
    if (tpdtermo == 0) {
        var nrconven = $("#nrconven", "#divConteudoOpcao").val();

        if (nrconven == "") {
            showError("error", "Selecione algum conv&ecirc;nio para excluir.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            return false;
        }
    } else {
        var nrconven = 1;
    }

    // Mostra mensagem de aguardo
    if (tpdtermo == 0) {
        showMsgAguardo("Aguarde, cancelando o Servi&ccedil;o ...");
    } else {
        showMsgAguardo("Aguarde, efetuando a Ades&atilde;o do Servi&ccedil;o ...");
    }

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/pagamento_titulo_arq/verifica_conven_aceit_cancel.php",
        data: {
            nrdconta: nrdconta,
            nrconven: nrconven,
            tpdtermo: tpdtermo,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                if (tpdtermo == 0) {
                    msg = 'Cancelamento do Servi&ccedil;o efetuado com sucesso! <br/> Favor imprimir o Termo de Cancelamento para o cooperado.';
                } else {
                    msg = 'Ades&atilde;o do Servi&ccedil;o efetuado com sucesso! <br/>Favor imprimir o Termo de Ades&atilde;o para o cooperado.';
                }
                showError("inform", msg, "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));acessaOpcaoAba();");

                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}


function buscaTermoServico(tpdtermo) {

    var msg;
    var nrconven = 1;

    // Mostra mensagem de aguardo
    if (tpdtermo == 0) {
        showMsgAguardo("Aguarde, buscando Termo de Cancelando do Servi&ccedil;o ...");
    } else {
        showMsgAguardo("Aguarde, buscando Termo de Ades&atilde;o do Servi&ccedil;o ...");
    }

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/pagamento_titulo_arq/relatorio.php",
        data: {
            nrdconta: nrdconta,
            nrconven: nrconven,
            tpdtermo: tpdtermo,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                ImpressaoTermoServico(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}


function ImpressaoTermoServico(resposta) {

    showMsgAguardo("Aguarde, abrindo termo ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/pagamento_titulo_arq/impressao.php",
        data: {
            resposta: resposta,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                $("#divRotina").html(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}


function impressaoConteudo() {

    var conteudo = document.getElementById('divTermo').innerHTML,
    tela_impressao = window.open('about:blank');

    tela_impressao.document.write(conteudo);
    tela_impressao.document.close(); // <-- Esse close é uma particularidade do IE
    tela_impressao.window.focus();   // <-- Esse focus é uma particularidade do IE
    tela_impressao.window.print();
    tela_impressao.window.close();
}


/* Formata a tabela gerada dentro do fonte principal.php */
function controlaLayout(nomeForm, cddopcao) {

    if (nomeForm == 'divResultado') {

        var divRegistro = $('div.divRegistros', '#' + nomeForm);
        var tabela = $('table', divRegistro);

        tabela.zebraTabela(0);

        $('#' + nomeForm).css('width', '800px');
        divRegistro.css('height', '85px');

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        arrayLargura[0] = '100px'; //convenio
        arrayLargura[1] = '100px'; //adesao
        arrayLargura[2] = '100px'; //situacao
        arrayLargura[3] = '20x';  //homologado
        arrayLargura[4] = '100px'; //homologaçao
        arrayLargura[5] = '150px'; //Forma envio

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'right';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'left';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'center';
		arrayAlinha[5] = 'center';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

        $('tbody > tr', tabela).each(function () {
            if ($(this).hasClass('corSelecao')) {
                $(this).focus();
            }
        });
		
        var complemento = $('ul.complemento');

		$('li:eq(0)', complemento).addClass('txtNormalBold');
        $('li:eq(1)', complemento).addClass('txtNormal').css({ 'width': '35%' });
		$('li:eq(2)', complemento).addClass('txtNormalBold');
        $('li:eq(3)', complemento).addClass('txtNormal').css({ 'width': '40%' });


        ajustarCentralizacao();

    }else{
	
		if (nomeForm == 'frmConsulta') {

			$('#' + nomeForm).addClass('formulario');

			var Lnrconven = $('label[for="nrconven"]', '#' + nomeForm);
			var Ldtdadesa = $('label[for="dtdadesa"]', '#' + nomeForm);
			var Lflgativo = $('label[for="flgativo"]', '#' + nomeForm);
			var Lflghomol = $('label[for="flghomol"]', '#' + nomeForm);
			var Ldtdhomol = $('label[for="dtdhomol"]', '#' + nomeForm);
			var Lcdopehom = $('label[for="cdopehom"]', '#' + nomeForm);
			var Lidretorn = $('label[for="idretorn"]', '#' + nomeForm);
			var Ldtaltera = $('label[for="dtaltera"]', '#' + nomeForm);
			var Lcdoperad = $('label[for="cdoperad"]', '#' + nomeForm);
			var Lnrremret = $('label[for="nrremret"]', '#' + nomeForm);

			var Cnrconven = $('#nrconven', '#' + nomeForm);
			var Cdtdadesa = $('#dtdadesa', '#' + nomeForm);
			var Cflgativo = $('#flgativo', '#' + nomeForm);
			var Cflghomol = $('#flghomol', '#' + nomeForm);
			var Cdtdhomol = $('#dtdhomol', '#' + nomeForm);
			var Ccdopehom = $('#cdopehom', '#' + nomeForm);
			var Cidretorn = $('#idretorn', '#' + nomeForm);
			var Cdtaltera = $('#dtaltera', '#' + nomeForm);
			var Ccdoperad = $('#cdoperad', '#' + nomeForm);
			var Cnrremret = $('#nrremret', '#' + nomeForm);
			
			Ldsemailsel = $('label[for="dsemailsel"]', '#' + nomeForm);
			Cdsemailsel = $('#dsemailsel','#' + nomeForm);
			Cdsemailadd = $('#dsemailadd','#' + nomeForm);
			
			var btAdicionar = $('#btAdicionar','#' + nomeForm);
        	var btRemover = $('#btRemover','#' + nomeForm);
			
			Cdsemailsel.addClass('campo').css({'width':'800px','height':'100px'});
			Cdsemailadd.addClass('campo').css({'width':'800px','height':'100px'});
			
			Lnrconven.addClass('rotulo').css('width', '310px');
			Ldtdadesa.addClass('rotulo').css('width', '310px');
			Lflgativo.addClass('rotulo').css('width', '310px');
			Lflghomol.addClass('rotulo').css('width', '310px');
			Ldtdhomol.addClass('rotulo').css('width', '310px');
			Lcdopehom.addClass('rotulo').css('width', '310px');
			Lidretorn.addClass('rotulo').css('width', '310px');
			Ldtaltera.addClass('rotulo').css('width', '310px');
			Lcdoperad.addClass('rotulo').css('width', '310px');
			Lnrremret.addClass('rotulo').css('width', '310px');

			Cnrconven.css({ 'width': '70px' });
			Cdtdadesa.css({ 'width': '130px' })
			Cflgativo.css({ 'width': '130px' });
			Cflghomol.css({ 'width': '130px' });
			Cdtdhomol.css({ 'width': '130px' });
			Ccdopehom.css({ 'width': '200px' });
			Cidretorn.css({ 'width': '130px' });
			Cdtaltera.css({ 'width': '130px' });
			Ccdoperad.css({ 'width': '200px' });
			Cnrremret.css({ 'width': '130px' });
			
			Cdsemailsel.val("1");
			Cdsemailadd.val("1");
		
			Cidretorn.unbind('change').bind('change',function(){
				if(Cidretorn.val() == 1){
					$('#divemails','#' + nomeForm).css('display','block');
				}else{
					$('#divemails','#' + nomeForm).css('display','none');					
				}
			});
			
			Cidretorn.change();		
			
			
			//Tratamentos para inclusao
			if(cddopcao == 'I'){
				Cflgativo.habilitaCampo();
				Cflghomol.habilitaCampo();
				
				Ldtdhomol.css('display','none');
				Cdtdhomol.css('display','none');
				
				Cidretorn.habilitaCampo();
				
				Ldtaltera.css('display','none');
				Cdtaltera.css('display','none');
				
				Lcdoperad.css('display','none');
				Ccdoperad.css('display','none');
				
				Lnrremret.css('display','none');
				Cnrremret.css('display','none');				
			}
			
			//Tratamentos para alteracao
			if(cddopcao == 'A'){
				Cflgativo.habilitaCampo();
				Cflghomol.habilitaCampo();
				
				Ldtdhomol.css('display','none');
				Cdtdhomol.css('display','none');
				
				Cidretorn.habilitaCampo();
				
				Ldtaltera.css('display','none');
				Cdtaltera.css('display','none');
				
				Lcdoperad.css('display','none');
				Ccdoperad.css('display','none');
				
				Lnrremret.css('display','none');
				Cnrremret.css('display','none');				
			}	

			if(cddopcao == 'C'){
				Ldsemailsel.css('display','none');
				Cdsemailsel.css('display','none');
				$("#divmatemail").css('display','none');
				Cdsemailadd.desabilitaCampo();
			}
			

		}else{
			if (nomeForm == 'frmLog') {
				var divRegistro = $('div.divRegistros','#'+nomeForm);
				var tabela = $('table', divRegistro);

				tabela.zebraTabela(0);

				$('#' + nomeForm).css('width', '800px');
				divRegistro.css('height', '100px');

				var ordemInicial = new Array();

				var arrayLargura = new Array();
				arrayLargura[0] = '110px'; //data|hora
				arrayLargura[1] = '90px';  //manipulacao
				arrayLargura[2] = '160px'; //campo
				arrayLargura[3] = '182px'; //conteudo anterior
				arrayLargura[4] = '183px'; //conteudo atual

				var arrayAlinha = new Array();
				arrayAlinha[0] = 'center';
				arrayAlinha[1] = 'center';				
				arrayAlinha[3] = 'center';
				arrayAlinha[4] = 'center';

				tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

		        var complemento = $('ul.complemento');

				$('li:eq(0)', complemento).addClass('txtNormalBold');
				$('li:eq(1)', complemento).addClass('txtNormal').css({ 'width': '35%' });
				$('li:eq(2)', complemento).addClass('txtNormalBold');
				$('li:eq(3)', complemento).addClass('txtNormal').css({ 'width': '40%' });

				$('tbody > tr', tabela).each(function () {
					if ($(this).hasClass('corSelecao')) {
						$(this).focus();
					}
				});				
				
				$('#dtiniper','#frmLog').unbind('keypress').bind('keypress', function(e) {
					if ( e.keyCode == 13 ) {	
						carregaLog();
					}	
				});
				
				$('#dtfimper','#frmLog').unbind('keypress').bind('keypress', function(e) {
					if ( e.keyCode == 13 ) {	
						carregaLog();
					}	
				});
				
				
			}			
		}
			
	}

    callafterCobranca = '';
    layoutPadrao();
    return false;
}


// Destacar convenio selecinado e setar valores do item selecionado
function selecionaConvenio(idLinha, nrconven, dtcadast, cdoperad, flgativo, dsorigem, flghomol, dtdhomol, idretorn) {

    $("#nrconven", "#divConteudoOpcao").val(nrconven);
	$("#dtcadast", "#divConteudoOpcao").html(dtcadast);
    $("#cdoperad", "#divConteudoOpcao").html(cdoperad);
    $("#flgativo", "#divConteudoOpcao").val(flgativo);
    $("#dsorigem", "#divConteudoOpcao").val(dsorigem);
    $("#flghomol", "#divConteudoOpcao").val(flghomol);
    $("#dtdhomol", "#divConteudoOpcao").val(dtdhomol);
    $("#idretorn", "#divConteudoOpcao").val(idretorn);

}

// Destacar convenio selecinado e setar valores do item selecionado
function selecionaLog(cdoperad, nmtabela) {

    $("#cdoperad", "#divRegLogCeb").html(cdoperad);
	$("#nmtabela", "#divRegLogCeb").html(nmtabela);

}

function addEmailRetorno() {
	
	var dsdemail = $( "#dsemailsel option:selected" ).text();
	var cddemail = $( "#dsemailsel option:selected" ).val();
	
    if ( $('#dsemailadd option').filter(function(){return this.value==cddemail}).val() == undefined ){
		$('#dsemailadd').append('<option value=' + cddemail + '> ' + dsdemail + '</option>');
	}
}

function removeEmailRetorno() {
	
	var cddemail = $( "#dsemailadd option:selected" ).val();
	
    $('#dsemailadd option').filter(function(){return this.value==cddemail}).remove();
}


function consulta(cddopcao){
	
    // Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando ...");

    // Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
 	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/pagamento_titulo_arq/consulta.php",
		data: {			
            cddopcao: cddopcao,
			nrdconta: nrdconta,
			redirect: "script_ajax"
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
        success: function (response) {
			$("#divOpcaoConsulta").html(response);
            hideMsgAguardo();
            blockBackground($("#divRotina"));
		}
	});	
}

// Abrir tela de log ceb
function carregaLog(){
    
    var nrconven = $("#nrconven", "#divConteudoOpcao").val();    
    var dtiniper = $("#dtiniper", "#frmLog").val();    
	var dtfimper = $("#dtfimper", "#frmLog").val();   
	
	
    // Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando ...");

    // Carrega log atraves ajax 	
    $.ajax({
		
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/pagamento_titulo_arq/log.php",
		data: {
            nrdconta: nrdconta,
			dtiniper: dtiniper,
			dtfimper: dtfimper,
			redirect: "script_ajax"
		},
        error: function (objAjax, responseError, objExcept) {
			
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
        success: function (response) {
            
			$("#divLog").html(response);
            hideMsgAguardo();
            blockBackground($("#divRotina"));
			$("#dtiniper", "#frmLog").focus(); 
		}		
	});
        
}


