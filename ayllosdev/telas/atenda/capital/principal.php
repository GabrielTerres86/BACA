<?php 

	//************************************************************************//
	//*** Fonte: principal.php                                             ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2007                 Última Alteração: 04/06/2013 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opcao Principal da rotina de Capital da tela ***//
	//****						ATENDA                                     ***//
	//***                                                                  ***//	 
	//*** Alter.: 04/09/2009 - Tratar tamanho do div (David).              ***//
	//***         04/04/2011 - Alterado para layout padrão (André - DB1)   ***//
	//***       														   ***//					
	//***		  04/06/2013 - Incluir chamada para b1wgen0155 e criado    ***//
	//***					   campo vlblqjud para listar em tela          ***//
    //***					   (Lucas R.)                                  ***//
    //***         09/08/2013 - Alteração da sigla PAC para PA. (Carlos)    ***//
	//***															   	   ***//
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
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetCapital  = "";
	$xmlGetCapital .= "<Root>";
	$xmlGetCapital .= "	<Cabecalho>";
	$xmlGetCapital .= "		<Bo>b1wgen0021.p</Bo>";
	$xmlGetCapital .= "		<Proc>obtem_dados_capital</Proc>";
	$xmlGetCapital .= "	</Cabecalho>";
	$xmlGetCapital .= "	<Dados>";
	$xmlGetCapital .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetCapital .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetCapital .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetCapital .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetCapital .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetCapital .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetCapital .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetCapital .= "		<idseqttl>1</idseqttl>";
	$xmlGetCapital .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetCapital .= "	</Dados>";
	$xmlGetCapital .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetCapital);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjCapital = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjCapital->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCapital->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$capital = $xmlObjCapital->roottag->tags[0]->tags[0]->tags;
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
    // Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0155.p</Bo>";
	$xml .= "		<Proc>retorna-valor-blqjud</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<nrcpfcgc>0</nrcpfcgc>";
	$xml .= "		<cdtipmov>0</cdtipmov>";
	$xml .= "		<cdmodali>4</cdmodali>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
		// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjBlqJud = getObjectXML($xmlResult);
	
	$vlbloque = $xmlObjBlqJud->roottag->tags[0]->attributes['VLBLOQUE']; 
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjBlqJud->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjBlqJud->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
?>
<form action="" method="post" name="frmDadosCapital" id="frmDadosCapital" class="formulario">

	<label for="vlcaptal">Valor total do capital:</label>
	<input name="vlcaptal" id="vlcaptal" type="text" value="<?php echo number_format(str_replace(",",".",$capital[4]->cdata),2,",","."); ?>" />

	<label for="nrctrpla">Plano de capital:</label>
	<input name="nrctrpla" id="nrctrpla" type="text" value="<?php if ($capital[6]->cdata == 0) { echo "Sem Plano de Capital"; } else { echo formataNumericos("zzz.zzz",$capital[6]->cdata,"."); } ?>" />
	<br />
		
	<label for="vldcotas">Valor das cotas:</label>
	<input name="vldcotas" id="vldcotas" type="text" value="<?php echo number_format(str_replace(",",".",$capital[0]->cdata),2,",","."); ?>" />
	
	<label for="vlprepla">Valor do plano:</label>
	<input name="vlprepla" id="vlprepla" type="text" value="<?php echo number_format(str_replace(",",".",$capital[7]->cdata),2,",","."); ?>" />
	<br />
	
	<label for="vlblqjud">Valor Bloq. Judicial:</label>
	<input name="vlblqjud" id="vlblqjud" type="text" value="<?php echo number_format(str_replace(",",".",$vlbloque),2,",","."); ?>" />
	<br />
	
	<label for="dspagcap"><? echo utf8ToHtml('Débito em:') ?></label>
	<input name="dspagcap" id="dspagcap" type="text" value="<?php echo $capital[9]->cdata; ?>" />
		
	<label for="qtprepag">Parcelas pagas:</label>
	<input name="qtprepag" id="qtprepag" type="text" value="<?php echo formataNumericos("zzz.zzz",$capital[3]->cdata,"."); ?>" />
	<br />
	
	<label for="vlmoefix">Valor da moeda fixa:</label>
	<input name="vlmoefix" id="vlmoefix" type="text" value="<?php echo number_format(str_replace(",",".",$capital[5]->cdata),8,",","."); ?>" />
	
	<label for="dtinipla"><? echo utf8ToHtml('Contratação:') ?></label>
	<input name="dtinipla" id="dtinipla" type="text" value="<?php if (trim($capital[8]->cdata) == "") { echo ""; } else { echo $capital[8]->cdata; } ?>" />
	
	<br />
	<label for="cdagenci">PA:</label>
	<input name="cdagenci" id="cdagenci" type="text" value="<?php if ($capital[11]->cdata == 0) { echo ""; } else { echo $capital[11]->cdata; } ?>" />

	<label for="cdbccxlt">Banco/Caixa:</label>
	<input name="cdbccxlt" id="cdbccxlt" type="text" value="<?php if ($capital[12]->cdata == 0) { echo ""; } else { echo $capital[12]->cdata; } ?>" />
		
	<label for="nrdolote">Lote:</label>
	<input name="nrdolote" id="nrdolote" type="text" value="<?php if ($capital[10]->cdata == 0) { echo ""; } else { echo formataNumericos("zzz.zzz",$capital[10]->cdata,"."); } ?>" />
	<br />
		
</form>

<script type="text/javascript">
// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
$("#divConteudoOpcao").css("height","150px");

controlaLayout('PRINCIPAL');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>