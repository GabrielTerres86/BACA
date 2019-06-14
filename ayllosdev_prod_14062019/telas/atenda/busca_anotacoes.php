<?php 

	//************************************************************************//
	//*** Fonte: busca_anotacoes.php                                       ***//
	//*** Autor: Guilherme                                                 ***//
	//*** Data : Julho/2008               Última Alteração: 12/07/2012     ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar as anotações de uma conta do associado       ***//
	//***                                                                  ***//	 
	//*** Alterações: 18/03/2011 - Utilizar nova BO (David).               ***//
	//***																   ***//
	//***			  12/07/2012 - Adicionado class classDisabled nos campos**//
	//***						   e desabilitado em seguida (Jorge).      ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Verifica Permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
		
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
		exit();
	}

	// Monta o xml de requisição
	$xmlAnotacoes  = "";
	$xmlAnotacoes .= "<Root>";
	$xmlAnotacoes .= "  <Cabecalho>";
	$xmlAnotacoes .= "	  <Bo>b1wgen0085.p</Bo>";
	$xmlAnotacoes .= "    <Proc>Busca_Dados</Proc>";
	$xmlAnotacoes .= "  </Cabecalho>";
	$xmlAnotacoes .= "  <Dados>";
	$xmlAnotacoes .= "      <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlAnotacoes .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlAnotacoes .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlAnotacoes .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlAnotacoes .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlAnotacoes .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlAnotacoes .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlAnotacoes .= "		<nrseqdig>0</nrseqdig>";		
	$xmlAnotacoes .= "		<cddopcao>C</cddopcao>";				
	$xmlAnotacoes .= "  </Dados>";
	$xmlAnotacoes .= "</Root>";			
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlAnotacoes);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAnotacoes = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAnotacoes->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAnotacoes->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	$anotacoes = $xmlObjAnotacoes->roottag->tags[1]->tags;
	
	if (count($anotacoes) == 0) {
		exibeErro("Conta n&atilde;o possui anota&ccedil;&atilde;o cadastrada.");
		exit();
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","");';
		echo '</script>';
		exit();
	}		
	
?>
<table cellpadding="0" cellspacing="0" border="0">
	<?php for ($i = 0; $i < count($anotacoes); $i++){
			if ($i != 0){?>
	<tr>
		<td height="5"></td>
	</tr>
	<tr>
		<td height="1" style="background-color: #666666;"></td>
	</tr>
	<tr>
		<td height="5"></td>
	</tr>
	<?php }?>
	<tr>
		<td>
			<table cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td width="25" height="25" class="txtNormalBold">Em&nbsp;</td>
					<td width="67"><input name="dtmvtolt" type="text" class="campoTelaSemBorda classDisabled" id="dtmvtolt" value="<?php echo $anotacoes[$i]->tags[1]->cdata; ?>" style="width: 67px; text-align: center;"></td>
					<td width="30" align="center" class="txtNormalBold">&agrave;s&nbsp;</td>
					<td width="67"><input name="hrtransa" type="text" class="campoTelaSemBorda classDisabled" id="hrtransa" value="<?php echo $anotacoes[$i]->tags[10]->cdata; ?>" style="width: 67px; text-align: center"></td>
					<td width="35" align="center" class="txtNormalBold">por&nbsp;</td>
					<td><input name="dsoperad" type="text" class="campoTelaSemBorda classDisabled" id="dsoperad" value="<?php echo $anotacoes[$i]->tags[11]->cdata; ?>" style="width: 230px;"></td>
				</tr>
			</table>
		</td>
	</tr>	
	<?php if ($anotacoes[$i]->tags[5]->cdata == "yes"){?>
	<tr>
		<td>
			<table cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td height="25" class="txtNormalBold">** MENSAGEM PRIORIT&Aacute;RIA **</td>
				</tr>
			</table>
		</td>
	</tr>
	<?php } /*FIM DO IF*/?>
	<tr>
		<td>
			<table cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td><textarea name="dsanotas" style="overflow-y: scroll; overflow-x: hidden; width: 455px; height: 152px;" readonly><?php echo $anotacoes[$i]->tags[6]->cdata; ?></textarea></td>
				</tr>
			</table>
		</td>
	</tr>
	<?php } /* FIM DO FOR */ ?>
</table>
<script type="text/javascript">
$("#nroconta","#frmAnotacoes").val(" <?php echo formataNumericos("zzz.zzz.zz9-9",$xmlObjAnotacoes->roottag->tags[0]->tags[0]->tags[1]->cdata,".-"); ?> ");
$("#nmprimtl","#frmAnotacoes").val(" <?php echo $xmlObjAnotacoes->roottag->tags[0]->tags[0]->tags[2]->cdata; ?> ");

$('input, select', '#frmAnotacoes').desabilitaCampo();
$('input, select', '.classDisabled').desabilitaCampo();

// Mostra div
$("#divAnotacoes").css("visibility","visible");

$("#btnAnotaSair").focus(); 


// Esconde mensagem de aguardo
hideMsgAguardo();		

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divAnotacoes").css("z-index")));	
</script>