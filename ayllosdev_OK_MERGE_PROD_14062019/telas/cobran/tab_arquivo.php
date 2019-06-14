<? 
/*!
 * FONTE        : tab_arquivo.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 28/02/2012 
 * OBJETIVO     : Tabela de com a lista de arquivos da tela COBRAN
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
?>

<?php
	
	$nmarqint	= $_POST['nmarqint'];

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0010.p</Bo>';
	$xml .= '		<Proc>carrega_arquivos</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<nmarqint>'.$nmarqint.'</nmarqint>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xml);
	$xmlObjeto 	= getObjectXML($xmlResult);
    
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','fechaRotina( $(\'#divRotina\') )', false);
	} 

	$registro 	= $xmlObjeto->roottag->tags[0]->tags;
	$qtregist	= $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];
	
?>

<table cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0"  >
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('IMPRIMIR') ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina( $('#divRotina') );  return false;" ><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
										
										<form id="frmArquivo" class="formulario" onsubmit="return false;">
										<fieldset>
										<legend>Arquivos a Serem Integrados</legend>
										<div class="divRegistros">	
											<table>
												<thead>
													<tr>
														<th></th>
														<th><? echo utf8ToHtml('Arquivo');  ?></th>
													</tr>
												</thead>
												<tbody>
													<? foreach( $registro as $r ) { ?>
														<tr>
															<td><input name="arquivos" id="arquivos" type="checkbox" value="<? echo getByTagName($r->tags,'dsarquiv') ?>" /></td>
															<td><span><? echo getByTagName($r->tags,'dsarquiv') ?></span>
																	  <? echo getByTagName($r->tags,'dsarquiv') ?>
															</td>
														</tr>
												<? } ?>	
												</tbody>
											</table>
										</div>
										</fieldset>
										</form>

										<div id="divBotoes" style="padding-bottom:10px">
											<a href="#" class="botao" id="btVoltar" onclick="fechaRotina( $('#divRotina') ); return false;">Cancelar</a>										
											<a href="#" class="botao" id="btContinuar" >Continuar</a>										
											
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
