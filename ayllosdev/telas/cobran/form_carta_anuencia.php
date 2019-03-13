<?
/* 
 * FONTE        : testemunhas.php
 * CRIAï¿½ï¿½O      : Gabriel Ramirez
 * DATA CRIAï¿½ï¿½O : 14/04/2011 
 * OBJETIVO     : Mostrar a tela de testemunhas.
 * 
 * ALTERACOES   : 26/07/2011 - Incluir tratamento para cobranca Registrada(Gabriel)
*/

session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");		
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");	

$nmrotina = $_POST["nmrotina"];

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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">&nbsp;</td>
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
                                        <form name="frmDataPag" id="frmDataPag" class="formulario">
                                            <fieldset>
                                            
                                                <legend> Carta Anuência </legend>
                                                
                                                <table width="100%" border="0" cellspacing="3" cellpadding="0">
                                                
                                                    <tr height="25px">
                                                        <td width="150px" align="right" class="txtNormalBold">Data quitação da dívida:</td>
                                                        <td><input name="dtcatanu" id="dtcatanu" type="text" class="campo data" style="width:150px;"/></td>			
                                                    </tr>
													<tr style="display:none" id="linhaRepresentantes">
														<td colspan="2">
															<fieldset>
																<legend>Representantes</legend>
																<table width="100%" border="0" cellspacing="3" cellpadding="0">
																	<tr style="display:none">
																		<td>																			
																			<div>
																				<label style="width:73px;">Nome:</label>
																				<input name="nomrepres[]" type="text" class="campo nome" style="width:150px;" disabled readonly />
																				<label style="width:73px;">RG:</label>
																				<input name="nrrgrepres[]" type="text" class="campo rg" style="width:150px;" disabled readonly />
																				<label style="width:73px;">CPF:</label>
																				<input name="cpfrepres[]" type="text" class="campo cpf" style="width:150px;" disabled readonly />
																				<img onclick="excluirRepresentante(this);" src="http://aylloshomol2.cecred.coop.br/imagens/geral/panel-error_16x16.gif" style="width: 16px;height: 16px;margin-top: 4px;margin-left: 5px;display: inline;">
																			</div>
																		</td>
																	</tr>
																</table>
															</fieldset>
														</td>
                                                    </tr>
                                                                
                                                </table>	
                                            </fieldset>	
                                        </form>
										

										<div id= "botao"> <!-- $('#divTestemunhas').css('display','none');$('#divImpressoes').css('display','block');  -->
											<a href="#" class="botao" id="btNovoRepresentante" onClick="adicionarNovoRepresentante(this);">Incluir representante</a>
											<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina'));">Voltar</a>
											<a href="#" class="botao" id="btConfirmar" onClick="imprimirCartaAnuencia();">Continuar</a>
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
<form action="<?php echo $UrlSite;?>telas/cobran/imprimir_carta_anuencia.php" method="post" id="frmReport" name="frmReport">
	<input type="hidden" name="cdcooper" id="cdcooper">
	<input type="hidden" name="nrdconta" id="nrdconta">
	<input type="hidden" name="nrcnvcob" id="nrcnvcob">
	<input type="hidden" name="nrdocmto" id="nrdocmto">
	<input type="hidden" name="cdbandoc" id="cdbandoc">
	<input type="hidden" name="dtcatanu" id="dtcatanu">
	<input type="hidden" name="nmrepres" id="nmrepres">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>
<script>
	function adicionarNovoRepresentante(btn) {
		var linha = $('#linhaRepresentantes');
		
		linha.show();
		
		var tb = linha.find('table');
		var tr = tb.find('tr').first();
		var clone = tr.clone();
		
		tb.append(clone);
		clone.show();
		clone.find('input').prop('disabled', false).prop('readonly', false);
		clone.find('input.cpf').setMask('INTEGER', '999.999.999-99', '.-', '');
		
		if (tb.find('tr:visible').length > 4) {
			$(btn).hide();
		}
		
	}
	
	function excluirRepresentante(el) {
		$(el).closest('tr').remove();
		
		if (!$('#linhaRepresentantes table tr:visible').length) {
			$('#linhaRepresentantes').hide();
		}
		
		if ($('#linhaRepresentantes table tr:visible').length <= 4) {
			$('#btNovoRepresentante').show();
		}
	}
</script>
