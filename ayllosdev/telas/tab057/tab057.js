/*!
 * FONTE        : tab057.js
 * DATA CRIAÇÃO : 19/01/2018
 * OBJETIVO     : Biblioteca de funções da tela TAB057
 *
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
	$('#divTela').css({'display':'block'}).fadeTo(0,0.1);
	
	// Formatar o layout da tela
	formataBotoes();
	formataCabecalho();
	formataFormularioSicredi();
    formataFormularioBancoob();
	controlaNavegacaoFrmSicredi();
	formataFiltros();

	removeOpacidade('divTela');
	highlightObjFocus( $('#frmCab') ); 
	
	// esconder os formulários da tela
	$('#frmFiltros').css({'display':'none'});
	$('#frmDadosSicredi').css({'display':'none'});
	$('#divConsulta').css({'display':'none'});
  
	// esconder os botoes da tela
	$('#divBotoes').css({'display':'none'});
	$('#frmCab').css({'display':'block'});
	$('#divTela').css({'width':'700px','padding-bottom':'2px'});
	
	// Ajustar o label do botao "Prosseguir"
	trocaBotao("Prosseguir");
	$('a', '#frmFiltros').css({'display':'block'});
	$('#cdempres').habilitaCampo();
	
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
	$("#cddopcao","#frmCab").css("width","250").habilitaCampo();
    $("#cdagente","#frmCab").css("width","120").habilitaCampo();
	
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
		//$(this).unbind('click');
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
      
   
  // CAMPOS - Filtro
  $('#tlcooper','#frmFiltros').css({'width':'100px'});
  $('#cdempres','#frmFiltros').addClass('inteiro').css({'width':'100px'}).habilitaCampo().attr('maxlength','10');
  $('#nmextcon','#frmFiltros').css({'width':'300'}).desabilitaCampo();
  $('#dtiniper','#frmFiltros').css({'width':'75px','text-align':'right'}).habilitaCampo().addClass('inteiro').attr('maxlength','14').setMask("DATE","","","");
  $('#dtiniper','#frmFiltros').val(dtmvtglb);
  $('#dtfimper','#frmFiltros').css({'width':'75px','text-align':'right'}).habilitaCampo().addClass('inteiro').attr('maxlength','14').setMask("DATE","","","");
  $('#dtfimper','#frmFiltros').val(dtmvtglb);
  
  //Alteração
  if ($('#cddopcao','#frmCab').val() == 'A') {
	  
	  $('label[for="dtiniper"]','#frmFiltros').css({'display':'none'});
	  $('label[for="dtfimper"]','#frmFiltros').css({'display':'none'});
	  $('label[for="nmarquiv"]','#frmDetalhe').css({'display':'none'});
	  $('label[for="nrsequen"]','#frmDetalhe').css({'display':'none'});
      $('label[for="dssitret"]','#frmDetalhe').css({'display':'none'});
	  
	  $('#dtiniper','#frmFiltros').css({'display':'none'});
	  $('#dtfimper','#frmFiltros').css({'display':'none'});
	  $('#nmarquiv','#frmDetalhe').css({'display':'none'});
	  $('#nrsequen','#frmDetalhe').css({'display':'none'});
      $('#dssitret','#frmDetalhe').css({'display':'none'});
	  
  }else{
      $('label[for="dtiniper"]','#frmFiltros').css({'display':'inline'});
	  $('label[for="dtfimper"]','#frmFiltros').css({'display':'inline'});
	  $('label[for="nmarquiv"]','#frmDetalhe').css({'display':'inline'});
	  $('label[for="nrsequen"]','#frmDetalhe').css({'display':'inline'});
      $('label[for="dssitret"]','#frmDetalhe').css({'display':'inline'});
	  
	  $('#dtiniper','#frmFiltros').css({'display':'inline'});
	  $('#dtfimper','#frmFiltros').css({'display':'inline'});
	  $('#nmarquiv','#frmDetalhe').css({'display':'inline'});
	  $('#nrsequen','#frmDetalhe').css({'display':'inline'}).attr('maxlength','6');      
      $('#dssitret','#frmDetalhe').css({'display':'inline'});
  }
  
  
  if ($('#glcooper','#frmCab').val() == '3') {
	 
	   $('#tlcooper','#frmFiltros').habilitaCampo();
	   document.getElementById('tlcooper').value = $('#glcooper','#frmCab').val();
	 
       var xtlcooper = document.getElementById('tlcooper');
       if ($('#cddopcao','#frmCab').val() == 'C') {
           // Incluir opcao Todas
           var aux_existe = false;
           for (i = 0; i < xtlcooper.length; i++) {
               if (xtlcooper.options[i].text == "Todas"){ 
                   aux_existe = true;               
               }              
           } 
           
           if (aux_existe == false){
               var optionTodas = document.createElement("option");
               optionTodas.text = "Todas";
               optionTodas.value = "0";
               xtlcooper.add(optionTodas);
           }
           document.getElementById('tlcooper').value = 0;
       }else{
           // Remover opcao todas
           for (i = 0; i < xtlcooper.length; i++) {
               if (xtlcooper.options[i].text == "Todas"){ 
                   xtlcooper.remove(i);                
               }              
           }         
       }
      
    
  } else {
    document.getElementById('tlcooper').value = $('#glcooper','#frmCab').val();
    $('#tlcooper','#frmFiltros').desabilitaCampo();
  }
   
  $('a','#frmFiltros').addClass('lupa').css('cursor', 'pointer').css({'width':'15','text-align':'center'});
  $('a','#frmFiltros').unbind('click').bind('click', function() {
    bo          = 'TAB057'
    procedure   = 'TAB057_LISTA_CONVENIOS';
    titulo      = 'Convênios de Arrecadação';
    qtReg       = '20';
    filtrosPesq = 'Codigo;cdempres;70px;S;;S;descricao|Descricao;nmextcon;200px;S;;S;descricao|;cdcooper;;N;' + $('#tlcooper','#frmFiltros').val() + ';N;codigo';
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
 * Formatação dos campos quando selecionado a opção Bancoob
 */
 function formataFormularioBancoob() {
   // LABEL
   $('label[for="seqarnsa"]','#frmDadosBancoob').addClass('rotulo').css({'width':'173px'});
   
   // CAMPOS - Dados Gerais
   $('#seqarnsa','#frmDadosBancoob').addClass('inteiro').css({'width':'60px'}).attr('maxlength','6').habilitaCampo();
   
   layoutPadrao();
   
   return false;
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
   $('#seqarfat','#frmDadosSicredi').addClass('inteiro').css({'width':'60px'}).attr('maxlength','6');
   $('#seqtrife','#frmDadosSicredi').addClass('inteiro').css({'width':'60px'}).attr('maxlength','6');
   $('#seqconso','#frmDadosSicredi').addClass('inteiro').css({'width':'60px'}).attr('maxlength','6');
   
   if ($("#cddopcao","#frmCab").val() == 'C') {
    $("#seqarfat","#frmDadosSicredi").desabilitaCampo();
    $("#seqtrife","#frmDadosSicredi").desabilitaCampo();
    $("#seqconso","#frmDadosSicredi").desabilitaCampo();
  } else {
    $("#seqarfat","#frmDadosSicredi").habilitaCampo();
    $("#seqtrife","#frmDadosSicredi").habilitaCampo();
    $("#seqconso","#frmDadosSicredi").habilitaCampo();
  }
   
   layoutPadrao();
   
   return false;
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
    
    if($('#cdagente','#frmCab').prop('disabled')){
        return false;
    }
    
    
  //Sicredi
  if ($("#cdagente","#frmCab").val() == 'S') {
    $('#frmDadosSicredi').css({'display':'block'});
    consultaSeqSicredi();
    //Consulta
    if ($("#cddopcao","#frmCab").val() == 'C') {
        
      $("#btSalvar", "#divBotoes").hide();
      $("#btVoltar", "#divBotoes").focus();
    //Alteração
    } else {
      $("#seqarfat","#frmDadosSicredi").focus();
      $("#btSalvar", "#divBotoes").show();
	  trocaBotao("Alterar");
    }
  //Bancoob
  } else {
    //Consulta
    if ($('#cddopcao','#frmCab').val() == 'C') {
	  formataFiltros();
	  $('#frmFiltros').css({'display':'block'});
      $("#tlcooper","#frmFiltros").focus();
    //Alteração
    } else {
		formataFiltros();
		$('#frmFiltros').css({'display':'block'});
		trocaBotao('Prosseguir');
    }
  }
  
  // Desabilitar a opção e agente
  $("#cddopcao","#frmCab").desabilitaCampo();
  $("#cdagente","#frmCab").desabilitaCampo();
  
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
	//Consulta
    if ($('#cddopcao','#frmBab').val() == 'C') {
      $("#tlcooper","#frmFiltros").focus();
	}
	$('#fsetFiltroConsultar','#frmFiltros').css({'display':'block'});
	$('#divBotoes').css({'display':'block','padding-bottom':'15px'});
	$('#btVoltar','#divBotoes').css({'display':'inline'});
	$('#btSalvar','#divBotoes').css({'display':'inline'});
	
	// Adicionar foco no primeiro campo
	//$("#tlcooper","#frmFiltros").val("").focus();
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
		  if (!$('#cdempres','#frmFiltros').val() && $('#cddopcao','#frmCab').val() == 'C'){
			$('#nmextcon','#frmFiltros').val('Todos');
			// Setar foco no campo dtiniper
			$('#dtiniper','#frmFiltros').focus();
			return false;
		  } else {
			  if ($('#cddopcao','#frmCab').val() == 'A') {
				  if (!$('#cdempres','#frmFiltros').val()) {
					  showError("error","Convênio é obrigatório.","Alerta - Ayllos","");
					} else {
						 $('#btSalvar','#divBotoes').focus();
					}
				}else{
                    $('#dtiniper','#frmFiltros').focus();
                } 
			}
		}
	});
    
	// Validacao do campo cdempres para quando executar o TAB ou ENTER
	$('#cdempres','#frmFiltros').unbind('change').bind('change', function(e) {
       
		//if ( e.keyCode == 9 || e.keyCode == 13 ) {
		  if (!$('#cdempres','#frmFiltros').val() && $('#cddopcao','#frmCab').val() == 'C'){
			$('#nmextcon','#frmFiltros').val('Todos');
			// Setar foco no campo dtiniper
			$('#dtiniper','#frmFiltros').focus();
			return false;
		  } else {
              
              
			  if ($('#cddopcao','#frmCab').val() == 'A') {
				  if (!$('#cdempres','#frmFiltros').val()) {
					  showError("error","Convênio é obrigatório.","Alerta - Ayllos","");
					} else {
                        
                        bo          = 'TAB057'
                        procedure   = 'TAB057_LISTA_CONVENIOS';
                        titulo      = 'Convênios de Arrecadação';                    
                        
                        filtrosDesc = 'cdcooper|' + $('#tlcooper','#frmFiltros').val() ;
                        buscaDescricao(bo,procedure,titulo,'cdempres','nmextcon',$('#cdempres','#frmFiltros').val(),'nmextcon',filtrosDesc,'frmFiltros','');
                        setTimeout(function(){ 
                            validaBuscaDescricao('cdempres','nmextcon','frmFiltros');
                        }, 800);
                        
                        return false;
						//prosseguir();
					}
				} else {
                    
                    
                    bo          = 'TAB057'
                    procedure   = 'TAB057_LISTA_CONVENIOS';
                    titulo      = 'Convênios de Arrecadação';                    
                    
                    filtrosDesc = 'cdcooper|' + $('#tlcooper','#frmFiltros').val() ;
                    buscaDescricao(bo,procedure,titulo,'cdempres','nmextcon',$('#cdempres','#frmFiltros').val(),'nmextcon',filtrosDesc,'frmFiltros','validaBuscaDescricao(\'cdempres\',\'nmextcon\',\'frmFiltros\');');
                    setTimeout(function(){ 
                            validaBuscaDescricao('cdempres','nmextcon','frmFiltros');
                        }, 800);
                    return false;
                    
                }
			}	
		//}
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

function validaBuscaDescricao(campoCod,campoDesc,formulario){
    
    if ( $('#'+campoDesc,'#'+formulario).val() == "" || 
         $('#'+campoDesc,'#'+formulario).val() == "undefined" ){
             
             $('#'+campoCod,'#'+formulario).val("");
         }
    
    return false;   
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
			if($('#seqarnsa','#frmDadosBancoob').prop('disabled')){
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
	if ( divError.css('display') == 'block' ) { return false; }		

	// Validar a opcao selecionada em tela
	switch($("#cddopcao","#frmCab").val()) {
		
		case "C": // Consultar
		  //Sicredi
		  if ($('#cdagente','#frmCab').val() == 'S') {
			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','focoBtVoltar();','','sim.gif','nao.gif');
		  //Bancoob
		  } else {
              
            if (validaPeriodo() == false){              
              return false;
            }
            consultaBancoob(1,50);
			//showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','consultaBancoob(1,50);','','sim.gif','nao.gif');
            
		  }
		break;
		
		case "A": // Alterar
			//Sicredi
			if ($('#cdagente','#frmCab').val() == 'S') {
				showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarSicredi();','','sim.gif','nao.gif');
			//Bancoob
			} else {
				//if ( $("#frmDadosBancoob").css("display") == 'none') {
				if ($("#tlcooper","#frmFiltros").val() != '' && $("#cdempres","#frmFiltros").val() != '') {
					if ( $("#frmDadosBancoob").css("display") != 'block' || $('#btSalvar').html() == 'Prosseguir') {
						trocaBotao('Alterar');
						consultaSeqBancoob();
                        setTimeout(function(){ 
  						    $("#divConsulta").css({'display':'block'});
						    $('a', '#frmFiltros').css({'display':'none'});
					        $('#cdempres').desabilitaCampo();
                            formataFormularioBancoob();
                        }, 400);
					} else {
						showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarBancoob();','','sim.gif','nao.gif');
					}
				}
			}
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
 *  Função para seleção de faturas
 */
function selecionaFaturas(tr){

	$('#nmarquiv','#frmDetalhe').val( $('#nmarquiv', tr ).val());
	$('#nrsequen','#frmDetalhe').val( $('#nrsequen', tr ).val());
    $('#dssitret','#frmDetalhe').val( $('#dssitret', tr ).val());
    //armazenar os selecionados
    $('#cdcooper_selec','#frmDetalhe').val( $('#cdcooper', tr ).val());
    $('#cdconven_selec','#frmDetalhe').val( $('#cdconven', tr ).val());
    $('#dtmvtolt_selec','#frmDetalhe').val( $('#dtmvtolt', tr ).val());
    $('#nrsequen_selec','#frmDetalhe').val( $('#nrsequen', tr ).val());
    
    
    
    

	return false;		
}

/**
 * Função para akustar o layout da tabela com os dados
 */
 function controlaLayout(operacao) {

	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	
	var nmForm;
	
	switch(operacao) {		
	
		case '1':	

			var divRegistro = $('div.divRegistros');
			var tabela      = $('table',divRegistro );	
			var linha		= $('table > tbody > tr', divRegistro );

			cTodos = $('input,select','#frmFiltros');
			cTodos.desabilitaCampo();

			divRegistro.css({'height':'150px'});

			var ordemInicial = new Array();
				ordemInicial = [[1,0]];		

			var arrayLargura = new Array(); 
				arrayLargura[0] = '100px';
				arrayLargura[1] = '60px';
				arrayLargura[2] = '60px';
				arrayLargura[3] = '50px';
				arrayLargura[4] = '65px';
				arrayLargura[5] = '65px';
				arrayLargura[6] = '65px';
                arrayLargura[7] = '65px';


			var arrayAlinha = new Array();
				arrayAlinha[0] = 'left';
				arrayAlinha[1] = 'right';
				arrayAlinha[2] = 'right';
				arrayAlinha[3] = 'right';
				arrayAlinha[4] = 'right';
				arrayAlinha[5] = 'right';
				arrayAlinha[6] = 'right';
                arrayAlinha[7] = 'center';

			arrayAlinha[2] = 'center';

			var metodoTabela = '';

			tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,metodoTabela);			

			//Deixa o primeiro registro já selecionado
			$('table > tbody > tr', divRegistro).each( function(i) {

				if ( $(this).hasClass( 'corSelecao' ) ) {
					selecionaFaturas($(this));
				}	

			});	

			//seleciona a fatura que tiver foco
			$('table > tbody > tr', divRegistro).focus( function() {
				selecionaFaturas($(this));
			});	
			
			//seleciona a fatura que é clicada
			$('table > tbody > tr', divRegistro).click( function() {
				selecionaFaturas($(this));
			});
								
			
			$('#divConsulta').css('display','block');
			$('#divRegistros').css('display','block');
			$('#divRegistrosRodape','#divConsulta').formataRodapePesquisa();	
			
			$("input","#frmDetalhe").desabilitaCampo();
			$("select","#frmDetalhe").desabilitaCampo();
			
			// Se clicar no btVoltar
			$('#btVoltar','#divBotoes').unbind('click').bind('click', function() { 		
				
				controlaLayout('2');
						
				return false;

			});	
			
			layoutPadrao();
			
		break;			
		//Voltar
		case '2':
		
			$('#divConsulta').html('');
			$('#divConsulta').css({'display':'none'});
			
			$('#btSalvar','#divBotoes').css('display','inline');
			$('#btVoltar','#divBotoes').css('display','inline');
			
			cTodos = $('input,select','#frmFiltros');
			cTodos.habilitaCampo();
			
			formataFiltros();
			
			$('#frmFiltros').css({'display':'block'});
			
			$('#tlcooper','#frmFiltros').focus();
			
			// Se clicar no btVoltar
			$('#btVoltar','#divBotoes').unbind('click').bind('click', function() { 		
				
				estadoInicial();
						
				return false;

			});	
			
		break;					
	}
	
	layoutPadrao();
	return false;	
	
}

/**
 * Função para consultar a sequencia Bancoob
 */
function consultaSeqBancoob() {
	showMsgAguardo('Aguarde efetuando operacao...');
	
	var cdcooper = $('#tlcooper','#frmFiltros').val();
	var cdempres = $('#cdempres','#frmFiltros').val();
	
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/tab057/form_bancoob.php', 
		data    :
				{ 
				  cdcooper : cdcooper,
				  cdempres : cdempres,
				  redirect : 'script_ajax'
				  
				},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o(cod.01).', 'Alerta - Ayllos', 'estadoInicial();');
        },
		success: function(response) {
			hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divConsulta').html(response);
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(cod.02)','Alerta - Ayllos','estadoInicial();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(cod.03)','Alerta - Ayllos','estadoInicial();');
					}
				}
        }
        /*success: function(response) {
            try {
                eval(response);	
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(cod.02)', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }*/
	});
}

/**
 * Função para consultar a sequencia Sicredi
 */
function consultaSeqSicredi() {
	showMsgAguardo('Aguarde efetuando operacao...');
	
	var cdcooper = $('#tlcooper','#frmFiltros').val();
	var cdempres = $('#cdempres','#frmFiltros').val();
	
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/tab057/form_sicredi.php', 
		data    :
				{ 
				  cdcooper : cdcooper,
				  cdempres : cdempres,
				  redirect : 'script_ajax'
				  
				},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o(cod.01).', 'Alerta - Ayllos', 'estadoInicial();');
        },
		success: function(response) {
			hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#divConsulta').html(response);
                        $("#divConsulta").css({'display':'block'});
                        formataFormularioSicredi();
						return false;
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(cod.02)','Alerta - Ayllos','estadoInicial();');
					}
				} else {
					try {
						eval( response );						
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(cod.03)','Alerta - Ayllos','estadoInicial();');
					}
				}
        }
        /*success: function(response) {
            try {
                eval(response);	
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(cod.02)', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }*/
	});
}


/**
 * Função para consultar os dados Bancoob
 */
function consultaBancoob(nriniseq, nrregist) {
	
	showMsgAguardo('Aguarde efetuando operacao...');

	var cddopcao = $('#cddopcao','#frmCab').val();
	var cdagente = $('#cdagente','#frmCab').val();
	var cdcooper = $('#tlcooper','#frmFiltros').val();
	var cdempres = $('#cdempres','#frmFiltros').val();
	var dtiniper = $('#dtiniper','#frmFiltros').val();
	var dtfimper = $('#dtfimper','#frmFiltros').val();
	
	if (cdempres == '') {
		cdempres = 0;
	}
	
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/tab057/manter_rotina.php', 
		data    :
				{ 
				  cddopcao : cddopcao,
				  cdagente : cdagente,
				  cdcooper : cdcooper,
				  cdempres : cdempres,
				  dtiniper : dtiniper,
				  dtfimper : dtfimper,
				  nriniseq : nriniseq,
				  nrregist : nrregist,
				  redirect : 'script_ajax'
				  
				},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o(1).', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
			hideMsgAguardo();
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
				
						$('#divConsulta').html(response);
						return false;
					} catch(error) {						
				
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(cod.02)','Alerta - Ayllos','estadoInicial();');
					}
				} else {
					try {
				
						eval( response );						
					} catch(error) {
				
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(cod.03)','Alerta - Ayllos','estadoInicial();');
					}
				}
        }
	});
}

/**
 * Funcao para realizar a gravacao dos dados do formulário Sicredi
 */
function alterarBancoob() {
	
	showMsgAguardo('Aguarde efetuando operacao...');

	var cddopcao = $('#cddopcao','#frmCab').val();
	var cdagente = $('#cdagente','#frmCab').val();
	var cdcooper = $('#tlcooper','#frmFiltros').val();
	var cdempres = $('#cdempres','#frmFiltros').val();
	var seqarnsa = $('#seqarnsa','#frmDadosBancoob').val();
	
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/tab057/manter_rotina.php', 
		data    :
				{ 
				  cddopcao : cddopcao,
				  cdagente : cdagente,
				  cdcooper : cdcooper,
				  cdempres : cdempres,
				  seqarnsa : seqarnsa,
				  redirect : 'script_ajax'
				  
				},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o(1).', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
                eval(response);	
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(2)', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
	});
}

/**
 * Funcao para realizar a gravacao dos dados do formulário Sicredi
 */
function alterarSicredi() {
	
	showMsgAguardo('Aguarde efetuando operacao...');

	var cddopcao  = $('#cddopcao','#frmCab').val();
	var cdagente  = $('#cdagente','#frmCab').val();
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
				  cdagente : cdagente,
				  seqarfat : seqarfat,
				  seqtrife : seqtrife,
				  seqconso : seqconso,
				  redirect : 'script_ajax'
				  
				},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o(1).', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
                eval(response);	
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(2)', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
	});
}

// Confirmar geracao do relatorio
function confirmaGeracRel(tr){ 

  var comando =  'gerarRelat();'   
  showConfirmacao('Deseja visualizar a impressão?','Confirma&ccedil;&atilde;o - Ayllos', comando ,'','sim.gif','nao.gif');     
}

function gerarRelat() {
	
    showMsgAguardo('Aguarde gerando relatorio...');
    
    var cdcooper = $('#cdcooper_selec','#frmDetalhe').val();
    var cdempres = $('#cdconven_selec','#frmDetalhe').val();
    var dtmvtolt = $('#dtmvtolt_selec','#frmDetalhe').val();
    var nrsequen = $('#nrsequen_selec','#frmDetalhe').val();
    $('#formImpres').html('');
    
    // Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#formImpres').append('<input type="hidden" id="cdcooper" name="cdcooper" />');
	$('#formImpres').append('<input type="hidden" id="cdempres" name="cdempres" />');
	$('#formImpres').append('<input type="hidden" id="dtmvtolt" name="dtmvtolt" />');
	$('#formImpres').append('<input type="hidden" id="nrsequen" name="nrsequen" />');
    $('#formImpres').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
    
	
	// Agora insiro os devidos valores nos inputs criados
	$('#cdcooper','#formImpres').val( cdcooper );
	$('#cdempres','#formImpres').val( cdempres );
	$('#dtmvtolt','#formImpres').val( dtmvtolt );
	$('#nrsequen','#formImpres').val( nrsequen );    
    $('#sidlogin','#formImpres').val( $('#sidlogin','#frmMenu').val() );
    
    var action = UrlSite + 'telas/tab057/gerar_relatorio.php';
	carregaImpressaoAyllos("formImpres",action,'bloqueiaFundo(divRotina);hideMsgAguardo();');
    
    
	
	/*
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/tab057/gerar_relatorio.php', 
		data    :
				{ 
				  cdcooper : cdcooper,
				  cdempres : cdempres,
				  dtmvtolt : dtmvtolt,
                  nrsequen : nrsequen,
				  redirect : 'script_ajax'
				  
				},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o(1).', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
                eval(response);	
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(2)', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
	});*/
}