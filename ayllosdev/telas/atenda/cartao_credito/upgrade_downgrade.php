<?php
/*!
 * FONTE        : upgrade_downgrade.php
 * CRIA��O      : Jean Michel
 * DATA CRIA��O : Abril/2014
 * OBJETIVO     : Mostrar op��o de troca de Administradoras de cart�es da tela ATENDA
 * --------------
 * ALTERA��ES   :
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
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"D")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro',$funcaoAposErro);	
	}			
	
	// Verifica se o n�mero do cartao foi informado
	if (!isset($_POST["nrcrcard"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro);	
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro);	

	$nrdconta = $_POST["nrdconta"];
	$nrcrcard = $_POST["nrcrcard"];
	$nrctrcrd = $_POST['nrctrcrd'];
	
	if (!is_titular_card($nrctrcrd, $nrdconta,$glbvars)) exibirErro('error', utf8ToHtml("Upgrade/Downgrade nao permitido para cartao adicional."),'Alerta - Aimaro',$funcaoAposErro);

	
		
	// Verifica se o n�mero do cartao � um inteiro v�lido
	if (!validaInteiro($nrcrcard)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);
	
	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);
	

	function is_titular_card($nrctrcrd, $nrdconta,$glbvars)
	{
		/*$xmlGetDadosCartao  = "";
		$xmlGetDadosCartao .= "<Root>";
		$xmlGetDadosCartao .= "	<Cabecalho>";
		$xmlGetDadosCartao .= "		<Bo>b1wgen0028.p</Bo>";
		$xmlGetDadosCartao .= "		<Proc>consulta_dados_cartao</Proc>";
		$xmlGetDadosCartao .= "	</Cabecalho>";
		$xmlGetDadosCartao .= "	<Dados>";
		$xmlGetDadosCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlGetDadosCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlGetDadosCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlGetDadosCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlGetDadosCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlGetDadosCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
		$xmlGetDadosCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xmlGetDadosCartao .= "		<idseqttl>1</idseqttl>";
		$xmlGetDadosCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlGetDadosCartao .= "	</Dados>";
		$xmlGetDadosCartao .= "</Root>";
		$xmlResult = getDataXML($xmlGetDadosCartao);

		//Cria objeto para classe de tratamento de XML
		$xmlObjNovoCartao = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra cr�tica
		if (strtoupper($xmlObjNovoCartao->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
		$dados = $xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags;
		$dsgraupr = strlen( getByTagName($dados,"dsgraupr")); 
		if($dsgraupr > 0 && getByTagName($dados, "dsgraupr")!="Primeiro Titular")
			return false;
		else*/
		$logXML  = "<Root>";
		$logXML .= " <Dados>";
		$logXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$logXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
		$logXML .= " </Dados>";
		$logXML .= "</Root>";
		$admresult = mensageria($logXML, "ATENDA_CRD", "VALIDAR_EH_TITULAR", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		
		$procXML = simplexml_load_string($admresult);
		
		$titular = $procXML->Dados->contas->conta->titular;
		//echo "/* \n � titular: $titular \n */ ";
		if($titular == 'S')
			return true;
		else
			return false;

}
	
	
	// Monta o xml de requisi��o
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

	// Se ocorrer um erro, mostra cr�tica
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
						<select name="dsadmant" id="dsadmant" class="campo" onchange="triggerAdm();">
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
				<tr>
					<td><label for="dsjustificativa"><? echo utf8ToHtml('Justificativa:') ?></label></td>
					<td><!-- <input type="text" name="dsjustificativa" id="dsjustificativa" class="campo" style="width:252px" /> -->
						<select name="dsjustificativa" id="dsjustificativa" class="campo" style="width:252px">
						
						</select>
					</td>
				</tr>	
			</table>
			
			<div id="divBotoes" >
				<input type="button" class="botao" id="btVoltar" onclick="voltaDiv(0,1,4);return false;" value="Voltar"/>
				<input type="button" class="botao" id="btSalvar" onclick="validarUpDown(<? echo $nrctrcrd;?>);return false;" value="Prosseguir"/>
			</div>
		</fieldset>
	</div>
</form>

<script type="text/javascript">
var justificativa=[];
//upgrade
justificativa[0] = {
		'<?php echo ("Modalidade do cartao nao atende as necessidades."); ?>':"<?php echo ("Modalidade do cartao nao atende as necessidades."); ?>",
		'<?php echo ("Beneficios do produto nao atendem as necessidades."); ?>':"<?php echo ("Beneficios do produto nao atendem as necessidades."); ?>",
		'<?php echo ("Atualizacao da Renda."); ?>':"<?php echo ("Atualizacao da Renda."); ?>"	
};
//downgrade
justificativa[1] = {
		'<?php echo ("Nao possui interesse nos benef�cios do produto."); ?>':"<?php echo ("Nao possui interesse nos benef�cios do produto."); ?>",
		'<?php echo ("Valor da anuidade."); ?>':"<?php echo ("Valor da anuidade."); ?>",
		'<?php echo ("Atualizacao de renda."); ?>':"<?php echo ("Atualizacao de renda."); ?>"	
};
function triggerAdm(){
	var admAnt = <?echo $cdcadmat;?>;
	var adm   = $('#dsadmant').val();
	if(parseInt(admAnt) < parseInt(adm))
		populaSelect("dsjustificativa",justificativa[0]);
	else
		populaSelect("dsjustificativa",justificativa[1]);
}
function populaSelect(id, dataset){
    $("#"+id).empty();
	if(dataset == undefined){
		$('#'+id).append("<option value='' selected='selected'>Por favor selecione uma Administradora antes de selecionar uma justificativa.</option>");
		return;		
	}
	$('#'+id).append("<option value='' selected='selected'>Selecione uma justificativa</option>");	
    for(var data in dataset ){
        $('#'+id).append('<option value="'+data+'" >'+dataset[data]+'</option>');
    }
}
populaSelect("dsjustificativa",undefined);
// Mostra o div da Tela da op��o
$("#divOpcoesDaOpcao1").css("display","block");
// Esconde os cart�es
$("#divConteudoCartoes").css("display","none");

$("#dsadmatu").prop("disabled",true);

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte�do que esta �tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>