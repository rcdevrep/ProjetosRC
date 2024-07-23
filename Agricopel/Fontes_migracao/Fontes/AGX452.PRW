#include "rwmake.ch"
#include "colors.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
#INCLUDE "protheus.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX452    บAutor  ณRodrigo             บ Data ณ  06/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function AGX452()
PRIVATE oDlg    := Nil, oCon := Nil, oCan := Nil, oPar := Nil
	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ AJUSTE NO SX1                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cPerg := "AGX452"
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Arquivo SPED         ?","mv_ch1","C",30,0,0,"G","","mv_par01","","\sped\","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Data CTR de          ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Data CTR at้         ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	
	U_CriaPer(cPerg,aRegistros)
	
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	Processa({|| GeraArq()}, "Importando Arquivo SPED FISCAL! Aguarde...")	
	Processa({|| Gera150()}, "Regristro 0150...")	
	Processa({|| Gera200()}, "Regristro 0200...")	
	Processa({|| GeraD100()}, "Regristro D100/D190...")	
	Processa({|| GeraNovo()}, "Adicionando informa็๕es...")
	Processa({|| RefazTot()}, "Totalizando Registros...")			
	Processa({|| ImpArq()},  "Gerando novo arquivo...")	
	
Return()                                  



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX452IMP บAutor  ณMicrosiga           บ Data ณ  06/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Importa o arquivo do SPED FISCAL                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/



Static Function GeraArq()
LOCAL nLineLength := 200, nTabSize := 3, lWrap := .F. , nRec := 1
LOCAL nLines, nCurrentLine
Private cImp := .T.     	
	aImpArq  := {} 
	a0150    := {}   
	a0200    := {}  
	aD100    := {}
	aNovo    := {}
	cArq     := "" 
	
	Aadd(aImpArq,{"INFO"      ,"C",1000,0,"C"})     //INFO
	Aadd(aImpArq,{"REC"       ,"N",9999999,0,"C"})  //REC               
	Aadd(aImpArq,{"REG"       ,"C",6,0,"C"})        //REGISTRO
	
	
	Aadd(a0150,{"CLIFOR"      ,"C",1000,0,"C"})     //0150
	Aadd(a0150,{"COD"         ,"C",16,0,"C"})     //0150
	
	Aadd(a0200,{"PROD"        ,"C",1000,0,"C"})     //0200 - 0220      
	
	Aadd(aD100,{"D100"        ,"C",1000,0,"C"})     //D100
	
	Aadd(aNovo,{"NOVO"      ,"C",1000,0,"C"})     //Novo Arquivo
	
	
	/*BEGINDOC
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImporto o arquivo TXT do Sped Fiscal para manipula็ใo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ENDDOC*/
			
	If (Select("MIMPARQ") <> 0)
	dbSelectArea("MIMPARQ") 
		dbCloseArea()
	Endif
	cArq := CriaTrab(aImpArq,.T.)
	dbUseArea(.T.,,cArq,"MIMPARQ",.T.,.F.)	    

	/*BEGINDOC
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImporto o arquivo TXT do Sped Fiscal para manipula็ใo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ENDDOC*/
			
	If (Select("REG0150") <> 0)
	dbSelectArea("REG0150") 
		dbCloseArea()
	Endif
	cArq := CriaTrab(a0150,.T.)
	dbUseArea(.T.,,cArq,"REG0150",.T.,.F.)	
//	Indregua("REG0150",cArq,"CLIFOR",,,OemToAnsi("Selecionando Ordem..."))                     		   


	/*BEGINDOC
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImporto o arquivo TXT do Sped Fiscal para manipula็ใo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ENDDOC*/
			
	If (Select("REG0200") <> 0)
	dbSelectArea("REG0200") 
		dbCloseArea()
	Endif
	cArq := CriaTrab(a0200,.T.)
	dbUseArea(.T.,,cArq,"REG0200",.T.,.F.)	    
	
		/*BEGINDOC
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImporto o arquivo TXT do Sped Fiscal para manipula็ใo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ENDDOC*/
			
	If (Select("REGD100") <> 0)
	dbSelectArea("REGD100") 
		dbCloseArea()
	Endif
	cArq := CriaTrab(aD100,.T.)
	dbUseArea(.T.,,cArq,"REGD100",.T.,.F.)	 
	
	
	//*******************************************************

	If (Select("REGNOVO") <> 0)
	dbSelectArea("REGNOVO") 
		dbCloseArea()
	Endif
	cArq := CriaTrab(aNovo,.T.)
	dbUseArea(.T.,,cArq,"REGNOVO",.T.,.F.)	 
	    
    
    
    //*******************************************************

    nRec := 0
	Ft_fUse(mv_par01)                                
	ProcRegua(500)
	While !FT_FEof()
//		IncProc("Aguarde Importa็ใo...")
		IncProc(SUBSTR(FT_FReadLn() ,1,6))
		RecLock("MIMPARQ",.T.)
			MIMPARQ->INFO := FT_FReadLn()                         
			MIMPARQ->REC  := nRec	  
			MIMPARQ->REG  := SUBSTR(FT_FReadLn() ,1,6)		
		MsUnLock()                            
		
		
		
		
		If ALLTRIM(SUBSTR(FT_FReadLn() ,1,6)) == '|0150|'
		   RecLock("REG0150",.T.)                
		      REG0150->CLIFOR  := FT_FReadLn()                         		   
			  REG0150->COD     := SUBSTR(FT_FReadLn() ,7,13)
		   MsUnLock()
		EndIf
		If ALLTRIM(SUBSTR(FT_FReadLn() ,1,6)) == '|0200|' 
		   RecLock("REG0200",.T.)
		      REG0200->PROD := FT_FReadLn()
		   MsUnLock()		
		EndIf                                         
		
		If 	ALLTRIM(SUBSTR(FT_FReadLn() ,1,6)) == '|0220|'
		   RecLock("REG0200",.T.)
		      REG0200->PROD := FT_FReadLn()
		   MsUnLock()		
		EndIf 
		
   	    If 	ALLTRIM(SUBSTR(FT_FReadLn() ,1,6)) == '|D100|'
		   RecLock("REGD100",.T.)
		      REGD100->D100 := FT_FReadLn()
		   MsUnLock()		
		EndIf              
		
		
   	    If 	ALLTRIM(SUBSTR(FT_FReadLn() ,1,6)) == '|D190|'
		   RecLock("REGD100",.T.)
		      REGD100->D100 := FT_FReadLn()
		   MsUnLock()		
		EndIf 
	
		FT_FSkip()                                        
		
		nRec++
	EndDo          
	FT_fUse()
		
	/*BEGINDOC
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFim Importa็ใoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ENDDOC*/   
	cont := 0 
	dbSelectArea("REG0150")
	dbgotop()
	do while !eof() 
	   cont++
	   REG0150->(dbskip())
	enddo
		    
Return()                  



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGera150    บAutor  ณMicrosiga           บ Data ณ  06/30/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function Gera150()
Local cQuery := "" 

cQuery := "SELECT DISTINCT('|0150|SA1'+F3_FILIAL+F3_CLIEFOR+SPACE(5-LEN(F3_CLIEFOR))+F3_LOJA + '|'+ LTRIM(RTRIM(A1_NOME)) + '|01058|'+"
cQuery += "REPLICATE('0',(14 - Len(Cast(A1_CGC as Varchar)))) + Cast(A1_CGC as Varchar) + '|' + LTRIM(RTRIM(A1_INSCR)) + '||'+  "
cQuery += "CASE A1_EST WHEN 'SC' THEN '42' WHEN 'PR' THEN '41' END  + LTRIM(RTRIM(A1_COD_MUN)) + "
cQuery += "'|' + REPLACE(LTRIM(RTRIM(A1_END)),',','|') + '||' + LTRIM(RTRIM(A1_BAIRRO)) + '|') R0150"
cQuery += " FROM " + RetSqlName("SF3") + " F3," + RetSqlName("SA1") + " A1 " 
cQuery += " WHERE  F3_FILIAL = '" + xFilial("SF3") + "' " 
cQuery += " AND F3.D_E_L_E_T_ <> '*' "
cQuery += " AND F3.F3_SERIE = 'U' " 
cQuery += " AND F3_EMISSAO BETWEEN '" + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "' "
cQuery += " AND A1_FILIAL = '" + xFilial("SA1") + "' " 
cQuery += " AND A1_COD = F3_CLIEFOR AND A1_LOJA = F3_LOJA AND SUBSTRING(F3_CFO,1,1) IN('5','6') "
cQuery += " AND A1.D_E_L_E_T_ <> '*'


If Select("QRY150") <> 0
	dbSelectArea("QRY150")
	dbCloseArea()
Endif

TCQuery cQuery NEW ALIAS "QRY150"

dbSelectArea("QRY150")
dbGotop()
While !eof()
   cCliFor := "" 
   cCliFor := SubStr(QRY150->R0150,7,13) 
   dbSelectArea("REG0150")
  	   RecLock("REG0150",.T.)   
          REG0150->CLIFOR := QRY150->R0150
       MsUnlock()
   dbSelectArea("QRY150")
   QRY150->(dbSkip())       
EndDo

Return()




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGera200    บAutor  ณMicrosiga           บ Data ณ  06/30/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function Gera200()
Local cQuery := ""  

cQuery := "SELECT DISTINCT('|0200|' + LTRIM(RTRIM(D2_COD)) + SPACE(15-LEN(LTRIM(RTRIM(D2_COD)))) + LTRIM(RTRIM(D2_FILIAL)) + '|' +LTRIM(RTRIM(B1_DESC)) + '||' + "
cQuery += "LTRIM(RTRIM(D2_COD)) + '|' + LTRIM(RTRIM(D2_UM)) + '|09|' + LTRIM(RTRIM(B1_POSIPI)) + '||99||' + LTRIM(RTRIM(CAST(D2_PICM AS CHAR(2)))) + ',00|') R0200 "
cQuery += "FROM " + RetSqlName("SD2") + " D2, " +  RetSqlName("SB1") + " B1 "
cQuery += "WHERE D2_FILIAL = '" + xFilial("SD2") + " ' " 
cQuery += " AND D2.D_E_L_E_T_ <> '*' " 
cQuery += " AND D2_SERIE = 'U' "
cQuery += " AND D2_EMISSAO BETWEEN '"  + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "' "   
cQuery += " AND B1_FILIAL = '" + xFilial("SB1") + "' " 
cQuery += " AND B1_COD =  D2_COD    AND B1.D_E_L_E_T_ <> '*'  AND SUBSTRING(D2_CF,1,1) IN('5','6') "  


If Select("QRY200") <> 0
	dbSelectArea("QRY200")
	dbCloseArea()
Endif

TCQuery cQuery NEW ALIAS "QRY200"

dbSelectArea("QRY200")
dbGotop()
While !eof()
   cExist := .F.           
   dbSelectArea("REG0200")
   dbGoTop()
   While !eof()
      If AllTrim(SUBSTR(QRY200->R0200,7,17)) == ALLTRIM(SUBSTR(REG0200->PROD,7,17))
         cExist := .T.
      EndIf   
      REG0200->(dbSkip())
   EndDo   
   If !cExist 
	   RecLock("REG0200",.T.)   
          REG0200->PROD := QRY200->R0200
       MsUnlock() 
   EndIf     
       
   dbSelectArea("QRY200")
   QRY200->(dbSkip())       
EndDo

Return() 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGERAD100    บAutor  ณMicrosiga           บ Data ณ  07/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/    


Static Function GeraD100()
Local cQuery := ""  

cQuery := " SELECT '|D100|1|0|SA1'+F3_FILIAL+F3_CLIEFOR+SPACE(5-LEN(F3_CLIEFOR))+F3_LOJA+'|08|00|'+LTRIM(RTRIM(F3_SERIE)) + '||'+LTRIM(RTRIM(F3_NFISCAL))+ " 
cQuery += "'||' + SUBSTRING(F3_EMISSAO,7,2)+SUBSTRING(F3_EMISSAO,5,2)+SUBSTRING(F3_EMISSAO,1,4)+ "
cQuery += " + '|0|1|' + REPLACE(CAST(F3_VALCONT AS CHAR(15)),'.',',') + '|' + REPLACE(CAST(F3_BASEICM AS CHAR(15)),'.',',')+'|'+ " 
cQuery += " REPLACE(CAST(F3_VALICM AS CHAR(15)),'.',',')+'|'+REPLACE(CAST(F3_ISENICM AS CHAR(15)),'.',',') + '||'+ "
cQuery += " LTRIM(RTRIM((SELECT D2_CONTA FROM SD2010 WHERE D2_DOC = F3_NFISCAL AND D2_SERIE = F3_SERIE AND D2_CLIENTE = F3_CLIEFOR AND " 
cQuery += " D2_LOJA = F3_LOJA AND D2_FILIAL = F3_FILIAL AND SD2010.D_E_L_E_T_ <> '*'))) + '|' D100, " 
cQuery += " '|D190|'+  LTRIM(RTRIM((SELECT D2_CLASFIS FROM SD2010 WHERE D2_DOC = F3_NFISCAL AND D2_SERIE = F3_SERIE AND D2_CLIENTE = F3_CLIEFOR AND "
cQuery += " D2_LOJA = F3_LOJA AND D2_FILIAL = F3_FILIAL AND SD2010.D_E_L_E_T_ <> '*'))) + '|' + F3_CFO + '|' + CAST(F3_ALIQICM AS CHAR(2)) + '|' + " 
cQuery += " REPLACE(CAST(F3_BASEICM AS CHAR(15)),'.',',')+'|'+ "
cQuery += " REPLACE(CAST(F3_VALICM AS CHAR(15)),'.',',')+'|0||' D190 " 
cQuery += " FROM " + RetSqlName("SF3") + "  " 
cQuery += " WHERE  F3_FILIAL = '" + xFilial("SF3") + " ' " 
cQuery += "  AND   D_E_L_E_T_ <> '*' " 
cQuery += "  AND F3_SERIE = 'U' " 
cQuery += "  AND F3_EMISSAO BETWEEN '"  + dtos(mv_par02) + "' AND '" + dtos(mv_par03) + "' "   
cQuery += "  AND SUBSTRING(F3_CFO,1,1) IN('5','6')
cQuery += "  ORDER BY F3_ENTRADA " 
  
If Select("QRYD100") <> 0
	dbSelectArea("QRYD100")
	dbCloseArea()
Endif

TCQuery cQuery NEW ALIAS "QRYD100"

dbSelectArea("QRYD100")
dbGoTop()
While !eof()   
   IncProc(SUBSTR(QRYD100->D100,1,15))
   RecLock("REGD100" ,.T.)
       REGD100->D100 := QRYD100->D100
   MsUnlock()
   RecLock("REGD100" ,.T.)
       REGD100->D100 := QRYD100->D190
   MsUnLock()
   dbSelectArea("QRYD100")
   QRYD100->(dbSkip())
EndDo


Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX452    บAutor  ณMicrosiga           บ Data ณ  07/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function GeraNovo()
Local l0150 := .f., l0200 := .f. , lD100 := .f.
dbSelectArea("MIMPARQ")
dbGoTop()
While !eof()


   If SUBSTR(MIMPARQ->INFO,1,6) <> "|0150|" .and. ;
      SUBSTR(MIMPARQ->INFO,1,6) <> "|0200|"   .and. SUBSTR(MIMPARQ->INFO,1,6) <> "|0220|" .and. ;
      SUBSTR(MIMPARQ->INFO,1,6) <> "|D100|"   .and. SUBSTR(MIMPARQ->INFO,1,6) <> "|D190|"    
      IncProc(MIMPARQ->INFO)
   	  RecLock("REGNOVO",.T.)  
	     REGNOVO->NOVO := MIMPARQ->INFO
      MsUnlock()
   EndIf

   If SUBSTR(MIMPARQ->INFO,1,6) == "|0150|"  .and. l0150 == .F.
      dbSelectArea("REG0150")
      dbGoTop()
      While !eof()                       
         RecLock("REGNOVO" , .T. ) 
            REGNOVO->NOVO := REG0150->CLIFOR
         MsUnLock()
         dbSelectArea("REG0150")
         REG0150->(dbskip())             
      EndDo                        
      l0150 := .T.
   EndIf
   
   If SUBSTR(MIMPARQ->INFO,1,6) == "|0200|"  .and. l0200 == .F.
      dbSelectArea("REG0200")
      dbGoTop()
      While !eof()                       
         RecLock("REGNOVO" , .T. ) 
            REGNOVO->NOVO := REG0200->PROD
         MsUnLock()
         dbSelectArea("REG0200")
         REG0200->(dbskip())             
      EndDo                        
      l0200 := .T.
   EndIf
   
   If SUBSTR(MIMPARQ->INFO,1,6) == "|D100|"  .and. lD100 == .F.
      dbSelectArea("REGD100")
      dbGoTop()
      While !eof()                       
         RecLock("REGNOVO" , .T. ) 
            REGNOVO->NOVO := REGD100->D100
         MsUnLock()
         dbSelectArea("REGD100")
         REGD100->(dbskip())             
      EndDo                        
      lD100 := .T.
   EndIf   
   dbselectarea("MIMPARQ")
   MIMPARQ->(dbskip())
   
EndDo

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX452    บAutor  ณMicrosiga           บ Data ณ  07/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/



Static Function RefazTot()
Local n0990 := 0, nC990 := 0, nD990 := 0
Local n0150 := 0, n0200 := 0, nD100:= 0, nD190 := 0,nTotGer :=0


dbSelectArea("REGNOVO")
dbGoTop() 
While !eof()  
    nTotGer++
    
	If SUBSTR(REGNOVO->NOVO,1,2) == "|0"
	   n0990++
	EndIf    
	
	If SUBSTR(REGNOVO->NOVO,1,2) == "|C"
	   nC990++
	EndIf
	
	
	If SUBSTR(REGNOVO->NOVO,1,2) == "|D"
	   nD990++
	EndIf
	
	
	If SUBSTR(REGNOVO->NOVO,1,6) == "|0150|"
	   n0150++
	EndIf   
	
	
	If SUBSTR(REGNOVO->NOVO,1,6) == "|0200|"
	   n0200++
	EndIf 
	        
	If SUBSTR(REGNOVO->NOVO,1,6) == "|D100|"
	   nD100++
	EndIf   
	
	If SUBSTR(REGNOVO->NOVO,1,6) == "|D190|"
	   nD190++
	EndIf   
	                                        
	If SUBSTR(REGNOVO->NOVO,1,6) == "|0990|"	
	   RecLock("REGNOVO", .F.)
		   REGNOVO->NOVO := "|0990|" + ALLTRIM(STR(INT(n0990))) + "|" 
       MsUnlock()
	EndIf
	
	If SUBSTR(REGNOVO->NOVO,1,6) == "|C990|"
	   RecLock("REGNOVO", .F.)	
		   REGNOVO->NOVO := "|C990|" + ALLTRIM(STR(INT(nC990))) + "|" 
	   MsUnlock()
	EndIf
	
	If SUBSTR(REGNOVO->NOVO,1,6) == "|D990|"	
	   RecLock("REGNOVO", .F.)
		   REGNOVO->NOVO := "|D990|" + ALLTRIM(STR(INT(nD990))) + "|" 
       MsUnlock()
	EndIf                                            
	
		
	If SUBSTR(REGNOVO->NOVO,1,11) == "|9900|0150|"	
   	   RecLock("REGNOVO", .F.)
		   REGNOVO->NOVO := "|9900|0150|" + ALLTRIM(STR(INT(n0150))) + "|" 
	   MsUnLock()
	EndIf                                            
	

	If SUBSTR(REGNOVO->NOVO,1,11) == "|9900|0200|"	  
   	   RecLock("REGNOVO", .F.)
		   REGNOVO->NOVO := "|9900|0200|" + ALLTRIM(STR(INT(n0200))) + "|" 
	   MsUnLock()
	EndIf                                            	     
	

	If SUBSTR(REGNOVO->NOVO,1,11) == "|9900|D100|"	
   	   RecLock("REGNOVO", .F.)
		   REGNOVO->NOVO := "|9900|D100|" + ALLTRIM(STR(INT(nD100))) + "|" 
       MsUnLock()
	EndIf                                            	
	

	If SUBSTR(REGNOVO->NOVO,1,11) == "|9900|D190|"	
   	   RecLock("REGNOVO", .F.)
		   REGNOVO->NOVO := "|9900|D190|" + ALLTRIM(STR(INT(nD190))) + "|" 
	   MsUnLock()
	EndIf                                            	                               
	
   
	If SUBSTR(REGNOVO->NOVO,1,6) == "|9999|"	
	   RecLock("REGNOVO", .F.)
		   REGNOVO->NOVO := "|9999|" + ALLTRIM(STR(INT(nTotGer))) + "|" 
	   MsUnLock()
	EndIf                                            
	
	
    REGNOVO->(dbSkip())
	        
EndDo


Return()





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX452150 บAutor  ณRodrigo             บ Data ณ  06/30/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Separa็ใo do Registro 0150                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                       


Static Function ImpArq()
Local nCont    := ""
Local nStatus1 := ""                                   
    nStatus1 := frename(alltrim(mv_par01) , alltrim(mv_par01) + "_old" )
    IF nStatus1 == -1   
       MsgStop('Falha na opera็ใo 1 : FError '+str(ferror(),4)) 
    Endif


   	cArquivo := ALLTRIM(mv_par01)  
	nHandle  := 0

	If !File(cArquivo)
		nHandle := MSFCreate(cArquivo)
	Else
		fErase(cArquivo)
		nHandle := MSFCreate(cArquivo)
	Endif
//    alert("entrou no imparq")
    cLinha := ""
 	dbSelectArea("REGNOVO")
	dbgotop() 
	While !Eof()                    
		cLinha := ALLTRIM(REGNOVO->NOVO) + chr(13)+chr(10)
		FWrite(nHandle,cLinha,Len(cLinha)) 
	    REGNOVO->(dbskip())
	EndDo                                                    
	fClose(nHandle)	  
           
Return()



//taize.rh@hotmail.com
