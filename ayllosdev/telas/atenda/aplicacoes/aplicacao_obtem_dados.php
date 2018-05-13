<?php 

	/************************************************************************
	 Fonte: aplicacao_obtem_dados.php                                 
	 Autor: David                                                     
	 Data : Outubro/2010                 �ltima Altera��o: 08/10/2015
	                                                                  
	 Objetivo  : Obter dados para alterar ou incluir nova aplica��o   
	                                                                   
	 Altera��es: 01/12/2010 - Alterado a chamada da BO b1wgen0004.p   
	                          para a BO b1wgen0081.p (Adriano).       
	                                                                   
	 			  23/08/2013 - Implementa��o novos produtos Aplica��o 
						       (Lucas).	

				  30/04/2014 - Ajuste referente ao projeto Capta��o.							  
							  (Adriano).
							  
			      11/09/2014 - Incluidos parametros no values do select
							   (Jean Michel).
				  
				  20/01/2015 - Tratamento para exclus�o de novas aplicacoes
							   (Jean Michel).
							   
			      08/10/2015 - Reformulacao cadastral (Gabriel-RKAM).				   
							  
	**************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nraplica"]) || !isset($_POST["cddopcao"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nraplica = $_POST["nraplica"];
	$cddopcao = $_POST["cddopcao"];	
	$tpaplica = $_POST["tpaplica"];		
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibeErro($msgError);		
	}

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se n�mero da aplica��o � um inteiro v�lido
	if (!validaInteiro($nraplica) && $nraplica != 0) {
		exibeErro("Aplica&ccedil;&atilde;o inv&aacute;lida.");
	}	
	
	// Monta o xml de requisi��o
	$xmlAplicacao  = "";
	$xmlAplicacao .= "<Root>";
	$xmlAplicacao .= "	<Cabecalho>";
	$xmlAplicacao .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlAplicacao .= "		<Proc>buscar-dados-aplicacao</Proc>";
	$xmlAplicacao .= "	</Cabecalho>";
	$xmlAplicacao .= "	<Dados>";
	$xmlAplicacao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlAplicacao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlAplicacao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlAplicacao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlAplicacao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlAplicacao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlAplicacao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlAplicacao .= "		<idseqttl>1</idseqttl>";
	$xmlAplicacao .= "		<cddopcao>".$cddopcao."</cddopcao>";			
	$xmlAplicacao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlAplicacao .= "		<nraplica>".$nraplica."</nraplica>";						
	$xmlAplicacao .= "	</Dados>";
	$xmlAplicacao .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlAplicacao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAplicacao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjAplicacao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAplicacao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}	
	
	$tipos     = $xmlObjAplicacao->roottag->tags[0]->tags;	
	$aplicacao = $xmlObjAplicacao->roottag->tags[1]->tags[0];
	$qtTipos   = count($tipos);
	$dsaplica  = $aplicacao->tags[11]->cdata;
	
	// Monta select com tipos de aplica��o dispon�veis para cadastro
	echo 'var strSelect = "";';	
	for ($i = 0; $i < $qtTipos; $i++) { 			
		echo 'strSelect += \'<option value="'.$tipos[$i]->tags[0]->cdata.','.$tipos[$i]->tags[2]->cdata.','.$tipos[$i]->tags[3]->cdata.'" >'.$tipos[$i]->tags[1]->cdata.'</option>\';';					
	} 	
	
	echo '$("#tpaplica","#frmDadosAplicacao").html(strSelect);';
	
	// Inicializa campos do form e vari�veis globais
	echo 'tpaplrdc = '.$aplicacao->tags[0]->cdata.';';
	echo 'cdperapl = '.$aplicacao->tags[7]->cdata.';';
	echo 'glbqtdia = "'.$aplicacao->tags[4]->cdata.'";';
	echo 'glbvenct = "'.$aplicacao->tags[5]->cdata.'";';	
	echo 'flgDigitValor  = true;';
	echo 'flgDigitVencto = true;';
	
	$auxTpaplica = '1';
	
	if ($aplicacao->tags[2]->cdata != 7){
		$auxTpaplica = '2';
	}
	
	echo '$("#tpaplica","#frmDadosAplicacao").val("'.$aplicacao->tags[2]->cdata.','.$auxTpaplica.','.$tpaplica .'");';
	
	?>
	
	// Esconde mensagem de aguardo
	hideMsgAguardo();
	
	// Bloqueia conte�do que est� �tras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
	
	// Mostra div com form para inclus�o ou altera��o	
	$("#divConteudoOpcao").css("height","280px");
	$("#divAplicacoesPrincipal").css("display","none");
	
	<?php	
	
	if($aplicacao->tags[14]->cdata == 'no'){
		$aux_flgrecno = 0;
	}else{
		$aux_flgrecno = 1;
	}
	echo '$("#qtdiaapl","#frmDadosAplicacaoPos").val("'.$aplicacao->tags[4]->cdata.'");';
	echo '$("#dtresgat","#frmDadosAplicacaoPos").val("'.$aplicacao->tags[5]->cdata.'");';
	echo '$("#qtdiacar","#frmDadosAplicacaoPos").val("'.$aplicacao->tags[6]->cdata.'");';
	echo '$("#flgdebci","#frmDadosAplicacaoPos").val("'.$aplicacao->tags[8]->cdata.'");';
	echo '$("#vllanmto","#frmDadosAplicacaoPos").val("'.number_format(str_replace(",",".",$aplicacao->tags[9]->cdata),2,",",".").'");';
	echo '$("#txaplica","#frmDadosAplicacaoPos").val("'.number_format(str_replace(",",".",$aplicacao->tags[10]->cdata),8,",",".").'");';	
	echo '$("#dtcarenc","#frmDadosAplicacaoPos").val("'.$aplicacao->tags[12]->cdata.'");';	
	echo '$("#dsaplica","#frmDadosAplicacaoPos").val("'.$aplicacao->tags[13]->cdata.'");';
	echo '$("#flgrecno","#frmDadosAplicacaoPos").val("'.$aux_flgrecno.'");';

	echo '$("#qtdiaapl","#frmDadosAplicacaoPre").val("'.$aplicacao->tags[4]->cdata.'");';
	echo '$("#dtresgat","#frmDadosAplicacaoPre").val("'.$aplicacao->tags[5]->cdata.'");';
	echo '$("#qtdiacar","#frmDadosAplicacaoPre").val("'.$aplicacao->tags[6]->cdata.'");';
	echo '$("#flgdebci","#frmDadosAplicacaoPre").val("'.$aplicacao->tags[8]->cdata.'");';
	echo '$("#vllanmto","#frmDadosAplicacaoPre").val("'.number_format(str_replace(",",".",$aplicacao->tags[9]->cdata),2,",",".").'");';
	echo '$("#txaplica","#frmDadosAplicacaoPre").val("'.number_format(str_replace(",",".",$aplicacao->tags[10]->cdata),6,",",".").'");';	
	echo '$("#dsaplica","#frmDadosAplicacaoPre").val("'.$aplicacao->tags[11]->cdata.'");';
	
			
	if ($cddopcao == "E") {
			
		/*RDCPOS*/
		if($aplicacao->tags[2]->cdata == 8 || $tpaplica == "N"){?>
			
			$("input,select","#frmDadosAplicacao").desabilitaCampo();
			$("input,select","#frmDadosAplicacaoPos").desabilitaCampo();
			$("#divSelecionaCarencia").hide();
			$("#divDadosAplicacao").show();
			$("#frmDadosAplicacaoPre").hide();
			$("#frmDadosAplicacaoPos").show();			
			$("#divBtnAplicacao").css("display","none");
			
			<?php			
				if($tpaplica == "N"){
				?>
					cFlgrecnoPos.show();
					rFlgrecnoPos.show();
				<?php
				}
			?>
			
			<?php
		}else{?>
					
			$("input,select","#frmDadosAplicacao").desabilitaCampo();
			$("input,select","#frmDadosAplicacaoPre").desabilitaCampo();
			$("#divSelecionaCarencia").hide();			
			$("#divDadosAplicacao").show();
			$("#frmDadosAplicacaoPos").hide();
			$("#frmDadosAplicacaoPre").show();
			
			$("#divBtnAplicacao").css("display","none");
			cFlgrecnoPos.hide();
			rFlgrecnoPos.hide();
			
			<?php
		
		}
		
		if($tpaplica == "N"){
		?>
			auxExcluir = 1;
			showConfirmacao('Confirma a exclusao da aplica&ccedil;&atilde;o <?php echo $dsaplica; ?> ?','Confirma&ccedil;&atilde;o - Ayllos','buscaDadosAplicacao("E");','voltarDivPrincipal(); auxExcluir = 0;','sim.gif','nao.gif');
		<?php
		}else{
		?>
			cFlgrecnoPos.hide();
			rFlgrecnoPos.hide();
			showConfirmacao('Confirma a exclusao da aplica&ccedil;&atilde;o <?php echo $dsaplica; ?> ?','Confirma&ccedil;&atilde;o - Ayllos','controlarAplicacao(false,"<?php echo $cddopcao; ?>"); auxExcluir = 0;','voltarDivPrincipal(); auxExcluir = 0;','sim.gif','nao.gif');
		<?php
		}
		
	}else{?>
	
		tpaplrdc = 0;
		cdperapl = 0;
		aux_qtdiaapl = 0;
		aux_qtdiacar = 0;
		glbqtdia = "0";
		glbvenct = "";
		
		$("#tpaplica","#frmDadosAplicacao").habilitaCampo();
		
		$("#qtdiaapl","#frmDadosAplicacaoPos").habilitaCampo();
		$("#dtresgat","#frmDadosAplicacaoPos").habilitaCampo();
		$("#vllanmto","#frmDadosAplicacaoPos").habilitaCampo();		
		
		$("#qtdiaapl","#frmDadosAplicacaoPre").habilitaCampo();
		$("#dtresgat","#frmDadosAplicacaoPre").habilitaCampo();
		$("#vllanmto","#frmDadosAplicacaoPre").habilitaCampo();		
		
		$("#divDadosAplicacao").css("display","block");	
		$("#frmDadosAplicacaoPre").css("display","block");	
		$("#divBtnAplicacao").css("display","block");	
	
		$("#tpaplica option[value='8']","#frmDadosAplicacao").prop('selected',true);
		$("#tpaplica","#frmDadosAplicacao").trigger("blur");	
		$("#tpaplica","#frmDadosAplicacao").focus();
		ativaCampo();
	<?php
	}
				
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>