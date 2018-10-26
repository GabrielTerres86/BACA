<?php
	/*!
	* FONTE        : buscar_mensagens.php
	* CRIAÇÃO      : Mateus Zimmermann - Mouts
	* DATA CRIAÇÃO : Agosto/2018
	* OBJETIVO     : Rotina para realizar a busca das mensagens
	* --------------
	* ALTERAÇÕES   : 
	* -------------- 
	*/		
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	$cdfase   = isset($_POST["cdfase"])   ? $_POST["cdfase"]   : 0;
	$cdcooper = isset($_POST["cdcooper"]) ? $_POST["cdcooper"] : 0;
	$mensagem = isset($_POST["mensagem"]) ? $_POST["mensagem"] : 0;
	$valorini = isset($_POST["valorini"]) ? $_POST["valorini"] : 0;
	$valorfim = isset($_POST["valorfim"]) ? $_POST["valorfim"] : 0;
	$horarioini  = isset($_POST["horarioini"])  ? $_POST["horarioini"] : 0;
	$horariofim  = isset($_POST["horariofim"])  ? $_POST["horariofim"] : 0;

	$valorini = str_replace(',','.',str_replace('.','',$valorini));
	$valorfim = str_replace(',','.',str_replace('.','',$valorfim));
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdfase>"  .$cdfase.  "</cdfase>";
	$xml .= "   <cdcooper_filtro>".$cdcooper."</cdcooper_filtro>";
	$xml .= "   <mensagem>".$mensagem."</mensagem>";
	$xml .= "   <valorini>".$valorini."</valorini>";
	$xml .= "   <valorfim>".$valorfim."</valorfim>";
	$xml .= "   <horarioini>".$horarioini."</horarioini>";
	$xml .= "   <horariofim>".$horariofim."</horariofim>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_SPBMSG", "SPBMSG_BUSCA_MENSAGENS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','$(\'input,select\',\'#divConteudo\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divConteudo\');',false);
	}
		
	$mensagens	= $xmlObj->roottag->tags;

?>

<form id="frmMensagens" name="frmMensagens" class="formulario" style="display:none;">

	<fieldset style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<div class="divRegistros">		
			<table>
				<thead>
					<tr>
						<th></th>
						<th>Nr.Mens.</th>
						<th>Fase</th>
						<th>Horário</th>
						<th>Mensagem</th>
						<th>Cooperativa</th>
						<th>Conta</th>
						<th>Valor</th>
						<th>IF Destino</th>
						<th>Nr.Ctrl.IF</th>
						<th></th>
					</tr>
				</thead>
				<tbody>
					<? foreach( $mensagens as $mensagem ) {    
						$valor = str_replace('.','',getByTagName($mensagem->tags,'valor'));
						?>
						<tr>
							<td><input id="reprocessar" type="checkbox"></td>	
							<td><? echo getByTagName($mensagem->tags,'nrseq_mensagem'); ?> </td>
							<td style="width: 135px;"><? echo getByTagName($mensagem->tags,'nmfase'); ?> </td>
							<td><? echo getByTagName($mensagem->tags,'dhmensagem'); ?> </td>
							<td><? echo getByTagName($mensagem->tags,'nmmensagem'); ?> </td>
							<td><? echo getByTagName($mensagem->tags,'nmrescop'); ?> </td>
							<td><? echo getByTagName($mensagem->tags,'nrdconta'); ?> </td>
							<td><span><? echo $valor; ?></span>
									  <? echo formataNumericos('zzz.zzz.zz9,99',$valor,'.,'); ?> </td>
							<td style="width: 125px;"><? echo getByTagName($mensagem->tags,'ifdestino'); ?> </td>
							<td><? echo getByTagName($mensagem->tags,'nrcontrole_if'); ?> </td>
							<td><span id="dsxml_completo" style="display: none"><? echo getByTagName($mensagem->tags,'dsxml_completo'); ?></span><a href="#" class="botao" id="btMostrarXML" onClick="mostrarXMLCompleto(this);">XML</a></td>
							
							<input type="hidden" id="nrseq_mensagem_xml" name="nrseq_mensagem_xml" value="<? echo getByTagName($mensagem->tags,'nrseq_mensagem_xml'); ?>" />
							<input type="hidden" id="cdcooper" name="cdcooper" value="<? echo getByTagName($mensagem->tags,'cdcooper'); ?>" />
							<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($mensagem->tags,'nrdconta'); ?>" />
							
						</tr>	
					<? } ?>
				</tbody>	
			</table>
		</div>
		<? if(count($mensagens)){ ?>
			<input id="marcarDesmarcar" type="checkbox" onchange="marcarDesmarcarTodas(this);">
			<label for="marcarDesmarcar" id="lblMarcarDesmarcar" >Marcar/Desmarcar Todas</label>
		<? } ?>
	</fieldset>
</form>

<div id="divBotoesMensagens" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
	
	<a href="#" class="botao" id="btVoltar" onClick="reprocessarMensagens(); return false;">Processar Reenvio</a>
	
</div>

<script type="text/javascript">
	
	formataTabelaMensagens();	
    	 
</script>