<?php
	/*!
	* FONTE        : buscar_socios.php
	* CRIAÇÃO      : Mateus Zimmermann - Mouts
	* DATA CRIAÇÃO : Maio/2018
	* OBJETIVO     : Rotina para realizar a busca dos socios
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
	
	$nrcpfcgc = isset($_POST["nrcpfcgc"]) ? $_POST["nrcpfcgc"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 30;
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 1;
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_REPEXT", "BUSCA_DADOS_HISTORICO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
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
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'input,select\',\'#divConteudo\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divConteudo\');',false);
	} 
		
	$registros = $xmlObj->roottag->tags[0]->tags;
	
?>

<table cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('Log Alterações') ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudo">
										<form id="formLogAlteracoes" class="formulario" onSubmit="return false;">
											<fieldset>
											<legend><? echo utf8ToHtml('Alterações') ?></legend>
											<div class="divRegistros">
												<? foreach($registros as $altera) { ?>
													<table>
														<tr>
															<td align="left"  style="padding-bottom: 2px; padding-top: 4px;"> 
																<label for="dtaltera" class="txtNormalBold">Data:</label>
																<input id ="dtaltera" name="dtaltera" type="text" value="<? echo getByTagName($altera->tags,'dtaltera'); ?>">
																<label for="nmoperad" class="txtNormalBold">Operador:</label>
																<input id ="nmoperad" name="nmoperad" type="text" value="<? echo getByTagName($altera->tags,'cdoperad'); ?>">
															</td>
														</tr>
														<tr>
															<td align="left"  style="padding-bottom: 2px; padding-top: 4px;"> 
																<label for="dsaltera" class="txtNormalBold">Dados Alterados/Incluidos:</label>
															</td>
														</tr>		
														<tr style="border-bottom: 2px solid #969FA9; background-color: #F4F3F0;">
															<td align="left" style="padding-bottom: 2px;">
																<textarea name="dsaltera" id="dsaltera" style="overflow-y: scroll; overflow-x: hidden; width: 685px; height: 100px;" readonly><?php echo trim(getByTagName($altera->tags,'dsalteracao')); ?></textarea>
															</td>
														</tr>
														<tr>
															<td height="1px"><hr></td>
														</tr>
													</table>
												<? } ?>
											</div>
											</fieldset>
											</form>

										<div id="divDadosSocio"></div>
										
										<div id="divBotoes" style="margin-bottom:10px">
											<a href="#" class="botao" id="btVoltar" onclick="fechaRotina( $('#divRotina')); return false;">Voltar</a>
										</div>
									
									</div>		
								</td>
							</tr>
						</table>			    
					</td> 
				</tr>
			</table>
		</td>
	</tr>
</table>

<script type="text/javascript">
	
	formataLogAlteracoes();
    	 
</script>