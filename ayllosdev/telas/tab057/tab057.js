/*!
 * FONTE        : tab057.js
 * DATA CRIAÇÃO : 19/01/2018
 * OBJETIVO     : Biblioteca de funções da tela TAB057
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Definir a quantidade de registros que devem ser carregados nas consultas 
var nrregist = 50; 
	
$(document).ready(function() {
	estadoInicial();
	return false;
});

/**
 * Funcao para o estado inicial da tela
 * Formatacao dos campos e acoes da tela
 */
function estadoInicial() {
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	
	// Formatar o layout da tela
  formataBotoes();
	formataCabecalho();
  formataFormularioSicredi();
  controlaNavegacaoFrmSicredi();
  formataFiltros();
  //formataFormularioBancoob();

	removeOpacidade('divTela');
	highlightObjFocus( $('#frmCab') ); 
	
  // esconder os formulários da tela
  $('#frmFiltros').css({'display':'none'});
  $('#frmDadosSicredi').css({'display':'none'});
  
	// esconder os botoes da tela
	$('#divBotoes').css({'display':'none'});
	$('#frmCab').css({'display':'block'});
	$('#divTela').css({'width':'700px','padding-bottom':'2px'});
	
	// Ajustar o label do botao "Prosseguir"
	trocaBotao("Prosseguir");
	
	// Adicionar o foco no campo de OPCAO 
	$("#cddopcao","#frmCab").focus();
  
  hideMsgAguardo();
}

/**
 * Formatacao dos campos do cabecalho
 */
function formataCabecalho() {
  
	// Labels
	$('label[for="cddopcao"]',"#frmCab").addClass("rotulo").css({"width":"60px"});
  $('label[for="cdagente"]',"#frmCab").addClass("rotulo-liha").css({"width":"60px"});
	
	// Campos
	$("#cddopcao","#frmCab").css("width","150").habilitaCampo();
  $("#cdagente","#frmCab").css("width","150").habilitaCampo();
	
	$('input[type="text"],select','#frmCab').limpaFormulario().removeClass('campoErro');
	
	//Define ação para ENTER e TAB no campo Opção
	$("#cdagente","#frmCab").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
      exibeFormulario();
			return false;
		}
    });	
	
	//Define ação para CLICK no botão de OK
	$("#btnOK","#frmCab").unbind('click').bind('click', function() {
    exibeFormulario();
		// Remover o click do botao, para nao executar mais de uma vez
		$(this).unbind('click');
		return false;
    });	
	
	layoutPadrao();
  
	return false;	
}

/**
 * Formatacao dos campos do filtro de consulta
 */
function formataFiltros(){
  // Limpar todos os campos do formulario, e remover o destaque dos campos com erro
	$('input[type="text"],select','#fsetFiltroConsultar').limpaFormulario().removeClass('campoErro');
  
  // LABEL - Filtro
  $('label[for="tlcooper"]','#frmFiltros').addClass('rotulo').css({'width':'75'});
  $('label[for="cdempres"]','#frmFiltros').addClass('rotulo').css({'width':'75'});
  $('label[for="dtiniper"]','#frmFiltros').addClass('rotulo').css({'width':'75'});
  $('label[for="dtfimper"]','#frmFiltros').addClass('rotulo-linha').css({'width':'15','text-align':'center'});
  $('label[for="nmarquiv"]','#frmFiltros').addClass('rotulo').css({'width':'75'});
  $('label[for="nrsequen"]','#frmFiltros').addClass('rotulo').css({'width':'75'});
   
  // CAMPOS - Filtro
  if ($('#glcooper','#frmCab').val() == '3') {
    $('#tlcooper','#frmFiltros').habilitaCampo();
  } else {
    document.getElementById('tlcooper').value = $('#glcooper','#frmCab').val();
    $('#tlcooper','#frmFiltros').desabilitaCampo();
  }
  $('#tlcooper','#frmFiltros').css({'width':'100px'});
  $('#cdempres','#frmFiltros').addClass('inteiro').css({'width':'100px'}).habilitaCampo();
  $('#nmextcon','#frmFiltros').css({'width':'300'}).desabilitaCampo();
  $('#dtiniper','#frmFiltros').css({'width':'75px','text-align':'right'}).habilitaCampo().addClass('inteiro').attr('maxlength','14').setMask("DATE","","","");
  $('#dtiniper','#frmFiltros').val(dtmvtglb);
  $('#dtfimper','#frmFiltros').css({'width':'75px','text-align':'right'}).habilitaCampo().addClass('inteiro').attr('maxlength','14').setMask("DATE","","","");
  $('#dtfimper','#frmFiltros').val(dtmvtglb);
  $('#nmarquiv','#frmFiltros').css({'width':'245px','text-align':'left'}).desabilitaCampo().addClass('alphanum').attr('maxlength','24');
  $('#nrsequen','#frmFiltros').addClass('inteiro').css({'width':'100px'}).desabilitaCampo();
  
   
  $('a','#frmFiltros').addClass('lupa').css('cursor', 'pointer').css({'width':'15','text-align':'center'});
  $('a','#frmFiltros').unbind('click').bind('click', function() {
    bo          = 'TAB057'
    procedure   = 'TAB057_LISTA_CONVENIOS';
    titulo      = 'Convênios de Arrecadação';
    qtReg       = '20';
    filtrosPesq = 'Codigo;cdempres;70px;S;;S;codigo|Descricao;nmextcon;200px;S;;S;descricao|;cdcooper;;N;' + $('#tlcooper','#frmFiltros').val() + ';N;codigo';
    colunas     = 'Codigo;cdempres;30%;center|Descricao;nmextcon;70%;left';
    mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
    
    return false;
  })

	// Esconder a tela de filtros
	$('#frmFiltros').css({'display':'none'});
	highlightObjFocus( $('#frmFiltros') ); 
	
	// Controlar o foco dos campos quando pressionar TAB ou ENTER
	controlaCamposFiltroConsulta();

	layoutPadrao();
	
	return false;
}

/**
 * Função para validar as datas
 */
 function validaPeriodo() {
   if ($('#dtiniper','#frmFiltros').val() != '' && $('#dtfimper','#frmFiltros').val() != '') {
			var date1 = $('#dtiniper','#frmFiltros').val();
			var date2 = $('#dtfimper','#frmFiltros').val();
			var newDate1 = new Date();
			var newDate2 = new Date();
			newDate1.setFullYear(date1.substr(6,4),(date1.substr(3,2) - 1),date1.substr(0,2));
			newDate2.setFullYear(date2.substr(6,4),(date2.substr(3,2) - 1),date2.substr(0,2));

			if (newDate2 < newDate1) {
				showError("error","Data inválida.","Alerta - Ayllos","");
        $('#dtfimper','#frmFiltros').focus();
        return false;
			}
		} else {
      showError("error","Data inválida.","Alerta - Ayllos","");
      $('#dtfimper','#frmFiltros').focus();
      return false
    }
    return true;
 }

/**
 * Formatação dos campos quando selecionado a opção Sicredi
 */
 function formataFormularioSicredi() {
   // LABEL
   $('label[for="seqarfat"]','#frmDadosSicredi').addClass('rotulo').css({'width':'200px'});
   $('label[for="seqtrife"]','#frmDadosSicredi').addClass('rotulo').css({'width':'200px'});
   $('label[for="seqconso"]','#frmDadosSicredi').addClass('rotulo').css({'width':'200px'});
   
   // CAMPOS - Dados Gerais
	$('#seqarfat','#frmDadosSicredi').addClass('inteiro').css({'width':'60px'});
  $('#seqtrife','#frmDadosSicredi').addClass('inteiro').css({'width':'60px'});
  $('#seqconso','#frmDadosSicredi').addClass('inteiro').css({'width':'60px'});
   
   layoutPadrao();
   
   return false;
 }
 
/**
 * Formatação dos campos quando selecionado a opção Bancoob
 */
 function formataFormularioBancoob() {
   
   
 }
 
/**
 * Controla a navegação no formulário Sicredi
 */
 function controlaNavegacaoFrmSicredi() {
   
   $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function(e) {
      if (e.keyCode == 9 || e.keyCode == 13) {
        $('#cdagente', '#frmCab').focus();
        return false;
      }
    });
    
    $('#seqarfat', '#frmDadosSicredi').unbind('keypress').bind('keypress', function(e) {
      if (e.keyCode == 9 || e.keyCode == 13) {
        $('#seqtrife', '#frmDadosSicredi').focus();
        return false;
      }
    });
    
    $('#seqtrife', '#frmDadosSicredi').unbind('keypress').bind('keypress', function(e) {
      if (e.keyCode == 9 || e.keyCode == 13) {
        $('#seqconso', '#frmDadosSicredi').focus();
        return false;
      }
    });
    
    $('#seqconso', '#frmDadosSicredi').unbind('keypress').bind('keypress', function(e) {
      if (e.keyCode == 9 || e.keyCode == 13) {
        prosseguir();
        return false;
      }
    });
 }

/**
 * Formatacao dos botoes da tela
 */
function formataBotoes(){
	//Define ação para CLICK no botão de VOLTAR
	$("#btVoltar","#divBotoes").unbind('click').bind('click', function() {
		// Realizar o voltar da tela de acordo com a OPCAO selionada
		voltar();
		return false;
    });	

	//Define ação para CLICK no botão de Prosseguir
	$("#btSalvar","#divBotoes").unbind('click').bind('click', function() {
		// Realizar a acao de prosseguir de acordo com a OPCAO selecionada
		prosseguir();
		return false;
    });	

	layoutPadrao();

	return false;
}

/**
 * Função para exibir o formulário de acordo com o agente selecionado
 */
function exibeFormulario() {
  //Sicredi
  if ($("#cdagente","#frmCab").val() == 'S') {
    $('#frmDadosSicredi').css({'display':'block'});
    //Consulta
    if ($("#cddopcao","#frmCab").val() == 'C') {
      $("#btSalvar", "#divBotoes").hide();
      $("#btVoltar", "#divBotoes").focus();
    //Alteração
    } else {
      $("#seqarfat","#frmDadosSicredi").focus();
      $("#btSalvar", "#divBotoes").show();
    }
  //Bancoob
  } else {
    $('#frmFiltros').css({'display':'block'});
    //Consulta
    if ($('#cddopcao','#frmBab').val() == 'C') {
      $("#tlcooper","#fsetFiltroConsultar").focus();
    //Alteração
    } else {
    }
  }
  
  // Desabilitar a opção e agente
	$("#cddopcao","#frmCab").desabilitaCampo();
  $("#cdagente","#frmCab").desabilitaCampo();
  
  if ($("#cddopcao","#frmCab").val() == 'C') {
    $("#seqarfat","#frmDadosSicredi").desabilitaCampo();
    $("#seqtrife","#frmDadosSicredi").desabilitaCampo();
    $("#seqconso","#frmDadosSicredi").desabilitaCampo();
  } else {
    $("#seqarfat","#frmDadosSicredi").habilitaCampo();
    $("#seqtrife","#frmDadosSicredi").habilitaCampo();
    $("#seqconso","#frmDadosSicredi").habilitaCampo();
    trocaBotao("Alterar");
  }
  
  $('#divBotoes').css({'display':'block','padding-bottom':'15px'});
}

/**
 * Funcao para liberar os campos da tela de acordo com a OPCAO selecionada
 */
function liberaFormulario() {

	// Validar qual a opcao que o usuario selecionou
	switch($("#cddopcao","#frmCab").val()) {
		case "C": // Consultar Historicos
			liberaAcaoConsultar();
		break;
		
		case "A": // Alterar Historicos
			liberaAcaoAlterar();
		break;
	}
}

/**
 * Funcao para liberar os campos de Filtro da Consulta
 */
function liberaAcaoConsultar(){
	// Liberar os filtros de consulta
	liberaFiltrosConsultar();
}

/**
 * Funcao para liberar os campos de opcao "ALTERAR"
 */
function liberaAcaoAlterar(){

	// Alterar o label do botao para "Alterar"
	trocaBotao("Alterar");	
	// Liberar todos os campos do cadastro, sem o campo "NOVO CODIGO"
	liberaCadastro();
}

/**
 * Funcao para liberar os campos da consulta
 */
function liberaFiltrosConsultar(){

	// Desabilitar a opção
	$("#cddopcao","#frmCab").desabilitaCampo();
  $("#cdagente","#frmCab").desabilitaCampo();

	// Limpar formulário
	$('input[type="text"],select','#frmFiltros').limpaFormulario().removeClass('campoErro').habilitaCampo();

	// Mostrar a tela
	$('#frmFiltros').css({'display':'block'});
	$('#fsetFiltroConsultar','#frmFiltros').css({'display':'block'});
	$('#divBotoes').css({'display':'block','padding-bottom':'15px'});
	$('#btVoltar','#divBotoes').css({'display':'inline'});
	$('#btSalvar','#divBotoes').css({'display':'inline'});
	
	// Adicionar foco no primeiro campo
	//$("#tlcooper","#fsetFiltroConsultar").val("").focus();
}

/**
 * Funcao para controlar a ordem dos campos dos filtros da consulta
 */
function controlaCamposFiltroConsulta(){
	// Validacao do campo tlcooper para quando executar o TAB ou ENTER
	$('#tlcooper','#frmFiltros').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			// Setar foco no campo cdempres
			$('#cdempres','#frmFiltros').focus();
			return false;
		}	
	});
	
	// Validacao do campo cdempres para quando executar o TAB ou ENTER
	$('#cdempres','#frmFiltros').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
      if (!$('#cdempres','#frmFiltros').val()){
        $('#nmextcon','#frmFiltros').val('Todos');
      }
      // Setar foco no campo dtiniper
      $('#dtiniper','#frmFiltros').focus();
			return false;
		}	
	});
  
  // Validacao do campo dtiniper para quando executar o TAB ou ENTER
	$('#dtiniper','#frmFiltros').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			// Setar foco no campo dtfimper
			$('#dtfimper','#frmFiltros').focus();
			return false;
		}	
	});
  
  // Validacao do campo dtiniper para quando executar o TAB ou ENTER
	$('#dtfimper','#frmFiltros').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			// Executar validação dos campos de data
      if (validaPeriodo()) {
        // Ultimo campo da tela, executar o botao PROSSEGUIR
        prosseguir();
      }
      return false;
		}
	});
}

/**
 * Funcao para controlar a execucao do botao VOLTAR
 */
function voltar() {
	// Validar a opcao selecionada em tela
	switch($("#cddopcao","#frmCab").val()) {
		
		case "C": // Consultar
			if($('#cdhistor','#fsetFiltroConsultar').prop('disabled')){
				// Se o campo CDHISTOR, da tela de filtro estiver desabilitada, 
				// vamos voltar apenas uma etapa
				// liberando os campos da opcao de consultar da tela
				liberaAcaoConsultar();							
			}else{
				// Volta para o estado inicial da tela
				estadoInicial();
			}
		break;
		
		case "A": // Alterar Historicos
			if($('#cdhistor','#frmHistorico').prop('disabled')){
				// Se o campo CDHISTOR, da tela de Historico estiver desabilitado
				// vamos voltar apenas uma etapa
				// liberando os campos da opcao de alterar
				liberaAcaoAlterar();							
			}else{
				// Volta para o estado inicial da tela
				estadoInicial();
			}
		break;

		default:
			estadoInicial();
	}
}

function focoBtVoltar() {
  $("#btVoltar", "#divBotoes").focus();
}

/**
 * Funcao para controlar a execucao do botao PROSSEGUIR
 */
function prosseguir() {
   alert('prosseguir'); 
	if ( divError.css('display') == 'block' ) { return false; }		

	// Validar a opcao selecionada em tela
	switch($("#cddopcao","#frmCab").val()) {
		
		case "C": // Consultar
      //Sicredi
      if ($('#cdagente','#frmCab').val() == 'S') {
        showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','focoBtVoltar();','','sim.gif','nao.gif');
      //Bancoob
      } else {
        
      }
		break;
		
		case "A": // Alterar
			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina();','','sim.gif','nao.gif');
		break;
	}

	return false;
}

/**
 * Funcao para trocar o label do campo que deve sr exibido
 * labelBotao -> Titulo que deve ser exibido no botao
 */
function trocaBotao(labelBotao){
	$('#btSalvar').text(labelBotao);
}

/**
 * Funcao para realizar a gravacao dos dados do historico (Alterar/Incluir/Replicar)
 */
function manterRotina(){
	
	showMsgAguardo('Aguarde efetuando operacao...');

	var cddopcao  = $('#cddopcao','#frmCab').val();
	var seqarfat  = $('#seqarfat','#frmDadosSicredi').val();
  var seqtrife  = $('#seqtrife','#frmDadosSicredi').val();
  var seqconso  = $('#seqconso','#frmDadosSicredi').val();
	
	
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/tab057/manter_rotina.php', 
		data    :
				{ 
				  cddopcao : cddopcao,	
				  seqarfat : seqarfat,
				  seqtrife : seqtrife,
				  seqconso : seqconso,
				  redirect : 'script_ajax'
				  
				},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
                eval(response);	
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
	});
}