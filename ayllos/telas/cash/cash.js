/*!
 * FONTE        : cash.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 25/10/2011
 * OBJETIVO     : Biblioteca de funções da tela CASH
 * --------------
 * ALTERAÇÕES   :
 * 28/06/2012 - Jorge    	(CECRED): Ajustado para novo esquema de impressao em funcoes Gera_Impressao() e Gera_Log()
 * 27/05/2014 - Incluido a informação de espécie de deposito e
                relatório do mesmo. (Andre Santos - SUPERO)
 * 14/09/2012 - David Kruger(CECRED): Ajuste para novo padrao de layout.
 * 24/07/2013 - James		(CECRED): Ajustado para permitir imprimir o relatório de cartões magnéticos.
 * 13/08/2013 - Carlos  	(CECRED): Alteração da sigla PAC para PA.
 * 18/11/2013 - Jorge    	(CECRED): Adicioando campo flgblsaq em funcao mostraTransacao.
 * 28/02/2014 - Jean Michel (CECRED): Liberação do campo PA para alteração.
 * 23/06/2014 - Rodrigo Bertelli (RKAM): Ajuste de quebra na tabela de depósitos.
 * 14/11/2014 - Jean Reddiga (RKAM) : Ajuste na função FormataData para obedecer ao parametro operação 
 * 22/04/2015 - Jaison/Elton(CECRED): Ajustado o cabecalho da tabela de listagem de depositos
 * 27/07/2016 - Criacao da opcao 'S'. (Jaison/Anderson)
 * 25/07/2017 - #712156 Melhoria 274, inclusão do campo flgntcem (Carlos)
 * 03/07/2018 - sctask0014656 permitir alterar a descricao do TAA (Carlos)
 * --------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmDados   		= 'frmCash';
var tabDados		= 'tabCash';

var cddopcao		= 'C';
var nrJanelas		= 0;

var cddoptel		= '';
var opcaorel		= '';
var lgagetfn		= '';
var cdagetfn		= '';
var dtmvtini		= '';
var dtmvtfim		= '';
var tiprelat		= '';
var nmarqimp		= '';
var nmarqpdf		= '';
var nmdireto		= '';
	
var flsistaa		= '';
var mmtramax		= '0';
var opreldep        = '';
var nrterfin1       = '0';
var dtmvtini        = '';
var dtmvtfim        = '';
var cdsitenv        = '';

//Labels/Campos do cabeçalho
var rCddopcao, rNrterfin,
	cCddopcao, cNrterfin, cDsterfin, btnOK, cTodosCabecalho, cNrterfin1, rNrterfin1 ,cDsterfin1;
	
$(document).ready(function() {
	estadoInicial();
});


// seletores
function estadoInicial() {
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	
	nrJanelas	= 0;
	cddoptel	= '';
	opcaorel    = '';
	lgagetfn	= '';
	cdagetfn	= '';
	dtmvtini	= '';
	dtmvtfim	= '';
	tiprelat	= '';
	nmarqimp	= '';
	nmarqpdf	= '';
	nmdireto	= '';
	flsistaa	= '';
	
	fechaRotina( $('#divUsoGenerico') ); 
	$('#divUsoGenerico').html('');
	
	trocaBotao('Prosseguir');
	hideMsgAguardo();		
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	
	cCddopcao.val( cddopcao );
	cCddopcao.habilitaCampo();
	cCddopcao.focus();

	$('#frmCash').remove();
	
	removeOpacidade('divTela');
}


// controle
function controlaOperacao( operacao ) {
	
	var nrterfin = normalizaNumero( cNrterfin.val() );
	var dsterfin = cDsterfin.val();
	
	var mensagem = 'Aguarde, buscando dados ...';

	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cash/principal.php', 
		data    : 
				{ 	
					operacao	: operacao,
					cddopcao	: cddopcao,
					nrterfin	: nrterfin,
					dsterfin	: dsterfin,
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
	
	var nrterfin = normalizaNumero( cNrterfin.val() );
	var cdsitfin = cddopcao == 'A' ? $('#cdsitfin', '#frmConfiguracao').val() : $('#cdsitfin', '#'+frmDados).val();
	var dtlimite = $('#dtlimite', '#frmData').val();
	var cdagencx = $('#cdagenci', '#frmConfiguracao').val();
	var dsfabtfn = $('#dsfabtfn', '#frmConfiguracao').val();
	var dsmodelo = $('#dsmodelo', '#frmConfiguracao').val();
	var dsdserie = $('#dsdserie', '#frmConfiguracao').val();
	var nmnarede = $('#nmnarede', '#frmConfiguracao').val();
	var nrdendip = $('#nrdendip', '#frmConfiguracao').val();
	var qtcasset = $('#qtcasset', '#frmConfiguracao').val();
	var flgntcem = ($('#flgntcem', '#frmConfiguracao').is(':checked')) ? 'yes' : 'no';
	
	var flsistaa = cddopcao == 'B' ? $('#flsistaa', '#frmSistemaTAA').val() : $('#flsistaa', '#'+frmDados).val();
	var dsterfin = cddopcao == 'I' ? cDsterfin.val() : $('#dsterfin', '#frmConfiguracao').val();
	var qttotalp = $('#qttotalP', '#'+frmDados).val();
	var tprecolh = $('#tprecolh', '#frmOpcaoL').val();

    var nmterminal     = $('#nmterminal',    '#frmOpcaoS').val();
    var flganexo_pa    = $('#flganexo_pa',   '#frmOpcaoS').prop("checked") == true ? 1 : 0;
    var dslogradouro   = $('#dslogradouro',  '#frmOpcaoS').val();
    var dscomplemento  = $('#dscomplemento', '#frmOpcaoS').val();
    var nrendere       = $('#nrendere',      '#frmOpcaoS').val();
    var nmbairro       = $('#nmbairro',      '#frmOpcaoS').val();
    var nrcep          = $('#nrcep',         '#frmOpcaoS').val();
    var idcidade       = $('#idcidade',      '#frmOpcaoS').val();
    var nrlatitude     = $('#nrlatitude ',   '#frmOpcaoS').val();
    var nrlongitude    = $('#nrlongitude ',  '#frmOpcaoS').val();
    var dshorario      = $('#dshorario',     '#frmOpcaoS').val();

	if ( $('#opcaorel', '#frmRelatorio').val() == 3 ) {
		opreldep = "Depositos";
	}
	
	var mensagem = 'Aguarde, realizando operação...';
	
	switch( operacao ) {
		case 'BDCM'      :
		case 'BD'        : mensagem = 'Aguarde, buscando informacoes...'; break;		
		case 'VP'        : mensagem = 'Aguarde, validando...';            break;
		case 'VD'        : mensagem = 'Aguarde, validando...';            break;
        case 'CASH_DADOS_SITE':
		case 'GD'        : mensagem = 'Aguarde, gravando...';             break;
	}

	fechaRotina( $('#divUsoGenerico') );
 	showMsgAguardo( mensagem );	
	
	$.ajax({		
			type  : 'POST',
			url   : UrlSite + 'telas/cash/manter_rotina.php', 		
			data: {
				operacao	: operacao,
				cddopcao	: cddopcao,
				nrterfin	: nrterfin,
				cdagencx	: cdagencx,
				dsfabtfn	: dsfabtfn,
				dsmodelo    : dsmodelo,
				dsdserie    : dsdserie,
				nmnarede    : nmnarede,
				nrdendip    : nrdendip,
				cdsitfin    : cdsitfin,
				qtcasset    : qtcasset,
				flsistaa    : flsistaa,
				dsterfin    : dsterfin,
				tprecolh    : tprecolh,
				qttotalp    : qttotalp,
				dtlimite	: dtlimite,
				
				cddoptel	: cddoptel,
				opcaorel	: opcaorel,
				opreldep    : opreldep,
				nrterfin1   : nrterfin1,
				cdsitenv    : cdsitenv,
				cdagetfn	: cdagetfn,
				lgagetfn	: lgagetfn,
				dtmvtini	: dtmvtini,
				dtmvtfim	: dtmvtfim,
				tiprelat	: tiprelat,
				
				nmarqimp	: nmarqimp,

                nmterminal    : nmterminal,
                flganexo_pa   : flganexo_pa,
                dslogradouro  : dslogradouro,
                dscomplemento : dscomplemento,
                nrendere      : normalizaNumero(nrendere),
                nmbairro      : nmbairro,
                nrcep         : normalizaNumero(nrcep),
                idcidade      : normalizaNumero(idcidade),
                nrlatitude    : nrlatitude,
                nrlongitude   : nrlongitude,
                dshorario     : dshorario,
				flgntcem      : flgntcem,
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

function controlaPesquisasTerminal() {

	var linkTerminal1 = $('a:not(.lupaFat)','#frmRelatorio');

	linkTerminal1.css('cursor','pointer').unbind('click').bind('click', function() {			
			
		var bo 			= 'b1wgen0059.p';
		var procedure	= 'busca_chashes';
		var titulo      = 'Busca do Terminal';
		var qtReg		= '30';
		var filtrosPesq	= 'Cash;nrterfin1;30px;S;0|Descricao;dsterfin1;200px;S';
		var colunas 	= 'Cash;nrterfin;20%;right|Rede;nmnarede;30%;left|Descricao;dsterfin1;50%;left';
		mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,$('#divRotina'));
	
		bloqueiaFundo( $('#divRotina') );
		return false;
		
	});
	
	cNrterfin1.unbind('change').bind('change',function() {

		bo			= 'b1wgen0059.p';
        procedure   = 'busca_chashes';
        titulo      = 'Busca do Terminal';
        filtrosDesc = 'Cash;nrterfin1'+cNrterfin1.val();
		buscaDescricao(bo,procedure,titulo,cNrterfin1.attr('name'),'dsterfin1',cNrterfin1.val(),'nmterfin',filtrosDesc,'frmRelatorio');
	
		return false;
    });
	
	return false;
}
	
function controlaPesquisas() {

	/*---------------------*/
	/*  CONTROLE TERMINAL  */
	/*---------------------*/
	var linkTerminal = $('a:eq(1)','#'+frmCab);
		
	if ( linkTerminal.prev().hasClass('campoTelaSemBorda') || cddopcao == 'I' ) {		
		linkTerminal.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkTerminal.css('cursor','pointer').unbind('click').bind('click', function() {			
			
			var bo 			= 'b1wgen0059.p';
			var procedure	= 'busca_chashes';
			var titulo      = 'Busca do Terminal';
			var qtReg		= '30';
			var filtrosPesq	= 'Cash;nrterfin;30px;S;0|Descricao;nmterfin;200px;S';
			var colunas 	= 'Cash;nrterfin;20%;right|Rede;nmnarede;30%;left|Descricao;nmterfin;50%;left';
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,$('#divTela'));
			return false;
		});
	}
	
	// controle das busca descrições
	/*
	linkTerminal.prev().unbind('change').bind('change',function() {		
		bo			= 'b1wgen0059.p';
		procedure	= 'busca_chashes';
		titulo      = 'Busca do Terminal';
		filtrosDesc = 'nrterfin|'+$(this).val();
		divRotina 	= $('#divRotina');
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'nmterfin',$(this).val(),'nmterfin',filtrosDesc,'frmRelatorio');
		return false;
	});	
	*/

	/*---------------------*/
	/*    CONTROLE PA     */
	/*---------------------*/
	var linkPAC = $('a:eq(1)','#frmRelatorio');		
	if ( linkPAC.prev().hasClass('campoTelaSemBorda') ) {		
		linkPAC.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkPAC.css('cursor','pointer').unbind('click').bind('click', function() {			
			
			var bo 			= 'b1wgen0059.p';
			var procedure	= 'Busca_Pac';
			var titulo      = 'Busca PA';
			var qtReg		= '30';
			var filtrosPesq	= 'PA;cdagetfn;30px;S;0|Descricao;dsagetfn;200px;S';
			var colunas 	= 'PA;cdagepac;20%;right|Descricao;dsagepac;50%;left';
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,$('#divRotina'));
			return false;
		});
	}
	
	// controle das busca descrições
	linkPAC.prev().unbind('change').bind('change',function() {		
		var bo			= 'b1wgen0059.p';
		var procedure	= 'busca_pac';
		var titulo      = 'Busca PA';
		var filtrosDesc = 'cdagepac|'+$(this).val();
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsagetfn',$(this).val(),'dsagepac',filtrosDesc,'divRotina');
		bloqueiaFundo( $('#divRotina') );
		return false;
	});

	/*---------------------*/
	/*   CONTROLE CIDADE   */
	/*---------------------*/
	var linkCidade = $('a:eq(0)','#frmOpcaoS');
	if ( linkCidade.prev().hasClass('campoTelaSemBorda') ) {
		linkCidade.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkCidade.css('cursor','pointer').unbind('click').bind('click', function() {			
			
			var cdestado    = $('#cdestado', '#frmOpcaoS').val();
            var bo          = 'CADA0003'
            var procedure   = 'LISTA_CIDADES';
            var titulo      = 'Cidades';
            var qtReg       = '20';
            var filtrosPesq = 'Codigo;idcidade;70px;S;;S;codigo|Cidade;dscidade;200px;S;;S;descricao|UF;cdestado;40px;S;' + cdestado + ';S;descricao|;infiltro;;N;1;N;codigo|;intipnom;;N;1;N;codigo|;cdcidade;;N;0;N;codigo';
            var colunas     = 'Codigo;idcidade;30%;center|Cidade;dscidade;60%;left|UF;cdestado;10%;center';
            mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,$('#divRotina'));
	        return false;
		});
    }

	return false;
}

function controlaLayout( operacao ) {

	formataCabecalho();
	
	//operacao = 'BD';
	if ( (cddopcao == 'A' || cddopcao == 'B' || cddopcao == 'C' || cddopcao == 'I' || cddopcao == 'L' || cddopcao == 'S' ) && operacao == '' ) {
		cCddopcao.desabilitaCampo();		
		if ( cddopcao == 'I' ) {
			// Buscar o código do próximo terminal e carregar na tela.
			manterRotina('BD');
		
			cNrterfin.desabilitaCampo();
			cDsterfin.habilitaCampo();
			cDsterfin.focus();
		}else{
			cNrterfin.habilitaCampo();
			cNrterfin.focus();
      cDsterfin.focus();            
		}
	} else if ( (cddopcao == 'C' || cddopcao == 'L') && operacao == 'BD' ) {
	    $('#divBotoes2:eq(0)').remove();
		formataDados();
		if ( cddopcao == 'L' ) {
			$('#divBotoes:eq(0)').html('');
			mostraOpcao('opcaol');
		}
		
	} else if ( cddopcao == 'A' && operacao == 'BD' ) {
		$('#frmCash').css({'display':'none'});
		$('#divBotoes:eq(0)', '#divTela').remove();
		mostraOpcao('configuracao');
	
	} else if ( cddopcao == 'A' && operacao == 'VD' ) {
		btnConfirmar( 'manterRotina(\'GD\');', 'fechaOpcao();')
	
	} else if ( cddopcao == 'A' && operacao == 'GD' ) {
		hideMsgAguardo();
		showError('inform','Alteracao efetuada com sucesso!','Alerta - Ayllos','fechaOpcao();');
	
	} else if ( cddopcao == 'B' && operacao == 'BD' ) {
		$('#frmCash').css({'display':'none'});
		$('#divBotoes:eq(0)', '#divTela').remove();
		if ( normalizaNumero( cNrterfin.val() ) == 0 ) cDsterfin.val('Todos os Terminais');
		mostraOpcao('sistema_taa');
	
	} else if ( cddopcao == 'B' && operacao == 'GD' ) {
		hideMsgAguardo();
		showError('inform','Alteracao efetuada com sucesso!','Alerta - Ayllos','fechaOpcao();');

	} else if ( cddopcao == 'L' && operacao == 'GD' ) {
		hideMsgAguardo();
		fechaOpcao();			
	
	} else if ( cddopcao == 'M' && operacao == '' ) {
		mostraOpcao('monitorar');

	} else if ( cddopcao == 'I' && operacao == 'BD' ) {
		$('#frmCash').css({'display':'none'});
		$('#divBotoes:eq(0)', '#divTela').remove();
		mostraOpcao('configuracao');
	
	} else if ( cddopcao == 'I' && operacao == 'VD' ) {
		btnConfirmar( 'manterRotina(\'GD\');', 'fechaOpcao()' );
	
	} else if ( cddopcao == 'I' && operacao == 'GD' ) {
		hideMsgAguardo();
		showError('inform','Terminal incluido com sucesso!','Alerta - Ayllos','fechaOpcao();');

	}else if ( cddopcao == 'R' && operacao == '' ) {
		mostraOpcao('relatorio');
		
	} else if ( cddopcao == 'R' && operacao == 'VP' ) {
		if ( cddoptel == 'A' ) { 
			buscaOpcao('diretorio');
		} else if ( opcaorel == 1 ) {		
			manterRotina('BD');
		} else if ( opcaorel == 2 ){			
			manterRotina('BDCM');
		}	
	} else if ( cddopcao == 'R' && ((operacao == 'BD' ) || (operacao == 'BDCM')) ){
		if ( cddoptel == 'T' ) { 
			showConfirmacao('Deseja visualizar impress&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','Gera_Impressao();hideMsgAguardo();fechaOpcao();','hideMsgAguardo();fechaOpcao();','sim.gif','nao.gif'); 
		}else{
			hideMsgAguardo();			
			showError('inform','Relatório gerado com sucesso!' ,'Alerta - Ayllos','fechaOpcao()');
		}
	} else if ( cddopcao == 'S' && operacao == 'BD' ) {
		$('#frmCash').css({'display':'none'});
		$('#divBotoes:eq(0)', '#divTela').remove();
		mostraOpcao('opcaoS');

	} else if ( cddopcao == 'S' && operacao == 'CASH_DADOS_SITE' ) {
		hideMsgAguardo();
		showError('inform','Dados gravados com sucesso!','Alerta - Ayllos','fechaOpcao();');

	}
	controlaPesquisas();
	return false;
}

// formata
function formataCabecalho() {

	// rotulo
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rNrterfin	        = $('label[for="nrterfin"]','#'+frmCab);        

	rCddopcao.addClass('rotulo').css({'width':'45px'});
	rNrterfin.addClass('rotulo-linha').css({'width':'180px'});
	
	// campo
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cNrterfin			= $('#nrterfin','#'+frmCab); 
	cDsterfin			= $('#dsterfin','#'+frmCab); 

	cCddopcao.css({'width':'510px'})
	cNrterfin.addClass('inteiro pesquisa').css({'width':'48px'}).attr('maxlength','4');	
	cDsterfin.css({'width':'218px'}).attr('maxlength','30');	

	// outros
	btnOK				= $('#btnOK', '#'+frmCab);
	var btSalvar        = $('#btSalvar','#divBotoes');
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);

	if ( $.browser.msie ) {
	}	

	cTodosCabecalho.desabilitaCampo();
	
	btnOK.unbind('click').bind('click', function() {
		if (divError.css('display') == 'block'){
		   return false;
		}
		
		if (cCddopcao.hasClass('campoTelaSemBorda')){
		   return false;
		}

		cTodosCabecalho.removeClass('campoErro');	
		cddopcao = cCddopcao.val();
		controlaLayout('');
		return false;
	});	
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnOK.click();
			return false;
		} 
	});	

	cNrterfin.unbind('keypress').bind('keypress', function(e) {
	    // Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
		    btnContinuar();
			return false;
		} 
	});	

	layoutPadrao();
	controlaPesquisas();
	return false;	
}

function formataDados() {

	/* TITULO */
	rLacre123 = $('label[for="lacre123"]', '#'+frmDados);
	rQtdnotas = $('label[for="qtdnotas"]', '#'+frmDados);
	rVldnotas = $('label[for="vldnotas"]', '#'+frmDados);
	rVldtotal = $('label[for="vldtotal"]', '#'+frmDados);

	rLacre123.addClass('rotulo').css({'width':'168px'});
	rQtdnotas.addClass('rotulo-linha').css({'width':'105px'});
	rVldnotas.addClass('rotulo-linha').css({'width':'127px'});	
	rVldtotal.addClass('rotulo-linha').css({'width':'136px'});	

	/* CASSETE A */
	// rotulo
	rCasseteA = $('label[for="casseteA"]', '#'+frmDados);
	rNrlacreA = $('label[for="nrlacreA"]', '#'+frmDados);
	rQtdnotaA = $('label[for="qtdnotaA"]', '#'+frmDados);
	rVldnotaA = $('label[for="vldnotaA"]', '#'+frmDados);
	rVltotalA = $('label[for="vltotalA"]', '#'+frmDados);

	rCasseteA.addClass('rotulo').css({'width':'80px'});
	rNrlacreA.addClass('rotulo-linha').css({'width':'40px'});
	rQtdnotaA.addClass('rotulo-linha').css({'width':'40px'});	
	rVldnotaA.addClass('rotulo-linha').css({'width':'40px'});	
	rVltotalA.addClass('rotulo-linha').css({'width':'40px'});	

	// campo
	cNrlacreA = $('#nrlacreA', '#'+frmDados);
	cQtdnotaA = $('#qtdnotaA', '#'+frmDados);
	cVldnotaA = $('#vldnotaA', '#'+frmDados);
	cVltotalA = $('#vltotalA', '#'+frmDados);

	cNrlacreA.addClass('inteiro').css({'width':'50px'});
	cQtdnotaA.addClass('inteiro').css({'width':'50px'});
	cVldnotaA.addClass('monetario').css({'width':'100px'});
	cVltotalA.addClass('monetario').css({'width':'100px'});
	
	/* CASSETE B */
	// rotulo
	rCasseteB = $('label[for="casseteB"]', '#'+frmDados);
	rNrlacreB = $('label[for="nrlacreB"]', '#'+frmDados);
	rQtdnotaB = $('label[for="qtdnotaB"]', '#'+frmDados);
	rVldnotaB = $('label[for="vldnotaB"]', '#'+frmDados);
	rVltotalB = $('label[for="vltotalB"]', '#'+frmDados);

	rCasseteB.addClass('rotulo').css({'width':'80px'});
	rNrlacreB.addClass('rotulo-linha').css({'width':'40px'});
	rQtdnotaB.addClass('rotulo-linha').css({'width':'40px'});	
	rVldnotaB.addClass('rotulo-linha').css({'width':'40px'});	
	rVltotalB.addClass('rotulo-linha').css({'width':'40px'});	
	
	cNrlacreB = $('#nrlacreB', '#'+frmDados);
	cQtdnotaB = $('#qtdnotaB', '#'+frmDados);
	cVldnotaB = $('#vldnotaB', '#'+frmDados);	
	cVltotalB = $('#vltotalB', '#'+frmDados);

	cNrlacreB.addClass('inteiro').css({'width':'50px'});
	cQtdnotaB.addClass('inteiro').css({'width':'50px'});
	cVldnotaB.addClass('monetario').css({'width':'100px'});
	cVltotalB.addClass('monetario').css({'width':'100px'});
	
	
	/* CASSETE C */
	// rotulo

	rCasseteC = $('label[for="casseteC"]', '#'+frmDados);
	rNrlacreC = $('label[for="nrlacreC"]', '#'+frmDados);
	rQtdnotaC = $('label[for="qtdnotaC"]', '#'+frmDados);
	rVldnotaC = $('label[for="vldnotaC"]', '#'+frmDados);
	rVltotalC = $('label[for="vltotalC"]', '#'+frmDados);

	rCasseteC.addClass('rotulo').css({'width':'80px'});
	rNrlacreC.addClass('rotulo-linha').css({'width':'40px'});
	rQtdnotaC.addClass('rotulo-linha').css({'width':'40px'});	
	rVldnotaC.addClass('rotulo-linha').css({'width':'40px'});	
	rVltotalC.addClass('rotulo-linha').css({'width':'40px'});	
	
	cNrlacreC = $('#nrlacreC', '#'+frmDados);	
	cQtdnotaC = $('#qtdnotaC', '#'+frmDados);	
	cVldnotaC = $('#vldnotaC', '#'+frmDados);	
	cVltotalC = $('#vltotalC', '#'+frmDados);	

	cNrlacreC.addClass('inteiro').css({'width':'50px'});
	cQtdnotaC.addClass('inteiro').css({'width':'50px'});
	cVldnotaC.addClass('monetario').css({'width':'100px'});
	cVltotalC.addClass('monetario').css({'width':'100px'});
	
	/* CASSETE D */
	// rotulo
	rCasseteD = $('label[for="casseteD"]', '#'+frmDados);
	rNrlacreD = $('label[for="nrlacreD"]', '#'+frmDados);
	rQtdnotaD = $('label[for="qtdnotaD"]', '#'+frmDados);
	rVldnotaD = $('label[for="vldnotaD"]', '#'+frmDados);
	rVltotalD = $('label[for="vltotalD"]', '#'+frmDados);

	rCasseteD.addClass('rotulo').css({'width':'80px'});
	rNrlacreD.addClass('rotulo-linha').css({'width':'40px'});
	rQtdnotaD.addClass('rotulo-linha').css({'width':'40px'});	
	rVldnotaD.addClass('rotulo-linha').css({'width':'40px'});	
	rVltotalD.addClass('rotulo-linha').css({'width':'40px'});	
	
	cNrlacreD = $('#nrlacreD', '#'+frmDados);
	cQtdnotaD = $('#qtdnotaD', '#'+frmDados);	
	cVldnotaD = $('#vldnotaD', '#'+frmDados);	
	cVltotalD = $('#vltotalD', '#'+frmDados);	

	cNrlacreD.addClass('inteiro').css({'width':'50px'});
	cQtdnotaD.addClass('inteiro').css({'width':'50px'});
	cVldnotaD.addClass('monetario').css({'width':'100px'});
	cVltotalD.addClass('monetario').css({'width':'100px'});
	
	/* REJEITADOS */
	// rotulo
	rRejeitaR = $('label[for="rejeitaR"]', '#'+frmDados);
	rNrlacreR = $('label[for="nrlacreR"]', '#'+frmDados);
	rQtdnotaR = $('label[for="qtdnotaR"]', '#'+frmDados);
	rVltotalR = $('label[for="vltotalR"]', '#'+frmDados);

	rRejeitaR.addClass('rotulo').css({'width':'80px'});
	rNrlacreR.addClass('rotulo-linha').css({'width':'40px'});
	rQtdnotaR.addClass('rotulo-linha').css({'width':'40px'});	
	rVltotalR.addClass('rotulo-linha').css({'width':'186px'});	
	
	cNrlacreR = $('#nrlacreR', '#'+frmDados);
	cQtdnotaR = $('#qtdnotaR', '#'+frmDados);
	cVltotalR = $('#vltotalR', '#'+frmDados);	

	cNrlacreR.addClass('inteiro').css({'width':'50px'});
	cQtdnotaR.addClass('inteiro').css({'width':'50px'});
	cVltotalR.addClass('monetario').css({'width':'100px'});
	
	/* TOTAL */
	// rotulo
	rTotal12G = $('label[for="total12G"]', '#'+frmDados);
	rQtdnotaG = $('label[for="qtdnotaG"]', '#'+frmDados);
	rVltotalG = $('label[for="vltotalG"]', '#'+frmDados);

	rTotal12G.addClass('rotulo').css({'width':'80px'});
	rQtdnotaG.addClass('rotulo-linha').css({'width':'136px'});	
	rVltotalG.addClass('rotulo-linha').css({'width':'186px'});	

	cQtdnotaG = $('#qtdnotaG', '#'+frmDados);	
	cVltotalG = $('#vltotalG', '#'+frmDados);	

	cQtdnotaG.addClass('inteiro').css({'width':'50px'});
	cVltotalG.addClass('monetario').css({'width':'100px'});

	/* Envelope e Situacao */
	rQttotalP= $('label[for="qttotalP"]', '#'+frmDados);
	rDssittfn= $('label[for="dssittfn"]', '#'+frmDados);

	rQttotalP.addClass('rotulo').css({'width':'80px'});
	rDssittfn.addClass('rotulo-linha').css({'width':'175px'});

	cQttotalP = $('#qttotalP', '#'+frmDados);	
	cDssittfn = $('#dssittfn', '#'+frmDados);	

	cQttotalP.addClass('inteiro').css({'width':'150px'});
	cDssittfn.css({'width':'150px'});
	
	/* Operador */
	rNmoperad = $('label[for="nmoperad"]', '#'+frmDados);
	rNmoperad.addClass('rotulo').css({'width':'80px'});

	cNmoperad = $('#nmoperad', '#'+frmDados);	
	cNmoperad.css({'width':'481px'});
	
	if ( $.browser.msie ) {
		rVltotalR.css({'width':'183px'}); 
		rQtdnotaG.css({'width':'133px'});	
		rVltotalG.css({'width':'183px'});
		rDssittfn.css({'width':'167px'});
		cNmoperad.css({'width':'470px'});
	
	}	
	
	cTodosDados = $('input[type="text"],select','#'+frmDados);
	cTodosDados.desabilitaCampo();
	layoutPadrao();
	return false;
}

function formataOperacao() { 

	// tabela
	var divRegistro = $('div.divRegistros', '#frmOperacao');		
	var tabela      = $('table', divRegistro );
	
	$('#frmOperacao').css({'margin-top':'5px'});
	divRegistro.css({'height':'208px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '62px'; 
 	arrayLargura[1] = '48px';
	arrayLargura[2] = '200px';
	arrayLargura[3] = '110px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	// centraliza a divRotina
	$('#divRotina').css({'width':'585px'});
	$('#divConteudo').css({'width':'560px'});
	$('#divRotina').centralizaRotinaH();
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	return false;
}

function formataConfiguracao() {

	var legend = $('legend', '#frmConfiguracao');

	// label
  rDsterfin = $('label[for="dsterfin"]', '#frmConfiguracao');
	rCdagenci = $('label[for="cdagenci"]', '#frmConfiguracao');
	rDsfabtfn = $('label[for="dsfabtfn"]', '#frmConfiguracao');
	rDsmodelo = $('label[for="dsmodelo"]', '#frmConfiguracao');
	rDsdserie = $('label[for="dsdserie"]', '#frmConfiguracao');
	rNmnarede = $('label[for="nmnarede"]', '#frmConfiguracao');
	rCdsitfin = $('label[for="cdsitfin"]', '#frmConfiguracao');
	rQtcasset = $('label[for="qtcasset"]', '#frmConfiguracao');
	rDstempor = $('label[for="dstempor"]', '#frmConfiguracao');
	rDsdispen = $('label[for="dsdispen"]', '#frmConfiguracao');
	rNoturno1 = $('label[for="noturno1"]', '#frmConfiguracao');
	rDsininot = $('label[for="dsininot"]', '#frmConfiguracao');
	rDsinino2 = $('label[for="dsinino2"]', '#frmConfiguracao');
	rDsfimnot = $('label[for="dsfimnot"]', '#frmConfiguracao');
	rDsfimno2 = $('label[for="dsfimno2"]', '#frmConfiguracao');
	rDssaqnot = $('label[for="dssaqnot"]', '#frmConfiguracao');
	rFlgntcem = $('label[for="flgntcem"]', '#frmConfiguracao');

  rDsterfin.addClass('rotulo').css({'width':'135px'});
	rCdagenci.addClass('rotulo').css({'width':'135px'});
	rDsfabtfn.addClass('rotulo').css({'width':'135px'});	
	rDsmodelo.addClass('rotulo').css({'width':'135px'});	
	rDsdserie.addClass('rotulo').css({'width':'135px'});
	rNmnarede.addClass('rotulo').css({'width':'135px'});
	rCdsitfin.addClass('rotulo').css({'width':'135px'});
	rQtcasset.addClass('rotulo').css({'width':'135px'});
	rDstempor.addClass('rotulo').css({'width':'135px'});
	rDsdispen.addClass('rotulo').css({'width':'135px'});
	rNoturno1.addClass('rotulo').css({'width':'135px'});
	rDsininot.addClass('rotulo-linha').css({'width':'37px'});	
	rDsinino2.addClass('rotulo-linha').css({'width':'35px'});	
	rDsfimnot.addClass('rotulo').css({'width':'175px'});
	rDsfimno2.addClass('rotulo-linha').css({'width':'35px'});
	rDssaqnot.addClass('rotulo').css({'width':'175px'});
	rFlgntcem.addClass('rotulo').css({'width':'135px'});
	
	// campos
  cDsterfin = $('#dsterfin', '#frmConfiguracao');
	cCdagenci = $('#cdagenci', '#frmConfiguracao');
	cDsfabtfn = $('#dsfabtfn', '#frmConfiguracao');
	cDsmodelo = $('#dsmodelo', '#frmConfiguracao');
	cDsdserie = $('#dsdserie', '#frmConfiguracao');
	cNmnarede = $('#nmnarede', '#frmConfiguracao');
	cNrdendip = $('#nrdendip', '#frmConfiguracao');
	cCdsitfin = $('#cdsitfin', '#frmConfiguracao');
	cDssittfn = $('#dssittfn', '#frmConfiguracao');
	cQtcasset = $('#qtcasset', '#frmConfiguracao');
	cDstempor = $('#dstempor', '#frmConfiguracao');
	cDsdispen = $('#dsdispen', '#frmConfiguracao');
	//cNoturno1 = $('#noturno1', '#frmConfiguracao');
	cDsininot = $('#dsininot', '#frmConfiguracao');
	cDsfimnot = $('#dsfimnot', '#frmConfiguracao');
	cDssaqnot = $('#dssaqnot', '#frmConfiguracao');
	cFlgntcem = $('#flgntcem', '#frmConfiguracao');

  cDsterfin.css({'width':'200px'}).attr('maxlength','25');
	cCdagenci.addClass('inteiro').css({'width':'100px'}).attr('maxlength','3');
	cDsfabtfn.css({'width':'200px'}).attr('maxlength','25');
	cDsmodelo.css({'width':'200px'}).attr('maxlength','25');
	cDsdserie.css({'width':'200px'}).attr('maxlength','20');
	cNmnarede.css({'width':'100px'}).attr('maxlength','14');
	cNrdendip.css({'width':'97px'}).attr('maxlength','14');
	cCdsitfin.addClass('inteiro').css({'width':'40px'}).attr('maxlength','1');
	cDssittfn.css({'width':'157px'}).attr('maxlength','20');
	cQtcasset.addClass('inteiro').css({'width':'200px'}).attr('maxlength','1');
	cDstempor.css({'width':'200px'}).attr('maxlength','21');
	cDsdispen.css({'width':'200px'}).attr('maxlength','21');
	//cNoturno1.css({'width':'120px'});
	cDsininot.css({'width':'60px'}).attr('maxlength','8');
	cDsfimnot.css({'width':'60px'}).attr('maxlength','8');
	cDssaqnot.css({'width':'160px'}).attr('maxlength','25');	
	cFlgntcem.css({'border':'none','margin':'3px','height':'16px','background-color':'transparent'});

	if ( $.browser.msie ) {
		rDsfimnot.css({'width':'172px'});
		rDssaqnot.css({'width':'172px'});
	}	
	
	cTodosConfiguracao = $('input[type="text"],select','#frmConfiguracao');
	cTodosConfiguracao.desabilitaCampo();

	if ( cddopcao == 'C' ) {
		legend.html('Configuração');
		rCdsitfin.remove();
		cCdsitfin.remove();
		cDssittfn.remove();
		$('#btContinuar', '#divRotina').remove();
		cFlgntcem.desabilitaCampo();
	
	} else if ( cddopcao == 'A' ) {
		legend.html('Alterar Dados do Terminal');
        
    cDsterfin.habilitaCampo();
		cCdagenci.habilitaCampo();
		cDsfabtfn.habilitaCampo();
		cDsmodelo.habilitaCampo();
		cDsdserie.habilitaCampo();
		cNmnarede.habilitaCampo();
		cNrdendip.habilitaCampo();
		cCdsitfin.habilitaCampo();
		cFlgntcem.habilitaCampo();

    cDsterfin.focus();
	
	} else if ( cddopcao == 'I' ) {
		legend.html('Incluir Terminal');
		cCdagenci.habilitaCampo();
		cDsfabtfn.habilitaCampo();
		cDsmodelo.habilitaCampo();
		cDsdserie.habilitaCampo();
		cNmnarede.habilitaCampo();
		cNrdendip.habilitaCampo();
		cQtcasset.habilitaCampo();
		rCdsitfin.remove();
		cCdsitfin.remove();
		cDssittfn.remove();
		cCdagenci.focus();
    rDsterfin.remove();
    cDsterfin.remove();
	}

	cDsterfin.unbind('keypress').bind('keypress', function(e) {
	    // Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
		    cCdagenci.focus();            
			return false;
	}
	});	

	cCdagenci.unbind('keypress').bind('keypress', function(e) {
	    // Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
		    cDsfabtfn.focus();
			return false;
		} 
	});	
	
	cDsfabtfn.unbind('keypress').bind('keypress', function(e) {
	    // Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
		    cDsmodelo.focus();
			return false;
		} 
	});	
	
	cDsmodelo.unbind('keypress').bind('keypress', function(e) {
	    // Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
		    cDsdserie.focus();
			return false;
		} 
	});	
	
	cDsdserie.unbind('keypress').bind('keypress', function(e) {
	    // Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
		    cNmnarede.focus();
			return false;
		} 
	});	
	
	cNmnarede.unbind('keypress').bind('keypress', function(e) {
	    // Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
		    cNrdendip.focus();
			return false;
		} 
	});	
	
	cNrdendip.unbind('keypress').bind('keypress', function(e) {
	    // Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
		    cCdsitfin.focus();
			return false;
		} 
	});	
	
	if ( cddopcao == 'A' ){ 
		cNrdendip.unbind('keypress').bind('keypress', function(e) {
			// Se é a tecla ENTER, 
		    if ( e.keyCode == 13 ) {
		       cCdsitfin.focus();
			   return false;
		    } 
	    });	
	}
	
	if (cddopcao == 'I'){
	    cNrdendip.unbind('keypress').bind('keypress', function(e) {
	        // Se é a tecla ENTER, 
		    if ( e.keyCode == 13 ) {
		        cQtcasset.focus();
		       	return false;
		    } 
	    });	
	}	

	cQtcasset.unbind('keypress').bind('keypress', function(e) {
	    // Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
		      btnContinuar();
			return false;
		} 
	});	
	
	cCdsitfin.unbind('keypress').bind('keypress', function(e) {
	    // Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
		      cFlgntcem.focus();
			return false;
		} 
	});
	
	cFlgntcem.unbind('keypress').bind('keypress', function(e) {
	    // Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
		      btnContinuar();
			return false;
		} 
	});	
	
	// centraliza a divRotina
	$('#divRotina').css({'width':'425px'});
	$('#divConteudo').css({'width':'400px'});
	$('#divRotina').centralizaRotinaH();
	
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function formataSaldos() {

	// rotulos
	rVldsdini = $('label[for="vldsdini"]', '#frmSaldo');
	rVlsuprim = $('label[for="vlsuprim"]', '#frmSaldo');
	rVlrecolh = $('label[for="vlrecolh"]', '#frmSaldo');
	rVldsaque = $('label[for="vldsaque"]', '#frmSaldo');
	rVlestorn = $('label[for="vlestorn"]', '#frmSaldo');
	rVldsdfin = $('label[for="vldsdfin"]', '#frmSaldo');
	rVlrejeit = $('label[for="vlrejeit"]', '#frmSaldo');

	rVldsdini.addClass('rotulo').css({'width':'150px'});
	rVlsuprim.addClass('rotulo').css({'width':'150px'});	
	rVlrecolh.addClass('rotulo').css({'width':'150px'});
	rVldsaque.addClass('rotulo').css({'width':'150px'});	
	rVlestorn.addClass('rotulo').css({'width':'150px'});	
	rVldsdfin.addClass('rotulo').css({'width':'150px'});	
	rVlrejeit.addClass('rotulo').css({'width':'150px'});	
	
	// campos
	cVldsdini = $('#vldsdini', '#frmSaldo');	
	cVlsuprim = $('#vlsuprim', '#frmSaldo');
	cVlrecolh = $('#vlrecolh', '#frmSaldo');
	cVldsaque = $('#vldsaque', '#frmSaldo');
    cVlestorn = $('#vlestorn', '#frmSaldo');
    cVldsdfin = $('#vldsdfin', '#frmSaldo');
	cVlrejeit = $('#vlrejeit', '#frmSaldo');

	cVldsdini.addClass('monetario').css({'width':'120px'});	
	cVlsuprim.addClass('monetario').css({'width':'120px'});
	cVlrecolh.addClass('monetario').css({'width':'120px'});	
	cVldsaque.addClass('monetario').css({'width':'120px'});	
	cVlestorn.addClass('monetario').css({'width':'120px'});
	cVldsdfin.addClass('monetario').css({'width':'120px'});
	cVlrejeit.addClass('monetario').css({'width':'120px'});	

	cTodosSaldo = $('input[type="text"],select','#frmSaldo');
	cTodosSaldo.desabilitaCampo();

	// centraliza a divRotina
	$('#divRotina').css({'width':'400px'});
	$('#divConteudo').css({'width':'375px'});
	$('#divRotina').centralizaRotinaH();
	
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	if ( $('center:eq(0)', '#frmSaldo').html() == '' ) {
		fechaOpcao();
	}
	
	return false;
}

function formataSensores() { 
	
	// tabela
	var divRegistro = $('div.divRegistros', '#frmSensores');		
	var tabela      = $('table', divRegistro );
	
	$('#frmSensores').css({'margin-top':'5px'});
	divRegistro.css({'height':'245px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '200px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	// centraliza a divRotina
	$('#divRotina').css({'width':'425px'});
	$('#divConteudo').css({'width':'400px'});
	$('#divRotina').centralizaRotinaH();
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	return false;
}

function formataTransacoes() { 
	
	// tabela
	var divRegistro = $('div.divRegistros', '#frmTransacoes');		
	var tabela      = $('table', divRegistro );
	
	$('#frmTransacoes').css({'margin-top':'5px'});
	divRegistro.css({'height':'158px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '62px';  
	arrayLargura[1] = '48px';  
	arrayLargura[2] = '65px';
	arrayLargura[3] = '50px';
	arrayLargura[4] = '61px';
	arrayLargura[5] = '105px';
	arrayLargura[6] = '112px'; 

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'left';
	arrayAlinha[6] = 'left';
	arrayAlinha[7] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	/********************
	 FORMATA COMPLEMENTO	
	*********************/
	// complemento linha 1
	var linha1  = $('ul.complemento', '#linha1').css({'margin-left':'1px','width':'99.5%'});
	$('li:eq(0)', linha1).addClass('txtNormal').css({'width':'15%'});
	$('li:eq(1)', linha1).addClass('txtNormalBold').css({'width':'20%','text-align':'left'});
	$('li:eq(2)', linha1).addClass('txtNormal').css({'width':'6%','text-align':'right'});
	$('li:eq(3)', linha1).addClass('txtNormal').css({'width':'11%','text-align':'right'});

	// complemento linha 2
	var linha2  = $('ul.complemento', '#linha2').css({'clear':'both','border-top':'0','width':'99.5%'});

	$('li:eq(0)', linha2).addClass('txtNormal').css({'width':'15%'});
	$('li:eq(1)', linha2).addClass('txtNormalBold').css({'width':'20%','text-align':'left'});
	$('li:eq(2)', linha2).addClass('txtNormal').css({'width':'6%','text-align':'right'});
	$('li:eq(3)', linha2).addClass('txtNormal').css({'width':'11%','text-align':'right'});

	if ( $.browser.msie ) {
		$('li:eq(2)', linha1).css({'width':'8%'});
		$('li:eq(2)', linha2).css({'width':'8%'});
		$('li:eq(3)', linha1).css({'width':'12%'});
		$('li:eq(3)', linha2).css({'width':'12%'});
	}	
	
	// centraliza a divRotina
	$('#divRotina').css({'width':'625px'});
	$('#divConteudo').css({'width':'660px'});
	$('#divRotina').centralizaRotinaH();
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function formataDepositos() { 
	
	// tabela
	var divRegistro = $('div.divRegistros', '#frmDepositos');		
	var tabela      = $('table', divRegistro );
	
	$('#frmDepositos').css({'margin-top':'5px'});
	divRegistro.css({'height':'208px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '50px'; 
	arrayLargura[1] = '49px';
	arrayLargura[2] = '100px'; 
	arrayLargura[3] = '100px'; 
	arrayLargura[4] = '50px';
	arrayLargura[5] = '69px';
	arrayLargura[6] = '96px';
	arrayLargura[7] = '93px';
	arrayLargura[8] = '13px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';
	arrayAlinha[7] = 'left';
	arrayAlinha[8] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	// centraliza a divRotina
	$('#divRotina').css({'width':'590px'});
	$('#divConteudo').css({'width':'720px'});
	$('#divRotina').centralizaRotinaH();
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	return false;
}

function formataRelatorio() {
  
	// label
	rOpcaorel = $('label[for="opcaorel"]', '#frmRelatorio');
	rLgagetfn = $('label[for="lgagetfn"]', '#frmRelatorio');
	rCdagetfn = $('label[for="cdagetfn"]', '#frmRelatorio');
	rDtmvtini = $('label[for="dtmvtini"]', '#frmRelatorio');
	rDtmvtfim = $('label[for="dtmvtfim"]', '#frmRelatorio');
	rTiprelat = $('label[for="tiprelat"]', '#frmRelatorio');
	rNrterfin1 = $('label[for="nrterfin1"]', '#frmRelatorio');
	rCdsitenv = $('label[for="cdsitenv"]', '#frmRelatorio');

	rLgagetfn.addClass('rotulo').css({'width':'100px'});	
	rCdagetfn.addClass('rotulo-linha').css({'width':'28px'});
	rDtmvtini.addClass('rotulo').css({'width':'100px'});
	rDtmvtfim.addClass('rotulo-linha').css({'width':'25px'});
	rTiprelat.addClass('rotulo-linha').css({'width':'88px'});
	rCdsitenv.addClass('rotulo-linha').css({'width':'75px'});
	
	rNrterfin1.addClass('rotulo').css({'width':'130px'});
	
	// campo	
	cOpcaorel  = $('#opcaorel', '#frmRelatorio');
	cLgagetfn  = $('#lgagetfn', '#frmRelatorio');
	cCdagetfn  = $('#cdagetfn', '#frmRelatorio');
	cDsagetfn  = $('#dsagetfn', '#frmRelatorio');
	cDtmvtini  = $('#dtmvtini', '#frmRelatorio');
	cDtmvtfim  = $('#dtmvtfim', '#frmRelatorio');
	cTiprelat  = $('#tiprelat', '#frmRelatorio');
	cNrterfin1 = $('#nrterfin1', '#frmRelatorio');
	cDsterfin1 = $('#dsterfin1', '#frmRelatorio');
	cCdsitenv  = $('#cdsitenv', '#frmRelatorio');
		
	cCdagetfn.addClass('inteiro pesquisa').css({'width':'30px'}).attr('maxlength','3');
	cLgagetfn.css({'width':'55px'});
	cDsagetfn.css({'width':'175px'});
	cDtmvtini.addClass('data').css({'width':'74px'});
    cDtmvtfim.addClass('data').css({'width':'74px'});
    cTiprelat.css({'width':'75px'});	
	
	cNrterfin1.css({'width':'50px'});
	cDsterfin1.css({'width':'220px'});
	
	if ( $.browser.msie ) {
		rLgagetfn.css({'width':'100px'});	
		cDsagetfn.css({'width':'152px'});
	    rTiprelat.css({'width':'73px'});
	}
	
	var cTodosRelatorio = $('input[type="text"],select', '#frmRelatorio');
	var btOk			= $('#btnOK', '#frmRelatorio');
	var btOk1			= $('#btnOK1', '#frmRelatorio');
	
	$('#btSalvar', '#divRotina').css({'display':'none'});	
	cTodosRelatorio.limpaFormulario();
	cTodosRelatorio.desabilitaCampo();	
	
	cNrterfin1.hide();
	rNrterfin1.hide();
	cCdsitenv.hide();
	rCdsitenv.hide();
	
	
	cOpcaorel.habilitaCampo();
	cOpcaorel.focus();
	
	cLgagetfn.habilitaCampo();
	cLgagetfn.val('no');
	
	
	cOpcaorel.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 13 ) {
			if (cOpcaorel.val() == 1 || cOpcaorel.val() == 2){			
				cLgagetfn.habilitaCampo();
				cLgagetfn.focus();
			}else {
				cNrterfin1.show();
				cNrterfin1.habilitaCampo();
				cNrterfin1.focus();
			}
			return false;
		}
	});
	
	cOpcaorel.unbind('blur').bind('blur', function(e) {		
		if (cOpcaorel.val() == 1){
		
			$('#divRel2').css({'display':'none'});	
			$('#divRel1').css({'display':'block'});
			
			cNrterfin1.hide();
			rNrterfin1.hide();
			
			cCdsitenv.hide();
			rCdsitenv.hide();
			
			cCdagetfn.show();
			rCdagetfn.show();
			cLgagetfn.show();
			rLgagetfn.show();
			cDsagetfn.show();
			$('#btnOK', '#frmRelatorio').show();
			
			cDtmvtini.show();
			rDtmvtini.show();
			
			cDtmvtfim.show();
			rDtmvtfim.show();
			
			cTiprelat.show();
			rTiprelat.show();
		
		}else
 		if (cOpcaorel.val() == 2){
		
			$('#divRel2').css({'display':'none'});	
			$('#divRel1').css({'display':'block'});
			
			cNrterfin1.hide();
			rNrterfin1.hide();
			
			cDtmvtini.hide();
			rDtmvtini.hide();
			
			cDtmvtfim.hide();
			rDtmvtfim.hide();
			
			cTiprelat.hide();
			rTiprelat.hide();
			
			cCdsitenv.hide();
			rCdsitenv.hide();
			
			cCdagetfn.show();
			cLgagetfn.show();
			cDsagetfn.show();
			rCdagetfn.show();
			rLgagetfn.show();

		}else
 		if (cOpcaorel.val() == 3){
			$('#divRel1').css({'display':'none'});	
			$('#divRel2').css({'display':'block'});
			
			cCdagetfn.hide();
			rCdagetfn.hide();
			
			cLgagetfn.hide();
			rLgagetfn.hide();
			
			cDsagetfn.hide();
			rCdagetfn.hide();			
									
			cNrterfin1.show();
			rNrterfin1.show();
			
			cNrterfin1.show();
			cNrterfin1.focus();
			
			cDtmvtini.show();
			rDtmvtini.show();
			
			cDtmvtfim.show();
			rDtmvtfim.show();
			
			cTiprelat.hide();
			rTiprelat.hide();
			
			cCdsitenv.show();
			rCdsitenv.show();
		}
		
		return false;
	});		
	
	cLgagetfn.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btOk.click();
			return false;
		} 
	});

	cNrterfin1.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btOk1.focus();
			var oBtnSalvar = $('#btSalvar', '#divRotina');
			oBtnSalvar.show();
			return false;
		} 
	});
	
	controlaPesquisasTerminal();
	
	btOk1.unbind('click').bind('click', function() {
		cDtmvtini.habilitaCampo();
		cDtmvtfim.habilitaCampo();
		cCdsitenv.habilitaCampo();
		cDtmvtini.focus();
		cDtmvtini.val( dtmvtolt );
		cDtmvtfim.val( dtmvtolt );
		return false;
	});		
	
	cDtmvtini.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cDtmvtfim.focus();
			return false;
		} 
	});
	
	cDtmvtfim.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cCdsitenv.focus();
			return false;
		} 
	});
	
	cCdsitenv.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnContinuar();
			return false;
		} 
	});
	
	var oBtnSalvar = $('#btSalvar', '#divRotina');
	btOk.unbind('click').bind('click', function() {
		
		if ( cLgagetfn.val() == 'yes' )	{
			cLgagetfn.desabilitaCampo();
			cCdagetfn.habilitaCampo();
			cDtmvtini.habilitaCampo();
			cDtmvtfim.habilitaCampo();		
			oBtnSalvar.show();
			cCdagetfn.focus();			
		
			cCdagetfn.unbind('keypress').bind('keypress', function(e) {
				// Se é a tecla ENTER, 
				if ( e.keyCode == 13 ) {					
					// Relatório de Movimentações
					if (cOpcaorel.val() == 1){
						cDtmvtini.focus();
					// Relatório de Cartões de Crédito
					}else{
						btnContinuar();
					}
					return false;
				} 
			});	
			
			cDtmvtini.unbind('keypress').bind('keypress', function(e) {
				// Se é a tecla ENTER, 
				if ( e.keyCode == 13 ) {
					cDtmvtfim.focus();
					return false;
				} 
			});
			
			cDtmvtfim.unbind('keypress').bind('keypress', function(e) {
				// Se é a tecla ENTER, 
				if ( e.keyCode == 13 ) {
					btnContinuar();
					return false;
				} 
			});
			
		} else if ( cLgagetfn.val() == 'no' ) {
			cLgagetfn.desabilitaCampo();
			cDtmvtini.habilitaCampo();
			cDtmvtfim.habilitaCampo();		
			cTiprelat.habilitaCampo().val('yes');
			oBtnSalvar.show();
			
			// Relatório de Movimentações
			if (cOpcaorel.val() == 1){
				cDtmvtini.focus();
			// Relatório de Cartões de Crédito
			}else{
				btnContinuar();
				return false;
			}
					
			cDtmvtini.unbind('keypress').bind('keypress', function(e) {
				// Se é a tecla ENTER, 
				if ( e.keyCode == 13 ) {
					cDtmvtfim.focus();
					return false;
				} 
			});
			
			cDtmvtfim.unbind('keypress').bind('keypress', function(e) {
				// Se é a tecla ENTER, 
				if ( e.keyCode == 13 ) {
					cTiprelat.focus();
					return false;
				} 
			});
			
			cTiprelat.unbind('keypress').bind('keypress', function(e) {
				// Se é a tecla ENTER, 
				if ( e.keyCode == 13 ) {
					btnContinuar();
					return false;
				} 
			});
		}
		cDtmvtini.val( dtmvtolt );
		cDtmvtfim.val( dtmvtolt );		
		controlaPesquisas();
		return false;

	});		
	
	// centraliza a divRotina
	$('#divRotina').css({'width':'408px'});
	$('#divConteudo').css({'width':'475px'});
	$('#divRotina').centralizaRotinaH();

	layoutPadrao();
	controlaPesquisas();
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	return false;
}

function formataData( operacao ) {
	
	var legend = '';
	
	//
	legend 		= $('legend:eq(0)', '#frmData');
	
	// label
	rDtfiltro	= $('label[for="dtlimite"]', '#frmData');	
	rDtinicio	= $('label[for="dtinicio"]', '#frmData');	
	rDtdfinal	= $('label[for="dtdfinal"]', '#frmData');		
	rCdsitenv	= $('label[for="cdsitenv"]', '#frmData');	
	
	// campos
	cDtfiltro	= $('#dtlimite', '#frmData');
	cDtinicio	= $('#dtinicio', '#frmData');
	cDtdfinal	= $('#dtdfinal', '#frmData');
	cCdsitenv	= $('#cdsitenv', '#frmData');

	// 
	$('label' , '#frmData').each(function() { $(this).css({'display':'none'}); });	
	$('input' , '#frmData').each(function() { $(this).css({'display':'none'}); });	
	$('select', '#frmData').each(function() { $(this).css({'display':'none'}); });

	if ( operacao == 'depositos' ) {
	
		legend.html('Depositos');
		
		rDtinicio.addClass('rotulo').css({'width':'35px', 'display':'block'});
		rDtdfinal.addClass('rotulo-linha').css({'width':'35px', 'display':'block'});
		rCdsitenv.addClass('rotulo-linha').css({'width':'60px', 'display':'block'});

		cDtinicio.addClass('campo data').css({'width':'80px', 'display':'block'});		
		cDtdfinal.addClass('campo data').css({'width':'80px', 'display':'block'});		
		cCdsitenv.addClass('campo').css({'width':'130px', 'display':'block'});		
		
		cDtinicio.unbind('keypress').bind('keypress', function(e) {
			// Se é a tecla ENTER, 
			if ( e.keyCode == 13 ) {
				cDtdfinal.focus();
				return false;
			} 
		});	
		
		cDtdfinal.unbind('keypress').bind('keypress', function(e) {
			// Se é a tecla ENTER, 
			if ( e.keyCode == 13 ) {
				cCdsitenv.focus();
				return false;
			} 
		});	
		
		cCdsitenv.unbind('keypress').bind('keypress', function(e) {
			// Se é a tecla ENTER, 
			if ( e.keyCode == 13 ) {
				mostraOpcao('depositos');
				return false;
			} 
		});	
		
		// centraliza a divUsoGenerico
		$('#divUsoGenerico').css({'width':'460px'});
		$('#divData').css({'width':'450px', 'height':'90px'});	
		$('#divUsoGenerico').centralizaRotinaH();
		
		layoutPadrao(); 
		hideMsgAguardo();		
		bloqueiaFundo( $('#divUsoGenerico') );
		cDtinicio.focus();
		
	} else {	

		legend.html('Entre com a data de referencia');
		
		cDtfiltro.addClass('campo data').css({'width':'100px', 'display':'block'});		
		rDtfiltro.addClass('rotulo').css({'width':'135px', 'display':'block'});
		
		cDtfiltro.unbind('keypress').bind('keypress', function(e) {
			// Se é a tecla ENTER, 
			if ( e.keyCode == 13 ) {
			    // Chamado 218234 - INICO - Jean Carlos Reddiga (RKAM)
			    //Se é consulta do LOG
				if ( operacao == 'log' ) {
				    Gera_Log();				   
				} else{
				  mostraOpcao( operacao );
				}
			    // Chamado 218234 - FIM - Jean Carlos Reddiga (RKAM)
				return false;
			} 
		});	
		
		// centraliza a divUsoGenerico
		$('#divUsoGenerico').css({'width':'355px'});
		$('#divData').css({'width':'330px', 'height':'90px'});	
		$('#divUsoGenerico').centralizaRotinaH();
		
		layoutPadrao(); 
		hideMsgAguardo();		
		bloqueiaFundo( $('#divUsoGenerico') );
		cDtfiltro.focus();
		
	}
		
	return false;
}

function formataSistemaTAA() {

	if ( flsistaa != '' ) {
		// tabela
		var divRegistro = $('div.divRegistros', '#frmSistemaTAA');		
		var tabela      = $('table', divRegistro );
		
		$('#frmSistemaTAA').css({'margin-top':'5px'});
		divRegistro.css({'height':'245px','padding-bottom':'2px'});

		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '250px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'left';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

		// centraliza a divRotina
		$('#divRotina').css({'width':'425px'});
		$('#divConteudo').css({'width':'400px', 'height':'auto'});
		$('#divRotina').centralizaRotinaH();
	
	} else {
	
		var flsisaux = $('#flsistaa', '#'+frmDados).val();

		rFlsistaa	= $('label[for="flsistaa"]', '#frmSistemaTAA');	
		cFlsistaa	= $('#flsistaa', '#frmSistemaTAA');
		
		rFlsistaa.addClass('rotulo').css({'width':'135px', 'display':'block'});
		cFlsistaa.addClass('campo').css({'width':'100px', 'display':'block'});		
		
		cFlsistaa.val( flsisaux );
		cFlsistaa.focus();

		cFlsistaa.unbind('keypress').bind('keypress', function(e) {
			// Se é a tecla ENTER, 
			if ( e.keyCode == 13 ) {
				btnContinuar();
				return false;
			} 
		});	
		
		// centraliza a divUsoGenerico
		$('#divRotina').css({'width':'325px'});
		$('#divConteudo').css({'width':'300px', 'height':'75px'});	
		$('#divRotina').centralizaRotinaH();
		
		$('fieldset', '#frmSistemaTAA').css({'padding':'3px'});
	}
	
	layoutPadrao();
	hideMsgAguardo();		
	bloqueiaFundo( $('#divRotina') );
	return false;
}

function formataOpcaoL() {

	rTprecolh	= $('label[for="tprecolh"]', '#frmOpcaoL');	
	cTprecolh	= $('#tprecolh', '#frmOpcaoL');
	
	rTprecolh.addClass('rotulo').css({'width':'235px'});
	cTprecolh.addClass('campo').css({'width':'100px'});		
	
	cTprecolh.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnConfirmar('manterRotina(\'GD\');','fechaOpcao();');
			return false;
		} 
	});	
	
	// centraliza a divUsoGenerico
	$('#divRotina').css({'width':'425px'});
	$('#divConteudo').css({'width':'400px', 'height':'75px'});	
	$('#divRotina').centralizaRotinaH();
	
	$('fieldset', '#frmOpcaoL').css({'padding':'3px'});
	
	layoutPadrao();
	hideMsgAguardo();		
	bloqueiaFundo( $('#divRotina') );
	cTprecolh.focus();
	return false;
}

function formataMonitorar() { 

	// label
	rMmtramax	= $('label[for="mmtramax"]', '#frmMonitorar');	
	rMminutos	= $('label[for="mminutos"]', '#frmMonitorar');	
	rMmtramax.addClass('rotulo').css({'width':'80px'});
	rMminutos.addClass('rotulo-linha').css({'width':'48px'});
	
	// campos
	cMmtramax	= $('#mmtramax', '#frmMonitorar');
	cMmtramax.addClass('campo inteiro').css({'width':'35px', 'display':'block'}).attr('maxlength','2');		

	var btOK		= $('#btnOK', '#frmMonitorar');
	
	cMmtramax.focus();

	btOK.unbind('click').bind('click', function() {
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cddopcao == 'M'  ) { buscaOpcao('monitorar'); }
		return false;
	});	
	
	cMmtramax.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btOK.click();
			return false;
		} 
	});	
	
	// tabela
	var divRegistro = $('div.divRegistros', '#frmMonitorar');		
	var tabela      = $('table', divRegistro );
	
	$('#frmMonitorar').css({'margin-top':'5px'});
	divRegistro.css({'height':'150px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '40px';
	arrayLargura[1] = '130px';
	arrayLargura[2] = '38px';
	arrayLargura[3] = '50px';
	arrayLargura[4] = '80px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	// centraliza a divRotina
	$('#divRotina').css({'width':'585px'});
	$('#divConteudo').css({'width':'560px'});
	$('#divRotina').centralizaRotinaH();
	
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	return false;
}

function formataDiretorio() {

	rNmdireto	= $('label[for="nmdireto"]', '#frmDiretorio');	
	cNmdireto	= $('#nmdireto', '#frmDiretorio');
	
	rNmdireto.addClass('rotulo').css({'width':'210px'});
	cNmdireto.addClass('campo').css({'width':'200px'}).attr('maxlength','29');		
	
	cNmdireto.focus();
	
	// centraliza a divUsoGenerico
	$('#divRotina').css({'width':'525px'});
	$('#divConteudo').css({'width':'500px', 'height':'75px'});	
	$('#divRotina').centralizaRotinaH();
	
	$('fieldset', '#frmDiretorio').css({'padding':'3px'});

	cNmdireto.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnContinuar();
			return false;
		} 
	});	
	
	layoutPadrao();
	hideMsgAguardo();		
	bloqueiaFundo( $('#divRotina') );
	return false;
}

//
function mostraOpcao( operacao ) {

	var mensagem = 'Aguarde...';

	fechaRotina( $('#divUsoGenerico') );
 	showMsgAguardo(mensagem);
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cash/opcao.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaOpcao( operacao );
			return false;
		}				
	});
	return false;
	
}

function buscaOpcao( operacao ) {
	
	var mensagem = '';

	// sensores
	var nrterfin = normalizaNumero( cNrterfin.val() );
	
	// configuração
	var nrtempor = $('#nrtempor', '#'+frmDados).val();
	var tpdispen = $('#tpdispen', '#'+frmDados).val();	
	var cdagenci = $('#cdagenci', '#'+frmDados).val();	
	var cdsitfin = $('#cdsitfin', '#'+frmDados).val();
	var dsfabtfn = $('#dsfabtfn', '#'+frmDados).val();
	var dsmodelo = $('#dsmodelo', '#'+frmDados).val();
	var dsdserie = $('#dsdserie', '#'+frmDados).val();
	var nmnarede = $('#nmnarede', '#'+frmDados).val();
	var nrdendip = $('#nrdendip', '#'+frmDados).val();
	var qtcasset = $('#qtcasset', '#'+frmDados).val();
	var dsininot = $('#dsininot', '#'+frmDados).val();
	var dsfimnot = $('#dsfimnot', '#'+frmDados).val();
	var dssaqnot = $('#dssaqnot', '#'+frmDados).val();
	var dstempor = $('#dstempor', '#'+frmDados).val();
	var dsdispen = $('#dsdispen', '#'+frmDados).val();
	var dssittfn = $('#dssittfn', '#'+frmDados).val();
	
	// operacao
	var dtlimite = $('#dtlimite', '#frmData').val();

	// depositos
	var dtinicio = $('#dtinicio', '#frmData').val();
	var dtdfinal = $('#dtdfinal', '#frmData').val();
	var cdsitenv = $('#cdsitenv', '#frmData').val();

	var mmtramax = normalizaNumero( $('#mmtramax', '#frmMonitorar').val() );
	
	var flgntcem = $('#flgntcem', '#'+frmDados).val();
	
  var dsterfin = $('#dsterfin', '#'+frmDados).val();
	
	switch( operacao ) {
		case 'monitorar': mensagem = 'Aguarde, analisando log...'; 	break;
		default			: mensagem = 'Aguarde, buscando ...'; 		break;
	}
	
	showMsgAguardo(mensagem);

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cash/busca_opcao.php', 
		data: {
			operacao: operacao,
			cddopcao: cddopcao,
			nrterfin: nrterfin,
			nrtempor: nrtempor,
            tpdispen: tpdispen,
            cdagenci: cdagenci,
            cdsitfin: cdsitfin,
            dsfabtfn: dsfabtfn,
            dsmodelo: dsmodelo,
            dsdserie: dsdserie,
            nmnarede: nmnarede,
            nrdendip: nrdendip,
            qtcasset: qtcasset,
            dsininot: dsininot,
            dsfimnot: dsfimnot,
            dssaqnot: dssaqnot,
			dstempor: dstempor,
			dsdispen: dsdispen,
			dssittfn: dssittfn,
			dtlimite: dtlimite,
			dtinicio: dtinicio,
			dtdfinal: dtdfinal,
			cdsitenv: cdsitenv,
			flsistaa: flsistaa,
			mmtramax: mmtramax,
			nmdireto: nmdireto,
			flgntcem: flgntcem,
      dsterfin: dsterfin,            
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"fechaOpcao();");
		},
		success: function(response) {

			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudo').html(response);
					exibeRotina( $('#divRotina') );
					
					switch( operacao ) {
						case 'sensores'			: 	formataSensores(); 		break;
						case 'configuracao'		: 	formataConfiguracao(); 	break;
						case 'operacao'			: 	formataOperacao(); 		break;
						case 'saldos'			: 	formataSaldos(); 		break;
						case 'lista_transacoes'	: 	formataTransacoes(); 	break;
						case 'depositos'		: 	formataDepositos(); 	break;
						case 'sistema_taa'		: 	formataSistemaTAA(); 	break;
						case 'opcaol'			: 	formataOpcaoL(); 		break;
						case 'monitorar'		: 	formataMonitorar();		break;
						case 'relatorio'		: 	formataRelatorio();		break;
						case 'diretorio'		: 	formataDiretorio();		break;
						case 'opcaoS'    		: 	formataOpcaoS();		break;
					}
					
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','fechaOpcao();');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','fechaOpcao();');
				}
			}
			
		}
	});
	return false;
}

function fechaOpcao() {

	//
	fechaRotina( $('#divRotina') );
	$('#divRotina').html('');
	
	//
	if ( cddopcao == 'A' || 
		 cddopcao == 'B' || 
		 cddopcao == 'I' || 
		 cddopcao == 'L' || 
		 cddopcao == 'M' || 
	     cddopcao == 'R' || 
	     cddopcao == 'S' ){ 
		estadoInicial(); 
	}
	
	//
	if ( cddopcao == 'L' ) {
		controlaLayout('');
	}
	
	return false;
}


// 
function mostraData( operacao ) {

	showMsgAguardo('Aguarde, buscando ...');
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cash/form_data.php', 
		data: {
			operacao: operacao,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			exibeRotina( $('#divUsoGenerico') );
			formataData( operacao );
			return false;
		}				
	});
	return false;
	
}

function mostraTransacao() {

	var cdsitfin = $('#cdsitfin', '#'+frmDados).val();
	var flgblsaq = $('#flgblsaq', '#'+frmDados).val();
	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cash/form_transacao.php', 
		data: {
			cdsitfin: cdsitfin,
			flgblsaq: flgblsaq,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			$('#divUsoGenerico').html(response);
			exibeRotina( $('#divUsoGenerico') );
			
			// centraliza a divUsoGenerico
			$('#divUsoGenerico').css({'width':'590px','left':'469px'});
			$('#divTransacao').css({'width':'560px', 'height':'50px', 'text-align':'center'});	
			$('#divUsoGenerico').centralizaRotinaH();
			
			return false;
		}				
	});
	return false;
	
}

// imprimir
function Gera_Log() {	

	var dtlimite = $('#dtlimite', '#frmData').val();
	var action 	 = UrlSite + 'telas/cash/imprimir_log.php';
	$('#dtlimite','#'+frmCab).val(dtlimite);
	fechaRotina( $('#divUsoGenerico') );
	$('#divUsoGenerico').html('');
	cTodosCabecalho.habilitaCampo();	
	carregaImpressaoAyllos(frmCab,action,"cTodosCabecalho.desabilitaCampo();");	
}

function Gera_Impressao() {	
	
	hideMsgAguardo();	
	var action = UrlSite + 'telas/cash/imprimir_dados.php';
	$('#nmarqpdf','#'+frmCab).val(nmarqpdf);	
	cTodosCabecalho.habilitaCampo();	
	carregaImpressaoAyllos(frmCab,action,"cTodosCabecalho.desabilitaCampo();fechaOpcao();");	
}

// botoes
function btnVoltar() {
	
	if ( cddopcao == 'R' && $('#dtmvtini', '#frmRelatorio').hasClass('campo') ) {
		formataRelatorio();
		fechaOpcao();
	} else if (cddopcao == 'C' && cNrterfin.hasClass('campoTelaSemBorda') ) {
		trocaBotao('Prosseguir');
		cNrterfin.val(''); 
		cDsterfin.val('');
		$('#frmCash').remove();
		fechaOpcao();
		controlaLayout('');
	} else { 
		fechaOpcao();
		estadoInicial();
	}	
	return false;
}

function btnContinuar() {
	
	if ( divError.css('display') == 'block' ) { return false; }
	
	if ( cCddopcao.hasClass('campo')  ) {  
		btnOK.click();	
	
	} else if ( ( cddopcao == 'A'|| cddopcao == 'B' || cddopcao == 'C' || cddopcao == 'L' || cddopcao == 'S') && (cNrterfin.hasClass('campo') || cNrterfin.hasClass('campoFocusIn') ) ) {
		controlaOperacao('BD');
		
	} else if ( cddopcao == 'A' && cNrterfin.hasClass('campoTelaSemBorda') ) { 
		manterRotina('VD');

	} else if ( cddopcao == 'S' && cNrterfin.hasClass('campoTelaSemBorda') ) { 
		btnConfirmar( "manterRotina('CASH_DADOS_SITE');", "fechaOpcao();");

	} else if ( cddopcao == 'B' && cNrterfin.hasClass('campoTelaSemBorda') ) { 
		// se for igual 0 abre a listagem
		if ( normalizaNumero( cNrterfin.val() ) == 0 ) {
			flsistaa = $('#flsistaa', '#frmSistemaTAA').val();
			buscaOpcao( 'sistema_taa' );
		} else {
			btnConfirmar('manterRotina(\'GD\');','fechaOpcao();');
		}

	} else if ( cddopcao == 'I') { 
		if (cNrterfin.hasClass('campoTelaSemBorda') && cDsterfin.hasClass('campoTelaSemBorda') ){
			manterRotina('VD');
		}else{
			controlaOperacao('BD');
		}
	} else if ( cddopcao == 'R' && $('#dtmvtini', '#frmRelatorio').hasClass('campo')  || ($('#dtmvtini', '#frmRelatorio').hasClass('campoFocusIn') ) ) {
	    
		if ($('#opcaorel', '#frmRelatorio').val() == 3) {
			opcaorel  = $('#opcaorel', '#frmRelatorio').val();
			nrterfin1 = $('#nrterfin1', '#frmRelatorio').val();
			dtmvtini  = $('#dtmvtini', '#frmRelatorio').val(); 
			dtmvtfim  = $('#dtmvtfim', '#frmRelatorio').val();
			cdsitenv  = $('#cdsitenv', '#frmRelatorio').val();
			var opcaoRelatorio = 'BD';
			
			var nao 	 = 'cddoptel=\'T\'; manterRotina(\'BD\');';
			showConfirmacao('Deseja salvar arquivo?','Confirma&ccedil;&atilde;o - Ayllos','cddoptel=\'A\'; buscaOpcao(\'diretorio\')',nao,'sim.gif','nao.gif');
		}else{
			opcaorel = $('#opcaorel', '#frmRelatorio').val(); 
			lgagetfn = $('#lgagetfn', '#frmRelatorio').val(); 
			cdagetfn = $('#cdagetfn', '#frmRelatorio').val(); 
			dtmvtini = $('#dtmvtini', '#frmRelatorio').val(); 
			dtmvtfim = $('#dtmvtfim', '#frmRelatorio').val(); 
			tiprelat = $('#tiprelat', '#frmRelatorio').val(); 
			tiprelat = tiprelat == 'yes' || tiprelat == 'no'  ? tiprelat : '';
			var opcaoRelatorio = ((opcaorel == 1) ? 'BD' : 'BDCM');
			
			var nao 	 = lgagetfn == 'yes' ? 'cddoptel=\'T\'; manterRotina(\'VP\');' : 'cddoptel=\'T\'; manterRotina(\''+opcaoRelatorio+'\');';
			showConfirmacao('Deseja salvar arquivo?','Confirma&ccedil;&atilde;o - Ayllos','cddoptel=\'A\'; manterRotina(\'VP\')',nao,'sim.gif','nao.gif');
		}
		
	} else if ( cddopcao == 'R' && $('#nmdireto', '#frmDiretorio').hasClass('campo') || ($('#nmdireto', '#frmDiretorio').hasClass('campoFocusIn')) ) {
		if (opcaorel == 3) {
			opreldep  = "Depositos";
			nmarqimp = $('#nmdireto', '#frmDiretorio').val();		
			var opcaoRelatorio = 'BD';
			manterRotina(opcaoRelatorio);
		}else{
			opreldep  = '';
			nmarqimp = $('#nmdireto', '#frmDiretorio').val();		
			var opcaoRelatorio = ((opcaorel == 1) ? 'BD' : 'BDCM');
			manterRotina(opcaoRelatorio);
		}
	}
	return false;
}

function btnConfirmar( sim, nao ) {
	showConfirmacao('Confirmar operação?','Confirma&ccedil;&atilde;o - Ayllos',sim,nao,'sim.gif','nao.gif');
	return false;
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html(''); 
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>&nbsp;');
    $('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;">'+botao+'</a>');
	
	return false;
}

function formataOpcaoS() {

	var legend = $('legend', '#frmOpcaoS');
    var blnChecked = $('#flganexo_pa', '#frmOpcaoS').prop("checked");

	// label
	rIdcidade       = $('label[for="idcidade"]',      '#frmOpcaoS');
	rNmterminal     = $('label[for="nmterminal"]',    '#frmOpcaoS');
    rFlganexo_pa    = $('label[for="flganexo_pa"]',   '#frmOpcaoS');
    rNmresage       = $('label[for="nmresage"]',      '#frmOpcaoS');
	rDslogradouro   = $('label[for="dslogradouro"]',  '#frmOpcaoS');
	rDscomplemento  = $('label[for="dscomplemento"]', '#frmOpcaoS');
	rNrendere       = $('label[for="nrendere"]',      '#frmOpcaoS');
	rNmbairro       = $('label[for="nmbairro"]',      '#frmOpcaoS');
	rNrcep          = $('label[for="nrcep"]',         '#frmOpcaoS');
	rNrlatitude     = $('label[for="nrlatitude"]',    '#frmOpcaoS');
    rNrlongitude    = $('label[for="nrlongitude"]',   '#frmOpcaoS');
	rDshorario      = $('label[for="dshorario"]',     '#frmOpcaoS');

	rIdcidade.addClass('rotulo').css({'width':'130px'});
    rNmterminal.addClass('rotulo').css({'width':'130px'});
    rFlganexo_pa.addClass('rotulo').css({'width':'130px'});
    rNmresage.addClass('rotulo').css({'width':'130px'});
	rDslogradouro.addClass('rotulo').css({'width':'130px'});	
	rDscomplemento.addClass('rotulo').css({'width':'130px'});	
	rNrendere.addClass('rotulo').css({'width':'130px'});
	rNmbairro.addClass('rotulo-linha').css({'width':'50px'});	
	rNrcep.addClass('rotulo').css({'width':'130px'});
	rNrlatitude.addClass('rotulo').css({'width':'130px'});
    rNrlongitude.addClass('rotulo').css({'width':'130px'});
	rDshorario.addClass('rotulo').css({'width':'130px'});

	// campos
    cIdcidade      = $('#idcidade',      '#frmOpcaoS');
	cNmterminal    = $('#nmterminal',    '#frmOpcaoS');
    cFlganexo_pa   = $('#flganexo_pa',   '#frmOpcaoS');
    cNmresage      = $('#nmresage',      '#frmOpcaoS');
	cDslogradouro  = $('#dslogradouro',  '#frmOpcaoS');
	cDscomplemento = $('#dscomplemento', '#frmOpcaoS');
	cNrendere      = $('#nrendere',      '#frmOpcaoS');
	cNmbairro      = $('#nmbairro',      '#frmOpcaoS');
	cNrcep         = $('#nrcep',         '#frmOpcaoS');
    cNrlatitude    = $('#nrlatitude',    '#frmOpcaoS');
    cNrlongitude   = $('#nrlongitude',   '#frmOpcaoS');
	cDshorario     = $('#dshorario',     '#frmOpcaoS');

    cIdcidade.addClass('campo pesquisa').css({'width':'50px'}).attr('maxlength','8').setMask('INTEGER','zzzzzzzz','','');
    cNmterminal.addClass('campo').css({'width':'240px'}).attr('maxlength','200').focus();
    cNmresage.addClass('campo').css({'width':'220px'}).desabilitaCampo();
    cDslogradouro.addClass('campo').css({'width':'240px'}).attr('maxlength','200');
	cDscomplemento.addClass('campo').css({'width':'240px'}).attr('maxlength','200');
	cNrendere.addClass('campo').css({'width':'50px'}).attr('maxlength','10').setMask('INTEGER','zzzzzzzzzz','','');
	cNmbairro.addClass('campo').css({'width':'134px'}).attr('maxlength','200');
	cNrcep.addClass('campo').css({'width':'240px'}).attr('maxlength','10').setMask('INTEGER','zz.zzz-zzz','','');
	cNrlatitude.addClass('campo').css({'width':'240px'});
    cNrlongitude.addClass('campo').css({'width':'240px'});
	cDshorario.addClass('campo').css({'width':'240px','height':'70px','float':'left','margin':'3px 0px 3px 3px'}).attr('maxlength','500');

    cNmterminal.unbind('keypress').bind('keypress', function(e) {
        // Se é a tecla ENTER, 
        if ( e.keyCode == 13 ) {
            // Se possuir o mesmo endereco do PA
            if (blnChecked) {
                cDshorario.focus();
            } else {
                cDslogradouro.focus();
            }
            return false;
        } 
    });
    
    cDslogradouro.unbind('keypress').bind('keypress', function(e) {
        // Se é a tecla ENTER, 
        if ( e.keyCode == 13 ) {
            cDscomplemento.focus();
            return false;
        } 
    });	
    
    cDscomplemento.unbind('keypress').bind('keypress', function(e) {
        // Se é a tecla ENTER, 
        if ( e.keyCode == 13 ) {
            cNrendere.focus();
            return false;
        } 
    });	
    
    cNrendere.unbind('keypress').bind('keypress', function(e) {
        // Se é a tecla ENTER, 
        if ( e.keyCode == 13 ) {
            cNmbairro.focus();
            return false;
        } 
    });	
    
    cNmbairro.unbind('keypress').bind('keypress', function(e) {
        // Se é a tecla ENTER, 
        if ( e.keyCode == 13 ) {
            cNrcep.focus();
            return false;
        } 
    });
    
    cNrcep.unbind('keypress').bind('keypress', function(e) {
        // Se é a tecla ENTER, 
        if ( e.keyCode == 13 ) {
           cIdcidade.focus();
           return false;
        } 
    });
    
    cIdcidade.unbind('keypress').bind('keypress', function(e) {
        // Se é a tecla ENTER, 
        if ( e.keyCode == 13 ) {
           cNrlatitude.focus();
           return false;
        } 
    });
    
    cNrlatitude.unbind('keypress').bind('keypress', function(e) {
        // Se é a tecla ENTER, 
        if ( e.keyCode == 13 && !e.shiftKey ) {
           cNrlongitude.focus();
           return false;
        } 
    });
    cNrlatitude.keyup(function () { 
        this.value = this.value.replace(/[^0-9.-]/g,''); // Deixa digitar somente hífen, ponto e número
        
        if ((this.value.match(/^\-$/g) || []).length == 0) //Remove a última ocorrência do hífen
            this.value = this.value.replace(/\-$/g,'');
        
        if ((this.value.match(/\./g) || []).length > 1) //Remove as ocorrências de ponto (.), deixando apenas a primeira
            this.value = this.value.replace(/\.$/g,'');
        
    });
    
    cNrlongitude.unbind('keypress').bind('keypress', function(e) {
        // Se é a tecla ENTER, 
        if ( e.keyCode == 13 && !e.shiftKey ) {
           cDshorario.focus();
           return false;
        } 
    });
    cNrlongitude.keyup(function () { 
        this.value = this.value.replace(/[^0-9.-]/g,''); // Deixa digitar somente hífen, ponto e número
        
        if ((this.value.match(/^\-$/g) || []).length == 0) //Remove a última ocorrência do hífen
            this.value = this.value.replace(/\-$/g,'');
        
        if ((this.value.match(/\./g) || []).length > 1) //Remove as ocorrências de ponto (.), deixando apenas a primeira
            this.value = this.value.replace(/\.$/g,'');
        
    });
	
	cDshorario.unbind('keypress').bind('keypress', function(e) {
	    // Se é a tecla ENTER, 
		if ( e.keyCode == 13 && !e.shiftKey ) {
		      btnContinuar();
			return false;
		} 
	});
    cDshorario.bind('input propertychange', function() {
        var maxLength = $(this).attr('maxlength');
        if ($(this).val().length > maxLength) {
            $(this).val($(this).val().substring(0, maxLength));
        }
    });

	// centraliza a divRotina
	$('#divRotina').css({'width':'425px'});
	$('#divConteudo').css({'width':'400px'});
	$('#divRotina').centralizaRotinaH();
	
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function carregaEnderecoPA() {
    var blnChecked = $('#flganexo_pa', '#frmOpcaoS').prop("checked");
    if (blnChecked) {
        $('#dscidade',      '#frmOpcaoS').val($('#dscidade',      '#frmOpcaoS').attr('pa_dscidade'));
        $('#idcidade',      '#frmOpcaoS').val($('#idcidade',      '#frmOpcaoS').attr('pa_idcidade')).desabilitaCampo();
        $('#dslogradouro',  '#frmOpcaoS').val($('#dslogradouro',  '#frmOpcaoS').attr('pa_dsendcop')).desabilitaCampo();
        $('#dscomplemento', '#frmOpcaoS').val($('#dscomplemento', '#frmOpcaoS').attr('pa_dscomple')).desabilitaCampo();
        $('#nmbairro',      '#frmOpcaoS').val($('#nmbairro',      '#frmOpcaoS').attr('pa_nmbairro')).desabilitaCampo();
        $('#nrcep',         '#frmOpcaoS').val($('#nrcep',         '#frmOpcaoS').attr('pa_nrcepend')).desabilitaCampo();
        $('#nrendere',      '#frmOpcaoS').val($('#nrendere',      '#frmOpcaoS').attr('pa_nrendere')).desabilitaCampo();
        $('#nrlatitude',    '#frmOpcaoS').val($('#nrlatitude',    '#frmOpcaoS').attr('pa_nrlatitude')).desabilitaCampo();
        $('#nrlongitude',   '#frmOpcaoS').val($('#nrlongitude',   '#frmOpcaoS').attr('pa_nrlongitude')).desabilitaCampo();
    } else {
        $('#dscidade',      '#frmOpcaoS').val($('#dscidade',      '#frmOpcaoS').attr('taa_dscidade'));
        $('#idcidade',      '#frmOpcaoS').val($('#idcidade',      '#frmOpcaoS').attr('taa_idcidade')).habilitaCampo();
        $('#dslogradouro',  '#frmOpcaoS').val($('#dslogradouro',  '#frmOpcaoS').attr('taa_dsendcop')).habilitaCampo();
        $('#dscomplemento', '#frmOpcaoS').val($('#dscomplemento', '#frmOpcaoS').attr('taa_dscomple')).habilitaCampo();
        $('#nmbairro',      '#frmOpcaoS').val($('#nmbairro',      '#frmOpcaoS').attr('taa_nmbairro')).habilitaCampo();
        $('#nrcep',         '#frmOpcaoS').val($('#nrcep',         '#frmOpcaoS').attr('taa_nrcepend')).habilitaCampo();
        $('#nrendere',      '#frmOpcaoS').val($('#nrendere',      '#frmOpcaoS').attr('taa_nrendere')).habilitaCampo();
        $('#nrlatitude',    '#frmOpcaoS').val($('#nrlatitude',    '#frmOpcaoS').attr('taa_nrlatitude')).habilitaCampo();
        $('#nrlongitude',   '#frmOpcaoS').val($('#nrlongitude',   '#frmOpcaoS').attr('taa_nrlongitude')).habilitaCampo();
        $('#dslogradouro',  '#frmOpcaoS').focus();
    }
    $('#dscidade', '#frmOpcaoS').css({'width':'170px'}).desabilitaCampo();
    controlaPesquisas();
}
