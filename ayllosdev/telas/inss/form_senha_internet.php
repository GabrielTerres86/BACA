<? 
/***************************************************************************************
 * FONTE        : form_senha_internet.php				Última alteração: --/--/----
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : Outubro/2015
 * OBJETIVO     : Solicita senha de internet do beneficiario
 
	 Alterações   : 
  
 
 **************************************************************************************/
?>
 
<?
	session_start();
		
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	
	isPostMethod();		
		
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');
			
	setVarSession("opcoesRotina",$opcoesTela);
  
	$retorno  = (isset($_POST['retorno']))  ? $_POST['retorno']  : "";
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : "";
	$idseqttl = (isset($_POST["idseqttl"])) ? $_POST["idseqttl"] : "";
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'])) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
		
	// Guardo os parâmetos do POST em variáveis	
	$nmdatela = (isset($_POST['nmdatela'])) ? $_POST['nmdatela'] : '';
	$nmrotina = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : '';
  
  $session = session_id();	
	
?>	
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?echo $tituloTela;?></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick="acessaOpcaoAba(4,0,'@')" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao">
									  <div id="divSolicitaSenha" style=";margin-top:5px; margin-bottom :10px;">
                      <br />
                      <br />
                        <label for="cddsenha">Senha Internet:</label>
                        <input id="cddsenha" type="password" name="cddsenha" value=""></input>	
                      <br />
                      <br />
                      <a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); return false;">Cancelar</a>
                      <a href="#" class="botao" id="btConcluir" onClick="validaSenhaInternet('<?echo $retorno?>','<?echo $nrdconta?>','<?echo $idseqttl?>');fechaRotina($('#divRotina'));return false;" >Concluir</a> 
                      <br />
                      <br />
                      <br />
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
<script>
  
  $('#cddsenha','#divSolicitaSenha').unbind('keypress').bind('keypress', function (e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		//Enter ou TAB
		if(e.keyCode == 13 || e.keyCode == 9){
		
			validaSenhaInternet('<?echo $retorno?>','<?echo $nrdconta?>','<?echo $idseqttl?>');
      fechaRotina($('#divRotina'));
			return false;
			
		}
					
	});
</script>