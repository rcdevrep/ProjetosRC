#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma   ³AGR094    º Autor ³ Jean Sérgio Vieira º Data ³  25/11/03   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Gerar arquivo texto para emissao de boleto  Banco Brasil   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Arquivos   ³  SA1 - SE1 - SA6                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes ³                                                            ³±±
±±³Necessarias³                                                            ³±±
±±³           ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AGR094
LOCAL cString 	:= "TRB"
LOCAL aStru    := {}
LOCAL cNomCli	:= space(40)
PRIVATE cPerg     := ""
PRIVATE cBanco,cAgencia,xConteudo
PRIVATE nHdlBco   := 0
PRIVATE nHdlSaida := 0
PRIVATE nSeq      := 0
PRIVATE nSomaValor:= 0
PRIVATE aRotina   := { {OemToAnsi("Gerar Arquivo") , "U_A094Gera" , 0 , 0 } }  // "Gerar Arquivo"
PRIVATE nBorderos := 0
PRIVATE xBuffer,nLidos := 0
PRIVATE nTotCnab2 := 0 // Contador de Lay-out nao deletar
PRIVATE nLinha 	:= 0 // Contador de Linhas nao deletar 
PRIVATE nNossoNum	:= 0 // Contador de Linhas nao deletar 
PRIVATE nNossoNumE1 := 0 // Contador de Linhas nao deletar 

DbSelectArea("SM0")   
        
//Mensagem de Rotina descontinuada, será utilizada apenas a AGR095	                    
If cEmpant == '01' .or. dtos(ddatabase) >= '20180926'
	Alert('Rotina descontinuada, em caso de dúvidas, entre em contato com a TI! ')     
    Return
Endif     


//Spiller - 12/02/2018
If (cEmpant == '01' .and. cFilAnt <> '03') .or. cEmpant <> '01'
     Alert('Essa rotina só pode ser utilizada pela Filial 03, entre em contato com a TI!')
	 Return	
Endif


cPerg := "AGR094"
If SM0->M0_CODIGO == "01"
	Do Case
		// Se for Filial Agricopel Matriz/Mime Distrib.
		Case SM0->M0_CODFIL == "01" .OR. SM0->M0_CODFIL == "06"
			cPerg := "AGR94A"
		// Se for Filial Agricopel Pien
		Case SM0->M0_CODFIL == "02"
			cPerg := "AGR94B"
		// Se for Filial Agricopel Filial II 
		Case SM0->M0_CODFIL == "03"
			cPerg := "AGR94C"				
	EndCase		
EndIf

PRIVATE cCadastro := OemToAnsi("Comunicação Bancária-Envio")  // "Comunica‡„o Banc ria-Envio"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Do Prefixo                           ³ 
//³ mv_par02             // Ate o Prefixo                        ³ 
//³ mv_par03             // Do Titulo                            ³ 
//³ mv_par04             // Ate o Titulo                         ³ 
//³ mv_par05             // Da Emissao                           ³ 
//³ mv_par06             // Ate a Emissao                        ³ 
//³ mv_par07             // Do Cliente                           ³ 
//³ mv_par08             // Ate o Cliente                        ³ 
//³ mv_par09             // Da Loja                              ³ 
//³ mv_par10             // Ate a Loja                           ³ 
//³ mv_par11		 		 // Arq.Config 		  						  ³
//³ mv_par12		 		 // Arq. Saida    	   					  ³
//³ mv_par13             // Banco                                ³
//³ mv_par14             // Agencia                              ³
//³ mv_par15             // Conta                                ³
//³ mv_par16             // Sub-Conta                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRegistros := {}
AADD(aRegistros,{cPerg,"01","Serie De          ?","mv_ch1","C",3,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Serie Ate         ?","mv_ch2","C",3,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"03","Nota De           ?","mv_ch3","C",TamSX3("F2_DOC")[1],0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Nota Ate          ?","mv_ch4","C",TamSX3("F2_DOC")[1],0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"05","Emissao De        ?","mv_ch5","D",8,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"06","Emissao Ate       ?","mv_ch6","D",8,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"07","Cliente De        ?","mv_ch7","C",6,0,0,"G","","mv_par07","","","","","","","","","","","","","","","CLI"})
AADD(aRegistros,{cPerg,"08","Cliente Ate       ?","mv_ch8","C",6,0,0,"G","","mv_par08","","","","","","","","","","","","","","","CLI"})
AADD(aRegistros,{cPerg,"09","Loja De           ?","mv_ch9","C",2,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"10","Loja Ate          ?","mv_ch10","C",2,0,0,"G","","mv_par10","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"11","Arq. Configuração ?","mv_ch11","C",20,0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"12","Arq. Saída        ?","mv_ch12","C",50,0,0,"G","","mv_par12","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"13","Banco		       ?","mv_ch13","C",3,0,0,"G","","mv_par13","","","","","","","","","","","","","","","SA6"})
AADD(aRegistros,{cPerg,"14","Agencia   	       ?","mv_ch14","C",5,0,0,"G","","mv_par14","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"15","Conta        	   ?","mv_ch15","C",10,0,0,"G","","mv_par15","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"16","Sub-Conta         ?","mv_ch16","C",3,0,0,"G","","mv_par16","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"17","Carteira          ?","mv_ch17","C",6,0,0,"G","","mv_par17","","","","","","","","","","","","","","",""})

//CriaPer(cPerg,aRegistros)
U_CriaPer(cPerg,aRegistros)

If !Pergunte(cPerg, .T.)
	Return
Endif

aAdd(aStru,{"OK"	,"C",02,00})
aAdd(aStru,{"DOC"	,"C",TamSX3("F2_DOC")[1],00})
aAdd(aStru,{"SERIE"	,"C",03,00})
aAdd(aStru,{"CLIENTE","C",06,00})
aAdd(aStru,{"LOJA"	,"C",02,00})
aAdd(aStru,{"NOMECLI","C",40,00})
aAdd(aStru,{"EMISSAO","D",08,00})

aCampos := { {"OK"		,".T.","  "     		,"@!"},;
				 {"DOC"		,".T.","Doc"    		,"@!"},;
				 {"SERIE"	,".T.","Serie"			,"@!"},;
				 {"CLIENTE"	,".T.","Cliente"		,"@!"},;
				 {"LOJA"		,".T.","Loja"   		,"@!"},;
				 {"NOMECLI"	,".T.","Nome Cliente","@!"},;
				 {"EMISSAO"	,".T.","Dt. Emissão"	,"@!"} }

if Select('TRB') # 0
	dbSelectArea('TRB')
	dbCloseArea()
endif
cArq := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cArq,cString,.T.)
cInd := CriaTrab(NIL,.F.)
IndRegua(cString,cInd,"SERIE+DOC+CLIENTE+LOJA",,,"Selecionando Registros...")

	
cQuery := ""
cQuery := "SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO "
cQuery += "FROM " + RetSqlName("SF2") + " (NOLOCK) F2 " 
//Spiller - Trava para nao mostrar Títulos de outros portadores
cQuery += " LEFT JOIN " + RetSqlName("SE1") + " (NOLOCK) E1 ON E1_FILIAL = '' AND "
cQuery += "						E1_CLIENTE = F2_CLIENTE AND "
cQuery += "						E1_LOJA   = F2_LOJA AND "
cQuery += "						E1_PREFIXO = '"+xfilial('SF2')+"'+Substring(LTRIM(F2_SERIE),1,1) AND "
cQuery += "						E1_NUM = F2_DOC AND "
cQuery += "					 	E1.D_E_L_E_T_ = '' "  
//Fim   
//Spiller - Trava para nao mostrar Títulos com notas NÃO autorizadas no NfeSEfaz
cQuery += "LEFT JOIN "  + RetSqlName("SF3") + " (NOLOCK) F3 ON F3_NFISCAL = F2_DOC AND F3_SERIE = F2_SERIE AND F2_FILIAL = F3_FILIAL "
cQuery += "AND F2_CLIENTE = F3_CLIEFOR AND F2_LOJA = F3_LOJA and F3.D_E_L_E_T_ = '' "            
//Fim
cQuery += "WHERE F2.D_E_L_E_T_ <> '*' "
cQuery += "AND F2_FILIAL = '" + xFilial("SF2") + "' "
cQuery += "AND F2_EMISSAO >= '" + DTOS(mv_par05) + "' "
cQuery += "AND F2_EMISSAO <= '" + DTOS(mv_par06) + "' "
cQuery += "AND F2_SERIE >= '" + mv_par01 + "' "
cQuery += "AND F2_SERIE <= '" + mv_par02 + "' "
cQuery += "AND F2_DOC >= '" + mv_par03 + "' "
cQuery += "AND F2_DOC <= '" + mv_par04 + "' "
cQuery += "AND F2_CLIENTE >= '" + mv_par07 + "' "
cQuery += "AND F2_CLIENTE <= '" + mv_par08 + "' "
cQuery += "AND F2_LOJA >= '" + mv_par09 + "' "
cQuery += "AND F2_LOJA <= '" + mv_par10 + "' "
cQuery += "AND F2_COND <> '001' "   
//Spiller - Trava para nao mostrar Títulos de outros portadores
//cQuery += "AND (E1_PORTADO =  '"+mv_par13+"' OR E1_PORTADO = '' ) AND E1_ZNBANCO = '' "    
cQuery += "AND ( ( E1_PORTADO =  '"+mv_par13+"' AND E1_CONTA ='"+mv_par15+"') OR E1_PORTADO = '' ) AND E1_ZNBANCO = '' " 
//Spiller - Trava para nao mostrar Títulos com notas NÃO autorizadas no NfeSEfaz
cQuery += " AND (F3_CODRSEF = '100' OR  F3_CODRSEF = ''  OR  F3_CODRSEF IS NULL ) "
//Fim
cQuery += "GROUP BY F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO "
//Fim
cQuery += "ORDER BY F2_FILIAL, F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA "

If Select("MSF2") <> 0
	dbSelectArea("MSF2")
	dbCloseArea()
Endif
TCQuery cQuery NEW ALIAS "MSF2"
TCSetField("MSF2","F2_EMISSAO","D",08,0)
            
dbSelectArea("MSF2")
dbGoTop()
While !Eof()  
	cNomCli := space(40)
	dbSelectArea("SA1")
	dbSetOrder(1)
	if dbSeek(xFilial("SA1")+MSF2->F2_CLIENTE+MSF2->F2_LOJA)
		cNomCli := SA1->A1_NOME	
	endif

	dbSelectArea("TRB")
	RecLock("TRB",.T.)
	TRB->DOC		:= MSF2->F2_DOC
	TRB->SERIE	:= MSF2->F2_SERIE
	TRB->CLIENTE:= MSF2->F2_CLIENTE
	TRB->LOJA	:= MSF2->F2_LOJA
	TRB->NOMECLI:= cNomCli
	TRB->EMISSAO:= MSF2->F2_EMISSAO
	TRB->(MsUnlock())//'TRB')

	dbSelectArea("MSF2")
   DbSkip()
EndDo

dbSelectArea(cString)
dbGotop()
cMarca := GetMark()
MarkBrow(cString,'OK',,aCampos,, cMarca,'ExecBlock("A094All",.f.,.f.)',,,,'ExecBlock("A094Mark",.f.,.f.)')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha os Arquivos ASC II                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FCLOSE(nHdlBco)
FCLOSE(nHdlSaida)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AGR094Gera³ Autor ³ Wagner Xavier         ³ Data ³ 25/11/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Comunica‡„o Banc ria - Envio  Banco Brasil                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AGR094Gera(cAlias)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ AGR094                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function A094Gera(cAlias)
Processa({|lEnd| A094Ger(cAlias)})  // Chamada com regua
dbSelectArea("TRB")
dbGotop()
nBorderos  := 0
nSeq		  := 0
nSomaValor := 0 
CloseBrowse()
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AGR094Ger ³ Autor ³ Wagner Xavier         ³ Data ³ 26/05/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Comunica‡„o Banc ria - Envio Banco Brasil                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AGR094Ger()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ AGR094                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A094Ger(cAlias)
LOCAL cSav7,cSav20,cSavCur,nPosAtu:=0,nPosAnt:=0,nTotRegs:=0,nPosCnt:=0
LOCAL nTamArq:=0,lResp:=.t.
LOCAL lHeader:=.F.,lFirst:=.F.,cSaveMenuh
LOCAL nTam,nDec,nUltDisco:=0,nGrava:=0,aBordero:={}
LOCAL nSavRecno := recno()
Local cDbf
Local lFinCnab2  := .F.
LOCAL oDlg,oBnt,oBmp,nMeter := 1
LOCAL cTexto := "CNAB"
LOCAL lFirstBord := .T.
LOCAL lAchouBord := .F.

LOCAL cNumBorAnt //:= Iif(mv_par13 == "001","BB",Iif(mv_par13 == "237","BR",Iif(mv_par13 == "027","BS","OU")))+StrZero(Day(dDatabase),2)+StrZero(Month(dDatabase),2)

cMes := Space(01)
Do Case 
	Case StrZero(Month(dDatabase),2) == "01"
		cMes := "A"
	Case StrZero(Month(dDatabase),2) == "02"
		cMes := "B"
	Case StrZero(Month(dDatabase),2) == "03"
		cMes := "C"
	Case StrZero(Month(dDatabase),2) == "04"
		cMes := "D"
	Case StrZero(Month(dDatabase),2) == "05"
		cMes := "E"
	Case StrZero(Month(dDatabase),2) == "06"
		cMes := "F"
	Case StrZero(Month(dDatabase),2) == "07"
		cMes := "G"
	Case StrZero(Month(dDatabase),2) == "08"
		cMes := "H"
	Case StrZero(Month(dDatabase),2) == "09"
		cMes := "I"
	Case StrZero(Month(dDatabase),2) == "10"
		cMes := "J"
	Case StrZero(Month(dDatabase),2) == "11"
		cMes := "K"																		
	Case StrZero(Month(dDatabase),2) == "12"
		cMes := "L"
End Case


Do Case
	Case MV_PAR13 == "001"
		cNumBorAnt := "A"+Substr(SM0->M0_CODFIL,2,1)+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)
	Case MV_PAR13 == "237"
		cNumBorAnt := "E"+Substr(SM0->M0_CODFIL,2,1)+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)		
	Case MV_PAR13 == "027"	
		cNumBorAnt := "F"+Substr(SM0->M0_CODFIL,2,1)+StrZero(Day(dDatabase),2)+cMes+Substr(Strzero(year(dDatabase),4),4,1)	
End Case

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Banco indicado                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cBanco  := mv_par13
cAgencia:= mv_par14
cConta  := mv_par15
cSubCta := mv_par16

dbSelectArea("SA6")
If !(dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
   Help(" ",1,"NAOSA6",,"Dados Bancários Incorretos"+chr(13)+"Informe dados validos!",2,1)
	Return .F.
Endif

dbSelectArea("SEE")
SEE->( dbSeek(cFilial+cBanco+cAgencia+cConta+cSubCta) )
  
//12/07/2018 - Semaforo de Usuários 
If /*alltrim(SEE->EE_XUSER) <> alltrim(cUserName) .and. */alltrim(SEE->EE_XUSER) <> '' //Adequado, pois usuário faturamento é utilizado por varios usuarios
	Alert('O Usuário '+alltrim(SEE->EE_XUSER)+' está utilizando a Rotina, aguarde!' ) 
	Return    
Else 
    dbselectarea('SEE')
	Reclock("SEE")
  		Replace EE_XUSER With alltrim(cUserName)
	SEE->(MsUnlock())    
Endif 

If !SEE->( found() )
	Help(" ",1,"PAR150")
	dbselectarea('SEE')
	Reclock("SEE")
	  Replace EE_XUSER With ''
	SEE->(MsUnlock())
	Return .F.
Else
	If Val(EE_FAXFIM)-Val(EE_FAXATU) < 100
		Help(" ",1,"FAIXA150")
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Bordero Informado pelo usuario                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lResp:=AbrePar()	//Abertura Arquivo ASC II

If !lResp 
	dbselectarea('SEE')
	Reclock("SEE")
	  Replace EE_XUSER With ''
	SEE->(MsUnlock())
	Return .F.
Endif

nTotCnab2 := 0
nSeq := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a leitura do arquivo de Titulos                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbGotop()
ProcRegua(TRB->(RecCount()))
While !Eof()
	IncProc()
	If !IsMark( "OK", cMarca )
		dbSelectArea("TRB")
		dbSkip()
		Loop
	Endif
	dbSelectArea("SE1")
	SE1->( dbSetOrder(2) )
	SE1->( dbSeek(xFilial("SE1")+TRB->CLIENTE+TRB->LOJA+SM0->M0_CODFIL+Substr(ALLTRIM(TRB->SERIE),1,1)+TRB->DOC,.T.))
	While !SE1->( Eof()) .AND. SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial("SE1")+TRB->CLIENTE+TRB->LOJA+SM0->M0_CODFIL+Substr(ALLTRIM(TRB->SERIE),1,1)+TRB->DOC

		If !Empty(SE1->E1_NUMBOR) .AND. SE1->E1_NUMBOR <> cNumBorAnt
		  	SE1->( dbSkip() )
			Loop
		EndIf

//		IF SE1->E1_SITUACA <> "0"
//			SE1->( dbSkip() )
//     		Loop
//		Endif
		
		IF Alltrim(SE1->E1_TIPO) == "NCC" .Or.;
		   Alltrim(SE1->E1_TIPO) == "NP"  .Or.;
		   Alltrim(SE1->E1_TIPO) == "CH" 		
		   SE1->( dbSkip() )
	       Loop
		Endif

		IF Alltrim(SE1->E1_TIPO) <> "NF" 
		   SE1->( dbSkip() )
	       Loop
		Endif

		IF SE1->E1_EMISSAO <> TRB->EMISSAO
		   SE1->( dbSkip() )
	      Loop
		Endif

		lAchouBord := .T.

	  	SELE SE1
  		reclock('SE1',.f.)
  		SE1->E1_PORTADO := cBanco
  		SE1->E1_AGEDEP  := cAgencia
  		SE1->E1_CONTA   := cConta
  		SE1->E1_VENCREA := DATAVALIDA(SE1->E1_VENCREA+SA6->A6_RETENCA,.T.)
  		se1->e1_numbor  := cNumBorAnt
  		se1->e1_databor := dDataBase
  		se1->e1_situaca := '1'
  		SE1->(msunlock())//'SE1')

	  	sele sea
  		dbseek(xfilial('SEA')+SE1->E1_NUMBOR+se1->e1_prefixo+se1->e1_num+se1->e1_parcela+se1->e1_tipo,.t.)
  		while !eof() .and. sea->ea_filial==xfilial('SEA') .and.;
  				SE1->E1_NUMBOR  == SEA->EA_NUMBOR .and.;
        		se1->e1_prefixo == sea->ea_prefixo .and.;
        		se1->e1_num     == sea->ea_num     .and.;
        		se1->e1_parcela == sea->ea_parcela .and.;
        		se1->e1_tipo    == sea->ea_tipo

      		reclock('SEA',.f.)
      		dbdelete()
        	SEA->(msunlock())//'SEA')
        	sele sea
        	skip
        	loop
  		end

  		SELE SEA
  		reclock('SEA',.t.)
  		sea->ea_filial  := xfilial('SEA')
  		sea->ea_prefixo := se1->e1_prefixo
  		sea->ea_num     := se1->e1_num
  		sea->ea_parcela := se1->e1_parcela
  		sea->ea_portado := cBanco
  		sea->ea_agedep  := cAgencia
  		sea->ea_numcon  := cConta
  		sea->ea_numbor  := cNumBorAnt
  		sea->ea_databor := dDataBase
  		sea->ea_tipo    := se1->e1_tipo
  		sea->ea_cart    := 'R'
  		SEA->(msunlock())//'SEA')

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   	//³ Posiciona no cliente                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA1")
		dbSeek(cFilial+SE1->E1_CLIENTE+SE1->E1_LOJA)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Posiciona no Contrato bancario                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SE9")
		dbSetOrder(1)
		dbSeek(xFilial("SE9")+SE1->(E1_CONTRAT+E1_PORTADO+E1_AGEDEP))
		
		dbSelectArea("SE1")

		nSeq++
		nSomaValor += SE1->E1_SALDO

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Le Arquivo de Parametrizacao                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLidos:=0
		FSEEK(nHdlBco,0,0)
		nTamArq:=FSEEK(nHdlBco,0,2)
		FSEEK(nHdlBco,0,0)
	
		While nLidos <= nTamArq

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o tipo qual registro foi lido                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			xBuffer:=Space(85)
			FREAD(nHdlBco,@xBuffer,85)

			Do Case
				Case SubStr(xBuffer,1,1) == CHR(1)
					IF lHeader
						nLidos+=85
						Loop
					EndIF
				Case SubStr(xBuffer,1,1) == CHR(2)
					IF !lFirst
						lFirst := .T.
						FWRITE(nHdlSaida,CHR(13)+CHR(10))
					EndIF
				Case SubStr(xBuffer,1,1) == CHR(3)
					nLidos+=85
					Loop
				Otherwise
					nLidos+=85
					Loop
			EndCase

			nTam := 1+(Val(SubStr(xBuffer,20,3))-Val(SubStr(xBuffer,17,3)))
			nDec := Val(SubStr(xBuffer,23,1))
			cConteudo:= SubStr(xBuffer,24,60)
			nGrava := A094Grava(nTam,nDec,cConteudo,@aBordero,,lFinCnab2)
			If nGrava != 1
				Exit
			Endif
			dbSelectArea("SE1")
			nLidos+=85
		EndDO
		If nGrava == 3
			Exit
		Endif
		If nGrava == 1
   		fWrite(nHdlSaida,CHR(13)+CHR(10))
			IF !lHeader
				lHeader := .T.
			EndIF
			dbSelectArea("SEA")
			If (dbSeek(xFilial()+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
				Reclock("SEA")
				SEA -> EA_TRANSF := "S"
				SEA->(MsUnlock())//'SEA')
			Endif
	   Endif

		dbSelectArea("SE1")
		SE1->( dbSkip())
	Enddo
	dbSelectArea("TRB")
	dbSkip()
EndDo

If !lAchouBord
	Help(" ",1,"BORD150") 
	dbselectarea('SEE')
	Reclock("SEE")
	  Replace EE_XUSER With ''
	SEE->(MsUnlock())
	Return .F.
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Registro Trailler                              		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSeq++
nLidos:=0
FSEEK(nHdlBco,0,0)
nTamArq:=FSEEK(nHdlBco,0,2)
FSEEK(nHdlBco,0,0)
While nLidos <= nTamArq

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tipo qual registro foi lido                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xBuffer:=Space(85)
	FREAD(nHdlBco,@xBuffer,85)

	IF SubStr(xBuffer,1,1) == CHR(3)
		nTam := 1+(Val(SubStr(xBuffer,20,3))-Val(SubStr(xBuffer,17,3)))
		nDec := Val(SubStr(xBuffer,23,1))
		cConteudo:= SubStr(xBuffer,24,60)
		nGrava:=A094Grava( nTam,nDec,cConteudo,@aBordero,.T.,lFinCnab2 )
	 End
	nLidos+=85
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Numero do ultimo Disco                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SEE")
IF !Eof() .and. nGrava != 3
	Reclock("SEE")
	nUltDisco:=VAL(EE_ULTDSK)  //+1
   Replace EE_ULTDSK With StrZero(nUltDisco,6)
   	SEE->(MsUnlock())//MsUnlock("SEE")
EndIF
FWRITE(nHdlSaida,CHR(13)+CHR(10))

dbSelectArea( cAlias )
dbGoTo( nSavRecno )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha o arquivo gerado.                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FCLOSE(nHdlSaida)    

//12/07/2018 - Semaforo de Usuários
dbselectarea('SEE')
Reclock("SEE")
  Replace EE_XUSER With ''
SEE->(MsUnlock())//MsUnlock("SEE")

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AbrePar   ³ Autor ³ Wagner Xavier         ³ Data ³ 26/11/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Abre arquivo de Parametros Banco Brasil                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AbrePar()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³AGR094                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AbrePar()
LOCAL cArqEnt:=mv_par11,cArqSaida

IF AT(".",mv_par12)>0
	cArqSaida:=SubStr(TRIM(mv_par12),1,AT(".",mv_par12)-1)+"."+TRIM(SEE->EE_EXTEN)
Else
	cArqSaida:=TRIM(mv_par12)+"."+TRIM(SEE->EE_EXTEN)
EndIF

IF !FILE(cArqEnt)
	Help(" ",1,"NOARQPAR")
	Return .F.
Else
	nHdlBco:=FOPEN(cArqEnt,0+64)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo Saida                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHdlSaida:=MSFCREATE(cArqSaida,0)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AGR094Grava³ Autor ³ Wagner Xavier         ³ Data ³ 26/05/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Geracao do Arquivo de Remessa de Comunicacao      ³±±
±±³          ³Bancaria Banco Brasil                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1:=AGR094Grava(ExpN1,ExpN2,ExpC1)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ AGR094                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function A094Grava( nTam,nDec,cConteudo,aBordero,lTrailler,lFinCnab2)
Local nRetorno := 1
Local cTecla   := ""
Local nX       := 1

lTrailler := IIF( lTrailler==NIL, .F., lTrailler ) // Para imprimir o trailler
                                                   // caso se deseje abandonar
                                                   // a gera‡Æo do arquivo
                                                   // de envio pela metade

lFinCnab2 := Iif( lFinCnab2 == Nil, .F., lFinCnab2 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O retorno podera' ser :                                  ³
//³ 1 - Grava Ok                                             ³
//³ 2 - Ignora bordero                                       ³
//³ 3 - Abandona rotina                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While .T.

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verifica se titulo ja' foi enviado                       ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    dbSelectArea("SEA")
    If (dbSeek(xFilial("SEA")+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
        If SEA->EA_TRANSF == "S"
            nX := ASCAN(aBordero,SubStr(SE1->E1_NUMBOR,1,TamSX3("E1_NUMBOR")[1]))
            If nX == 0
					nOpc  := 0
					nTipo := 1
					aTipo := {OemToAnsi("Gera com esse border“"),OemToAnsi("Ignora esse border“")}

					@ 35,37 TO 188,383 Dialog oDialogos Title OemToAnsi("Bordero Existente")
					@ 11,07 SAY OemToAnsi("O border“ n£mero:") SIZE 58, 7 // "O border“ n£mero:"
					@ 11,68 GET SE1->E1_NUMBOR When .F. SIZE 37, 10
					@ 24,07 SAY OemToAnsi("j  foi enviado ao banco.") SIZE 82, 7 // "j  foi enviado ao banco."
					@ 37,06 SAY OemToAnsi("Para prosseguir escolha uma das op‡äes")  //"Para prosseguir escolha uma das op‡äes"

					@ 45, 11 RADIO aTipo VAR nTipo // "Gera com esse border“"###"Ignora esse border“"

					DEFINE SBUTTON FROM 11, 140 TYPE 1 ENABLE OF oDialogos Action (nOpc:=1,oDialogos:End())
					DEFINE SBUTTON FROM 24, 140 TYPE 2 ENABLE OF oDialogos Action (nopc:=0,oDialogos:End())
					Activate Dialog oDialogos Centered

					If nOpc == 1
						If nTipo == 1
							nRetorno := 1
							nBorderos++
						Else
							nRetorno := 2
						EndIf
					Else
						nRetorno := 3
					EndIf				
            Else
                nRetorno := Int(Val(SubStr(aBordero[nX],7,1)))
            End
        End
    End
    If nRetorno == 1 .or. ( lTrailler .and. nBorderos > 0 )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Analisa conteudo                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF Empty(cConteudo)
			cCampo:=Space(nTam)
		Else
			lConteudo := A094Orig( cConteudo )
			IF !lConteudo
				Exit
			Else
				IF ValType(xConteudo)="D"
					cCampo := GravaData(xConteudo,.F.)
				Elseif ValType(xConteudo)="N"
					cCampo:=Substr(Strzero(xConteudo,nTam,nDec),1,nTam)
				Elseif ValType(xConteudo)="C"
					cCampo:=Substr(xConteudo,1,nTam)
				Else
					cCampo:= Iif(xConteudo,"S","N")
				End
			End
		End
		If Len(cCampo) < nTam  //Preenche campo a ser gravado, caso menor
			cCampo:=cCampo+Space(nTam-Len(cCampo))
		End
		Fwrite( nHdlSaida,cCampo,nTam )
	 EndIf
    If nX == 0
        Aadd(aBordero,Substr(SE1->E1_NUMBOR,1,TamSX3("E1_NUMBOR")[1])+Str(nRetorno,1))
    End
    Exit
End
Return nRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AGR094Orig ³ Autor ³ Wagner Xavier         ³ Data ³ 10/11/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se expressao e' valida para Remessa CNAB.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³AGR094                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A094Orig( cForm )
        Local bBlock:=ErrorBlock(),bErro := ErrorBlock( { |e| ChecErr260(e,cForm) } )
Private lRet := .T.

BEGIN SEQUENCE
	xConteudo := &cForm
END SEQUENCE
ErrorBlock(bBlock)
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SomaValor³ Autor ³ Vinicius Barreira     ³ Data ³ 09/01/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor total dos titulos remetidos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SomaValor()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SomaValor()
Return nSomaValor * 100

Static Function A094Process(oDlg,oMeter)
Local ni
oMeter:nTotal := 1000
oMeter:Set(0)
For ni:= 1 to 1000
	oMeter:Set(ni)
	SysRefresh(.t.)
Next
oDlg:End()
Return Nil

Static Function CriaPer(cGrupo,aPer)
***********************************
LOCAL lRetu := .T., aReg  := {}
LOCAL _l := 1, _m := 1, _k := 1

dbSelectArea("SX1")
If (FCount() == 41)
	For _l := 1 to Len(aPer)                                   
		Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
		                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
		                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
		                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
		                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
		                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],"","",""})
	Next _l
ElseIf (FCount() == 39)
	For _l := 1 to Len(aPer)                                   
		Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
		                  aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
		                  aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
		                  aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
		                  aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
		                  aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],""})
	Next _l
Elseif (FCount() == 26)
	aReg := aPer
Endif

dbSelectArea("SX1")
For _l := 1 to Len(aReg)
	If !dbSeek(cGrupo+StrZero(_l,02,00))
		RecLock("SX1",.T.)
		For _m := 1 to FCount()
			FieldPut(_m,aReg[_l,_m])
		Next _m
		MsUnlock("SX1")
	Elseif Alltrim(aReg[_l,3]) <> Alltrim(SX1->X1_PERGUNT)
		RecLock("SX1",.F.)
		For _k := 1 to FCount()
			FieldPut(_k,aReg[_l,_k])
		Next _k
		MsUnlock("SX1")
	Endif
Next _l

Return (lRetu)

// Grava marca no campo

User Function A094Mark

If IsMark( 'OK', cMarca )

RecLock( 'TRB', .F. )

Replace OK With Space(2)

TRB->(MsUnLock())//'TRB')

Else

RecLock( 'TRB', .F. )

Replace OK With cMarca

TRB->(MsUnLock())//'TRB')

EndIf

Return

 

// Grava marca em todos os registros validos

User Function A094All

Local nRecno := Recno()

dbSelectArea('TRB')

dbGotop()

While !Eof()

ExecBlock('A094Mark',.f.,.f.)

dbSkip()

End

dbGoto( nRecno )

Return

User Function 	XNossoNum()
******************************
Local cDigito 	:= space(01)

dbSelectArea('SE1')
If Empty(SE1->E1_NUMBCO)  

   Conout('AGR094 ANTES: '+SE1->E1_NUM + SE1->E1_PARCELA +' - '+ SEE->EE_CONTA+' - '+SEE->EE_FAXATU)	
   nNossoNum := Val(NossoNum())                         
   Conout('AGR094 DEPOIS: '+SE1->E1_NUM + SE1->E1_PARCELA +' - '+ SEE->EE_CONTA+' - '+SEE->EE_FAXATU)	
   
   cDigito   := XDigitoNosso()
   if Alltrim(SEE->EE_CODEMP) == '2988362'
      nNossoNumE1 :=  StrZero(nNossoNum,9)+cDigito
      nNossoNum   :=  Alltrim(SEE->EE_CODEMP) + StrZero(nNossoNum,9)+cDigito      
   else
      nNossoNumE1 := StrZero(nNossoNum,11)+cDigito
      nNossoNum   := StrZero(nNossoNum,11)+cDigito
        
      //VALIDA CONTA VELHA DO BANCO DO BRASIL  SPILLER - 09/072018                 
      If cEmpant=='01' 
      	If Substr(nNossoNum,1,6) <> '189343'
          	Alert('ERRO DE NN, ENTRE EM CONTATO COM A TI E NÃO ENVIE O BOLETO PARA O CLIENTE!')
     	 Endif
   	  Endif	
   endif     
    
   Conout('AGR094 NN('+ nNossoNum +'): '+ SE1->E1_NUM + SE1->E1_PARCELA +' - '+ SEE->EE_CONTA+' - '+SEE->EE_FAXATU)
      
   RecLock('SE1',.f.)
   SE1->E1_NUMBCO := nNossoNumE1
   SE1->(MsUnlock())//'SE1')
Else
//	nNossoNum := NossoNum()
   if Alltrim(SEE->EE_CODEMP) == '2988362'
      nNossoNum := Alltrim(SEE->EE_CODEMP) + Alltrim(SE1->E1_NUMBCO)
   else
      nNossoNum := Alltrim(SE1->E1_NUMBCO)
      //VALIDA CONTA VELHA DO BANCO DO BRASIL SPILLER - 09/072018                  
      If cEmpant=='01' 
      	If Substr(nNossoNum,1,6) <> '189343' 
          	Alert('ERRO DE NN, ENTRE EM CONTATO COM A TI E NÃO ENVIE O BOLETO PARA O CLIENTE!')
     	 Endif
   	  Endif	      
   endif      
EndIf


Return nNossoNum 

Static Function XDigitoNosso()
******************************
nCont:=0                                            

if Alltrim(SEE->EE_CODEMP) == '2988362'
   nSoma1 := 0 //val(subs(alltrim(mv_par17),01,1))*2
   nSoma2 := 0 //val(subs(alltrim(mv_par17),02,1))*7
   nSoma3 := val(subs(StrZero(nNossoNum,9),01,1))*7
   nSoma4 := val(subs(StrZero(nNossoNum,9),02,1))*8
   nSoma5 := val(subs(StrZero(nNossoNum,9),03,1))*9
   nSoma6 := val(subs(StrZero(nNossoNum,9),04,1))*2
   nSoma7 := val(subs(StrZero(nNossoNum,9),05,1))*3
   nSoma8 := val(subs(StrZero(nNossoNum,9),06,1))*4
   nSoma9 := val(subs(StrZero(nNossoNum,9),07,1))*5
   nSomaA := val(subs(StrZero(nNossoNum,9),08,1))*6
   nSomaB := val(subs(StrZero(nNossoNum,9),09,1))*7

    cDigito := mod(nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+;
    nSoma8+nSoma9+nSomaA+nSomaB,9)
Else 
   nSoma1 := 0 //val(subs(alltrim(mv_par17),01,1))*2
   nSoma2 := 0 //val(subs(alltrim(mv_par17),02,1))*7
   nSoma3 := val(subs(StrZero(nNossoNum,11),01,1))*7
   nSoma4 := val(subs(StrZero(nNossoNum,11),02,1))*8
   nSoma5 := val(subs(StrZero(nNossoNum,11),03,1))*9
   nSoma6 := val(subs(StrZero(nNossoNum,11),04,1))*2
   nSoma7 := val(subs(StrZero(nNossoNum,11),05,1))*3
   nSoma8 := val(subs(StrZero(nNossoNum,11),06,1))*4
   nSoma9 := val(subs(StrZero(nNossoNum,11),07,1))*5
   nSomaA := val(subs(StrZero(nNossoNum,11),08,1))*6
   nSomaB := val(subs(StrZero(nNossoNum,11),09,1))*7
   nSomaC := val(subs(StrZero(nNossoNum,11),10,1))*8
   nSomaD := val(subs(StrZero(nNossoNum,11),11,1))*9

    cDigito := mod(nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+;
    nSoma8+nSoma9+nSomaA+nSomaB+nSomaC+nSomaD,11)
EndIf

//cDigito := mod(nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+;
//nSoma8+nSoma9+nSomaA+nSomaB+nSomaC+nSomaD,11)

//nCont := iif(cDigito == 10, "X", iif(cDigito == 0 , "0", strzero(11-cDigito,1)))
nCont := iif(cDigito == 10, "X", iif(cDigito == 0 , "0", strzero(cDigito,1)))
Return nCont