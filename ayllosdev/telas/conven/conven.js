/*!
 * FONTE        : conven.js
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 04/12/2017
 * OBJETIVO     : Biblioteca de funções da tela CONVEN
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

var rCddopcao, rCdempcon, rCdsegmto, rNmrescon, rNmextcon, rCdhistor, rNrdolote, rFlginter, rFlgaccec, rFlgacsic, rFlgacbcb, 
    cCddopcao, cCdempcon, cCdsegmto, cNmrescon, cNmextcon, cCdhistor, cNrdolote, cFlginter, cFlgaccec, cFlgacsic, cFlgacbcb, cTparrecd, cCamposAltera, cRadio;
    
var cTparrecd_3, cTparrecd_N3, cTparrecd_1, cTparrecd_N1, cTparrecd_2, cTparrecd_N2;
	

var frmCab = 'frmCab';

$(document).ready(function() {
    // cabecalho
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
	rCddopcao		= $('label[for="cddopcao"]'	,'#' + frmCab); 
	rCdempcon       = $('label[for="cdempcon"]'	,'#' + frmCab);
    rCdsegmto       = $('label[for="cdsegmto"]'	,'#' + frmCab);        
    
    cCddopcao		= $('#cddopcao'	,'#' + frmCab); 
    cCdempcon       = $('#cdempcon'	,'#' + frmCab);    
    cCdsegmto       = $('#cdsegmto'	,'#' + frmCab);          
    
    // Form Campos
    cTodosCampos  = $('input[type="text"],input[type="radio"],select', '#frmCampos');
    cRadio        = $('.radio', '#frmCampos');
    
    rNmrescon       = $('label[for="nmrescon"]'	,'#frmCampos');
    rNmextcon       = $('label[for="nmextcon"]'	,'#frmCampos');
    rCdhistor       = $('label[for="cdhistor"]'	,'#frmCampos');
    rNrdolote       = $('label[for="nrdolote"]'	,'#frmCampos');
    rFlginter       = $('label[for="flginter"]'	,'#frmCampos');   
    
    cNmrescon       = $('#nmrescon'	,'#frmCampos' );
    cNmextcon       = $('#nmextcon'	,'#frmCampos' );
    cCdhistor       = $('#cdhistor'	,'#frmCampos' );
    cNrdolote       = $('#nrdolote'	,'#frmCampos' );
    cFlginter       = $('#flginter'	,'#frmCampos' );
    
    rFlgaccec       = $('label[for="flgaccec"]'	,'#frmCampos'); 
    rFlgacsic       = $('label[for="flgacsic"]'	,'#frmCampos'); 
    rFlgacbcb       = $('label[for="flgacbcb"]'	,'#frmCampos');
        
    cFlgaccec       = $('input[name=\'flgaccec\']','#frmCampos');
    cFlgacsic       = $('input[name=\'flgacsic\']','#frmCampos');
    cFlgacbcb       = $('input[name=\'flgacbcb\']','#frmCampos');
    
    cTparrecd       = $('#tparrecd','#frmCampos');
    
    cTparrecd_3      = $('#tparrecd_3','#frmCampos');
    cTparrecd_N3     = $('#tparrecd_N3','#frmCampos');
    
    cTparrecd_1      = $('#tparrecd_1','#frmCampos');
    cTparrecd_N1     = $('#tparrecd_N1','#frmCampos');
                          
    cTparrecd_2      = $('#tparrecd_2','#frmCampos');
    cTparrecd_N2     = $('#tparrecd_N2','#frmCampos');
    
    estadoInicial();

});


// seletores
function estadoInicial() {
	
	$('#divTela').fadeTo(0,0.1);
	
	//fechaRotina( $('#divRotina') );
	
    // Limpa formularios
    cTodosCabecalho.limpaFormulario();
    cTodosCampos.limpaFormulario();
    // habilita foco no formulário inicial
    highlightObjFocus($('#' + frmCab));
	
	cddopcao = "C";
    cCddopcao.val(cddopcao);
    cTodosCampos.desabilitaCampo();
    
    controlaLayout();
	
	removeOpacidade('divTela');
	$('#cddopcao', '#frmCab').focus();
    $('#btnBusca', '#frmCab').trocaClass('botaoDesativado','botao').attr("onClick","buscaDados(); return false;");
    
	return false;
	
}

function controlaLayout() {
	
	
	$('#frmCampos').css({'display':'none'});
    formataCabecalho();
    formataCampos();
    
	
	layoutPadrao();
	return false;	
}

function LiberaCampos(tipo) {

	// Desabilita campo opção
	cTodosCabecalho = $('input[type="text"],select', '#frmCab');
	cTodosCabecalho.desabilitaCampo();
	
    cCdempcon.desabilitaCampo();
    cCdsegmto.desabilitaCampo();   
    
    $('#frmCampos').css({'display': 'block'});		
    $('#divBotoes', '#frmCampos').css({'display': 'block'});
    $('#btnOk', '#frmCampos').css({'display': 'inline-block'});     
    
    $('#btnBusca', '#frmCab').trocaClass('botao','botaoDesativado').attr("onClick","return false;");
    cTodosCabecalho.desabilitaCampo();
    
    // liberar campos para edicao qnd for alteracao ou inclusao
    if (cCddopcao.val() == 'A' || cCddopcao.val() == 'I' ){
        cTodosCampos.habilitaCampo();           
        
        // Manter Sicredi desabilitado
        cFlgacsic.prop('readonly', true).prop('disabled', true);
        cTparrecd_1.prop('readonly', true).prop('disabled', true);
        cTparrecd_N1.prop('readonly', true).prop('disabled', true);
        
        if (cCddopcao.val() == 'I'){
            // setar valores padrão
            document.getElementById("flgaccec_0").checked = true;
            document.getElementById("flgacsic_0").checked = true;
            document.getElementById("flgacbcb_0").checked = true;
            selecionarTparrecd();
        }
        
        cNmrescon.focus();
        
    }else if (cCddopcao.val() == 'C' ){
       $('#btnOk', '#frmCampos').css({'display': 'none'});  
       cRadio.prop('readonly', true).prop('disabled', true); 
    }else{
        cRadio.prop('readonly', true).prop('disabled', true);
    }
    
    layoutPadrao();
    return false;

}

function formataCabecalho() {

    // Cabeçalho
    $('#cddopcao', '#' + frmCab).focus();
    
    var btnBusca			= $('#btnBusca','#' + frmCab);
	
	rCddopcao.addClass('rotulo').css({'width':'68px'});
	cCddopcao.css({'width':'419px'});
    
    rCdempcon.addClass('rotulo').css({'width':'68px'});
    cCdempcon.addClass('inteiro').css({'width':'47px'}).attr('maxlength','5');
    
    rCdsegmto.addClass('rotulo-linha').css({'padding-left':'10px'});
	cCdsegmto.css('width','280px');
    
    cTodosCabecalho.habilitaCampo(); 
    controlaPesquisas(frmCab);
    
    cCdempcon.habilitaCampo();
    cCdsegmto.habilitaCampo();
    
    //Navegação    
    cCddopcao.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cCdempcon.focus();
			return false;
		}
	});
    
    cCdempcon.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cCdsegmto.focus();
			return false;
		}
	});
    
    cCdsegmto.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			btnBusca.click();
			return false;
		}
	});
    
    layoutPadrao();
    return false;
}

function formataCampos(){
    
    rNmrescon.addClass('rotulo').css({'width':'150px','padding-right':'2px'});
    rNmextcon.addClass('rotulo').css({'width':'150px','padding-right':'2px'});
    rCdhistor.addClass('rotulo').css({'width':'150px','padding-right':'2px'});
    rNrdolote.addClass('rotulo-linha').css({'padding-left':'115px'});
    rFlginter.addClass('rotulo').css({'width':'150px','padding-right':'2px'});
    
    rFlgaccec.addClass('rotulo').css({'width':'150px','padding-right':'2px'});
    rFlgacsic.addClass('rotulo').css({'width':'150px','padding-right':'2px'});
    rFlgacbcb.addClass('rotulo').css({'width':'150px','padding-right':'2px'});
        
    cNmrescon.css('width','200px').attr('maxlength', '15');
    cNmrescon.addClass('alpha');
    cNmextcon.css('width','300px').attr('maxlength', '40');
    cNmextcon.addClass('alpha');
    cCdhistor.addClass('codigo').css('width','50px');
    cNrdolote.css('width','80px').setMask('INTEGER', 'zzz.zz9', '.', '');
    cFlginter.css('width','52px');
       
    cRadio.prop('readonly', false).prop('disabled', false);
    
    cTparrecd_1.prop('readonly', true).prop('disabled', true);
    cTparrecd_N1.prop('readonly', true).prop('disabled', true);
    
    cTodosCampos.desabilitaCampo();     
    
    layoutPadrao();
    
    //Navegação    
    cNmrescon.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cNmextcon.focus();
			return false;
		}
	});
    
    cNmextcon.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cCdhistor.focus();
			return false;
		}
	});
    
    cCdhistor.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cNrdolote.focus();
			return false;
		}
	});
    
    cNrdolote.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cFlginter.focus();
			return false;
		}
	});
    
    cFlginter.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cFlgaccec.focus();
			return false;
		}
	});
    
    cFlgaccec.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cFlgacbcb.focus();
			return false;
		}
	});
    
    
    // Validacoes
    cFlgaccec.unbind('click').bind('click', function() { 	        
        selecionarAceita('flgaccec',$('input[name="flgaccec"]:checked','#frmCampos').val());        
    });
    
    cFlgacbcb.unbind('click').bind('click', function() { 	
        selecionarAceita('flgacbcb',$('input[name="flgacbcb"]:checked','#frmCampos').val());    
    });
    
    cTparrecd_3.unbind('click').bind('click', function() { 	
    
      selecionarTparrecd(3);    
    });       
    
    cTparrecd_1.unbind('click').bind('click', function() { 	
      selecionarTparrecd(1);    
    });
    
    cTparrecd_2.unbind('click').bind('click', function() { 	
      selecionarTparrecd(2);    
    });
    
    cTparrecd_N3.unbind('click').bind('click', function() { 	
        // caso selecionou nao, e seu respectivo sim estava marcado        
        if (cTparrecd.val() == 3){
            // deve limpar opcao salva 
            cTparrecd.val('');
        }
    });
    
    cTparrecd_N1.unbind('click').bind('click', function() { 	
        // caso selecionou nao, e seu respectivo sim estava marcado        
        if (cTparrecd.val() == 1){
            // deve limpar opcao salva 
            cTparrecd.val('');
        }
    });
    
    cTparrecd_N2.unbind('click').bind('click', function() { 	
        // caso selecionou nao, e seu respectivo sim estava marcado        
        if (cTparrecd.val() == 2){
            // deve limpar opcao salva 
            cTparrecd.val('');
        }
    });
        
}

function controlaPesquisas(nomeFormulario){

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhiscxa;	
	
	var divRotina = 'divTela';
		
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');

	// Atribui a classe lupa para os links de desabilita todos
	$('a','#'+nomeFormulario).addClass('lupa').css('cursor','auto');
	
	// Percorrendo todos os links
	$('a','#'+nomeFormulario).each( function(i) {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');
				
		$(this).unbind('click').bind('click', function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');
			
				
				if ( campoAnterior == 'cdempcon' ) {
					bo			= 'b1wgen0101.p';
					procedure	= 'lista-empresas-conv';
					titulo      = 'Empr.Conven.';
					qtReg		= '20';
					filtros 	= 'Empresa;cdempcon;45px;S;0;S|Segmento;cdsegmto;35px;S|Conv&ecircnio;nmextcon;200px;S';
					colunas 	= 'Codigo;cdempcon;15%;right|Segmento;cdsegmto;18%;left|Conv&ecircnio;nmextcon;70%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,nomeFormulario);
					return false;
				}
				
			}
		});
	});
    
    
    cCdempcon.unbind('change').bind('change', function() { 	
    
        // Para inclusao nao deve buscar descrição
        if (cCddopcao.val() != 'I'){
    
            bo			= 'b1wgen0101.p';
            procedure	= 'lista-empresas-conv';
            titulo      = 'Empr.Conven.';
            filtrosDesc = '';
            buscaDescricao(bo,procedure,titulo,'cdempcon','nmextcon',cCdempcon.val(),'nmextcon',filtrosDesc,'frmCab','fechaRotina(divRotina);');
            return false;
        }
    });
	
	return false;
	
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
    var dia = data.split("/")[0];
    var mes = data.split("/")[1];
    var ano = data.split("/")[2];
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

function selecionarAceita(campo,valor){
       
    document.getElementById(campo + "_" + valor).checked = true;
    if (valor == 0 ){
        if (campo == 'flgaccec'){
            cTparrecd_3.prop('readonly', true).prop('disabled', true);
            cTparrecd_N3.prop('readonly', true).prop('disabled', true);
            
            // caso selecionou nao, e seu respectivo sim estava marcado        
            if (cTparrecd.val() == 3){
                // deve limpar opcao salva 
                cTparrecd.val('');
                document.getElementById("tparrecd_N3").checked = true;
            }
            
        }else if (campo == 'flgacbcb'){
            cTparrecd_2.prop('readonly', true).prop('disabled', true);
            cTparrecd_N2.prop('readonly', true).prop('disabled', true);
            
            // caso selecionou nao, e seu respectivo sim estava marcado        
            if (cTparrecd.val() == 2){
                // deve limpar opcao salva 
                cTparrecd.val('');
                document.getElementById("tparrecd_N2").checked = true;
            }
            
        }
    } else if (valor == 1 ){
        if (campo == 'flgaccec'){
            cTparrecd_3.prop('readonly', false).prop('disabled', false);
            cTparrecd_N3.prop('readonly', false).prop('disabled', false);
            
        } else if (campo == 'flgacbcb'){
            cTparrecd_2.prop('readonly', false).prop('disabled', false);
            cTparrecd_N2.prop('readonly', false).prop('disabled', false);
        }
        
    }

    
    
}


function selecionarTparrecd(Tparrecd){
       
    if (Tparrecd == undefined){
        
        //Marcar todos como nao, e desabilitar os campos        
        document.getElementById("tparrecd_N3").checked = true;
        document.getElementById("tparrecd_N1").checked = true;
        document.getElementById("tparrecd_N2").checked = true;
        cTparrecd.val("");
        
        //Cecred
        cTparrecd_3.prop('readonly', true).prop('disabled', true);
        cTparrecd_N3.prop('readonly', true).prop('disabled', true);
        
        //Bancoob        
        cTparrecd_2.prop('readonly', true).prop('disabled', true);
        cTparrecd_N2.prop('readonly', true).prop('disabled', true);
        
        
        return false;     
    } 
    
    if (cTparrecd.val() != "" ){
        showError("error","Opção não permitida.","Alerta - Ayllos","");        
        // Voltar valor antigo
        Tparrecd = cTparrecd.val();
    }

    if (Tparrecd != 0 ){
        document.getElementById("tparrecd_"+Tparrecd).checked = true;
        cTparrecd.val(Tparrecd);
    }

    if (Tparrecd == 3){
        document.getElementById("tparrecd_N1").checked = true;
        document.getElementById("tparrecd_N2").checked = true;
        
    }else if (Tparrecd == 1){
        document.getElementById("tparrecd_N3").checked = true;
        document.getElementById("tparrecd_N2").checked = true;
    }else if (Tparrecd == 2){
        document.getElementById("tparrecd_N3").checked = true;
        document.getElementById("tparrecd_N1").checked = true;
    }
    
}

function buscaDados(){
    
    cdempcon = cCdempcon.val();
    cdsegmto = cCdsegmto.val();
    cddopcao = cCddopcao.val();
    
    //Incializar variavel oculta
    cTparrecd.val("");
    
    if (cdempcon == "" ){
        showError("error","Empresa deve sert informada informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cCdempcon.focus();");        
        return false;
    }
    
    if (cdsegmto == "" ){
        showError("error","Segmento deve sert informada informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cCdsegmto.focus();");        
        return false;
    }
           
    dsaguardo = 'Aguarde, buscando dados...';
    showMsgAguardo(dsaguardo);
    
    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/conven/busca_dados.php',
        data: {
            cddopcao: cddopcao,
            cdempcon: cdempcon,
            cdsegmto: cdsegmto,
            redirect: 'script_ajax'
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

    return false;
    
    
    
}

function confirmaRegExist(){
    hideMsgAguardo();
    showConfirmacao('Já existe Convênio para esta empresa e segmento, deseja alterá-lo?', 'Confirma&ccedil;&atilde;o - Ayllos', 'cCddopcao.val("A");LiberaCampos("campos");', '', 'sim.gif', 'nao.gif');
}

function confirmaOpe() {
    
     if (cCddopcao.val() == 'A' ||
         cCddopcao.val() == 'I' ){ 
         
        if (cCdempcon.val() == ""){
            showError("error","Codigo da empresa deve ser informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cCdempcon.focus();");        
            return false;
        }
        
        if (cCdsegmto.val() == ""){
            showError("error","Segmento deve ser informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cCdsegmto.focus();");        
            return false;
        }
        
        if (cNmrescon.val() == ""){
            showError("error","Nome fantasia deve ser informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cNmrescon.focus();");        
            return false;
        }
        
        if (cNmextcon.val() == ""){
            showError("error","Razao Social deve ser informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cNmextcon.focus();");        
            return false;
        }
        
        if (cCdhistor.val() == ""){
            showError("error","Historico deve ser informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cCdhistor.focus();");        
            return false;
        }
        
        if (cNrdolote.val() == ""){
            showError("error","Lote deve ser informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cNrdolote.focus();");        
            return false;
        }
        
        if (cTparrecd.val() == ''){
            showError("error","Informe a forma de arrecadação do convênio.","Alerta - Ayllos","blockBackground(); unblockBackground(); cTparrecd_3.focus();");        
            return false;
        }
        
    }
    
    
    if (cCddopcao.val() == 'A'){        
        aux_dsconfir = 'Altera&ccedil;&atilde;o dos dados';
        
    } else if (cCddopcao.val() == 'I'){        
        aux_dsconfir = 'Inclus&atilde;o dos dados';
        
    } else if (cCddopcao.val() == 'E'){        
        aux_dsconfir = 'Exclus&atilde;o dos dados';
    
    } else if (cCddopcao.val() == 'X'){        
        aux_dsconfir = 'Replica&ccedil;&atilde;o dos dados';
        
    }
    
    showConfirmacao('Confirma a ' + aux_dsconfir + ' ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina();', '', 'sim.gif', 'nao.gif');
}


function manterRotina() {

    var dsaguardo = '';    
    hideMsgAguardo(); 
    
    cddopcao = cCddopcao.val(); 
    cdempcon = cCdempcon.val(); 
    cdsegmto = cCdsegmto.val();
    nmrescon = cNmrescon.val();
    nmextcon = cNmextcon.val();
    cdhistor = cCdhistor.val(); 
    nrdolote = normalizaNumero(cNrdolote.val());
    flginter = cFlginter.val(); 
    flgaccec = $('input[name="flgaccec"]:checked','#frmCampos').val();
    flgacsic = $('input[name="flgacsic"]:checked','#frmCampos').val();
    flgacbcb = $('input[name="flgacbcb"]:checked','#frmCampos').val();
    tparrecd = cTparrecd.val();
    
    
    if (cddopcao == 'A' || 
        cddopcao == 'I' ) {
        dsaguardo = 'Aguarde, gravando dados...';
        showMsgAguardo(dsaguardo);     
    }else if (cddopcao == 'E' ) {
        dsaguardo = 'Aguarde, excluindo dados...';
        showMsgAguardo(dsaguardo);  
    }else if (cddopcao == 'X' ) {
        dsaguardo = 'Aguarde, replicando dados...';
        showMsgAguardo(dsaguardo);  
    }    
            
    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/conven/manter_rotina.php',
        data: {
            cddopcao: cddopcao,
            cdempcon: cdempcon,
            cdsegmto: cdsegmto,
            nmrescon: nmrescon,
            nmextcon: nmextcon,
            cdhistor: cdhistor,
            nrdolote: nrdolote,
            flginter: flginter,
		    flgaccec: flgaccec,
            flgacsic: flgacsic,
            flgacbcb: flgacbcb,
            tparrecd: tparrecd, 
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
                eval(response);			
                hideMsgAguardo();
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    return false;

}
