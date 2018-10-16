<?php 

	//**********************************************************************************************//
	//*** Fonte: envio_solicitacao.php                                                                   ***//
	//*** Autor: Anderson-Alan                                                                   ***//
	//*** Data : Setembro/2018                Última Alteração: 24/09/2018                       ***//
	//***                                                                                        ***//
	//*** Objetivo  : Mostrar opcao Principal da rotina de Portabilidade Salárial da tela ATENDA ***//
	//****			                                                                             ***//
	//***                                                                                        ***//	 
	//*** Alter.:                                                                                ***//
	//***															   	                         ***//
	//**********************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);
	}
	
	$nrdconta        = (isset($_POST['nrdconta']))        ? $_POST['nrdconta']        : 0  ;
  $inpessoa        = (isset($_POST['inpessoa']))        ? $_POST['inpessoa']        : 0  ;
	
	$xml  = "<Root>";
  $xml .= " <Dados>";
  $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
  $xml .= " </Dados>";
  $xml .= "</Root>";
	
  $xmlResult = mensageria($xml, "ATENDA", "BUSCA_DADOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
  $xmlObject = getObjectXML($xmlResult);
  
  if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
      $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
      exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial()', false);
  }
  
  $registro      = $xmlObject->roottag->tags[0];
	$nrcpfcgc      = getByTagName($registro->tags,'nrcpfcgc');
	$nmprimtl      = getByTagName($registro->tags,'nmprimtl');
	$nrtelefo      = getByTagName($registro->tags,'nrtelefo');
	$dsdemail      = getByTagName($registro->tags,'dsdemail');
	$dsdbanco      = getByTagName($registro->tags,'DSDBANCO');
	$cdageban      = getByTagName($registro->tags,'CDAGEBAN');
	$nrispbif_ban  = getByTagName($registro->tags,'nrispbif_ban');
	$nrcnpjag      = getByTagName($registro->tags,'NRCNPJAG');
  $nrdocnpj_emp  = getByTagName($registro->tags,'nrdocnpj_emp');
  $nmprimtl_emp  = getByTagName($registro->tags,'nmprimtl_emp');
  $nrispbif       = getByTagName($registro->tags,'nrispbif');
  $nrdocnpj      = getByTagName($registro->tags,'nrdocnpj');
  $tpconta       = getByTagName($registro->tags,'TPCONTA');
  $cdagectl      = getByTagName($registro->tags,'cdagectl');
  $nrconta       = getByTagName($registro->tags,'nrconta');
  $dscodigo    = getByTagName($registro->tags,'dscodigo');
  $dtretorno     = getByTagName($registro->tags,'dtretorno');
  $dsmotivo      = getByTagName($registro->tags,'dsmotivo');
	
?>
<form action="" method="post" name="frmDadosPortabilidade" id="frmDadosPortabilidade" class="formulario">
	
	<div id="divDados" class="clsCampos">
	
	<fieldset style="padding: 5px">
		<legend>Cooperado</legend>
			<label for="nrcpfcgc" class="clsCampos">CPF:</label>
			<input name="nrcpfcgc" type="text" id="nrcpfcgc" readonly="readonly" class="clsCampos" value="<?php echo number_format(str_replace(",",".",$nrcpfcgc),2,",","."); ?>" />
			
			<label for="nmprimtl" class="clsCampos">Nome:</label>
			<input id="nmprimtl" name="nmprimtl" readonly="readonly" class="clsCampos" type="text" value="<?php echo $nmprimtl; ?>" />
			
			<br style="clear:both"/>
			
			<label for="nrtelefo" class="clsCampos">Telefone:</label>
			<input id="nrtelefo" name="nrtelefo" readonly="readonly" class="clsCampos" type="text" value="<?php echo $nrtelefo; ?>" />
			
			<label for="dsdemail" class="clsCampos">E-mail:</label>
			<input id="dsdemail" name="dsdemail" readonly="readonly" class="clsCampos" type="text" value="<?php echo $dsdemail; ?>" />
	</fieldset>
	
	<fieldset style="padding: 5px">
		<legend>Banco Folha</legend>
			<label for="dsdbanco" class="clsCampos">Banco Folha:</label>
            <select id="dsdbanco" name="dsdbanco" class="clsCampos">
                <option value="" <?php echo ($inmotcan == 0 ? 'selected' : ''); ?>>-</option>
                
            </select>
			
			<!-- 
			<label for="cdageban" class="clsCampos">Ag�ncia:</label>
			<input type="text" id="cdageban" name="cdageban" class="clsCampos" value="<?php echo $cdageban; ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			-->
			
			<br style="clear:both"/>
			
			<label for="nrispbif_ban" class="clsCampos">ISPB:</label>
			<input id="nrispbif_ban" name="nrispbif_ban" readonly="readonly" type="text" class="clsCampos" value="<?php echo $nrispbif_ban; ?>" />
			
			<label for="nrcnpjag" class="clsCampos">CNPJ:</label>
			<input name="nrcnpjag" type="text" id="nrcnpjag" readonly="readonly" class="clsCampos" value="<?php echo number_format(str_replace(",",".",$nrcnpjag),2,",","."); ?>" />
	</fieldset>
	
	<fieldset>
		<legend>Empregador</legend>
			<label for="nrdocnpj_emp" class="clsCampos">CNPJ:</label>
			<input name="nrdocnpj_emp" type="text" id="nrdocnpj_emp" readonly="readonly" class="clsCampos" value="<?php echo number_format(str_replace(",",".",$nrdocnpj_emp),2,",","."); ?>" />
	
			<label for="nmprimtl_emp" class="clsCampos">Nome:</label>
			<input id="nmprimtl_emp" name="nmprimtl_emp" readonly="readonly" type="text" class="clsCampos" value="<?php echo $nmprimtl_emp; ?>" />
	</fieldset>
	
	<fieldset style="padding: 5px">
		<legend>Institui��o Destinatria</legend>
			<label for="nrispbif" class="clsCampos">ISPB:</label>
			<input id="nrispbif" name="nrispbif" type="text" readonly="readonly" class="clsCampos" value="<?php echo $nrispbif; ?>" />
			
			<label for="nrdocnpj" class="clsCampos">CNPJ:</label>
			<input name="nrdocnpj" type="text" id="nrdocnpj" readonly="readonly" class="clsCampos" value="<?php echo number_format(str_replace(",",".",$nrdocnpj),2,",","."); ?>" />
			
			<br style="clear:both"/>
			
			<label for="tpconta" class="clsCampos">Tipo de Conta:</label>
			<input id="tpconta" name="tpconta" type="text" class="clsCampos" value="Conta Corrente<?php echo $tpconta; ?>" />
			
			<label for="cdagectl" class="clsCampos">Agência:</label>
			<input type="text" id="cdagectl" name="cdagectl" readonly="readonly" class="clsCampos" value="<?php echo $cdagectl; ?>" />
			
			<label for="nrconta" class="clsCampos">Conta:</label>
			<input type="text" id="nrconta" name="nrconta" readonly="readonly" class="clsCampos" value="<?php echo $nrconta; ?>" />
	</fieldset>
	
	<fieldset style="padding: 5px">
		<legend>Status da Solicitação</legend>
			<label for="dscodigo" class="clsCampos">Situação:</label>
			<input type="text" id="dscodigo" name="dscodigo" readonly="readonly" class="clsCampos" value="<?php echo $dscodigo; ?>" />
			
			<br style="clear:both"/>
			
			<label for="dtsolicitacao" class="clsCampos">Data Solicitação:</label>
			<input type="text" id="dtsolicitacao" name="dtsolicitacao" readonly="readonly" class="clsCampos" value="<?php echo $dtsolicitacao; ?>" />
			
			<label for="dtretorno" class="clsCampos">Data Retorno:</label>
			<input type="text" id="dtretorno" name="dtretorno" readonly="readonly" class="clsCampos" value="<?php echo $dtretorno; ?>" />
			
			<br style="clear:both"/>
			
			<label for="dsmotivo" class="clsCampos">Motivo:</label>
			<input type="text" id="dsmotivo" name="dsmotivo" readonly="readonly" rows="2" class="clsCampos" value="<?php echo $dsmotivo; ?>" />
	</fieldset>
	
	</div>

</form>

<div id="divBotoes">	
        <input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="encerraRotina(true);return false;" />
		<input type="image" id="btSolicitar" src="<? echo $UrlImagens; ?>botoes/solicitar.gif" onClick="controlaOperacao('SO')" />
        <input type="image" id="btImprimirTermo" src="<? echo $UrlImagens; ?>botoes/imprimir_termo.gif" onClick="controlaOperacao('IMPRIMIR')" />
		<input type="image" id="btCancelar" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onclick="controlaOperacao('CANCELAR')">
</div>

<script type="text/javascript">
  controlaLayout('ENVIO_SOLICITACAO');

  // Esconde mensagem de aguardo
  hideMsgAguardo();

  // Bloqueia conteúdo que está átras do div da rotina
  blockBackground(parseInt($("#divRotina").css("z-index")));z
</script>