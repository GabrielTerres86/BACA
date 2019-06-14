<? 
/*!
 * FONTE          : consulta_dados.php
 * CRIAÇÃO        : Rodrigo Bertelli (RKAM)
 * DATA CRIAÇÃO   : 27/06/2014
 * OBJETIVO       : arquivo responvel para preencher os dados inputados para inclusao
 *
 * Alteração      : 16/10/2015 - (Lucas Ranghetti #326872) - Alteração referente ao projeto melhoria 217, cheques sinistrados fora.
 */
 
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
 
 $strnomacao = $_POST['strCampo'];
 $strvalorcampo = $_POST['valorBusca'];
 $strtipotela = $_POST['tipoBusca'];
 $strcamporetorno = '';
 if($strtipotela == 1){
	$strcamporetorno = strtolower('NMEXTBCC');
 }else if($strtipotela == 2){
	$strcamporetorno = strtolower('NMRESCOP');
 }else{
	$strcamporetorno = strtolower('NMPRIMTL');
 }
  
 $xmlconsulta  = "";
 $xmlconsulta .= "<Root>";
 $xmlconsulta .= " <Dados>";
 $xmlconsulta .= "    <nmcamp>".$strnomacao."</nmcamp>";
 $xmlconsulta .= "    <dspesq>".$strvalorcampo."</dspesq>";
 $xmlconsulta .= " </Dados>";
 $xmlconsulta .= "</Root>";
 
 $xmlResultCons = mensageria($xmlconsulta, "CHQSIN", 'CONCAMSCH', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
 $xmlObjRetornoCons = getObjectXML($xmlResultCons);
 //retorno dos registros
 if(strtoupper($xmlObjRetornoCons->roottag->tags[0]->name) == 'ERRO'){
 $dados = '0.'.$xmlObjRetornoCons->roottag->tags[0]->tags[0]->tags[4]->cdata;
 }else{
 $dados = '1.'.$xmlObjRetornoCons->roottag->tags[0]->tags[0]->cdata;
 }
 echo ($dados);
?>
	