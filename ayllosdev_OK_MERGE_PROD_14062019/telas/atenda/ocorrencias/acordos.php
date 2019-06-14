<?php 

	/************************************************************************
	      Fonte: acordos.php
	      Autor: Jean Michel
	      Data : Setembro/2016              		Última Alteração: 10/02/2014

          Objetivo  : Mostrar opcao de Acordos de contratos de emprestimos

	      Alterações:
											
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

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "ATENDA","ATENDA_OCORRENCIAS_ACORDO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
		
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibeErro($msgErro);
		exit();
	}else{
		$qtdregist = $xmlObj->roottag->tags[1]->cdata;
		$arracordo = $xmlObj->roottag->tags[0]->tags;
	}
		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) {
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}

?>

<div id="divAcordos" >
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('N&uacute;mero Acordo'); ?></th>
					<th><? echo utf8ToHtml('Origem');  ?></th>
					<th><? echo utf8ToHtml('Contrato');  ?></th>					
				</tr>
			</thead>
			<tbody>
				<?php
					if($qtdregist == 0){
				?>
						<tr><td colspan="3" style="font-size: 10pt;">N&atilde;o existem contratos em acordo</td></tr>
				<?php
					}else{
						foreach ($arracordo as $acordo) { 
				?>
						<tr>
							<td><?php echo($acordo->tags[0]->cdata); ?></td>
							<td><?php echo($acordo->tags[1]->cdata); ?></td>
							<td><?php echo($acordo->tags[2]->cdata); ?></td>
						</tr>
				<?php	
						}
					}
				?>
			</tbody>
		</table>
	</div>	
</div>

<script type="text/javascript">
	formataAcordos();
	// Esconde mensagem de aguardo
	hideMsgAguardo();
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>