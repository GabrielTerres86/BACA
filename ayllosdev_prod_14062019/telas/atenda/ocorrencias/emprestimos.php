<?php 

	/************************************************************************
	      Fonte: emprestimos.php
	      Autor: Guilherme
	      Data : Fevereiro/2008               &Uacute;ltima Altera&ccedil;&atilde;o:  13/07/2011

	      Objetivo  : Mostrar opcao Emprestimos da rotina de OCORRENCIAS
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
	$xmlGetEmprestimos  = "";
	$xmlGetEmprestimos .= "<Root>";
	$xmlGetEmprestimos .= "	<Cabecalho>";
	$xmlGetEmprestimos .= "		<Bo>b1wgen0027.p</Bo>";
	$xmlGetEmprestimos .= "		<Proc>lista_emprestimos</Proc>";
	$xmlGetEmprestimos .= "	</Cabecalho>";
	$xmlGetEmprestimos .= "	<Dados>";
	$xmlGetEmprestimos .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetEmprestimos .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetEmprestimos .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetEmprestimos .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetEmprestimos .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetEmprestimos .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetEmprestimos .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlGetEmprestimos .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlGetEmprestimos .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetEmprestimos .= "		<idseqttl>1</idseqttl>";
	$xmlGetEmprestimos .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetEmprestimos .= "	</Dados>";
	$xmlGetEmprestimos .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetEmprestimos);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjEmprestimos = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjEmprestimos->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjEmprestimos->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$emprestimos      = $xmlObjEmprestimos->roottag->tags[0]->tags;
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<div id="divTabEmprestimos">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Data'); ?></th>
					<th><? echo utf8ToHtml('Contrato');  ?></th>
					<th><? echo utf8ToHtml('Emprestado');  ?></th>
					<th><? echo utf8ToHtml('Saldo');  ?></th>
					<th><? echo utf8ToHtml('A Regularizar');  ?></th>
					<th><? echo utf8ToHtml('Ult.Pagmto');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				for ($i = 0; $i < count($emprestimos); $i++) {
				?>
					<tr>
						<td><span><?php echo dataParaTimestamp($emprestimos[$i]->tags[0]->cdata); ?></span>
								<?php echo $emprestimos[$i]->tags[0]->cdata; ?>
						</td>
						<td><span><?php echo $emprestimos[$i]->tags[1]->cdata ?></span>
								<?php echo formataNumericos("z.zzz.zzz",$emprestimos[$i]->tags[1]->cdata,".") ?>
						</td>
						<td><span><?php echo str_replace(",",".",$emprestimos[$i]->tags[2]->cdata) ?></span>
								<?php echo number_format(str_replace(",",".",$emprestimos[$i]->tags[2]->cdata),2,",","."); ?>
						</td>
						<td><span><?php echo str_replace(",",".",$emprestimos[$i]->tags[3]->cdata) ?></span>
								<?php echo number_format(str_replace(",",".",$emprestimos[$i]->tags[3]->cdata),2,",","."); ?>
						</td>
						<td><span><?php echo str_replace(",",".",$emprestimos[$i]->tags[4]->cdata) ?></span>
								<?php echo number_format(str_replace(",",".",$emprestimos[$i]->tags[4]->cdata),2,",","."); ?>
						</td>
						<td><span><?php echo $emprestimos[$i]->tags[5]->cdata; ?></span>
								<?php echo $emprestimos[$i]->tags[5]->cdata; ?>
						</td>
	
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>


<script type="text/javascript">

// Formata layout
formataEmprestimos();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

</script>
