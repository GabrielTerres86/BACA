<?php 

	/************************************************************************
	 Fonte: aplicacao_obtem_dados.php                                 
	 Autor: David                                                     
	 Data : Outubro/2010                 Última Alteração: 08/10/2015
	                                                                  
	 Objetivo  : Obter dados para alterar ou incluir nova aplicação   
	                                                                   
	 Alterações: 01/12/2010 - Alterado a chamada da BO b1wgen0004.p   
	                          para a BO b1wgen0081.p (Adriano).       
	                                                                   
	 			  23/08/2013 - Implementação novos produtos Aplicação 
						       (Lucas).	

				  30/04/2014 - Ajuste referente ao projeto Captação.							  
							  (Adriano).
							  
			      11/09/2014 - Incluidos parametros no values do select
							   (Jean Michel).
				  
				  20/01/2015 - Tratamento para exclusão de novas aplicacoes
							   (Jean Michel).
							   
			      08/10/2015 - Reformulacao cadastral (Gabriel-RKAM).				   
							  
				  04/04/2018 - Chamada da rotina para verificar se o tipo de conta permite 
				               produto 16 - Poupança Programada. PRJ366 (Lombardi).
							  
	**************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	// Se parâmetros necessários não foram informados
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

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se número da aplicação é um inteiro válido
	if (!validaInteiro($nraplica) && $nraplica != 0) {
		exibeErro("Aplica&ccedil;&atilde;o inv&aacute;lida.");
	}	
	
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cdprodut>". 3 ."</cdprodut>"; //Aplicação
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_ADESAO_PRODUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro(utf8_encode($msgErro));
	}
	
	// Monta o xml de requisição
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
	
	// Monta select com tipos de aplicação disponíveis para cadastro
	echo 'var strSelect = "";';	
	for ($i = 0; $i < $qtTipos; $i++) { 			
		echo 'strSelect += \'<option value="'.$tipos[$i]->tags[0]->cdata.','.$tipos[$i]->tags[2]->cdata.','.$tipos[$i]->tags[3]->cdata.'" >'.$tipos[$i]->tags[1]->cdata.'</option>\';';					
	} 	
	
	echo '$("#tpaplica","#frmDadosAplicacao").html(strSelect);';
	
	// Inicializa campos do form e variáveis globais
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
	
	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
	
	// Mostra div com form para inclusão ou alteração	
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
			showConfirmacao('Confirma a exclusao da aplica&ccedil;&atilde;o <?php echo $dsaplica; ?> ?','Confirma&ccedil;&atilde;o - Aimaro','buscaDadosAplicacao("E");','voltarDivPrincipal(); auxExcluir = 0;','sim.gif','nao.gif');
		<?php
		}else{
		?>
			cFlgrecnoPos.hide();
			rFlgrecnoPos.hide();
			showConfirmacao('Confirma a exclusao da aplica&ccedil;&atilde;o <?php echo $dsaplica; ?> ?','Confirma&ccedil;&atilde;o - Aimaro','controlarAplicacao(false,"<?php echo $cddopcao; ?>"); auxExcluir = 0;','voltarDivPrincipal(); auxExcluir = 0;','sim.gif','nao.gif');
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
				
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>