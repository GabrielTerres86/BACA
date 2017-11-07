/*!
 * FONTE        : identificacao_juridica.js
 * CRIAÇÃO      : Alexandre Scola (DB1)
 * DATA CRIAÇÃO : Janeiro/2010 
 * OBJETIVO     : Biblioteca de funções na rotina Identificação Jurídica da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [09/02/2010] Rodolpho Telmo  (DB1)     : Retirada das funções de busca descrição e pesquisa. 
 *                                               Estas funções se tornaram genéricas, e agora se encontrar no arquivo pesquisa.js na pasta scrits/pesquisa.
 * 002: [24/03/2010] Rodolpho Telmo  (DB1)     : Adequação da tela ao novo padrão. Criação das funções "controlaLayout" e "controlaLupas"
 * 003: [26/04/2010] Rodolpho Telmo  (DB1)     : Retirada função "revisaoCadastral", agora se encontra no arquivo funcoes.js
 * 004: [06/09/2011] David (CECRED)            : Ajuste no evento onChange do campo Ramo Atividade. Não estava passando o setor economico no filtro.
 * 005: [06/02/2012] Tiago (CECRED)            : Ajuste para não chamar 2 vezes a função mostraPesquisa.
 * 006: [23/07/2015] Gabriel (RKAM)            : Reformulacao Cadastral.
 * 007: [03/12/2015] Jaison/Andrino  (CECRED)  : Adicao do campo flserasa na pesquisa generica de BUSCA_CNAE.
 * 008: [14/09/2016] Kelvin (CECRED) 		   : Ajuste feito para resolver o problema relatado no chamado 506554.
 * 009: [25/10/2016] Tiago (CECRED)            : Tratamentos da melhoria 310.
 * 010: [13/07/2017] Diogo (M410)         	   : Incluido campo Identificador do Regime tributário 'idregtrb'
 * 011: [04/08/2017] Adriano (CECRED)          : Ajuste para utilizar a package ZOOM0001 para busca o código cnae.       
 * 012: [12/08/2017] Lombardi                  : Criada a função dossieDigidoc.	PRJ339 CRM
 * 013: [06/10/2017] Kelvin (CECRED)           : Adicionado o campo Nome da conta (PRJ339 - Kelvin).
 */

var contWin = 0;  // Variável para contagem do número de janelas abertas para impressão de termos
var flgContinuar = false;     // Controle botao Continuar	


function acessaOpcaoAba(nrOpcoes,id,opcao) {  
	
	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, carregando...');
	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da opção
			$('#linkAba' + id).attr('class','txtBrancoBold');
			$('#imgAbaEsq' + id).attr('src',UrlImagens + 'background/mnu_sle.gif');				
			$('#imgAbaDir' + id).attr('src',UrlImagens + 'background/mnu_sld.gif');
			$('#imgAbaCen' + id).css('background-color','#969FA9');
			continue;			
		}
		
		$('#linkAba' + i).attr('class','txtNormalBold');
		$('#imgAbaEsq' + i).attr('src',UrlImagens + 'background/mnu_nle.gif');			
		$('#imgAbaDir' + i).attr('src',UrlImagens + 'background/mnu_nld.gif');
		$('#imgAbaCen' + i).css('background-color','#C6C8CA');
	}

	/*inpessoa 3 não tem idseqttl, então para não passar null
	  na requisição, passamos 0 para não gerar problemas.*/
	if (inpessoa == 3)
		idseqttl = 0;

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		dataType: 'html',
		url: UrlSite + 'telas/contas/identificacao_juridica/principal.php',
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
				
			} else {
				eval( response );
				controlaFoco( operacao );
			}
			return false;
		}				
	}); 		
}

function controlaOperacao(operacao){
	
	if ( (operacao == 'CA') && (flgAlterar != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
	
	var mensagem = '';
	switch (operacao) {
		case 'CA': // Consulta para Alteração
			mensagem = 'abrindo altera&ccedil;&atilde;o';
			cddopcao = 'A';
			break;
		case 'AC': showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');return false;break;
		case 'AV': // Chamar o manterRotina  naS 02 situacoes
		case 'VA': manterRotina(operacao);return false;			
		default: 
			mensagem = 'carregando';	
			cddopcao = 'C';			
			break;
	}	
	showMsgAguardo('Aguarde, ' + mensagem + '...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/identificacao_juridica/principal.php', 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			operacao: operacao,
			flgcadas: flgcadas,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
			} else {
				eval( response );
				controlaFoco( operacao );
			}
			return false;
		}				
	});			
}

function manterRotina(operacao) {
	
	hideMsgAguardo();		
	
	var mensagem = '';
	
	switch (operacao) {	
		case 'AV': mensagem = 'validando ';break;
		case 'VA': mensagem = 'salvando ';break;
		default: return false; break;
	}
	
	showMsgAguardo('Aguarde, ' + mensagem + '...');

	// Recebendo valores do formulário 
	nmfatasi = trim($('#nmfatasi','#frmDadosIdentJuridica').val());
	dtcnscpf = $('#dtcnscpf','#frmDadosIdentJuridica').val();
	cdsitcpf = $('#cdsitcpf','#frmDadosIdentJuridica').val();
	cdnatjur = $('#cdnatjur','#frmDadosIdentJuridica').val();
	qtfilial = trim($('#qtfilial','#frmDadosIdentJuridica').val());
	qtfuncio = trim($('#qtfuncio','#frmDadosIdentJuridica').val());
	dtiniatv = $('#dtiniatv','#frmDadosIdentJuridica').val();
	cdseteco = $('#cdseteco','#frmDadosIdentJuridica').val();
	cdrmativ = $('#cdrmativ','#frmDadosIdentJuridica').val();
	dsendweb = trim($('#dsendweb','#frmDadosIdentJuridica').val());
	nmtalttl = trim($('#nmtalttl','#frmDadosIdentJuridica').val());
	qtfoltal = trim($('#qtfoltal','#frmDadosIdentJuridica').val());
	dtcadass = trim($('#dtcadass','#frmDadosIdentJuridica').val());
	cdcnae   = trim($('#cdcnae','#frmDadosIdentJuridica').val());
	nrlicamb = $('#nrlicamb', '#frmDadosIdentJuridica').val();
	dtvallic = $('#dtvallic', '#frmDadosIdentJuridica').val();
	idregtrb = $('#idregtrb', '#frmDadosIdentJuridica').val();
	inpessoa = $('#inpessoa', '#frmDadosIdentJuridica').val();
	inpessoa = $('#inpessoa', '#frmDadosIdentJuridica').val();
	nmctajur = removeCaracteresInvalidos($('#nmctajur', '#frmDadosIdentJuridica').val());

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/identificacao_juridica/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, nmfatasi: nmfatasi, dtcnscpf: dtcnscpf, 
			cdsitcpf: cdsitcpf, cdnatjur: cdnatjur, qtfilial: qtfilial, qtfuncio: qtfuncio,
			dtiniatv: dtiniatv, cdseteco: cdseteco, cdrmativ: cdrmativ, dsendweb: dsendweb,
			nmtalttl: nmtalttl, qtfoltal: qtfoltal,	dtcadass: dtcadass, cdcnae  : cdcnae,
			operacao: operacao,	flgcadas: flgcadas, nrlicamb: nrlicamb, dtvallic : dtvallic,
			idregtrb: idregtrb, inpessoa: inpessoa, nmctajur: nmctajur,	redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				eval(response);
				
				// Se esta fazendo o cadastro apos MATRIC, fechar rotina e ir pra proxima
				if (operacao == 'VA' && (flgcadas == "M" || flgContinuar)) {
					proximaRotina();
				}
				
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
			}
		}				
	});
}

function controlaLayout(operacao) {	

	// Controla a altura da tela
	divRotina.css('width','552px');	
	$('#divConteudoOpcao').css('height','322px');

	// Razão Social / Tipo Natureza / CNPJ
	var camposGrupo1	= $('#nmprimtl, #inpessoa, #nrcpfcgc','#frmDadosIdentJuridica');	
	
	// Nome Fantasia / Consulta / Situação / Natureza Jurídica / Qt. Filiais / Qt. Funcionários / Início Atividade / Setor Econômico / Ramo Atividade / Site / Nome Talão / Qt. Folhas Talão
	var camposGrupo2	= $('#nmfatasi, #dtcnscpf, #cdsitcpf, #cdnatjur, #qtfilial, #qtfuncio, #dtiniatv, #cdseteco, #cdrmativ, #dsendweb, #nmtalttl, #qtfoltal,#cdcnae,#nrlicamb, #dtvallic, #idregtrb, #nmctajur','#frmDadosIdentJuridica');
	var selectsGrupo2	= $('select[name="cdsitcpf"], select[name="cdseteco"]','#frmDadosIdentJuridica');	
	var codigo			= $('#cdnatjur, #cdseteco, #cdrmativ','#frmDadosIdentJuridica');

	// Sempre inicia com tudo bloqueado
	camposGrupo1.desabilitaCampo();
	camposGrupo2.desabilitaCampo();

	// Controla largura dos campos
	$('#nmprimtl','#frmDadosIdentJuridica').css({'width':'424px'});
	$('#nrcpfcgc','#frmDadosIdentJuridica').css({'width':'114px'});
	$('#nmfatasi','#frmDadosIdentJuridica').css({'width':'240px'});
	$('#inpessoa,#dtiniatv,#cdsitcpf','#frmDadosIdentJuridica').css({'width':'101px'});
	$('#dtcnscpf,#qtfuncio','#frmDadosIdentJuridica').css({'width':'68px'});
	$('#qtfilial','#frmDadosIdentJuridica').css({'width':'65px'});
	$('#nmtalttl','#frmDadosIdentJuridica').css({'width':'321px'});
	$('#qtfoltal','#frmDadosIdentJuridica').css({'width':'25px'});
	$('#dsendweb','#frmDadosIdentJuridica').css({'width':'348px','margin-right':'2px'});
	$('#cdestcvl','#frmDadosIdentJuridica').css({'width':'30px'});
	$('#cdcnae','#frmDadosIdentJuridica').css({'width':'60px'}).attr('maxlength','7');
	$('#dscnae','#frmDadosIdentJuridica').css({'width':'344px'});
	$('label[for="qtfuncio"]','#frmDadosIdentJuridica').css({'width':'104px'});
	$('#nrlicamb', '#frmDadosIdentJuridica').css({ 'width': '180px' });
	$('#dtvallic', '#frmDadosIdentJuridica').css({ 'width': '90px' });
	$('#nmctajur', '#frmDadosIdentJuridica').css({ 'width': '424px' });

	// Pular para o proximo campo quando pressionado ENTER
	controlaFocoEnter('frmDadosIdentJuridica');

	// Está Alterando
	if (operacao == 'CA') {
		// Habilita os devidos campos
		camposGrupo2.habilitaCampo();

		codigo.unbind('blur').bind('blur', function() {
			controlaPesquisas();
		});

		$('#dsendweb','#frmDadosIdentJuridica').unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});	


		controlaPesquisas();					
	}

	controlaPesquisas();

	$('#cdcnae','#frmDadosIdentJuridica').trigger('change');	
	
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	highlightObjFocus($('#divConteudoOpcao'));
	controlaFoco(operacao);
	divRotina.centralizaRotinaH();
	return false;	
}

function controlaFoco(operacao){
	if (in_array(operacao,['FA','AC',''])) {
	  $('#btAlterar','#divBotoes').focus();
	} else {
		$('#nmfatasi','#frmDadosIdentJuridica').focus();
	}
}

function controlaPesquisas() {
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, filtrosDesc;	
	
	bo = 'b1wgen0059.p';
	
	// Atribui a classe lupa para os links de desabilita todos
	var lupas = $('a:not(.link)','#frmDadosIdentJuridica');
	lupas.addClass('lupa').css('cursor','auto');
	
	// Percorrendo todos os links
	lupas.each( function(i) {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');
		
		$(this).unbind("click").bind("click",( function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');
				
				// Natureza Jurídica
				if ( campoAnterior == 'cdnatjur' ) {					
					procedure	= 'busca_natureza_juridica';
					titulo      = 'Natureza Jur&iacute;dica';
					qtReg		= '30';
					filtros 	= 'Cód. Nat. Jurídica;cdnatjur;30px;S;0|Natureza Jurídica;dsnatjur;250px;S;';
					colunas 	= 'Código;cdnatjur;20%;right|Natureza Jurídica;dsnatjur;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;	

				// Setor Econômico
				} else if ( campoAnterior == 'cdseteco' ) {
					procedure	= 'busca_setor_economico';
					titulo      = 'Setor Econ&ocirc;mico';
					qtReg		= '30';
					filtros 	= 'Cód. Setor Econômico;cdseteco;30px;S;0|Setor Econômico;nmseteco;250px;S;';
					colunas 	= 'Código;cdseteco;20%;right|Setor Econômico;nmseteco;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;					
				
				// Ramo Atividade
				} else if ( campoAnterior == 'cdrmativ' ) {
					procedure	= 'busca_ramo_atividade';
					titulo      = 'Ramo Atividade';
					qtReg		= '30';
					filtros 	= 'Cód. Ramo Atividade;cdrmativ;30px;S;0|Ramo Atividade;dsrmativ;250px;S;|Cód. Setor Econômico;cdseteco;30px;N;|Setor Econômico;nmseteco;200px;N;';
					colunas 	= 'Código;cdrmativ;20%;right|Ramo Atividade;nmrmativ;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;
				}
				// CNAE
				else if ( campoAnterior == 'cdcnae' ) {
					procedure	= 'BUSCA_CNAE';
					titulo      = 'CNAE';
					qtReg		= '30';
					filtros     = 'Cód. CNAE;cdcnae;60px;S;0;;descricao|Desc. CNAE;dscnae;200px;S;;;descricao|;flserasa;;N;2;N;;descricao';
					colunas     = 'Código;cdcnae;20%;right|Desc CANE;dscnae;80%;left';			
					mostraPesquisa('ZOOM0001',procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;
				}
			}
		}));
	});
	
	// Hiperlink, pega o endereço no elemento anterior
	$('.link','#frmDadosIdentJuridica').css('cursor','pointer');
	$('.link','#frmDadosIdentJuridica').each( function() {
		
		var url = $(this).prev().attr('value');
		if( url.search('http://') == -1) url = 'http://'+$(this).prev().attr('value');
		$(this).attr('href',url);
		$(this).attr('target','_blank');
	});	

	/*-------------------------------------*/
	/*   CONTROLE DAS BUSCA DESCRIÇÕES     */
	/*-------------------------------------*/	

	// Natureza Jurídica
	$('#cdnatjur','#frmDadosIdentJuridica').unbind('change').bind('change',function() {
		procedure	= 'busca_natureza_juridica';
		titulo      = 'Natureza Jur&iacute;dica';	
		filtrosDesc = '';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsnatjur',$(this).val(),'dsnatjur',filtrosDesc,'frmDadosIdentJuridica');
		return false;
	});	
	
	// Setor Econômico
	$('#cdseteco','#frmDadosIdentJuridica').unbind('change').bind('change',function() {
		procedure	= 'busca_setor_economico';
		titulo      = 'Setor Econ&ocirc;mico';
		filtrosDesc = '';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'nmseteco',$(this).val(),'nmseteco',filtrosDesc,'frmDadosIdentJuridica');
		return false;
	});		

	// Ramo Atividade
	$('#cdrmativ','#frmDadosIdentJuridica').unbind('change').bind('change',function() {
		procedure	= 'busca_ramo_atividade';
		titulo      = 'Ramo Atividade';		
		filtrosDesc = 'cdseteco|'+$('#cdseteco','#frmDadosIdentJuridica').val();		
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsrmativ',$(this).val(),'nmrmativ',filtrosDesc,'frmDadosIdentJuridica');
		return false;
	});		
	
	// CNAE
	$('#cdcnae','#frmDadosIdentJuridica').unbind('change').bind('change',function() {
		procedure	= 'BUSCA_CNAE';
		titulo      = 'CNAE';		
		filtrosDesc = 'flserasa|2';
		buscaDescricao('ZOOM0001',procedure,titulo,$(this).attr('name'),'dscnae',$(this).val(),'dscnae',filtrosDesc,'frmDadosIdentJuridica');
		return false;
	});	
	
	return false;
}

function controlaContinuar () {
	
	flgContinuar = true;
	
	if ($("#btAlterar","#divBotoes").length > 0) {
		proximaRotina();
	} else {
		controlaOperacao('AV');
	}
	
}	

function proximaRotina () {
	hideMsgAguardo();
	encerraRotina(false);
	acessaRotina('REGISTRO','Registro','registro');		
}

function dossieDigidoc() {
	showMsgAguardo('Aguarde...');

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/dossie_digidoc.php',
		data: {
      nrcpfcgc: $('#nrcpfcgc','#frmDadosIdentJuridica').val(),
      nrdconta: nrdconta,
      redirect: 'html_ajax'
    },
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();

			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			$('#divUsoGenerico').html(response);
			exibeRotina($('#divUsoGenerico'));
      $('#divUsoGenerico').css({'margin-top': '170px'});
      $('#divUsoGenerico').css({'width': '400px'});
      $('#divUsoGenerico').centralizaRotinaH();
			bloqueiaFundo( $('#divUsoGenerico') );
      layoutPadrao();

      return false;
		}
	});
}
