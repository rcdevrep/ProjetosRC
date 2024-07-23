#include'Protheus.ch'
#INCLUDE "RPTDEF.CH"  
#include "Fileio.ch"
#include "Topconn.ch"
#INCLUDE "TBICONN.CH"

User Function 095TESTE(xAlias)   

	Private aEmpresas := {}
	Default xAlias := ""

	cQuery := " SELECT "
	cQuery += "  EMP_COD "
	cQuery += " FROM EMPRESAS "
	cQuery += " GROUP BY EMP_COD
	//cQuery += " WHERE INTEGRA_DBGINT = 'S' " 
	
	TCQuery cQuery NEW ALIAS 'TEMPSM0'

	WHILE TEMPSM0->(!eof())
		AADD(aEmpresas,TEMPSM0->EMP_COD )
		TEMPSM0->(dbskip())
	Enddo


	For i := 1 to len(aEmpresas)
		PREPARE ENVIRONMENT Empresa aEmpresas[i] Filial '01' Tables "SA1"
		//PREPARE ENVIRONMENT Empresa '01' Filial '01' Tables "SA1","SA2","SB1","SF1","SD1","SF3","SE2","SF4","SX5","XXS"
			RPCSetType(1)
			RPCSetEnv(aEmpresas[i], '01')

			cEmpant := aEmpresas[i]
			cFilAnt := '01'

			If xAlias <> ""
				DBSELECTAREA(xAlias)
			Endif

			//DBSELECTAREA('SEA')

			//RPCClearEnv()
			//dbCloseAll()
		RESET ENVIRONMENT
	Next i 


return
/*
	Local _cPath :='\IMPBOLETO\'//"C:\IMPBOLETO\"
	*/
    //Descomentar para Utilizar Diretório no servidor
    //cPath :="c:\IMPBOLETO\"
	alert(_cPath)
	oFont20:= TFont():New( "Arial Black"   ,,15,,.f.,,,,,.T. )

    MakeDir(Trim(Upper(_cPath))) 
	CONOUT('XABLAW')
	alert(IMP_PDF)

	cFile := "03NF_TESTEM"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)+".Rel"
	//oPrn  := FWMSPrinter():New(cFile,IMP_PDF,.T.,_cPath/*AQUI*/,.T., , , ,.T. ) TESTES 1 E 2 
	oPrn  := FWMSPrinter():New(cFile,IMP_PDF,.T.,_cPath/*AQUI*/,.T., , , ,.T. ) 
    oPrn:StartPage() 
	oPrn:Say( 500, 0640, 'TESTANDO'		,oFont20,100)
	oPrn:EndPage()

	//oPrn:lServer  := .T. 
	oPrn:cPathPDF :='\IMPBOLETO\'  
	oPrn:SetDevice ( IMP_PDF ) 
	oPrn:SetPortrait() 
	oPrn:SetPaperSize(9)
	oPrn:SetViewPDF(.F.)	
	oPrn:Preview()
	SetPgEject(.F.)
	MS_Flush() 

	//CpyT2S( _cPath+cFile+".PDF", "\IMPBOLETO", .F. )
	//cteste := FILE("\IMPBOLETO\"+cFile+".PDF")
	//ALERT(CTESTE)
	conout('Fim')


	/*TESTE 1
	_cPath :='C:\IMPBOLETO\
	oPrn:cPathPDF :='\IMPBOLETO\'
	.REL EM AMBOS

	TESTE 2 
	_cPath :='\IMPBOLETO\'
	oPrn:cPathPDF :='C:\IMPBOLETO\'
	.PDF EM C:\IMPBOLETO\
	*/




Return

user function 095TEST1()
  
    local nHandle := FCREATE("\IMPBOLETO\Testfile.pdf")
  
    if nHandle = -1
        conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
    else
        FWrite(nHandle, Time() + CRLF)
        FClose(nHandle)
    endif
 
return