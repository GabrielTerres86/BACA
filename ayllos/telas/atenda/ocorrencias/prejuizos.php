<?php 

	/************************************************************************
	      Fonte: prejuizos.php
	      Autor: Guilherme
	      Data : Fevereiro/2008               &Uacute;ltima Altera&ccedil;&atilde;o: 13/07/2011

	      Objetivo  : Mostrar opcao Prejuizos da rotina de OCORRENCIAS
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
	$xmlGetPrejuizos  = "";
	$xmlGetPrejuizos .= "<Root>";
	$xmlGetPrejuizos .= "	<Cabecalho>";
	$xmlGetPrejuizos .= "		<Bo>b1wgen0027.p</Bo>";
	$xmlGetPrejuizos .= "		<Proc>lista_prejuizos</Proc>";
	$xmlGetPrejuizos .= "	</Cabecalho>";
	$xmlGetPrejuizos .= "	<Dados>";
	$xmlGetPrejuizos .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetPrejuizos .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetPrejuizos .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetPrejuizos .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetPrejuizos .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetPrejuizos .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetPrejuizos .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlGetPrejuizos .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlGetPrejuizos .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetPrejuizos .= "		<idseqttl>1</idseqttl>";
	$xmlGetPrejuizos .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetPrejuizos .= "	</Dados>";
	$xmlGetPrejuizos .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetPrejuizos);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjPrejuizos = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPrejuizos->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPrejuizos->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$prejuizos      = $xmlObjPrejuizos->roottag->tags[0]->tags;
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>


<div id="divTabPrejuizos">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Data'); ?></th>
					<th><? echo utf8ToHtml('Contrato');  ?></th>
					<th><? echo utf8ToHtml('Transfer&ecirc;ncia');  ?></th>
					<th><? echo utf8ToHtml('Preju&iacute;zo');  ?></th>
					<th><? echo utf8ToHtml('Saldo Devedor');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
                for ($i = 0; $i < count($prejuizos); $i++) {
				?>
					<tr>
						<td><span><?php echo dataParaTimestamp($prejuizos[$i]->tags[0]->cdata); ?></span>
								<?php echo $prejuizos[$i]->tags[0]->cdata; ?>
						</td>
						<td><span><?php echo $prejuizos[$i]->tags[1]->cdata; ?></span>
								<?php echo formataNumericos("z.zzz.zzz",$prejuizos[$i]->tags[1]->cdata,"."); ?>
						</td>
						<td><span><?php echo $prejuizos[$i]->tags[2]->cdata; ?></span>
								<?php echo $prejuizos[$i]->tags[2]->cdata; ?>
						</td>
						<td><span><?php echo str_replace(",",".",$prejuizos[$i]->tags[3]->cdata) ?></span>
								<?php echo number_format(str_replace(",",".",$prejuizos[$i]->tags[3]->cdata),2,",","."); ?>
						</td>
						<td><span><?php echo str_replace(",",".",$prejuizos[$i]->tags[4]->cdata) ?></span>
								<?php echo number_format(str_replace(",",".",$prejuizos[$i]->tags[4]->cdata),2,",","."); ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>


<script type="text/javascript">
// Formata layout
formataPrejuizos();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

</script>
