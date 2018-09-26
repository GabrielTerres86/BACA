var tipoPessoa = 1;

	var dsendre1 = "";
	var nmdavali = "";
	var nrcpfcgc = "";
	var tpdocava = "";
	var nrdocava = "";
	var nmconjug = "";
	var nrcpfcjg = "";
	var tpdoccjg = "";
	var nrdoccjg = "";
	var cdnacion = "";
	var dsendre2 = "";
	var nrfonres = "";
	var dsdemail = "";
	var cdufresd = "";
	var nrcepend = "";
	var nrendere = "";
	var complend = "";
	var nrcxapst = "";
	var nmcidade = "";
	var dsnacion = "";

	var nomeForm = "";
	var camposOrigem = '';
	
	
function validaCPFInterveniente()
{	
	nrcpfcgc =$('#nrcpfcgc', '#frmTipo').val();
	nrcpfcgc=normalizaNumero(nrcpfcgc);	
	$.ajax({
		type  : 'POST',
		url   : UrlSite + 'telas/manbem/interveniente/valida_cpf_interveniente.php',
		data: {
			nrdconta	: nrdconta, // global
			nrctremp	: nrctremp, // global
               tpctrato    : tpctrato, // global
               nrcpfcgc    : nrcpfcgc,				
			redirect	: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','');
		},
		success: function(response) {
			try 
			{
				hideMsgAguardo();
				var responseJson = $.parseJSON(response);	
				if(responseJson.hasOwnProperty('error'))
				{
					showError('error',responseJson.error.msg,'Alerta - Aimaro','');
				}
				else if(responseJson.hasOwnProperty('success'))
				{
					if(responseJson.success.msg==="NOK")
					{
						intervenienteValidado = false;
						chamaCadastroIntervenienteGarantidor(nrcpfcgc);
					}else if(responseJson.success.msg==="OK")
					{
						intervenienteValidado = true;
						manterRotina('VD');
					}
				}			
				
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','');
			}
		}
	});
}

function chamaPesquisaCep()
{
	showMsgAguardo("Buscando CEP ...");
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/manbem/interveniente/pesquisa_cep.php",
		data: {
			nrcepend : nrcepend,
			redirect: "html_ajax"
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
		},
        success: function (response) {
			$("#divUsoGAROPC").html(response);
			$("#divUsoGAROPC").centralizaRotinaH();
			$("#divPesquisaEndereco").css("visibility","visible");
			$("#divUsoGAROPC").setCenterPosition();
			
		}				
	});
	hideMsgAguardo(); 
}


/*!
 * OBJETIVO: FunÁ„o para pedir senha de Coordenador/Gerente para processo especial
 */
function chamaCadastroIntervenienteGarantidor(nrcpfcgc) {
	showMsgAguardo("Cadastre o interveniente garantidor para continuar ...");			
	
	// Resetar a Global com operador de liberacao
    glb_codigoOperadorLiberacao = 0;

	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/manbem/interveniente/interv_garantidor.php",
		data: {
			nrcpfcgc : nrcpfcgc,
			redirect: "html_ajax"
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
		},
        success: function (response) {
			$("#divUsoGenerico").html(response);
			$("#divUsoGenerico").centralizaRotinaH();
		}				
	});
	$("#divUsoGenerico").css("visibility","visible");
    $("#divUsoGenerico").setCenterPosition();
    hideMsgAguardo(); 	
	
}

function salvaFormInterveniente()
{
		nrcepend       =	$('#nrcepend', '#frmIntevAnuente').val();
		dsendre1       =	$('#dsendre1', '#frmIntevAnuente').val();
		nmdavali       =	$('#nmdavali', '#frmIntevAnuente').val();
		tpdocava       =	$('#tpdocava', '#frmIntevAnuente').val();
		nrdocava       =	$('#nrdocava', '#frmIntevAnuente').val();       
		nmconjug       =	$('#nmconjug', '#frmIntevAnuente').val();
		nrcpfcjg       =	$('#nrcpfcjg', '#frmIntevAnuente').val();
		tpdoccjg       =	$('#tpdoccjg', '#frmIntevAnuente').val();
		nrdoccjg       =	$('#nrdoccjg', '#frmIntevAnuente').val();
		cdnacion       =	$('#cdnacion', '#frmIntevAnuente').val();
		dsnacion       =	$('#dsnacion', '#frmIntevAnuente').val();		
		dsendre2       = 	$('#dsendre2', '#frmIntevAnuente').val();
		nrfonres       = 	$('#nrfonres', '#frmIntevAnuente').val();
		dsdemail       = 	$('#dsdemail', '#frmIntevAnuente').val();
		nmcidade       = 	$('#nmcidade', '#frmIntevAnuente').val();
		cdufresd       = 	$('#cdufresd', '#frmIntevAnuente').val();
		nrendere       = 	$('#nrendere', '#frmIntevAnuente').val();
		complend       = 	$('#complend', '#frmIntevAnuente').val();
		nrcxapst       = 	$('#nrcxapst', '#frmIntevAnuente').val();
}

/*!
 * OBJETIVO: 
 */	
function cancelaCadastroInterveniente() {
	salvaFormInterveniente();
    $("#divUsoGenerico").css("visibility", "hidden");
	$("#divUsoGenerico").html("");	
		unblockBackground();

}
function cancelaPesquisaCep() {

    $("#divUsoGAROPC").css("visibility", "hidden");
	$("#divUsoGAROPC").html("");	
		unblockBackground();

}

/****************************************   ValidaÁıes   ****************************************************/
function validaInterveniente()
{
	if(validaCamposInterveniente())
	{
		
		nrcepend       =	$('#nrcepend', '#frmIntevAnuente').val();
		dsendre1       =	$('#dsendre1', '#frmIntevAnuente').val();
		nmdavali       =	$('#nmdavali', '#frmIntevAnuente').val();
		nrcpfcgc       =	$('#nrcpfcgc', '#frmIntevAnuente').val();
		tpdocava       =	$('#tpdocava', '#frmIntevAnuente').val();
		nrdocava       =	$('#nrdocava', '#frmIntevAnuente').val();       
		nmconjug       =	$('#nmconjug', '#frmIntevAnuente').val();
		nrcpfcjg       =	$('#nrcpfcjg', '#frmIntevAnuente').val();
		tpdoccjg       =	$('#tpdoccjg', '#frmIntevAnuente').val();
		nrdoccjg       =	$('#nrdoccjg', '#frmIntevAnuente').val();
		cdnacion       =	$('#cdnacion', '#frmIntevAnuente').val();		

		/*********************************GravaÁ„o ****************************/
		dsendre2       = 	$('#dsendre2', '#frmIntevAnuente').val();
		nrfonres       = 	$('#nrfonres', '#frmIntevAnuente').val();
		dsdemail       = 	$('#dsdemail', '#frmIntevAnuente').val();
		nmcidade       = 	$('#nmcidade', '#frmIntevAnuente').val();
		cdufresd       = 	$('#cdufresd', '#frmIntevAnuente').val();
		nrendere       = 	$('#nrendere', '#frmIntevAnuente').val();
		complend       = 	$('#complend', '#frmIntevAnuente').val();
		nrcxapst       = 	$('#nrcxapst', '#frmIntevAnuente').val();

		$.trim(nmdavali.toUpperCase());		
		$.trim(nmconjug.toUpperCase());		
		$.trim(dsendre1.toUpperCase());
		$.trim(complend.toUpperCase());
		$.trim(dsendre2.toUpperCase());
		$.trim(nmcidade.toUpperCase());
		$.trim(dsdemail.toUpperCase());

		nrcepend=normalizaNumero(nrcepend);
		nrcpfcgc=normalizaNumero(nrcpfcgc);	
		nrdocava=normalizaNumero(nrdocava);
		nrcpfcjg=normalizaNumero(nrcpfcjg);
		nrdoccjg=normalizaNumero(nrdoccjg);
		nrfonres=normalizaNumero(nrfonres);
		nrendere=normalizaNumero(nrendere);
		nrcxapst=normalizaNumero(nrcxapst);

		if(tipoPessoa==2)
		{
			nrcpfcjg="";
			nrdocava="";
			nrdoccjg="";
		}

		$.ajax({		
				type: "POST", 
				dataType: "html",
				url: UrlSite + "telas/manbem/interveniente/valida_interveniente.php",
				data: {
						nrdconta	: 	nrdconta, // global
						nrcepend    :	nrcepend,
						dsendre1    :   dsendre1,
						nmdavali    :   nmdavali,
						nrcpfcgc    :   nrcpfcgc,
						tpdocava    :   tpdocava,
						nrdocava    :   nrdocava,      
						nmconjug    :   nmconjug,
						nrcpfcjg    :   nrcpfcjg,
						tpdoccjg    :   tpdoccjg,
						nrdoccjg    :   nrdoccjg,
						cdnacion    :   cdnacion,
						//nrcpfcgc 	: 	nrcpfcgc,
						redirect	: 	"html_ajax"
				},		
				error: function (objAjax, responseError, objExcept) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
				},
				success: function (response) {
					try 
					{	
						hideMsgAguardo();
						var responseJson = $.parseJSON(response);	
						if(responseJson.hasOwnProperty('error'))
						{
							showError('error',responseJson.error.msg,'Alerta - Aimaro','');
						}
						else if(responseJson.hasOwnProperty('success'))
						{
							intervenienteValidado=true;
							manterRotina('VD'); 
						}		
						return false;
					} catch(error) {
						hideMsgAguardo();
						//showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','estadoInicial();');
					}
				}				
			}); 
	}
}

function validaCamposInterveniente(){
	var invalidos=0;
	errorMessage = "";
	
	if(!validaCampo( 'nmdavali', '#frmIntevAnuente')){invalidos=invalidos+1;}
	if(!validaCampo( 'nrcpfcgc', '#frmIntevAnuente')){invalidos=invalidos+1;}
	if(!validaCampo( 'cdnacion', '#frmIntevAnuente')){invalidos=invalidos+1;}
	if(!validaCampo( 'nrcepend', '#frmIntevAnuente')){invalidos=invalidos+1;}

	if(tipoPessoa==1)
	{
		if(!validaCampo('tpdocava', '#frmIntevAnuente')){invalidos=invalidos+1;}
		if(!validaCampo('nrdocava', '#frmIntevAnuente')){invalidos=invalidos+1;}
	}

	if(invalidos>0)
	{
		$("#msgErro").show();
		showError('error','Preencha os seguintes campos obrigatorios:<br/><br/>'+errorMessage ,'Alerta - Aimaro','');
		return false;
	}
	else{
		$("#msgErro").hide();
		return true;
	}
}

/****************************************   Mascaras   ****************************************************/
function mascaraCPF(evt){
	$("#" + evt.target.id).setMask('INTEGER','999.999.999-99','.-','');	
}

function ajustaParaPessoaJuridica()
{
	bloqueiaCampo($('#tpdocava', '#frmIntevAnuente'));
	bloqueiaCampo($('#nrdocava', '#frmIntevAnuente'));
	bloqueiaCampo($('#nmconjug', '#frmIntevAnuente'));
	bloqueiaCampo($('#nrcpfcjg', '#frmIntevAnuente'));
	bloqueiaCampo($('#tpdoccjg', '#frmIntevAnuente'));
	bloqueiaCampo($('#nrdoccjg', '#frmIntevAnuente'));
	
	//$("label[for='nrcpfcgc']").text("C.N.P.J :");	
}

function gravaInterveniente(){
	$.ajax({		
				type: "POST", 
				dataType: "html",
				url: UrlSite + "telas/manbem/interveniente/grava_interveniente.php",
				data: {						
						nrdconta	: 	nrdconta, // global
						nrctremp	: 	nrctremp, // global
						tpctrato    : 	tpctrato, // global

						nrcpfcgc    :   nrcpfcgc,
						nmdavali    :   nmdavali,
						nrcpfcjg    :   nrcpfcjg,
						nmconjug    :   nmconjug,
						tpdoccjg    :   tpdoccjg,
						nrdoccjg    :   nrdoccjg,
						tpdocava    :   tpdocava,
						nrdocava    :   nrdocava,      
						dsendre1    :   dsendre1,
						dsendre2    : 	dsendre2,
						nrfonres    : 	nrfonres,
						dsdemail    : 	dsdemail,
						nmcidade    : 	nmcidade,
						cdufresd    : 	cdufresd,
						nrcepend    :	nrcepend,
						cdnacion    :   cdnacion,					
						nrendere    : 	nrendere,
						complend    : 	complend,
						nrcxapst    : 	nrcxapst,
						redirect	: 	"html_ajax"
				},		
				error: function (objAjax, responseError, objExcept) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
				},
				success: function (response) {
					try {
						eval(response);					
						return false;
					} catch(error) {
						hideMsgAguardo();
						//showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','estadoInicial();');
					}
				}				
			}); 

}

/*************************************************  Pesquisas ***************************************************************/

function pesquisa(id)
{		
	var camposOrigem = 'nrcepend;dsendre1;nrendere;complend;nrcxapst;dsendre2;cdufresd;nmcidade';
	var vCep =$('#nrcepend','#frmIntevAnuente').val();

	switch(id)
	{
		case "cdnacion":
			bo = 'b1wgen0059.p';
			procedure = 'busca_nacionalidade';
			titulo = 'Nacionalidade';
			qtReg = '50';
			filtros = 'Codigo;cdnacion;30px;N;|Nacionalidade;dsnacion;200px;S;';
			colunas = 'Codigo;cdnacion;15%;left|Descri√ß√£o;dsnacion;85%;left';
			mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, divRotina);
			$("#divPesquisa").css('z-index', 1000);
		break;
		case "nrcepend":
			mostraPesquisaEndereco('frmIntevAnuente', camposOrigem, divRotina);
		break;
	}
}

function controlaPesquisa()
{
	//campos endereco
	var camposOrigem = 'nrcepend;dsendre1;nrendere;complend;nrcxapst;dsendre2;cdufresd;nmcidade';
	// CEP RESIDENCIAL
	$('#nrcepend','#frmIntevAnuente').buscaCEP('frmIntevAnuente', camposOrigem, divRotina);

	// Validar que o CEP do cooperado seja numa cidade de atuacao da cooperativa. Somente alerta, nao trava


	var nacio = $("#cdnacion"); 


	/*	cCEP.unbind('keydown').bind('keydown', function(e) { 
			if(divError.css('display') == 'block') { return false; }            
			if (e.keyCode == 13 || e.keyCode == 9) {
			
				mostraPesquisaEndereco(nomeForm, camposOrigem, divRotina, $(this).val());
				return false;
			}
			
		}).unbind('change').bind('change', function() {
			if ( normalizaNumero($(this).val()) == 0 ) {
				limparEndereco(camposOrigem, nomeForm);
			}
		});	
		cCEP.next().unbind('click').bind('click', function(){ // Bot√£o Pesquisa
			if( cCEP.hasClass('campo') ) mostraPesquisaEndereco(nomeForm, camposOrigem, divRotina);
			return false;
		});*/

}

function recuperaFormInterveniente()
{
	
	$('#nrcepend', '#frmIntevAnuente').val(nrcepend);
	$('#dsendre1', '#frmIntevAnuente').val(dsendre1);
	$('#nmdavali', '#frmIntevAnuente').val(nmdavali);
	$('#tpdocava', '#frmIntevAnuente').val(tpdocava);
	$('#nrdocava', '#frmIntevAnuente').val(nrdocava);       
	$('#nmconjug', '#frmIntevAnuente').val(nmconjug);
	$('#nrcpfcjg', '#frmIntevAnuente').val(nrcpfcjg);
	$('#tpdoccjg', '#frmIntevAnuente').val(tpdoccjg);
	$('#nrdoccjg', '#frmIntevAnuente').val(nrdoccjg);
	$('#cdnacion', '#frmIntevAnuente').val(cdnacion);	
	$('#dsnacion', '#frmIntevAnuente').val(dsnacion);		
	$('#dsendre2', '#frmIntevAnuente').val(dsendre2);
	$('#nrfonres', '#frmIntevAnuente').val(nrfonres);
	$('#dsdemail', '#frmIntevAnuente').val(dsdemail);
	$('#nmcidade', '#frmIntevAnuente').val(nmcidade);
	$('#cdufresd', '#frmIntevAnuente').val(cdufresd);
	$('#nrendere', '#frmIntevAnuente').val(nrendere);
	$('#complend', '#frmIntevAnuente').val(complend);
	$('#nrcxapst', '#frmIntevAnuente').val(nrcxapst);
}
