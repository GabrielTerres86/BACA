<?php 
	//**********************************************************************************************//
	//*** Fonte: envio_solicitacao.php                                                           ***//
	//*** Autor: Anderson-Alan                                                                   ***//
	//*** Data : Setembro/2018                Última Alteração: 24/09/2018                       ***//
	//***                                                                                        ***//
	//*** Objetivo  : Mostrar opcao Principal da rotina de Portabilidade Salarial da tela ATENDA ***//
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

	$xmlResult = mensageria($xml, "ATENDA", "BUSCA_DADOS_ENVIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);

	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','acessaOpcaoAba(2,0,"0")', false);
	}

	$registro           = $xmlObject->roottag->tags[0];
	if (!empty($registro->name) && strtoupper($registro->name) == "INPESSOA_INVALIDO" && $registro->cdata == "1") {
		exibirErro('error','Portabilidade indispon&iacute;vel para Pessoa Jur&iacute;dica.','Alerta - Aimaro','encerraRotina(true)', false);
		exit();
	}
	
	$nrcpfcgc            = getByTagName($registro->tags,'nrcpfcgc');
	$nmprimtl            = getByTagName($registro->tags,'nmprimtl');
	$nrtelefo            = getByTagName($registro->tags,'nrtelefo');
	$dsdemail            = getByTagName($registro->tags,'dsdemail');
	$cdbanco_folha       = getByTagName($registro->tags,'cdbanco_folha');
	$nrispb_banco_folha  = getByTagName($registro->tags,'nrispb_banco_folha');
	$nrcnpj_banco_folha  = getByTagName($registro->tags,'nrcnpj_banco_folha');
	$nrdocnpj_emp        = getByTagName($registro->tags,'nrdocnpj_emp');
	$nmprimtl_emp        = getByTagName($registro->tags,'nmprimtl_emp');
	$nrispbif            = getByTagName($registro->tags,'nrispbif');
	$nrdocnpj            = getByTagName($registro->tags,'nrdocnpj');
	$cdagectl            = getByTagName($registro->tags,'cdagectl');
	$nrdconta_formatada  = getByTagName($registro->tags,'nrdconta');
	$dssituacao          = getByTagName($registro->tags,'dssituacao');
	$nrnu_portabilidade  = getByTagName($registro->tags,'nrnu_portabilidade');
	$dtsolicita          = getByTagName($registro->tags,'dtsolicita');
	$dtretorno           = getByTagName($registro->tags,'dtretorno');
	$dsmotivo            = getByTagName($registro->tags,'dsmotivo');
	$cdsituacao 		 = getByTagName($registro->tags,'cdsituacao');
	$dsrowid             = getByTagName($registro->tags,'dsrowid');
	$nrsolicitacao       = getByTagName($registro->tags,'nrsolicitacao');
	$tppessoa_empregador = getByTagName($registro->tags,'tppessoa_empregador');

	/***
	 ** Deve apresentar na tela os campos que estao gravados na ultima solicitacao de portabilidade:
     **
	 ** 1 ? A Solicitar            [C]onsulta
	 ** 2 ? Solicitada             [C]onsulta
	 ** 3 ? Aprovada               [C]onsulta
	 ** 5 ? A Cancelar             [C]onsulta
	 **
	 ** 8 ? Rejeitada              [A]lteracao 
	 ** 9 ? Cancelamento Rejeitado [A]lteracao
     **
	 ** 4 ? Reprovada              [A]lteracao
	 ** 6 ? Cancelada              [A]lteracao
	 **
	 **      N/A        [I]nclusao
	***/
	$cddopcao 			= ( ( in_array($cdsituacao, array(1,2,3,5,6,9)) ) ? 'C' : ( ( in_array($cdsituacao, array(4,8)) ) ? 'A' : 'I' ) );
	
?>
<form action="<?php echo $UrlSite; ?>telas/atenda/portabilidade/impressao_termo.php" name="frmTermo" class="formulario" id="frmTermo" method="post">
    <input type="hidden" id="dsrowid" name="dsrowid" value="">
    <input type="hidden" id="sidlogin" name="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>

<form action="" method="post" name="frmDadosPortabilidade" id="frmDadosPortabilidade" class="formulario">
	
	<div id="divDados" class="clsCampos">
	
	<fieldset style="padding: 5px">
		<legend>Cooperado</legend>
			<label for="nrcpfcgc" class="clsCampos">CPF:</label>
			<input name="nrcpfcgc" type="text" id="nrcpfcgc" readonly="readonly" class="clsCampos" value="<?php echo $nrcpfcgc; ?>" />
			
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
		<select id="dsdbanco" name="dsdbanco" class="campo">
			<option value="" <?php echo ($inmotcan == 0 ? 'selected' : ''); ?>></option>
			<?php
			$xml  = "<Root>";
			$xml .= " <Dados/>";
			$xml .= "</Root>";

			$xmlResult = mensageria($xml, "ATENDA", "BUSCA_BANCOS_FOLHA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObject = getObjectXML($xmlResult);

			if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
				$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
				exibirErro('error',$msgErro,'Alerta - Aimaro','estadoInicial()', false);
			}

			$registros = $xmlObject->roottag->tags;

			foreach ($registros as $registro) {
				$dsdbanco = getByTagName($registro->tags,'dsdbanco');
				$nrispbif_s = getByTagName($registro->tags,'nrispbif');
				$nrcnpjif = getByTagName($registro->tags,'nrcnpjif');
				$cdbccxlt = getByTagName($registro->tags,'cdbccxlt');
				
				$selected = ( ( $cdbanco_folha == $cdbccxlt ) ? 'selected' : '' );

				echo '<option '.$selected.' data-nrcnpjif="'.$nrcnpjif.'" data-nrispbif="'.$nrispbif_s.'" value="'.$cdbccxlt.'">'.$dsdbanco.'</option>';
			}
			?>
		</select>
		
		<br style="clear:both"/>
		
		<label for="nrispbif_banco_folha" class="clsCampos">ISPB:</label>
		<input id="nrispbif_banco_folha" name="nrispbif_banco_folha" readonly="readonly" type="text" class="campo" value="<?php echo $nrispb_banco_folha; ?>" />
		
		<label for="nrcnpjif" class="clsCampos">CNPJ:</label>
		<input name="nrcnpjif" type="text" id="nrcnpjif" readonly="readonly" class="campo" value="<?php echo $nrcnpj_banco_folha; ?>" />
	</fieldset>
	
	<fieldset>
		<legend>Empregador</legend>
		
		<label id="lbl_tppessoa_empregador" class="clsCampos">Tipo:</label>
		<input type="radio" style="margin-right: 5px" <?=($tppessoa_empregador == "1" ? "checked" : "")?> id="tppessoa_fisica" disabled readonly name="tppessoa_empregador" value="1"/> <label style="margin-right: 25px" for="tppessoa_fisica">F&iacute;sica</label>
		<input type="radio" style="margin-right: 5px" <?=($tppessoa_empregador == "2" ? "checked" : "")?> id="tppessoa_juridica" disabled readonly name="tppessoa_empregador" value="2"/> <label for="tppessoa_juridica">J&uacute;ridica</label>
		
		<br style="clear:both"/>

		<label for="nrdocnpj_emp" class="clsCampos"><?=($tppessoa_empregador == "1" ? "CPF" : "CNPJ")?>:</label>
		<input name="nrdocnpj_emp" type="text" id="nrdocnpj_emp" readonly="readonly" class="campo" value="<?php echo $nrdocnpj_emp; ?>" />

		<label for="nmprimtl_emp" class="clsCampos">Nome:</label>
		<input id="nmprimtl_emp" name="nmprimtl_emp" readonly="readonly" type="text" class="campo" value="<?php echo $nmprimtl_emp; ?>" />
	</fieldset>
	
	<fieldset style="padding: 5px">
		<legend>Institui&ccedil;&atilde;o Destinat&aacute;ria</legend>
		<label for="nrispbif" class="clsCampos">ISPB:</label>
		<input id="nrispbif" name="nrispbif" type="text" readonly="readonly" class="campo" value="<?php echo $nrispbif; ?>" />
		
		<label for="nrdocnpj" class="clsCampos">CNPJ:</label>
		<input name="nrdocnpj" type="text" id="nrdocnpj" readonly="readonly" class="campo" value="<?php echo $nrdocnpj; ?>" />
		
		<br style="clear:both"/>
		
		<label for="cdtipcta" class="clsCampos" style="width: 98px;">Tipo de Conta:</label>
		<input type="text" id="cdtipcta" name="cdtipcta" style="width: 112px;" readonly="readonly" class="campo" value="Conta Corrente" />
		
		<label for="cdagectl" class="clsCampos" style="width: 70px;">Ag&ecirc;ncia:</label>
		<input type="text" id="cdagectl" name="cdagectl" style="width: 45px;" readonly="readonly" class="campo" value="<?php echo $cdagectl; ?>" />
		
		<label for="nrdconta" class="clsCampos">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" readonly="readonly" class="campo" value="<?php echo $nrdconta_formatada; ?>" />
	</fieldset>
	
	<fieldset style="padding: 5px">
		<legend>Status da Solicita&ccedil;&atilde;o</legend>
		<label for="dssituacao" class="clsCampos">Situa&ccedil;&atilde;o:</label>
		<input type="text" id="dssituacao" name="dssituacao" readonly="readonly" class="campo" value="<?php echo $dssituacao; ?>" />

		<label for="nrnu_portabilidade" class="clsCampos">NU:</label>
		<input type="text" id="nrnu_portabilidade" name="nrnu_portabilidade" readonly="readonly" class="campo" value="<?php echo $nrnu_portabilidade; ?>" />
		
		<br style="clear:both"/>
		
		<label for="dtsolicita" class="clsCampos">Data Solicita&ccedil;&atilde;o:</label>
		<input type="text" id="dtsolicita" name="dtsolicita" readonly="readonly" class="campo" value="<?php echo $dtsolicita; ?>" />
		
		<label for="dtretorno" class="clsCampos">Data Retorno:</label>
		<input type="text" id="dtretorno" name="dtretorno" readonly="readonly" class="campo" value="<?php echo $dtretorno; ?>" />
		
		<br style="clear:both"/>
		
		<label for="dsmotivo" class="clsCampos">Motivo(s):</label>
		<textarea id="dsmotivo" class="campoTelaSemBorda" readonly disabled style="width: 513px;height: 60px;margin-right: 18px;"><?=utf8_decode($dsmotivo)?></textarea>
	</fieldset>
	
	<?php
		/*
		*** Busca dados da contestação
		*/
		
		$xml  = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "   <nrsolicitacao>".$nrsolicitacao."</nrsolicitacao>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "ATENDA", "BUSCA_DADOS_CONTESTACAO_ENVIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObject = getObjectXML($xmlResult);
		
		if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
			$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',$msgErro,'Alerta - Aimaro','acessaOpcaoAba(2,0,"0")', false);
		}
		
		$contestacao = $xmlObject->roottag->tags[0];
		
		$dssituacao = getByTagName($contestacao->tags,'dssituacao');
		$identificador = getByTagName($contestacao->tags,'identificador');
		$dtsolicita = getByTagName($contestacao->tags,'dtsolicita');
		$dtretorno = getByTagName($contestacao->tags,'dtretorno');
		$dsmotivo = getByTagName($contestacao->tags,'dsmotivo');
		$dsretornno = getByTagName($contestacao->tags,'dsretorno');
		$cddominio = getByTagName($contestacao->tags,'cddominio');
	?>
	
	<fieldset style="padding: 5px">
		<legend>Status da Contesta&ccedil;&atilde;o</legend>
		<label for="dssituacao" class="clsCampos">Situa&ccedil;&atilde;o:</label>
		<input type="text" id="dssituacao" name="dssituacao" readonly="readonly" class="campo" value="<?php echo $dssituacao; ?>" />

		<label for="nr_identificador" class="clsCampos">Identificador:</label>
		<input type="text" id="nr_identificador" name="nr_identificador" readonly="readonly" class="campo" value="<?php echo $identificador; ?>" />
		
		<br style="clear:both"/>
		
		<label for="dtsolicita" class="clsCampos">Data Solicita&ccedil;&atilde;o:</label>
		<input type="text" id="dtsolicita" name="dtsolicita" readonly="readonly" class="campo" value="<?php echo $dtsolicita; ?>" />
		
		<label for="dtretorno" class="clsCampos">Data Retorno:</label>
		<input type="text" id="dtretorno" name="dtretorno" readonly="readonly" class="campo" value="<?php echo $dtretorno; ?>" />
		
		<br style="clear:both"/>
		
		<label for="dsmotivo" class="clsCampos">Motivo:</label>
		<textarea id="dsmotivo" class="campoTelaSemBorda" readonly disabled style="width: 416;height: 60px;margin-right: 18px;"><?=$dsmotivo?></textarea>
		
		<label for="dsretornno" class="clsCampos">Retorno:</label>
		<textarea id="dsretornno" class="campoTelaSemBorda" readonly disabled style="width: 416px;height: 60px;margin-right: 18px;margin-top:5px;"><?=utf8_decode($dsretornno)?></textarea>
	</fieldset>
	
	</div>

</form>

<div id="divBotoes">
	<a class="botao" id="btVoltar" href="#" onclick="encerraRotina(true);return false;">Voltar</a>

	<?php if ($cddopcao == 'A' || $cddopcao == 'I') { ?>
	<a class="botao"           id="btSolicitar"     href="#" onclick="controlaOperacao('S')">Solicitar Portabilidade</a>
	<br />
	<a style="margin-top: 5px;" class="botaoDesativado" id="btImprimirTermo" href="#" onclick="return false;">Imprimir Termo</a>
	<?php } else { ?>
	<a class="botaoDesativado" id="btSolicitar"     href="#" onclick="return false;">Solicitar Portabilidade</a>
	<br />
	<a style="margin-top: 5px;" class="botao"           id="btImprimirTermo" href="#" onclick="imprimirTermoAdesao('<?php echo $dsrowid; ?>')">Imprimir Termo</a>
	<?php } ?>

	<?php if (in_array($cdsituacao, array(1,3,9)) || ($cdsituacao == 2 && trim($nrnu_portabilidade) != "")) { ?>
	<a style="margin-top: 5px;" class="botao" id="btCancelar" href="#" onclick="controlaOperacao('E')">Cancelar Portabilidade</a>
	<?php } else { ?>
	<a style="margin-top: 5px;" class="botaoDesativado" id="btCancelar" href="#" onclick="return false;">Cancelar Portabilidade</a>
	<?php } ?>
	
	<a style="margin-top: 5px;" class="<?=( ($cddominio == 1 || $cddominio == 2) || ($cdsituacao != 3) ? 'botaoDesativado' : 'botao')?>" id="botaoContestarPortabilidade" onclick="<?=(($cddominio == 1 || $cddominio == 2) || ($cdsituacao != 3) ? '' : 'controlaOperacao(\'CP\');')?>return false;" href="#">Contestar</a>

	
</div>

<script type="text/javascript">

	controlaLayout('<?php echo $cddopcao; ?>');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está atrás do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>