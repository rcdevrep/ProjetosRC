#Include 'Protheus.ch' 
#Include "topconn.ch"    
#include "apvt100.ch" 

/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 06/10/2018
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Preenchimento automatico CN9_NUMERO.
Módulo (Uso) : SIGAGCT
=============================================================
/*/

User Function XAG0008()

	//Buscar numero de contrato.
	cquery        := cQuerysel := cQueryfrom := cQuerywher :=  " "   	
	cQuerysel     := " SELECT MAX(CN9_NUMERO) CN9_NUMERO "
	cQueryfrom    := " FROM "+RetSqlName("CN9")+" "                                                                                                      
	cQuerywher    := " WHERE D_E_L_E_T_ = ' ' AND CN9_FILIAL = '"+xFilial('CN9')+"' 
	cQuerywher    += " AND CN9_TPCTO = '"+CN1->CN1_CODIGO+"' 
	cQuerywher    += " AND SUBSTRING(CAST(CN9_NUMERO AS VARCHAR(15)),1,3) = '"+CN1->CN1_CODIGO+"' 
	cquery        := cquerysel + cqueryfrom + cquerywher                                                           

	If Select("Qry1") <> 0
		Qry1->(dbCloseArea())
	EndIf

	TCQuery cQuery Alias Qry1 New

	dbSelectArea("QRY1")
	Qry1->(dbGotop()) 

	_cProxNumero := " "
	If !Qry1->(Eof())
		If AllTrim(Qry1->CN9_NUMERO) <> "" 
			_cProxNumero := CN1->CN1_CODIGO+StrZero((Val(SubStr(Qry1->CN9_NUMERO,4,12))+1),12) 
		EndIf 
	EndIf

	If Empty(_cProxNumero)
		_cProxNumero := CN1->CN1_CODIGO+"000000000001"
	EndIf  

Return(_cProxNumero)

User Function XAG0008B()

	Local _cPlnLocV	:= SuperGetMv("MV_XPLNLOC",.F.,"004")
	Local _cPlnLocC	:= SuperGetMv("MV_XPLNVLC",.F.,"005")

	_cReajust := "2"
	
	If M->CN9_TPCTO == _cPlnLocV .or. M->CN9_TPCTO == _cPlnLocC
		_cReajust := "1"
	EndIf

Return(_cReajust)