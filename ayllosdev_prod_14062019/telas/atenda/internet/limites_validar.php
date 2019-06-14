<?php 

	//************************************************************************//
	//*** Fonte: limites_validar.php 	     	                           ***//
	//*** Autor: Lucas                                                     ***//
	//*** Data : Maio/2012                   Última Alteração: 23/04/2013  ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar alterações nos limites do coop.		       ***//
	//***                                                                  ***//	 
	//***                                                                  ***//	 
	//*** Alterações: 23/04/2013 - Incluido novos campos referente ao      ***//
    //***                          cadastro de limites Vr Boleto           ***//
    //***  						   (David Kruger).   					   ***//	 
	//***			 22/01/2015 - (Chamado 217240) Alterar formato do	   ***// 
	//***			     		   numero de caracteres 				   ***//
    //***   					   de todos os valores de parametros       ***// 
	//***						   para pessoa juridica				   	   ***//
    //*** 						  (Tiago Castro - RKAM).				   ***//
	//***                                                                  ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"]) || !isset($_POST["vllimweb"]) || !isset($_POST["vllimtrf"]) || !isset($_POST["vllimpgo"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$vllimweb = $_POST["vllimweb"];
	$vllimtrf = $_POST["vllimtrf"];
	$vllimpgo = $_POST["vllimpgo"];
	$vllimted = $_POST["vllimted"];
	$vllimvrb = $_POST["vllimvrb"];
	

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	
			
	// Verifica se limite di&aacute;rio &eacute; um decimal v&aacute;lido
	if (!validaDecimal($vllimweb)) {
		exibeErro("Valor do limite di&aacute;rio inv&aacute;lido.");
	}
	
	// Verifica se limite di&aacute;rio para transfer&ecirc;ncia &eacute; um decimal v&aacute;lido
	if (!validaDecimal($vllimtrf)) {
		exibeErro("Valor do limite di&aacute;rio para transfer&ecirc;ncia inv&aacute;lido.");
	}	
	
	// Verifica se limite di&aacute;rio para pagamento &eacute; um decimal v&aacute;lido
	if (!validaDecimal($vllimpgo)) {
		exibeErro("Valor do limite di&aacute;rio para pagamento inv&aacute;lido.");
	}

	// Verifica se limite TED e um decimal valido
	if (!validaDecimal($vllimted)) {
		exibeErro("Valor do limite TED inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlLimites  = "";
	$xmlLimites .= "<Root>";
	$xmlLimites .= "	<Cabecalho>";
	$xmlLimites .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlLimites .= "		<Proc>valida-dados-limites</Proc>";
	$xmlLimites .= "	</Cabecalho>";
	$xmlLimites .= "	<Dados>";
	$xmlLimites .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlLimites .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlLimites .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlLimites .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlLimites .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xmlLimites .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlLimites .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlLimites .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlLimites .= "		<vllimweb>".$vllimweb."</vllimweb>";
	$xmlLimites .= "		<vllimtrf>".$vllimtrf."</vllimtrf>";
	$xmlLimites .= "		<vllimpgo>".$vllimpgo."</vllimpgo>";		
	$xmlLimites .= "		<vllimted>".$vllimted."</vllimted>";
	$xmlLimites .= "		<vllimvrb>".$vllimvrb."</vllimvrb>"; 
	$xmlLimites .= "	</Dados>";
	$xmlLimites .= "</Root>";	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlLimites);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLimites = getObjectXML($xmlResult);	

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjLimites->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimites->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$preposto   = $xmlObjLimites->roottag->tags[0]->tags;
	$qtPreposto = count($preposto);	
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<script type="text/javascript">var metodoBlock = "blockBackground(parseInt($('#divRotina').css('z-index')))";</script>
<?php if ($qtPreposto > 0) {	?>

<?/**/?>
<div id="divSelecaoPreposto">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Conta/dv</th>
					<th>Nome</th>
					<th>CPF</th>
					<th>Cargo</th>
				</tr>			
			</thead>
			<tbody>
				<?  $cor          = "";
					$nomePreposto = "";
					$cpfPreposto  = 0;
					$idPreposto   = 0;
					
					for ($i = 0; $i < $qtPreposto; $i++) { 
															
						if (strtolower($preposto[$i]->tags[5]->cdata) == "yes") {
							$nomePreposto = $preposto[$i]->tags[1]->cdata;										
							$cpfPreposto  = $preposto[$i]->tags[2]->cdata;
							$idPreposto   = $i + 1;
						}
						
						$mtdClick = "selecionaPreposto('".($i + 1)."','".$qtPreposto."','".$preposto[$i]->tags[1]->cdata."','".$preposto[$i]->tags[2]->cdata."');";
					?>
					<tr id="trPreposto<?php echo $i + 1; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
					
						<td><span><? echo $preposto[$i]->tags[0]->cdata ?></span>
							<?php echo formataNumericos("z.zzzz.zzz-z",$preposto[$i]->tags[0]->cdata,".-"); ?></td>
						
						<td><?php echo $preposto[$i]->tags[1]->cdata; ?></td>
						
						<td><?php echo $preposto[$i]->tags[3]->cdata; ?></td>
						
						<td><?php echo $preposto[$i]->tags[4]->cdata; ?></td>					
						
					</tr>
				<?} // Fim do for ?>			
			</tbody>
		</table>
	</div>
</div>
<form action="" name="frmSelecaoPreposto" id="frmSelecaoPreposto" method="post">
	<fieldset>
		<label for="vllimtrf"><? echo utf8ToHtml('Vlr. Limite Diário Transf.:') ?></label>
		<input type="text" id="vllimtrf" value="<?php echo number_format(str_replace(",",".",$vllimtrf),2,",","."); ?>" />
		<br />
		
		<label for="vllimpgo"><? echo utf8ToHtml('Vlr. Limite Diário Pagto.:') ?></label>
		<input type="text" id="vllimpgo" value="<?php echo number_format(str_replace(",",".",$vllimpgo),2,",","."); ?>" />
		<br />
		
		<label for="nmprepat"><? echo utf8ToHtml('Preposto Atual:') ?></label>
		<input type="text" id="nmprepat" value="<?php echo $nomePreposto; ?>" />
		<br />
		
		<label for="nmprepos"><? echo utf8ToHtml('Preposto Novo:') ?></label>
		<input type="text" name="nmprepos" id="nmprepos" />
	</fieldset>

</form>
<div id="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelar.gif" onClick="escondeDivHabilitacao02();return false;" />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="confirmaAtualizacaoPreposto();return false;" />
</div>

<script type="text/javascript">
controlaLayout('divSelecaoPreposto');

// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
$("#divConteudoOpcao").css("height","250");
	
// Mostrar div de preposto e esconde div com limites
mostraDivHabilitacao02();

// Armazena CPF do preposto atual
cpfpreat = <?php echo $cpfPreposto; ?>;

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
<?php } else { ?>
<script type="text/javascript">
// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

// Confirma altera&ccedil;&atilde;o dos limites
confirmaAlteracaoLimites();
</script>
<?php } ?>