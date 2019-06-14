/*!
 * FONTE        : inteas.js
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 15/04/2016
 * OBJETIVO     : Biblioteca de funções da tela INTEAS
 * --------------
 * ALTERAÇÕES   : 
 *								 
 *				  
 *				
 *
 *				
 * --------------
 */
 
var cddopcao = '';

var rCddopcao, rNmrescop, rINarquiv, rDtiniger, rDtfimger,
    cCddopcao, cNmrescop, cInarquiv,cDtiniger,cDtfimger,cCamposAltera;
	
var lstCooperativas = new Array();
var lstRelatorios   = new Array();

var nrdconta, nrdctitg, flgdemis;

var vllimpam, dddebpam, nrctapam;


$(document).ready(function() {
	
    // cabecalho
	rCddopcao			= $('label[for="cddopcao"]'	,'#frmCab'); 
	rNmrescop           = $('label[for="nmrescop"]'	,'#divCooper');
    rINarquiv			= $('label[for="inarquiv"]'	,'#frmFiltros'); 
	rDtiniger			= $('label[for="dtiniger"]'	,'#frmFiltros'); 
    rDtfimger			= $('label[for="dtfimger"]'	,'#frmFiltros');  
    
    btnAlterar      = $('#btnAlterar'	,'#divBotoes'); 
    cCddopcao		= $('#cddopcao'	,'#frmCab'); 
    cNmrescop       = $('#nmrescop'	,'#divCooper');
    cInarquiv       = $('#inarquiv'	,'#frmFiltros');
    cDtiniger		= $('#dtiniger'	,'#frmFiltros');
    cDtfimger		= $('#dtfimger'	,'#frmFiltros');
    estadoInicial();

});


// seletores
function estadoInicial() {
	
	$('#divTela').fadeTo(0,0.1);
	
	fechaRotina( $('#divRotina') );
	
	cddopcao = "";
	
	$('#nmrescop','#frmFiltros').val(0);    
    cInarquiv.val(0);
    cDtiniger.val("");
    cDtfimger.val("");
	
    controlaLayout(true);
	cCddopcao.val(cddopcao);
	
	removeOpacidade('divTela');
	$('#cddopcao', '#frmCab').focus();
	return false;
	
}

function controlaLayout(carregaCoops) {
	
	
	cCamposAltera		= $('#nmrescop,#inarquiv,#dtiniger,#dtfimger','#frmFiltros');
    
	var btnOK			= $('#btnOK','#frmCab');
	
	rCddopcao.addClass('rotulo').css({'width':'68px'});
	cCddopcao.css({'width':'456px'});
	
	$('#divFiltros').css({'display':'none'});
	
	// Formata
	if ( cddopcao == 'G' ) {
	
		$("#frmFiltros").css({'display':'block'});
	
		rNmrescop.addClass('rotulo').css({'width':'100px'});
        rINarquiv.addClass('rotulo').css({'width':'100px'});
		rDtiniger.addClass('rotulo').css({'width':'100px'});	
		rDtfimger.addClass('rotulo-linha').css({'width':'35px','text-align': 'center'});		
		
		cNmrescop.addClass('rotulo').css('width','130px');
        $('#inarquiv'	,'#divInarquiv').addClass('rotulo').css('width','130px');
		cDtiniger.addClass('rotulo').css({'width':'70px'}).setMask("STRING","ZZ/ZZZZ","/","");
		cDtfimger.addClass('rotulo').css({'width':'70px'}).setMask("STRING","ZZ/ZZZZ","/","");
		
		cCamposAltera.habilitaCampo();		
		
        $('#divFiltros').css({'display':'block'});		
			
	} 
	
	cCddopcao.habilitaCampo();
	
	cCddopcao.unbind('change').bind('change', function() { 	
		cddopcao = cCddopcao.val();
		return false;
	});
		
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() {
	    eventoCliqueBotaoOk();		
		return false;
	});

	$('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function (e) {
	    if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) { return false; }
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        eventoCliqueBotaoOk();
	        return false;
	    }
	});

	$('#nmrescop', '#frmFiltros').unbind('keypress').bind('keypress', function (e) {
	    if ($('#nmrescop', '#frmFiltros').hasClass('campoTelaSemBorda')) { return false; }
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        $('#inarquiv','#frmFiltros').focus();
	        return false;
	    }
	});

	$('#inarquiv', '#frmFiltros').unbind('keypress').bind('keypress', function (e) {
	    if ($('#inarquiv', '#frmFiltros').hasClass('campoTelaSemBorda')) { return false; }
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        $('#dtiniger', '#frmFiltros').focus();
	        return false;
	    }
	});
	$('#dtiniger', '#frmFiltros').unbind('keypress').bind('keypress', function (e) {
	    if ($('#dtiniger', '#frmFiltros').hasClass('campoTelaSemBorda')) { return false; }
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        $('#dtfimger', '#frmFiltros').focus();
	        return false;
	    }
	});
	$('#dtfimger', '#frmFiltros').unbind('keypress').bind('keypress', function (e) {
	    if ($('#dtfimger', '#frmFiltros').hasClass('campoTelaSemBorda')) { return false; }
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        $('#btnAlterar', '#frmFiltros').focus();
	        return false;
	    }
	});

    
	// Atribuir caracteres numericos
    var keyCodesPermitidos = new Array();
     
    //numeros e 0 a 9 do teclado alfanumerico
    for(x=48;x<=57;x++){
        keyCodesPermitidos.push(x);
    }
     
    //numeros e 0 a 9 do teclado numerico
    for(x=96;x<=105;x++){
        keyCodesPermitidos.push(x);
    }
     
    
    cDtiniger.unbind('keyup').bind('keyup', function(e) { 
    //setTimeout(function () {
       
        
        /* Verificar se ja completou a quantidade de caracteres*/
        if (cDtiniger.val().length >= 7 ){
           
           /*so realizar o pulo automatico qnd foi informado um numero */           
           if ( $.inArray(e.keyCode,keyCodesPermitidos) >= 0 )  {  
               cDtiniger.setMask("STRING","ZZ/ZZZZ","/","");
               cDtfimger.focus(); 
               
               return false;
           }
           return true;
        }
	//},300); 	
	});
    
    
    cDtfimger.unbind('keyup').bind('keyup', function(e) { 
		       
        /* Verificar se ja completou a quantidade de caracteres*/
        if (cDtfimger.val().length >= 7 ){
           /*so realizar o pulo automatico qnd foi informado um numero */            
           if ( $.inArray(e.keyCode,keyCodesPermitidos) >= 0 )  {  
           
               cDtfimger.setMask("STRING","ZZ/ZZZZ","/","");
               btnAlterar.focus(); 
               return true;
           }
           return true;
        }
        
	});
    
    /*Validar data ao sair do campo */
    cDtiniger.unbind('blur').bind('blur', function() { 
      if (!validarData(cDtiniger.val())) {
          showError("error","Data de inicio inv&aacute;lida.","Alerta - Ayllos","blockBackground(); unblockBackground(); cDtiniger.focus();");
          return false;
      }
     
    });
    
    /* Validar data ao sair do campo */
    cDtfimger.unbind('blur').bind('blur', function() {     
      if (!validarData(cDtfimger.val())) {
          showError("error","Data final inv&aacute;lida.","Alerta - Ayllos","blockBackground(); unblockBackground(); cDtfimger.focus();");
          return false;
      }  
    });         
		
	// Se clicar no Anotações
	$('#anotacao','#divHabilita').unbind('click').bind('click', function() { 	
		
		if( $('#nrdconta','#divHabilita').val() != '' ){
			buscaAnotacoes();
			
		}else{
			showError("error","Conta/dv inv&aacute;lida.","Alerta - Ayllos","blockBackground(); unblockBackground(); $('#nrdconta','#divHabilita').focus();");
			
		}
		
		return false;
						
	});

	layoutPadrao();
	return false;	
}

function eventoCliqueBotaoOk() {
    cCamposAltera = $('#nmrescop,#inarquiv,#dtiniger,#dtfimger', '#frmFiltros');

    if (divError.css('display') == 'block') { return false; }
    if (cCddopcao.hasClass('campoTelaSemBorda')) { return false; }

    // Armazena o número da conta na variável global
    cddopcao = cCddopcao.val();
    if (cddopcao == '') { return false; }

    cCamposAltera.removeClass('campoErro');

    controlaLayout(true);
    cCddopcao.desabilitaCampo();
    $('#nmrescop', '#frmFiltros').focus();
}

function macara_data(data){  
  
    var dt = data.val().replace('/','');
    
    if (dt.length > 4 ){
        if (dt.length == 5 ){
            dt = dt[0] + "/" + dt.substring(1,5);
        } else {
            dt = dt.substring(0,2) + '/' + dt.substring(2,6);
        }
    }
    
    data.val(dt);
    return false;
}


// Validar data
function validarData(data){   
    /*nao validar data nula */
    if (data == ''){
      return true;
    }
    
    var valido = false;
    var dia = 1;
    var mes = data.split("/")[0];
    var ano = data.split("/")[1];
    var MyData = new Date(ano, mes-1, dia);

    if((MyData.getMonth()+1 != mes)|| (MyData.getDate() != dia)||  (MyData.getFullYear() != ano))
        valido = false;
      else
        valido = true;
    return valido;
  }

// Função para buscar anotações do associado
function buscaAnotacoes() {
	// Mostra mensagem de aguardo	
	showMsgAguardo("Aguarde, carregando anota&ccedil;&otilde;es ...");
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/busca_anotacoes.php", 
		data: {
			nrdconta: nrdconta,			
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divAnotacoes').css('z-index')))");
		},
		success: function(response) {
			$("#divListaAnotacoes").html(response);
		}				
	});	
}

function manterRotina(cdopcao) {

    var mensagem = '';

    hideMsgAguardo();
    if (cdopcao == 'G') {
      mensagem = 'Aguarde, solicitando geração dos arquivos...';
      showMsgAguardo(mensagem);
    }
	
    var cdcooper = $('#nmrescop','#frmFiltros').val();
    var inarquiv = cInarquiv.val();
    var dtiniger = cDtiniger.val();
    var dtfimger = cDtfimger.val();
	

    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/inteas/manter_rotina.php',
        data: {
            cddopcao: cdopcao,
            cdcooper: cdcooper, 
            inarquiv: inarquiv,
            dtiniger: dtiniger,
            dtfimger: dtfimger,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
                eval(response);	
			//	$('#divBotoes').css({'display': 'block'});
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    return false;

}

function confirmaGeracao() {
    
    if (cDtiniger.val() == "" ){
        showError("error","Data de inicio do periodo deve ser informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cDtiniger.focus();");        
        return false;
    }
    
    if (cDtfimger.val() == "" ){
        showError("error","Data de final do periodo deve ser informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cDtfimger.focus();");        
        return false;
    }
    
    //Validar periodo
    var dia = 1;
    var mes = cDtiniger.val().split("/")[0];
    var ano = cDtiniger.val().split("/")[1];
    var DataIni = new Date(ano, mes-1, dia);
    
    var mes = cDtfimger.val().split("/")[0];
    var ano = cDtfimger.val().split("/")[1];
    var DatFim = new Date(ano, mes-1, dia);
    
    if (DataIni > DatFim){
        showError("error","Data de inicio do periodo deve ser menor ou igual a data final.","Alerta - Ayllos","blockBackground(); unblockBackground(); cDtfimger.focus();");        
        return false;            
    }
    
    showConfirmacao('Confirma a Gera&ccedil;&atilde;o dos arquivos?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'G\');', '', 'sim.gif', 'nao.gif');
}
