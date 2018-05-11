/*!
 * FONTE        : imunidade_tributaria.js
 * CRIAÇÃO      : Lucas R. (CECRED)
 * DATA CRIAÇÃO : Julho/2013
 * OBJETIVO     : Biblioteca de funções da rotina imunidade tributaria da tela de CADCTA
 * --------------
 * ALTERAÇÕES   :20/09/2013 - Corrigindo os campos cddentid e cdsitcad
							  para exibir os dados que vem da base e mostrar corretamente
							  na tela (André Santos/ SUPERO)
				 
				 30/10/2013 - Incluir campo opcao passado por parametro no principal.php
							  (Lucas R.)
							  
				 06/08/2015 - Reformulacao Cadastral (Gabriel-RKAM)		

				 01/12/2015 - Corrigir impressao (Gabriel-RKAM).			
 * --------------
 */

var vlentBase; //cddentid
var vlsitBase; //cdsitcad
var flgContinuar = false;
 
var rCddentid, rCdsitcad, cCddentid, cCdsitcad; 
 
var nrcpfcgc = $("#nrcpfcgc","#frmCabCadcta").val();
 
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
	
	nrcpfcgc = normalizaNumero( nrcpfcgc );
	
    // Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/cadcta/imunidade_tributaria/principal.php",
		data: {
			cddopcao: opcao,
			nrcpfcgc: nrcpfcgc,
			flgcadas: flgcadas,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
                vlentBase = $("#cddentid","#frmImunidade").val();
                vlsitBase = $("#cdsitcad","#frmImunidade").val();
			} else {
				eval(response);
				controlaFoco();				
			}
			controlaLayout();				
			return false;
		}				
	});	
	
}

// Somente para nao dar erro na chamada desta rotina IMUNIDADE TRIBUTARIA
function controlaOperacao(operacao) {
	hideMsgAguardo();
	blockBackground(parseInt($('#divRotina').css('z-index')));
}

function confirmaRotina() {
	
	if (isHabilitado(cCddentid) == false) {
		$('input, select','#frmImunidade').habilitaCampo();
		return false;
	}
	
	showConfirmacao("Confirma Opera&ccedil;&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","manterRotinaImun();","hideMsgAguardo();bloqueiaFundo(divRotina);","sim.gif","nao.gif");
}

function manterRotinaImun() {

	var cddentid = $("#cddentid","#frmImunidade").val();
	var cdsitcad = $("#cdsitcad","#frmImunidade").val();

    if (vlentBase != cddentid) {
       vlentBase = $("#cddentid","#frmImunidade").val();
       $("#cdsitcad","#frmImunidade").val(0);
       cdsitcad = 0;
    }
    
	nrcpfcgc = normalizaNumero( nrcpfcgc );
	
	showMsgAguardo('Aguarde, carregando dados ... ');
			
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',	
		dataType: "html",		
		url: UrlSite + 'telas/cadcta/imunidade_tributaria/manter_rotina.php', 
		data: {
			nrcpfcgc: nrcpfcgc,
			cddentid: cddentid,
			cdsitcad: cdsitcad,
			flgcadas: flgcadas,
			flgContinuar: flgContinuar,
			redirect: 'script_ajax'
		},  
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			eval(response);
			$('input, select','#frmImunidade').desabilitaCampo();
		}
	});			

}

function controlaLayout() {

	// CONTROLA A ALTURA DA TELA  
	divRotina.css({'height':'380px','width':'550px'});
	
	// SELETORES GENÉRICOS
	var cTodos	= $('input, select','#frmImunidade');
	var cSelect	= $('select','#frmImunidade');
	
	rCddentid = $('label[for="cddentid"]','#frmImunidade');
	rCdsitcad = $('label[for="cdsitcad"]','#frmImunidade');
	cCddentid = $('#cddentid','#frmImunidade');
	cCdsitcad = $('#cdsitcad','#frmImunidade');
	
	rCddentid.addClass('rotulo').css('width','120px');	
	rCdsitcad.addClass('rotulo').css('width','120px');
	cCddentid.css('width','350px');
	cCdsitcad.css('width','150px');	

	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'4px','padding':'2px 2px'});
				
	cTodos.desabilitaCampo();
	layoutPadrao();
	
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	divRotina.centralizaRotinaH();	
	controlaFoco();

	return false;	

}

function controlaFoco() {
	
	$('select[name=\'cddentid\']','#frmImunidade').focus();
	
	$('#cddentid','#frmImunidade').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#cdsitcad','#frmImunidade').focus();
            return false;
		}	
	});
	
	$('#cdsitcad','#frmImunidade').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btAlterar','#divBotoes').focus();
            return false;
		}	
	});
	
	return false;
}

function confirmaImpressao() {
	showConfirmacao("Confirma Impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","btnImprimir();","hideMsgAguardo();bloqueiaFundo(divRotina);","sim.gif","nao.gif");	
}

function btnImprimir() {
	
	var cddentid = $("#cddentid","#frmImunidade").val();
	nrcpfcgc = normalizaNumero( nrcpfcgc );
		
	var action    = UrlSite + 'telas/cadcta/imunidade_tributaria/imprime_imunidade.php';	
	var callafter = "hideMsgAguardo();bloqueiaFundo(divRotina);";
	
	$('#sidlogin','#frmImunidade').remove();
	$('#nrcpfcgc','#frmImunidade').remove();
	$('#cddentid','#frmImunidade').remove();
	
	$('#frmImunidade').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');
	$('#frmImunidade').append('<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="' + nrcpfcgc + '" />');
	$('#frmImunidade').append('<input type="hidden" id="cddentid" name="cddentid" value="' + cddentid + '" />');

	carregaImpressaoAyllos("frmImunidade",action,callafter);
	return false;
		
}

function voltarRotina() {
	fechaRotina(divRotina);
	acessaRotina('FINANCEIRO-INF.ADICIONAIS','Inf. Adicionais','inf_adicionais');	
}

function proximaRotina () {
		
	if (flgcadas == 'M') {
		acessaRotina('IMPRESSOES','Impressoes','impressoes');	
		return false;
	}	
	else {	
		hideMsgAguardo();
		bloqueiaFundo(divRotina);
		
		// Vai para a ATENDA - PRODUTOS
		setaParametros('ATENDA','',nrdconta,flgcadas); 	
		direcionaTela('ATENDA','no');
	}
		
}

function controlaContinuar () {
 
	flgContinuar = true;

	if ( isHabilitado(cCddentid) == false) {
		proximaRotina();
	} else {
		confirmaRotina();
	}
}
