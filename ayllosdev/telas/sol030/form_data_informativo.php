<?php
    /*
     * FONTE        : form_importa_carga.php
     * CRIAÇÃO      : Lucas Lombardi
     * DATA CRIAÇÃO : 19/07/2016
     * OBJETIVO     : Formulario de Regras.
     * --------------
     * ALTERAÇÕES   : 
     * --------------
     */
	
    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');	
    require_once('../../class/xmlfile.php');
	
	$cddopcao   = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	
    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',true);
	}
	// Monta o xml de requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "TELA_SOL030", "BUSCA_DATA_INFORM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	$reg = $xmlObjeto->roottag->tags[0];
?>
<form id="frmDataInformativo" name="frmDataInformativo" class="formulario" onSubmit="return false;">
	
	<div style="margin-top:10px;"></div>
	<label for="dtapinco">Data Apresenta&ccedil;&atilde;o Informativo Conta Online:</label>
	<input type="text" id="dtapinco" name="dtapinco" value="<?php echo getByTagName($reg->tags,'dtinform'); ?>"/>
	
	<div id="divBotoes" class="rotulo-linha" style="margin-top:25px; margin-bottom :10px; text-align: center;">
		<a href="#" class="botao" id="btVoltar">Voltar</a>
		<a href="#" class="botao" id="btAlterar">Alterar</a>
	</div>

</form>