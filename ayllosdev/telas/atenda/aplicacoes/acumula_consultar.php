<?php 

	/************************************************************************
	 Fonte: acumula_consultar.php                                     
	 Autor: David                                                     
	 Data : Outubro/2009                 Útila alteração: 16/01/2015
	                                                                  
	 Objetivo  : Script para consultar saldos acumulados da Aplicação
	                                                                  
	 Alterações: 01/12/2010 - Alterado a chamada da BO b1wgen0004.p 	
	                          para a BO b1wgen0081.p (Adriano).    
							  
				 30/04/2014 - Ajuste referente ao projeto Captação:
							  - Layout dos botões (Adriano).

				 16/01/2015 - Inclusao do parametro idtipapl. (Jean Michel)				
											
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nraplica"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nraplica = $_POST["nraplica"];
	$idtipapl = $_POST["idtipapl"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o n&uacute;mero da aplica&ccedil;&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nraplica)) {
		exibeErro("N&uacute;mero da aplica&ccedil;&atilde;o inv&aacute;lida.");
	}		
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlAcumula  = "";
	$xmlAcumula .= "<Root>";
	$xmlAcumula .= "	<Cabecalho>";
	$xmlAcumula .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlAcumula .= "		<Proc>consultar-saldo-acumulado</Proc>";
	$xmlAcumula .= "	</Cabecalho>";
	$xmlAcumula .= "	<Dados>";
	$xmlAcumula .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlAcumula .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlAcumula .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlAcumula .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlAcumula .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlAcumula .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xmlAcumula .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlAcumula .= "		<idseqttl>1</idseqttl>";
	$xmlAcumula .= "		<nraplica>".$nraplica."</nraplica>";
	$xmlAcumula .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlAcumula .= "		<idtipapl>".$idtipapl."</idtipapl>";
	$xmlAcumula .= "	</Dados>";
	$xmlAcumula .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlAcumula);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAcumula = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjAcumula->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAcumula->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$dados    = $xmlObjAcumula->roottag->tags[0]->tags[0]->tags;
	$saldos   = $xmlObjAcumula->roottag->tags[1]->tags;
	$qtSaldos = count($saldos);
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<form action="" method="post" name="frmDadosAcumula" id="frmDadosAcumula" class="formulario">
	<fieldset>
	<legend>Consultar Saldo Acumulado</legend>

	<label for="campo1">Aplica&ccedil;&atilde;o:</label>
	<input id="campo1" name="campo1" type="text" value="<?php echo formataNumericos("zzz.zzz.zzz",$nraplica,".")." - ".$dados[2]->cdata; ?>" />
	
	<br />
	
	<label for="campo2">Valor da Aplica&ccedil;&atilde;o:</label>
	<input id="campo2" name="campo2" type="text" value="<?php echo number_format(str_replace(",",".",$dados[5]->cdata),2,",","."); ?>" />
	
	<label for="campo3">Saldo da Aplica&ccedil;&atilde;o:</label>
	<input id="campo3" name="campo3" type="text" value="<?php echo number_format(str_replace(",",".",$dados[8]->cdata),2,",","."); ?>" />
	
	<br />
	
	<label for="campo4">Data da Aplica&ccedil;&atilde;o:</label>
	<input id="campo4" name="campo4" type="text" value="<?php echo $dados[3]->cdata; ?>" />
	
	<label for="campo5">Data de Vencimento:</label>
	<input id="campo5" name="campo5" type="text" value="<?php echo $dados[4]->cdata; ?>" />
	
	<br />
	
	<label for="campo6">Taxa Contrato:</label>
	<input id="campo6" name="campo6" type="text" value="<?php echo number_format(str_replace(",",".",$dados[6]->cdata),6,",","."); ?>" />
	
	<label for="campo7">Taxa Min&iacute;ma:</label>
	<input id="campo7" name="campo7" type="text" value="<?php echo number_format(str_replace(",",".",$dados[7]->cdata),6,",","."); ?>" />
	
	<br />
	
	<table width="315" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td>
				<table width="300" border="0" cellpadding="1" cellspacing="2" class="tituloRegistros">	
					<tr style="background-color: #F4D0C9;" height="20">				
						<th width="70" class="txtNormalBold" align="right">Aplica&ccedil;&atilde;o</th>
						<th width="110" class="txtNormalBold">Tipo da Aplica&ccedil;&atilde;o</th>
						<th class="txtNormalBold" align="right">Saldo na Data</th>
					</tr>						
				</table>
			</td>
		</tr>				
		<tr>
			<td>
				<div id="divSaldosAcumulados" style="overflow-y: scroll; overflow-x: hidden; height: 72px; width: 100%;">
					<table width="100%" border="0" cellpadding="1" cellspacing="2">				
						<?php 
						$cor = "";
						
						for ($i = 0; $i < $qtSaldos; $i++) { 
							if ($cor == "#F4F3F0") {
								$cor = "#FFFFFF";
							} else {
								$cor = "#F4F3F0";
							}
						?>
						<tr style="background-color: <?php echo $cor; ?>;">
							<td width="70" class="txtNormal" align="right"><?php echo formataNumericos("zzz.zzz.zzz",$saldos[$i]->tags[0]->cdata,"."); ?></td>
							<td width="110" class="txtNormal"><?php echo $saldos[$i]->tags[1]->cdata; ?></td>
							<td class="txtNormal" align="right"><?php echo number_format(str_replace(",",".",$saldos[$i]->tags[2]->cdata),2,",","."); ?></td>
						</tr>							
						<?php 
						} // Fim do for						
						?>									
					</table>
				</div>
			</td>
		</tr>
		<tr>
			<td>	
				<table width="300" border="0" cellpadding="1" cellspacing="2">		
					<tr style="background-color: #FFFFFF;">
						<td width="70" class="txtNormal" align="right">&nbsp;</td>
						<td width="110" class="txtNormal">TOTAL ACUMULADO</td>
						<td class="txtNormal" align="right"><?php echo number_format(str_replace(",",".",$dados[9]->cdata),2,",","."); ?></td>
					</tr>	
				</table>
			</td>
		</tr>
	</table>

	</fieldset>
	
</form>

<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onClick="voltarDivAcumula();return false;">Voltar</a>
</div>

<script type="text/javascript">

// Formata layout
formataAcumulaConsulta();
	
// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));	
</script>