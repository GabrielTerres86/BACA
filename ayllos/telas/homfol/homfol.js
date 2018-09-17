/*********************************************************************************************
 FONTE        : homfol.js
 CRIAÇÃO      : Renato Darosci (SUPERO)
 DATA CRIAÇÃO : Julho/2015
 OBJETIVO     : Biblioteca de funções da tela HOMFOL
 --------------
 ALTERAÇÕES   : 
 -------------- 
                                                                                           
***********************************************************************************************/

//Labels/Campos do cabeçalho
var rCddopcao     , cCddopcao     ,
    rDsArquivo    , cDsArquivo    , fDsArquivo     ,
	rDsComprovante, cDsComprovante, cTodosCabecalho, fDsComprovante,
	cQtdregok	  , cQtregerr     , cQtregtot      , cVltotpag     ,
	cQtdcmpok	  , cQtcmperr     , cQtcmptot      , cQtdlinok     ,
	cQtlinerr     , cQtlintot;

var divListMsg ,divListErr, divViewMsg;

$.fn.extend({ 
	
	/*!
	 * Formatar a tabela desta tela, sem setar Ordernação
	 */
	formataTabelaHOMFOL: function(ordemInicial, larguras, alinhamento, metodoDuploClick ) {

		var tabela = $(this);		
		
		// Forma personalizada de extra??o dos dados para ordena??o, pois para n?meros e datas os dados devem ser extra?dos para serem ordenados
		// n?o da forma que s?o apresentados na tela. Portanto adotou-se o padr?o de no in?cio da tag TD, inserir uma tag SPAN com o formato do 
		// dado aceito para ordena??o
		var textExtraction = function(node) {  
			if ( $('span', node).length == 1 ) {
				return $('span', node).html();
			} else {
				return node.innerHTML;
			}		
		}

		// O thead no IE n?o funciona corretamento, portanto ele ? ocultado no arquivo "estilo.css", mas seu conte?do
		// ? copiado para uma tabela fora da tabela original
		var divRegistro = tabela.parent();
		divRegistro.before('<table class="tituloRegistros"><thead>'+$('thead', tabela ).html()+'</thead></table>');		
		
		var tabelaTitulo = $( 'table.tituloRegistros',divRegistro.parent() );	
		
		// $('thead', tabelaTitulo ).append( $('thead', tabela ).html() );
		$('thead > tr', tabelaTitulo ).append('<th class="ordemInicial"></th>');
		
		
		// Formatando - Largura 
		if (typeof larguras != 'undefined') {
			for( var i in larguras ) {
				$('td:eq('+i+')', tabela ).css('width', larguras[i] );
				$('th:eq('+i+')', tabelaTitulo ).css('width', larguras[i] );
			}		
		}	
		
		// Calcula o n?mero de colunas Total da tabela
		var nrColTotal = $('thead > tr > th', tabela ).length;
		
		//$('td:last-child', tabela ).prop('colspan','2');
		
		// Formatando - Alinhamento
		if (typeof alinhamento != 'undefined') {
			for( var i in alinhamento ) {
				var nrColAtual = i;
				nrColAtual++;
				$('td:nth-child('+nrColTotal+'n+'+nrColAtual+')', tabela ).css('text-align', alinhamento[i] );		
			}		
		}			

		$('table > tbody > tr', divRegistro).each( function(i) {
			$(this).bind('click', function() {
				$('table', divRegistro).zebraTabela( i );
			});
		});		

		if ( typeof metodoDuploClick != 'undefined' ) {	
			$('table > tbody > tr', divRegistro).dblclick( function() {
				eval( metodoDuploClick );
			});	

			$('table > tbody > tr', divRegistro).keypress( function(e) {
				if ( e.keyCode == 13 ) {
					eval( metodoDuploClick );
				}
			});	

		}	
		
		$('td:nth-child('+nrColTotal+'n)', tabela ).css('border','0px');
		
		// Iniciar com a primeira linha selecionado e retornar o valor da chave deste primerio registro, que se encontra no input do tipo hidden
		tabela.zebraTabela(0);	
		return true;
	}
});

$(document).ready(function() {
	
	estadoInicial();
	
	highlightObjFocus( $('#frmCab') );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
});

// seletores
function estadoInicial() {
	
	divListMsg  = $("#divListMsg");
	divListErr  = $("#divListErr");
	divViewMsg  = $("#divViewMsg");
		
	divListMsg.hide();
	divViewMsg.hide();
	
	divListErr.html('').hide();
		
	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
	$('#frmArquivo').css({'display':'none'});
	$('#frmComprovante').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	
	formataLayout();
	
	cTodosCabecalho.limpaFormulario();
	// Limpar os campos de arquivos
	fDsArquivo[0].reset();
	fDsComprovante[0].reset();
	cDsArquivo.removeClass('campoErro');
	cDsComprovante.removeClass('campoErro');
	
	cTodosCabecalho.habilitaCampo();
	
	cCddopcao.val( 'C' );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	$("#btVoltar","#divBotoes").hide();
	
	cCddopcao.habilitaCampo();
	cCddopcao.focus();

}

function formataLayout() {

	// Cabecalho	
	cTodosCabecalho	 	= $('input[type="text"],select','#frmCab');
		
	cCddopcao			= $('#cddopcao','#frmCab'); 
	rCddopcao			= $('label[for="cddopcao"]','#frmCab'); 
	cDsArquivo			= $('#userfile','#frmArquivo'); 
	rDsArquivo          = $('label[for="userfile"]','#frmArquivo'); 
	cDsComprovante		= $('#userfile','#frmComprovante'); 
	rDsComprovante      = $('label[for="userfile"]','#frmComprovante'); 
	fDsArquivo			= $('#frmArquivo'); 
	fDsComprovante		= $('#frmComprovante'); 
	
	cQtdregok   = $("#qtdregok","#divViewMsg");
	cQtregerr   = $("#qtregerr","#divViewMsg");
	cQtregtot   = $("#qtregtot","#divViewMsg");
	cVltotpag   = $("#vltotpag","#divViewMsg");	
	
	cQtdcmpok	= $("#qtdcmpok","#divViewMsg");
	cQtcmperr	= $("#qtcmperr","#divViewMsg");
	cQtcmptot	= $("#qtcmptot","#divViewMsg");
	cQtdlinok	= $("#qtdlinok","#divViewMsg");
	cQtlinerr	= $("#qtlinerr","#divViewMsg");
	cQtlintot	= $("#qtlintot","#divViewMsg");
		
	cCddopcao.css({'width':'400px'});
	rCddopcao.css('width','44px');

	return false;	
}

function liberaCampos() {

	if ( cCddopcao.hasClass('campoTelaSemBorda')  ) { return false; }	

	$("#btVoltar","#divBotoes").show();
	
	if (cCddopcao.val() == "C") {
		// Mostra form Comprovantes
		$('#frmComprovante').css({'display':'block'});
		$("#btArquivo","#divBotoes").hide();
		$("#btComprovante","#divBotoes").show();		
	} else {
	    if (cCddopcao.val() == "F") {
			// Mostra form Arquivos
			$('#frmArquivo').css({'display':'block'});
			$("#btArquivo","#divBotoes").show();
			$("#btComprovante","#divBotoes").hide();
		}
	}
	
	// Desabilita o campo de opção
	cCddopcao.desabilitaCampo();
		
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	return false;
}
	
function btnVoltar() {
	
	estadoInicial();
	return false;
}

function realizaOperacao(inOperacao) {
	
	var mensagem = 'Aguarde, validando arquivo ...';
	var cUserFile;
	var formEnvia;
	
	// Remove propriedades dos campos
	cDsArquivo.removeClass('campoErro');
	cDsComprovante.removeClass('campoErro');
	
	var NavVersion = CheckNavigator();
	
	// Link para o action do formulario
	action = UrlSite + 'telas/homfol/manter_rotina.php';
	
	// Verifica se é arquivo ou comprovante
	if (inOperacao == 'C') {
		// Se o campo de comprovante estiver sem valor informado
		if (cDsComprovante.val().length == 0) {
			showError("error",'Arquivo a ser carregado deve ser informado.',"Alerta - Ayllos","focaCampoErro('userfile','frmComprovante')");
			return false; 
		}
		cUserFile = cDsComprovante;
		formEnvia = $('#frmComprovante');
		$('#cddopcao','#frmComprovante').remove();
		formEnvia.append('<input type="hidden" id="cddopcao" name="cddopcao" value="C" />');
		$('#resumoarquivo'    ,'#divViewMsg').css({'display':'none'});
		$('#resumocomprovante','#divViewMsg').css({'display':'block'});
	} else {
		if (inOperacao == 'F') {
			// Se o campo de arquivo estiver sem valor informado
			if (cDsArquivo.val().length == 0) {
				showError("error",'Arquivo a ser carregado deve ser informado.',"Alerta - Ayllos","focaCampoErro('userfile','frmArquivo')");
				return false; 
			}
			cUserFile = cDsArquivo;
			formEnvia = $('#frmArquivo');
			$('#cddopcao','#frmArquivo').remove();
			formEnvia.append('<input type="hidden" id="cddopcao" name="cddopcao" value="F" />');
			$('#resumoarquivo'    ,'#divViewMsg').css({'display':'block'});
			$('#resumocomprovante','#divViewMsg').css({'display':'none'});
		} else {
			return false;
		}
	}

	// Incluir o campo de login para validação (campo necessario para validar sessao)
	$('#sidlogin',formEnvia).remove();
	formEnvia.append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	// Incluir o número da conta
	$('#nrdconta','#frmComprovante').remove();
	formEnvia.append('<input type="hidden" id="nrdconta" name="nrdconta" value="' +  + '" />');
	// Seta o valor conforme id do menu
	$('#sidlogin',formEnvia).val( $('#sidlogin','#frmMenu').val() );
		
	// Configuro o formulário para posteriormente submete-lo
	formEnvia.attr('method','post');
	formEnvia.attr('action',action);
	formEnvia.attr("target",'frameBlank');		
	
	// Mensagem de aguardo...
	showMsgAguardo(mensagem);
	
	// Limpa a lista de erro e faz o submit do formulário
	$('#divListErr').html('');
	formEnvia.submit();
	
	return false;
	
}

function formataTabListMsg() {

	var divRegistro = $('div.divRegistros','#divListMsg');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'220px'});
		
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
	
	// Se a opção selecionada for comprovante
	if (cCddopcao.val() == "F") {
		
		divListMsg.css({'width':'750px'});
		divRegistro.css({'width':'750px'});
		
		var arrayLargura = new Array();
		arrayLargura[0] = '30px';
		arrayLargura[1] = '65px';
		arrayLargura[2] = '95px';
		arrayLargura[3] = '130px';
		arrayLargura[4] = '95px';
		arrayLargura[5] = '';
		arrayLargura[6] = '14px';
		
			
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'left';
		
	} else {
		
		divListMsg.css({'width':'900px'});
		divRegistro.css({'width':'900px'});
		
		var arrayLargura = new Array();
		arrayLargura[0] = '45px';
		arrayLargura[1] = '80px';
		arrayLargura[2] = '95px';
		arrayLargura[3] = '170px';
		arrayLargura[4] = '40px';
		arrayLargura[5] = '80px';
		//arrayLargura[6] = ;
		arrayLargura[7] = '15px';
		
			
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'center';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'left';
		
	}
	
	var metodoTabela = '';
		
	tabela.formataTabelaHOMFOL( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function msgError(tipo,msg,callback){
	showError(tipo,msg,"Alerta - Ayllos",callback);
}