<?php 

	/************************************************************************
	 Fonte: consultar_dados_cartao_ultimos_debitos.php                                                 
	 Autor: Guilherme                                                     
	 Data : Abril/2008					      Última Alteração: 08/07/2011
	
	 Objetivo  : Mostrar opcao Ult.Débitos da opção Consultar da ROTINA 
	             Cartões de Crédito da tela ATENDA

	 Alterações: 04/11/2010 - Adaptação Cartão PJ (David).
	 
				 08/07/2011 - Alterado para layout padrão ( Gabriel - DB1 )
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}			
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrcrcard"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcrcard = $_POST["nrcrcard"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisição
	$xmlGetUltDeb  = "";
	$xmlGetUltDeb .= "<Root>";
	$xmlGetUltDeb .= "	<Cabecalho>";
	$xmlGetUltDeb .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlGetUltDeb .= "		<Proc>ult_debitos</Proc>";
	$xmlGetUltDeb .= "	</Cabecalho>";
	$xmlGetUltDeb .= "	<Dados>";
	$xmlGetUltDeb .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetUltDeb .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetUltDeb .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetUltDeb .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetUltDeb .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetUltDeb .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlGetUltDeb .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetUltDeb .= "		<idseqttl>1</idseqttl>";
	$xmlGetUltDeb .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetUltDeb .= "	</Dados>";
	$xmlGetUltDeb .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetUltDeb);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjUltDeb = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjUltDeb->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjUltDeb->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$ultimosdebitos = $xmlObjUltDeb->roottag->tags[0]->tags;
	
	// Se não houver lançamentos faz a crítica
	if ($ultimosdebitos[0]->tags[0]->cdata == ""){
		exibeErro('Lan&ccedil;amentos n&atilde;o encontrados.');
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

<form id="formUltDebitos">
	<fieldset>
		<legend><? echo utf8ToHtml('Últimos Débitos:') ?></legend>
		<div style="width:50%">
			<div class="divRegistros">
				<table>
					<thead>
						<tr><th>Data</th>
							<th>Valor</th></tr>			
					</thead>
					<tbody>
						<? for ($i = 0; $i < count($ultimosdebitos); $i++) { ?>
							<?;?>
							<tr>
								<td><span><? echo dataParaTimestamp($ultimosdebitos[$i]->tags[0]->cdata) ?></span>
										  <? echo $ultimosdebitos[$i]->tags[0]->cdata; ?></td>

								<td><span><? echo str_replace(",",".",$ultimosdebitos[$i]->tags[1]->cdata) ?></span>
									<? echo number_format(str_replace(",",".",$ultimosdebitos[$i]->tags[1]->cdata),2,",",".") ?></td>
							</tr>				
						<? } ?>			
					</tbody>
				</table>
			</div>
		</div>
	</fieldset>
</form>
<div id="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(2,1,4,385);return false;">
</div>
								
<script type="text/javascript">
	$("#divOpcoesDaOpcao1").css("display","none");
	$("#divOpcoesDaOpcao2").css("display","block");
	
	controlaLayout('formUltDebitos');

	hideMsgAguardo();
	bloqueiaFundo(divRotina);
</script>