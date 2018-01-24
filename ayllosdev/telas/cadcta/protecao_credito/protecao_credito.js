/*!
 * FONTE        : protecao_credito.js
 * CRIAÇÃO      : Jonata (Rkam)
 * DATA CRIAÇÃO : Agosto/2014 
 * OBJETIVO     : Biblioteca de funções da rotina Protecao Credito da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 12/01/2016 - Inclusao do parametro de assinatura conjunta, Prj. 131 (Jean Michel)
 * ALTERAÇÕES   :
 * 000: [21/03/2016] Incluido dados consulta Boa Vista - PRJ207 Esteira -  (Odirlei/AMcom)
 * --------------
 */

// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes,id,opcao) {  
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando...");
	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da opção
			$("#linkAba" + id).attr("class","txtBrancoBold");
			$("#imgAbaEsq" + id).attr("src",UrlImagens + "background/mnu_sle.gif");				
			$("#imgAbaDir" + id).attr("src",UrlImagens + "background/mnu_sld.gif");
			$("#imgAbaCen" + id).css("background-color","#969FA9");
			continue;			
		}
		
		$("#linkAba" + i).attr("class","txtNormalBold");
		$("#imgAbaEsq" + i).attr("src",UrlImagens + "background/mnu_nle.gif");			
		$("#imgAbaDir" + i).attr("src",UrlImagens + "background/mnu_nld.gif");
		$("#imgAbaCen" + i).css("background-color","#C6C8CA");
	}

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/cadcta/protecao_credito/principal.php",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',bloqueiaFundo(divRotina));
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

function controlaOperacao(operacao, msgRetorno) {

	// Verifica permissões de acesso
	if ( (operacao == 'CA') && (flgAlterar != '1') ) { 
		showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina);');
		return false;
	} 
		
	// Mostra mensagem de aguardo
	var msgOperacao = '';
	switch (operacao) {			
		// Consulta para Alteração
		case 'CA': 
			msgOperacao = 'abrindo altera&ccedil;&atilde;o';
			cddopcao    = 'A';
			break;
		// Alteração para Consulta
		case 'AC': 
			showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;	
		// Alteração para Validação - Validando Alteração
		case 'AV': 
			manterRotina(operacao);
			return false;
			break;	
		// Validação para Alteração - Salvando Alteração
		case 'VA': 
			manterRotina(operacao);
			operacao = '';
			break;				
		// Finalizou Alteração, mostrar mensagem
		case 'FA':
			msgOperacao = 'finalizando altera&ccedil;&atilde;o';
			cddopcao    = '@';			
			break;		
		// Qualquer outro valor: Cancelando Operação
		case 'DA':
			carregaImpressao();
			return false;			
		default: 
			msgOperacao = 'abrindo consulta';
			cddopcao    = '@';
			break;			
	}
	
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadcta/protecao_credito/principal.php', 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			operacao: operacao,
			redirect: "html_ajax"
		},  
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
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

function manterRotina(operacao) {

	hideMsgAguardo();	
	
	var msgOperacao = '';

	switch (operacao) {	
		case 'VA': msgOperacao = 'salvando altera&ccedil;&atilde;o'; break;
		case 'AV': msgOperacao = 'validando altera&ccedil;&atilde;o'; break;
		case 'DA': msgOperacao = 'consultando detalhes'; break;
		default: return false; break;
	}
	
	showMsgAguardo('Aguarde, ' + msgOperacao + ' ...');
	
	var nomeForm = "frmDadosProtecao";
	var cdagepac = $('#cdagepac','#' + nomeForm ).val();
	var cdsitdct = $('#cdsitdct','#' + nomeForm ).val();
	var cdtipcta = $('#cdtipcta','#' + nomeForm ).val();		
	var cdbcochq = $('#cdbcochq','#' + nomeForm ).val();	
	var nrdctitg = $('#nrdctitg','#' + nomeForm ).val();
	var cdagedbb = $('#cdagedbb','#' + nomeForm ).val();
	var cdbcoitg = $('#cdbcoitg','#' + nomeForm ).val();
	var cdsecext = $('#cdsecext','#' + nomeForm ).val();
	var dtcnsscr = $('#dtcnsscr','#' + nomeForm ).val();
	var dtcnsspc = $('#dtcnsspc','#' + nomeForm ).val();
	var dtdsdspc = $('#dtdsdspc','#' + nomeForm ).val();
	var dtabtcoo = $('#dtabtcoo','#' + nomeForm ).val();
	var dtelimin = $('#dtelimin','#' + nomeForm ).val();
	var dtabtcct = $('#dtabtcct','#' + nomeForm ).val();
	var dtdemiss = $('#dtdemiss','#' + nomeForm ).val();
	var flgcrdpa = $('#flgcrdpa','#' + nomeForm ).val();
    var flgiddep = $('#flgiddep','#' + nomeForm ).val();
	var tpavsdeb = $('#tpavsdeb','#' + nomeForm ).val();
	var tpextcta = $('#tpextcta','#' + nomeForm ).val();
	var inadimpl = $('input[name="inadimpl"]:checked','#' + nomeForm ).val();
	var inlbacen = $('#inlbacen','#' + nomeForm ).val();
	var flgrestr = $('#flgrestr', '#' + nomeForm).val();
	var idastcjt = $('#idastcjt', '#' + nomeForm).val();
  			
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/cadcta/protecao_credito/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, 
			cdagepac: cdagepac,	cdsitdct: cdsitdct, cdtipcta: cdtipcta,
			cdbcochq: cdbcochq,	nrdctitg: nrdctitg, cdagedbb: cdagedbb,
			cdbcoitg: cdbcoitg,	cdsecext: cdsecext, dtcnsscr: dtcnsscr,
			dtcnsspc: dtcnsspc,	dtdsdspc: dtdsdspc, dtabtcoo: dtabtcoo,
			dtelimin: dtelimin,	dtabtcct: dtabtcct, dtdemiss: dtdemiss,
            flgcrdpa: flgcrdpa, flgiddep: flgiddep,	tpavsdeb: tpavsdeb, 
            tpextcta: tpextcta, flgrestr: flgrestr,	inadimpl: inadimpl,	
            inlbacen: inlbacen, idastcjt: idastcjt, operacao: operacao,
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
				return;
			}
			hideMsgAguardo();
			bloqueiaFundo(divRotina);
		}				
	});
}

function carregaImpressao () {

	// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
	blockBackground(parseInt($('#divRotina').css('z-index')));
	
	var nrconbir = $("#nrconbir","#frmDadosProtecao").val();
	var nrseqdet = $("#nrseqdet","#frmDadosProtecao").val();
	var cdbircon = $("#cdbircon","#frmDadosProtecao").val();
	var cdmodbir = $("#cdmodbir","#frmDadosProtecao").val();
		
	$("#nrconbir","#frmImpressao").val(nrconbir);
	$("#nrseqdet","#frmImpressao").val(nrseqdet);
	$("#cdbircon","#frmImpressao").val(cdbircon);
	$("#cdmodbir","#frmImpressao").val(cdmodbir);
	$("#nrdconta","#frmImpressao").val(nrdconta);
	$("#inpessoa","#frmImpressao").val(inpessoa);

	var action = $("#frmImpressao").attr("action");
	var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";
	
	carregaImpressaoAyllos("frmImpressao",action,callafter);

}

function controlaLayout(operacao) {	
	
	var rInadimpl = $('label[for="inadimpl"]','#frmDadosProtecao');	
	var rDtcnsspc = $('label[for="dtcnsspc"]','#frmDadosProtecao');
	var rDtdsdspc = $('label[for="dtdsdspc"]','#frmDadosProtecao');	
	var rDsinaout = $('label[for="dsinaout"]','#frmDadosProtecao');		
    var rDtdscore = $('label[for="dtdscore"]','#frmDadosProtecao');	
	var rDsdscore = $('label[for="dsdscore"]','#frmDadosProtecao');		
    var cDsdscore = $('#dsdscore','#frmDadosProtecao');		
    
    
	var campos  = $('input','#frmDadosProtecao');
	var rPrincipal  = $('label[for="dtcnsspc"],label[for="dsinacop"]','#frmDadosProtecao');
	var rInadimpl_todos   = $('label[for="inadimpl_1"],label[for="inadimpl_2"],label[for="dsinaout_1"],label[for="dsinaout_2"]','#frmDadosProtecao');
	var cInadimpl   = $('#inadimpl_1,#inadimpl_2,#dsinaout_1,#dsinaout_2,#dsinaout_3','#frmDadosProtecao');
	var cBloqueia   = $('#dsinaout_1,#dsinaout_2,#dsinaout_3,#dtdscore,#dsdscore','#frmDadosProtecao');

	$('#divConteudoOpcao').hide(0, function() {

		// Controla a altura da tela		
		$('#divConteudoOpcao').css('width','570px');
		$('#divConteudoOpcao').css('height','160px');
		
		$('#frmDadosProtecao').css({'padding-top':'5px','padding-bottom':'15px'});
		rPrincipal.addClass('rotulo');

		// Sempre inicia com tudo bloqueado
		campos.removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true).attr('maxlength','40');
		
		// Formatação dos rotulos
		rInadimpl.css('width','110px');
		rDtcnsspc.css('width','200px');
		rDtdsdspc.css('width','80px');
		rDsinaout.css('width','160px');		
		rInadimpl_todos.css('width','20px');
		
        rDtdscore.css('width','111px');
		rDsdscore.css('width','50px');
        
		
		// Formatação dos campos
		campos.css({'width':'90px'});
		cInadimpl.css({'width':'20px'});
				
        cDsdscore.css({'width':'210px'});
				
		switch(operacao) {
		
			// Consulta Alteração
			case 'CA': 
				campos.habilitaCampo();
				cBloqueia.desabilitaCampo();
				break;
				
			default: 
				break;
		}
		
		layoutPadrao();
		hideMsgAguardo();
		bloqueiaFundo(divRotina);	
		$(this).fadeIn(1000);
		controlaFoco(operacao);
		divRotina.centralizaRotinaH(); 
	});	
	
	return false;	
}	

function controlaFoco(operacao) {
	if (in_array(operacao,['AC','FA',''])) {
		$('#btAlterar','#divBotoes').focus();
	} else {		
		$('#dtcnsspc','#frmDadosProtecao').focus();
	}
	return false;
}