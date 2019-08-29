<?php
    /*
     * FONTE        : form_importa_carga.php
     * CRIAÇÃO      : Lucas Lombardi
     * DATA CRIAÇÃO : 19/07/2016
     * OBJETIVO     : Formulario de Regras.
     * --------------
     * ALTERAÇÕES   : 
     *
     * 000: [11/07/2017] Alteração no controla de apresentação do cargas bloqueadas na opção "A", Melhoria M441. ( Mateus Zimmermann/MoutS )
     * --------------
     */
	
    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');	
    require_once('../../class/xmlfile.php');
	
	$cddopcao   = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$iddcarga   = (isset($_POST['iddcarga'])) ? $_POST['iddcarga'] : 0 ;
  $flgbloqu   = (isset($_POST['flgbloqu'])) ? $_POST['flgbloqu'] : 2 ;
	
    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
	if(strtoupper($cddopcao) == 'A') {
	
		if($iddcarga == 0)
			exibirErro('error','Carga não encontrada.','Alerta - Ayllos','acessa_rotina();',true);
		
		// Monta o xml de requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";	
		$xml .= "  <iddcarga>".$iddcarga."</iddcarga>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		// Executa script para envio do XML e cria objeto para classe de tratamento de XML
		$xmlResult = mensageria($xml, "TELA_IMPPRE", "IMPPRE_BUSCA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);

		$carga = $xmlObjeto->roottag->tags[0];
	}
?>
<form id="frmImportaCarga" name="frmImportaCarga" class="formulario">
	<div style="margin-top:10px;"></div>
	<input type="hidden" id="hdIdcarga" name="hdIdcarga" value="<?php echo getByTagName($carga->tags,'idcarga'); ?>" />
	<label for="descricao">Descri&ccedil;&atilde;o:</label>
	<input type="text" id="descricao" name="descricao" maxlength="100" />
	
	<label for="final_vigencia">Final de Vig&ecirc;ncia:</label>
	<input type="text" id="final_vigencia" name="final_vigencia"/>
	
	<input type="checkbox" id="indeterminada" name="indeterminada" />
	<label for="indeterminada">Indeterminada</label>
	
	<label for="mensagem">Mensagem:&nbsp;</label>
	<textarea id="mensagem" name="mensagem" />
	
	<label for="nome_arquivo">Nome do Arquivo:</label>
	<input type="text" id="nome_arquivo" name="nome_arquivo" value="<?php echo date("Ymd"); ?>" maxlength="100" /><label style="margin-top: 4px;">&nbsp;.csv</label>

	<div id="divBotoes" class="rotulo-linha" style="margin-top:25px; margin-bottom :10px; text-align: center;">
		<a href="#" class="botao" id="btVoltar">Voltar</a>
		<a href="#" class="botao" id="btConcluir">Concluir</a>
	</div>

</form>
<script language="javascrip">
	glbDscarga			= '<?php echo getByTagName($carga->tags,'dscarga'); ?>';
	glbDtfinal_vigencia = '<?php echo getByTagName($carga->tags,'dtfinal_vigencia'); ?>';
	glbDsmensagem_aviso = '<?php echo preg_replace('/\r\n|\r|\n/','\n',getByTagName($carga->tags,'dsmensagem_aviso')); ?>';
	glbNmarquivo		= '<?php echo getByTagName($carga->tags,'nmarquivo'); ?>';
</script>