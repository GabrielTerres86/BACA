//*********************************************************************************************//
//*** Fonte: alerta.js                                                                      ***//
//*** Autor: Adriano                                                                        ***//
//*** Data : Fevereiro/2013                Última Alteração: 10/07/2018                   ***//
//***                                                                                       ***//
//*** Objetivo  : Biblioteca de funções da tela ALERTA                                      ***//
//***                                                                                       ***//	 
//*** Alterações:                                                                           ***//
//***             09/08/2013 - Carlos (Cecred) : Alteração da sigla PAC para PA.            ***//
//***																						***//
//***			  30/05/2014 - Adicionado replace de caracteres de quebra de linha vindo do ***//
//***						   campo de justificativa, tanto de inclusao como de exclusao.  ***//
//***						   (Jorge/Rosangela) - Emergencial   							***//
//***         																				***//
//***			  15/09/2014 - Chamado 152916 (Jonata-RKAM).                                ***//
//***																						***//
//*** 			  10/07/2018 - Ajuste para nao permitir caractere invalido. 				***//
//*** 						   (PRB0040139 - Kelvin)										***//
//*********************************************************************************************//

var nrregres;


$(document).ready(function() {

	formataCabecalho();
	estadoInicial();
			
});


function estadoInicial() {

	//Esconde os div's referente a consulta	
	$('#divOpcoesConsulta').css('display','none');
	$('#divBotoes','#divOpcoesConsulta').css('display','none');
	$('#btConsulta','#divOpcoesConsulta').hide();
	$('#btVoltar','#divOpcoesConsulta').hide();
	
	//Limpa os div's
	$('#divDetalhes').html('');
	$('#divTabela').html('');
	
	//Esconde os divs CPF e limpa o radio
	$('#divCpf').css('display','none');
	$('#divNome').css('display','none');
	$('#divRelatorio').css('display','none');
	$('#divPeriodo').css('display','none');
	$('#frmOpcoesConsulta').css('display','none');
	
	// Deselecionar os check
	$('#cpfcgc').prop('checked',false);	
	$('#nome').prop('checked',false);
	$("#tprelato","#frmOpcoesConsulta").val('1');
	$("#dtinicio","#frmOpcoesConsulta").val('');
	$("#dtdfinal","#frmOpcoesConsulta").val('');
		
	limpaCampos('C');
	formataOpcoesConsulta();
	layoutPadrao();
	$('#cddopcao','#frmCabAlerta').habilitaCampo().focus();
			
}

function controlaOperacao(op,nriniseq, nrregist){

	var cddopcao = $('#cddopcao','#frmCabAlerta').val();
	var nrcpfcgc = $('#consucpf','#frmOpcoesConsulta').val();
	var consupes = $('#consupes','#frmOpcoesConsulta').val();
	var consucpf = normalizaNumero(nrcpfcgc);
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, carregando informa&ccedil;&otilde;es ...');
	
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/alerta/principal.php',
		data: {
			cddopcao: cddopcao,
			consucpf: consucpf,
			consupes: consupes,
			nriniseq: nriniseq,
			nrregist: nrregist,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabAlerta').focus()");							
		},
		success: function(response) {			
			
				hideMsgAguardo();
				
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divDetalhes').html(response);
						return false;
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
					}
				} else {
					try {
						eval( response );
						
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
					}
				}
				
		}		
	});
	
	
}


function controlaLayout(op){

	$("#divRelatorio","#frmOpcoesConsulta").css('display','none');
	$("#divNomeCpf","#frmOpcoesConsulta").css('display','none');
				
	switch(op) {
	
		//Opcoes de Consulta
		case "C":
		
				$("#divNomeCpf","#frmOpcoesConsulta").css('display','block');
				highlightObjFocus( $('#divOpcoesConsulta') );
				$('#divOpcoesConsulta').css('display','block');
				$('#frmOpcoesConsulta').css('display','block');
				$('input[name=tppesqui]','#divOpcoesConsulta')[0].focus();
				$('#divBotoes','#divOpcoesConsulta').css('display','block');
				$('#btVoltar','#divOpcoesConsulta').show();
		
		break;
		
		//Excluir
		case "E":
		
				$("#divNomeCpf","#frmOpcoesConsulta").css('display','block');
				highlightObjFocus( $('#divOpcoesConsulta') );
				$('#divOpcoesConsulta').css('display','block');
				$('#frmOpcoesConsulta').css('display','block');
				$('input[name=tppesqui]','#divOpcoesConsulta')[0].focus();
				$('#divBotoes','#divOpcoesConsulta').css('display','block');
				$('#btVoltar','#divOpcoesConsulta').show();
		
		break;
	
	
		//Incluir
		case 'I':
		
				highlightObjFocus( $('#divDetalhes') );
				$('#divDetalhes').css('display','block');
				$('#divBotoesIncluir').css('display','block');
				$('#frmIncluir').css('display','block');
				$('input,textarea,select','#frmIncluir').habilitaCampo();
				$('#nmextcop','#frmIncluir').desabilitaCampo();
				$('#nmextbcc','#frmIncluir').desabilitaCampo();
				
		break;
		
		//Liberar
		case 'L':
		
				highlightObjFocus( $('#divDetalhes') );
				$('#divDetalhes').css('display','block');
				$('#divBotoesLiberar').css('display','block');
				$('#frmLiberar').css('display','block');
				$('#cdcopsol','#divDetalhes').focus();
		
		break;
		
		//Gera relarótio de justificativas
		case "R":
					
				highlightObjFocus( $('#divOpcoesConsulta') );
				$("#divRelatorio","#frmOpcoesConsulta").css('display','block');	
				$('#divOpcoesConsulta').css('display','block');
				$('#frmOpcoesConsulta').css('display','block');
				$('input[name=tppesqui]','#divOpcoesConsulta')[0].focus();
				$('#divBotoes','#divOpcoesConsulta').css('display','block');
				$('#btVoltar','#divOpcoesConsulta').show();
		
		break;
		
		//Vinculos
		case "V":
		
				highlightObjFocus( $('#divDetalhes') );
				$('#divDetalhes').css('display','block');
				$('#frmVinculos').css('display','block');
				$('#nrcpfcgc','#frmVinculos').focus();
				$('#divBotoesVinculos').css('display','block');
		
		break;
			
		//Volta Div - Chamado na consulta e na exclusão; vai escondendo os divs que estão em block
		case 'V1':
			
			if( $('#frmExcluir').css('display') == 'block' ){
			
				$('#frmExcluir').css('display','none');
				$('#divTabela').css('display','block');
				$('#divBotoesExcluir').css('display','none');
			
			
			}else if( $('#frmConsulta').css('display') == 'block' ){
				
				$('#frmConsulta').css('display','none');
				$('#divTabela').css('display','block');
				$('#divBotoesConsulta').css('display','none');
							
			}else if( $('#divTabela').css('display') == 'block' ){
			
					  $('#divTabela').css('display','none');
					  $("#divOpcoesConsulta").css("display","block")
					  $('#consupes','#divNome').val('');
					  $('#consucpf','#divCpf').val('');
				
			} else if( $('#divOpcoesConsulta').css('display') == 'block'){
			
					  estadoInicial();
					  $('#cddopcao','#frmCabAlerta').habilitaCampo().focus();
					  
			}
		
		break;
										
	}
		
}

function formataCabecalho(){

	$('label[for="cddopcao"]','#frmCabAlerta').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCabAlerta').css('width','465px').habilitaCampo();
	$('#divTela').fadeTo(0,0.1);
	removeOpacidade('divTela');		
	$('#frmCabAlerta').css('display','block');
		
	//Ao pressionar botao cddopcao
	$('#cddopcao','#frmCabAlerta').unbind('keypress').bind('keypress', function(e){
	
		// Se é a tecla ENTER, F1
		if ( e.keyCode == 13  || e.keyCode == 18) {	
			
			estadoInicial();
			$('#cddopcao','#frmCabAlerta').desabilitaCampo();
						
			if($(this).val() == "C" || $(this).val() == "E" || $(this).val() == "R"){
				
				controlaLayout($(this).val());
				
			}else{
			
				controlaOperacao($(this).val());
			}
			
		}
						
	});
	
	//Ao clicar no botao OK
	$('#btOK','#frmCabAlerta').unbind('click').bind('click', function(){
	
		estadoInicial();
		$('#cddopcao','#frmCabAlerta').desabilitaCampo();
		
		if(!controlaAcessoOperacoes()){
			return false;
		}
				
		if($('#cddopcao','#frmCabAlerta').val() == "C" || $('#cddopcao','#frmCabAlerta').val() == "E" || $('#cddopcao','#frmCabAlerta').val() == "R" ){
							
			controlaLayout($('#cddopcao','#frmCabAlerta').val());
			
		}else{
		
			controlaOperacao($('#cddopcao','#frmCabAlerta').val());
		}
						
	});
	
	//Ao pressionar botao OK
	$('#btOK','#frmCabAlerta').unbind('keypress').bind('keypress', function(e){
	
		// Se é a tecla ENTER, F1
		if ( e.keyCode == 13  || e.keyCode == 18) {	
			
			estadoInicial();
			$('#cddopcao','#frmCabAlerta').desabilitaCampo();
			
			if(!controlaAcessoOperacoes()){
				return false;
			}
			
			if($('#cddopcao','#frmCabAlerta').val() == "C" || $('#cddopcao','#frmCabAlerta').val() == "E" || $('#cddopcao','#frmCabAlerta').val() == "R" ){
				
				controlaLayout($('#cddopcao','#frmCabAlerta').val());
				
			}else{
			
				controlaOperacao($('#cddopcao','#frmCabAlerta').val());
			}
				
		}
					
	});
	
}

//Funcao para limpar campos dos formulários 
function limpaCampos(op) {
	
	switch(op){
	
		case "C":
			
			//Form Consulta
			$('#detsitua','#frmConsula').val('');
			$('#nrcpfcgc','#frmConsula').val('');
			$('#nmpessoa','#frmConsula').val('');
			$('#cdbccxlt','#frmConsula').val('');
			$('#nmextbcc','#frmConsula').val('');
			$('#nmpessol','#frmConsula').val('');
			$('#dtinclus','#frmConsula').val('');
			$('#dsjusinc','#frmConsula').val('');
			$('#nmcopinc','#frmConsula').val('');
			$('#dtexclus','#frmConsula').val('');
			$('#nmcopexc','#frmConsula').val('');
			$('#dsjusexc','#frmConsula').val('');
			
		
		break;
	
		case "E":
		
			//Form Excluir
			$('#detsitua','#frmExcluir').val('');
			$('#nrcpfcgc','#frmExcluir').val('');
			$('#nmpessoa','#frmExcluir').val('');
			$('#cdbccxlt','#frmExcluir').val('');
			$('#nmextbcc','#frmExcluir').val('');
			$('#nmpessol','#frmExcluir').val('');
			$('#dtinclus','#frmExcluir').val('');
			$('#dsjusinc','#frmExcluir').val('');
			$('#nmcopinc','#frmExcluir').val('');
			$('#dsjusexc','#frmExcluir').val('');
		
		break;
		
		case "I":
			
			//Form de Incluir
			$('#nrcpfcgc','#frmIncluir').val('').focus();
			$('#nmpessoa','#frmIncluir').val('');
			$('#cdbccxlt','#frmIncluir').val('');
			$('#nmextbcc','#frmIncluir').val('');
			$('#cdcopsol','#frmIncluir').val('');
			$('#nmextcop','#frmIncluir').val('');
			$('#nmpessol','#frmIncluir').val('');
			$('#dsjusinc','#frmIncluir').val('');
			$('#dsmotexc','#frmIncluir').val('');
		
		break;

		
		case "L":
		
			//Form Liberar
			$('#cdcopsol','#frmLiberar').val('').focus();
			$('#nmextcop','#frmLiberar').val('');
			$('#cdagepac','#frmLiberar').val('');
			$('#nmresage','#frmLiberar').val('');
			$('#cdopelib','#frmLiberar').val('');
			$('#nmoperad','#frmLiberar').val('');
			$('#nrdconta','#frmLiberar').val('');
			$('#dsjuslib','#frmLiberar').val('');
			$('#cdoperac','#frmLiberar').val('');
			$('#dsoperac','#frmLiberar').val('');
						
		break;
		
		//Form Vinculos
		case "V":

			$('#nrcpfcgc','#frmVinculos').val('').focus();

		break;
				
	}
		
	return false;
	
}

function formataOpcoesConsulta(){

	//Label do form de Opcoes de Consulta
	rTprelato  = $('label[for="tprelato"]','#frmOpcoesConsulta');
	rTppesqi   = $('label[for="tppesqui"]','#frmOpcoesConsulta');
	rCpfcnpj   = $('label[for="cpfcgcRadio"]','#frmOpcoesConsulta');
	rNome      = $('label[for="nomeRadio"]','#frmOpcoesConsulta');
	rConsucpf  = $('label[for="consucpf"]','#frmOpcoesConsulta');
	rConsupes  = $('label[for="consupes"]','#frmOpcoesConsulta');
	rDtinicio  = $('label[for="dtinicio"]','#frmOpcoesConsulta');
	rDtdfinal  = $('label[for="dtdfinal"]','#frmOpcoesConsulta');
	
	rTprelato.css('width', '75px').addClass('rotulo');
	rTppesqi.css('width', '180px').addClass('rotulo');
	rCpfcnpj.css('width', '110px').addClass('rotulo').css('text-align','left');
	rNome.css('width', '30px').addClass('rotulo');
	rConsucpf.css('width', '180px').addClass('rotulo');
	rConsupes.css('width', '180px').addClass('rotulo');
	rDtinicio.css('width', '80px').addClass('rotulo');
	rDtdfinal.css('width', '80px');
	
	
	//Campos do form de Opcoes de Consulta
	cCpfcnpj    = $('#cpfcgc','#frmOpcoesConsulta');
	cNome       = $('#nome','#frmOpcoesConsulta');
	cConsupes   = $('#consupes','#frmOpcoesConsulta');
	cConsucpf   = $('#consucpf','#frmOpcoesConsulta');
	cTodosRadio = $('[type=radio]','#frmOpcoesConsulta');
	cTprelato   = $('#tprelato','#frmOpcoesConsulta');
	cDtinicio   = $("#dtinicio","#frmOpcoesConsulta");
	cDtdfinal   = $("#dtdfinal","#frmOpcoesConsulta");
	

	cTodosRadio.css('width','30px').css('height','100%');
	cConsupes.addClass('alphanum').addClass('alpha').css('width','300px').attr('maxlength','50');
	cConsucpf.addClass('inteiro').css('width','170px').attr('maxlength','18');
	cTprelato.addClass('campo').css('width','410px');
	cDtinicio.addClass('campo').css('width','75px');
	cDtdfinal.addClass('campo').css('width','75px');
	
	
	// Se pressionar cConsucpf
	cConsucpf.unbind('keypress').bind('keypress', function(e){ 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER, F1
		if ( e.keyCode == 13  || e.keyCode == 18) {		
		
			$(this).removeClass('campoErro');
					
			var cpfCnpj = normalizaNumero($('#consucpf','#frmOpcoesConsulta').val());
			
			if(cpfCnpj.length <= 11){	
				cConsucpf.val(mascara(cpfCnpj,'###.###.###-##'));
			}else{
				cConsucpf.val(mascara(cpfCnpj,'##.###.###/####-##'));
			}
			
			controlaOperacao($('#cddopcao','#frmCabAlerta').val(),1,30);
			
			return false;
			
		}
										
	});		
	
	// Se pressionar cConsupes
	cConsupes.unbind('keypress').bind('keypress', function(e){ 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER, F1
		if ( e.keyCode == 13  || e.keyCode == 18) {		
					
			controlaOperacao($('#cddopcao','#frmCabAlerta').val(),1,30);
			
			return false;
			
		}
										
	});	
	
	
	//Ao clicar no radio CPF - Controla exibicao dos campos para consulta
	cCpfcnpj.unbind('click').bind('click',function() {
	
		$('#divNome').css('display','none');
		$('#divCpf').css('display','block');
		$('#consucpf','#divCpf').val('').focus();
		$('#divBotoes','#divOpcoesConsulta').css('display','block');
		$('#btConsulta','#divOpcoesConsulta').show();
										
	});	
	
	//Ao clicar no radio Nome - Controla exibicao dos campos para consulta
	cNome.unbind('click').bind('click',function() {
	
		$('#divCpf').css('display','none');
		$('#divNome').css('display','block');
		$('#consupes','#divNome').val('').focus();
		$('#divBotoes','#divOpcoesConsulta').css('display','block');
		$('#btConsulta','#divOpcoesConsulta').show();
		
	});	
	
	cTprelato.unbind('keypress').bind('keypress', function (e) {
		
		if ( e.keyCode == 13 || e.keyCode == 18) {
			mostraOpcoesRelatorios($(this).val());
		}
		
	});
	
	//Ao pressionar botao OK
	$('#btOKRel','#frmOpcoesConsulta').unbind('click').bind('click', function(e){		
		mostraOpcoesRelatorios(cTprelato.val());
	});
	
	return false;
	
}

function formataConsulta(){

	//Variáveis do formulário Consulta
	rDetsitua = $('label[for="detsitua"]','#frmConsulta');
	rNrcpfcgc = $('label[for="nrcpfcgc"]','#frmConsulta');
	rNmpessoa = $('label[for="nmpessoa"]','#frmConsulta');
	rTporigem = $('label[for="tporigem"]','#frmConsulta');
	rNmpessol = $('label[for="nmpessol"]','#frmConsulta');
	rCdbccxlt = $('label[for="cdbccxlt"]','#frmConsulta');
	rNmextbcc = $('label[for="nmextbcc"]','#frmConsulta');
	rDtinclus = $('label[for="dtinclus"]','#frmConsulta');
	rDsjusinc = $('label[for="dsjusinc"]','#frmConsulta');
	rNmcopinc = $('label[for="nmcopinc"]','#frmConsulta');
	rDtexclus = $('label[for="dtexclus"]','#frmConsulta');
	rNmcopexc = $('label[for="nmcopexc"]','#frmConsulta');
	rDsjusexc = $('label[for="dsjusexc"]','#frmConsulta');
	
	//Label do form de Consulta
	rDetsitua.css('width', '175px').addClass('rotulo');
	rNrcpfcgc.css('width', '175px').addClass('rotulo');
	rNmpessoa.css('width', '175px').addClass('rotulo');
	rTporigem.css('width', '175px').addClass('rotulo');
	rNmpessol.css('width', '175px').addClass('rotulo');
	rCdbccxlt.css('width', '175px').addClass('rotulo');
	rNmextbcc.addClass('rotulo-linha');
	rDtinclus.css('width', '175px').addClass('rotulo');
	rDsjusinc.css('width', '175px').addClass('rotulo');
	rNmcopinc.css('width', '175px').addClass('rotulo');
	rDtexclus.css('width', '175px').addClass('rotulo');
	rNmcopexc.css('width', '175px').addClass('rotulo');
	rDsjusexc.css('width', '175px').addClass('rotulo');
	
	//Campos do form Consulta
	cDetsitua = $('#detsitua','#frmConsulta');
	cNrcpfcgc = $('#nrcpfcgc','#frmConsulta');
	cNmpessoa = $('#nmpessoa','#frmConsulta');
	cTporigem = $('#tporigem','#frmConsulta');
	cNmpessol = $('#nmpessol','#frmConsulta');
	cCdbccxlt = $('#cdbccxlt','#frmConsulta');
	cNmextbcc = $('#nmextbcc','#frmConsulta');
	cDtinclus = $('#dtinclus','#frmConsulta');
	cDsjusinc = $('#dsjusinc','#frmConsulta');
	cNmcopinc = $('#nmcopinc','#frmConsulta');
	cDtexclus = $('#dtexclus','#frmConsulta');
	cNmcopexc = $('#nmcopexc','#frmConsulta');
	cDsjusexc = $('#dsjusexc','#frmConsulta');
		
	cDetsitua.css('width','310px').attr('maxlength','14');
	cNrcpfcgc.css('width','310px').attr('maxlength','14');
	cNmpessoa.css('width','310px').attr('maxlength','50');
	cTporigem.css('width','100px');
	cNmpessol.css('width','310px').attr('maxlength','60');
	cCdbccxlt.css('width','35px').attr('maxlength','50');
	cNmextbcc.css('width','250px').attr('maxlength','50');
	cDtinclus.css('width','310px').attr('maxlength','25');
	cNmcopinc.css('width','310px').attr('maxlength','60');
	cDtexclus.css('width','310px').attr('maxlength','60');
	cNmcopexc.css('width','310px').attr('maxlength','25');
	
	
	if($.browser.msie){
		cDsjusexc.addClass('alphanum').css('width','310px').css('overflow-y','scroll').css('overflow-x','hidden').css('height','70').setMask("STRING","60",charPermitido(),"");
		cDsjusinc.addClass('alphanum').css('width','310px').css('overflow-y','scroll').css('overflow-x','hidden').css('height','70').setMask("STRING","60",charPermitido(),"");	
		
	}else{
		cDsjusexc.addClass('alphanum').css('width','310px').css('overflow-y','scroll').css('overflow-x','hidden').css('height','70').css('margin-left','3').setMask("STRING","60",charPermitido(),"");	
		cDsjusinc.addClass('alphanum').css('width','310px').css('overflow-y','scroll').css('overflow-x','hidden').css('height','70').css('margin-left','3').setMask("STRING","60",charPermitido(),"");	
		
	}	
		
	cTodosDetalhes = $('input,select','#frmConsulta');			
	cTodosDetalhes.desabilitaCampo();
	cDsjusinc.desabilitaCampo();
	cDsjusexc.desabilitaCampo();
	
	
	// Se pressionar dsjusexc
	$('#dsjusexc','#frmConsulta').unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, F1
		if ( e.keyCode == 13 || e.keyCode == 18) {
		
			$('input,select','#frmConsulta').removeClass('campoErro');
			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','excluir();','controlaLayout(\'V1\');','sim.gif','nao.gif');
			return false;
		
		}
		
	});		
	
	layoutPadrao();	
	
	return false;

}


function formataIncluir() {

	// Variáveis do formulário Inclusão
	rNrcpfcgc = $('label[for="nrcpfcgc"]','#frmIncluir');
	rNmpessoa = $('label[for="nmpessoa"]','#frmIncluir');
	rTporigem = $('label[for="tporigem"]','#frmIncluir');
	rCdbccxlt = $('label[for="cdbccxlt"]','#frmIncluir');
	rNmextbcc = $('label[for="nmextbcc"]','#frmIncluir');
	rCdcopsol = $('label[for="cdcopsol"]','#frmIncluir');
	rNmpessol = $('label[for="nmpessol"]','#frmIncluir');
	rDsjusinc = $('label[for="dsjusinc"]','#frmIncluir');
	
	
    //Label do form de Inclusão	
	rNrcpfcgc.css('width', '155px').addClass('rotulo');
	rNmpessoa.css('width', '155px').addClass('rotulo');
	rTporigem.css('width', '155px').addClass('rotulo');
	rCdbccxlt.css('width', '155px').addClass('rotulo');
	rNmextbcc.addClass('rotulo-linha');
	rCdcopsol.css('width', '155px').addClass('rotulo');
	rNmpessol.css('width', '155px').addClass('rotulo');
	rDsjusinc.css('width', '155px').addClass('rotulo');
	
		
	//Campos do form de Inclusão
	cNrcpfcgc = $('#nrcpfcgc','#frmIncluir');
	cNmpessoa = $('#nmpessoa','#frmIncluir');
	cTporigem = $('#tporigem','#frmIncluir'); 
	cCdbccxlt = $('#cdbccxlt','#frmIncluir');
	cNmextbcc = $('#nmextbcc','#frmIncluir'); 
	cCdcopsol = $('#cdcopsol','#frmIncluir');
	cNmpessol = $('#nmpessol','#frmIncluir');
	cDsjusinc = $('#dsjusinc','#frmIncluir');
	
	cNrcpfcgc.css('width','310px').addClass('inteiro').attr('maxlength','18');
	cNmpessoa.addClass('alphanum').addClass('alpha').css('width','310px').attr('maxlength','50');
	cTporigem.css('width','100px');
	cCdbccxlt.css('width','35px').attr('maxlength','50');
	cNmextbcc.css('width','250px').attr('maxlength','50');
	cCdcopsol.css('width','310px');
	cNmpessol.addClass('alphanum').addClass('alpha').css('width','310px').attr('maxlength','50');
			
	cCdcopsol.html( slcooper );		
			
	if($.browser.msie){
		cDsjusinc.addClass('alphanum').css('width','310px').css('overflow-y','scroll').css('overflow-x','hidden').css('height','70').setMask("STRING","60",charPermitido(),"");	
		
	}else{
		cDsjusinc.addClass('alphanum').css('width','310px').css('overflow-y','scroll').css('overflow-x','hidden').css('height','70').css('margin-left','3').setMask("STRING","60",charPermitido(),"");
		
	}	
		
	
	// Se pressionar cNrcpfcgc
	cNrcpfcgc.unbind('keypress').bind('keypress', function(e){ 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13  || e.keyCode == 9 || e.keyCode == 18) {		
		
			$(this).removeClass('campoErro');
			cNmpessoa.focus();
			
			var cpfCnpj = normalizaNumero($('#nrcpfcgc','#frmIncluir').val());
			
			if(cpfCnpj.length <= 11){	
				cNrcpfcgc.val(mascara(cpfCnpj,'###.###.###-##'));
			}else{
				cNrcpfcgc.val(mascara(cpfCnpj,'##.###.###/####-##'));
			}
										
			return false;
			
		}
										
	});		
		
	
	// Se pressionar cNmpessoa
	cNmpessoa.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {
		
			$(this).removeClass('campoErro');
			cTporigem.focus();
			
			return false;
		
		}
		
	});		
	
	// Se pressionar cTporigem
	cTporigem.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {
		
			$(this).removeClass('campoErro');
			cCdbccxlt.focus();
			
			return false;
		
		}
		
	});		
	
		
	// Se pressionar cNmpessol
	cNmpessol.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18 ) {
		
			$(this).removeClass('campoErro');
			cDsjusinc.focus();		
			return false;
		
		}
				
	});		
	
	// Se pressionar cDsjusinc
	cDsjusinc.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, F1
		if ( e.keyCode == 13 || e.keyCode == 18) {
		
			$(this).removeClass('campoErro');
			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','incluir();','','sim.gif','nao.gif');
			return false;
		
		}
		
	});	
	
	controlaPesquisasIncluir();
	layoutPadrao();	
	
	return false;
	
}


function formataExcluir(){

	//Variáveis do formulário Detalhes
	rNrcpfcgc = $('label[for="nrcpfcgc"]','#frmExcluir');
	rNmpessoa = $('label[for="nmpessoa"]','#frmExcluir');
	rTporigem = $('label[for="tporigem"]','#frmExcluir');
	rNmpessol = $('label[for="nmpessol"]','#frmExcluir');
	rCdbccxlt = $('label[for="cdbccxlt"]','#frmExcluir');
	rNmextbcc = $('label[for="nmextbcc"]','#frmExcluir');
	rDtinclus = $('label[for="dtinclus"]','#frmExcluir');
	rDsjusinc = $('label[for="dsjusinc"]','#frmExcluir');
	rNmcopinc = $('label[for="nmcopinc"]','#frmExcluir');
	rDsjusexc = $('label[for="dsjusexc"]','#frmExcluir');
	
	//Label do form de Detalhes
	rNrcpfcgc.css('width', '175px').addClass('rotulo');
	rNmpessoa.css('width', '175px').addClass('rotulo');
	rTporigem.css('width', '175px').addClass('rotulo');
	rNmpessol.css('width', '175px').addClass('rotulo');
	rCdbccxlt.css('width', '175px').addClass('rotulo');
	rNmextbcc.addClass('rotulo-linha');
	rDtinclus.css('width', '175px').addClass('rotulo');
	rDsjusinc.css('width', '175px').addClass('rotulo');
	rNmcopinc.css('width', '175px').addClass('rotulo');
	rDsjusexc.css('width', '175px').addClass('rotulo');
	
	//Campos do form Detalhes
	cNrcpfcgc = $('#nrcpfcgc','#frmExcluir');
	cNmpessoa = $('#nmpessoa','#frmExcluir');
	cTporigem = $('#tporigem','#frmExcluir');
	cNmpessol = $('#nmpessol','#frmExcluir');
	cCdbccxlt = $('#cdbccxlt','#frmExcluir');
	cNmextbcc = $('#nmextbcc','#frmExcluir');
	cDtinclus = $('#dtinclus','#frmExcluir');
	cDsjusinc = $('#dsjusinc','#frmExcluir');
	cNmcopinc = $('#nmcopinc','#frmExcluir');
	cDsjusexc = $('#dsjusexc','#frmExcluir');
		
	cNrcpfcgc.css('width','310px').attr('maxlength','14');
	cNmpessoa.css('width','310px').attr('maxlength','50');
	cTporigem.css('width','100px');
	cNmpessol.css('width','310px').attr('maxlength','60');
	cCdbccxlt.css('width','35px').attr('maxlength','50');
	cNmextbcc.css('width','250px').attr('maxlength','50');
	cDtinclus.css('width','310px').attr('maxlength','25');
	cNmcopinc.css('width','310px').attr('maxlength','60');
	
	
	if($.browser.msie){
		cDsjusexc.addClass('alphanum').css('width','310px').css('overflow-y','scroll').css('overflow-x','hidden').css('height','70').setMask("STRING","60",charPermitido(),"");
		cDsjusinc.addClass('alphanum').css('width','310px').css('overflow-y','scroll').css('overflow-x','hidden').css('height','70').setMask("STRING","60",charPermitido(),"");
		
	}else{
		cDsjusexc.addClass('alphanum').css('width','310px').css('overflow-y','scroll').css('overflow-x','hidden').css('height','70').css('margin-left','3').setMask("STRING","60",charPermitido(),"");
		cDsjusinc.addClass('alphanum').css('width','310px').css('overflow-y','scroll').css('overflow-x','hidden').css('height','70').css('margin-left','3').setMask("STRING","60",charPermitido(),"");
		
	}	
		
	cTodosDetalhes = $('input,select','#frmExcluir');			
	cTodosDetalhes.desabilitaCampo();
	cDsjusinc.desabilitaCampo();
	cDsjusexc.habilitaCampo();
	
	
	// Se pressionar dsjusexc
	$('#dsjusexc','#frmExcluir').unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, F1
		if ( e.keyCode == 13 || e.keyCode == 18) {
		
			$(this).removeClass('campoErro');
			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','excluir();','controlaLayout(\'V1\');','sim.gif','nao.gif');
			return false;
		
		}
		
	});		
	
	layoutPadrao();	
	
	return false;

}

function formataLiberar(){

	//Variáveis do formulário Liberar
	rCdcopsol = $('label[for="cdcopsol"]','#frmLiberar');
	rCdagepac = $('label[for="cdagepac"]','#frmLiberar');
	rNmresage = $('label[for="nmresage"]','#frmLiberar');
	rCdopelib = $('label[for="cdopelib"]','#frmLiberar');
	rNmoperad = $('label[for="nmoperad"]','#frmLiberar');
	rNrdconta = $('label[for="nrdconta"]','#frmLiberar');
	rNrcpfcgc = $('label[for="nrcpfcgc"]','#frmLiberar');
	rCdoperac = $('label[for="cdoperac"]','#frmLiberar');
	rDsoperac = $('label[for="dsoperac"]','#frmLiberar');
	rDsjuslib = $('label[for="dsjuslib"]','#frmLiberar');
	
	
	//Label do form de Liberar
	rCdcopsol.css('width', '175px').addClass('rotulo');
	rCdagepac.css('width', '175px').addClass('rotulo');
	rNmresage.addClass('rotulo-linha');
	rCdopelib.css('width', '175px').addClass('rotulo');
	rNmoperad.addClass('rotulo-linha');
	rNrdconta.css('width', '175px').addClass('rotulo');
	rNrcpfcgc.css('width', '60px').addClass('rotulo-linha');
	rCdoperac.css('width', '175px').addClass('rotulo');
	rDsoperac.addClass('rotulo-linha');
	rDsjuslib.css('width', '175px').addClass('rotulo');
		
	
	//Campos do form Liberar
	cCdcopsol = $('#cdcopsol','#frmLiberar');
	cCdagepac = $('#cdagepac','#frmLiberar');
	cNmresage = $('#nmresage','#frmLiberar');
	cCdopelib = $('#cdopelib','#frmLiberar');
	cNmoperad = $('#nmoperad','#frmLiberar');
	cNrdconta = $('#nrdconta','#frmLiberar');
	cNrcpfcgc = $('#nrcpfcgc','#frmLiberar');
	cCdoperac = $('#cdoperac','#frmLiberar');
	cDsoperac = $('#dsoperac','#frmLiberar');
	cDsjuslib = $('#dsjuslib','#frmLiberar');
	
	
	cCdcopsol.css('width','335px');
	cCdagepac.css('width','35px');
	cNmresage.css('width','275px');
	cCdopelib.css('width','100px').attr('maxlength','15');
	cNmoperad.css('width','210px');
	cNrdconta.css({'width':'100px','text-align':'right'});
	cNrcpfcgc.css('width','168px').addClass('inteiro').attr('maxlength','18');
	cCdoperac.css('width','35px').attr('maxlength','6');
	cDsoperac.css('width','275px');
	
	cCdcopsol.html( slcooper );	
	
	if($.browser.msie){
		cDsjuslib.addClass('alphanum').css('width','335px').css('overflow-y','scroll').css('overflow-x','hidden').css('height','70').setMask("STRING","50",charPermitido(),"");		
		
	}else{
		cDsjuslib.addClass('alphanum').css('width','335px').css('overflow-y','scroll').css('overflow-x','hidden').css('height','70').css('margin-left','3px').setMask("STRING","50",charPermitido(),"");
		
	}
	
	cTodosLiberar = $('input,textarea,select','#divDetalhes');
	cTodosLiberar.habilitaCampo();
	cNmresage.desabilitaCampo();
	cNmoperad.desabilitaCampo();
	cDsoperac.desabilitaCampo();		
			
	
	// Evento onKeyUp no campo cNrdconta
	cNrdconta.bind("keyup",function(e) { 
	
		// Seta máscara ao campo
		if (!$(this).setMaskOnKeyUp("INTEGER","zzzz.zzz-z","",e)) {
			return false;
		}
				
	});
	
	// Evento onKeyDown no campo cNrdconta
	cNrdconta.bind("keydown",function(e) {
										
		// Seta máscara ao campo
		return $(this).setMaskOnKeyDown("INTEGER","zzzz.zzz-z","",e);
		
	});
	
	// Evento onBlur no campo cNrdconta
	cNrdconta.bind("blur",function() {
				
		if ($(this).val() == "") {
			return true;
		}
				
		// Valida número da conta
		if (!validaNroConta(retiraCaracteres($(this).val(),"0123456789",true))) {
		
			showError("error","Conta/dv inv&aacute;lida.","Alerta - Ayllos","$('#nrdconta','#frmLiberar').focus()");
			return false;
		}
		
		return true;
	});
	
	// Se pressionar cNrdconta
	cNrdconta.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18 ) {
			$(this).removeClass('campoErro');
				
			cNrcpfcgc.focus();
			return false;
		
		}
				
	});		
	
	// Se pressionar cNrcpfcgc
	cNrcpfcgc.unbind('keypress').bind('keypress', function(e){ 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13  || e.keyCode == 9 || e.keyCode == 18) {		
		
			$(this).removeClass('campoErro');
					
			var cpfCnpj = normalizaNumero($('#nrcpfcgc','#frmLiberar').val());
			
			if(cpfCnpj.length <= 11){	
				cNrcpfcgc.val(mascara(cpfCnpj,'###.###.###-##'));
			}else{
				cNrcpfcgc.val(mascara(cpfCnpj,'##.###.###/####-##'));
			}
			
			cCdoperac.focus();			
			return false;
			
		}
										
	});	
	
	// Se pressionar cDsjuslib
	cDsjuslib.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
			// Se é a tecla ENTER, F1
			if ( e.keyCode == 13 || e.keyCode == 18 ) {

				$(this).removeClass('campoErro');
				showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','liberar();','','sim.gif','nao.gif');		
				return false;
			
			}
						
	});		
		
	controlaPesquisasLiberar();
	layoutPadrao();	
	
	return false;

}


function formataVinculos(){

	//Label do form Vinculos
	rNrcpfcgc = $('label[for="nrcpfcgc"]','#frmVinculos');
	rNrcpfcgc.css('width', '280px').addClass('rotulo');
		
	//Campos do form Vinculos
	cNrcpfcgc = $('#nrcpfcgc','#frmVinculos');
	cNrcpfcgc.addClass('inteiro').css('width','170px').attr('maxlength','18');
	
	
	// Se pressionar cNrcpfcgc
	cNrcpfcgc.unbind('keypress').bind('keypress', function(e){ 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER, F1
		if ( e.keyCode == 13  || e.keyCode == 18) {		
		
			$(this).removeClass('campoErro');
					
			var cpfCnpj = normalizaNumero($('#nrcpfcgc','#frmVinculos').val());
			
			if(cpfCnpj.length <= 11){	
				cNrcpfcgc.val(mascara(cpfCnpj,'###.###.###-##'));
			}else{
				cNrcpfcgc.val(mascara(cpfCnpj,'##.###.###/####-##'));											   
			}
			
			consultaVinculo('C',$('#nrcpfcgc','#frmVinculos').val(),1,30);
			
			return false;
			
		}
										
	});		
	
	layoutPadrao();	
	
	return false;
	
}



//Funcao para formatar a tabela com as ocorrências encontradas na consulta
function tabela(op){

	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
		
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table',divRegistro );	
	var linha		= $('table > tbody > tr', divRegistro );
									
	divRegistro.css({'height':'150px'});
			
	var ordemInicial = new Array();
		ordemInicial = [[1,0]];		
			
	var arrayLargura = new Array(); 
		arrayLargura[0] = '80px';
		arrayLargura[1] = '75px';
		arrayLargura[2] = '210px';
							
	var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'left';
		arrayAlinha[3] = 'right';
				
	var metodoTabela = '';
				
	tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,metodoTabela);			
				
			
	//Seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaRegistro($(this),op);
		
	});					
	
	$('#divRegistros').css('display','block');
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();		
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		controlaOperacao($('#cddopcao','#frmCabAlerta').val(),(nriniseq - nrregist),nrregist);
	
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		controlaOperacao($('#cddopcao','#frmCabAlerta').val(),(nriniseq + nrregist),nrregist);

	});		
		
}

//Funcao para formatar a tabela de vinculos
function tabelaVinculo(){
	
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
		
	var divRegistro = $('div.divRegistros','#divUsoGenerico');		
	var tabela      = $('table',divRegistro );	
	var linha		= $('table > tbody > tr', divRegistro );
									
	divRegistro.css({'height':'150px'});
			
	var ordemInicial = new Array();
		ordemInicial = [[1,0]];		
			
		
	var arrayLargura = new Array(); 
		arrayLargura[0] = '90px';
		arrayLargura[1] = '70px';
		arrayLargura[2] = '140px';
		arrayLargura[3] = '85px';
		arrayLargura[4] = '115px';
		arrayLargura[5] = '140px';
		arrayLargura[6] = '90px';
						
							
	var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'left';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'left';
		arrayAlinha[6] = 'left';
		
		
				
	var metodoTabela = '';
				
	tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,metodoTabela);			
		
	$('#divUsoGenerico').css('width','860px');
	$('#divRegistros','#divUsoGenerico').css('display','block');
	$('#divRegistrosRodape','#divUsoGenerico').formataRodapePesquisa();		
		
}


//Funcao para selecionar um registro para listar os detalhes de uma ocorrência
function selecionaRegistro(tr,op){	
	
	if(op == "C"){
		
		limpaCampos(op);
		
		$('#nrcpfcgc','#frmConsulta').val( $('#nrcpfcgc', tr ).val() );
		$('#detsitua','#frmConsulta').val( $('#detsitua', tr ).val() );
		$('#nmpessoa','#frmConsulta').val( $('#nmpessoa', tr ).val() );
		$('#nmpessol','#frmConsulta').val( $('#nmpessol', tr ).val() );
		$('#dtinclus','#frmConsulta').val( $('#dtinclus', tr ).val() );
		$('#dsjusinc','#frmConsulta').val( $('#dsjusinc', tr ).val() );
		$('#nmcopinc','#frmConsulta').val( $('#nmcopinc', tr ).val() );
		$('#dtexclus','#frmConsulta').val( $('#dtexclus', tr ).val() );
		$('#nmcopexc','#frmConsulta').val( $('#nmcopexc', tr ).val() );
		$('#dsjusexc','#frmConsulta').val( $('#dsjusexc', tr ).val() );
		$('#tporigem','#frmConsulta').val( $('#tporigem', tr ).val() );
		$('#cdbccxlt','#frmConsulta').val( $('#cdbccxlt', tr ).val() );
		$('#nmextbcc','#frmConsulta').val( $('#nmextbcc', tr ).val() );
		nrregres = $('#nrregres', tr ).val();
		
		$('#divTabela').css('display','none');
		$('#divDetalhes').css('display','block');
		$('#frmConsulta','#divDetalhes').css('display','block'); 
		$('#divBotoesConsulta').css('display','block');
				
		$('#btVoltar','#divBotoesConsulta').show();
		$('#btExcluir','#divBotoesConsulta').hide();	
		
	} else{
	
		limpaCampos(op);
		
		$('#nrcpfcgc','#frmExcluir').val( $('#nrcpfcgc', tr ).val() );
		$('#detsitua','#frmExcluir').val( $('#detsitua', tr ).val() );
		$('#nmpessoa','#frmExcluir').val( $('#nmpessoa', tr ).val() );
		$('#nmpessol','#frmExcluir').val( $('#nmpessol', tr ).val() );
		$('#dtinclus','#frmExcluir').val( $('#dtinclus', tr ).val() );
		$('#dsjusinc','#frmExcluir').val( $('#dsjusinc', tr ).val() );
		$('#nmcopinc','#frmExcluir').val( $('#nmcopinc', tr ).val() );
		
		$('#dsjusexc','#frmExcluir').val( $('#dsjusexc', tr ).val() );
		$('#tporigem','#frmExcluir').val( $('#tporigem', tr ).val() );
		$('#cdbccxlt','#frmExcluir').val( $('#cdbccxlt', tr ).val() );
		$('#nmextbcc','#frmExcluir').val( $('#nmextbcc', tr ).val() );
		nrregres = $('#nrregres', tr ).val();
		
		
		$('#divTabela').css('display','none');
		$('#divDetalhes').css('display','block');
		$('#frmExcluir','#divDetalhes').css('display','block'); 
		$('#divBotoesExcluir').css('display','block');
		
		$('#btVoltar','#divBotoesExcluir').show();
		$('#btExcluir','#divBotoesExcluir').show();
		
	}
	
	return false;		
	
}

function incluir(){
	
	var cpf = $('#nrcpfcgc','#frmIncluir').val();
	var nmpessoa = $('#nmpessoa','#frmIncluir').val();
	var cdcopsol = $('#cdcopsol','#frmIncluir').val();
	var nmpessol = $('#nmpessol','#frmIncluir').val();
	var dsjusinc = $('#dsjusinc','#frmIncluir').val().replace(/\r\n/g,' ');
	var cdbccxlt = $('#cdbccxlt','#frmIncluir').val();
	var tporigem = $('#tporigem','#frmIncluir').val();
	var nrcpfcgc = normalizaNumero(cpf);
				
	$('input,select,textarea','#frmIncluir').removeClass('campoErro');
	
	
	// Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, carregando informa&ccedil;&otilde;es ...');
			
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/alerta/incluir.php',
		data: {
			nrcpfcgc: nrcpfcgc,
			nmpessoa: removeCaracteresInvalidos(nmpessoa, true),
			cdcopsol: cdcopsol,
			nmpessol: removeCaracteresInvalidos(nmpessol, true), 
			dsjusinc: removeCaracteresInvalidos(dsjusinc, true),
			cdbccxlt: cdbccxlt,
			tporigem: tporigem,
			redirect: 'script_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabAlerta').focus()");							
		},
		success: function(response) {
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try { 
							$('#divDetalhes').html(response);
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
		
}

function excluir(){

	var cddopcao = $('#cddopcao','#frmCabAlerta').val();
	var dsjusexc = $('#dsjusexc','#frmExcluir').val().replace(/\r\n/g,' ');
	var cpf = $('#nrcpfcgc','#frmExcluir').val();
	var nrcpfcgc = normalizaNumero(cpf);
	
	// Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, carregando informa&ccedil;&otilde;es ...');
		
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/alerta/excluir.php',
		data: {
			nrcpfcgc: nrcpfcgc,
			nrregres: nrregres,
			dsjusexc: dsjusexc,
			redirect: 'script_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabAlerta').focus()");							
		},
		success: function(response) {			
			hideMsgAguardo();
			eval(response);
										
		}	
		
	});
	
}


function liberar(){

	var cdcoplib = $('#cdcopsol','#frmLiberar').val();
	var cdagelib = $('#cdagepac','#frmLiberar').val();
	var cdopelib = $('#cdopelib','#frmLiberar').val();
	var nrdconta = retiraCaracteres($("#nrdconta","#frmLiberar").val(),"0123456789",true);
	var nrcpfcgc = normalizaNumero($('#nrcpfcgc','#frmLiberar').val());
	var dsjuslib = $('#dsjuslib','#frmLiberar').val();
	var cdoperac = $('#cdoperac','#frmLiberar').val();
		
	$('input,textarea','#frmLiberar').removeClass('campoErro');
	
	// Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, carregando informa&ccedil;&otilde;es ...');
		
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/alerta/liberar.php',
		data: {
			cdcoplib: cdcoplib,
			cdagelib: cdagelib,
			cdopelib: cdopelib,
			nrdconta: nrdconta,
			nrcpfcgc: nrcpfcgc,
			dsjuslib: dsjuslib,
			cdoperac: cdoperac,
			redirect: 'script_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabAlerta').focus()");							
		},
		success: function(response) {
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try { 
							$('#divDetalhes').html(response);
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
		
}


//Monta a div e mostra os vinculos encontrados ao cpf em questao
function consultaVinculo(cddopcao, cpf, nriniseq, nrregist) {

	var nrcpfcgc = normalizaNumero(cpf);

	showMsgAguardo('Aguarde, buscando v&iacute;nculos...');
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/alerta/consulta_vinculo.php', 
		data: {
			nrcpfcgc: nrcpfcgc,
			nrregist: nrregist,
			nriniseq: nriniseq,
			cddopcao: cddopcao,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
					hideMsgAguardo();
					bloqueiaFundo( $('#divRotina') );
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try { 
							$('#divUsoGenerico').html('');
							exibeRotina($('#divUsoGenerico'));
							$('#divUsoGenerico').html(response).css('left','310px');
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

function controlaPesquisasLiberar() {
	
	/*---------------------*/
	/*   CONTROLE PA  */
	/*---------------------*/
	var linkPac = $('a:eq(0)','#frmLiberar');

	if ( linkPac.prev().hasClass('campoTelaSemBorda') ) {		
		linkPac.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkPac.css('cursor','pointer').unbind('click').bind('click', function() {			
		
			bo		    = 'b1wgen0059.p';
			procedure   = 'busca-agencia';
			titulo      = 'Agência PA';
			qtReg	    = '20';					
			filtrosPesq = 'Cód. PA   ;cdagepac;30px ;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;|Cód. Cooperativa;cdcopsol;30px;S;' + $('#cdcopsol','#frmLiberar').val() + ';N;codigo;';
			colunas 	= 'PA;cdagepac;20%;right|Descrição;dsagepac;80%;left;';
							
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
		
		});
	}
	
	/*---------------------*/
	/*  CONTROLE OPERADOR  */
	/*---------------------*/
	var linkOperador = $('a:eq(1)','#frmLiberar');
	
	if ( linkOperador.prev().hasClass('campoTelaSemBorda') ) {		
		linkOperador.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkOperador.css('cursor','pointer').unbind('click').bind('click', function() {			
			
			bo			= 'b1wgen0059.p';
			procedure	= 'busca-operador';
			titulo      = 'Operador';
			qtReg		= '20';					
			filtrosPesq	= 'Cód. Operador;cdopelib;100px;S;;;descricao;|Nome ;nmoperad;200px;S;;;descricao;|Cód. Cooperativa;cdcopsol;30px;S;' + $('#cdcopsol','#frmLiberar').val() + ';N;codigo;|Cód. Pa;cdagepac;30px;S;' + $('#cdagepac','#frmLiberar').val() + ';N;codigo;';
			colunas 	= 'Código;cdoperad;20%;right|Descrição;nmoperad;80%;left;';
								
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
		
		});
	}
	
	/*---------------------*/
	/*  CONTROLE OPERACAO  */
	/*---------------------*/
	var linkOperacao = $('a:eq(2)','#frmLiberar');
	
	if ( linkOperacao.prev().hasClass('campoTelaSemBorda') ) {		
		linkOperacao.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkOperacao.css('cursor','pointer').unbind('click').bind('click', function() {			
			
			bo			= 'b1wgen0059.p';
			procedure	= 'busca-rotina';
			titulo      = 'Operacao/Rotina';
			qtReg		= '20';					
			filtrosPesq	= 'Cód. Operacao;cdoperac;100px;S;;;codigo;|Descricao ;dsoperac;200px;S;;;descricao;';
			colunas 	= 'Código;cdoperac;20%;right|Descrição;dsoperac;80%;left;';
								
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
		
		});
	}
	
		
	// Se pressionar cdagepac
	$('#cdagepac','#frmLiberar').unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {
		
			bo		    = 'b1wgen0059.p';
			procedure   = 'busca-agencia';
			titulo      = 'Agência PA';
			filtrosDesc = 'cdcopsol|' + $('#cdcopsol','#frmLiberar').val() + ';cdagepac|' + +$('#cdagepac','#frmLiberar').val();
										
			$(this).removeClass('campoErro');
			buscaDescricao(bo,procedure,titulo,'cdagepac','nmresage',$('#cdagepac','#frmLiberar').val(),'dsagepac',filtrosDesc,'frmLiberar');
			$('#cdopelib','#frmLiberar').focus();
			
			return false;
		
		}
		
	});		
	
	// Se pressionar cdopelib
	$('#cdopelib','#frmLiberar').unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13  || e.keyCode == 9 || e.keyCode == 18) {
		
			bo			= 'b1wgen0059.p';
			procedure	= 'busca-operador';
			titulo      = 'Operador';
			colunas 	= 'Código;cdoperad;20%;right|Descrição;nmoperad;80%;left;';
			
			filtrosDesc = 'cdcopsol|' + $('#cdcopsol','#frmLiberar').val() + ';cdagepac|' + $('#cdagepac','#frmLiberar').val() + ';cdopelib|'+$('#cdopelib','#frmLiberar').val();
						
			$(this).removeClass('campoErro');
			buscaDescricao(bo,procedure,titulo,'cdopelib','nmoperad',$('#cdopelib','#frmLiberar').val(),'nmoperad',filtrosDesc,'frmLiberar');
			$('#nrdconta','#frmLiberar').focus();
		
			return false;
		
		}
				
	});	
	
	// Se pressionar cdoperac
	$('#cdoperac','#frmLiberar').unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13  || e.keyCode == 9 || e.keyCode == 18) {
		
			/*Se for informado 0 (zero) o campo dsoperac será alimentado com "TODAS" pois, na função buscaDescrição
			  está sendo tratado para que, quando for informado 0 (zero), o campo seja alimentado com "NAO INFORMADO".*/
			if( $('#cdoperac','#frmLiberar').val() == '0'){
				
				$('#dsoperac','#frmLiberar').val('TODAS');
				$('#dsjuslib','#frmLiberar').focus();
					
				return false;
				
			}
			
			bo			= 'b1wgen0059.p';
			procedure	= 'busca-rotina';
			titulo      = 'Operacao/Rotina';
			colunas 	= 'Código;cdoperac;20%;right|Descrição;dsoperac;80%;left;';
							
			filtrosDesc = 'cdoperac|' + $('#cdoperac','#frmLiberar').val() + ';cdopelib|'+$('#cdopelib','#frmLiberar').val();
						
			$(this).removeClass('campoErro');
			buscaDescricao(bo,procedure,titulo,'cdoperac','dsoperac',$('#cdoperac','#frmLiberar').val(),'dsoperac',filtrosDesc,'frmLiberar');
			
			$('#dsjuslib','#frmLiberar').focus();
			
			return false;
		
		}
		
				
	});	
	
	return false;
	
}

function controlaPesquisasIncluir() {

	/*---------------------*/
	/*   CONTROLE BANCO    */
	/*---------------------*/
	var linkBanco = $('a:eq(0)','#frmIncluir');

	if ( linkBanco.prev().hasClass('campoTelaSemBorda') ) {		
		linkBanco.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkBanco.css('cursor','pointer').unbind('click').bind('click', function() {			
		
			bo 	        = 'b1wgen0059.p';
			procedure	= 'Busca_Banco';
			titulo      = 'Banco';
			qtReg		= '20';					
			filtrosPesq	= 'Cód. Banco;cdbccxlt;30px;S;0;|Nome Banco;nmextbcc;200px;S;';
			colunas  	= 'Código;cdbccxlt;20%;right|Banco;nmextbcc;80%;left';
			
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
		
		});
	}
	
	// Se pressionar cdbccxlt
	$('#cdbccxlt','#frmIncluir').unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13  || e.keyCode == 9 || e.keyCode == 18) {
		
			bo  	     = 'b1wgen0059.p';
			procedure    = 'Busca_Banco';
			titulo       = 'Banco';
			qtReg 		 = '20';					
			filtrosPesq  = 'Cód. Banco;cdbccxlt;30px;S;0;|Nome Banco;nmextbcc;200px;S;';
			colunas    	 = 'Código;cdbccxlt;20%;right|Banco;nmextbcc;80%;left';
			
			$(this).removeClass('campoErro');
			buscaDescricao(bo,procedure,titulo,'cdbccxlt','nmextbcc',$('#cdbccxlt','#frmIncluir').val(),'nmextbcc','cdbccxlt','frmIncluir');
			
			$('#cdcopsol','#frmIncluir').focus();	
						
			return false;
		
		}
				
	});	
			
	return false;
}

//Função utilizada na opção "R" para abrir o relatório
function trataImpressao( nmarqpdf ){
	
	$('#nmarqpdf','#frmCabAlerta').remove();		
	$('#sidlogin','#frmCabAlerta').remove();			
	$('#nrcpfcgc','#frmCabAlerta').remove();			
	$('#nmpessoa','#frmCabAlerta').remove();	
	$('#tprelato','#frmCabAlerta').remove();
	$('#dtinicio','#frmCabAlerta').remove();	
	$('#dtdfinal','#frmCabAlerta').remove();	
			
	var cpf      = $('#consucpf','#divOpcoesConsulta').val();
	var tprelato = $('#tprelato',"#divOpcoesConsulta").val();
	var dtinicio = $('#dtinicio',"#divOpcoesConsulta").val();
	var dtdfinal = $('#dtdfinal',"#divOpcoesConsulta").val();
	var nrcpfcgc = normalizaNumero(cpf);	
			
	// Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#frmCabAlerta').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');
	$('#frmCabAlerta').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
	$('#frmCabAlerta').append('<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="' + nrcpfcgc + '" />');	
	$('#frmCabAlerta').append('<input type="hidden" id="nmpessoa" name="nmpessoa" value="' + $('#consupes','#divOpcoesConsulta').val() + '" />');
	$('#frmCabAlerta').append('<input type="hidden" id="tprelato" name="tprelato" value="' + tprelato + '" />');	
	$('#frmCabAlerta').append('<input type="hidden" id="dtinicio" name="dtinicio" value="' + dtinicio + '" />');
	$('#frmCabAlerta').append('<input type="hidden" id="dtdfinal" name="dtdfinal" value="' + dtdfinal + '" />');
		
	var action = UrlSite + 'telas/alerta/gera_relatorio.php';	
	
	carregaImpressaoAyllos( 'frmCabAlerta' ,action, 'estadoInicial();');
	
	return false;
	
		
}

function controlaAcessoOperacoes() {
				
	operacao = $('#cddopcao','#frmCabAlerta').val(); 	
	
	// Verifica permissões de acesso	
	if ( (operacao == 'C') && (flgConsultar		!= '1') ) { showError('error','Seu usuário não possui permissão de consulta.' 				,'Alerta - Ayllos','estadoInicial();'); return false; }
	if ( (operacao == 'A') && (flgAlterar		!= '1') ) { showError('error','Seu usuário não possui permissão de alteração.' 				,'Alerta - Ayllos','estadoInicial();'); return false; }
	if ( (operacao == 'E') && (flgExcluir   	!= '1') ) { showError('error','Seu usuário não possui permissão de exclusão.'  				,'Alerta - Ayllos','estadoInicial();'); return false; }
	if ( (operacao == 'I') && (flgIncluir   	!= '1') ) { showError('error','Seu usuário não possui permissão de inclusão.'           	,'Alerta - Ayllos','estadoInicial();'); return false; }
	if ( (operacao == 'L') && (flgLiberar		!= '1') ) { showError('error','Seu usuário não possui permissão de liberação.'  			,'Alerta - Ayllos','estadoInicial();'); return false; }
	if ( (operacao == 'R') && (flgRelatorio 	!= '1') ) { showError('error','Seu usuário não possui permissão para emissão do relatório.'	,'Alerta - Ayllos','estadoInicial();'); return false; }
	if ( (operacao == 'V') && (flgVinculos  	!= '1') ) { showError('error','Seu usuário não possui permissão para consulta de vinculos.'	,'Alerta - Ayllos','estadoInicial();'); return false; }
			
	return true;
}

function mostraOpcoesRelatorios (pr_tprelato) {
	
	if (pr_tprelato == 1) { // Alerta de emitidos
		$('#divPeriodo','#frmOpcoesConsulta').hide();
		$('#divNomeCpf','#frmOpcoesConsulta').show();
	}
	else { // Relatório Geral/Analítico
		$('#divNomeCpf','#frmOpcoesConsulta').hide();
		$('#divCpf','#frmOpcoesConsulta').hide();
		$('#divNome','#frmOpcoesConsulta').hide();
		$('#divPeriodo','#frmOpcoesConsulta').show();
		$('#btConsulta','#divOpcoesConsulta').show();
		$("#dtinicio","#frmOpcoesConsulta").focus();
	}

}