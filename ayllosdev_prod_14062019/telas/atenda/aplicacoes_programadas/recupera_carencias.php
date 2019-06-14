<?php 

	/**********************************************************************************
	 Fonte: recupera_carencias.php                                    
	 Autor: CIS Corporate                                                     
	 Data : Outubro/2018                             �ltima Altera��o: 
	                                                                  
	 Objetivo  : Carregar per�odos de car�ncia para nova aplica��o programada.
	 	         Derivada da aplicao_carencia.php
				 Proj. 411.2  - CIS Corporate    	
	                                                                  	 
	 Altera��es:   
							  
	***********************************************************************************/
	
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
	if (!isset($_POST["nrdconta"]) || 
		!isset($_POST["cdprodut"]) || 
		!isset($_POST["idtippro"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];	
	$cdprodut = $_POST["cdprodut"];  /*Codigo do produto pcapta*/		
	$idtippro = $_POST["idtippro"];  /*Verifica se produto �  PRE = 1 OU POS =2 dos produtos novos*/
	$qtdiaapl = $_POST["qtdiaapl"];
	$qtdiacar = $_POST["qtdiacar"];
		
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica o produto � v�lido
	if (!validaInteiro($cdprodut)) {
		exibeErro("Tipo de aplica&ccedil;&atilde;o inv&aacute;lida.");
	}	
	
	// Verifica se quantidade de dias � um inteiro v�lido
	if (!validaInteiro($qtdiaapl)) {
		exibeErro("Quantidade de dias inv&aacute;lida.");
	}
	
	// Verifica se quantidade de dias de carencia � um inteiro v�lido
	if (!validaInteiro($qtdiacar)) {
		exibeErro("Car&ecirc;ncia inv&aacute;lida.");
	}

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <cdprodut>".$cdprodut."</cdprodut>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "ATENDA", "OBTCAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
			
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
		
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}		
		exibirErro('error',$msgErro,'Alerta - Ayllos','blockBackground(parseInt($(\"#divRotina\").css(\"z-index\"))); \Cvlprerpp.focus();',false);
		exit();
	} else {
		$qtdRegistros = count($xmlObj->roottag->tags[0]);		
?>
		var strHTML = "";
		strHTML += '<table border="0" cellpadding="0" cellspacing="0">';
		strHTML += '	<tr>';
		strHTML += '		<td>';
		strHTML += '			<table border="0" cellpadding="1" cellspacing="1">';
		strHTML += '				<tr style="background-color: #F4D0C9;">';
		strHTML += '					<td width="70" class="txtNormalBold" align="center">Car&ecirc;ncia</td>';
		strHTML += '					<td width="70" class="txtNormalBold" align="center">Prazo</td>';
		strHTML += '					<td width="15" class="txtNormalBold" align="right" style="background-color: #FFFFFF; padding-bottom:5px;"><a href="#" onClick="fechaZoomCarencia(\'\',false);return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.gif" border="0"></a></td>';
		strHTML += '				</tr>';
		strHTML += '			</table>';
		strHTML += '		</td>';
		strHTML += '	</tr>';
		strHTML += '	<tr>';
		strHTML += '		<td>';
	<?php	
		if($qtdRegistros == 0){
	?>
			strHTML += '			<div id="divPeriodosCarencia" style="overflow-y: scroll; overflow-x: hidden; height: 100px; width: 100%;">';
			strHTML += '				<table width="165" border="0" cellpadding="1" cellspacing="1">';
			strHTML += '					<tr style="cursor: pointer;">';
			strHTML += '						<td colspan="3"width="100%" class="txtNormal" align="center">N&atilde;o foi encontrada modalidade na pol&iacute;tica de capta&ccedil;&atilde;o para o produto selecionado. </td>';
			strHTML += '					</tr>';		
			strHTML += '				</table>';
			strHTML += '			</div>';
	<?php
		}else{
			$registros = $xmlObj->roottag->tags;
			$cor = "#F4F3F0";
		
	?>	
			strHTML += '			<div id="divPeriodosCarencia" style="overflow-y: scroll; overflow-x: hidden; height: 100px; width: 100%;">';
			strHTML += '				<table width="165" border="0" cellpadding="1" cellspacing="1">';
			<?php
				foreach ($registros as $registro){
					if ($cor == "#F4F3F0") {
						$cor = "#FFFFFF";
					} else {
						$cor = "#F4F3F0";
					}	
			?>
			strHTML += '					<tr style="cursor: pointer; background-color: <?php echo $cor; ?>" onClick="selecionaCarenciaApProg(\'<?php echo $registro->tags[0]->cdata; ?>\',\'<?php echo $registro->tags[1]->cdata; ?>\');">';
			
			strHTML += '						<td width="65" class="txtNormal" align="right"><?php echo formataNumericos("zzz.zzz",$registro->tags[0]->cdata,"."); ?></td>';
			strHTML += '						<td width="65" class="txtNormal" align="right"><?php echo formataNumericos("zzz.zzz",$registro->tags[1]->cdata,"."); ?></td>';
			strHTML += '						<td width="25" class="txtNormal" align="right"></td>';
			strHTML += '					</tr>';	
			<?php
				}
			?>
			strHTML += '				</table>';
			strHTML += '			</div>';
	<?php	
		}	
	?>
		strHTML += '		</td>';
		strHTML += '	</tr>';
		strHTML += '</table>';
			
		$("#divSelecionaCarencia").html(strHTML);
		$("#divSelecionaCarencia").show();
	
		hideMsgAguardo();
		blockBackground(parseInt($("#divRotina").css("z-index")));
<?php	
	}

	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>