<?php 

	/******************************************************************************
	 Fonte: acumula_carencia.php                                      
	 Autor: David                                                     
	 Data : Outubro/2009                 Última Alteração: 26/06/2014
	                                                                  
	 Objetivo  : Script para obter carências permitidas para período  	
	                                                                  	 
	 Alterações: 13/10/2010 - Incluir novo parâmetro para função      
	                          selecionaCarencia (David).              
	                                                                  
	             01/12/2010 - Alterado a chamada da BO b1wgen0004.p   
	                          para a BO b1wgen0081.p (Adriano).     

				 26/06/2014 - Ajustes referente ao projeto do captação.
							  (Adriano).
							  
	*******************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["tpaplica"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$tpaplica = $_POST["tpaplica"];	
	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se tipo de aplicação é um inteiro válido
	if (!validaInteiro($tpaplica)) {
		exibeErro("Tipo de aplica&ccedil;&atilde;o inv&aacute;lida.");
	}	
	
			
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
	$xmlCarencia .= "		<qtdiacar>0</qtdiacar>";	
	$xmlCarencia .= "		<qtdiaapl>0</qtdiaapl>";		
	$xmlCarencia .= "		<flgvalid>no</flgvalid>";
	$xmlCarencia .= "	</Dados>";
	$xmlCarencia .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCarencia);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjCarencia = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCarencia->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCarencia->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$carencia   = $xmlObjCarencia->roottag->tags[0]->tags;	
	$qtCarencia = count($carencia);
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
		
?>
var strHTML = "";
strHTML += '<table border="0" cellpadding="0" cellspacing="0" >';
strHTML += '	<tr>';
strHTML += '		<td>';
strHTML += '			<table border="0" cellpadding="1" cellspacing="1">';
strHTML += '				<tr style="background-color: #F4D0C9;">';
strHTML += '					<td width="45" class="txtNormalBold" align="right">Per&iacute;odo</td>';
strHTML += '					<td width="35" class="txtNormalBold" align="right">In&iacute;cio</td>';
strHTML += '					<td width="35" class="txtNormalBold" align="right">Fim</td>';
strHTML += '					<td width="57" class="txtNormalBold" align="right">Car&ecirc;ncia</td>';
strHTML += '					<td width="15" class="txtNormalBold" align="right" style="background-color: #FFFFFF;"><a href="#" onClick="fechaZoomCarencia(\'<?php echo $carencia[0]->tags[0]->cdata; ?>\',\'<?php echo $carencia[0]->tags[2]->cdata; ?>\',\'<?php echo$carencia[0]->tags[3]->cdata; ?>\',\'<?php echo$carencia[0]->tags[4]->cdata; ?>\',true);return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.gif" border="0"></a></td>';
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
strHTML += '					<tr style="cursor: pointer; background-color: <?php echo $cor; ?>" onClick="selecionaCarencia(\'<?php echo $carencia[$i]->tags[0]->cdata; ?>\',\'<?php echo $carencia[$i]->tags[2]->cdata; ?>\',\'<?php echo$carencia[$i]->tags[3]->cdata; ?>\',\'<?php echo$carencia[$i]->tags[4]->cdata; ?>\',true);">';
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
		
$("#divCarencia").html(strHTML);
$("#divCarencia").css("visibility","visible");
	
hideMsgAguardo();
blockBackground(parseInt($("#divRotina").css("z-index")));