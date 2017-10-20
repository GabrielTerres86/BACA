/*!
 * FONTE        : impressao.js
 * CRIAÇÃO      : André Socoloski (DB1)
 * DATA CRIAÇÃO : 25/03/2011 
 * OBJETIVO     : Biblioteca de funções de impressao na rotina Emprestimos da tela ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [09/07/2012] Jorge Hamaguchi (CECRED) : Retirado window.open de funcao carregarImpresso() e adicionado target variavel. Retirado campo "redirect" popup.
 * 002: [13/08/2014] Lucas R./Gielow (CECRED) : Ajustes para validar tipo de impressão do tipo 6, Projeto CET.
 * 003: [03/09/2014] Jonata (RKAM)  : Orgaos de protecao ao credito.
 * 004: [06/11/2014] Jaison (CECRED): Ajuste na funcao mostraDivImpressao para nao remover todo o conteudo da divUsoGenerico e sim apenas os botoes no arquivo impressao.php
 * 005: [09/06/2015] Gabriel (RKAM) : Imprimir contrato nao negociavel.
 * 006: [26/06/2015] Jaison (CECRED): Passagem do parametro 'portabil' na funcao 'mostraDivImpressao'.
 * 007: [26/06/2015] Lombardi (CECRED): Inclusão da function 'verificaDadosJDCTCPortabilidade'.
 * 008: [15/03/2016] Odirlei (AMCOM): Alterado rotina mostraEmail para verificar se deve permitir o envio de email para o comite. PRJ207 - Esteira
 */

var flmail_comite;
// Carrega biblioteca javascript referente ao RATING
$.getScript(UrlSite + "includes/rating/rating.js");

// Função para Mostrar Div de Impressão
function mostraDivImpressao( operacao ) {

	showMsgAguardo('Aguarde, abrindo impressão...');
    
    limpaDivGenerica();
    
    exibeRotina($('#divUsoGenerico'));
                            
    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/impressao.php',
        data: {
            operacao: operacao,
            flgimppr: flgimppr,
            flgimpnp: flgimpnp,
            cdorigem: cdorigem,
			nrctremp: nrctremp,
			nrdconta: nrdconta,
            portabil: portabil,
            redirect: 'html_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });

    divRotina.css('width','330');
    $('#divConteudoOpcao','#tbImp').css({'height':'200px','width':'330'});

    $('input','#tbImp > #divConteudoOpcao').css({'clear':'left'});

	return false;
}

function validaImpressao( operacao ){
	
	showMsgAguardo('Aguarde, carregando...');
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/atenda/emprestimos/valida_impressao.php',
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, 
			recidepr: nrdrecid, operacao: operacao,
			tplcremp: tplcremp, nrctremp: nrctremp, 
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();

			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
						
				if ( response.indexOf('showError("error"') == -1 ) {
										
					hideMsgAguardo();
					bloqueiaFundo(divRotina);
					
					eval(response);
																									
				} else {
									
					hideMsgAguardo();
					eval( response );
				}
									
				
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
			}
		}				
	});
	
	return false;
}

// Função para verificar a opção de impressão
function verificaImpressao(par_idimpres){

	idimpres = par_idimpres;
	
	if ( idimpres >= 1 && idimpres <= 23 ) {
		
		if ( idimpres == 5 ) {
			var metodo = '';
			
			imprimirRating(false,90,nrctremp,"divConteudoOpcao","controlaOperacao('');");
			
			if ( $('#divAguardo').css('display') == 'block' ){
				metodo = $('#divAguardo');
			}else{
				metodo = $('#divRotina');
			}
			fechaRotina($('#divUsoGenerico'),metodo);
		}
		else 
		if  (idimpres == 7 || idimpres == 8 || idimpres == 9 || idimpres == 23) {
			carregarImpresso();
		}
		else {
            if (idimpres == 2 || idimpres == 3) {
                verificaDadosJDCTCPortabilidade();
            }
            else {
			    if ( ( flgimpnp == 'yes' ) && in_array(idimpres,[1,4]) ) {
				    mostraNP(idimpres);
			    } else {
				    promsini = 1;
				    mostraEmail();
			    }
		    } 		
        }		
		
	}else{
		showError('error','Opção de impressão inválida','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
	}
}

function verificaDadosJDCTCPortabilidade() {
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/emprestimos/verificaDadosJDCTCPortabilidade.php',
        data: {
            nrdconta: nrdconta,
            nrctremp: nrctremp,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {
            fechaRotina($('#divUsoGenerico'), $('#divRotina'));
            if (response.substr(0, 4) == "hide") {
                eval(response);
            } else {
                if (response == "S") {
                    if ((flgimpnp == 'yes') && in_array(idimpres, [1, 4])) {
                        mostraNP(idimpres);
                    } else {
                        promsini = 1;
                        mostraEmail();
                    }
                } else
                if (response == "N") {
                    showError('error', 'Saldo devedor/Qtd. parcelas não liquidadas/Data do último vencimento não confere(m) com dados recebidos da IF Credora.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                } else {
                    showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                }
            }
            return false;
        }
    });

}

// Função para fechamento da tela de impressão
function fechaImpressao(operacao){
	
	fechaRotina($('#divUsoGenerico'),$('#divRotina'));
	
	if (operacao != 'fechar') { controlaOperacao(operacao); }
	
	return false;

}

// Função para número inicial de nota promissória
function mostraNP( operacao ) {

	showMsgAguardo('Aguarde, abrindo impressão...');
	exibeRotina($('#divUsoGenerico'));

	limpaDivGenerica();
		
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/emprestimos/nota_promissoria.php',
		data: {
			operacao: operacao,
			redirect: 'html_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			layoutPadrao();
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
		}
	});

	return false;
}

// Função que tratar fechamento da confirmação da promissória inicial
function fechaNP(operacao){
		
	if ( qtpromis < $('#nrpromini' , '#frmNotaini').val() ){
		showError('error','Número de nota promissória inicial inválido','Alerta - Ayllos',"bloqueiaFundo($('#divUsoGenerico'));");
		return false;
	}

	promsini = $('#nrpromini' , '#frmNotaini').val();
	
	fechaRotina($('#divUsoGenerico'),$('#divRotina'));

	mostraEmail();

	return false;

}

//Função para chamar Confirmação de E-mail
function mostraEmail() {
    
    // Verificar se deve permitir envio de email para o comite
    if (flmail_comite == 1) {
	
    var metodoSim = "flgemail=true;carregarImpresso();";
	var metodoNao = "flgemail=false;carregarImpresso();";

	showConfirmacao("Efetuar envio de e-mail para Sede?","Confirma&ccedil;&atilde;o - Ayllos",metodoSim,metodoNao,"sim.gif","nao.gif");
    } else  
        {  
          flgemail=false;
          carregarImpresso();
        }
    
}

// Função para envio de formulário de impressao
function carregarImpresso(){
	var nrcpfcgc = normalizaNumero($("#nrcpfcgc", "#frmCabAtenda").val());
	
	fechaRotina($('#divUsoGenerico'),$('#divRotina'));
	
	$('#idimpres','#formEmpres').remove();
	$('#promsini','#formEmpres').remove();
	$('#flgemail','#formEmpres').remove();
	$('#nrdrecid','#formEmpres').remove();
	$('#nrdconta','#formEmpres').remove();
	$('#nrctremp','#formEmpres').remove();
	$('#sidlogin','#formEmpres').remove();
	$('#nrcpfcgc','#formEmpres').remove();
	
	
	// Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#formEmpres').append('<input type="hidden" id="idimpres" name="idimpres" />');
	$('#formEmpres').append('<input type="hidden" id="promsini" name="promsini" />');
	$('#formEmpres').append('<input type="hidden" id="flgemail" name="flgemail" />');
	$('#formEmpres').append('<input type="hidden" id="nrdrecid" name="nrdrecid" />');
	$('#formEmpres').append('<input type="hidden" id="nrdconta" name="nrdconta" />');
	$('#formEmpres').append('<input type="hidden" id="nrctremp" name="nrctremp" />');
	$('#formEmpres').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	$('#formEmpres').append('<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" />');
	
	// Agora insiro os devidos valores nos inputs criados
	$('#idimpres','#formEmpres').val( idimpres );
	$('#promsini','#formEmpres').val( promsini );
	$('#flgemail','#formEmpres').val( flgemail );
	$('#nrdrecid','#formEmpres').val( nrdrecid );
	$('#nrdconta','#formEmpres').val( nrdconta );
	$('#nrctremp','#formEmpres').val( nrctremp );
	$('#nrcpfcgc','#formEmpres').val( nrcpfcgc );
	$('#sidlogin','#formEmpres').val( $('#sidlogin','#frmMenu').val() );

	var action = UrlSite + 'telas/atenda/emprestimos/imprimir_dados.php';
	
	carregaImpressaoAyllos("formEmpres",action,"bloqueiaFundo(divRotina);");
	
	return false;
}

