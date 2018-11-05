//*********************************************************************************************//
//*** Fonte: mancar.js                                                 						***//
//*** Autor: Andr� Clemer                                            						***//
//*** Data : Abril/2018                  �ltima Altera��o: --/--/----  					    ***//
//***                                                                  						***//
//*** Objetivo  : Biblioteca de fun��es da tela MANCAR                 						***//
//***                                                                  						***//	 
//*** Altera��es:                                                                           ***//	  
//***                           									                        ***//
//*********************************************************************************************//

var cCddopcao;
var cCdcooper;
var frmCab = 'frmCab';
var frmManCar = 'frmManCar';
var cTodos;
var cddopcao = 'C';
var cTodosCabecalho;
var cTodosFiltro;

$(document).ready(function() {

    estadoInicial();

    highlightObjFocus($('#frmCab'));

    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});

    $(document).keyup(function(e){
        if (e.keyCode == 38 || e.keyCode == 40) { // 38:Seta para cima --- 40:Seta para baixo
            selecionaCartorio('');
            return false;
        }
    });

});

function estadoInicial() {
    $('#divTela').fadeTo(0, 0.1);
    $('#frmCab').css({'display': 'block'});
    $('#divMsgAjuda').css('display', 'none');
    $('#frmManCar').css('display', 'none');
    $('#divBotao').css('display', 'none');
    $('#divFiltro').css('display', 'none');
    $('#divFormulario').html('');

    formataCabecalho();

    cTodosCabecalho.habilitaCampo();
    

    removeOpacidade('divTela');
    unblockBackground();
    hideMsgAguardo();

    $("#cddopcao", "#frmCab").val('C').focus();
}

function formataCabecalho() {

    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);

    var cddopcao = $("#cddopcao", "#frmCab").val();

    var rCddopcao = $('label[for="cddopcao"]', '#frmCab');
    var rCdcooper = $('label[for="cdcooper"]', '#frmCab');

    rCddopcao.css('width', '50px').addClass('rotulo');
    rCdcooper.css('width', '80px').addClass('rotulo-linha');

    cCddopcao = $('#cddopcao', '#frmCab');
    cCddopcao.css('width', '330px');

    cCdcooper = $('#cdcooper', '#frmCab');

    cCddopcao.css('width', '565px');

    cCddopcao.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 13 || e.keyCode == 9 || e.KeyCode == 18) {
            cCdcooper.focus();
            return false;
        }
    });

    cCddopcao.unbind('changed').bind('changed', function(e) {
        cCdcooper.focus();
        return false;
    });
}


function btnOK() {
    var cddopcao = $("#cddopcao", "#frmCab").val();

    cTodosCabecalho.desabilitaCampo();
    if (cddopcao == 'I') {
        formataFormulario(cddopcao);
    } else {
        $('#divFiltro').css('display', 'block');
        formataFormulario(cddopcao);
        formataFiltro();
    }
}

function formataFiltro() {    
    cTodosFiltro = $('input[type="text"],input[type="checkbox"],select', '#divFiltro');
    $('#divFiltro').css({ 'border': '1px solid #777', 'padding': '10px', 'min-height': '50px' });

    cTodosFiltro.habilitaCampo();
    $("#btVoltar", "#divMsgAjuda").show();
    $("#btContinuar", "#divMsgAjuda").show();
    $("#btAlterar", "#divMsgAjuda").hide();
    $("#btIncluir", "#divMsgAjuda").hide();
}

function formataFormulario(cddopcao) {

    var cTodosFormulario = $('input[type="text"],input[type="checkbox"],select', '#frmManCar');
    var cIdcidade = $('#idcidade', '#frmManCar');

    highlightObjFocus($('#frmManCar'));
    $('#btVoltar', '#divMsgAjuda').show();
    $("#btIncluir", "#divMsgAjuda").hide();
    $('#divMsgAjuda').css('display', 'block');
    $('#divFormulario').css({ 'margin-top': '10px' });

    //op��o de altera��o
    if(cddopcao == 'A') {
        $('#divFormulario').css('display', 'block');
        cTodosFormulario.habilitaCampo();
        controlaPesquisas('divFiltro');
        $("#btAlterar", "#divMsgAjuda").show();
    } else if (cddopcao == 'I') {
        $('#frmManCar').css('display', 'block');
        $('#divFormulario').css('display', 'none');
        $('#divCartorios, #divPesquisaRodape').css('display', 'none');
        controlaPesquisas('frmManCar');
        cTodosFormulario.habilitaCampo();
        cTodosFormulario.val('');
        $('#flgativo').val(1);
        $("#btAlterar", "#divMsgAjuda").hide();
        $("#btContinuar", "#divMsgAjuda").hide();
        $("#btIncluir", "#divMsgAjuda").show();
    } else {
        $('#frmManCar').css('display', 'none');
        $('#divFormulario').css('display', 'block');
        controlaPesquisas('divFiltro');
        cTodosFormulario.desabilitaCampo();
        $("#btAlterar", "#divMsgAjuda").hide();
    }

    layoutPadrao();

    //cIdcidade.unbind('focus').bind('focus', function(e) {
        ;
    //});

}

function btContinuar() {
    var opcao = $("#cddopcao", "#frmCab").val();

    carregarDados(1, 20);
    cTodosFiltro.desabilitaCampo();
    $("#btContinuar", "#divMsgAjuda").hide();
    
    if (opcao == 'A') {
        $('#frmManCar').css('display', 'block');
        controlaPesquisas('frmManCar');
    }
}

function formataGridCartorios(opcao){
	
    var divRegistro = $('#divCartorios');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'300px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '80px';
    arrayLargura[1] = '320px';
    arrayLargura[2] = '100px';
    arrayLargura[3] = '40px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';    
    arrayAlinha[2] = 'left';    
    arrayAlinha[3] = 'center';    

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
    
    if (opcao != 'E') {
        selecionaCartorio(opcao);
    }

    $('table > tbody > tr', divRegistro).click( function() {
		selecionaCartorio(opcao);
	});

    return false;	
}

// Botao Voltar
function btnVoltar() {
    estadoInicial();
}

function carregarDados(nriniseq,nrregist) {
    var cddopcao = $("#cddopcao", "#frmCab").val();
    var uf = $("#uf", "#frmOpcao").val();
    var idcidade = $("#idcidade", "#frmOpcao").val();
    var nrcpf_cnpj = $("#nrcpf_cnpj", "#frmOpcao").val();

    if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) { 
        if ($('#frmManCar').css('display') == 'block' && cddopcao != 'E'){
            selecionaCartorio(cddopcao);
        }
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

    // Carrega conte�do da op��o atrav�s de ajax
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/mancar/obtem_consulta.php",
        data: {
            cddopcao: cddopcao,
            nriniseq: nriniseq,
            nrregist: nrregist,
            uf: uf,
            idcidade: idcidade,
            nrcpf_cnpj: nrcpf_cnpj,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
        },
        success: function(response) {
            if (response.substr(0, 14) == 'hideMsgAguardo') {
                eval(response);
            } else {
                $('#divFormulario').html(response);
                $('#divPesquisaRodape').formataRodapePesquisa();
                hideMsgAguardo();
                formataFormulario(cddopcao);
                formataGridCartorios(cddopcao);
            }
		}
    });

    return false;

}

function alterarDados() {
    showConfirmacao('Confirma a atualiza&ccedil;&atilde;o dos dados?', 'ManCar', 'grava_dados();', 'voltaDiv();estadoInicial();', 'sim.gif', 'nao.gif');
}

function grava_dados() {

    // Campos de parametrizacao
    var idcartorio = $('#idcartorio', '#frmManCar').val();
    var nrcpf_cnpj = $('#nrcpf_cnpj', '#frmManCar').val();
    var nmcartorio = $('#nmcartorio','#frmManCar').val();    
    var idcidade = $('#idcidade','#frmManCar').val();
    var flgativo = $('#flgativo','#frmManCar').val();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, enviando informa&ccedil;&otilde;es ...");

    // Carrega conte�do da op��o atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/mancar/grava_dados.php",
        data: {
            idcartorio : idcartorio,
            nrcpf_cnpj : nrcpf_cnpj,
            nmcartorio : nmcartorio,
            idcidade   : idcidade,
            flgativo   : flgativo,
            cddopcao   : 'A',
            redirect   : "script_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
        },
        success: function(response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            }
        }
    });
}

function excluirCartorio(idcartorio) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, enviando informa&ccedil;&otilde;es ...");

    // Carrega conte�do da op��o atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/mancar/grava_dados.php",
        data: {
            idcartorio : idcartorio,
            cddopcao   : 'E',
            redirect   : "script_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
        },
        success: function(response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            }
        }
    });
}

function selecionaCartorio(opcao) {

    var flgSelected = false;

	$('table > tbody > tr', 'div.divRegistros').each( function() {
		if ( $(this).hasClass('corSelecao') ) {
            flgSelected = true;

            var self = $(this);
            var idcartorio = $('#idcartorio', self).val();

			if (opcao == 'A'){
                $('#idcartorio', '#frmManCar').val(idcartorio);
                $('#nrcpf_cnpj', '#frmManCar').val($('#nrcpf_cnpj', self).val());
                $('#nmcartorio', '#frmManCar').val($('#nmcartorio', self).val());
                $('#idcidade', '#frmManCar').val($('#idcidade', self).val());
                $('#dscidade', '#frmManCar').val($('#dscidade', self).val());
                $('#flgativo', '#frmManCar').val($('#flgativo', self).val());
			}else if(opcao == 'E'){
				showConfirmacao('Voc� tem certeza de que deseja excluir este cart�rio?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirCartorio(' + idcartorio + ');', 'voltaDiv();estadoInicial();', 'sim.gif', 'nao.gif');
			}
		}
		
	});

    if (! flgSelected && opcao == 'E') {
        showError("error", "Favor selecionar o cart�rio que deseja excluir!", "Alerta - Ayllos", "");
    }
	
	return false;
}

function controlaPesquisas(nmformul) {
    var cdcooper = $('#cdcooper', '#' + nmformul).val();
    var cdestado = $('#cdestado', '#' + nmformul).val();
    var campoAnterior = '';
    var lupas = $('a', '#' + nmformul);

    // Atribui a classe lupa para os links
    lupas.addClass('lupa').css('cursor', 'pointer');

    // Percorrendo todos os links
    lupas.each(function() {
        $(this).unbind('click').bind('click', function() {

            if ($(this).prev().hasClass('campoTelaSemBorda')) {
                return false;
            } else {
                // Obtenho o nome do campo anterior
                campoAnterior = $(this).prev().attr('name');

                // Cidade
                if (campoAnterior == 'idcidade') {
                    bo          = 'CADA0003'
                    procedure   = 'LISTA_CIDADES';
                    titulo      = 'Cidades';
                    qtReg       = '20';
                    filtrosPesq = 'Codigo;idcidade;70px;S;;S;codigo|Cidade;dscidade;200px;S;;S;descricao|UF;cdestado;40px;S;' + cdestado + ';S;descricao|;infiltro;;N;1;N;codigo|;intipnom;;N;1;N;codigo|;cdcidade;;N;0;N;codigo';
                    colunas     = 'Codigo;idcidade;30%;center|Cidade;dscidade;60%;left|UF;cdestado;10%;center';
                    mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
                    return false;
                }
            }
        });
    });
}