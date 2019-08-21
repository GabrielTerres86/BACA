create or replace and compile java source named validarxml as
import java.sql.*;
import java.io.*;

import java.lang.String;
import oracle.xml.sql.dataset.*;
import oracle.xml.sql.query.*;

import oracle.xml.sql.*;
import oracle.sql.*;
import oracle.jdbc.driver.*;
import oracle.xml.parser.schema.*;
import oracle.xml.parser.v2.*;
import org.xml.sax.*;
import org.w3c.dom.*;
/**
 * Classe que vai receber um parâmetro do tipo CLOB do Oracle e irá efetuar o parser XML utilizando
 * SAX.
 * No final retorna 1 em caso de sucesso ou 0 + mensagem de erro em caso de erros.
 * @author Petter Rafael - Supero Tecnologia
 * @since Janeiro/2013
 */
 public class ValidarXML {
 /**
 * Método público para efetuar o parser.
 * @param xmldoc imput stream dos caracteres que montam o XML
 * @return Retorna string contendo 1 em caso de sucesso ou 0 em caso de erros
 */
 public static String validarCLOB(oracle.sql.CLOB xmldoc) {
 SAXParser parser = new SAXParser();

 try {
     parser.parse(xmldoc.getCharacterStream());
     return "1";
      } catch(SAXException e) {
         return "0 -" + e.getMessage();
      }
catch(Exception e) {
         return "Erro: " + e.getMessage();
      }
       }
         }
/
