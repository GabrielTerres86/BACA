<? 
/***************************************************************************************
 * FONTE        : form_senha_internet.php				Última alteração: --/--/----
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : Outubro/2015
 * OBJETIVO     : Solicita senha de internet do beneficiario
 
   Alterações   : 21/10/2016 - Movido rotina para includes para uso generico - Odirlei Busana - AMcom 
  
 
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
	

	// Guardo os parâmetos do POST em variáveis	
	$nmdatela = (isset($_POST['nmdatela'])) ? $_POST['nmdatela'] : '';
	$nmrotina = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : '';
  
    $session = session_id();	    
    
    // Montar o xml de Requisicao
    $xml = new XmlMensageria();
    $xml->add('nrdconta',$nrdconta);
    
    $xmlResult = mensageria($xml, "GENERICO", 'CARREGA_TTL_INTERNET', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);
    $xmlDados  = $xmlObject->roottag->tags[0];

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {

       $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObject->roottag->tags[0]->cdata;
        }

        exibeErroNew('error',$msgErro);
        exit();
    }
    
    // Titulares com acesso ao internetbank
    $titulares = $xmlDados->tags[2]->tags;


function exibeErroNew($tpdmsg,$msgErro) {
    echo '<script>';
    echo 'hideMsgAguardo();';
    echo 'showError("'.$tpdmsg.'","' . $msgErro . '","Alerta - Aimaro","desbloqueia()");';
    echo '</script>';
}    
	
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
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">							
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
                                    <form name="frmSnhInternet" id="frmSnhInternet" class="formulario" method="post" onsubmit="return false;">	
                                    <fieldset>
                                        <legend>Senha de Internet</legend>
                                        <br>
                                        <div id="divConteudoSnh">
                                            <div class="divRegistros">
                                                <table>
                                                <thead>
                                                    <tr>
                                                        <th>Sequ&ecirc;ncia</th>
                                                        <th>Titular</th>
                                                        <th>Situa&ccedil;&atilde;o</th>
                                                    </tr>			
                                                </thead>
                                                <tbody>
                                                    <?  for ($i = 0; $i < count($titulares); $i++) {	
                                                            $idseqttl =  getByTagName($titulares[$i]->tags,'idseqttl');   
                                                            $nmtitula =  getByTagName($titulares[$i]->tags,'nmtitula'); 
                                                            $nrcpfope =  getByTagName($titulares[$i]->tags,'nrcpfope'); 
                                                            $incadsen =  getByTagName($titulares[$i]->tags,'incadsen');
                                                            $inbloque =  getByTagName($titulares[$i]->tags,'inbloque');
                                                            $inpessoa =  getByTagName($titulares[$i]->tags,'inpessoa');
                                                            
                                                            if ($inbloque == 1) {
                                                                $status = 'Bloqueado';
                                                            }else if($incadsen){
                                                                $status = 'Pendente 1&deg; acesso';
                                                            }else{
                                                                $status = 'Ativo';
                                                            }
                                                    
                                                            $mtdClick = "selecionaTtlInternetSenha(".$idseqttl.",".$incadsen.",".$inbloque.");";
                                                    ?>
                                                    <tr id="titular<?php echo $i; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>" >
                                                      <td> <?php echo $idseqttl; ?> </td>
                                                      <td> <?php echo $nmtitula; ?> </td>
                                                      <td> <?php echo $status; ?> </td>
                                                    </tr>
                                                    <?php } ?>
                                                </tbody>
                                                </table>
                                            </div>
                         
                                        </div>
                                        
                                        <div id="divSolicitaSenha" style=";margin-top:1px; margin-bottom :0px;" align="center">
                                          <br />
                                            <label for="cddsenha">Senha Internet:</label>
                                            <input id="cddsenha" type="password" name="cddsenha" value=""></input>	
                                            <input id="idseqttl" type="hidden" name="idseqttl" value=""></input>	
                                            <input id="retorno"  type="hidden" name="retorno"  value="<?echo $retorno?>"></input>	
                                            <input id="nrdconta" type="hidden" name="nrdconta" value="<?echo $nrdconta?>"></input>	
                                          <br />
                                          <br />                                          
                                        </div>                                        
                                        
                                    </fieldset>                                     
                                    </form>
                                    <div id='divbotsnh'>
                                        <a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divUsoGenerico')); return false;">Cancelar</a>
                                        <a href="#" class="botao" id="btConSnh" onClick="validaSenhaInternet();fechaRotina($('#divUsoGenerico'));return false;" >Concluir</a> 
                                        <br />
                                        <br />
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
		
			validaSenhaInternet();
            fechaRotina($('#divUsoGenerico'));
			return false;
			
		}
					
	});
</script>
