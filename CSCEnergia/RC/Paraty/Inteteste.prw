#Include "PROTHEUS.CH
#include "RESTFUL.CH"
#include "Topconn.ch"  
/*--------------------------------------------------------+
  | Programa | API utilizada para efetuar consulta        |
  |            de Boletos em aberto Cliente               |
  +-------------------------------------------------------+  
  | Autor    | Khronos                                    | 
  +-------------------------------------------------------+  
  | Data     | 25/06/2024                                 | 
  +-------------------------------------------------------+
  | Descr.   | API REST Boletos/Boletos -  Nkey_Boletos   | 
  +-------------------------------------------------------+
  | 05/08/2024 -Alteração query todas empresas            |  
  | Obs empresas 03 e 05 não tinham tabelas até 05/08/2024|
  +------------------------------------------------------*/
	    
WSRESTFUL Boletos DESCRIPTION "API REST Boletos" 
   WSDATA cpfcnpj  AS CHARACTER  OPTIONAL
         
WSMETHOD GET BuscaBoletos;
	DESCRIPTION "API utilizada para buscar Boletos.";
    WSSYNTAX "/?{cpfcnpj}";
	PATH "/";
   TTALK "BuscaBoletos";
	
END WSRESTFUL

WSMETHOD GET BuscaBoletos WSSERVICE Boletos
Local oResponse	:=	Nil
Local aResponse	:=	{}
Local oC
Local lRet	      := .T.
Local cCnpj       := ""
Local cQuery      := ""
Local cAliasB     
Local caca        := 0
Local aCampos     := {}
Local ncamp       := 0
Local nX          := 0
Local cCamposQ
CONOUT( "*********************** API Boletos *******************************")
IF ( ValType( self:cpfcnpj  ) == "C" .and. !Empty( self:cpfcnpj  ) )
   cCnpj   := self:cpfcnpj
   cCnpj   := StrTran(cCnpj,".","")
   cCnpj   := StrTran(cCnpj,"/","")
   cCnpj   := StrTran(cCnpj,"-","")
ENDIF


cCamposQ := "E1_FILIAL, E1_FILORIG, E1_TIPO, E1_NUM ,E1_PREFIXO, E1_CLIENTE, E1_LOJA, E1_TIPO, E1_PARCELA,E1_EMISSAO,E1_VENCREA AS VENCTO,E1_MOEDA, E1_CONTKHR AS CONTRATO,E1_ZSTATFC AS STATUS, "

            cCamposQ += "(E1_SALDO + E1_SDACRES - E1_SDDECRE - (  "
            cCamposQ += " 		     (CASE WHEN A1_RECISS  = '1' AND nvl(ED_CALCISS, ' ') = 'S' THEN E1_ISS    ELSE 0 END) + "
            cCamposQ += " 		     (CASE WHEN A1_RECCSLL = 'S' AND nvl(ED_CALCCSL, ' ') = 'S' THEN E1_CSLL   ELSE 0 END) + "
            cCamposQ += " 		     (CASE WHEN A1_RECCOFI = 'S' AND nvl(ED_CALCCOF, ' ') = 'S' THEN E1_COFINS ELSE 0 END) + "
            cCamposQ += " 		     (CASE WHEN A1_RECINSS = 'S' AND nvl(ED_CALCINS, ' ') = 'S' THEN E1_INSS   ELSE 0 END) + "
            cCamposQ += " 		     (CASE WHEN A1_RECPIS  = 'S' AND nvl(ED_CALCPIS, ' ') = 'S' THEN E1_PIS    ELSE 0 END) + "
            cCamposQ += " 		     (CASE WHEN A1_RECIRRF = '1' AND nvl(ED_CALCIRF, ' ') = 'S' THEN E1_IRRF   ELSE 0 END) ) "
            cCamposQ += " 		    ) AS VALOR, "

cCamposQ += "SA1.R_E_C_N_O_ as RECNO, A1_NOME, A1_NREDUZ, A1_CGC, A1_EST, A1_EMAIL, Z04_LINDGT AS LINDGT, Z04_PDF AS PDF" + CRLF
cQuery := ""
For nX = 1 to 6 // empresas
   if nX <> 3 .and. nX <> 5
      cQuery += "SELECT " + cCamposQ + " FROM SE1" + strzero(nX,2) + "0 SE1 LEFT JOIN SED" + strzero(nX,2) + "0 SED ON SED.D_E_L_E_T_ = ' ' " + CRLF
      cQuery += "AND ED_FILIAL = E1_FILORIG AND ED_CODIGO = E1_NATUREZ INNER JOIN SA1" + strzero(nX,2) + "0 SA1 ON SA1.D_E_L_E_T_ = ' ' " + CRLF
      cQuery += "AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA INNER JOIN system.Z04" + strzero(nX,2) + "0 Z04 ON Z04.D_E_L_E_T_ = ' ' " + CRLF
      cQuery += "AND Z04_FILIAL = E1_FILORIG AND Z04_PREFIX = E1_PREFIXO AND Z04_TITULO = E1_NUM AND Z04_PARCEL = E1_PARCELA " + CRLF
      cQuery += "AND Z04_CLIENT = E1_CLIENTE AND Z04_LOJA = E1_LOJA AND Z04_STATUS = 'T' LEFT JOIN SF2" + strzero(nX,2) + "0 SF2 ON SF2.D_E_L_E_T_ = ' ' " + CRLF
      cQuery += "AND F2_FILIAL = E1_FILORIG AND F2_NFELETR = E1_NFELETR AND F2_CLIENTE = E1_CLIENTE AND F2_LOJA = E1_LOJA " + CRLF
      cQuery += "AND E1_NFELETR <> ' ' WHERE SE1.D_E_L_E_T_ = ' ' AND E1_EMISSAO < TO_CHAR(SYSDATE, 'YYYYMMDD') AND E1_SALDO > 0 " + CRLF
      cQuery += "AND E1_ZSTATFC NOT IN (' ' , 'E' , 'C' , 'X') AND A1_CGC = '" + cCnpj  + "'  AND A1_FILIAL = E1_FILORIG" + CRLF

      if nx < 6
         cQuery += "UNION all " + CRLF
      endIf
   endIf
Next

CONOUT( cQuery )
While .T.
    cAliasB := GetNextAlias()
    If !TCCanOpen(cAliasB) .And. Select(cAliasB) == 0
        Exit
    EndIf
EndDo

dbUseArea(.T.,"TOPCONN",TcGenQRY(,,cQuery),cAliasB,.F.,.T.) 
DbSelectArea(cAliasB)
(cAliasB)->(DbGoTop())
   aCampos := (cAliasB)->(dbStruct())
   ncamp   := len(aCampos) 
   
   While !(cAliasB)->(EOF())
                    
        oC  := nil
        oC  := JsonObject():New()
        FOR caca := 1 to ncamp
            IF(aCampos[caca,1] != "E1_MOEDA")        
               IF  ValType( &((cAliasB)+"->"+aCampos[caca,1])  ) == "C"     
                  oC[aCampos[caca,1]]  := ALLTRIM(&((cAliasB)+"->"+aCampos[caca,1]))
               ELSE
                     oC[aCampos[caca,1]]  := &((cAliasB)+"->"+aCampos[caca,1])
               ENDIF
            ENDIF
        NEXT 
        aadd(aResponse,oC)
        
        (cAliasB)->(dbskip())
    End
    (cAliasB)->(DbcloseArea())
    
    oResponse := JsonObject():New()
    oResponse["Boletos"] := aResponse
    self:SetResponse( EncodeUTF8(oResponse:ToJson()) )
FreeObj( oResponse )
oResponse := Nil
Return( lRet )
