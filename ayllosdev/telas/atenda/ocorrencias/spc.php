<?php 
	/************************************************************************
	      Fonte: spc.php
	      Autor: Guilherme
	Data : Fevereiro/2008               Ultima Alteracoes: 25/07/2016 

	Objetivo  : Mostrar opcao SPC da rotina de OCORRENCIAS da tela ATENDA

	Alteracoes: 13/07/2011 - Alterado para layout padrão (Rogerius - DB1). 
				25/07/2016 - Correcao na forma de recuperacao dos dados do XML. SD 479874 (Carlos R.)	
	
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetSPC  = "";
	$xmlGetSPC .= "<Root>";
	$xmlGetSPC .= "	<Cabecalho>";
	$xmlGetSPC .= "		<Bo>b1wgen0027.p</Bo>";
	$xmlGetSPC .= "		<Proc>lista_spc</Proc>";
	$xmlGetSPC .= "	</Cabecalho>";
	$xmlGetSPC .= "	<Dados>";
	$xmlGetSPC .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetSPC .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetSPC .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetSPC .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetSPC .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetSPC .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetSPC .= "		<idseqttl>1</idseqttl>";
	$xmlGetSPC .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetSPC .= "	</Dados>";
	$xmlGetSPC .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetSPC);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSPC = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjSPC->roottag->tags[0]->name) && strtoupper($xmlObjSPC->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjSPC->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$spc = ( isset($xmlObjSPC->roottag->tags[0]->tags) ) ? $xmlObjSPC->roottag->tags[0]->tags : array();
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<div id="divTabSPC">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Contrato'); ?></th>
					<th><? echo utf8ToHtml('Origem');  ?></th>
					<th><? echo utf8ToHtml('Identifica&ccedil;&atilde;o');  ?></th>
					<th><? echo utf8ToHtml('Dt.Venc.');  ?></th>
					<th><? echo utf8ToHtml('Data da Inclus&atilde;o');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
                for ($i = 0; $i < count($spc); $i++) {
				?>
					<tr>
						<td><span><?php echo $spc[$i]->tags[0]->cdata?></span>
								<?php echo formataNumericos("z.zzz.zzz",$spc[$i]->tags[0]->cdata,".") ?>
								<input id="contrat1" name="contrat1" type="hidden" value="<?php echo $spc[$i]->tags[6]->cdata ?>" />
								<input id="dtbaixa1" name="dtbaixa1" type="hidden" value="<?php echo $spc[$i]->tags[7]->cdata; ?>" />
						</td>
						<td><span><?php echo $spc[$i]->tags[5]->cdata ?></span>
								<?php echo $spc[$i]->tags[5]->cdata ?>
						</td>
						<td><span><?php echo $spc[$i]->tags[1]->cdata; ?></span>
								<?php echo $spc[$i]->tags[1]->cdata; ?>
						</td>
						<td><span><?php echo dataParaTimestamp($spc[$i]->tags[2]->cdata); ?></span>
								<?php echo $spc[$i]->tags[2]->cdata ?>
						</td>
						<td><span><?php echo dataParaTimestamp($spc[$i]->tags[3]->cdata); ?></span>
								<?php echo $spc[$i]->tags[3]->cdata; ?>
						</td>
						<td><span><?php echo str_replace(",",".",$spc[$i]->tags[4]->cdata) ?></span>
								<?php echo number_format(str_replace(",",".",$spc[$i]->tags[4]->cdata),2,",","."); ?>
						</td>
	
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>

	<div id="divSPCLinha1">
	<ul class="complemento">
	<li>Contrato</li>
	<li id="contrat2"><?php echo ( isset($spc[0]->tags[6]->cdata) ) ? $spc[0]->tags[6]->cdata : ''; ?></li>
	<li>Data da Baixa</li>
	<li id="dtbaixa2"><?php echo ( isset($spc[0]->tags[7]->cdata) ) ? $spc[0]->tags[7]->cdata : ''; ?></li>
	</ul>
	</div>
	
</div>

<script type="text/javascript">
// Formata Layout
formataSPC();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
