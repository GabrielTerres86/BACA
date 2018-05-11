/*!
 * FONTE        : avalista.js
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 02/05/2011 
 * OBJETIVO     : Biblioteca de funções para o formulário genérico de Avalistas
 */	

/*!
 * OBJETIVO  : Formatar o formulário de avalistas
 * CHAMADA   : No final do arquivo que realiza o include do "form_avalista.php", esta função é disparada para
 *             formatar o formulário
 
   Alterações : 04/12/2012 - Ajuste na função formataAvalista referente a alguns campos estarem
							 com width muito grande e assim, gerando uma quebra de linha 
						    (Adriano).
							
				30/04/2015 - Evitar erros no ENTER de campos que nao tem eventos (Gabriel-RKAM).			
							
                24/10/2017 - Ajustes ao carregar dados do avalista e controle de alteração. PRJ339 CRM (Odirlei-AMcom)                      
							
 */	 
function formataAvalista() {
	
	if ( $('#divConteudoOpcao').css('display') != 'none' ) {
		$('#divConteudoOpcao').fadeTo(1,0.01);
	}	
	
	$('.fsAvalista').css('height','auto');	
	cTodos = $('input, select','#'+nomeForm+' .fsAvalista');
	cTodos.desabilitaCampo();	

	var rConta	= $('label[for="nrctaav1"],label[for="nrctaav2"]','#'+nomeForm);
	var rNome	= $('label[for="nmdaval1"],label[for="nmdaval2"]','#'+nomeForm);
	var rConjuge= $('label[for="nmdcjav1"],label[for="nmdcjav2"]','#'+nomeForm);
    var rCpfCnpj= $('label[for="nrcpfav1"],label[for="nrcpfav2"]','#'+nomeForm);
	var rCpfCjea= $('label[for="cpfcjav1"],label[for="cpfcjav2"]','#'+nomeForm);
	var rTDoc	= $('label[for="tpdocav1"],label[for="tdccjav1"],label[for="tpdocav2"],label[for="tdccjav2"]','#'+nomeForm);
	var rDDoc	= $('label[for="dsdocav1"],label[for="doccjav1"],label[for="dsdocav2"],label[for="doccjav2"]','#'+nomeForm);
	var rCep	= $('label[for="nrcepav1"],label[for="nrcepav2"]','#'+nomeForm);
	var rEnd	= $('label[for="ende1av1"],label[for="ende1av2"]','#'+nomeForm);
	var rNum	= $('label[for="nrender1"],label[for="nrender2"]','#'+nomeForm);
	var rCom	= $('label[for="complen1"],label[for="complen2"]','#'+nomeForm);
	var rCax	= $('label[for="nrcxaps1"],label[for="nrcxaps2"]','#'+nomeForm);	
	var rBai	= $('label[for="ende2av1"],label[for="ende2av2"]','#'+nomeForm);
	var rEst	= $('label[for="cdufava1"],label[for="cdufava2"]','#'+nomeForm);	
	var rCid	= $('label[for="nmcidav1"],label[for="nmcidav2"]','#'+nomeForm);
	var rEmail	= $('label[for="emailav1"],label[for="emailav2"]','#'+nomeForm);
	var rTel	= $('label[for="nrfonav1"],label[for="nrfonav2"]','#'+nomeForm);

	rConta.addClass('rotulo').css('width','64px');
	rNome.addClass('rotulo').css('width','64px');
	rConjuge.addClass('rotulo').css('width','64px');
	rCpfCnpj.addClass('rotulo-linha').css('width','64px');
    rCpfCjea.addClass('rotulo').css('width','64px');
	rTDoc.addClass('rotulo-linha');

	rCep.addClass('rotulo').css('width','64px');
	rEnd.addClass('rotulo-linha').css('width','30px');
	rNum.addClass('rotulo-linha').css('width','25px');
	rCom.addClass('rotulo').css('width','64px');
	rCax.addClass('rotulo').css('width','64px');
	rBai.addClass('rotulo-linha').css('width','44px');
	rEst.addClass('rotulo-linha').css('width','25px');
	rCid.addClass('rotulo-linha').css('width','47px');
	rTel.addClass('rotulo').css('width','64px');
	rEmail.addClass('rotulo-linha');

	var cContas	= $('#nrctaav1,#nrctaav2','#'+nomeForm);
	var cNome	= $('#nmdaval1,#nmdaval2','#'+nomeForm);
	var cConjuge= $('#nmdcjav1,#nmdcjav2','#'+nomeForm);
	var cCpfTit	= $('#nrcpfav1,#nrcpfav2','#'+nomeForm);
	var cCpfCon	= $('#cpfcjav1,#cpfcjav2','#'+nomeForm);
	var cTDoc	= $('#tpdocav1,#tdccjav1,#tpdocav2,#tdccjav2','#'+nomeForm);
	var cDDoc	= $('#dsdocav1,#doccjav1,#dsdocav2,#doccjav2','#'+nomeForm);
	var cCEPs	= $('#nrcepav1,#nrcepav2','#'+nomeForm);
	var cEnd	= $('#ende1av1,#ende1av2','#'+nomeForm);
	var cNum	= $('#nrender1,#nrender2','#'+nomeForm);
	var cCom	= $('#complen1,#complen2','#'+nomeForm);
	var cCax	= $('#nrcxaps1,#nrcxaps2','#'+nomeForm);	
	var cBai	= $('#ende2av1,#ende2av2','#'+nomeForm);
	var cEst	= $('#cdufava1,#cdufava2','#'+nomeForm);	
	var cCid	= $('#nmcidav1,#nmcidav2','#'+nomeForm);
	var cEmail	= $('#emailav1,#emailav2','#'+nomeForm);
	var cTel	= $('#nrfonav1,#nrfonav2','#'+nomeForm);
	var cRenda  = $('#vlrenme1,#vlrenme2','#'+nomeForm);

	cContas.addClass('conta pesquisa').css('width','70px');
	cNome.addClass('alphanum').css('width','220px').attr('maxlength','57');
	cConjuge.addClass('alphanum').css('width','429px').attr('maxlength','40');
	cCpfTit.addClassCpfCnpj().css({'width':'118px','text-align':'right'});
	cCpfCon.addClass('cpf').css('width','118px');
	cTDoc.css('width','42px');
	cDDoc.css('width','130px').attr('maxlength','40');

	cCEPs.addClass('cep pesquisa').css('width','65px').attr('maxlength','9');
	cEnd.addClass('alphanum').css('width','230px').attr('maxlength','40');
	cNum.addClass('numerocasa').css('width','47px').attr('maxlength','7');
	cCom.addClass('alphanum').css('width','120px').attr('maxlength','40');	
	cCax.addClass('caixapostal').css('width','65px').attr('maxlength','6');	
	cBai.addClass('alphanum').css('width','260px').attr('maxlength','40');	
	cEst.css('width','118px');	
	cCid.addClass('alphanum').css('width','163px').attr('maxlength','25');
	cTel.css('width','118px').attr('maxlength','20');
	cEmail.addClass('email').css({'width':'269px'}).attr('maxlength','32');
	cRenda.addClass('moeda').css('width','117px');

	// ACERTOS PARA O IE
	if ( $.browser.msie ) {	
		cNome.css('width','275px');
		cEnd.addClass('alphanum').css('width','233px');
		cBai.addClass('alphanum').css('width','263px');
		cCid.addClass('alphanum').css('width','156px');
		cEst.css('width','131px');	
		
	}

	layoutPadrao();
	controlaAvalista();	
	
    cContas.trigger('blur');	
	cCEPs.trigger('blur');	
	cCpfTit.trigger('blur');	
	cCpfCon.trigger('blur');	
	cNum.trigger('blur');
	cCax.trigger('blur');

	if ( $('#divConteudoOpcao').css('display') != 'none' ) {
		removeOpacidade('divConteudoOpcao');
	}
		
	return false;
}

/*!
 * OBJETIVO  : Aplicar os eventos necessários para o formulário genérico de Avalistas
 * CHAMADA   : No final do arquivo que realiza o include do "form_avalista.php", esta função é disparada para
 *             aplicar os eventos necessários para o formulário
 */	
function controlaAvalista() {

	// A variavel camposOrigem deve ser composta:
	// 1) os cincos primeiros campos são os retornados para o formulario de origem
	// 2) o sexto campo é o campo q será focado após o retorno ao formulario de origem, que
	// pelo requisito na maioria dos casos será o NUMERO do endereço	
	var camposOrigem1 = 'nrcepav1;ende1av1;nrender1;complen1;nrcxaps1;ende2av1;cdufava1;nmcidav1';	
	var camposOrigem2 = 'nrcepav2;ende1av2;nrender2;complen2;nrcxaps2;ende2av2;cdufava2;nmcidav2';

	
	// Campos que devem possuir eventos
	var cTodos  = $('input','#'+nomeForm);
	var cCTA_1	= $('#nrctaav1','#'+nomeForm); // Conta do avalista 1
	var cCTA_2	= $('#nrctaav2','#'+nomeForm); // Conta do avalista 2
	var cCEP_1	= $('#nrcepav1','#'+nomeForm); // CEP do avalista 1
	var cCEP_2	= $('#nrcepav2','#'+nomeForm); // CEP do avalista 2
	var cCPF_1  = $('#nrcpfav1','#'+nomeForm); // CPF/CNPJ do avalita 
	var cCPF_2  = $('#nrcpfav2','#'+nomeForm); // CPF/CNPJ do avalita 
	
	
	// Evitar erros no ENTER dos campos sem eventos especificos
	cTodos.unbind('keypress').bind('keypress',function(e) {
	
		// Focar no proximo campo quando ENTER ou tab
		if ( e.keyCode == 13 || e.keyCode == 9) {
			
			var campo =  $("input",'#'+nomeForm);
			var indice = campo.index(this);
		
			if (campo[indice+1] != null) { 
				campo[indice+1].focus();
			}	
		
			return false;
		}
	
	});
	
	// CONTA AVALISTA
	cCTA_1.buscaConta('pesquisaContaAvalista(1)', 'estadoInicial(1)', divRotina );
	cCTA_2.buscaConta('pesquisaContaAvalista(2)', 'estadoInicial(2)', divRotina );

	// CPF AVALISTA
	cCPF_1.buscaCPF('pesquisaCpfAvalista(1);');
	cCPF_2.buscaCPF('pesquisaCpfAvalista(2);');

	// CEP AVALISTA
	cCEP_1.buscaCEP(nomeForm, camposOrigem1, divRotina);
	cCEP_2.buscaCEP(nomeForm, camposOrigem2, divRotina);	
}

/*!
 * OBJETIVO  : Capturar o número da conta, caso for zero, libera os campos para edição, caso contrário valida se
 *             o número da conta é valido e caso afirmativo chama a função que busca os dados do avalista
 * CHAMADA   : É disparada no evento onChange a tecla ENTER é pressionada no campo Nr. Conta
 * PARÂMETRO : i -> [int] Valores válidos 1 ou 2. Representa se é o primeiro ou segundo avalista. 
 */	 
function pesquisaContaAvalista(i) {
    
	var cConta  = $('#nrctaav'+i,'#'+nomeForm);	
    var cCpfAva = $('#nrcpfav'+i,'#'+nomeForm);	
	var nrConta = normalizaNumero( cConta.val() );	
	if (nrConta == 0) {
		cConta.val('').desabilitaCampo();
        cCpfAva.habilitaCampo();
		cCpfAva.focus();
	} else if (!validaNroConta(nrConta)) {			
		showError("error","Conta/dv inv&aacute;lida.","Alerta - Ayllos","$('#nrctaav"+i+"','#"+nomeForm+"').focus();bloqueiaFundo(divRotina);");		
	} else {
		carregaAvalista(i);
	}
	return false;
}

/*!
 * OBJETIVO  : Capturar o número do CPF/CNPJ, caso diferente de zero valida se é um CPF/CNPJ válido
 *             e caso afirmativo chama a função que busca os dados do avalista
 * CHAMADA   : É disparada no evento onChange a tecla ENTER é pressionada no campo CPF/CNPJ
 * PARÂMETRO : i -> [int] Valores válidos 1 ou 2. Representa se é o primeiro ou segundo avalista. 
 */	 
function pesquisaCpfAvalista(i) {
	
	var cCPF  = $('#nrcpfav'+i,'#'+nomeForm);	
	var nrCpfCnpj = normalizaNumero( cCPF.val() );	
	if ( nrCpfCnpj == 0 ) {
		cCPF.removeClass('cpf cnpj').focus();		
	} else if (verificaTipoPessoa(nrCpfCnpj) == 0) {			
		showError("error","CPF/CNPJ inv&aacute;lido.","Alerta - Ayllos","$('#nrcpfav"+i+"','#"+nomeForm+"').focus();bloqueiaFundo(divRotina);");				
	} else {
		carregaAvalista(i);
        // Se nao for acessado via CRM, pode habilitar os campos
        if ($('#crm_inacesso', '#' + nomeForm).val() != 1 ) {
            $('input, select','.fsAvalista:eq('+(i-1)+')').habilitaCampo();		
            $('#ende1av'+i+',#ende2av'+i+',#cdufava'+i+',#nmcidav'+i,'#'+nomeForm).desabilitaCampo();
        }
	}
	return false;
}

/*!
 * OBJETIVO  : Carregar os dados do avalista no formulário genérico de avalistas
 * CHAMADA   : É chamada pelas funções pesquisaCpfAvalista e pesquisaContaAvalista
 * PARÂMETRO : i -> [int] Valores válidos 1 ou 2. Representa se é o primeiro ou segundo avalista. 
 */
function carregaAvalista(i) {

	showMsgAguardo('Aguarde, verificando dados do avalista ...');
	
	cCta = $('#nrctaav'+(i),'#'+nomeForm);
	cCPF = $('#nrcpfav'+(i),'#'+nomeForm);
	
	var nrctaava 	= normalizaNumero( cCta.val() );
	var nrcpfava 	= normalizaNumero( cCPF.val() );	
	
	if (nrctaava == 0 && nrcpfava == 0) {
		hideMsgAguardo();
		bloqueiaFundo(divRotina);
		return true;
	}
		
	// Executa script para carregar dados de avalistas através de ajax
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'includes/avalistas/obtem_dados_avalista.php',
		data: {
			nrdconta  : nrdconta,
			idavalis  : i,
			nrctaava  : nrctaava,
			nrcpfava  : nrcpfava,
			bo	      : boAvalista,
			procedure : procAvalista,
			nomeForm  : nomeForm,
			redirect  : 'script_ajax'
		},	
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);			
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	}); 	
}

/*!
 * OBJETIVO  : Deixar o formulário de avalista em modo de edição
 * CHAMADA   : No final do arquivo que realiza o include do "form_avalista.php", caso for uma operação
 *             para alteração/inclusão de avalista, então chamar esta função que se encarrega de liberar
 *			   os campos necessários para edição
 * PARÂMETRO : boHabilita -> [Boolean] True para habilitar e False para desabilitar
 */	 
function habilitaAvalista(boHabilita,operacao) {	
	
	if (boHabilita) {	
		estadoInicial(1,operacao);
		estadoInicial(2,operacao);
		$('#nrctaav1','#'+nomeForm).focus();	
        
	} else {
		$('input, select','#'+nomeForm+' .fsAvalista').desabilitaCampo();
		$('a.pointer','#'+nomeForm+' .fsAvalista').removeClass('pointer');
	}
}

/*!
 * OBJETIVO  : Deixar o formulário em seu estado inicial, somente com os campos contas habilitados
 * CHAMADA   : No clique do botão refresh
 */	 
function estadoInicial(i,operacao) {	
	
	// Declarando variáveis úteis
	var cTodos = $('input[type="text"], select','#'+nomeForm+' .fsAvalista:eq('+(i-1)+')');
	var cConta = $('input:eq(0)','.fsAvalista:eq('+(i-1)+')');
	
	switch(operacao) {
	case 'A':
		// Limpa o formulário de sesabilita todos campos 
		cTodos.desabilitaCampo();
		
		//Habilita os campos de Nr. Conta do avalista "i"
		cConta.habilitaCampo();	
	break;

	default:
		// Limpa o formulário de sesabilita todos campos 
		cTodos.limpaFormulario();
		cTodos.desabilitaCampo();	
		
		//Habilita os campos de Nr. Conta do avalista "i"
		cConta.habilitaCampo();	
		cConta.val('');
	break;
	}

	// Foca o Nr. Conta
	cConta.focus();
	
}
