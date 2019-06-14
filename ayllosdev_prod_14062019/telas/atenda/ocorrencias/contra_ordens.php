<?php 

	/************************************************************************
	      Fonte: contra_ordens.php
	      Autor: Guilherme
	      Data : Fevereiro/2008               &Uacute;ltima Altera&ccedil;&atilde;o:   13/07/2011

	      Objetivo  : Mostrar opcao Contra Ordens da rotina de OCORRENCIAS
                      da tela ATENDA

	      Altera&ccedil;&otilde;es:
				13/07/2011 - Alterado para layout padrão (Rogerius - DB1). 	

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
	$xmlGetContraOrdem  = "";
	$xmlGetContraOrdem .= "<Root>";
	$xmlGetContraOrdem .= "	<Cabecalho>";
	$xmlGetContraOrdem .= "		<Bo>b1wgen0027.p</Bo>";
	$xmlGetContraOrdem .= "		<Proc>lista_contra-ordem</Proc>";
	$xmlGetContraOrdem .= "	</Cabecalho>";
	$xmlGetContraOrdem .= "	<Dados>";
	$xmlGetContraOrdem .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetContraOrdem .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetContraOrdem .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetContraOrdem .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetContraOrdem .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetContraOrdem .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetContraOrdem .= "		<idseqttl>1</idseqttl>";
	$xmlGetContraOrdem .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetContraOrdem .= "	</Dados>";
	$xmlGetContraOrdem .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetContraOrdem);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjContraOrdem = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjContraOrdem->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjContraOrdem->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$ContraOrdem = $xmlObjContraOrdem->roottag->tags[0]->tags;
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<div id="divTabContraOrdens">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Bco'); ?></th>
					<th><? echo utf8ToHtml('Age');  ?></th>
					<th><? echo utf8ToHtml('Cta.chq');  ?></th>
					<th><? echo utf8ToHtml('OPE');  ?></th>
					<th><? echo utf8ToHtml('Cheque');  ?></th>
					<th><? echo utf8ToHtml('Emiss&atilde;o');  ?></th>
					<th><? echo utf8ToHtml('Inclus&atilde;o');  ?></th>
					<th><? echo utf8ToHtml('Hist&oacute;rico');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				for ($i = 0; $i < count($ContraOrdem); $i++) {
				?>
					<tr>
						<td><span><?php echo $ContraOrdem[$i]->tags[0]->cdata; ?></span>
								<?php echo $ContraOrdem[$i]->tags[0]->cdata; ?>
						</td>
						<td><span><?php echo $ContraOrdem[$i]->tags[1]->cdata; ?></span>
								<?php echo $ContraOrdem[$i]->tags[1]->cdata; ?>
						</td>
						<td><span><?php echo $ContraOrdem[$i]->tags[2]->cdata; ?></span>
								<?php echo formataNumericos("zzz.zzz.z",$ContraOrdem[$i]->tags[2]->cdata,".") ?>
						</td>
						<td><span><?php echo $ContraOrdem[$i]->tags[3]->cdata; ?></span>
								<?php echo $ContraOrdem[$i]->tags[3]->cdata; ?>
						</td>
						<td><span><?php echo $ContraOrdem[$i]->tags[4]->cdata; ?></span>
								<?php echo formataNumericos("zzz.zzz.z",$ContraOrdem[$i]->tags[4]->cdata,"."); ?>
						</td>
						<td><span><?php echo dataParaTimestamp($ContraOrdem[$i]->tags[5]->cdata); ?></span>
								<?php echo $ContraOrdem[$i]->tags[5]->cdata; ?>
						</td>
						<td><span><?php echo dataParaTimestamp($ContraOrdem[$i]->tags[6]->cdata); ?></span>
								<?php echo $ContraOrdem[$i]->tags[6]->cdata; ?>
						</td>
						<td><span><?php echo $ContraOrdem[$i]->tags[7]->cdata; ?></span>
								<?php echo $ContraOrdem[$i]->tags[7]->cdata; ?>
						</td>
	
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>

<script type="text/javascript">
// Formata layout
formataContraOrdens();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
