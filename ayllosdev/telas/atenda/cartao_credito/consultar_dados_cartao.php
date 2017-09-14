<?php 

	//************************************************************************//
	//*** Fonte: consultar_dados_cartao.php                                ***//
	//*** Autor: Guilherme                                                 ***//
	//*** Data : Março/2008                   Última Alteração: 14/10/2015 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opção de Consulta da rotina de Cartões de    ***//
	//***             Crédito da tela ATENDA                               ***//
	//***                                                                  ***//	 
	//*** Alterações: 04/09/2008 - Mostrar data de solicitação de 2 via de ***//
	//***                          senha de cartão de crédito (David)      ***//	
	//***                                                                  ***//
	//***             04/11/2010 - Adaptação Cartão PJ (David).            ***//
	//***                                                                  ***//
	//***             07/07/2011 - Alterado para layout padrão 			   ***//
	//***                          (Gabriel - DB1)						   ***//
	//***																   ***//
	//***             10/07/2012 - Incluído campo 'Nome no Plastico' no    ***//
	//***             			   formulário (Guilherme Maba).            ***//
	//***                                                                  ***//
	//***             24/08/2015 - Incluido os campos referente ao acesso  ***//
	//***             			   do Sistema do TAA. (James)              ***//
	//***                                                                  ***//
	//***             14/10/2015 - Desenvolvimento do projeto 126. (James) ***//
	//***                                                                  ***//
	//***             31/08/2017 - Alterar os botões da tela e incluir o   ***//
	//***                          novo botão de histórico de alteração    ***//
	//***                          de limite de crédito (Renato - Prj360)  ***//
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
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}			
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrcrd"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato do cart&atilde;o inv&aacute;lido.");
	}	
	
	// Monta o xml de requisição
	$xmlGetDadosCartao  = "";
	$xmlGetDadosCartao .= "<Root>";
	$xmlGetDadosCartao .= "	<Cabecalho>";
	$xmlGetDadosCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlGetDadosCartao .= "		<Proc>consulta_dados_cartao</Proc>";
	$xmlGetDadosCartao .= "	</Cabecalho>";
	$xmlGetDadosCartao .= "	<Dados>";
	$xmlGetDadosCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlGetDadosCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDadosCartao .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosCartao .= "	</Dados>";
	$xmlGetDadosCartao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosCartao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjNovoCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjNovoCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

	$dados = $xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags;
	$nrcrcard = getByTagName($dados,"NRCRCARD");
	$nrctrcrd = getByTagName($dados,"NRCTRCRD");
	$dscartao = getByTagName($dados,"DSCARTAO");
	$nmextttl = getByTagName($dados,"NMEXTTTL");
	$nmtitcrd = getByTagName($dados,"NMTITCRD");
	$nrcpftit = getByTagName($dados,"NRCPFTIT");
	$dsparent = getByTagName($dados,"DSPARENT");
	$dssituac = getByTagName($dados,"DSSITUAC");
	$vlsalari = getByTagName($dados,"VLSALARI");
	$vlsalcon = getByTagName($dados,"VLSALCON");
	$vloutras = getByTagName($dados,"VLOUTRAS");
	$vlalugue = getByTagName($dados,"VLALUGUE");
	$dddebito = getByTagName($dados,"DDDEBITO");
	$vllimite = getByTagName($dados,"VLLIMITE");
	$dtpropos = getByTagName($dados,"DTPROPOS");
	$vllimdeb = getByTagName($dados,"VLLIMDEB");
	$dtsolici = getByTagName($dados,"DTSOLICI");
	$dtlibera = getByTagName($dados,"DTLIBERA");
	$dtentreg = getByTagName($dados,"DTENTREG");
	$dtcancel = getByTagName($dados,"DTCANCEL");
	$dsmotivo = getByTagName($dados,"DSMOTIVO");
	$dtvalida = getByTagName($dados,"DTVALIDA");
	$qtanuida = getByTagName($dados,"QTANUIDA");
	$nrctamae = getByTagName($dados,"NRCTAMAE");
	$dsde2via = getByTagName($dados,"DSDE2VIA");
	$dtanucrd = getByTagName($dados,"DTANUCRD");
	$dspaganu = getByTagName($dados,"DSPAGANU");
	$nmoperad = getByTagName($dados,"NMOPERAD");
	$ds2viasn = getByTagName($dados,"DS2VIASN");
	$ds2viacr = getByTagName($dados,"DS2VIACR");
	$lbcanblq = getByTagName($dados,"LBCANBLQ");
	$inpessoa = getByTagName($dados,"INPESSOA");
	$inacetaa = getByTagName($dados,"inacetaa");
	$dsacetaa = getByTagName($dados,"dsacetaa");
	$dtacetaa = getByTagName($dados,"dtacetaa");
	$cdopetaa = getByTagName($dados,"cdopetaa");
	$nmopetaa = getByTagName($dados,"nmopetaa");
	$cdadmcrd = getByTagName($dados,"cdadmcrd");
	$flgdebit = ((getByTagName($dados,"flgdebit") == "no") ? "" : "checked");
    $dtrejeit = getByTagName($dados,"dtrejeit");
    $nrcctitg = getByTagName($dados,"nrcctitg");
    $dsdpagto = getByTagName($dados,"dsdpagto");
    $dsgraupr = getByTagName($dados,"dsgraupr");
		   
	if (getByTagName($dados,"DDDEBANT") == 0){
		$dddebant = "";
	} else {
		$dddebant = getByTagName($dados,"DDDEBANT");
	}

	$aMensagem = Array();	
	foreach($xmlObjNovoCartao->roottag->tags[1]->tags as $mensagem ) {
		$aMensagem[] = getByTagName($mensagem->tags,'dsmensag');
	}
	
	echo '<script type="text/javascript">';
	echo '	exibirMensagens("'.implode( "|", $aMensagem).'","bloqueiaFundo(divRotina)");';
	echo '</script>';	

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<div id="divResultadoConsulta">
	<form action="" method="post" name="frmDadosCartao" id="frmDadosCartao">
		<fieldset>
			<legend><? echo utf8ToHtml('Dados do Cartão:') ?></legend>
			
			<label for="nrcrcard"><? echo utf8ToHtml('Cartão:') ?></label>
			<input type="text" name="nrcrcard" id="nrcrcard" value="<? echo formataNumericos("9999.9999.9999.9999",$nrcrcard,"."); ?>" />
			<input type="text" name="dscartao" id="dscartao" value="<? echo $dscartao; ?>" />
			<br />
			
			<label for="nmextttl"><? echo utf8ToHtml('Titular:') ?></label>
			<input type="text" name="nmextttl" id="nmextttl" value="<? echo $nmextttl; ?>" />
			
			<label for="nrcpftit"><? echo utf8ToHtml('C.P.F.:') ?></label>
			<input type="text" name="nrcpftit" id="nrcpftit" value="<? echo formataNumericos("999.999.999-99",$nrcpftit,".-"); ?>" />
			<br />
			<? if ($inpessoa == 1) { // Pessoa Física ?>
			
				<label for="dsparent"><? echo utf8ToHtml('Parentesco:') ?></label>
				<input type="text" name="dsparent" id="dsparent" value="<?php echo $dsparent; ?>" />
				
				<label for="dssituac"><? echo utf8ToHtml('Situação:') ?></label>
				<input type="text" name="dssituac" id="dssituac" value="<?php echo $dssituac; ?>" />
				<br />
				
				<label for="nmtitcrd"><? echo utf8ToHtml('Nome no Plastico:') ?></label>
				<input type="text" name="nmtitcrd" id="nmtitcrd" value="<? echo $nmtitcrd; ?>" />
				
				<label for="dsgraupr"><? echo utf8ToHtml('Titularidade:') ?></label>
				<input type="text" name="dsgraupr" id="dsgraupr" value="<? echo $dsgraupr; ?>" />				
				
				<br />
			
				<label for="vlsalari"><? echo utf8ToHtml('Salário:') ?></label>
				<input type="text" name="vlsalari" id="vlsalari" value="<?php echo number_format(str_replace(",",".",$vlsalari),2,",","."); ?>" />
								
				<label for="vlsalcon"><? echo utf8ToHtml('Salário Cônjuge:') ?></label>
				<input type="text" name="vlsalcon" id="vlsalcon" value="<?php echo number_format(str_replace(",",".",$vlsalcon),2,",","."); ?>" />
				
				<label for="vloutras"><? echo utf8ToHtml('Rendas:') ?></label>
				<input type="text" name="vloutras" id="vloutras" value="<?php echo number_format(str_replace(",",".",$vloutras),2,",","."); ?>" />
							
				<label for="vlalugue"><? echo utf8ToHtml('Aluguel:') ?></label>
				<input type="text" name="vlalugue" id="vlalugue" value="<?php echo number_format(str_replace(",",".",$vlalugue),2,",","."); ?>" />
				
				<label for="vllimite"><? echo utf8ToHtml('Limite:') ?></label>
				<input type="text" name="vllimite" id="vllimite" value="<?php echo $vllimite; ?>" />
				
				<label for="dddebito"><? echo utf8ToHtml('Dia Venc. Fatura:') ?></label>
				<input type="text" name="dddebito" id="dddebito" value="<?php echo $dddebito; ?>" />
				<br />
			
				<label for="dtrejeit"><? echo utf8ToHtml('Dt. Rejeição:') ?></label>
	     		<input type="text" name="dtrejeit" id="dtrejeit" value="<?php echo $dtrejeit ?>" />
			
				<label for="vllimdeb"><? echo utf8ToHtml('Limite Débito:') ?></label>
	     		<input type="text" name="vllimdeb" id="vllimdeb" value="<?php echo number_format(str_replace(",",".",$vllimdeb),2,",","."); ?>" />
				
				<label for="dddebant"><? echo utf8ToHtml('Dia Venc. Fat. 2v.:') ?></label>
				<input type="text" name="dddebant" id="dddebant" value="<?php echo $dddebant; ?>" />
				<br />
				
			<? } else { // Pessoa Jurídica  ?>
				
				<label for="nmtitcrd"><? echo utf8ToHtml('Nome no Plástico:') ?></label>
				<input type="text" name="nmtitcrd" id="nmtitcrd" value="<? echo $nmtitcrd; ?>" />
				
				<label for="dsparent"><? echo utf8ToHtml('Representante Solicitante:') ?></label>
				<input type="text" name="dsparent" id="dsparent" value="<?php echo $dsparent; ?>" />
				<br />
			
				<label for="dssituac"><? echo utf8ToHtml('Situação:') ?></label>
				<input type="text" name="dssituac" id="dssituac" value="<?php echo $dssituac; ?>" />
				
				<label for="vllimite"><? echo utf8ToHtml('Limite:') ?></label>
				<input type="text" name="vllimite" id="vllimite" value="<?php echo $vllimite; ?>" />
				
				<label for="dddebito"><? echo utf8ToHtml('Dia Venc. Fatura:') ?></label>
				<input type="text" name="dddebito" id="dddebito" value="<?php echo $dddebito; ?>" />
				<br />
				
				<label for="dtrejeit"><? echo utf8ToHtml('Dt. Rejeição:') ?></label>
	     		<input type="text" name="dtrejeit" id="dtrejeit" value="<?php echo $dtrejeit ?>" />
				
				<label for="vllimdeb"><? echo utf8ToHtml('Limite Débito:') ?></label>
				<input type="text" name="vllimdeb" id="vllimdeb" value="<?php echo number_format(str_replace(",",".",$vllimdeb),2,",","."); ?>" />
				
				<label for="dddebant"><? echo utf8ToHtml('Dia Venc. Fat. 2v.:') ?></label>
				<input type="text" name="dddebant" id="dddebant" value="<?php echo $dddebant; ?>" />
				<br />
			<? } ?>
			
			<label for="dtpropos"><? echo utf8ToHtml('Proposta:') ?></label>
			<input type="text" name="dtpropos" id="dtpropos" value="<?php echo $dtpropos; ?>" />
			
			<label for="dtsolici"><? echo utf8ToHtml('Pedido:') ?></label>
			<input type="text" name="dtsolici" id="dtsolici" value="<?php echo $dtsolici; ?>" />
			
			<label for="dtlibera"><? echo utf8ToHtml('Liberação:') ?></label>
			<input type="text" name="dtlibera" id="dtlibera" value="<?php echo $dtlibera; ?>" />
			
			<label for="dtentreg"><? echo utf8ToHtml('Entrega:') ?></label>
			<input type="text" name="dtentreg" id="dtentreg" value="<?php echo $dtentreg; ?>" />
			
			<label for="dtcancel"><? echo $lbcanblq; ?>:</label>
			<input type="text" name="dtcancel" id="dtcancel" value="<?php echo $dtcancel; ?>" />
			
			<input type="text" name="dsmotivo" id="dsmotivo" value="<?php echo $dsmotivo; ?>" />
			
			<label for="dtvalida"><? echo utf8ToHtml('Validade Cartão:') ?></label>
			<input type="text" name="dtvalida" id="dtvalida" value="<?php echo $dtvalida; ?>" />
			
			<label for="flgdebit"><? echo utf8ToHtml('Habilita função débito:') ?></label>
			<input type="checkbox" name="flgdebit" id="flgdebit" <?php echo $flgdebit; ?> />
			
			<label for="dsdpagto"><? echo utf8ToHtml('Forma de Pag:') ?></label>
			<input type="text" name="dsdpagto" id="dsdpagto" value="<?php echo $dsdpagto; ?>" />
			
			<br />
			
			<label for="nrcctitg"><? echo utf8ToHtml('Nr. Conta Cartão:') ?></label>
			<input type="text" name="nrcctitg" id="nrcctitg" value="<?php echo $nrcctitg; ?>" />			
			
			<input type="text" name="ds2viasn" id="ds2viasn" value="<?php echo $ds2viasn; ?>" />
			
			<input type="text" name="ds2viacr" id="ds2viacr" value="<?php echo $ds2viacr; ?>" />
			
			<input type="text" name="dsde2via" id="dsde2via" value="<?php echo $dsde2via; ?>" />
			
			<br />
			
			<label for="dtanucrd"><? echo utf8ToHtml('Anuidade Administradora:') ?></label>
			<input type="text" name="dtanucrd" id="dtanucrd" value="<?php echo $dtanucrd; ?>" />
			
			<input type="text" name="dspaganu" id="dspaganu" value="<?php echo $dspaganu; ?>" />
			
			<label for="qtanuida"><? echo utf8ToHtml('Anuidades Pagas:') ?></label>
			<input type="text" name="qtanuida" id="qtanuida" value="<?php echo $qtanuida; ?>" />
			
			<br />
		
			<label for="nmoperad"><? echo utf8ToHtml('Alterado Por:') ?></label>
			<input type="text" name="nmoperad" id="nmoperad" value="<?php echo $nmoperad; ?>" />
			
			<label for="nrctrcrd"><? echo utf8ToHtml('Proposta:') ?></label>
			<input type="text" name="nrctrcrd" id="nrctrcrd" value="<?php echo formataNumericos("zzz.zzz.zzz",$nrctrcrd,"."); ?>" />
			
			<? if (($cdadmcrd >= 10) && ($cdadmcrd <= 80)){ ?>
			
			<label for="dsacetaa"><? echo utf8ToHtml('Acesso TAA:') ?></label>
			<input type="text" name="dsacetaa" id="dsacetaa" value="<?php echo $dsacetaa; ?>" />
			
			<label for="dtacetaa"><? echo utf8ToHtml('Data Alteração Acesso:') ?></label>
			<input type="text" name="dtacetaa" id="dtacetaa" value="<?php echo $dtacetaa; ?>" />
			
			<label for="nmopetaa"><? echo utf8ToHtml('Acesso Alterado Por:') ?></label>
			<input type="text" name="nmopetaa" id="nmopetaa" value="<?php echo $cdopetaa.' - '.$nmopetaa; ?>" />			
			
			<? } ?>
			
			<label for="nrctamae"><? echo utf8ToHtml('Conta-Mãe:') ?></label>
			<input type="text" name="nrctamae" id="nrctamae" value="<?php echo formataNumericos("9999.9999.9999.9999",$nrctamae,"."); ?>" />
		
		</fieldset>
	</form>
	<div id="divBotoes">
		<!--input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"          onClick="voltaDiv(0,1,4);return false;">
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/avais.gif"           onClick="mostraAvais();return false;">
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/ultimos_debitos.gif" onClick="mostraUltDebitos();return false;"-->
		
		<a href="#" class="botao" id="btvoltar" onClick="voltaDiv(0,1,4);return false;">Voltar</a>
		<a href="#" class="botao" id="btavais" onClick="mostraAvais();return false;">Avais</a>
		<a href="#" class="botao" id="btultimos_debitos" onClick="mostraUltDebitos();return false;">&Uacute;ltimos D&eacute;bitos</a>
		<? if (($cdadmcrd >= 10) && ($cdadmcrd <= 80)){ ?>
		<a href="#" class="botao" id="bthislim" onClick="mostraHisLimite(); return false;">Hist. Limite</a>
		<? } ?>
	</div>
</div>

<script type="text/javascript">
	$("#divOpcoesDaOpcao1").css("display","block");
	$("#divConteudoCartoes").css("display","none");
	
	controlaLayout('frmDadosCartao');

	hideMsgAguardo();
	bloqueiaFundo(divRotina);
</script>
