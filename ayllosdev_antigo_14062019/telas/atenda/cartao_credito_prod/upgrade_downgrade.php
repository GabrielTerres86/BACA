<?php
/*!
 * FONTE        : upgrade_downgrade.php
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : Abril/2014
 * OBJETIVO     : Mostrar opção de troca de Administradoras de cartões da tela ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000:
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$funcaoAposErro = 'bloqueiaFundo(divRotina);';
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"D")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro',$funcaoAposErro);	
	}			
	
	// Verifica se o número do cartao foi informado
	if (!isset($_POST["nrcrcard"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro);	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro);	
	
	$nrdconta = $_POST["nrdconta"];
	$nrcrcard = $_POST["nrcrcard"];
		
	// Verifica se o número do cartao é um inteiro válido
	if (!validaInteiro($nrcrcard)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);
	
	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);
	

	// Monta o xml de requisição
	$xmlGetCartao  = "";
	$xmlGetCartao .= "<Root>";
	$xmlGetCartao .= "	<Cabecalho>";
	$xmlGetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlGetCartao .= "		<Proc>carrega_dados_administradoras</Proc>";
	$xmlGetCartao .= "	</Cabecalho>";
	$xmlGetCartao .= "	<Dados>";
	$xmlGetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetCartao .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlGetCartao .= "	</Dados>";
	$xmlGetCartao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetCartao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$funcaoAposErro);	
	}else{
		//Caso consulta retorne dados
		$admatual = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[0]->cdata;
		$admnnova = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[1]->cdata;
		
		$arradmat = explode(",",$admatual);
		$arradmno = explode(";",$admnnova);
		
		$cdcadmat = $arradmat[0];
		$dscadmat = $arradmat[1];		
	}		
	
?>

<form action="" name="frmNovoCartao" id="frmNovoCartao" method="post" onSubmit="return false;">			
	<div id="divUpDown">
		<input type="hidden" name="hdncodadm" id="hdncodadm" value="<?php echo $cdcadmat; ?>" />
		<fieldset>
			<legend><? echo utf8ToHtml('Upgrade / Downgrade de Cart&atilde;o') ?></legend>
			<table>
				<tr>
					<td><label for="dsadmatu"><? echo utf8ToHtml('Administradora Atual:') ?></label></td>
					<td><input type="text" name="dsadmatu" id="dsadmatu" class="campo" value=" <?php echo $cdcadmat . " - " . $dscadmat; ?> " style="width:252px" /></td>
				</tr>
				<tr>
					<td><label for="dsadmant"><? echo utf8ToHtml('Nova Administradora:') ?></label></td>
					<td>
						<select name="dsadmant" id="dsadmant" class="campo">
							<option value="0">Selecione uma Administradora</option>
							<?php
								for ($i = 0; $i <= count($arradmno); $i++){
									
									$arrNovaAdm = explode(",",$arradmno[$i]);
									
									if ($arrNovaAdm[0] != 0){
							?>		
										<option value="<?php echo($arrNovaAdm[0]); ?>" > <?php echo($arrNovaAdm[1]); ?> </option>
							<?php	
									}
								}
							?>			
						</select>
					</td>
				</tr>
			</table>
			
			<div id="divBotoes" >
				<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(0,1,4);return false;">
				<input type="image" id="btSalvar" src="<?echo $UrlImagens; ?>botoes/concluir.gif" onClick="validarUpDown();return false;">
			</div>
		</fieldset>
	</div>
</form>

<script type="text/javascript">

// Mostra o div da Tela da opção
$("#divOpcoesDaOpcao1").css("display","block");
// Esconde os cartões
$("#divConteudoCartoes").css("display","none");

$("#dsadmatu").prop("disabled",true);

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que esta átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>