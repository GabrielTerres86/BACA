<?php 

	/************************************************************************
	 Fonte: cheques_bordero_consultar_visualizacheques.php                                       
	 Autor: Guilherme                                                 
	 Data : Novembro/2008                Última Alteração: 16/12/2016 
	                                                                  
	 Objetivo  : Visualizar os cheques de um Borderos de descontos de cheques        
	                                                                  	 
	 Alterações: 12/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)

				 16/12/2016 - Alterações referente ao projeto 300. (Reinert)
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrborder"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrborder = $_POST["nrborder"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o número do bordero é um inteiro válido
	if (!validaInteiro($nrborder)) {
		exibeErro("N&uacute;mero do border&ocirc; inv&aacute;lida.");
	}	
	
	// Monta o xml de requisição
	$xmlGetChqs  = "";
	$xmlGetChqs .= "<Root>";
	$xmlGetChqs .= "	<Cabecalho>";
	$xmlGetChqs .= "		<Bo>b1wgen0009.p</Bo>";
	$xmlGetChqs .= "		<Proc>busca_cheques_bordero</Proc>";
	$xmlGetChqs .= "	</Cabecalho>";
	$xmlGetChqs .= "	<Dados>";
	$xmlGetChqs .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetChqs .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetChqs .= "		<nrborder>".$nrborder."</nrborder>";
	$xmlGetChqs .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetChqs .= "	</Dados>";
	$xmlGetChqs .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetChqs);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjChqs = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjChqs->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjChqs->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$cheques      = $xmlObjChqs->roottag->tags[0]->tags;
	$qtCheques    = count($cheques);
	$restricoes   = $xmlObjChqs->roottag->tags[1]->tags;
	$qtRestricoes = count($restricoes);
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<div id="divCheques" style="overflow-y: scroll; height: 250px; width: 885px;">
	<table width="860px" border="0" cellpadding="1" cellspacing="2">
		
		<thead>
			<tr style="background-color: #F4D0C9;" height="20">				
				<th width="60"  align="right" class="txtNormalBold">Data</th>
				<th width="30"  align="right" class="txtNormalBold">Cmp</th>
				<th width="30"  align="right" class="txtNormalBold">Bco</th>
				<th width="35"  align="right" class="txtNormalBold">Ag.</th>
				<th width="30"  align="right" class="txtNormalBold">C1</th>
				<th width="80" align="right" class="txtNormalBold">Conta</th>
				<th width="250" align="right" class="txtNormalBold">Nome</th>
				<th width="30"  align="right" class="txtNormalBold">C2</th>
				<th width="50"  align="right" class="txtNormalBold">Cheque</th>
				<th width="30"  align="right" class="txtNormalBold">C3</th>
				<th width="80"  align="right" class="txtNormalBold">Valor</th>
				<th align="right" class="txtNormalBold">CPF/CNPJ</th>
			</tr>
		</thead>
		
		<?php 
		$cor = "";
		$vlrtotal = 0;
		$vltotliq = 0;
		
		for ($i = 0; $i < $qtCheques; $i++) { 								
			if ($cor == "#F4F3F0") {
				$cor = "#FFFFFF";
			} else {
				$cor = "#F4F3F0";
			}
			$vlrtotal += doubleval(str_replace(",",".",$cheques[$i]->tags[8]->cdata));
			$vltotliq += doubleval(str_replace(",",".",$cheques[$i]->tags[9]->cdata));
			
		?>
		<tr style="background-color: <?php echo $cor; ?>;" >
			<td width="60"  align="right" class="txtNormal"><?php echo $cheques[$i]->tags[11]->cdata; ?></td>
			<td width="30"  align="right" class="txtNormal"><?php echo formataNumericos('999',$cheques[$i]->tags[0]->cdata,''); ?></td>
			<td width="30"  align="right" class="txtNormal"><?php echo formataNumericos('999',$cheques[$i]->tags[1]->cdata,''); ?></td>
			<td width="35"  align="right" class="txtNormal"><?php echo formataNumericos('9999',$cheques[$i]->tags[2]->cdata,''); ?></td>
			<td width="30"  align="right" class="txtNormal"><?php echo $cheques[$i]->tags[3]->cdata; ?></td>
			<td width="80"  align="right" class="txtNormal"><?php echo formataNumericos('zzzzzzz.zzz.9',$cheques[$i]->tags[4]->cdata,'.'); ?></td>
			<td width="250" align="right" class="txtNormal"><?php echo $cheques[$i]->tags[12]->cdata; ?></td>
			<td width="30"  align="right" class="txtNormal"><?php echo $cheques[$i]->tags[5]->cdata; ?></td>
			<td width="50"  align="right" class="txtNormal"><?php echo formataNumericos('zzz.zz9',$cheques[$i]->tags[6]->cdata,'.'); ?></td>
			<td width="30"  align="right" class="txtNormal"><?php echo $cheques[$i]->tags[7]->cdata; ?></td>
			<td width="80"  align="right" class="txtNormal"><?php echo number_format(str_replace(",",".",$cheques[$i]->tags[8]->cdata),2,",",".");?></td>
			<td align="right" class="txtNormal"><?php echo $cheques[$i]->tags[10]->cdata; ?></td>
		</tr>							
		<?php
		for ($j = 0; $j < $qtRestricoes; $j++){
		if ($restricoes[$j]->tags[1]->cdata == $cheques[$i]->tags[6]->cdata) {
		?>
		<tr style="background-color: <?php echo $cor; ?>;">
			<td width="20" align="right" class="txtNormal">==></td>
			<td class="txtNormal" colspan="11"><?php echo $restricoes[$j]->tags[2]->cdata; ?></td>	
		</tr>
		<?php 
		}
		} // Fim do for das restrições
		} // Fim do for
		for ($i = 0; $i < $qtRestricoes; $i++){
			if ($restricoes[$i]->tags[1]->cdata == "888888"){
				?>
				<tr>
					<td>&nbsp;</td>
				<tr>
				<tr>
					<td width="20" align="right" class="txtNormal">==></td>
					<td class="txtNormal" colspan="11"><?php echo $restricoes[$i]->tags[2]->cdata; ?></td>	
				</tr>
				<?php
			} //fim do if
		} //fim do for das restricoes gerais
		?>
	</table>
	<table width="860px" border="0" cellpadding="1" cellspacing="2">
		<tr>
			<td>&nbsp;</td>
		<tr>
		<tr>
			<td width="60"  align="center" class="txtNormal">TOTAL ==></td>
			<td width="130" align="left"   class="txtNormal"><?php if($qtCheques <= 1){ echo $qtCheques." CHEQUE";}else{ echo $qtCheques." CHEQUES";};?></td>
			<td width="150" align="left"   class="txtNormal"><?php echo "VALOR TOTAL ".number_format(str_replace(",",".",$vlrtotal),2,",","."); ?></td>
			<td width="30"  align="right"  class="txtNormal"><?php echo $qtRestricoes; ?></td>
			<td class="txtNormal">&nbsp;<?php if($qtRestricoes <= 1){echo "RESTRI&Ccedil;&Atilde;O";}else{echo "RESTRI&Ccedil;&Otilde;ES";} ?></td>
		</tr>
	</table>
</div>
<div id="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(4,3,4,'CONSULTA DE BORDER&Ocirc;');return false;" />
</div>

<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao4","divOpcoesDaOpcao3");

// Muda o título da tela
$("#tdTitRotina").html("CONSULTA DE CHEQUES DO BORDER&Ocirc;");

// Esconde mensagem de aguardo
hideMsgAguardo();

ajustarCentralizacao();
// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>