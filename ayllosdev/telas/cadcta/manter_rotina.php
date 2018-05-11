<?php
/* FONTE        : manter_rotina.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 10/10/2017 
 * OBJETIVO     : Rotina para validar/alterar/excluir os dados da tela CADCTA
 * 
 * ALTERACOES   : 
 *
 */
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Guardo os parâmetos do POST em variáveis
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;		
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '' ;	
$cdagepac = (isset($_POST['cdagepac'])) ? $_POST['cdagepac'] : '' ;
$cdsitdct = (isset($_POST['cdsitdct'])) ? $_POST['cdsitdct'] : '' ;
$cdtipcta = (isset($_POST['cdtipcta'])) ? $_POST['cdtipcta'] : '' ;
$cdbcochq = (isset($_POST['cdbcochq'])) ? $_POST['cdbcochq'] : '' ;
$nrdctitg = (isset($_POST['nrdctitg'])) ? $_POST['nrdctitg'] : '' ;
$cdagedbb = (isset($_POST['cdagedbb'])) ? $_POST['cdagedbb'] : '' ;
$cdbcoitg = (isset($_POST['cdbcoitg'])) ? $_POST['cdbcoitg'] : '' ;
$dtcnsscr = (isset($_POST['dtcnsscr'])) ? $_POST['dtcnsscr'] : '' ;
$dtcnsspc = (isset($_POST['dtcnsspc'])) ? $_POST['dtcnsspc'] : '' ;
$dtdsdspc = (isset($_POST['dtdsdspc'])) ? $_POST['dtdsdspc'] : '' ;
$dtabtcoo = (isset($_POST['dtabtcoo'])) ? $_POST['dtabtcoo'] : '' ;
$dtelimin = (isset($_POST['dtelimin'])) ? $_POST['dtelimin'] : '' ;
$dtabtcct = (isset($_POST['dtabtcct'])) ? $_POST['dtabtcct'] : '' ;
$dtdemiss = (isset($_POST['dtdemiss'])) ? $_POST['dtdemiss'] : '' ;
$flgiddep = (isset($_POST['flgiddep'])) ? $_POST['flgiddep'] : '' ;
$tpavsdeb = (isset($_POST['tpavsdeb'])) ? $_POST['tpavsdeb'] : '' ;
$tpextcta = (isset($_POST['tpextcta'])) ? $_POST['tpextcta'] : '' ;
$inadimpl = (isset($_POST['inadimpl'])) ? $_POST['inadimpl'] : '' ;
$inlbacen = (isset($_POST['inlbacen'])) ? $_POST['inlbacen'] : '' ;	
$flgexclu = (isset($_POST['flgexclu'])) ? $_POST['flgexclu'] : '' ;
$flgcreca = (isset($_POST['flgcreca'])) ? $_POST['flgcreca'] : '' ;			
$flgrestr = (isset($_POST['flgrestr'])) ? $_POST['flgrestr'] : '' ;
$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '' ;
$indserma = (isset($_POST['indserma'])) ? $_POST['indserma'] : '' ;
$idastcjt = (isset($_POST['idastcjt'])) ? $_POST['idastcjt'] : '' ;
$cdconsul = (isset($_POST['cdconsul'])) ? $_POST['cdconsul'] : '' ; //Melhoria 126
$nrctacns = (isset($_POST['nrctacns'])) ? $_POST['nrctacns'] : '' ;
$incadpos = (isset($_POST['incadpos'])) ? $_POST['incadpos'] : '' ;
$flblqtal = (isset($_POST['flblqtal'])) ? $_POST['flblqtal'] : '' ;
$nmtalttl = (isset($_POST['nmtalttl'])) ? $_POST['nmtalttl'] : '' ;
$qtfoltal = (isset($_POST['qtfoltal'])) ? $_POST['qtfoltal'] : '' ;
$cdempres = (isset($_POST['cdempres'])) ? $_POST['cdempres'] : '' ;
$nrinfcad = (isset($_POST['nrinfcad'])) ? $_POST['nrinfcad'] : '' ;
$nrpatlvr = (isset($_POST['nrpatlvr'])) ? $_POST['nrpatlvr'] : '' ;
$dsinfadi = (isset($_POST['dsinfadi'])) ? $_POST['dsinfadi'] : '' ;
$cdsecext = (isset($_POST['cdsecext'])) ? $_POST['cdsecext'] : '' ;
$nrperger = (isset($_POST['nrperger'])) ? $_POST['nrperger'] : '' ;
$nmctajur = (isset($_POST['nmctajur'])) ? $_POST['nmctajur'] : '' ;

$dsinfadi = retiraSerialize( $dsinfadi, 'dsinfadi' );

$cdopecor = (isset($_POST['cdopecor'])) ? $_POST['cdopecor'] : '' ; //Melhoria 69
$fldevchq = (isset($_POST['fldevchq'])) ? $_POST['fldevchq'] : '' ; //Melhoria 69

$array1 = array("á","à","â","ã","ä","é","è","ê","ë","í","ì","î","ï","ó","ò","ô","õ","ö","ú","ù","û","ü","ç","ñ"
	               ,"Á","À","Â","Ã","Ä","É","È","Ê","Ë","Í","Ì","Î","Ï","Ó","Ò","Ô","Õ","Ö","Ú","Ù","Û","Ü","Ç","Ñ"
				   ,"&","¨","~","^","*","#","%","$","!","?",";",">","<","|","+","=","£","¢","¬","§","`","´","¹","²"
				   ,"³","ª","º","°","\"","'","\\","","→");
$array2 = array("a","a","a","a","a","e","e","e","e","i","i","i","i","o","o","o","o","o","u","u","u","u","c","n"
                   ,"A","A","A","A","A","E","E","E","E","I","I","I","I","O","O","O","O","O","U","U","U","U","C","N"
				   ,"e"," "," "," "," "," "," "," "," "," ",";"," "," ","|"," "," "," "," "," "," "," "," "," "," "
				   ," "," "," "," "," "," "," ","-","-");

// limpeza dos caracteres nos campos 
$nmtalttl = trim(str_replace( $array1, $array2, $nmtalttl));

if( $operacao == 'AV' ){
	validaDados();
} 

if ( $operacao == 'VA' ) {
  // Tipo de Conta
	if ( $GLOBALS['cdtipcta'] == '' ) exibirErro('error','Tipo de conta deve ser selecionado.','Alerta - Ayllos','',false); 
}

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','',false);

// Se é Validação
if( in_array($operacao,array('AV')) ) {

	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0074.p</Bo>';
	$xml .= '		<Proc>valida_dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<cdagepac>'.$cdagepac.'</cdagepac>';
	$xml .= '		<cdsitdct>'.$cdsitdct.'</cdsitdct>';	
	$xml .= '		<cdtipcta>'.$cdtipcta.'</cdtipcta>';
	$xml .= '		<cdbcochq>'.$cdbcochq.'</cdbcochq>';
	$xml .= '		<nrdctitg>'.$nrdctitg.'</nrdctitg>';
	$xml .= '		<cdagedbb>'.$cdagedbb.'</cdagedbb>';
	$xml .= '		<cdbcoitg>'.$cdbcoitg.'</cdbcoitg>';
	$xml .= '		<cdsecext>'.$cdsecext.'</cdsecext>';
	$xml .= '		<dtcnsscr>'.$dtcnsscr.'</dtcnsscr>';
	$xml .= '		<dtcnsspc>'.$dtcnsspc.'</dtcnsspc>';
	$xml .= '		<dtdsdspc>'.$dtdsdspc.'</dtdsdspc>';
	$xml .= '		<dtabtcoo>'.$dtabtcoo.'</dtabtcoo>';
	$xml .= '		<dtelimin>'.$dtelimin.'</dtelimin>';
	$xml .= '		<dtabtcct>'.$dtabtcct.'</dtabtcct>';
	$xml .= '		<dtdemiss>'.$dtdemiss.'</dtdemiss>';
	$xml .= '		<flgiddep>'.$flgiddep.'</flgiddep>';
	$xml .= '		<tpavsdeb>'.$tpavsdeb.'</tpavsdeb>';
	$xml .= '		<tpextcta>'.$tpextcta.'</tpextcta>';
	$xml .= '		<inadimpl>'.$inadimpl.'</inadimpl>';
	$xml .= '		<inlbacen>'.$inlbacen.'</inlbacen>';
	$xml .= '		<cddopcao>A</cddopcao>';
	$xml .= '		<tpevento>A</tpevento>';
	$xml .= '		<flgexclu>'.$flgexclu.'</flgexclu>';
	$xml .= '		<flgcreca>'.$flgcreca.'</flgcreca>';
	$xml .= '		<flgrestr>'.$flgrestr.'</flgrestr>';
	$xml .= '		<indserma>'.$indserma.'</indserma>';
	$xml .= '		<idastcjt>'.$idastcjt.'</idastcjt>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$nmdcampo = ( isset($xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO']) ) ? $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'] : '';

		if ( $nmdcampo == "" ) {
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
		} else {
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
		}
	}

    // Salva dados alterados da tela CADCTA
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0198.p</Bo>';
	$xml .= '		<Proc>valida_dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
    $xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<flgerlog>1</flgerlog>';
	$xml .= '		<cddopcao>I</cddopcao>';
	$xml .= '		<cdbcochq>'.$cdbcochq.'</cdbcochq>';
	$xml .= '		<cdconsul>'.$cdconsul.'</cdconsul>';
	$xml .= '		<cdagedbb>'.$cdagedbb.'</cdagedbb>';	
	$xml .= '		<nrdctitg>'.$nrdctitg.'</nrdctitg>';
	$xml .= '		<nrctacns>'.$nrctacns.'</nrctacns>';
	$xml .= '		<incadpos>'.$incadpos.'</incadpos>';
	$xml .= '		<flgiddep>'.$flgiddep.'</flgiddep>';
	$xml .= '		<flgrestr>'.$flgrestr.'</flgrestr>';
	$xml .= '		<indserma>'.$indserma.'</indserma>';
	$xml .= '		<inlbacen>'.$inlbacen.'</inlbacen>';
	$xml .= '		<nmtalttl>'.$nmtalttl.'</nmtalttl>';
	$xml .= '		<qtfoltal>'.$qtfoltal.'</qtfoltal>';
	$xml .= '		<cdempres>'.$cdempres.'</cdempres>';
	$xml .= '		<nrinfcad>'.$nrinfcad.'</nrinfcad>';
	$xml .= '		<nrpatlvr>'.$nrpatlvr.'</nrpatlvr>';
	$xml .= '		<dsinfadi>'.$dsinfadi.'</dsinfadi>';
    $xml .= '		<nmctajur>'.$nmctajur.'</nmctajur>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
        
		if ( $nmdcampo == "" ) {            
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
		} else {
            $metodo =  'focaCampoErro(\''.$nmdcampo.'\', \'frmCabCadcta\');';
            
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$metodo,false);
		}
	}
    
    
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0048.p</Bo>';
	$xml .= '		<Proc>validar-informacoes-adicionais</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dsdepart>'.$dsdepart.'</dsdepart>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<nrinfcad>'.$nrinfcad.'</nrinfcad>';
    $xml .= '		<nrpatlvr>'.$nrpatlvr.'</nrpatlvr>';
    $xml .= '		<nrperger>'.$nrperger.'</nrperger>';
    $xml .= '		<dsinfadi>'.$dsinfadi.'</dsinfadi>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO'){
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
	} 
	
	$opeconfi = 'VA';

	exibirConfirmacao('Deseja confirmar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOpeCadcta(\''.$opeconfi.'\')','',false);		

} else {

	// Salva dados alterados da tela CADCTA
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0198.p</Bo>';
	$xml .= '		<Proc>grava_dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
    $xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<flgerlog>1</flgerlog>';
	$xml .= '		<cddopcao>I</cddopcao>';
	$xml .= '		<cdbcochq>'.$cdbcochq.'</cdbcochq>';
	$xml .= '		<cdconsul>'.$cdconsul.'</cdconsul>';
	$xml .= '		<cdagedbb>'.$cdagedbb.'</cdagedbb>';	
	$xml .= '		<nrdctitg>'.$nrdctitg.'</nrdctitg>';
	$xml .= '		<nrctacns>'.$nrctacns.'</nrctacns>';
	$xml .= '		<incadpos>'.$incadpos.'</incadpos>';
	$xml .= '		<flgiddep>'.$flgiddep.'</flgiddep>';
	$xml .= '		<flgrestr>'.$flgrestr.'</flgrestr>';
	$xml .= '		<indserma>'.$indserma.'</indserma>';
	$xml .= '		<inlbacen>'.$inlbacen.'</inlbacen>';
	$xml .= '		<nmtalttl>'.$nmtalttl.'</nmtalttl>';
	$xml .= '		<qtfoltal>'.$qtfoltal.'</qtfoltal>';
	$xml .= '		<cdempres>'.$cdempres.'</cdempres>';
	$xml .= '		<nrinfcad>'.$nrinfcad.'</nrinfcad>';
	$xml .= '		<nrpatlvr>'.$nrpatlvr.'</nrpatlvr>';
	$xml .= '		<dsinfadi>'.$dsinfadi.'</dsinfadi>';
    $xml .= '		<nmctajur>'.$nmctajur.'</nmctajur>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];

		if ( $nmdcampo == "" ) {
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
		} else {
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
		}
	}
	
	
	// Verificação da revisão Cadastral
	$msgAtCad = $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'];
	$chaveAlt = $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'];
	$tpAtlCad = $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'];

	// Salvar a alteração de consultor
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '       <cdconsultordst>'.$cdconsul.'</cdconsultordst>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '       <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CADCON", "CADCON_TRANSFERE_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");

	$xmlObjeto = simplexml_load_string($xmlResult);

	if ($xmlObjeto->Erro->Registro->dscritic != "") {
		$msgErro = $xmlObjeto->Erro->Registro->dscritic;
		exibirErro("error",$msgErro,"Alerta - Ayllos","",false);
	}

	// Salvar alteração do campo devolução cheque automatico
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= '       <cddopcao>A</cddopcao>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '       <flgdevolu_autom>'.$fldevchq.'</flgdevolu_autom>';
	$xml .= '       <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '       <cdopecor>'.$cdopecor.'</cdopecor>';
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "GRAVA_DEVOLU_AUTOM", 'GRAVA_DEVOLU_AUTOM_XML', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");
	$xmlObjeto1 = getObjectXML($xmlResult); 
	
	if(strtoupper($xmlObjeto1->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObjeto1->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObjeto1->roottag->tags[0]->attributes["NMDCAMPO"];					
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto1->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}								
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);								
	}

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0048.p</Bo>';
	$xml .= '		<Proc>atualizar-informacoes-adicionais</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dsdepart>'.$dsdepart.'</dsdepart>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<nrinfcad>'.$nrinfcad.'</nrinfcad>';
    $xml .= '		<nrpatlvr>'.$nrpatlvr.'</nrpatlvr>';
    $xml .= '		<nrperger>'.$nrperger.'</nrperger>';
    $xml .= '		<dsinfadi>'.$dsinfadi.'</dsinfadi>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO'){
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);		
	}

	// Verificar se existe "Verificação de Revisão Cadastral"
	if($msgAtCad != '' && $flgcadas != 'M') {		
		exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0074.p\',\'\',controlaOpeCadcta(\'OC\'))','controlaOpeCadcta(\'OC\')',false);
			
	// Se não existe necessidade de Revisão Cadastral
	} else {
		echo 'controlaOpeCadcta(\'OC\');';			
	} 
} 

function validaDados() {			
	// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input","#frmContaCorrente").removeClass("campoErro");';
        echo '$("input","#frmCabCadcta").removeClass("campoErro");';

		// Número da conta e o titular são inteiros válidos
		if (!validaInteiro($GLOBALS['nrdconta'])) exibirErro('error','Conta/dv inválida.','Alerta - Ayllos','',false);				
		if (!validaInteiro($GLOBALS['idseqttl'])) exibirErro('error','Seq. Titular inválida','Alerta - Ayllos','',false);
	
		// PA
		if ( $GLOBALS['cdagepac'] == '' ) exibirErro('error','PA deve ser informado.','Alerta - Ayllos','',false); 
		
		// Situação
		if ( $GLOBALS['cdsitdct'] == '' ) exibirErro('error','Situação deve ser selecionada.','Alerta - Ayllos','',false); 
		
		// Tipo de Conta
		if ( $GLOBALS['cdtipcta'] == '' ) exibirErro('error','Tipo de conta deve ser selecionado.','Alerta - Ayllos','',false); 
		
		// Banco emi. cheque
		if ( ($GLOBALS['cdbcochq'] == '') ) exibirErro('error','Banco emissão do cheque deve ser informado.','Alerta - Ayllos','',false);
			
		// Valida se cods. são numericos
		if ( (!validaInteiro($GLOBALS['nrinfcad'])) || ( $GLOBALS['nrinfcad'] == 0 ) ) exibirErro('error','Informações Adicionais - Código inválido','Alerta - Ayllos','',false);	
		if ( ((!validaInteiro($GLOBALS['nrpatlvr'])) || ( $GLOBALS['nrpatlvr'] == 0 )) && ($GLOBALS['cdcooper'] != 3) ) exibirErro('error','Informações Adicionais - Código inválido','Alerta - Ayllos','',false);
}
?>