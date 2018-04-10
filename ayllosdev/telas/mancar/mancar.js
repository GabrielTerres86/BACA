//*********************************************************************************************//
//*** Fonte: mancar.js                                                 						***//
//*** Autor: André Clemer                                            						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					    ***//
//***                                                                  						***//
//*** Objetivo  : Biblioteca de funções da tela MANCAR                 						***//
//***                                                                  						***//	 
//*** Alterações:                                                                           ***//	  
//***                           									                        ***//
//*********************************************************************************************//

var cCddopcao;
var cCdcooper;
var frmCab = 'frmCab';
var frmManCar = 'frmManCar';
var cTodos;
var cddopcao = 'C';
var cTodosCabecalho;

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
    carregarDados(1,20);
}

function formataFormulario(cddopcao) {

    var cTodosFormulario = $('input[type="text"],input[type="checkbox"],select', '#frmManCar');
    var cIdcidade = $('#idcidade', '#frmManCar');

    highlightObjFocus($('#frmManCar'));
    $('#btVoltar', '#divMsgAjuda').show();
    $("#btIncluir", "#divMsgAjuda").hide();
    $('#divMsgAjuda').css('display', 'block');

    //opção de alteração
    if(cddopcao == 'A') {
        $('#frmManCar').css('display', 'block');
        $('#divFormulario').css('display', 'block');

        cTodosFormulario.habilitaCampo();
        $("#btAlterar", "#divMsgAjuda").show();
    } else if (cddopcao == 'I') {
        $('#frmManCar').css('display', 'block');
        $('#divFormulario').css('display', 'none');
        $('#divCartorios, #divPesquisaRodape').css('display', 'none');

        cTodosFormulario.habilitaCampo();
        cTodosFormulario.val('');
        $('#flgativo').val(1);
        $("#btAlterar", "#divMsgAjuda").hide();
        $("#btIncluir", "#divMsgAjuda").show();
    } else {
        $('#frmManCar').css('display', 'none');
        $('#divFormulario').css('display', 'block');

        cTodosFormulario.desabilitaCampo();
        $("#btAlterar", "#divMsgAjuda").hide();
    }

    layoutPadrao();

    //cIdcidade.unbind('focus').bind('focus', function(e) {
        controlaPesquisas();
    //});

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


    if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) { 
        if ($('#frmManCar').css('display') == 'block' && cddopcao != 'E'){
            selecionaCartorio(cddopcao);
        }
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

    if (cddopcao == 'I') {
        hideMsgAguardo();
        formataFormulario(cddopcao);
        return false;
    }

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/mancar/obtem_consulta.php",
        data: {
            cddopcao: cddopcao,
            nriniseq: nriniseq,
            nrregist: nrregist,
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

    // Carrega conteúdo da opção através de ajax
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

    // Carrega conteúdo da opção através de ajax
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
				showConfirmacao('Você tem certeza de que deseja excluir este cartório?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirCartorio(' + idcartorio + ');', 'voltaDiv();estadoInicial();', 'sim.gif', 'nao.gif');
			}
		}
		
	});

    if (! flgSelected && opcao == 'E') {
        showError("error", "Favor selecionar o cartório que deseja excluir!", "Alerta - Ayllos", "");
    }
	
	return false;
}

function controlaPesquisas() {

    var nmformul = 'frmManCar';
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