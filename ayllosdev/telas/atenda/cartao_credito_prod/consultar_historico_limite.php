<?php 

	/************************************************************************
	  Fonte: consultar_historico_limite.php
	  Autor: Renato Darosci
	  Data : Agosto/2017                 �ltima Altera��o: --/--/----

	  Objetivo: Mostrar a listagem dos hist�ricos de altera��o de limite 

	  Altera��es: 

	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permiss�o
	/*if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);
	}*/

	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcctitg"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcctitg = $_POST["nrcctitg"];

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se n�mero do cart�o � um inteiro valido
	if (!validaInteiro($nrcctitg)) {
		exibeErro("Cart&atilde;o inv&aacute;lido.");
	}

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrcctitg>".$nrcctitg."</nrcctitg>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "ATENDA", "HISLIMCRD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
		exibeErro($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$historico = $xmlObj->roottag->tags[0]->tags;

	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>


<div id="divHistorico">
	<div id="divConteudoHistorico">
		<div class="divRegistros">
			<table>
				<thead>
					<tr>
						<th>Data da Altera&ccedil;&atilde;o</th>
						<th>Tipo</th>
						<th>Valor Anterior</th>
						<th>Valor Atualizado</th>
					</tr>			
				</thead>
				<tbody>
					<?  for ($i = 0; $i < count($historico); $i++) { 					
					?>
						<tr id="<?php echo $i; ?>" >
							<td><?php echo getByTagName($historico[$i]->tags,"DTALTERA"); ?></td>
							<td><?php echo getByTagName($historico[$i]->tags,"DSTIPALT"); ?></td>
							<td><?php echo getByTagName($historico[$i]->tags,"VLLIMOLD"); ?></td>
							<td><?php echo getByTagName($historico[$i]->tags,"VLLIMNEW"); ?></td>
							
						</tr>				
					<? } ?>			
				</tbody>
			</table>
		</div>
		
		<div id="divBotoes">
			<a href="#" class="botao" id="btvoltar" onClick="voltaDiv(2,1,4,385);return false;">Voltar</a>
		</div>
		
	</div>
</div>
<script type="text/javascript">
	$('#divOpcoesDaOpcao1').css('display','none');
	$('#divOpcoesDaOpcao2').css('display','block');
	
	controlaLayout('divConteudoHistorico');
	
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
</script>
