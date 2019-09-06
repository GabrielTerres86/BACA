<?php 
	//**********************************************************************************************//
	//*** Fonte: envio_solicitacao.php                                                           ***//
	//*** Autor: Anderson-Alan                                                                   ***//
	//*** Data : Setembro/2018                Última Alteração: 30/01/2019                       ***//
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

	$xmlResult = mensageria($xml, "ATENDA", "BUSCA_DADOS_RECEBE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);

	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','estadoInicial()', false);
	}

	$registro                       = $xmlObject->roottag->tags[0];
	$nrnu_portabilidade_r           = getByTagName($registro->tags,'nrnu_portabilidade');
	$dtsolicitacao_r                = getByTagName($registro->tags,'dtsolicitacao');
	$nrcnpj_empregador_r            = getByTagName($registro->tags,'nrcnpj_empregador');
	$dsnome_empregador_r            = getByTagName($registro->tags,'dsnome_empregador');
	$banco                          = getByTagName($registro->tags,'banco');
	$cdagencia_destinataria_r       = getByTagName($registro->tags,'cdagencia_destinataria');
	$nrdconta_destinataria_r        = getByTagName($registro->tags,'nrdconta_destinataria');	
	$cdsituacao 		            = getByTagName($registro->tags,'cdsituacao');
	$dssituacao                     = getByTagName($registro->tags,'dssituacao');
	$dtavaliacao                    = getByTagName($registro->tags,'dtavaliacao');
	$dsmotivo                       = getByTagName($registro->tags,'dsmotivo');
	$dsrowid                        = getByTagName($registro->tags,'dsrowid');
	$idsituacao_regularizacao       = getByTagName($registro->tags,'idsituacao_regularizacao');
	$tppessoa_empregador       		= getByTagName($registro->tags,'tppessoa_empregador');
	
	/***
	 ** Deve apresentar na tela os campos que estao gravados na ultima solicitacao de portabilidade:
     **
	 ** 1 ? A Solicitar [C]onsulta
	 ** 2 ? Solicitada  [C]onsulta
	 ** 3 ? Aprovada    [C]onsulta
	 ** 5 ? A Cancelar  [C]onsulta
	 **
	 ** 4 ? Reprovada   [A]lteracao
	 ** 6 ? Cancelada   [A]lteracao
     **
	 **      N/A        [I]nclusao
	***/
	$cddopcao 			= ( ( in_array($cdsituacao, array(1,2,3,5)) ) ? 'C' : ( ( in_array($cdsituacao, array(4,6)) ) ? 'A' : 'I' ) );
?>
<form action="" method="post" name="frmDadosDestinatario" id="frmDadosDestinatario" class="formulario">
	
	<div id="divDados" class="clsCampos">
        
        <fieldset style="padding: 5px">
            <legend>Portabilidade</legend>

            <label for="nrnu_portabilidade_r" class="clsCampos" style="width:90px">NU:</label>
            <input type="text" id="nrnu_portabilidade_r" name="nrnu_portabilidade_r" readonly="readonly" class="campo campoTelaSemBorda" value="<?php echo $nrnu_portabilidade_r; ?>" style="width:140px" />
            
            <label for="dtsolicitacao_r" class="clsCampos" style="width:170px">Data Solicita&ccedil;&atilde;o:</label>
            <input type="text" id="dtsolicitacao_r" name="dtsolicitacao_r" readonly="readonly" class="campo campoTelaSemBorda" value="<?php echo $dtsolicitacao_r; ?>" style="width:113px" />

			<br style="clear:both"/>

			<label for="dtsolicitacao_r" class="clsCampos" style="width:90px">Situa&ccedil;&atilde;o:</label>
            <input type="text" id="dtsolicitacao_r" name="dtsolicitacao_r" readonly="readonly" class="campo campoTelaSemBorda" value="<?=$dssituacao?>" style="width:140px" />

			<label for="dtsolicitacao_r" class="clsCampos" style="width:170px">Data Avalia&ccedil;&atilde;o:</label>
            <input type="text" id="dtsolicitacao_r" name="dtsolicitacao_r" readonly="readonly" class="campo campoTelaSemBorda" value="<?=$dtavaliacao?>" style="width:113px" />

			<br style="clear:both"/>
            
			<label for="dsmotivo" class="clsCampos" style="width:90px">Motivo(s):</label>
			<textarea id="dsmotivo" class="campoTelaSemBorda" readonly disabled style="width: 426px;height: 45px;margin-left: 3px;float: left;margin-top: 3px;"><?=utf8_decode($dsmotivo)?></textarea>
        </fieldset>

        <fieldset style="padding: 5px">
            <legend>Empregador</legend>
			
			<label style="width:90px" id="lbl_tppessoa_empregador" class="clsCampos">Tipo:</label>
			<input type="radio" style="margin-right: 5px" <?=($tppessoa_empregador == "1" ? "checked" : "")?> id="tppessoa_fisica" disabled readonly name="tppessoa_empregador" value="1"/> <label style="margin-right: 25px" for="tppessoa_fisica">F&iacute;sica</label>
			<input type="radio" style="margin-right: 5px" <?=($tppessoa_empregador == "2" ? "checked" : "")?> id="tppessoa_juridica" disabled readonly name="tppessoa_empregador" value="2"/> <label for="tppessoa_juridica">Jur&iacute;dica</label>

			<br style="clear:both"/>

            <label for="nrcnpj_empregador_r" class="clsCampos" style="width:90px"><?=($tppessoa_empregador == "1" ? "CPF" : "CNPJ")?>:</label>
            <input name="nrcnpj_empregador_r" type="text" id="nrcnpj_empregador_r" readonly="readonly" class="campo campoTelaSemBorda" value="<?php echo $nrcnpj_empregador_r; ?>" style="width:110px" />

            <label for="dsnome_empregador_r" class="clsCampos" style="width:65px">Nome:</label>
            <input id="dsnome_empregador_r" name="dsnome_empregador_r" readonly="readonly" type="text" class="campo campoTelaSemBorda" value="<?php echo $dsnome_empregador_r; ?>" style="width:250px" />
        </fieldset>

        <fieldset style="padding: 5px">
            <legend>Institui&ccedil;&atilde;o Destinat&aacute;ria</legend>
            <label for="banco" class="clsCampos" style="width:90px">Banco:</label>
            <input id="banco" name="banco" type="text" readonly="readonly" class="campo campoTelaSemBorda" value="<?php echo $banco; ?>" style="width:426px"/>
            
            <br style="clear:both"/>
            
            <label for="cdagencia_destinataria_r" class="clsCampos" style="width: 90px">Ag&ecirc;ncia:</label>
            <input type="text" id="cdagencia_destinataria_r" name="cdagencia_destinataria_r" readonly="readonly" class="campo campoTelaSemBorda" value="<?php echo $cdagencia_destinataria_r; ?>" style="width:45px" />
            
            <label for="nrdconta_destinataria_r" class="clsCampos" style="width: 303px">Conta:</label>
            <input type="text" id="nrdconta_destinataria_r" name="nrdconta_destinataria_r" readonly="readonly" class="campo campoTelaSemBorda" value="<?php echo $nrdconta_destinataria_r; ?>" style="width:75px" />
        </fieldset>
	
		<?php
			/*
			*** Busca dados da contestação
			*/
			
			$xml  = "<Root>";
			$xml .= " <Dados>";
			$xml .= "   <nrnuportabilidade>".$nrnu_portabilidade_r."</nrnuportabilidade>";
			$xml .= " </Dados>";
			$xml .= "</Root>";
			
			$xmlResult = mensageria($xml, "ATENDA", "BUSCA_DADOS_CONTESTACAO_RECEBE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
			$cdsituacaoContestacao = getByTagName($contestacao->tags,'cddominio');
		?>
		
		<fieldset>
			<legend>Status da Contesta&ccedil;&atilde;o</legend>
			<label style="width: 90px;" for="dssituacao" class="clsCampos">Situa&ccedil;&atilde;o:</label>
			<input style="width: 135px;" type="text" id="dssituacao" name="dssituacao" disabled readonly="readonly" class="campoTelaSemBorda" value="<?php echo $dssituacao; ?>" />

			<label style="width: 145px;" for="nr_identificador" class="clsCampos">Identificador:</label>
			<input style="width: 145px;" type="text" id="nr_identificador" name="nr_identificador" readonly="readonly" class="campoTelaSemBorda" value="<?php echo $identificador; ?>" />
			
			<br style="clear:both"/>
			
			<label style="width: 90px;" for="dtsolicita" class="clsCampos">Data Solicita&ccedil;&atilde;o:</label>
			<input style="width: 135px;" type="text" id="dtsolicita" name="dtsolicita" readonly="readonly" class="campoTelaSemBorda" value="<?php echo $dtsolicita; ?>" />
			
			<label style="width: 145px;" for="dtretorno" class="clsCampos">Data Retorno:</label>
			<input style="width: 145px;" type="text" id="dtretorno" name="dtretorno" readonly="readonly" class="campoTelaSemBorda" value="<?php echo $dtretorno; ?>" />
			
			<br style="clear:both"/>
			
			<label style="width: 90px;" for="dsmotivo" class="clsCampos">Motivo:</label>
			<textarea style="width: 428px;height: 45px;margin-left: 3px;float: left;" id="dsmotivo" class="campoTelaSemBorda" readonly disabled style="width: 513px;height: 60px;margin-right: 19px;"><?=$dsmotivo?></textarea>
			<input type="hidden" value="<?=$dsmotivo?>" id="dsmotivo_contestacao" name="dsmotivo_contestacao" />
			
			<br style="clear:both"/>
			
			<label style="width: 90px;margin-top: 3px;" for="dsretornno" class="clsCampos">Retorno:</label>
			<textarea style="width: 428px;height: 45px;margin-left: 3px;float: left;margin-top: 3px;" id="dsretornno" class="campoTelaSemBorda" readonly disabled style="width: 513px;height: 60px;margin-right: 19px;"><?=$dsretornno?></textarea>
		</fieldset>
		
		<?php
			/*
			*** Busca dados da regularização
			*/
			
			$xml  = "<Root>";
			$xml .= " <Dados>";
			$xml .= "   <nrnu_portabilidade>".$nrnu_portabilidade_r."</nrnu_portabilidade>";
			$xml .= " </Dados>";
			$xml .= "</Root>";
			
			$xmlResult = mensageria($xml, "ATENDA", "BUSCA_DADOS_REGULARIZACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObject = getObjectXML($xmlResult);
			
			if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
				$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
				exibirErro('error',$msgErro,'Alerta - Aimaro','acessaOpcaoAba(2,0,"0")', false);
			}
			
			$regularizacao = $xmlObject->roottag->tags[0];
			
			$dssituacao = getByTagName($regularizacao->tags,'dssituacao');
			$dsmotivo = getByTagName($regularizacao->tags,'dsmotivo');
			$dtregularizacao = getByTagName($regularizacao->tags,'dtregularizacao');
		?>
		
		<fieldset style="margin-top:10px">
			<legend>Status da Regulariza&ccedil;&atilde;o</legend>
			<label style="width: 90px;" for="dssituacao" class="clsCampos">Situa&ccedil;&atilde;o:</label>
			<input style="width: 135px;" type="text" id="dssituacao" name="dssituacao" disabled readonly="readonly" class="campoTelaSemBorda" value="<?=$dssituacao?>" />

			<label style="width: 145px;" for="dt_regularizacao" class="clsCampos">Data:</label>
			<input style="width: 145px;" type="text" id="dt_regularizacao" name="dt_regularizacao" readonly="readonly" class="campoTelaSemBorda" value="<?=$dtregularizacao?>" />
			
			<br style="clear:both"/>
			
			<label style="width: 90px;" for="dsmotivo" class="clsCampos">Motivo:</label>
			<textarea style="width: 428px;height: 45px;margin-left: 3px;float: left;" id="dsmotivo" class="campoTelaSemBorda" readonly disabled style="width: 513px;height: 60px;margin-right: 19px;"><?=$dsmotivo?></textarea>
		</fieldset>
	
	</div>

</form>

<div id="divBotoes">
	<a class="botao" id="btVoltar" href="#" onclick="encerraRotina(true);return false;">Voltar</a>
	
	<!-- Apenas situação de Contestação Pendente -->
	<a class="<?=(($cdsituacaoContestacao == 1) ? 'botao' : 'botaoDesativado')?>" id="btResponderContestacao" href="#" onclick="<?=(($cdsituacaoContestacao == 1) ? 'responderContestacao(\''.$dsrowid.'\', 2);' : '')?>return false;">Responder Contesta&ccedil;&atilde;o</a>
	
	<!-- Apenas situação de Aprovada ou Reprovada -->
	<a class="<?=(( ($cdsituacao == 2 || $cdsituacao == 3) && ($idsituacao_regularizacao != 1 && $idsituacao_regularizacao != 2) ) ? 'botao' : 'botaoDesativado')?>" id="btRegularizarContestacao" href="#" onclick="<?=(( ($cdsituacao == 2 || $cdsituacao == 3) && ($idsituacao_regularizacao != 1 && $idsituacao_regularizacao != 2) ) ? 'regularizarContestacao(\''.$dsrowid.'\', '.$cdsituacao.');' : '')?>return false;">Regularizar</a>
</div>

<script type="text/javascript">

	controlaLayout('<?php echo $cddopcao; ?>');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>