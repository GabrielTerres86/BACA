/*!
/*!
 * FONTE        : funcoes.js
 * CRIA??O      : Jean Michel
 * DATA CRIA??O : Junho/2015
 * OBJETIVO     : Biblioteca de funcoes JavaScript
 * --------------
 * ALTERAÇÕES   : 29/10/2015 - Inclusão da função validaMesAno e Alteração da validaData - Vanessa
 *				        30/11/2015 - Criacao da function montaSelect() para montagem dos selects de eixo,tema,evento - Carlos Rafael
 *				        15/12/2015 - Adicionei a forma correta de selecao(option:selected) para os campos cdcooperPesquisa,cdagenciPesquisa - Carlos Rafael
 * --------------
 */ 	 

    
var nmrotina    = ''; // Para armazenar o nome da rotina no uso da Ajuda (F2)
var semaforo	= 0;  // Semáforo para n?o permitir chamar a função controlaOperacao uma atr?s da outra

var divRotina; 	// Variável que representa a Rotina com a qual está se trabalhando
var divError;  	// Variável que representa a div de Erros do sistema, usada para mensagens de Erros e Confirmações
var divConfirm;	// Variável que representa a div de Erros do sistema, usada para mensagens de Erros e Confirmações

var exibeAlerta = true;		// Variável lógica (boolean) glogal que libera a função "alerta()" chamar os alert() do javascript
var shift		= false; 	// Variável lógica (boolean) glogal que indica se a tecla shift está prescionada
var control		= false; 	// Variável lógica (boolean) glogal que indica se a tecla control está prescionada

var arrcoper = "";					
var arrregio = "";
var arragenc = "";
var arrdtano = "";
var dataAtual = new Date(); 
//var anoAtual = dataAtual.getYear();
var mesAtual = dataAtual.getMonth();
var diaAtual = dataAtual.getDate();
var arrMeses = new Array("0","1","2","3","4","5","6","7","8","9","10","11","12")
	
$(document).ready(function() {
	
	
	$("body").append('<div id="divAguardo" name="divAguardo"></div><div id="divConfirm"></div><div id="divBloqueio"></div><div id="divUsoGenerico"></div>');
	
	// Inicializo a Variável divRotiva e divError com o respectivo seletor jQuery da div
	// A qualquer momento pode-se alterar o valor da divRotina com a Rotina que está sendo implementada
	// O valor do divError n?o tem motivos para ser alterado
	divRotina 	= $('#divRotina');
	divError  	= $('#divError');	
	divConfirm  = $('#divConfirm');	
	
	// Iniciliza tirando os eventos para posteriormente bind?-los corretamente
	$(this).unbind('keyup').unbind('keydown').unbind('keypress');	
	
	$(this).unbind("keydown.backspace").bind("keydown.backspace",function(e) {
		if (getKeyValue(e) == 8) { // Tecla BACKSPACE
			var targetType = e.target.tagName.toUpperCase();			
			// Permite a tecla BACKSPACE somente em campos INPUT e TEXTAREA e se estiverem habilitados para digita??o			
			if ((targetType == "INPUT" || targetType == "TEXTAREA") && !e.target.disabled && !e.target.readonly) return true;							
			return false; 
		}		
		return true;
	});
	
	$.ajaxSetup({ data: { sidlogin: $("#sidlogin","#frmMenu").val() } });
	
	/*!
	 * ALTERA??O     : 022
	 * OBJETIVO      : Prevenir o comportamento padr?o do browser em rela??o as teclas F1 a F12, para posteriormente utilizar estas teclas para fins espec?ficos 
	 * FUNCIONAMENTO : Captura o evento da tecla pressionada e associa ? função previneTeclasEspeciais funcionando para IE, Chrome e FF
	 */	
	$(this).keydown( previneTeclasEspeciais );
	function previneTeclasEspeciais(event){		
		// Essecial para funcionar no IE 
		var e = (window.event) ? window.event : event;
		// Verifica se a tecla pressionada ? F1 a F12 retirando a F5
		if ( ( e.keyCode >= 112 ) && ( e.keyCode <= 123 ) && ( e.keyCode != 116 ) ) { 
			if ( $.browser.msie ) {
				e.returnValue	= false; // Previne o comportamento padr?o no IE
				e.cancelBubble 	= true;  // Previne o comportamento padr?o no IE
				e.keyCode       = 0;     // Previne o comportamento padr?o no IE
				document.onhelp = new Function("return false"); // Previne a abertura do help no IE
				window.onhelp 	= new Function("return false"); // Previne a abertura do help no IE
			} else {
				e.stopPropagation(); // Previne o comportamento padr?o nos browsers bons
				e.preventDefault();  // Previne o comportamento padr?o nos browsers bons
			}
		}
	}
	
	/*!
	 * ALTERA??O     : 035
	 * OBJETIVO      : Controle de identifica??o se as teclas shift e control estáo pressionadas
	 * FUNCIONAMENTO : Ao pressionar qualquer tecla, o sistema verifica se ? a shift/control, caso verdadeiro seta a Variável global 
	 *                 correspondente para TRUE. Ao liberar a tecla, o sistema verifica novamente se ? shift/control, caso afirmativo
	 *                 volta os valores das Variávels globais correspondentes para FALSE.
	 */		
	$(this).keydown( function(e) {
		if (e.which == 16 ) { shift 	= true; } // Tecla Shift		
		if (e.which == 17 ) { control 	= true; } // Tecla Control
	}).keyup( function(e) {
		if (e.which == 16 ) { shift 	= false; } // Tecla Shift		
		if (e.which == 17 ) { control 	= false; } // Tecla Control
	});
	
	/*!
	 * ALTERA??O  : 018 e 051
	 * OBJETIVO   : Teclas de atalho para selecinar os registro nas tabelas pelo teclado, utilizando as setas direcionais "para cima" e "para baixo"
	 * OBSERVA??O : As tabelas devem estar criadas dentro do padr?o adotado nas rotinas no m?dulo de CONTAS
	 */	
	$(this).keyup( function(e) { 			
		var tecla = e.which;	
		if ( (tecla == 38) || (tecla == 40) ) {
			
			var nrLinhaSelecao;	
			var divRegistro;	
			var divRegistros;	
			
			if ( divError.css('display') == 'block' || divConfirm.css('display') == 'block' ){
				return true;
			}else if ( $('#divUsoGenerico').css('visibility') == 'visible' ){
				divRegistros = $('div.divRegistros','#divUsoGenerico');
			}else if( $('#divRotina').css('visibility') == 'visible' && $('div.divRegistros','#divRotina').length ){
				divRegistros = $('div.divRegistros','#divRotina');
			}else if( $('#divMatric').css('visibility') == 'visible' || $('#divMatric').css('visibility') == 'inherit' ){
				divRegistros = $('div.divRegistros','#divMatric');
			}else {
				if ( $('#divRotina').css('visibility') == 'visible') return false;
				divRegistros = $('div.divRegistros');
			}		
				
			divRegistros.each( function() {
				if ( $(this).css('display') == 'block' ) {
					divRegistro = $(this);
				}				
			});			
			
			var tabela = $('table', divRegistro);
			
			var qtdeRegistros = $('table > tbody > tr', divRegistro).length;
			// Se possui um ou nenhum registro, n?o fazer nada
			if ( qtdeRegistros > 1 ) { 
				// Descobre qual linha está selecionada
				$('table > tbody > tr', divRegistro).each( function(i) {
					if ( $(this).hasClass( 'corSelecao' ) ) {
						nrLinhaSelecao = i;
					}					
				});	
				// Se teclou seta para cima e n?o ? a primeira linha, selecionar registro acima
				if ( (tecla == 38) && (nrLinhaSelecao > 0) ) {
					$('table', divRegistro).zebraTabela( nrLinhaSelecao - 1 );
					$('tbody > tr:eq('+(nrLinhaSelecao - 1)+') > td', tabela ).first().focus();
				}
				// Se teclou seta para baixo e n?o ? a ultima linha, selecionar registro abaixo
				if ( (tecla == 40) && (nrLinhaSelecao < qtdeRegistros - 1) ) {
					$('table', divRegistro).zebraTabela( nrLinhaSelecao + 1 );
					$('tbody > tr:eq('+(nrLinhaSelecao + 1)+') > td', tabela ).first().focus();
				}			
			}
		}
	});				
	
	/*!
	 * ALTERA??O  : 011
	 * OBJETIVO   : Teclas de atalho (HotKeys) para os bot?es da tela corrente (em exibi??o)
	 * PADR?O     : (   F1   ) -> Bot?o Salvar (Concluir)
	 *              (   F2   ) -> Ajuda da CECRED
	 *              (   F3   ) -> Bot?o Inserir
	 *              (   F4   ) -> Bot?o Voltar (ESC)
	 *              (   F5   ) -> Atualizar p?gina ( N?o presica implementar, pois ? padr?o do Browser )
	 *              (   F7   ) -> Abre Pesquisa ( Implementa??o na função layoutrPadrao() )
	 *              (   F8   ) -> Limpar Campo  ( Implementa??o na função layoutrPadrao() )
	 *              (   F9   ) -> Bot?o Alterar
	 *              (   F10  ) -> Bot?o Consultar
	 *              (   F11  ) -> Bot?o Limpar
	 *              ( DELETE ) -> Bot?o Excluir
	 *              (   ESC  ) -> Bot?o Voltar
	 *              ( INSERT ) -> Bot?o Inserir	 
	 * OBSERVA??O : Para que os atalhos funcionem, os bot?es em tela devem estar com a propriedade "id" igual a um dos valores abaixo:
	 *              btIncluir | btExcluir | btVoltar | btAlterar | btSalvar | btConsultar | btLimpar
	 */	 
	$(this).keyup( atalhoTeclado );
	function atalhoTeclado(e) {

		var arrayTeclas  = new Array();		
		arrayTeclas[13]  = 'btEnter';		// ENTER		
		arrayTeclas[45]  = 'btIncluir';		// INSERT
		arrayTeclas[46]  = 'btExcluir';		// DELETE
		arrayTeclas[27]  = 'btVoltar';		// ESC - VOLTAR
		arrayTeclas[112] = 'btSalvar';		// F1  - SALVAR
		arrayTeclas[114] = 'btIncluir';		// F3  - INSERIR
		arrayTeclas[115] = 'btVoltar';		// F4  - VOLTAR	
		arrayTeclas[120] = 'btAlterar';		// F9  - ALTERAR
		arrayTeclas[121] = 'btConsultar';   // F10 - CONSULTAR		
		arrayTeclas[122] = 'btLimpar';      // F11 - LIMPAR
		
		// Se o divAguardo estiver sendo exibido, ent?o n?o aceitar atalhos do teclado
		if ( $('#divAguardo').css('display') == 'block' ) { return true; }

		/*!
		 * ALTERA??O : 017
		 * OBJETIVO  : Quando o divError estiver vis?vel na tela, e a tecla ? ESC (27) ou F4 for pressionada, ent?o chamar o clique do bot?o "N?o" do divError,
		 *             pois caso contr?rio a função chama o clique o bot?o com o ID = 'btVoltar'
		 */
		if ( divError.css('display') == 'block' ) {
			// Se teclar ENTER (13)	
			if (e.which == 13) {
				// $('#btnError','#divError').click();
			}			
			return true;				

		} else if ( divConfirm.css('display') == 'block' ) {
			// Se teclar ESC (27) ou F4 (115)
			if ( (e.which == 27) || (e.which == 115) ) {
				$('#btnNoConfirm','#divConfirm').click();	
			}
			return true;
			
		// Se for tecla F2, abre ajuda padr?o		
		} else if ( e.keyCode == 113 ) {
			mostraAjudaF2();
			return true;			
			
		// Se for as teclas ENTER | INSERT | DELET | ESC | F1 | F3 | F4 | F9 | F10 | F11
		} else if (in_array(e.keyCode,[13,35,45,46,27,112,114,115,120,121,122])) {	
			
			if( typeof e.result == 'undefined' ) {
			
				// Se a pesquisa estiver aberta, e a tecla ? ESC (27) ou F4, ent?o ativar o bot?o fechar da pesquisa				
				// ALTERA??O 040
				if ( $('#divFormularioEndereco').css('visibility') == 'visible' ) {
					if ( e.which == 27 || e.which == 115 ) {
						$('.fecharPesquisa','#divFormularioEndereco').click();
					} else {
						$('#'+arrayTeclas[e.which]+':visible','#divFormularioEndereco').click();
					}					
					return true;
				
				// ALTERA??O 040
				} else if ( $('#divPesquisaEndereco').css('visibility') == 'visible' ) {
					if ( e.which == 27 || e.which == 115 ) {
						$('.fecharPesquisa','#divPesquisaEndereco').click(); 
					} else {
						$('#'+arrayTeclas[e.which]+':visible','#divPesquisaEndereco').click();
					}					
					return true;				
					
				} else if ( $('#divPesquisaAssociado').css('visibility') == 'visible') {
					if ( e.which == 27 || e.which == 115 ) {
						$('.fecharPesquisa','#divPesquisaAssociado').click();
					} 
					return true;						
					
				} else if ( $('#divPesquisa').css('visibility') == 'visible') {
					if ( e.which == 27 || e.which == 115 ) {
						$('.fecharPesquisa','#divPesquisa').click();
					} 
					return true;														
				
				// Verifica HotKeys v?lidos					
				} else if (in_array(e.which,[13,35,45,46,27,112,114,115,120,121,122])) {
					
					// Se a divUsoGenerico estiver visivel, ent?o chamar os click os bot?es contidos nela
					if ( $('#divUsoGenerico').css('visibility') == 'visible' ) {
						$('#'+arrayTeclas[e.which]+':visible','#divUsoGenerico').click();
						return true; 
					
					// Se a divRotina estiver visivel, ent?o chamar os click os bot?es contidos nela
					// 050 - adicionado a opcao btsair
					}else if( $('#divRotina').css('visibility') == 'visible' ) {
						if ( $('#divRotina').find('#'+arrayTeclas[e.which]).length ) {
							$('#'+arrayTeclas[e.which]+':visible','#divRotina').click();
						} else if ( $('#divRotina').find('#btSair').length && e.which == 27 ) {
							$('#btSair:visible','#divRotina').click();
						}
						return true; 	
					
					// Se ? a tela do Matric, chamar os click dos bot?es contidos nela
					}else if( $('#divMsgsAlerta').css('visibility') == 'visible' ) {
						$('#'+arrayTeclas[e.which]+':visible','#divMsgsAlerta').click();
						return true; 
					
					// Se ? a tela do Matric, chamar os click dos bot?es contidos nela
					}else if( $('#divAnota').css('visibility') == 'visible' || $('#divAnota').css('visibility') == 'inherit' ) {
						$('#'+arrayTeclas[e.which]+':visible','#divAnota').click();
						return true;

					// Se a divRotina estiver visivel, ent?o chamar os click os bot?es contidos nela
					}else if( $('#divTela').css('visibility') == 'visible' || $('#divTela').css('visibility') == 'inherit' ) {
						$('#'+arrayTeclas[e.which]+':visible','#divTela').click();
						return true; 						
					
					// Se ? a tela do Matric, chamar os click dos bot?es contidos nela
					}else if( $('#divMatric').css('visibility') == 'visible' || $('#divMatric').css('visibility') == 'inherit' ) {									
						
						//Se ? pessoa juridica verifico se ? um evento do bot?o de procuradores
						if( $('#frmJuridico','#divMatric').css('visibility') == 'visible' || $('#frmJuridico','#divMatric').css('visibility') == 'inherit' ){
							
							var metodo = $('#'+arrayTeclas[e.which]+'Proc:visible','#divMatric').attr('onClick');
							metodo = ( typeof metodo == 'undefined' ) ? '' : metodo.toString() ;
							
							if ( $.browser.msie ) {
								metodo = metodo.replace('return false;','');
								metodo = metodo.replace('function anonymous()','');
								metodo = metodo.replace('{','');
								metodo = metodo.replace('}','');
							}else{
								metodo = metodo.replace('return false;','');
							}	
												
							eval( metodo );
						}
						$('#'+arrayTeclas[e.which]+':visible','#divMatric').click();
						return true; 
					}						
					return true; 				
				}
			}
		}
	}
		
	/*!
	 * ALTERA??O  : 019 | 040
	 * OBJETIVO   : Tornar as mensagens padr?o de Erro ou Confirma??o "Moviment?veis", permitindo arrastar a janela para qualquer dire??o, com o objetivo
	 *              de desobstruindo os dados que se encontram logo abaixo da caixa de mensagem. Funcionalidade replicada as telas de rotinas.
	 */	 
	var elementosDrag = $('#divRotina, #divError, #divConfirm, #divPesquisa, #divPesquisaEndereco, #divFormularioEndereco, #divPesquisaAssociado, #divUsoGenerico, #divMsgsAlerta');
	elementosDrag.unbind('dragstart');	
	elementosDrag.bind('dragstart',function( event ){
		return $(event.target).is('.ponteiroDrag');
    }).bind('drag',function( event ){
		$( this ).css({ top: event.offsetY, left: event.offsetX });		
    });  	
	
});


function highlightObjFocus(parentElement) {			
	// Verificar se o elemento pai ? um objeto v?lido
	if ($.type(parentElement) != 'object' || parentElement.size() == 0) return false;
	
	// Faz pre-sele??o dos sub-elementos 
	var subElements = $('input',parentElement);
	
	// Verificar se o elemento pai tem sub-elementos	
	if (subElements.size() == 0) return true;
	
	var validTypes = new Array();
	validTypes[1] = 'textarea';
	validTypes[2] = 'text';
	validTypes[3] = 'image';
	validTypes[4] = 'password';
	validTypes[5] = 'radio';
	validTypes[6] = 'checkbox';
	validTypes[7] = 'select';
	
	$('input,textarea',parentElement).each(function() {					
		var typeElement = $(this).attr('type') != undefined ? $(this).attr('type') : $(this).get(0).tagName.toLowerCase();
		
		if (in_array(typeElement,validTypes)) {			
			$(this).unbind('focusout.highlightfocus')
			       .unbind('focusin.highlightfocus')
				   .bind('focusout.highlightfocus',function() {
						if (typeElement == 'image') {
							if ($(this).attr('src') == UrlImagens + 'botoes/entrar_focus.gif')
								$(this).attr('src',$(this).attr('src').replace('_focus.gif','.gif'));
						} else {
							$(this).removeClass(function() {
										if (typeElement == 'text' || typeElement == 'password' || typeElement == 'select') {
											return 'campoFocusIn';											
										} else {
											return typeElement + 'FocusIn';
										}
								    })
								   .addClass(function() {
										if (typeElement == 'text' || typeElement == 'password' || typeElement == 'select') {
											return 'campo';
										} else {											
											return typeElement;
										}
									})
						}
				    })
				   .bind('focusin.highlightfocus',function() {						
						if (typeElement == 'image') {							
							if ($(this).attr('src') == UrlImagens + "botoes/entrar.gif")
								$(this).attr('src',$(this).attr('src').replace('.gif','_focus.gif'));															
						} else {																	
							$(this).removeClass(function() {
										if (typeElement == 'text' || typeElement == 'password' || typeElement == 'select') {
											return 'campo';
										} else {											
											return typeElement;
										}
									})
								   .addClass(function () {
										if (typeElement == 'text' || typeElement == 'password' || typeElement == 'select') {
											return 'campoFocusIn';
										} else {											
											return typeElement + 'FocusIn';
										}
								    });
						}
				    });
					
		}
	});
	
	return true;	
}



/*!
 * OBJETIVO: função para bloquear conte?do atr?s de um div
 */
function blockBackground(zIndex) {
	$("#iframeBloqueio").css({
		width: "100%",
		height: "125%",//$(document).height() + "px",
		zIndex: zIndex - 2,
		display: "block"
	}); 	
	// Propriedados do div utilizado no bloqueio
	$("#divBloqueio").css({
		width: "100%",
		height: "125%",//$(document).height() + "px",
		zIndex: zIndex - 1,
		display: "block"
	}); 
}

/*!
 * OBJETIVO: função para desbloquear conte?do atr?s de um div
 */
function unblockBackground() { 
	// Propriedades do div utilizado no bloqueio
	$("#divBloqueio").css({
		width: "1px",
		height: "1px",
		top: "0",
		left: "0",
		display: "none"
	});	
	$("#iframeBloqueio").css({
		width: "1px",
		height: "1px",
		top: "0",
		left: "0",
		display: "none"
	});
}

/*!
 * OBJETIVO  : função para mostrar mensagem de erro ou notifica??o
 * ALTERA??O : 019 - Para permitir Movimentar a mensagem de Error, alterou-se a forma de centraliza??o da mensagem
 * ALTERA??O : 039 - Condi??o do tipoMsg, caso venha com 'none' n?o mostrar? ?cone.
 * ALTERA??O : 047 - Parametro numWidth opcional, largura da tabela de mensagem, caso nao seja passado, pega 300 como padrao.
 */	 
function showError(tipoMsg,msgError,titMsg,metodoMsg,numWidth) {
	
	// Construindo conte?do da mensagem
	var strHTML = '';
	var display = '';	
	
	if(tipoMsg == 'none')
		display = 'display:none;';
	
	larg = Number(numWidth);	
	
	if (isNaN(larg)) {		
		larg = 300; // largura padrao
	}
		
	strHTML += '<table border="0" cellpadding="0" cellspacing="0" width="' + larg + '" id="tabMsgError">';
	strHTML += '	<tr>';
	strHTML += '		<td id="tdTitError" class="ponteiroDrag">' + titMsg + '</td>';
	strHTML += '	</tr>';
	strHTML += '	<tr>';
	strHTML += '		<td height="5"></td>';
	strHTML += '	</tr>';	
	strHTML += '	<tr>';
	strHTML += '		<td style="padding: 4px 6px 4px 6px;">';	
	strHTML += '			<table border="0" cellpadding="0" cellspacing="0">';
	strHTML += '				<tr>';
	strHTML += '					<td valign="top" style="padding-right: 5px;' + display + '"><img src="' + UrlImagens + (tipoMsg == "inform" ? "geral/ico_inform.jpg" : "geral/ico_atencao.jpg") + '"></td>';
	strHTML += '					<td class="' + (tipoMsg == "inform" ? "txtCarregando" : "txtCritica") + '" nowrap><center>' + msgError + '</center></td>';
	strHTML += '				</tr>';
	strHTML += '			</table>';
	strHTML += '		</td>';
	strHTML += '	</tr>';
	strHTML += '	<tr>';
	strHTML += '		<td height="5"></td>';
	strHTML += '	</tr>';		
	strHTML += '	<tr>';
	strHTML += '		<td align="center" style="padding-bottom: 8px;"><input type="image" id="btnError" name="btnError" src="' + UrlImagens + (tipoMsg == "inform" ? "botoes/fechar.gif" : "botoes/continuar.gif") + '"></td>';
	strHTML += '	</tr>';
	strHTML += '</table>';		
	
	// Atribui o conte?do ao div da mensagem
	divError.html(strHTML);
	
	// Bloqueia o Fundo e Mostra a mensagem
        bloqueiaFundo( divError );
	divError.css('display','block').setCenterPosition();	
	$('#btnError').focus();

	// Aplica m?todos ao evento "click" do bot?o de confirma??o
	$('#btnError').unbind('click').bind('click',function() {		
		// Esconde mensagem
		divError.escondeMensagem();
		// M?todo passado por par?metro
		if ( metodoMsg != '' ) { eval(metodoMsg); }		
		return false;
	});	
	
	return false;
}

/*!
 * OBJETIVO  : função para mostrar mensagem para confirma??o e a??es
 * ALTERA??O : 019 - Para permitir Movimentar a mensagem de Confirma??o, alterou-se esta função
 */	 
function showConfirmacao(msgConfirm,titConfirm,metodoYes,metodoNo,nomeBtnYes,nomeBtnNo) {
	
	// Construindo o conte?do da mensagem
	var strHTML = "";	
	strHTML += '<table border="0" cellpadding="0" cellspacing="0" width="300">';
	strHTML += '	<tr>';
	strHTML += '		<td id="tdTitError" class="ponteiroDrag">' + titConfirm + '</td>';
	strHTML += '	</tr>';
	strHTML += '	<tr>';
	strHTML += '		<td style="padding-top: 4px; padding-right: 6px; padding-left: 6px;">';	
	strHTML += '			<table border="0" cellpadding="0" cellspacing="0">';
	strHTML += '				<tr>';
	strHTML += '					<td style="padding-right: 5px;"><img src="' + UrlImagens + 'geral/ico_interrogacao.jpg' + '"></td>';
	strHTML += '					<td class="txtCarregando" nowrap>' + msgConfirm + '</td>';
	strHTML += '				</tr>';
	strHTML += '			</table>';
	strHTML += '		</td>';
	strHTML += '	</tr>';
	strHTML += '	<tr>';
	strHTML += '		<td align="center" style="padding-bottom: 8px; padding-top: 6px;">';
	strHTML += '			<table border="0" cellpadding="0" cellspacing="0">';
	strHTML += '				<tr>';
	strHTML += '					<td><input type="image" id="btnYesConfirm" name="btnYesConfirm" src="' + UrlImagens + "botoes/" + nomeBtnYes + '"></td>';
	strHTML += '					<td width="25"></td>';		
	strHTML += '					<td><input type="image" id="btnNoConfirm" name="btnNoConfirm" src="' + UrlImagens + "botoes/" + nomeBtnNo + '"></td>';	
	strHTML += '				</tr>';
	strHTML += '			</table>';
	strHTML += '		</td>';
	strHTML += '	</tr>';
	strHTML += '</table>';	
	
	// Atribui o conte?do ao divConfirm
	divConfirm.html(strHTML);
	
	// Aplica m?todos ao evento "click" do bot?o de confirma??o
	$("#btnYesConfirm").unbind("click");
	$("#btnYesConfirm").bind("click",function() {
		// Esconde mensagem
		divConfirm.escondeMensagem();
		// M?todo passado por par?metro
		if (metodoYes != "") { 
			eval(metodoYes); 
		}		
		return false;
	});
	
	// Aplica m?todo ao evento "click" do bot?o de cancelamento
	$("#btnNoConfirm").unbind("click");
	$("#btnNoConfirm").bind("click",function() {
		// Esconde mensagem
		divConfirm.escondeMensagem();
		// M?todo passado por par?metro
		if (metodoNo != "") { eval(metodoNo); }		
		return false;
	});
        
	// Bloqueia o Fundo e Mostra a mensagem
	bloqueiaFundo( divConfirm );
	divConfirm.css('display','block').setCenterPosition();	
	$("#btnYesConfirm").focus(); 
}

/*!
 * OBJETIVO  : função para mostrar mensagem de Aguardo
 * ALTERA??O : 019 - Para permitir Movimentar a mensagem de Aguardo, alterou-se esta função
 */	 
function showMsgAguardo(msgAguardo) {
	
	// Mensagem de espera
	var strHTML = "";
	strHTML += '<table border="0" cellpadding="0" cellspacing="0">';
	strHTML += '  <tr>';
	strHTML += '    <td><img src="/web/imagens/indicator.gif" width="15" height="15"></td>';
	strHTML += '    <td nowrap><strong class="txtCarregando">&nbsp;&nbsp;&nbsp;' + msgAguardo + '</strong></td>';
	strHTML += '  </tr>';
	strHTML += '</table>';		
	
	// Atribui conte&uacute;do ao div da mensagem
	$('#divAguardo').html(strHTML);
	
	// Bloqueia o Fundo e Mostra a mensagem
	bloqueiaFundo( $('#divAguardo') );
	$('#divAguardo').css('display','block').setCenterPosition();	
}

/*!
 * OBJETIVO  : função para esconder (ocultar) a mensagem de aguardo
 * ALTERA??O : 019 - Alterou-se a função utilizando-se do novo m?todo criado "escondeMensagem()", implementado neste arquivo
 */	
function hideMsgAguardo() {
	$("#divAguardo").escondeMensagem();;
}	

/*!
 * OBJETIVO  : Retirar caracteres indesejados
 * PAR?METROS: flgRetirar -> Se TRUE retira caracteres que n?o estáo na Variável "valid"
 *                           Se FALSE retira caracteres que estáo na Variável "valid"    
 */	
function retiraCaracteres(str,valid,flgRetirar) {
	
	var result = "";	// Variável que armazena os caracteres v&aacute;lidos
	var temp   = "";	// Variável para armazenar caracter da string
	
	for (var i = 0; i < str.length; i++) {
		temp = str.substr(i,1);
			
		// Se for um n&uacute;mero concatena na string result
		if ((valid.indexOf(temp) != "-1" && flgRetirar) || (valid.indexOf(temp) == "-1" && !flgRetirar)) {
			result += temp;
		}
	}
	
	return result;		
}

/*!
 * OBJETIVO  : função para validar o n?mero da conta/dv
 * PAR?METRO : conta [Obrigat?rio] -> N?mero da conta que deseja-se validar. Aceita somente n?meros
 */	
function validaNroConta(conta) {

	// 057
	conta = normalizaNumero(conta);
	
	if (parseInt(conta) == 0) {
		return false;
	}
	
	if (conta != "" && conta.length < 9) {
		var mult    = 2;
		var soma    = 0;
		var tam     = conta.length;
		var str_aux = 0;
		
		for (var i = tam - 2; i >= 0; i--) {
			str_aux = parseInt(conta.substr(i,1));
			soma = soma + (str_aux * mult);
			mult++;
		}

		var div = soma % 11;

		if (div > 1) {
			div = 11 - div;
		}	else {
			div = 0;
		}

		if (div == conta.substr((tam - 1),1)) {
			return true;
		}
	}
	
	return false;
}

/*!
 * OBJETIVO  : função para retirar zeros at? encontrar outro n?mero maior
 * PAR?METRO : numero [Obrigat?rio] -> N?mero a ser retirado os zeros a esquerda
 */	
function retirarZeros(numero) {
	var flgMaior = false; // Flag para verificar se foi encontrado o primeiro n&uacute;mero maior que zero
	var result   = "";    // Armazena conteudo de retorno
	var temp     = "";    // Armazena caracter temporario do numero
	
	// Efetua leitura de todos os caracteres do numero e atribui a vari&aacute;vel temp
	for (var i = 0; i < numero.length; i++) {
		temp = numero.substr(i,1);
		
		if ((temp == '0') && (numero.substr(i+1,1) != ',')) { 
			if (flgMaior) { // Se j? foi encontrado um n?mero maior que zero
				result += temp;
			}
		} else if (!isNaN(temp)) { // Se for um n?mero maior que zero
			result += temp;
			
			if (!flgMaior) {
				flgMaior = true; 
			}
		} else if (flgMaior) { // Se n?o for um n?mero
			result += temp;
		}
	}
	
	return result;
}

/*!
 * OBJETIVO  : função para retornar c?digo da tecla pressionada
 */	
function getKeyValue(e) {
	// charCode para Firefox e keyCode para IE
	var keyValue = e.charCode ? e.charCode : e.keyCode ? e.keyCode : 0;	
	return keyValue;
}

/*!
 * OBJETIVO : função para validar se ? uma data v?lida
 */	
function validaData(data, tipo,dtanoage) {
	// Se string n&atilde;o conter 10 caracteres
	if (data.length != 10) {
		return false;
	}
	
	var dia = parseInt(data.substr(0,2),10); 
	var mes = parseInt(data.substr(3,2),10);
	var ano = parseInt(data.substr(6));
		
	
	if (isNaN(dia) || isNaN(mes) || isNaN(ano) || String(ano).length != 4) {
		return false; 
	}

	// Valida n&uacute;mero do m&ecirc;s
	if (mes < 1 || mes > 12) {
		return false;
	}

	// Valida se m&ecirc;s X possui 31 dias
	if ((mes == 1 || mes == 3 || mes == 5 || mes == 7 || mes == 8 || mes == 10 || mes == 12) && (dia < 1 || dia > 31)) {
		return false;
	}

	// Valida se m&ecirc;s X possui 30 dias
	if ((mes == 4 || mes == 6 || mes == 9 || mes == 11) && (dia < 1 || dia > 30)) {
		return false;
	}

	// Valida n&uacute;mero de dias para o m&ecirc;s de Fevereiro
	if (mes == 2) {
		if (dia < 1) {
			return false;
		}

		var bissexto = false;
		
		// Calcula para verificar se &eacute; ano bissexto
		if (ano % 100 == 0) {
			if (ano % 400 == 0) { 
				bissexto = true;
			}
		}	else {
			if ((ano % 4) == 0) { 
				bissexto = true;
			}
		}		

		if (bissexto) { // Se for ano bissexto
			if (dia > 29) {
				return false;
			} 
		}	else { // Se n&atilde;o for ano bissexto
			if (dia > 28) {
				return false;
			}
		}
	}
	
	if(tipo == 'A'){ //atual ou futuro 
	
		if (ano <  dataAtual.getYear()){ 
			return false;
		}
		
		if(dtanoage != ano){ 
		   return false; 
		}
		
		if( ano <  dataAtual.getYear() && mes < arrMeses[mesAtual]){ 
		  return false; 
		}  
		
		//if( ano <=  dataAtual.getYear() && mes <= arrMeses[mesAtual] && dia < diaAtual){
		if(data <= dataAtual){		
			return false; 
		}
	} 
	return true;
}
function validaMesAno(data,tipo,dtanoage) {	

	var mes = parseInt(data.substr(0,2),10);
	var ano = parseInt(data.substr(3),10);
	
	// Se string n&atilde;o conter 10 caracteres
	if (data.length != 7) { 
		return false;
	}		
	
	if(tipo == 'A'){ //atual ou futuro 
		if (ano < dataAtual.getYear()){   
			return false;
		}
		
		if(dtanoage != ano){  
			return false;
		}
		
		if(ano < dataAtual.getYear() && mes < arrMeses[mesAtual]){  
		  return false;
		}
	}
	
	if (isNaN(mes) || isNaN(ano) || String(ano).length != 4) {  
		return false;  
	}

	// Valida n&uacute;mero do m&ecirc;s
	if (mes < 1 || mes > 12) {  alert(6);
		return false;  
	}

	
	return true;
}
/*!
 * OBJETIVO  : função para validar n?meros inteiros e decimais
 */	
function validaNumero(numero,validaFaixa,minimo,maximo) {
	// Retirar "." e "," do numero	
	numero = numero.replace(/\./g,"").replace(/,/g,"."); 	
	
	// Verifica se &eacute; um n&uacute;mero inteiro ou decimal
	numero = numero.search(".") == "-1" ? parseInt(numero) : parseFloat(numero); 
	
	// Se n&atilde;o for um n&uacute;mero v&aacute;lido
	if (isNaN(numero)) {
		return false;
	}
	
	// Se par&acirc;metro for true, verifica se n&uacute;mero est&aacute; dentro de uma faixa v&aacute;lida
	if (validaFaixa) {
		if (minimo == maximo) {
			if (numero >= minimo && numero <= maximo) {
				return false;
			}
		} else {
			if (numero < minimo || numero > maximo) {
				return false;
			}
		}
	}
	
	return true;
}

/*!
 * OBJETIVO   : função para validar CPF ou CNPJ
 * PAR?METROS : cpfcnpf [String ] -> [Obrigat?rio] N?mero do CPF ou CNPJ a ser validado
 *              tipo    [Integer] -> [Obrigat?rio] Tipos v?lidos: (1) para CPF e (2) para CNPJ
 */	
function validaCpfCnpj(cpfcnpj,tipo) {

	// 058
	cpfcnpj = normalizaNumero(cpfcnpj);
	
	var strCPFCNPJ = new String(parseFloat(cpfcnpj));

	if (tipo == 1) { //CPF
		var invalid = "";
		var peso    = 9;
		var calculo = 0;
		var resto   = 0;

		if (strCPFCNPJ.length < 5) {
			return false;
		}
		
		for (var i = 1; i < 10; i++) {
			for (var j = 0; j < 11; j++) {
				invalid += i;
			}

			if (strCPFCNPJ == invalid) {
				return false;
			}
			
			invalid = "";
		}
		
		for (i = strCPFCNPJ.length - 3; i >= 0; i--) {
			 calculo = parseInt(calculo) + parseInt(strCPFCNPJ.substr(i,1)) * peso;
			 peso--;
		}
		
		resto = parseInt(calculo) % 11;
		
		if (resto == 10) {
			digito = 0;
		} else {
			digito = resto;
		}

		peso    = 8;
		calculo = digito * 9;
		
		for (i = strCPFCNPJ.length - 3; i >= 0; i--) {
			 calculo = parseInt(calculo) + parseInt(strCPFCNPJ.substr(i,1)) * peso;
			 peso--;
		}		
		
		resto = parseInt(calculo) % 11;
		
		if (resto == 10) {
			digito = digito * 10;
		} else {
			digito = (digito * 10) + resto;
		}
		
		if (strCPFCNPJ.substr(strCPFCNPJ.length - 2,2) != digito) {
			return false;
		} else {
			return true;
		}
	} else if (tipo == 2) { //CNPJ
		if (strCPFCNPJ.length < 3)
			return false;
			
		var calculo   = 0;
		var resultado = 0;
		var peso      = 2;
		
		//Calculo do digito 8 do CNPJ.
		calculo   = new String(parseInt(strCPFCNPJ.substr(0,1)) * 2);
		resultado = parseInt(strCPFCNPJ.substr(1,1)) + parseInt(strCPFCNPJ.substr(3,1)) + parseInt(strCPFCNPJ.substr(5,1)) +
 							  parseInt(calculo.substr(0,1)) + parseInt(calculo.substr(1,1));
		
		calculo   = new String(parseInt(strCPFCNPJ.substr(2,1)) * 2);
		resultado = parseInt(resultado) + parseInt(calculo.substr(0,1)) + parseInt(calculo.substr(1,1));
		
		calculo   = new String(parseInt(strCPFCNPJ.substr(4,1)) * 2);
		resultado = parseInt(resultado) + parseInt(calculo.substr(0,1)) + parseInt(calculo.substr(1,1));
									
		calculo   = new String(parseInt(strCPFCNPJ.substr(6,1)) * 2);
		resultado = parseInt(resultado) + parseInt(calculo.substr(0,1)) +	parseInt(calculo.substr(1,1));
		
		var resto = parseInt(resultado) % 10;
		
		if (resto == 0) {
			digito = resto;
		} else {
			digito = 10 - resto;
		}
		
		calculo = 0;
		
		for (var i = strCPFCNPJ.length - 3; i >= 0; i--) {
			calculo = parseInt(calculo) + parseInt(strCPFCNPJ.substr(i,1)) * peso;
			peso++;
		
			if (peso > 9) {
				peso = 2;
			}
		}
	
		resto = parseInt(calculo) % 11;
		
		if (resto < 2) {
			digito = 0;
		} else {
			digito = 11 - resto;
		}
		
		if (strCPFCNPJ.substr(strCPFCNPJ.length - 2,1) != digito) {
			return false;
		}
		
		//Calculo do digito 14 do CNPJ.		
		peso    = 2;
		calculo = 0;
		
		for (var i = strCPFCNPJ.length - 2; i >= 0; i--) {
			calculo = parseInt(calculo) + parseInt(strCPFCNPJ.substr(i,1)) * peso;
			peso++;
		
			if (peso > 9) {
				peso = 2;
			}
		}
		
		resto = parseInt(calculo) % 11;
		
		if (resto < 2) {
	 		digito = 0;
		} else {
			digito = 11 - resto;
		}
		
		if (strCPFCNPJ.substr(strCPFCNPJ.length - 1,1) != digito) {
			return false;
		} else {
			return true;
		}
	}
}

/*!
 * OBJETIVO   : função que retorna uma lista de caracteres permitidos
 */	
function charPermitido() {
	var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789\"!@#$%*() -_=+[]{}/?;:.,\\|" + String.fromCharCode(10,13);	
	return chars;
}

/*!
 * OBJETIVO: 
 */	
function cancelaPedeSenhaCoordenador(divBlock) {
	$("#divUsoGenerico").css("visibility","hidden");
	$("#divUsoGenerico").html("");	

	if (divBlock == '') {
		unblockBackground();
	} else {
		blockBackground(parseInt($("#" + divBlock).css("z-index")));
	}
}




/*!
 * OBJETIVO: função para for?ar TAB quando der enter no campo
 */
function enterTab(f, e) { 

	if (getKeyValue(e) == 13) { 
		var i; 
		for (i = 0; i < f.form.elements.length; i++) { 
			if (f == f.form.elements[i]) { break; } 
		} 

		i = (i + 1) % f.form.elements.length; 
		for (ii = i; ii < f.form.elements.length; ii++) { 
			if ( (f.form.elements[ii].readOnly!=true) && (f.form.elements[ii].type!='button') ) { 
				break; 
			} 
		} 
		f.form.elements[ii].focus(); 
		return false; 

	} 
	else {
		return true; 
	}
} 
 
/*!
 * ALTERA??O : 002
 * OBJETIVO  : função para resetar as cores zebradas das linhas de uma tabela
 * PAR?METRO : Recebe um seletor CSS das linhas (TR) de uma tabela
 */
function zebradoLinhaTabela(x) {
	var cor = '#F7F3F7';	
	x.each(function(e) {
		cor == '#F4F3F0' ? cor = '#FFFFFF' : cor = '#F4F3F0';
		$(this).css({'background-color':cor,'color':'#444'});
	});
	x.hover( function() {
		$(this).css({'cursor':'pointer','outline':'1px solid #6B7984','color':'#000'});
	}, function() {
		$(this).css({'cursor':'auto','outline':'0px','color':'#444'});
	});
	return false;
}

/*!
 * ALTERA??O : 003
 * OBJETIVO  : função an?loga ao "trim" do PHP, onde limpa os espa?os em branco excedentes de uma string
 * PAR?METRO : str -> Uma string qualquer
 */
function trim(str) {
	str = str.replace(/^\s+/, '');
	for (var i = str.length - 1; i >= 0; i--) {
		if (/\S/.test(str.charAt(i))) {
			str = str.substring(0, i + 1);
			break;
		}
	}
	return str;
}

/*!
 * ALTERA??O : 004
 * OBJETIVO  : função similar ? mostraRotina, com a melhoria de se passar o div a ser exibido e bloquear o fundo
 * PAR?METRO : x -> div a ser exibido
 */
function exibeRotina(x) { 
	x.css('visibility','visible');
	x.centralizaRotinaH();
	bloqueiaFundo(x);
	return false;
}

/*!
 * ALTERA??O : 005 
 * OBJETIVO  : função similar ? mostraRotina, com a melhoria de se passar o seletor jQuery da div a ser exibida e desbloquear o fundo.
 *             Ao desbloquear o fundo, tudo ? desbloqueado, mas existem situa??es que precisamos manter alguma parte do sistema bloqueado,
 *             para isso utiliza-se do segundo par?metro da função, que bloqueia a rotina indicada neste par?metro
 * PAR?METRO : rotina         -> Seletor jQuery a ser fechado
 *	           bloqueiaRotina -> Seletor jQuery ao qual seu fundo ser? bloqueado
 */
function fechaRotina(rotina, bloqueiaRotina, fncFechar) { 
	rotina.css('visibility','hidden');
	unblockBackground();	
	if ( typeof bloqueiaRotina == 'object' ) {		
		bloqueiaFundo(bloqueiaRotina);		
	}
	if ( typeof fncFechar != 'undefined' ) {
		eval(fncFechar);		
	}
	return false;
}

/*!
 * ALTERA??O : 006
 * OBJETIVO  : função similar ? blockBackground, com a melhoria de se passar o div a ser bloqueado
 * PAR?METRO : div       -> div ao qual o fundo ser? bloqueado 
 *             campoFoco -> [Opcional] id do campo ao qual ser? dado o foco
 *             formFoco  -> [Opcional] id do formulario ao qual o campoFoco está inserido
 *			   boErro    -> [Opcional] valores v?lidos (true|false), indicando se recebe a classe erro ou n?o
 */
function bloqueiaFundo(div, campoFoco, formFoco, boErro) {	
	//if ( ( div.attr('id') != 'divMatric' ) && ( div.attr('id') != 'divTela' ) ){ 
		zIndex = parseInt(div.css('z-index'));	
		blockBackground(zIndex);	
	//}

		
	return true;
}



/*!
 * ALTERA??O : 009
 * OBJETIVO  : função similar ? in_array do php, retorna "true" se o item existe no array e "false" caso contr?rio
 * PAR?METRO : item  -> Item que está sendo verificado se existe no array
 *             array -> Conjunto de valores que ser?o analizados verificando se o item ? igual a um deles
 */
function in_array(item, array){
	for(var i=0;i<array.length;i++) {
		if(item == array[i]) return true;
	}
	return false;
}

/*!
 * ALTERA??O : 010
 * OBJETIVO  : função que define m?scaras, formatos, valores permitidos e layout de v?rios elementos dos formul?rios. 
 */
function layoutPadrao() {
	
	var caracAcentuacao 	= '\'"´`^~';
	var caracEspeciais  	= '!@#$%&*()-_+=?:<>;/?[]{}\\|\',.?`?^~';
	var caracSuperEspeciais	= '<>&\'\"';
	var caracEspeciaisEmail = '!#$%&*()+=?:<>;/?[]{}\\|\',?`?^~';
  var caracEspeciaisEmailVarios = '!#$%&*()+=?:<>/?[]{}\\|\',?`?^~';
	var p='[0-9]+';
	var d='[0-9]{2}';		

	// Aplicando M?scaras
	$('input.conta'			).setMask('INTEGER','zzzz.zzz-z','.-','');
	$('input.cheque'		).setMask('INTEGER','zzz.zzz.9','.','');
	$('input.renavan'		).setMask('INTEGER','zzz.zzz.zzz.zz9','.','');
    $('input.renavan2'		).setMask('INTEGER','zz.zzz.zzz.zz9','.',''); //GRAVAMES
    $('input.contaitg'      ).setMask('STRING' ,'9.999.999-9','.-','');
	$('input.placa'         ).setMask('STRING' ,'999-9999','-','');
	$('input.matricula'		).setMask('INTEGER','zzz.zzz','.','');
	$('input.cadempresa'	).setMask('INTEGER','zzzz.zzz.z','.','');
	$('input.cnpj'			).setMask('INTEGER','z.zzz.zzz/zzzz-zz','/.-','');
	$('input.cpf'			).setMask('INTEGER','999.999.999-99','.-','');	
	$('input.cep'			).setMask('INTEGER','zzzzz-zz9','-','');	
	$('input.caixapostal'	).setMask('INTEGER','zz.zz9','.','');	
	$('input.numerocasa'	).setMask('INTEGER','zzz.zz9','.','');	
	$('input.contrato'		).setMask('INTEGER','z.zzz.zz9','.','');	
	$('input.contrato2'		).setMask('INTEGER','z.zzz.zzz.zz9','.','');
	$('input.contrato3'		).setMask('INTEGER','zz.zzz.zz9','.','');	
	$('input.insc_estadual'	).setMask('INTEGER','zzz.zzz.zzz.zzz','.','');			
	$('input.dataMesAno'	).setMask('INTEGER','zz/zzzz','/','');
	$('input.kmetros'		).setMask("p,d");	
	//$('input.data'			).dateEntry({useMouseWheel:true,spinnerImage:''});   
	$('input.data'			).setMask("DATE","","","");
	$('input.monetario'		).attr('alt','n9p3c2D').css('text-align','right').autoNumeric().trigger('blur');
	$('input.moeda'			).attr('alt','p9p3c2D').css('text-align','right').autoNumeric().trigger('blur');
	$('input.moeda_3'   	).attr('alt','p9p3c3D').css('text-align','right').autoNumeric().trigger('blur');
	$('input.moeda_6'		).attr('alt','p6p3c2D').css('text-align','right').autoNumeric().trigger('blur');
	$('input.moeda_15'	    ).attr('alt','p0p3c2D').css('text-align','right').autoNumeric().trigger('blur');
	$('input.porcento'		).attr('alt','p3x0c2a').autoNumeric().trigger('blur');	
	$('input.porcento_n'	).attr('alt','n3x0c2a').css('text-align','right').autoNumeric().trigger('blur');	
	$('input.porcento_7'	).attr('alt','p3x0c7a').autoNumeric().trigger('blur');	
	$('input.porcento_8'	).attr('alt','p3x0c8a').autoNumeric().trigger('blur');	
	$('input.indexador'	).attr('alt','p3x0c8a').autoNumeric().trigger('blur');	
	$('input.email'			).css({'text-transform':'lowercase'}).alphanumeric({ichars: caracSuperEspeciais+caracAcentuacao+caracEspeciaisEmail});
  $('input.emailVarios'			).css({'text-transform':'lowercase'}).alphanumeric({ichars: caracSuperEspeciais+caracAcentuacao+caracEspeciaisEmailVarios});
	$('input.alpha'			).css({'text-transform':'uppercase'});
	$('input.alphanum'		).css({'text-transform':'uppercase'});		
	$('input.alphanumlower'	).css({'text-transform':'lowercase'});		
	$('input.alpha'			).alpha({ichars: caracAcentuacao+caracEspeciais});
	$('input.alphanum'		).alphanumeric({ichars: caracSuperEspeciais+caracAcentuacao});
	$('input.alphanumlower'	).alphanumeric({ichars: caracSuperEspeciais+caracAcentuacao});
	$('textarea.alphanum'   ).alphanumeric({ichars: caracSuperEspeciais+caracAcentuacao});
	$('input.inteiro'		).numeric({ichars: caracAcentuacao+caracEspeciais+'.,\"'});
	$('input.codigo'		).numeric({ichars: caracAcentuacao+caracEspeciais+'.,\"'});	
	$('.descricao'			).desabilitaCampo();
	$('.campoTelaSemBorda'	).attr('tabindex','-1');	
	$('label'				).addClass("txtNormalBold");
	$('input.codigo'		).attr('maxlength','4');	
	$('a[class!="botao"]','.formulario').attr('tabindex','-1');	

	// Alinhando os campos para direita
	$('.inteiro,.porcento,.numerocasa,.caixapostal,.cep,.conta,.contrato,.contrato2,.contrato3,.contaitg,.cnpj,.cpf,.matricula,.cadempresa,.insc_estadual').css('text-align','right');	
	
	/*!
	 * ALTERA??O  : 023
	 * OBJETIVO   : Tecla de atalho F8 igual ao modo CARACTER para limpar os campos input
	 */	
	/*
	* remover esse atalho, conforme NOVO LAYOUT PADR?O
	*$('input[type=\'text\'],select').keydown( function(e) {
	*	if ( e.keyCode == 119 ) {
	*		$(this).val(''); 
	*		$(this).trigger('change'); // ALTERA??O 040
	*		return false;
	*	}
	*	return true;
	*});
	*/
	
	/*!
	 * ALTERA??O  : 024
	 * OBJETIVO   : Tecla de atalho F7 igual ao modo CARACTER para abrir a Pesquisa
	 * OBSERVA??O : Aplicado somente a campos que possuem a classe "pesquisa"
	 */	
	$('input.pesquisa').unbind('keydown.zoom').bind('keydown.zoom', function(e) {
		if ( e.keyCode == 118 ) {
			if ( isHabilitado($(this)) ) {
				$(this).next().click();
				return false;
			}
		}
		return true;
	});
	
	/*!
	 * ALTERA??O  : 027
	 * OBJETIVO   : Ao entrar no campo cpf ou cnpj, verifica se n?o existe valor digitado, caso afirmativo limpa o campo para digita??o
	 */		
	$('input.cnpj').unbind('focusin').bind('focusin', function() {
		$(this).addClass('campoFocusIn');	/*064*/
		valorAtual = normalizaNumero( $(this).val() );
		valorAtual = ( valorAtual == '0' ) ? '' : valorAtual;
		$(this).val( valorAtual );
	});
	$('input.cpf').unbind('focusin').bind('focusin', function() {
		$(this).addClass('campoFocusIn');	/*064*/
		valorAtual = normalizaNumero( $(this).val() );
		valorAtual = ( valorAtual == '0' ) ? '' : valorAtual;
		$(this).val( valorAtual );
	});	
	
	return true;
}

/*!
 * ALTERA??O  : 021 - Cria??o
 * OBJETIVO   : Para trabalhar com o n?meros sem m?scaras
 * PARAMETROS : numero [String] -> N?mero que deseja-se normalizar
 * RETORNO    : Retorna zero caso seja vazio o n?mero passado como par?metro, ou retorna o n?mero sem m?scara
 */	 
function normalizaNumero( numero ) {
	var retorno;
	numero  = ( (typeof numero == 'undefined') || (numero == null) ) ? '' : numero;
	retorno = retiraCaracteres(numero,'0123456789,',true);
	retorno = retirarZeros( retorno );
	retorno = ( retorno == '' ) ? 0 : retorno;
	return retorno;
}

/*!
 * ALTERA??O  : 025 - Criada função
 * OBJETIVO   : Selecionar o registro corrente retornando a chave para ser enviada ao XML. 
 * OBSERVA??ES: função utilizada no in?cio da função "controlaOperacao" de cada rotina. 
 *              Comumente utilizada para opera??es de Altera??o ou Exclus?o
 * RETORNO    : Retorna vazio caso n?o existam registros para serem selecionados, ou retorna a chave do registro selecionado
 */	 	
function selecionaRegistro() {
	var retorno = '';
	$('table > tbody > tr', 'div.divRegistros').each( function() {
		if ( $(this).hasClass('corSelecao') ) {
			retorno = $('input', $(this) ).val();
		}
	});	
	return retorno;
}

/*!
 * OBJETIVO   : Inserir comportamento no link da pesquisa associado para abrir o formul?rio de pesquisa
 */	 
function controlaPesquisaAssociado( nomeForm ) {
	$('a','#'+nomeForm).addClass('lupa').css({'float':'right','font-size':'11px','cursor':'pointer'});
	$('a','#'+nomeForm).each( function() {	
		$(this).click( function() {
			mostraPesquisaAssociado('nrdconta',nomeForm);
			return false;
		});
	});
}

/*!
 * OBJETIVO  : função para exibir alertas padr?o do javascript caso a Variável global "exibeAlerta" estiver setada para TRUE
 *             ? uma função auxiliar para o programador debugar as telas
 */
function alerta( mensagem ) {
	if ( exibeAlerta ) alert(mensagem);
}

/*!
 * ALTERA??O : 026
 * OBJETIVO  : função para padr?o de focar os campos com erro.
 * PAR?METRO : campoFoco    [String]  -> id do campo ao qual ser? dado o foco
 *             formFoco     [String]  -> id do formulario ao qual o campoFoco está inserido
 *             desbloqueia  [Boolean] -> [Opcional] true para desbloquear e false para n?o fazer nada, por default = true
 *             divBloqueia  [String]  -> [Opcional] nome da div que o fundo ser? bloqueado
 */
function focaCampoErro(campoFoco, formFoco, desbloqueia, divBloqueia) {
	
	if ( typeof desbloqueia == 'undefined' ) {
		unblockBackground();
	} else {
		if ( desbloqueia ) unblockBackground();
	}
	
	if ( typeof divBloqueia != 'undefined') {
		zIndex = parseInt( $('#'+divBloqueia).css('z-index') );
		blockBackground(zIndex); 
	}	
	
	$('#'+campoFoco,'#'+formFoco).addClass('campoErro');
	$('#'+campoFoco,'#'+formFoco).focus();
	
	return true;
}

/*!
 * ALTERA??O  : 030
 * OBJETIVO   : função recursiva para exibir um array de mensagens, onde cada mensagem ser? exibida por LIFO
 * PAR?METROS : strArray [Obrigatorio] -> Array de strings que ser?o exibidas
 *              metodo 	 [Obrigatorio] -> Metodo que ser? executado ap?s a ultima mensagem do array ser exibida
 */	
function exibirMensagens( strArray, metodo  ) {	
	if ( strArray != '' ) {		
		// Definindo as vari?veis
		var arrayMensagens	= new Array();
		var novoArray		= new Array();		
		var elementoAtual	= '';		
		// Setando os valores
		arrayMensagens 	= strArray.split('|');
		elementoAtual	= arrayMensagens.pop();
		arrayMensagens 	= implode( '|' , arrayMensagens);
		// Exibindo mensagem de erro
		showError('inform',elementoAtual,'Alerta - Ayllos',"exibirMensagens('"+arrayMensagens+"','"+metodo+"')");
	} else {
		eval(metodo);
	}
}

/*!
 * ALTERA??O  : 029
 * OBJETIVO   : função semelhando ao implode do PHP, que retorna uma string contento todos os elementos de um array separados por um separador
 * PAR?METROS : separador   [Obrigatorio] -> Separador que ser? utilizado na montagem da string
 *              arrayPedaco [Obrigatorio] -> Array que ser? implodido 
 */	
function implode( separador, arrayPedaco ) {  
    return ( ( arrayPedaco instanceof Array ) ? arrayPedaco.join ( separador ) : arrayPedaco );  
}  

/*!
 * ALTERA??O  : 028
 * OBJETIVO   : função para verificar se existem fun??es "montaSelect" sendo executadas
 * OBSERVA??O : Utilizada pelos botoes das diversas rotinas, onde se essa função retornar FALSE, n?o ? para executar a a??o do bot?o
 */	
function verificaContadorSelect() {
	if ( contadorSelect > 0 ) return false;
	return true;
}

/*!
 * ALTERA??O  : 032
 * OBJETIVO   : função para verificar se o sistema está processando alguma função "controlaOperacao", n?o permitindo cham?-la 
 *              enquanto ainda está sendo executada
 * OBSERVA??O : Utilizada por todas rotinas
 */	
function verificaSemaforo() {
	if ( semaforo > 0 ) return false;
	semaforo++;
	return true;
}

/*!
 * ALTERA??O  : 031
 * OBJETIVO   : função para desbloquear a tela, mas a melhoria de poder setar o foco em algum campo da tela
 * OBSERVA??O : Utilizada na tela MATRIC nos retornos de erro
 */	
function desbloqueia(campoFoco, formFoco) {
	unblockBackground();
	if( (typeof campoFoco != 'undefined') && (typeof formFoco != 'undefined') ) {
		$('#'+campoFoco,'#'+formFoco).focus();
	}
	return true;
}

/*!
 * ALTERA??O  : 032
 * OBJETIVO   : função para trucar textos em javascript
 * OBSERVA??O : Utilizada na tela MATRIC apresenta??o dos dados da tabela dos procuradores
 */	
function truncar(texto,limite){
	if (texto.length > limite) {
		texto = texto.substr(0,limite-1) + '?';
	}
	return texto;
}

/*!
 * ALTERA??O  : 036
 * OBJETIVO   : função para remover o filtro de opacidade tanto no IE quanto no FF
 * PAR?METROS : nome [String] -> Nome da div que deseja-se voltar a visualiza??o em 100%, sem transparencia (opacidade)
 */	
function removeOpacidade( nome ) {
	$('#'+nome).fadeTo(1000,1,function() { 
		if ( $.browser.msie ) {
			$(this).get(0).style.removeAttribute('filter');
		} else {
			$(this).css({'-moz-opacity':'100','filter':'alpha(opacity=100)','opacity':'100'}); 
		}
	});
	
}

/*!
 * ALTERA??O  : 
 * OBJETIVO   : função que dado um Array Associativo bidirecional retorna uma string contendo o nome das chaves do array separado pelo separador
 * PAR?METROS : arrayDados  [Obrigatorio] -> Array Associativo que ser? implodido
 *              separador   [Obrigatorio] -> Separador que ser? utilizado na montagem da string
 */	
function retornaCampos( arrayDados, separador ){
	var str = '';
	if ( arrayDados.length > 0 ){
		for( registro in arrayDados[0] ) {
			str += registro+separador;
		}
		str = str.substring(0, ( str.length - 1 ) );
	}
	return str;
}

/*!
 * ALTERA??O  : 
 * OBJETIVO   : função que dado um Array Associativo bidirecional retorna uma string contendo os dados de um registro implodidos com o sepValores
				e todos os registros s?o implodidos com o sepRegs
 * PAR?METROS : arrayDados  [Obrigatorio] -> Array Associativo que ser? implodido
 *              sepValores  [Obrigatorio] -> Separador que ser? utilizado para separar os dados
 *              sepRegs     [Obrigatorio] -> Separador que ser? utilizado para separar os registros
 */
function retornaValores( arrayDados, sepValores, sepRegs, strCampos ){
	var str = '';
	var arrayCampos	= new Array();
	arrayCampos 	= strCampos.split('|');
	
	if ( arrayDados.length > 0 ){
		for( registro in arrayDados ) {
			for( i in arrayCampos ) {
			
			//for( dado in arrayDados[registro] ) {
				str += arrayDados[registro][arrayCampos[i]]+sepValores;
			}
			str = str.substring(0, ( str.length - 1 ) );
			str += sepRegs;
		}
		str = str.substring(0, ( str.length - 1 ) );
	}
	return str;
}


/*!
 * ALTERA??O  : 046 
 * OBJETIVO   :	função que converte um valor de financeiro para float 
 * PAR?METROS : valor [String ] -> [Obrigat?rio] Valor financeiro
 * RETORNO    : Retorna um valor float
 */
function converteMoedaFloat(valor) {
	valor = valor != '' ? valor : '0';
	valor = valor.replace(/\./g,'');
	valor = valor.replace(/,/g,'.');
	valor = parseFloat(valor);
	return valor;
}

/*!
 * ALTERA??O  : 048 
 * OBJETIVO   :	função que coloca mascara em uma string 
 * PAR?METROS : v [String ] -> String que vai receber a mascara. Ex.: 1111111
			  : m [String ] -> String com o formato da mascara. Ex.: ###.###.#	
 * RETORNO    : Retorna uma string com mascara. Ex.: 111.111.1
 */
function mascara(v,m) {
	var t1 = v.length-1; // tamanho da string
	var t2 = m.length-1; // tamanho da mascara
	var l1 = ''; // ultima letra string
	var l2 = ''; // ultima letra mascara
	var i1 = 0; // indice string
	var i2 = 0; // indice mascara
	
	var retorno = '';	
	var ultima  = '';
	
	for ( i1 = t1; i1 >= 0; i1-- ) {
		l1 = v.charAt(i1);
		while ( ultima != '#' && t2 >= i2 ) {
			l2 = m.charAt(t2-i2);
			if ( l2 == '#' ) {
				retorno = l1 + retorno;
			} else {
				retorno = l2 + retorno;
			}
			ultima = l2;
			i2++;
		}
		ultima = '';
	}	
	return retorno;
}


/*!
 * V?rias fun??es criadas como plugins do jQuery
 */
$.fn.extend({ 
	
	/*!
	 * OBJETIVO: função para centralizar objetos na tela
	 */
	setCenterPosition: function() { 
		var objOffsetX = screen.width / 8; 
		var objOffsetY = screen.height / 5; 
		
		// Atribui posi&ccedil;&atilde;o ao div
		$(this).css({
			left:objOffsetX,
			top: objOffsetY,
			width:100, 
			height: 50
		});
	},

	/*!
	 * ALTERA??O : 007
	 * OBJETIVO  : função similar e' setCenterPosition, so que centraliza a Rotina na horizontal dentro de outro elemento "tdTela"
	 */	
	centralizaRotinaH: function() {
		
		// Calcula a largura e altura da tela inteira
		var larguraRotina = $(window).innerWidth();  
		var alturaRotina  = $(window).innerHeight();
		
		// Obter tamanho do objeto
		var larguraObjeto = $(this).innerWidth();				
		var alturaObjeto  = $(this).innerHeight();	

		// Subtrair largura do objeto da largura da tela e / 4 
		// Subtrair altura do objeto da altura da tela e / 4
		var leftRotina = Math.floor( (larguraRotina - larguraObjeto) / 4 );  
		var topRotina  = Math.floor( (alturaRotina - alturaObjeto)  / 4 );   
				
		//$(this).css('left',leftRotina);
		$(this).css('top', topRotina);
		
	},
	
	/*!
	 * ALTERA??O : 020 - Cria??o do m?todo
	 * OBJETIVO  : Facilitar a chamada e ocultar as mensagens padr?o do sistema, onde somente um m?todo agora ? respons?vel por realizar tal tarefa
	 */	
	escondeMensagem: function() {
		$(this).css({left:'0px',top:'0px',display:'none'});	
		unblockBackground();	
	},
	
	/*!
	 * ALTERA??O 45 - Somente trabalhar com determinados tipos e tags
	 * ALTERA??O 44 - Se possui a classe pesquisa, ent?o controla ponteiro do mouse do pr?ximo campo
	 * OBJETIVO: função para desabilitar o(s) campo(s)
	 */		
	desabilitaCampo: function() {
		return this.each(function() {	  
			var type = this.type;
			var tag  = this.tagName.toLowerCase();			
			if ( in_array(tag,['input','select','textarea']) && (type != 'image') ) {			
				$(this).addClass('campoTelaSemBorda').removeClass('campo campoFocusIn textareaFocusIn radioFocusIn checkboxFocusIn selectFocusIn').prop('readonly',true).prop('disabled',true);
				if ( type == 'radio'    ) $(this).css('background','none');
				if ( type == 'textarea' ) $(this).prop('disabled',false);
				if ( $(this).hasClass('pesquisa') ) $(this).next().ponteiroMouse();			
			}
		});		
	},
	
	

	/*!
	 * ALTERA??O  : 015 - Cria??o da função
	 * OBJETIVO   : Facilitar o processo de formata??o e padroniza??o das tabelas que apresentam registros. Este padr?o utiliza-se do plugin jQuery TableSorter
	 *              que adiciona a funcionalidade de ordena??o das tabelas.
	 * PAR?METROS : ordemInicial     [Obrigat?rio] -> Array bidimencional representando a ordena??o inicial dos dados contidos na tabela
	 *              larguras         [Opcional]    -> Array unidimencional onde constam-se as larguras de cada coluna da tabela
	 *              alinhamento      [Opcional]    -> Array unidimencional onde constam-se os alinhamentos de cada coluna da tabela
	 *              metodoDuploClick [Opcional]    -> Metodo que ser? chamado no duplo clique na linha "registro" da tabela
	 */
	formataTabela: function(ordemInicial, larguras, alinhamento, metodoDuploClick ) {

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
				
		// Configura??es para o Sorter
		tabela.has("tbody > tr").tablesorter({ 
			sortList         : ordemInicial,
			textExtraction   : textExtraction,
			widgets          : ['zebra'],
			cssAsc			 : 'headerSortUp',
			cssDesc          : 'headerSortDown',
			cssHeader  		 : 'headerSort'
		});
		
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
		
		// Formatando - Alinhamento
		if (typeof alinhamento != 'undefined') {
			for( var i in alinhamento ) {
				var nrColAtual = i;
				nrColAtual++;
				$('td:nth-child('+nrColTotal+'n+'+nrColAtual+')', tabela ).css('text-align', alinhamento[i] );		
			}		
		}			

		// Controla Click para Ordena??o
		$('th', tabelaTitulo ).each( function(i) {		
			$(this).mousedown( function() {						
				if( $(this).hasClass('ordemInicial') ) {
					tabela.has("tbody > tr").tablesorter({ sortList: ordemInicial }).tablesorter({ sortList: ordemInicial });
				} else {
					$('th:eq('+i+')',divRegistro).click();
				}
			});
			$(this).mouseup( function() {
				
				tabela.zebraTabela();		
				
				$('table > tbody > tr', divRegistro).each( function(i) {
					$(this).unbind('click').bind('click', function() {
						$('table', divRegistro).zebraTabela( i );
					});
				});				
				
				$('th', tabela ).each( function(i) {
					var classes = $(this).attr('class');
					if ( classes != 'ordemInicial' ) {
						$('th:eq('+i+')', tabelaTitulo ).removeClass('headerSort headerSortUp headerSortDown');
						$('th:eq('+i+')', tabelaTitulo ).addClass( classes );
					}
				});				
			});			
		});	
		
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
	},

	/*!
	 * ALTERA??O  : 016 - Cria??o da função
	 * OBJETIVO   : Utilizada  na função acima "formataTabela" ? chamada atrav?s de um seletor jQuery de tabela, e ele zebra as linhas da tabela.
	 *              Caso nehum par?metro ? informado, a linha que estava selecionada continua selecionada.
	 * PAR?METROS : indice [Inteiro] -> Indica a linha que deve estar selecionada, ficando com uma cor diferenciada.
	 */
	zebraTabela: function( indice ) {	
		
		var tabela = $(this);
		
		$('tbody > tr'     , tabela ).removeClass('corPar corImpar corSelecao');
		$('tbody > tr:odd' , tabela ).addClass('corPar'  );
		$('tbody > tr:even', tabela ).addClass('corImpar');		
		
		if ( typeof indice != 'undefined' ) {
			$('tbody > tr', tabela ).removeClass('corSelecao');
			$('tbody > tr:eq('+indice+')', tabela ).addClass('corSelecao');
		}
		
		$('tr', tabela ).hover( function() {
			$(this).css({'cursor':'pointer','outline':'1px solid #6B7984','color':'#000'});
		}, function() {
			$(this).css({'cursor':'auto','outline':'0px','color':'#444'});
		});
		
		return false;
	},

	/*!
	 * ALTERA??O  : 013
	 * OBJETIVO   : Plugin para limitar a quantidade de linhas e colunas de um textarea. 
	 *              O n?mero de colunas e linhas aceitos pelo "textarea" ser? os valores de suas propriedades "cols" e "rows" respctivamente.
	 * UTILIZA??O : Via jQuery, onde a partir de um seletor podemos disparar esta funcionalidade da seguinte forma: $('seletor').limitaTexto;
	 */
	limitaTexto: function() {
		function limita(x) {
			var testoAux = '';
			var nrLinhasAtual, nrColunasAtual, nrLinhas, nrColunas = 0;
			var arrayLinhas = x.val().split("\n");

			nrLinhas  = x.attr('rows');
			nrColunas = x.attr('cols');			
			nrLinhasAtual = arrayLinhas.length;			

			for( var i in arrayLinhas ) {
				nrColunasAtual = arrayLinhas[i].length;			
				if ( eval(nrColunasAtual >= nrColunas) ) { arrayLinhas[i] = arrayLinhas[i].substring(0,nrColunas); }
				testoAux += ( testoAux == '') ? arrayLinhas[i] : '\n'+arrayLinhas[i];
			}
			x.val( testoAux );

			if( nrLinhasAtual > nrLinhas ) { 
				testoAux = x.val().split("\n").slice(0, nrLinhas); 
				x.val( testoAux.join("\n") ); 
			}
		}

		this.each(function() {
			var textArea = $(this);
			textArea.keyup(function() {	limita(textArea); });
			textArea.bind('paste', function(e) { setTimeout(function() { limita(textArea) }, 75); });
		});
		
		return this;
	},
	
	/*!
	 * ALTERA??O  : 042 
	 * OBJETIVO   : Adicionar a classe "cpf" ou "cnpj" nos campos que possuem valores v?lidos de cpf ou cnpj respectivamente
	 */
	addClassCpfCnpj: function() {	
		return this.each(function() {	  
			var type = this.type;
			var tag = this.tagName.toLowerCase();
			if (tag == 'input' && type == 'text') {
				if ( verificaTipoPessoa( this.value ) == 1 ) { 
					$(this).removeClass('cnpj').addClass('cpf'); 
				} else if( verificaTipoPessoa( this.value ) == 2 ) {
					$(this).removeClass('cpf').addClass('cnpj'); 
				} else {
					$(this).removeClass('cpf').removeClass('cnpj');
				}
			}	
		});
	},
	
	/*!
	 * ALTERA??O  : 043
	 * OBJETIVO   : Somente aplicar comportamento para links <a> que possuem a classe "lupa", onde ser?
	 *              verificado se o campo anterior possui a classe "campo", e caso afirmativo coloca
	 *              a classe "pointer", caso negativo retira esta classe.
	 */		
	ponteiroMouse: function() {
		return this.each( function() {	  			
			// Se n?o form TAG de link <a>, ent?o n?o faz nada
			if (this.tagName.toLowerCase() != 'a') return false;						
			// Se n?o possuir a classe "lupa", n?o faz nada
			if (!$(this).hasClass('lupa')) return false;			
			// Se o campo anterior possuir a classe "campo", ent?o adiciona a classe "pointer"
			if ( isHabilitado($(this).prev()) ) {
				$(this).addClass('pointer');
			} else {
				$(this).removeClass('pointer');
			}
			return false;			
		});
	},
	removeOpacidade: function() {
		$(this).fadeTo(1000,1,function() { 
			if ( $.browser.msie ) {
				$(this).get(0).style.removeAttribute('filter');
			} else {
				$(this).css({'-moz-opacity':'100','filter':'alpha(opacity=100)','opacity':'100'}); 
			}
		});
	},
	trocaClass: function(classAnterior,classAtual) {
		return this.each(function() {			
			$(this).removeClass(classAnterior).addClass(classAtual);
		});		
	}
});

/*!
 * ALTERA??O  : 037
 * OBJETIVO   : Transforma data para timestamp
 * UTILIZA??O : *     example 1: mktime(14, 10, 2, 2, 1, 2008);  
				*     returns 1: 1201871402  
				*     example 2: mktime(0, 0, 0, 0, 1, 2008);  
				*     returns 2: 1196463600  
				*     example 3: make = mktime();  
				*     example 3: td = new Date();  
				*     example 3: real = Math.floor(td.getTime()/1000);  
				*     example 3: diff = (real - make);  
				*     results 3: diff < 5  
				*     example 4: mktime(0, 0, 0, 13, 1, 1997)  
				*     returns 4: 883609200  
				*     example 5: mktime(0, 0, 0, 1, 1, 1998)  
				*     returns 5: 883609200  
				*     example 6: mktime(0, 0, 0, 1, 1, 98)  
				*     returns 6: 883609200  
 */
 function mktime() {  
     // Get UNIX timestamp for a date    
     //   
     // version: 901.2514  
     // discuss at: http://phpjs.org/functions/mktime  
     // +   original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net) 
       
     var no, ma = 0, mb = 0, i = 0, d = new Date(), argv = arguments, argc = argv.length;  
   
     if (argc > 0){  
         d.setHours(0,0,0); d.setDate(1); d.setMonth(1); d.setYear(1972);  
     }  
    
     var dateManip = {  
         0: function(tt){ return d.setHours(tt); },  
         1: function(tt){ return d.setMinutes(tt); },  
         2: function(tt){ var set = d.setSeconds(tt); mb = d.getDate() - 1; return set; },  
         3: function(tt){ var set = d.setMonth(parseInt(tt)-1); ma = d.getFullYear() - 1972; return set; },  
         4: function(tt){ return d.setDate(tt+mb); },  
         5: function(tt){ return d.setYear(tt+ma); }  
     };  
       
     for( i = 0; i < argc; i++ ){  
         no = parseInt(argv[i]*1);  
         if (isNaN(no)) {  
             return false;  
         } else {  
             // arg is number, let's manipulate date object  
             if(!dateManip[i](no)){  
                 // failed  
                 return false;  
             }  
         }  
     }     
     return Math.floor(d.getTime()/1000);  
}

/*!
 * ALTERA??O  : 038
 * OBJETIVO   : Receber uma data no formato dd/mm/aaaa , obter as substrings referentes ? ao dia, mes e ao ano e passar como parametro na 
 *				função mktime.              
 * PAR?METROS : data ->  Data no formato dd/mm/aaaa. 
 */
function dataParaTimestamp(data) {
	dia = data.substr(0,2); 
	mes = data.substr(3,2);
	ano = data.substr(6,4);
	return mktime(0, 0, 0, mes, dia, ano);
}

/*!
 * ALTERA??O  : 041
 * OBJETIVO   : função para verificar se n?mero passado como par?metro ? um CPF ou CNPJ
 * PAR?METROS : numero [String ] -> [Obrigat?rio] N?mero do CPF ou CNPJ a ser verificado
 * RETORNO    : Retorna o valor [1] para pessoa F?sica e [2] para Jur?dica e [0] quando n?o ? nenhum dos dois
 */	
function verificaTipoPessoa( numero ) {
	if ( validaCpfCnpj(numero,1) ) {
		return 1;
	} else if (validaCpfCnpj(numero,2)){
		return 2;
	} else {
		return 0;
	}
}

function milisegundos() {
	return Number(new Date());	
}

/*!
 * ALTERA??O  : 059
 * OBJETIVO   : Verifica se o campo está habilitado
 * UTILIZA??O : 
*/
function isHabilitado( objeto ) {

	var classes = new Array();
	
	classes[0] = 'campo';
	classes[1] = 'campoFocusIn';
	classes[2] = 'textareaFocusIn';
	classes[3] = 'radioFocusIn';
	classes[4] = 'checkboxFocusIn';
	classes[5] = 'selectFocusIn';

	if ( typeof objeto == 'object' ) {		
		for ( var i in classes ) if ( objeto.hasClass(classes[i]) ) return true;
	}
	
	return false;
}

function CheckNavigator() {
	var navegador = 'undefined';
	var versao    = '0';
	
	if (navigator.userAgent.search(/chrome/i) !=' -1') {		
		navegador = 'chrome';
		versao   = navigator.userAgent.substr(navigator.userAgent.search(/chrome/i) + 7);
		versao   = versao.substr(0,versao.search(' '));
	} else if (navigator.userAgent.search(/firefox/i) != '-1') {		
		navegador = 'firefox';
		versao   = navigator.userAgent.substr(navigator.userAgent.search(/firefox/i) + 8);
		versao   = versao.substr(0,versao.search(' '));
	} else if (navigator.userAgent.search(/msie/i) != '-1') {
		navegador = 'msie';
		if (navigator.userAgent.search(/trident/i) != '-1') {
			versao = navigator.userAgent.substr(navigator.userAgent.search(/trident/i) + 8);
			versao = versao.substr(0,versao.search(';'));
			
			switch (versao) {
				case '4.0': versao = '8.0'; break;
				default: versao = '9.0'; break;
			}
		} else {
			versao = navigator.userAgent.substr(navigator.userAgent.search(/msie/i) + 5);
			versao = versao.substr(0,versao.search(';'));
		}		
	}
	
	return { navegador: navegador, versao: versao };
}

//funcao pode ou nao ter parametro de retorno
function verificaAguardoImpressao(callback) {		
	try {
		var httpState = parent.document.getElementById("frameBlank").contentWindow.document.readyState.toUpperCase();		
		
		if (httpState == undefined || httpState.toUpperCase() == "COMPLETE" || httpState.toUpperCase() == "INTERACTIVE") {
			hideMsgAguardo();
			
			if (callback != undefined) {
				eval(callback);			
			}		
		} else {
			setTimeout(function(){verificaAguardoImpressao(callback)},500);
		}
	} catch (err) {
		hideMsgAguardo();
		showError("error","Erro no sistema de impress&atilde;o: " + err.message + "<br>Feche o navegador e reinicie o sistema Ayllos.","Alerta - Ayllos","");
	}			

	return true;
}

function carregaImpressaoAyllos(form,action,callback) {	
	
	try {
		showMsgAguardo('Aguarde, carregando impress&atilde;o ...');
		
		var NavVersion = CheckNavigator();	
		
		if (action.search(/\?/) == '-1') {	
			action = action + '?';
		} else {
			action = action + '&';
		}
		
		action = action + 'keylink=' + milisegundos();
		
		// Configuro o formul?rio para posteriormente submete-lo
		$('#'+form).attr('method','post');
		$('#'+form).attr('action',action);
		$('#'+form).attr("target",(NavVersion.navegador == 'chrome' ? '_blank' : 'frameBlank'));		
		$('#'+form).submit();	
		verificaAguardoImpressao(callback);	
	} catch (err) {	
		hideMsgAguardo();
		showError("error","Erro no sistema de impress&atilde;o: " + err.message + "<br>Feche o navegador e reinicie o sistema Ayllos.","Alerta - Ayllos","");
	}
	
	return true;
}

/* http://stackoverflow.com/questions/46155/validate-email-address-in-javascript */
function validaEmail(emailAddress) {
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(emailAddress);
}

function replaceAll(str, de, para){
    var pos = str.indexOf(de);
    while (pos > -1){
		str = str.replace(de, para);
        pos = str.indexOf(de);
    }
    return (str);
}

function base64_decode(data){

  var b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
  var o1, o2, o3, h1, h2, h3, h4, bits, i = 0,
    ac = 0,
    dec = '',
    tmp_arr = [];

  if (!data) {
    return data;
  }

  data += '';

  do { // unpack four hexets into three octets using index points in b64
    h1 = b64.indexOf(data.charAt(i++));
    h2 = b64.indexOf(data.charAt(i++));
    h3 = b64.indexOf(data.charAt(i++));
    h4 = b64.indexOf(data.charAt(i++));

    bits = h1 << 18 | h2 << 12 | h3 << 6 | h4;

    o1 = bits >> 16 & 0xff;
    o2 = bits >> 8 & 0xff;
    o3 = bits & 0xff;

    if (h3 == 64) {
      tmp_arr[ac++] = String.fromCharCode(o1);
    } else if (h4 == 64) {
      tmp_arr[ac++] = String.fromCharCode(o1, o2);
    } else {
      tmp_arr[ac++] = String.fromCharCode(o1, o2, o3);
    }
  } while (i < data.length);

  dec = tmp_arr.join('');

  return dec.replace(/\0+$/, '');
}

function base64_encode(data){
  
  var b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
  var o1, o2, o3, h1, h2, h3, h4, bits, i = 0,
    ac = 0,
    enc = '',
    tmp_arr = [];

  if (!data) {
    return data;
  }

  do { // pack three octets into four hexets
    o1 = data.charCodeAt(i++);
    o2 = data.charCodeAt(i++);
    o3 = data.charCodeAt(i++);

    bits = o1 << 16 | o2 << 8 | o3;

    h1 = bits >> 18 & 0x3f;
    h2 = bits >> 12 & 0x3f;
    h3 = bits >> 6 & 0x3f;
    h4 = bits & 0x3f;

    // use hexets to index into b64, and append result to encoded string
    tmp_arr[ac++] = b64.charAt(h1) + b64.charAt(h2) + b64.charAt(h3) + b64.charAt(h4);
  } while (i < data.length);

  enc = tmp_arr.join('');

  var r = data.length % 3;

  return (r ? enc.slice(0, r - 3) : enc) + '==='.slice(r || 3);
}

/*!
 * FUNCAO       : carregaSelect
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 21/07/2015
 * OBJETIVO     : Efetua consulta de dados para select de Cooperativas, Regionais e PA's
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
 function carregaSelect(tpdaacao,flgativo,idpesq,flgtodco){ 
		
	var cdcooper = 0;
	var cddregio = 0;
	var cdagenci = 0;
	var cdeixtem = 0;
	var nrseqtem = 0;
	var cdevento = 0;
	var nmdaacao = "";
	var arr = "";
	
	flgtodco = typeof flgtodco !== 'undefined' ? flgtodco : false;
	
	// Verifica o tipo de acao
	if(tpdaacao == 0){ // Cooperativa
		
		if(idpesq){
			$("#cdcooperPesquisa").empty();
			$('#cdcooperPesquisa').append($('<option>', {
				value: 0,
				text: '-- SELECIONE --'
			}));
			
		}else{	
			$("#cdcooper").empty();
			$('#cdcooper').append($('<option>', {
				value: 0,
				text: '-- SELECIONE --'
			}));
		}
				
		cdcooper = idpesq ? $("#cdcooperPesquisa option:selected").val() : $("#cdcooper").val(); // Codigo da Cooperativa
		
		// Verifica se existe select de Regional
		if(idpesq){
			
			if($("#cddregioPesquisa").length){
				// Limpa selecte de Regional
				$("#cddregioPesquisa").empty();
				$('#cddregioPesquisa').append($('<option>', {
					value: 0,
					text: '-- SELECIONE --'
				}));
			}
			
			// Verifica se existe select de PA
			if($("#cdagenciPesquisa").length){
				// Limpa selecte de PA
				$("#cdagenciPesquisa").empty();
				$('#cdagenciPesquisa').append($('<option>', {
					value: 0,
					text: '-- SELECIONE --'
				}));
			}
		}else{
			
			if($("#cddregio").length){
				// Limpa selecte de Regional
				$("#cddregio").empty();
				$('#cddregio').append($('<option>', {
					value: 0,
					text: '-- SELECIONE --'
				}));
			}
			
			// Verifica se existe select de PA
			if($("#cdagenci").length){
				// Limpa selecte de PA
				$("#cdagenci").empty();
				$('#cdagenci').append($('<option>', {
					value: 0,
					text: '-- TODOS --'
				}));
			}
		}
		
	}else if(tpdaacao == 1){ // Regional
		
		// Verifica se existe select de Cooper
		if(idpesq){
			if($("#cdcooperPesquisa").length){
				// Atribui valor de Cooperativa
				cdcooper = $("#cdcooperPesquisa").val(); // Codigo da Cooperativa
			}
			// Verifica se existe select de PA
			if($("#cdagenciPesquisa").length){
				// Limpa selecte de PA
				$("#cdagenciPesquisa").empty();
				$('#cdagenciPesquisa').append($('<option>', {
					value: 0,
					text: '-- SELECIONE --'
				}));
			}
		}else{
			if($("#cdcooper").length){
				// Atribui valor de Cooperativa
				cdcooper = $("#cdcooper").val(); // Codigo da Cooperativa
			}
			
			// Verifica se existe select de PA
			if($("#cdagenci").length){
				// Limpa selecte de PA
				$("#cdagenci").empty();
				$('#cdagenci').append($('<option>', {
					value: 0,
					text: '-- SELECIONE --'
				}));
			}
		}
		cdcooper = idpesq ? $("#cdcooperPesquisa").val() : $("#cdcooper").val(); // Codigo da Cooperativa
		cddregio = idpesq ? $("#cddregioPesquisa").val() : $("#cddregio").val(); // Codigo da Regional
				
	}else if(tpdaacao == 2){ // PA
				
		if(idpesq){
			// Verifica se existe select de Cooper
			if($("#cdcooperPesquisa").length){
				// Atribui valor de Cooperativa
				cdcooper = $("#cdcooper").val(); // Codigo da Cooperativa
			}
			
			// Verifica se existe select de Regional
			if($("#cddregioPesquisa").length){
				// Atribui valor de Regional
				cddregio = $("#cddregioPesquisa").val(); // Codigo da Regional
			}
		}else{
			// Verifica se existe select de Cooper
			if($("#cdcooper").length){
				// Atribui valor de Cooperativa
				cdcooper = $("#cdcooper").val(); // Codigo da Cooperativa
			}	
			
			// Verifica se existe select de Regional
			if($("#cddregio").length){
				// Atribui valor de Regional
				cddregio = $("#cddregio").val(); // Codigo da Regional
			}
		}			
		cdcooper = idpesq ? $("#cdcooperPesquisa option:selected").val() : $("#cdcooper").val(); // Codigo da Cooperativa
		// Atribui valor selecionado de PA
		cdagenci = idpesq ? $("#cdagenciPesquisa option:selected").val() : $("#cdagenci").val(); // Codigo da Regional
		
	} else if (tpdaacao == 3) { // EIXO
		cdcooper = $("#cdcooper").val();
	} else if (tpdaacao == 4) { // TEMA
		cdcooper = $("#cdcooper").val();
		cdeixtem = $("#cdeixtem option:selected").val();
	} else if (tpdaacao == 5) { // EVENTO
		cdcooper = (idpesq) ? $("#cdcooperPesquisa option:selected").val() : $("#cdcooper").val();
		cdeixtem = $("#cdeixtem option:selected").val();
		nrseqtem = $("#nrseqtem option:selected").val();
		cdagenci = $("#cdagenciPesquisa option:selected").val();
	} else if (tpdaacao == 6) { // carrega as agencias juntando Cooperativa | PA - (WPGD0110)
		//valida a forma de pesquisa
		if ( idpesq ) {
			cdcooper = '';
			$("#cdcooperPesquisa option:selected").each( function() {
				cdcooper += (cdcooper == '') ? $(this).val() : ","+$(this).val();
			});	
		} else {
			cdcooper = $("#cdcooper").val(); // Codigo da Cooperativa
		}
	} else if (tpdaacao == 7) { // EVENTOS POR COOP. E PA
		tpdaacao = 5; //acao que carrega eventos por agencia e coop concatenados (Cooperativa | PA)
				
		cdagenci = '';
		$("#cdagenciPesquisa option:selected").each( function() {
			cdagenci += (cdagenci == '') ? $(this).val() : ','+$(this).val();
		});			
		
	}
	
	showMsgAguardo("Carregando Dados...");
	
	// Executa script de bloqueio através de ajax
	$.ajax({
		type: "POST",
		url: "../../includes/monta_select.php",
		dataType: "json",
		data: {
			tpdaacao: tpdaacao,	// Tipo da acao de consulta (0 - Cooper / 1 - Regional / 2 - PA)	
			cdcooper: cdcooper, // Codigo da Cooperativa
			cddregio: cddregio, // Codigo da Regional
			cdagenci: cdagenci, // Codigo do PA
			flgativo: flgativo, // Cooperativas Ativas
			cdeixtem: cdeixtem, // eixo
			nrseqtem: nrseqtem, // tema
			cdevento: cdevento, // evento
			redirect: "script_ajax",
			async: true
		},
		success: function(json) {
			if(tpdaacao == 0){
				montaSelectCoop(json,idpesq,flgtodco);
			}else if(tpdaacao == 1){
				montaSelectRegio(json,idpesq);
			}else if(tpdaacao == 2){
				montaSelectPA(json,idpesq);
			}else if(tpdaacao == 3){			
				montaComboSelect(json, 'eixo');
			}else if(tpdaacao == 4){
				montaComboSelect(json, 'tema');
			}else if(tpdaacao == 5){
				montaComboSelect(json, 'evento');			
			}else if(tpdaacao == 6){
				montaComboSelect(json, 'coop_pa');				
			}
		}
	});
	setTimeout(function(){hideMsgAguardo();},5000);
}


/*!
 * FUNCAO       : montaComboSelect
 * CRIAÇÃO      : Carlos Rafael Tanholi
 * DATA CRIAÇÃO : 30/11/2015
 * OBJETIVO     : Monta select com as informacoes de (eixo,tema,evento)
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
function montaComboSelect(json,tipo) {
	
	var campo = '';
	
	if ( tipo == 'eixo' ) {
		campo = '#cdeixtem';
	} else if ( tipo == 'tema' ) {
		campo = '#nrseqtem';
	} else if ( tipo == 'evento' ) {
		campo = '#cdevento';
	} else if ( tipo == 'coop_pa' ) {
		campo = '#cdagenciPesquisa';
	}
	
	$(campo).empty();
	$(campo).append($('<option>', {
		value: 0,
		text: "TODOS"
	}));		

	$.each(json, function (key, data) {		
		if ( tipo == 'eixo' ) {
			$(campo).append($('<option>', {
				value: data.cdeixtem,
				text: data.dseixtem
			}));			
		
		} else if ( tipo == 'tema' ) {
			$(campo).append($('<option>', {
				value: data.nrseqtem,
				text: data.dstemeix
			}));
		
		} else if ( tipo == 'evento' ) {
			$(campo).append($('<option>', {
				value: data.cdevento,
				text: data.nmevento
			}));		
		} else if ( tipo == 'coop_pa' ) {
			$(campo).append($('<option>', {
				value: data.cdagenci,
				text: data.nmresage
			}));
		}
	});
	hideMsgAguardo();	
	
}


/*!
 * FUNCAO       : montaSelectCoop
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 21/07/2015
 * OBJETIVO     : Monta select com as informacoes de cooperativas
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
function montaSelectCoop(json,idpesq,flgtodco) {
	
	showMsgAguardo("Carregando Cooperativas...");
	
	if(idpesq){
		// Limpa Select de Cooperativa
		$('#cdcooperPesquisa').empty();
		$('#cdcooperPesquisa').append($('<option>', {
			value: 0,
			text: "-- SELECIONE --"
		}));	
		
		if(flgtodco){
			$('#cdcooper').append($('<option>', {
				value: 99,
				text: '* TODAS'
			}));
		}
	}else{
		// Limpa Select de Cooperativa
		$('#cdcooper').empty();
		$('#cdcooper').append($('<option>', {
			value: 0,
			text: "-- SELECIONE --"
		}));	
		
		if(flgtodco){
			$('#cdcooper').append($('<option>', {
				value: 99,
				text: '* TODAS'
			}));
		}
	}	
		
	$.each(json, function (key, data) {
		if(data.cdcooper != 0 && data.cdcooper != ""){
			if(idpesq){
				$('#cdcooperPesquisa').append($('<option>', {
					value: data.cdcooper,
					text: data.nmrescop
				}));
				arrcoper = 	arrcoper + "-" + data.cdcooper + "," + data.nmrescop;
				arrcoper = arrcoper.substr(1);	
			}else{
				$('#cdcooper').append($('<option>', {
					value: data.cdcooper,
					text: data.nmrescop
				}));
			}
		}
	})
	hideMsgAguardo();
}

/*!
 * FUNCAO       : montaSelectRegio
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 21/07/2015
 * OBJETIVO     : Monta select com as informacoes de regionais
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
function montaSelectRegio(json,idpesq) {
		
	var flgativo = false;	
	showMsgAguardo("Carregando Regionais...");
	
	if(idpesq){
		// Limpa Select de Regionais
		$('#cddregioPesquisa').empty();
		$('#cddregioPesquisa').append($('<option>', {
			value: 0,
			text: "-- SELECIONE --"
		}));
	}else{
		// Limpa Select de Regionais
		$('#cddregio').empty();
		$('#cddregio').append($('<option>', {
			value: 0,
			text: "-- SELECIONE --"
		}));	
	}
	
	$.each(json, function (key, data) {
		flgativo = true;
		if(data.cddregio != 0 && data.cddregio != ""){				
			
			if(idpesq){
			
				$('#cddregioPesquisa').append($('<option>', {
					value: data.cddregio,
					text: data.dsdregio
				}));
				arrregio = 	arrregio + "-" + data.cddregio + "," + data.dsdregio;
				arrregio = arrregio.substr(1);
			}else{
			
				$('#cddregio').append($('<option>', {
					value: data.cddregio,
					text: data.dsdregio
				}));
			}			
		}	
	})	
	
	if(!flgativo){
		$('#cddregioPesquisa').empty();
		$('#cddregio').empty();
		$('#cddregio').append($('<option>', {
			value: 0,
			text: "Não se aplica"
		}));
	}
	
	hideMsgAguardo();	
}

/*!
 * FUNCAO       : montaSelectPA
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 21/07/2015
 * OBJETIVO     : Monta select com as informacoes de pa
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
function montaSelectPA(json,idpesq) {
		
	showMsgAguardo("Carregando PA's...");

	if(idpesq){
		// Limpa Select de PA
		$('#cdagenciPesquisa').empty();
		$('#cdagenciPesquisa').append($('<option>', {
			value: 0,
			text: "-- TODOS --"
		}));
	}else{
		// Limpa Select de PA
		$('#cdagenci').empty();
		$('#cdagenci').append($('<option>', {
			value: 0,
			text: "-- TODOS --"
		}));
	}	
	
	
	$.each(json, function (key, data) {
		if(data.cdagenci != 0 && data.cdagenci != ""){	
			if(idpesq){
				$('#cdagenciPesquisa').append($('<option>', {
					value: data.cdagenci,
					text: data.nmresage
				}));
				arragenc = 	arragenc + "-" + data.cdagenci + "," + data.nmresage;
				arragenc = arragenc.substr(1);
			}else{		
				$('#cdagenci').append($('<option>', {
					value: data.cdagenci,
					text: data.nmresage
				}));
			}
		}	
	})		
	//
	
	hideMsgAguardo();	
}



