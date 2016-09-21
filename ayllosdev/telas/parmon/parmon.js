/*!
 * FONTE        : parmon.js
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 24/07/2013
 * OBJETIVO     : Biblioteca de funções da tela PARMON
 * --------------
 * ALTERAÇÕES   : 20/10/2014 - Novos campos. Chamado 198702 (Jonata-RKAM).
 *
 *                06/04/2016 - Adicionado campos de TED. (Jaison/Marcos - SUPERO)
 *
 *                24/05/2016 - Inclusão do novo parâmetro (flmntage) de monitoração de agendamento (Carlos)
 * -----------------------------------------------------------------------
 */
 
//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmparmon       = 'frmparmon';

//Labels/Campos do cabeçalho
var rCddopcao, rVlinimon, rVllmonip, rDsidpara, rSpanInfo, rTodos, rRadios;
var cCddopcao, cVlinimon, cVllmonip, cDsidpara, cTodos;

// array de cooperativas
var lstCooperativas = new Array();

// array de estados
var arrUF = ["AC","AL","AM","AP","BA","CE","DF","ES","GO","MA","MG","MS","MT","PA","PB","PE","PI","PR","RJ","RN","RO","RR","RS","SC","SE","SP","TO"];


$(document).ready(function() {
	estadoInicial();
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	
	fechaRotina( $('#divRotina') );
	hideMsgAguardo();		
	formataCabecalho();
	formataFrmparmon();
	controlaNavegacao();
	
	trocaBotao('Prosseguir');
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	highlightObjFocus( $('#'+frmCab) );
	highlightObjFocus( $('#'+frmparmon) );
	
	$('#'+frmCab).css({'display':'block'});
	$('#'+frmparmon).css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	
	cCddopcao.habilitaCampo();
	cTodos.habilitaCampo();
	removeOpacidade('divTela');
		
	$("#cddopcao","#"+frmCab).val("C").focus();
	
	return false;

}


function formataCabecalho() {

	// Cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);	
	rCddopcao.addClass('rotulo').css({'width':'60px'});
	cCddopcao			= $('#cddopcao','#'+frmCab);
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	cCddopcao.addClass('campo').css({'width':'450px'});
	layoutPadrao();
	return false;
}


function formataFrmparmon() {
	
	// Cabecalho
	rVlinimon = $('label[for="vlinimon"]','#'+frmparmon);
	rVllmonip = $('label[for="vllmonip"]','#'+frmparmon);
	rDsidpara = $('label[for="dsidpara"]','#'+frmparmon);
	rSpanInfo = $('#spanInfo','#'+frmparmon);
	rTodos    = $('label','#'+frmparmon);
	rRadios   = $('#insaqlim_sim,#insaqlim_nao,#inaleblq_sim,#inaleblq_nao,#flmstted_sim,#flmstted_nao,#flnvfted_sim,#flnvfted_nao,#flmobted_sim,#flmobted_nao,#flmntage_sim,#flmntage_nao','#'+frmparmon);
	
	rTodos.addClass('rotulo').css({'width':'50%'});
	rRadios.removeClass('rotulo').css({'width':'20px'});
	rSpanInfo.css({'margin-left':'120px','font-style':'italic','font-size':'10px','display':'inline','float':'left','top':'-20px'});
	rDsidpara.css({'text-align':'right','width':'50%'});
	
	cVlinimon = $('#vlinimon','#'+frmparmon);
	cVllmonip = $('#vllmonip','#'+frmparmon);
	cDsidpara = $('#dsidpara','#'+frmparmon);
	cTodos    = $(':text','#'+frmparmon);
	
	cTodos.addClass('campo').css({'width':'150px','text-align':'right'}).setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.,','');
	cDsidpara.css({'margin-left':'120px','width':'310px','height':'140px','border':'1px solid #777777','font-size':'11px','padding':'2px 4px 1px','display':'block'});
	
	layoutPadrao();

	return false;
}


// Formata
function controlaNavegacao() {

	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			liberaCampos();
			return false;
		}
	});	
		
	return false;	
	
}


function liberaCampos() {

	if ( $('#cddopcao','#'+frmCab).hasClass('campoTelaSemBorda')  ) { return false; } ;	
	
	$('#cddopcao','#'+frmCab).desabilitaCampo();
	$('#'+frmparmon).css({'display':'block'});
	$('#divBotoes').css({'display':'block'});
	formataFrmparmon();
	
	$('input, select', '#'+frmparmon).limpaFormulario().removeClass('campoErro');
	
	highlightObjFocus($('#'+frmparmon));
	
	manter_rotina();
	
	return false;

}


// Botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function btnContinuar() {
	
	var cddopcao = $("#cddopcao","#"+frmCab).val();
	var vlinimon = parseFloat($.trim($("#vlinimon","#"+frmparmon).val()).replace(/\./g,"").replace(",","."));
	var vllmonip = parseFloat($.trim($("#vllmonip","#"+frmparmon).val()).replace(/\./g,"").replace(",","."));
	
	if(isNaN(vlinimon)){
		showError("error","Valor inválido!","Alerta - Ayllos","$('#vlinimon','#"+frmparmon+"').focus();");
		return false;
	}else if (isNaN(vllmonip)){
		showError("error","Valor inválido!","Alerta - Ayllos","$('#vllmonip','#"+frmparmon+"').focus();");
		return false;
	}else{
		//Remove a classe de Erro do form
		$('input,select', '#'+frmparmon).removeClass('campoErro');
		if(cddopcao == "A"){
			manter_rotina('A1');
			return false;
		}
	}
}


function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	
	if (botao != '') {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >' + botao + '</a>');
	}

	return false;
}

function manter_rotina(rotina){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando ...");
	
	var cddopcao = $('#cddopcao','#'+frmCab).val();
	var vlinimon = $('#vlinimon','#'+frmparmon).val();
	var vllmonip = $('#vllmonip','#'+frmparmon).val();
	var vlinisaq = $('#vlinisaq','#'+frmparmon).val();
	var vlinitrf = $('#vlinitrf','#'+frmparmon).val();
	var vlsaqind = $('#vlsaqind','#'+frmparmon).val();
    var vlmnlmtd = $('#vlmnlmtd','#'+frmparmon).val();
    var vlinited = $('#vlinited','#'+frmparmon).val();
    var dsestted = $('#dsestted','#'+frmparmon).val();
	var insaqlim = $('#insaqlim_1','#'+frmparmon).is(":checked") ? 1 : 0;
	var inaleblq = $('#inaleblq_1','#'+frmparmon).is(":checked") ? 1 : 0;
    var flmstted = $('#flmstted_1','#'+frmparmon).is(":checked") ? 1 : 0;
	var flnvfted = $('#flnvfted_1','#'+frmparmon).is(":checked") ? 1 : 0;
	var flmobted = $('#flmobted_1','#'+frmparmon).is(":checked") ? 1 : 0;
	var flmntage = $('#flmntage_1','#'+frmparmon).is(":checked") ? 1 : 0;
	var cdcoptel = '';
	
	if(rotina != undefined){
		cddopcao = rotina;
		if(cddopcao == 'C1' || cddopcao == 'A1'){
			if($('#divCoptel','#frmparmon').css('display') != 'none'){
				cdcoptel = $('#dsidpara','#frmparmon').val();
			}
		}
	}
	
	vlinimon = normalizaNumero(vlinimon);
	
	window.focus();
	
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/parmon/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			vlinimon: vlinimon,
			vllmonip: vllmonip,
			vlinisaq: vlinisaq,
			vlinitrf: vlinitrf,
			vlsaqind: vlsaqind,
			insaqlim: insaqlim,
			inaleblq: inaleblq,
            vlmnlmtd: vlmnlmtd,
            vlinited: vlinited,
            flmstted: flmstted,
            flnvfted: flnvfted,
            flmobted: flmobted,
            dsestted: dsestted,
			cdcoptel: cdcoptel,
			flmntage: flmntage,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
}

function ver_rotina(){
	var cddopcao = $("#cddopcao","#frmCab").val();
	if(cddopcao == "C"){
		manter_rotina("C1");
	}
	return false;
}

//funcao para carregar cooperativas em combobox
function carregaCooperativas(qtdCooperativas) {
	for (var i = 0; i < qtdCooperativas; i++) {
		$('option','#dsidpara').remove();
		
	}
	for (var i = 0; i < qtdCooperativas; i++) {
		if(i == 0 && $('#cddopcao','#frmCab').val() == "A"){
			cDsidpara.append("<option id='coop0' value='0'>Todas Cooperativas</option>");
		}
		cDsidpara.append("<option id='coop"+lstCooperativas[i].cdcooper+"' value='"+lstCooperativas[i].cdcooper+"'>"+lstCooperativas[i].nmrescop+"</option>");
	}
		
	hideMsgAguardo();
}

function carregaEstados() {
    var cddopcao = $("#cddopcao","#frmCab").val();
    var dsestted = $('#dsestted','#frmparmon').val();
    var linDsestted = '';
    var index;

    // Oculta linha com opcoes de adicao
    $('#linAddUF').hide();

    if (cddopcao == 'A') {
        var opcao = '';
        for	(index = 0; index < arrUF.length; index++) {
            if (dsestted.indexOf(arrUF[index]) == -1) {
                opcao += '<option value="' + arrUF[index] + '">' + arrUF[index] + '</option>';
            }
        }
        // Monta o list menu
        $('#nmuf').empty().append(opcao);
        // Exibe linha com opcoes de adicao
        $('#linAddUF').show();
    }
    
    if (dsestted == '') {
        linDsestted += '<tr>';
        linDsestted += '    <td>Todas</td>';
        linDsestted += '    <td>&nbsp;</td>';
        linDsestted += '</tr>';
    } else {        
        var dsDispImage = (cddopcao == 'A' ? 'block' : 'none');
        var arrDsestted = dsestted.split(';');
        arrDsestted.sort(); // Ordena
        for	(index = 0; index < arrDsestted.length; index++) {
            linDsestted += '<tr>';
            linDsestted += '    <td>' + arrDsestted[index] + '</td>';
            linDsestted += '    <td><img onclick="confirmaExclusao(\'' + arrDsestted[index] + '\');" style="display:' + dsDispImage + ';cursor:hand;" src="../../imagens/geral/panel-error_16x16.gif" width="13" height="13" /></td>';
            linDsestted += '</tr>';
        }
    }
    // Monta as linhas da tabela
    $('#listUF').empty().append(linDsestted);
}

function confirmaExclusao(nmuf) {
    showConfirmacao("Deseja excluir '" + nmuf + "' da lista?", 'Confirma&ccedil;&atilde;o - Ayllos', "removerEstado('" + nmuf + "')", '', 'sim.gif', 'nao.gif');
}

function removerEstado(nmuf) {
    var dsestted = $('#dsestted','#frmparmon').val();
    var arrDsestted = dsestted.split(';');
    var opcao = '';
    var index;

    for	(index = 0; index < arrDsestted.length; index++) {
        if (nmuf.indexOf(arrDsestted[index]) == -1) {
            opcao += (opcao == '' ? '' : ';') + arrDsestted[index];
        }
    }

    // Seta as opcoes sem o estado excluido
    $('#dsestted','#frmparmon').val(opcao);

    // Monta os estados
    carregaEstados();
}

function incluirEstado() {
    var nmuf = $('#nmuf','#frmparmon').val();
    var dsestted = $('#dsestted','#frmparmon').val();
    dsestted += (dsestted == '' ? '' : ';') + nmuf;

    if (nmuf != null) {
        // Seta as opcoes com o estado incluido
        $('#dsestted','#frmparmon').val(dsestted);
        // Monta os estados
        carregaEstados();
    }
}
