/*!
 * FONTE        : uppgto.js
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : 06/09/2017
 * OBJETIVO     : Biblioteca de funções da tela UPPGTO
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 13/06/2019 - Inclusao da opcao E - Upload de TED - Anderson Schloegel - Mout's
 */
 
//Formulários e Tabela
var frmCab      = 'frmCab';
var frmArquivo  = 'frmArquivo';
var frmArquivoTed  = 'frmArquivoTed'; // P500 - Mouts - Anderson Schloegel
var frmConsulta = 'frmConsulta';
var frmRelatorio = 'frmRelatorio';
var frmConsultaLog = 'frmConsultaLog';
var frmOpcao    = 'frmOpcao';
var frmTabela   = 'frmTabela';

var cddopcao = 'C';

$(document).ready(function () {	
    estadoInicial();
});

// inicio
function estadoInicial() {

    $('#divTela').fadeTo(0, 0.1);

    // retira as mensagens	
    hideMsgAguardo();

    // formulario	
    formataCabecalho();	
    cTodosCabecalho.limpaFormulario().removeClass('campoErro');

    fechaRotina($('#divUsoGenerico'));
    fechaRotina($('#divRotina'));
	
	$('#divArquivos').css({'display':'none'});
	$('#divConsulta').css({'display':'none'});
	$('#divRelatorio').css({'display':'none'});
	$('#divConsultaLog').css({'display':'none'});
	$('#divTabela').css({'display':'none'});
	$('#divArquivosTed').css({'display':'none'}); 	// P500 - Mouts - Anderson Schloegel
	$('#fRemessasTed').css({'display':'none'}); 	// P500 - Mouts - Anderson Schloegel
	$('#divtbcriticasted').html(''); 				// P500 - Mouts - Anderson Schloegel
	
	trocaBotao('');
	
    $('#' + frmOpcao).remove();
    $('#' + frmTabela).remove();
    $('#divPesquisaRodape', '#divTela').remove();

    cCddopcao.val(cddopcao);
    cCddopcao.habilitaCampo().focus();

    removeOpacidade('divTela');

}

// cabecalho
function formataCabecalho() {

    // Label
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    rCddopcao.css({ 'width': '45px' }).addClass('rotulo');

    // Input
    cCddopcao = $('#cddopcao', '#' + frmCab);
    cCddopcao.css({ 'width': '710px' });

    // campo
    cCddopcao.habilitaCampo();


    // Outros	
    cTodosCabecalho = $('input[type="text"], select', '#' + frmCab);
    btnOK1 = $('#btnOk1', '#' + frmCab);
    cTodosCabecalho.desabilitaCampo();
	
	
    // Se clicar no botao OK
    btnOK1.unbind('click').bind('click', function () {

        //if (divError.css('display') == 'block') { return false; }
        if (cCddopcao.hasClass('campoTelaSemBorda')) { return false; }

        trocaBotao('Avançar');

        //
        cddopcao = cCddopcao.val();
		cCddopcao.desabilitaCampo();
		
        //
        buscaOpcao();
        
        return false;

    });

    // opcao
    cCddopcao.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        // Se é a tecla ENTER, 
        if (e.keyCode == 13) {
            btnOK1.click();
            return false;
        }
    });

    layoutPadrao();
    return false;
}

function formataDetalhes(){

    rNmarquiv = $('label[for="dtnmarquiv"]','#fsetDetalhes');
    rDhdgerac = $('label[for="dtdhdgerac"]','#fsetDetalhes');
    rDscodbar = $('label[for="dtdscodbar"]','#fsetDetalhes');
    rDslindig = $('label[for="dtdslindig"]','#fsetDetalhes');
    rNmcedent = $('label[for="dtnmcedent"]','#fsetDetalhes');
    rDtvencto = $('label[for="dtdtvencto"]','#fsetDetalhes');
    rDtdpagto = $('label[for="dtdtdpagto"]','#fsetDetalhes');
	rVltitulo = $('label[for="dtvltitulo"]','#fsetDetalhes');
	rDssituac = $('label[for="dtdssituac"]','#fsetDetalhes');
	rDsocorre = $('label[for="dtdsocorre"]','#fsetDetalhes');

	rNmarquiv.addClass('rotulo').css({'width':'180px'});
	rDhdgerac.addClass('rotulo').css({'width':'180px'});
	rDscodbar.addClass('rotulo').css({'width':'180px'});
	rDslindig.addClass('rotulo').css({'width':'180px'});
	rNmcedent.addClass('rotulo').css({'width':'180px'});
	rDtvencto.addClass('rotulo').css({'width':'180px'});
	rDtdpagto.addClass('rotulo').css({'width':'180px'});
	rVltitulo.addClass('rotulo').css({'width':'180px'});
	rDssituac.addClass('rotulo').css({'width':'180px'});
	rDsocorre.addClass('rotulo').css({'width':'180px'});
	
	
    cNmarquiv = $('#dtnmarquiv','#fsetDetalhes');
    cDhdgerac = $('#dtdhdgerac','#fsetDetalhes');
    cDscodbar = $('#dtdscodbar','#fsetDetalhes');
    cDslindig = $('#dtdslindig','#fsetDetalhes');
    cNmcedent = $('#dtnmcedent','#fsetDetalhes');
    cDtvencto = $('#dtdtvencto','#fsetDetalhes');
    cDtdpagto = $('#dtdtdpagto','#fsetDetalhes');
	cVltitulo = $('#dtvltitulo','#fsetDetalhes');
	cDssituac = $('#dtdssituac','#fsetDetalhes');
	cDsocorre = $('#dtdsocorre','#fsetDetalhes');
	
	cNmarquiv.addClass('campo').css({'width':'380px'});
	cDhdgerac.addClass('campo').css({'width':'380px'});
	cDscodbar.addClass('campo').css({'width':'380px'});
	cDslindig.addClass('campo').css({'width':'380px'});
	cNmcedent.addClass('campo').css({'width':'380px'});
	cDtvencto.addClass('campo').css({'width':'380px'});
	cDtdpagto.addClass('campo').css({'width':'380px'});
	cVltitulo.addClass('campo').css({'width':'380px'});
	cDssituac.addClass('campo').css({'width':'380px'});
	cDsocorre.addClass('campo').css({'width':'380px'});

	cNmarquiv.desabilitaCampo();
	cDhdgerac.desabilitaCampo();
	cDscodbar.desabilitaCampo();
	cDslindig.desabilitaCampo();
	cNmcedent.desabilitaCampo();
	cDtvencto.desabilitaCampo();
	cDtdpagto.desabilitaCampo();
	cVltitulo.desabilitaCampo();
	cDssituac.desabilitaCampo();
	cDsocorre.desabilitaCampo();	
	
}

// P500 - Mouts - Anderson Schloegel
function formataOpcaoE(){
	
	rNrdconta			= $('label[for="nrdconta"]','#'+frmArquivoTed); 
	rNmprimtl	        = $('label[for="nmprimtl"]','#'+frmArquivoTed);        
	
	cNrdconta			= $('#nrdconta','#'+frmArquivoTed); 
	cNmprimtl			= $('#nmprimtl','#'+frmArquivoTed); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmArquivoTed);
	btnOK1				= $('#btnOK1','#'+frmArquivoTed);

	rNrdconta.addClass('rotulo').css({'width':'40px'});
	rNmprimtl.addClass('rotulo').css({'width':'40px'});

	cNrdconta.addClass('conta pesquisa').css({'width':'80px'})
	cNmprimtl.addClass('alphanum').css({'width':'420px'}).attr('maxlength','48');

	$('#userfile','#'+frmArquivoTed).css({'width':'600px'})

	cNrdconta.habilitaCampo();
	cNmprimtl.desabilitaCampo();
	
	cNrdconta.val('');
	cNmprimtl.val('');
	$('#userfile','#'+frmArquivoTed).val('');

	$('#fCriticasTed').css({'display':'none'});
	$('table.tituloRegistros').css({'display':'none'});
	
	btnOK1.unbind('click').bind('click', function() { 	
		
		if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }
		
		// Armazena o número da conta na variável global
		var nrdconta = normalizaNumero( cNrdconta.val() );
		
		// Verifica se o número da conta é vazio
		if ( nrdconta == '' ) { return false; }
	
		// Verifica se a conta é válida
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmArquivoTed +'\');');
			return false; 
		}

		cTodosCabecalho.removeClass('campoErro');
		
		// Se chegou até aqui, a conta é diferente de vazio e é válida, então realizar a operação desejada
        consultaConta(frmArquivoTed);

        // consulta ao enviar clique de OK dos dados da conta
		$.ajax({
	        type: "POST",
	        url: UrlSite + "telas/uppgto/busca_remessas_ted.php",
	        data: {
	            cddopcao: 'e',
	            nrdconta: nrdconta,
	            redirect: "script_ajax"
	        },
	        error: function (objAjax, responseError, objExcept) {
	        	console.log(' response error: ' , response);
	            hideMsgAguardo();
	            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
	        },
	        success: function (response) {

	        	try {

	        		eval(response);

	        	} catch(error) {

	        		console.log('erro tc');

	        	}

	        }

	    });

		return false;
			
	});	

	cNrdconta.unbind('keypress').bind('keypress', function(e) {

		//alert('keypress');
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cNrdconta.val() == '' ) {
				mostraPesquisaAssociado('nrdconta|nmprimtl', frmArquivoTed );
				return false;
			}
			btnOK1.click();
			return false;
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta|nmprimtl', frmArquivoTed );
			return false;
		}
	});	
	
	layoutPadrao();
	controlaPesquisas();		
	
	return false;
} // fim P500

function formataOpcaoT(){
	
	rNrdconta			= $('label[for="nrdconta"]','#'+frmArquivo); 
	rNmprimtl	        = $('label[for="nmprimtl"]','#'+frmArquivo);        
	
	cNrdconta			= $('#nrdconta','#'+frmArquivo); 
	cNmprimtl			= $('#nmprimtl','#'+frmArquivo); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmArquivo);
	btnOK1				= $('#btnOK1','#'+frmArquivo);

	
	rNrdconta.addClass('rotulo').css({'width':'40px'});
	rNmprimtl.addClass('rotulo').css({'width':'40px'});

	cNrdconta.addClass('conta pesquisa').css({'width':'80px'})
	cNmprimtl.addClass('alphanum').css({'width':'420px'}).attr('maxlength','48');

	$('#userfile','#'+frmArquivo).css({'width':'600px'})

	cNrdconta.habilitaCampo();
	cNmprimtl.desabilitaCampo();
	
	cNrdconta.val('');
	cNmprimtl.val('');
	$('#userfile','#'+frmArquivo).val('');

	$('#divtbcriticas').css({'display':'none'});
	$('table.tituloRegistros').css({'display':'none'});
	
	btnOK1.unbind('click').bind('click', function() { 	
		
		if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		// Armazena o número da conta na variável global
		var nrdconta = normalizaNumero( cNrdconta.val() );
		
		// Verifica se o número da conta é vazio
		if ( nrdconta == '' ) { return false; }
	
		// Verifica se a conta é válida
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmArquivo +'\');'); 
			return false; 
		}

		cTodosCabecalho.removeClass('campoErro');	
		
		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
        consultaConta(frmArquivo);
		return false;
			
	});	

	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cNrdconta.val() == '' ) {
				mostraPesquisaAssociado('nrdconta|nmprimtl', frmArquivo );
				return false;
			}
			btnOK1.click();
			return false;
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta|nmprimtl', frmArquivo );
			return false;
		}
	});	
	
	layoutPadrao();
	controlaPesquisas();		
	
	return false;
}

function formataOpcaoC(){
	
	rNrdconta			= $('label[for="nrdconta"]','#'+frmConsulta);
	rNmprimtl	        = $('label[for="nmprimtl"]','#'+frmConsulta);
	rNmarquiv           = $('label[for="nmarquiv"]','#'+frmConsulta);
	rNrremess           = $('label[for="nrremess"]','#'+frmConsulta); 
	rDtrefere           = $('label[for="dtrefere"]','#'+frmConsulta); 
	rDtiniper           = $('label[for="dtiniper"]','#'+frmConsulta); 
	rDtfimper           = $('label[for="dtfimper"]','#'+frmConsulta); 
	rNmbenefi           = $('label[for="nmbenefi"]','#'+frmConsulta); 
	rCdbarras           = $('label[for="cdbarras"]','#'+frmConsulta); 
	rCdsittit           = $('label[for="cdsittit"]','#'+frmConsulta); 
	
	cNrdconta			= $('#nrdconta','#'+frmConsulta); 	
	cNmprimtl			= $('#nmprimtl','#'+frmConsulta); 
	cNmarquiv			= $('#nmarquiv','#'+frmConsulta); 
	cNrremess           = $('#nrremess','#'+frmConsulta); 
	cDtrefere           = $('#dtrefere','#'+frmConsulta); 
	cDtiniper           = $('#dtiniper','#'+frmConsulta); 
	cDtfimper           = $('#dtfimper','#'+frmConsulta); 
	cNmbenefi           = $('#nmbenefi','#'+frmConsulta); 
	cCdbarras           = $('#cdbarras','#'+frmConsulta); 
	cCdsittit           = $('#cdsittit','#'+frmConsulta); 
	
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmConsulta);
	btnOK1				= $('#btnOK1','#'+frmConsulta);

	
	rNrdconta.addClass('rotulo').css({'width':'130px'});
	rNmprimtl.addClass('rotulo').css({'width':'40px'});
	rNmarquiv.addClass('rotulo').css({'width':'130px'});
    rNrremess.addClass('rotulo').css({'width':'130px'});
	rDtrefere.addClass('rotulo').css({'width':'130px'});
	rDtiniper.addClass('rotulo').css({'width':'130px'});
	rNmbenefi.addClass('rotulo').css({'width':'130px'});
	rCdbarras.addClass('rotulo').css({'width':'130px'});
	rCdsittit.addClass('rotulo').css({'width':'130px'});
	
	cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
	cNmprimtl.addClass('campo alphanum').css({'width':'300px'});
	cNmarquiv.addClass('campo alphanum').css({'width':'280px'}).attr('maxlength','48');
	cNrremess.addClass('campo numero').css({'width':'220px'}).attr('maxlength','48');
	cDtrefere.addClass('campo alphanum').css({'width':'220px'});
	cDtiniper.addClass('campo data').css({'width':'105px'});
	cDtfimper.addClass('campo data').css({'width':'105px'});
	cNmbenefi.addClass('campo alphanum').css({'width':'280px'}).attr('maxlength','48');
	cCdbarras.addClass('campo numerico').css({'width':'280px'}).attr('maxlength','48');
	cCdsittit.addClass('campo alphanum').css({'width':'220px'});

	cNrdconta.habilitaCampo();
	cNmprimtl.desabilitaCampo();
	
	cNmarquiv.habilitaCampo();
	cNrremess.habilitaCampo();
	cDtrefere.habilitaCampo();
	cDtiniper.habilitaCampo();
	cDtfimper.habilitaCampo();
	cNmbenefi.habilitaCampo();
	cCdbarras.habilitaCampo();
	cCdsittit.habilitaCampo();

	cNrdconta.val('');
	cNmprimtl.val('');
	cNmarquiv.val('');
	cNrremess.val('');
	cDtrefere.val('1');
	cDtiniper.val('');
	cDtfimper.val('');
	cNmbenefi.val('');
	cCdbarras.val('');
	cCdsittit.val('1');
	
	btnOK1.unbind('click').bind('click', function() { 	
		
		if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		// Armazena o número da conta na variável global
		var nrdconta = normalizaNumero( cNrdconta.val() );
		
		// Verifica se o número da conta é vazio
		if ( nrdconta == '' ) { return false; }
	
		// Verifica se a conta é válida
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmConsulta +'\');'); 
			return false; 
		}

		cTodosCabecalho.removeClass('campoErro');	
		
		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
        consultaConta(frmConsulta);
		
		return false;			
	});	

	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cNrdconta.val() == '' ) {
				mostraPesquisaAssociado('nrdconta|nmprimtl', frmConsulta );
				return false;
			}
			btnOK1.click();
			return false;
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta|nmprimtl', frmConsulta );
			return false;
		}
	});	
	

	layoutPadrao();
	return false;
}


function formataOpcaoR(){
	
	rNrdconta			= $('label[for="nrdconta"]','#'+frmRelatorio);
	rNmprimtl	        = $('label[for="nmprimtl"]','#'+frmRelatorio);
	rNmarquiv           = $('label[for="nmarquiv"]','#'+frmRelatorio);
	rNrremess           = $('label[for="nrremess"]','#'+frmRelatorio); 
	rDtrefere           = $('label[for="dtrefere"]','#'+frmRelatorio); 
	rDtiniper           = $('label[for="dtiniper"]','#'+frmRelatorio); 
	rDtfimper           = $('label[for="dtfimper"]','#'+frmRelatorio); 
	rNmbenefi           = $('label[for="nmbenefi"]','#'+frmRelatorio); 
	rCdbarras           = $('label[for="cdbarras"]','#'+frmRelatorio); 
	rCdsittit           = $('label[for="cdsittit"]','#'+frmRelatorio); 
	rTprelato           = $('label[for="tprelato"]','#'+frmRelatorio); 	
	
	cNrdconta			= $('#nrdconta','#'+frmRelatorio); 	
	cNmprimtl			= $('#nmprimtl','#'+frmRelatorio); 
	cNmarquiv			= $('#nmarquiv','#'+frmRelatorio); 
	cNrremess           = $('#nrremess','#'+frmRelatorio); 
	cDtrefere           = $('#dtrefere','#'+frmRelatorio); 
	cDtiniper           = $('#dtiniper','#'+frmRelatorio); 
	cDtfimper           = $('#dtfimper','#'+frmRelatorio); 
	cNmbenefi           = $('#nmbenefi','#'+frmRelatorio); 
	cCdbarras           = $('#cdbarras','#'+frmRelatorio); 
	cCdsittit           = $('#cdsittit','#'+frmRelatorio); 
	cTprelato           = $('#tprelato','#'+frmRelatorio); 	
	
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmRelatorio);
	btnOK1				= $('#btnOK1','#'+frmRelatorio);

	
	rNrdconta.addClass('rotulo').css({'width':'130px'});
	rNmprimtl.addClass('rotulo').css({'width':'40px'});
	rNmarquiv.addClass('rotulo').css({'width':'130px'});
    rNrremess.addClass('rotulo').css({'width':'130px'});
	rDtrefere.addClass('rotulo').css({'width':'130px'});
	rDtiniper.addClass('rotulo').css({'width':'130px'});
	rNmbenefi.addClass('rotulo').css({'width':'130px'});
	rCdbarras.addClass('rotulo').css({'width':'130px'});
	rCdsittit.addClass('rotulo').css({'width':'130px'});
	rTprelato.addClass('rotulo').css({'width':'130px'});	
	
	cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
	cNmprimtl.addClass('campo alphanum').css({'width':'300px'});
	cNmarquiv.addClass('campo alphanum').css({'width':'280px'}).attr('maxlength','48');
	cNrremess.addClass('campo numero').css({'width':'220px'}).attr('maxlength','48');
	cDtrefere.addClass('campo alphanum').css({'width':'220px'});
	cDtiniper.addClass('campo data').css({'width':'105px'});
	cDtfimper.addClass('campo data').css({'width':'105px'});
	cNmbenefi.addClass('campo alphanum').css({'width':'280px'}).attr('maxlength','48');
	cCdbarras.addClass('campo numerico').css({'width':'280px'}).attr('maxlength','48');
	cCdsittit.addClass('campo alphanum').css({'width':'220px'});
	cTprelato.addClass('campo alphanum').css({'width':'80px'});	

	cNrdconta.habilitaCampo();
	cNmprimtl.desabilitaCampo();
	
	cNmarquiv.habilitaCampo();
	cNrremess.habilitaCampo();
	cDtrefere.habilitaCampo();
	cDtiniper.habilitaCampo();
	cDtfimper.habilitaCampo();
	cNmbenefi.habilitaCampo();
	cCdbarras.habilitaCampo();
	cCdsittit.habilitaCampo();
	cTprelato.habilitaCampo();

	cNrdconta.val('');
	cNmprimtl.val('');
	cNmarquiv.val('');
	cNrremess.val('');
	cDtrefere.val('1');
	cDtiniper.val('');
	cDtfimper.val('');
	cNmbenefi.val('');
	cCdbarras.val('');
	cCdsittit.val('1');
	cTprelato.val('1');
	
	btnOK1.unbind('click').bind('click', function() { 	
		
		if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		// Armazena o número da conta na variável global
		var nrdconta = normalizaNumero( cNrdconta.val() );
		
		// Verifica se o número da conta é vazio
		if ( nrdconta == '' ) { return false; }
	
		// Verifica se a conta é válida
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmRelatorio +'\');'); 
			return false; 
		}

		cTodosCabecalho.removeClass('campoErro');	
		
		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
        consultaConta(frmRelatorio);
		return false;
			
	});	

	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cNrdconta.val() == '' ) {
				mostraPesquisaAssociado('nrdconta|nmprimtl', frmRelatorio );
				return false;
			}
			btnOK1.click();
			return false;
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta|nmprimtl', frmRelatorio );
			return false;
		}
	});	
	

	layoutPadrao();
	return false;
}


function formataOpcaoL(){
	
	rNrdconta			= $('label[for="nrdconta"]','#'+frmConsultaLog);
	rNmprimtl	        = $('label[for="nmprimtl"]','#'+frmConsultaLog);
	rNmarquiv           = $('label[for="nmarquiv"]','#'+frmConsultaLog);
	rNrremess           = $('label[for="nrremess"]','#'+frmConsultaLog); 
	rDtiniper           = $('label[for="dtiniper"]','#'+frmConsultaLog); 
	rDtfimper           = $('label[for="dtfimper"]','#'+frmConsultaLog); 
	
	cNrdconta			= $('#nrdconta','#'+frmConsultaLog); 	
	cNmprimtl			= $('#nmprimtl','#'+frmConsultaLog); 
	cNmarquiv			= $('#nmarquiv','#'+frmConsultaLog); 
	cNrremess           = $('#nrremess','#'+frmConsultaLog); 
	cDtiniper           = $('#dtiniper','#'+frmConsultaLog); 
	cDtfimper           = $('#dtfimper','#'+frmConsultaLog); 
	
	cNrdconta.val('');
	cNmprimtl.val('');
	cNmarquiv.val('');
	cNrremess.val('');
	cDtiniper.val('');
	cDtfimper.val('');	

	cNrdconta.habilitaCampo();
	cNmprimtl.desabilitaCampo();
	cNmarquiv.habilitaCampo();
	cNrremess.habilitaCampo();
	cDtiniper.habilitaCampo();
	cDtfimper.habilitaCampo();
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmConsultaLog);
	btnOK1				= $('#btnOK1','#'+frmConsultaLog);
	
	rNrdconta.addClass('rotulo').css({'width':'130px'});
	rNmprimtl.addClass('rotulo').css({'width':'40px'});
	rNmarquiv.addClass('rotulo').css({'width':'130px'});
    rNrremess.addClass('rotulo').css({'width':'130px'});
	rDtiniper.addClass('rotulo').css({'width':'130px'});
	
	cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
	cNmprimtl.addClass('campo alphanum').css({'width':'300px'});
	cNmarquiv.addClass('campo alphanum').css({'width':'280px'}).attr('maxlength','48');
	cNrremess.addClass('campo numero').css({'width':'220px'}).attr('maxlength','48');
	cDtiniper.addClass('campo data').css({'width':'105px'});
	cDtfimper.addClass('campo data').css({'width':'105px'});
	
	cNrdconta.habilitaCampo();
	cNmprimtl.desabilitaCampo();

	btnOK1.unbind('click').bind('click', function() { 	
		
		if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		// Armazena o número da conta na variável global
		var nrdconta = normalizaNumero( cNrdconta.val() );
		
		// Verifica se o número da conta é vazio
		if ( nrdconta == '' ) { return false; }
	
		// Verifica se a conta é válida
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmConsultaLog +'\');'); 
			return false; 
		}

		cTodosCabecalho.removeClass('campoErro');	
		
		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
        consultaConta(frmConsultaLog);
		return false;
			
	});	

	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cNrdconta.val() == '' ) {
				mostraPesquisaAssociado('nrdconta|nmprimtl', frmConsultaLog );
				return false;
			}
			btnOK1.click();
			return false;
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta|nmprimtl', frmConsultaLog );
			return false;
		}
	});	
	
	layoutPadrao();
	return false;
}

function btnContinuar() {

	$('input,select', '#frmCab').removeClass('campoErro');

	$('#fCriticasTed').html('<div id="divtbcriticasted" class="divRegistros" center></div>'); // P500 - Mout's - Anderson Schloegel

	// Se chegou até aqui, o cnae é diferente do vazio e é válida, então realizar a operação desejada
	realizaOperacao();
	
	return false;		
}

function buscaOpcao() {

    showMsgAguardo('Aguarde, buscando dados ...');

    // P500 - Mouts - Anderson Schloegel
	if(cddopcao == 'E'){		
		formataOpcaoE();
		trocaBotao('Importar');		
		$('#divArquivosTed').css({'display':'block'});
		$('#divBotoes').css({'display':'block'});		
		$('#nrdconta','#'+frmArquivo).focus();
		$('fCriticasTed').show();
	} // fim P500

	if(cddopcao == 'T'){		
		formataOpcaoT();
		trocaBotao('Importar');		
		$('#divArquivos').css({'display':'block'});
		$('#divBotoes').css({'display':'block'});		
		$('#nrdconta','#'+frmArquivo).focus();
	}

    if(cddopcao == 'C'){
		formataOpcaoC();
		trocaBotao('OK');
		$('#divConsulta').css({'display':'block'});
		$('#divBotoes').css({'display':'block'});		
		$('#nrdconta','#'+frmConsulta).focus();
	}

    if(cddopcao == 'L'){
		formataOpcaoL();
		trocaBotao('OK');
		$('#divConsultaLog').css({'display':'block'});
		$('#divBotoes').css({'display':'block'});		
		$('#nrdconta','#'+frmConsultaLog).focus();
	}

	if(cddopcao == 'R'){		
		formataOpcaoR();
		trocaBotao('Gerar');
		$('#divRelatorio').css({'display':'block'});
		$('#divBotoes').css({'display':'block'});
		$('#nrdconta','#'+frmRelatorio).focus();
	}
	
	hideMsgAguardo();

    return false;

}

function controlaPesquisas() {

	// Atribui a classe lupa para os links e desabilita todos
	$('a','#'+frmArquivo).addClass('lupa').css('cursor','auto');	
	
	// Percorrendo todos os links
	$('a','#'+frmArquivo).each( function() {
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) { $(this).css('cursor','pointer'); }
	});

	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#frmArquivo' );

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta|nmprimtl', frmArquivo );
		});
	}
	
	
	return false;
}

function realizaOperacao() {

	// Mostra mensagem de aguardo
	cddopcao = cCddopcao.val();
	var frmUtil;
	
	if (cddopcao == "C"){ frmUtil = frmConsulta; } 
	else if (cddopcao == "L"){ frmUtil = frmConsultaLog; }	
	else if (cddopcao == "R"){ frmUtil = frmRelatorio; }
	else if (cddopcao == "T"){ frmUtil = frmArquivo; } 
	else if (cddopcao == "E"){ frmUtil = frmArquivoTed; }  // P500 - Mouts - Anderson Schloegel
	
	if( !$('#nrdconta','#'+frmUtil).hasClass('campoTelaSemBorda') ){
		showError("error", "Conta deve ser informada.", "Alerta - Ayllos", "return false;");
		return false;
	}
	
	// P500 - Mout's - Anderson Schloegel
	if (cddopcao == "E") {
		var confereArquivoTed = $('#userfile','#frmArquivoTed').val();
		if (confereArquivoTed.length == 0) {
			showError("error", "Arquivo deve ser informado.", "Alerta - Ayllos", "return false;");
			return false;
		}
	} // fim P500

	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando..."); buscaRemessas(0,10); return false; } 
	else if (cddopcao == "L"){ showMsgAguardo("Aguarde, consultando..."); buscaLogRemessas(); return false; }	
	else if (cddopcao == "R"){ showMsgAguardo("Aguarde, excluindo...");  geraRelatorio(); return false;}
	else if (cddopcao == "T"){ showMsgAguardo("Aguarde, importando...");  confirmaUploadArquivo(cddopcao); return false;} 
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, importando...");  confirmaUploadArquivoTed(cddopcao); return false;} // P500 - Mouts - Anderson Schloegel
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
}

function consultaConta(frmParametro){
	
    var nrdconta = normalizaNumero( $("#nrdconta", "#"+frmParametro).val() );

    showMsgAguardo("Aguarde, consultando cooperativa ...");

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/uppgto/consulta_conta.php",
        data: {
            nrdconta: nrdconta,
			frmparametro: frmParametro,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    eval(response);						                    										
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            } else {
                try {					
                    eval(response);						
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            }
        }

    });
	
	return false;
}

function confirmaUploadArquivo(cddopcao){
	showConfirmacao('Confirma importa&ccedil;&atilde;o?'	,'Confirma&ccedil;&atilde;o - UPPGTO','importarArquivo("' + cddopcao + '")','return false','sim.gif','nao.gif'); return false; 
}
// P500 - Mout's - Anderson Schloegel
function confirmaUploadArquivoTed(cddopcao){
	hideMsgAguardo();
	showConfirmacao('Confirma importa&ccedil;&atilde;o?'	,'Confirma&ccedil;&atilde;o - UPPGTO','importarArquivoTed("' + cddopcao + '")','return false','sim.gif','nao.gif'); return false; 
} // fim P500

function importarArquivo(cddopcao){

	// Link para o action do formulario
	var action = UrlSite + 'telas/uppgto/upload.php'; 
    var frmEnvia = $('#'+frmArquivo);
   
	// Incluir o campo de login para validação (campo necessario para validar sessao)
    $('#sidlogin', frmEnvia).remove(); 
	$('#cddopcao', frmEnvia).remove();
	$('#flglimpa', frmEnvia).remove(); 
	$('#nudconta', frmEnvia).remove(); 
	
	$(frmEnvia).append('<input type="hidden" id="sidlogin" name="sidlogin" />'); 	
	$(frmEnvia).append('<input type="hidden" id="cddopcao" name="cddopcao" value="' + cddopcao + '" />');	
	$(frmEnvia).append('<input type="hidden" id="flglimpa" name="flglimpa" value="0" />'); 
	$(frmEnvia).append('<input type="hidden" id="nudconta" name="nudconta" value="' + normalizaNumero($('#nrdconta', frmEnvia).val()) + '" />');		
	
	// Seta o valor conforme id do menu
	$('#sidlogin',frmEnvia).val( $('#sidlogin','#frmMenu').val() ); 
		
	// Configuro o formulário para posteriormente submete-lo
	$(frmEnvia).attr('method','post');
	$(frmEnvia).attr('action',action);		
	$(frmEnvia).attr("target",'frameBlank');			
		
	$(frmEnvia).submit();

}

// P500 - Mouts - Anderson Schloegel
function importarArquivoTed(cddopcao){

	//alert( 'teste importarArquivoTed');
	// Link para o action do formulario
	var action = UrlSite + 'telas/uppgto/upload_ted.php';
    var frmEnvia = $('#'+frmArquivoTed);

	// Incluir o campo de login para validação (campo necessario para validar sessao)
    $('#sidlogin', frmEnvia).remove(); 
	$('#cddopcao', frmEnvia).remove();
	$('#flglimpa', frmEnvia).remove(); 
	$('#nudconta', frmEnvia).remove(); 
	
	$(frmEnvia).append('<input type="hidden" id="sidlogin" name="sidlogin" />'); 	
	$(frmEnvia).append('<input type="hidden" id="cddopcao" name="cddopcao" value="' + cddopcao + '" />');	
	$(frmEnvia).append('<input type="hidden" id="flglimpa" name="flglimpa" value="0" />'); 
	$(frmEnvia).append('<input type="hidden" id="nudconta" name="nudconta" value="' + normalizaNumero($('#nrdconta', frmEnvia).val()) + '" />');		
	
	// Seta o valor conforme id do menu
	$('#sidlogin',frmEnvia).val( $('#sidlogin','#frmMenu').val() ); 
		
	// Configuro o formulário para posteriormente submete-lo
	$(frmEnvia).attr('method','post');
	$(frmEnvia).attr('action',action);		
	$(frmEnvia).attr("target",'frameBlank');			
	
	//console.log('dados do form: ', frmEnvia);

	$(frmEnvia).submit();

}

function sucessoOpcaoT(){	
	hideMsgAguardo();	
	estadoInicial();
}

function criticaOpcaoT(tabela){	
	hideMsgAguardo();	
	
	$('#divtbcriticas').html(tabela);
	
	formataTabelaCriticas();
}

function sucessoOpcaoE(){
	hideMsgAguardo();	
	estadoInicial();
	showError('inform','Arquivo importado com sucesso.','Alerta - Ayllos','',false);

}

function criticaOpcaoE(tabela){	
	hideMsgAguardo();	
	$('#divtbcriticasted').html(tabela);
	formataTabelaCriticasTed();
}

function criticaOpcaoE2(tabela){	
	hideMsgAguardo();	
	//alert('criticaOpcaoE2');
	$('#divtbremessasted').html(tabela);
	// alert(' teste bacon defumado');
	formataTabelaCriticasTed2();
}


function buscaLogRemessas(){
    //Desabilita todos os campos do form
    $('input,select', '#frmConsultaLog').desabilitaCampo();

    var nrdconta = normalizaNumero($('#nrdconta', '#frmConsultaLog').val());
    var nmarquiv = $("#nmarquiv", "#frmConsultaLog").val();    
    var nrremess = $("#nrremess", "#frmConsultaLog").val();
    var dtiniper = $("#dtiniper", "#frmConsultaLog").val();
	var dtfimper = $("#dtfimper", "#frmConsultaLog").val();
    var cddopcao = $("#cddopcao", "#frmCab").val();

    $('input,select', '#frmConsultaLog').removeClass('campoErro');

    showMsgAguardo("Aguarde, buscando log remessas ...");
	
    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/uppgto/busca_log_remessas.php",
        data: {
			cddopcao: cddopcao,
            nrdconta: nrdconta,
			nrremess: nrremess,
            nmarquiv: nmarquiv,            
			dtiniper: dtiniper,
			dtfimper: dtfimper,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divTabela').html(response);
                    return false;
                } catch (error) {
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
                }
            }
        }

    });
    return false;	
}

function buscaRemessas(nriniseq,nrregist) {

    //Desabilita todos os campos do form
    $('input,select', '#frmConsulta').desabilitaCampo();

    var nrdconta = normalizaNumero($('#nrdconta', '#frmConsulta').val());
    var nmarquiv = $("#nmarquiv", "#frmConsulta").val();    
    var nrremess = $("#nrremess", "#frmConsulta").val();
    var dtrefere   = $("#dtrefere", "#frmConsulta").val();
    var dtiniper = $("#dtiniper", "#frmConsulta").val();
	var dtfimper = $("#dtfimper", "#frmConsulta").val();
	var nmbenefi = $("#nmbenefi", "#frmConsulta").val();
	var dscodbar = $("#cdbarras", "#frmConsulta").val();
	var idstatus = $("#cdsittit", "#frmConsulta").val();
    var cddopcao = $("#cddopcao", "#frmCab").val();

    $('input,select', '#frmConsulta').removeClass('campoErro');

    showMsgAguardo("Aguarde, buscando remessas ...");
	
    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/uppgto/busca_remessas.php",
        data: {
			cddopcao: cddopcao,
            nrdconta: nrdconta,
			nrremess: nrremess,
            nmarquiv: nmarquiv,            
            nmbenefi: nmbenefi,
            dscodbar: dscodbar,
            idstatus: idstatus,
            dtrefere: dtrefere,
			dtiniper: dtiniper,
			dtfimper: dtfimper,
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divTabela').html(response);
                    return false;
                } catch (error) {
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
                }
            }
        }

    });
    return false;
}

function selecionaRemessa(tr) {

    $('#dtnmarquiv','#fsetDetalhes').val($('#hdnmarquiv',tr).val());
    $('#dtdhdgerac','#fsetDetalhes').val($('#hddhdgerac',tr).val());
    $('#dtdscodbar','#fsetDetalhes').val($('#hddscodbar',tr).val());
    $('#dtdslindig','#fsetDetalhes').val($('#hddslindig',tr).val());
    $('#dtnmcedent','#fsetDetalhes').val($('#hdnmcedent',tr).val());
    $('#dtdtvencto','#fsetDetalhes').val($('#hddtvencto',tr).val());
    $('#dtdtdpagto','#fsetDetalhes').val($('#hddtdpagto', tr).val());
	$('#dtvltitulo','#fsetDetalhes').val($('#hdvltitulo', tr).val());
	$('#dtdssituac','#fsetDetalhes').val($('#hddssituac', tr).val());
	$('#dtdsocorre','#fsetDetalhes').val($('#hddsocorre', tr).val());
        
    return false;
}

function formataTabelaCriticas(){
    var divRegistro = $('#divtbcriticas');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

	$('#divtbcriticas').css({'display':'block'});
    divRegistro.css({ 'height': '162px' });

    var ordemInicial = new Array();

    var arrayLargura = new Array();

    arrayLargura[0] = '40px';
    
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'left';
    
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
        
    return false;
}

// P500 - Mout's - Anderson Schloegel
function formataTabelaCriticasTed(){
    var divRegistro = $('#divtbcriticasted');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    //$('table', divRegistro).css({'width':'100%'});

	$('#divtbcriticasted').css({'display':'block'});
    divRegistro.css({ 'height': '162px' });
    divRegistro.css({ 'width' : '100%'  });

    var ordemInicial = new Array();

    var arrayLargura = new Array();

    arrayLargura[0] = '40px';
    
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'left';
    
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
        
    return false;
}
// fim P500

// P500 - Mout's - Anderson Schloegel
function formataTabelaCriticasTed2(){
	//alert('formataTabela');
    var divRegistro = $('#divtbremessasted');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    //$('table', divRegistro).css({'width':'100%'});

	$('#divtbremessasted').css({'display':'block'});
    divRegistro.css({ 'height': '162px' });
    divRegistro.css({ 'width' : '100%'  });

    var ordemInicial = new Array();

    var arrayLargura = new Array();

    arrayLargura[0] = '40px';
    
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'left';
    
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
        
    return false;
}
// fim P500

function formataTabelaRemessas() {

    var divRegistro = $('div.divRegistros', '#divTabela');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '162px' });
    $('#divRegistrosRodape', '#divTabela').formataRodapePesquisa();

    var ordemInicial = new Array();

    var arrayLargura = new Array();

    arrayLargura[0] = '260px';
    arrayLargura[1] = '140px';
    arrayLargura[2] = '235px';
    arrayLargura[3] = '80px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

    $('table > tbody > tr', divRegistro).each(function (i) {

        if ($(this).hasClass('corSelecao')) {

            selecionaRemessa($(this));

        }

    });

    //seleciona o lancamento que é clicado
    $('table > tbody > tr', divRegistro).click(function () {

        selecionaRemessa($(this));
    });

    return false;

}

function formataTabelaRemessasLog() {

    var divRegistro = $('div.divRegistros', '#divTabela');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '250px' });
    
    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '225px';
    arrayLargura[1] = '363px';
    arrayLargura[2] = '20px';
    arrayLargura[3] = '63px';
    
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'left';
    arrayAlinha[4] = 'right';
    
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

    return false;

}

function geraRelatorio(){
	
    $('#nrdconta', '#frmImprimir').val( normalizaNumero($('#nrdconta', '#frmRelatorio').val()));
    $('#nmarquiv', '#frmImprimir').val($('#nmarquiv', '#frmRelatorio').val());
    $('#nrremess', '#frmImprimir').val($('#nrremess', '#frmRelatorio').val());
    $('#dtrefere', '#frmImprimir').val($('#dtrefere', '#frmRelatorio').val());
    $('#dtiniper', '#frmImprimir').val($('#dtiniper', '#frmRelatorio').val());
    $('#dtfimper', '#frmImprimir').val($('#dtfimper', '#frmRelatorio').val());
    $('#nmbenefi', '#frmImprimir').val($('#nmbenefi', '#frmRelatorio').val());
    $('#cdbarras', '#frmImprimir').val($('#cdbarras', '#frmRelatorio').val());
    $('#cdsittit', '#frmImprimir').val($('#cdsittit', '#frmRelatorio').val());
    $('#tprelato', '#frmImprimir').val($('#tprelato', '#frmRelatorio').val());

    var action = UrlSite + 'telas/uppgto/gera_relatorio.php';
    cTodosCabecalho.habilitaCampo();

    carregaImpressaoAyllos("frmImprimir", action);
	
    return false;		
}

function btnVoltar(){  
    estadoInicial();  
}

function trocaBotao(botao) {

    $('#divBotoes', '#divTela').html('');    

	if (botao == 'LOG' || botao == 'CONSULTA') {
		$('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');
		return false;
	}
	
    if (botao != '') {
		$('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');
        $('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao" onclick="btnContinuar(); return false;" >' + botao + '</a>');
    }
	
    return false;
}

function msgError(tipo,msg,callback){
	showError(tipo,msg,"Alerta - Ayllos",callback);
}


// P500 - Mout's - Anderson Schloegel
function downloadArquivoRemessaTed(nrseqarq, nomereme){

	/*
	*
	* Faz o download do arquivo de remessas da tela E
	*
	*/

	$.ajax({
        type: "POST",
        url: UrlSite + "telas/uppgto/busca_remessas_arquivo.php",
        data: {
            cddopcao: 'e',
            nrseqarq: nrseqarq,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
        	console.log(' response error: ' , response);
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
        },
        success: function (response) {

			var filename = nomereme;

			var blob = new Blob([response], {type: 'text/csv'});
		    if(window.navigator.msSaveOrOpenBlob) {
		        window.navigator.msSaveBlob(blob, filename);
		    }
		    else{
		        var elem = window.document.createElement('a');
		        elem.href = window.URL.createObjectURL(blob);
		        elem.download = filename;        
		        document.body.appendChild(elem);
		        elem.click();        
		        document.body.removeChild(elem);
		    }


        }

    });

} // fim P500
