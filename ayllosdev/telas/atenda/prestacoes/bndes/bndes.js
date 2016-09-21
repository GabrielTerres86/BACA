/*!
 * FONTE        : bndes.js
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : 24/05/2013
 * OBJETIVO     : Biblioteca de funções na rotina Prestações - bndes da tela ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
  */	
 
 var glbDsdprodu, glbNrctremp, glbVlropepr,	glbVlparepr, glbVlsdeved, glbQtdmesca, glbPerparce,	glbDtinictr, glbDtlibera, glbQtparctr, glbDtpripag, glbDtpricar, glbPercaren, arrBndes; 
 
 
 arrBndes = new Array();
 
function controlaOperacao() {
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde carregando dados do BNDES ...");
	
	// Executa script de atraves de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',   
		url: UrlSite + 'telas/atenda/prestacoes/bndes/principal.php', 
		data: {
			nrdconta: nrdconta,	
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
					hideMsgAguardo();
					$('#divConteudoOpcao').html(response);
										
				} else {
				eval( response );
			}
			return false;
		}			
	});
	
}

function controlaLayout() {
	
	altura  = '205px';
	largura = '302px';

	// Configurações da tabela
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
		
	divRegistro.css({'height':'150px','padding-bottom':'2px'});
		
	var ordemInicial = new Array();
	ordemInicial = [[0,2]];
		
	var arrayLargura = new Array();
	arrayLargura[0] = '75px';
	arrayLargura[1] = '65px';
	
	var arrayAlinha = new Array();
					
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );		
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		glbNrctremp = $(this).find('#nrctremp > #tbnrctremp').val() ;
	});
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).dblclick( function() {
		glbNrctremp = $(this).find('#nrctremp > #tbnrctremp').val() ;
		btConsultar()
	});
		
	$('table > tbody > tr:eq(0)', divRegistro).click();
	
	divRotina.css('width',largura);	
	$('#divConteudoOpcao').css({'height':altura,'width':largura});

	layoutPadrao();	
	
	$('input','#divRegistros').trigger('blur');	
	
	hideMsgAguardo();
	removeOpacidade('divRegistros');
	divRotina.centralizaRotinaH();
	bloqueiaFundo(divRotina);	
	
}

function formataTela() {
	
	nomeForm = 'frmDadosBndes';		
	altura   = '235px';
	largura  = '500px';
	
	$('input', '#frmDadosBndes').limpaFormulario();
	$('#divConteudoOpcao').css('display','none');
	
	$('input, select','#frmDadosBndes').removeClass('campoErro');
	
     $.each(arrBndes, function(i, object){
	
		 if ( object.nrctremp == glbNrctremp ) {

			 $('#nrctremp','#frmDadosBndes').val( object.nrctremp );
			 $('#dsdprodu','#frmDadosBndes').val( object.dsdprodu );
			 $('#vlropepr','#frmDadosBndes').val( object.vlropepr );
			 $('#vlparepr','#frmDadosBndes').val( object.vlparepr );
			 $('#vlsdeved','#frmDadosBndes').val( object.vlsdeved );
			 $('#qtdmesca','#frmDadosBndes').val( object.qtdmesca );
			 $('#perparce','#frmDadosBndes').val( object.perparce );
			 $('#dtinictr','#frmDadosBndes').val( object.dtinictr );
			 $('#dtlibera','#frmDadosBndes').val( object.dtlibera );
			 $('#qtparctr','#frmDadosBndes').val( object.qtparctr );
			 $('#dtpripag','#frmDadosBndes').val( object.dtpripag );
			 $('#dtpricar','#frmDadosBndes').val( object.dtpricar );
			 $('#percaren','#frmDadosBndes').val( object.percaren );
		
		 }
		
	 }); 
	
	var rRotulos     = $('label[for="dsdprodu"],label[for="nrctremp"],label[for="qtdmesca"],label[for="percaren"],label[for="qtparctr"],label[for="perparce"]','#'+nomeForm);
	var cTodos       = $('select,input','#'+nomeForm);	
	
	var rRotuloLinha = $('label[for="vlropepr"],label[for="vlparepr"],label[for="vlsdeved"],label[for="dtinictr"],label[for="dtlibera"],label[for="dtpricar"]','#'+nomeForm); 
	var cMoeda      = $('#vlropepr,#vlparepr,#vlsdeved','#'+nomeForm);
	var cContrato   = $('#nrctremp','#'+nomeForm);
	var rDtpripag   = $('label[for="dtpripag"]','#'+nomeForm);
	var cDtpripag   = $('#dtpripag','#'+nomeForm);
	
	cContrato.setMask('INTEGER','zzz.zzz.zz9','.','');
	
	cMoeda.addClass('moeda');	
	cTodos.addClass('campo').css('width','131px');
	
	rRotulos.addClass('rotulo').css('width','85px');	
	rDtpripag.addClass('rotulo-linha').css({'width':'305px'});	
	rRotuloLinha.addClass('rotulo-linha').css('width','85px');
	
	cTodos.desabilitaCampo();

	$('input','#'+nomeForm).trigger('blur');
		
	divRotina.css('width',largura);	
	$('#divConteudoOpcao').css({'height':altura,'width':largura});

	layoutPadrao();
	hideMsgAguardo();
	removeOpacidade('divConteudoOpcao');
	divRotina.centralizaRotinaH();
	bloqueiaFundo(divRotina);	
	
}

function btConsultar() {
	
	// Executa script de atraves de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',   
		url: UrlSite + 'telas/atenda/prestacoes/bndes/form_bndes.php', 
		data: {
			nrdconta: nrdconta,	
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
					hideMsgAguardo();
					$('#divConteudoOpcao').html(response);
					formataTela();										
				} else {
				eval( response );
			}
			return false;
		}			
	});			
	
}

function criaObjetoBndes(dsdprodu, nrctremp, vlropepr, vlparepr, vlsdeved, qtdmesca, perparce, dtinictr, dtlibera, qtparctr, dtpripag, dtpricar, percaren){
		
	var objBndes = new bndes(dsdprodu, nrctremp, vlropepr, vlparepr, vlsdeved, qtdmesca, perparce, dtinictr, dtlibera, qtparctr, dtpripag, dtpricar, percaren);
	arrBndes.push( objBndes );
	
}

function bndes(dsdprodu, nrctremp, vlropepr, vlparepr, vlsdeved, qtdmesca, perparce, dtinictr, dtlibera, qtparctr, dtpripag, dtpricar, percaren ) {

	this.dsdprodu=dsdprodu;
	this.nrctremp=nrctremp;
	this.vlropepr=vlropepr;
	this.vlparepr=vlparepr;
	this.vlsdeved=vlsdeved;
	this.qtdmesca=qtdmesca;
	this.perparce=perparce;
	this.dtinictr=dtinictr;
	this.dtlibera=dtlibera;
	this.qtparctr=qtparctr;
	this.dtpripag=dtpripag;
	this.dtpricar=dtpricar;
	this.percaren=percaren;
}

	