<?php 

	//************************************************************************//
	//*** Fonte: listagem_push.php                                         ***//
	//*** Autor: Jean Michel                                               ***//
	//*** Data : Setembro/2017                   Última Alteração:  			 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar listagem de dispositivos Mobile							 ***//
	//****																							    						   ***//
	//***                                                                  ***//	 
	//*** Alterações: 																									   ***//
	//***                                                                  ***//	 
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	
	
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '<nrdconta>' . $nrdconta . '</nrdconta>';	
	$xml .= '<idseqttl>' . $idseqttl . '</idseqttl>'; 
	$xml .= '	</Dados>';
	$xml .= '</Root>';
		
	// Enviar XML de ida e receber String XML de resposta		pc_relatorio_custos_orcados_
	$xmlResult = mensageria($xml, 'TELA_ATENDA_INTERNET', 'LISTAGEM_PUSH', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
		
	$dispositivos = $xmlObjeto->roottag->tags[0]->tags[2]->tags;
	
	$qtDispositivos = count($dispositivos);
	
?>
<div id="divDispositivos" name="divDispositivos">
	<form action="" method="post" name="frmOpDesativaPush" id="frmOpDesativaPush" onSubmit="return false;">
		<input type="hidden" id="qtdDispositivos" name="qtdDispositivos" value="<?php echo $qtDispositivos; ?>" />
		<fieldset>
			<legend><? echo utf8ToHtml('Dispositivos que recebem alertas de notificações') ?></legend>
			<div class="divRegistros">
				<table id="tableDispositivos" name="tableDispositivos">
					<thead>
						<tr>
							<th>Data da Cria&ccedil;&atilde;o</th>
							<th>Modelo do Dispositivo</th>
							<th>SO</th>
						</tr>
					</thead>
					<tbody>
						<?php
							if($qtDispositivos > 0){
								for ($i = 0; $i < $qtDispositivos; $i++){ 
								  if($i == 0){
										echo "<script>selecionaMobile(".$dispositivos[$i]->tags[0]->cdata.");</script>";
									}
						?>
							<tr onclick="selecionaMobile(<?php echo $dispositivos[$i]->tags[0]->cdata; ?>);">
								<td><?php echo $dispositivos[$i]->tags[2]->cdata; ?></td>
								<td><?php echo $dispositivos[$i]->tags[1]->cdata; ?></td>
								<td><?php echo $dispositivos[$i]->tags[3]->cdata; ?></td>
							</tr>
						<?php	
								}
							}else{
								?>
								<tr>
									<td colspan="3" style="text-align: center;">Nenhum dispositivo cadastrado para receber notifica&ccedil;&otilde;es</td>
								</tr>
								<?php
							}
						?>
					</tbody>
				</table>
			</div>
			<br />
		</fieldset>	
				
		<a href="#" class="botao" id="btnvoltar" name="btnvoltar" style="margin-left:180px;" onClick="redimensiona(); carregaHabilitacao(); return false;" >&nbsp;Voltar&nbsp;</a>
		<a href="#" class="botao" id="btnDesativar" name="btnDesativar" onClick="desativarEnvioPush();" >&nbsp;Desativar envio de Alertas&nbsp;</a>
	</form>
</div>

<script type="text/javascript">
	
	controlaLayout('frmOpDesativaPush');
	
	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>