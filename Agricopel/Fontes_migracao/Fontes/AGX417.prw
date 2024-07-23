#INCLUDE "rwmake.ch" 
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
#INCLUDE "protheus.ch"

User Function AGX417()                             

	cPerg:= "AGX417"
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Tabela de Preço ?","mv_ch1","C",3,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""}) 
	AADD(aRegistros,{cPerg,"02","Fornecedor de   ?","mv_ch2","C",06,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","SA2"})	 
	AADD(aRegistros,{cPerg,"03","Fornecedor até  ?","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SA2"})      
	AADD(aRegistros,{cPerg,"04","Produto de  ?"    ,"mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SB1"})    
    AADD(aRegistros,{cPerg,"05","Produto até ?"    ,"mv_ch5","C",15,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","SB1"})	 

   //U_CriaPer(cPerg,aRegistros)
	Pergunte(cPerg,.T.)

	IF MsgYesNo("Deseja Continuar ? ")
	   Processa({|| fInserePro()}, "PRODUTOS")
      ApMsgInfo("Dados gerados com sucesso !")
   Else
      Alert("Operação Cancelada!")
   EndIf

Return()

Static Function fInserePro()

/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pego o ultimo item da tabela de preço para realizar incremento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/

cQuery := ""
cQuery += "SELECT MAX(DA1_ITEM) ITEM FROM " + RETSQLNAME("DA1") +" "      
cQuery += "WHERE DA1_FILIAL = '" + xFilial("DA1") + "' "    
cQuery += "AND DA1_CODTAB = '" + mv_par01 + " ' "
cQuery += "AND D_E_L_E_T_ <> '*' "

If (Select("QRY") <> 0)
	dbSelectArea("QRY")
	dbCloseArea()
Endif

cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "QRY"  

dbSelectArea("QRY")
dbGoTop()

_cItem := QRY->ITEM                               


/*cQuery := ""
cQuery += "SELECT B1_COD "
cQuery += "FROM " + RETSQLNAME("SB1") + " "
cQuery += "WHERE D_E_L_E_T_ <> '*' "
cQuery += "AND B1_FILIAL = '" + xFilial("SB1") + "' "   
cQuery += "AND B1_PROC BETWEEN '" + MV_PAR02 + "' AND '" +  mv_par03 + "' "
cQuery += "AND B1_COD BETWEEN '" + MV_PAR04 + "' AND '" +  mv_par05 + "' "     
cQuery += "AND NOT EXISTS(SELECT R_E_C_N_O_ FROM " +  RETSQLNAME("DA1") + " WHERE DA1_CODTAB = '" + mv_par01 + " ' "
cQuery += "AND DA1_FILIAL = '" + xFilial("DA1") + "' AND D_E_L_E_T_ <> '*' AND DA1_CODPRO = B1_COD) "
cQuery += "AND B1_SITUACA <> '2' "*/

cQuery := ""
cQuery += "SELECT B1_COD, B1_DESC, B2_QATU FROM SB2010, SB1010 WHERE B2_LOCAL = '02' AND B2_FILIAL ='06' AND SB1010.D_E_L_E_T_ <>'*'  AND SB2010.D_E_L_E_T_ <>'*' "
cQuery += "AND NOT EXISTS (SELECT R_E_C_N_O_ FROM DA1010 WHERE DA1_FILIAL ='06' AND DA1_CODTAB = '001' AND D_E_L_E_T_ <>'*' AND DA1_CODPRO = B2_COD ) " 
cQuery += "AND B1_COD = B2_COD AND B1_FILIAL = B1_FILIAL AND B2_QATU > 0 ORDER BY B1_DESC "
        

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
      _cItem := Soma1(_cItem)	
      Reclock("DA1",.T.) 
      DA1->DA1_FILIAL  := xFilial("DA1")       
      DA1->DA1_CODTAB  := mv_par01   
      DA1->DA1_ITEM    := alltrim(_cItem) 
  	  DA1->DA1_CODPRO  := QRY->B1_COD
	  DA1->DA1_TPOPER  := "4"
	  DA1->DA1_MOEDA   := 1
	  DA1->DA1_DATVIG  := date()   
	  DA1->DA1_PRCVEN  := 0.01        
	  DA1->DA1_ATIVO   := '1'
      DA1->DA1_QTDLOT  := 999999.99
      DA1->DA1_INDLOT  := '000000000999999.99'
		DA1->(MsUnlock())         
	  //	alert(STR(VAL(_cItem) + 1))

    	dbSelectArea("QRY")
   	QRY->(dbSkip())
EndDo
Return()