<?php 

	/************************************************************************
          Fonte: principal.php
	        Autor: Guilherme
          Data : Fevereiro/2008                 &Uacute;ltima Altera&ccedil;&atilde;o:   /  /

	      Objetivo  : Listar os convenios

	      Altera&ccedil;&otilde;es:
              30/06/2011 - Alterado para layout padrão (Rogerius - DB1).		
		  
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
		
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
		
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetDadosConvenios  = "";
	$xmlGetDadosConvenios .= "<Root>";
	$xmlGetDadosConvenios .= "	<Cabecalho>";
	$xmlGetDadosConvenios .= "		<Bo>b1wgen0026.p</Bo>";
	$xmlGetDadosConvenios .= "		<Proc>lista_conven</Proc>";
	$xmlGetDadosConvenios .= "	</Cabecalho>";
	$xmlGetDadosConvenios .= "	<Dados>";
	$xmlGetDadosConvenios .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosConvenios .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosConvenios .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosConvenios .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosConvenios .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosConvenios .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDadosConvenios .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosConvenios .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosConvenios .= "	</Dados>";
	$xmlGetDadosConvenios .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosConvenios);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosConvenios = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDadosConvenios->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosConvenios->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Seta a tag de convenios para a variavel
	$convenios = $xmlObjDadosConvenios->roottag->tags[0]->tags;

	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
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
				<th><? echo utf8ToHtml('C&oacute;d.'); ?></th>
				<th><? echo utf8ToHtml('Descri&ccedil;&atilde;o');  ?></th>
				<th><? echo utf8ToHtml('Autoriza&ccedil;&atilde;o');  ?></th>
				<th><? echo utf8ToHtml('Ult.D&eacute;bito');  ?></th>
				<th><? echo utf8ToHtml('Refer&ecirc;ncia');  ?></th>
			</tr>
		</thead>
		<tbody>
			<? 
			for ($i = 0; $i < count($convenios); $i++)	{		
			?>
				<tr>
					<td><span><?php echo $convenios[$i]->tags[2]->cdata; ?></span>
							  <?php echo $convenios[$i]->tags[2]->cdata; ?>
					</td>
					<td><span><?php echo $convenios[$i]->tags[3]->cdata; ?></span>
							  <?php echo $convenios[$i]->tags[3]->cdata; ?>
					</td>
					<td><span><?php echo dataParaTimestamp($convenios[$i]->tags[4]->cdata); ?></span>
							  <?php echo $convenios[$i]->tags[4]->cdata; ?>
					</td>
					<td><span><?php echo dataParaTimestamp($convenios[$i]->tags[5]->cdata); ?></span>
							  <?php echo $convenios[$i]->tags[5]->cdata; ?>
					</td>
					<td><span><?php echo $convenios[$i]->tags[6]->cdata; ?></span>
							  <?php echo $convenios[$i]->tags[6]->cdata; ?>
					</td>

				</tr>
		<? } ?>	
		</tbody>
	</table>
</div>	

<script type="text/javascript">
// Formata layout
controlaLayout();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
