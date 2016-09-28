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
	$xml .= " <Dados/>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "TELA_SOL030", "BUSCA_CALC_SOBRAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	$reg = $xmlObjeto->roottag->tags[0];
?>
<form id="frmCalculoSobras" name="frmCalculoSobras" class="formulario">
	<div style="margin-top:10px;"></div>
	<input type="hidden" id="ininccmi" name="ininccmi" value="<?php echo getByTagName($reg->tags,'ininccmi'); ?>" />
	
	<label for="increret">Cr&eacute;dito de retorno sobre juros pagos em <?echo getByTagName($reg->tags,'dtanoret'); ?>:&nbsp;&nbsp;</label>
	<select id="increret" name="increret">
		<option value="1" <?php echo getByTagName($reg->tags,'increret') == 1 ? 'SELECTED' : ''; ?> >Sim</option>
		<option value="0" <?php echo getByTagName($reg->tags,'increret') == 0 ? 'SELECTED' : ''; ?> >Não</option>
	</select>
	
	<label for="indeschq">Considerar juros de descontos de cheques:&nbsp;&nbsp;</label>
	<select id="indeschq" name="indeschq">
		<option value="1" <?php echo getByTagName($reg->tags,'indeschq') == 1 ? 'SELECTED' : ''; ?> >Sim</option>
		<option value="0" <?php echo getByTagName($reg->tags,'indeschq') == 0 ? 'SELECTED' : ''; ?> >Não</option>
	</select>
	
	<label for="indestit">Considerar juros de descontos de títulos:&nbsp;&nbsp;</label>
	<select id="indestit" name="indestit">
		<option value="1" <?php echo getByTagName($reg->tags,'indestit') == 1 ? 'SELECTED' : ''; ?> >Sim</option>
		<option value="0" <?php echo getByTagName($reg->tags,'indestit') == 0 ? 'SELECTED' : ''; ?> >Não</option>
	</select>
	
	<label for="indemiti">Considerar demitidos:&nbsp;&nbsp;</label>
	<select id="indemiti" name="indemiti">
		<option value="1" <?php echo getByTagName($reg->tags,'indemiti') == 1 ? 'SELECTED' : ''; ?> >Sim</option>
		<option value="0" <?php echo getByTagName($reg->tags,'indemiti') == 0 ? 'SELECTED' : ''; ?> >Não</option>
	</select>
	
	<label for="unsobdep">Unificar Sobras S/ Dep&oacute;sitos:&nbsp;&nbsp;</label>
	<select id="unsobdep" name="unsobdep">
		<option value="1" <?php echo getByTagName($reg->tags,'unsobdep') == 1 ? 'SELECTED' : ''; ?> >Sim</option>
		<option value="0" <?php echo getByTagName($reg->tags,'unsobdep') == 0 ? 'SELECTED' : ''; ?> >Não</option>
	</select>
	
	
	<label style="margin-top:20px;" for="txretorn">Percentual de retorno sobre juros pagos:&nbsp;&nbsp;</label>
	<input style="margin-top:20px;" type="text" id="txretorn" name="txretorn" value="<?php echo getByTagName($reg->tags,'txretorn'); ?>" />
	<label style="margin-top:20px;">&nbsp;%</label>
	
	<label for="txjurapl">Percentual de retorno sobre rendimentos pagos:&nbsp;&nbsp;</label>
	<input type="text" id="txjurapl" name="txjurapl" value="<?php echo getByTagName($reg->tags,'txjurapl'); ?>" />
	<label>&nbsp;%</label>
	
	<label for="txjursdm">Percentual de retorno sobre saldo m&eacute;dio de C/C:&nbsp;&nbsp;</label>
	<input type="text" id="txjursdm" name="txjursdm" value="<?php echo getByTagName($reg->tags,'txjursdm'); ?>" />
	<label>&nbsp;%</label>
	
	<label for="txjurtar">Percentual de retorno sobre tarifas:&nbsp;&nbsp;</label>
	<input type="text" id="txjurtar" name="txjurtar" value="<?php echo getByTagName($reg->tags,'txjurtar'); ?>" />
	<label>&nbsp;%</label>
	
	<label for="txreauat">Percentual de retorno sobre Autoatendimento:&nbsp;&nbsp;</label>
	<input type="text" id="txreauat" name="txreauat" value="<?php echo getByTagName($reg->tags,'txreauat'); ?>" />
	<label>&nbsp;%</label>
	
	<label for="txjurcap">Percentual de juros ao capital:&nbsp;&nbsp;</label>
	<input type="text" id="txjurcap" name="txjurcap" value="<?php echo getByTagName($reg->tags,'txjurcap'); ?>" />
	<label>&nbsp;%</label>
	
	<label for="inpredef">Tipo de c&aacute;lculo:&nbsp;&nbsp;</label>
	<select id="inpredef" name="inpredef">
		<option value="0" <?php echo getByTagName($reg->tags,'inpredef') == 0 ? 'SELECTED' : ''; ?> >Pr&eacute;vio</option>
		<option value="1" <?php echo getByTagName($reg->tags,'inpredef') == 1 ? 'SELECTED' : ''; ?> >Definitivo</option>
	</select>
	
	<label style="width:420px; margin-top:20px;">Cotas &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; C/C </label>
	
	<label for="dssopfco">Distribuição das Sobras PF:&nbsp;&nbsp;</label>
	<input type="text" id="dssopfco" name="dssopfco" value="<?php echo getByTagName($reg->tags,'dssopfco'); ?>" />
	<label>&nbsp;%&nbsp;</label>
	<input type="text" id="dssopfcc" name="dssopfcc" />
	<label>&nbsp;%&nbsp;</label>
	
	<label for="dssopjco">Distribuição das Sobras PJ:&nbsp;&nbsp;</label>
	<input type="text" id="dssopjco" name="dssopjco" value="<?php echo getByTagName($reg->tags,'dssopjco'); ?>" />
	<label>&nbsp;%&nbsp;</label>
	<input type="text" id="dssopjcc" name="dssopjcc" />
	<label>&nbsp;%&nbsp;</label>
	
	
	<div id="divBotoes" class="rotulo-linha" style="margin-top:25px; margin-bottom :10px; text-align: center;">
		<a href="#" class="botao" id="btVoltar">Voltar</a>
		<a href="#" class="botao" id="btAlterar">Alterar</a>
	</div>

</form>