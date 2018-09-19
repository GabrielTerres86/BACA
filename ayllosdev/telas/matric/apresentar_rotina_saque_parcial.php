<?
/*!
 * FONTE        : apresentar_rotina_saque_parcial.php
 * CRIAÇÃO      : Jonata - RKAM
 * DATA CRIAÇÃO : Julho/2017
 * OBJETIVO     : Tela do formulario da rotina de saquel parcial
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
    $xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
    $xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
    $xml  .= "  </Dados>";
    $xml  .= "</Root>";

    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "CADA0003", "BUSCAR_SALDO_COTAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {

        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
        exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','fechaRotina($(\'#divRotina\'));',false);

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
											
												<label for="vldcotas"><? echo utf8ToHtml('Valor das cotas:') ?></label>
												<input type="text" name="vldcotas" id="vldcotas" value="<? echo $vldcotas; ?>" />
												
												<br />
												
												<label for="vldsaque"><? echo utf8ToHtml('Valor do saque:') ?></label>
												<input type="text" name="vldsaque" id="vldsaque"/>
		
												<br />
												
												<label for="nrdconta">Conta:</label>
												<input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta); ?>" alt="Informe o numero da conta do cooperado." />
												<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
												
												<br style="clear:both" />
												
											</form>
											
										</div>
										
										<div id="divBotoesSaqueParcial" style="margin-bottom:10px">
											
											<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); return false;">Voltar</a>
											<a href="#" class="botao" id="btConcluir" onclick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','efetuarSaqueParcial();','$(\'#btVoltar\',\'#divBotoesSaqueParcial\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));','sim.gif','nao.gif');return false;">Concluir</a>
											
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

