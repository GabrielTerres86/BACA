<? 
/*!
 * FONTE       	    : manter_rotina.php
 * CRIAÇÃO     	    : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO	    : 11/01/2013
 * OBJETIVO    	    : Rotina para manter as operações da tela MANCCF
 * ULTIMA ALTERAÇÃO : 02/07/2013
 * --------------
 * ALTERAÇÕES   	: 02/07/2013 - Inclusão da variavel confirem (Confirma remoção da justificativa). (Reinert)
                      18/10/2013 - Validacao de permissao estava incorreta, utilizando opcao C. Opcao J é a correta. (David)
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

	// Inicializa	
	$procedure 		= '';
	$retornoAposErro= '';	
	
	
	// Recebe a operação que está sendo realizada
	$flextjus = (isset($_POST['flextjus']))   ? $_POST['flextjus']   : 'no';
	$cddjusti = (isset($_POST['cddjusti']))   ? $_POST['cddjusti']   : 0   ; 
	$dsdjusti = (isset($_POST['dsdjusti']))   ? $_POST['dsdjusti']   : ''  ; 
	$dsobserv = (isset($_POST['dsobserv']))   ? $_POST['dsobserv']   : ''  ; 
	$nrdrowid = (isset($_POST['nrdrowid']))   ? $_POST['nrdrowid']   : '?' ; 
	$cdoperad = (isset($_POST['cdoperad']))   ? $_POST['cdoperad']   : 0   ; 
	$confirem = (isset($_POST['confirem']))   ? $_POST['confirem']   : ''  ; 
	$flgctitg = (isset($_POST['flgctitg']))   ? $_POST['flgctitg']   : 'no'; 
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'J')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0152.p</Bo>";
	$xml .= "        <Proc>Grava_Dados</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';		
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';		
	$xml .= '       <flextjus>'.$flextjus.'</flextjus>';			
	$xml .= '       <cddjusti>'.$cddjusti.'</cddjusti>';		
	$xml .= '       <dsdjusti>'.$dsdjusti.'</dsdjusti>';		
	$xml .= '       <dsobserv>'.$dsobserv.'</dsobserv>';		
	$xml .= '       <nrdrowid>'.$nrdrowid.'</nrdrowid>';		
	$xml .= '       <cdopera1>'.$cdoperad.'</cdopera1>';		
	$xml .= '       <flgctitg>'.$flgctitg.'</flgctitg>';	
	$xml .= '       <confirem>'.$confirem.'</confirem>';	
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
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	 echo 'buscaDados(1);';		
?>