/*!
 * FONTE        : conjuge.js
 * CRIAÇÃO      : Alexandre Scola (DB1)
 * DATA CRIAÇÃO : 08/03/2010 
 * OBJETIVO     : Biblioteca de funções na rotina CÔNJUGE da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [16/03/2010] Rodolpho Telmo  (DB1): Criação da rotina de busca conjuge por Nr. Conta ou CPF
 * 002: [23/03/2010] Rodolpho Telmo  (DB1): Criação da função controlaLupas()
 * 003: [26/04/2010] Rodolpho Telmo  (DB1): Retirada função "revisaoCadastral", agora se encontra no arquivo funcoes.js
 * 004: [12/11/2012] Daniel Zimmermann    : Alterado chamadas do procedimento controlaPesquisas() para evitar bloqueio 
 *											tela quando efetuado busca atraves lupa.
 * 005: [01/09/2015] Gabriel (RKAM)       : Reformulacao cadastral. 
 * 006: [03/03/2017] Adriano              : Ajuste devido a conversão das rotinas busca_nat_ocupacao, busca_ocupacao - SD 614408.
 * 007: [13/06/2017] Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			         crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
					 (Adriano - P339).
 * 018: [25/09/2017] Kelvin			     : Adicionado uma lista de valores para carregar orgao emissor. (PRJ339)			
 * 019: [07/02/2018] Lucas Ranghetti     : Aumentar o tamanho do campo cdnatopc para 90px pois estava estourando o tamanho no label (SD )
 */

// Definindo variáveis globais 
var nrctacje = ''; // Nr. Conta do Cônjuge
var nrcpfcjg = ''; // Nr. CPF do Cônjuge
var nrcpfOld = ''; // Nr. CPF auxiliar
var nrdrowid = ''; // Chave da Tabela Progress
var cdnvlcgo = ''; // Nível do cargo
var cdturnos = ''; // Cód. Turmo 
var operacao = ''; 
var nomeForm = 'frmDadosConjuge'; // Nome do Formulário
var flgContinuar = false;

function acessaOpcaoAba(nrOpcoes,id,opcao) {

	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, carregando...');
	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if (!$('#linkAba' + id)) {
			continue;
		}
		
		if (id == i) { // Atribui estilos para foco da opção
			$('#linkAba'   + id).attr('class','txtBrancoBold');
			$('#imgAbaEsq' + id).attr('src',UrlImagens + 'background/mnu_sle.gif');				
			$('#imgAbaDir' + id).attr('src',UrlImagens + 'background/mnu_sld.gif');
			$('#imgAbaCen' + id).css('background-color','#969FA9');
			continue;			
		}
		
		$('#linkAba'   + i).attr('class','txtNormalBold');
		$('#imgAbaEsq' + i).attr('src',UrlImagens + 'background/mnu_nle.gif');			
		$('#imgAbaDir' + i).attr('src',UrlImagens + 'background/mnu_nld.gif');
		$('#imgAbaCen' + i).css('background-color','#C6C8CA');
	}

	// Carrega conteúdo da opção através do Ajax
	$.ajax({		
		type: 'POST', 
		dataType: 'html',
		url: UrlSite + 'telas/contas/conjuge/principal.php',
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			operacao: operacao,
			flgcadas: flgcadas,
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

function controlaOperacao(operacao) {
		
	if ( !verificaContadorSelect() && operacao != 'CA' ) return false;
	
	// Se não possui acesso para alterar, emitir mensagem	
	if ( (operacao == 'CA') && (flgAlterar != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }

	if ( dsblqalt != '' ) {	showError('error',dsblqalt,'Alerta - Ayllos','bloqueiaFundo(divRotina)'); return false; }
		
	var mensagem = '';
	switch (operacao) {			
		case 'SC': 
			mensagem = 'Aguarde, abrindo formulário ...';
			cddopcao = 'C';
			break;
		case 'CA': 
			mensagem = 'Aguarde, abrindo formulário ...';
			cddopcao = 'A';
			break;	
		case 'CB':
			mensagem = 'Aguarde, buscando dados ...';
				
			break;	
		case 'AC': showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif'); return false; break;
		case 'FA': controlaOperacao(''); return false; break; // Finalizou Alteração		
		case 'AV': manterRotina(operacao); return false; break;	// Alteração para validação
		case 'VA': manterRotina(operacao); return false; break;	// Validação para Alteração: Salvando Alteração		
		default: 
			mensagem = 'Aguarde, abrindo formulário ...';
			nrcpfcjg = '';
			nrdrowid = '';
			nrctacje = '';
			cddopcao = 'C';			
			break;
	}	
	showMsgAguardo( mensagem );
	
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/conjuge/principal.php', 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			operacao: operacao,
			nrctacje: normalizaNumero( nrctacje ),
			nrcpfcjg: normalizaNumero( nrcpfcjg ),
			nrdrowid: nrdrowid,
			cddopcao: cddopcao,
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
				
				if ( operacao == 'CB' ){
					// Validar se o nome pode ser alterada
                    buscaNomePessoa_gen($('#nrcpfcjg','#'+nomeForm ).val(),'nmconjug', nomeForm);                        
                    
				}
				
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
		case 'VA':	mensagem = 'Aguarde, alterando ...'; break;
		case 'AV': 	mensagem = 'Aguarde, validando ...'; break;						
		default: return false; break;
	}	
	showMsgAguardo( mensagem );
	
	// Recebendo valores do formulário 
	nmconjug = $('#nmconjug','#'+nomeForm ).val();
	nrcpfcjg = $('#nrcpfcjg','#'+nomeForm ).val();
	dtnasccj = $('#dtnasccj','#'+nomeForm ).val();
	tpdoccje = $('#tpdoccje','#'+nomeForm ).val();
	nrctacje = $('#nrctacje','#'+nomeForm ).val();
	nrdoccje = $('#nrdoccje','#'+nomeForm ).val();
	cdoedcje = $('#cdoedcje','#'+nomeForm ).val();
	cdufdcje = $('#cdufdcje','#'+nomeForm ).val();
	dtemdcje = $('#dtemdcje','#'+nomeForm ).val();
	grescola = $('#grescola','#'+nomeForm ).val();
	cdfrmttl = $('#cdfrmttl','#'+nomeForm ).val();
	cdnatopc = $('#cdnatopc','#'+nomeForm ).val();
	cdocpcje = $('#cdocpcje','#'+nomeForm ).val();
	tpcttrab = $('#tpcttrab','#'+nomeForm ).val();
	nmextemp = $('#nmextemp','#'+nomeForm ).val();
	dsproftl = $('#dsproftl','#'+nomeForm ).val();
	cdnvlcgo = $('#cdnvlcgo','#'+nomeForm ).val();
	nrfonemp = $('#nrfonemp','#'+nomeForm ).val();
	nrramemp = $('#nrramemp','#'+nomeForm ).val();
	cdturnos = $('#cdturnos','#'+nomeForm ).val();
	dtadmemp = $('#dtadmemp','#'+nomeForm ).val();
	vlsalari = $('#vlsalari','#'+nomeForm ).val();
	nrdocnpj = $('#nrdocnpj','#'+nomeForm ).val();
	dsescola = $('#dsescola','#'+nomeForm ).val();
	rsfrmttl = $('#rsfrmttl','#'+nomeForm ).val();
	rsnatocp = $('#rsnatocp','#'+nomeForm ).val();
	rsdocupa = $('#rsdocupa','#'+nomeForm ).val();
	dsctrtab = $('#dsctrtab','#'+nomeForm ).val();
	rsnvlcgo = $('#rsnvlcgo','#'+nomeForm ).val();
	dsturnos = $('#dsturnos','#'+nomeForm ).val();
	cdgraupr = $('#cdgraupr','#'+nomeForm ).val();
	
	nmconjug = trim( nmconjug );
	cdoedcje = trim( cdoedcje );
	nmextemp = trim( nmextemp );
	dsproftl = trim( dsproftl );
	
	nrctacje = normalizaNumero( nrctacje );
	nrcpfcjg = normalizaNumero( nrcpfcjg );
	nrfonemp = normalizaNumero( nrfonemp );
	nrdocnpj = normalizaNumero( nrdocnpj );	
	cdnvlcgo = normalizaNumero( cdnvlcgo );	
	cdturnos = normalizaNumero( cdturnos );
	
	// Executa script de confirmação através de ajax 
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/conjuge/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, nmconjug: nmconjug,
			nrcpfcjg: nrcpfcjg, dtnasccj: dtnasccj, tpdoccje: tpdoccje,
			nrdoccje: nrdoccje, cdoedcje: cdoedcje, cdufdcje: cdufdcje,
			dtemdcje: dtemdcje, grescola: grescola, cdfrmttl: cdfrmttl,
			cdnatopc: cdnatopc, cdocpcje: cdocpcje, tpcttrab: tpcttrab,
			nmextemp: nmextemp, dsproftl: dsproftl, cdnvlcgo: cdnvlcgo,
			nrfonemp: nrfonemp, nrramemp: nrramemp, cdturnos: cdturnos,
			dtadmemp: dtadmemp, vlsalari: vlsalari, nrdocnpj: nrdocnpj,
			nrctacje: nrctacje, dsescola: dsescola, rsfrmttl: rsfrmttl,
			rsnatocp: rsnatocp, rsdocupa: rsdocupa, dsctrtab: dsctrtab,
			rsnvlcgo: rsnvlcgo, dsturnos: dsturnos,	cdgraupr: cdgraupr,	
			operacao: operacao,	flgcadas: flgcadas, redirect: 'script_ajax'
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
					flgContinuar = false;
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

	altura  = '365px';
	largura = '580px';
	$('#divConteudoOpcao').css('width',largura);
	$('#divConteudoOpcao').css('height',altura);
	
	// FIELDSET IDENDIFICAÇÃO 
	var rotulos_1 = $('label[for="nrctacje"],label[for="nmconjug"],label[for="tpdoccje"],label[for="nrdoccje"]', '#' + nomeForm);
	var rCPF          = $('label[for="nrcpfcjg"]','#'+nomeForm );
	var rDatas_1      = $('label[for="dtnasccj"],label[for="dtemdcje"]','#'+nomeForm );
	var rLinha_1      = $('label[for="cdoedcje"],label[for="cdufdcje"]','#'+nomeForm );
	
	var campos_1      = $('#nrcpfcjg,#dtnasccj,#cdoedcje,#dtemdcje','#'+nomeForm )
	var cNrConta      = $('#nrctacje','#'+nomeForm );
	var cCPF          = $('#nrcpfcjg','#'+nomeForm );
	var cNome         = $('#nmconjug','#'+nomeForm );
	var cDataNasc     = $('#dtnasccj','#'+nomeForm );
	var cTpDocumento  = $('#tpdoccje','#'+nomeForm );
	var cDocumento    = $('#nrdoccje','#'+nomeForm );
	var cOrgEmissor   = $('#cdoedcje','#'+nomeForm );	
	var cEstados      = $('#cdufdcje','#'+nomeForm );	
	var cDataEmissao  = $('#dtemdcje','#'+nomeForm );	

	rotulos_1.addClass('rotulo').css('width','80px');
	rLinha_1.addClass('rotulo-linha');
	rCPF.css('width','264px');
	rDatas_1.css('width','55px');
	
	campos_1.css('width','87px');
	cCPF.addClass('integer cpf');
	cNrConta.addClass('conta pesquisa').css('width','80px');
	cNome.addClass('alphanum').css('width','306px').attr('maxlength','40');
	cDataNasc.addClass('data');	
	cTpDocumento.css('width','45px');
	cDocumento.addClass('alphanum').css('width','400px').attr('maxlength','40');
	cOrgEmissor.addClass('alphanum').css('width','45px').attr('maxlength','5');
	cEstados.css('width','45px');
	cDataEmissao.addClass('data');
	
// FIELDSET PERFIL	
	var rotulos_2  = $('label[for="grescola"],label[for="cdnatopc"]','#'+nomeForm );	
	var rLinha_2   = $('label[for="cdfrmttl"],label[for="cdocpcje"]','#'+nomeForm );
	var cDescricao = $('#dsescola,#rsfrmttl,#rsnatocp,#rsdocupa','#'+nomeForm );	
	var cCodigo_2  = $('#grescola,#cdnatopc,#cdfrmttl,#cdocpcje','#'+nomeForm );	
	
	rotulos_2.addClass('rotulo').css('width','90px');
	rLinha_2.css('width','70px');
	cDescricao.addClass('descricao').css('width','134px');
	cCodigo_2.addClass('codigo pesquisa');
	
// FIELDSET INF. PROFISSIONAIS	
	var rotulos_3 = $('label[for="tpcttrab"],label[for="nrdocnpj"],label[for="dsproftl"],label[for="cdnvlcgo"],label[for="cdturnos"],label[for="cdoedcje"]', '#' + nomeForm);
	var rColuna_2	= $('label[for="nmextemp"],label[for="nrfonemp"],label[for="dtadmemp"]','#'+nomeForm );
	var rLinha_3   	= $('label[for="nrramemp"],label[for="vlsalari"]','#'+nomeForm );
	var cColuna_1  	= $('#tpcttrab,#nrdocnpj,#cdturnos,#cdnvlcgo','#'+nomeForm );
	var cCNPJ		= $('#nrdocnpj','#'+nomeForm );
	var cEmpresa    = $('#nmextemp','#'+nomeForm );
	var cFuncao  	= $('#dsproftl','#'+nomeForm );
	var cTelComerc 	= $('#nrfonemp','#'+nomeForm );
	var cRamal     	= $('#nrramemp','#'+nomeForm );
	var cDtAdmissao = $('#dtadmemp','#'+nomeForm );
	var cRendimento	= $('#vlsalari','#'+nomeForm );
	
	rotulos_3.addClass('rotulo').css('width','80px');
	rColuna_2.css('width','60px');
	rLinha_3.addClass('rotulo-linha');	
	cColuna_1.css('width','130px');
	cCNPJ.addClass('cnpj');
	cEmpresa.addClass('alphanum').attr('maxlength','35').css('width','258px');
	cFuncao.addClass('alphanum').attr('maxlength','20').css('width','258px');
	cTelComerc.addClass('telefone').attr('maxlength','20').css('width','175px');
	cRamal.addClass('inteiro').attr('maxlength','4').css('width','41px');
	cDtAdmissao.addClass('data').css('width','75px');
	cRendimento.addClass('moeda_6').css('width','129px');	
		
	var camposGrupo1  = $('#nrctacje,#nrcpfcjg','#'+nomeForm );
	var camposGrupo2  = $('#nmconjug,#dtnasccj,#tpdoccje,#nrdoccje,#cdoedcje,#cdufdcje,#dtemdcje,#grescola,#cdfrmttl,#cdnatopc,#cdocpcje','#'+nomeForm );
	var camposGrupo3  = $('#nmextemp,#nrdocnpj,#dsproftl,#nrfonemp,#nrramemp,#dtadmemp,#vlsalari,#tpcttrab,#cdturnos,#cdnvlcgo','#'+nomeForm );	
	var naturezaOcupacao = $('#cdnatopc','#'+nomeForm ).val();	

	// Sempre inicia com tudo bloqueado
	camposGrupo1.desabilitaCampo();
	camposGrupo2.desabilitaCampo();
	camposGrupo3.desabilitaCampo();

	// Definindo variáveis auxiliares para o número da conta e o número do cpf
	var nrconta      = '';
	var nrcontaAtual = '';
	var nrcpfEnt     = ''; // Numero do cpf na entrada do campo
	var nrcpfAtual   = '';
	
	// [A] ALTERANDO OU [B] ALTERAÇÃO COM BUSCA
	if ( operacao == 'CA' || operacao == 'CB' ) {
	
		// Habilita somente Nr. Conta
		cNrConta.habilitaCampo();		
		
		controlaInfProfissionais();
				
		// CONTROLE DO NÚMERO DA CONTA
		cNrConta.unbind('keydown').bind('keydown', function (e) {									
			if ( !verificaContadorSelect() ) return false;
			if ( e.keyCode == 13 ) {
				
				// Obtenho o número da conta atual
				nrcontaAtual = normalizaNumero( $(this).val() );
				// nrcpfOld	 = normalizaNumero( cCPF.val() );
				
				// Se é zero habilito o campo CPF
				if ( nrcontaAtual == 0 ) {					
					
					// Desabilita Nr. Conta
					$(this).desabilitaCampo();	
					
					cCPF.habilitaCampo();
					cCPF.trigger('blur');			
					nrcpfEnt = normalizaNumero( cCPF.val() );
					cCPF.focus();	
				} else {
					nrctacje = nrcontaAtual;
					nrcpfcjg = 0;
					nrdrowid = '';
					showMsgAguardo('Aguarde, buscando dados ...');	
					controlaOperacao('CB');
				}
			}
		});	

		// CONTROLE DO CPF
		cCPF.unbind('keydown').bind('keydown', function(e) {
			if ( !verificaContadorSelect() ) return false;
			if ( e.keyCode == 13 ) {							
				
				// Obtenho o número do cpf atual
				nrcpfAtual = normalizaNumero( $(this).val() );	
				
				// Se o cpf for diferente de zero, busco pelo cpf
				if ( nrcpfAtual != 0 ) {						
					
					// Valida o CPF
					if ( !validaCpfCnpj( nrcpfAtual ,1 ) ) {
						showError('error','CPF inv&aacute;lido.','Valida&ccedil;&atilde;o CPF','$("#nrcpfcjg","#frmDadosConjuge").focus();bloqueiaFundo(divRotina);');
						return false;
					} else {					
						nrcpfcjg = nrcpfAtual;
						nrcpfOld = nrcpfcjg;
						nrctacje = 0;
						nrdrowid = '';
						showMsgAguardo('Aguarde, buscando dados ...');									
						controlaOperacao('CB');
                                               
					}					
		
				// Caso em que o cpf é zero
				} else {
					camposGrupo1.desabilitaCampo();
					camposGrupo2.habilitaCampo();	
					controlaInfProfissionais();	
					cNome.focus();
					 								
				}	
                
                // Validar empresa de trabalho, se pode ser alterada
                buscaNomePessoa_gen($('#nrdocnpj','#'+nomeForm ).val(),'nmextemp', nomeForm);
                return false;
            
			}			
		});	

		cRendimento.unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});		
		
		if (operacao == 'CB') {

			// Obtenho o número da conta atual
			nrcontaAtual = normalizaNumero( cNrConta.val() );			
			camposGrupo1.desabilitaCampo();
			
			// Se é zero habilito o campo CPF
			if ( nrcontaAtual == 0 ) {										
				camposGrupo2.habilitaCampo();				
		        controlaInfProfissionais();	
			}	
		}
	}
	
	montaSelect('b1wgen0059.p','busca_nivel_cargo','cdnvlcgo','cdnvlcgo','cdnvlcgo;rsnvlcgo',cdnvlcgo);
	montaSelect('b1wgen0059.p','busca_turnos','cdturnos','cdturnos','cdturnos;dsturnos',cdturnos);	
		
	controlaPesquisas();
	layoutPadrao();
	cNrConta.trigger('blur');
	cCNPJ.trigger('blur');
	cCPF.trigger('blur');
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	highlightObjFocus($('#divConteudoOpcao'));
	controlaFocoEnter("divConteudoOpcao");
	controlaFoco(operacao);
	divRotina.centralizaRotinaH();
	return false;
}

function controlaInfProfissionais() {
	var cNrConta      		= $('#nrctacje','#'+nomeForm );
	var cCPF          		= $('#nrcpfcjg','#'+nomeForm );
	var naturezaOcupacao 	= $('#cdnatopc','#'+nomeForm );
	var tipoContratoTrab 	= $('#tpcttrab','#'+nomeForm );
	var camposGrupo3  		= $('#nmextemp,#nrdocnpj,#dsproftl,#nrfonemp,#nrramemp,#dtadmemp,#vlsalari,#tpcttrab,#cdturnos,#cdnvlcgo','#'+nomeForm );

	// Se o campo conta ou cpf estiverem habilitados, o restante fica desabilitados
	if ( cNrConta.prop('disabled') && cCPF.prop('disabled') ) {	
		// Habilita / Desabilita o Grupo 3 se a "Nat. Ocupação" for 11 (Sem Remuneração) ou 12 (Sem Vínculo)
		// e o campo "Tp. Ctr. Trabalho" será igual a 3 (Sem Vinculo)
		if ( ( naturezaOcupacao.val() != '11' ) && ( naturezaOcupacao.val() != '12') ) {
			camposGrupo3.habilitaCampo();
			if ( tipoContratoTrab.val() == 3 ){
				camposGrupo3.limpaFormulario();
				camposGrupo3.desabilitaCampo();
				tipoContratoTrab.habilitaCampo();
				tipoContratoTrab.removeProp('selected');
				tipoContratoTrab.prop('selected',true).val(3);
			}
		} else {
			tipoContratoTrab.removeProp('selected');
			tipoContratoTrab.prop('selected',true).val(3);						
			// Desabilita os campos necessários
			camposGrupo3.desabilitaCampo();					
		}
	}
	
	// Se a Nat. Ocupação for 11 (Sem Remuneração) ou 12 (Sem Vínculo), 
	// o Tp. Ctr. Trabalho será igual a 3 (Sem Vinculo) e o camposGrupo3 estarão desabilitados
	naturezaOcupacao.unbind('blur').bind('blur', function() {	
		if ( ($(this).val() == 11) || ($(this).val() == 12 ) ) {									
			// Seleciono a opção 3 do select "Tp. Ctr. Trabalho" = tpcttrab
			tipoContratoTrab.removeProp('selected');
			tipoContratoTrab.prop('selected',true).val(3);
			tipoContratoTrab.trigger('change');	
			camposGrupo3.desabilitaCampo();
		} else {							
			// Habilita os campos necessários			
			camposGrupo3.habilitaCampo();				
			tipoContratoTrab.trigger('change');			
		}
		if ( shift ) { 
			$('#cdfrmttl','#'+nomeForm ).focus(); 
		} else { 
			$('#cdocpcje','#'+nomeForm ).focus(); 				
		}		
		return true;
	});
	
	tipoContratoTrab.unbind('change').bind('change', function(){ 
		if ( $(this).val() == 3 ) {
			camposGrupo3.limpaFormulario();
			camposGrupo3.desabilitaCampo();
			$(this).habilitaCampo();
			$(this).removeProp('selected');
			$(this).prop('selected',true).val(3);
			$('#btVoltar','#divBotoes').focus();
		} else {
			camposGrupo3.habilitaCampo();
			$('#nmextemp','#'+nomeForm).focus();
		}
		return true;
	});		
}

function estadoInicial() {
	if ( !verificaContadorSelect() ) return false;
	var formulario	= $('#'+nomeForm);
	var cNrConta	= $('#nrctacje','#'+nomeForm );	
	var cTodos		= $('input,select','#'+nomeForm );	
	formulario.limpaFormulario();
	cTodos.desabilitaCampo();
	cNrConta.habilitaCampo();	
	cNrConta.focus();
	return false;
}

function controlaFoco(operacao) {
	if (in_array(operacao,[''])) {
		$('#btAlterar','#divBotoes').focus();
	} else {
		$('.campo:first','#'+nomeForm ).focus();
	}
	return false;
}

function controlaPesquisas() {

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas;
	
	bo = 'b1wgen0059.p';
	
	/*-------------------------------------*/
	/*       CONTROLE DAS PESQUISAS        */
	/*-------------------------------------*/
	
	// Atribui a classe lupa para os links e desabilita todos
	$('a','#'+nomeForm).addClass('lupa').css('cursor','auto');	
	
	// Percorrendo todos os links
	$('a','#'+nomeForm).each( function() {
		
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) { $(this).css('cursor','pointer'); }
		
		$(this).click( function() {
		
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');
				
				//Remove a classe de Erro do form
				$('input,select', '#'+nomeForm).removeClass('campoErro');
				
				// Nr. Conta do Cônjuge
				if ( campoAnterior == 'nrctacje' ) {
					mostraPesquisaAssociado('nrctacje',nomeForm,divRotina);
					return false;	
				
				// Grau de Escolaridade
				} else if ( campoAnterior == 'grescola' ) {
					procedure	= 'busca_grau_escolar';
					titulo      = 'Escolaridade';
					qtReg		= '30';
					filtrosPesq	= 'Cód. Escolaridade;grescola;30px;S;0|Escolaridade;dsescola;200px;S;';
					colunas 	= 'Código;grescola;20%;right|Escolaridade;dsescola;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
					return false;
				// Orgao Emissor
				} else if (campoAnterior == 'cdoedcje'){								
					procedure	= 'BUSCA_ORGAO_EXPEDIDOR';
					titulo      = 'Org&atilde;o expedidor';
					qtReg		= '30';
					filtrosPesq = 'Código;cdoedcje;100px;S;|Descrição;nmoedcje;200px;S;';
					colunas = 'Código;cdorgao_expedidor;25%;left|Descrição;nmorgao_expedidor;75%;left';
					mostraPesquisa("ZOOM0001", procedure, titulo, qtReg, filtrosPesq, colunas, divRotina);									
					return false;
				// Curso Superior
				} else if ( campoAnterior == 'cdfrmttl' ) {
					procedure	= 'busca_formacao';
					titulo      = 'Curso Superior';
					qtReg		= '30';
					filtrosPesq	= 'Cód. Curso Superior;cdfrmttl;30px;S;0|Curso Superior;rsfrmttl;200px;S;';
					colunas 	= 'Código;cdfrmttl;25%;right|Curso Superior;rsfrmttl;75%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
					return false;

				// Natureza Ocupação
				} else if ( campoAnterior == 'cdnatopc' ) {
					filtrosPesq = "Cód. Nat. Ocupação;cdnatopc;30px;S;0|Natureza da Ocupação;rsnatocp;200px;S;";
                    colunas = 'Código;cdnatocp;25%;right|Natureza da Ocupação;rsnatocp;75%;left';
                    mostraPesquisa("ZOOM0001", "BUSCANATOCU", "Natureza da Ocupa&ccedil;&atilde;o", "30", filtrosPesq, colunas, divRotina);

					return false;
				
				// Código Ocupação
				} else if ( campoAnterior == 'cdocpcje' ) {
					
					filtrosPesq	= 'Cód. Ocupação;cdocpcje;30px;S;0|Ocupação;rsdocupa;200px;S;';
					colunas 	= 'Código;cdocupa;20%;right|Ocupação;dsdocupa;80%;left';
					mostraPesquisa("ZOOM0001", "BUSCOCUPACAO", "Ocupa&ccedil;&atilde;o", "30", filtrosPesq, colunas, divRotina);
					return false;
				}					
			}
			return false;		
		});
	});
	
	/*-------------------------------------*/
	/*   CONTROLE DAS BUSCA DESCRIÇÕES     */
	/*-------------------------------------*/

	// Escolaridade
	$('#grescola','#'+nomeForm).unbind('change').bind('change', function() {
		titulo      = 'Escolaridade';
		procedure   = 'busca_grau_escolar';
		filtrosDesc = '';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsescola',$(this).val(),'dsescola',filtrosDesc,nomeForm);
		return false;
	});
	
	// Curso Superior
	$('#cdfrmttl','#'+nomeForm).unbind('change').bind('change',function() {
		titulo      = 'Curso Superior';
		procedure   = 'busca_formacao';
		filtrosDesc = '';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'rsfrmttl',$(this).val(),'rsfrmttl',filtrosDesc,nomeForm);
		return false;
	});	
	
	// Natureza Ocupação
	$('#cdnatopc','#'+nomeForm).unbind('change').bind('change', function() {
		filtrosDesc = '';
        buscaDescricao("ZOOM0001", "BUSCANATOCU", "Natureza Ocupação", $(this).attr('name'), 'rsnatocp', $(this).val(), 'rsnatocp', filtrosDesc, nomeForm);
		return false;
	});	
	
	// Ocupação
	$('#cdocpcje','#'+nomeForm).unbind('change').bind('change',function() {
		
		filtrosDesc = '';
        buscaDescricao("ZOOM0001", "BUSCOCUPACAO", "Ocupação", $(this).attr('name'), 'rsdocupa', $(this).val(), 'dsdocupa', filtrosDesc, nomeForm);
		return false;

	});		
}

function controlaContinuar() {
	
	flgContinuar = true;
			
	if ($("#btAlterar","#divBotoes").length > 0) {
		proximaRotina();
	} else {
		controlaOperacao('AV');
	}		
	
}

function voltarRotina() {
	acessaOpcaoAbaDados(6,2,'@');
}

function proximaRotina () {
	hideMsgAguardo();
	encerraRotina(false);
	acessaRotina('CONTATOS','Contatos','contatos_pf');				
}
