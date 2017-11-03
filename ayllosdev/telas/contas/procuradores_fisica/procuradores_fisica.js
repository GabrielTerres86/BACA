/*
 * FONTE        : procuradores_fisica.js
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 16/09/2010 
 * OBJETIVO     : Biblioteca de funções na rotina Representates/Procuradores (Pessoa Física) da tela de CONTAS
 * ALTERAÇÃO    : Adicionado pesquisa CEP. ( Rodolpho/Rogérius. (DB1) ).
 *                06/02/2012 - Ajuste para não chamar 2 vezes a função mostraPesquisa (Tiago).
 * 				  23/04/2012 - Ajustes GP - Socios Menores (Adrinao).
 *				  04/07/2013 - Inclusão das opções refentes aos poderes (Jean Michel).
 *				  25/09/2013 - Alteração da função de salvar poderes (Jean Michel).
 *                03/09/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *                25/04/2017 - Alterado campo dsnacion para cdnacion. (Projeto 339 - Odirlei-AMcom) 
*				  25/08/2016 - Inclusao da validaResponsaveis e alteração da controlaOperacaoPoderes, SD 510426(Jean Michel).
 *				  01/12/2016 - Retirada da function validaResponsaveis, SD.564025 (Jean Michel).		                         
 *				  18/10/2017 - Removendo caixa postal. (PRJ339 - Kelvin)
 */

var nrcpfcgc = '';
var nrdctato = '';
var nrdrowid = '';
var cddopcao = 'C';
var cpfaux 	 = '';
var indarray = '';
var operacao = '';
var nomeFormProcuradores = 'frmDadosProcuradores';
var arrayBens =  new Array();
var maxBens = 6;
var auxrowid = '';
var auxind = '';
var cpfPoderes = 0;
var flgPoderes = false;

var flgassco = false;

var flgpoderC1 = false;
var flgpoderI1 = false;
var flgpoderC2 = false;
var flgpoderI2 = false;
var flgpoderC3 = false;
var flgpoderI3 = false;
var flgpoderC4 = false;
var flgpoderI4 = false;
var flgpoderC5 = false;
var flgpoderI5 = false;
var flgpoderC6 = false;
var flgpoderI6 = false;
var flgpoderC7 = false;
var flgpoderI7 = false;
var flgpoderC8 = false;
var flgpoderI8 = false;
var flgpoderC9 = false;
var flgpoderI9 = false;

function controlaOperacaoProcuradores( operacao ){
	
	if ( operacao != 'EV' && operacao !='EC' && !verificaContadorSelect() ) return false;
	
	// Se não possui acesso para alterar, emitir mensagem	
	if ( (operacao == 'TC') && (flgConsultar != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de consulta.'               ,'Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TA') && (flgAlterar   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ctilde;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }	
	if ( (operacao == 'TI') && (flgIncluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de inclus&atilde;o.'        ,'Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TX') && (flgExcluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de exclux&atilde;o.'        ,'Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TP') && (flgPoderes	 != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de poderes.'        		  ,'Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
	
	if ( in_array(operacao,['TC','TA','TX','TP']) ) {
		nrcpfcgc 	= '';
		nrdctato 	= '';
		nrdrowid 	= '';
		
		$('table > tbody > tr', 'div.divRegistrosProcuradores').each( function() {
			if ( $(this).hasClass('corSelecao') || normalizaNumero(cpfPoderes) == $('input[name="nrcpfcgc"]', $(this) ).val() ) {
				nrcpfcgc = $('input[name="nrcpfcgc"]', $(this) ).val();
				nrdctato = $('input[name="nrdctato"]', $(this) ).val();
				nrdrowid = $('input[name="nrdrowid"]', $(this) ).val();
				auxrowid = nrdrowid;
			}
		});	
				
		if ( nrcpfcgc == '' && nrdctato == '' ) { return false; }
	}
	
	var msgOperacao = '';		
	switch (operacao) {
		// Consulta tabela para consulta formulário
		case 'TC':
			msgOperacao = 'Aguarde, abrindo formulário ...';
			operacao 	= 'CF'; //consulta formulario
			cddopcao    = 'C';	
			break;			
		// Consulta formulário para consulta tabela
		case 'CT': 
		case 'CTP':
			msgOperacao = 'Aguarde, abrindo tabela ...';
			flgPoderes  = (operacao == 'CTP');
			operacao 	= 'CT';	//consulta tabela
			nrcpfcgc 	= '';
			nrdctato 	= '';
			nrdrowid 	= '';
			cddopcao    = 'C';	
			break;				
		// Consulta tabela para alteração
		case 'TA': 
			msgOperacao = 'Aguarde, abrindo formulário ...';
			operacao 	= 'A';
			cddopcao    = 'A';
			break;
		
		// Tabela consulta para inclusão Poder		
		case 'TP':
			msgOperacao = 'Aguarde, abrindo formulário ...';
			operacao 	= 'P';
			cddopcao    = 'P';
			flgPoderes  = false;
			break;		
		// Alteração para consulta tabela 	
		case 'AT': 
			showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacaoProcuradores()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
		// Formulario em modo inclusão para tabela consulta		
		case 'IT': 
           showConfirmacao('Deseja cancelar inclus&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacaoProcuradores()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
            break;	
		// Tabela consulta para inclusão		
		case 'TI':
			msgOperacao = 'Aguarde, abrindo formulário ...';
			operacao 	= 'I'; 
			nrcpfcgc 	= '';
			nrdctato 	= '';
			nrdrowid 	= '';
			cddopcao    = 'I';	
			break;
		// Formulario de inclução com os dados de retorno da busca por CONTA ou CPF	
		case 'TB':
			msgOperacao = 'Aguarde, abrindo formulário ...';
			operacao 	= 'IB'; 
			cddopcao    = 'I';	
			break;
		// Alteração para validação: Salvando alteração
		case 'AV': 
			manterRotinaProcuradores('VA');
			return false;
			break;
		// Formulario em modo inclusão para validação: Incluindo procurador	
		case 'IV':
			manterRotinaProcuradores('VI');
			return false;
			break;
		// Abre o form. consulta para formulario em modo exclusão	
		case 'TX': 
			msgOperacao = 'Aguarde, abrindo formulário ...';
			cddopcao    = 'E';			
			break;	
		// Tabela consulta para formulario em modo exclusão	
		case 'EV':
			manterRotinaProcuradores(operacao);
			return false;
            break;
		// Dados validados. Exclui dados. 
		case 'E':
			manterRotinaProcuradores(operacao);
			return false;
            break;
		// Dados validados. Altera dados. 
		case 'VA': 
			manterRotinaProcuradores('A');
			return false;
            break;
		//Dados validados. Inclui dados.	
		case 'VI': 
			manterRotinaProcuradores('I');
			return false;
            break;
		default:  
			acessaOpcaoAbaDados(6,2,'@');
			return false;
	}
	
	$('.divRegistrosProcuradores').remove();
	showMsgAguardo(msgOperacao);
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/procuradores_fisica/principal.php', 
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, nrcpfcgc: nrcpfcgc,
			nrdctato: nrdctato, nrdrowid: nrdrowid, cddopcao: cddopcao,
			operacao: operacao, redirect: 'script_ajax'			
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
				
				if (flgPoderes) {
					controlaOperacaoProcuradores('TP');
				}
				
			} else {
				eval( response );
				controlaFocoProcuradores( operacao );
			}
			return false;	
		}				
	});				
}

function manterRotinaProcuradores(operacao) {
	
	nrdctato = $('#nrdctato','#frmDadosProcuradores').val();
	nrdctato = normalizaNumero( nrdctato );
	
	//tratamento no campo conta e cpf para deixar parecido com o ambiente caracter	
	if (operacao == 'VI'){ 
		
		var campoConta = $('#nrdctato','#frmDadosProcuradores');
		var campoCpf   = $('#nrcpfcgc','#frmDadosProcuradores');
		
		if ( !campoConta.hasClass('campoTelaSemBorda') ){
			if ( nrdctato == 0 ) { 
				campoConta.removeClass("campoErro");
				campoConta.desabilitaCampo();
				campoCpf.habilitaCampo();
				campoCpf.focus();
				return false; 
			}else{
				// Verifica se a conta é válida
				if ( !validaNroConta(nrdctato) ) { 
					showError('error','Conta/dv inválida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrdctato\',\'frmDadosProcuradores\');'); return false; 
				}else{				
					// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
					nrcpfcgc = '';				
					nrdrowid = '';				
					showMsgAguardo('Aguarde, buscando dados do procurador...');					
					controlaOperacaoProcuradores('TB');
					return false;
				}	
			}
		}else{

			if ( !campoCpf.hasClass('campoTelaSemBorda') ){
				cpf = campoCpf.val();
				cpf = normalizaNumero( cpf );
				if ( !validaCpfCnpj(cpf,1) ) { 
					showError('error','CPF inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrcpfcgc\',\'frmDadosProcuradores\');'); return false; 
				}else{
					// Se chegou até aqui, a CPF é diferente do vazio e é válido, então realizar a operação desejada
					cpfaux 		= cpf;	
					nrcpfcgc 	= cpf;
					nrdctato 	= 0;
					nrdrowid 	= '';
					showMsgAguardo('Aguarde, buscando dados do procurador...');
					controlaOperacaoProcuradores('TB');
					return false;
				}
			}
		}
		}
	
	hideMsgAguardo();		
	var msgOperacao = '';
	switch (operacao) {	
		
		case 'A' : msgOperacao = 'Aguarde, alterando ...';           break;
		case 'I' : msgOperacao = 'Aguarde, incluindo ...';           break;
		case 'VA': msgOperacao = 'Aguarde, validando alteração ...'; break;
		case 'VI': msgOperacao = 'Aguarde, validando inclusão ...';  break;			
		case 'EV': msgOperacao = 'Aguarde, validando exclusão ...';  break;				
		case 'E' : msgOperacao = 'Aguarde, excluindo ...'; 			 break;
		
		default: return false; break;
		
	}
	showMsgAguardo( msgOperacao );
	
	// Recebendo valores do formulário
	nrcpfcgc = $('#nrcpfcgc','#frmDadosProcuradores').val();
	
	cdoeddoc = $('#cdoeddoc','#frmDadosProcuradores').val(); 
	dtnascto = $('#dtnascto','#frmDadosProcuradores').val(); 
	dtemddoc = $('#dtemddoc','#frmDadosProcuradores').val(); 
	nmdavali = $('#nmdavali','#frmDadosProcuradores').val(); 
	nrdocava = $('#nrdocava','#frmDadosProcuradores').val(); 
	cdnacion = $('#cdnacion','#frmDadosProcuradores').val(); 
	dsnatura = $('#dsnatura','#frmDadosProcuradores').val(); 
	complend = $('#complend','#frmDadosProcuradores').val(); 
	nmcidade = $('#nmcidade','#frmDadosProcuradores').val(); 
	nmbairro = $('#nmbairro','#frmDadosProcuradores').val(); 
	dsendres = $('#dsendres','#frmDadosProcuradores').val(); 
	nmpaicto = $('#nmpaicto','#frmDadosProcuradores').val(); 
	nmmaecto = $('#nmmaecto','#frmDadosProcuradores').val(); 
	nrendere = $('#nrendere','#frmDadosProcuradores').val(); 
	nrcepend = $('#nrcepend','#frmDadosProcuradores').val(); 
	dsrelbem = $('#dsrelbem','#frmDadosProcuradores').val(); 
	dtvalida = $('#dtvalida','#frmDadosProcuradores').val(); 
	vledvmto = $('#vledvmto','#frmDadosProcuradores').val();	
	dthabmen = $('#dthabmen','#frmDadosProcuradores').val();
	inhabmen = $('#inhabmen','#frmDadosProcuradores').val();
		
	tpdocava = $('#tpdocava > option:selected','#frmDadosProcuradores').val(); 
	cdufddoc = $('#cdufddoc > option:selected','#frmDadosProcuradores').val();
	cdestcvl = $('#cdestcvl > option:selected','#frmDadosProcuradores').val();
	cdufresd = $('#cdufresd > option:selected','#frmDadosProcuradores').val();
		
	nrcpfcgc = normalizaNumero( nrcpfcgc );
	nrendere = normalizaNumero( nrendere );
	nrcepend = normalizaNumero( nrcepend );
	
	cdoeddoc = trim( cdoeddoc );
	nmdavali = trim( nmdavali );
	nrdocava = trim( nrdocava );
	cdnacion = trim( cdnacion );
	dsnatura = trim( dsnatura );
	complend = trim( complend );
	nmcidade = trim( nmcidade );
	nmbairro = trim( nmbairro );
	dsendres = trim( dsendres );
	nmpaicto = trim( nmpaicto );
	nmmaecto = trim( nmmaecto );
	
	var camposXML = '';
	camposXML = retornaCampos( arrayBens, '|' );
		
	var dadosXML = '';
	dadosXML = retornaValores( arrayBens, ';', '|', camposXML );
							
	// Tratamento para os radio do sexo
	var sexoMas = $('#sexoMas','#frmDadosProcuradores').prop('checked');
	var sexoFem = $('#sexoFem','#frmDadosProcuradores').prop('checked');	
	var cdsexcto = (sexoMas) ? '1' : '0';
	cdsexcto = (sexoFem) ? '2' : cdsexcto;
	
			
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/procuradores_fisica/manter_rotina.php', 		
		data: {			
			nrcpfcgc: nrcpfcgc,	cdoeddoc: cdoeddoc,	dtnascto: dtnascto, 
			dtemddoc: dtemddoc,	nrdctato: nrdctato, nmdavali: nmdavali,	
			cdufddoc: cdufddoc, tpdocava: tpdocava, nrdocava: nrdocava,	
			cdestcvl: cdestcvl,	cdnacion: cdnacion, dsnatura: dsnatura,	
			complend: complend, nmcidade: nmcidade, nmbairro: nmbairro,	
			dsendres: dsendres,	nmpaicto: nmpaicto, nmmaecto: nmmaecto,	
			nrendere: nrendere,	nrcepend: nrcepend, dsrelbem: dsrelbem,	
			dtvalida: dtvalida, vledvmto: vledvmto,	cdsexcto: cdsexcto,	
			cdufresd: cdufresd, nrdconta: nrdconta, idseqttl: idseqttl, 
			nrdrowid: nrdrowid, dthabmen: dthabmen, inhabmen: inhabmen, 
			dadosXML: dadosXML, camposXML: camposXML,
			operacao: operacao, 
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
			}
		}				
	});
}

function estadoInicialProcuradores() {

	var cNrConta		= $('#nrdctato','#frmDadosProcuradores');
	var cCPF			= $('#nrcpfcgc','#frmDadosProcuradores');
	var camposGrupo2	= $('#nmdavali,#dtnascto,#tpdocava,#cdufddoc,#dthabmen,#inhabmen,#cdestcvl,#nrdocava,#cdoeddoc,#cdufresd,#dtemddoc,#cdnacion,#dsnatura,#dsendres,#nrendere,#complend,#nmbairro,#nrcepend,#nmcidade,#nmmaecto,#nmpaicto,#vledvmto','#frmDadosProcuradores');
	var camposGrupo3	= $('#dtvalida','#frmDadosProcuradores');		
	var sexo			= $('input[name="cdsexcto"]');	
	var cDescBem		= $('#dsrelbem','#frmDadosProcuradores');
    var cDsnacion		= $('#dsnacion','#frmDadosProcuradores');
	
	$("input,select","#frmDadosProcuradores").removeClass("campoErro");
	$('#frmDadosProcuradores').limpaFormulario();
	cNrConta.habilitaCampo();
	cCPF.desabilitaCampo();
	camposGrupo2.desabilitaCampo();
	camposGrupo3.desabilitaCampo();
	sexo.desabilitaCampo();	
	cDescBem.desabilitaCampo();
    cDsnacion.desabilitaCampo();
	removeOpacidade('divConteudoOpcao');	
	cNrConta.focus();
	
}

function controlaLayoutProcuradores( operacao ) {
	
	altura  = "0";
	largura = "0";
	
	if(operacao == 'CT'){		
		altura 	= '205px';
		largura = '600px';
	}else if(operacao == 'P'){
		altura 	= '380px';
		largura = '570px';
	}else{
		altura 	= '430px';
		largura = '548px';
	}
	
	if ( in_array(operacao,['I','A','TX','CF','P']) ) {
		$('#divConteudoOpcao').css('height',altura);
	}
	
	divRotina.css('width',largura);			
	
	if ( operacao == 'CT' ) {
		
		var divRegistro = $('div.divRegistrosProcuradores');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
		
		divRegistro.css('height','60px');
		
		var ordemInicial = new Array();
		ordemInicial = [[0,0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '90px';
		arrayLargura[1] = '155px';
		arrayLargura[2] = '110px';
		arrayLargura[3] = '80px';
		arrayLargura[4] = '60px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'center';
				
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacaoProcuradores(\'TC\');' );
		
		$('.divRegistrosProcuradores > table > thead').remove();
		
		if ( in_array(operacao,['CT','AT']) ) {
			SelecionaItem('nrdrowid',tabela,auxrowid);
		}
		
	} else {
		
	// FIELDSET IDENTIFICAÇÃO
		var cNrConta		= $('#nrdctato','#frmDadosProcuradores');
		var cCPF			= $('#nrcpfcgc','#frmDadosProcuradores');
		var cNomeProcurador	= $('#nmdavali','#frmDadosProcuradores');
		var cDtNascimento	= $('#dtnascto','#frmDadosProcuradores');	
		var cDthabmen		= $('#dthabmen','#frmDadosProcuradores');
		var cInhabmen		= $('#inhabmen','#frmDadosProcuradores');
		var cTpDocumento	= $('#tpdocava','#frmDadosProcuradores');
		var cDocumento		= $('#nrdocava','#frmDadosProcuradores');
		var cOrgEmissor		= $('#cdoeddoc','#frmDadosProcuradores');	
		var cEstados		= $('#cdufddoc','#frmDadosProcuradores');	
		var cDataEmissao	= $('#dtemddoc','#frmDadosProcuradores');
		var cEstadoCivil	= $('#cdestcvl','#frmDadosProcuradores');
		var cNacionalidade	= $('#dsnacion','#frmDadosProcuradores');
        var cCodnacionali	= $('#cdnacion','#frmDadosProcuradores');
		var cNaturalidade	= $('#dsnatura','#frmDadosProcuradores');
		
		cNrConta.css('width','70px').addClass('conta pesquisa');
		cCPF.css('width','90px').addClass('cpf');
		cNomeProcurador.css('width','300px').addClass('alphanum').attr('maxlength','40');
		cDtNascimento.css('width','70px').addClass('data');		
		cDthabmen.css('width','70px').addClass('data');
		cInhabmen.css('width','256px');
		cTpDocumento.css('width','40px');
		cDocumento.addClass('alphanum').css('width','84px').attr('maxlength','15');
		cOrgEmissor.addClass('alphanum').css('width','45px').attr('maxlength','5');
		cEstados.css('width','45px');
		cDataEmissao.addClass('data').css('width','70px');
		cEstadoCivil.css('width','300px');
		cNacionalidade.css('width','140px');
        cCodnacionali.css('width','65px');
		cNaturalidade.css('width','185px');
		
		// FIELDSET ENDEREÇO
		// rotulo endereco
		var rCep		= $('label[for="nrcepend"]','#'+nomeFormProcuradores);
		var rEnd		= $('label[for="dsendres"]','#'+nomeFormProcuradores);
		var rNum		= $('label[for="nrendere"]','#'+nomeFormProcuradores);
		var rCom		= $('label[for="complend"]','#'+nomeFormProcuradores);
		var rBai		= $('label[for="nmbairro"]','#'+nomeFormProcuradores);
		var rEst		= $('label[for="cdufresd"]','#'+nomeFormProcuradores);	
		var rCid		= $('label[for="nmcidade"]','#'+nomeFormProcuradores);

		rCep.addClass('rotulo').css('width','70px');
		rEnd.addClass('rotulo-linha').css('width','35px');
		rNum.addClass('rotulo').css('width','70px');
		rCom.addClass('rotulo-linha').css('width','52px');
		rEst.addClass('rotulo').css('width','70px');
		rBai.addClass('rotulo-linha').css('width','52px');
		rCid.addClass('rotulo').css('width','70');
		
		// campo endereco
		var cCep		= $('#nrcepend','#'+nomeFormProcuradores);
		var cEnd		= $('#dsendres','#'+nomeFormProcuradores);
		var cNum		= $('#nrendere','#'+nomeFormProcuradores);
		var cCom		= $('#complend','#'+nomeFormProcuradores);
		var cBai		= $('#nmbairro','#'+nomeFormProcuradores);
		var cEst		= $('#cdufresd','#'+nomeFormProcuradores);	
		var cCid		= $('#nmcidade','#'+nomeFormProcuradores);

		cCep.addClass('cep pesquisa').css('width','65px').attr('maxlength','9');
		cEnd.addClass('alphanum').css('width','306px').attr('maxlength','40');
		cNum.addClass('numerocasa').css('width','65px').attr('maxlength','7');
		cCom.addClass('alphanum').css('width','306px').attr('maxlength','40');	
		cEst.css('width','65px');	
		cBai.addClass('alphanum').css('width','306px').attr('maxlength','40');	
		cCid.addClass('alphanum').css('width','429px').attr('maxlength','25');

		var endDesabilita = $('#dsendres,#cdufresd,#nmbairro,#nmcidade','#'+nomeFormProcuradores);
		
		// ie
		if ( $.browser.msie ) {	
			cEnd.addClass('alphanum').css('width','309px');
			cCom.addClass('alphanum').css('width','309px');	
			cBai.addClass('alphanum').css('width','309px');	
			cCid.addClass('alphanum').css('width','309px');
		}
		
		// FIELDSET FILIAÇÃO	
		$('#nmpaicto,#nmmaecto','#frmDadosProcuradores').css('width','429px').addClass('alphanum').attr('maxlength','40');
		
		// FIELDSET OPERAÇÃO	
		var cDescBem		= $('#dsrelbem','#frmDadosProcuradores');
		var cEndividamento  = $('#vledvmto','#frmDadosProcuradores');
		var cDtVigencia  	= $('#dtvalida','#frmDadosProcuradores');
				
		cDescBem.css('width','170px').addClass('alphanum');
		cEndividamento.css('width','104px');
		cDtVigencia.css('width','64px');
		
		// CONTROLA LARGURA PARA FORMULÁRIO DE BENS
		$('label','#frmProcBens').css({'width':'195px'}).addClass('rotulo');
		$('#dsrelbem','#frmProcBens').css({'width':'275px'});
		$('#persemon,#qtprebem','#frmProcBens').css({'width':'40px'});			
		
		// INICIA CONTROLE DA TELA
		var camposGrupo2  = $('#nmdavali,#dtnascto,#tpdocava,#cdufddoc,#dthabmen,#inhabmen,#cdestcvl,#nrdocava,#cdoeddoc,#cdufresd,#dtemddoc,#cdnacion,#dsnacion,#dsnatura,#dsendres,#nrendere,#complend,#nmbairro,#nrcepend,#nmcidade,#nmmaecto,#nmpaicto,#vledvmto','#frmDadosProcuradores');
		var camposGrupo3  = $('#dtvalida','#frmDadosProcuradores');		
		var sexo 		  = $('input[name="cdsexcto"]');

		// Sempre inicia com tudo bloqueado
		cNrConta.desabilitaCampo();
		cCPF.desabilitaCampo();
		camposGrupo2.desabilitaCampo();
		camposGrupo3.desabilitaCampo();
		sexo.desabilitaCampo();	
		cDescBem.desabilitaCampo();	
		
		switch (operacao) {
			
			// Caso é inclusão, limpar dados do formulário					
			case 'I': 
				$('#frmDadosProcuradores').limpaFormulario();
				montaSelect('b1wgen0059.p','busca_estado_civil','cdestcvl','cdestcvl','cdestcvl;dsestcvl','');				
				cNrConta.habilitaCampo();
				break;
				
			//Caso é inclusão, apos a busca de dados pela conta ou pelo CPF 
			case 'IB':
				//Se o nº da conta for igual a 0 ou vazio então o formulario é desbloqueado para preenchimento 
				if ( cNrConta.val() == '0' || cNrConta.val() == '' ){
					camposGrupo2.habilitaCampo();
					sexo.habilitaCampo();	
					cDescBem.habilitaCampo();			
					cDescBem.prop('disabled',true);
					endDesabilita.desabilitaCampo();	
		
					if( $('#cdestcvl','#'+nomeFormProcuradores).val() == "2" ||
						$('#cdestcvl','#'+nomeFormProcuradores).val() == "3" ||
						$('#cdestcvl','#'+nomeFormProcuradores).val() == "4" || 
						$('#cdestcvl','#'+nomeFormProcuradores).val() == "8" || 
						$('#cdestcvl','#'+nomeFormProcuradores).val() == "9" || 
						$('#cdestcvl','#'+nomeFormProcuradores).val() == "11" ){
					
						$('#inhabmen','#'+nomeFormProcuradores).desabilitaCampo();
						$('#dthabmen','#'+nomeFormProcuradores).desabilitaCampo();
			
					}else{			
					
						( $('#inhabmen','#'+nomeFormProcuradores).val() != 1 ) ? $('#dthabmen','#'+nomeFormProcuradores).desabilitaCampo() : $('#dthabmen','#'+nomeFormProcuradores).habilitaCampo();
						
					}
					
				}
				camposGrupo3.habilitaCampo();
				break;
				
			// Caso é alteração, se conta = 0, libera grupo 2 e 3, senão libera somente grupo 3 	
			case 'A': 
				if ( nrdctato == 0 ) {
					camposGrupo2.habilitaCampo();
					sexo.habilitaCampo();
					camposGrupo3.habilitaCampo();
					cDescBem.habilitaCampo();			
					cDescBem.prop('disabled',true);
					endDesabilita.desabilitaCampo();	

					if( $('#cdestcvl','#'+nomeFormProcuradores).val() == "2" ||
						$('#cdestcvl','#'+nomeFormProcuradores).val() == "3" ||
						$('#cdestcvl','#'+nomeFormProcuradores).val() == "4" || 
						$('#cdestcvl','#'+nomeFormProcuradores).val() == "8" || 
						$('#cdestcvl','#'+nomeFormProcuradores).val() == "9" || 
						$('#cdestcvl','#'+nomeFormProcuradores).val() == "11" ){
					
						$('#inhabmen','#'+nomeFormProcuradores).desabilitaCampo();
						$('#dthabmen','#'+nomeFormProcuradores).desabilitaCampo();
			
					}else{			
					
						( $('#inhabmen','#'+nomeFormProcuradores).val() != 1 ) ? $('#dthabmen','#'+nomeFormProcuradores).desabilitaCampo() : $('#dthabmen','#'+nomeFormProcuradores).habilitaCampo();
						
					}
					
				} else {
					camposGrupo3.habilitaCampo();
				}
				break;
				
			// Caso é exclusão, lista o formulário e bloqueia todos os campos
			case 'FX': 
				cNrConta.desabilitaCampo();
				cCPF.desabilitaCampo();
				camposGrupo2.desabilitaCampo();
				sexo.desabilitaCampo();
				camposGrupo3.desabilitaCampo();
				break;	
			
			default: 
				cDescBem.desabilitaCampo(); 
				break;
		}	
		
		// Ao dar foco no bens já abre janela
		cDescBem.unbind('focusin').bind('focusin', function() {
			auxind = '';
			mostraTabelaBens('BT');
			//cDtVigencia.focus();
		});
	
		// Se operação é diferente de "I" monto os setects usados na tela
		if ( operacao != 'I' ) {
			montaSelect('b1wgen0059.p','busca_estado_civil','cdestcvl','cdestcvl','cdestcvl;dsestcvl',estadoCivil);				
		}

		// Controle do número da conta
		cNrConta.unbind('keydown').bind('keydown', function(e){ 	
		
			if ( divError.css('display') == 'block' ) { return false; }		
			
			// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
			if ( e.keyCode == 13 ) {		
				
				// Armazena o número da conta na variável global
				nrdctato = normalizaNumero( $(this).val() );
			
				// Verifica se o número da conta é vazio
				if ( nrdctato == 0 ) { 
					$(this).removeClass("campoErro");
					$(this).desabilitaCampo();
					cCPF.habilitaCampo();
					cCPF.focus();
					return false; 
				}
					
				// Verifica se a conta é válida
				if ( !validaNroConta(nrdctato) ) { showError('error','Conta/dv inválida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrdctato\',\'frmDadosProcuradores\');'); return false; }
				
				// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
				nrcpfcgc = '';				
				nrdrowid = '';				
				showMsgAguardo('Aguarde, buscando dados do procurador...');					
				controlaOperacaoProcuradores('TB');
			} 
		});	

		// Controle no CPF
		cCPF.unbind('keydown').bind('keydown', function(e){ 	
		
			if ( divError.css('display') == 'block' ) { return false; }		
			
			// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
			if ( e.keyCode == 13 ) {		
				
				// Armazena o número da conta na variável global
				cpf = normalizaNumero( $(this).val() );
			
				// Verifica se o número da conta é vazio
				if ( cpf == 0 ) { return false; }
					
				// Verifica se a conta é válida
				if ( !validaCpfCnpj(cpf ,1) ) { showError('error','CPF inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrcpfcgc\',\'frmDadosProcuradores\');'); return false; }
				
				// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
				cpfaux 		= cpf;	
				nrcpfcgc 	= cpf;
				nrdctato 	= 0;
				nrdrowid 	= '';
				showMsgAguardo('Aguarde, buscando dados do procurador...');
				controlaOperacaoProcuradores('TB');
			} 
		});		

		$('#inhabmen','#'+nomeFormProcuradores).unbind('change').bind('change', function() {
		
			if( $(this).val() != 1 ){
				$('#dthabmen','#'+nomeFormProcuradores).desabilitaCampo();
				$('#dthabmen','#'+nomeFormProcuradores).val('');
				cEstadoCivil.focus();
				
			}else{
				$('#dthabmen','#'+nomeFormProcuradores).habilitaCampo();
			}
							
		});
		
			
		$('#dthabmen','#'+nomeFormProcuradores).unbind('change').bind('change',function() {
					
			//Quando estado civil for "Casado" e idade for menor que 18 anos, a pessoa passa automaticamente a ser emancipada.
			if(($(this).val() == "2"                   ||
				$(this).val() == "3"            	   ||
				$(this).val() == "4"    			   || 
				$(this).val() == "8"    			   || 
				$(this).val() == "9"    			   || 
				$(this).val() == "11" ) 			   &&
				$('#inhabmen','#'+nomeFormProcuradores).val() == 0){
							
				$('#inhabmen','#'+nomeFormProcuradores).val(1).habilitaCampo();
				cDthabmen.val(dtmvtolt).habilitaCampo();

			}else{
				$('#inhabmen','#'+nomeFormProcuradores).habilitaCampo();
				cDthabmen.habilitaCampo();
				 
			}
											
		});
		
		cEstadoCivil.unbind('keydown').bind('keydown', function(e){
			
			if(e.keyCode == 13){
		
				//Quando estado civil for "Casado" e idade for menor que 18 anos, a pessoa passa automaticamente a ser emancipada.
				if(($(this).val() == "2"    ||
					$(this).val() == "3"    ||
					$(this).val() == "4"    || 
					$(this).val() == "8"    || 
					$(this).val() == "9"    || 
					$(this).val() == "11" )) {
				
					$('#inhabmen','#'+nomeFormProcuradores).val(1).habilitaCampo();
					cDthabmen.val(dtmvtolt).habilitaCampo();
		
				}else{
					$('#inhabmen','#'+nomeFormProcuradores).habilitaCampo();
					cDthabmen.habilitaCampo();
				}
					
			
			}
			
		});
		
		cEstadoCivil.unbind('change').bind('change',function() {
					
			//Quando estado civil for "Casado" e idade for menor que 18 anos, a pessoa passa automaticamente a ser emancipada.
			if(($(this).val() == "2"                             ||
				$(this).val() == "3"                             ||
				$(this).val() == "4"                             || 
				$(this).val() == "8"                             || 
				$(this).val() == "9"                             || 
				$(this).val() == "11" )                          &&
				$('#inhabmen','#'+nomeFormProcuradores).val() == 0){
							
				$('#inhabmen','#'+nomeFormProcuradores).val(1).habilitaCampo();
				cDthabmen.val(dtmvtolt).habilitaCampo();

			}else{
				$('#inhabmen','#'+nomeFormProcuradores).habilitaCampo();
				cDthabmen.habilitaCampo();
				 
			}
												
		});
		
		cEstadoCivil.unbind('focusout').bind('focusout',function() {
					
			//Quando estado civil for "Casado" e idade for menor que 18 anos, a pessoa passa automaticamente a ser emancipada.
			if(($(this).val() == "2"                             ||
				$(this).val() == "3"                             ||
				$(this).val() == "4"                             || 
				$(this).val() == "8"                             || 
				$(this).val() == "9"                             || 
				$(this).val() == "11" )                          &&
				$('#inhabmen','#'+nomeFormProcuradores).val() == 0){
							
				$('#inhabmen','#'+nomeFormProcuradores).val(1).habilitaCampo();
				cDthabmen.val(dtmvtolt).habilitaCampo();

			}else{
				$('#inhabmen','#'+nomeFormProcuradores).habilitaCampo();
				cDthabmen.habilitaCampo();
				 
			}
											
		});
		
		cEndividamento.unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13) {
				cDtVigencia.focus();
				return false;
			}	
		});	
		
		cDtVigencia.unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});	
		
				
		layoutPadrao();
		controlaFocoEnter("frmDadosProcuradores");
		controlaPesquisasProcuradores();
		
	}
	
	$('#nrdctato','#frmDadosProcuradores').trigger('blur');
	$('#nrcpfcgc','#frmDadosProcuradores').trigger('blur');
	$('#nrendere','#frmDadosProcuradores').trigger('blur');
	$('#nrcepend','#frmDadosProcuradores').trigger('blur');
		
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	highlightObjFocus($('#frmDadosProcuradores'));
	
	controlaFocoProcuradores(operacao);
	divRotina.centralizaRotinaH();
	return false;	
}

function controlaFocoProcuradores(operacao) {

	if (in_array(operacao,['CT','',])) {
		$('#btAlterar','#divBotoes').focus();
	} else if ( operacao == 'CF' ) {
		$('#btVoltar','#divBotoes').focus();
	} else {
		$('.campo:first','#'+nomeFormProcuradores).focus();
	}
	return false;
}

function controlaPesquisasProcuradores() {

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas;
	var camposOrigem = 'nrcepend;dsendres;nrendere;complend;nrcxapst;nmbairro;cdufresd;nmcidade';	
	
	
	// Atribui a classe lupa para os links de desabilita todos
	var lupas = $('a:not(.lupaBens)','#frmDadosProcuradores');
	lupas.addClass('lupa').css('cursor','auto');	
	// Percorrendo todos os links
	lupas.each( function() {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');		
		
		$(this).unbind("click").bind("click",( function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {			
				// Obtenho o nome do campo anterior
				campoAnterior = $(this).prev().attr('name');		
				
				// Nr. Conta Procurador
				if ( campoAnterior == 'nrdctato' ) {
					mostraPesquisaAssociado('nrdctato','frmDadosProcuradores',divRotina);
					return false;					
				
				// Nacionalidade
				} else if ( campoAnterior == 'cdnacion' ) {
					bo			= 'b1wgen0059.p';
					procedure	= 'busca_nacionalidade';
					titulo      = 'Nacionalidade';
					qtReg		= '50';
					filtros 	= 'Codigo;cdnacion;30px;N;|Nacionalidade;dsnacion;200px;S;';
					colunas 	= 'Codigo;cdnacion;15%;left|Descrição;dsnacion;85%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;
				// Naturalidade
				} else if ( campoAnterior == 'dsnatura' ) {
					bo			= 'b1wgen0059.p';
					procedure	= 'Busca_Naturalidade';
					titulo      = 'Naturalidade';
					qtReg		= '50';
					filtros 	= 'Naturalidade;dsnatura;200px;S;';
					colunas 	= 'Naturalidade;dsnatura;100%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;
				
				// CEP	
				} else if ( campoAnterior == 'nrcepend' ) {
					mostraPesquisaEndereco(nomeFormProcuradores, camposOrigem, divRotina);
					return false;					
				} 		
			}
		}));
	});
	
	// Controle da lupaBens
	var lupaBens = $('.lupaBens','#frmDadosProcuradores');
	// Somente estará habilitada quando o campo "NOME" estiver habilitado
	if ( $('#nmdavali','#frmDadosProcuradores').hasClass('campoTelaSemBorda') ) {
		lupaBens.css('cursor','auto');
		lupaBens.click( function() { return false; } );
	} else {
		lupaBens.css('cursor','pointer');
		lupaBens.click( function() { auxind = '';mostraTabelaBens('BT'); return false; } );
	}
	
	// Cep
	$('#nrcepend','#'+nomeFormProcuradores).buscaCEP(nomeFormProcuradores, camposOrigem, divRotina);
	
    //  Nacionalidade
	$('#cdnacion','#'+nomeFormProcuradores).unbind('change').bind('change',function() {
		procedure	= 'BUSCAR_NACIONALIDADE';
		titulo      = ' Nacionalidade';
		filtrosDesc = '';
		buscaDescricao('CADA0001',procedure,titulo,$(this).attr('name'),'dsnacion',$(this).val(),'dsnacion',filtrosDesc,nomeFormProcuradores);        
	return false;
	}); 
	
	return false;
}

//Monta a div e mostra a tabela de descrição de bens
function mostraTabelaBens( operacao ) {

	showMsgAguardo('Aguarde, buscando bens...');
	
	exibeRotina($('#divUsoGenerico'));
	
	$('#tbbens').remove();
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/procuradores_fisica/bens.php', 
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
			controlaOperacaoBens(operacao);			
		}				
	});
	return false;
}

//Controla as operações da descrição de bens
function controlaOperacaoBens(operacao) {
	
	var msgOperacao = '';	
	if ( operacao == 'BF' || operacao == 'E' ) {
		indarray = '';
		$('table > tbody > tr', '#divProcBensTabela > div.divRegistrosProcuradores').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				indarray = $('input', $(this) ).val();
				auxind   = indarray;
			}
		});	
		if ( indarray == '' ) { return false; }
	}
	
	switch (operacao) {
		//Mostra o formulario de bens
		case 'BF':
			//Oculto a tabela e mostro o formulario
			$('#divProcBensFormulario').css('display','block');
			$('#divProcBensTabela').css('display','none');
			//Preencho o formulario com os dados do bem selecionado;
			$('input[name="dsrelbem"]','#divProcBensFormulario').val(arrayBens[indarray]['dsrelbem']);
			$('input[name="persemon"]','#divProcBensFormulario').val(arrayBens[indarray]['persemon']);
			$('input[name="qtprebem"]','#divProcBensFormulario').val(arrayBens[indarray]['qtprebem']);
			$('input[name="vlprebem"]','#divProcBensFormulario').val(arrayBens[indarray]['vlprebem']);
			$('input[name="vlrdobem"]','#divProcBensFormulario').val(arrayBens[indarray]['vlrdobem']);
			msgOperacao = 'abrindo bens';
			break;
		
		//Inclusão. Mostra formulario de bens vazio.	
		case 'BI':
			if ( arrayBens.length < maxBens ) {
				$('#divProcBensFormulario').css('display','block');
				$('#divProcBensTabela').css('display','none');
				msgOperacao = 'abrindo formulário de bens';
			}else{
				showError('error','Limite de cadastramento atingido','Alerta - Ayllos',"bloqueiaFundo($('#divUsoGenerico'));");				
				return false;
			}
			break;
		
		// Mostra a tabela de bens	
		case 'BT':
			// Oculto o formulario e mostro a tabela
			msgOperacao = 'abrindo tabela de bens';
			break;
		case 'BR':
			// Oculto o formulario e mostro a tabela
			showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','mostraTabelaBens(\'BT\')','bloqueiaFundo($(\'#divUsoGenerico\'))','sim.gif','nao.gif');
			return false;
			break;
		
		//Excluindo bem do Array	
		case 'E':
			showMsgAguardo('Aguarde, excluindo ...');	
			arrayBens.splice(indarray,1);
			mostraTabelaBens('BT');
			return false;
			break;
		
		//Salvando alterações do bem no Array	
		case 'AS':
			arrayBens[indarray]['dsrelbem'] = $('input[name="dsrelbem"]','#divProcBensFormulario').val();
			arrayBens[indarray]['persemon'] = $('input[name="persemon"]','#divProcBensFormulario').val();
			arrayBens[indarray]['qtprebem'] = $('input[name="qtprebem"]','#divProcBensFormulario').val();
			arrayBens[indarray]['vlprebem'] = $('input[name="vlprebem"]','#divProcBensFormulario').val();
			arrayBens[indarray]['vlrdobem'] = $('input[name="vlrdobem"]','#divProcBensFormulario').val();			
			mostraTabelaBens('BT');
			return false
			break;
		
		//Salvando inclusões do bem no Array		
		case 'IS':
			i = arrayBens.length;
			eval('var arrayBem'+i+' = new Object();');
			eval('arrayBem'+i+'["dsrelbem"] = $(\'input[name="dsrelbem"]\',\'#divProcBensFormulario\').val();');
			eval('arrayBem'+i+'["cdsequen"] = \'\';');
			eval('arrayBem'+i+'["persemon"] = $(\'input[name="persemon"]\',\'#divProcBensFormulario\').val();');
			eval('arrayBem'+i+'["qtprebem"] = $(\'input[name="qtprebem"]\',\'#divProcBensFormulario\').val();');
			eval('arrayBem'+i+'["vlprebem"] = $(\'input[name="vlprebem"]\',\'#divProcBensFormulario\').val();');
			eval('arrayBem'+i+'["vlrdobem"] = $(\'input[name="vlrdobem"]\',\'#divProcBensFormulario\').val();');			
			eval('arrayBens['+i+'] = arrayBem'+i+';');			
			mostraTabelaBens('BT');
			return false
			break;	
		default:  
           	break;
	}
	showMsgAguardo('Aguarde, ' + msgOperacao + ' ...');	
	controlaLayoutBens(operacao);	
	return false;
}

// Controla o layout da descrição de bens
function controlaLayoutBens( operacao ) {
		
	// Operação consultando
	if (operacao == 'BT') {	
		$('#divProcBensTabela').css('display','block');
		$('#divProcBensFormulario').css('display','none');
		
		// Formata o tamanho da tabela
		$('#divProcBensTabela').css({'height':'215px','width':'517px'});
		
		// Monta Tabela dos Itens
		$('#divProcBensTabela > div > table > tbody').html('');		
		
		for( var i in arrayBens ) {
			desc = ( arrayBens[i]['dsrelbem'].length > 16 ) ? arrayBens[i]['dsrelbem'].substr(0,17)+'...' : arrayBens[i]['dsrelbem'] ;
			$('#divProcBensTabela > div > table > tbody').append('<tr></tr>');										
			$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td><span>'+arrayBens[i]['dsrelbem']+'</span>'+ desc+'<input type="hidden" id="indarray" name="indarray" value="'+i+'" /></td>').css({'text-transform':'uppercase'});
			$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td><span>'+arrayBens[i]['persemon'].replace(',','.')+'</span>'+number_format(parseFloat(arrayBens[i]['persemon'].replace(',','.')),2,',','.')+'</td>');
			$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td>'+arrayBens[i]['qtprebem']+'</td>');
			$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td><span>'+arrayBens[i]['vlprebem'].replace(',','.')+'</span>'+number_format(parseFloat(arrayBens[i]['vlprebem'].replace(/[.R$ ]*/g,'').replace(',','.')),2,',','.')+'</td>');
			$('#divProcBensTabela > div > table > tbody > tr:last-child').append('<td><span>'+arrayBens[i]['vlrdobem'].replace(',','.')+'</span>'+number_format(parseFloat(arrayBens[i]['vlrdobem'].replace(/[.R$ ]*/g,'').replace(',','.')),2,',','.')+'</td>');
		}
						
		var divRegistro = $('#divProcBensTabela > div.divRegistrosProcuradores');		
		var tabela      = $('table', divRegistro );
	
		divRegistro.css('height','60px');
		
		var ordemInicial = new Array();
		ordemInicial = [[0,0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '160px';
		arrayLargura[1] = '60px';
		arrayLargura[2] = '60px';
		arrayLargura[3] = '83px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacaoBens(\'BF\');' );
		
		if ( in_array(operacao,['BT']) ) {
			SelecionaItem('indarray',tabela,auxind);
		}
	
	//  Operação Alterando/Incluindo - Formatando o formulário
	} else {
	
		var persemon, qtprebem, vlrdobem;
		
		var cTodos      = $('#dsrelbem,#persemon,#qtprebem,#vlprebem,#vlrdobem','#frmProcBens');
		var cDescricao  = $('#dsrelbem','#frmProcBens');
		var cPercentual = $('#persemon','#frmProcBens');
		var cQtParcela  = $('#qtprebem','#frmProcBens');
		var cVlParcela  = $('#vlprebem','#frmProcBens');
		var cVlBem      = $('#vlrdobem','#frmProcBens');	
		
		// Controla largura dos campos
		$('label','#frmProcBens').css({'width':'195px'}).addClass('rotulo');
		cDescricao.css({'width':'275px'});
		cPercentual.css({'width':'50px'});
		cQtParcela.css({'width':'50px'});
		cVlParcela.css({'width':'135px','text-align':'right'}).attr('alt','p6p3c2D').autoNumeric().trigger('blur');
		cVlBem.css({'width':'135px'});	
		
		// Se inclusão, limpar dados do formulário
		if ( operacao == 'BI' ) {
			$('#frmProcBens').limpaFormulario();
			$('input[name="incluir"]','#divProcBensFormulario').unbind('click');
			$('input[name="incluir"]','#divProcBensFormulario').click( function() { validaBens('IS'); return false; } );
		} else if ( operacao == 'BF') {
			$('input[name="incluir"]','#divProcBensFormulario').unbind('click');
			$('input[name="incluir"]','#divProcBensFormulario').click( function() { validaBens('AS'); return false; } );
		}
	
		// Formata o tamanho do Formulário
		$('#divProcBensFormulario').css({'height':'165px','width':'517px'});
		
		// Adicionando as classes
		cTodos.removeClass('campoErro').habilitaCampo();
		
		// Se percentual sem ônus = 100, trava os campos "qtprebem" e "vlprebem"
		persemon = cPercentual.val();
		persemon = (typeof persemon == 'undefined') ? 0 : persemon.replace(',','.');
		persemon = parseFloat( persemon );

		if ( persemon == 100 ) {
			cQtParcela.unbind().val(0).desabilitaCampo();
			cVlParcela.unbind().val(0,00).desabilitaCampo();
		}		
		
		// Valida Percentual sem Ônus
		cPercentual.change(function () {			
			persemon = parseFloat( cPercentual.val().replace(',','.') );			
			// Se maior do que 100, mostra mensagem de erro e retorna o foco no mesmo campo
			if ( persemon > 100 ) {
				showError('error','Valor Percentual sem &ocirc;nus deve ser menor ou igual a 100,00.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'persemon\',\'frmProcBens\')');
			} else {
				cPercentual.removeClass('campoErro');
				if ( persemon == 100 ) {
					cQtParcela.unbind().val(0).desabilitaCampo();
					cVlParcela.unbind().val(0,00).desabilitaCampo();
					layoutPadrao();	
				} else {						
					cQtParcela.habilitaCampo();
					cVlParcela.habilitaCampo();
					cVlParcela.css({'width':'135px','text-align':'right'}).attr('alt','p6p3c2D').autoNumeric().trigger('blur');
					cQtParcela.focus();				
				}
			}
		});	

		// Valida Quantidade de parcelas
		// Ao mudar a Quantidade de parcelas, não permitir valores menores ou iguais a zero
		cQtParcela.change(function () {
			if ( $(this).hasClass('campo') ) { 
				qtprebem = parseFloat( cQtParcela.val().replace(',','.').replace('','0') );
				if ( qtprebem <= 0 )	{
					showError('error','Parcelas a pagar deve ser maior que zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'qtprebem\',\'frmProcBens\')');
				} else {
					cQtParcela.removeClass('campoErro');
				}
			}
		});
		
		// Valida Valor das parcelas
		cVlParcela.change(function () {
			if ( $(this).hasClass('campo') ) { 
				vlprebem = parseFloat( cVlParcela.val().replace(',','.').replace('','0') );
				if ( vlprebem <= 0 ) {
					showError('error','Valor da parcela deve ser maior que zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'vlprebem\',\'frmProcBens\')');
				} else {
					cVlParcela.removeClass('campoErro');
				}
			}
		});		
		
		// Valida Valor do Bem
		cVlBem.change(function () {
			vlrdobem = parseFloat( cVlBem.val().replace(',','.').replace('','0') );
			if ( vlrdobem <= 0 ) {
				showError('error','Valor do Bem deve ser maior que zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'vlrdobem\',\'frmProcBens\')');
			} else {
				cVlBem.removeClass('campoErro');
			}
		});			
	}	
	
	layoutPadrao();	
	hideMsgAguardo();
	bloqueiaFundo($('#divUsoGenerico'));	
	if (operacao != 'BT') { 
		$('#dsrelbem','#divProcBensFormulario').focus(); 
	}else{
		$('#btIncluir','#divProcBensTabela').focus();
	}
	return false;
}

function validaBens(operacao){
	
	var dsrelbem, persemon, qtprebem, vlprebem, vlrdobem;	
	
	var cTodos      = $('#dsrelbem,#persemon,#qtprebem,#vlprebem,#vlrdobem','#frmProcBens');
	var cDescricao  = $('#dsrelbem','#frmProcBens');
	var cPercentual = $('#persemon','#frmProcBens');
	var cQtParcela  = $('#qtprebem','#frmProcBens');
	var cVlParcela  = $('#vlprebem','#frmProcBens');
	var cVlBem      = $('#vlrdobem','#frmProcBens');	

	cTodos.removeClass('campoErro');

	// Recebe todos os valores em variáveis
	dsrelbem = trim( cDescricao.val() );
	persemon = cPercentual.val().replace(',','.');
	qtprebem = cQtParcela.val().replace('','0');
	vlprebem = parseFloat( cVlParcela.val().replace(',','.').replace('','0') );
	vlrdobem = parseFloat( cVlBem.val().replace(',','.').replace('','0') );
	
	// Descrição do bem não pode ser vazia
	if ( dsrelbem == '' ) { showError('error','Descri&ccedil;&atilde;o do bem deve se preenchido.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'dsrelbem\',\'frmProcBens\')');return false; } 
	
	// Não aceita percentual sem ônus maior do que 100%	
	if ( persemon > 100 ) {	showError('error','Percentual sem &ocirc;nus deve ser menor ou igual a 100,00.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'persemon\',\'frmProcBens\')');return false; }
	
	// Se percentual sem ônus for 100%, então qtde. e valor das parcelas deve ser zero
	if ( ( persemon == 100 ) && ( qtprebem > 0 ) ) {showError('error','Parcelas a pagar deve ser zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'qtprebem\',\'frmProcBens\')');return false; }
	if ( ( persemon == 100 ) && ( vlprebem > 0 ) ) {showError('error','Valor da parcela deve ser zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'vlprebem\',\'frmProcBens\')');return false; }

	// Se percentual sem ônus for menor do que 100%, então qtde. e valor das parcelas devem ser maiores do que zero
	if ( ( persemon < 100 ) && ( qtprebem == 0 ) ) {showError('error','Parcelas a pagar deve ser maior que zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'qtprebem\',\'frmProcBens\')');return false; }
	if ( ( persemon < 100 ) && ( vlprebem == 0 ) ) {showError('error','Parcelas a pagar deve ser maior que zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'vlprebem\',\'frmProcBens\')');return false; }
	
	// Valida valor do bem
	if( vlrdobem <= 0 ) {showError('error','Valor do Bem deve ser maior que zero.','Alerta - Ayllos','bloqueiaFundo($("#divUsoGenerico"),\'vlrdobem\',\'frmProcBens\')');return false; }
	
	controlaOperacaoBens(operacao);
	return false;
}

function fechaBens(){

	if( arrayBens.length > 0){
		var descBem = arrayBens[0]['dsrelbem'];
		$('#dsrelbem','#frmDadosProcuradores').val(descBem.toUpperCase());
	}else{
		$('#dsrelbem','#frmDadosProcuradores').val('');
	}
	$('#divProcBensFormulario').remove();
	fechaRotina($('#divUsoGenerico'),$('#divRotina'));
	$('#dtvalida','#frmDadosProcuradores').focus();
	
}

//Função seleciona a linha referente ao item consultado/alterado
function SelecionaItem(name,tabela,rowid){
	
	var divRegistro = tabela.parent();
	var linha       = $('table > tbody > tr', divRegistro );
	
	$(linha, divRegistro).each( function(i) {
		if( $('input[name="'+name+'"]', $(this) ).val() == rowid ){
			tabela.zebraTabela( i );
			$('tbody > tr:eq('+i+') > td', tabela ).first().focus();
		}
	});
}

function controlaLayoutPoder() {
	
	altura  = '380px';
	largura = '570px';
	
	divRotina.css('width',largura);	
	
	$('#divConteudoOpcao').css('height',altura);		
	
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	divRegistro.css('height','360px');
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
	
	var arrayLargura = new Array();
	arrayLargura[0] = '200px';
	arrayLargura[1] = '190px';
	arrayLargura[2] = '190px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	$('.divRegistros > table > thead').remove();
}

function controlaOperacaoPoderes(operacao) {
    switch (operacao) {
		
		case 'SP':
			// Oculto o formulario e mostro a tabela
		    showConfirmacao('Deseja confirmar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','salvarPoderes()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
	}
        }

function salvarPoderes(){
	
	var strPoderes = "";
	var dsoutpod = "";
	var flgisola = "no";
	var flgconju = "no";
	
	showMsgAguardo('Aguarde, salvando...');	
	
	dsoutpod += $('#dsoutpod1').val();
	dsoutpod += '#' + $('#dsoutpod2').val();
	dsoutpod += '#' + $('#dsoutpod3').val();
	dsoutpod += '#' + $('#dsoutpod4').val();
	dsoutpod += '#' + $('#dsoutpod5').val();
	
	$('table > tbody > tr', 'div.divRegistros').each(function () {

	    valRadio = $('input:checked', $(this)).val();

	    if (dsoutpod == undefined || dsoutpod == "") {
	        dsoutpod = ""
	    }

	    if ($('input[name="hdnCodPoder"]', $(this)).val() != 10) {
	        if (valRadio == 'iso') {
	            flgconju = "no";
	            flgisola = "yes"
	        } else if (valRadio == 'con') {
	            flgconju = "yes";
	            flgisola = "no"
	        } else {
	            flgconju = "no";
	            flgisola = "no"
	        }
	    } else {
	        if (valRadio == 'con') {
	            flgconju = "yes";
	            flgisola = "no";
	        } else {
	            flgconju = "no";
	            flgisola = "no";
	        }
	    }

	    if (strPoderes != "") {
	        strPoderes += "/"
	    }

	    strPoderes += $('input[name="hdnCodPoder"]', $(this)).val() + ",";
	    strPoderes += flgconju + ",",
		strPoderes += flgisola + ",",
		strPoderes += dsoutpod;
	});
	
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'includes/procuradores/salva_poderes.php', 		
		data: {			
			strPoderes: strPoderes,nrdconta: nrdconta,
			nrcpfcgc: nrcpfcgc,nrdctato: nrdctato
		}, 
		error:function(objAjax, responseError,objExcept){
			hideMsgAguardo();
		},
		success: function(response) {
			hideMsgAguardo();
			if (response != "" &&
				response != 'hideMsgAguardo();showError("error","yes","Alerta - Ayllos","","NaN");' &&
				response != 'hideMsgAguardo();showError("error","no","Alerta - Ayllos","","NaN");'){
				eval(response);
			}else{
				acessaOpcaoAbaDados(6,2,'@');
				return false;
			}
		}		
	});
	
	
}

function selecionaPoder(check) {

    if (check == 'radPoderC10') {
        if (flgassco) {
            $('#radPoderC10').removeProp('checked');
            flgassco = false;
        } else {
            $('#radPoderC10').prop('checked', 'checked');
            flgassco = true;
        }
    } else if (check == 'radPoderC1' || check == 'radPoderI1') {

        if (check == 'radPoderC1' && flgpoderC1) {
            $('#' + check).removeProp('checked');
            flgpoderC1 = false;
        } else if (check == 'radPoderI1' && flgpoderI1) {
            $('#' + check).removeProp('checked');
            flgpoderI1 = false;
        } else if (check == 'radPoderC1' && !(flgpoderC1)) {
            $('#radPoderI1').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC1 = true;
            flgpoderI1 = false;
        } else if (check == 'radPoderI1' && !(flgpoderI1)) {
            $('#radPoderC1').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI1 = true;
            flgpoderC1 = false;
        }
    } else if (check == 'radPoderC2' || check == 'radPoderI2') {
        if (check == 'radPoderC2' && flgpoderC2) {
            $('#' + check).removeProp('checked');
            flgpoderC2 = false;
        } else if (check == 'radPoderI2' && flgpoderI2) {
            $('#' + check).removeProp('checked');
            flgpoderI2 = false;
        } else if (check == 'radPoderC2' && !(flgpoderC2)) {
            $('#radPoderI2').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC2 = true;
            flgpoderI2 = false;
        } else if (check == 'radPoderI2' && !(flgpoderI2)) {
            $('#radPoderC2').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI2 = true;
            flgpoderC2 = false;
        }
    } else if (check == 'radPoderC3' || check == 'radPoderI3') {
        if (check == 'radPoderC3' && flgpoderC3) {
            $('#' + check).removeProp('checked');
            flgpoderC3 = false;
        } else if (check == 'radPoderI3' && flgpoderI3) {
            $('#' + check).removeProp('checked');
            flgpoderI3 = false;
        } else if (check == 'radPoderC3' && !(flgpoderC3)) {
            $('#radPoderI3').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC3 = true;
            flgpoderI3 = false;
        } else if (check == 'radPoderI3' && !(flgpoderI3)) {
            $('#radPoderC3').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI3 = true;
            flgpoderC3 = false;
        }
    } else if (check == 'radPoderC4' || check == 'radPoderI4') {
        if (check == 'radPoderC4' && flgpoderC4) {
            $('#' + check).removeProp('checked');
            flgpoderC4 = false;
        } else if (check == 'radPoderI4' && flgpoderI4) {
            $('#' + check).removeProp('checked');
            flgpoderI4 = false;
        } else if (check == 'radPoderC4' && !(flgpoderC4)) {
            $('#radPoderI4').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC4 = true;
            flgpoderI4 = false;
        } else if (check == 'radPoderI4' && !(flgpoderI4)) {
            $('#radPoderC4').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI4 = true;
            flgpoderC4 = false;
        }
    } else if (check == 'radPoderC5' || check == 'radPoderI5') {
        if (check == 'radPoderC5' && flgpoderC5) {
            $('#' + check).removeProp('checked');
            flgpoderC5 = false;
        } else if (check == 'radPoderI5' && flgpoderI5) {
            $('#' + check).removeProp('checked');
            flgpoderI5 = false;
        } else if (check == 'radPoderC5' && !(flgpoderC5)) {
            $('#radPoderI5').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC5 = true;
            flgpoderI5 = false;
        } else if (check == 'radPoderI5' && !(flgpoderI5)) {
            $('#radPoderC5').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI5 = true;
            flgpoderC5 = false;
        }
    } else if (check == 'radPoderC6' || check == 'radPoderI6') {
        if (check == 'radPoderC6' && flgpoderC6) {
            $('#' + check).removeProp('checked');
            flgpoderC6 = false;
        } else if (check == 'radPoderI6' && flgpoderI6) {
            $('#' + check).removeProp('checked');
            flgpoderI6 = false;
        } else if (check == 'radPoderC6' && !(flgpoderC6)) {
            $('#radPoderI6').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC6 = true;
            flgpoderI6 = false;
        } else if (check == 'radPoderI6' && !(flgpoderI6)) {
            $('#radPoderC6').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI6 = true;
            flgpoderC6 = false;
        }
    } else if (check == 'radPoderC7' || check == 'radPoderI7') {
        if (check == 'radPoderC7' && flgpoderC7) {
            $('#' + check).removeProp('checked');
            flgpoderC7 = false;
        } else if (check == 'radPoderI7' && flgpoderI7) {
            $('#' + check).removeProp('checked');
            flgpoderI7 = false;
        } else if (check == 'radPoderC7' && !(flgpoderC7)) {
            $('#radPoderI7').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC7 = true;
            flgpoderI7 = false;
        } else if (check == 'radPoderI7' && !(flgpoderI7)) {
            $('#radPoderC7').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI7 = true;
            flgpoderC7 = false;
        }
    } else if (check == 'radPoderC8' || check == 'radPoderI8') {
        if (check == 'radPoderC8' && flgpoderC8) {
            $('#' + check).removeProp('checked');
            flgpoderC8 = false;
        } else if (check == 'radPoderI8' && flgpoderI8) {
            $('#' + check).removeProp('checked');
            flgpoderI8 = false;
        } else if (check == 'radPoderC8' && !(flgpoderC8)) {
            $('#radPoderI8').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC8 = true;
            flgpoderI8 = false;
        } else if (check == 'radPoderI8' && !(flgpoderI8)) {
            $('#radPoderC8').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI8 = true;
            flgpoderC8 = false;
        }
    } else if (check == 'radPoderC9' || check == 'radPoderI9') {
        if (check == 'radPoderC9' && flgpoderC9) {
            $('#' + check).removeProp('checked');
            flgpoderC9 = false;
        } else if (check == 'radPoderI9' && flgpoderI9) {
            $('#' + check).removeProp('checked');
            flgpoderI9 = false;
        } else if (check == 'radPoderC9' && !(flgpoderC9)) {
            $('#radPoderI9').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderC9 = true;
            flgpoderI9 = false;
        } else if (check == 'radPoderI8' && !(flgpoderI8)) {
            $('#radPoderC9').removeProp('checked');
            $('#' + check).prop('checked', 'checked');
            flgpoderI9 = true;
            flgpoderC9 = false;
        }
    }

}