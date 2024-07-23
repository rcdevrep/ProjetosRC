#INCLUDE "rwmake.ch" 
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
#INCLUDE "protheus.ch"


User Function AGX418()                             

	cPerg:= "AGX418"
	aRegistros := {}
	//AADD(aRegistros,{cPerg,"01","Tabela de Preço ?","mv_ch1","C",3,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""}) 
	AADD(aRegistros,{cPerg,"01","Fornecedor de   ?","mv_ch1","C",06,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","SA2"})	 
	AADD(aRegistros,{cPerg,"02","Fornecedor até  ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","SA2"})      
	AADD(aRegistros,{cPerg,"03","Produto de  ?"    ,"mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SB1"})    
    AADD(aRegistros,{cPerg,"04","Produto até ?"    ,"mv_ch4","C",15,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","SB1"})	 
    AADD(aRegistros,{cPerg,"05","Zona Armaz. ?"    ,"mv_ch5","C",06,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","DC4"})	 
	AADD(aRegistros,{cPerg,"06","Armazém     ?"    ,"mv_ch6","C",02,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","",""})	 
   

    U_CriaPer(cPerg,aRegistros)
	Pergunte(cPerg,.T.)

	IF MsgYesNo("Deseja Continuar ? ")
	   Processa({|| fInserePro2()}, "PRODUTOS")
       ApMsgInfo("Dados gerados com sucesso !")
   Else
      Alert("Operação Cancelada!")
   EndIf
Return()  


Static Function fInserePro2()
                                       
 
cQuery := ""
cQuery += "SELECT B1_COD,B1_DESC "
cQuery += "FROM " + RETSQLNAME("SB1") + " "
cQuery += "WHERE D_E_L_E_T_ <> '*' "
cQuery += "AND B1_FILIAL = '" + xFilial("SB1") + "' "   
cQuery += "AND B1_PROC BETWEEN '" + MV_PAR01 + "' AND '" +  mv_par02 + "' "
cQuery += "AND B1_COD BETWEEN '" + MV_PAR03 + "' AND '" +  mv_par04 + "' "     
cQuery += "AND NOT EXISTS(SELECT R_E_C_N_O_ FROM " +  RETSQLNAME("SB5") + " WHERE B5_COD = B1_COD "
cQuery += "AND B5_FILIAL = '" + xFilial("SB5") + "') "
//cQuery += "AND B1_SITUACA <> '2' "    
cQuery += "AND B1_LOCPAD = '" + MV_PAR06 + "' "



If (Select("QRY") <> 0)
	dbSelectArea("QRY")
	dbCloseArea()
Endif

cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "QRY"

dbSelectArea("QRY")
ProcRegua(500)
dbGoTop()
While !Eof()
	IncProc("Aguarde...") 

      Reclock("SB5",.T.)   
      SB5->B5_FILIAL := xFilial("SB5")
      SB5->B5_COD    := QRY->B1_COD
      SB5->B5_CEME   := QRY->B1_DESC
      SB5->B5_CODZON := MV_PAR05 
      SB5->B5_UMIND  := "1"   
      SB5->B5_NPULMAO :="1"
		SB5->(MsUnlock())         
		
    	dbSelectArea("QRY")
   	QRY->(dbSkip())
EndDo
Return()

