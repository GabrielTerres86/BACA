<?php 

	//************************************************************************//
	//*** Fonte: principal.php                                             ***//
	//*** Autor: David                                                     ***//
	//*** Data : Setembro/2008                Última Alteração: 24/07/2015 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opcao Principal da rotina Cartões Magnéticos ***//
	//***             da tela ATENDA                                       ***//
	//***                                                                  ***//	 
	//*** Alterações: 22/10/2010 - Tratamento nas operações que possuem    ***//
	//***                          mensagem de confirmação (David).        ***//
	//***																   ***//
	//***		      13/07/2011 - Alterado para layout padrão 			   ***//
    //***					       (Rogerius - DB1). 					   ***//	
	//***																   ***//
	//***			  22/12/2011 - Ajuste para inclusão das opções   	   ***//
	//***						   Numérica, Solicitar Letras (Adriano).   ***//
	//***																   ***//
	//***			  05/01/2012 - Ajuste para alterar senha do cartao     ***//
	//***						   ao solicitar entrega (Adriano).   	   ***//
	//***																   ***//
	//***			  09/07/2012 - Retirado campo "redirect" popup. (Jorge)***//
	//***																   ***//
	//***			  07/11/2012 - Adicionado param. 'tpusucar' (Lucas).   ***//
	//***																   ***//
	//***			  24/07/2015 - Ajustado para esconder o botao Alterar  ***//
	//***						   quando o tipo de pessoa for Juridica    ***//
	//***						   (James) 								   ***//
	//***																   ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$inpessoa = $_POST["inpessoa"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisição
	$xmlGetMagneticos  = "";
	$xmlGetMagneticos .= "<Root>";
	$xmlGetMagneticos .= "	<Cabecalho>";
	$xmlGetMagneticos .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlGetMagneticos .= "		<Proc>obtem-cartoes-magneticos</Proc>";
	$xmlGetMagneticos .= "	</Cabecalho>";
	$xmlGetMagneticos .= "	<Dados>";
	$xmlGetMagneticos .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetMagneticos .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetMagneticos .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetMagneticos .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetMagneticos .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetMagneticos .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetMagneticos .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetMagneticos .= "		<idseqttl>1</idseqttl>";
	$xmlGetMagneticos .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetMagneticos .= "	</Dados>";
	$xmlGetMagneticos .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetMagneticos);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjMagneticos = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjMagneticos->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjMagneticos->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$magneticos   = $xmlObjMagneticos->roottag->tags[0]->tags;
	$qtMagneticos = count($magneticos);
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<div id="divMagneticosPrincipal">
	<form action="" method="post" name="frmDadosMagneticos" id="frmDadosMagneticos">
		<div class="divRegistros">	
			<table>
				<thead>
					<tr>
						<th><? echo utf8ToHtml('Titular'); ?></th>
						<th><? echo utf8ToHtml('N&uacute;mero do Cart&atilde;o');  ?></th>
						<th><? echo utf8ToHtml('Situa&ccedil;&atilde;o');  ?></th>
					</tr>
				</thead>
				<tbody>
					<?
					for ($i = 0; $i < $qtMagneticos; $i++) {
						$aux = $i + 1;
						$seleciona = "selecionaMagnetico('". $aux ."','". $qtMagneticos ."','". $magneticos[$i]->tags[1]->cdata ."','".$magneticos[$i]->tags[3]->cdata."');";
					?>
					<tr id="trMagnetico<?php echo $i + 1; ?>" onFocus="<? echo $seleciona ?>"  onClick="<? echo $seleciona ?>">
						<td><span><?php echo $magneticos[$i]->tags[0]->cdata; ?></span>
								  <?php echo $magneticos[$i]->tags[0]->cdata; ?>
						</td>
						<td><span><?php echo $magneticos[$i]->tags[1]->cdata; ?></span>
								  <?php echo $magneticos[$i]->tags[1]->cdata; ?>
						</td>
						<td><span><?php echo $magneticos[$i]->tags[2]->cdata; ?></span>
								  <?php echo $magneticos[$i]->tags[2]->cdata; ?>
						</td>
					</tr>
				<? } ?>	
				</tbody>
			</table>
		</div>	

		<div id="divBotoes">
			<?php IF ($inpessoa == 1){ ?>
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/alterar.gif" <?php if (!in_array("A",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="solicitacaoCartao(\'A\');return false;"'; } ?>>
			<?php } ?>
			
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/bloquear.gif" <?php if (!in_array("B",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="confirmaBloqueioCartao();return false;"'; } ?>>
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelar.gif" <?php if (!in_array("X",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="confirmaCancelamentoCartao();return false;"'; } ?>>
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/consultar.gif" <?php if (!in_array("C",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="consultaCartaoMagnetico();return false;"'; } ?>>
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/entregar.gif" <?php if (!in_array("L",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="carregaPrepostosEntrega(\'E\');return false;"'; } ?>>

			<br />
			
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/excluir.gif" <?php if (!in_array("E",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="confirmaExclusaoCartao();return false;"'; } ?>>
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/imprimir.gif" <?php if (!in_array("M",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="verificaImpressao();return false;"'; } ?>>
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/senha.gif" <?php if (!in_array("H",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="acessaOpcao();return false;"'; } ?>>
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/solicitar.gif" <?php if (!in_array("I",$glbvars["opcoesTela"])) { echo 'style="cursor: default" onClick="return false;"'; } else { echo 'onClick="solicitacaoCartao(\'I\');return false;"'; } ?>>
			
		</div>
		
	</form>
</div>

<div id="divMagneticosOpcao01" 		style="display: none;"></div>
<div id="divConteudoLimiteSaqueTAA" style="display: none;"></div>

<div id="divNumericaLetras" style="display: none;">
	
	<br />
	<input type="image" id="btnVoltarOpcao" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltarDivPrincipal(185);return false;">
	<input type="image" id="btnNumerico" src="<?php echo $UrlImagens; ?>botoes/numerica.gif" onClick="acessaOpcaoSenha('');return false;">	
	<input type="image" id="btnLetrasSolicitar" src="<?php echo $UrlImagens; ?>botoes/letras_seguranca.gif" onClick="opcaoSolicitarLetras('');return false;">
	<br />
	
	
</div>


<form action="" name="frmImpressaoMagnetico" id="frmImpressaoMagnetico" method="post">
<input type="hidden" name="nrdconta" id="nrdconta" value="">
<input type="hidden" name="nrcartao" id="nrcartao" value="">
<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>		

<script type="text/javascript">
// Formata o layout
formataPrincipal();

<?php if ($qtMagneticos > 0) { ?>
if (idLinha > 0) {
	selecionaMagnetico(idLinha,<?php echo $qtMagneticos; ?>,nrcartao,tpusucar);	
} else {
	selecionaMagnetico(1,<?php echo $qtMagneticos; ?>,'<?php echo $magneticos[0]->tags[1]->cdata; ?>',<?php echo $magneticos[0]->tags[3]->cdata; ?>);
}
<?php } ?>

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está atrás do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>