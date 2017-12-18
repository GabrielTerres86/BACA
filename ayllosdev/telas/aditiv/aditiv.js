/*!
 * FONTE        : aditiv.js
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 26/09/2011
 * OBJETIVO     : Biblioteca de funções da tela ADITIV
 * --------------
 * ALTERAÇÕES   :
 *
 * 001: [25/06/2012] Jorge Hamaguchi (CECRED)  : Alterado funcoes Gera_Impressao e Gera_Termo.
 *										   		 Adequado para submeter imppressao.
 *												 Retirado campo "redirect" popup.
 .
 * 002: [22/11/2012] Daniel Zimmermann(CECRED) : Alterado botões do tipo tag <input> por tag <a>.
 *												 Incluso efeito highlightObjFocus e FadeTo, alteração
 *												 posicionamento campos na tela, criado funcao GerenciaPesquisa
 *												 incluso navegacao campos usando enter, retirado função
 *												 controlaPesquisas.
 *
 * 003: [03/04/2013] Daniel Zimmermann(CECRED) : Correcao efento onClick do botao imprimir.
 *
 * 004: [28/02/2014] Guilherme(SUPERO)         : Novos campos NrCpfCgc e validações.
 *
 * 005: [08/11/2014] Jonata (RKAM)             : Retirar function Gera_Termo.  
 *
 * 006: [11/12/2014] Lucas Reinert(CECRED)	   : Adicionado tratamento para novos produtos de captação
 *
 * 007: 05/01/2015 - Kelvin (CECRED) 		   : Padronizando a mascara do campo nrctremp.
 *									   		  	 10 Digitos - Campos usados apenas para visualização
 *									   			 8 Digitos - Campos usados para alterar ou incluir novos contratos
 *									   			 (SD 233714) 
 *
 * 009: 17/12/2015 - Tiago (CECRED)            : Restricoes de caracteres no campo dschassi (Tiago/Gielow)
 *
 * 010: 23/12/2015 - Odirlei(AMcom)            : Ajustado validacao no campo chassi para nao digitar letras I,O e Q  
 *                                               devido ao keycode nao diferenciar maiusculos e minusculos (Odirlei-AMcom SD378702)
 *
 * 011: 31/10/2017 - Jaison (CECRED)           : Ajustes conforme inclusao do campo tipo de contrato. (Jaison/Marcos Martini - PRJ404)
 *
 * 012: 18/12/2017 - P404 - Inclusão de Garantia de Cobertura das Operações de Crédito (Augusto / Marcos (Supero))
 * --------------
 *
 */

//Formulários
var frmCab   		= 'frmCab';
var frmDados  		= 'frmAditiv';
var tabDados		= 'tabAditiv';

var cddopcao		= 'C';
var nrdconta		= 0;
var nrctremp		= 0;
var dtmvtolx		= '';
var nraditiv		= 0;
var cdaditiv		= 0;
var flgaplic 		= '';
var nmdgaran		= '';
var regtotal		= 0;
var tpctrato        = 90;

var aplicacao		= new Array();
var arrayAditiv		= new Array();

//Labels/Campos do cabeçalho
var rCddopcao, rNrdconta, rNrctremp, rNraditiv, rDtmvtolx, rCdaditiv, rCdaditix, rTpctrato,
	cCddopcao, cNrdconta, cNrctremp, cNraditiv, cDtmvtolx, cCdaditiv, cCdaditix, cTpctrato, cTodosCabecalho, btnOK1, btnOK2;


$(document).ready(function() {
	estadoInicial();
});


// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});

	$('#'+tabDados).css({'display':'none'}).html('');

	hideMsgAguardo();
	atualizaSeletor();
	formataCabecalho();
	controlaLayout();

	$('#divPesquisaRodape').remove();
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');
	fechaRotina( $('#divRotina') );
	$('#divRotina').html('');

	cCddopcao.habilitaCampo();
	cCddopcao.focus();
	cCddopcao.val(cddopcao);

	removeOpacidade('divTela');

	highlightObjFocus( $("#frmCab") );

	$("#btVoltar","#divBotoes").hide();



}

function atualizaSeletor(){

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);
	rNrdconta			= $('label[for="nrdconta"]','#'+frmCab);
	rNrctremp			= $('label[for="nrctremp"]','#'+frmCab);
	rNraditiv			= $('label[for="nraditiv"]','#'+frmCab);
	rDtmvtolx			= $('label[for="dtmvtolx"]','#'+frmCab);
	rCdaditiv			= $('label[for="cdaditiv"]','#'+frmCab);
	rCdaditix			= $('label[for="cdaditix"]','#'+frmCab);
    rTpctrato			= $('label[for="tpctrato"]','#'+frmCab);

	cCddopcao			= $('#cddopcao','#'+frmCab);
	cNrdconta			= $('#nrdconta','#'+frmCab);
	cNrctremp			= $('#nrctremp','#'+frmCab);
	cNraditiv			= $('#nraditiv','#'+frmCab);
	cDtmvtolx			= $('#dtmvtolx','#'+frmCab);
	cCdaditiv			= $('#cdaditiv','#'+frmCab);
	cCdaditix			= $('#cdaditix','#'+frmCab);
	cTpctrato			= $('#tpctrato','#'+frmCab);

	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK1				= $('#btnOK1','#'+frmCab);
	btnOK2				= $('#btnOK2','#'+frmCab);

	return false;
}


// controle
function controlaOperacao(nriniseq, nrregist) {

	var mensagem = 'Aguarde, buscando dados ...';
	showMsgAguardo( mensagem );

	// Carrega dados da conta através de ajax
	$.ajax({
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/aditiv/principal.php',
		data    :
				{
					cddopcao	: cddopcao,
                    nrdconta	: nrdconta,
					nrctremp	: nrctremp,
				    dtmvtolx	: dtmvtolx,
                    tpctrato    : tpctrato,
					nriniseq	: nriniseq,
					nrregist	: nrregist,
 					redirect	: 'script_ajax'
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTela').html(response);
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
						}
					}
				}
	});

	return false;
}

function manterRotina( operacao ) {

	hideMsgAguardo();

	var mensagem = '';

	var idseqbem = $('#idseqbem', '#'+frmCab).val();	// inteiro

	var idcobert = normalizaNumero($('#idcobert', '#'+frmCab).val());

	var flgpagto = $('#flgpagto', '#frmTipo').val(); //
	var dtdpagto = $('#dtdpagto', '#frmTipo').val(); //
	var nrctagar = normalizaNumero( $('#nrctagar', '#frmTipo').val() ); // inteiro

	var dsbemfin = $('#dsbemfin', '#frmTipo').val(); // string
	var dschassi = $('#dschassi', '#frmTipo').val(); // string
	var nrdplaca = $('#nrdplaca', '#frmTipo').val(); // string
	var dscorbem = $('#dscorbem', '#frmTipo').val(); // string
	var nranobem = normalizaNumero( $('#nranobem', '#frmTipo').val() ); // inteiro
	var nrmodbem = normalizaNumero( $('#nrmodbem', '#frmTipo').val() ); // inteiro
	var nrrenava = normalizaNumero( $('#nrrenava', '#frmTipo').val() ); // inteiro
	var tpchassi = normalizaNumero( $('#tpchassi', '#frmTipo').val() ); // inteiro
	var ufdplaca = $('#ufdplaca', '#frmTipo').val(); // string
	var uflicenc = $('#uflicenc', '#frmTipo').val(); // string
    var nrcpfcgc = normalizaNumero( $('#nrcpfcgc', '#frmTipo').val() ); // inteiro

	var nrcpfgar = normalizaNumero( $('#nrcpfgar', '#frmTipo').val() ); //
	var nrdocgar = $('#nrdocgar', '#frmTipo').val(); //

	var nrpromi1 = $('#nrpromi1', '#frmTipo').val(); //
	var nrpromi2 = $('#nrpromi2', '#frmTipo').val(); //
	var nrpromi3 = $('#nrpromi3', '#frmTipo').val(); //
	var nrpromi4 = $('#nrpromi4', '#frmTipo').val(); //
	var nrpromi5 = $('#nrpromi5', '#frmTipo').val(); //
	var nrpromi6 = $('#nrpromi6', '#frmTipo').val(); //
	var nrpromi7 = $('#nrpromi7', '#frmTipo').val(); //
	var nrpromi8 = $('#nrpromi8', '#frmTipo').val(); //
	var nrpromi9 = $('#nrpromi9', '#frmTipo').val(); //
	var nrprom10 = $('#nrprom10', '#frmTipo').val(); //

	var vlpromi1 = cdaditiv == 7 ? $('#vlpromi1', '#frmTipo').val() : $('#vlpromis', '#frmTipo').val(); //
	var vlpromi2 = $('#vlpromi2', '#frmTipo').val(); //
	var vlpromi3 = $('#vlpromi3', '#frmTipo').val(); //
	var vlpromi4 = $('#vlpromi4', '#frmTipo').val(); //
	var vlpromi5 = $('#vlpromi5', '#frmTipo').val(); //
	var vlpromi6 = $('#vlpromi6', '#frmTipo').val(); //
	var vlpromi7 = $('#vlpromi7', '#frmTipo').val(); //
	var vlpromi8 = $('#vlpromi8', '#frmTipo').val(); //
	var vlpromi9 = $('#vlpromi9', '#frmTipo').val(); //
	var vlprom10 = $('#vlprom10', '#frmTipo').val(); //

	var tpaplic1 = $('#tpaplic1', '#frmTipo').val();
	var tpaplic3 = $('#tpaplic3', '#frmTipo').val();
	var tpaplic5 = $('#tpaplic5', '#frmTipo').val();
	var tpaplic7 = $('#tpaplic7', '#frmTipo').val();
	var tpaplic8 = $('#tpaplic8', '#frmTipo').val();

	var tpproap1 = $('#tpproap1', '#frmTipo').val();
	var tpproap3 = $('#tpproap3', '#frmTipo').val();
	var tpproap5 = $('#tpproap5', '#frmTipo').val();
	var tpproap7 = $('#tpproap7', '#frmTipo').val();
	var tpproap8 = $('#tpproap8', '#frmTipo').val();
	
	switch ( operacao ) {
		case 'VD': mensagem = 'Aguarde, validando dados...'; break;
		case 'GD': mensagem = 'Aguarde, gravando dados...'; break;
	}

	showMsgAguardo( mensagem );

	$.ajax({
			type  : 'POST',
			url   : UrlSite + 'telas/aditiv/manter_rotina.php',
			data: {
				operacao	: operacao,
				cddopcao	: cddopcao, // global
				nrdconta	: nrdconta, // global
				nrctremp	: nrctremp, // global
				nraditiv	: nraditiv, // global
				cdaditiv	: cdaditiv, // global
                tpctrato    : tpctrato, // global

				idseqbem	: idseqbem,

				flgpagto	: flgpagto,
				dtdpagto	: dtdpagto,
				flgaplic	: flgaplic,
				nrctagar	: nrctagar,

				dsbemfin	: dsbemfin,
				dschassi	: dschassi,
				nrdplaca	: nrdplaca,
				dscorbem	: dscorbem,
				nranobem  	: nranobem,
				nrmodbem    : nrmodbem,
				nrrenava    : nrrenava,
				tpchassi    : tpchassi,
				ufdplaca    : ufdplaca,
				uflicenc    : uflicenc,
                nrcpfcgc    : nrcpfcgc,

				nrcpfgar	: nrcpfgar,
				nrdocgar	: nrdocgar,
				nmdgaran	: nmdgaran,
				nrpromi1	: nrpromi1,
				nrpromi2    : nrpromi2,
				nrpromi3    : nrpromi3,
				nrpromi4    : nrpromi4,
				nrpromi5    : nrpromi5,
				nrpromi6    : nrpromi6,
				nrpromi7    : nrpromi7,
				nrpromi8    : nrpromi8,
				nrpromi9    : nrpromi9,
				nrprom10    : nrprom10,

				vlpromi1	: vlpromi1,
				vlpromi2	: vlpromi2,
				vlpromi3	: vlpromi3,
				vlpromi4	: vlpromi4,
				vlpromi5	: vlpromi5,
				vlpromi6	: vlpromi6,
				vlpromi7	: vlpromi7,
				vlpromi8	: vlpromi8,
				vlpromi9	: vlpromi9,
				vlprom10	: vlprom10,

				tpaplic1	: tpaplic1,
				tpaplic3	: tpaplic3,
				tpaplic5	: tpaplic5,
				tpaplic7	: tpaplic7,
				tpaplic8	: tpaplic8,

				tpproap1	: tpproap1,
				tpproap3    : tpproap3,
				tpproap5    : tpproap5,
				tpproap7    : tpproap7,
				tpproap8    : tpproap8,

				idgaropc    : idcobert,
				
				redirect	: 'script_ajax'
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
		});

	return false;

}


// imprimir
function Gera_Impressao() {

	// Eliminar
	$('#nrdconta','#frmTipo').remove();
	$('#nrctremp','#frmTipo').remove();
	$('#nraditiv','#frmTipo').remove();
	$('#cdaditiv','#frmTipo').remove();
	$('#sidlogin','#frmTipo').remove();
	$('#tpctrato','#frmTipo').remove();

	// Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#frmTipo').append('<input type="hidden" id="nrdconta" name="nrdconta" />');
	$('#frmTipo').append('<input type="hidden" id="nrctremp" name="nrctremp" />');
	$('#frmTipo').append('<input type="hidden" id="nraditiv" name="nraditiv" />');
	$('#frmTipo').append('<input type="hidden" id="cdaditiv" name="cdaditiv" />');
	$('#frmTipo').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	$('#frmTipo').append('<input type="hidden" id="tpctrato" name="tpctrato" />');

	// Agora insiro os devidos valores nos inputs criados
	$('#nrdconta','#frmTipo').val( nrdconta );
	$('#nrctremp','#frmTipo').val( nrctremp );
	$('#nraditiv','#frmTipo').val( nraditiv );
	$('#cdaditiv','#frmTipo').val( cdaditiv );
	$('#sidlogin','#frmTipo').val( $('#sidlogin','#frmMenu').val() );
	$('#tpctrato','#frmTipo').val( tpctrato );

	var action = UrlSite + 'telas/aditiv/imprimir_dados.php';

	$('input[type="text"], select','#frmTipo').habilitaCampo();

	carregaImpressaoAyllos("frmTipo",action,"estadoInicial();");

}


// formata
function formataCabecalho() {

	//atualizaSeletor();

	rCddopcao.addClass('rotulo').css({'width':'58px'});
	rNrdconta.addClass('rotulo-linha').css({'width':'55px'});
	rNrctremp.addClass('rotulo').css({'width':'58px'});
	rNraditiv.addClass('rotulo-linha').css({'width':'48px'});
	rDtmvtolx.addClass('rotulo-linha').css({'width':'52px','display':'none'});
	rCdaditix.addClass('rotulo-linha').css({'width':'36px','display':'none'});
	rCdaditiv.addClass('rotulo').css({'width':'0px'});
    rTpctrato.addClass('rotulo-linha').css({'width':'90px'});

	cCddopcao.css({'width':'470px'});
	cNrdconta.addClass('conta pesquisa').css({'width':'80px'})
	cNrctremp.addClass('contrato3 pesquisa').css({'width':'80px'});
	cNraditiv.addClass('pesquisa inteiro').css({'width':'70px'}).attr('maxlength','2');
	cDtmvtolx.addClass('data').css({'width':'83px','display':'none'});
	cCdaditix.css({'width':'99px','display':'none'});
	cCdaditiv.css({'width':'563px','height':'130px'});
	cTpctrato.css({'width':'278px'}).val(tpctrato);

	if ( $.browser.msie ) {
		rNrdconta.css({'width':'58px'});
		rNrctremp.css({'width':'62px'});
		rNraditiv.css({'width':'51px'});
		rCdaditix.css({'width':'39px'});
		rDtmvtolx.css({'width':'55px'});
	}

	cTodosCabecalho.desabilitaCampo();

	// Se clicar no botao OK
	btnOK1.unbind('click').bind('click', function() {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( cCddopcao.hasClass('campo') ) {
			cddopcao = cCddopcao.val();
			cTodosCabecalho.limpaFormulario().removeClass('campoErro');
			cCddopcao.desabilitaCampo();
			cNrdconta.habilitaCampo().focus();
			cNrctremp.habilitaCampo();
			cNraditiv.habilitaCampo();
			cCdaditix.habilitaCampo();
			cDtmvtolx.habilitaCampo();

            if ( cddopcao != 'X' ) {
                cTpctrato.habilitaCampo();
			}

			$('#divBotoes', '#divTela').css({'display':'block'});
			$("#btVoltar","#divBotoes").show();

			cCddopcao.val(cddopcao);
			controlaLayout();

		}

		return false;

	});


	btnOK2.unbind('click').bind('click', function() {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( cNrdconta.hasClass('campoTelaSemBorda') ) { return false; }

		selecionaTipo();

		nrdconta = normalizaNumero( cNrdconta.val() );
		nrctremp = normalizaNumero( cNrctremp.val() );
		nraditiv = normalizaNumero( cNraditiv.val() );
		cdaditiv = cCdaditiv.val() ? cCdaditiv.val()[0] : 0;
		dtmvtolx = cDtmvtolx.val();
		tpctrato = normalizaNumero( cTpctrato.val() );

		cTodosCabecalho.removeClass('campoErro');

		// Verifica se a conta é válida
		if ( !validaNroConta(nrdconta) && nrdconta != 0 ) {
			showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmCab +'\');');
			return false;
		}

		if ( cddopcao == 'V' ) {
			controlaOperacao(1, 50);

		} else {

            // Se for Cobertura de Aplicacao Vinculada a Operacao
            if (cdaditiv == 9) {
                buscaDadosGAROPC();
            } else {
                
                showMsgAguardo('Aguarde, buscando ...');

                // Executa script de confirmação através de ajax
                $.ajax({
                    type: 'POST',
                    dataType: 'html',
                    url: UrlSite + 'telas/aditiv/busca_tipo_aditivo.php',
                    data: {
                        nrdconta : nrdconta,
                        nrctremp : nrctremp,
                        nraditiv : nraditiv,
                        tpctrato : tpctrato,
                        redirect : 'html_ajax'
                        },
                    error: function(objAjax,responseError,objExcept) {
                        hideMsgAguardo();
                        showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
                    },
                    success: function(cdaditiv_ajax) {

                        // Marca o aditivo
                        $("#cdaditiv option[value='" + cdaditiv_ajax + "']",'#frmCab').prop('selected',true);

                        cdaditiv = $("#cdaditiv","#frmCab").val()[0];

                        // Se for Cobertura de Aplicacao Vinculada a Operacao
                        if (cdaditiv_ajax == 9) {
                            buscaDadosGAROPC();
                        } else {
                            mostraTipo();
                        }
                    }
                });
            }
		}

		return false;

	});

	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		// Se é a tecla ENTER,
		if ( e.keyCode == 13 ) {
			if (cNrdconta.val() == '') {
				mostraPesquisaAssociado('nrdconta', frmCab );
				return false;
			} else {
                if ( cCddopcao.val() != 'X' ) {
                    cTpctrato.focus();
                } else {
                    cNrctremp.focus();
                }
				return false;
			}
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta', frmCab );
			return false;
		}
	});

	cTpctrato.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		// Se é a tecla ENTER,
		if ( e.keyCode == 13 ) {
			cNrctremp.focus();
            return false;
		}
	});

	cNrctremp.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( $('#divRotina').css('visibility') == 'visible' ) {
			if ( e.keyCode == 13 ) { selecionaContrato(); return false; }
		}

		// Se é a tecla ENTER,
		if ( e.keyCode == 13 ) {
			nrctremp = normalizaNumero( $(this).val() );

			if ( nrctremp == 0 ) {
				mostraContrato();
			} else {
				if ( $('#cddopcao','#frmCab').val() == 'X') {
					$('#btnOK2','#frmCab').focus();
				} else if ( $('#cddopcao','#frmCab').val() == 'V') {
					$('#dtmvtolx','#frmCab').focus();
				} else if ( $('#cddopcao','#frmCab').val() == 'C' || $('#cddopcao','#frmCab').val() == 'E') {
					$('#nraditiv','#frmCab').focus();
				} else if ( $('#cddopcao','#frmCab').val() == 'I') {
					$('#cdaditix','#frmCab').focus();
				}

			//	$(this).next().focus();
			}
			return false;
		}
		atualizaSeletor();
	});

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			$('#btnOK1','#frmCab').focus();
			return false;
		}
	});

	$('#dtmvtolx','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			$('#btnOK2','#frmCab').focus();
			return false;
		}
	});

	$('#cdaditix','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			$('#btnOK2','#frmCab').focus();
			return false;
		}
	});

	$('#nraditiv','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			$('#btnOK2','#frmCab').focus();
			return false;
		}
	});


	layoutPadrao();
	return false;
}

function formataTabela() {

	// tabela
	var divRegistro = $('div.divRegistros', '#'+tabDados);
	var tabela      = $('table', divRegistro );

	$('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'160px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '75px';
	arrayLargura[1] = '74px';
	arrayLargura[2] = '238px';
	arrayLargura[3] = '50px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'left';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	hideMsgAguardo();
	return false;
}

function controlaLayout() {

	$('#frmCab').css({'display':'block'});

	rNraditiv.css({'display':'none'});
	cNraditiv.css({'display':'none'});
	rCdaditix.css({'display':'none'});
	cCdaditix.css({'display':'none'});
	rCdaditiv.css({'display':'none'});
	cCdaditiv.css({'display':'none'});
	cNraditiv.next().css({'display':'none'}); // lupa
	rDtmvtolx.css({'display':'none'});
	cDtmvtolx.css({'display':'none'});

	if ( cddopcao == 'V' ) {
		rDtmvtolx.css({'display':'block'});
		cDtmvtolx.css({'display':'block'});

	} else if ( cddopcao == 'X' ) {
		rCdaditiv.css({'display':'block'});
		cCdaditiv.css({'display':'block'});

		$("#cdaditiv option[value='5']",'#'+frmCab).prop('selected',true);

	} else if ( cddopcao == 'I' ) {
		rCdaditiv.css({'display':'block'});
		cCdaditiv.css({'display':'block'});
		rCdaditix.css({'display':'block'});
		cCdaditix.css({'display':'block'});

	} else {
		rNraditiv.css({'display':'block'});
		cNraditiv.css({'display':'block'});
		cNraditiv.next().css({'display':'block'}); // lupa
		rCdaditiv.css({'display':'block','width':'0px'});
		cCdaditiv.css({'display':'block'});

	}


	return false;
}


// tipo
function mostraTipo() {

	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/aditiv/tipo.php',
		data: {
			redirect: 'html_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaTipo();
			return false;
		}
	});
	return false;

}

function buscaTipo() {

	arrayAditiv.length = 0;
	showMsgAguardo('Aguarde, buscando ...');

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/aditiv/busca_tipo.php',
		data: {
			cddopcao: cddopcao,
			nrdconta: nrdconta,
			nrctremp: nrctremp,
			nraditiv: nraditiv,
			cdaditiv: cdaditiv,
            tpctrato: tpctrato,
			redirect: 'script_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {

			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudo', '#divRotina').html(response);

					if ( cddopcao == 'X' && parseInt(regtotal) == 0 ) {
						estadoInicial();
					} else {
						exibeRotina( $('#divRotina') );
					}

					if ( cddopcao == 'E' && cdaditiv != 2 && cdaditiv != 3 ) {
						$('#divBotoes', '#divRotina').css({'display':'none'});
						manterRotina('VD');
						//showConfirmacao('078 - Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina(\'VD\')','fechaRotina($(\'#divRotina\'))','sim.gif','nao.gif');
					}

					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}
	});


	return false;
}

function formataTipo1( tpdescto ) {

	var frmTipo1 = 'frmTipo';

	highlightObjFocus( $("#frmTipo") );

	// label
	rDtmvtolt	= $('label[for="dtmvtolt"]','#'+frmTipo1);
	rFlgpagto	= $('label[for="flgpagto"]','#'+frmTipo1);
	rDtdpagto	= $('label[for="dtdpagto"]','#'+frmTipo1);

	rDtmvtolt.addClass('rotulo').css({'width':'160px'});
	rFlgpagto.addClass('rotulo').css({'width':'160px'});
	rDtdpagto.addClass('rotulo').css({'width':'160px'});

	// campo
	cDtmvtolt	= $('#dtmvtolt','#'+frmTipo1);
	cFlgpagto	= $('#flgpagto','#'+frmTipo1);
	cDtdpagto	= $('#dtdpagto','#'+frmTipo1);

	cDtmvtolt.css({'width':'120px'});
	cFlgpagto.css({'width':'120px'});
	cDtdpagto.addClass('data').css({'width':'120px'});


	if ( cddopcao == 'I' ) {
		$('select, input', '#'+frmTipo1).habilitaCampo();
		cDtmvtolt.val('').desabilitaCampo();
		cDtmvtolt.focus();
		trocaBotao( 'gravar' );

		//
		if ( tpdescto == '2' ) {
			cFlgpagto.desabilitaCampo();
		}

	} else {
		$('select, input', '#'+frmTipo1).desabilitaCampo();
	}

	// centraliza a divRotina
	$('#divRotina').css({'width':'375px'});
	$('#divConteudo').css({'width':'350px'});
	$('#divRotina').centralizaRotinaH();

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	layoutPadrao();
	return false;
}

function formataTipo2() {	

	var tabTipo2 = 'tabTipo';
	var frmTipo2 = 'frmTipo';

	highlightObjFocus( $("#tabTipo") );
	highlightObjFocus( $("#frmTipo") );

	// label
	rDtmvtolt	= $('label[for="dtmvtolt"]','#'+frmTipo2);
	rDtmvtolt.addClass('rotulo').css({'width':'160px'});

	// campo
	cDtmvtolt	= $('#dtmvtolt','#'+frmTipo2);
	cDtmvtolt.css({'width':'120px'});

	if ( cddopcao == 'C' || cddopcao == 'E' ) {

		// centraliza a divRotina
		$('#divRotina').css({'width':'680px'});
		$('#divConteudo', '#divRotina').css({'width':'705px'});
		$('#divRotina').centralizaRotinaH();
	
		// tabela
		var divRegistro = $('div.divRegistros', '#'+tabTipo2);
		var tabela      = $('table', divRegistro );

		$('#'+tabTipo2).css({'margin-top':'5px'});		

		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '70px';
		arrayLargura[1] = '150px';
		arrayLargura[2] = '80px';
		arrayLargura[3] = '70px';
		arrayLargura[4] = '75px';
		arrayLargura[5] = '63px';
	//	arrayLargura[6] = '69px';
	
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'left';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'right';
	//	arrayAlinha[7] = 'right';
		

		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	} else if ( cddopcao == 'I' ) {

		// centraliza a divRotina
		$('#divRotina').css({'width':'575px'});
		$('#divConteudo', '#divRotina').css({'width':'550px'});
		$('#divRotina').centralizaRotinaH();
	
		// label
		rBtaplic1	= $('label[for="btaplic1"]','#'+frmTipo2);
		rBtaplic3	= $('label[for="btaplic3"]','#'+frmTipo2);
		rBtaplic5	= $('label[for="btaplic5"]','#'+frmTipo2);
		rBtaplic7	= $('label[for="btaplic7"]','#'+frmTipo2);
		rBtaplic8	= $('label[for="btaplic8"]','#'+frmTipo2);
		rTpaplic1	= $('label[for="tpaplic1"]','#'+frmTipo2);
		rTpaplic3	= $('label[for="tpaplic3"]','#'+frmTipo2);
		rTpaplic5	= $('label[for="tpaplic5"]','#'+frmTipo2);
		rTpaplic7	= $('label[for="tpaplic7"]','#'+frmTipo2);
		rTpaplic8	= $('label[for="tpaplic8"]','#'+frmTipo2);

		rBtaplic1.addClass('rotulo').css({'width':'3px'});
		rBtaplic3.addClass('rotulo').css({'width':'3px'});
		rBtaplic5.addClass('rotulo').css({'width':'3px'});
		rBtaplic7.addClass('rotulo').css({'width':'3px'});
		rBtaplic8.addClass('rotulo').css({'width':'3px'});
		rTpaplic1.addClass('rotulo-linha').css({'width':'5px'});
		rTpaplic3.addClass('rotulo-linha').css({'width':'5px'});
		rTpaplic5.addClass('rotulo-linha').css({'width':'5px'});
		rTpaplic7.addClass('rotulo-linha').css({'width':'5px'});
		rTpaplic8.addClass('rotulo-linha').css({'width':'5px'});

		// campo
		cBtaplic1	= $('#btaplic1','#'+frmTipo2);
		cBtaplic3	= $('#btaplic3','#'+frmTipo2);
		cBtaplic5	= $('#btaplic5','#'+frmTipo2);
		cBtaplic7	= $('#btaplic7','#'+frmTipo2);
		cBtaplic8	= $('#btaplic8','#'+frmTipo2);
		cTpaplic1	= $('#tpaplic1','#'+frmTipo2);
		cTpaplic3	= $('#tpaplic3','#'+frmTipo2);
		cTpaplic5	= $('#tpaplic5','#'+frmTipo2);
		cTpaplic7	= $('#tpaplic7','#'+frmTipo2);
		cTpaplic8	= $('#tpaplic8','#'+frmTipo2);

		cBtaplic1.css({'width':'80px','cursor':'pointer'});
		cBtaplic3.css({'width':'80px','cursor':'pointer'});
		cBtaplic5.css({'width':'80px','cursor':'pointer'});
		cBtaplic7.css({'width':'80px','cursor':'pointer'});
		cBtaplic8.css({'width':'80px','cursor':'pointer'});
		cTpaplic1.css({'width':'433px'});
		cTpaplic3.css({'width':'433px'});
		cTpaplic5.css({'width':'433px'});
		cTpaplic7.css({'width':'433px'});
		cTpaplic8.css({'width':'433px'});

		cDtmvtolt.val('');
	}

	$('select, input[type="text"]', '#'+frmTipo2).desabilitaCampo();	

	hideMsgAguardo();
	return false;
}

function formataTipo3() {

	var tabTipo3 = 'tabTipo';
	var frmTipo3 = 'frmTipo';

	highlightObjFocus( $("#tabTipo") );
	highlightObjFocus( $("#frmTipo") );

	// label
	rNrctagar	= $('label[for="nrctagar"]','#'+frmTipo3);
	rDtmvtolt	= $('label[for="dtmvtolt"]','#'+frmTipo3);

	rNrctagar.addClass('rotulo').css({'width':'200px'});
	rDtmvtolt.addClass('rotulo-linha').css({'width':'150px'});

	// campo
	cNrctagar	= $('#nrctagar','#'+frmTipo3);
	cDtmvtolt	= $('#dtmvtolt','#'+frmTipo3);

	cNrctagar.addClass('conta').css({'width':'90px'});
	cDtmvtolt.css({'width':'90px'});

	$('select, input[type="text"]', '#'+frmTipo3).desabilitaCampo();

	if ( cddopcao == 'C'  || cddopcao == 'E' ) {

		// tabela
		var divRegistro = $('div.divRegistros', '#'+tabTipo3);
		var tabela      = $('table', divRegistro );

		$('#'+tabTipo3).css({'margin-top':'5px'});
		//divRegistro.css({'height':'150px','padding-bottom':'2px'});
		
		// centraliza a divRotina
		$('#divRotina').css({'width':'680px'});
		$('#divConteudo').css({'width':'705px'});
		$('#divRotina').centralizaRotinaH();

		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '70px';
		arrayLargura[1] = '150px';
		arrayLargura[2] = '80px';
		arrayLargura[3] = '70px';
		arrayLargura[4] = '75px';
		arrayLargura[5] = '63px';
	//	arrayLargura[6] = '69px';
	
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'left';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'right';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	} else if ( cddopcao == 'I' ) {
	
		// centraliza a divRotina
		$('#divRotina').css({'width':'575px'});
		$('#divConteudo').css({'width':'560px'});
		$('#divRotina').centralizaRotinaH();

		// label
		rBtaplic1	= $('label[for="btaplic1"]','#'+frmTipo3);
		rBtaplic3	= $('label[for="btaplic3"]','#'+frmTipo3);
		rBtaplic5	= $('label[for="btaplic5"]','#'+frmTipo3);
		rBtaplic7	= $('label[for="btaplic7"]','#'+frmTipo3);
		rBtaplic8	= $('label[for="btaplic8"]','#'+frmTipo3);
		rTpaplic1	= $('label[for="tpaplic1"]','#'+frmTipo3);
		rTpaplic3	= $('label[for="tpaplic3"]','#'+frmTipo3);
		rTpaplic5	= $('label[for="tpaplic5"]','#'+frmTipo3);
		rTpaplic7	= $('label[for="tpaplic7"]','#'+frmTipo3);
		rTpaplic8	= $('label[for="tpaplic8"]','#'+frmTipo3);

		rBtaplic1.addClass('rotulo').css({'width':'3px'});
		rBtaplic3.addClass('rotulo').css({'width':'3px'});
		rBtaplic5.addClass('rotulo').css({'width':'3px'});
		rBtaplic7.addClass('rotulo').css({'width':'3px'});
		rBtaplic8.addClass('rotulo').css({'width':'3px'});
		rTpaplic1.addClass('rotulo-linha').css({'width':'5px'});
		rTpaplic3.addClass('rotulo-linha').css({'width':'5px'});
		rTpaplic5.addClass('rotulo-linha').css({'width':'5px'});
		rTpaplic7.addClass('rotulo-linha').css({'width':'5px'});
		rTpaplic8.addClass('rotulo-linha').css({'width':'5px'});

		// campo
		cBtaplic1	= $('#btaplic1','#'+frmTipo3);
		cBtaplic3	= $('#btaplic3','#'+frmTipo3);
		cBtaplic5	= $('#btaplic5','#'+frmTipo3);
		cBtaplic7	= $('#btaplic7','#'+frmTipo3);
		cBtaplic8	= $('#btaplic8','#'+frmTipo3);
		cTpaplic1	= $('#tpaplic1','#'+frmTipo3);
		cTpaplic3	= $('#tpaplic3','#'+frmTipo3);
		cTpaplic5	= $('#tpaplic5','#'+frmTipo3);
		cTpaplic7	= $('#tpaplic7','#'+frmTipo3);
		cTpaplic8	= $('#tpaplic8','#'+frmTipo3);

		cBtaplic1.css({'width':'80px','cursor':'pointer'});
		cBtaplic3.css({'width':'80px','cursor':'pointer'});
		cBtaplic5.css({'width':'80px','cursor':'pointer'});
		cBtaplic7.css({'width':'80px','cursor':'pointer'});
		cBtaplic8.css({'width':'80px','cursor':'pointer'});
		cTpaplic1.css({'width':'433px'});
		cTpaplic3.css({'width':'433px'});
		cTpaplic5.css({'width':'433px'});
		cTpaplic7.css({'width':'433px'});
		cTpaplic8.css({'width':'433px'});

		cNrctagar.habilitaCampo();
		cDtmvtolt.val('');
	}	

	hideMsgAguardo();
	layoutPadrao();
	return false;
}

function formataTipo4() {

	var frmTipo4 = 'frmTipo';

	highlightObjFocus( $("#frmTipo") );

	// label
	rDscpfavl	= $('label[for="dscpfavl"]','#'+frmTipo4);
	rNmdavali	= $('label[for="nmdavali"]','#'+frmTipo4);
	rDtmvtolt	= $('label[for="dtmvtolt"]','#'+frmTipo4);

	rDscpfavl.addClass('rotulo').css({'width':'160px'});
	rNmdavali.addClass('rotulo').css({'width':'160px'});
	rDtmvtolt.addClass('rotulo').css({'width':'160px'});

	// campo
	cDscpfavl	= $('#dscpfavl','#'+frmTipo4);
	cNmdavali	= $('#nmdavali','#'+frmTipo4);
	cDtmvtolt	= $('#dtmvtolt','#'+frmTipo4);

	cDscpfavl.css({'width':'120px'});
	cNmdavali.css({'width':'260px'});
	cDtmvtolt.addClass('data').css({'width':'120px'});

	$('select, input', '#'+frmTipo4).desabilitaCampo();

	// centraliza a divRotina
	$('#divRotina').css({'width':'475px'});
	$('#divConteudo').css({'width':'450px'});
	$('#divRotina').centralizaRotinaH();

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );

	return false;
}

function formataTipo5() {

	var frmTipo5 = 'frmTipo';
	var tabTipo5 = 'tabTipo';

	highlightObjFocus( $("#frmTipo") );
	highlightObjFocus( $("#tabTipo") );

	rNrdplaca	= $('label[for="nrdplaca"]','#'+frmTipo5);
	rUfdplaca	= $('label[for="ufdplaca"]','#'+frmTipo5);
	rDscorbem	= $('label[for="dscorbem"]','#'+frmTipo5);
	rNranobem	= $('label[for="nranobem"]','#'+frmTipo5);
	rNrmodbem	= $('label[for="nrmodbem"]','#'+frmTipo5);
	rUflicenc	= $('label[for="uflicenc"]','#'+frmTipo5);
    rNrcpfcgc	= $('label[for="nrcpfcgc"]','#'+frmTipo5);

	cNrdplaca	= $('#nrdplaca','#'+frmTipo5);
	cUfdplaca	= $('#ufdplaca','#'+frmTipo5);
	cDscorbem	= $('#dscorbem','#'+frmTipo5);
	cNranobem	= $('#nranobem','#'+frmTipo5);
	cNrmodbem	= $('#nrmodbem','#'+frmTipo5);
	cUflicenc	= $('#uflicenc','#'+frmTipo5);
    cNrcpfcgc   = $('#nrcpfcgc','#'+frmTipo5);

	if ( cddopcao == 'X' ) {

		// tabela
		var divRegistro = $('div.divRegistros', '#'+tabTipo5);
		var tabela      = $('table', divRegistro );

		$('#'+tabTipo5).css({'margin-top':'5px'});
		divRegistro.css({'height':'150px','padding-bottom':'2px'});

		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '55px';
		arrayLargura[1] = '190px';
		arrayLargura[2] = '80px';
		arrayLargura[3] = '50px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'center';

		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

		// centraliza a divRotina
		$('#divRotina').css({'width':'610px'});
		$('#divConteudo').css({'width':'590px'});

		/********************
		 FORMATA COMPLEMENTO
		*********************/
		// complemento linha 1
		var linha1  = $('ul.complemento', '#linha1').css({'margin-left':'1px','width':'99.5%'});

		$('li:eq(0)', linha1).addClass('txtNormalBold').css({'width':'8%','text-align':'right'});
		$('li:eq(1)', linha1).addClass('txtNormal').css({'width':'12%'});
		$('li:eq(2)', linha1).addClass('txtNormalBold').css({'width':'15%','text-align':'right'});
		$('li:eq(3)', linha1).addClass('txtNormal').css({'width':'12%'});
		$('li:eq(4)', linha1).addClass('txtNormalBold').css({'width':'15%','text-align':'right'});
		$('li:eq(5)', linha1).addClass('txtNormal');

		// complemento linha 2
		var linha2  = $('ul.complemento', '#linha2').css({'clear':'both','border-top':'0','width':'99.5%'});

		$('li:eq(0)', linha2).addClass('txtNormalBold').css({'width':'8%','text-align':'right'});
		$('li:eq(1)', linha2).addClass('txtNormal').css({'width':'12%'});
		$('li:eq(2)', linha2).addClass('txtNormalBold').css({'width':'15%','text-align':'right'});
		$('li:eq(3)', linha2).addClass('txtNormal').css({'width':'12%'});
		$('li:eq(4)', linha2).addClass('txtNormalBold').css({'width':'15%','text-align':'right'});
		$('li:eq(5)', linha2).addClass('txtNormal');

		/********************
		  EVENTO COMPLEMENTO
		*********************/
		// seleciona o registro que é clicado
		$('table > tbody > tr', divRegistro).click( function() {
			selecionaComplemento($(this));
		});

		// seleciona o registro que é focado
		$('table > tbody > tr', divRegistro).focus( function() {
			selecionaComplemento($(this));
		});

		$('table > tbody > tr:eq(0)', divRegistro).click();

	} else {

		// label
		rDtmvtolt	= $('label[for="dtmvtolt"]','#'+frmTipo5);
		rDsbemfin	= $('label[for="dsbemfin"]','#'+frmTipo5);
		rNrrenava	= $('label[for="nrrenava"]','#'+frmTipo5);
		rTpchassi	= $('label[for="tpchassi"]','#'+frmTipo5);
		rDschassi	= $('label[for="dschassi"]','#'+frmTipo5);
		rNrdplaca	= $('label[for="nrdplaca"]','#'+frmTipo5);
		rUfdplaca	= $('label[for="ufdplaca"]','#'+frmTipo5);
		rDscorbem	= $('label[for="dscorbem"]','#'+frmTipo5);
		rNranobem	= $('label[for="nranobem"]','#'+frmTipo5);
		rNrmodbem	= $('label[for="nrmodbem"]','#'+frmTipo5);
		rUflicenc	= $('label[for="uflicenc"]','#'+frmTipo5);
        rNrcpfcgc	= $('label[for="nrcpfcgc"]','#'+frmTipo5);

		rDtmvtolt.addClass('rotulo').css({'width':'130px'});
		rDsbemfin.addClass('rotulo').css({'width':'130px'});
		rNrrenava.addClass('rotulo').css({'width':'130px'});
		rTpchassi.addClass('rotulo').css({'width':'130px'});
		rDschassi.addClass('rotulo').css({'width':'130px'});
		rNrdplaca.addClass('rotulo').css({'width':'130px'});
		rUfdplaca.addClass('rotulo').css({'width':'130px'});
		rDscorbem.addClass('rotulo').css({'width':'130px'});
		rNranobem.addClass('rotulo').css({'width':'130px'});
		rNrmodbem.addClass('rotulo').css({'width':'130px'});
		rUflicenc.addClass('rotulo').css({'width':'130px'});
        rNrcpfcgc.addClass('rotulo').css({'width':'130px'});

		// campo
		cDtmvtolt	= $('#dtmvtolt','#'+frmTipo5);
		cDsbemfin	= $('#dsbemfin','#'+frmTipo5);
		cNrrenava	= $('#nrrenava','#'+frmTipo5);
		cTpchassi	= $('#tpchassi','#'+frmTipo5);
		cDschassi	= $('#dschassi','#'+frmTipo5);
		cNrdplaca	= $('#nrdplaca','#'+frmTipo5);
		cUfdplaca	= $('#ufdplaca','#'+frmTipo5);
		cDscorbem	= $('#dscorbem','#'+frmTipo5);
		cNranobem	= $('#nranobem','#'+frmTipo5);
		cNrmodbem	= $('#nrmodbem','#'+frmTipo5);
		cUflicenc	= $('#uflicenc','#'+frmTipo5);
        cNrcpfcgc   = $('#nrcpfcgc','#'+frmTipo5);

		cDtmvtolt.addClass('data').css({'width':'140px'});
		cDsbemfin.css({'width':'220px'}).attr('maxlength','40');
		cNrrenava.addClass('renavan').css({'width':'140px'});
		cTpchassi.addClass('inteiro').css({'width':'40px'}).attr('maxlength','1');
		cDschassi.css({'width':'140px'}).attr('maxlength','20');
		cNrdplaca.addClass('placa').css({'width':'140px'});
		cUfdplaca.css({'width':'30px'}).attr('maxlength','2');
		cDscorbem.css({'width':'220px'}).attr('maxlength','25');
		cNranobem.addClass('inteiro').css({'width':'40px'}).attr('maxlength','4');
		cNrmodbem.addClass('inteiro').css({'width':'40px'}).attr('maxlength','4');
		cUflicenc.css({'width':'40px'}).attr('maxlength','2');
        cNrcpfcgc.addClass('inteiro').css({'width':'140px'}).attr('maxlength','14');

		if ( cddopcao == 'I' ) {
			$('select, input', '#'+frmTipo5).habilitaCampo();
			cDtmvtolt.val('').desabilitaCampo();
			cDtmvtolt.focus();
			trocaBotao( 'gravar' );

		} else {

			$('select, input', '#'+frmTipo5).desabilitaCampo();
		}

		cDsbemfin.unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 ) { cNrrenava.focus(); return false; }
		});

		cNrrenava.unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 ) { cTpchassi.focus(); return false; }
		});

		cTpchassi.unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 ) { cDschassi.focus(); return false; }
		});

		cDschassi.unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 ) { cNrdplaca.focus(); return false; }
		});

        // Se pressionar alguma tecla no campo Chassi/N.Serie, verificar a tecla pressionada e toda a devida ação
        cDschassi.unbind('keydown').bind('keydown', function(event) {
			
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
        });

		//Remover caracteres especiais
		cDschassi.unbind('keyup').bind('keyup', function(e){
			var re = /[^\w\s]/gi;
			
			if(re.test(cDschassi.val())){
				cDschassi.val(cDschassi.val().replace(re, ''));
			}			
			
			re = /[\Q\q\I\i\O\o\_]/g;
			
			if(re.test(cDschassi.val())){
				cDschassi.val(cDschassi.val().replace(re, ''));
			}			
			
			re = / /g;
			
			if(re.test(cDschassi.val())){
				cDschassi.val(cDschassi.val().replace(re, ''));
			}						
		});
		
		cDschassi.unbind('blur').bind('blur', function(){
			cDschassi.val(cDschassi.val().replace(/[^\w\s]/gi, ''));
			cDschassi.val(cDschassi.val().replace(/[\Q\q\I\i\O\o\_]/g, ''));
			cDschassi.val(cDschassi.val().replace(/ /g,''));			
		});
		
		cNrdplaca.unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 ) { cUfdplaca.focus(); return false; }
		});

		cUfdplaca.unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 ) { cDscorbem.focus(); return false; }
		});

		cDscorbem.unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 ) { cNranobem.focus(); return false; }
		});

		cNranobem.unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 ) { cNrmodbem.focus(); return false; }
		});

		cNrmodbem.unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 ) { cUflicenc.focus(); return false; }
		});

        cUflicenc.unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 ) { cNrcpfcgc.focus(); return false; }
		});

        cNrcpfcgc.unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }

			if ( e.keyCode == 13 ) { manterRotina('VD'); return false; }
		});

		// centraliza a divRotina
		//$('#divRotina').css({'width':'400px'});
		//$('#divConteudo').css({'width':'375px'});

        $('#divRotina').css({'width':'550px'});
		$('#divConteudo').css({'width':'500px'});


	}

	$('#divRotina').centralizaRotinaH();

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	layoutPadrao();

	return false;
}

function formataTipo6() {

	var frmTipo6 = 'frmTipo';

	highlightObjFocus( $("#frmTipo") );

	// label
	rDtmvtolt	= $('label[for="dtmvtolt"]','#'+frmTipo6);
	rNmdgaran	= $('label[for="nmdgaran"]','#'+frmTipo6);
	rNrcpfgar	= $('label[for="nrcpfgar"]','#'+frmTipo6);
	rNrdocgar	= $('label[for="nrdocgar"]','#'+frmTipo6);
	rDsbemfin	= $('label[for="dsbemfin"]','#'+frmTipo6);
	rNrrenava	= $('label[for="nrrenava"]','#'+frmTipo6);
	rTpchassi	= $('label[for="tpchassi"]','#'+frmTipo6);
	rDschassi	= $('label[for="dschassi"]','#'+frmTipo6);
	rNrdplaca	= $('label[for="nrdplaca"]','#'+frmTipo6);
	rUfdplaca	= $('label[for="ufdplaca"]','#'+frmTipo6);
	rDscorbem	= $('label[for="dscorbem"]','#'+frmTipo6);
	rNranobem	= $('label[for="nranobem"]','#'+frmTipo6);
	rNrmodbem	= $('label[for="nrmodbem"]','#'+frmTipo6);
	rUflicenc	= $('label[for="uflicenc"]','#'+frmTipo6);

	rDtmvtolt.addClass('rotulo').css({'width':'170px'});
	rNmdgaran.addClass('rotulo').css({'width':'170px'});
	rNrcpfgar.addClass('rotulo').css({'width':'170px'});
    rNrdocgar.addClass('rotulo').css({'width':'170px'});
	rDsbemfin.addClass('rotulo').css({'width':'170px'});
	rNrrenava.addClass('rotulo').css({'width':'170px'});
	rTpchassi.addClass('rotulo').css({'width':'170px'});
	rDschassi.addClass('rotulo-linha').css({'width':'50px'});
	rNrdplaca.addClass('rotulo').css({'width':'170px'});
	rUfdplaca.addClass('rotulo').css({'width':'170px'});
	rDscorbem.addClass('rotulo').css({'width':'170px'});
	rNranobem.addClass('rotulo').css({'width':'170px'});
	rNrmodbem.addClass('rotulo-linha').css({'width':'55px'});
	rUflicenc.addClass('rotulo-linha').css({'width':'72px'});

	// campo
	cDtmvtolt	= $('#dtmvtolt','#'+frmTipo6);
	cNmdgaran	= $('#nmdgaran','#'+frmTipo6);
	cNrcpfgar	= $('#nrcpfgar','#'+frmTipo6);
	cNrdocgar	= $('#nrdocgar','#'+frmTipo6);
	cDsbemfin	= $('#dsbemfin','#'+frmTipo6);
	cNrrenava	= $('#nrrenava','#'+frmTipo6);
	cTpchassi	= $('#tpchassi','#'+frmTipo6);
	cDschassi	= $('#dschassi','#'+frmTipo6);
	cNrdplaca	= $('#nrdplaca','#'+frmTipo6);
	cUfdplaca	= $('#ufdplaca','#'+frmTipo6);
	cDscorbem	= $('#dscorbem','#'+frmTipo6);
	cNranobem	= $('#nranobem','#'+frmTipo6);
	cNrmodbem	= $('#nrmodbem','#'+frmTipo6);
	cUflicenc	= $('#uflicenc','#'+frmTipo6);

	cDtmvtolt.addClass('data').css({'width':'120px'});
	cNmdgaran.css({'width':'320px'});
	cNrcpfgar.css({'width':'120px'});
    cNrdocgar.css({'width':'120px'});
	cDsbemfin.css({'width':'320px'});
	cNrrenava.css({'width':'120px'});
	cTpchassi.css({'width':'120px'});
	cDschassi.css({'width':'143px'});
	cNrdplaca.css({'width':'120px'});
	cUfdplaca.css({'width':'120px'});
	cDscorbem.css({'width':'120px'});
	cNranobem.css({'width':'60px'});
	cNrmodbem.css({'width':'60px'});
	cUflicenc.css({'width':'60px'});

	$('select, input', '#'+frmTipo6).desabilitaCampo();

	// centraliza a divRotina
	$('#divRotina').css({'width':'550px'});
	$('#divConteudo').css({'width':'525px'});
	$('#divRotina').centralizaRotinaH();

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );

	return false;
}

function formataTipo7() {

	var frmTipo7 = 'frmTipo';
	var espaco	 = 30;

	highlightObjFocus( $("#frmTipo") );

	if ( $.browser.msie ) {
		espaco = 25;
	}

	// label

	rDtmvtolt	= $('label[for="dtmvtolt"]','#'+frmTipo7);
	rNrcpfgar	= $('label[for="nrcpfgar"]','#'+frmTipo7);
	rQuebrali	= $('label[for="quebrali"]','#'+frmTipo7);
	rEspacos1	= $('label[for="espacos1"]','#'+frmTipo7);
	rEspacos2	= $('label[for="espacos2"]','#'+frmTipo7);
	rEspacos3	= $('label[for="espacos3"]','#'+frmTipo7);
	rEspacos4	= $('label[for="espacos4"]','#'+frmTipo7);
	rEspacos5	= $('label[for="espacos5"]','#'+frmTipo7);

	rDtmvtolt.addClass('rotulo').css({'width':'123px'});
	rNrcpfgar.addClass('rotulo-linha').css({'width':'138px'});
	rQuebrali.addClass('rotulo');
	rEspacos1.css({'width':espaco+'px'});
	rEspacos2.css({'width':espaco+'px'});
	rEspacos3.css({'width':espaco+'px'});
	rEspacos4.css({'width':espaco+'px'});
	rEspacos5.css({'width':espaco+'px'});

	// campo
	cDtmvtolt	= $('#dtmvtolt','#'+frmTipo7);
	cNrcpfgar	= $('#nrcpfgar','#'+frmTipo7);
	cNrpromi1	= $('#nrpromi1','#'+frmTipo7);
	cVlpromi1	= $('#vlpromi1','#'+frmTipo7);
	cNrpromi2	= $('#nrpromi2','#'+frmTipo7);
	cVlpromi2	= $('#vlpromi2','#'+frmTipo7);
	cNrpromi3	= $('#nrpromi3','#'+frmTipo7);
	cVlpromi3	= $('#vlpromi3','#'+frmTipo7);
	cNrpromi4	= $('#nrpromi4','#'+frmTipo7);
	cVlpromi4	= $('#vlpromi4','#'+frmTipo7);
	cNrpromi5	= $('#nrpromi5','#'+frmTipo7);
	cVlpromi5	= $('#vlpromi5','#'+frmTipo7);
	cNrpromi6	= $('#nrpromi6','#'+frmTipo7);
	cVlpromi6	= $('#vlpromi6','#'+frmTipo7);
	cNrpromi7	= $('#nrpromi7','#'+frmTipo7);
	cVlpromi7	= $('#vlpromi7','#'+frmTipo7);
	cNrpromi8	= $('#nrpromi8','#'+frmTipo7);
	cVlpromi8	= $('#vlpromi8','#'+frmTipo7);
	cNrpromi9	= $('#nrpromi9','#'+frmTipo7);
	cVlpromi9	= $('#vlpromi9','#'+frmTipo7);
	cNrprom10	= $('#nrprom10','#'+frmTipo7);
	cVlprom10	= $('#vlprom10','#'+frmTipo7);

	cDtmvtolt.css({'width':'105px'});
	cNrcpfgar.addClass('cpf').css({'width':'105px'});
	cNrpromi1.css({'width':'150px'}).attr('maxlength','20');
    cVlpromi1.addClass('monetario').css({'width':'95px'});
	cNrpromi2.css({'width':'150px'}).attr('maxlength','20');
	cVlpromi2.addClass('monetario').css({'width':'95px'});
	cNrpromi3.css({'width':'150px'}).attr('maxlength','20');
	cVlpromi3.addClass('monetario').css({'width':'95px'});
	cNrpromi4.css({'width':'150px'}).attr('maxlength','20');
	cVlpromi4.addClass('monetario').css({'width':'95px'});
	cNrpromi5.css({'width':'150px'}).attr('maxlength','20');
	cVlpromi5.addClass('monetario').css({'width':'95px'});
	cNrpromi6.css({'width':'150px'}).attr('maxlength','20');
	cVlpromi6.addClass('monetario').css({'width':'95px'});
	cNrpromi7.css({'width':'150px'}).attr('maxlength','20');
	cVlpromi7.addClass('monetario').css({'width':'95px'});
	cNrpromi8.css({'width':'150px'}).attr('maxlength','20');
	cVlpromi8.addClass('monetario').css({'width':'95px'});
	cNrpromi9.css({'width':'150px'}).attr('maxlength','20');
	cVlpromi9.addClass('monetario').css({'width':'95px'});
	cNrprom10.css({'width':'150px'}).attr('maxlength','20');
	cVlprom10.addClass('monetario').css({'width':'95px'});

	if ( cddopcao == 'I' ) {
		$('select, input', '#'+frmTipo7).habilitaCampo();
		cDtmvtolt.val('').desabilitaCampo();
		cDtmvtolt.focus();
		trocaBotao( 'gravar' );
	} else {
		$('select, input', '#'+frmTipo7).desabilitaCampo();
	}

	// centraliza a divRotina
	$('#divRotina').css({'width':'575px'});
	$('#divConteudo').css({'width':'550px'});
	$('#divRotina').centralizaRotinaH();

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	layoutPadrao();

	//////
	cNrcpfgar.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cNrpromi1.focus(); return false; }
	});

	cNrpromi1.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cVlpromi1.focus();	return false; }
	});

	cVlpromi1.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cNrpromi2.focus();	return false; }
	});

	cNrpromi2.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cVlpromi2.focus();	return false; }
	});

	cVlpromi2.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cNrpromi3.focus();	return false; }
	});

	cNrpromi3.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cVlpromi3.focus();	return false; }
	});

	cVlpromi3.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cNrpromi4.focus();	return false; }
	});

	cNrpromi4.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cVlpromi4.focus();	return false; }
	});

	cVlpromi4.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cNrpromi5.focus();	return false; }
	});

	cNrpromi5.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cVlpromi5.focus();	return false; }
	});

	cVlpromi5.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cNrpromi6.focus();	return false; }
	});

	cNrpromi6.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cVlpromi6.focus();	return false; }
	});

	cVlpromi6.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cNrpromi7.focus();	return false; }
	});

	cNrpromi7.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cVlpromi7.focus();	return false; }
	});

	cVlpromi7.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cNrpromi8.focus();	return false; }
	});

	cNrpromi8.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cVlpromi8.focus();	return false; }
	});

	cVlpromi8.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cNrpromi9.focus();	return false; }
	});

	cNrpromi9.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cVlpromi9.focus();	return false; }
	});

	cVlpromi9.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cNrprom10.focus();	return false; }
	});

	cNrprom10.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cVlprom10.focus();	return false; }
	});

	cVlprom10.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { manterRotina('VD'); return false; }
	});

	$('#nrcpfgar','#'+frmTipo7).focus();
	//////

	return false;
}

function formataTipo8() {

	var frmTipo8 = 'frmTipo';

	highlightObjFocus( $("#frmTipo") );

	// label
	rNrcpfgar	= $('label[for="nrcpfgar"]','#'+frmTipo8);
	rVlpromis	= $('label[for="vlpromis"]','#'+frmTipo8);
	rDtmvtolt	= $('label[for="dtmvtolt"]','#'+frmTipo8);

	rNrcpfgar.addClass('rotulo').css({'width':'160px'});
	rVlpromis.addClass('rotulo').css({'width':'160px'});
	rDtmvtolt.addClass('rotulo').css({'width':'160px'});

	// campo
	cNrcpfgar	= $('#nrcpfgar','#'+frmTipo8);
	cVlpromis	= $('#vlpromis','#'+frmTipo8);
	cDtmvtolt	= $('#dtmvtolt','#'+frmTipo8);

	cNrcpfgar.addClass('cpf').css({'width':'120px'});
	cVlpromis.addClass('monetario').css({'width':'120px'});
	cDtmvtolt.addClass('data').css({'width':'120px'});

	if ( cddopcao == 'I' ) {
		$('select, input', '#'+frmTipo8).habilitaCampo();
		cDtmvtolt.val('').desabilitaCampo();
		cDtmvtolt.focus();
		trocaBotao( 'gravar' );
	} else {
		$('select, input', '#'+frmTipo8).desabilitaCampo();
	}

	// centraliza a divRotina
	$('#divRotina').css({'width':'375px'});
	$('#divConteudo').css({'width':'350px'});
	$('#divRotina').centralizaRotinaH();

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	layoutPadrao();

	cNrcpfgar.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { cVlpromis.focus(); return false; }
	});

	cVlpromis.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }

		if ( e.keyCode == 13 ) { manterRotina('VD'); return false; }
	});

	cNrcpfgar.focus();
	return false;
}


function selecionaComplemento(tr) {

	$('#idseqbem','#'+frmCab).val( $('#idseqbem', tr).val() );
	$('#nrdplaca','.complemento').html( $('#nrdplaca', tr).val() );
	$('#ufdplaca','.complemento').html( $('#ufdplaca', tr).val() );
	$('#dscorbem','.complemento').html( $('#dscorbem', tr).val() );
	$('#nranobem','.complemento').html( $('#nranobem', tr).val() );
	$('#nrmodbem','.complemento').html( $('#nrmodbem', tr).val() );
	$('#uflicenc','.complemento').html( $('#uflicenc', tr).val() );
	return false;
}

function selecionaTipo() {

	if ( cddopcao == 'I' ) {
		$('#cdaditiv option', '#'+frmCab ).each(function () {
			$(this).removeProp('selected');
		});

		$("#cdaditiv option[value='"+cCdaditix.val()+"']",'#'+frmCab).prop('selected',true);
	}

}


function mostraAplicacao(tpaplica) {

	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/aditiv/aplicacao.php',
		data: {
			redirect: 'html_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			buscaAplicacao(tpaplica);
			return false;
		}
	});
	return false;

}

function buscaAplicacao(tpaplica) {

	var nrctagar = normalizaNumero( $('#nrctagar', '#frmTipo').val() );	
	var tpaplic1 = $('#tpaplic1', '#frmTipo').val();
	var tpaplic3 = $('#tpaplic3', '#frmTipo').val();
	var tpaplic5 = $('#tpaplic5', '#frmTipo').val();
	var tpaplic7 = $('#tpaplic7', '#frmTipo').val();
	var tpaplic8 = $('#tpaplic8', '#frmTipo').val();
		
	showMsgAguardo('Aguarde, buscando aplicação ...');

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/aditiv/busca_aplicacao.php',
		data: {
			cddopcao : cddopcao,
			nrdconta : nrdconta,
            tpctrato : tpctrato,
			nrctremp : nrctremp,
			nraditiv : nraditiv,
			cdaditiv : cdaditiv,
			tpaplica : tpaplica,
			nrctagar : nrctagar,
			tpaplic1 : tpaplic1,
			tpaplic3 : tpaplic3,
			tpaplic5 : tpaplic5,
			tpaplic7 : tpaplic7,
			tpaplic8 : tpaplic8,
			redirect : 'script_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divAplicacao', '#divUsoGenerico').html(response);
					exibeRotina( $('#divUsoGenerico') );
					formataAplicacao();
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}
	});
	return false;
}

function formataAplicacao() {

	// tabela
	var divRegistro = $('div.divRegistros', '#tabAplicacao');
	var tabela      = $('table', divRegistro );

	$('#tabAplicacao').css({'margin-top':'5px'});
	divRegistro.css({'height':'100px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '20px';
	arrayLargura[1] = '70px';
	arrayLargura[2] = '150px';
	arrayLargura[3] = '80px';
	arrayLargura[4] = '70px';
	arrayLargura[5] = '75px';
	arrayLargura[6] = '63px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'left';
	arrayAlinha[6] = 'right';
	arrayAlinha[7] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	// centraliza a divRotina
	$('#divUsoGenerico').css({'width':'725px'});
	$('#divConteudo', '#divUsoGenerico').css({'width':'750px'});
	$('#divUsoGenerico').centralizaRotinaH();
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divUsoGenerico') );
	return false;

}

function continuarAplicacao(tp) {

	var dsaplica = '';
	var dstipapl = '';

	// percorre todos os contratos que estão selecionados
	$('input:checkbox:checked', '#tabAplicacao' ).each(function () {
		var d = $(this).val().split('-');
		var a = new Array();

		a['tpaplica'] = d[0];
		a['nraplica'] = d[1];
		a['tpproapl'] = d[2];

		dsaplica = (dsaplica != '') ? dsaplica + '/' + a['nraplica'] : a['nraplica'];
		dstipapl = (dstipapl != '') ? dstipapl + '/' + a['tpproapl'] : a['tpproapl'];
	});

	// mostra os contratos selecionados
	$('#tpaplic'+tp, '#frmTipo').val(dsaplica);
	// adiciona input hidden com os tipos de aplicação (antigos/novos)
	$('#tpproap'+tp, '#frmTipo').remove();
	$('#frmTipo').append('<input type="hidden" id="tpproap'+tp+'" />');
	$('#tpproap'+tp, '#frmTipo').val(dstipapl);

	// adiciona o botao continuar caso tenha alguma contrato selecionado
	var tpaplic1 = $('#tpaplic1', '#frmTipo').val();
	var tpaplic3 = $('#tpaplic3', '#frmTipo').val();
	var tpaplic5 = $('#tpaplic5', '#frmTipo').val();
	var tpaplic7 = $('#tpaplic7', '#frmTipo').val();
	var tpaplic8 = $('#tpaplic8', '#frmTipo').val();
	
	$('#btSalvar','#divRotina').remove();

	if (tpaplic1!='' || tpaplic3!='' || tpaplic5!='' || tpaplic7!='' || tpaplic8!='') {
		$('#divBotoes','#divRotina').append('<a href="#" class="botao" id="btSalvar" onClick="manterRotina(\'VD\'); return false;">Continuar</a>');

	}
	fechaRotina($('#divUsoGenerico'));
	$('#divUsoGenerico').html('');
	bloqueiaFundo( $('#divRotina') );
	return false;
}


// contrato
function mostraContrato() {
    var s_tpctrato = normalizaNumero($('#tpctrato','#frmCab').val());
    var s_nrdconta = normalizaNumero($('#nrdconta','#frmCab').val());

    // Se for Emprestimo/Financiamento
    if (s_tpctrato == 90) {
        showMsgAguardo('Aguarde, buscando ...');

        // Executa script de confirmação através de ajax
        $.ajax({
            type: 'POST',
            dataType: 'html',
            url: UrlSite + 'telas/aditiv/contrato.php',
            data: {
                redirect: 'html_ajax'
                },
            error: function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
                showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
            },
            success: function(response) {
                $('#divRotina').html(response);
                buscaContrato();
                return false;
            }
        });
    } else {
        // Definicao dos filtros
        var filtros = "Contrato;nrctrlim;120px;S;;;|;vllimite;;N;;N;|;dtinivig;;N;;N;|;dtfimvig;;N;;N;|;cddlinha;;N;;N;|;nrdconta;;;"+s_nrdconta+";N|;tpctrlim;;;"+s_tpctrato+";N";

        // Campos que serao exibidos na tela
        var colunas = 'Contrato;nrctrlim;20%;right|Limite;vllimite;20%;right|Data Ini.;dtinivig;20%;center;|Data Fim;dtfimvig;20%;center|Linha;cddlinha;20%;center';

        // Exibir a pesquisa
        mostraPesquisa("ZOOM0001", "ZOOM_BUSCA_LIMITE_CREDITO", "Limites de Cr&eacute;dito", "30", filtros, colunas, '', '$(\'#nrctremp\',\'#frmCab\').val($(\'#nrctrlim\',\'#frmCab\').val()).focus();', 'frmCab');
    }

	return false;

}

function buscaContrato() {

	showMsgAguardo('Aguarde, buscando ...');

	var nrdconta = normalizaNumero( cNrdconta.val() );

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/aditiv/busca_contrato.php',
		data: {
			nrdconta: nrdconta,
			redirect: 'script_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {

			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudo').html(response);
					exibeRotina($('#divRotina'));
					formataContrato();
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}
	});
	return false;
}

function formataContrato() {

	var divRegistro = $('div.divRegistros','#divContrato');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

	divRegistro.css({'height':'120px','width':'500px'});

	var ordemInicial = new Array();
	ordemInicial = [[0,0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '60px';
	arrayLargura[1] = '62px';
	arrayLargura[2] = '80px';
	arrayLargura[3] = '60px';
	arrayLargura[4] = '80px';
	arrayLargura[5] = '38px';


	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';

	var metodoTabela = 'selecionaContrato();';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );

	return false;
}

function selecionaContrato() {

	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {

		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cNrctremp.val( $('#nrctremp', $(this) ).val() );
			}
		});
	}

	fechaRotina($('#divRotina'));
	return false;

}


// senha
function mostraSenha() {

	showMsgAguardo('Aguarde, abrindo ...');

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/aditiv/senha.php',
		data: {
			redirect: 'html_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			buscaSenha();
			return false;
		}
	});
	return false;

}

function buscaSenha() {

	hideMsgAguardo();

	showMsgAguardo('Aguarde, abrindo ...');

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/aditiv/form_senha.php',
		data: {
			redirect: 'script_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {

			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudoSenha').html(response);
					exibeRotina($('#divUsoGenerico'));
					formataSenha();
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}
	});
	return false;
}

function formataSenha() {

	rOperador 	= $('label[for="operauto"]', '#frmSenha');
	rSenha		= $('label[for="codsenha"]', '#frmSenha');

	rOperador.addClass('rotulo').css({'width':'135px'});
	rSenha.addClass('rotulo').css({'width':'135px'});

	cOperador	= $('#operauto', '#frmSenha');
	cSenha		= $('#codsenha', '#frmSenha');

	cOperador.addClass('campo').css({'width':'100px'}).attr('maxlength','10').focus();
    cSenha.addClass('campo').css({'width':'100px'}).attr('maxlength','10');



	// centraliza a divRotina
	$('#divUsoGenerico').css({'width':'355px'});
	$('#divConteudoSenha').css({'width':'330px', 'height':'110px'});
	$('#divUsoGenerico').centralizaRotinaH();

	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo( $('#divUsoGenerico') );
	return false;
}

function validarSenha() {

	hideMsgAguardo();

	// Situacao
	operauto 		= $('#operauto','#frmSenha').val();
	var codsenha 	= $('#codsenha','#frmSenha').val();

	showMsgAguardo( 'Aguarde, validando ...' );

	$.ajax({
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/aditiv/valida_senha.php',
			data: {
				operauto	: operauto,
				codsenha	: codsenha,
				redirect	: 'script_ajax'
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		});

	return false;

}


// substituir bem
function substituirBem( i ) {

	// verifica se tem bem para substituir,
	if ( arrayAditiv.length > 0 ) {

		// pega o id do bem
		i = parseInt(i);

		// pergunta se quer substituir o bem
		if ( i < arrayAditiv.length ) {
			var j = i + 1;
			$('#idseqbem', '#'+frmCab).val( arrayAditiv[i]['idseqbem'] );
			showConfirmacao('EXCLUIR BEM ANTERIOR de Nro ' + arrayAditiv[i]['nrsequen'] + ' ' + arrayAditiv[i]['dsbemfin'] + ' ?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina(\'GD\');','substituirBem('+j+');','sim.gif','nao.gif');

		// se nao for substituir por nenhum, chama o grava
		} else {
			$('#idseqbem', '#'+frmCab).val('');
			manterRotina('GD');
		}

	// se nao tiver nenhum bem para substituir chama o grava
	} else {
		$('#idseqbem', '#'+frmCab).val('');
		manterRotina('GD');
	}

	return false;
}


// botoes
function btnVoltar() {
	estadoInicial();

	$("#cdaditiv option[value='1']",'#'+frmCab).prop('selected',false);
	$("#cdaditiv option[value='2']",'#'+frmCab).prop('selected',false);
	$("#cdaditiv option[value='3']",'#'+frmCab).prop('selected',false);
	$("#cdaditiv option[value='4']",'#'+frmCab).prop('selected',false);
	$("#cdaditiv option[value='5']",'#'+frmCab).prop('selected',false);
	$("#cdaditiv option[value='6']",'#'+frmCab).prop('selected',false);
	$("#cdaditiv option[value='7']",'#'+frmCab).prop('selected',false);
	$("#cdaditiv option[value='8']",'#'+frmCab).prop('selected',false);
	$("#cdaditiv option[value='9']",'#'+frmCab).prop('selected',false);
	return false;
}

function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }

	if ( cCddopcao.hasClass('campo') ) {
		btnOK1.click();

	} else if ( cNrdconta.hasClass('campo') ) {
		btnOK2.click();

	} else if ( $('#divRotina').css('display') != 'hidden' ) {
		manterRotina('VD');
	}

	return false;

}

function trocaBotao( acao ) {

	$('#divBotoes','#divRotina').html('');

	if ( acao == 'gravar' ) {
		$('#divBotoes','#divRotina').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;">Voltar</a>');
		$('#divBotoes','#divRotina').append('<a href="#" class="botao" id="btSalvar" onClick="manterRotina(\'VD\'); return false;">Continuar</a>');
	} else if ( acao == 'imprimir' ) {
		$('#divBotoes','#divRotina').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;">Cancelar</a>');
		$('#divBotoes','#divRotina').append('<a href="#" class="botao" id="btSalvar" onClick="Gera_Impressao(); return false;">Imprimir</a>');
	}

	return false;
}


function GerenciaPesquisa(opcao) {

	if( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ){

		if (opcao == 1) {
			// Conta
			mostraPesquisaAssociado('nrdconta', 'frmCab','' );
		} else if (opcao == 2) {
			// Contrato
			mostraContrato();
		} else if (opcao == 3) {
			// Aditivo
			var nrdcont1	= normalizaNumero( cNrdconta.val() );
			var nrctrem1	= normalizaNumero( cNrctremp.val() );
            var tpctrat1    = normalizaNumero( cTpctrato.val() );
			var bo 			= 'b1wgen0059.p';
			var procedure	= 'busca_aditivos';
			var titulo      = 'Busca do Aditivo';
			var qtReg		= '30';
			var filtrosPesq	= 'Aditivo;nraditiv;30px;S;0|Tipo;cdaditiv;200px;S|;nrdconta;;;'+nrdcont1+';N|;nrctremp;;;'+nrctrem1+';N|;tpctrato;;;'+tpctrat1+';N';
			var colunas 	= 'Aditivo;nraditiv;50%;right|Tipo;cdaditiv;50%;left';
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,$('#divTela'));
			return false;
		}

		 return false;
	}
}


function buscaDadosGAROPC() {

    $('#codlinha,#vlropera','#'+frmCab).val(0);

	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/aditiv/busca_dados_garopc.php',
		data: {
            cddopcao : cddopcao,
            nrdconta : nrdconta,
            tpctrato : tpctrato,
            nrctremp : nrctremp,
			redirect : 'html_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
            eval(response);
			return false;
		}
	});
	return false;

}


function abrirTelaGAROPC() {

    showMsgAguardo('Aguarde, carregando ...');

    exibeRotina($('#divUsoGAROPC'));

    var tipaber  = cddopcao;
    var idcobert = normalizaNumero($('#idcobert','#'+frmCab).val());
    var codlinha = normalizaNumero($('#codlinha','#'+frmCab).val());
    var vlropera = $('#vlropera','#'+frmCab).val();

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/garopc/garopc.php',
        data: {
            nmdatela     : 'ADITIV',
            tipaber      : tipaber,
            nrdconta     : nrdconta,
            tpctrato     : tpctrato,
            idcobert     : idcobert,
            dsctrliq     : nrctremp,
            codlinha     : codlinha,
            vlropera     : vlropera,
            ret_nomcampo : 'idcobert',
            ret_nomformu : 'frmCab',
            ret_execfunc : 'manterRotina(\\\'GD\\\');',
            ret_errofunc : '',
            divanterior  : '',
			redirect     : 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            hideMsgAguardo();
            $('#divUsoGAROPC').html(response);
            bloqueiaFundo($('#divUsoGAROPC'));
        }
    });
}

function carregaAditivoCadastrado(par_nrdconta,par_tpctrato,par_nrctremp,par_nraditiv) {
    estadoInicial();

    $('#cddopcao', '#frmCab').val('C');
    $('#btnOK1',   '#frmCab').click();
    $('#nrdconta', '#frmCab').val(par_nrdconta);
    $('#tpctrato', '#frmCab').val(par_tpctrato);
    $('#nrctremp', '#frmCab').val(par_nrctremp);
    $('#nraditiv', '#frmCab').val(par_nraditiv);
    $('#btnOK2',   '#frmCab').click();
}