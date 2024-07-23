#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF260BUT   บAutor  ณOsmar Schimitberger บ Data ณ  05/09/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ          ณPonto de Entrada para trarar raiz do CNPJ no DDA            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Agricopel - Conciliacao DDA                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function F260BUT()

Local aRot := PARAMIXB

aAdd(aRot,{'Acerta Codigo do Fornecedor','u_xAltFor()',0,5 })  

Return aRot

//Grava fornecedor com fornecedor que nใo integrou no DDA
User Function xAltFor()

Processa({|| u_xAltDDA()}, "Atualizando Codigo Fornecedor...")
        
Return

User Function xAltDDA()

Local cCNPJ:= ""
Local cQuery:= ""
Local cQueryA:= ""
Local cQueryF:= ""
Local cQueryU:= ""
Local cQueryL:= ""


//Limpa codigo de fornecedores que importaram no CNPJ incorreto na Database
//Chamado  160814 - IMPLANTAR MULTIPAG DDA NA EMPRESA AGRICOPEL
If MsgYesNo("Esta rotina deve ser executada depois de efetuar a CONCILIACAO DO DIA. Deseja Abortar o Processo? ")

	Return(.T.)

Else
      
	cQueryL := " UPDATE " + RETSQLNAME("FIG")
	cQueryL += " SET FIG_FORNEC = '', FIG_LOJA = '', FIG_NOMFOR = '' "
	cQueryL += " WHERE D_E_L_E_T_ <> '*' "
	cQueryL += " AND FIG_DATA = '" +DTOS(DDATABASE)+ "' "
	cQueryL += " AND FIG_CONCIL = '2' "
	cQueryL += " AND FIG_DDASE2 = '' "
			
	TcSqlExec(cQueryL)  
	
Endif

//DDA capturado pela raiz do CNPJ do Fornecedor
cQuery := " SELECT DISTINCT substring(FIG_CNPJ,1,8) RAIZCNPJ, FIG_VALOR, FIG_VENCTO,"
cQuery += "(SELECT DISTINCT(COUNT(substring(FIG_CNPJ,1,8)))  FROM  " + RetSqlName("FIG") + " (NOLOCK) WHERE FIG_FORNEC = ''AND FIG_DDASE2 = '' AND D_E_L_E_T_ ='') AS QTDREG
cQuery += " FROM " + RetSqlName("FIG") + " (NOLOCK) "
cQuery += " WHERE FIG_FORNEC = '' "
cQuery += " AND FIG_DDASE2 = '' "
cQuery += " AND D_E_L_E_T_ =  '' "  
cQuery += " ORDER BY RAIZCNPJ  

If Select("DDA") <> 0
	dbSelectArea("DDA")
	DDA->(dbCloseArea())
Endif 

TCQuery cQuery NEW ALIAS "DDA"  


DbSelectArea("DDA")
DDA->(dbgotop())   
ProcRegua(DDA->QTDREG)
While DDA->(!eof())
	cQueryF:= ""
    
	IncProc("Raiz Cnpj: " + substr(DDA->RAIZCNPJ,1,8))
	
	//Capturo a raiz do CNPJ dos Fornecedores
	cQueryF := " SELECT *FROM " + RetSqlName("SA2") + " (NOLOCK) "
	cQueryF += " WHERE substring(A2_CGC,1,8)   =  '" +substring(RAIZCNPJ,1,8)+ "' "
	cQueryF += " AND D_E_L_E_T_ =  '' "

	If Select("FORN") <> 0
		dbSelectArea("FORN")
		FORN->(dbCloseArea())
	Endif	
	
	TCQuery cQueryF NEW ALIAS "FORN"

	DbSelectArea("FORN")
	FORN->(dbgotop())
    While FORN->(!eof())

		cQueryA:= ""
		
		cQueryA := " SELECT * FROM " + RetSqlName("SE2") + " (NOLOCK) "
		cQueryA += " WHERE E2_SALDO =  '" +cvaltochar(DDA->FIG_VALOR)+ "' "
		cQueryA += " AND E2_VENCREA =  '" +DDA->FIG_VENCTO+ "' "
		cQueryA += " AND E2_FORNECE =  '" +FORN->A2_COD+ "' "
		cQueryA += " AND E2_LOJA =  '" +FORN->A2_LOJA+ "' "
		cQueryA += " AND D_E_L_E_T_   =  ''  "
		
		If Select("TIT") <> 0
			dbSelectArea("TIT")
			TIT->(dbCloseArea())
		Endif		
		
		TCQuery cQueryA NEW ALIAS "TIT"
		
		DbSelectArea("TIT")
		TIT->(dbgotop())
		While TIT->(!eof())
			cQueryU:= ""
			
			cQueryU := " UPDATE " + RETSQLNAME("FIG")
			cQueryU += " SET FIG_FORNEC = '"+ TIT->E2_FORNECE +"', FIG_LOJA = '"+ TIT->E2_LOJA +"', FIG_NOMFOR = '"+ TIT->E2_NOMFOR +"' "
			cQueryU += " WHERE D_E_L_E_T_ <> '*' "
			cQueryU += " AND substring(FIG_CNPJ,1,8) = '"+DDA->RAIZCNPJ+"' "
			cQueryU += " AND FIG_FORNEC = '' "
			cQueryU += " AND FIG_DDASE2 = '' "
			cQueryU += " AND FIG_VENCTO =  '" +TIT->E2_VENCREA+ "' "
			cQueryU += " AND FIG_VALOR =  '" +cvaltochar(TIT->E2_SALDO)+ "' "
			
			TcSqlExec(cQueryU)
			
			TIT->(DbSkip())
		End
		
		FORN->(DbSkip())
	End
	
	DDA->(DbSkip())
End

Return(.T.)