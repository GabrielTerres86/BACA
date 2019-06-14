<? 
/*!
 * FONTE        : valida_horario.php
 * CRIAÇÃO      : Adriano (CECRED)
 * DATA CRIAÇÃO : 22/08/2012
 * OBJETIVO     : Rotina validar o horario para digitação dos campos na opção "F"
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?> 

<?	
	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	
	// Recebe a operação que está sendo realizada
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$cdmovmto = (isset($_POST['cdmovmto'])) ? $_POST['cdmovmto'] : '' ;
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
		
	}

	//Monta XML de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0131.p</Bo>";
	$xml .= "        <Proc>valida_horario</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";	

	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
	
		$msgErro	= "Não foi possível validar horário.";
				
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
		
	}else{
					
		$msgErro	= $xmlObjeto->roottag->tags[0]->attributes['DSCRITIC'];
		$hrpermit	= $xmlObjeto->roottag->tags[0]->attributes['HRPERMIT'];
		
		?>
		
		hrpermit = '<?echo $hrpermit;?>';
										
		<?
		
		if($hrpermit == "no"){
						
			exibirErro('error',$msgErro,'Alerta - Ayllos','bloqueiaCampo();mostraMsgsAlerta();',false);
									
		}else{
			
			?>
				mostraMsgsAlerta();
			<?
			
			if($cdmovmto == "E" || $cdmovmto == "S"){
				echo "trocaBotao('prosseguir','showConfirmacao(\'Deseja confirmar opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'gravaDiversos();\',\'\',\'sim.gif\',\'nao.gif\');');";
			}else if($cdmovmto == "R"){
				echo "trocaBotao('prosseguir','showConfirmacao(\'Deseja confirmar opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'gravaApliResg();\',\'\',\'sim.gif\',\'nao.gif\');');";
									
			}
		
		}
		
	
	}
		
	
?>
	
	
	
	
