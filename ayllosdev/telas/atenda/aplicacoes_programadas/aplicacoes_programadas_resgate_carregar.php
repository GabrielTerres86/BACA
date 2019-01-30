<?php 

	/***************************************************************************
	 Fonte:  	_resgate_carregar.php                             
	 Autor: David                                                     
	 Data : Março/2010                   Última Alteração: 27/07/2018
	                                                                  
	 Objetivo  : Carregar resgates da aplicação programada             	
	                                                                  	 
	 Alterações: 13/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1) 
				 27/07/2018 - Derivação para Aplicação Programada (Proj. 411.2 - CIS Corporate)	 
	***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"G")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"]) || !isset($_POST["flgcance"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];
	$flgcance = $_POST["flgcance"];

	// Verifica se núero da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o contrato da aplicação é um inteiro válido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}		
	
	// Verifica se indicador para opção cancelamento é válido
	if ($flgcance <> "yes" && $flgcance <> "no") {
		exibeErro("Indicador de cancelamento inv&aacute;lido.");
	}	
	
	// Monta o xml de requisição
	$xmlGetResgates  = "";
	$xmlGetResgates .= "<Root>";
	$xmlGetResgates .= "	<Cabecalho>";
	$xmlGetResgates .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlGetResgates .= "		<Proc>consultar-resgates</Proc>";
	$xmlGetResgates .= "	</Cabecalho>";
	$xmlGetResgates .= "	<Dados>";
	$xmlGetResgates .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetResgates .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetResgates .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetResgates .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetResgates .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetResgates .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xmlGetResgates .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetResgates .= "		<idseqttl>1</idseqttl>";
	$xmlGetResgates .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>";	
	$xmlGetResgates .= "		<flgcance>".$flgcance."</flgcance>";
	$xmlGetResgates .= "	</Dados>";
	$xmlGetResgates .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetResgates);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjResgates = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjResgates->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjResgates->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$resgates   = $xmlObjResgates->roottag->tags[0]->tags;	
	$qtResgates = count($resgates);
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<script type="text/javascript">var metodoBlock = "blockBackground(parseInt($('#divRotina').css('z-index')))";</script>
<?/**/?>
<div id="divResultadoResgates">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Data</th>
					<th>Documento</th>
					<th>Tp.Resgate</th>
					<th>Situa&ccedil;&atilde;o</th>
					<th>Operador</th>	
					<th>Hora</th>
					<th>Valor</th>
				</tr>			
			</thead>
			<tbody>
				<? for ($i = 0; $i < $qtResgates; $i++) { 
										
					if ($flgcance == "yes") {
						$mtdClick = "selecionaResgate('".$i."','".$qtResgates."','".$resgates[$i]->tags[1]->cdata."');";
					?>
						<tr id="trResgate<?php echo $i; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
					<?} else {?>
						<tr>
					<?} ?>
													
						<td><?php echo $resgates[$i]->tags[0]->cdata; ?></td>
						
						<td><span><? echo $resgates[$i]->tags[1]->cdata; ?></span>
							<?php echo formataNumericos("zzz.zzz.zzz",$resgates[$i]->tags[1]->cdata,"."); ?></td>
						
						<td><?php echo $resgates[$i]->tags[2]->cdata; ?></td>
						
						<td><?php echo $resgates[$i]->tags[3]->cdata; ?></td>
						
						<td><?php echo $resgates[$i]->tags[4]->cdata; ?></td>						
						
						<td><?php echo $resgates[$i]->tags[5]->cdata; ?></td>
						
						<td><span><? echo $resgates[$i]->tags[6]->cdata; ?></span>
							<?php echo number_format(str_replace(",",".",$resgates[$i]->tags[6]->cdata),2,",","."); ?></td>
					</tr>							
				<?} // Fim do for ?>			
			</tbody>
		</table>
	</div>
</div>
<div id="divBotoes" >
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltarDivResgate();return false;" />
	<? if ($flgcance == "yes" && $qtResgates > 0) { ?>
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelar.gif" onClick="showConfirmacao('Deseja cancelar o resgate?','Confirma&ccedil;&atilde;o - Aimaro','cancelarResgates()',metodoBlock,'sim.gif','nao.gif');return false;" />
	<?}?>
</div>

<script type="text/javascript">	
$("#divResgate").css("display","none");	
$("#divOpcoes").css("display","block");

controlaLayout('divResultadoResgates')

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));	
</script>
