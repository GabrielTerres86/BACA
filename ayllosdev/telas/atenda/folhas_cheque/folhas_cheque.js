/************************************************************************
 Fonte: folhas_cheque.js                                          
 Autor: David                                                     
 Data : Fevereiro/2008               Ultima Alteracao: 27/06/2012 
                                                                  
 Objetivo  : Biblioteca de funcoes da rotina Folhas de Cheque da  
             tela ATENDA                                          
                                                                  	 
 Alteracoes: 													   
			  27/06/2012 - Alterado esquema para impressao em      
						   carrega_lista() (Jorge)    			   
			  25/05/2018 - Criadas funcoes confirmaChequesNaoCompensados
						   e confirmaSolicitarTalonario. PRJ366 (Lombardi)

************************************************************************/

// Funcao para carregar lista de cheques n&atilde;o compensados em PDF
function carrega_lista() {	
	
	var nmprimtl = $("#nmprimtl","#frmCabAtenda").val().search("E/OU") == "-1" ? $("#nmprimtl","#frmCabAtenda").val() : $("#nmprimtl","#frmCabAtenda").val().substr(0,$("#nmprimtl","#frmCabAtenda").val().search("E/OU") - 1);

	$("#nrdconta","#frmCheques").val(nrdconta);
	$("#nmprimtl","#frmCheques").val(nmprimtl);
	
	var action = $("#frmCheques").attr("action");
	var callafter = "encerraRotina(false);";
	
	carregaImpressaoAyllos("frmCheques",action,callafter);
}

function solicitarTalonario () {
	// Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/folhas_cheque/solicitar_talonario.php',
        data: {
            nrdconta: nrdconta,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
			try {
                eval(response);
                return false;
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
            }
        }
    });
}

function validarAcessoLista () {
	// Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'script',
        url: UrlSite + 'telas/atenda/folhas_cheque/lista_cheques_acesso.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
			try {
                eval(response);
				//carrega_lista();
                return false;
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
            }
        }
    });
}


function confirmaChequesNaoCompensados () {
	showConfirmacao('Deseja visualizar a rela&ccedil;&atilde;o de cheques n&atilde;o compensados?','Confirma&ccedil;&atilde;o - Ayllos','validarAcessoLista();','blockBackground(parseInt($("#divRotina").css("z-index")))','sim.gif','nao.gif');
}

function confirmaSolicitarTalonario () {
	showConfirmacao('Confirma a solicita&ccedil;&atilde;o do talon&aacute;rio?','Confirma&ccedil;&atilde;o - Ayllos','solicitarTalonario();','blockBackground(parseInt($("#divRotina").css("z-index")))','sim.gif','nao.gif');
}