/*****************************************************************************************
 Fonte: parrgp.js                                                   
 Autor: Jonata - Mouts                                                 
 Data : Maio/2017           					   Última Alteração:        
                                                                  
 Objetivo  : Biblioteca de funções da tela PARRGP                 
                                                                  
 Alterações:  
						  
******************************************************************************************/

$(document).ready(function() {

	estadoInicial();
			
});


function estadoInicial() {
	
	formataCabecalho();	
	
	$('#divDetalhes').html('');
	$('#cddopcao','#frmCabParrgp').habilitaCampo().focus().val('C');	
		
	layoutPadrao();
				
}

function formataCabecalho(){

	$('label[for="cddopcao"]','#frmCabParrgp').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCabParrgp').css('width','710px');
	$('#divTela').css({'display':'block'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
	$('#frmCabParrgp').css('display','block');
		
	cTodosCabecalho = $('input[type="text"],select', '#frmCabParrgp');
    
	highlightObjFocus( $('#frmCabParrgp') );
	
	cTodosCabecalho.habilitaCampo();
	
    //Ao pressionar botao cddopcao
	$('#cddopcao','#frmCabParrgp').unbind('keypress').bind('keypress', function(e){
    
		$('input,select').removeClass('campoErro');
			
		// Se é a tecla ENTER, TAB
		if(e.keyCode == 13 || e.keyCode == 9){
			
			$('#btOK','#frmCabParrgp').click();
			$(this).desabilitaCampo();			
			
			return false;						
			
		}
						
	});
	
	//Ao clicar no botao OK
	$('#btOK','#frmCabParrgp').unbind('click').bind('click', function(){
		
		if ( $('#cddopcao','#frmCabParrgp').hasClass('campoTelaSemBorda')  ) { return false; }
		
		$('#cddopcao','#frmCabParrgp').desabilitaCampo();		
		$(this).unbind('click');
		
		principal('1','30');
								
	});
		
	$('#cddopcao', '#frmCabParrgp').focus();
	
	return false;
	
}

function principal(nriniseq,nrregist){

	var cddopcao = $('#cddopcao','#frmCabParrgp').val(); 
	
	$('input,select').removeClass('campoErro');
	
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, buscando informações...');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/parrgp/principal.php',
		data: {
			cddopcao: cddopcao,			
			nriniseq: nriniseq,			
			nrregist: nrregist,			
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","estadoInicial();");							
		},
		success: function(response) {			
				hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divDetalhes').html(response);
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();estadoInicial();');
					}
				}
		}				
	});
		
	return false;
	
}

function manterRotina() {

    var cddopcao = $("#cddopcao", "#frmCabParrgp").val();
	var idproduto = $('#idproduto','#fsetDetalhes').val();
	var dsproduto = $('#dsproduto','#fsetDetalhes').val();
	var tpdestino = $('#tpdestino','#fsetDetalhes').val();
	var tparquivo = $('#tparquivo','#fsetDetalhes').val();
	var idgarantia = $('#iddominio_idgarantia','#fsetDetalhes').val();
	var idmodalidade = $('#iddominio_idmodalidade','#fsetDetalhes').val();
	var idconta_cosif = $('#iddominio_idconta_cosif','#fsetDetalhes').val();
	var idorigem_recurso = $('#iddominio_idorigem_recurso','#fsetDetalhes').val();
	var idindexador = $('#iddominio_idindexador','#fsetDetalhes').val();
	var perindexador = isNaN(parseFloat($('#perindexador', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#perindexador', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."));
	var vltaxa_juros = isNaN(parseFloat($('#vltaxa_juros', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vltaxa_juros', '#fsetDetalhes').val().replace(/\./g, "").replace(/\,/g, "."));
	var cdclassifica_operacao = $('#cdclassifica_operacao', '#fsetDetalhes').val();
	var idvariacao_cambial = $('#iddominio_idvariacao_cambial','#fsetDetalhes').val();
	var idorigem_cep = $('#idorigem_cep','#fsetDetalhes').val();
	var idnat_operacao = $('#iddominio_idnat_operacao','#fsetDetalhes').val();
	var idcaract_especial = $('#iddominio_idcaract_especial','#fsetDetalhes').val();
	var flpermite_saida_operacao = $('#flpermite_saida_operacao','#fsetDetalhes').prop('checked');
	var flpermite_fluxo_financeiro = $('#flpermite_fluxo_financeiro','#fsetDetalhes').prop('checked');
	var flreaprov_mensal = $('#flreaprov_mensal','#fsetDetalhes').prop('checked');
		
	$('input,select').removeClass('campoErro');
	
    showMsgAguardo("Aguarde, realizando operação ...");

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/parrgp/manter_rotina.php",
        data: {
            cddopcao                   : cddopcao,
            idproduto                  : idproduto, 
			dsproduto                  : dsproduto, 
			tpdestino                  : tpdestino, 
			tparquivo                  : tparquivo, 
			idgarantia                 : idgarantia,
			idmodalidade			   : idmodalidade,	
			idconta_cosif              : idconta_cosif,
			idorigem_recurso           : idorigem_recurso,
			idindexador                : idindexador,
			perindexador               : perindexador,
			vltaxa_juros               : vltaxa_juros,
			cdclassifica_operacao      : cdclassifica_operacao,
			idvariacao_cambial         : idvariacao_cambial,
			idorigem_cep               : idorigem_cep,
			idnat_operacao             : idnat_operacao,
			idcaract_especial          : idcaract_especial,
			flpermite_saida_operacao   : (flpermite_saida_operacao ) ? '1' : '0',
			flpermite_fluxo_financeiro : (flpermite_fluxo_financeiro ) ? '1' : '0',
			flreaprov_mensal           : (flreaprov_mensal ) ? '1' : '0',
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'blockBackground(parseInt($("#divRotina").css("z-index")));$("#idproduto","#frmDetalhes").focus();');
            }
        }

    });

    return false;

}



//Funcao para formatar a tabela com as ocorrências encontradas na consulta
function formataTabelaParametros(){

	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
		
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table',divRegistro );	
	var linha		= $('table > tbody > tr', divRegistro );
									
	divRegistro.css({'height':'150px'});
			
	var ordemInicial = new Array();
					
	var arrayLargura = new Array(); 
		arrayLargura[0] = '80px';
		arrayLargura[1] = '180px';
		arrayLargura[2] = '100px';
		arrayLargura[3] = '180px';
							
	var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'left';
		arrayAlinha[3] = 'left';
		arrayAlinha[4] = 'left';
				
	var metodoTabela = '';
				
	tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,metodoTabela);			
							
	//Seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		
		var linha = $(this);
		
		//Ao clicar no botao btProsseguir
		$('#btProsseguir','#divBotoesProdutos').unbind('click').bind('click', function(){
			
			formataDetalhes();
			selecionaRegistro(linha);
						
		});		
		
	});			
	
	$('table > tbody > tr', divRegistro).focus(function () {
		
		var linha = $(this);
		
		//Ao clicar no botao btProsseguir
		$('#btProsseguir','#divBotoesProdutos').unbind('click').bind('click', function(){
			
			formataDetalhes();
			selecionaRegistro(linha);
												
		});			

	});

	//Deixa o primeiro registro ja selecionado
	$('table > tbody > tr', divRegistro).each(function (i) {

		if ($(this).hasClass('corSelecao')) {

			var linha = $(this);
		
			//Ao clicar no botao btProsseguir
			$('#btProsseguir','#divBotoesProdutos').unbind('click').bind('click', function(){
				
				formataDetalhes();
				selecionaRegistro(linha);				
													
			});

		}

	});
	
	$('#divRegistros').css('display','block');
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();		
	
	return false;
	
}


//Funcao para selecionar um registro para listar os detalhes de uma ocorrência
function selecionaRegistro(tr){	
		
	$('#idproduto','#fsetDetalhes').val( $('#aux_idproduto', tr ).val() );
	$('#dsproduto','#fsetDetalhes').val( $('#aux_dsproduto', tr ).val() );
	$('#tpdestino','#fsetDetalhes').prop('selected',true).val($('#aux_tpdestino', tr ).val());	
	$('#tparquivo','#fsetDetalhes').prop('selected',true).val($('#aux_tparquivo', tr ).val());	
	$('#idgarantia','#fsetDetalhes').val( $('#aux_idgarantia', tr ).val() );
	$('#iddominio_idgarantia','#fsetDetalhes').val( $('#aux_iddominio_idgarantia', tr ).val() );
	$('#dsgarantia','#fsetDetalhes').val( $('#aux_dsgarantia', tr ).val() );
	$('#idmodalidade','#fsetDetalhes').val( $('#aux_idmodalidade', tr ).val() );
	$('#iddominio_idmodalidade','#fsetDetalhes').val( $('#aux_iddominio_idmodalidade', tr ).val() );
	$('#dsmodalidade','#fsetDetalhes').val( $('#aux_dsmodalidade', tr ).val() );
	$('#idconta_cosif','#fsetDetalhes').val( $('#aux_idconta_cosif', tr ).val() );
	$('#iddominio_idconta_cosif','#fsetDetalhes').val( $('#aux_iddominio_idconta_cosif', tr ).val() );
	$('#dsconta_cosif','#fsetDetalhes').val( $('#aux_dsconta_cosif', tr ).val() );
	$('#idorigem_recurso','#fsetDetalhes').val( $('#aux_idorigem_recurso', tr ).val() );
	$('#iddominio_idorigem_recurso','#fsetDetalhes').val( $('#aux_iddominio_idorigem_recurso', tr ).val() );
	$('#dsorigem_recurso','#fsetDetalhes').val( $('#aux_dsorigem_recurso', tr ).val() );
	$('#idindexador','#fsetDetalhes').val( $('#aux_idindexador', tr ).val() );
	$('#iddominio_idindexador','#fsetDetalhes').val( $('#aux_iddominio_idindexador', tr ).val() );
	$('#dsindexador','#fsetDetalhes').val( $('#aux_dsindexador', tr ).val() );
	$('#perindexador','#fsetDetalhes').val( $('#aux_perindexador', tr ).val() );
	$('#vltaxa_juros','#fsetDetalhes').val( $('#aux_vltaxa_juros', tr ).val() );
	$('#cdclassifica_operacao','#fsetDetalhes').val( $('#aux_cdclassifica_operacao', tr ).val() );
	$('#iddominio_cdclassifica_operacao','#fsetDetalhes').val( $('#aux_iddominio_cdclassifica_operacao', tr ).val() );
	$('#dsclassifica_operacao','#fsetDetalhes').val( $('#aux_dsclassifica_operacao', tr ).val() );
	$('#idvariacao_cambial','#fsetDetalhes').val( $('#aux_idvariacao_cambial', tr ).val() );
	$('#iddominio_idvariacao_cambial','#fsetDetalhes').val( $('#aux_iddominio_idvariacao_cambial', tr ).val() );
	$('#dsvariacao_cambial','#fsetDetalhes').val( $('#aux_dsvariacao_cambial', tr ).val() );
	$('#idorigem_cep','#fsetDetalhes').prop('selected',true).val($('#aux_idorigem_cep', tr ).val());	
	$('#idnat_operacao','#fsetDetalhes').val( $('#aux_idnat_operacao', tr ).val() );
	$('#iddominio_idnat_operacao','#fsetDetalhes').val( $('#aux_iddominio_idnat_operacao', tr ).val() );
	$('#dsnat_operacao','#fsetDetalhes').val( $('#aux_dsnat_operacao', tr ).val() );
	$('#idcaract_especial','#fsetDetalhes').val( $('#aux_idcaract_especial', tr ).val() );
	$('#iddominio_idcaract_especial','#fsetDetalhes').val( $('#aux_iddominio_idcaract_especial', tr ).val() );
	$('#dscaract_especial','#fsetDetalhes').val( $('#aux_dscaract_especial', tr ).val() );
	($('#aux_flpermite_saida_operacao', tr ).val() == '1') ? $('#flpermite_saida_operacao','#fsetDetalhes').prop("checked",true) : $('#flpermite_saida_operacao','#fsetDetalhes').prop("checked",false);
	($('#aux_flpermite_fluxo_financeiro', tr ).val() == '1') ? $('#flpermite_fluxo_financeiro','#fsetDetalhes').prop("checked",true) : $('#flpermite_fluxo_financeiro','#fsetDetalhes').prop("checked",false);
	($('#aux_flreaprov_mensal', tr ).val() == '1') ? $('#flreaprov_mensal','#fsetDetalhes').prop("checked",true) : $('#flreaprov_mensal','#fsetDetalhes').prop("checked",false);
	
	$('#fsetDetalhes').css('display','block');
	$('#divBotoespParametros').css('display','block');
	$('#btVoltar','#divBotoesConsulta').show();
	$('#btConcluir','#divBotoesConsulta').show();	

	if($('#cddopcao','#frmCabParrgp').val() != 'C'){
		$('#dsproduto','#fsetDetalhes').focus();
	}
	
	return false;		
	
}

function formataDetalhes(){

	highlightObjFocus( $('#fsetDetalhes') );
	$('#fsetDetalhes').css({'border-bottom':'1px solid #777'});	
	
	todosCampos = $('input,select','#fsetDetalhes');
	 
	todosCampos.val('').desabilitaCampo();
	
	//Label do fsetDetalhes
	rIdproduto = $('label[for="idproduto"]','#fsetDetalhes');
	rDsproduto = $('label[for="dsproduto"]','#fsetDetalhes');
	rTpdestino = $('label[for="tpdestino"]','#fsetDetalhes');
	rTparquivo = $('label[for="tparquivo"]','#fsetDetalhes');
	rIdgarantia = $('label[for="idgarantia"]','#fsetDetalhes');
	rIdmodalidade = $('label[for="idmodalidade"]','#fsetDetalhes');
	rIdconta_cosif = $('label[for="idconta_cosif"]','#fsetDetalhes');
	rIdorigem_recurso = $('label[for="idorigem_recurso"]','#fsetDetalhes');
	rIdindexadorn = $('label[for="idindexador"]','#fsetDetalhes');
	rPerindexador = $('label[for="perindexador"]','#fsetDetalhes');
	rVltaxa_juros = $('label[for="vltaxa_juros"]','#fsetDetalhes');
	rCdclassifica_operacao = $('label[for="cdclassifica_operacao"]','#fsetDetalhes');
	rIdvariacao_cambial = $('label[for="idvariacao_cambial"]','#fsetDetalhes');
	rIdorigem_cep = $('label[for="idorigem_cep"]','#fsetDetalhes');
	rIdnat_operacao = $('label[for="idnat_operacao"]','#fsetDetalhes');
	rIdcaract_especial = $('label[for="idcaract_especial"]','#fsetDetalhes');
	rFlpermite_saida_operacao = $('label[for="flpermite_saida_operacao"]','#fsetDetalhes');
	rFlpermite_fluxo_financeiro = $('label[for="flpermite_fluxo_financeiro"]','#fsetDetalhes');
	rFlreaprov_mensal = $('label[for="flreaprov_mensal"]','#fsetDetalhes');
	
	//Label do fsetDetalhes
	rIdproduto.addClass("rotulo").css('width','160px');
	rDsproduto.addClass("rotulo").css('width','160px');
	rTpdestino.addClass("rotulo").css('width','160px');
	rTparquivo.addClass("rotulo").css('width','160px');
	rIdgarantia.addClass("rotulo").css('width','160px');
	rIdmodalidade.addClass("rotulo").css('width','160px');
	rIdconta_cosif.addClass("rotulo").css('width','160px');
	rIdorigem_recurso.addClass("rotulo").css('width','160px');
	rIdindexadorn.addClass("rotulo").css('width','160px');
	rPerindexador.addClass("rotulo").css('width','160px');
	rVltaxa_juros.addClass("rotulo").css('width','160px');
	rCdclassifica_operacao.addClass("rotulo").css('width','160px');
	rIdvariacao_cambial.addClass("rotulo").css('width','160px');
	rIdorigem_cep.addClass("rotulo").css('width','160px');
	rIdnat_operacao.addClass("rotulo").css('width','160px');
	rIdcaract_especial.addClass("rotulo").css('width','160px');
	rFlpermite_saida_operacao.addClass("rotulo").css('width','160px');
	rFlpermite_fluxo_financeiro.addClass("rotulo").css('width','160px');
	rFlreaprov_mensal.addClass("rotulo").css('width','160px');
		  		
	//Campos do fsetDetalhes
	cIdproduto = $('#idproduto','#fsetDetalhes');
	cDsproduto = $('#dsproduto','#fsetDetalhes');
	cTpdestino = $('#tpdestino','#fsetDetalhes');
	cTparquivo = $('#tparquivo','#fsetDetalhes');
	cIdgarantia = $('#idgarantia','#fsetDetalhes');
	cDsgarantia = $('#dsgarantia','#fsetDetalhes');
	cIdmodalidade = $('#idmodalidade','#fsetDetalhes');
	cDsmodalidade = $('#dsmodalidade','#fsetDetalhes');
	cIdconta_cosif = $('#idconta_cosif','#fsetDetalhes');
	cDsconta_cosif = $('#dsconta_cosif','#fsetDetalhes');
	cIdorigem_recurso = $('#idorigem_recurso','#fsetDetalhes');
	cDsorigem_recurso = $('#dsorigem_recurso','#fsetDetalhes');
	cIdindexador = $('#idindexador','#fsetDetalhes');
	cDsindexador = $('#dsindexador','#fsetDetalhes');
	cPerindexador = $('#perindexador','#fsetDetalhes');
	cVltaxa_juros = $('#vltaxa_juros','#fsetDetalhes');
	cCdclassifica_operacao = $('#cdclassifica_operacao','#fsetDetalhes');
	cIdvariacao_cambial = $('#idvariacao_cambial','#fsetDetalhes');
	cDsvariacao_cambial = $('#dsvariacao_cambial','#fsetDetalhes');
	cIdorigem_cep = $('#idorigem_cep','#fsetDetalhes');
	cIdnat_operacao = $('#idnat_operacao','#fsetDetalhes');
	cDsnat_operacao = $('#dsnat_operacao','#fsetDetalhes');
	cIdcaract_especial = $('#idcaract_especial','#fsetDetalhes');
	cDscaract_especial = $('#dscaract_especial','#fsetDetalhes');
	cFlpermite_saida_operacao = $('#flpermite_saida_operacao','#fsetDetalhes');
	cFlpermite_fluxo_financeiro = $('#flpermite_fluxo_financeiro','#fsetDetalhes');
	cFlreaprov_mensal = $('#flreaprov_mensal','#fsetDetalhes');
	
	cIdproduto.css('width','100px').addClass('inteiro').attr('maxlength','10').desabilitaCampo();
	cDsproduto.css('width','340px').addClass('alphanum').attr('maxlength','150').habilitaCampo();
	cTpdestino.css({ 'width': '150px', 'text-align': 'left' }).habilitaCampo();
	cTparquivo.css({ 'width': '150px', 'text-align': 'left' }).habilitaCampo();
	cIdgarantia.css('width','100px').addClass('inteiro').attr('maxlength','4').habilitaCampo();
	cDsgarantia.css('width','480px').addClass('alphanum').attr('maxlength','200').desabilitaCampo();
	cIdmodalidade.css('width','100px').addClass('inteiro').attr('maxlength','4').habilitaCampo();
	cDsmodalidade.css('width','480px').addClass('alphanum').attr('maxlength','200').desabilitaCampo();
	cIdconta_cosif.css('width','100px').addClass('inteiro').attr('maxlength','7').habilitaCampo();
	cDsconta_cosif.css('width','480px').addClass('alphanum').attr('maxlength','200').desabilitaCampo();
	cIdorigem_recurso.css('width','100px').addClass('inteiro').attr('maxlength','4').habilitaCampo();
	cDsorigem_recurso.css('width','480px').addClass('alphanum').attr('maxlength','200').desabilitaCampo();
	cIdindexador.css('width','100px').addClass('inteiro').attr('maxlength','4').habilitaCampo();
	cDsindexador.css('width','480px').addClass('alphanum').attr('maxlength','200').desabilitaCampo();
    cPerindexador.css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_7').attr('maxlength', '10').habilitaCampo();
    cVltaxa_juros.css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_7').attr('maxlength', '10').habilitaCampo();
    cCdclassifica_operacao.css({ 'width': '150px', 'text-align': 'left' }).habilitaCampo();
	cIdvariacao_cambial.css('width','100px').addClass('inteiro').attr('maxlength','3').habilitaCampo();
	cDsvariacao_cambial.css('width','480px').addClass('alphanum').attr('maxlength','200').desabilitaCampo();
	cIdorigem_cep.css({ 'width': '100px', 'text-align': 'left' }).habilitaCampo();
	cIdnat_operacao.css('width','100px').addClass('inteiro').attr('maxlength','2').habilitaCampo();
	cDsnat_operacao.css('width','480px').addClass('alphanum').attr('maxlength','200').desabilitaCampo();
	cIdcaract_especial.css('width','100px').addClass('inteiro').attr('maxlength','2').habilitaCampo();
	cDscaract_especial.css('width','480px').addClass('alphanum').attr('maxlength','200').desabilitaCampo();
	cFlpermite_saida_operacao.habilitaCampo();
	cFlpermite_fluxo_financeiro.habilitaCampo();
	cFlreaprov_mensal.habilitaCampo();
	
	controlaPesquisas();
	
	// Percorrendo todos os links
    $('input, select', '#frmDetalhes').each(function () {
		
		//Define ação para o campo
		$(this).unbind('keypress').bind('keypress', function (e) {

			$('input,select').removeClass('campoErro');
			
			if (divError.css('display') == 'block') { return false; }

			// Se é a tecla ENTER, TAB
			if (e.keyCode == 13 || e.keyCode == 9) {

				$(this).nextAll('.campo:first').focus();

				return false;
			}
			
		});
		
	});
	
	layoutPadrao();
	
	$('#frmProdutos').css('display','none');
	$('#divBotoesProdutos').css('display','none');
	$('#frmDetalhes').css('display','block');
	$('#divBotoesDetalhes').css('display','block');	
	
    if($('#cddopcao','#frmCabParrgp').val() == 'C'){
		
		todosCampos.desabilitaCampo();
		$('#btVoltar','#divBotoesDetalhes').focus();
		
	}else if($('#cddopcao','#frmCabParrgp').val() == 'E'){
		
		todosCampos.desabilitaCampo();
	    $('#btConcluir','#divBotoesDetalhes').focus();
		
		
	}else{
		
		cDsproduto.focus();
		
	}
	
	return false;
	
}


function controlaPesquisas() {

	// Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas, campoDescricao;
    var nomeForm = 'fsetDetalhes';
	
    /*-------------------------------------*/
    /*       CONTROLE DAS PESQUISAS        */
    /*-------------------------------------*/

    // Atribui a classe lupa para os links e desabilita todos
    $('a', '#' + nomeForm).addClass('lupa').css('cursor', 'auto');

    // Percorrendo todos os links
    $('a', '#' + nomeForm).each(function () {

        if (!$(this).prev().hasClass('campoTelaSemBorda')) { $(this).css('cursor', 'pointer'); }

        $(this).unbind("click").bind("click", (function () {
            if ($(this).prev().hasClass('campoTelaSemBorda')) {
                return false;
            } else {
                campoAnterior = $(this).prev().attr('name');
				
				// Garantia
                if (campoAnterior == 'idgarantia') {
                    filtrosPesq = "Cód. do Domínio;idtipo_dominio;30px;N;8;N|Descrição do Domínio;dstipo_dominio;200px;N;;N";
					colunas 	= 'Valor;dsdvalor;10%;left|Domínio;cddominio;20%;center|Descrição;dsdominio;80%;left#Valor;dsdvalor;10%;left|Domínio;cddominio;10%;center|Descrição;dsdominio;30%;left|Subdomínio;cdsubdominio;20%;left|Descrição;dssubdominio;80%;left';
					camposRetorno = 'dsdvalor|idgarantia;iddominio|iddominio_idgarantia;dstipo_dominio|dsgarantia;nrctacosif|idconta_cosif;dsctacosif|dsconta_cosif;iddominioctacosif|iddominio_idconta_cosif';
					mostraPesquisaDominios("ZOOM0001", "BUSCADOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", "30", filtrosPesq, camposRetorno, colunas, '','','frmDetalhes');                        
					return false;

				// Modalidade
                }else if (campoAnterior == 'idmodalidade') {
                    filtrosPesq = "Cód. do Domínio;idtipo_dominio;30px;N;1;N|Descrição do Domínio;dstipo_dominio;200px;N;;N";
                    colunas 	= 'Valor;dsdvalor;10%;left|Domínio;cddominio;20%;center|Descrição;dsdominio;80%;left#Valor;dsdvalor;10%;left|Domínio;cddominio;10%;center|Descrição;dsdominio;30%;left|Subdomínio;cdsubdominio;20%;left|Descrição;dssubdominio;80%;left';
					camposRetorno = 'iddominio|iddominio_idmodalidade;dsdvalor|idmodalidade;dstipo_dominio|dsmodalidade';
					mostraPesquisaDominios("ZOOM0001", "BUSCADOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", "30", filtrosPesq, camposRetorno, colunas,'','','frmDetalhes');                        
					return false;

                    // Conta COSIF
                } else if (campoAnterior == 'idconta_cosif') {
                    filtrosPesq = "Cód. do Domínio;idtipo_dominio;30px;N;2;N|Descrição do Domínio;dstipo_dominio;200px;N;;N";
                    colunas 	= 'Valor;dsdvalor;10%;left|Domínio;cddominio;20%;center|Descrição;dsdominio;80%;left#Valor;dsdvalor;10%;left|Domínio;cddominio;10%;center|Descrição;dsdominio;30%;left|Subdomínio;cdsubdominio;20%;left|Descrição;dssubdominio;80%;left';
					camposRetorno = 'iddominio|iddominio_idconta_cosif;dsdvalor|idconta_cosif;dstipo_dominio|dsconta_cosif';
					mostraPesquisaDominios("ZOOM0001", "BUSCADOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", "30", filtrosPesq, camposRetorno, colunas, '', '', 'frmDetalhes');
                    return false;

                    // Origem recurso
                } else if (campoAnterior == 'idorigem_recurso') {
                    filtrosPesq = "Cód. do Domínio;idtipo_dominio;30px;N;3;N|Descrição do Domínio;dstipo_dominio;200px;N;;N";
                    colunas 	= 'Valor;dsdvalor;10%;left|Domínio;cddominio;20%;center|Descrição;dsdominio;80%;left#Valor;dsdvalor;10%;left|Domínio;cddominio;10%;center|Descrição;dsdominio;30%;left|Subdomínio;cdsubdominio;20%;left|Descrição;dssubdominio;80%;left';
					camposRetorno = 'iddominio|iddominio_idorigem_recurso;dsdvalor|idorigem_recurso;dstipo_dominio|dsorigem_recurso';
					mostraPesquisaDominios("ZOOM0001", "BUSCADOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", "30", filtrosPesq, camposRetorno, colunas,'','','frmDetalhes');
                    return false;

					//Indexador
                }else if (campoAnterior == 'idindexador') {
                    filtrosPesq = "Cód. do Domínio;idtipo_dominio;30px;N;4;N|Descrição do Domínio;dstipo_dominio;200px;N;;N";
                    colunas 	= 'Valor;dsdvalor;10%;left|Domínio;cddominio;20%;center|Descrição;dsdominio;80%;left#Valor;dsdvalor;10%;left|Domínio;cddominio;10%;center|Descrição;dsdominio;30%;left|Subdomínio;cdsubdominio;20%;left|Descrição;dssubdominio;80%;left';
					camposRetorno = 'iddominio|iddominio_idindexador;dsdvalor|idindexador;dstipo_dominio|dsindexador';
					mostraPesquisaDominios("ZOOM0001", "BUSCADOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", "30", filtrosPesq, camposRetorno, colunas,'','','frmDetalhes');
                    return false;

					//Variação cambial
                }else if (campoAnterior == 'idvariacao_cambial') {
                    filtrosPesq = "Cód. do Domínio;idtipo_dominio;30px;N;5;N|Descrição do Domínio;dstipo_dominio;200px;N;;N";
                    colunas 	= 'Valor;dsdvalor;10%;left|Domínio;cddominio;20%;center|Descrição;dsdominio;80%;left#Valor;dsdvalor;10%;left|Domínio;cddominio;10%;center|Descrição;dsdominio;30%;left|Subdomínio;cdsubdominio;20%;left|Descrição;dssubdominio;80%;left';
					camposRetorno = 'iddominio|iddominio_idvariacao_cambial;dsdvalor|idvariacao_cambial;dstipo_dominio|dsvariacao_cambial';
					mostraPesquisaDominios("ZOOM0001", "BUSCADOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", "30", filtrosPesq, camposRetorno, colunas,'','','frmDetalhes');
                    return false;

					//Natureza operação
                }else if (campoAnterior == 'idnat_operacao') {
                    filtrosPesq = "Cód. do Domínio;idtipo_dominio;30px;N;6;N|Descrição do Domínio;dstipo_dominio;200px;N;;N";
                    colunas 	= 'Valor;dsdvalor;10%;left|Domínio;cddominio;20%;center|Descrição;dsdominio;80%;left#Valor;dsdvalor;10%;left|Domínio;cddominio;10%;center|Descrição;dsdominio;30%;left|Subdomínio;cdsubdominio;20%;left|Descrição;dssubdominio;80%;left';
					camposRetorno = 'iddominio|iddominio_idnat_operacao;dsdvalor|idnat_operacao;dstipo_dominio|dsnat_operacao';
					mostraPesquisaDominios("ZOOM0001", "BUSCADOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", "30", filtrosPesq, camposRetorno, colunas,'','','frmDetalhes');
                    return false;

					//Caracteristica especial
                }else if (campoAnterior == 'idcaract_especial') {
                    filtrosPesq = "Cód. do Domínio;idtipo_dominio;30px;N;7;N|Descrição do Domínio;dstipo_dominio;200px;N;;N";
                    colunas 	= 'Valor;dsdvalor;10%;left|Domínio;cddominio;20%;center|Descrição;dsdominio;80%;left#Valor;dsdvalor;10%;left|Domínio;cddominio;10%;center|Descrição;dsdominio;30%;left|Subdomínio;cdsubdominio;20%;left|Descrição;dssubdominio;80%;left';
					camposRetorno = 'iddominio|iddominio_idcaract_especial;dsdvalor|idcaract_especial;dstipo_dominio|dscaract_especial';
					mostraPesquisaDominios("ZOOM0001", "BUSCADOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", "30", filtrosPesq, camposRetorno, colunas,'','','frmDetalhes');
                    return false;

                }

            }
            return false;
        }));
    });

	
    /*-------------------------------------*/
    /*   CONTROLE DA BUSCA DESCRIÇÕES     */
    /*-------------------------------------*/

    //Garantia
    $('#idgarantia', '#' + nomeForm).unbind('change').bind('change', function () {
		filtrosDesc = 'idtipo_dominio|8';
        buscaDescricao("ZOOM0001", "BUSCADESCDOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", $(this).attr('name'), 'dsgarantia', $(this).val(), 'descricao', filtrosDesc, 'frmDetalhes');
        
		return false;
    });
	
	// Modalidade
    $('#idmodalidade', '#' + nomeForm).unbind('change').bind('change', function () {
		filtrosDesc = 'idtipo_dominio|1';
        buscaDescricao("ZOOM0001", "BUSCADESCDOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", $(this).attr('name'), 'dsmodalidade', $(this).val(), 'descricao', filtrosDesc, 'frmDetalhes');
        
		return false;
    });
	
	// Conta COSIF
    $('#idconta_cosif', '#' + nomeForm).unbind('change').bind('change', function () {
		filtrosDesc = 'idtipo_dominio|2';
        buscaDescricao("ZOOM0001", "BUSCADESCDOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", $(this).attr('name'), 'dsconta_cosif', $(this).val(), 'descricao', filtrosDesc, 'frmDetalhes');
        
		return false;
    });
	
	// Origem recurso
    $('#idorigem_recurso', '#' + nomeForm).unbind('change').bind('change', function () {
		filtrosDesc = 'idtipo_dominio|3';
        buscaDescricao("ZOOM0001", "BUSCADESCDOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", $(this).attr('name'), 'dsorigem_recurso', $(this).val(), 'descricao', filtrosDesc, 'frmDetalhes');
        
		return false;
    });
	
	// Indexador
    $('#idindexador', '#' + nomeForm).unbind('change').bind('change', function () {
		filtrosDesc = 'idtipo_dominio|4';
        buscaDescricao("ZOOM0001", "BUSCADESCDOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", $(this).attr('name'), 'dsindexador', $(this).val(), 'descricao', filtrosDesc, 'frmDetalhes');
        
		return false;
    });
	
	// Variação Cambial
    $('#idvariacao_cambial', '#' + nomeForm).unbind('change').bind('change', function () {
		filtrosDesc = 'idtipo_dominio|5';
        buscaDescricao("ZOOM0001", "BUSCADESCDOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", $(this).attr('name'), 'dsvariacao_cambial', $(this).val(), 'descricao', filtrosDesc, 'frmDetalhes');
        
		return false;
    });
	
	// Natureza Operação
    $('#idnat_operacao', '#' + nomeForm).unbind('change').bind('change', function () {
		filtrosDesc = 'idtipo_dominio|6';
        buscaDescricao("ZOOM0001", "BUSCADESCDOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", $(this).attr('name'), 'dsnat_operacao', $(this).val(), 'descricao', filtrosDesc, 'frmDetalhes');
        
		return false;
    });
	
	// Caracteristica especial
    $('#idcaract_especial', '#' + nomeForm).unbind('change').bind('change', function () {
		filtrosDesc = 'idtipo_dominio|7';
        buscaDescricao("ZOOM0001", "BUSCADESCDOMINIOS", "Sele&ccedil;&atilde;o de Dom&iacute;nio", $(this).attr('name'), 'dscaract_especial', $(this).val(), 'descricao', filtrosDesc, 'frmDetalhes');
        
		return false;
    });
	
	
}

function controlaVoltar(ope){
		
	switch (ope) {
		
		case '1': 
		
			estadoInicial();
			
		break;
		
		case '2': 			
			
			($('#cddopcao','#frmCabParrgp').val() != 'I') ? principal('1','30') : estadoInicial();
			
		break;
				
	}
	
	return false;
	
}

