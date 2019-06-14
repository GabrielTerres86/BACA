<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jorge I. Hamaguchi 
 * DATA CRIAÇÃO : 27/08/2013
 * OBJETIVO     : Rotina tela CADRET.
 * --------------
 * ALTERAÇÕES   : [23/06/2016] - Renato Darosci - Supero: Incluir o código do produto como parametro 
 * -------------- 
 */
?> 

<?	
	session_cache_limiter("private");
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdprodut = (isset($_POST['cdprodut'])) ? $_POST['cdprodut'] : '' ; 
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ; 
	$cdoperac = (isset($_POST['cdoperac'])) ? $_POST['cdoperac'] : ''  ;
	$nrtabela = (isset($_POST['nrtabela'])) ? $_POST['nrtabela'] : 0  ;
	$cdretorn = (isset($_POST['cdretorn'])) ? $_POST['cdretorn'] : 0  ;
	$dsretorn = (isset($_POST['dsretorn'])) ? $_POST['dsretorn'] : '' ;
	
	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	// Verifica Procedure a ser executada	
	switch($operacao) {
		case 'A' :  
		case 'C' : { $procedure = 'consultar_cadret'; } break;
		case 'A1': { $procedure = 'alterar_cadret';   } break;
		case 'I' : { $procedure = 'incluir_cadret';   } break;
		default  : { exibirErro('atencao','Op&ccedil;&atilde;o Invalida!','Alerta - Ayllos','hideMsgAguardo();',true); exit();}
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('atencao',$msgError,'Alerta - Ayllos','hideMsgAguardo();',true);
		exit();
	}
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0169.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<cdprodut>'.$cdprodut.'</cdprodut>';
	$xml .= '		<cdoperac>'.$cdoperac.'</cdoperac>';
	$xml .= '		<nrtabela>'.$nrtabela.'</nrtabela>';
	$xml .= '		<cdretorn>'.$cdretorn.'</cdretorn>';
	$xml .= '		<dsretorn>'.$dsretorn.'</dsretorn>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
    // Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	$xmlObj    = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
 	if ($xmlObj->roottag->tags[0]->name == "ERRO") {
	    
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes['NMDCAMPO'];
		$retornoAposErro = "$('#btVoltar','#divBotoes').show();$('#btnContinuar','#divBotoes').show();"; 
		
		if (!empty($nmdcampo)) { 
			$nmdoform = "frmcadret";
			$retornoAposErro .= "$('#cddopcao','#frmCab').val('".$cddopcao."');focaCampoErro('".$nmdcampo."','".$nmdoform."');"; 
		}else{
			$retornoAposErro .= "$('#cddopcao','#frmCab').habilitaCampo();";
		}
		
		$retornoAposErro .= "hideMsgAguardo();";
		
		$msgErro = "<div style='text-align:left;'>";
		$taberros = $xmlObj->roottag->tags[0]->tags;
		for($i=0;$i<count($taberros);$i++){
			if($i==0){
				$msgErro .= $taberros[$i]->tags[4]->cdata;
			}else{
				$msgErro .= "<br>".$taberros[$i]->tags[4]->cdata;
			}
		}	
		$msgErro .= "</div>";
		
		exibirErro('atencao',$msgErro,'Alerta - Ayllos',$retornoAposErro,true);
		exit();
    }
	
	$cadret = $xmlObj->roottag->tags[0]->tags;	
	
	echo "<script  type='text/javascript'>";
	if ($operacao == "C" or $operacao == "A"){
		
		$desab = ".desabilitaCampo()";
		$btcon = ($operacao == "C") ? "$('#divRetorno').show();$('#btSalvar').hide();" : "";
		$focus = ($operacao == "A") ? "$('#dsretorn','#frmcadret').focus();" : "$('#btVoltar').focus();";
		
		echo "$('#cdoperac','#frmcadret')".$desab.";";
		echo "$('#nrtabela','#frmcadret')".$desab.";";
		if($operacao == "A"){
			$dsretorn = getByTagName($cadret[0]->tags,'DSRETORN');
			echo "$('#cdretorn','#frmcadret')".$desab.";";
			echo "$('#dsretorn','#frmcadret').habilitaCampo().val('".$dsretorn."');";
		}
		echo $btcon;
		echo $focus;
		
		echo "hideMsgAguardo();";
		
	}else if ($operacao == "I"){
		echo "showError('inform','Cadastro de Retorno salvo com sucesso!','Alerta - Ayllos','estadoInicial();hideMsgAguardo();');";
	}else if ($operacao == "A1"){
		echo "showError('inform','Cadastro de Retorno alterado com sucesso!','Alerta - Ayllos','btnVoltar();hideMsgAguardo();');";
	}
	echo "</script>";
	
	if($operacao == "C"){
		include('form_tabela_retorno.php'); 
	}
?>