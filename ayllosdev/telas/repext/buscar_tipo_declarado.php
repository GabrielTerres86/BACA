<?php
	/*!
	* FONTE        : buscar_tipo_declarado.php
	* CRIAÇÃO      : Mateus Zimmermann - Mouts
	* DATA CRIAÇÃO : Abril/2018
	* OBJETIVO     : Rotina para realizar a busca dos tipos declarado
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

	$nrregist       = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
	$nriniseq       = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	$idtipo_dominio = 'D'; // declarado
	$insituacao     = 'T'; // todos

	//Validar permissão de consulta do usuário
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'D', false)) <> "") {
		exibirErro("error",$msgError,"Alerta - Ayllos",'estadoInicial();', false);
	}

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <idtipo_dominio>".$idtipo_dominio."</idtipo_dominio>";
	$xml .= "   <cdtipo_dominio></cdtipo_dominio>";
	$xml .= "   <insituacao>"    .$insituacao.    "</insituacao>";
	$xml .= "   <nrregist>"      .$nrregist.      "</nrregist>";
	$xml .= "   <nriniseq>"      .$nriniseq.      "</nriniseq>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_REPEXT", "BUSCA_DOMINIO_TIPO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	$xmlObj = getObjectXML($xmlResult);

	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'inputtt,select\',\'#divConteudo\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divConteudo\');',false);
	} 
		
	$dados	  = $xmlObj->roottag->tags[0]->tags;	
	$qtregist = $xmlObj->roottag->tags[0]->attributes['QTREGIST'];
	?>

	<form id="frmTipoDeclarado" name="frmTipoDeclarado" class="formulario">

		<fieldset id="fsetTipoDeclarado" name="fsetTipoDeclarado" style="padding:0px; margin:0px; padding-bottom:10px;">
			
			<div class="divRegistros">		
				<table>
					<thead>
						<tr>
							<th><? echo utf8ToHtml('Código'); ?></th>
							<th>Tipo Declarado</th>
							<th><? echo utf8ToHtml('Proprietário') ?></th>
							<th><? echo utf8ToHtml('Situação') ?></th>
						</tr>
					</thead>
					<tbody>
						<? foreach( $dados as $dado ) {    ?>
							<tr>	
								<td><? echo getByTagName($dado->tags,'cdtipo_dominio'); ?></td>
								<td><? echo stringTabela(getByTagName($dado->tags,'dstipo_dominio'), 22, 'maiuscula'); ?></td>
								<td><? echo getByTagName($dado->tags,'dsexige_proprietario'); ?></td>
								<td><? echo getByTagName($dado->tags,'dssituacao'); ?></td>
								
								<input type="hidden" id="cdtipo_dominio" name="cdtipo_dominio" value="<? echo getByTagName($dado->tags,'cdtipo_dominio'); ?>" />
								<input type="hidden" id="dstipo_dominio" name="dstipo_dominio" value="<? echo getByTagName($dado->tags,'dstipo_dominio'); ?>" />
								<input type="hidden" id="insituacao" name="insituacao" value="<? echo getByTagName($dado->tags,'insituacao'); ?>" />
								<input type="hidden" id="inexige_proprietario" name="inexige_proprietario" value="<? echo getByTagName($dado->tags,'inexige_proprietario'); ?>" />
							</tr>	
						<? } ?>
					</tbody>	
				</table>
			</div>
			<div id="divRegistrosRodape" class="divRegistrosRodape">
				<table>	
					<tr>
						<td>
							<? if (isset($qtregist) and $qtregist == 0){ $nriniseq = 0;} ?>
							<? if ($nriniseq > 1){ ?>
								   <a class="paginacaoAnt"><<< Anterior</a>
							<? }else{ ?>
									&nbsp;
							<? } ?>
						</td>
						<td>
							<? if (isset($nriniseq)) { ?>
								   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
								<? } ?>
						</td>
						<td>
							<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
								  <a class="paginacaoProx">Pr&oacute;ximo >>></a>
							<? }else{ ?>
									&nbsp;
							<? } ?>
						</td>
					</tr>
				</table>
			</div>
		</fieldset>
	</form>

	<div id="divBotoes" style='text-align:center; margin-bottom: 10px; margin-top: 10px;' >

		<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1'); return false;">Voltar</a>
		<a href="#" class="botao" id="btIncluir" onClick="mostraFormTipoDeclarado('I'); return false;">Incluir</a>
		<a href="#" class="botao" id="btAlterar" onClick="mostraFormTipoDeclarado('A'); return false;">Alterar</a>

	</div>

	<script type="text/javascript">
		
		$('a.paginacaoAnt').unbind('click').bind('click', function() {

			buscarDadosCompliance(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

		});
		
		$('a.paginacaoProx').unbind('click').bind('click', function() {
			
			buscarDadosCompliance(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
			
		});	
		
		formataTabelaTipoDeclarado();	
	    	 
	</script>