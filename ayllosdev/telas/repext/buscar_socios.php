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
	$nmpessoa = isset($_POST["nmpessoa"]) ? $_POST["nmpessoa"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_REPEXT", "BUSCA_DADOS_SOCIOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
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
		
	$dados	  = $xmlObj->roottag->tags[0]->tags;	
	$qtregist = $xmlObj->roottag->tags[0]->attributes['QTREGIST'];
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('Sócios') ?></td>
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
										<form id="frmSocios" name="frmSocios" class="formulario" style="display:none;">
											<fieldset id="fsetFiltro" name="fsetFiltro">
												
												<label for="nrcpfcgc">Cooperado:</label>
										        <input name="nrcpfcgc" id="nrcpfcgc" type="text" value="<? echo $nrcpfcgc; ?>" />
										        <input name="nmpessoa" id="nmpessoa" type="text" value="<? echo $nmpessoa; ?>" />

											</fieldset>
											<fieldset id="fsetSocios" name="fsetSocios" style="padding:0px; margin:0px; padding-bottom:10px;">
												<div class="divRegistros">		
													<table>
														<thead>
															<tr>
																<th><? echo utf8ToHtml('Sócios') ?></th>
																<th>CPF</th>
																<th><? echo utf8ToHtml('Situação') ?></th>
																<th><? echo utf8ToHtml('Reportável') ?></th>
																<th>Digidoc</th>
															</tr>
														</thead>
														<tbody>
															<? foreach( $dados as $dado ) {    ?>
																<tr>	
																	<td><? echo stringTabela(getByTagName($dado->tags,'nmpessoa_socio'), 40, 'maiuscula'); ?> </td>
																	<td><? echo getByTagName($dado->tags,'nrcpfcgc_socio'); ?> </td>
																	<td><? echo getByTagName($dado->tags,'insituacao'); ?> </td>
																	<td><? echo getByTagName($dado->tags,'inreportavel'); ?> </td>
																	<td><? echo getByTagName($dado->tags,'dsdigidoc'); ?> </td>

																	<input type="hidden" id="nrcpfcgc_socio" name="nrcpfcgc_socio" value="<? echo getByTagName($dado->tags,'nrcpfcgc_socio'); ?>" />
																	<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($dado->tags,'nrdconta'); ?>" />
																	<input type="hidden" id="cdcooper" name="cdcooper" value="<? echo getByTagName($dado->tags,'cdcooper'); ?>" />
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

										<div id="divDadosSocio"></div>
										
										<div id="divBotoes" style="margin-bottom:10px">
											<a href="#" class="botao" id="btVoltar" onclick="fechaRotina( $('#divRotina')); return false;">Voltar</a>
											<?php if ($qtregist > 0) { ?>
												<a href="#" class="botao" id="btVoltar" onClick="dossieDigidoc('S'); return false;"><? echo utf8ToHtml('Dossiê DigiDOC') ?></a>
												<a href="#" class="botao" id="btVoltar" onClick="buscarLogAlteracoes('S'); return false;"><? echo utf8ToHtml('Log Alterações') ?></a>
											<?php } ?>
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
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		buscarSocios(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		buscarSocios(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});
	
	formataFormSocios();
	formataTabelaSocios();
    	 
</script>