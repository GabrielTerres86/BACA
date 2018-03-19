<?php 

	 /************************************************************************
	   Fonte: principal.php
	   Autor: Guilherme
	   Data : Fevereiro/2008                 Última Alteração: 06/10/2015

	   Objetivo  : Mostrar opcao Principal da rotina de Dep. Vista
                   da tela ATENDA

	   Alterações: 02/09/2010 - Ajuste no xml de retorno (David).
				   24/06/2011 - Alterado para layout padrão (Gabriel - DB1).
				   12/04/2012 - Ajustar leitura das tags do XML (David).
				   04/06/2013 - Incluir label vlblqjud Bloq. Judicial (Lucas R.)   
				   06/10/2016 - Incluido campo de valores bloqueados em acordos de empréstimos,
								Prj. 302 (Jean Michel).
				   11/07/2017 - Novos campos Limite Pré-aprovado disponível e Última Atu. Lim. Pré-aprovado na aba Principal, Melhoria M441. ( Mateus Zimmermann/MoutS )
	
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
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
	$xmlGetDepVista  = "";
	$xmlGetDepVista .= "<Root>";
	$xmlGetDepVista .= "	<Cabecalho>";
	$xmlGetDepVista .= "		<Bo>b1wgen0001.p</Bo>";
	$xmlGetDepVista .= "		<Proc>carrega_dep_vista</Proc>";
	$xmlGetDepVista .= "	</Cabecalho>";
	$xmlGetDepVista .= "	<Dados>";
	$xmlGetDepVista .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDepVista .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDepVista .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDepVista .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDepVista .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDepVista .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetDepVista .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDepVista .= "		<idseqttl>1</idseqttl>";
	$xmlGetDepVista .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDepVista .= "		<flagpesq>FALSE</flagpesq>";
	$xmlGetDepVista .= "		<dtdapesq></dtdapesq>";
	$xmlGetDepVista .= "		<flgerlog>true</flgerlog>";
	$xmlGetDepVista .= "	</Dados>";
	$xmlGetDepVista .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDepVista);
	
	// Cria objeto para classe de tratamento de XML
	$xmlGetDepVista = getObjectXML($xmlResult);
	
    // Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlGetDepVista->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlGetDepVista->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

	// Montar o xml de Requisicao das datas de prejuizo
	$xml = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<idseqttl>1</idseqttl>";
	$xml .= "		<nrcpfope>0</nrcpfope>";
	$xml .= " </Dados>";
	$xml .= "</Root>";	
	
	// Chamada mensageria
    $xmlResult = mensageria($xml, "EMPR0002", "BUSCA_DTPRJATR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

	$camposPrejuizo = $xmlObjeto->roottag->tags[0]->tags;

	// Montar o xml de Requisicao M441
	$xml = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>1</idseqttl>";
	$xml .= "		<nrcpfope>0</nrcpfope>";
	$xml .= " </Dados>";
	$xml .= "</Root>";	
	
	// Chamada mensageria
    $xmlResult = mensageria($xml, "ATENDA", "CONSULTA_CARGA_CPA_VIGENTE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$depvista  = $xmlGetDepVista->roottag->tags[0]->tags[0]->tags;
	$liberaepr = $xmlGetDepVista->roottag->tags[1]->tags;
	$qtLibEpr  = count($liberaepr);
	
	$camposLimData = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	
	// Monta mensagem para aviso sobre liberação de empréstimos
	$msgLibera = "";	
	for ($i = 0; $i < $qtLibEpr; $i++) {
		if ($i == 0) {
			$msgLibera = "Liberacao de emprestimos para ".$liberaepr[$i]->tags[0]->cdata." (".number_format($liberaepr[$i]->tags[1]->cdata,2,",",".").")";
		} else {
			$msgLibera .= ", ".$liberaepr[$i]->tags[0]->cdata." (".number_format($liberaepr[$i]->tags[1]->cdata,2,",",".").")";
		}
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	} 
	
?>
<form action="" method="post" name="frmDadosDepVista" id="frmDadosDepVista" class="formulario" >

	<fieldset>
		
		<label for="vlsddisp"><? echo utf8ToHtml('Disponível:') ?></label>
		<input name="vlsddisp" id="vlsddisp" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($depvista,"vlsddisp")),2,",","."); ?>" />
			
		<label for="vlsaqmax"><? echo utf8ToHtml('SAQUE MÁXIMO:') ?></label>
		<input name="vlsaqmax" id="vlsaqmax" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($depvista,"vlsaqmax")),2,",","."); ?>" />
		<br />
		
		<label for="vlsdbloq"><? echo utf8ToHtml('Bloqueado:') ?></label>
		<input name="vlsdbloq" id="vlsdbloq" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($depvista,"vlsdbloq")),2,",","."); ?>" />
			
		<label for="vlacerto"><? echo utf8ToHtml('ACERTO DE CONTA:') ?></label>
		<input name="vlacerto" id="vlacerto" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($depvista,"vlacerto")),2,",","."); ?>" />
		<br />
		
		<label for="vlsdblpr"><? echo utf8ToHtml('Bloqueado Praça:') ?></label>
		<input name="vlsdblpr" id="vlsdblpr" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($depvista,"vlsdblpr")),2,",","."); ?>" />
		<br />

		<label for="vlipmfpg"><? echo utf8ToHtml('Prox. Deb. CPMF:') ?></label>
		<input name="vlipmfpg" id="vlipmfpg" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($depvista,"vlipmfpg")),2,",","."); ?>" />
		
		<label for="vlsdblfp"><? echo utf8ToHtml('Bloq. Fora Praça:') ?></label>
		<input name="vlsdblfp" id="vlsdblfp" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($depvista,"vlsdblfp")),2,",","."); ?>" />
		
		<label for="vllimdis"><? echo utf8ToHtml('Limite Pré-aprovado disponível:') ?></label>
		<input name="vllimdis" id="vllimdis" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($camposLimData,"vllimdis")),2,",","."); ?>" />

		<label for="vlblqaco"><? echo utf8ToHtml('Bloqueado Acordo:') ?></label>
		<input name="vlblqaco" id="vlblqaco" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($depvista,"vlblqaco")),2,",","."); ?>" />

		<label for="dtliberacao"><? echo utf8ToHtml('Última Atu. Lim. Pré-aprovado:') ?></label>
		<input name="dtliberacao" id="dtliberacao" type="text" value="<?php echo getByTagName($camposLimData,"dtliberacao"); ?>" />

		<label for="vlsdchsl"><? echo utf8ToHtml('Cheque Salário:') ?></label>
		<input name="vlsdchsl" id="vlsdchsl" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($depvista,"vlsdchsl")),2,",","."); ?>" />

		<label for="dttrapre"><? echo utf8ToHtml('Data Transf.Prejuízo:') ?></label>
		<input type="text" name="dttrapre" id="dttrapre" value="<?php echo getByTagName($camposPrejuizo, "dttrapre"); ?>">

		<label for="vlblqjud"><? echo utf8ToHtml('Bloq. Judicial:') ?></label>
		<input name="vlblqjud" id="vlblqjud" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($depvista,"vlblqjud")),2,",","."); ?>" />

		<label for="dtiniatr"><? echo utf8ToHtml('Data Início Atraso:') ?></label>
		<input type="text" name="dtiniatr" id="dtiniatr" value="<?php echo getByTagName($camposPrejuizo, "dtiniatr"); ?>">

		<label for="vlstotal"><? echo utf8ToHtml('Saldo Total:') ?></label>
		<input name="vlstotal" id="vlstotal" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($depvista,"vlstotal")),2,",",".");  ?>" />
		
		<div style="float: right; padding-right: 5px;">
			<a href="#" class="botao" id="btDetVoltar" onClick="mostraDetalhesAtraso();" style="padding: 3px 6px;">Detahes de atraso/preju&iacute;zo</a>
		</div>
	</fieldset>
	
	<fieldset>
		
		<label for="vllimcre"><? echo utf8ToHtml('Limite Crédito:') ?></label>
		<input name="vllimcre" id="vllimcre" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($depvista,"vllimcre")),2,",","."); ?>" />
		
		<label for="dtultlcr"><? echo utf8ToHtml('Útima Atualização:') ?></label>
		<input name="dtultlcr" id="dtultlcr" type="text" value="<?php echo getByTagName($depvista,"dtultlcr"); ?>" />
		<br />
		
	</fieldset>

</form>

<script type="text/javascript">

controlaLayout('frmDadosDepVista');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

<?php if ($msgLibera <> "") { echo 'showError("inform","'.$msgLibera.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");'; } ?>
</script>
