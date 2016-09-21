/*!
 * FONTE        : pesqsr.js
 * CRIAÇÃO      : Gabriel Capoia (DB1)             Úlimta alteração: 30/06/2016
 * DATA CRIAÇÃO : 12/07/2013
 * OBJETIVO     : Biblioteca de funções da tela PESQSR
 * --------------
 * ALTERAÇÕES   : 08/08/2013 - Alterações de Layout da tela e adicionado nova
							   opção (R) para geração de relatórios.
							   Inibição dos campos :
							   - Código de Pesquisa
							   - Sequencia
							   - Valor de CPMF
							   
		            19/08/2015 - Retirar campo secao (Gabriel-RKAM).

					02/06/2016 #412556
					           - Não estava mostrando os dados do cheque;
							   - Inclusão dos campos Coop, cód de pesquisa, sequência e vlr cpmf;
							   - Inclusão de máscaras de moeda, inteiro, conta e outras;
							   - nrctabb vazio;
							   - Correção do botão Voltar, que estava deixando as opções quase invisíveis (fade);
							   - Ajuste dos campos, pois estavam com alinhamentos e tamanhos desproporcionais aos seus conteúdos;
							   - Correção da sequência dos focos dos campos ao pressionar enter;
							   - Correção da ordenação das validações;
							   - Campos não estavam sendo limpos quando era trocada a opção da tela;
							   - Comentados os códigos que envolviam a geração de relatório, pois esta opção não existe na tela 
								 atual do ambiente caracter;
							   - Ajustes de css que estavam sendo feitos em js sem necessidade e em alguns casos com redundância.
							   (Carlos)

                   24/062016 - Ajustes referente a homologação da tela para liberação 
                              (Adriano - SD 412556).

                   24/062016 - Ajustes referente a homologação da área de negócio 
                              (Adriano - SD 412556).

 *
 * --------------
 */

// inicio
$(document).ready(function () {

	estadoInicial();

});


function estadoInicial() {

	formataCabecalho();

	$('#cddopcao', '#frmCab').habilitaCampo().focus().val('C');
	$('#frmFiltro').limpaFormulario();
	$('#frmFiltro').css('display', 'none');
	
	$('#divBotoes', '#divTela').css({ 'display': 'none' });
	$('#divBotoesConsulta', '#divTela').css({ 'display': 'none' });
	$('#divTabela').html('');
	
	return false;
}


function formataCabecalho() {

    $('label[for="cddopcao"]', '#frmCab').css('width', '50px').addClass('rotulo');
    $('#cddopcao', '#frmCab').css('width', '520px');
    $('#divTela').fadeTo(0, 0.1);
    removeOpacidade('divTela');
    $('#frmCab').css('display', 'block');

    highlightObjFocus($('#frmCab'));
    $('#cddopcao', '#frmCab').focus();

    //Ao pressionar botao cddopcao
    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $('#btOK', '#frmCab').click();
            return false;
        }

    });


    //Ao clicar no botao OK
    $('#btOK', '#frmCab').unbind('click').bind('click', function () {

        $('input,select').removeClass('campoErro');
        $('#cddopcao', '#frmCab').desabilitaCampo();
        $('#divBotoes', '#divTela').css({ 'display': 'block' });
        $('#divBotoesConsulta', '#divTela').css({ 'display': 'block' });

        formataFiltro();

    });

    //Ao pressionar botao OK
    $('#btOK', '#frmCab').unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {


            $('input,select').removeClass('campoErro');
            $('#cddopcao', '#frmCab').desabilitaCampo();

            formataFiltro();

        }

    });

    return false;

}


// Formata Filtro
function formataFiltro() {

    highlightObjFocus($('#frmFiltro'));

    $('#frmFiltro').css('display', 'block');
    $('#divBotoesFiltro').css('display', 'block');
    $('#divBotoes', '#divTela').css({ 'display': 'none' });

    //Consulta
	var cTodosConsulta		= $('input[type="text"],select','#frmFiltro');

	cTodosConsulta.removeClass('campoErro');

	var cCddopcao = $('#cddopcao', '#frmCab');
	var rNrdocmto = $('label[for="nrdocmto"]', '#frmFiltro');
	var rNrdctabb = $('label[for="nrdctabb"]', '#frmFiltro');
	var rCdbaninf = $('label[for="cdbaninf"]', '#frmFiltro');
	var rDtmvtolt = $('label[for="dtmvtolt"]', '#frmFiltro');
	var rNrdconta = $('label[for="nrdconta"]', '#frmFiltro');
	var rCdbccxlt = $('label[for="cdbccxlt"]', '#frmFiltro');
	var rNrdolote = $('label[for="nrdolote"]', '#frmFiltro');
	var rCdagenci = $('label[for="cdagenci"]', '#frmFiltro');
	var rVllanmto = $('label[for="vllanmto"]', '#frmFiltro');
	var rNrseqimp = $('label[for="nrseqimp"]', '#frmFiltro');
	var rCdpesqbb = $('label[for="cdpesqbb"]', '#frmFiltro');
	var rVldoipmf = $('label[for="vldoipmf"]', '#frmFiltro');

	var rNmprimtl = $('label[for="nmprimtl"]', '#frmFiltro');
	var rDsagenci = $('label[for="dsagenci"]', '#frmFiltro');
	var rCdturnos = $('label[for="cdturnos"]', '#frmFiltro');
	var rNrfonemp = $('label[for="nrfonemp"]', '#frmFiltro');
	var rNrramemp = $('label[for="nrramemp"]', '#frmFiltro');

	var rCdbanchq = $('label[for="cdbanchq"]', '#frmFiltro');
	var rCdcmpchq = $('label[for="cdcmpchq"]', '#frmFiltro');
	var rNrlotchq = $('label[for="nrlotchq"]', '#frmFiltro');
	var rSqlotchq = $('label[for="sqlotchq"]', '#frmFiltro');
	var rNrctachq = $('label[for="nrctachq"]', '#frmFiltro');

    var cDtmvtolt = $('#dtmvtolt','#frmFiltro');
	var cCdagenci = $('#cdagenci','#frmFiltro');
	var cCdbccxlt = $('#cdbccxlt','#frmFiltro');
	var cVlcheque = $('#vlcheque','#frmFiltro');
	var cNrdolote = $('#nrdolote','#frmFiltro');
	var cNrdconta = $('#nrdconta','#frmFiltro');
	var cNrdocmto = $('#nrdocmto','#frmFiltro');
	var cNrdctabb = $('#nrdctabb','#frmFiltro');
	var cCdbaninf = $('#cdbaninf','#frmFiltro');
	var cCdagechq = $('#cdagechq','#frmFiltro');
	var cVllanmto = $('#vllanmto','#frmFiltro');
	var cNrseqimp = $('#nrseqimp','#frmFiltro');
	var cCdpesqbb = $('#cdpesqbb','#frmFiltro');
	var cVldoipmf = $('#vldoipmf','#frmFiltro');
	var cNmprimtl = $('#nmprimtl','#frmFiltro');
	var cDsagenci = $('#dsagenci','#frmFiltro');
	var cCdturnos = $('#cdturnos','#frmFiltro');
	var cNrfonemp = $('#nrfonemp','#frmFiltro');
	var cNrramemp = $('#nrramemp','#frmFiltro');
	var cCdbanchq = $('#cdbanchq','#frmFiltro');
	var cCdcmpchq = $('#cdcmpchq','#frmFiltro');
	var cNrlotchq = $('#nrlotchq','#frmFiltro');
	var cSqlotchq = $('#sqlotchq','#frmFiltro');
	var cNrctachq = $('#nrctachq','#frmFiltro');

    rNrdocmto.addClass('rotulo').css({ 'margin-left': '2px', 'width': '74px' });
	rNrdctabb.addClass('rotulo-linha').css({ 'margin-left': '2px', 'width': '95px' });
	rCdbaninf.addClass('rotulo-linha').css({ 'margin-left': '2px', 'width': '90px' });

	rDtmvtolt.addClass('rotulo').css({ 'margin-left': '2px', 'width': '74px' });
	rNrdconta.addClass('rotulo-linha').css({ 'margin-left': '2px', 'width': '95px' });
	rCdbccxlt.addClass('rotulo-linha').css({ 'margin-left': '2px', 'width': '90px' });

	rNrdolote.addClass('rotulo').css({ 'margin-left': '2px', 'width': '74px' });
	rCdagenci.addClass('rotulo-linha').css({ 'margin-left': '2px', 'width': '95px' });
	rVllanmto.addClass('rotulo-linha').css({ 'margin-left': '2px', 'width': '90px' });

	rCdbanchq.addClass('rotulo').css({ 'margin-left': '2px', 'width': '50px' });
	rCdcmpchq.addClass('rotulo-linha').css({'width':'40px'});
	rNrlotchq.addClass('rotulo-linha').css({'width':'35px'});
	rSqlotchq.addClass('rotulo-linha').css({'width':'26px'});
	rNrctachq.addClass('rotulo-linha').css({'width':'40px'});

	rNrseqimp.addClass('rotulo').css({ 'width': '74px' });
	rCdpesqbb.addClass('rotulo-linha').css({ 'width': '64px' });
	rVldoipmf.addClass('rotulo').css({ 'width': '74px' });

	rNmprimtl.addClass('rotulo').css({ 'width': '74px' });
	rDsagenci.addClass('rotulo-linha').css({ 'width': '30px' });

	rCdturnos.addClass('rotulo').css({ 'width': '74px' });
	rNrfonemp.addClass('rotulo-linha').css({ 'width': '40px' });
	rNrramemp.addClass('rotulo-linha').css({ 'width': '40px' });

	cNrdocmto.css({'width':'110px'}).setMask('INTEGER','z.zzz.zzz.9','.','');
	cNrdctabb.addClass('conta').css({'width':'95px'}).setMask('INTEGER','z.zzz.zzz.9','.','');
	cCdbaninf.css({'width':'40px'}).setMask('INTEGER','z.zzz','.','');
	cCdagechq.css({'width':'40px'}).addClass('inteiro');

	cDtmvtolt.css({'width':'110px'}).addClass('data');
	cNrdconta.addClass('conta').css({'width':'95px'});
	cCdbccxlt.css({'width':'105px'});

	cNrdolote.css({'width':'110px'});
	cCdagenci.css({'width':'95px'});
	cVllanmto.css({'width':'105px'});

	cNrseqimp.css({'width':'65px'});
	cCdpesqbb.css({'width':'377px'});
	cVldoipmf.css({'width':'65px'});

	cNmprimtl.css({'width':'300px'});
	cDsagenci.css({'width':'178px'});

	cCdturnos.css({'width':'40px'});
	cNrfonemp.css({'width':'159px'});
	cNrramemp.css({'width':'60px'});

	cCdbanchq.css({'width':'75px'});
	cCdcmpchq.css({'width':'50px'});
	cNrlotchq.css({'width':'75px'});
	cSqlotchq.css({'width':'75px'});
	cNrctachq.addClass('conta').css({'width':'100px'});

	cVlcheque.addClass('moeda');

	cTodosConsulta.desabilitaCampo();

	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
	    if (e.keyCode == 13) {

	        $(this).removeClass('campoErro');
            
			if (cCddopcao.val() == 'C') {			
				cNrdocmto.focus();
			} else {
			    btnContinuar();
			}
			return false;
		}
	});

	cNrdocmto.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
	    if (e.keyCode == 13) {

	        $(this).removeClass('campoErro');

			if (cCddopcao.val() == 'C') {
				cNrdctabb.focus();
			} else {
				cNrdconta.focus();
			}
			return false;
		}
	});

	cNrdctabb.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
	    if (e.keyCode == 13) {

	        $(this).removeClass('campoErro');

			if (cCddopcao.val() == 'C') {
				cCdbaninf.focus();
				}
		    else {
			    btnContinuar();
			}
			
			return false;
		}
	});

	cCdbaninf.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
	    if (e.keyCode == 13) {

	        $(this).removeClass('campoErro');

	        btnContinuar();
			return false;
		}
	});

	cDtmvtolt.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
	    if (e.keyCode == 13) {

	        $(this).removeClass('campoErro');
            
			if (cCddopcao.val() == 'C') {
				cCdbaninf.focus();
			} else {
				cNrdconta.focus();				
			}

			return false;
		}
	});

	layoutPadrao();

	if (cCddopcao.val() == 'C') {

	    
	    cCdbaninf.habilitaCampo();
	    cNrdctabb.habilitaCampo();
	    cNrdocmto.habilitaCampo().focus();

	} else {

	    cNrdconta.habilitaCampo();
	    cNrdocmto.habilitaCampo().focus();
	}
    
	return false;
}

function btnVoltar(op) {

    switch (op) {

        case '1': // volta para opcao		

            $('#divBotoesConsulta','#divTela').css({'display':'none'});

		 	estadoInicial();			
        break;

        case '2': // volta para filtro
            $('#frmFiltro').limpaFormulario();

			$('#divBotoes','#divTela').css({'display':'none'});
			$('#divBotoesConsulta','#divTela').css({'display':'block'});

			$('#divTabela').html('');

			formataFiltro();

			$('#nrdocmto','#frmFiltro').focus();
        break;
    }
}


function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }

	var cddopcao = $('#cddopcao', '#frmCab');
	var nrdocmto = $('#nrdocmto', '#frmFiltro');
	var nrdctabb = $('#nrdctabb', '#frmFiltro');	
	var cdbaninf = $('#cdbaninf', '#frmFiltro');
	var nrdconta = $('#nrdconta', '#frmFiltro');
	var dtmvtolt = $('#dtmvtolt', '#frmFiltro');	
	
	if (cddopcao.hasClass('campo')) {
	    $('#btOK', '#frmCab').click();
	} else if (cddopcao.val() == "C") {
	    if (nrdocmto.val() == "" || nrdocmto.val() == "0") {
			showError('error','Informar campo Nro. Documento.','Alerta - Ayllos','focaCampoErro(\'nrdocmto\',\'frmFiltro\');');
		}else
		if (nrdctabb.val() == "") {
			showError('error','Informar campo Cta.Chq/Base.','Alerta - Ayllos','focaCampoErro(\'nrdctabb\',\'frmFiltro\');');
		}else
		if (cdbaninf.val() == "") {
			showError('error','Informar campo Bco Chq.','Alerta - Ayllos','focaCampoErro(\'cdbaninf\',\'frmFiltro\');');
		}else {
			buscaCheque();
		}
	} else if (cddopcao.val() == "D") {
	    if (nrdocmto.val() == "" || nrdocmto.val() == "0") {
			showError('error','Informar campo Nro. Documento.','Alerta - Ayllos','focaCampoErro(\'nrdocmto\',\'frmFiltro\');');
		}else
		if (nrdconta.val() == "") {
			showError('error','Informar campo Conta/dv.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\'frmFiltro\');');
		} else {
			buscaCheque();
		}
	}

	return false;
}


function buscaCheque() {

	var cddopcao = $('#cddopcao', '#frmCab').val();
    var dtmvtolt = $('#dtmvtolt', '#frmFiltro').val();
	var cdagenci = $('#cdagenci', '#frmFiltro').val();
	var cdbccxlt = $('#cdbccxlt', '#frmFiltro').val();
    var nrdolote = $('#nrdolote', '#frmFiltro').val();
	var nrdconta = $('#nrdconta', '#frmFiltro').val();
	var nrdconta = normalizaNumero(nrdconta);
	var nrdocmto = $('#nrdocmto', '#frmFiltro').val();
	var nrdocmto = normalizaNumero(nrdocmto);
	var nrdctabb = $('#nrdctabb', '#frmFiltro').val();
	var nrdctabb = normalizaNumero(nrdctabb);
	var cdbaninf = $('#cdbaninf', '#frmFiltro').val();
	var cdbaninf = normalizaNumero(cdbaninf);
	var cdagechq = $('#cdagechq', '#frmFiltro').val();
	var cdagechq = normalizaNumero(cdagechq);
	var vllanmto = $('#vllanmto', '#frmFiltro').val();
	var nmprimtl = $('#nmprimtl', '#frmFiltro').val();
	var dsagenci = $('#dsagenci', '#frmFiltro').val();
	var cdturnos = $('#cdturnos', '#frmFiltro').val();
	var nrfonemp = $('#nrfonemp', '#frmFiltro').val();
	var nrramemp = $('#nrramemp', '#frmFiltro').val();
	var cdbanchq = $('#cdbanchq', '#frmFiltro').val();
	var cdcmpchq = $('#cdcmpchq', '#frmFiltro').val();
	var nrlotchq = $('#nrlotchq', '#frmFiltro').val();
	var sqlotchq = $('#sqlotchq', '#frmFiltro').val();
	var nrctachq = $('#nrfonemp', '#frmFiltro').val();
    var dsdocmc7 = '<' + nrdolote + '<' + nrdconta + '>' + nrdocmto + ':';

	cddopcao = (typeof cddopcao == 'undefined') ? '' : cddopcao;
	cdagenci = (typeof cdagenci == 'undefined') ? '' : cdagenci;
	cdbccxlt = (typeof cdbccxlt == 'undefined') ? '' : cdbccxlt;
	dtmvtolt = (dtmvtolt == '') ? '?' : dtmvtolt;

	$('input,select', '#frmFiltro').desabilitaCampo().removeClass('campoErro');
	$('#divTabela').html('');

	showMsgAguardo("Aguarde, buscando informações ...");
	
	$.ajax({
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/pesqsr/busca_cheque.php',
		data    :
				{ cddopcao	: cddopcao,
				  dtmvtolt  : dtmvtolt,
				  cdagenci  : cdagenci,
				  cdbccxlt  : cdbccxlt,
				  dsdocmc7  : dsdocmc7,
				  nrdolote  : nrdolote,
				  nrdconta  : nrdconta,
				  nrdocmto	: nrdocmto,
				  nrdctabb	: nrdctabb,
				  cdbaninf	: cdbaninf,
				  vllanmto	: vllanmto,
				  nmprimtl  : nmprimtl,
				  dsagenci  : dsagenci,
				  cdturnos  : cdturnos,
				  nrfonemp  : nrfonemp,
				  nrramemp  : nrramemp,
				  cdbanchq  : cdbanchq,
				  cdcmpchq  : cdcmpchq,
				  nrlotchq  : nrlotchq,
				  sqlotchq  : sqlotchq,
				  nrctachq  : nrctachq,				  
				  redirect: 'script_ajax'

				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success : function(response) {			
					hideMsgAguardo();
					
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {							
							                            
							$('#divTabela').html(response);
							
							return false;

						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					}

				}
	});
}


function formataTabela() {

	var divRegistro = $('div.divRegistros');

	var tabela      = $('table', divRegistro );

	divRegistro.css({'height':'117px','border-bottom':'1px dotted #777','padding-bottom':'2px'});
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '150px';
	arrayLargura[1] = '160px';
    arrayLargura[2] = '190px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'left';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

    // seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaCheque($(this));
	});

	return false;
}

/* Seleciona cheque, para opcao C */
function selecionaCheque(tr){

	$('#dtmvtolt','#frmFiltro').val( $('#dtmvtolt', tr ).val() );
	$('#cdagenci','#frmFiltro').val( $('#cdagenci', tr ).val() );
	$('#cdbccxlt','#frmFiltro').val( $('#cdbccxlt', tr ).val() );
	$('#nrdolote','#frmFiltro').val( $('#nrdolote', tr ).val() );
	$('#nrdconta','#frmFiltro').val($('#nrdconta', tr ).val() );
	$('#nrdocmto','#frmFiltro').val( $('#nrdocmto', tr ).val() );
	$('#nrdctabb','#frmFiltro').val( $('#nrdctabb', tr ).val() );
	$('#cdbaninf','#frmFiltro').val( $('#cdbaninf', tr ).val() );
	$('#cdagechq','#frmFiltro').val( $('#cdagechq', tr ).val() );
	$('#vllanmto','#frmFiltro').val( $('#vllanmto', tr ).val() );
	
	$('#nrseqimp','#frmFiltro').val( $('#nrseqimp', tr ).val() );
	$('#cdpesqbb','#frmFiltro').val( $('#cdpesqbb', tr ).val() );
	$('#vldoipmf','#frmFiltro').val( $('#vldoipmf', tr ).val() );
	
	$('#nmprimtl','#frmFiltro').val( $('#nmprimtl', tr ).val() );
	$('#dsagenci','#frmFiltro').val( $('#dsagenci', tr ).val() );
	$('#cdturnos','#frmFiltro').val( $('#cdturnos', tr ).val() );
	$('#nrfonemp','#frmFiltro').val( $('#nrfonemp', tr ).val() );
	$('#nrramemp','#frmFiltro').val( $('#nrramemp', tr ).val() );
	$('#cdbanchq','#frmFiltro').val( $('#cdbanchq', tr ).val() );
	$('#cdcmpchq','#frmFiltro').val( $('#cdcmpchq', tr ).val() );
	$('#nrlotchq','#frmFiltro').val( $('#nrlotchq', tr ).val() );
	$('#sqlotchq','#frmFiltro').val( $('#sqlotchq', tr ).val() );
	$('#nrctachq','#frmFiltro').val( $('#nrctachq', tr ).val() );

	return false;
}
