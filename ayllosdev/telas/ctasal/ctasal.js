/*!
   FONTE        : pesqdp.js
   CRIAÇÃO      : Gabriel Capoia (DB1)
   DATA CRIAÇÃO : 11/01/2013
   OBJETIVO     : Biblioteca de funções da tela PESQDP
   --------------
   ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos).
   --------------
  				  23/04/2015 - Ajustando a tela CTASAL
                               Projeto 158 - Servico Folha de Pagto
                               (Andre Santos - SUPERO)
  
                  23/02/2016 - Inclusao da function retirarAcentuacao para
                               validacao do nome dos funcionario (Jean Michel).
  
  				  27/07/2016 - Adicionar funcao validaDados() para validar se nome do funcionario esta em branco ou nao (Lucas Ranghetti #457281)
				  
				  07/08/2017 - Ajuste realizado para gerar numero de conta automaticamente na
							   inclusao, conforme solicitado no chamado 689996. (Kelvin)
  
				  08/02/2018 - Ajuste para caracteres especiais não gerarem problemas. (SD 845660 - Kelvin).		
					
				  05/04/2018 - Ajuste na tela ctasal para que caso o operador tente inserir o nome do funcionario
							   com apenas um caractere especial, não permita cadastrar. (SD 866541 - Kelvin)
							   
				  14/05/2018 - Incluido novo campo "Tipo de Conta" (tpctatrf) na tela CTASAL
                               Projeto 479-Catalogo de Servicos SPB (Mateus Z - Mouts)
  
				  20/08/2018 - Removendo validacao do titular do javascript e colocando no progress. (SCTASK002723 - Kelvin)
  
 */

 var nometela;

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmCheque   	= 'frmCheque';
var frmDados    	= 'frmDados';
var divTabela;
var bo			    = 'b1wgen0059.p';
var dtmvtolt;


var cTodosCabecalho, cddopcao, nrdconta, cdagenca, cdempres, nmfuncio, cdagetrf, cdbantrf, nrdigtrf,
	nrctatrf, nrcpfcgc, rCddopcao, rNrdconta, cCddopcao, cNrdconta, btnOK,
	rNmfuncio, rNrcpfcgc, rCdagenca, rCdempres, rCdbantrf, rNmresage, rNmresemp, rDsbantrf, rNrctatrf,
	rNrdigtrf, rDtadmiss, rDtcantrf, rCdsitcta, cNmfuncio, cNrcpfcgc, cCdagenca, cCdempres, cCdbantrf,
	cNmresage, cNmresemp, cDsbantrf, cNrctatrf, cNrdigtrf, cDtadmiss, cDtcantrf, cCdsitcta;

$(document).ready(function() {
	divTabela		= $('#divTabela');
	estadoInicial();
	nrregist = 20;
    
	return false;

});

function carregaDados(){

	cddopcao = $('#cddopcao','#'+frmCab).val();
	nrdconta = $('#nrdconta','#'+frmCab).val();

	cdagenca = $('#cdagenca','#frmDados').val();
	cdempres = $('#cdempres','#frmDados').val();
	nmfuncio = $('#nmfuncio','#frmDados').val();
	cdagetrf = $('#cdagetrf','#frmDados').val();
	cdbantrf = $('#cdbantrf','#frmDados').val();
	nrdigtrf = $('#nrdigtrf','#frmDados').val();
	nrctatrf = $('#nrctatrf','#frmDados').val();
	nrcpfcgc = $('#nrcpfcgc','#frmDados').val();
	tpctatrf = $('#tpctatrf','#frmDados').val();

	nrdconta = normalizaNumero( nrdconta );
	nrcpfcgc = normalizaNumero( nrcpfcgc );
	nrctatrf = normalizaNumero( nrctatrf );

	return false;
}

// inicio
function estadoInicial() {

	$('#frmCab').fadeTo(0,0.1);

	$('#divTabela').html('');
	$('#divDados').html('');

	trocaBotao('Prosseguir','btnContinuar()');
	formataCabecalho();
	
	

	removeOpacidade('frmCab');

	return false;

}

// formata
function formataCabecalho() {

	cTodosCabecalho	= $('input[type="text"],select','#'+frmCab);

	btnOK			= $('#btnOK','#'+frmCab);
	btnProsseguir	= $('#btSalvar','#divBotoes');

	//Cabecalho
	rCddopcao		= $('label[for="cddopcao"]','#'+frmCab);
	rNrdconta		= $('label[for="nrdconta"]','#'+frmCab);

	cCddopcao		= $('#cddopcao','#'+frmCab);
	cNrdconta		= $('#nrdconta','#'+frmCab);

	rCddopcao.addClass('rotulo').css({'width':'100px'});
	rNrdconta.css({'width':'100px'});

	cCddopcao.css({'width':'150px'});
	cNrdconta.css({'width':'82px'}).addClass('conta');

	cTodosCabecalho.habilitaCampo();
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cNrdconta.focus();
		}
	});

	
	cCddopcao.unbind('change').bind('change', function(){
		if(cCddopcao.val() == "I"){			
		  	cNrdconta.desabilitaCampo();			
			cNrdconta.val("");
		}else{
			cNrdconta.val("");
			cNrdconta.habilitaCampo();			
		}		
	});
	
	highlightObjFocus( $('#frmCab') );

	layoutPadrao();

	controlaPesquisas();

	limpaCampos();

	cCddopcao.val('C');
	cCddopcao.focus();
	
	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if ( divError.css('display')     == 'block' ) { return false; }
			if ( !cCddopcao.hasClass('campo') ) { return false; }

			buscaDados();

			return false;
		}
	});

	btnOK.unbind('click').bind('click', function() {

		if ( divError.css('display')     == 'block' ) { return false; }
		if ( !cCddopcao.hasClass('campo') ) { return false; }

		buscaDados();

		return false;

	});	

	return false;
}

function controlaOperacao(){

	controlaLayout();

	switch (cCddopcao.val()) {
		case "C": break;
		case "A": break;
		case "S": break;
		case "X": break;/*manterRotina('valida'); break;*/
		case "E": break;/*manterRotina('valida'); break;*/
		case "I": break;
	}

	return false;
}

function controlaLayout() {

	switch (cCddopcao.val()) {
		case "C":
			btnProsseguir.hide();
			cTodosDados.desabilitaCampo();
			break;
		case "A":
			cTodosDados.desabilitaCampo();
			cNmfuncio.habilitaCampo();
			cCdagenca.habilitaCampo();
			cCdempres.habilitaCampo();
			break;
		case "S":
			cTodosDados.desabilitaCampo();
			cCdbantrf.habilitaCampo();
			cCdagetrf.habilitaCampo();
			cNrctatrf.habilitaCampo();
			cNrdigtrf.habilitaCampo();
			cTpctatrf.habilitaCampo();
			break;
		case "X":
			cTodosDados.desabilitaCampo();
			break;
		case "E":
			cTodosDados.desabilitaCampo();
			break;
		case "I":
			cTodosDados.habilitaCampo();
			cNmresage.desabilitaCampo();
			cNmresemp.desabilitaCampo();
			cDsbantrf.desabilitaCampo();
			cDtadmiss.desabilitaCampo();
			cDtcantrf.desabilitaCampo();
			cCdsitcta.desabilitaCampo();
			$('#frmDados').limpaFormulario();
			break;
	}
	
	// Sempre que entrar na tela e o valor do campo Tipo de Conta for 3 (conta de pagamento) ira desabilitar e limpar o campo Agencia
	if (cTpctatrf.val() == 3) {
		cCdagetrf.desabilitaCampo();
		cCdagetrf.val('');
	}

	cTpctatrf.unbind('change').bind('change', function(e) {
		if ($(this).val() == 3) {
			cCdagetrf.val('');
			cDsagetrf.val('');
			cCdagetrf.desabilitaCampo();
		} else {
			cCdagetrf.habilitaCampo();
		}
	});

	return false;
}

// imprimir
function Gera_Impressao(nrdconrt) {

	var action = UrlSite + 'telas/ctasal/imprimir_dados.php';
	var sidlogin = $("#sidlogin", "#frmMenu").val();
	var nrdconta;

	if (cCddopcao.val() == 'I') 
		 nrdconta = nrdconrt;
	else 
		nrdconta = cNrdconta.val();
		
	
	$('#frmDados').append('<input type="hidden" id="nrdconta" name="nrdconta" value="' + nrdconta + '" />')
				  .append('<input type="hidden" id="flgsolic" name="flgsolic" value="' + controlaFlag() + '" />')
				  .append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + sidlogin + '" />');

    cTodosDados.habilitaCampo();

	carregaImpressaoAyllos("frmDados",action,"");

	controlaLayout();

	return false;

}

function controlaFlag(){

	if (cCddopcao.val() == 'I' || cCddopcao.val() == 'S' ||
    	cCddopcao.val() == 'X' ){
		return 'yes';
	}

	return 'no';
}

// botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function btnContinuar() {
	var strOpcao = $("#cddopcao").val();

	if(strOpcao == 'C'){
		btnOK.click();
	}else{

		if ( divError.css('display') == 'block' ) { return false; }

		if (cCddopcao.hasClass('campo') ) {
			btnOK.click();

		} else{
			manterRotina('valida');
		}
		return false;
	}

}

function trocaBotao(botao,funcao) {

	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');

	if (botao != '') {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="' + funcao + '; return false;" >' + botao + '</a>');
	}

	return false;
}

function buscaDados() {

	showMsgAguardo('Aguarde, buscando dados...');

	carregaDados();

	$.ajax({
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/'+nometela+'/busca_dados.php',
		data    :
				{ cddopcao	: cddopcao,
				  nrdconta  : nrdconta,
				  redirect: 'script_ajax'

				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
				},
		success : function(response) {
					hideMsgAguardo();

					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divDados').html(response);
							formataDados();
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
						}
					}

				}
	});
}

function formataDados(){

	cTodosCabecalho.removeClass('campoErro');
	cTodosCabecalho.desabilitaCampo();

	cTodosDados = $('input[type="text"],select','#frmDados');

	rCdagechq = $('label[for="cdagechq"]','#frmDados');
	cCdagechq = $('#cdagechq','#frmDados');

	cTodosDados.habilitaCampo();

	layoutPadrao();

	rNmfuncio = $('label[for="nmfuncio"]','#frmDados');
	rNrcpfcgc = $('label[for="nrcpfcgc"]','#frmDados');
	rCdagenca = $('label[for="cdagenca"]','#frmDados');
	rCdempres = $('label[for="cdempres"]','#frmDados');
	rCdbantrf = $('label[for="cdbantrf"]','#frmDados');
	rNmresage = $('label[for="nmresage"]','#frmDados');
	rNmresemp = $('label[for="nmresemp"]','#frmDados');
	rDsbantrf = $('label[for="dsbantrf"]','#frmDados');
	rNrctatrf = $('label[for="nrctatrf"]','#frmDados');
	rNrdigtrf = $('label[for="nrdigtrf"]','#frmDados');
	rDtadmiss = $('label[for="dtadmiss"]','#frmDados');
	rDtcantrf = $('label[for="dtcantrf"]','#frmDados');
	rCdsitcta = $('label[for="cdsitcta"]','#frmDados');
	rCdagetrf = $('label[for="cdagetrf"]','#frmDados');
	rTpctatrf = $('label[for="tpctatrf"]','#frmDados');

	cNmfuncio = $('#nmfuncio','#frmDados').addClass('alpha');
	cNrcpfcgc = $('#nrcpfcgc','#frmDados');
	cCdagenca = $('#cdagenca','#frmDados');
	cCdempres = $('#cdempres','#frmDados');
	cCdbantrf = $('#cdbantrf','#frmDados');
	cNmresage = $('#nmresage','#frmDados');
	cNmresemp = $('#nmresemp','#frmDados');
	cDsbantrf = $('#dsbantrf','#frmDados');
	cNrctatrf = $('#nrctatrf','#frmDados');
	cNrdigtrf = $('#nrdigtrf','#frmDados');
	cDtadmiss = $('#dtadmiss','#frmDados');
	cDtcantrf = $('#dtcantrf','#frmDados');
	cCdsitcta = $('#cdsitcta','#frmDados');
	cCdagetrf = $('#cdagetrf','#frmDados');
	cDsagetrf = $('#dsagetrf','#frmDados');
	cTpctatrf = $('#tpctatrf','#frmDados');

	rNmfuncio.css({'width':'100px'}).addClass('rotulo');
	rNrcpfcgc.css({'width':'100px'}).addClass('rotulo');
	rCdagenca.css({'width':'60px'});

	rCdempres.css({'width':'262px'}).addClass('rotulo');
	rCdbantrf.css({'width':'262px'}).addClass('rotulo');
	rNmresage.addClass('rotulo-linha');
	rNmresemp.addClass('rotulo-linha');
	rDsbantrf.addClass('rotulo-linha');
	rNrctatrf.css({'width':'262px'}).addClass('rotulo');
	rCdagetrf.css({'width':'262px'}).addClass('rotulo');
	rNrdigtrf.addClass('rotulo-linha');
	rDtadmiss.css({'width':'90px'});
	rDtcantrf.addClass('rotulo-linha');
	rCdsitcta.addClass('rotulo-linha');
	rTpctatrf.css({'width':'262px'}).addClass('rotulo');

	cNmfuncio.css({'width':'380px'});
	cNrcpfcgc.css({'width':'100px'});
	cCdagenca.css({'width':'45px' });
	cCdempres.css({'width':'45px' });
	cCdbantrf.css({'width':'45px' });
	cCdagetrf.css({'width':'45px' });
	cNmresage.css({'width':'150px'});
	cNmresemp.css({'width':'150px'});
	cDsbantrf.css({'width':'150px'});
	cDsagetrf.css({'width':'150px'});
	cNrctatrf.css({'width':'140px'});
	cNrdigtrf.css({'width':'75px' }).attr('maxlength','1');
	cDtadmiss.css({'width':'75px' }).addClass('data');
	cDtcantrf.css({'width':'75px' }).addClass('data');
	cCdsitcta.css({'width':'100px'});
	cTpctatrf.css({'width':'218px'});

	highlightObjFocus( $('#frmDados') );

	layoutPadrao();

	controlaOperacao();

	controlaPesquisas();

	return false;
}

function manterRotina( operacao ) {

    carregaDados();

	var mensagem = '';

	switch ( operacao ) {
		case 'valida' : mensagem = 'Aguarde, validando dados ...'; 	break;
		case 'grava'  : mensagem = 'Aguarde, gravando dados ...';	break;
		default		      : return false; 	break;
	}

	showMsgAguardo( mensagem );

	$.ajax({
			type  : 'POST',
			url   : UrlSite + 'telas/'+nometela+'/manter_rotina.php',
			data: {
				operacao	: operacao,
				nrdconta	: nrdconta,
				cddopcao	: cddopcao,
				cdagenca	: cdagenca,
				cdempres    : cdempres,
				nmfuncio    : removeCaracteresInvalidos(nmfuncio),
				cdagetrf    : cdagetrf,
				cdbantrf    : cdbantrf,
				nrdigtrf    : nrdigtrf,
				nrctatrf    : nrctatrf,
				nrcpfcgc    : nrcpfcgc,
				tpctatrf    : tpctatrf,
				redirect	: 'script_ajax'
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			},
			success: function(response) {
				hideMsgAguardo();
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

function controlaPesquisas() {

	/*---------------------*/
	/*  CONTROLE PA  	   */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#'+frmCab);

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {
		linkConta.addClass('lupa').css('cursor','auto').unbind('click');
	} else {
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {
			mostraAvalista();
			return false;
		});
	}

	var linkPac = $('a:eq(0)','#'+frmDados);

	if ( linkPac.prev().hasClass('campoTelaSemBorda') ) {
		linkPac.addClass('lupa').css('cursor','auto').unbind('click');
	} else {
		linkPac.css('cursor','pointer').unbind('click').bind('click', function() {
			bo			= 'b1wgen0059.p';
			procedure	= 'busca_pac';
			titulo      = 'Agência PA';
			qtReg		= '20';
			filtrosPesq	= 'Cód. PA;cdagenca;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
			colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
		});
	}

	var linkEmp	= $('a:eq(1)','#'+frmDados);
	if ( linkEmp.prev().hasClass('campoTelaSemBorda') ) {
		linkEmp.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkEmp.css('cursor','pointer').unbind('click').bind('click', function() {
			procedure	= 'busca_empresa';
			titulo      = 'Empresa';
			qtReg		= '30';
			filtrosPesq	= 'Cód. Empresa;cdempres;30px;S;0;;codigo|Empresa;nmresemp;200px;S;;;descricao';
			colunas 	= 'Código;cdempres;20%;right|Empresa;nmresemp;80%;left';
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
			return false;
		});
	}

	var linkBanco	= $('a:eq(2)','#'+frmDados);
	if ( linkBanco.prev().hasClass('campoTelaSemBorda') ) {
		linkBanco.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkBanco.css('cursor','pointer').unbind('click').bind('click', function() {
			bo			= 'b1wgen0059.p';
			procedure	= 'busca_banco';
			titulo      = 'Banco';
			qtReg		= '30';
			filtros 	= 'Cód. Banco;cdbantrf;30px;S;0|Nome Banco;dsbantrf;200px;S;';
			colunas 	= 'Código;cdbccxlt;20%;right|Banco;nmextbcc;80%;left';
			mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas);
			return false;
		});
	}

	var linkAgencia	= $('a:eq(3)','#'+frmDados);
	if ( linkAgencia.prev().hasClass('campoTelaSemBorda') ) {
		linkAgencia.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkAgencia.css('cursor','pointer').unbind('click').bind('click', function() {
			bo			= 'b1wgen0059.p';
			procedure	= 'busca_agencia';
			titulo      = 'Agência';
			qtReg		= '30';
			filtros 	= 'Cód. Agência;cdagetrf;30px;S;0|Agência;dsagetrf;200px;S;|Cód. Banco;cdbantrf;30px;N;|Banco;dsbantrf;200px;N;|Cód. Banco;cddbanco;30px;N;'+$('#cdbantrf','#'+frmDados).val()+';N;';
			colunas 	= 'Código;cdageban;20%;right|Agência;nmageban;80%;left';
			mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas);
			return false;
		});
	}

	return false;
}

function buscaPac(valor){

	procedure	= 'busca_pac';
	titulo      = 'Agência PA';
	filtrosDesc = 'cdagepac|'+valor;
	buscaDescricao(bo,procedure,titulo,'cdagenca','nmresage',valor,'dsagepac',filtrosDesc,frmDados);

	return false;
}

function buscaEmp(valor){

	procedure	= 'busca_empresa';
	titulo      = 'Empresa';
	filtrosDesc = '';
	buscaDescricao(bo,procedure,titulo,'cdempres','nmresemp',valor,'nmresemp',filtrosDesc,frmDados);
	return false;
}

function buscaBanco(valor){

	$('#nrdigtrf','#frmDados').habilitaCampo();

    // Verifica se for CECRED
	if (valor==85){
		$('#nrdigtrf','#frmDados').desabilitaCampo();
	}

	procedure	= 'busca_banco';
	titulo      = 'Banco';
	filtrosDesc = 'cdbccxlt|'+valor;
	buscaDescricao(bo,procedure,titulo,'cdbantrf','dsbantrf',valor,'nmextbcc',filtrosDesc,frmDados);
	return false;
}

function buscaAgencia(valor){

	procedure	= 'busca_agencia';
	titulo      = 'Agencia';
	filtrosDesc = 'cddbanco|'+$('#cdbantrf','#'+frmDados).val()+';cdageban|'+valor;
	buscaDescricao(bo,procedure,titulo,'cdagetrf','dsagetrf',valor,'nmageban',filtrosDesc,frmDados);
	return false;
}

function mostraAvalista() {

	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/'+nometela+'/avalista.php',
		data: {
			redirect: 'html_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			exibeRotina($('#divRotina'));
			formataAvalista();
			//buscaContrato();
			return false;
		}
	});
	return false;

}

function buscaAvalista() {

	showMsgAguardo('Aguarde, buscando ...');

	var nmprimtl = $('#nmprimtl','#frmAvalis').val();

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/'+nometela+'/busca_avalista.php',
		data: {
			nmprimtl: nmprimtl,
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
					formataAvalista();
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

function formataAvalista() {

	var rNmprimtl2 = $('label[for="nmprimtl"]','#frmAvalis');
	var cNmprimtl2 = $('#nmprimtl','#frmAvalis');

	//Label
	rNmprimtl2.addClass('rotulo').css({'width':'120px'});

	//Campos
	cNmprimtl2.css({'width':'300px'}).habilitaCampo();

	cNmprimtl2.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( $('#divRotina').css('visibility') == 'visible' ) {
			if ( e.keyCode == 13 ) { buscaAvalista(); return false; }
		}
	});

	var divRegistro = $('div.divRegistros','#divContrato');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

	divRegistro.css({'height':'130px'});

	var ordemInicial = new Array();
	ordemInicial = [[0,0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '80px';
	arrayLargura[1] = '280px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';

	var metodoTabela = 'selecionaAvalista();';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

	// centraliza a divRotina
	$('#divRotina').css({'width':'525px'});
	$('#divConteudo').css({'width':'500px'});
	$('#divRotina').centralizaRotinaH();

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	highlightObjFocus( $('#frmAvalis') );
	layoutPadrao();
	cNmprimtl2.focus();

	return false;
}

function limpaCampos() {

	cNrdconta.val('');
	return false;
}

function selecionaAvalista() {

	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {

		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cNrdconta.val( $('#nrdconta', $(this) ).val() );
				cNrdconta.trigger('blur');
			}
		});
	}

	fechaRotina( $('#divRotina') );
	buscaDados();
	return false;
}

function retirarAcentuacao(str) {    
    str = removeAcentos(str);
    $('#nmfuncio', '#frmDados').val(str);
}

function validaDados(){
	
	nmfuncio = $.trim($('#nmfuncio','#frmDados').val());	
	nmfuncio = retiraCaracteres(nmfuncio,'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ',true);
	
	$('#nmfuncio', '#frmDados').val(nmfuncio);
	
}
