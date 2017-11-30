/*
 * FONTE        : contas_ted_capital.js
 * CRIAÇÃO      : Jonata - RKAM
 * DATA CRIAÇÃO : Agosto/2017
 * OBJETIVO     : Biblioteca de funções na rotina Gerar TED Capital da tela de MATRIC
 * ALTERAÇÃO    : 
 
 
 
 */
 
function acessaOpcaoAbaTedCapital(nrOpcoes,id,opcao){ 
	
	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, carregando...');
	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if (!$('#linkAba' + id)) {
			continue;
		}
		
		if (id == i) { // Atribui estilos para foco da opção
			$('#linkAba' + id).attr('class','txtBrancoBold');
			$('#imgAbaEsq' + id).attr('src',UrlImagens + 'background/mnu_sle.gif');				
			$('#imgAbaDir' + id).attr('src',UrlImagens + 'background/mnu_sld.gif');
			$('#imgAbaCen' + id).css('background-color','#969FA9');
			continue;			
		}
		
		$('#linkAba'   + i).attr('class','txtNormalBold');
		$('#imgAbaEsq' + i).attr('src',UrlImagens + 'background/mnu_nle.gif');			
		$('#imgAbaDir' + i).attr('src',UrlImagens + 'background/mnu_nld.gif');
		$('#imgAbaCen' + i).css('background-color','#C6C8CA');
		
	}		 
		
	// Carrega conteúdo da opção através do Ajax
	$.ajax({		
		type: 'POST', 
		dataType: 'html',
		url: UrlSite + 'includes/contas_ted_capital/principal.php',
		data: {
			nrdconta     : nrdconta,
			nmrotina     : nmrotina,
			redirect     : 'html_ajax'
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			 
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
			} else {
				
				eval( response );
				
			}
									
			return false;	
		}
	});
}


function controlaLayoutContasTedCapital(tpoperac) {
	
	var	altura 	= '270px';
	var	largura = '650px';	
	
	divRotina.css('width',largura);	
	
	$('#divConteudoOpcao').css('height',altura);		
		
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	divRotina.centralizaRotinaH();
	formataDados(tpoperac);
		
	return false;	
}



function formataDados(tpoperac){

	$('#fsetDados').css({'border-bottom':'1px solid #777'});	
	$('#fsetSituacao').css({'border-bottom':'1px solid #777'});	
	
	var cTodosDados = $('input[type="text"],select','#frmDados');

	var rCdagechq = $('label[for="cdagechq"]','#frmDados');
	var cCdagechq = $('#cdagechq','#frmDados');

	cTodosDados.habilitaCampo();

	var rNmtitular = $('label[for="nmtitular"]','#frmDados');
	var rNrcpfcgc = $('label[for="nrcpfcgc"]','#frmDados');
	var rCdbantrf = $('label[for="cdbantrf"]','#frmDados');
	var rNrctatrf = $('label[for="nrctatrf"]','#frmDados');
	var rNrdigtrf = $('label[for="nrdigtrf"]','#frmDados');
	var rCdsitcta = $('label[for="cdsitcta"]','#frmDados');
	var rCdagetrf = $('label[for="cdagetrf"]','#frmDados');

	rNmtitular.css({'width':'110px'}).addClass('rotulo');
	rNrcpfcgc.css({'width':'110px'}).addClass('rotulo');
	rCdbantrf.css({'width':'110px'}).addClass('rotulo');
	rNrctatrf.css({'width':'110px'}).addClass('rotulo');
	rCdagetrf.css({'width':'110px'}).addClass('rotulo');
	rNrdigtrf.addClass('rotulo-linha');
	rCdsitcta.css({'width':'110px'}).addClass('rotulo-linha');
	
	var cNmtitular = $('#nmtitular','#frmDados');
	var cNrcpfcgc = $('#nrcpfcgc','#frmDados');
	var cCdbantrf = $('#cdbantrf','#frmDados');
	var cDsbantrf = $('#dsbantrf','#frmDados');
	var cNrctatrf = $('#nrctatrf','#frmDados');
	var cNrdigtrf = $('#nrdigtrf','#frmDados');
	var cCdsitcta = $('#cdsitcta','#frmDados');
	var cCdagetrf = $('#cdagetrf','#frmDados');
	var cDsagetrf = $('#dsagetrf','#frmDados');

	cNmtitular.css({'width':'380px'}).attr('maxlength','55').addClass('alpha');
	cNrcpfcgc.css('width','216px').addClass('inteiro').attr('maxlength','18');
	cCdbantrf.css({'width':'45px' }).attr('maxlength','5');
	cCdagetrf.css({'width':'45px' }).attr('maxlength','10');
	cDsbantrf.css({'width':'310px'});
	cDsagetrf.css({'width':'310px'});
	cNrctatrf.css({'width':'100px','text-align':'right'}).addClass('conta');
	cNrdigtrf.css({'width':'75px' }).addClass('inteiro').attr('maxlength','1');
	cCdsitcta.css({'width':'100px'});

	highlightObjFocus( $('#frmDados') );

	// Se pressionar cNrcpfcgc
	cNrcpfcgc.unbind('blur').bind('blur', function(){ 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
	
		$(this).removeClass('campoErro');
					
		var cpfCnpj = normalizaNumero($('#nrcpfcgc','#frmDados').val());
		
		if(cpfCnpj.length <= 11){	
			cNrcpfcgc.val(mascara(cpfCnpj,'###.###.###-##'));
		}else{
			cNrcpfcgc.val(mascara(cpfCnpj,'##.###.###/####-##'));
		}
									
		return false;	
										
	});				
	
	//Banco
    $('#cdbantrf', '#frmDados').unbind('blur').bind('blur', function () {
		
		if( $('#divRotina').css('visibility') == 'visible'){
			
			$('#nrdigtrf','#frmDados').habilitaCampo();

			// Verifica se for CECRED
			if ($(this).val()==85){
				$('#nrdigtrf','#frmDados').desabilitaCampo();
			}
			
			bo			= 'b1wgen0059.p';
			procedure	= 'busca_banco';
			titulo      = 'Banco';
			filtrosDesc = 'cdbccxlt|'+$(this).val();
			buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsbantrf',$(this).val(), 'nmextbcc', filtrosDesc, 'frmDados','bloqueiaFundo(divRotina);');
				
		}
		
		return false;
		
    });	

	//Agência
    $('#cdagetrf', '#frmDados').unbind('blur').bind('blur', function () {		
		
		if( $('#divRotina').css('visibility') == 'visible'){
		
			bo			= 'b1wgen0059.p';
			procedure	= 'busca_agencia';
			titulo      = 'Agencia';
			filtrosDesc = 'cddbanco|'+$('#cdbantrf','#frmDados').val()+';cdageban|'+$(this).val();
			buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsagetrf',$(this).val(), 'nmageban', filtrosDesc, 'frmDados','bloqueiaFundo(divRotina);');

		}
		
		return false;
		
    });	
	
	layoutPadrao();
	controlaPesquisasFormTedCapital();
	controlaBotoesFormDadosTedCapital(tpoperac);
		
	return false;
}

function controlaBotoesFormDadosTedCapital(tpoperac){	

	switch (tpoperac) {
		
		case "C":
			$('#btIncluir','#divBotoesDados').css('display','none');
			$('#btExcluir','#divBotoesDados').css('display','inline');
			$('#btAlterar','#divBotoesDados').css('display','inline');
			$('#btReativar','#divBotoesDados').css('display','inline');
			$('#btConcluir','#divBotoesDados').css('display','none');
			$('input[type="text"],select','#frmDados').desabilitaCampo();
			break;
		case "A":
			$('input[type="text"],select','#frmDados').desabilitaCampo();
			$('#nmtitular','#frmDados').habilitaCampo();
			$('#nrcpfcgc','#frmDados').habilitaCampo();
			$('#cdbantrf','#frmDados').habilitaCampo();			 
			$('#cdagetrf','#frmDados').habilitaCampo();			 
			$('#nrctatrf','#frmDados').habilitaCampo();			 
			if($('#cdbantrf', '#frmDados').val() != 85){$('#nrdigtrf','#frmDados').habilitaCampo();}else{$('#nrdigtrf','#frmDados').desabilitaCampo();}			 
			$('#divBotoesDados').css('display','none');
			$('#divBotoesAlterar').css('display','block');
			$('#nmtitular','#frmDados').focus();
			break;
		case "I":
			$('input[type="text"],select','#frmDados').habilitaCampo();			
			$('#dsbantrf','#frmDados').desabilitaCampo();
			$('#dsagetrf','#frmDados').desabilitaCampo();
			$('#dtadmiss','#frmDados').desabilitaCampo();
			$('#dtcantrf','#frmDados').desabilitaCampo();
			$('#cdsitcta','#frmDados').desabilitaCampo();
			$('#btIncluir','#divBotoesDados').css('display','inline');
			$('#btExcluir','#divBotoesDados').css('display','none');
			$('#btAlterar','#divBotoesDados').css('display','none');
			$('#btReativar','#divBotoesDados').css('display','none');
			$('#btConcluir','#divBotoesDados').css('display','none');
			$('#nmtitular','#frmDados').focus();
			break;
	}

	return false;

}

function controlaPesquisasFormTedCapital() {	
	
	var linkBanco	= $('a:eq(0)','#frmDados');
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
			mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,$('#divRotina'));
			return false;
		});
	}

	var linkAgencia	= $('a:eq(1)','#frmDados');
	if ( linkAgencia.prev().hasClass('campoTelaSemBorda') ) {
		linkAgencia.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkAgencia.css('cursor','pointer').unbind('click').bind('click', function() {
			bo			= 'b1wgen0059.p';
			procedure	= 'busca_agencia';
			titulo      = 'Agência';
			qtReg		= '30';
			filtros 	= 'Cód. Agência;cdagetrf;30px;S;0|Agência;dsagetrf;200px;S;|Cód. Banco;cdbantrf;30px;N;|Banco;dsbantrf;200px;N;|Cód. Banco;cddbanco;30px;N;'+$('#cdbantrf','#frmDados').val()+';N;';
			colunas 	= 'Código;cdageban;20%;right|Agência;nmageban;80%;left';
			mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,$('#divRotina'));
			return false;
		});
	}
	
	return false;
}


function manterContaDestinoTedCapital(cddopcao) {

	// Recebendo valores do formulário
	var nrcpfcgc = normalizaNumero($('#nrcpfcgc','#frmDados').val());
	var nmtitular = $('#nmtitular','#frmDados').val();
	var cdbantrf = $('#cdbantrf','#frmDados').val(); 
	var cdagetrf = $('#cdagetrf','#frmDados').val(); 
	var nrctatrf = normalizaNumero($('#nrctatrf','#frmDados').val()); 
	var nrdigtrf = $('#nrdigtrf','#frmDados').val(); 
	
	showMsgAguardo( 'Aguarde, efetuando operação...' );
			
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'includes/contas_ted_capital/manter_conta_destino_ted_capital.php', 		
		data: {			
			nrcpfcgc: nrcpfcgc, 
			nmtitular: nmtitular, 
			cdbantrf: cdbantrf, 
			cdagetrf: cdagetrf, 
			nrctatrf: nrctatrf, 
			nrdigtrf: nrdigtrf, 
			cddopcao: cddopcao, 
			nrdconta: nrdconta, 
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
			}
		}				
	});
	
	return false;
	
}


function retirarAcentuacaoTedCapital(str) {    
    str = removeAcentos(str);
    $('#nmtitular', '#frmDados').val(str);
}