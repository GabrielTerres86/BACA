/*
 * FONTE        : responsavel_legal.js
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 04/05/2010 
 * OBJETIVO     : Biblioteca de funções na rotina Responsável Legal da tela de CONTAS
 * ALTERAÇÃO    : Adicionado pesquisa CEP. ( Rodolpho/Rogérius. (DB1) ).
 *                06/02/2012 - Ajuste para não chamar 2 vezes a função mostraPesquisa (Tiago).
 *                24/04/2012 - Ajustes Projeto GP - Socios Menores (Adriano)
 *                28/01/2015 - #239097 Ajustes para cadastro de Resp. legal 0 menor/maior.
 *                16/07/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *                25/04/2017 - Alterado campo dsnacion para cdnacion. (Projeto 339 - Odirlei-AMcom)
 *                12/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                   crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
							  (Adriano - P339).
 *                31/07/2017 - Aumentado campo dsnatura de 25 para 50, PRJ339-CRM (Odirlei-AMcom).
 *                19/10/2017 - Ajuste da lov de nacionalidades na tela de responsavel legal. (PRJ339 - Kelvin).
 * 				  25/09/2017 - Adicionado uma lista de valores para carregar orgao emissor. (PRJ339 - Kelvin)			                         
 *                23/10/2017 - Ajustado para chamar a rotina de reposavel legal apos a inclusão devido a 
 *                             replicação dos dados da pessoa. (PRJ339 Odirlei/AMcom)   
 *				  25/10/2017 - Removendo campo caixa postal (PRJ339 - Kelvin).
 */

var nrcpfcto = "";
var nrdctato_rsp = "";
var nrdrowid_rsp = "";
var cddopcao_rsp = ""; 
var cpfaux_rsp 	 = "";
var operacao_rsp = "";
var nomeFormResp = "frmRespLegal";
var arrayBackup  = new Array(); // Array que armazena o arrayFilhos antes de qualquer operação.
var indarray_rsp = ''; 			// Variável que armazena o responsavel legal que está selecionado na tabela
var cooperativa = 0; 			//Armazena o código da cooperativa para ser usado na inclusao de reg no arrayFilhos
var aux_permalte = true;		//Varaiavel para verificar se conta pode ou nao ser alterada
var validadt = false; 			//Variavel criada para que possa ser validado a data de nascimento na tela Resp. Legal
var aux_cdestciv; 				//Variavel para armazenar o estado civil. Devido ao montaSelect do estado civil demorar para retornar o resultado.
var ope_rotinaant = '';			//Contem a opcao da rotina anterior
var teste = false;

/*OBS.: Devido a tela responsável estar sendo chamada por mais de uma rotina, o nome das funções, 
  variáveis globais deste fonte devem ser diferenciadas dos fontes da rotina origem.*/

if(nmrotina != "Representante/Procurador"){
	var criaTabela  = 'CT'; 		//Variável para controlar quando a tabela referente ao arrayFilhos será alimentada e apresentada na tela
}
      
function acessaOpcaoAbaResp(nrOpcoes,id,opcao) { 
	
	showMsgAguardo("Aguarde, carregando ...");
	
	if (nmrotina != "Responsavel Legal") {
		// Atribui cor de destaque para aba da opção
		for (var i = 0; i < nrOpcoes; i++) {
			if (!$("#linkAba" + id)) {
				continue;
			}
			
			if (id == i) { // Atribui estilos para foco da opção
				$("#linkAba" + id).attr("class","txtBrancoBold");
				$("#imgAbaEsq" + id).attr("src",UrlImagens + "background/mnu_sle.gif");				
				$("#imgAbaDir" + id).attr("src",UrlImagens + "background/mnu_sld.gif");
				$("#imgAbaCen" + id).css("background-color","#969FA9");
				continue;			
			}
			
			$("#linkAba"   + i).attr("class","txtNormalBold");
			$("#imgAbaEsq" + i).attr("src",UrlImagens + "background/mnu_nle.gif");			
			$("#imgAbaDir" + i).attr("src",UrlImagens + "background/mnu_nld.gif");
			$("#imgAbaCen" + i).css("background-color","#C6C8CA");
			
		}
	}
	
	ope_rotinaant = '';
	
	if(nmrotina == 'Identificacao'){
		
			criaTabela = 'CT';
			ope_rotinaant = operacao;
							
	}else if(nmrotina == "Representante/Procurador"){
	
			criaTabela = 'CT';
		   	ope_rotinaant = aux_cdrotina;
			
	}else if(nmrotina == "MATRIC" ){
	
			ope_rotinaant = aux_cdrotina;
						
	}
	
	$('#divConteudoOpcao').css('height','200px');
		
	if (typeof cpfprocu == 'undefined') {
		var cpfprocu = 0;
	}
		
	if (typeof dtdenasc == 'undefined') {
		var dtdenasc = "";
	}
	
	if (typeof cdhabmen == 'undefined') {
		var cdhabmen = 0;
	}
			
	// Carrega conteúdo da opção através do Ajax
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "includes/responsavel_legal/principal.php",
		data: {
			nrdconta: (nmrotina == 'Representante/Procurador' || (idseqttl == 2 && nmrotina != "Responsavel Legal" ) ) ? nrdctato : nrdconta,
			idseqttl: (nmrotina == 'Representante/Procurador' || (idseqttl == 2 && nmrotina != "Responsavel Legal" ) ) ? nrctremp : idseqttl,
			nrcpfcto: (nmrotina == 'Representante/Procurador' || (idseqttl == 2 && nmrotina != "Responsavel Legal" ) ) ? ''       : normalizaNumero(nrcpfcto),
			nrdctato_rsp: nrdctato_rsp,
			nrdrowid_rsp: nrdrowid_rsp,
			cddopcao_rsp: cddopcao_rsp,
			operacao_rsp: operacao_rsp,
			ope_rotinaant: (nmrotina != 'Responsavel Legal') ? ope_rotinaant : '',
			cpfprocu: (nmrotina == 'Representante/Procurador' || (idseqttl == 2 && nmrotina != "Responsavel Legal" ) ) ? normalizaNumero(nrcpfcgc_proc) : normalizaNumero(cpfprocu),
			nmdatela: nmdatela,
			nmrotina: nmrotina,
			dtdenasc: dtdenasc,
			cdhabmen: cdhabmen,
			permalte: aux_permalte,
			flgcadas: flgcadas,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',bloqueiaFundo(divRotina));
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divOpcoesDaOpcao2').html(response);
			} else {
				eval( response );
				controlaFocoResp( operacao_rsp );
			}
			return false;
		}
	});
}

//Função de controle das ações/operações da tela de representantes/procuradores
function controlaOperacaoResp( operacao_rsp ){
	
	if ( operacao_rsp != 'EV' && !verificaContadorSelect() ) return false;
	
	// Se não possui acesso para alterar, emitir mensagem	
	if ( (operacao_rsp == 'TC') && (flgConsultar != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de consulta.'               ,'Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao_rsp == 'TA') && (flgAlterar   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }	
	if ( (operacao_rsp == 'TI') && (flgIncluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de inclus&atilde;o.'        ,'Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao_rsp == 'TE') && (flgExcluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de exclux&atilde;o.'        ,'Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
	
	aux_permalte = true;

	if(nmrotina != "Responsavel Legal"){
		
		ope = ( typeof operacao_rsp != 'undefined' ) ? operacao_rsp : '';
			
		if ( !in_array(operacao_rsp,['TI','IV','CT','TB','IT','EV','AV','AT',]) && ope != '') {
				
			indarray_rsp = retornaIndiceSelecionadoResp();	
			
			if ( indarray_rsp == ''){ 
				return false; 
			} 
			
		}
			
	}
	
	if ( in_array(operacao_rsp,['TC','TA','TE','CF']) ) {
		
		nrdrowid_rsp = '';
			
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				
				if(nmrotina == "Responsavel Legal"){
					nrdrowid_rsp = $('input', $(this) ).val();
					
				}else{ 
					nrdrowid_rsp  = $('input[name="nrdrowid"]', $(this) ).val();
					
					if( nrdrowid_rsp == 'undefined' ){
						nrdrowid_rsp = '';
	
					}
					
				}
			}
		});
		
		if(nmrotina == "Responsavel Legal"){
			if ( nrdrowid_rsp == '' ) { return false; }		
		}
		
	}
	
		
	if ( (operacao_rsp == 'TA') && (menorida != 'yes') ) { return false; }
	
	var mensagem = '';		
	
	switch (operacao_rsp) {
		// Consulta tabela para consulta formulário
		case 'CF':
			mensagem = 'Aguarde, carregando ...';
			cddopcao_rsp = 'C';	
			break;
		// Consulta tabela para consulta formulário
		case 'TC':
			mensagem = 'Aguarde, carregando ...';
			cddopcao_rsp = 'C';	
			break;			
		// Consulta formulário para consulta tabela
		case 'CT':  
			mensagem = 'Aguarde, carregando ...';
			nrcpfcto = '';
			nrdctato_rsp = '';
			nrdrowid_rsp = '';
			cddopcao_rsp = 'C';			
			break;				
		// Consulta tabela para alteração
		case 'TA': 
			mensagem = 'Aguarde, carregando ...';
			cddopcao_rsp = 'A';		
			
			if(nmrotina == "Representante/Procurador"){
				
				aux_permalte = (nrdctato == '0') ? true : false;
				nrdctato_rsp = arrayFilhos[indarray_rsp]['nrdconta'];
				nrcpfcto = arrayFilhos[indarray_rsp]['nrcpfcgc'];
					
			}else if(nmrotina == "MATRIC" && idseqttl == 2){
				
				aux_permalte = (nrdctato == '0') ? true : false;
				nrdctato_rsp = arrayFilhos[indarray_rsp]['nrdconta'];
				nrcpfcto = arrayFilhos[indarray_rsp]['nrcpfcgc'];
				
			}else if(nmrotina == "Identificacao"){
			
				aux_permalte = (nrdconta == '0') ? true : false;
				nrdctato_rsp = arrayFilhos[indarray_rsp]['nrdconta'];
				nrcpfcto = arrayFilhos[indarray_rsp]['nrcpfcgc'];
			
			}else{
			
				aux_permalte = true;
							
			}
			
			break;
		// Alteração para consulta tabela 		
		case 'AT': 
			showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacaoResp();','bloqueiaFundo(divRotina);','sim.gif','nao.gif');
			return false;
			break;
		// Formulario em modo inclusão para tabela consulta		
		case 'IT': 
            showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacaoResp();','bloqueiaFundo(divRotina);','sim.gif','nao.gif');
			return false;
            break;	
		// Tabela consulta para inclusão	
		case 'TI':
			mensagem = 'Aguarde, carregando ...';
			nrcpfcto = '';
			nrdctato_rsp = '';
			nrdrowid_rsp = '';
			
			if(nmrotina == "Representante/Procurador"){
			
				aux_permalte = (nrdctato == '0') ? true : false;
				
			}else if(nmrotina == "MATRIC" && idseqttl == 2){
			
				aux_permalte = (nrdctato == '0') ? true : false;
				
			}else{
			
				aux_permalte = true;
				
			}
			break;
		// Formulario de inclução com os dados de retorno da busca por CONTA ou CPF	
		case 'TB':
			mensagem = 'Aguarde, carregando ...';
			cddopcao_rsp = 'I';
			if(nmrotina == "Representante/Procurador"){
			
				aux_permalte = (nrdctato == '0') ? true : false;
				
			}else if(nmrotina == "MATRIC" && idseqttl == 2){
			
				aux_permalte = (nrdctato == '0') ? true : false;
				
			}else{
			
				aux_permalte = true;
				
			}
			break;
		// Abre o form. consulta para formulario em modo exclusão	
		case 'TE': 
			mensagem = 'Aguarde, processando exclusão ...';
			cddopcao_rsp = 'E';
								
			if(nmrotina == "Representante/Procurador"){
			
				aux_permalte = (nrdctato == '0') ? true : false;
				
			}else if(nmrotina == "MATRIC" && idseqttl == 2){
			
				aux_permalte = (nrdctato == '0') ? true : false;
				
			}else{
			
				aux_permalte = true;
				
			}
						
			break;
		case 'AV' : 
		
			if(nmrotina == "Representante/Procurador"){
			
				aux_permalte = (nrdctato == '0') ? true : false;
				
			}else if(nmrotina == "MATRIC" && idseqttl == 2){
			
				aux_permalte = (nrdctato == '0') ? true : false;
				
			}else{
			
				aux_permalte = true;
				
			}
			
			manterRotinaResp(operacao_rsp);
			
			return false;
			
			break;	
			
			
		case 'IV' : 
		
			if(nmrotina == "Representante/Procurador"){
			
				aux_permalte = (nrdctato == '0') ? true : false;
				
			}else if(nmrotina == "MATRIC" && idseqttl == 2){
			
				aux_permalte = (nrdctato == '0') ? true : false;
				
			}else{
			
				aux_permalte = true;
				
			}
			
			manterRotinaResp(operacao_rsp);
						
			return false;
			break;
			
			
		case 'EV' : manterRotinaResp(operacao_rsp);return false;break;
		case 'VA' : manterRotinaResp(operacao_rsp);return false;break;		
		case 'VI' : manterRotinaResp(operacao_rsp);return false;break;
		case 'VE' : manterRotinaResp(operacao_rsp);return false;break;	
		default   :
			mensagem = 'Aguarde, carregando ...';
			operacao_rsp = (operacao_rsp != 'SC') ? 'CT' : operacao_rsp;
			nrcpfcto = '';
			nrdctato_rsp = '';
			nrdrowid_rsp = '';
			cddopcao_rsp = 'C';
	}	
	
	if (typeof cpfprocu == 'undefined') {
		var cpfprocu = 0;
	}
	
	if (typeof dtdenasc == 'undefined') {
		var dtdenasc = "";
	}
	
	if (typeof cdhabmen == 'undefined') {
		var cdhabmen = 0;
	}
	
		
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'includes/responsavel_legal/principal.php', 
		data: {
			nrdconta: (nmrotina == 'Representante/Procurador' || (idseqttl == 2 && nmrotina != "Responsavel Legal" ) ) ? nrdctato : nrdconta,	
			idseqttl: (nmrotina == 'Representante/Procurador' || (idseqttl == 2 && nmrotina != "Responsavel Legal" ) ) ? nrctremp : idseqttl,
			nrcpfcto:  normalizaNumero(nrcpfcto),
			nrdctato_rsp: nrdctato_rsp,	
			nrdrowid_rsp: nrdrowid_rsp,	
			cddopcao_rsp: cddopcao_rsp,
			ope_rotinaant: (nmrotina != 'Responsavel Legal') ? ope_rotinaant : '',
			cpfprocu: (nmrotina == 'Representante/Procurador' || (idseqttl == 2 && nmrotina != "Responsavel Legal" ) ) ? normalizaNumero(nrcpfcgc_proc) : normalizaNumero(cpfprocu),
			nmdatela: nmdatela,
			nmrotina: nmrotina,
			operacao_rsp: operacao_rsp,	
			permalte : aux_permalte,
			dtdenasc: dtdenasc, 
			cdhabmen: cdhabmen, 
			tppessoa: (nmrotina == "MATRIC") ? tppessoa : 0, 
			flgcadas: flgcadas,
			redirect: 'script_ajax'			
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divOpcoesDaOpcao2').html(response);
			} else {
				eval( response );
				controlaFocoResp( operacao_rsp );
			}
			return false;
		}				
	});	
	
	criaTabela = '';
	
		
}

function manterRotinaResp(operacao_rsp) {
	
	hideMsgAguardo();	
	
	var mensagem = '';
	
	switch (operacao_rsp) {	
	
		case 'VA': mensagem = 'Aguarde, alterando ...'; break;
		case 'VI': mensagem = 'Aguarde, incluindo ...'; break;
		case 'VE': mensagem = 'Aguarde, excluindo ...'; break;							
		case 'AV': mensagem = 'Aguarde, validando alteração ...'; break;
		case 'IV': mensagem = 'Aguarde, validando inclusão ...'; break;			
		case 'EV': mensagem = 'Aguarde, validando exclusão ...'; break;		
		default: return false; break;
		
	}
	
	showMsgAguardo( mensagem );
	
	// Recebendo valores do formulário 
	nrcpfcto = normalizaNumero( $('#nrcpfcto','#frmRespLegal').val() );
	nrdctato_rsp = normalizaNumero( $('#nrdctato','#frmRespLegal').val() );
	cdoeddoc = trim($('#cdoeddoc','#frmRespLegal').val()); 
	dtnascto = $('#dtnascto','#frmRespLegal').val(); 
	dtemddoc = $('#dtemddoc','#frmRespLegal').val(); 
	nmdavali = $('#nmdavali','#frmRespLegal').val(); 
	cdufddoc = $('#cdufddoc','#frmRespLegal').val();
	tpdocava = $('#tpdocava','#frmRespLegal').val(); 
	nrdocava = $('#nrdocava','#frmRespLegal').val();
	cdestcvl = (operacao_rsp == "EV") ? aux_cdestciv : $('#cdestciv','#frmRespLegal').val(); 
	cdnacion = $('#cdnacion','#frmRespLegal').val(); 
	dsnatura = $('#dsnatura','#frmRespLegal').val(); 
	complend = trim($('#complend','#frmRespLegal').val()); 
	nmcidade = trim($('#nmcidade','#frmRespLegal').val()); 
	nmbairro = trim($('#nmbairro','#frmRespLegal').val()); 
	dsendere = trim($('#dsendere','#frmRespLegal').val()); 
	nmpaicto = trim($('#nmpaicto','#frmRespLegal').val()); 
	nmmaecto = trim($('#nmmaecto','#frmRespLegal').val()); 
	nrendere = normalizaNumero( $('#nrendere','#frmRespLegal').val() ); 
	nrcepend = normalizaNumero( $('#nrcepend','#frmRespLegal').val() ); 
	cdufende = $('#cdufende','#frmRespLegal').val();
	cdrlcrsp = $('#cdrelacionamento','#frmRespLegal').val();
	
		
	// Tratamento para os radio do sexo
	var sexoMas = $("#sexoMas","#frmRespLegal").prop("checked");					
	var sexoFem = $("#sexoFem","#frmRespLegal").prop("checked");	                
	var cdsexcto = '0';     
	
	if (sexoMas) {cdsexcto = '1';}else if (sexoFem) {cdsexcto = '2';}   

	if (typeof cpfprocu == 'undefined') {
		var cpfprocu = 0;
	}
	
	if (typeof dtdenasc == 'undefined') {
		var dtdenasc = "";
	}
	
	if (typeof cdhabmen == 'undefined') {
		var cdhabmen = 0;
	}	
		
	// Executa script de confirmação através de ajax								
	$.ajax({		                                                                
		type: "POST",                                                               
		url: UrlSite + "includes/responsavel_legal/manter_rotina.php", 		    
		data: {			                                                            
			nrcpfcto: normalizaNumero(nrcpfcto),	
			cdoeddoc: cdoeddoc,	
			dtnascto: dtnascto,             
			dtemddoc: dtemddoc,	
			nrdctato_rsp: nrdctato_rsp, 
			cdsexcto: cdsexcto,            
			nmdavali: nmdavali,	
			cdufddoc: cdufddoc, 
			tpdocava: tpdocava,             
			nrdocava: nrdocava,	
			cdestcvl: cdestcvl,	
			cdnacion: cdnacion,             
			dsnatura: dsnatura,	
			complend: complend, 
			nmcidade: nmcidade,             
			nmbairro: nmbairro,	
			dsendere: dsendere,	
			nmpaicto: nmpaicto,             
			nmmaecto: nmmaecto,	
			nrendere: nrendere,	
			nrcepend: nrcepend,			           
			nrdconta: nrdconta, 
			nrdrowid_rsp: nrdrowid_rsp,
			idseqttl: idseqttl, 
			cdufende: cdufende, 
			operacao_rsp: operacao_rsp,
			cpfprocu: normalizaNumero(cpfprocu), 
			nmrotina: nmrotina, 
			dtdenasc: dtdenasc,
			cdhabmen: cdhabmen,	
			permalte: aux_permalte, 
			validadt: validadt,
			cdrlcrsp: cdrlcrsp,
			arrayFilhos: arrayFilhos,
			redirect: "script_ajax"                             
		},                                                                          
		error: function(objAjax,responseError,objExcept) {                          
			hideMsgAguardo();														
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos",bloqueiaFundo(divRotina));
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos",bloqueiaFundo(divRotina));
			}
		}				
	});
}

function controlaLayoutResp(operacao_rsp) {	

	var largura = '575px';	
	var altura  = (in_array(operacao_rsp,['CT','AT','IT','SC',''])) ? '210px' : '470px';
	
	if (nmdatela == "CONTAS") {
		$('#divConteudoOpcao').css('width',largura);
	} else {
		divRotina.css('width',largura);	
	}
	
	$('#divConteudoOpcao').css('height',altura);

	
	if(nmrotina != 'MATRIC'){
	
		$('#divOpcoesDaOpcao1').css('height',altura);
		$('#divOpcoesDaOpcao1').css('width',largura);
		
	}

	// TABELA
	if ( in_array(operacao_rsp,['CT','AT','IT','SC','']) ) {
					
		if(nmrotina == "Responsavel Legal"){
					
			var divRegistro = $('div.divRegistros');		
			var tabela      = $('table', divRegistro );
			
			divRegistro.css('height','150px');
			
			var ordemInicial = new Array();
			ordemInicial = [[1,0]];
			
			var arrayLargura = new Array();
			arrayLargura[0] = '70px';
			arrayLargura[1] = '244px';
			arrayLargura[2] = '80px';
			
			var arrayAlinha = new Array();
			arrayAlinha[0] = 'right';
			arrayAlinha[1] = 'left';
			arrayAlinha[2] = 'right' ;
			arrayAlinha[3] = 'right' ;
					
			var metodoTabela = ( operacao_rsp != 'SC' ) ? 'controlaOperacaoResp(\'TA\')' : 'controlaOperacaoResp(\'CF\')' ; 
			tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
			
		}else{
			
			montaTabelaResp();
			formataTabelaResp();
			
		}
		
	// FORMULÁRIO
	} else {	
	
		// Conta e CPF
		var camposGrupo1  	= $('#nrdctato, #nrcpfcto','#frmRespLegal');
		var cConta  		= $('#nrdctato','#frmRespLegal');
		var cCPF    		= $('#nrcpfcto','#frmRespLegal');
		
		// Nome / Dt. Nasc. / Tp. Doc. / Nr. Doc./ Org. Emis. / UF / Dt. Emis. / Est. Civil / Sexo / Nacionalidade / Naturalidade / End.Residen. / Nro. / Comp. / Bairro / Cep / Cidade / UF / Mãe / Pai
		var camposGrupo2  	= $('#nmdavali,#dtnascto,#tpdocava,#cdufddoc,#cdestciv,#nrdocava,#cdoeddoc,#cdufende,#dtemddoc,#cdnacion,#dsnatura,#dsendere,#nrendere,#complend,#nmbairro,#nrcepend,#nmcidade,#nmmaecto,#nmpaicto,#vledvmto','#frmRespLegal');
        var cDsnacion       = $('#dsnacion','#frmRespLegal');
		var selectsGrupo2 	= $('select','#frmRespLegal');
		var sexo 		  	= $('input[name="cdsexcto"]','#frmRespLegal');
		var cdrlcrsp        = $('#cdrelacionamento','#frmRespLegal');
		
							
		// Sempre inicia com tudo bloqueado
		camposGrupo1.desabilitaCampo();
		camposGrupo2.desabilitaCampo();
        cDsnacion.desabilitaCampo();
		selectsGrupo2.desabilitaCampo();	
		sexo.desabilitaCampo();
		
		// Controla largura para formulário de responsavel 
		$('#nrdctato','#frmRespLegal').css('width','80px').addClass('conta pesquisa');
		$('#nmdavali','#frmRespLegal').css({'width':'290px'}).addClass('alpha').attr('maxlength','40');
		$('#cdufddoc,#cdestciv','#frmRespLegal').css({'width':'290px'});
		$('#nrcpfcto','#frmRespLegal').css({'width':'101px'}).addClass('cpf');
		$('#dtnascto,#dtemddoc','#frmRespLegal').css({'width':'101px'}).addClass('data');
		$('#cdoeddoc','#frmRespLegal').css({'width':'101px'}).addClass('alphanum').attr('maxlength','5');
		$('#tpdocava','#frmRespLegal').css({'width':'57px'});
		$('#nrdocava', '#frmRespLegal').css({ 'width': '230px' }).addClass('alphanum').attr('maxlength', '40');
		$('#cdnacion', '#frmRespLegal').css({ 'width': '50px' }).addClass('inteiro pesquisa').attr('maxlength', '16');
		$('#dsnacion', '#frmRespLegal').css({ 'width': '150px' }).addClass('alphanum').attr('maxlength', '16');
		$('#dsnatura','#frmRespLegal').css({'width':'202px'}).addClass('alphanum pesquisa').attr('maxlength','50');
		$('#nmpaicto,#nmmaecto','#frmRespLegal').css({'width':'444px'}).addClass('alpha').attr('maxlength','40');
		$('label[for="nrcpfcto"]','#frmRespLegal').css({'width':'253px'});	
		cdrlcrsp.css({'width':'200px'});
		
	
		// RÓTULOS - ENDEREÇO 
		var rCep	= $('label[for="nrcepend"]','#'+nomeFormResp);
		var rEnd	= $('label[for="dsendere"]','#'+nomeFormResp);
		var rNum	= $('label[for="nrendere"]','#'+nomeFormResp);
		var rCom	= $('label[for="complend"]','#'+nomeFormResp);
		var rBai	= $('label[for="nmbairro"]','#'+nomeFormResp);
		var rEst	= $('label[for="cdufende"]','#'+nomeFormResp);	
		var rCid	= $('label[for="nmcidade"]','#'+nomeFormResp);
		
		rCep.addClass('rotulo').css('width','70px');
		rEnd.addClass('rotulo-linha').css('width','35px');
		rNum.addClass('rotulo').css('width','70px');
		rCom.addClass('rotulo-linha').css('width','52px');
		rEst.addClass('rotulo').css('width','70px');
		rBai.addClass('rotulo-linha').css('width','52px');
		rCid.addClass('rotulo').css('width','70px');

		// CAMPOS - ENDEREÇO
		var cCep	= $('#nrcepend,','#'+nomeFormResp);
		var cEnd	= $('#dsendere,','#'+nomeFormResp);
		var cNum	= $('#nrendere,','#'+nomeFormResp);
		var cCom	= $('#complend,','#'+nomeFormResp);
		var cBai	= $('#nmbairro,','#'+nomeFormResp);
		var cEst	= $('#cdufende,','#'+nomeFormResp);	
		var cCid	= $('#nmcidade,','#'+nomeFormResp);

		cCep.addClass('cep pesquisa').css('width','70px').attr('maxlength','9');
		cEnd.addClass('alphanum').css('width','328px').attr('maxlength','40');
		cNum.addClass('numerocasa').css('width','70px').attr('maxlength','7');
		cCom.addClass('alphanum').css('width','328px').attr('maxlength','40');	
		cBai.addClass('alphanum').css('width','328px').attr('maxlength','40');	
		cEst.css('width','70px');	
		cCid.addClass('alphanum').css('width','456px').attr('maxlength','25');

		$('#nmmaecto,#nmpaicto','#'+nomeFormResp).css('width','454px');	
		
		var endDesabilita = $('#dsendere,#cdufende,#nmbairro,#nmcidade','#'+nomeFormResp);

		
		switch (operacao_rsp) {			
			// Caso é inclusão, limpar dados do formulário					
			case 'TI': 
				$("#frmRespLegal").limpaFormulario();				
				montaSelect('b1wgen0059.p','busca_estado_civil','cdestciv','cdestcvl','cdestcvl;dsestcvl','');	
				montaSelect('MATRIC','BUSCA_RLC_RESP_LEGAL','cdrelacionamento','cdrelacionamento','cdrelacionamento;dsrelacionamento','');				
				cConta.habilitaCampo();
				controlaLupasResp();
				break;
				
			// Caso é inclusão, apos a busca de dados pela conta ou pelo CPF 
			case 'TB':
				//Se o nº da conta for igual a 0 ou vazio então o formulario é desbloqueado para preenchimento 
				if ( ($("#nrdctato","#frmRespLegal").val() == '0') || ($("#nrdctato","#frmRespLegal").val() == '') ){
					camposGrupo2.habilitaCampo();
					selectsGrupo2.habilitaCampo();
					sexo.habilitaCampo();
					endDesabilita.desabilitaCampo();
				}
				cdrlcrsp.habilitaCampo().focus();
				controlaLupasResp();
				break;
				
			// Caso é alteração, se conta = 0, libera grupo 2 e 3, senão libera somente grupo 3 	
			case 'TA': 		

				nrdctato_rsp = normalizaNumero( $('#nrdctato','#frmRespLegal').val() );
					
				if ( nrdctato_rsp == 0 ) {
					camposGrupo2.habilitaCampo();
					selectsGrupo2.habilitaCampo();		
					sexo.habilitaCampo();
					endDesabilita.desabilitaCampo();
				}
				cdrlcrsp.habilitaCampo();
				controlaLupasResp();
				break;
				
			// Caso é exclusão, lista o formulário e bloqueia todos os campos
			case 'TE': 
				camposGrupo1.desabilitaCampo();
				camposGrupo2.desabilitaCampo();
				selectsGrupo2.desabilitaCampo();
				sexo.desabilitaCampo();
				controlaLupasResp();
				break;
		}

		
		if (operacao_rsp == 'TI')  {			
			
			// Ao mudar Nr. Conta busca dados do representante
			cConta.unbind('keydown').bind('keydown', function(e){ 	
	
				if ( divError.css('display') == 'block' ) { return false; }		
			
				// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
				if ( e.keyCode == 13 ) {		
							
					// Armazena o número da conta na variável global
					nrconta = normalizaNumero( $(this).val() );
							
					// Verifica se o número da conta é vazio
					if ( nrconta == '' || nrconta == 0 ) { 
						cCPF.habilitaCampo();
						cConta.desabilitaCampo();
						cCPF.focus();
					} else {
						if ( !validaNroConta(nrconta) ) { showError('error','Conta/dv inválida.','Alerta - Ayllos','bloqueiaFundo(divRotina);'); return false; }
						nrdctato_rsp = nrconta;
						nrcpfcto = '';	
						controlaOperacaoResp('TB');
					}
					return false;
				}		
			});
			
											
			// Ao mudar CPF busca dados do Representanre
			cCPF.unbind('keydown').bind('keydown', function(e){ 	
	
				if ( divError.css('display') == 'block' ) { return false; }		
			
				// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
				if ( e.keyCode == 13 ) {		
							
					// Armazena o número da conta na variável global
					cpf = normalizaNumero( $(this).val() );
							
					// Verifica se o número da conta é vazio
					if ( cpf != '' || cpf != 0 ) { 
						
						if ( !validaCpfCnpj(cpf,1) ) { showError('error','CPF inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina);'); return false; }
							cpfaux_rsp = cpf;	
							nrcpfcto = cpf;
							nrdctato_rsp = 0;
							controlaOperacaoResp('TB');
					}
					return false;
				}		
			});
				
		}
		
		// Relacionamento com o 1. ttl
		cdrlcrsp.unbind("keydown").bind("keydown",function(e) {			
			if (e.keyCode == 13) {
				$("#btSalvar","#divBotoesFrmResp").trigger("click");
				return false;
			}	
		});	
				
		// Se operação é diferente de "I" monto os selects usados na tela
		if ( operacao_rsp != 'TI' ) {			
			montaSelect('b1wgen0059.p','busca_estado_civil','cdestciv','cdestcvl','cdestcvl;dsestcvl',$("input[name='cdestciv']","#frmRespLegal").val());				
			montaSelect('MATRIC','BUSCA_RLC_RESP_LEGAL','cdrelacionamento','cdrelacionamento','cdrelacionamento;dsrelacionamento',$("input[name='cdrelacionamento']","#frmRespLegal").val());						
		}
		
		layoutPadrao();		
		controlaFocoEnter("frmRespLegal");
		controlaLupasResp();
	}			
	
	$('#nrdctato','#frmRespLegal').trigger('blur');
	$('#nrcpfcto','#frmRespLegal').trigger('blur');
	$('#nrendere','#frmRespLegal').trigger('blur');
	$('#nrcepend','#frmRespLegal').trigger('blur');
	
	hideMsgAguardo();
	bloqueiaFundo(divRotina);	
	
	controlaBotoesResp(operacao_rsp);
	removeOpacidade('divOpcoesDaOpcao2'); 
	highlightObjFocus($('#frmRespLegal'));
	divRotina.centralizaRotinaH();
	controlaFocoResp(operacao_rsp);
	return false;
	
}

function controlaFocoResp(operacao_rsp){

	if (in_array(operacao_rsp,['CT','AT','IT',''])) {
		$('#btAlterar','#divBotoesResp').focus();
	} else if ( operacao_rsp == 'TC' ) {
		$('#btVoltar','#divBotoesResp').focus();
	} else if ( operacao_rsp == 'TB' ) {
		$('#nrdctato','#frmRespLegal').focus();
	} else {
		$('.campo:first','#frmRespLegal').focus();
	}
	
	return false;
	
}

function controlaLupasResp() {
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas;	
	var camposOrigem = 'nrcepend;dsendere;nrendere;complend;nrcxapst;nmbairro;cdufende;nmcidade';	
	
	// Atribui a classe lupa para os links de desabilita todos
	var lupas = $('a:not(.lupaBens)','#frmRespLegal');
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
					mostraPesquisaAssociado('nrdctato','frmRespLegal',divRotina);
					return false;					
				
				// Nacionalidade
				} else if ( campoAnterior == 'cdnacion' ) {
					bo			= 'b1wgen0059.p';
					procedure	= 'busca_nacionalidade';
					titulo      = 'Nacionalidade';
					qtReg		= '50';
					filtros 	= 'Codigo;cdnacion;30px;N;;N|Nacionalidade;dsnacion;200px;S;';
					colunas 	= 'Codigo;cdnacion;15%;left|Descrição;dsnacion;85%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina,'',nomeFormResp);
					return false;				
					
				// Naturalidade
				} else if ( campoAnterior == 'dsnatura' ) {
					bo			= 'b1wgen0059.p';
					procedure	= 'Busca_Naturalidade';
					titulo      = 'Naturalidade';
					qtReg		= '50';
					filtros 	= 'Naturalidade;dsnatura;200px;S;';
					colunas 	= 'Naturalidade;dsnatura;100%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina,'',nomeFormResp);
					return false;
				
				// Cep	
				} else if ( campoAnterior == 'nrcepend' ) {
					mostraPesquisaEndereco(nomeFormResp, camposOrigem, divRotina);
					return false;					
				} 				
			}
		}));
	});
	
	/*-------------------------------------*/
	/*   CONTROLE DAS BUSCA DESCRIÇÕES     */
	/*-------------------------------------*/
	$('#nrcepend','#'+nomeFormResp).buscaCEP(nomeFormResp, camposOrigem, divRotina);
	
    //  Nacionalidade
	$('#cdnacion','#'+nomeFormResp).unbind('change').bind('change',function() {
		procedure	= 'BUSCANACIONALIDADES';
		titulo      = ' Nacionalidade';
		filtrosDesc = '';
		buscaDescricao('ZOOM0001',procedure,titulo,$(this).attr('name'),'dsnacion',$(this).val(),'dsnacion',filtrosDesc,nomeFormResp);        
	return false;
	}); 
	
	return false;
}

function btLimparResp(){		
	
	cTodos = $('input, select','#frmContatos');
	cSelect = $('select','#frmContatos');
	cConta = $('#nrdctato','#frmContatos');
	cNome = $('#nmdavali','#frmContatos');
	
	$('#'+nomeFormResp).limpaFormulario();
	cTodos.desabilitaCampo();
	cSelect.desabilitaCampo();
	cConta.habilitaCampo();
	controlaPesquisas();
	controlaFocoResp(operacao_rsp);
		
	cConta.unbind('keydown').bind('keydown', function(e){ 	
	
		if ( divError.css('display') == 'block' ) { return false; }		
	
		// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
		if ( e.keyCode == 13 ) {		
					
			// Armazena o número da conta na variável global
			nrconta = normalizaNumero( $(this).val() );
					
			// Verifica se o número da conta é vazio
			if ( nrconta == '' || nrconta == 0 ) { 
				cTodos.habilitaCampo();
				cSelect.habilitaCampo();
				cConta.desabilitaCampo();
				cNome.focus();
			} else {
				if ( !validaNroConta(nrconta) ) { showError('error','Conta/dv inválida.','Alerta - Ayllos','bloqueiaFundo(divRotina);'); return false; }
				nrdctato_rsp = nrconta;
				controlaOperacaoResp('TB');
			}
			return false;
		}		
	});		
	
	return false;	
}

function retornaIndiceSelecionadoResp() {	
	
	indice = '';
	
	$('table > tbody > tr','div.divRegistros').each( function() {
		if ( $(this).hasClass('corSelecao') ) {	
			indice = $('#indarray', $(this) ).val();	
						
		}
	});	
	
	return indice;
}


function montaTabelaResp() {
	
	$('div.divRegistros').remove();
	$('table.tituloRegistros','#frmRegistros').remove();
	$('#frmRegistros').append('<div class="divRegistros"></div>');
	$('div.divRegistros','#frmRegistros').append('<table><thead><tr><th>Conta/dv</th><th>Nome</th><th>C.P.F.</th><th>Documento</th></tr></thead><tbody></tbody></table>');
		
	var colunas = new Array();	
	
	for( var i in arrayFilhos ) {
		
		//Mostra apenas os registros não deletados
		if ( !arrayFilhos[i]['deletado'] && 
			 arrayFilhos[i]['nrctamen'] == ((nmrotina == 'Representante/Procurador' || (idseqttl == 2 && nmrotina != "Responsavel Legal" ) ) ? nrdctato : nrdconta) &&	 
			 arrayFilhos[i]['nrcpfmen'] == ((nmrotina == 'Representante/Procurador' || (idseqttl == 2 && nmrotina != "Responsavel Legal" ) ) ? ( (nrdctato == 0 ) ? normalizaNumero(nrcpfcgc_proc) : 0 ) : ( (nrdconta == 0 ) ? normalizaNumero(cpfprocu) : 0 ) )){
			
			// Monta o conteudo de cada coluna 
			var conta = (arrayFilhos[i]['cddctato'] == 0) ? 0 : mascara(arrayFilhos[i]['cddctato'],'####.###-#');
			
			colunas[0] = '<span>'+arrayFilhos[i]['nrdconta']+'</span>' + conta +'<input type="hidden" id="indarray" name="indarray" value="'+i+'" />' +'<input type="hidden" id="nrdrowid" name="nrdrowid" value="'+arrayFilhos[i]['nrdrowid']+'" />';
			colunas[1] = arrayFilhos[i]['nmrespon'];
			colunas[2] = (arrayFilhos[i]['nrcpfcgc'] == 0) ? 0 : mascara(normalizaNumero(arrayFilhos[i]['nrcpfcgc']),"###.###.###-##");
			colunas[3] = arrayFilhos[i]['nridenti'];
						
			// Agora monto as coluas com seus repectivos conteúdos
			$('div.divRegistros > table > tbody').append('<tr></tr>');										
			$('div.divRegistros > table > tbody > tr:last-child').append('<td>'+colunas[0]+'</td>').css({'text-transform':'uppercase'});
			$('div.divRegistros > table > tbody > tr:last-child').append('<td>'+colunas[1]+'</td>');
			$('div.divRegistros > table > tbody > tr:last-child').append('<td>'+colunas[2]+'</td>');
			$('div.divRegistros > table > tbody > tr:last-child').append('<td>'+colunas[3]+'</td>');
			
		}
	}
		
	return false;
	
}


function formataTabelaResp() {

	var divRegistro = $('div.divRegistros','#frmRegistros');		
	var tabela      = $('table', divRegistro );

	divRegistro.css({'height':'150px','border-bottom':'1px solid #777','padding-bottom':'2px'});

	var ordemInicial = new Array();
	    ordemInicial = [[1,0]];

	var arrayLargura = new Array();
		arrayLargura[0] = '70px';
		arrayLargura[1] = '244px';
		arrayLargura[2] = '80px';
		
	var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right' ;
		arrayAlinha[3] = 'right' ;
	
	var metodoTabela = ( operacao_rsp != 'SC' ) ? 'controlaOperacaoResp(\'TA\')' : 'controlaOperacaoResp(\'CF\')' ; 

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela ); 
	
	return false;
	
}


function carregaDadosResp() { 
	
	$('input[name="cdestciv"]','#frmRespLegal').val( arrayFilhos[indarray_rsp]['cdestciv'] );
	$('select[name="cdestciv"]','#frmRespLegal').val( arrayFilhos[indarray_rsp]['cdestciv'] );
	$('#nrdctato','#frmRespLegal').val( arrayFilhos[indarray_rsp]['nrdconta'] );
	$('#nrcpfcto','#frmRespLegal').val( arrayFilhos[indarray_rsp]['nrcpfcgc'] );
	$('#nmdavali','#frmRespLegal').val( arrayFilhos[indarray_rsp]['nmrespon'] );	
	$('#dtnascto','#frmRespLegal').val( arrayFilhos[indarray_rsp]['dtnascin'] );		
	$('#tpdocava','#frmRespLegal').val( arrayFilhos[indarray_rsp]['tpdeiden'] );	
	$('#nrdocava','#frmRespLegal').val( arrayFilhos[indarray_rsp]['nridenti'] );	
	$('#cdoeddoc','#frmRespLegal').val( arrayFilhos[indarray_rsp]['dsorgemi'] );	
	$('#cdufddoc','#frmRespLegal').val( arrayFilhos[indarray_rsp]['cdufiden'] );	
	$('#dtemddoc','#frmRespLegal').val( arrayFilhos[indarray_rsp]['dtemiden'] );
	
	if(arrayFilhos[indarray_rsp]['cddosexo'] == 1){
		 $("#sexoMas","#frmRespLegal").prop('checked',true);
	}else{
		if(arrayFilhos[indarray_rsp]['cddosexo'] == 2){
			$("#sexoFem","#frmRespLegal").prop('checked',true);
		}
	
	} 
		
	$('#cdsexcto','#frmRespLegal').val( arrayFilhos[indarray_rsp]['cddosexo'] );	
	$('#dsnacion','#frmRespLegal').val( arrayFilhos[indarray_rsp]['dsnacion'] );	
    $('#cdnacion','#frmRespLegal').val( arrayFilhos[indarray_rsp]['cdnacion'] );	
	$('#dsnatura','#frmRespLegal').val( arrayFilhos[indarray_rsp]['dsnatura'] );	
	$('#nrcepend','#frmRespLegal').val( arrayFilhos[indarray_rsp]['cdcepres'] );	
	$('#dsendere','#frmRespLegal').val( arrayFilhos[indarray_rsp]['dsendres'] );	
	$('#nrendere','#frmRespLegal').val( arrayFilhos[indarray_rsp]['nrendres'] );	
	$('#complend','#frmRespLegal').val( arrayFilhos[indarray_rsp]['dscomres'] );	
	
	$('#nmbairro','#frmRespLegal').val( arrayFilhos[indarray_rsp]['dsbaires'] );	
	$('#cdufende','#frmRespLegal').val( arrayFilhos[indarray_rsp]['dsdufres'] );	
	$('#nmcidade','#frmRespLegal').val( arrayFilhos[indarray_rsp]['dscidres'] );	
	$('#nmmaecto','#frmRespLegal').val( arrayFilhos[indarray_rsp]['nmmaersp'] );	
	$('#nmpaicto','#frmRespLegal').val( arrayFilhos[indarray_rsp]['nmpairsp'] );
	$('input[name="cdrelacionamento"]','#frmRespLegal').val( arrayFilhos[indarray_rsp]['cdrlcrsp'] );
		
}

function sincronizaArrayResp(){
	
	arrayBackup.length = 0;
	
	for ( i in arrayFilhos ){
	
		eval('var arrayAux'+i+' = new Object();');
		
		for ( campo in arrayFilhos[0] ){
		
			eval('arrayAux'+i+'[\''+campo+'\']= arrayFilhos['+i+'][\''+campo+'\'];');
			
		}
		
		eval('arrayBackup['+i+'] = arrayAux'+i+';');	
	}
	
	return false;
}


function rollBack(){

	arrayFilhos.length = 0;
		
	for ( i in arrayBackup ){
	
		eval('var arrayAux'+i+' = new Object();');
		
		for ( campo in arrayBackup[0] ){
		
			eval('arrayAux'+i+'[\''+campo+'\']= arrayBackup['+i+'][\''+campo+'\'];');
			
		}
		
		eval('arrayFilhos['+i+'] = arrayAux'+i+';');	
	}

	return false;
	
}

function controlaArrayResp(op){
	
	hideMsgAguardo();
	showMsgAguardo( 'Aguarde, processando ...' );
		
	switch (op) {	
		
		case 'AV': 
				
				conta = normalizaNumero( $('#nrdctato','#frmRespLegal').val() );
				cpfcgc = normalizaNumero( $('#nrcpfcto','#frmRespLegal').val() ) ;
				cddctato = ( $('#nrdctato','#frmRespLegal').val() == '' ) ? 0 : $('#nrdctato','#frmRespLegal').val();	
				
				arrayFilhos[indarray_rsp]['cdestciv'] = $('select[name="cdestciv"]','#frmRespLegal').val();
				arrayFilhos[indarray_rsp]['nrdconta'] = conta;
				arrayFilhos[indarray_rsp]['nrcpfcgc'] = cpfcgc;
				arrayFilhos[indarray_rsp]['nmrespon'] = $('#nmdavali','#frmRespLegal').val();
				arrayFilhos[indarray_rsp]['dtnascin'] = $('#dtnascto','#frmRespLegal').val();
				arrayFilhos[indarray_rsp]['tpdeiden'] = $('#tpdocava','#frmRespLegal').val();
				arrayFilhos[indarray_rsp]['nridenti'] = $('#nrdocava','#frmRespLegal').val();
				arrayFilhos[indarray_rsp]['dsorgemi'] = $('#cdoeddoc','#frmRespLegal').val();
				arrayFilhos[indarray_rsp]['cdufiden'] = $('#cdufddoc','#frmRespLegal').val();
				arrayFilhos[indarray_rsp]['dtemiden'] = $('#dtemddoc','#frmRespLegal').val();
				arrayFilhos[indarray_rsp]['cddctato'] = cddctato;    
				
				if ($("#sexoMas","#frmRespLegal").prop('checked')) {
					arrayFilhos[indarray_rsp]['cddosexo'] = 1;
				}else 
					if ($("#sexoFem","#frmRespLegal").prop('checked')) {
						arrayFilhos[indarray_rsp]['cddosexo'] = 2;
					}
								
				arrayFilhos[indarray_rsp]['dsnacion'] = $('#dsnacion','#frmRespLegal').val();
                arrayFilhos[indarray_rsp]['cdnacion'] = $('#cdnacion','#frmRespLegal').val();
				arrayFilhos[indarray_rsp]['dsnatura'] = $('#dsnatura','#frmRespLegal').val();	
				arrayFilhos[indarray_rsp]['cdcepres'] = normalizaNumero($('#nrcepend','#frmRespLegal').val());	
				arrayFilhos[indarray_rsp]['dsendres'] = $('#dsendere','#frmRespLegal').val();	
				arrayFilhos[indarray_rsp]['nrendres'] = $('#nrendere','#frmRespLegal').val();	
				arrayFilhos[indarray_rsp]['dscomres'] = $('#complend','#frmRespLegal').val();	
				arrayFilhos[indarray_rsp]['dsbaires'] = $('#nmbairro','#frmRespLegal').val();	
				arrayFilhos[indarray_rsp]['dsdufres'] = $('#cdufende','#frmRespLegal').val();	
				arrayFilhos[indarray_rsp]['dscidres'] = $('#nmcidade','#frmRespLegal').val();	
				arrayFilhos[indarray_rsp]['nmmaersp'] = $('#nmmaecto','#frmRespLegal').val();	
				arrayFilhos[indarray_rsp]['nmpairsp'] = $('#nmpaicto','#frmRespLegal').val();
				arrayFilhos[indarray_rsp]['cdrlcrsp'] = $('select[name="cdrelacionamento"]','#frmRespLegal').val();
				arrayFilhos[indarray_rsp]['cddopcao'] = 'A';
				
				permalte = false;
											
				hideMsgAguardo();
				bloqueiaFundo(divRotina);
				criaTabela = 'A';
				
				return false; 	
				break;
		
		case 'IV': 
								
				i = arrayFilhos.length;
				
				conta = normalizaNumero( $('#nrdctato','#frmRespLegal').val() );
				cpfcgc = normalizaNumero( $('#nrcpfcto','#frmRespLegal').val() ) ;
				cddctato = ( $('#nrdctato','#frmRespLegal').val() == '' ) ? 0 : $('#nrdctato','#frmRespLegal').val();	
				cdrlcrsp = $('select[name="cdrelacionamento"]','#frmRespLegal').val(); 	
												
				eval('var regFilho'+i+' = new Object();');
				
				eval('regFilho'+i+'["nrdconta"] = \''+conta+'\';');
				eval('regFilho'+i+'["cdcooper"] = \''+cooperativa+'\';');
				eval('regFilho'+i+'["cddctato"] = \''+normalizaNumero(cddctato)+'\';');
				eval('regFilho'+i+'["nrcpfcgc"] = \''+cpfcgc+'\';');
				eval('regFilho'+i+'["cdrlcrsp"] = \''+cdrlcrsp+ '\';');
				
				if(nmrotina == "Identificacao"){
				
					eval('regFilho'+i+'["nrctamen"] = \''+nrdconta+'\';'); 
					eval('regFilho'+i+'["idseqmen"] = \''+idseqttl+'\';');
					
					if(nrdconta == 0){
						eval('regFilho'+i+'["nrcpfmen"] = \''+normalizaNumero(cpfprocu)+'\';'); 
					}else{
						eval('regFilho'+i+'["nrcpfmen"] = 0;'); 
					}
									
				}else if(nmrotina == 'Responsavel Legal'){
				
					eval('regFilho'+i+'["nrctamen"] = \''+nrdconta+'\';'); 
					eval('regFilho'+i+'["idseqmen"] = \''+idseqttl+'\';');
					
					if(nrdconta == 0){
						eval('regFilho'+i+'["nrcpfmen"] = \''+normalizaNumero(cpfprocu)+'\';'); 
					}else{
						eval('regFilho'+i+'["nrcpfmen"] = 0;'); 
					}
					
				}else if(nmrotina == 'Representante/Procurador'){
				
					eval('regFilho'+i+'["nrctamen"] = \''+nrdctato+'\';'); 
					eval('regFilho'+i+'["idseqmen"] = \''+nrctremp+'\';');
					
					if(nrdctato == 0){
						eval('regFilho'+i+'["nrcpfmen"] = \''+normalizaNumero(nrcpfcgc_proc)+'\';');
					}else{
						eval('regFilho'+i+'["nrcpfmen"] = 0;');
					}
					
				}else if(nmrotina == 'MATRIC'){
					
					if(idseqttl == 2){
						
						eval('regFilho'+i+'["nrctamen"] = \''+nrdctato+'\';'); 
						eval('regFilho'+i+'["idseqmen"] = \''+nrctremp+'\';');
												
						if(nrdctato == 0){
							eval('regFilho'+i+'["nrcpfmen"] = \''+normalizaNumero(nrcpfcgc_proc)+'\';'); 
						}else{
							eval('regFilho'+i+'["nrcpfmen"] = 0;'); 
						}
						
						
					}else{ 
						
						eval('regFilho'+i+'["nrctamen"] = \''+nrdconta+'\';'); 
						eval('regFilho'+i+'["idseqmen"] = \''+idseqttl+'\';');
						eval('regFilho'+i+'["nrcpfmen"] = \''+normalizaNumero(nrcpfcgc)+'\';'); 
						
						if(nrdconta == 0){
							eval('regFilho'+i+'["nrcpfmen"] = \''+normalizaNumero(nrcpfcgc)+'\';'); 
						}else{
							eval('regFilho'+i+'["nrcpfmen"] = 0;'); 
						}
						
					}
														
				}
										
				eval('regFilho'+i+'["nmrespon"] = $(\'#nmdavali\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["nridenti"] = $(\'#nrdocava\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["tpdeiden"] = $(\'#tpdocava\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["dsorgemi"] = $(\'#cdoeddoc\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["cdufiden"] = $(\'#cdufddoc\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["dtemiden"] = $(\'#dtemddoc\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["dtnascin"] = $(\'#dtnascto\',\'#frmRespLegal\').val();');
				
				if ($("#sexoMas","#frmRespLegal").prop('checked')) {
					eval('regFilho'+i+'["cddosexo"] = 1');
				}else 
					if ($("#sexoFem","#frmRespLegal").prop('checked')) {
							eval('regFilho'+i+'["cddosexo"] = 2');
								
					}
								
				eval('regFilho'+i+'["cdestciv"] = $(\'select[name="cdestciv"]\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["cdnacion"] = $(\'#cdnacion\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["dsnacion"] = $(\'#dsnacion\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["dsnatura"] = $(\'#dsnatura\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["cdcepres"] = normalizaNumero($(\'#nrcepend\',\'#frmRespLegal\').val());');
				eval('regFilho'+i+'["dsendres"] = $(\'#dsendere\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["nrendres"] = $(\'#nrendere\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["dscomres"] = $(\'#complend\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["dsbaires"] = $(\'#nmbairro\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["dscidres"] = $(\'#nmcidade\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["dsdufres"] = $(\'#cdufende\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["nmpairsp"] = $(\'#nmpaicto\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["nmmaersp"] = $(\'#nmmaecto\',\'#frmRespLegal\').val();');
				eval('regFilho'+i+'["deletado"] = false;');
				eval('regFilho'+i+'["cddopcao"] = \'I\';');
				
				eval('arrayFilhos['+i+'] = regFilho'+i+';');
				
				permalte = false;				
													
				hideMsgAguardo();
				bloqueiaFundo(divRotina);
				criaTabela = 'I';
				
				return false;	
				break;
		
		case 'EV': 
				arrayFilhos[indarray_rsp]['cddopcao'] = 'E' ;
				arrayFilhos[indarray_rsp]['deletado'] = true ;
				
				permalte = false;
				
				hideMsgAguardo();
				return false;
				break;                                                                                             
		                                                                                                       
		default: 
		
		hideMsgAguardo();
		return false; 
		break;                                                                          
	}
	
	return false;
	
}

function controlaBotoesResp(operacao_rsp){

	//Esconde os botões da tabela
	$('#btVoltar','#divBotoesResp').css('display','none');
	$('#btAlterar','#divBotoesResp').css('display','none');
	$('#btConsultar','#divBotoesResp').css('display','none');
	$('#btExcluir','#divBotoesResp').css('display','none');
	$('#btIncluir','#divBotoesResp').css('display','none');
	$('#btConcluir','#divBotoesResp').css('display','none');
	$('#btVoltarCns','#divBotoesResp').css('display','none');
	$('#btConsultar','#divBotoesResp').css('display','none');
	
	//Esconde os botões do formulário
	$('#btVoltar','#divBotoesFrmResp').css('display','none');
	$('#btSalvar','#divBotoesFrmResp').css('display','none');
	$('#btLimpar','#divBotoesFrmResp').css('display','none');

		
	//Controla os botões da tabela
	if(nmrotina == 'Responsavel Legal'){ 
	
		$('#btVoltar','#divBotoesResp').css('display','inline');
		
		if (nmdatela == "MATRIC") {
			
			$('#btConcluir','#divBotoesResp').unbind('click').bind('click', function (){
				
                //Alterado, pois deverá validar responsavel legal apos salvar os dados, devido a replicação de dados da pessoa. 
                controlaOperacao("AR");
			});
			
			$('#btConcluir','#divBotoesResp').css('display','inline');
			
		}
		
		if ( operacao_rsp != 'SC' ){
		
			if (menorida == 'yes'){
							
				$('#btConsultar','#divBotoesResp').unbind('click').bind('click', function (){
					controlaOperacaoResp('TC');
				});
			
				$('#btAlterar','#divBotoesResp').css('display','inline');
				$('#btConsultar','#divBotoesResp').css('display','inline');
				$('#btExcluir','#divBotoesResp').css('display','inline');
				$('#btIncluir','#divBotoesResp').css('display','inline');
				
			}else{
				$('#btExcluir','#divBotoesResp').css('display','inline');
				
			}
			
		}else{
			$('#btConsultar','#divBotoesResp').unbind('click').bind('click', function (){
				controlaOperacaoResp('CF');
			});
			
			$('#btConsultar','#divBotoesResp').css('display','inline');
		}
	
	}else if(nmrotina == 'Identificacao'){
	
			if (menorida == 'yes') {
				
				$('#btConsultar','#divBotoesResp').unbind('click').bind('click', function (){
					controlaOperacaoResp('TC');
				});
				
				$('#btAlterar','#divBotoesResp').css('display','inline');
				$('#btConsultar','#divBotoesResp').css('display','inline');
				$('#btExcluir','#divBotoesResp').css('display','inline');
				$('#btIncluir','#divBotoesResp').css('display','inline');
				$('#btConcluir','#divBotoesResp').css('display','inline');
				
				$('#btConcluir','#divBotoesResp').unbind('click').bind('click', function (){
					voltaDiv('3','0','3','IDENTIFICA&Ccedil;&Atilde;O F&Iacute;SICA','Identifica&ccetil;&atilde;o','345','538');
				});
				
			}else{
									
				$('#btConcluir','#divBotoesResp').unbind('click').bind('click', function (){
					voltaDiv('3','0','3','IDENTIFICA&Ccedil;&Atilde;O F&Iacute;SICA','Identifica&ccetil;&atilde;o','345','538');
				});
				
				$('#btExcluir','#divBotoesResp').css('display','inline');
				$('#btConcluir','#divBotoesResp').css('display','inline');
								
			}
			
			
	}else if(nmrotina == 'Representante/Procurador' && nrdconta != 0){
	
			if( ope_rotinaant != 'CF' ){
		
				if(menorida == 'yes'){		
					
					$('#btConcluir','#divBotoesResp').unbind('click').bind('click', function (){
						voltaDiv('3','0','3','REPRESENTANTE/PROCURADOR','Representante/Procurador','620','565');
					});
					
					$('#btConsultar','#divBotoesResp').unbind('click').bind('click', function (){
						controlaOperacaoResp('TC');
					});
					
					$('#btAlterar','#divBotoesResp').css('display','inline');
					$('#btConsultar','#divBotoesResp').css('display','inline');
					$('#btExcluir','#divBotoesResp').css('display','inline');
					$('#btIncluir','#divBotoesResp').css('display','inline');
					$('#btConcluir','#divBotoesResp').css('display','inline');
										
				}else{
					$('#btConcluir','#divBotoesResp').unbind('click').bind('click', function (){
						voltaDiv('3','0','3','REPRESENTANTE/PROCURADOR','Representante/Procurador','620','565');
					});
					
					$('#btExcluir','#divBotoesResp').css('display','inline');
					$('#btConcluir','#divBotoesResp').css('display','inline');
				}
				
			}else{
				$('#btVoltarCns','#divBotoesResp').unbind('click').bind('click', function (){
					voltaDiv('3','0','3','REPRESENTANTE/PROCURADOR','Representante/Procurador','620','565');
				});
					
				$('#btConsultar','#divBotoesResp').unbind('click').bind('click', function (){
					controlaOperacaoResp('CF');
				});
				
				$('#btVoltarCns','#divBotoesResp').css('display','inline');
				$('#btConsultar','#divBotoesResp').css('display','inline');
			}
	
	}else if(nmrotina == 'Representante/Procurador' && nrdconta == 0){
				
			if( ope_rotinaant != 'CF' ){
		
				if(menorida == 'yes') {
					
					$('#btConcluir','#divBotoesResp').unbind('click').bind('click', function (){
						voltaDiv('3','0','3','REPRESENTANTE/PROCURADOR','Representante/Procurador','620','565');
					});
					
					$('#btConsultar','#divBotoesResp').unbind('click').bind('click', function (){
						controlaOperacaoResp('TC');
					});
										
					$('#btAlterar','#divBotoesResp').css('display','inline');
					$('#btConsultar','#divBotoesResp').css('display','inline');
					$('#btExcluir','#divBotoesResp').css('display','inline');
					$('#btIncluir','#divBotoesResp').css('display','inline');
					$('#btConcluir','#divBotoesResp').css('display','inline');
					
				}else{
					
					$('#btConcluir','#divBotoesResp').unbind('click').bind('click', function (){
						voltaDiv('3','0','3','REPRESENTANTE/PROCURADOR','Representante/Procurador','620','565');
					});
					
					$('#btExcluir','#divBotoesResp').css('display','inline');
					$('#btConcluir','#divBotoesResp').css('display','inline');
					
				}
				
			}else{
				
				$('#btVoltarCns','#divBotoesResp').unbind('click').bind('click', function (){
					voltaDiv('3','0','3','REPRESENTANTE/PROCURADOR','Representante/Procurador','620','565');
				});
					
				$('#btConsultar','#divBotoesResp').unbind('click').bind('click', function (){
					controlaOperacaoResp('CF');
				});
				
				$('#btVoltarCns','#divBotoesResp').css('display','inline');
				$('#btConsultar','#divBotoesResp').css('display','inline');
				
			}
			
	}else if(nmrotina == 'MATRIC'){
		
			if(idseqttl == 2){

				if(operacao_proc != "SC"){
				
					if( ope_rotinaant != 'FC' ){
				
						if(menorida == 'yes'){
							
							$('#btConcluir','#divBotoesResp').unbind('click').bind('click', function (){
																
								voltaDiv('3','2','3','REPRESENTANTE/PROCURADOR','Representante/Procurador','620','630');
								
							});
																		
							$('#btConsultar','#divBotoesResp').unbind('click').bind('click', function (){
								controlaOperacaoResp('TC');
							});
											
							$('#btAlterar','#divBotoesResp').css('display','inline');
							$('#btConsultar','#divBotoesResp').css('display','inline');
							$('#btExcluir','#divBotoesResp').css('display','inline');
							$('#btIncluir','#divBotoesResp').css('display','inline');
							$('#btConcluir','#divBotoesResp').css('display','inline');
							
						}else{
							
							$('#btConcluir','#divBotoesResp').unbind('click').bind('click', function (){
								fechaRotina(divRotina);
								
								if(aux_cdrotina == 'I'){
									controlaOperacaoProc('IV');
								}else if(aux_cdrotina == 'A'){
									controlaOperacaoProc('AV');
								}
															
							});
							
							$('#btExcluir','#divBotoesResp').css('display','inline');
							$('#btConcluir','#divBotoesResp').css('display','inline');
							
						}
						
					}else{
						
						$('#btVoltarCns','#divBotoesResp').unbind('click').bind('click', function (){
							
							voltaDiv('3','0','3','REPRESENTANTE/PROCURADOR','Representante/Procurador','620','630');
											
						});
							
						$('#btConsultar','#divBotoesResp').unbind('click').bind('click', function (){
							controlaOperacaoResp('CF');
						});
						
						$('#btVoltarCns','#divBotoesResp').css('display','inline');
						$('#btConsultar','#divBotoesResp').css('display','inline');
						
					}
					
				}else{
				
					$('#btVoltarCns','#divBotoesResp').unbind('click').bind('click', function (){
						
						voltaDiv('3','1','3','REPRESENTANTE/PROCURADOR','Representante/Procurador','620','630');
									
					});
						
					$('#btConsultar','#divBotoesResp').unbind('click').bind('click', function (){
						controlaOperacaoResp('CF');
					});
					
					$('#btVoltarCns','#divBotoesResp').css('display','inline');
					$('#btConsultar','#divBotoesResp').css('display','inline');

				}
				
			}else{
					
				if( ope_rotinaant != 'FC' ){
				
					if(menorida == 'yes'){
													
						$('#btConcluir','#divBotoesResp').unbind('click').bind('click', function (){
						
							fechaRotina(divRotina);
									
							verrespo = true;
							
							if(aux_cdrotina == 'CI'){
								controlaOperacao('IV');
							}else if(aux_cdrotina == 'CA'){
								controlaOperacao('AV');
							}
							
						});
						
													
						$('#btConsultar','#divBotoesResp').unbind('click').bind('click', function (){
							controlaOperacaoResp('TC');
						});
												
						$('#btAlterar','#divBotoesResp').css('display','inline');
						$('#btConsultar','#divBotoesResp').css('display','inline');
						$('#btExcluir','#divBotoesResp').css('display','inline');
						$('#btIncluir','#divBotoesResp').css('display','inline');
						$('#btConcluir','#divBotoesResp').css('display','inline');
						
					}else{
												
						$('#btConcluir','#divBotoesResp').unbind('click').bind('click', function (){
						
							fechaRotina(divRotina);
							
							if(aux_cdrotina == 'CI'){
								controlaOperacao('IV');
							}else if(aux_cdrotina == 'CA'){
								controlaOperacao('AV');
							}
							
						});
					
						
						$('#btExcluir','#divBotoesResp').css('display','inline');
						$('#btConcluir','#divBotoesResp').css('display','inline');
						
					}
					
				}else{
										
					$('#btVoltarCns','#divBotoesResp').unbind('click').bind('click', function (){
									
						fechaRotina(divRotina);
									
					});
						
					$('#btConsultar','#divBotoesResp').unbind('click').bind('click', function (){
						controlaOperacaoResp('CF');
					});
					
					$('#btVoltarCns','#divBotoesResp').css('display','inline');
					$('#btConsultar','#divBotoesResp').css('display','inline');
					
				}
			
			}
			
	}
		
	//Controla os botoes do formulário
	if( operacao_rsp == 'CF' ){
		
		$('#btVoltar','#divBotoesFrmResp').unbind('click').bind('click', function (){
			controlaOperacaoResp(operacao);
					
		});
				
		$('#btVoltar','#divBotoesFrmResp').css('display','inline');
		
	}else if( operacao_rsp == 'TC' ){
	
		$('#btVoltar','#divBotoesFrmResp').unbind('click').bind('click', function (){
			controlaOperacaoResp('CT');
			
		});

		$('#btVoltar','#divBotoesFrmResp').css('display','inline');
		
	}else if( operacao_rsp == 'TA' ){
		
		$('#btVoltar','#divBotoesFrmResp').unbind('click').bind('click', function (){
			controlaOperacaoResp('AT');
			
		});

		$('#btVoltar','#divBotoesFrmResp').css('display','inline');
		
		if(nmrotina == "Identificacao" || nmrotina == "Representante/Procurador" || nmrotina == "MATRIC"){
		
			$('#btSalvar','#divBotoesFrmResp').unbind('click').bind('click', function (){
				sincronizaArrayResp();
				controlaArrayResp('AV');
				showConfirmacao('Deseja confirmar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacaoResp(\'AV\');','rollBack();bloqueiaFundo(divRotina);','sim.gif','nao.gif');
				
			});
	
			$('#btSalvar','#divBotoesFrmResp').css('display','inline');
			
		}else{
							
			$('#btSalvar','#divBotoesFrmResp').unbind('click').bind('click', function (){
				controlaOperacaoResp('AV');
				
			});
	
			$('#btSalvar','#divBotoesFrmResp').css('display','inline');
		}
		
		
	}else if( operacao_rsp == 'TI' ){
					
		$('#btVoltar','#divBotoesFrmResp').unbind('click').bind('click', function (){
			controlaOperacaoResp('IT');
			
		});
		
		$('#btLimpar','#divBotoesFrmResp').unbind('click').bind('click', function (){
			controlaLayoutResp('TI');
			
		});

		$('#btVoltar','#divBotoesFrmResp').css('display','inline');
		$('#btLimpar','#divBotoesFrmResp').css('display','inline');

			
		if(nmrotina == "Identificacao" || nmrotina == "Representante/Procurador" || nmrotina == "MATRIC"){
			
			$('#btSalvar','#divBotoesFrmResp').unbind('click').bind('click', function (){
				showConfirmacao('Deseja confirmar inclus&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacaoResp(\'IV\');','bloqueiaFundo(divRotina);','sim.gif','nao.gif');
				
			});
	
			$('#btSalvar','#divBotoesFrmResp').css('display','inline');
				
		}else{
			
			$('#btSalvar','#divBotoesFrmResp').unbind('click').bind('click', function (){
				controlaOperacaoResp('IV');
				
			});
	
			$('#btSalvar','#divBotoesFrmResp').css('display','inline');
		}
		
		
	}else if( operacao_rsp == 'TB' ){
	
		$('#btVoltar','#divBotoesFrmResp').unbind('click').bind('click', function (){
			controlaOperacaoResp('IT');
			
		});
		
		$('#btLimpar','#divBotoesFrmResp').unbind('click').bind('click', function (){
			controlaLayoutResp('TI');
			
		});
			
		$('#btVoltar','#divBotoesFrmResp').css('display','inline');
		$('#btLimpar','#divBotoesFrmResp').css('display','inline');
			
		if(nmrotina == "Identificacao" || nmrotina == "Representante/Procurador" || nmrotina == "MATRIC"){
			
			$('#btSalvar','#divBotoesFrmResp').unbind('click').bind('click', function (){
				sincronizaArrayResp();
				controlaArrayResp('IV');
				showConfirmacao('Deseja confirmar inclus&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacaoResp(\'IV\');','rollBack();bloqueiaFundo(divRotina);','sim.gif','nao.gif');
				
			});
	
			$('#btSalvar','#divBotoesFrmResp').css('display','inline');
			
		}else{
			
			$('#btSalvar','#divBotoesFrmResp').unbind('click').bind('click', function (){
				controlaOperacaoResp('IV');
				
			});
			
			$('#btSalvar','#divBotoesFrmResp').css('display','inline');
				
		}
		
	}

}

// Função para voltar para o div anterior conforme parâmetros
function voltaDiv(esconder,mostrar,qtdade,titulo,rotina,novotam,novalar) {	

	var tamanho = 0;
	var largura = 0;
	
	if (rotina != undefined && rotina != "") {
	
		// Executa script de alteração de nome da rotina na seção através de ajax
		$.ajax({		
			type: "POST",
			url: UrlSite + "includes/responsavel_legal/altera_secao_nmrotina.php",
			data: {
				nmrotina: rotina
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		});	
		
	}
	
	
	if(novotam == "undefined" || novotam == 0){
		tamanho = 345;
	}else{
		tamanho = novotam;
		
	}
	
	if(novalar == "undefined" || novalar == 0){
		largura = 538;
	}else{
		largura = novalar;
		
	}
	
		
	if (titulo != undefined || titulo != "") {
	
		$("#tdTitRotina").html(titulo);
		
	}
	
	if(nmrotina != 'MATRIC'){
	
		$("#divRotina").css("height",tamanho);
		$("#divRotina").css("width",largura);
				
	}
	
	if(mostrar == 0){
	
		for (var i = 1; i <= qtdade;i++) {
			$("#divOpcoesDaOpcao"+i).css("display","none");
						
		}		
		
		if(nmrotina != 'MATRIC'){
			$("#divConteudoOpcao").css("display","block");
		}
		
	}else{
	
		if(nmrotina != 'MATRIC'){
			$("#divConteudoOpcao").css("display","none");
		}else{
			$("#divConteudoOpcao").css("display","block");
		}
		
		for (var i = 1; i <= qtdade;i++) {
			$("#divOpcoesDaOpcao"+i).css("display",(mostrar == i ? "block" : "none"));			
		}
		
	}
			
	if(nmrotina == "Identificacao"){
	
		if(operacao == 'IV'){
		
			verrespo =  true;
			controlaOperacao('IV');
					
		}else{
			if(operacao == 'AV'){
			
				verrespo =  true;
				controlaOperacao('AV');
				
			}	
			
		}
		
	}else if(nmrotina == "Representante/Procurador" ){
				
		if(operacao_proc == 'IV'){
			verrespo = true;
			permalte = true;
			controlaOperacaoProc('IV');
					
		}else if(operacao_proc == 'AV'){
				verrespo = true;
				permalte = true;
				controlaOperacaoProc('AV');
			
		}else{
		
			controlaLayoutProc("CF");
			
		}
		
	}else if(nmrotina == "MATRIC"){
			
		verrespo = true;
		permalte = true;				
				
		if(operacao_proc != "SC"){
						
			if(operacao_proc == "IV"){
				controlaOperacaoProc('IV');
			}else if(operacao_proc == "AV"){
				controlaOperacaoProc('AV');
			}
									
		}else{
		
			controlaLayoutProc("CF");
			
		}
		
	}
	
}

	
function voltarRotina() {
	acessaOpcaoAbaDados(6,0,'@');
}

function proximaRotina () {
	acessaOpcaoAbaDados(6,2,'@');			
}