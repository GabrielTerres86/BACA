<?php 

	/**********************************************************************************
	 Fonte: aplicacao_carencia.php                                    
	 Autor: David                                                     
	 Data : Outubro/2010                             Última Alteração: 25/07/2014
	                                                                  
	 Objetivo  : Carregar períodos de carência para nova aplicação    	
	                                                                  	 
	 Alterações: 01/12/2010 - Alterado a chamada da BO b1wgen0004.p   
	                          para a BO b1wgen0081.p (Adriano). 

				 02/05/2014 - Ajuste referente ao projeto Captação							 
						      (Adriano).  
							  
				 25/07/2014 - Inclusao de novas condicoes para verificacao
							  de produtos novos ou antigos do projeto de captacao.
							  (Jean Michel).
							  
	***********************************************************************************/
	
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
	if (!isset($_POST["nrdconta"]) || !isset($_POST["tpaplica"]) || !isset($_POST["qtdiaapl"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];	
	$tpaplica = $_POST["tpaplica"];  /*Codigo do tipo da aplicacao*/		
	$idtippro = $_POST["idtippro"];  /*Verifica se produto é PRE OU POS dos produtos novos*/
	$idprodut = $_POST["idprodut"];  /*Verifica se é produto novo ou antigo*/					
	$qtdiaapl = $_POST["qtdiaapl"];
	$qtdiacar = $_POST["qtdiacar"];
		
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se tipo da aplicação é um inteiro válido
	if (!validaInteiro($tpaplica)) {
		exibeErro("Tipo de aplica&ccedil;&atilde;o inv&aacute;lida.");
	}	
	
	// Verifica se quantidade de dias é um inteiro válido
	if (!validaInteiro($qtdiaapl)) {
		exibeErro("Quantidade de dias inv&aacute;lida.");
	}
	
	// Verifica se quantidade de dias de carencia é um inteiro válido
	if (!validaInteiro($qtdiacar)) {
		exibeErro("Car&ecirc;ncia inv&aacute;lida.");
	}
	
	
	if($idprodut == 'A'){ // Produtos antigos
		
		// Monta o xml de requisição
		$xmlCarencia  = "";
		$xmlCarencia .= "<Root>";
		$xmlCarencia .= "	<Cabecalho>";
		$xmlCarencia .= "		<Bo>b1wgen0081.p</Bo>";
		$xmlCarencia .= "		<Proc>obtem-dias-carencia</Proc>";
		$xmlCarencia .= "	</Cabecalho>";
		$xmlCarencia .= "	<Dados>";
		$xmlCarencia .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlCarencia .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlCarencia .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlCarencia .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlCarencia .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlCarencia .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xmlCarencia .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlCarencia .= "		<idseqttl>1</idseqttl>";
		$xmlCarencia .= "		<tpaplica>".$tpaplica."</tpaplica>";
		$xmlCarencia .= "		<qtdiaapl>".$qtdiaapl."</qtdiaapl>";		
		$xmlCarencia .= "		<qtdiacar>".$qtdiacar."</qtdiacar>";		
		$xmlCarencia .= "		<flgvalid>no</flgvalid>";
		$xmlCarencia .= "	</Dados>";
		$xmlCarencia .= "</Root>";	
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlCarencia);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjCarencia = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra cr&iacute;tica
		if (strtoupper($xmlObjCarencia->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjCarencia->roottag->tags[0]->tags[0]->tags[4]->cdata);
		} 
		
		$carencia   = $xmlObjCarencia->roottag->tags[0]->tags;	
		$qtCarencia = count($carencia);
	?>
	var tpaplrdc = <?php echo $idtippro; ?>;
	
	cdperapl = <?php echo $carencia[0]->tags[0]->cdata == "" ? 0 : $carencia[0]->tags[0]->cdata; ?>;
	
	if (tpaplrdc == 1) { // RDCPRE			
		
		aux_qtdiaapl = '<?php echo$carencia[0]->tags[1]->cdata; ?>';
		aux_qtdiacar = '<?php echo$carencia[0]->tags[3]->cdata; ?>';
			
		$("#qtdiacar","#frmDadosAplicacaoPre").val("<?php echo$carencia[0]->tags[3]->cdata; ?>");
			
		hideMsgAguardo();
		blockBackground(parseInt($("#divRotina").css("z-index")));	
		
		var vllanmto = (tpaplrdc == 1) ? parseFloat($("#vllanmto","#frmDadosAplicacaoPre").val().replace(/\./g,"").replace(/\,/g,".")) : parseFloat($("#vllanmto","#frmDadosAplicacaoPos").val().replace(/\./g,"").replace(/\,/g,"."));
				
		if (vllanmto > 0) {
			obtemTaxaAplicacao();
		} 	
		
	} else {
			
		var strHTML = "";
		strHTML += '<table border="0" cellpadding="0" cellspacing="0">';
		strHTML += '	<tr>';
		strHTML += '		<td>';
		strHTML += '			<table border="0" cellpadding="1" cellspacing="1">';
		strHTML += '				<tr style="background-color: #F4D0C9;">';
		strHTML += '					<td width="45" class="txtNormalBold" align="right">Per&iacute;odo</td>';
		strHTML += '					<td width="35" class="txtNormalBold" align="right">In&iacute;cio</td>';
		strHTML += '					<td width="35" class="txtNormalBold" align="right">Fim</td>';
		strHTML += '					<td width="57" class="txtNormalBold" align="right">Car&ecirc;ncia</td>';
		strHTML += '					<td width="15" class="txtNormalBold" align="right" style="background-color: #FFFFFF;"><a href="#" onClick="fechaZoomCarencia(\'<?php echo $carencia[0]->tags[0]->cdata; ?>\',\'<?php echo $carencia[0]->tags[2]->cdata; ?>\',\'<?php echo$carencia[0]->tags[3]->cdata; ?>\',\'<?php echo$carencia[0]->tags[4]->cdata; ?>\',false);return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.gif" border="0"></a></td>';
		strHTML += '				</tr>';
		strHTML += '			</table>';
		strHTML += '		</td>';
		strHTML += '	</tr>';
		strHTML += '	<tr>';
		strHTML += '		<td>';
		strHTML += '			<div id="divPeriodosCarencia" style="overflow-y: scroll; overflow-x: hidden; height: 100px; width: 100%;">';
		strHTML += '				<table width="185" border="0" cellpadding="1" cellspacing="1">';
		<?php 
		$cor = "";

		for ($i = 0; $i < $qtCarencia; $i++) { 
			if ($cor == "#F4F3F0") {
				$cor = "#FFFFFF";
			} else {
				$cor = "#F4F3F0";
			}	
		?>
		strHTML += '					<tr style="cursor: pointer; background-color: <?php echo $cor; ?>" onClick="selecionaCarencia(<?php echo $carencia[$i]->tags[0]->cdata; ?>,\'<?php echo $carencia[$i]->tags[2]->cdata; ?>\',\'<?php echo$carencia[$i]->tags[3]->cdata; ?>\',\'<?php echo$carencia[$i]->tags[4]->cdata; ?>\',false);">';
		strHTML += '						<td width="45" class="txtNormal" align="right"><?php echo $carencia[$i]->tags[0]->cdata; ?></td>';
		strHTML += '						<td width="35" class="txtNormal" align="right"><?php echo formataNumericos("zzz.zzz",$carencia[$i]->tags[1]->cdata,"."); ?></td>';
		strHTML += '						<td width="35" class="txtNormal" align="right"><?php echo formataNumericos("zzz.zzz",$carencia[$i]->tags[2]->cdata,"."); ?></td>';
		strHTML += '						<td class="txtNormal" align="right"><?php echo $carencia[$i]->tags[3]->cdata; ?></td>';
		strHTML += '					</tr>';
		<?php
		} // Fim do for
		?>				
		strHTML += '				</table>';
		strHTML += '			</div>';
		strHTML += '		</td>';
		strHTML += '	</tr>';
		strHTML += '</table>';
				
		$("#divSelecionaCarencia").html(strHTML);
		$("#divSelecionaCarencia").show();
		
		hideMsgAguardo();
		blockBackground(parseInt($("#divRotina").css("z-index")));
				
			}
	<?php
		
	}else{ // Novos produtos
		// Montar o xml de Requisicao
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "   <cdprodut>".$tpaplica."</cdprodut>";
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
			exibirErro('error',$msgErro,'Alerta - Aimaro','blockBackground(parseInt($(\"#divRotina\").css(\"z-index\"))); verificaTipoAplicacao(); cVllanmtoPos.focus();',false);
			exit();
		}else{
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
			strHTML += '					<tr style="cursor: pointer; background-color: <?php echo $cor; ?>" onClick="selecionaCarenciaCaptacao(\'<?php echo $registro->tags[0]->cdata; ?>\',\'<?php echo $registro->tags[1]->cdata; ?>\');">';
			
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
	}
		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>