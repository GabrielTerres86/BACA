<?php 

	//************************************************************************//
	//*** Fonte: ultimas_alteracose.php                                    ***//
	//*** Autor: David                                                     ***//
	//*** Data : Fevereiro/2008               Última Alteração: 28/06/2011 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opção Últimas Alterações da rotina de Limite ***//
	//***             de Crédito da tela ATENDA                            ***//
	//***                                                                  ***//	 
	//*** Alterações:                                                      ***//
	//***                                                   			   ***//
	//***             28/06/2011 - Tableless - (Rogerius DB1)   		   ***//
	//***                                          						   ***//
	//***             08/08/2017 - Implementacao da melhoria 438.          ***//
	//***                          Heitor (Mouts).                         ***//
	//***                                          						   ***//
	//***             14/11/2017 - Nova coluna "Operador"                  ***//
	//***                          Chamado 791852 (Mateus Z - Mouts)	   ***//
	//***                                          						   ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"U")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisição
	//$xmlGetAlteracoes  = "";
	//$xmlGetAlteracoes .= "<Root>";
	//$xmlGetAlteracoes .= "	<Cabecalho>";
	//$xmlGetAlteracoes .= "		<Bo>b1wgen0019.p</Bo>";
	//$xmlGetAlteracoes .= "		<Proc>obtem-ultimas-alteracoes</Proc>";
	//$xmlGetAlteracoes .= "	</Cabecalho>";
	//$xmlGetAlteracoes .= "	<Dados>";
	//$xmlGetAlteracoes .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	//$xmlGetAlteracoes .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	//$xmlGetAlteracoes .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	//$xmlGetAlteracoes .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	//$xmlGetAlteracoes .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	//$xmlGetAlteracoes .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	//$xmlGetAlteracoes .= "		<nrdconta>".$nrdconta."</nrdconta>";
	//$xmlGetAlteracoes .= "		<idseqttl>1</idseqttl>";
	//$xmlGetAlteracoes .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	//$xmlGetAlteracoes .= "		<nrctrlim>0</nrctrlim>";
	//$xmlGetAlteracoes .= "	</Dados>";
	//$xmlGetAlteracoes .= "</Root>";
		
	// Executa script para envio do XML
	//$xmlResult = getDataXML($xmlGetAlteracoes);
	
	// Cria objeto para classe de tratamento de XML
	//$xmlObjAlteracoes = getObjectXML($xmlResult);
	
	$xml  = "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "ATENDA", "LIM_ULTIMAS_ALT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjAlteracoes = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAlteracoes->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAlteracoes->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$alteracoes = $xmlObjAlteracoes->roottag->tags[0]->tags;
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
?>

<div class="divRegistros">	
	<table>
		<thead>
			<tr>
				<th><? echo utf8ToHtml('Contrato'); ?></th>
				<th><? echo utf8ToHtml('In&iacute;cio');  ?></th>
				<th><? echo utf8ToHtml('Fim');  ?></th>
				<th><? echo utf8ToHtml('Limite');  ?></th>
				<th><? echo utf8ToHtml('Situa&ccedil;&atilde;o');  ?></th>
				<th><? echo utf8ToHtml('Motivo');  ?></th>
				<th><? echo utf8ToHtml('Operador');  ?></th>
			</tr>
		</thead>
		<tbody>
			<? 
			foreach ( $alteracoes as $registro ) { 
			?>
				<tr>
					<td><span><?php echo getByTagName($registro->tags,'nrctrlim') ?></span>
							  <?php echo formataNumericos("zzz.zzz.zzz",getByTagName($registro->tags,'nrctrlim'),"."); ?>
					</td>
					<td><span><?php echo dataParaTimestamp(getByTagName($registro->tags,'dtinivig')); ?></span>
							  <?php echo getByTagName($registro->tags,'dtinivig') ?>
					</td>
					<td><span><?php echo dataParaTimestamp(getByTagName($registro->tags,'dtfimvig')); ?></span>
							  <?php echo getByTagName($registro->tags,'dtfimvig'); ?>
					</td>
					<td><span><?php echo str_replace(",",".",getByTagName($registro->tags,'vllimite')); ?></span>
							  <?php echo number_format(str_replace(",",".",getByTagName($registro->tags,'vllimite')),2,",","."); ?>
					</td>
					<td><span><?php echo getByTagName($registro->tags,'dssitlli'); ?></span>
							  <?php echo getByTagName($registro->tags,'dssitlli'); ?>
					</td>
					<td><span><?php echo getByTagName($registro->tags,'dsmotivo'); ?></span>
							  <?php echo getByTagName($registro->tags,'dsmotivo'); ?>
					</td>
					<td><span><?php echo getByTagName($registro->tags,'nmoperad'); ?></span>
							  <?php echo getByTagName($registro->tags,'nmoperad'); ?>
					</td>
				</tr>
		<? } ?>	
		</tbody>
	</table>
</div>	

<!-- bruno - prj - 438 - sprint 7 - tela principal -->
<div id="divBotoes">
	<a href="#" class="botao" id="btVoltarImpressao" onClick="acessaTela('@');  return false;">Voltar</a>	
</div>

<script type="text/javascript">
	formataUltimasAlteracoes();	
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
</script>