/*!
 * FONTE        : autori.js
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 13/05/2011
 * OBJETIVO     : Biblioteca de funções da tela AUTORI
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Migrado para o Novo Layout (Lucas).
 * --------------
 * 				  19/05/2014 - Ajustes referentes ao Projeto debito Automatico
 *							   Softdesk 148330 (Lucas R.)
 *
 *				  17/12/2014 - Incluir function validaCampos(), para validar os campos 
 *							   digitados se for sicredi e manual sim/não (Lucas R. #234429)
 *
 *				  19/12/2014 - Ajustado opcao I, para não deixar incluir historico em branco, 
 *							   trocado funcao keypress por keydown (Lucas R. #235558)
 *
 *				  03/02/2015 - Ajustado procedure calculoDigito (Lucas R. #242146)
 *
 *				  09/03/2015 - Ajustado para nao habilitar os campos enquanto a funcao que 
 *                             valida conta sicredi nao terminar, habilitando o campo dentro
 *                             do php valida_conta_sicredi.php (SD260803 - Tiago).
 *
 *				  25/03/2015 - Aumentar format do cdrefere de 17 para 25 (Lucas Ranghetti #269537)
 *
 *				  13/04/2015 - Bloquear campos flgsicre,flgmanua apos selecionados, validar referencia
 *							   ao click no botao incluir (Lucas Ranghetti #275084)
 *
 *                15/10/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *
 *                15/04/2016 - Retirado "normalizaNumero" dos campos faturas e Cod. Barras, 
 *                             pois estava removendo o zero da fatura apresentando problema ao grava 
 *                             o convênios Sicredi. (Gisele C. Neves RKAM - #407091).
 *
 *				  18/04/2016 - Incluir senha do cartão magnetico PinPad para as operações M-141(Lucas Ranghetti #436229)
 *
 *				  06/05/2016 - Revisão do processo de validação de senha e 
 *                             correção do fluxo para convenios SICRED [Rafael Maciel (RKAM) #436229] 
 *
 *                24/04/2016 - Criação de nova opção para cadastro de SMS (Dionathan)
 *
 *				  31/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])
 *
 *				  24/10/2016 - Ajustar mensagem de critica no cancelamento da operacao, sem efetuar a operacao (Lucas Ranghetti #537829)
 *
 *                31/10/2016 - Incluir validação para passar histórico 1019 caso for Sicredi e não for 
 *							   operação de consulta (Lucas Ranghetti #547448)
 *
 *				  16/01/2017 - Arrumar a gravacao da flginassele (Lucas Ranghetti #564654)
 *
 *                12/09/2017 - Tratamento para não permitir o prosseguimento da rotina caso ocorra erro de digito 
 *                             para a referencia no caso de sicredi sim (Lucas Ranghetti #751239)
 */

// Definição de algumas variáveis globais 
var operacao 		= ''; // Armazena a operação corrente da tela AUTORI
var operacaoOld		= ''; // Variável auxiliar para guardar a operação passada
var dsdconta 		= ''; // Armazena o Nome do Associado
var cdsitdtl		= 0; // Armazena valor para validar prejuizo
var nrseqdig		= 0; // Armazena a chave do registro
var cdhistor		= 0; // Armazena a Número do Historico
var cdrefere		= 0; // Armazena o Número da Referência
var dtlimite		= 0; // Armazena a Data Limite 
var flginassele = 0;	 
var arrayAutori   	= new Array();

var valida = 0; // 0 = Segue com operacao/ 1 = Barra operacao

var erroRef = 0;

$(document).ready(function() {	
	
	controlaOperacao();			
});

function controlaOperacao( novaOp ) {

	operacao = ( typeof novaOp != 'undefined' ) ? novaOp : operacao;	
	
	
	var mensagem = '';
	var cdhistor = normalizaNumero($('#cdhistor','#frmAutori').val());
    var cdrefere = $('#cdrefere','#frmAutori').val();
	var flgsicre = $('#flgsicre','#frmAutori').val();
	
	switch (operacao) {
		case 'C1': mensagem = 'Aguarde, abrindo formulário ...'; break;		
		case 'C2': mensagem = 'Aguarde, abrindo vizualiza&ccedil;&atilde;o ...'; break;		
		case 'A2': manterRotina(''); return false; break;		
		case 'A4': manterRotina(''); return false; break;	
		case 'A5': manterRotina(''); return false; break;	
		case 'I1': mensagem = 'Aguarde, abrindo formulário ...'; break;
		case 'I2': manterRotina(); return false; break;	// valida prejuizo	
		case 'I3': manterRotina(); return false; break; // valida historico
		case 'I4': manterRotina(); return false; break;	// valida dados
		case 'I5': manterRotina(); return false; break;		
		case 'I6': mensagem = 'Aguarde, abrindo vizualiza&ccedil;&atilde;o ...'; break;		
		case 'E1': mensagem = 'Aguarde, abrindo formulário ...'; break;		
		case 'E2': manterRotina(); return false; break;		
		case 'E3': mensagem = 'Aguarde, buscando dados ...'; break;
		case 'E5': manterRotina(); return false; break;
		case 'E6': manterRotina(); return false; break;
		case 'R1': mensagem = 'Aguarde, abrindo formulário ...'; break;	
		case 'R2': manterRotina(); return false; break;
		case 'R3': manterRotina(); return false; break;
		case 'R4': mensagem = 'Aguarde, buscando dados ...'; break;
		case 'R5': manterRotina(); return false; break;
		case 'R6': manterRotina(''); return false; break; 	
		case 'S1': mensagem = 'Aguarde, buscando telefone ...'; break;
		case 'S2': manterRotinaSMS(); return false;
		case 'S3': manterRotinaSMS(); return false;
		case 'GC': manterRotina(); return false;
		default: mensagem = 'Aguarde, abrindo tela ...'; break;		

	}

	if ((flgsicre == 'S') && (operacao != 'C2') ) {
		cdhistor = 1019;
	}	
	
	showMsgAguardo( mensagem );	

	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/autori/principal.php', 
		data    : 
				{ 
					nmdatela: 'AUTORI',
					nmrotina: '',
					nrdconta: nrdconta,	
					dsdconta: dsdconta,	
					operacao: operacao,
					cdhistor: cdhistor,
					cdrefere: cdrefere,
					dtlimite: dtlimite,
					flgsicre: flgsicre,
					nrseqdig: 0,
					executandoProdutos: executandoProdutos,
					redirect: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
	
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Autori','$(\'#nrdconta\',\'#frmCabAutori\').focus()');
				},
		success : function(response) { 
	
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTela').html(response);
							
							if (operacao == '' && executandoProdutos) {
								$('#opcao','#frmCabAutori').val('I1');
								$('#nrdconta','#frmCabAutori').val(nrdconta);
								controlaOperacao('I1');
							}
							
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
						}
					} else {
						try {
							eval( response );
							//controlaFoco();
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
						}
					}
				}
	}); 
}

function manterRotina() {
		
		
	hideMsgAguardo();		
	var mensagem = '';
	switch (operacao) {	
		case 'A2': mensagem = 'Aguarde, validando historico ...'; break;
		case 'A4': mensagem = 'Aguarde, validando dados ...'; break;
		case 'A5': mensagem = 'Aguarde, alterando ...'; break;
		case 'I2': mensagem = 'Aguarde, validando prejuizo ...'; break;
		case 'I3': mensagem = 'Aguarde, validando historico ...'; break;
		case 'I4': mensagem = 'Aguarde, validando dados ...'; break;
		case 'I5': mensagem = 'Aguarde, incluindo ...'; break;
		case 'E2': mensagem = 'Aguarde, validando historico ...'; break;
		case 'E5': mensagem = 'Aguarde, validando dados ...'; break;
		case 'E6': mensagem = 'Aguarde, excluindo ...'; break;
		case 'R2': mensagem = 'Aguarde, validando opera&ccedil;&atilde;o ...'; break;
		case 'R3': mensagem = 'Aguarde, validando historico ...'; break;
		case 'R5': mensagem = 'Aguarde, validando dados ...'; break;
		case 'R6': mensagem = 'Aguarde, alterando ...'; break;
		case 'GC': mensagem = 'Aguarde, gerando conta Sicredi ...'; break;
		default: return false; break;
	}

	var cdhistor = normalizaNumero($('#cdhistor','#frmAutori').val());
	var dshistor = $('#dshistor','#frmAutori').val();
	var cdrefere = $('#cdrefere','#frmAutori').val();
	var cddddtel = $('#cddddtel','#frmAutori').val();
	var dtautori = $('#dtautori','#frmAutori').val();
	var dtcancel = $('#dtcancel','#frmAutori').val();
	var dtultdeb = $('#dtultdeb','#frmAutori').val();
	var flgsicre = $('#flgsicre','#frmAutori').val();
	var fatura01 = $('#fatura01','#frmAutori').val();
	var fatura02 = $('#fatura02','#frmAutori').val();
	var fatura03 = $('#fatura03','#frmAutori').val();
	var fatura04 = $('#fatura04','#frmAutori').val();
	var codbarra = $('#codbarra','#frmAutori').val();
	var flgmanua = $('#flgmanua','#frmAutori').val();
	
	var nmfatura = '';
	var nmempres = '';
	erroRef = 0;
	
	if (operacao == 'I4') {
		if ( $('#dshistor','#frmAutori').val() == '') {
			showError('error','Convenio não informado.','Alerta - AUTORI','focaCampoErro(\'dshistor\',\'frmAutori\');');
			return false;
		}
		if ($('#cdrefere','#frmAutori').val() == '') {
			showError('error','Referencia não informada.','Alerta - AUTORI','focaCampoErro(\'cdrefere\',\'frmAutori\');');
			return false;
		}
		if ($('#flgsicre','#frmAutori').val() == 'S') {
			calculoDigito('referencia','cdrefere');
			if (erroRef == 1) {
			  return false;
			}
		}
	}
	
	if (flgsicre == 'S') {
		cdhistor = 1019;
	}
	
	showMsgAguardo( mensagem );
	
	$.ajax({
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/autori/manter_rotina.php',
			data: {
				nrdconta: nrdconta,
				nrseqdig: nrseqdig,
				operacao: operacao,
				cdhistor: cdhistor,
				dshistor: dshistor,
				cdrefere: cdrefere,
				cddddtel: cddddtel,
				dtautori: dtautori,
				dtcancel: dtcancel,
				dtultdeb: dtultdeb,
				nmfatura: nmfatura,
				nmempres: nmempres,
				dtlimite: dtlimite,
				cdsitdtl: cdsitdtl,
				flgsicre: flgsicre,
				flgmanua: flgmanua,
				codbarra: codbarra,
				cdrefere: cdrefere,
				fatura01: fatura01,
				fatura02: fatura02,
				fatura03: fatura03,
				fatura04: fatura04,
				executandoProdutos: executandoProdutos,
				flginassele: flginassele,
				redirect: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
	
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			},
			success: function(response) {
	
				try {
					eval(response);
					if (operacao == 'I4') {
						$('#btSalvarI5'       ,'#divBotoes').show();
					}
					else
					if (operacao == 'R6') {
						hideMsgAguardo();
						
						showError('inform','Opera&ccedil;&atilde;o realizada com sucesso!','Alerta - Ayllos','controlaOperacao("");');
					}
					else
					if (operacao == 'GC') {
						ValidaContaSicredi();
					}
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		});

	return false;
}

function manterRotinaSMS() {

	// Mostra mensagem de aguardo
	if (operacao == "S1"){  	   showMsgAguardo("Aguarde, consultando Telefone..."); } 
	else if (operacao == "S2"){ showMsgAguardo("Aguarde, incluindo Telefone...");  }
	else if (operacao == "S3"){ showMsgAguardo("Aguarde, alterando Telefone...");  }	
	else { showMsgAguardo("Aguarde..."); }
	
	var nrdddtfc = normalizaNumero($('#nrdddtfc','#frmSms').val());
	var nrtelefo = normalizaNumero($('#nrtelefo','#frmSms').val());
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/autori/manter_rotina_sms.php", 
		data: {
			nrdconta: nrdconta,
			operacao: operacao,
			nrdddtfc: nrdddtfc,
			nrtelefo: nrtelefo,
			redirect: "script_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			}
		}				
	});
}

function confirmaExclusaoSMS(){
	showConfirmacao("Confirma a exclus&atilde;o do celular cadastrado?","Confirma&ccedil;&atilde;o - Ayllos","controlaOperacao('S3');","","concluir.gif","cancelar.gif");
}

function controlaLayout() {


	$('#divTela').fadeTo(0,0.1);
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('#divBotoes').css({'text-align':'center','padding-top':'5px'});

	if ( operacao == 'C2' ) {

		altura  = '150px';
		largura = '430px';

		// Configurações da tabela
		var divRegistro = $('div.divRegistros');
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
			
		divRegistro.css('height','150px');
			
		var ordemInicial = new Array();
		ordemInicial = [[0,0]];
			
			var arrayLargura = new Array();
			arrayLargura[0] = '';
			arrayLargura[1] = '190px';
			arrayLargura[2] = '67px';
			arrayLargura[3] = '67px';
			arrayLargura[4] = '67px';
			
			var arrayAlinha = new Array();
			arrayAlinha[0] = 'center';
			arrayAlinha[1] = 'center';
			arrayAlinha[2] = 'center';
			arrayAlinha[3] = 'center';
			arrayAlinha[4] = 'center';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
				
		divRotina.css('width',largura);	
		$('#divRotina').css({'height':altura,'width':largura});
	} 
	
	// cabecalho
	var cOpcao    	= $('#opcao','#frmCabAutori');
	var cNrConta  	= $('#nrdconta','#frmCabAutori');	
	
	// autorizacao
	var rCdHistor	= $('label[for="cdhistor"]','#frmAutori');
	var rDsHistor 	= $('label[for="dshistor"]','#frmAutori');
	var rCdRefere 	= $('label[for="cdrefere"]','#frmAutori');
	var rDtAutori 	= $('label[for="dtautori"]','#frmAutori');
	var rDtCancel 	= $('label[for="dtcancel"]','#frmAutori');
	var rDtUltdeb  	= $('label[for="dtultdeb"]','#frmAutori');
	
	rDsHistor.addClass('rotulo').css('width','85px');
	rCdRefere.addClass('rotulo-linha').css('width','30px');
	rDtAutori.addClass('rotulo').css('width','85px');
	rDtCancel.addClass('rotulo-linha').css('width','80px');
	rDtUltdeb.addClass('rotulo-linha').css('width','80px');	
	
	var cTodos		= $('input','#frmAutori');
	var cCdHistor	= $('#cdhistor','#frmAutori');
	var cDsHistor 	= $('#dshistor','#frmAutori');
	var cCdRefere 	= $('#cdrefere','#frmAutori');
	var cDtAutori 	= $('#dtautori','#frmAutori');
	var cDtCancel 	= $('#dtcancel','#frmAutori');
	var cDtUltdeb 	= $('#dtultdeb','#frmAutori');	
	
	var rFlgsicre = $('label[for="flgsicre"]','#frmAutori');
	var rFlgmanua = $('label[for="flgmanua"]','#frmAutori');
	var cFlgsicre   = $('#flgsicre','#frmAutori');
	var cFlgmanua   = $('#flgmanua','#frmAutori');	
	var cCodbarra   = $('#codbarra','#frmAutori');
	var cFatura01   = $('#fatura01','#frmAutori');	
	var cFatura02   = $('#fatura02','#frmAutori');	
	var cFatura03   = $('#fatura03','#frmAutori');	
	var cFatura04   = $('#fatura04','#frmAutori');	
	var rCodbarra   = $('label[for="codbarra"]','#frmAutori');
	var rFatura01   = $('label[for="fatura01"]','#frmAutori');
	var rFatura02   = $('label[for="fatura02"]','#frmAutori');
	var rFatura03   = $('label[for="fatura03"]','#frmAutori');
	var rFatura04   = $('label[for="fatura04"]','#frmAutori');	
	
	rFlgsicre.addClass('rotulo').css('width','85px');
	rFlgmanua.addClass('rotulo-linha').css('width','85px');
	cFlgsicre.css('width','80px');
	cFlgmanua.css('width','70px');
	
	rCodbarra.addClass('rotulo').css('width','85px');
	rFatura01.addClass('rotulo').css('width','85px');
	rFatura02.addClass('rotulo-linha').css('width','5px');
	rFatura03.addClass('rotulo-linha').css('width','5px'); 
	rFatura04.addClass('rotulo-linha').css('width','5px');
	
	cCodbarra.addClass('campo inteiro').css('width','320px').attr('maxlength','44');
	cFatura01.addClass('campo inteiro').css('width','95px').attr('maxlength','12');
	cFatura02.addClass('campo inteiro').css('width','95px').attr('maxlength','12');
	cFatura03.addClass('campo inteiro').css('width','95px').attr('maxlength','12');
	cFatura04.addClass('campo inteiro').css('width','95px').attr('maxlength','12');
	
	cCdHistor.addClass('campo codigo pesquisa');
	cDsHistor.addClass('campo alphanum').css('width','258px').attr('maxlength','50');
	cCdRefere.addClass('campo inteiro').css('width','115px').attr('maxlength','25');
	cDtAutori.addClass('campo data').css('width','75px');
	cDtCancel.addClass('campo data').css('width','75px');
	cDtUltdeb.addClass('campo data').css('width','75px');
	
	cFlgsicre.habilitaCampo();
	cTodos.habilitaCampo();
	
	cCodbarra.desabilitaCampo();
	cFatura01.desabilitaCampo();
	cFatura02.desabilitaCampo();
	cFatura03.desabilitaCampo();
	cFatura04.desabilitaCampo();
	cFlgmanua.desabilitaCampo();
	cCdRefere.desabilitaCampo();
	cDsHistor.desabilitaCampo(); 
	
	
	//SMS
	var rNrDDDTfc  	= $('label[for="nrdddtfc"]','#frmSms');
	var rNrTelefo 	= $('label[for="nrtelefo"]','#frmSms');
	
	rNrDDDTfc.addClass('rotulo-linha').css('width','80px');
	rNrTelefo.addClass('rotulo-linha').css('width','80px');
	
	var cNrDDDTfc  	= $('#nrdddtfc','#frmSms');
	var cNrTelefo 	= $('#nrtelefo','#frmSms');
	
	cNrDDDTfc.addClass('campo inteiro').attr('maxlength','3').css('width','60px');
	cNrTelefo.addClass('campo inteiro').attr('maxlength','10').css('width','87px');
	
	
	$('label[for="dtautori"],label[for="dtcancel"],label[for="dtultdeb"]','#frmAutori').css('display','none');
	$('#dtautori,#dtcancel,#dtultdeb','#frmAutori').css('display','none');
	
	//Desabilita campos de fatura e codigo de barras se convenio for sicredi
	$('label[for="fatura01"],label[for="fatura02"],label[for="fatura03"],label[for="fatura04"],label[for="codbarra"]','#frmAutori').css('display','none');
	$('#fatura01,#fatura02,#fatura03,#fatura04,#codbarra','#frmAutori').css('display','none');
	
	$('#btSalvarI5'       ,'#divBotoes').hide();
	$('#divConteudoSenha').css('display','none');
	fechaRotina($('#divRotina'));

	//CONSULTA
	if  (cOpcao.val() == 'C1') {
		cFlgsicre.focus();
			
		cFlgsicre.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9) {  
				
				if (cFlgsicre.val() == 'S') {
					controlaOperacao('C2');
				} else {
					
					cDsHistor.habilitaCampo();
					cDsHistor.focus(); 
					cFlgsicre.desabilitaCampo();
				}
				return false;
			} 
		});
		
		cDsHistor.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9) {
				if (cDsHistor.val() != ''){
					buscaHistorico();
				}
				if (cFlgsicre.val() == 'N'){
					validaHistorico(cOpcao.val());
				}
				cCdRefere.habilitaCampo();
				cCdRefere.focus();
				return false;
			} 
		});
	
		cCdRefere.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9) {
				if (cCdRefere.val() != '' && cDsHistor.val() == '' ) {
					showError('error','Se digitar a referência favor informar o convênio.','Alerta - AUTORI','focaCampoErro(\'dshistor\',\'frmAutori\');');
					return false;
				}
			    controlaOperacao('C2');
				return false;
			}
		});
		//INCLUIR
	} else if (cOpcao.val() == 'I1') {
		
		cCdHistor.habilitaCampo();
		cFlgsicre.focus();
		$('#btSalvarI5'       ,'#divBotoes').hide();
		$('#lupa_frmAutori','#frmAutori').hide();		
		
		cFlgsicre.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9) { 
				if (cFlgsicre.val() == 'S') {
					$('label[for="fatura01"],label[for="fatura02"],label[for="fatura03"],label[for="fatura04"],label[for="codbarra"]','#frmAutori').css('display','block');
					$('#fatura01,#fatura02,#fatura03,#fatura04,#codbarra','#frmAutori').css('display','block');
					ValidaContaSicredi(); 
				}else{
					$('label[for="fatura01"],label[for="fatura02"],label[for="fatura03"],label[for="fatura04"],label[for="codbarra"]','#frmAutori').css('display','none');
					$('#fatura01,#fatura02,#fatura03,#fatura04,#codbarra','#frmAutori').css('display','none');
					cFlgmanua.desabilitaCampo();
					cDsHistor.habilitaCampo();
					cDsHistor.focus();
					cFlgsicre.desabilitaCampo();
					$('#lupa_frmAutori','#frmAutori').show();
				}
				return false;
			}
		});

		cFlgmanua.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				if (cFlgmanua.val() == 'S') { 
					cCodbarra.desabilitaCampo().val('');
					cFatura01.habilitaCampo().focus();
					cFatura01.focus();
					desabilitaFaturas('#flgmanua');
				} else{ 
					cFatura01.desabilitaCampo().val('');
					cCodbarra.habilitaCampo();
					cCodbarra.focus(); 
					desabilitaFaturas('#flgmanua');
				}
				return false;
			}
		});

		cCodbarra.unbind('keydown').bind('keydown', function(e) { 
	
			if ( e.keyCode == 13 || e.keyCode == 9) {
				if (cCodbarra.val() == '') {
					showError('error','Código de barras não informado.','Alerta - AUTORI','focaCampoErro(\'codbarra\',\'frmAutori\');');
					return false;
				}
				calculoDigito('barra','codbarra');
			}
		});

		cFatura01.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9) {
				if (cFatura01.val() == '') {
					showError('error','Fatura não informada.','Alerta - AUTORI','focaCampoErro(\'fatura01\',\'frmAutori\');');
					return false;
				}
				calculoDigito('fatura','fatura01');
			}
		});
		
		cFatura02.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9) { 
				if (cFatura02.val() == '') {
					showError('error','Fatura não informada.','Alerta - AUTORI','focaCampoErro(\'fatura02\',\'frmAutori\');');
					return false;
				}
				calculoDigito('fatura','fatura02');
			}
		});
		
		cFatura03.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9) { 
				if (cFatura03.val() == '') {
					showError('error','Fatura não informada.','Alerta - AUTORI','focaCampoErro(\'fatura03\',\'frmAutori\');');
					return false;
				}
				calculoDigito('fatura','fatura03');
			}
		});
		
		cFatura04.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9) { 
				if (cFatura04.val() == '') {
					showError('error','Fatura não informada.','Alerta - AUTORI','focaCampoErro(\'fatura04\',\'frmAutori\');');
					return false;
				}
				calculoDigito('fatura','fatura04');
			}
		});
		
		cDsHistor.unbind('keydown').bind('keydown', function(e) { 
	
			if ( e.keyCode == 13 || e.keyCode == 9) {
				if (cDsHistor.val() == '') {
					showError('error','Convenio não informado.','Alerta - AUTORI','focaCampoErro(\'dshistor\',\'frmAutori\');');
					return false;
				}
				$('#btSalvarI5'       ,'#divBotoes').show();
				buscaHistorico();
				$('#cdrefere','#frmAutori').habilitaCampo().focus();
				return false;
			} 
		});
		
		cCdRefere.unbind('keydown').bind('keydown', function(e) { 
	
			if ( e.keyCode == 13 || e.keyCode == 9) { 
				if (cCdRefere.val() == '') {
					showError('error','Referencia não informada.','Alerta - AUTORI','focaCampoErro(\'cdrefere\',\'frmAutori\');');
					return false;
				}
				if (cFlgsicre.val() == 'S') {
					calculoDigito('referencia','cdrefere');
					controlaOperacao('I4');
				}else{ 
					validaHistorico(cOpcao.val());
				}
				
				return false;
			} 
		});
		//EXCLUIR
	} else if (cOpcao.val() == 'E1') {
	
		$('label[for="dtautori"],label[for="dtcancel"],label[for="dtultdeb"]','#frmAutori').css('display','block');
		$('#dtautori,#dtcancel,#dtultdeb','#frmAutori').css('display','block');
	
		cDtAutori.desabilitaCampo();
		cDtCancel.desabilitaCampo();
		cDtUltdeb.desabilitaCampo();
		
		cFlgmanua.desabilitaCampo();
		cDsHistor.desabilitaCampo();
		cFlgsicre.focus();
		
		cFlgsicre.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9) { 
				cDsHistor.habilitaCampo();
				cDsHistor.focus();
				cFlgsicre.desabilitaCampo();
				return false;
			} 
		});
		
		cDsHistor.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9) {
				if (cDsHistor.val() == '') {
					showError('error','Histórico não informado.','Alerta - AUTORI','focaCampoErro(\'dshistor\',\'frmAutori\');');
					return false;
				}
				cDsHistor.removeClass('campoErro');
				
				if (cDsHistor.val() != ''){
					buscaHistorico();
				}
				if (cFlgsicre.val() == 'N'){
					validaHistorico(cOpcao.val());
				}
				cCdRefere.habilitaCampo();
				cCdRefere.focus();
				return false;
			} 
		});
	
		cCdRefere.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9) {
				if (cDsHistor.val() == '') {
					showError('error','Histórico não informado.','Alerta - AUTORI','focaCampoErro(\'dshistor\',\'frmAutori\');');
					return false;
				}
				cDsHistor.removeClass('campoErro');
				
				if (cCdRefere.val() == '') {
					showError('error','Referência não informada.','Alerta - AUTORI','focaCampoErro(\'cdrefere\',\'frmAutori\');');
					return false;
				}
				cCdRefere.removeClass('campoErro');
				cDtAutori.desabilitaCampo();
				showConfirma();
				return false;
			}
		});
		//RECADASTRAR
	} else if (cOpcao.val() == 'R1') {
			
		$('label[for="dtautori"],label[for="dtcancel"],label[for="dtultdeb"]','#frmAutori').css('display','block');
		$('#dtautori,#dtcancel,#dtultdeb','#frmAutori').css('display','block');
	
		cDtAutori.desabilitaCampo();
		cDtCancel.desabilitaCampo();
		cDtUltdeb.desabilitaCampo();
		
		cFlgmanua.desabilitaCampo();
		cDsHistor.desabilitaCampo();
		cFlgsicre.focus();
		
		cFlgsicre.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9) { 
				cDsHistor.habilitaCampo();
				cDsHistor.focus();
				cFlgsicre.desabilitaCampo();
				return false;
			} 
		});
		
		cDsHistor.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9) {
				if (cDsHistor.val() == '') {
					showError('error','Histórico não informado.','Alerta - AUTORI','focaCampoErro(\'dshistor\',\'frmAutori\');');
					return false;
				}
				cDsHistor.removeClass('campoErro');
				
				if (cDsHistor.val() != ''){
					buscaHistorico();
				}
				if (cFlgsicre.val() == 'N'){
					validaHistorico(cOpcao.val());
				}
				cCdRefere.habilitaCampo();
				cCdRefere.focus();
				return false;
			} 
		});	
		
	
		cCdRefere.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9) {
				if (cDsHistor.val() == '') {
					showError('error','Histórico não informado.','Alerta - AUTORI','focaCampoErro(\'dshistor\',\'frmAutori\');');
					return false;
				}
				cDsHistor.removeClass('campoErro');
				
				if (cCdRefere.val() == '') {
					showError('error','Referência não informada.','Alerta - AUTORI','focaCampoErro(\'cdrefere\',\'frmAutori\');');
					return false;
				}
				cCdRefere.removeClass('campoErro');
				controlaOperacao('R4');
				return false;
			}
		});
		
		cDtAutori.keypress( function(e) {
	
			if ( e.keyCode == 13 || e.keyCode == 9 ) { 
				if (cDtCancel.val() == '') {
					controlaOperacao('R5');
				}else{  
					cDtCancel.habilitaCampo();
					cDtCancel.focus();
				}
				return false;
			}
		});
		
		cDtCancel.keypress( function(e) {
	
			if ( e.keyCode == 13 ) { 
				controlaOperacao('R5');
				return false;
			}
		});
    //SMS Débito automático
	} else if (cOpcao.val() == 'S1') {
		cNrDDDTfc.focus();
		
		cNrDDDTfc.keypress( function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9) {  
				
				cNrTelefo.focus();
				return false;
			} 
		});
		
		cNrTelefo.keypress( function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9) {  
				
				$('#btSalvar','#divBotoes').focus();
				return false;
			} 
		});
	}	
	
	layoutPadrao();
	$('.conta').trigger('blur');
	controlaPesquisas();
	removeOpacidade('divTela');
	return false;
	
}

function habilitaFaturas(campo) {
	
	setTimeout("$('"+campo+ "',"+"'#frmAutori').habilitaCampo().focus();");
}

function desabilitaFaturas(campo) {
	
	setTimeout("$('"+campo+ "',"+"'#frmAutori').desabilitaCampo();");
}

function formataCabecalho() {	
	
	
	var rLinha    = $('label[for="nrdconta"],label[for="nmprimtl"]','#frmCabAutori');	
	var rOpcao    = $('label[for="opcao"]','#frmCabAutori');	
	var rConta    = $('label[for="nrdconta"]','#frmCabAutori');		
	
	var cTodos	  = $('input[type="text"],select','#frmCabAutori');
	var cOpcao    = $('#opcao','#frmCabAutori');
	var cNrConta  = $('#nrdconta','#frmCabAutori');
    var cNome	  = $('#nmprimtl','#frmCabAutori');
		
	highlightObjFocus($('#frmCabAutori'));
	highlightObjFocus($('#frmAutori'));
		
	rLinha.addClass('rotulo-linha');
	cTodos.desabilitaCampo();
	rOpcao.addClass('rotulo').css('width','83px');
	rConta.addClass('rotulo').css('width','80px');
		
	cOpcao.css('width','490px');
	cNrConta.addClass('conta pesquisa').css('width','80px');	
	cNome.addClass('descricao').css('width','355px');
	
	if ( $.browser.msie ) {
		rConta.addClass('rotulo').css('width','83px');
	}
	
	cOpcao.habilitaCampo().focus();
	cNrConta.habilitaCampo();
	
	cOpcao.keypress( function(e) {
		if (e.keyCode == 13 || e.keyCode == 9) {
			cNrConta.focus();
			return false;
		}
	});
	
	if ( operacao == '' ) {
		
		// Se eu mudar a opção, muda a variável global operacao
		cOpcao.unbind('change').bind('change', function() { 
			operacao = $(this).val();
			operacaoOld = operacao;			
		});
		
		// Se pressionar alguma tecla no campo numero da conta, verificar a tecla pressionada e toda a devida ação
		cNrConta.unbind('keypress').bind('keypress', function(e) { 	
		
			if ( divError.css('display') == 'block' ) { return false; }		
			
			// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
			if ( e.keyCode == 13 ) {
				// Armazena o número da conta na variável global
				nrdconta = normalizaNumero( $(this).val() );
												
				// Verifica se o número da conta é vazio
				if ( nrdconta == '' ) { return false; }
					
				// Verifica se a conta é válida
				if ( !validaNroConta(nrdconta) ) { 
					showError('error','Conta/dv inv&aacute;lida.','Alerta - Autori','focaCampoErro(\'nrdconta\',\'frmCabAutori\');'); 
					return false; 
				}
				return false;
			// Se é a tecla TAB, focar o campo opcao
			} else if ( e.keyCode == 9 ) { 
				cOpcao.focus(); 
				return false; 
			}
		});		
		
		cNrConta.keypress( function(e) {
			if ( e.keyCode == 13 ) { 
				consultaInicial();
     			$('#flgsicre','#frmAutori').focus();
				
                return false;
				} 
			});			
	} else {	

		// Selecionar a opção (operação) correta
		$('#opcao option:selected','#frmCabAutori').val();
		
		if ( operacao.charAt(0) == 'C' ){
			$('#opcao','#frmCabAutori').val('C1');
		}else if ( operacao.charAt(0) == 'I'  ){
			$('#opcao','#frmCabAutori').val('I1');
		}else if ( operacao.charAt(0) == 'E' ) { 
			$('#opcao','#frmCabAutori').val('E1');
		}else if ( operacao.charAt(0) == 'R' ) { 
			$('#opcao','#frmCabAutori').val('R1');
		}else{
			$('#opcao','#frmCabAutori').val(operacao);
		}
	
		cNrConta.desabilitaCampo();
		cOpcao.desabilitaCampo();
	}
	
			
	return false;	
}

function controlaFoco() {
		
	if ( operacao == '' || operacao == 'C2' || operacao == 'I6' ) {
		$('#nrdconta','#frmCabAutori').focus()

	} 

	return false;
}

function controlaPesquisas() { 
	
	
	
	var cDsHistor = $('#dshistor','#frmAutori');
	
	var bo, procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas;
	
	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#frmCabAutori');

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {

		linkConta.prev().unbind('blur').bind('blur', function() { 
			controlaPesquisas();
			return false;
		});	
	
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {
			mostraPesquisaAssociado('nrdconta','frmCabAutori');
		});
	}	
	
	/*---------------------*/
	/*      HISTORICO      */
	/*---------------------*/
	var linkHistorico = $('a:eq(0)','#frmAutori');
	
	if ( linkHistorico.prev().hasClass('campoTelaSemBorda') ) {
		linkHistorico.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() {   return false; });
	} else {
		
		linkHistorico.prev().unbind('blur').bind('blur', function() { 
			controlaPesquisas();
			return false;
		});	 			
		
		linkHistorico.css('cursor','pointer').unbind('click').bind('click', function() { 
			validaCampos();
			if (valida == 0){
				buscaHistorico();
				if ($('#opcao','#frmCabAutori').val() == 'I1' ) {
					$('#btSalvarI5'       ,'#divBotoes').show();
				}
			}
		});
	}
}

function validaCampos() {
	
	valida = 0;
	// Se for sicredi valida os campos antes de chamar a lupa
	if ($('#flgsicre','#frmAutori').val() == 'S') { 
		if ($('#flgmanua','#frmAutori').val() == 'S') { 
			if ($('#fatura01','#frmAutori').val() == '') {
				$('#fatura01','#frmAutori').habilitaCampo();
				showError('error','Fatura não informada.','Alerta - AUTORI','$(\'fatura01\',\'frmAutori\');focaCampoErro(\'fatura01\',\'frmAutori\');');
				valida = 1;
				return false;
			}	

			if ($('#fatura02','#frmAutori').val() == '') {
				$('#fatura02','#frmAutori').habilitaCampo();
				showError('error','Fatura não informada.','Alerta - AUTORI','$(\'fatura02\',\'frmAutori\');focaCampoErro(\'fatura02\',\'frmAutori\');');
				valida = 1;
				return false;
			}
				
			if ($('#fatura03','#frmAutori').val() == '') {
				$('#fatura03','#frmAutori').habilitaCampo();
				showError('error','Fatura não informada.','Alerta - AUTORI','$(\'fatura03\',\'frmAutori\');focaCampoErro(\'fatura03\',\'frmAutori\');');
				valida = 1;
				return false;
			}
				
			if ($('#fatura04','#frmAutori').val() == '') {
				$('#fatura04','#frmAutori').habilitaCampo();
				showError('error','Fatura não informada.','Alerta - AUTORI','$(\'fatura04\',\'frmAutori\');focaCampoErro(\'fatura04\',\'frmAutori\');');
				valida = 1;
				return false;
			}
		}
	}
}

function consultaInicial() {
		
		
	// zera array	
	arrayAutori.length = 0;
	
	if ( divError.css('display') == 'block' ) { return false; }
	if( $('#nrdconta','#frmCabAutori').hasClass('campoTelaSemBorda') ){ return false; }
				
	// Armazena o número da conta na variável global e operacao
	nrdconta = normalizaNumero( $('#nrdconta','#frmCabAutori').val() );
	
	// Verifica se o número da conta é vazio
	if ( nrdconta == '' ) { return false; }
		
	// Verifica se a conta é válida
	if ( !validaNroConta(nrdconta) ) {
		showError('error','Conta/dv inválida.','Alerta - Autori','focaCampoErro(\'nrdconta\',\'frmCabAutori\');'); 
		return false; 
	}
	
	// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
	controlaOperacao( $('#opcao','#frmCabAutori').val() );
	
};	


// historico
function buscaHistorico() {


	if ($('#flgsicre','#frmAutori').val() == 'S'){
		bo 			= 'b1wgen0092.p';
		procedure	= 'busca-convenios';
		titulo      = 'Convênios';
		qtReg		= '30';
		filtrosPesq	= 'Cód. Hist;cdhistor;30px;N;0|Convênios;dshistor;200px;S;' + $('#dshistor','#frmAutori').val() + '|;flglanca;;;FALSE;N|;inautori;;;1;N';
		colunas 	= 'Código;cdhistor;20%;right|Histórico;dshistor;80%;left';
	}else{
		bo 			= 'b1wgen0059.p';
		procedure	= 'busca_historico';
		titulo      = 'Histórico';
		qtReg		= '30';
		filtrosPesq	= 'Cód. Hist;cdhistor;30px;S;0|Histórico;dshistor;200px;S;' + $('#dshistor','#frmAutori').val() + '|;flglanca;;;FALSE;N|;inautori;;;1;N';
		colunas 	= 'Código;cdhistor;20%;right|Histórico;dshistor;80%;left';
	}

	mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,'frmAutori','focusReferencia();');
	
} 

function validaHistorico(cddopcao) {


	hideMsgAguardo();
	showMsgAguardo( 'Aguarde, validando historico ...' );
	
	var cdhistor = normalizaNumero($('#cdhistor','#frmAutori').val());
	var dshistor = $('#dshistor','#frmAutori').val();
				   
	$.ajax({
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/autori/valida_historico.php',
			data: {
				nrdconta: nrdconta,
				nrseqdig: nrseqdig,
				operacao: operacao,
				cdhistor: cdhistor,
				dshistor: dshistor,
				cddopcao: cddopcao,
				redirect: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
	
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			},
			success: function(response) {
				try {
	
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		});
	return false;
}

function calculoDigito(operacao, nomcampo) {


	hideMsgAguardo();
	showMsgAguardo( 'Aguarde, validando dados ...' );

	var cdrefere = normalizaNumero($('#cdrefere','#frmAutori').val() );
	var flgmanua = $('#flgmanua','#frmAutori').val();
	if (flgmanua == 'S') {
		var fatura01 = $('#fatura01','#frmAutori').val();
		var fatura02 = $('#fatura02','#frmAutori').val();
		var fatura03 = $('#fatura03','#frmAutori').val();
		var fatura04 = $('#fatura04','#frmAutori').val();
	} else {
		var codbarra = normalizaNumero($('#codbarra','#frmAutori').val());
	}
	
	$.ajax({
			type  : 'POST',
			async : false ,
			url   : UrlSite + 'telas/autori/calcula_digito.php',
			data: {
				operacao: operacao,
				codbarra: codbarra,
				cdrefere: cdrefere,
				fatura01: fatura01,
				fatura02: fatura02,
				fatura03: fatura03,
				fatura04: fatura04,
				flgmanua: flgmanua,
				nomcampo: nomcampo,
				redirect: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
					
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		});
	return false;
}

function ValidaContaSicredi() {


	hideMsgAguardo();
	showMsgAguardo( 'Aguarde, validando conta ...' );

	$.ajax({
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/autori/valida_conta_sicredi.php',
			data: {
				nrdconta: nrdconta,
				operacao: operacao,
				redirect: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		});
	return false;
}

function gerarContaSicredi () {
	
	controlaOperacao('GC');
}

function showConfirma(){
	
	controlaOperacao('E3');
}

function focusReferencia() {
	
	$('#cdrefere','#frmAutori').habilitaCampo();
	$('#cdrefere','#frmAutori').focus(); 
}

function voltarAtenda() {
	
	setaParametros ('ATENDA', '', nrdconta, flgcadas);
	setaATENDA();
	direcionaTela('ATENDA','no');
}

// senha
function mostraSenha() {
	
	hideMsgAguardo();		
	
	showMsgAguardo('Aguarde, abrindo ...');
	
	cddopcao = 'C';
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/autori/senha.php', 
		data: {
			cddopcao: cddopcao,
			redirect: 'html_ajax'
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			return false;
		}				
	});
	
	return false;
	
}

function buscaSenha() {
	

	hideMsgAguardo();		
	
	showMsgAguardo('Aguarde, abrindo ...');
	
	cddopcao = 'C';
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/autori/form_senha.php', 
		data: {
			cddopcao: cddopcao,
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
			
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudoSenha').html(response);
					exibeRotina($('#divRotina'));
					formataSenha();
					$('#cddsenha','#frmSenha').unbind('keydown').bind('keydown', function(e) { 	
						if ( divError.css('display') == 'block' ) { return false; }		
						// Se é a tecla ENTER, 
						if ( e.keyCode == 13 ) {
							validarSenha();
							return false;			
						} 
					});
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

function formataSenha() {
	

	highlightObjFocus($('#frmSenha'));

	rSenha = $('label[for="cddsenha"]', '#frmSenha');
	rSenha.addClass('rotulo').css({'width':'165px'});

	cSenha = $('#cddsenha', '#frmSenha');
    cSenha.addClass('campo').css({'width':'100px'}).focus();
	
	cSenha.val('');
	
	$('#divConteudoSenha').css({'width':'400px', 'height':'120px'});

	// centraliza a divRotina
	$('#divRotina').css({'width':'425px'});
	$('#divConteudo').css({'width':'400px'});	
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}
		 
function validarSenha() {
	
		
	hideMsgAguardo();
	flginassele = 0;
	
	var cddsenha 	= $('#cddsenha','#frmSenha').val();	
	
	showMsgAguardo( 'Aguarde, validando dados ...' );	

	$.ajax({		
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/autori/valida_senha.php', 
			data: {
				operacao : operacao,
				cddsenha : cddsenha,
				nrdconta : nrdconta,
				redirect : 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
			},
			success: function(response) {
				try {
					flginassele = 1; // Deve validar senha
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				}
			}
		});	
		
	return false;	
	
}

function AtualizaInassele(inassele) {
	
		
	hideMsgAguardo();		
	
	var cdrefere = $('#cdrefere','#frmAutori').val();
	var cdhistor = normalizaNumero($('#cdhistor','#frmAutori').val());
	var flgsicre = $('#flgsicre','#frmAutori').val();
	cddopcao = 'C';
	
	if (flgsicre == 'S') {
		cdhistor = 1019;
	}
	
	showMsgAguardo( 'Aguarde, validando dados ...' );	

	$.ajax({		
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/autori/atualiza_inassele.php', 		
			data: {
				cdrefere : cdrefere,
				cdhistor : cdhistor,
				inassele : inassele,
				nrdconta : nrdconta,
				redirect	: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
			},
			success: function(response) {
				try {
					showError('inform','Autoriza&ccedil;&atilde;o processada com sucesso.','Alerta - Ayllos','controlaOperacao("");');
					//eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				}
			}
		});	
		
	return false;	
	
}

function mensagem(tipo){
	
	
	var operacao_aux = '';
	
	switch (operacao) {
		case 'R5': operacao_aux = 'R6'; break;
		case 'E5': operacao_aux = 'E6'; break;
		case 'I4': operacao_aux = 'I5'; break;
	}
	
	if(tipo == 1){
		showConfirmacao("Deseja realmente cancelar a senha?","Confirma&ccedil;&atilde;o - Ayllos","mensagem('2');","mostraSenha();","sim.gif","nao.gif");
	}else if(tipo == 2){
		showConfirmacao("Deseja continuar com a autoriza&ccedil;&atilde;o assinada?","Confirma&ccedil;&atilde;o - Ayllos","mensagem('3');","mensagem('4');","sim.gif","nao.gif");
	} else if (tipo == 4) {
	    if (operacao == 'E5') {
	        showError('inform', 'Cancelamento/exclus&atilde;o n&atilde;o realizado!', 'Alerta - Ayllos', 'controlaOperacao("");');
	    } else {
	        showError('inform', 'Opera&ccedil;&atilde;o cancelada!', 'Alerta - Ayllos', 'controlaOperacao("");');
	    }		
	}else if(tipo == 3){
		flginassele = 2; // atualizar o campo inassele para 2
		showError('inform','Requisite a assinatura do cooperado.','Alerta - Ayllos','controlaOperacao("' + operacao_aux + '");');
	}
}

function btCancelar(){
	
	mensagem(1); //cancelar
}