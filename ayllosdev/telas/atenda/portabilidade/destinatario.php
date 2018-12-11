<?php 
	//**********************************************************************************************//
	//*** Fonte: envio_solicitacao.php                                                           ***//
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

            <label for="nrnu_portabilidade_r" class="clsCampos" style="width:85px">NU:</label>
            <input type="text" id="nrnu_portabilidade_r" name="nrnu_portabilidade_r" readonly="readonly" class="campo campoTelaSemBorda" value="<?php echo $nrnu_portabilidade_r; ?>" style="width:140px" />
            
            <label for="dtsolicitacao_r" class="clsCampos" style="width:170px">Data Solicita&ccedil;&atilde;o:</label>
            <input type="text" id="dtsolicitacao_r" name="dtsolicitacao_r" readonly="readonly" class="campo campoTelaSemBorda" value="<?php echo $dtsolicitacao_r; ?>" style="width:113px" />

			<br style="clear:both"/>

			<label for="dtsolicitacao_r" class="clsCampos" style="width:85px">Situa&ccedil;&atilde;o:</label>
            <input type="text" id="dtsolicitacao_r" name="dtsolicitacao_r" readonly="readonly" class="campo campoTelaSemBorda" value="<?=$dssituacao?>" style="width:140px" />

			<label for="dtsolicitacao_r" class="clsCampos" style="width:170px">Data Avalia&ccedil;&atilde;o:</label>
            <input type="text" id="dtsolicitacao_r" name="dtsolicitacao_r" readonly="readonly" class="campo campoTelaSemBorda" value="<?=$dtavaliacao?>" style="width:113px" />

			<br style="clear:both"/>
            
			<label for="dsmotivo" class="clsCampos" style="width:85px">Motivo(s):</label>
			<textarea id="dsmotivo" class="campoTelaSemBorda" readonly disabled style="width: 425px;height: 60px;margin-right: 19px;"><?=utf8_decode($dsmotivo)?></textarea>
        </fieldset>

        <fieldset>
            <legend>Empregador</legend>
            <label for="nrcnpj_empregador_r" class="clsCampos" style="width:85px">CNPJ:</label>
            <input name="nrcnpj_empregador_r" type="text" id="nrcnpj_empregador_r" readonly="readonly" class="campo campoTelaSemBorda" value="<?php echo $nrcnpj_empregador_r; ?>" style="width:110px" />

            <label for="dsnome_empregador_r" class="clsCampos" style="width:65px">Nome:</label>
            <input id="dsnome_empregador_r" name="dsnome_empregador_r" readonly="readonly" type="text" class="campo campoTelaSemBorda" value="<?php echo $dsnome_empregador_r; ?>" style="width:250px" />
        </fieldset>

        <fieldset style="padding: 5px">
            <legend>Institui&ccedil;&atilde;o Destinat&aacute;ria</legend>
            <label for="banco" class="clsCampos" style="width:85px">Banco:</label>
            <input id="banco" name="banco" type="text" readonly="readonly" class="campo campoTelaSemBorda" value="<?php echo $banco; ?>" style="width:278px"/>
            
            <br style="clear:both"/>
            
            <label for="cdagencia_destinataria_r" class="clsCampos" style="width:85px">Ag&ecirc;ncia:</label>
            <input type="text" id="cdagencia_destinataria_r" name="cdagencia_destinataria_r" readonly="readonly" class="campo campoTelaSemBorda" value="<?php echo $cdagencia_destinataria_r; ?>" style="width:45px" />
            
            <label for="nrdconta_destinataria_r" class="clsCampos" style="width:60px">Conta:</label>
            <input type="text" id="nrdconta_destinataria_r" name="nrdconta_destinataria_r" readonly="readonly" class="campo campoTelaSemBorda" value="<?php echo $nrdconta_destinataria_r; ?>" style="width:75px" />
        </fieldset>
	
	</div>

</form>

<div id="divBotoes">
	<a class="botao" id="btVoltar" href="#" onclick="encerraRotina(true);return false;">Voltar</a>
</div>

<script type="text/javascript">

	controlaLayout('<?php echo $cddopcao; ?>');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>