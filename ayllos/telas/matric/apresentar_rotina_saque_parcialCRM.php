<?
/*!
 * FONTE        : apresentar_rotina_saque_parcial.php
 * CRIAÇÃO      : Renato Darosci - SUPERO
 * DATA CRIAÇÃO : Dezembro/2017
 * OBJETIVO     : Tela do formulario da rotina de saquel parcial
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
?>

<?
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	
    require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
  
    $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	
	// Monta o xml de requisição
    $xml   = "";
    $xml  .= "<Root>";
    $xml  .= "  <Dados>";
    $xml  .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
    $xml  .= "  </Dados>";
    $xml  .= "</Root>";

    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "MATRIC", "DADOS_SAQUE_PARCIAL_MATRIC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra mensagem
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Cadmat','estadoInicial();',false);
		exit();
	}

	$registro = ( isset($xmlObjeto->roottag->tags) ) ? $xmlObjeto->roottag->tags : array();

	// Monta o xml de requisição
    $xml   = "";
    $xml  .= "<Root>";
    $xml  .= "  <Dados>";
    $xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';
    $xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
    $xml  .= "  </Dados>";
    $xml  .= "</Root>";

    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "MATRIC", "COTAS_LIBERADA_MATRIC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {

        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        
        exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','fechaRotina($(\'#divRotina\'));',false);

    }
    
    $vldcotas = $xmlObj->roottag->tags[0]->tags[0]->cdata;
  
?>

<table width="100%" id='telaDetalhamento' cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table width="100%" border="0" cellpadding="0" cellspacing="0"  >
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('Saque Parcial') ?></td>
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
									
									<div id="divConteudoOpcao" >
							
										<div id="divSaqueParcial" style="width: 100%; display: block;">
											<form action="" method="post" name="frmSaqueParcial" id="frmSaqueParcial" class="formulario">
												<input type="hidden" name="rowidsaq" id="rowidsaq" value="<?php echo getByTagName($registro,'rowidsaq'); ?>" />

												<label for="nrdconta"><? echo utf8ToHtml('Conta para crédito:') ?></label>
												<input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDVsimples(getByTagName($registro,'nrdconta')); ?>" alt="Informe o numero da conta do cooperado." />
												
												<br />

												<label for="vldcotas"><? echo utf8ToHtml('Valor das cotas:') ?></label>
												<input type="text" name="vldcotas" id="vldcotas" value="<?php echo $vldcotas; ?>" />

												<br />

												<label for="vldsaque"><? echo utf8ToHtml('Valor do saque:') ?></label>
												<input type="text" name="vldsaque" id="vldsaque" value="<?php echo getByTagName($registro,'vlsaque'); ?>" />

												<br />
												
												<label for="dsmotivo"><? echo utf8ToHtml('Motivo do saque:') ?></label>
												<input type="text" name="dsmotivo" id="dsmotivo" value="<?php echo getByTagName($registro,'dsmotivo'); ?>" />
											
												<br style="clear:both" />
												
											</form>
											
										</div>
										
										<div id="divBotoesSaqueParcial" style="margin-bottom:10px">
											
											<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); return false;">Voltar</a>
											<a href="#" class="botao" id="btConcluir" onclick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','efetuarSaqueParcialCRM();','$(\'#btVoltar\',\'#divBotoesSaqueParcial\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));','sim.gif','nao.gif');return false;">Concluir</a>
											
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

