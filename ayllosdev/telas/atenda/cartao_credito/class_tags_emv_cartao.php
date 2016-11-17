<?
/*!
 * FONTE        : class_tags_emv_cartao.php
 * CRIAÇÃO      : Oscar
 * DATA CRIAÇÃO : Novembro/2014
 * OBJETIVO     : Classe para tratar estrutura TLV tags do cartao.
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 

/*
Tags EMVS tratadas:
Authorised_Amount 9F02
Application_Cryptogram 9F26
Application_Interchange_Profile 82
Transaction_Counter 9F36
Card_Risk_Managment_Data_1 8C
Cryptogram_Information_Data 9F27
Issuer_Application_Data 9F10
PAN_Number 5A
PAN_Sequence_Number 5F34
Terminal_Country_Code 9F1A
Terminal_Verification_Results 95
Transaction_Currency_Code 5F2A
Transaction_Date 9A
Tranasction_Type 9C
Unpredictable_Number 9F37  */


define("Authorised_Amount", "9F02");
define("Application_Cryptogram", "9F26");
define("Application_Interchange_Profile", "82");
define("Transaction_Counter", "9F36");
define("Card_Risk_Managment_Data_1", "8C");
define("Cryptogram_Information_Data", "9F27");
define("Issuer_Application_Data", "9F10");
define("PAN_Number", "5A");
define("PAN_Sequence_Number", "5F34");
define("Terminal_Country_Code", "9F1A");
define("Terminal_Verification_Results", "95");
define("Transaction_Currency_Code", "5F2A");
define("Transaction_Date", "9A");
define("Tranasction_Type", "9C");
define("Unpredictable_Number", "9F37");

require_once("class_tags_emv.php");
 
class TagsEmvCartao extends TagsEmv {

	private $tagNameList = array(Authorised_Amount, 
	                             Application_Cryptogram, 
								 Application_Interchange_Profile, 
								 Transaction_Counter,
								 Card_Risk_Managment_Data_1,
								 Cryptogram_Information_Data,
								 Issuer_Application_Data,
								 PAN_Number,
								 PAN_Sequence_Number,
								 Terminal_Country_Code,
								 Terminal_Verification_Results,
								 Transaction_Currency_Code,
								 Transaction_Date,
								 Tranasction_Type,
								 Unpredictable_Number);
								 
	function __construct ($Script) { 
		
		parent :: __construct ($Script, $this->tagNameList); 

	} 
	
	public function getTagValueByTagName($tagName){
	
	   return $this->_getTagValueByTagName($tagName);
	   
	}
	
}
?>

