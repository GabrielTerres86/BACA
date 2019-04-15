/*!
 * FONTE        : registro.js
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 23/04/2010 
 * OBJETIVO     : Biblioteca de funções na rotina REGISTRO da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 03/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 * 				  13/04/2018 - Alterado funcao voltarRotina para chamar a FATCA/CRS - PRJ 414 (Mateus - Mouts).
 * --------------
 */ 

 var flgContinuar = false;     // Controle botao Continuar	

 
function acessaOpcaoAba(nrOpcoes,id,opcao) {

	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, carregando...');
	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if (!$('#linkAba' + id)) {
			continue;
		}
		
		if (id == i) { // Atribui estilos para foco da opção
			$('#linkAba'   + id).attr('class','txtBrancoBold');
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
		url: UrlSite + 'telas/contas/registro/principal.php',
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			redirect: 'html_ajax'
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
				controlaFoco( operacao );
			}
			return false;
		}				 
	});
}

function controlaOperacao(operacao) {

	// Se não possui acesso para alterar, emitir mensagem	
	if ( (operacao == 'CA') && (flgAlterar != '1') ) {
		showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		exit();
	}
		
	// Mostra mensagem de aguardo
	var msgOperacao = '';
	switch (operacao) {			
		// Consulta para Alteração
		case 'CA': 
			msgOperacao = 'abrindo altera&ccedil;&atilde;o';
			break;	
		// Alteração para Consulta
		case 'AC': 
			showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
		// Consulta para Exclusão: Excluindo Bem
		case 'AV': 
			manterRotina(operacao);
			return false;
			break;	
		// Validação para Alteração: Salvando Alteração
		case 'VA': 
			manterRotina(operacao);
			return false;
			break;					
		// Qualquer outro valor: Cancelando Operação
		default: 
			msgOperacao = 'abrindo consulta';	
			break;
	}
	
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/registro/principal.php', 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			flgcadas: flgcadas,
			operacao: operacao,
			redirect: 'html_ajax'
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
				controlaFoco( operacao );
			}
			return false;
		}				
	});			
}

function manterRotina(operacao) {
	
	// Primerio oculta a mensagem de aguardo
	hideMsgAguardo();	
	
	var msgOperacao = '';
	switch (operacao) {	
		case 'VA':
			msgOperacao = 'salvando altera&ccedil;&atilde;o'; 
			break;
		case 'AV': 
			msgOperacao = 'validando dados'; 
			break;						
		default: 
			return false; 
			break;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	vlfatano = $('#vlfatano','#frmRegistro').val(); 
	vlcaprea = $('#vlcaprea','#frmRegistro').val();
	dtregemp = $('#dtregemp','#frmRegistro').val();
	nrregemp = $('#nrregemp','#frmRegistro').val();
	orregemp = $('#orregemp','#frmRegistro').val();
	dtinsnum = $('#dtinsnum','#frmRegistro').val();
	nrinsmun = normalizaNumero( $('#nrinsmun','#frmRegistro').val() );
	nrinsest = normalizaNumero( $('#nrinsest','#frmRegistro').val() );
	nrcdnire = $('#nrcdnire','#frmRegistro').val();
	perfatcl = $('#perfatcl','#frmRegistro').val();
	flgrefis = $('input[name="flgrefis"]:checked','#frmRegistro').val();
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/registro/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, vlfatano: vlfatano,
			vlcaprea: vlcaprea,	dtregemp: dtregemp,	nrregemp: nrregemp,
			orregemp: orregemp,	dtinsnum: dtinsnum,	nrinsmun: nrinsmun,
			nrinsest: nrinsest,	flgrefis: flgrefis,	nrcdnire: nrcdnire,
			perfatcl: perfatcl, operacao: operacao,	flgcadas: flgcadas,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				
				eval(response);
				
				// Se esta fazendo o cadastro apos MATRIC, fechar rotina e ir pra proxima
				if  (operacao == 'VA' && (flgcadas == 'M' || flgContinuar)) {
					proximaRotina();
				}
				
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
			}
		}				
	});
}

function controlaLayout(operacao) {	
	var todos = $('input[type="text"]','#frmRegistro');
	var flag  = $('input[name="flgrefis"]','#frmRegistro');
	
	$('#divRegistro').fadeTo(1,0.01);
	divRotina.css({'height':'300px','width':'570px'});
	$('#frmRegistro').css('padding-top','3px');
	
	// Controla Rótulos vlcaprea
	$('label[for="vlfatano"],label[for="dtregemp"],label[for="dtinsnum"],label[for="perfatcl"],','#frmRegistro').addClass('rotulo-100');
	$('label[for="nrregemp"],label[for="nrinsmun"],label[for="nrinsest"]','#frmRegistro').css('width','65px');
	$('label[for="vlcaprea"]','#frmRegistro').css('width','130px');
	$('label[for="orregemp"]','#frmRegistro').addClass('rotulo-50'); 
	$('label[for="flgrefis"]','#frmRegistro').addClass('rotulo-100');
	$('label[for="nrcdnire"]','#frmRegistro').css('width','85px');
	
	// Controla Campos 
	$('#perfatcl','#frmRegistro').css('width','50px').addClass('porcento');	
	$('#vlfatano,#vlcaprea','#frmRegistro').css('text-align','right');
	$('#vlcaprea','#frmRegistro').css('width','133px');
	$('#orregemp','#frmRegistro').attr('maxlength','11').addClass('alphanum').css('width','109px');
	$('#nrinsest,#nrinsmun,#nrcdnire,#nrregemp','#frmRegistro').css('width','100px').addClass('inteiro');
	$('#dtregemp,#dtinsnum','#frmRegistro').addClass('data').css('width','70px');
	
	if ( $.browser.msie ) { 
		$('label[for="nrinsest"]','#frmRegistro').css('width','62px');
		$('#vlcaprea','#frmRegistro').css('width','139px');
	}
	
	// Controle de Máscaras
	$('#vlfatano','#frmRegistro').setMask('DECIMAL','zzz.zzz.zz9,99',',','');
	$('#vlfatano','#frmRegistro').trigger('blur');	
	$('#vlcaprea','#frmRegistro').setMask('DECIMAL','zzz.zzz.zz9,99',',','');
	$('#vlcaprea','#frmRegistro').trigger('blur');
	$('#nrregemp','#frmRegistro').setMask('INTEGER','zzzzzzzzzzzz','','');
	$('#nrregemp','#frmRegistro').trigger('blur');
	$('#nrinsmun','#frmRegistro').setMask('INTEGER','zzz.zzz.zzz.zzz.z','','');
	$('#nrinsmun','#frmRegistro').trigger('blur');
	$('#nrinsest','#frmRegistro').setMask('INTEGER','zzz.zzz.zzz.zzz','','');
	$('#nrinsest','#frmRegistro').trigger('blur');
	$('#nrcdnire','#frmRegistro').setMask('INTEGER','zzzzzzzzzzzz','','');
	$('#nrcdnire','#frmRegistro').trigger('blur');
	
	// Se está Alterando 
	if (operacao == 'CA') {
		todos.addClass('campo').removeProp('disabled');
		flag.removeProp('disabled');		

		// Valida Percentual 
		// Se maior do que 100, mostra mensagem de erro e retorna o foco no mesmo campo
		$('#perfatcl','#frmRegistro').blur(function () {
			if ( parseFloat( $(this).val().replace(',','.') ) > 100 ) {
				showError('error','Percentual deve ser menor ou igual a 100,00.','Alerta - Aimaro','bloqueiaFundo($("#divRotina"),\'perfatcl\',\'frmRegistro\')');
			} else {
				$(this).removeClass('campoErro');
			}
		});	

		$('#nrcdnire','#frmRegistro').bind("keydown",function(e) {
			if (e.keyCode == 13) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});	
		
	} else {
		todos.addClass('campoTelaSemBorda').prop('disabled',true);
		flag.prop('disabled',true);
	}


	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);	
	removeOpacidade('divRegistro');
	divRotina.centralizaRotinaH();
	highlightObjFocus($('#frmRegistro'));
	controlaFocoEnter("frmRegistro");
	return false;	
}

function controlaFoco(operacao) {
	if (in_array(operacao,['AC','FA',''])) {
		$('#btAlterar','#divBotoes').focus();
	} else {
		$('#vlfatano','#frmRegistro').focus();
	}
	return false;
}

function controlaContinuar () {
	
	flgContinuar = true;
	
	if ($("#btAlterar","#divBotoes").length > 0) {
		proximaRotina();
	} else {
		controlaOperacao('AV');
	}
	
}	

function voltarRotina() {
	fechaRotina(divRotina);
	acessaRotina('FATCA CRS','FATCA/CRS','fatca_crs_pj'); 
}

function proximaRotina() {
	hideMsgAguardo();
	encerraRotina(false);
	acessaRotina('ENDERECO','Endereço','endereco');
}