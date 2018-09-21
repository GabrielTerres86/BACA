/*!
 * FONTE        : dependentes.js
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 24/05/2010 
 * OBJETIVO     : Biblioteca de funções na rotina DEPENDENTES da tela de CONTAS
 *
 * ALTERACOES   : 02/09/2015 - Reformulacao Cadastral (Gabriel-RKAM)
 */

var nrdrowid  = ''; 
var operacao  = '';
var cddopcao  = '';
var nomeFormDependentes  = 'frmDependentes';
 
function controlaOperacaoDependentes(operacao) {

	if ( (operacao == 'TA') && (flgAlterar   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TC') && (flgConsultar != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de consulta.'               ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TE') && (flgExcluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de exclus&atilde;o.'        ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TI') && (flgIncluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de incluis&atilde;o.'       ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	
	// Se a operação necessita filtrar somente um registro, então filtro abaixo
	// Para isso verifico a linha que está selecionado e pego o valor do INPUT HIDDEN desta linha	
	if ( in_array(operacao,['TA','TE','CF']) ) {
		nrdrowid = '';
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrdrowid = $('input', $(this) ).val();
			}
		});
				
		if ( nrdrowid == '' ) { return false; }		
	}
		
	var mensagem = '';
	
	switch (operacao) {			
		case 'TA' :	
			mensagem = 'abrindo altera&ccedil;&atilde;o...';
			cddopcao = 'A';
			break;
		case 'CF' :	
			mensagem = 'abrindo consulta...';
			cddopcao = 'C';
			break;
		case 'TI' : 
			mensagem = 'abrindo inclus&atilde;o...';
			nrdrowid = '';
			cddopcao = 'I';
			break;	
		case 'TE' : 
			mensagem = 'processando exclus&atilde;o...';
			cddopcao = 'E';
			break;			
		case 'AT' : 
			showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacaoDependentes()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
		case 'IT' : 
			showConfirmacao('Deseja cancelar inclus&atilde;o?'        ,'Confirma&ccedil;&atilde;o - Aimaro','controlaOperacaoDependentes()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
		case 'VE' :
			showConfirmacao('Deseja confirmar exclus&atilde;o?'        ,'Confirma&ccedil;&atilde;o - Aimaro','manterRotinaDependentes(\'VE\')','controlaOperacaoDependentes(\'\')','sim.gif','nao.gif');
			return false;
			break;		
		case 'AV' : manterRotinaDependentes(operacao);return false;break;	
		case 'IV' : manterRotinaDependentes(operacao);return false;break;
		case 'VA' : manterRotinaDependentes(operacao);return false;break;		
		case 'VI' : manterRotinaDependentes(operacao);return false;break;
		default   : 
			acessaOpcaoAbaDados(6,2,'@');
			return false;
	}
	showMsgAguardo('Aguarde, ' + mensagem);	
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/dependentes/principal.php', 
		data: {
			nrdconta: nrdconta,	idseqttl: idseqttl,
			operacao: operacao,	nrdrowid: nrdrowid,
			cddopcao: cddopcao,	redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
			} else {
				eval( response );
				controlaFocoDependentes( operacao );
			}
			return false;
		}				
	});			
}

function manterRotinaDependentes( operacao ) {
	hideMsgAguardo();	
	var mensagem = '';
	switch (operacao) {	
		case 'AV': mensagem = 'validando altera&ccedil;&atilde;o'; break;
		case 'IV': mensagem = 'validando inclus&atilde;o'; break;				
		case 'EV': mensagem = 'validando exclus&atilde;o'; break;								
		case 'VA': mensagem = 'alterando'; break;
		case 'VI': mensagem = 'incluindo'; break;
		case 'VE': mensagem = 'excluindo'; break;
		default: controlaOperacaoDependentes(); return false; break;
	}
	showMsgAguardo('Aguarde, ' + mensagem + '...');
	
	nmdepend = $('#nmdepend','#'+nomeFormDependentes).val();
	dtnascto = $('#dtnascto','#'+nomeFormDependentes).val();
	cdtipdep = $('#cdtipdep','#'+nomeFormDependentes).val();
	nrdrowid = $('#nrdrowid','#'+nomeFormDependentes).val();
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/dependentes/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, nmdepend: nmdepend, 
			dtnascto: dtnascto, cdtipdep: cdtipdep,	nrdrowid: nrdrowid, 
			operacao: operacao, redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
			}
		}				
	});
}

function controlaLayoutDependentes(operacao) {		
	
	altura  = ( in_array(operacao,['AT','IT','FI','FA','FE','SC','']) ) ? '205px' : '117px';
	largura = ( in_array(operacao,['AT','IT','FI','FA','FE','SC','']) ) ? '550px' : '390px';
	divRotina.css('width',largura);	
	
	if ( in_array(operacao,['TA','TE','TI']) ) {
		$('#divConteudoOpcao').css('height','125px');
	}	
	
	// Operação consultando
	if ( in_array(operacao,['AT','IT','FI','FA','FE','SC','']) ) {	

		var divRegistro = $('div.divRegistros');		
		var tabela      = $('table', divRegistro );
		
		divRegistro.css('height','60px');
		
		var ordemInicial = new Array();
		ordemInicial = [[0,0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '220px';
		arrayLargura[1] = '110px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'left';
						
		var metodoTabela = ( operacao != 'SC' ) ? 'controlaOperacaoDependentes(\'TA\')' : 'controlaOperacaoDependentes(\'CF\')' ;
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	// Operação Alterando/Incluindo
	} else {	
		
		var rRotulos   	= $('label','#'+nomeFormDependentes);
		var formulario  = $('#'+nomeFormDependentes);
		var cNome     	= $('#nmdepend','#'+nomeFormDependentes);		
		var cNascimento	= $('#dtnascto','#'+nomeFormDependentes);		
		var cCodigo	    = $('#cdtipdep','#'+nomeFormDependentes);				
		var cDescricao 	= $('#dstipdep','#'+nomeFormDependentes);				
		
		formulario.css('padding-top','5px');
		rRotulos.addClass('rotulo').css('width','100px');
		cNome.addClass('alphanum').attr('maxlength','40').css('width','255px');
		cNascimento.addClass('data').css('width','80px');
		cCodigo.addClass('codigo pesquisa');
		cDescricao.addClass('descricao').css('width','200px');
		
		if ( operacao == 'CF' ){
			cNome.desabilitaCampo();
			cNascimento.desabilitaCampo();
			cCodigo.desabilitaCampo();
		// Se for EXCLUSÃO
		} else if ( operacao == 'TE' ) {					
			cNome.desabilitaCampo();
			cNascimento.desabilitaCampo();
			cCodigo.desabilitaCampo();
			
		// Caso INCLUSÃO OU ALTERAÇÃO
		} else if ( (operacao == 'TI') || (operacao == 'TA') ) {			
			cNome.desabilitaCampo();
			cNascimento.habilitaCampo();
			cCodigo.habilitaCampo();		
			
			// Somente INCLUSÃO
			if (operacao == 'TI') {	
				cNome.habilitaCampo();
				$('#'+nomeFormDependentes).limpaFormulario();
			}			
		}
		
		cCodigo.unbind('focusin').bind('focusin', function() {
			controlaPesquisasDependentes(); 
		});

		cCodigo.unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});		
		
	}
	
	
	layoutPadrao();
	controlaPesquisasDependentes();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	highlightObjFocus($('#divConteudoOpcao'));
	controlaFocoEnter("divConteudoOpcao");
	divRotina.centralizaRotinaH();
	controlaFocoDependentes(operacao);
	return false;	
}

function controlaFocoDependentes(operacao) {
	if (in_array(operacao,['AT','IT','FA','FI','FE',''])) {
		$('#btAlterar','#divBotoes').focus();
	} else if (operacao == 'TA') {
		$('#dtnascto','#'+nomeFormDependentes).focus();
	} else if (operacao == 'TI') {
		$('#nmdepend','#'+nomeFormDependentes).focus();
	}
	return false;
}

function controlaPesquisasDependentes() {
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas;
	
	// Inicializa a BO padrão
	bo = 'b1wgen0059.p';
	
	// CONTROLE DAS PESQUISAS
	
	// Atribui a classe lupa para os links de desabilita todos
	$('a','#'+nomeFormDependentes).addClass('lupa').css('cursor','auto');
	
	// Percorrendo todos os links
	$('a','#'+nomeFormDependentes).each( function() {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) { $(this).css('cursor','pointer'); }
		
		$(this).click( function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');
				
				// Tipo Dependente
				if ( campoAnterior == 'cdtipdep' ) {
					procedure	= 'busca_tipo_dependentes';
					titulo      = 'Tipo Dependente';
					qtReg		= '30';
					filtrosPesq	= 'Cód. Tipo;cdtipdep;30px;S;0|Tipo Dependente;dstipdep;200px;S;';
					colunas 	= 'Código;cdtipdep;20%;right|Tipo Dependente;dstipdep;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
					return false;
				}
			}
			return false;
		});
	});	
	
	// CONTROLE DAS BUSCA DESCRIÇÕES
	// Tipo Dependente
	$('#cdtipdep','#'+nomeFormDependentes).unbind('change').bind('change', function() {		
		procedure   = 'busca_tipo_dependentes';
		titulo      = 'Tipo Dependente';
		filtrosDesc = '';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dstipdep',$(this).val(),'dstipdep',filtrosDesc,nomeFormDependentes);
		return false;
	});	
	
	return false;
}