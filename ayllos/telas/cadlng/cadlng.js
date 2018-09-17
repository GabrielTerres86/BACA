//************************************************************************//
//*** Fonte: cadlng.js                                                 ***//
//*** Autor: Adriano                                                   ***//
//*** Data : Outubro/2011                Última Alteração:             ***//
//***                                                                  ***//
//*** Objetivo  : Biblioteca de funções da tela CADLNG                 ***//
//***                                                                  ***//	 
//*** Alterações:                                                      ***//
//************************************************************************//

var frmCabCadlng,
	frmIncCadlng,
	frmDetalhes,
	cTodosInc,
	cTodosConExc,
	cTodosDetalhes;
	
var cCddopcao, nrsequen;


$(document).ready(function() {

	frmCabCadlng =  $('#frmCabCadlng');
	frmIncCadlng =  $('#frmIncCadlng');
	frmDetalhes  =  $('#frmDetalhes');
	
	$("#divBtIncluir").css("display","none");
	$("#divBtConsulta").css("display","none");
	$("#Informacoes").css("display","none");
	$("#divConsulta").css("display","none");
	$("#divIncluir").css("display","none");
	$("#divDetalhes").css("display","none"); 
	$("#divCpf").css("display","none");
	$("#divNome").css("display","none");
	
	cTodosInc      = $('input',frmIncCadlng);
	cTodosConExc   = $('input','#frmConCadlng');	
	cTodosDetalhes = $('input',frmDetalhes);	
	
	controlaLayout();	
	
});

function controlaLayout(){
		
	formataCabecalho();
	formataCadlng();
	limpaCampos();
	estadoInicial();
	layoutPadrao();
}

function formataCabecalho(){

	var cddopcao = $("#cddopcao","#frmCabCadlng").val();
	var rCddopcao = $('label[for="cddopcao"]','#frmCabCadlng');
				
	rCddopcao.css('width','40px').addClass('rotulo');
		
	cCddopcao = $('#cddopcao','#frmCabCadlng');
		
	cCddopcao.css('width','36px');
	cCddopcao.habilitaCampo().focus();
		

}

//Funcao para limpar campos dos formularios 
function limpaCampos() {
	
	$('#nrcpfcgc','#frmIncCadlng').val('');
	$('#nmpessoa','#frmIncCadlng').val('');
	$('#cdcoosol','#frmIncCadlng').val('');
	$('#nmextcop','#frmIncCadlng').val('');
	$('#nmpessol','#frmIncCadlng').val('');
	$('#dscarsol','#frmIncCadlng').val('');
	$('#dsmotinc','#frmIncCadlng').val('');
	$('#dsmotexc','#frmIncCadlng').val('');
	$('#consucpf','#frmConCadlng').val('');
	$('#consupes','#frmConCadlng').val('');
	
}

function estadoInicial() {
		
	cCddopcao.focus();
	
	$("#divBtIncluir").css("display","none");
	$("#divBtConsulta").css("display","none");
	$("#divConsulta").css("display","none");
	$("#divIncluir").css("display","none");
	$("#divdetalhes").css("display","none");
	$("#divCpf").css("display","none");
	$("#divNome").css("display","none");
			
}

function formataCadlng() {

	// Definindo as variáveis
	var bo 			  = 'b1wgen0059.p';
	var procedure	  = '';
	var titulo		  = '';
	var qtReg		  = '';
	var filtrosPesq	  = '';
	var filtrosDesc	  = '';
	var colunas	      = '';
	var divBtIncluir  = $('#divBtIncluir');
	var divBtConsulta = $('#divBtConsulta');
	var divBtDetalhes   = $('#divBtDetalhes');
	var btIncluir 	  = $('input','#divBtIncluir');
	var btConsulta 	  = $('input','#divBtConsulta');
	var btConExc 	  = $('input','#divBtDetalhes');
	
	
	divBtIncluir.css({'border':'1px solid #ddd','background-color':'#eee','padding':'2px','height':'28px','margin':'7px 0px'});
	divBtConsulta.css({'border':'1px solid #ddd','background-color':'#eee','padding':'2px','height':'28px','margin':'7px 0px'});
	divBtDetalhes.css({'border':'1px solid #ddd','background-color':'#eee','padding':'2px','height':'28px','margin':'7px 0px'});
	btIncluir.css({'display':'block','float':'right','padding-left':'2px'});
	btConsulta.css({'display':'none','float':'right','padding-left':'2px'});
	btConExc.css({'display':'block','float':'right','padding-left':'2px'});
	
	
	// Variáveis do formulário Inclusão
	rNrcpfcgc = $('label[for="nrcpfcgc"]','#frmIncCadlng');
	rNmpessoa = $('label[for="nmpessoa"]','#frmIncCadlng');
	rCdcoosol = $('label[for="cdcoosol"]','#frmIncCadlng');
	rNmextcop = $('label[for="nmextcop"]','#frmIncCadlng');
	rNmpessol = $('label[for="nmpessol"]','#frmIncCadlng');
	rDscarsol = $('label[for="dscarsol"]','#frmIncCadlng');
	rDsmotinc = $('label[for="dsmotinc"]','#frmIncCadlng');
	
	//Variáveis do formulário Consulta
	rTppesqi = $('label[for="tppesqui"]','#frmConCadlng');
	rCpfcnpj = $('label[for="cpfcgcRadio"]','#frmConCadlng');
	rNome = $('label[for="nomeRadio"]','#frmConCadlng');
	rConsucpf = $('label[for="consucpf"]','#frmConCadlng');
	rConsupes = $('label[for="consupes"]','#frmConCadlng');
	 
	
	//Variáveis do formulário Detalhes
	rDetsitua = $('label[for="detsitua"]','#frmDetalhes');
	rDetnrcpf = $('label[for="detnrcpf"]','#frmDetalhes');
	rDetdnome = $('label[for="detdnome"]','#frmDetalhes');
	rDetsolic = $('label[for="detsolic"]','#frmDetalhes');
	rDetdtinc = $('label[for="detdtinc"]','#frmDetalhes');
	dDetmotin = $('label[for="detmotin"]','#frmDetalhes');
	rDetdocad = $('label[for="detdocad"]','#frmDetalhes');
	rDetexclu = $('label[for="detexclu"]','#frmDetalhes');
	rDetdtexc = $('label[for="detdtexc"]','#frmDetalhes');
	rDetmotex = $('label[for="detmotex"]','#frmDetalhes');
	
	
    //Label do form de Inclusão	
	rNrcpfcgc.css('width', '175px').addClass('rotulo');
	rNmpessoa.css('width', '175px').addClass('rotulo');
	rCdcoosol.css('width', '175px').addClass('rotulo');
	rNmextcop.addClass('rotulo');
	rNmpessol.css('width', '175px').addClass('rotulo');
	rDscarsol.css('width', '175px').addClass('rotulo');
	rDsmotinc.css('width', '175px').addClass('rotulo');
	
	//Label do form de Consulta
	rTppesqi.css('width', '220px').addClass('rotulo');
	rCpfcnpj.css('width', '90px').addClass('rotulo');
	rNome.css('width', '30px').addClass('rotulo');
	rConsucpf.css('width', '280px').addClass('rotulo');
	rConsupes.css('width', '170px').addClass('rotulo');
	
	//Label do form de Detalhes
	rDetsitua.css('width', '175px').addClass('rotulo');
	rDetnrcpf.css('width', '175px').addClass('rotulo');
	rDetdnome.css('width', '175px').addClass('rotulo');
	rDetsolic.css('width', '175px').addClass('rotulo');
	rDetdtinc.css('width', '175px').addClass('rotulo');
	dDetmotin.css('width', '175px').addClass('rotulo');
	rDetdocad.css('width', '175px').addClass('rotulo');
	rDetexclu.css('width', '175px').addClass('rotulo');
	rDetdtexc.css('width', '175px').addClass('rotulo');
	rDetmotex.css('width', '175px').addClass('rotulo');
	
	if($.browser.msie){
		frmIncCadlng.css({'height':'300px'});
		$('#frmConCadlng').css({'height':'130px'});
		frmDetalhes.css({'height':'450px'});
	}else{
		frmIncCadlng.css({'height':'320px'});
		$('#frmConCadlng').css({'height':'350px'});
		frmDetalhes.css({'height':'455px'});
		
	}
		
	//Campos do form de Inclusão
	cNrcpfcgc = $('#nrcpfcgc','#frmIncCadlng');
	cNmpessoa = $('#nmpessoa','#frmIncCadlng');
	cCdcoosol = $('#cdcoosol','#frmIncCadlng');
	cNmextcop = $('#nmextcop','#frmIncCadlng');
	cNmpessol = $('#nmpessol','#frmIncCadlng');
	cDscarsol = $('#dscarsol','#frmIncCadlng');
	cDsmotinc = $('#dsmotinc','#frmIncCadlng');
	
	cNrcpfcgc.css('width','250px').addClass('inteiro').attr('maxlength','17');
	cNmpessoa.addClass('alphanum').addClass('alpha').css('width','250px').attr('maxlength','50');
	cCdcoosol.css('width','35px').attr('maxlength','50');
	cNmextcop.css('width','250px').attr('maxlength','50');
	cNmpessol.addClass('alphanum').addClass('alpha').css('width','250px').attr('maxlength','50');
	cDscarsol.addClass('alphanum').addClass('alpha').css('width','250px').attr('maxlength','50');
		
	if($.browser.msie){
		cDsmotinc.addClass('alphanum').css('width','250px').attr('maxlength','150').css('overflow-y','scroll').css('overflow-x','hidden').css('height','100');
				
	}else{
		cDsmotinc.addClass('alphanum').css('width','250px').attr('maxlength','150').css('overflow-y','scroll').css('overflow-x','hidden').css('height','100').css('margin-left','3');
				
	}	
	
	//Campos do form de Consulta
	cCpfcnpj = $('#cpfcgc','#frmConCadlng');
	cNome = $('#nome','#frmConCadlng');
	cConsupes = $('#consupes','#frmConCadlng');
	cConsucpf = $('#consucpf','#frmConCadlng');
	
	cCpfcnpj.css('width','30px');
	cNome.css('width','30px');
	cConsupes.addClass('alphanum').addClass('alpha').css('width','300px').attr('maxlength','50');
	cConsucpf.addClass('inteiro').css('width','170px').attr('maxlength','16');
	
	//Campos do form Detalhes
	cDetsitua = $('#detsitua','#frmDetalhes');
	cDetnrcpf = $('#detnrcpf','#frmDetalhes');
	cDetdnome = $('#detdnome','#frmDetalhes');
	cDetsolic = $('#detsolic','#frmDetalhes');
	cDetdtinc = $('#detdtinc','#frmDetalhes');
	cDetmotin = $('#detmotin','#frmDetalhes');
	cDetdocad = $('#detdocad','#frmDetalhes');
	cDetexclu = $('#detexclu','#frmDetalhes');
	cDetdtexc = $('#detdtexc','#frmDetalhes');
	cDetmotex = $('#detmotex','#frmDetalhes');
		
	cDetsitua.css('width','250px').attr('maxlength','14');
	cDetnrcpf.css('width','250px').attr('maxlength','14');
	cDetdnome.css('width','250px').attr('maxlength','50');
	cDetsolic.css('width','250px').attr('maxlength','60');
	cDetdtinc.css('width','250px').attr('maxlength','25');
	cDetdocad.css('width','250px').attr('maxlength','60');
	cDetexclu.css('width','250px').attr('maxlength','60');
	cDetdtexc.css('width','250px').attr('maxlength','25');
	
	
	if($.browser.msie){
		cDetmotex.addClass('alphanum').css('width','250px').attr('maxlength','150').css('overflow-y','scroll').css('overflow-x','hidden').css('height','100');
		cDetmotin.addClass('alphanum').css('width','250px').attr('maxlength','150').css('overflow-y','scroll').css('overflow-x','hidden').css('height','100');
		
	}else{
		cDetmotex.addClass('alphanum').css('width','250px').attr('maxlength','150').css('overflow-y','scroll').css('overflow-x','hidden').css('height','100').css('margin-left','3');
		cDetmotin.addClass('alphanum').css('width','250px').attr('maxlength','150').css('overflow-y','scroll').css('overflow-x','hidden').css('height','100').css('margin-left','3');
		
	}	
		
	cTodosDetalhes.desabilitaCampo();
	cDetmotin.desabilitaCampo();
	cDetmotex.desabilitaCampo();
	
	/*----------------*/
	/*  CONTROLE PAC  */
	/*----------------*/
	var linkPAC = $('a:eq(0)','#frmIncCadlng');
	
	linkPAC.css('cursor','pointer').unbind('click').bind('click', function() {
		procedure	= 'busca_cooperativa';
		titulo      = 'Cooperativa';
		qtReg		= '20';					
		filtrosPesq	= 'Cód. Cop;cdcoosol;30px;S;0;;codigo;|Cooperativa;nmextcop;200px;S;;;descricao;';
		colunas 	= 'Código;cdcoosol;20%;right|Descrição;nmextcop;80%;left';
		mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
	
		return false;	
		
	});
	
	linkPAC.prev().unbind('change').bind('change', function() {
		procedure	= 'busca_cooperativa';
		titulo      = 'Cooperativa';
		filtrosDesc = '';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'nmextcop',$(this).val(),'nmextcop',filtrosDesc,'frmIncCadlng');
	
		return false;
		
	});
	
	linkPAC.prev().unbind('blur').bind('blur', function() {
		$(this).unbind('change').bind('change', function() {
			procedure	= 'busca_cooperativa';
			titulo      = 'Cooperativa';
			filtrosDesc = '';
			buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'nmextcop',$(this).val(),'nmextcop',filtrosDesc,'frmIncCadlng');
			return false;

		});
	});		
	
	
	// Se pressionar cNrcpfcgc
	cNrcpfcgc.unbind('keypress').bind('keypress', function(e){ 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER
		if ( e.keyCode == 13  || e.keyCode == 9 ) {		
			$("input,select","#frmIncCadlng").removeClass("campoErro");
			cNmpessoa.focus();
			
			var cpfCnpj = normalizaNumero($("#nrcpfcgc","#frmIncCadlng").val());
			
			if(cpfCnpj.length <= 11){	
				cNrcpfcgc.val(mascara(cpfCnpj,"###.###.###-##"));
			}else{
				cNrcpfcgc.val(mascara(cpfCnpj,"##.###.###/####-##"));
			}
			
			return false;
			
		}
										
	});		
	
	// Se pressionar cConsucpf
	cConsucpf.unbind('keypress').bind('keypress', function(e){ 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER
		if ( e.keyCode == 13  || e.keyCode == 9 ) {		
			$("input,select","#frmConCadlng").removeClass("campoErro");
					
			var cpfCnpj = normalizaNumero($("#consucpf","#frmConCadlng").val());
			
			if(cpfCnpj.length <= 11){	
				cConsucpf.val(mascara(cpfCnpj,"###.###.###-##"));
			}else{
				cConsucpf.val(mascara(cpfCnpj,"##.###.###/####-##"));
			}
			
			return false;
			
		}
										
	});		
	
	// Se pressionar cNmpessoa
	cNmpessoa.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 || e.keyCode == 9 ) {
			$("input,select","#frmIncCadlng").removeClass("campoErro");
			cCdcoosol.focus();
			
			return false;
		
		}
		
	});		
	
	// Se pressionar cCdcoosol
	cCdcoosol.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13  || e.keyCode == 9 ) {
			$("input,select","#frmIncCadlng").removeClass("campoErro");
			cNmpessol.focus();
		
			return false;
		
		}

				
	});		
	
	// Se pressionar cNmpessol
	cNmpessol.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 || e.keyCode == 9  ) {
			$("input,select","#frmIncCadlng").removeClass("campoErro");
			cDscarsol.focus();
		
			return false;
		
		}

				
	});		
	
	// Se pressionar cDscarsol
	cDscarsol.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 || e.keyCode == 9  ) {
			$("input,select","#frmIncCadlng").removeClass("campoErro");
			cDsmotinc.focus();
		
			return false;
		
		}
		
	});		
	
		
	//Controla exibicao dos campos para consulta
	cCpfcnpj.click( function() {
		$("#divNome").css("display","none");
		$("#divCpf").css("display","block");
		cConsupes.val('');
		$("#divBtConsulta").css("display","block");
		btConsulta.css({'display':'block'});
						
	});	
	
	//Controla exibicao dos campos para consulta
	cNome.click( function() {
		$("#divCpf").css("display","none");
		$("#divNome").css("display","block");
		cConsucpf.val('');
		$("#divBtConsulta").css("display","block");
		btConsulta.css({'display':'block'});
				
	});	
		
		
}

//Funcao para formata tabela
function tabela(){

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
		selecionaConsulta($(this));
		
	});					
	
	$('#divConsulta').css('display','block');
	$('#divRegistros').css('display','block');
	$('#divRegistrosRodape','#divConsulta').formataRodapePesquisa();		
		
}

function tipoOpcao(){

    var cddopcao = $("#cddopcao","#frmCabCadlng").val();
	var dsmotexc = $('#detmotex','#frmDetalhes');
	var btConsulta = $('input','#divBtConsulta');
    	
	$("#divBtConsulta").css("display","none");
	$("#divBtIncluir").css("display","none");	
	$("#divConsulta").css("display","none");
	$("#divIncluir").css("display","none");	
	$("#divBtDetalhes").css("display","none");
	$("#btVoltar").css("display","none");
	$("#btExcluir").css("display","none");
	$("#divDetalheConsulta").css("display","none");
	$("#divDetalhes").css("display","none");
	btConsulta.css({'display':'none'});		
	document.getElementById("cpfcgc").checked = false;
	document.getElementById("nome").checked = false;
	 
	if(cddopcao == 'C' || cddopcao == 'E'){
		
		$("#divConsulta").css("display","block");
		$("#btVoltar").css("display","block");
		cTodosConExc.habilitaCampo(); 
				
		if(cddopcao == 'E'){
			dsmotexc.habilitaCampo();
			$("#divBtDetalhes").css("display","block");
			$("#btExcluir").css("display","block");
					
		}else{
			dsmotexc.desabilitaCampo();
		
		}
						
	}else{if(cddopcao == 'I'){ 
		
			$("#divBtIncluir").css("display","block");	
			$("#divIncluir").css("display","block");
			cTodosInc.habilitaCampo();
			cNmextcop.desabilitaCampo();
			$("#divBtIncluir").css("display","block");	
						
		}
	}


}


function realizaInclusao(){

	var cpf = $("#nrcpfcgc","#frmIncCadlng").val();
	var nmpessoa = $("#nmpessoa","#frmIncCadlng").val();
	var cdcoosol = $("#cdcoosol","#frmIncCadlng").val();
	var nmpessol = $("#nmpessol","#frmIncCadlng").val();
	var dscarsol = $("#dscarsol","#frmIncCadlng").val();
	var dsmotinc = $("#dsmotinc","#frmIncCadlng").val();
	var nrcpfcgc = normalizaNumero(cpf);
	var tipo;
	
	if(nrcpfcgc.length <= 11){
		tipo = 1;
		
	}else{
		tipo =2;
		
	}
	
	if (!validaCpfCnpj(nrcpfcgc ,tipo) ) { 
		showError("error","CPF inv&aacute;lido.","Alerta - Ayllos","focaCampoErro(\"nrcpfcgc\",\"frmIncCadlng\");"); 
		return false;
	}
				
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
			
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/cadlng/realiza_inclusao.php",
		data: {
			nrcpfcgc: nrcpfcgc,
			nmpessoa: nmpessoa,
			cdcoosol: cdcoosol,
			nmpessol: nmpessol,
			dscarsol: dscarsol,
			dsmotinc: dsmotinc,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabCadlng').focus()");							
		},
		success: function(response) {				
			hideMsgAguardo();
			eval(response);
							
		}		
	});
		
}


function realizaConsulta(nriniseq, nrregist){

	var cddopcao = $("#cddopcao","#frmCabCadlng").val();
	var nrcpfcgc = $("#consucpf","#frmConCadlng").val();
	var consupes = $("#consupes","#frmConCadlng").val();
	var consucpf = normalizaNumero(nrcpfcgc);
	
	$('.divRegistros').html('');	
			
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
	
		
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/cadlng/realiza_consulta.php",
		data: {
			cddopcao: cddopcao,
			consucpf: consucpf,
			consupes: consupes,
			nriniseq: nriniseq,
			nrregist: nrregist,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabCadlng').focus()");							
		},
		success: function(response) {			
			try {
				hideMsgAguardo();
				eval(response);
						
				$('a.paginacaoAnt').unbind('click').bind('click', function() {
					realizaConsulta((nriniseq - nrregist),nrregist);
				
				});
				$('a.paginacaoProx').unbind('click').bind('click', function() {
					realizaConsulta((nriniseq + nrregist),nrregist);
			
				});		
			} catch(error) {
					hideMsgAguardo();					
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmPesqti').focus()");									
				}	
		}		
	});
	
}

function realizaExclusao(){

	var cddopcao = $("#cddopcao","#frmCabCadlng").val();
	var dsmotexc = $("#detmotex","#frmDetalhes").val();
	var cpf = $("#detnrcpf","#frmDetalhes").val();
	var nrcpfcgc = normalizaNumero(cpf);
	
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
		
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/cadlng/realiza_exclusao.php",
		data: {
			nrcpfcgc: nrcpfcgc,
			nrsequen: nrsequen,
			dsmotexc: dsmotexc,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabCadlng').focus()");							
		},
		success: function(response) {			
			hideMsgAguardo();
			eval(response);
										
		}	
		
	});
	
}


//Funcao para selecionar um registro para consultar detalhes
function selecionaConsulta(tr){	

    var cddopcao = $("#cddopcao","#frmCabCadlng").val();
	var dsmotexc = $('#detmotex','#frmDetalhes');
	
	if(cddopcao == "E"){
		dsmotexc.habilitaCampo();
	
	}	
	
	if($('#detnrcpf', tr ).val().length <= 11){
		$('#detnrcpf',"#frmDetalhes").val(mascara($('#detnrcpf', tr ).val(),"###.###.###-##"));
	
	}else{
		$('#detnrcpf',"#frmDetalhes").val(mascara($('#detnrcpf', tr ).val(),"##.###.###/####-##"));
	
	};
	
	$('#detsitua',"#frmDetalhes").val( $('#detsitua', tr ).val() );
	$('#detdnome',"#frmDetalhes").val( $('#detdnome', tr ).val() );
	$('#detsolic',"#frmDetalhes").val( $('#detsolic', tr ).val() );
	$('#detdtinc',"#frmDetalhes").val( $('#detdtinc', tr ).val() );
	$('#detmotin',"#frmDetalhes").val( $('#detmotin', tr ).val() );
	$('#detdocad',"#frmDetalhes").val( $('#detdocad', tr ).val() );
	$('#detexclu',"#frmDetalhes").val( $('#detexclu', tr ).val() );
	$('#detdtexc',"#frmDetalhes").val( $('#detdtexc', tr ).val() );
	$('#detmotex',"#frmDetalhes").val( $('#detmotex', tr ).val() );
	nrsequen = $('#detseque', tr ).val();
	
	
	$("#divRegistros").css("display","none");
	$("#divConsulta").css("display","none");
	$("#divDetalhes").css("display","block");
	$("#divBtDetalhes").css("display","block");
	$("#divBtConsulta").css("display","none");
		
	return false;		
	
}

// Função para voltar ao div anterior
function voltaDiv(){
	
	$("#divDetalhes").css("display","none");
	$("#divConsulta").css("display","block");
	$("#divRegistros").css("display","block");
	$("#divBtDetalhes").css("display","none");
	$("#divBtConsulta").css("display","block");
		
}
	