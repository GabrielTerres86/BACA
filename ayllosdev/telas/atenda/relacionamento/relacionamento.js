	/************************************************************************
	 Fonte: relacionamento.js                                             
	 Autor: Guilherme                                                 
	 Data : Setembro/2009                    Última Alteração: 16/02/2017

	 Objetivo  : Biblioteca de funções da rotina de relacionamento

	 Alterações: 25/10/2010 - Ajuste para validação de permissão (David).
	 
				 09/02/2011 - Incluir impressao do historico (Gabriel).

				 14/07/2011 - Alterado para layout padrão (Rogerius - DB1). 
					
				 28/06/2012 - ALterado esquema para impressao em imprimeHistCooperado() e gerarImpressao() (Jorge).
				 
				 12/08/2013 - Alteração da sigla PAC para PA (Carlos).
				 
				 01/12/2015 - Correção de bug de layout na tag <UL><LI> no IE (Dionathan)
	
				 09/12/2015 - Ajustado posicionamento do form frmEventosEmAndamentoBusca (Lucas Ranghetti #369433)
                 
				 28/06/2016 - Ajustado msgConfirmaStatus. PRJ229 - Melhorias OQS (Odirlei-AMcom)
             
				 01/08/2016 - Adicionado função controlaFoco.(Evandro - RKAM).

				 16/02/2017 - Alterei a rotina selecionaEventoAndamento para validar a exibicao da table.(SD 605275 Carlos Tanholi)

				 18/12/2018 - Alterações contingência Projeto 418  (Bruno - Mouts)
						
				 05/07/2019 - Destacar evento do cooperado - P484.2 - Gabriel Marcos (Mouts).
				 
	************************************************************************/

var callafterRelacionamento = '';
var idLinhaEA = 0;
var idLinhaSI = 0;
var idevento = 0;
var cdevento = 0;
var dsobserv = "";
var rowidedp = "";
var rowidadp = "";
var rowididp = "";
var nmevento = "";
var dsrestri = "";
var cdgraupr = new Array(); // grau de parentesco quando selecionado opcao outra pessoa na pre inscricao
var idseqttl = 1;           // Titular que estara fazendo a preinscricao
var titular = new Array(); // Array que guardara os dados de cada titular que esta fazendo a inscricao
var nrcpfcgc = ""; //pre-inscricao

	
// Função para carregar dados da opção principal
function acessaOpcaoPrincipal() {

	//pre-inscricao
	nrcpfcgc = $('#nrcpfcgc','#frmCabAtenda').val();
	nrcpfcgc = nrcpfcgc.replace(/\./g,'').replace(/-/g,'');

    $("#divConteudoOpcao").css("display", "block");
    $("#divRelacionamentoPrincipal").css("display", "none");
    $("#divRelacionamentoQuestionario").css("display", "none");
    $("#divOpcoesDaOpcao1").css("display", "none");
    $("#divOpcoesDaOpcao2").css("display", "none");
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados de Relacionamento ...");	
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/relacionamento/principal.php",
		data: {
			nrdconta: nrdconta,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			try {
				eval(response);
				formataPrincipal();
                controlaFoco();
            } catch (error) {
				hideMsgAguardo();					
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	}); 	
}

//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoOpcao').each(function () {
        $(this).find("#frmRelacionamento #ulRelacionamento li > :input[type=image]").addClass("FluxoNavega");
        $(this).find("#frmRelacionamento #ulRelacionamento li > :input[type=image]").first().addClass("FirstInputModal").focus();
        $(this).find("#frmRelacionamento #ulRelacionamento li > :input[type=image]").last().addClass("LastInputModal");
    });

    //Se estiver com foco na classe FluxoNavega
    $(".FluxoNavega").focus(function () {
        $(this).bind('keydown', function (e) {
            if (e.keyCode == 13) {
                $(this).click();
            }
        });
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

// Função para mostrar a opção questionario
function mostraQuestionario() {
	// Configura visualização dos divs
    $("#divRelacionamentoQuestionario").css("display", "block");
    $("#divRelacionamentoPrincipal").css("display", "none");
    $("#dtinique", "#frmRelacionamentoQuestionario").val($("#dtinique", "#frmRelacionamento").val());
    $("#dtfimque", "#frmRelacionamentoQuestionario").val($("#dtfimque", "#frmRelacionamento").val());
	// Format para a alteração das datas de questionário
    $("#dtinique", "#frmRelacionamentoQuestionario").setMask("DATE", "", "");
    $("#dtfimque", "#frmRelacionamentoQuestionario").setMask("DATE", "", "");
    $("#dtinique", "#frmRelacionamentoQuestionario").focus();
}

// Função para mostrar a opção Histórico de participação
function mostraHistParticipacao() {
    if ($("#qthistor", "#frmRelacionamento").val() == 0) {
        showError("error", "N&atilde;o foi encontrado nenhum hist&oacute;rico de participa&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando hist&oacute;rico de participa&ccedil;&atilde;o ...");	

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/relacionamento/historico_de_participacao.php",
		data: {
			redirect: "html_ajax" // Tipo de retorno do ajax
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divOpcoesDaOpcao1").html(response);
			formataPesquisaParticipacao();
		}				
	});	
}

// Função para alterar as datas de entrega do questionário
function alterarDatasQuestionario() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, alterando datas do question&aacute;rio ...");	
	
    var dtinique = $("#dtinique", "#frmRelacionamentoQuestionario").val();
    var dtfimque = $("#dtfimque", "#frmRelacionamentoQuestionario").val();
	
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/relacionamento/questionario_alterar.php",
		data: {
			nrdconta: nrdconta,
			dtinique: dtinique,
			dtfimque: dtfimque,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			try {
				eval(response);
            } catch (error) {
				hideMsgAguardo();					
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	}); 	
}

// Montar o select(combobox) de acordo com os dados pesquisados
function buscaEventosPeriodo() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando eventos do per&iacute;odo ...");	

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/relacionamento/historico_de_participacao_evento.php",
		data: {
			nrdconta: nrdconta,
            inianoev: $('#inianoev', '#frmHistParticipacao').val(),
            finanoev: $('#finanoev', '#frmHistParticipacao').val(),
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			try {
				eval(response);
            } catch (error) {
				hideMsgAguardo();					
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});
}


function confirmaEventosHistCooperado() {

    showConfirmacao('Deseja visualizar o historico em PDF ?', 'Confirma&ccedil;&atilde;o - Aimaro', 'imprimeHistCooperado() ', 'buscaEventosHistCooperado() ', 'sim.gif', 'nao.gif');

}

// Gerar o PDF com o Historico 
function imprimeHistCooperado() {

    var inianoev = $("#inianoev", "#frmHistParticipacao").val();
    var finanoev = $("#finanoev", "#frmHistParticipacao").val();
	
	// Pega o objeto select
	var objSelectEventos = document.frmHistParticipacao.dsevento;
	// pega o value do evento selecionada
	var valueEvento = objSelectEventos.options[objSelectEventos.options.selectedIndex].value;
	
	blockBackground(parseInt($("#divRotina").css("z-index")));
	
    $("#nrdconta", "#frmHistParticipacao").val(nrdconta);
    $("#inipesqu", "#frmHistParticipacao").val(inianoev);
    $("#finpesqu", "#frmHistParticipacao").val(finanoev);
    $("#idevento", "#frmHistParticipacao").val(valueEvento.slice(0, valueEvento.search(",")));
    $("#cdevento", "#frmHistParticipacao").val(valueEvento.slice(valueEvento.search(",") + 1));
	
	var action = $("#frmHistParticipacao").attr("action");
	var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";
	
    carregaImpressaoAyllos("frmHistParticipacao", action, callafter);
	
}

// Buscar eventos participados pelo cooperado no período informado de um ou mais eventos
function buscaEventosHistCooperado() {

	// Pega o objeto select
	var objSelectEventos = document.frmHistParticipacao.dsevento;
	// pega o value do evento selecionada
	var valueEvento = objSelectEventos.options[objSelectEventos.options.selectedIndex].value;
	// pega o identificador do evento
    idevento = valueEvento.slice(0, valueEvento.search(","));
	// pega o código do evento
	cdevento = valueEvento.slice(valueEvento.search(",") + 1);

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando eventos do hist&oacute;rico do cooperado ...");	

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/relacionamento/historico_de_participacao_eventos_cooperado.php",
		data: {
			nrdconta: nrdconta,
            inianoev: $('#inianoev', '#frmHistParticipacao').val(),
            finanoev: $('#finanoev', '#frmHistParticipacao').val(),
			idevento: idevento,
			cdevento: cdevento,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divOpcoesDaOpcao2").html(response);		
		}				
	});
}

// Mostra os eventos em andamento de acordo com o parametro
function mostraEventosEmAndamento(dsobs) {

	// Mostra mensagem de aguardo
    if (dsobs == "P") {
        if ($("#qtpenden", "#frmRelacionamento").val() == 0) {
            showError("error", "N&atilde;o foi encontrada nenhuma pr&eacute;-inscri&ccedil;&atilde;o pendente.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
        } else {
			showMsgAguardo("Aguarde, carregando eventos em andamento pendentes ...");
		}
	}
    else if (dsobs == "") {
        if ($("#qtandame", "#frmRelacionamento").val() == 0) {
            showError("error", "Nenhum evento est&aacute; em andamento neste PA.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
        } else {
			showMsgAguardo("Aguarde, carregando eventos em andamento ...");
		}
	}
    else if (dsobs == "C") {
        if ($("#qtconfir", "#frmRelacionamento").val() == 0) {
            showError("error", "N&atilde;o foi encontrada nenhuma inscri&ccedil;&atilde;o confirmada.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
        } else {
			showMsgAguardo("Aguarde, carregando eventos em andamento confirmados ...");
		}
	}

    callafterRelacionamento = '';

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/relacionamento/eventos_em_andamento_busca.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrcpfcgc: nrcpfcgc,
			dsobserv: dsobs,
			redirect: "html_ajax"
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divOpcoesDaOpcao1").html(response);
		}				
	});
	
}

// Mostra detalhes de um determinado evento
function mostraDetalhesEvento() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando detalhes do evento ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/relacionamento/eventos_em_andamento_detalhes.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			rowidedp: rowidedp,
			rowidadp: rowidadp,
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
		
}

// Mostra a opção situação da inscrição 
function mostraSituacaoDaInscricaoEvento() {

    if (dsobserv.search("H") >= 0 || dsobserv == "") {
        showError("error", "N&atilde;o existe pr&eacute;-inscri&ccedil;&atilde;o para este evento.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando detalhes do evento ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/relacionamento/eventos_em_andamento_situacao_da_inscricao.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			rowidedp: rowidedp,
			rowidadp: rowidadp,
			imptermo: imptermo,
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
		
}

// Mostra a opção pré-inscrição 
function mostraPreInscricao() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o pr&eacute;-inscri&ccedil;&atilde;o ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/relacionamento/eventos_em_andamento_pre_inscricao.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			rowidadp: rowidadp,
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
		
}

// Lista se tiver jah inscritos com esta conta no eventou (ou historico)
function listaInscritos(flgcoope, listaInscricoes) {

    if (listaInscricoes != "") {
        prosseguirPreInscricao(flgcoope, listaInscricoes);
	}
	else {
		verificaExclusivoCooperado(flgcoope);
	}
	
}

//
function prosseguirPreInscricao(flgcoope, listaInscricoes) {
	listaInscricoes = 'O cooperado ja possui inscricoes nesse evento sob sua responsabilidade:<br><br>' + 
					  '<table cellpadding="0" cellspacing="0" border="0">' +
					  '  <tr>' +
					  '    <td class="txtCarregando">PA</td>' +
					  '    <td width="10"></td>' +
					  '    <td class="txtCarregando">Data</td>' +
					  '    <td width="10"></td>' +
					  '    <td class="txtCarregando">Inscrito</td>' +
					  '  </tr>' +					  
					  listaInscricoes +
					  '</table>' +
					  '<br>Deseja prosseguir com a pre-inscricao?';
					  
    showConfirmacao(listaInscricoes, 'Confirma&ccedil;&atilde;o - Aimaro', 'verificaExclusivoCooperado("' + flgcoope + '")', 'blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
}

// Verifica se o evento é exclusivo a cooperados
function verificaExclusivoCooperado(flgcoope) {

	// Nao propria e evento exclusivo a cooperados 
    if ($("#tpinseve" + idseqttl, "#frmPreInscricao").val() != "yes" && flgcoope == "yes") {
			
        showConfirmacao('Evento exclusivo para cooperados. Confirma inscri&ccedil;&atilde;o de um n&atilde;o cooperado?', 'Confirma&ccedil;&atilde;o - Aimaro', 'criaPreInscricao () ', 'blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
		
	}
	else {
        criaPreInscricao();
	}
}

//
function criaPreInscricao() {
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando inclus&atilde;o da pr&eacute;-inscri&ccedil;&atilde;o ...");
		
	// Carrega conteúdo da opção através de ajax
			
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/relacionamento/inscricao_criar.php",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			rowidedp: rowidedp,
			rowidadp: rowidadp,
			imptermo: imptermo,
            tpinseve: $('#tpinseve' + idseqttl, '#frmPreInscricao').val(),
            cdgraupr: $('#cdgraupr' + idseqttl, '#frmPreInscricao').val(),
            dsdemail: $('#dsdemail' + idseqttl, '#frmPreInscricao').val(),
            dsobserv: $('#dsobserv' + idseqttl, '#frmPreInscricao').val(),
            flgdispe: $('#flgdispe' + idseqttl, '#frmPreInscricao').val(),
            nminseve: $('#nminseve' + idseqttl, '#frmPreInscricao').val(),
            nrdddins: $('#nrdddins' + idseqttl, '#frmPreInscricao').val(),
            nrtelefo: $('#nrtelefo' + idseqttl, '#frmPreInscricao').val(),
            nrcpfcgc: $('#nrcpfcgcRepresen', '#frmPreInscricao').val(),
			redirect: "html_ajax"
		},
        error: function (objAjax, responseError, objExcept) {
			
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			
		},
        success: function (response) {
							
			try {
				eval(response);
            } catch (error) {
				hideMsgAguardo();					
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}	
				
		}
		
	});	
		
}

// Mostra histórico de um determinado evento
function mostraHistoricoEvento() {

    if (dsobserv == "") {
        showError("error", "O evento selecionado n&atilde;o possui hist&oacute;rico.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando hist&oacute;rico do evento ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/relacionamento/historico_de_participacao_eventos_cooperado.php",
		data: {
			nrdconta: nrdconta,
			inianoev: 0,
			finanoev: 0,
			idevento: idevento,
			cdevento: cdevento,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divOpcoesDaOpcao2").html(response);
		}				
	});
		
}

//
function msgConfirmaStatus(opcaosit,imptermo) {	

    if (opcaosit == 4){
        msgconfir = 'Deseja excluir a inscri&ccedil;&atilde;o?';
    }else{
        msgconfir = 'Deseja alterar a situa&ccedil;&atilde;o?';
    }

	showConfirmacao(msgconfir,'Confirma&ccedil;&atilde;o - Aimaro','alteraStatusEventoSI(' + opcaosit + ',"' + imptermo + '")','blockBackground(parseInt($("#divRotina").css("z-index")))','sim.gif','nao.gif');
}

// Alterar o status de um determinado evento
function alteraStatusEventoSI(opcaosit, imptermo) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, alterando situa&ccedil;&atilde;o do evento ...");		
		 			
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/relacionamento/eventos_em_andamento_situacao_da_inscricao_alterar.php",
		data: {
			nrdconta: nrdconta,
			rowididp: rowididp,
			imptermo: imptermo,
			opcaosit: opcaosit,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			try {
				eval(response);
            } catch (error) {
				hideMsgAguardo();					
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
}

// Função para seleção do Evento em andamento
function selecionaEventoAndamento(idLinha, qtEAndamento, id, cd, edp, adp, obs, temTermo, nmEven, dsRest) {

	var cor = "";
	
	if ($("#divOpcoesDaOpcao1").css("display") == 'block') {

	// Formata cor da linha da tabela que lista os eventos em andamento
	for (var i = 1; i <= qtEAndamento; i++) {		
		if (cor == "#F4F3F0") {
			cor = "#FFFFFF";
		} else {
			cor = "#F4F3F0";
		}		
		
		// Formata cor da linha
        $("#trEvento" + i).css("background-color", cor);
		
		if (i == idLinha) {
			// Atribui cor de destaque para limite selecionado
            $("#trEvento" + idLinha).css("background-color", "#FFB9AB");
			// Armazena codigo e id do evento selecionado
			idevento = id;
			cdevento = cd;
			rowidedp = edp;
			rowidadp = adp;
			dsobserv = obs;
			nmevento = nmEven;
			dsrestri = dsRest;
			imptermo = temTermo;
            idLinhaEA = idLinha;
		}
	}
	} else {
	    return false;
	}
}

// Função para seleção do Evento em andamento
function selecionaEventoSituacaoInscricao(idLinhai, qtEventoSI, idp) {

	// Formata cor da linha da tabela que lista os eventos em andamento
	for (var i = 1; i <= qtEventoSI; i++) {		
		
		if (i == idLinhai) {
			// Atribui cor de destaque para limite selecionado
			rowididp = idp;
            idLinhaSI = idLinhai;
		}
	}
}

// Remover options de um select
function removerOptions(select) {
    $("#" + select + " option").each(function () {
		$(this).remove();
	});
}

// Adicionar option em um select
function adicionarOption(select, id, val, tex) {
    $("#" + select).append("<option id='" + id + "' value='" + val + "'>" + tex + "</option>");
}

// Função para gerar impressão em PDF
function gerarImpressao(idimpres, nrdrowid) {
	
    $("#nrdconta", "#frmImprimirRelacion").val(nrdconta);
    $("#rowidedp", "#frmImprimirRelacion").val(rowidedp);
    $("#idimpres", "#frmImprimirRelacion").val(idimpres);

    if (nrdrowid != "") {
        $("#rowididp", "#frmImprimirRelacion").val(nrdrowid);
	}
	else {
        $("#rowididp", "#frmImprimirRelacion").val(rowididp);
	}
	
	var action = $("#frmImprimirRelacion").attr("action");
	var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";
	
	if (callafterRelacionamento != '') {
		callafter = callafterRelacionamento;
		callafterRelacionamento = '';
	}
	
    carregaImpressaoAyllos("frmImprimirRelacion", action, callafter);
	
}

// Função que formata a pagina principal
function formataPrincipal() {
	
	// Principal
	var nomeForm1 = 'frmRelacionamento';
	var ul = $('#ulRelacionamento');
	
    ul.css({ 'margin-left': '80px' });
    $('li:eq(0)', ul).css({ 'float': 'left', 'width': '150px', 'text-align': 'right', 'margin-right': '7px' });
    $('li:eq(1)', ul).css({ 'text-align': 'left' });
    $('li:eq(2)', ul).css({ 'float': 'left', 'width': '150px', 'text-align': 'right', 'margin-right': '7px', 'clear': 'both' });
    $('li:eq(3)', ul).css({ 'text-align': 'left' });
    $('li:eq(4)', ul).css({ 'float': 'left', 'width': '150px', 'text-align': 'right', 'margin-right': '7px', 'clear': 'both' });
    $('li:eq(5)', ul).css({ 'text-align': 'left' });
    $('li:eq(6)', ul).css({ 'float': 'left', 'width': '150px', 'text-align': 'right', 'margin-right': '7px', 'clear': 'both' });
    $('li:eq(7)', ul).css({ 'text-align': 'left' });
    $('li:eq(8)', ul).css({ 'float': 'left', 'width': '150px', 'text-align': 'right', 'margin-right': '7px', 'clear': 'both' });
    $('li:eq(9)', ul).css({ 'text-align': 'left' });
    $('li:eq(10)', ul).css({ 'float': 'left', 'width': '150px', 'text-align': 'right', 'margin-right': '7px', 'clear': 'both' }); // Anderson

	// campos
    cQtandame = $('#qtandame', '#' + nomeForm1);
    cQthistor = $('#qthistor', '#' + nomeForm1);
    cQtpenden = $('#qtpenden', '#' + nomeForm1);
    cQtconfir = $('#qtconfir', '#' + nomeForm1);
    cDtinique = $('#dtinique', '#' + nomeForm1);
    cDtfimque = $('#dtfimque', '#' + nomeForm1);

    cQtandame.css({ 'width': '35px', 'text-align': 'right' });
    cQthistor.css({ 'width': '35px', 'text-align': 'right' });
    cQtpenden.css({ 'width': '35px', 'text-align': 'right' });
    cQtconfir.css({ 'width': '35px', 'text-align': 'right' });
    cDtinique.css({ 'width': '70px', 'text-align': 'center' });
    cDtfimque.css({ 'width': '70px', 'text-align': 'center' });
	
    $('input', '#' + nomeForm1).desabilitaCampo();
	
	// Questionario
	var nomeForm2 = 'frmRelacionamentoQuestionario';
	
    $('#divRelacionamentoQuestionario').css({ 'heigth': '120px' });
	
    rDtinique = $('label[for="dtinique"]', '#' + nomeForm2);
    rDtfimque = $('label[for="dtfimque"]', '#' + nomeForm2);
    rDtcadqst = $('label[for="dtcadqst"]', '#' + nomeForm2);

    rDtinique.addClass('rotulo').css({ 'width': '135px' });
    rDtfimque.addClass('rotulo').css({ 'width': '135px' });
    rDtcadqst.addClass('rotulo-linha').css({ 'width': '120px' });

    cDtinique = $('#dtinique', '#' + nomeForm2);
    cDtfimque = $('#dtfimque', '#' + nomeForm2);
    cDtcadqst = $('#dtcadqst', '#' + nomeForm2);

    cDtinique.addClass('campo').css({ 'width': '70px', 'text-align': 'center' });
    cDtfimque.addClass('campo').css({ 'width': '70px', 'text-align': 'center' });
    cDtcadqst.addClass('campoTelaSemBorda').css({ 'width': '70px', 'text-align': 'center' });

	layoutPadrao();
	return false;
}

// Função que formata pesquisa participacao
function formataPesquisaParticipacao() {
	
	var nomeForm = 'frmHistParticipacao';
	
    rInianoev = $('label[for="inianoev"]', '#' + nomeForm);
    rFinanoev = $('label[for="finanoev"]', '#' + nomeForm);
    rDsevento = $('label[for="dsevento"]', '#' + nomeForm);

    rInianoev.addClass('rotulo').css({ 'width': '120px' });
	rFinanoev.addClass('rotulo-linha');
    rDsevento.addClass('rotulo').css({ 'width': '63px' });
	
    cInianoev = $('#inianoev', '#' + nomeForm);
    cFinanoev = $('#finanoev', '#' + nomeForm);
    cDsevento = $('#dsevento', '#' + nomeForm);
	
    cInianoev.addClass('campo').css({ 'width': '40px', 'text-align': 'center' });
    cFinanoev.addClass('campo').css({ 'width': '40px', 'text-align': 'center' });
    cDsevento.addClass('campo').css({ 'width': '285px' });
	
	layoutPadrao();
	return false;
}

// Função que formata a tabela dos eventos em andamento
function formataEventosAndamentoBusca() {
			
    var divRegistro = $('div.divRegistros', '#frmEventosEmAndamentoBusca');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);
	
	//relacionamentos
    divRegistro.css({ 'height': '150px', 'width': '625px' });
	
	var ordemInicial = new Array();
	
	//relacionamentos
	var arrayLargura = new Array();
	arrayLargura[0] = '210px';
	arrayLargura[1] = '90px';
	arrayLargura[2] = '50px';
	arrayLargura[3] = '50px';
	arrayLargura[4] = '50px';
	arrayLargura[5] = '65px';
	arrayLargura[6] = '65px';
	arrayLargura[7] = '45px';
	
	// relacionamentos
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'center';
	arrayAlinha[6] = 'center';
	arrayAlinha[7] = 'left';
	
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
	ajustarCentralizacao();	
	return false;
}

// Função que formata a tabela dos eventos em andamento
function formataCargos() {
			
    var divRegistro = $('div.divRegistros', '#frmCargos');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);
	
    divRegistro.css({ 'height': '150px', 'width': '625px' });
	
	var ordemInicial = new Array();
	
	var arrayLargura = new Array();
	arrayLargura[0] = '225px';
	arrayLargura[1] = '200px';
	arrayLargura[2] = '100px';
	arrayLargura[3] = '100px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
	ajustarCentralizacao();
	return false;
}

// Função que formata o formulario eventos em andamento detalhe
function formataEventosEmAndamentoDetalhes() {

	var nomeForm = 'frmEventosEmAndamentoDetalhes';

    $('input, textarea', '#' + nomeForm).desabilitaCampo();
	
    rNmevento = $('label[for="nmevento"]', '#' + nomeForm);
    rDsperiod = $('label[for="dsperiod"]', '#' + nomeForm);
    rDshroeve = $('label[for="dshroeve"]', '#' + nomeForm);
    rDslocali = $('label[for="dslocali"]', '#' + nomeForm);
    rNmfornec = $('label[for="nmfornec"]', '#' + nomeForm);
    rNmfacili = $('label[for="nmfacili"]', '#' + nomeForm);
	
    rNmevento.addClass('rotulo').css({ 'width': '70px' });
    rDsperiod.addClass('rotulo').css({ 'width': '70px' });
    rDshroeve.addClass('rotulo').css({ 'width': '70px' });
    rDslocali.addClass('rotulo').css({ 'width': '70px' });
    rNmfornec.addClass('rotulo').css({ 'width': '70px' });
    rNmfacili.addClass('rotulo').css({ 'width': '70px' });
	
    cNmevento = $('#nmevento', '#' + nomeForm);
    cDsperiod = $('#dsperiod', '#' + nomeForm);
    cDshroeve = $('#dshroeve', '#' + nomeForm);
    cDslocali = $('#dslocali', '#' + nomeForm);
    cNmfornec = $('#nmfornec', '#' + nomeForm);
    cNmfacili = $('#nmfacili', '#' + nomeForm);
    cTxtDetalhes = $('#txtDetalhes', '#' + nomeForm);
	
    cNmevento.css({ 'width': '330px' });
    cDsperiod.css({ 'width': '150px' });
    cDshroeve.css({ 'width': '150px' });
    cDslocali.css({ 'width': '330px' });
    cNmfornec.css({ 'width': '330px' });
    cNmfacili.css({ 'width': '330px' });
    cTxtDetalhes.css({ 'background-color': '#F4F3F0', 'width': '400px', 'height': '150px' });
	
	return false;
}

// Função que formata o formulario da pré-inscricao
function formataPreInscricao() {

	var nomeForm = 'frmPreInscricao';

    rNmevento = $('label[for="nmevento"]', '#' + nomeForm);
    rDsrestri = $('label[for="dsrestri"]', '#' + nomeForm);
    rNmextttl = $('label[for="nmextttl"]', '#' + nomeForm);
    rTpinseve = $('label[for="tpinseve"]', '#' + nomeForm);
    rCdgraupr = $('label[for="cdgraupr"]', '#' + nomeForm);
    rNminseve = $('label[for="nminseve"]', '#' + nomeForm);
    rDsdemail = $('label[for="dsdemail"]', '#' + nomeForm);
    rNrdddins = $('label[for="nrdddins"]', '#' + nomeForm);
    rDsobserv = $('label[for="dsobserv"]', '#' + nomeForm);
    rFlgdispe = $('label[for="flgdispe"]', '#' + nomeForm);
    rRepresen = $('label[for="represen"]', '#' + nomeForm);

    rNmevento.addClass('rotulo').css({ 'width': '150px' });
    rDsrestri.addClass('rotulo').css({ 'width': '150px' });
    rNmextttl.addClass('rotulo').css({ 'width': '150px' });
    rTpinseve.addClass('rotulo').css({ 'width': '150px' });
    rCdgraupr.addClass('rotulo').css({ 'width': '150px' });
    rNminseve.addClass('rotulo').css({ 'width': '150px' });
    rDsdemail.addClass('rotulo').css({ 'width': '150px' });
    rNrdddins.addClass('rotulo').css({ 'width': '150px' });
    rDsobserv.addClass('rotulo').css({ 'width': '150px' });
    rFlgdispe.addClass('rotulo').css({ 'width': '150px' });
    rRepresen.addClass('rotulo').css({ 'width': '150px' });
	
		
}

//
function formataEventosdoHistorico() {

    var divRegistro = $('div.divRegistros', '#divEventosdoHistorico');
    var tabela = $('table', divRegistro);
			
    divRegistro.css({ 'height': '150px', 'width': '500px' });
	
	var ordemInicial = new Array();
	
	var arrayLargura = new Array();
	arrayLargura[0] = '245px';
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
	
	/********************
	 FORMATA COMPLEMENTO	
	*********************/
    var complemento = $('ul.complemento');
	
	$('li:eq(0)', complemento).addClass('txtNormalBold');
    $('li:eq(1)', complemento).addClass('txtNormal').css({ 'width': '30%' });
	$('li:eq(2)', complemento).addClass('txtNormalBold');
    $('li:eq(3)', complemento).addClass('txtNormal').css({ 'width': '25%' });
	$('li:eq(4)', complemento).addClass('txtNormalBold');
    $('li:eq(5)', complemento).addClass('txtNormal').css({ 'width': '18%' });
	

	/********************
	  EVENTO COMPLEMENTO	
	*********************/
	// seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function () {
		selecionaComplemento($(this));
	});	

	// seleciona o registro que é focado
    $('table > tbody > tr', divRegistro).focus(function () {
		selecionaComplemento($(this));
	});	
		
	return false;

}

//
function selecionaComplemento(tr) {

    $('#situacao', '.complemento').html($('#situacao', tr).val());
    $('#dtinicio', '.complemento').html($('#dtinicio', tr).val());
    $('#dtfim', '.complemento').html($('#dtfim', tr).val());

	return false;
}

//
function formataEventosdoSI() {

    var divRegistro = $('div.divRegistros', '#divEventosdoSI');
    var tabela = $('table', divRegistro);
			
    divRegistro.css({ 'height': '150px', 'width': '530px' });
	
	var ordemInicial = new Array();
	
	var arrayLargura = new Array();
	arrayLargura[0] = '200px';
	arrayLargura[1] = '55px';
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

	/********************
	 FORMATA COMPLEMENTO	
	*********************/
    var complemento = $('ul.complemento');
	
	$('li:eq(0)', complemento).addClass('txtNormalBold');
    $('li:eq(1)', complemento).addClass('txtNormal').css({ 'width': '30%' });
	$('li:eq(2)', complemento).addClass('txtNormalBold');
    $('li:eq(3)', complemento).addClass('txtNormal').css({ 'width': '25%' });
	$('li:eq(4)', complemento).addClass('txtNormalBold');
    $('li:eq(5)', complemento).addClass('txtNormal').css({ 'width': '16%' });

	return false;
}


/**
 * Autor: Bruno Luiz Katzjarowski - Mout's;
 * Data: 12/12/2018
 */
function validaGrupo(){
	var linha = $('.corSelecao','#frmEventosEmAndamentoBusca');

	var nmdgrupo = $(linha).data('nmdgrupo');
	var idevento = $(linha).data('idevento');

	if(nmdgrupo != ""){

		var data = {
			nrdconta: nrdconta,
			nmdgrupo: nmdgrupo,
			idevento: idevento,
			nrcpfcgc: nrcpfcgc,
			redirect: "script_ajax" // Tipo de retorno do ajax
		}
		
		$.ajax({		
			type: "POST", 
			url: UrlSite + "telas/atenda/relacionamento/consulta_pre_inscricao.php",
			data: data,
			dataType: 'json',
			error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function (response) {
				if(response.erro != ""){
					showError("error", response.erro, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
				}else{
					if(nmdgrupo != response.retorno.nmdgrupo){
						showConfirmacao('Grupo do evento ('+nmdgrupo+') difere do grupo do cooperado ('+response.retorno.nmdgrupo+'), deseja efetuar a pr&eacute;-inscri&ccedil;&atilde;o assim mesmo?',
										'Confirma&ccedil;&atilde;o - Aimaro',
										'mostraPreInscricao()',
										'',
										'sim.gif',
										'nao.gif');
					}else{
						mostraPreInscricao();
					}
				}
			}				
		}); 	
	}else{
		mostraPreInscricao();
	}
}

function mostraCargos() {

	var nrdconta = normalizaNumero($('#nrdconta','#frmCabAtenda').val()); 
	
    showMsgAguardo('Aguarde, buscando cargos...');

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/atenda/relacionamento/busca_cargos.php',
		data: {
			nrdconta: nrdconta
		},		
		error: function(objAjax,responseError,objExcept) {

			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","estadoInicial();");							
			console.log(response);
		
		},

		success: function(response) {

			hideMsgAguardo();

			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divOpcoesDaOpcao1').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
				}
			}
		}				
	});
} 