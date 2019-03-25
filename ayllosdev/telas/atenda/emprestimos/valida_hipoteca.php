<? 
/*!
 * FONTE        : valida_hipoteca.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 16/03/2011 
 * OBJETIVO     : Verificas conta e traz dados do associados.
 
 * ALTERAÇÕES   :
 * 001: [21/01/2016] James (CECRED): Incluido condicao para verificar se apresenta mensagem de aviso, caso o valor da garantia for superior a 5 vezes do valor do emprestimo
 * 002: [31/10/2018] Paulo (Mouts): Incluido novas colunas para validação 
 */
?>
 
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$nmfuncao = (isset($_POST['nmfuncao'])) ? $_POST['nmfuncao'] : '';	
	$dscatbem = (isset($_POST['dscatbem'])) ? $_POST['dscatbem'] : '';
	$dsbemfin = (isset($_POST['dsbemfin'])) ? $_POST['dsbemfin'] : '';
	$vlmerbem = (isset($_POST['vlmerbem'])) ? $_POST['vlmerbem'] : '';
	$idcatbem = (isset($_POST['idcatbem'])) ? $_POST['idcatbem'] : '';
	$vlemprst = (isset($_POST['vlemprst'])) ? $_POST['vlemprst'] : '';
	$dsendere = (isset($_POST['dsendere'])) ? $_POST['dsendere'] : '';
	$dsclassi = (isset($_POST['dsclassi'])) ? $_POST['dsclassi'] : '';
	$vlrdobem = (isset($_POST['vlrdobem'])) ? $_POST['vlrdobem'] : '';
	$nrcepend = (isset($_POST['nrcepend'])) ? $_POST['nrcepend'] : '';
	$nmbairro = (isset($_POST['nmbairro'])) ? $_POST['nmbairro'] : '';
	$nmcidade = (isset($_POST['nmcidade'])) ? $_POST['nmcidade'] : '';
	$cdufende = (isset($_POST['cdufende'])) ? $_POST['cdufende'] : '';
	$nomeform = (isset($_POST['nomeform'])) ? $_POST['nomeform'] : '';
	
	$dscatbem = ( $dscatbem == 'null' ) ? '' : $dscatbem;
		
	// Monta o xml de requisição
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0002.p</Bo>";
	$xml .= "		<Proc>valida-dados-hipoteca</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<dscatbem>".$dscatbem."</dscatbem>";
	$xml .= "		<dsbemfin>".$dsbemfin."</dsbemfin>";
	$xml .= "		<vlmerbem>".$vlmerbem."</vlmerbem>";
	$xml .= "		<idcatbem>".$idcatbem."</idcatbem>";
	$xml .= "		<vlemprst>".$vlemprst."</vlemprst>";
    $xml .= "		<dsendere>".$dsendere."</dsendere>";	
    $xml .= "		<dsclassi>".$dsclassi."</dsclassi>";	
    $xml .= "		<vlrdobem>".$vlrdobem."</vlrdobem>";	
	$xml .= "		<nrcepend>".$nrcepend."</nrcepend>";	
	$xml .= "		<nmbairro>".$nmbairro."</nmbairro>";	
	$xml .= "		<nmcidade>".$nmcidade."</nmcidade>";	
	$xml .= "		<cdufende>".$cdufende."</cdufende>";	    
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	$nomeCampo	= $xmlObj->roottag->tags[0]->attributes['NMDCAMPO'];
	
	if ( $nomeCampo != '' ) {
		$mtdErro = 'focaCampoErro(\''.$nomeCampo.'\',\''.$nomeform.'\');bloqueiaFundo(divRotina);';
	} else {
		$mtdErro = 'bloqueiaFundo(divRotina);';
	}
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$mtdErro,false);
	}
	
	// Condicao para veriricar se apresenta mensagem para o usuario
	if ($xmlObj->roottag->tags[0]->attributes['DSMENSAG'] != ""){
		
		$metodo = "bloqueiaFundo(divRotina);";
		
		// Condicao para verificar se apresenta senha de confirmacao
		if ($xmlObj->roottag->tags[0]->attributes['FLGSENHA'] == 1){
			$metodo .= "pedeSenhaCoordenador(2,'".addslashes(addslashes(addslashes($nmfuncao)))."','');";
		}else{
			$metodo .= addslashes($nmfuncao);
		}	
		exibirErro('inform',$xmlObj->roottag->tags[0]->attributes['DSMENSAG'],'Alerta - Aimaro',$metodo,false);		
	}else{
		echo $nmfuncao;
	}
?>