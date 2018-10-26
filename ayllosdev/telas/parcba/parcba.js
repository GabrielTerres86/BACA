/*!
 * FONTE        : parcba.js
 * CRIAÇÃO      : Alcemir Junior - Mout's
 * DATA CRIAÇÃO : 21/09/2018
 * OBJETIVO     : Biblioteca de funções da tela PARCBA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

var flgVoltarGeral = 1;


$(document).ready(function() {
	// Estado Inicial da tela
	estadoInicial();
	formataTabCon();
	formataTabHis();
	formataTabExc();
	formataTabCad();
	
	
});

function estadoInicial(){
	//Voltar para a tela principal
	flgVoltarGeral = 1;

	$("#divTela").fadeTo(0,0.1);

	hideMsgAguardo();
	//Formatação do cabeçalho

	//Formatacao da tela de Cadastro de Parametros

	formataCabecalho();
	
	formataCadastroParametro();
	
	formataConsultaParametro();
    
	formataOpcaoParametrizacao();

	formataExclusaoParametro();
	// fim formatacao

	removeOpacidade("divTela");

	highlightObjFocus( $("#frmCab") );

	//Exibe cabeçalho e define tamanho da tela
	$("#frmCab").css({"display":"block"});
	$("#divTela").css({"width":"700px","padding-bottom":"2px"});

	$("#divCadastroParametro").css({"display":"none"});
	$("#divConsultaParametro").css({"display":"none"});
	$("#divExcluirParametro").css({"display":"none"});
		
    
	//Esconder os botões da tela
	$("#divBotoes").css({"display":"none"});

	//Foca o campo da Opção
	$("#cddotipo","#frmCab").focus();
}

function formataExclusaoParametro(){
	
	// rotulo
	$('label[for="cdtransa"]',"#frmExcParametro").css({"width":"47px"});
	$('label[for="dstransa"]',"#frmExcParametro").css({"width":"67px"});	
	$('label[for="indebcre"]',"#frmExcParametro").css({"width":"27px"});	

	// campo
	$("#cdtransa","#frmExcParametro").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5").habilitaCampo();
	$("#indebcre","#frmExcParametro").habilitaCampo();
	
	$("#fsexcpar","#frmExcParametro").css({"display":"none"});


	$("#cdtransa","#frmExcParametro").unbind('keydown').bind('keydown', function(e){   		
        
        /* 
         * verifica se o evento é Keycode (para IE e outros browsers)
         * se não for pega o evento Which (Firefox)
         */
        var tecla = (e.keyCode?e.keyCode:e.which);
                    
        /* verifica se a tecla pressionada foi o ENTER ou TAB*/
        if(tecla == 13 || tecla == 9){
            IniciaExclusao();
			return false;
        }
    });

    /*
    //  Define ação para o campo de código da historico ailos
	$("#cdtransa","#frmExcParametro").unbind('keypress').bind('keypress', function(e) {
		
		var tecla = (e.keyCode?e.keyCode:e.which);
		
		
		
		if (tecla == 9 || tecla == 13) {
			IniciaExclusao();
			return false;
		}
    });	
    
    */

	return false;
    
}

function formataConsultaParametro(){

    // rotulo
	$('label[for="cdtrnasa"]',"#frmConParametro").css({"width":"120px"});
	$('label[for="cdhistor"]',"#frmConParametro").css({"width":"95px"});	
		
	// campo
	$("#cdtransa","#frmConParametro").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5").habilitaCampo();
	$("#cdhistor","#frmConParametro").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5").habilitaCampo();
    
    $('#tabConcon','#frmConParametro').hide();
    $('#tabConhis','#frmConParametro').hide();

    
    //  Define ação para o campo de código d
	$("#cdtransa","#frmConParametro").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			consultaParametro();
			return false;
		}
    });	
	

}

function formataCabecalho() {
	// rotulo
	$('label[for="cddotipo"]',"#frmCab").addClass("rotulo").css({"width":"100px"}); 
	
	// campo
	$("#cddotipo","#frmCab").css("width","500px").habilitaCampo();
	
	$('input[type="text"],select','#frmCab').limpaFormulario().removeClass('campoErro');
	layoutPadrao();
	
	//Define ação para ENTER e TAB no campo Opção
	$("#cddotipo","#frmCab").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa função do botão OK
			liberaFormulario();
			return false;
		}
    });	
	
	//Define ação para CLICK no botão de OK
	$("#btnOK","#frmCab").unbind('click').bind('click', function() {
		liberaFormulario();
		return false;
    });	
	return false;	
}

function liberaFormulario(){
	var cddotipo = $("#cddotipo","#frmCab");

	if(cddotipo.prop("disabled")){
		// Se o campo estiver desabilitado, não executa a liberação do formulário pois já existe uma ação sendo executada
		return;
	}

	cddotipo.desabilitaCampo();

	// Validar a opção que foi selecionada na tela
	switch(cddotipo.val()){
		case "I": // Inclusão
			estadoInicialCadastro();
		break;

		case "C": // Consulta
			estadoInicialConsulta();			
		break;

		case "E": // Exclusão
			estadoInicialExclusao();
		break;

		default:
			estadoInicial();
		break;
	}
}

function controlaVoltar(){
	estadoInicial();
}

function controlaConcluir(){

	var cdtransa = $('#cdtransa','#frmCadParametro').val();
    var dstransa = $('#dstransa','#frmCadParametro').val();
    var indebcre = $('#indebcre','#frmCadParametro').val();

	if (cdtransa != "" && dstransa != "" && indebcre != ""){


		switch($("#cddotipo","#frmCab").val()){
			case "I": // Inclusão
				//Quando for inclusão, solicita confirmação
				showConfirmacao('Confirma a inclus&atilde;o do Parametro?','Confirma&ccedil;&atilde;o - Aimaro','confirmouOperacaoParametro();','','sim.gif','nao.gif');
			break;

			case "A": // Alteração
				//Quando for alteração, solicita confirmação
				showConfirmacao('Confirma a altera&ccedil;&atilde;o do Parametro?','Confirma&ccedil;&atilde;o - Aimaro','confirmouOperacaoParametro();','','sim.gif','nao.gif');
			break;

		}

	}

}

function estadoInicialExclusao(){
	

	//Retorna para a principal
	flgVoltarGeral = 1;
	hideMsgAguardo();	
	removeOpacidade("divTela");


	$("#tbCadpar > tbody").html("");
	$("#tbCadpar > thead").html("");
	$("#tbConhis > tbody").html("");
	$("#tbConhis > thead").html("");
	$("#tbConcon > tbody").html("");
	$("#tbConcon > thead").html("");
    $("#tbExcpar > tbody").html("");
	$("#tbExcpar > thead").html("");

	$("#btConcluir","#divBotoes").hide();
	$("#btExcluir","#divBotoes").show();

	$("#divExcluirParametro").css({"display":"block"});
	$("#tabExcpar").css({"display":"block"});
	
    $("#divBotoes").css({"display":"block"});
     $("#indebcre","#frmExcParametro").habilitaCampo();
     $("#cdtransa","#frmExcParametro").habilitaCampo();

     //Exibe cabeçalho e define tamanho da tela
	$("#frmExcParametro","#divExcluirParametro").css({"display":"block"});
    
    formataExclusaoParametro();

    $('input[type="text"],select','#frmExcParametro').limpaFormulario().removeClass('campoErro');

    $('#cdtransa','#frmExcParametro').focus();
}

function controlaExcluir(){
	
	var cdtransa = $("#cdtransa","#frmExcParametro").val();

	if (cdtransa != ""){
		showConfirmacao('Confirma a Exclus&atilde;o do Parametro?','Confirma&ccedil;&atilde;o - Aimaro','confirmouExclusao();','','sim.gif','nao.gif');		
	}

}

function confirmouExclusao(){
	
	var cdtransa = $("#cdtransa","#frmExcParametro").val();

	if (cdtransa != ""){
		
		manterParametro("E",cdtransa,"","","","");	
	}
	

}

function finalizaExclusao(){

	showError('inform','Exclus&atilde;o efetuada com sucesso!','Alerta - Aimaro','estadoInicialExclusao();');

}

function estadoInicialCadastro(){
	//Retorna para a principal
	flgVoltarGeral = 1;

	hideMsgAguardo();

	removeOpacidade("divTela");

	$("#tbCadpar > tbody").html("");
	$("#tbCadpar > thead").html("");
	$("#tbConhis > tbody").html("");
	$("#tbConhis > thead").html("");
	$("#tbConcon > tbody").html("");
	$("#tbConcon > thead").html("");

	$("#divCadastroParametro").css({"display":"block"});


	//Esconde cadastro e os botões
	$("#divBotoes").css({"display":"block"});
	$("#btConcluir","#divBotoes").show();
	$("#btExcluir","#divBotoes").hide();

	//Exibe cabeçalho e define tamanho da tela
	$("#frmCadParametro","#divCadastroParametro").css({"display":"block"});

	//Limpa os campos do formulário e remove o erro dos campos
	$('input[type="text"],select','#frmCadParametro').limpaFormulario().removeClass('campoErro');

	formataCadastroParametro();
	formataOpcaoParametrizacao();


    $('#cdtransa','#frmCadParametro').focus();

}

function estadoInicialConsulta(){
	//Retorna para a principal
	flgVoltarGeral = 1;
	hideMsgAguardo();
	removeOpacidade("divTela");
	
	$("#tbCadpar > tbody").html("");
	$("#tbCadpar > thead").html("");
	$("#tbConhis > tbody").html("");
	$("#tbConhis > thead").html("");
	$("#tbConcon > tbody").html("");
	$("#tbConcon > thead").html("");

	$("#divConsultaParametro").css({"display":"block"});

	//Esconde cadastro e os botões
	$("#divBotoes").css({"display":"block"});
	
	//Exibe cabeçalho e define tamanho da tela
	$("#frmConParametro","#divConsultaParametro").css({"display":"block"});
	
	// Esconder o botão de Concluir
	$("#btConcluir","#divBotoes").hide();
	$("#btExcluir","#divBotoes").hide();

	//Limpa os campos do formulário e remove o erro dos campos
	$('input[type="text"],select','#frmConParametro').limpaFormulario().removeClass('campoErro');

	$("#cdtransa","#frmConParametro").focus();

}

function estadoInicialAlteracao(){
	//Retorna para a principal
	flgVoltarGeral = 1;

	hideMsgAguardo();

	removeOpacidade("divTela");

	$("#tbCadpar > tbody").html("");
	$("#tbCadpar > thead").html("");
	$("#tbConhis > tbody").html("");
	$("#tbConhis > thead").html("");
	$("#tbConcon > tbody").html("");
	$("#tbConcon > thead").html("");	


	//Esconde cadastro e os botões
	$("#divBotoes").css({"display":"block"});
	$("#btConcluir","#divBotoes").show();
	
}

function formataCadastroParametro(){

    $("#cdtransa","#frmCadParametro").habilitaCampo();
    $("#dstransa","#frmCadParametro").habilitaCampo();
    $("#indebcre","#frmCadParametro").habilitaCampo();
    $("#fscadhis","#frmCadParametro").css({"display":"none"});
    $("#tbCadpar > tbody").html("");
    
    

    $("#cdhistor","#frmCadParametro").unbind('keydown').bind('keydown', function(e){   		
        /* 
         * verifica se o evento é Keycode (para IE e outros browsers)
         * se não for pega o evento Which (Firefox)
        */
        var tecla = (e.keyCode?e.keyCode:e.which);
                    
        /* verifica se a tecla pressionada foi o ENTER ou TAB*/
        if(tecla == 13 || tecla == 9){
            buscaDesHistoricoAilos($("#cdhistor","#frmCadParametro").val());
			return false;
        }
    });
    /*
	//Define ação para o campo de código do historico ailos
	$("#cdhistor","#frmCadParametro").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {

			buscaDesHistoricoAilos($("#cdhistor","#frmCadParametro").val());
			return false;
		}
    });*/

	return false;

}

function buscaDesHistoricoAilos(cdhistor){
		   
    if (cdhistor != ""){
       manterParametro("BH","",cdhistor,"","","");	//buscar descrição historico ailos
    }

}

function formataTabCad() {
	// Tabela
	var divRegistro = $("div.divRegistros", "#tabCadpar");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

	$("#tabCadpar").css({"margin-top":"5px"});
	divRegistro.css({"height":"170px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "80px";
    arrayLargura[1] = "";
	arrayLargura[2] = "50px";
	arrayLargura[3] = "80px";

	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "right";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "center";
	arrayAlinha[3] = "center";

	//Aplica as informações na tabela
	$(".ordemInicial","#tabCadpar").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	//
	
	return false;
}

function formataTabCon() {
	// Tabela de Consulta parametro
	var divRegistro = $("div.divRegistros", "#tabConcon");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

	$("#tabConcon").css({"margin-top":"5px"});
	divRegistro.css({"height":"230px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "80px";
    arrayLargura[1] = "";
    arrayLargura[2] = "80px";

	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "left";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "center";

	//Aplica as informações na tabela
	$(".ordemInicial","#tabConcon").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);


	// seleciona o registro que é focado
	ConsultaHistoricoAilos($("tr:first-child","#tbConcon"));	
	

	return false;

}

function formataTabExc() {
	// Tabela 
	var divRegistro = $("div.divRegistros", "#tabExcpar");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

	$("#tabExcpar").css({"margin-top":"5px"});
	divRegistro.css({"height":"290px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "80px";
    arrayLargura[1] = "";
    arrayLargura[2] = "80px";

	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "left";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "center";

	//Aplica as informações na tabela
	$(".ordemInicial","#tabExcpar").remove();
	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

	return false;

}


function formataTabHis() {
	// Tabela
	var divRegistro = $("div.divRegistros", "#tabConhis");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabConhis").css({"margin-top":"5px"});
	divRegistro.css({"height":"200px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "80px";
    arrayLargura[1] = "";
    arrayLargura[2] = "80px";

	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "right";
	arrayAlinha[1] = "left";
    arrayAlinha[2] = "center";

	//Aplica as informações na tabela
	$(".ordemInicial","#tabConhis").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	return false;
}


function formataOpcaoParametrizacao(){

	// rotulo
	$('label[for="cdtr"]',"#frmCadParametro").css({"width":"47px"});
	$('label[for="dstransa"]',"#frmCadParametro").css({"width":"67px"});	
	$('label[for="indebcre"]',"#frmCadParametro").css({"width":"27px"});	

    $('label[for="cdhistor"]',"#frmCadParametro").css({"width":"47px"});
	$('label[for="dshistor"]',"#frmCadParametro").css({"width":"67px"});	
	$('label[for="indebcre1"]',"#frmCadParametro").css({"width":"27px"});	

	// campo
	$("#cdtransa","#frmCadParametro").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5");
	$("#dstransa","#frmCadParametro").addClass("campo").css({"width":"200px"}).attr("maxlength","50").habilitaCampo();
	$("#indebcre","#frmCadParametro").css("width","35px");
     
    
    $("#cdhistor","#frmCadParametro").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5");	
	$("#indebcre1","#frmCadParametro").css("width","35px");

    $("#btnOK","#frmCadParametro").show();  
    $("#btnIncluirTransacao","#frmCadParametro").hide();        
    $("#btnAlterarTransacao","#frmCadParametro").hide();

    $("#fscadtra","#frmCadParametro").css({"display":"block"});  


   $("#cdtransa","#frmCadParametro").unbind('keydown').bind('keydown', function(e){   		
        /* 
         * verifica se o evento é Keycode (para IE e outros browsers)
         * se não for pega o evento Which (Firefox)
        */
        var tecla = (e.keyCode?e.keyCode:e.which);
                    
        /* verifica se a tecla pressionada foi o ENTER ou TAB*/
        if(tecla == 13 || tecla == 9){
            buscaDesTrasacaoBancoob("BT",$("#cdtransa","#frmCadParametro").val());
			return false;	
        }
    });
/*
	//Define ação para o campo de código do operador
	$("#cdtransa","#frmCadParametro").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			buscaDesTrasacaoBancoob("BT",$("#cdtransa","#frmCadParametro").val());
			return false;
		}
    });	*/

	return false;

}

function setarDestransacaoBancoob(cddopcao,cdtransa,dstransa,indebcre){

	if (dstransa != ""){		
		$("#dstransa","#frmCadParametro").val(dstransa);
		$("#indebcre","#frmCadParametro").val(indebcre);
        $("#dstransa","#frmExcParametro").val(dstransa);
		$("#indebcre","#frmExcParametro").val(indebcre);		
		
		$("#btnIncluirTransacao","#frmCadParametro").hide();  	
        $("#btnAlterarTransacao","#frmCadParametro").show();

        var cddopcaohist;

        // se for buscar da transacao da opção exclusao 
        if (cddopcao == "BTE"){
        	cddopcaohist = "BLHE";
        }
        if (cddopcao == "BT"){
        	cddopcaohist = "BLH";	
        }

        carregaHistoricoAilos(cdtransa,cddopcaohist);
           
	}else{	
		// gera mesnagem apenas se for busca transacao pela opcao excluir
		if (cddopcao == "BTE"){
			showError('alert','Parametro n&atilde;o encontrado!','Alerta - Aimaro','estadoInicialExclusao()');	
		}
		
        $("#btnIncluirTransacao","#frmCadParametro").show();                        	    	    
        $("#btnAlterarTransacao","#frmCadParametro").hide();
        $("#dstransa","#frmCadParametro").focus();

    }
}





function buscaDesTrasacaoBancoob(cddopcao,cdtransa){
	

	if (cdtransa != ""){
       manterParametro(cddopcao,cdtransa,"","","","");	//buscar descrição historico ailos
    }

}

function alterarTransacaoBancoob(){

	$("#cdtransa","#frmCadParametro").habilitaCampo();
	$("#dstransa","#frmCadParametro").habilitaCampo();
	$("#indebcre","#frmCadParametro").habilitaCampo();
    $("#cdtransa","#frmCadParametro").focus();

}


function carregaHistoricoAilos(cdtransa,cddopcao){
		
		              
        $("#cdtransa","#frmCadParametro").desabilitaCampo();
		$("#dstransa","#frmCadParametro").desabilitaCampo();
		$("#indebcre","#frmCadParametro").desabilitaCampo();
		$("#cdtransa","#frmExcParametro").desabilitaCampo();
		$("#dstransa","#frmExcParametro").desabilitaCampo();
		$("#indebcre","#frmExcParametro").desabilitaCampo();		
        $("#btnIncluirTransacao","#frmCadParametro").hide();     

        IniciaHistoricoAilos();
        //caso já cadastrado, deve carregar os historicos ailos na tabela
        
        buscaLinhaCadastroHistorico(cdtransa,cddopcao);        

}

function confirmouOperacaoParametro(){

	//Recupera a opção
	var cddopcao = $("#cddotipo","#frmCab").val();
	var mensagem = "Aguarde ...";
	var cdtransa = $("#cdtransa","#frmCadParametro").val();
    var dstransa = $("#dstransa","#frmCadParametro").val();
    var indebcre_transa = $("#indebcre","#frmCadParametro").val();    
    var lscdhistor = '';
    var lsindebcre = '';

	//Atualiza a mensagem que será exibida
	if(cddopcao == "I") {
		mensagem = "Aguarde, incluindo Parametro ...";
	} else if (cddopcao == "A") {
		mensagem = "Aguarde, alterando Parametro ...";
	}else if (cddopcao == "E"){
		mensagem = "Aguarde, Excluindo Parametro ...";
	}

	//mostra mensagem e finaliza a operação
	showMsgAguardo( mensagem );	

	if (cddopcao == "I") {
		//devemos deletar os historicos ailos e inserilos novamente		
		// neste caso devemos chamar primeiro a exclusao 
				
		showMsgAguardo( mensagem );	
		$('#tbCadpar > tbody > tr').each(function(){	
			//concatena cada linha da tabela de historicos ailos
		    // EX: 1566;1548  e D;C	
			if (lscdhistor == ''){
				lscdhistor = $("td:eq(0)", $(this)).html();
			}else{
 				lscdhistor = lscdhistor + ';' + $("td:eq(0)", $(this)).html();
			}

			if (lsindebcre == ''){
				lsindebcre = $("td:eq(2)", $(this)).html();
			}else{
				lsindebcre = lsindebcre + ';' + $("td:eq(2)", $(this)).html();
			}
						
		});
		
		InserirParametro(cddopcao,cdtransa,"",dstransa,indebcre_transa,"",lscdhistor,lsindebcre);
		
		
		showError('inform','Inclu&iacute;do com sucesso.','Alerta - Aimaro','estadoInicialCadastro();');

	}

}

function InserirParametro(cddopcao,cdtransa,cdhistor,dstransa,indebcre_transa,indebcre_histor,lscdhistor,lsindebcre){

	$.ajax({
        type: "POST",
        url: UrlSite + "telas/parcba/incluir_historico.php",
        data: {
            cddopcao:     cddopcao,
			cdtransa:     cdtransa,
			cdhistor:     cdhistor,	
			indebcre_transa:     indebcre_transa,
			indebcre_histor:     indebcre_histor,
			lscdhistor:          lscdhistor,
			lsindebcre:          lsindebcre,
			dstransa:            dstransa,			
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
           hideMsgAguardo();
			try {
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}
		}
    });

    return false;

}

function ExcluirTransacao (cdtransa){
	
	if (cdtransa != ""){
	   manterParametro("EH",cdtransa,"","","","");	
	}
	
}


function criaLinhaHistorico(cdhistor,dshistor,indebcre){	
	// Criar a linha na tabela
	$("#tbConhis > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(cdhistor))
			.append($('<td>') 
				.attr('style','width: 80px; text-align:right')
				.text(cdhistor)
			)
			.append($('<td>')  
				.attr('style','text-align:left')
				.text(dshistor)
			)
			.append($('<td>') 
				.attr('style','width: 80px; text-align:center')
				.text(indebcre)
			)
		);
}

function mostraTabelasConsulta(){
	$('#tabConcon','#frmConParametro').show();
	$('#tabConhis','#frmConParametro').show();
}

function criaLinhaTransacao(cdtransa,dstransa,indebcre){
     
    if (dstransa != ""){

    	mostraTabelasConsulta();

    	let tr = $('<tr>') // Linha
			.attr('id',"id_".concat(cdtransa))
			.append($('<td>') // Coluna: Cód. transacao
				.attr('style','width: 80px; text-align:right')
				.text(cdtransa)
			)
			.append($('<td>') // Coluna: Des. transacao
				.attr('style','text-align:left')
				.text(dstransa)
			)
			.append($('<td>') // Coluna: D/C
				.attr('style','text-align:center')
				.text(indebcre)
			);

			//onclick=

			$(tr).unbind('click').bind('click',function(){
				ConsultaHistoricoAilos(this);
			});



		$("#tbConcon > tbody")
		.append($(tr));

	}else{
		showError('alert','Parametro n&atilde;o encontrado!','Alerta - Aimaro','estadoInicialConsulta()');
	}

}

function criaLinhaCadastroHistorico(cddopcao,cdhistor,dshistor,indebcre){

	if (cddopcao == "BLH"){
	// Criar a linha na tabela
	$("#tbCadpar > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(cdhistor))
			.append($('<td>') // Coluna: Cód. Historico
				.attr('style','width: 80px; text-align:right')
				.text(cdhistor)
			)
			.append($('<td>') // Coluna: Des. Historico
				.attr('style','text-align:left')
				.text(dshistor)
			)
			.append($('<td>') // Coluna: D/C
				.attr('style','text-align:center')
				.text(indebcre)
			)	
			.append($('<td>') // Coluna: Botão para REMOVER
				.attr('style','width: 80px; text-align:center')
				.append($('<img onclick="excluirLinhaHistorico(this)">')
					.attr('src', UrlImagens + 'geral/btn_excluir.gif')
				)
			)	
					
		);
	}

	if (cddopcao == "BLHE"){

    $("#tbExcpar > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(cdhistor))
			.append($('<td>') // Coluna: Cód. Historico
				.attr('style','width: 80px; text-align:right')
				.text(cdhistor)
			)
			.append($('<td>') // Coluna: Des. Historico
				.attr('style','text-align:left')
				.text(dshistor)
			)
			.append($('<td>') // Coluna: D/C
				.attr('style','text-align:center')
				.text(indebcre)
			)			
					
		);

}
}


function excluirLinhaHistorico(linha) {

	$(linha).closest('tr').remove();	
}

function limpaTabelaHistorico() {	
	
	$("#tbCadpar > tbody").html("");
	$("#tbConhis > tbody").html("");
	$("#tbExcpar > tbody").html("");

}

function limpaTabelaTransacao(){
	$("#tbConcon > tbody").html("");
}

function limpaTabelaExlcusao(){
	$("#tbExcpar > tbody").html("");

}

function selecionaLinhaConsulta(linha) {
	linha.style.backgroundColor = "";	
}

function ConsultaHistoricoAilos(linha) {
		
	var cdtransa = $("td:eq(0)", linha ).html();
	
	if (cdtransa != null){			
	  	manterParametro("CH",cdtransa,"","","","");		
    }	

	
}

function setarDesHistoricoAilos(dshistor){
	$("#dshistor","#frmCadParametro").val(dshistor);
}

function manterParametro(cddopcao,cdtransa,cdhistor,dstransa,indebcre_transa,indebcre_histor){
    //Requisição para processar a opção que foi selecionada
    var lscdhistor = '';
    var lsindebcre = '';

	$.ajax({
        type: "POST",
        url: UrlSite + "telas/parcba/manter_rotina_parametro.php",
        data: {
            cddopcao:     cddopcao,
			cdtransa:     cdtransa,
			cdhistor:     cdhistor,	
			indebcre_transa:     indebcre_transa,
			indebcre_histor:     indebcre_histor,
	        lscdhistor:          lscdhistor,
			lsindebcre:          lsindebcre,
			dstransa:     dstransa,			
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
           hideMsgAguardo();
			try {
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}
		}
    });
    return false;
}

function consultaParametro(){
 
  limpaTabelaHistorico();
  var cdtransa = $("#cdtransa","#frmConParametro").val();
  var cdhistor = $("#cdhistor","#frmConParametro").val();

  manterParametro("C",cdtransa,cdhistor,"","","");
        
}

function incluirTransacaoBancoob() {
	
    var cdtransa = $("#cdtransa","#frmCadParametro").val();
    var dstransa = $("#dstransa","#frmCadParametro").val();
     
    if (dstransa == ""){       
    	buscaDesTrasacaoBancoob("BT",cdtransa);
    }else{
    	carregaHistoricoAilos(cdtransa,"BLH");
    	$("#cdhistor","#frmCadParametro").focus();
    }
       
}

function IniciaExclusao(){	
		
	var cdtransa = $("#cdtransa","#frmExcParametro").val();
    
	if (cdtransa != ""){
		//showConfirmacao
	 	buscaDesTrasacaoBancoob('BTE',cdtransa);
	}

}

function IniciaHistoricoAilos(){
	$("#fscadhis","#frmCadParametro").css({"display":"block"});
	$("#fsexcpar","#frmExcParametro").css({"display":"block"});
}

function buscaLinhaCadastroHistorico(cdtransa,cddopcao){
	
	if (cdtransa != ""){
		manterParametro(cddopcao,cdtransa,"","","","");
	}

}

function limpaCamposHistorico(){
    $("#cdhistor","#frmCadParametro").val('');
	$("#dshistor","#frmCadParametro").val('');	
	$("#indebcre1","#frmCadParametro").val('C');
	$("#cdhistor","#frmCadParametro").focus();

}

function incluirHistoricoAilos(){

	var cdhistor = $("#cdhistor","#frmCadParametro").val();
	var dshistor = $("#dshistor","#frmCadParametro").val();	
	var indebcre = $("#indebcre1","#frmCadParametro").val();

	if (cdhistor != "" && dshistor != "" && indebcre != ""){	 	
	    criaLinhaCadastroHistorico("BLH",cdhistor,dshistor,indebcre);
	    formataTabCad();	
        limpaCamposHistorico();
	}

}